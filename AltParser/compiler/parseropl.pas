{
    Copyright (c) 1998-2010 by Florian Klaempfl and Dr. Diettrich

    This unit implements the parsing of modules (unit,program,library,package).
    Handling of ppufiles and other semantics were moved somewhere else
    (SModules, SSub, SStatmnt...)
}
unit parserOPL;

{$i fpcdefs.inc}

interface

uses
  pbase,node,symdef,symconst;

type
{ In order to support multiple parsers, some general procedures are virtualized.
  The original procedures (statement,expr...) have been renamed and replaced
  by forwarders to virtual TParser methods.
}
  TParserOPL = class(TParser)
  protected
    function  ParseBlock(_isLibrary: boolean): tnode; override;
    procedure read_declarations(is_library : boolean); override;
    procedure read_interface_declarations; override;
    procedure generate_specialization_procs; override;
    function  statement: tnode; override;
    { reads a whole expression }
    function  expr(dotypecheck : boolean) : tnode; override;
    { reads an expression without assignments and .. }
    function  comp_expr(accept_equal : boolean):tnode; override;
    procedure Parse_Parameter_Dec(_pd:tabstractprocdef); override;
    function  Parse_Proc_Dec(isclassmethod:boolean; aclass:tobjectdef):tprocdef; override;
    function  parse_proc_head(aclass:tobjectdef;potype:tproctypeoption;var pd:tprocdef):boolean; override;
  public
    procedure Compile; override;
  end;

implementation

uses
  globals,globtype,cfileutl,
  fmodule,scanner,tokens,
  SModules,PStatmntOPL,
  pmodules,pexpr,psub,psubOPL,
  PDecSubOPL,
  finput,verbose,
  symbase;

{ References to external parsing procedures:
  ProcUnit
  -> pmodules.try_consume_hintdirective
    [clean]
  -> psub.read_interface_declarations
    [virtualized]
  -> psub.init_procinfo.parse_body -> psub.block(=psubOPL.ParseBlock)
    [virtualized]
  ProcPackage
  --
  ProcProgram
    [-> parse_body]
  LoadUnits
  --
}

{***************************************************************
                    From pmodules
***************************************************************}

procedure LoadUnits;
var
   s,sorg  : TIDString;
   fn      : string;
begin //LoadUnits
{If you use units, you likely need unit initializations.}
   current_module.micro_exe_allowed:=false;

   consume(_USES);
   repeat
     s:=pattern;
     sorg:=orgpattern;
     consume(_ID);
   { support "<unit> in '<file>'" construct, but not for tp7 }
     if not(m_tp7 in current_settings.modeswitches)
     and try_to_consume(_OP_IN) then
       fn:=FixFileName(get_stringconst)
     else
       fn:='';
     SUsesAdd(s,sorg,fn);
   until not try_to_consume(_COMMA);
   consume(_SEMICOLON);

   SUsesDone(); //used units are either compiled, or ppu files have been found
end;

procedure ProcUnit;
var
  sm: TSemModule;
begin //ProcUnit
  sm.SModuleInitUnit;
  consume(_UNIT);
  if token=_ID then //else error on consume(_ID)
    sm.SUnitName;
  consume(_ID);
{ parse hint directives }
  try_consume_hintdirective(current_module.moduleoptions, current_module.deprecatedmsg);
  consume(_SEMICOLON);
//enter interface section
  consume(_INTERFACE);
  sm.SUnitInterface;
  if not(cs_compilesystem in current_settings.moduleswitches)
  and (token=_USES) then begin
  { insert qualifier for the system unit (allows system.writeln) (where?) }
    LoadUnits; //parse USES clause
  { has it been compiled at a higher level ?}
    if current_module.state=ms_compiled then
      exit; //all used units are available (interface uses only!?)
  end;
{ ... parse the declarations }
  sm.SUnitIntfInit;
  Message1(parser_u_parsing_interface,current_module.realmodulename^);
  begin //put all interface declarations into the module's global STB
    symtablestack.push(current_module.globalsymtable);
    read_interface_declarations; //<--------------------- parse!
    symtablestack.pop(current_module.globalsymtable);
  end;
  if sm.SUnitIntfDone((m_mac in current_settings.modeswitches)
  and try_to_consume(_END)) then
    exit; //no implementation section present! (could consume(_POINT))
//enter implementation section
  if not current_module.interface_only then begin
    consume(_IMPLEMENTATION);
    Message1(unit_u_loading_implementation_units,current_module.modulename^);
  { Read the implementation units }
    //inlined parse_implementation_uses;
    if token=_USES then
      LoadUnits; //parse USES clause
  end;
  if sm.SUnitImplInit then
    exit; //unit doesn't deserve recompilation
