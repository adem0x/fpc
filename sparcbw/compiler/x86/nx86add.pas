{
    Copyright (c) 2000-2002 by Florian Klaempfl

    Common code generation for add nodes on the i386 and x86

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
unit nx86add;

{$i fpcdefs.inc}

  interface

    uses
      cgbase,
      cpubase,
      node,nadd,ncgadd;

    type
      tx86addnode = class(tcgaddnode)
      protected
        function  getresflags(unsigned : boolean) : tresflags;
        procedure left_must_be_reg(opsize:TCGSize;noswap:boolean);
        procedure left_and_right_must_be_fpureg;
        procedure emit_op_right_left(op:TAsmOp;opsize:TCgSize);
        procedure emit_generic_code(op:TAsmOp;opsize:TCgSize;unsigned,extra_not,mboverflow:boolean);

        procedure second_cmpfloatsse;
        procedure second_addfloatsse;
        procedure second_mul;virtual;abstract;
      public
        procedure second_addfloat;override;
        procedure second_addsmallset;override;
        procedure second_add64bit;override;
        procedure second_addordinal;override;
        procedure second_cmpfloat;override;
        procedure second_cmpsmallset;override;
        procedure second_cmp64bit;override;
        procedure second_cmpordinal;override;
      end;


  implementation

    uses
      globtype,globals,
      verbose,cutils,
      cpuinfo,
      aasmbase,aasmtai,aasmcpu,
      symconst,
      cgobj,cgx86,cga,cgutils,
      paramgr,tgobj,ncgutil,
      ncon,nset,
      defutil;


{*****************************************************************************
                                  Helpers
*****************************************************************************}

    procedure tx86addnode.emit_generic_code(op:TAsmOp;opsize:TCGSize;unsigned,extra_not,mboverflow:boolean);
      var
        power : longint;
        hl4   : tasmlabel;
        r     : Tregister;
      begin
        { at this point, left.location.loc should be LOC_REGISTER }
        if right.location.loc=LOC_REGISTER then
         begin
           { right.location is a LOC_REGISTER }
           { when swapped another result register }
           if (nodetype=subn) and (nf_swaped in flags) then
            begin
              if extra_not then
               emit_reg(A_NOT,TCGSize2Opsize[opsize],left.location.register);
              emit_reg_reg(op,TCGSize2Opsize[opsize],left.location.register,right.location.register);
              { newly swapped also set swapped flag }
              location_swap(left.location,right.location);
              toggleflag(nf_swaped);
            end
           else
            begin
              if extra_not then
                emit_reg(A_NOT,TCGSize2Opsize[opsize],right.location.register);
              if (op=A_ADD) or (op=A_OR) or (op=A_AND) or (op=A_XOR) or (op=A_IMUL) then
                location_swap(left.location,right.location);
              emit_reg_reg(op,TCGSize2Opsize[opsize],right.location.register,left.location.register);
            end;
         end
        else
         begin
           { right.location is not a LOC_REGISTER }
           if (nodetype=subn) and (nf_swaped in flags) then
            begin
              if extra_not then
                cg.a_op_reg_reg(exprasmlist,OP_NOT,opsize,left.location.register,left.location.register);
              r:=cg.getintregister(exprasmlist,opsize);
              cg.a_load_loc_reg(exprasmlist,opsize,right.location,r);
              emit_reg_reg(op,TCGSize2Opsize[opsize],left.location.register,r);
              cg.a_load_reg_reg(exprasmlist,opsize,opsize,r,left.location.register);
            end
           else
            begin
               { Optimizations when right.location is a constant value }
               if (op=A_CMP) and
                  (nodetype in [equaln,unequaln]) and
                  (right.location.loc=LOC_CONSTANT) and
                  (right.location.value=0) then
                 begin
                   emit_reg_reg(A_TEST,TCGSize2Opsize[opsize],left.location.register,left.location.register);
                 end
               else
                 if (op=A_ADD) and
                    (right.location.loc=LOC_CONSTANT) and
                    (right.location.value=1) and
                    not(cs_check_overflow in aktlocalswitches) then
                  begin
                    emit_reg(A_INC,TCGSize2Opsize[opsize],left.location.register);
                  end
               else
                 if (op=A_SUB) and
                    (right.location.loc=LOC_CONSTANT) and
                    (right.location.value=1) and
                    not(cs_check_overflow in aktlocalswitches) then
                  begin
                    emit_reg(A_DEC,TCGSize2Opsize[opsize],left.location.register);
                  end
               else
                 if (op=A_IMUL) and
                    (right.location.loc=LOC_CONSTANT) and
                    (ispowerof2(int64(right.location.value),power)) and
                    not(cs_check_overflow in aktlocalswitches) then
                  begin
                    emit_const_reg(A_SHL,TCGSize2Opsize[opsize],power,left.location.register);
                  end
               else
                 begin
                   if extra_not then
                     begin
                        r:=cg.getintregister(exprasmlist,opsize);
                        cg.a_load_loc_reg(exprasmlist,opsize,right.location,r);
                        emit_reg(A_NOT,TCGSize2Opsize[opsize],r);
                        emit_reg_reg(A_AND,TCGSize2Opsize[opsize],r,left.location.register);
                     end
                   else
                     begin
                        emit_op_right_left(op,opsize);
                     end;
                 end;
            end;
         end;

        { only in case of overflow operations }
        { produce overflow code }
        { we must put it here directly, because sign of operation }
        { is in unsigned VAR!!                                   }
        if mboverflow then
         begin
           if cs_check_overflow in aktlocalswitches  then
            begin
              objectlibrary.getlabel(hl4);
              if unsigned then
                cg.a_jmp_flags(exprasmlist,F_AE,hl4)
              else
                cg.a_jmp_flags(exprasmlist,F_NO,hl4);
              cg.a_call_name(exprasmlist,'FPC_OVERFLOW');
              cg.a_label(exprasmlist,hl4);
            end;
         end;
      end;


    procedure tx86addnode.left_must_be_reg(opsize:TCGSize;noswap:boolean);
      begin
        { left location is not a register? }
        if (left.location.loc<>LOC_REGISTER) then
         begin
           { if right is register then we can swap the locations }
           if (not noswap) and
              (right.location.loc=LOC_REGISTER) then
            begin
              location_swap(left.location,right.location);
              toggleflag(nf_swaped);
            end
           else
            begin
              { maybe we can reuse a constant register when the
                operation is a comparison that doesn't change the
                value of the register }
              location_force_reg(exprasmlist,left.location,opsize,(nodetype in [ltn,lten,gtn,gten,equaln,unequaln]));
            end;
          end;
       end;


    procedure tx86addnode.left_and_right_must_be_fpureg;
      begin
        if (right.location.loc<>LOC_FPUREGISTER) then
         begin
           cg.a_loadfpu_loc_reg(exprasmlist,right.location,NR_ST);
           if (right.location.loc <> LOC_CFPUREGISTER) then
             location_freetemp(exprasmlist,left.location);
           if (left.location.loc<>LOC_FPUREGISTER) then
            begin
              cg.a_loadfpu_loc_reg(exprasmlist,left.location,NR_ST);
              if (left.location.loc <> LOC_CFPUREGISTER) then
                location_freetemp(exprasmlist,left.location);
            end
           else
            begin
              { left was on the stack => swap }
              toggleflag(nf_swaped);
            end;
         end
        { the nominator in st0 }
        else if (left.location.loc<>LOC_FPUREGISTER) then
         begin
           cg.a_loadfpu_loc_reg(exprasmlist,left.location,NR_ST);
           if (left.location.loc <> LOC_CFPUREGISTER) then
             location_freetemp(exprasmlist,left.location);
         end
        else
         begin
           { fpu operands are always in the wrong order on the stack }
           toggleflag(nf_swaped);
         end;
      end;


    procedure tx86addnode.emit_op_right_left(op:TAsmOp;opsize:TCgsize);
{$ifdef x86_64}
      var
        tmpreg : tregister;
{$endif x86_64}
      begin
        { left must be a register }
        case right.location.loc of
          LOC_REGISTER,
          LOC_CREGISTER :
            exprasmlist.concat(taicpu.op_reg_reg(op,TCGSize2Opsize[opsize],right.location.register,left.location.register));
          LOC_REFERENCE,
          LOC_CREFERENCE :
            begin
              tcgx86(cg).make_simple_ref(exprasmlist,right.location.reference);
              exprasmlist.concat(taicpu.op_ref_reg(op,TCGSize2Opsize[opsize],right.location.reference,left.location.register));
            end;
          LOC_CONSTANT :
            begin
{$ifdef x86_64}
              { x86_64 only supports signed 32 bits constants directly }
              if (opsize in [OS_S64,OS_64]) and
                 ((right.location.value<low(longint)) or (right.location.value>high(longint))) then
                begin
                  tmpreg:=cg.getintregister(exprasmlist,opsize);
                  cg.a_load_const_reg(exprasmlist,opsize,right.location.value,tmpreg);
                  exprasmlist.concat(taicpu.op_reg_reg(op,TCGSize2Opsize[opsize],tmpreg,left.location.register));
                end
              else
{$endif x86_64}
                exprasmlist.concat(taicpu.op_const_reg(op,TCGSize2Opsize[opsize],right.location.value,left.location.register));
            end;
          else
            internalerror(200203232);
        end;
      end;


    function tx86addnode.getresflags(unsigned : boolean) : tresflags;
      begin
         case nodetype of
           equaln : getresflags:=F_E;
           unequaln : getresflags:=F_NE;
          else
           if not(unsigned) then
             begin
                if nf_swaped in flags then
                  case nodetype of
                     ltn : getresflags:=F_G;
                     lten : getresflags:=F_GE;
                     gtn : getresflags:=F_L;
                     gten : getresflags:=F_LE;
                  end
                else
                  case nodetype of
                     ltn : getresflags:=F_L;
                     lten : getresflags:=F_LE;
                     gtn : getresflags:=F_G;
                     gten : getresflags:=F_GE;
                  end;
             end
           else
             begin
                if nf_swaped in flags then
                  case nodetype of
                     ltn : getresflags:=F_A;
                     lten : getresflags:=F_AE;
                     gtn : getresflags:=F_B;
                     gten : getresflags:=F_BE;
                  end
                else
                  case nodetype of
                     ltn : getresflags:=F_B;
                     lten : getresflags:=F_BE;
                     gtn : getresflags:=F_A;
                     gten : getresflags:=F_AE;
                  end;
             end;
         end;
      end;


{*****************************************************************************
                                AddSmallSet
*****************************************************************************}

    procedure tx86addnode.second_addsmallset;
      var
        opsize : TCGSize;
        op     : TAsmOp;
        extra_not,
        noswap : boolean;
      begin
        pass_left_right;

        noswap:=false;
        extra_not:=false;
        opsize:=OS_32;
        case nodetype of
          addn :
            begin
              { this is a really ugly hack!!!!!!!!!! }
              { this could be done later using EDI   }
              { as it is done for subn               }
              { instead of two registers!!!!         }
              { adding elements is not commutative }
              if (nf_swaped in flags) and (left.nodetype=setelementn) then
               swapleftright;
              { are we adding set elements ? }
              if right.nodetype=setelementn then
               begin
                 { no range support for smallsets! }
                 if assigned(tsetelementnode(right).right) then
                  internalerror(43244);
                 { bts requires both elements to be registers }
                 location_force_reg(exprasmlist,left.location,opsize,false);
                 location_force_reg(exprasmlist,right.location,opsize,true);
                 op:=A_BTS;
                 noswap:=true;
               end
              else
               op:=A_OR;
            end;
          symdifn :
            op:=A_XOR;
          muln :
            op:=A_AND;
          subn :
            begin
              op:=A_AND;
              if (not(nf_swaped in flags)) and
                 (right.location.loc=LOC_CONSTANT) then
                right.location.value := not(right.location.value)
              else if (nf_swaped in flags) and
                      (left.location.loc=LOC_CONSTANT) then
                left.location.value := not(left.location.value)
              else
                extra_not:=true;
            end;
          xorn :
            op:=A_XOR;
          orn :
            op:=A_OR;
          andn :
            op:=A_AND;
          else
            internalerror(2003042215);
        end;
        { left must be a register }
        left_must_be_reg(opsize,noswap);
        emit_generic_code(op,opsize,true,extra_not,false);
        location_freetemp(exprasmlist,right.location);

        set_result_location_reg;
      end;


    procedure tx86addnode.second_cmpsmallset;
      var
        opsize : TCGSize;
        op     : TAsmOp;
      begin
        pass_left_right;
        opsize:=OS_32;
        case nodetype of
          equaln,
          unequaln :
            op:=A_CMP;
          lten,gten:
            begin
              if (not(nf_swaped in flags) and (nodetype = lten)) or
                 ((nf_swaped in flags) and (nodetype = gten)) then
                swapleftright;
              location_force_reg(exprasmlist,left.location,opsize,true);
              emit_op_right_left(A_AND,opsize);
              op:=A_CMP;
              { warning: ugly hack, we need a JE so change the node to equaln }
              nodetype:=equaln;
            end;
          else
            internalerror(2003042215);
        end;
        { left must be a register }
        left_must_be_reg(opsize,false);
        emit_generic_code(op,opsize,true,false,false);
        location_freetemp(exprasmlist,right.location);
        location_freetemp(exprasmlist,left.location);

        location_reset(location,LOC_FLAGS,OS_NO);
        location.resflags:=getresflags(true);
      end;


{*****************************************************************************
                                AddFloat
*****************************************************************************}

    procedure tx86addnode.second_addfloatsse;
      var
        op : topcg;
      begin
        pass_left_right;
        if (nf_swaped in flags) then
          swapleftright;

        case nodetype of
          addn :
            op:=OP_ADD;
          muln :
            op:=OP_MUL;
          subn :
            op:=OP_SUB;
          slashn :
            op:=OP_DIV;
          else
            internalerror(200312231);
        end;

        location_reset(location,LOC_MMREGISTER,def_cgsize(resulttype.def));
        { we can use only right as left operand if the operation is commutative }
        if (right.location.loc=LOC_MMREGISTER) and (op in [OP_ADD,OP_MUL]) then
          begin
            location.register:=right.location.register;
            { force floating point reg. location to be written to memory,
              we don't force it to mm register because writing to memory
              allows probably shorter code because there is no direct fpu->mm register
              copy instruction
            }
            if left.location.loc in [LOC_FPUREGISTER,LOC_CFPUREGISTER] then
              location_force_mem(exprasmlist,left.location);
            cg.a_opmm_loc_reg(exprasmlist,op,location.size,left.location,location.register,mms_movescalar);
          end
        else
          begin
            location_force_mmregscalar(exprasmlist,left.location,false);
            location.register:=left.location.register;
            { force floating point reg. location to be written to memory,
              we don't force it to mm register because writing to memory
              allows probably shorter code because there is no direct fpu->mm register
              copy instruction
            }
            if right.location.loc in [LOC_FPUREGISTER,LOC_CFPUREGISTER] then
              location_force_mem(exprasmlist,right.location);
            cg.a_opmm_loc_reg(exprasmlist,op,location.size,right.location,location.register,mms_movescalar);
          end;
      end;


    procedure tx86addnode.second_cmpfloatsse;
      var
        op : tasmop;
      begin
        if is_single(left.resulttype.def) then
          op:=A_COMISS
        else if is_double(left.resulttype.def) then
          op:=A_COMISD
        else
          internalerror(200402222);
        pass_left_right;

        location_reset(location,LOC_FLAGS,def_cgsize(resulttype.def));
        { we can use only right as left operand if the operation is commutative }
        if (right.location.loc=LOC_MMREGISTER) then
          begin
            { force floating point reg. location to be written to memory,
              we don't force it to mm register because writing to memory
              allows probably shorter code because there is no direct fpu->mm register
              copy instruction
            }
            if left.location.loc in [LOC_FPUREGISTER,LOC_CFPUREGISTER] then
              location_force_mem(exprasmlist,left.location);
            case left.location.loc of
              LOC_REFERENCE,LOC_CREFERENCE:
                begin
                  tcgx86(cg).make_simple_ref(exprasmlist,left.location.reference);
                  exprasmlist.concat(taicpu.op_ref_reg(op,S_NO,left.location.reference,right.location.register));
                end;
              LOC_MMREGISTER,LOC_CMMREGISTER:
                exprasmlist.concat(taicpu.op_reg_reg(op,S_NO,left.location.register,right.location.register));
              else
                internalerror(200402221);
            end;
            if nf_swaped in flags then
              exclude(flags,nf_swaped)
            else
              include(flags,nf_swaped)
          end
        else
          begin
            location_force_mmregscalar(exprasmlist,left.location,false);
            { force floating point reg. location to be written to memory,
              we don't force it to mm register because writing to memory
              allows probably shorter code because there is no direct fpu->mm register
              copy instruction
            }
            if right.location.loc in [LOC_FPUREGISTER,LOC_CFPUREGISTER] then
              location_force_mem(exprasmlist,right.location);
            case right.location.loc of
              LOC_REFERENCE,LOC_CREFERENCE:
                begin
                  tcgx86(cg).make_simple_ref(exprasmlist,right.location.reference);
                  exprasmlist.concat(taicpu.op_ref_reg(op,S_NO,right.location.reference,left.location.register));
                end;
              LOC_MMREGISTER,LOC_CMMREGISTER:
                exprasmlist.concat(taicpu.op_reg_reg(op,S_NO,right.location.register,left.location.register));
              else
                internalerror(200402223);
            end;
          end;
        location.resflags:=getresflags(true);
      end;


    procedure tx86addnode.second_addfloat;
      var
        op : TAsmOp;
      begin
        if use_sse(resulttype.def) then
          begin
            second_addfloatsse;
            exit;
          end;

        pass_left_right;

        case nodetype of
          addn :
            op:=A_FADDP;
          muln :
            op:=A_FMULP;
          subn :
            op:=A_FSUBP;
          slashn :
            op:=A_FDIVP;
          else
            internalerror(2003042214);
        end;

        left_and_right_must_be_fpureg;

        { if we swaped the tree nodes, then use the reverse operator }
        if nf_swaped in flags then
          begin
             if (nodetype=slashn) then
               op:=A_FDIVRP
             else if (nodetype=subn) then
               op:=A_FSUBRP;
          end;

        emit_reg_reg(op,S_NO,NR_ST,NR_ST1);
        tcgx86(cg).dec_fpu_stack;

        location_reset(location,LOC_FPUREGISTER,def_cgsize(resulttype.def));
        location.register:=NR_ST;
      end;


    procedure tx86addnode.second_cmpfloat;
      var
        resflags   : tresflags;
      begin
        if use_sse(left.resulttype.def) or use_sse(right.resulttype.def) then
          begin
            second_cmpfloatsse;
            exit;
          end;

        pass_left_right;
        left_and_right_must_be_fpureg;

{$ifndef x86_64}
        if aktspecificoptprocessor<ClassPentium2 then
          begin
            emit_none(A_FCOMPP,S_NO);
            tcgx86(cg).dec_fpu_stack;
            tcgx86(cg).dec_fpu_stack;

            { load fpu flags }
            cg.getcpuregister(exprasmlist,NR_AX);
            emit_reg(A_FNSTSW,S_NO,NR_AX);
            emit_none(A_SAHF,S_NO);
            cg.ungetcpuregister(exprasmlist,NR_AX);
            if nf_swaped in flags then
             begin
               case nodetype of
                   equaln : resflags:=F_E;
                 unequaln : resflags:=F_NE;
                      ltn : resflags:=F_A;
                     lten : resflags:=F_AE;
                      gtn : resflags:=F_B;
                     gten : resflags:=F_BE;
               end;
             end
            else
             begin
               case nodetype of
                   equaln : resflags:=F_E;
                 unequaln : resflags:=F_NE;
                      ltn : resflags:=F_B;
                     lten : resflags:=F_BE;
                      gtn : resflags:=F_A;
                     gten : resflags:=F_AE;
               end;
             end;
          end
        else
{$endif x86_64}
          begin
            exprasmlist.concat(taicpu.op_reg_reg(A_FCOMIP,S_NO,NR_ST1,NR_ST0));
            { fcomip pops only one fpu register }
            exprasmlist.concat(taicpu.op_reg(A_FSTP,S_NO,NR_ST0));
            tcgx86(cg).dec_fpu_stack;
            tcgx86(cg).dec_fpu_stack;

            { load fpu flags }
            if nf_swaped in flags then
             begin
               case nodetype of
                   equaln : resflags:=F_E;
                 unequaln : resflags:=F_NE;
                      ltn : resflags:=F_A;
                     lten : resflags:=F_AE;
                      gtn : resflags:=F_B;
                     gten : resflags:=F_BE;
               end;
             end
            else
             begin
               case nodetype of
                   equaln : resflags:=F_E;
                 unequaln : resflags:=F_NE;
                      ltn : resflags:=F_B;
                     lten : resflags:=F_BE;
                      gtn : resflags:=F_A;
                     gten : resflags:=F_AE;
               end;
             end;
          end;

        location_reset(location,LOC_FLAGS,OS_NO);
        location.resflags:=resflags;
      end;


{*****************************************************************************
                                  Add64bit
*****************************************************************************}

    procedure tx86addnode.second_add64bit;
      begin
{$ifdef cpu64bit}
        second_addordinal;
{$else cpu64bit}
        { must be implemented separate }
        internalerror(200402042);
{$endif cpu64bit}
      end;


    procedure tx86addnode.second_cmp64bit;
      begin
{$ifdef cpu64bit}
        second_cmpordinal;
{$else cpu64bit}
        { must be implemented separate }
        internalerror(200402043);
{$endif cpu64bit}
      end;


{*****************************************************************************
                                  AddOrdinal
*****************************************************************************}

    procedure tx86addnode.second_addordinal;
      var
         mboverflow : boolean;
         op : tasmop;
         opsize : tcgsize;
         { true, if unsigned types are compared }
         unsigned : boolean;
         { true, if for sets subtractions the extra not should generated }
         extra_not : boolean;
      begin
         { defaults }
         extra_not:=false;
         mboverflow:=false;
         unsigned:=not(is_signed(left.resulttype.def)) or
                   not(is_signed(right.resulttype.def));
         opsize:=def_cgsize(left.resulttype.def);

         pass_left_right;

         case nodetype of
           addn :
             begin
               op:=A_ADD;
               mboverflow:=true;
             end;
           muln :
             begin
               if unsigned then
                 op:=A_MUL
               else
                 op:=A_IMUL;
               mboverflow:=true;
             end;
           subn :
             begin
               op:=A_SUB;
               mboverflow:=true;
             end;
           xorn :
             op:=A_XOR;
           orn :
             op:=A_OR;
           andn :
             op:=A_AND;
           else
             internalerror(200304229);
         end;

         { filter MUL, which requires special handling }
         if op=A_MUL then
           begin
             second_mul;
             exit;
           end;

         left_must_be_reg(opsize,false);
         emit_generic_code(op,opsize,unsigned,extra_not,mboverflow);
         location_freetemp(exprasmlist,right.location);

         set_result_location_reg;
      end;


    procedure tx86addnode.second_cmpordinal;
      var
         opsize : tcgsize;
         unsigned : boolean;
      begin
         unsigned:=not(is_signed(left.resulttype.def)) or
                   not(is_signed(right.resulttype.def));
         opsize:=def_cgsize(left.resulttype.def);

         pass_left_right;

         left_must_be_reg(opsize,false);
         emit_generic_code(A_CMP,opsize,unsigned,false,false);
         location_freetemp(exprasmlist,right.location);
         location_freetemp(exprasmlist,left.location);

         location_reset(location,LOC_FLAGS,OS_NO);
         location.resflags:=getresflags(unsigned);
      end;

begin
   caddnode:=tx86addnode;
end.
