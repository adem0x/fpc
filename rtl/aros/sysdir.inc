{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by Florian Klaempfl and Pavel Ozerski
    member of the Free Pascal development team.

    FPC Pascal system unit for the Win32 API.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}


{*****************************************************************************
                           Directory Handling
*****************************************************************************}
//procedure mkdir(const s : string);
procedure mkdir(a: PChar; l: LongInt); [IOCheck, public, alias : 'FPC_SYS_MKDIR'];
var
  TmpStr : array[0..255] of char;
  TmpLock: LongInt;
  S: String;
begin
  S := string(a);
  CheckCTRLC;
  if (S = '') or (InOutRes <> 0) then
    Exit;
  TmpStr := PathConv(S) + #0;
  TmpLock := DosCreateDir(@TmpStr);
  if TmpLock = 0 then begin
    DosError2InOut(IoErr);
    Exit;
  end;
  UnLock(TmpLock);
end;


//procedure rmdir(const s : string);
procedure rmdir(a: PChar; l: LongInt); [IOCheck, public, alias : 'FPC_SYS_RMDIR'];
var
  TmpStr : array[0..255] of Char;
  S: string;
begin
  S := string(a);
  CheckCTRLC;
  if (S = '.') then
    InOutRes := 16;
  If (S = '') or (InOutRes <> 0) then
    Exit;
  TmpStr := PathConv(S) + #0;
  if not DosDeleteFile(@TmpStr) then
    DosError2InOut(IoErr);
end;

//procedure chdir(const s : string);
procedure chdir(a: PChar; l: LongInt); [IOCheck, public, alias : 'FPC_SYS_CHDIR'];
var
  TmpStr : array[0..255] of Char;
  TmpLock: LongInt;
  FIB    : PFileInfoBlock;
  S: String;
begin
  S := string(a);
  CheckCTRLC;
  If (S = '') or (InOutRes <> 0) then
    Exit;
  TmpStr := PathConv(S) + #0;
  TmpLock := 0;

  { Changing the directory is a pretty complicated affair }
  {   1) Obtain a lock on the directory                   }
  {   2) CurrentDir the lock                              }
  TmpLock := Lock(@TmpStr, SHARED_LOCK);
  if TmpLock=0 then
  begin
    DosError2InOut(IoErr);
    Exit;
  end;

  FIB := nil;
  New(FIB);

  if (Examine(TmpLock, FIB) <> 0) and (FIB^.fib_DirEntryType > 0) then
  begin
    TmpLock := CurrentDir(TmpLock);
    if AOS_OrigDir = 0 then
    begin
      AOS_OrigDir := TmpLock;
      TmpLock := 0;
    end;
  end;

  if TmpLock <> 0 then
    Unlock(TmpLock);
  if Assigned(FIB) then
    Dispose(FIB);
end;

procedure GetDir(DriveNr: Byte; var Dir: ShortString);
var
  TmpBuf: array[0..255] of Char;
  LockDir: LongInt;
begin
  CheckCTRLC;
  Dir:='';
  LockDir := CurrentDir(0);
  CurrentDir(LockDir);
  NameFromLock(LockDir, TmpBuf, 256);
  Dir := StrPas(TmpBuf);
  // followinf dos not work when called from WB or by make
  {if not GetCurrentDirName(tmpbuf,256) then
    DosError2InOut(IoErr)
  else
    Dir:=strpas(tmpbuf);
    }
end;