//parse the implementation body
  if not current_module.interface_only then begin
    sm.SUnitBodyInit;
    sm.init_procinfo.parse_body;
  { save file pos for debuginfo }
    current_module.mainfilepos:=sm.init_procinfo.entrypos;
  end;
  sm.SUnitBodyDone;
{ finalize? }
  if sm.SUnitFinalInit((token=_FINALIZATION) and not current_module.interface_only) then
    sm.finalize_procinfo.parse_body;
  sm.SUnitFinalDone;
{ the last char should always be a point }
  consume(_POINT);
  if sm.SUnitDone then
    exit; //without message?
  Message1(unit_u_finished_compiling,current_module.modulename^); //move into SUnitDone?
end;

procedure ProcPackage;
var
  sm: TSemModule;
begin //ProcPackage
  sm.SModuleInitPackage;
  consume(_ID);  //PACKAGE
  sm.SPackageName;
  consume(_ID);
  consume(_SEMICOLON);

  sm.SPackageInterface;
{Load the units/packages used by the package we compile.}
  if token=_REQUIRES then
     begin
      //todo: this clause will produce errors, if ever entered
     end;
{Load the units that make up the package }
  if try_to_consume(_CONTAINS) then begin
    consume(_ID);
    repeat
      if token=_ID then
        AddUnit(pattern);
      consume(_ID);
    until not try_to_consume(_COMMA);
    consume(_SEMICOLON);
  end;
  sm.SPackageImplInit;
{ consume the last point }
  consume(_END);
  consume(_POINT);
  sm.SPackageDone;
end;

procedure ProcProgram(islibrary : boolean);
var
  sm: TSemModule;
begin //ProcProgram
  sm.SModuleInitProgLib(isLibrary);
  if islibrary then begin
    consume(_LIBRARY); //may fail, intentionally
    if token=_ID then
      sm.SLibName;
    consume(_ID);
    consume(_SEMICOLON);
  end else if try_to_consume(_PROGRAM) then begin
  //PROGRAM header
    if token=_ID then
      sm.SProgName;
    consume(_ID);
    if token=_LKLAMMER then begin
      consume(_LKLAMMER);
      repeat
        consume(_ID);
      until not try_to_consume(_COMMA);
      consume(_RKLAMMER);
    end;
    consume(_SEMICOLON);
  end else //headerless program
    sm.SProgNameNone;
//enter implementation body
  sm.SProgLibImplInit;
  if token=_USES then
    LoadUnits; {Load the units used by the program we compile.}
  sm.SProgLibBodyInit;
  sm.main_procinfo.parse_body; //all declarations and main procedure (BEGIN..END.)
{ save file pos for debuginfo }
  current_module.mainfilepos:=sm.main_procinfo.entrypos;
  sm.SProgLibBodyDone;
{ finalize? }
  if token=_FINALIZATION then begin
    sm.SProgLibFinalInit(True);
    sm.finalize_procinfo.parse_body;
  end else if sm.force_init_final then
    sm.SProgLibFinalInit(False);
  //else no finalization procedure at all
  sm.SPrgLibFinalDone;
{ consume the last point }
  consume(_POINT);
  sm.SPrgLibDone;
end;


{ TParserOPL }

procedure TParserOPL.Compile;
begin
WriteLn('*** using alternate parser ***');
{ read the first token }
  current_scanner.readtoken(false);

  if (token=_UNIT) or (compile_level>main_program_level) then begin
  //non main-level modules can be nothing but units
     current_module.is_unit:=true;
     ProcUnit;
  end else if (token=_ID) and (idtoken=_PACKAGE) then begin
    current_module.IsPackage:=true;
    ProcPackage;
  end else //assume program or library
    ProcProgram(token=_LIBRARY);
end;

function TParserOPL.ParseBlock(_isLibrary: boolean): tnode;
begin
  Result := psubOPL.ParseBlock(_isLibrary);
end;

procedure TParserOPL.read_declarations(is_library: boolean);
begin
  psubOPL.ReadDeclarations(is_library);
end;

procedure TParserOPL.read_interface_declarations;
begin
  psubOPL.ReadInterfaceDeclarations;
end;

procedure TParserOPL.generate_specialization_procs;
begin
  psubOPL._generate_specialization_procs;
end;

function TParserOPL.comp_expr(accept_equal: boolean): tnode;
begin
  Result:=pexpr.comp_expr(accept_equal); //unless implemented differently
end;

function TParserOPL.expr(dotypecheck: boolean): tnode;
begin
  Result:=pexpr.expr(dotypecheck); //unless implemented differently
end;

function TParserOPL.statement: tnode;
begin
  Result:=PStatmntOPL.statementOPL;
end;

procedure TParserOPL.Parse_Parameter_Dec(_pd: tabstractprocdef);
begin
  PDecSubOPL.Parse_Parameter_Dec(_pd);
end;

function TParserOPL.Parse_Proc_Dec(isclassmethod: boolean; aclass: tobjectdef
  ): tprocdef;
begin
  Result:=PDecSubOPL.Parse_Proc_Dec(isclassmethod, aclass);
end;

function TParserOPL.parse_proc_head(aclass: tobjectdef;
  potype: tproctypeoption; var pd: tprocdef): boolean;
begin
  Result:=PDecSubOPL._parse_proc_head(aclass, potype, pd);
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

