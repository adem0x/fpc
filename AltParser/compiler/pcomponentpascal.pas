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
    procedure SkipWhite; override;
    procedure ScanToken; override;
  end;

implementation

uses
  globals,symsym,verbose,
  globtype,
  SModules,fmodule,
{$IFDEF StdExprs}
  pexpr,
{$ELSE}
{$ENDIF}
  scanner, tokens;

//some token substitutions, for now
const
//keywords
  _CLOSE  = _FINALIZATION; //same meaning
  _IMPORT = _USES;
  _MODULE = _UNIT;
  _BY     = _DOWNTO; //mutually exlucsive
  _ELSEIF = _OTHERWISE;
  _EMPTY  = _DEFAULT;
  _EXTENSIBLE = _VIRTUAL;
  _LIMITED= _PRIVATE;
  _LOOP   = _LABEL;
  _POINTER= _GOTO;
//non-keywords
  _NEW    = _PUBLISHED;
//tokens
  _LBRACE = _LSHARPBRACKET;
  _RBRACE = _RSHARPBRACKET;
  _DOLLAR = _KLAMMERAFFE;
  _TILDE  = _NOT;

  Relation = [_EQUAL,_UNEQUAL,_LT,_LTE,_GT,_GTE,_IN,_IS];
            //"=" | "#" | "<" | "<=" | ">" | ">=" | IN | IS.
  AddOp = [_PLUS,_MINUS,_OR]; // "+" | "-" | OR.
  MulOp = [_STAR,_SLASH,_DIV,_MOD,_AMPERSAND];  // " * " | "/" | DIV | MOD | "&".
  LogOp = [_OR, _AMPERSAND, _TILDE];  // logical OR, AND, NOT

const
  CPcpas: TParserListItem = (
    ext: '.cpas'; cls: TComponentPascal;
    alt:nil; next:nil;
  );

{ TComponentPascal }

procedure TComponentPascal.ScanToken;
{
The representation of (terminal) symbols in terms of characters is defined using
ISO 8859-1, i.e., the Latin-1 extension of the ASCII character set.
Unicode (16 bit) characters are allowed in string constants only.

Braces, $ and # are tokens!

Strings in single or double quotes, no duplication allowed.

IMO the C-ish number format is stupid, but to translate real life code...
}
var
  i: integer;
  delim: char;
