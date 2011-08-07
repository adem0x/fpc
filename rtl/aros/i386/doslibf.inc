{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2011 by Marcus Sackrow

    dos.library functions for AROS

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

function Open(name: PChar; accessMode: longint): Cardinal;
type
  TOpen = function(name: PChar; accessMode: longint; Base: Pointer): Cardinal; stdcall;
var
  Call: TOpen;
begin
  Call := TOpen(GetLibAdress(AOS_DOSBase, 5));
  Open := Call(name, accessMode, AOS_DOSBase);
end;

function dosClose(_file: Cardinal): boolean;
type
  TdosClose = function(_file: Cardinal; Base: Pointer): boolean; stdcall;
var
  Call: TdosClose;
begin
  Call := TdosClose(GetLibAdress(AOS_DOSBase, 6));
  dosClose := Call(_file, AOS_DOSBase);
end;

function dosRead(_file: Cardinal; buffer: Pointer; length: longint): longint;
type
  TdosRead = function(_file: Cardinal; buffer: Pointer; length: longint; Base: Pointer): longint; stdcall;
var
  Call: TdosRead;
begin
  Call := TdosRead(GetLibAdress(AOS_DOSBase, 7));
  dosRead := Call(_file, buffer, length, AOS_DOSBase);
end;

function dosWrite(_file: Cardinal; buffer: Pointer; length: longint): longint;
type
  TdosWrite = function(_file: Cardinal; buffer: Pointer; length: longint; Base: Pointer): longint; stdcall;
var
  Call: TdosWrite;
begin
  Call := TdosWrite(GetLibAdress(AOS_DOSBase, 8));
  dosWrite := Call(_file, buffer, length, AOS_DOSBase);
end;

function dosInput: Cardinal;
type
  TdosInput = function(Base: Pointer): Cardinal; stdcall;
var
  Call: TdosInput;
begin
  Call := TdosInput(GetLibAdress(AOS_DOSBase, 9));
  dosInput := Call(AOS_DOSBase);
end;

function dosOutput: Cardinal;
type
  TdosOutput = function(Base: Pointer): Cardinal; stdcall;
var
  Call: TdosOutput;
begin
  Call := TdosOutput(GetLibAdress(AOS_DOSBase, 10));
  dosOutput := Call(AOS_DOSBase);
end;

function dosSeek(_file: longint;position: longint;offset: longint): longint;
type
  TdosSeek = function(_file: longint;position: longint;offset: longint; Base: Pointer): longint; stdcall;
var
  Call: TdosSeek;
begin
  Call := TdosSeek(GetLibAdress(AOS_DOSBase, 11));
  dosSeek := Call(_file, position, offset, AOS_DOSBase);
end;

function dosDeleteFile(name: PChar): boolean;
type
  TdosDeleteFile = function(name: PChar; Base: Pointer): boolean; stdcall;
var
  Call: TdosDeleteFile;
begin
  Call := TdosDeleteFile(GetLibAdress(AOS_DOSBase, 12));
  dosDeleteFile := Call(name, AOS_DOSBase);
end;

function dosRename(oldName: PChar;newName: PChar): boolean;
type
  TdosRename = function(oldName: PChar;newName: PChar; Base: Pointer): boolean; stdcall;
var
  Call: TdosRename;
begin
  Call := TdosRename(GetLibAdress(AOS_DOSBase, 13));
  dosRename := Call(oldname, newname, AOS_DOSBase);
end;

function Lock(name: PChar;_type: longint): longint;
type
  TLock = function(name: PChar;_type: longint; Base: Pointer): longint; stdcall;
var
  Call: TLock;
begin
  Call := TLock(GetLibAdress(AOS_DOSBase, 14));
  Lock := Call(name, _type, AOS_DOSBase);
end;

function UnLock(lock: longint): longint;
type
  TUnLock = function(lock: longint; Base: Pointer): longint; stdcall;
var
  Call: TUnLock;
begin
  Call := TUnLock(GetLibAdress(AOS_DOSBase, 15));
  UnLock := Call(lock, AOS_DOSBase);
end;


function Examine(lock: longint; fileInfoBlock: PFileInfoBlock): boolean;
type
  TExamine = function(lock: longint; fileInfoBlock: PFileInfoBlock; Base: Pointer): boolean; stdcall;
var
  Call: TExamine;
begin
  Call := TExamine(GetLibAdress(AOS_DOSBase, 17));
  Examine := Call(lock, fileInfoBlock, AOS_DOSBase);
end;

function Info(lock: longint; parameterBlock: PInfoData): boolean;
type
  TInfo = function(lock: longint; parameterBlock: PInfoData; Base: Pointer): boolean; stdcall;
var
  Call: TInfo;
begin
  Call := TInfo(GetLibAdress(AOS_DOSBase, 19));
  Info := Call(lock, parameterBlock, AOS_DOSBase);
end;

function dosCreateDir(name: PChar): longint;
type
  TdosCreateDir = function(name: PChar; Base: Pointer): longint; stdcall;
var
  Call: TdosCreateDir;
begin
  Call := TdosCreateDir(GetLibAdress(AOS_DOSBase, 20));
  dosCreateDir := Call(name, AOS_DOSBase);
end;

function CurrentDir(lock: longint): longint;
type
  TCurrentDir = function(lock: longint; Base: Pointer): longint; stdcall;
var
  Call: TCurrentDir;
begin
  Call := TCurrentDir(GetLibAdress(AOS_DOSBase, 21));
  CurrentDir := Call(lock, AOS_DOSBase);
end;

function IoErr: longint;
type
  TIoErr = function(Base: Pointer): longint; stdcall;
var
  Call: TIoErr;
begin
  Call := TIoErr(GetLibAdress(AOS_DOSBase, 22));
  IoErr := Call(AOS_DOSBase);
end;

procedure dosExit(ErrCode: longint);
type
  TExit = procedure(ErrCode: longint; Base: Pointer); stdcall;
var
  Call: TExit;
begin
  Call := TExit(GetLibAdress(AOS_DOSBase, 24));
  Call(ErrCode, AOS_DOSBase);
end;

function SetProtection(name: PChar; protect: longword): boolean;
type
  TSetProtection = function(name: PChar; protect: longword; Base: Pointer): boolean; stdcall;
var
  Call: TSetProtection;
begin
  Call := TSetProtection(GetLibAdress(AOS_DOSBase, 31));
  SetProtection := Call(name, protect, AOS_DOSBase);
end;

function DateStamp(date: PDateStamp): PDateStamp;
type
  TDateStamp = function(date: PDateStamp; Base: Pointer): PDateStamp; stdcall;
var
  Call: TDateStamp;
begin
  Call := TDateStamp(GetLibAdress(AOS_DOSBase, 32));
  DateStamp := Call(date, AOS_DOSBase);
end;

procedure Delay(ticks: LongWord);
type
  TDelay = procedure(ticks: LongWord; Base: Pointer); stdcall;
var
  Call: TDelay;
begin
  Call := TDelay(GetLibAdress(AOS_DOSBase, 33));
  Call(ticks, AOS_DOSBase);
end;

function SetFileDate(name: PChar; date: PDateStamp): boolean;
type
  TSetFileDate = function(name: PChar; date: PDateStamp; Base: Pointer): boolean; stdcall;
var
  Call: TSetFileDate;
begin
  Call := TSetFileDate(GetLibAdress(AOS_DOSBase, 66));
  SetFileDate := Call(name, date, AOS_DOSBase);
end;

function NameFromLock(lock: longint; buffer: PChar; len: longint): boolean;
type
  TNameFromLock = function(lock: longint; buffer: PChar; len: longint; Base: Pointer): boolean; stdcall;
var
  Call: TNameFromLock;
begin
  Call := TNameFromLock(GetLibAdress(AOS_DOSBase, 67));
  NameFromLock := Call(lock, buffer, len, AOS_DOSBase);
end;

function SetFileSize(fh: longint; pos: longint; mode: longint): longint;
type
  TSetFileSize = function(fh: longint; pos: longint; mode: longint; Base: Pointer): longint; stdcall;
var
  Call: TSetFileSize;
begin
  Call := TSetFileSize(GetLibAdress(AOS_DOSBase, 76));
  SetFileSize := Call(fh, pos, mode, AOS_DOSBase);
end;

function Cli : pCommandLineInterface;
type
  TLocalCall = function(LibBase: Pointer): pCommandLineInterface; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_DOSBase, 82));
  Cli := Call(AOS_DOSBase);
