{
    Copyright (c) 1998-2010 by Florian Klaempfl and Dr. Diettrich

    Implements the Component Pascal language (not strictly)
}
unit PComponentPascal;

{$i fpcdefs.inc}

{$DEFINE StdExprs} //use OPL expressions and literals?

interface

uses
  pbase,node,symdef,symconst;

type
  TComponentPascal = class(TParser)
  protected //in grammar order
    //procedure Module;
    procedure ImportList;
    procedure DeclSeq;
    procedure ConstDecl;
    procedure TypeDecl;
    procedure VarDecl;
    procedure ProcDecl;
      //procedure ForwardDecl; - part of ProcDecl
      //procedure Receiver;
      procedure MethAttributes;
    procedure FormalPars;
    procedure FPSection;
    procedure Type_;
    procedure FieldList;
    procedure StatementSeq;
    function  Statement: tnode; override;
    //procedure Case_;
    //procedure CaseLabels;
    procedure Guard;
    procedure ConstExpr;
    function  Expr(dotypecheck: boolean = false): tnode; override;
  {$IFDEF StdExprs}
    //using expr.pas
  {$ELSE}
    procedure SimpleExpr;
    procedure Term;
    procedure Factor;
    procedure Set_;
    procedure Element;
    //procedure Relation;
    //procedure AddOp;
    //procedure MulOp;
  {$ENDIF}
    procedure Designator;
    procedure ExprList;
    procedure IdentList;
    procedure QualIdent;
    procedure IdentDef; //function?
    procedure Ident;  //function?
    function  UnitID: boolean;
  public
    procedure Compile; override;
  end;

function  TokenIs(const str: string): boolean;

implementation

uses
  globals,
  SModules,fmodule,
{$IFDEF StdExprs}
  pexpr,
{$ELSE}
{$ENDIF}
  scanner, tokens;

//some token substitutions, for now
const
  //_MODULE = _UNIT;
  //_IMPORT = _USES;
  //_CLOSE  = _FINALIZATION;
  _LBRACE = _LECKKLAMMER;
  _RBRACE = _RECKKLAMMER;

  Relation = [_EQUAL,_UNEQUAL,_LT,_LTE,_GT,_GTE,_IN,_IS];
            //"=" | "#" | "<" | "<=" | ">" | ">=" | IN | IS.
  AddOp = [_PLUS,_MINUS,_OR]; // "+" | "-" | OR.
  MulOp = [_STAR,_SLASH,_DIV,_MOD,_AMPERSAND];  // " * " | "/" | DIV | MOD | "&".

const
  CPcpas: TParserListItem = (
    ext: '.cpas'; cls: TComponentPascal;
    alt:nil; next:nil;
  );

function TokenIs(const str: string): boolean;
begin
  Result := (token=_ID) and (pattern =str);
end;

{ TComponentPascal }

procedure TComponentPascal.Compile;
(*
  Module = MODULE ident ";" [ImportList] DeclarationSequence
  [BEGIN StatementSequence]
  [CLOSE StatementSequence] END ident ".".
*)
var
  sm: TSemModule;
begin
{ read the first token }
  current_scanner.readtoken(false);
//Module
  if TokenIs('MODULE') or (compile_level>main_program_level) then begin
  //non main-level modules can be nothing but units
    current_module.is_unit:=true;
    sm.SModuleInitUnit;  //is this applicable???
  end else begin //assume program
    sm.SModuleInitProgLib(False);
  end;
  if (token=_PROGRAM) or TokenIs('MODULE') then
    consume(token);
  sm.SProgName; //expect _ID
  consume(_ID);
  consume(_SEMICOLON);
//enter implementation body
  sm.SProgLibImplInit;
//imports/uses?
  if TokenIs('IMPORT') then begin
    consume(token);
    ImportList;
  end;
//body
  sm.SProgLibBodyInit;
  DeclSeq;
  if try_to_consume(_BEGIN) then
    StatementSeq;
{ save file pos for debuginfo }
  current_module.mainfilepos:=sm.main_procinfo.entrypos;
  sm.SProgLibBodyDone;
//finalization?
  if TokenIs('CLOSE') then begin
    consume(token);
    sm.SProgLibFinalInit(True);
    //sm.finalize_procinfo.parse_body;
    StatementSeq;
  end else
    sm.SProgLibFinalInit(False);
  sm.SPrgLibFinalDone;
  consume(_END);
  if token = _ID then begin //DoDi: made this ID optional
    consume(_ID); //must match the module name
  end;
  //sm.SProgLibBodyDone;
  consume(_POINT);
  sm.SPrgLibDone;
