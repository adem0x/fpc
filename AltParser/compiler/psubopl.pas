{
    Copyright (c) 1998-2002 by Florian Klaempfl, Daniel Mantione, Dr. Diettrich

    Does the parsing at subroutine level.
    Mostly copied from psub.pas.

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
unit psubOPL;

{$i fpcdefs.inc}

{$DEFINE semclass} //using semantic class/object TSemSub?
{.$DEFINE imports} //importing additional units?
{$DEFINE FastSpecialize} //speedup specialize_objectdefs()?

interface

    uses
      node,psub;

    { new name for block() }
    function  ParseBlock(is_Library : boolean) : tnode;
    { wrapper for ParseBlock, original tcgprocinfo.parse_body }
    procedure ParseBody(pi: tcgprocinfo);

    { new name for read_declarations }
    procedure ReadDeclarations(is_Library : boolean);
    { new name for read_interface_declarations }
    procedure ReadInterfaceDeclarations;
    { new name for generate_specialization_procs }
    procedure _generate_specialization_procs;

implementation

    uses
       sysutils,
       { common }
       cutils,
       { global }
       globals,globtype,tokens,verbose,comphook,constexp,
       systems,procinfo,
{$IFDEF semclass}
       SSub,pstatmnt,PStatmntOPL,
       { symtable }
       symconst,symbase,symsym,symtype,{symtable,defutil,}symdef,
       //paramgr,
       ppu,fmodule,
       { pass 1 }
       //nutils,nld,ncal,ncon,nflw,nadd,ncnv,nmem,
       nbas,
       //pass_1,
{$ELSE}
  {$DEFINE imports}
{$ENDIF}
{$IFDEF imports}
       { aasm }
       cpuinfo,cpubase,aasmbase,aasmtai,aasmdata,
       { symtable }
       symconst,symbase,symsym,symtype,symtable,defutil,symdef,
       paramgr,
       ppu,fmodule,
       { pass 1 }
       nutils,nld,ncal,ncon,nflw,nadd,ncnv,nmem,
       nbas,
       pass_1,
    {$ifdef state_tracking}
       nstate,
    {$endif state_tracking}
       { pass 2 }
{$ifndef NOPASS2}
       pass_2,
{$endif}
{$ENDIF imports}
       { parser }
       scanner,import,gendef,
       pbase,pdecl,pdecsub,{PDecSubOPL,}pexports
{$IFDEF imports}
       { codegen }
       ,tgobj,cgbase,cgobj,cgcpu,dbgbase,
       ncgutil,regvars,
       optbase,
       opttail,
       optcse,optloop,
       optutils
{$if defined(arm) or defined(powerpc) or defined(powerpc64)}
       ,aasmcpu
{$endif arm}
       {$ifndef NOOPT}
         {$ifdef i386}
           ,aopt386
         {$else i386}
           ,aopt
         {$endif i386}
       {$endif}
{$ELSE}
{$ENDIF imports}
       ;

{ References to external parser procedures:
  ParseBlock
  -> read_declarations
    [here]
  -> pstatmnt.assembler_block
    [deserves no modifications]
  -> pstatmnt.statement_block
    [virtualized]
  ParseBody
  -> ParseBlock
    [here]
  read_proc_body
  -> ParseBody
    [here]
  read_proc
  -> pdecsub.parse_proc_dec
  -> pdecsub.parse_proc_directives
  -> pbase.try_consume_hintdirective
    [clean]
  -> (here.)read_proc_body
  ReadDeclarations
  -> pdecl.label_dec, const_dec, type_dec, var_dec, resourcestring_dec, property_dec
  -> (here.)read_proc
  -> pexports.read_exports
  ReadInterfaceDeclarations
  -> (same as read_declarations)
  -> var_dec, threadvar_dec
  -> (here.)read_proc
  specialize_objectdefs
  -> (here.)read_proc_body
}

{****************************************************************************
                      PROCEDURE/FUNCTION BODY PARSING
****************************************************************************}

    function ParseBlock(is_Library : boolean) : tnode;
      begin
         { parse const,types and vars }
         ReadDeclarations(is_Library);  //<---------- parse!

         { do we have an assembler block without the po_assembler?
           we should allow this for Delphi compatibility (PFV) }
         if (token=_ASM) and (m_delphi in current_settings.modeswitches) then
           include(current_procinfo.procdef.procoptions,po_assembler);

         { Handle assembler block different }
         if (po_assembler in current_procinfo.procdef.procoptions) then
          begin
            Result:=assembler_block;
            exit;
          end;

         {Unit initialization?}
         if (
             assigned(current_procinfo.procdef.localst) and
             (current_procinfo.procdef.localst.symtablelevel=main_program_level) and
             (current_module.is_unit or is_Library)
            ) then
           begin //unit or library module block (module body)
             if (token=_END) then
                begin
                   consume(_END);
                   { We need at least a node, else the entry/exit code is not
                     generated and thus no PASCALMAIN symbol which we need (PFV) }
                   if is_Library then
                    Result:=cnothingnode.create
                   else
                    Result:=nil;
                end
              else
                begin
                   if token=_INITIALIZATION then
                     begin
                        { The library init code is already called and does not
                          need to be in the initfinal table (PFV) }
                        Result:=statement_blockOPL(_INITIALIZATION);
                        { optimize empty initialization block away }
                        if (Result.nodetype=blockn) and (tblocknode(Result).left=nil) then
                          FreeAndNil(Result)
                        else
                          if not is_Library then
                            current_module.flags:=current_module.flags or uf_init;
                     end
                   else if token=_FINALIZATION then
                     begin
                       { when a unit has only a finalization section, we can come to this
                         point when we try to read the nonh existing initalization section
                         so we've to check if we are really try to parse the finalization }
                       if current_procinfo.procdef.proctypeoption=potype_unitfinalize then
                         begin
                           Result:=statement_blockOPL(_FINALIZATION);
                           { optimize empty finalization block away }
                           if (Result.nodetype=blockn) and (tblocknode(Result).left=nil) then
                             FreeAndNil(Result)
                           else
                             current_module.flags:=current_module.flags or uf_finalize;
                         end
                         else
                           Result:=nil;
                     end
                   else
                     begin
                        { The library init code is already called and does not
                          need to be in the initfinal table (PFV) }
                        if not is_Library then
                          current_module.flags:=current_module.flags or uf_init;
                        Result:=statement_blockOPL(_BEGIN);
                     end;
                end;
            end
         else
            begin //any other statement block (module or procedure level)
               Result:=statement_blockOPL(_BEGIN);
            {$IFDEF semclass}
              SBlockVarInitialization(Result);
            {$ELSE}
               if current_procinfo.procdef.localst.symtabletype=localsymtable then
                 current_procinfo.procdef.localst.SymList.ForEachCall(@initializevars,Result);
            {$ENDIF}
            end;
      end;

    procedure ParseBody(pi: tcgprocinfo);
    var
      rpb: RParseBody;
    begin
    { wrapper, replaces tcgprocinfo.parse_block() }
      pi.ParseBodyInit(rpb);
      pi.code := ParseBlock(current_module.isLibrary);
      pi.ParseBodyDone(rpb);
    end;

    procedure Read_Proc_Body(_old_current_procinfo:tprocinfo;_pd:tprocdef);
      {
        Parses the procedure directives, then parses the procedure body, then
        generates the code for it
      }
    {$IFDEF semclass}
      var
        rrpb: TReadProcBody;
    {$ELSE}
      type
        RReadProcBody = record
        oldfailtokenmode : tmodeswitch;
        isnestedproc     : boolean;
        pd: tprocdef;
        old_current_procinfo:tprocinfo;
        end;
      var
        rrpb: RReadProcBody;
    {$ENDIF}
      begin
    {$IFDEF semclass}
        rrpb.ProcBodyInit(_pd, _old_current_procinfo);
    {$ELSE}
        rrpb.old_current_procinfo := _old_current_procinfo;
        rrpb.pd := _pd;
        Message1(parser_d_procedure_start,rrpb.pd.fullprocname(false));

        { create a new procedure }
        current_procinfo:=cprocinfo.create(rrpb.old_current_procinfo);
        current_module.procinfo:=current_procinfo;
        current_procinfo.procdef:=rrpb.pd;
        rrpb.isnestedproc:=(current_procinfo.procdef.parast.symtablelevel>normal_function_level);

        { Insert mangledname }
        rrpb.pd.aliasnames.insert(rrpb.pd.mangledname);

        { Handle Export of this procedure }
        if (po_exports in rrpb.pd.procoptions) and
           (target_info.system in [system_i386_os2,system_i386_emx]) then
          begin
            rrpb.pd.aliasnames.insert(rrpb.pd.procsym.realname);
            if cs_link_deffile in current_settings.globalswitches then
              deffile.AddExport(rrpb.pd.mangledname);
          end;

        { Insert result variables in the localst }
        insert_funcret_local(rrpb.pd);

        { check if there are para's which require initing -> set }
        { pi_do_call (if not yet set)                            }
        if not(pi_do_call in current_procinfo.flags) then
          rrpb.pd.parast.SymList.ForEachCall(@check_init_paras,nil);

        { set _FAIL as keyword if constructor }
        if (rrpb.pd.proctypeoption=potype_constructor) then
         begin
           rrpb.oldfailtokenmode:=tokeninfo^[_FAIL].keyword;
           tokeninfo^[_FAIL].keyword:=m_all;
         end;
    {$ENDIF}

    {$IFDEF semclass}
        ParseBody(tcgprocinfo(current_procinfo));
    {$ELSE}
        tcgprocinfo(current_procinfo).parse_body; //<----------- parse!
    {$ENDIF}

    {$IFDEF semclass}
        //SReadProcBodyDone(rrpb, pd);
        rrpb.ProcBodyDone;
    {$ELSE}
        { We can't support inlining for procedures that have nested
          procedures because the nested procedures use a fixed offset
          for accessing locals in the parent procedure (PFV) }
        if (tcgprocinfo(current_procinfo).nestedprocs.count>0) then
          begin
            if (df_generic in current_procinfo.procdef.defoptions) then
              Comment(V_Error,'Generic methods cannot have nested procedures')
            else
             if (po_inline in current_procinfo.procdef.procoptions) then
              begin
                Message1(parser_w_not_supported_for_inline,'nested procedures');
                Message(parser_w_inlining_disabled);
                exclude(current_procinfo.procdef.procoptions,po_inline);
              end;
          end;

        { When it's a nested procedure then defer the code generation,
          when back at normal function level then generate the code
          for all defered nested procedures and the current procedure }
        if rrpb.isnestedproc then
          tcgprocinfo(current_procinfo.parent).nestedprocs.insert(current_procinfo)
        else
          begin
            if not(df_generic in current_procinfo.procdef.defoptions) then
              tcgprocinfo(current_procinfo).do_generate_code;
          end;

        { reset _FAIL as _SELF normal }
        if (rrpb.pd.proctypeoption=potype_constructor) then
          tokeninfo^[_FAIL].keyword:=rrpb.oldfailtokenmode;

        { release procinfo }
        if tprocinfo(current_module.procinfo)<>current_procinfo then
          internalerror(200304274);
        current_module.procinfo:=current_procinfo.parent;
    {$ENDIF}

        { For specialization we didn't record the last semicolon. Moving this parsing
          into the parse_body routine is not done because of having better file position
          information available }
        if not(df_specialization in current_procinfo.procdef.defoptions) then
          consume(_SEMICOLON); //<---------------------------------------- parse!

        if not rrpb.isnestedproc then
          { current_procinfo is checked for nil later on }
          freeandnil(current_procinfo);
      end;


    procedure read_proc(isclassmethod:boolean);
      {
        Parses the procedure directives, then parses the procedure body, then
        generates the code for it
      }

      {$IFDEF semclass}
      var
        ss: TSemSub;
      {$ELSE}
      type
        RSemSub = record
        old_current_procinfo : tprocinfo;
        old_current_objectdef : tobjectdef;
        pd: tprocdef;
        end;
      var
        ss: RSemSub;
        s          : string;
        firstpd : tprocdef;
      {$ENDIF}
        pdflags    : tpdflags;
      begin
      {$IFDEF semclass}
        ss.Init;
      {$ELSE semclass}
        begin //constructor
         { save old state }
         ss.old_current_procinfo:=current_procinfo;
         ss.old_current_objectdef:=current_objectdef;

         { reset current_procinfo.procdef to nil to be sure that nothing is writing
           to another procdef }
         current_procinfo:=nil;
         current_objectdef:=nil;
        end;
      {$ENDIF}
         { parse procedure declaration }
         ss.pd:=parse_proc_dec(isclassmethod, ss.old_current_objectdef);
      {$IFDEF semclass}
         pdflags := ss.SDefaultProcOptions;
         { parse the directives that may follow }
         parse_proc_directives(ss.pd,pdflags); //<--------------- parse

         { hint directives, these can be separated by semicolons here,
           that needs to be handled here with a loop (PFV) }
         while try_consume_hintdirective(ss.pd.symoptions,ss.pd.deprecatedmsg) do
          Consume(_SEMICOLON);
      {$ELSE}
        begin //SDefaultProcOptions;
         { set the default function options }
         if parse_only then
          begin
            ss.pd.forwarddef:=true;
            { set also the interface flag, for better error message when the
              implementation doesn't much this header }
            ss.pd.interfacedef:=true;
            include(ss.pd.procoptions,po_global);
            pdflags:=[pd_interface];
          end
         else
          begin
            pdflags:=[pd_body];
            if (not current_module.in_interface) then
              include(pdflags,pd_implemen);
            if (not current_module.is_unit) or
               create_smartlink or
              {
                taking addresses of static procedures goes wrong
                if they aren't global when pic is used (FK)
              }
              (cs_create_pic in current_settings.moduleswitches) then
              include(ss.pd.procoptions,po_global);
            ss.pd.forwarddef:=false;
          end;
        end;
         { parse the directives that may follow }
         parse_proc_directives(ss.pd,pdflags); //<--------------- parse

         { hint directives, these can be separated by semicolons here,
           that needs to be handled here with a loop (PFV) }
         while try_consume_hintdirective(ss.pd.symoptions,ss.pd.deprecatedmsg) do
          Consume(_SEMICOLON);
      {$ENDIF}

      {$IFDEF semclass}
        ss.SProcDirectivesDone;
         { compile procedure when a body is needed }
         if (pd_body in pdflags) then
           begin
             Read_Proc_Body(ss.old_current_procinfo,ss.pd);
           end
         else
            ss.SHandleImports;
      {$ELSE}
        begin //SProcDirectivesDone
         { Set calling convention }
         handle_calling_convention(ss.pd);

         { search for forward declarations }
         if not proc_add_definition(ss.pd) then
           begin
             { A method must be forward defined (in the object declaration) }
             if assigned(ss.pd._class) and
                (not assigned(ss.old_current_objectdef)) then
              begin
                MessagePos1(ss.pd.fileinfo,parser_e_header_dont_match_any_member,ss.pd.fullprocname(false));
                tprocsym(ss.pd.procsym).write_parameter_lists(ss.pd);
              end
             else
              begin
                { Give a better error if there is a forward def in the interface and only
                  a single implementation }
                ss.firstpd:=tprocdef(tprocsym(ss.pd.procsym).ProcdefList[0]);
                if (not ss.pd.forwarddef) and
                   (not ss.pd.interfacedef) and
                   (tprocsym(ss.pd.procsym).ProcdefList.Count>1) and
                   ss.firstpd.forwarddef and
                   ss.firstpd.interfacedef and
                   not(tprocsym(ss.pd.procsym).ProcdefList.Count>2) and
                   { don't give an error if it may be an overload }
                   not(m_fpc in current_settings.modeswitches) and
                   (not(po_overload in ss.pd.procoptions) or
                    not(po_overload in ss.firstpd.procoptions)) then
                 begin
                   MessagePos1(ss.pd.fileinfo,parser_e_header_dont_match_forward,ss.pd.fullprocname(false));
                   tprocsym(ss.pd.procsym).write_parameter_lists(ss.pd);
                 end;
              end;
           end;

         { Set mangled name }
         proc_set_mangledname(ss.pd);
        end;
         { compile procedure when a body is needed }
         if (pd_body in pdflags) then
           begin
             read_proc_body(ss.old_current_procinfo,ss.pd);
           end
         else
           begin  //SHandleImports
             { Handle imports }
             if (po_external in ss.pd.procoptions) then
               begin
                 { External declared in implementation, and there was already a
                   forward (or interface) declaration then we need to generate
                   a stub that calls the external routine }
                 if (not ss.pd.forwarddef) and
                    (ss.pd.hasforward) and
                    not(
                        assigned(ss.pd.import_dll) and
                        (target_info.system in [system_i386_wdosx,
                                                system_arm_wince,system_i386_wince])
                       ) then
                   begin
                     s:=proc_get_importname(ss.pd);
                     if s<>'' then
                       gen_external_stub(current_asmdata.asmlists[al_procedures],ss.pd,s);
                   end;

                 { Import DLL specified? }
                 if assigned(ss.pd.import_dll) then
                   current_module.AddExternalImport(ss.pd.import_dll^,proc_get_importname(ss.pd),ss.pd.import_nr,false,ss.pd.import_name=nil)
                 else
                   begin
                     { add import name to external list for DLL scanning }
                     if tf_has_dllscanner in target_info.flags then
                       current_module.dllscannerinputlist.Add(proc_get_importname(ss.pd),ss.pd);
                   end;
               end;
           end;
      {$ENDIF}
      {$IFDEF semclass}
          ss.SProcDone;
      {$ELSE}
        begin //SProcDone
         { make sure that references to forward-declared functions are not }
         { treated as references to external symbols, needed for darwin.   }

         { make sure we don't change the binding of real external symbols }
         if not(po_external in ss.pd.procoptions) then
           begin
             if (po_global in ss.pd.procoptions) or
                (cs_profile in current_settings.moduleswitches) then
               current_asmdata.DefineAsmSymbol(ss.pd.mangledname,AB_GLOBAL,AT_FUNCTION)
             else
               current_asmdata.DefineAsmSymbol(ss.pd.mangledname,AB_LOCAL,AT_FUNCTION);
           end;
        end;
      {$ENDIF}
{$IFDEF semclass}
        ss.done;
{$ELSE}
         current_objectdef:=ss.old_current_objectdef;
         current_procinfo:=ss.old_current_procinfo;
{$ENDIF}
      end;

{****************************************************************************
                             DECLARATION PARSING
****************************************************************************}

    procedure ReadDeclarations(is_Library : boolean);
      var
        is_classdef:boolean; {found "class" prefix on method...}
      begin
        is_classdef:=false;
        repeat
           if not assigned(current_procinfo) then
             internalerror(200304251);
           case token of
              _LABEL:
                label_dec;
              _CONST:
                const_dec;
              _TYPE:
                type_dec;
              _VAR:
                var_dec;
              _THREADVAR:
                threadvar_dec;
              _CLASS:
                begin
                  is_classdef:=false;
                  //if try_to_consume(_CLASS) then
                  consume(_CLASS);
                   begin
                     { class modifier is only allowed for procedures, functions, }
                     { constructors, destructors, fields and properties          }
                     if not(token in [_FUNCTION,_PROCEDURE,_PROPERTY,_VAR,_CONSTRUCTOR,_DESTRUCTOR]) then
                       Message(parser_e_procedure_or_function_expected);

                     if is_interface(current_objectdef) then
                       Message(parser_e_no_static_method_in_interfaces)
                     else
                       { class methods are also allowed for Objective-C protocols }
                       is_classdef:=true;
                   end;
                end;
              _CONSTRUCTOR,
              _DESTRUCTOR,
              _FUNCTION,
              _PROCEDURE,
              _OPERATOR:
                begin
                  read_proc(is_classdef);
                  is_classdef:=false;
                end;
              _EXPORTS:
                begin
                   if (current_procinfo.procdef.localst.symtablelevel>main_program_level) then
                     begin
                        Message(parser_e_syntax_error);
                        consume_all_until(_SEMICOLON); //recover: skip to end of clause
                     end
                   else if is_Library or
                     (target_info.system in systems_unit_program_exports) then
                     read_exports //<------------------------------------- parse.
                   else
                     begin
                        Message(parser_w_unsupported_feature);
                        consume(_BEGIN); //force error
                     end;
                end
              else
                begin
                  case idtoken of
                    _RESOURCESTRING :
                      begin
                        { m_class is needed, because the resourcestring
                          loading is in the ObjPas unit }
{                        if (m_class in current_settings.modeswitches) then}
                          resourcestring_dec //<-------------------------- parse!
{                        else
                          break;}
                      end;
                    _PROPERTY:
                      begin
                        if (m_fpc in current_settings.modeswitches) then
                        begin
                          property_dec(is_classdef); //<------------------ parse!
                          is_classdef:=false;
                        end
                        else
                          break;
                      end;
                    else
                      break;
                  end;
                end;
           end;
         until false;

         { check for incomplete class definitions, this is only required
           for fpc modes }
        {$IFDEF semclass}
         SCheckIncompleteClassDefinitions;
        {$ELSE}
         if (m_fpc in current_settings.modeswitches) then
           current_procinfo.procdef.localst.SymList.ForEachCall(@check_forward_class,nil);
        {$ENDIF}
      end;

    procedure ReadInterfaceDeclarations;
      begin
         repeat
           case token of
             _CONST :
               const_dec;
             _TYPE :
               type_dec;
             _VAR :
               var_dec;
             _THREADVAR :
               threadvar_dec;
             _FUNCTION,
             _PROCEDURE,
             _OPERATOR :
               read_proc(false);
             else
               begin
                 case idtoken of
                   _RESOURCESTRING :
                     resourcestring_dec;
                   _PROPERTY:
                     begin
                       if (m_fpc in current_settings.modeswitches) then
                         property_dec(false)
                       else
                         break;
                     end;
                   else
                     break;
                 end;
               end;
           end;
         until false;
         { check for incomplete class definitions, this is only required
           for fpc modes }
      {$IFDEF semclass}
         SCheckInterfaceIncompleteClassDefinitions;
      {$ELSE}
         if (m_fpc in current_settings.modeswitches) then
          symtablestack.top.SymList.ForEachCall(@check_forward_class,nil);
      {$ENDIF}
      end;


{****************************************************************************
                      SPECIALIZATION BODY GENERATION
****************************************************************************}


    procedure specialize_objectdefs(p:TObject;arg:pointer);
      var
        i  : longint;
        hp : tdef;
        oldcurrent_filepos : tfileposinfo;
        oldsymtablestack   : tsymtablestack;
        pu : tused_unit;
        hmodule : tmodule;
        specobj : tobjectdef;
      begin
        if not((tsym(p).typ=typesym) and
               (ttypesym(p).typedef.typesym=tsym(p)) and
               (ttypesym(p).typedef.typ=objectdef) and
               (df_specialization in ttypesym(p).typedef.defoptions)
              ) then
          exit;

        { Setup symtablestack a definition time }
        specobj:=tobjectdef(ttypesym(p).typedef);
      {$IFDEF FastSpecialize}
        if not(is_class(specobj) or is_object(specobj)) then // ---- check before???
          exit;
      {$ENDIF}
        oldsymtablestack:=symtablestack;
        symtablestack:=tsymtablestack.create;
        if not assigned(tobjectdef(ttypesym(p).typedef).genericdef) then
          internalerror(200705151);
        hmodule:=find_module_from_symtable(specobj.genericdef.owner);
        if hmodule=nil then
          internalerror(200705152);
        pu:=tused_unit(hmodule.used_units.first);
        while assigned(pu) do
          begin
            if not assigned(pu.u.globalsymtable) then
              internalerror(200705153);
            symtablestack.push(pu.u.globalsymtable);
            pu:=tused_unit(pu.next);
          end;
        if assigned(hmodule.globalsymtable) then
          symtablestack.push(hmodule.globalsymtable);
        if assigned(hmodule.localsymtable) then
          symtablestack.push(hmodule.localsymtable);

        { procedure definitions for classes or objects }
      {$IFDEF FastSpecialize}
        //checked above
      {$ELSE}
        if is_class(specobj) or is_object(specobj) then // ---- check before???
      {$ENDIF}
          begin
            for i:=0 to specobj.symtable.DefList.Count-1 do
              begin
                hp:=tdef(specobj.symtable.DefList[i]);
                if hp.typ=procdef then
                 begin
                   if assigned(tprocdef(hp).genericdef) and
                     (tprocdef(hp).genericdef.typ=procdef) and
                     assigned(tprocdef(tprocdef(hp).genericdef).generictokenbuf) then
                     begin
                       oldcurrent_filepos:=current_filepos;
                       current_filepos:=tprocdef(tprocdef(hp).genericdef).fileinfo;
                       { use the index the module got from the current compilation process }
                       current_filepos.moduleindex:=hmodule.unit_index;
                       current_tokenpos:=current_filepos;
                       current_scanner.startreplaytokens(tprocdef(tprocdef(hp).genericdef).generictokenbuf);
                       Read_Proc_Body(nil,tprocdef(hp));  //<------------ parse!
                       current_filepos:=oldcurrent_filepos;
                     end
                   else
                     MessagePos1(tprocdef(hp).fileinfo,sym_e_forward_not_resolved,tprocdef(hp).fullprocname(false));
                 end;
             end;
          end;

        { Restore symtablestack }
        symtablestack.free;
        symtablestack:=oldsymtablestack;
      end;

    procedure _generate_specialization_procs;
      begin
        if assigned(current_module.globalsymtable) then
          current_module.globalsymtable.SymList.ForEachCall(@specialize_objectdefs,nil);
        if assigned(current_module.localsymtable) then
          current_module.localsymtable.SymList.ForEachCall(@specialize_objectdefs,nil);
      end;

end.
