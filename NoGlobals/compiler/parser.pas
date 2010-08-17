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
      procedure compileMain(const filename:string);
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
      {$IFDEF GlobalModule}
      {$ELSE}
         InvalidateModule;
      {$ENDIF}
         current_asmdata:=nil;
         current_objectdef:=nil;

         loaded_units:=TLinkedList.Create;

         usedunits:=TLinkedList.Create;

         unloaded_units:=TLinkedList.Create;

      {$IFDEF GlobalModule}
         { global switches }
      {nonsense here - copy onto self
         current_settings^.globalswitches:=init_settings.globalswitches;

         current_settings^.sourcecodepage:=init_settings.sourcecodepage;
      }
      {$ELSE}
        //scanner with current_settings does not yet exist!
      {$ENDIF}

         { initialize scanner }
         InitScanner;
         InitScannerDirectives;

         { register all nodes and tais }
         registernodes;
         registertais;

         { memory sizes }
         if stacksize=0 then
           stacksize:=target_info.stacksize;

         { RTTI writer }
         RTTIWriter:=TRTTIWriter.Create;

         { open assembler response }
      {$IFDEF GlobalModule}
      //a dummy module provides global settings and symbol tables
         if cs_link_on_target in current_settings^.globalswitches then
      {$ELSE}
      //scanner with current_settings does not yet exist!
         if cs_link_on_target in init_settings.globalswitches then
      {$ENDIF}
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
         { if there was an error in the scanner, the scanner is
           still assigned }
         InvalidateModule;
         current_asmdata:=nil;
         current_objectdef:=nil;

         { unload units }
         FreeAndNil(loaded_units);
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

  type
    tolddata=record
    {$IFDEF NoGlobals}
    {$ELSE}
    { scanner }
      oldtokenpos    : tfileposinfo;
    { akt.. things }
      oldcurrent_filepos      : tfileposinfo;
    {$ENDIF}
      old_current_module : tmodule;
    end;
    polddata=tolddata;


    procedure compile(const filename:string);

       procedure SaveParser(var olddata: polddata);
       begin
       (*todo: saving the scanner/parser state will no more be required
          with scanner/parser objects.

          These are (currently) global variables, for error/exception log
       *)
         with olddata do
          begin //removed all local variables
            old_current_module:=current_module;

          {$IFDEF NoGlobals}
          {$ELSE}
            oldtokenpos:=current_tokenpos;
            oldcurrent_filepos:=current_filepos;
          {$ENDIF}
          end;
        end;

       procedure RestoreParser(var olddata: polddata);
        begin
          with olddata do
            begin
              PopModule(old_current_module);
            {$IFDEF NoGlobals}
            {$ELSE}
              { restore scanner }
              current_tokenpos:=oldtokenpos;
              current_filepos:=oldcurrent_filepos;
            {$ENDIF}
            end;
        end;


    {$IFDEF old}
       procedure ParseFinished(var olddata: polddata);
         begin
           if assigned(current_module) then
             begin  //todo: move into module
               { module is now compiled }
               tppumodule(current_module).state:=ms_compiled;

               { free ppu }
               FreeAndNil(tppumodule(current_module).ppufile);

               { free asmdata }
               if assigned(current_module.asmdata) then
                 begin
                   current_module.asmdata.free;
                   current_module.asmdata:=nil;
                 end;

               { free symtable stack }
              PopSymbolStack(nil); //local in module!
              FreeAndNil(current_module.macrosymtablestack);
             end;
         end;
    {$ELSE}
      //in module
    {$ENDIF}


    procedure NewParser(const filename:string);
      begin
      {$IFDEF NoGlobals}
        //update status, later?
      {$ELSE}
        parser_current_file:=filename;
      {$ENDIF}
        current_module.scanner:=TParser.Compile(filename); //factory request
        if not assigned(current_module.scanner) then
          Internalerror(20100810);  //todo: regular error message: no parser for this file

       { reset parser, a previous fatal error could have left these variables in an unreliable state, this is
         important for the IDE }
       { reset symtable }
        PushSymbolStack;  //create new
        current_module.macrosymtablestack := TMacroStack.Create;
        WhichMs:=msModule;  //todo: move to after global initialize
         systemunit:=nil; //???

         { load current asmdata from current_module }
         current_asmdata:=TAsmData(current_module.asmdata);
      end;

    procedure Parse;
      begin
       { startup scanner and load the first file }

         current_scanner.firstfile;

       { show info }
         Message1(parser_i_compiling, current_scanner.inputfile.name^);

         { init macros before anything in the file is parsed.}
         current_module.localmacrosymtable:= tmacrosymtable.create(false);
          macrosymtablestack.Init;
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

      var
         olddata : polddata;
      begin  //compile
         { parsing a procedure or declaration should be finished }
         if assigned(current_objectdef) then
           internalerror(200811122);

        SaveParser(olddata);
        inc(compile_level);
       { reset the unit or create a new program }
             if not(assigned(current_module) and
                  (current_module.state in [ms_compile,ms_second_compile])) then
               internalerror(200212281);

        NewParser(filename);
        try
          Parse;
        finally
        {$IFDEF old}
          ParseFinished(olddata);
        {$ELSE}
          current_module.ParseFinished;
        {$ENDIF}
          dec(compile_level);
          RestoreParser(olddata);
        end;
      end;

      procedure compileMain(const filename:string);
       var
         hp,hp2 : tmodule;
       begin  //compile main module
         if assigned(current_module) then
           internalerror(200501158);
         main_module := tppumodule.create(nil,filename,'',false);
         PushModule(main_module);
         { a unit compiled at command line must be inside the loaded_unit list }
         addloadedunit(main_module);
         main_module.state:=ms_compile;
         compile(filename);
         {$IFDEF old}
          //moved here
         {$ELSE}
        { Shut down things when the last file is compiled succesfull }
          if (status.errorcount=0) then begin
            { Write Browser Collections }
            do_extractsymbolinfo;

        //RestoreParser(olddata); - moved below

        {$IFDEF NoGlobals}
        {$ELSE}
            parser_current_file:='';  //here???
        {$ENDIF}
            { Close script }
            if (not AsmRes.Empty) then
            begin
              Message1(exec_i_closing_script,AsmRes.Fn);
              AsmRes.WriteToDisk;
            end;
          end;

          { free now what we did not free earlier in
            proc_program PM }
          if needsymbolinfo then
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
         {$ENDIF}
       end;

end.
