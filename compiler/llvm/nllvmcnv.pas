{
    Copyright (c) 2014 by Jonas Maebe

    Generate LLVM IR for type converting nodes

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
unit nllvmcnv;

{$i fpcdefs.inc}

interface

    uses
      node,ncnv,ncgcnv,defcmp;

    type
       tllvmtypeconvnode = class(tcgtypeconvnode)
         protected
          procedure second_int_to_int;override;
         { procedure second_string_to_string;override; }
         { procedure second_cstring_to_pchar;override; }
         { procedure second_string_to_chararray;override; }
         { procedure second_array_to_pointer;override; }
         procedure second_pointer_to_array;override;
         { procedure second_chararray_to_string;override; }
         { procedure second_char_to_string;override; }
         { procedure second_int_to_real;override; }
         { procedure second_real_to_real;override; }
         { procedure second_cord_to_pointer;override; }
         { procedure second_proc_to_procvar;override; }
         { procedure second_bool_to_int;override; }
         {  procedure second_int_to_bool;override; }
         { procedure second_load_smallset;override;  }
         { procedure second_ansistring_to_pchar;override; }
         { procedure second_pchar_to_string;override; }
         { procedure second_class_to_intf;override; }
         { procedure second_char_to_char;override; }
          procedure second_nothing; override;
       end;

implementation

uses
  globtype,verbose,
  aasmdata,
  llvmbase,aasmllvm,
  symdef,defutil,
  cgbase,cgutils,hlcgobj;

{ tllvmtypeconvnode }

procedure tllvmtypeconvnode.second_int_to_int;
  var
    fromsize, tosize: tcgint;
    hreg: tregister;
  begin
    if not(nf_explicit in flags) then
      hlcg.g_rangecheck(current_asmdata.CurrAsmList,left.location,left.resultdef,resultdef);
    fromsize:=left.resultdef.size;
    tosize:=resultdef.size;
    location_copy(location,left.location);
    if not(left.location.loc in [LOC_REFERENCE,LOC_CREFERENCE]) or
       (fromsize<>tosize) then
      begin
        hlcg.location_force_reg(current_asmdata.CurrAsmList,location,left.resultdef,resultdef,left.location.loc=LOC_CREGISTER);
      end
    else if left.resultdef<>resultdef then
      begin
        { just typecast the pointer type }
        hreg:=hlcg.getaddressregister(current_asmdata.CurrAsmList,getpointerdef(resultdef));
        hlcg.a_loadaddr_ref_reg(current_asmdata.CurrAsmList,left.resultdef,getpointerdef(resultdef),left.location.reference,hreg);
        hlcg.reference_reset_base(location.reference,getpointerdef(resultdef),hreg,0,location.reference.alignment);
      end;
  end;


procedure tllvmtypeconvnode.second_pointer_to_array;
  var
    hreg: tregister;
  begin
    inherited;
    { insert type conversion }
    hreg:=hlcg.getaddressregister(current_asmdata.CurrAsmList,getpointerdef(resultdef));
    hlcg.a_loadaddr_ref_reg(current_asmdata.CurrAsmList,tpointerdef(left.resultdef).pointeddef,getpointerdef(resultdef),location.reference,hreg);
    reference_reset_base(location.reference,hreg,0,location.reference.alignment);
  end;


procedure tllvmtypeconvnode.second_nothing;
  var
    hreg: tregister;
  begin
    if left.resultdef<>resultdef then
      begin
        if left.resultdef.size<>resultdef.size then
          internalerror(2014012216);
        hlcg.location_force_mem(current_asmdata.CurrAsmList,left.location,left.resultdef);
        hreg:=hlcg.getaddressregister(current_asmdata.CurrAsmList,getpointerdef(resultdef));
        hlcg.a_loadaddr_ref_reg(current_asmdata.CurrAsmList,left.resultdef,getpointerdef(resultdef),left.location.reference,hreg);
        location_reset_ref(location,left.location.loc,left.location.size,left.location.reference.alignment);
        reference_reset_base(location.reference,hreg,0,location.reference.alignment);
      end
    else
      location_copy(location,left.location);
  end;

begin
  ctypeconvnode:=tllvmtypeconvnode;
end.
