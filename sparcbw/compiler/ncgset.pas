{
    $Id: ncgset.pas,v 1.75 2005/02/14 17:13:06 peter Exp $
    Copyright (c) 1998-2002 by Florian Klaempfl and Carl Eric Codere

    Generate generic assembler for in set/case labels

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
unit ncgset;

{$i fpcdefs.inc}

interface

    uses
       globtype,globals,
       node,nset,cpubase,cgbase,cgobj,aasmbase,aasmtai;

    type
       tcgsetelementnode = class(tsetelementnode)
          procedure pass_2;override;
       end;

       tcginnode = class(tinnode)
          procedure pass_2;override;
       protected
          {# Routine to test bitnumber in bitnumber register on value
             in value register. The __result register should be set
             to one if the bit is set, otherwise __result register
             should be set to zero.

             Should be overriden on processors which have specific
             instructions to do bit tests.
          }

          procedure emit_bit_test_reg_reg(list : taasmoutput;
                                          bitsize: tcgsize; bitnumber,value : tregister;
                                          ressize: tcgsize; res :tregister);virtual;
       end;

       tcgcasenode = class(tcasenode)
          {
            Emits the case node statement. Contrary to the intel
            80x86 version, this version does not emit jump tables,
            because of portability problems.
          }
          procedure pass_2;override;

        protected
          with_sign : boolean;
          opsize : tcgsize;
          jmp_gt,jmp_lt,jmp_le : topcmp;
          { register with case expression }
          hregister,hregister2 : tregister;
          endlabel,elselabel : tasmlabel;

          { true, if we can omit the range check of the jump table }
          jumptable_no_range : boolean;
          { has the implementation jumptable support }
          min_label : tconstexprint;

          function  blocklabel(id:longint):tasmlabel;
          procedure optimizevalues(var max_linear_list:aint;var max_dist:aword);virtual;
          function  has_jumptable : boolean;virtual;
          procedure genjumptable(hp : pcaselabel;min_,max_ : aint); virtual;
          procedure genlinearlist(hp : pcaselabel); virtual;
          procedure genlinearcmplist(hp : pcaselabel); virtual;
       end;


implementation

    uses
      systems,
      verbose,
      symconst,symdef,defutil,
      paramgr,
      pass_2,tgobj,
      nbas,ncon,nflw,
      ncgutil,regvars,
      cgutils;


{*****************************************************************************
                          TCGSETELEMENTNODE
*****************************************************************************}

    procedure tcgsetelementnode.pass_2;
       begin
       { load first value in 32bit register }
         secondpass(left);
         if left.location.loc in [LOC_REGISTER,LOC_CREGISTER] then
           location_force_reg(exprasmlist,left.location,OS_32,false);

       { also a second value ? }
         if assigned(right) then
           begin
             secondpass(right);
             if codegenerror then
               exit;
             if right.location.loc in [LOC_REGISTER,LOC_CREGISTER] then
              location_force_reg(exprasmlist,right.location,OS_32,false);
           end;

         { we doesn't modify the left side, we check only the type }
         location_copy(location,left.location);
       end;


{*****************************************************************************
*****************************************************************************}

  {**********************************************************************}
  {  Description: Emit operation to do a bit test, where the bitnumber   }
  {  to test is in the bitnumber register. The value to test against is  }
  {  located in the value register.                                      }
  {   WARNING: Bitnumber register value is DESTROYED!                    }
  {  __Result register is set to 1, if the bit is set otherwise, __Result}
  {   is set to zero. __RESULT register is also used as scratch.         }
  {**********************************************************************}
  procedure tcginnode.emit_bit_test_reg_reg(list : taasmoutput;
                                            bitsize: tcgsize; bitnumber,value : tregister;
                                            ressize: tcgsize; res :tregister);
    begin
      { first make sure that the bit number is modulo 32 }

      { not necessary, since if it's > 31, we have a range error -> will }
      { be caught when range checking is on! (JM)                        }
      { cg.a_op_const_reg(list,OP_AND,31,bitnumber);                     }

      if bitsize<>ressize then
        begin
          { FIX ME! We're not allowed to modify the value register here! }

          { shift value register "bitnumber" bits to the right }
          cg.a_op_reg_reg(list,OP_SHR,bitsize,bitnumber,value);
          { extract the bit we want }
          cg.a_op_const_reg(list,OP_AND,bitsize,1,value);
          cg.a_load_reg_reg(list,bitsize,ressize,value,res);
        end
      else
        begin
          { rotate value register "bitnumber" bits to the right }
          cg.a_op_reg_reg_reg(list,OP_SHR,bitsize,bitnumber,value,res);
          { extract the bit we want }
          cg.a_op_const_reg(list,OP_AND,bitsize,1,res);
        end;
    end;


    procedure tcginnode.pass_2;
       type
         Tsetpart=record
           range : boolean;      {Part is a range.}
           start,stop : byte;    {Start/stop when range; Stop=element when an element.}
         end;
       var
         l,l3       : tasmlabel;
         adjustment : aint;
         href : treference;
         hr,hr2,
         pleftreg   : tregister;
         setparts   : array[1..8] of Tsetpart;
         opsize     : tcgsize;
         genjumps,
         use_small  : boolean;
         i,numparts : byte;

         function analizeset(const Aset:Tconstset;is_small:boolean):boolean;
           var
             compares,maxcompares:word;
             i:byte;
           begin
             analizeset:=false;
             numparts:=0;
             compares:=0;
             { Lots of comparisions take a lot of time, so do not allow
               too much comparisions. 8 comparisions are, however, still
               smalller than emitting the set }
             if cs_littlesize in aktglobalswitches then
              maxcompares:=8
             else
              maxcompares:=5;
             { when smallset is possible allow only 3 compares the smallset
               code is for littlesize also smaller when more compares are used }
             if is_small then
              maxcompares:=3;
             for i:=0 to 255 do
              if i in Aset then
               begin
                 if (numparts=0) or (i<>setparts[numparts].stop+1) then
                  begin
                  {Set element is a separate element.}
                    inc(compares);
                    if compares>maxcompares then
                         exit;
                    inc(numparts);
                    setparts[numparts].range:=false;
                    setparts[numparts].stop:=i;
                  end
                 else
                  {Set element is part of a range.}
                  if not setparts[numparts].range then
                   begin
                     {Transform an element into a range.}
                     setparts[numparts].range:=true;
                     setparts[numparts].start:=setparts[numparts].stop;
                     setparts[numparts].stop:=i;
                     { there's only one compare per range anymore. Only a }
                     { sub is added, but that's much faster than a        }
                     { cmp/jcc combo so neglect its effect                }
{                     inc(compares);
                     if compares>maxcompares then
                      exit; }
                   end
                  else
                   begin
                    {Extend a range.}
                    setparts[numparts].stop:=i;
                   end;
              end;
             analizeset:=true;
           end;

       begin
         { We check first if we can generate jumps, this can be done
           because the resulttype.def is already set in firstpass }

         { check if we can use smallset operation using btl which is limited
           to 32 bits, the left side may also not contain higher values !! }
         use_small:=(tsetdef(right.resulttype.def).settype=smallset) and
                    ((left.resulttype.def.deftype=orddef) and (torddef(left.resulttype.def).high<=32) or
                     (left.resulttype.def.deftype=enumdef) and (tenumdef(left.resulttype.def).max<=32));

         { Can we generate jumps? Possible for all types of sets }
         genjumps:=(right.nodetype=setconstn) and
                   analizeset(Tsetconstnode(right).value_set^,use_small);

         opsize:=OS_32;

         { calculate both operators }
         { the complex one first }
         firstcomplex(self);
         secondpass(left);
         { Only process the right if we are not generating jumps }
         if not genjumps then
           secondpass(right);
         if codegenerror then
           exit;

         { ofcourse not commutative }
         if nf_swaped in flags then
          swapleftright;

         { location is always LOC_JUMP }
         location_reset(location,LOC_REGISTER,def_cgsize(resulttype.def));

         if genjumps then
          begin
            { allocate a register for the result }
            location.register := cg.getintregister(exprasmlist,location.size);
            { Get a label to jump to the end }
            objectlibrary.getlabel(l);

            { clear the register value, indicating result is FALSE }
            cg.a_load_const_reg(exprasmlist,location.size,0,location.register);
            { If register is used, use only lower 8 bits }
            location_force_reg(exprasmlist,left.location,opsize,false);
            pleftreg := left.location.register;

            { how much have we already substracted from the x in the }
            { "x in [y..z]" expression                               }
            adjustment := 0;
            hr:=NR_NO;

            for i:=1 to numparts do
             if setparts[i].range then
              { use fact that a <= x <= b <=> aword(x-a) <= aword(b-a) }
              begin
                { is the range different from all legal values? }
                if (setparts[i].stop-setparts[i].start <> 255) then
                  begin
                    { yes, is the lower bound <> 0? }
                    if (setparts[i].start <> 0) then
                      { we're going to substract from the left register,   }
                      { so in case of a LOC_CREGISTER first move the value }
                      { to edi (not done before because now we can do the  }
                      { move and substract in one instruction with LEA)    }
                      if (left.location.loc = LOC_CREGISTER) and
                         (hr<>pleftreg) then
                        begin
                          cg.a_op_const_reg(exprasmlist,OP_SUB,opsize,setparts[i].start,pleftreg);
                          hr:=cg.getintregister(exprasmlist,opsize);
                          cg.a_load_reg_reg(exprasmlist,opsize,opsize,pleftreg,hr);
                          pleftreg:=hr;
                        end
                      else
                        begin
                          { otherwise, the value is already in a register   }
                          { that can be modified                            }
                          cg.a_op_const_reg(exprasmlist,OP_SUB,opsize,
                             setparts[i].start-adjustment,pleftreg)
                        end;
                    { new total value substracted from x:           }
                    { adjustment + (setparts[i].start - adjustment) }
                    adjustment := setparts[i].start;

                    { check if result < b-a+1 (not "result <= b-a", since }
                    { we need a carry in case the element is in the range }
                    { (this will never overflow since we check at the     }
                    { beginning whether stop-start <> 255)                }
                    cg.a_cmp_const_reg_label(exprasmlist, opsize, OC_B,
                      setparts[i].stop-setparts[i].start+1,pleftreg,l);
                  end
                else
                  { if setparts[i].start = 0 and setparts[i].stop = 255,  }
                  { it's always true since "in" is only allowed for bytes }
                  begin
                    cg.a_jmp_always(exprasmlist,l);
                  end;
              end
             else
              begin
                { Emit code to check if left is an element }
                cg.a_cmp_const_reg_label(exprasmlist, opsize, OC_EQ,
                      setparts[i].stop-adjustment,pleftreg,l);
              end;
             { To compensate for not doing a second pass }
             right.location.reference.symbol:=nil;
             objectlibrary.getlabel(l3);
             cg.a_jmp_always(exprasmlist,l3);
             { Now place the end label if IN success }
             cg.a_label(exprasmlist,l);
             { result register is 1 }
             cg.a_load_const_reg(exprasmlist,location.size,1,location.register);
             { in case value is not found }
             cg.a_label(exprasmlist,l3);
          end
         else
         {*****************************************************************}
         {                     NO JUMP TABLE GENERATION                    }
         {*****************************************************************}
          begin
            { We will now generated code to check the set itself, no jmps,
              handle smallsets separate, because it allows faster checks }
            if use_small then
             begin
               {****************************  SMALL SET **********************}
               if left.nodetype=ordconstn then
                begin
                  location_force_reg(exprasmlist,right.location,opsize,true);
                  location.register:=cg.getintregister(exprasmlist,location.size);
                  { first SHR the register }
                  cg.a_op_const_reg_reg(exprasmlist,OP_SHR,opsize,tordconstnode(left).value and 31,right.location.register,location.register);
                  { then extract the lowest bit }
                  cg.a_op_const_reg(exprasmlist,OP_AND,opsize,1,location.register);
                end
               else
                begin
                  location_force_reg(exprasmlist,left.location,opsize,false);
                  location_force_reg(exprasmlist,right.location,opsize,false);
                  { allocate a register for the result }
                  location.register:=cg.getintregister(exprasmlist,location.size);
                  { emit bit test operation }
                  emit_bit_test_reg_reg(exprasmlist,left.location.size,left.location.register,
                      right.location.register,location.size,location.register);
                end;
             end
            else
             {************************** NOT SMALL SET ********************}
             begin
               if right.location.loc=LOC_CONSTANT then
                begin
                  { can it actually occur currently? CEC }
                  { yes: "if bytevar in [1,3,5,7,9,11,13,15]" (JM) }

                  { note: this code assumes that left in [0..255], which is a valid }
                  { assumption (other cases will be caught by range checking) (JM)  }

                  { load left in register }
                  location_force_reg(exprasmlist,left.location,opsize,true);
                  if left.location.loc = LOC_CREGISTER then
                    hr := cg.getintregister(exprasmlist,opsize)
                  else
                    hr := left.location.register;
                  { load right in register }
                  hr2:=cg.getintregister(exprasmlist,opsize);
                  cg.a_load_const_reg(exprasmlist,opsize,right.location.value,hr2);

                  { emit bit test operation }
                  emit_bit_test_reg_reg(exprasmlist,left.location.size,left.location.register,hr2,opsize,hr2);

                  { if left > 31 then hr := 0 else hr := $ffffffff }
                  cg.a_op_const_reg_reg(exprasmlist,OP_SUB,opsize,32,left.location.register,hr);
                  cg.a_op_const_reg(exprasmlist,OP_SAR,opsize,31,hr);

                  { if left > 31, then result := 0 else result := result of bit test }
                  cg.a_op_reg_reg(exprasmlist,OP_AND,opsize,hr,hr2);
                  { allocate a register for the result }
                  location.register := cg.getintregister(exprasmlist,location.size);
                  cg.a_load_reg_reg(exprasmlist,opsize,location.size,hr2,location.register);
                end { of right.location.loc=LOC_CONSTANT }
               { do search in a normal set which could have >32 elementsm
                 but also used if the left side contains higher values > 32 }
               else if left.nodetype=ordconstn then
                begin
                  { use location.register as scratch register here }
                  if (target_info.endian = endian_little) then
                    inc(right.location.reference.offset,tordconstnode(left).value shr 3)
                  else
                    { adjust for endianess differences }
                    inc(right.location.reference.offset,(tordconstnode(left).value shr 3) xor 3);
                  { allocate a register for the result }
                  location.register := cg.getintregister(exprasmlist,location.size);
                  cg.a_load_ref_reg(exprasmlist,OS_8,location.size,right.location.reference, location.register);
                  cg.a_op_const_reg(exprasmlist,OP_SHR,location.size,tordconstnode(left).value and 7,
                    location.register);
                  cg.a_op_const_reg(exprasmlist,OP_AND,location.size,1,location.register);
                end
               else
                begin
                  location_force_reg(exprasmlist,left.location,OS_INT,true);
                  pleftreg := left.location.register;

                  location_freetemp(exprasmlist,left.location);
                  hr := cg.getaddressregister(exprasmlist);
                  cg.a_op_const_reg_reg(exprasmlist,OP_SHR,OS_INT,5,pleftreg,hr);
                  cg.a_op_const_reg(exprasmlist,OP_SHL,OS_INT,2,hr);

                  href := right.location.reference;
                  if (href.base = NR_NO) then
                    href.base := hr
                  else if (right.location.reference.index = NR_NO) then
                    href.index := hr
                  else
                    begin
                      hr2 := cg.getaddressregister(exprasmlist);
                      cg.a_loadaddr_ref_reg(exprasmlist,href, hr2);
                      reference_reset_base(href,hr2,0);
                      href.index := hr;
                    end;
                  { allocate a register for the result }
                  location.register := cg.getintregister(exprasmlist,opsize);
                  cg.a_load_ref_reg(exprasmlist,opsize,opsize,href,location.register);

                  hr := cg.getintregister(exprasmlist,opsize);
                  cg.a_op_const_reg_reg(exprasmlist,OP_AND,opsize,31,pleftreg,hr);
                  cg.a_op_reg_reg(exprasmlist,OP_SHR,opsize,hr,location.register);
                  cg.a_op_const_reg(exprasmlist,OP_AND,opsize,1,location.register);
                end;
             end;
          end;
          location_freetemp(exprasmlist,right.location);
       end;

{*****************************************************************************
                            TCGCASENODE
*****************************************************************************}

    function tcgcasenode.blocklabel(id:longint):tasmlabel;
      begin
        if not assigned(blocks[id]) then
          internalerror(200411301);
        result:=pcaseblock(blocks[id])^.blocklabel;
      end;


    procedure tcgcasenode.optimizevalues(var max_linear_list:aint;var max_dist:aword);
      begin
        { no changes by default }
      end;


    function tcgcasenode.has_jumptable : boolean;
      begin
        { No jumptable support in the default implementation }
        has_jumptable:=false;
      end;


    procedure tcgcasenode.genjumptable(hp : pcaselabel;min_,max_ : aint);
      begin
        internalerror(200209161);
      end;


    procedure tcgcasenode.genlinearlist(hp : pcaselabel);

      var
         first : boolean;
         last : TConstExprInt;
         scratch_reg: tregister;

      procedure genitem(t : pcaselabel);

          procedure gensub(value:aint);
            begin
              { here, since the sub and cmp are separate we need
                to move the result before subtract to help
                the register allocator
              }
              cg.a_load_reg_reg(exprasmlist, opsize, opsize, hregister, scratch_reg);
              cg.a_op_const_reg(exprasmlist, OP_SUB, opsize, value, hregister);
            end;

        begin
           if assigned(t^.less) then
             genitem(t^.less);
           { do we need to test the first value? }
           if first and (t^._low>get_min_value(left.resulttype.def)) then
             cg.a_cmp_const_reg_label(exprasmlist,opsize,jmp_lt,aint(t^._low),hregister,elselabel);
           if t^._low=t^._high then
             begin
                if t^._low-last=0 then
                  cg.a_cmp_const_reg_label(exprasmlist,opsize,OC_EQ,0,hregister,blocklabel(t^.blockid))
                else
                  begin
                      gensub(aint(t^._low-last));
                      cg.a_cmp_const_reg_label(exprasmlist,opsize,OC_EQ,aint(t^._low-last),scratch_reg,blocklabel(t^.blockid));
                  end;
                last:=t^._low;
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
                       gensub(aint(t^._low));
                  end
                else
                  begin
                    { if there is no unused label between the last and the }
                    { present label then the lower limit can be checked    }
                    { immediately. else check the range in between:       }
                    gensub(aint(t^._low-last));
                    cg.a_cmp_const_reg_label(exprasmlist, opsize,jmp_lt,aint(t^._low-last),scratch_reg,elselabel);
                  end;
                gensub(aint(t^._high-t^._low));
                cg.a_cmp_const_reg_label(exprasmlist,opsize,jmp_le,aint(t^._high-t^._low),scratch_reg,blocklabel(t^.blockid));
                last:=t^._high;
             end;
           first:=false;
           if assigned(t^.greater) then
             genitem(t^.greater);
        end;

      begin
         { do we need to generate cmps? }
         if (with_sign and (min_label<0)) then
           genlinearcmplist(hp)
         else
           begin
              last:=0;
              first:=true;
              scratch_reg:=cg.getintregister(exprasmlist,opsize);
              genitem(hp);
              cg.a_jmp_always(exprasmlist,elselabel);
           end;
      end;


    procedure tcgcasenode.genlinearcmplist(hp : pcaselabel);

      var
         last : TConstExprInt;
         lastwasrange: boolean;

      procedure genitem(t : pcaselabel);

{$ifndef cpu64bit}
        var
           l1 : tasmlabel;
{$endif cpu64bit}

        begin
           if assigned(t^.less) then
             genitem(t^.less);
           if t^._low=t^._high then
             begin
{$ifndef cpu64bit}
                if opsize in [OS_S64,OS_64] then
                  begin
                     objectlibrary.getlabel(l1);
                     cg.a_cmp_const_reg_label(exprasmlist, OS_32, OC_NE, aint(hi(int64(t^._low))),hregister2,l1);
                     cg.a_cmp_const_reg_label(exprasmlist, OS_32, OC_EQ, aint(lo(int64(t^._low))),hregister, blocklabel(t^.blockid));
                     cg.a_label(exprasmlist,l1);
                  end
                else
{$endif cpu64bit}
                  begin
                     cg.a_cmp_const_reg_label(exprasmlist, opsize, OC_EQ, aint(t^._low),hregister, blocklabel(t^.blockid));
                  end;
                { Reset last here, because we've only checked for one value and need to compare
                  for the next range both the lower and upper bound }
                lastwasrange := false;
             end
           else
             begin
                { it begins with the smallest label, if the value }
                { is even smaller then jump immediately to the    }
                { ELSE-label                                }
                if not lastwasrange or (t^._low-last>1) then
                  begin
{$ifndef cpu64bit}
                     if opsize in [OS_64,OS_S64] then
                       begin
                          objectlibrary.getlabel(l1);
                          cg.a_cmp_const_reg_label(exprasmlist, OS_32, jmp_lt, aint(hi(int64(t^._low))),
                               hregister2, elselabel);
                          cg.a_cmp_const_reg_label(exprasmlist, OS_32, jmp_gt, aint(hi(int64(t^._low))),
                               hregister2, l1);
                          { the comparisation of the low dword must be always unsigned! }
                          cg.a_cmp_const_reg_label(exprasmlist, OS_32, OC_B, aint(lo(int64(t^._low))), hregister, elselabel);
                          cg.a_label(exprasmlist,l1);
                       end
                     else
{$endif cpu64bit}
                       begin
                        cg.a_cmp_const_reg_label(exprasmlist, opsize, jmp_lt, aint(t^._low), hregister,
                           elselabel);
                       end;
                  end;
{$ifndef cpu64bit}
                if opsize in [OS_S64,OS_64] then
                  begin
                     objectlibrary.getlabel(l1);
                     cg.a_cmp_const_reg_label(exprasmlist, OS_32, jmp_lt, aint(hi(int64(t^._high))), hregister2,
                           blocklabel(t^.blockid));
                     cg.a_cmp_const_reg_label(exprasmlist, OS_32, jmp_gt, aint(hi(int64(t^._high))), hregister2,
                           l1);
                    cg.a_cmp_const_reg_label(exprasmlist, OS_32, OC_BE, aint(lo(int64(t^._high))), hregister, blocklabel(t^.blockid));
                    cg.a_label(exprasmlist,l1);
                  end
                else
{$endif cpu64bit}
                  begin
                     cg.a_cmp_const_reg_label(exprasmlist, opsize, jmp_le, aint(t^._high), hregister, blocklabel(t^.blockid));
                  end;

                last:=t^._high;
                lastwasrange := true;
             end;
           if assigned(t^.greater) then
             genitem(t^.greater);
        end;

      begin
         last:=0;
         lastwasrange:=false;
         genitem(hp);
         cg.a_jmp_always(exprasmlist,elselabel);
      end;


    procedure ReLabel(var p:tasmsymbol);
      begin
        if p.defbind = AB_LOCAL then
         begin
           if not assigned(p.altsymbol) then
             objectlibrary.GenerateAltSymbol(p);
           p:=p.altsymbol;
           p.increfs;
         end;
      end;


    procedure tcgcasenode.pass_2;
      var
         i : longint;
         lv,hv,
         max_label: tconstexprint;
         labelcnt : aint;
         max_linear_list : aint;
         otl, ofl: tasmlabel;
         isjump : boolean;
         max_dist,
         dist : aword;
      begin
         location_reset(location,LOC_VOID,OS_NO);

         { Allocate labels }
         objectlibrary.getlabel(endlabel);
         objectlibrary.getlabel(elselabel);
         for i:=0 to blocks.count-1 do
           objectlibrary.getlabel(pcaseblock(blocks[i])^.blocklabel);

         with_sign:=is_signed(left.resulttype.def);
         if with_sign then
           begin
              jmp_gt:=OC_GT;
              jmp_lt:=OC_LT;
              jmp_le:=OC_LTE;
           end
         else
            begin
              jmp_gt:=OC_A;
              jmp_lt:=OC_B;
              jmp_le:=OC_BE;
           end;

         { save current truelabel and falselabel }
         isjump:=false;
         if left.location.loc=LOC_JUMP then
          begin
            otl:=truelabel;
            objectlibrary.getlabel(truelabel);
            ofl:=falselabel;
            objectlibrary.getlabel(falselabel);
            isjump:=true;
          end;
         secondpass(left);
         { determines the size of the operand }
         opsize:=def_cgsize(left.resulttype.def);
         { copy the case expression to a register }
         location_force_reg(exprasmlist,left.location,opsize,false);
{$ifndef cpu64bit}
         if opsize in [OS_S64,OS_64] then
           begin
             hregister:=left.location.register64.reglo;
             hregister2:=left.location.register64.reghi;
           end
         else
{$endif cpu64bit}
           hregister:=left.location.register;
         if isjump then
          begin
            truelabel:=otl;
            falselabel:=ofl;
          end;

         { we need the min_label always to choose between }
         { cmps and subs/decs                             }
         min_label:=case_get_min(labels);

         { Generate the jumps }
{$ifdef OLDREGVARS}
         load_all_regvars(exprasmlist);
{$endif OLDREGVARS}
{$ifndef cpu64bit}
         if opsize in [OS_64,OS_S64] then
           genlinearcmplist(labels)
         else
{$endif cpu64bit}
           begin
              if cs_optimize in aktglobalswitches then
                begin
                   { procedures are empirically passed on }
                   { consumption can also be calculated   }
                   { but does it pay on the different     }
                   { processors?                       }
                   { moreover can the size only be appro- }
                   { ximated as it is not known if rel8,  }
                   { rel16 or rel32 jumps are used   }
                   max_label:=case_get_max(labels);
                   labelcnt:=case_count_labels(labels);
                   { can we omit the range check of the jump table ? }
                   getrange(left.resulttype.def,lv,hv);
                   jumptable_no_range:=(lv=min_label) and (hv=max_label);
                   { hack a little bit, because the range can be greater }
                   { than the positive range of a aint            }

                   if (min_label<0) and (max_label>0) then
                     begin
                        if min_label=TConstExprInt(low(aint)) then
                          dist:=aword(max_label)+aword(low(aint))
                        else
                          dist:=aword(max_label)+aword(-min_label)
                     end
                   else
                     dist:=max_label-min_label;

                   { optimize for size ? }
                   if cs_littlesize in aktglobalswitches  then
                     begin
                       if has_jumptable and
                          not((labelcnt<=2) or
                              ((max_label-min_label)<0) or
                              ((max_label-min_label)>3*labelcnt)) then
                         begin
                           { if the labels less or more a continuum then }
                           genjumptable(labels,min_label,max_label);
                         end
                       else
                         begin
                           { a linear list is always smaller than a jump tree }
                           genlinearlist(labels);
                         end;
                     end
                   else
                     begin
                        max_dist:=4*labelcnt;
                        if jumptable_no_range then
                          max_linear_list:=4
                        else
                          max_linear_list:=2;

                        { allow processor specific values }
                        optimizevalues(max_linear_list,max_dist);

                        if (labelcnt<=max_linear_list) then
                          genlinearlist(labels)
                        else
                          begin
                            if (has_jumptable) and
                               (dist<max_dist) and
                               (min_label>=low(aint)) and
                               (max_label<=high(aint)) then
                              genjumptable(labels,min_label,max_label)
                            else
                              genlinearlist(labels);
                          end;
                     end;
                end
              else
                { it's always not bad }
                genlinearlist(labels);
           end;

         { generate the instruction blocks }
         for i:=0 to blocks.count-1 do
           begin
              cg.a_label(exprasmlist,pcaseblock(blocks[i])^.blocklabel);
              secondpass(pcaseblock(blocks[i])^.statement);
              { don't come back to case line }
              aktfilepos:=exprasmList.getlasttaifilepos^;
{$ifdef OLDREGVARS}
              load_all_regvars(exprasmlist);
{$endif OLDREGVARS}
              cg.a_jmp_always(exprasmlist,endlabel);
           end;
         { ...and the else block }
         cg.a_label(exprasmlist,elselabel);
         if assigned(elseblock) then
           begin
              secondpass(elseblock);
{$ifdef OLDREGVARS}
              load_all_regvars(exprasmlist);
{$endif OLDREGVARS}
           end;
         cg.a_label(exprasmlist,endlabel);

         { Reset labels }
         for i:=0 to blocks.count-1 do
           pcaseblock(blocks[i])^.blocklabel:=nil;
      end;


begin
   csetelementnode:=tcgsetelementnode;
   cinnode:=tcginnode;
   ccasenode:=tcgcasenode;
end.
{
  $Log: ncgset.pas,v $
  Revision 1.75  2005/02/14 17:13:06  peter
    * truncate log

  Revision 1.74  2005/01/04 20:14:40  florian
    * better commenting

}
