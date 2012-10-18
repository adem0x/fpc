{
    Copyright (c) 1998-2002 by Florian Klaempfl

    Generate m68k assembler for type converting nodes

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
unit n68kcnv;

{$i fpcdefs.inc}

interface

    uses
      node,ncnv,ncgcnv,defcmp;

    type
       tm68ktypeconvnode = class(tcgtypeconvnode)
         protected
          function first_int_to_real: tnode; override;
          procedure second_int_to_real;override;
          procedure second_int_to_bool;override;
//          procedure pass_generate_code;override;
       end;

implementation

   uses
      verbose,globals,systems,
      symconst,symdef,aasmbase,aasmtai,aasmdata,
      defutil,
      cgbase,pass_1,pass_2,procinfo,
      ncon,ncal,
      ncgutil,
      cpubase,aasmcpu,
      rgobj,tgobj,cgobj,hlcgobj,cgutils,globtype,cgcpu;


{*****************************************************************************
                             FirstTypeConv
*****************************************************************************}

    function tm68ktypeconvnode.first_int_to_real: tnode;
      var
        fname: string[32];
      begin
        { In case we are in emulation mode, we must
          always call the helpers
        }
        if (cs_fp_emulation in current_settings.moduleswitches) then
          begin
            result := inherited first_int_to_real;
            exit;
          end
        else
        { converting a 64bit integer to a float requires a helper }
        if is_64bitint(left.resultdef) then
          begin
            if is_signed(left.resultdef) then
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
            if is_signed(left.resultdef) then
              inserttypeconv(left,s32inttype)
            else
              { the fpu always considers 32-bit values as signed
                therefore we need to call the helper in case of
                a cardinal value.
              }
              begin
                 fname := 'fpc_longword_to_double';
                 result := ccallnode.createintern(fname,ccallparanode.create(
                    left,nil));
                 left:=nil;
                 firstpass(result);
                 exit;
              end;
            firstpass(left);
          end;
        result := nil;
        location.loc:=LOC_FPUREGISTER;
      end;


{*****************************************************************************
                             SecondTypeConv
*****************************************************************************}



    procedure tm68ktypeconvnode.second_int_to_real;

      var
        tempconst: trealconstnode;
        ref: treference;
        valuereg, tempreg, leftreg, tmpfpureg: tregister;
        signed : boolean;
        scratch_used : boolean;
        opsize : tcgsize;
      begin
        scratch_used := false;
        location_reset(location,LOC_FPUREGISTER,def_cgsize(resultdef));
        signed := is_signed(left.resultdef);
        opsize := def_cgsize(left.resultdef);
        { has to be handled by a helper }
        if is_64bitint(left.resultdef) then
          internalerror(200110011);
        { has to be handled by a helper }
        if not signed then
           internalerror(2002081404);

        location.register:=cg.getfpuregister(current_asmdata.CurrAsmList,opsize);
        if not(left.location.loc in [LOC_REGISTER,LOC_CREGISTER,LOC_REFERENCE,LOC_CREFERENCE]) then
          hlcg.location_force_reg(current_asmdata.CurrAsmList,left.location,left.resultdef,osuinttype,false);
        case left.location.loc of
          LOC_REGISTER, LOC_CREGISTER:
            begin
              leftreg := left.location.register;
              current_asmdata.CurrAsmList.concat(taicpu.op_reg_reg(A_FMOVE,TCGSize2OpSize[opsize],leftreg,
                  location.register));
            end;
          LOC_REFERENCE,LOC_CREFERENCE:
            begin
              current_asmdata.CurrAsmList.concat(taicpu.op_ref_reg(A_FMOVE,TCGSize2OpSize[opsize],
                  left.location.reference,location.register));
            end
          else
            internalerror(200110012);
         end;
       end;


    procedure tm68ktypeconvnode.second_int_to_bool;
      var
        hreg1,
        hreg2    : tregister;
        resflags : tresflags;
        opsize   : tcgsize;
        newsize  : tcgsize;
        hlabel,
        oldTrueLabel,
        oldFalseLabel : tasmlabel;
      begin
         oldTrueLabel:=current_procinfo.CurrTrueLabel;
         oldFalseLabel:=current_procinfo.CurrFalseLabel;
         current_asmdata.getjumplabel(current_procinfo.CurrTrueLabel);
         current_asmdata.getjumplabel(current_procinfo.CurrFalseLabel);

         secondpass(left);

         { Explicit typecasts from any ordinal type to a boolean type }
         { must not change the ordinal value                          }
         if (nf_explicit in flags) and
            not(left.location.loc in [LOC_FLAGS,LOC_JUMP]) then
           begin
              location_copy(location,left.location);
              newsize:=def_cgsize(resultdef);
              { change of size? change sign only if location is LOC_(C)REGISTER? Then we have to sign/zero-extend }
              if (tcgsize2size[newsize]<>tcgsize2size[left.location.size]) or
                 ((newsize<>left.location.size) and (location.loc in [LOC_REGISTER,LOC_CREGISTER])) then
                hlcg.location_force_reg(current_asmdata.CurrAsmList,location,left.resultdef,resultdef,true)
              else
                location.size:=newsize;
              current_procinfo.CurrTrueLabel:=oldTrueLabel;
              current_procinfo.CurrFalseLabel:=oldFalseLabel;
              exit;
           end;

         location_reset(location,LOC_REGISTER,def_cgsize(left.resultdef));
         opsize := def_cgsize(left.resultdef);
         case left.location.loc of
            LOC_CREFERENCE,LOC_REFERENCE :
              begin
                { can we optimize it, or do we need to fix the ref. ? }
                if isvalidrefoffset(left.location.reference) then
                  begin
                    current_asmdata.CurrAsmList.concat(taicpu.op_ref(A_TST,TCGSize2OpSize[opsize],
                       left.location.reference));
                  end
                else
                  begin
                     hreg2:=cg.getintregister(current_asmdata.CurrAsmList,opsize);
                     cg.a_load_ref_reg(current_asmdata.CurrAsmList,opsize,opsize,
                        left.location.reference,hreg2);
                     current_asmdata.CurrAsmList.concat(taicpu.op_reg(A_TST,TCGSize2OpSize[opsize],hreg2));
//                     cg.ungetcpuregister(current_asmdata.CurrAsmList,hreg2);
                  end;
//                reference_release(current_asmdata.CurrAsmList,left.location.reference);
                resflags:=F_NE;
                hreg1:=cg.getintregister(current_asmdata.CurrAsmList,opsize);
              end;
            LOC_REGISTER,LOC_CREGISTER :
              begin
                hreg2:=left.location.register;
                current_asmdata.CurrAsmList.concat(taicpu.op_reg(A_TST,TCGSize2OpSize[opsize],hreg2));
//                cg.ungetcpuregister(current_asmdata.CurrAsmList,hreg2);
                hreg1:=cg.getintregister(current_asmdata.CurrAsmList,opsize);
                resflags:=F_NE;
              end;
            LOC_FLAGS :
              begin
                hreg1:=cg.getintregister(current_asmdata.CurrAsmList,opsize);
                resflags:=left.location.resflags;
              end;
            LOC_JUMP :
              begin
                { for now blindly copied from nx86cnv }
                location_reset(location,LOC_REGISTER,def_cgsize(resultdef));
                location.register:=cg.getintregister(current_asmdata.CurrAsmList,location.size);
                current_asmdata.getjumplabel(hlabel);
                cg.a_label(current_asmdata.CurrAsmList,current_procinfo.CurrTrueLabel);
                if not(is_cbool(resultdef)) then
                  cg.a_load_const_reg(current_asmdata.CurrAsmList,location.size,1,location.register)
                else
                  cg.a_load_const_reg(current_asmdata.CurrAsmList,location.size,-1,location.register);
                cg.a_jmp_always(current_asmdata.CurrAsmList,hlabel);
                cg.a_label(current_asmdata.CurrAsmList,current_procinfo.CurrFalseLabel);
                cg.a_load_const_reg(current_asmdata.CurrAsmList,location.size,0,location.register);
                cg.a_label(current_asmdata.CurrAsmList,hlabel);
              end;
            else
             internalerror(200512182);
         end;
         if left.location.loc<>LOC_JUMP then
           begin
             cg.g_flags2reg(current_asmdata.CurrAsmList,location.size,resflags,hreg1);
             if (is_cbool(resultdef)) then
               cg.a_op_reg_reg(current_asmdata.CurrAsmList,OP_NEG,location.size,hreg1,hreg1);
             location.register := hreg1;
           end;
         current_procinfo.CurrTrueLabel:=oldTrueLabel;
         current_procinfo.CurrFalseLabel:=oldFalseLabel;
      end;

{
    procedure tm68ktypeconvnode.pass_generate_code;
{$ifdef TESTOBJEXT2}
      var
         r : preference;
         nillabel : plabel;
{$endif TESTOBJEXT2}
      begin
         { this isn't good coding, I think tc_bool_2_int, shouldn't be }
         { type conversion (FK)                                 }

         if not(convtype in [tc_bool_2_int,tc_bool_2_bool]) then
           begin
              secondpass(left);
              location_copy(location,left.location);
              if codegenerror then
               exit;
           end;
         second_call_helper(convtype);
      end;
}

begin
   ctypeconvnode:=tm68ktypeconvnode;
end.