const //for Latin-1 charset in identifiers
  IDfirst = ['A'..'Z','a'..'z','_'];
  IDnext = ['A'..'Z','a'..'z','_', '0'..'9', //'À'..'Ö', 'Ø'..'ö', 'ø'..'ÿ',#0];
    #$C0..#$D6, #$D8..#$F6, #$F8..#$FF, #0];
begin
{ Check first for an identifier/keyword, this is 20+% faster (PFV) }
  if c in IDfirst then begin
    //readstring;
    i := 1; //length+1
    while c in IDnext do begin
      if c=#0 then begin
        reload;
        continue; //???
      end else if i <= 255 then begin
        orgpattern[i]:=c;
        pattern[i]:=c; //the language is case sensitive
        inc(i); //>255 is overflow
      end;
      c := inputpointer^;
      inc(inputpointer);
    end;
  //check length - allow for overflows (ignore excess chars?)
    if i > 255 then begin
      Message(scan_e_string_exceeds_255_chars);
      i := 255;
    end else
      dec(i); //real length
    SetLength(orgpattern,i);
    SetLength(pattern,i);
    token:=_ID;
    idtoken:=_ID;
  { keyword or any other known token? }
    case pattern[1] of
    'A':  if (i=8) and (pattern='ABSTRACT') then token:=_ABSTRACT else
          if (i=5) and (pattern='ARRAY')    then token:=_ARRAY;
    'B':  if (i=5) and (pattern='BEGIN')    then token:=_BEGIN else
          if (i=2) and (pattern[2]='Y')     then token:=_by;
    'C':  if (i=4) and (pattern='CASE')     then token:=_CASE else
          if (i=5) then begin
                    if pattern='CLOSE'      then token:=_close else
                    if pattern='CONST'      then token:=_CONST;
          end;
    'D':  if (i=2) and (pattern='DO')        then token:=_DO else
          if (i=3) and (pattern='DIV')      then token:=_DIV;
    'E':  if (i=4) then begin
                    if pattern='ELSE'       then token:=_ELSE else
                    if pattern='EXIT'       then token:=_EXIT end else
          if (i=3) and (pattern='END')      then token:=_END else
          if (i=5) then begin
                    if pattern='ELSIF'      then token:=_elseif else
                    if pattern='EMPTY'      then token:=_empty end else
          if (i=10) and (pattern='EXTENSIBLE') then token:=_extensible;
    'F':  if (i=3) and (pattern='FOR')      then token:=_FOR;

    'I':  if (i=2) then begin
            case pattern[2] of
              'F': token:=_IF;
              'N': token:=_IN;
              'S': token:=_IS;
            end
          end else if (i=6) and (pattern='IMPORT') then token:=_import;
    'L':  if (i=7) and (pattern='LIMITED')  then token:=_limited else
          if (i=4) and (pattern='LOOP')     then token:=_loop;
    'M':  if (i=3) and (pattern='MOD')      then token:=_MOD else
          if (i=6) and (pattern='MODULE')   then token:=_module;
    'N':  if (i=3) then begin
                    if (pattern='NIL')      then token:=_NIL else
                    if (pattern='NEW')      then token:=_NEW end;
    'O':  if (i=3) and (pattern='OUT')      then token:=_OUT else
          if (i=2) then
            case pattern[2] of
            'F':  token:=_OF;
            'R':  token:=_OR;
            end;
    'P':  if (i=7) and (pattern='POINTER')  then token:=_pointer else
          if (i=9) and (pattern='PROCEDURE')then token:=_PROCEDURE;
    'R':  if (i=6) then begin
            if pattern='RECORD'             then token:=_RECORD else
            if pattern='REPEAT'             then token:=_REPEAT else
            if pattern='RETURN'             then token:=_RETURN end;
    'T':  if (i=2) and (pattern[2]='O')     then token:=_TO else
          if (i=4) then begin
            if (pattern='THEN')             then token:=_THEN else
            if (pattern='TYPE')             then token:=_TYPE end;
    'U':  if (i=5) and (pattern='UNTIL')    then token:=_UNTIL;
    'V':  if (i=3) and (pattern='VAR')      then token:=_VAR;
    'W':  if (i=4) and (pattern='WITH')     then token:=_WITH else
          if (i=5) and (pattern='WHILE')    then token:=_WHILE;
    end;
  { identifiers may be macros }
    if token=_ID then
      CheckMacro;
  end else begin
    idtoken:=_NOID;
    case c of
    '''', '"': //todo: strings deserve more handling
      begin
        delim:=c;
        SetLength(cstringpattern,256);
        i := 0;
        repeat
          readchar; //handles #0
          case c of
          #26:  end_of_file;
          #10,#13: Message(scan_f_string_exceeds_line);
          else //case
          //todo: only handle Ansi, for now
            if c = delim then
              break;
            inc(i);
            if i > Length(cstringpattern) then
              SetLength(cstringpattern, i*2);
            cstringpattern[i] := c;
          end;
        until False;
        readchar; //skip delimiter(?)
        SetLength(cstringpattern,i);
        if i = 1 then begin
          token := _CCHAR;  //really???
          pattern:=cstringpattern;
        end else
          token := _CSTRING;
      end;
    '#': begin readchar; token:=_UNEQUAL; end;
    '$':  //token (AsString), but also allow for hex numbers(?)
      if (m_fpc in current_settings.modeswitches) then begin
        readnumber;
        if length(pattern) = 1 then
          token:=_dollar
        else
          token:=_INTCONST;
      end else begin
        readchar;
        token:=_dollar;
      end;
    '%':  //allow for binary number?
      if (m_fpc in current_settings.modeswitches) then begin
        readnumber;
        token:=_INTCONST;
      end else
        Illegal_Char(c);
    '&': //_AMPERSAND, also allow for escaped ID, octal number?
      if [m_fpc,m_delphi] * current_settings.modeswitches <> [] then begin
        readnumber;
        if length(pattern)=1 then begin
            readstring;
            token:=_ID;
            idtoken:=_ID;
        end else
          token:=_INTCONST;
      end else begin
        readchar;
        token:=_AMPERSAND;
      end;
//    '(':  begin readchar; token:=_LKLAMMER end; //comment ---------------
    ')':  begin readchar; token:=_RKLAMMER end;
//    '*':  begin readchar; token:=_STAR; end;  //**? *=?
//    '+':  begin readchar; token:=_PLUS; end;
    ',':  begin readchar; token:=_COMMA; end;
//    '-':  begin readchar; token:=_MINUS; end;
//    '.':  begin readchar; token:=_POINT; end; //.. ----------------------
//    '/':  begin readchar; token:=_SLASH; end; // /=? comment??? --------------
    '0'..'9' : //--------------------------------------------------------
       begin
         readnumber;
         if (c in ['.','e','E']) then begin
          { first check for a . }
            if c='.' then begin
               cachenexttokenpos;
               readchar;
               { is it a .. from a range? }
               case c of
                 '.' :
                   begin
                     readchar;
                     token:=_INTCONST;
                     nexttoken:=_POINTPOINT;
                     exit;
                   end;
                 ')' :
                   begin
                     readchar;
                     token:=_INTCONST;
                     nexttoken:=_RECKKLAMMER;
                     exit;
                   end;
                end;
            end;
             { insert the number after the . }
             pattern:=pattern+'.';
             while c in ['0'..'9'] do
              begin
                pattern:=pattern+c;
                readchar;
              end;
          { E can also follow after a point is scanned }
            if c in ['e','E'] then
             begin
               pattern:=pattern+'E';
               readchar;
               if c in ['-','+'] then
                begin
                  pattern:=pattern+c;
                  readchar;
                end;
               if not(c in ['0'..'9']) then
                Illegal_Char(c);
               while c in ['0'..'9'] do
                begin
                  pattern:=pattern+c;
                  readchar;
                end;
             end;
            token:=_REALNUMBER;
            exit;
          end;
         token:=_INTCONST;
       end;
//    ':':  begin readchar; token:=_COLON; end; //:= -----------------
    ';':  begin readchar; token:=_SEMICOLON; end;
//    '<':  begin readchar; token:=_LT; end;  // < <= generics? <= -----------
    '=':  begin readchar; token:=_EQUAL; end;
//    '>':  begin readchar; token:=_GT; end;  //>= ----------------------
    '[':  begin readchar; token:=_LECKKLAMMER; end;
    ']':  begin readchar; token:=_RECKKLAMMER; end;
    '^':  begin readchar; token:=_CARET; end;
    '{':  begin readchar; token:=_LBRACE; end;
    '|':  begin readchar; token:=_PIPE; end;
    '}':  begin readchar; token:=_RBRACE; end;
    '~':  begin readchar; token:=_TILDE; end;

     '(' :  // ( or (. or (* ?
       begin
         readchar;
         case c of
           '*' :
             begin
               c:=#0;{Signal skipoldtpcomment to reload a char }
               skipoldtpcomment;
               readtoken(false);
             end;
           '.' :
             begin
               readchar;
               token:=_LECKKLAMMER;
             end;
         else
               token:=_LKLAMMER;
         end;
       end;

     '+' : // + or +=
       begin
         readchar;
         if (c='=') and (cs_support_c_operators in current_settings.moduleswitches) then begin
            readchar;
            token:=_PLUSASN;
         end else
           token:=_PLUS;
       end;

     '-' :  // - or -=
       begin
         readchar;
         if (c='=') and (cs_support_c_operators in current_settings.moduleswitches) then begin
            readchar;
            token:=_MINUSASN;
         end else
           token:=_MINUS;
       end;

     ':' :  // : or :=
       begin
         readchar;
         if c='=' then begin
            readchar;
            token:=_ASSIGNMENT;
         end else
           token:=_COLON;
       end;

     '*' :  // * or *= or ** ???
       begin
         readchar;
         if (c='=') and (cs_support_c_operators in current_settings.moduleswitches) then begin
            readchar;
            token:=_STARASN;
         end else if c='*' then begin
             readchar;
             token:=_STARSTAR;
         end else
            token:=_STAR;
       end;

     '/' : // / or /= or // ???
       begin
         readchar;
         case c of
         '=' :
           begin
             if (cs_support_c_operators in current_settings.moduleswitches) then begin
                readchar;
                token:=_SLASHASN;
              end;
           end;
         '/' :
           begin
             skipdelphicomment;
             readtoken(false);
           end;
         else
           token:=_SLASH;
         end;
       end;

     '.' : // . or .. or .) or ... ???
       begin
         readchar;
         case c of
           '.' :
             begin
               readchar;
               case c of
               '.' :
                 begin
                   readchar;
                   token:=_POINTPOINTPOINT;
                 end;
               else
                   token:=_POINTPOINT;
               end;
             end;
           ')' :
             begin
               readchar;
               token:=_RECKKLAMMER;
             end;
         else //case
           token:=_POINT;
         end;
       end;
{$IFDEF OPL}
     '@' :
       begin
         readchar;
         token:=_KLAMMERAFFE;
       end;

     '''','#','^' :
       begin
         len:=0;
         cstringpattern:='';
         iswidestring:=false;
         if c='^' then begin
            readchar;
            c:=upcase(c);
            if (block_type in [bt_type,bt_const_type,bt_var_type]) or
               (lasttoken=_ID) or (lasttoken=_NIL) or (lasttoken=_OPERATOR) or
               (lasttoken=_RKLAMMER) or (lasttoken=_RECKKLAMMER) or (lasttoken=_CARET) then
            begin
               token:=_CARET;
               exit;  //goto exit_label;
            end else begin
               inc(len);
               setlength(cstringpattern,256);
               if c<#64 then
                 cstringpattern[len]:=chr(ord(c)+64)
               else
                 cstringpattern[len]:=chr(ord(c)-64);
               readchar;
            end;
         end;
         repeat
           case c of
             '#' :
               begin
                 readchar; { read # }
                 case c of
                   '$':
                     begin
                       readchar; { read leading $ }
                       asciinr:='$';
                       while (upcase(c) in ['A'..'F','0'..'9']) and (length(asciinr)<=5) do
                         begin
                           asciinr:=asciinr+c;
                           readchar;
                         end;
                     end;
                   '&':
                     begin
                       readchar; { read leading $ }
                       asciinr:='&';
                       while (upcase(c) in ['0'..'7']) and (length(asciinr)<=7) do
                         begin
                           asciinr:=asciinr+c;
                           readchar;
                         end;
                     end;
                   '%':
                     begin
                       readchar; { read leading $ }
                       asciinr:='%';
                       while (upcase(c) in ['0','1']) and (length(asciinr)<=17) do
                         begin
                           asciinr:=asciinr+c;
                           readchar;
                         end;
                     end;
                   else
                     begin
                       asciinr:='';
                       while (c in ['0'..'9']) and (length(asciinr)<=5) do
                         begin
                           asciinr:=asciinr+c;
                           readchar;
                         end;
                     end;
                 end;
                 val(asciinr,m,code);
                 if (asciinr='') or (code<>0) then
                   Message(scan_e_illegal_char_const)
                 else if (m<0) or (m>255) or (length(asciinr)>3) then
                   begin
                      if (m>=0) and (m<=65535) then
                        begin
                          if not iswidestring then
                           begin
                             if len>0 then
                               ascii2unicode(@cstringpattern[1],len,patternw)
                             else
                               ascii2unicode(nil,len,patternw);
                             iswidestring:=true;
                             len:=0;
                           end;
                          concatwidestringchar(patternw,tcompilerwidechar(m));
                        end
                      else
                        Message(scan_e_illegal_char_const)
                   end
                 else if iswidestring then
                   concatwidestringchar(patternw,asciichar2unicode(char(m)))
                 else
                   begin
                     if len>=length(cstringpattern) then
                       setlength(cstringpattern,length(cstringpattern)+256);
                      inc(len);
                      cstringpattern[len]:=chr(m);
                   end;
               end;
             '''' :
               begin
                 repeat
                   readchar;
                   case c of
                     #26 :
                       end_of_file;
                     #10,#13 :
                       Message(scan_f_string_exceeds_line);
                     '''' :
                       begin
                         readchar;
                         if c<>'''' then
                          break;
                       end;
                   end;
                   { interpret as utf-8 string? }
                   if (ord(c)>=$80) and (current_settings.sourcecodepage='utf8') then
                     begin
                       { convert existing string to an utf-8 string }
                       if not iswidestring then
                         begin
                           if len>0 then
                             ascii2unicode(@cstringpattern[1],len,patternw)
                           else
                             ascii2unicode(nil,len,patternw);
                           iswidestring:=true;
                           len:=0;
                         end;
                       { four or more chars aren't handled }
                       if (ord(c) and $f0)=$f0 then
                         message(scan_e_utf8_bigger_than_65535)
                       { three chars }
                       else if (ord(c) and $e0)=$e0 then
                         begin
                           w:=ord(c) and $f;
                           readchar;
                           if (ord(c) and $c0)<>$80 then
                             message(scan_e_utf8_malformed);
                           w:=(w shl 6) or (ord(c) and $3f);
                           readchar;
                           if (ord(c) and $c0)<>$80 then
                             message(scan_e_utf8_malformed);
                           w:=(w shl 6) or (ord(c) and $3f);
                           concatwidestringchar(patternw,w);
                         end
                       { two chars }
                       else if (ord(c) and $c0)<>0 then
                         begin
                           w:=ord(c) and $1f;
                           readchar;
                           if (ord(c) and $c0)<>$80 then
                             message(scan_e_utf8_malformed);
                           w:=(w shl 6) or (ord(c) and $3f);
                           concatwidestringchar(patternw,w);
                         end
                       { illegal }
                       else if (ord(c) and $80)<>0 then
                         message(scan_e_utf8_malformed)
                       else
                         concatwidestringchar(patternw,tcompilerwidechar(c))
                     end
                   else if iswidestring then
                     begin
                       if current_settings.sourcecodepage='utf8' then
                         concatwidestringchar(patternw,ord(c))
                       else
                         concatwidestringchar(patternw,asciichar2unicode(c))
                     end
                   else
                     begin
                       if len>=length(cstringpattern) then
                         setlength(cstringpattern,length(cstringpattern)+256);
                        inc(len);
                        cstringpattern[len]:=c;
                     end;
                 until false;
               end;
             '^' :
               begin
                 readchar;
                 c:=upcase(c);
                 if c<#64 then
                  c:=chr(ord(c)+64)
                 else
                  c:=chr(ord(c)-64);

                 if iswidestring then
                   concatwidestringchar(patternw,asciichar2unicode(c))
                 else
                   begin
                     if len>=length(cstringpattern) then
                       setlength(cstringpattern,length(cstringpattern)+256);
                      inc(len);
                      cstringpattern[len]:=c;
                   end;

                 readchar;
               end;
             else
              break;
           end;
         until false;
         { strings with length 1 become const chars }
         if iswidestring then
           begin
             if patternw^.len=1 then
               token:=_CWCHAR
             else
               token:=_CWSTRING;
           end
         else
           begin
             setlength(cstringpattern,len);
             if length(cstringpattern)=1 then
               begin
                 token:=_CCHAR;
                 pattern:=cstringpattern;
               end
             else
               token:=_CSTRING;
           end;
       end;
{$ELSE}
{$ENDIF}

     '>' :  // > or >= or >> or >< ???
       begin
         readchar;
       {$IFDEF generics}
         if (block_type in [bt_type,bt_var_type,bt_const_type]) then
           token:=_RSHARPBRACKET
         else
       {$ELSE}
       {$ENDIF}
           begin
             case c of
               '=' :
                 begin
                   readchar;
                   token:=_GTE;
                 end;
               '>' :
                 begin
                   readchar;
                   token:=_OP_SHR;
                 end;
               '<' :
                 begin { >< is for a symetric diff for sets }
                   readchar;
                   token:=_SYMDIF;
                 end;
             else
               token:=_GT;
             end;
           end;
       end;

     '<' :  // < or <= or << ???
       begin
         readchar;
       {$IFDEF generics}
         if (block_type in [bt_type,bt_var_type,bt_const_type]) then
           token:=_LSHARPBRACKET
         else
       {$ELSE}
       {$ENDIF}
           begin
             case c of
               '>' :
                 begin
                   readchar;
                   token:=_UNEQUAL;
                 end;
               '=' :
                 begin
                   readchar;
                   token:=_LTE;
                 end;
               '<' :
                 begin
                   readchar;
                   token:=_OP_SHL;
                 end;
             else
               token:=_LT;
             end;
           end;
       end;

     #26 : // EOF
       begin
         token:=_EOF;
         checkpreprocstack;
       end;
     else //case
       Illegal_Char(c);
    end;
  end;
end;

procedure TComponentPascal.SkipWhite;
{ comments only in (* *), braces are tokens!
}
begin
{ Skip all spaces and comments }
  repeat
    case c of
      #26 :
        begin
          reload;
          if (c=#26) and not assigned(inputfile.next) then
            break;
        end;
      ' ',#9..#13 :
        begin
{$ifdef PREPROCWRITE}
          if parapreprocess then
           begin
             if c in [#10,#13] then
              preprocfile.eolfound:=true
             else
              preprocfile.spacefound:=true;
           end;
{$endif PREPROCWRITE}
          skipspace;
        end
      else
        break;
    end;
  until false;
end;

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
  if (token=_MODULE) or (compile_level>main_program_level) then begin
  //non main-level modules can be nothing but units
    current_module.is_unit:=true;
    sm.SModuleInitUnit;  //is this applicable???
  end else begin //assume program
    sm.SModuleInitProgLib(False);
  end;
  if (token=_PROGRAM) or (token=_MODULE) then
    consume(token);
  sm.SProgName; //expect _ID
  consume(_ID);
  consume(_SEMICOLON);
//enter implementation body
  sm.SProgLibImplInit;
//imports/uses?
  if (token=_IMPORT) then begin
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
  if (token=_CLOSE) then begin
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
        consume(_RKLAMMER);
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
    if (token=_NEW) then begin
      consume(token);
      if not try_to_consume(_COMMA) then
        exit; //only NEW
    end;
    if try_to_consume(_ABSTRACT) then begin
    //???
    end else if token=_EMPTY then begin
      //???
      consume(token);
    end else if token=_EXTENSIBLE then begin
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
        consume(_SEMICOLON);
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

