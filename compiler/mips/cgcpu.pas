{
    Copyright (c) 1998-2012 by Florian Klaempfl and David Zhang

    This unit implements the code generator for MIPS

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
  globtype, parabase,
  cgbase, cgutils, cgobj, cg64f32, cpupara,
  aasmbase, aasmtai, aasmcpu, aasmdata,
  cpubase, cpuinfo,
  node, symconst, SymType, symdef,
  rgcpu;

type
  TCGMIPS = class(tcg)
  public

    procedure init_register_allocators; override;
    procedure done_register_allocators; override;
///    { needed by cg64 }
    procedure make_simple_ref(list: tasmlist; var ref: treference);
    procedure handle_reg_const_reg(list: tasmlist; op: Tasmop; src: tregister; a: tcgint; dst: tregister);
    procedure maybeadjustresult(list: TAsmList; op: TOpCg; size: tcgsize; dst: tregister);
    procedure overflowcheck_internal(list: TAsmList; arg1, arg2: TRegister);

    { parameter }
    procedure a_loadfpu_reg_cgpara(list: tasmlist; size: tcgsize; const r: tregister; const paraloc: TCGPara); override;
    procedure a_loadfpu_ref_cgpara(list: tasmlist; size: tcgsize; const ref: treference; const paraloc: TCGPara); override;
    procedure a_call_name(list: tasmlist; const s: string; weak : boolean); override;
    procedure a_call_reg(list: tasmlist; Reg: TRegister); override;
    procedure a_call_sym_pic(list: tasmlist; sym: tasmsymbol);
    { General purpose instructions }
    procedure a_op_const_reg(list: tasmlist; Op: TOpCG; size: tcgsize; a: tcgint; reg: TRegister); override;
    procedure a_op_reg_reg(list: tasmlist; Op: TOpCG; size: TCGSize; src, dst: TRegister); override;
    procedure a_op_const_reg_reg(list: tasmlist; op: TOpCg; size: tcgsize; a: tcgint; src, dst: tregister); override;
    procedure a_op_reg_reg_reg(list: tasmlist; op: TOpCg; size: tcgsize; src1, src2, dst: tregister); override;
    procedure a_op_const_reg_reg_checkoverflow(list: tasmlist; op: TOpCg; size: tcgsize; a: tcgint; src, dst: tregister; setflags: boolean; var ovloc: tlocation); override;
    procedure a_op_reg_reg_reg_checkoverflow(list: tasmlist; op: TOpCg; size: tcgsize; src1, src2, dst: tregister; setflags: boolean; var ovloc: tlocation); override;
    { move instructions }
    procedure a_load_const_reg(list: tasmlist; size: tcgsize; a: tcgint; reg: tregister); override;
    procedure a_load_const_ref(list: tasmlist; size: tcgsize; a: tcgint; const ref: TReference); override;
    procedure a_load_reg_ref(list: tasmlist; FromSize, ToSize: TCgSize; reg: TRegister; const ref: TReference); override;
    procedure a_load_ref_reg(list: tasmlist; FromSize, ToSize: TCgSize; const ref: TReference; reg: tregister); override;
    procedure a_load_reg_reg(list: tasmlist; FromSize, ToSize: TCgSize; reg1, reg2: tregister); override;
    procedure a_loadaddr_ref_reg(list: tasmlist; const ref: TReference; r: tregister); override;
    { fpu move instructions }
    procedure a_loadfpu_reg_reg(list: tasmlist; fromsize, tosize: tcgsize; reg1, reg2: tregister); override;
    procedure a_loadfpu_ref_reg(list: tasmlist; fromsize, tosize: tcgsize; const ref: TReference; reg: tregister); override;
    procedure a_loadfpu_reg_ref(list: tasmlist; fromsize, tosize: tcgsize; reg: tregister; const ref: TReference); override;
    { comparison operations }
    procedure a_cmp_const_reg_label(list: tasmlist; size: tcgsize; cmp_op: topcmp; a: tcgint; reg: tregister; l: tasmlabel); override;
    procedure a_cmp_reg_reg_label(list: tasmlist; size: tcgsize; cmp_op: topcmp; reg1, reg2: tregister; l: tasmlabel); override;
    procedure a_jmp_always(List: tasmlist; l: TAsmLabel); override;
    procedure a_jmp_name(list: tasmlist; const s: string); override;
    procedure g_overflowCheck(List: tasmlist; const Loc: TLocation; def: TDef); override;
    procedure g_overflowCheck_loc(List: tasmlist; const Loc: TLocation; def: TDef; ovloc: tlocation); override;
    procedure g_proc_entry(list: tasmlist; localsize: longint; nostackframe: boolean); override;
    procedure g_proc_exit(list: tasmlist; parasize: longint; nostackframe: boolean); override;
    procedure g_concatcopy(list: tasmlist; const Source, dest: treference; len: tcgint); override;
    procedure g_concatcopy_unaligned(list: tasmlist; const Source, dest: treference; len: tcgint); override;
    procedure g_concatcopy_move(list: tasmlist; const Source, dest: treference; len: tcgint);
    procedure g_adjust_self_value(list:TAsmList;procdef: tprocdef;ioffset: tcgint); override;
    procedure g_intf_wrapper(list: tasmlist; procdef: tprocdef; const labelname: string; ioffset: longint); override;
    procedure g_external_wrapper(list : TAsmList; procdef: tprocdef; const externalname: string);override;
    procedure g_profilecode(list: TAsmList);override;
    { Transform unsupported methods into Internal errors }
    procedure a_bit_scan_reg_reg(list: TAsmList; reverse: boolean; size: TCGSize; src, dst: TRegister); override;
    procedure g_stackpointer_alloc(list : TAsmList;localsize : longint);override;
  end;

  TCg64MPSel = class(tcg64f32)
  public
    procedure a_load64_reg_ref(list: tasmlist; reg: tregister64; const ref: treference); override;
    procedure a_load64_ref_reg(list: tasmlist; const ref: treference; reg: tregister64); override;
    procedure a_load64_ref_cgpara(list: tasmlist; const r: treference; const paraloc: tcgpara); override;
    procedure a_op64_reg_reg(list: tasmlist; op: TOpCG; size: tcgsize; regsrc, regdst: TRegister64); override;
    procedure a_op64_const_reg(list: tasmlist; op: TOpCG; size: tcgsize; Value: int64; regdst: TRegister64); override;
    procedure a_op64_const_reg_reg(list: tasmlist; op: TOpCG; size: tcgsize; Value: int64; regsrc, regdst: tregister64); override;
    procedure a_op64_reg_reg_reg(list: tasmlist; op: TOpCG; size: tcgsize; regsrc1, regsrc2, regdst: tregister64); override;
    procedure a_op64_const_reg_reg_checkoverflow(list: tasmlist; op: TOpCG; size: tcgsize; Value: int64; regsrc, regdst: tregister64; setflags: boolean; var ovloc: tlocation); override;
    procedure a_op64_reg_reg_reg_checkoverflow(list: tasmlist; op: TOpCG; size: tcgsize; regsrc1, regsrc2, regdst: tregister64; setflags: boolean; var ovloc: tlocation); override;
  end;

  procedure create_codegen;

  const
      TOpCmp2AsmCond : array[topcmp] of TAsmCond=(C_NONE,
        C_EQ,C_GT,C_LT,C_GE,C_LE,C_NE,C_LEU,C_LTU,C_GEU,C_GTU
      );

implementation

uses
  globals, verbose, systems, cutils,
  paramgr, fmodule,
  symtable, symsym,
  tgobj,
  procinfo, cpupi;


  function f_TOpCG2AsmOp(op: TOpCG; size: tcgsize): TAsmOp;
  begin
    if size = OS_32 then
      case op of
        OP_ADD:       { simple addition          }
          f_TOpCG2AsmOp := A_ADDU;
        OP_AND:       { simple logical and       }
          f_TOpCG2AsmOp := A_AND;
        OP_DIV:       { simple unsigned division }
          f_TOpCG2AsmOp := A_DIVU;
        OP_IDIV:      { simple signed division   }
          f_TOpCG2AsmOp := A_DIV;
        OP_IMUL:      { simple signed multiply   }
          f_TOpCG2AsmOp := A_MULT;
        OP_MUL:       { simple unsigned multiply }
          f_TOpCG2AsmOp := A_MULTU;
        OP_NEG:       { simple negate            }
          f_TOpCG2AsmOp := A_NEGU;
        OP_NOT:       { simple logical not       }
          f_TOpCG2AsmOp := A_NOT;
        OP_OR:        { simple logical or        }
          f_TOpCG2AsmOp := A_OR;
        OP_SAR:       { arithmetic shift-right   }
          f_TOpCG2AsmOp := A_SRA;
        OP_SHL:       { logical shift left       }
          f_TOpCG2AsmOp := A_SLL;
        OP_SHR:       { logical shift right      }
          f_TOpCG2AsmOp := A_SRL;
        OP_SUB:       { simple subtraction       }
          f_TOpCG2AsmOp := A_SUBU;
        OP_XOR:       { simple exclusive or      }
          f_TOpCG2AsmOp := A_XOR;
        else
          InternalError(2007070401);
      end{ case }
    else
      case op of
        OP_ADD:       { simple addition          }
          f_TOpCG2AsmOp := A_ADDU;
        OP_AND:       { simple logical and       }
          f_TOpCG2AsmOp := A_AND;
        OP_DIV:       { simple unsigned division }
          f_TOpCG2AsmOp := A_DIVU;
        OP_IDIV:      { simple signed division   }
          f_TOpCG2AsmOp := A_DIV;
        OP_IMUL:      { simple signed multiply   }
          f_TOpCG2AsmOp := A_MULT;
        OP_MUL:       { simple unsigned multiply }
          f_TOpCG2AsmOp := A_MULTU;
        OP_NEG:       { simple negate            }
          f_TOpCG2AsmOp := A_NEGU;
        OP_NOT:       { simple logical not       }
          f_TOpCG2AsmOp := A_NOT;
        OP_OR:        { simple logical or        }
          f_TOpCG2AsmOp := A_OR;
        OP_SAR:       { arithmetic shift-right   }
          f_TOpCG2AsmOp := A_SRA;
        OP_SHL:       { logical shift left       }
          f_TOpCG2AsmOp := A_SLL;
        OP_SHR:       { logical shift right      }
          f_TOpCG2AsmOp := A_SRL;
        OP_SUB:       { simple subtraction       }
          f_TOpCG2AsmOp := A_SUBU;
        OP_XOR:       { simple exclusive or      }
          f_TOpCG2AsmOp := A_XOR;
        else
          InternalError(2007010701);
      end;{ case }
  end;

  function f_TOpCG2AsmOp_ovf(op: TOpCG; size: tcgsize): TAsmOp;
  begin
    if size = OS_32 then
      case op of
        OP_ADD:       { simple addition          }
          f_TOpCG2AsmOp_ovf := A_ADD;
        OP_AND:       { simple logical and       }
          f_TOpCG2AsmOp_ovf := A_AND;
        OP_DIV:       { simple unsigned division }
          f_TOpCG2AsmOp_ovf := A_DIVU;
        OP_IDIV:      { simple signed division   }
          f_TOpCG2AsmOp_ovf := A_DIV;
        OP_IMUL:      { simple signed multiply   }
          f_TOpCG2AsmOp_ovf := A_MULO;
        OP_MUL:       { simple unsigned multiply }
          f_TOpCG2AsmOp_ovf := A_MULOU;
        OP_NEG:       { simple negate            }
          f_TOpCG2AsmOp_ovf := A_NEG;
        OP_NOT:       { simple logical not       }
          f_TOpCG2AsmOp_ovf := A_NOT;
        OP_OR:        { simple logical or        }
          f_TOpCG2AsmOp_ovf := A_OR;
        OP_SAR:       { arithmetic shift-right   }
          f_TOpCG2AsmOp_ovf := A_SRA;
        OP_SHL:       { logical shift left       }
          f_TOpCG2AsmOp_ovf := A_SLL;
        OP_SHR:       { logical shift right      }
          f_TOpCG2AsmOp_ovf := A_SRL;
        OP_SUB:       { simple subtraction       }
          f_TOpCG2AsmOp_ovf := A_SUB;
        OP_XOR:       { simple exclusive or      }
          f_TOpCG2AsmOp_ovf := A_XOR;
        else
          InternalError(2007070403);
      end{ case }
    else
      case op of
        OP_ADD:       { simple addition          }
          f_TOpCG2AsmOp_ovf := A_ADD;
        OP_AND:       { simple logical and       }
          f_TOpCG2AsmOp_ovf := A_AND;
        OP_DIV:       { simple unsigned division }
          f_TOpCG2AsmOp_ovf := A_DIVU;
        OP_IDIV:      { simple signed division   }
          f_TOpCG2AsmOp_ovf := A_DIV;
        OP_IMUL:      { simple signed multiply   }
          f_TOpCG2AsmOp_ovf := A_MULO;
        OP_MUL:       { simple unsigned multiply }
          f_TOpCG2AsmOp_ovf := A_MULOU;
        OP_NEG:       { simple negate            }
          f_TOpCG2AsmOp_ovf := A_NEG;
        OP_NOT:       { simple logical not       }
          f_TOpCG2AsmOp_ovf := A_NOT;
        OP_OR:        { simple logical or        }
          f_TOpCG2AsmOp_ovf := A_OR;
        OP_SAR:       { arithmetic shift-right   }
          f_TOpCG2AsmOp_ovf := A_SRA;
        OP_SHL:       { logical shift left       }
          f_TOpCG2AsmOp_ovf := A_SLL;
        OP_SHR:       { logical shift right      }
          f_TOpCG2AsmOp_ovf := A_SRL;
        OP_SUB:       { simple subtraction       }
          f_TOpCG2AsmOp_ovf := A_SUB;
        OP_XOR:       { simple exclusive or      }
          f_TOpCG2AsmOp_ovf := A_XOR;
        else
          InternalError(2007010703);
      end;{ case }
  end;


procedure TCGMIPS.make_simple_ref(list: tasmlist; var ref: treference);
var
  tmpreg, tmpreg1: tregister;
  tmpref: treference;
  base_replaced: boolean;
begin
  { Enforce some discipline for callers:
    - gp is always implicit
    - reference is processed only once }
  if (ref.base=NR_GP) or (ref.index=NR_GP) then
    InternalError(2013022801);
  if (ref.refaddr<>addr_no) then
    InternalError(2013022802);

  { fixup base/index, if both are present then add them together }
  base_replaced:=false;
  tmpreg:=ref.base;
  if (tmpreg=NR_NO) then
    tmpreg:=ref.index
  else if (ref.index<>NR_NO) then
    begin
      tmpreg:=getintregister(list,OS_ADDR);
      list.concat(taicpu.op_reg_reg_reg(A_ADDU,tmpreg,ref.base,ref.index));
      base_replaced:=true;
    end;
  ref.base:=tmpreg;
  ref.index:=NR_NO;

  if (ref.symbol=nil) and
     (ref.offset>=simm16lo) and
     (ref.offset<=simm16hi-sizeof(pint)) then
    exit;

  { Symbol present or offset > 16bits }
  if assigned(ref.symbol) then
    begin
      ref.base:=getintregister(list,OS_ADDR);
      reference_reset_symbol(tmpref,ref.symbol,ref.offset,ref.alignment);
      if (cs_create_pic in current_settings.moduleswitches) then
        begin
          { For PIC global symbols offset must be handled separately.
            Otherwise (non-PIC or local symbols) offset can be encoded
            into relocation even if exceeds 16 bits. }
          if (ref.symbol.bind<>AB_LOCAL) then
            tmpref.offset:=0;
          tmpref.refaddr:=addr_pic;
          tmpref.base:=NR_GP;
          list.concat(taicpu.op_reg_ref(A_LW,ref.base,tmpref));
        end
      else
        begin
          tmpref.refaddr:=addr_high;
          list.concat(taicpu.op_reg_ref(A_LUI,ref.base,tmpref));
        end;

      { Add original base/index, if any. }
      if (tmpreg<>NR_NO) then
        list.concat(taicpu.op_reg_reg_reg(A_ADDU,ref.base,tmpreg,ref.base));

      if (ref.symbol.bind=AB_LOCAL) or
         not (cs_create_pic in current_settings.moduleswitches) then
        begin
          ref.refaddr:=addr_low;
          exit;
        end;

      { PIC global symbol }
      ref.symbol:=nil;
      if (ref.offset=0) then
        exit;

      if (ref.offset>=simm16lo) and
        (ref.offset<=simm16hi-sizeof(pint)) then
        begin
          list.concat(taicpu.op_reg_reg_const(A_ADDIU,ref.base,ref.base,ref.offset));
          ref.offset:=0;
          exit;
        end;
      { fallthrough to the case of large offset }
    end;

  tmpreg1:=getintregister(list,OS_INT);
  a_load_const_reg(list,OS_INT,ref.offset,tmpreg1);
  if (ref.base=NR_NO) then
    ref.base:=tmpreg1   { offset alone, weird but possible }
  else
    begin
      if (not base_replaced) then
        ref.base:=getintregister(list,OS_ADDR);
      list.concat(taicpu.op_reg_reg_reg(A_ADDU,ref.base,tmpreg,tmpreg1))
    end;
  ref.offset:=0;
end;


procedure TCGMIPS.handle_reg_const_reg(list: tasmlist; op: Tasmop; src: tregister; a: tcgint; dst: tregister);
var
  tmpreg: tregister;
  op2: Tasmop;
  negate: boolean;
begin
  case op of
    A_ADD,A_SUB:
      op2:=A_ADDI;
    A_ADDU,A_SUBU:
      op2:=A_ADDIU;
  else
    InternalError(2013052001);
  end;
  negate:=op in [A_SUB,A_SUBU];
  { subtraction is actually addition of negated value, so possible range is
    off by one (-32767..32768) }
  if (a < simm16lo+ord(negate)) or
    (a > simm16hi+ord(negate)) then
  begin
    tmpreg := GetIntRegister(list, OS_INT);
    a_load_const_reg(list, OS_INT, a, tmpreg);
    list.concat(taicpu.op_reg_reg_reg(op, dst, src, tmpreg));
  end
  else
  begin
    if negate then
      a:=-a;
    list.concat(taicpu.op_reg_reg_const(op2, dst, src, a));
  end;
end;


{****************************************************************************
                              Assembler code
****************************************************************************}

procedure TCGMIPS.init_register_allocators;
begin
  inherited init_register_allocators;

  { Keep RS_R25, i.e. $t9 for PIC call }
  if (cs_create_pic in current_settings.moduleswitches) and assigned(current_procinfo) and
    (pi_needs_got in current_procinfo.flags) then
    begin
      current_procinfo.got := NR_GP;
      rg[R_INTREGISTER]    := Trgcpu.Create(R_INTREGISTER, R_SUBD,
        [RS_R2,RS_R3,RS_R4,RS_R5,RS_R6,RS_R7,RS_R8,RS_R9,
       RS_R10,RS_R11,RS_R12,RS_R13,RS_R14,RS_R15,RS_R16,RS_R17,RS_R18,RS_R19,
       RS_R20,RS_R21,RS_R22,RS_R23,RS_R24{,RS_R25}],
        first_int_imreg, []);
    end
  else
    rg[R_INTREGISTER] := trgcpu.Create(R_INTREGISTER, R_SUBD,
      [RS_R2,RS_R3,RS_R4,RS_R5,RS_R6,RS_R7,RS_R8,RS_R9,
       RS_R10,RS_R11,RS_R12,RS_R13,RS_R14,RS_R15,RS_R16,RS_R17,RS_R18,RS_R19,
       RS_R20,RS_R21,RS_R22,RS_R23,RS_R24{,RS_R25}],
      first_int_imreg, []);

{
  rg[R_FPUREGISTER] := trgcpu.Create(R_FPUREGISTER, R_SUBFS,
    [RS_F0,RS_F1,RS_F2,RS_F3,RS_F4,RS_F5,RS_F6,RS_F7,
     RS_F8,RS_F9,RS_F10,RS_F11,RS_F12,RS_F13,RS_F14,RS_F15,
     RS_F16,RS_F17,RS_F18,RS_F19,RS_F20,RS_F21,RS_F22,RS_F23,
     RS_F24,RS_F25,RS_F26,RS_F27,RS_F28,RS_F29,RS_F30,RS_F31],
    first_fpu_imreg, []);
}
  rg[R_FPUREGISTER] := trgcpu.Create(R_FPUREGISTER, R_SUBFS,
    [RS_F0,RS_F2,RS_F4,RS_F6, RS_F8,RS_F10,RS_F12,RS_F14,
     RS_F16,RS_F18,RS_F20,RS_F22, RS_F24,RS_F26,RS_F28,RS_F30],
    first_fpu_imreg, []);

  { needs at least one element for rgobj not to crash }
  rg[R_MMREGISTER]:=trgcpu.create(R_MMREGISTER,R_SUBNONE,
      [RS_R0],first_mm_imreg,[]);
end;



procedure TCGMIPS.done_register_allocators;
begin
  rg[R_INTREGISTER].Free;
  rg[R_FPUREGISTER].Free;
  rg[R_MMREGISTER].Free;
  inherited done_register_allocators;
end;


procedure TCGMIPS.a_loadfpu_ref_cgpara(list: tasmlist; size: tcgsize; const ref: treference; const paraloc: TCGPara);
var
  href, href2: treference;
  hloc: pcgparalocation;
begin
  { TODO: inherited cannot deal with individual locations for each of OS_32 registers.
    Must change parameter management to allocate a single 64-bit register pair,
    then this method can be removed.  }
  href := ref;
  hloc := paraloc.location;
  while assigned(hloc) do
  begin
    paramanager.allocparaloc(list,hloc);
    case hloc^.loc of
      LOC_REGISTER:
        a_load_ref_reg(list, hloc^.size, hloc^.size, href, hloc^.Register);
      LOC_FPUREGISTER,LOC_CFPUREGISTER :
        a_loadfpu_ref_reg(list,hloc^.size,hloc^.size,href,hloc^.register);
      LOC_REFERENCE:
        begin
          paraloc.check_simple_location;
          reference_reset_base(href2,paraloc.location^.reference.index,paraloc.location^.reference.offset,paraloc.alignment);
          { concatcopy should choose the best way to copy the data }
          g_concatcopy(list,ref,href2,tcgsize2size[size]);
        end;
      else
        internalerror(200408241);
    end;
    Inc(href.offset, tcgsize2size[hloc^.size]);
    hloc := hloc^.Next;
  end;
end;


procedure TCGMIPS.a_loadfpu_reg_cgpara(list: tasmlist; size: tcgsize; const r: tregister; const paraloc: TCGPara);
var
  href: treference;
begin
  if paraloc.Location^.next=nil then
    begin
      inherited a_loadfpu_reg_cgpara(list,size,r,paraloc);
      exit;
    end;
  tg.GetTemp(list, TCGSize2Size[size], TCGSize2Size[size], tt_normal, href);
  a_loadfpu_reg_ref(list, size, size, r, href);
  a_loadfpu_ref_cgpara(list, size, href, paraloc);
  tg.Ungettemp(list, href);
end;


procedure TCGMIPS.a_call_sym_pic(list: tasmlist; sym: tasmsymbol);
var
  href: treference;
begin
  reference_reset_symbol(href,sym,0,sizeof(aint));
  if (sym.bind=AB_LOCAL) then
    href.refaddr:=addr_pic
  else
    href.refaddr:=addr_pic_call16;
  href.base:=NR_GP;
  list.concat(taicpu.op_reg_ref(A_LW,NR_PIC_FUNC,href));
  if (sym.bind=AB_LOCAL) then
    begin
      href.refaddr:=addr_low;
      list.concat(taicpu.op_reg_ref(A_ADDIU,NR_PIC_FUNC,href));
    end;
  { JAL handled as macro provides delay slot and correct restoring of GP. }
  { Doing it ourselves requires a fixup pass, because GP restore location
    becomes known only in g_proc_entry, when all code is already generated. }

  { GAS <2.21 is buggy, it doesn't add delay slot in noreorder mode. As a result,
    the code will crash if dealing with stack frame size >32767 or if calling
    into shared library.
    This can be remedied by enabling instruction reordering, but then we also
    have to emit .set macro/.set nomacro pair and exclude JAL from the
    list of macro instructions (because noreorder is not allowed after nomacro) }
  list.concat(taicpu.op_none(A_P_SET_MACRO));
  list.concat(taicpu.op_none(A_P_SET_REORDER));
  list.concat(taicpu.op_reg(A_JAL,NR_PIC_FUNC));
  list.concat(taicpu.op_none(A_P_SET_NOREORDER));
  list.concat(taicpu.op_none(A_P_SET_NOMACRO));
end;


procedure TCGMIPS.a_call_name(list: tasmlist; const s: string; weak: boolean);
var
  sym: tasmsymbol;
begin
  if assigned(current_procinfo) and
     not (pi_do_call in current_procinfo.flags) then
    InternalError(2013022101);

  if weak then
    sym:=current_asmdata.WeakRefAsmSymbol(s)
  else
    sym:=current_asmdata.RefAsmSymbol(s);

  if (cs_create_pic in current_settings.moduleswitches) then
    a_call_sym_pic(list,sym)
  else
    begin
      list.concat(taicpu.op_sym(A_JAL,sym));
      { Delay slot }
      list.concat(taicpu.op_none(A_NOP));
    end;
end;


procedure TCGMIPS.a_call_reg(list: tasmlist; Reg: TRegister);
begin
  if assigned(current_procinfo) and
     not (pi_do_call in current_procinfo.flags) then
    InternalError(2013022102);
  // if (cs_create_pic in current_settings.moduleswitches) then
    begin
      if (Reg <> NR_PIC_FUNC) then
        list.concat(taicpu.op_reg_reg(A_MOVE,NR_PIC_FUNC,reg));
      { See comments in a_call_name }
      list.concat(taicpu.op_none(A_P_SET_MACRO));
      list.concat(taicpu.op_none(A_P_SET_REORDER));
      list.concat(taicpu.op_reg(A_JAL,NR_PIC_FUNC));
      list.concat(taicpu.op_none(A_P_SET_NOREORDER));
      list.concat(taicpu.op_none(A_P_SET_NOMACRO));
  (*  end
  else
    begin
      list.concat(taicpu.op_reg(A_JALR, reg));
      { Delay slot }
      list.concat(taicpu.op_none(A_NOP)); *)
    end;
end;


{********************** load instructions ********************}

procedure TCGMIPS.a_load_const_reg(list: tasmlist; size: TCGSize; a: tcgint; reg: TRegister);
begin
  if (a = 0) then
    list.concat(taicpu.op_reg_reg(A_MOVE, reg, NR_R0))
  else if (a >= simm16lo) and (a <= simm16hi) then
    list.concat(taicpu.op_reg_reg_const(A_ADDIU, reg, NR_R0, a))
  else if (a>=0) and (a <= 65535) then
    list.concat(taicpu.op_reg_reg_const(A_ORI, reg, NR_R0, a))
  else
    begin
      list.concat(taicpu.op_reg_const(A_LUI, reg, aint(a) shr 16));
      if (a and aint($FFFF))<>0 then
        list.concat(taicpu.op_reg_reg_const(A_ORI,reg,reg,a and aint($FFFF)));
    end;
end;


procedure TCGMIPS.a_load_const_ref(list: tasmlist; size: tcgsize; a: tcgint; const ref: TReference);
begin
  if a = 0 then
    a_load_reg_ref(list, size, size, NR_R0, ref)
  else
    inherited a_load_const_ref(list, size, a, ref);
end;


procedure TCGMIPS.a_load_reg_ref(list: tasmlist; FromSize, ToSize: TCGSize; reg: tregister; const Ref: TReference);
var
  op: tasmop;
  href: treference;
begin
  if (TCGSize2Size[fromsize] < TCGSize2Size[tosize]) then
    a_load_reg_reg(list,fromsize,tosize,reg,reg);
  case tosize of
    OS_8,
    OS_S8:
      Op := A_SB;
    OS_16,
    OS_S16:
      Op := A_SH;
    OS_32,
    OS_S32:
      Op := A_SW;
    else
      InternalError(2002122100);
  end;
  href:=ref;
  make_simple_ref(list,href);
  list.concat(taicpu.op_reg_ref(op,reg,href));
end;


procedure TCGMIPS.a_load_ref_reg(list: tasmlist; FromSize, ToSize: TCgSize; const ref: TReference; reg: tregister);
var
  op: tasmop;
  href: treference;
begin
  if (TCGSize2Size[fromsize] >= TCGSize2Size[tosize]) then
    fromsize := tosize;
  case fromsize of
    OS_S8:
      Op := A_LB;{Load Signed Byte}
    OS_8:
      Op := A_LBU;{Load Unsigned Byte}
    OS_S16:
      Op := A_LH;{Load Signed Halfword}
    OS_16:
      Op := A_LHU;{Load Unsigned Halfword}
    OS_S32:
      Op := A_LW;{Load Word}
    OS_32:
      Op := A_LW;//A_LWU;{Load Unsigned Word}
    OS_S64,
    OS_64:
      Op := A_LD;{Load a Long Word}
    else
      InternalError(2002122101);
  end;
  href:=ref;
  make_simple_ref(list,href);
  list.concat(taicpu.op_reg_ref(op,reg,href));
  if (fromsize=OS_S8) and (tosize=OS_16) then
    a_load_reg_reg(list,fromsize,tosize,reg,reg);
end;


procedure TCGMIPS.a_load_reg_reg(list: tasmlist; fromsize, tosize: tcgsize; reg1, reg2: tregister);
var
  instr: taicpu;
  done: boolean;
begin
  if (tcgsize2size[tosize] < tcgsize2size[fromsize]) or
    (
    (tcgsize2size[tosize] = tcgsize2size[fromsize]) and (tosize <> fromsize)
    ) or  ((fromsize = OS_S8) and
             (tosize = OS_16)) then
  begin
    done:=true;
    case tosize of
      OS_8:
        list.concat(taicpu.op_reg_reg_const(A_ANDI, reg2, reg1, $ff));
      OS_16:
        list.concat(taicpu.op_reg_reg_const(A_ANDI, reg2, reg1, $ffff));
      OS_32,
      OS_S32:
        done:=false;
      OS_S8:
      begin
        list.concat(taicpu.op_reg_reg_const(A_SLL, reg2, reg1, 24));
        list.concat(taicpu.op_reg_reg_const(A_SRA, reg2, reg2, 24));
      end;
      OS_S16:
      begin
        list.concat(taicpu.op_reg_reg_const(A_SLL, reg2, reg1, 16));
        list.concat(taicpu.op_reg_reg_const(A_SRA, reg2, reg2, 16));
      end;
      else
        internalerror(2002090901);
    end;
  end
  else
    done:=false;

  if (not done) and (reg1 <> reg2) then
  begin
    { same size, only a register mov required }
    instr := taicpu.op_reg_reg(A_MOVE, reg2, reg1);
    list.Concat(instr);
    { Notify the register allocator that we have written a move instruction so
      it can try to eliminate it. }
    add_move_instruction(instr);
  end;
end;


procedure TCGMIPS.a_loadaddr_ref_reg(list: tasmlist; const ref: TReference; r: tregister);
var
  href: treference;
  hreg: tregister;
begin
  { Enforce some discipline for callers:
    - reference must be a "raw" one and not use gp }
  if (ref.base=NR_GP) or (ref.index=NR_GP) then
    InternalError(2013022803);
  if (ref.refaddr<>addr_no) then
    InternalError(2013022804);
  if (ref.base=NR_NO) and (ref.index<>NR_NO) then
    InternalError(200306171);

  if (ref.symbol=nil) then
    begin
      if (ref.base<>NR_NO) then
        begin
          if (ref.offset<simm16lo) or (ref.offset>simm16hi) then
            begin
              hreg:=getintregister(list,OS_INT);
              a_load_const_reg(list,OS_INT,ref.offset,hreg);
              list.concat(taicpu.op_reg_reg_reg(A_ADDU,r,ref.base,hreg));
            end
          else if (ref.offset<>0) then
            list.concat(taicpu.op_reg_reg_const(A_ADDIU,r,ref.base,ref.offset))
          else
            a_load_reg_reg(list,OS_INT,OS_INT,ref.base,r);  { emit optimizable move }

          if (ref.index<>NR_NO) then
            list.concat(taicpu.op_reg_reg_reg(A_ADDU,r,r,ref.index));
        end
      else
        a_load_const_reg(list,OS_INT,ref.offset,r);
      exit;
    end;

  reference_reset_symbol(href,ref.symbol,ref.offset,ref.alignment);
  if (cs_create_pic in current_settings.moduleswitches) then
    begin
      { For PIC global symbols offset must be handled separately.
        Otherwise (non-PIC or local symbols) offset can be encoded
        into relocation even if exceeds 16 bits. }
      if (href.symbol.bind<>AB_LOCAL) then
        href.offset:=0;
      href.refaddr:=addr_pic;
      href.base:=NR_GP;
      list.concat(taicpu.op_reg_ref(A_LW,r,href));
    end
  else
    begin
      href.refaddr:=addr_high;
      list.concat(taicpu.op_reg_ref(A_LUI,r,href));
    end;

  { Add original base/index, if any. }
  if (ref.base<>NR_NO) then
    list.concat(taicpu.op_reg_reg_reg(A_ADDU,r,r,ref.base));
  if (ref.index<>NR_NO) then
    list.concat(taicpu.op_reg_reg_reg(A_ADDU,r,r,ref.index));

  { add low part if necessary }
  if (ref.symbol.bind=AB_LOCAL) or
     not (cs_create_pic in current_settings.moduleswitches) then
    begin
      href.refaddr:=addr_low;
      href.base:=NR_NO;
      list.concat(taicpu.op_reg_reg_ref(A_ADDIU,r,r,href));
      exit;
    end;

  if (ref.offset<simm16lo) or (ref.offset>simm16hi) then
    begin
      hreg:=getintregister(list,OS_INT);
      a_load_const_reg(list,OS_INT,ref.offset,hreg);
      list.concat(taicpu.op_reg_reg_reg(A_ADDU,r,r,hreg));
    end
  else if (ref.offset<>0) then
    list.concat(taicpu.op_reg_reg_const(A_ADDIU,r,r,ref.offset));
end;

procedure TCGMIPS.a_loadfpu_reg_reg(list: tasmlist; fromsize, tosize: tcgsize; reg1, reg2: tregister);
const
  FpuMovInstr: array[OS_F32..OS_F64,OS_F32..OS_F64] of TAsmOp =
    ((A_MOV_S, A_CVT_D_S),(A_CVT_S_D,A_MOV_D));
var
  instr: taicpu;
begin
  if (reg1 <> reg2) or (fromsize<>tosize) then
  begin
    instr := taicpu.op_reg_reg(fpumovinstr[fromsize,tosize], reg2, reg1);
    list.Concat(instr);
    { Notify the register allocator that we have written a move instruction so
      it can try to eliminate it. }
    if (fromsize=tosize) then
      add_move_instruction(instr);
  end;
end;


procedure TCGMIPS.a_loadfpu_ref_reg(list: tasmlist; fromsize, tosize: tcgsize; const ref: TReference; reg: tregister);
var
  href: TReference;
begin
  href:=ref;
  make_simple_ref(list,href);
  case fromsize of
    OS_F32:
      list.concat(taicpu.op_reg_ref(A_LWC1,reg,href));
    OS_F64:
      list.concat(taicpu.op_reg_ref(A_LDC1,reg,href));
    else
      InternalError(2007042701);
  end;
  if tosize<>fromsize then
    a_loadfpu_reg_reg(list,fromsize,tosize,reg,reg);
end;

procedure TCGMIPS.a_loadfpu_reg_ref(list: tasmlist; fromsize, tosize: tcgsize; reg: tregister; const ref: TReference);
var
  href: TReference;
begin
  if tosize<>fromsize then
    a_loadfpu_reg_reg(list,fromsize,tosize,reg,reg);
  href:=ref;
  make_simple_ref(list,href);
  case tosize of
    OS_F32:
      list.concat(taicpu.op_reg_ref(A_SWC1,reg,href));
    OS_F64:
      list.concat(taicpu.op_reg_ref(A_SDC1,reg,href));
    else
      InternalError(2007042702);
  end;
end;

procedure TCGMIPS.maybeadjustresult(list: TAsmList; op: TOpCg; size: tcgsize; dst: tregister);
const
  overflowops = [OP_MUL,OP_SHL,OP_ADD,OP_SUB,OP_NOT,OP_NEG];
begin
  if (op in overflowops) and
    (size in [OS_8,OS_S8,OS_16,OS_S16]) then
    a_load_reg_reg(list,OS_32,size,dst,dst);
end;

procedure TCGMIPS.overflowcheck_internal(list: tasmlist; arg1, arg2: tregister);
var
  carry, hreg: tregister;
begin
  if (arg1=arg2) then
    InternalError(2013050501);
  carry:=GetIntRegister(list,OS_INT);
  hreg:=GetIntRegister(list,OS_INT);
  list.concat(taicpu.op_reg_reg_reg(A_SLTU,carry,arg1,arg2));
  { if carry<>0, this will cause hardware overflow interrupt }
  a_load_const_reg(list,OS_INT,$80000000,hreg);
  list.concat(taicpu.op_reg_reg_reg(A_SUB,hreg,hreg,carry));
end;


const
  ops_mul: array[boolean] of TAsmOp = (A_MULTU,A_MULT);
  ops_add: array[boolean] of TAsmOp = (A_ADDU, A_ADD);
  ops_sub: array[boolean] of TAsmOp = (A_SUBU, A_SUB);
  ops_and: array[boolean] of TAsmOp = (A_AND, A_ANDI);
  ops_or:  array[boolean] of TAsmOp = (A_OR, A_ORI);
  ops_xor: array[boolean] of TasmOp = (A_XOR, A_XORI);


procedure TCGMIPS.a_op_const_reg(list: tasmlist; Op: TOpCG; size: tcgsize; a: tcgint; reg: TRegister);
begin
  optimize_op_const(op,a);
  case op of
    OP_NONE:
      exit;

    OP_MOVE:
      a_load_const_reg(list,size,a,reg);

    OP_NEG,OP_NOT:
      internalerror(200306011);
  else
    a_op_const_reg_reg(list,op,size,a,reg,reg);
  end;
end;


procedure TCGMIPS.a_op_reg_reg(list: tasmlist; Op: TOpCG; size: TCGSize; src, dst: TRegister);
begin
  case Op of
    OP_NEG:
      list.concat(taicpu.op_reg_reg_reg(A_SUBU, dst, NR_R0, src));

    OP_NOT:
      list.concat(taicpu.op_reg_reg_reg(A_NOR, dst, NR_R0, src));

    OP_IMUL,OP_MUL:
      begin
        list.concat(taicpu.op_reg_reg(ops_mul[op=OP_IMUL], dst, src));
        list.concat(taicpu.op_reg(A_MFLO, dst));
      end;
  else
    list.concat(taicpu.op_reg_reg_reg(f_TOpCG2AsmOp(op, size), dst, dst, src));
  end;
  maybeadjustresult(list,op,size,dst);
end;


procedure TCGMIPS.a_op_const_reg_reg(list: tasmlist; op: TOpCg; size: tcgsize; a: tcgint; src, dst: tregister);
var
  l: TLocation;
begin
  a_op_const_reg_reg_checkoverflow(list, op, size, a, src, dst, false, l);
end;


procedure TCGMIPS.a_op_reg_reg_reg(list: tasmlist; op: TOpCg; size: tcgsize; src1, src2, dst: tregister);
begin

  list.concat(taicpu.op_reg_reg_reg(f_TOpCG2AsmOp(op, size), dst, src2, src1));
  maybeadjustresult(list,op,size,dst);
end;


procedure TCGMIPS.a_op_const_reg_reg_checkoverflow(list: tasmlist; op: TOpCg; size: tcgsize; a: tcgint; src, dst: tregister; setflags: boolean; var ovloc: tlocation);
var
  signed,immed: boolean;
  hreg: TRegister;
  asmop: TAsmOp;
begin
  ovloc.loc := LOC_VOID;
  optimize_op_const(op,a);
  signed:=(size in [OS_S8,OS_S16,OS_S32]);
  if (setflags and (not signed) and (src=dst) and (op in [OP_ADD,OP_SUB])) then
    hreg:=GetIntRegister(list,OS_INT)
  else
    hreg:=dst;
  case op of
    OP_NONE:
      a_load_reg_reg(list,size,size,src,dst);

    OP_MOVE:
      a_load_const_reg(list,size,a,dst);

    OP_ADD:
      begin
        handle_reg_const_reg(list,ops_add[setflags and signed],src,a,hreg);
        if setflags and (not signed) then
          overflowcheck_internal(list,hreg,src);
        { does nothing if hreg=dst }
        a_load_reg_reg(list,OS_INT,OS_INT,hreg,dst);
      end;

    OP_SUB:
      begin
        handle_reg_const_reg(list,ops_sub[setflags and signed],src,a,hreg);
        if setflags and (not signed) then
          overflowcheck_internal(list,src,hreg);
        a_load_reg_reg(list,OS_INT,OS_INT,hreg,dst);
      end;

    OP_MUL,OP_IMUL:
      begin
        hreg:=GetIntRegister(list,OS_INT);
        a_load_const_reg(list,OS_INT,a,hreg);
        a_op_reg_reg_reg_checkoverflow(list,op,size,src,hreg,dst,setflags,ovloc);
        exit;
      end;

    OP_AND,OP_OR,OP_XOR:
      begin
        { logical operations zero-extend, not sign-extend, the immediate }
        immed:=(a>=0) and (a<=65535);
        case op of
          OP_AND:   asmop:=ops_and[immed];
          OP_OR:    asmop:=ops_or[immed];
          OP_XOR:   asmop:=ops_xor[immed];
        else
          InternalError(2013050401);
        end;

        if immed then
          list.concat(taicpu.op_reg_reg_const(asmop,dst,src,a))
        else
          begin
            hreg:=GetIntRegister(list,OS_INT);
            a_load_const_reg(list,OS_INT,a,hreg);
            list.concat(taicpu.op_reg_reg_reg(asmop,dst,src,hreg));
          end;
      end;

    OP_SHL,OP_SHR,OP_SAR:
      list.concat(taicpu.op_reg_reg_const(f_TOpCG2AsmOp_ovf(op,size),dst,src,a));

  else
    internalerror(2007012601);
  end;
  maybeadjustresult(list,op,size,dst);
end;


procedure TCGMIPS.a_op_reg_reg_reg_checkoverflow(list: tasmlist; op: TOpCg; size: tcgsize; src1, src2, dst: tregister; setflags: boolean; var ovloc: tlocation);
var
  signed: boolean;
  hreg,hreg2: TRegister;
  hl: tasmlabel;
begin
  ovloc.loc := LOC_VOID;
  signed:=(size in [OS_S8,OS_S16,OS_S32]);
  if (setflags and (not signed) and (src2=dst) and (op in [OP_ADD,OP_SUB])) then
    hreg:=GetIntRegister(list,OS_INT)
  else
    hreg:=dst;
  case op of
    OP_ADD:
      begin
        list.concat(taicpu.op_reg_reg_reg(ops_add[setflags and signed], hreg, src2, src1));
        if setflags and (not signed) then
          overflowcheck_internal(list, hreg, src2);
        a_load_reg_reg(list, OS_INT, OS_INT, hreg, dst);
      end;
    OP_SUB:
      begin
        list.concat(taicpu.op_reg_reg_reg(ops_sub[setflags and signed], hreg, src2, src1));
        if setflags and (not signed) then
          overflowcheck_internal(list, src2, hreg);
        a_load_reg_reg(list, OS_INT, OS_INT, hreg, dst);
      end;
    OP_MUL,OP_IMUL:
      begin
        list.concat(taicpu.op_reg_reg(ops_mul[op=OP_IMUL], src2, src1));
        list.concat(taicpu.op_reg(A_MFLO, dst));
        if setflags then
          begin
            current_asmdata.getjumplabel(hl);
            hreg:=GetIntRegister(list,OS_INT);
            list.concat(taicpu.op_reg(A_MFHI,hreg));
            if (op=OP_IMUL) then
              begin
                hreg2:=GetIntRegister(list,OS_INT);
                list.concat(taicpu.op_reg_reg_const(A_SRA,hreg2,dst,31));
                a_cmp_reg_reg_label(list,OS_INT,OC_EQ,hreg2,hreg,hl);
              end
            else
              a_cmp_reg_reg_label(list,OS_INT,OC_EQ,hreg,NR_R0,hl);
            list.concat(taicpu.op_const(A_BREAK,6));
            a_label(list,hl);
          end;
      end;
    OP_AND,OP_OR,OP_XOR:
      begin
        list.concat(taicpu.op_reg_reg_reg(f_TOpCG2AsmOp_ovf(op, size), dst, src2, src1));
      end;
    else
      internalerror(2007012602);
  end;
  maybeadjustresult(list,op,size,dst);
end;



{*************** compare instructructions ****************}

procedure TCGMIPS.a_cmp_const_reg_label(list: tasmlist; size: tcgsize; cmp_op: topcmp; a: tcgint; reg: tregister; l: tasmlabel);
var
  tmpreg: tregister;
  ai : Taicpu;
begin
if a = 0 then
  tmpreg := NR_R0
else
begin
  tmpreg := GetIntRegister(list, OS_INT);
  a_load_const_reg(list,OS_INT,a,tmpreg);
end;
  ai := taicpu.op_reg_reg_sym(A_BC, reg, tmpreg, l);
  ai.SetCondition(TOpCmp2AsmCond[cmp_op]);
  list.concat(ai);
  { Delay slot }
  list.Concat(TAiCpu.Op_none(A_NOP));
end;


procedure TCGMIPS.a_cmp_reg_reg_label(list: tasmlist; size: tcgsize; cmp_op: topcmp; reg1, reg2: tregister; l: tasmlabel);
var
  ai : Taicpu;
begin
  ai := taicpu.op_reg_reg_sym(A_BC, reg2, reg1, l);
  ai.SetCondition(TOpCmp2AsmCond[cmp_op]);
  list.concat(ai);
  { Delay slot }
  list.Concat(TAiCpu.Op_none(A_NOP));
end;


procedure TCGMIPS.a_jmp_always(List: tasmlist; l: TAsmLabel);
var
  ai : Taicpu;
begin
  ai := taicpu.op_sym(A_BA, l);
  list.concat(ai);
  { Delay slot }
  list.Concat(TAiCpu.Op_none(A_NOP));
end;


procedure TCGMIPS.a_jmp_name(list: tasmlist; const s: string);
begin
  List.Concat(TAiCpu.op_sym(A_BA, current_asmdata.RefAsmSymbol(s)));
  { Delay slot }
  list.Concat(TAiCpu.Op_none(A_NOP));
end;


procedure TCGMIPS.g_overflowCheck(List: tasmlist; const Loc: TLocation; def: TDef);
begin
// this is an empty procedure
end;

procedure TCGMIPS.g_overflowCheck_loc(List: tasmlist; const Loc: TLocation; def: TDef; ovloc: tlocation);
begin

// this is an empty procedure

end;

{ *********** entry/exit code and address loading ************ }

procedure TCGMIPS.g_proc_entry(list: tasmlist; localsize: longint; nostackframe: boolean);
var
  lastintoffset,lastfpuoffset,
  nextoffset : aint;
  i : longint;
  ra_save,framesave : taicpu;
  fmask,mask : dword;
  saveregs : tcpuregisterset;
  href:  treference;
  reg : Tsuperregister;
  helplist : TAsmList;
begin
  a_reg_alloc(list,NR_STACK_POINTER_REG);

  if nostackframe then
    exit;

  if (pi_needs_stackframe in current_procinfo.flags) then
    a_reg_alloc(list,NR_FRAME_POINTER_REG);

  helplist:=TAsmList.Create;

  reference_reset(href,0);
  href.base:=NR_STACK_POINTER_REG;

  fmask:=0;
  nextoffset:=TMIPSProcInfo(current_procinfo).floatregstart;
  lastfpuoffset:=LocalSize;
  for reg := RS_F0 to RS_F31 do { to check: what if F30 is double? }
    begin
      if reg in (rg[R_FPUREGISTER].used_in_proc-paramanager.get_volatile_registers_fpu(pocall_stdcall)) then
        begin
          fmask:=fmask or (1 shl ord(reg));
          href.offset:=nextoffset;
          lastfpuoffset:=nextoffset;
          helplist.concat(taicpu.op_reg_ref(A_SWC1,newreg(R_FPUREGISTER,reg,R_SUBFS),href));
          inc(nextoffset,4);
          { IEEE Double values are stored in floating point
            register pairs f2X/f2X+1,
            as the f2X+1 register is not correctly marked as used for now,
            we simply assume it is also used if f2X is used 
            Should be fixed by a proper inclusion of f2X+1 into used_in_proc }
          if (ord(reg)-ord(RS_F0)) mod 2 = 0 then
            include(rg[R_FPUREGISTER].used_in_proc,succ(reg));
        end;
    end;

  mask:=0;
  nextoffset:=TMIPSProcInfo(current_procinfo).intregstart;
  saveregs:=rg[R_INTREGISTER].used_in_proc-paramanager.get_volatile_registers_int(pocall_stdcall);
  if (current_procinfo.flags*[pi_do_call,pi_is_assembler]<>[]) then
    include(saveregs,RS_R31);
  if (pi_needs_stackframe in current_procinfo.flags) then
    include(saveregs,RS_FRAME_POINTER_REG);
  lastintoffset:=LocalSize;
  framesave:=nil;
  ra_save:=nil;

  for reg:=RS_R1 to RS_R31 do
    begin
      if reg in saveregs then
        begin
          mask:=mask or (1 shl ord(reg));
          href.offset:=nextoffset;
          lastintoffset:=nextoffset;
          if (reg=RS_FRAME_POINTER_REG) then
            framesave:=taicpu.op_reg_ref(A_SW,newreg(R_INTREGISTER,reg,R_SUBWHOLE),href)
          else if (reg=RS_R31) then
            ra_save:=taicpu.op_reg_ref(A_SW,newreg(R_INTREGISTER,reg,R_SUBWHOLE),href)
          else
            helplist.concat(taicpu.op_reg_ref(A_SW,newreg(R_INTREGISTER,reg,R_SUBWHOLE),href));
          inc(nextoffset,4);
        end;
    end;

  //list.concat(Taicpu.Op_reg_reg_const(A_ADDIU,NR_FRAME_POINTER_REG,NR_STACK_POINTER_REG,current_procinfo.para_stack_size));
  list.concat(Taicpu.op_none(A_P_SET_NOMIPS16));
  list.concat(Taicpu.op_reg_const_reg(A_P_FRAME,current_procinfo.framepointer,LocalSize,NR_R31));
  list.concat(Taicpu.op_const_const(A_P_MASK,mask,-(LocalSize-lastintoffset)));
  list.concat(Taicpu.op_const_const(A_P_FMASK,Fmask,-(LocalSize-lastfpuoffset)));
  list.concat(Taicpu.op_none(A_P_SET_NOREORDER));
  if (cs_create_pic in current_settings.moduleswitches) and
     (pi_needs_got in current_procinfo.flags) then
    begin
      list.concat(Taicpu.op_reg(A_P_CPLOAD,NR_PIC_FUNC));
    end;

  if (-LocalSize >= simm16lo) and (-LocalSize <= simm16hi) then
    begin
      list.concat(Taicpu.op_none(A_P_SET_NOMACRO));
      list.concat(Taicpu.Op_reg_reg_const(A_ADDIU,NR_STACK_POINTER_REG,NR_STACK_POINTER_REG,-LocalSize));
      if assigned(ra_save) then
        list.concat(ra_save);
      if assigned(framesave) then
        begin
          list.concat(framesave);
          list.concat(Taicpu.op_reg_reg_const(A_ADDIU,NR_FRAME_POINTER_REG,
            NR_STACK_POINTER_REG,LocalSize));
        end;
    end
  else
    begin
      a_load_const_reg(list,OS_32,-LocalSize,NR_R9);
      list.concat(Taicpu.Op_reg_reg_reg(A_ADDU,NR_STACK_POINTER_REG,NR_STACK_POINTER_REG,NR_R9));
      if assigned(ra_save) then
        list.concat(ra_save);
      if assigned(framesave) then
        begin
          list.concat(framesave);
          list.concat(Taicpu.op_reg_reg_reg(A_SUBU,NR_FRAME_POINTER_REG,
            NR_STACK_POINTER_REG,NR_R9));
        end;
      { The instructions before are macros that can extend to multiple instructions,
        the settings of R9 to -LocalSize surely does,
        but the saving of RA and FP also might, and might
        even use AT register, which is why we use R9 instead of AT here for -LocalSize }
      list.concat(Taicpu.op_none(A_P_SET_NOMACRO));
    end;
  if (cs_create_pic in current_settings.moduleswitches) and
     (pi_needs_got in current_procinfo.flags) then
    begin
      list.concat(Taicpu.op_none(A_P_SET_MACRO));
      list.concat(Taicpu.op_const(A_P_CPRESTORE,TMIPSProcinfo(current_procinfo).save_gp_ref.offset));
      list.concat(Taicpu.op_none(A_P_SET_NOMACRO));
    end;

  with TMIPSProcInfo(current_procinfo) do
    begin
      href.offset:=0;
      //if current_procinfo.framepointer<>NR_STACK_POINTER_REG then
        href.base:=NR_FRAME_POINTER_REG;

      for i:=0 to MIPS_MAX_REGISTERS_USED_IN_CALL-1 do
        if (register_used[i]) then
          begin
            reg:=parasupregs[i];
            if register_offset[i]=-1 then
              comment(V_warning,'Register parameter has offset -1 in TCGMIPS.g_proc_entry');

            //if current_procinfo.framepointer=NR_STACK_POINTER_REG then
            //  href.offset:=register_offset[i]+Localsize
            //else
            href.offset:=register_offset[i];
            list.concat(taicpu.op_reg_ref(A_SW, newreg(R_INTREGISTER,reg,R_SUBWHOLE), href));
        end;
    end;
  list.concatList(helplist);
  helplist.Free;
end;


procedure TCGMIPS.g_proc_exit(list: tasmlist; parasize: longint; nostackframe: boolean);
var
  href : treference;
  stacksize : aint;
  saveregs : tcpuregisterset;
  nextoffset : aint;
  reg : Tsuperregister;
begin
  stacksize:=current_procinfo.calc_stackframe_size;
   if nostackframe then
     begin
       list.concat(taicpu.op_reg(A_JR, NR_R31));
       list.concat(Taicpu.op_none(A_NOP));
       list.concat(Taicpu.op_none(A_P_SET_MACRO));
       list.concat(Taicpu.op_none(A_P_SET_REORDER));
     end
   else
     begin
       reference_reset(href,0);
       href.base:=NR_STACK_POINTER_REG;

       nextoffset:=TMIPSProcInfo(current_procinfo).floatregstart;
       for reg := RS_F0 to RS_F31 do
         begin
           if reg in (rg[R_FPUREGISTER].used_in_proc-paramanager.get_volatile_registers_fpu(pocall_stdcall)) then
             begin
               href.offset:=nextoffset;
               list.concat(taicpu.op_reg_ref(A_LWC1,newreg(R_FPUREGISTER,reg,R_SUBFS),href));
               inc(nextoffset,4);
             end;
         end;

       nextoffset:=TMIPSProcInfo(current_procinfo).intregstart;
       saveregs:=rg[R_INTREGISTER].used_in_proc-paramanager.get_volatile_registers_int(pocall_stdcall);
       if (current_procinfo.flags*[pi_do_call,pi_is_assembler]<>[]) then
         include(saveregs,RS_R31);
       if (pi_needs_stackframe in current_procinfo.flags) then
         include(saveregs,RS_FRAME_POINTER_REG);
       // GP does not need to be restored on exit
       for reg:=RS_R1 to RS_R31 do
         begin
           if reg in saveregs then
             begin
               href.offset:=nextoffset;
               list.concat(taicpu.op_reg_ref(A_LW,newreg(R_INTREGISTER,reg,R_SUBWHOLE),href));
               inc(nextoffset,sizeof(aint));
             end;
         end;

       if (-stacksize >= simm16lo) and (-stacksize <= simm16hi) then
         begin
           list.concat(taicpu.op_reg(A_JR, NR_R31));
           { correct stack pointer in the delay slot }
           list.concat(Taicpu.Op_reg_reg_const(A_ADDIU, NR_STACK_POINTER_REG, NR_STACK_POINTER_REG, stacksize));
         end
       else
         begin
           a_load_const_reg(list,OS_32,stacksize,NR_R1);
           list.concat(taicpu.op_reg(A_JR, NR_R31));
           { correct stack pointer in the delay slot }
           list.concat(taicpu.op_reg_reg_reg(A_ADD,NR_STACK_POINTER_REG,NR_STACK_POINTER_REG,NR_R1));
         end;
       list.concat(Taicpu.op_none(A_P_SET_MACRO));
       list.concat(Taicpu.op_none(A_P_SET_REORDER));
    end;
end;



{ ************* concatcopy ************ }

procedure TCGMIPS.g_concatcopy_move(list: tasmlist; const Source, dest: treference; len: tcgint);
var
  paraloc1, paraloc2, paraloc3: TCGPara;
  pd: tprocdef;
begin
  pd:=search_system_proc('MOVE');
  paraloc1.init;
  paraloc2.init;
  paraloc3.init;
  paramanager.getintparaloc(pd, 1, paraloc1);
  paramanager.getintparaloc(pd, 2, paraloc2);
  paramanager.getintparaloc(pd, 3, paraloc3);
  a_load_const_cgpara(list, OS_SINT, len, paraloc3);
  a_loadaddr_ref_cgpara(list, dest, paraloc2);
  a_loadaddr_ref_cgpara(list, Source, paraloc1);
  paramanager.freecgpara(list, paraloc3);
  paramanager.freecgpara(list, paraloc2);
  paramanager.freecgpara(list, paraloc1);
  alloccpuregisters(list, R_INTREGISTER, paramanager.get_volatile_registers_int(pocall_default));
  alloccpuregisters(list, R_FPUREGISTER, paramanager.get_volatile_registers_fpu(pocall_default));
  a_call_name(list, 'FPC_MOVE', false);
  dealloccpuregisters(list, R_FPUREGISTER, paramanager.get_volatile_registers_fpu(pocall_default));
  dealloccpuregisters(list, R_INTREGISTER, paramanager.get_volatile_registers_int(pocall_default));
  paraloc3.done;
  paraloc2.done;
  paraloc1.done;
end;


procedure TCGMIPS.g_concatcopy(list: tasmlist; const Source, dest: treference; len: tcgint);
var
  tmpreg1, hreg, countreg: TRegister;
  src, dst: TReference;
  lab:      tasmlabel;
  Count, count2: aint;
  ai : TaiCpu;

  function reference_is_reusable(const ref: treference): boolean;
    begin
      result:=(ref.base<>NR_NO) and (ref.index=NR_NO) and
         (ref.symbol=nil) and
         (ref.alignment>=sizeof(aint)) and
         (ref.offset>=simm16lo) and (ref.offset+len<=simm16hi);
    end;

begin
  if len > high(longint) then
    internalerror(2002072704);
  { A call (to FPC_MOVE) requires the outgoing parameter area to be properly
    allocated on stack. This can only be done before tmipsprocinfo.set_first_temp_offset,
    i.e. before secondpass. Other internal procedures request correct stack frame
    by setting pi_do_call during firstpass, but for this particular one it is impossible.
    Therefore, if the current procedure is a leaf one, we have to leave it that way. }

  { anybody wants to determine a good value here :)? }
  if (len > 100) and
     assigned(current_procinfo) and
     (pi_do_call in current_procinfo.flags) then
    g_concatcopy_move(list, Source, dest, len)
  else
  begin
    Count := len div 4;
    if (count<=4) and reference_is_reusable(source) then
      src:=source
    else
      begin
        reference_reset(src,sizeof(aint));
        { load the address of source into src.base }
        src.base := GetAddressRegister(list);
        a_loadaddr_ref_reg(list, Source, src.base);
      end;
    if (count<=4) and reference_is_reusable(dest) then
      dst:=dest
    else
      begin
        reference_reset(dst,sizeof(aint));
        { load the address of dest into dst.base }
        dst.base := GetAddressRegister(list);
        a_loadaddr_ref_reg(list, dest, dst.base);
      end;
    { generate a loop }
    if Count > 4 then
    begin
      countreg := GetIntRegister(list, OS_INT);
      tmpreg1  := GetIntRegister(list, OS_INT);
      a_load_const_reg(list, OS_INT, Count, countreg);
      current_asmdata.getjumplabel(lab);
      a_label(list, lab);
      list.concat(taicpu.op_reg_ref(A_LW, tmpreg1, src));
      list.concat(taicpu.op_reg_ref(A_SW, tmpreg1, dst));
      list.concat(taicpu.op_reg_reg_const(A_ADDIU, src.base, src.base, 4));
      list.concat(taicpu.op_reg_reg_const(A_ADDIU, dst.base, dst.base, 4));
      list.concat(taicpu.op_reg_reg_const(A_ADDIU, countreg, countreg, -1));
      //list.concat(taicpu.op_reg_sym(A_BGTZ, countreg, lab));
      ai := taicpu.op_reg_reg_sym(A_BC,countreg, NR_R0, lab);
      ai.setcondition(C_GT);
      list.concat(ai);
      list.concat(taicpu.op_none(A_NOP));
      len := len mod 4;
    end;
    { unrolled loop }
    Count := len div 4;
    if Count > 0 then
    begin
      tmpreg1 := GetIntRegister(list, OS_INT);
      for count2 := 1 to Count do
      begin
        list.concat(taicpu.op_reg_ref(A_LW, tmpreg1, src));
        list.concat(taicpu.op_reg_ref(A_SW, tmpreg1, dst));
        Inc(src.offset, 4);
        Inc(dst.offset, 4);
      end;
      len := len mod 4;
    end;
    if (len and 4) <> 0 then
    begin
      hreg := GetIntRegister(list, OS_INT);
      a_load_ref_reg(list, OS_32, OS_32, src, hreg);
      a_load_reg_ref(list, OS_32, OS_32, hreg, dst);
      Inc(src.offset, 4);
      Inc(dst.offset, 4);
    end;
    { copy the leftovers }
    if (len and 2) <> 0 then
    begin
      hreg := GetIntRegister(list, OS_INT);
      a_load_ref_reg(list, OS_16, OS_16, src, hreg);
      a_load_reg_ref(list, OS_16, OS_16, hreg, dst);
      Inc(src.offset, 2);
      Inc(dst.offset, 2);
    end;
    if (len and 1) <> 0 then
    begin
      hreg := GetIntRegister(list, OS_INT);
      a_load_ref_reg(list, OS_8, OS_8, src, hreg);
      a_load_reg_ref(list, OS_8, OS_8, hreg, dst);
    end;
  end;
