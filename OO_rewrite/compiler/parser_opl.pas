{
    Copyright (c) 1998-2002 by Florian Klaempfl

    This unit does the parsing process

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
(* This is the OPL parser class.
  Perhaps the declaration should be moved into the implementation section?
  (to prevent excessive uses, exposure of types and methods)
*)

unit parser_opl;

{$i fpcdefs.inc}

interface

uses
  pbase,
{$IFNDEF USE_FAKE_SYSUTILS}
      sysutils,
{$ELSE}
      fksysutl,
{$ENDIF}
      cutils,cclasses,
      globtype,version,tokens,systems,globals,verbose,switches,
      symbase,symtable,symdef,symsym, symtype,
      finput,fmodule,fppu,
      aasmbase,aasmtai,aasmdata,
      cgbase, dbgbase,
      script,gendef,
      comphook,
      scanner,//scandir,
      //pbase,ptype,psystem,pmodules,psub, --- all inlined
      ncgrtti,htypechk,
      cresstr,cpuinfo,procinfo,
      node, ncal, constexp, symconst;

(* These types are required for method arguments.
  Can be moved into the implementation, together with the detailed class declaration.
*)
    type
      tvar_dec_option=(vd_record,vd_object,vd_threadvar,vd_class);
      tvar_dec_options=set of tvar_dec_option;

    { sub_expr(opmultiply) is need to get -1 ** 4 to be
      read as - (1**4) and not (-1)**4 PM }
    type
      Toperator_precedence=(opcompare,opaddition,opmultiply,oppower);

    type
      tpdflag=(
        pd_body,         { directive needs a body }
        pd_implemen,     { directive can be used implementation section }
        pd_interface,    { directive can be used interface section }
        pd_object,       { directive can be used object declaration }
        pd_procvar,      { directive can be used procvar declaration }
        pd_notobject,    { directive can not be used object declaration }
        pd_notobjintf,   { directive can not be used interface declaration }
        pd_notprocvar,   { directive can not be used procvar declaration }
        pd_dispinterface,{ directive can be used with dispinterface methods }
        pd_cppobject,    { directive can be used with cppclass }
        pd_objcclass,    { directive can be used with objcclass }
        pd_objcprot      { directive can be used with objcprotocol }
      );
      tpdflags=set of tpdflag;

    type
      TOPLParser = class(TParserBase)
      private
       { hack, which allows to use the current parsed }
       { object type as function argument type  }
       testcurobject : byte;

        function check_proc_directive(isprocvar: boolean): boolean;
        function comp_expr(accept_equal: boolean): tnode;
        procedure create_objectfile;
        procedure do_member_read(classh: tobjectdef; getaddr: boolean;
          sym: tsym; var p1: tnode; var again: boolean;
          callflags: tcallnodeflags);
        function expr(dotypecheck: boolean): tnode;
        function factor(getaddr: boolean): tnode;
        procedure generate_specialization(var tt: tdef);
        function get_intconst: TConstExprInt;
        function get_stringconst: string;
        procedure handle_calling_convention(pd: tabstractprocdef);
        procedure id_type(var def: tdef; isforwarddef: boolean);
        function inline_copy: tnode;
        function inline_finalize: tnode;
        function inline_initialize: tnode;
        function inline_setlength: tnode;
        procedure insertobjectfile;
        //procedure insert_funcret_local(pd: tprocdef);
        procedure loadautounits;
        procedure loadunits;
        function maybe_parse_proc_directives(def: tdef): boolean;
        function new_dispose_statement(is_new: boolean): tnode;
        function new_function: tnode;
        function object_dec(objecttype: tobjecttyp; const n: tidstring;
          genericdef: tstoreddef; genericlist: TFPObjectList; fd: tobjectdef
          ): tobjectdef;
        procedure parse_implementation_uses;
        procedure parse_object_proc_directives(pd: tabstractprocdef);
        procedure parse_parameter_dec(pd: tabstractprocdef);
        function parse_paras(__colon, __namedpara: boolean; end_of_paras: ttoken
          ): tnode;
        function parse_proc_dec(isclassmethod: boolean; aclass: tobjectdef
          ): tprocdef;
        procedure parse_proc_directives(pd: tabstractprocdef;
          var pdflags: tpdflags);
        function parse_proc_head(aclass: tobjectdef; potype: tproctypeoption;
          var pd: tprocdef): boolean;
        procedure parse_var_proc_directives(sym: tsym);
        function proc_add_definition(var currpd: tprocdef): boolean;
        function proc_get_importname(pd: tprocdef): string;
        procedure proc_package;
        procedure proc_program(islibrary: boolean);
        procedure proc_set_mangledname(pd: tprocdef);
        procedure proc_unit;
        procedure read_anon_type(var def: tdef; parseprocvardir: boolean);
        procedure read_declarations(islibrary: boolean);
        procedure read_exports;
        procedure read_interface_declarations;
        procedure read_named_type(var def: tdef; const name: TIDString;
          genericdef: tstoreddef; genericlist: TFPObjectList;
          parseprocvardir: boolean);
        function read_property_dec(is_classproperty: boolean; aclass: tobjectdef
          ): tpropertysym;
        procedure read_public_and_external(vs: tabstractvarsym);
        procedure read_public_and_external_sc(sc: TFPObjectList);
        procedure read_record_fields(options: Tvar_dec_options);
        procedure read_var_decls(options: Tvar_dec_options);
        function record_dec: tdef;
        procedure resolve_forward_types;
        procedure set_current_module(p:tmodule);
        procedure setupglobalswitches;
        procedure single_type(var def: tdef; isforwarddef, allowtypedef: boolean
          );
        procedure string_dec(var def: tdef; allowtypedef: boolean);
        function sub_expr(pred_level: Toperator_precedence;
          accept_equal: boolean): tnode;
        function try_consume_hintdirective(var moduleopt: tmoduleoptions;
          var deprecatedmsg: pshortstring): boolean;
      public  //?
        current_debuginfo : tdebuginfo;
        current_module: tmodule;
        current_scanner: tscannerfile; //deprecated; - will disappear
        function block(islibrary: boolean; current_procinfo: tprocinfo) : tnode;
      public
        constructor Create;
        destructor Destroy; override;
        procedure Execute;  //in preparation of threads
        procedure preprocess(const Afilename:string);
      end;

{ TODO : these will disappear }
  procedure initparser;
  procedure doneparser;

implementation

    uses
      psystem, pmodules, psub, cfileutl,
    //pinline
      { symtable }
      defutil,defcmp,
      { pass 1 }
      pass_1,
      nobj,
      nmat,nadd,nmem,nset,ncnv,ninl,ncon,nld,nflw,nbas,nutils,
       { link }
       import
  ;

//this is an attempt to locate non-methods
procedure write_persistent_type_info(st:tsymtable); forward;


{$ifdef PREPROCWRITE}
    procedure TOPLParser.preprocess(const AFilename:string);
      var
        i : longint;
        //current_scanner: tscannerfile;
      begin
      (* Still deserves some improvements:
        - message 'preprocessing...'
        - outfile: where? name?
        - suppress echo {$I...} - is inlined!
      *)
        Message1(parser_i_compiling, AFilename);
      {$IFDEF old}
        if not FileExists(filename) then begin
          Message2(scan_f_cannot_open_input, 'File not found: ', filename);
          inc(status.errorcount);
          Exit;
        end;
      {$ENDIF}
        preprocfile := tpreprocfile.create(AFilename + '.pre'); //???

       { initialize a module, for symbol tables etc. }
         set_current_module(tmodule.create(nil, AFilename, False));

         macrosymtablestack:= TSymtablestack.create;
         { init macros before anything in the file is parsed.}
         current_module.localmacrosymtable:= tmacrosymtable.create(false);
         macrosymtablestack.push(initialmacrosymtable);
         macrosymtablestack.push(current_module.localmacrosymtable);

         main_module:=current_module;
       { startup scanner, and save in current_module }
         //current_scanner:=tscannerfile.Create(AFilename);
         {current_scanner.}firstfile;
       { loop until EOF is found }
         repeat
           {current_scanner.}readtoken(true);
           case token of
             _ID :
               begin
                 preprocfile.Add(orgpattern);
               end;
             _REALNUMBER,
             _INTCONST :
               preprocfile.Add(pattern);
             _CSTRING :
               begin
                 i:=0;
                 while (i<length(cstringpattern)) do
                  begin
                    inc(i);
                    if cstringpattern[i]='''' then
                     begin
                       insert('''',cstringpattern,i);
                       inc(i);
                     end;
                  end;
                 preprocfile.Add(''''+cstringpattern+'''');
               end;
             _CCHAR :
               begin
                 case pattern[1] of
                   #39 :
                     pattern:='''''''';
                   #0..#31,
                   #128..#255 :
                     begin
                       str(ord(pattern[1]),pattern);
                       pattern:='#'+pattern;
                     end;
                   else
                     pattern:=''''+pattern[1]+'''';
                 end;
                 preprocfile.Add(pattern);
               end;
             _EOF :
               break;
             else
               preprocfile.Add(tokeninfo^[token].str)
           end;
         until false;
       {$IFDEF old}
       { free scanner }
         current_scanner.Free;
         current_scanner:=nil;
       {$ELSE}
        set_current_module(nil);
       {$ENDIF}
       { close }
         preprocfile.Free;
      end;
{$endif PREPROCWRITE}

    { TOPLParser }

{ TODO : initparser and doneparser must disappear, all done in classes }

    procedure initparser;
      begin
        {$IFDEF old}
         { Current compiled module/proc }
         set_current_module(nil);
         current_module:=nil;
         current_asmdata:=nil;
         current_procinfo:=nil;
         current_objectdef:=nil;
        {$ELSE}
        {$ENDIF}

         loaded_units:=TLinkedList.Create;

         usedunits:=TLinkedList.Create;

         unloaded_units:=TLinkedList.Create;

         { global switches }
         current_settings.globalswitches:=init_settings.globalswitches;

         current_settings.sourcecodepage:=init_settings.sourcecodepage;

         { initialize scanner }
         InitScanner;
       {$IFDEF old}
         InitScannerDirectives; //in InitScanner

         { scanner }
         c:=#0;
         pattern:='';
         orgpattern:='';
         cstringpattern:='';
         current_scanner:=nil;
         switchesstatestackpos:=0;
       {$ELSE}
        //in scanner constructor
       {$ENDIF}

         { register all nodes and tais }
         registernodes;
         registertais;

         { memory sizes }
         if stacksize=0 then
           stacksize:=target_info.stacksize;

         { RTTI writer }
         RTTIWriter:=TRTTIWriter.Create;

         { open assembler response }
         if cs_link_on_target in current_settings.globalswitches then
           GenerateAsmRes(outputexedir+ChangeFileExt(inputfilename,'_ppas'))
         else
           GenerateAsmRes(outputexedir+'ppas');

         { open deffile }
         DefFile:=TDefFile.Create(outputexedir+ChangeFileExt(inputfilename,target_info.defext));

         { list of generated .o files, so the linker can remove them }
         SmartLinkOFiles:=TCmdStrList.Create;

       {$IFDEF old}
         { codegen }
         if paraprintnodetree<>0 then
           printnode_reset;
       {$ELSE}
        //?
       {$ENDIF}

         { target specific stuff }
         case target_info.system of
           system_powerpc_amiga:
             include(supported_calling_conventions,pocall_syscall);
           system_powerpc_morphos:
             include(supported_calling_conventions,pocall_syscall);
           system_m68k_amiga:
             include(supported_calling_conventions,pocall_syscall);
         end;
      end;


    procedure doneparser;
      begin
        {$IFDEF old}
         { Reset current compiling info, so destroy routines can't
           reference the data that might already be destroyed }
         set_current_module(nil);
         current_module:=nil;
         current_procinfo:=nil;
         current_asmdata:=nil;
         current_objectdef:=nil;
        {$ELSE}
        {$ENDIF}

         { unload units }
         if assigned(loaded_units) then
           begin
             loaded_units.free;
             loaded_units:=nil;
           end;
         if assigned(usedunits) then
           begin
             usedunits.free;
             usedunits:=nil;
           end;
         if assigned(unloaded_units) then
           begin
             unloaded_units.free;
             unloaded_units:=nil;
           end;

       {$IFDEF old}
         { if there was an error in the scanner, the scanner is
           still assinged }
         if assigned(current_scanner) then
          begin
            current_scanner.free;
            current_scanner:=nil;
          end;

         { close scanner }
         DoneScanner;
       {$ELSE}
        //by creator of the parser instance
       {$ENDIF}

         RTTIWriter.free;

         { close ppas,deffile }
         asmres.free;
         deffile.free;

         { free list of .o files }
         SmartLinkOFiles.Free;
      end;

    constructor TOPLParser.Create;
    begin
      current_scanner := self;  //for now
      //what?
    end;

    destructor TOPLParser.Destroy;
    begin
      //what?
      //FreeAndNil(current_scanner);  //=self!
      current_scanner := nil; //prevent destruction of self!
      inherited Destroy;
    end;


    procedure TOPLParser.set_current_module(p: tmodule);
    begin
      current_module := p;
      if p = nil then begin
      //cleanup
        //FreeAndNil(current_scanner); not if baseclass!
      end;
    end;

{*****************************************************************************
                             Compile a source file
*****************************************************************************}

    //procedure compile(const filename:string);
    procedure TOPLParser.Execute;
    { TODO : move all variables into classes, drop tolddata. }
      type
        polddata=^tolddata;
        tolddata=record
        { scanner }
          oldidtoken,
          oldtoken       : ttoken;
          oldtokenpos    : tfileposinfo;
          oldc           : char;
          oldpattern,
          oldorgpattern  : string;
          old_block_type : tblock_type;
        { symtable }
          oldsymtablestack,
          oldmacrosymtablestack : TSymtablestack;
          oldaktprocsym    : tprocsym;
        { cg }
          oldparse_only  : boolean;
        { akt.. things }
          oldcurrent_filepos      : tfileposinfo;
          old_current_module : tmodule;
          oldcurrent_procinfo : tprocinfo;
          old_settings : tsettings;
          oldsourcecodepage : tcodepagestring;
          old_switchesstatestack : tswitchesstatestack;
          old_switchesstatestackpos : Integer;
        end;

      var
         olddata : polddata;
         hp,hp2 : tmodule;
       begin
         { parsing a procedure or declaration should be finished }
         if assigned(current_procinfo) then
           internalerror(200811121);
         if assigned(current_objectdef) then
           internalerror(200811122);
         inc(compile_level);
         parser_current_file:=ffilename;
         { Uses heap memory instead of placing everything on the
           stack. This is needed because compile() can be called
           recursively }
         { TODO : nothing to save, everything must be in classes }
         new(olddata);
         with olddata^ do
          begin
            old_current_module:=current_module;

            { save symtable state }
            oldsymtablestack:=symtablestack;
            oldmacrosymtablestack:=macrosymtablestack;
            oldcurrent_procinfo:=current_procinfo;

            { save scanner state }
            oldc:=c;
            oldpattern:=pattern;
            oldorgpattern:=orgpattern;
            oldtoken:=token;
            oldidtoken:=idtoken;
            old_block_type:=block_type;
            oldtokenpos:=current_tokenpos;
            old_switchesstatestack:=switchesstatestack;
            old_switchesstatestackpos:=switchesstatestackpos;

            { save cg }
            oldparse_only:=parse_only;

            { save akt... state }
            { handle the postponed case first }
            flushpendingswitchesstate;
            oldcurrent_filepos:=current_filepos;
            old_settings:=current_settings;
          end;

       { reset parser, a previous fatal error could have left these variables in an unreliable state, this is
         important for the IDE }
         afterassignment:=false;
         in_args:=false;
         named_args_allowed:=false;
         got_addrn:=false;
         getprocvardef:=nil;
         allow_array_constructor:=false;

       { show info }
         Message1(parser_i_compiling,filename);

       { reset symtable }
         symtablestack:=TSymtablestack.create;
         macrosymtablestack:=TSymtablestack.create;
         systemunit:=nil;
         current_settings.defproccall:=init_settings.defproccall;
         current_exceptblock:=0;
         exceptblockcounter:=0;
         current_settings.maxfpuregisters:=-1;
       { reset the unit or create a new program }
         { a unit compiled at command line must be inside the loaded_unit list }
         if (compile_level=1) then
           begin
             if assigned(current_module) then
               internalerror(200501158);
             set_current_module(tppumodule.create(nil,filename,'',false));
             addloadedunit(current_module);
             main_module:=current_module;
             current_module.state:=ms_compile;
           end;
         if not(assigned(current_module) and
                (current_module.state in [ms_compile,ms_second_compile])) then
           internalerror(200212281);

         { Load current state from the init values }
         current_settings:=init_settings;

         { load current asmdata from current_module }
         current_asmdata:=TAsmData(current_module.asmdata);

         { startup scanner and load the first file }
       {$IFDEF scanner_based}
        //we ARE the scanner
          current_scanner := self;  //for now
       {$ELSE}
         current_scanner:=tscannerfile.Create(filename);
       {$ENDIF}
         current_scanner.firstfile;
         current_module.scanner:=current_scanner;

         { init macros before anything in the file is parsed.}
         current_module.localmacrosymtable:= tmacrosymtable.create(false);
         macrosymtablestack.push(initialmacrosymtable);
         macrosymtablestack.push(current_module.localmacrosymtable);

         { read the first token }
         current_scanner.readtoken(false);

         { If the compile level > 1 we get a nice "unit expected" error
           message if we are trying to use a program as unit.}
         try
           try
             if (token=_UNIT) or (compile_level>1) then
               begin
                 current_module.is_unit:=true;
                 proc_unit;
               end
             else if (token=_ID) and (idtoken=_PACKAGE) then
               begin
                 current_module.IsPackage:=true;
                 proc_package;
               end
             else
               proc_program(token=_LIBRARY);
           except
             on ECompilerAbort do
               raise;
             on Exception do
               begin
                 { Increase errorcounter to prevent some
                   checks during cleanup }
                 inc(status.errorcount);
                 raise;
               end;
           end;
         finally
           if assigned(current_module) then
             begin
               { module is now compiled }
               tppumodule(current_module).state:=ms_compiled;

               { free ppu }
               if assigned(tppumodule(current_module).ppufile) then
                 begin
                   tppumodule(current_module).ppufile.free;
                   tppumodule(current_module).ppufile:=nil;
                 end;

               { free asmdata }
               if assigned(current_module.asmdata) then
                 begin
                   current_module.asmdata.free;
                   current_module.asmdata:=nil;
                 end;

               { free scanner }
               if assigned(current_module.scanner) then
                 begin
                   if current_scanner=tscannerfile(current_module.scanner) then
                     current_scanner:=nil;
                   tscannerfile(current_module.scanner).free;
                   current_module.scanner:=nil;
                 end;

               { free symtable stack }
               if assigned(symtablestack) then
                 begin
                   symtablestack.free;
                   symtablestack:=nil;
                 end;
               if assigned(macrosymtablestack) then
                 begin
                   macrosymtablestack.free;
                   macrosymtablestack:=nil;
                 end;
             end;

            if (compile_level=1) and
               (status.errorcount=0) then
              { Write Browser Collections }
              do_extractsymbolinfo;

            with olddata^ do
              begin
                { restore scanner }
                c:=oldc;
                pattern:=oldpattern;
                orgpattern:=oldorgpattern;
                token:=oldtoken;
                idtoken:=oldidtoken;
                current_tokenpos:=oldtokenpos;
                block_type:=old_block_type;
                switchesstatestack:=old_switchesstatestack;
                switchesstatestackpos:=old_switchesstatestackpos;

                { restore cg }
                parse_only:=oldparse_only;

                { restore symtable state }
                symtablestack:=oldsymtablestack;
                macrosymtablestack:=oldmacrosymtablestack;
                current_procinfo:=oldcurrent_procinfo;
                current_filepos:=oldcurrent_filepos;
                current_settings:=old_settings;
                current_exceptblock:=0;
                exceptblockcounter:=0;
              end;
            { Shut down things when the last file is compiled succesfull }
            if (compile_level=1) and
                (status.errorcount=0) then
              begin
                parser_current_file:='';
                { Close script }
                if (not AsmRes.Empty) then
                begin
                  Message1(exec_i_closing_script,AsmRes.Fn);
                  AsmRes.WriteToDisk;
                end;
              end;

          { free now what we did not free earlier in
            proc_program PM }
          if (compile_level=1) and needsymbolinfo then
            begin
              hp:=tmodule(loaded_units.first);
              while assigned(hp) do
               begin
                 hp2:=tmodule(hp.next);
                 if (hp<>current_module) then
                   begin
                     loaded_units.remove(hp);
                     hp.free;
                   end;
                 hp:=hp2;
               end;
              { free also unneeded units we didn't free before }
              unloaded_units.Clear;
             end;
           dec(compile_level);
           set_current_module(olddata^.old_current_module);

           dispose(olddata);
         end;
    end;

{$I pdecl.inc}
{$I pinline.inc}
{$I ptype.inc}
{$I psub.inc}
  {$I pmodule.inc}
{$I pexpr.inc}
{$I pdecvar.inc}
{$I pdecobj.inc}
{$I pdecsub.inc}
{$I pexports.inc}

end.
