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
unit parser;

{$i fpcdefs.inc}

interface

uses
  pbase;

  {$ifdef PREPROCWRITE}
      procedure preprocess(const filename:string);
  {$endif PREPROCWRITE}
      procedure compile(const filename:string);
      procedure initparser;
      procedure doneparser;

implementation

    uses
{$IFNDEF USE_FAKE_SYSUTILS}
      sysutils,
{$ELSE}
      fksysutl,
{$ENDIF}
      cutils,cclasses,
      globtype,version,tokens,systems,globals,verbose,switches,
      symbase,symtable,symdef,symsym,
      finput,fmodule,fppu,
      aasmbase,aasmtai,aasmdata,
      cgbase,
      script,gendef,
      comphook,
      scanner,scandir,
      ptype,psystem,pmodules,psub,ncgrtti,htypechk,
      cresstr,cpuinfo,procinfo;


    procedure initparser;
      begin
         { we didn't parse a object or class declaration }
         { and no function header                        }
         testcurobject:=0;

         { Current compiled module/proc }
      {$IFDEF old}
         set_current_module(nil);
         current_module:=nil;
      {$ELSE}
        InvalidateModule;
      {$ENDIF}
         current_asmdata:=nil;
         current_procinfo:=nil;
         current_objectdef:=nil;

         loaded_units:=TLinkedList.Create;

         usedunits:=TLinkedList.Create;

         unloaded_units:=TLinkedList.Create;

         { global switches }
         current_settings.globalswitches:=init_settings.globalswitches;

         current_settings.sourcecodepage:=init_settings.sourcecodepage;

         { initialize scanner }
         InitScanner;
         InitScannerDirectives;

         { scanner - should be moved into InitScanner }
         {$IFDEF old}
         c:=#0;
         pattern:='';
         orgpattern:='';
         cstringpattern:='';
         {$ELSE}
         //in TScannerFile
         {$ENDIF}
         //current_scanner:=nil;
         switchesstatestackpos:=0;

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

         { codegen }
         if paraprintnodetree<>0 then
           printnode_reset;

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
         { Reset current compiling info, so destroy routines can't
           reference the data that might already be destroyed }
      {$IFDEF old}
         set_current_module(nil);
         current_module:=nil;
      {$ELSE}

         { if there was an error in the scanner, the scanner is
           still assigned }
         //FreeAndNil(_current_scanner);  //before nilled in InvalidateModule
        InvalidateModule;
      {$ENDIF}
         current_procinfo:=nil;
         current_asmdata:=nil;
         current_objectdef:=nil;

         { unload units }
//WriteLn('---before FreeAndNil(loaded_units);---');
         FreeAndNil(loaded_units);
//WriteLn('---after  FreeAndNil(loaded_units);---');
         FreeAndNil(usedunits);
         FreeAndNil(unloaded_units);
         { close scanner }
         DoneScanner;

         RTTIWriter.free;

         { close ppas,deffile }
         asmres.free;
         deffile.free;

         { free list of .o files }
         SmartLinkOFiles.Free;
      end;




{$ifdef PREPROCWRITE}
    procedure preprocess(const filename:string);
      var
        i : longint;
      begin
         new(preprocfile,init('pre'));
       { initialize a module }
         set_current_module(new(pmodule,init(filename,false)));

         macrosymtablestack:= initialmacrosymtable;
         current_module.localmacrosymtable:= tmacrosymtable.create(false);
         current_module.localmacrosymtable.next:= initialmacrosymtable;
         macrosymtablestack:= current_module.localmacrosymtable;

         main_module:=current_module;
       { startup scanner, and save in current_module }
         current_scanner:=new(pscannerfile,Init(filename));
         current_module.scanner:=current_scanner;
       { loop until EOF is found }
         repeat
           current_scanner^.readtoken(true);
           preprocfile^.AddSpace;
           case token of
             _ID :
               begin
                 preprocfile^.Add(orgpattern);
               end;
             _REALNUMBER,
             _INTCONST :
               preprocfile^.Add(pattern);
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
                 preprocfile^.Add(''''+cstringpattern+'''');
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
                 preprocfile^.Add(pattern);
               end;
             _EOF :
               break;
             else
               preprocfile^.Add(tokeninfo^[token].str)
           end;
         until false;
       { free scanner }
         dispose(current_scanner,done);
         current_scanner:=nil;
       { close }
         dispose(preprocfile,done);
      end;
{$endif PREPROCWRITE}


{*****************************************************************************
                             Compile a source file
*****************************************************************************}

{
    procedure compile(const filename:string);
    var
      p: TParser;
    begin
      p := TParser.Create(filename);
      p.compile;
      p.Free;
    end;
}

  type
    polddata=^tolddata;
    tolddata=record
    { scanner }
      //oldparser: TParser;
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


    procedure compile(const filename:string);
      var
         olddata : polddata;

       procedure SaveParser(var olddata: polddata);
       begin
       (*todo: saving the scanner/parser state will no more be required
          with scanner/parser objects.
       *)
         { Uses heap memory instead of placing everything on the
           stack. This is needed because compile() can be called
           recursively }
         new(olddata);
         with olddata^ do
          begin
            //oldparser := current_parser;
            old_current_module:=current_module;

            { save symtable state }
            oldsymtablestack:=symtablestack;
            oldmacrosymtablestack:=macrosymtablestack;
            oldcurrent_procinfo:=current_procinfo;

            { save scanner state }
            if assigned(current_module) and assigned(current_module.scanner) then
            begin
              oldc:=current_scanner.c;
              oldpattern:=current_scanner.pattern;
              oldorgpattern:=current_scanner.orgpattern;
              oldtoken:=current_scanner.token;
              oldidtoken:=current_scanner.idtoken;
              { save cg }
              oldparse_only:=current_parser.parse_only;
            end;
          //todo: these should become scanner elements as well
            old_block_type:=block_type;
            oldtokenpos:=current_tokenpos;
            old_switchesstatestack:=switchesstatestack;
            old_switchesstatestackpos:=switchesstatestackpos;

            { save akt... state }
            { handle the postponed case first }
            flushpendingswitchesstate;
            oldcurrent_filepos:=current_filepos;
            old_settings:=current_settings;
          end;
        end;

       procedure RestoreParser(var olddata: polddata);
        begin
        //must have reset to old module before
          with olddata^ do
            begin
            {$IFDEF old}
              { restore scanner }
              //current_scanner := oldparser;
              if assigned(current_scanner) then begin
                current_scanner.c:=oldc;
                current_scanner.pattern:=oldpattern;
                current_scanner.orgpattern:=oldorgpattern;
                current_scanner.token:=oldtoken;
                current_scanner.idtoken:=oldidtoken;
                current_tokenpos:=oldtokenpos;

                { restore cg }
                current_parser.parse_only:=oldparse_only;
              end;
            {$ELSE}
            {$ENDIF}
              block_type:=old_block_type;
              switchesstatestack:=old_switchesstatestack;
              switchesstatestackpos:=old_switchesstatestackpos;

              { restore symtable state }
              symtablestack:=oldsymtablestack;
              macrosymtablestack:=oldmacrosymtablestack;
              current_procinfo:=oldcurrent_procinfo;
              current_filepos:=oldcurrent_filepos;
              current_settings:=old_settings;
              current_exceptblock:=0;
              exceptblockcounter:=0;
            end;
        end;

       procedure ParseFinished(var olddata: polddata);
         var
           hp,hp2 : tmodule;
         begin
           if assigned(current_module) then
             begin  //todo: move into module
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

             {$IFDEF old}
               { free scanner }
               if assigned(current_module.scanner) then
                 begin
                   if current_scanner=tscannerfile(current_module.scanner) then
                     current_scanner:=nil;  //todo: in destructor
                   if current_module <> main_module then
                     tscannerfile(current_module.scanner).free; //else here, later!
                   current_module.scanner:=nil;
                 end;
             {$ELSE}
              //in module.destroy
             {$ENDIF}

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

            //RestoreParser(olddata); - moved below

            { Shut down things when the last file is compiled succesfull }
            if (compile_level=1) then begin
              if (status.errorcount=0) then
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
              if {(compile_level=1) and} needsymbolinfo then
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
            end;
           dec(compile_level);
         {$IFDEF old}
           set_current_module(olddata^.old_current_module);
         {$ELSE}
          PopModule(olddata^.old_current_module);
         {$ENDIF}
          RestoreParser(olddata);

           dispose(olddata);
         end;


    procedure NewParser(const filename:string);
      var
         p: TParser;
      begin
        parser_current_file:=filename;
        p := TParser.Compile(filename); //factory request
        inc(compile_level);
       { reset the unit or create a new program }
         { a unit compiled at command line must be inside the loaded_unit list }
         if (compile_level=1) then
           begin  //compile main module
             if assigned(current_module) then
               internalerror(200501158);
             main_module := tppumodule.create(nil,filename,'',false);
             main_module.scanner := p;
             PushModule(main_module); //also activate scanner
             addloadedunit(current_module);
             current_module.state:=ms_compile;
           end
         else
           begin
             if not(assigned(current_module) and
                  (current_module.state in [ms_compile,ms_second_compile])) then
               internalerror(200212281);
             current_module.scanner:=p; //current_scanner; //if not main unit
           end;

       { reset parser, a previous fatal error could have left these variables in an unreliable state, this is
         important for the IDE }
       { reset symtable }
         symtablestack:=TSymtablestack.create;
         macrosymtablestack:=TSymtablestack.create;
         systemunit:=nil;
         current_settings.defproccall:=init_settings.defproccall;
         current_exceptblock:=0;
         exceptblockcounter:=0;
         current_settings.maxfpuregisters:=-1;

         { Load current state from the init values }
         current_settings:=init_settings;

         { load current asmdata from current_module }
         current_asmdata:=TAsmData(current_module.asmdata);
      end;

    procedure Parse;
      begin
       { show info }
         Message1(parser_i_compiling, parser_current_file);  // filename);

       { startup scanner and load the first file }

         current_scanner.firstfile;

         { init macros before anything in the file is parsed.}
         current_module.localmacrosymtable:= tmacrosymtable.create(false);
         macrosymtablestack.push(initialmacrosymtable);
         macrosymtablestack.push(current_module.localmacrosymtable);

         { read the first token }
         current_scanner.readtoken(false);

         { If the compile level > 1 we get a nice "unit expected" error
           message if we are trying to use a program as unit.}
           try
             if (current_scanner.token=_UNIT) or (compile_level>1) then
               begin
                 current_module.is_unit:=true;
                 proc_unit;
               end
             else if (current_scanner.token=_ID) and (current_scanner.idtoken=_PACKAGE) then
               begin
                 current_module.IsPackage:=true;
                 proc_package;
               end
             else
               proc_program(current_scanner.token=_LIBRARY);
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
        end;  //Parse

      begin  //compile
         { parsing a procedure or declaration should be finished }
         if assigned(current_procinfo) then
           internalerror(200811121);
         if assigned(current_objectdef) then
           internalerror(200811122);

        SaveParser(olddata);
        NewParser(filename);
        try
          Parse;
        finally
          ParseFinished(olddata);
        end;
      end;

(*
{ TOPLParser }

constructor TOPLParser.Create(const fn: string);
begin
  inherited Create(fn);
end;

procedure TOPLParser.Execute;
begin
  //inherited Execute;
  //initparser;
  compile;
end;
*)

end.
