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
  ThreadvarContainerCount : Longword;

type
  PTlsSection = ^TTlsSection;
  TTlsSection = record
    threadvars : pointer;
  end;

procedure copy_unit_threadthreadvars(p: PTlsSection; tableEntry: pltvInitEntry);
var
  src: pointer;
  dst: pointer;
begin
  while tableEntry^.varaddr <> nil do
  begin
    { copy initial threadvar data to TLS section }
    src := pointer(pchar(tableEntry^.varaddr)+sizeof(pointer));
    dst := pointer(PtrUInt(P^.threadvars) + tableEntry^.varaddr^);
    move(src^, dst^, tableEntry^.size);

    { goto next entry }
    inc(pchar(tableEntry), sizeof(tableEntry^));
  end;
end;

procedure InitTlsSection(const Address: Pointer);
var
  P: PTlsSection absolute Address;
  i: integer;
begin
  { allocate memory for threadthreadvars of this new TLS section }
  GetMem(P^.threadvars, ThreadvarContainerSize);

  { copy threadvar initial data to TLS section }
  for i := 1 to ThreadvarTablesTable.count do
    copy_unit_threadthreadvars(P, ThreadvarTablesTable.tables[i]);
end;

procedure FreeTlsSection(const Address: Pointer);
var
  P: PTlsSection absolute Address;
begin
  FreeMem(P^.threadvars);
  P^.threadvars := nil;
end;

function ThreadVarLocate(const Offset: Longword): pointer;
var
  P: PTlsSection;
begin
  P := __CurrentTM.TlsSectionGet();
  Result := pointer(ptruint(P^.threadvars) + Offset);
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
    inc(ThreadvarContainerCount);

    { goto next entry }
    inc(pchar(tableEntry), sizeof(tableEntry^));
  end;
end;

procedure InitThreadvars;
var
  i: integer;
begin
  ThreadvarContainerSize := 0;
  ThreadvarContainerCount := 0;
{$ifdef DEBUG_MT}
  WriteLn ('InitThreadthreadvars (',ThreadvarTablesTable.count,') units');
{$endif}
  for i := 1 to ThreadvarTablesTable.count do
    init_unit_threadthreadvars(ThreadvarTablesTable.tables[i]);
end;


