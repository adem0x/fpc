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
       tokens,globtype,
       symconst,symbase,symtype,symdef,symsym,symtable,
       scanner
       ;

    const
       { tokens that end a block or statement. And don't require
         a ; on the statement before }
       endtokens = [_SEMICOLON,_END,_ELSE,_UNTIL,_EXCEPT,_FINALLY];

    type

      { TParser }

      TParser = class(tscannerfile)
      public
       { true, if we are after an assignement }
       afterassignment : boolean;

       { true, if we are parsing arguments }
       in_args : boolean;

       { true, if we are parsing arguments allowing named parameters }
       named_args_allowed : boolean;

       { true, if we got an @ to get the address }
       got_addrn  : boolean;

       { special for handling procedure vars }
       getprocvardef : tprocvardef;

       { true, if we are parsing stuff which allows array constructors }
       allow_array_constructor: boolean;

       { true, if only routine headers should be parsed }
       parse_only : boolean;

       { true, if we found a name for a named arg }
       found_arg_name : boolean;

       { true, if we are parsing generic declaration }
       parse_generic : boolean;

    protected //disallow arbitrary creation
       constructor Create(const fn:string); override;
    public
       destructor Destroy;override;

       //Create parser for the given file
       class function Compile(const fn: string): TParser;
       //compile the file
       procedure Execute; virtual;
    end;

function GetParser: TParser; inline; //does "inline" work with properties?
property current_parser: TParser read GetParser;


implementation

    uses
       globals,htypechk,
       systems,verbose,fmodule;

function GetParser: TParser;
begin
  Result := TParser(current_module.scanner);
end;

{ TParser }

constructor TParser.Create(const fn: string);
begin
  inherited Create(fn);
end;

destructor TParser.Destroy;
begin
  inherited Destroy;
end;

class function TParser.Compile(const fn: string): TParser;
begin
(* Create the parser for fn.
  Create default parser, for now
*)
  Result := TParser.Create(fn);
end;

procedure TParser.Execute;
begin
//to come, from body of old compile()
  //compile/Parse
end;

end.
