{
    Copyright (c) 1998-2002 by Florian Klaempfl

    Generate SPARC assembler for type converting nodes

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

 ****************************************************************************}
unit ncpucnv;

{$i fpcdefs.inc}

interface

    uses
      node,ncnv,ncgcnv,defcmp;

    type
       tsparctypeconvnode = class(TCgTypeConvNode)
         protected
         { procedure second_int_to_int;override; }
         { procedure second_string_to_string;override; }
         { procedure second_cstring_to_pchar;override; }
         { procedure second_string_to_chararray;override; }
         { procedure second_array_to_pointer;override; }
          function first_int_to_real: tnode; override;
         { procedure second_pointer_to_array;override; }
         { procedure second_chararray_to_string;override; }
         { procedure second_char_to_string;override; }
          procedure second_int_to_real;override;
          procedure second_real_to_real;override;
         { procedure second_cord_to_pointer;override; }
         { procedure second_proc_to_procvar;override; }
         { procedure second_bool_to_int;override; }
          procedure second_int_to_bool;override;
         { procedure second_load_smallset;override;  }
         { procedure second_ansistring_to_pchar;override; }
         { procedure second_pchar_to_string;override; }
         { procedure second_class_to_intf;override; }
         { procedure second_char_to_char;override; }
       end;

implementation

   uses
      verbose,globals,systems,
      symconst,symdef,aasmbase,aasmtai,
      defutil,
      cgbase,cgutils,pass_1,pass_2,
      ncon,ncal,
      ncgutil,
      cpubase,aasmcpu,
      tgobj,cgobj;


{*****************************************************************************
                             FirstTypeConv
*****************************************************************************}

    function tsparctypeconvnode.first_int_to_real: tnode;
      var
        fname: string[19];
      begin
        { converting a 64bit integer to a float requires a helper }
        if is_64bitint(left.resulttype.def) or
          is_currency(left.resulttype.def) then
          begin
            { hack to avoid double division by 10000, as it's
              already done by resulttypepass.resulttype_int_to_real }
            if is_currency(left.resulttype.def) then
              left.resulttype := s64inttype;
            if is_signed(left.resulttype.def) then
              fname := 'fpc_int64_to_double'
            else
              fname := 'fpc_qword_to_double';
            result := ccallnode.createintern(fname,ccallparanode.create(
              left,nil));
            left:=nil;
            firstpass(result);
            exit;
          end
        else
          { other integers are supposed to be 32 bit }
          begin
            if is_signed(left.resulttype.def) then
              inserttypeconv(left,s32inttype)
            else
              inserttypeconv(left,u32inttype);
            firstpass(left);
          end;
        result := nil;
        if registersfpu<1 then
          registersfpu:=1;
        expectloc:=LOC_FPUREGISTER;
      end;


