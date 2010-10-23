{
    Copyright (c) 1998-2002 by Florian Klaempfl and Dr. Diettrich

    Implements the statement parser.
    Cloned from pstatmnt.pas, semantics moved into SStatmnt.pas.

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
(* Currently not much is done in this unit. Parsing statements is almost a
  matter of building an AST, and that's a typical task of any parser.

  This statement parser defers parsing to the standard parser in pstatmnt.
  New statements or different handling can be implemented here, in the select
  statement of _statement().

  For the selection of the right statement parser, in a multi-parser environment,
  the original statement() procedure has been renamed into _statement(). Calls
  to statement() are caught in pbase.pas and deferred to the virtual
  current_parser.statement() method. Every parser overrides this method, calling
  his own _statement procedure. The same mechanism is implemented for parsing
  expressions.
*)
unit PStatmntOPL;

{$i fpcdefs.inc}

{$DEFINE semclass}  //using semantic classes?
{$DEFINE imports}   //strip excessive uses? (todo)

interface

    uses
      tokens,node;

    function statement_blockOPL(starttoken : ttoken) : tnode;

    { renamed and exported statement() }
    function statementOPL : tnode;

implementation

    uses
    {$IFDEF semclass}
      pstatmnt,
       { global }
       globtype,globals,constexp,
       { pass 1 }
       pass_1,nbas,
       { parser }
       scanner,
       pbase,
    {$ELSE}
       { common }
       cutils,cclasses,
       { global }
       globtype,globals,verbose,constexp,
       systems,
       { aasm }
       cpubase,aasmbase,aasmtai,aasmdata,
       { symtable }
       symconst,symbase,symtype,symdef,symsym,symtable,defutil,defcmp,
       paramgr,symutil,
       { pass 1 }
       pass_1,htypechk,
       nutils,nbas,nmat,nadd,ncal,nmem,nset,ncnv,ninl,ncon,nld,nflw,
       { parser }
       scanner,
       pbase,pexpr,
       { codegen }
       procinfo,cgbase,
       { assembler reader }
       rabase,
       { wide- and unicodestrings}
       widestr,
    {$ENDIF}
       SStatmnt
       ;


    function try_statement : tnode;
      var
      {$IFDEF semclass}
        sts: TSemTry;
      {$ELSE}
         oldcurrent_exceptblock: integer;
         p_try_block,p_finally_block,first,last,
         p_default,p_specific,hp : tnode;
         ot : tDef;
         sym : tlocalvarsym;
         old_block_type : tblock_type;
         excepTSymtable : TSymtable;
         objname,objrealname : TIDString;
         srsym : tsym;
         srsymtable : TSymtable;
      {$ENDIF}
      begin
        {$IFDEF semclass}
          sts.TryInit;
        {$ELSE}
         include(current_procinfo.flags,pi_uses_exceptions);

         p_default:=nil;
         p_specific:=nil;
        {$ENDIF}

         { read statements to try }
         consume(_TRY);
        {$IFDEF semclass}
        {$ELSE}
         first:=nil;
         inc(exceptblockcounter);
         oldcurrent_exceptblock := current_exceptblock;
         current_exceptblock := exceptblockcounter;
        {$ENDIF}

         while (token<>_FINALLY) and (token<>_EXCEPT) do
           begin
           {$IFDEF semclass}
              sts.TryStmt;
           {$ELSE}
              if first=nil then
                begin
                   last:=cstatementnode.create(statement,nil);
                   first:=last;
                end
              else
                begin
                   tstatementnode(last).right:=cstatementnode.create(statement,nil);
                   last:=tstatementnode(last).right;
                end;
           {$ENDIF}
              if not try_to_consume(_SEMICOLON) then
                break;
              consume_emptystats;
           end;
        {$IFDEF semclass}
          sts.TryStmtsDone;
        {$ELSE}
         p_try_block:=cblocknode.create(first);
        {$ENDIF}

         if try_to_consume(_FINALLY) then
           begin
         {$IFDEF semclass}
            Result := sts.TryFinallyInit;
         {$ELSE}
              inc(exceptblockcounter);
              current_exceptblock := exceptblockcounter;
              p_finally_block:=statements_til_end;
              Result:=ctryfinallynode.create(p_try_block,p_finally_block);
         {$ENDIF}
           end
         else
           begin
              consume(_EXCEPT);
           {$IFDEF semclass}
              sts.TryExceptInit;
           {$ELSE}
              old_block_type:=block_type;
              block_type:=bt_except;
              inc(exceptblockcounter);
              current_exceptblock := exceptblockcounter;
              ot:=generrordef;
              p_specific:=nil;
           {$ENDIF}
              if (idtoken=_ON) then
                { catch specific exceptions }
                begin
                   repeat
                     consume(_ON);
                     if token=_ID then
                       begin
                       {$IFDEF semclass}
                          sts.OnExceptID;
                       {$ELSE}
                          objname:=pattern;
                          objrealname:=orgpattern;
                          { can't use consume_sym here, because we need already
                            to check for the colon }
                          searchsym(objname,srsym,srsymtable);
                       {$ENDIF}
                          consume(_ID);
                          { is a explicit name for the exception given ? }
                          if try_to_consume(_COLON) then
                            begin
                               consume_sym(sts.srsym,sts.srsymtable);
                            {$IFDEF semclass}
                                sts.OnExceptBody;
                            {$ELSE}
                               if (srsym.typ=typesym) and
                                  is_class(ttypesym(srsym).typedef) then
                                 begin
                                    ot:=ttypesym(srsym).typedef;
                                    sym:=tlocalvarsym.create(objrealname,vs_value,ot,[]);
                                 end
                               else
                                 begin
                                    sym:=tlocalvarsym.create(objrealname,vs_value,generrordef,[]);
                                    if (srsym.typ=typesym) then
                                      Message1(type_e_class_type_expected,ttypesym(srsym).typedef.typename)
                                    else
                                      Message1(type_e_class_type_expected,ot.typename);
                                 end;
                               excepTSymtable:=tstt_excepTSymtable.create;
                               excepTSymtable.insert(sym);
                               symtablestack.push(excepTSymtable);
                            {$ENDIF}
                            end
                          else
                            begin
                            {$IFDEF semclass}
                              sts.OnExceptType;
                            {$ELSE}
                               { check if type is valid, must be done here because
                                 with "e: Exception" the e is not necessary }
                               if srsym=nil then
                                begin
                                  identifier_not_found(objrealname);
                                  srsym:=generrorsym;
                                end;
                               { support unit.identifier }
                               if srsym.typ=unitsym then
                                 begin
                                    consume(_POINT);
                                    searchsym_in_module(tunitsym(srsym).module,pattern,srsym,srsymtable);
                                    if sts.srsym=nil then
                                     begin
                                       identifier_not_found(orgpattern);
                                       srsym:=generrorsym;
                                     end;
                                    consume(_ID);
                                 end;
                               { check if type is valid, must be done here because
                                 with "e: Exception" the e is not necessary }
                               if (srsym.typ=typesym) and
                                  is_class(ttypesym(srsym).typedef) then
                                 ot:=ttypesym(srsym).typedef
                               else
                                 begin
                                    ot:=generrordef;
                                    if (sts.srsym.typ=typesym) then
                                      Message1(type_e_class_type_expected,ttypesym(srsym).typedef.typename)
                                    else
                                      Message1(type_e_class_type_expected,ot.typename);
                                 end;
                               excepTSymtable:=nil;
                            {$ENDIF}
                            end;
                       end
                     else
                       consume(_ID);
                     consume(_DO);
                  {$IFDEF semclass}
                      sts.OnExceptDo;
                  {$ELSE}
                     hp:=connode.create(nil,statement);
                     if ot.typ=errordef then
                       begin
                          hp.free;
                          hp:=cerrornode.create;
                       end;
                     if p_specific=nil then
                       begin
                          last:=hp;
                          p_specific:=last;
                       end
                     else
                       begin
                          tonnode(last).left:=hp;
                          last:=tonnode(last).left;
                       end;
                     { set the informations }
                     { only if the creation of the onnode was succesful, it's possible }
                     { that last and hp are errornodes (JM)                            }
                     if last.nodetype = onn then
                       begin
                         tonnode(last).excepttype:=tobjectdef(ot);
                         tonnode(last).excepTSymtable:=excepTSymtable;
                       end;
                     { remove exception symtable }
                     if assigned(excepTSymtable) then
                       begin
                         symtablestack.pop(excepTSymtable);
                         if last.nodetype <> onn then
                           excepTSymtable.free;
                       end;
                  {$ENDIF}
                     if not try_to_consume(_SEMICOLON) then
                        break;
                     consume_emptystats;
                   until (token in [_END,_ELSE]);
                   if try_to_consume(_ELSE) then
                     begin
                       { catch the other exceptions }
                       sts.p_default:=statements_til_end;
                     end
                   else
                     consume(_END);
                end
              else
                begin
                   { catch all exceptions }
                   sts.p_default:=statements_til_end;
                end;

           {$IFDEF semclass}
              Result := sts.TryExceptDone;
           {$ELSE}
              block_type:=old_block_type;
              Result:=ctryexceptnode.create(p_try_block,p_specific,p_default);
           {$ENDIF}
           end;
        {$IFDEF semclass}
          sts.TryDone;
        {$ELSE}
         current_exceptblock := oldcurrent_exceptblock;
        {$ENDIF}
      end;


    function statementOPL : tnode;
      var
         filepos : tfileposinfo;
    {$IFDEF semclass}
    {$ELSE}
         p       : tnode;
         code    : tnode;
         srsym   : tsym;
         srsymtable : TSymtable;
         s       : TIDString;
    {$ENDIF}
      begin
         filepos:=current_tokenpos;
        {$IFDEF semclass}
          //todo: extract semantics, link to modified procedures
         case token of
         _BEGIN:  Result := statement_blockOPL(_BEGIN);
         _TRY:    Result := try_statement;
         { semicolons,else until and end are ignored }
         _SEMICOLON,
         _ELSE,
         _UNTIL,
         _END:    Result := cnothingnode.create;
         else
                  Result := pstatmnt._statement;
                  exit;
         end;
        {$ELSE}
         case token of
           _GOTO :
             begin
                if not(cs_support_goto in current_settings.moduleswitches) then
                 Message(sym_e_goto_and_label_not_supported);
                consume(_GOTO);
                if (token<>_INTCONST) and (token<>_ID) then
                  begin
                    Message(sym_e_label_not_found);
                    code:=cerrornode.create;
                  end
                else
                  begin
                     if token=_ID then
                       consume_sym(srsym,srsymtable)
                     else
                      begin
                        if token<>_INTCONST then
                          internalerror(201008021);

                        { strip leading 0's in iso mode }
                        if m_iso in current_settings.modeswitches then
                          while pattern[1]='0' do
                            delete(pattern,1,1);

                        searchsym(pattern,srsym,srsymtable);
                        if srsym=nil then
                          begin
                            identifier_not_found(pattern);
                            srsym:=generrorsym;
                            srsymtable:=nil;
                          end;
                        consume(token);
                      end;

                     if srsym.typ<>labelsym then
                       begin
                          Message(sym_e_id_is_no_label_id);
                          code:=cerrornode.create;
                       end
                     else
                       begin
                         { goto is only allowed to labels within the current scope }
                         if not(m_iso in current_settings.modeswitches) and
                           (srsym.owner<>current_procinfo.procdef.localst) then
                           CGMessage(parser_e_goto_outside_proc);
                         code:=cgotonode.create(tlabelsym(srsym));
                         tgotonode(code).labelsym:=tlabelsym(srsym);
                         { set flag that this label is used }
                         tlabelsym(srsym).used:=true;
                       end;
                  end;
             end;
           _BEGIN :
             code:=statement_block(_BEGIN);
           _IF :
             code:=if_statement;
           _CASE :
             code:=case_statement;
           _REPEAT :
             code:=repeat_statement;
           _WHILE :
             code:=while_statement;
           _FOR :
             code:=for_statement;
           _WITH :
             code:=with_statement;
           _TRY :
             code:=try_statement;
           _RAISE :
             code:=raise_statement;
           { semicolons,else until and end are ignored }
           _SEMICOLON,
           _ELSE,
           _UNTIL,
           _END:
             code:=cnothingnode.create;
           _FAIL :
             begin
                if (current_procinfo.procdef.proctypeoption<>potype_constructor) then
                  Message(parser_e_fail_only_in_constructor);
                consume(_FAIL);
                code:=call_fail_node;
             end;
           _ASM :
             code:=_asm_statement;
           _EOF :
             Message(scan_f_end_of_file);
         else
           begin
             { don't typecheck yet, because that will also simplify, which may
               result in not detecting certain kinds of syntax errors --
               see mantis #15594 }
             p:=expr(false);
             { save the pattern here for latter usage, the label could be "000",
               even if we read an expression, the pattern is still valid if it's really
               a label (FK)
               if you want to mess here, take care of
               tests/webtbs/tw3546.pp
             }
             s:=pattern;

             { When a colon follows a intconst then transform it into a label }
             if (p.nodetype=ordconstn) and
                try_to_consume(_COLON) then
              begin
                { in iso mode, 0003: is equal to 3: }
                if m_iso in current_settings.modeswitches then
                  searchsym(tostr(tordconstnode(p).value),srsym,srsymtable)
                else
                  searchsym(s,srsym,srsymtable);
                p.free;

                if assigned(srsym) and
                   (srsym.typ=labelsym) then
                 begin
                   if tlabelsym(srsym).defined then
                     Message(sym_e_label_already_defined);
                   if symtablestack.top.symtablelevel<>srsymtable.symtablelevel then
                     begin
                       tlabelsym(srsym).nonlocal:=true;
                       exclude(current_procinfo.procdef.procoptions,po_inline);
                     end;
                   if tlabelsym(srsym).nonlocal and
                     (current_procinfo.procdef.proctypeoption in [potype_unitinit,potype_unitfinalize]) then
                     Message(sym_e_interprocgoto_into_init_final_code_not_allowed);

                   tlabelsym(srsym).defined:=true;
                   p:=clabelnode.create(nil,tlabelsym(srsym));
                   tlabelsym(srsym).code:=p;
                 end
                else
                 begin
                   Message1(sym_e_label_used_and_not_defined,s);
                   p:=cnothingnode.create;
                 end;
              end;

             if p.nodetype=labeln then
               begin
                 { the pointer to the following instruction }
                 { isn't a very clean way                   }
                 if token in endtokens then
                   tlabelnode(p).left:=cnothingnode.create
                 else
                   tlabelnode(p).left:=statement();
                 { be sure to have left also typecheckpass }
                 typecheckpass(tlabelnode(p).left);
               end
             else

             { change a load of a procvar to a call. this is also
               supported in fpc mode }
             if p.nodetype in [vecn,derefn,typeconvn,subscriptn,loadn] then
               maybe_call_procvar(p,false);

             { blockn support because a read/write is changed into a blocknode }
             { with a separate statement for each read/write operation (JM)    }
             { the same is true for val() if the third parameter is not 32 bit }
             if not(p.nodetype in [nothingn,errorn,calln,ifn,assignn,breakn,inlinen,
                                   continuen,labeln,blockn,exitn]) or
                ((p.nodetype=inlinen) and
                 not is_void(p.resultdef)) or
                ((p.nodetype=calln) and
                 (assigned(tcallnode(p).procdefinition)) and
                 (tcallnode(p).procdefinition.proctypeoption=potype_operator)) then
               Message(parser_e_illegal_expression);

             if not assigned(p.resultdef) then
               do_typecheckpass(p);

             { Specify that we don't use the value returned by the call.
               This is used for :
                - dispose of temp stack space
                - dispose on FPU stack
                - extended syntax checking }
             if (p.nodetype=calln) then
               begin
                 exclude(tcallnode(p).callnodeflags,cnf_return_value_used);

                 { in $x- state, the function result must not be ignored }
                 if not(cs_extsyntax in current_settings.moduleswitches) and
                    not(is_void(p.resultdef)) and
                    { can be nil in case there was an error in the expression }
                    assigned(tcallnode(p).procdefinition) and
                    not((tcallnode(p).procdefinition.proctypeoption=potype_constructor) and
                        assigned(tprocdef(tcallnode(p).procdefinition)._class) and
                        is_object(tprocdef(tcallnode(p).procdefinition)._class)) then
                   Message(parser_e_illegal_expression);
               end;
             code:=p;
           end;
         end;
        {$ENDIF}
         if assigned(Result) then
           begin
             typecheckpass(Result);
             Result.fileinfo:=filepos;
           end;
      end;


    function statement_blockOPL(starttoken : ttoken) : tnode;
      var
    {$IFDEF semclass}
        ssb: TSemStmtBlock;
    {$ELSE}
         first,last : tnode;
         filepos : tfileposinfo;
    {$ENDIF}

      begin
        {$IFDEF semclass}
          //todo: extract semantics
          ssb.SBInit;
        {$ELSE}
         first:=nil;
         filepos:=current_tokenpos;
        {$ENDIF}
         consume(starttoken);

         while not(token in [_END,_FINALIZATION]) do
           begin
            {$IFDEF semclass}
              ssb.ParseStmt(@statementOPL);
            {$ELSE}
              if first=nil then
                begin
                   last:=cstatementnode.create(statement,nil);
                   first:=last;
                end
              else
                begin
                   tstatementnode(last).right:=cstatementnode.create(statement,nil);
                   last:=tstatementnode(last).right;
                end;
            {$ENDIF}
              if (token in [_END,_FINALIZATION]) then
                break
              else
                begin
                   { if no semicolon, then error and go on }
                   if token<>_SEMICOLON then
                     begin
                        consume(_SEMICOLON);
                        consume_all_until(_SEMICOLON);
                     end;
                   consume(_SEMICOLON);
                end;
              consume_emptystats;
           end;

         { don't consume the finalization token, it is consumed when
           reading the finalization block, but allow it only after
           an initalization ! }
         if (starttoken<>_INITIALIZATION) or (token<>_FINALIZATION) then
           consume(_END);
       {$IFDEF semclass}
          Result := ssb.SBDone;
       {$ELSE}
         last:=cblocknode.create(first);
         last.fileinfo:=filepos;
         Result:=last;
       {$ENDIF}
      end;

end.
