{
    DFA

    Copyright (c) 2007 by Florian Klaempfl

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

{ $define DEBUG_DFA}
{ $define EXTDEBUG_DFA}

{ this unit implements routines to perform dfa }
unit optdfa;

{$i fpcdefs.inc}

  interface

    uses
      node;

    { reset all dfa info, this is required before creating dfa info
      if the tree has been changed without updating dfa }
    procedure resetdfainfo(node : tnode);

    procedure createdfainfo(node : tnode);

  implementation

    uses
      globtype,globals,
      verbose,
      cpuinfo,
      symconst,symdef,
      defutil,
      procinfo,
      nutils,
      nbas,nflw,ncon,ninl,ncal,nset,
      optbase,optutils;


    (*
    function initnodes(var n:tnode; arg: pointer) : foreachnoderesult;
      begin
        { node worth to add? }
        if (node_complexity(n)>1) and (tstoreddef(n.resultdef).is_intregable or tstoreddef(n.resultdef).is_fpuregable) then
          begin
            plists(arg)^.nodelist.Add(n);
            plists(arg)^.locationlist.Add(@n);
            result:=fen_false;
          end
        else
          result:=fen_norecurse_false;
      end;
    *)

    {
      x:=f;         read: [f]

      while x do    read: []

        a:=b;       read: [a,b,d]  def: [a]       life:  read*def=[a]
          c:=d;     read: [a,d]    def: [a,c]     life:  read*def=[a]
            e:=a;   read: [a]      def: [a,c,e]   life:  read*def=[a]


      function f(b,d,x : type) : type;

        begin
          while x do        alive: b,d,x
            begin
              a:=b;         alive: b,d,x
              c:=d;         alive: a,d,x
              e:=a+c;       alive: a,c,x
              dec(x);       alive: c,e,x
            end;
          result:=c+e;      alive: c,e
        end;                alive: result

    }

    type
      tdfainfo = record
        use : PDFASet;
        def : PDFASet;
        map : TIndexedNodeSet
      end;
      pdfainfo = ^tdfainfo;

    function AddDefUse(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        case n.nodetype of
          loadn:
            begin
              pdfainfo(arg)^.map.Add(n);
              if nf_write in n.flags then
                DFASetInclude(pdfainfo(arg)^.def^,n.optinfo^.index)
              else
                DFASetInclude(pdfainfo(arg)^.use^,n.optinfo^.index);
              {
              write('Use Set: ');
              PrintDFASet(output,pdfainfo(arg)^.use^);
              write(' Def Set: ');
              PrintDFASet(output,pdfainfo(arg)^.def^);
              writeln;
              }
            end;
        end;
        result:=fen_false;
      end;


    function ResetProcessing(var n: tnode; arg: pointer): foreachnoderesult;
      begin
        exclude(n.flags,nf_processing);
        result:=fen_false;
      end;


    procedure CreateLifeInfo(node : tnode;map : TIndexedNodeSet);

      var
        changed : boolean;
        Resultnode : TNode;

      procedure CreateInfo(node : tnode);

        { update life entry of a node with l, set changed if this changes
          life info for the node
        }
        procedure updatelifeinfo(n : tnode;l : TDFASet);
          var
            b : boolean;
          begin
            b:=DFASetNotEqual(l,n.optinfo^.life);
            {
            if b then
              begin
                printnode(output,n);
                printdfaset(output,l);
                writeln;
                printdfaset(output,n.optinfo^.life);
                writeln;
              end;
            }
{$ifdef DEBUG_DFA}
            if not(changed) and b then
              writeln('Another DFA pass caused by: ',nodetype2str[n.nodetype],'(',n.fileinfo.line,',',n.fileinfo.column,')');
{$endif DEBUG_DFA}

            changed:=changed or b;
            node.optinfo^.life:=l;
          end;

        procedure calclife(n : tnode);
          var
            l : TDFASet;
          begin
            if assigned(n.successor) then
              begin
                {
                write('Successor Life: ');
                printdfaset(output,n.successor.optinfo^.life);
                writeln;
                write('Def.');
                printdfaset(output,n.optinfo^.def);
                writeln;
                }
                { ensure we can access optinfo }
                DFASetDiff(l,n.successor.optinfo^.life,n.optinfo^.def);
                {
                printdfaset(output,l);
                writeln;
                }
                DFASetIncludeSet(l,n.optinfo^.use);
                DFASetIncludeSet(l,n.optinfo^.life);
              end
            else
              begin
                l:=n.optinfo^.use;
                DFASetIncludeSet(l,n.optinfo^.life);
              end;
            updatelifeinfo(n,l);
          end;

        var
          dfainfo : tdfainfo;
          l : TDFASet;
          i : longint;

        begin
          if node=nil then
            exit;

          { ensure we've already optinfo set }
          node.allocoptinfo;

          if nf_processing in node.flags then
            exit;
          include(node.flags,nf_processing);

          if assigned(node.successor) then
            CreateInfo(node.successor);

{$ifdef EXTDEBUG_DFA}
          writeln('Handling: ',nodetype2str[node.nodetype],'(',node.fileinfo.line,',',node.fileinfo.column,')');
{$endif EXTDEBUG_DFA}
          { life:=succesorlive-definition+use }

          case node.nodetype of
            whilerepeatn:
              begin
                calclife(node);
                { take care of repeat until! }
                if lnf_testatbegin in twhilerepeatnode(node).loopflags then
                  begin
                    node.allocoptinfo;
                    if not(assigned(node.optinfo^.def)) and
                       not(assigned(node.optinfo^.use)) then
                      begin
                        dfainfo.use:=@node.optinfo^.use;
                        dfainfo.def:=@node.optinfo^.def;
                        dfainfo.map:=map;
                        foreachnodestatic(pm_postprocess,twhilerepeatnode(node).left,@AddDefUse,@dfainfo);
                      end;
                    calclife(node);

                    { now iterate through the loop }
                    CreateInfo(twhilerepeatnode(node).right);

                    { update while node }
                    { life:=life+use+right.life }
                    l:=node.optinfo^.life;
                    DFASetIncludeSet(l,node.optinfo^.use);
                    DFASetIncludeSet(l,twhilerepeatnode(node).right.optinfo^.life);
                    UpdateLifeInfo(node,l);

                    { ... and a second iteration for fast convergence }
                    CreateInfo(twhilerepeatnode(node).right);
                  end;
              end;

            forn:
              begin
                {
                  left: loopvar
                  right: from
                  t1: to
                  t2: body
                }
                calclife(node);
                node.allocoptinfo;
                if not(assigned(node.optinfo^.def)) and
                   not(assigned(node.optinfo^.use)) then
                  begin
                    dfainfo.use:=@node.optinfo^.use;
                    dfainfo.def:=@node.optinfo^.def;
                    dfainfo.map:=map;
                    foreachnodestatic(pm_postprocess,tfornode(node).left,@AddDefUse,@dfainfo);
                    foreachnodestatic(pm_postprocess,tfornode(node).right,@AddDefUse,@dfainfo);
                    foreachnodestatic(pm_postprocess,tfornode(node).t1,@AddDefUse,@dfainfo);
                  end;
                calclife(node);

                { create life the body }
                CreateInfo(tfornode(node).t2);

                { update for node }
                { life:=life+use+body }
                l:=node.optinfo^.life;
                DFASetIncludeSet(l,node.optinfo^.use);
                DFASetIncludeSet(l,tfornode(node).t2.optinfo^.life);
                UpdateLifeInfo(node,l);

                { ... and a second iteration for fast convergence }
                CreateInfo(tfornode(node).t2);
              end;

            assignn:
              begin
                if not(assigned(node.optinfo^.def)) and
                  not(assigned(node.optinfo^.use)) then
                  begin
                    dfainfo.use:=@node.optinfo^.use;
                    dfainfo.def:=@node.optinfo^.def;
                    dfainfo.map:=map;
                    foreachnodestatic(pm_postprocess,node,@AddDefUse,@dfainfo);
                  end;
                calclife(node);
              end;

            statementn:
              begin
                { nested statement }
                CreateInfo(tstatementnode(node).statement);
                { inherit info }
                node.optinfo^.life:=tstatementnode(node).statement.optinfo^.life;
              end;

            blockn:
              begin
                CreateInfo(tblocknode(node).statements);
                if assigned(tblocknode(node).statements) then
                  node.optinfo^.life:=tblocknode(node).statements.optinfo^.life;
              end;

            ifn:
              begin
                { get information from cond. expression }
                if not(assigned(node.optinfo^.def)) and
                   not(assigned(node.optinfo^.use)) then
                  begin
                    dfainfo.use:=@node.optinfo^.use;
                    dfainfo.def:=@node.optinfo^.def;
                    dfainfo.map:=map;
                    foreachnodestatic(pm_postprocess,tifnode(node).left,@AddDefUse,@dfainfo);
                  end;
                { create life info for then and else node }
                CreateInfo(tifnode(node).right);
                CreateInfo(tifnode(node).t1);

                { ensure that we don't remove life info }
                l:=node.optinfo^.life;

                { get life info from then branch }
                if assigned(tifnode(node).right) then
                  DFASetIncludeSet(l,tifnode(node).right.optinfo^.life);
                { get life info from else branch }
                if assigned(tifnode(node).t1) then
                  DFASetIncludeSet(l,tifnode(node).t1.optinfo^.life)
                else
                  if assigned(node.successor) then
                    DFASetIncludeSet(l,node.successor.optinfo^.life);
                { add use info from the cond. expression }
                DFASetIncludeSet(l,tifnode(node).optinfo^.use);
                { finally, update the life info of the node }
                UpdateLifeInfo(node,l);
              end;

            casen:
              begin
                { get information from "case" expression }
                if not(assigned(node.optinfo^.def)) and
                   not(assigned(node.optinfo^.use)) then
                  begin
                    dfainfo.use:=@node.optinfo^.use;
                    dfainfo.def:=@node.optinfo^.def;
                    dfainfo.map:=map;
                    foreachnodestatic(pm_postprocess,tcasenode(node).left,@AddDefUse,@dfainfo);
                  end;

                { create life info for block and else nodes }
                for i:=0 to tcasenode(node).blocks.count-1 do
                  CreateInfo(pcaseblock(tcasenode(node).blocks[i])^.statement);

                CreateInfo(tcasenode(node).elseblock);

                { ensure that we don't remove life info }
                l:=node.optinfo^.life;

                { get life info from case branches }
                for i:=0 to tcasenode(node).blocks.count-1 do
                  DFASetIncludeSet(l,pcaseblock(tcasenode(node).blocks[i])^.statement.optinfo^.life);

                { get life info from else branch or the succesor }
                if assigned(tcasenode(node).elseblock) then
                  DFASetIncludeSet(l,tcasenode(node).elseblock.optinfo^.life)
                else
                  if assigned(node.successor) then
                    DFASetIncludeSet(l,node.successor.optinfo^.life);

                { add use info from the "case" expression }
                DFASetIncludeSet(l,tcasenode(node).optinfo^.use);

                { finally, update the life info of the node }
                UpdateLifeInfo(node,l);
              end;

            exitn:
              begin
                if not(is_void(current_procinfo.procdef.returndef)) and
                  not(current_procinfo.procdef.proctypeoption=potype_constructor) then
                  begin
                    { get info from faked resultnode }
                    node.optinfo^.use:=resultnode.optinfo^.use;
                    node.optinfo^.life:=node.optinfo^.use;
                  end;
              end;

            raisen:
              begin
                calclife(node);
                node.allocoptinfo;
                if not(assigned(node.optinfo^.def)) and
                   not(assigned(node.optinfo^.use)) then
                  begin
                    dfainfo.use:=@node.optinfo^.use;
                    dfainfo.def:=@node.optinfo^.def;
                    dfainfo.map:=map;
                    foreachnodestatic(pm_postprocess,traisenode(node).left,@AddDefUse,@dfainfo);
                    foreachnodestatic(pm_postprocess,traisenode(node).right,@AddDefUse,@dfainfo);
                    foreachnodestatic(pm_postprocess,traisenode(node).third,@AddDefUse,@dfainfo);
                  end;
                calclife(node);
              end;

            calln:
              begin
                if not(assigned(node.optinfo^.def)) and
                  not(assigned(node.optinfo^.use)) then
                  begin
                    dfainfo.use:=@node.optinfo^.use;
                    dfainfo.def:=@node.optinfo^.def;
                    dfainfo.map:=map;
                    foreachnodestatic(pm_postprocess,node,@AddDefUse,@dfainfo);
                  end;
                calclife(node);
              end;

            tempcreaten,
            tempdeleten,
            inlinen,
            nothingn,
            continuen,
            goton,
            breakn,
            labeln:
              begin
                calclife(node);
              end;
            else
              begin
                writeln(nodetype2str[node.nodetype]);
                internalerror(2007050502);
              end;
          end;

          // exclude(node.flags,nf_processing);
        end;

      var
        runs : integer;
        dfarec : tdfainfo;
      begin
        runs:=0;
        if not(is_void(current_procinfo.procdef.returndef)) and
          not(current_procinfo.procdef.proctypeoption=potype_constructor) then
          begin
            { create a fake node using the result }
            resultnode:=load_result_node;
            resultnode.allocoptinfo;
            dfarec.use:=@resultnode.optinfo^.use;
            dfarec.def:=@resultnode.optinfo^.def;
            dfarec.map:=map;
            AddDefUse(resultnode,@dfarec);
          end
        else
          resultnode:=nil;

        repeat
          inc(runs);
          changed:=false;
          CreateInfo(node);
          foreachnodestatic(pm_postprocess,node,@ResetProcessing,nil);
{$ifdef DEBUG_DFA}
          PrintIndexedNodeSet(output,map);
          PrintDFAInfo(output,node);
{$endif DEBUG_DFA}
        until not(changed);
{$ifdef DEBUG_DFA}
        writeln('DFA solver iterations: ',runs);
{$endif DEBUG_DFA}
        resultnode.free;
      end;


    { reset all dfa info, this is required before creating dfa info
      if the tree has been changed without updating dfa }
    procedure resetdfainfo(node : tnode);
      begin
      end;


    procedure createdfainfo(node : tnode);
      begin
        if not(assigned(current_procinfo.nodemap)) then
          current_procinfo.nodemap:=TIndexedNodeSet.Create;
        { add controll flow information }
        SetNodeSucessors(node);

        { now, collect life information }
        CreateLifeInfo(node,current_procinfo.nodemap);
      end;

end.
