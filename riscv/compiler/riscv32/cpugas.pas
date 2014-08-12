{
    Copyright (c) 1999-2009 by Florian Klaempfl and David Zhang

    This unit implements an asmoutput class for RISC-V assembly syntax

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
unit cpugas;

{$i fpcdefs.inc}

  interface

    uses
      cpubase, aasmbase, globtype,
      aasmtai, aasmcpu, assemble, aggas;

    type
      TRISCVassembler = class(TGNUassembler)
        constructor create(smart: boolean); override;
        {# Constructs the command line for calling the assembler }
        function MakeCmdLine: TCmdStr; override;
      end;

      TRISCVInstrWriter = class(TCPUInstrWriter)
        procedure WriteInstruction(hp : tai);override;
      end;

    const
      use_std_regnames : boolean = false;

  implementation

    uses
      cutils, systems, cpuinfo,
      globals, verbose, itcpugas, cgbase, cgutils;


      function asm_regname(reg : TRegister) : string;

        begin
          if use_std_regnames then
            asm_regname:='$'+std_regname(reg)
          else
            asm_regname:='x'+gas_regname(reg);
        end;

{****************************************************************************}
{                         GNU MIPS  Assembler writer                           }
{****************************************************************************}

    constructor TRISCVassembler.create(smart: boolean);
      begin
        inherited create(smart);
        InstrWriter := TRISCVInstrWriter.create(self);
      end;

    function TRISCVassembler.MakeCmdLine: TCmdStr;
      begin
         result := Inherited MakeCmdLine;
      end;

{****************************************************************************}
{                  Helper routines for Instruction Writer                    }
{****************************************************************************}

    function GetReferenceString(var ref: TReference): string;
      var
        reg: TRegister;
        regstr: string;
      begin
        result:='';
        if assigned(ref.symbol) then
          result:=ref.symbol.name;
        if (ref.offset<0) then
          result:=result+tostr(ref.offset)
        else if (ref.offset>0) then
          begin
            if assigned(ref.symbol) then
              result:=result+'+';
            result:=result+tostr(ref.offset);
          end
        { asmreader appears to treat literal numbers as references }
        else if (ref.symbol=nil) and (ref.base=NR_NO) and (ref.index=NR_NO) then
          result:='0';

        { either base or index may be present, but not both }
        reg:=ref.base;
        if (reg=NR_NO) then
          reg:=ref.index
        else if (ref.index<>NR_NO) then
          InternalError(2013013001);

        if (reg=NR_NO) then
          regstr:=''
        else
          regstr:='('+asm_regname(reg)+')';

        case ref.refaddr of
          addr_no,
          addr_full:
            if assigned(ref.symbol) and (reg<>NR_NO) then
              InternalError(2013013002)
            else
              begin
                result:=result+regstr;
                exit;
              end;
          addr_pic:
            result:='%got('+result;
          addr_high:
            result:='%hi('+result;
          addr_low:
            result:='%lo('+result;
        else
          InternalError(2013013003);
        end;

        result:=result+')'+regstr;
      end;


    function getopstr(const Oper: TOper): string;
      begin
        with Oper do
          case typ of
            top_reg:
              getopstr := asm_regname(reg);
            top_const:
              getopstr := tostr(longint(val));
            top_ref:
              getopstr := getreferencestring(ref^);
            else
              internalerror(10001);
          end;
      end;


    procedure TRISCVInstrWriter.WriteInstruction(hp: Tai);
      var
        Op: TAsmOp;
        s,s1:  string;
        i:  integer;
        tmpfpu: string;
        tmpfpu_len: longint;
        r: TRegister;
      begin
        if hp.typ <> ait_instruction then
          exit;
        op := taicpu(hp).opcode;

        s := #9 + gas_op2str[op] + cond2str[taicpu(hp).condition];
        if taicpu(hp).ops > 0 then
        begin
          s := s + #9 + getopstr(taicpu(hp).oper[0]^);
          for i := 1 to taicpu(hp).ops - 1 do
            s := s + ',' + getopstr(taicpu(hp).oper[i]^);
        end;
        owner.AsmWriteLn(s);
      end;


    const
      as_riscv_as_info: tasminfo =
        (
        id: as_gas;
        idtxt: 'AS';
        asmbin: 'as';
        asmcmd: '-m32 -o $OBJ $EXTRAOPT $ASM';
        supported_targets: [system_riscv32_linux,system_riscv32_embedded];
        flags: [ af_needar, af_smartlink_sections];
        labelprefix: '.L';
        comment: '# ';
        dollarsign: '$';
        );

begin
  RegisterAssembler(as_riscv_as_info, TRISCVassembler);
end.
