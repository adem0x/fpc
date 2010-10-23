{
    Copyright (c) 1998-2002 by Florian Klaempfl and Dr. Diettrich

    Implements the statement semantics.
    Code inherited from pstatmnt.pas.
}
unit SStatmnt;

{$i fpcdefs.inc}

interface

uses
  globtype,
  node, symbase, symtype, symsym;

type
{ from try_statement() }
  TSemTry = object
  protected
    oldcurrent_exceptblock: integer;
    p_try_block,p_finally_block,first,last,
    p_specific,hp : tnode;
    ot : tDef;
    sym : tlocalvarsym;
    old_block_type : tblock_type;
    exceptSymtable : TSymtable;
    objname,objrealname : TIDString;
  public
    p_default: tnode;
    srsym : tsym;
    srsymtable : TSymtable;
  public
    constructor TryInit;
    procedure TryStmt;
    procedure TryStmtsDone;
    function  TryFinallyInit: tnode;
    procedure TryExceptInit;
    procedure OnExceptID;
    procedure OnExceptBody;
    procedure OnExceptDo;
    procedure OnExceptType;
    function  TryExceptDone: tnode;
    procedure TryDone;
  end;

  TStatementParser = function(): tnode;

  TSemStmtBlock = object
  protected
    first,last : tnode;
    filepos : tfileposinfo;
  public
    constructor SBInit;
    procedure ParseStmt(ps: TStatementParser);
    function  SBDone: tnode;
  end;

implementation

uses
  globals,verbose,
  symdef,symtable,symconst,
  procinfo,
  scanner,tokens, //should disappear
  pbase,pstatmnt,
  nbas,nflw;

{ TSemTry }

constructor TSemTry.TryInit;
begin
  include(current_procinfo.flags,pi_uses_exceptions);

  p_default:=nil;
  p_specific:=nil;

  first:=nil;

  inc(exceptblockcounter);
  oldcurrent_exceptblock := current_exceptblock;
  current_exceptblock := exceptblockcounter;
end;

procedure TSemTry.TryStmt;
begin
  if first=nil then begin
    last:=cstatementnode.create(statement(),nil);
    first:=last;
  end else begin
    tstatementnode(last).right:=cstatementnode.create(statement(),nil);
    last:=tstatementnode(last).right;
  end;
end;

procedure TSemTry.TryStmtsDone;
begin
  p_try_block:=cblocknode.create(first);
end;

function TSemTry.TryFinallyInit: tnode;
begin
  inc(exceptblockcounter);
  current_exceptblock := exceptblockcounter;
  p_finally_block:=statements_til_end;
  result:=ctryfinallynode.create(p_try_block,p_finally_block);
end;

procedure TSemTry.TryExceptInit;
begin
  old_block_type:=block_type;
  block_type:=bt_except;
  inc(exceptblockcounter);
  current_exceptblock := exceptblockcounter;
  ot:=generrordef;
  p_specific:=nil;
end;

procedure TSemTry.OnExceptID;
begin
  objname:=pattern;
  objrealname:=orgpattern;
  { can't use consume_sym here, because we need already
    to check for the colon }
  searchsym(objname,srsym,srsymtable);
end;

procedure TSemTry.OnExceptBody;
begin
  if (srsym.typ=typesym) and is_class(ttypesym(srsym).typedef) then begin
    ot:=ttypesym(srsym).typedef;
    sym:=tlocalvarsym.create(objrealname,vs_value,ot,[]);
  end else begin
    sym:=tlocalvarsym.create(objrealname,vs_value,generrordef,[]);
    if (srsym.typ=typesym) then
      Message1(type_e_class_type_expected,ttypesym(srsym).typedef.typename)
    else
      Message1(type_e_class_type_expected,ot.typename);
  end;
  exceptSymtable:=tstt_excepTSymtable.create;
  exceptSymtable.insert(sym);
  symtablestack.push(exceptSymtable);
end;

procedure TSemTry.OnExceptDo;
begin
  hp:=connode.create(nil,statement);
  if ot.typ=errordef then begin
      hp.free;
      hp:=cerrornode.create;
  end;
  if p_specific=nil then begin
      last:=hp;
      p_specific:=last;
  end else begin
      tonnode(last).left:=hp;
      last:=tonnode(last).left;
  end;
  { set the informations }
  { only if the creation of the onnode was succesful, it's possible }
  { that last and hp are errornodes (JM)                            }
  if last.nodetype = onn then begin
     tonnode(last).excepttype:=tobjectdef(ot);
     tonnode(last).exceptSymtable:=exceptSymtable;
  end;
  { remove exception symtable }
  if assigned(exceptSymtable) then begin
     symtablestack.pop(exceptSymtable);
     if last.nodetype <> onn then
       exceptSymtable.free;
  end;
end;

function TSemTry.TryExceptDone: tnode;
begin
  block_type:=old_block_type;
  Result:=ctryexceptnode.create(p_try_block,p_specific,p_default);
end;

procedure TSemTry.TryDone;
begin
  current_exceptblock := oldcurrent_exceptblock;
end;

procedure TSemTry.OnExceptType;
begin
(* we allow for consume here - should be moved into general QualID.
*)
  { check if type is valid, must be done here because
   with "e: Exception" the e is not necessary }
  if srsym=nil then begin
    identifier_not_found(objrealname);
    srsym:=generrorsym;
  end;
  { support unit.identifier }
  if srsym.typ=unitsym then begin
    consume(_POINT);
    searchsym_in_module(tunitsym(srsym).module,pattern,srsym,srsymtable);
    if srsym=nil then
     begin
       identifier_not_found(orgpattern);
       srsym:=generrorsym;
     end;
    consume(_ID);
  end;
  { check if type is valid, must be done here because
   with "e: Exception" the e is not necessary }
  if (srsym.typ=typesym) and is_class(ttypesym(srsym).typedef) then
    ot:=ttypesym(srsym).typedef
  else begin
    ot:=generrordef;
    if (srsym.typ=typesym) then
      Message1(type_e_class_type_expected,ttypesym(srsym).typedef.typename)
    else
      Message1(type_e_class_type_expected,ot.typename);
  end;
  exceptSymtable:=nil;
end;

{ TSemStmtBlock }

constructor TSemStmtBlock.SBInit;
begin
  first:=nil;
  filepos:=current_tokenpos;
end;

procedure TSemStmtBlock.ParseStmt(ps: TStatementParser);
var
  n: tnode;
begin
  n:=cstatementnode.create(ps(),nil);
  if first=nil then
    first:=n
  else
    tstatementnode(last).right:=n;
  last := n;
end;

function TSemStmtBlock.SBDone: tnode;
begin
  Result:=cblocknode.create(first);
  Result.fileinfo:=filepos;
end;

end.

