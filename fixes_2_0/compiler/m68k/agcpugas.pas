{
    Copyright (c) 1998-2002 by Florian Klaempfl

    This unit implements an asmoutput class for m68k GAS syntax

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
{ This unit implements an asmoutput class for i386 AT&T syntax
}
unit agcpugas;

{$i fpcdefs.inc}

interface

    uses
      cclasses,cpubase,
      globals,
      aasmbase,aasmtai,aasmcpu,assemble,aggas;

    type
      TM68kAssembler=class(TGNUassembler)
      public
        procedure WriteInstruction(hp: tai);override;
      end;

    const
      gas_op2str:op2strtable=
    {  warning: CPU32 opcodes are not fully compatible with the MC68020. }
       { 68000 only opcodes }
       ('abcd',
         'add','adda','addi','addq','addx','and','andi',
         'asl','asr','bcc','bcs','beq','bge','bgt','bhi',
         'ble','bls','blt','bmi','bne','bpl','bvc','bvs',
         'bchg','bclr','bra','bset','bsr','btst','chk',
         'clr','cmp','cmpa','cmpi','cmpm','dbcc','dbcs','dbeq','dbge',
         'dbgt','dbhi','dble','dbls','dblt','dbmi','dbne','dbra',
         'dbpl','dbt','dbvc','dbvs','dbf','divs','divu',
         'eor','eori','exg','illegal','ext','jmp','jsr',
         'lea','link','lsl','lsr','move','movea','movei','moveq',
         'movem','movep','muls','mulu','nbcd','neg','negx',
         'nop','not','or','ori','pea','rol','ror','roxl',
         'roxr','rtr','rts','sbcd','scc','scs','seq','sge',
         'sgt','shi','sle','sls','slt','smi','sne',
         'spl','st','svc','svs','sf','sub','suba','subi','subq',
         'subx','swap','tas','trap','trapv','tst','unlk',
         'rte','reset','stop',
         { mc68010 instructions }
         'bkpt','movec','moves','rtd',
         { mc68020 instructions }
         'bfchg','bfclr','bfexts','bfextu','bfffo',
         'bfins','bfset','bftst','callm','cas','cas2',
         'chk2','cmp2','divsl','divul','extb','pack','rtm',
         'trapcc','tracs','trapeq','trapf','trapge','trapgt',
         'traphi','traple','trapls','traplt','trapmi','trapne',
         'trappl','trapt','trapvc','trapvs','unpk',
         { fpu processor instructions - directly supported only. }
         { ieee aware and misc. condition codes not supported   }
         'fabs','fadd',
         'fbeq','fbne','fbngt','fbgt','fbge','fbnge',
         'fblt','fbnlt','fble','fbgl','fbngl','fbgle','fbngle',
         'fdbeq','fdbne','fdbgt','fdbngt','fdbge','fdbnge',
         'fdblt','fdbnlt','fdble','fdbgl','fdbngl','fdbgle','fdbngle',
         'fseq','fsne','fsgt','fsngt','fsge','fsnge',
         'fslt','fsnlt','fsle','fsgl','fsngl','fsgle','fsngle',
         'fcmp','fdiv','fmove','fmovem',
         'fmul','fneg','fnop','fsqrt','fsub','fsgldiv',
         'fsflmul','ftst',
         'ftrapeq','ftrapne','ftrapgt','ftrapngt','ftrapge','ftrapnge',
         'ftraplt','ftrapnlt','ftraple','ftrapgl','ftrapngl','ftrapgle','ftrapngle',
         { protected instructions }
         'cprestore','cpsave',
         { fpu unit protected instructions                    }
         { and 68030/68851 common mmu instructions            }
         { (this may include 68040 mmu instructions)          }
         'frestore','fsave','pflush','pflusha','pload','pmove','ptest',
         { useful for assembly language output }
         'label','none','db','s','b','fb');


     gas_opsize2str : array[topsize] of string[2] =
     ('','.b','.w','.l','.s','.d','.x',''
     );
{
     gas_reg2str : treg2strtable =
      ('', '%d0','%d1','%d2','%d3','%d4','%d5','%d6','%d7',
       '%a0','%a1','%a2','%a3','%a4','%a5','%a6','%sp',
       '-(%sp)','(%sp)+',
       '%ccr','%fp0','%fp1','%fp2','%fp3','%fp4','%fp5',
       '%fp6','%fp7','%fpcr','%sr','%ssp','%dfc',
       '%sfc','%vbr','%fpsr');
}

  implementation

    uses
      cutils,systems,
      cgbase,cgutils,
      verbose,itcpugas;


    function getreferencestring(var ref : treference) : string;
      var
         s,basestr,indexstr : string;

      begin
         s:='';
         with ref do
           begin
             basestr:=gas_regname(base);
             indexstr:=gas_regname(index);
             if assigned(symbol) then
               s:=s+symbol.name;

             if offset<0 then s:=s+tostr(offset)
              else if (offset>0) then
                begin
                  if (symbol=nil) then s:=tostr(offset)
                       else s:=s+'+'+tostr(offset);
                    end
                  else if (index=NR_NO) and (base=NR_NO) and not assigned(symbol) then
                    s:=s+'0';

               if (index<>NR_NO) and (base=NR_NO) and (direction=dir_none) then
                begin
                  if (scalefactor = 1) or (scalefactor = 0) then
                    s:=s+'(,'+indexstr+'.l)'
                  else
                    s:=s+'(,'+indexstr+'.l*'+tostr(scalefactor)+')'
                end
                else if (index=NR_NO) and (base<>NR_NO) and (direction=dir_inc) then
                begin
                  if (scalefactor = 1) or (scalefactor = 0) then
                      s:=s+'('+basestr+')+'
                  else
                   InternalError(10002);
                end
                else if (index=NR_NO) and (base<>NR_NO) and (direction=dir_dec) then
                begin
                  if (scalefactor = 1) or (scalefactor = 0) then
                      s:=s+'-('+basestr+')'
                  else
                   InternalError(10003);
                end
                  else if (index=NR_NO) and (base<>NR_NO) and (direction=dir_none) then
                begin
                  s:=s+'('+basestr+')'
                end
                  else if (index<>NR_NO) and (base<>NR_NO) and (direction=dir_none) then
                begin
                  if (scalefactor = 1) or (scalefactor = 0) then
                    s:=s+'('+basestr+','+indexstr+'.l)'
                  else
                    s:=s+'('+basestr+','+indexstr+'.l*'+tostr(scalefactor)+')';
                end;
          end;
         getreferencestring:=s;
      end;


    function getopstr(const o:toper) : string;
      var
        hs : string;
        i : tsuperregister;
      begin
        case o.typ of
          top_reg:
            getopstr:=gas_regname(o.reg);
          top_ref:
            if o.ref^.refaddr=addr_full then
              begin
             if assigned(o.ref^.symbol) then
               hs:='#'+o.ref^.symbol.name
             else
               hs:='#';
               if o.ref^.offset>0 then
                hs:=hs+'+'+tostr(o.ref^.offset)
               else
                if o.ref^.offset<0 then
                 hs:=hs+tostr(o.ref^.offset)
               else
                if not(assigned(o.ref^.symbol)) then
                  hs:=hs+'0';
               getopstr:=hs;
              end
            else
              getopstr:=getreferencestring(o.ref^);
          top_reglist:
            begin
              hs:='';
              for i:=RS_D0 to RS_D7 do
                begin
                  if i in o.regset^ then
                   hs:=hs+gas_regname(newreg(R_INTREGISTER,i,R_SUBWHOLE))+'/';
                end;
              for i:=RS_A0 to RS_SP do
                begin
                  if i in o.regset^ then
                   hs:=hs+gas_regname(newreg(R_INTREGISTER,i,R_SUBWHOLE))+'/';
                end;
              delete(hs,length(hs),1);
              getopstr := hs;
            end;
          top_const:
            getopstr:='#'+tostr(longint(o.val));
          else internalerror(200405021);
        end;
      end;


    function getopstr_jmp(const o:toper) : string;
      var
        hs : string;
      begin
        case o.typ of
          top_reg:
            getopstr_jmp:=gas_regname(o.reg);
          top_ref:
            if o.ref^.refaddr=addr_no then
              getopstr_jmp:=getreferencestring(o.ref^)
            else
              begin
                if assigned(o.ref^.symbol) then
                  hs:=o.ref^.symbol.name
                else
                  hs:='';
                  if o.ref^.offset>0 then
                   hs:=hs+'+'+tostr(o.ref^.offset)
                  else
                   if o.ref^.offset<0 then
                    hs:=hs+tostr(o.ref^.offset)
                  else
                   if not(assigned(o.ref^.symbol)) then
                     hs:=hs+'0';
                getopstr_jmp:=hs;
              end;
          top_const:
            getopstr_jmp:=tostr(o.val);
          else internalerror(200405022);
        end;
      end;

{****************************************************************************
                            TM68kASMOUTPUT
 ****************************************************************************}

    { returns the opcode string }
    function getopcodestring(hp : tai) : string;
      var
        op : tasmop;
        s : string;
      begin
        op:=taicpu(hp).opcode;
        { old versions of GAS don't like PEA.L and LEA.L }
        if (op in [
         A_LEA,A_PEA,A_ABCD,A_BCHG,A_BCLR,A_BSET,A_BTST,
         A_EXG,A_NBCD,A_SBCD,A_SWAP,A_TAS,A_SCC,A_SCS,
         A_SEQ,A_SGE,A_SGT,A_SHI,A_SLE,A_SLS,A_SLT,A_SMI,
         A_SNE,A_SPL,A_ST,A_SVC,A_SVS,A_SF]) then
         s:=gas_op2str[op]
        else
        if op = A_SXX then
         s:=gas_op2str[op]+cond2str[taicpu(hp).condition]
        else
        if op in [a_dbxx,a_bxx,a_fbxx] then
         s:=gas_op2str[op]+cond2str[taicpu(hp).condition]+gas_opsize2str[taicpu(hp).opsize]
        else
         s:=gas_op2str[op]+gas_opsize2str[taicpu(hp).opsize];
        getopcodestring:=s;
      end;


    procedure TM68kAssembler.WriteInstruction(hp: tai);
      var
        op       : tasmop;
        s        : string;
        sep      : char;
        calljmp  : boolean;
        i        : integer;
       begin
         if hp.typ <> ait_instruction then exit;
         op:=taicpu(hp).opcode;
         calljmp:=is_calljmp(op);
         { call maybe not translated to call }
         s:=#9+getopcodestring(hp);
         { process operands }
         if taicpu(hp).ops<>0 then
           begin
             { call and jmp need an extra handling                          }
             { this code is only called if jmp isn't a labeled instruction  }
             { quick hack to overcome a problem with manglednames=255 chars }
             if calljmp then
                begin
                  AsmWrite(s+#9);
                  s:=getopstr_jmp(taicpu(hp).oper[0]^);
                end
              else
                begin
                  for i:=0 to taicpu(hp).ops-1 do
                    begin
                      if i=0 then
                        sep:=#9
                      else
                      if ((op = A_DIVSL) or
                         (op = A_DIVUL) or
                         (op = A_MULU) or
                         (op = A_MULS) or
                         (op = A_DIVS) or
                         (op = A_DIVU)) and (i=1) then
                        sep:=':'
                      else
                        sep:=',';
                      s:=s+sep+getopstr(taicpu(hp).oper[i]^)
                    end;
                end;
           end;
           AsmWriteLn(s);
       end;


{*****************************************************************************
                                  Initialize
*****************************************************************************}

    const
       as_m68k_as_info : tasminfo =
          (
            id     : as_gas;
            idtxt  : 'AS';
            asmbin : 'as';
            asmcmd : '-o $OBJ $ASM';
            supported_target : system_any;
            flags : [af_allowdirect,af_needar,af_smartlink_sections];
            labelprefix : '.L';
            comment : '# ';
          );

initialization
  RegisterAssembler(as_m68k_as_info,TM68kAssembler);
end.