end;

function GetArgStr: PChar;
type
  TGetArgStr = function(Base: Pointer): PChar; stdcall;
var
  Call: TGetArgStr;
begin
  Call := TGetArgStr(GetLibAdress(AOS_DOSBase, 89));
  GetArgStr := Call(AOS_DOSBase);
end;

function GetCurrentDirName(buf: PChar; len: longint): boolean;
type
  TGetCurrentDirName = function(buf: PChar; len: longint; Base: Pointer): boolean; stdcall;
var
  Call: TGetCurrentDirName;
begin
  Call := TGetCurrentDirName(GetLibAdress(AOS_DOSBase, 94));
  GetCurrentDirName := Call(buf, len, AOS_DOSBase);
end;

function GetProgramName(buf: PChar; len: longint): boolean;
type
  TGetProgramName = function(buf: PChar; len: longint; Base: Pointer): boolean; stdcall;
var
  Call: TGetProgramName;
begin
  Call := TGetProgramName(GetLibAdress(AOS_DOSBase, 96));
  GetProgramName := Call(buf, len, AOS_DOSBase);
end;

function GetProgramDir: longint;
type
  TGetProgramDir = function(Base: Pointer): longint; stdcall;
var
  Call: TGetProgramDir;
begin
  Call := TGetProgramDir(GetLibAdress(AOS_DOSBase, 100));
  GetProgramDir := Call(AOS_DOSBase);
