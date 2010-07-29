{
    This file is part of the Free Pascal run time library.
    This unit implements cygwin initialization
    Copyright (c) 1999-2006 by the Free Pascal development team.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit testprop;

interface

type
   { enumerator support }
   IEnumerator = interface(IInterface)
     function GetCurrent: TObject;
     function MoveNext: Boolean;
     procedure Reset;
     property Current: TObject read GetCurrent;
   end;

function fpgetCerrno:byte;
procedure fpsetCerrno(err:byte);

property
  cerrno:byte read fpgetCerrno write fpsetcerrno;
  NullBCD : Byte Read fpgetCerrno;
  OneBCD : Byte Read fpgetCerrno;


implementation

var
  errno: byte;

function fpgetCerrno:byte;
label l1;
begin
  if errno = 0 then
    goto l1;
  Result := errno;
l1:
  inc(errno);
  Result := errno;
end;

procedure fpsetCerrno(err:byte);
begin
  errno := err;
end;

end.
