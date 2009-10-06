
(* lexical analyzer template (TP Lex V3.0), V1.0 3-2-91 AG *)

(* global definitions: *)
{
    Copyright (c) 1998-2000 by Florian Klaempfl

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

 ****************************************************************************}


unit scan;

  interface

  uses
   strings,
   h2plexlib,h2pyacclib;

    const
       version = '1.0.0';

    type
       Char=system.char;
       ttyp = (
          t_id,
          { p contains the string }
          t_arraydef,
          { }
          t_pointerdef,
          { p1 contains the definition
            if in type overrider
            or nothing for args
          }
          t_addrdef,

          t_void,
          { no field }
          t_dec,
          { }
          t_declist,
          { p1 is t_dec
            next if exists }
          t_memberdec,
          { p1 is type specifier
            p2 is declarator_list }
          t_structdef,
          { }
          t_memberdeclist,
          { p1 is memberdec
            next is next if it exist }
          t_procdef,
          { }
          t_uniondef,
          { }
          t_enumdef,
          { }
          t_enumlist,
          { }
          t_preop,
          { p contains the operator string
            p1 contains the right expr }
          t_bop,
          { p contains the operator string
            p1 contains the left expr
            p2 contains the right expr }
          t_arrayop,
          {
            p1 contains the array expr
            p2 contains the index expressions }
          t_callop,
          {
            p1 contains the proc expr
            p2 contains the index expressions }
          t_arg,
          {
            p1 contain the typedef
            p2 the declarator (t_dec)
          }
          t_arglist,
          { }
          t_funexprlist,
          { }
          t_exprlist,
          { p1 contains the expr
            next contains the next if it exists }
          t_ifexpr,
          { p1 contains the condition expr
            p2 contains the if branch
            p3 contains the else branch }
          t_funcname,
          { p1 contains the function dname
            p2 contains the funexprlist
            p3 possibly contains the return type }
          t_typespec,
          { p1 is the type itself
            p2 the typecast expr }
          t_size_specifier,
          { p1 expr for size }
          t_default_value,
          { p1 expr for value }
          t_statement_list,
          { p1 is the statement
            next is next if it exist }
          t_whilenode,
          t_fornode,
          t_dowhilenode,
          t_switchnode,
          t_gotonode,
          t_continuenode,
          t_breaknode
          );

const
   ttypstr: array[ttyp] of string =
   (
          't_id',
          't_arraydef',
          't_pointerdef',
          't_addrdef',
          't_void',
          't_dec',
          't_declist',
          't_memberdec',
          't_structdef',
          't_memberdeclist',
          't_procdef',
          't_uniondef',
          't_enumdef',
          't_enumlist',
          't_preop',
          't_bop',
          't_arrayop',
          't_callop',
          't_arg',
          't_arglist',
          't_funexprlist',
          't_exprlist',
          't_ifexpr',
          't_funcname',
          't_typespec',
          't_size_specifier',
          't_default_value',
          't_statement_list',
          't_whilenode',
          't_fornode',
          't_dowhilenode',
          't_switchnode',
          't_gotonode',
          't_continuenode',
          't_breaknode'
   );

type

       presobject = ^tresobject;
       tresobject = object
          typ : ttyp;
          p : pchar;
          next : presobject;
          p1,p2,p3 : presobject;
          { name of int/real, then no T prefix is required }
          intname : boolean;
          constructor init_no(t : ttyp);
          constructor init_one(t : ttyp;_p1 : presobject);
          constructor init_two(t : ttyp;_p1,_p2 : presobject);
          constructor init_three(t : ttyp;_p1,_p2,_p3 : presobject);
          constructor init_id(const s : string);
          constructor init_intid(const s : string);
          constructor init_bop(const s : string;_p1,_p2 : presobject);
          constructor init_preop(const s : string;_p1 : presobject);
          procedure setstr(const s:string);
          function str : string;
          function strlength : byte;
          function get_copy : presobject;
          { can this ve considered as a constant ? }
          function is_const : boolean;
          destructor done;
       end;

     tblocktype = (bt_type,bt_const,bt_var,bt_func,bt_no);


    var
       infile : string;
       outfile : text;
       c : char;
       aktspace : string;
       block_type : tblocktype;
       commentstr: string;

    const
       in_define : boolean = false;
       { True if define spans to the next line }
       cont_line : boolean = false;
       { 1 after define; 2 after the ID to print the first separating space }
       in_space_define : byte = 0;
       arglevel : longint = 0;

       {> 1 = ifdef level in a ifdef C++ block
          1 = first level in an ifdef block
          0 = not in an ifdef block
         -1 = in else part of ifdef block, process like we weren't in the block
              but skip the incoming end.
        > -1 = ifdef sublevel in an else block.
       }
       cplusblocklevel : LongInt = 0;


    function yylex : integer;
    function act_token : string;
    procedure internalerror(i : integer);

    function strpnew(const s : string) : pchar;

    procedure writetree(p: presobject);


  implementation

    uses
       h2poptions,converu;

    const
       newline = #10;


    procedure writeentry(p: presobject; var currentlevel: integer);
    begin
                     if assigned(p^.p1) then
                        begin
                          WriteLn(' Entry p1[',ttypstr[p^.p1^.typ],']',p^.p1^.str);
                        end;
                     if assigned(p^.p2) then
                        begin
                          WriteLn(' Entry p2[',ttypstr[p^.p2^.typ],']',p^.p2^.str);
                        end;
                     if assigned(p^.p3) then
                        begin
                          WriteLn(' Entry p3[',ttypstr[p^.p3^.typ],']',p^.p3^.str);
                        end;
    end;

    procedure writetree(p: presobject);
    var
     i : integer;
     localp: presobject;
     localp1: presobject;
     currentlevel : integer;
    begin
      localp:=p;
      currentlevel:=0;
      while assigned(localp) do
         begin
          WriteLn('Entry[',ttypstr[localp^.typ],']',localp^.str);
          case localp^.typ of
          { Some arguments sharing the same type }
          t_arglist:
            begin
               localp1:=localp;
               while assigned(localp1) do
                  begin
                     writeentry(localp1,currentlevel);
                     localp1:=localp1^.p1;
                  end;
            end;
          end;

          localp:=localp^.next;
         end;
    end;



    procedure internalerror(i : integer);
      begin
         writeln('Internal error ',i,' in line ',yylineno);
         halt(1);
      end;


    procedure commenteof;
      begin
         writeln('unexpected EOF inside comment at line ',yylineno);
      end;


    procedure copy_until_eol;
      begin
        c:=get_char;
        while c<>newline do
         begin
           write(outfile,c);
           c:=get_char;
         end;
      end;


    procedure skip_until_eol;
      begin
        c:=get_char;
        while c<>newline do
         c:=get_char;
      end;


    function strpnew(const s : string) : pchar;
      var
        p : pchar;
      begin
         getmem(p,length(s)+1);
         strpcopy(p,s);
         strpnew:=p;
      end;

    function NotInCPlusBlock : Boolean; inline;
    begin
      NotInCPlusBlock := cplusblocklevel < 1;
    end;

    constructor tresobject.init_preop(const s : string;_p1 : presobject);
      begin
         typ:=t_preop;
         p:=strpnew(s);
         p1:=_p1;
         p2:=nil;
         p3:=nil;
         next:=nil;
         intname:=false;
      end;

    constructor tresobject.init_bop(const s : string;_p1,_p2 : presobject);
      begin
         typ:=t_bop;
         p:=strpnew(s);
         p1:=_p1;
         p2:=_p2;
         p3:=nil;
         next:=nil;
         intname:=false;
      end;

    constructor tresobject.init_id(const s : string);
      begin
         typ:=t_id;
         p:=strpnew(s);
         p1:=nil;
         p2:=nil;
         p3:=nil;
         next:=nil;
         intname:=false;
      end;

    constructor tresobject.init_intid(const s : string);
      begin
         typ:=t_id;
         p:=strpnew(s);
         p1:=nil;
         p2:=nil;
         p3:=nil;
         next:=nil;
         intname:=true;
      end;

    constructor tresobject.init_two(t : ttyp;_p1,_p2 : presobject);
      begin
         typ:=t;
         p1:=_p1;
         p2:=_p2;
         p3:=nil;
         p:=nil;
         next:=nil;
         intname:=false;
      end;

    constructor tresobject.init_three(t : ttyp;_p1,_p2,_p3 : presobject);
      begin
         typ:=t;
         p1:=_p1;
         p2:=_p2;
         p3:=_p3;
         p:=nil;
         next:=nil;
         intname:=false;
      end;

    constructor tresobject.init_one(t : ttyp;_p1 : presobject);
      begin
         typ:=t;
         p1:=_p1;
         p2:=nil;
         p3:=nil;
         next:=nil;
         p:=nil;
         intname:=false;
      end;

    constructor tresobject.init_no(t : ttyp);
      begin
         typ:=t;
         p:=nil;
         p1:=nil;
         p2:=nil;
         p3:=nil;
         next:=nil;
         intname:=false;
      end;

    procedure tresobject.setstr(const s : string);
      begin
         if assigned(p) then
          strdispose(p);
         p:=strpnew(s);
      end;

    function tresobject.str : string;
      begin
         str:=strpas(p);
      end;

    function tresobject.strlength : byte;
      begin
         if assigned(p) then
           strlength:=strlen(p)
         else
           strlength:=0;
      end;

    { can this ve considered as a constant ? }
    function tresobject.is_const : boolean;
      begin
         case typ of
           t_id,t_void :
             is_const:=true;
           t_preop  :
             is_const:= ((str='-') or (str=' not ')) and p1^.is_const;
           t_bop  :
             is_const:= p2^.is_const and p1^.is_const;
         else
           is_const:=false;
         end;
      end;

    function tresobject.get_copy : presobject;
      var
         newres : presobject;
      begin
         newres:=new(presobject,init_no(typ));
         newres^.intname:=intname;
         if assigned(p) then
           newres^.p:=strnew(p);
         if assigned(p1) then
           newres^.p1:=p1^.get_copy;
         if assigned(p2) then
           newres^.p2:=p2^.get_copy;
         if assigned(p3) then
           newres^.p3:=p3^.get_copy;
         if assigned(next) then
           newres^.next:=next^.get_copy;
         get_copy:=newres;
      end;

    destructor tresobject.done;
      begin
         (* writeln('disposing ',byte(typ)); *)
         if assigned(p)then strdispose(p);
         if assigned(p1) then
           dispose(p1,done);
         if assigned(p2) then
           dispose(p2,done);
         if assigned(p3) then
           dispose(p3,done);
         if assigned(next) then
           dispose(next,done);
      end;


function yylex : Integer;

procedure yyaction ( yyruleno : Integer );
  (* local definitions: *)