end;

function SystemTagList(command: PChar; tags: PTagItem): longint;
type
  TSystemTagList = function(command: PChar; tags: PTagItem; Base: Pointer): longint; stdcall;
var
  Call: TSystemTagList;
begin
  Call := TSystemTagList(GetLibAdress(AOS_DOSBase, 101));
  SystemTagList := Call(command, tags, AOS_DOSBase);
end;

function LockDosList(flags: longword): PDosList;
type
  TLockDosList = function(flags: longword; Base: Pointer): PDosList; stdcall;
var
  Call: TLockDosList;
begin
  Call := TLockDosList(GetLibAdress(AOS_DOSBase, 109));
  LockDosList := Call(flags, AOS_DOSBase);
end;

procedure UnLockDosList(flags: longword);
type
  TUnLockDosList = procedure(flags: longword; Base: Pointer); stdcall;
var
  Call: TUnLockDosList;
begin
  Call := TUnLockDosList(GetLibAdress(AOS_DOSBase, 110));
  Call(flags, AOS_DOSBase);
end;

function NextDosEntry(dlist: PDosList; flags: longword): PDosList;
type
  TNextDosEntry = function(dlist: PDosList; flags: longword; Base: Pointer): PDosList; stdcall;
var
  Call: TNextDosEntry;
begin
  Call := TNextDosEntry(GetLibAdress(AOS_DOSBase, 115));
  NextDosEntry := Call(dlist, flags, AOS_DOSBase);
end;

function MatchFirst(pat: PChar; anchor: PAnchorPath): longint;
type
  TMatchFirst = function(pat: PChar; anchor: PAnchorPath; Base: Pointer): longint; stdcall;
var
  Call: TMatchFirst;
begin
  Call := TMatchFirst(GetLibAdress(AOS_DOSBase, 137));
  MatchFirst := Call(pat, anchor, AOS_DOSBase);
end;

function MatchNext(anchor: PAnchorPath): longint;
type
  TMatchNext = function(anchor: PAnchorPath; Base: Pointer): longint; stdcall;
var
  Call: TMatchNext;
begin
  Call := TMatchNext(GetLibAdress(AOS_DOSBase, 138));
  MatchNext := Call(anchor, AOS_DOSBase);
end;


procedure MatchEnd(anchor: PAnchorPath);
type
  TMatchEnd = procedure(anchor: PAnchorPath; Base: Pointer); stdcall;
var
  Call: TMatchEnd;
begin
  Call := TMatchEnd(GetLibAdress(AOS_DOSBase, 139));
  Call(anchor, AOS_DOSBase);
end;


function GetVar(name: PChar; buffer: PChar; size: longint; flags: longword): longint;
type
  TGetVar = function(name: PChar; buffer: PChar; size: longint; flags: longword; Base: Pointer): longint; stdcall;
var
  Call: TGetVar;
begin
  Call := TGetVar(GetLibAdress(AOS_DOSBase, 151));
  GetVar := Call(name, buffer, size, flags, AOS_DOSBase);
end;


