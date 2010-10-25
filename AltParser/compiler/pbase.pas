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
unit pbase;

{$i fpcdefs.inc}

interface

    uses
       cutils,cclasses,
       tokens,globtype,scanner,node,
       symconst,symbase,symtype,symdef,symsym,symtable
       ;

    const
       { tokens that end a block or statement. And don't require
         a ; on the statement before }
       endtokens = [_SEMICOLON,_END,_ELSE,_UNTIL,_EXCEPT,_FINALLY];

       { true, if we are after an assignement }
       afterassignment : boolean = false;

       { true, if we are parsing arguments }
       in_args : boolean = false;

       { true, if we are parsing arguments allowing named parameters }
       named_args_allowed : boolean = false;

       { true, if we got an @ to get the address }
       got_addrn  : boolean = false;

       { special for handling procedure vars }
       getprocvardef : tprocvardef = nil;

    var
       { for operators }
       optoken : ttoken;

       { true, if only routine headers should be parsed }
       parse_only : boolean;

       { true, if we found a name for a named arg }
       found_arg_name : boolean;

       { true, if we are parsing generic declaration }
       parse_generic : boolean;

    type
      TParser = class(tscannerfile)
      protected
        constructor CreateFor(const filename: string); virtual;
        function  ParseBlock(_isLibrary: boolean): tnode; virtual;
        procedure read_declarations(is_library : boolean); virtual;
        procedure read_interface_declarations; virtual;
        procedure generate_specialization_procs; virtual;
        function  statement: tnode; virtual;
        function  statement_block(starttoken : ttoken) : tnode; virtual;
        { reads a whole expression }
        function  expr(dotypecheck : boolean) : tnode; virtual;
        { reads an expression without assignements and .. }
        function  comp_expr(accept_equal : boolean):tnode; virtual;
        procedure Parse_Parameter_Dec(_pd:tabstractprocdef); virtual;
        function  Parse_Proc_Dec(isclassmethod:boolean; aclass:tobjectdef):tprocdef; virtual;
        function  parse_proc_head(aclass:tobjectdef;potype:tproctypeoption;var pd:tprocdef):boolean; virtual;
      public
        procedure Compile; virtual;
      end;

      TParserClass = class of TParser;

      PParserListItem = ^TParserListItem;
      TParserListItem = record
        ext: string[7];         { supported file extension }
        cls, alt: TParserClass; { primary and alternative parser class }
        next: PParserListItem;
      end;

    { Create parser for the given file, by file extension }
    function  ParserFor(const filename: string): TParser;

    { Register an parser with a filetype }
    procedure RegisterParser(pcl: PParserListItem);

    { Get the current parser }
    function current_parser: TParser; inline;

    procedure identifier_not_found(const s:string);

{    function tokenstring(i : ttoken):string;}

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

    { parses a statement }
    function statement: tnode;
    function statement_block(starttoken : ttoken) : tnode;

    { reads a whole expression }
    function expr(dotypecheck : boolean) : tnode;

    { reads an expression without assignements and .. }
    function comp_expr(accept_equal : boolean):tnode;

    { just for an accurate position of the end of a procedure (PM) }
    var
       last_endtoken_filepos: tfileposinfo;


    function block(is_Library: boolean): tnode;

    { reads the declaration blocks }
    procedure read_declarations(is_library : boolean);

    { reads declarations in the interface part of a unit }
    procedure read_interface_declarations;

    procedure generate_specialization_procs;

    procedure Parse_Parameter_Dec(_pd:tabstractprocdef);
    function  Parse_Proc_Dec(isclassmethod:boolean; aclass:tobjectdef):tprocdef;
    function  parse_proc_head(aclass:tobjectdef;potype:tproctypeoption;var pd:tprocdef):boolean;

implementation

    uses
       sysutils,
       globals,htypechk,systems,verbose,
       pmodules,psub,pstatmnt,pexpr,pdecsub,
       fmodule;

function block(is_Library: boolean): tnode;
begin
  Result := current_parser.ParseBlock(is_Library);
end;

{ reads the declaration blocks }
procedure read_declarations(is_library : boolean);
begin
  current_parser.read_declarations(is_library);
end;

{ reads declarations in the interface part of a unit }
procedure read_interface_declarations;
begin
  current_parser.read_interface_declarations;
end;

procedure generate_specialization_procs;
begin
  current_parser.generate_specialization_procs;
end;

{****************************************************************************
                               Token Parsing
****************************************************************************}

     procedure identifier_not_found(const s:string);
       begin
         Message1(sym_e_id_not_found,s);
         { show a fatal that you need -S2 or -Sd, but only
           if we just parsed the a token that has m_class }
         if not(m_class in current_settings.modeswitches) and
            (Upper(s)=pattern) and
            (tokeninfo^[idtoken].keyword=m_class) then
           Message(parser_f_need_objfpc_or_delphi_mode);
       end;


    { consumes token i, write error if token is different }
    procedure consume(i : ttoken);
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
            current_scanner.readtoken(true);
          end;
      end;


    function try_to_consume(i:Ttoken):boolean;
      begin
        try_to_consume:=false;
        if (token=i) or (idtoken=i) then
         begin
           try_to_consume:=true;
           if token=_END then
            last_endtoken_filepos:=current_tokenpos;
           current_scanner.readtoken(true);
         end;
      end;


    procedure consume_all_until(atoken : ttoken);
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


    procedure consume_emptystats;
      begin
         repeat
         until not try_to_consume(_SEMICOLON);
      end;


    { check if a symbol contains the hint directive, and if so gives out a hint
      if required.

      If this code is changed, it's likly that consume_sym_orgid and factor_read_id
      must be changed as well (FK)
    }
    function consume_sym(var srsym:tsym;var srsymtable:TSymtable):boolean;
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
    function consume_sym_orgid(var srsym:tsym;var srsymtable:TSymtable;var s : string):boolean;
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


    function try_consume_unitsym(var srsym:tsym;var srsymtable:TSymtable;var tokentoconsume : ttoken):boolean;
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


    function try_consume_hintdirective(var symopt:tsymoptions; var deprecatedmsg:pshortstring):boolean;
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