end;

procedure TComponentPascal.DeclSeq;
(* DeclSeq = { CONST {ConstDecl ";" } | TYPE {TypeDecl ";"} |
    VAR {VarDecl ";"}} {ProcDecl ";" | ForwardDecl ";"}.
  ProcDecl = PROCEDURE [Receiver] IdentDef [FormalPars] MethAttributes
    [";" DeclSeq [BEGIN StatementSeq] END ident].
  ForwardDecl = PROCEDURE " ^ " [Receiver] IdentDef [FormalPars] MethAttributes.
*)
  procedure ConstDecls;
  begin
    consume(_CONST);
    while token = _ID do begin
      ConstDecl;
      consume(_SEMICOLON);
    end;
  end;

  procedure TypeDecls;
  begin
    consume(_TYPE);
    while token = _ID do begin
      TypeDecl;
      consume(_SEMICOLON);
    end;
  end;

  procedure VarDecls;
  begin
    consume(_VAR);
    while token = _ID do begin
      VarDecl;
      consume(_SEMICOLON);
    end;
  end;

begin
  while token in [_CONST,_TYPE,_VAR,_PROCEDURE] do begin
    case token of
    _CONST: ConstDecls;
    _TYPE:  TypeDecls;
    _VAR:   VarDecls;
    _PROCEDURE: ProcDecl; // ProcOrForwardDecl;
    end;
  end;
end;

procedure TComponentPascal.ImportList;
(*
  ImportList = IMPORT] Import {"," Import} ";".
  Import = [ident ":="] ident.
*)
begin
  repeat  //while token = _ID do begin
    consume(_ID);
    if try_to_consume(_ASSIGNMENT) then begin
    //preceding ID is the alias name
    //ID is the real name
      consume(_ID);
    end else begin
    //ID is the real name
    end;
  until not try_to_consume(_COMMA);
  consume(_SEMICOLON);
end;

procedure TComponentPascal.ConstDecl;
(* ConstDecl = IdentDef "=" ConstExpr.
*)
begin
  IdentDef;
  consume(_EQUAL);
  ConstExpr;
end;

procedure TComponentPascal.TypeDecl;
(* TypeDecl = IdentDef "=" Type.
  IdentDef = ident [" * " | "-"].
*)
begin
  IdentDef;
  consume(_EQUAL);
  Type_;
end;

procedure TComponentPascal.VarDecl;
(* VarDecl = IdentList ":" Type.
*)
begin
  IdentList;
  consume(_COLON);
  Type_;
//allow for initializer???
end;

procedure TComponentPascal.StatementSeq;
(* StatementSeq = Statement {";" Statement}.
*)
begin
  repeat
    Statement;
  until not try_to_consume(_SEMICOLON);
end;

