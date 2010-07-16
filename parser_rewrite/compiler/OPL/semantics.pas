unit semantics;
(* Implements parser semantic initialization and actions, by DoDi.

  The interface part of this unit can be used for any (new) OPL parser.

  The implementation part implements the FPC compiler stuff.
  It's borrowed from the parser and other p* units.
*)

{$mode objfpc}

interface

procedure InitCodeGen;  //called by InitParser
procedure DoneCodeGen;  //called by DoneParser
procedure InitCompile(const filename:string);  //called by Compile
procedure DoneCompile;  //called by Compile
procedure DoneCompile2;  //called by Compile

implementation

uses
{$IFNDEF USE_FAKE_SYSUTILS}
  sysutils,
{$ELSE}
  fksysutl,
{$ENDIF}
  cclasses, ptype, tokens
  //general requirements?
  ,scanner
  ,switches   //flushpendingswitchesstate

  ,aasmdata   //current_asmdata
  ,procinfo   //current_procinfo
  ,symdef     //current_objectdef
  ,fmodule    //loaded_units, usedunits, unloaded_units
  ,psystem    //registernodes, registertais
  ,globals    //stacksize
  ,systems    //target_info, current_settings
  ,ncgrtti    //RTTIWriter
  ,globtype   //cs_link_on_target
  ,script     //GenerateAsmRes
  ,gendef     //DefFile
  ,symbase    //TSymtablestack
  ,symsym     //tprocsym
  ,scandir    //tswitchesstatestack
  ,CPUInfo    //supported_calling_conventions
  ,pbase      //parse_only
  ,symtable   //systemunit
  ,fppu       //tppumodule
  ,finput     //ms_compile
  ,comphook   //status
  ,verbose
  ;

//these declarations must be accessible to the parser(?)
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

procedure InitCodeGen;  //called by InitParser
begin
//from parser.initparser
  current_asmdata:=nil;
  current_procinfo:=nil;
  current_objectdef:=nil;

         loaded_units:=TLinkedList.Create;

         usedunits:=TLinkedList.Create;

         unloaded_units:=TLinkedList.Create;

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

procedure DoneCodeGen;  //called by DoneParser
begin
         current_procinfo:=nil;
         current_asmdata:=nil;
         current_objectdef:=nil;

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
         RTTIWriter.free;

         { close ppas,deffile }
         asmres.free;
         deffile.free;

         { free list of .o files }
         SmartLinkOFiles.Free;
end;

procedure InitCompile(const filename:string);  //called by Compile
begin
         { parsing a procedure or declaration should be finished }
         if assigned(current_procinfo) then
           internalerror(200811121);
         if assigned(current_objectdef) then
           internalerror(200811122);
         inc(compile_level);
         parser_current_file:=filename;
         { Uses heap memory instead of placing everything on the
           stack. This is needed because compile() can be called
           recursively }
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

         { load current asmdata from current_module }
         current_asmdata:=TAsmData(current_module.asmdata);

end;

procedure DoneCompile;  //called by Compile
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

end;

procedure DoneCompile2;  //called by Compile
begin
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

end.

