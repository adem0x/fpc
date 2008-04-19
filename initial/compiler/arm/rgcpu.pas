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
         procedure do_spill_read(list:TAsmList;pos:tai;const spilltemp:treference;tempreg:tregister);override;
         procedure do_spill_written(list:TAsmList;pos:tai;const spilltemp:treference;tempreg:tregister);override;
       end;

       trgintcpu = class(trgcpu)
         procedure add_cpu_interferences(p : tai);override;

         procedure add_regset_edges(s : Tcpuregisterset; v:Tsuperregister); virtual;
       end;

  implementation

    uses
      verbose, cutils,
      cgobj,
      procinfo;


    procedure trgcpu.do_spill_read(list:TAsmList;pos:tai;const spilltemp:treference;tempreg:tregister);
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

        if abs(spilltemp.offset)>4095 then
          begin
            helplist:=TAsmList.create;
            reference_reset(tmpref);
            { create consts entry }
            current_asmdata.getjumplabel(l);
            cg.a_label(current_procinfo.aktlocaldata,l);
            tmpref.symboldata:=current_procinfo.aktlocaldata.last;

            current_procinfo.aktlocaldata.concat(tai_const.Create_32bit(spilltemp.offset));

            { load consts entry }
            if getregtype(tempreg)=R_INTREGISTER then
              hreg:=getregisterinline(helplist,R_SUBWHOLE)
            else
              hreg:=cg.getintregister(helplist,OS_ADDR);

            tmpref.symbol:=l;
            tmpref.base:=NR_R15;
            helplist.concat(taicpu.op_reg_ref(A_LDR,hreg,tmpref));

            reference_reset_base(tmpref,current_procinfo.framepointer,0);
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


    procedure trgcpu.do_spill_written(list:TAsmList;pos:tai;const spilltemp:treference;tempreg:tregister);
      var
        tmpref : treference;
        helplist : TAsmList;
        l : tasmlabel;
        hreg : tregister;
      begin
        if abs(spilltemp.offset)>4095 then
          begin
            helplist:=TAsmList.create;
            reference_reset(tmpref);
            { create consts entry }
            current_asmdata.getjumplabel(l);
            cg.a_label(current_procinfo.aktlocaldata,l);
            tmpref.symboldata:=current_procinfo.aktlocaldata.last;

            current_procinfo.aktlocaldata.concat(tai_const.Create_32bit(spilltemp.offset));

            { load consts entry }
            if getregtype(tempreg)=R_INTREGISTER then
              hreg:=getregisterinline(helplist,R_SUBWHOLE)
            else
              hreg:=cg.getintregister(helplist,OS_ADDR);
            tmpref.symbol:=l;
            tmpref.base:=NR_R15;
            helplist.concat(taicpu.op_reg_ref(A_LDR,hreg,tmpref));

            if spilltemp.index<>NR_NO then
              internalerror(200401263);

            reference_reset_base(tmpref,current_procinfo.framepointer,0);
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


    
    procedure trgintcpu.add_regset_edges(s : Tcpuregisterset; v:Tsuperregister);
      const num2reg : array[0..15] of Tsuperregister = (RS_R0,RS_R1,RS_R2,RS_R3,RS_R4,RS_R5,RS_R6,RS_R7,RS_R8,RS_R9,RS_R10,RS_R11,RS_R12,RS_R13,RS_R14,RS_R15);
      var i : longint; r : Tsuperregister;
    begin
      for i := 0 to 15 do begin
        r := num2reg[i];
        if (r in s) then begin
          add_edge(r,v); 
          add_edge(v,r); 
        end;
      end;
    end;



    procedure trgintcpu.add_cpu_interferences(p : tai);
      var
        r : tregister; i,j : longint;
      begin
        if p.typ=ait_instruction then
          begin
            case taicpu(p).opcode of
              A_MUL:
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
                {
                  Did this happen?
                  Where/why, and if so, why disallow? 
                  For now, I (JB) leave this here, but I think this "problem"
                  should be fixed elsewhere.
                }

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

              A_ZZZ_VIRTUALLOAD,
              A_ZZZ_VIRTUALSAVE,
              A_ZZZ_VIRTUALCOPY : 
              begin
                { if the instruction contains tempregs, make sure they're
                  all diffrent, also from the reg to load/store. regs given
                  in the ref may probably be shared, if they aren't needed
                  anymore.
                }
                for i := taicpu(p).ops-1 downto 0 do begin

                  if (taicpu(p).oper[i]^.typ in [top_reg,top_regset]) then begin

                    for j := taicpu(p).ops-1 downto 0 do begin

                      if not(i=j)  and (taicpu(p).oper[j]^.typ=top_reg) then begin
                        if (taicpu(p).oper[i]^.typ=top_reg) 
                        then add_edge( getsupreg( taicpu(p).oper[i]^.reg )  ,getsupreg(taicpu(p).oper[j]^.reg))
                        else add_regset_edges(    taicpu(p).oper[i]^.regset^,getsupreg(taicpu(p).oper[j]^.reg));
                      end;

                    end;
                  end;
                  if taicpu(p).opcode=A_ZZZ_VIRTUALCOPY then begin
                    { Maybe it's needed to add additional constraints 
                      for copying refs, here. I'm unsure what to do
                      if tempregs are equal to refregs of both refs.
                      We should probably not generate that case, or 
                      maybe concatcopy will be able to deal with this
                      situation.
                    }
                  end;
                end;
              end;
              A_ZZZ_VIRTUALSPILL,
              A_ZZZ_VIRTUALUNSPILL : ; // actually no known constraints
            end; {case instr}
          end; {if tai-instr}
      end;


end.
