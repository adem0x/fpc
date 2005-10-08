{

    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2005 by Florian Klaempfl and Yury Sidorov
    members of the Free Pascal development team

    Sysutils unit for wince

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit sysutils;
interface

{$MODE objfpc}
{ force ansistrings }
{$H+}

uses
  dos,
  windows;

{$DEFINE HAS_SLEEP}
{$DEFINE HAS_OSERROR}
{$DEFINE HAS_OSCONFIG}

{ Include platform independent interface part }
{$i sysutilh.inc}

type
  EWinCEError = class(Exception)
  public
    ErrorCode : DWORD;
  end;


Var
  WinCEPlatform : Longint;
  WinCEMajorVersion,
  WinCEMinorVersion,
  WinCEBuildNumber   : dword;
  WinCECSDVersion    : ShortString;   // CSD record is 128 bytes only?


implementation

  uses
    sysconst;

{$DEFINE FPC_NOGENERICANSIROUTINES}
{$define HASEXPANDUNCFILENAME}

{ Include platform independent implementation part }
{$i sysutils.inc}

procedure PWideCharToString(const str: PWideChar; out Result: string; strlen: longint = -1);
var
  len: longint;
begin
  if str^ = #0 then
    Result:=''
  else
  begin
    while True do begin
      if strlen <> -1 then
        len:=(strlen + 1) div SizeOf(WideChar)
      else
        len:=WideToAnsiBuf(str, -1, nil, 0);
      if len > 0 then
      begin
        SetLength(Result, len - 1);
        if (WideToAnsiBuf(str, -1, @Result[1], len) = 0) and (strlen <> -1) then
        begin
          strlen:=-1;
          continue;
        end;
      end
      else
        Result:='';
      break;
    end;
  end;
end;

function ExpandUNCFileName (const filename:string) : string;
{ returns empty string on errors }
var
  s    : widestring;
  size : dword;
  rc   : dword;
  buf  : pwidechar;
begin
  s := ExpandFileName (filename);

  size := max_path*SizeOf(WideChar);
  getmem(buf,size);

  try
    rc := WNetGetUniversalName (pwidechar(s), UNIVERSAL_NAME_INFO_LEVEL, buf, @size);

    if rc=ERROR_MORE_DATA then
      begin
        buf:=reallocmem(buf,size);
        rc := WNetGetUniversalName (pwidechar(s), UNIVERSAL_NAME_INFO_LEVEL, buf, @size);
      end;
    if rc = NO_ERROR then
      Result := PRemoteNameInfo(buf)^.lpUniversalName
    else if rc = ERROR_NOT_CONNECTED then
      Result := filename
    else
      Result := '';
  finally
    freemem(buf);
  end;
end;

{****************************************************************************
                              File Functions
****************************************************************************}

Function FileOpen (Const FileName : string; Mode : Integer) : Longint;
const
  AccessMode: array[0..2] of Cardinal  = (
    GENERIC_READ,
    GENERIC_WRITE,
    GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of Integer = (
               0,
               0,
               FILE_SHARE_READ,
               FILE_SHARE_WRITE,
               FILE_SHARE_READ or FILE_SHARE_WRITE);
var
  fn: PWideChar;
begin
  fn:=StringToPWideChar(FileName);
  result := CreateFile(fn, dword(AccessMode[Mode and 3]),
                       dword(ShareMode[(Mode and $F0) shr 4]), nil, OPEN_EXISTING,
                       FILE_ATTRIBUTE_NORMAL, 0);
  FreeMem(fn);
end;


Function FileCreate (Const FileName : String) : Longint;
var
  fn: PWideChar;
begin
  fn:=StringToPWideChar(FileName);
  Result := CreateFile(fn, GENERIC_READ or GENERIC_WRITE,
                       0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  FreeMem(fn);
end;


Function FileCreate (Const FileName : String; Mode:longint) : SizeInt;
begin
  FileCreate:=FileCreate(FileName);
end;


Function FileRead (Handle : Longint; Var Buffer; Count : longint) : Longint;
Var
  res : dword;
begin
  if ReadFile(Handle, Buffer, Count, res, nil) then
   FileRead:=Res
  else
   FileRead:=-1;
end;


Function FileWrite (Handle : Longint; const Buffer; Count : Longint) : Longint;
Var
  Res : dword;
begin
  if WriteFile(Handle, Buffer, Count, Res, nil) then
   FileWrite:=Res
  else
   FileWrite:=-1;
end;


Function FileSeek (Handle,FOffset,Origin : Longint) : Longint;
begin
  Result := longint(SetFilePointer(Handle, FOffset, nil, Origin));
end;


Function FileSeek (Handle : Longint; FOffset,Origin : Int64) : Int64;
begin
  {$warning need to add 64bit call }
  Result := longint(SetFilePointer(Handle, longint(FOffset), nil, longint(Origin)));
end;


Procedure FileClose (Handle : Longint);
begin
  if Handle<=4 then
   exit;
  CloseHandle(Handle);
end;


Function FileTruncate (Handle,Size: Longint) : boolean;
begin
  Result:=longint(SetFilePointer(handle,Size,nil,FILE_BEGIN))<>-1;
  If Result then
    Result:=SetEndOfFile(handle);
end;


Function DosToWinTime (DTime:longint; out Wtime : TFileTime):longbool;
begin
  DosToWinTime:=False;  //!!! fixme
end;


Function WinToDosTime (Const Wtime : TFileTime; out DTime:longint):longbool;
begin
  WinToDosTime:=False; //!!! fixme
end;


Function FileAge (Const FileName : String): Longint;
var
  Handle: THandle;
  FindData: TWin32FindData;
  fn: PWideChar;
begin
  fn:=StringToPWideChar(FileName);
  Handle := FindFirstFile(fn, FindData);
  FreeMem(fn);
  if Handle <> INVALID_HANDLE_VALUE then
    begin
      Windows.FindClose(Handle);
      if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
        If WinToDosTime(FindData.ftLastWriteTime,Result) then
          exit;
    end;
  Result := -1;
end;


Function FileExists (Const FileName : String) : Boolean;
var
  Handle: THandle;
  FindData: TWin32FindData;
  fn: PWideChar;
begin
  fn:=StringToPWideChar(FileName);
  Handle := FindFirstFile(PWideChar(widestring(FileName)), FindData);
  FreeMem(fn);
  Result:=Handle <> INVALID_HANDLE_VALUE;
  If Result then
    Windows.FindClose(Handle);
end;


Function DirectoryExists (Const Directory : String) : Boolean;
var
  Attr:Dword;
  fn: PWideChar;
begin
  fn:=StringToPWideChar(Directory);
  Attr:=GetFileAttributes(fn);
  FreeMem(fn);
  if Attr <> $ffffffff then
    Result:= (Attr and FILE_ATTRIBUTE_DIRECTORY) > 0
  else
    Result:=False;
end;


Function FindMatch(var f: TSearchRec) : Longint;
begin
  { Find file with correct attribute }
  While (F.FindData.dwFileAttributes and cardinal(F.ExcludeAttr))<>0 do
   begin
     if not FindNextFile (F.FindHandle,F.FindData) then
      begin
        Result:=GetLastError;
        exit;
      end;
   end;
  { Convert some attributes back }
  WinToDosTime(F.FindData.ftLastWriteTime,F.Time);
  f.size:=F.FindData.NFileSizeLow;
  f.attr:=F.FindData.dwFileAttributes;
  PWideCharToString(@F.FindData.cFileName, f.Name);
  Result:=0;
end;


Function FindFirst (Const Path : String; Attr : Longint; out Rslt : TSearchRec) : Longint;
var
  fn: PWideChar;
begin
  fn:=StringToPWideChar(Path);
  Rslt.Name:=Path;
  Rslt.Attr:=attr;
  Rslt.ExcludeAttr:=(not Attr) and ($1e);
                 { $1e = faHidden or faSysFile or faVolumeID or faDirectory }
  { FindFirstFile is a WinCE Call }
  Rslt.FindHandle:=FindFirstFile (fn, Rslt.FindData);
  FreeMem(fn);
  If Rslt.FindHandle=Invalid_Handle_value then
   begin
     Result:=GetLastError;
     exit;
   end;
  { Find file with correct attribute }
  Result:=FindMatch(Rslt);
end;


Function FindNext (Var Rslt : TSearchRec) : Longint;
begin
  if FindNextFile(Rslt.FindHandle, Rslt.FindData) then
    Result := FindMatch(Rslt)
  else
    Result := GetLastError;
end;


Procedure FindClose (Var F : TSearchrec);
begin
   if F.FindHandle <> INVALID_HANDLE_VALUE then
    Windows.FindClose(F.FindHandle);
end;


Function FileGetDate (Handle : Longint) : Longint;
Var
  FT : TFileTime;
begin
  If GetFileTime(Handle,nil,nil,@ft) and
     WinToDosTime(FT,Result) then
    exit;
  Result:=-1;
end;


Function FileSetDate (Handle,Age : Longint) : Longint;
Var
  FT: TFileTime;
begin
  Result := 0;
  if DosToWinTime(Age,FT) and
    SetFileTime(Handle, ft, ft, FT) then
    Exit;
  Result := GetLastError;
end;


Function FileGetAttr (Const FileName : String) : Longint;
var
  fn: PWideChar;
begin
  fn:=StringToPWideChar(FileName);
  Result:=GetFileAttributes(fn);
  FreeMem(fn);
end;


Function FileSetAttr (Const Filename : String; Attr: longint) : Longint;
var
  fn: PWideChar;
begin
  fn:=StringToPWideChar(FileName);
  if not SetFileAttributes(fn, Attr) then
    Result := GetLastError
  else
    Result:=0;
  FreeMem(fn);
end;


Function DeleteFile (Const FileName : String) : Boolean;
var
  fn: PWideChar;
begin
  fn:=StringToPWideChar(FileName);
  DeleteFile:=Windows.DeleteFile(fn);
  FreeMem(fn);
end;


Function RenameFile (Const OldName, NewName : String) : Boolean;
var
  fold, fnew: PWideChar;
begin
  fold:=StringToPWideChar(OldName);
  fnew:=StringToPWideChar(NewName);
  Result := MoveFile(fold, fnew);
  FreeMem(fnew);
  FreeMem(fold);
end;


{****************************************************************************
                              Disk Functions
****************************************************************************}

function diskfree(drive : byte) : int64;
begin
  Result := Dos.diskfree(drive);
end;


function disksize(drive : byte) : int64;
begin
  Result := Dos.disksize(drive);
end;


Function GetCurrentDir : String;
begin
  GetDir(0, result);
end;


Function SetCurrentDir (Const NewDir : String) : Boolean;
begin
  {$I-}
   ChDir(NewDir);
  {$I+}
  result := (IOResult = 0);
end;


Function CreateDir (Const NewDir : String) : Boolean;
begin
  {$I-}
   MkDir(NewDir);
  {$I+}
  result := (IOResult = 0);
end;


Function RemoveDir (Const Dir : String) : Boolean;
begin
  {$I-}
   RmDir(Dir);
  {$I+}
  result := (IOResult = 0);
end;


{****************************************************************************
                              Time Functions
****************************************************************************}


Procedure GetLocalTime(var SystemTime: TSystemTime);
Var
  Syst : Windows.TSystemtime;
begin
  windows.Getlocaltime(@syst);
  SystemTime.year:=syst.wYear;
  SystemTime.month:=syst.wMonth;
  SystemTime.day:=syst.wDay;
  SystemTime.hour:=syst.wHour;
  SystemTime.minute:=syst.wMinute;
  SystemTime.second:=syst.wSecond;
  SystemTime.millisecond:=syst.wMilliSeconds;
end;


{****************************************************************************
                              Misc Functions
****************************************************************************}

procedure Beep;
begin
  MessageBeep(0);
end;


{****************************************************************************
                              Locale Functions
****************************************************************************}

Procedure InitAnsi;
Var
  i : longint;
begin
  {  Fill table entries 0 to 127  }
  for i := 0 to 96 do
    UpperCaseTable[i] := chr(i);
  for i := 97 to 122 do
    UpperCaseTable[i] := chr(i - 32);
  for i := 123 to 191 do
    UpperCaseTable[i] := chr(i);
  Move (CPISO88591UCT,UpperCaseTable[192],SizeOf(CPISO88591UCT));

  for i := 0 to 64 do
    LowerCaseTable[i] := chr(i);
  for i := 65 to 90 do
    LowerCaseTable[i] := chr(i + 32);
  for i := 91 to 191 do
    LowerCaseTable[i] := chr(i);
  Move (CPISO88591LCT,UpperCaseTable[192],SizeOf(CPISO88591UCT));
end;


function GetLocaleStr(LID, LT: Longint; const Def: string): ShortString;
var
  L: Integer;
  Buf: array[0..255] of WideChar;
  s: widestring;
begin
  L := GetLocaleInfo(LID, LT, Buf, SizeOf(Buf) div SizeOf(WideChar));
  if L > 0 then
  begin
    SetString(s, Buf, L - 1);
    Result:=s;
  end
  else
    Result := Def;
end;


function GetLocaleChar(LID, LT: Longint; Def: Char): Char;
var
  Buf: array[0..1] of WideChar;
  Buf2: array[0..1] of Char;
begin
  if GetLocaleInfo(LID, LT, Buf, 2) > 0 then
  begin
    WideToAnsiBuf(Buf, -1, Buf2, SizeOf(Buf2));
    Result := Buf2[0];
  end
  else
    Result := Def;
end;


Function GetLocaleInt(LID,TP,Def: LongInt): LongInt;
Var
  S: String;
  C: Integer;
Begin
  S:=GetLocaleStr(LID,TP,'0');
  Val(S,Result,C);
  If C<>0 Then
    Result:=Def;
End;


procedure GetFormatSettings;
var
  HF  : Shortstring;
  LID : LCID;
  I,Day,DateOrder : longint;
begin
  LID := GetUserDefaultLCID;
  { Date stuff }
  for I := 1 to 12 do
    begin
    ShortMonthNames[I]:=GetLocaleStr(LID,LOCALE_SABBREVMONTHNAME1+I-1,ShortMonthNames[i]);
    LongMonthNames[I]:=GetLocaleStr(LID,LOCALE_SMONTHNAME1+I-1,LongMonthNames[i]);
    end;
  for I := 1 to 7 do
    begin
    Day := (I + 5) mod 7;
    ShortDayNames[I]:=GetLocaleStr(LID,LOCALE_SABBREVDAYNAME1+Day,ShortDayNames[i]);
    LongDayNames[I]:=GetLocaleStr(LID,LOCALE_SDAYNAME1+Day,LongDayNames[i]);
    end;
  DateSeparator := GetLocaleChar(LID, LOCALE_SDATE, '/');
  DateOrder := GetLocaleInt(LID, LOCALE_IDate, 0);
  Case DateOrder Of
     1: Begin
        ShortDateFormat := 'dd/mm/yyyy';
        LongDateFormat := 'dddd, d. mmmm yyyy';
        End;
     2: Begin
        ShortDateFormat := 'yyyy/mm/dd';
        LongDateFormat := 'dddd, yyyy mmmm d.';
        End;
  else
    // Default american settings...
    ShortDateFormat := 'mm/dd/yyyy';
    LongDateFormat := 'dddd, mmmm d. yyyy';
  End;
  { Time stuff }
  TimeSeparator := GetLocaleChar(LID, LOCALE_STIME, ':');
  TimeAMString := GetLocaleStr(LID, LOCALE_S1159, 'AM');
  TimePMString := GetLocaleStr(LID, LOCALE_S2359, 'PM');
  if StrToIntDef(GetLocaleStr(LID, LOCALE_ITLZERO, '0'), 0) = 0 then
    HF:='h'
  else
    HF:='hh';
  // No support for 12 hour stuff at the moment...
  ShortTimeFormat := HF+':nn';
  LongTimeFormat := HF + ':nn:ss';
  { Currency stuff }
  CurrencyString:=GetLocaleStr(LID, LOCALE_SCURRENCY, '');
  CurrencyFormat:=StrToIntDef(GetLocaleStr(LID, LOCALE_ICURRENCY, '0'), 0);
  NegCurrFormat:=StrToIntDef(GetLocaleStr(LID, LOCALE_INEGCURR, '0'), 0);
  { Number stuff }
  ThousandSeparator:=GetLocaleChar(LID, LOCALE_STHOUSAND, ',');
  DecimalSeparator:=GetLocaleChar(LID, LOCALE_SDECIMAL, '.');
  CurrencyDecimals:=StrToIntDef(GetLocaleStr(LID, LOCALE_ICURRDIGITS, '0'), 0);
end;


Procedure InitInternational;
begin
  InitInternationalGeneric;
  SysLocale.MBCS:=GetSystemMetrics(SM_DBCSENABLED)<>0;
  SysLocale.RightToLeft:=GetSystemMetrics(SM_MIDEASTENABLED)<>0;
  InitAnsi;
  GetFormatSettings;
end;


{****************************************************************************
                           Target Dependent
****************************************************************************}

function SysErrorMessage(ErrorCode: Integer): String;
var
  MsgBuffer: PWideChar;
  len: longint;
begin
  len:=FormatMessage(
         FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS,
         nil,
         ErrorCode,
         0,
         @MsgBuffer,                 { This function allocs the memory }
         0,
         nil);
  while (len > 0) and (MsgBuffer[len - 1] <= #32) do
    Dec(len);
  MsgBuffer[len]:=#0;
  PWideCharToString(PWideChar(MsgBuffer), Result);
  LocalFree(HLOCAL(MsgBuffer));
end;

{****************************************************************************
                              Initialization code
****************************************************************************}

// WinCE does not have environment. It can be emulated via registry or file. (YS)

Function GetEnvironmentVariable(Const EnvVar : String) : String;
begin
  Result := ''; //!!! fixme
end;

Function GetEnvironmentVariableCount : Integer;
begin
  Result := 0; //!!! fixme
end;

Function GetEnvironmentString(Index : Integer) : String;
begin
  Result := ''; //!!! fixme
end;


function ExecuteProcess(Const Path: AnsiString; Const ComLine: AnsiString):integer;
var
  PI: TProcessInformation;
  Proc : THandle;
  l    : DWord;
  e : EOSError;

begin
  DosError := 0;
  if not CreateProcess(PWideChar(widestring(Path)), PWideChar(widestring(ComLine)),
                       nil, nil, FALSE, 0, nil, nil, nil, PI) then
    begin
      e:=EOSError.CreateFmt(SExecuteProcessFailed,[Path,GetLastError]);
      e.ErrorCode:=GetLastError;
      raise e;
    end;
  Proc:=PI.hProcess;
  CloseHandle(PI.hThread);
  if WaitForSingleObject(Proc, dword($ffffffff)) <> $ffffffff then
    begin
      GetExitCodeProcess(Proc,l);
      CloseHandle(Proc);
      result:=l;
    end
  else
    begin
      e:=EOSError.CreateFmt(SExecuteProcessFailed,[Path,GetLastError]);
      e.ErrorCode:=GetLastError;
      CloseHandle(Proc);
      raise e;
    end;
end;

function ExecuteProcess(Const Path: AnsiString; Const ComLine: Array of AnsiString):integer;

Var
  CommandLine : AnsiString;
  i : Integer;

Begin
  Commandline:='';
  For i:=0 to high(ComLine) Do
   Commandline:=CommandLine+' '+Comline[i];
  ExecuteProcess:=ExecuteProcess(Path,CommandLine);
End;

Procedure Sleep(Milliseconds : Cardinal);

begin
  Windows.Sleep(MilliSeconds)
end;

Function GetLastOSError : Integer;

begin
  Result:=GetLastError;
end;

{****************************************************************************
                              Initialization code
****************************************************************************}

Procedure LoadVersionInfo;
Var
   versioninfo : TOSVERSIONINFO;
   i          : Integer;

begin
  versioninfo.dwOSVersionInfoSize:=sizeof(versioninfo);
  GetVersionEx(versioninfo);
  WinCEPlatform:=versionInfo.dwPlatformId;
  WinCEMajorVersion:=versionInfo.dwMajorVersion;
  WinCEMinorVersion:=versionInfo.dwMinorVersion;
  WinCEBuildNumber:=versionInfo.dwBuildNumber;
  i:=WideToAnsiBuf(@versioninfo.szCSDVersion, -1, @WinCECSDVersion[1], SizeOf(WinCECSDVersion) - 1);
  if i <> 0 then
    WinCECSDVersion[0]:=chr(i - 1);
end;

Function GetSpecialDir(ID: Integer) : String;

Var
  APath : array[0..MAX_PATH] of WideChar;
begin
  if SHGetSpecialFolderPath(0, APath, ID, True) then
  begin
    PWideCharToString(APath, Result);
    Result:=IncludeTrailingPathDelimiter(Result);
  end
  else
    Result:='';
end;

Function GetAppConfigDir(Global : Boolean) : String;

begin
  If Global then
    Result:=DGetAppConfigDir(Global) // or use windows dir ??
  else
    begin
    Result:=GetSpecialDir(CSIDL_APPDATA)+ApplicationName;
    If (Result='') then
      Result:=DGetAppConfigDir(Global);
    end;
end;

Function GetAppConfigFile(Global : Boolean; SubDir : Boolean) : String;

begin
  if Global then
    begin
    Result:=IncludeTrailingPathDelimiter(DGetAppConfigDir(Global));
    if SubDir then
      Result:=IncludeTrailingPathDelimiter(Result+'Config');
    Result:=Result+ApplicationName+ConfigExtension;
    end
  else
    begin
    Result:=IncludeTrailingPathDelimiter(GetAppConfigDir(False));
    if SubDir then
      Result:=Result+'Config\';
    Result:=Result+ApplicationName+ConfigExtension;
    end;
end;

{****************************************************************************
                    Target Dependent WideString stuff
****************************************************************************}


function WinCECompareWideString(const s1, s2 : WideString) : PtrInt;
begin
  SetLastError(0);
  Result:=CompareString(LOCALE_USER_DEFAULT,0,pwidechar(s1),
    length(s1),pwidechar(s2),length(s2))-2;
  if GetLastError<>0 then
    RaiseLastOSError;
end;


function WinCECompareTextWideString(const s1, s2 : WideString) : PtrInt;
begin
  SetLastError(0);
  Result:=CompareString(LOCALE_USER_DEFAULT,NORM_IGNORECASE,pwidechar(s1),
    length(s1),pwidechar(s2),length(s2))-2;
  if GetLastError<>0 then
    RaiseLastOSError;
end;


function WinCEAnsiUpperCase(const s: string): string;
var
  buf: PWideChar;
  len: longint;
begin
  if s <> '' then
  begin
    buf:=StringToPWideChar(s, @len);
    CharUpperBuff(buf, len);
    PWideCharToString(buf, Result, len);
    FreeMem(buf);
  end
  else
    Result:='';
end;


function WinCEAnsiLowerCase(const s: string): string;
var
  buf: PWideChar;
  len: longint;
begin
  if s <> '' then
  begin
    buf:=StringToPWideChar(s, @len);
    CharLowerBuff(buf, len);
    PWideCharToString(buf, Result, len);
    FreeMem(buf);
  end
  else
    Result:='';
end;


function WinCEAnsiCompareStr(const S1, S2: string): PtrInt;
var
  ws1, ws2: PWideChar;
begin
  ws1:=StringToPWideChar(S1);
  ws2:=StringToPWideChar(S2);
  Result:=CompareString(LOCALE_USER_DEFAULT, 0, ws1, -1, ws2, -1) - 2;
  FreeMem(ws2);
  FreeMem(ws1);
end;


function WinCEAnsiCompareText(const S1, S2: string): PtrInt;
var
  ws1, ws2: PWideChar;
begin
  ws1:=StringToPWideChar(S1);
  ws2:=StringToPWideChar(S2);
  Result:=CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, ws1, -1, ws2, -1) - 2;
  FreeMem(ws2);
  FreeMem(ws1);
end;

function WinCEAnsiStrComp(S1, S2: PChar): PtrInt;
var
  ws1, ws2: PWideChar;
begin
  ws1:=PCharToPWideChar(S1);
  ws2:=PCharToPWideChar(S2);
  Result:=CompareString(LOCALE_USER_DEFAULT, 0, ws1, -1, ws2, -1) - 2;
  FreeMem(ws2);
  FreeMem(ws1);
end;


function WinCEAnsiStrIComp(S1, S2: PChar): PtrInt;
var
  ws1, ws2: PWideChar;
begin
  ws1:=PCharToPWideChar(S1);
  ws2:=PCharToPWideChar(S2);
  Result:=CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, ws1, -1, ws2, -1) - 2;
  FreeMem(ws2);
  FreeMem(ws1);
end;


function WinCEAnsiStrLComp(S1, S2: PChar; MaxLen: PtrUInt): PtrInt;
var
  ws1, ws2: PWideChar;
  len1, len2: longint;
begin
  ws1:=PCharToPWideChar(S1, MaxLen, @len1);
  ws2:=PCharToPWideChar(S2, MaxLen, @len2);
  Result:=CompareString(LOCALE_USER_DEFAULT, 0, ws1, len1, ws2, len2) - 2;
  FreeMem(ws2);
  FreeMem(ws1);
end;


function WinCEAnsiStrLIComp(S1, S2: PChar; MaxLen: PtrUInt): PtrInt;
var
  ws1, ws2: PWideChar;
  len1, len2: longint;
begin
  ws1:=PCharToPWideChar(S1, MaxLen, @len1);
  ws2:=PCharToPWideChar(S2, MaxLen, @len2);
  Result:=CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, ws1, len1, ws2, len2) - 2;
  FreeMem(ws2);
  FreeMem(ws1);
end;


function WinCEAnsiStrLower(Str: PChar): PChar;
var
  buf: PWideChar;
  len: longint;
begin
  buf:=PCharToPWideChar(Str, -1, @len);
  CharLowerBuff(buf, len);
  WideToAnsiBuf(buf, -1, Result, len + 1);
  FreeMem(buf);
end;


function WinCEAnsiStrUpper(Str: PChar): PChar;
var
  buf: PWideChar;
  len: longint;
begin
  buf:=PCharToPWideChar(Str, -1, @len);
  CharUpperBuff(buf, len);
  WideToAnsiBuf(buf, -1, Result, len + 1);
  FreeMem(buf);
end;


{ there is a similiar procedure in the system unit which inits the fields which
  are relevant already for the system unit }
procedure InitWinCEWidestrings;
  begin
    widestringmanager.CompareWideStringProc:=@WinCECompareWideString;
    widestringmanager.CompareTextWideStringProc:=@WinCECompareTextWideString;
    
    widestringmanager.UpperAnsiStringProc:=@WinCEAnsiUpperCase;
    widestringmanager.LowerAnsiStringProc:=@WinCEAnsiLowerCase;
    widestringmanager.CompareStrAnsiStringProc:=@WinCEAnsiCompareStr;
    widestringmanager.CompareTextAnsiStringProc:=@WinCEAnsiCompareText;
    widestringmanager.StrCompAnsiStringProc:=@WinCEAnsiStrComp;
    widestringmanager.StrICompAnsiStringProc:=@WinCEAnsiStrIComp;
    widestringmanager.StrLCompAnsiStringProc:=@WinCEAnsiStrLComp;
    widestringmanager.StrLICompAnsiStringProc:=@WinCEAnsiStrLIComp;
    widestringmanager.StrLowerAnsiStringProc:=@WinCEAnsiStrLower;
    widestringmanager.StrUpperAnsiStringProc:=@WinCEAnsiStrUpper;
  end;



Initialization
  InitWinCEWidestrings;
  InitExceptions;       { Initialize exceptions. OS independent }
  InitInternational;    { Initialize internationalization settings }
  LoadVersionInfo;
  SysConfigDir:='\Windows';

Finalization
  DoneExceptions;

end.
