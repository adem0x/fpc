{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by Michael Van Canneyt
    member of the Free Pascal development team

    Threadvar support, platform independent part

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}


{*****************************************************************************
                           Threadvar support
*****************************************************************************}


type
  pltvInitEntry = ^ltvInitEntry;
  ltvInitEntry = packed record
     varaddr : plongword;
     size    : longint;
  end;

  TltvInitTablesTable = packed record
    count  : longword;
    tables : packed array [1..32767] of pltvInitEntry;
  end;

var
  ThreadvarTablesTable : TltvInitTablesTable; external name 'FPC_THREADVARTABLES';
  ThreadvarContainerSize : PtrUInt;


procedure copy_unit_threadthreadvars(p: pointer; tableEntry: pltvInitEntry);
var
  src: pointer;
  dst: pointer;
begin
  while tableEntry^.varaddr <> nil do
  begin
    { copy initial threadvar data to TLS section }
    src := pointer(pchar(tableEntry^.varaddr)+sizeof(pointer));
    dst := pointer(PtrUInt(P) + tableEntry^.varaddr^);
    move(src^, dst^, tableEntry^.size);

    { goto next entry }
    inc(pchar(tableEntry), sizeof(tableEntry^));
  end;
end;

function ThreadVarLocate(Offset: Longword): pointer; register;
var
  P: pointer;
begin
  WriteLn('ThreadVarLocate');
//  P := __CurrentTM.TlsSectionGet();
//  Result := pointer(ptruint(P) + Offset);
end;

procedure InitTlsSection(var Address: Pointer);
var
  i: integer;
begin
  { allocate memory for threadvars of this new TLS section }
  GetMem(Address, ThreadvarContainerSize);
  FillChar(Address^, ThreadvarContainerSize, 0);

  { copy threadvar initial data to TLS section }
  for i := 1 to ThreadvarTablesTable.count do
    copy_unit_threadthreadvars(Address, ThreadvarTablesTable.tables[i]);
end;

procedure FreeTlsSection(var Address: Pointer);
begin
  FreeMem(Address);
  Address := nil;
end;


procedure init_unit_threadthreadvars(tableEntry: pltvInitEntry);
var
  size: integer;
begin
  while tableEntry^.varaddr <> nil do
  begin
    { align to operand size }
    size := tableEntry^.size mod sizeof(pointer);
    if size <> 0 then
      size := tableEntry^.size + sizeof(pointer) - size
    else
      size := tableEntry^.size;

    { offset means byte offset inside tls section }
    tableEntry^.varaddr^ := ThreadvarContainerSize;
    inc(ThreadvarContainerSize, size);

    { goto next entry }
    inc(pchar(tableEntry), sizeof(tableEntry^));
  end;
end;

procedure InitThreadvars;
var
  i: integer;
begin
  ThreadvarContainerSize := 0;
{$ifdef DEBUG_MT}
  WriteLn ('InitThreadvars (',ThreadvarTablesTable.count,') units');
{$endif}
  for i := 1 to ThreadvarTablesTable.count do
    init_unit_threadthreadvars(ThreadvarTablesTable.tables[i]);
end;


