{
    Copyright (c) 1998-2010 by Florian Klaempfl and Jonas Maebe
    Member of the Free Pascal development team

    This unit contains routines to create a pass-through high-level code
    generator. This is used by most regular code generators.

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

unit hlcgcpu;

{$i fpcdefs.inc}

interface

  uses
    globtype,
    aasmdata,
    symtype,symdef,parabase,
    cgbase,cgutils,
    hlcgobj, hlcgx86;


  type
    thlcgcpu = class(thlcgx86)
     protected
      procedure gen_loadfpu_loc_cgpara(list: TAsmList; size: tdef; const l: tlocation; const cgpara: tcgpara; locintsize: longint); override;
     public
      procedure g_copyvaluepara_openarray(list: TAsmList; const ref: treference; const lenloc: tlocation; arrdef: tarraydef; destreg: tregister); override;
      procedure g_releasevaluepara_openarray(list: TAsmList; arrdef: tarraydef; const l: tlocation); override;
      procedure g_exception_reason_save(list: TAsmList; fromsize, tosize: tdef; reg: tregister; const href: treference); override;
      procedure g_exception_reason_save_const(list: TAsmList; size: tdef; a: tcgint; const href: treference); override;
      procedure g_exception_reason_load(list: TAsmList; fromsize, tosize: tdef; const href: treference; reg: tregister); override;
      procedure g_exception_reason_discard(list: TAsmList; size: tdef; href: treference); override;
    end;

  procedure create_hlcodegen;

implementation

  uses
    verbose,
    paramgr,
    defutil,
    cpubase,aasmcpu,tgobj,cgobj,cgx86,cgcpu;

  { thlcgcpu }

  procedure thlcgcpu.gen_loadfpu_loc_cgpara(list: TAsmList; size: tdef; const l: tlocation; const cgpara: tcgpara; locintsize: longint);
    var
      locsize : tcgsize;
      tmploc : tlocation;
      href   : treference;
      stacksize   : longint;
    begin
      if not(l.size in [OS_32,OS_S32,OS_64,OS_S64,OS_128,OS_S128]) then
        locsize:=l.size
      else
        locsize:=int_float_cgsize(tcgsize2size[l.size]);
      case l.loc of
        LOC_FPUREGISTER,
        LOC_CFPUREGISTER:
          begin
            case cgpara.location^.loc of
              LOC_REFERENCE:
                begin
                  stacksize:=align(locintsize,cgpara.alignment);
                  if (not paramanager.use_fixed_stack) and
                     (cgpara.location^.reference.index=NR_STACK_POINTER_REG) then
                    begin
                      cg.g_stackpointer_alloc(list,stacksize);
                      reference_reset_base(href,voidstackpointertype,NR_STACK_POINTER_REG,0,voidstackpointertype.size);
                    end
                  else
                    reference_reset_base(href,voidstackpointertype,cgpara.location^.reference.index,cgpara.location^.reference.offset,cgpara.alignment);
                  cg.a_loadfpu_reg_ref(list,locsize,locsize,l.register,href);
                end;
              LOC_FPUREGISTER:
                begin
                  cg.a_loadfpu_reg_reg(list,locsize,cgpara.location^.size,l.register,cgpara.location^.register);
                end;
              { can happen if a record with only 1 "single field" is
                returned in a floating point register and then is directly
                passed to a regcall parameter }
              LOC_REGISTER:
                begin
                  tmploc:=l;
                  location_force_mem(list,tmploc,size);
                  case locsize of
                    OS_F32:
                      tmploc.size:=OS_32;
                    OS_F64:
                      tmploc.size:=OS_64;
                    else
                      internalerror(2010053116);
                  end;
                  cg.a_load_loc_cgpara(list,tmploc,cgpara);
                  location_freetemp(list,tmploc);
                end
              else
                internalerror(2010053003);
            end;
          end;
        LOC_MMREGISTER,
        LOC_CMMREGISTER:
          begin
            case cgpara.location^.loc of
              LOC_REFERENCE:
                begin
                  { can't use TCGSize2Size[l.size], because the size of an
                    80 bit extended parameter can be either 10 or 12 bytes }
                  stacksize:=align(locintsize,cgpara.alignment);
                  if (not paramanager.use_fixed_stack) and
                     (cgpara.location^.reference.index=NR_STACK_POINTER_REG) then
                    begin
                      cg.g_stackpointer_alloc(list,stacksize);
                      reference_reset_base(href,voidstackpointertype,NR_STACK_POINTER_REG,0,voidstackpointertype.size);
                    end
                  else
                    reference_reset_base(href,voidstackpointertype,cgpara.location^.reference.index,cgpara.location^.reference.offset,cgpara.alignment);
                  cg.a_loadmm_reg_ref(list,locsize,locsize,l.register,href,mms_movescalar);
                end;
              LOC_FPUREGISTER:
                begin
                  tmploc:=l;
                  location_force_mem(list,tmploc,size);
                  cg.a_loadfpu_ref_cgpara(list,tmploc.size,tmploc.reference,cgpara);
                  location_freetemp(list,tmploc);
                end;
              else
                internalerror(2010053004);
            end;
          end;
        LOC_REFERENCE,
        LOC_CREFERENCE :
          begin
            case cgpara.location^.loc of
              LOC_REFERENCE:
                begin
                  stacksize:=align(locintsize,cgpara.alignment);
                  if (not paramanager.use_fixed_stack) and
                     (cgpara.location^.reference.index=NR_STACK_POINTER_REG) then
                    cg.a_load_ref_cgpara(list,locsize,l.reference,cgpara)
                  else
                    begin
                      reference_reset_base(href,voidstackpointertype,cgpara.location^.reference.index,cgpara.location^.reference.offset,cgpara.alignment);
                      cg.g_concatcopy(list,l.reference,href,stacksize);
                    end;
                end;
              LOC_FPUREGISTER:
                begin
                  cg.a_loadfpu_ref_cgpara(list,locsize,l.reference,cgpara);
                end;
              else
                internalerror(2010053005);
            end;
          end;
        else
          internalerror(2002042430);
      end;
    end;


  procedure thlcgcpu.g_copyvaluepara_openarray(list: TAsmList; const ref: treference; const lenloc: tlocation; arrdef: tarraydef; destreg: tregister);
    begin
      if paramanager.use_fixed_stack then
        begin
          inherited;
          exit;
        end;
      tcg386(cg).g_copyvaluepara_openarray(list,ref,lenloc,arrdef.elesize,destreg);
    end;


  procedure thlcgcpu.g_releasevaluepara_openarray(list: TAsmList; arrdef: tarraydef; const l: tlocation);
    begin
      if paramanager.use_fixed_stack then
        begin
          inherited;
          exit;
        end;
      tcg386(cg).g_releasevaluepara_openarray(list,l);
    end;


  procedure thlcgcpu.g_exception_reason_save(list: TAsmList; fromsize, tosize: tdef; reg: tregister; const href: treference);
    begin
      if not paramanager.use_fixed_stack then
        list.concat(Taicpu.op_reg(A_PUSH,tcgsize2opsize[def_cgsize(tosize)],reg))
      else
        inherited
    end;


  procedure thlcgcpu.g_exception_reason_save_const(list: TAsmList; size: tdef; a: tcgint; const href: treference);
    begin
      if not paramanager.use_fixed_stack then
        list.concat(Taicpu.op_const(A_PUSH,tcgsize2opsize[def_cgsize(size)],a))
      else
        inherited;
    end;


  procedure thlcgcpu.g_exception_reason_load(list: TAsmList; fromsize, tosize: tdef; const href: treference; reg: tregister);
    begin
      if not paramanager.use_fixed_stack then
        list.concat(Taicpu.op_reg(A_POP,tcgsize2opsize[def_cgsize(tosize)],reg))
      else
        inherited;
    end;


  procedure thlcgcpu.g_exception_reason_discard(list: TAsmList; size: tdef; href: treference);
    begin
      if not paramanager.use_fixed_stack then
        begin
          getcpuregister(list,NR_FUNCTION_RESULT_REG);
          list.concat(Taicpu.op_reg(A_POP,tcgsize2opsize[def_cgsize(size)],NR_FUNCTION_RESULT_REG));
          ungetcpuregister(list,NR_FUNCTION_RESULT_REG);
        end;
    end;


  procedure create_hlcodegen;
    begin
      hlcg:=thlcgcpu.create;
      create_codegen;
    end;



begin
  chlcgobj:=thlcgcpu;
end.
