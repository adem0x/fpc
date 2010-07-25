{
    Copyright (c) 1998-2002 by Florian Klaempfl

    Contains some helper routines for the parser

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
(* OO modifications

In a first try this unit (singleton) has been converted into a class.
  The methods should reside in the scanner,
  but to reduce the modifications of all calls we implement stubs here, at least.
  Exact placement of the method implementation is subject to optimization (profiling)
In a second try it may be more efficient to base the parser on the scanner class,
  provided that every parser uses exactly one scanner (not so likely?)

  All other parser units must become include files of the parser unit,
  their procedures become methods of the parser.
*)

unit pbase;

{$i fpcdefs.inc}
{$DEFINE consume_in_parser}

interface

    uses
       cutils,cclasses,
       tokens,globtype,globals,
       symconst,symbase,symtype,symdef,symsym,symtable
      ,scanner
       ;

    const
       { tokens that end a block or statement. And don't require
         a ; on the statement before }
       endtokens = [_SEMICOLON,_END,_ELSE,_UNTIL,_EXCEPT,_FINALLY];

  type
  {$IFDEF consume_in_parser}
    TParserBase = class(tscannerfile)
  {$ELSE}
    TParserBase = class //(tscannerfile)
  {$ENDIF}
    public  //really?
    {$IFDEF NoGlobals}
    {$ELSE}
     current_scanner : tscannerfile;  { current scanner in use }
     //current_module: tmodule; //circular reference!
     current_settings: tsettings;
    {$ENDIF}

     { true, if we are after an assignement }
     afterassignment : boolean; // = false;

     { true, if we are parsing arguments }
     in_args : boolean; // = false;

     { true, if we are parsing arguments allowing named parameters }
     named_args_allowed : boolean;  // = false;

     { true, if we got an @ to get the address }
     got_addrn  : boolean;  // = false;

     { special for handling procedure vars }
     getprocvardef : tprocvardef; // = nil;

     { for operators }
     //optoken : ttoken; - moved into scanner?

     { true, if only routine headers should be parsed }
     parse_only : boolean;

     { true, if we found a name for a named arg }
     found_arg_name : boolean;

     { true, if we are parsing generic declaration }
     parse_generic : boolean;

{$IFDEF consume_in_parser}
  //everything inherited
{$ELSE}
    procedure identifier_not_found(const s:string);

    { consumes token i, if the current token is unequal i }
    { a syntax error is written                           }
    procedure consume(i : ttoken);

    {Tries to consume the token i, and returns true if it was consumed:
     if token=i.}
    function try_to_consume(i:Ttoken):boolean;

    { consumes all tokens til atoken (for error recovering }
    procedure consume_all_until(atoken : ttoken);

    { consumes tokens while they are semicolons }
    procedure consume_emptystats;

    { reads a list of identifiers into a string list }
    { consume a symbol, if not found give an error and
      and return an errorsym }
    function consume_sym(var srsym:tsym;var srsymtable:TSymtable):boolean;
    function consume_sym_orgid(var srsym:tsym;var srsymtable:TSymtable;var s : string):boolean;

    function try_consume_unitsym(var srsym:tsym;var srsymtable:TSymtable;var tokentoconsume : ttoken):boolean;

    function try_consume_hintdirective(var symopt:tsymoptions; var deprecatedmsg:pshortstring):boolean;
{$ENDIF}
  protected
    ffilename: string;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    class procedure compile(const filename:string); //should return the compiled module?
{$ifdef PREPROCWRITE}
    class procedure preprocess(const filename:string);
{$endif PREPROCWRITE}
    property filename: string read ffilename;
  end;

  procedure initparser;
  procedure doneparser;

implementation

    uses
       //globals,
      htypechk,//scanner,
      systems,verbose,fmodule,
      aasmdata, //current_asmdata
      procinfo, //current_procinfo
      psystem,  //registernodes
      ncgrtti,  //RTTIWriter
      script,   //GenerateAsmRes
      sysutils, //ChangeFileExt
      gendef,   //DefFile
      psub,     //printnode_reset
      cpuinfo,  //supported_calling_conventions
    //specialized parsers
      parser_opl;

{$IFnDEF old}
//moved from parser
    procedure initparser;
      begin
        {$IFDEF NoGlobals}
          InitModules;
        {$ELSE}
         { Current compiled module/proc }
         set_current_module(nil);
         current_module:=nil;
         current_asmdata:=nil;
         current_procinfo:=nil;
         current_objectdef:=nil;

         loaded_units:=TLinkedList.Create;

         usedunits:=TLinkedList.Create;

         unloaded_units:=TLinkedList.Create;

        { DONE : move into parser constructor }
         { global switches }
         current_settings.globalswitches:=init_settings.globalswitches;

         current_settings.sourcecodepage:=init_settings.sourcecodepage;

         { initialize scanner }
         InitScanner; // !!!global!!!

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
        //in InitScanner and constructor
       {$ENDIF}
       {$ENDIF}

       { TODO : become globals? - preprocessor? }
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
       {$ELSE}
         { close scanner }
         DoneScanner;
        //by creator of the parser instance
       {$ENDIF}

         RTTIWriter.free;

         { close ppas,deffile }
         asmres.free;
         deffile.free;

         { free list of .o files }
         SmartLinkOFiles.Free;
      end;
{$ELSE}
//in parser
{$ENDIF}

      { TParserBase }

      constructor TParserBase.Create;
      begin
      //the filename is not yet known!
      //from InitParser
         { global switches }
         current_settings.globalswitches:=init_settings.globalswitches;

         current_settings.sourcecodepage:=init_settings.sourcecodepage;

         { initialize scanner }
         InitScanner;
        //what?
        //inherited Create; - nothing to inherit
      end;

      destructor TParserBase.Destroy;
      begin
        //what?
        inherited Destroy;
      end;

      class procedure TParserBase.compile(const filename: string);
      var
        parser: TOPLParser;
      begin
      (* Later on this method can detect the language of the file,
          and create an parser accordingly.
      *)
        parser := TOPLParser.Create;
        parser.ffilename := filename;
        parser.Execute; //must init all class members
        parser.Free;
      end;

      class procedure TParserBase.preprocess(const filename: string);
      var
        parser: TOPLParser;
      begin
      (* Later on this method can detect the language of the file,
          and preprocess the file accordingly.
      *)
        parser := TOPLParser.Create;
        parser.preprocess(filename);
        parser.Free;
      end;

{****************************************************************************
                               Token Parsing
****************************************************************************}

{$IFDEF old}
{$IFnDEF consume_in_parser}
     procedure TParserBase.identifier_not_found(const s:string);
       begin
         Message1(sym_e_id_not_found,s);
         { show a fatal that you need -S2 or -Sd, but only
           if we just parsed the a token that has m_class }
         if not(m_class in current_settings.modeswitches) and
            (Upper(s)={current_scanner.}pattern) and
            (tokeninfo^[{current_scanner.}idtoken].keyword=m_class) then
           Message(parser_f_need_objfpc_or_delphi_mode);
       end;


    { consumes token i, write error if token is different }
    procedure TParserBase.consume(i : ttoken);
      begin
        if (token<>i) and (idtoken<>i) then
          if token=_id then
            Message2(scan_f_syn_expected,tokeninfo^[i].str,'identifier '+pattern)
          else
            Message2(scan_f_syn_expected,tokeninfo^[i].str,tokeninfo^[token].str)
        else
          begin
            if token=_END then
              last_endtoken_filepos:=current_tokenpos;
            {current_scanner.}readtoken(true);
          end;
      end;


    function TParserBase.try_to_consume(i:Ttoken):boolean;
      begin
        try_to_consume:=false;
        if (token=i) or (idtoken=i) then
         begin
           try_to_consume:=true;
           if token=_END then
            last_endtoken_filepos:=current_tokenpos;
           {current_scanner.}readtoken(true);
         end;
      end;


    procedure TParserBase.consume_all_until(atoken : ttoken);
      begin
         while (token<>atoken) and (idtoken<>atoken) do
          begin
            Consume(token);
            if token=_EOF then
             begin
               Consume(atoken);
               Message(scan_f_end_of_file);
               exit;
             end;
          end;
      end;

    procedure TParserBase.consume_emptystats;
      begin
         repeat
         until not try_to_consume(_SEMICOLON);
      end;


    { check if a symbol contains the hint directive, and if so gives out a hint
      if required.

      If this code is changed, it's likly that consume_sym_orgid and factor_read_id
      must be changed as well (FK)
    }
    function TParserBase.consume_sym(var srsym:tsym;var srsymtable:TSymtable):boolean;
      var
        t : ttoken;
      begin
        { first check for identifier }
        if token<>_ID then
          begin
            consume(_ID);
            srsym:=generrorsym;
            srsymtable:=nil;
            result:=false;
            exit;
          end;
        searchsym(pattern,srsym,srsymtable);
        { handle unit specification like System.Writeln }
        try_consume_unitsym(srsym,srsymtable,t);
        { if nothing found give error and return errorsym }
        if assigned(srsym) then
          check_hints(srsym,srsym.symoptions,srsym.deprecatedmsg)
        else
          begin
            identifier_not_found(orgpattern);
            srsym:=generrorsym;
            srsymtable:=nil;
          end;
        consume(t);
        result:=assigned(srsym);
      end;


    { check if a symbol contains the hint directive, and if so gives out a hint
      if required and returns the id with it's original casing
    }
    function TParserBase.consume_sym_orgid(var srsym:tsym;var srsymtable:TSymtable;var s : string):boolean;
      var
        t : ttoken;
      begin
        { first check for identifier }
        if token<>_ID then
          begin
            consume(_ID);
            srsym:=generrorsym;
            srsymtable:=nil;
            result:=false;
            exit;
          end;
        searchsym(pattern,srsym,srsymtable);
        { handle unit specification like System.Writeln }
        try_consume_unitsym(srsym,srsymtable,t);
        { if nothing found give error and return errorsym }
        if assigned(srsym) then
          check_hints(srsym,srsym.symoptions,srsym.deprecatedmsg)
        else
          begin
            identifier_not_found(orgpattern);
            srsym:=generrorsym;
            srsymtable:=nil;
          end;
        s:=orgpattern;
        consume(t);
        result:=assigned(srsym);
      end;


    function TParserBase.try_consume_unitsym(var srsym:tsym;var srsymtable:TSymtable;var tokentoconsume : ttoken):boolean;
      begin
        result:=false;
        tokentoconsume:=_ID;
        if assigned(srsym) and
           (srsym.typ=unitsym) then
          begin
            if not(srsym.owner.symtabletype in [staticsymtable,globalsymtable]) then
              internalerror(200501154);
            { only allow unit.symbol access if the name was
              found in the current module }
            if srsym.owner.iscurrentunit then
              begin
                consume(_ID);
                consume(_POINT);
                case token of
                  _ID:
                     searchsym_in_module(tunitsym(srsym).module,pattern,srsym,srsymtable);
                  _STRING:
                    begin
                      { system.string? }
                      if tmodule(tunitsym(srsym).module).globalsymtable=systemunit then
                        begin
                          if cs_ansistrings in current_settings.localswitches then
                            searchsym_in_module(tunitsym(srsym).module,'ANSISTRING',srsym,srsymtable)
                          else
                            searchsym_in_module(tunitsym(srsym).module,'SHORTSTRING',srsym,srsymtable);
                          tokentoconsume:=_STRING;
                        end;
                    end
                  end;
              end
            else
              begin
                srsym:=nil;
                srsymtable:=nil;
              end;
            result:=true;
          end;
      end;


    function TParserBase.try_consume_hintdirective(var symopt:tsymoptions; var deprecatedmsg:pshortstring):boolean;
      var
        last_is_deprecated:boolean;
      begin
        try_consume_hintdirective:=false;
        if not(m_hintdirective in current_settings.modeswitches) then
         exit;
        repeat
          last_is_deprecated:=false;
          case idtoken of
            _LIBRARY :
              begin
                include(symopt,sp_hint_library);
                try_consume_hintdirective:=true;
              end;
            _DEPRECATED :
              begin
                include(symopt,sp_hint_deprecated);
                try_consume_hintdirective:=true;
                last_is_deprecated:=true;
              end;
            _EXPERIMENTAL :
              begin
                include(symopt,sp_hint_experimental);
                try_consume_hintdirective:=true;
              end;
            _PLATFORM :
              begin
                include(symopt,sp_hint_platform);
                try_consume_hintdirective:=true;
              end;
            _UNIMPLEMENTED :
              begin
                include(symopt,sp_hint_unimplemented);
                try_consume_hintdirective:=true;
              end;
            else
              break;
          end;
          consume(Token);
          { handle deprecated message }
          if ((token=_CSTRING) or (token=_CCHAR)) and last_is_deprecated then
            begin
              if deprecatedmsg<>nil then
                internalerror(200910181);
              if token=_CSTRING then
                deprecatedmsg:=stringdup(cstringpattern)
              else
                deprecatedmsg:=stringdup(pattern);
              consume(token);
              include(symopt,sp_has_deprecated_msg);
            end;
        until false;
      end;
{$ELSE}

{ TParserBase }

procedure TParserBase.identifier_not_found(const s: string);
begin
  current_scanner.identifier_not_found(s);
end;

procedure TParserBase.consume(i: ttoken);
begin
  current_scanner.consume(i);
end;

function TParserBase.try_to_consume(i: Ttoken): boolean;
begin
  Result := current_scanner.try_to_consume(i);
end;

procedure TParserBase.consume_all_until(atoken: ttoken);
begin
  current_scanner.consume_all_until(atoken);
end;

procedure TParserBase.consume_emptystats;
begin
  current_scanner.consume_emptystats;
end;

function TParserBase.consume_sym(var srsym: tsym; var srsymtable: TSymtable
  ): boolean;
begin
  Result :=  current_scanner.consume_sym(srsym,srsymtable);
end;

function TParserBase.consume_sym_orgid(var srsym: tsym;
  var srsymtable: TSymtable; var s: string): boolean;
begin
  Result := current_scanner.consume_sym_orgid(srsym, srsymtable, s);
end;

function TParserBase.try_consume_unitsym(var srsym: tsym;
  var srsymtable: TSymtable; var tokentoconsume: ttoken): boolean;
begin
  Result :=   current_scanner.try_consume_unitsym(srsym, srsymtable, tokentoconsume);
end;

function TParserBase.try_consume_hintdirective(var symopt: tsymoptions;
  var deprecatedmsg: pshortstring): boolean;
begin
  Result := current_scanner.try_consume_hintdirective(symopt, deprecatedmsg);
end;

{$ENDIF}
{$ELSE}
{$ENDIF}

end.
