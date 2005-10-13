{
    Copyright (c) 1998-2002 by Jonas Maebe, member of the Free Pascal
    Development Team

    This unit implements the PowerPC optimizer object

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


Unit aoptcpu;

Interface

{$i fpcdefs.inc}

uses cpubase, aoptobj, aoptcpub, aopt, aasmtai;

Type
  TCpuAsmOptimizer = class(TAsmOptimizer)
    { uses the same constructor as TAopObj }
    function PeepHoleOptPass1Cpu(var p: tai): boolean; override;

    function PostPeepHoleOptsCpu(var p: tai): boolean; override;

  End;

Implementation

  uses
    cutils, aasmcpu, cgbase;

  function TCpuAsmOptimizer.PeepHoleOptPass1Cpu(var p: tai): boolean;
    var
      next1, next2: tai;
      l1, l2: longint;
    begin
      result := false;
      case p.typ of
        ait_instruction:
          begin
            case taicpu(p).opcode of
              A_SRWI:
                begin
                  if getnextinstruction(p,next1) and
                     (next1.typ = ait_instruction) and
                     ((taicpu(next1).opcode = A_SLWI) or
                      (taicpu(next1).opcode = A_RLWINM)) and
                     (taicpu(next1).oper[0]^.reg = taicpu(p).oper[0]^.reg) and
                     (taicpu(next1).oper[1]^.reg = taicpu(p).oper[0]^.reg) then
                    case taicpu(next1).opcode of
                      A_SLWI:
                        begin
                          taicpu(p).opcode := A_RLWINM;
                          taicpu(p).ops := 5;
                          taicpu(p).loadconst(2,taicpu(next1).oper[2]^.val-taicpu(p).oper[2]^.val);
                          if (taicpu(p).oper[2]^.val < 0) then
                            begin
                              taicpu(p).loadconst(3,-taicpu(p).oper[2]^.val);
                              taicpu(p).loadconst(4,31-taicpu(next1).oper[2]^.val);
                              inc(taicpu(p).oper[2]^.val,32);
                            end
                          else
                            begin
                              taicpu(p).loadconst(3,0);
                              taicpu(p).loadconst(4,31-taicpu(next1).oper[2]^.val);
                            end;
                          asml.remove(next1);
                          next1.free;
                          result := true;
                        end;
                      A_RLWINM:
                        begin
                          if (taicpu(next1).oper[2]^.val = 0) then
                            begin
                              { convert srwi to rlwinm and see if the rlwinm }
                              { optimization can do something with it        }
                              taicpu(p).opcode := A_RLWINM;
                              taicpu(p).ops := 5;
                              taicpu(p).loadconst(3,taicpu(p).oper[2]^.val);
                              taicpu(p).loadconst(4,31);
                              taicpu(p).loadconst(2,(32-taicpu(p).oper[2]^.val) and 31);
                              result := true;
                            end;
                        end;
                    end;
                end;
              A_RLWINM:
                begin
                  if getnextinstruction(p,next1) and
                     (next1.typ = ait_instruction) and
                     (taicpu(next1).opcode = A_RLWINM) and
                     (taicpu(next1).oper[0]^.reg = taicpu(p).oper[0]^.reg) and
                     // both source and target of next1 must equal target of p
                     (taicpu(next1).oper[1]^.reg = taicpu(p).oper[0]^.reg) and
                     (taicpu(next1).oper[2]^.val = 0) then
                    begin
                      l1 := taicpu(p).oper[4]^.val;
                      if (l1 < taicpu(p).oper[3]^.val) then
                        inc(l1,32);
                      l2 := taicpu(next1).oper[4]^.val;
                      if (l2 < taicpu(next1).oper[3]^.val) then
                        inc(l2,32);

                      if (taicpu(p).oper[3]^.val > l2) or
                         (taicpu(next1).oper[3]^.val > l1) then
                        begin
                          // masks have no bits in common
                          taicpu(p).opcode := A_LI;
                          taicpu(p).loadconst(1,0);
                          taicpu(p).clearop(2);
                          taicpu(p).clearop(3);
                          taicpu(p).clearop(4);
                          taicpu(p).ops := 2;
                          taicpu(p).opercnt := 2;
                          asml.remove(next1);
                          next1.free;
                        end
                      else
                        // some of the cases with l1>32 or l2>32 can be
                        // optimized, but others can't (like 19,17 and 25,23)
                        if (l1 < 32) and
                           (l2 < 32) then
                        begin
                          taicpu(p).oper[3]^.val := max(taicpu(p).oper[3]^.val,taicpu(next1).oper[3]^.val);
                          taicpu(p).oper[4]^.val := min(taicpu(p).oper[4]^.val,taicpu(next1).oper[4]^.val);
                          asml.remove(next1);
                          next1.free;
                          result := true;
                        end;
                    end;
                end;
            end;
          end;
      end;
    end;


  const
    modifyflags: array[tasmop] of tasmop =
      (a_none, a_add_, a_add_, a_addo_, a_addo_, a_addc_, a_addc_, a_addco_, a_addco_,
      a_adde_, a_adde_, a_addeo_, a_addeo_, {a_addi could be addic_ if sure doesn't disturb carry} a_none, a_addic_, a_addic_, a_none,
      a_addme_, a_addme_, a_addmeo_, a_addmeo_, a_addze_, a_addze_, a_addzeo_,
      a_addzeo_, a_and_, a_and_, a_andc_, a_andc_, a_andi_, a_andis_, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_cntlzw_, a_cntlzw_, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_divw_, a_divw_, a_divwo_, a_divwo_,
      a_divwu_, a_divwu_, a_divwuo_, a_divwuo_, a_none, a_none, a_none, a_eqv_,
      a_eqv_, a_extsb_, a_extsb_, a_extsh_, a_extsh_, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_mffs, a_mffs_, a_mfmsr, a_mfspr, a_mfsr,
      a_mfsrin, a_mftb, a_mtcrf, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_mulhw_,
      a_mulhw_, a_mulhwu_, a_mulhwu_, a_none, a_mullw_, a_mullw_, a_mullwo_,
      a_mullwo_, a_nand_, a_nand_, a_neg_, a_neg_, a_nego_, a_nego_, a_nor_, a_nor_,
      a_or_, a_or_, a_orc_, a_orc_, a_none, a_none, a_none, a_rlwimi_, a_rlwimi_,
      a_rlwinm_, a_rlwinm_, a_rlwnm_, a_rlwnm_, a_none, a_slw_, a_slw_, a_sraw_, a_sraw_,
      a_srawi_, a_srawi_,a_srw_, a_srw_, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none, a_none, a_none, a_none, a_subf_, a_subf_, a_subfo_,
      a_subfo_, a_subfc_, a_subfc_, a_subfco_, a_subfco_, a_subfe_, a_subfe_,
      a_subfeo_, a_subfeo_, a_none, a_subfme_, a_subfme_, a_subfmeo_, a_subfmeo_,
      a_subfze_, a_subfze_, a_subfzeo_, a_subfzeo_, a_none, a_none, a_none,
      a_none, a_none, a_none, a_xor_, a_xor_, a_none, a_none,
      { simplified mnemonics }
      a_none, a_none, a_subic_, a_subic_, a_sub_, a_sub_, a_subo_, a_subo_,
      a_subc_, a_subc_, a_subco_, a_subco_, a_none, a_none, a_none, a_none,
      a_extlwi_, a_extlwi_, a_extrwi_, a_extrwi_, a_inslwi_, a_inslwi_, a_insrwi_,
      a_insrwi_, a_rotlwi_, a_rotlwi_, a_rotlw_, a_rotlw_, a_slwi_, a_slwi_,
      a_srwi_, a_srwi_, a_clrlwi_, a_clrlwi_, a_clrrwi_, a_clrrwi_, a_clrslwi_,
      a_clrslwi_, a_none, a_none, a_none, a_none, a_none, a_none, a_none,
      a_none, a_none {move to special prupose reg}, a_none {move from special purpose reg},
      a_none, a_none, a_none, a_none, a_mr_, a_mr_, a_not_, a_not_, a_none, a_none, a_none,
      a_none, a_none);

  function changetomodifyflags(p: taicpu): boolean;
    begin
      result := false;
      if (modifyflags[p.opcode] <> a_none) then
        begin
          p.opcode := modifyflags[p.opcode];
          result := true;
        end;
    end;



  function TCpuAsmOptimizer.PostPeepHoleOptsCpu(var p: tai): boolean;
    var
      next1: tai;
    begin
      result := false;
      case p.typ of
        ait_instruction:
          begin
            case taicpu(p).opcode of
              A_RLWINM_:
                begin
                  // rlwinm_ is cracked on the G5, andi_/andis_ aren't
                  if (taicpu(p).oper[2]^.val = 0) then
                    if (taicpu(p).oper[3]^.val < 16) and
                       (taicpu(p).oper[4]^.val < 16) then
                      begin
                        taicpu(p).opcode := A_ANDIS_;
                        taicpu(p).oper[2]^.val :=
                          ((1 shl (16-taicpu(p).oper[3]^.val)) - 1) and
                          not((1 shl (15-taicpu(p).oper[4]^.val)) - 1);
                        taicpu(p).clearop(3);
                        taicpu(p).clearop(4);
                        taicpu(p).ops := 3;
                        taicpu(p).opercnt := 2;
                      end
                    else if (taicpu(p).oper[3]^.val >= 16) and
                       (taicpu(p).oper[4]^.val >= 16) then
                      begin
                        taicpu(p).opcode := A_ANDI_;
                        taicpu(p).oper[2]^.val :=
                          ((1 shl (32-taicpu(p).oper[3]^.val)) - 1) and
                          not((1 shl (31-taicpu(p).oper[4]^.val)) - 1);
                        taicpu(p).clearop(3);
                        taicpu(p).clearop(4);
                        taicpu(p).ops := 3;
                        taicpu(p).opercnt := 2;
                      end;
                end;
            end;

            // change "integer operation with destination reg" followed by a
            // comparison to zero of that reg, with a variant of that integer
            // operation which sets the flags (if it exists)
            if not(result) and
               (taicpu(p).ops >= 2) and
               (taicpu(p).oper[0]^.typ = top_reg) and
               (taicpu(p).oper[1]^.typ = top_reg) and
               getnextinstruction(p,next1) and
               (next1.typ = ait_instruction) and
               (taicpu(next1).opcode = A_CMPWI) and
               // make sure it the result goes to cr0
               (((taicpu(next1).ops = 2) and
                 (taicpu(next1).oper[1]^.val = 0) and
                 (taicpu(next1).oper[0]^.reg = taicpu(p).oper[0]^.reg)) or
                ((taicpu(next1).ops = 3) and
                 (taicpu(next1).oper[2]^.val = 0) and
                 (taicpu(next1).oper[0]^.typ = top_reg) and
                 (getsupreg(taicpu(next1).oper[0]^.reg) = RS_CR0) and
                 (taicpu(next1).oper[1]^.reg = taicpu(p).oper[0]^.reg))) and
               changetomodifyflags(taicpu(p)) then
              begin
                asml.remove(next1);
                next1.free;
                result := true;
              end;
          end;
      end;
    end;

begin
  casmoptimizer:=TCpuAsmOptimizer;
End.