begin
  (* actions: *)
  case yyruleno of
  1:
                        if NotInCPlusBlock then
                        begin
                          if not stripcomment then
                            write(outfile,aktspace,'{');
                          repeat
                            c:=get_char;
                            case c of
                               '*' :
                                 begin
                                   c:=get_char;
                                   if c='/' then
                                    begin
                                      if not stripcomment then
                                       write(outfile,' }');
                                      c:=get_char;
                                      if c=newline then
                                        writeln(outfile);
                                      unget_char(c);
                                      flush(outfile);
                                      exit;
                                    end
                                   else
                                    begin
                                      if not stripcomment then
                                       write(outfile,'*');
                                      unget_char(c)
                                    end;
                                  end;
                                newline :
                                  begin
                                    if not stripcomment then
                                     begin
                                       writeln(outfile);
                                       write(outfile,aktspace);
                                     end;
                                  end;
                                { Don't write this thing out, to
                                  avoid nested comments.
                                }
                              '{','}' :
                                  begin
                                  end;
                                #0 :
                                  commenteof;
                                else
                                  if not stripcomment then
                                   write(outfile,c);
                            end;
                          until false;
                          flush(outfile);
                        end
                        else
                          skip_until_eol;
  2:
                        if NotInCPlusBlock then
                        begin
                          commentstr:='';
                          if (in_define) and not (stripcomment) then
                          begin
                             commentstr:='{';
                          end
                          else
                          If not stripcomment then
                            write(outfile,aktspace,'{');

                          repeat
                            c:=get_char;
                            case c of
                              newline :
                                begin
                                  unget_char(c);
                                  if not stripcomment then
                                    begin
                                      if in_define then
                                        begin
                                          commentstr:=commentstr+' }';
                                        end
                                      else
                                        begin
                                          write(outfile,' }');
                                          writeln(outfile);
                                        end;
                                    end;
                                  flush(outfile);
                                  exit;
                                end;
                              { Don't write this comment out,
                                to avoid nested comment problems
                              }
                              '{','}' :
                                  begin
                                  end;
                              #0 :
                                commenteof;
                              else
                                if not stripcomment then
                                  begin
                                    if in_define then
                                     begin
                                       commentstr:=commentstr+c;
                                     end
                                    else
                                      write(outfile,c);
                                  end;
                            end;
                          until false;
                          flush(outfile);
                        end
                        else
                          skip_until_eol;
  3:
                        if NotInCPlusBlock then return(CSTRING) else skip_until_eol;
  4:
                        if NotInCPlusBlock then return(CSTRING) else skip_until_eol;
  5:
                        if NotInCPlusBlock then
                        begin
                          if win32headers then
                            return(CSTRING)
                          else
                            return(256);
                        end
                        else skip_until_eol;
  6:
                        if NotInCPlusBlock then
                        begin
                          if win32headers then
                            return(CSTRING)
                          else
                            return(256);
                        end
                        else
                          skip_until_eol;
  7:
                        if NotInCPlusBlock then
                        begin
                           while yytext[length(yytext)] in ['L','U','l','u'] do
                             Delete(yytext,length(yytext),1);
                           return(NUMBER);
                        end
                         else skip_until_eol;
  8:
                          
                        if NotInCPlusBlock then
                        begin
                           (* handle pre- and postfixes *)
                           if copy(yytext,1,2)='0x' then
                             begin
                                delete(yytext,1,2);
                                yytext:='$'+yytext;
                             end;
                           while yytext[length(yytext)] in ['L','U','l','u'] do
                             Delete(yytext,length(yytext),1);
                           return(NUMBER);
                        end
                        else
                         skip_until_eol;
  9:
                             
                        if NotInCPlusBlock then
                        begin
                          return(NUMBER);
                        end
                        else
                          skip_until_eol;
  10:
                        if NotInCPlusBlock then
                        begin
                          if in_define then
                            return(DEREF)
                          else
                            return(256);
                        end
                        else
                          skip_until_eol;
  11:
                        if NotInCPlusBlock then return(MINUS) else skip_until_eol;
  12:
                        if NotInCPlusBlock then return(EQUAL) else skip_until_eol;
  13:
                        if NotInCPlusBlock then return(UNEQUAL) else skip_until_eol;
  14:
                        if NotInCPlusBlock then return(GTE) else skip_until_eol;
  15:
                        if NotInCPlusBlock then return(LTE) else skip_until_eol;
  16:
                        if NotInCPlusBlock then return(_SHR) else skip_until_eol;
  17:
                        if NotInCPlusBlock then return(STICK) else skip_until_eol;
  18:
                        if NotInCPlusBlock then return(_SHL) else skip_until_eol;
  19:
                        if NotInCPlusBlock then return(GT) else skip_until_eol;
  20:
                        if NotInCPlusBlock then return(LT) else skip_until_eol;
  21:
                        if NotInCPlusBlock then return(_OR) else skip_until_eol;
  22:
                        if NotInCPlusBlock then return(_AND) else skip_until_eol;
  23:
                        if NotInCPlusBlock then return(_NOT) else skip_until_eol; (* inverse, but handled as not operation *)
  24:
                        if NotInCPlusBlock then return(_NOT) else skip_until_eol;
  25:
                        if NotInCPlusBlock then return(_SLASH) else skip_until_eol;
  26:
                        if NotInCPlusBlock then return(_PLUS) else skip_until_eol;
  27:
                        if NotInCPlusBlock then return(QUESTIONMARK) else skip_until_eol;
  28:
                        if NotInCPlusBlock then return(COLON) else skip_until_eol;
  29:
                        if NotInCPlusBlock then return(COMMA) else skip_until_eol;
  30:
                        if NotInCPlusBlock then return(LECKKLAMMER) else skip_until_eol;
  31:
                        if NotInCPlusBlock then return(RECKKLAMMER) else skip_until_eol;
  32:
                        if NotInCPlusBlock then
                           begin
                             inc(arglevel);
                             return(LKLAMMER);
                           end
                        else
                           skip_until_eol;
  33:
                        if NotInCPlusBlock then
                           begin
                             dec(arglevel);
                             return(RKLAMMER);
                           end
                         else
                           skip_until_eol;
  34:
                        if NotInCPlusBlock then return(STAR) else skip_until_eol;
  35:
                        if NotInCPlusBlock then return(ELLIPSIS) else skip_until_eol;
  36:
                        if NotInCPlusBlock then
                          if in_define then
                            return(POINT)
                          else
                            return(256);
  37:
                        if NotInCPlusBlock then return(_ASSIGN) else skip_until_eol;
  38:
                        if NotInCPlusBlock then return(EXTERN) else skip_until_eol;
  39:
                        if NotInCPlusBlock then
                        begin
                          if Win32headers then
                            return(STDCALL)
                          else
                            return(ID);
                        end
                        else
                        begin
                          skip_until_eol;
                        end;
  40:
                        if NotInCPlusBlock then
                        begin
                          if not Win32headers then
                            return(ID)
                          else
                            return(CDECL);
                        end
                        else
                        begin
                          skip_until_eol;
                        end;
  41:
                        if NotInCPlusBlock then
                        begin
                          if not Win32headers then
                            return(ID)
                          else
                            return(PASCAL);
                        end
                        else
                        begin
                          skip_until_eol;
                        end;
  42:
                        if NotInCPlusBlock then
                        begin
                          if not Win32headers then
                            return(ID)
                          else
                            return(_PACKED);
                        end
                        else
                        begin
                          skip_until_eol;
                        end;
  43:
                        if NotInCPlusBlock then
                        begin
                          if not Win32headers then
                            return(ID)
                          else
                            return(WINAPI);
                        end
                        else
                        begin
                          skip_until_eol;
                        end;
  44:
                        if NotInCPlusBlock then
                        begin
                          if not palmpilot then
                            return(ID)
                          else
                            return(SYS_TRAP);
                        end
                        else
                        begin
                          skip_until_eol;
                        end;
  45:
                        if NotInCPlusBlock then
                        begin
                          if not Win32headers then
                            return(ID)
                          else
                            return(WINGDIAPI);
                        end
                        else
                        begin
                          skip_until_eol;
                        end;
  46:
                        if NotInCPlusBlock then
                        begin
                          if not Win32headers then
                            return(ID)
                          else
                            return(CALLBACK);
                        end
                        else
                        begin
                          skip_until_eol;
                        end;
  47:
                        if NotInCPlusBlock then
                        begin
                          if not Win32headers then
                            return(ID)
                          else
                            return(CALLBACK);
                        end
                        else
                        begin
                          skip_until_eol;
                        end;
  48:
                        if NotInCPlusBlock then return(VOID) else skip_until_eol;
  49:
                        if NotInCPlusBlock then return(VOID) else skip_until_eol;
  50:
                                                             
                        begin
                          if not stripinfo then
                            writeln(outfile,'{ C++ extern C conditionnal removed }');
                        end;
  51:
                                                           
                        begin
                          if not stripinfo then
                            writeln(outfile,'{ C++ extern C conditionnal removed }');
                        end;
  52:
                                                
                        begin
                          if not stripinfo then
                            writeln(outfile,'{ C++ end of extern C conditionnal removed }');
                        end;
  53:
                                              
                        begin
                          if not stripinfo then
                            writeln(outfile,'{ C++ end of extern C conditionnal removed }');
                        end;
  54:
                               
                        begin
                          Inc(cplusblocklevel);
                        end;
  55:
                                 
                        begin
                          Inc(cplusblocklevel);
                        end;
  56:
             
                        begin
                           if cplusblocklevel > 0 then
                             Inc(cplusblocklevel)
                           else
                           begin
                             if cplusblocklevel < 0 then
                               Dec(cplusblocklevel);
                             write(outfile,'{$ifdef ');
                             copy_until_eol;
                             writeln(outfile,'}');
                             flush(outfile);
                           end;
                        end;
  57:
                        begin
                           if cplusblocklevel < -1 then
                           begin
                             writeln(outfile,'{$else}');
                             block_type:=bt_no;
                             flush(outfile);
                           end
                           else
                             case cplusblocklevel of
                             0 :
                                 begin
                                   writeln(outfile,'{$else}');
                                   block_type:=bt_no;
                                   flush(outfile);
                                 end;
                             1 : cplusblocklevel := -1;
                             -1 : cplusblocklevel := 1;
                             end;
                        end;
  58:
                        begin
                           if cplusblocklevel > 0 then
                           begin
                             Dec(cplusblocklevel);
                           end
                           else
                           begin
                             case cplusblocklevel of
                               0 : begin
                                     writeln(outfile,'{$endif}');
                                     block_type:=bt_no;
                                     flush(outfile);
                                   end;
                               -1 : begin
                                     cplusblocklevel :=0;
                                    end
                              else
                                inc(cplusblocklevel);
                              end;
                           end;

                        end;
  59:
                        begin
                           if cplusblocklevel < -1 then
                           begin
                             if not stripinfo then
                               write(outfile,'(*** was #elif ****)');
                             write(outfile,'{$else');
                             copy_until_eol;
                             writeln(outfile,'}');
                             block_type:=bt_no;
                             flush(outfile);
                           end
                           else
                             case cplusblocklevel of
                             0 :
                                 begin
                                   if not stripinfo then
                                     write(outfile,'(*** was #elif ****)');
                                   write(outfile,'{$else');
                                   copy_until_eol;
                                   writeln(outfile,'}');
                                   block_type:=bt_no;
                                   flush(outfile);
                                 end;
                             1 : cplusblocklevel := -1;
                             -1 : cplusblocklevel := 1;
                             end;
                        end;
  60:
                        begin
                           write(outfile,'{$undef');
                           copy_until_eol;
                           writeln(outfile,'}');
                           flush(outfile);
                        end;
  61:
                        begin
                           write(outfile,'{$error');
                           copy_until_eol;
                           writeln(outfile,'}');
                           flush(outfile);
                        end;
  62:
                        if NotInCPlusBlock then
                           begin
                             write(outfile,'{$include');
                             copy_until_eol;
                             writeln(outfile,'}');
                             flush(outfile);
                             block_type:=bt_no;
                           end
                        else
                          skip_until_eol;
  63:
                        begin
                           if cplusblocklevel > 0 then
                             Inc(cplusblocklevel)
                           else
                           begin
                             if cplusblocklevel < 0 then
                               Dec(cplusblocklevel);
                             write(outfile,'{$if');
                             copy_until_eol;
                             writeln(outfile,'}');
                             flush(outfile);
                             block_type:=bt_no;
                           end;
                        end;
  64:
                        if NotInCPlusBlock then
                          (* preprocessor line info *)
                          repeat
                            c:=get_char;
                            case c of
                              newline :
                                begin
                                  unget_char(c);
                                  exit;
                                end;
                              #0 :
                                commenteof;
                            end;
                          until false
                        else
                          skip_until_eol;
  65:
                        begin
                           if not stripinfo then
                            begin
                              write(outfile,'(** unsupported pragma');
                              write(outfile,'#pragma');
                              copy_until_eol;
                              writeln(outfile,'*)');
                              flush(outfile);
                            end
                           else
                            skip_until_eol;
                           block_type:=bt_no;
                        end;
  66:
                        if NotInCPlusBlock then
                           begin
                             commentstr:='';
                             in_define:=true;
                             in_space_define:=1;
                             return(DEFINE);
                           end
                        else
                          skip_until_eol;
  67:
                        if NotInCPlusBlock then return(_CHAR) else skip_until_eol;
  68:
                        if NotInCPlusBlock then return(UNION) else skip_until_eol;
  69:
                        if NotInCPlusBlock then return(ENUM) else skip_until_eol;
  70:
                        if NotInCPlusBlock then return(STRUCT) else skip_until_eol;
  71:
                        if NotInCPlusBlock then return(LGKLAMMER) else skip_until_eol;
  72:
                        if NotInCPlusBlock then return(RGKLAMMER) else skip_until_eol;
  73:
                        if NotInCPlusBlock then return(TYPEDEF) else skip_until_eol;
  74:
                        if NotInCPlusBlock then return(INT) else skip_until_eol;
  75:
                        if NotInCPlusBlock then return(SHORT) else skip_until_eol;
  76:
                        if NotInCPlusBlock then return(LONG) else skip_until_eol;
  77:
                        if NotInCPlusBlock then return(SIGNED) else skip_until_eol;
  78:
                        if NotInCPlusBlock then return(UNSIGNED) else skip_until_eol;
  79:
                        if NotInCPlusBlock then return(INT8) else skip_until_eol;
  80:
                        if NotInCPlusBlock then return(INT16) else skip_until_eol;
  81:
                        if NotInCPlusBlock then return(INT32) else skip_until_eol;
  82:
                        if NotInCPlusBlock then return(INT64) else skip_until_eol;
  83:
                        if NotInCPlusBlock then return(INT8) else skip_until_eol;
  84:
                        if NotInCPlusBlock then return(INT16) else skip_until_eol;
  85:
                        if NotInCPlusBlock then return(INT32) else skip_until_eol;
  86:
                        if NotInCPlusBlock then return(INT64) else skip_until_eol;
  87:
                        if NotInCPlusBlock then return(FLOAT) else skip_until_eol;
  88:
                        if NotInCPlusBlock then return(_CONST) else skip_until_eol;
  89:
                        if NotInCPlusBlock then return(_CONST) else skip_until_eol;
  90:
                        if NotInCPlusBlock then return(_FAR) else skip_until_eol;
  91:
                        if NotInCPlusBlock then return(_FAR) else skip_until_eol;
  92:
                        if NotInCPlusBlock then return(_NEAR) else skip_until_eol;
  93:
                        if NotInCPlusBlock then return(_NEAR) else skip_until_eol;
  94:
                        if NotInCPlusBlock then return(_HUGE) else skip_until_eol;
  95:
                        if NotInCPlusBlock then return(_HUGE) else skip_until_eol;
  96:
                        if NotInCPlusBlock then return(_WHILE) else skip_until_eol;
  97:
                        if NotInCPlusBlock then
                           begin
                             if in_space_define=1 then
                               in_space_define:=2;
                             return(ID);
                          end
                          else
                            skip_until_eol;
  98:
                        if NotInCPlusBlock then return(SEMICOLON) else skip_until_eol;
  99:
                        if NotInCPlusBlock then
                        begin
                           if (arglevel=0) and (in_space_define=2) then
                            begin
                              in_space_define:=0;
                              return(SPACE_DEFINE);
                            end;
                        end
                        else
                          skip_until_eol;
  100:
                        begin
                           if in_define then
                            begin
                              in_space_define:=0;
                              if cont_line then
                              begin
                                cont_line:=false;
                              end
                              else
                              begin
                                in_define:=false;
                                if NotInCPlusBlock then
                                  return(NEW_LINE)
                                else
                                  skip_until_eol
                              end;
                            end;
                       end;
  101:
                       begin
                           if in_define then
                           begin
                             cont_line:=true;
                           end
                           else
                           begin
                             writeln('Unexpected wrap of line ',yylineno);
                             writeln('"',yyline,'"');
                             return(256);
                           end;
                       end;
  102:
                       begin
                           writeln('Illegal character in line ',yylineno);
                           writeln('"',yyline,'"');
                           return(256);
                        end;
  end;
end(*yyaction*);

(* DFA table: *)

type YYTRec = record
                cc : set of Char;
                s  : Integer;
              end;

const

yynmarks   = 343;
yynmatches = 343;
yyntrans   = 642;
yynstates  = 369;

yyk : array [1..yynmarks] of Integer = (
  { 0: }
  { 1: }
  { 2: }
  25,
  102,
  { 3: }
  102,
  { 4: }
  102,
  { 5: }
  97,
  102,
  { 6: }
  7,
  9,
  102,
  { 7: }
  7,
  9,
  102,
  { 8: }
  11,
  102,
  { 9: }
  37,
  102,
  { 10: }
  24,
  102,
  { 11: }
  19,
  102,
  { 12: }
  20,
  102,
  { 13: }
  102,
  { 14: }
  21,
  102,
  { 15: }
  22,
  102,
  { 16: }
  23,
  102,
  { 17: }
  26,
  102,
  { 18: }
  27,
  102,
  { 19: }
  28,
  102,
  { 20: }
  29,
  102,
  { 21: }
  30,
  102,
  { 22: }
  31,
  102,
  { 23: }
  32,
  102,
  { 24: }
  33,
  102,
  { 25: }
  34,
  102,
  { 26: }
  36,
  102,
  { 27: }
  97,
  102,
  { 28: }
  97,
  102,
  { 29: }
  97,
  102,
  { 30: }
  97,
  102,
  { 31: }
  97,
  102,
  { 32: }
  97,
  102,
  { 33: }
  97,
  102,
  { 34: }
  97,
  102,
  { 35: }
  97,
  102,
  { 36: }
  97,
  102,
  { 37: }
  97,
  102,
  { 38: }
  71,
  102,
  { 39: }
  72,
  102,
  { 40: }
  97,
  102,
  { 41: }
  97,
  102,
  { 42: }
  97,
  102,
  { 43: }
  97,
  102,
  { 44: }
  97,
  102,
  { 45: }
  97,
  102,
  { 46: }
  97,
  102,
  { 47: }
  97,
  102,
  { 48: }
  97,
  102,
  { 49: }
  97,
  102,
  { 50: }
  97,
  102,
  { 51: }
  97,
  102,
  { 52: }
  98,
  102,
  { 53: }
  99,
  102,
  { 54: }
  100,
  { 55: }
  101,
  102,
  { 56: }
  102,
  { 57: }
  1,
  { 58: }
  2,
  { 59: }
  { 60: }
  3,
  { 61: }
  { 62: }
  4,
  { 63: }
  { 64: }
  { 65: }
  97,
  { 66: }
  7,
  9,
  { 67: }
  7,
  { 68: }
  7,
  { 69: }
  { 70: }
  { 71: }
  8,
  { 72: }
  10,
  { 73: }
  12,
  { 74: }
  13,
  { 75: }
  14,
  { 76: }
  16,
  { 77: }
  15,
  { 78: }
  18,
  { 79: }
  17,
  { 80: }
  { 81: }
  { 82: }
  { 83: }
  { 84: }
  { 85: }
  { 86: }
  { 87: }
  { 88: }
  97,
  { 89: }
  97,
  { 90: }
  97,
  { 91: }
  97,
  { 92: }
  97,
  { 93: }
  97,
  { 94: }
  97,
  { 95: }
  97,
  { 96: }
  97,
  { 97: }
  97,
  { 98: }
  97,
  { 99: }
  97,
  { 100: }
  97,
  { 101: }
  97,
  { 102: }
  97,
  { 103: }
  97,
  { 104: }
  97,
  { 105: }
  97,
  { 106: }
  97,
  { 107: }
  97,
  { 108: }
  97,
  { 109: }
  97,
  { 110: }
  97,
  { 111: }
  97,
  { 112: }
  97,
  { 113: }
  97,
  { 114: }
  97,
  { 115: }
  97,
  { 116: }
  97,
  { 117: }
  97,
  { 118: }
  { 119: }
  5,
  { 120: }
  6,
  { 121: }
  9,
  { 122: }
  { 123: }
  9,
  { 124: }
  8,
  { 125: }
  8,
  { 126: }
  63,
  { 127: }
  { 128: }
  { 129: }
  { 130: }
  { 131: }
  { 132: }
  { 133: }
  { 134: }
  { 135: }
  { 136: }
  35,
  { 137: }
  97,
  { 138: }
  97,
  { 139: }
  97,
  { 140: }
  97,
  { 141: }
  97,
  { 142: }
  97,
  { 143: }
  97,
  { 144: }
  97,
  { 145: }
  97,
  { 146: }
  97,
  { 147: }
  97,
  { 148: }
  97,
  { 149: }
  97,
  { 150: }
  97,
  { 151: }
  97,
  { 152: }
  97,
  { 153: }
  97,
  { 154: }
  97,
  { 155: }
  97,
  { 156: }
  97,
  { 157: }
  97,
  { 158: }
  74,
  97,
  { 159: }
  97,
  { 160: }
  97,
  { 161: }
  97,
  { 162: }
  91,
  97,
  { 163: }
  90,
  97,
  { 164: }
  97,
  { 165: }
  97,
  { 166: }
  97,
  { 167: }
  97,
  { 168: }
  97,
  { 169: }
  { 170: }
  { 171: }
  63,
  { 172: }
  { 173: }
  { 174: }
  { 175: }
  { 176: }
  { 177: }
  64,
  { 178: }
  { 179: }
  { 180: }
  97,
  { 181: }
  69,
  97,
  { 182: }
  97,
  { 183: }
  97,
  { 184: }
  97,
  { 185: }
  97,
  { 186: }
  97,
  { 187: }
  97,
  { 188: }
  97,
  { 189: }
  97,
  { 190: }
  97,
  { 191: }
  97,
  { 192: }
  48,
  97,
  { 193: }
  49,
  97,
  { 194: }
  67,
  97,
  { 195: }
  97,
  { 196: }
  97,
  { 197: }
  97,
  { 198: }
  97,
  { 199: }
  97,
  { 200: }
  97,
  { 201: }
  97,
  { 202: }
  83,
  97,
  { 203: }
  97,
  { 204: }
  97,
  { 205: }
  97,
  { 206: }
  76,
  97,
  { 207: }
  97,
  { 208: }
  97,
  { 209: }
  92,
  97,
  { 210: }
  93,
  97,
  { 211: }
  94,
  97,
  { 212: }
  95,
  97,
  { 213: }
  97,
  { 214: }
  { 215: }
  { 216: }
  57,
  { 217: }
  59,
  { 218: }
  { 219: }
  { 220: }
  { 221: }
  { 222: }
  { 223: }
  97,
  { 224: }
  97,
  { 225: }
  97,
  { 226: }
  40,
  97,
  { 227: }
  97,
  { 228: }
  89,
  97,
  { 229: }
  97,
  { 230: }
  97,
  { 231: }
  97,
  { 232: }
  97,
  { 233: }
  97,
  { 234: }
  88,
  97,
  { 235: }
  68,
  97,
  { 236: }
  97,
  { 237: }
  97,
  { 238: }
  75,
  97,
  { 239: }
  97,
  { 240: }
  97,
  { 241: }
  84,
  97,
  { 242: }
  85,
  97,
  { 243: }
  86,
  97,
  { 244: }
  97,
  { 245: }
  87,
  97,
  { 246: }
  96,
  97,
  { 247: }
  { 248: }
  { 249: }
  58,
  { 250: }
  61,
  { 251: }
  60,
  { 252: }
  { 253: }
  { 254: }
  38,
  97,
  { 255: }
  97,
  { 256: }
  97,
  { 257: }
  97,
  { 258: }
  41,
  97,
  { 259: }
  42,
  97,
  { 260: }
  43,
  97,
  { 261: }
  97,
  { 262: }
  97,
  { 263: }
  97,
  { 264: }
  70,
  97,
  { 265: }
  77,
  97,
  { 266: }
  97,
  { 267: }
  79,
  97,
  { 268: }
  97,
  { 269: }
  97,
  { 270: }
  97,
  { 271: }
  56,
  { 272: }
  { 273: }
  { 274: }
  { 275: }
  65,
  { 276: }
  66,
  { 277: }
  39,
  97,
  { 278: }
  97,
  { 279: }
  97,
  { 280: }
  97,
  { 281: }
  97,
  { 282: }
  97,
  { 283: }
  73,
  97,
  { 284: }
  80,
  97,
  { 285: }
  81,
  97,
  { 286: }
  82,
  97,
  { 287: }
  { 288: }
  { 289: }
  { 290: }
  62,
  { 291: }
  44,
  97,
  { 292: }
  46,
  97,
  { 293: }
  97,
  { 294: }
  47,
  97,
  { 295: }
  78,
  97,
  { 296: }
  { 297: }
  { 298: }
  45,
  97,
  { 299: }
  { 300: }
  { 301: }
  { 302: }
  { 303: }
  { 304: }
  { 305: }
  { 306: }
  { 307: }
  { 308: }
  { 309: }
  { 310: }
  54,
  { 311: }
  { 312: }
  { 313: }
  55,
  { 314: }
  { 315: }
  { 316: }
  { 317: }
  { 318: }
  { 319: }
  { 320: }
  { 321: }
  { 322: }
  { 323: }
  { 324: }
  { 325: }
  { 326: }
  { 327: }
  { 328: }
  { 329: }
  { 330: }
  { 331: }
  { 332: }
  { 333: }
  { 334: }
  { 335: }
  { 336: }
  { 337: }
  { 338: }
  { 339: }
  { 340: }
  { 341: }
  { 342: }
  53,
  { 343: }
  { 344: }
  { 345: }
  { 346: }
  { 347: }
  52,
  { 348: }
  { 349: }
  { 350: }
  { 351: }
  { 352: }
  { 353: }
  { 354: }
  { 355: }
  { 356: }
  { 357: }
  { 358: }
  { 359: }
  { 360: }
  { 361: }
  { 362: }
  { 363: }
  { 364: }
  { 365: }
  { 366: }
  51,
  { 367: }
  { 368: }
  50
);

