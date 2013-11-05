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
       psub,procinfo,aasmdata;

    type
       ti8086procinfo = class(tcgprocinfo)
         constructor create(aparent:tprocinfo);override;
         procedure set_first_temp_offset;override;
         function calc_stackframe_size:longint;override;
         procedure generate_parameter_info;override;
       end;


  implementation

    uses
      cutils,
      systems,globals,globtype,
      cgobj,tgobj,paramgr,
      cpubase,
      cgutils,
      symconst;

    constructor ti8086procinfo.create(aparent:tprocinfo);
      begin
        inherited create(aparent);
        got:=NR_EBX;
      end;


    procedure ti8086procinfo.set_first_temp_offset;
      begin
        if paramanager.use_fixed_stack then
          begin
            if not(po_assembler in procdef.procoptions) and
               (tg.direction > 0) then
              tg.setfirsttemp(tg.direction*maxpushedparasize);
            if (tg.direction < 0) and
               not(po_nostackframe in procdef.procoptions) then
              { compensate for the return address and the "pushl %ebp" }
              tg.setalignmentmismatch(sizeof(pint)*2);
          end;
      end;


    function ti8086procinfo.calc_stackframe_size:longint;
      begin
        { ???:
          align to 4 bytes at least
          otherwise all those subl $2,%esp are meaningless PM }
        if target_info.stackalign<=2 then
          result:=Align(tg.direction*tg.lasttemp,min(current_settings.alignment.localalignmax,2))
        else
          { aligned during stack frame allocation, because also depends number
            of saved registers }
          result:=tg.direction*tg.lasttemp+maxpushedparasize;
      end;


    procedure ti8086procinfo.generate_parameter_info;
      begin
        inherited generate_parameter_info;
        { Para_stack_size is only used to determine how many bytes to remove }
        { from the stack at the end of the procedure (in the "ret $xx").     }
        { If the stack is fixed, nothing has to be removed by the callee     }
        if paramanager.use_fixed_stack then
          para_stack_size := 0;
      end;

begin
   cprocinfo:=ti8086procinfo;
end.
