{
    Copyright (c) 2002 by Florian Klaempfl

    Implements the PowerPC specific part of call nodes

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published bymethodpointer
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
unit nppccal;

{$i fpcdefs.inc}

interface

    uses
      symdef,node,ncal,ncgcal;

    type
       tppccallnode = class(tcgcallnode)
         procedure extra_call_code;override;
         procedure do_syscall;override;
       end;


implementation

    uses
      globtype,systems,
      cutils,verbose,globals,
      symconst,symbase,symsym,symtable,defutil,paramgr,parabase,
      cgbase,pass_2,
      cpuinfo,cpubase,aasmbase,aasmtai,aasmcpu,
      nmem,nld,ncnv,
      ncgutil,cgutils,cgobj,tgobj,regvars,rgobj,rgcpu,
      cg64f32,cgcpu,cpupi,procinfo;


    procedure tppccallnode.extra_call_code;
      begin
        if assigned(varargsparas) then
          begin
            if (target_info.abi = abi_powerpc_sysv) then
              begin
                if va_uses_float_reg in varargsparas.varargsinfo then
                  exprasmlist.concat(taicpu.op_const_const_const(A_CREQV,6,6,6))
                else
                  exprasmlist.concat(taicpu.op_const_const_const(A_CRXOR,6,6,6));
              end;
          end;
      end;


    procedure tppccallnode.do_syscall;
      var
        tmpref: treference;
      begin
        case target_info.system of
          system_powerpc_morphos:
            begin
              if (po_syscall_sysv in tprocdef(procdefinition).procoptions) or
                (po_syscall_sysvbase in tprocdef(procdefinition).procoptions) then
                begin
                  cg.getcpuregister(exprasmlist,NR_R0);
                  cg.getcpuregister(exprasmlist,NR_R31);

                  reference_reset(tmpref);
                  tmpref.symbol:=objectlibrary.newasmsymbol(tglobalvarsym(tprocdef(procdefinition).libsym).mangledname,AB_EXTERNAL,AT_DATA);
                  tmpref.refaddr:=addr_hi;
                  exprasmlist.concat(taicpu.op_reg_ref(A_LIS,NR_R31,tmpref));
                  tmpref.base:=NR_R31;
                  tmpref.refaddr:=addr_lo;
                  exprasmlist.concat(taicpu.op_reg_ref(A_LWZ,NR_R31,tmpref));

                  exprasmlist.concat(taicpu.op_reg_reg_const(A_ADDI,NR_R31,NR_R31,-tprocdef(procdefinition).extnumber));
                  reference_reset_base(tmpref,NR_R31,0);
                  exprasmlist.concat(taicpu.op_reg_ref(A_LWZ,NR_R0,tmpref));
                  exprasmlist.concat(taicpu.op_reg(A_MTCTR,NR_R0));
                  exprasmlist.concat(taicpu.op_none(A_BCTRL));

                  cg.ungetcpuregister(exprasmlist,NR_R31);
                  cg.ungetcpuregister(exprasmlist,NR_R0);
                end
              else if (po_syscall_basesysv in tprocdef(procdefinition).procoptions) or
                (po_syscall_r12base in tprocdef(procdefinition).procoptions) then
                begin
                  cg.getcpuregister(exprasmlist,NR_R0);
                  cg.getcpuregister(exprasmlist,NR_R31);

                  if (po_syscall_basesysv in tprocdef(procdefinition).procoptions) then
                    exprasmlist.concat(taicpu.op_reg_reg_const(A_ADDI,NR_R31,NR_R3,-tprocdef(procdefinition).extnumber))
                  else
                    exprasmlist.concat(taicpu.op_reg_reg_const(A_ADDI,NR_R31,NR_R12,-tprocdef(procdefinition).extnumber));
                  reference_reset_base(tmpref,NR_R31,0);
                  exprasmlist.concat(taicpu.op_reg_ref(A_LWZ,NR_R0,tmpref));
                  exprasmlist.concat(taicpu.op_reg(A_MTCTR,NR_R0));
                  exprasmlist.concat(taicpu.op_none(A_BCTRL));

                  cg.ungetcpuregister(exprasmlist,NR_R31);
                  cg.ungetcpuregister(exprasmlist,NR_R0);
                end
              else if po_syscall_legacy in tprocdef(procdefinition).procoptions then
                begin
                  cg.getcpuregister(exprasmlist,NR_R0);
                  cg.getcpuregister(exprasmlist,NR_R3);

                  { store call offset into R3 }
                  exprasmlist.concat(taicpu.op_reg_const(A_LI,NR_R3,-tprocdef(procdefinition).extnumber));

                  { prepare LR, and call function }
                  reference_reset_base(tmpref,NR_R2,100); { 100 ($64) is EmulDirectCallOS offset }
                  exprasmlist.concat(taicpu.op_reg_ref(A_LWZ,NR_R0,tmpref));
                  exprasmlist.concat(taicpu.op_reg(A_MTLR,NR_R0));
                  exprasmlist.concat(taicpu.op_none(A_BLRL));

                  cg.ungetcpuregister(exprasmlist,NR_R0);
                  cg.ungetcpuregister(exprasmlist,NR_R3);
                end
              else
                internalerror(2005010403);
            end;
          else
            internalerror(2004042901);
        end;
      end;


begin
   ccallnode:=tppccallnode;
end.
