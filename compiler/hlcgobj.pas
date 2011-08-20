{
    Copyright (c) 1998-2010 by Florian Klaempfl and Jonas Maebe
    Member of the Free Pascal development team

    This unit implements the basic high level code generator object

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
{# @abstract(Abstract code generator unit)
   Abstract high level code generator unit. This contains the base class
   that either lowers most code to the regular code generator, or that
   has to be implemented/overridden for higher level targets (such as LLVM).
}
unit hlcgobj;

{$i fpcdefs.inc}

{ define hlcginline}

  interface

    uses
       cclasses,globtype,constexp,
       cpubase,cgbase,cgutils,parabase,
       aasmbase,aasmtai,aasmdata,aasmcpu,
       symconst,symtype,symdef,rgobj,
       node
       ;

    type
       {# @abstract(Abstract high level code generator)
          This class implements an abstract instruction generator. All
          methods of this class are generic and are mapped to low level code
          generator methods by default. They have to be overridden for higher
          level targets
       }

       { thlcgobj }

       thlcgobj = class
       public
          {************************************************}
          {                 basic routines                 }
          constructor create;

          {# Initialize the register allocators needed for the codegenerator.}
          procedure init_register_allocators;virtual;
          {# Clean up the register allocators needed for the codegenerator.}
          procedure done_register_allocators;virtual;
          {# Set whether live_start or live_end should be updated when allocating registers, needed when e.g. generating initcode after the rest of the code. }
          procedure set_regalloc_live_range_direction(dir: TRADirection);virtual;
          {# Gets a register suitable to do integer operations on.}
          function getintregister(list:TAsmList;size:tdef):Tregister;virtual;
          {# Gets a register suitable to do integer operations on.}
          function getaddressregister(list:TAsmList;size:tdef):Tregister;virtual;
          function getfpuregister(list:TAsmList;size:tdef):Tregister;virtual;
//        we don't have high level defs yet that translate into all mm cgsizes
//          function getmmregister(list:TAsmList;size:tdef):Tregister;virtual;
          function getflagregister(list:TAsmList;size:tdef):Tregister;virtual;
          function getregisterfordef(list: TAsmList;size:tdef):Tregister;virtual;
          {Does the generic cg need SIMD registers, like getmmxregister? Or should
           the cpu specific child cg object have such a method?}

          function  uses_registers(rt:Tregistertype):boolean; inline;

          procedure do_register_allocation(list:TAsmList;headertai:tai); inline;
          procedure translate_register(var reg : tregister); inline;

          {# Emit a label to the instruction stream. }
          procedure a_label(list : TAsmList;l : tasmlabel); inline;

          {# Allocates register r by inserting a pai_realloc record }
          procedure a_reg_alloc(list : TAsmList;r : tregister); inline;
          {# Deallocates register r by inserting a pa_regdealloc record}
          procedure a_reg_dealloc(list : TAsmList;r : tregister); inline;
          { Synchronize register, make sure it is still valid }
          procedure a_reg_sync(list : TAsmList;r : tregister); inline;

          {# Pass a parameter, which is located in a register, to a routine.

             This routine should push/send the parameter to the routine, as
             required by the specific processor ABI and routine modifiers.
             It must generate register allocation information for the cgpara in
             case it consists of cpuregisters.

             @param(size size of the operand in the register)
             @param(r register source of the operand)
             @param(cgpara where the parameter will be stored)
          }
          procedure a_load_reg_cgpara(list : TAsmList;size : tdef;r : tregister;const cgpara : TCGPara);virtual;
          {# Pass a parameter, which is a constant, to a routine.

             A generic version is provided. This routine should
             be overridden for optimization purposes if the cpu
             permits directly sending this type of parameter.
             It must generate register allocation information for the cgpara in
             case it consists of cpuregisters.

             @param(size size of the operand in constant)
             @param(a value of constant to send)
             @param(cgpara where the parameter will be stored)
          }
          procedure a_load_const_cgpara(list : TAsmList;tosize : tdef;a : aint;const cgpara : TCGPara);virtual;
          {# Pass the value of a parameter, which is located in memory, to a routine.

             A generic version is provided. This routine should
             be overridden for optimization purposes if the cpu
             permits directly sending this type of parameter.
             It must generate register allocation information for the cgpara in
             case it consists of cpuregisters.

             @param(size size of the operand in constant)
             @param(r Memory reference of value to send)
             @param(cgpara where the parameter will be stored)
          }
          procedure a_load_ref_cgpara(list : TAsmList;size : tdef;const r : treference;const cgpara : TCGPara);virtual;
          {# Pass the value of a parameter, which can be located either in a register or memory location,
             to a routine.

             A generic version is provided.

             @param(l location of the operand to send)
             @param(nr parameter number (starting from one) of routine (from left to right))
             @param(cgpara where the parameter will be stored)
          }
          procedure a_load_loc_cgpara(list : TAsmList;size : tdef; const l : tlocation;const cgpara : TCGPara);virtual;
          {# Pass the address of a reference to a routine. This routine
             will calculate the address of the reference, and pass this
             calculated address as a parameter.
             It must generate register allocation information for the cgpara in
             case it consists of cpuregisters.

             A generic version is provided. This routine should
             be overridden for optimization purposes if the cpu
             permits directly sending this type of parameter.

             @param(fromsize type of the reference we are taking the address of)
             @param(tosize type of the pointer that we get as a result)
             @param(r reference to get address from)
          }
          procedure a_loadaddr_ref_cgpara(list : TAsmList;fromsize, tosize : tdef;const r : treference;const cgpara : TCGPara);virtual;

          { Remarks:
            * If a method specifies a size you have only to take care
              of that number of bits, i.e. load_const_reg with OP_8 must
              only load the lower 8 bit of the specified register
              the rest of the register can be undefined
              if  necessary the compiler will call a method
              to zero or sign extend the register
            * The a_load_XX_XX with OP_64 needn't to be
              implemented for 32 bit
              processors, the code generator takes care of that
            * the addr size is for work with the natural pointer
              size
            * the procedures without fpu/mm are only for integer usage
            * normally the first location is the source and the
              second the destination
          }

          {# Emits instruction to call the method specified by symbol name.
             This routine must be overridden for each new target cpu.
          }
          procedure a_call_name(list : TAsmList;pd : tprocdef;const s : string; weak: boolean);virtual;abstract;
          procedure a_call_reg(list : TAsmList;pd : tabstractprocdef;reg : tregister);virtual;abstract;
          procedure a_call_ref(list : TAsmList;pd : tabstractprocdef;ref : treference);virtual;abstract;
          { same as a_call_name, might be overridden on certain architectures to emit
            static calls without usage of a got trampoline }
          procedure a_call_name_static(list : TAsmList;pd : tprocdef;const s : string);virtual;
          { same as a_call_name, might be overridden on certain architectures to emit
            special static calls for inherited methods }
          procedure a_call_name_inherited(list : TAsmList;pd : tprocdef;const s : string);virtual;

          { move instructions }
          procedure a_load_const_reg(list : TAsmList;tosize : tdef;a : aint;register : tregister);virtual;abstract;
          procedure a_load_const_ref(list : TAsmList;tosize : tdef;a : aint;const ref : treference);virtual;
          procedure a_load_const_loc(list : TAsmList;tosize : tdef;a : aint;const loc : tlocation);virtual;
          procedure a_load_reg_ref(list : TAsmList;fromsize, tosize : tdef;register : tregister;const ref : treference);virtual;abstract;
          procedure a_load_reg_ref_unaligned(list : TAsmList;fromsize, tosize : tdef;register : tregister;const ref : treference);virtual;
          procedure a_load_reg_reg(list : TAsmList;fromsize, tosize : tdef;reg1,reg2 : tregister);virtual;abstract;
          procedure a_load_reg_loc(list : TAsmList;fromsize, tosize : tdef;reg : tregister;const loc: tlocation);virtual;
          procedure a_load_ref_reg(list : TAsmList;fromsize, tosize : tdef;const ref : treference;register : tregister);virtual;abstract;
          procedure a_load_ref_reg_unaligned(list : TAsmList;fromsize, tosize : tdef;const ref : treference;register : tregister);virtual;
          procedure a_load_ref_ref(list : TAsmList;fromsize, tosize : tdef;const sref : treference;const dref : treference);virtual;
          procedure a_load_loc_reg(list : TAsmList;fromsize, tosize : tdef; const loc: tlocation; reg : tregister);virtual;
          procedure a_load_loc_ref(list : TAsmList;fromsize, tosize: tdef; const loc: tlocation; const ref : treference);virtual;
          procedure a_load_loc_subsetreg(list : TAsmList;fromsize, tosize, tosubsetsize: tdef; const loc: tlocation; const sreg : tsubsetregister);virtual;
          procedure a_load_loc_subsetref(list : TAsmList;fromsize, tosize, tosubsetsize: tdef; const loc: tlocation; const sref : tsubsetreference);virtual;
          procedure a_loadaddr_ref_reg(list : TAsmList;fromsize, tosize : tdef;const ref : treference;r : tregister);virtual;abstract;

          { The subset stuff still need a transformation to thlcgobj }
          procedure a_load_subsetreg_reg(list : TAsmList; fromsize, fromsubsetsize, tosize: tdef; const sreg: tsubsetregister; destreg: tregister); virtual; abstract;
          procedure a_load_reg_subsetreg(list : TAsmList; fromsize, tosize, tosubsetsize: tdef; fromreg: tregister; const sreg: tsubsetregister); virtual; abstract;
          procedure a_load_subsetreg_subsetreg(list: TAsmlist; fromsize, fromsubsetsize, tosize, tosubsetsize : tdef; const fromsreg, tosreg: tsubsetregister); virtual; abstract;
          procedure a_load_subsetreg_ref(list : TAsmList; fromsize, fromsubsetsize, tosize: tdef; const sreg: tsubsetregister; const destref: treference); virtual; abstract;
          procedure a_load_ref_subsetreg(list : TAsmList; fromsize, tosize,tosubsetsize: tdef; const fromref: treference; const sreg: tsubsetregister); virtual; abstract;
          procedure a_load_const_subsetreg(list: TAsmlist; tosize, tosubsetsize: tdef; a: aint; const sreg: tsubsetregister); virtual; abstract;
          procedure a_load_subsetreg_loc(list: TAsmlist; fromsize, fromsubsetsize, tosize: tdef; const sreg: tsubsetregister; const loc: tlocation); virtual;

          procedure a_load_subsetref_reg(list : TAsmList; fromsize, fromsubsetsize, tosize: tdef; const sref: tsubsetreference; destreg: tregister); virtual; abstract;
          procedure a_load_reg_subsetref(list : TAsmList; fromsize, tosubsetsize, tosize: tdef; fromreg: tregister; const sref: tsubsetreference); virtual; abstract;
          procedure a_load_subsetref_subsetref(list: TAsmlist; fromsize, fromsubsetsize, tosize, tosubsetsize : tdef; const fromsref, tosref: tsubsetreference); virtual; abstract;
          procedure a_load_subsetref_ref(list : TAsmList; fromsize, fromsubsetsize, tosize: tdef; const sref: tsubsetreference; const destref: treference); virtual; abstract;
          procedure a_load_ref_subsetref(list : TAsmList; fromsize, tosize, tosubsetsize: tdef; const fromref: treference; const sref: tsubsetreference); virtual; abstract;
          procedure a_load_const_subsetref(list: TAsmlist; tosize, tosubsetsize: tdef; a: aint; const sref: tsubsetreference); virtual; abstract;
          procedure a_load_subsetref_loc(list: TAsmlist; fromsize, fromsubsetsize, tosize: tdef; const sref: tsubsetreference; const loc: tlocation); virtual;
          procedure a_load_subsetref_subsetreg(list: TAsmlist; fromsize, fromsubsetsize, tosize, tosubsetsize : tdef; const fromsref: tsubsetreference; const tosreg: tsubsetregister); virtual; abstract;
          procedure a_load_subsetreg_subsetref(list: TAsmlist; fromsize, fromsubsetsize, tosize, tosubsetsize : tdef; const fromsreg: tsubsetregister; const tosref: tsubsetreference); virtual; abstract;

          { bit test instructions (still need transformation to thlcgobj) }
          procedure a_bit_test_reg_reg_reg(list : TAsmList; bitnumbersize,valuesize,destsize: tdef;bitnumber,value,destreg: tregister); virtual; abstract;
          procedure a_bit_test_const_ref_reg(list: TAsmList; fromsize, destsize: tdef; bitnumber: aint; const ref: treference; destreg: tregister); virtual; abstract;
          procedure a_bit_test_const_reg_reg(list: TAsmList; setregsize, destsize: tdef; bitnumber: aint; setreg, destreg: tregister); virtual; abstract;
          procedure a_bit_test_const_subsetreg_reg(list: TAsmList; fromsize, fromsubsetsize, destsize: tdef; bitnumber: aint; const setreg: tsubsetregister; destreg: tregister); virtual; abstract;
          procedure a_bit_test_reg_ref_reg(list: TAsmList; bitnumbersize, refsize, destsize: tdef; bitnumber: tregister; const ref: treference; destreg: tregister); virtual; abstract;
          procedure a_bit_test_reg_loc_reg(list: TAsmList; bitnumbersize, locsize, destsize: tdef; bitnumber: tregister; const loc: tlocation; destreg: tregister);virtual;
          procedure a_bit_test_const_loc_reg(list: TAsmList; locsize, destsize: tdef; bitnumber: aint; const loc: tlocation; destreg: tregister);virtual;

          { bit set/clear instructions (still need transformation to thlcgobj) }
          procedure a_bit_set_reg_reg(list : TAsmList; doset: boolean; bitnumbersize, destsize: tdef; bitnumber,dest: tregister); virtual; abstract;
          procedure a_bit_set_const_ref(list: TAsmList; doset: boolean;destsize: tdef; bitnumber: aint; const ref: treference); virtual; abstract;
          procedure a_bit_set_const_reg(list: TAsmList; doset: boolean; destsize: tdef; bitnumber: aint; destreg: tregister); virtual; abstract;
          procedure a_bit_set_const_subsetreg(list: TAsmList; doset: boolean; destsize, destsubsetsize: tdef; bitnumber: aint; const destreg: tsubsetregister); virtual; abstract;
          procedure a_bit_set_reg_ref(list: TAsmList; doset: boolean; fromsize, tosize: tdef; bitnumber: tregister; const ref: treference); virtual; abstract;
          procedure a_bit_set_reg_loc(list: TAsmList; doset: boolean; fromsize, tosize: tdef; bitnumber: tregister; const loc: tlocation);virtual;
          procedure a_bit_set_const_loc(list: TAsmList; doset: boolean; tosize: tdef; bitnumber: aint; const loc: tlocation);virtual;

          { bit scan instructions (still need transformation to thlcgobj) }
          procedure a_bit_scan_reg_reg(list: TAsmList; reverse: boolean; size: tdef; src, dst: tregister); virtual; abstract;

          { fpu move instructions }
          procedure a_loadfpu_reg_reg(list: TAsmList; fromsize, tosize: tdef; reg1, reg2: tregister); virtual; abstract;
          procedure a_loadfpu_ref_reg(list: TAsmList; fromsize, tosize: tdef; const ref: treference; reg: tregister); virtual; abstract;
          procedure a_loadfpu_reg_ref(list: TAsmList; fromsize, tosize: tdef; reg: tregister; const ref: treference); virtual; abstract;
          procedure a_loadfpu_ref_ref(list: TAsmList; fromsize, tosize: tdef; const ref1,ref2: treference);virtual;
          procedure a_loadfpu_loc_reg(list: TAsmList; fromsize, tosize: tdef; const loc: tlocation; const reg: tregister);virtual;
          procedure a_loadfpu_reg_loc(list: TAsmList; fromsize, tosize: tdef; const reg: tregister; const loc: tlocation);virtual;
          procedure a_loadfpu_reg_cgpara(list : TAsmList;fromsize: tdef;const r : tregister;const cgpara : TCGPara);virtual;
          procedure a_loadfpu_ref_cgpara(list : TAsmList;fromsize : tdef;const ref : treference;const cgpara : TCGPara);virtual;

          { vector register move instructions }
//        we don't have high level defs yet that translate into all mm cgsizes
{
          procedure a_loadmm_reg_reg(list: TAsmList; fromsize, tosize: tdef;reg1, reg2: tregister;shuffle : pmmshuffle); virtual;
          procedure a_loadmm_ref_reg(list: TAsmList; fromsize, tosize: tdef;const ref: treference; reg: tregister;shuffle : pmmshuffle); virtual;
          procedure a_loadmm_reg_ref(list: TAsmList; fromsize, tosize: tdef;reg: tregister; const ref: treference;shuffle : pmmshuffle); virtual;
          procedure a_loadmm_loc_reg(list: TAsmList; fromsize, tosize: tdef; const loc: tlocation; const reg: tregister;shuffle : pmmshuffle);virtual;
          procedure a_loadmm_reg_loc(list: TAsmList; fromsize, tosize: tdef; const reg: tregister; const loc: tlocation;shuffle : pmmshuffle);virtual;
          procedure a_loadmm_reg_cgpara(list: TAsmList; fromsize: tdef; reg: tregister;const cgpara : TCGPara;shuffle : pmmshuffle); virtual;
          procedure a_loadmm_ref_cgpara(list: TAsmList; fromsize: tdef; const ref: treference;const cgpara : TCGPara;shuffle : pmmshuffle); virtual;
          procedure a_loadmm_loc_cgpara(list: TAsmList; fromsize: tdef; const loc: tlocation; const cgpara : TCGPara;shuffle : pmmshuffle); virtual;
          procedure a_opmm_reg_reg(list: TAsmList; Op: TOpCG; size : tdef;src,dst: tregister;shuffle : pmmshuffle); virtual;
          procedure a_opmm_ref_reg(list: TAsmList; Op: TOpCG; size : tdef;const ref: treference; reg: tregister;shuffle : pmmshuffle); virtual;
          procedure a_opmm_loc_reg(list: TAsmList; Op: TOpCG; size : tdef;const loc: tlocation; reg: tregister;shuffle : pmmshuffle); virtual;
          procedure a_opmm_reg_ref(list: TAsmList; Op: TOpCG; size : tdef;reg: tregister;const ref: treference; shuffle : pmmshuffle); virtual;
}
//        we don't have high level defs yet that translate into all mm cgsizes
//          procedure a_loadmm_intreg_reg(list: TAsmList; fromsize, tosize : tdef; intreg, mmreg: tregister; shuffle: pmmshuffle); virtual;
//          procedure a_loadmm_reg_intreg(list: TAsmList; fromsize, tosize : tdef; mmreg, intreg: tregister; shuffle : pmmshuffle); virtual;

          { basic arithmetic operations }
          { note: for operators which require only one argument (not, neg), use }
          { the op_reg_reg, op_reg_ref or op_reg_loc methods and keep in mind   }
          { that in this case the *second* operand is used as both source and   }
          { destination (JM)                                                    }
          procedure a_op_const_reg(list : TAsmList; Op: TOpCG; size: tdef; a: Aint; reg: TRegister); virtual; abstract;
          procedure a_op_const_ref(list : TAsmList; Op: TOpCG; size: tdef; a: Aint; const ref: TReference); virtual;
          procedure a_op_const_subsetreg(list : TAsmList; Op : TOpCG; size, subsetsize : tdef; a : aint; const sreg: tsubsetregister); virtual;
          procedure a_op_const_subsetref(list : TAsmList; Op : TOpCG; size, subsetsize : tdef; a : aint; const sref: tsubsetreference); virtual;
          procedure a_op_const_loc(list : TAsmList; Op: TOpCG; size: tdef; a: Aint; const loc: tlocation);virtual;
          procedure a_op_reg_reg(list : TAsmList; Op: TOpCG; size: tdef; reg1, reg2: TRegister); virtual; abstract;
          procedure a_op_reg_ref(list : TAsmList; Op: TOpCG; size: tdef; reg: TRegister; const ref: TReference); virtual;
          procedure a_op_ref_reg(list : TAsmList; Op: TOpCG; size: tdef; const ref: TReference; reg: TRegister); virtual;
          procedure a_op_reg_subsetreg(list: TAsmList; Op: TOpCG; opsize, destsize, destsubsetsize: tdef; reg: TRegister; const sreg: tsubsetregister); virtual;
          procedure a_op_reg_subsetref(list: TAsmList; Op: TOpCG; opsize, destsize, destsubsetsize: tdef; reg: TRegister; const sref: tsubsetreference); virtual;
          procedure a_op_reg_loc(list : TAsmList; Op: TOpCG; size: tdef; reg: tregister; const loc: tlocation);virtual;
          procedure a_op_ref_loc(list : TAsmList; Op: TOpCG; size: tdef; const ref: TReference; const loc: tlocation);virtual;

          { trinary operations for processors that support them, 'emulated' }
          { on others. None with "ref" arguments since I don't think there  }
          { are any processors that support it (JM)                         }
          procedure a_op_const_reg_reg(list: TAsmList; op: TOpCg; size: tdef; a: aint; src, dst: tregister); virtual;
          procedure a_op_reg_reg_reg(list: TAsmList; op: TOpCg; size: tdef; src1, src2, dst: tregister); virtual;
          procedure a_op_const_reg_reg_checkoverflow(list: TAsmList; op: TOpCg; size: tdef; a: aint; src, dst: tregister;setflags : boolean;var ovloc : tlocation); virtual;
          procedure a_op_reg_reg_reg_checkoverflow(list: TAsmList; op: TOpCg; size: tdef; src1, src2, dst: tregister;setflags : boolean;var ovloc : tlocation); virtual;

          {  comparison operations }
          procedure a_cmp_const_reg_label(list : TAsmList;size : tdef;cmp_op : topcmp;a : aint;reg : tregister;
            l : tasmlabel);virtual;
          procedure a_cmp_const_ref_label(list : TAsmList;size : tdef;cmp_op : topcmp;a : aint;const ref : treference;
            l : tasmlabel); virtual;
          procedure a_cmp_const_loc_label(list: TAsmList; size: tdef;cmp_op: topcmp; a: aint; const loc: tlocation;
            l : tasmlabel);virtual;
          procedure a_cmp_reg_reg_label(list : TAsmList;size : tdef;cmp_op : topcmp;reg1,reg2 : tregister;l : tasmlabel); virtual; abstract;
          procedure a_cmp_ref_reg_label(list : TAsmList;size : tdef;cmp_op : topcmp; const ref: treference; reg : tregister; l : tasmlabel); virtual;
          procedure a_cmp_reg_ref_label(list : TAsmList;size : tdef;cmp_op : topcmp;reg : tregister; const ref: treference; l : tasmlabel); virtual;
          procedure a_cmp_subsetreg_reg_label(list: TAsmList; fromsize, fromsubsetsize, cmpsize: tdef; cmp_op: topcmp; const sreg: tsubsetregister; reg: tregister; l: tasmlabel); virtual;
          procedure a_cmp_subsetref_reg_label(list: TAsmList; fromsize, fromsubsetsize, cmpsize: tdef; cmp_op: topcmp; const sref: tsubsetreference; reg: tregister; l: tasmlabel); virtual;

          procedure a_cmp_loc_reg_label(list : TAsmList;size : tdef;cmp_op : topcmp; const loc: tlocation; reg : tregister; l : tasmlabel);virtual;
          procedure a_cmp_reg_loc_label(list : TAsmList;size : tdef;cmp_op : topcmp; reg: tregister; const loc: tlocation; l : tasmlabel);virtual;
          procedure a_cmp_ref_loc_label(list: TAsmList; size: tdef;cmp_op: topcmp; const ref: treference; const loc: tlocation; l : tasmlabel);virtual;

          procedure a_jmp_always(list : TAsmList;l: tasmlabel); virtual;abstract;
{$ifdef cpuflags}
          procedure a_jmp_flags(list : TAsmList;const f : TResFlags;l: tasmlabel); virtual; abstract;

          {# Depending on the value to check in the flags, either sets the register reg to one (if the flag is set)
             or zero (if the flag is cleared). The size parameter indicates the destination size register.
          }
          procedure g_flags2reg(list: TAsmList; size: tdef; const f: tresflags; reg: TRegister); virtual; abstract;
          procedure g_flags2ref(list: TAsmList; size: tdef; const f: tresflags; const ref:TReference); virtual; abstract;
{$endif cpuflags}

//          procedure g_maybe_testself(list : TAsmList;reg:tregister);
//          procedure g_maybe_testvmt(list : TAsmList;reg:tregister;objdef:tobjectdef);
          {# This should emit the opcode to copy len bytes from the source
             to destination.

             It must be overridden for each new target processor.

             @param(source Source reference of copy)
             @param(dest Destination reference of copy)

          }
          procedure g_concatcopy(list : TAsmList;size: tdef; const source,dest : treference);virtual;
          {# This should emit the opcode to copy len bytes from the an unaligned source
             to destination.

             It must be overridden for each new target processor.

             @param(source Source reference of copy)
             @param(dest Destination reference of copy)

          }
          procedure g_concatcopy_unaligned(list : TAsmList;size: tdef; const source,dest : treference);virtual;
          {# This should emit the opcode to a shortrstring from the source
             to destination.

             @param(source Source reference of copy)
             @param(dest Destination reference of copy)

          }
          procedure g_copyshortstring(list : TAsmList;const source,dest : treference;strdef:tstringdef);virtual;abstract;
          procedure g_copyvariant(list : TAsmList;const source,dest : treference;vardef:tvariantdef);virtual;abstract;

          procedure g_incrrefcount(list : TAsmList;t: tdef; const ref: treference);virtual;abstract;
          procedure g_decrrefcount(list : TAsmList;t: tdef; const ref: treference);virtual;abstract;
          procedure g_initialize(list : TAsmList;t : tdef;const ref : treference);virtual;abstract;
          procedure g_finalize(list : TAsmList;t : tdef;const ref : treference);virtual;abstract;
          procedure g_array_rtti_helper(list: TAsmList; t: tdef; const ref: treference; const highloc: tlocation;
            const name: string);virtual;abstract;

          {# Generates range checking code. It is to note
             that this routine does not need to be overridden,
             as it takes care of everything.

             @param(p Node which contains the value to check)
             @param(todef Type definition of node to range check)
          }
          procedure g_rangecheck(list: TAsmList; const l:tlocation; fromdef,todef: tdef); virtual;

          {# Generates overflow checking code for a node }
          procedure g_overflowcheck(list: TAsmList; const Loc:tlocation; def:tdef); virtual; abstract;
          procedure g_overflowCheck_loc(List:TAsmList;const Loc:TLocation;def:TDef;var ovloc : tlocation);virtual; abstract;

          procedure g_copyvaluepara_openarray(list : TAsmList;const ref:treference;const lenloc:tlocation;arrdef: tarraydef;destreg:tregister);virtual;abstract;
          procedure g_releasevaluepara_openarray(list : TAsmList;arrdef: tarraydef;const l:tlocation);virtual;abstract;

          {# Emits instructions when compilation is done in profile
             mode (this is set as a command line option). The default
             behavior does nothing, should be overridden as required.
          }
          procedure g_profilecode(list : TAsmList);virtual;
          {# Emits instruction for allocating @var(size) bytes at the stackpointer

             @param(size Number of bytes to allocate)
          }
          procedure g_stackpointer_alloc(list : TAsmList;size : longint);virtual; abstract;
          {# Emits instruction for allocating the locals in entry
             code of a routine. This is one of the first
             routine called in @var(genentrycode).

             @param(localsize Number of bytes to allocate as locals)
          }
          procedure g_proc_entry(list : TAsmList;localsize : longint;nostackframe:boolean);virtual; abstract;
          {# Emits instructions for returning from a subroutine.
             Should also restore the framepointer and stack.

             @param(parasize  Number of bytes of parameters to deallocate from stack)
          }
          procedure g_proc_exit(list : TAsmList;parasize:longint;nostackframe:boolean);virtual; abstract;

          procedure g_intf_wrapper(list: TAsmList; procdef: tprocdef; const labelname: string; ioffset: longint);virtual; abstract;
          procedure g_adjust_self_value(list:TAsmList;procdef: tprocdef;ioffset: aint);virtual; abstract;

          function g_indirect_sym_load(list:TAsmList;const symname: string; weak: boolean): tregister;virtual; abstract;
          { generate a stub which only purpose is to pass control the given external method,
          setting up any additional environment before doing so (if required).

          The default implementation issues a jump instruction to the external name. }
//          procedure g_external_wrapper(list : TAsmList; procdef: tprocdef; const externalname: string); virtual;

          { create "safe copy" of a tlocation that can be used later: all
            registers used in the tlocation are copied to new ones, so that
            even if the original ones change, things stay the same (except if
            the original location was already a register, then the register is
            kept). Must only be used on lvalue locations.
            It's intended as some kind of replacement for a_loadaddr_ref_reg()
            for targets without pointers. }
          procedure g_reference_loc(list: TAsmList; def: tdef; const fromloc: tlocation; out toloc: tlocation); virtual; abstract;


          { routines migrated from ncgutil }

          procedure location_force_reg(list:TAsmList;var l:tlocation;src_size,dst_size:tdef;maybeconst:boolean);virtual;
          procedure location_force_fpureg(list:TAsmList;var l: tlocation;size: tdef;maybeconst:boolean);virtual;
          procedure location_force_mem(list:TAsmList;var l:tlocation;size:tdef);virtual;
//          procedure location_force_mmregscalar(list:TAsmList;var l: tlocation;size:tdef;maybeconst:boolean);virtual;abstract;
//          procedure location_force_mmreg(list:TAsmList;var l: tlocation;size:tdef;maybeconst:boolean);virtual;abstract;

          { Retrieve the location of the data pointed to in location l, when the location is
            a register it is expected to contain the address of the data }
          procedure location_get_data_ref(list:TAsmList;def: tdef; const l:tlocation;var ref:treference;loadref:boolean; alignment: longint);virtual;

          procedure maketojumpbool(list:TAsmList; p : tnode);virtual;

          procedure gen_proc_symbol(list:TAsmList);virtual;
          procedure gen_proc_symbol_end(list:TAsmList);virtual;

          procedure gen_load_para_value(list:TAsmList);virtual;
         protected
          { helpers called by gen_load_para_value }
          procedure g_copyvalueparas(p:TObject;arg:pointer);virtual;
          procedure gen_loadfpu_loc_cgpara(list: TAsmList; size: tdef; const l: tlocation;const cgpara: tcgpara;locintsize: longint);virtual;
          procedure init_paras(p:TObject;arg:pointer);
         protected
          { Some targets have to put "something" in the function result
            location if it's not initialised by the Pascal code, e.g.
            stack-based architectures. By default it does nothing }
          procedure gen_load_uninitialized_function_result(list: TAsmList; pd: tprocdef; resdef: tdef; const resloc: tcgpara);virtual;
         public
          { load a tlocation into a cgpara }
          procedure gen_load_loc_cgpara(list: TAsmList; vardef: tdef; const l: tlocation; const cgpara: tcgpara);virtual;

          { load a cgpara into a tlocation }
          procedure gen_load_cgpara_loc(list: TAsmList; vardef: tdef; const para: TCGPara; var destloc: tlocation; reusepara: boolean);virtual;

          { load the function return value into the ABI-defined function return location }
          procedure gen_load_return_value(list:TAsmList);virtual;

          { extras refactored from other units }

          { queue the code/data generated for a procedure for writing out to
            the assembler/object file }
          procedure record_generated_code_for_procdef(pd: tprocdef; code, data: TAsmList); virtual;

       end;

    var
       {# Main high level code generator class }
       hlcg : thlcgobj;

    procedure destroy_hlcodegen;

implementation

    uses
       globals,options,systems,
       fmodule,export,
       verbose,defutil,paramgr,symsym,
       ncon,
       cpuinfo,cgobj,tgobj,cutils,procinfo,
       ncgutil;


    procedure destroy_hlcodegen;
      begin
        hlcg.free;
        hlcg:=nil;
      end;

  { thlcgobj }

  constructor thlcgobj.create;
    begin
    end;

  procedure thlcgobj.init_register_allocators;
    begin
      cg.init_register_allocators;
    end;

  procedure thlcgobj.done_register_allocators;
    begin
      cg.done_register_allocators;
    end;

  procedure thlcgobj.set_regalloc_live_range_direction(dir: TRADirection);
    begin
      cg.set_regalloc_live_range_direction(dir);
    end;

  function thlcgobj.getintregister(list: TAsmList; size: tdef): Tregister;
    begin
      result:=cg.getintregister(list,def_cgsize(size));
    end;

  function thlcgobj.getaddressregister(list: TAsmList; size: tdef): Tregister;
    begin
      result:=cg.getaddressregister(list);
    end;

  function thlcgobj.getfpuregister(list: TAsmList; size: tdef): Tregister;
    begin
      result:=cg.getfpuregister(list,def_cgsize(size));
    end;
(*
  function thlcgobj.getmmregister(list: TAsmList; size: tdef): Tregister;
    begin
      result:=cg.getmmregister(list,def_cgsize(size));
    end;
*)
  function thlcgobj.getflagregister(list: TAsmList; size: tdef): Tregister;
    begin
      result:=cg.getflagregister(list,def_cgsize(size));
    end;

    function thlcgobj.getregisterfordef(list: TAsmList; size: tdef): Tregister;
      begin
        case def2regtyp(size) of
          R_INTREGISTER:
            result:=getintregister(list,size);
          R_ADDRESSREGISTER:
            result:=getaddressregister(list,size);
          R_FPUREGISTER:
            result:=getfpuregister(list,size);
(*
          R_MMREGISTER:
            result:=getmmregister(list,size);
*)
          else
            internalerror(2010122901);
        end;
      end;

  function thlcgobj.uses_registers(rt: Tregistertype): boolean;
    begin
       result:=cg.uses_registers(rt);
    end;

  procedure thlcgobj.do_register_allocation(list: TAsmList; headertai: tai);
    begin
      cg.do_register_allocation(list,headertai);
    end;

  procedure thlcgobj.translate_register(var reg: tregister);
    begin
      cg.translate_register(reg);
    end;

  procedure thlcgobj.a_label(list: TAsmList; l: tasmlabel); inline;
    begin
      cg.a_label(list,l);
    end;

  procedure thlcgobj.a_reg_alloc(list: TAsmList; r: tregister);
    begin
      cg.a_reg_alloc(list,r);
    end;

  procedure thlcgobj.a_reg_dealloc(list: TAsmList; r: tregister);
    begin
      cg.a_reg_dealloc(list,r);
    end;

  procedure thlcgobj.a_reg_sync(list: TAsmList; r: tregister);
    begin
      cg.a_reg_sync(list,r);
    end;

  procedure thlcgobj.a_load_reg_cgpara(list: TAsmList; size: tdef; r: tregister; const cgpara: TCGPara);
    var
      ref: treference;
    begin
      cgpara.check_simple_location;
      paramanager.alloccgpara(list,cgpara);
      case cgpara.location^.loc of
         LOC_REGISTER,LOC_CREGISTER:
           a_load_reg_reg(list,size,cgpara.def,r,cgpara.location^.register);
         LOC_REFERENCE,LOC_CREFERENCE:
           begin
              reference_reset_base(ref,cgpara.location^.reference.index,cgpara.location^.reference.offset,cgpara.alignment);
              a_load_reg_ref(list,size,cgpara.def,r,ref);
           end;
(*
         LOC_MMREGISTER,LOC_CMMREGISTER:
           a_loadmm_intreg_reg(list,size,cgpara.def,r,cgpara.location^.register,mms_movescalar);
*)
         LOC_FPUREGISTER,LOC_CFPUREGISTER:
           begin
             tg.gethltemp(list,size,size.size,tt_normal,ref);
             a_load_reg_ref(list,size,size,r,ref);
             a_loadfpu_ref_cgpara(list,size,ref,cgpara);
             tg.ungettemp(list,ref);
           end
         else
           internalerror(2010120415);
      end;
    end;

  procedure thlcgobj.a_load_const_cgpara(list: TAsmList; tosize: tdef; a: aint; const cgpara: TCGPara);
    var
       ref : treference;
    begin
       cgpara.check_simple_location;
       paramanager.alloccgpara(list,cgpara);
       case cgpara.location^.loc of
          LOC_REGISTER,LOC_CREGISTER:
            a_load_const_reg(list,cgpara.def,a,cgpara.location^.register);
          LOC_REFERENCE,LOC_CREFERENCE:
            begin
               reference_reset_base(ref,cgpara.location^.reference.index,cgpara.location^.reference.offset,cgpara.alignment);
               a_load_const_ref(list,cgpara.def,a,ref);
            end
          else
            internalerror(2010120416);
       end;
    end;

  procedure thlcgobj.a_load_ref_cgpara(list: TAsmList; size: tdef; const r: treference; const cgpara: TCGPara);
    var
      ref: treference;
    begin
      cgpara.check_simple_location;
      paramanager.alloccgpara(list,cgpara);
      case cgpara.location^.loc of
         LOC_REGISTER,LOC_CREGISTER:
           a_load_ref_reg(list,size,cgpara.def,r,cgpara.location^.register);
         LOC_REFERENCE,LOC_CREFERENCE:
           begin
              reference_reset_base(ref,cgpara.location^.reference.index,cgpara.location^.reference.offset,cgpara.alignment);
              a_load_ref_ref(list,size,cgpara.def,r,ref);
           end
(*
         LOC_MMREGISTER,LOC_CMMREGISTER:
           begin
              case location^.size of
                OS_F32,
                OS_F64,
                OS_F128:
                  a_loadmm_ref_reg(list,cgpara.def,cgpara.def,r,location^.register,mms_movescalar);
                OS_M8..OS_M128,
                OS_MS8..OS_MS128:
                  a_loadmm_ref_reg(list,cgpara.def,cgpara.def,r,location^.register,nil);
                else
                  internalerror(2010120417);
              end;
           end
*)
         else
           internalerror(2010120418);
      end;
    end;

  procedure thlcgobj.a_load_loc_cgpara(list: TAsmList; size: tdef; const l: tlocation; const cgpara: TCGPara);
    begin
      case l.loc of
        LOC_REGISTER,
        LOC_CREGISTER :
          a_load_reg_cgpara(list,size,l.register,cgpara);
        LOC_CONSTANT :
          a_load_const_cgpara(list,size,l.value,cgpara);
        LOC_CREFERENCE,
        LOC_REFERENCE :
          a_load_ref_cgpara(list,size,l.reference,cgpara);
        else
          internalerror(2010120419);
      end;
    end;

  procedure thlcgobj.a_loadaddr_ref_cgpara(list: TAsmList; fromsize, tosize: tdef; const r: treference; const cgpara: TCGPara);
    var
       hr : tregister;
    begin
       cgpara.check_simple_location;
       if cgpara.location^.loc in [LOC_CREGISTER,LOC_REGISTER] then
         begin
           paramanager.allocparaloc(list,cgpara.location);
           a_loadaddr_ref_reg(list,fromsize,tosize,r,cgpara.location^.register)
         end
       else
         begin
           hr:=getaddressregister(list,tosize);
           a_loadaddr_ref_reg(list,fromsize,tosize,r,hr);
           a_load_reg_cgpara(list,tosize,hr,cgpara);
         end;
    end;

  procedure thlcgobj.a_call_name_static(list: TAsmList; pd: tprocdef; const s: string);
    begin
      a_call_name(list,pd,s,false);
    end;

    procedure thlcgobj.a_call_name_inherited(list: TAsmList; pd: tprocdef; const s: string);
      begin
        a_call_name(list,pd,s,false);
      end;

  procedure thlcgobj.a_load_const_ref(list: TAsmList; tosize: tdef; a: aint; const ref: treference);
    var
      tmpreg: tregister;
    begin
      tmpreg:=getintregister(list,tosize);
      a_load_const_reg(list,tosize,a,tmpreg);
      a_load_reg_ref(list,tosize,tosize,tmpreg,ref);
    end;

  procedure thlcgobj.a_load_const_loc(list: TAsmList; tosize: tdef; a: aint; const loc: tlocation);
    begin
      case loc.loc of
        LOC_REFERENCE,LOC_CREFERENCE:
          a_load_const_ref(list,tosize,a,loc.reference);
        LOC_REGISTER,LOC_CREGISTER:
          a_load_const_reg(list,tosize,a,loc.register);
        { we don't have enough type information to handle these here
        LOC_SUBSETREG,LOC_CSUBSETREG:
          a_load_const_subsetreg(list,loc.size,a,loc.sreg);
        LOC_SUBSETREF,LOC_CSUBSETREF:
          a_load_const_subsetref(list,loc.size,a,loc.sref);
        }
        else
          internalerror(2010120401);
      end;
    end;

  procedure thlcgobj.a_load_reg_ref_unaligned(list: TAsmList; fromsize, tosize: tdef; register: tregister; const ref: treference);
    begin
      a_load_reg_ref(list,fromsize,tosize,register,ref);
    end;

  procedure thlcgobj.a_load_reg_loc(list: TAsmList; fromsize, tosize: tdef; reg: tregister; const loc: tlocation);
    begin
      case loc.loc of
        LOC_REFERENCE,LOC_CREFERENCE:
          a_load_reg_ref(list,fromsize,tosize,reg,loc.reference);
        LOC_REGISTER,LOC_CREGISTER:
          a_load_reg_reg(list,fromsize,tosize,reg,loc.register);
        { we don't have enough type information to handle these here
        LOC_SUBSETREG,LOC_CSUBSETREG:
          a_load_reg_subsetreg(list,fromsize,tosize,reg,loc.sreg);
        LOC_SUBSETREF,LOC_CSUBSETREF:
          a_load_reg_subsetref(list,fromsize,loc.size,reg,loc.sref);
        LOC_MMREGISTER,LOC_CMMREGISTER:
          a_loadmm_intreg_reg(list,fromsize,loc.size,reg,loc.register,mms_movescalar);
        }
        else
          internalerror(2010120402);
      end;
    end;

  procedure thlcgobj.a_load_ref_reg_unaligned(list: TAsmList; fromsize, tosize: tdef; const ref: treference; register: tregister);
    begin
      a_load_ref_reg(list,fromsize,tosize,ref,register);
    end;

  procedure thlcgobj.a_load_ref_ref(list: TAsmList; fromsize, tosize: tdef; const sref: treference; const dref: treference);
    var
      tmpreg: tregister;
    begin
      { verify if we have the same reference }
      if references_equal(sref,dref) then
        exit;
      tmpreg:=getintregister(list,tosize);
      a_load_ref_reg(list,fromsize,tosize,sref,tmpreg);
      a_load_reg_ref(list,tosize,tosize,tmpreg,dref);
    end;

  procedure thlcgobj.a_load_loc_reg(list: TAsmList; fromsize, tosize: tdef; const loc: tlocation; reg: tregister);
    begin
      case loc.loc of
        LOC_REFERENCE,LOC_CREFERENCE:
          a_load_ref_reg(list,fromsize,tosize,loc.reference,reg);
        LOC_REGISTER,LOC_CREGISTER:
          a_load_reg_reg(list,fromsize,tosize,loc.register,reg);
        LOC_CONSTANT:
          a_load_const_reg(list,tosize,loc.value,reg);
        { we don't have enough type information to handle these here
        LOC_SUBSETREG,LOC_CSUBSETREG:
          a_load_subsetreg_reg(list,fromsize,tosize,loc.sreg,reg);
        LOC_SUBSETREF,LOC_CSUBSETREF:
          a_load_subsetref_reg(list,fromsize,tosize,loc.sref,reg);
        }
        else
          internalerror(2010120201);
      end;
    end;

  procedure thlcgobj.a_load_loc_ref(list: TAsmList; fromsize, tosize: tdef; const loc: tlocation; const ref: treference);
    begin
      case loc.loc of
        LOC_REFERENCE,LOC_CREFERENCE:
          a_load_ref_ref(list,fromsize,tosize,loc.reference,ref);
        LOC_REGISTER,LOC_CREGISTER:
          a_load_reg_ref(list,fromsize,tosize,loc.register,ref);
        LOC_CONSTANT:
          a_load_const_ref(list,tosize,loc.value,ref);
        { we don't have enough type information to handle these here
        LOC_SUBSETREG,LOC_CSUBSETREG:
          a_load_subsetreg_ref(list,loc.size,tosize,loc.sreg,ref);
        LOC_SUBSETREF,LOC_CSUBSETREF:
          a_load_subsetref_ref(list,loc.size,tosize,loc.sref,ref);
        }
        else
          internalerror(2010120403);
      end;
    end;

  procedure thlcgobj.a_load_loc_subsetreg(list: TAsmList; fromsize, tosize, tosubsetsize: tdef; const loc: tlocation; const sreg: tsubsetregister);
    begin
      case loc.loc of
        LOC_REFERENCE,LOC_CREFERENCE:
          a_load_ref_subsetreg(list,fromsize,tosize,tosubsetsize,loc.reference,sreg);
        LOC_REGISTER,LOC_CREGISTER:
          a_load_reg_subsetreg(list,fromsize,tosize,tosubsetsize,loc.register,sreg);
        LOC_CONSTANT:
          a_load_const_subsetreg(list,tosize,tosubsetsize,loc.value,sreg);
        { we don't have enough type information to handle these here
        LOC_SUBSETREG,LOC_CSUBSETREG:
          a_load_subsetreg_subsetreg(list,loc.size,subsetsize,loc.sreg,sreg);
        LOC_SUBSETREF,LOC_CSUBSETREF:
          a_load_subsetref_subsetreg(list,loc.size,subsetsize,loc.sref,sreg);
        }
        else
          internalerror(2010120404);
      end;
    end;

  procedure thlcgobj.a_load_loc_subsetref(list: TAsmList; fromsize, tosize, tosubsetsize: tdef; const loc: tlocation; const sref: tsubsetreference);
    begin
      case loc.loc of
        LOC_REFERENCE,LOC_CREFERENCE:
          a_load_ref_subsetref(list,fromsize,tosize,tosubsetsize,loc.reference,sref);
        LOC_REGISTER,LOC_CREGISTER:
          a_load_reg_subsetref(list,fromsize,tosize,tosubsetsize,loc.register,sref);
        LOC_CONSTANT:
          a_load_const_subsetref(list,tosize,tosubsetsize,loc.value,sref);
        { we don't have enough type information to handle these here
        LOC_SUBSETREG,LOC_CSUBSETREG:
          a_load_subsetreg_subsetref(list,loc.size,subsetsize,loc.sreg,sref);
        LOC_SUBSETREF,LOC_CSUBSETREF:
          a_load_subsetref_subsetref(list,loc.size,subsetsize,loc.sref,sref);
        }
        else
          internalerror(2010120405);
      end;
    end;

  procedure thlcgobj.a_load_subsetreg_loc(list: TAsmlist; fromsize, fromsubsetsize, tosize: tdef; const sreg: tsubsetregister; const loc: tlocation);
    begin
      case loc.loc of
        LOC_REFERENCE,LOC_CREFERENCE:
          a_load_subsetreg_ref(list,fromsize,fromsubsetsize,tosize,sreg,loc.reference);
        LOC_REGISTER,LOC_CREGISTER:
          a_load_subsetreg_reg(list,fromsize,fromsubsetsize,tosize,sreg,loc.register);
        { we don't have enough type information to handle these here
        LOC_SUBSETREG,LOC_CSUBSETREG:
          a_load_subsetreg_subsetreg(list,subsetsize,loc.size,sreg,loc.sreg);
        LOC_SUBSETREF,LOC_CSUBSETREF:
          a_load_subsetreg_subsetref(list,subsetsize,loc.size,sreg,loc.sref);
        }
        else
          internalerror(2010120406);
      end;
    end;

  procedure thlcgobj.a_load_subsetref_loc(list: TAsmlist; fromsize, fromsubsetsize, tosize: tdef; const sref: tsubsetreference; const loc: tlocation);
    begin
      case loc.loc of
        LOC_REFERENCE,LOC_CREFERENCE:
          a_load_subsetref_ref(list,fromsize,fromsubsetsize,tosize,sref,loc.reference);
        LOC_REGISTER,LOC_CREGISTER:
          a_load_subsetref_reg(list,fromsize,fromsubsetsize,tosize,sref,loc.register);
        { we don't have enough type information to handle these here
        LOC_SUBSETREG,LOC_CSUBSETREG:
          a_load_subsetref_subsetreg(list,subsetsize,loc.size,sref,loc.sreg);
        LOC_SUBSETREF,LOC_CSUBSETREF:
          a_load_subsetref_subsetref(list,subsetsize,loc.size,sref,loc.sref);
        }
        else
          internalerror(2010120407);
      end;
    end;

  procedure thlcgobj.a_bit_test_reg_loc_reg(list: TAsmList; bitnumbersize, locsize, destsize: tdef; bitnumber: tregister; const loc: tlocation; destreg: tregister);
    var
      tmpreg: tregister;
    begin
      case loc.loc of
        LOC_REFERENCE,LOC_CREFERENCE:
          a_bit_test_reg_ref_reg(list,bitnumbersize,locsize,destsize,bitnumber,loc.reference,destreg);
        LOC_REGISTER,LOC_CREGISTER,
        LOC_SUBSETREG,LOC_CSUBSETREG,
        LOC_CONSTANT:
          begin
            case loc.loc of
              LOC_REGISTER,LOC_CREGISTER:
                tmpreg:=loc.register;
              (* we don't have enough type information to handle this here
              LOC_SUBSETREG,LOC_CSUBSETREG:
                begin
                  tmpreg:=getintregister(list,loc.size);
                  a_load_subsetreg_reg(list,loc.size,loc.size,loc.sreg,tmpreg);
                end;
              *)
              LOC_CONSTANT:
                begin
                  tmpreg:=getintregister(list,locsize);
                  a_load_const_reg(list,locsize,loc.value,tmpreg);
                end;
            end;
            a_bit_test_reg_reg_reg(list,bitnumbersize,locsize,destsize,bitnumber,tmpreg,destreg);
          end;
        { LOC_SUBSETREF is not possible, because sets are not (yet) bitpacked }
        else
          internalerror(2010120411);
      end;
    end;

  procedure thlcgobj.a_bit_test_const_loc_reg(list: TAsmList; locsize, destsize: tdef; bitnumber: aint; const loc: tlocation; destreg: tregister);
    begin
      case loc.loc of
        LOC_REFERENCE,LOC_CREFERENCE:
          a_bit_test_const_ref_reg(list,locsize,destsize,bitnumber,loc.reference,destreg);
        LOC_REGISTER,LOC_CREGISTER:
          a_bit_test_const_reg_reg(list,locsize,destsize,bitnumber,loc.register,destreg);
        (* we don't have enough type information to handle this here
        LOC_SUBSETREG,LOC_CSUBSETREG:
          a_bit_test_const_subsetreg_reg(list,loc.size,destsize,bitnumber,loc.sreg,destreg);
        *)
        { LOC_SUBSETREF is not possible, because sets are not (yet) bitpacked }
        else
          internalerror(2010120410);
      end;
    end;

  procedure thlcgobj.a_bit_set_reg_loc(list: TAsmList; doset: boolean; fromsize, tosize: tdef; bitnumber: tregister; const loc: tlocation);
    begin
      case loc.loc of
        LOC_REFERENCE:
          a_bit_set_reg_ref(list,doset,fromsize,tosize,bitnumber,loc.reference);
        LOC_CREGISTER:
          a_bit_set_reg_reg(list,doset,fromsize,tosize,bitnumber,loc.register);
        (* we don't have enough type information to handle this here
        { e.g. a 2-byte set in a record regvar }
        LOC_CSUBSETREG:
          begin
            { hard to do in-place in a generic way, so operate on a copy }
            tmpreg:=getintregister(list,loc.size);
            a_load_subsetreg_reg(list,loc.size,loc.size,loc.sreg,tmpreg);
            a_bit_set_reg_reg(list,doset,bitnumbersize,loc.size,bitnumber,tmpreg);
            a_load_reg_subsetreg(list,loc.size,loc.size,tmpreg,loc.sreg);
          end;
        *)
        { LOC_SUBSETREF is not possible, because sets are not (yet) bitpacked }
        else
          internalerror(2010120408)
      end;
    end;

  procedure thlcgobj.a_bit_set_const_loc(list: TAsmList; doset: boolean; tosize: tdef; bitnumber: aint; const loc: tlocation);
    begin
      case loc.loc of
        LOC_REFERENCE:
          a_bit_set_const_ref(list,doset,tosize,bitnumber,loc.reference);
        LOC_CREGISTER:
          a_bit_set_const_reg(list,doset,tosize,bitnumber,loc.register);
        (* we don't have enough type information to handle this here
        LOC_CSUBSETREG:
          a_bit_set_const_subsetreg(list,doset,loc.size,bitnumber,loc.sreg);
        *)
        { LOC_SUBSETREF is not possible, because sets are not (yet) bitpacked }
        else
          internalerror(2010120409)
      end;
    end;

  procedure thlcgobj.a_loadfpu_ref_ref(list: TAsmList; fromsize, tosize: tdef; const ref1, ref2: treference);
    var
      reg: tregister;
      regsize: tdef;
    begin
      if (fromsize.size>=tosize.size) then
        regsize:=fromsize
      else
        regsize:=tosize;
      reg:=getfpuregister(list,regsize);
      a_loadfpu_ref_reg(list,fromsize,regsize,ref1,reg);
      a_loadfpu_reg_ref(list,regsize,tosize,reg,ref2);
    end;

  procedure thlcgobj.a_loadfpu_loc_reg(list: TAsmList; fromsize, tosize: tdef; const loc: tlocation; const reg: tregister);
    begin
      case loc.loc of
        LOC_REFERENCE, LOC_CREFERENCE:
          a_loadfpu_ref_reg(list,fromsize,tosize,loc.reference,reg);
        LOC_FPUREGISTER, LOC_CFPUREGISTER:
          a_loadfpu_reg_reg(list,fromsize,tosize,loc.register,reg);
        else
          internalerror(2010120412);
      end;
    end;

  procedure thlcgobj.a_loadfpu_reg_loc(list: TAsmList; fromsize, tosize: tdef; const reg: tregister; const loc: tlocation);
    begin
      case loc.loc of
        LOC_REFERENCE, LOC_CREFERENCE:
          a_loadfpu_reg_ref(list,fromsize,tosize,reg,loc.reference);
        LOC_FPUREGISTER, LOC_CFPUREGISTER:
          a_loadfpu_reg_reg(list,fromsize,tosize,reg,loc.register);
        else
          internalerror(2010120413);
       end;
    end;

  procedure thlcgobj.a_loadfpu_reg_cgpara(list: TAsmList; fromsize: tdef; const r: tregister; const cgpara: TCGPara);
      var
         ref : treference;
      begin
        paramanager.alloccgpara(list,cgpara);
        case cgpara.location^.loc of
          LOC_FPUREGISTER,LOC_CFPUREGISTER:
            begin
              cgpara.check_simple_location;
              a_loadfpu_reg_reg(list,fromsize,cgpara.def,r,cgpara.location^.register);
            end;
          LOC_REFERENCE,LOC_CREFERENCE:
            begin
              cgpara.check_simple_location;
              reference_reset_base(ref,cgpara.location^.reference.index,cgpara.location^.reference.offset,cgpara.alignment);
              a_loadfpu_reg_ref(list,fromsize,cgpara.def,r,ref);
            end;
          LOC_REGISTER,LOC_CREGISTER:
            begin
              { paramfpu_ref does the check_simpe_location check here if necessary }
              tg.gethltemp(list,fromsize,fromsize.size,tt_normal,ref);
              a_loadfpu_reg_ref(list,fromsize,fromsize,r,ref);
              a_loadfpu_ref_cgpara(list,fromsize,ref,cgpara);
              tg.Ungettemp(list,ref);
            end;
          else
            internalerror(2010120422);
        end;
      end;

  procedure thlcgobj.a_loadfpu_ref_cgpara(list: TAsmList; fromsize: tdef; const ref: treference; const cgpara: TCGPara);
    var
       href : treference;
//       hsize: tcgsize;
    begin
       case cgpara.location^.loc of
        LOC_FPUREGISTER,LOC_CFPUREGISTER:
          begin
            cgpara.check_simple_location;
            paramanager.alloccgpara(list,cgpara);
            a_loadfpu_ref_reg(list,fromsize,cgpara.def,ref,cgpara.location^.register);
          end;
        LOC_REFERENCE,LOC_CREFERENCE:
          begin
            cgpara.check_simple_location;
            reference_reset_base(href,cgpara.location^.reference.index,cgpara.location^.reference.offset,cgpara.alignment);
            { concatcopy should choose the best way to copy the data }
            g_concatcopy(list,fromsize,ref,href);
          end;
        (* not yet supported
        LOC_REGISTER,LOC_CREGISTER:
          begin
            { force integer size }
            hsize:=int_cgsize(tcgsize2size[size]);
{$ifndef cpu64bitalu}
            if (hsize in [OS_S64,OS_64]) then
              cg64.a_load64_ref_cgpara(list,ref,cgpara)
            else
{$endif not cpu64bitalu}
              begin
                cgpara.check_simple_location;
                a_load_ref_cgpara(list,hsize,ref,cgpara)
              end;
          end
        *)
        else
          internalerror(2010120423);
      end;
    end;
(*
  procedure thlcgobj.a_loadmm_reg_reg(list: TAsmList; fromsize, tosize: tdef; reg1, reg2: tregister; shuffle: pmmshuffle);
    begin
      cg.a_loadmm_reg_reg(list,def_cgsize(fromsize),def_cgsize(tosize),reg1,reg2,shuffle);
    end;

  procedure thlcgobj.a_loadmm_ref_reg(list: TAsmList; fromsize, tosize: tdef; const ref: treference; reg: tregister; shuffle: pmmshuffle);
    begin
      cg.a_loadmm_ref_reg(list,def_cgsize(fromsize),def_cgsize(tosize),ref,reg,shuffle);
    end;

  procedure thlcgobj.a_loadmm_reg_ref(list: TAsmList; fromsize, tosize: tdef; reg: tregister; const ref: treference; shuffle: pmmshuffle);
    begin
      cg.a_loadmm_reg_ref(list,def_cgsize(fromsize),def_cgsize(tosize),reg,ref,shuffle);
    end;

  procedure thlcgobj.a_loadmm_loc_reg(list: TAsmList; fromsize, tosize: tdef; const loc: tlocation; const reg: tregister; shuffle: pmmshuffle);
    begin
      case loc.loc of
        LOC_MMREGISTER,LOC_CMMREGISTER:
          a_loadmm_reg_reg(list,fromsize,tosize,loc.register,reg,shuffle);
        LOC_REFERENCE,LOC_CREFERENCE:
          a_loadmm_ref_reg(list,fromsize,tosize,loc.reference,reg,shuffle);
        LOC_REGISTER,LOC_CREGISTER:
          a_loadmm_intreg_reg(list,fromsize,tosize,loc.register,reg,shuffle);
        else
          internalerror(2010120414);
      end;
    end;

  procedure thlcgobj.a_loadmm_reg_loc(list: TAsmList; fromsize, tosize: tdef; const reg: tregister; const loc: tlocation; shuffle: pmmshuffle);
    begin
      case loc.loc of
        LOC_MMREGISTER,LOC_CMMREGISTER:
          a_loadmm_reg_reg(list,fromsize,tosize,reg,loc.register,shuffle);
        LOC_REFERENCE,LOC_CREFERENCE:
          a_loadmm_reg_ref(list,fromsize,tosize,reg,loc.reference,shuffle);
        else
          internalerror(2010120415);
      end;
    end;

  procedure thlcgobj.a_loadmm_reg_cgpara(list: TAsmList; fromsize: tdef; reg: tregister; const cgpara: TCGPara; shuffle: pmmshuffle);
    var
      href  : treference;
    begin
       cgpara.check_simple_location;
       paramanager.alloccgpara(list,cgpara);
       case cgpara.location^.loc of
        LOC_MMREGISTER,LOC_CMMREGISTER:
          a_loadmm_reg_reg(list,fromsize,cgpara.def,reg,cgpara.location^.register,shuffle);
        LOC_REFERENCE,LOC_CREFERENCE:
          begin
            reference_reset_base(href,cgpara.location^.reference.index,cgpara.location^.reference.offset,cgpara.alignment);
            a_loadmm_reg_ref(list,fromsize,cgpara.def,reg,href,shuffle);
          end;
        LOC_REGISTER,LOC_CREGISTER:
          begin
            if assigned(shuffle) and
               not shufflescalar(shuffle) then
              internalerror(2009112510);
             a_loadmm_reg_intreg(list,deomsize,cgpara.def,reg,cgpara.location^.register,mms_movescalar);
          end
        else
          internalerror(2010120427);
      end;
    end;

  procedure thlcgobj.a_loadmm_ref_cgpara(list: TAsmList; fromsize: tdef; const ref: treference; const cgpara: TCGPara; shuffle: pmmshuffle);
    var
       hr : tregister;
       hs : tmmshuffle;
    begin
       cgpara.check_simple_location;
       hr:=cg.getmmregister(list,cgpara.size);
       a_loadmm_ref_reg(list,deomsize,cgpara.def,ref,hr,shuffle);
       if realshuffle(shuffle) then
         begin
           hs:=shuffle^;
           removeshuffles(hs);
           a_loadmm_reg_cgpara(list,cgpara.def,hr,cgpara,@hs);
         end
       else
         a_loadmm_reg_cgpara(list,cgpara.def,hr,cgpara,shuffle);
    end;

  procedure thlcgobj.a_loadmm_loc_cgpara(list: TAsmList; fromsize: tdef; const loc: tlocation; const cgpara: TCGPara; shuffle: pmmshuffle);
    begin
{$ifdef extdebug}
      if def_cgsize(fromsize)<>loc.size then
        internalerror(2010112105);
{$endif}
      cg.a_loadmm_loc_cgpara(list,loc,cgpara,shuffle);
    end;

  procedure thlcgobj.a_opmm_reg_reg(list: TAsmList; Op: TOpCG; size: tdef; src, dst: tregister; shuffle: pmmshuffle);
    begin
      cg.a_opmm_reg_reg(list,op,def_cgsize(size),src,dst,shuffle);
    end;

  procedure thlcgobj.a_opmm_ref_reg(list: TAsmList; Op: TOpCG; size: tdef; const ref: treference; reg: tregister; shuffle: pmmshuffle);
    begin
      cg.a_opmm_ref_reg(list,op,def_cgsize(size),ref,reg,shuffle)
    end;

  procedure thlcgobj.a_opmm_loc_reg(list: TAsmList; Op: TOpCG; size: tdef; const loc: tlocation; reg: tregister; shuffle: pmmshuffle);
    begin
      cg.a_opmm_loc_reg(list,op,def_cgsize(size),loc,reg,shuffle);
    end;

  procedure thlcgobj.a_opmm_reg_ref(list: TAsmList; Op: TOpCG; size: tdef; reg: tregister; const ref: treference; shuffle: pmmshuffle);
    begin
      cg.a_opmm_reg_ref(list,op,def_cgsize(size),reg,ref,shuffle);
    end;
*)
(*
  procedure thlcgobj.a_loadmm_intreg_reg(list: TAsmList; fromsize, tosize: tdef; intreg, mmreg: tregister; shuffle: pmmshuffle);
    begin
      cg.a_loadmm_intreg_reg(list,def_cgsize(fromsize),def_cgsize(tosize),intreg,mmreg,shuffle);
    end;

  procedure thlcgobj.a_loadmm_reg_intreg(list: TAsmList; fromsize, tosize: tdef; mmreg, intreg: tregister; shuffle: pmmshuffle);
    begin
      cg.a_loadmm_reg_intreg(list,def_cgsize(fromsize),def_cgsize(tosize),mmreg,intreg,shuffle);
    end;
*)
  procedure thlcgobj.a_op_const_ref(list: TAsmList; Op: TOpCG; size: tdef; a: Aint; const ref: TReference);
    var
      tmpreg : tregister;
    begin
      tmpreg:=getintregister(list,size);
      a_load_ref_reg(list,size,size,ref,tmpreg);
      a_op_const_reg(list,op,size,a,tmpreg);
      a_load_reg_ref(list,size,size,tmpreg,ref);
    end;

  procedure thlcgobj.a_op_const_subsetreg(list: TAsmList; Op: TOpCG; size, subsetsize: tdef; a: aint; const sreg: tsubsetregister);
    var
      tmpreg: tregister;
    begin
      tmpreg:=getintregister(list,size);
      a_load_subsetreg_reg(list,size,subsetsize,size,sreg,tmpreg);
      a_op_const_reg(list,op,size,a,tmpreg);
      a_load_reg_subsetreg(list,size,size,subsetsize,tmpreg,sreg);
    end;

  procedure thlcgobj.a_op_const_subsetref(list: TAsmList; Op: TOpCG; size, subsetsize: tdef; a: aint; const sref: tsubsetreference);
    var
      tmpreg: tregister;
    begin
      tmpreg:=getintregister(list,size);
      a_load_subsetref_reg(list,size,subsetsize,size,sref,tmpreg);
      a_op_const_reg(list,op,size,a,tmpreg);
      a_load_reg_subsetref(list,size,size,subsetsize,tmpreg,sref);
    end;

  procedure thlcgobj.a_op_const_loc(list: TAsmList; Op: TOpCG; size: tdef; a: Aint; const loc: tlocation);
    begin
      case loc.loc of
        LOC_REGISTER, LOC_CREGISTER:
          a_op_const_reg(list,op,size,a,loc.register);
        LOC_REFERENCE, LOC_CREFERENCE:
          a_op_const_ref(list,op,size,a,loc.reference);
        { we don't have enough type information to handle these here
        LOC_SUBSETREG, LOC_CSUBSETREG:
          a_op_const_subsetreg(list,op,loc.size,loc.size,a,loc.sreg);
        LOC_SUBSETREF, LOC_CSUBSETREF:
          a_op_const_subsetref(list,op,loc.size,loc.size,a,loc.sref);
        }
        else
          internalerror(2010120428);
      end;
    end;

  procedure thlcgobj.a_op_reg_ref(list: TAsmList; Op: TOpCG; size: tdef; reg: TRegister; const ref: TReference);
    var
      tmpreg: tregister;
    begin
      case op of
        OP_NOT,OP_NEG:
          { handle it as "load ref,reg; op reg" }
          begin
            a_load_ref_reg(list,size,size,ref,reg);
            a_op_reg_reg(list,op,size,reg,reg);
          end;
        else
          begin
            tmpreg:=getintregister(list,size);
            a_load_ref_reg(list,size,size,ref,tmpreg);
            a_op_reg_reg(list,op,size,tmpreg,reg);
          end;
      end;
    end;

  procedure thlcgobj.a_op_ref_reg(list: TAsmList; Op: TOpCG; size: tdef; const ref: TReference; reg: TRegister);
      var
        tmpreg: tregister;
      begin
        case op of
          OP_NOT,OP_NEG:
            { handle it as "load ref,reg; op reg" }
            begin
              a_load_ref_reg(list,size,size,ref,reg);
              a_op_reg_reg(list,op,size,reg,reg);
            end;
          else
            begin
              tmpreg:=getintregister(list,size);
              a_load_ref_reg(list,size,size,ref,tmpreg);
              a_op_reg_reg(list,op,size,tmpreg,reg);
            end;
        end;
      end;

  procedure thlcgobj.a_op_reg_subsetreg(list: TAsmList; Op: TOpCG; opsize, destsize, destsubsetsize: tdef; reg: TRegister; const sreg: tsubsetregister);
    var
      tmpreg: tregister;
    begin
      tmpreg:=getintregister(list,opsize);
      a_load_subsetreg_reg(list,destsize,destsubsetsize,opsize,sreg,tmpreg);
      a_op_reg_reg(list,op,opsize,reg,tmpreg);
      a_load_reg_subsetreg(list,opsize,destsize,destsubsetsize,tmpreg,sreg);
    end;

  procedure thlcgobj.a_op_reg_subsetref(list: TAsmList; Op: TOpCG; opsize, destsize, destsubsetsize: tdef; reg: TRegister; const sref: tsubsetreference);
    var
      tmpreg: tregister;
    begin
      tmpreg:=getintregister(list,opsize);
      a_load_subsetref_reg(list,destsize,destsubsetsize,opsize,sref,tmpreg);
      a_op_reg_reg(list,op,opsize,reg,tmpreg);
      a_load_reg_subsetref(list,opsize,destsize,destsubsetsize,tmpreg,sref);
    end;

  procedure thlcgobj.a_op_reg_loc(list: TAsmList; Op: TOpCG; size: tdef; reg: tregister; const loc: tlocation);
    begin
      case loc.loc of
        LOC_REGISTER, LOC_CREGISTER:
          a_op_reg_reg(list,op,size,reg,loc.register);
        LOC_REFERENCE, LOC_CREFERENCE:
          a_op_reg_ref(list,op,size,reg,loc.reference);
        { we don't have enough type information to handle these here
        LOC_SUBSETREG, LOC_CSUBSETREG:
          a_op_reg_subsetreg(list,op,loc.size,loc.size,reg,loc.sreg);
        LOC_SUBSETREF, LOC_CSUBSETREF:
          a_op_reg_subsetref(list,op,loc.size,loc.size,reg,loc.sref);
        }
        else
          internalerror(2010120429);
      end;
    end;

  procedure thlcgobj.a_op_ref_loc(list: TAsmList; Op: TOpCG; size: tdef; const ref: TReference; const loc: tlocation);
    var
      tmpreg: tregister;
    begin
      case loc.loc of
        LOC_REGISTER,LOC_CREGISTER:
          a_op_ref_reg(list,op,size,ref,loc.register);
        LOC_REFERENCE,LOC_CREFERENCE:
          begin
            tmpreg:=getintregister(list,size);
            a_load_ref_reg(list,size,size,ref,tmpreg);
            a_op_reg_ref(list,op,size,tmpreg,loc.reference);
          end;
        { we don't have enough type information to handle these here
        LOC_SUBSETREG, LOC_CSUBSETREG:
          begin
            tmpreg:=getintregister(list,loc.size);
            a_load_subsetreg_reg(list,loc.size,loc.size,loc.sreg,tmpreg);
            a_op_ref_reg(list,op,loc.size,ref,tmpreg);
            a_load_reg_subsetreg(list,loc.size,loc.size,tmpreg,loc.sreg);
          end;
        LOC_SUBSETREF, LOC_CSUBSETREF:
          begin
            tmpreg:=getintregister(list,loc.size);
            a_load_subsetreF_reg(list,loc.size,loc.size,loc.sref,tmpreg);
            a_op_ref_reg(list,op,loc.size,ref,tmpreg);
            a_load_reg_subsetref(list,loc.size,loc.size,tmpreg,loc.sref);
          end;
          }
        else
          internalerror(2010120429);
      end;
    end;

  procedure thlcgobj.a_op_const_reg_reg(list: TAsmList; op: TOpCg; size: tdef; a: aint; src, dst: tregister);
    begin
      a_load_reg_reg(list,size,size,src,dst);
      a_op_const_reg(list,op,size,a,dst);
    end;

  procedure thlcgobj.a_op_reg_reg_reg(list: TAsmList; op: TOpCg; size: tdef; src1, src2, dst: tregister);
    var
      tmpreg: tregister;
    begin
      if (dst<>src1) then
        begin
          a_load_reg_reg(list,size,size,src2,dst);
          a_op_reg_reg(list,op,size,src1,dst);
        end
      else
        begin
          { can we do a direct operation on the target register ? }
          if op in [OP_ADD,OP_MUL,OP_AND,OP_MOVE,OP_XOR,OP_IMUL,OP_OR] then
            a_op_reg_reg(list,op,size,src2,dst)
          else
            begin
              tmpreg:=getintregister(list,size);
              a_load_reg_reg(list,size,size,src2,tmpreg);
              a_op_reg_reg(list,op,size,src1,tmpreg);
              a_load_reg_reg(list,size,size,tmpreg,dst);
            end;
        end;
    end;

  procedure thlcgobj.a_op_const_reg_reg_checkoverflow(list: TAsmList; op: TOpCg; size: tdef; a: aint; src, dst: tregister; setflags: boolean; var ovloc: tlocation);
    begin
      if not setflags then
        a_op_const_reg_reg(list,op,size,a,src,dst)
      else
        internalerror(2010122910);
    end;

  procedure thlcgobj.a_op_reg_reg_reg_checkoverflow(list: TAsmList; op: TOpCg; size: tdef; src1, src2, dst: tregister; setflags: boolean; var ovloc: tlocation);
    begin
      if not setflags then
        a_op_reg_reg_reg(list,op,size,src1,src2,dst)
      else
        internalerror(2010122911);
    end;

  procedure thlcgobj.a_cmp_const_reg_label(list: TAsmList; size: tdef; cmp_op: topcmp; a: aint; reg: tregister; l: tasmlabel);
    var
      tmpreg: tregister;
    begin
      tmpreg:=getintregister(list,size);
      a_load_const_reg(list,size,a,tmpreg);
      a_cmp_reg_reg_label(list,size,cmp_op,tmpreg,reg,l);
    end;

  procedure thlcgobj.a_cmp_const_ref_label(list: TAsmList; size: tdef; cmp_op: topcmp; a: aint; const ref: treference; l: tasmlabel);
    var
      tmpreg: tregister;
    begin
      tmpreg:=getintregister(list,size);
      a_load_ref_reg(list,size,size,ref,tmpreg);
      a_cmp_const_reg_label(list,size,cmp_op,a,tmpreg,l);
    end;

  procedure thlcgobj.a_cmp_const_loc_label(list: TAsmList; size: tdef; cmp_op: topcmp; a: aint; const loc: tlocation; l: tasmlabel);
    begin
      case loc.loc of
        LOC_REGISTER,LOC_CREGISTER:
          a_cmp_const_reg_label(list,size,cmp_op,a,loc.register,l);
        LOC_REFERENCE,LOC_CREFERENCE:
          a_cmp_const_ref_label(list,size,cmp_op,a,loc.reference,l);
        { we don't have enough type information to handle these here
        LOC_SUBSETREG, LOC_CSUBSETREG:
          begin
            tmpreg:=getintregister(list,size);
            a_load_subsetreg_reg(list,loc.size,size,loc.sreg,tmpreg);
            a_cmp_const_reg_label(list,size,cmp_op,a,tmpreg,l);
          end;
        LOC_SUBSETREF, LOC_CSUBSETREF:
          begin
            tmpreg:=getintregister(list,size);
            a_load_subsetref_reg(list,loc.size,size,loc.sref,tmpreg);
            a_cmp_const_reg_label(list,size,cmp_op,a,tmpreg,l);
          end;
        }
        else
          internalerror(2010120430);
      end;
    end;

  procedure thlcgobj.a_cmp_ref_reg_label(list: TAsmList; size: tdef; cmp_op: topcmp; const ref: treference; reg: tregister; l: tasmlabel);
    var
      tmpreg: tregister;
    begin
      tmpreg:=getintregister(list,size);
      a_load_ref_reg(list,size,size,ref,tmpreg);
      a_cmp_reg_reg_label(list,size,cmp_op,tmpreg,reg,l);
    end;

  procedure thlcgobj.a_cmp_reg_ref_label(list: TAsmList; size: tdef; cmp_op: topcmp; reg: tregister; const ref: treference; l: tasmlabel);
    var
      tmpreg: tregister;
    begin
      tmpreg:=getintregister(list,size);
      a_load_ref_reg(list,size,size,ref,tmpreg);
      a_cmp_reg_reg_label(list,size,cmp_op,reg,tmpreg,l);
    end;

  procedure thlcgobj.a_cmp_subsetreg_reg_label(list: TAsmList; fromsize, fromsubsetsize, cmpsize: tdef; cmp_op: topcmp; const sreg: tsubsetregister; reg: tregister; l: tasmlabel);
    var
      tmpreg: tregister;
    begin
      tmpreg:=getintregister(list,cmpsize);
      a_load_subsetreg_reg(list,fromsize,fromsubsetsize,cmpsize,sreg,tmpreg);
      a_cmp_reg_reg_label(list,cmpsize,cmp_op,tmpreg,reg,l);
    end;

  procedure thlcgobj.a_cmp_subsetref_reg_label(list: TAsmList; fromsize, fromsubsetsize, cmpsize: tdef; cmp_op: topcmp; const sref: tsubsetreference; reg: tregister; l: tasmlabel);
    var
      tmpreg: tregister;
    begin
      tmpreg:=getintregister(list,cmpsize);
      a_load_subsetref_reg(list,fromsize,fromsubsetsize,cmpsize,sref,tmpreg);
      a_cmp_reg_reg_label(list,cmpsize,cmp_op,tmpreg,reg,l);
    end;

  procedure thlcgobj.a_cmp_loc_reg_label(list: TAsmList; size: tdef; cmp_op: topcmp; const loc: tlocation; reg: tregister; l: tasmlabel);
    begin
      case loc.loc of
        LOC_REGISTER,
        LOC_CREGISTER:
          a_cmp_reg_reg_label(list,size,cmp_op,loc.register,reg,l);
        LOC_REFERENCE,
        LOC_CREFERENCE :
          a_cmp_ref_reg_label(list,size,cmp_op,loc.reference,reg,l);
        LOC_CONSTANT:
          a_cmp_const_reg_label(list,size,cmp_op,loc.value,reg,l);
        { we don't have enough type information to handle these here
        LOC_SUBSETREG,
        LOC_CSUBSETREG:
          a_cmp_subsetreg_reg_label(list,loc.size,size,cmp_op,loc.sreg,reg,l);
        LOC_SUBSETREF,
        LOC_CSUBSETREF:
          a_cmp_subsetref_reg_label(list,loc.size,size,cmp_op,loc.sref,reg,l);
        }
        else
          internalerror(2010120431);
      end;
    end;

  procedure thlcgobj.a_cmp_reg_loc_label(list: TAsmList; size: tdef; cmp_op: topcmp; reg: tregister; const loc: tlocation; l: tasmlabel);
    begin
      a_cmp_loc_reg_label(list,size,swap_opcmp(cmp_op),loc,reg,l);
    end;

  procedure thlcgobj.a_cmp_ref_loc_label(list: TAsmList; size: tdef; cmp_op: topcmp; const ref: treference; const loc: tlocation; l: tasmlabel);
    var
      tmpreg: tregister;
    begin
      case loc.loc of
        LOC_REGISTER,LOC_CREGISTER:
          a_cmp_ref_reg_label(list,size,cmp_op,ref,loc.register,l);
        LOC_REFERENCE,LOC_CREFERENCE:
          begin
            tmpreg:=getintregister(list,size);
            a_load_ref_reg(list,size,size,loc.reference,tmpreg);
            a_cmp_ref_reg_label(list,size,cmp_op,ref,tmpreg,l);
          end;
        LOC_CONSTANT:
          begin
            a_cmp_const_ref_label(list,size,swap_opcmp(cmp_op),loc.value,ref,l);
          end
        { we don't have enough type information to handle these here
        LOC_SUBSETREG, LOC_CSUBSETREG:
          begin
            tmpreg:=getintregister(list, size);
            a_load_ref_reg(list,size,size,loc.reference,tmpreg);
            a_cmp_subsetreg_reg_label(list,loc.size,size,swap_opcmp(cmp_op),loc.sreg,tmpreg,l);
          end;
        LOC_SUBSETREF, LOC_CSUBSETREF:
          begin
            tmpreg:=getintregister(list, size);
            a_load_ref_reg(list,size,size,loc.reference,tmpreg);
            a_cmp_subsetref_reg_label(list,loc.size,size,swap_opcmp(cmp_op),loc.sref,tmpreg,l);
          end;
        }
        else
          internalerror(2010120432);
      end;
    end;

  procedure thlcgobj.g_concatcopy(list: TAsmList; size: tdef; const source, dest: treference);
    begin
{
      if use_vectorfpu(size) then
        a_loadmm_ref_ref()
      else
 }
      if size.typ<>floatdef then
        a_load_ref_ref(list,size,size,source,dest)
      else
        a_loadfpu_ref_ref(list,size,size,source,dest);
    end;

  procedure thlcgobj.g_concatcopy_unaligned(list: TAsmList; size: tdef; const source, dest: treference);
    begin
      g_concatcopy(list,size,source,dest);
    end;

  procedure thlcgobj.g_rangecheck(list: TAsmList; const l: tlocation; fromdef, todef: tdef);
    begin
      if not(cs_check_range in current_settings.localswitches) then
        exit;
      internalerror(2011010610);
    end;

  procedure thlcgobj.g_profilecode(list: TAsmList);
    begin
    end;

  procedure thlcgobj.location_force_reg(list: TAsmList; var l: tlocation; src_size, dst_size: tdef; maybeconst: boolean);
    var
      hregister,
      hregister2: tregister;
      hl : tasmlabel;
      oldloc : tlocation;
    begin
      oldloc:=l;
      hregister:=getregisterfordef(list,dst_size);
      { load value in new register }
      case l.loc of
{$ifdef cpuflags}
        LOC_FLAGS :
          cg.g_flags2reg(list,def_cgsize(dst_size),l.resflags,hregister);
{$endif cpuflags}
        LOC_JUMP :
          begin
            a_label(list,current_procinfo.CurrTrueLabel);
            a_load_const_reg(list,dst_size,1,hregister);
            current_asmdata.getjumplabel(hl);
            a_jmp_always(list,hl);
            a_label(list,current_procinfo.CurrFalseLabel);
            a_load_const_reg(list,dst_size,0,hregister);
            a_label(list,hl);
          end;
        else
          begin
            { load_loc_reg can only handle size >= l.size, when the
              new size is smaller then we need to adjust the size
              of the orignal and maybe recalculate l.register for i386 }
            if (dst_size.size<src_size.size) then
              begin
                hregister2:=getregisterfordef(list,src_size);
                { prevent problems with memory locations -- at this high
                  level we cannot twiddle with the reference offset, since
                  that may not mean anything (e.g., it refers to fixed-sized
                  stack slots on Java) }
                a_load_loc_reg(list,src_size,src_size,l,hregister2);
                a_load_reg_reg(list,src_size,dst_size,hregister2,hregister);
              end
            else
              a_load_loc_reg(list,src_size,dst_size,l,hregister);
          end;
      end;
      if (l.loc <> LOC_CREGISTER) or
         not maybeconst then
        location_reset(l,LOC_REGISTER,def_cgsize(dst_size))
      else
        location_reset(l,LOC_CREGISTER,def_cgsize(dst_size));
      l.register:=hregister;
      { Release temp if it was a reference }
      if oldloc.loc=LOC_REFERENCE then
        location_freetemp(list,oldloc);
    end;

  procedure thlcgobj.location_force_fpureg(list: TAsmList; var l: tlocation; size: tdef; maybeconst: boolean);
    var
      reg : tregister;
    begin
      if (l.loc<>LOC_FPUREGISTER)  and
         ((l.loc<>LOC_CFPUREGISTER) or (not maybeconst)) then
        begin
          { if it's in an mm register, store to memory first }
          if (l.loc in [LOC_MMREGISTER,LOC_CMMREGISTER]) then
            internalerror(2011012903);
          reg:=getfpuregister(list,size);
          a_loadfpu_loc_reg(list,size,size,l,reg);
          location_freetemp(list,l);
          location_reset(l,LOC_FPUREGISTER,l.size);
          l.register:=reg;
        end;
    end;

  procedure thlcgobj.location_force_mem(list: TAsmList; var l: tlocation; size: tdef);
    var
      r : treference;
    begin
      case l.loc of
        LOC_FPUREGISTER,
        LOC_CFPUREGISTER :
          begin
            tg.gethltemp(list,size,size.size,tt_normal,r);
            hlcg.a_loadfpu_reg_ref(list,size,size,l.register,r);
            location_reset_ref(l,LOC_REFERENCE,l.size,0);
            l.reference:=r;
          end;
(*
        LOC_MMREGISTER,
        LOC_CMMREGISTER:
          begin
            tg.gethltemp(list,size,size.size,tt_normal,r);
            cg.a_loadmm_reg_ref(list,l.size,l.size,l.register,r,mms_movescalar);
            location_reset_ref(l,LOC_REFERENCE,l.size,0);
            l.reference:=r;
          end;
*)
        LOC_CONSTANT,
        LOC_REGISTER,
        LOC_CREGISTER :
          begin
            tg.gethltemp(list,size,size.size,tt_normal,r);
            hlcg.a_load_loc_ref(list,size,size,l,r);
            location_reset_ref(l,LOC_REFERENCE,l.size,0);
            l.reference:=r;
          end;
(*
        LOC_SUBSETREG,
        LOC_CSUBSETREG,
        LOC_SUBSETREF,
        LOC_CSUBSETREF:
          begin
            tg.gethltemp(list,size,size.size,tt_normal,r);
            cg.a_load_loc_ref(list,l.size,l,r);
            location_reset_ref(l,LOC_REFERENCE,l.size,0);
            l.reference:=r;
          end;
*)
        LOC_CREFERENCE,
        LOC_REFERENCE : ;
        else
          internalerror(2011010304);
      end;
    end;

    procedure thlcgobj.location_get_data_ref(list: TAsmList; def: tdef; const l: tlocation; var ref: treference; loadref: boolean; alignment: longint);
      begin
        case l.loc of
          LOC_REGISTER,
          LOC_CREGISTER :
            begin
              if not loadref then
                internalerror(200410231);
              reference_reset_base(ref,l.register,0,alignment);
            end;
          LOC_REFERENCE,
          LOC_CREFERENCE :
            begin
              if loadref then
                begin
                  reference_reset_base(ref,cg.getaddressregister(list),0,alignment);
                  { it's a pointer to def }
                  hlcg.a_load_ref_reg(list,voidpointertype,voidpointertype,l.reference,ref.base);
                end
              else
                ref:=l.reference;
            end;
          else
            internalerror(200309181);
        end;
      end;

  procedure thlcgobj.maketojumpbool(list: TAsmList; p: tnode);
  {
    produces jumps to true respectively false labels using boolean expressions

    depending on whether the loading of regvars is currently being
    synchronized manually (such as in an if-node) or automatically (most of
    the other cases where this procedure is called), loadregvars can be
    "lr_load_regvars" or "lr_dont_load_regvars"
  }
    var
      storepos : tfileposinfo;
    begin
       if nf_error in p.flags then
         exit;
       storepos:=current_filepos;
       current_filepos:=p.fileinfo;
       if is_boolean(p.resultdef) then
         begin
            if is_constboolnode(p) then
              begin
                 if Tordconstnode(p).value.uvalue<>0 then
                   a_jmp_always(list,current_procinfo.CurrTrueLabel)
                 else
                   a_jmp_always(list,current_procinfo.CurrFalseLabel)
              end
            else
              begin
                 case p.location.loc of
(*
                   LOC_SUBSETREG,LOC_CSUBSETREG,
                   LOC_SUBSETREF,LOC_CSUBSETREF:
                     begin
                       tmpreg := cg.getintregister(list,OS_INT);
                       cg.a_load_loc_reg(list,OS_INT,p.location,tmpreg);
                       cg.a_cmp_const_reg_label(list,OS_INT,OC_NE,0,tmpreg,current_procinfo.CurrTrueLabel);
                       cg.a_jmp_always(list,current_procinfo.CurrFalseLabel);
                     end;
*)
                   LOC_CREGISTER,LOC_REGISTER,LOC_CREFERENCE,LOC_REFERENCE :
                     begin
                       a_cmp_const_loc_label(list,p.resultdef,OC_NE,0,p.location,current_procinfo.CurrTrueLabel);
                       a_jmp_always(list,current_procinfo.CurrFalseLabel);
                     end;
                   LOC_JUMP:
                     ;
{$ifdef cpuflags}
                   LOC_FLAGS :
                     begin
                       a_jmp_flags(list,p.location.resflags,current_procinfo.CurrTrueLabel);
                       a_jmp_always(list,current_procinfo.CurrFalseLabel);
                     end;
{$endif cpuflags}
                   else
                     begin
                       printnode(output,p);
                       internalerror(2011010418);
                     end;
                 end;
              end;
         end
       else
         internalerror(2011010419);
       current_filepos:=storepos;
    end;

  procedure thlcgobj.gen_proc_symbol(list: TAsmList);
    var
      item,
      previtem : TCmdStrListItem;
    begin
      previtem:=nil;
      item := TCmdStrListItem(current_procinfo.procdef.aliasnames.first);
      while assigned(item) do
        begin
{$ifdef arm}
          if current_settings.cputype in cpu_thumb2 then
            list.concat(tai_thumb_func.create);
{$endif arm}
          { "double link" all procedure entry symbols via .reference }
          { directives on darwin, because otherwise the linker       }
          { sometimes strips the procedure if only on of the symbols }
          { is referenced                                            }
          if assigned(previtem) and
             (target_info.system in systems_darwin) then
            list.concat(tai_directive.create(asd_reference,item.str));
          if (cs_profile in current_settings.moduleswitches) or
            (po_global in current_procinfo.procdef.procoptions) then
            list.concat(Tai_symbol.createname_global(item.str,AT_FUNCTION,0))
          else
            list.concat(Tai_symbol.createname(item.str,AT_FUNCTION,0));
          if assigned(previtem) and
             (target_info.system in systems_darwin) then
            list.concat(tai_directive.create(asd_reference,previtem.str));
          if not(af_stabs_use_function_absolute_addresses in target_asm.flags) then
            list.concat(Tai_function_name.create(item.str));
          previtem:=item;
          item := TCmdStrListItem(item.next);
        end;
      current_procinfo.procdef.procstarttai:=tai(list.last);
    end;

  procedure thlcgobj.gen_proc_symbol_end(list: TAsmList);
    begin
      list.concat(Tai_symbol_end.Createname(current_procinfo.procdef.mangledname));

      current_procinfo.procdef.procendtai:=tai(list.last);

      if (current_module.islibrary) then
        if (current_procinfo.procdef.proctypeoption = potype_proginit) then
          { setinitname may generate a new section -> don't add to the
            current list, because we assume this remains a text section }
          exportlib.setinitname(current_asmdata.AsmLists[al_exports],current_procinfo.procdef.mangledname);

      if (current_procinfo.procdef.proctypeoption=potype_proginit) then
        begin
         if (target_info.system in (systems_darwin+[system_powerpc_macos])) and
            not(current_module.islibrary) then
           begin
            new_section(list,sec_code,'',4);
            list.concat(tai_symbol.createname_global(
              target_info.cprefix+mainaliasname,AT_FUNCTION,0));
            { keep argc, argv and envp properly on the stack }
            cg.a_jmp_name(list,target_info.cprefix+'FPC_SYSTEMMAIN');
           end;
        end;
    end;

{ generates the code for incrementing the reference count of parameters and
  initialize out parameters }
  { generates the code for incrementing the reference count of parameters and
    initialize out parameters }
  procedure thlcgobj.init_paras(p:TObject;arg:pointer);
    var
      href : treference;
      hsym : tparavarsym;
      eldef : tdef;
      list : TAsmList;
      highloc : tlocation;
      needs_inittable (*,
      do_trashing     *)  : boolean;
    begin
      list:=TAsmList(arg);
      if (tsym(p).typ=paravarsym) then
       begin
         needs_inittable:=is_managed_type(tparavarsym(p).vardef);
(*
         do_trashing:=
           (localvartrashing <> -1) and
           (not assigned(tparavarsym(p).defaultconstsym)) and
           not needs_inittable;
*)
         case tparavarsym(p).varspez of
           vs_value :
             if needs_inittable then
               begin
                 { variants are already handled by the call to fpc_variant_copy_overwrite if
                   they are passed by reference }
                 if not((tparavarsym(p).vardef.typ=variantdef) and
                   paramanager.push_addr_param(tparavarsym(p).varspez,tparavarsym(p).vardef,current_procinfo.procdef.proccalloption)) then
                   begin
                     location_get_data_ref(list,tparavarsym(p).vardef,tparavarsym(p).initialloc,href,is_open_array(tparavarsym(p).vardef),sizeof(pint));
                     if is_open_array(tparavarsym(p).vardef) then
                       begin
                         if paramanager.push_high_param(tparavarsym(p).varspez,tparavarsym(p).vardef,current_procinfo.procdef.proccalloption) then
                           begin
                             hsym:=tparavarsym(tsym(p).owner.Find('high'+tsym(p).name));
                             if not assigned(hsym) then
                               internalerror(201003032);
                             highloc:=hsym.initialloc
                           end
                         else
                           highloc.loc:=LOC_INVALID;
                         { open arrays do not contain correct element count in their rtti,
                           the actual count must be passed separately. }
                         eldef:=tarraydef(tparavarsym(p).vardef).elementdef;
                         if not assigned(hsym) then
                           internalerror(201003031);
                         g_array_rtti_helper(list,eldef,href,highloc,'FPC_ADDREF_ARRAY');
                       end
                     else
                      g_incrrefcount(list,tparavarsym(p).vardef,href);
                   end;
               end;
           vs_out :
             begin
               if needs_inittable (*or
                  do_trashing*) then
                 begin
                   { we have no idea about the alignment at the callee side,
                     and the user also cannot specify "unaligned" here, so
                     assume worst case }
                   location_get_data_ref(list,tparavarsym(p).vardef,tparavarsym(p).initialloc,href,true,1);
(*
                   if do_trashing and
                      { needs separate implementation to trash open arrays }
                      { since their size is only known at run time         }
                      not is_special_array(tparavarsym(p).vardef) then
                      { may be an open string, even if is_open_string() returns }
                      { false (for some helpers in the system unit)             }
                     if not is_shortstring(tparavarsym(p).vardef) then
                       trash_reference(list,href,tparavarsym(p).vardef.size)
                     else
                       trash_reference(list,href,2);
*)
                   if needs_inittable then
                     begin
                       if is_open_array(tparavarsym(p).vardef) then
                         begin
                           if paramanager.push_high_param(tparavarsym(p).varspez,tparavarsym(p).vardef,current_procinfo.procdef.proccalloption) then
                             begin
                               hsym:=tparavarsym(tsym(p).owner.Find('high'+tsym(p).name));
                               if not assigned(hsym) then
                                 internalerror(201003032);
                               highloc:=hsym.initialloc
                             end
                           else
                             highloc.loc:=LOC_INVALID;
                           eldef:=tarraydef(tparavarsym(p).vardef).elementdef;
                           g_array_rtti_helper(list,eldef,href,highloc,'FPC_INITIALIZE_ARRAY');
                         end
                       else
                         g_initialize(list,tparavarsym(p).vardef,href);
                     end;
                 end;
             end;
(*
           else if do_trashing and
                   ([vo_is_funcret,vo_is_hidden_para] * tparavarsym(p).varoptions = [vo_is_funcret,vo_is_hidden_para]) then
                 begin
                   { should always have standard alignment. If a function is assigned
                     to a non-aligned variable, the optimisation to pass this variable
                     directly as hidden function result must/cannot be performed
                     (see tcallnode.funcret_can_be_reused)
                   }
                   location_get_data_ref(list,tparavarsym(p).vardef,tparavarsym(p).initialloc,href,true,
                     used_align(tparavarsym(p).vardef.alignment,current_settings.alignment.localalignmin,current_settings.alignment.localalignmax));
                   { may be an open string, even if is_open_string() returns }
                   { false (for some helpers in the system unit)             }
                   if not is_shortstring(tparavarsym(p).vardef) then
                     trash_reference(list,href,tparavarsym(p).vardef.size)
                   else
                     { an open string has at least size 2 }
                     trash_reference(list,href,2);
                 end
*)
         end;
       end;
    end;

  procedure thlcgobj.gen_load_para_value(list: TAsmList);
    var
      i: longint;
      currpara: tparavarsym;
    begin
      if (po_assembler in current_procinfo.procdef.procoptions) then
        exit;

      { Copy parameters to local references/registers }
      for i:=0 to current_procinfo.procdef.paras.count-1 do
        begin
          currpara:=tparavarsym(current_procinfo.procdef.paras[i]);
          gen_load_cgpara_loc(list,currpara.vardef,currpara.paraloc[calleeside],currpara.initialloc,paramanager.param_use_paraloc(currpara.paraloc[calleeside]));
        end;

      { generate copies of call by value parameters, must be done before
        the initialization and body is parsed because the refcounts are
        incremented using the local copies }
      current_procinfo.procdef.parast.SymList.ForEachCall(@g_copyvalueparas,list);

      if not(po_assembler in current_procinfo.procdef.procoptions) then
        begin
          { has to be done here rather than in gen_initialize_code, because
            the initialisation code is generated a) later and b) with
            rad_backwards, so the register allocator would generate
            information as if this code comes before loading the parameters
            from their original registers to their local location }
//          if (localvartrashing <> -1) then
//            current_procinfo.procdef.localst.SymList.ForEachCall(@trash_variable,list);
          { initialize refcounted paras, and trash others. Needed here
            instead of in gen_initialize_code, because when a reference is
            intialised or trashed while the pointer to that reference is kept
            in a regvar, we add a register move and that one again has to
            come after the parameter loading code as far as the register
            allocator is concerned }
          current_procinfo.procdef.parast.SymList.ForEachCall(@init_paras,list);
        end;
    end;

  procedure thlcgobj.g_copyvalueparas(p: TObject; arg: pointer);
    var
      href : treference;
      hreg : tregister;
      list : TAsmList;
      hsym : tparavarsym;
      l    : longint;
      highloc,
      localcopyloc : tlocation;
    begin
      list:=TAsmList(arg);
      if (tsym(p).typ=paravarsym) and
         (tparavarsym(p).varspez=vs_value) and
        (paramanager.push_addr_param(tparavarsym(p).varspez,tparavarsym(p).vardef,current_procinfo.procdef.proccalloption)) then
        begin
          { we have no idea about the alignment at the caller side }
          location_get_data_ref(list,tparavarsym(p).vardef,tparavarsym(p).initialloc,href,true,1);
          if is_open_array(tparavarsym(p).vardef) or
             is_array_of_const(tparavarsym(p).vardef) then
            begin
              { cdecl functions don't have a high pointer so it is not possible to generate
                a local copy }
              if not(current_procinfo.procdef.proccalloption in cdecl_pocalls) then
                begin
                  if paramanager.push_high_param(tparavarsym(p).varspez,tparavarsym(p).vardef,current_procinfo.procdef.proccalloption) then
                    begin
                      hsym:=tparavarsym(tsym(p).owner.Find('high'+tsym(p).name));
                      if not assigned(hsym) then
                        internalerror(2011020506);
                      highloc:=hsym.initialloc
                    end
                  else
                    highloc.loc:=LOC_INVALID;
                  hreg:=cg.getaddressregister(list);
                  if not is_packed_array(tparavarsym(p).vardef) then
                    g_copyvaluepara_openarray(list,href,highloc,tarraydef(tparavarsym(p).vardef),hreg)
                  else
                    internalerror(2011020507);
//                      cg.g_copyvaluepara_packedopenarray(list,href,hsym.intialloc,tarraydef(tparavarsym(p).vardef).elepackedbitsize,hreg);
                  a_load_reg_loc(list,tparavarsym(p).vardef,tparavarsym(p).vardef,hreg,tparavarsym(p).initialloc);
                end;
            end
          else
            begin
              { Allocate space for the local copy }
              l:=tparavarsym(p).getsize;
              localcopyloc.loc:=LOC_REFERENCE;
              localcopyloc.size:=int_cgsize(l);
              tg.GetLocal(list,l,tparavarsym(p).vardef,localcopyloc.reference);
              { Copy data }
              if is_shortstring(tparavarsym(p).vardef) then
                begin
                  { this code is only executed before the code for the body and the entry/exit code is generated
                    so we're allowed to include pi_do_call here; after pass1 is run, this isn't allowed anymore
                  }
                  include(current_procinfo.flags,pi_do_call);
                  g_copyshortstring(list,href,localcopyloc.reference,tstringdef(tparavarsym(p).vardef))
                end
              else if tparavarsym(p).vardef.typ=variantdef then
                begin
                  { this code is only executed before the code for the body and the entry/exit code is generated
                    so we're allowed to include pi_do_call here; after pass1 is run, this isn't allowed anymore
                  }
                  include(current_procinfo.flags,pi_do_call);
                  g_copyvariant(list,href,localcopyloc.reference,tvariantdef(tparavarsym(p).vardef))
                end
              else
                begin
                  { pass proper alignment info }
                  localcopyloc.reference.alignment:=tparavarsym(p).vardef.alignment;
                  g_concatcopy(list,tparavarsym(p).vardef,href,localcopyloc.reference);
                end;
              { update localloc of varsym }
              tg.Ungetlocal(list,tparavarsym(p).localloc.reference);
              tparavarsym(p).localloc:=localcopyloc;
              tparavarsym(p).initialloc:=localcopyloc;
            end;
        end;
    end;

  procedure thlcgobj.gen_loadfpu_loc_cgpara(list: TAsmList; size: tdef; const l: tlocation; const cgpara: tcgpara; locintsize: longint);
    begin
      case l.loc of
(*
        LOC_MMREGISTER,
        LOC_CMMREGISTER:
          case cgpara.location^.loc of
            LOC_REFERENCE,
            LOC_CREFERENCE,
            LOC_MMREGISTER,
            LOC_CMMREGISTER,
            LOC_REGISTER,
            LOC_CREGISTER :
              cg.a_loadmm_reg_cgpara(list,locsize,l.register,cgpara,mms_movescalar);
            LOC_FPUREGISTER,
            LOC_CFPUREGISTER:
              begin
                tmploc:=l;
                location_force_fpureg(list,tmploc,false);
                cg.a_loadfpu_reg_cgpara(list,tmploc.size,tmploc.register,cgpara);
              end;
            else
              internalerror(200204249);
          end;
*)
        LOC_FPUREGISTER,
        LOC_CFPUREGISTER:
          case cgpara.location^.loc of
(*
            LOC_MMREGISTER,
            LOC_CMMREGISTER:
              begin
                tmploc:=l;
                location_force_mmregscalar(list,tmploc,false);
                cg.a_loadmm_reg_cgpara(list,tmploc.size,tmploc.register,cgpara,mms_movescalar);
              end;
*)
            { Some targets pass floats in normal registers }
            LOC_REGISTER,
            LOC_CREGISTER,
            LOC_REFERENCE,
            LOC_CREFERENCE,
            LOC_FPUREGISTER,
            LOC_CFPUREGISTER:
              hlcg.a_loadfpu_reg_cgpara(list,size,l.register,cgpara);
            else
              internalerror(2011010210);
          end;
        LOC_REFERENCE,
        LOC_CREFERENCE:
          case cgpara.location^.loc of
(*
            LOC_MMREGISTER,
            LOC_CMMREGISTER:
              cg.a_loadmm_ref_cgpara(list,locsize,l.reference,cgpara,mms_movescalar);
*)
            { Some targets pass floats in normal registers }
            LOC_REGISTER,
            LOC_CREGISTER,
            LOC_REFERENCE,
            LOC_CREFERENCE,
            LOC_FPUREGISTER,
            LOC_CFPUREGISTER:
              hlcg.a_loadfpu_ref_cgpara(list,size,l.reference,cgpara);
            else
              internalerror(2011010211);
          end;
        LOC_REGISTER,
        LOC_CREGISTER :
          hlcg.a_load_loc_cgpara(list,size,l,cgpara);
         else
           internalerror(2011010212);
      end;
    end;

  procedure thlcgobj.gen_load_uninitialized_function_result(list: TAsmList; pd: tprocdef; resdef: tdef; const resloc: tcgpara);
    begin
      { do nothing by default }
    end;

  procedure thlcgobj.gen_load_loc_cgpara(list: TAsmList; vardef: tdef; const l: tlocation; const cgpara: tcgpara);
    begin
      { Handle Floating point types differently

        This doesn't depend on emulator settings, emulator settings should
        be handled by cpupara }
      if (vardef.typ=floatdef) or
         { some ABIs return certain records in an fpu register }
         (l.loc in [LOC_FPUREGISTER,LOC_CFPUREGISTER]) or
         (assigned(cgpara.location) and
          (cgpara.Location^.loc in [LOC_FPUREGISTER,LOC_CFPUREGISTER])) then
        begin
          gen_loadfpu_loc_cgpara(list,vardef,l,cgpara,vardef.size);
          exit;
        end;

      case l.loc of
        LOC_CONSTANT,
        LOC_REGISTER,
        LOC_CREGISTER,
        LOC_REFERENCE,
        LOC_CREFERENCE :
          begin
            hlcg.a_load_loc_cgpara(list,vardef,l,cgpara);
          end;
(*
        LOC_MMREGISTER,
        LOC_CMMREGISTER:
          begin
            case l.size of
              OS_F32,
              OS_F64:
                cg.a_loadmm_loc_cgpara(list,l,cgpara,mms_movescalar);
              else
                cg.a_loadmm_loc_cgpara(list,l,cgpara,nil);
            end;
          end;
*)
        else
          internalerror(2011010213);
      end;
    end;

  procedure thlcgobj.gen_load_cgpara_loc(list: TAsmList; vardef: tdef; const para: TCGPara; var destloc: tlocation; reusepara: boolean);
    var
      href     : treference;
    begin
      para.check_simple_location;
      { skip e.g. empty records }
      if (para.location^.loc = LOC_VOID) then
        exit;
      case destloc.loc of
        LOC_REFERENCE :
          begin
            { If the parameter location is reused we don't need to copy
              anything }
            if not reusepara then
              begin
                reference_reset_base(href,para.location^.reference.index,para.location^.reference.offset,para.alignment);
                a_load_ref_ref(list,para.def,para.def,href,destloc.reference);
              end;
          end;
        { TODO other possible locations }
        else
          internalerror(2011010308);
      end;
    end;

  procedure thlcgobj.gen_load_return_value(list: TAsmList);
    var
      ressym : tabstractnormalvarsym;
      funcretloc : TCGPara;
    begin
      { Is the loading needed? }
      if is_void(current_procinfo.procdef.returndef) or
         (
          (po_assembler in current_procinfo.procdef.procoptions) and
          (not(assigned(current_procinfo.procdef.funcretsym)) or
           (tabstractvarsym(current_procinfo.procdef.funcretsym).refs=0))
         ) then
         exit;

      funcretloc:=current_procinfo.procdef.funcretloc[calleeside];

      { constructors return self }
      if (current_procinfo.procdef.proctypeoption=potype_constructor) then
        ressym:=tabstractnormalvarsym(current_procinfo.procdef.parast.Find('self'))
      else
        ressym:=tabstractnormalvarsym(current_procinfo.procdef.funcretsym);
      if (ressym.refs>0) or
         is_managed_type(ressym.vardef) then
        begin
          { was: don't do anything if funcretloc.loc in [LOC_INVALID,LOC_REFERENCE] }
          if not paramanager.ret_in_param(current_procinfo.procdef.returndef,current_procinfo.procdef.proccalloption) then
            hlcg.gen_load_loc_cgpara(list,ressym.vardef,ressym.localloc,funcretloc);
        end
      else
        gen_load_uninitialized_function_result(list,current_procinfo.procdef,ressym.vardef,funcretloc)
    end;

  procedure thlcgobj.record_generated_code_for_procdef(pd: tprocdef; code, data: TAsmList);
    begin
      { add the procedure to the al_procedures }
      maybe_new_object_file(current_asmdata.asmlists[al_procedures]);
      new_section(current_asmdata.asmlists[al_procedures],sec_code,lower(pd.mangledname),getprocalign);
      current_asmdata.asmlists[al_procedures].concatlist(code);
      { save local data (casetable) also in the same file }
      if assigned(data) and
         (not data.empty) then
        current_asmdata.asmlists[al_procedures].concatlist(data);
    end;

end.