function TComponentPascal.Statement: tnode;
(* Statement =
[ Designator ":=" Expr
| Designator ["(" [ExprList] ")"]
| IF Expr THEN StatementSeq
  {ELSIF Expr THEN StatementSeq}
  [ELSE StatementSeq] END
| CASE Expr OF Case {"|" Case}
    [ELSE StatementSeq] END
| WHILE Expr DO StatementSeq END
| REPEAT StatementSeq UNTIL Expr
| FOR ident ":=" Expr TO Expr [BY ConstExpr]
  DO StatementSeq END
| LOOP StatementSeq END
| WITH [ Guard DO StatementSeq ]
  {"|" [ Guard DO StatementSeq ] }
  [ELSE StatementSeq] END
| EXIT
| RETURN [Expr]
].
*)
  procedure LoopStmt;
  (*  LOOP StatementSeq END
  *)
  begin
    consume(token); //_loop
    StatementSeq;
    consume(_END);
  end;

  procedure AssignOrCallStmt;
  begin //got ID
  //DoDi: until we have a _LOOP token...
    if pattern = 'LOOP' then begin
      LoopStmt;
      exit;
    end;
    Designator; //return what?
    if try_to_consume(_ASSIGNMENT) then begin
      Expr;
    end else begin
      if try_to_consume(_LKLAMMER) then begin
      //FormalPars;
        if token<>_RKLAMMER then
          ExprList;
        consume(_RKLAMMER);
      end;
      //Call...
    end;
  end;

  procedure CaseStmt;
  (* CASE Expr OF Case {"|" Case}
      [ELSE StatementSeq] END
    Case = [CaseLabels {"," CaseLabels} ":" StatementSeq].
    CaseLabels = ConstExpr [".." ConstExpr].
  *)
    procedure CaseLabels;
    (* CaseLabels = ConstExpr [".." ConstExpr].
    *)
    begin
      repeat
        ConstExpr;
      until not try_to_consume(_POINTPOINT);
    end;

    procedure Case_;
    (* Case = [CaseLabels {"," CaseLabels} ":" StatementSeq].
    *)
    begin
      repeat
        CaseLabels;
      until not try_to_consume(_COMMA);
      consume(_COLON);
      StatementSeq;
    end;

  begin
    consume(_CASE);
    Expr;
    consume(_OF);
    repeat
      Case_;
    until not try_to_consume(_PIPE);
    if try_to_consume(_ELSE) then
      StatementSeq;
    consume(_END);
  end;

  procedure IfStmt;
  (*  IF Expr THEN StatementSeq
  {ELSIF Expr THEN StatementSeq}
  [ELSE StatementSeq] END
  *)
  begin
    consume(_IF);
    Expr;
    consume(_THEN);
    StatementSeq;
    if (token=_ID) and (pattern='ELSEIF') then begin
      consume(token);
      Expr;
      consume(_THEN);
      StatementSeq;
    end;
    if try_to_consume(_ELSE) then begin
      StatementSeq;
    end;
    consume(_END);
  end;

  procedure WhileStmt;
  (* WHILE Expr DO StatementSeq END
  *)
  begin
    consume(_WHILE);
    Expr;
    consume(_DO);
    StatementSeq;
    consume(_END);
  end;

  procedure RepeatStmt;
  (* REPEAT StatementSeq UNTIL Expr
  *)
  begin
    consume(_REPEAT);
    StatementSeq;
    consume(_UNTIL);
    Expr;
  end;

  procedure ForStmt;
  (* FOR ident ":=" Expr TO Expr [BY ConstExpr]
      DO StatementSeq END
  *)
  begin
    consume(_FOR);
    consume(_ID);
    consume(_ASSIGNMENT);
    Expr;
    consume(_TO);
    Expr;
    if (token=_ID) and (pattern='BY') then begin
      consume(token);
      Expr;
    end;
    consume(_DO);
    StatementSeq;
    consume(_END);
  end;

  procedure WithStmt;
  (* WITH [ Guard DO StatementSeq ]
    {"|" [ Guard DO StatementSeq ] }
    [ELSE StatementSeq] END.
    Guard = Qualident ":" Qualident.
  *)
  begin
    consume(_WITH);
    repeat
      Guard;
    until not try_to_consume(_PIPE);
    if try_to_consume(_ELSE) then begin
      StatementSeq;
    end;
    consume(_END);
  end;

  procedure ExitStmt;
  begin
    consume(_EXIT);
  end;

  procedure ReturnStmt;
  (* RETURN [Expr]
  *)
  begin
    consume(_RETURN);
    if token <> _SEMICOLON then begin //what?
      Expr;
    end;
  end;

begin
  Result := nil;  //to come!
  case token of
  _ID:    AssignOrCallStmt;
  _IF:    IfStmt;
  _Case:  CaseStmt;
  _WHILE: WhileStmt;
  _REPEAT:  RepeatStmt;
  _FOR:   ForStmt;
  //_loop:  LoopStmt; //as _ID
  _WITH:  WithStmt;
  _EXIT:  ExitStmt;
  _RETURN:  ReturnStmt;
  end;
end;

procedure TComponentPascal.ConstExpr;
begin
  Expr;
end;

procedure TComponentPascal.Designator;
(* Designator = Qualident
{"." ident
| "[" ExprList "]"
| " ^ "
| "(" Qualident ")" --- type guard ???
| "(" [ExprList] ")"} --- ActualParameters ???
[ "$" ].  --- string from char[] ???
*)
begin
  QualIdent;
  while token in [_POINT,_LECKKLAMMER,_CARET,_LKLAMMER] do begin
    case token of
    _POINT: //member selector
      begin
        consume(_POINT);
        Ident;  //how?
      end;
    _LECKKLAMMER: //array selector
      begin
        consume(_LECKKLAMMER);
        ExprList;
        consume(_RECKKLAMMER);
      end;
    _CARET: //pointer dereference
      begin
        consume(_CARET);
      end;
    _LKLAMMER: //???
      begin
        consume(_LKLAMMER);
        if token=_ID then begin //type guard?
          QualIdent;
        end else begin //procedure call?
          ExprList;
        end;
      end;
    else
      break;
    end;
  end;
