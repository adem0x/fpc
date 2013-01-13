{
    Copyright (c) 2002 by Florian Klaempfl

    Implements the avr32 specific part of call nodes

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
unit navr32cal;

{$i fpcdefs.inc}

interface

    uses
      symdef,ncal,ncgcal;

    type
       tavr32callnode = class(tcgcallnode)
         procedure set_result_location(realresdef: tstoreddef);override;
       end;

implementation

  uses
    verbose,globtype,globals,aasmdata,
    symconst,
    cgbase,cpuinfo,
    ncgutil,
    paramgr;

  procedure tavr32callnode.set_result_location(realresdef: tstoreddef);
    begin
      if (realresdef.typ=floatdef){ and
         ((cs_fp_emulation in current_settings.moduleswitches) or
          (current_settings.fputype in [fpu_avr32]))} then
        begin
          { keep the fpu values in integer registers for now, the code
            generator will move them to memory or an mmregister when necessary
            (avoids double moves in case a function result is assigned to
             another function result, or passed as a parameter) }
          case retloc.size of
            OS_32,
            OS_F32:
              location_allocate_register(current_asmdata.CurrAsmList,location,s32inttype,false);
            OS_64,
            OS_F64:
              location_allocate_register(current_asmdata.CurrAsmList,location,s64inttype,false);
            else
              internalerror(2010053008);
          end
        end
      else
        inherited;
    end;


begin
   ccallnode:=tavr32callnode;
end.
