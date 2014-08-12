{
    Copyright (c) 1999-2014 by Mazen Neifer and David Zhang and Jeppe Johansen

    Contains the assembler object for the RISC-V
    Adapted from MIPS specific code

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

{$i fpcdefs.inc}

  interface

    uses
      cclasses,
      globtype, globals, verbose,
      aasmbase, aasmdata, aasmsym, aasmtai,
      cgbase, cgutils, cpubase, cpuinfo;

    const
      { "mov reg,reg" source operand number }
      O_MOV_SOURCE = 0;
      { "mov reg,reg" source operand number }
      O_MOV_DEST   = 1;

    type
      taicpu = class(tai_cpu_abstract_sym)
        constructor op_none(op: tasmop);

        constructor op_reg(op: tasmop; _op1: tregister);
        constructor op_const(op: tasmop; _op1: longint);
        constructor op_ref(op: tasmop; const _op1: treference);

        constructor op_reg_reg(op: tasmop; _op1, _op2: tregister);
        constructor op_reg_ref(op: tasmop; _op1: tregister; const _op2: treference);
        constructor op_reg_const(op: tasmop; _op1: tregister; _op2: longint);
        constructor op_const_const(op: tasmop; _op1: aint; _op2: aint);

        constructor op_reg_reg_reg(op: tasmop; _op1, _op2, _op3: tregister);

        constructor op_reg_reg_ref(op: tasmop; _op1, _op2: tregister; const _op3: treference);
        constructor op_reg_reg_const(op: tasmop; _op1, _op2: tregister; _op3: aint);
        { INS and EXT }
        constructor op_reg_reg_const_const(op: tasmop; _op1,_op2: tregister; _op3,_op4: aint);
        constructor op_reg_const_reg(op: tasmop; _op1: tregister; _op2: aint; _op3: tregister);

        { this is for Jmp instructions }
        constructor op_sym(op: tasmop; _op1: tasmsymbol);
        constructor op_reg_reg_sym(op: tasmop; _op1, _op2: tregister; _op3: tasmsymbol);
        constructor op_reg_sym(op: tasmop; _op1: tregister; _op2: tasmsymbol);
        constructor op_sym_ofs(op: tasmop; _op1: tasmsymbol; _op1ofs: longint);

        { register allocation }
        function is_same_reg_move(regtype: Tregistertype): boolean; override;

        { register spilling code }
        function spilling_get_operation_type(opnr: longint): topertype; override;
      end;

      tai_align = class(tai_align_abstract)
        { nothing to add }
      end;

    procedure InitAsm;
    procedure DoneAsm;

    function spilling_create_load(const ref: treference; r: tregister): taicpu;
    function spilling_create_store(r: tregister; const ref: treference): taicpu;

  implementation

    uses
      cutils;


    constructor taicpu.op_none(op: tasmop);
      begin
        inherited Create(op);
      end;


    constructor taicpu.op_reg(op: tasmop; _op1: tregister);
      begin
        inherited Create(op);
        ops := 1;
        loadreg(0, _op1);
      end;


    constructor taicpu.op_ref(op: tasmop; const _op1: treference);
      begin
        inherited Create(op);
        ops := 1;
        loadref(0, _op1);
      end;


    constructor taicpu.op_const(op: tasmop; _op1: longint);
      begin
        inherited Create(op);
        ops := 1;
        loadconst(0, _op1);
      end;


    constructor taicpu.op_reg_reg(op: tasmop; _op1, _op2: tregister);
      begin
        inherited Create(op);
        ops := 2;
        loadreg(0, _op1);
        loadreg(1, _op2);
      end;


    constructor taicpu.op_reg_const(op: tasmop; _op1: tregister; _op2: longint);
    begin
      inherited Create(op);
      ops := 2;
      loadreg(0, _op1);
      loadconst(1, _op2);
    end;


    constructor taicpu.op_const_const(op: tasmop; _op1: aint; _op2: aint);
      begin
        inherited Create(op);
        ops := 2;
        loadconst(0, _op1);
        loadconst(1, _op2);
      end;


    constructor taicpu.op_reg_ref(op: tasmop; _op1: tregister; const _op2: treference);
      begin
        inherited Create(op);
        ops := 2;
        loadreg(0, _op1);
        loadref(1, _op2);
      end;


    constructor taicpu.op_reg_reg_reg(op: tasmop; _op1, _op2, _op3: tregister);
      begin
        inherited Create(op);
        ops := 3;
        loadreg(0, _op1);
        loadreg(1, _op2);
        loadreg(2, _op3);
      end;


    constructor taicpu.op_reg_reg_ref(op: tasmop; _op1, _op2: tregister; const _op3: treference);
      begin
        inherited create(op);
        ops := 3;
        loadreg(0, _op1);
        loadreg(1, _op2);
        loadref(2, _op3);
      end;


    constructor taicpu.op_reg_reg_const(op: tasmop; _op1, _op2: tregister; _op3: aint);
      begin
        inherited create(op);
        ops := 3;
        loadreg(0, _op1);
        loadreg(1, _op2);
        loadconst(2, _op3);
      end;


    constructor taicpu.op_reg_reg_const_const(op: tasmop; _op1, _op2: tregister; _op3, _op4: aint);
      begin
        inherited create(op);
        ops := 4;
        loadreg(0, _op1);
        loadreg(1, _op2);
        loadconst(2, _op3);
        loadconst(3, _op4);
      end;


    constructor taicpu.op_reg_const_reg(op: tasmop; _op1: tregister; _op2: aint; _op3: tregister);
      begin
        inherited create(op);
        ops := 3;
        loadreg(0, _op1);
        loadconst(1, _op2);
        loadreg(2, _op3);
      end;


    constructor taicpu.op_sym(op: tasmop; _op1: tasmsymbol);
      begin
        inherited Create(op);
        is_jmp := op in [A_Bcc,A_J];
        ops := 1;
        loadsymbol(0, _op1, 0);
      end;


    constructor taicpu.op_reg_reg_sym(op: tasmop; _op1, _op2: tregister; _op3: tasmsymbol);
      begin
         inherited create(op);
         is_jmp := op in [A_Bcc,A_J];
         ops := 3;
         loadreg(0, _op1);
         loadreg(1, _op2);
         loadsymbol(2, _op3, 0);
      end;


    constructor taicpu.op_reg_sym(op: tasmop; _op1: tregister; _op2: tasmsymbol);
    begin
       inherited create(op);
       is_jmp := op in [A_Bcc,A_J];
       ops := 2;
       loadreg(0, _op1);
       loadsymbol(1, _op2, 0);
    end;


    constructor taicpu.op_sym_ofs(op: tasmop; _op1: tasmsymbol; _op1ofs: longint);
      begin
        inherited Create(op);
        ops := 1;
        loadsymbol(0, _op1, _op1ofs);
      end;


    function taicpu.is_same_reg_move(regtype: Tregistertype): boolean;
      begin
        Result := ((((opcode = A_ADDI) and (regtype = R_INTREGISTER))) and
                   (oper[0]^.reg = oper[1]^.reg) and
                   (oper[2]^.val = 0)) or
                  ((((opcode = A_MOVE) and (regtype = R_INTREGISTER))) and
                   (oper[0]^.reg = oper[1]^.reg));
      end;


    function taicpu.spilling_get_operation_type(opnr: longint): topertype;
      begin
        result := operand_read;

        case opcode of
          A_Bcc,A_J,
          A_SB,A_SW,A_SH:
            result:=operand_read;
          else
            if opnr = 0 then
              result := operand_write;
        end;
      end;


    function spilling_create_load(const ref: treference; r: tregister): taicpu;
      begin
        case getregtype(r) of
          R_INTREGISTER :
            result:=taicpu.op_reg_ref(A_LW,r,ref);
          else
            internalerror(200401041);
        end;
      end;


    function spilling_create_store(r: tregister; const ref: treference): taicpu;
      begin
        case getregtype(r) of
          R_INTREGISTER :
            result:=taicpu.op_reg_ref(A_SW,r,ref);
          else
            internalerror(200401041);
        end;
      end;


    procedure InitAsm;
      begin
      end;


    procedure DoneAsm;
      begin
      end;


begin
  cai_cpu   := taicpu;
  cai_align := tai_align;
end.
