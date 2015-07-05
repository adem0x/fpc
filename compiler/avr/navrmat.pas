{
    Copyright (c) 1998-2008 by Florian Klaempfl

    Generates AVR assembler for math nodes

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
unit navrmat;

{$i fpcdefs.inc}

interface

    uses
      node,nmat,ncgmat;

    type
      tavrnotnode = class(tcgnotnode)
        procedure second_boolean;override;
      end;

      tavrshlshrnode = class(tcgshlshrnode)
        procedure second_integer;override;
      end;

implementation

    uses
      globtype,systems,
      cutils,verbose,globals,constexp,
      symtype,symdef,
      aasmbase,aasmcpu,aasmtai,aasmdata,
      defutil,
      cgbase,cgobj,hlcgobj,cgutils,
      pass_2,procinfo,
      ncon,
      cpubase,
      ncgutil,cgcpu;

{*****************************************************************************
                               TAVRNOTNODE
*****************************************************************************}

    procedure tavrnotnode.second_boolean;
      var
        hl : tasmlabel;
        tmpreg : tregister;
        i : longint;
      begin
        { if the location is LOC_JUMP, we do the secondpass after the
          labels are allocated
        }
        if left.expectloc=LOC_JUMP then
          begin
            hl:=current_procinfo.CurrTrueLabel;
            current_procinfo.CurrTrueLabel:=current_procinfo.CurrFalseLabel;
            current_procinfo.CurrFalseLabel:=hl;
            secondpass(left);

            if left.location.loc<>LOC_JUMP then
              internalerror(2012081304);

            maketojumpbool(current_asmdata.CurrAsmList,left,lr_load_regvars);
            hl:=current_procinfo.CurrTrueLabel;
            current_procinfo.CurrTrueLabel:=current_procinfo.CurrFalseLabel;
            current_procinfo.CurrFalseLabel:=hl;
            location.loc:=LOC_JUMP;
          end
        else
          begin
            secondpass(left);
            case left.location.loc of
              LOC_FLAGS :
                begin
                  location_copy(location,left.location);
                  inverse_flags(location.resflags);
                end;
              LOC_REGISTER,LOC_CREGISTER,LOC_REFERENCE,LOC_CREFERENCE,
              LOC_SUBSETREG,LOC_CSUBSETREG,LOC_SUBSETREF,LOC_CSUBSETREF :
                begin
                  hlcg.location_force_reg(current_asmdata.CurrAsmList,left.location,left.resultdef,left.resultdef,true);
                  current_asmdata.CurrAsmList.concat(taicpu.op_reg_const(A_CPI,left.location.register,0));
                  tmpreg:=left.location.register;

                  { avr has no cpci, so we use the first register as "zero" register }
                  for i:=2 to tcgsize2size[left.location.size] do
                    begin
                      current_asmdata.CurrAsmList.concat(taicpu.op_reg_reg(A_CPC,tmpreg,left.location.register));
                    end;
                  location_reset(location,LOC_FLAGS,OS_NO);
                  location.resflags:=F_EQ;
               end;
              else
                internalerror(2003042401);
            end;
          end;
      end;


    procedure tavrshlshrnode.second_integer;
      var
         op : topcg;
         opdef: tdef;
         hcountreg : tregister;
         opsize : tcgsize;
         shiftval : longint;
      begin
        { determine operator }
        case nodetype of
          shln: op:=OP_SHL;
          shrn: op:=OP_SHR;
          else
            internalerror(2013120102);
        end;
        opsize:=left.location.size;
        opdef:=left.resultdef;

        if not(left.location.loc in [LOC_CREGISTER,LOC_REGISTER]) or
          { location_force_reg can be also used to change the size of a register }
          (left.location.size<>opsize) then
          hlcg.location_force_reg(current_asmdata.CurrAsmList,left.location,left.resultdef,opdef,true);
        location_reset(location,LOC_REGISTER,opsize);
        location.register:=hlcg.getintregister(current_asmdata.CurrAsmList,resultdef);

        { shifting by a constant directly coded: }
        if (right.nodetype=ordconstn) then
          begin
             { shl/shr must "wrap around", so use ... and 31 }
             { In TP, "byte/word shl 16 = 0", so no "and 15" in case of
               a 16 bit ALU }
             if tcgsize2size[opsize]<=4 then
               shiftval:=tordconstnode(right).value.uvalue and 31
             else
               shiftval:=tordconstnode(right).value.uvalue and 63;
             hlcg.a_op_const_reg_reg(current_asmdata.CurrAsmList,op,opdef,
               shiftval,left.location.register,location.register);
          end
        else
          begin
             { load right operators in a register - this
               is done since most target cpu which will use this
               node do not support a shift count in a mem. location (cec)
             }
             hlcg.location_force_reg(current_asmdata.CurrAsmList,right.location,right.resultdef,sinttype,true);
             hlcg.a_op_reg_reg_reg(current_asmdata.CurrAsmList,op,opdef,right.location.register,left.location.register,location.register);
          end;
        { shl/shr nodes return the same type as left, which can be different
          from opdef }
        if opdef<>resultdef then
          begin
            hcountreg:=hlcg.getintregister(current_asmdata.CurrAsmList,resultdef);
            hlcg.a_load_reg_reg(current_asmdata.CurrAsmList,opdef,resultdef,location.register,hcountreg);
            location.register:=hcountreg;
          end;
      end;

begin
  cnotnode:=tavrnotnode;
  cshlshrnode:=tavrshlshrnode;
end.
