{

    Copyright (c) 2003 by Florian Klaempfl
    Member of the Free Pascal development team

    This unit implements the code generator for the ARM

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
unit cgcpu;

{$i fpcdefs.inc}

  interface

    uses
       globtype,symtype,symdef,
       cgbase,cgutils,cgobj,
       aasmbase,aasmcpu,aasmtai,
       parabase,
       cpubase,cpuinfo,node,cg64f32,rgcpu;


    type
      tcgarm = class(tcg)
        { true, if the next arithmetic operation should modify the flags }
        cgsetflags : boolean;
        procedure init_register_allocators;override;
        procedure done_register_allocators;override;

        procedure a_param_const(list : taasmoutput;size : tcgsize;a : aint;const paraloc : TCGPara);override;
        procedure a_param_ref(list : taasmoutput;size : tcgsize;const r : treference;const paraloc : TCGPara);override;
        procedure a_paramaddr_ref(list : taasmoutput;const r : treference;const paraloc : TCGPara);override;

        procedure a_call_name(list : taasmoutput;const s : string);override;
        procedure a_call_reg(list : taasmoutput;reg: tregister); override;

        procedure a_op_const_reg(list : taasmoutput; Op: TOpCG; size: TCGSize; a: aint; reg: TRegister); override;
        procedure a_op_reg_reg(list : taasmoutput; Op: TOpCG; size: TCGSize; src, dst: TRegister); override;

        procedure a_op_const_reg_reg(list: taasmoutput; op: TOpCg;
          size: tcgsize; a: aint; src, dst: tregister); override;
        procedure a_op_reg_reg_reg(list: taasmoutput; op: TOpCg;
          size: tcgsize; src1, src2, dst: tregister); override;
        procedure a_op_const_reg_reg_checkoverflow(list: taasmoutput; op: TOpCg; size: tcgsize; a: aint; src, dst: tregister;setflags : boolean;var ovloc : tlocation);override;
        procedure a_op_reg_reg_reg_checkoverflow(list: taasmoutput; op: TOpCg; size: tcgsize; src1, src2, dst: tregister;setflags : boolean;var ovloc : tlocation);override;

        { move instructions }
        procedure a_load_const_reg(list : taasmoutput; size: tcgsize; a : aint;reg : tregister);override;
        procedure a_load_reg_ref(list : taasmoutput; fromsize, tosize: tcgsize; reg : tregister;const ref : treference);override;
        procedure a_load_ref_reg(list : taasmoutput; fromsize, tosize : tcgsize;const Ref : treference;reg : tregister);override;
        procedure a_load_reg_reg(list : taasmoutput; fromsize, tosize : tcgsize;reg1,reg2 : tregister);override;

        { fpu move instructions }
        procedure a_loadfpu_reg_reg(list: taasmoutput; size: tcgsize; reg1, reg2: tregister); override;
        procedure a_loadfpu_ref_reg(list: taasmoutput; size: tcgsize; const ref: treference; reg: tregister); override;
        procedure a_loadfpu_reg_ref(list: taasmoutput; size: tcgsize; reg: tregister; const ref: treference); override;

        {  comparison operations }
        procedure a_cmp_const_reg_label(list : taasmoutput;size : tcgsize;cmp_op : topcmp;a : aint;reg : tregister;
          l : tasmlabel);override;
        procedure a_cmp_reg_reg_label(list : taasmoutput;size : tcgsize;cmp_op : topcmp;reg1,reg2 : tregister;l : tasmlabel); override;

        procedure a_jmp_name(list : taasmoutput;const s : string); override;
        procedure a_jmp_always(list : taasmoutput;l: tasmlabel); override;
        procedure a_jmp_flags(list : taasmoutput;const f : TResFlags;l: tasmlabel); override;

        procedure g_flags2reg(list: taasmoutput; size: TCgSize; const f: TResFlags; reg: TRegister); override;

        procedure g_proc_entry(list : taasmoutput;localsize : longint;nostackframe:boolean);override;
        procedure g_proc_exit(list : taasmoutput;parasize : longint;nostackframe:boolean); override;

        procedure a_loadaddr_ref_reg(list : taasmoutput;const ref : treference;r : tregister);override;

        procedure g_concatcopy(list : taasmoutput;const source,dest : treference;len : aint);override;
        procedure g_concatcopy_unaligned(list : taasmoutput;const source,dest : treference;len : aint);override;
        procedure g_concatcopy_move(list : taasmoutput;const source,dest : treference;len : aint);
        procedure g_concatcopy_internal(list : taasmoutput;const source,dest : treference;len : aint;aligned : boolean);

        procedure g_overflowcheck(list: taasmoutput; const l: tlocation; def: tdef); override;
        procedure g_overflowCheck_loc(List:TAasmOutput;const Loc:TLocation;def:TDef;ovloc : tlocation);override;

        procedure g_save_standard_registers(list : taasmoutput);override;
        procedure g_restore_standard_registers(list : taasmoutput);override;

        procedure a_jmp_cond(list : taasmoutput;cond : TOpCmp;l: tasmlabel);
        procedure fixref(list : taasmoutput;var ref : treference);
        procedure handle_load_store(list:taasmoutput;op: tasmop;oppostfix : toppostfix;reg:tregister;ref: treference);

        procedure g_intf_wrapper(list: taasmoutput; procdef: tprocdef; const labelname: string; ioffset: longint);override;
      end;

      tcg64farm = class(tcg64f32)
        procedure a_op64_reg_reg(list : taasmoutput;op:TOpCG;size : tcgsize;regsrc,regdst : tregister64);override;
        procedure a_op64_const_reg(list : taasmoutput;op:TOpCG;size : tcgsize;value : int64;reg : tregister64);override;
        procedure a_op64_const_reg_reg(list: taasmoutput;op:TOpCG;size : tcgsize;value : int64;regsrc,regdst : tregister64);override;
        procedure a_op64_reg_reg_reg(list: taasmoutput;op:TOpCG;size : tcgsize;regsrc1,regsrc2,regdst : tregister64);override;
        procedure a_op64_const_reg_reg_checkoverflow(list: taasmoutput;op:TOpCG;size : tcgsize;value : int64;regsrc,regdst : tregister64;setflags : boolean;var ovloc : tlocation);override;
        procedure a_op64_reg_reg_reg_checkoverflow(list: taasmoutput;op:TOpCG;size : tcgsize;regsrc1,regsrc2,regdst : tregister64;setflags : boolean;var ovloc : tlocation);override;
      end;

    const
      OpCmp2AsmCond : Array[topcmp] of TAsmCond = (C_NONE,C_EQ,C_GT,
                           C_LT,C_GE,C_LE,C_NE,C_LS,C_CC,C_CS,C_HI);

    function is_shifter_const(d : aint;var imm_shift : byte) : boolean;

    function get_fpu_postfix(def : tdef) : toppostfix;

  implementation


    uses
       globals,verbose,systems,cutils,
       fmodule,
       symconst,symsym,
       tgobj,
       procinfo,cpupi,
       paramgr;


    function get_fpu_postfix(def : tdef) : toppostfix;
      begin
        if def.deftype=floatdef then
          begin
            case tfloatdef(def).typ of
              s32real:
                result:=PF_S;
              s64real:
                result:=PF_D;
              s80real:
                result:=PF_E;
              else
                internalerror(200401272);
            end;
          end
        else
          internalerror(200401271);
      end;


    procedure tcgarm.init_register_allocators;
      begin
        inherited init_register_allocators;
        { currently, we save R14 always, so we can use it }
        rg[R_INTREGISTER]:=trgintcpu.create(R_INTREGISTER,R_SUBWHOLE,
            [RS_R0,RS_R1,RS_R2,RS_R3,RS_R4,RS_R5,RS_R6,RS_R7,RS_R8,
             RS_R9,RS_R10,RS_R12,RS_R14],first_int_imreg,[]);
        rg[R_FPUREGISTER]:=trgcpu.create(R_FPUREGISTER,R_SUBNONE,
            [RS_F0,RS_F1,RS_F2,RS_F3,RS_F4,RS_F5,RS_F6,RS_F7],first_fpu_imreg,[]);
        rg[R_MMREGISTER]:=trgcpu.create(R_MMREGISTER,R_SUBNONE,
            [RS_S0,RS_S1,RS_R2,RS_R3,RS_R4,RS_S31],first_mm_imreg,[]);
      end;


    procedure tcgarm.done_register_allocators;
      begin
        rg[R_INTREGISTER].free;
        rg[R_FPUREGISTER].free;
        rg[R_MMREGISTER].free;
        inherited done_register_allocators;
      end;


    procedure tcgarm.a_param_const(list : taasmoutput;size : tcgsize;a : aint;const paraloc : TCGPara);
      var
        ref: treference;
      begin
        paraloc.check_simple_location;
        case paraloc.location^.loc of
          LOC_REGISTER,LOC_CREGISTER:
            a_load_const_reg(list,size,a,paraloc.location^.register);
          LOC_REFERENCE:
            begin
               reference_reset(ref);
               ref.base:=paraloc.location^.reference.index;
               ref.offset:=paraloc.location^.reference.offset;
               a_load_const_ref(list,size,a,ref);
            end;
          else
            internalerror(2002081101);
        end;
      end;


    procedure tcgarm.a_param_ref(list : taasmoutput;size : tcgsize;const r : treference;const paraloc : TCGPara);
      var
        ref: treference;
        tmpreg: tregister;
      begin
        paraloc.check_simple_location;
        case paraloc.location^.loc of
          LOC_REGISTER,LOC_CREGISTER:
            a_load_ref_reg(list,size,size,r,paraloc.location^.register);
          LOC_REFERENCE:
            begin
               reference_reset(ref);
               ref.base:=paraloc.location^.reference.index;
               ref.offset:=paraloc.location^.reference.offset;
               tmpreg := getintregister(list,size);
               a_load_ref_reg(list,size,size,r,tmpreg);
               a_load_reg_ref(list,size,size,tmpreg,ref);
            end;
          LOC_FPUREGISTER,LOC_CFPUREGISTER:
            case size of
               OS_F32, OS_F64:
                 a_loadfpu_ref_reg(list,size,r,paraloc.location^.register);
               else
                 internalerror(2002072801);
            end;
          else
            internalerror(2002081103);
        end;
      end;


    procedure tcgarm.a_paramaddr_ref(list : taasmoutput;const r : treference;const paraloc : TCGPara);
      var
        ref: treference;
        tmpreg: tregister;
      begin
        paraloc.check_simple_location;
         case paraloc.location^.loc of
            LOC_REGISTER,LOC_CREGISTER:
              a_loadaddr_ref_reg(list,r,paraloc.location^.register);
            LOC_REFERENCE:
              begin
                reference_reset(ref);
                ref.base := paraloc.location^.reference.index;
                ref.offset := paraloc.location^.reference.offset;
                tmpreg := getintregister(list,OS_ADDR);
                a_loadaddr_ref_reg(list,r,tmpreg);
                a_load_reg_ref(list,OS_ADDR,OS_ADDR,tmpreg,ref);
              end;
            else
              internalerror(2002080701);
         end;
      end;


    procedure tcgarm.a_call_name(list : taasmoutput;const s : string);
      begin
        list.concat(taicpu.op_sym(A_BL,objectlibrary.newasmsymbol(s,AB_EXTERNAL,AT_FUNCTION)));
{
        the compiler does not properly set this flag anymore in pass 1, and
        for now we only need it after pass 2 (I hope) (JM)
          if not(pi_do_call in current_procinfo.flags) then
            internalerror(2003060703);
}
        include(current_procinfo.flags,pi_do_call);
      end;


    procedure tcgarm.a_call_reg(list : taasmoutput;reg: tregister);
      var
         r : tregister;
      begin
        list.concat(taicpu.op_reg_reg(A_MOV,NR_R14,NR_PC));
        list.concat(taicpu.op_reg_reg(A_MOV,NR_PC,reg));
{
        the compiler does not properly set this flag anymore in pass 1, and
        for now we only need it after pass 2 (I hope) (JM)
          if not(pi_do_call in current_procinfo.flags) then
            internalerror(2003060703);
}
        include(current_procinfo.flags,pi_do_call);
      end;


     procedure tcgarm.a_op_const_reg(list : taasmoutput; Op: TOpCG; size: TCGSize; a: aint; reg: TRegister);
       begin
          a_op_const_reg_reg(list,op,size,a,reg,reg);
       end;


     procedure tcgarm.a_op_reg_reg(list : taasmoutput; Op: TOpCG; size: TCGSize; src, dst: TRegister);
       begin
         case op of
           OP_NEG:
             list.concat(taicpu.op_reg_reg_const(A_RSB,dst,src,0));
           OP_NOT:
             begin
               list.concat(taicpu.op_reg_reg(A_MVN,dst,src));
               case size of
                 OS_8 :
                   a_op_const_reg_reg(list,OP_AND,OS_INT,$ff,dst,dst);
                 OS_16 :
                   a_op_const_reg_reg(list,OP_AND,OS_INT,$ffff,dst,dst);
               end;
             end
           else
             a_op_reg_reg_reg(list,op,OS_32,src,dst,dst);
         end;
       end;


    const
      op_reg_reg_opcg2asmop: array[TOpCG] of tasmop =
        (A_NONE,A_ADD,A_AND,A_NONE,A_NONE,A_MUL,A_MUL,A_NONE,A_NONE,A_ORR,
         A_NONE,A_NONE,A_NONE,A_SUB,A_EOR);


    procedure tcgarm.a_op_const_reg_reg(list: taasmoutput; op: TOpCg;
      size: tcgsize; a: aint; src, dst: tregister);
      var
        ovloc : tlocation;
      begin
        a_op_const_reg_reg_checkoverflow(list,op,size,a,src,dst,false,ovloc);
      end;


    procedure tcgarm.a_op_reg_reg_reg(list: taasmoutput; op: TOpCg;
      size: tcgsize; src1, src2, dst: tregister);
      var
        ovloc : tlocation;
      begin
        a_op_reg_reg_reg_checkoverflow(list,op,size,src1,src2,dst,false,ovloc);
      end;


    procedure tcgarm.a_op_const_reg_reg_checkoverflow(list: taasmoutput; op: TOpCg; size: tcgsize; a: aint; src, dst: tregister;setflags : boolean;var ovloc : tlocation);
      var
        shift : byte;
        tmpreg : tregister;
        so : tshifterop;
        l1 : longint;
      begin
        ovloc.loc:=LOC_VOID;
        if is_shifter_const(-a,shift) then
          case op of
            OP_ADD:
              begin
                op:=OP_SUB;
                a:=dword(-a);
              end;
            OP_SUB:
              begin
                op:=OP_ADD;
                a:=dword(-a);
              end
          end;

        if is_shifter_const(a,shift) and not(op in [OP_IMUL,OP_MUL]) then
          case op of
            OP_NEG,OP_NOT,
            OP_DIV,OP_IDIV:
              internalerror(200308281);
            OP_SHL:
              begin
                if a>32 then
                  internalerror(200308291);
                if a<>0 then
                  begin
                    shifterop_reset(so);
                    so.shiftmode:=SM_LSL;
                    so.shiftimm:=a;
                    list.concat(taicpu.op_reg_reg_shifterop(A_MOV,dst,src,so));
                  end
                else
                 list.concat(taicpu.op_reg_reg(A_MOV,dst,src));
              end;
            OP_SHR:
              begin
                if a>32 then
                  internalerror(200308292);
                shifterop_reset(so);
                if a<>0 then
                  begin
                    so.shiftmode:=SM_LSR;
                    so.shiftimm:=a;
                    list.concat(taicpu.op_reg_reg_shifterop(A_MOV,dst,src,so));
                  end
                else
                 list.concat(taicpu.op_reg_reg(A_MOV,dst,src));
              end;
            OP_SAR:
              begin
                if a>32 then
                  internalerror(200308291);
                if a<>0 then
                  begin
                    shifterop_reset(so);
                    so.shiftmode:=SM_ASR;
                    so.shiftimm:=a;
                    list.concat(taicpu.op_reg_reg_shifterop(A_MOV,dst,src,so));
                  end
                else
                 list.concat(taicpu.op_reg_reg(A_MOV,dst,src));
              end;
            else
              list.concat(setoppostfix(
                  taicpu.op_reg_reg_const(op_reg_reg_opcg2asmop[op],dst,src,a),toppostfix(ord(cgsetflags or setflags)*ord(PF_S))
              ));
              if (cgsetflags or setflags) and (size in [OS_8,OS_16,OS_32]) then
                begin
                  ovloc.loc:=LOC_FLAGS;
                  case op of
                    OP_ADD:
                      ovloc.resflags:=F_CS;
                    OP_SUB:
                      ovloc.resflags:=F_CC;
                  end;
                end;
          end
        else
          begin
            { there could be added some more sophisticated optimizations }
            if (op in [OP_MUL,OP_IMUL]) and (a=1) then
              a_load_reg_reg(list,size,size,src,dst)
            else if (op in [OP_MUL,OP_IMUL]) and (a=0) then
              a_load_const_reg(list,size,0,dst)
            else if (op in [OP_IMUL]) and (a=-1) then
              a_op_reg_reg(list,OP_NEG,size,src,dst)
            { we do this here instead in the peephole optimizer because
              it saves us a register }
            else if (op in [OP_MUL,OP_IMUL]) and ispowerof2(a,l1) and not(cgsetflags or setflags) then
              a_op_const_reg_reg(list,OP_SHL,size,l1,src,dst)
            else
              begin
                tmpreg:=getintregister(list,size);
                a_load_const_reg(list,size,a,tmpreg);
                a_op_reg_reg_reg_checkoverflow(list,op,size,tmpreg,src,dst,setflags,ovloc);
              end;
          end;
      end;


    procedure tcgarm.a_op_reg_reg_reg_checkoverflow(list: taasmoutput; op: TOpCg; size: tcgsize; src1, src2, dst: tregister;setflags : boolean;var ovloc : tlocation);
      var
        so : tshifterop;
        tmpreg,overflowreg : tregister;
        asmop : tasmop;
      begin
        ovloc.loc:=LOC_VOID;
        case op of
          OP_NEG,OP_NOT,
          OP_DIV,OP_IDIV:
            internalerror(200308281);
          OP_SHL:
            begin
              shifterop_reset(so);
              so.rs:=src1;
              so.shiftmode:=SM_LSL;
              list.concat(taicpu.op_reg_reg_shifterop(A_MOV,dst,src2,so));
            end;
          OP_SHR:
            begin
              shifterop_reset(so);
              so.rs:=src1;
              so.shiftmode:=SM_LSR;
              list.concat(taicpu.op_reg_reg_shifterop(A_MOV,dst,src2,so));
            end;
          OP_SAR:
            begin
              shifterop_reset(so);
              so.rs:=src1;
              so.shiftmode:=SM_ASR;
              list.concat(taicpu.op_reg_reg_shifterop(A_MOV,dst,src2,so));
            end;
          OP_IMUL,
          OP_MUL:
            begin
              if cgsetflags or setflags then
                begin
                  overflowreg:=getintregister(list,size);
                  if op=OP_IMUL then
                    asmop:=A_SMULL
                  else
                    asmop:=A_UMULL;
                  { the arm doesn't allow that rd and rm are the same }
                  if dst=src2 then
                    begin
                      if dst<>src1 then
                        list.concat(taicpu.op_reg_reg_reg_reg(asmop,dst,overflowreg,src1,src2))
                      else
                        begin
                          tmpreg:=getintregister(list,size);
                          a_load_reg_reg(list,size,size,src2,dst);
                          list.concat(taicpu.op_reg_reg_reg_reg(asmop,dst,overflowreg,tmpreg,src1));
                        end;
                    end
                  else
                    list.concat(taicpu.op_reg_reg_reg_reg(asmop,dst,overflowreg,src2,src1));
                  if op=OP_IMUL then
                    begin
                      shifterop_reset(so);
                      so.shiftmode:=SM_ASR;
                      so.shiftimm:=31;
                      list.concat(taicpu.op_reg_reg_shifterop(A_CMP,overflowreg,dst,so));
                    end
                  else
                    list.concat(taicpu.op_reg_const(A_CMP,overflowreg,0));

                   ovloc.loc:=LOC_FLAGS;
                   ovloc.resflags:=F_NE;
                end
              else
                begin
                  { the arm doesn't allow that rd and rm are the same }
                  if dst=src2 then
                    begin
                      if dst<>src1 then
                        list.concat(taicpu.op_reg_reg_reg(A_MUL,dst,src1,src2))
                      else
                        begin
                          tmpreg:=getintregister(list,size);
                          a_load_reg_reg(list,size,size,src2,dst);
                          list.concat(taicpu.op_reg_reg_reg(A_MUL,dst,tmpreg,src1));
                        end;
                    end
                  else
                    list.concat(taicpu.op_reg_reg_reg(A_MUL,dst,src2,src1));
                end;
            end;
          else
            list.concat(setoppostfix(
                taicpu.op_reg_reg_reg(op_reg_reg_opcg2asmop[op],dst,src2,src1),toppostfix(ord(cgsetflags or setflags)*ord(PF_S))
              ));
        end;
      end;


     function rotl(d : dword;b : byte) : dword;
       begin
          result:=(d shr (32-b)) or (d shl b);
       end;


     function is_shifter_const(d : aint;var imm_shift : byte) : boolean;
       var
          i : longint;
       begin
          for i:=0 to 15 do
            begin
               if (dword(d) and not(rotl($ff,i*2)))=0 then
                 begin
                    imm_shift:=i*2;
                    result:=true;
                    exit;
                 end;
            end;
          result:=false;
       end;


     procedure tcgarm.a_load_const_reg(list : taasmoutput; size: tcgsize; a : aint;reg : tregister);
       var
          imm_shift : byte;
          l : tasmlabel;
          hr : treference;
       begin
          if not(size in [OS_8,OS_S8,OS_16,OS_S16,OS_32,OS_S32]) then
            internalerror(2002090902);
          if is_shifter_const(a,imm_shift) then
            list.concat(taicpu.op_reg_const(A_MOV,reg,a))
          else if is_shifter_const(not(a),imm_shift) then
            list.concat(taicpu.op_reg_const(A_MVN,reg,not(a)))
          else
            begin
               reference_reset(hr);

               objectlibrary.getlabel(l);
               cg.a_label(current_procinfo.aktlocaldata,l);
               hr.symboldata:=current_procinfo.aktlocaldata.last;
               current_procinfo.aktlocaldata.concat(tai_const.Create_32bit(longint(a)));

               hr.symbol:=l;
               list.concat(taicpu.op_reg_ref(A_LDR,reg,hr));
            end;
       end;


    procedure tcgarm.handle_load_store(list:taasmoutput;op: tasmop;oppostfix : toppostfix;reg:tregister;ref: treference);
      var
        tmpreg : tregister;
        tmpref : treference;
        l : tasmlabel;
      begin
        tmpreg:=NR_NO;

        { Be sure to have a base register }
        if (ref.base=NR_NO) then
          begin
            if ref.shiftmode<>SM_None then
              internalerror(200308294);
            ref.base:=ref.index;
            ref.index:=NR_NO;
          end;

        { absolute symbols can't be handled directly, we've to store the symbol reference
          in the text segment and access it pc relative

          For now, we assume that references where base or index equals to PC are already
          relative, all other references are assumed to be absolute and thus they need
          to be handled extra.

          A proper solution would be to change refoptions to a set and store the information
          if the symbol is absolute or relative there.
        }

        if (assigned(ref.symbol) and
            not(is_pc(ref.base)) and
            not(is_pc(ref.index))
           ) or
           (ref.offset<-4095) or
           (ref.offset>4095) or
           ((oppostfix in [PF_SB,PF_H,PF_SH]) and
            ((ref.offset<-255) or
             (ref.offset>255)
            )
           ) or
           ((op in [A_LDF,A_STF]) and
            ((ref.offset<-1020) or
             (ref.offset>1020)
            )
           ) then
          begin
            reference_reset(tmpref);
            { create consts entry }
            objectlibrary.getlabel(l);
            cg.a_label(current_procinfo.aktlocaldata,l);
            tmpref.symboldata:=current_procinfo.aktlocaldata.last;

            if assigned(ref.symbol) then
              current_procinfo.aktlocaldata.concat(tai_const.create_sym_offset(ref.symbol,ref.offset))
            else
              current_procinfo.aktlocaldata.concat(tai_const.Create_32bit(ref.offset));

            { load consts entry }
            tmpreg:=getintregister(list,OS_INT);
            tmpref.symbol:=l;
            tmpref.base:=NR_R15;
            list.concat(taicpu.op_reg_ref(A_LDR,tmpreg,tmpref));

            if (ref.base<>NR_NO) then
              begin
                if ref.index<>NR_NO then
                  begin
                    list.concat(taicpu.op_reg_reg_reg(A_ADD,tmpreg,ref.base,tmpreg));
                    ref.base:=tmpreg;
                  end
                else
                  begin
                    ref.index:=tmpreg;
                    ref.shiftimm:=0;
                    ref.signindex:=1;
                    ref.shiftmode:=SM_None;
                  end;
              end
            else
              ref.base:=tmpreg;
            ref.offset:=0;
            ref.symbol:=nil;
          end;

        if (ref.base<>NR_NO) and (ref.index<>NR_NO) and (ref.offset<>0) then
          begin
            if tmpreg<>NR_NO then
              a_op_const_reg_reg(list,OP_ADD,OS_ADDR,ref.offset,tmpreg,tmpreg)
            else
              begin
                tmpreg:=getintregister(list,OS_ADDR);
                a_op_const_reg_reg(list,OP_ADD,OS_ADDR,ref.offset,ref.base,tmpreg);
                ref.base:=tmpreg;
              end;
            ref.offset:=0;
          end;

        { floating point operations have only limited references
          we expect here, that a base is already set }
        if (op in [A_LDF,A_STF]) and (ref.index<>NR_NO) then
          begin
            if ref.shiftmode<>SM_none then
              internalerror(200309121);
            if tmpreg<>NR_NO then
              begin
                if ref.base=tmpreg then
                  begin
                    if ref.signindex<0 then
                      list.concat(taicpu.op_reg_reg_reg(A_SUB,tmpreg,tmpreg,ref.index))
                    else
                      list.concat(taicpu.op_reg_reg_reg(A_ADD,tmpreg,tmpreg,ref.index));
                    ref.index:=NR_NO;
                  end
                else
                  begin
                    if ref.index<>tmpreg then
                      internalerror(200403161);
                    if ref.signindex<0 then
                      list.concat(taicpu.op_reg_reg_reg(A_SUB,tmpreg,ref.base,tmpreg))
                    else
                      list.concat(taicpu.op_reg_reg_reg(A_ADD,tmpreg,ref.base,tmpreg));
                    ref.base:=tmpreg;
                    ref.index:=NR_NO;
                  end;
              end
            else
              begin
                tmpreg:=getintregister(list,OS_ADDR);
                list.concat(taicpu.op_reg_reg_reg(A_ADD,tmpreg,ref.base,ref.index));
                ref.base:=tmpreg;
                ref.index:=NR_NO;
              end;
          end;
        list.concat(setoppostfix(taicpu.op_reg_ref(op,reg,ref),oppostfix));
      end;


     procedure tcgarm.a_load_reg_ref(list : taasmoutput; fromsize, tosize: tcgsize; reg : tregister;const ref : treference);
       var
         oppostfix:toppostfix;
       begin
         case ToSize of
           { signed integer registers }
           OS_8,
           OS_S8:
             oppostfix:=PF_B;
           OS_16,
           OS_S16:
             oppostfix:=PF_H;
           OS_32,
           OS_S32:
             oppostfix:=PF_None;
           else
             InternalError(200308295);
         end;
         handle_load_store(list,A_STR,oppostfix,reg,ref);
       end;


     procedure tcgarm.a_load_ref_reg(list : taasmoutput; fromsize, tosize : tcgsize;const Ref : treference;reg : tregister);
       var
         oppostfix:toppostfix;
       begin
         case FromSize of
           { signed integer registers }
           OS_8:
             oppostfix:=PF_B;
           OS_S8:
             oppostfix:=PF_SB;
           OS_16:
             oppostfix:=PF_H;
           OS_S16:
             oppostfix:=PF_SH;
           OS_32,
           OS_S32:
             oppostfix:=PF_None;
           else
             InternalError(200308291);
         end;
         handle_load_store(list,A_LDR,oppostfix,reg,ref);
       end;


     procedure tcgarm.a_load_reg_reg(list : taasmoutput; fromsize, tosize : tcgsize;reg1,reg2 : tregister);
       var
         instr: taicpu;
         so : tshifterop;
       begin
         shifterop_reset(so);
         if (tcgsize2size[tosize] < tcgsize2size[fromsize]) or
            (
              (tcgsize2size[tosize] = tcgsize2size[fromsize]) and
             (tosize <> fromsize) and
             not(fromsize in [OS_32,OS_S32])
            ) then
           begin
             case tosize of
               OS_8:
                 list.concat(taicpu.op_reg_reg_const(A_AND,
                   reg2,reg1,$ff));
               OS_S8:
                 begin
                   so.shiftmode:=SM_LSL;
                   so.shiftimm:=24;
                   list.concat(taicpu.op_reg_reg_shifterop(A_MOV,reg2,reg1,so));
                   so.shiftmode:=SM_ASR;
                   so.shiftimm:=24;
                   list.concat(taicpu.op_reg_reg_shifterop(A_MOV,reg2,reg2,so));
                 end;
               OS_16:
                 begin
                   so.shiftmode:=SM_LSL;
                   so.shiftimm:=16;
                   list.concat(taicpu.op_reg_reg_shifterop(A_MOV,reg2,reg1,so));
                   so.shiftmode:=SM_LSR;
                   so.shiftimm:=16;
                   list.concat(taicpu.op_reg_reg_shifterop(A_MOV,reg2,reg2,so));
                 end;
               OS_S16:
                 begin
                   so.shiftmode:=SM_LSL;
                   so.shiftimm:=16;
                   list.concat(taicpu.op_reg_reg_shifterop(A_MOV,reg2,reg1,so));
                   so.shiftmode:=SM_ASR;
                   so.shiftimm:=16;
                   list.concat(taicpu.op_reg_reg_shifterop(A_MOV,reg2,reg2,so));
                 end;
               OS_32,OS_S32:
                 begin
                   instr:=taicpu.op_reg_reg(A_MOV,reg2,reg1);
                   list.concat(instr);
                   add_move_instruction(instr);
                 end;
               else internalerror(2002090901);
             end;
           end
         else
           begin
             if reg1<>reg2 then
               begin
                 { same size, only a register mov required }
                 instr:=taicpu.op_reg_reg(A_MOV,reg2,reg1);
                 list.Concat(instr);
                 { Notify the register allocator that we have written a move instruction so
                   it can try to eliminate it. }
                 add_move_instruction(instr);
               end;
           end;
       end;


     procedure tcgarm.a_loadfpu_reg_reg(list: taasmoutput; size: tcgsize; reg1, reg2: tregister);
       begin
         list.concat(setoppostfix(taicpu.op_reg_reg(A_MVF,reg2,reg1),cgsize2fpuoppostfix[size]));
       end;


     procedure tcgarm.a_loadfpu_ref_reg(list: taasmoutput; size: tcgsize; const ref: treference; reg: tregister);
       var
         oppostfix:toppostfix;
       begin
         case size of
           OS_F32:
             oppostfix:=PF_S;
           OS_F64:
             oppostfix:=PF_D;
           OS_F80:
             oppostfix:=PF_E;
           else
             InternalError(200309021);
         end;
         handle_load_store(list,A_LDF,oppostfix,reg,ref);
       end;


     procedure tcgarm.a_loadfpu_reg_ref(list: taasmoutput; size: tcgsize; reg: tregister; const ref: treference);
       var
         oppostfix:toppostfix;
       begin
         case size of
           OS_F32:
             oppostfix:=PF_S;
           OS_F64:
             oppostfix:=PF_D;
           OS_F80:
             oppostfix:=PF_E;
           else
             InternalError(200309021);
         end;
         handle_load_store(list,A_STF,oppostfix,reg,ref);
       end;


    {  comparison operations }
    procedure tcgarm.a_cmp_const_reg_label(list : taasmoutput;size : tcgsize;cmp_op : topcmp;a : aint;reg : tregister;
      l : tasmlabel);
      var
        tmpreg : tregister;
        b : byte;
      begin
        if is_shifter_const(a,b) then
          list.concat(taicpu.op_reg_const(A_CMP,reg,a))
        { CMN reg,0 and CMN reg,$80000000 are different from CMP reg,$ffffffff
          and CMP reg,$7fffffff regarding the flags according to the ARM manual }
        else if (a<>$7fffffff) and (a<>-1) and is_shifter_const(-a,b) then
          list.concat(taicpu.op_reg_const(A_CMN,reg,-a))
        else
          begin
            tmpreg:=getintregister(list,size);
            a_load_const_reg(list,size,a,tmpreg);
            list.concat(taicpu.op_reg_reg(A_CMP,reg,tmpreg));
          end;
        a_jmp_cond(list,cmp_op,l);
      end;


    procedure tcgarm.a_cmp_reg_reg_label(list : taasmoutput;size : tcgsize;cmp_op : topcmp;reg1,reg2 : tregister;l : tasmlabel);
      begin
        list.concat(taicpu.op_reg_reg(A_CMP,reg2,reg1));
        a_jmp_cond(list,cmp_op,l);
      end;


    procedure tcgarm.a_jmp_name(list : taasmoutput;const s : string);
      begin
        list.concat(taicpu.op_sym(A_B,objectlibrary.newasmsymbol(s,AB_EXTERNAL,AT_FUNCTION)));
      end;


    procedure tcgarm.a_jmp_always(list : taasmoutput;l: tasmlabel);
      begin
        list.concat(taicpu.op_sym(A_B,objectlibrary.newasmsymbol(l.name,AB_EXTERNAL,AT_FUNCTION)));
      end;


    procedure tcgarm.a_jmp_flags(list : taasmoutput;const f : TResFlags;l: tasmlabel);
      var
        ai : taicpu;
      begin
        ai:=setcondition(taicpu.op_sym(A_B,l),flags_to_cond(f));
        ai.is_jmp:=true;
        list.concat(ai);
      end;


    procedure tcgarm.g_flags2reg(list: taasmoutput; size: TCgSize; const f: TResFlags; reg: TRegister);
      var
        ai : taicpu;
      begin
        list.concat(setcondition(taicpu.op_reg_const(A_MOV,reg,1),flags_to_cond(f)));
        list.concat(setcondition(taicpu.op_reg_const(A_MOV,reg,0),inverse_cond(flags_to_cond(f))));
      end;


    procedure tcgarm.g_proc_entry(list : taasmoutput;localsize : longint;nostackframe:boolean);
      var
         ref : treference;
         shift : byte;
         firstfloatreg,lastfloatreg,
         r : byte;
      begin
        LocalSize:=align(LocalSize,4);
        if not(nostackframe) then
          begin
            firstfloatreg:=RS_NO;
            { save floating point registers? }
            for r:=RS_F0 to RS_F7 do
              if r in rg[R_FPUREGISTER].used_in_proc-paramanager.get_volatile_registers_fpu(pocall_stdcall) then
                begin
                  if firstfloatreg=RS_NO then
                    firstfloatreg:=r;
                  lastfloatreg:=r;
                end;
            a_reg_alloc(list,NR_STACK_POINTER_REG);
            a_reg_alloc(list,NR_FRAME_POINTER_REG);
            a_reg_alloc(list,NR_R12);

            list.concat(taicpu.op_reg_reg(A_MOV,NR_R12,NR_STACK_POINTER_REG));
            { save int registers }
            reference_reset(ref);
            ref.index:=NR_STACK_POINTER_REG;
            ref.addressmode:=AM_PREINDEXED;
            list.concat(setoppostfix(taicpu.op_ref_regset(A_STM,ref,
              rg[R_INTREGISTER].used_in_proc-paramanager.get_volatile_registers_int(pocall_stdcall)+[RS_R11,RS_R12,RS_R14,RS_R15]),
              PF_FD));

            list.concat(taicpu.op_reg_reg_const(A_SUB,NR_FRAME_POINTER_REG,NR_R12,4));

            { allocate necessary stack size }
            { don't use  a_op_const_reg_reg here because we don't allow register allocations
              in the entry/exit code }
            if not(is_shifter_const(localsize,shift)) then
              begin
                a_load_const_reg(list,OS_ADDR,LocalSize,NR_R12);
                list.concat(taicpu.op_reg_reg_reg(A_SUB,NR_STACK_POINTER_REG,NR_STACK_POINTER_REG,NR_R12));
                a_reg_dealloc(list,NR_R12);
              end
            else
              begin
                a_reg_dealloc(list,NR_R12);
                list.concat(taicpu.op_reg_reg_const(A_SUB,NR_STACK_POINTER_REG,NR_STACK_POINTER_REG,LocalSize));
              end;
            if firstfloatreg<>RS_NO then
              begin
                reference_reset(ref);
                if not(is_shifter_const(-tarmprocinfo(current_procinfo).floatregstart,shift)) then
                  begin
                    a_load_const_reg(list,OS_ADDR,-tarmprocinfo(current_procinfo).floatregstart,NR_R12);
                    list.concat(taicpu.op_reg_reg_reg(A_SUB,NR_R12,NR_FRAME_POINTER_REG,NR_R12));
                    ref.base:=NR_R12;
                  end
                else
                  begin
                    ref.base:=NR_FRAME_POINTER_REG;
                    ref.offset:=tarmprocinfo(current_procinfo).floatregstart;
                  end;
                list.concat(taicpu.op_reg_const_ref(A_SFM,newreg(R_FPUREGISTER,firstfloatreg,R_SUBWHOLE),
                  lastfloatreg-firstfloatreg+1,ref));
              end;
          end;
      end;


    procedure tcgarm.g_proc_exit(list : taasmoutput;parasize : longint;nostackframe:boolean);
      var
         ref : treference;
         firstfloatreg,lastfloatreg,
         r : byte;
         shift : byte;
      begin
        if not(nostackframe) then
          begin
            { restore floating point register }
            firstfloatreg:=RS_NO;
            { save floating point registers? }
            for r:=RS_F0 to RS_F7 do
              if r in rg[R_FPUREGISTER].used_in_proc-paramanager.get_volatile_registers_fpu(pocall_stdcall) then
                begin
                  if firstfloatreg=RS_NO then
                    firstfloatreg:=r;
                  lastfloatreg:=r;
                end;

            if firstfloatreg<>RS_NO then
              begin
                reference_reset(ref);
                if not(is_shifter_const(-tarmprocinfo(current_procinfo).floatregstart,shift)) then
                  begin
                    a_load_const_reg(list,OS_ADDR,-tarmprocinfo(current_procinfo).floatregstart,NR_R12);
                    list.concat(taicpu.op_reg_reg_reg(A_SUB,NR_R12,NR_FRAME_POINTER_REG,NR_R12));
                    ref.base:=NR_R12;
                  end
                else
                  begin
                    ref.base:=NR_FRAME_POINTER_REG;
                    ref.offset:=tarmprocinfo(current_procinfo).floatregstart;
                  end;
                list.concat(taicpu.op_reg_const_ref(A_LFM,newreg(R_FPUREGISTER,firstfloatreg,R_SUBWHOLE),
                  lastfloatreg-firstfloatreg+1,ref));
              end;

            if (current_procinfo.framepointer=NR_STACK_POINTER_REG) then
              list.concat(taicpu.op_reg_reg(A_MOV,NR_R15,NR_R14))
            else
              begin
                { restore int registers and return }
                reference_reset(ref);
                ref.index:=NR_FRAME_POINTER_REG;
                list.concat(setoppostfix(taicpu.op_ref_regset(A_LDM,ref,rg[R_INTREGISTER].used_in_proc-paramanager.get_volatile_registers_int(pocall_stdcall)+[RS_R11,RS_R13,RS_R15]),PF_EA));
              end;
          end
        else
          list.concat(taicpu.op_reg_reg(A_MOV,NR_PC,NR_R14));
      end;


    procedure tcgarm.a_loadaddr_ref_reg(list : taasmoutput;const ref : treference;r : tregister);
      var
        b : byte;
        tmpref : treference;
        instr : taicpu;
      begin
        if ref.addressmode<>AM_OFFSET then
          internalerror(200309071);
        tmpref:=ref;
        { Be sure to have a base register }
        if (tmpref.base=NR_NO) then
          begin
            if tmpref.shiftmode<>SM_None then
              internalerror(200308294);
            if tmpref.signindex<0 then
              internalerror(200312023);
            tmpref.base:=tmpref.index;
            tmpref.index:=NR_NO;
          end;

        if assigned(tmpref.symbol) or
           not((is_shifter_const(tmpref.offset,b)) or
               (is_shifter_const(-tmpref.offset,b))
              ) then
          fixref(list,tmpref);

        { expect a base here }
        if tmpref.base=NR_NO then
          internalerror(200312022);

        if tmpref.index<>NR_NO then
          begin
            if tmpref.shiftmode<>SM_None then
              internalerror(200312021);
            if tmpref.signindex<0 then
              a_op_reg_reg_reg(list,OP_SUB,OS_ADDR,tmpref.base,tmpref.index,r)
            else
              a_op_reg_reg_reg(list,OP_ADD,OS_ADDR,tmpref.base,tmpref.index,r);
            if tmpref.offset<>0 then
              a_op_const_reg_reg(list,OP_ADD,OS_ADDR,tmpref.offset,r,r);
          end
        else
          begin
            if tmpref.offset<>0 then
              a_op_const_reg_reg(list,OP_ADD,OS_ADDR,tmpref.offset,tmpref.base,r)
            else
              begin
                instr:=taicpu.op_reg_reg(A_MOV,r,tmpref.base);
                list.concat(instr);
                add_move_instruction(instr);
              end;
          end;
      end;


    procedure tcgarm.fixref(list : taasmoutput;var ref : treference);
      var
        tmpreg : tregister;
        tmpref : treference;
        l : tasmlabel;
      begin
        { absolute symbols can't be handled directly, we've to store the symbol reference
          in the text segment and access it pc relative

          For now, we assume that references where base or index equals to PC are already
          relative, all other references are assumed to be absolute and thus they need
          to be handled extra.

          A proper solution would be to change refoptions to a set and store the information
          if the symbol is absolute or relative there.
        }
        { create consts entry }
        reference_reset(tmpref);
        objectlibrary.getlabel(l);
        cg.a_label(current_procinfo.aktlocaldata,l);
        tmpref.symboldata:=current_procinfo.aktlocaldata.last;

        if assigned(ref.symbol) then
          current_procinfo.aktlocaldata.concat(tai_const.create_sym_offset(ref.symbol,ref.offset))
        else
          current_procinfo.aktlocaldata.concat(tai_const.Create_32bit(ref.offset));

        { load consts entry }
        tmpreg:=getintregister(list,OS_INT);
        tmpref.symbol:=l;
        tmpref.base:=NR_PC;
        list.concat(taicpu.op_reg_ref(A_LDR,tmpreg,tmpref));

        if (ref.base<>NR_NO) then
          begin
            if ref.index<>NR_NO then
              begin
                list.concat(taicpu.op_reg_reg_reg(A_ADD,tmpreg,ref.base,tmpreg));
                ref.base:=tmpreg;
              end
            else
              begin
                ref.index:=tmpreg;
                ref.shiftimm:=0;
                ref.signindex:=1;
                ref.shiftmode:=SM_None;
              end;
          end
        else
          ref.base:=tmpreg;

        ref.offset:=0;
        ref.symbol:=nil;
      end;


    procedure tcgarm.g_concatcopy_move(list : taasmoutput;const source,dest : treference;len : aint);
      var
        paraloc1,paraloc2,paraloc3 : TCGPara;
      begin
        paraloc1.init;
        paraloc2.init;
        paraloc3.init;
        paramanager.getintparaloc(pocall_default,1,paraloc1);
        paramanager.getintparaloc(pocall_default,2,paraloc2);
        paramanager.getintparaloc(pocall_default,3,paraloc3);
        paramanager.allocparaloc(list,paraloc3);
        a_param_const(list,OS_INT,len,paraloc3);
        paramanager.allocparaloc(list,paraloc2);
        a_paramaddr_ref(list,dest,paraloc2);
        paramanager.allocparaloc(list,paraloc2);
        a_paramaddr_ref(list,source,paraloc1);
        paramanager.freeparaloc(list,paraloc3);
        paramanager.freeparaloc(list,paraloc2);
        paramanager.freeparaloc(list,paraloc1);
        alloccpuregisters(list,R_INTREGISTER,paramanager.get_volatile_registers_int(pocall_default));
        alloccpuregisters(list,R_FPUREGISTER,paramanager.get_volatile_registers_fpu(pocall_default));
        a_call_name(list,'FPC_MOVE');
        dealloccpuregisters(list,R_FPUREGISTER,paramanager.get_volatile_registers_fpu(pocall_default));
        dealloccpuregisters(list,R_INTREGISTER,paramanager.get_volatile_registers_int(pocall_default));
        paraloc3.done;
        paraloc2.done;
        paraloc1.done;
      end;


    procedure tcgarm.g_concatcopy_internal(list : taasmoutput;const source,dest : treference;len : aint;aligned : boolean);
      var
        srcref,dstref:treference;
        srcreg,destreg,countreg,r:tregister;
        helpsize:aword;
        copysize:byte;
        cgsize:Tcgsize;

      procedure genloop(count : aword;size : byte);
        const
          size2opsize : array[1..4] of tcgsize = (OS_8,OS_16,OS_NO,OS_32);
        var
          l : tasmlabel;
        begin
          objectlibrary.getlabel(l);
          a_load_const_reg(list,OS_INT,count,countreg);
          cg.a_label(list,l);
          srcref.addressmode:=AM_POSTINDEXED;
          dstref.addressmode:=AM_POSTINDEXED;
          srcref.offset:=size;
          dstref.offset:=size;
          r:=getintregister(list,size2opsize[size]);
          a_load_ref_reg(list,size2opsize[size],size2opsize[size],srcref,r);
          list.concat(setoppostfix(taicpu.op_reg_reg_const(A_SUB,countreg,countreg,1),PF_S));
          a_load_reg_ref(list,size2opsize[size],size2opsize[size],r,dstref);
          list.concat(setcondition(taicpu.op_sym(A_B,l),C_NE));
          { keep the registers alive }
          list.concat(taicpu.op_reg_reg(A_MOV,countreg,countreg));
          list.concat(taicpu.op_reg_reg(A_MOV,srcreg,srcreg));
          list.concat(taicpu.op_reg_reg(A_MOV,destreg,destreg));
        end;

      begin
        if len=0 then
          exit;
        helpsize:=12;
        dstref:=dest;
        srcref:=source;
        if cs_littlesize in aktglobalswitches then
          helpsize:=8;
        if (len<=helpsize) and aligned then
          begin
            copysize:=4;
            cgsize:=OS_32;
            while len<>0 do
              begin
                if len<2 then
                  begin
                    copysize:=1;
                    cgsize:=OS_8;
                  end
                else if len<4 then
                  begin
                    copysize:=2;
                    cgsize:=OS_16;
                  end;
                dec(len,copysize);
                r:=getintregister(list,cgsize);
                a_load_ref_reg(list,cgsize,cgsize,srcref,r);
                a_load_reg_ref(list,cgsize,cgsize,r,dstref);
                inc(srcref.offset,copysize);
                inc(dstref.offset,copysize);
              end;
          end
        else
          begin
            destreg:=getintregister(list,OS_ADDR);
            a_loadaddr_ref_reg(list,dest,destreg);
            reference_reset_base(dstref,destreg,0);

            srcreg:=getintregister(list,OS_ADDR);
            a_loadaddr_ref_reg(list,source,srcreg);
            reference_reset_base(srcref,srcreg,0);

            countreg:=getintregister(list,OS_32);

//            if cs_littlesize in aktglobalswitches  then
              genloop(len,1);
{
            else
              begin
                helpsize:=len shr 2;
                len:=len and 3;
                if helpsize>1 then
                  begin
                    a_load_const_reg(list,OS_INT,helpsize,countreg);
                    list.concat(Taicpu.op_none(A_REP,S_NO));
                  end;
                if helpsize>0 then
                  list.concat(Taicpu.op_none(A_MOVSD,S_NO));
                if len>1 then
                  begin
                    dec(len,2);
                    list.concat(Taicpu.op_none(A_MOVSW,S_NO));
                  end;
                if len=1 then
                  list.concat(Taicpu.op_none(A_MOVSB,S_NO));
                end;
}
          end;
      end;


    procedure tcgarm.g_concatcopy_unaligned(list : taasmoutput;const source,dest : treference;len : aint);
      begin
        g_concatcopy_internal(list,source,dest,len,false);
      end;


    procedure tcgarm.g_concatcopy(list : taasmoutput;const source,dest : treference;len : aint);
      begin
        g_concatcopy_internal(list,source,dest,len,true);
      end;


    procedure tcgarm.g_overflowCheck(list : taasmoutput;const l : tlocation;def : tdef);
      var
        ovloc : tlocation;
      begin
        ovloc.loc:=LOC_VOID;
        g_overflowCheck_loc(list,l,def,ovloc);
      end;


    procedure tcgarm.g_overflowCheck_loc(List:TAasmOutput;const Loc:TLocation;def:TDef;ovloc : tlocation);
      var
        hl : tasmlabel;
        ai:TAiCpu;
        hflags : tresflags;
      begin
        if not(cs_check_overflow in aktlocalswitches) then
          exit;
        objectlibrary.getlabel(hl);
        case ovloc.loc of
          LOC_VOID:
            begin
              ai:=taicpu.op_sym(A_B,hl);
              ai.is_jmp:=true;

              if not((def.deftype=pointerdef) or
                    ((def.deftype=orddef) and
                     (torddef(def).typ in [u64bit,u16bit,u32bit,u8bit,uchar,bool8bit,bool16bit,bool32bit]))) then
                 ai.SetCondition(C_VC)
              else
                 ai.SetCondition(C_CC);

              list.concat(ai);
            end;
          LOC_FLAGS:
            begin
              hflags:=ovloc.resflags;
              inverse_flags(hflags);
              cg.a_jmp_flags(list,hflags,hl);
            end;
          else
            internalerror(200409281);
        end;

        a_call_name(list,'FPC_OVERFLOW');
        a_label(list,hl);
      end;


    procedure tcgarm.g_save_standard_registers(list : taasmoutput);
      begin
        { this work is done in g_proc_entry }
      end;


    procedure tcgarm.g_restore_standard_registers(list : taasmoutput);
      begin
        { this work is done in g_proc_exit }
      end;


    procedure tcgarm.a_jmp_cond(list : taasmoutput;cond : TOpCmp;l: tasmlabel);
      var
        ai : taicpu;
      begin
        ai:=Taicpu.Op_sym(A_B,l);
        ai.SetCondition(OpCmp2AsmCond[cond]);
        ai.is_jmp:=true;
        list.concat(ai);
      end;


    procedure tcgarm.g_intf_wrapper(list: taasmoutput; procdef: tprocdef; const labelname: string; ioffset: longint);

      procedure loadvmttor12;
        var
          href : treference;
        begin
          reference_reset_base(href,NR_R0,0);
          cg.a_load_ref_reg(list,OS_ADDR,OS_ADDR,href,NR_R12);
        end;


      procedure op_onr12methodaddr;
        var
          href : treference;
        begin
          if (procdef.extnumber=$ffff) then
            Internalerror(200006139);
          { call/jmp  vmtoffs(%eax) ; method offs }
          reference_reset_base(href,NR_R12,procdef._class.vmtmethodoffset(procdef.extnumber));
          cg.a_load_ref_reg(list,OS_ADDR,OS_ADDR,href,NR_R12);
          list.concat(taicpu.op_reg_reg(A_MOV,NR_PC,NR_R12));
        end;

      var
        lab : tasmsymbol;
        make_global : boolean;
        href : treference;
      begin
        if procdef.proctypeoption<>potype_none then
          Internalerror(200006137);
        if not assigned(procdef._class) or
           (procdef.procoptions*[po_classmethod, po_staticmethod,
             po_methodpointer, po_interrupt, po_iocheck]<>[]) then
          Internalerror(200006138);
        if procdef.owner.symtabletype<>objectsymtable then
          Internalerror(200109191);

        make_global:=false;
        if (not current_module.is_unit) or
           (cs_create_smart in aktmoduleswitches) or
           (procdef.owner.defowner.owner.symtabletype=globalsymtable) then
          make_global:=true;

        if make_global then
          list.concat(Tai_symbol.Createname_global(labelname,AT_FUNCTION,0))
        else
          list.concat(Tai_symbol.Createname(labelname,AT_FUNCTION,0));

        { set param1 interface to self  }
        g_adjust_self_value(list,procdef,ioffset);

        { case 4 }
        if po_virtualmethod in procdef.procoptions then
          begin
            loadvmttor12;
            op_onr12methodaddr;
          end
        { case 0 }
        else
          list.concat(taicpu.op_sym(A_B,objectlibrary.newasmsymbol(procdef.mangledname,AB_EXTERNAL,AT_FUNCTION)));

        list.concat(Tai_symbol_end.Createname(labelname));
      end;


    procedure tcg64farm.a_op64_reg_reg(list : taasmoutput;op:TOpCG;size : tcgsize;regsrc,regdst : tregister64);
      var
        tmpreg : tregister;
      begin
        case op of
          OP_NEG:
            begin
              list.concat(setoppostfix(taicpu.op_reg_reg_const(A_RSB,regdst.reglo,regsrc.reglo,0),PF_S));
              list.concat(taicpu.op_reg_reg_const(A_RSC,regdst.reghi,regsrc.reghi,0));
            end;
          OP_NOT:
            begin
              cg.a_op_reg_reg(list,OP_NOT,OS_INT,regsrc.reglo,regdst.reglo);
              cg.a_op_reg_reg(list,OP_NOT,OS_INT,regsrc.reghi,regdst.reghi);
            end;
          else
            a_op64_reg_reg_reg(list,op,size,regsrc,regdst,regdst);
        end;
      end;


    procedure tcg64farm.a_op64_const_reg(list : taasmoutput;op:TOpCG;size : tcgsize;value : int64;reg : tregister64);
      begin
        a_op64_const_reg_reg(list,op,size,value,reg,reg);
      end;


    procedure tcg64farm.a_op64_const_reg_reg(list: taasmoutput;op:TOpCG;size : tcgsize;value : int64;regsrc,regdst : tregister64);
      var
        ovloc : tlocation;
      begin
        a_op64_const_reg_reg_checkoverflow(list,op,size,value,regsrc,regdst,false,ovloc);
      end;


    procedure tcg64farm.a_op64_reg_reg_reg(list: taasmoutput;op:TOpCG;size : tcgsize;regsrc1,regsrc2,regdst : tregister64);
      var
        ovloc : tlocation;
      begin
        a_op64_reg_reg_reg_checkoverflow(list,op,size,regsrc1,regsrc2,regdst,false,ovloc);
      end;


    procedure tcg64farm.a_op64_const_reg_reg_checkoverflow(list: taasmoutput;op:TOpCG;size : tcgsize;value : int64;regsrc,regdst : tregister64;setflags : boolean;var ovloc : tlocation);
      var
        tmpreg : tregister;
        b : byte;
      begin
        ovloc.loc:=LOC_VOID;
        case op of
          OP_NEG,
          OP_NOT :
            internalerror(200306017);
        end;
        if (setflags or tcgarm(cg).cgsetflags) and (op in [OP_ADD,OP_SUB]) then
          begin
            case op of
              OP_ADD:
                begin
                  if is_shifter_const(lo(value),b) then
                    list.concat(setoppostfix(taicpu.op_reg_reg_const(A_ADD,regdst.reglo,regsrc.reglo,lo(value)),PF_S))
                  else
                    begin
                      tmpreg:=cg.getintregister(list,OS_32);
                      cg.a_load_const_reg(list,OS_32,lo(value),tmpreg);
                      list.concat(setoppostfix(taicpu.op_reg_reg_reg(A_ADD,regdst.reglo,regsrc.reglo,tmpreg),PF_S));
                    end;

                  if is_shifter_const(hi(value),b) then
                    list.concat(setoppostfix(taicpu.op_reg_reg_const(A_ADC,regdst.reghi,regsrc.reghi,hi(value)),PF_S))
                  else
                    begin
                      tmpreg:=cg.getintregister(list,OS_32);
                      cg.a_load_const_reg(list,OS_32,hi(value),tmpreg);
                      list.concat(setoppostfix(taicpu.op_reg_reg_reg(A_ADC,regdst.reghi,regsrc.reghi,tmpreg),PF_S));
                    end;
                end;
              OP_SUB:
                begin
                  if is_shifter_const(lo(value),b) then
                    list.concat(setoppostfix(taicpu.op_reg_reg_const(A_SUB,regdst.reglo,regsrc.reglo,lo(value)),PF_S))
                  else
                    begin
                      tmpreg:=cg.getintregister(list,OS_32);
                      cg.a_load_const_reg(list,OS_32,lo(value),tmpreg);
                      list.concat(setoppostfix(taicpu.op_reg_reg_reg(A_SUB,regdst.reglo,regsrc.reglo,tmpreg),PF_S));
                    end;

                  if is_shifter_const(hi(value),b) then
                    list.concat(setoppostfix(taicpu.op_reg_reg_const(A_SBC,regdst.reghi,regsrc.reghi,hi(value)),PF_S))
                  else
                    begin
                      tmpreg:=cg.getintregister(list,OS_32);
                      cg.a_load_const_reg(list,OS_32,hi(value),tmpreg);
                      list.concat(setoppostfix(taicpu.op_reg_reg_reg(A_SBC,regdst.reghi,regsrc.reghi,tmpreg),PF_S));
                    end;
                end;
              else
                internalerror(200502131);
            end;
            if size=OS_64 then
              begin
                { the arm has an weired opinion how flags for SUB/ADD are handled }
                ovloc.loc:=LOC_FLAGS;
                case op of
                  OP_ADD:
                    ovloc.resflags:=F_CS;
                  OP_SUB:
                    ovloc.resflags:=F_CC;
                end;
              end;
          end
        else
          begin
            case op of
              OP_AND,OP_OR,OP_XOR:
                begin
                  cg.a_op_const_reg_reg(list,op,OS_32,lo(value),regsrc.reglo,regdst.reglo);
                  cg.a_op_const_reg_reg(list,op,OS_32,hi(value),regsrc.reghi,regdst.reghi);
                end;
              OP_ADD:
                begin
                  if is_shifter_const(lo(value),b) then
                    list.concat(setoppostfix(taicpu.op_reg_reg_const(A_ADD,regdst.reglo,regsrc.reglo,lo(value)),PF_S))
                  else
                    begin
                      tmpreg:=cg.getintregister(list,OS_32);
                      cg.a_load_const_reg(list,OS_32,lo(value),tmpreg);
                      list.concat(setoppostfix(taicpu.op_reg_reg_reg(A_ADD,regdst.reglo,regsrc.reglo,tmpreg),PF_S));
                    end;

                  if is_shifter_const(hi(value),b) then
                    list.concat(taicpu.op_reg_reg_const(A_ADC,regdst.reghi,regsrc.reghi,hi(value)))
                  else
                    begin
                      tmpreg:=cg.getintregister(list,OS_32);
                      cg.a_load_const_reg(list,OS_32,hi(value),tmpreg);
                      list.concat(taicpu.op_reg_reg_reg(A_ADC,regdst.reghi,regsrc.reghi,tmpreg));
                    end;
                end;
              OP_SUB:
                begin
                  if is_shifter_const(lo(value),b) then
                    list.concat(setoppostfix(taicpu.op_reg_reg_const(A_SUB,regdst.reglo,regsrc.reglo,lo(value)),PF_S))
                  else
                    begin
                      tmpreg:=cg.getintregister(list,OS_32);
                      cg.a_load_const_reg(list,OS_32,lo(value),tmpreg);
                      list.concat(setoppostfix(taicpu.op_reg_reg_reg(A_SUB,regdst.reglo,regsrc.reglo,tmpreg),PF_S));
                    end;

                  if is_shifter_const(hi(value),b) then
                    list.concat(taicpu.op_reg_reg_const(A_SBC,regdst.reghi,regsrc.reghi,hi(value)))
                  else
                    begin
                      tmpreg:=cg.getintregister(list,OS_32);
                      cg.a_load_const_reg(list,OS_32,hi(value),tmpreg);
                      list.concat(taicpu.op_reg_reg_reg(A_SBC,regdst.reghi,regsrc.reghi,tmpreg));
                    end;
                end;
            else
              internalerror(2003083101);
          end;
        end;
      end;


    procedure tcg64farm.a_op64_reg_reg_reg_checkoverflow(list: taasmoutput;op:TOpCG;size : tcgsize;regsrc1,regsrc2,regdst : tregister64;setflags : boolean;var ovloc : tlocation);
      var
        op1,op2:TAsmOp;
      begin
        ovloc.loc:=LOC_VOID;
        case op of
          OP_NEG,
          OP_NOT :
            internalerror(200306017);
        end;
        if (setflags or tcgarm(cg).cgsetflags) and (op in [OP_ADD,OP_SUB]) then
          begin
            case op of
              OP_ADD:
                begin
                  list.concat(setoppostfix(taicpu.op_reg_reg_reg(A_ADD,regdst.reglo,regsrc1.reglo,regsrc2.reglo),PF_S));
                  list.concat(setoppostfix(taicpu.op_reg_reg_reg(A_ADC,regdst.reghi,regsrc1.reghi,regsrc2.reghi),PF_S));
                end;
              OP_SUB:
                begin
                  list.concat(setoppostfix(taicpu.op_reg_reg_reg(A_SUB,regdst.reglo,regsrc2.reglo,regsrc1.reglo),PF_S));
                  list.concat(setoppostfix(taicpu.op_reg_reg_reg(A_SBC,regdst.reghi,regsrc2.reghi,regsrc1.reghi),PF_S));
                end;
              else
                internalerror(2003083101);
            end;
            if size=OS_64 then
              begin
                { the arm has an weired opinion how flags for SUB/ADD are handled }
                ovloc.loc:=LOC_FLAGS;
                case op of
                  OP_ADD:
                    ovloc.resflags:=F_CC;
                  OP_SUB:
                    ovloc.resflags:=F_CS;
                end;
              end;
          end
        else
          begin
            case op of
              OP_AND,OP_OR,OP_XOR:
                begin
                  cg.a_op_reg_reg_reg(list,op,OS_32,regsrc1.reglo,regsrc2.reglo,regdst.reglo);
                  cg.a_op_reg_reg_reg(list,op,OS_32,regsrc1.reghi,regsrc2.reghi,regdst.reghi);
                end;
              OP_ADD:
                begin
                  list.concat(setoppostfix(taicpu.op_reg_reg_reg(A_ADD,regdst.reglo,regsrc1.reglo,regsrc2.reglo),PF_S));
                  list.concat(taicpu.op_reg_reg_reg(A_ADC,regdst.reghi,regsrc1.reghi,regsrc2.reghi));
                end;
              OP_SUB:
                begin
                  list.concat(setoppostfix(taicpu.op_reg_reg_reg(A_SUB,regdst.reglo,regsrc2.reglo,regsrc1.reglo),PF_S));
                  list.concat(taicpu.op_reg_reg_reg(A_SBC,regdst.reghi,regsrc2.reghi,regsrc1.reghi));
                end;
              else
                internalerror(2003083101);
            end;
          end;
      end;


begin
  cg:=tcgarm.create;
  cg64:=tcg64farm.create;
end.
