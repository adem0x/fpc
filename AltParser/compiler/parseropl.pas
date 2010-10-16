{
    Copyright (c) 1998-2010 by Florian Klaempfl and Dr. Diettrich

    This unit implements the parsing of modules (unit,program,library,package).
    Handling of ppufiles and other semantics will be moved somewhere else.
}
unit parserOPL;

{$i fpcdefs.inc}

interface

uses
  pbase;

type
  TParserOPL = class(TParser)
  public
    procedure Compile; override;
  end;

implementation

uses
  globals,globtype,cfileutl,
  fmodule,scanner,tokens,
  SModules,
  pmodules,pexpr,psub,psubOPL,
//for semantic
  sysutils,
  cutils,finput,comphook,verbose,
  symbase,symtable,symsym,symdef,symconst,
  ptype,
  ncgutil,objcgutl,import,dbgbase,cresstr,comprsrc,gendef,
  cpubase, ppu,fppu,export, systems,
  aasmbase,aasmdata,aasmcpu,aasmtai,wpobase, wpoinfo,link
  ;

{$DEFINE semclass}  //using semantic classes/objects?

{ References to external parsing procedures:
  ProcUnit
  -> pmodules.try_consume_hintdirective
    - clean
  -> psub.read_interface_declarations
    -> pdecl...
  -> psub.init_procinfo.parse_body
}

{***************************************************************
                    From pmodules
***************************************************************}

    procedure loadunits;
      var
         s,sorg  : TIDString;
         fn      : string;
      begin //loadunits
         {If you use units, you likely need unit initializations.}
         current_module.micro_exe_allowed:=false;

         consume(_USES);
         repeat
           s:=pattern;
           sorg:=orgpattern;
           consume(_ID);
           { support "<unit> in '<file>'" construct, but not for tp7 }
           fn:='';
           if not(m_tp7 in current_settings.modeswitches) and
              try_to_consume(_OP_IN) then
             fn:=FixFileName(get_stringconst);

          SUsesAdd(s,sorg,fn);

           if token=_COMMA then
            begin
              pattern:='';
              consume(_COMMA);
            end
           else
            break;
         until false;

         if SUsesDone() then
           exit; //using ppu file, parse finished

         consume(_SEMICOLON);
      end;

    procedure ProcUnit;

{$IFDEF semclass}
      var
        sm: TSemModule;
      {$IFDEF old}
        rpb: RParseBody;
      {$ELSE}
        //in ParseBody
      {$ENDIF}
{$ELSE}

      function is_assembler_generated:boolean;
      var
        hal : tasmlisttype;
      begin
        result:=false;
        if Errorcount=0 then
          begin
            for hal:=low(TasmlistType) to high(TasmlistType) do
              if not current_asmdata.asmlists[hal].empty then
                begin
                  result:=true;
                  exit;
                end;
          end;
      end;

      var
         main_file: tinputfile;
{$ifdef EXTDEBUG}
         store_crc,
{$endif EXTDEBUG}
         store_interface_crc,
         store_indirect_crc: cardinal;
         s1,s2  : ^string; {Saves stack space}
         force_init_final : boolean;
         init_procinfo,
         finalize_procinfo : tcgprocinfo;
         unitname8 : string[8];
         ag: boolean;
{$ifdef debug_devirt}
         i: longint;
{$endif debug_devirt}
{$ENDIF semclass}

    begin //ProcUnit
{$IFDEF semclass}
      sm.SModuleInitUnit;
{$ELSE}
        begin //SModuleInitUnit;
         init_procinfo:=nil;
         finalize_procinfo:=nil;

         if m_mac in current_settings.modeswitches then
           current_module.mode_switch_allowed:= false;
         if compile_level=1 then
           Status.IsExe:=false;
        end; //SModuleInitUnit;
{$ENDIF}
         consume(_UNIT);

         if token=_ID then
{$IFDEF semclass}
          sm.SUnitName;
{$ELSE}
            begin //SUnitName
             { create filenames and unit name }
             main_file := current_scanner.inputfile;
             while assigned(main_file.next) do
               main_file := main_file.next;

             new(s1);
             s1^:=current_module.modulename^;
             current_module.SetFileName(main_file.path^+main_file.name^,true);
             current_module.SetModuleName(orgpattern);

             { check for system unit }
             new(s2);
             s2^:=upper(ChangeFileExt(ExtractFileName(main_file.name^),''));
             unitname8:=copy(current_module.modulename^,1,8);
             if (cs_check_unit_name in current_settings.globalswitches) and
                (
                 not(
                     (current_module.modulename^=s2^) or
                     (
                      (length(current_module.modulename^)>8) and
                      (unitname8=s2^)
                     )
                    )
                 or
                 (
                  (length(s1^)>8) and
                  (s1^<>current_module.modulename^)
                 )
                ) then
              Message1(unit_e_illegal_unit_name,current_module.realmodulename^);
             if (current_module.modulename^='SYSTEM') then
              include(current_settings.moduleswitches,cs_compilesystem);
             dispose(s2);
             dispose(s1);

         if (target_info.system in systems_unit_program_exports) then
           exportlib.preparelib(current_module.realmodulename^);
        end; //SUnitName
{$ENDIF}
         consume(_ID);

         { parse hint directives }
         try_consume_hintdirective(current_module.moduleoptions, current_module.deprecatedmsg);

         consume(_SEMICOLON);
         consume(_INTERFACE);

