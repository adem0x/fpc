{
    Copyright (c) 2014 by Jeppe Johansen

    This unit calls the optimization procedures to optimize the assembler
    code for Risc-V. Adapted from other peephole optimizer codebases.

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

unit aoptcpu;

{$i fpcdefs.inc}

{$define DEBUG_AOPTCPU}

  Interface

    uses
      cgbase, cpubase, aoptobj, aoptcpub, aopt, aasmtai, aasmcpu;

    Type

      TCpuAsmOptimizer = class(TAsmOptimizer)
        function RegUsedAfterInstruction(reg: Tregister; p: tai;
                                         var AllUsedRegs: TAllUsedRegs): Boolean;
        { returns true if reg reaches it's end of life at p, this means it is either
          reloaded with a new value or it is deallocated afterwards }
        function RegEndOfLife(reg: TRegister;p: taicpu): boolean;

        function RemoveRedundant(var p: tai): boolean;
        function PeepHoleOptPass1Cpu(var p: tai): boolean; override;

        { outputs a debug message into the assembler file }
        procedure DebugMsg(const s: string; p: tai);
      private
        function GetNextInstructionUsingReg(Current: tai; out Next: tai; reg: TRegister): Boolean;
      End;

  Implementation

    uses
      globals,aasmbase,cpuinfo,verbose,
      globtype,
      cutils;


    const
      might_have_sideeffects : set of TAsmOp = [A_FENCE,A_FENCE_I,
                                                A_SCALL,A_SBREAK,
                                                A_RDCYCLE,A_RDCYCLEH,A_RDTIME,A_RDTIMEH,A_RDINSTRET,A_RDINSTRETH,
                                                A_SB,A_SH,A_SW,
                                                A_JAL,A_JALR,A_Bcc];


  function regLoadedWithNewValue(reg: tregister; hp: tai): boolean;
    var
      p: taicpu;
    begin
      p := taicpu(hp);
      regLoadedWithNewValue := false;
      if not ((assigned(hp)) and (hp.typ = ait_instruction)) then
        exit;

      case p.opcode of
        A_SB,A_SH,A_SW,
        A_FENCE,A_FENCE_I,
        A_SCALL,A_SBREAK,
        A_Bcc:
          exit;
      end;

      if (taicpu(hp).ops>=1) and
         (taicpu(hp).spilling_get_operation_type(0) in [operand_readwrite,operand_write]) and
         (taicpu(hp).oper[0]^.typ=top_reg) and
         (taicpu(hp).oper[0]^.reg=reg) then
        regLoadedWithNewValue:=true;
    end;


  function instructionLoadsFromReg(const reg: TRegister; const hp: tai): boolean;
    var
      p: taicpu;
      i: longint;
    begin
      instructionLoadsFromReg := false;
      if not (assigned(hp) and (hp.typ = ait_instruction)) then
        exit;
      p:=taicpu(hp);

      i:=1;
      {For these instructions we have to start on oper[0]}
      if (p.opcode in [A_SB,A_SW,A_SH]) then i:=0;

      while(i<p.ops) do
        begin
          case p.oper[I]^.typ of
            top_reg:
              instructionLoadsFromReg := (p.oper[I]^.reg = reg);
            top_ref:
              instructionLoadsFromReg :=
                (p.oper[I]^.ref^.base = reg) or
                (p.oper[I]^.ref^.index = reg);
          end;
          if instructionLoadsFromReg then exit; {Bailout if we found something}
          Inc(I);
        end;
    end;


{$ifdef DEBUG_AOPTCPU}
  procedure TCpuAsmOptimizer.DebugMsg(const s: string;p : tai);
    begin
      asml.insertbefore(tai_comment.Create(strpnew(s)), p);
    end;
{$else DEBUG_AOPTCPU}
  procedure TCpuAsmOptimizer.DebugMsg(const s: string;p : tai);inline;
    begin
    end;
{$endif DEBUG_AOPTCPU}


  function TCpuAsmOptimizer.RegUsedAfterInstruction(reg: Tregister; p: tai; var AllUsedRegs: TAllUsedRegs): Boolean;
    begin
      AllUsedRegs[getregtype(reg)].Update(tai(p.Next),true);
      RegUsedAfterInstruction :=
        AllUsedRegs[getregtype(reg)].IsUsed(reg) and
        not(regLoadedWithNewValue(reg,p)) and
        (
          not(GetNextInstruction(p,p)) or
          instructionLoadsFromReg(reg,p) or
          not(regLoadedWithNewValue(reg,p))
        );
    end;


  function TCpuAsmOptimizer.RegEndOfLife(reg : TRegister;p : taicpu) : boolean;
    begin
       Result:=assigned(FindRegDealloc(reg,tai(p.Next))) or
         RegLoadedWithNewValue(reg,p);
    end;


  function TCpuAsmOptimizer.GetNextInstructionUsingReg(Current: tai;
    Out Next: tai; reg: TRegister): Boolean;
    begin
      Next:=Current;
      repeat
        Result:=GetNextInstruction(Next,Next);
      until not (Result) or
            not(cs_opt_level3 in current_settings.optimizerswitches) or
            (Next.typ<>ait_instruction) or
            RegInInstruction(reg,Next) or
            is_calljmp(taicpu(Next).opcode);
    end;


  function TCpuAsmOptimizer.RemoveRedundant(var p: tai): boolean;
    var
      hp1: tai;
    begin
      result:=false;

      if p.typ<>ait_instruction then
        exit;

      if taicpu(p).opcode in might_have_sideeffects then
        exit;

      if (taicpu(p).ops>=1) and
         (taicpu(p).oper[0]^.typ=top_reg) and
         GetNextInstruction(p,hp1) and
         (hp1.typ=ait_instruction) and
         regLoadedWithNewValue(taicpu(p).oper[0]^.reg, taicpu(hp1)) and
         (not instructionLoadsFromReg(taicpu(p).oper[0]^.reg, taicpu(hp1))) then
        begin
          DebugMsg('Removed redundant instruction', p);

          asml.remove(p);
          p.free;

          p:=hp1;

          result:=true;
        end;
    end;


  function TCpuAsmOptimizer.PeepHoleOptPass1Cpu(var p: tai): boolean;
    var
      hp1, hp2: tai;
    begin
      result:=false;
      case p.typ of
        ait_instruction:
          begin
            case taicpu(p).opcode of
              A_SLT:
                begin
                  {
                    Turn the common
                      SLT xX, xY, xZ
                      BNE xX, x0, ...
                      dealloc xX
                    Into
                      BLT xY, xZ, ...
                  }
                  if (taicpu(p).ops=3) and
                     GetNextInstructionUsingReg(p,hp1,taicpu(p).oper[0]^.reg) and
                     (hp1.typ=ait_instruction) and
                     (taicpu(hp1).opcode=A_Bcc) and
                     (taicpu(hp1).condition=C_NE) and
                     (taicpu(p).oper[0]^.reg=taicpu(hp1).oper[0]^.reg) and
                     (taicpu(hp1).oper[1]^.reg=NR_X0) and
                     assigned(FindRegDeAlloc(taicpu(p).oper[0]^.reg,tai(hp1.next))) and
                     (not RegModifiedBetween(taicpu(p).oper[1]^.reg,p,hp1)) and
                     (not RegModifiedBetween(taicpu(p).oper[2]^.reg,p,hp1)) then
                    begin
                      DebugMsg('Peephole SltBne2Blt performed',p);

                      taicpu(hp1).oper[0]^.reg:=taicpu(p).oper[1]^.reg;
                      taicpu(hp1).oper[1]^.reg:=taicpu(p).oper[2]^.reg;

                      taicpu(hp1).condition:=C_LT;

                      GetNextInstruction(p,hp1);

                      asml.remove(p);
                      p.Free;

                      p:=hp1;

                      result:=true;
                    end
                  else
                    result:=RemoveRedundant(p);
                end;
              A_MOVE:
                begin
                  {
                    Remove
                      move xX, xX
                  }
                  if (taicpu(p).ops=2) and
                     (taicpu(p).oper[0]^.reg=taicpu(p).oper[1]^.reg) then
                    begin
                      GetNextInstruction(p,hp1);

                      DebugMsg('Redundant move removed', p);

                      AsmL.Remove(p);
                      p.Free;

                      p:=hp1;

                      result:=true;
                    end
                  {
                    Turn
                      move xX, xY
                      move xY, xX
                    Into
                      move xX, xY
                  }
                  else if (taicpu(p).ops=2) and
                          //GetNextInstructionUsingReg(p,hp1,taicpu(p).oper[0]^.reg) and
                          GetNextInstruction(p,hp1) and
                          (hp1.typ=ait_instruction) and
                          (taicpu(hp1).opcode=A_MOVE) and
                          (taicpu(hp1).oper[1]^.reg=taicpu(p).oper[0]^.reg) and
                          (taicpu(p).oper[1]^.reg=taicpu(hp1).oper[0]^.reg) {and
                          (not RegModifiedBetween(taicpu(p).oper[1]^.reg,p,hp1))} then
                    begin
                      DebugMsg('Peephole MoveMove2Move performed', p);

                      AsmL.Remove(hp1);
                      hp1.Free;

                      result:=true;
                    end
                  else
                    result:=RemoveRedundant(p);
                end;
              A_ADDI:
                begin
                  { Remove addi xx,xx,0 }
                  if (taicpu(p).ops=3) and
                     (taicpu(p).oper[2]^.typ=top_const) and
                     (taicpu(p).oper[2]^.val=0) and
                     (taicpu(p).oper[0]^.reg=taicpu(p).oper[1]^.reg) then
                    begin
                      GetNextInstruction(p,hp1);

                      DebugMsg('Peephole addi removed', p);

                      AsmL.Remove(p);
                      p.Free;

                      p:=hp1;

                      result:=true;
                    end
                  {
                    Turn
                      addi xx, x0, #imm
                      andi xy, xx, #imm
                    Into
                      addi xx, x0, #imm
                      addi xy, xx, #0
                  }
                  else if (taicpu(p).ops=3) and
                          (taicpu(p).oper[2]^.typ=top_const) and
                          (taicpu(p).oper[1]^.reg=NR_X0) and
                          GetNextInstructionUsingReg(p,hp1,taicpu(p).oper[0]^.reg) and
                          (hp1.typ=ait_instruction) and
                          (taicpu(hp1).opcode=A_ANDI) and
                          (taicpu(hp1).ops=3) and
                          (taicpu(hp1).oper[2]^.typ=top_const) and
                          (taicpu(hp1).oper[1]^.reg=taicpu(p).oper[0]^.reg) and
                          RegEndOfLife(taicpu(p).oper[0]^.reg, taicpu(hp1)) and
                          ((taicpu(p).oper[2]^.val and taicpu(hp1).oper[2]^.val)=taicpu(p).oper[2]^.val) then
                    begin
                      DebugMsg('Peephole AddiAndi2AddiAddi performed', p);

                      taicpu(hp1).opcode:=A_ADDI;
                      taicpu(hp1).loadconst(2,0);

                      result:=true;
                    end
                  else
                    result:=RemoveRedundant(p);
                end;
              A_LUI:
                begin
                  {
                    Turn
                      lui xX, #immX
                      ori xY, xX, #immY
                      l* xZ, #immZ(xY)
                    Into
                      lui xX, #imm
                      move xY, xX
                      l* xZ, #immZ | #immY(xY)
                  }
                  if (taicpu(p).ops=2) and
                     (taicpu(p).oper[0]^.typ=top_reg) and
                     GetNextInstructionUsingReg(p,hp1,taicpu(p).oper[0]^.reg) and
                     (hp1.typ=ait_instruction) and
                     (taicpu(hp1).opcode=A_ORI) and
                     (taicpu(hp1).ops=3) and
                     (taicpu(hp1).oper[2]^.typ=top_const) and
                     (taicpu(hp1).oper[1]^.reg=taicpu(p).oper[0]^.reg) and
                     GetNextInstructionUsingReg(hp1,hp2,taicpu(hp1).oper[0]^.reg) and
                     (hp2.typ=ait_instruction) and
                     (taicpu(hp2).opcode in [A_LW,A_LH,A_LB,A_LHU,A_LBU, A_SW,A_SH,A_SB]) and
                     (taicpu(hp2).oper[1]^.typ=top_ref) and
                     ((taicpu(hp2).oper[1]^.ref^.base=taicpu(hp1).oper[0]^.reg) or
                      (taicpu(hp2).oper[1]^.ref^.index=taicpu(hp1).oper[0]^.reg)) then
                    begin
                      DebugMsg('Peephole LuiOriMem2LuiMoveMem performed', p);

                      taicpu(hp2).oper[1]^.ref^.offset:=taicpu(hp2).oper[1]^.ref^.offset or taicpu(hp1).oper[2]^.val;

                      taicpu(hp1).ops:=2;
                      taicpu(hp1).opcode:=A_MOVE;

                      result:=true;
                    end
                  else
                    result:=RemoveRedundant(p);
                end;
              A_SRLI:
                begin
                  {
                    Turn
                      srli xX, xY, #s
                      slli xX, xX, #s
                      srli xZ, xX, #s
                    Into
                      srli xX, xY, #s
                      move xZ, xX
                  }
                  if GetNextInstruction(p,hp1) and
                     (hp1.typ=ait_instruction) and
                     (taicpu(hp1).opcode=A_SLLI) and
                     (taicpu(hp1).oper[0]^.reg=taicpu(p).oper[0]^.reg) and
                     (taicpu(hp1).oper[1]^.reg=taicpu(p).oper[0]^.reg) and
                     (taicpu(hp1).oper[2]^.val=taicpu(p).oper[2]^.val) and
                     GetNextInstruction(hp1,hp2) and
                     (hp2.typ=ait_instruction) and
                     (taicpu(hp2).opcode=A_SRLI) and
                     (taicpu(hp2).oper[1]^.reg=taicpu(p).oper[0]^.reg) and
                     (taicpu(hp2).oper[2]^.val=taicpu(p).oper[2]^.val) then
                    begin
                      DebugMsg('Peephole SrlSllSrl2SrlMove performed', p);

                      asml.remove(hp1);
                      hp1.Free;

                      taicpu(hp2).opcode:=A_MOVE;
                      taicpu(hp2).ops:=2;

                      result:=true;
                    end
                  {
                    Turn
                      srli xX, xY, #a
                      srli xZ, xX, #b
                    Into
                      srli xZ, xY, #a+b
                  }
                  else if GetNextInstructionUsingReg(p,hp1,taicpu(p).oper[0]^.reg) and
                          (hp1.typ=ait_instruction) and
                          (taicpu(hp1).opcode=A_SRLI) and
                          (taicpu(p).oper[1]^.reg<>taicpu(p).oper[0]^.reg) and
                          (taicpu(hp1).oper[1]^.reg=taicpu(p).oper[0]^.reg) and
                          (not RegModifiedBetween(taicpu(p).oper[1]^.reg,p,hp1)) then
                    begin
                      DebugMsg('Peephole SrliSrli2SplitSrli performed', p);

                      taicpu(hp1).oper[1]^.reg:=taicpu(p).oper[1]^.reg;
                      taicpu(hp1).oper[2]^.val:=taicpu(hp1).oper[2]^.val+taicpu(p).oper[2]^.val;

                      result:=true;
                    end
                  {
                    Turn
                      srli xX, xY, #a
                      srli xX, xX, #b
                    Into
                      srli xX, xY, #a+b
                  }
                  else if GetNextInstruction(p,hp1) and
                          (hp1.typ=ait_instruction) and
                          (taicpu(hp1).opcode=A_SRLI) and
                          (taicpu(hp1).oper[1]^.reg=taicpu(p).oper[0]^.reg) and
                          (taicpu(hp1).oper[0]^.reg=taicpu(p).oper[0]^.reg) then
                    begin
                      DebugMsg('Peephole SrliSrli2Srli performed', p);

                      taicpu(p).oper[2]^.val:=taicpu(hp1).oper[2]^.val+taicpu(p).oper[2]^.val;

                      asml.remove(hp1);
                      hp1.Free;

                      result:=true;
                    end
                  {
                    Turn
                      srli xX, xX, #a
                      srli xY, xX, #b
                    Into
                      srli xY, xX, #a+b
                      srli xX, xX, #a
                  }
                  else if GetNextInstruction(p,hp1) and
                          (hp1.typ=ait_instruction) and
                          (taicpu(hp1).opcode=A_SRLI) and
                          (taicpu(p).oper[1]^.reg=taicpu(p).oper[0]^.reg) and
                          (taicpu(hp1).oper[1]^.reg=taicpu(p).oper[0]^.reg) and
                          (taicpu(hp1).oper[0]^.reg<>taicpu(p).oper[1]^.reg) then
                    begin
                      DebugMsg('Peephole SrliSrli2SrliSrliSwap performed', p);

                      taicpu(p).oper[2]^.val:=taicpu(hp1).oper[2]^.val+taicpu(p).oper[2]^.val;
                      taicpu(p).loadreg(0,taicpu(hp1).oper[0]^.reg);

                      taicpu(hp1).loadreg(0,taicpu(hp1).oper[1]^.reg);

                      result:=true;
                    end
                  {
                    Turn
                      srli xX, xY, #a
                      andi xZ, xX, #b
                    Into
                      srli xX, xY, #a
                      move xZ, xX
                  }
                  else if GetNextInstructionUsingReg(p,hp1,taicpu(p).oper[0]^.reg) and
                          (hp1.typ=ait_instruction) and
                          (taicpu(hp1).opcode=A_ANDI) and
                          (taicpu(hp1).oper[1]^.reg=taicpu(p).oper[0]^.reg) and
                          (((longword($FFFFFFFF) shr taicpu(p).oper[2]^.val) and taicpu(hp1).oper[2]^.val)=(longword($FFFFFFFF) shr taicpu(p).oper[2]^.val)) then
                    begin
                      DebugMsg('Peephole SrliAndi2SrliMove performed', p);

                      taicpu(hp1).ops:=2;
                      taicpu(hp1).opcode:=A_MOVE;

                      result:=true;
                    end
                  else
                    result:=RemoveRedundant(p);
                end
              else
                result:=RemoveRedundant(p);
            end;
          end;
      end;
    end;

begin
  casmoptimizer:=TCpuAsmOptimizer;
end.