end;


procedure TCGMIPS.g_concatcopy_unaligned(list: tasmlist; const Source, dest: treference; len: tcgint);
var
  src, dst: TReference;
  tmpreg1, countreg: TRegister;
  i:   aint;
  lab: tasmlabel;
  ai : TaiCpu;
begin
  if (len > 31) and
    { see comment in g_concatcopy }
     assigned(current_procinfo) and
     (pi_do_call in current_procinfo.flags) then
    g_concatcopy_move(list, Source, dest, len)
  else
  begin
    reference_reset(src,sizeof(aint));
    reference_reset(dst,sizeof(aint));
    { load the address of source into src.base }
    src.base := GetAddressRegister(list);
    a_loadaddr_ref_reg(list, Source, src.base);
    { load the address of dest into dst.base }
    dst.base := GetAddressRegister(list);
    a_loadaddr_ref_reg(list, dest, dst.base);
    { generate a loop }
    if len > 4 then
    begin
      countreg := cg.GetIntRegister(list, OS_INT);
      tmpreg1  := cg.GetIntRegister(list, OS_INT);
      a_load_const_reg(list, OS_INT, len, countreg);
      current_asmdata.getjumplabel(lab);
      a_label(list, lab);
      list.concat(taicpu.op_reg_ref(A_LBU, tmpreg1, src));
      list.concat(taicpu.op_reg_ref(A_SB, tmpreg1, dst));
      list.concat(taicpu.op_reg_reg_const(A_ADDIU, src.base, src.base, 1));
      list.concat(taicpu.op_reg_reg_const(A_ADDIU, dst.base, dst.base, 1));
      list.concat(taicpu.op_reg_reg_const(A_ADDIU, countreg, countreg, -1));
      //list.concat(taicpu.op_reg_sym(A_BGTZ, countreg, lab));
      ai := taicpu.op_reg_reg_sym(A_BC,countreg, NR_R0, lab);
      ai.setcondition(C_GT);
      list.concat(ai);
      list.concat(taicpu.op_none(A_NOP));
    end
    else
    begin
      { unrolled loop }
      tmpreg1 := cg.GetIntRegister(list, OS_INT);
      for i := 1 to len do
      begin
        list.concat(taicpu.op_reg_ref(A_LBU, tmpreg1, src));
        list.concat(taicpu.op_reg_ref(A_SB, tmpreg1, dst));
        Inc(src.offset);
        Inc(dst.offset);
      end;
    end;
  end;
