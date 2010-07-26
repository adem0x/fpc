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

  This singleton (unit) has been converted into a class,
  based on tscannerfile (if scanner_based)
*)

unit pbase;

{$i fpcdefs.inc}
{$DEFINE consume_in_parser} //scanner_based

interface

    uses
       cutils,cclasses,
       tokens,globtype,globals,
       symconst,symbase,symtype,symdef,symsym,symtable
      ,scanner
       ;

    const
      scanner_based = True;

    const
       { tokens that end a block or statement. And don't require
         a ; on the statement before }
       endtokens = [_SEMICOLON,_END,_ELSE,_UNTIL,_EXCEPT,_FINALLY];

  type
  {.$IFDEF consume_in_parser}
  {$IF scanner_based}
    TParserBase = class(tscannerfile)
  {$ELSE}
    TParserBase = class //(tscannerfile)
  {$ENDIF}
    public  //really?
    {$IFDEF NoGlobals}
     current_scanner : tscannerfile;  { current scanner in use }
     //current_module: tmodule; //circular reference!
     current_settings: tsettings;
    {$ELSE}
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

{$IF scanner_based}
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
    class procedure preprocess(const filename:string);
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
      (* Init all (global) parser-related resources.
      *)
        {$IFDEF NoGlobals}
         InitScanner;
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
        //in InitScanner and constructor
       {$ENDIF}
       {$ENDIF NoGlobals}

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
      (* Release all (global) parser-related resources.
      *)
        {$IFDEF NoGlobals}
        {$ELSE}
         { Reset current compiling info, so destroy routines can't
           reference the data that might already be destroyed }
         set_current_module(nil);
         current_module:=nil;
         current_procinfo:=nil;
         current_asmdata:=nil;
         current_objectdef:=nil;
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

       {$IF scanner_based}
         { close scanner }
         DoneScanner;
       {$ELSE}
         { if there was an error in the scanner, the scanner is
           still assinged }
         if assigned(current_scanner) then
          begin
            current_scanner.free;
            current_scanner:=nil;
          end;
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

       {$IFDEF NoGlobals}
       {$ELSE}
         current_scanner := self;
       {$ENDIF}
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

end.
