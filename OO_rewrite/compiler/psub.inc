//psub.inc from psub.pas

{.$DEFINE old_class} //allow for unit level "class" variables and properties?

{****************************************************************************
                             DECLARATION PARSING
****************************************************************************}

    { search in symtablestack for not complete classes }
    procedure check_forward_class(p:TObject;arg:pointer);
      begin
        if (tsym(p).typ=typesym) and
           (ttypesym(p).typedef.typ=objectdef) and
           (oo_is_forward in tobjectdef(ttypesym(p).typedef).objectoptions) then
          MessagePos1(tsym(p).fileinfo,sym_e_forward_type_not_resolved,tsym(p).realname);
      end;


    procedure TOPLParser.read_declarations(islibrary : boolean);
      var
        is_classdef:boolean;
      begin
      (* Parse declarations at unit or procedure scope.
        Also procedure definitions?
      *)
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
                begin
                  var_dec;  //(is_classdef); ???
                  is_classdef:=false;
                end;
              _THREADVAR:
                threadvar_dec;
              _CLASS:
                begin
                  consume(_CLASS);
                  is_classdef:=true;
                  { class modifier is only allowed for procedures, functions, }
                  { constructors, destructors, fields and properties          }
                  { class methods are also allowed for Objective-C protocols }
                  if not(token in [_FUNCTION,_PROCEDURE,
                      {$IFDEF old_class}
                        _PROPERTY,_VAR,
                      {$ELSE}
                        //makes no sense to me
                      {$ENDIF}
                      _CONSTRUCTOR,_DESTRUCTOR]) then
                    Message(parser_e_procedure_or_function_expected);

                  if is_interface(current_objectdef) then
                    Message(parser_e_no_static_method_in_interfaces);
                end;
              _CONSTRUCTOR,
              _DESTRUCTOR,
              _FUNCTION,
              _PROCEDURE,
              _OPERATOR:
                begin
                  read_proc(is_classdef); //implementation!
                  is_classdef:=false;
                end;
              _EXPORTS:
                begin
                   if (current_procinfo.procdef.localst.symtablelevel>main_program_level) then
                     begin
                        Message(parser_e_syntax_error);
                        consume_all_until(_SEMICOLON);
                     end
                   else if islibrary or
                     (target_info.system in systems_unit_program_exports) then
                     read_exports
                   else
                     begin
                        Message(parser_w_unsupported_feature);
                        consume(_BEGIN);
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
                          resourcestring_dec
{                        else
                          break;}
                      end;
                    _PROPERTY:
                      begin
                        if (m_fpc in current_settings.modeswitches) then
                        begin
                          property_dec; //(is_classdef);  //no "class" modifier here!
                        {$IFDEF old_class}
                          is_classdef:=false;
                        {$ENDIF}
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
         if (m_fpc in current_settings.modeswitches) then
           current_procinfo.procdef.localst.SymList.ForEachCall(@check_forward_class,nil);
      end;


    procedure TOPLParser.read_interface_declarations;
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
                         property_dec //(false)
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
         if (m_fpc in current_settings.modeswitches) then
          symtablestack.top.SymList.ForEachCall(@check_forward_class,nil);
      end;


{****************************************************************************
                      PROCEDURE/FUNCTION BODY PARSING
****************************************************************************}

    procedure initializevars(p:TObject;arg:pointer);
      var
        b : tblocknode;
      begin
        if not (tsym(p).typ in [localvarsym,staticvarsym]) then
         exit;
        with tabstractnormalvarsym(p) do
         begin
           if assigned(defaultconstsym) then
            begin
              b:=tblocknode(arg);
              b.left:=cstatementnode.create(
                        cassignmentnode.create(
                            cloadnode.create(tsym(p),tsym(p).owner),
                            cloadnode.create(defaultconstsym,defaultconstsym.owner)),
                        b.left);
            end;
         end;
      end;

{$IFDEF new}

    procedure check_finalize_paras(p:TObject;arg:pointer);
      begin
        if (tsym(p).typ=paravarsym) and
           (tparavarsym(p).varspez=vs_value) and
           is_managed_type(tparavarsym(p).vardef) then
          include(current_procinfo.flags,pi_needs_implicit_finally);
      end;


    procedure check_finalize_locals(p:TObject;arg:pointer);
      begin
        { include the result: it needs to be finalized in case an exception }
        { occurs                                                            }
        if (tsym(p).typ=localvarsym) and
           (tlocalvarsym(p).refs>0) and
           is_managed_type(tlocalvarsym(p).vardef) then
          include(current_procinfo.flags,pi_needs_implicit_finally);
      end;
{$ELSE}
{$ENDIF}

