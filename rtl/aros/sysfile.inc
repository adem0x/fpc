{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2005 by Free Pascal development team

    Low level file functions

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{ Enable this for file handling debug }
{DEFINE MOSFPC_FILEDEBUG}

{*****************************************************************************
                  AROS File-handling Support Functions
*****************************************************************************}

type
  { AmigaOS does not automatically close opened files on exit back to  }
  { the operating system, therefore as a precuation we close all files }
  { manually on exit.                                                  }
  PFileList = ^TFileList;
  TFileList = record { no packed, must be correctly aligned }
    Handle   : THandle;      { Handle to file     }
    FName    : array of Char;
    Next     : PFileList;    { Next file in list  }
    Buffered : Boolean;      { used Buffered I/O? }
  end;

var
  AOS_fileList: PFileList; public name 'AOS_FILELIST'; { List pointer to opened files }

{ Function to be called at program shutdown, to close all opened files }
procedure CloseList(l: PFileList);
var
  TmpNext: PFileList;
  TmpHandle: THandle;
begin
  if l = nil then
    Exit;

  { First, close all tracked files }
  TmpNext := l^.Next;
  while TmpNext <> nil do
  begin
    TmpHandle := TmpNext^.Handle;
    if (TmpHandle <> StdInputHandle) and (TmpHandle <> StdOutputHandle)
       and (TmpHandle <> StdErrorHandle) then
    begin
      DosClose(TmpHandle);
    end;
    TmpNext := TmpNext^.Next;
  end;

  { Next, erase the linked list }
  while l <> nil do
  begin
    TmpNext := l;
    l := l^.Next;
    Dispose(TmpNext);
  end;
end;

{ Function to be called to add a file to the opened file list }
procedure AddToList(var l: PFileList; h: THandle; const AName: PChar); alias: 'ADDTOLIST'; [public];
var
  p: PFileList;
  InList: Boolean;
  LocalName: string;
begin
  InList := False;
  if l <> nil then
  begin
    { if there is a valid filelist, search for the value }
    { in the list to avoid double additions }
    p := l;
    while (p^.Next <> nil) and (not InList) do
      if p^.Next^.Handle = h then
        inList := True
      else
        p := p^.Next;
    p := nil;
  end else
  begin
    { if the list is not yet allocated, allocate it. }
    New(l);
    l^.Next := nil;
  end;

  if not inList then
  begin
    New(p);
    p^.Handle := h;
    localname := AName + #0;
    SetLength(p^.FName, Length(LocalName));
    Move(LocalName[1], p^.FName[0], Length(LocalName));
    p^.Buffered := False;
    p^.Next := l^.Next;
    l^.Next := p;
  end
{$IFDEF MOSFPC_FILEDEBUG}
  else 
    RawDoFmt('FPC_FILE_DEBUG: Error! Trying add filehandle a filehandle twice: $%lx !'+#10,@h,pointer(1),nil);
{$ENDIF}
  ;
end;

{ Function to be called to remove a file from the list }
function RemoveFromList(var l: PFileList; h: THandle): Boolean; alias: 'REMOVEFROMLIST'; [public];
var
  p: PFileList;
  InList: Boolean;
  TmpList: PFileList;
begin
  InList := False;
  if l = nil then
  begin
    RemoveFromList := InList;
    Exit;
  end;

  p := l;
  while (p^.Next <> nil) and (not InList) do
    if p^.Next^.Handle = h then
      InList := True
    else
      p := p^.Next;
  
  if InList then
  begin
    TmpList := p^.Next^.Next;
    Dispose(p^.Next);
    p^.Next := TmpList;
  end
{$IFDEF MOSFPC_FILEDEBUG}
  else 
    RawDoFmt('FPC_FILE_DEBUG: Error! Trying to remove not existing filehandle: $%lx !'+#10,@h,pointer(1),nil);
{$ENDIF}
  ;

  RemoveFromList := inList;
end;

{ Function to check if file is in the list }
function CheckInList(var l: PFileList; h: THandle): pointer; alias: 'CHECKINLIST'; [public];
var
  p: PFileList;
  InList: Pointer;
begin
  InList := nil;
  if l = nil then
  begin
    CheckInList := InList;
    Exit;
  end;

  p := l;
  while (p^.Next <> nil) and (InList = nil) do
    if p^.Next^.Handle = h then
      InList := p^.Next
    else
      p := p^.Next;

{$IFDEF MOSFPC_FILEDEBUG}
  if InList = nil then
    RawDoFmt('FPC_FILE_DEBUG: Warning! Check for not existing filehandle: $%lx !'+#10,@h,pointer(1),nil);
{$ENDIF}

  CheckInList := InList;
end;

function GetNameFromList(var l: PFileList; h: THandle): PChar; alias: 'GETNAMEFROMLIST'; [public];
var
  p: PFileList;
  InList: PChar;
begin
  InList := '';
  if l = nil then
  begin
    GetNameFromList := '';
    Exit;
  end;

  p := l;
  while (p^.Next <> nil) and (InList = '') do
  begin
    if p^.Next^.Handle = h then
    begin
      InList := PChar(@(p^.Next^.FName[0]));
      Break;
    end else
      p := p^.Next;
  end;
  GetNameFromList := inList;
end;


{****************************************************************************
                        Low level File Routines
               All these functions can set InOutRes on errors
****************************************************************************}

{ close a file from the Handle value }
procedure do_close(Handle: THandle);
begin
  if RemoveFromList(AOS_fileList,Handle) then
  begin
    { Do _NOT_ check CTRL_C on Close, because it will conflict
      with System_Exit! }
    if not dosClose(Handle) then
      dosError2InOut(IoErr);
  end;
end;

procedure do_erase(p: PChar);
var
  TmpStr: array[0..255] of Char;
begin
  TmpStr := PathConv(StrPas(p))+#0;
  CheckCTRLC;
  if not dosDeleteFile(@TmpStr) then
    DosError2InOut(IoErr);
end;

procedure do_rename(p1,p2 : PChar);
{ quite stack-effective code, huh? :) damn path conversions... (KB) }
var
  TmpStr1: array[0..255] of Char;
  TmpStr2: array[0..255] of Char;
begin
  TmpStr1 := PathConv(StrPas(p1)) + #0;
  TmpStr2 := PathConv(StrPas(p2)) + #0;
  CheckCTRLC;
  if dosRename(@TmpStr1, @TmpStr2) = 0 then
    DosError2InOut(IoErr);
end;

function do_write(h: THandle; addr: pointer; Len: LongInt) : LongInt;
var
  DosResult: LongInt;
begin
  CheckCTRLC;
  do_write := 0;
  if (Len <= 0) or (h = 0) then
    Exit;

  DosResult := DosWrite(h, addr, Len);
  if DosResult < 0 then
  begin
    DosError2InOut(IoErr);
  end else
  begin
    do_write := DosResult;
  end;
  {$IFDEF MOSFPC_FILEDEBUG}
  if not ((h = StdOutputHandle) or (h = StdInputHandle) or
    (h = StdErrorHandle)) then
  begin
    writeln('## write ',h,' should: ', len, ' is: ', Dosresult);
    //CheckInList(AOS_fileList, h);
  end;
 {$ENDIF}
end;

function do_read(h: THandle; addr: pointer; Len: LongInt) : LongInt;
var
  DosResult: LongInt;
begin
  CheckCTRLC;
  do_read := 0;
  if (Len <= 0) or (h = 0) then
    Exit;

{$IFDEF MOSFPC_FILEDEBUG}
  if not ((h = StdOutputHandle) or (h = StdInputHandle) or
    (h = StdErrorHandle)) then
    CheckInList(AOS_fileList, h);
{$ENDIF}

  DosResult := DosRead(h, addr, Len);
  if DosResult < 0 then
  begin
    DosError2InOut(IoErr);
  end else
  begin
    do_read := DosResult;
  end
end;

function do_filepos(Handle: THandle) : LongInt;
var
  DosResult: LongInt;
begin
  CheckCTRLC;
  do_filepos := -1;
  if CheckInList(AOS_fileList, Handle) <> nil then
  begin
    { Seeking zero from OFFSET_CURRENT to find out where we are }    
    DosResult := DosSeek(Handle, 0, OFFSET_CURRENT);
    if DosResult < 0 then
    begin
      DosError2InOut(IoErr);
    end else
    begin
      do_filepos := DosResult;
    end;
  end;
end;

procedure do_seek(Handle: Thandle; pos: LongInt);
var
  err: Integer;
begin
  CheckCTRLC;
  if CheckInList(AOS_fileList, Handle) <> nil then
  begin
    { Seeking from OFFSET_BEGINNING }  
    if DosSeek(Handle, pos, OFFSET_BEGINNING) < 0 then
    begin
      Err := ioErr;
      DosError2InOut(Err);
    end;
  end;
end;

function do_seekend(Handle: LongInt):LongInt;
var
  DosResult: LongInt;
begin
  CheckCTRLC;
  do_seekend := -1;
  if CheckInList(AOS_fileList, Handle) <> nil then
  begin
    { Seeking to OFFSET_END }
    DosResult := dosSeek(Handle, 0, OFFSET_END);
    if DosResult < 0 then
    begin
      DosError2InOut(IoErr);
    end else
    begin
      do_seekend := DosSeek(Handle, 0, OFFSET_CURRENT);  // get positon
    end;
  end;
end;

function do_filesize(Handle : LongInt) : LongInt;
var
  CurrFilePos: LongInt;
begin
  CheckCTRLC;
  do_filesize := -1;
  if CheckInList(AOS_fileList, Handle) <> nil then
  begin
    CurrFilePos := do_filepos(Handle);
    do_filesize := do_seekend(Handle);
    do_seek(Handle, CurrFilePos);
  end;
end;

{ truncate at a given position }
procedure do_truncate(Handle, pos: LongInt);
begin
  CheckCTRLC;
  if CheckInList(AOS_fileList, Handle) <> nil then
  begin
    { Seeking from OFFSET_BEGINNING }
    if SetFileSize(Handle, pos, OFFSET_BEGINNING) < 0 then
      DosError2InOut(IoErr);
  end;
end;

procedure do_open(var f; p: PChar; flags: LongInt);
{
  filerec and textrec have both Handle and mode as the first items so
  they could use the same routine for opening/creating.
  when (flags and $10)   the file will be append
  when (flags and $100)  the file will be truncate/rewritten
  when (flags and $1000) there is no check for close (needed for textfiles)
}
var
  Handle   : THandle;
  OpenFlags: LongInt;
  TmpStr   : array[0..255] of Char;
begin
  TmpStr:=PathConv(StrPas(p))+#0;
  
  { close first if opened }
  if ((flags and $10000) = 0) then
  begin
    case filerec(f).mode of
      fminput,
      fmoutput,
      fminout: Do_Close(filerec(f).Handle);
      fmclosed: ;
      else
      begin
        InOutRes := 102; {not assigned}
        Exit;
      end;
    end;
  end;

  { reset file Handle }
  filerec(f).Handle := UnusedHandle;

  { convert filemode to filerec modes }
  { READ/WRITE on existing file }
  { RESET/APPEND                }
  OpenFlags := MODE_OLDFILE;
  case (flags and 3) of
    0 : filerec(f).mode := fminput;
    1 : filerec(f).mode := fmoutput;
    2 : filerec(f).mode := fminout;
  end;

  { rewrite (create a new file) }
  if (flags and $1000) <> 0 then
    openflags:=MODE_NEWFILE;

  { empty name is special }
  if p[0] = #0 then
  begin
    case filerec(f).mode of
      fminput:
        filerec(f).Handle := StdInputHandle;
      fmappend,
      fmoutput: begin
        filerec(f).Handle := StdOutputHandle;
        filerec(f).mode := fmOutput; {fool fmappend}
      end;
    end;
    Exit;
  end;

  Handle := Open(@TmpStr, OpenFlags);
  if Handle = 0 then
  begin
    DosError2InOut(IoErr);
  end else
  begin
    AddToList(AOS_fileList, Handle, PChar(@TmpStr[0]));
    filerec(f).Handle := Handle;
  end;

  { append mode }
  if ((Flags and $100) <> 0) and (FileRec(F).Handle <> UnusedHandle) then
  begin
    do_seekend(filerec(f).Handle);
    filerec(f).mode := fmoutput; {fool fmappend}
  end;

  {$IFDEF MOSFPC_FILEDEBUG}
  if not ((Handle = StdOutputHandle) or (Handle = StdInputHandle) or
    (Handle = StdErrorHandle)) then
  begin
    CheckInList(AOS_fileList, h);
  end;
  {$ENDIF}

end;

function do_isdevice(Handle: LongInt): Boolean;
begin
  if (Handle = StdOutputHandle) or (Handle = StdInputHandle) or
     (Handle = StdErrorHandle) then
    do_isdevice := True
  else
    do_isdevice := False;
end;
