{
    Copyright (c) 2006 by Florian Klaempfl

    This unit implements the common part of the code generator for the PowerPC

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
unit cgppc;

{$i fpcdefs.inc}

  interface

    uses
       globtype,symtype,symdef,
       cgbase,cgobj,
       aasmbase,aasmcpu,aasmtai,aasmdata,
       cpubase,cpuinfo,cgutils,rgcpu,
       parabase;

    type
      tcgppcgen = class(tcg)
        procedure a_param_const(list: TAsmList; size: tcgsize; a: aint; const paraloc : tcgpara); override;
        procedure a_paramaddr_ref(list : TAsmList;const r : treference;const paraloc : tcgpara); override;

        procedure a_call_reg(list : TAsmList;reg: tregister); override;
        procedure a_call_ref(list : TAsmList;ref: treference); override;

        { stores the contents of register reg to the memory location described by
        ref }
        procedure a_load_reg_ref(list: TAsmList; fromsize, tosize: TCGSize;
          reg: tregister; const ref: treference); override;

        { fpu move instructions }
        procedure a_loadfpu_reg_reg(list: TAsmList; fromsize, tosize: tcgsize; reg1, reg2: tregister); override;
        procedure a_loadfpu_ref_reg(list: TAsmList; fromsize, tosize: tcgsize; const ref: treference; reg: tregister); override;
        procedure a_loadfpu_reg_ref(list: TAsmList; fromsize, tosize: tcgsize; reg: tregister; const ref: treference); override;

        { overflow checking }
        procedure g_overflowcheck(list: TAsmList; const l: tlocation; def: tdef);override;

        { entry code }
        procedure g_profilecode(list: TAsmList); override;

        procedure a_jmp_cond(list : TAsmList;cond : TOpCmp;l: tasmlabel);
       protected
        function  get_darwin_call_stub(const s: string): tasmsymbol;
        procedure a_load_subsetref_regs_noindex(list: TAsmList; subsetsize: tcgsize; loadbitsize: byte; const sref: tsubsetreference; valuereg, extra_value_reg: tregister); override;
        function  fixref(list: TAsmList; var ref: treference): boolean; virtual; abstract;
        procedure a_load_store(list:TAsmList;op: tasmop;reg:tregister;ref: treference);virtual;abstract;

        { creates the correct branch instruction for a given combination }
        { of asmcondflags and destination addressing mode                }
        procedure a_jmp(list: TAsmList; op: tasmop;
                        c: tasmcondflag; crval: longint; l: tasmlabel);
     end;

  const
    TOpCmp2AsmCond: Array[topcmp] of TAsmCondFlag = (C_NONE,C_EQ,C_GT,
                         C_LT,C_GE,C_LE,C_NE,C_LE,C_LT,C_GE,C_GT);  


  implementation

    uses
       globals,verbose,systems,cutils,
       symconst,symsym,fmodule,
       rgobj,tgobj,cpupi,procinfo,paramgr;


    procedure tcgppcgen.a_param_const(list: TAsmList; size: tcgsize; a: aint; const
      paraloc: tcgpara);
    var
      ref: treference;
    begin
      paraloc.check_simple_location;
      case paraloc.location^.loc of
        LOC_REGISTER, LOC_CREGISTER:
          a_load_const_reg(list, size, a, paraloc.location^.register);
        LOC_REFERENCE:
          begin
            reference_reset(ref);
            ref.base := paraloc.location^.reference.index;
            ref.offset := paraloc.location^.reference.offset;
            a_load_const_ref(list, size, a, ref);
          end;
      else
        internalerror(2002081101);
      end;
    end;


    procedure tcgppcgen.a_paramaddr_ref(list : TAsmList;const r : treference;const paraloc : tcgpara);
      var
        ref: treference;
        tmpreg: tregister;

      begin
        paraloc.check_simple_location;
        case paraloc.location^.loc of
           LOC_REGISTER,LOC_CREGISTER:
             a_loadaddr_ref_reg(list,r,paraloc.location^.register);
           LOC_REFERENCE:
             begin
               reference_reset(ref);
               ref.base := paraloc.location^.reference.index;
               ref.offset := paraloc.location^.reference.offset;
               tmpreg := rg[R_INTREGISTER].getregister(list,R_SUBWHOLE);
               a_loadaddr_ref_reg(list,r,tmpreg);
               a_load_reg_ref(list,OS_ADDR,OS_ADDR,tmpreg,ref);
             end;
           else
             internalerror(2002080701);
        end;
      end;


    function tcgppcgen.get_darwin_call_stub(const s: string): tasmsymbol;
      var
        stubname: string;
        href: treference;
        l1: tasmsymbol;
      begin
        { function declared in the current unit? }
        { doesn't work correctly, because this will also return a hit if we }
        { previously took the address of an external procedure. It doesn't  }
        { really matter, the linker will remove all unnecessary stubs.      }
        stubname := 'L'+s+'$stub';
        result := current_asmdata.getasmsymbol(stubname);
        if assigned(result) then
          exit;

        if current_asmdata.asmlists[al_imports]=nil then
          current_asmdata.asmlists[al_imports]:=TAsmList.create;

        current_asmdata.asmlists[al_imports].concat(Tai_section.create(sec_stub,'',0));
        current_asmdata.asmlists[al_imports].concat(Tai_align.Create(16));
        result := current_asmdata.RefAsmSymbol(stubname);
        current_asmdata.asmlists[al_imports].concat(Tai_symbol.Create(result,0));
        current_asmdata.asmlists[al_imports].concat(tai_directive.create(asd_indirect_symbol,s));
        l1 := current_asmdata.RefAsmSymbol('L'+s+'$lazy_ptr');
        reference_reset_symbol(href,l1,0);
        href.refaddr := addr_hi;
        current_asmdata.asmlists[al_imports].concat(taicpu.op_reg_ref(A_LIS,NR_R11,href));
        href.refaddr := addr_lo;
        href.base := NR_R11;
{$ifndef cpu64bit}
        current_asmdata.asmlists[al_imports].concat(taicpu.op_reg_ref(A_LWZU,NR_R12,href));
{$else cpu64bit}
        { darwin/ppc64 uses a 32 bit absolute address here, strange... }
        current_asmdata.asmlists[al_imports].concat(taicpu.op_reg_ref(A_LDU,NR_R12,href));
{$endif cpu64bit}
        current_asmdata.asmlists[al_imports].concat(taicpu.op_reg(A_MTCTR,NR_R12));
        current_asmdata.asmlists[al_imports].concat(taicpu.op_none(A_BCTR));
        current_asmdata.asmlists[al_imports].concat(tai_directive.create(asd_lazy_symbol_pointer,''));
        current_asmdata.asmlists[al_imports].concat(Tai_symbol.Create(l1,0));
        current_asmdata.asmlists[al_imports].concat(tai_directive.create(asd_indirect_symbol,s));
        current_asmdata.asmlists[al_imports].concat(tai_const.createname('dyld_stub_binding_helper',0));
      end;


    { calling a procedure by address }
    procedure tcgppcgen.a_call_reg(list : TAsmList;reg: tregister);
      begin
        list.concat(taicpu.op_reg(A_MTCTR,reg));
        list.concat(taicpu.op_none(A_BCTRL));
        include(current_procinfo.flags,pi_do_call);
      end;


    procedure tcgppcgen.a_call_ref(list : TAsmList;ref: treference);
      var
        tempreg : TRegister;
      begin
        tempreg := getintregister(list, OS_ADDR);
        a_load_ref_reg(list,OS_ADDR,OS_ADDR,ref,tempreg);
        a_call_reg(list,tempreg);
      end;


    procedure tcgppcgen.a_load_reg_ref(list: TAsmList; fromsize, tosize: TCGSize;
      reg: tregister; const ref: treference);
    
    const
      StoreInstr: array[OS_8..OS_INT, boolean, boolean] of TAsmOp =
      { indexed? updating?}
      (((A_STB, A_STBU), (A_STBX, A_STBUX)),
        ((A_STH, A_STHU), (A_STHX, A_STHUX)),
        ((A_STW, A_STWU), (A_STWX, A_STWUX))
{$ifdef cpu64bit}
        ,
        ((A_STD, A_STDU), (A_STDX, A_STDUX))
{$endif cpu64bit}
        );
    var
      op: TAsmOp;
      ref2: TReference;
    begin
      if not (fromsize in [OS_8..OS_INT,OS_S8..OS_SINT]) then
        internalerror(2002090903);
      if not (tosize in [OS_8..OS_INT,OS_S8..OS_SINT]) then
        internalerror(2002090905);
    
      ref2 := ref;
      fixref(list, ref2);
      if tosize in [OS_S8..OS_SINT] then
        { storing is the same for signed and unsigned values }
        tosize := tcgsize(ord(tosize) - (ord(OS_S8) - ord(OS_8)));
      op := storeinstr[tcgsize2unsigned[tosize], ref2.index <> NR_NO, false];
      a_load_store(list, op, reg, ref2);
    end;



     procedure tcgppcgen.a_loadfpu_reg_reg(list: TAsmList; fromsize, tosize: tcgsize; reg1, reg2: tregister);

       var
         op: tasmop;
         instr: taicpu;
       begin
         if not(fromsize in [OS_F32,OS_F64]) or
            not(tosize in [OS_F32,OS_F64]) then
           internalerror(2006123110);
         if (tosize < fromsize) then
           op:=A_FRSP
         else
           op:=A_FMR;
         instr := taicpu.op_reg_reg(op,reg2,reg1);
         list.concat(instr);
         if (op = A_FMR) then
           rg[R_FPUREGISTER].add_move_instruction(instr);
       end;


     procedure tcgppcgen.a_loadfpu_ref_reg(list: TAsmList; fromsize, tosize: tcgsize; const ref: treference; reg: tregister);

       const
         FpuLoadInstr: Array[OS_F32..OS_F64,boolean, boolean] of TAsmOp =
                          { indexed? updating?}
                    (((A_LFS,A_LFSU),(A_LFSX,A_LFSUX)),
                     ((A_LFD,A_LFDU),(A_LFDX,A_LFDUX)));
       var
         op: tasmop;
         ref2: treference;

       begin
         if not(fromsize in [OS_F32,OS_F64]) or
            not(tosize in [OS_F32,OS_F64]) then
           internalerror(200201121);
         ref2 := ref;
         fixref(list,ref2);
         op := fpuloadinstr[fromsize,ref2.index <> NR_NO,false];
         a_load_store(list,op,reg,ref2);
         if (fromsize > tosize) then
           a_loadfpu_reg_reg(list,fromsize,tosize,reg,reg);
       end;


     procedure tcgppcgen.a_loadfpu_reg_ref(list: TAsmList; fromsize, tosize: tcgsize; reg: tregister; const ref: treference);

       const
         FpuStoreInstr: Array[OS_F32..OS_F64,boolean, boolean] of TAsmOp =
                            { indexed? updating?}
                    (((A_STFS,A_STFSU),(A_STFSX,A_STFSUX)),
                     ((A_STFD,A_STFDU),(A_STFDX,A_STFDUX)));
       var
         op: tasmop;
         ref2: treference;
{$ifndef cpu64bit}
         reg2: tregister;
{$endif cpu64bit}

       begin
         if not(fromsize in [OS_F32,OS_F64]) or
            not(tosize in [OS_F32,OS_F64]) then
           internalerror(200201122);
         ref2 := ref;
         fixref(list,ref2);
         op := fpustoreinstr[tosize,ref2.index <> NR_NO,false];
{$ifndef cpu64bit}
         { some ppc's have a bug whereby storing a double to memory }
         { as single corrupts the value -> convert double to single }
         { first                                                    }
         if (tosize < fromsize) then
           begin
             reg2:=getfpuregister(list,tosize);
             a_loadfpu_reg_reg(list,fromsize,tosize,reg,reg2);
             reg:=reg2;
           end;
{$endif not cpu64bit}
         a_load_store(list,op,reg,ref2);
       end;


  procedure tcgppcgen.a_load_subsetref_regs_noindex(list: TAsmList; subsetsize: tcgsize; loadbitsize: byte; const sref: tsubsetreference; valuereg, extra_value_reg: tregister);
    var
      fromsreg, tosreg: tsubsetregister;
      restbits: byte;
    begin
      restbits := (sref.bitlen - (loadbitsize - sref.startbit));
      a_op_const_reg(list,OP_SHL,OS_INT,restbits,valuereg);
      { mask other bits }
      if (sref.bitlen <> AIntBits) then
        a_op_const_reg(list,OP_AND,OS_INT,(aword(1) shl sref.bitlen)-1,valuereg);
      { use subsetreg routine, it may have been overridden with an optimized version }
      fromsreg.subsetreg := extra_value_reg;
      fromsreg.subsetregsize := OS_INT;
      { subsetregs always count bits from right to left }
      if (target_info.endian = endian_big) then
        fromsreg.startbit := loadbitsize-restbits
      else
        fromsreg.startbit := 0;
      fromsreg.bitlen := restbits;
  
      tosreg.subsetreg := valuereg;
      tosreg.subsetregsize := OS_INT;
      if (target_info.endian = endian_big) then
        tosreg.startbit := 0
      else
        tosreg.startbit := loadbitsize-sref.startbit;
      tosreg.bitlen := restbits;
  
      a_load_subsetreg_subsetreg(list,subsetsize,subsetsize,fromsreg,tosreg);
    end;


  procedure tcgppcgen.g_overflowcheck(list: TAsmList; const l: tlocation; def: tdef);
    var
      hl : tasmlabel;
      flags : TResFlags;
    begin
      if not(cs_check_overflow in current_settings.localswitches) then
        exit;
      current_asmdata.getjumplabel(hl);
      if not ((def.typ=pointerdef) or
             ((def.typ=orddef) and
              (torddef(def).ordtype in [u64bit,u16bit,u32bit,u8bit,uchar,
                                        bool8bit,bool16bit,bool32bit,bool64bit]))) then
        begin
          if (current_settings.optimizecputype >= cpu_ppc970) or
             (current_settings.cputype >= cpu_ppc970) then
            begin
              { ... instructions setting overflow flag ...
              mfxerf R0
              mtcrf 128, R0
              ble cr0, label }
              list.concat(taicpu.op_reg(A_MFXER, NR_R0));
              list.concat(taicpu.op_const_reg(A_MTCRF, 128, NR_R0));
              flags.cr := RS_CR0;
              flags.flag := F_LE;
              a_jmp_flags(list, flags, hl);
            end
          else
            begin
              list.concat(taicpu.op_reg(A_MCRXR,NR_CR7));
              a_jmp(list,A_BC,C_NO,7,hl)
            end;
        end
      else
        a_jmp_cond(list,OC_AE,hl);
      a_call_name(list,'FPC_OVERFLOW');
      a_label(list,hl);
    end;


  procedure tcgppcgen.g_profilecode(list: TAsmList);
    var
      paraloc1 : tcgpara;
      reg: tregister;
    begin
      if (target_info.system in [system_powerpc_darwin]) then
        begin
          paraloc1.init;
          paramanager.getintparaloc(pocall_cdecl,1,paraloc1);
          a_param_reg(list,OS_ADDR,NR_R0,paraloc1);
          paramanager.freeparaloc(list,paraloc1);
          paraloc1.done;
          allocallcpuregisters(list);
          a_call_name(list,'mcount');
          deallocallcpuregisters(list);
          a_reg_dealloc(list,NR_R0);
        end;
    end;


  procedure tcgppcgen.a_jmp_cond(list : TAsmList;cond : TOpCmp; l: tasmlabel);
    begin
      a_jmp(list,A_BC,TOpCmp2AsmCond[cond],0,l);
    end;


 procedure tcgppcgen.a_jmp(list: TAsmList; op: tasmop; c: tasmcondflag;
             crval: longint; l: tasmlabel);
   var
     p: taicpu;

   begin
     p := taicpu.op_sym(op,l);
     if op <> A_B then
       create_cond_norm(c,crval,p.condition);
     p.is_jmp := true;
     list.concat(p)
   end;




end.

