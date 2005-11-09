{
    Copyright (c) 1998-2002 by Florian Klaempfl

    Generate i386 assembler for in set/case nodes

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
unit n386set;

{$i fpcdefs.inc}

interface

    uses
      globtype,
      node,nset,pass_1,ncgset;

    type
      ti386casenode = class(tcgcasenode)
         procedure optimizevalues(var max_linear_list:aint;var max_dist:aword);override;
         function  has_jumptable : boolean;override;
         procedure genjumptable(hp : pcaselabel;min_,max_ : aint);override;
         procedure genlinearlist(hp : pcaselabel);override;
      end;


implementation

    uses
      systems,
      verbose,globals,
      symconst,symdef,defutil,
      aasmbase,aasmtai,aasmcpu,
      cgbase,pass_2,
      ncon,
      cpubase,cpuinfo,procinfo,
      cga,cgutils,cgobj,ncgutil,
      cgx86;


{*****************************************************************************
                            TI386CASENODE
*****************************************************************************}

    procedure ti386casenode.optimizevalues(var max_linear_list:aint;var max_dist:aword);
      begin
        { a jump table crashes the pipeline! }
        if aktoptprocessor=Class386 then
          inc(max_linear_list,3)
        else if aktoptprocessor=ClassPentium then
          inc(max_linear_list,6)
        else if aktoptprocessor in [ClassPentium2,ClassPentium3] then
          inc(max_linear_list,9)
        else if aktoptprocessor=ClassPentium4 then
          inc(max_linear_list,14);
      end;


    function ti386casenode.has_jumptable : boolean;
      begin
        has_jumptable:=true;
      end;


    procedure ti386casenode.genjumptable(hp : pcaselabel;min_,max_ : aint);
      var
        table : tasmlabel;
        last : TConstExprInt;
        indexreg : tregister;
        href : treference;
        jumpsegment : TAAsmOutput;

        procedure genitem(t : pcaselabel);
          var
            i : aint;
          begin
            if assigned(t^.less) then
              genitem(t^.less);
            { fill possible hole }
            for i:=last+1 to t^._low-1 do
              jumpSegment.concat(Tai_const.Create_sym(elselabel));
            for i:=t^._low to t^._high do
              jumpSegment.concat(Tai_const.Create_sym(blocklabel(t^.blockid)));
            last:=t^._high;
            if assigned(t^.greater) then
              genitem(t^.greater);
          end;

      begin
        if (cs_create_smart in aktmoduleswitches) or
           (af_smartlink_sections in target_asm.flags) then
          jumpsegment:=current_procinfo.aktlocaldata
        else
          jumpsegment:=datasegment;
        if not(jumptable_no_range) then
          begin
             { case expr less than min_ => goto elselabel }
             cg.a_cmp_const_reg_label(exprasmlist,opsize,jmp_lt,aint(min_),hregister,elselabel);
             { case expr greater than max_ => goto elselabel }
             cg.a_cmp_const_reg_label(exprasmlist,opsize,jmp_gt,aint(max_),hregister,elselabel);
          end;
        objectlibrary.getlabel(table);
        { make it a 32bit register }
        indexreg:=cg.makeregsize(exprasmlist,hregister,OS_INT);
        cg.a_load_reg_reg(exprasmlist,opsize,OS_INT,hregister,indexreg);
        { create reference }
        reference_reset_symbol(href,table,0);
        href.offset:=(-aint(min_))*4;
        href.index:=indexreg;
        href.scalefactor:=4;
        emit_ref(A_JMP,S_NO,href);
        { generate jump table }
        if not(cs_littlesize in aktglobalswitches) then
          jumpSegment.concat(Tai_Align.Create_Op(4,0));
        jumpSegment.concat(Tai_label.Create(table));
        last:=min_;
        genitem(hp);
      end;


    procedure ti386casenode.genlinearlist(hp : pcaselabel);
      var
        first : boolean;
        lastrange : boolean;
        last : TConstExprInt;
        cond_lt,cond_le : tresflags;

        procedure genitem(t : pcaselabel);
          begin
             if assigned(t^.less) then
               genitem(t^.less);
             { need we to test the first value }
             if first and (t^._low>get_min_value(left.resulttype.def)) then
               begin
                 cg.a_cmp_const_reg_label(exprasmlist,opsize,jmp_lt,aint(t^._low),hregister,elselabel);
               end;
             if t^._low=t^._high then
               begin
                  if t^._low-last=0 then
                    cg.a_cmp_const_reg_label(exprasmlist, opsize, OC_EQ,0,hregister,blocklabel(t^.blockid))
                  else
                    begin
                      cg.a_op_const_reg(exprasmlist, OP_SUB, opsize, aint(t^._low-last), hregister);
                      cg.a_jmp_flags(exprasmlist,F_E,blocklabel(t^.blockid));
                    end;
                  last:=t^._low;
                  lastrange:=false;
               end
             else
               begin
                  { it begins with the smallest label, if the value }
                  { is even smaller then jump immediately to the    }
                  { ELSE-label                                }
                  if first then
                    begin
                       { have we to ajust the first value ? }
                       if (t^._low>get_min_value(left.resulttype.def)) then
                         cg.a_op_const_reg(exprasmlist, OP_SUB, opsize, aint(t^._low), hregister);
                    end
                  else
                    begin
                      { if there is no unused label between the last and the }
                      { present label then the lower limit can be checked    }
                      { immediately. else check the range in between:       }

                      cg.a_op_const_reg(exprasmlist, OP_SUB, opsize, aint(t^._low-last), hregister);
                      { no jump necessary here if the new range starts at }
                      { at the value following the previous one           }
                      if ((t^._low-last) <> 1) or
                         (not lastrange) then
                        cg.a_jmp_flags(exprasmlist,cond_lt,elselabel);
                    end;
                  {we need to use A_SUB, because A_DEC does not set the correct flags, therefor
                   using a_op_const_reg(OP_SUB) is not possible }
                  emit_const_reg(A_SUB,TCGSize2OpSize[opsize],aint(t^._high-t^._low),hregister);
                  cg.a_jmp_flags(exprasmlist,cond_le,blocklabel(t^.blockid));
                  last:=t^._high;
                  lastrange:=true;
               end;
             first:=false;
             if assigned(t^.greater) then
               genitem(t^.greater);
          end;

        begin
           if with_sign then
             begin
                cond_lt:=F_L;
                cond_le:=F_LE;
             end
           else
              begin
                cond_lt:=F_B;
                cond_le:=F_BE;
             end;
           { do we need to generate cmps? }
           if (with_sign and (min_label<0)) then
             genlinearcmplist(hp)
           else
             begin
                last:=0;
                lastrange:=false;
                first:=true;
                genitem(hp);
                cg.a_jmp_always(exprasmlist,elselabel);
             end;
        end;

begin
   ccasenode:=ti386casenode;
end.
