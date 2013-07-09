{

    This file is part of the Free Pascal run time library.
    Copyright (c) 2010 by Sven Barth
    member of the Free Pascal development team

    Sysutils unit for NativeNT

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit sysutils;
interface

{$MODE objfpc}
{$MODESWITCH OUT}
{ force ansistrings }
{$H+}

uses
  ndk;

{$DEFINE HAS_SLEEP}
{$DEFINE HAS_CREATEGUID}

type
  TNativeNTFindData = record
    SearchSpec: String;
    NamePos: LongInt;
    Handle: THandle;
    IsDirObj: Boolean;
    SearchAttr: LongInt;
    Context: ULONG;
    LastRes: NTSTATUS;
  end;

{ Include platform independent interface part }
{$i sysutilh.inc}

implementation

  uses
    sysconst, ndkutils;

{$DEFINE FPC_NOGENERICANSIROUTINES}

{ used OS file system APIs use unicodestring }
{$define SYSUTILS_HAS_UNICODESTR_FILEUTIL_IMPL}

{ Include platform independent implementation part }
{$i sysutils.inc}

{****************************************************************************
                              File Functions
****************************************************************************}

function FileOpen(const FileName : UnicodeString; Mode : Integer) : THandle;
const
  AccessMode: array[0..2] of ACCESS_MASK  = (
    GENERIC_READ,
    GENERIC_WRITE,
    GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of ULONG = (
               0,
               0,
               FILE_SHARE_READ,
               FILE_SHARE_WRITE,
               FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE);
var
  ntstr: UNICODE_STRING;
  objattr: OBJECT_ATTRIBUTES;
  iostatus: IO_STATUS_BLOCK;
begin
  UnicodeStrToNtStr(FileName, ntstr);
  InitializeObjectAttributes(objattr, @ntstr, 0, 0, Nil);
  NtCreateFile(@Result, AccessMode[Mode and 3] or NT_SYNCHRONIZE, @objattr,
    @iostatus, Nil, FILE_ATTRIBUTE_NORMAL, ShareMode[(Mode and $F0) shr 4],
    FILE_OPEN, FILE_NON_DIRECTORY_FILE or FILE_SYNCHRONOUS_IO_NONALERT, Nil, 0);
  FreeNtStr(ntstr);
end;


function FileCreate(const FileName : UnicodeString) : THandle;
begin
  FileCreate := FileCreate(FileName, fmShareDenyNone, 0);
end;


function FileCreate(const FileName : UnicodeString; Rights: longint) : THandle;
begin
  FileCreate := FileCreate(FileName, fmShareDenyNone, Rights);
end;


function FileCreate(const FileName : UnicodeString; ShareMode : longint; Rights: longint) : THandle;
const
  ShareModeFlags: array[0..4] of ULONG = (
               0,
               0,
               FILE_SHARE_READ,
               FILE_SHARE_WRITE,
               FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE);
var
  ntstr: UNICODE_STRING;
  objattr: OBJECT_ATTRIBUTES;
  iostatus: IO_STATUS_BLOCK;
  res: NTSTATUS;
begin
  UnicodeStrToNtStr(FileName, ntstr);
  InitializeObjectAttributes(objattr, @ntstr, 0, 0, Nil);
  NtCreateFile(@Result, GENERIC_READ or GENERIC_WRITE or NT_SYNCHRONIZE,
    @objattr, @iostatus, Nil, FILE_ATTRIBUTE_NORMAL,
    ShareModeFlags[(ShareMode and $F0) shr 4], FILE_OVERWRITE_IF,
    FILE_NON_DIRECTORY_FILE or FILE_SYNCHRONOUS_IO_NONALERT, Nil, 0);
  FreeNtStr(ntstr);
end;


function FileRead(Handle : THandle; out Buffer; Count : longint) : Longint;
var
  iostatus: IO_STATUS_BLOCK;
  res: NTSTATUS;
begin
  res := NtReadFile(Handle, 0, Nil, Nil, @iostatus, @Buffer, Count, Nil, Nil);

  if res = STATUS_PENDING then begin
    res := NtWaitForSingleObject(Handle, False, Nil);
    if NT_SUCCESS(res) then
      res := iostatus.union1.Status;
  end;

  if NT_SUCCESS(res) then
    Result := LongInt(iostatus.Information)
  else
    Result := -1;
end;


function FileWrite(Handle : THandle; const Buffer; Count : Longint) : Longint;
var
  iostatus: IO_STATUS_BLOCK;
  res: NTSTATUS;
begin
  res := NtWriteFile(Handle, 0, Nil, Nil, @iostatus, @Buffer, Count, Nil,
           Nil);

  if res = STATUS_PENDING then begin
    res := NtWaitForSingleObject(Handle, False, Nil);
    if NT_SUCCESS(res) then
      res := iostatus.union1.Status;
  end;

  if NT_SUCCESS(res) then
    Result := LongInt(iostatus.Information)
  else
    Result := -1;
end;


function FileSeek(Handle : THandle;FOffset,Origin : Longint) : Longint;
begin
  Result := longint(FileSeek(Handle, Int64(FOffset), Origin));
end;


function FileSeek(Handle : THandle; FOffset: Int64; Origin: Longint) : Int64;
const
  ErrorCode = $FFFFFFFFFFFFFFFF;
var
  position: FILE_POSITION_INFORMATION;
  standard: FILE_STANDARD_INFORMATION;
  iostatus: IO_STATUS_BLOCK;
  res: NTSTATUS;
begin
  { determine the new position }
  case Origin of
    fsFromBeginning:
      position.CurrentByteOffset.QuadPart := FOffset;
    fsFromCurrent: begin
      res := NtQueryInformationFile(Handle, @iostatus, @position,
               SizeOf(FILE_POSITION_INFORMATION), FilePositionInformation);
      if res < 0 then begin
        Result := ErrorCode;
        Exit;
      end;
      position.CurrentByteOffset.QuadPart :=
        position.CurrentByteOffset.QuadPart + FOffset;
    end;
    fsFromEnd: begin
      res := NtQueryInformationFile(Handle, @iostatus, @standard,
               SizeOf(FILE_STANDARD_INFORMATION), FileStandardInformation);
      if res < 0 then begin
        Result := ErrorCode;
        Exit;
      end;
      position.CurrentByteOffset.QuadPart := standard.EndOfFile.QuadPart +
                                               FOffset;
    end;
    else begin
      Result := ErrorCode;
      Exit;
    end;
  end;

  { set the new position }
  res := NtSetInformationFile(Handle, @iostatus, @position,
           SizeOf(FILE_POSITION_INFORMATION), FilePositionInformation);
  if res < 0 then
    Result := ErrorCode
  else
    Result := position.CurrentByteOffset.QuadPart;
end;


procedure FileClose(Handle : THandle);
begin
  NtClose(Handle);
end;


function FileTruncate(Handle : THandle;Size: Int64) : boolean;
var
  endoffileinfo: FILE_END_OF_FILE_INFORMATION;
  allocinfo: FILE_ALLOCATION_INFORMATION;
  iostatus: IO_STATUS_BLOCK;
  res: NTSTATUS;
begin
  // based on ReactOS' SetEndOfFile
  endoffileinfo.EndOfFile.QuadPart := Size;
  res := NtSetInformationFile(Handle, @iostatus, @endoffileinfo,
           SizeOf(FILE_END_OF_FILE_INFORMATION), FileEndOfFileInformation);
  if NT_SUCCESS(res) then begin
    allocinfo.AllocationSize.QuadPart := Size;
    res := NtSetInformationFile(handle, @iostatus, @allocinfo,
             SizeOf(FILE_ALLOCATION_INFORMATION), FileAllocationInformation);
    Result := NT_SUCCESS(res);
  end else
    Result := False;
end;

function NTToDosTime(const NtTime: LARGE_INTEGER): LongInt;
var
  userdata: PKUSER_SHARED_DATA;
  local, bias: LARGE_INTEGER;
  fields: TIME_FIELDS;
  zs: LongInt;
begin
  userdata := SharedUserData;
  repeat
    bias.u.HighPart := userdata^.TimeZoneBias.High1Time;
    bias.u.LowPart := userdata^.TimeZoneBias.LowPart;
  until bias.u.HighPart = userdata^.TimeZoneBias.High2Time;

  local.QuadPart := NtTime.QuadPart - bias.QuadPart;

  RtlTimeToTimeFields(@local, @fields);

  { from objpas\datutil.inc\DateTimeToDosDateTime }
  Result := - 1980;
  Result := Result + fields.Year and 127;
  Result := Result shl 4;
  Result := Result + fields.Month;
  Result := Result shl 5;
  Result := Result + fields.Day;
  Result := Result shl 16;
  zs := fields.Hour;
  zs := zs shl 6;
  zs := zs + fields.Minute;
  zs := zs shl 5;
  zs := zs + fields.Second div 2;
  Result := Result + (zs and $ffff);
end;

function DosToNtTime(aDTime: LongInt; var aNtTime: LARGE_INTEGER): Boolean;
var
  fields: TIME_FIELDS;
  local, bias: LARGE_INTEGER;
  userdata: PKUSER_SHARED_DATA;
begin
  { from objpas\datutil.inc\DosDateTimeToDateTime }
  fields.Second := (aDTime and 31) * 2;
  aDTime := aDTime shr 5;
  fields.Minute := aDTime and 63;
  aDTime := aDTime shr 6;
  fields.Hour := aDTime and 31;
  aDTime := aDTime shr 5;
  fields.Day := aDTime and 31;
  aDTime := aDTime shr 5;
  fields.Month := aDTime and 15;
  aDTime := aDTime shr 4;
  fields.Year := aDTime + 1980;

  Result := RtlTimeFieldsToTime(@fields, @local);
  if not Result then
    Exit;

  userdata := SharedUserData;
  repeat
    bias.u.HighPart := userdata^.TimeZoneBias.High1Time;
    bias.u.LowPart := userdata^.TimeZoneBias.LowPart;
  until bias.u.HighPart = userdata^.TimeZoneBias.High2Time;

  aNtTime.QuadPart := local.QuadPart + bias.QuadPart;
end;

function FileAge(const FileName: String): Longint;
begin
  { TODO }
  Result := -1;
end;


function FileExists(const FileName: String): Boolean;
var
  ntstr: UNICODE_STRING;
  objattr: OBJECT_ATTRIBUTES;
  res: NTSTATUS;
  iostatus: IO_STATUS_BLOCK;
  h: THandle;
begin
  AnsiStrToNtStr(FileName, ntstr);
  InitializeObjectAttributes(objattr, @ntstr, 0, 0, Nil);
  res := NtOpenFile(@h, FILE_READ_ATTRIBUTES or NT_SYNCHRONIZE, @objattr,
           @iostatus, FILE_SHARE_READ or FILE_SHARE_WRITE,
           FILE_NON_DIRECTORY_FILE or FILE_SYNCHRONOUS_IO_NONALERT);
  Result := NT_SUCCESS(res);

  if Result then
    NtClose(h);
  FreeNtStr(ntstr);
end;


function DirectoryExists(const Directory : String) : Boolean;
var
  ntstr: UNICODE_STRING;
  objattr: OBJECT_ATTRIBUTES;
  res: NTSTATUS;
  iostatus: IO_STATUS_BLOCK;
  h: THandle;
begin
  AnsiStrToNtStr(Directory, ntstr);
  InitializeObjectAttributes(objattr, @ntstr, 0, 0, Nil);

  { first test wether this is a object directory }
  res := NtOpenDirectoryObject(@h, DIRECTORY_QUERY, @objattr);
  if NT_SUCCESS(res) then
    Result := True
  else begin
    if res = STATUS_OBJECT_TYPE_MISMATCH then begin
      { this is a file object! }
      res := NtOpenFile(@h, FILE_READ_ATTRIBUTES or NT_SYNCHRONIZE, @objattr,
               @iostatus, FILE_SHARE_READ or FILE_SHARE_WRITE,
               FILE_DIRECTORY_FILE or FILE_SYNCHRONOUS_IO_NONALERT);
      Result := NT_SUCCESS(res);
    end else
      Result := False;
  end;

  if Result then
    NtClose(h);
  FreeNtStr(ntstr);
end;

{ copied from rtl/unix/sysutils.pp }
Function FNMatch(const Pattern,Name:string):Boolean;
Var
  LenPat,LenName : longint;

  Function DoFNMatch(i,j:longint):Boolean;
  Var
    Found : boolean;
  Begin
  Found:=true;
  While Found and (i<=LenPat) Do
   Begin
     Case Pattern[i] of
      '?' : Found:=(j<=LenName);
      '*' : Begin
            {find the next character in pattern, different of ? and *}
              while Found do
                begin
                inc(i);
                if i>LenPat then Break;
                case Pattern[i] of
                  '*' : ;
                  '?' : begin
                          if j>LenName then begin DoFNMatch:=false; Exit; end;
                          inc(j);
                        end;
                else
                  Found:=false;
                end;
               end;
              Assert((i>LenPat) or ( (Pattern[i]<>'*') and (Pattern[i]<>'?') ));
            {Now, find in name the character which i points to, if the * or ?
             wasn't the last character in the pattern, else, use up all the
             chars in name}
              Found:=false;
              if (i<=LenPat) then
              begin
                repeat
                  {find a letter (not only first !) which maches pattern[i]}
                  while (j<=LenName) and (name[j]<>pattern[i]) do
                    inc (j);
                  if (j<LenName) then
                  begin
                    if DoFnMatch(i+1,j+1) then
                    begin
                      i:=LenPat;
                      j:=LenName;{we can stop}
                      Found:=true;
                      Break;
                    end else
                      inc(j);{We didn't find one, need to look further}
                  end else
                  if j=LenName then
                  begin
                    Found:=true;
                    Break;
                  end;
                  { This 'until' condition must be j>LenName, not j>=LenName.
                    That's because when we 'need to look further' and
                    j = LenName then loop must not terminate. }
                until (j>LenName);
              end else
              begin
                j:=LenName;{we can stop}
                Found:=true;
              end;
            end;
     else {not a wildcard character in pattern}
       Found:=(j<=LenName) and (pattern[i]=name[j]);
     end;
     inc(i);
     inc(j);
   end;
  DoFnMatch:=Found and (j>LenName);
  end;

Begin {start FNMatch}
  LenPat:=Length(Pattern);
  LenName:=Length(Name);
  FNMatch:=DoFNMatch(1,1);
End;


function FindGetFileInfo(const s: String; var f: TSearchRec): Boolean;
var
  ntstr: UNICODE_STRING;
  objattr: OBJECT_ATTRIBUTES;
  res: NTSTATUS;
  h: THandle;
  iostatus: IO_STATUS_BLOCK;
  attr: LongInt;
  filename: String;
  isfileobj: Boolean;
  buf: array of Byte;
  objinfo: OBJECT_BASIC_INFORMATION;
  fileinfo: FILE_BASIC_INFORMATION;
  time: LongInt;
begin
  AnsiStrToNtStr(s, ntstr);
  InitializeObjectAttributes(objattr, @ntstr, 0, 0, Nil);

  filename := ExtractFileName(s);

  { TODO : handle symlinks }
{  If Assigned(F.FindHandle) and ((((PUnixFindData(f.FindHandle)^.searchattr)) and faSymlink) > 0) then
    FindGetFileInfo:=(fplstat(pointer(s),st)=0)
  else
    FindGetFileInfo:=(fpstat(pointer(s),st)=0);}

  attr := 0;
  Result := False;

  if (faDirectory and f.FindData.SearchAttr <> 0) and
      ((filename = '.') or (filename = '..')) then begin
    attr := faDirectory;
    res := STATUS_SUCCESS;
  end else
    res := STATUS_INVALID_PARAMETER;

  isfileobj := False;

  if not NT_SUCCESS(res) then begin
    { first check whether it's a directory }
    res := NtOpenDirectoryObject(@h, DIRECTORY_QUERY, @objattr);
    if not NT_SUCCESS(res) then
      if res = STATUS_OBJECT_TYPE_MISMATCH then begin
        res := NtOpenFile(@h, FILE_READ_ATTRIBUTES or NT_SYNCHRONIZE, @objattr,
                 @iostatus, FILE_SHARE_READ or FILE_SHARE_WRITE,
                 FILE_DIRECTORY_FILE or FILE_SYNCHRONOUS_IO_NONALERT);
        isfileobj := NT_SUCCESS(res);
      end;

    if NT_SUCCESS(res) then
      attr := faDirectory;
  end;

  if not NT_SUCCESS(res) then begin
    { first try whether we have a file object }
    res := NtOpenFile(@h, FILE_READ_ATTRIBUTES or NT_SYNCHRONIZE, @objattr,
             @iostatus, FILE_SHARE_READ or FILE_SHARE_WRITE,
             FILE_NON_DIRECTORY_FILE or FILE_SYNCHRONOUS_IO_NONALERT);
    isfileobj := NT_SUCCESS(res);
    if res = STATUS_OBJECT_TYPE_MISMATCH then begin
      { is this an object? }
      res := NtOpenFile(@h, FILE_READ_ATTRIBUTES or NT_SYNCHRONIZE, @objattr,
               @iostatus, FILE_SHARE_READ or FILE_SHARE_WRITE,
               FILE_SYNCHRONOUS_IO_NONALERT);
      if (res = STATUS_OBJECT_TYPE_MISMATCH)
          and (f.FindData.SearchAttr and faSysFile <> 0) then begin
        { this is some other system file like an event or port, so we can only
          provide it's name }
        res := STATUS_SUCCESS;
        attr := faSysFile;
      end;
    end;
  end;

  FreeNtStr(ntstr);

  if not NT_SUCCESS(res) then
    Exit;

  time := 0;

  if isfileobj then begin
    res := NtQueryInformationFile(h, @iostatus, @fileinfo, SizeOf(fileinfo),
             FileBasicInformation);
    if NT_SUCCESS(res) then begin
      time := NtToDosTime(fileinfo.LastWriteTime);
      { copy file attributes? }
    end;
  end else begin
    res := NtQueryObject(h, ObjectBasicInformation, @objinfo, SizeOf(objinfo),
             Nil);
    if NT_SUCCESS(res) then begin
      time := NtToDosTime(objinfo.CreateTime);
      { what about attributes? }
    end;
  end;

  if (attr and not f.FindData.SearchAttr) = 0 then begin
    f.Name := filename;
    f.Attr := attr;
    f.Size := 0;
{$ifndef FPUNONE}
    if time = 0 then
      { for now we use "Now" as a fall back; ideally this should be the system
        start time }
      f.Time := DateTimeToFileDate(Now)
    else
      f.Time := time;
{$endif}
    Result := True;
  end else
    Result := False;

  NtClose(h);
end;


procedure FindClose(var F: TSearchrec);
begin
  if f.FindData.Handle <> 0 then
    NtClose(f.FindData.Handle);
end;


function FindNext(var Rslt: TSearchRec): LongInt;
{
  re-opens dir if not already in array and calls FindGetFileInfo
}
Var
  DirName  : String;
  FName,
  SName    : string;
  Found,
  Finished : boolean;
  ntstr: UNICODE_STRING;
  objattr: OBJECT_ATTRIBUTES;
  buf: array of WideChar;
  len: LongWord;
  res: NTSTATUS;
  i: LongInt;
  dirinfo: POBJECT_DIRECTORY_INFORMATION;
  filedirinfo: PFILE_DIRECTORY_INFORMATION;
  pc: PChar;
  name: AnsiString;
  iostatus: IO_STATUS_BLOCK;
begin
  { TODO : relative directories }
  Result := -1;
  { SearchSpec='' means that there were no wild cards, so only one file to
    find.
  }
  if Rslt.FindData.SearchSpec = '' then
    Exit;
  { relative directories not supported for now }
  if Rslt.FindData.NamePos = 0 then
    Exit;

  if Rslt.FindData.Handle = 0 then begin
    if Rslt.FindData.NamePos > 1 then
      name := Copy(Rslt.FindData.SearchSpec, 1, Rslt.FindData.NamePos - 1)
    else
    if Rslt.FindData.NamePos = 1 then
      name := Copy(Rslt.FindData.SearchSpec, 1, 1)
    else
      name := Rslt.FindData.SearchSpec;
    AnsiStrToNtStr(name, ntstr);
    InitializeObjectAttributes(objattr, @ntstr, 0, 0, Nil);

    res := NtOpenDirectoryObject(@Rslt.FindData.Handle,
             DIRECTORY_QUERY or DIRECTORY_TRAVERSE, @objattr);
    if not NT_SUCCESS(res) then begin
      if res = STATUS_OBJECT_TYPE_MISMATCH then
        res := NtOpenFile(@Rslt.FindData.Handle,
                 FILE_LIST_DIRECTORY or NT_SYNCHRONIZE, @objattr,
                 @iostatus, FILE_SHARE_READ or FILE_SHARE_WRITE,
                 FILE_DIRECTORY_FILE or FILE_SYNCHRONOUS_IO_NONALERT);
    end else
      Rslt.FindData.IsDirObj := True;

    FreeNTStr(ntstr);

    if not NT_SUCCESS(res) then
      Exit;
  end;
{  if (NTFindData^.SearchType = 0) and
     (NTFindData^.Dirptr = Nil) then
    begin
      If NTFindData^.NamePos = 0 Then
        DirName:='./'
      Else
        DirName:=Copy(NTFindData^.SearchSpec,1,NTFindData^.NamePos);
      NTFindData^.DirPtr := fpopendir(Pchar(pointer(DirName)));
    end;}
  SName := Copy(Rslt.FindData.SearchSpec, Rslt.FindData.NamePos + 1,
             Length(Rslt.FindData.SearchSpec));
  Found := False;
  Finished := not NT_SUCCESS(Rslt.FindData.LastRes)
              or (Rslt.FindData.LastRes = STATUS_NO_MORE_ENTRIES);
  SetLength(buf, 200);
  dirinfo := @buf[0];
  filedirinfo := @buf[0];
  while not Finished do begin
    if Rslt.FindData.IsDirObj then
      res := NtQueryDirectoryObject(Rslt.FindData.Handle, @buf[0],
               Length(buf) * SizeOf(buf[0]), True, False,
               @Rslt.FindData.Context, @len)
    else
      res := NtQueryDirectoryFile(Rslt.FindData.Handle, 0, Nil, Nil, @iostatus,
               @buf[0], Length(buf) * SizeOf(buf[0]), FileDirectoryInformation,
               True, Nil, False);
    if Rslt.FindData.IsDirObj then begin
      Finished := (res = STATUS_NO_MORE_ENTRIES)
                    or (res = STATUS_NO_MORE_FILES)
                    or not NT_SUCCESS(res);
      Rslt.FindData.LastRes := res;
      if dirinfo^.Name.Length > 0 then begin
        SetLength(FName, dirinfo^.Name.Length div 2);
        pc := PChar(FName);
        for i := 0 to dirinfo^.Name.Length div 2 - 1 do begin
          if dirinfo^.Name.Buffer[i] < #256 then
            pc^ := AnsiChar(Byte(dirinfo^.Name.Buffer[i]))
          else
            pc^ := '?';
          pc := pc + 1;
        end;
{$ifdef debug_findnext}
        Write(FName, ' (');
        for i := 0 to dirinfo^.TypeName.Length div 2 - 1 do
          if dirinfo^.TypeName.Buffer[i] < #256 then
            Write(AnsiChar(Byte(dirinfo^.TypeName.Buffer[i])))
          else
            Write('?');
        Writeln(')');
{$endif debug_findnext}
      end else
        FName := '';
    end else begin
      SetLength(FName, filedirinfo^.FileNameLength div 2);
      pc := PChar(FName);
      for i := 0 to filedirinfo^.FileNameLength div 2 - 1 do begin
        if filedirinfo^.FileName[i] < #256 then
          pc^ := AnsiChar(Byte(filedirinfo^.FileName[i]))
        else
          pc^ := '?';
        pc := pc + 1;
      end;
    end;
    if FName = '' then
      Finished := True
    else begin
      if FNMatch(SName, FName) then begin
        Found := FindGetFileInfo(Copy(Rslt.FindData.SearchSpec, 1,
                   Rslt.FindData.NamePos) + FName, Rslt);
        if Found then begin
          Result := 0;
          Exit;
        end;
      end;
    end;
  end;
end;


function FindFirst(const Path: String; Attr: Longint; out Rslt: TSearchRec): Longint;
{
  opens dir and calls FindNext if needed.
}
Begin
  Result := -1;
  FillChar(Rslt, SizeOf(Rslt), 0);
  if Path = '' then
    Exit;
  Rslt.FindData.SearchAttr := Attr;
  {Wildcards?}
  if (Pos('?', Path) = 0) and (Pos('*', Path) = 0) then begin
    if FindGetFileInfo(Path, Rslt) then
      Result := 0;
  end else begin
    {Create Info}
    Rslt.FindData.SearchSpec := Path;
    Rslt.FindData.NamePos := Length(Rslt.FindData.SearchSpec);
    while (Rslt.FindData.NamePos > 0)
        and (Rslt.FindData.SearchSpec[Rslt.FindData.NamePos] <> DirectorySeparator)
        do
      Dec(Rslt.FindData.NamePos);
    Result := FindNext(Rslt);
  end;
  if Result <> 0 then
    FindClose(Rslt);
end;


function FileGetDate(Handle: THandle): Longint;
var
  res: NTSTATUS;
  basic: FILE_BASIC_INFORMATION;
  iostatus: IO_STATUS_BLOCK;
begin
  res := NtQueryInformationFile(Handle, @iostatus, @basic,
           SizeOf(FILE_BASIC_INFORMATION), FileBasicInformation);
  if NT_SUCCESS(res) then
    Result := NtToDosTime(basic.LastWriteTime)
  else
    Result := -1;
end;


function FileSetDate(Handle: THandle;Age: Longint): Longint;
var
  res: NTSTATUS;
  basic: FILE_BASIC_INFORMATION;
  iostatus: IO_STATUS_BLOCK;
begin
  res := NtQueryInformationFile(Handle, @iostatus, @basic,
           SizeOf(FILE_BASIC_INFORMATION), FileBasicInformation);
  if NT_SUCCESS(res) then begin
    if not DosToNtTime(Age, basic.LastWriteTime) then begin
      Result := -1;
      Exit;
    end;

    res := NtSetInformationFile(Handle, @iostatus, @basic,
             SizeOf(FILE_BASIC_INFORMATION), FileBasicInformation);
    if NT_SUCCESS(res) then
      Result := 0
    else
      Result := res;
  end else
    Result := res;
end;


function FileGetAttr(const FileName: String): Longint;
var
  objattr: OBJECT_ATTRIBUTES;
  info: FILE_NETWORK_OPEN_INFORMATION;
  res: NTSTATUS;
  ntstr: UNICODE_STRING;
begin
  AnsiStrToNtStr(FileName, ntstr);
  InitializeObjectAttributes(objattr, @ntstr, 0, 0, Nil);

  res := NtQueryFullAttributesFile(@objattr, @info);
  if NT_SUCCESS(res) then
    Result := info.FileAttributes
  else
    Result := 0;

  FreeNtStr(ntstr);
end;


function FileSetAttr(const Filename: String; Attr: LongInt): Longint;
var
  h: THandle;
  objattr: OBJECT_ATTRIBUTES;
  ntstr: UNICODE_STRING;
  basic: FILE_BASIC_INFORMATION;
  res: NTSTATUS;
  iostatus: IO_STATUS_BLOCK;
begin
  AnsiStrToNtStr(Filename, ntstr);
  InitializeObjectAttributes(objattr, @ntstr, 0, 0, Nil);
  res := NtOpenFile(@h,
           NT_SYNCHRONIZE or FILE_READ_ATTRIBUTES or FILE_WRITE_ATTRIBUTES,
           @objattr, @iostatus,
           FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE,
           FILE_SYNCHRONOUS_IO_NONALERT);

  FreeNtStr(ntstr);

  if NT_SUCCESS(res) then begin
    res := NtQueryInformationFile(h, @iostatus, @basic,
             SizeOf(FILE_BASIC_INFORMATION), FileBasicInformation);

    if NT_SUCCESS(res) then begin
      basic.FileAttributes := Attr;
      Result := NtSetInformationFile(h, @iostatus, @basic,
                  SizeOf(FILE_BASIC_INFORMATION), FileBasicInformation);
    end;

    NtClose(h);
  end else
    Result := res;
end;


function DeleteFile(const FileName: String): Boolean;
var
  h: THandle;
  objattr: OBJECT_ATTRIBUTES;
  ntstr: UNICODE_STRING;
  dispinfo: FILE_DISPOSITION_INFORMATION;
  res: NTSTATUS;
  iostatus: IO_STATUS_BLOCK;
begin
  AnsiStrToNtStr(Filename, ntstr);
  InitializeObjectAttributes(objattr, @ntstr, 0, 0, Nil);
  res := NtOpenFile(@h, NT_DELETE, @objattr, @iostatus,
           FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE,
           FILE_NON_DIRECTORY_FILE);

  FreeNtStr(ntstr);

  if NT_SUCCESS(res) then begin
    dispinfo.DeleteFile := True;

    res := NtSetInformationFile(h, @iostatus, @dispinfo,
             SizeOf(FILE_DISPOSITION_INFORMATION), FileDispositionInformation);

    Result := NT_SUCCESS(res);

    NtClose(h);
  end else
    Result := False;
end;


function RenameFile(const OldName, NewName: String): Boolean;
var
  h: THandle;
  objattr: OBJECT_ATTRIBUTES;
  iostatus: IO_STATUS_BLOCK;
  dest, src: UNICODE_STRING;
  renameinfo: PFILE_RENAME_INFORMATION;
  res: LongInt;
begin
  { check whether the destination exists first }
  AnsiStrToNtStr(NewName, dest);
  InitializeObjectAttributes(objattr, @dest, 0, 0, Nil);

  res := NtCreateFile(@h, 0, @objattr, @iostatus, Nil, 0,
           FILE_SHARE_READ or FILE_SHARE_WRITE, FILE_OPEN,
           FILE_NON_DIRECTORY_FILE, Nil, 0);
  if NT_SUCCESS(res) then begin
    { destination already exists => error }
    NtClose(h);
    Result := False;
  end else begin
    AnsiStrToNtStr(OldName, src);
    InitializeObjectAttributes(objattr, @src, 0, 0, Nil);

    res := NtCreateFile(@h,
             GENERIC_ALL or NT_SYNCHRONIZE or FILE_READ_ATTRIBUTES,
             @objattr, @iostatus, Nil, 0, FILE_SHARE_READ or FILE_SHARE_WRITE,
             FILE_OPEN, FILE_OPEN_FOR_BACKUP_INTENT or FILE_OPEN_REMOTE_INSTANCE
             or FILE_NON_DIRECTORY_FILE or FILE_SYNCHRONOUS_IO_NONALERT, Nil,
             0);

    if NT_SUCCESS(res) then begin
      renameinfo := GetMem(SizeOf(FILE_RENAME_INFORMATION) + dest.Length);
      with renameinfo^ do begin
        ReplaceIfExists := False;
        RootDirectory := 0;
        FileNameLength := dest.Length;
        Move(dest.Buffer^, renameinfo^.FileName, dest.Length);
      end;

      res := NtSetInformationFile(h, @iostatus, renameinfo,
               SizeOf(FILE_RENAME_INFORMATION) + dest.Length,
               FileRenameInformation);
      if not NT_SUCCESS(res) then begin
        { this could happen if src and destination reside on different drives,
          so we need to copy the file manually }
        {$message warning 'RenameFile: Implement file copy!'}
        Result := False;
      end else
        Result := True;

      NtClose(h);
    end else
      Result := False;

    FreeNtStr(src);
  end;

  FreeNtStr(dest);
end;


{****************************************************************************
                              Disk Functions
****************************************************************************}

function diskfree(drive: byte): int64;
begin
  { here the mount manager needs to be queried }
  Result := -1;
end;


function disksize(drive: byte): int64;
begin
  { here the mount manager needs to be queried }
  Result := -1;
end;


function GetCurrentDir: String;
begin
  GetDir(0, result);
end;


function SetCurrentDir(const NewDir: String): Boolean;
begin
{$I-}
  ChDir(NewDir);
{$I+}
  Result := IOResult = 0;
end;


function CreateDir(const NewDir: String): Boolean;
begin
{$I-}
  MkDir(NewDir);
{$I+}
  Result := IOResult = 0;
end;


function RemoveDir(const Dir: String): Boolean;
begin
{$I-}
  RmDir(Dir);
{$I+}
  Result := IOResult = 0;
end;


{****************************************************************************
                              Time Functions
****************************************************************************}


procedure GetLocalTime(var SystemTime: TSystemTime);
var
  bias, syst: LARGE_INTEGER;
  fields: TIME_FIELDS;
  userdata: PKUSER_SHARED_DATA;
begin
  // get UTC time
  userdata := SharedUserData;
  repeat
    syst.u.HighPart := userdata^.SystemTime.High1Time;
    syst.u.LowPart := userdata^.SystemTime.LowPart;
  until syst.u.HighPart = userdata^.SystemTime.High2Time;

  // adjust to local time
  repeat
    bias.u.HighPart := userdata^.TimeZoneBias.High1Time;
    bias.u.LowPart := userdata^.TimeZoneBias.LowPart;
  until bias.u.HighPart = userdata^.TimeZoneBias.High2Time;
  syst.QuadPart := syst.QuadPart - bias.QuadPart;

  RtlTimeToTimeFields(@syst, @fields);

  SystemTime.Year := fields.Year;
  SystemTime.Month := fields.Month;
  SystemTime.Day := fields.Day;
  SystemTime.Hour := fields.Hour;
  SystemTime.Minute := fields.Minute;
  SystemTime.Second := fields.Second;
  SystemTime.Millisecond := fields.MilliSeconds;
end;


{****************************************************************************
                              Misc Functions
****************************************************************************}

procedure sysbeep;
begin
  { empty }
end;

procedure InitInternational;
begin
  InitInternationalGeneric;
end;


{****************************************************************************
                           Target Dependent
****************************************************************************}

function SysErrorMessage(ErrorCode: Integer): String;
begin
  Result := 'NT error code: 0x' + IntToHex(ErrorCode, 8);
end;

{****************************************************************************
                              Initialization code
****************************************************************************}

function wstrlen(p: PWideChar): SizeInt; external name 'FPC_PWIDECHAR_LENGTH';

function GetEnvironmentVariable(const EnvVar: String): String;
var
   s : string;
   i : longint;
   hp: pwidechar;
   len: sizeint;
begin
   { TODO : test once I know how to execute processes }
   Result:='';
   hp:=PPEB(CurrentPEB)^.ProcessParameters^.Environment;
   while hp^<>#0 do
     begin
        len:=UnicodeToUTF8(Nil, hp, 0);
        SetLength(s,len);
        UnicodeToUTF8(PChar(s), hp, len);
        //s:=strpas(hp);
        i:=pos('=',s);
        if uppercase(copy(s,1,i-1))=upcase(envvar) then
          begin
             Result:=copy(s,i+1,length(s)-i);
             break;
          end;
        { next string entry}
        hp:=hp+wstrlen(hp)+1;
     end;
end;

function GetEnvironmentVariableCount: Integer;
var
  hp : pwidechar;
begin
  Result:=0;
  hp:=PPEB(CurrentPEB)^.ProcessParameters^.Environment;
  If (Hp<>Nil) then
    while hp^<>#0 do
      begin
      Inc(Result);
      hp:=hp+wstrlen(hp)+1;
      end;
end;

function GetEnvironmentString(Index: Integer): String;
var
  hp : pwidechar;
  len: sizeint;
begin
  Result:='';
  hp:=PPEB(CurrentPEB)^.ProcessParameters^.Environment;
  If (Hp<>Nil) then
    begin
    while (hp^<>#0) and (Index>1) do
      begin
      Dec(Index);
      hp:=hp+wstrlen(hp)+1;
      end;
    If (hp^<>#0) then
      begin
        len:=UnicodeToUTF8(Nil, hp, 0);
        SetLength(Result, len);
        UnicodeToUTF8(PChar(Result), hp, len);
      end;
    end;
end;


function ExecuteProcess(const Path: AnsiString; const ComLine: AnsiString;
  Flags: TExecuteFlags = []): Integer;
begin
  { TODO : implement }
  Result := 0;
end;

function ExecuteProcess(const Path: AnsiString;
  const ComLine: Array of AnsiString; Flags:TExecuteFlags = []): Integer;
var
  CommandLine: AnsiString;
  I: integer;
begin
  Commandline := '';
  for I := 0 to High (ComLine) do
   if Pos (' ', ComLine [I]) <> 0 then
    CommandLine := CommandLine + ' ' + '"' + ComLine [I] + '"'
   else
    CommandLine := CommandLine + ' ' + Comline [I];
  ExecuteProcess := ExecuteProcess (Path, CommandLine,Flags);
end;

procedure Sleep(Milliseconds: Cardinal);
const
  DelayFactor = 10000;
var
  interval: LARGE_INTEGER;
begin
  interval.QuadPart := - Milliseconds * DelayFactor;
  NtDelayExecution(False, @interval);
end;

{****************************************************************************
                              Initialization code
****************************************************************************}

initialization
  InitExceptions;       { Initialize exceptions. OS independent }
  InitInternational;    { Initialize internationalization settings }
  OnBeep := @SysBeep;
finalization
  DoneExceptions;
end.