{$IFDEF semclass}
        sm.SUnitInterface;
{$ELSE}
         begin //SUnitInterface
         { global switches are read, so further changes aren't allowed }
         current_module.in_global:=false;

         { handle the global switches }
         setupglobalswitches;

         message1(unit_u_loading_interface_units,current_module.modulename^);

         { update status }
         status.currentmodule:=current_module.realmodulename^;

         { maybe turn off m_objpas if we are compiling objpas }
         if (current_module.modulename^='OBJPAS') then
           exclude(current_settings.modeswitches,m_objpas);

         { maybe turn off m_mac if we are compiling macpas }
         if (current_module.modulename^='MACPAS') then
           exclude(current_settings.modeswitches,m_mac);


         parse_only:=true;

         { generate now the global symboltable,
           define first as local to overcome dependency conflicts }
         current_module.localsymtable:=tglobalsymtable.create(current_module.modulename^,current_module.moduleid);

         { insert unitsym of this unit to prevent other units having
           the same name }
         current_module.localsymtable.insert(tunitsym.create(current_module.realmodulename^,current_module));

         { load default units, like the system unit }
         loaddefaultunits;
      end; //SUnitInterface
{$ENDIF}
         { insert qualifier for the system unit (allows system.writeln) }
         if not(cs_compilesystem in current_settings.moduleswitches) and
            (token=_USES) then
           begin
             loadunits; //parse USES clause
             { has it been compiled at a higher level ?}
             if current_module.state=ms_compiled then
               exit;
           end;

{$IFDEF semclass}
        sm.SUnitIntfInit;
{$ELSE}
         begin
         { move the global symtable from the temporary local to global }
         current_module.globalsymtable:=current_module.localsymtable;
         current_module.localsymtable:=nil;

         { number all units, so we know if a unit is used by this unit or
           needs to be added implicitly }
         current_module.updatemaps;

         { create whole program optimisation information (may already be
           updated in the interface, e.g., in case of classrefdef typed
           constants }
         current_module.wpoinfo:=tunitwpoinfo.create;
         end;
{$ENDIF}
         { ... parse the declarations }
         Message1(parser_u_parsing_interface,current_module.realmodulename^);
         symtablestack.push(current_module.globalsymtable);
           read_interface_declarations; //<--------------------- parse!
         symtablestack.pop(current_module.globalsymtable);

{$IFDEF semclass}
          if sm.SUnitIntfDone((m_mac in current_settings.modeswitches) and try_to_consume(_END)) then
            exit;
{$ELSE}
         begin //SUnitIntfDone
         { Export macros defined in the interface for macpas. The macros
           are put in the globalmacrosymtable that will only be used by other
           units. The current unit continues to use the localmacrosymtable }
         if (m_mac in current_settings.modeswitches) then
          begin
            current_module.globalmacrosymtable:=tmacrosymtable.create(true);
            current_module.localmacrosymtable.SymList.ForEachCall(@copy_macro,nil);
          end;

         { leave when we got an error }
         if (Errorcount>0) and not status.skip_error then
          begin
            Message1(unit_f_errors_in_unit,tostr(Errorcount));
            status.skip_error:=true;
            exit;
          end;

         { Our interface is compiled, generate CRC and switch to implementation }
         if not(cs_compilesystem in current_settings.moduleswitches) and
            (Errorcount=0) then
           tppumodule(current_module).getppucrc;
         current_module.in_interface:=false;
         current_module.interface_compiled:=true;

         { First reload all units depending on our interface, we need to do this
           in the implementation part to prevent erroneous circular references }
         tppumodule(current_module).setdefgeneration;
         tppumodule(current_module).reload_flagged_units;

         { Parse the implementation section }
         if (m_mac in current_settings.modeswitches) and try_to_consume(_END) then
           current_module.interface_only:=true
         else
           current_module.interface_only:=false;

         parse_only:=false;

         { create static symbol table }
         current_module.localsymtable:=tstaticsymtable.create(current_module.modulename^,current_module.moduleid);

         { Insert _GLOBAL_OFFSET_TABLE_ symbol if system uses it }
         maybe_load_got;
      end; //SUnitIntfDone
{$ENDIF}

         if not current_module.interface_only then
           begin
             consume(_IMPLEMENTATION);
             Message1(unit_u_loading_implementation_units,current_module.modulename^);
             { Read the implementation units }
             //inlined parse_implementation_uses;
             if token=_USES then
               loadunits; //parse USES clause
           end;

{$IFDEF semclass}
        if sm.SUnitImplInit then
          exit;
{$ELSE}
        begin //SUnitImplInit;
         if current_module.state=ms_compiled then
           exit;

         { All units are read, now give them a number }
         current_module.updatemaps;

         symtablestack.push(current_module.globalsymtable);
         symtablestack.push(current_module.localsymtable);
        end; //SUnitImplInit;
{$ENDIF}

        if not current_module.interface_only then
          begin
{$IFDEF semclass}
            sm.SUnitBodyInit;
          (* We cannot subclass tcgprocinfo class,
              because it's subclassed for every target CPU.
            But we can split tcgprocinfo.parse_body, so that the block() call
            can be redirected to another procedure.
          *)
          {$IFDEF old}
             sm.init_procinfo.ParseBodyInit(rpb);
             //sm.init_procinfo.code := ParseBlock(sm.Kind=mkLib);
             sm.init_procinfo.code := ParseBlock(current_module.islibrary);
             sm.init_procinfo.ParseBodyDone(rpb);
          {$ELSE}
            ParseBody(sm.init_procinfo);
          {$ENDIF}
             { save file pos for debuginfo }
             current_module.mainfilepos:=sm.init_procinfo.entrypos;
{$ELSE}
            begin //SUnitBodyInit;
             Message1(parser_u_parsing_implementation,current_module.modulename^);
             if current_module.in_interface then
               internalerror(200212285);

             { Compile the unit }
             init_procinfo:=create_main_proc(make_mangledname('',current_module.localsymtable,'init'),potype_unitinit,current_module.localsymtable);
             init_procinfo.procdef.aliasnames.insert(make_mangledname('INIT$',current_module.localsymtable,''));
            end; //SUnitBodyInit;
             init_procinfo.parse_body;
             { save file pos for debuginfo }
             current_module.mainfilepos:=init_procinfo.entrypos;
{$ENDIF}
          end;
{$IFDEF semclass}
        sm.SUnitBodyDone;
{$ELSE}
        begin //SUnitBodyDone;
         { Generate specializations of objectdefs methods }
         generate_specialization_procs;

         { if the unit contains ansi/widestrings, initialization and
           finalization code must be forced }
         force_init_final:=tglobalsymtable(current_module.globalsymtable).needs_init_final or
                           tstaticsymtable(current_module.localsymtable).needs_init_final;

         { should we force unit initialization? }
         { this is a hack, but how can it be done better ? }
         if force_init_final and ((current_module.flags and uf_init)=0) then
           begin
             { first release the not used init procinfo }
             if assigned(init_procinfo) then
               release_main_proc(init_procinfo);
             init_procinfo:=gen_implicit_initfinal(uf_init,current_module.localsymtable);
           end;
        end; //SUnitBodyDone;
{$ENDIF}
         { finalize? }
         if not current_module.interface_only and (token=_FINALIZATION) then
           begin
{$IFDEF semclass}
            sm.SUnitFinalInit(True);
            sm.finalize_procinfo.parse_body;
{$ELSE}
            begin //finalize_procinfo:= SUnitFinalInit;
              { the uf_finalize flag is only set after we checked that it
                wasn't empty }

              { Compile the finalize }
              finalize_procinfo:=create_main_proc(make_mangledname('',current_module.localsymtable,'finalize'),potype_unitfinalize,current_module.localsymtable);
              finalize_procinfo.procdef.aliasnames.insert(make_mangledname('FINALIZE$',current_module.localsymtable,''));
            end; //SUnitFinalInit;
            finalize_procinfo.parse_body;
{$ENDIF}
           end
{$IFDEF semclass}
         else if sm.force_init_final then //begin
          sm.SUnitFinalInit(False);
{$ELSE}
         else if force_init_final then //begin
          begin //SUnitFinalInit(False)
           finalize_procinfo:=gen_implicit_initfinal(uf_finalize,current_module.localsymtable);
          end;
{$ENDIF}
         //end;
{$IFDEF semclass}
        sm.SUnitFinalDone;
{$ELSE}
        begin //SUnitFinalDone
         { Now both init and finalize bodies are read and it is known
           which variables are used in both init and finalize we can now
           generate the code. This is required to prevent putting a variable in
           a register that is also used in the finalize body (PFV) }
         if assigned(init_procinfo) then
           begin
             init_procinfo.generate_code;
             init_procinfo.resetprocdef;
             release_main_proc(init_procinfo);
           end;
         if assigned(finalize_procinfo) then
           begin
             finalize_procinfo.generate_code;
             finalize_procinfo.resetprocdef;
             release_main_proc(finalize_procinfo);
           end;

         symtablestack.pop(current_module.localsymtable);
         symtablestack.pop(current_module.globalsymtable);
        end; //SUnitFinalDone
{$ENDIF}

         { the last char should always be a point }
         consume(_POINT);
{$IFDEF semclass}
        if sm.SUnitDone then
          exit; //without message?
{$ELSE}
        begin //SUnitDone;
         { reset wpo flags for all defs }
         reset_all_defs;

         if (Errorcount=0) then
           begin
             { tests, if all (interface) forwards are resolved }
             tstoredsymtable(current_module.globalsymtable).check_forwards;
             { check if all private fields are used }
             tstoredsymtable(current_module.globalsymtable).allprivatesused;

             { test static symtable }
             tstoredsymtable(current_module.localsymtable).allsymbolsused;
             tstoredsymtable(current_module.localsymtable).allprivatesused;
             tstoredsymtable(current_module.localsymtable).check_forwards;
             tstoredsymtable(current_module.localsymtable).checklabels;

             { used units }
             current_module.allunitsused;
           end;

         { leave when we got an error }
         if (Errorcount>0) and not status.skip_error then
          begin
            Message1(unit_f_errors_in_unit,tostr(Errorcount));
            status.skip_error:=true;
            exit;
          end;

         { if an Objective-C module, generate rtti and module info }
         MaybeGenerateObjectiveCImageInfo(current_module.globalsymtable,current_module.localsymtable);

         { do we need to add the variants unit? }
         maybeloadvariantsunit;

         { generate wrappers for interfaces }
         gen_intf_wrappers(current_asmdata.asmlists[al_procedures],current_module.globalsymtable);
         gen_intf_wrappers(current_asmdata.asmlists[al_procedures],current_module.localsymtable);

         { generate pic helpers to load eip if necessary }
         gen_pic_helpers(current_asmdata.asmlists[al_procedures]);

         { generate rtti/init tables }
         write_persistent_type_info(current_module.globalsymtable);
         write_persistent_type_info(current_module.localsymtable);

         { Tables }
         InsertThreadvars;

         { Resource strings }
         GenerateResourceStrings;

         { Widestring typed constants }
         InsertWideInits;

         { generate debuginfo }
         if (cs_debuginfo in current_settings.moduleswitches) then
           current_debuginfo.inserttypeinfo;

         { generate imports }
         if current_module.ImportLibraryList.Count>0 then
           importlib.generatelib;

         { insert own objectfile, or say that it's in a library
           (no check for an .o when loading) }
         ag:=is_assembler_generated;
         if ag then
           insertobjectfile
         else
           begin
             current_module.flags:=current_module.flags or uf_no_link;
             current_module.flags:=current_module.flags and not (uf_has_stabs_debuginfo or uf_has_dwarf_debuginfo);
           end;

         if ag then
          begin
            { create callframe info }
            create_dwarf_frame;
            { assemble }
            create_objectfile;
          end;

         { Write out the ppufile after the object file has been created }
         store_interface_crc:=current_module.interface_crc;
         store_indirect_crc:=current_module.indirect_crc;
{$ifdef EXTDEBUG}
         store_crc:=current_module.crc;
{$endif EXTDEBUG}
         if (Errorcount=0) then
           tppumodule(current_module).writeppu;

         if not(cs_compilesystem in current_settings.moduleswitches) then
           begin
             if store_interface_crc<>current_module.interface_crc then
               Message1(unit_u_interface_crc_changed,current_module.ppufilename^);
             if store_indirect_crc<>current_module.indirect_crc then
               Message1(unit_u_indirect_crc_changed,current_module.ppufilename^);
           end;
{$ifdef EXTDEBUG}
         if not(cs_compilesystem in current_settings.moduleswitches) then
           if (store_crc<>current_module.crc) and simplify_ppu then
             Message1(unit_u_implementation_crc_changed,current_module.ppufilename^);
{$endif EXTDEBUG}

         { release local symtables that are not needed anymore }
         free_localsymtables(current_module.globalsymtable);
         free_localsymtables(current_module.localsymtable);

         { leave when we got an error }
         if (Errorcount>0) and not status.skip_error then
          begin
            Message1(unit_f_errors_in_unit,tostr(Errorcount));
            status.skip_error:=true;
            exit;
          end;

{$ifdef debug_devirt}
         { print out all instantiated class/object types }
         writeln('constructed object/class/classreftypes in ',current_module.realmodulename^);
         for i := 0 to current_module.wpoinfo.createdobjtypes.count-1 do
           begin
             write('  ',tdef(current_module.wpoinfo.createdobjtypes[i]).GetTypeName);
             case tdef(current_module.wpoinfo.createdobjtypes[i]).typ of
               objectdef:
                 case tobjectdef(current_module.wpoinfo.createdobjtypes[i]).objecttype of
                   odt_object:
                     writeln(' (object)');
                   odt_class:
                     writeln(' (class)');
                   else
                     internalerror(2008101103);
                 end;
               else
                 internalerror(2008101104);
             end;
           end;

         for i := 0 to current_module.wpoinfo.createdclassrefobjtypes.count-1 do
           begin
             write('  Class Of ',tdef(current_module.wpoinfo.createdclassrefobjtypes[i]).GetTypeName);
             case tdef(current_module.wpoinfo.createdclassrefobjtypes[i]).typ of
               objectdef:
                 case tobjectdef(current_module.wpoinfo.createdclassrefobjtypes[i]).objecttype of
                   odt_class:
                     writeln(' (classrefdef)');
                   else
                     internalerror(2008101105);
                 end
               else
                 internalerror(2008101102);
             end;
           end;
{$endif debug_devirt}
        end; //SUnitDone;
{$ENDIF}
        Message1(unit_u_finished_compiling,current_module.modulename^); //move into SUnitDone?
    end;


    procedure ProcPackage;
{$IFDEF semclass}
    var
      sm: TSemModule;
{$ELSE}
      var
        main_file : tinputfile;
        hp,hp2    : tmodule;
        {finalize_procinfo,
        init_procinfo,
        main_procinfo : tcgprocinfo;}
        force_init_final : boolean;
        uu : tused_unit;

{$ENDIF}
    begin //ProcPackage
{$IFDEF semclass}
      sm.SModuleInitPackage;
{$ELSE}
        begin //SModuleInitPackage
         Status.IsPackage:=true;
         Status.IsExe:=true;
         parse_only:=false;
         {main_procinfo:=nil;
         init_procinfo:=nil;
         finalize_procinfo:=nil;}

         if not RelocSectionSetExplicitly then
           RelocSection:=true;

         { Relocation works only without stabs under Windows when }
         { external linker (LD) is used.  LD generates relocs for }
         { stab sections which is not loaded in memory. It causes }
         { AV error when DLL is loaded and relocation is needed.  }
         { Internal linker does not have this problem.            }
         if RelocSection and
            (target_info.system in systems_all_windows+[system_i386_wdosx]) and
            (cs_link_extern in current_settings.globalswitches) then
           begin
              include(current_settings.globalswitches,cs_link_strip);
              { Warning stabs info does not work with reloc section !! }
              if (cs_debuginfo in current_settings.moduleswitches) and
                 (target_dbg.id=dbg_stabs) then
                begin
                  Message1(parser_w_parser_reloc_no_debug,current_module.mainsource^);
                  Message(parser_w_parser_win32_debug_needs_WN);
                  exclude(current_settings.moduleswitches,cs_debuginfo);
                end;
           end;
         { get correct output names }
         main_file := current_scanner.inputfile;
         while assigned(main_file.next) do
           main_file := main_file.next;

         current_module.SetFileName(main_file.path^+main_file.name^,true);
        end; //SModuleInitPackage
{$ENDIF}
         consume(_ID);  //PACKAGE
{$IFDEF semclass}
        sm.SPackageName;
{$ELSE}
        begin //SPackageName
         current_module.setmodulename(orgpattern);
         current_module.ispackage:=true;
         exportlib.preparelib(orgpattern);

         if tf_library_needs_pic in target_info.flags then
           include(current_settings.moduleswitches,cs_create_pic);
        end; //SPackageName
{$ENDIF}
         consume(_ID);
         consume(_SEMICOLON);
{$IFDEF semclass}
        sm.SPackageInterface;
{$ELSE}
        begin //SPackageInterface
         { global switches are read, so further changes aren't allowed }
         current_module.in_global:=false;

         { setup things using the switches }
         setupglobalswitches;

         { set implementation flag }
         current_module.in_interface:=false;
         current_module.interface_compiled:=true;

         { insert after the unit symbol tables the static symbol table }
         { of the program                                             }
         current_module.localsymtable:=tstaticsymtable.create(current_module.modulename^,current_module.moduleid);
        end; //SPackageInterface
{$ENDIF}
         {Load the units used by the program we compile.}
         if token=_REQUIRES then
           begin
            //this clause will produce errors, if ever entered
           end;

         {Load the units used by the program we compile.}
         if (token=_ID) and (idtoken=_CONTAINS) then
           begin
             consume(_ID);
             while true do
               begin
                 if token=_ID then
                   AddUnit(pattern);
                 consume(_ID);
                 if token=_COMMA then
                   consume(_COMMA)
                 else break;
               end;
             consume(_SEMICOLON);
           end;
{$IFDEF semclass}
        sm.SPackageImplInit;
{$ELSE}
        begin //SPackageImplInit
         { All units are read, now give them a number }
         current_module.updatemaps;

         {Insert the name of the main program into the symbol table.}
         if current_module.realmodulename^<>'' then
           current_module.localsymtable.insert(tunitsym.create(current_module.realmodulename^,current_module));

         Message1(parser_u_parsing_implementation,current_module.mainsource^);

         symtablestack.push(current_module.localsymtable);

         { create whole program optimisation information }
         current_module.wpoinfo:=tunitwpoinfo.create;

         { should we force unit initialization? }
         force_init_final:=tstaticsymtable(current_module.localsymtable).needs_init_final;
         if force_init_final then
           {init_procinfo:=gen_implicit_initfinal(uf_init,current_module.localsymtable)};

         { Add symbol to the exports section for win32 so smartlinking a
           DLL will include the edata section }
         if assigned(exportlib) and
            (target_info.system in [system_i386_win32,system_i386_wdosx]) and
            ((current_module.flags and uf_has_exports)<>0) then
           current_asmdata.asmlists[al_procedures].concat(tai_const.createname(make_mangledname('EDATA',current_module.localsymtable,''),0));

         { all labels must be defined before generating code }
         if Errorcount=0 then
           tstoredsymtable(current_module.localsymtable).checklabels;

         symtablestack.pop(current_module.localsymtable);
        end; //SPackageImplInit
{$ENDIF}
         { consume the last point }
         consume(_END);
         consume(_POINT);
{$IFDEF semclass}
        if sm.SPackageDone then
          exit;
{$ELSE}
        begin //SPackageDone
         if (Errorcount=0) then
           begin
             { test static symtable }
             tstoredsymtable(current_module.localsymtable).allsymbolsused;
             tstoredsymtable(current_module.localsymtable).allprivatesused;
             tstoredsymtable(current_module.localsymtable).check_forwards;

             current_module.allunitsused;
           end;

         new_section(current_asmdata.asmlists[al_globals],sec_data,'_FPCDummy',4);
         current_asmdata.asmlists[al_globals].concat(tai_symbol.createname_global('_FPCDummy',AT_DATA,0));
         current_asmdata.asmlists[al_globals].concat(tai_const.create_32bit(0));

         new_section(current_asmdata.asmlists[al_procedures],sec_code,'',0);
         current_asmdata.asmlists[al_procedures].concat(tai_symbol.createname_global('_DLLMainCRTStartup',AT_FUNCTION,0));
{$ifdef i386}
         { fix me! }
         current_asmdata.asmlists[al_procedures].concat(Taicpu.Op_const_reg(A_MOV,S_L,1,NR_EAX));
         current_asmdata.asmlists[al_procedures].concat(Taicpu.Op_const(A_RET,S_W,12));
{$endif i386}
         current_asmdata.asmlists[al_procedures].concat(tai_const.createname('_FPCDummy',0));

         { leave when we got an error }
         if (Errorcount>0) and not status.skip_error then
           begin
             Message1(unit_f_errors_in_unit,tostr(Errorcount));
             status.skip_error:=true;
             exit;
           end;

         { remove all unused units, this happends when units are removed
           from the uses clause in the source and the ppu was already being loaded }
         hp:=tmodule(loaded_units.first);
         while assigned(hp) do
          begin
            hp2:=hp;
            hp:=tmodule(hp.next);
            if hp2.is_unit and
               not assigned(hp2.globalsymtable) then
              loaded_units.remove(hp2);
          end;

         { force exports }
         uu:=tused_unit(usedunits.first);
         while assigned(uu) do
           begin
             uu.u.globalsymtable.symlist.ForEachCall(@insert_export,uu.u.globalsymtable);
             { check localsymtable for exports too to get public symbols }
             uu.u.localsymtable.symlist.ForEachCall(@insert_export,uu.u.localsymtable);

             { create special exports }
             if (uu.u.flags and uf_init)<>0 then
               procexport(make_mangledname('INIT$',uu.u.globalsymtable,''));
             if (uu.u.flags and uf_finalize)<>0 then
               procexport(make_mangledname('FINALIZE$',uu.u.globalsymtable,''));
             if (uu.u.flags and uf_threadvars)=uf_threadvars then
               varexport(make_mangledname('THREADVARLIST',uu.u.globalsymtable,''));

             uu:=tused_unit(uu.next);
           end;

{$ifdef arm}
         { Insert .pdata section for arm-wince.
           It is needed for exception handling. }
         if target_info.system in [system_arm_wince] then
           InsertPData;
{$endif arm}

         { generate debuginfo }
         if (cs_debuginfo in current_settings.moduleswitches) then
           current_debuginfo.inserttypeinfo;

         exportlib.generatelib;

         { write all our exports to the import library,
           needs to be done after exportlib.generatelib; }
         createimportlibfromexports;

         { generate imports }
         if current_module.ImportLibraryList.Count>0 then
           importlib.generatelib;

         { Reference all DEBUGINFO sections from the main .fpc section }
         if (cs_debuginfo in current_settings.moduleswitches) then
           current_debuginfo.referencesections(current_asmdata.asmlists[al_procedures]);

         { insert own objectfile }
         insertobjectfile;

         { assemble and link }
         create_objectfile;

         { We might need the symbols info if not using
           the default do_extractsymbolinfo
           which is a dummy function PM }
         needsymbolinfo:=do_extractsymbolinfo<>@def_extractsymbolinfo;
         { release all local symtables that are not needed anymore }
         if (not needsymbolinfo) then
           free_localsymtables(current_module.localsymtable);

         { leave when we got an error }
         if (Errorcount>0) and not status.skip_error then
          begin
            Message1(unit_f_errors_in_unit,tostr(Errorcount));
            status.skip_error:=true;
            exit;
          end;

         if (not current_module.is_unit) then
           begin
             { finally rewrite all units included into the package }
             uu:=tused_unit(usedunits.first);
             while assigned(uu) do
               begin
                 RewritePPU(uu.u.ppufilename^,uu.u.ppufilename^);
                 uu:=tused_unit(uu.next);
               end;

             { create the executable when we are at level 1 }
             if (compile_level=1) then
               begin
                 { create global resource file by collecting all resource files }
                 CollectResourceFiles;
                 { write .def file }
                 if (cs_link_deffile in current_settings.globalswitches) then
                   deffile.writefile;
                 { insert all .o files from all loaded units and
                   unload the units, we don't need them anymore.
                   Keep the current_module because that is still needed }
                 hp:=tmodule(loaded_units.first);
                 while assigned(hp) do
                  begin
                    { the package itself contains no code so far }
                    linker.AddModuleFiles(hp);
                    hp2:=tmodule(hp.next);
                    if (hp<>current_module) and
                       (not needsymbolinfo) then
                      begin
                        loaded_units.remove(hp);
                        hp.free;
                      end;
                    hp:=hp2;
                  end;
                 linker.MakeSharedLibrary
               end;

             { Give Fatal with error count for linker errors }
             if (Errorcount>0) and not status.skip_error then
              begin
                Message1(unit_f_errors_in_unit,tostr(Errorcount));
                status.skip_error:=true;
              end;
          end;
        end; //SPackageDone
{$ENDIF}
    end;


    procedure ProcProgram(islibrary : boolean);
{$IFDEF semclass}
    var
      sm: TSemModule;
{$ELSE}
      var
         main_file : tinputfile;
         hp,hp2    : tmodule;
         finalize_procinfo,
         init_procinfo,
         main_procinfo : tcgprocinfo;
         force_init_final : boolean;
         resources_used : boolean;
{$ENDIF}

    begin //ProcProgram
{$IFDEF semclass}
      sm.SModuleInitProgLib(isLibrary);
{$ELSE}
        begin //SModuleInitProgLib
         DLLsource:=islibrary;
         Status.IsLibrary:=IsLibrary;
         Status.IsPackage:=false;
         Status.IsExe:=true;
         parse_only:=false;
         main_procinfo:=nil;
         init_procinfo:=nil;
         finalize_procinfo:=nil;
         resources_used:=false;

         { DLL defaults to create reloc info }
         if islibrary then
           begin
             if not RelocSectionSetExplicitly then
               RelocSection:=true;
           end;

         { Relocation works only without stabs under Windows when }
         { external linker (LD) is used.  LD generates relocs for }
         { stab sections which is not loaded in memory. It causes }
         { AV error when DLL is loaded and relocation is needed.  }
         { Internal linker does not have this problem.            }
         if RelocSection and
            (target_info.system in systems_all_windows+[system_i386_wdosx]) and
            (cs_link_extern in current_settings.globalswitches) then
           begin
              include(current_settings.globalswitches,cs_link_strip);
              { Warning stabs info does not work with reloc section !! }
              if (cs_debuginfo in current_settings.moduleswitches) and
                 (target_dbg.id=dbg_stabs) then
                begin
                  Message1(parser_w_parser_reloc_no_debug,current_module.mainsource^);
                  Message(parser_w_parser_win32_debug_needs_WN);
                  exclude(current_settings.moduleswitches,cs_debuginfo);
                end;
           end;
         { get correct output names }
         main_file := current_scanner.inputfile;
         while assigned(main_file.next) do
           main_file := main_file.next;

         current_module.SetFileName(main_file.path^+main_file.name^,true);
        end; //SModuleInitProgLib
{$ENDIF}
         if islibrary then
           begin
              consume(_LIBRARY);
{$IFDEF semclass}
              //if token=_ID then ...
              sm.SLibName;
{$ELSE}
            begin //SLibName
              current_module.setmodulename(orgpattern);
              current_module.islibrary:=true;
              exportlib.preparelib(orgpattern);
            //where???
              if tf_library_needs_pic in target_info.flags then
                include(current_settings.moduleswitches,cs_create_pic);
            end; //SLibName
{$ENDIF}
              consume(_ID);
              consume(_SEMICOLON);
           end
         else //program
           { is there an program head ? }
           if token=_PROGRAM then //PROGRAM header
            begin
              consume(_PROGRAM);
{$IFDEF semclass}
              //if token=_ID...
              sm.SProgName;
{$ELSE}
              begin //SProgName
              current_module.setmodulename(orgpattern);
              if (target_info.system in systems_unit_program_exports) then
                exportlib.preparelib(orgpattern);
              end; //SProgName
{$ENDIF}
              consume(_ID);
              if token=_LKLAMMER then
                begin
                   consume(_LKLAMMER);
                   repeat
                     consume(_ID);
                   until not try_to_consume(_COMMA);
                   consume(_RKLAMMER);
                end;
              consume(_SEMICOLON);
            end
{$IFDEF semclass}
         else
            sm.SProgNameNone;

          sm.SProgLibImplInit;
{$ELSE}
         else
          begin //SProgNameNone
          if (target_info.system in systems_unit_program_exports) then
           exportlib.preparelib(current_module.realmodulename^);
          end; //SProgNameNone

        begin //SProgLibImplInit
         { global switches are read, so further changes aren't allowed }
         current_module.in_global:=false;

         { setup things using the switches }
         setupglobalswitches;

         { set implementation flag }
         current_module.in_interface:=false;
         current_module.interface_compiled:=true;

         { insert after the unit symbol tables the static symbol table }
         { of the program                                             }
         current_module.localsymtable:=tstaticsymtable.create(current_module.modulename^,current_module.moduleid);

         { load standard units (system,objpas,profile unit) }
         loaddefaultunits;

         { Load units provided on the command line }
         loadautounits;
        end; //SProgLibImplInit
{$ENDIF}
         {Load the units used by the program we compile.}
         if token=_USES then
           loadunits;
{$IFDEF semclass}
        sm.SProgLibBodyInit;

         sm.main_procinfo.parse_body;
         { save file pos for debuginfo }
         current_module.mainfilepos:=sm.main_procinfo.entrypos;
{$ELSE}
        begin //SProgLibBodyInit
         { All units are read, now give them a number }
         current_module.updatemaps;

         {Insert the name of the main program into the symbol table.}
         if current_module.realmodulename^<>'' then
           current_module.localsymtable.insert(tunitsym.create(current_module.realmodulename^,current_module));

         Message1(parser_u_parsing_implementation,current_module.mainsource^);

         symtablestack.push(current_module.localsymtable);

         { Insert _GLOBAL_OFFSET_TABLE_ symbol if system uses it }
         maybe_load_got;

         { create whole program optimisation information }
         current_module.wpoinfo:=tunitwpoinfo.create;

         { The program intialization needs an alias, so it can be called
           from the bootstrap code.}
         if islibrary then
          begin
            main_procinfo:=create_main_proc(make_mangledname('',current_module.localsymtable,mainaliasname),potype_proginit,current_module.localsymtable);
            { Win32 startup code needs a single name }
            if not(target_info.system in systems_darwin) then
              main_procinfo.procdef.aliasnames.insert('PASCALMAIN')
            else
              main_procinfo.procdef.aliasnames.insert(target_info.Cprefix+'PASCALMAIN')
          end
         else if (target_info.system in ([system_i386_netware,system_i386_netwlibc,system_powerpc_macos]+systems_darwin)) then
           begin
             main_procinfo:=create_main_proc('PASCALMAIN',potype_proginit,current_module.localsymtable);
           end
         else
           begin
             main_procinfo:=create_main_proc(mainaliasname,potype_proginit,current_module.localsymtable);
             main_procinfo.procdef.aliasnames.insert('PASCALMAIN');
           end;
        end; //SProgLibImplInit

         main_procinfo.parse_body;
         { save file pos for debuginfo }
         current_module.mainfilepos:=main_procinfo.entrypos;
{$ENDIF}
{$IFDEF semclass}
        sm.SProgLibBodyDone;
{$ELSE}
        begin //SProgLibBodyDone
         { Generate specializations of objectdefs methods }
         generate_specialization_procs;

         { should we force unit initialization? }
         force_init_final:=tstaticsymtable(current_module.localsymtable).needs_init_final;
         if force_init_final then
           init_procinfo:=gen_implicit_initfinal(uf_init,current_module.localsymtable);

         { Add symbol to the exports section for win32 so smartlinking a
           DLL will include the edata section }
         if assigned(exportlib) and
            (target_info.system in [system_i386_win32,system_i386_wdosx]) and
            ((current_module.flags and uf_has_exports)<>0) then
           current_asmdata.asmlists[al_procedures].concat(tai_const.createname(make_mangledname('EDATA',current_module.localsymtable,''),0));
        end; //SProgLibBodyDone
{$ENDIF}
         { finalize? }
         if token=_FINALIZATION then
{$IFDEF semclass}
           begin
              sm.SProgLibFinalInit(True);
              sm.finalize_procinfo.parse_body;
           end
         else
           if sm.force_init_final then
              sm.SProgLibFinalInit(False);
{$ELSE}
           begin
             begin //SProgLibFinalInit(True)
              { the uf_finalize flag is only set after we checked that it
                wasn't empty }

              { Parse the finalize }
              finalize_procinfo:=create_main_proc(make_mangledname('',current_module.localsymtable,'finalize'),potype_unitfinalize,current_module.localsymtable);
              finalize_procinfo.procdef.aliasnames.insert(make_mangledname('FINALIZE$',current_module.localsymtable,''));
              finalize_procinfo.procdef.aliasnames.insert('PASCALFINALIZE');
             end; //SProgLibFinalInit(True)
              finalize_procinfo.parse_body;
           end
         else
           if force_init_final then
            begin //SPrgLibFinalInit(False)
             finalize_procinfo:=gen_implicit_initfinal(uf_finalize,current_module.localsymtable);
            end; //SPrgLibFinalInit(False)
{$ENDIF}
{$IFDEF semclass}
          sm.SPrgLibFinalDone;
{$ELSE}
         begin //SPrgLibFinalDone
          { the finalization routine of libraries is generic (and all libraries need to }
          { be finalized, so they can finalize any units they use                       }
          if (islibrary) then
            exportlib.setfininame(current_asmdata.asmlists[al_procedures],'FPC_LIB_EXIT');

         { all labels must be defined before generating code }
         if Errorcount=0 then
           tstoredsymtable(current_module.localsymtable).checklabels;

         { See remark in unit init/final }
         main_procinfo.generate_code;
         main_procinfo.resetprocdef;
         release_main_proc(main_procinfo);
         if assigned(init_procinfo) then
           begin
             init_procinfo.generate_code;
             init_procinfo.resetprocdef;
             release_main_proc(init_procinfo);
           end;
         if assigned(finalize_procinfo) then
           begin
             finalize_procinfo.generate_code;
             finalize_procinfo.resetprocdef;
             release_main_proc(finalize_procinfo);
           end;

         symtablestack.pop(current_module.localsymtable);
        end; //SPrgLibFinalDone
{$ENDIF}
         { consume the last point }
         consume(_POINT);
{$IFDEF semclass}
          sm.SPrgLibDone;
{$ELSE}
        begin //SPrgLibDone
         { reset wpo flags for all defs }
         reset_all_defs;

         if (Errorcount=0) then
           begin
             { test static symtable }
             tstoredsymtable(current_module.localsymtable).allsymbolsused;
             tstoredsymtable(current_module.localsymtable).allprivatesused;
             tstoredsymtable(current_module.localsymtable).check_forwards;

             current_module.allunitsused;
           end;

         { leave when we got an error }
         if (Errorcount>0) and not status.skip_error then
           begin
             Message1(unit_f_errors_in_unit,tostr(Errorcount));
             status.skip_error:=true;
             exit;
           end;

         { remove all unused units, this happens when units are removed
           from the uses clause in the source and the ppu was already being loaded }
         hp:=tmodule(loaded_units.first);
         while assigned(hp) do
          begin
            hp2:=hp;
            hp:=tmodule(hp.next);
            if hp2.is_unit and
               not assigned(hp2.globalsymtable) then
                begin
                  loaded_units.remove(hp2);
                  unloaded_units.concat(hp2);
                end;
          end;

         { do we need to add the variants unit? }
         maybeloadvariantsunit;

         { Now that everything has been compiled we know if we need resource
           support. If not, remove the unit. }
         resources_used:=MaybeRemoveResUnit;

         linker.initsysinitunitname;
         if target_info.system in systems_internal_sysinit then
         begin
           { add start/halt unit }
           AddUnit(linker.sysinitunit);
         end;

{$ifdef arm}
         { Insert .pdata section for arm-wince.
           It is needed for exception handling. }
         if target_info.system in [system_arm_wince] then
           InsertPData;
{$endif arm}

         InsertThreadvars;

         { generate pic helpers to load eip if necessary }
         gen_pic_helpers(current_asmdata.asmlists[al_procedures]);

         { generate rtti/init tables }
         write_persistent_type_info(current_module.localsymtable);

         { if an Objective-C module, generate rtti and module info }
         MaybeGenerateObjectiveCImageInfo(nil,current_module.localsymtable);

         { generate wrappers for interfaces }
         gen_intf_wrappers(current_asmdata.asmlists[al_procedures],current_module.localsymtable);

         { generate imports }
         if current_module.ImportLibraryList.Count>0 then
           importlib.generatelib;

         { generate debuginfo }
         if (cs_debuginfo in current_settings.moduleswitches) then
           current_debuginfo.inserttypeinfo;

         if islibrary or (target_info.system in systems_unit_program_exports) then
           exportlib.generatelib;

         { Reference all DEBUGINFO sections from the main .fpc section }
         if (cs_debuginfo in current_settings.moduleswitches) then
           current_debuginfo.referencesections(current_asmdata.asmlists[al_procedures]);

         { Resource strings }
         GenerateResourceStrings;

         { Windows widestring needing initialization }
         InsertWideInits;

         { insert Tables and StackLength }
         InsertInitFinalTable;
         InsertThreadvarTablesTable;
         InsertResourceTablesTable;
         InsertWideInitsTablesTable;
         InsertMemorySizes;

         { Insert symbol to resource info }
         InsertResourceInfo(resources_used);

         { create callframe info }
         create_dwarf_frame;

         { insert own objectfile }
         insertobjectfile;

         { assemble and link }
         create_objectfile;

         { We might need the symbols info if not using
           the default do_extractsymbolinfo
           which is a dummy function PM }
         needsymbolinfo:=
           (do_extractsymbolinfo<>@def_extractsymbolinfo) or
           ((current_settings.genwpoptimizerswitches*WPOptimizationsNeedingAllUnitInfo)<>[]);

         { release all local symtables that are not needed anymore }
         if (not needsymbolinfo) then
           free_localsymtables(current_module.localsymtable);

         { leave when we got an error }
         if (Errorcount>0) and not status.skip_error then
          begin
            Message1(unit_f_errors_in_unit,tostr(Errorcount));
            status.skip_error:=true;
            exit;
          end;

         if (not current_module.is_unit) then
           begin
             { create the executable when we are at level 1 }
             if (compile_level=1) then
               begin
                 { create global resource file by collecting all resource files }
                 CollectResourceFiles;
                 { write .def file }
                 if (cs_link_deffile in current_settings.globalswitches) then
                  deffile.writefile;
                 { insert all .o files from all loaded units and
                   unload the units, we don't need them anymore.
                   Keep the current_module because that is still needed }
                 hp:=tmodule(loaded_units.first);
                 while assigned(hp) do
                  begin
                    linker.AddModuleFiles(hp);
                    hp2:=tmodule(hp.next);
                    if (hp<>current_module) and
                       (not needsymbolinfo) then
                      begin
                        loaded_units.remove(hp);
                        hp.free;
                      end;
                    hp:=hp2;
                  end;
                 { free also unneeded units we didn't free before }
                 if not needsymbolinfo then
                   unloaded_units.Clear;
                 { finally we can create a executable }
                 if DLLSource then
                   linker.MakeSharedLibrary
                 else
                   linker.MakeExecutable;

                 { collect all necessary information for whole-program optimization }
                 wpoinfomanager.extractwpoinfofromprogram;
               end;


             { Give Fatal with error count for linker errors }
             if (Errorcount>0) and not status.skip_error then
              begin
                Message1(unit_f_errors_in_unit,tostr(Errorcount));
                status.skip_error:=true;
              end;
          end;
        end; //SPrgLibDone
{$ENDIF}
    end;


{ TParserOPL }

procedure TParserOPL.Compile;
begin
WriteLn('*** using alternate parser ***');
{ read the first token }
  current_scanner.readtoken(false);

  if (token=_UNIT) or (compile_level>1) then
   begin
     current_module.is_unit:=true;
     ProcUnit;
   end
  else if (token=_ID) and (idtoken=_PACKAGE) then
   begin
     current_module.IsPackage:=true;
     ProcPackage;
   end
  else
   ProcProgram(token=_LIBRARY);
end;

const
  OPLpas2: TParserListItem = (
    ext: '.pas'; cls: TParserOPL;
    alt:nil; next:nil;
  );
  OPLpp2: TParserListItem = (
    ext: '.pp'; cls: TParserOPL;
    alt:nil; next:nil;
  );
  OPLlpr2: TParserListItem = (
    ext: '.lpr'; cls: TParserOPL;
    alt:nil; next:nil;
  );

initialization
  RegisterParser(@OPLpas2);
  RegisterParser(@OPLpp2);
  RegisterParser(@OPLlpr2);
end.