end;


procedure TCGMIPS.g_intf_wrapper(list: tasmlist; procdef: tprocdef; const labelname: string; ioffset: longint);
var
  make_global: boolean;
  hsym: tsym;
  href: treference;
  paraloc: Pcgparalocation;
  IsVirtual: boolean;
begin
  if not(procdef.proctypeoption in [potype_function,potype_procedure]) then
    Internalerror(200006137);
  if not assigned(procdef.struct) or
    (procdef.procoptions * [po_classmethod, po_staticmethod,
    po_methodpointer, po_interrupt, po_iocheck] <> []) then
    Internalerror(200006138);
  if procdef.owner.symtabletype <> objectsymtable then
    Internalerror(200109191);

  make_global := False;
  if (not current_module.is_unit) or create_smartlink or
    (procdef.owner.defowner.owner.symtabletype = globalsymtable) then
    make_global := True;

  if make_global then
    List.concat(Tai_symbol.Createname_global(labelname, AT_FUNCTION, 0))
  else
    List.concat(Tai_symbol.Createname(labelname, AT_FUNCTION, 0));

  IsVirtual:=(po_virtualmethod in procdef.procoptions) and
      not is_objectpascal_helper(procdef.struct);

  if (cs_create_pic in current_settings.moduleswitches) and
    (not IsVirtual) then
    begin
      list.concat(Taicpu.op_none(A_P_SET_NOREORDER));
      list.concat(Taicpu.op_reg(A_P_CPLOAD,NR_PIC_FUNC));
      list.concat(Taicpu.op_none(A_P_SET_REORDER));
    end;

  { set param1 interface to self  }
  procdef.init_paraloc_info(callerside);
  hsym:=tsym(procdef.parast.Find('self'));
  if not(assigned(hsym) and
    (hsym.typ=paravarsym)) then
    internalerror(2010103101);
  paraloc:=tparavarsym(hsym).paraloc[callerside].location;
  if assigned(paraloc^.next) then
    InternalError(2013020101);

  case paraloc^.loc of
    LOC_REGISTER:
      begin
        if ((ioffset>=simm16lo) and (ioffset<=simm16hi)) then
          a_op_const_reg(list,OP_SUB, paraloc^.size,ioffset,paraloc^.register)
        else
          begin
            a_load_const_reg(list, paraloc^.size, ioffset, NR_R1);
            a_op_reg_reg(list, OP_SUB, paraloc^.size, NR_R1, paraloc^.register);
          end;
      end;
  else
    internalerror(2010103102);
  end;

  if IsVirtual then
  begin
    { load VMT pointer }
    reference_reset_base(href,paraloc^.register,0,sizeof(aint));
    list.concat(taicpu.op_reg_ref(A_LW,NR_VMT,href));

    if (procdef.extnumber=$ffff) then
      Internalerror(200006139);

    { TODO: case of large VMT is not handled }
    { We have no reason not to use $t9 even in non-PIC mode. }
    reference_reset_base(href, NR_VMT, tobjectdef(procdef.struct).vmtmethodoffset(procdef.extnumber), sizeof(aint));
    list.concat(taicpu.op_reg_ref(A_LW,NR_PIC_FUNC,href));
    list.concat(taicpu.op_reg(A_JR, NR_PIC_FUNC));
  end
  else if not (cs_create_pic in current_settings.moduleswitches) then
    list.concat(taicpu.op_sym(A_J,current_asmdata.RefAsmSymbol(procdef.mangledname)))
  else
    begin
      { GAS does not expand "J symbol" into PIC sequence }
      reference_reset_symbol(href,current_asmdata.RefAsmSymbol(procdef.mangledname),0,sizeof(pint));
      href.base:=NR_GP;
      href.refaddr:=addr_pic_call16;
      list.concat(taicpu.op_reg_ref(A_LW,NR_PIC_FUNC,href));
      list.concat(taicpu.op_reg(A_JR,NR_PIC_FUNC));
    end;
  { Delay slot }
  list.Concat(TAiCpu.Op_none(A_NOP));

  List.concat(Tai_symbol_end.Createname(labelname));
