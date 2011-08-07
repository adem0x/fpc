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
  tmpStr : array[0..255] of char;
  tmpLock: LongInt;
  s: String;
begin
  s := string(a);
  checkCTRLC;
  if (s='') or (InOutRes<>0) then exit;
  tmpStr:=PathConv(s)+#0;
  tmpLock:=dosCreateDir(@tmpStr);
  if tmpLock=0 then begin
    dosError2InOut(IoErr);
    exit;
  end;
  UnLock(tmpLock);
end;


//procedure rmdir(const s : string);
procedure rmdir(a: PChar; l: LongInt); [IOCheck, public, alias : 'FPC_SYS_RMDIR'];
var
  tmpStr : array[0..255] of Char;
  s: string;
begin
  s := string(a);
  checkCTRLC;
  if (s='.') then InOutRes:=16;
  If (s='') or (InOutRes<>0) then exit;
  tmpStr:=PathConv(s)+#0;
  if not dosDeleteFile(@tmpStr) then
    dosError2InOut(IoErr);
end;

//procedure chdir(const s : string);
procedure chdir(a: PChar; l: LongInt); [IOCheck, public, alias : 'FPC_SYS_CHDIR'];
var
  tmpStr : array[0..255] of Char;
  tmpLock: LongInt;
  FIB    : PFileInfoBlock;
  s: String;
begin
  s := string(a);
  checkCTRLC;
  If (s='') or (InOutRes<>0) then exit;
  tmpStr:=PathConv(s)+#0;
  tmpLock:=0;

  { Changing the directory is a pretty complicated affair }
  {   1) Obtain a lock on the directory                   }
  {   2) CurrentDir the lock                              }
  tmpLock:=Lock(@tmpStr,SHARED_LOCK);
  if tmpLock=0 then begin
    dosError2InOut(IoErr);
    exit;
  end;

  FIB:=nil;
  new(FIB);

  if (Examine(tmpLock,FIB)=True) and (FIB^.fib_DirEntryType>0) then begin
    tmpLock:=CurrentDir(tmpLock);
    if AOS_OrigDir=0 then begin
      AOS_OrigDir:=tmpLock;
      tmpLock:=0;
    end;
  end;

  if tmpLock<>0 then Unlock(tmpLock);
  if assigned(FIB) then dispose(FIB);
end;

procedure GetDir (DriveNr: byte; var Dir: ShortString);
var
  tmpbuf: array[0..255] of char;
  LockDir: LongInt;
begin
  checkCTRLC;
  Dir:='';
  LockDir := CurrentDir(0);
  CurrentDir(LockDir);
  NameFromLock(LockDir, tmpbuf, 256);
  Dir := strpas(tmpbuf);
  // followinf dos not work when called from WB or by make
  {if not GetCurrentDirName(tmpbuf,256) then
    dosError2InOut(IoErr)
  else
    Dir:=strpas(tmpbuf);
    }
end;
