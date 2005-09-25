{
    Copyright (c) 1999-2002 by Jonas Maebe

    Contains the assembler object for the PowerPC64. Heavily based on code
    from the PowerPC platform

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
unit aasmcpu;

{$I fpcdefs.inc}

interface

uses
  globtype, verbose,
  aasmbase, aasmtai,
  cpubase, cgbase, cgutils;

const
  { "mov reg,reg" source operand number }
  O_MOV_SOURCE = 1;
  { "mov reg,reg" source operand number }
  O_MOV_DEST = 0;

type
  taicpu = class(tai_cpu_abstract)
    constructor op_none(op: tasmop);

    constructor op_reg(op: tasmop; _op1: tregister);
    constructor op_const(op: tasmop; _op1: aint);

    constructor op_reg_reg(op: tasmop; _op1, _op2: tregister);
    constructor op_reg_ref(op: tasmop; _op1: tregister; const _op2: treference);
    constructor op_reg_const(op: tasmop; _op1: tregister; _op2: aint);
    constructor op_const_reg(op: tasmop; _op1: aint; _op2: tregister);

    constructor op_const_const(op: tasmop; _op1, _op2: aint);

    constructor op_reg_reg_const_const(op: tasmop; _op1, _op2: tregister; _op3,
      _op4: aint);

    constructor op_reg_reg_reg(op: tasmop; _op1, _op2, _op3: tregister);
    constructor op_reg_reg_const(op: tasmop; _op1, _op2: tregister; _op3: aint);
    constructor op_reg_reg_sym_ofs(op: tasmop; _op1, _op2: tregister; _op3:
      tasmsymbol; _op3ofs: aint);
    constructor op_reg_reg_ref(op: tasmop; _op1, _op2: tregister; const _op3:
      treference);
    constructor op_const_reg_reg(op: tasmop; _op1: aint; _op2, _op3: tregister);
    constructor op_const_reg_const(op: tasmop; _op1: aint; _op2: tregister;
      _op3: aint);
    constructor op_const_const_const(op: tasmop; _op1: aint; _op2: aint; _op3:
      aint);

    constructor op_reg_reg_reg_reg(op: tasmop; _op1, _op2, _op3, _op4:
      tregister);
    constructor op_reg_bool_reg_reg(op: tasmop; _op1: tregister; _op2: boolean;
      _op3, _op4: tregister);
    constructor op_reg_bool_reg_const(op: tasmop; _op1: tregister; _op2:
      boolean; _op3: tregister; _op4: aint);

    constructor op_reg_reg_reg_const_const(op: tasmop; _op1, _op2, _op3:
      tregister; _op4, _op5: aint);
    constructor op_reg_reg_const_const_const(op: tasmop; _op1, _op2: tregister;
      _op3, _op4, _op5: aint);

    { this is for Jmp instructions }
    constructor op_cond_sym(op: tasmop; cond: TAsmCond; _op1: tasmsymbol);
    constructor op_const_const_sym(op: tasmop; _op1, _op2: aint; _op3:
      tasmsymbol);

    constructor op_sym(op: tasmop; _op1: tasmsymbol);
    constructor op_sym_ofs(op: tasmop; _op1: tasmsymbol; _op1ofs: aint);
    constructor op_reg_sym_ofs(op: tasmop; _op1: tregister; _op2: tasmsymbol;
      _op2ofs: aint);
    constructor op_sym_ofs_ref(op: tasmop; _op1: tasmsymbol; _op1ofs: aint; const
      _op2: treference);

    procedure loadbool(opidx: aint; _b: boolean);

    function is_same_reg_move(regtype: Tregistertype): boolean; override;

  end;

  tai_align = class(tai_align_abstract)
    { nothing to add }
  end;

procedure InitAsm;
procedure DoneAsm;

function spilling_create_load(const ref: treference; r: tregister): tai;
function spilling_create_store(r: tregister; const ref: treference): tai;

implementation

uses cutils;

{*****************************************************************************
                                 taicpu Constructors
*****************************************************************************}

procedure taicpu.loadbool(opidx: aint; _b: boolean);
begin
  if opidx >= ops then
    ops := opidx + 1;
  with oper[opidx]^ do
  begin
    if typ = top_ref then
      dispose(ref);
    b := _b;
    typ := top_bool;
  end;
end;

constructor taicpu.op_none(op: tasmop);
begin
  inherited create(op);
end;

constructor taicpu.op_reg(op: tasmop; _op1: tregister);
begin
  inherited create(op);
  ops := 1;
  loadreg(0, _op1);
end;

constructor taicpu.op_const(op: tasmop; _op1: aint);
begin
  inherited create(op);
  ops := 1;
  loadconst(0, _op1);
end;

constructor taicpu.op_reg_reg_const_const(op: tasmop; _op1, _op2: tregister;
  _op3, _op4: aint);
begin
  inherited create(op);
  ops := 4;
  loadreg(0, _op1);
  loadreg(1, _op2);
  loadconst(2, _op3);
  loadconst(3, _op4);
end;

constructor taicpu.op_reg_reg(op: tasmop; _op1, _op2: tregister);
begin
  inherited create(op);
  ops := 2;
  loadreg(0, _op1);
  loadreg(1, _op2);
end;

constructor taicpu.op_reg_const(op: tasmop; _op1: tregister; _op2: aint);
begin
  inherited create(op);
  ops := 2;
  loadreg(0, _op1);
  loadconst(1, _op2);
end;

constructor taicpu.op_const_reg(op: tasmop; _op1: aint; _op2: tregister);
begin
  inherited create(op);
  ops := 2;
  loadconst(0, _op1);
  loadreg(1, _op2);
end;

constructor taicpu.op_reg_ref(op: tasmop; _op1: tregister; const _op2:
  treference);
begin
  inherited create(op);
  ops := 2;
  loadreg(0, _op1);
  loadref(1, _op2);
end;

constructor taicpu.op_const_const(op: tasmop; _op1, _op2: aint);
begin
  inherited create(op);
  ops := 2;
  loadconst(0, _op1);
  loadconst(1, _op2);
end;

constructor taicpu.op_reg_reg_reg(op: tasmop; _op1, _op2, _op3: tregister);
begin
  inherited create(op);
  ops := 3;
  loadreg(0, _op1);
  loadreg(1, _op2);
  loadreg(2, _op3);
end;

constructor taicpu.op_reg_reg_const(op: tasmop; _op1, _op2: tregister; _op3:
  aint);
begin
  inherited create(op);
  ops := 3;
  loadreg(0, _op1);
  loadreg(1, _op2);
  loadconst(2, _op3);
end;

constructor taicpu.op_reg_reg_sym_ofs(op: tasmop; _op1, _op2: tregister; _op3:
  tasmsymbol; _op3ofs: aint);
begin
  inherited create(op);
  ops := 3;
  loadreg(0, _op1);
  loadreg(1, _op2);
  loadsymbol(0, _op3, _op3ofs);
end;

constructor taicpu.op_reg_reg_ref(op: tasmop; _op1, _op2: tregister; const _op3:
  treference);
begin
  inherited create(op);
  ops := 3;
  loadreg(0, _op1);
  loadreg(1, _op2);
  loadref(2, _op3);
end;

constructor taicpu.op_const_reg_reg(op: tasmop; _op1: aint; _op2, _op3:
  tregister);
begin
  inherited create(op);
  ops := 3;
  loadconst(0, _op1);
  loadreg(1, _op2);
  loadreg(2, _op3);
end;

constructor taicpu.op_const_reg_const(op: tasmop; _op1: aint; _op2: tregister;
  _op3: aint);
begin
  inherited create(op);
  ops := 3;
  loadconst(0, _op1);
  loadreg(1, _op2);
  loadconst(2, _op3);
end;

constructor taicpu.op_const_const_const(op: tasmop; _op1: aint; _op2: aint;
  _op3: aint);
begin
  inherited create(op);
  ops := 3;
  loadconst(0, _op1);
  loadconst(1, _op2);
  loadconst(2, _op3);
end;

constructor taicpu.op_reg_reg_reg_reg(op: tasmop; _op1, _op2, _op3, _op4:
  tregister);
begin
  inherited create(op);
  ops := 4;
  loadreg(0, _op1);
  loadreg(1, _op2);
  loadreg(2, _op3);
  loadreg(3, _op4);
end;

constructor taicpu.op_reg_bool_reg_reg(op: tasmop; _op1: tregister; _op2:
  boolean; _op3, _op4: tregister);
begin
  inherited create(op);
  ops := 4;
  loadreg(0, _op1);
  loadbool(1, _op2);
  loadreg(2, _op3);
  loadreg(3, _op4);
end;

constructor taicpu.op_reg_bool_reg_const(op: tasmop; _op1: tregister; _op2:
  boolean; _op3: tregister; _op4: aint);
begin
  inherited create(op);
  ops := 4;
  loadreg(0, _op1);
  loadbool(0, _op2);
  loadreg(0, _op3);
  loadconst(0, cardinal(_op4));
end;

constructor taicpu.op_reg_reg_reg_const_const(op: tasmop; _op1, _op2, _op3:
  tregister; _op4, _op5: aint);
begin
  inherited create(op);
  ops := 5;
  loadreg(0, _op1);
  loadreg(1, _op2);
  loadreg(2, _op3);
  loadconst(3, cardinal(_op4));
  loadconst(4, cardinal(_op5));
end;

constructor taicpu.op_reg_reg_const_const_const(op: tasmop; _op1, _op2:
  tregister; _op3, _op4, _op5: aint);
begin
  inherited create(op);
  ops := 5;
  loadreg(0, _op1);
  loadreg(1, _op2);
  loadconst(2, _op3);
  loadconst(3, _op4);
  loadconst(4, _op5);
end;

constructor taicpu.op_cond_sym(op: tasmop; cond: TAsmCond; _op1: tasmsymbol);
begin
  inherited create(op);
  condition := cond;
  ops := 1;
  loadsymbol(0, _op1, 0);
end;

constructor taicpu.op_const_const_sym(op: tasmop; _op1, _op2: aint; _op3:
  tasmsymbol);
begin
  inherited create(op);
  ops := 3;
  loadconst(0, _op1);
  loadconst(1, _op2);
  loadsymbol(2, _op3, 0);
end;

constructor taicpu.op_sym(op: tasmop; _op1: tasmsymbol);
begin
  inherited create(op);
  ops := 1;
  loadsymbol(0, _op1, 0);
end;

constructor taicpu.op_sym_ofs(op: tasmop; _op1: tasmsymbol; _op1ofs: aint);
begin
  inherited create(op);
  ops := 1;
  loadsymbol(0, _op1, _op1ofs);
end;

constructor taicpu.op_reg_sym_ofs(op: tasmop; _op1: tregister; _op2: tasmsymbol;
  _op2ofs: aint);
begin
  inherited create(op);
  ops := 2;
  loadreg(0, _op1);
  loadsymbol(1, _op2, _op2ofs);
end;

constructor taicpu.op_sym_ofs_ref(op: tasmop; _op1: tasmsymbol; _op1ofs: aint;
  const _op2: treference);
begin
  inherited create(op);
  ops := 2;
  loadsymbol(0, _op1, _op1ofs);
  loadref(1, _op2);
end;

{ ****************************** newra stuff *************************** }

function taicpu.is_same_reg_move(regtype: Tregistertype): boolean;
begin
  result :=
    (((opcode = A_MR) and
    (regtype = R_INTREGISTER)) or
    ((opcode = A_FMR) and
    (regtype = R_FPUREGISTER))) and
    { these opcodes can only have registers as operands }
  (oper[0]^.reg = oper[1]^.reg);
end;

function spilling_create_load(const ref: treference; r: tregister): tai;
begin
  result := taicpu.op_reg_ref(A_LD, r, ref);
end;

function spilling_create_store(r: tregister; const ref: treference): tai;
begin
  result := taicpu.op_reg_ref(A_STD, r, ref);
end;

procedure InitAsm;
begin
end;

procedure DoneAsm;
begin
end;

begin
  cai_align := tai_align;
  cai_cpu := taicpu;
end.

