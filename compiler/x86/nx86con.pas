{
    Copyright (c) 1998-2002 by Florian Klaempfl

    Generate i386 assembler for constants

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
unit nx86con;

{$i fpcdefs.inc}

interface

    uses
       node,ncon,ncgcon;

    type
       tx86realconstnode = class(tcgrealconstnode)
          function pass_1 : tnode;override;
          procedure pass_2;override;
       end;

implementation

    uses
      systems,globals,
      symdef,
      defutil,
      cpubase,
      cga,cgx86,cgobj,cgbase,cgutils;

{*****************************************************************************
                           TI386REALCONSTNODE
*****************************************************************************}

    function tx86realconstnode.pass_1 : tnode;
      begin
         result:=nil;
         if is_number_float(value_real) and not(use_sse(resulttype.def)) and (value_real=1.0) or (value_real=0.0) then
           begin
              expectloc:=LOC_FPUREGISTER;
              registersfpu:=1;
           end
         else
           expectloc:=LOC_CREFERENCE;
      end;

    procedure tx86realconstnode.pass_2;

      begin
         if is_number_float(value_real) then
           begin
             if (value_real=1.0) and not(use_sse(resulttype.def)) then
               begin
                  emit_none(A_FLD1,S_NO);
                  location_reset(location,LOC_FPUREGISTER,def_cgsize(resulttype.def));
                  location.register:=NR_ST;
                  tcgx86(cg).inc_fpu_stack;
               end
             else if (value_real=0.0) and not(use_sse(resulttype.def)) then
               begin
                  emit_none(A_FLDZ,S_NO);
                  location_reset(location,LOC_FPUREGISTER,def_cgsize(resulttype.def));
                  location.register:=NR_ST;
                  tcgx86(cg).inc_fpu_stack;
               end
            else
              inherited pass_2;
           end
         else
           inherited pass_2;
      end;


begin
   crealconstnode:=tx86realconstnode;
end.
