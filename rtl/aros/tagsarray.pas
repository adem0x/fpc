{
    This file is part of the Free Pascal run time library.

    A file in Amiga system run time library.
    Copyright (c) 2002 by Nils Sjoholm
    member of the Amiga RTL development team.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{
     History:

     First version of this unit.
     Just use this unit when you want to
     use taglist.

     09 Nov 2002

     nils.sjoholm@mailbox.swipnet.se
}

unit tagsarray;
{$mode objfpc}


interface

uses Exec, Utility;

type
  TTagsList= array of ttagitem;
  PMyTags= ^TTagsList;


function readintags(const args : array of const): pTagItem;
procedure AddTags(var Taglist: TTagsList; const args: array of const);
function GetTagPtr(TagList: TTagsList): pTagItem;

implementation

uses pastoc;

var
  mytags : PMyTags;//array [0..200] of ttagitem;


procedure AddTags(var Taglist: TTagsList; const args: array of const);
var
  i: LongInt;
  ii: LongInt;
begin
  ii := Length(TagList);
  SetLength(TagList, Length(TagList) + (Length(args) DIV 2));
  for i := 0 to High(args) do
  begin
    if (not Odd(i)) then
    begin
      TagList[ii].ti_tag := longint(Args[i].vinteger);
    end else
    begin
      case Args[i].vtype of
        vtinteger : TagList[ii].ti_data := longint(Args[i].vinteger);
        vtboolean : TagList[ii].ti_data := longint(byte(Args[i].vboolean));
        vtpchar   : TagList[ii].ti_data := longint(Args[i].vpchar);
        vtchar    : TagList[ii].ti_data := longint(Args[i].vchar);
        vtstring  : TagList[ii].ti_data := longint(pas2c(Args[i].vstring^));
        vtpointer : TagList[ii].ti_data := longint(Args[i].vpointer);
      end;
      inc(ii);
    end;
  end;
end;

function GetTagPtr(TagList: TTagsList): pTagItem;
begin
  AddTags(TagList, [TAG_END, TAG_END]);
  GetTagPtr := @(TagList[0]);
end;

function readintags(const args : array of const): pTagItem;
var
    i : longint;
    ii : longint;
begin
    ii := 0;
    for i := 0 to high(args) do begin
         if (not odd(i)) then begin
              mytags^[ii].ti_tag := longint(Args[i].vinteger);
         end else begin
             case Args[i].vtype of
                  vtinteger : mytags^[ii].ti_data := longint(Args[i].vinteger);
                  vtboolean : mytags^[ii].ti_data := longint(byte(Args[i].vboolean));
                  vtpchar   : mytags^[ii].ti_data := longint(Args[i].vpchar);
                  vtchar    : mytags^[ii].ti_data := longint(Args[i].vchar);
                  vtstring  : mytags^[ii].ti_data := longint(pas2c(Args[i].vstring^));
                  vtpointer : mytags^[ii].ti_data := longint(Args[i].vpointer);
             end;
             inc(ii);
         end;
    end;
    readintags := @(mytags^[0]);
end;

initialization
  New(MyTags);
  SetLength(MyTags^, 200);
finalization
  SetLength(MyTags^, 0);
  Dispose(MyTags);
end.
