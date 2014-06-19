{
    Copyright (c) 2014 by Nikolay Nikolov

    i8086 version of some node tree helper routines

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

 ****************************************************************************
}
unit n8086util;

{$i fpcdefs.inc}

interface

  uses
    ngenutil;


  type
    ti8086nodeutils = class(tnodeutils)
      class procedure InsertMemorySizes; override;
      class procedure InsertStackSegment;
      class procedure InsertHeapSegment;
    end;


implementation

  uses
    sysutils,cutils,
    globtype,globals,cpuinfo,
    aasmbase,aasmdata,aasmtai;


  class procedure ti8086nodeutils.InsertMemorySizes;
    begin
      inherited;
      if current_settings.x86memorymodel<>mm_tiny then
        InsertStackSegment;
      InsertHeapSegment;
    end;


  class procedure ti8086nodeutils.InsertStackSegment;
    var
      stacksizeleft,stackblock: LongInt;
      i: Integer;
    begin
      maybe_new_object_file(current_asmdata.asmlists[al_globals]);
      new_section(current_asmdata.asmlists[al_globals],sec_stack,'__stack', 16);
      current_asmdata.asmlists[al_globals].concat(tai_symbol.Createname_global('___stack', AT_DATA, stacksize));
      { HACK: since tai_datablock's size parameter is aint, which cannot be
        larger than 32767 on i8086, but we'd like to support stack size of
        up to 64kb, we may need to use several tai_datablocks to reserve
        the stack segment }
      i:=0;
      stacksizeleft:=stacksize;
      while stacksizeleft>0 do
        begin
          stackblock:=min(stacksizeleft,high(aint));
          current_asmdata.asmlists[al_globals].concat(tai_datablock.Create('___stackblock'+IntToStr(i),stackblock));
          dec(stacksizeleft,stackblock);
          inc(i);
        end;
      current_asmdata.asmlists[al_globals].concat(tai_symbol.Createname_global('___stacktop',AT_DATA,0));
    end;


  class procedure ti8086nodeutils.InsertHeapSegment;
    var
      heapsizeleft,heapblock: LongInt;
      i: Integer;
    begin
      maybe_new_object_file(current_asmdata.asmlists[al_globals]);
      new_section(current_asmdata.asmlists[al_globals],sec_heap,'__heap', 16);
      current_asmdata.asmlists[al_globals].concat(tai_symbol.Createname_global('___heap', AT_DATA, heapsize));
      { HACK: since tai_datablock's size parameter is aint, which cannot be
        larger than 32767 on i8086, but we'd like to support heap size of
        up to 640kb, we may need to use several tai_datablocks to reserve
        the heap segment }
      i:=0;
      heapsizeleft:=heapsize;
      while heapsizeleft>0 do
        begin
          heapblock:=min(heapsizeleft,high(aint));
          current_asmdata.asmlists[al_globals].concat(tai_datablock.Create('___heapblock'+IntToStr(i),heapblock));
          dec(heapsizeleft,heapblock);
          inc(i);
        end;
      current_asmdata.asmlists[al_globals].concat(tai_symbol.Createname_global('___heaptop',AT_DATA,0));
    end;


begin
  cnodeutils:=ti8086nodeutils;
end.
