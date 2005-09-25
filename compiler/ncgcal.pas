{
    Copyright (c) 1998-2002 by Florian Klaempfl

    Generate assembler for call nodes

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
unit ncgcal;

{$i fpcdefs.inc}

interface

    uses
      cpubase,
      globtype,
      parabase,cgutils,
      symdef,node,ncal;

    type
       tcgcallparanode = class(tcallparanode)
       private
          tempcgpara : tcgpara;
          procedure push_addr_para;
          procedure push_value_para;
       public
          constructor create(expr,next : tnode);override;
          destructor destroy;override;
          procedure secondcallparan;override;
       end;

       tcgcallnode = class(tcallnode)
       private
          procedure release_para_temps;
          procedure normal_pass_2;
{$ifdef PASS2INLINE}
          procedure inlined_pass_2;
{$endif PASS2INLINE}
          procedure pushparas;
          procedure freeparas;
       protected
          framepointer_paraloc : tcgpara;
          refcountedtemp : treference;
          procedure handle_return_value;
          {# This routine is used to push the current frame pointer
             on the stack. This is used in nested routines where the
             value of the frame pointer is always pushed as an extra
             parameter.

             The default handling is the standard handling used on
             most stack based machines, where the frame pointer is
             the first invisible parameter.
          }
          procedure pop_parasize(pop_size:longint);virtual;
          procedure extra_interrupt_code;virtual;
          procedure extra_call_code;virtual;
          procedure extra_post_call_code;virtual;
          procedure do_syscall;virtual;abstract;
       public
          procedure pass_2;override;
       end;


implementation

    uses
      systems,
      cutils,verbose,globals,
      symconst,symtable,defutil,paramgr,
{$ifdef GDB}
      strings,
      gdb,
{$endif GDB}
      cgbase,pass_2,
      aasmbase,aasmtai,
      nbas,nmem,nld,ncnv,nutils,
{$ifdef x86}
      cga,cgx86,
{$endif x86}
      ncgutil,
      cgobj,tgobj,
      procinfo;


{*****************************************************************************
                             TCGCALLPARANODE
*****************************************************************************}

    constructor tcgcallparanode.create(expr,next : tnode);
      begin
        inherited create(expr,next);
        tempcgpara.init;
      end;


    destructor tcgcallparanode.destroy;
      begin
        tempcgpara.done;
        inherited destroy;
      end;


    procedure tcgcallparanode.push_addr_para;
      begin
        if not(left.location.loc in [LOC_CREFERENCE,LOC_REFERENCE]) then
          internalerror(200304235);
        cg.a_paramaddr_ref(exprasmlist,left.location.reference,tempcgpara);
      end;


    procedure tcgcallparanode.push_value_para;
{$ifdef i386}
      var
        href   : treference;
        size   : longint;
{$endif i386}
      begin
        { we've nothing to push when the size of the parameter is 0 }
        if left.resulttype.def.size=0 then
          exit;

        { Move flags and jump in register to make it less complex }
        if left.location.loc in [LOC_FLAGS,LOC_JUMP] then
          location_force_reg(exprasmlist,left.location,def_cgsize(left.resulttype.def),false);

        { Handle Floating point types differently }
        if (left.resulttype.def.deftype=floatdef) and not(cs_fp_emulation in aktmoduleswitches) then
         begin
{$ifdef i386}
           if tempcgpara.location^.loc<>LOC_REFERENCE then
             internalerror(200309291);
           case left.location.loc of
             LOC_FPUREGISTER,
             LOC_CFPUREGISTER:
               begin
                 size:=align(TCGSize2Size[left.location.size],tempcgpara.alignment);
                 if tempcgpara.location^.reference.index=NR_STACK_POINTER_REG then
                   begin
                     cg.g_stackpointer_alloc(exprasmlist,size);
                     reference_reset_base(href,NR_STACK_POINTER_REG,0);
                   end
                 else
                   reference_reset_base(href,tempcgpara.location^.reference.index,tempcgpara.location^.reference.offset);
                 cg.a_loadfpu_reg_ref(exprasmlist,left.location.size,left.location.register,href);
               end;
             LOC_MMREGISTER,
             LOC_CMMREGISTER:
               begin
                 size:=align(tfloatdef(left.resulttype.def).size,tempcgpara.alignment);
                 if tempcgpara.location^.reference.index=NR_STACK_POINTER_REG then
                   begin
                     cg.g_stackpointer_alloc(exprasmlist,size);
                     reference_reset_base(href,NR_STACK_POINTER_REG,0);
                   end
                 else
                   reference_reset_base(href,tempcgpara.location^.reference.index,tempcgpara.location^.reference.offset);
                 cg.a_loadmm_reg_ref(exprasmlist,left.location.size,left.location.size,left.location.register,href,mms_movescalar);
               end;
             LOC_REFERENCE,
             LOC_CREFERENCE :
               begin
                 size:=align(left.resulttype.def.size,tempcgpara.alignment);
                 if tempcgpara.location^.reference.index=NR_STACK_POINTER_REG then
                   cg.a_param_ref(exprasmlist,left.location.size,left.location.reference,tempcgpara)
                 else
                   begin
                     reference_reset_base(href,tempcgpara.location^.reference.index,tempcgpara.location^.reference.offset);
                     cg.g_concatcopy(exprasmlist,left.location.reference,href,size);
                   end;
               end;
             else
               internalerror(2002042430);
           end;
{$else i386}
           case left.location.loc of
             LOC_MMREGISTER,
             LOC_CMMREGISTER:
               case tempcgpara.location^.loc of
                 LOC_REFERENCE,
                 LOC_CREFERENCE,
                 LOC_MMREGISTER,
                 LOC_CMMREGISTER:
                   cg.a_parammm_reg(exprasmlist,left.location.size,left.location.register,tempcgpara,mms_movescalar);
                 LOC_FPUREGISTER,
                 LOC_CFPUREGISTER:
                   begin
                     location_force_fpureg(exprasmlist,left.location,false);
                     cg.a_paramfpu_reg(exprasmlist,left.location.size,left.location.register,tempcgpara);
                   end;
                 else
                   internalerror(200204249);
               end;
             LOC_FPUREGISTER,
             LOC_CFPUREGISTER:
               case tempcgpara.location^.loc of
                 LOC_MMREGISTER,
                 LOC_CMMREGISTER:
                   begin
                     location_force_mmregscalar(exprasmlist,left.location,false);
                     cg.a_parammm_reg(exprasmlist,left.location.size,left.location.register,tempcgpara,mms_movescalar);
                   end;
{$ifdef x86_64}
                 { x86_64 pushes s64comp in normal register }
                 LOC_REGISTER,
                 LOC_CREGISTER :
                   begin
                     location_force_mem(exprasmlist,left.location);
                     { force integer size }
                     left.location.size:=int_cgsize(tcgsize2size[left.location.size]);
                     cg.a_param_ref(exprasmlist,left.location.size,left.location.reference,tempcgpara);
                   end;
{$endif x86_64}
{$if defined(sparc) or defined(arm)}
                 { sparc and arm pass floats in normal registers }
                 LOC_REGISTER,
                 LOC_CREGISTER,
{$endif sparc}
                 LOC_REFERENCE,
                 LOC_CREFERENCE,
                 LOC_FPUREGISTER,
                 LOC_CFPUREGISTER:
                   cg.a_paramfpu_reg(exprasmlist,left.location.size,left.location.register,tempcgpara);
                 else
                   internalerror(2002042433);
               end;
             LOC_REFERENCE,
             LOC_CREFERENCE:
               case tempcgpara.location^.loc of
                 LOC_MMREGISTER,
                 LOC_CMMREGISTER:
                   cg.a_parammm_ref(exprasmlist,left.location.size,left.location.reference,tempcgpara,mms_movescalar);
{$ifdef x86_64}
                 { x86_64 pushes s64comp in normal register }
                 LOC_REGISTER,
                 LOC_CREGISTER :
                   begin
                     { force integer size }
                     left.location.size:=int_cgsize(tcgsize2size[left.location.size]);
                     cg.a_param_ref(exprasmlist,left.location.size,left.location.reference,tempcgpara);
                   end;
{$endif x86_64}
{$if defined(sparc) or defined(arm) }
                 { sparc and arm pass floats in normal registers }
                 LOC_REGISTER,
                 LOC_CREGISTER,
{$endif sparc}
                 LOC_REFERENCE,
                 LOC_CREFERENCE,
                 LOC_FPUREGISTER,
                 LOC_CFPUREGISTER:
                   cg.a_paramfpu_ref(exprasmlist,left.location.size,left.location.reference,tempcgpara);
                 else
                   internalerror(2002042431);
               end;
             else
               internalerror(2002042432);
           end;
{$endif i386}
         end
        else
         begin
           case left.location.loc of
             LOC_CONSTANT,
             LOC_REGISTER,
             LOC_CREGISTER,
             LOC_REFERENCE,
             LOC_CREFERENCE :
               begin
{$ifndef cpu64bit}
                 { use cg64 only for int64, not for 8 byte records }
                 if is_64bit(left.resulttype.def) then
                   cg64.a_param64_loc(exprasmlist,left.location,tempcgpara)
                 else
{$endif cpu64bit}
                   begin
{$ifndef cpu64bit}
                     { Only a_param_ref supports multiple locations, when the
                       value is still a const or in a register then write it
                       to a reference first. This situation can be triggered
                       by typecasting an int64 constant to a record of 8 bytes }
                     if left.location.size in [OS_64,OS_S64] then
                       location_force_mem(exprasmlist,left.location);
{$endif cpu64bit}
                     cg.a_param_loc(exprasmlist,left.location,tempcgpara);
                   end;
               end;
{$ifdef SUPPORT_MMX}
             LOC_MMXREGISTER,
             LOC_CMMXREGISTER:
               cg.a_parammm_reg(exprasmlist,OS_M64,left.location.register,tempcgpara,nil);
{$endif SUPPORT_MMX}
             else
               internalerror(200204241);
           end;
         end;
      end;


    procedure tcgcallparanode.secondcallparan;
      var
         href    : treference;
         otlabel,
         oflabel : tasmlabel;
      begin
         if not(assigned(parasym)) then
           internalerror(200304242);

         { Skip nothingn nodes which are used after disabling
           a parameter }
         if (left.nodetype<>nothingn) then
           begin
             otlabel:=truelabel;
             oflabel:=falselabel;
             objectlibrary.getjumplabel(truelabel);
             objectlibrary.getjumplabel(falselabel);
             secondpass(left);

             { release memory for refcnt out parameters }
             if (parasym.varspez=vs_out) and
                (left.resulttype.def.needs_inittable) then
               begin
                 location_get_data_ref(exprasmlist,left.location,href,false);
                 cg.g_decrrefcount(exprasmlist,left.resulttype.def,href);
               end;

{$ifdef PASS2INLINE}
             if assigned(aktcallnode.inlinecode) then
               paramanager.duplicateparaloc(exprasmlist,aktcallnode.procdefinition.proccalloption,parasym,tempcgpara)
             else
{$endif PASS2INLINE}
               paramanager.createtempparaloc(exprasmlist,aktcallnode.procdefinition.proccalloption,parasym,tempcgpara);

             { handle varargs first, because parasym is not valid }
             if (cpf_varargs_para in callparaflags) then
               begin
                 if paramanager.push_addr_param(vs_value,left.resulttype.def,
                        aktcallnode.procdefinition.proccalloption) then
                   push_addr_para
                 else
                   push_value_para;
               end
             { hidden parameters }
             else if (vo_is_hidden_para in parasym.varoptions) then
               begin
                 { don't push a node that already generated a pointer type
                   by address for implicit hidden parameters }
                 if (vo_is_funcret in parasym.varoptions) or
                    (not(left.resulttype.def.deftype in [pointerdef,classrefdef]) and
                     paramanager.push_addr_param(parasym.varspez,parasym.vartype.def,
                         aktcallnode.procdefinition.proccalloption)) then
                   push_addr_para
                 else
                   push_value_para;
               end
             { formal def }
             else if (parasym.vartype.def.deftype=formaldef) then
               begin
                  { allow passing of a constant to a const formaldef }
                  if (parasym.varspez=vs_const) and
                     (left.location.loc=LOC_CONSTANT) then
                    location_force_mem(exprasmlist,left.location);
                  push_addr_para;
               end
             { Normal parameter }
             else
               begin
                 { don't push a node that already generated a pointer type
                   by address for implicit hidden parameters }
                 if (not(
                         (vo_is_hidden_para in parasym.varoptions) and
                         (left.resulttype.def.deftype in [pointerdef,classrefdef])
                        ) and
                     paramanager.push_addr_param(parasym.varspez,parasym.vartype.def,
                         aktcallnode.procdefinition.proccalloption)) and
                     { dyn. arrays passed to an array of const must be passed by value, see tests/webtbs/tw4219.pp }
                     not(
                         is_array_of_const(parasym.vartype.def) and
                         is_dynamic_array(left.resulttype.def)
                        ) then
                   begin
                      { Passing a var parameter to a var parameter, we can
                        just push the address transparently }
                      if (left.nodetype=loadn) and
                         (tloadnode(left).is_addr_param_load) then
                        begin
                          if (left.location.reference.index<>NR_NO) or
                             (left.location.reference.offset<>0) then
                            internalerror(200410107);
                          cg.a_param_reg(exprasmlist,OS_ADDR,left.location.reference.base,tempcgpara)
                        end
                      else
                        begin
                          { Check for passing a constant to var,out parameter }
                          if (parasym.varspez in [vs_var,vs_out]) and
                             (left.location.loc<>LOC_REFERENCE) then
                           begin
                             { passing self to a var parameter is allowed in
                               TP and delphi }
                             if not((left.location.loc=LOC_CREFERENCE) and
                                    is_self_node(left)) then
                              internalerror(200106041);
                           end;
                          { Force to be in memory }
                          if not(left.location.loc in [LOC_CREFERENCE,LOC_REFERENCE]) then
                            location_force_mem(exprasmlist,left.location);
                          push_addr_para;
                        end;
                   end
                 else
                   push_value_para;
               end;
             truelabel:=otlabel;
             falselabel:=oflabel;

             { update return location in callnode when this is the function
               result }
             if assigned(parasym) and
                (vo_is_funcret in parasym.varoptions) then
               location_copy(aktcallnode.location,left.location);
           end;

         { next parameter }
         if assigned(right) then
           tcallparanode(right).secondcallparan;
      end;


{*****************************************************************************
                             TCGCALLNODE
*****************************************************************************}

    procedure tcgcallnode.extra_interrupt_code;
      begin
      end;


    procedure tcgcallnode.extra_call_code;
      begin
      end;


    procedure tcgcallnode.extra_post_call_code;
      begin
      end;


    procedure tcgcallnode.pop_parasize(pop_size:longint);
      begin
      end;


    procedure tcgcallnode.handle_return_value;
      var
        cgsize    : tcgsize;
        retloc    : tlocation;
        hregister : tregister;
        tempnode  : tnode;
      begin
        cgsize:=procdefinition.funcretloc[callerside].size;

        { structured results are easy to handle....
          needed also when result_no_used !! }
        if (procdefinition.proctypeoption<>potype_constructor) and
           paramanager.ret_in_param(resulttype.def,procdefinition.proccalloption) then
          begin
            { Location should be setup by the funcret para }
            if location.loc<>LOC_REFERENCE then
             internalerror(200304241);
          end
        else
          { ansi/widestrings must be registered, so we can dispose them }
          if resulttype.def.needs_inittable then
            begin
              if procdefinition.funcretloc[callerside].loc<>LOC_REGISTER then
                internalerror(200409261);

              { the FUNCTION_RESULT_REG is already allocated }
              if getsupreg(procdefinition.funcretloc[callerside].register)<first_int_imreg then
                cg.ungetcpuregister(exprasmlist,procdefinition.funcretloc[callerside].register);
              if not assigned(funcretnode) then
                begin
                  { reg_ref could generate two instrcutions and allocate a register so we've to
                    save the result first before releasing it }
                  hregister:=cg.getaddressregister(exprasmlist);
                  cg.a_load_reg_reg(exprasmlist,OS_ADDR,OS_ADDR,procdefinition.funcretloc[callerside].register,hregister);

                  location_reset(location,LOC_REFERENCE,OS_ADDR);
                  location.reference:=refcountedtemp;
                  cg.a_load_reg_ref(exprasmlist,OS_ADDR,OS_ADDR,hregister,location.reference);
                end
              else
                begin
                  hregister := cg.getaddressregister(exprasmlist);
                  cg.a_load_reg_reg(exprasmlist,OS_ADDR,OS_ADDR,procdefinition.funcretloc[callerside].register,hregister);
                  { in case of a regular funcretnode with ret_in_param, the }
                  { original funcretnode isn't touched -> make sure it's    }
                  { the same here (not sure if it's necessary)              }
                  tempnode := funcretnode.getcopy;
                  tempnode.pass_2;
                  location := tempnode.location;
                  tempnode.free;
                  cg.g_decrrefcount(exprasmlist,resulttype.def,location.reference);
                  cg.a_load_reg_ref(exprasmlist,OS_ADDR,OS_ADDR,hregister,location.reference);
               end;
            end
        else
          { normal (ordinal,float,pointer) result value }
          begin
            { we have only to handle the result if it is used }
            if (cnf_return_value_used in callnodeflags) then
              begin
                location.loc:=procdefinition.funcretloc[callerside].loc;
                case procdefinition.funcretloc[callerside].loc of
                   LOC_FPUREGISTER:
                     begin
                       location_reset(location,LOC_FPUREGISTER,cgsize);
                       location.register:=procdefinition.funcretloc[callerside].register;
{$ifdef x86}
                       tcgx86(cg).inc_fpu_stack;
{$else x86}
                       if getsupreg(procdefinition.funcretloc[callerside].register)<first_fpu_imreg then
                         cg.ungetcpuregister(exprasmlist,procdefinition.funcretloc[callerside].register);
                       hregister:=cg.getfpuregister(exprasmlist,location.size);
                       cg.a_loadfpu_reg_reg(exprasmlist,location.size,location.register,hregister);
                       location.register:=hregister;
{$endif x86}
                     end;

                   LOC_REGISTER:
                     begin
                       if cgsize<>OS_NO then
                        begin
                          location_reset(location,LOC_REGISTER,cgsize);
{$ifndef cpu64bit}
                          if cgsize in [OS_64,OS_S64] then
                           begin
                             retloc:=procdefinition.funcretloc[callerside];
                             if retloc.loc<>LOC_REGISTER then
                               internalerror(200409141);
                             { the function result registers are already allocated }
                             if getsupreg(retloc.register64.reglo)<first_int_imreg then
                               cg.ungetcpuregister(exprasmlist,retloc.register64.reglo);
                             location.register64.reglo:=cg.getintregister(exprasmlist,OS_32);
                             cg.a_load_reg_reg(exprasmlist,OS_32,OS_32,retloc.register64.reglo,location.register64.reglo);
                             if getsupreg(retloc.register64.reghi)<first_int_imreg then
                               cg.ungetcpuregister(exprasmlist,retloc.register64.reghi);
                             location.register64.reghi:=cg.getintregister(exprasmlist,OS_32);
                             cg.a_load_reg_reg(exprasmlist,OS_32,OS_32,retloc.register64.reghi,location.register64.reghi);
                           end
                          else
{$endif cpu64bit}
                           begin
                             { change register size after the unget because the
                               getregister was done for the full register
                               def_cgsize(resulttype.def) is used here because
                               it could be a constructor call }
                             if getsupreg(procdefinition.funcretloc[callerside].register)<first_int_imreg then
                               cg.ungetcpuregister(exprasmlist,procdefinition.funcretloc[callerside].register);
                             location.register:=cg.getintregister(exprasmlist,def_cgsize(resulttype.def));
                             cg.a_load_reg_reg(exprasmlist,cgsize,def_cgsize(resulttype.def),procdefinition.funcretloc[callerside].register,location.register);
                           end;
                        end
                       else
                        begin
                          if resulttype.def.size>0 then
                            internalerror(200305131);
                        end;
                     end;

                   LOC_MMREGISTER:
                     begin
                       location_reset(location,LOC_MMREGISTER,cgsize);
                       if getsupreg(procdefinition.funcretloc[callerside].register)<first_mm_imreg then
                         cg.ungetcpuregister(exprasmlist,procdefinition.funcretloc[callerside].register);
                       location.register:=cg.getmmregister(exprasmlist,cgsize);
                       cg.a_loadmm_reg_reg(exprasmlist,cgsize,cgsize,procdefinition.funcretloc[callerside].register,location.register,mms_movescalar);
                     end;

                   else
                     internalerror(200405023);
                end;
              end
            else
              begin
{$ifdef x86}
                { release FPU stack }
                if procdefinition.funcretloc[callerside].loc=LOC_FPUREGISTER then
                  emit_reg(A_FSTP,S_NO,NR_FPU_RESULT_REG);
{$endif x86}
                if cgsize<>OS_NO then
                  location_free(exprasmlist,procdefinition.funcretloc[callerside]);
                location_reset(location,LOC_VOID,OS_NO);
              end;
           end;

        { When the result is not used we need to finalize the result and
          can release the temp }
        if not(cnf_return_value_used in callnodeflags) then
          begin
            if location.loc=LOC_REFERENCE then
              begin
                if resulttype.def.needs_inittable then
                  cg.g_finalize(exprasmlist,resulttype.def,location.reference);
                tg.ungetiftemp(exprasmlist,location.reference)
              end;
          end;
      end;


    procedure tcgcallnode.release_para_temps;
      var
        hp  : tnode;
        ppn : tcallparanode;
      begin
        { Release temps from parameters }
        ppn:=tcallparanode(left);
        while assigned(ppn) do
          begin
             if assigned(ppn.left) then
               begin
                 { don't release the funcret temp }
                 if not(assigned(ppn.parasym)) or
                    not(vo_is_funcret in ppn.parasym.varoptions) then
                   location_freetemp(exprasmlist,ppn.left.location);
                 { process also all nodes of an array of const }
                 hp:=ppn.left;
                 while (hp.nodetype=typeconvn) do
                   hp:=ttypeconvnode(hp).left;
                 if (hp.nodetype=arrayconstructorn) and
                    assigned(tarrayconstructornode(hp).left) then
                   begin
                     while assigned(hp) do
                       begin
                         location_freetemp(exprasmlist,tarrayconstructornode(hp).left.location);
                         hp:=tarrayconstructornode(hp).right;
                       end;
                   end;
               end;
             ppn:=tcallparanode(ppn.right);
          end;
      end;


     procedure tcgcallnode.pushparas;
       var
         ppn : tcgcallparanode;
         callerparaloc,
         tmpparaloc : pcgparalocation;
         sizeleft: aint;
{$ifdef cputargethasfixedstack}
         htempref,
         href : treference;
{$endif cputargethasfixedstack}
       begin
         { copy all resources to the allocated registers }
         ppn:=tcgcallparanode(left);
         while assigned(ppn) do
           begin
             if (ppn.left.nodetype<>nothingn) then
               begin
                 { better check for the real location of the parameter here, when stack passed parameters
                   are saved temporary in registers, checking for the tmpparaloc.loc is wrong
                 }
{$ifdef PASS2INLINE}
                 if not assigned(inlinecode) then
{$endif PASS2INLINE}
                   paramanager.freeparaloc(exprasmlist,ppn.tempcgpara);
                 tmpparaloc:=ppn.tempcgpara.location;
                 sizeleft:=ppn.tempcgpara.intsize;
                 callerparaloc:=ppn.parasym.paraloc[callerside].location;
                 while assigned(callerparaloc) do
                   begin
                     { Every paraloc must have a matching tmpparaloc }
                     if not assigned(tmpparaloc) then
                       internalerror(200408224);
                     if callerparaloc^.size<>tmpparaloc^.size then
                       internalerror(200408225);
                     case callerparaloc^.loc of
                       LOC_REGISTER:
                         begin
                           if tmpparaloc^.loc<>LOC_REGISTER then
                             internalerror(200408221);
                           if getsupreg(callerparaloc^.register)<first_int_imreg then
                             cg.getcpuregister(exprasmlist,callerparaloc^.register);
                           cg.a_load_reg_reg(exprasmlist,tmpparaloc^.size,tmpparaloc^.size,
                               tmpparaloc^.register,callerparaloc^.register);
                         end;
                       LOC_FPUREGISTER:
                         begin
                           if tmpparaloc^.loc<>LOC_FPUREGISTER then
                             internalerror(200408222);
                           if getsupreg(callerparaloc^.register)<first_fpu_imreg then
                             cg.getcpuregister(exprasmlist,callerparaloc^.register);
                           cg.a_loadfpu_reg_reg(exprasmlist,ppn.tempcgpara.size,tmpparaloc^.register,callerparaloc^.register);
                         end;
                       LOC_MMREGISTER:
                         begin
                           if tmpparaloc^.loc<>LOC_MMREGISTER then
                             internalerror(200408223);
                           if getsupreg(callerparaloc^.register)<first_mm_imreg then
                             cg.getcpuregister(exprasmlist,callerparaloc^.register);
                           cg.a_loadmm_reg_reg(exprasmlist,tmpparaloc^.size,tmpparaloc^.size,
                             tmpparaloc^.register,callerparaloc^.register,mms_movescalar);
                         end;
                       LOC_REFERENCE:
                         begin
{$ifdef PASS2INLINE}
                           if not assigned(inlinecode) then
{$endif PASS2INLINE}
                             begin
{$ifdef cputargethasfixedstack}
                               { Can't have a data copied to the stack, every location
                                 must contain a valid size field }

                               if (ppn.tempcgpara.size=OS_NO) and
                                  ((tmpparaloc^.loc<>LOC_REFERENCE) or
                                   assigned(tmpparaloc^.next)) then
                                 internalerror(200501281);
                               reference_reset_base(href,callerparaloc^.reference.index,callerparaloc^.reference.offset);
                               { copy parameters in case they were moved to a temp. location because we've a fixed stack }
                               case tmpparaloc^.loc of
                                 LOC_REFERENCE:
                                   begin
                                     reference_reset_base(htempref,tmpparaloc^.reference.index,tmpparaloc^.reference.offset);
                                     { use concatcopy, because it can also be a float which fails when
                                       load_ref_ref is used }
                                     if (ppn.tempcgpara.size <> OS_NO) then
                                       cg.g_concatcopy(exprasmlist,htempref,href,tcgsize2size[tmpparaloc^.size])
                                      else
                                       cg.g_concatcopy(exprasmlist,htempref,href,sizeleft)
                                   end;
                                 LOC_REGISTER:
                                   cg.a_load_reg_ref(exprasmlist,tmpparaloc^.size,tmpparaloc^.size,tmpparaloc^.register,href);
                                 LOC_FPUREGISTER:
                                   cg.a_loadfpu_reg_ref(exprasmlist,tmpparaloc^.size,tmpparaloc^.register,href);
                                 LOC_MMREGISTER:
                                   cg.a_loadmm_reg_ref(exprasmlist,tmpparaloc^.size,tmpparaloc^.size,tmpparaloc^.register,href,mms_movescalar);
                                 else
                                   internalerror(200402081);
                               end;
{$endif cputargethasfixedstack}
                             end;
                         end;
                     end;
                     dec(sizeleft,tcgsize2size[tmpparaloc^.size]);
                     callerparaloc:=callerparaloc^.next;
                     tmpparaloc:=tmpparaloc^.next;
                   end;
               end;
             ppn:=tcgcallparanode(ppn.right);
           end;
       end;


     procedure tcgcallnode.freeparas;
       var
         ppn : tcgcallparanode;
       begin
         { free the resources allocated for the parameters }
         ppn:=tcgcallparanode(left);
         while assigned(ppn) do
           begin
             if (ppn.left.nodetype<>nothingn) then
               begin
                 if
{$ifdef PASS2INLINE}
                    not assigned(inlinecode) or
{$endif PASS2INLINE}
                    (ppn.parasym.paraloc[callerside].location^.loc <> LOC_REFERENCE) then
                   paramanager.freeparaloc(exprasmlist,ppn.parasym.paraloc[callerside]);
               end;
             ppn:=tcgcallparanode(ppn.right);
           end;
       end;



    procedure tcgcallnode.normal_pass_2;
      var
         regs_to_save_int,
         regs_to_save_fpu,
         regs_to_save_mm   : Tcpuregisterset;
         href : treference;
         pop_size : longint;
         pvreg,
         vmtreg : tregister;
         oldaktcallnode : tcallnode;
      begin
         if not assigned(procdefinition) or
            not procdefinition.has_paraloc_info then
           internalerror(200305264);

         if resulttype.def.needs_inittable and
            not paramanager.ret_in_param(resulttype.def,procdefinition.proccalloption) and
            not assigned(funcretnode) then
           begin
             tg.gettemptyped(exprasmlist,resulttype.def,tt_normal,refcountedtemp);
             cg.g_decrrefcount(exprasmlist,resulttype.def,refcountedtemp);
           end;

         regs_to_save_int:=paramanager.get_volatile_registers_int(procdefinition.proccalloption);
         regs_to_save_fpu:=paramanager.get_volatile_registers_fpu(procdefinition.proccalloption);
         regs_to_save_mm:=paramanager.get_volatile_registers_mm(procdefinition.proccalloption);

         { Include Function result registers }
         if (not is_void(resulttype.def)) then
          begin
            case procdefinition.funcretloc[callerside].loc of
              LOC_REGISTER,
              LOC_CREGISTER:
                include(regs_to_save_int,getsupreg(procdefinition.funcretloc[callerside].register));
              LOC_FPUREGISTER,
              LOC_CFPUREGISTER:
                include(regs_to_save_fpu,getsupreg(procdefinition.funcretloc[callerside].register));
              LOC_MMREGISTER,
              LOC_CMMREGISTER:
                include(regs_to_save_mm,getsupreg(procdefinition.funcretloc[callerside].register));
              LOC_REFERENCE,
              LOC_VOID:
                ;
              else
                internalerror(2004110213);
              end;
          end;

         { Process parameters, register parameters will be loaded
           in imaginary registers. The actual load to the correct
           register is done just before the call }
         oldaktcallnode:=aktcallnode;
         aktcallnode:=self;
         if assigned(left) then
           tcallparanode(left).secondcallparan;
         aktcallnode:=oldaktcallnode;

         { procedure variable or normal function call ? }
         if (right=nil) then
           begin
             { When methodpointer is typen we don't need (and can't) load
               a pointer. We can directly call the correct procdef (PFV) }
             if (po_virtualmethod in procdefinition.procoptions) and
                assigned(methodpointer) and
                (methodpointer.nodetype<>typen) then
               begin
                 { virtual methods require an index }
                 if tprocdef(procdefinition).extnumber=$ffff then
                   internalerror(200304021);

                 secondpass(methodpointer);

                 { Load VMT from self }
                 if methodpointer.resulttype.def.deftype=objectdef then
                   gen_load_vmt_register(exprasmlist,tobjectdef(methodpointer.resulttype.def),methodpointer.location,vmtreg)
                 else
                   begin
                     { Load VMT value in register }
                     location_force_reg(exprasmlist,methodpointer.location,OS_ADDR,false);
                     vmtreg:=methodpointer.location.register;
                   end;

                 { test validity of VMT }
                 if not(is_interface(tprocdef(procdefinition)._class)) and
                    not(is_cppclass(tprocdef(procdefinition)._class)) then
                   cg.g_maybe_testvmt(exprasmlist,vmtreg,tprocdef(procdefinition)._class);

                 pvreg:=cg.getintregister(exprasmlist,OS_ADDR);
                 reference_reset_base(href,vmtreg,
                    tprocdef(procdefinition)._class.vmtmethodoffset(tprocdef(procdefinition).extnumber));
                 cg.a_load_ref_reg(exprasmlist,OS_ADDR,OS_ADDR,href,pvreg);

                 { Load parameters that are in temporary registers in the
                   correct parameter register }
                 if assigned(left) then
                   begin
                     pushparas;
                     { free the resources allocated for the parameters }
                     freeparas;
                   end;

                 cg.alloccpuregisters(exprasmlist,R_INTREGISTER,regs_to_save_int);
                 if cg.uses_registers(R_FPUREGISTER) then
                   cg.alloccpuregisters(exprasmlist,R_FPUREGISTER,regs_to_save_fpu);
                 if cg.uses_registers(R_MMREGISTER) then
                   cg.alloccpuregisters(exprasmlist,R_MMREGISTER,regs_to_save_mm);

                 { call method }
                 extra_call_code;
                 cg.a_call_reg(exprasmlist,pvreg);
                 extra_post_call_code;
               end
             else
               begin
                  { Load parameters that are in temporary registers in the
                    correct parameter register }
                  if assigned(left) then
                    begin
                      pushparas;
                      { free the resources allocated for the parameters }
                      freeparas;
                    end;

                  cg.alloccpuregisters(exprasmlist,R_INTREGISTER,regs_to_save_int);
                  if cg.uses_registers(R_FPUREGISTER) then
                    cg.alloccpuregisters(exprasmlist,R_FPUREGISTER,regs_to_save_fpu);
                  if cg.uses_registers(R_MMREGISTER) then
                    cg.alloccpuregisters(exprasmlist,R_MMREGISTER,regs_to_save_mm);

                  if procdefinition.proccalloption=pocall_syscall then
                    do_syscall
                  else
                    begin
                      { Calling interrupt from the same code requires some
                        extra code }
                      if (po_interrupt in procdefinition.procoptions) then
                        extra_interrupt_code;
                      extra_call_code;
                      cg.a_call_name(exprasmlist,tprocdef(procdefinition).mangledname);
                      extra_post_call_code;
                    end;
               end;
           end
         else
           { now procedure variable case }
           begin
              secondpass(right);

              pvreg:=cg.getintregister(exprasmlist,OS_ADDR);
              { Only load OS_ADDR from the reference }
              if right.location.loc in [LOC_REFERENCE,LOC_CREFERENCE] then
                cg.a_load_ref_reg(exprasmlist,OS_ADDR,OS_ADDR,right.location.reference,pvreg)
              else
                cg.a_load_loc_reg(exprasmlist,OS_ADDR,right.location,pvreg);
              location_freetemp(exprasmlist,right.location);

              { Load parameters that are in temporary registers in the
                correct parameter register }
              if assigned(left) then
                begin
                  pushparas;
                  { free the resources allocated for the parameters }
                  freeparas;
                end;

              cg.alloccpuregisters(exprasmlist,R_INTREGISTER,regs_to_save_int);
              if cg.uses_registers(R_FPUREGISTER) then
                cg.alloccpuregisters(exprasmlist,R_FPUREGISTER,regs_to_save_fpu);
              if cg.uses_registers(R_MMREGISTER) then
                cg.alloccpuregisters(exprasmlist,R_MMREGISTER,regs_to_save_mm);

              { Calling interrupt from the same code requires some
                extra code }
              if (po_interrupt in procdefinition.procoptions) then
                extra_interrupt_code;
              extra_call_code;
              cg.a_call_reg(exprasmlist,pvreg);
              extra_post_call_code;
           end;

         { Need to remove the parameters from the stack? }
         if (procdefinition.proccalloption in clearstack_pocalls) then
          begin
            pop_size:=pushedparasize;
            { for Cdecl functions we don't need to pop the funcret when it
              was pushed by para }
            if paramanager.ret_in_param(procdefinition.rettype.def,procdefinition.proccalloption) then
              dec(pop_size,sizeof(aint));
            { Remove parameters/alignment from the stack }
            pop_parasize(pop_size);
          end;

         { Release registers, but not the registers that contain the
           function result }
         if (not is_void(resulttype.def)) then
           begin
             case procdefinition.funcretloc[callerside].loc of
               LOC_REGISTER,
               LOC_CREGISTER:
                 begin
{$ifndef cpu64bit}
                   if procdefinition.funcretloc[callerside].size in [OS_64,OS_S64] then
                     begin
                       exclude(regs_to_save_int,getsupreg(procdefinition.funcretloc[callerside].register64.reghi));
                       exclude(regs_to_save_int,getsupreg(procdefinition.funcretloc[callerside].register64.reglo));
                     end
                   else
{$endif cpu64bit}
                     exclude(regs_to_save_int,getsupreg(procdefinition.funcretloc[callerside].register));
                 end;
               LOC_FPUREGISTER,
               LOC_CFPUREGISTER:
                 exclude(regs_to_save_fpu,getsupreg(procdefinition.funcretloc[callerside].register));
               LOC_MMREGISTER,
               LOC_CMMREGISTER:
                 exclude(regs_to_save_mm,getsupreg(procdefinition.funcretloc[callerside].register));
               LOC_REFERENCE,
               LOC_VOID:
                 ;
               else
                 internalerror(2004110214);
              end;
           end;
         if cg.uses_registers(R_MMREGISTER) then
           cg.dealloccpuregisters(exprasmlist,R_MMREGISTER,regs_to_save_mm);
         if cg.uses_registers(R_FPUREGISTER) then
           cg.dealloccpuregisters(exprasmlist,R_FPUREGISTER,regs_to_save_fpu);
         cg.dealloccpuregisters(exprasmlist,R_INTREGISTER,regs_to_save_int);

         { handle function results }
         if (not is_void(resulttype.def)) then
           handle_return_value
         else
           location_reset(location,LOC_VOID,OS_NO);

         { perhaps i/o check ? }
         if (cs_check_io in aktlocalswitches) and
            (po_iocheck in procdefinition.procoptions) and
            not(po_iocheck in current_procinfo.procdef.procoptions) and
            { no IO check for methods and procedure variables }
            (right=nil) and
            not(po_virtualmethod in procdefinition.procoptions) then
           begin
              cg.allocallcpuregisters(exprasmlist);
              cg.a_call_name(exprasmlist,'FPC_IOCHECK');
              cg.deallocallcpuregisters(exprasmlist);
           end;

         { release temps of paras }
         release_para_temps;
      end;


{$ifdef PASS2INLINE}
    procedure tcgcallnode.inlined_pass_2;
      var
         oldaktcallnode : tcallnode;
         oldprocinfo : tprocinfo;
         oldinlining_procedure : boolean;
         inlineentrycode,inlineexitcode : TAAsmoutput;
{$ifdef GDB}
         startlabel,endlabel : tasmlabel;
         pp : pchar;
         mangled_length  : longint;
{$endif GDB}
      begin
         if not(assigned(procdefinition) and (procdefinition.deftype=procdef)) then
           internalerror(200305262);

         oldinlining_procedure:=inlining_procedure;
         oldprocinfo:=current_procinfo;
         { we're inlining a procedure }
         inlining_procedure:=true;

         { Add inling start }
{$ifdef GDB}
         exprasmlist.concat(Tai_force_line.Create);
{$endif GDB}
         exprasmList.concat(Tai_Marker.Create(InlineStart));
{$ifdef extdebug}
         exprasmList.concat(tai_comment.Create(strpnew('Start of inlined proc '+tprocdef(procdefinition).procsym.name)));
{$endif extdebug}

         { calculate registers to pass the parameters }
         paramanager.create_inline_paraloc_info(procdefinition);

         { Allocate parameters and locals }
         gen_alloc_inline_parast(exprasmlist,tprocdef(procdefinition));
         gen_alloc_inline_funcret(exprasmlist,tprocdef(procdefinition));
         gen_alloc_symtable(exprasmlist,tprocdef(procdefinition).localst);

         { if we allocate the temp. location for ansi- or widestrings }
         { already here, we avoid later a push/pop                    }
         if resulttype.def.needs_inittable and
            not paramanager.ret_in_param(resulttype.def,procdefinition.proccalloption) then
           begin
             tg.gettemptyped(exprasmlist,resulttype.def,tt_normal,refcountedtemp);
             cg.g_decrrefcount(exprasmlist,resulttype.def,refcountedtemp);
           end;

         { Push parameters, still use the old current_procinfo. This
           is required that have the correct information available like
           _class and nested procedure }
         oldaktcallnode:=aktcallnode;
         aktcallnode:=self;
         if assigned(left) then
           begin
             tcallparanode(left).secondcallparan;
             pushparas;
           end;
         aktcallnode:=oldaktcallnode;

         { create temp procinfo that will be used for the inlinecode tree }
         current_procinfo:=cprocinfo.create(nil);
         current_procinfo.procdef:=tprocdef(procdefinition);
         current_procinfo.flags:=oldprocinfo.flags;
         current_procinfo.aktlocaldata.destroy;
         current_procinfo.aktlocaldata:=oldprocinfo.aktlocaldata;

         { when the oldprocinfo is also being inlined reuse the
           inlining_procinfo }
         if assigned(oldprocinfo.inlining_procinfo) then
           current_procinfo.inlining_procinfo:=oldprocinfo.inlining_procinfo
         else
           current_procinfo.inlining_procinfo:=oldprocinfo;

         { takes care of local data initialization }
         inlineentrycode:=TAAsmoutput.Create;
         inlineexitcode:=TAAsmoutput.Create;

{$ifdef GDB}
         if (cs_debuginfo in aktmoduleswitches) and
            not(cs_gdb_valgrind in aktglobalswitches) then
           begin
             objectlibrary.getaddrlabel(startlabel);
             objectlibrary.getaddrlabel(endlabel);
             cg.a_label(exprasmlist,startlabel);

             { Here we must include the para and local symtable info }
             procdefinition.concatstabto(al_withdebug);

             mangled_length:=length(current_procinfo.inlining_procinfo.procdef.mangledname);
             getmem(pp,mangled_length+50);
             strpcopy(pp,'192,0,0,'+startlabel.name);
             if (target_info.use_function_relative_addresses) then
               begin
                 strpcopy(strend(pp),'-');
                 strpcopy(strend(pp),current_procinfo.inlining_procinfo.procdef.mangledname);
               end;
             al_withdebug.concat(Tai_stabn.Create(strnew(pp)));
           end;
{$endif GDB}

         gen_load_para_value(inlineentrycode);
         { now that we've loaded the para's, free them }
         if assigned(left) then
           freeparas;
         gen_initialize_code(inlineentrycode);
         if po_assembler in current_procinfo.procdef.procoptions then
           inlineentrycode.insert(Tai_marker.Create(asmblockstart));
         exprasmList.concatlist(inlineentrycode);

         { process the inline code }
         secondpass(inlinecode);

         cg.a_label(exprasmlist,current_procinfo.aktexitlabel);
         gen_finalize_code(inlineexitcode);
         gen_load_return_value(inlineexitcode);
         if po_assembler in current_procinfo.procdef.procoptions then
           inlineexitcode.concat(Tai_marker.Create(asmblockend));
         exprasmlist.concatlist(inlineexitcode);

         inlineentrycode.free;
         inlineexitcode.free;
{$ifdef extdebug}
         exprasmList.concat(tai_comment.Create(strpnew('End of inlined proc')));
{$endif extdebug}
         exprasmList.concat(Tai_Marker.Create(InlineEnd));

         { handle function results }
         if (not is_void(resulttype.def)) then
           handle_return_value
         else
           location_reset(location,LOC_VOID,OS_NO);

         { perhaps i/o check ? }
         if (cs_check_io in aktlocalswitches) and
            (po_iocheck in procdefinition.procoptions) and
            not(po_iocheck in current_procinfo.procdef.procoptions) and
            { no IO check for methods and procedure variables }
            (right=nil) and
            not(po_virtualmethod in procdefinition.procoptions) then
           begin
              cg.allocallcpuregisters(exprasmlist);
              cg.a_call_name(exprasmlist,'FPC_IOCHECK');
              cg.deallocallcpuregisters(exprasmlist);
           end;

         { release temps of paras }
         release_para_temps;

         { if return value is not used }
         if (not is_void(resulttype.def)) and
            (not(cnf_return_value_used in callnodeflags)) then
           begin
              if location.loc in [LOC_CREFERENCE,LOC_REFERENCE] then
                begin
                   { data which must be finalized ? }
                   if (resulttype.def.needs_inittable) then
                      cg.g_finalize(exprasmlist,resulttype.def,location.reference);
                   { release unused temp }
                   tg.ungetiftemp(exprasmlist,location.reference)
                end
              else if location.loc=LOC_FPUREGISTER then
                begin
{$ifdef x86}
                  { release FPU stack }
                  emit_reg(A_FSTP,S_NO,NR_FPU_RESULT_REG);
{$endif x86}
                end;
           end;

         { Release parameters and locals }
         gen_free_symtable(exprasmlist,tparasymtable(current_procinfo.procdef.parast));
         gen_free_symtable(exprasmlist,tlocalsymtable(current_procinfo.procdef.localst));

{$ifdef GDB}
         if (cs_debuginfo in aktmoduleswitches) and
            not(cs_gdb_valgrind in aktglobalswitches) then
           begin
             cg.a_label(exprasmlist,endlabel);
             strpcopy(pp,'224,0,0,'+endlabel.name);
             if (target_info.use_function_relative_addresses) then
               begin
                 strpcopy(strend(pp),'-');
                 strpcopy(strend(pp),current_procinfo.inlining_procinfo.procdef.mangledname);
               end;
             al_withdebug.concat(Tai_stabn.Create(strnew(pp)));
             freemem(pp,mangled_length+50);
           end;
{$endif GDB}

         { restore }
         current_procinfo.aktlocaldata:=nil;
         current_procinfo.destroy;
         current_procinfo:=oldprocinfo;
         inlining_procedure:=oldinlining_procedure;
      end;
{$endif PASS2INLINE}


    procedure tcgcallnode.pass_2;
      begin
        if assigned(methodpointerinit) then
          secondpass(methodpointerinit);

{$ifdef PASS2INLINE}
        if assigned(inlinecode) then
          inlined_pass_2
        else
{$endif PASS2INLINE}
          normal_pass_2;

        if assigned(methodpointerdone) then
          secondpass(methodpointerdone);
      end;


begin
   ccallparanode:=tcgcallparanode;
   ccallnode:=tcgcallnode;
end.