{****************************************************************************
                parser registration and management
****************************************************************************}

      var
        FileTypes: PParserListItem;

      const
        OPLpas: TParserListItem = (
          ext: '.pas'; cls: TParser;
          alt:nil; next:nil;
        );
        OPLpp: TParserListItem = (
          ext: '.pp'; cls: TParser;
          alt:nil; next:nil;
        );
        OPLlpr: TParserListItem = (
          ext: '.lpr'; cls: TParser;
          alt:nil; next:nil;
        );

      function current_parser: TParser;
      begin
        TObject(Result) := current_scanner;
      end;

      function ParserForExtension(const ext: string): PParserListItem;
      begin
        Result := FileTypes;
        while (Result <> nil) and (Result^.ext <> ext) do
          Result := Result^.next;
      end;

      procedure InitParsers;
      begin
        if FileTypes = nil then begin
          { register the default parser first, prevent recursion }
          FileTypes := @OPLpas;
          RegisterParser(@OPLpp);
          RegisterParser(@OPLlpr);
        end;
      end;

      procedure RegisterParser(pcl: PParserListItem);
      var
        p: PParserListItem;
      begin
        InitParsers;  //always register standard parser as first alternative
        p := ParserForExtension(pcl^.ext);
        if p = nil then begin
          pcl^.next := FileTypes;
          FileTypes := pcl;
        end else begin
        //already registered!?
          p^.alt := pcl^.cls;
        end;
      end;

      function  ParserFor(const filename: string): TParser;
      var
        ext: string;
        p: PParserListItem;
      begin
      (* check all registered parsers,
        create whichever can handle <filename>
      *)
        InitParsers;  //in case no parser was explicitly registered
        ext := lower(ExtractFileExt(filename));
        p := ParserForExtension(ext);
        if p = nil then begin
          //p := FileTypes; //fallback to default parser
          WriteLn('*** no parser for ', ext);
          Internalerror(20101025);
        end;
        if assigned(p^.alt) and ParaAltParser then
          Result := p^.alt.CreateFor(filename)
        else
          Result := p^.cls.CreateFor(filename);
      end;

      { TParser }

      constructor TParser.CreateFor(const filename: string);
      begin
        Create(filename);
      end;

      procedure TParser.Compile;
      begin
         { from parser.compile - default parser }

         { If the compile level > 1 we get a nice "unit expected" error
           message if we are trying to use a program as unit.}

         { read the first token }
         readtoken(false);

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
      end;

      function TParser.ParseBlock(_isLibrary: boolean): tnode;
      begin
        Result := psub._block(_isLibrary);
      end;

      procedure TParser.read_declarations(is_library: boolean);
      begin
        psub._read_declarations(is_library);
      end;

      procedure TParser.read_interface_declarations;
      begin
        psub._read_interface_declarations;
      end;

      procedure TParser.generate_specialization_procs;
      begin
        psub._generate_specialization_procs;
      end;

{***************** language specifics **********************}

      function TParser.statement: tnode;
      begin
        Result := pstatmnt._statement;
      end;

      function TParser.statement_block(starttoken: ttoken): tnode;
      begin
        Result := pstatmnt._statement_block(starttoken);
      end;

      function TParser.comp_expr(accept_equal: boolean): tnode;
      begin
        Result := pexpr.comp_expr(accept_equal);
      end;

      function TParser.expr(dotypecheck: boolean): tnode;
      begin
        Result := pexpr.expr(dotypecheck);
      end;

      procedure TParser.Parse_Parameter_Dec(_pd: tabstractprocdef);
      begin
        pdecsub._parse_parameter_dec(_pd);
      end;

      function TParser.Parse_Proc_Dec(isclassmethod: boolean;
              aclass: tobjectdef): tprocdef;
      begin
        Result := pdecsub._parse_proc_dec(isclassmethod, aclass);
      end;

      function TParser.parse_proc_head(aclass: tobjectdef;
        potype: tproctypeoption; var pd: tprocdef): boolean;
      begin
        Result := pdecsub._parse_proc_head(aclass,potype,pd);
      end;

{********************* forwarders ********************}

    { parses a statement }
    function statement: tnode;
    begin
      Result := current_parser.statement;
    end;

    function statement_block(starttoken : ttoken) : tnode;
    begin
      Result := current_parser.statement_block(starttoken);
    end;

    { reads a whole expression }
    function expr(dotypecheck : boolean) : tnode;
    begin
      Result := current_parser.expr(dotypecheck);
    end;

    { reads an expression without assignements and .. }
    function comp_expr(accept_equal : boolean):tnode;
    begin
      Result := current_parser.comp_expr(accept_equal);
    end;

    procedure Parse_Parameter_Dec(_pd:tabstractprocdef);
    begin
      current_parser.Parse_Parameter_Dec(_pd);
    end;

    function  Parse_Proc_Dec(isclassmethod:boolean; aclass:tobjectdef):tprocdef;
    begin
      Result := current_parser.Parse_Proc_Dec(isclassmethod, aclass);
    end;

    function  parse_proc_head(aclass:tobjectdef;potype:tproctypeoption;var pd:tprocdef):boolean;
    begin
      Result := current_parser.parse_proc_head(aclass,potype,pd);
    end;

end.
