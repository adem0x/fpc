{
    Copyright (c) 1998-2002 by Carl Eric Codere and Peter Vreman

    Does the parsing for the x86 GNU AS styled inline assembler.

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
Unit rax86att;

{$i fpcdefs.inc}

Interface

  uses
    cpubase,
    raatt,rax86;

  type
    tx86attreader = class(tattreader)
      ActOpsize : topsize;
      function is_asmopcode(const s: string):boolean;override;
      procedure handleopcode;override;
      procedure BuildReference(oper : tx86operand);
      procedure BuildOperand(oper : tx86operand);
      procedure BuildOpCode(instr : tx86instruction);
      procedure handlepercent;override;
    end;


Implementation

    uses
      { helpers }
      cutils,
      { global }
      globtype,verbose,
      systems,
      { aasm }
      aasmbase,aasmtai,aasmcpu,
      { symtable }
      symconst,
      { parser }
      scanner,
      procinfo,
      itcpugas,
      rabase,rautils,
      cgbase
      ;

    procedure tx86attreader.handlepercent;
      var
        len : longint;
      begin
        len:=1;
        actasmpattern[len]:='%';
        c:=current_scanner.asmgetchar;
        { to be a register there must be a letter and not a number }
        if c in ['0'..'9'] then
         begin
           actasmtoken:=AS_MOD;
         end
        else
         begin
           while c in ['a'..'z','A'..'Z','0'..'9'] do
            Begin
              inc(len);
              actasmpattern[len]:=c;
              c:=current_scanner.asmgetchar;
            end;
           actasmpattern[0]:=chr(len);
           uppervar(actasmpattern);
           if (actasmpattern = '%ST') and (c='(') then
            Begin
              actasmpattern:=actasmpattern+c;
              c:=current_scanner.asmgetchar;
              if c in ['0'..'9'] then
               actasmpattern:=actasmpattern + c
              else
               Message(asmr_e_invalid_fpu_register);
              c:=current_scanner.asmgetchar;
              if c <> ')' then
               Message(asmr_e_invalid_fpu_register)
              else
               Begin
                 actasmpattern:=actasmpattern + c;
                 c:=current_scanner.asmgetchar; { let us point to next character. }
               end;
            end;
           if is_register(actasmpattern) then
            exit;
           Message(asmr_e_invalid_register);
           actasmtoken:=raatt.AS_NONE;
         end;
      end;


    Procedure tx86attreader.BuildReference(oper : tx86operand);

      procedure Consume_RParen;
        begin
          if actasmtoken <> AS_RPAREN then
           Begin
             Message(asmr_e_invalid_reference_syntax);
             RecoverConsume(true);
           end
          else
           begin
             Consume(AS_RPAREN);
             if not (actasmtoken in [AS_COMMA,AS_SEPARATOR,AS_END]) then
              Begin
                Message(asmr_e_invalid_reference_syntax);
                RecoverConsume(true);
              end;
           end;
        end;


      procedure Consume_Scale;
        var
          l : aint;
        begin
          { we have to process the scaling }
          l:=BuildConstExpression(false,true);
          if ((l = 2) or (l = 4) or (l = 8) or (l = 1)) then
           oper.opr.ref.scalefactor:=l
          else
           Begin
             Message(asmr_e_wrong_scale_factor);
             oper.opr.ref.scalefactor:=0;
           end;
        end;


      begin
        oper.InitRef;
        Consume(AS_LPAREN);
        Case actasmtoken of
          AS_INTNUM,
          AS_MINUS,
          AS_PLUS: { absolute offset, such as fs:(0x046c) }
            Begin
              { offset(offset) is invalid }
              If oper.opr.Ref.Offset <> 0 Then
               Begin
                 Message(asmr_e_invalid_reference_syntax);
                 RecoverConsume(true);
               End
              Else
               Begin
                 oper.opr.Ref.Offset:=BuildConstExpression(false,true);
                 Consume_RParen;
               end;
              exit;
            End;
          AS_REGISTER: { (reg ...  }
            Begin
              { Check if there is already a base (mostly ebp,esp) than this is
                not allowed, because it will give crashing code }
              if ((oper.opr.typ=OPR_REFERENCE) and (oper.opr.ref.base<>NR_NO)) or
                 ((oper.opr.typ=OPR_LOCAL) and (oper.opr.localsym.localloc.loc<>LOC_REGISTER)) then
                message(asmr_e_cannot_index_relative_var);
              oper.opr.ref.base:=actasmregister;
              Consume(AS_REGISTER);
              { can either be a register or a right parenthesis }
              { (reg)        }
              if actasmtoken=AS_RPAREN then
               Begin
                 Consume_RParen;
                 exit;
               end;
              { (reg,reg ..  }
              Consume(AS_COMMA);
              if actasmtoken=AS_REGISTER then
               Begin
                 oper.opr.ref.index:=actasmregister;
                 Consume(AS_REGISTER);
                 { check for scaling ... }
                 case actasmtoken of
                   AS_RPAREN:
                     Begin
                       Consume_RParen;
                       exit;
                     end;
                   AS_COMMA:
                     Begin
                       Consume(AS_COMMA);
                       Consume_Scale;
                       Consume_RParen;
                     end;
                 else
                   Begin
                     Message(asmr_e_invalid_reference_syntax);
                     RecoverConsume(false);
                   end;
                 end; { end case }
               end
              else
               Begin
                 Message(asmr_e_invalid_reference_syntax);
                 RecoverConsume(false);
               end;
            end; {end case }
          AS_COMMA: { (, ...  can either be scaling, or index }
            Begin
              Consume(AS_COMMA);
              { Index }
              if (actasmtoken=AS_REGISTER) then
               Begin
                 oper.opr.ref.index:=actasmregister;
                 Consume(AS_REGISTER);
                 { check for scaling ... }
                 case actasmtoken of
                   AS_RPAREN:
                     Begin
                       Consume_RParen;
                       exit;
                     end;
                   AS_COMMA:
                     Begin
                       Consume(AS_COMMA);
                       Consume_Scale;
                       Consume_RParen;
                     end;
                 else
                   Begin
                     Message(asmr_e_invalid_reference_syntax);
                     RecoverConsume(false);
                   end;
                 end; {end case }
               end
              { Scaling }
              else
               Begin
                 Consume_Scale;
                 Consume_RParen;
                 exit;
               end;
            end;
        else
          Begin
            Message(asmr_e_invalid_reference_syntax);
            RecoverConsume(false);
          end;
        end;
      end;


    Procedure tx86attreader.BuildOperand(oper : tx86operand);
      var
        tempstr,
        expr : string;
        typesize,l,k : aint;


        procedure AddLabelOperand(hl:tasmlabel);
          begin
            if not(actasmtoken in [AS_PLUS,AS_MINUS,AS_LPAREN]) and
               is_calljmp(actopcode) then
             begin
               oper.opr.typ:=OPR_SYMBOL;
               oper.opr.symbol:=hl;
             end
            else
             begin
               oper.InitRef;
               oper.opr.ref.symbol:=hl;
             end;
          end;


        procedure MaybeRecordOffset;
          var
            hasdot  : boolean;
            l,
            toffset,
            tsize   : aint;
          begin
            if not(actasmtoken in [AS_DOT,AS_PLUS,AS_MINUS]) then
             exit;
            l:=0;
            hasdot:=(actasmtoken=AS_DOT);
            if hasdot then
             begin
               if expr<>'' then
                 begin
                   BuildRecordOffsetSize(expr,toffset,tsize);
                   inc(l,toffset);
                   oper.SetSize(tsize,true);
                 end;
             end;
            if actasmtoken in [AS_PLUS,AS_MINUS] then
             inc(l,BuildConstExpression(true,false));
            case oper.opr.typ of
              OPR_LOCAL :
                begin
                  { don't allow direct access to fields of parameters, because that
                    will generate buggy code. Allow it only for explicit typecasting }
                  if hasdot and
                     (not oper.hastype) and
                     (oper.opr.localsym.owner.symtabletype=parasymtable) and
                     (current_procinfo.procdef.proccalloption<>pocall_register) then
                    Message(asmr_e_cannot_access_field_directly_for_parameters);
                  inc(oper.opr.localsymofs,l)
                end;
              OPR_CONSTANT :
                inc(oper.opr.val,l);
              OPR_REFERENCE :
                inc(oper.opr.ref.offset,l);
              else
                internalerror(200309221);
            end;
          end;


        procedure handleat;
          begin
          end;


        function MaybeBuildReference:boolean;
          { Try to create a reference, if not a reference is found then false
            is returned }
          begin
            MaybeBuildReference:=true;
            case actasmtoken of
              AS_INTNUM,
              AS_MINUS,
              AS_PLUS:
                Begin
                  oper.opr.ref.offset:=BuildConstExpression(True,False);
                  if actasmtoken<>AS_LPAREN then
                    Message(asmr_e_invalid_reference_syntax)
                  else
                    BuildReference(oper);
                end;
              AS_LPAREN:
                BuildReference(oper);
              AS_ID: { only a variable is allowed ... }
                Begin
                  tempstr:=actasmpattern;
                  Consume(AS_ID);
                  { typecasting? }
                  if (actasmtoken=AS_LPAREN) and
                     SearchType(tempstr,typesize) then
                   begin
                     oper.hastype:=true;
                     Consume(AS_LPAREN);
                     BuildOperand(oper);
                     Consume(AS_RPAREN);
                     if oper.opr.typ in [OPR_REFERENCE,OPR_LOCAL] then
                       oper.SetSize(typesize,true);
                   end
                  else
                   if not oper.SetupVar(tempstr,false) then
                    Message1(sym_e_unknown_id,tempstr);
                  { record.field ? }
                  if actasmtoken=AS_DOT then
                   begin
                     BuildRecordOffsetSize(tempstr,l,k);
                     inc(oper.opr.ref.offset,l);
                   end;
                  if actasmtoken=AS_AT then
                    begin
                      consume(AS_AT);
                      if actasmtoken=AS_ID then
                        begin
                          if actasmpattern='GOTPCREL' then
                            oper.opr.ref.refaddr:=addr_pic
                          else
                            Message(asmr_e_invalid_reference_syntax);
                        end
                      else
                        Message(asmr_e_invalid_reference_syntax);
                    end;
                  case actasmtoken of
                    AS_END,
                    AS_SEPARATOR,
                    AS_COMMA: ;
                    AS_LPAREN:
                      BuildReference(oper);
                  else
                    Begin
                      Message(asmr_e_invalid_reference_syntax);
                      Consume(actasmtoken);
                    end;
                  end; {end case }
                end;
              else
               MaybeBuildReference:=false;
            end; { end case }
          end;

      var
        tempreg : tregister;
        hl      : tasmlabel;
      Begin
        expr:='';
        case actasmtoken of
          AS_LPAREN: { Memory reference or constant expression }
            Begin
              oper.InitRef;
              BuildReference(oper);
            end;

          AS_DOLLAR: { Constant expression  }
            Begin
              Consume(AS_DOLLAR);
              BuildConstantOperand(oper);
            end;

          AS_INTNUM,
          AS_MINUS,
          AS_PLUS:
            Begin
              { Constant memory offset }
              { This must absolutely be followed by (  }
              oper.InitRef;
              oper.opr.ref.offset:=BuildConstExpression(True,False);
              if actasmtoken<>AS_LPAREN then
                Message(asmr_e_invalid_reference_syntax)
              else
                BuildReference(oper);
            end;

          AS_STAR: { Call from memory address }
            Begin
              Consume(AS_STAR);
              if actasmtoken=AS_REGISTER then
               begin
                 oper.opr.typ:=OPR_REGISTER;
                 oper.opr.reg:=actasmregister;
                 oper.SetSize(tcgsize2size[reg_cgsize(actasmregister)],true);
                 Consume(AS_REGISTER);
               end
              else
               begin
                 oper.InitRef;
                 if not MaybeBuildReference then
                  Message(asmr_e_syn_operand);
               end;
              { this is only allowed for call's and jmp's }
              if not is_calljmp(actopcode) then
               Message(asmr_e_syn_operand);
            end;

          AS_ID: { A constant expression, or a Variable ref.  }
            Begin
              { Local Label ? }
              if is_locallabel(actasmpattern) then
               begin
                 CreateLocalLabel(actasmpattern,hl,false);
                 Consume(AS_ID);
                 AddLabelOperand(hl);
               end
              else
               { Check for label }
               if SearchLabel(actasmpattern,hl,false) then
                begin
                  Consume(AS_ID);
                  AddLabelOperand(hl);
                end
              else
               { probably a variable or normal expression }
               { or a procedure (such as in CALL ID)      }
               Begin
                 { is it a constant ? }
                 if SearchIConstant(actasmpattern,l) then
                  Begin
                    if not (oper.opr.typ in [OPR_NONE,OPR_CONSTANT]) then
                     Message(asmr_e_invalid_operand_type);
                    BuildConstantOperand(oper);
                  end
                 else
                  begin
                    expr:=actasmpattern;
                    Consume(AS_ID);
                    { typecasting? }
                    if (actasmtoken=AS_LPAREN) and
                       SearchType(expr,typesize) then
                     begin
                       oper.hastype:=true;
                       Consume(AS_LPAREN);
                       BuildOperand(oper);
                       Consume(AS_RPAREN);
                       if oper.opr.typ in [OPR_REFERENCE,OPR_LOCAL] then
                         oper.SetSize(typesize,true);
                     end
                    else
                     begin
                       if oper.SetupVar(expr,false) then
                        begin
                          if actasmtoken=AS_AT then
                            begin
                              consume(AS_AT);
                              if actasmtoken=AS_ID then
                                begin
                                  if actasmpattern='GOTPCREL' then
                                    begin
                                      oper.opr.ref.refaddr:=addr_pic;
                                      consume(AS_ID);
                                    end
                                  else
                                    Message(asmr_e_invalid_reference_syntax);
                                end
                              else
                                Message(asmr_e_invalid_reference_syntax);
                            end;
                          end
                       else
                        Begin
                          { look for special symbols ... }
                          if expr= '__HIGH' then
                            begin
                              consume(AS_LPAREN);
                              if not oper.setupvar('high'+actasmpattern,false) then
                                Message1(sym_e_unknown_id,'high'+actasmpattern);
                              consume(AS_ID);
                              consume(AS_RPAREN);
                            end
                          else
                           if expr = '__RESULT' then
                            oper.SetUpResult
                          else
                           if expr = '__SELF' then
                            oper.SetupSelf
                          else
                           if expr = '__OLDEBP' then
                            oper.SetupOldEBP
                          else
                            Message1(sym_e_unknown_id,expr);
                        end;
                     end;
                  end;
                  if actasmtoken=AS_DOT then
                    MaybeRecordOffset;
                  { add a constant expression? }
                  if (actasmtoken=AS_PLUS) then
                   begin
                     l:=BuildConstExpression(true,false);
                     case oper.opr.typ of
                       OPR_CONSTANT :
                         inc(oper.opr.val,l);
                       OPR_LOCAL :
                         inc(oper.opr.localsymofs,l);
                       OPR_REFERENCE :
                         inc(oper.opr.ref.offset,l);
                       else
                         internalerror(200309202);
                     end;
                   end
               end;
              { Do we have a indexing reference, then parse it also }
              if actasmtoken=AS_LPAREN then
                BuildReference(oper);
            end;

          AS_REGISTER: { Register, a variable reference or a constant reference  }
            Begin
              { save the type of register used. }
              tempreg:=actasmregister;
              Consume(AS_REGISTER);
              if actasmtoken = AS_COLON then
               Begin
                 Consume(AS_COLON);
                 oper.InitRef;
                 oper.opr.ref.segment:=tempreg;
                 { This must absolutely be followed by a reference }
                 if not MaybeBuildReference then
                  Begin
                    Message(asmr_e_invalid_seg_override);
                    Consume(actasmtoken);
                  end;
               end
              { Simple register  }
              else if (actasmtoken in [AS_END,AS_SEPARATOR,AS_COMMA]) then
                Begin
                  if not (oper.opr.typ in [OPR_NONE,OPR_REGISTER]) then
                    Message(asmr_e_invalid_operand_type);
                  oper.opr.typ:=OPR_REGISTER;
                  oper.opr.reg:=tempreg;
                  oper.SetSize(tcgsize2size[reg_cgsize(oper.opr.reg)],true);
                end
              else
                Message(asmr_e_syn_operand);
            end;
          AS_END,
          AS_SEPARATOR,
          AS_COMMA: ;
        else
          Begin
            Message(asmr_e_syn_operand);
            Consume(actasmtoken);
          end;
        end; { end case }
      end;


    procedure tx86attreader.BuildOpCode(instr : tx86instruction);
      var
        operandnum : longint;
        PrefixOp,OverrideOp: tasmop;
      Begin
        PrefixOp:=A_None;
        OverrideOp:=A_None;
        { prefix seg opcode / prefix opcode }
        repeat
          if is_prefix(actopcode) then
            begin
              PrefixOp:=ActOpcode;
              with instr do
                begin
                  opcode:=ActOpcode;
                  condition:=ActCondition;
                  opsize:=ActOpsize;
                  ConcatInstruction(curlist);
                end;
              Consume(AS_OPCODE);
            end
          else
            if is_override(actopcode) then
              begin
                OverrideOp:=ActOpcode;
                with instr do
                  begin
                    opcode:=ActOpcode;
                    condition:=ActCondition;
                    opsize:=ActOpsize;
                    ConcatInstruction(curlist);
                  end;
                Consume(AS_OPCODE);
              end
            else
              break;
          { allow for newline as in gas styled syntax }
          while actasmtoken=AS_SEPARATOR do
            Consume(AS_SEPARATOR);
        until (actasmtoken<>AS_OPCODE);
        { opcode }
        if (actasmtoken<>AS_OPCODE) then
         Begin
           Message(asmr_e_invalid_or_missing_opcode);
           RecoverConsume(true);
           exit;
         end;
        { Fill the instr object with the current state }
        with instr do
          begin
            Opcode:=ActOpcode;
            condition:=ActCondition;
            opsize:=ActOpsize;
          end;

        { Valid combination of prefix/override and instruction ?  }

        if (prefixop<>A_NONE) and (NOT CheckPrefix(PrefixOp,actopcode)) then
           Message1(asmr_e_invalid_prefix_and_opcode,actasmpattern);

        if (overrideop<>A_NONE) and (NOT CheckOverride(OverrideOp,ActOpcode)) then
          Message1(asmr_e_invalid_override_and_opcode,actasmpattern);
        { We are reading operands, so opcode will be an AS_ID }
        operandnum:=1;
        Consume(AS_OPCODE);
        { Zero operand opcode ?  }
        if actasmtoken in [AS_SEPARATOR,AS_END] then
         begin
           operandnum:=0;
           exit;
         end;
        { Read the operands }
        repeat
          case actasmtoken of
            AS_COMMA: { Operand delimiter }
              Begin
                if operandnum > Max_Operands then
                  Message(asmr_e_too_many_operands)
                else
                  Inc(operandnum);
                Consume(AS_COMMA);
              end;
            AS_SEPARATOR,
            AS_END : { End of asm operands for this opcode  }
              begin
                break;
              end;
          else
            BuildOperand(instr.Operands[operandnum] as tx86operand);
          end; { end case }
        until false;
        instr.Ops:=operandnum;
      end;


    function tx86attreader.is_asmopcode(const s: string):boolean;
      const
        { We need first to check the long prefixes, else we get probs
          with things like movsbl }
        att_sizesuffixstr : array[0..9] of string[2] = (
          '','BW','BL','WL','B','W','L','S','Q','T'
        );
        att_sizesuffix : array[0..9] of topsize = (
          S_NO,S_BW,S_BL,S_WL,S_B,S_W,S_L,S_FS,S_IQ,S_FX
        );
        att_sizefpusuffix : array[0..9] of topsize = (
          S_NO,S_NO,S_NO,S_NO,S_NO,S_NO,S_FL,S_FS,S_IQ,S_FX
        );
        att_sizefpuintsuffix : array[0..9] of topsize = (
          S_NO,S_NO,S_NO,S_NO,S_NO,S_NO,S_IL,S_IS,S_IQ,S_NO
        );
      var
        str2opentry: tstr2opentry;
        cond : string[4];
        cnd  : tasmcond;
        len,
        j,
        sufidx : longint;
      Begin
        is_asmopcode:=FALSE;

        actopcode:=A_None;
        actcondition:=C_None;
        actopsize:=S_NO;

        { search for all possible suffixes }
        for sufidx:=low(att_sizesuffixstr) to high(att_sizesuffixstr) do
         begin
           len:=length(s)-length(att_sizesuffixstr[sufidx]);
           if copy(s,len+1,length(att_sizesuffixstr[sufidx]))=att_sizesuffixstr[sufidx] then
            begin
              { here we search the entire table... }
              str2opentry:=nil;
              if {(length(s)>0) and} (len>0) then
                str2opentry:=tstr2opentry(iasmops.search(copy(s,1,len)));
              if assigned(str2opentry) then
                begin
                  actopcode:=str2opentry.op;
                  if gas_needsuffix[actopcode]=attsufFPU then
                   actopsize:=att_sizefpusuffix[sufidx]
                  else if gas_needsuffix[actopcode]=attsufFPUint then
                   actopsize:=att_sizefpuintsuffix[sufidx]
                  else
                   actopsize:=att_sizesuffix[sufidx];
                  actasmtoken:=AS_OPCODE;
                  is_asmopcode:=TRUE;
                  exit;
                end;
              { not found, check condition opcodes }
              j:=0;
              while (j<CondAsmOps) do
               begin
                 if Copy(s,1,Length(CondAsmOpStr[j]))=CondAsmOpStr[j] then
                  begin
                    cond:=Copy(s,Length(CondAsmOpStr[j])+1,len-Length(CondAsmOpStr[j]));
                    if cond<>'' then
                     begin
                       for cnd:=low(TasmCond) to high(TasmCond) do
                        if Cond=Upper(cond2str[cnd]) then
                         begin
                           actopcode:=CondASmOp[j];
                           if gas_needsuffix[actopcode]=attsufFPU then
                            actopsize:=att_sizefpusuffix[sufidx]
                           else if gas_needsuffix[actopcode]=attsufFPUint then
                            actopsize:=att_sizefpuintsuffix[sufidx]
                           else
                            actopsize:=att_sizesuffix[sufidx];
                           actcondition:=cnd;
                           actasmtoken:=AS_OPCODE;
                           is_asmopcode:=TRUE;
                           exit;
                         end;
                     end;
                  end;
                 inc(j);
               end;
           end;
         end;
      end;


    procedure tx86attreader.handleopcode;
      var
        instr : Tx86Instruction;
      begin
        instr:=Tx86Instruction.Create(Tx86Operand);
        instr.OpOrder:=op_att;
        BuildOpcode(instr);
        instr.AddReferenceSizes;
        instr.SetInstructionOpsize;
        instr.CheckOperandSizes;
        instr.ConcatInstruction(curlist);
        instr.Free;
      end;


end.