yym : array [1..yynmatches] of Integer = (
{ 0: }
{ 1: }
{ 2: }
  25,
  102,
{ 3: }
  102,
{ 4: }
  102,
{ 5: }
  97,
  102,
{ 6: }
  7,
  9,
  102,
{ 7: }
  7,
  9,
  102,
{ 8: }
  11,
  102,
{ 9: }
  37,
  102,
{ 10: }
  24,
  102,
{ 11: }
  19,
  102,
{ 12: }
  20,
  102,
{ 13: }
  102,
{ 14: }
  21,
  102,
{ 15: }
  22,
  102,
{ 16: }
  23,
  102,
{ 17: }
  26,
  102,
{ 18: }
  27,
  102,
{ 19: }
  28,
  102,
{ 20: }
  29,
  102,
{ 21: }
  30,
  102,
{ 22: }
  31,
  102,
{ 23: }
  32,
  102,
{ 24: }
  33,
  102,
{ 25: }
  34,
  102,
{ 26: }
  36,
  102,
{ 27: }
  97,
  102,
{ 28: }
  97,
  102,
{ 29: }
  97,
  102,
{ 30: }
  97,
  102,
{ 31: }
  97,
  102,
{ 32: }
  97,
  102,
{ 33: }
  97,
  102,
{ 34: }
  97,
  102,
{ 35: }
  97,
  102,
{ 36: }
  97,
  102,
{ 37: }
  97,
  102,
{ 38: }
  71,
  102,
{ 39: }
  72,
  102,
{ 40: }
  97,
  102,
{ 41: }
  97,
  102,
{ 42: }
  97,
  102,
{ 43: }
  97,
  102,
{ 44: }
  97,
  102,
{ 45: }
  97,
  102,
{ 46: }
  97,
  102,
{ 47: }
  97,
  102,
{ 48: }
  97,
  102,
{ 49: }
  97,
  102,
{ 50: }
  97,
  102,
{ 51: }
  97,
  102,
{ 52: }
  98,
  102,
{ 53: }
  99,
  102,
{ 54: }
  100,
{ 55: }
  102,
{ 56: }
  102,
{ 57: }
  1,
{ 58: }
  2,
{ 59: }
{ 60: }
  3,
{ 61: }
{ 62: }
  4,
{ 63: }
{ 64: }
{ 65: }
  97,
{ 66: }
  7,
  9,
{ 67: }
  7,
{ 68: }
  7,
{ 69: }
{ 70: }
{ 71: }
  8,
{ 72: }
  10,
{ 73: }
  12,
{ 74: }
  13,
{ 75: }
  14,
{ 76: }
  16,
{ 77: }
  15,
{ 78: }
  18,
{ 79: }
  17,
{ 80: }
{ 81: }
{ 82: }
{ 83: }
{ 84: }
{ 85: }
{ 86: }
{ 87: }
{ 88: }
  97,
{ 89: }
  97,
{ 90: }
  97,
{ 91: }
  97,
{ 92: }
  97,
{ 93: }
  97,
{ 94: }
  97,
{ 95: }
  97,
{ 96: }
  97,
{ 97: }
  97,
{ 98: }
  97,
{ 99: }
  97,
{ 100: }
  97,
{ 101: }
  97,
{ 102: }
  97,
{ 103: }
  97,
{ 104: }
  97,
{ 105: }
  97,
{ 106: }
  97,
{ 107: }
  97,
{ 108: }
  97,
{ 109: }
  97,
{ 110: }
  97,
{ 111: }
  97,
{ 112: }
  97,
{ 113: }
  97,
{ 114: }
  97,
{ 115: }
  97,
{ 116: }
  97,
{ 117: }
  97,
{ 118: }
  101,
{ 119: }
  5,
{ 120: }
  6,
{ 121: }
  9,
{ 122: }
{ 123: }
  9,
{ 124: }
  8,
{ 125: }
  8,
{ 126: }
  63,
{ 127: }
{ 128: }
{ 129: }
{ 130: }
{ 131: }
{ 132: }
{ 133: }
{ 134: }
{ 135: }
{ 136: }
  35,
{ 137: }
  97,
{ 138: }
  97,
{ 139: }
  97,
{ 140: }
  97,
{ 141: }
  97,
{ 142: }
  97,
{ 143: }
  97,
{ 144: }
  97,
{ 145: }
  97,
{ 146: }
  97,
{ 147: }
  97,
{ 148: }
  97,
{ 149: }
  97,
{ 150: }
  97,
{ 151: }
  97,
{ 152: }
  97,
{ 153: }
  97,
{ 154: }
  97,
{ 155: }
  97,
{ 156: }
  97,
{ 157: }
  97,
{ 158: }
  74,
  97,
{ 159: }
  97,
{ 160: }
  97,
{ 161: }
  97,
{ 162: }
  91,
  97,
{ 163: }
  90,
  97,
{ 164: }
  97,
{ 165: }
  97,
{ 166: }
  97,
{ 167: }
  97,
{ 168: }
  97,
{ 169: }
{ 170: }
{ 171: }
  63,
{ 172: }
{ 173: }
{ 174: }
{ 175: }
{ 176: }
{ 177: }
  64,
{ 178: }
{ 179: }
{ 180: }
  97,
{ 181: }
  69,
  97,
{ 182: }
  97,
{ 183: }
  97,
{ 184: }
  97,
{ 185: }
  97,
{ 186: }
  97,
{ 187: }
  97,
{ 188: }
  97,
{ 189: }
  97,
{ 190: }
  97,
{ 191: }
  97,
{ 192: }
  48,
  97,
{ 193: }
  49,
  97,
{ 194: }
  67,
  97,
{ 195: }
  97,
{ 196: }
  97,
{ 197: }
  97,
{ 198: }
  97,
{ 199: }
  97,
{ 200: }
  97,
{ 201: }
  97,
{ 202: }
  83,
  97,
{ 203: }
  97,
{ 204: }
  97,
{ 205: }
  97,
{ 206: }
  76,
  97,
{ 207: }
  97,
{ 208: }
  97,
{ 209: }
  92,
  97,
{ 210: }
  93,
  97,
{ 211: }
  94,
  97,
{ 212: }
  95,
  97,
{ 213: }
  97,
{ 214: }
{ 215: }
{ 216: }
  57,
{ 217: }
  59,
{ 218: }
{ 219: }
{ 220: }
{ 221: }
{ 222: }
{ 223: }
  97,
{ 224: }
  97,
{ 225: }
  97,
{ 226: }
  40,
  97,
{ 227: }
  97,
{ 228: }
  89,
  97,
{ 229: }
  97,
{ 230: }
  97,
{ 231: }
  97,
{ 232: }
  97,
{ 233: }
  97,
{ 234: }
  88,
  97,
{ 235: }
  68,
  97,
{ 236: }
  97,
{ 237: }
  97,
{ 238: }
  75,
  97,
{ 239: }
  97,
{ 240: }
  97,
{ 241: }
  84,
  97,
{ 242: }
  85,
  97,
{ 243: }
  86,
  97,
{ 244: }
  97,
{ 245: }
  87,
  97,
{ 246: }
  96,
  97,
{ 247: }
{ 248: }
{ 249: }
  58,
{ 250: }
  61,
{ 251: }
  60,
{ 252: }
{ 253: }
{ 254: }
  38,
  97,
{ 255: }
  97,
{ 256: }
  97,
{ 257: }
  97,
{ 258: }
  41,
  97,
{ 259: }
  42,
  97,
{ 260: }
  43,
  97,
{ 261: }
  97,
{ 262: }
  97,
{ 263: }
  97,
{ 264: }
  70,
  97,
{ 265: }
  77,
  97,
{ 266: }
  97,
{ 267: }
  79,
  97,
{ 268: }
  97,
{ 269: }
  97,
{ 270: }
  97,
{ 271: }
  56,
{ 272: }
{ 273: }
{ 274: }
{ 275: }
  65,
{ 276: }
  66,
{ 277: }
  39,
  97,
{ 278: }
  97,
{ 279: }
  97,
{ 280: }
  97,
{ 281: }
  97,
{ 282: }
  97,
{ 283: }
  73,
  97,
{ 284: }
  80,
  97,
{ 285: }
  81,
  97,
{ 286: }
  82,
  97,
{ 287: }
{ 288: }
{ 289: }
{ 290: }
  62,
{ 291: }
  44,
  97,
{ 292: }
  46,
  97,
{ 293: }
  97,
{ 294: }
  47,
  97,
{ 295: }
  78,
  97,
{ 296: }
{ 297: }
{ 298: }
  45,
  97,
{ 299: }
{ 300: }
{ 301: }
{ 302: }
{ 303: }
{ 304: }
{ 305: }
{ 306: }
{ 307: }
{ 308: }
{ 309: }
{ 310: }
  54,
{ 311: }
{ 312: }
{ 313: }
  55,
{ 314: }
{ 315: }
{ 316: }
{ 317: }
{ 318: }
{ 319: }
{ 320: }
{ 321: }
{ 322: }
{ 323: }
{ 324: }
{ 325: }
{ 326: }
{ 327: }
{ 328: }
{ 329: }
{ 330: }
{ 331: }
{ 332: }
{ 333: }
{ 334: }
{ 335: }
{ 336: }
{ 337: }
{ 338: }
{ 339: }
{ 340: }
{ 341: }
{ 342: }
  53,
{ 343: }
{ 344: }
{ 345: }
{ 346: }
{ 347: }
  52,
{ 348: }
{ 349: }
{ 350: }
{ 351: }
{ 352: }
{ 353: }
{ 354: }
{ 355: }
{ 356: }
{ 357: }
{ 358: }
{ 359: }
{ 360: }
{ 361: }
{ 362: }
{ 363: }
{ 364: }
{ 365: }
{ 366: }
  51,
{ 367: }
{ 368: }
  50
);

