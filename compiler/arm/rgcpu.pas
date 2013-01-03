{
    Copyright (c) 1998-2003 by Florian Klaempfl

    This unit implements the arm specific class for the register
    allocator

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

unit rgcpu;

{$i fpcdefs.inc}

  interface

     uses
       aasmbase,aasmtai,aasmdata,aasmcpu,
       cgbase,cgutils,
       cpubase,
       rgobj;

     type
       trgcpu = class(trgobj)
       private
         procedure spilling_create_load_store(list: TAsmList; pos: tai; const spilltemp:treference;tempreg:tregister; is_store: boolean);
       public
         procedure do_spill_read(list:TAsmList;pos:tai;const spilltemp:treference;tempreg:tregister);override;
         procedure do_spill_written(list:TAsmList;pos:tai;const spilltemp:treference;tempreg:tregister);override;
         procedure add_constraints(reg:tregister);override;
         function  get_spill_subreg(r:tregister) : tsubregister;override;
       end;

       trgcputhumb2 = class(trgobj)
       private
         procedure SplitITBlock(list:TAsmList;pos:tai);
       public
         procedure do_spill_read(list:TAsmList;pos:tai;const spilltemp:treference;tempreg:tregister);override;
         procedure do_spill_written(list:TAsmList;pos:tai;const spilltemp:treference;tempreg:tregister);override;
       end;

       trgintcputhumb2 = class(trgcputhumb2)
         procedure add_cpu_interferences(p : tai);override;
       end;

       trgintcpu = class(trgcpu)
         procedure add_cpu_interferences(p : tai);override;
       end;

  implementation

    uses
      verbose,globtype,globals,cpuinfo,
      cgobj,
      procinfo;

    procedure trgintcputhumb2.add_cpu_interferences(p: tai);
      var
        r : tregister;
        hr : longint;
      begin
        if p.typ=ait_instruction then
          begin
            case taicpu(p).opcode of
              A_CBNZ,
              A_CBZ:
                begin
                  for hr := RS_R8 to RS_R15 do
                    add_edge(getsupreg(taicpu(p).oper[0]^.reg), hr);
                end;
              A_ADD:
                begin
                  if taicpu(p).ops = 3 then
                    begin
                      if (taicpu(p).oper[0]^.typ = top_reg) and
                         (taicpu(p).oper[1]^.typ = top_reg) and
                         (taicpu(p).oper[2]^.typ in [top_reg, top_shifterop]) then
                        begin
                          { if d == 13 || (d == 15 && S == ‚Äò0‚Äô) || n == 15 || m IN [13,15] then UNPREDICTABLE; }
                          add_edge(getsupreg(taicpu(p).oper[0]^.reg), RS_R13);
                          if taicpu(p).oppostfix <> PF_S then
                            add_edge(getsupreg(taicpu(p).oper[0]^.reg), RS_R15);

                          add_edge(getsupreg(taicpu(p).oper[1]^.reg), RS_R15);

                          if (taicpu(p).oper[2]^.typ = top_shifterop) and
                             (taicpu(p).oper[2]^.shifterop^.rs <> NR_NO) then
                            begin
                              add_edge(getsupreg(taicpu(p).oper[2]^.shifterop^.rs), RS_R13);
                              add_edge(getsupreg(taicpu(p).oper[2]^.shifterop^.rs), RS_R15);
                            end
                          else if (taicpu(p).oper[2]^.typ = top_reg) then
                            begin
                              add_edge(getsupreg(taicpu(p).oper[2]^.reg), RS_R13);
                              add_edge(getsupreg(taicpu(p).oper[2]^.reg), RS_R15);
                            end;
                        end;
                    end;
                end;
              A_LDRB,
              A_STRB,
              A_STR,
              A_LDR,
              A_LDRH,
              A_STRH,
              A_LDRSB,
              A_LDRSH,
              A_LDRD,
              A_STRD:
                { don't mix up the framepointer and stackpointer with pre/post indexed operations }
                if (taicpu(p).oper[1]^.typ=top_ref) and
                  (taicpu(p).oper[1]^.ref^.addressmode in [AM_PREINDEXED,AM_POSTINDEXED]) then
                  begin
                    add_edge(getsupreg(taicpu(p).oper[1]^.ref^.base),getsupreg(current_procinfo.framepointer));
                    { FIXME: temp variable r is needed here to avoid Internal error 20060521 }
                    {        while compiling the compiler. }
                    r:=NR_STACK_POINTER_REG;
                    if current_procinfo.framepointer<>r then
                      add_edge(getsupreg(taicpu(p).oper[1]^.ref^.base),getsupreg(r));
                  end;
            end;
          end;
      end;

    procedure trgcpu.spilling_create_load_store(list: TAsmList; pos: tai; const spilltemp:treference;tempreg:tregister; is_store: boolean);
      var
        tmpref : treference;
        helplist : TAsmList;
        l : tasmlabel;
        hreg : tregister;
        immshift: byte;
        a: aint;
    begin
      helplist:=TAsmList.create;

      { load consts entry }
      if getregtype(tempreg)=R_INTREGISTER then
        hreg:=getregisterinline(helplist,[R_SUBWHOLE])
      else
        hreg:=cg.getintregister(helplist,OS_ADDR);

      { Lets remove the bits we can fold in later and check if the result can be easily with an add or sub }
      a:=abs(spilltemp.offset);
      if is_shifter_const(a and not($FFF), immshift) then
        if spilltemp.offset > 0 then
          begin
            {$ifdef DEBUG_SPILLING}
            helplist.concat(tai_comment.create(strpnew('Spilling: Use ADD to fix spill offset')));
            {$endif}
            helplist.concat(taicpu.op_reg_reg_const(A_ADD, hreg, current_procinfo.framepointer,
                                                      a and not($FFF)));
            reference_reset_base(tmpref, hreg, a and $FFF, sizeof(aint));
          end
        else
          begin
            {$ifdef DEBUG_SPILLING}
            helplist.concat(tai_comment.create(strpnew('Spilling: Use SUB to fix spill offset')));
            {$endif}
            helplist.concat(taicpu.op_reg_reg_const(A_SUB, hreg, current_procinfo.framepointer,
                                                      a and not($FFF)));
            reference_reset_base(tmpref, hreg, -(a and $FFF), sizeof(aint));
          end
      else
        begin
          {$ifdef DEBUG_SPILLING}
          helplist.concat(tai_comment.create(strpnew('Spilling: Use a_load_const_reg to fix spill offset')));
          {$endif}
          cg.a_load_const_reg(helplist,OS_ADDR,spilltemp.offset,hreg);
          reference_reset_base(tmpref,current_procinfo.framepointer,0,sizeof(aint));
          tmpref.index:=hreg;
        end;

      if spilltemp.index<>NR_NO then
        internalerror(200401263);

      if is_store then
        helplist.concat(spilling_create_store(tempreg,tmpref))
      else
        helplist.concat(spilling_create_load(tmpref,tempreg));

      if getregtype(tempreg)=R_INTREGISTER then
        ungetregisterinline(helplist,hreg);

      list.insertlistafter(pos,helplist);
      helplist.free;
    end;

    procedure trgcpu.do_spill_read(list:TAsmList;pos:tai;const spilltemp:treference;tempreg:tregister);
      begin
        { don't load spilled register between
          mov lr,pc
          mov pc,r4
          but befure the mov lr,pc
        }
        if assigned(pos.previous) and
          (pos.typ=ait_instruction) and
          (taicpu(pos).opcode=A_MOV) and
          (taicpu(pos).oper[0]^.typ=top_reg) and
          (taicpu(pos).oper[0]^.reg=NR_R14) and
          (taicpu(pos).oper[1]^.typ=top_reg) and
          (taicpu(pos).oper[1]^.reg=NR_PC) then
          pos:=tai(pos.previous);

        if abs(spilltemp.offset)>4095 then
          spilling_create_load_store(list, pos, spilltemp, tempreg, false)
        else
          inherited do_spill_read(list,pos,spilltemp,tempreg);
      end;


    procedure trgcpu.do_spill_written(list:TAsmList;pos:tai;const spilltemp:treference;tempreg:tregister);
      begin
        if abs(spilltemp.offset)>4095 then
          spilling_create_load_store(list, pos, spilltemp, tempreg, true)
        else
          inherited do_spill_written(list,pos,spilltemp,tempreg);
      end;


    procedure trgcpu.add_constraints(reg:tregister);
      var
        supreg,i : Tsuperregister;
      begin
        case getsubreg(reg) of
          { Let 32bit floats conflict with all double precision regs > 15
            (since these don't have 32 bit equivalents) }
          R_SUBFS:
            begin
              supreg:=getsupreg(reg);
              for i:=RS_D16 to RS_D31 do
                add_edge(supreg,i);
            end;
        end;
      end;


    function  trgcpu.get_spill_subreg(r:tregister) : tsubregister;
      begin
        if (getregtype(r)<>R_MMREGISTER) then
          result:=defaultsub
        else
          result:=getsubreg(r);
      end;

    function GetITRemainderOp(originalOp:TAsmOp;remLevels:longint;var newOp: TAsmOp;var NeedsCondSwap:boolean) : TAsmOp;
      const
        remOps : array[1..3] of array[A_ITE..A_ITTTT] of TAsmOp = (
          (A_IT,A_IT,       A_IT,A_IT,A_IT,A_IT,            A_IT,A_IT,A_IT,A_IT,A_IT,A_IT,A_IT,A_IT),
          (A_NONE,A_NONE,   A_ITT,A_ITE,A_ITE,A_ITT,        A_ITT,A_ITT,A_ITE,A_ITE,A_ITE,A_ITE,A_ITT,A_ITT),
          (A_NONE,A_NONE,   A_NONE,A_NONE,A_NONE,A_NONE,    A_ITTT,A_ITEE,A_ITET,A_ITTE,A_ITTE,A_ITET,A_ITEE,A_ITTT));
        newOps : array[1..3] of array[A_ITE..A_ITTTT] of TAsmOp = (
          (A_IT,A_IT,       A_ITE,A_ITT,A_ITE,A_ITT,        A_ITEE,A_ITTE,A_ITET,A_ITTT,A_ITEE,A_ITTE,A_ITET,A_ITTT),
          (A_NONE,A_NONE,   A_IT,A_IT,A_IT,A_IT,            A_ITE,A_ITT,A_ITE,A_ITT,A_ITE,A_ITT,A_ITE,A_ITT),
          (A_NONE,A_NONE,   A_NONE,A_NONE,A_NONE,A_NONE,    A_IT,A_IT,A_IT,A_IT,A_IT,A_IT,A_IT,A_IT));
        needsSwap: array[1..3] of array[A_ITE..A_ITTTT] of Boolean = (
          (true ,false,     true ,true ,false,false,        true ,true ,true ,true ,false,false,false,false),
          (false,false,     true ,false,true ,false,        true ,true ,false,false,true ,true ,false,false),
          (false,false,     false,false,false,false,        true ,false,true ,false,true ,false,true ,false));
      begin
        result:=remOps[remLevels][originalOp];
        newOp:=newOps[remLevels][originalOp];
        NeedsCondSwap:=needsSwap[remLevels][originalOp];
      end;

    procedure trgcputhumb2.SplitITBlock(list: TAsmList; pos: tai);
      var
        hp : tai;
        level,itLevel : LongInt;
        remOp,newOp : TAsmOp;
        needsSwap : boolean;
      begin
        hp:=pos;
        level := 0;
        while assigned(hp) do
          begin
            if IsIT(taicpu(hp).opcode) then
              break
            else if hp.typ=ait_instruction then
              inc(level);

            hp:=tai(hp.Previous);
          end;

        if not assigned(hp) then
          internalerror(2012100801); // We are supposed to have found the ITxxx instruction here

        if (hp.typ<>ait_instruction) or
          (not IsIT(taicpu(hp).opcode)) then
          internalerror(2012100802); // Sanity check

        itLevel := GetITLevels(taicpu(hp).opcode);
        if level=itLevel then
          exit; // pos was the last instruction in the IT block anyway

        remOp:=GetITRemainderOp(taicpu(hp).opcode,itLevel-level,newOp,needsSwap);

        if (remOp=A_NONE) or
          (newOp=A_NONE) then
          Internalerror(2012100803);

        taicpu(hp).opcode:=newOp;

        if needsSwap then
          list.InsertAfter(taicpu.op_cond(remOp,inverse_cond(taicpu(hp).oper[0]^.cc)), pos)
        else
          list.InsertAfter(taicpu.op_cond(remOp,taicpu(hp).oper[0]^.cc), pos);
      end;

    procedure trgcputhumb2.do_spill_read(list:TAsmList;pos:tai;const spilltemp:treference;tempreg:tregister);
      var
        tmpref : treference;
        helplist : TAsmList;
        l : tasmlabel;
        hreg : tregister;
      begin
        { don't load spilled register between
          mov lr,pc
          mov pc,r4
          but befure the mov lr,pc
        }
        if assigned(pos.previous) and
          (pos.typ=ait_instruction) and
          (taicpu(pos).opcode=A_MOV) and
          (taicpu(pos).oper[0]^.typ=top_reg) and
          (taicpu(pos).oper[0]^.reg=NR_R14) and
          (taicpu(pos).oper[1]^.typ=top_reg) and
          (taicpu(pos).oper[1]^.reg=NR_PC) then
          pos:=tai(pos.previous);

        if (pos.typ=ait_instruction) and
          (taicpu(pos).condition<>C_None) and
          (taicpu(pos).opcode<>A_B) then
          SplitITBlock(list, pos)
        else if (pos.typ=ait_instruction) and
          IsIT(taicpu(pos).opcode) then
          begin
            if not assigned(pos.Previous) then
              list.InsertBefore(tai_comment.Create('Dummy'), pos);
            pos:=tai(pos.Previous);
          end;

        if (spilltemp.offset>4095) or (spilltemp.offset<-255) then
          begin
            helplist:=TAsmList.create;
            reference_reset(tmpref,sizeof(aint));
            { create consts entry }
            current_asmdata.getjumplabel(l);
            cg.a_label(current_procinfo.aktlocaldata,l);
            tmpref.symboldata:=current_procinfo.aktlocaldata.last;

            current_procinfo.aktlocaldata.concat(tai_const.Create_32bit(spilltemp.offset));

            { load consts entry }
            if getregtype(tempreg)=R_INTREGISTER then
              hreg:=getregisterinline(helplist,[R_SUBWHOLE])
            else
              hreg:=cg.getintregister(helplist,OS_ADDR);

            tmpref.symbol:=l;
            tmpref.base:=NR_R15;
            helplist.concat(taicpu.op_reg_ref(A_LDR,hreg,tmpref));

            reference_reset_base(tmpref,current_procinfo.framepointer,0,sizeof(aint));
            tmpref.index:=hreg;

            if spilltemp.index<>NR_NO then
              internalerror(200401263);

            helplist.concat(spilling_create_load(tmpref,tempreg));
            if getregtype(tempreg)=R_INTREGISTER then
              ungetregisterinline(helplist,hreg);

            list.insertlistafter(pos,helplist);
            helplist.free;
          end
        else
          inherited do_spill_read(list,pos,spilltemp,tempreg);
      end;


    procedure trgcputhumb2.do_spill_written(list:TAsmList;pos:tai;const spilltemp:treference;tempreg:tregister);
      var
        tmpref : treference;
        helplist : TAsmList;
        l : tasmlabel;
        hreg : tregister;
      begin
        if (pos.typ=ait_instruction) and
          (taicpu(pos).condition<>C_None) and
          (taicpu(pos).opcode<>A_B) then
          SplitITBlock(list, pos)
        else if (pos.typ=ait_instruction) and
          IsIT(taicpu(pos).opcode) then
          begin
            if not assigned(pos.Previous) then
              list.InsertBefore(tai_comment.Create('Dummy'), pos);
            pos:=tai(pos.Previous);
          end;

        if (spilltemp.offset>4095) or (spilltemp.offset<-255) then
          begin
            helplist:=TAsmList.create;
            reference_reset(tmpref,sizeof(aint));
            { create consts entry }
            current_asmdata.getjumplabel(l);
            cg.a_label(current_procinfo.aktlocaldata,l);
            tmpref.symboldata:=current_procinfo.aktlocaldata.last;

            current_procinfo.aktlocaldata.concat(tai_const.Create_32bit(spilltemp.offset));

            { load consts entry }
            if getregtype(tempreg)=R_INTREGISTER then
              hreg:=getregisterinline(helplist,[R_SUBWHOLE])
            else
              hreg:=cg.getintregister(helplist,OS_ADDR);
            tmpref.symbol:=l;
            tmpref.base:=NR_R15;
            helplist.concat(taicpu.op_reg_ref(A_LDR,hreg,tmpref));

            if spilltemp.index<>NR_NO then
              internalerror(200401263);

            reference_reset_base(tmpref,current_procinfo.framepointer,0,sizeof(pint));
            tmpref.index:=hreg;

            helplist.concat(spilling_create_store(tempreg,tmpref));

            if getregtype(tempreg)=R_INTREGISTER then
              ungetregisterinline(helplist,hreg);

            list.insertlistafter(pos,helplist);
            helplist.free;
          end
        else
          inherited do_spill_written(list,pos,spilltemp,tempreg);
      end;


    procedure trgintcpu.add_cpu_interferences(p : tai);
      var
        r : tregister;
      begin
        if p.typ=ait_instruction then
          begin
            case taicpu(p).opcode of
              A_MLA,
              A_MUL:
                if current_settings.cputype<cpu_armv6 then
                  add_edge(getsupreg(taicpu(p).oper[0]^.reg),getsupreg(taicpu(p).oper[1]^.reg));
              A_UMULL,
              A_UMLAL,
              A_SMULL,
              A_SMLAL:
                begin
                  add_edge(getsupreg(taicpu(p).oper[0]^.reg),getsupreg(taicpu(p).oper[1]^.reg));
                  add_edge(getsupreg(taicpu(p).oper[1]^.reg),getsupreg(taicpu(p).oper[2]^.reg));
                  add_edge(getsupreg(taicpu(p).oper[0]^.reg),getsupreg(taicpu(p).oper[2]^.reg));
                end;
              A_LDRB,
              A_STRB,
              A_STR,
              A_LDR,
              A_LDRH,
              A_STRH:
                { don't mix up the framepointer and stackpointer with pre/post indexed operations }
                if (taicpu(p).oper[1]^.typ=top_ref) and
                  (taicpu(p).oper[1]^.ref^.addressmode in [AM_PREINDEXED,AM_POSTINDEXED]) then
                  begin
                    add_edge(getsupreg(taicpu(p).oper[1]^.ref^.base),getsupreg(current_procinfo.framepointer));
                    { FIXME: temp variable r is needed here to avoid Internal error 20060521 }
                    {        while compiling the compiler. }
                    r:=NR_STACK_POINTER_REG;
                    if current_procinfo.framepointer<>r then
                      add_edge(getsupreg(taicpu(p).oper[1]^.ref^.base),getsupreg(r));
                  end;
            end;
          end;
      end;


end.
