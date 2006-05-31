{
    Copyright (c) 1998-2002 by Florian Klaempfl

    This unit implements the code generator for the PowerPC

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
       cgbase,cgobj,cgppc,
       aasmbase,aasmcpu,aasmtai,aasmdata,
       cpubase,cpuinfo,cgutils,cg64f32,rgcpu,
       parabase;

    type
      tcgppc = class(tcgppcgen)
        procedure init_register_allocators;override;
        procedure done_register_allocators;override;

        { passing parameters, per default the parameter is pushed }
        { nr gives the number of the parameter (enumerated from   }
        { left to right), this allows to move the parameter to    }
        { register, if the cpu supports register calling          }
        { conventions                                             }
        procedure a_param_const(list : TAsmList;size : tcgsize;a : aint;const paraloc : tcgpara);override;
        procedure a_param_ref(list : TAsmList;size : tcgsize;const r : treference;const paraloc : tcgpara);override;
        procedure a_paramaddr_ref(list : TAsmList;const r : treference;const paraloc : tcgpara);override;


        procedure a_call_name(list : TAsmList;const s : string);override;
        procedure a_call_reg(list : TAsmList;reg: tregister); override;

        procedure a_op_const_reg(list : TAsmList; Op: TOpCG; size: TCGSize; a: aint; reg: TRegister); override;
        procedure a_op_reg_reg(list : TAsmList; Op: TOpCG; size: TCGSize; src, dst: TRegister); override;

        procedure a_op_const_reg_reg(list: TAsmList; op: TOpCg;
          size: tcgsize; a: aint; src, dst: tregister); override;
        procedure a_op_reg_reg_reg(list: TAsmList; op: TOpCg;
          size: tcgsize; src1, src2, dst: tregister); override;

        { move instructions }
        procedure a_load_const_reg(list : TAsmList; size: tcgsize; a : aint;reg : tregister);override;
        procedure a_load_reg_ref(list : TAsmList; fromsize, tosize: tcgsize; reg : tregister;const ref : treference);override;
        procedure a_load_ref_reg(list : TAsmList; fromsize, tosize : tcgsize;const Ref : treference;reg : tregister);override;
        procedure a_load_reg_reg(list : TAsmList; fromsize, tosize : tcgsize;reg1,reg2 : tregister);override;

        procedure a_load_subsetreg_reg(list : TAsmList; subsetregsize, subsetsize: tcgsize;
          startbit: byte; tosize: tcgsize; subsetreg, destreg: tregister); override;
        procedure a_load_reg_subsetreg(list : TAsmList; fromsize: tcgsize; subsetregsize, 
          subsetsize: tcgsize; startbit: byte; fromreg, subsetreg: tregister); override;
       procedure a_load_subsetreg_subsetreg(list: TAsmlist; fromsubsetregsize, fromsubsetsize: tcgsize; fromstartbit: byte;
          tosubsetregsize, tosubsetsize: tcgsize; tostartbit: byte; fromsubsetreg, tosubsetreg: tregister); override;

        { fpu move instructions }
        procedure a_loadfpu_reg_reg(list: TAsmList; size: tcgsize; reg1, reg2: tregister); override;
        procedure a_loadfpu_ref_reg(list: TAsmList; size: tcgsize; const ref: treference; reg: tregister); override;
        procedure a_loadfpu_reg_ref(list: TAsmList; size: tcgsize; reg: tregister; const ref: treference); override;

        {  comparison operations }
        procedure a_cmp_const_reg_label(list : TAsmList;size : tcgsize;cmp_op : topcmp;a : aint;reg : tregister;
          l : tasmlabel);override;
        procedure a_cmp_reg_reg_label(list : TAsmList;size : tcgsize;cmp_op : topcmp;reg1,reg2 : tregister;l : tasmlabel); override;

        procedure a_jmp_name(list : TAsmList;const s : string); override;
        procedure a_jmp_always(list : TAsmList;l: tasmlabel); override;
        procedure a_jmp_flags(list : TAsmList;const f : TResFlags;l: tasmlabel); override;

        procedure g_flags2reg(list: TAsmList; size: TCgSize; const f: TResFlags; reg: TRegister); override;

        procedure g_proc_entry(list : TAsmList;localsize : longint;nostackframe:boolean);override;
        procedure g_proc_exit(list : TAsmList;parasize : longint;nostackframe:boolean); override;
        procedure g_save_standard_registers(list:TAsmList); override;
        procedure g_restore_standard_registers(list:TAsmList); override;

        procedure a_loadaddr_ref_reg(list : TAsmList;const ref : treference;r : tregister);override;

        procedure g_concatcopy(list : TAsmList;const source,dest : treference;len : aint);override;

        procedure g_overflowcheck(list: TAsmList; const l: tlocation; def: tdef); override;
        { find out whether a is of the form 11..00..11b or 00..11...00. If }
        { that's the case, we can use rlwinm to do an AND operation        }
        function get_rlwi_const(a: aint; var l1, l2: longint): boolean;

        procedure a_jmp_cond(list : TAsmList;cond : TOpCmp;l: tasmlabel);

        procedure g_intf_wrapper(list: TAsmList; procdef: tprocdef; const labelname: string; ioffset: longint);override;

      private

        (* NOT IN USE: *)
        procedure g_stackframe_entry_mac(list : TAsmList;localsize : longint);
        (* NOT IN USE: *)
        procedure g_return_from_proc_mac(list : TAsmList;parasize : aint);

        { clear out potential overflow bits from 8 or 16 bit operations  }
        { the upper 24/16 bits of a register after an operation          }
        procedure maybeadjustresult(list: TAsmList; op: TOpCg; size: tcgsize; dst: tregister);

        { Make sure ref is a valid reference for the PowerPC and sets the }
        { base to the value of the index if (base = R_NO).                }
        { Returns true if the reference contained a base, index and an    }
        { offset or symbol, in which case the base will have been changed }
        { to a tempreg (which has to be freed by the caller) containing   }
        { the sum of part of the original reference                       }
        function fixref(list: TAsmList; var ref: treference): boolean;

        { returns whether a reference can be used immediately in a powerpc }
        { instruction                                                      }
        function issimpleref(const ref: treference): boolean;

        { contains the common code of a_load_reg_ref and a_load_ref_reg }
        procedure a_load_store(list:TAsmList;op: tasmop;reg:tregister;
                    ref: treference);

        { creates the correct branch instruction for a given combination }
        { of asmcondflags and destination addressing mode                }
        procedure a_jmp(list: TAsmList; op: tasmop;
                        c: tasmcondflag; crval: longint; l: tasmlabel);

        function save_regs(list : TAsmList):longint;
        procedure restore_regs(list : TAsmList);

        function get_darwin_call_stub(const s: string): tasmsymbol;
     end;

     tcg64fppc = class(tcg64f32)
       procedure a_op64_reg_reg(list : TAsmList;op:TOpCG;size : tcgsize;regsrc,regdst : tregister64);override;
       procedure a_op64_const_reg(list : TAsmList;op:TOpCG;size : tcgsize;value : int64;reg : tregister64);override;
       procedure a_op64_const_reg_reg(list: TAsmList;op:TOpCG;size : tcgsize;value : int64;regsrc,regdst : tregister64);override;
       procedure a_op64_reg_reg_reg(list: TAsmList;op:TOpCG;size : tcgsize;regsrc1,regsrc2,regdst : tregister64);override;
     end;


const
  TOpCG2AsmOpConstLo: Array[topcg] of TAsmOp = (A_NONE,A_MR,A_ADDI,A_ANDI_,A_DIVWU,
                        A_DIVW,A_MULLW, A_MULLW, A_NONE,A_NONE,A_ORI,
                        A_SRAWI,A_SLWI,A_SRWI,A_SUBI,A_XORI);
  TOpCG2AsmOpConstHi: Array[topcg] of TAsmOp = (A_NONE,A_MR,A_ADDIS,A_ANDIS_,
                        A_DIVWU,A_DIVW, A_MULLW,A_MULLW,A_NONE,A_NONE,
                        A_ORIS,A_NONE, A_NONE,A_NONE,A_SUBIS,A_XORIS);

  TOpCmp2AsmCond: Array[topcmp] of TAsmCondFlag = (C_NONE,C_EQ,C_GT,
                       C_LT,C_GE,C_LE,C_NE,C_LE,C_LT,C_GE,C_GT);

  implementation

    uses
       globals,verbose,systems,cutils,
       symconst,symsym,fmodule,
       rgobj,tgobj,cpupi,procinfo,paramgr;


    procedure tcgppc.init_register_allocators;
      begin
        inherited init_register_allocators;
        if target_info.system=system_powerpc_darwin then
          begin
{
            if pi_needs_got in current_procinfo.flags then
              begin
                current_procinfo.got:=NR_R31;
                rg[R_INTREGISTER]:=trgcpu.create(R_INTREGISTER,R_SUBWHOLE,
                  [RS_R2,RS_R3,RS_R4,RS_R5,RS_R6,RS_R7,RS_R8,
                   RS_R9,RS_R10,RS_R11,RS_R12,RS_R30,RS_R29,
                   RS_R28,RS_R27,RS_R26,RS_R25,RS_R24,RS_R23,RS_R22,
                   RS_R21,RS_R20,RS_R19,RS_R18,RS_R17,RS_R16,RS_R15,
                   RS_R14,RS_R13],first_int_imreg,[]);
              end
            else}
              rg[R_INTREGISTER]:=trgcpu.create(R_INTREGISTER,R_SUBWHOLE,
                [RS_R2,RS_R3,RS_R4,RS_R5,RS_R6,RS_R7,RS_R8,
                 RS_R9,RS_R10,RS_R11,RS_R12,RS_R31,RS_R30,RS_R29,
                 RS_R28,RS_R27,RS_R26,RS_R25,RS_R24,RS_R23,RS_R22,
                 RS_R21,RS_R20,RS_R19,RS_R18,RS_R17,RS_R16,RS_R15,
                 RS_R14,RS_R13],first_int_imreg,[]);
          end
        else
          rg[R_INTREGISTER]:=trgcpu.create(R_INTREGISTER,R_SUBWHOLE,
            [RS_R3,RS_R4,RS_R5,RS_R6,RS_R7,RS_R8,
             RS_R9,RS_R10,RS_R11,RS_R12,RS_R31,RS_R30,RS_R29,
             RS_R28,RS_R27,RS_R26,RS_R25,RS_R24,RS_R23,RS_R22,
             RS_R21,RS_R20,RS_R19,RS_R18,RS_R17,RS_R16,RS_R15,
             RS_R14,RS_R13],first_int_imreg,[]);
        rg[R_FPUREGISTER]:=trgcpu.create(R_FPUREGISTER,R_SUBNONE,
            [RS_F0,RS_F1,RS_F2,RS_F3,RS_F4,RS_F5,RS_F6,RS_F7,RS_F8,RS_F9,
             RS_F10,RS_F11,RS_F12,RS_F13,RS_F31,RS_F30,RS_F29,RS_F28,RS_F27,
             RS_F26,RS_F25,RS_F24,RS_F23,RS_F22,RS_F21,RS_F20,RS_F19,RS_F18,
             RS_F17,RS_F16,RS_F15,RS_F14],first_fpu_imreg,[]);
        {$warning FIX ME}
        rg[R_MMREGISTER]:=trgcpu.create(R_MMREGISTER,R_SUBNONE,
            [RS_M0,RS_M1,RS_M2],first_mm_imreg,[]);
      end;


    procedure tcgppc.done_register_allocators;
      begin
        rg[R_INTREGISTER].free;
        rg[R_FPUREGISTER].free;
        rg[R_MMREGISTER].free;
        inherited done_register_allocators;
      end;


    procedure tcgppc.a_param_const(list : TAsmList;size : tcgsize;a : aint;const paraloc : tcgpara);
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


    procedure tcgppc.a_param_ref(list : TAsmList;size : tcgsize;const r : treference;const paraloc : tcgpara);

      var
        tmpref, ref: treference;
        location: pcgparalocation;
        sizeleft: aint;

      begin
        location := paraloc.location;
        tmpref := r;
        sizeleft := paraloc.intsize;
        while assigned(location) do
          begin
            case location^.loc of
              LOC_REGISTER,LOC_CREGISTER:
                begin
{$ifndef cpu64bit}
                  if (sizeleft <> 3) then
                    begin
                      a_load_ref_reg(list,location^.size,location^.size,tmpref,location^.register);
                    end
                  else
                    begin
                      a_load_ref_reg(list,OS_16,OS_16,tmpref,location^.register);
                      a_reg_alloc(list,NR_R0);
                      inc(tmpref.offset,2);
                      a_load_ref_reg(list,OS_8,OS_8,tmpref,newreg(R_INTREGISTER,RS_R0,R_SUBNONE));
                      a_op_const_reg(list,OP_SHL,OS_INT,16,location^.register);
                      list.concat(taicpu.op_reg_reg_const_const_const(A_RLWIMI,location^.register,newreg(R_INTREGISTER,RS_R0,R_SUBNONE),8,16,31-8));
                      a_reg_dealloc(list,NR_R0);
                      dec(tmpref.offset,2);
                    end;
{$else not cpu64bit}
{$error add 64 bit support for non power of 2 loads in a_param_ref}
{$endif not cpu64bit}
                end;
              LOC_REFERENCE:
                begin
                   reference_reset_base(ref,location^.reference.index,location^.reference.offset);
                   g_concatcopy(list,tmpref,ref,sizeleft);
                   if assigned(location^.next) then
                     internalerror(2005010710);
                end;
              LOC_FPUREGISTER,LOC_CFPUREGISTER:
                case location^.size of
                   OS_F32, OS_F64:
                     a_loadfpu_ref_reg(list,location^.size,tmpref,location^.register);
                   else
                     internalerror(2002072801);
                end;
              LOC_VOID:
                begin
                  // nothing to do
                end;
              else
                internalerror(2002081103);
            end;
            inc(tmpref.offset,tcgsize2size[location^.size]);
            dec(sizeleft,tcgsize2size[location^.size]);
            location := location^.next;
          end;
      end;


    procedure tcgppc.a_paramaddr_ref(list : TAsmList;const r : treference;const paraloc : tcgpara);
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
               tmpreg := rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
               a_loadaddr_ref_reg(list,r,tmpreg);
               a_load_reg_ref(list,OS_ADDR,OS_ADDR,tmpreg,ref);
             end;
           else
             internalerror(2002080701);
        end;
      end;


    function tcgppc.get_darwin_call_stub(const s: string): tasmsymbol;
      var
        stubname: string;
        href: treference;
        l1: tasmsymbol;
      begin
        { function declared in the current unit? }
        { doesn't work correctly, because this will also return a hit if we }
        { previously took the address of an external procedure. It doesn't  }
        { really matter, the linker will remove all unnecessary stubs.      }
{        result := current_asmdata.getasmsymbol(s);
        if not(assigned(result)) then
          begin }
            stubname := 'L'+s+'$stub';
            result := current_asmdata.getasmsymbol(stubname);
{          end; }
        if assigned(result) then
          exit;

        if current_asmdata.asmlists[al_imports]=nil then
          current_asmdata.asmlists[al_imports]:=TAsmList.create;

        current_asmdata.asmlists[al_imports].concat(Tai_section.create(sec_stub,'',0));
        current_asmdata.asmlists[al_imports].concat(Tai_align.Create(16));
        result := current_asmdata.RefAsmSymbol(stubname);
        current_asmdata.asmlists[al_imports].concat(Tai_symbol.Create(result,0));
        current_asmdata.asmlists[al_imports].concat(tai_directive.create(asd_indirect_symbol,s));
        l1 := current_asmdata.RefAsmSymbol('L'+s+'$lazy_ptr');
        reference_reset_symbol(href,l1,0);
        href.refaddr := addr_hi;
        current_asmdata.asmlists[al_imports].concat(taicpu.op_reg_ref(A_LIS,NR_R11,href));
        href.refaddr := addr_lo;
        href.base := NR_R11;
        current_asmdata.asmlists[al_imports].concat(taicpu.op_reg_ref(A_LWZU,NR_R12,href));
        current_asmdata.asmlists[al_imports].concat(taicpu.op_reg(A_MTCTR,NR_R12));
        current_asmdata.asmlists[al_imports].concat(taicpu.op_none(A_BCTR));
        current_asmdata.asmlists[al_imports].concat(tai_directive.create(asd_lazy_symbol_pointer,''));
        current_asmdata.asmlists[al_imports].concat(Tai_symbol.Create(l1,0));
        current_asmdata.asmlists[al_imports].concat(tai_directive.create(asd_indirect_symbol,s));
        current_asmdata.asmlists[al_imports].concat(tai_const.createname(strpnew('dyld_stub_binding_helper'),0));
      end;


    { calling a procedure by name }
    procedure tcgppc.a_call_name(list : TAsmList;const s : string);
      begin
         { MacOS: The linker on MacOS (PPCLink) inserts a call to glue code,
           if it is a cross-TOC call. If so, it also replaces the NOP
           with some restore code.}
         if (target_info.system <> system_powerpc_darwin) then
           begin
             list.concat(taicpu.op_sym(A_BL,current_asmdata.RefAsmSymbol(s)));
             if target_info.system=system_powerpc_macos then
               list.concat(taicpu.op_none(A_NOP));
           end
         else
           list.concat(taicpu.op_sym(A_BL,get_darwin_call_stub(s)));
{
       the compiler does not properly set this flag anymore in pass 1, and
       for now we only need it after pass 2 (I hope) (JM)
         if not(pi_do_call in current_procinfo.flags) then
           internalerror(2003060703);
}
       include(current_procinfo.flags,pi_do_call);
      end;

    { calling a procedure by address }
    procedure tcgppc.a_call_reg(list : TAsmList;reg: tregister);

      var
        tmpreg : tregister;
        tmpref : treference;

      begin
        if target_info.system=system_powerpc_macos then
          begin
            {Generate instruction to load the procedure address from
            the transition vector.}
            //TODO: Support cross-TOC calls.
            tmpreg := rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
            reference_reset(tmpref);
            tmpref.offset := 0;
            //tmpref.symaddr := refs_full;
            tmpref.base:= reg;
            list.concat(taicpu.op_reg_ref(A_LWZ,tmpreg,tmpref));
            list.concat(taicpu.op_reg(A_MTCTR,tmpreg));
          end
        else
          list.concat(taicpu.op_reg(A_MTCTR,reg));
        list.concat(taicpu.op_none(A_BCTRL));
        //if target_info.system=system_powerpc_macos then
        //  //NOP is not needed here.
        //  list.concat(taicpu.op_none(A_NOP));
        include(current_procinfo.flags,pi_do_call);
{
        if not(pi_do_call in current_procinfo.flags) then
          internalerror(2003060704);
}
        //list.concat(tai_comment.create(strpnew('***** a_call_reg')));
      end;


{********************** load instructions ********************}

     procedure tcgppc.a_load_const_reg(list : TAsmList; size: TCGSize; a : aint; reg : TRegister);

       begin
          if not(size in [OS_8,OS_S8,OS_16,OS_S16,OS_32,OS_S32]) then
            internalerror(2002090902);
          if (a >= low(smallint)) and
             (a <= high(smallint)) then
            list.concat(taicpu.op_reg_const(A_LI,reg,smallint(a)))
          else if ((a and $ffff) <> 0) then
            begin
              list.concat(taicpu.op_reg_const(A_LI,reg,smallint(a and $ffff)));
              if ((a shr 16) <> 0) or
                 (smallint(a and $ffff) < 0) then
                list.concat(taicpu.op_reg_reg_const(A_ADDIS,reg,reg,
                  smallint((a shr 16)+ord(smallint(a and $ffff) < 0))))
            end
          else
            list.concat(taicpu.op_reg_const(A_LIS,reg,smallint(a shr 16)));
       end;


     procedure tcgppc.a_load_reg_ref(list : TAsmList; fromsize, tosize: TCGSize; reg : tregister;const ref : treference);

       const
         StoreInstr: Array[OS_8..OS_32,boolean, boolean] of TAsmOp =
                                 { indexed? updating?}
                    (((A_STB,A_STBU),(A_STBX,A_STBUX)),
                     ((A_STH,A_STHU),(A_STHX,A_STHUX)),
                     ((A_STW,A_STWU),(A_STWX,A_STWUX)));
       var
         op: TAsmOp;
         ref2: TReference;
       begin
         ref2 := ref;
         fixref(list,ref2);
         if tosize in [OS_S8..OS_S16] then
           { storing is the same for signed and unsigned values }
           tosize := tcgsize(ord(tosize)-(ord(OS_S8)-ord(OS_8)));
         { 64 bit stuff should be handled separately }
         if tosize in [OS_64,OS_S64] then
           internalerror(200109236);
         op := storeinstr[tcgsize2unsigned[tosize],ref2.index<>NR_NO,false];
         a_load_store(list,op,reg,ref2);
       End;


     procedure tcgppc.a_load_ref_reg(list : TAsmList; fromsize,tosize : tcgsize;const ref: treference;reg : tregister);

       const
         LoadInstr: Array[OS_8..OS_S32,boolean, boolean] of TAsmOp =
                                { indexed? updating?}
                    (((A_LBZ,A_LBZU),(A_LBZX,A_LBZUX)),
                     ((A_LHZ,A_LHZU),(A_LHZX,A_LHZUX)),
                     ((A_LWZ,A_LWZU),(A_LWZX,A_LWZUX)),
                     { 64bit stuff should be handled separately }
                     ((A_NONE,A_NONE),(A_NONE,A_NONE)),
                     { 128bit stuff too }
                     ((A_NONE,A_NONE),(A_NONE,A_NONE)),
                     { there's no load-byte-with-sign-extend :( }
                     ((A_LBZ,A_LBZU),(A_LBZX,A_LBZUX)),
                     ((A_LHA,A_LHAU),(A_LHAX,A_LHAUX)),
                     ((A_LWZ,A_LWZU),(A_LWZX,A_LWZUX)));
       var
         op: tasmop;
         ref2: treference;

       begin
          { TODO: optimize/take into consideration fromsize/tosize. Will }
          { probably only matter for OS_S8 loads though                  }
          if not(fromsize in [OS_8,OS_S8,OS_16,OS_S16,OS_32,OS_S32]) then
            internalerror(2002090902);
          ref2 := ref;
          fixref(list,ref2);
          { the caller is expected to have adjusted the reference already }
          { in this case                                                  }
          if (TCGSize2Size[fromsize] >= TCGSize2Size[tosize]) then
            fromsize := tosize;
          op := loadinstr[fromsize,ref2.index<>NR_NO,false];
          a_load_store(list,op,reg,ref2);
          { sign extend shortint if necessary, since there is no }
          { load instruction that does that automatically (JM)   }
          if fromsize = OS_S8 then
            list.concat(taicpu.op_reg_reg(A_EXTSB,reg,reg));
       end;


     procedure tcgppc.a_load_reg_reg(list : TAsmList;fromsize, tosize : tcgsize;reg1,reg2 : tregister);

       var
         instr: taicpu;
       begin
         if (tcgsize2size[fromsize] > tcgsize2size[tosize]) or
            ((tcgsize2size[fromsize] = tcgsize2size[tosize]) and
             (fromsize <> tosize)) or
            { needs to mask out the sign in the top 16 bits }
            ((fromsize = OS_S8) and
             (tosize = OS_16)) then
           case tosize of
             OS_8:
               instr := taicpu.op_reg_reg_const_const_const(A_RLWINM,
                 reg2,reg1,0,31-8+1,31);
             OS_S8:
               instr := taicpu.op_reg_reg(A_EXTSB,reg2,reg1);
             OS_16:
               instr := taicpu.op_reg_reg_const_const_const(A_RLWINM,
                 reg2,reg1,0,31-16+1,31);
             OS_S16:
               instr := taicpu.op_reg_reg(A_EXTSH,reg2,reg1);
             OS_32,OS_S32:
               instr := taicpu.op_reg_reg(A_MR,reg2,reg1);
             else internalerror(2002090901);
           end
         else
           instr := taicpu.op_reg_reg(A_MR,reg2,reg1);
           
         list.concat(instr);
         rg[R_INTREGISTER].add_move_instruction(instr);
       end;


     procedure tcgppc.a_load_subsetreg_reg(list : TAsmList; subsetregsize, subsetsize: tcgsize;
       startbit: byte; tosize: tcgsize; subsetreg, destreg: tregister);

       begin
         if (tcgsize2size[subsetsize] <> sizeof(aint)) then
           begin
             list.concat(taicpu.op_reg_reg_const_const_const(A_RLWINM,destreg,
               subsetreg,(32-startbit) and 31,32-tcgsize2size[subsetsize]*8,31));
             a_load_reg_reg(list,tcgsize2unsigned[subsetsize],subsetsize,destreg,destreg);
             a_load_reg_reg(list,subsetsize,tosize,destreg,destreg);
           end
         else
           a_load_reg_reg(list,subsetsize,tosize,subsetreg,destreg);
       end;


     procedure tcgppc.a_load_reg_subsetreg(list : TAsmList; fromsize: tcgsize; subsetregsize, 
       subsetsize: tcgsize; startbit: byte; fromreg, subsetreg: tregister);

       begin
         if ((tcgsize2size[subsetsize]) <> sizeof(aint)) then
           list.concat(taicpu.op_reg_reg_const_const_const(A_RLWIMI,subsetreg,fromreg,
             startbit,32-startbit-tcgsize2size[subsetsize]*8,31-startbit))
         else
           a_load_reg_reg(list,fromsize,subsetsize,fromreg,subsetreg);
       end;


       procedure tcgppc.a_load_subsetreg_subsetreg(list: TAsmlist; fromsubsetregsize, fromsubsetsize: tcgsize; fromstartbit: byte;
         tosubsetregsize, tosubsetsize: tcgsize; tostartbit: byte; fromsubsetreg, tosubsetreg: tregister);

         begin
           if (tcgsize2size[fromsubsetsize] >= tcgsize2size[tosubsetsize]) then
             list.concat(taicpu.op_reg_reg_const_const_const(A_RLWIMI,tosubsetreg, fromsubsetreg,
                (tostartbit-fromstartbit) and 31,
                32-tostartbit-tcgsize2size[tosubsetsize]*8,31-tostartbit))
           else
             inherited a_load_subsetreg_subsetreg(list,fromsubsetregsize,fromsubsetsize,fromstartbit,tosubsetregsize,tosubsetsize,tostartbit,fromsubsetreg,tosubsetreg);
         end;


     procedure tcgppc.a_loadfpu_reg_reg(list: TAsmList; size: tcgsize; reg1, reg2: tregister);

       var
         instr: taicpu;
       begin
         instr :=  taicpu.op_reg_reg(A_FMR,reg2,reg1);
         list.concat(instr);
         rg[R_FPUREGISTER].add_move_instruction(instr);
       end;


     procedure tcgppc.a_loadfpu_ref_reg(list: TAsmList; size: tcgsize; const ref: treference; reg: tregister);

       const
         FpuLoadInstr: Array[OS_F32..OS_F64,boolean, boolean] of TAsmOp =
                          { indexed? updating?}
                    (((A_LFS,A_LFSU),(A_LFSX,A_LFSUX)),
                     ((A_LFD,A_LFDU),(A_LFDX,A_LFDUX)));
       var
         op: tasmop;
         ref2: treference;

       begin
          { several functions call this procedure with OS_32 or OS_64 }
          { so this makes life easier (FK)                            }
          case size of
             OS_32,OS_F32:
               size:=OS_F32;
             OS_64,OS_F64,OS_C64:
               size:=OS_F64;
             else
               internalerror(200201121);
          end;
         ref2 := ref;
         fixref(list,ref2);
         op := fpuloadinstr[size,ref2.index <> NR_NO,false];
         a_load_store(list,op,reg,ref2);
       end;


     procedure tcgppc.a_loadfpu_reg_ref(list: TAsmList; size: tcgsize; reg: tregister; const ref: treference);

       const
         FpuStoreInstr: Array[OS_F32..OS_F64,boolean, boolean] of TAsmOp =
                            { indexed? updating?}
                    (((A_STFS,A_STFSU),(A_STFSX,A_STFSUX)),
                     ((A_STFD,A_STFDU),(A_STFDX,A_STFDUX)));
       var
         op: tasmop;
         ref2: treference;

       begin
         if not(size in [OS_F32,OS_F64]) then
           internalerror(200201122);
         ref2 := ref;
         fixref(list,ref2);
         op := fpustoreinstr[size,ref2.index <> NR_NO,false];
         a_load_store(list,op,reg,ref2);
       end;


     procedure tcgppc.a_op_const_reg(list : TAsmList; Op: TOpCG; size: TCGSize; a: aint; reg: TRegister);

       begin
         a_op_const_reg_reg(list,op,size,a,reg,reg);
       end;


      procedure tcgppc.a_op_reg_reg(list : TAsmList; Op: TOpCG; size: TCGSize; src, dst: TRegister);

         begin
           a_op_reg_reg_reg(list,op,size,src,dst,dst);
         end;


    procedure tcgppc.maybeadjustresult(list: TAsmList; op: TOpCg; size: tcgsize; dst: tregister);
      const
        overflowops = [OP_MUL,OP_SHL,OP_ADD,OP_SUB,OP_NOT,OP_NEG];
      begin
        if (op in overflowops) and
           (size in [OS_8,OS_S8,OS_16,OS_S16]) then
          a_load_reg_reg(list,OS_32,size,dst,dst);
      end;


    procedure tcgppc.a_op_const_reg_reg(list: TAsmList; op: TOpCg;
                       size: tcgsize; a: aint; src, dst: tregister);
      var
        l1,l2: longint;
        oplo, ophi: tasmop;
        scratchreg: tregister;
        useReg, gotrlwi: boolean;


        procedure do_lo_hi;
          begin
            list.concat(taicpu.op_reg_reg_const(oplo,dst,src,word(a)));
            list.concat(taicpu.op_reg_reg_const(ophi,dst,dst,word(a shr 16)));
          end;

      begin
        if (op = OP_MOVE) then
          internalerror(2006031401);
        if op = OP_SUB then
          begin
            a_op_const_reg_reg(list,OP_ADD,size,-a,src,dst);
            exit;
          end;
        ophi := TOpCG2AsmOpConstHi[op];
        oplo := TOpCG2AsmOpConstLo[op];
        gotrlwi := get_rlwi_const(a,l1,l2);
        if (op in [OP_AND,OP_OR,OP_XOR]) then
          begin
            if (a = 0) then
              begin
                if op = OP_AND then
                  list.concat(taicpu.op_reg_const(A_LI,dst,0))
                else
                  a_load_reg_reg(list,size,size,src,dst);
                exit;
              end
            else if (a = -1) then
              begin
                case op of
                  OP_OR:
                    case size of
                      OS_8, OS_S8:
                        list.concat(taicpu.op_reg_const(A_LI,dst,255));
                      OS_16, OS_S16:
                        a_load_const_reg(list,OS_16,65535,dst);
                      else
                        list.concat(taicpu.op_reg_const(A_LI,dst,-1));
                    end;
                  OP_XOR:
                    case size of
                      OS_8, OS_S8:
                        list.concat(taicpu.op_reg_reg_const(A_XORI,dst,src,255));
                      OS_16, OS_S16:
                        list.concat(taicpu.op_reg_reg_const(A_XORI,dst,src,65535));
                      else
                        list.concat(taicpu.op_reg_reg(A_NOT,dst,src));
                    end;
                  OP_AND:
                    a_load_reg_reg(list,size,size,src,dst);
                end;
                exit;
              end
            else if (aword(a) <= high(word)) and
               ((op <> OP_AND) or
                not gotrlwi) then
              begin
                if ((size = OS_8) and
                    (byte(a) <> a)) or
                   ((size = OS_S8) and
                    (shortint(a) <> a)) then
                  internalerror(200604142);
                list.concat(taicpu.op_reg_reg_const(oplo,dst,src,word(a)));
                { and/or/xor -> cannot overflow in high 16 bits }
                exit;
              end;
            { all basic constant instructions also have a shifted form that }
            { works only on the highest 16bits, so if lo(a) is 0, we can    }
            { use that one                                                  }
            if (word(a) = 0) and
               (not(op = OP_AND) or
                not gotrlwi) then
              begin
                if (size in [OS_8,OS_S8,OS_16,OS_S16]) then
                  internalerror(200604141);
                list.concat(taicpu.op_reg_reg_const(ophi,dst,src,word(a shr 16)));
                exit;
              end;
          end
        else if (op = OP_ADD) then
          if a = 0 then
            begin
              a_load_reg_reg(list,size,size,src,dst);
              exit
            end
          else if (a >= low(smallint)) and
                  (a <= high(smallint)) then
             begin
               list.concat(taicpu.op_reg_reg_const(A_ADDI,dst,src,smallint(a)));
               maybeadjustresult(list,op,size,dst);
               exit;
             end;

        { otherwise, the instructions we can generate depend on the }
        { operation                                                 }
        useReg := false;
        case op of
          OP_DIV,OP_IDIV:
             if (a = 0) then
               internalerror(200208103)
             else if (a = 1) then
               begin
                 a_load_reg_reg(list,OS_INT,OS_INT,src,dst);
                 exit
               end
            else if ispowerof2(a,l1) then
              begin
                case op of
                  OP_DIV:
                    list.concat(taicpu.op_reg_reg_const(A_SRWI,dst,src,l1));
                  OP_IDIV:
                    begin
                       list.concat(taicpu.op_reg_reg_const(A_SRAWI,dst,src,l1));
                       list.concat(taicpu.op_reg_reg(A_ADDZE,dst,dst));
                    end;
                end;
                exit;
              end
            else
              usereg := true;
           OP_IMUL, OP_MUL:
             if (a = 0) then
               begin
                 list.concat(taicpu.op_reg_const(A_LI,dst,0));
                 exit
               end
             else if (a = 1) then
               begin
                 a_load_reg_reg(list,OS_INT,OS_INT,src,dst);
                 exit
               end
             else if ispowerof2(a,l1) then
               list.concat(taicpu.op_reg_reg_const(A_SLWI,dst,src,l1))
             else if (longint(a) >= low(smallint)) and
                (longint(a) <= high(smallint)) then
               list.concat(taicpu.op_reg_reg_const(A_MULLI,dst,src,smallint(a)))
             else
               usereg := true;
          OP_ADD:
            begin
              list.concat(taicpu.op_reg_reg_const(oplo,dst,src,smallint(a)));
              list.concat(taicpu.op_reg_reg_const(ophi,dst,dst,
                smallint((a shr 16) + ord(smallint(a) < 0))));
            end;
          OP_OR:
            { try to use rlwimi }
            if gotrlwi and
               (src = dst) then
              begin
                scratchreg := rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
                list.concat(taicpu.op_reg_const(A_LI,scratchreg,-1));
                list.concat(taicpu.op_reg_reg_const_const_const(A_RLWIMI,dst,
                  scratchreg,0,l1,l2));
              end
            else
              do_lo_hi;
          OP_AND:
            { try to use rlwinm }
            if gotrlwi then
              list.concat(taicpu.op_reg_reg_const_const_const(A_RLWINM,dst,
                src,0,l1,l2))
            else
              useReg := true;
          OP_XOR:
            do_lo_hi;
          OP_SHL,OP_SHR,OP_SAR:
            begin
              if (a and 31) <> 0 Then
                list.concat(taicpu.op_reg_reg_const(
                  TOpCG2AsmOpConstLo[Op],dst,src,a and 31))
              else
                a_load_reg_reg(list,size,size,src,dst);
              if (a shr 5) <> 0 then
                internalError(68991);
            end
          else
            internalerror(200109091);
        end;
        { if all else failed, load the constant in a register and then }
        { perform the operation                                        }
        if useReg then
          begin
            scratchreg := rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
            a_load_const_reg(list,OS_32,a,scratchreg);
            a_op_reg_reg_reg(list,op,OS_32,scratchreg,src,dst);
          end;
        maybeadjustresult(list,op,size,dst);
      end;


    procedure tcgppc.a_op_reg_reg_reg(list: TAsmList; op: TOpCg;
      size: tcgsize; src1, src2, dst: tregister);

      const
        op_reg_reg_opcg2asmop: array[TOpCG] of tasmop =
          (A_NONE,A_MR,A_ADD,A_AND,A_DIVWU,A_DIVW,A_MULLW,A_MULLW,A_NEG,A_NOT,A_OR,
           A_SRAW,A_SLW,A_SRW,A_SUB,A_XOR);

       begin
         if (op = OP_MOVE) then
           internalerror(2006031402);
         case op of
           OP_NEG,OP_NOT:
             begin
               list.concat(taicpu.op_reg_reg(op_reg_reg_opcg2asmop[op],dst,src1));
               if (op = OP_NOT) and
                  not(size in [OS_32,OS_S32]) then
                 { zero/sign extend result again }
                 a_load_reg_reg(list,OS_32,size,dst,dst);
              end;
           else
             list.concat(taicpu.op_reg_reg_reg(op_reg_reg_opcg2asmop[op],dst,src2,src1));
         end;
         maybeadjustresult(list,op,size,dst);
       end;


{*************** compare instructructions ****************}

      procedure tcgppc.a_cmp_const_reg_label(list : TAsmList;size : tcgsize;cmp_op : topcmp;a : aint;reg : tregister;
        l : tasmlabel);

        var
          scratch_register: TRegister;
          signed: boolean;

        begin
          signed := cmp_op in [OC_GT,OC_LT,OC_GTE,OC_LTE,OC_EQ,OC_NE];
          { in the following case, we generate more efficient code when }
          { signed is false                                              }
          if (cmp_op in [OC_EQ,OC_NE]) and
             (aword(a) >= $8000) and
             (aword(a) <= $ffff) then
            signed := false;
          if signed then
            if (a >= low(smallint)) and (a <= high(smallint)) Then
              list.concat(taicpu.op_reg_reg_const(A_CMPWI,NR_CR0,reg,a))
            else
              begin
                scratch_register := rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
                a_load_const_reg(list,OS_32,a,scratch_register);
                list.concat(taicpu.op_reg_reg_reg(A_CMPW,NR_CR0,reg,scratch_register));
              end
          else
            if (aword(a) <= $ffff) then
              list.concat(taicpu.op_reg_reg_const(A_CMPLWI,NR_CR0,reg,aword(a)))
            else
              begin
                scratch_register := rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
                a_load_const_reg(list,OS_32,a,scratch_register);
                list.concat(taicpu.op_reg_reg_reg(A_CMPLW,NR_CR0,reg,scratch_register));
              end;
          a_jmp(list,A_BC,TOpCmp2AsmCond[cmp_op],0,l);
        end;


      procedure tcgppc.a_cmp_reg_reg_label(list : TAsmList;size : tcgsize;cmp_op : topcmp;
        reg1,reg2 : tregister;l : tasmlabel);

        var
          op: tasmop;

        begin
          if cmp_op in [OC_GT,OC_LT,OC_GTE,OC_LTE] then
            op := A_CMPW
          else
            op := A_CMPLW;
          list.concat(taicpu.op_reg_reg_reg(op,NR_CR0,reg2,reg1));
          a_jmp(list,A_BC,TOpCmp2AsmCond[cmp_op],0,l);
        end;


     procedure tcgppc.a_jmp_cond(list : TAsmList;cond : TOpCmp;l: tasmlabel);

       begin
         a_jmp(list,A_BC,TOpCmp2AsmCond[cond],0,l);
       end;


    procedure tcgppc.a_jmp_name(list : TAsmList;const s : string);
      var
        p : taicpu;
      begin
         if (target_info.system = system_powerpc_darwin) then
           p := taicpu.op_sym(A_B,get_darwin_call_stub(s))
        else
          p := taicpu.op_sym(A_B,current_asmdata.RefAsmSymbol(s));
        p.is_jmp := true;
        list.concat(p)
      end;


     procedure tcgppc.a_jmp_always(list : TAsmList;l: tasmlabel);

       begin
         a_jmp(list,A_B,C_None,0,l);
       end;

     procedure tcgppc.a_jmp_flags(list : TAsmList;const f : TResFlags;l: tasmlabel);

       var
         c: tasmcond;
       begin
         c := flags_to_cond(f);
         a_jmp(list,A_BC,c.cond,c.cr-RS_CR0,l);
       end;

     procedure tcgppc.g_flags2reg(list: TAsmList; size: TCgSize; const f: TResFlags; reg: TRegister);

       var
         testbit: byte;
         bitvalue: boolean;

       begin
         { get the bit to extract from the conditional register + its }
         { requested value (0 or 1)                                   }
         testbit := ((f.cr-RS_CR0) * 4);
         case f.flag of
           F_EQ,F_NE:
             begin
               inc(testbit,2);
               bitvalue := f.flag = F_EQ;
             end;
           F_LT,F_GE:
             begin
               bitvalue := f.flag = F_LT;
             end;
           F_GT,F_LE:
             begin
               inc(testbit);
               bitvalue := f.flag = F_GT;
             end;
           else
             internalerror(200112261);
         end;
         { load the conditional register in the destination reg }
         list.concat(taicpu.op_reg(A_MFCR,reg));
         { we will move the bit that has to be tested to bit 0 by rotating }
         { left                                                            }
         testbit := (testbit + 1) and 31;
         { extract bit }
         list.concat(taicpu.op_reg_reg_const_const_const(
           A_RLWINM,reg,reg,testbit,31,31));
         { if we need the inverse, xor with 1 }
         if not bitvalue then
           list.concat(taicpu.op_reg_reg_const(A_XORI,reg,reg,1));
       end;

(*
     procedure tcgppc.g_cond2reg(list: TAsmList; const f: TAsmCond; reg: TRegister);

       var
         testbit: byte;
         bitvalue: boolean;

       begin
         { get the bit to extract from the conditional register + its }
         { requested value (0 or 1)                                   }
         case f.simple of
           false:
             begin
               { we don't generate this in the compiler }
               internalerror(200109062);
             end;
           true:
             case f.cond of
               C_None:
                 internalerror(200109063);
               C_LT..C_NU:
                 begin
                   testbit := (ord(f.cr) - ord(R_CR0))*4;
                   inc(testbit,AsmCondFlag2BI[f.cond]);
                   bitvalue := AsmCondFlagTF[f.cond];
                 end;
               C_T,C_F,C_DNZT,C_DNZF,C_DZT,C_DZF:
                 begin
                   testbit := f.crbit
                   bitvalue := AsmCondFlagTF[f.cond];
                 end;
               else
                 internalerror(200109064);
             end;
         end;
         { load the conditional register in the destination reg }
         list.concat(taicpu.op_reg_reg(A_MFCR,reg));
         { we will move the bit that has to be tested to bit 31 -> rotate }
         { left by bitpos+1 (remember, this is big-endian!)               }
         if bitpos <> 31 then
           inc(bitpos)
         else
           bitpos := 0;
         { extract bit }
         list.concat(taicpu.op_reg_reg_const_const_const(
           A_RLWINM,reg,reg,bitpos,31,31));
         { if we need the inverse, xor with 1 }
         if not bitvalue then
           list.concat(taicpu.op_reg_reg_const(A_XORI,reg,reg,1));
       end;
*)

{ *********** entry/exit code and address loading ************ }

    procedure tcgppc.g_save_standard_registers(list:TAsmList);
      begin
        { this work is done in g_proc_entry }
      end;


    procedure tcgppc.g_restore_standard_registers(list:TAsmList);
      begin
        { this work is done in g_proc_exit }
      end;


    procedure tcgppc.g_proc_entry(list : TAsmList;localsize : longint;nostackframe:boolean);
     { generated the entry code of a procedure/function. Note: localsize is the }
     { sum of the size necessary for local variables and the maximum possible   }
     { combined size of ALL the parameters of a procedure called by the current }
     { one.                                                                     }
     { This procedure may be called before, as well as after g_return_from_proc }
     { is called. NOTE registers are not to be allocated through the register   }
     { allocator here, because the register colouring has already occured !!    }


     var regcounter,firstregfpu,firstregint: TSuperRegister;
         href : treference;
         usesfpr,usesgpr,gotgot : boolean;
         cond : tasmcond;
         instr : taicpu;

      begin
        { CR and LR only have to be saved in case they are modified by the current }
        { procedure, but currently this isn't checked, so save them always         }
        { following is the entry code as described in "Altivec Programming }
        { Interface Manual", bar the saving of AltiVec registers           }
        a_reg_alloc(list,NR_STACK_POINTER_REG);

        usesgpr := false;
        usesfpr := false;
        if not(po_assembler in current_procinfo.procdef.procoptions) then
          begin
            { save link register? }
            if (pi_do_call in current_procinfo.flags) or
               ([cs_lineinfo,cs_debuginfo] * aktmoduleswitches <> []) then
              begin
                a_reg_alloc(list,NR_R0);
                { save return address... }
                list.concat(taicpu.op_reg(A_MFLR,NR_R0));
                { ... in caller's frame }
                case target_info.abi of
                  abi_powerpc_aix:
                    reference_reset_base(href,NR_STACK_POINTER_REG,LA_LR_AIX);
                  abi_powerpc_sysv:
                    reference_reset_base(href,NR_STACK_POINTER_REG,LA_LR_SYSV);
                end;
                list.concat(taicpu.op_reg_ref(A_STW,NR_R0,href));
                a_reg_dealloc(list,NR_R0);
              end;

(*
            { save the CR if necessary in callers frame. }
            if target_info.abi = abi_powerpc_aix then
              if false then { Not needed at the moment. }
                begin
                  a_reg_alloc(list,NR_R0);
                  list.concat(taicpu.op_reg_reg(A_MFSPR,NR_R0,NR_CR));
                  reference_reset_base(href,NR_STACK_POINTER_REG,LA_CR_AIX);
                  list.concat(taicpu.op_reg_ref(A_STW,NR_R0,href));
                  a_reg_dealloc(list,NR_R0);
                end;
*)

            firstregfpu := tppcprocinfo(current_procinfo).get_first_save_fpu_reg;
            firstregint := tppcprocinfo(current_procinfo).get_first_save_int_reg;
            usesgpr := firstregint <> 32;
            usesfpr := firstregfpu <> 32;

             if (tppcprocinfo(current_procinfo).needs_frame_pointer) then
              begin
                a_reg_alloc(list,NR_R12);
                list.concat(taicpu.op_reg_reg(A_MR,NR_R12,NR_STACK_POINTER_REG));
              end;
          end;

        { no GOT pointer loaded yet }
        gotgot:=false;
        if usesfpr then
          begin
{            save floating-point registers
             if (cs_create_pic in aktmoduleswitches) and not(usesgpr) then
               begin
                  a_call_name(current_asmdata.RefAsmSymbol('_savefpr_'+tostr(ord(firstregfpu)-ord(R_F14)+14)+'_g'));
                  gotgot:=true;
               end
             else
               a_call_name(current_asmdata.RefAsmSymbol('_savefpr_'+tostr(ord(firstregfpu)-ord(R_F14)+14)));
}

             reference_reset_base(href,NR_R1,-8);
             for regcounter:=firstregfpu to RS_F31 do
               begin
                 a_loadfpu_reg_ref(list,OS_F64,newreg(R_FPUREGISTER,regcounter,R_SUBNONE),href);
                 dec(href.offset,8);
               end;
             { compute start of gpr save area }
             inc(href.offset,4);
          end
        else
          { compute start of gpr save area }
          reference_reset_base(href,NR_R1,-4);

        { save gprs and fetch GOT pointer }
        if usesgpr then
          begin
             {
             if cs_create_pic in aktmoduleswitches then
               begin
                  a_call_name(current_asmdata.RefAsmSymbol('_savegpr_'+tostr(ord(firstreggpr)-ord(R_14)+14)+'_g'));
                  gotgot:=true;
               end
             else
               a_call_name(current_asmdata.RefAsmSymbol('_savegpr_'+tostr(ord(firstreggpr)-ord(R_14)+14)))
             }
            if (firstregint <= RS_R22) or
               ((cs_opt_size in aktoptimizerswitches) and
               { with RS_R30 it's also already smaller, but too big a speed trade-off to make }
                (firstregint <= RS_R29)) then
              begin
                dec(href.offset,(RS_R31-firstregint)*sizeof(aint));
                list.concat(taicpu.op_reg_ref(A_STMW,newreg(R_INTREGISTER,firstregint,R_SUBNONE),href));
              end
            else
              for regcounter:=firstregint to RS_R31 do
                begin
                  a_load_reg_ref(list,OS_INT,OS_INT,newreg(R_INTREGISTER,regcounter,R_SUBNONE),href);
                  dec(href.offset,4);
                end;
          end;

{        done in ncgutil because it may only be released after the parameters }
{        have been moved to their final resting place                         }
{        if (tppcprocinfo(current_procinfo).needs_frame_pointer) then }
{          a_reg_dealloc(list,NR_R12); }


        { if we didn't get the GOT pointer till now, we've to calculate it now }
(*
        if not(gotgot) and (pi_needs_got in current_procinfo.flags) then
          case target_info.system of
            system_powerpc_darwin:
              begin
                list.concat(taicpu.op_reg_reg(A_MFSPR,NR_R0,NR_LR));
                fillchar(cond,sizeof(cond),0);
                cond.simple:=false;
                cond.bo:=20;
                cond.bi:=31;
                instr:=taicpu.op_sym(A_BCL,current_procinfo.CurrGOTLabel);
                instr.setcondition(cond);
                list.concat(instr);
                a_label(list,current_procinfo.CurrGOTLabel);
                list.concat(taicpu.op_reg_reg(A_MFSPR,current_procinfo.got,NR_LR));
                list.concat(taicpu.op_reg_reg(A_MTSPR,NR_LR,NR_R0));
              end;
            else
              begin
                a_reg_alloc(list,NR_R31);
                { place GOT ptr in r31 }
                list.concat(taicpu.op_reg_reg(A_MFSPR,NR_R31,NR_LR));
              end;
          end;
*)

        if (not nostackframe) and
           (localsize <> 0) then
          begin
            if (localsize <= high(smallint)) then
              begin
                reference_reset_base(href,NR_STACK_POINTER_REG,-localsize);
                a_load_store(list,A_STWU,NR_STACK_POINTER_REG,href);
              end
            else
              begin
                reference_reset_base(href,NR_STACK_POINTER_REG,0);
                { can't use getregisterint here, the register colouring }
                { is already done when we get here                      }
                href.index := NR_R11;
                a_reg_alloc(list,href.index);
                a_load_const_reg(list,OS_S32,-localsize,href.index);
                a_load_store(list,A_STWUX,NR_STACK_POINTER_REG,href);
                a_reg_dealloc(list,href.index);
              end;
          end;

        { save the CR if necessary ( !!! never done currently ) }
{       still need to find out where this has to be done for SystemV
        a_reg_alloc(list,R_0);
        list.concat(taicpu.op_reg_reg(A_MFSPR,R_0,R_CR);
        list.concat(taicpu.op_reg_ref(A_STW,scratch_register,
          new_reference(STACK_POINTER_REG,LA_CR)));
        a_reg_dealloc(list,R_0);
}
        { now comes the AltiVec context save, not yet implemented !!! }

      end;


    procedure tcgppc.g_proc_exit(list : TAsmList;parasize : longint;nostackframe:boolean);
     { This procedure may be called before, as well as after g_stackframe_entry }
     { is called. NOTE registers are not to be allocated through the register   }
     { allocator here, because the register colouring has already occured !!    }

      var
         regcounter,firstregfpu,firstregint: TsuperRegister;
         href : treference;
         usesfpr,usesgpr,genret : boolean;
         localsize: aint;
      begin
        { AltiVec context restore, not yet implemented !!! }

        usesfpr:=false;
        usesgpr:=false;
        if not (po_assembler in current_procinfo.procdef.procoptions) then
          begin
            firstregfpu := tppcprocinfo(current_procinfo).get_first_save_fpu_reg;
            firstregint := tppcprocinfo(current_procinfo).get_first_save_int_reg;
            usesgpr := firstregint <> 32;
            usesfpr := firstregfpu <> 32;
          end;

        localsize:= tppcprocinfo(current_procinfo).calc_stackframe_size;

        { adjust r1 }
        { (register allocator is no longer valid at this time and an add of 0   }
        { is translated into a move, which is then registered with the register }
        { allocator, causing a crash                                            }
        if (not nostackframe) and
           (localsize <> 0) then
          a_op_const_reg(list,OP_ADD,OS_ADDR,localsize,NR_R1);

        { no return (blr) generated yet }
        genret:=true;
        if usesfpr then
          begin
            reference_reset_base(href,NR_R1,-8);
            for regcounter := firstregfpu to RS_F31 do
              begin
                a_loadfpu_ref_reg(list,OS_F64,href,newreg(R_FPUREGISTER,regcounter,R_SUBNONE));
                dec(href.offset,8);
              end;
            inc(href.offset,4);
          end
        else
          reference_reset_base(href,NR_R1,-4);

        if (usesgpr) then
          begin
            if (firstregint <= RS_R22) or
               ((cs_opt_size in aktoptimizerswitches) and
                { with RS_R30 it's also already smaller, but too big a speed trade-off to make }
                (firstregint <= RS_R29)) then
              begin
                dec(href.offset,(RS_R31-firstregint)*sizeof(aint));
                list.concat(taicpu.op_reg_ref(A_LMW,newreg(R_INTREGISTER,firstregint,R_SUBNONE),href));
              end
            else
              for regcounter:=firstregint to RS_R31 do
                begin
                  a_load_ref_reg(list,OS_INT,OS_INT,href,newreg(R_INTREGISTER,regcounter,R_SUBNONE));
                  dec(href.offset,4);
                end;
          end;

(*
        { restore fprs and return }
        if usesfpr then
          begin
             { address of fpr save area to r11 }
             r:=NR_R12;
             list.concat(taicpu.op_reg_reg_const(A_ADDI,r,r,(ord(R_F31)-ord(firstregfpu.enum)+1)*8));
             {
             if (pi_do_call in current_procinfo.flags) then
               a_call_name(current_asmdata.RefAsmSymbol('_restfpr_'+tostr(ord(firstregfpu)-ord(R_F14)+14)+'_x'))
             else
               { leaf node => lr haven't to be restored }
               a_call_name('_restfpr_'+tostr(ord(firstregfpu.enum)-ord(R_F14)+14)+'_l');
             genret:=false;
             }
          end;
*)

        { if we didn't generate the return code, we've to do it now }
        if genret then
          begin
            { load link register? }
            if not (po_assembler in current_procinfo.procdef.procoptions) then
              begin
                if (pi_do_call in current_procinfo.flags) then
                  begin
                    case target_info.abi of
                      abi_powerpc_aix:
                        reference_reset_base(href,NR_STACK_POINTER_REG,LA_LR_AIX);
                      abi_powerpc_sysv:
                        reference_reset_base(href,NR_STACK_POINTER_REG,LA_LR_SYSV);
                    end;
                    list.concat(taicpu.op_reg_ref(A_LWZ,NR_R0,href));
                    list.concat(taicpu.op_reg(A_MTLR,NR_R0));
                  end;

(*
                  { restore the CR if necessary from callers frame}
                  if target_info.abi = abi_powerpc_aix then
                    if false then { Not needed at the moment. }
                      begin
                        reference_reset_base(href,NR_STACK_POINTER_REG,LA_CR_AIX);
                        list.concat(taicpu.op_reg_ref(A_LWZ,NR_R0,href));
                        list.concat(taicpu.op_reg_reg(A_MTSPR,NR_R0,NR_CR));
                        a_reg_dealloc(list,NR_R0);
                      end;
*)
              end;

            list.concat(taicpu.op_none(A_BLR));
          end;
      end;


    function tcgppc.save_regs(list : TAsmList):longint;
    {Generates code which saves used non-volatile registers in
     the save area right below the address the stackpointer point to.
     Returns the actual used save area size.}

     var regcounter,firstregfpu,firstreggpr: TSuperRegister;
         usesfpr,usesgpr: boolean;
         href : treference;
         offset: aint;
         regcounter2, firstfpureg: Tsuperregister;
    begin
      usesfpr:=false;
      if not (po_assembler in current_procinfo.procdef.procoptions) then
        begin
            { FIXME: has to be R_F14 instad of R_F8 for SYSV-64bit }
            case target_info.abi of
              abi_powerpc_aix:
                firstfpureg := RS_F14;
              abi_powerpc_sysv:
                firstfpureg := RS_F9;
              else
                internalerror(2003122903);
            end;
          for regcounter:=firstfpureg to RS_F31 do
           begin
             if regcounter in rg[R_FPUREGISTER].used_in_proc then
              begin
                 usesfpr:=true;
                 firstregfpu:=regcounter;
                 break;
              end;
           end;
        end;
      usesgpr:=false;
      if not (po_assembler in current_procinfo.procdef.procoptions) then
        for regcounter2:=RS_R13 to RS_R31 do
          begin
            if regcounter2 in rg[R_INTREGISTER].used_in_proc then
              begin
                 usesgpr:=true;
                 firstreggpr:=regcounter2;
                 break;
              end;
          end;
      offset:= 0;

      { save floating-point registers }
      if usesfpr then
        for regcounter := firstregfpu to RS_F31 do
          begin
            offset:= offset - 8;
            reference_reset_base(href, NR_STACK_POINTER_REG, offset);
            list.concat(taicpu.op_reg_ref(A_STFD, tregister(regcounter), href));
          end;
        (* Optimiztion in the future:  a_call_name(list,'_savefXX'); *)

      { save gprs in gpr save area }
      if usesgpr then
        if firstreggpr < RS_R30 then
          begin
            offset:= offset - 4 * (RS_R31 - firstreggpr + 1);
            reference_reset_base(href,NR_STACK_POINTER_REG,offset);
            list.concat(taicpu.op_reg_ref(A_STMW,tregister(firstreggpr),href));
              {STMW stores multiple registers}
          end
        else
          begin
            for regcounter := firstreggpr to RS_R31 do
              begin
                offset:= offset - 4;
                reference_reset_base(href, NR_STACK_POINTER_REG, offset);
                list.concat(taicpu.op_reg_ref(A_STW, newreg(R_INTREGISTER,regcounter,R_SUBWHOLE), href));
              end;
          end;

      { now comes the AltiVec context save, not yet implemented !!! }

      save_regs:= -offset;
    end;

    procedure tcgppc.restore_regs(list : TAsmList);
    {Generates code which restores used non-volatile registers from
    the save area right below the address the stackpointer point to.}

     var regcounter,firstregfpu,firstreggpr: TSuperRegister;
         usesfpr,usesgpr: boolean;
         href : treference;
         offset: integer;
         regcounter2, firstfpureg: Tsuperregister;

    begin
      usesfpr:=false;
      if not (po_assembler in current_procinfo.procdef.procoptions) then
        begin
          { FIXME: has to be R_F14 instad of R_F8 for SYSV-64bit }
          case target_info.abi of
            abi_powerpc_aix:
              firstfpureg := RS_F14;
            abi_powerpc_sysv:
              firstfpureg := RS_F9;
            else
              internalerror(2003122903);
          end;
          for regcounter:=firstfpureg to RS_F31 do
           begin
             if regcounter in rg[R_FPUREGISTER].used_in_proc then
              begin
                 usesfpr:=true;
                 firstregfpu:=regcounter;
                 break;
              end;
           end;
        end;

      usesgpr:=false;
      if not (po_assembler in current_procinfo.procdef.procoptions) then
        for regcounter2:=RS_R13 to RS_R31 do
          begin
            if regcounter2 in rg[R_INTREGISTER].used_in_proc then
              begin
                 usesgpr:=true;
                 firstreggpr:=regcounter2;
                 break;
              end;
          end;

      offset:= 0;

      { restore fp registers }
      if usesfpr then
        for regcounter := firstregfpu to RS_F31 do
          begin
            offset:= offset - 8;
            reference_reset_base(href, NR_STACK_POINTER_REG, offset);
            list.concat(taicpu.op_reg_ref(A_LFD, newreg(R_FPUREGISTER,regcounter,R_SUBWHOLE), href));
          end;
        (* Optimiztion in the future: a_call_name(list,'_restfXX'); *)

      { restore gprs }
      if usesgpr then
        if firstreggpr < RS_R30 then
          begin
            offset:= offset - 4 * (RS_R31 - firstreggpr + 1);
            reference_reset_base(href,NR_STACK_POINTER_REG,offset); //-220
            list.concat(taicpu.op_reg_ref(A_LMW,tregister(firstreggpr),href));
              {LMW loads multiple registers}
          end
        else
          begin
            for regcounter := firstreggpr to RS_R31 do
              begin
                offset:= offset - 4;
                reference_reset_base(href, NR_STACK_POINTER_REG, offset);
                list.concat(taicpu.op_reg_ref(A_LWZ, newreg(R_INTREGISTER,regcounter,R_SUBWHOLE), href));
              end;
          end;

      { now comes the AltiVec context restore, not yet implemented !!! }
    end;


    procedure tcgppc.g_stackframe_entry_mac(list : TAsmList;localsize : longint);
 (* NOT IN USE *)

 { generated the entry code of a procedure/function. Note: localsize is the }
 { sum of the size necessary for local variables and the maximum possible   }
 { combined size of ALL the parameters of a procedure called by the current }
 { one                                                                     }

     const
         macosLinkageAreaSize = 24;

     var
         href : treference;
         registerSaveAreaSize : longint;

      begin
        if (localsize mod 8) <> 0 then
          internalerror(58991);
        { CR and LR only have to be saved in case they are modified by the current }
        { procedure, but currently this isn't checked, so save them always         }
        { following is the entry code as described in "Altivec Programming }
        { Interface Manual", bar the saving of AltiVec registers           }
        a_reg_alloc(list,NR_STACK_POINTER_REG);
        a_reg_alloc(list,NR_R0);

        { save return address in callers frame}
        list.concat(taicpu.op_reg_reg(A_MFSPR,NR_R0,NR_LR));
        { ... in caller's frame }
        reference_reset_base(href,NR_STACK_POINTER_REG,8);
        list.concat(taicpu.op_reg_ref(A_STW,NR_R0,href));
        a_reg_dealloc(list,NR_R0);

        { save non-volatile registers in callers frame}
        registerSaveAreaSize:= save_regs(list);

        { save the CR if necessary in callers frame ( !!! always done currently ) }
        a_reg_alloc(list,NR_R0);
        list.concat(taicpu.op_reg_reg(A_MFSPR,NR_R0,NR_CR));
        reference_reset_base(href,NR_STACK_POINTER_REG,LA_CR_AIX);
        list.concat(taicpu.op_reg_ref(A_STW,NR_R0,href));
        a_reg_dealloc(list,NR_R0);

        (*
        { save pointer to incoming arguments }
        list.concat(taicpu.op_reg_reg_const(A_ORI,R_31,STACK_POINTER_REG,0));
        *)

        (*
        a_reg_alloc(list,R_12);

        { 0 or 8 based on SP alignment }
        list.concat(taicpu.op_reg_reg_const_const_const(A_RLWINM,
          R_12,STACK_POINTER_REG,0,28,28));
        { add in stack length }
        list.concat(taicpu.op_reg_reg_const(A_SUBFIC,R_12,R_12,
          -localsize));
        { establish new alignment }
        list.concat(taicpu.op_reg_reg_reg(A_STWUX,STACK_POINTER_REG,STACK_POINTER_REG,R_12));

        a_reg_dealloc(list,R_12);
        *)

        { allocate stack frame }
        localsize:= align(localsize + macosLinkageAreaSize + registerSaveAreaSize, 16);
        inc(localsize,tg.lasttemp);
        localsize:=align(localsize,16);
        //tppcprocinfo(current_procinfo).localsize:=localsize;

        if (localsize <> 0) then
          begin
            if (localsize <= high(smallint)) then
              begin
                reference_reset_base(href,NR_STACK_POINTER_REG,-localsize);
                a_load_store(list,A_STWU,NR_STACK_POINTER_REG,href);
              end
            else
              begin
                reference_reset_base(href,NR_STACK_POINTER_REG,0);
                href.index := NR_R11;
                a_reg_alloc(list,href.index);
                a_load_const_reg(list,OS_S32,-localsize,href.index);
                a_load_store(list,A_STWUX,NR_STACK_POINTER_REG,href);
                a_reg_dealloc(list,href.index);
              end;
          end;
      end;

    procedure tcgppc.g_return_from_proc_mac(list : TAsmList;parasize : aint);
 (* NOT IN USE *)

      var
        href : treference;
      begin
        a_reg_alloc(list,NR_R0);

        { restore stack pointer }
        reference_reset_base(href,NR_STACK_POINTER_REG,LA_SP);
        list.concat(taicpu.op_reg_ref(A_LWZ,NR_STACK_POINTER_REG,href));
        (*
        list.concat(taicpu.op_reg_reg_const(A_ORI,NR_STACK_POINTER_REG,R_31,0));
        *)

        { restore the CR if necessary from callers frame
            ( !!! always done currently ) }
        reference_reset_base(href,NR_STACK_POINTER_REG,LA_CR_AIX);
        list.concat(taicpu.op_reg_ref(A_LWZ,NR_R0,href));
        list.concat(taicpu.op_reg_reg(A_MTSPR,NR_R0,NR_CR));
        a_reg_dealloc(list,NR_R0);

        (*
        { restore return address from callers frame }
        reference_reset_base(href,STACK_POINTER_REG,8);
        list.concat(taicpu.op_reg_ref(A_LWZ,R_0,href));
        *)

        { restore non-volatile registers from callers frame }
        restore_regs(list);

        (*
        { return to caller }
        list.concat(taicpu.op_reg_reg(A_MTSPR,R_0,R_LR));
        list.concat(taicpu.op_none(A_BLR));
        *)

        { restore return address from callers frame }
        reference_reset_base(href,NR_STACK_POINTER_REG,8);
        list.concat(taicpu.op_reg_ref(A_LWZ,NR_R0,href));

        { return to caller }
        list.concat(taicpu.op_reg_reg(A_MTSPR,NR_R0,NR_LR));
        list.concat(taicpu.op_none(A_BLR));
      end;


     procedure tcgppc.a_loadaddr_ref_reg(list : TAsmList;const ref : treference;r : tregister);

       var
         ref2, tmpref: treference;

       begin
         ref2 := ref;
         fixref(list,ref2);
         if assigned(ref2.symbol) then
           begin
             if target_info.system = system_powerpc_macos then
               begin
                 if macos_direct_globals then
                   begin
                     reference_reset(tmpref);
                     tmpref.offset := ref2.offset;
                     tmpref.symbol := ref2.symbol;
                     tmpref.base := NR_NO;
                     list.concat(taicpu.op_reg_reg_ref(A_ADDI,r,NR_RTOC,tmpref));
                   end
                 else
                   begin
                     reference_reset(tmpref);
                     tmpref.symbol := ref2.symbol;
                     tmpref.offset := 0;
                     tmpref.base := NR_RTOC;
                     list.concat(taicpu.op_reg_ref(A_LWZ,r,tmpref));

                     if ref2.offset <> 0 then
                       begin
                         reference_reset(tmpref);
                         tmpref.offset := ref2.offset;
                         tmpref.base:= r;
                         list.concat(taicpu.op_reg_ref(A_LA,r,tmpref));
                       end;
                   end;

                 if ref2.base <> NR_NO then
                   list.concat(taicpu.op_reg_reg_reg(A_ADD,r,r,ref2.base));

                 //list.concat(tai_comment.create(strpnew('*** a_loadaddr_ref_reg')));
               end
             else
               begin

                 { add the symbol's value to the base of the reference, and if the }
                 { reference doesn't have a base, create one                       }
                 reference_reset(tmpref);
                 tmpref.offset := ref2.offset;
                 tmpref.symbol := ref2.symbol;
                 tmpref.relsymbol := ref2.relsymbol;
                 tmpref.refaddr := addr_hi;
                 if ref2.base<> NR_NO then
                   begin
                     list.concat(taicpu.op_reg_reg_ref(A_ADDIS,r,
                       ref2.base,tmpref));
                   end
                 else
                   list.concat(taicpu.op_reg_ref(A_LIS,r,tmpref));
                 tmpref.base := NR_NO;
                 tmpref.refaddr := addr_lo;
                 { can be folded with one of the next instructions by the }
                 { optimizer probably                                     }
                 list.concat(taicpu.op_reg_reg_ref(A_ADDI,r,r,tmpref));
               end
           end
         else if ref2.offset <> 0 Then
           if ref2.base <> NR_NO then
             a_op_const_reg_reg(list,OP_ADD,OS_32,ref2.offset,ref2.base,r)
           { FixRef makes sure that "(ref.index <> R_NO) and (ref.offset <> 0)" never}
           { occurs, so now only ref.offset has to be loaded                         }
           else
             a_load_const_reg(list,OS_32,ref2.offset,r)
         else if ref2.index <> NR_NO Then
           list.concat(taicpu.op_reg_reg_reg(A_ADD,r,ref2.base,ref2.index))
         else if (ref2.base <> NR_NO) and
                 (r <> ref2.base) then
           a_load_reg_reg(list,OS_ADDR,OS_ADDR,ref2.base,r)
         else
           list.concat(taicpu.op_reg_const(A_LI,r,0));
       end;

{ ************* concatcopy ************ }

{$ifndef ppc603}
  const
    maxmoveunit = 8;
{$else ppc603}
  const
    maxmoveunit = 4;
{$endif ppc603}

    procedure tcgppc.g_concatcopy(list : TAsmList;const source,dest : treference;len : aint);

      var
        countreg: TRegister;
        src, dst: TReference;
        lab: tasmlabel;
        count, count2: aint;
        size: tcgsize;
        copyreg: tregister;

      begin
{$ifdef extdebug}
        if len > high(longint) then
          internalerror(2002072704);
{$endif extdebug}

        if (references_equal(source,dest)) then
          exit;

        { make sure short loads are handled as optimally as possible }
        if (len <= maxmoveunit) and
           (byte(len) in [1,2,4,8]) then
          begin
            if len < 8 then
              begin
                size := int_cgsize(len);
                a_load_ref_ref(list,size,size,source,dest);
              end
            else
              begin
                copyreg := getfpuregister(list,OS_F64);
                a_loadfpu_ref_reg(list,OS_F64,source,copyreg);
                a_loadfpu_reg_ref(list,OS_F64,copyreg,dest);
              end;
            exit;
          end;

        count := len div maxmoveunit;

        reference_reset(src);
        reference_reset(dst);
        { load the address of source into src.base }
        if (count > 4) or
           not issimpleref(source) or
           ((source.index <> NR_NO) and
            ((source.offset + longint(len)) > high(smallint))) then
          begin
            src.base := rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
            a_loadaddr_ref_reg(list,source,src.base);
          end
        else
          begin
            src := source;
          end;
        { load the address of dest into dst.base }
        if (count > 4) or
           not issimpleref(dest) or
           ((dest.index <> NR_NO) and
            ((dest.offset + longint(len)) > high(smallint))) then
          begin
            dst.base := rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
            a_loadaddr_ref_reg(list,dest,dst.base);
          end
        else
          begin
            dst := dest;
          end;

{$ifndef ppc603}
        if count > 4 then
          { generate a loop }
          begin
            { the offsets are zero after the a_loadaddress_ref_reg and just }
            { have to be set to 8. I put an Inc there so debugging may be   }
            { easier (should offset be different from zero here, it will be }
            { easy to notice in the generated assembler                     }
            inc(dst.offset,8);
            inc(src.offset,8);
            list.concat(taicpu.op_reg_reg_const(A_SUBI,src.base,src.base,8));
            list.concat(taicpu.op_reg_reg_const(A_SUBI,dst.base,dst.base,8));
            countreg := rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
            a_load_const_reg(list,OS_32,count,countreg);
            copyreg := getfpuregister(list,OS_F64);
            a_reg_sync(list,copyreg);
            current_asmdata.getjumplabel(lab);
            a_label(list, lab);
            list.concat(taicpu.op_reg_reg_const(A_SUBIC_,countreg,countreg,1));
            list.concat(taicpu.op_reg_ref(A_LFDU,copyreg,src));
            list.concat(taicpu.op_reg_ref(A_STFDU,copyreg,dst));
            a_jmp(list,A_BC,C_NE,0,lab);
            a_reg_sync(list,copyreg);
            len := len mod 8;
          end;

        count := len div 8;
        if count > 0 then
          { unrolled loop }
          begin
            copyreg := getfpuregister(list,OS_F64);
            for count2 := 1 to count do
              begin
                a_loadfpu_ref_reg(list,OS_F64,src,copyreg);
                a_loadfpu_reg_ref(list,OS_F64,copyreg,dst);
                inc(src.offset,8);
                inc(dst.offset,8);
              end;
            len := len mod 8;
          end;

        if (len and 4) <> 0 then
          begin
            a_reg_alloc(list,NR_R0);
            a_load_ref_reg(list,OS_32,OS_32,src,NR_R0);
            a_load_reg_ref(list,OS_32,OS_32,NR_R0,dst);
            inc(src.offset,4);
            inc(dst.offset,4);
            a_reg_dealloc(list,NR_R0);
          end;
{$else not ppc603}
        if count > 4 then
          { generate a loop }
          begin
            { the offsets are zero after the a_loadaddress_ref_reg and just }
            { have to be set to 4. I put an Inc there so debugging may be   }
            { easier (should offset be different from zero here, it will be }
            { easy to notice in the generated assembler                     }
            inc(dst.offset,4);
            inc(src.offset,4);
            list.concat(taicpu.op_reg_reg_const(A_SUBI,src.base,src.base,4));
            list.concat(taicpu.op_reg_reg_const(A_SUBI,dst.base,dst.base,4));
            countreg := rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
            a_load_const_reg(list,OS_32,count,countreg);
            { explicitely allocate R_0 since it can be used safely here }
            { (for holding date that's being copied)                    }
            a_reg_alloc(list,NR_R0);
            current_asmdata.getjumplabel(lab);
            a_label(list, lab);
            list.concat(taicpu.op_reg_reg_const(A_SUBIC_,countreg,countreg,1));
            list.concat(taicpu.op_reg_ref(A_LWZU,NR_R0,src));
            list.concat(taicpu.op_reg_ref(A_STWU,NR_R0,dst));
            a_jmp(list,A_BC,C_NE,0,lab);
            a_reg_dealloc(list,NR_R0);
            len := len mod 4;
          end;

        count := len div 4;
        if count > 0 then
          { unrolled loop }
          begin
            a_reg_alloc(list,NR_R0);
            for count2 := 1 to count do
              begin
                a_load_ref_reg(list,OS_32,OS_32,src,NR_R0);
                a_load_reg_ref(list,OS_32,OS_32,NR_R0,dst);
                inc(src.offset,4);
                inc(dst.offset,4);
              end;
            a_reg_dealloc(list,NR_R0);
            len := len mod 4;
          end;
{$endif not ppc603}
       { copy the leftovers }
       if (len and 2) <> 0 then
         begin
           a_reg_alloc(list,NR_R0);
           a_load_ref_reg(list,OS_16,OS_16,src,NR_R0);
           a_load_reg_ref(list,OS_16,OS_16,NR_R0,dst);
           inc(src.offset,2);
           inc(dst.offset,2);
           a_reg_dealloc(list,NR_R0);
         end;
       if (len and 1) <> 0 then
         begin
           a_reg_alloc(list,NR_R0);
           a_load_ref_reg(list,OS_8,OS_8,src,NR_R0);
           a_load_reg_ref(list,OS_8,OS_8,NR_R0,dst);
           a_reg_dealloc(list,NR_R0);
         end;
      end;


    procedure tcgppc.g_overflowcheck(list: TAsmList; const l: tlocation; def: tdef);
      var
         hl : tasmlabel;
      begin
         if not(cs_check_overflow in aktlocalswitches) then
          exit;
         current_asmdata.getjumplabel(hl);
         if not ((def.deftype=pointerdef) or
                ((def.deftype=orddef) and
                 (torddef(def).typ in [u64bit,u16bit,u32bit,u8bit,uchar,
                                                  bool8bit,bool16bit,bool32bit]))) then
           begin
             list.concat(taicpu.op_reg(A_MCRXR,NR_CR7));
             a_jmp(list,A_BC,C_NO,7,hl)
           end
         else
           a_jmp_cond(list,OC_AE,hl);
         a_call_name(list,'FPC_OVERFLOW');
         a_label(list,hl);
      end;


    procedure tcgppc.g_intf_wrapper(list: TAsmList; procdef: tprocdef; const labelname: string; ioffset: longint);

        procedure loadvmttor11;
        var
          href : treference;
        begin
          reference_reset_base(href,NR_R3,0);
          cg.a_load_ref_reg(list,OS_ADDR,OS_ADDR,href,NR_R11);
        end;

        procedure op_onr11methodaddr;
        var
          href : treference;
        begin
          if (procdef.extnumber=$ffff) then
            Internalerror(200006139);
          { call/jmp  vmtoffs(%eax) ; method offs }
          reference_reset_base(href,NR_R11,procdef._class.vmtmethodoffset(procdef.extnumber));
          if not((longint(href.offset) >= low(smallint)) and
                 (longint(href.offset) <= high(smallint))) then
            begin
              list.concat(taicpu.op_reg_reg_const(A_ADDIS,NR_R11,NR_R11,
                smallint((href.offset shr 16)+ord(smallint(href.offset and $ffff) < 0))));
              href.offset := smallint(href.offset and $ffff);
            end;
          list.concat(taicpu.op_reg_ref(A_LWZ,NR_R11,href));
          list.concat(taicpu.op_reg(A_MTCTR,NR_R11));
          list.concat(taicpu.op_none(A_BCTR));
        end;

      var
        make_global : boolean;
      begin
        if not(procdef.proctypeoption in [potype_function,potype_procedure]) then
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
          List.concat(Tai_symbol.Createname_global(labelname,AT_FUNCTION,0))
        else
          List.concat(Tai_symbol.Createname(labelname,AT_FUNCTION,0));

        { set param1 interface to self  }
        g_adjust_self_value(list,procdef,ioffset);

        { case 4 }
        if po_virtualmethod in procdef.procoptions then
          begin
            loadvmttor11;
            op_onr11methodaddr;
          end
        { case 0 }
        else
          list.concat(taicpu.op_sym(A_B,current_asmdata.RefAsmSymbol(procdef.mangledname)));

        List.concat(Tai_symbol_end.Createname(labelname));
      end;


{***************** This is private property, keep out! :) *****************}

    function tcgppc.issimpleref(const ref: treference): boolean;

      begin
        if (ref.base = NR_NO) and
           (ref.index <> NR_NO) then
          internalerror(200208101);
        result :=
          not(assigned(ref.symbol)) and
          (((ref.index = NR_NO) and
            (ref.offset >= low(smallint)) and
            (ref.offset <= high(smallint))) or
           ((ref.index <> NR_NO) and
            (ref.offset = 0)));
      end;


    function tcgppc.fixref(list: TAsmList; var ref: treference): boolean;

       var
         tmpreg: tregister;
       begin
         result := false;

         if (target_info.system = system_powerpc_darwin) and
            assigned(ref.symbol) and
            (ref.symbol.bind = AB_EXTERNAL) then
           begin
             tmpreg := g_indirect_sym_load(list,ref.symbol.name);
             if (ref.base = NR_NO) then
               ref.base := tmpreg
             else if (ref.index = NR_NO) then
               ref.index := tmpreg
             else
               begin
                 list.concat(taicpu.op_reg_reg_reg(A_ADD,tmpreg,ref.base,tmpreg));
                 ref.base := tmpreg;
               end;
             ref.symbol := nil;
           end;

         if (ref.base = NR_NO) then
           begin
             ref.base := ref.index;
             ref.index := NR_NO;
           end;
         if (ref.base <> NR_NO) then
           begin
             if (ref.index <> NR_NO) and
                ((ref.offset <> 0) or assigned(ref.symbol)) then
               begin
                 result := true;
                 tmpreg := rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
                 list.concat(taicpu.op_reg_reg_reg(
                   A_ADD,tmpreg,ref.base,ref.index));
                 ref.index := NR_NO;
                 ref.base := tmpreg;
               end
           end
         else
           if ref.index <> NR_NO then
             internalerror(200208102);
       end;


    { find out whether a is of the form 11..00..11b or 00..11...00. If }
    { that's the case, we can use rlwinm to do an AND operation        }
    function tcgppc.get_rlwi_const(a: aint; var l1, l2: longint): boolean;

      var
        temp : longint;
        testbit : aint;
        compare: boolean;

      begin
        get_rlwi_const := false;
        if (a = 0) or (a = -1) then
          exit;
        { start with the lowest bit }
        testbit := 1;
        { check its value }
        compare := boolean(a and testbit);
        { find out how long the run of bits with this value is            }
        { (it's impossible that all bits are 1 or 0, because in that case }
        { this function wouldn't have been called)                        }
        l1 := 31;
        while (((a and testbit) <> 0) = compare) do
          begin
            testbit := testbit shl 1;
            dec(l1);
          end;

        { check the length of the run of bits that comes next }
        compare := not compare;
        l2 := l1;
        while (((a and testbit) <> 0) = compare) and
               (l2 >= 0) do
          begin
            testbit := testbit shl 1;
            dec(l2);
          end;

        { and finally the check whether the rest of the bits all have the }
        { same value                                                      }
        compare := not compare;
        temp := l2;
        if temp >= 0 then
          if (a shr (31-temp)) <> ((-ord(compare)) shr (31-temp)) then
            exit;

        { we have done "not(not(compare))", so compare is back to its   }
        { initial value. If the lowest bit was 0, a is of the form      }
        { 00..11..00 and we need "rlwinm reg,reg,0,l2+1,l1", (+1        }
        { because l2 now contains the position of the last zero of the  }
        { first run instead of that of the first 1) so switch l1 and l2 }
        { in that case (we will generate "rlwinm reg,reg,0,l1,l2")      }
        if not compare then
          begin
            temp := l1;
            l1 := l2+1;
            l2 := temp;
          end
        else
          { otherwise, l1 currently contains the position of the last   }
          { zero instead of that of the first 1 of the second run -> +1 }
          inc(l1);
        { the following is the same as "if l1 = -1 then l1 := 31;" }
        l1 := l1 and 31;
        l2 := l2 and 31;
        get_rlwi_const := true;
      end;


    procedure tcgppc.a_load_store(list:TAsmList;op: tasmop;reg:tregister;
       ref: treference);

      var
        tmpreg: tregister;
        tmpref: treference;
        largeOffset: Boolean;

      begin
        tmpreg := NR_NO;

        if target_info.system = system_powerpc_macos then
          begin
            largeOffset:= (cardinal(ref.offset-low(smallint)) >
                  high(smallint)-low(smallint));

            if assigned(ref.symbol) then
              begin {Load symbol's value}
                tmpreg := rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);

                reference_reset(tmpref);
                tmpref.symbol := ref.symbol;
                tmpref.base := NR_RTOC;

                if macos_direct_globals then
                  list.concat(taicpu.op_reg_ref(A_LA,tmpreg,tmpref))
                else
                  list.concat(taicpu.op_reg_ref(A_LWZ,tmpreg,tmpref));
              end;

            if largeOffset then
              begin {Add hi part of offset}
                reference_reset(tmpref);

                if Smallint(Lo(ref.offset)) < 0 then
                  tmpref.offset := Hi(ref.offset) + 1 {Compensate when lo part is negative}
                else
                  tmpref.offset := Hi(ref.offset);

                if (tmpreg <> NR_NO) then
                  list.concat(taicpu.op_reg_reg_ref(A_ADDIS,tmpreg, tmpreg,tmpref))
                else
                  begin
                    tmpreg := rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
                    list.concat(taicpu.op_reg_ref(A_LIS,tmpreg,tmpref));
                  end;
              end;

            if (tmpreg <> NR_NO) then
              begin
                {Add content of base register}
                if ref.base <> NR_NO then
                  list.concat(taicpu.op_reg_reg_reg(A_ADD,tmpreg,
                    ref.base,tmpreg));

                {Make ref ready to be used by op}
                ref.symbol:= nil;
                ref.base:= tmpreg;
                if largeOffset then
                  ref.offset := Smallint(Lo(ref.offset));

                list.concat(taicpu.op_reg_ref(op,reg,ref));
                //list.concat(tai_comment.create(strpnew('*** a_load_store indirect global')));
              end
            else
              list.concat(taicpu.op_reg_ref(op,reg,ref));
          end
        else {if target_info.system <> system_powerpc_macos}
          begin
            if assigned(ref.symbol) or
               (cardinal(ref.offset-low(smallint)) >
                high(smallint)-low(smallint)) then
              begin
                tmpreg := rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
                reference_reset(tmpref);
                tmpref.symbol := ref.symbol;
                tmpref.relsymbol := ref.relsymbol;
                tmpref.offset := ref.offset;
                tmpref.refaddr := addr_hi;
                if ref.base <> NR_NO then
                  list.concat(taicpu.op_reg_reg_ref(A_ADDIS,tmpreg,
                    ref.base,tmpref))
                else
                  list.concat(taicpu.op_reg_ref(A_LIS,tmpreg,tmpref));
                ref.base := tmpreg;
                ref.refaddr := addr_lo;
                list.concat(taicpu.op_reg_ref(op,reg,ref));
              end
            else
              list.concat(taicpu.op_reg_ref(op,reg,ref));
          end;
      end;


    procedure tcgppc.a_jmp(list: TAsmList; op: tasmop; c: tasmcondflag;
                crval: longint; l: tasmlabel);
      var
        p: taicpu;

      begin
        p := taicpu.op_sym(op,l);
        if op <> A_B then
          create_cond_norm(c,crval,p.condition);
        p.is_jmp := true;
        list.concat(p)
      end;


    procedure tcg64fppc.a_op64_reg_reg(list : TAsmList;op:TOpCG;size : tcgsize;regsrc,regdst : tregister64);
      begin
        a_op64_reg_reg_reg(list,op,size,regsrc,regdst,regdst);
      end;


    procedure tcg64fppc.a_op64_const_reg(list : TAsmList;op:TOpCG;size : tcgsize;value : int64;reg : tregister64);
      begin
        a_op64_const_reg_reg(list,op,size,value,reg,reg);
      end;


    procedure tcg64fppc.a_op64_reg_reg_reg(list: TAsmList;op:TOpCG;size : tcgsize;regsrc1,regsrc2,regdst : tregister64);
      begin
        case op of
          OP_AND,OP_OR,OP_XOR:
            begin
              cg.a_op_reg_reg_reg(list,op,OS_32,regsrc1.reglo,regsrc2.reglo,regdst.reglo);
              cg.a_op_reg_reg_reg(list,op,OS_32,regsrc1.reghi,regsrc2.reghi,regdst.reghi);
            end;
          OP_ADD:
            begin
              list.concat(taicpu.op_reg_reg_reg(A_ADDC,regdst.reglo,regsrc1.reglo,regsrc2.reglo));
              list.concat(taicpu.op_reg_reg_reg(A_ADDE,regdst.reghi,regsrc1.reghi,regsrc2.reghi));
            end;
          OP_SUB:
            begin
              list.concat(taicpu.op_reg_reg_reg(A_SUBC,regdst.reglo,regsrc2.reglo,regsrc1.reglo));
              list.concat(taicpu.op_reg_reg_reg(A_SUBFE,regdst.reghi,regsrc1.reghi,regsrc2.reghi));
            end;
          else
            internalerror(2002072801);
        end;
      end;


    procedure tcg64fppc.a_op64_const_reg_reg(list: TAsmList;op:TOpCG;size : tcgsize;value : int64;regsrc,regdst : tregister64);

      const
        ops: array[boolean,1..3] of tasmop = ((A_ADDIC,A_ADDC,A_ADDZE),
                                              (A_SUBIC,A_SUBC,A_ADDME));
      var
        tmpreg: tregister;
        tmpreg64: tregister64;
        issub: boolean;
      begin
        case op of
          OP_AND,OP_OR,OP_XOR:
            begin
              cg.a_op_const_reg_reg(list,op,OS_32,aint(value),regsrc.reglo,regdst.reglo);
              cg.a_op_const_reg_reg(list,op,OS_32,aint(value shr 32),regsrc.reghi,
                regdst.reghi);
            end;
          OP_ADD, OP_SUB:
            begin
              if (value < 0) then
                begin
                  if op = OP_ADD then
                    op := OP_SUB
                  else
                    op := OP_ADD;
                  value := -value;
                end;
              if (longint(value) <> 0) then
                begin
                  issub := op = OP_SUB;
                  if (value > 0) and
                     (value-ord(issub) <= 32767) then
                    begin
                      list.concat(taicpu.op_reg_reg_const(ops[issub,1],
                        regdst.reglo,regsrc.reglo,longint(value)));
                      list.concat(taicpu.op_reg_reg(ops[issub,3],
                        regdst.reghi,regsrc.reghi));
                    end
                  else if ((value shr 32) = 0) then
                    begin
                      tmpreg := tcgppc(cg).rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
                      cg.a_load_const_reg(list,OS_32,cardinal(value),tmpreg);
                      list.concat(taicpu.op_reg_reg_reg(ops[issub,2],
                        regdst.reglo,regsrc.reglo,tmpreg));
                      list.concat(taicpu.op_reg_reg(ops[issub,3],
                        regdst.reghi,regsrc.reghi));
                    end
                  else
                    begin
                      tmpreg64.reglo := tcgppc(cg).rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
                      tmpreg64.reghi := tcgppc(cg).rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
                      a_load64_const_reg(list,value,tmpreg64);
                      a_op64_reg_reg_reg(list,op,size,tmpreg64,regsrc,regdst);
                    end
                end
              else
                begin
                  cg.a_load_reg_reg(list,OS_INT,OS_INT,regsrc.reglo,regdst.reglo);
                  cg.a_op_const_reg_reg(list,op,OS_32,aint(value shr 32),regsrc.reghi,
                    regdst.reghi);
                end;
            end;
          else
            internalerror(2002072802);
        end;
      end;


begin
  cg := tcgppc.create;
  cg64 :=tcg64fppc.create;
end.