//unhandled: "$"
end;

function TComponentPascal.Expr(dotypecheck: boolean): tnode;
begin
{$IFDEF StdExprs}
  Result := pexpr.expr(dotypecheck);  //???
{$ELSE}
...
  SimpleExpr;
  if token in Relation then begin
    consume(token);
    SimpleExpr;
  end;
{$ENDIF}
end;

procedure TComponentPascal.ExprList;
(* ExprList = Expr {"," Expr}.
*)
begin
  repeat
    Expr;
  until not try_to_consume(_COMMA);
end;

{$IFDEF StdExprs}
{$ELSE}
procedure TComponentPascal.Element;
begin
  Expr;
  if try_to_consume(_POINTPOINT) then begin
    Expr;
  end;
end;

procedure TComponentPascal.Factor;
(* Factor = Designator
| number
| character
| string
| NIL
| Set
|"(" Expr ")"
| " ~ " Factor.
*)
begin
...
end;

procedure TComponentPascal.SimpleExpr;
begin
  if token in [_PLUS,_MINUS] then begin
    consume(token);
  end;
  Term;
  if token in AddOp then begin
    consume(token);
  end;
  Term;
end;

procedure TComponentPascal.Term;
(* Term = Factor {MulOp Factor}.
*)
begin
  Factor;
  if token in MulOp then begin
    consume(token);
    Factor;
  end;
end;

procedure TComponentPascal.Set_;
(* Set = "{" [Element {"," Element}] "}".
*)
begin
  consume(_LBRACE);
  while token <> _RBRACE do begin
    Element;
    if not try_to_consume(_COMMA) then
      break;
  end;
  consume(_RBRACE);
end;

{$ENDIF}

procedure TComponentPascal.FieldList;
(* FieldList = [IdentList ":" Type].
*)
begin
  //if ???
  IdentList;
  consume(_COLON);
  Type_;
end;

procedure TComponentPascal.FormalPars;
(* FormalPars = "(" [FPSection {";" FPSection}] ")" [":" Type].
*)
begin
  //if not try_to_consume(_LKLAMMER) then exit;
  consume(_LKLAMMER);

  if token <> _RKLAMMER then begin
    repeat
      FPSection;
    until not try_to_consume(_SEMICOLON) ;
  end;
  consume(_RKLAMMER);

  if try_to_consume(_COLON) then begin
    Type_;
  end;
end;

procedure TComponentPascal.FPSection;
(* FPSection = [VAR | IN | OUT] ident {"," ident} ":" Type.
*)
begin
  if token in [_VAR,_IN,_OUT] then begin
    consume(token);
  end;
  repeat
    Ident;
  until not try_to_consume(_COMMA);
  Type_;
end;

procedure TComponentPascal.Guard;
(* Guard = Qualident ":" Qualident.
*)
begin
  if token=_ID then begin
    QualIdent;
    consume(_COLON);
    QualIdent;
  end;
end;

procedure TComponentPascal.IdentDef;
(* IdentDef = ident [" * " | "-"].
*)
begin
  consume(_ID);
  if token=_STAR then begin
  //???
    consume(_STAR);
  end else if token=_MINUS then begin
    consume(_MINUS);
  end;
end;

procedure TComponentPascal.IdentList;
(* IdentList = IdentDef {"," IdentDef}.
*)
begin
  repeat
    IdentDef;
  until not try_to_consume(_COMMA);
end;

procedure TComponentPascal.MethAttributes;
(* MethAttributes = ["," NEW] ["," (ABSTRACT | EMPTY | EXTENSIBLE)].
*)
begin
{ The leading comma already has been consumed }
  //if try_to_consume(_COMMA) then begin
    if TokenIs('NEW') then begin
      consume(token);
      if not try_to_consume(_COMMA) then
        exit; //only NEW
    end;
    if try_to_consume(_ABSTRACT) then begin
    //???
    end else if TokenIs('EMPTY') then begin
      //???
      consume(token);
    end else if TokenIs('EXTENSIBLE') then begin
      //???
      consume(token);
    end;
  //end;
