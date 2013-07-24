{
    Copyright (c) 1998-2002 by Florian Klaempfl

    Generate code for i8086 assembler for type converting nodes

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
unit n8086cnv;

{$i fpcdefs.inc}

interface

    uses
      node,ncgcnv,nx86cnv,defutil,defcmp;

    type
       t8086typeconvnode = class(tx86typeconvnode)
       protected
         procedure second_proc_to_procvar;override;
         procedure second_nil_to_methodprocvar;override;
       end;


implementation

   uses
      verbose,systems,globals,globtype,
      aasmbase,aasmtai,aasmdata,aasmcpu,
      symconst,symdef,
      cgbase,cga,procinfo,pass_1,pass_2,
      ncon,ncal,ncnv,
      cpubase,cpuinfo,
      cgutils,cgobj,hlcgobj,cgx86,ncgutil,
      tgobj;


    procedure t8086typeconvnode.second_proc_to_procvar;
      var
        tmpreg: tregister;
        tmpref: treference;
      begin
        if not (po_far in tabstractprocdef(resultdef).procoptions) then
          begin
            inherited;
            exit;
          end;

        if tabstractprocdef(resultdef).is_addressonly then
          begin
            location_reset(location,LOC_REGISTER,OS_32);
            { only a code pointer? (when taking the address of classtype.method
              we also only get a code pointer even though the resultdef is a
              procedure of object, and hence is_addressonly would return false)
             }
  	    if left.location.size = OS_32 then
              begin
                case left.location.loc of
                  LOC_REFERENCE,LOC_CREFERENCE:
                    begin
                      { the procedure symbol is encoded in reference.symbol -> take address }
                      location.register:=cg.getintregister(current_asmdata.CurrAsmList,OS_32);
                      cg.a_loadaddr_ref_reg(current_asmdata.CurrAsmList,left.location.reference,location.register);
                      tmpref:=left.location.reference;
                      tmpref.refaddr:=addr_seg;
                      cg.a_load_ref_reg(current_asmdata.CurrAsmList,OS_16,OS_16,tmpref,GetNextReg(location.register));
                    end;
                  else
                    internalerror(2013031501)
                end;
              end
            else
              begin
                { conversion from a procedure of object/nested procvar to plain procvar }
                case left.location.loc of
                  LOC_REFERENCE,LOC_CREFERENCE:
                    begin
                      location.register:=cg.getintregister(current_asmdata.CurrAsmList,OS_32);
                      { code field is the first one }
                      cg.a_load_ref_reg(current_asmdata.CurrAsmList,OS_32,OS_32,left.location.reference,location.register);
                    end;
                  LOC_REGISTER,LOC_CREGISTER:
                    begin
                      if target_info.endian=endian_little then
                        location.register:=left.location.register
                      else
                        location.register:=left.location.registerhi;
                    end;
                  else
                    internalerror(2013031502)
                end;
              end;
          end
        else
          begin
            { TODO: update for far procs }
            if not tabstractprocdef(left.resultdef).is_addressonly then
              location_copy(location,left.location)
            else
              begin
                { assigning a global function to a nested procvar -> create
                  tmethodpointer record and set the "frame pointer" to nil }
                if not(left.location.loc in [LOC_REFERENCE,LOC_CREFERENCE]) then
                  internalerror(2013031503);
                location_reset_ref(location,LOC_REFERENCE,int_cgsize(sizeof(pint)*2),sizeof(pint));
                tg.gethltemp(current_asmdata.CurrAsmList,resultdef,resultdef.size,tt_normal,location.reference);
                tmpreg:=cg.getaddressregister(current_asmdata.CurrAsmList);
                cg.a_loadaddr_ref_reg(current_asmdata.CurrAsmList,left.location.reference,tmpreg);
                cg.a_load_reg_ref(current_asmdata.CurrAsmList,OS_ADDR,OS_ADDR,tmpreg,location.reference);
                { setting the frame pointer to nil is not strictly necessary
                  since the global procedure won't use it, but it can help with
                  debugging }
                inc(location.reference.offset,sizeof(pint));
                cg.a_load_const_ref(current_asmdata.CurrAsmList,OS_ADDR,0,location.reference);
                dec(location.reference.offset,sizeof(pint));
              end;
          end;
      end;


    procedure t8086typeconvnode.second_nil_to_methodprocvar;
      begin
        location_reset(location,LOC_REGISTER,def_cgsize(resultdef));
        if current_settings.x86memorymodel in x86_far_data_models then
          begin
            location.registerhi:=cg.getintregister(current_asmdata.currasmlist,OS_32);
            cg.a_load_const_reg(current_asmdata.currasmlist,OS_32,0,location.registerhi);
          end
        else
          begin
            location.registerhi:=cg.getaddressregister(current_asmdata.currasmlist);
            cg.a_load_const_reg(current_asmdata.currasmlist,OS_ADDR,0,location.registerhi);
          end;
        if (resultdef.typ=procvardef) and (po_far in tprocvardef(resultdef).procoptions) then
          begin
            location.register:=cg.getintregister(current_asmdata.currasmlist,OS_32);
            cg.a_load_const_reg(current_asmdata.currasmlist,OS_32,0,location.register);
          end
        else
          begin
            location.register:=cg.getaddressregister(current_asmdata.currasmlist);
            cg.a_load_const_reg(current_asmdata.currasmlist,OS_ADDR,0,location.register);
          end;
      end;


begin
  ctypeconvnode:=t8086typeconvnode
end.