end;


procedure TCGMIPS.g_external_wrapper(list: TAsmList; procdef: tprocdef; const externalname: string);
  var
    href: treference;
  begin
    reference_reset_symbol(href,current_asmdata.RefAsmSymbol(externalname),0,sizeof(aint));
    { Always do indirect jump using $t9, it won't harm in non-PIC mode }
    if (cs_create_pic in current_settings.moduleswitches) then
      begin
        list.concat(taicpu.op_none(A_P_SET_NOREORDER));
        list.concat(taicpu.op_reg(A_P_CPLOAD,NR_PIC_FUNC));
        href.base:=NR_GP;
        href.refaddr:=addr_pic_call16;
        list.concat(taicpu.op_reg_ref(A_LW,NR_PIC_FUNC,href));
        list.concat(taicpu.op_reg(A_JR,NR_PIC_FUNC));
        { Delay slot }
        list.Concat(taicpu.op_none(A_NOP));
        list.Concat(taicpu.op_none(A_P_SET_REORDER));
      end
    else
      begin
        href.refaddr:=addr_high;
        list.concat(taicpu.op_reg_ref(A_LUI,NR_PIC_FUNC,href));
        href.refaddr:=addr_low;
        list.concat(taicpu.op_reg_ref(A_ADDIU,NR_PIC_FUNC,href));
        list.concat(taicpu.op_reg(A_JR,NR_PIC_FUNC));
        { Delay slot }
        list.Concat(taicpu.op_none(A_NOP));
      end;
  end;


procedure TCGMIPS.g_profilecode(list:TAsmList);
  var
    href: treference;
  begin
    if not (cs_create_pic in current_settings.moduleswitches) then
      begin
        reference_reset_symbol(href,current_asmdata.RefAsmSymbol('_gp'),0,sizeof(pint));
        a_loadaddr_ref_reg(list,href,NR_GP);
      end;
    list.concat(taicpu.op_reg_reg(A_MOVE,NR_R1,NR_RA));
    list.concat(taicpu.op_reg_reg_const(A_ADDIU,NR_SP,NR_SP,-8));
    a_call_sym_pic(list,current_asmdata.RefAsmSymbol('_mcount'));
  end;


procedure TCGMIPS.g_adjust_self_value(list:TAsmList;procdef: tprocdef;ioffset: tcgint);
  begin
    { This method is integrated into g_intf_wrapper and shouldn't be called separately }
    InternalError(2013020102);
  end;

procedure TCGMIPS.g_stackpointer_alloc(list : TAsmList;localsize : longint);
  begin
    Comment(V_Error,'TCgMPSel.g_stackpointer_alloc method not implemented');
  end;

procedure TCGMIPS.a_bit_scan_reg_reg(list: TAsmList; reverse: boolean; size: TCGSize; src, dst: TRegister);
  begin
    Comment(V_Error,'TCgMPSel.a_bit_scan_reg_reg method not implemented');
  end;

{****************************************************************************
                               TCG64_MIPSel
****************************************************************************}


procedure TCg64MPSel.a_load64_reg_ref(list: tasmlist; reg: tregister64; const ref: treference);
var
  tmpref: treference;
  tmpreg: tregister;
begin
  { Override this function to prevent loading the reference twice }
  if target_info.endian = endian_big then
    begin
      tmpreg := reg.reglo;
      reg.reglo := reg.reghi;
      reg.reghi := tmpreg;
    end;
  tmpref := ref;
  cg.a_load_reg_ref(list, OS_S32, OS_S32, reg.reglo, tmpref);
  Inc(tmpref.offset, 4);
  cg.a_load_reg_ref(list, OS_S32, OS_S32, reg.reghi, tmpref);
end;


procedure TCg64MPSel.a_load64_ref_reg(list: tasmlist; const ref: treference; reg: tregister64);
var
  tmpref: treference;
  tmpreg: tregister;
begin
  { Override this function to prevent loading the reference twice }
  if target_info.endian = endian_big then
    begin
      tmpreg := reg.reglo;
      reg.reglo := reg.reghi;
      reg.reghi := tmpreg;
    end;
  tmpref := ref;
  cg.a_load_ref_reg(list, OS_S32, OS_S32, tmpref, reg.reglo);
  Inc(tmpref.offset, 4);
  cg.a_load_ref_reg(list, OS_S32, OS_S32, tmpref, reg.reghi);
end;


procedure TCg64MPSel.a_load64_ref_cgpara(list: tasmlist; const r: treference; const paraloc: tcgpara);
var
  hreg64: tregister64;
begin
        { Override this function to prevent loading the reference twice.
          Use here some extra registers, but those are optimized away by the RA }
  hreg64.reglo := cg.GetIntRegister(list, OS_S32);
  hreg64.reghi := cg.GetIntRegister(list, OS_S32);
  a_load64_ref_reg(list, r, hreg64);
  a_load64_reg_cgpara(list, hreg64, paraloc);
end;

procedure TCg64MPSel.a_op64_reg_reg(list: tasmlist; op: TOpCG; size: tcgsize; regsrc, regdst: TRegister64);
var
  tmpreg1: TRegister;
begin
  case op of
    OP_NEG:
      begin
        tmpreg1 := cg.GetIntRegister(list, OS_INT);
        list.concat(taicpu.op_reg_reg_reg(A_SUBU, regdst.reglo, NR_R0, regsrc.reglo));
        list.concat(taicpu.op_reg_reg_reg(A_SLTU, tmpreg1, NR_R0, regdst.reglo));
        list.concat(taicpu.op_reg_reg_reg(A_SUBU, regdst.reghi, NR_R0, regsrc.reghi));
        list.concat(taicpu.op_reg_reg_reg(A_SUBU, regdst.reghi, regdst.reghi, tmpreg1));
      end;

    OP_NOT:
      begin
        list.concat(taicpu.op_reg_reg_reg(A_NOR, regdst.reglo, NR_R0, regsrc.reglo));
        list.concat(taicpu.op_reg_reg_reg(A_NOR, regdst.reghi, NR_R0, regsrc.reghi));
      end;
  else
    a_op64_reg_reg_reg(list,op,size,regsrc,regdst,regdst);
  end;
end;


procedure TCg64MPSel.a_op64_const_reg(list: tasmlist; op: TOpCG; size: tcgsize; Value: int64; regdst: TRegister64);
begin
  a_op64_const_reg_reg(list, op, size, value, regdst, regdst);
end;

procedure TCg64MPSel.a_op64_const_reg_reg(list: tasmlist; op: TOpCG; size: tcgsize; Value: int64; regsrc, regdst: tregister64);
var
  l: tlocation;
begin
  a_op64_const_reg_reg_checkoverflow(list, op, size, Value, regsrc, regdst, False, l);
end;


procedure TCg64MPSel.a_op64_reg_reg_reg(list: tasmlist; op: TOpCG; size: tcgsize; regsrc1, regsrc2, regdst: tregister64);
var
  l: tlocation;
begin
  a_op64_reg_reg_reg_checkoverflow(list, op, size, regsrc1, regsrc2, regdst, False, l);
end;


procedure TCg64MPSel.a_op64_const_reg_reg_checkoverflow(list: tasmlist; op: TOpCG; size: tcgsize; Value: int64; regsrc, regdst: tregister64; setflags: boolean; var ovloc: tlocation);
var
  tmplo,carry: TRegister;
  hisize: tcgsize;
begin
  carry:=NR_NO;
  if (size in [OS_S64]) then
    hisize:=OS_S32
  else
    hisize:=OS_32;

  case op of
    OP_AND,OP_OR,OP_XOR:
      begin
        cg.a_op_const_reg_reg(list,op,OS_32,aint(lo(value)),regsrc.reglo,regdst.reglo);
        cg.a_op_const_reg_reg(list,op,OS_32,aint(hi(value)),regsrc.reghi,regdst.reghi);
      end;

    OP_ADD:
      begin
        if lo(value)<>0 then
          begin
            tmplo:=cg.GetIntRegister(list,OS_32);
            carry:=cg.GetIntRegister(list,OS_32);
            tcgmips(cg).handle_reg_const_reg(list,A_ADDU,regsrc.reglo,aint(lo(value)),tmplo);
            list.concat(taicpu.op_reg_reg_reg(A_SLTU,carry,tmplo,regsrc.reglo));
            cg.a_load_reg_reg(list,OS_32,OS_32,tmplo,regdst.reglo);
          end
        else
          cg.a_load_reg_reg(list,OS_32,OS_32,regsrc.reglo,regdst.reglo);

        { With overflow checking and unsigned args, this generates slighly suboptimal code
         ($80000000 constant loaded twice). Other cases are fine. Getting it perfect does not
         look worth the effort. }
        cg.a_op_const_reg_reg_checkoverflow(list,OP_ADD,hisize,aint(hi(value)),regsrc.reghi,regdst.reghi,setflags,ovloc);
        if carry<>NR_NO then
          cg.a_op_reg_reg_reg_checkoverflow(list,OP_ADD,hisize,carry,regdst.reghi,regdst.reghi,setflags,ovloc);
      end;

    OP_SUB:
      begin
        carry:=NR_NO;
        if lo(value)<>0 then
          begin
            tmplo:=cg.GetIntRegister(list,OS_32);
            carry:=cg.GetIntRegister(list,OS_32);
            tcgmips(cg).handle_reg_const_reg(list,A_SUBU,regsrc.reglo,aint(lo(value)),tmplo);
            list.concat(taicpu.op_reg_reg_reg(A_SLTU,carry,regsrc.reglo,tmplo));
            cg.a_load_reg_reg(list,OS_32,OS_32,tmplo,regdst.reglo);
          end
        else
          cg.a_load_reg_reg(list,OS_32,OS_32,regsrc.reglo,regdst.reglo);

        cg.a_op_const_reg_reg_checkoverflow(list,OP_SUB,hisize,aint(hi(value)),regsrc.reghi,regdst.reghi,setflags,ovloc);
        if carry<>NR_NO then
          cg.a_op_reg_reg_reg_checkoverflow(list,OP_SUB,hisize,carry,regdst.reghi,regdst.reghi,setflags,ovloc);
      end;
  else
    InternalError(2013050301);
  end;
end;


procedure TCg64MPSel.a_op64_reg_reg_reg_checkoverflow(list: tasmlist; op: TOpCG; size: tcgsize; regsrc1, regsrc2, regdst: tregister64; setflags: boolean; var ovloc: tlocation);
var
  tmplo,tmphi,carry,hreg: TRegister;
  signed: boolean;
begin
  case op of
    OP_ADD:
      begin
        signed:=(size in [OS_S64]);
        tmplo := cg.GetIntRegister(list,OS_S32);
        carry := cg.GetIntRegister(list,OS_S32);
        // destreg.reglo could be regsrc1.reglo or regsrc2.reglo
        list.concat(taicpu.op_reg_reg_reg(A_ADDU, tmplo, regsrc2.reglo, regsrc1.reglo));
        list.concat(taicpu.op_reg_reg_reg(A_SLTU, carry, tmplo, regsrc2.reglo));
        cg.a_load_reg_reg(list,OS_INT,OS_INT,tmplo,regdst.reglo);
        if signed or (not setflags) then
          begin
            list.concat(taicpu.op_reg_reg_reg(ops_add[setflags and signed], regdst.reghi, regsrc2.reghi, regsrc1.reghi));
            list.concat(taicpu.op_reg_reg_reg(ops_add[setflags and signed], regdst.reghi, regdst.reghi, carry));
          end
        else
          begin
            tmphi:=cg.GetIntRegister(list,OS_INT);
            hreg:=cg.GetIntRegister(list,OS_INT);
            cg.a_load_const_reg(list,OS_INT,$80000000,hreg);
            // first add carry to one of the addends
            list.concat(taicpu.op_reg_reg_reg(A_ADDU, tmphi, regsrc2.reghi, carry));
            list.concat(taicpu.op_reg_reg_reg(A_SLTU, carry, tmphi, regsrc2.reghi));
            list.concat(taicpu.op_reg_reg_reg(A_SUB, carry, hreg, carry));
            // then add another addend
            list.concat(taicpu.op_reg_reg_reg(A_ADDU, regdst.reghi, tmphi, regsrc1.reghi));
            list.concat(taicpu.op_reg_reg_reg(A_SLTU, carry, regdst.reghi, tmphi));
            list.concat(taicpu.op_reg_reg_reg(A_SUB, carry, hreg, carry));
          end;
      end;
    OP_SUB:
      begin
        signed:=(size in [OS_S64]);
        tmplo := cg.GetIntRegister(list,OS_S32);
        carry := cg.GetIntRegister(list,OS_S32);
        // destreg.reglo could be regsrc1.reglo or regsrc2.reglo
        list.concat(taicpu.op_reg_reg_reg(A_SUBU, tmplo, regsrc2.reglo, regsrc1.reglo));
        list.concat(taicpu.op_reg_reg_reg(A_SLTU, carry, regsrc2.reglo,tmplo));
        cg.a_load_reg_reg(list,OS_INT,OS_INT,tmplo,regdst.reglo);
        if signed or (not setflags) then
          begin
            list.concat(taicpu.op_reg_reg_reg(ops_sub[setflags and signed], regdst.reghi, regsrc2.reghi, regsrc1.reghi));
            list.concat(taicpu.op_reg_reg_reg(ops_sub[setflags and signed], regdst.reghi, regdst.reghi, carry));
          end
        else
          begin
            tmphi:=cg.GetIntRegister(list,OS_INT);
            hreg:=cg.GetIntRegister(list,OS_INT);
            cg.a_load_const_reg(list,OS_INT,$80000000,hreg);
            // first subtract the carry...
            list.concat(taicpu.op_reg_reg_reg(A_SUBU, tmphi, regsrc2.reghi, carry));
            list.concat(taicpu.op_reg_reg_reg(A_SLTU, carry, regsrc2.reghi, tmphi));
            list.concat(taicpu.op_reg_reg_reg(A_SUB, carry, hreg, carry));
            // ...then the subtrahend
            list.concat(taicpu.op_reg_reg_reg(A_SUBU, regdst.reghi, tmphi, regsrc1.reghi));
            list.concat(taicpu.op_reg_reg_reg(A_SLTU, carry, tmphi, regdst.reghi));
            list.concat(taicpu.op_reg_reg_reg(A_SUB, carry, hreg, carry));
          end;
      end;
    OP_AND,OP_OR,OP_XOR:
      begin
        cg.a_op_reg_reg_reg(list,op,size,regsrc1.reglo,regsrc2.reglo,regdst.reglo);
        cg.a_op_reg_reg_reg(list,op,size,regsrc1.reghi,regsrc2.reghi,regdst.reghi);
      end;
  else
    internalerror(200306017);
  end;
end;


    procedure create_codegen;
      begin
        cg:=TCGMIPS.Create;
        cg64:=TCg64MPSel.Create;
      end;

end.
