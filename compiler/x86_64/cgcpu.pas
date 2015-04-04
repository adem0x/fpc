{
    Copyright (c) 2002 by Florian Klaempfl

    This unit implements the code generator for the x86-64.

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
unit cgcpu;

{$i fpcdefs.inc}

  interface

    uses
       cgbase,cgutils,cgobj,cgx86,
       aasmbase,aasmtai,aasmdata,aasmcpu,
       cpubase,cpuinfo,cpupara,parabase,
       symdef,
       node,symconst,rgx86,procinfo;

    type
      tcgx86_64 = class(tcgx86)
        procedure init_register_allocators;override;

        procedure a_loadfpu_ref_cgpara(list: TAsmList; size: tcgsize; const ref: treference; const cgpara: TCGPara); override;
        procedure a_loadfpu_reg_ref(list: TAsmList; fromsize, tosize: tcgsize; reg: tregister; const ref: treference); override;

        procedure g_proc_entry(list : TAsmList;localsize:longint; nostackframe:boolean);override;
        procedure g_proc_exit(list : TAsmList;parasize:longint;nostackframe:boolean);override;
        procedure g_local_unwind(list: TAsmList; l: TAsmLabel);override;
        procedure g_save_registers(list: TAsmList);override;
        procedure g_restore_registers(list: TAsmList);override;

        procedure a_loadmm_intreg_reg(list: TAsmList; fromsize, tosize : tcgsize;intreg, mmreg: tregister; shuffle: pmmshuffle); override;
        procedure a_loadmm_reg_intreg(list: TAsmList; fromsize, tosize : tcgsize;mmreg, intreg: tregister;shuffle : pmmshuffle); override;
      private
        function use_push: boolean;
        function saved_xmm_reg_size: longint;
      end;

    procedure create_codegen;

  implementation

    uses
       globtype,globals,verbose,systems,cutils,cclasses,
       symsym,symtable,defutil,paramgr,fmodule,cpupi,
       rgobj,tgobj,rgcpu,ncgutil;


    procedure Tcgx86_64.init_register_allocators;
      const
        win64_saved_std_regs : array[0..7] of tsuperregister = (RS_RBX,RS_RDI,RS_RSI,RS_R12,RS_R13,RS_R14,RS_R15,RS_RBP);
        others_saved_std_regs : array[0..4] of tsuperregister = (RS_RBX,RS_R12,RS_R13,RS_R14,RS_R15);
        saved_regs_length : array[boolean] of longint = (5,7);

        win64_saved_xmm_regs : array[0..9] of tsuperregister = (RS_XMM6,RS_XMM7,
          RS_XMM8,RS_XMM9,RS_XMM10,RS_XMM11,RS_XMM12,RS_XMM13,RS_XMM14,RS_XMM15);
      var
        i : longint;
      begin
        inherited init_register_allocators;

        if (length(saved_standard_registers)<>saved_regs_length[target_info.system=system_x86_64_win64]) then
          begin
            if target_info.system=system_x86_64_win64 then
              begin
                SetLength(saved_standard_registers,Length(win64_saved_std_regs));
                SetLength(saved_mm_registers,Length(win64_saved_xmm_regs));

                for i:=low(win64_saved_std_regs) to high(win64_saved_std_regs) do
                  saved_standard_registers[i]:=win64_saved_std_regs[i];

                for i:=low(win64_saved_xmm_regs) to high(win64_saved_xmm_regs) do
                  saved_mm_registers[i]:=win64_saved_xmm_regs[i];
              end
            else
              begin
                SetLength(saved_standard_registers,Length(others_saved_std_regs));
                SetLength(saved_mm_registers,0);

                for i:=low(others_saved_std_regs) to high(others_saved_std_regs) do
                  saved_standard_registers[i]:=others_saved_std_regs[i];
              end;
          end;
        if target_info.system=system_x86_64_win64 then
          begin
            if (cs_userbp in current_settings.optimizerswitches) and assigned(current_procinfo) and (current_procinfo.framepointer=NR_STACK_POINTER_REG) then
              begin
                rg[R_INTREGISTER]:=trgcpu.create(R_INTREGISTER,R_SUBWHOLE,[RS_RAX,RS_RDX,RS_RCX,RS_R8,RS_R9,RS_R10,
                  RS_R11,RS_RBX,RS_RSI,RS_RDI,RS_R12,RS_R13,RS_R14,RS_R15,RS_RBP],first_int_imreg,[]);
              end
            else
              rg[R_INTREGISTER]:=trgcpu.create(R_INTREGISTER,R_SUBWHOLE,[RS_RAX,RS_RDX,RS_RCX,RS_R8,RS_R9,RS_R10,
                RS_R11,RS_RBX,RS_RSI,RS_RDI,RS_R12,RS_R13,RS_R14,RS_R15],first_int_imreg,[])
          end
        else
          rg[R_INTREGISTER]:=trgcpu.create(R_INTREGISTER,R_SUBWHOLE,[RS_RAX,RS_RDX,RS_RCX,RS_RSI,RS_RDI,RS_R8,
            RS_R9,RS_R10,RS_R11,RS_RBX,RS_R12,RS_R13,RS_R14,RS_R15],first_int_imreg,[]);

        rg[R_MMREGISTER]:=trgcpu.create(R_MMREGISTER,R_SUBWHOLE,[RS_XMM0,RS_XMM1,RS_XMM2,RS_XMM3,RS_XMM4,RS_XMM5,RS_XMM6,RS_XMM7,
          RS_XMM8,RS_XMM9,RS_XMM10,RS_XMM11,RS_XMM12,RS_XMM13,RS_XMM14,RS_XMM15],first_mm_imreg,[]);
        rgfpu:=Trgx86fpu.create;
      end;


    procedure tcgx86_64.a_loadfpu_ref_cgpara(list: TAsmList; size: tcgsize; const ref: treference; const cgpara: TCGPara);
      begin
        { a record containing an extended value is returned on the x87 stack
          -> size will be OS_F128 (if not packed), while cgpara.paraloc^.size
          contains the proper size

          In the future we should probably always use cgpara.location^.size, but
          that should only be tested/done after 2.8 is branched }
        if size in [OS_128,OS_F128] then
          size:=cgpara.location^.size;
        inherited;
      end;


    procedure tcgx86_64.a_loadfpu_reg_ref(list: TAsmList; fromsize, tosize: tcgsize; reg: tregister; const ref: treference);
      begin
        { same as with a_loadfpu_ref_cgpara() above, but on the callee side
          when the value is moved from the fpu register into a memory location }
        if tosize in [OS_128,OS_F128] then
          tosize:=OS_F80;
        inherited;
      end;


    function tcgx86_64.use_push: boolean;
      begin
        result:=(current_procinfo.framepointer=NR_STACK_POINTER_REG) or
          (current_procinfo.procdef.proctypeoption=potype_exceptfilter);
      end;


    function tcgx86_64.saved_xmm_reg_size: longint;
      var
        i: longint;
      begin
        result:=0;
        if (target_info.system<>system_x86_64_win64) or
           (not uses_registers(R_MMREGISTER)) then
          exit;
        for i:=low(saved_mm_registers) to high(saved_mm_registers) do
          begin
            if (saved_mm_registers[i] in rg[R_MMREGISTER].used_in_proc) then
              inc(result,tcgsize2size[OS_VECTOR]);
          end;
      end;


    procedure tcgx86_64.g_proc_entry(list : TAsmList;localsize:longint;nostackframe:boolean);
      var
        hitem: tlinkedlistitem;
        r: integer;
        href: treference;
        templist: TAsmList;
        frame_offset: longint;
        suppress_endprologue: boolean;
        stackmisalignment: longint;
        xmmsize: longint;

      procedure push_one_reg(reg: tregister);
        begin
          list.concat(taicpu.op_reg(A_PUSH,tcgsize2opsize[OS_ADDR],reg));
          if (target_info.system=system_x86_64_win64) then
            begin
              list.concat(cai_seh_directive.create_reg(ash_pushreg,reg));
              include(current_procinfo.flags,pi_has_unwind_info);
            end;
        end;

      procedure push_regs;
        var
          r: longint;
        begin
          for r := low(saved_standard_registers) to high(saved_standard_registers) do
            if saved_standard_registers[r] in rg[R_INTREGISTER].used_in_proc then
              begin
                inc(stackmisalignment,sizeof(pint));
                push_one_reg(newreg(R_INTREGISTER,saved_standard_registers[r],R_SUBWHOLE));
              end;
        end;

      begin
        hitem:=list.last;
        { pi_has_unwind_info may already be set at this point if there are
          SEH directives in assembler body. In this case, .seh_endprologue
          is expected to be one of those directives, and not generated here. }
        suppress_endprologue:=(pi_has_unwind_info in current_procinfo.flags);

        { save old framepointer }
        if not nostackframe then
          begin
            { return address }
            stackmisalignment := sizeof(pint);
            list.concat(tai_regalloc.alloc(current_procinfo.framepointer,nil));
            if current_procinfo.framepointer=NR_STACK_POINTER_REG then
              begin
                push_regs;
                CGmessage(cg_d_stackframe_omited);
              end
            else
              begin
                { push <frame_pointer> }
                inc(stackmisalignment,sizeof(pint));
                push_one_reg(NR_FRAME_POINTER_REG);
                { Return address and FP are both on stack }
                current_asmdata.asmcfi.cfa_def_cfa_offset(list,2*sizeof(pint));
                current_asmdata.asmcfi.cfa_offset(list,NR_FRAME_POINTER_REG,-(2*sizeof(pint)));
                if current_procinfo.procdef.proctypeoption<>potype_exceptfilter then
                  list.concat(Taicpu.op_reg_reg(A_MOV,tcgsize2opsize[OS_ADDR],NR_STACK_POINTER_REG,NR_FRAME_POINTER_REG))
                else
                  begin
                    push_regs;
                    gen_load_frame_for_exceptfilter(list);
                    { Need only as much stack space as necessary to do the calls.
                      Exception filters don't have own local vars, and temps are 'mapped'
                      to the parent procedure.
                      maxpushedparasize is already aligned at least on x86_64. }
                    localsize:=current_procinfo.maxpushedparasize;
                  end;
                current_asmdata.asmcfi.cfa_def_cfa_register(list,NR_FRAME_POINTER_REG);
                {
                  TODO: current framepointer handling is not compatible with Win64 at all:
                  Win64 expects FP to point to the top or into the middle of local area.
                  In FPC it points to the bottom, making it impossible to generate
                  UWOP_SET_FPREG unwind code if local area is > 240 bytes.
                  So for now pretend we never have a framepointer.
                }
              end;

            xmmsize:=saved_xmm_reg_size;
            if use_push and (xmmsize<>0) then
              begin
                localsize:=align(localsize,target_info.stackalign)+xmmsize;
                reference_reset_base(current_procinfo.save_regs_ref,NR_STACK_POINTER_REG,
                  localsize-xmmsize,tcgsize2size[OS_VECTOR]);
              end;

            { allocate stackframe space }
            if (localsize<>0) or
               ((target_info.stackalign>sizeof(pint)) and
                (stackmisalignment <> 0) and
                ((pi_do_call in current_procinfo.flags) or
                 (po_assembler in current_procinfo.procdef.procoptions))) then
              begin
                if target_info.stackalign>sizeof(pint) then
                  localsize := align(localsize+stackmisalignment,target_info.stackalign)-stackmisalignment;
                cg.g_stackpointer_alloc(list,localsize);
                if current_procinfo.framepointer=NR_STACK_POINTER_REG then
                  current_asmdata.asmcfi.cfa_def_cfa_offset(list,localsize+sizeof(pint));
                current_procinfo.final_localsize:=localsize;
                if (target_info.system=system_x86_64_win64) then
                  begin
                    if localsize<>0 then
                      list.concat(cai_seh_directive.create_offset(ash_stackalloc,localsize));
                    include(current_procinfo.flags,pi_has_unwind_info);
                    if use_push and (xmmsize<>0) then
                      begin
                        href:=current_procinfo.save_regs_ref;
                        for r:=low(saved_mm_registers) to high(saved_mm_registers) do
                          if saved_mm_registers[r] in rg[R_MMREGISTER].used_in_proc then
                            begin
                              a_loadmm_reg_ref(list,OS_VECTOR,OS_VECTOR,newreg(R_MMREGISTER,saved_mm_registers[r],R_SUBMMWHOLE),href,nil);
                              inc(href.offset,tcgsize2size[OS_VECTOR]);
                            end;
                      end;
                  end;
               end;
          end;

        if not (pi_has_unwind_info in current_procinfo.flags) then
          exit;
        { Generate unwind data for x86_64-win64 }
        list.insertafter(cai_seh_directive.create_name(ash_proc,current_procinfo.procdef.mangledname),hitem);
        templist:=TAsmList.Create;

        { We need to record postive offsets from RSP; if registers are saved
          at negative offsets from RBP we need to account for it. }
        if (not use_push) then
          frame_offset:=current_procinfo.final_localsize
        else
          frame_offset:=0;

        { There's no need to describe position of register saves precisely;
          since registers are not modified before they are saved, and saves do not
          change RSP, 'logically' all saves can happen at the end of prologue. }
        href:=current_procinfo.save_regs_ref;
        if (not use_push) then
          begin
            for r:=low(saved_standard_registers) to high(saved_standard_registers) do
              if saved_standard_registers[r] in rg[R_INTREGISTER].used_in_proc then
                begin
                  templist.concat(cai_seh_directive.create_reg_offset(ash_savereg,
                    newreg(R_INTREGISTER,saved_standard_registers[r],R_SUBWHOLE),
                    href.offset+frame_offset));
                 inc(href.offset,sizeof(aint));
                end;
          end;
        if uses_registers(R_MMREGISTER) then
          begin
            if (href.offset mod tcgsize2size[OS_VECTOR])<>0 then
              inc(href.offset,tcgsize2size[OS_VECTOR]-(href.offset mod tcgsize2size[OS_VECTOR]));

            for r:=low(saved_mm_registers) to high(saved_mm_registers) do
              begin
                if saved_mm_registers[r] in rg[R_MMREGISTER].used_in_proc then
                  begin
                    templist.concat(cai_seh_directive.create_reg_offset(ash_savexmm,
                      newreg(R_MMREGISTER,saved_mm_registers[r],R_SUBMMWHOLE),
                      href.offset+frame_offset));
                    inc(href.offset,tcgsize2size[OS_VECTOR]);
                  end;
              end;
          end;
        if not suppress_endprologue then
          templist.concat(cai_seh_directive.create(ash_endprologue));
        if assigned(current_procinfo.endprologue_ai) then
          current_procinfo.aktproccode.insertlistafter(current_procinfo.endprologue_ai,templist)
        else
          list.concatlist(templist);
        templist.free;
      end;


    procedure tcgx86_64.g_proc_exit(list : TAsmList;parasize:longint;nostackframe:boolean);

      procedure increase_sp(a : tcgint);
        var
          href : treference;
        begin
          reference_reset_base(href,NR_STACK_POINTER_REG,a,0);
          { normally, lea is a better choice than an add }
          list.concat(Taicpu.op_ref_reg(A_LEA,TCGSize2OpSize[OS_ADDR],href,NR_STACK_POINTER_REG));
        end;

      var
        href : treference;
        hreg : tregister;
        r : longint;
      begin
        { Prevent return address from a possible call from ending up in the epilogue }
        { (restoring registers happens before epilogue, providing necessary padding) }
        if (current_procinfo.flags*[pi_has_unwind_info,pi_do_call,pi_has_saved_regs])=[pi_has_unwind_info,pi_do_call] then
          list.concat(Taicpu.op_none(A_NOP));
        { remove stackframe }
        if not nostackframe then
          begin
            if use_push then
              begin
                if (saved_xmm_reg_size<>0) then
                  begin
                    href:=current_procinfo.save_regs_ref;
                    for r:=low(saved_mm_registers) to high(saved_mm_registers) do
                      if saved_mm_registers[r] in rg[R_MMREGISTER].used_in_proc then
                        begin
                          { Allocate register so the optimizer does not remove the load }
                          hreg:=newreg(R_MMREGISTER,saved_mm_registers[r],R_SUBMMWHOLE);
                          a_reg_alloc(list,hreg);
                          a_loadmm_ref_reg(list,OS_VECTOR,OS_VECTOR,href,hreg,nil);
                          inc(href.offset,tcgsize2size[OS_VECTOR]);
                        end;
                  end;

                if (current_procinfo.final_localsize<>0) then
                  increase_sp(current_procinfo.final_localsize);
                internal_restore_regs(list,true);

                if (current_procinfo.procdef.proctypeoption=potype_exceptfilter) then
                  list.concat(Taicpu.op_reg(A_POP,tcgsize2opsize[OS_ADDR],NR_FRAME_POINTER_REG));
              end
            else if (target_info.system=system_x86_64_win64) then
              begin
                { Comply with Win64 unwinding mechanism, which only recognizes
                  'add $constant,%rsp' and 'lea offset(FPREG),%rsp' as belonging to
                  the function epilog.
                  Neither 'leave' nor even 'mov %FPREG,%rsp' are allowed. }
                reference_reset_base(href,current_procinfo.framepointer,0,sizeof(pint));
                list.concat(Taicpu.op_ref_reg(A_LEA,tcgsize2opsize[OS_ADDR],href,NR_STACK_POINTER_REG));
                list.concat(Taicpu.op_reg(A_POP,tcgsize2opsize[OS_ADDR],current_procinfo.framepointer));
              end
            else
              generate_leave(list);
            list.concat(tai_regalloc.dealloc(current_procinfo.framepointer,nil));
          end;

        list.concat(Taicpu.Op_none(A_RET,S_NO));
        if (pi_has_unwind_info in current_procinfo.flags) then
          begin
            tx86_64procinfo(current_procinfo).dump_scopes(list);
            list.concat(cai_seh_directive.create(ash_endproc));
          end;
      end;


    procedure tcgx86_64.g_save_registers(list: TAsmList);
      begin
        if (not use_push) then
          inherited g_save_registers(list);
      end;


    procedure tcgx86_64.g_restore_registers(list: TAsmList);
      begin
        if (not use_push) then
          inherited g_restore_registers(list);
      end;


    procedure tcgx86_64.g_local_unwind(list: TAsmList; l: TAsmLabel);
      var
        para1,para2: tcgpara;
        href: treference;
        pd: tprocdef;
      begin
        if (target_info.system<>system_x86_64_win64) then
          begin
            inherited g_local_unwind(list,l);
            exit;
          end;
        pd:=search_system_proc('_fpc_local_unwind');
        para1.init;
        para2.init;
        paramanager.getintparaloc(list,pd,1,para1);
        paramanager.getintparaloc(list,pd,2,para2);
        reference_reset_symbol(href,l,0,1);
        { TODO: using RSP is correct only while the stack is fixed!!
          (true now, but will change if/when allocating from stack is implemented) }
        a_load_reg_cgpara(list,OS_ADDR,NR_STACK_POINTER_REG,para1);
        a_loadaddr_ref_cgpara(list,href,para2);
        paramanager.freecgpara(list,para2);
        paramanager.freecgpara(list,para1);
        g_call(list,'_FPC_local_unwind');
        para2.done;
        para1.done;
      end;

    procedure tcgx86_64.a_loadmm_intreg_reg(list: TAsmList; fromsize, tosize : tcgsize; intreg, mmreg: tregister; shuffle: pmmshuffle);
      var
        opc: tasmop;
      begin
        { this code can only be used to transfer raw data, not to perform
          conversions }
        if (tcgsize2size[fromsize]<>tcgsize2size[tosize]) or
           not(tosize in [OS_F32,OS_F64,OS_M64]) then
          internalerror(2009112505);
        case fromsize of
          OS_32,OS_S32:
            opc:=A_MOVD;
          OS_64,OS_S64:
            opc:=A_MOVQ;
          else
            internalerror(2009112506);
        end;
        if assigned(shuffle) and
           not shufflescalar(shuffle) then
          internalerror(2009112517);
        list.concat(taicpu.op_reg_reg(opc,S_NO,intreg,mmreg));
      end;


    procedure tcgx86_64.a_loadmm_reg_intreg(list: TAsmList; fromsize, tosize : tcgsize; mmreg, intreg: tregister;shuffle : pmmshuffle);
      var
        opc: tasmop;
      begin
        { this code can only be used to transfer raw data, not to perform
          conversions }
        if (tcgsize2size[fromsize]<>tcgsize2size[tosize]) or
           not (fromsize in [OS_F32,OS_F64,OS_M64]) then
          internalerror(2009112507);
        case tosize of
          OS_32,OS_S32:
            opc:=A_MOVD;
          OS_64,OS_S64:
            opc:=A_MOVQ;
          else
            internalerror(2009112408);
        end;
        if assigned(shuffle) and
           not shufflescalar(shuffle) then
          internalerror(2009112515);
        list.concat(taicpu.op_reg_reg(opc,S_NO,mmreg,intreg));
      end;


    procedure create_codegen;
      begin
        cg:=tcgx86_64.create;
        cg128:=tcg128.create;
      end;

end.
