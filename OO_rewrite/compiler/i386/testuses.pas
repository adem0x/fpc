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
unit testuses;

interface

uses
  testprop;

function testlab: integer;

implementation

function testlab: integer;
var
  b: boolean;
label l1;
begin
  if b then
    goto l1;
  Result := 1;
  exit;
l1:
  testlab := 2;
end;

end.
