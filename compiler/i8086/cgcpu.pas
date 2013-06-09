{
    Copyright (c) 1998-2002 by Florian Klaempfl

    This unit implements the code generator for the i8086

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
       globtype,
       cgbase,cgobj,cg64f32,cgx86,
       aasmbase,aasmtai,aasmdata,aasmcpu,
       cpubase,parabase,cgutils,
       symconst,symdef
       ;

    type

      { tcg8086 }

      tcg8086 = class(tcgx86)
        procedure init_register_allocators;override;
        procedure do_register_allocation(list:TAsmList;headertai:tai);override;

        function getintregister(list:TAsmList;size:Tcgsize):Tregister;override;

        procedure a_call_name(list : TAsmList;const s : string; weak: boolean);override;
        procedure a_call_name_far(list : TAsmList;const s : string; weak: boolean);
        procedure a_call_name_static(list : TAsmList;const s : string);override;
        procedure a_call_name_static_far(list : TAsmList;const s : string);

        procedure a_op_const_reg(list : TAsmList; Op: TOpCG; size: TCGSize; a: tcgint; reg: TRegister); override;
        procedure a_op_const_ref(list : TAsmList; Op: TOpCG; size: TCGSize; a: tcgint; const ref: TReference); override;
        procedure a_op_reg_reg(list : TAsmList; Op: TOpCG; size: TCGSize; src, dst: TRegister); override;
        procedure a_op_ref_reg(list : TAsmList; Op: TOpCG; size: TCGSize; const ref: TReference; reg: TRegister); override;
        procedure a_op_reg_ref(list : TAsmList; Op: TOpCG; size: TCGSize;reg: TRegister; const ref: TReference); override;

        procedure push_const(list:TAsmList;size:tcgsize;a:tcgint);

        { passing parameter using push instead of mov }
        procedure a_load_reg_cgpara(list : TAsmList;size : tcgsize;r : tregister;const cgpara : tcgpara);override;
        procedure a_load_const_cgpara(list : TAsmList;size : tcgsize;a : tcgint;const cgpara : tcgpara);override;
        procedure a_load_ref_cgpara(list : TAsmList;size : tcgsize;const r : treference;const cgpara : tcgpara);override;
        procedure a_loadaddr_ref_cgpara(list : TAsmList;const r : treference;const cgpara : tcgpara);override;

        { move instructions }
        procedure a_load_const_reg(list : TAsmList; tosize: tcgsize; a : tcgint;reg : tregister);override;
        procedure a_load_const_ref(list : TAsmList; tosize: tcgsize; a : tcgint;const ref : treference);override;
        procedure a_load_reg_ref(list : TAsmList;fromsize,tosize: tcgsize; reg : tregister;const ref : treference);override;
        procedure a_load_ref_reg(list : TAsmList;fromsize,tosize: tcgsize;const ref : treference;reg : tregister);override;
        procedure a_load_reg_reg(list : TAsmList;fromsize,tosize: tcgsize;reg1,reg2 : tregister);override;

        procedure g_flags2reg(list: TAsmList; size: TCgSize; const f: tresflags; reg: TRegister);override;
        procedure g_flags2ref(list: TAsmList; size: TCgSize; const f: tresflags; const ref: TReference);override;

        procedure g_proc_exit(list : TAsmList;parasize:longint;nostackframe:boolean);override;
        procedure g_copyvaluepara_openarray(list : TAsmList;const ref:treference;const lenloc:tlocation;elesize:tcgint;destreg:tregister);
        procedure g_releasevaluepara_openarray(list : TAsmList;const l:tlocation);

        procedure g_exception_reason_save(list : TAsmList; const href : treference);override;
        procedure g_exception_reason_save_const(list : TAsmList; const href : treference; a: tcgint);override;
        procedure g_exception_reason_load(list : TAsmList; const href : treference);override;

        procedure g_adjust_self_value(list:TAsmList;procdef: tprocdef;ioffset: tcgint);override;
        procedure g_intf_wrapper(list: TAsmList; procdef: tprocdef; const labelname: string; ioffset: longint);override;

        procedure get_32bit_ops(op: TOpCG; out op1,op2: TAsmOp);
     end;

      tcg64f8086 = class(tcg64f32)
{        procedure a_op64_ref_reg(list : TAsmList;op:TOpCG;size : tcgsize;const ref : treference;reg : tregister64);override;}
        procedure a_op64_reg_reg(list : TAsmList;op:TOpCG;size : tcgsize;regsrc,regdst : tregister64);override;
        procedure a_op64_const_reg(list : TAsmList;op:TOpCG;size : tcgsize;value : int64;reg : tregister64);override;
{        procedure a_op64_const_ref(list : TAsmList;op:TOpCG;size : tcgsize;value : int64;const ref : treference);override;}
      private
        procedure get_64bit_ops(op:TOpCG;var op1,op2:TAsmOp);
      end;

    procedure create_codegen;

  implementation

    uses
       globals,verbose,systems,cutils,
       paramgr,procinfo,fmodule,
       rgcpu,rgx86,cpuinfo,
       symtype,symsym;

    function use_push(const cgpara:tcgpara):boolean;
      begin
        result:=(not paramanager.use_fixed_stack) and
                assigned(cgpara.location) and
                (cgpara.location^.loc=LOC_REFERENCE) and
                (cgpara.location^.reference.index=NR_STACK_POINTER_REG);
      end;


    procedure tcg8086.init_register_allocators;
      begin
        inherited init_register_allocators;
        if not(target_info.system in [system_i386_darwin,system_i386_iphonesim]) and
           (cs_create_pic in current_settings.moduleswitches) then
          rg[R_INTREGISTER]:=trgcpu.create(R_INTREGISTER,R_SUBWHOLE,[RS_AX,RS_DX,RS_CX,RS_SI,RS_DI],first_int_imreg,[RS_BP])
        else
          if (cs_useebp in current_settings.optimizerswitches) and assigned(current_procinfo) and (current_procinfo.framepointer<>NR_BP) then
            rg[R_INTREGISTER]:=trgcpu.create(R_INTREGISTER,R_SUBWHOLE,[RS_AX,RS_DX,RS_CX,RS_BX,RS_SI,RS_DI,RS_BP],first_int_imreg,[])
          else
            rg[R_INTREGISTER]:=trgintcpu.create(R_INTREGISTER,R_SUBWHOLE,[RS_AX,RS_DX,RS_CX,RS_BX,RS_SI,RS_DI],first_int_imreg,[RS_BP]);
        rg[R_MMXREGISTER]:=trgcpu.create(R_MMXREGISTER,R_SUBNONE,[RS_XMM0,RS_XMM1,RS_XMM2,RS_XMM3,RS_XMM4,RS_XMM5,RS_XMM6,RS_XMM7],first_mm_imreg,[]);
        rg[R_MMREGISTER]:=trgcpu.create(R_MMREGISTER,R_SUBWHOLE,[RS_XMM0,RS_XMM1,RS_XMM2,RS_XMM3,RS_XMM4,RS_XMM5,RS_XMM6,RS_XMM7],first_mm_imreg,[]);
        rgfpu:=Trgx86fpu.create;
      end;

    procedure tcg8086.do_register_allocation(list:TAsmList;headertai:tai);
      begin
        if (pi_needs_got in current_procinfo.flags) then
          begin
            if getsupreg(current_procinfo.got) < first_int_imreg then
              include(rg[R_INTREGISTER].used_in_proc,getsupreg(current_procinfo.got));
          end;
        inherited do_register_allocation(list,headertai);
      end;


    function tcg8086.getintregister(list: TAsmList; size: Tcgsize): Tregister;
      begin
        case size of
          OS_8, OS_S8,
          OS_16, OS_S16:
            Result := inherited getintregister(list, size);
          OS_32, OS_S32:
            begin
              Result:=inherited getintregister(list, OS_16);
              { ensure that the high register can be retrieved by
                GetNextReg
              }
              if inherited getintregister(list, OS_16)<>GetNextReg(Result) then
                internalerror(2013030202);
            end;
          else
            internalerror(2013030201);
        end;
      end;


    procedure tcg8086.a_call_name(list: TAsmList; const s: string; weak: boolean);
      begin
        if current_settings.x86memorymodel in x86_far_code_models then
          a_call_name_far(list,s,weak)
        else
          a_call_name_near(list,s,weak);
      end;


    procedure tcg8086.a_call_name_far(list: TAsmList; const s: string;
      weak: boolean);
      var
        sym : tasmsymbol;
        r : treference;
      begin
        if not(weak) then
          sym:=current_asmdata.RefAsmSymbol(s)
        else
          sym:=current_asmdata.WeakRefAsmSymbol(s);
        reference_reset_symbol(r,sym,0,sizeof(pint));
        r.refaddr:=addr_far;
        list.concat(taicpu.op_ref(A_CALL,S_NO,r));
      end;


    procedure tcg8086.a_call_name_static(list: TAsmList; const s: string);
      begin
        if current_settings.x86memorymodel in x86_far_code_models then
          a_call_name_static_far(list,s)
        else
          a_call_name_static_near(list,s);
      end;


    procedure tcg8086.a_call_name_static_far(list: TAsmList; const s: string);
      var
        sym : tasmsymbol;
        r : treference;
      begin
        sym:=current_asmdata.RefAsmSymbol(s);
        reference_reset_symbol(r,sym,0,sizeof(pint));
        r.refaddr:=addr_far;
        list.concat(taicpu.op_ref(A_CALL,S_NO,r));
      end;


    procedure tcg8086.a_op_const_reg(list: TAsmList; Op: TOpCG; size: TCGSize;
      a: tcgint; reg: TRegister);
      var
        tmpreg: tregister;
        op1, op2: TAsmOp;
        ax_subreg: tregister;
        hl_loop_start: tasmlabel;
        ai: taicpu;
        use_loop: Boolean;
        i: Integer;
      begin
        optimize_op_const(op, a);
        check_register_size(size,reg);

        if size in [OS_64, OS_S64] then
          internalerror(2013030904);

        if size in [OS_32, OS_S32] then
          begin
            case op of
              OP_NONE:
                begin
                  { Opcode is optimized away }
                end;
              OP_MOVE:
                begin
                  { Optimized, replaced with a simple load }
                  a_load_const_reg(list,size,a,reg);
                end;
              OP_ADD, OP_AND, OP_OR, OP_SUB, OP_XOR:
                begin
                  if (longword(a) = high(longword)) and
                     (op in [OP_AND,OP_OR,OP_XOR]) then
                    begin
                      case op of
                        OP_AND:
                          exit;
                        OP_OR:
                          a_load_const_reg(list,size,high(longword),reg);
                        OP_XOR:
                          begin
                            list.concat(taicpu.op_reg(A_NOT,S_W,reg));
                            list.concat(taicpu.op_reg(A_NOT,S_W,GetNextReg(reg)));
                          end;
                      end
                    end
                  else
                  begin
                    get_32bit_ops(op, op1, op2);
                    list.concat(taicpu.op_const_reg(op1,S_W,aint(a and $FFFF),reg));
                    list.concat(taicpu.op_const_reg(op2,S_W,aint(a shr 16),GetNextReg(reg)));
                  end;
                end;
              OP_SHR,OP_SHL,OP_SAR:
                begin
                  a:=a and 31;
                  { for shl with const >= 16, we can just move the low register
                    to the high reg, then zero the low register, then do the
                    remaining part of the shift (by const-16) in 16 bit on the
                    high register. the same thing applies to shr with low and high
                    reversed. sar is exactly like shr, except that instead of
                    zeroing the high register, we sar it by 15. }
                  if a>=16 then
                    case op of
                      OP_SHR:
                        begin
                          a_load_reg_reg(list,OS_16,OS_16,GetNextReg(reg),reg);
                          a_load_const_reg(list,OS_16,0,GetNextReg(reg));
                          a_op_const_reg(list,OP_SHR,OS_16,a-16,reg);
                        end;
                      OP_SHL:
                        begin
                          a_load_reg_reg(list,OS_16,OS_16,reg,GetNextReg(reg));
                          a_load_const_reg(list,OS_16,0,reg);
                          a_op_const_reg(list,OP_SHL,OS_16,a-16,GetNextReg(reg));
                        end;
                      OP_SAR:
                        begin
                          a_load_reg_reg(list,OS_16,OS_16,GetNextReg(reg),reg);
                          a_op_const_reg(list,OP_SAR,OS_16,15,GetNextReg(reg));
                          a_op_const_reg(list,OP_SAR,OS_16,a-16,reg);
                        end;
                      else
                        internalerror(2013060201);
                    end
                  else if a<>0 then
                    begin
                      use_loop:=a>2;

                      if use_loop then
                        begin
                          getcpuregister(list,NR_CX);
                          a_load_const_reg(list,OS_16,a,NR_CX);

                          current_asmdata.getjumplabel(hl_loop_start);
                          a_label(list,hl_loop_start);

                          case op of
                            OP_SHR:
                              begin
                                list.concat(taicpu.op_const_reg(A_SHR,S_W,1,GetNextReg(reg)));
                                list.concat(taicpu.op_const_reg(A_RCR,S_W,1,reg));
                              end;
                            OP_SAR:
                              begin
                                list.concat(taicpu.op_const_reg(A_SAR,S_W,1,GetNextReg(reg)));
                                list.concat(taicpu.op_const_reg(A_RCR,S_W,1,reg));
                              end;
                            OP_SHL:
                              begin
                                list.concat(taicpu.op_const_reg(A_SHL,S_W,1,reg));
                                list.concat(taicpu.op_const_reg(A_RCL,S_W,1,GetNextReg(reg)));
                              end;
                            else
                              internalerror(2013030903);
                          end;

                          ai:=Taicpu.Op_Sym(A_LOOP,S_W,hl_loop_start);
                          ai.is_jmp:=true;
                          list.concat(ai);

                          ungetcpuregister(list,NR_CX);
                        end
                      else
                        begin
                          for i:=1 to a do
                            begin
                              case op of
                                OP_SHR:
                                  begin
                                    list.concat(taicpu.op_const_reg(A_SHR,S_W,1,GetNextReg(reg)));
                                    list.concat(taicpu.op_const_reg(A_RCR,S_W,1,reg));
                                  end;
                                OP_SAR:
                                  begin
                                    list.concat(taicpu.op_const_reg(A_SAR,S_W,1,GetNextReg(reg)));
                                    list.concat(taicpu.op_const_reg(A_RCR,S_W,1,reg));
                                  end;
                                OP_SHL:
                                  begin
                                    list.concat(taicpu.op_const_reg(A_SHL,S_W,1,reg));
                                    list.concat(taicpu.op_const_reg(A_RCL,S_W,1,GetNextReg(reg)));
                                  end;
                                else
                                  internalerror(2013030903);
                              end;
                            end;
                        end;
                    end;
                end;
              else
                begin
                  tmpreg:=getintregister(list,size);
                  a_load_const_reg(list,size,a,tmpreg);
                  a_op_reg_reg(list,op,size,tmpreg,reg);
                end;
            end;
          end
        else
          begin
            { size <= 16-bit }

            { 8086 doesn't support 'imul reg,const', so we handle it here }
            if (current_settings.cputype<cpu_186) and (op in [OP_MUL,OP_IMUL]) then
              begin
                { TODO: also enable the SHL optimization below }
    {            if not(cs_check_overflow in current_settings.localswitches) and
                   ispowerof2(int64(a),power) then
                  begin
                    list.concat(taicpu.op_const_reg(A_SHL,TCgSize2OpSize[size],power,reg));
                    exit;
                  end;}
                if op = OP_IMUL then
                  begin
                    if size in [OS_16,OS_S16] then
                      ax_subreg := NR_AX
                    else
                      if size in [OS_8,OS_S8] then
                        ax_subreg := NR_AL
                      else
                        internalerror(2013050102);

                    getcpuregister(list,NR_AX);
                    if size in [OS_16,OS_S16] then
                      getcpuregister(list,NR_DX);

                    a_load_const_reg(list,size,a,ax_subreg);
                    list.concat(taicpu.op_reg(A_IMUL,TCgSize2OpSize[size],reg));
                    a_load_reg_reg(list,size,size,ax_subreg,reg);

                    ungetcpuregister(list,NR_AX);
                    if size in [OS_16,OS_S16] then
                      ungetcpuregister(list,NR_DX);

                    { TODO: implement overflow checking? }

                    exit;
                  end
                else
                  { OP_MUL should be handled specifically in the code        }
                  { generator because of the silly register usage restraints }
                  internalerror(200109225);
              end
            else
              inherited a_op_const_reg(list, Op, size, a, reg);
          end;
      end;


    procedure tcg8086.a_op_const_ref(list: TAsmList; Op: TOpCG; size: TCGSize; a: tcgint; const ref: TReference);
      var
        tmpref: treference;
        op1,op2: TAsmOp;
      begin
        optimize_op_const(op, a);
        tmpref:=ref;
        make_simple_ref(list,tmpref);

        if size in [OS_64, OS_S64] then
          internalerror(2013050801);
        if size in [OS_32, OS_S32] then
          begin
            case Op of
              OP_NONE :
                begin
                  { Opcode is optimized away }
                end;
              OP_MOVE :
                begin
                  { Optimized, replaced with a simple load }
                  a_load_const_ref(list,size,a,ref);
                end;
              OP_ADD, OP_AND, OP_OR, OP_SUB, OP_XOR:
                begin
                  if (longword(a) = high(longword)) and
                     (op in [OP_AND,OP_OR,OP_XOR]) then
                    begin
                      case op of
                        OP_AND:
                          exit;
                        OP_OR:
                          a_load_const_ref(list,size,high(longword),tmpref);
                        OP_XOR:
                          begin
                            list.concat(taicpu.op_ref(A_NOT,S_W,tmpref));
                            inc(tmpref.offset, 2);
                            list.concat(taicpu.op_ref(A_NOT,S_W,tmpref));
                          end;
                      end
                    end
                  else
                  begin
                    get_32bit_ops(op, op1, op2);
                    list.concat(taicpu.op_const_ref(op1,S_W,aint(a and $FFFF),tmpref));
                    inc(tmpref.offset, 2);
                    list.concat(taicpu.op_const_ref(op2,S_W,aint(a shr 16),tmpref));
                  end;
                end;
              else
                internalerror(2013050802);
            end;
          end
        else
          inherited a_op_const_ref(list,Op,size,a,tmpref);
      end;


    procedure tcg8086.a_op_reg_reg(list: TAsmList; Op: TOpCG; size: TCGSize;
      src, dst: TRegister);
      var
        op1, op2: TAsmOp;
        hl_skip, hl_loop_start: TAsmLabel;
        ai: taicpu;
      begin
        check_register_size(size,src);
        check_register_size(size,dst);
        if size in [OS_64, OS_S64] then
          internalerror(2013030902);
        if size in [OS_32, OS_S32] then
          begin
            case op of
              OP_NEG:
                begin
                  if src<>dst then
                    a_load_reg_reg(list,size,size,src,dst);
                  list.concat(taicpu.op_reg(A_NOT, S_W, GetNextReg(dst)));
                  list.concat(taicpu.op_reg(A_NEG, S_W, dst));
                  list.concat(taicpu.op_const_reg(A_SBB, S_W,-1, GetNextReg(dst)));
                end;
              OP_NOT:
                begin
                  if src<>dst then
                    a_load_reg_reg(list,size,size,src,dst);
                  list.concat(taicpu.op_reg(A_NOT, S_W, dst));
                  list.concat(taicpu.op_reg(A_NOT, S_W, GetNextReg(dst)));
                end;
              OP_ADD,OP_SUB,OP_XOR,OP_OR,OP_AND:
                begin
                  get_32bit_ops(op, op1, op2);
                  list.concat(taicpu.op_reg_reg(op1, S_W, src, dst));
                  list.concat(taicpu.op_reg_reg(op2, S_W, GetNextReg(src), GetNextReg(dst)));
                end;
              OP_SHR,OP_SHL,OP_SAR:
                begin
                  getcpuregister(list,NR_CX);
                  a_load_reg_reg(list,size,OS_16,src,NR_CX);
                  list.concat(taicpu.op_const_reg(A_AND,S_W,$1f,NR_CX));

                  current_asmdata.getjumplabel(hl_skip);
                  ai:=Taicpu.Op_Sym(A_Jcc,S_NO,hl_skip);
                  ai.SetCondition(C_Z);
                  ai.is_jmp:=true;
                  list.concat(ai);

                  current_asmdata.getjumplabel(hl_loop_start);
                  a_label(list,hl_loop_start);

                  case op of
                    OP_SHR:
                      begin
                        list.concat(taicpu.op_const_reg(A_SHR,S_W,1,GetNextReg(dst)));
                        list.concat(taicpu.op_const_reg(A_RCR,S_W,1,dst));
                      end;
                    OP_SAR:
                      begin
                        list.concat(taicpu.op_const_reg(A_SAR,S_W,1,GetNextReg(dst)));
                        list.concat(taicpu.op_const_reg(A_RCR,S_W,1,dst));
                      end;
                    OP_SHL:
                      begin
                        list.concat(taicpu.op_const_reg(A_SHL,S_W,1,dst));
                        list.concat(taicpu.op_const_reg(A_RCL,S_W,1,GetNextReg(dst)));
                      end;
                    else
                      internalerror(2013030903);
                  end;

                  ai:=Taicpu.Op_Sym(A_LOOP,S_W,hl_loop_start);
                  ai.is_jmp:=true;
                  list.concat(ai);

                  a_label(list,hl_skip);

                  ungetcpuregister(list,NR_CX);
                end;
              else
                internalerror(2013030901);
            end;
          end
        else
          inherited a_op_reg_reg(list, Op, size, src, dst);
      end;


    procedure tcg8086.a_op_ref_reg(list: TAsmList; Op: TOpCG; size: TCGSize; const ref: TReference; reg: TRegister);
      var
        tmpref  : treference;
        op1, op2: TAsmOp;
      begin
        tmpref:=ref;
        make_simple_ref(list,tmpref);
        check_register_size(size,reg);

        if size in [OS_64, OS_S64] then
          internalerror(2013030902);

        if size in [OS_32, OS_S32] then
          begin
            case op of
              OP_ADD,OP_SUB,OP_XOR,OP_OR,OP_AND:
                begin
                  get_32bit_ops(op, op1, op2);
                  list.concat(taicpu.op_ref_reg(op1, S_W, tmpref, reg));
                  inc(tmpref.offset, 2);
                  list.concat(taicpu.op_ref_reg(op2, S_W, tmpref, GetNextReg(reg)));
                end;
              else
                internalerror(2013050701);
            end;
          end
        else
          inherited a_op_ref_reg(list,Op,size,tmpref,reg);
      end;


    procedure tcg8086.a_op_reg_ref(list: TAsmList; Op: TOpCG; size: TCGSize; reg: TRegister; const ref: TReference);
      var
        tmpref: treference;
        op1,op2: TAsmOp;
      begin
        tmpref:=ref;
        make_simple_ref(list,tmpref);
        check_register_size(size,reg);

        if size in [OS_64, OS_S64] then
          internalerror(2013050803);

        if size in [OS_32, OS_S32] then
          begin
            case op of
              OP_NEG:
                begin
                  if reg<>NR_NO then
                    internalerror(200109237);
                  inc(tmpref.offset, 2);
                  list.concat(taicpu.op_ref(A_NOT, S_W, tmpref));
                  dec(tmpref.offset, 2);
                  list.concat(taicpu.op_ref(A_NEG, S_W, tmpref));
                  inc(tmpref.offset, 2);
                  list.concat(taicpu.op_const_ref(A_SBB, S_W,-1, tmpref));
                end;
              OP_NOT:
                begin
                  if reg<>NR_NO then
                    internalerror(200109237);
                  list.concat(taicpu.op_ref(A_NOT, S_W, tmpref));
                  inc(tmpref.offset, 2);
                  list.concat(taicpu.op_ref(A_NOT, S_W, tmpref));
                end;
              OP_IMUL:
                begin
                  { this one needs a load/imul/store, which is the default }
                  inherited a_op_ref_reg(list,op,size,tmpref,reg);
                end;
              OP_MUL,OP_DIV,OP_IDIV:
                { special stuff, needs separate handling inside code }
                { generator                                          }
                internalerror(200109238);
              OP_ADD,OP_SUB,OP_XOR,OP_OR,OP_AND:
                begin
                  get_32bit_ops(op, op1, op2);
                  list.concat(taicpu.op_reg_ref(op1, S_W, reg, tmpref));
                  inc(tmpref.offset, 2);
                  list.concat(taicpu.op_reg_ref(op2, S_W, GetNextReg(reg), tmpref));
                end;
              else
                internalerror(2013050804);
            end;
          end
        else
          inherited a_op_reg_ref(list,Op,size,reg,tmpref);
      end;


    procedure tcg8086.push_const(list: TAsmList; size: tcgsize; a: tcgint);
      var
        tmpreg: TRegister;
      begin
        if not (size in [OS_16,OS_S16]) then
          internalerror(2013043001);
        if current_settings.cputype < cpu_186 then
          begin
            tmpreg:=getintregister(list,size);
            a_load_const_reg(list,size,a,tmpreg);
            list.concat(taicpu.op_reg(A_PUSH,S_W,tmpreg));
          end
        else
          list.concat(taicpu.op_const(A_PUSH,TCGSize2OpSize[size],a));
      end;


    procedure tcg8086.a_load_reg_cgpara(list : TAsmList;size : tcgsize;r : tregister;const cgpara : tcgpara);
      var
        pushsize, pushsize2: tcgsize;
      begin
        check_register_size(size,r);
        if use_push(cgpara) then
          begin
            if tcgsize2size[cgpara.Size] > 2 then
              begin
                if tcgsize2size[cgpara.Size] <> 4 then
                  internalerror(2013031101);
                if cgpara.location^.Next = nil then
                  begin
                    if tcgsize2size[cgpara.location^.size] <> 4 then
                      internalerror(2013031101);
                  end
                else
                  begin
                    if tcgsize2size[cgpara.location^.size] <> 2 then
                      internalerror(2013031101);
                    if tcgsize2size[cgpara.location^.Next^.size] <> 2 then
                      internalerror(2013031101);
                    if cgpara.location^.Next^.Next <> nil then
                      internalerror(2013031101);
                  end;

                if tcgsize2size[cgpara.size]>cgpara.alignment then
                  pushsize:=cgpara.size
                else
                  pushsize:=int_cgsize(cgpara.alignment);
                pushsize2 := int_cgsize(tcgsize2size[pushsize] - 2);
                list.concat(taicpu.op_reg(A_PUSH,TCgsize2opsize[pushsize2],makeregsize(list,GetNextReg(r),pushsize2)));
                list.concat(taicpu.op_reg(A_PUSH,S_W,makeregsize(list,r,OS_16)));
              end
            else
              begin
                cgpara.check_simple_location;
                if tcgsize2size[cgpara.location^.size]>cgpara.alignment then
                  pushsize:=cgpara.location^.size
                else
                  pushsize:=int_cgsize(cgpara.alignment);
                list.concat(taicpu.op_reg(A_PUSH,TCgsize2opsize[pushsize],makeregsize(list,r,pushsize)));
              end;
          end
        else
          inherited a_load_reg_cgpara(list,size,r,cgpara);
      end;


    procedure tcg8086.a_load_const_cgpara(list : TAsmList;size : tcgsize;a : tcgint;const cgpara : tcgpara);
      var
        pushsize : tcgsize;
      begin
        if use_push(cgpara) then
          begin
            if tcgsize2size[cgpara.Size] > 2 then
              begin
                if tcgsize2size[cgpara.Size] <> 4 then
                  internalerror(2013031101);
                if cgpara.location^.Next = nil then
                  begin
                    if tcgsize2size[cgpara.location^.size] <> 4 then
                      internalerror(2013031101);
                  end
                else
                  begin
                    if tcgsize2size[cgpara.location^.size] <> 2 then
                      internalerror(2013031101);
                    if tcgsize2size[cgpara.location^.Next^.size] <> 2 then
                      internalerror(2013031101);
                    if cgpara.location^.Next^.Next <> nil then
                      internalerror(2013031101);
                  end;
                if (cgpara.alignment <> 4) and (cgpara.alignment <> 2) then
                  internalerror(2013031101);

                push_const(list,OS_16,a shr 16);
                push_const(list,OS_16,a and $FFFF);
              end
            else
              begin
                cgpara.check_simple_location;
                if tcgsize2size[cgpara.location^.size]>cgpara.alignment then
                  pushsize:=cgpara.location^.size
                else
                  pushsize:=int_cgsize(cgpara.alignment);
                push_const(list,pushsize,a);
              end;
          end
        else
          inherited a_load_const_cgpara(list,size,a,cgpara);
      end;


    procedure tcg8086.a_load_ref_cgpara(list : TAsmList;size : tcgsize;const r : treference;const cgpara : tcgpara);

        procedure pushdata(paraloc:pcgparalocation;ofs:tcgint);
        var
          pushsize : tcgsize;
          opsize : topsize;
          tmpreg   : tregister;
          href,tmpref: treference;
        begin
          if not assigned(paraloc) then
            exit;
          if (paraloc^.loc<>LOC_REFERENCE) or
             (paraloc^.reference.index<>NR_STACK_POINTER_REG) or
             (tcgsize2size[paraloc^.size]>4) then
            internalerror(200501162);
          { Pushes are needed in reverse order, add the size of the
            current location to the offset where to load from. This
            prevents wrong calculations for the last location when
            the size is not a power of 2 }
          if assigned(paraloc^.next) then
            pushdata(paraloc^.next,ofs+tcgsize2size[paraloc^.size]);
          { Push the data starting at ofs }
          href:=r;
          inc(href.offset,ofs);
          if tcgsize2size[paraloc^.size]>cgpara.alignment then
            pushsize:=paraloc^.size
          else
            pushsize:=int_cgsize(cgpara.alignment);
          opsize:=TCgsize2opsize[pushsize];
          { for go32v2 we obtain OS_F32,
            but pushs is not valid, we need pushl }
          if opsize=S_FS then
            opsize:=S_W;
          if tcgsize2size[paraloc^.size]<cgpara.alignment then
            begin
              tmpreg:=getintregister(list,pushsize);
              a_load_ref_reg(list,paraloc^.size,pushsize,href,tmpreg);
              list.concat(taicpu.op_reg(A_PUSH,opsize,tmpreg));
            end
          else
            begin
              make_simple_ref(list,href);
              if tcgsize2size[pushsize] > 2 then
                begin
                  tmpref := href;
                  Inc(tmpref.offset, 2);
                  list.concat(taicpu.op_ref(A_PUSH,TCgsize2opsize[int_cgsize(tcgsize2size[pushsize]-2)],tmpref));
                end;
              list.concat(taicpu.op_ref(A_PUSH,opsize,href));
            end;
        end;

      var
        len : tcgint;
        href : treference;
      begin
        { cgpara.size=OS_NO requires a copy on the stack }
        if use_push(cgpara) then
          begin
            { Record copy? }
            if (cgpara.size in [OS_NO,OS_F64]) or (size=OS_NO) then
              begin
                cgpara.check_simple_location;
                len:=align(cgpara.intsize,cgpara.alignment);
                g_stackpointer_alloc(list,len);
                reference_reset_base(href,NR_STACK_POINTER_REG,0,4);
                g_concatcopy(list,r,href,len);
              end
            else
              begin
                if tcgsize2size[cgpara.size]<>tcgsize2size[size] then
                  internalerror(200501161);
                { We need to push the data in reverse order,
                  therefor we use a recursive algorithm }
                pushdata(cgpara.location,0);
              end
          end
        else
          inherited a_load_ref_cgpara(list,size,r,cgpara);
      end;


    procedure tcg8086.a_loadaddr_ref_cgpara(list : TAsmList;const r : treference;const cgpara : tcgpara);
      var
        tmpreg : tregister;
        opsize : topsize;
        tmpref : treference;
      begin
        with r do
          begin
            if use_push(cgpara) then
              begin
                cgpara.check_simple_location;
                opsize:=tcgsize2opsize[OS_ADDR];
                if (segment=NR_NO) and (base=NR_NO) and (index=NR_NO) then
                  begin
                    if assigned(symbol) then
                      begin
                        if current_settings.cputype < cpu_186 then
                          begin
                            tmpreg:=getaddressregister(list);
                            a_loadaddr_ref_reg(list,r,tmpreg);
                            list.concat(taicpu.op_reg(A_PUSH,opsize,tmpreg));
                          end
                        else
                          list.concat(Taicpu.Op_sym_ofs(A_PUSH,opsize,symbol,offset));
                      end
                    else
                      push_const(list,OS_ADDR,offset);
                  end
                else if (segment=NR_NO) and (base=NR_NO) and (index<>NR_NO) and
                        (offset=0) and (scalefactor=0) and (symbol=nil) then
                  list.concat(Taicpu.Op_reg(A_PUSH,opsize,index))
                else if (segment=NR_NO) and (base<>NR_NO) and (index=NR_NO) and
                        (offset=0) and (symbol=nil) then
                  list.concat(Taicpu.Op_reg(A_PUSH,opsize,base))
                else
                  begin
                    tmpreg:=getaddressregister(list);
                    a_loadaddr_ref_reg(list,r,tmpreg);
                    list.concat(taicpu.op_reg(A_PUSH,opsize,tmpreg));
                  end;
              end
            else
              inherited a_loadaddr_ref_cgpara(list,r,cgpara);
          end;
      end;


    procedure tcg8086.a_load_const_reg(list : TAsmList; tosize: tcgsize; a : tcgint;reg : tregister);
    begin
      check_register_size(tosize,reg);
      if tosize in [OS_S32,OS_32] then
        begin
          list.concat(taicpu.op_const_reg(A_MOV,S_W,longint(a and $ffff),reg));
          list.concat(taicpu.op_const_reg(A_MOV,S_W,longint(a shr 16),GetNextReg(reg)));
        end
      else
        list.concat(taicpu.op_const_reg(A_MOV,TCGSize2OpSize[tosize],a,reg));
    end;


    procedure tcg8086.a_load_const_ref(list : TAsmList; tosize: tcgsize; a : tcgint;const ref : treference);
      var
        tmpref : treference;
      begin
        tmpref:=ref;
        make_simple_ref(list,tmpref);

        if tosize in [OS_S32,OS_32] then
          begin
            a_load_const_ref(list,OS_16,longint(a and $ffff),tmpref);
            inc(tmpref.offset,2);
            a_load_const_ref(list,OS_16,longint(a shr 16),tmpref);
          end
        else
          list.concat(taicpu.op_const_ref(A_MOV,TCGSize2OpSize[tosize],a,tmpref));
      end;



    procedure tcg8086.a_load_reg_ref(list : TAsmList;fromsize,tosize: tcgsize; reg : tregister;const ref : treference);
      var
        tmpsize : tcgsize;
        tmpreg  : tregister;
        tmpref  : treference;
      begin
        tmpref:=ref;
        make_simple_ref(list,tmpref);
        check_register_size(fromsize,reg);

        case tosize of
          OS_8,OS_S8:
            if fromsize in [OS_8,OS_S8] then
              list.concat(taicpu.op_reg_ref(A_MOV, S_B, reg, tmpref))
            else
              internalerror(2013030310);
          OS_16,OS_S16:
            case fromsize of
              OS_8:
                begin
                  reg := makeregsize(list, reg, OS_16);
                  setsubreg(reg, R_SUBH);
                  list.concat(taicpu.op_const_reg(A_MOV, S_B, 0, reg));
                  setsubreg(reg, R_SUBW);
                  list.concat(taicpu.op_reg_ref(A_MOV, S_W, reg, tmpref));
                end;
              OS_S8: internalerror(2013052503);  { TODO }
              OS_16,OS_S16:
                begin
                  list.concat(taicpu.op_reg_ref(A_MOV, S_W, reg, tmpref));
                end;
              else
                internalerror(2013030312);
            end;
          OS_32,OS_S32:
            case fromsize of
              OS_8:
                begin
                  reg := makeregsize(list, reg, OS_16);
                  setsubreg(reg, R_SUBH);
                  list.concat(taicpu.op_const_reg(A_MOV, S_B, 0, reg));
                  setsubreg(reg, R_SUBW);
                  list.concat(taicpu.op_reg_ref(A_MOV, S_W, reg, tmpref));
                  inc(tmpref.offset, 2);
                  list.concat(taicpu.op_const_ref(A_MOV, S_W, 0, tmpref));
                end;
              OS_S8:
                internalerror(2013052501);  { TODO }
              OS_16:
                begin
                  list.concat(taicpu.op_reg_ref(A_MOV, S_W, reg, tmpref));
                  inc(tmpref.offset, 2);
                  list.concat(taicpu.op_const_ref(A_MOV, S_W, 0, tmpref));
                end;
              OS_S16:
                internalerror(2013052502);  { TODO }
              OS_32,OS_S32:
                begin
                  list.concat(taicpu.op_reg_ref(A_MOV, S_W, reg, tmpref));
                  inc(tmpref.offset, 2);
                  list.concat(taicpu.op_reg_ref(A_MOV, S_W, GetNextReg(reg), tmpref));
                end;
              else
                internalerror(2013030313);
            end;
          else
            internalerror(2013030311);
        end;
      end;


    procedure tcg8086.a_load_ref_reg(list : TAsmList;fromsize,tosize: tcgsize;const ref : treference;reg : tregister);

        procedure add_mov(instr: Taicpu);
          begin
            { Notify the register allocator that we have written a move instruction so
              it can try to eliminate it. }
            if (instr.oper[0]^.reg<>current_procinfo.framepointer) and (instr.oper[0]^.reg<>NR_STACK_POINTER_REG) then
              add_move_instruction(instr);
            list.concat(instr);
          end;

      var
        tmpref  : treference;
      begin
        tmpref:=ref;
        make_simple_ref(list,tmpref);
        check_register_size(tosize,reg);

        if (tcgsize2size[fromsize]>32) or (tcgsize2size[tosize]>32) or (fromsize=OS_NO) or (tosize=OS_NO) then
          internalerror(2011021307);
{        if tcgsize2size[tosize]<=tcgsize2size[fromsize] then
          fromsize:=tosize;}

        case tosize of
          OS_8,OS_S8:
            if fromsize in [OS_8,OS_S8] then
              list.concat(taicpu.op_ref_reg(A_MOV, S_B, tmpref, reg))
            else
              internalerror(2013030210);
          OS_16,OS_S16:
            case fromsize of
              OS_8:
                begin
                  list.concat(taicpu.op_const_reg(A_MOV, S_W, 0, reg));
                  reg := makeregsize(list, reg, OS_8);
                  list.concat(taicpu.op_ref_reg(A_MOV, S_B, tmpref, reg));
                end;
              OS_S8:
                begin
                  getcpuregister(list, NR_AX);
                  list.concat(taicpu.op_ref_reg(A_MOV, S_B, tmpref, NR_AL));
                  list.concat(taicpu.op_none(A_CBW));
                  add_mov(taicpu.op_reg_reg(A_MOV, S_W, NR_AX, reg));
                  ungetcpuregister(list, NR_AX);
                end;
              OS_16,OS_S16:
                list.concat(taicpu.op_ref_reg(A_MOV, S_W, tmpref, reg));
              else
                internalerror(2013030212);
            end;
          OS_32,OS_S32:
            case fromsize of
              OS_8:
                begin
                  list.concat(taicpu.op_const_reg(A_MOV,S_W,0,GetNextReg(reg)));
                  list.concat(taicpu.op_const_reg(A_MOV, S_W, 0, reg));
                  reg := makeregsize(list, reg, OS_8);
                  list.concat(taicpu.op_ref_reg(A_MOV, S_B, tmpref, reg));
                end;
              OS_S8:
                begin
                  getcpuregister(list, NR_AX);
                  getcpuregister(list, NR_DX);
                  list.concat(taicpu.op_ref_reg(A_MOV, S_B, tmpref, NR_AL));
                  list.concat(taicpu.op_none(A_CBW));
                  list.concat(taicpu.op_none(A_CWD));
                  add_mov(taicpu.op_reg_reg(A_MOV, S_W, NR_AX, reg));
                  add_mov(taicpu.op_reg_reg(A_MOV, S_W, NR_DX, GetNextReg(reg)));
                  ungetcpuregister(list, NR_AX);
                  ungetcpuregister(list, NR_DX);
                end;
              OS_16:
                begin
                  list.concat(taicpu.op_ref_reg(A_MOV, S_W, tmpref, reg));
                  list.concat(taicpu.op_const_reg(A_MOV,S_W,0,GetNextReg(reg)));
                end;
              OS_S16:
                begin
                  getcpuregister(list, NR_AX);
                  getcpuregister(list, NR_DX);
                  list.concat(taicpu.op_ref_reg(A_MOV, S_W, tmpref, NR_AX));
                  list.concat(taicpu.op_none(A_CWD));
                  add_mov(taicpu.op_reg_reg(A_MOV, S_W, NR_AX, reg));
                  add_mov(taicpu.op_reg_reg(A_MOV, S_W, NR_DX, GetNextReg(reg)));
                  ungetcpuregister(list, NR_AX);
                  ungetcpuregister(list, NR_DX);
                end;
              OS_32,OS_S32:
                begin
                  list.concat(taicpu.op_ref_reg(A_MOV, S_W, tmpref, reg));
                  inc(tmpref.offset, 2);
                  list.concat(taicpu.op_ref_reg(A_MOV, S_W, tmpref, GetNextReg(reg)));
                end;
              else
                internalerror(2013030213);
            end;
          else
            internalerror(2013030211);
        end;
      end;


    procedure tcg8086.a_load_reg_reg(list : TAsmList;fromsize,tosize: tcgsize;reg1,reg2 : tregister);

        procedure add_mov(instr: Taicpu);
          begin
            { Notify the register allocator that we have written a move instruction so
              it can try to eliminate it. }
            if (instr.oper[0]^.reg<>current_procinfo.framepointer) and (instr.oper[0]^.reg<>NR_STACK_POINTER_REG) then
              add_move_instruction(instr);
            list.concat(instr);
          end;

      begin
        check_register_size(fromsize,reg1);
        check_register_size(tosize,reg2);

        if tcgsize2size[fromsize]>tcgsize2size[tosize] then
          begin
            if tosize in [OS_32, OS_S32] then
              internalerror(2013031801);
            reg1:=makeregsize(list,reg1,tosize);
            fromsize:=tosize;
          end;

        if (reg1<>reg2) then
          begin
            case tosize of
              OS_8,OS_S8:
                if fromsize in [OS_8,OS_S8] then
                  add_mov(taicpu.op_reg_reg(A_MOV, S_B, reg1, reg2))
                else
                  internalerror(2013030210);
              OS_16,OS_S16:
                case fromsize of
                  OS_8:
                    begin
                      reg2 := makeregsize(list, reg2, OS_8);
                      add_mov(taicpu.op_reg_reg(A_MOV, S_B, reg1, reg2));
                      setsubreg(reg2,R_SUBH);
                      list.concat(taicpu.op_const_reg(A_MOV, S_B, 0, reg2));
                    end;
                  OS_S8:
                    begin
                      getcpuregister(list, NR_AX);
                      add_mov(taicpu.op_reg_reg(A_MOV, S_B, reg1, NR_AL));
                      list.concat(taicpu.op_none(A_CBW));
                      add_mov(taicpu.op_reg_reg(A_MOV, S_W, NR_AX, reg2));
                      ungetcpuregister(list, NR_AX);
                    end;
                  OS_16,OS_S16:
                    add_mov(taicpu.op_reg_reg(A_MOV, S_W, reg1, reg2));
                  else
                    internalerror(2013030212);
                end;
              OS_32,OS_S32:
                case fromsize of
                  OS_8:
                    begin
                      list.concat(taicpu.op_const_reg(A_MOV, S_W, 0, GetNextReg(reg2)));
                      reg2 := makeregsize(list, reg2, OS_8);
                      add_mov(taicpu.op_reg_reg(A_MOV, S_B, reg1, reg2));
                      setsubreg(reg2,R_SUBH);
                      list.concat(taicpu.op_const_reg(A_MOV, S_B, 0, reg2));
                    end;
                  OS_S8:
                    begin
                      getcpuregister(list, NR_AX);
                      add_mov(taicpu.op_reg_reg(A_MOV, S_B, reg1, NR_AL));
                      getcpuregister(list, NR_DX);
                      list.concat(taicpu.op_none(A_CBW));
                      list.concat(taicpu.op_none(A_CWD));
                      add_mov(taicpu.op_reg_reg(A_MOV, S_W, NR_AX, reg2));
                      ungetcpuregister(list, NR_AX);
                      add_mov(taicpu.op_reg_reg(A_MOV, S_W, NR_DX, GetNextReg(reg2)));
                      ungetcpuregister(list, NR_DX);
                    end;
                  OS_16:
                    begin
                      add_mov(taicpu.op_reg_reg(A_MOV, S_W, reg1, reg2));
                      list.concat(taicpu.op_const_reg(A_MOV,S_W,0,GetNextReg(reg2)));
                    end;
                  OS_S16:
                    begin
                      getcpuregister(list, NR_AX);
                      add_mov(taicpu.op_reg_reg(A_MOV, S_W, reg1, NR_AX));
                      getcpuregister(list, NR_DX);
                      list.concat(taicpu.op_none(A_CWD));
                      add_mov(taicpu.op_reg_reg(A_MOV, S_W, NR_AX, reg2));
                      ungetcpuregister(list, NR_AX);
                      add_mov(taicpu.op_reg_reg(A_MOV, S_W, NR_DX, GetNextReg(reg2)));
                      ungetcpuregister(list, NR_DX);
                    end;
                  OS_32,OS_S32:
                    begin
                      add_mov(taicpu.op_reg_reg(A_MOV, S_W, reg1, reg2));
                      add_mov(taicpu.op_reg_reg(A_MOV, S_W, GetNextReg(reg1), GetNextReg(reg2)));
                    end;
                  else
                    internalerror(2013030213);
                end;
              else
                internalerror(2013030211);
            end;
          end;
      end;


    procedure tcg8086.g_flags2reg(list: TAsmList; size: TCgSize; const f: tresflags; reg: TRegister);
      var
        ai : taicpu;
        hreg, hreg16 : tregister;
        hl_skip: TAsmLabel;
        invf: TResFlags;
      begin
        hreg:=makeregsize(list,reg,OS_8);

        invf := f;
        inverse_flags(invf);

        list.concat(Taicpu.op_const_reg(A_MOV, S_B, 0, hreg));

        current_asmdata.getjumplabel(hl_skip);
        ai:=Taicpu.Op_Sym(A_Jcc,S_NO,hl_skip);
        ai.SetCondition(flags_to_cond(invf));
        ai.is_jmp:=true;
        list.concat(ai);

        { 16-bit INC is shorter than 8-bit }
        hreg16:=makeregsize(list,hreg,OS_16);
        list.concat(Taicpu.op_reg(A_INC, S_W, hreg16));

        a_label(list,hl_skip);

        if reg<>hreg then
          a_load_reg_reg(list,OS_8,size,hreg,reg);
      end;


    procedure tcg8086.g_flags2ref(list: TAsmList; size: TCgSize; const f: tresflags; const ref: TReference);
      var
        tmpreg : tregister;
      begin
        tmpreg:=getintregister(list,size);
        g_flags2reg(list,size,f,tmpreg);
        a_load_reg_ref(list,size,size,tmpreg,ref);
      end;


    procedure tcg8086.g_proc_exit(list : TAsmList;parasize:longint;nostackframe:boolean);
      var
        stacksize : longint;
        ret_instr: TAsmOp;
      begin
        if po_far in current_procinfo.procdef.procoptions then
          ret_instr:=A_RETF
        else
          ret_instr:=A_RET;
        { MMX needs to call EMMS }
        if assigned(rg[R_MMXREGISTER]) and
           (rg[R_MMXREGISTER].uses_registers) then
          list.concat(Taicpu.op_none(A_EMMS,S_NO));

        { remove stackframe }
        if not nostackframe then
          begin
            if (current_procinfo.framepointer=NR_STACK_POINTER_REG) then
              begin
                stacksize:=current_procinfo.calc_stackframe_size;
                if (target_info.stackalign>4) and
                   ((stacksize <> 0) or
                    (pi_do_call in current_procinfo.flags) or
                    { can't detect if a call in this case -> use nostackframe }
                    { if you (think you) know what you are doing              }
                    (po_assembler in current_procinfo.procdef.procoptions)) then
                  stacksize := align(stacksize+sizeof(aint),target_info.stackalign) - sizeof(aint);
                if (stacksize<>0) then
                  cg.a_op_const_reg(list,OP_ADD,OS_ADDR,stacksize,current_procinfo.framepointer);
              end
            else
              begin
                if current_settings.cputype < cpu_186 then
                  begin
                    list.concat(Taicpu.op_reg_reg(A_MOV, S_W, NR_BP, NR_SP));
                    list.concat(Taicpu.op_reg(A_POP, S_W, NR_BP));
                  end
                else
                  list.concat(Taicpu.op_none(A_LEAVE,S_NO));
              end;
            list.concat(tai_regalloc.dealloc(current_procinfo.framepointer,nil));
          end;

        { return from interrupt }
        if po_interrupt in current_procinfo.procdef.procoptions then
          begin
            list.concat(Taicpu.Op_reg(A_POP,S_W,NR_ES));
            list.concat(Taicpu.Op_reg(A_POP,S_W,NR_DS));
            list.concat(Taicpu.Op_reg(A_POP,S_W,NR_DI));
            list.concat(Taicpu.Op_reg(A_POP,S_W,NR_SI));
            list.concat(Taicpu.Op_reg(A_POP,S_W,NR_DX));
            list.concat(Taicpu.Op_reg(A_POP,S_W,NR_CX));
            list.concat(Taicpu.Op_reg(A_POP,S_W,NR_BX));
            list.concat(Taicpu.Op_reg(A_POP,S_W,NR_AX));
            list.concat(Taicpu.Op_none(A_IRET,S_NO));
          end
        { Routines with the poclearstack flag set use only a ret }
        else if (current_procinfo.procdef.proccalloption in clearstack_pocalls) and
                (not paramanager.use_fixed_stack)  then
         begin
           { complex return values are removed from stack in C code PM }
           { but not on win32 }
           { and not for safecall with hidden exceptions, because the result }
           { wich contains the exception is passed in EAX }
           if (target_info.system <> system_i386_win32) and
              not ((current_procinfo.procdef.proccalloption = pocall_safecall) and
               (tf_safecall_exceptions in target_info.flags)) and
              paramanager.ret_in_param(current_procinfo.procdef.returndef,
                                       current_procinfo.procdef) then
             list.concat(Taicpu.Op_const(ret_instr,S_W,sizeof(aint)))
           else
             list.concat(Taicpu.Op_none(ret_instr,S_NO));
         end
        { ... also routines with parasize=0 }
        else if (parasize=0) then
         list.concat(Taicpu.Op_none(ret_instr,S_NO))
        else
         begin
           { parameters are limited to 65535 bytes because ret allows only imm16 }
           if (parasize>65535) then
             CGMessage(cg_e_parasize_too_big);
           list.concat(Taicpu.Op_const(ret_instr,S_W,parasize));
         end;
      end;


    procedure tcg8086.g_copyvaluepara_openarray(list : TAsmList;const ref:treference;const lenloc:tlocation;elesize:tcgint;destreg:tregister);
      var
        power,len  : longint;
        opsize : topsize;
{$ifndef __NOWINPECOFF__}
        again,ok : tasmlabel;
{$endif}
      begin
        { get stack space }
        getcpuregister(list,NR_DI);
        a_load_loc_reg(list,OS_INT,lenloc,NR_DI);
        list.concat(Taicpu.op_reg(A_INC,S_W,NR_DI));
        { Now DI contains (high+1). Copy it to CX for later use. }
        getcpuregister(list,NR_CX);
        list.concat(Taicpu.op_reg_reg(A_MOV,S_W,NR_DI,NR_CX));
        if (elesize<>1) then
         begin
           if ispowerof2(elesize, power) then
             list.concat(Taicpu.op_const_reg(A_SHL,S_W,power,NR_DI))
           else
             list.concat(Taicpu.op_const_reg(A_IMUL,S_W,elesize,NR_DI));
         end;
{$ifndef __NOWINPECOFF__}
        { windows guards only a few pages for stack growing, }
        { so we have to access every page first              }
        if target_info.system=system_i386_win32 then
          begin
             current_asmdata.getjumplabel(again);
             current_asmdata.getjumplabel(ok);
             a_label(list,again);
             list.concat(Taicpu.op_const_reg(A_CMP,S_L,winstackpagesize,NR_EDI));
             a_jmp_cond(list,OC_B,ok);
             list.concat(Taicpu.op_const_reg(A_SUB,S_L,winstackpagesize-4,NR_ESP));
             list.concat(Taicpu.op_reg(A_PUSH,S_L,NR_EDI));
             list.concat(Taicpu.op_const_reg(A_SUB,S_L,winstackpagesize,NR_EDI));
             a_jmp_always(list,again);

             a_label(list,ok);
          end;
{$endif __NOWINPECOFF__}
        { If we were probing pages, EDI=(size mod pagesize) and ESP is decremented
          by (size div pagesize)*pagesize, otherwise EDI=size.
          Either way, subtracting EDI from ESP will set ESP to desired final value. }
        list.concat(Taicpu.op_reg_reg(A_SUB,S_W,NR_DI,NR_SP));
        { align stack on 2 bytes }
        list.concat(Taicpu.op_const_reg(A_AND,S_W,aint($fffe),NR_SP));
        { load destination, don't use a_load_reg_reg, that will add a move instruction
          that can confuse the reg allocator }
        list.concat(Taicpu.Op_reg_reg(A_MOV,S_W,NR_SP,NR_DI));

{$ifdef volatile_es}
        list.concat(taicpu.op_reg(A_PUSH,S_W,NR_DS));
        list.concat(taicpu.op_reg(A_POP,S_W,NR_ES));
{$endif volatile_es}

        { Allocate SI and load it with source }
        getcpuregister(list,NR_SI);
        a_loadaddr_ref_reg(list,ref,NR_SI);

        { calculate size }
        len:=elesize;
        opsize:=S_B;
{        if (len and 3)=0 then
         begin
           opsize:=S_L;
           len:=len shr 2;
         end
        else}
         if (len and 1)=0 then
          begin
            opsize:=S_W;
            len:=len shr 1;
          end;

        if len>1 then
          begin
            if ispowerof2(len, power) then
              list.concat(Taicpu.op_const_reg(A_SHL,S_W,power,NR_CX))
            else
              list.concat(Taicpu.op_const_reg(A_IMUL,S_W,len,NR_CX));
          end;
        list.concat(Taicpu.op_none(A_REP,S_NO));
        case opsize of
          S_B : list.concat(Taicpu.Op_none(A_MOVSB,S_NO));
          S_W : list.concat(Taicpu.Op_none(A_MOVSW,S_NO));
//          S_L : list.concat(Taicpu.Op_none(A_MOVSD,S_NO));
        end;
        ungetcpuregister(list,NR_DI);
        ungetcpuregister(list,NR_CX);
        ungetcpuregister(list,NR_SI);

        { patch the new address, but don't use a_load_reg_reg, that will add a move instruction
          that can confuse the reg allocator }
        list.concat(Taicpu.Op_reg_reg(A_MOV,S_W,NR_SP,destreg));
      end;


    procedure tcg8086.g_releasevaluepara_openarray(list : TAsmList;const l:tlocation);
      begin
        { Nothing to release }
      end;


    procedure tcg8086.g_exception_reason_save(list : TAsmList; const href : treference);
      begin
        if not paramanager.use_fixed_stack then
          list.concat(Taicpu.op_reg(A_PUSH,tcgsize2opsize[OS_INT],NR_FUNCTION_RESULT_REG))
        else
         inherited g_exception_reason_save(list,href);
      end;


    procedure tcg8086.g_exception_reason_save_const(list : TAsmList;const href : treference; a: tcgint);
      begin
        if not paramanager.use_fixed_stack then
          push_const(list,OS_INT,a)
        else
          inherited g_exception_reason_save_const(list,href,a);
      end;


    procedure tcg8086.g_exception_reason_load(list : TAsmList; const href : treference);
      begin
        if not paramanager.use_fixed_stack then
          begin
            cg.a_reg_alloc(list,NR_FUNCTION_RESULT_REG);
            list.concat(Taicpu.op_reg(A_POP,tcgsize2opsize[OS_INT],NR_FUNCTION_RESULT_REG))
          end
        else
          inherited g_exception_reason_load(list,href);
      end;


    procedure tcg8086.get_32bit_ops(op: TOpCG; out op1, op2: TAsmOp);
      begin
        case op of
          OP_ADD :
            begin
              op1:=A_ADD;
              op2:=A_ADC;
            end;
          OP_SUB :
            begin
              op1:=A_SUB;
              op2:=A_SBB;
            end;
          OP_XOR :
            begin
              op1:=A_XOR;
              op2:=A_XOR;
            end;
          OP_OR :
            begin
              op1:=A_OR;
              op2:=A_OR;
            end;
          OP_AND :
            begin
              op1:=A_AND;
              op2:=A_AND;
            end;
          else
            internalerror(200203241);
        end;
      end;


    procedure tcg8086.g_adjust_self_value(list:TAsmList;procdef: tprocdef;ioffset: tcgint);
      var
        hsym : tsym;
        href : treference;
        paraloc : Pcgparalocation;
      begin
        { calculate the parameter info for the procdef }
        procdef.init_paraloc_info(callerside);
        hsym:=tsym(procdef.parast.Find('self'));
        if not(assigned(hsym) and
               (hsym.typ=paravarsym)) then
          internalerror(200305251);
        paraloc:=tparavarsym(hsym).paraloc[callerside].location;
        while paraloc<>nil do
          with paraloc^ do
            begin
              case loc of
                LOC_REGISTER:
                  a_op_const_reg(list,OP_SUB,size,ioffset,register);
                LOC_REFERENCE:
                  begin
                    { offset in the wrapper needs to be adjusted for the stored
                      return address }
                    if (reference.index<>NR_BP) and (reference.index<>NR_BX) and (reference.index<>NR_DI)
                      and (reference.index<>NR_SI) then
                      begin
                        list.concat(taicpu.op_reg(A_PUSH,S_W,NR_DI));
                        list.concat(taicpu.op_reg_reg(A_MOV,S_W,reference.index,NR_DI));

                        if reference.index=NR_SP then
                          reference_reset_base(href,NR_DI,reference.offset+sizeof(pint)+2,sizeof(pint))
                        else
                          reference_reset_base(href,NR_DI,reference.offset+sizeof(pint),sizeof(pint));
                        a_op_const_ref(list,OP_SUB,size,ioffset,href);
                        list.concat(taicpu.op_reg(A_POP,S_W,NR_DI));
                      end
                    else
                      begin
                        reference_reset_base(href,reference.index,reference.offset+sizeof(pint),sizeof(pint));
                        a_op_const_ref(list,OP_SUB,size,ioffset,href);
                      end;
                  end
                else
                  internalerror(200309189);
              end;
              paraloc:=next;
            end;
      end;


    procedure tcg8086.g_intf_wrapper(list: TAsmList; procdef: tprocdef; const labelname: string; ioffset: longint);
      {
      possible calling conventions:
                    default stdcall cdecl pascal register
      default(0):      OK     OK    OK     OK       OK
      virtual(1):      OK     OK    OK     OK       OK(2)

      (0):
          set self parameter to correct value
          jmp mangledname

      (1): The wrapper code use %eax to reach the virtual method address
           set self to correct value
           move self,%bx
           mov  0(%bx),%bx ; load vmt
           jmp  vmtoffs(%bx) ; method offs

      (2): Virtual use values pushed on stack to reach the method address
           so the following code be generated:
           set self to correct value
           push %bx ; allocate space for function address
           push %bx
           push %di
           mov  self,%bx
           mov  0(%bx),%bx ; load vmt
           mov  vmtoffs(%bx),bx ; method offs
           mov  %sp,%di
           mov  %bx,4(%di)
           pop  %di
           pop  %bx
           ret  0; jmp the address

      }

      procedure getselftobx(offs: longint);
        var
          href : treference;
          selfoffsetfromsp : longint;
        begin
          { "mov offset(%sp),%bx" }
          if (procdef.proccalloption<>pocall_register) then
            begin
              list.concat(taicpu.op_reg(A_PUSH,S_W,NR_DI));
              { framepointer is pushed for nested procs }
              if procdef.parast.symtablelevel>normal_function_level then
                selfoffsetfromsp:=2*sizeof(aint)
              else
                selfoffsetfromsp:=sizeof(aint);
              list.concat(taicpu.op_reg_reg(A_mov,S_W,NR_SP,NR_DI));
              reference_reset_base(href,NR_DI,selfoffsetfromsp+offs+2,2);
              cg.a_load_ref_reg(list,OS_ADDR,OS_ADDR,href,NR_BX);
              list.concat(taicpu.op_reg(A_POP,S_W,NR_DI));
            end
          else
            cg.a_load_reg_reg(list,OS_ADDR,OS_ADDR,NR_BX,NR_BX);
        end;


      procedure loadvmttobx;
        var
          href : treference;
        begin
          { mov  0(%bx),%bx ; load vmt}
          reference_reset_base(href,NR_BX,0,2);
          cg.a_load_ref_reg(list,OS_ADDR,OS_ADDR,href,NR_BX);
        end;


      procedure loadmethodoffstobx;
        var
          href : treference;
        begin
          if (procdef.extnumber=$ffff) then
            Internalerror(200006139);
          { mov vmtoffs(%bx),%bx ; method offs }
          reference_reset_base(href,NR_BX,tobjectdef(procdef.struct).vmtmethodoffset(procdef.extnumber),2);
          cg.a_load_ref_reg(list,OS_ADDR,OS_ADDR,href,NR_BX);
        end;


      var
        lab : tasmsymbol;
        make_global : boolean;
        href : treference;
      begin
        if not(procdef.proctypeoption in [potype_function,potype_procedure]) then
          Internalerror(200006137);
        if not assigned(procdef.struct) or
           (procdef.procoptions*[po_classmethod, po_staticmethod,
             po_methodpointer, po_interrupt, po_iocheck]<>[]) then
          Internalerror(200006138);
        if procdef.owner.symtabletype<>ObjectSymtable then
          Internalerror(200109191);

        make_global:=false;
        if (not current_module.is_unit) or
           create_smartlink or
           (procdef.owner.defowner.owner.symtabletype=globalsymtable) then
          make_global:=true;

        if make_global then
          List.concat(Tai_symbol.Createname_global(labelname,AT_FUNCTION,0))
        else
          List.concat(Tai_symbol.Createname(labelname,AT_FUNCTION,0));

        { set param1 interface to self  }
        g_adjust_self_value(list,procdef,ioffset);

        if (po_virtualmethod in procdef.procoptions) and
            not is_objectpascal_helper(procdef.struct) then
          begin
            { case 1 & case 2 }
            list.concat(taicpu.op_reg(A_PUSH,S_W,NR_BX)); { allocate space for address}
            list.concat(taicpu.op_reg(A_PUSH,S_W,NR_BX));
            list.concat(taicpu.op_reg(A_PUSH,S_W,NR_DI));
            getselftobx(8);
            loadvmttobx;
            loadmethodoffstobx;
            { set target address
              "mov %bx,4(%sp)" }
            reference_reset_base(href,NR_DI,4,2);
            list.concat(taicpu.op_reg_reg(A_MOV,S_W,NR_SP,NR_DI));
            list.concat(taicpu.op_reg_ref(A_MOV,S_W,NR_BX,href));

            { load ax? }
            if procdef.proccalloption=pocall_register then
              list.concat(taicpu.op_reg_reg(A_MOV,S_W,NR_BX,NR_AX));

            { restore register
              pop  %di,bx }
            list.concat(taicpu.op_reg(A_POP,S_W,NR_DI));
            list.concat(taicpu.op_reg(A_POP,S_W,NR_BX));

            { ret  ; jump to the address }
            list.concat(taicpu.op_none(A_RET,S_W));
          end
        { case 0 }
        else
          begin
            lab:=current_asmdata.RefAsmSymbol(procdef.mangledname);
            list.concat(taicpu.op_sym(A_JMP,S_NO,lab))
          end;

        List.concat(Tai_symbol_end.Createname(labelname));
      end;


{ ************* 64bit operations ************ }

    procedure tcg64f8086.get_64bit_ops(op:TOpCG;var op1,op2:TAsmOp);
      begin
        case op of
          OP_ADD :
            begin
              op1:=A_ADD;
              op2:=A_ADC;
            end;
          OP_SUB :
            begin
              op1:=A_SUB;
              op2:=A_SBB;
            end;
          OP_XOR :
            begin
              op1:=A_XOR;
              op2:=A_XOR;
            end;
          OP_OR :
            begin
              op1:=A_OR;
              op2:=A_OR;
            end;
          OP_AND :
            begin
              op1:=A_AND;
              op2:=A_AND;
            end;
          else
            internalerror(200203241);
        end;
      end;


(*    procedure tcg64f8086.a_op64_ref_reg(list : TAsmList;op:TOpCG;size : tcgsize;const ref : treference;reg : tregister64);
      var
        op1,op2 : TAsmOp;
        tempref : treference;
      begin
        if not(op in [OP_NEG,OP_NOT]) then
          begin
            get_64bit_ops(op,op1,op2);
            tempref:=ref;
            tcgx86(cg).make_simple_ref(list,tempref);
            list.concat(taicpu.op_ref_reg(op1,S_L,tempref,reg.reglo));
            inc(tempref.offset,4);
            list.concat(taicpu.op_ref_reg(op2,S_L,tempref,reg.reghi));
          end
        else
          begin
            a_load64_ref_reg(list,ref,reg);
            a_op64_reg_reg(list,op,size,reg,reg);
          end;
      end;*)


    procedure tcg64f8086.a_op64_reg_reg(list : TAsmList;op:TOpCG;size : tcgsize;regsrc,regdst : tregister64);
      var
        op1,op2 : TAsmOp;
      begin
        case op of
          OP_NEG :
            begin
              if (regsrc.reglo<>regdst.reglo) then
                a_load64_reg_reg(list,regsrc,regdst);
              cg.a_op_reg_reg(list,OP_NOT,OS_32,regdst.reghi,regdst.reghi);
              cg.a_op_reg_reg(list,OP_NEG,OS_32,regdst.reglo,regdst.reglo);
              { there's no OP_SBB, so do it directly }
              list.concat(taicpu.op_const_reg(A_SBB,S_W,-1,regdst.reghi));
              list.concat(taicpu.op_const_reg(A_SBB,S_W,-1,GetNextReg(regdst.reghi)));
              exit;
            end;
          OP_NOT :
            begin
              if (regsrc.reglo<>regdst.reglo) then
                a_load64_reg_reg(list,regsrc,regdst);
              cg.a_op_reg_reg(list,OP_NOT,OS_32,regdst.reglo,regdst.reglo);
              cg.a_op_reg_reg(list,OP_NOT,OS_32,regdst.reghi,regdst.reghi);
              exit;
            end;
        end;
        get_64bit_ops(op,op1,op2);
        list.concat(taicpu.op_reg_reg(op1,S_W,regsrc.reglo,regdst.reglo));
        list.concat(taicpu.op_reg_reg(op2,S_W,GetNextReg(regsrc.reglo),GetNextReg(regdst.reglo)));
        list.concat(taicpu.op_reg_reg(op2,S_W,regsrc.reghi,regdst.reghi));
        list.concat(taicpu.op_reg_reg(op2,S_W,GetNextReg(regsrc.reghi),GetNextReg(regdst.reghi)));
      end;


    procedure tcg64f8086.a_op64_const_reg(list : TAsmList;op:TOpCG;size : tcgsize;value : int64;reg : tregister64);
      var
        op1,op2 : TAsmOp;
      begin
        case op of
          OP_AND,OP_OR,OP_XOR:
            begin
              cg.a_op_const_reg(list,op,OS_32,tcgint(lo(value)),reg.reglo);
              cg.a_op_const_reg(list,op,OS_32,tcgint(hi(value)),reg.reghi);
            end;
          OP_ADD, OP_SUB:
            begin
              // can't use a_op_const_ref because this may use dec/inc
              get_64bit_ops(op,op1,op2);
              list.concat(taicpu.op_const_reg(op1,S_W,aint(value and $ffff),reg.reglo));
              list.concat(taicpu.op_const_reg(op2,S_W,aint((value shr 16) and $ffff),GetNextReg(reg.reglo)));
              list.concat(taicpu.op_const_reg(op2,S_W,aint((value shr 32) and $ffff),reg.reghi));
              list.concat(taicpu.op_const_reg(op2,S_W,aint((value shr 48) and $ffff),GetNextReg(reg.reghi)));
            end;
          else
            internalerror(200204021);
        end;
      end;


(*    procedure tcg64f8086.a_op64_const_ref(list : TAsmList;op:TOpCG;size : tcgsize;value : int64;const ref : treference);
      var
        op1,op2 : TAsmOp;
        tempref : treference;
      begin
        tempref:=ref;
        tcgx86(cg).make_simple_ref(list,tempref);
        case op of
          OP_AND,OP_OR,OP_XOR:
            begin
              cg.a_op_const_ref(list,op,OS_32,tcgint(lo(value)),tempref);
              inc(tempref.offset,4);
              cg.a_op_const_ref(list,op,OS_32,tcgint(hi(value)),tempref);
            end;
          OP_ADD, OP_SUB:
            begin
              get_64bit_ops(op,op1,op2);
              // can't use a_op_const_ref because this may use dec/inc
              list.concat(taicpu.op_const_ref(op1,S_L,aint(lo(value)),tempref));
              inc(tempref.offset,4);
              list.concat(taicpu.op_const_ref(op2,S_L,aint(hi(value)),tempref));
            end;
          else
            internalerror(200204022);
        end;
      end;*)

    procedure create_codegen;
      begin
        cg := tcg8086.create;
        cg64 := tcg64f8086.create;
      end;

end.
