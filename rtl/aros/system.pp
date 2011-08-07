{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2004-2006 by Karoly Balogh
    
    AROS conversation
    Copyright (c) 2011 by Marcus Sackrow

    System unit for AROS

    Uses parts of the Free Pascal 1.0.x for Commodore Amiga/68k port
    by Carl Eric Codere and Nils Sjoholm

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit System;

interface

{$define FPC_IS_SYSTEM}

{$I systemh.inc}

const
  LineEnding = #10;
  LFNSupport = True;
  DirectorySeparator = '/';
  DriveSeparator = ':';
  ExtensionSeparator = '.';
  PathSeparator = ';';
  AllowDirectorySeparators : set of char = ['\','/'];
  AllowDriveSeparators : set of char = [':'];
  maxExitCode = 255;
  MaxPathLen = 256;
  AllFilesMask = '*';

const
  UnusedHandle    : THandle = 0;
  StdInputHandle  : THandle = 0;
  StdOutputHandle : THandle = 0;
  StdErrorHandle  : THandle = 0;

  FileNameCaseSensitive : Boolean = False;
  CtrlZMarksEOF: Boolean = false; (* #26 not considered as end of file *)

  sLineBreak = LineEnding;
  DefaultTextLineBreakStyle : TTextLineBreakStyle = tlbsLF;

  BreakOn : Boolean = True;


var
  AOS_ExecBase   : Pointer; external name '_ExecBase';
  AOS_DOSBase    : Pointer;
  AOS_UtilityBase: Pointer;

  AOS_heapPool : Pointer; { pointer for the OS pool for growing the heap }
  AOS_origDir  : LongInt; { original directory on startup }
  AOS_wbMsg    : Pointer;
  AOS_ConName  : PChar ='CON:10/30/620/100/FPC Console Output/AUTO/CLOSE/WAIT';
  AOS_ConHandle: THandle;

  argc: LongInt;
  argv: PPChar;
  envp: PPChar;
  killed : Boolean = False;

function GetLibAdress(Base: Pointer; Offset: LongInt): Pointer;

implementation

{$I system.inc}

{*****************************************************************************
                       Misc. System Dependent Functions
*****************************************************************************}

procedure haltproc(e:longint);stdcall;external name '_haltproc';

procedure System_exit;
var
  a: LongInt;
begin
  if Killed then
    Exit;
  Killed := True;
  { Closing opened files }
  CloseList(AOS_fileList);
  { Changing back to original directory if changed }
  if AOS_OrigDir <> 0 then begin
    CurrentDir(AOS_origDir);
  end;
  if AOS_UtilityBase <> nil then
    CloseLibrary(AOS_UtilityBase);
  if AOS_heapPool <> nil then
    DeletePool(AOS_heapPool);
  AOS_UtilityBase := nil;
  AOS_HeapPool := nil;
  // call Exit
  DosExit(ExitCode);
  //
  if AOS_DOSBase<>nil then
    CloseLibrary(AOS_DOSBase);
  AOS_DOSBase := nil;
  //
  HaltProc(ExitCode);
end;

{ Generates correct argument array on startup }
procedure GenerateArgs;
var
  ArgVLen: LongInt;

  procedure AllocArg(Idx, Len: LongInt);
  var
    i, OldArgVLen : LongInt;
  begin
    if Idx >= ArgVLen then
    begin
      OldArgVLen := ArgVLen;
      ArgVLen := (Idx + 8) and (not 7);
      SysReAllocMem(Argv, Argvlen * SizeOf(Pointer));
      for i := OldArgVLen to ArgVLen - 1 do
        ArgV[i]:=nil;
    end;
    ArgV[Idx] := SysAllocMem(Succ(Len));
  end;

var
  Count: Word;
  Start: Word;
  LocalIndex: Word;
  P : PChar;
  Temp : string;
  InQuotes: boolean;
begin
  P := GetArgStr;
  ArgVLen := 0;

  { Set argv[0] }
  Temp := ParamStr(0);
  AllocArg(0, Length(Temp));
  Move(Temp[1], Argv[0]^, Length(Temp));
  Argv[0][Length(Temp)] := #0;

  { check if we're started from Ambient }
  if AOS_wbMsg <> nil then
  begin
    ArgC := 0;
    Exit;
  end;
  InQuotes := False;
  { Handle the other args }
  Count := 0;
  { first index is one }
  LocalIndex := 1;
  while (P[Count] <> #0) do
  begin
    while (p[count]=' ') or (p[count]=#9) or (p[count]=LineEnding) do
      Inc(count);
    if p[count] = '"' then
    begin
      inQuotes := True;
      Inc(Count);
    end;
    start := count;
    if inQuotes then
    begin
      while (p[count]<>#0) and (p[count]<>'"') and (p[count]<>LineEnding) do
      begin
        Inc(Count) 
      end;    
    end else
    begin
      while (p[count]<>#0) and (p[count]<>' ') and (p[count]<>#9) and (p[count]<>LineEnding) do
        inc(count);
    end;
    if (count-start>0) then
    begin
      allocarg(localindex,count-start);
      move(p[start],argv[localindex]^,count-start);
      argv[localindex][count-start]:=#0;
      if inQuotes and (argv[localindex][(count-start) - 1] = '"') then
        argv[localindex][(count-start)-1] := #0;
      inc(localindex);    
    end;
    inQuotes := False; 
  end;
  argc:=localindex;
end;

function GetProgDir: String;
var
  s1     : String;
  alock  : LongInt;
  counter: Byte;
begin
  GetProgDir:='';
  FillChar(s1,255,#0);
  { GetLock of program directory }

  alock:=GetProgramDir;
  if alock<>0 then begin
    if NameFromLock(alock,@s1[1],255) then begin
      counter:=1;
      while (s1[counter]<>#0) and (counter<>0) do Inc(counter);
      s1[0]:=Char(counter-1);
      GetProgDir:=s1;
    end;
  end;
end;

function GetProgramName: String;
{ Returns ONLY the program name }
var
  s1     : String;
  counter: Byte;
begin
  GetProgramName:='';
  FillChar(s1,255,#0);

  if GetProgramName(@s1[1],255) then begin
    { now check out and assign the length of the string }
    counter := 1;
    while (s1[counter]<>#0) and (counter<>0) do Inc(counter);
    s1[0]:=Char(counter-1);

    { now remove any component path which should not be there }
    for counter:=length(s1) downto 1 do
      if (s1[counter] = '/') or (s1[counter] = ':') then break;
    { readjust counterv to point to character }
    if counter<>1 then Inc(counter);

    GetProgramName:=copy(s1,counter,length(s1));
  end;
end;


{*****************************************************************************
                             ParamStr/Randomize
*****************************************************************************}

{ number of args }
function paramcount : longint;
begin
  if AOS_wbMsg<>nil then
    paramcount:=0
  else
    paramcount:=argc-1;
end;

{ argument number l }
function paramstr(l : longint) : string;
var
  s1: String;
begin
  paramstr:='';
  if AOS_wbMsg<>nil then exit;

  if l=0 then begin
    s1:=GetProgDir;
    if s1[length(s1)]=':' then paramstr:=s1+GetProgramName
                          else paramstr:=s1+'/'+GetProgramName;
  end else begin
    if (l>0) and (l+1<=argc) then paramstr:=strpas(argv[l]);
  end;
end;

{ set randseed to a new pseudo random value }
procedure Randomize;
var
  tmpTime: TDateStamp;
begin
  DateStamp(@tmpTime);
  randseed := tmpTime.ds_tick;
end;




{ AmigaOS specific startup }
procedure SysInitAmigaOS;
var
  self: PProcess;
begin
  self := PProcess(FindTask(nil));
  if self^.pr_CLI = NIL then begin
    { if we're running from Ambient/Workbench, we catch its message }
    WaitPort(@self^.pr_MsgPort);
    AOS_wbMsg:=GetMsg(@self^.pr_MsgPort);
  end;

  AOS_DOSBase := OpenLibrary('dos.library', 0);
  if AOS_DOSBase = nil then
    Halt(1);
  AOS_UtilityBase := OpenLibrary('utility.library', 0);
  if AOS_UtilityBase = nil then
    Halt(1);

  { Creating the memory pool for growing heap }
  AOS_heapPool := CreatePool(MEMF_ANY, growheapsize2, growheapsize1);
  if AOS_heapPool = nil then
    Halt(1);
  
  if AOS_wbMsg = nil then begin
    StdInputHandle := THandle(dosInput);
    StdOutputHandle := THandle(dosOutput);
  end else begin
    AOS_ConHandle := Open(AOS_ConName, MODE_OLDFILE);
    if AOS_ConHandle <> 0 then begin
      StdInputHandle := AOS_ConHandle;
      StdOutputHandle := AOS_ConHandle;
    end else
      Halt(1);
  end;
end;


procedure SysInitStdIO;
begin

  OpenStdIO(Input,fmInput,StdInputHandle);
  OpenStdIO(Output,fmOutput,StdOutputHandle);
  OpenStdIO(StdOut,fmOutput,StdOutputHandle);

  { * AmigaOS doesn't have a separate stderr * }

  StdErrorHandle:=StdOutputHandle;
  //OpenStdIO(StdErr,fmOutput,StdErrorHandle);
  //OpenStdIO(ErrOutput,fmOutput,StdErrorHandle);
end;

function GetProcessID: SizeUInt;
begin
  GetProcessID := SizeUInt(FindTask(NIL));
end;

function CheckInitialStkLen(stklen : SizeUInt) : SizeUInt;
begin
  result := stklen;
end;


begin
  IsConsole := TRUE;
  SysResetFPU;
  if not (IsLibrary) then
    SysInitFPU;
  StackLength := CheckInitialStkLen(InitialStkLen);
  StackBottom := Sptr - StackLength;
{ OS specific startup }
  AOS_wbMsg := nil;
  AOS_origDir := 0;
  AOS_fileList := nil;
  envp := nil;
  SysInitAmigaOS;
{ Set up signals handlers }
  //InstallSignals;
{ Setup heap }
  InitHeap;
  SysInitExceptions;
{ Setup stdin, stdout and stderr }
  SysInitStdIO;
{ Reset IO Error }
  InOutRes:=0;
  { Arguments }
  GenerateArgs;
  InitSystemThreads;
  initvariantmanager;
{$ifdef VER2_2}
  initwidestringmanager;
{$else VER2_2}
  initunicodestringmanager;
{$endif VER2_2}
end.