{****************************************************************************
                        PROCEDURE/FUNCTION PARSING
****************************************************************************}

//called in ForEach
    procedure check_init_paras(p:TObject;arg:pointer);
    var
      current_procinfo: tprocinfo absolute arg;
      begin
        if tsym(p).typ<>paravarsym then
         exit;
        with tparavarsym(p) do
          if is_managed_type(vardef) and
             (varspez in [vs_value,vs_out]) then
            include(current_procinfo.flags,pi_do_call);
      end;


    procedure TOPLParser.parse_body(procinfo: tprocinfo);
    var
      saved_procinfo: TSavedProc;
    begin
    (* This is the psub.tcgprocinfo.parse_body method replacement.
      tcgprocinfo.parse_body has been splitted into an _init and _done method,
      and we are calling the removed block() method here.

      saved_procinfo preserves the old state across the block() call.

      We also handle some statements with inaccessible elements in psub.
    *)
      //tcgprocinfo(current_procinfo).parse_body;
        { parse the code ... }
        tcgprocinfo(procinfo).parse_body_init(saved_procinfo);  //part 1

        if saved_procinfo.recording then
          startrecordtokens(procinfo.procdef.generictokenbuf);

      //call the block() method, inaccessible in psub
        tcgprocinfo(procinfo).code:=block(current_module.islibrary);  //, current_procinfo);

      //added syntax from psub
      //these are local to the scanner/parser, inaccessible in psub
        if saved_procinfo.recording then
          stoprecordtokens;
        procinfo.exitswitches := current_settings.localswitches;
        procinfo.exitpos:= last_endtoken_filepos;

        tcgprocinfo(procinfo).parse_body_done(saved_procinfo);  //part 2
    end;

    procedure toplparser.read_proc_body(old_current_procinfo:tprocinfo;pd:tprocdef);
      {
        Parses the procedure directives, then parses the procedure body, then
        generates the code for it.

        Called by read_proc (make local?)
      }
      procedure do_generate_code(pi:tcgprocinfo);
        var
          hpi : tcgprocinfo;
        begin
          { generate code for this procedure }
          pi.generate_code;
          { process nested procs }
          hpi:=tcgprocinfo(pi.nestedprocs.first);
          while assigned(hpi) do
           begin
             do_generate_code(hpi);
             hpi:=tcgprocinfo(hpi.next);
           end;
          pi.resetprocdef;
        end;

      var
        oldfailtokenmode : tmodeswitch;
        isnestedproc     : boolean;
      begin //read_proc_body
        Message1(parser_d_procedure_start,pd.fullprocname(false));

        { create a new procedure }
        current_procinfo:=cprocinfo.create(old_current_procinfo);
        current_module.procinfo:=current_procinfo;
        current_procinfo.procdef:=pd;
        isnestedproc:=(current_procinfo.procdef.parast.symtablelevel>normal_function_level);

        { Insert mangledname }
        pd.aliasnames.insert(pd.mangledname);

        { Handle Export of this procedure }
        if (po_exports in pd.procoptions) and
           (target_info.system in [system_i386_os2,system_i386_emx]) then
          begin
            pd.aliasnames.insert(pd.procsym.realname);
            if cs_link_deffile in current_settings.globalswitches then
              deffile.AddExport(pd.mangledname);
          end;

        { Insert result variables in the localst }
        insert_funcret_local(pd);

        { check if there are para's which require initing -> set }
        { pi_do_call (if not yet set)                            }
        if not(pi_do_call in current_procinfo.flags) then
          pd.parast.SymList.ForEachCall(@check_init_paras,current_procinfo);  // nil);

        { set _FAIL as keyword if constructor }
        if (pd.proctypeoption=potype_constructor) then
         begin
           oldfailtokenmode:=tokeninfo^[_FAIL].keyword;
           tokeninfo^[_FAIL].keyword:=m_all;
         end;

        { parse the code ... }
      {$IFDEF old}
        tcgprocinfo(current_procinfo).parse_body; //(block);
      {$ELSE}
        parse_body(current_procinfo);
      {$ENDIF}

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
        if isnestedproc then
          tcgprocinfo(current_procinfo.parent).nestedprocs.insert(current_procinfo)
        else
          begin
            if not(df_generic in current_procinfo.procdef.defoptions) then
              do_generate_code(tcgprocinfo(current_procinfo));
          end;

        { reset _FAIL as _SELF normal }
        if (pd.proctypeoption=potype_constructor) then
          tokeninfo^[_FAIL].keyword:=oldfailtokenmode;

        { release procinfo }
        if tprocinfo(current_module.procinfo)<>current_procinfo then
          internalerror(200304274);
        current_module.procinfo:=current_procinfo.parent;

        { For specialization we didn't record the last semicolon. Moving this parsing
          into the parse_body routine is not done because of having better file position
          information available }
        if not(df_specialization in current_procinfo.procdef.defoptions) then
          current_scanner.consume(_SEMICOLON);

        if not isnestedproc then
          { current_procinfo is checked for nil later on }
          freeandnil(current_procinfo);
      end;

    procedure TOPLParser.read_proc(isclassmethod:boolean);
      {
        Parses the procedure directives, then parses the procedure body, then
        generates the code for it.
      }

      var
        old_current_procinfo : tprocinfo;
        old_current_objectdef : tobjectdef;
        pdflags    : tpdflags;
        pd,firstpd : tprocdef;
        s          : string;
      begin
         { save old state }
         old_current_procinfo:=current_procinfo;
         old_current_objectdef:=current_objectdef;

         { reset current_procinfo.procdef to nil to be sure that nothing is writing
           to an other procdef }
         current_procinfo:=nil;
         current_objectdef:=nil;

         { parse procedure declaration }
         pd:=parse_proc_dec(isclassmethod, old_current_objectdef);

         { set the default function options }
         if parse_only then
          begin
            pd.forwarddef:=true;
            { set also the interface flag, for better error message when the
              implementation doesn't much this header }
            pd.interfacedef:=true;
            include(pd.procoptions,po_global);
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
              include(pd.procoptions,po_global);
            pd.forwarddef:=false;
          end;

         { parse the directives that may follow }
         parse_proc_directives(pd,pdflags);

         { hint directives, these can be separated by semicolons here,
           that needs to be handled here with a loop (PFV) }
         while try_consume_hintdirective(pd.symoptions,pd.deprecatedmsg) do
          Consume(_SEMICOLON);

         { Set calling convention }
         handle_calling_convention(pd, parse_only);

         { search for forward declarations }
         if not proc_add_definition(pd) then
           begin
             { A method must be forward defined (in the object declaration) }
             if assigned(pd._class) and
                (not assigned(old_current_objectdef)) then
              begin
                MessagePos1(pd.fileinfo,parser_e_header_dont_match_any_member,pd.fullprocname(false));
                tprocsym(pd.procsym).write_parameter_lists(pd);
              end
             else
              begin
                { Give a better error if there is a forward def in the interface and only
                  a single implementation }
                firstpd:=tprocdef(tprocsym(pd.procsym).ProcdefList[0]);
                if (not pd.forwarddef) and
                   (not pd.interfacedef) and
                   (tprocsym(pd.procsym).ProcdefList.Count>1) and
                   firstpd.forwarddef and
                   firstpd.interfacedef and
                   not(tprocsym(pd.procsym).ProcdefList.Count>2) and
                   { don't give an error if it may be an overload }
                   not(m_fpc in current_settings.modeswitches) and
                   (not(po_overload in pd.procoptions) or
                    not(po_overload in firstpd.procoptions)) then
                 begin
                   MessagePos1(pd.fileinfo,parser_e_header_dont_match_forward,pd.fullprocname(false));
                   tprocsym(pd.procsym).write_parameter_lists(pd);
                 end;
              end;
           end;

         { Set mangled name }
         proc_set_mangledname(pd);

         { compile procedure when a body is needed }
         if (pd_body in pdflags) then
           begin
             read_proc_body(old_current_procinfo,pd);
           end
         else
           begin
             { Handle imports }
             if (po_external in pd.procoptions) then
               begin
                 { External declared in implementation, and there was already a
                   forward (or interface) declaration then we need to generate
                   a stub that calls the external routine }
                 if (not pd.forwarddef) and
                    (pd.hasforward) and
                    not(
                        assigned(pd.import_dll) and
                        (target_info.system in [system_i386_wdosx,
                                                system_arm_wince,system_i386_wince])
                       ) then
                   begin
                     s:=proc_get_importname(pd);
                     if s<>'' then
                       gen_external_stub(current_asmdata.asmlists[al_procedures],pd,s);
                   end;

                 { Import DLL specified? }
                 if assigned(pd.import_dll) then
                   current_module.AddExternalImport(pd.import_dll^,proc_get_importname(pd),pd.import_nr,false,pd.import_name=nil)
                 else
                   begin
                     { add import name to external list for DLL scanning }
                     if tf_has_dllscanner in target_info.flags then
                       current_module.dllscannerinputlist.Add(proc_get_importname(pd),pd);
                   end;
               end;
           end;

         { make sure that references to forward-declared functions are not }
         { treated as references to external symbols, needed for darwin.   }

         { make sure we don't change the binding of real external symbols }
         if not(po_external in pd.procoptions) then
           begin
             if (po_global in pd.procoptions) or
                (cs_profile in current_settings.moduleswitches) then
               current_asmdata.DefineAsmSymbol(pd.mangledname,AB_GLOBAL,AT_FUNCTION)
             else
               current_asmdata.DefineAsmSymbol(pd.mangledname,AB_LOCAL,AT_FUNCTION);
           end;

         current_objectdef:=old_current_objectdef;
         current_procinfo:=old_current_procinfo;
      end;


    function TOPLParser.block(islibrary: boolean) : tnode;
      var
        procdef: tprocdef;  //local in tprocinfo
      begin
      //added syntax from psub
        procdef := current_procinfo.procdef;

         { parse const,types and vars }
         read_declarations(islibrary);

         { do we have an assembler block without the po_assembler?
           we should allow this for Delphi compatibility (PFV) }
         if (token=_ASM) and (m_delphi in current_settings.modeswitches) then
           include(procdef.procoptions,po_assembler);

         { Handle assembler block different }
         if (po_assembler in procdef.procoptions) then
          begin
            block:=assembler_block;
            exit;
          end;

         {Unit initialization?.}
         if (
             assigned(procdef.localst) and
             (procdef.localst.symtablelevel=main_program_level) and
             (current_module.is_unit or islibrary)
            ) then
           begin
             if (token=_END) then
                begin
                   consume(_END);
                   { We need at least a node, else the entry/exit code is not
                     generated and thus no PASCALMAIN symbol which we need (PFV) }
                   if islibrary then
                    block:=cnothingnode.create
                   else
                    block:=nil;
                end
              else
                begin
                   if token=_INITIALIZATION then
                     begin
                        { The library init code is already called and does not
                          need to be in the initfinal table (PFV) }
                        block:=statement_block(_INITIALIZATION);
                        { optimize empty initialization block away }
                        if (block.nodetype=blockn) and (tblocknode(block).left=nil) then
                          FreeAndNil(block)
                        else
                          if not islibrary then
                            current_module.flags:=current_module.flags or uf_init;
                     end
                   else if token=_FINALIZATION then
                     begin
                       { when a unit has only a finalization section, we can come to this
                         point when we try to read the nonh existing initalization section
                         so we've to check if we are really try to parse the finalization }
                       if procdef.proctypeoption=potype_unitfinalize then
                         begin
                           block:=statement_block(_FINALIZATION);
                           { optimize empty finalization block away }
                           if (block.nodetype=blockn) and (tblocknode(block).left=nil) then
                             FreeAndNil(block)
                           else
                             current_module.flags:=current_module.flags or uf_finalize;
                         end
                         else
                           block:=nil;
                     end
                   else
                     begin
                        { The library init code is already called and does not
                          need to be in the initfinal table (PFV) }
                        if not islibrary then
                          current_module.flags:=current_module.flags or uf_init;
                        block:=statement_block(_BEGIN);
                     end;
                end;
            end
         else
            begin
               block:=statement_block(_BEGIN);
               if procdef.localst.symtabletype=localsymtable then
                 procdef.localst.SymList.ForEachCall(@initializevars,block);
            end;
      end;


{****************************************************************************
                      SPECIALIZATION BODY GENERATION
****************************************************************************}

//used in ForEach - arg is the parser object(?)
    procedure specialize_objectdefs(p:TObject;arg:pointer);
      var
        i  : longint;
        hp : tdef;
        oldcurrent_filepos : tfileposinfo;
        oldsymtablestack   : tsymtablestack;
        pu : tused_unit;
        hmodule : tmodule;
        specobj : tobjectdef;
        //current_scanner: tscannerfile absolute arg;
        parser: TOPLParser absolute arg;
      begin
        if not((tsym(p).typ=typesym) and
               (ttypesym(p).typedef.typesym=tsym(p)) and
               (ttypesym(p).typedef.typ=objectdef) and
               (df_specialization in ttypesym(p).typedef.defoptions)
              ) then
          exit;

        { Setup symtablestack a definition time }
        specobj:=tobjectdef(ttypesym(p).typedef);
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
        if is_class(specobj) or is_object(specobj) then
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
                       parser.startreplaytokens(tprocdef(tprocdef(hp).genericdef).generictokenbuf);
                       parser.read_proc_body(nil,tprocdef(hp)); //, current_scanner);
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


    procedure TOPLParser.generate_specialization_procs;
      begin
        if assigned(current_module.globalsymtable) then
          current_module.globalsymtable.SymList.ForEachCall(@specialize_objectdefs, self);
        if assigned(current_module.localsymtable) then
          current_module.localsymtable.SymList.ForEachCall(@specialize_objectdefs, self);
      end;


