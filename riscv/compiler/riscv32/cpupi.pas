{
    Copyright (c) 2002 by Florian Klaempfl

    This unit contains the CPU specific part of tprocinfo

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

{ This unit contains the CPU specific part of tprocinfo. }
unit cpupi;

{$i fpcdefs.inc}

  interface

    uses
       globtype,cutils,
       procinfo,cpuinfo,psub,cgbase,
       aasmdata;

    type
       triscvprocinfo = class(tcgprocinfo)
          stackframesize,
          floatregstart : aint;
          stackpaddingreg: TSuperRegister;
          // procedure handle_body_start;override;
          // procedure after_pass1;override;
          procedure set_first_temp_offset;override;
          function calc_stackframe_size:longint;override;
          procedure generate_parameter_info;override;
          procedure allocate_got_register(list : TAsmList);override;
          procedure postprocess_code;override;
       end;


  implementation

    uses
       globals,systems,
       cpubase,
       tgobj,
       symconst,symtype,symsym,symcpu,paramgr,
       cgutils,
       cgobj,
       defutil,
       aasmcpu;

    procedure triscvprocinfo.set_first_temp_offset;
      var
        localsize : aint;
        i : longint;
      begin
        { We allocate enough space to save all registers because we can't determine
          the necessary space because the used registers aren't known before
          secondpass is run. Even worse, patching
          the local offsets after generating the code could cause trouble because
          "shifter" constants could change to non-"shifter" constants. This
          is especially a problem when taking the address of a local. For now,
          this extra memory should hurt less than generating all local contants with offsets
          >256 as non shifter constants }
        if (po_nostackframe in procdef.procoptions) then
          begin
             { maxpushedparasize sghould be zero,
               if not we will get an error later. }
             tg.setfirsttemp(maxpushedparasize);
             exit;
          end;
        if tg.direction = -1 then
          tg.setfirsttemp(-28-16)
        else
          tg.setfirsttemp(maxpushedparasize);

        { estimate stack frame size }
        if (pi_estimatestacksize in flags) then
          begin
            stackframesize:=maxpushedparasize+32;
            localsize:=0;
            for i:=0 to procdef.localst.SymList.Count-1 do
              if tsym(procdef.localst.SymList[i]).typ=localvarsym then
                inc(localsize,tabstractnormalvarsym(procdef.localst.SymList[i]).getsize);
            inc(stackframesize,localsize);

            localsize:=0;
            for i:=0 to procdef.parast.SymList.Count-1 do
              if tsym(procdef.parast.SymList[i]).typ=paravarsym then
                begin
                  if tabstractnormalvarsym(procdef.parast.SymList[i]).varspez in [vs_var,vs_out,vs_constref] then
                    inc(localsize,4)
                  else if is_open_string(tabstractnormalvarsym(procdef.parast.SymList[i]).vardef) then
                    inc(localsize,256)
                  else
                    inc(localsize,tabstractnormalvarsym(procdef.parast.SymList[i]).getsize);
                end;

            inc(stackframesize,localsize);

            if pi_needs_implicit_finally in flags then
              inc(stackframesize,40);

            if pi_uses_exceptions in flags then
              inc(stackframesize,40);

            if procdef.proctypeoption in [potype_constructor] then
              inc(stackframesize,40*2);

            inc(stackframesize,estimatedtempsize);

            stackframesize:=Align(stackframesize,8);
          end;
      end;


    function triscvprocinfo.calc_stackframe_size:longint;
      var
         firstfloatreg,lastfloatreg,
         r : byte;
         floatsavesize : aword;
         regs: tcpuregisterset;
      begin
        if (pi_estimatestacksize in flags) then
          result:=stackframesize
        else
          begin
            maxpushedparasize:=align(maxpushedparasize,max(current_settings.alignment.localalignmin,4));
            floatsavesize:=0;
            case current_settings.fputype of
              fpu_r32fd:
                begin
                  floatsavesize:=0;
                  regs:=cg.rg[R_MMREGISTER].used_in_proc-paramanager.get_volatile_registers_fpu(pocall_stdcall);
                  for r:=RS_F0 to RS_F31 do
                    if r in regs then
                      inc(floatsavesize,8);
                end;
            end;
            floatsavesize:=align(floatsavesize,max(current_settings.alignment.localalignmin,4));
            result:=Align(tg.direction*tg.lasttemp,max(current_settings.alignment.localalignmin,4))+maxpushedparasize+aint(floatsavesize);
            { Note: in cgcpu "-floatregstart" is subtracted -> reason based on
                "adding floatregstart" to avoid double negation

              tg.direction=1 -> no framepointer ->
                1) save used int registers
                2) allocate stacksize (= subtracting result, which is positive,
                   from the stackpointer)
                3) add floatregstart to the stackpointer to get the offset where
                   to store the floating point registers (-> floatregstart
                   should be positive)
                4) store the floating point registers from this offset with IA
                   (i.e., this offset and higher addresses -> offset should
                    point to lower end of area)
               -> newsp+(result) points to lower end of saved int registers area
               -> newsp+(result-floatsavesize) points to lower end of float reg
                  saving area

              tg.direction=-1 -> with framepointer ->
                1) save stack pointer in framepointer
                2) save used int registers using stackpointer
                3) allocate stacksize (= subtracting result, which is positive,
                   from the stack pointer)
                4) add floatregstart" to the framepointer to get the offset
                   where to store the floating point registers (-> floatregstart
                   should be negative)
                5) store the floating point registers from this offset with IA
                   (i.e., this offset and higher addresses -> offset should
                    point to lower end of area)
                o in this case, firsttemp starts right after the saved int
                  registers area (or a bit further, because it's calculated for
                  the worst-case scenario, when all non-volative integer
                  registers have to be saved) -> we store the floating point
                  registers between the last temp and the parameter pushing area
               -> fp+(-result) points to the top of the stack (= end of
                  parameter pushing area)
               -> fp+(-result+maxpushedparasize) points to the start of the
                  parameter pushing area = lower end of float reg saving area
            }
            if tg.direction=1 then
              floatregstart:=result-aint(floatsavesize)
            else
              floatregstart:=-result+maxpushedparasize;
          end;
      end;


    procedure triscvprocinfo.generate_parameter_info;
      begin
       tcpuprocdef(procdef).total_stackframe_size:=stackframesize;
       inherited generate_parameter_info;
      end;


    procedure triscvprocinfo.allocate_got_register(list: TAsmList);
      begin
        { darwin doesn't use a got }
        if tf_pic_uses_got in target_info.flags then
          got := cg.getaddressregister(list);
      end;


    procedure triscvprocinfo.postprocess_code;
      begin
      end;

begin
   cprocinfo:=triscvprocinfo;
end.