yyt : array [1..yyntrans] of YYTrec = (
{ 0: }
  ( cc: [ #1..#8,#11,#13..#31,'$','%','@','^','`',#127..#255 ]; s: 56),
  ( cc: [ #9,#12,' ' ]; s: 53),
  ( cc: [ #10 ]; s: 54),
  ( cc: [ '!' ]; s: 10),
  ( cc: [ '"' ]; s: 3),
  ( cc: [ '#' ]; s: 13),
  ( cc: [ '&' ]; s: 15),
  ( cc: [ '''' ]; s: 4),
  ( cc: [ '(' ]; s: 23),
  ( cc: [ ')' ]; s: 24),
  ( cc: [ '*' ]; s: 25),
  ( cc: [ '+' ]; s: 17),
  ( cc: [ ',' ]; s: 20),
  ( cc: [ '-' ]; s: 8),
  ( cc: [ '.' ]; s: 26),
  ( cc: [ '/' ]; s: 2),
  ( cc: [ '0' ]; s: 7),
  ( cc: [ '1'..'9' ]; s: 6),
  ( cc: [ ':' ]; s: 19),
  ( cc: [ ';' ]; s: 52),
  ( cc: [ '<' ]; s: 12),
  ( cc: [ '=' ]; s: 9),
  ( cc: [ '>' ]; s: 11),
  ( cc: [ '?' ]; s: 18),
  ( cc: [ 'A','B','D','G','I'..'K','M','O','Q','R',
            'T','U','X'..'Z','a','b','d','g','j','k',
            'm','o'..'r','x'..'z' ]; s: 51),
  ( cc: [ 'C' ]; s: 29),
  ( cc: [ 'E' ]; s: 32),
  ( cc: [ 'F' ]; s: 45),
  ( cc: [ 'H' ]; s: 48),
  ( cc: [ 'L' ]; s: 5),
  ( cc: [ 'N' ]; s: 46),
  ( cc: [ 'P' ]; s: 30),
  ( cc: [ 'S' ]; s: 28),
  ( cc: [ 'V' ]; s: 34),
  ( cc: [ 'W' ]; s: 31),
  ( cc: [ '[' ]; s: 21),
  ( cc: [ '\' ]; s: 55),
  ( cc: [ ']' ]; s: 22),
  ( cc: [ '_' ]; s: 43),
  ( cc: [ 'c' ]; s: 35),
  ( cc: [ 'e' ]; s: 27),
  ( cc: [ 'f' ]; s: 44),
  ( cc: [ 'h' ]; s: 49),
  ( cc: [ 'i' ]; s: 41),
  ( cc: [ 'l' ]; s: 42),
  ( cc: [ 'n' ]; s: 47),
  ( cc: [ 's' ]; s: 37),
  ( cc: [ 't' ]; s: 40),
  ( cc: [ 'u' ]; s: 36),
  ( cc: [ 'v' ]; s: 33),
  ( cc: [ 'w' ]; s: 50),
  ( cc: [ '{' ]; s: 38),
  ( cc: [ '|' ]; s: 14),
  ( cc: [ '}' ]; s: 39),
  ( cc: [ '~' ]; s: 16),
{ 1: }
  ( cc: [ #1..#8,#11,#13..#31,'$','%','@','^','`',#127..#255 ]; s: 56),
  ( cc: [ #9,#12,' ' ]; s: 53),
  ( cc: [ #10 ]; s: 54),
  ( cc: [ '!' ]; s: 10),
  ( cc: [ '"' ]; s: 3),
  ( cc: [ '#' ]; s: 13),
  ( cc: [ '&' ]; s: 15),
  ( cc: [ '''' ]; s: 4),
  ( cc: [ '(' ]; s: 23),
  ( cc: [ ')' ]; s: 24),
  ( cc: [ '*' ]; s: 25),
  ( cc: [ '+' ]; s: 17),
  ( cc: [ ',' ]; s: 20),
  ( cc: [ '-' ]; s: 8),
  ( cc: [ '.' ]; s: 26),
  ( cc: [ '/' ]; s: 2),
  ( cc: [ '0' ]; s: 7),
  ( cc: [ '1'..'9' ]; s: 6),
  ( cc: [ ':' ]; s: 19),
  ( cc: [ ';' ]; s: 52),
  ( cc: [ '<' ]; s: 12),
  ( cc: [ '=' ]; s: 9),
  ( cc: [ '>' ]; s: 11),
  ( cc: [ '?' ]; s: 18),
  ( cc: [ 'A','B','D','G','I'..'K','M','O','Q','R',
            'T','U','X'..'Z','a','b','d','g','j','k',
            'm','o'..'r','x'..'z' ]; s: 51),
  ( cc: [ 'C' ]; s: 29),
  ( cc: [ 'E' ]; s: 32),
  ( cc: [ 'F' ]; s: 45),
  ( cc: [ 'H' ]; s: 48),
  ( cc: [ 'L' ]; s: 5),
  ( cc: [ 'N' ]; s: 46),
  ( cc: [ 'P' ]; s: 30),
  ( cc: [ 'S' ]; s: 28),
  ( cc: [ 'V' ]; s: 34),
  ( cc: [ 'W' ]; s: 31),
  ( cc: [ '[' ]; s: 21),
  ( cc: [ '\' ]; s: 55),
  ( cc: [ ']' ]; s: 22),
  ( cc: [ '_' ]; s: 43),
  ( cc: [ 'c' ]; s: 35),
  ( cc: [ 'e' ]; s: 27),
  ( cc: [ 'f' ]; s: 44),
  ( cc: [ 'h' ]; s: 49),
  ( cc: [ 'i' ]; s: 41),
  ( cc: [ 'l' ]; s: 42),
  ( cc: [ 'n' ]; s: 47),
  ( cc: [ 's' ]; s: 37),
  ( cc: [ 't' ]; s: 40),
  ( cc: [ 'u' ]; s: 36),
  ( cc: [ 'v' ]; s: 33),
  ( cc: [ 'w' ]; s: 50),
  ( cc: [ '{' ]; s: 38),
  ( cc: [ '|' ]; s: 14),
  ( cc: [ '}' ]; s: 39),
  ( cc: [ '~' ]; s: 16),
{ 2: }
  ( cc: [ '*' ]; s: 57),
  ( cc: [ '/' ]; s: 58),
{ 3: }
  ( cc: [ #1..'!','#'..#255 ]; s: 59),
  ( cc: [ '"' ]; s: 60),
{ 4: }
  ( cc: [ #1..'&','('..#255 ]; s: 61),
  ( cc: [ '''' ]; s: 62),
{ 5: }
  ( cc: [ '"' ]; s: 63),
  ( cc: [ '''' ]; s: 64),
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 6: }
  ( cc: [ '.' ]; s: 69),
  ( cc: [ '0'..'9' ]; s: 66),
  ( cc: [ 'E','e' ]; s: 70),
  ( cc: [ 'L','l' ]; s: 68),
  ( cc: [ 'U','u' ]; s: 67),
{ 7: }
  ( cc: [ '.' ]; s: 69),
  ( cc: [ '0'..'9' ]; s: 66),
  ( cc: [ 'E','e' ]; s: 70),
  ( cc: [ 'L','l' ]; s: 68),
  ( cc: [ 'U','u' ]; s: 67),
  ( cc: [ 'x' ]; s: 71),
{ 8: }
  ( cc: [ '>' ]; s: 72),
{ 9: }
  ( cc: [ '=' ]; s: 73),
{ 10: }
  ( cc: [ '=' ]; s: 74),
{ 11: }
  ( cc: [ '=' ]; s: 75),
  ( cc: [ '>' ]; s: 76),
{ 12: }
  ( cc: [ '<' ]; s: 78),
  ( cc: [ '=' ]; s: 77),
{ 13: }
  ( cc: [ #9 ]; s: 81),
  ( cc: [ ' ' ]; s: 84),
  ( cc: [ '#' ]; s: 79),
  ( cc: [ 'd' ]; s: 86),
  ( cc: [ 'e' ]; s: 82),
  ( cc: [ 'i' ]; s: 80),
  ( cc: [ 'p' ]; s: 85),
  ( cc: [ 'u' ]; s: 83),
{ 14: }
{ 15: }
{ 16: }
{ 17: }
{ 18: }
{ 19: }
{ 20: }
{ 21: }
{ 22: }
{ 23: }
{ 24: }
{ 25: }
{ 26: }
  ( cc: [ '.' ]; s: 87),
{ 27: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'m','o'..'w','y','z' ]; s: 65),
  ( cc: [ 'n' ]; s: 89),
  ( cc: [ 'x' ]; s: 88),
{ 28: }
  ( cc: [ '0'..'9','A'..'S','U'..'X','Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'T' ]; s: 90),
  ( cc: [ 'Y' ]; s: 91),
{ 29: }
  ( cc: [ '0'..'9','B','C','E'..'N','P'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'A' ]; s: 93),
  ( cc: [ 'D' ]; s: 92),
  ( cc: [ 'O' ]; s: 94),
{ 30: }
  ( cc: [ '0'..'9','B'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'A' ]; s: 95),
{ 31: }
  ( cc: [ '0'..'9','A'..'H','J'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'I' ]; s: 96),
{ 32: }
  ( cc: [ '0'..'9','A'..'W','Y','Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'X' ]; s: 97),
{ 33: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'n','p'..'z' ]; s: 65),
  ( cc: [ 'o' ]; s: 98),
{ 34: }
  ( cc: [ '0'..'9','A'..'N','P'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'O' ]; s: 99),
{ 35: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'g','i'..'n','p'..'z' ]; s: 65),
  ( cc: [ 'h' ]; s: 100),
  ( cc: [ 'o' ]; s: 101),
{ 36: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'m','o'..'z' ]; s: 65),
  ( cc: [ 'n' ]; s: 102),
{ 37: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'g','j'..'s','u'..'z' ]; s: 65),
  ( cc: [ 'h' ]; s: 104),
  ( cc: [ 'i' ]; s: 105),
  ( cc: [ 't' ]; s: 103),
{ 38: }
{ 39: }
{ 40: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'x','z' ]; s: 65),
  ( cc: [ 'y' ]; s: 106),
{ 41: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'m','o'..'z' ]; s: 65),
  ( cc: [ 'n' ]; s: 107),
{ 42: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'n','p'..'z' ]; s: 65),
  ( cc: [ 'o' ]; s: 108),
{ 43: }
  ( cc: [ '0'..'9','A'..'Z','a'..'z' ]; s: 65),
  ( cc: [ '_' ]; s: 109),
{ 44: }
  ( cc: [ '0'..'9','A'..'Z','_','b'..'k','m'..'z' ]; s: 65),
  ( cc: [ 'a' ]; s: 111),
  ( cc: [ 'l' ]; s: 110),
{ 45: }
  ( cc: [ '0'..'9','B'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'A' ]; s: 112),
{ 46: }
  ( cc: [ '0'..'9','A'..'D','F'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'E' ]; s: 113),
{ 47: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'d','f'..'z' ]; s: 65),
  ( cc: [ 'e' ]; s: 114),
{ 48: }
  ( cc: [ '0'..'9','A'..'T','V'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'U' ]; s: 115),
{ 49: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'t','v'..'z' ]; s: 65),
  ( cc: [ 'u' ]; s: 116),
{ 50: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'g','i'..'z' ]; s: 65),
  ( cc: [ 'h' ]; s: 117),
{ 51: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 52: }
{ 53: }
{ 54: }
{ 55: }
  ( cc: [ #10 ]; s: 118),
{ 56: }
{ 57: }
{ 58: }
{ 59: }
  ( cc: [ #1..'!','#'..#255 ]; s: 59),
  ( cc: [ '"' ]; s: 60),
{ 60: }
{ 61: }
  ( cc: [ #1..'&','('..#255 ]; s: 61),
  ( cc: [ '''' ]; s: 62),
{ 62: }
{ 63: }
  ( cc: [ #1..'!','#'..#255 ]; s: 63),
  ( cc: [ '"' ]; s: 119),
{ 64: }
  ( cc: [ #1..'&','('..#255 ]; s: 64),
  ( cc: [ '''' ]; s: 120),
{ 65: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 66: }
  ( cc: [ '.' ]; s: 69),
  ( cc: [ '0'..'9' ]; s: 66),
  ( cc: [ 'E','e' ]; s: 70),
  ( cc: [ 'L','l' ]; s: 68),
  ( cc: [ 'U','u' ]; s: 67),
{ 67: }
  ( cc: [ 'L','l' ]; s: 68),
{ 68: }
{ 69: }
  ( cc: [ '0'..'9' ]; s: 121),
{ 70: }
  ( cc: [ '+','-' ]; s: 122),
  ( cc: [ '0'..'9' ]; s: 123),
{ 71: }
  ( cc: [ '0'..'9','A'..'F','a'..'f' ]; s: 71),
  ( cc: [ 'L','l' ]; s: 125),
  ( cc: [ 'U','u' ]; s: 124),
{ 72: }
{ 73: }
{ 74: }
{ 75: }
{ 76: }
{ 77: }
{ 78: }
{ 79: }
{ 80: }
  ( cc: [ 'f' ]; s: 126),
  ( cc: [ 'n' ]; s: 127),
{ 81: }
  ( cc: [ #9,' ' ]; s: 81),
  ( cc: [ 'd' ]; s: 86),
  ( cc: [ 'e' ]; s: 82),
  ( cc: [ 'i' ]; s: 128),
  ( cc: [ 'p' ]; s: 85),
  ( cc: [ 'u' ]; s: 83),
{ 82: }
  ( cc: [ 'l' ]; s: 129),
  ( cc: [ 'n' ]; s: 130),
  ( cc: [ 'r' ]; s: 131),
{ 83: }
  ( cc: [ 'n' ]; s: 132),
{ 84: }
  ( cc: [ #9,' ' ]; s: 81),
  ( cc: [ '0'..'9' ]; s: 133),
  ( cc: [ 'd' ]; s: 86),
  ( cc: [ 'e' ]; s: 82),
  ( cc: [ 'i' ]; s: 128),
  ( cc: [ 'p' ]; s: 85),
  ( cc: [ 'u' ]; s: 83),
{ 85: }
  ( cc: [ 'r' ]; s: 134),
{ 86: }
  ( cc: [ 'e' ]; s: 135),
{ 87: }
  ( cc: [ '.' ]; s: 136),
{ 88: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'s','u'..'z' ]; s: 65),
  ( cc: [ 't' ]; s: 137),
{ 89: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'t','v'..'z' ]; s: 65),
  ( cc: [ 'u' ]; s: 138),
{ 90: }
  ( cc: [ '0'..'9','A'..'C','E'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'D' ]; s: 139),
{ 91: }
  ( cc: [ '0'..'9','A'..'R','T'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'S' ]; s: 140),
{ 92: }
  ( cc: [ '0'..'9','A'..'D','F'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'E' ]; s: 141),
{ 93: }
  ( cc: [ '0'..'9','A'..'K','M'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'L' ]; s: 142),
{ 94: }
  ( cc: [ '0'..'9','A'..'M','O'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'N' ]; s: 143),
{ 95: }
  ( cc: [ '0'..'9','A','B','D'..'R','T'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'C' ]; s: 145),
  ( cc: [ 'S' ]; s: 144),
{ 96: }
  ( cc: [ '0'..'9','A'..'M','O'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'N' ]; s: 146),
{ 97: }
  ( cc: [ '0'..'9','A'..'O','Q'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'P' ]; s: 147),
{ 98: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'h','j'..'z' ]; s: 65),
  ( cc: [ 'i' ]; s: 148),
{ 99: }
  ( cc: [ '0'..'9','A'..'H','J'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'I' ]; s: 149),
{ 100: }
  ( cc: [ '0'..'9','A'..'Z','_','b'..'z' ]; s: 65),
  ( cc: [ 'a' ]; s: 150),
{ 101: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'m','o'..'z' ]; s: 65),
  ( cc: [ 'n' ]; s: 151),
{ 102: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'h','j'..'r','t'..'z' ]; s: 65),
  ( cc: [ 'i' ]; s: 152),
  ( cc: [ 's' ]; s: 153),
{ 103: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'q','s'..'z' ]; s: 65),
  ( cc: [ 'r' ]; s: 154),
{ 104: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'n','p'..'z' ]; s: 65),
  ( cc: [ 'o' ]; s: 155),
{ 105: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'f','h'..'z' ]; s: 65),
  ( cc: [ 'g' ]; s: 156),
{ 106: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'o','q'..'z' ]; s: 65),
  ( cc: [ 'p' ]; s: 157),
{ 107: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'s','u'..'z' ]; s: 65),
  ( cc: [ 't' ]; s: 158),
{ 108: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'m','o'..'z' ]; s: 65),
  ( cc: [ 'n' ]; s: 159),
{ 109: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'h','j'..'z' ]; s: 65),
  ( cc: [ 'i' ]; s: 160),
{ 110: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'n','p'..'z' ]; s: 65),
  ( cc: [ 'o' ]; s: 161),
{ 111: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'q','s'..'z' ]; s: 65),
  ( cc: [ 'r' ]; s: 162),
{ 112: }
  ( cc: [ '0'..'9','A'..'Q','S'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'R' ]; s: 163),
{ 113: }
  ( cc: [ '0'..'9','B'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'A' ]; s: 164),
{ 114: }
  ( cc: [ '0'..'9','A'..'Z','_','b'..'z' ]; s: 65),
  ( cc: [ 'a' ]; s: 165),
{ 115: }
  ( cc: [ '0'..'9','A'..'F','H'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'G' ]; s: 166),
{ 116: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'f','h'..'z' ]; s: 65),
  ( cc: [ 'g' ]; s: 167),
{ 117: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'h','j'..'z' ]; s: 65),
  ( cc: [ 'i' ]; s: 168),
{ 118: }
{ 119: }
{ 120: }
{ 121: }
  ( cc: [ '0'..'9' ]; s: 121),
  ( cc: [ 'E','e' ]; s: 70),
{ 122: }
  ( cc: [ '0'..'9' ]; s: 123),
{ 123: }
  ( cc: [ '0'..'9' ]; s: 123),
{ 124: }
  ( cc: [ 'L','l' ]; s: 125),
{ 125: }
{ 126: }
  ( cc: [ 'd' ]; s: 169),
{ 127: }
  ( cc: [ 'c' ]; s: 170),
{ 128: }
  ( cc: [ 'f' ]; s: 171),
  ( cc: [ 'n' ]; s: 127),
{ 129: }
  ( cc: [ 'i' ]; s: 173),
  ( cc: [ 's' ]; s: 172),
{ 130: }
  ( cc: [ 'd' ]; s: 174),
{ 131: }
  ( cc: [ 'r' ]; s: 175),
{ 132: }
  ( cc: [ 'd' ]; s: 176),
{ 133: }
  ( cc: [ ' ' ]; s: 177),
  ( cc: [ '0'..'9' ]; s: 133),
{ 134: }
  ( cc: [ 'a' ]; s: 178),
{ 135: }
  ( cc: [ 'f' ]; s: 179),
{ 136: }
{ 137: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'d','f'..'z' ]; s: 65),
  ( cc: [ 'e' ]; s: 180),
{ 138: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'l','n'..'z' ]; s: 65),
  ( cc: [ 'm' ]; s: 181),
{ 139: }
  ( cc: [ '0'..'9','A','B','D'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'C' ]; s: 182),
{ 140: }
  ( cc: [ '0'..'9','A'..'Z','a'..'z' ]; s: 65),
  ( cc: [ '_' ]; s: 183),
{ 141: }
  ( cc: [ '0'..'9','A','B','D'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'C' ]; s: 184),
{ 142: }
  ( cc: [ '0'..'9','A'..'K','M'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'L' ]; s: 185),
{ 143: }
  ( cc: [ '0'..'9','A'..'R','T'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'S' ]; s: 186),
{ 144: }
  ( cc: [ '0'..'9','A','B','D'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'C' ]; s: 187),
{ 145: }
  ( cc: [ '0'..'9','A'..'J','L'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'K' ]; s: 188),
{ 146: }
  ( cc: [ '0'..'9','B'..'F','H'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'A' ]; s: 189),
  ( cc: [ 'G' ]; s: 190),
{ 147: }
  ( cc: [ '0'..'9','A'..'D','F'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'E' ]; s: 191),
{ 148: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'c','e'..'z' ]; s: 65),
  ( cc: [ 'd' ]; s: 192),
{ 149: }
  ( cc: [ '0'..'9','A'..'C','E'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'D' ]; s: 193),
{ 150: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'q','s'..'z' ]; s: 65),
  ( cc: [ 'r' ]; s: 194),
{ 151: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'r','t'..'z' ]; s: 65),
  ( cc: [ 's' ]; s: 195),
{ 152: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'n','p'..'z' ]; s: 65),
  ( cc: [ 'o' ]; s: 196),
{ 153: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'h','j'..'z' ]; s: 65),
  ( cc: [ 'i' ]; s: 197),
{ 154: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'t','v'..'z' ]; s: 65),
  ( cc: [ 'u' ]; s: 198),
{ 155: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'q','s'..'z' ]; s: 65),
  ( cc: [ 'r' ]; s: 199),
{ 156: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'m','o'..'z' ]; s: 65),
  ( cc: [ 'n' ]; s: 200),
{ 157: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'d','f'..'z' ]; s: 65),
  ( cc: [ 'e' ]; s: 201),
{ 158: }
  ( cc: [ '0','2','4','5','7','9','A'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ '1' ]; s: 203),
  ( cc: [ '3' ]; s: 204),
  ( cc: [ '6' ]; s: 205),
  ( cc: [ '8' ]; s: 202),
{ 159: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'f','h'..'z' ]; s: 65),
  ( cc: [ 'g' ]; s: 206),
{ 160: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'m','o'..'z' ]; s: 65),
  ( cc: [ 'n' ]; s: 207),
{ 161: }
  ( cc: [ '0'..'9','A'..'Z','_','b'..'z' ]; s: 65),
  ( cc: [ 'a' ]; s: 208),
{ 162: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 163: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 164: }
  ( cc: [ '0'..'9','A'..'Q','S'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'R' ]; s: 209),
{ 165: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'q','s'..'z' ]; s: 65),
  ( cc: [ 'r' ]; s: 210),
{ 166: }
  ( cc: [ '0'..'9','A'..'D','F'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'E' ]; s: 211),
{ 167: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'d','f'..'z' ]; s: 65),
  ( cc: [ 'e' ]; s: 212),
{ 168: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'k','m'..'z' ]; s: 65),
  ( cc: [ 'l' ]; s: 213),
{ 169: }
  ( cc: [ 'e' ]; s: 214),
{ 170: }
  ( cc: [ 'l' ]; s: 215),
{ 171: }
{ 172: }
  ( cc: [ 'e' ]; s: 216),
{ 173: }
  ( cc: [ 'f' ]; s: 217),
{ 174: }
  ( cc: [ 'i' ]; s: 218),
{ 175: }
  ( cc: [ 'o' ]; s: 219),
{ 176: }
  ( cc: [ 'e' ]; s: 220),
{ 177: }
{ 178: }
  ( cc: [ 'g' ]; s: 221),
{ 179: }
  ( cc: [ 'i' ]; s: 222),
{ 180: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'q','s'..'z' ]; s: 65),
  ( cc: [ 'r' ]; s: 223),
{ 181: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 182: }
  ( cc: [ '0'..'9','B'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'A' ]; s: 224),
{ 183: }
  ( cc: [ '0'..'9','A'..'S','U'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'T' ]; s: 225),
{ 184: }
  ( cc: [ '0'..'9','A'..'K','M'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'L' ]; s: 226),
{ 185: }
  ( cc: [ '0'..'9','A','C'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'B' ]; s: 227),
{ 186: }
  ( cc: [ '0'..'9','A'..'S','U'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'T' ]; s: 228),
{ 187: }
  ( cc: [ '0'..'9','B'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'A' ]; s: 229),
{ 188: }
  ( cc: [ '0'..'9','A'..'D','F'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'E' ]; s: 230),
{ 189: }
  ( cc: [ '0'..'9','A'..'O','Q'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'P' ]; s: 231),
{ 190: }
  ( cc: [ '0'..'9','A'..'C','E'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'D' ]; s: 232),
{ 191: }
  ( cc: [ '0'..'9','A'..'M','O'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'N' ]; s: 233),
{ 192: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 193: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 194: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 195: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'s','u'..'z' ]; s: 65),
  ( cc: [ 't' ]; s: 234),
{ 196: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'m','o'..'z' ]; s: 65),
  ( cc: [ 'n' ]; s: 235),
{ 197: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'f','h'..'z' ]; s: 65),
  ( cc: [ 'g' ]; s: 236),
{ 198: }
  ( cc: [ '0'..'9','A'..'Z','_','a','b','d'..'z' ]; s: 65),
  ( cc: [ 'c' ]; s: 237),
{ 199: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'s','u'..'z' ]; s: 65),
  ( cc: [ 't' ]; s: 238),
{ 200: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'d','f'..'z' ]; s: 65),
  ( cc: [ 'e' ]; s: 239),
{ 201: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'c','e'..'z' ]; s: 65),
  ( cc: [ 'd' ]; s: 240),
{ 202: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 203: }
  ( cc: [ '0'..'5','7'..'9','A'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ '6' ]; s: 241),
{ 204: }
  ( cc: [ '0','1','3'..'9','A'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ '2' ]; s: 242),
{ 205: }
  ( cc: [ '0'..'3','5'..'9','A'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ '4' ]; s: 243),
{ 206: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 207: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'s','u'..'z' ]; s: 65),
  ( cc: [ 't' ]; s: 244),
{ 208: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'s','u'..'z' ]; s: 65),
  ( cc: [ 't' ]; s: 245),
{ 209: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 210: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 211: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 212: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 213: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'d','f'..'z' ]; s: 65),
  ( cc: [ 'e' ]; s: 246),
{ 214: }
  ( cc: [ 'f' ]; s: 247),
{ 215: }
  ( cc: [ 'u' ]; s: 248),
{ 216: }
{ 217: }
{ 218: }
  ( cc: [ 'f' ]; s: 249),
{ 219: }
  ( cc: [ 'r' ]; s: 250),
{ 220: }
  ( cc: [ 'f' ]; s: 251),
{ 221: }
  ( cc: [ 'm' ]; s: 252),
{ 222: }
  ( cc: [ 'n' ]; s: 253),
{ 223: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'m','o'..'z' ]; s: 65),
  ( cc: [ 'n' ]; s: 254),
{ 224: }
  ( cc: [ '0'..'9','A'..'K','M'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'L' ]; s: 255),
{ 225: }
  ( cc: [ '0'..'9','A'..'Q','S'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'R' ]; s: 256),
{ 226: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 227: }
  ( cc: [ '0'..'9','B'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'A' ]; s: 257),
{ 228: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 229: }
  ( cc: [ '0'..'9','A'..'K','M'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'L' ]; s: 258),
{ 230: }
  ( cc: [ '0'..'9','A'..'C','E'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'D' ]; s: 259),
{ 231: }
  ( cc: [ '0'..'9','A'..'H','J'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'I' ]; s: 260),
{ 232: }
  ( cc: [ '0'..'9','A'..'H','J'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'I' ]; s: 261),
{ 233: }
  ( cc: [ '0'..'9','A'..'S','U'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'T' ]; s: 262),
{ 234: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 235: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 236: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'m','o'..'z' ]; s: 65),
  ( cc: [ 'n' ]; s: 263),
{ 237: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'s','u'..'z' ]; s: 65),
  ( cc: [ 't' ]; s: 264),
{ 238: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 239: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'c','e'..'z' ]; s: 65),
  ( cc: [ 'd' ]; s: 265),
{ 240: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'d','f'..'z' ]; s: 65),
  ( cc: [ 'e' ]; s: 266),
{ 241: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 242: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 243: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 244: }
  ( cc: [ '0','2','4','5','7','9','A'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ '1' ]; s: 268),
  ( cc: [ '3' ]; s: 269),
  ( cc: [ '6' ]; s: 270),
  ( cc: [ '8' ]; s: 267),
{ 245: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 246: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 247: }
  ( cc: [ #9,' ' ]; s: 271),
  ( cc: [ '_' ]; s: 272),
  ( cc: [ 'c' ]; s: 273),
{ 248: }
  ( cc: [ 'd' ]; s: 274),
{ 249: }
{ 250: }
{ 251: }
{ 252: }
  ( cc: [ 'a' ]; s: 275),
{ 253: }
  ( cc: [ 'e' ]; s: 276),
{ 254: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 255: }
  ( cc: [ '0'..'9','A'..'K','M'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'L' ]; s: 277),
{ 256: }
  ( cc: [ '0'..'9','B'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'A' ]; s: 278),
{ 257: }
  ( cc: [ '0'..'9','A','B','D'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'C' ]; s: 279),
{ 258: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 259: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 260: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 261: }
  ( cc: [ '0'..'9','B'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'A' ]; s: 280),
{ 262: }
  ( cc: [ '0'..'9','A'..'Q','S'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'R' ]; s: 281),
{ 263: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'d','f'..'z' ]; s: 65),
  ( cc: [ 'e' ]; s: 282),
{ 264: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 265: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 266: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'e','g'..'z' ]; s: 65),
  ( cc: [ 'f' ]; s: 283),
{ 267: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 268: }
  ( cc: [ '0'..'5','7'..'9','A'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ '6' ]; s: 284),
{ 269: }
  ( cc: [ '0','1','3'..'9','A'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ '2' ]; s: 285),
{ 270: }
  ( cc: [ '0'..'3','5'..'9','A'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ '4' ]; s: 286),
{ 271: }
  ( cc: [ #9,' ' ]; s: 287),
  ( cc: [ '_' ]; s: 272),
  ( cc: [ 'c' ]; s: 273),
{ 272: }
  ( cc: [ '_' ]; s: 288),
{ 273: }
  ( cc: [ 'p' ]; s: 289),
{ 274: }
  ( cc: [ 'e' ]; s: 290),
{ 275: }
{ 276: }
{ 277: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 278: }
  ( cc: [ '0'..'9','A'..'O','Q'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'P' ]; s: 291),
{ 279: }
  ( cc: [ '0'..'9','A'..'J','L'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'K' ]; s: 292),
{ 280: }
  ( cc: [ '0'..'9','A'..'O','Q'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'P' ]; s: 293),
{ 281: }
  ( cc: [ '0'..'9','A'..'X','Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'Y' ]; s: 294),
{ 282: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'c','e'..'z' ]; s: 65),
  ( cc: [ 'd' ]; s: 295),
{ 283: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 284: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 285: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 286: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 287: }
  ( cc: [ #9,' ' ]; s: 287),
  ( cc: [ '_' ]; s: 272),
  ( cc: [ 'c' ]; s: 273),
{ 288: }
  ( cc: [ 'c' ]; s: 296),
{ 289: }
  ( cc: [ 'l' ]; s: 297),
{ 290: }
{ 291: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 292: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 293: }
  ( cc: [ '0'..'9','A'..'H','J'..'Z','_','a'..'z' ]; s: 65),
  ( cc: [ 'I' ]; s: 298),
{ 294: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 295: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 296: }
  ( cc: [ 'p' ]; s: 299),
{ 297: }
  ( cc: [ 'u' ]; s: 300),
{ 298: }
  ( cc: [ '0'..'9','A'..'Z','_','a'..'z' ]; s: 65),
{ 299: }
  ( cc: [ 'l' ]; s: 301),
{ 300: }
  ( cc: [ 's' ]; s: 302),
{ 301: }
  ( cc: [ 'u' ]; s: 303),
{ 302: }
  ( cc: [ 'p' ]; s: 304),
{ 303: }
  ( cc: [ 's' ]; s: 305),
{ 304: }
  ( cc: [ 'l' ]; s: 306),
{ 305: }
  ( cc: [ 'p' ]; s: 307),
{ 306: }
  ( cc: [ 'u' ]; s: 308),
{ 307: }
  ( cc: [ 'l' ]; s: 309),
{ 308: }
  ( cc: [ 's' ]; s: 310),
{ 309: }
  ( cc: [ 'u' ]; s: 311),
{ 310: }
  ( cc: [ #9,' ' ]; s: 310),
  ( cc: [ #10 ]; s: 312),
{ 311: }
  ( cc: [ 's' ]; s: 313),
{ 312: }
  ( cc: [ 'e' ]; s: 314),
  ( cc: [ '}' ]; s: 315),
{ 313: }
  ( cc: [ #9,' ' ]; s: 313),
  ( cc: [ #10 ]; s: 316),
{ 314: }
  ( cc: [ 'x' ]; s: 317),
{ 315: }
  ( cc: [ #10 ]; s: 318),
{ 316: }
  ( cc: [ 'e' ]; s: 319),
  ( cc: [ '}' ]; s: 320),
{ 317: }
  ( cc: [ 't' ]; s: 321),
{ 318: }
  ( cc: [ '#' ]; s: 322),
{ 319: }
  ( cc: [ 'x' ]; s: 323),
{ 320: }
  ( cc: [ #10 ]; s: 324),
{ 321: }
  ( cc: [ 'e' ]; s: 325),
{ 322: }
  ( cc: [ 'e' ]; s: 326),
{ 323: }
  ( cc: [ 't' ]; s: 327),
{ 324: }
  ( cc: [ '#' ]; s: 328),
{ 325: }
  ( cc: [ 'r' ]; s: 329),
{ 326: }
  ( cc: [ 'n' ]; s: 330),
{ 327: }
  ( cc: [ 'e' ]; s: 331),
{ 328: }
  ( cc: [ 'e' ]; s: 332),
{ 329: }
  ( cc: [ 'n' ]; s: 333),
{ 330: }
  ( cc: [ 'd' ]; s: 334),
{ 331: }
  ( cc: [ 'r' ]; s: 335),
{ 332: }
  ( cc: [ 'n' ]; s: 336),
{ 333: }
  ( cc: [ ' ' ]; s: 337),
{ 334: }
  ( cc: [ 'i' ]; s: 338),
{ 335: }
  ( cc: [ 'n' ]; s: 339),
{ 336: }
  ( cc: [ 'd' ]; s: 340),
{ 337: }
  ( cc: [ '"' ]; s: 341),
{ 338: }
  ( cc: [ 'f' ]; s: 342),
{ 339: }
  ( cc: [ ' ' ]; s: 343),
{ 340: }
  ( cc: [ 'i' ]; s: 344),
{ 341: }
  ( cc: [ 'C' ]; s: 345),
{ 342: }
{ 343: }
  ( cc: [ '"' ]; s: 346),
{ 344: }
  ( cc: [ 'f' ]; s: 347),
{ 345: }
  ( cc: [ '"' ]; s: 348),
{ 346: }
  ( cc: [ 'C' ]; s: 349),
{ 347: }
{ 348: }
  ( cc: [ ' ' ]; s: 350),
{ 349: }
  ( cc: [ '"' ]; s: 351),
{ 350: }
  ( cc: [ '{' ]; s: 352),
{ 351: }
  ( cc: [ ' ' ]; s: 353),
{ 352: }
  ( cc: [ #10 ]; s: 354),
{ 353: }
  ( cc: [ '{' ]; s: 355),
{ 354: }
  ( cc: [ '#' ]; s: 356),
{ 355: }
  ( cc: [ #10 ]; s: 357),
{ 356: }
  ( cc: [ 'e' ]; s: 358),
{ 357: }
  ( cc: [ '#' ]; s: 359),
{ 358: }
  ( cc: [ 'n' ]; s: 360),
{ 359: }
  ( cc: [ 'e' ]; s: 361),
{ 360: }
  ( cc: [ 'd' ]; s: 362),
{ 361: }
  ( cc: [ 'n' ]; s: 363),
{ 362: }
  ( cc: [ 'i' ]; s: 364),
{ 363: }
  ( cc: [ 'd' ]; s: 365),
{ 364: }
  ( cc: [ 'f' ]; s: 366),
{ 365: }
  ( cc: [ 'i' ]; s: 367),
{ 366: }
{ 367: }
  ( cc: [ 'f' ]; s: 368)
{ 368: }
);

yykl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 3,
{ 4: } 4,
{ 5: } 5,
{ 6: } 7,
{ 7: } 10,
{ 8: } 13,
{ 9: } 15,
{ 10: } 17,
{ 11: } 19,
{ 12: } 21,
{ 13: } 23,
{ 14: } 24,
{ 15: } 26,
{ 16: } 28,
{ 17: } 30,
{ 18: } 32,
{ 19: } 34,
{ 20: } 36,
{ 21: } 38,
{ 22: } 40,
{ 23: } 42,
{ 24: } 44,
{ 25: } 46,
{ 26: } 48,
{ 27: } 50,
{ 28: } 52,
{ 29: } 54,
{ 30: } 56,
{ 31: } 58,
{ 32: } 60,
{ 33: } 62,
{ 34: } 64,
{ 35: } 66,
{ 36: } 68,
{ 37: } 70,
{ 38: } 72,
{ 39: } 74,
{ 40: } 76,
{ 41: } 78,
{ 42: } 80,
{ 43: } 82,
{ 44: } 84,
{ 45: } 86,
{ 46: } 88,
{ 47: } 90,
{ 48: } 92,
{ 49: } 94,
{ 50: } 96,
{ 51: } 98,
{ 52: } 100,
{ 53: } 102,
{ 54: } 104,
{ 55: } 105,
{ 56: } 107,
{ 57: } 108,
{ 58: } 109,
{ 59: } 110,
{ 60: } 110,
{ 61: } 111,
{ 62: } 111,
{ 63: } 112,
{ 64: } 112,
{ 65: } 112,
{ 66: } 113,
{ 67: } 115,
{ 68: } 116,
{ 69: } 117,
{ 70: } 117,
{ 71: } 117,
{ 72: } 118,
{ 73: } 119,
{ 74: } 120,
{ 75: } 121,
{ 76: } 122,
{ 77: } 123,
{ 78: } 124,
{ 79: } 125,
{ 80: } 126,
{ 81: } 126,
{ 82: } 126,
{ 83: } 126,
{ 84: } 126,
{ 85: } 126,
{ 86: } 126,
{ 87: } 126,
{ 88: } 126,
{ 89: } 127,
{ 90: } 128,
{ 91: } 129,
{ 92: } 130,
{ 93: } 131,
{ 94: } 132,
{ 95: } 133,
{ 96: } 134,
{ 97: } 135,
{ 98: } 136,
{ 99: } 137,
{ 100: } 138,
{ 101: } 139,
{ 102: } 140,
{ 103: } 141,
{ 104: } 142,
{ 105: } 143,
{ 106: } 144,
{ 107: } 145,
{ 108: } 146,
{ 109: } 147,
{ 110: } 148,
{ 111: } 149,
{ 112: } 150,
{ 113: } 151,
{ 114: } 152,
{ 115: } 153,
{ 116: } 154,
{ 117: } 155,
{ 118: } 156,
{ 119: } 156,
{ 120: } 157,
{ 121: } 158,
{ 122: } 159,
{ 123: } 159,
{ 124: } 160,
{ 125: } 161,
{ 126: } 162,
{ 127: } 163,
{ 128: } 163,
{ 129: } 163,
{ 130: } 163,
{ 131: } 163,
{ 132: } 163,
{ 133: } 163,
{ 134: } 163,
{ 135: } 163,
{ 136: } 163,
{ 137: } 164,
{ 138: } 165,
{ 139: } 166,
{ 140: } 167,
{ 141: } 168,
{ 142: } 169,
{ 143: } 170,
{ 144: } 171,
{ 145: } 172,
{ 146: } 173,
{ 147: } 174,
{ 148: } 175,
{ 149: } 176,
{ 150: } 177,
{ 151: } 178,
{ 152: } 179,
{ 153: } 180,
{ 154: } 181,
{ 155: } 182,
{ 156: } 183,
{ 157: } 184,
{ 158: } 185,
{ 159: } 187,
{ 160: } 188,
{ 161: } 189,
{ 162: } 190,
{ 163: } 192,
{ 164: } 194,
{ 165: } 195,
{ 166: } 196,
{ 167: } 197,
{ 168: } 198,
{ 169: } 199,
{ 170: } 199,
{ 171: } 199,
{ 172: } 200,
{ 173: } 200,
{ 174: } 200,
{ 175: } 200,
{ 176: } 200,
{ 177: } 200,
{ 178: } 201,
{ 179: } 201,
{ 180: } 201,
{ 181: } 202,
{ 182: } 204,
{ 183: } 205,
{ 184: } 206,
{ 185: } 207,
{ 186: } 208,
{ 187: } 209,
{ 188: } 210,
{ 189: } 211,
{ 190: } 212,
{ 191: } 213,
{ 192: } 214,
{ 193: } 216,
{ 194: } 218,
{ 195: } 220,
{ 196: } 221,
{ 197: } 222,
{ 198: } 223,
{ 199: } 224,
{ 200: } 225,
{ 201: } 226,
{ 202: } 227,
{ 203: } 229,
{ 204: } 230,
{ 205: } 231,
{ 206: } 232,
{ 207: } 234,
{ 208: } 235,
{ 209: } 236,
{ 210: } 238,
{ 211: } 240,
{ 212: } 242,
{ 213: } 244,
{ 214: } 245,
{ 215: } 245,
{ 216: } 245,
{ 217: } 246,
{ 218: } 247,
{ 219: } 247,
{ 220: } 247,
{ 221: } 247,
{ 222: } 247,
{ 223: } 247,
{ 224: } 248,
{ 225: } 249,
{ 226: } 250,
{ 227: } 252,
{ 228: } 253,
{ 229: } 255,
{ 230: } 256,
{ 231: } 257,
{ 232: } 258,
{ 233: } 259,
{ 234: } 260,
{ 235: } 262,
{ 236: } 264,
{ 237: } 265,
{ 238: } 266,
{ 239: } 268,
{ 240: } 269,
{ 241: } 270,
{ 242: } 272,
{ 243: } 274,
{ 244: } 276,
{ 245: } 277,
{ 246: } 279,
{ 247: } 281,
{ 248: } 281,
{ 249: } 281,
{ 250: } 282,
{ 251: } 283,
{ 252: } 284,
{ 253: } 284,
{ 254: } 284,
{ 255: } 286,
{ 256: } 287,
{ 257: } 288,
{ 258: } 289,
{ 259: } 291,
{ 260: } 293,
{ 261: } 295,
{ 262: } 296,
{ 263: } 297,
{ 264: } 298,
{ 265: } 300,
{ 266: } 302,
{ 267: } 303,
{ 268: } 305,
{ 269: } 306,
{ 270: } 307,
{ 271: } 308,
{ 272: } 309,
{ 273: } 309,
{ 274: } 309,
{ 275: } 309,
{ 276: } 310,
{ 277: } 311,
{ 278: } 313,
{ 279: } 314,
{ 280: } 315,
{ 281: } 316,
{ 282: } 317,
{ 283: } 318,
{ 284: } 320,
{ 285: } 322,
{ 286: } 324,
{ 287: } 326,
{ 288: } 326,
{ 289: } 326,
{ 290: } 326,
{ 291: } 327,
{ 292: } 329,
{ 293: } 331,
{ 294: } 332,
{ 295: } 334,
{ 296: } 336,
{ 297: } 336,
{ 298: } 336,
{ 299: } 338,
{ 300: } 338,
{ 301: } 338,
{ 302: } 338,
{ 303: } 338,
{ 304: } 338,
{ 305: } 338,
{ 306: } 338,
{ 307: } 338,
{ 308: } 338,
{ 309: } 338,
{ 310: } 338,
{ 311: } 339,
{ 312: } 339,
{ 313: } 339,
{ 314: } 340,
{ 315: } 340,
{ 316: } 340,
{ 317: } 340,
{ 318: } 340,
{ 319: } 340,
{ 320: } 340,
{ 321: } 340,
{ 322: } 340,
{ 323: } 340,
{ 324: } 340,
{ 325: } 340,
{ 326: } 340,
{ 327: } 340,
{ 328: } 340,
{ 329: } 340,
{ 330: } 340,
{ 331: } 340,
{ 332: } 340,
{ 333: } 340,
{ 334: } 340,
{ 335: } 340,
{ 336: } 340,
{ 337: } 340,
{ 338: } 340,
{ 339: } 340,
{ 340: } 340,
{ 341: } 340,
{ 342: } 340,
{ 343: } 341,
{ 344: } 341,
{ 345: } 341,
{ 346: } 341,
{ 347: } 341,
{ 348: } 342,
{ 349: } 342,
{ 350: } 342,
{ 351: } 342,
{ 352: } 342,
{ 353: } 342,
{ 354: } 342,
{ 355: } 342,
{ 356: } 342,
{ 357: } 342,
{ 358: } 342,
{ 359: } 342,
{ 360: } 342,
{ 361: } 342,
{ 362: } 342,
{ 363: } 342,
{ 364: } 342,
{ 365: } 342,
{ 366: } 342,
{ 367: } 343,
{ 368: } 343
);

yykh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 2,
{ 3: } 3,
{ 4: } 4,
{ 5: } 6,
{ 6: } 9,
{ 7: } 12,
{ 8: } 14,
{ 9: } 16,
{ 10: } 18,
{ 11: } 20,
{ 12: } 22,
{ 13: } 23,
{ 14: } 25,
{ 15: } 27,
{ 16: } 29,
{ 17: } 31,
{ 18: } 33,
{ 19: } 35,
{ 20: } 37,
{ 21: } 39,
{ 22: } 41,
{ 23: } 43,
{ 24: } 45,
{ 25: } 47,
{ 26: } 49,
{ 27: } 51,
{ 28: } 53,
{ 29: } 55,
{ 30: } 57,
{ 31: } 59,
{ 32: } 61,
{ 33: } 63,
{ 34: } 65,
{ 35: } 67,
{ 36: } 69,
{ 37: } 71,
{ 38: } 73,
{ 39: } 75,
{ 40: } 77,
{ 41: } 79,
{ 42: } 81,
{ 43: } 83,
{ 44: } 85,
{ 45: } 87,
{ 46: } 89,
{ 47: } 91,
{ 48: } 93,
{ 49: } 95,
{ 50: } 97,
{ 51: } 99,
{ 52: } 101,
{ 53: } 103,
{ 54: } 104,
{ 55: } 106,
{ 56: } 107,
{ 57: } 108,
{ 58: } 109,
{ 59: } 109,
{ 60: } 110,
{ 61: } 110,
{ 62: } 111,
{ 63: } 111,
{ 64: } 111,
{ 65: } 112,
{ 66: } 114,
{ 67: } 115,
{ 68: } 116,
{ 69: } 116,
{ 70: } 116,
{ 71: } 117,
{ 72: } 118,
{ 73: } 119,
{ 74: } 120,
{ 75: } 121,
{ 76: } 122,
{ 77: } 123,
{ 78: } 124,
{ 79: } 125,
{ 80: } 125,
{ 81: } 125,
{ 82: } 125,
{ 83: } 125,
{ 84: } 125,
{ 85: } 125,
{ 86: } 125,
{ 87: } 125,
{ 88: } 126,
{ 89: } 127,
{ 90: } 128,
{ 91: } 129,
{ 92: } 130,
{ 93: } 131,
{ 94: } 132,
{ 95: } 133,
{ 96: } 134,
{ 97: } 135,
{ 98: } 136,
{ 99: } 137,
{ 100: } 138,
{ 101: } 139,
{ 102: } 140,
{ 103: } 141,
{ 104: } 142,
{ 105: } 143,
{ 106: } 144,
{ 107: } 145,
{ 108: } 146,
{ 109: } 147,
{ 110: } 148,
{ 111: } 149,
{ 112: } 150,
{ 113: } 151,
{ 114: } 152,
{ 115: } 153,
{ 116: } 154,
{ 117: } 155,
{ 118: } 155,
{ 119: } 156,
{ 120: } 157,
{ 121: } 158,
{ 122: } 158,
{ 123: } 159,
{ 124: } 160,
{ 125: } 161,
{ 126: } 162,
{ 127: } 162,
{ 128: } 162,
{ 129: } 162,
{ 130: } 162,
{ 131: } 162,
{ 132: } 162,
{ 133: } 162,
{ 134: } 162,
{ 135: } 162,
{ 136: } 163,
{ 137: } 164,
{ 138: } 165,
{ 139: } 166,
{ 140: } 167,
{ 141: } 168,
{ 142: } 169,
{ 143: } 170,
{ 144: } 171,
{ 145: } 172,
{ 146: } 173,
{ 147: } 174,
{ 148: } 175,
{ 149: } 176,
{ 150: } 177,
{ 151: } 178,
{ 152: } 179,
{ 153: } 180,
{ 154: } 181,
{ 155: } 182,
{ 156: } 183,
{ 157: } 184,
{ 158: } 186,
{ 159: } 187,
{ 160: } 188,
{ 161: } 189,
{ 162: } 191,
{ 163: } 193,
{ 164: } 194,
{ 165: } 195,
{ 166: } 196,
{ 167: } 197,
{ 168: } 198,
{ 169: } 198,
{ 170: } 198,
{ 171: } 199,
{ 172: } 199,
{ 173: } 199,
{ 174: } 199,
{ 175: } 199,
{ 176: } 199,
{ 177: } 200,
{ 178: } 200,
{ 179: } 200,
{ 180: } 201,
{ 181: } 203,
{ 182: } 204,
{ 183: } 205,
{ 184: } 206,
{ 185: } 207,
{ 186: } 208,
{ 187: } 209,
{ 188: } 210,
{ 189: } 211,
{ 190: } 212,
{ 191: } 213,
{ 192: } 215,
{ 193: } 217,
{ 194: } 219,
{ 195: } 220,
{ 196: } 221,
{ 197: } 222,
{ 198: } 223,
{ 199: } 224,
{ 200: } 225,
{ 201: } 226,
{ 202: } 228,
{ 203: } 229,
{ 204: } 230,
{ 205: } 231,
{ 206: } 233,
{ 207: } 234,
{ 208: } 235,
{ 209: } 237,
{ 210: } 239,
{ 211: } 241,
{ 212: } 243,
{ 213: } 244,
{ 214: } 244,
{ 215: } 244,
{ 216: } 245,
{ 217: } 246,
{ 218: } 246,
{ 219: } 246,
{ 220: } 246,
{ 221: } 246,
{ 222: } 246,
{ 223: } 247,
{ 224: } 248,
{ 225: } 249,
{ 226: } 251,
{ 227: } 252,
{ 228: } 254,
{ 229: } 255,
{ 230: } 256,
{ 231: } 257,
{ 232: } 258,
{ 233: } 259,
{ 234: } 261,
{ 235: } 263,
{ 236: } 264,
{ 237: } 265,
{ 238: } 267,
{ 239: } 268,
{ 240: } 269,
{ 241: } 271,
{ 242: } 273,
{ 243: } 275,
{ 244: } 276,
{ 245: } 278,
{ 246: } 280,
{ 247: } 280,
{ 248: } 280,
{ 249: } 281,
{ 250: } 282,
{ 251: } 283,
{ 252: } 283,
{ 253: } 283,
{ 254: } 285,
{ 255: } 286,
{ 256: } 287,
{ 257: } 288,
{ 258: } 290,
{ 259: } 292,
{ 260: } 294,
{ 261: } 295,
{ 262: } 296,
{ 263: } 297,
{ 264: } 299,
{ 265: } 301,
{ 266: } 302,
{ 267: } 304,
{ 268: } 305,
{ 269: } 306,
{ 270: } 307,
{ 271: } 308,
{ 272: } 308,
{ 273: } 308,
{ 274: } 308,
{ 275: } 309,
{ 276: } 310,
{ 277: } 312,
{ 278: } 313,
{ 279: } 314,
{ 280: } 315,
{ 281: } 316,
{ 282: } 317,
{ 283: } 319,
{ 284: } 321,
{ 285: } 323,
{ 286: } 325,
{ 287: } 325,
{ 288: } 325,
{ 289: } 325,
{ 290: } 326,
{ 291: } 328,
{ 292: } 330,
{ 293: } 331,
{ 294: } 333,
{ 295: } 335,
{ 296: } 335,
{ 297: } 335,
{ 298: } 337,
{ 299: } 337,
{ 300: } 337,
{ 301: } 337,
{ 302: } 337,
{ 303: } 337,
{ 304: } 337,
{ 305: } 337,
{ 306: } 337,
{ 307: } 337,
{ 308: } 337,
{ 309: } 337,
{ 310: } 338,
{ 311: } 338,
{ 312: } 338,
{ 313: } 339,
{ 314: } 339,
{ 315: } 339,
{ 316: } 339,
{ 317: } 339,
{ 318: } 339,
{ 319: } 339,
{ 320: } 339,
{ 321: } 339,
{ 322: } 339,
{ 323: } 339,
{ 324: } 339,
{ 325: } 339,
{ 326: } 339,
{ 327: } 339,
{ 328: } 339,
{ 329: } 339,
{ 330: } 339,
{ 331: } 339,
{ 332: } 339,
{ 333: } 339,
{ 334: } 339,
{ 335: } 339,
{ 336: } 339,
{ 337: } 339,
{ 338: } 339,
{ 339: } 339,
{ 340: } 339,
{ 341: } 339,
{ 342: } 340,
{ 343: } 340,
{ 344: } 340,
{ 345: } 340,
{ 346: } 340,
{ 347: } 341,
{ 348: } 341,
{ 349: } 341,
{ 350: } 341,
{ 351: } 341,
{ 352: } 341,
{ 353: } 341,
{ 354: } 341,
{ 355: } 341,
{ 356: } 341,
{ 357: } 341,
{ 358: } 341,
{ 359: } 341,
{ 360: } 341,
{ 361: } 341,
{ 362: } 341,
{ 363: } 341,
{ 364: } 341,
{ 365: } 341,
{ 366: } 342,
{ 367: } 342,
{ 368: } 343
);

yyml : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 3,
{ 4: } 4,
{ 5: } 5,
{ 6: } 7,
{ 7: } 10,
{ 8: } 13,
{ 9: } 15,
{ 10: } 17,
{ 11: } 19,
{ 12: } 21,
{ 13: } 23,
{ 14: } 24,
{ 15: } 26,
{ 16: } 28,
{ 17: } 30,
{ 18: } 32,
{ 19: } 34,
{ 20: } 36,
{ 21: } 38,
{ 22: } 40,
{ 23: } 42,
{ 24: } 44,
{ 25: } 46,
{ 26: } 48,
{ 27: } 50,
{ 28: } 52,
{ 29: } 54,
{ 30: } 56,
{ 31: } 58,
{ 32: } 60,
{ 33: } 62,
{ 34: } 64,
{ 35: } 66,
{ 36: } 68,
{ 37: } 70,
{ 38: } 72,
{ 39: } 74,
{ 40: } 76,
{ 41: } 78,
{ 42: } 80,
{ 43: } 82,
{ 44: } 84,
{ 45: } 86,
{ 46: } 88,
{ 47: } 90,
{ 48: } 92,
{ 49: } 94,
{ 50: } 96,
{ 51: } 98,
{ 52: } 100,
{ 53: } 102,
{ 54: } 104,
{ 55: } 105,
{ 56: } 106,
{ 57: } 107,
{ 58: } 108,
{ 59: } 109,
{ 60: } 109,
{ 61: } 110,
{ 62: } 110,
{ 63: } 111,
{ 64: } 111,
{ 65: } 111,
{ 66: } 112,
{ 67: } 114,
{ 68: } 115,
{ 69: } 116,
{ 70: } 116,
{ 71: } 116,
{ 72: } 117,
{ 73: } 118,
{ 74: } 119,
{ 75: } 120,
{ 76: } 121,
{ 77: } 122,
{ 78: } 123,
{ 79: } 124,
{ 80: } 125,
{ 81: } 125,
{ 82: } 125,
{ 83: } 125,
{ 84: } 125,
{ 85: } 125,
{ 86: } 125,
{ 87: } 125,
{ 88: } 125,
{ 89: } 126,
{ 90: } 127,
{ 91: } 128,
{ 92: } 129,
{ 93: } 130,
{ 94: } 131,
{ 95: } 132,
{ 96: } 133,
{ 97: } 134,
{ 98: } 135,
{ 99: } 136,
{ 100: } 137,
{ 101: } 138,
{ 102: } 139,
{ 103: } 140,
{ 104: } 141,
{ 105: } 142,
{ 106: } 143,
{ 107: } 144,
{ 108: } 145,
{ 109: } 146,
{ 110: } 147,
{ 111: } 148,
{ 112: } 149,
{ 113: } 150,
{ 114: } 151,
{ 115: } 152,
{ 116: } 153,
{ 117: } 154,
{ 118: } 155,
{ 119: } 156,
{ 120: } 157,
{ 121: } 158,
{ 122: } 159,
{ 123: } 159,
{ 124: } 160,
{ 125: } 161,
{ 126: } 162,
{ 127: } 163,
{ 128: } 163,
{ 129: } 163,
{ 130: } 163,
{ 131: } 163,
{ 132: } 163,
{ 133: } 163,
{ 134: } 163,
{ 135: } 163,
{ 136: } 163,
{ 137: } 164,
{ 138: } 165,
{ 139: } 166,
{ 140: } 167,
{ 141: } 168,
{ 142: } 169,
{ 143: } 170,
{ 144: } 171,
{ 145: } 172,
{ 146: } 173,
{ 147: } 174,
{ 148: } 175,
{ 149: } 176,
{ 150: } 177,
{ 151: } 178,
{ 152: } 179,
{ 153: } 180,
{ 154: } 181,
{ 155: } 182,
{ 156: } 183,
{ 157: } 184,
{ 158: } 185,
{ 159: } 187,
{ 160: } 188,
{ 161: } 189,
{ 162: } 190,
{ 163: } 192,
{ 164: } 194,
{ 165: } 195,
{ 166: } 196,
{ 167: } 197,
{ 168: } 198,
{ 169: } 199,
{ 170: } 199,
{ 171: } 199,
{ 172: } 200,
{ 173: } 200,
{ 174: } 200,
{ 175: } 200,
{ 176: } 200,
{ 177: } 200,
{ 178: } 201,
{ 179: } 201,
{ 180: } 201,
{ 181: } 202,
{ 182: } 204,
{ 183: } 205,
{ 184: } 206,
{ 185: } 207,
{ 186: } 208,
{ 187: } 209,
{ 188: } 210,
{ 189: } 211,
{ 190: } 212,
{ 191: } 213,
{ 192: } 214,
{ 193: } 216,
{ 194: } 218,
{ 195: } 220,
{ 196: } 221,
{ 197: } 222,
{ 198: } 223,
{ 199: } 224,
{ 200: } 225,
{ 201: } 226,
{ 202: } 227,
{ 203: } 229,
{ 204: } 230,
{ 205: } 231,
{ 206: } 232,
{ 207: } 234,
{ 208: } 235,
{ 209: } 236,
{ 210: } 238,
{ 211: } 240,
{ 212: } 242,
{ 213: } 244,
{ 214: } 245,
{ 215: } 245,
{ 216: } 245,
{ 217: } 246,
{ 218: } 247,
{ 219: } 247,
{ 220: } 247,
{ 221: } 247,
{ 222: } 247,
{ 223: } 247,
{ 224: } 248,
{ 225: } 249,
{ 226: } 250,
{ 227: } 252,
{ 228: } 253,
{ 229: } 255,
{ 230: } 256,
{ 231: } 257,
{ 232: } 258,
{ 233: } 259,
{ 234: } 260,
{ 235: } 262,
{ 236: } 264,
{ 237: } 265,
{ 238: } 266,
{ 239: } 268,
{ 240: } 269,
{ 241: } 270,
{ 242: } 272,
{ 243: } 274,
{ 244: } 276,
{ 245: } 277,
{ 246: } 279,
{ 247: } 281,
{ 248: } 281,
{ 249: } 281,
{ 250: } 282,
{ 251: } 283,
{ 252: } 284,
{ 253: } 284,
{ 254: } 284,
{ 255: } 286,
{ 256: } 287,
{ 257: } 288,
{ 258: } 289,
{ 259: } 291,
{ 260: } 293,
{ 261: } 295,
{ 262: } 296,
{ 263: } 297,
{ 264: } 298,
{ 265: } 300,
{ 266: } 302,
{ 267: } 303,
{ 268: } 305,
{ 269: } 306,
{ 270: } 307,
{ 271: } 308,
{ 272: } 309,
{ 273: } 309,
{ 274: } 309,
{ 275: } 309,
{ 276: } 310,
{ 277: } 311,
{ 278: } 313,
{ 279: } 314,
{ 280: } 315,
{ 281: } 316,
{ 282: } 317,
{ 283: } 318,
{ 284: } 320,
{ 285: } 322,
{ 286: } 324,
{ 287: } 326,
{ 288: } 326,
{ 289: } 326,
{ 290: } 326,
{ 291: } 327,
{ 292: } 329,
{ 293: } 331,
{ 294: } 332,
{ 295: } 334,
{ 296: } 336,
{ 297: } 336,
{ 298: } 336,
{ 299: } 338,
{ 300: } 338,
{ 301: } 338,
{ 302: } 338,
{ 303: } 338,
{ 304: } 338,
{ 305: } 338,
{ 306: } 338,
{ 307: } 338,
{ 308: } 338,
{ 309: } 338,
{ 310: } 338,
{ 311: } 339,
{ 312: } 339,
{ 313: } 339,
{ 314: } 340,
{ 315: } 340,
{ 316: } 340,
{ 317: } 340,
{ 318: } 340,
{ 319: } 340,
{ 320: } 340,
{ 321: } 340,
{ 322: } 340,
{ 323: } 340,
{ 324: } 340,
{ 325: } 340,
{ 326: } 340,
{ 327: } 340,
{ 328: } 340,
{ 329: } 340,
{ 330: } 340,
{ 331: } 340,
{ 332: } 340,
{ 333: } 340,
{ 334: } 340,
{ 335: } 340,
{ 336: } 340,
{ 337: } 340,
{ 338: } 340,
{ 339: } 340,
{ 340: } 340,
{ 341: } 340,
{ 342: } 340,
{ 343: } 341,
{ 344: } 341,
{ 345: } 341,
{ 346: } 341,
{ 347: } 341,
{ 348: } 342,
{ 349: } 342,
{ 350: } 342,
{ 351: } 342,
{ 352: } 342,
{ 353: } 342,
{ 354: } 342,
{ 355: } 342,
{ 356: } 342,
{ 357: } 342,
{ 358: } 342,
{ 359: } 342,
{ 360: } 342,
{ 361: } 342,
{ 362: } 342,
{ 363: } 342,
{ 364: } 342,
{ 365: } 342,
{ 366: } 342,
{ 367: } 343,
{ 368: } 343
);

yymh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 2,
{ 3: } 3,
{ 4: } 4,
{ 5: } 6,
{ 6: } 9,
{ 7: } 12,
{ 8: } 14,
{ 9: } 16,
{ 10: } 18,
{ 11: } 20,
{ 12: } 22,
{ 13: } 23,
{ 14: } 25,
{ 15: } 27,
{ 16: } 29,
{ 17: } 31,
{ 18: } 33,
{ 19: } 35,
{ 20: } 37,
{ 21: } 39,
{ 22: } 41,
{ 23: } 43,
{ 24: } 45,
{ 25: } 47,
{ 26: } 49,
{ 27: } 51,
{ 28: } 53,
{ 29: } 55,
{ 30: } 57,
{ 31: } 59,
{ 32: } 61,
{ 33: } 63,
{ 34: } 65,
{ 35: } 67,
{ 36: } 69,
{ 37: } 71,
{ 38: } 73,
{ 39: } 75,
{ 40: } 77,
{ 41: } 79,
{ 42: } 81,
{ 43: } 83,
{ 44: } 85,
{ 45: } 87,
{ 46: } 89,
{ 47: } 91,
{ 48: } 93,
{ 49: } 95,
{ 50: } 97,
{ 51: } 99,
{ 52: } 101,
{ 53: } 103,
{ 54: } 104,
{ 55: } 105,
{ 56: } 106,
{ 57: } 107,
{ 58: } 108,
{ 59: } 108,
{ 60: } 109,
{ 61: } 109,
{ 62: } 110,
{ 63: } 110,
{ 64: } 110,
{ 65: } 111,
{ 66: } 113,
{ 67: } 114,
{ 68: } 115,
{ 69: } 115,
{ 70: } 115,
{ 71: } 116,
{ 72: } 117,
{ 73: } 118,
{ 74: } 119,
{ 75: } 120,
{ 76: } 121,
{ 77: } 122,
{ 78: } 123,
{ 79: } 124,
{ 80: } 124,
{ 81: } 124,
{ 82: } 124,
{ 83: } 124,
{ 84: } 124,
{ 85: } 124,
{ 86: } 124,
{ 87: } 124,
{ 88: } 125,
{ 89: } 126,
{ 90: } 127,
{ 91: } 128,
{ 92: } 129,
{ 93: } 130,
{ 94: } 131,
{ 95: } 132,
{ 96: } 133,
{ 97: } 134,
{ 98: } 135,
{ 99: } 136,
{ 100: } 137,
{ 101: } 138,
{ 102: } 139,
{ 103: } 140,
{ 104: } 141,
{ 105: } 142,
{ 106: } 143,
{ 107: } 144,
{ 108: } 145,
{ 109: } 146,
{ 110: } 147,
{ 111: } 148,
{ 112: } 149,
{ 113: } 150,
{ 114: } 151,
{ 115: } 152,
{ 116: } 153,
{ 117: } 154,
{ 118: } 155,
{ 119: } 156,
{ 120: } 157,
{ 121: } 158,
{ 122: } 158,
{ 123: } 159,
{ 124: } 160,
{ 125: } 161,
{ 126: } 162,
{ 127: } 162,
{ 128: } 162,
{ 129: } 162,
{ 130: } 162,
{ 131: } 162,
{ 132: } 162,
{ 133: } 162,
{ 134: } 162,
{ 135: } 162,
{ 136: } 163,
{ 137: } 164,
{ 138: } 165,
{ 139: } 166,
{ 140: } 167,
{ 141: } 168,
{ 142: } 169,
{ 143: } 170,
{ 144: } 171,
{ 145: } 172,
{ 146: } 173,
{ 147: } 174,
{ 148: } 175,
{ 149: } 176,
{ 150: } 177,
{ 151: } 178,
{ 152: } 179,
{ 153: } 180,
{ 154: } 181,
{ 155: } 182,
{ 156: } 183,
{ 157: } 184,
{ 158: } 186,
{ 159: } 187,
{ 160: } 188,
{ 161: } 189,
{ 162: } 191,
{ 163: } 193,
{ 164: } 194,
{ 165: } 195,
{ 166: } 196,
{ 167: } 197,
{ 168: } 198,
{ 169: } 198,
{ 170: } 198,
{ 171: } 199,
{ 172: } 199,
{ 173: } 199,
{ 174: } 199,
{ 175: } 199,
{ 176: } 199,
{ 177: } 200,
{ 178: } 200,
{ 179: } 200,
{ 180: } 201,
{ 181: } 203,
{ 182: } 204,
{ 183: } 205,
{ 184: } 206,
{ 185: } 207,
{ 186: } 208,
{ 187: } 209,
{ 188: } 210,
{ 189: } 211,
{ 190: } 212,
{ 191: } 213,
{ 192: } 215,
{ 193: } 217,
{ 194: } 219,
{ 195: } 220,
{ 196: } 221,
{ 197: } 222,
{ 198: } 223,
{ 199: } 224,
{ 200: } 225,
{ 201: } 226,
{ 202: } 228,
{ 203: } 229,
{ 204: } 230,
{ 205: } 231,
{ 206: } 233,
{ 207: } 234,
{ 208: } 235,
{ 209: } 237,
{ 210: } 239,
{ 211: } 241,
{ 212: } 243,
{ 213: } 244,
{ 214: } 244,
{ 215: } 244,
{ 216: } 245,
{ 217: } 246,
{ 218: } 246,
{ 219: } 246,
{ 220: } 246,
{ 221: } 246,
{ 222: } 246,
{ 223: } 247,
{ 224: } 248,
{ 225: } 249,
{ 226: } 251,
{ 227: } 252,
{ 228: } 254,
{ 229: } 255,
{ 230: } 256,
{ 231: } 257,
{ 232: } 258,
{ 233: } 259,
{ 234: } 261,
{ 235: } 263,
{ 236: } 264,
{ 237: } 265,
{ 238: } 267,
{ 239: } 268,
{ 240: } 269,
{ 241: } 271,
{ 242: } 273,
{ 243: } 275,
{ 244: } 276,
{ 245: } 278,
{ 246: } 280,
{ 247: } 280,
{ 248: } 280,
{ 249: } 281,
{ 250: } 282,
{ 251: } 283,
{ 252: } 283,
{ 253: } 283,
{ 254: } 285,
{ 255: } 286,
{ 256: } 287,
{ 257: } 288,
{ 258: } 290,
{ 259: } 292,
{ 260: } 294,
{ 261: } 295,
{ 262: } 296,
{ 263: } 297,
{ 264: } 299,
{ 265: } 301,
{ 266: } 302,
{ 267: } 304,
{ 268: } 305,
{ 269: } 306,
{ 270: } 307,
{ 271: } 308,
{ 272: } 308,
{ 273: } 308,
{ 274: } 308,
{ 275: } 309,
{ 276: } 310,
{ 277: } 312,
{ 278: } 313,
{ 279: } 314,
{ 280: } 315,
{ 281: } 316,
{ 282: } 317,
{ 283: } 319,
{ 284: } 321,
{ 285: } 323,
{ 286: } 325,
{ 287: } 325,
{ 288: } 325,
{ 289: } 325,
{ 290: } 326,
{ 291: } 328,
{ 292: } 330,
{ 293: } 331,
{ 294: } 333,
{ 295: } 335,
{ 296: } 335,
{ 297: } 335,
{ 298: } 337,
{ 299: } 337,
{ 300: } 337,
{ 301: } 337,
{ 302: } 337,
{ 303: } 337,
{ 304: } 337,
{ 305: } 337,
{ 306: } 337,
{ 307: } 337,
{ 308: } 337,
{ 309: } 337,
{ 310: } 338,
{ 311: } 338,
{ 312: } 338,
{ 313: } 339,
{ 314: } 339,
{ 315: } 339,
{ 316: } 339,
{ 317: } 339,
{ 318: } 339,
{ 319: } 339,
{ 320: } 339,
{ 321: } 339,
{ 322: } 339,
{ 323: } 339,
{ 324: } 339,
{ 325: } 339,
{ 326: } 339,
{ 327: } 339,
{ 328: } 339,
{ 329: } 339,
{ 330: } 339,
{ 331: } 339,
{ 332: } 339,
{ 333: } 339,
{ 334: } 339,
{ 335: } 339,
{ 336: } 339,
{ 337: } 339,
{ 338: } 339,
{ 339: } 339,
{ 340: } 339,
{ 341: } 339,
{ 342: } 340,
{ 343: } 340,
{ 344: } 340,
{ 345: } 340,
{ 346: } 340,
{ 347: } 341,
{ 348: } 341,
{ 349: } 341,
{ 350: } 341,
{ 351: } 341,
{ 352: } 341,
{ 353: } 341,
{ 354: } 341,
{ 355: } 341,
{ 356: } 341,
{ 357: } 341,
{ 358: } 341,
{ 359: } 341,
{ 360: } 341,
{ 361: } 341,
{ 362: } 341,
{ 363: } 341,
{ 364: } 341,
{ 365: } 341,
{ 366: } 342,
{ 367: } 342,
{ 368: } 343
);

yytl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 56,
{ 2: } 111,
{ 3: } 113,
{ 4: } 115,
{ 5: } 117,
{ 6: } 120,
{ 7: } 125,
{ 8: } 131,
{ 9: } 132,
{ 10: } 133,
{ 11: } 134,
{ 12: } 136,
{ 13: } 138,
{ 14: } 146,
{ 15: } 146,
{ 16: } 146,
{ 17: } 146,
{ 18: } 146,
{ 19: } 146,
{ 20: } 146,
{ 21: } 146,
{ 22: } 146,
{ 23: } 146,
{ 24: } 146,
{ 25: } 146,
{ 26: } 146,
{ 27: } 147,
{ 28: } 150,
{ 29: } 153,
{ 30: } 157,
{ 31: } 159,
{ 32: } 161,
{ 33: } 163,
{ 34: } 165,
{ 35: } 167,
{ 36: } 170,
{ 37: } 172,
{ 38: } 176,
{ 39: } 176,
{ 40: } 176,
{ 41: } 178,
{ 42: } 180,
{ 43: } 182,
{ 44: } 184,
{ 45: } 187,
{ 46: } 189,
{ 47: } 191,
{ 48: } 193,
{ 49: } 195,
{ 50: } 197,
{ 51: } 199,
{ 52: } 200,
{ 53: } 200,
{ 54: } 200,
{ 55: } 200,
{ 56: } 201,
{ 57: } 201,
{ 58: } 201,
{ 59: } 201,
{ 60: } 203,
{ 61: } 203,
{ 62: } 205,
{ 63: } 205,
{ 64: } 207,
{ 65: } 209,
{ 66: } 210,
{ 67: } 215,
{ 68: } 216,
{ 69: } 216,
{ 70: } 217,
{ 71: } 219,
{ 72: } 222,
{ 73: } 222,
{ 74: } 222,
{ 75: } 222,
{ 76: } 222,
{ 77: } 222,
{ 78: } 222,
{ 79: } 222,
{ 80: } 222,
{ 81: } 224,
{ 82: } 230,
{ 83: } 233,
{ 84: } 234,
{ 85: } 241,
{ 86: } 242,
{ 87: } 243,
{ 88: } 244,
{ 89: } 246,
{ 90: } 248,
{ 91: } 250,
{ 92: } 252,
{ 93: } 254,
{ 94: } 256,
{ 95: } 258,
{ 96: } 261,
{ 97: } 263,
{ 98: } 265,
{ 99: } 267,
{ 100: } 269,
{ 101: } 271,
{ 102: } 273,
{ 103: } 276,
{ 104: } 278,
{ 105: } 280,
{ 106: } 282,
{ 107: } 284,
{ 108: } 286,
{ 109: } 288,
{ 110: } 290,
{ 111: } 292,
{ 112: } 294,
{ 113: } 296,
{ 114: } 298,
{ 115: } 300,
{ 116: } 302,
{ 117: } 304,
{ 118: } 306,
{ 119: } 306,
{ 120: } 306,
{ 121: } 306,
{ 122: } 308,
{ 123: } 309,
{ 124: } 310,
{ 125: } 311,
{ 126: } 311,
{ 127: } 312,
{ 128: } 313,
{ 129: } 315,
{ 130: } 317,
{ 131: } 318,
{ 132: } 319,
{ 133: } 320,
{ 134: } 322,
{ 135: } 323,
{ 136: } 324,
{ 137: } 324,
{ 138: } 326,
{ 139: } 328,
{ 140: } 330,
{ 141: } 332,
{ 142: } 334,
{ 143: } 336,
{ 144: } 338,
{ 145: } 340,
{ 146: } 342,
{ 147: } 345,
{ 148: } 347,
{ 149: } 349,
{ 150: } 351,
{ 151: } 353,
{ 152: } 355,
{ 153: } 357,
{ 154: } 359,
{ 155: } 361,
{ 156: } 363,
{ 157: } 365,
{ 158: } 367,
{ 159: } 372,
{ 160: } 374,
{ 161: } 376,
{ 162: } 378,
{ 163: } 379,
{ 164: } 380,
{ 165: } 382,
{ 166: } 384,
{ 167: } 386,
{ 168: } 388,
{ 169: } 390,
{ 170: } 391,
{ 171: } 392,
{ 172: } 392,
{ 173: } 393,
{ 174: } 394,
{ 175: } 395,
{ 176: } 396,
{ 177: } 397,
{ 178: } 397,
{ 179: } 398,
{ 180: } 399,
{ 181: } 401,
{ 182: } 402,
{ 183: } 404,
{ 184: } 406,
{ 185: } 408,
{ 186: } 410,
{ 187: } 412,
{ 188: } 414,
{ 189: } 416,
{ 190: } 418,
{ 191: } 420,
{ 192: } 422,
{ 193: } 423,
{ 194: } 424,
{ 195: } 425,
{ 196: } 427,
{ 197: } 429,
{ 198: } 431,
{ 199: } 433,
{ 200: } 435,
{ 201: } 437,
{ 202: } 439,
{ 203: } 440,
{ 204: } 442,
{ 205: } 444,
{ 206: } 446,
{ 207: } 447,
{ 208: } 449,
{ 209: } 451,
{ 210: } 452,
{ 211: } 453,
{ 212: } 454,
{ 213: } 455,
{ 214: } 457,
{ 215: } 458,
{ 216: } 459,
{ 217: } 459,
{ 218: } 459,
{ 219: } 460,
{ 220: } 461,
{ 221: } 462,
{ 222: } 463,
{ 223: } 464,
{ 224: } 466,
{ 225: } 468,
{ 226: } 470,
{ 227: } 471,
{ 228: } 473,
{ 229: } 474,
{ 230: } 476,
{ 231: } 478,
{ 232: } 480,
{ 233: } 482,
{ 234: } 484,
{ 235: } 485,
{ 236: } 486,
{ 237: } 488,
{ 238: } 490,
{ 239: } 491,
{ 240: } 493,
{ 241: } 495,
{ 242: } 496,
{ 243: } 497,
{ 244: } 498,
{ 245: } 503,
{ 246: } 504,
{ 247: } 505,
{ 248: } 508,
{ 249: } 509,
{ 250: } 509,
{ 251: } 509,
{ 252: } 509,
{ 253: } 510,
{ 254: } 511,
{ 255: } 512,
{ 256: } 514,
{ 257: } 516,
{ 258: } 518,
{ 259: } 519,
{ 260: } 520,
{ 261: } 521,
{ 262: } 523,
{ 263: } 525,
{ 264: } 527,
{ 265: } 528,
{ 266: } 529,
{ 267: } 531,
{ 268: } 532,
{ 269: } 534,
{ 270: } 536,
{ 271: } 538,
{ 272: } 541,
{ 273: } 542,
{ 274: } 543,
{ 275: } 544,
{ 276: } 544,
{ 277: } 544,
{ 278: } 545,
{ 279: } 547,
{ 280: } 549,
{ 281: } 551,
{ 282: } 553,
{ 283: } 555,
{ 284: } 556,
{ 285: } 557,
{ 286: } 558,
{ 287: } 559,
{ 288: } 562,
{ 289: } 563,
{ 290: } 564,
{ 291: } 564,
{ 292: } 565,
{ 293: } 566,
{ 294: } 568,
{ 295: } 569,
{ 296: } 570,
{ 297: } 571,
{ 298: } 572,
{ 299: } 573,
{ 300: } 574,
{ 301: } 575,
{ 302: } 576,
{ 303: } 577,
{ 304: } 578,
{ 305: } 579,
{ 306: } 580,
{ 307: } 581,
{ 308: } 582,
{ 309: } 583,
{ 310: } 584,
{ 311: } 586,
{ 312: } 587,
{ 313: } 589,
{ 314: } 591,
{ 315: } 592,
{ 316: } 593,
{ 317: } 595,
{ 318: } 596,
{ 319: } 597,
{ 320: } 598,
{ 321: } 599,
{ 322: } 600,
{ 323: } 601,
{ 324: } 602,
{ 325: } 603,
{ 326: } 604,
{ 327: } 605,
{ 328: } 606,
{ 329: } 607,
{ 330: } 608,
{ 331: } 609,
{ 332: } 610,
{ 333: } 611,
{ 334: } 612,
{ 335: } 613,
{ 336: } 614,
{ 337: } 615,
{ 338: } 616,
{ 339: } 617,
{ 340: } 618,
{ 341: } 619,
{ 342: } 620,
{ 343: } 620,
{ 344: } 621,
{ 345: } 622,
{ 346: } 623,
{ 347: } 624,
{ 348: } 624,
{ 349: } 625,
{ 350: } 626,
{ 351: } 627,
{ 352: } 628,
{ 353: } 629,
{ 354: } 630,
{ 355: } 631,
{ 356: } 632,
{ 357: } 633,
{ 358: } 634,
{ 359: } 635,
{ 360: } 636,
{ 361: } 637,
{ 362: } 638,
{ 363: } 639,
{ 364: } 640,
{ 365: } 641,
{ 366: } 642,
{ 367: } 642,
{ 368: } 643
);

yyth : array [0..yynstates-1] of Integer = (
{ 0: } 55,
{ 1: } 110,
{ 2: } 112,
{ 3: } 114,
{ 4: } 116,
{ 5: } 119,
{ 6: } 124,
{ 7: } 130,
{ 8: } 131,
{ 9: } 132,
{ 10: } 133,
{ 11: } 135,
{ 12: } 137,
{ 13: } 145,
{ 14: } 145,
{ 15: } 145,
{ 16: } 145,
{ 17: } 145,
{ 18: } 145,
{ 19: } 145,
{ 20: } 145,
{ 21: } 145,
{ 22: } 145,
{ 23: } 145,
{ 24: } 145,
{ 25: } 145,
{ 26: } 146,
{ 27: } 149,
{ 28: } 152,
{ 29: } 156,
{ 30: } 158,
{ 31: } 160,
{ 32: } 162,
{ 33: } 164,
{ 34: } 166,
{ 35: } 169,
{ 36: } 171,
{ 37: } 175,
{ 38: } 175,
{ 39: } 175,
{ 40: } 177,
{ 41: } 179,
{ 42: } 181,
{ 43: } 183,
{ 44: } 186,
{ 45: } 188,
{ 46: } 190,
{ 47: } 192,
{ 48: } 194,
{ 49: } 196,
{ 50: } 198,
{ 51: } 199,
{ 52: } 199,
{ 53: } 199,
{ 54: } 199,
{ 55: } 200,
{ 56: } 200,
{ 57: } 200,
{ 58: } 200,
{ 59: } 202,
{ 60: } 202,
{ 61: } 204,
{ 62: } 204,
{ 63: } 206,
{ 64: } 208,
{ 65: } 209,
{ 66: } 214,
{ 67: } 215,
{ 68: } 215,
{ 69: } 216,
{ 70: } 218,
{ 71: } 221,
{ 72: } 221,
{ 73: } 221,
{ 74: } 221,
{ 75: } 221,
{ 76: } 221,
{ 77: } 221,
{ 78: } 221,
{ 79: } 221,
{ 80: } 223,
{ 81: } 229,
{ 82: } 232,
{ 83: } 233,
{ 84: } 240,
{ 85: } 241,
{ 86: } 242,
{ 87: } 243,
{ 88: } 245,
{ 89: } 247,
{ 90: } 249,
{ 91: } 251,
{ 92: } 253,
{ 93: } 255,
{ 94: } 257,
{ 95: } 260,
{ 96: } 262,
{ 97: } 264,
{ 98: } 266,
{ 99: } 268,
{ 100: } 270,
{ 101: } 272,
{ 102: } 275,
{ 103: } 277,
{ 104: } 279,
{ 105: } 281,
{ 106: } 283,
{ 107: } 285,
{ 108: } 287,
{ 109: } 289,
{ 110: } 291,
{ 111: } 293,
{ 112: } 295,
{ 113: } 297,
{ 114: } 299,
{ 115: } 301,
{ 116: } 303,
{ 117: } 305,
{ 118: } 305,
{ 119: } 305,
{ 120: } 305,
{ 121: } 307,
{ 122: } 308,
{ 123: } 309,
{ 124: } 310,
{ 125: } 310,
{ 126: } 311,
{ 127: } 312,
{ 128: } 314,
{ 129: } 316,
{ 130: } 317,
{ 131: } 318,
{ 132: } 319,
{ 133: } 321,
{ 134: } 322,
{ 135: } 323,
{ 136: } 323,
{ 137: } 325,
{ 138: } 327,
{ 139: } 329,
{ 140: } 331,
{ 141: } 333,
{ 142: } 335,
{ 143: } 337,
{ 144: } 339,
{ 145: } 341,
{ 146: } 344,
{ 147: } 346,
{ 148: } 348,
{ 149: } 350,
{ 150: } 352,
{ 151: } 354,
{ 152: } 356,
{ 153: } 358,
{ 154: } 360,
{ 155: } 362,
{ 156: } 364,
{ 157: } 366,
{ 158: } 371,
{ 159: } 373,
{ 160: } 375,
{ 161: } 377,
{ 162: } 378,
{ 163: } 379,
{ 164: } 381,
{ 165: } 383,
{ 166: } 385,
{ 167: } 387,
{ 168: } 389,
{ 169: } 390,
{ 170: } 391,
{ 171: } 391,
{ 172: } 392,
{ 173: } 393,
{ 174: } 394,
{ 175: } 395,
{ 176: } 396,
{ 177: } 396,
{ 178: } 397,
{ 179: } 398,
{ 180: } 400,
{ 181: } 401,
{ 182: } 403,
{ 183: } 405,
{ 184: } 407,
{ 185: } 409,
{ 186: } 411,
{ 187: } 413,
{ 188: } 415,
{ 189: } 417,
{ 190: } 419,
{ 191: } 421,
{ 192: } 422,
{ 193: } 423,
{ 194: } 424,
{ 195: } 426,
{ 196: } 428,
{ 197: } 430,
{ 198: } 432,
{ 199: } 434,
{ 200: } 436,
{ 201: } 438,
{ 202: } 439,
{ 203: } 441,
{ 204: } 443,
{ 205: } 445,
{ 206: } 446,
{ 207: } 448,
{ 208: } 450,
{ 209: } 451,
{ 210: } 452,
{ 211: } 453,
{ 212: } 454,
{ 213: } 456,
{ 214: } 457,
{ 215: } 458,
{ 216: } 458,
{ 217: } 458,
{ 218: } 459,
{ 219: } 460,
{ 220: } 461,
{ 221: } 462,
{ 222: } 463,
{ 223: } 465,
{ 224: } 467,
{ 225: } 469,
{ 226: } 470,
{ 227: } 472,
{ 228: } 473,
{ 229: } 475,
{ 230: } 477,
{ 231: } 479,
{ 232: } 481,
{ 233: } 483,
{ 234: } 484,
{ 235: } 485,
{ 236: } 487,
{ 237: } 489,
{ 238: } 490,
{ 239: } 492,
{ 240: } 494,
{ 241: } 495,
{ 242: } 496,
{ 243: } 497,
{ 244: } 502,
{ 245: } 503,
{ 246: } 504,
{ 247: } 507,
{ 248: } 508,
{ 249: } 508,
{ 250: } 508,
{ 251: } 508,
{ 252: } 509,
{ 253: } 510,
{ 254: } 511,
{ 255: } 513,
{ 256: } 515,
{ 257: } 517,
{ 258: } 518,
{ 259: } 519,
{ 260: } 520,
{ 261: } 522,
{ 262: } 524,
{ 263: } 526,
{ 264: } 527,
{ 265: } 528,
{ 266: } 530,
{ 267: } 531,
{ 268: } 533,
{ 269: } 535,
{ 270: } 537,
{ 271: } 540,
{ 272: } 541,
{ 273: } 542,
{ 274: } 543,
{ 275: } 543,
{ 276: } 543,
{ 277: } 544,
{ 278: } 546,
{ 279: } 548,
{ 280: } 550,
{ 281: } 552,
{ 282: } 554,
{ 283: } 555,
{ 284: } 556,
{ 285: } 557,
{ 286: } 558,
{ 287: } 561,
{ 288: } 562,
{ 289: } 563,
{ 290: } 563,
{ 291: } 564,
{ 292: } 565,
{ 293: } 567,
{ 294: } 568,
{ 295: } 569,
{ 296: } 570,
{ 297: } 571,
{ 298: } 572,
{ 299: } 573,
{ 300: } 574,
{ 301: } 575,
{ 302: } 576,
{ 303: } 577,
{ 304: } 578,
{ 305: } 579,
{ 306: } 580,
{ 307: } 581,
{ 308: } 582,
{ 309: } 583,
{ 310: } 585,
{ 311: } 586,
{ 312: } 588,
{ 313: } 590,
{ 314: } 591,
{ 315: } 592,
{ 316: } 594,
{ 317: } 595,
{ 318: } 596,
{ 319: } 597,
{ 320: } 598,
{ 321: } 599,
{ 322: } 600,
{ 323: } 601,
{ 324: } 602,
{ 325: } 603,
{ 326: } 604,
{ 327: } 605,
{ 328: } 606,
{ 329: } 607,
{ 330: } 608,
{ 331: } 609,
{ 332: } 610,
{ 333: } 611,
{ 334: } 612,
{ 335: } 613,
{ 336: } 614,
{ 337: } 615,
{ 338: } 616,
{ 339: } 617,
{ 340: } 618,
{ 341: } 619,
{ 342: } 619,
{ 343: } 620,
{ 344: } 621,
{ 345: } 622,
{ 346: } 623,
{ 347: } 623,
{ 348: } 624,
{ 349: } 625,
{ 350: } 626,
{ 351: } 627,
{ 352: } 628,
{ 353: } 629,
{ 354: } 630,
{ 355: } 631,
{ 356: } 632,
{ 357: } 633,
{ 358: } 634,
{ 359: } 635,
{ 360: } 636,
{ 361: } 637,
{ 362: } 638,
{ 363: } 639,
{ 364: } 640,
{ 365: } 641,
{ 366: } 641,
{ 367: } 642,
{ 368: } 642
);


var yyn : Integer;

label start, scan, action;

begin

start:

  (* initialize: *)

  yynew;

scan:

  (* mark positions and matches: *)

  for yyn := yykl[yystate] to     yykh[yystate] do yymark(yyk[yyn]);
  for yyn := yymh[yystate] downto yyml[yystate] do yymatch(yym[yyn]);

  if yytl[yystate]>yyth[yystate] then goto action; (* dead state *)

  (* get next character: *)

  yyscan;

  (* determine action: *)

  yyn := yytl[yystate];
  while (yyn<=yyth[yystate]) and not (yyactchar in yyt[yyn].cc) do inc(yyn);
  if yyn>yyth[yystate] then goto action;
    (* no transition on yyactchar in this state *)

  (* switch to new state: *)

  yystate := yyt[yyn].s;

  goto scan;

action:

  (* execute action: *)

  if yyfind(yyrule) then
    begin
      yyaction(yyrule);
      if yyreject then goto action;
    end
  else if not yydefault and yywrap() then
    begin
      yyclear;
      return(0);
    end;

  if not yydone then goto start;

  yylex := yyretval;

end(*yylex*);




function act_token : string;
begin
  act_token:=yytext;
end;

end.




