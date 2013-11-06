{
    Dead store elimination

    Copyright (c) 2005-2012 by Jeppe Johansen and Florian Klaempfl

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
unit optdeadstore;

{$i fpcdefs.inc}

{ $define DEBUG_DEADSTORE}

  interface

    uses
      node;

    function do_optdeadstoreelim(var rootnode : tnode) : tnode;

  implementation

    uses
      verbose,globtype,
      fmodule,
      procinfo,pass_1,
      nutils,
      nbas,nld,nmem,nflw,nset,
      optbase,
      symsym,symconst;


    function deadstoreelim(var n: tnode; arg: pointer): foreachnoderesult;
      var
        a: tassignmentnode;
        redundant: boolean;
      begin
        result:=fen_true;
        if (n.nodetype=statementn) and
           assigned(tstatementnode(n).statement) then
          begin
            if tstatementnode(n).statement.nodetype=assignn then
              begin
                a:=tassignmentnode(tstatementnode(n).statement);

                { we need to have dfa for the node }
                if assigned(a.left.optinfo) and
                   (a.left.optinfo^.index<>aword(-1)) and
                   { node must be either a local or parameter load node }
                   (((a.left.nodetype=loadn) and
                     (tloadnode(a.left).symtableentry.typ=localvarsym) and
                     (tloadnode(a.left).symtable=current_procinfo.procdef.localst)) or
                    ((a.left.nodetype=loadn) and
                     (tloadnode(a.left).symtableentry.typ=paravarsym) and
                     (tloadnode(a.left).symtable=current_procinfo.procdef.parast) and
                     (tparavarsym(tloadnode(a.left).symtableentry).varspez in [vs_const,vs_value]))
                    ) and
                    not(might_have_sideeffects(a.right)) then
                  begin
                    redundant:=not(assigned(a.successor)) or not(DFASetIn(a.successor.optinfo^.life,a.left.optinfo^.index));

                    if redundant then
                      begin
{$ifdef DEBUG_DEADSTORE}
                        writeln('************************** Redundant write *********************************');
                        printnode(a);
                        writeln('****************************************************************************');
{$endif DEBUG_DEADSTORE}
                        pboolean(arg)^:=true;

                        tstatementnode(n).statement.free;

                        tstatementnode(n).statement:=cnothingnode.create;
                        Exclude(tstatementnode(n).flags, nf_pass1_done);
                        do_firstpass(n);
                      end
                  end;
              end;
          end;
      end;


    function do_optdeadstoreelim(var rootnode: tnode): tnode;
      var
        changed: boolean;
      begin
        if not(pi_dfaavailable in current_procinfo.flags) then
          internalerror(2013110201);
        if not current_procinfo.has_nestedprocs then
          begin
            changed:=false;
            foreachnodestatic(pm_postprocess, rootnode, @deadstoreelim, @changed);
          end;
        result:=rootnode;
      end;

end.