end;

procedure TComponentPascal.ProcDecl;
(* ProcDecl = PROCEDURE [Receiver] IdentDef [FormalPars] MethAttributes
[";" DeclSeq [BEGIN StatementSeq] END ident].
*)
(* ForwardDecl = PROCEDURE " ^ " [Receiver] IdentDef [FormalPars] MethAttributes.
*)
    procedure Receiver;
    (* Receiver = "(" [VAR | IN] ident ":" ident ")".
    *)
    begin
      if try_to_consume(_VAR) then begin
      //???
      end else if try_to_consume(_IN) then begin
      //???
      end;
      consume(_ID);
      consume(_COLON);
      consume(_ID);
    end;

var
  fwd: boolean;
begin
  consume(_PROCEDURE);
  fwd := try_to_consume(_CARET);
  if try_to_consume(_LKLAMMER) then begin
    Receiver; //opt.
  end;
  IdentDef;
  if try_to_consume(_LKLAMMER) then begin
    FormalPars; //opt
  end;
  if try_to_consume(_COMMA) then begin
    MethAttributes;
  end;
  if fwd then begin
    //...
  end else begin
    if try_to_consume(_SEMICOLON) then begin
      DeclSeq;
      if try_to_consume(_BEGIN) then begin
        StatementSeq;
        consume(_END);
        if token=_ID then begin //DoDi: made this conditional
        //ident must match procedure name
          consume(_ID);
        end;
      end;
    end;
    //...
  end;
end;

procedure TComponentPascal.QualIdent;
(* Qualident = [ident "."] ident.
*)
begin
  if UnitID then begin
  //unit.ident
    consume(_ID);
    consume(_POINT);
    consume(_ID);
  end else begin
    consume(_ID);
  end;
end;

procedure TComponentPascal.Ident;
begin
  consume(_ID);
end;

procedure TComponentPascal.Type_;
(* Type = Qualident
| ARRAY [ConstExpr {"," ConstExpr}] OF Type
| [ABSTRACT | EXTENSIBLE | LIMITED]
    RECORD ["("Qualident")"] FieldList {";" FieldList} END
| POINTER TO Type
| PROCEDURE [FormalPars].
*)
type
  TTypeKind = (tkNone, tkRec, tkPtr, tkTypeName); //disambiguate _ID
var
  kind: TTypeKind;
begin
  case token of
  _ARRAY:
    begin
      consume(_ARRAY);
      if token <> _OF then begin
        repeat
          ConstExpr;  //one dimension
        until not try_to_consume(_COMMA);
      end; //else open array
      consume(_OF);
      Type_;
    end;
  _ABSTRACT, _ID, _RECORD:
    begin
      kind:=tkNone;
      if token=_ABSTRACT then begin
        kind:=tkRec;
        consume(_ABSTRACT);
      end else if token=_RECORD then begin
        kind := tkRec;
        //consume later
      end else if token=_ID then begin
        if pattern='EXTENSIBLE' then begin
          kind := tkRec;
          consume(_ID);
        end else if pattern='LIMITED' then begin
          kind := tkRec;
          consume(_ID);
        end else if pattern = 'POINTER' then begin
          kind:=tkPtr;
          consume(_ID);
        //... handle pointer
          try_to_consume(_TO);  //DoDi: made this optional
          Type_;
        end else begin
        //assume/test typename
          kind := tkTypeName;
          QualIdent;
          //...
        end;
      end;
    //handle the detected type
      case kind of
      tkRec:
        begin
          consume(_RECORD);
          if try_to_consume(_LKLAMMER) then begin
          //inherit from
            QualIdent;
            consume(_RKLAMMER);
          end;
        //members
          repeat
            FieldList;
          until not try_to_consume(_SEMICOLON);
          consume(_END);
        end;
      //tkPtr, tkTypeName: finish?
      //tkNone: error?
      end;
    end;
  _PROCEDURE:
    begin
      consume(_PROCEDURE);
      FormalPars;
    end;
  //else Message...
  end;
end;

function TComponentPascal.UnitID: boolean;
begin
//todo: check if current token is a unit identifier
  //Result := (token=_ID) and ???;
  Result := False;  //for now
end;

initialization
  RegisterParser(@CPcpas);
end.

