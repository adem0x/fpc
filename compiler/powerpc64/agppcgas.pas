{
    Copyright (c) 1998-2002 by Florian Klaempfl

    This unit implements an asm for the PowerPC64. Heavily based on the one
    from the PowerPC architecture.

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
{ This unit implements the GNU Assembler writer for the PowerPC
}

unit agppcgas;

{$I fpcdefs.inc}

interface

uses
  aasmtai,
  aggas,
  cpubase;

type
  TPPCGNUAssembler = class(TGNUassembler)
  public
    constructor create(smart: boolean); override;
    procedure WriteExtraHeader; override;
  end;

  TPPCInstrWriter = class(TCPUInstrWriter)
    procedure WriteInstruction(hp: tai); override;
  end;


implementation

uses
  cutils, globals, verbose,
  cgbase, cgutils, systems,
  assemble, globtype, fmodule,
  itcpugas, finput,
  aasmcpu;


{****************************************************************************}
{                         GNU PPC Assembler writer                           }
{****************************************************************************}

constructor TPPCGNUAssembler.create(smart: boolean);
  begin
    inherited create(smart);
    InstrWriter := TPPCInstrWriter.create(self);
  end;


procedure TPPCGNUAssembler.WriteExtraHeader;
var
  i: longint;
begin
  for i := 0 to 31 do
    AsmWriteln(#9'.set'#9'r' + tostr(i) + ',' + tostr(i));
  for i := 0 to 31 do
    AsmWriteln(#9'.set'#9'f' + tostr(i) + ',' + tostr(i));
end;

{****************************************************************************}
{                  Helper routines for Instruction Writer                    }
{****************************************************************************}

const
  refaddr2str: array[trefaddr] of string[9] = ('', '', '', '@l', '@h', '@higher', '@highest', '@ha', '@highera', '@highesta');

function getreferencestring(var ref: treference): string;
var
  s: string;
begin
  with ref do
  begin
    if ((offset < -32768) or (offset > 32767)) and
      (refaddr = addr_no) then
      ; //internalerror(19991);
    if (refaddr = addr_no) then
      s := ''
    else
    begin
      s := '(';
      if assigned(symbol) then
      begin
        s := s + symbol.name;
        if assigned(relsymbol) then
          s := s + '-' + relsymbol.name;
      end;
    end;
    if offset < 0 then
      s := s + tostr(offset)
    else if (offset > 0) then
    begin
      if assigned(symbol) then
        s := s + '+' + tostr(offset)
      else
        s := s + tostr(offset);
    end;

    if (refaddr in [addr_low, addr_high, addr_higher, addr_highest, addr_higha, addr_highera, addr_highesta]) then
    begin
      s := s + ')';
      if (target_info.system <> system_powerpc_darwin) then
        s := s + refaddr2str[refaddr];
    end;
    if (refaddr = addr_pic) then s := s + ')';

    if (index = NR_NO) and (base <> NR_NO) then
    begin
      if offset = 0 then
      begin
        if not (assigned(symbol)) then
          s := s + '0';
      end;
      s := s + '(' + gas_regname(base) + ')';
    end
    else if (index <> NR_NO) and (base <> NR_NO) then
    begin
      if (offset = 0) then
        s := s + gas_regname(base) + ',' + gas_regname(index)
      else
        internalerror(19992);
    end;
  end;
  getreferencestring := s;
end;

function getopstr_jmp(const o: toper): string;
var
  hs: string;
begin
  case o.typ of
    top_reg:
      getopstr_jmp := gas_regname(o.reg);
    { no top_ref jumping for powerpc }
    top_const:
      getopstr_jmp := tostr(o.val);
    top_ref:
      begin
        if o.ref^.refaddr <> addr_full then
          internalerror(200402262);
        hs := o.ref^.symbol.name;
        if o.ref^.offset > 0 then
          hs := hs + '+' + tostr(o.ref^.offset)
        else if o.ref^.offset < 0 then
          hs := hs + tostr(o.ref^.offset);
        getopstr_jmp := hs;
      end;
    top_none:
      getopstr_jmp := '';
  else
    internalerror(2002070603);
  end;
end;

function getopstr(const o: toper): string;
var
  hs: string;
begin
  case o.typ of
    top_reg:
      getopstr := gas_regname(o.reg);
    top_const:
      getopstr := tostr(longint(o.val));
    top_ref:
      if o.ref^.refaddr = addr_full then
      begin
        hs := o.ref^.symbol.name;
        if o.ref^.offset > 0 then
          hs := hs + '+' + tostr(o.ref^.offset)
        else if o.ref^.offset < 0 then
          hs := hs + tostr(o.ref^.offset);
        getopstr := hs;
      end
      else
        getopstr := getreferencestring(o.ref^);
  else
    internalerror(2002070604);
  end;
end;

function branchmode(o: tasmop): string[4];
var
  tempstr: string[4];
begin
  tempstr := '';
  case o of
    A_BCCTR, A_BCCTRL: tempstr := 'ctr';
    A_BCLR, A_BCLRL: tempstr := 'lr';
  end;
  case o of
    A_BL, A_BLA, A_BCL, A_BCLA, A_BCCTRL, A_BCLRL: tempstr := tempstr + 'l';
  end;
  case o of
    A_BA, A_BLA, A_BCA, A_BCLA: tempstr := tempstr + 'a';
  end;
  branchmode := tempstr;
end;

function cond2str(op: tasmop; c: tasmcond): string;
{ note: no checking is performed whether the given combination of }
{ conditions is valid                                             }
var
  tempstr: string;
begin
  tempstr := #9;
  case c.simple of
    false:
      begin
        cond2str := tempstr + gas_op2str[op];
        case c.dirhint of
          DH_None: ;
          DH_Minus:
            cond2str := cond2str + '-';
          DH_Plus:
            cond2str := cond2str + '+';
        else
          internalerror(2003112901);
        end;
        cond2str := cond2str + #9 + tostr(c.bo) + ',' + tostr(c.bi);
      end;
    true:
      if (op >= A_B) and (op <= A_BCLRL) then
        case c.cond of
          { unconditional branch }
          C_NONE:
            cond2str := tempstr + gas_op2str[op];
          { bdnzt etc }
        else
          begin
            tempstr := tempstr + 'b' + asmcondflag2str[c.cond] +
              branchmode(op);
            case c.dirhint of
              DH_None:
                tempstr := tempstr + #9;
              DH_Minus:
                tempstr := tempstr + ('-' + #9);
              DH_Plus:
                tempstr := tempstr + ('+' + #9);
            else
              internalerror(2003112901);
            end;
            case c.cond of
              C_LT..C_NU:
                cond2str := tempstr + gas_regname(newreg(R_SPECIALREGISTER,
                  c.cr, R_SUBWHOLE));
              C_T, C_F, C_DNZT, C_DNZF, C_DZT, C_DZF:
                cond2str := tempstr + tostr(c.crbit);
            else
              cond2str := tempstr;
            end;
          end;
        end
          { we have a trap instruction }
      else
      begin
        internalerror(2002070601);
        { not yet implemented !!!!!!!!!!!!!!!!!!!!! }
        { case tempstr := 'tw';}
      end;
  end;
end;


{****************************************************************************}
{                        PowerPC Instruction Writer                          }
{****************************************************************************}

procedure TPPCInstrWriter.WriteInstruction(hp: tai);
var
  op: TAsmOp;
  s: string;
  i: byte;
  sep: string[3];
begin
  op := taicpu(hp).opcode;
  if is_calljmp(op) then
  begin
    { direct BO/BI in op[0] and op[1] not supported, put them in condition! }
    case op of
      A_BL :
        s := #9 + gas_op2str[op] + #9;
      A_B, A_BA, A_BLA:
        s := #9 + gas_op2str[op] + #9;
      A_BCTR, A_BCTRL, A_BLR, A_BLRL:
        s := #9 + gas_op2str[op]
    else
      begin
        s := cond2str(op, taicpu(hp).condition);
        if (s[length(s)] <> #9) and
        (taicpu(hp).ops > 0) then
          s := s + ',';
      end;
    end;

    if (taicpu(hp).ops > 0) and (taicpu(hp).oper[0]^.typ <> top_none) then
    begin
      { first write the current contents of s, because the symbol }
      { may be 255 characters                                     }
      owner.AsmWrite(s);
      s := getopstr_jmp(taicpu(hp).oper[0]^);
    end;
  end
  else
    { process operands }
  begin
    s := #9 + gas_op2str[op];
    if taicpu(hp).ops <> 0 then
    begin
      {
        if not is_calljmp(op) then
          sep:=','
        else
      }
      sep := #9;
      for i := 0 to taicpu(hp).ops - 1 do
      begin
        // debug code
        // writeln(s);
        // writeln(taicpu(hp).fileinfo.line);
        s := s + sep + getopstr(taicpu(hp).oper[i]^);
        sep := ',';
      end;
    end;
  end;
  owner.AsmWriteLn(s);
end;


const
  as_ppc_gas_info: tasminfo =
  (
    id: as_gas;

    idtxt: 'AS';
    asmbin: 'as';
    asmcmd: '-a64 -o $OBJ $ASM';
    supported_target: system_any;
    flags: [af_allowdirect, af_needar, af_smartlink_sections];
    labelprefix: '.L';
    comment: '# ';
    );


begin
  RegisterAssembler(as_ppc_gas_info, TPPCGNUAssembler);
end.
