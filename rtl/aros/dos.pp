{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2004 by Karoly Balogh for Genesi S.a.r.l.

    Heavily based on the Commodore Amiga/m68k RTL by Nils Sjoholm and
    Carl Eric Codere

    MorphOS port was done on a free Pegasos II/G4 machine
    provided by Genesi S.a.r.l. <www.genesi.lu>
    
    AROS Port by Marcus Sackrow 2011

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$INLINE ON}

{$MODE objfpc}
unit Dos;

{--------------------------------------------------------------------}
{ LEFT TO DO:                                                        }
{--------------------------------------------------------------------}
{ o DiskFree / Disksize don't work as expected                       }
{ o Implement EnvCount,EnvStr                                        }
{ o FindFirst should only work with correct attributes               }
{--------------------------------------------------------------------}

interface

type
  SearchRec = packed record
    { watch out this is correctly aligned for all processors }
    { don't modify.                                          }
    { Replacement for Fill }
{0} AnchorPtr : Pointer;    { Pointer to the Anchorpath structure }
{4} Fill: array[1..15] of Byte; {future use}
    {End of replacement for fill}
    Attr : Byte;        {attribute of found file}
    Time : LongInt;     {last modify date of found file}
    Size : LongInt;     {file size of found file}
    Name : String[255]; {name of found file}
  End;

{$I dosh.inc}

implementation

{$DEFINE HAS_GETMSCOUNT}
{$DEFINE HAS_GETCBREAK}
{$DEFINE HAS_SETCBREAK}

{$DEFINE FPC_FEXPAND_VOLUMES} (* Full paths begin with drive specification *)
{$DEFINE FPC_FEXPAND_DRIVESEP_IS_ROOT}
{$DEFINE FPC_FEXPAND_NO_DEFAULT_PATHS}
{$I dos.inc}


{ * include AROS specific functions & definitions * }

{$include execd.inc}
{$include execf.inc}
{$include timerd.inc}
{$include doslibd.inc}
{$include doslibf.inc}
{$include utilf.inc}

const
  DaysPerMonth :  Array[1..12] of ShortInt =
         (031,028,031,030,031,030,031,031,030,031,030,031);
  DaysPerYear  :  Array[1..12] of Integer  =
         (031,059,090,120,151,181,212,243,273,304,334,365);
  DaysPerLeapYear :    Array[1..12] of Integer  =
         (031,060,091,121,152,182,213,244,274,305,335,366);
  SecsPerYear      : LongInt  = 31536000;
  SecsPerLeapYear  : LongInt  = 31622400;
  SecsPerDay       : LongInt  = 86400;
  SecsPerHour      : Integer  = 3600;
  SecsPerMinute    : ShortInt = 60;
  TICKSPERSECOND    = 50;


{******************************************************************************
                           --- Internal routines ---
******************************************************************************}

{ * PathConv is implemented in the system unit! * }
function PathConv(path: string): string; external name 'PATHCONV';

function DosLock(const Name: string; AccessMode: Longint): LongInt;
var
  Buffer: array of char;
begin
  SetLength(Buffer, Length(Name) + 1);
  Move(Name[1], Buffer[0], Length(Name));
  Buffer[Length(Name)] := #0;
  dosLock:=Lock(PChar(@Buffer[0]), AccessMode);
end;

function BADDR(BVal: Cardinal): Pointer; inline;
begin
  {$ifdef AROS_BINCOMPAT}
  BADDR := Pointer(BVal shl 2);
  {$else}
  BADDR := Pointer(BVal);
  {$endif}
end;

function BSTR2STRING(s : BSTR): PChar; inline;
begin
  BSTR2STRING := Pointer(BADDR(Cardinal(s)) + 1);
end;

function IsLeapYear(Source: Word) : Boolean;
begin
  if (source Mod 400 = 0) or ((source Mod 4 = 0) and (source Mod 100 <> 0)) then
    IsLeapYear:=True
  else
    IsLeapYear:=False;
end;

procedure Amiga2DateStamp(Date : LongInt; var TotalDays, Minutes, Ticks: LongInt);
{ Converts a value in seconds past 1978 to a value in AMIGA DateStamp format }
{ Taken from SWAG and modified to work with the Amiga format - CEC           }
var
  LocalDate : LongInt;
  Done : Boolean;
  TotDays : Integer;
  Y: Word;
  H: Word;
  Min: Word;
  S : Word;
begin
  Y   := 1978; H := 0; Min := 0; S := 0;
  TotalDays := 0;
  Minutes := 0;
  Ticks := 0;
  LocalDate := Date;
  Done := False;
  while not Done do
  begin
    if LocalDate >= SecsPerYear then
    begin
      Inc(Y, 1);
      Dec(LocalDate, SecsPerYear);
      Inc(TotalDays, DaysPerYear[12]);
    end else
      Done := true;
    if (IsLeapYear(Y + 1)) and (LocalDate >= SecsPerLeapYear) and
       (Not Done) then
    begin
      Inc(Y, 1);
      Dec(LocalDate, SecsPerLeapYear);
      Inc(TotalDays, DaysPerLeapYear[12]);
    end;
  end; { END WHILE }

  TotDays := LocalDate div SecsPerDay;
  { Total number of days }
  TotalDays := TotalDays + TotDays;
  Dec(LocalDate, TotDays * SecsPerDay);
  { Absolute hours since start of day }
  H := LocalDate div SecsPerHour;
  { Convert to minutes }
  Minutes := H * 60;
  Dec(LocalDate, (H * SecsPerHour));
  { Find the remaining minutes to add }
  Min := LocalDate div SecsPerMinute;
  Dec(LocalDate, (Min * SecsPerMinute));
  Minutes := Minutes + Min;
  { Find the number of seconds and convert to ticks }
  S := LocalDate;
  Ticks := TICKSPERSECOND * S;
end;

function DosSetProtection(const Name: string; Mask: LongInt): Boolean;
var
  Buffer: array of char;
begin
  SetLength(Buffer, Length(Name) + 1);
  Move(Name[1], Buffer[0], Length(Name));
  Buffer[Length(Name)] := #0;
  DosSetProtection := SetProtection(PChar(@Buffer[0]), Mask);
end;

function DosSetFileDate(Name: string; P : PDateStamp): Boolean;
var
  Buffer: array of char;
begin
  SetLength(Buffer, Length(Name) + 1);
  Move(Name[1], Buffer[0], Length(Name));
  Buffer[Length(Name)] := #0;
  DosSetFileDate := SetFileDate(PChar(@Buffer[0]), P);
end;


{******************************************************************************
                        --- Info / Date / Time ---
******************************************************************************}

function DosVersion: Word;
var
  p: PLibrary;
begin
  P := PLibrary(AOS_DOSBase);
  DosVersion := P^.lib_Version or (P^.lib_Revision shl 8);
end;

{ Here are a lot of stuff just for setdate and settime }

var
  TimerBase : Pointer;


procedure NewList(List: PList);
begin
  with list^ do
  begin
    lh_Head := PNode(@lh_Tail);
    lh_Tail := nil;
    lh_TailPred := PNode(@lh_Head)
  end;
end;

function CreateExtIO (Port: PMsgPort; Size: LongInt): PIORequest;
var
   IOReq: PIORequest;
begin
  IOReq := nil;
  if Port <> nil then
  begin
    IOReq := ExecAllocMem(Size, MEMF_CLEAR);
    if IOReq <> NIL then
    begin
      IOReq^.io_Message.mn_Node.ln_Type := 7;
      IOReq^.io_Message.mn_Length := Size;
      IOReq^.io_Message.mn_ReplyPort := Port;
    end;
  end;
  CreateExtIO := IOReq;
end;

procedure DeleteExtIO (IOReq: PIORequest);
begin
  if IOReq <> NIL then 
  begin
    IOReq^.io_Message.mn_Node.ln_Type := $FF;
    IOReq^.io_Message.mn_ReplyPort := PMsgPort(-1);
    IOReq^.io_Device := PDevice(-1);
    ExecFreeMem(IOReq, IOReq^.io_Message.mn_Length);
  end
end;

function CreatePort(Name: PChar; Pri: LongInt): PMsgPort;
var
  SigBit: ShortInt;
  Port: PMsgPort;
begin
  SigBit := AllocSignal(-1);
  if SigBit = -1 then
    CreatePort := nil;
  Port := ExecAllocMem(SizeOf(TMsgPort), MEMF_CLEAR);
  if Port = nil then
  begin
     FreeSignal(SigBit);
     CreatePort := nil;
     Exit;
  end;
  with Port^ do
  begin
    if Assigned(Name) then
      mp_Node.ln_Name := Name
    else
      mp_Node.ln_Name := nil;
    mp_Node.ln_Pri := Pri;
    mp_Node.ln_Type := 4;
    mp_Flags := 0;
    mp_SigBit := SigBit;
    mp_SigTask := FindTask(nil);
  end;
  if Assigned(Name) then
    AddPort(Port)
  else
    NewList(Addr(Port^.mp_MsgList));
  CreatePort := Port;
end;

procedure DeletePort(Port: PMsgPort);
begin
  if Port <> nil then
  begin
    if Port^.mp_Node.ln_Name <> nil then
      RemPort(Port);
    Port^.mp_Node.ln_Type := $FF;
    Port^.mp_MsgList.lh_Head := PNode(-1);
    FreeSignal(Port^.mp_SigBit);
    ExecFreeMem(Port, SizeOf(TMsgPort));
  end;
end;

function CreateTimer(TheUnit: LongInt) : PTimeRequest;
var
  Error: LongInt;
  TimerPort: PMsgPort;
  TimeReq: PTimeRequest;
begin
  TimerPort := CreatePort(nil, 0);
  if TimerPort = nil then
  begin
    CreateTimer := nil;
    Exit;
  end;
  TimeReq := PTimeRequest(CreateExtIO(TimerPort, SizeOf(TTimeRequest)));
  if TimeReq = nil then
  begin
    DeletePort(TimerPort);
    CreateTimer := nil;
    Exit;
  end;
  Error := OpenDevice(TIMERNAME, TheUnit, PIORequest(TimeReq), 0);
  if Error <> 0 then
  begin
    DeleteExtIO(PIORequest(TimeReq));
    DeletePort(TimerPort);
    CreateTimer := Nil;
    Exit;
  end;
  TimerBase := Pointer(TimeReq^.tr_Node.io_Device);
  CreateTimer := PTimeRequest(TimeReq);
end;

Procedure DeleteTimer(WhichTimer: PTimeRequest);
var
  WhichPort: PMsgPort;
begin
  WhichPort := WhichTimer^.tr_Node.io_Message.mn_ReplyPort;
  if Assigned(WhichTimer) then
  begin
    CloseDevice(PIORequest(WhichTimer));
    DeleteExtIO(PIORequest(WhichTimer));
  end;
  if Assigned(WhichPort) then
    DeletePort(WhichPort);
end;

function SetNewTime(Secs, Micro: LongInt): LongInt;
var
  Tr : PTimeRequest;
begin
  Tr := CreateTimer(UNIT_MICROHZ);
    { non zero return says error }
  if Tr = nil then
  begin
    SetNewTime := -1;
    Exit;
  end;  
  Tr^.tr_time.tv_secs := Secs;
  Tr^.tr_time.tv_micro := Micro;
  Tr^.tr_node.io_Command := TR_SETSYSTIME;
  DoIO(PIORequest(Tr));
  DeleteTimer(Tr);
  SetNewTime := 0;
end;


function GetSysTime(Tv: PTimeVal): LongInt;
var
  Tr : PTimeRequest;
begin
  Tr := CreateTimer(UNIT_MICROHZ);
  { non zero return says error }
  if Tr = nil then
  begin
    GetSysTime := -1;
    Exit;
  end;
  Tr^.tr_node.io_Command := TR_GETSYSTIME;
  DoIO(pIORequest(Tr));
  { structure assignment }
  Tv^ := Tr^.tr_time;
  DeleteTimer(Tr);
  GetSysTime := 0;
end;

procedure GetDate(var Year, Month, MDay, WDay: Word);
var
  Cd: PClockData;
  ATime: TTimeVal;
begin
  New(Cd);
  try
    GetSysTime(@ATime);
    Amiga2Date(ATime.tv_secs, Cd);
    Year := Cd^.year;
    Month := Cd^.month;
    MDay := Cd^.mday;
    WDay := Cd^.wday;
  finally
    Dispose(Cd);
  end;
end;

procedure SetDate(Year, Month, Day: Word);
var
  Cd: PClockData;
  ATime: TTimeVal;
begin
  New(Cd);
  try
    GetSysTime(@ATime);
    Amiga2Date(ATime.tv_secs, Cd);
    Cd^.year := Year;
    Cd^.month := Month;
    Cd^.mday := Day;
    SetNewTime(Date2Amiga(Cd), 0);
  finally
    Dispose(Cd);
  end;
end;

procedure GetTime(var Hour, Minute, Second, Sec100: Word);
var
  Cd: PClockData;
  ATime : TTimeVal;
begin
  New(Cd);
  try
    GetSysTime(@ATime);
    Amiga2Date(ATime.tv_secs, Cd);
    Hour   := Cd^.hour;
    Minute := Cd^.min;
    Second := Cd^.sec;
    Sec100 := ATime.tv_micro div 10000;
  finally  
    Dispose(Cd);
  end;
end;


Procedure SetTime(Hour, Minute, Second, Sec100: Word);
var
  Cd: PClockData;
  ATime: TTimeVal;
begin
  New(Cd);
  try
    GetSysTime(@ATime);
    Amiga2Date(ATime.tv_secs, Cd);
    Cd^.hour := Hour;
    Cd^.min := Minute;
    Cd^.sec := Second;
    SetNewTime(Date2Amiga(Cd), Sec100 * 10000);
  finally  
   Dispose(Cd);
  end;
end;


function GetmsCount: Int64;
var
  ATime: TTimeVal;
begin
  GetSysTime(@ATime);
  GetmsCount := Int64(ATime.tv_Secs) * 1000 + ATime.tv_Micro div 1000;
end;

{******************************************************************************
                               --- Exec ---
******************************************************************************}


procedure Exec(const Path: PathStr; const ComLine: ComStr);
var
  TmpPath: array[0..255] of char;
  Result : longInt;
  TmpLock: longInt;
begin
  DosError := 0;
  LastDosExitCode :=0;
  TmpPath := PathConv(Path) + #0 + ComLine + #0; // hacky... :)

  { Here we must first check if the command we wish to execute }
  { actually exists, because this is NOT handled by the        }
  { _SystemTagList call (program will abort!!)                 }

  { Try to open with shared lock                               }
  TmpLock := Lock(TmpPath, SHARED_LOCK);
  if TmpLock <> 0 then
  begin
    { File exists - therefore unlock it }
    Unlock(TmpLock);
    TmpPath[Length(Path)]:=' '; // hacky... replaces first #0 from above, to get the whole string. :)
    Result := SystemTagList(TmpPath, nil);
    { on return of -1 the shell could not be executed }
    { probably because there was not enough memory    }
    if Result = -1 then
      DosError:=8
    else
      LastDosExitCode := Word(Result);
  end else
    DosError:=3;
end;


procedure GetCBreak(var BreakValue: Boolean);
begin
  BreakValue := system.BreakOn;
end;

procedure SetCBreak(BreakValue: Boolean);
begin
  System.BreakOn := BreakValue;
end;


{******************************************************************************
                               --- Disk ---
******************************************************************************}

{ How to solve the problem with this:       }
{  We could walk through the device list    }
{  at startup to determine possible devices }

const

  not_to_use_devs : array[0..12] of string =(
                   'DF0:',
                   'DF1:',
                   'DF2:',
                   'DF3:',
                   'PED:',
                   'PRJ:',
                   'PIPE:',
                   'RAM:',
                   'CON:',
                   'RAW:',
                   'SER:',
                   'PAR:',
                   'PRT:');

var
   deviceids : array[1..20] of byte;
   devicenames : array[1..20] of string[20];
   numberofdevices : Byte;

Function DiskFree(Drive: Byte): Int64;
Var
  MyLock      : LongInt;
  Inf         : pInfoData;
  Free        : Longint;
  myproc      : pProcess;
  OldWinPtr   : Pointer;
Begin
  Free := -1;
  { Here we stop systemrequesters to appear }
  myproc := pProcess(FindTask(nil));
  OldWinPtr := myproc^.pr_WindowPtr;
  myproc^.pr_WindowPtr := Pointer(-1);
  { End of systemrequesterstop }
  New(Inf);
  MyLock := dosLock(devicenames[deviceids[Drive]],SHARED_LOCK);
  If MyLock <> 0 then begin
     if Info(MyLock,Inf) then begin
        Free := (Inf^.id_NumBlocks * Inf^.id_BytesPerBlock) -
                (Inf^.id_NumBlocksUsed * Inf^.id_BytesPerBlock);
     end;
     Unlock(MyLock);
  end;
  Dispose(Inf);
  { Restore systemrequesters }
  myproc^.pr_WindowPtr := OldWinPtr;
  diskfree := Free;
end;



Function DiskSize(Drive: Byte): int64;
Var
  MyLock      : LongInt;
  Inf         : pInfoData;
  Size        : Longint;
  myproc      : pProcess;
  OldWinPtr   : Pointer;
Begin
  Size := -1;
  { Here we stop systemrequesters to appear }
  myproc := pProcess(FindTask(nil));
  OldWinPtr := myproc^.pr_WindowPtr;
  myproc^.pr_WindowPtr := Pointer(-1);
  { End of systemrequesterstop }
  New(Inf);
  MyLock := dosLock(devicenames[deviceids[Drive]],SHARED_LOCK);
  If MyLock <> 0 then begin
     if Info(MyLock,Inf) then begin
        Size := (Inf^.id_NumBlocks * Inf^.id_BytesPerBlock);
     end;
     Unlock(MyLock);
  end;
  Dispose(Inf);
  { Restore systemrequesters }
  myproc^.pr_WindowPtr := OldWinPtr;
  disksize := Size;
end;


procedure FindFirst(const Path: PathStr; Attr: Word; Var f: SearchRec);
var
 tmpStr: array[0..255] of Char;
 Anchor: PAnchorPath;
 Result: LongInt;
begin
  tmpStr:=PathConv(path)+#0;
  DosError:=0;

  new(Anchor);
  FillChar(Anchor^,sizeof(TAnchorPath),#0);

  Result:=MatchFirst(@tmpStr,Anchor);
  f.AnchorPtr:=Anchor;
  if Result = ERROR_NO_MORE_ENTRIES then
    DosError:=18
  else
    if Result<>0 then DosError:=3;

  if DosError=0 then begin
    {-------------------------------------------------------------------}
    { Here we fill up the SearchRec attribute, but we also do check     }
    { something else, if the it does not match the mask we are looking  }
    { for we should go to the next file or directory.                   }
    {-------------------------------------------------------------------}
    with Anchor^.ap_Info do begin
      f.Time := fib_Date.ds_Days * (24 * 60 * 60) +
                fib_Date.ds_Minute * 60 +
                fib_Date.ds_Tick div 50;
      f.attr := 0;
      {*------------------------------------*}
      {* Determine if is a file or a folder *}
      {*------------------------------------*}
      if fib_DirEntryType>0 then f.attr:=f.attr OR DIRECTORY;

      {*------------------------------------*}
      {* Determine if Read only             *}
      {*  Readonly if R flag on and W flag  *}
      {*   off.                             *}
      {* Should we check also that EXEC     *}
      {* is zero? for read only?            *}
      {*------------------------------------*}
      if ((fib_Protection and FIBF_READ) <> 0) and
         ((fib_Protection and FIBF_WRITE) = 0) then f.attr:=f.attr or READONLY;
      f.Name := strpas(fib_FileName);
      f.Size := fib_Size;
    end; { end with }
  end;
end;


procedure FindNext(Var f: SearchRec);
var
 Result: longint;
 Anchor: PAnchorPath;
begin
  DosError:=0;
  Result:=MatchNext(f.AnchorPtr);
  if Result = ERROR_NO_MORE_ENTRIES then
    DosError:=18
  else
    if Result <> 0 then DosError:=3;

  if DosError=0 then begin
    { Fill up the Searchrec information     }
    { and also check if the files are with  }
    { the correct attributes                }
    Anchor:=pAnchorPath(f.AnchorPtr);
    with Anchor^.ap_Info do begin
      f.Time := fib_Date.ds_Days * (24 * 60 * 60) +
                fib_Date.ds_Minute * 60 +
                fib_Date.ds_Tick div 50;
      f.attr := 0;
      {*------------------------------------*}
      {* Determine if is a file or a folder *}
      {*------------------------------------*}
      if fib_DirEntryType > 0 then f.attr:=f.attr OR DIRECTORY;

      {*------------------------------------*}
      {* Determine if Read only             *}
      {*  Readonly if R flag on and W flag  *}
      {*   off.                             *}
      {* Should we check also that EXEC     *}
      {* is zero? for read only?            *}
      {*------------------------------------*}
      if ((fib_Protection and FIBF_READ) <> 0) and
         ((fib_Protection and FIBF_WRITE) = 0) then f.attr:=f.attr or READONLY;
      f.Name := strpas(fib_FileName);
      f.Size := fib_Size;
    end; { end with }
  end;
end;

procedure FindClose(Var f: SearchRec);
begin
  MatchEnd(f.AnchorPtr);
  if assigned(f.AnchorPtr) then
    Dispose(PAnchorPath(f.AnchorPtr));
end;


{******************************************************************************
                               --- File ---
******************************************************************************}

function FSearch(path: PathStr; dirlist: String) : PathStr;
var
  p1     : LongInt;
  tmpSR  : SearchRec;
  newdir : PathStr;
begin
  { No wildcards allowed in these things }
  if (pos('?',path)<>0) or (pos('*',path)<>0) or (path='') then
    FSearch:=''
  else begin
    repeat
      p1:=pos(';',dirlist);
      if p1<>0 then begin
        newdir:=Copy(dirlist,1,p1-1);
        Delete(dirlist,1,p1);
      end else begin
        newdir:=dirlist;
        dirlist:='';
      end;
      if (newdir<>'') and (not (newdir[length(newdir)] in ['/',':'])) then
        newdir:=newdir+'/';
      FindFirst(newdir+path,anyfile,tmpSR);
      if doserror=0 then
        newdir:=newdir+path
      else
        newdir:='';
    until (dirlist='') or (newdir<>'');
    FSearch:=newdir;
  end;
end;


Procedure getftime (var f; var time : longint);
{
    This function returns a file's date and time as the number of
    seconds after January 1, 1978 that the file was created.
}
var
    FInfo: PFileInfoBlock;
    FTime: Longint;
    FLock: Longint;
    Str: String;
begin
    DosError:=0;
    FTime := 0;
    Str := StrPas(filerec(f).name);
    DoDirSeparators(Str);
    FLock := dosLock(Str, SHARED_LOCK);
    IF FLock <> 0 then begin
        New(FInfo);
        if Examine(FLock, FInfo) then begin
             with FInfo^.fib_Date do
             FTime := ds_Days * (24 * 60 * 60) +
             ds_Minute * 60 +
             ds_Tick div 50;
        end else begin
             FTime := 0;
        end;
        Unlock(FLock);
        Dispose(FInfo);
    end
    else
     DosError:=6;
    time := FTime;
end;


  Procedure setftime(var f; time : longint);
   var
    DateStamp: pDateStamp;
    Str: String;
    Days, Minutes,Ticks: longint;
    FLock: longint;
  Begin
    new(DateStamp);
    Str := StrPas(filerec(f).name);
    DoDirSeparators(str);
    { Check first of all, if file exists }
    FLock := dosLock(Str, SHARED_LOCK);
    IF FLock <> 0 then
      begin
        Unlock(FLock);
        Amiga2DateStamp(time,Days,Minutes,ticks);
        DateStamp^.ds_Days:=Days;
        DateStamp^.ds_Minute:=Minutes;
        DateStamp^.ds_Tick:=Ticks;
        if dosSetFileDate(Str,DateStamp) then
            DosError:=0
        else
            DosError:=6;
      end
    else
      DosError:=2;
    if assigned(DateStamp) then Dispose(DateStamp);
  End;

procedure getfattr(var f; var attr : word);
var
    info : pFileInfoBlock;
    MyLock : Longint;
    flags: word;
    Str: String;
begin
    DosError:=0;
    flags:=0;
    New(info);
    Str := StrPas(filerec(f).name);
    DoDirSeparators(str);
    { open with shared lock to check if file exists }
    MyLock:=dosLock(Str,SHARED_LOCK);
    if MyLock <> 0 then
      Begin
        Examine(MyLock,info);
        {*------------------------------------*}
        {* Determine if is a file or a folder *}
        {*------------------------------------*}
        if info^.fib_DirEntryType > 0 then
             flags:=flags OR DIRECTORY;

        {*------------------------------------*}
        {* Determine if Read only             *}
        {*  Readonly if R flag on and W flag  *}
        {*   off.                             *}
        {* Should we check also that EXEC     *}
        {* is zero? for read only?            *}
        {*------------------------------------*}
        if   ((info^.fib_Protection and FIBF_READ) <> 0)
         AND ((info^.fib_Protection and FIBF_WRITE) = 0)
         then
          flags:=flags OR ReadOnly;
        Unlock(mylock);
      end
    else
      DosError:=3;
    attr:=flags;
    Dispose(info);
  End;


procedure setfattr(var f; attr : word);
var
  flags: longint;
  tmpLock : longint;
begin
  DosError:=0;
  flags:=FIBF_WRITE;

  { By default files are read-write }
  if attr and ReadOnly <> 0 then flags:=FIBF_READ; { Clear the Fibf_write flags }

  { no need for path conversion here, because file opening already }
  { converts the path (KB) }

  { create a shared lock on the file }
  tmpLock:=Lock(filerec(f).name,SHARED_LOCK);
  if tmpLock <> 0 then begin
    Unlock(tmpLock);
    if not SetProtection(filerec(f).name,flags) then DosError:=5;
  end else
    DosError:=3;
end;



{******************************************************************************
                             --- Environment ---
******************************************************************************}

var
  strofpaths : string;

function GetPathString: string;
type
  TPathEntry = record
    next: Pointer;
    lock: LongInt;
  end;
  PPathEntry = ^TPathEntry;
var
  Cl: PCommandLineInterface;
  Cur: PPathEntry;
  Buffer:PChar;
  Temp: string;
begin
  Cl := Cli();
  if not Assigned(cl) then
  begin
    GetPathString :='c:';
    Exit;
  end;
  Cur := PPathEntry(cli^.cli_CommandDir);
  GetMem(Buffer, 2048);
  try  
    Temp := '';
    repeat
      if NameFromLock(cur^.Lock, Buffer, 2048) then
        Temp := Temp + string(Buffer) + ';';
      Cur := Cur^.Next;
    until Cur = NIL;
    Temp := Temp + 'C:';
  finally
    FreeMem(Buffer);
  end;
  GetPathString := Temp;
end;

function EnvCount: Longint;
{ HOW TO GET THIS VALUE:                                }
{   Each time this function is called, we look at the   }
{   local variables in the Process structure (2.0+)     }
{   And we also read all files in the ENV: directory    }
begin
  EnvCount := 0;
end;


function EnvStr(Index: LongInt): String;
begin
  EnvStr:='';
end;



function GetEnv(envvar : String): String;
var
  BufArr : array[0..255] of char;
  StrBuffer: array of char;
  Temp : Longint;
begin
  if UpCase(EnvVar) = 'PATH' then
  begin
    if StrOfpaths = '' then
      StrOfPaths := GetPathString;
    GetEnv := StrOfPaths;
  end else
  begin
    SetLength(StrBuffer, Length(EnvVar) + 1);
    Move(Envvar[1], StrBuffer[0], Length(EnvVar));
    StrBuffer[Length(EnvVar)] := #0;
    temp := GetVar(PChar(@Strbuffer[0]), BufArr, 255, $100);
    if temp = -1 then
      GetEnv := ''
    else
      GetEnv := StrPas(BufArr);
   end;
end;


procedure AddDevice(Str: String);
begin
  Inc(NumberOfDevices);
  DeviceIDs[NumberOfDevices] := NumberOfDevices;
  DeviceNames[NumberOfDevices] := Str;
end;

function MakeDeviceName(Str: PChar): string;
var
  Temp: string;
begin
  Temp := '';
  if Assigned(Str) then
  begin
    Temp := StrPas(Str);
    Temp := Temp + ':';
  end;
  MakeDeviceName := Temp;
end;

function IsInDeviceList(Str : string): Boolean;
var
  i : Integer;
begin
  IsInDeviceList := False;
  for i := Low(Not_To_Use_Devs) to High(Not_To_Use_Devs) do
  begin
    if Str = Not_To_Use_Devs[i] then
    begin
      IsInDeviceList := True;
      Exit;
    end;
  end;
end;

procedure ReadInDevices;
var
  i: LongInt;
  Dl : PDosList;
  Temp: PChar;
  Str: string;
begin
  i := 0;
  Dl := LockDosList(LDF_DEVICES or LDF_READ);
  repeat
     Inc(i);
     Dl := NextDosEntry(Dl, LDF_DEVICES);
     if Dl <> nil then
     begin
       //Temp := PChar(Dl^.dol_Name);
       Temp := BSTR2STRING(Dl^.dol_Name);
       Str := MakeDeviceName(Temp);
       if not IsInDeviceList(Str) then
         AddDevice(str);
     end;
  until Dl = nil;
  UnLockDosList(LDF_DEVICES or LDF_READ);
end;

begin
  DosError := 0;
  NumberOfDevices := 0;
  StrOfPaths := '';
  ReadInDevices;
end.
