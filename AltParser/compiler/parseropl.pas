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
  pmodules,pexpr,psub,
//for semantic
  sysutils,
  cutils,finput,comphook,verbose,
  symbase,symtable,symsym,symdef,symconst,
  ptype,
  ncgutil,objcgutl,import,dbgbase,cresstr,comprsrc,gendef,
  cpubase, ppu,fppu,export, systems,
  aasmbase,aasmdata,aasmcpu,aasmtai,wpobase, wpoinfo,link
  ;

(* These constants are for debugging the semantic procedures.
  It looks as if the same code behaves differently,
  when used in a global or local procedure :-(

  When different behaviour is assumed, set the condition to Buggy
  to use the inlined code (known to work correctly).

  When different behaviour has been detected, set the condition to BugHere
  so that correct (inlined) code is enabled by default.
  Set BugHere to True to use the code in the subroutine.
*)
const
  Sem = True; //False; //use semantic procedures?
  Buggy = True; //False;  //use selected semantic procedures?
  BugHere = False;  //enable buggy semantic procedures?
  //BugHere = True; // False;  //enable buggy semantic procedures?

{***************************************************************
                From pmodules
***************************************************************}

    procedure SUsesAdd(s,sorg:TIDString; const fn: string);
      var
        pu      : tused_unit;
        hp2     : tmodule;
        unitsym : tunitsym;
     begin  //SUsesAdd
       { Give a warning if lineinfo is loaded }
       if s='LINEINFO' then begin
        Message(parser_w_no_lineinfo_use_switch);
        if (paratargetdbg in [dbg_dwarf2, dbg_dwarf3]) then
          s := 'LNFODWRF';
        sorg := s;
       end;
       { Give a warning if objpas is loaded }
       if s='OBJPAS' then
        Message(parser_w_no_objpas_use_mode);
       { Using the unit itself is not possible }
       if (s<>current_module.modulename^) then
        begin
          { check if the unit is already used }
          hp2:=nil;
          pu:=tused_unit(current_module.used_units.first);
          while assigned(pu) do
           begin
             if (pu.u.modulename^=s) then
              begin
                hp2:=pu.u;
                break;
              end;
             pu:=tused_unit(pu.next);
           end;
          if not assigned(hp2) then
            hp2:=registerunit(current_module,sorg,fn)
          else
            Message1(sym_e_duplicate_id,s);
          { Create unitsym, we need to use the name as specified, we
            can not use the modulename because that can be different
            when -Un is used }
          unitsym:=tunitsym.create(sorg,nil);
          current_module.localsymtable.insert(unitsym);
          { the current module uses the unit hp2 }
          current_module.addusedunit(hp2,true,unitsym);
        end
       else
        Message1(sym_e_duplicate_id,s);
     end;

    procedure SUsesDone;
    var
      pu      : tused_unit;
    begin //SUsesDone;
     { Load the units }
     pu:=tused_unit(current_module.used_units.first);
     while assigned(pu) do
      begin
        { Only load the units that are in the current
          (interface/implementation) uses clause }
        if pu.in_uses and
           (pu.in_interface=current_module.in_interface) then
         begin
           tppumodule(pu.u).loadppu;
           { is our module compiled? then we can stop }
           if current_module.state=ms_compiled then
            exit;
           { add this unit to the dependencies }
           pu.u.adddependency(current_module);
           { save crc values }
           pu.checksum:=pu.u.crc;
           pu.interface_checksum:=pu.u.interface_crc;
           pu.indirect_checksum:=pu.u.indirect_crc;
           { connect unitsym to the module }
           pu.unitsym.module:=pu.u;
           { add to symtable stack }
           symtablestack.push(pu.u.globalsymtable);
           if (m_mac in current_settings.modeswitches) and
              assigned(pu.u.globalmacrosymtable) then
             macrosymtablestack.push(pu.u.globalmacrosymtable);
           { check hints }
           pu.u.check_hints;
         end;
        pu:=tused_unit(pu.next);
      end;
    end;

    procedure loadunits;
      var
         s,sorg  : TIDString;
         fn      : string;

      var //for inlined procedures only - remove together with inlined code!
        pu      : tused_unit;
        hp2     : tmodule;
        unitsym : tunitsym;
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

         if Sem then SUsesAdd(s,sorg,fn) else
         begin  //SUsesAdd
           { Give a warning if lineinfo is loaded }
           if s='LINEINFO' then begin
            Message(parser_w_no_lineinfo_use_switch);
            if (paratargetdbg in [dbg_dwarf2, dbg_dwarf3]) then
              s := 'LNFODWRF';
            sorg := s;
           end;
           { Give a warning if objpas is loaded }
           if s='OBJPAS' then
            Message(parser_w_no_objpas_use_mode);
           { Using the unit itself is not possible }
           if (s<>current_module.modulename^) then
            begin
              { check if the unit is already used }
              hp2:=nil;
              pu:=tused_unit(current_module.used_units.first);
              while assigned(pu) do
               begin
                 if (pu.u.modulename^=s) then
                  begin
                    hp2:=pu.u;
                    break;
                  end;
                 pu:=tused_unit(pu.next);
               end;
              if not assigned(hp2) then
                hp2:=registerunit(current_module,sorg,fn)
              else
                Message1(sym_e_duplicate_id,s);
              { Create unitsym, we need to use the name as specified, we
                can not use the modulename because that can be different
                when -Un is used }
              unitsym:=tunitsym.create(sorg,nil);
              current_module.localsymtable.insert(unitsym);
              { the current module uses the unit hp2 }
              current_module.addusedunit(hp2,true,unitsym);
            end
           else
            Message1(sym_e_duplicate_id,s);
         end; //SUsesAdd

           if token=_COMMA then
            begin
              pattern:='';
              consume(_COMMA);
            end
           else
            break;
         until false;

        if BugHere {Sem} {Buggy} then SUsesDone else
        begin //SUsesDone;
         { Load the units }
         pu:=tused_unit(current_module.used_units.first);
         while assigned(pu) do
          begin
            { Only load the units that are in the current
              (interface/implementation) uses clause }
            if pu.in_uses and
               (pu.in_interface=current_module.in_interface) then
             begin
               tppumodule(pu.u).loadppu;
               { is our module compiled? then we can stop }
               if current_module.state=ms_compiled then
                exit;
               { add this unit to the dependencies }
               pu.u.adddependency(current_module);
               { save crc values }
               pu.checksum:=pu.u.crc;
               pu.interface_checksum:=pu.u.interface_crc;
               pu.indirect_checksum:=pu.u.indirect_crc;
               { connect unitsym to the module }
               pu.unitsym.module:=pu.u;
               { add to symtable stack }
               symtablestack.push(pu.u.globalsymtable);
               if (m_mac in current_settings.modeswitches) and
                  assigned(pu.u.globalmacrosymtable) then
                 macrosymtablestack.push(pu.u.globalmacrosymtable);
               { check hints }
               pu.u.check_hints;
             end;
            pu:=tused_unit(pu.next);
          end;
        end; //UsesDone;

         consume(_SEMICOLON);
      end;

    procedure ProcUnit;

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

        procedure SModuleInitUnit;
        begin //SModuleInitUnit;
         init_procinfo:=nil;
         finalize_procinfo:=nil;

         if m_mac in current_settings.modeswitches then
           current_module.mode_switch_allowed:= false;
        end;

        procedure SUnitName;
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
        end;

        procedure SUnitInterface;
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
      end;

        procedure SUnitIntfDone;
        begin //SUnitIntfDone
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

         { ... parse the declarations }
         Message1(parser_u_parsing_interface,current_module.realmodulename^);
         symtablestack.push(current_module.globalsymtable);
         read_interface_declarations;
         symtablestack.pop(current_module.globalsymtable);

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

        procedure SUnitImplInit;
        begin //SUnitImplInit;
         if current_module.state=ms_compiled then
           exit;

         { All units are read, now give them a number }
         current_module.updatemaps;

         symtablestack.push(current_module.globalsymtable);
         symtablestack.push(current_module.localsymtable);
        end; //SUnitImplInit;

        procedure SUnitBodyInit;
            begin //SUnitBodyInit;
             Message1(parser_u_parsing_implementation,current_module.modulename^);
             if current_module.in_interface then
               internalerror(200212285);

             { Compile the unit }
             init_procinfo:=create_main_proc(make_mangledname('',current_module.localsymtable,'init'),potype_unitinit,current_module.localsymtable);
             init_procinfo.procdef.aliasnames.insert(make_mangledname('INIT$',current_module.localsymtable,''));
            end; //SUnitBodyInit;

        procedure SUnitBodyDone;
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

        procedure SUnitFinalInit(fPresent: boolean);
        begin
          if fPresent then
            begin //finalize_procinfo:= SUnitFinalInit;
              { the uf_finalize flag is only set after we checked that it
                wasn't empty }

              { Compile the finalize }
              finalize_procinfo:=create_main_proc(make_mangledname('',current_module.localsymtable,'finalize'),potype_unitfinalize,current_module.localsymtable);
              finalize_procinfo.procdef.aliasnames.insert(make_mangledname('FINALIZE$',current_module.localsymtable,''));
            end
          else
           finalize_procinfo:=gen_implicit_initfinal(uf_finalize,current_module.localsymtable);
        end;

        procedure SUnitFinalDone;
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

        procedure SUnitDone;
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

      begin
        if Sem then SModuleInitUnit else
        begin //SModuleInitUnit;
         init_procinfo:=nil;
         finalize_procinfo:=nil;

         if m_mac in current_settings.modeswitches then
           current_module.mode_switch_allowed:= false;
        end; //SModuleInitUnit;

         consume(_UNIT);
         if compile_level=1 then
          Status.IsExe:=false;

         if token=_ID then
          if Sem then SUnitName else
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

         consume(_ID);

         { parse hint directives }
         try_consume_hintdirective(current_module.moduleoptions, current_module.deprecatedmsg);

         consume(_SEMICOLON);
         consume(_INTERFACE);

         if Sem then SUnitInterface else
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

         { insert qualifier for the system unit (allows system.writeln) }
         if not(cs_compilesystem in current_settings.moduleswitches) and
            (token=_USES) then
           begin
             loadunits;
             { has it been compiled at a higher level ?}
             if current_module.state=ms_compiled then
               exit;
           end;

         if Sem then SUnitIntfDone else
         begin //SUnitIntfDone
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

         { ... parse the declarations }
         Message1(parser_u_parsing_interface,current_module.realmodulename^);
         symtablestack.push(current_module.globalsymtable);
         read_interface_declarations;
         symtablestack.pop(current_module.globalsymtable);

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

         if not current_module.interface_only then
           begin
             consume(_IMPLEMENTATION);
             Message1(unit_u_loading_implementation_units,current_module.modulename^);
             { Read the implementation units }
             //inlined parse_implementation_uses;
             if token=_USES then
               loadunits;
           end;

        if Sem then SUnitImplInit else
        begin //SUnitImplInit;
         if current_module.state=ms_compiled then
           exit;

         { All units are read, now give them a number }
         current_module.updatemaps;

         symtablestack.push(current_module.globalsymtable);
         symtablestack.push(current_module.localsymtable);
        end; //SUnitImplInit;

        if not current_module.interface_only then
          begin
            if Sem then SUnitBodyInit else
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
          end;

        if Sem then SUnitBodyDone else
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

         { finalize? }
         if not current_module.interface_only and (token=_FINALIZATION) then
           begin
              if Sem then SUnitFinalInit(True) else
            begin //finalize_procinfo:= SUnitFinalInit;
              { the uf_finalize flag is only set after we checked that it
                wasn't empty }

              { Compile the finalize }
              finalize_procinfo:=create_main_proc(make_mangledname('',current_module.localsymtable,'finalize'),potype_unitfinalize,current_module.localsymtable);
              finalize_procinfo.procdef.aliasnames.insert(make_mangledname('FINALIZE$',current_module.localsymtable,''));
            end; //SUnitFinalInit;

              finalize_procinfo.parse_body;
           end
         else if force_init_final then
          if Sem then SUnitFinalInit(False) else
          begin //SUnitFinalInit(False)
           finalize_procinfo:=gen_implicit_initfinal(uf_finalize,current_module.localsymtable);
          end;

         if Sem then SUnitFinalDone else
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

         { the last char should always be a point }
         consume(_POINT);

        if Sem then SUnitDone else
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

        Message1(unit_u_finished_compiling,current_module.modulename^);
      end;


    procedure ProcPackage;
      var
        main_file : tinputfile;
        hp,hp2    : tmodule;
        {finalize_procinfo,
        init_procinfo,
        main_procinfo : tcgprocinfo;}
        force_init_final : boolean;
        uu : tused_unit;

      procedure SModuleInitPackage;
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

      procedure SPackageName;
        begin //SPackageName
         current_module.setmodulename(orgpattern);
         current_module.ispackage:=true;
         exportlib.preparelib(orgpattern);

         if tf_library_needs_pic in target_info.flags then
           include(current_settings.moduleswitches,cs_create_pic);
        end; //SPackageName

      procedure SPackageInterface;
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

      procedure SPackageImplInit;
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

      procedure SPackageDone;
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


      begin //ProcPackage
        if Sem then SModuleInitPackage else
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

         consume(_ID);  //PACKAGE

        if Sem then SPackageName else
        begin //SPackageName
         current_module.setmodulename(orgpattern);
         current_module.ispackage:=true;
         exportlib.preparelib(orgpattern);

         if tf_library_needs_pic in target_info.flags then
           include(current_settings.moduleswitches,cs_create_pic);
        end; //SPackageName

         consume(_ID);
         consume(_SEMICOLON);

        if Sem then SPackageInterface else
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

        if Sem then SPackageImplInit else
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

         { consume the last point }
         consume(_END);
         consume(_POINT);

        if Sem then SPackageDone else
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
      end;


    procedure ProcProgram(islibrary : boolean);
      var
         main_file : tinputfile;
         hp,hp2    : tmodule;
         finalize_procinfo,
         init_procinfo,
         main_procinfo : tcgprocinfo;
         force_init_final : boolean;
         resources_used : boolean;

      procedure SModuleInitProgLib;
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

      procedure SLibName;
            begin //SLibName
              current_module.setmodulename(orgpattern);
              current_module.islibrary:=true;
              exportlib.preparelib(orgpattern);
            end; //SLibName

      procedure SProgName;
            begin //SProgName
              current_module.setmodulename(orgpattern);
              if (target_info.system in systems_unit_program_exports) then
                exportlib.preparelib(orgpattern);
            end; //SProgName

      procedure SProgNameNone;
          begin //SProgNameNone
          if (target_info.system in systems_unit_program_exports) then
           exportlib.preparelib(current_module.realmodulename^);
          end; //SProgNameNone

      procedure SProgLibImplInit;
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

      procedure SProgLibBodyInit;
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
        end; //SProgLibBodyInit

      procedure SProgLibBodyDone;
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

      procedure SProgLibFinalInit(fExplicit: boolean);
      begin
        if fExplicit then
            begin //SProgLibFinalInit(True)
              { the uf_finalize flag is only set after we checked that it
                wasn't empty }

              { Parse the finalize }
              finalize_procinfo:=create_main_proc(make_mangledname('',current_module.localsymtable,'finalize'),potype_unitfinalize,current_module.localsymtable);
              finalize_procinfo.procdef.aliasnames.insert(make_mangledname('FINALIZE$',current_module.localsymtable,''));
              finalize_procinfo.procdef.aliasnames.insert('PASCALFINALIZE');
            end //SProgLibFinalInit(True)
        else
             finalize_procinfo:=gen_implicit_initfinal(uf_finalize,current_module.localsymtable);
      end;

      procedure SPrgLibFinalDone;
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

      procedure SPrgLibDone;
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


      begin //ProcProgram
        if Sem then SModuleInitProgLib else
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

         if islibrary then
           begin
              consume(_LIBRARY);

              //if token=_ID then ...
            if Sem then SLibName else
            begin //SLibName
              current_module.setmodulename(orgpattern);
              current_module.islibrary:=true;
              exportlib.preparelib(orgpattern);
            end; //SLibName

            //where???
              if tf_library_needs_pic in target_info.flags then
                include(current_settings.moduleswitches,cs_create_pic);

              consume(_ID);
              consume(_SEMICOLON);
           end
         else //program
           { is there an program head ? }
           if token=_PROGRAM then //PROGRAM header
            begin
              consume(_PROGRAM);
              if Sem then SProgName else
            begin //SProgName
              current_module.setmodulename(orgpattern);
              if (target_info.system in systems_unit_program_exports) then
                exportlib.preparelib(orgpattern);
            end; //SProgName
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
         else
          if Sem then SProgNameNone else
          begin //SProgNameNone
          if (target_info.system in systems_unit_program_exports) then
           exportlib.preparelib(current_module.realmodulename^);
          end; //SProgNameNone

        if Sem then SProgLibImplInit else
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

         {Load the units used by the program we compile.}
         if token=_USES then
           loadunits;

        if Sem then SProgLibBodyInit else
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

        if Sem then SProgLibBodyDone else
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

         { finalize? }
         if token=_FINALIZATION then
           begin
            if sem then SProgLibFinalInit(True) else
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
            if Sem then SProgLibFinalInit(False) else
            begin //SPrgLibFinalInit(False)
             finalize_procinfo:=gen_implicit_initfinal(uf_finalize,current_module.localsymtable);
            end; //SPrgLibFinalInit(False)

         if Sem then SPrgLibFinalDone else
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

         { consume the last point }
         consume(_POINT);

        if Sem then SPrgLibDone else
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