{*****************************************************************************
                             SecondTypeConv
*****************************************************************************}

    procedure tsparctypeconvnode.second_int_to_real;

      procedure loadsigned;
        begin
          location_force_mem(exprasmlist,left.location);
          { Load memory in fpu register }
          cg.a_loadfpu_ref_reg(exprasmlist,OS_F32,left.location.reference,location.register);
          tg.ungetiftemp(exprasmlist,left.location.reference);
          { Convert value in fpu register from integer to float }
          case tfloatdef(resulttype.def).typ of
            s32real:
               exprasmlist.concat(taicpu.op_reg_reg(A_FiTOs,location.register,location.register));
            s64real:
              exprasmlist.concat(taicpu.op_reg_reg(A_FiTOd,location.register,location.register));
            s128real:
              exprasmlist.concat(taicpu.op_reg_reg(A_FiTOq,location.register,location.register));
            else
              internalerror(200408011);
          end;
        end;

      var
        href : treference;
        hregister : tregister;
        l1,l2 : tasmlabel;

      begin
        location_reset(location,LOC_FPUREGISTER,def_cgsize(resulttype.def));
        if is_signed(left.resulttype.def) then
          begin
            location.register:=cg.getfpuregister(exprasmlist,location.size);
            loadsigned;
          end
        else
          begin
            objectlibrary.getdatalabel(l1);
            objectlibrary.getjumplabel(l2);
            reference_reset_symbol(href,l1,0);
            hregister:=cg.getintregister(exprasmlist,OS_32);
            cg.a_load_loc_reg(exprasmlist,OS_32,left.location,hregister);

            { here we need always an 64 bit register }
            location.register:=cg.getfpuregister(exprasmlist,OS_F64);
            location_force_mem(exprasmlist,left.location);
            { Load memory in fpu register }
            cg.a_loadfpu_ref_reg(exprasmlist,OS_F32,left.location.reference,location.register);
            tg.ungetiftemp(exprasmlist,left.location.reference);
            exprasmlist.concat(taicpu.op_reg_reg(A_FiTOd,location.register,location.register));

            exprasmList.concat(Taicpu.op_reg_reg(A_CMP,hregister,NR_G0));
            cg.a_jmp_flags(exprasmlist,F_GE,l2);

            case tfloatdef(resulttype.def).typ of
               { converting dword to s64real first and cut off at the end avoids precision loss }
               s32real,
               s64real:
                 begin
                   hregister:=cg.getfpuregister(exprasmlist,OS_F64);
                   asmlist[al_typedconsts].concat(tai_align.create(const_align(8)));
                   asmlist[al_typedconsts].concat(Tai_label.Create(l1));
                   { I got this constant from a test program (FK) }
                   asmlist[al_typedconsts].concat(Tai_const.Create_32bit($41f00000));
                   asmlist[al_typedconsts].concat(Tai_const.Create_32bit(0));

                   cg.a_loadfpu_ref_reg(exprasmlist,OS_F64,href,hregister);
                   exprasmlist.concat(taicpu.op_reg_reg_reg(A_FADDD,location.register,hregister,location.register));
                   cg.a_label(exprasmlist,l2);

                   { cut off if we should convert to single }
                   if tfloatdef(resulttype.def).typ=s32real then
                     begin
                       hregister:=location.register;
                       location.register:=cg.getfpuregister(exprasmlist,location.size);
                       exprasmlist.concat(taicpu.op_reg_reg(A_FDTOS,hregister,location.register));
                     end;
                 end;
               else
                 internalerror(200410031);
            end;
          end;
       end;


    procedure tsparctypeconvnode.second_real_to_real;
      const
        conv_op : array[tfloattype,tfloattype] of tasmop = (
          {    from:   s32     s64     s80     c64     cur    f128 }
          { s32 }  ( A_FMOVS,A_FDTOS,A_NONE, A_NONE, A_NONE, A_NONE ),
          { s64 }  ( A_FSTOD,A_FMOVD,A_NONE, A_NONE, A_NONE, A_NONE ),
          { s80 }  ( A_NONE, A_NONE, A_NONE, A_NONE, A_NONE, A_NONE ),
          { c64 }  ( A_NONE, A_NONE, A_NONE, A_NONE, A_NONE, A_NONE ),
          { cur }  ( A_NONE, A_NONE, A_NONE, A_NONE, A_NONE, A_NONE ),
          { f128 } ( A_NONE, A_NONE, A_NONE, A_NONE, A_NONE, A_NONE )
        );
      var
        op : tasmop;
      begin
        location_reset(location,LOC_FPUREGISTER,def_cgsize(resulttype.def));
        location_force_fpureg(exprasmlist,left.location,false);
        { Convert value in fpu register from integer to float }
        op:=conv_op[tfloatdef(resulttype.def).typ,tfloatdef(left.resulttype.def).typ];
        if op=A_NONE then
          internalerror(200401121);
        location.register:=cg.getfpuregister(exprasmlist,location.size);
        exprasmlist.concat(taicpu.op_reg_reg(op,left.location.register,location.register));
      end;


    procedure tsparctypeconvnode.second_int_to_bool;
      var
        hreg1,hreg2 : tregister;
        resflags : tresflags;
        opsize   : tcgsize;
        hlabel,oldtruelabel,oldfalselabel : tasmlabel;
      begin
        oldtruelabel:=truelabel;
        oldfalselabel:=falselabel;
        objectlibrary.getjumplabel(truelabel);
        objectlibrary.getjumplabel(falselabel);
        secondpass(left);
        if codegenerror then
          exit;

        { byte(boolean) or word(wordbool) or longint(longbool) must }
        { be accepted for var parameters                            }
        if (nf_explicit in flags)and
           (left.resulttype.def.size=resulttype.def.size)and
           (left.location.loc in [LOC_REFERENCE,LOC_CREFERENCE,LOC_CREGISTER]) then
          begin
            location_copy(location,left.location);
            truelabel:=oldtruelabel;
            falselabel:=oldfalselabel;
            exit;
          end;
        location_reset(location,LOC_REGISTER,def_cgsize(resulttype.def));
        opsize:=def_cgsize(left.resulttype.def);
        case left.location.loc of
          LOC_CREFERENCE,LOC_REFERENCE,LOC_REGISTER,LOC_CREGISTER:
            begin
              if left.location.loc in [LOC_CREFERENCE,LOC_REFERENCE] then
                begin
                  hreg2:=cg.getintregister(exprasmlist,opsize);
                  cg.a_load_ref_reg(exprasmlist,opsize,opsize,left.location.reference,hreg2);
                end
              else
                hreg2:=left.location.register;
{$ifndef cpu64bit}
              if left.location.size in [OS_64,OS_S64] then
                begin
                  hreg1:=cg.getintregister(exprasmlist,OS_32);
                  cg.a_op_reg_reg_reg(exprasmlist,OP_OR,OS_32,hreg2,tregister(succ(longint(hreg2))),hreg1);
                  hreg2:=hreg1;
                  opsize:=OS_32;
                end;
{$endif cpu64bit}
              exprasmlist.concat(taicpu.op_reg_reg_reg(A_SUBCC,NR_G0,hreg2,NR_G0));
              hreg1:=cg.getintregister(exprasmlist,opsize);
              exprasmlist.concat(taicpu.op_reg_const_reg(A_ADDX,NR_G0,0,hreg1));
            end;
          LOC_FLAGS :
            begin
              hreg1:=cg.GetIntRegister(exprasmlist,location.size);
              resflags:=left.location.resflags;
              cg.g_flags2reg(exprasmlist,location.size,resflags,hreg1);
            end;
          LOC_JUMP :
            begin
              hreg1:=cg.getintregister(exprasmlist,OS_INT);
              objectlibrary.getjumplabel(hlabel);
              cg.a_label(exprasmlist,truelabel);
              cg.a_load_const_reg(exprasmlist,OS_INT,1,hreg1);
              cg.a_jmp_always(exprasmlist,hlabel);
              cg.a_label(exprasmlist,falselabel);
              cg.a_load_const_reg(exprasmlist,OS_INT,0,hreg1);
              cg.a_label(exprasmlist,hlabel);
            end;
          else
            internalerror(10062);
        end;
        location.register:=hreg1;

         if location.size in [OS_64, OS_S64] then
           internalerror(200408241);

        truelabel:=oldtruelabel;
        falselabel:=oldfalselabel;
      end;


begin
   ctypeconvnode:=tsparctypeconvnode;
end.
