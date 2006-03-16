{
    Copyright (c) 1998-2002 by Florian Klaempfl

    Generate ARM assembler for type converting nodes

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
unit narmcnv;

{$i fpcdefs.inc}

interface

    uses
      node,ncnv,ncgcnv,defcmp;

    type
       tarmtypeconvnode = class(tcgtypeconvnode)
         protected
           function first_int_to_real: tnode;override;
         { procedure second_int_to_int;override; }
         { procedure second_string_to_string;override; }
         { procedure second_cstring_to_pchar;override; }
         { procedure second_string_to_chararray;override; }
         { procedure second_array_to_pointer;override; }
         // function first_int_to_real: tnode; override;
         { procedure second_pointer_to_array;override; }
         { procedure second_chararray_to_string;override; }
         { procedure second_char_to_string;override; }
           procedure second_int_to_real;override;
         // procedure second_real_to_real;override;
         { procedure second_cord_to_pointer;override; }
         { procedure second_proc_to_procvar;override; }
         { procedure second_bool_to_int;override; }
           procedure second_int_to_bool;override;
         { procedure second_load_smallset;override;  }
         { procedure second_ansistring_to_pchar;override; }
         { procedure second_pchar_to_string;override; }
         { procedure second_class_to_intf;override; }
         { procedure second_char_to_char;override; }
       end;

implementation

   uses
      verbose,globtype,globals,systems,
      symconst,symdef,aasmbase,aasmtai,aasmdata,
      defutil,
      cgbase,cgutils,
      pass_1,pass_2,procinfo,
      ncon,ncal,
      ncgutil,
      cpubase,aasmcpu,
      rgobj,tgobj,cgobj,cgcpu;


{*****************************************************************************
                             FirstTypeConv
*****************************************************************************}

    function tarmtypeconvnode.first_int_to_real: tnode;
      var
        fname: string[19];
      begin
        if cs_fp_emulation in aktmoduleswitches then
          begin
            if target_info.system in system_wince then
              begin
                { converting a 64bit integer to a float requires a helper }
                if is_64bitint(left.resulttype.def) or
                  is_currency(left.resulttype.def) then
                  begin
                    { hack to avoid double division by 10000, as it's
                      already done by resulttypepass.resulttype_int_to_real }
                    if is_currency(left.resulttype.def) then
                      left.resulttype := s64inttype;
                    if is_signed(left.resulttype.def) then
                      fname:='I64TOD'
                    else
                      fname:='UI64TOD';
                  end
                else
                  { other integers are supposed to be 32 bit }
                  begin
                    if is_signed(left.resulttype.def) then
                      fname:='ITOD'
                    else
                      fname:='UTOD';
                    firstpass(left);
                  end;
                result:=ccallnode.createintern(fname,ccallparanode.create(
                  left,nil));
                left:=nil;
                firstpass(result);
                exit;
              end
            else
              begin
                internalerror(2005082803);
              end;
          end
        else
          begin
            { converting a 64bit integer to a float requires a helper }
            if is_64bitint(left.resulttype.def) or
              is_currency(left.resulttype.def) then
              begin
                { hack to avoid double division by 10000, as it's
                  already done by resulttypepass.resulttype_int_to_real }
                if is_currency(left.resulttype.def) then
                  left.resulttype := s64inttype;
                if is_signed(left.resulttype.def) then
                  fname := 'fpc_int64_to_double'
                else
                  fname := 'fpc_qword_to_double';
                result := ccallnode.createintern(fname,ccallparanode.create(
                  left,nil));
                left:=nil;
                firstpass(result);
                exit;
              end
            else
              { other integers are supposed to be 32 bit }
              begin
                if is_signed(left.resulttype.def) then
                  inserttypeconv(left,s32inttype)
                else
                  inserttypeconv(left,u32inttype);
                firstpass(left);
              end;
            result := nil;
            if registersfpu<1 then
              registersfpu:=1;
            expectloc:=LOC_FPUREGISTER;
          end;
      end;


    procedure tarmtypeconvnode.second_int_to_real;
      var
        instr : taicpu;
      begin
        location_reset(location,LOC_FPUREGISTER,def_cgsize(resulttype.def));
        location_force_reg(current_asmdata.CurrAsmList,left.location,OS_32,true);
        location.register:=cg.getfpuregister(current_asmdata.CurrAsmList,location.size);
        instr:=taicpu.op_reg_reg(A_FLT,location.register,left.location.register);
        instr.oppostfix:=cgsize2fpuoppostfix[def_cgsize(resulttype.def)];
        current_asmdata.CurrAsmList.concat(instr);
      end;


    procedure tarmtypeconvnode.second_int_to_bool;
      var
        hregister : tregister;
        href      : treference;
        resflags  : tresflags;
        hlabel,oldTrueLabel,oldFalseLabel : tasmlabel;
      begin
         oldTrueLabel:=current_procinfo.CurrTrueLabel;
         oldFalseLabel:=current_procinfo.CurrFalseLabel;
         current_asmdata.getjumplabel(current_procinfo.CurrTrueLabel);
         current_asmdata.getjumplabel(current_procinfo.CurrFalseLabel);
         secondpass(left);
         if codegenerror then
          exit;
         { byte(boolean) or word(wordbool) or longint(longbool) must
           be accepted for var parameters                            }
         if (nf_explicit in flags) and
            (left.resulttype.def.size=resulttype.def.size) and
            (left.location.loc in [LOC_REFERENCE,LOC_CREFERENCE,LOC_CREGISTER]) then
           begin
              location_copy(location,left.location);
              current_procinfo.CurrTrueLabel:=oldTrueLabel;
              current_procinfo.CurrFalseLabel:=oldFalseLabel;
              exit;
           end;

         { Load left node into flag F_NE/F_E }
         resflags:=F_NE;
         case left.location.loc of
            LOC_CREFERENCE,
            LOC_REFERENCE :
              begin
                if left.location.size in [OS_64,OS_S64] then
                 begin
                   hregister:=cg.getintregister(current_asmdata.CurrAsmList,OS_INT);
                   cg.a_load_ref_reg(current_asmdata.CurrAsmList,OS_32,OS_32,left.location.reference,hregister);
                   href:=left.location.reference;
                   inc(href.offset,4);
                   tcgarm(cg).cgsetflags:=true;
                   cg.a_op_ref_reg(current_asmdata.CurrAsmList,OP_OR,OS_32,href,hregister);
                   tcgarm(cg).cgsetflags:=false;
                 end
                else
                 begin
                   location_force_reg(current_asmdata.CurrAsmList,left.location,left.location.size,true);
                   tcgarm(cg).cgsetflags:=true;
                   cg.a_op_reg_reg(current_asmdata.CurrAsmList,OP_OR,left.location.size,left.location.register,left.location.register);
                   tcgarm(cg).cgsetflags:=false;
                 end;
              end;
            LOC_FLAGS :
              begin
                resflags:=left.location.resflags;
              end;
            LOC_REGISTER,LOC_CREGISTER :
              begin
                if left.location.size in [OS_64,OS_S64] then
                 begin
                   hregister:=cg.getintregister(current_asmdata.CurrAsmList,OS_32);
                   cg.a_load_reg_reg(current_asmdata.CurrAsmList,OS_32,OS_32,left.location.register64.reglo,hregister);
                   tcgarm(cg).cgsetflags:=true;
                   cg.a_op_reg_reg(current_asmdata.CurrAsmList,OP_OR,OS_32,left.location.register64.reghi,hregister);
                   tcgarm(cg).cgsetflags:=false;
                 end
                else
                 begin
                   tcgarm(cg).cgsetflags:=true;
                   cg.a_op_reg_reg(current_asmdata.CurrAsmList,OP_OR,left.location.size,left.location.register,left.location.register);
                   tcgarm(cg).cgsetflags:=false;
                 end;
              end;
            LOC_JUMP :
              begin
                hregister:=cg.getintregister(current_asmdata.CurrAsmList,OS_INT);
                current_asmdata.getjumplabel(hlabel);
                cg.a_label(current_asmdata.CurrAsmList,current_procinfo.CurrTrueLabel);
                cg.a_load_const_reg(current_asmdata.CurrAsmList,OS_INT,1,hregister);
                cg.a_jmp_always(current_asmdata.CurrAsmList,hlabel);
                cg.a_label(current_asmdata.CurrAsmList,current_procinfo.CurrFalseLabel);
                cg.a_load_const_reg(current_asmdata.CurrAsmList,OS_INT,0,hregister);
                cg.a_label(current_asmdata.CurrAsmList,hlabel);
                tcgarm(cg).cgsetflags:=true;
                cg.a_op_reg_reg(current_asmdata.CurrAsmList,OP_OR,OS_INT,hregister,hregister);
                tcgarm(cg).cgsetflags:=false;
              end;
            else
              internalerror(200311301);
         end;
         { load flags to register }
         location_reset(location,LOC_REGISTER,def_cgsize(resulttype.def));
         location.register:=cg.getintregister(current_asmdata.CurrAsmList,location.size);
         cg.g_flags2reg(current_asmdata.CurrAsmList,location.size,resflags,location.register);
         current_procinfo.CurrTrueLabel:=oldTrueLabel;
         current_procinfo.CurrFalseLabel:=oldFalseLabel;
      end;


begin
  ctypeconvnode:=tarmtypeconvnode;
end.
