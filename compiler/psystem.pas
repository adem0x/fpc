{
    Copyright (c) 1998-2002 by Florian Klaempfl

    Load the system unit, create required defs for systemunit

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
unit psystem;

{$i fpcdefs.inc}

interface

    uses
      symbase;

    procedure create_intern_symbols;
    procedure create_intern_types;

    procedure load_intern_types;

    procedure registernodes;
    procedure registertais;


implementation

    uses
      globals,globtype,verbose,
      systems,
      symconst,symtype,symsym,symdef,symtable,
      aasmtai,aasmdata,aasmcpu,
      ncgutil,ncgrtti,fmodule,
      node,nbas,nflw,nset,ncon,ncnv,nld,nmem,ncal,nmat,nadd,ninl,nopt
      ;


    procedure create_intern_symbols;
      {
        all intern procedures for the system unit
      }
      begin
        systemunit.insert(tsyssym.create('Concat',in_concat_x));
        systemunit.insert(tsyssym.create('Write',in_write_x));
        systemunit.insert(tsyssym.create('WriteLn',in_writeln_x));
        systemunit.insert(tsyssym.create('Assigned',in_assigned_x));
        systemunit.insert(tsyssym.create('Read',in_read_x));
        systemunit.insert(tsyssym.create('ReadLn',in_readln_x));
        systemunit.insert(tsyssym.create('Ofs',in_ofs_x));
        systemunit.insert(tsyssym.create('SizeOf',in_sizeof_x));
        systemunit.insert(tsyssym.create('BitSizeOf',in_bitsizeof_x));
        systemunit.insert(tsyssym.create('TypeOf',in_typeof_x));
        systemunit.insert(tsyssym.create('Low',in_low_x));
        systemunit.insert(tsyssym.create('High',in_high_x));
        systemunit.insert(tsyssym.create('Slice',in_slice_x));
        systemunit.insert(tsyssym.create('Seg',in_seg_x));
        systemunit.insert(tsyssym.create('Ord',in_ord_x));
        systemunit.insert(tsyssym.create('Pred',in_pred_x));
        systemunit.insert(tsyssym.create('Succ',in_succ_x));
        systemunit.insert(tsyssym.create('Exclude',in_exclude_x_y));
        systemunit.insert(tsyssym.create('Include',in_include_x_y));
        systemunit.insert(tsyssym.create('Pack',in_pack_x_y_z));
        systemunit.insert(tsyssym.create('Unpack',in_unpack_x_y_z));
        systemunit.insert(tsyssym.create('Break',in_break));
        systemunit.insert(tsyssym.create('Exit',in_exit));
        systemunit.insert(tsyssym.create('Continue',in_continue));
        systemunit.insert(tsyssym.create('Leave',in_leave)); {macpas only}
        systemunit.insert(tsyssym.create('Cycle',in_cycle)); {macpas only}
        systemunit.insert(tsyssym.create('Dec',in_dec_x));
        systemunit.insert(tsyssym.create('Inc',in_inc_x));
        systemunit.insert(tsyssym.create('Str',in_str_x_string));
        systemunit.insert(tsyssym.create('Assert',in_assert_x_y));
        systemunit.insert(tsyssym.create('Val',in_val_x));
        systemunit.insert(tsyssym.create('Addr',in_addr_x));
        systemunit.insert(tsyssym.create('TypeInfo',in_typeinfo_x));
        systemunit.insert(tsyssym.create('SetLength',in_setlength_x));
        systemunit.insert(tsyssym.create('Copy',in_copy_x));
        systemunit.insert(tsyssym.create('Initialize',in_initialize_x));
        systemunit.insert(tsyssym.create('Finalize',in_finalize_x));
        systemunit.insert(tsyssym.create('Length',in_length_x));
        systemunit.insert(tsyssym.create('New',in_new_x));
        systemunit.insert(tsyssym.create('Dispose',in_dispose_x));
{$if defined(x86) or defined(arm)}
        systemunit.insert(tsyssym.create('Get_Frame',in_get_frame));
{$endif defined(x86) or defined(arm)}
{$ifdef SUPPORT_UNALIGNED}
        systemunit.insert(tsyssym.create('Unaligned',in_unaligned_x));
{$endif SUPPORT_UNALIGNED}
      end;


    procedure create_intern_types;
      {
        all the types inserted into the system unit
      }

        function addtype(const s:string;def:tdef):ttypesym;
        begin
          result:=ttypesym.create(s,def);
          systemunit.insert(result);
        end;

      var
        hrecst : trecordsymtable;
      begin
        symtablestack.push(systemunit);
        cundefinedtype:=tundefineddef.create;
        cformaltype:=tformaldef.create;
        voidtype:=torddef.create(uvoid,0,0);
        u8inttype:=torddef.create(u8bit,0,255);
        s8inttype:=torddef.create(s8bit,-128,127);
        u16inttype:=torddef.create(u16bit,0,65535);
        s16inttype:=torddef.create(s16bit,-32768,32767);
        u32inttype:=torddef.create(u32bit,0,high(longword));
        s32inttype:=torddef.create(s32bit,low(longint),high(longint));
        u64inttype:=torddef.create(u64bit,low(qword),TConstExprInt(high(qword)));
        s64inttype:=torddef.create(s64bit,low(int64),high(int64));
        booltype:=torddef.create(bool8bit,0,1);
        bool16type:=torddef.create(bool16bit,0,1);
        bool32type:=torddef.create(bool32bit,0,1);
        bool64type:=torddef.create(bool64bit,0,1);
        cchartype:=torddef.create(uchar,0,255);
        cwidechartype:=torddef.create(uwidechar,0,65535);
        cshortstringtype:=tstringdef.createshort(255);
        { should we give a length to the default long and ansi string definition ?? }
        clongstringtype:=tstringdef.createlong(-1);
        cansistringtype:=tstringdef.createansi(-1);
        cwidestringtype:=tstringdef.createwide(-1);
        { length=0 for shortstring is open string (needed for readln(string) }
        openshortstringtype:=tstringdef.createshort(0);
        openchararraytype:=tarraydef.create(0,-1,s32inttype);
        tarraydef(openchararraytype).elementdef:=cchartype;
{$ifdef x86}
        s32floattype:=tfloatdef.create(s32real);
        s64floattype:=tfloatdef.create(s64real);
        s80floattype:=tfloatdef.create(s80real);
        if target_info.system<>system_x86_64_win64 then
          s64currencytype:=tfloatdef.create(s64currency)
        else
          begin
            s64currencytype:=torddef.create(scurrency,low(int64),high(int64));
            pbestrealtype:=@s64floattype;
          end;
{$endif x86}
{$ifdef powerpc}
        s32floattype:=tfloatdef.create(s32real);
        s64floattype:=tfloatdef.create(s64real);
        s80floattype:=tfloatdef.create(s80real);
        s64currencytype:=torddef.create(scurrency,low(int64),high(int64));
{$endif powerpc}
{$ifdef POWERPC64}
        s32floattype:=tfloatdef.create(s32real);
        s64floattype:=tfloatdef.create(s64real);
        s80floattype:=tfloatdef.create(s80real);
        s64currencytype:=torddef.create(scurrency,low(int64),high(int64));
{$endif POWERPC64}
{$ifdef sparc}
        s32floattype:=tfloatdef.create(s32real);
        s64floattype:=tfloatdef.create(s64real);
        s80floattype:=tfloatdef.create(s80real);
        s64currencytype:=torddef.create(scurrency,low(int64),high(int64));
{$endif sparc}
{$ifdef m68k}
        s32floattype:=tfloatdef.create(s32real);
        s64floattype:=tfloatdef.create(s64real);
        s80floattype:=tfloatdef.create(s80real);
        s64currencytype:=torddef.create(scurrency,low(int64),high(int64));
{$endif}
{$ifdef arm}
        s32floattype:=tfloatdef.create(s32real);
        s64floattype:=tfloatdef.create(s64real);
        s80floattype:=tfloatdef.create(s80real);
        s64currencytype:=torddef.create(scurrency,low(int64),high(int64));
{$endif arm}
{$ifdef cpu64bit}
        uinttype:=u64inttype;
        sinttype:=s64inttype;
        ptruinttype:=u64inttype;
        ptrsinttype:=s64inttype;
{$else cpu64bit}
        uinttype:=u32inttype;
        sinttype:=s32inttype;
        ptruinttype:=u32inttype;
        ptrsinttype:=s32inttype;
{$endif cpu64bit}
        { some other definitions }
        voidpointertype:=tpointerdef.create(voidtype);
        charpointertype:=tpointerdef.create(cchartype);
        widecharpointertype:=tpointerdef.create(cwidechartype);
        voidfarpointertype:=tpointerdef.createfar(voidtype);
        cfiletype:=tfiledef.createuntyped;
        cvarianttype:=tvariantdef.create(vt_normalvariant);
        colevarianttype:=tvariantdef.create(vt_olevariant);

{$ifdef cpufpemu}
        { Normal types }
        (* we use the same types as without emulator, the only
          difference is that direct calls to the emulator are generated
        if (cs_fp_emulation in current_settings.moduleswitches) then
          begin
            addtype('Single',s32floattype);
            { extended size is the best real type for the target }
            addtype('Real',s32floattype);
            pbestrealtype:=@s32floattype;
            { extended size is the best real type for the target }
            addtype('Extended',pbestrealtype^);
          end
        else
        *)
{$endif cpufpemu}
          begin
            addtype('Single',s32floattype);
            addtype('Double',s64floattype);
            { extended size is the best real type for the target }
            addtype('Extended',pbestrealtype^);
          end;
{$ifdef x86}
        if target_info.system<>system_x86_64_win64 then
          addtype('Comp',tfloatdef.create(s64comp));
{$endif x86}
        addtype('Currency',s64currencytype);
        addtype('Pointer',voidpointertype);
{$ifdef x86}
        addtype('FarPointer',voidfarpointertype);
{$endif x86}
        addtype('ShortString',cshortstringtype);
{$ifdef support_longstring}
        addtype('LongString',clongstringtype);
{$endif support_longstring}
        addtype('AnsiString',cansistringtype);
        addtype('WideString',cwidestringtype);
        addtype('OpenString',openshortstringtype);
        addtype('Boolean',booltype);
        addtype('ByteBool',booltype);
        addtype('WordBool',bool16type);
        addtype('LongBool',bool32type);
        addtype('QWordBool',bool64type);
        addtype('Byte',u8inttype);
        addtype('ShortInt',s8inttype);
        addtype('Word',u16inttype);
        addtype('SmallInt',s16inttype);
        addtype('LongWord',u32inttype);
        addtype('LongInt',s32inttype);
        addtype('QWord',u64inttype);
        addtype('Int64',s64inttype);
        addtype('Char',cchartype);
        addtype('WideChar',cwidechartype);
        addtype('Text',tfiledef.createtext);
        addtype('TypedFile',tfiledef.createtyped(voidtype));
        addtype('Variant',cvarianttype);
        addtype('OleVariant',colevarianttype);
        { Internal types }
        addtype('$undefined',cundefinedtype);
        addtype('$formal',cformaltype);
        addtype('$void',voidtype);
        addtype('$byte',u8inttype);
        addtype('$shortint',s8inttype);
        addtype('$word',u16inttype);
        addtype('$smallint',s16inttype);
        addtype('$ulong',u32inttype);
        addtype('$longint',s32inttype);
        addtype('$qword',u64inttype);
        addtype('$int64',s64inttype);
        addtype('$char',cchartype);
        addtype('$widechar',cwidechartype);
        addtype('$shortstring',cshortstringtype);
        addtype('$longstring',clongstringtype);
        addtype('$ansistring',cansistringtype);
        addtype('$widestring',cwidestringtype);
        addtype('$openshortstring',openshortstringtype);
        addtype('$boolean',booltype);
        addtype('$boolean16',bool16type);
        addtype('$boolean32',bool32type);
        addtype('$boolean64',bool64type);
        addtype('$void_pointer',voidpointertype);
        addtype('$char_pointer',charpointertype);
        addtype('$widechar_pointer',widecharpointertype);
        addtype('$void_farpointer',voidfarpointertype);
        addtype('$openchararray',openchararraytype);
        addtype('$file',cfiletype);
        addtype('$variant',cvarianttype);
        addtype('$olevariant',cvarianttype);
        addtype('$s32real',s32floattype);
        addtype('$s64real',s64floattype);
        addtype('$s80real',s80floattype);
        addtype('$s64currency',s64currencytype);
        { Add a type for virtual method tables }
        hrecst:=trecordsymtable.create(current_settings.packrecords);
        vmttype:=trecorddef.create(hrecst);
        pvmttype:=tpointerdef.create(vmttype);
        { can't use addtype for pvmt because the rtti of the pointed
          type is not available. The rtti for pvmt will be written implicitly
          by thev tblarray below }
        systemunit.insert(ttypesym.create('$pvmt',pvmttype));
        hrecst.insertfield(tfieldvarsym.create('$parent',vs_value,pvmttype,[]));
        hrecst.insertfield(tfieldvarsym.create('$length',vs_value,s32inttype,[]));
        hrecst.insertfield(tfieldvarsym.create('$mlength',vs_value,s32inttype,[]));
        vmtarraytype:=tarraydef.create(0,1,s32inttype);
        tarraydef(vmtarraytype).elementdef:=voidpointertype;
        hrecst.insertfield(tfieldvarsym.create('$__pfn',vs_value,vmtarraytype,[]));
        addtype('$__vtbl_ptr_type',vmttype);
        vmtarraytype:=tarraydef.create(0,1,s32inttype);
        tarraydef(vmtarraytype).elementdef:=pvmttype;
        addtype('$vtblarray',vmtarraytype);
        { Add a type for methodpointers }
        hrecst:=trecordsymtable.create(1);
        hrecst.insertfield(tfieldvarsym.create('$proc',vs_value,voidpointertype,[]));
        hrecst.insertfield(tfieldvarsym.create('$self',vs_value,voidpointertype,[]));
        methodpointertype:=trecorddef.create(hrecst);
        addtype('$methodpointer',methodpointertype);
        symtablestack.pop(systemunit);
      end;


    procedure load_intern_types;
      {
        Load all default definitions for consts from the system unit
      }

        procedure loadtype(const s:string;var def:tdef);
        var
          srsym : ttypesym;
        begin
          srsym:=search_system_type(s);
          def:=srsym.typedef;
        end;

      var
        oldcurrentmodule : tmodule;
      begin
        if target_info.system=system_x86_64_win64 then
          pbestrealtype:=@s64floattype;

        oldcurrentmodule:=current_module;
        current_module:=nil;
        loadtype('byte',u8inttype);
        loadtype('shortint',s8inttype);
        loadtype('word',u16inttype);
        loadtype('smallint',s16inttype);
        loadtype('ulong',u32inttype);
        loadtype('longint',s32inttype);
        loadtype('qword',u64inttype);
        loadtype('int64',s64inttype);
        loadtype('undefined',cundefinedtype);
        loadtype('formal',cformaltype);
        loadtype('void',voidtype);
        loadtype('char',cchartype);
        loadtype('widechar',cwidechartype);
        loadtype('shortstring',cshortstringtype);
        loadtype('longstring',clongstringtype);
        loadtype('ansistring',cansistringtype);
        loadtype('widestring',cwidestringtype);
        loadtype('openshortstring',openshortstringtype);
        loadtype('openchararray',openchararraytype);
        loadtype('s32real',s32floattype);
        loadtype('s64real',s64floattype);
        loadtype('s80real',s80floattype);
        loadtype('s64currency',s64currencytype);
        loadtype('boolean',booltype);
        loadtype('boolean16',bool16type);
        loadtype('boolean32',bool32type);
        loadtype('boolean64',bool64type);
        loadtype('void_pointer',voidpointertype);
        loadtype('char_pointer',charpointertype);
        loadtype('widechar_pointer',widecharpointertype);
        loadtype('void_farpointer',voidfarpointertype);
        loadtype('file',cfiletype);
        loadtype('pvmt',pvmttype);
        loadtype('vtblarray',vmtarraytype);
        loadtype('__vtbl_ptr_type',vmttype);
        loadtype('variant',cvarianttype);
        loadtype('olevariant',colevarianttype);
        loadtype('methodpointer',methodpointertype);
        loadtype('HRESULT',hresultdef);
{$ifdef cpu64bit}
        uinttype:=u64inttype;
        sinttype:=s64inttype;
        ptruinttype:=u64inttype;
        ptrsinttype:=s64inttype;
{$else cpu64bit}
        uinttype:=u32inttype;
        sinttype:=s32inttype;
        ptruinttype:=u32inttype;
        ptrsinttype:=s32inttype;
{$endif cpu64bit}
        current_module:=oldcurrentmodule;
      end;


    procedure registernodes;
      {
        Register all possible nodes in the nodeclass array that
        will be used for loading the nodes from a ppu
      }
      begin
        nodeclass[addn]:=caddnode;
        nodeclass[muln]:=caddnode;
        nodeclass[subn]:=caddnode;
        nodeclass[divn]:=cmoddivnode;
        nodeclass[symdifn]:=caddnode;
        nodeclass[modn]:=cmoddivnode;
        nodeclass[assignn]:=cassignmentnode;
        nodeclass[loadn]:=cloadnode;
        nodeclass[rangen]:=crangenode;
        nodeclass[ltn]:=caddnode;
        nodeclass[lten]:=caddnode;
        nodeclass[gtn]:=caddnode;
        nodeclass[gten]:=caddnode;
        nodeclass[equaln]:=caddnode;
        nodeclass[unequaln]:=caddnode;
        nodeclass[inn]:=cinnode;
        nodeclass[orn]:=caddnode;
        nodeclass[xorn]:=caddnode;
        nodeclass[shrn]:=cshlshrnode;
        nodeclass[shln]:=cshlshrnode;
        nodeclass[slashn]:=caddnode;
        nodeclass[andn]:=caddnode;
        nodeclass[subscriptn]:=csubscriptnode;
        nodeclass[derefn]:=cderefnode;
        nodeclass[addrn]:=caddrnode;
        nodeclass[ordconstn]:=cordconstnode;
        nodeclass[typeconvn]:=ctypeconvnode;
        nodeclass[calln]:=ccallnode;
        nodeclass[callparan]:=ccallparanode;
        nodeclass[realconstn]:=crealconstnode;
        nodeclass[unaryminusn]:=cunaryminusnode;
        nodeclass[asmn]:=casmnode;
        nodeclass[vecn]:=cvecnode;
        nodeclass[pointerconstn]:=cpointerconstnode;
        nodeclass[stringconstn]:=cstringconstnode;
        nodeclass[notn]:=cnotnode;
        nodeclass[inlinen]:=cinlinenode;
        nodeclass[niln]:=cnilnode;
        nodeclass[errorn]:=cerrornode;
        nodeclass[typen]:=ctypenode;
        nodeclass[setelementn]:=csetelementnode;
        nodeclass[setconstn]:=csetconstnode;
        nodeclass[blockn]:=cblocknode;
        nodeclass[statementn]:=cstatementnode;
        nodeclass[ifn]:=cifnode;
        nodeclass[breakn]:=cbreaknode;
        nodeclass[continuen]:=ccontinuenode;
        nodeclass[whilerepeatn]:=cwhilerepeatnode;
        nodeclass[forn]:=cfornode;
        nodeclass[exitn]:=cexitnode;
        nodeclass[withn]:=cwithnode;
        nodeclass[casen]:=ccasenode;
        nodeclass[labeln]:=clabelnode;
        nodeclass[goton]:=cgotonode;
        nodeclass[tryexceptn]:=ctryexceptnode;
        nodeclass[raisen]:=craisenode;
        nodeclass[tryfinallyn]:=ctryfinallynode;
        nodeclass[onn]:=connode;
        nodeclass[isn]:=cisnode;
        nodeclass[asn]:=casnode;
        nodeclass[caretn]:=caddnode;
        nodeclass[starstarn]:=caddnode;
        nodeclass[arrayconstructorn]:=carrayconstructornode;
        nodeclass[arrayconstructorrangen]:=carrayconstructorrangenode;
        nodeclass[tempcreaten]:=ctempcreatenode;
        nodeclass[temprefn]:=ctemprefnode;
        nodeclass[tempdeleten]:=ctempdeletenode;
        nodeclass[addoptn]:=caddnode;
        nodeclass[nothingn]:=cnothingnode;
        nodeclass[loadvmtaddrn]:=cloadvmtaddrnode;
        nodeclass[guidconstn]:=cguidconstnode;
        nodeclass[rttin]:=crttinode;
        nodeclass[loadparentfpn]:=cloadparentfpnode;
      end;


    procedure registertais;
      {
        Register all possible tais in the taiclass array that
        will be used for loading the tais from a ppu
      }
      begin
        aiclass[ait_none]:=nil;
        aiclass[ait_align]:=tai_align;
        aiclass[ait_section]:=tai_section;
        aiclass[ait_comment]:=tai_comment;
        aiclass[ait_string]:=tai_string;
        aiclass[ait_instruction]:=taicpu;
        aiclass[ait_datablock]:=tai_datablock;
        aiclass[ait_symbol]:=tai_symbol;
        aiclass[ait_symbol_end]:=tai_symbol_end;
        aiclass[ait_directive]:=tai_directive;
        aiclass[ait_label]:=tai_label;
        aiclass[ait_const]:=tai_const;
        aiclass[ait_real_32bit]:=tai_real_32bit;
        aiclass[ait_real_64bit]:=tai_real_64bit;
        aiclass[ait_real_80bit]:=tai_real_80bit;
        aiclass[ait_comp_64bit]:=tai_comp_64bit;
        aiclass[ait_stab]:=tai_stab;
        aiclass[ait_force_line]:=tai_force_line;
        aiclass[ait_function_name]:=tai_function_name;
{$ifdef alpha}
          { the follow is for the DEC Alpha }
        aiclass[ait_frame]:=tai_frame;
        aiclass[ait_ent]:=tai_ent;
{$endif alpha}
{$ifdef m68k}
{$warning FIXME: tai_labeled_instruction doesn't exists}
//        aiclass[ait_labeled_instruction]:=tai_labeled_instruction;
{$endif m68k}
{$ifdef ia64}
        aiclass[ait_bundle]:=tai_bundle;
        aiclass[ait_stop]:=tai_stop;
{$endif ia64}
{$ifdef SPARC}
//        aiclass[ait_labeled_instruction]:=tai_labeled_instruction;
{$endif SPARC}
        aiclass[ait_cutobject]:=tai_cutobject;
        aiclass[ait_regalloc]:=tai_regalloc;
        aiclass[ait_tempalloc]:=tai_tempalloc;
        aiclass[ait_marker]:=tai_marker;
        aiclass[ait_file]:=tai_file;
        aiclass[ait_loc]:=tai_loc;
      end;

end.
