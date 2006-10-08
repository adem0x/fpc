{
    Copyright (c) 2003-2006 by Peter Vreman and Florian Klaempfl

    This units contains support for DWARF debug info generation

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
{
  This units contains support for DWARF debug info generation.

  Currently a lot of code looks like being mergable with dbgstabs. This might
  change however when improved dwarf info is generated, so the stuff shouldn't be
  merged yet. (FK)

  The easiest way to debug dwarf debug info generation is the usage of
  readelf --debug-dump <executable>
  This works only with elf targets though.
}
unit dbgdwarf;

{$i fpcdefs.inc}

interface

    uses
      cclasses,
      aasmbase,aasmtai,aasmdata,
      symbase,symtype,symdef,symsym,
      finput,
      DbgBase;

    type
      { Tag names and codes.   }
      tdwarf_tag = (DW_TAG_padding := $00,DW_TAG_array_type := $01,
        DW_TAG_class_type := $02,DW_TAG_entry_point := $03,
        DW_TAG_enumeration_type := $04,DW_TAG_formal_parameter := $05,
        DW_TAG_imported_declaration := $08,DW_TAG_label := $0a,
        DW_TAG_lexical_block := $0b,DW_TAG_member := $0d,
        DW_TAG_pointer_type := $0f,DW_TAG_reference_type := $10,
        DW_TAG_compile_unit := $11,DW_TAG_string_type := $12,
        DW_TAG_structure_type := $13,DW_TAG_subroutine_type := $15,
        DW_TAG_typedef := $16,DW_TAG_union_type := $17,
        DW_TAG_unspecified_parameters := $18,
        DW_TAG_variant := $19,DW_TAG_common_block := $1a,
        DW_TAG_common_inclusion := $1b,DW_TAG_inheritance := $1c,
        DW_TAG_inlined_subroutine := $1d,DW_TAG_module := $1e,
        DW_TAG_ptr_to_member_type := $1f,DW_TAG_set_type := $20,
        DW_TAG_subrange_type := $21,DW_TAG_with_stmt := $22,
        DW_TAG_access_declaration := $23,DW_TAG_base_type := $24,
        DW_TAG_catch_block := $25,DW_TAG_const_type := $26,
        DW_TAG_constant := $27,DW_TAG_enumerator := $28,
        DW_TAG_file_type := $29,DW_TAG_friend := $2a,
        DW_TAG_namelist := $2b,DW_TAG_namelist_item := $2c,
        DW_TAG_packed_type := $2d,DW_TAG_subprogram := $2e,
        DW_TAG_template_type_param := $2f,DW_TAG_template_value_param := $30,
        DW_TAG_thrown_type := $31,DW_TAG_try_block := $32,
        DW_TAG_variant_part := $33,DW_TAG_variable := $34,
        DW_TAG_volatile_type := $35,
        { DWARF 3.   }
        DW_TAG_dwarf_procedure := $36,
        DW_TAG_restrict_type := $37,DW_TAG_interface_type := $38,
        DW_TAG_namespace := $39,DW_TAG_imported_module := $3a,
        DW_TAG_unspecified_type := $3b,DW_TAG_partial_unit := $3c,
        DW_TAG_imported_unit := $3d,

        { SGI/MIPS Extensions.   }
        DW_TAG_MIPS_loop := $4081,

        { HP extensions.  See: ftp://ftp.hp.com/pub/lang/tools/WDB/wdb-4.0.tar.gz .   }
        DW_TAG_HP_array_descriptor := $4090,

        { GNU extensions.   }
        { For FORTRAN 77 and Fortran 90.   }
        DW_TAG_format_label := $4101,
        { For C++.   }
        DW_TAG_function_template := $4102,DW_TAG_class_template := $4103,

        DW_TAG_GNU_BINCL := $4104,DW_TAG_GNU_EINCL := $4105,
        { Extensions for UPC.  See: http://upc.gwu.edu/~upc.   }
        DW_TAG_upc_shared_type := $8765,DW_TAG_upc_strict_type := $8766,
        DW_TAG_upc_relaxed_type := $8767,

        { PGI (STMicroelectronics) extensions.  No documentation available.   }
        DW_TAG_PGI_kanji_type := $A000,
        DW_TAG_PGI_interface_block := $A020);

      { Attribute names and codes.   }
      tdwarf_attribute = (DW_AT_sibling := $01,DW_AT_location := $02,
        DW_AT_name := $03,DW_AT_ordering := $09,
        DW_AT_subscr_data := $0a,DW_AT_byte_size := $0b,
        DW_AT_bit_offset := $0c,DW_AT_bit_size := $0d,
        DW_AT_element_list := $0f,DW_AT_stmt_list := $10,
        DW_AT_low_pc := $11,DW_AT_high_pc := $12,
        DW_AT_language := $13,DW_AT_member := $14,
        DW_AT_discr := $15,DW_AT_discr_value := $16,
        DW_AT_visibility := $17,DW_AT_import := $18,
        DW_AT_string_length := $19,DW_AT_common_reference := $1a,
        DW_AT_comp_dir := $1b,DW_AT_const_value := $1c,
        DW_AT_containing_type := $1d,DW_AT_default_value := $1e,
        DW_AT_inline := $20,DW_AT_is_optional := $21,
        DW_AT_lower_bound := $22,DW_AT_producer := $25,
        DW_AT_prototyped := $27,DW_AT_return_addr := $2a,
        DW_AT_start_scope := $2c,DW_AT_stride_size := $2e,
        DW_AT_upper_bound := $2f,DW_AT_abstract_origin := $31,
        DW_AT_accessibility := $32,DW_AT_address_class := $33,
        DW_AT_artificial := $34,DW_AT_base_types := $35,
        DW_AT_calling_convention := $36,DW_AT_count := $37,
        DW_AT_data_member_location := $38,DW_AT_decl_column := $39,
        DW_AT_decl_file := $3a,DW_AT_decl_line := $3b,
        DW_AT_declaration := $3c,DW_AT_discr_list := $3d,
        DW_AT_encoding := $3e,DW_AT_external := $3f,
        DW_AT_frame_base := $40,DW_AT_friend := $41,
        DW_AT_identifier_case := $42,DW_AT_macro_info := $43,
        DW_AT_namelist_items := $44,DW_AT_priority := $45,
        DW_AT_segment := $46,DW_AT_specification := $47,
        DW_AT_static_link := $48,DW_AT_type := $49,
        DW_AT_use_location := $4a,DW_AT_variable_parameter := $4b,
        DW_AT_virtuality := $4c,DW_AT_vtable_elem_location := $4d,

        { DWARF 3 values.   }
        DW_AT_allocated := $4e,DW_AT_associated := $4f,
        DW_AT_data_location := $50,DW_AT_stride := $51,
        DW_AT_entry_pc := $52,DW_AT_use_UTF8 := $53,
        DW_AT_extension := $54,DW_AT_ranges := $55,
        DW_AT_trampoline := $56,DW_AT_call_column := $57,
        DW_AT_call_file := $58,DW_AT_call_line := $59,

        { SGI/MIPS extensions.   }
        DW_AT_MIPS_fde := $2001,DW_AT_MIPS_loop_begin := $2002,
        DW_AT_MIPS_tail_loop_begin := $2003,DW_AT_MIPS_epilog_begin := $2004,
        DW_AT_MIPS_loop_unroll_factor := $2005,
        DW_AT_MIPS_software_pipeline_depth := $2006,
        DW_AT_MIPS_linkage_name := $2007,DW_AT_MIPS_stride := $2008,
        DW_AT_MIPS_abstract_name := $2009,DW_AT_MIPS_clone_origin := $200a,
        DW_AT_MIPS_has_inlines := $200b,

        { HP extensions.   }
        DW_AT_HP_block_index := $2000,
        DW_AT_HP_unmodifiable := $2001,DW_AT_HP_actuals_stmt_list := $2010,
        DW_AT_HP_proc_per_section := $2011,DW_AT_HP_raw_data_ptr := $2012,
        DW_AT_HP_pass_by_reference := $2013,DW_AT_HP_opt_level := $2014,
        DW_AT_HP_prof_version_id := $2015,DW_AT_HP_opt_flags := $2016,
        DW_AT_HP_cold_region_low_pc := $2017,DW_AT_HP_cold_region_high_pc := $2018,
        DW_AT_HP_all_variables_modifiable := $2019,
        DW_AT_HP_linkage_name := $201a,DW_AT_HP_prof_flags := $201b,

        { GNU extensions.   }
        DW_AT_sf_names := $2101,DW_AT_src_info := $2102,
        DW_AT_mac_info := $2103,DW_AT_src_coords := $2104,
        DW_AT_body_begin := $2105,DW_AT_body_end := $2106,
        DW_AT_GNU_vector := $2107,

        { VMS extensions.  }
        DW_AT_VMS_rtnbeg_pd_address := $2201,

        { UPC extension.   }
        DW_AT_upc_threads_scaled := $3210,

        { PGI (STMicroelectronics) extensions.   }
        DW_AT_PGI_lbase := $3a00,
        DW_AT_PGI_soffset := $3a01,DW_AT_PGI_lstride := $3a02
      );

      { Form names and codes.   }
      Tdwarf_form = (DW_FORM_addr := $01,DW_FORM_block2 := $03,
        DW_FORM_block4 := $04,DW_FORM_data2 := $05,
        DW_FORM_data4 := $06,DW_FORM_data8 := $07,
        DW_FORM_string := $08,DW_FORM_block := $09,
        DW_FORM_block1 := $0a,DW_FORM_data1 := $0b,
        DW_FORM_flag := $0c,DW_FORM_sdata := $0d,
        DW_FORM_strp := $0e,DW_FORM_udata := $0f,
        DW_FORM_ref_addr := $10,DW_FORM_ref1 := $11,
        DW_FORM_ref2 := $12,DW_FORM_ref4 := $13,
        DW_FORM_ref8 := $14,DW_FORM_ref_udata := $15,
        DW_FORM_indirect := $16);

      TDwarfFile = record
        Index: integer;
        Name: PChar;
      end;

      { TDebugInfoDwarf }

      TDebugInfoDwarf = class(TDebugInfo)
      private
        currabbrevnumber : longint;

        { collect all defs in one list so we can reset them easily }
        { not used (MWE)
        nextdefnumber    : longint;
        }
        defnumberlist,
        deftowritelist   : TFPObjectList;

        writing_def_dwarf : boolean;

        { use this defs to create info for variants and file handles }
        { unused (MWE)
        filerecdef,
        textrecdef : tdef;
        }

        dirlist: Tdictionary;
        filesequence: Integer;
        loclist: tdynamicarray;
        asmline: TAsmList;

        function def_dwarf_lab(def:tdef) : tasmsymbol;
        function get_file_index(afile: tinputfile): Integer;
        procedure write_symtable_syms(st:tsymtable);
      protected
        isdwarf64: Boolean;
        vardatadef: trecorddef;
        procedure append_entry(tag : tdwarf_tag;has_children : boolean;data : array of const);
        procedure append_labelentry(attr : tdwarf_attribute;sym : tasmsymbol);
        procedure append_labelentry_ref(attr : tdwarf_attribute;sym : tasmsymbol);
        procedure append_labelentry_data(attr : tdwarf_attribute;sym : tasmsymbol);

        procedure appenddef(def:tdef);
        procedure appenddef_ord(def:torddef); virtual;
        procedure appenddef_float(def:tfloatdef); virtual;
        procedure appenddef_file(def:tfiledef); virtual;
        procedure appenddef_enum(def:tenumdef); virtual;
        procedure appenddef_array(def:tarraydef); virtual;
        procedure appenddef_record(def:trecorddef); virtual;
        procedure appenddef_object(def:tobjectdef); virtual; abstract;
        procedure appenddef_pointer(def:tpointerdef); virtual;
        procedure appenddef_string(def:tstringdef); virtual;
        procedure appenddef_procvar(def:tprocvardef); virtual;
        procedure appenddef_variant(def:tvariantdef); virtual; abstract;
        procedure appenddef_set(def:tsetdef); virtual; abstract;
        procedure appenddef_formal(def:tformaldef); virtual;
        procedure appenddef_unineddef(def:tundefineddef); virtual; abstract;

        procedure appendprocdef(pd:tprocdef); virtual;

        procedure appendsym(sym:tsym);
        procedure appendsym_var(sym:tabstractnormalvarsym); virtual;
        procedure appendsym_fieldvar(sym:tfieldvarsym); virtual;
        procedure appendsym_unit(sym:tunitsym); virtual;
        procedure appendsym_const(sym:tconstsym); virtual;
        procedure appendsym_type(sym:ttypesym); virtual;
        procedure appendsym_typedconst(sym:ttypedconstsym); virtual;
        procedure appendsym_label(sym:tlabelsym); virtual;
        procedure appendsym_absolute(sym:tabsolutevarsym); virtual;
        procedure appendsym_property(sym:tpropertysym); virtual;
        procedure appendsym_proc(sym:tprocsym); virtual;
        
        function symname(sym:tsym): String; virtual;

        procedure enum_membersyms_callback(p:Tnamedindexitem;arg:pointer);

        procedure finish_children;
        procedure finish_entry;
      public
        constructor Create;override;
        destructor Destroy;override;

        procedure insertdef(unused:TAsmList;def:tdef);override;

        procedure insertmoduleinfo;override;
        procedure inserttypeinfo;override;
        procedure referencesections(list:TAsmList);override;
        procedure insertlineinfo(list:TAsmList);override;
        function  dwarf_version: Word; virtual; abstract;
        procedure write_symtable_defs(unused:TAsmList;st:tsymtable);override;
      end;

      { TDebugInfoDwarf2 }

      TDebugInfoDwarf2 = class(TDebugInfoDwarf)
      private
      protected
        procedure appenddef_file(def:tfiledef); override;
        procedure appenddef_formal(def:tformaldef); override;
        procedure appenddef_object(def:tobjectdef); override;
        procedure appenddef_set(def:tsetdef); override;
        procedure appenddef_unineddef(def:tundefineddef); override;
        procedure appenddef_variant(def:tvariantdef); override;
      public
        function  dwarf_version: Word; override;
      end;

      { TDebugInfoDwarf3 }

      TDebugInfoDwarf3 = class(TDebugInfoDwarf)
      private
      protected
        procedure appenddef_file(def:tfiledef); override;
        procedure appenddef_formal(def:tformaldef); override;
        procedure appenddef_object(def:tobjectdef); override;
        procedure appenddef_set(def:tsetdef); override;
        procedure appenddef_unineddef(def:tundefineddef); override;
        procedure appenddef_variant(def:tvariantdef); override;

        function symname(sym:tsym): String; override;
      public
        function  dwarf_version: Word; override;
      end;

implementation

    uses
      version,
      cutils,
      globtype,
      globals,
      verbose,
      systems,
      cpubase,
      cgbase,
      fmodule,
      defutil,
      symconst,symtable
      ;

    const
      LINE_BASE   = 1;
      OPCODE_BASE = 13;

    const
      DW_TAG_lo_user = $4080;
      DW_TAG_hi_user = $ffff;

      { Flag that tells whether entry has a child or not.   }
      DW_children_no = 0;
      DW_children_yes = 1;

    const
      { Implementation-defined range start.   }
      DW_AT_lo_user = $2000;
      { Implementation-defined range end.   }
      DW_AT_hi_user = $3ff0;

    type
      { Source language names and codes.   }
      tdwarf_source_language = (DW_LANG_C89 := $0001,DW_LANG_C := $0002,DW_LANG_Ada83 := $0003,
        DW_LANG_C_plus_plus := $0004,DW_LANG_Cobol74 := $0005,
        DW_LANG_Cobol85 := $0006,DW_LANG_Fortran77 := $0007,
        DW_LANG_Fortran90 := $0008,DW_LANG_Pascal83 := $0009,
        DW_LANG_Modula2 := $000a,DW_LANG_Java := $000b,

        { DWARF 3.   }
        DW_LANG_C99 := $000c,DW_LANG_Ada95 := $000d,
        DW_LANG_Fortran95 := $000e,

        { MIPS.   }
        DW_LANG_Mips_Assembler := $8001,

        { UPC.   }
        DW_LANG_Upc := $8765
      );

    const
      { Implementation-defined range start.   }
      DW_LANG_lo_user = $8000;

      { Implementation-defined range start.   }
      DW_LANG_hi_user = $ffff;

    type
      { Names and codes for macro information.   }
      tdwarf_macinfo_record_type = (DW_MACINFO_define := 1,DW_MACINFO_undef := 2,
        DW_MACINFO_start_file := 3,DW_MACINFO_end_file := 4,
        DW_MACINFO_vendor_ext := 255);


    type
      { Type encodings.   }
      Tdwarf_type = (DW_ATE_void := $0,DW_ATE_address := $1,
        DW_ATE_boolean := $2,DW_ATE_complex_float := $3,
        DW_ATE_float := $4,DW_ATE_signed := $5,
        DW_ATE_signed_char := $6,DW_ATE_unsigned := $7,
        DW_ATE_unsigned_char := $8,DW_ATE_imaginary_float := $9,

        { HP extensions.   }
        DW_ATE_HP_float80 := $80,DW_ATE_HP_complex_float80 := $81,
        DW_ATE_HP_float128 := $82,DW_ATE_HP_complex_float128 := $83,
        DW_ATE_HP_floathpintel := $84,DW_ATE_HP_imaginary_float80 := $85,
        DW_ATE_HP_imaginary_float128 := $86
        );


    const
      DW_ATE_lo_user = $80;
      DW_ATE_hi_user = $ff;


    type
      Tdwarf_array_dim_ordering = (DW_ORD_row_major := 0,DW_ORD_col_major := 1
        );

      { Access attribute.   }
      Tdwarf_access_attribute = (DW_ACCESS_public := 1,DW_ACCESS_protected := 2,
        DW_ACCESS_private := 3);

      { Visibility.   }
      Tdwarf_visibility_attribute = (DW_VIS_local := 1,DW_VIS_exported := 2,
        DW_VIS_qualified := 3);

      { Virtuality.   }
      Tdwarf_virtuality_attribute = (DW_VIRTUALITY_none := 0,DW_VIRTUALITY_virtual := 1,
        DW_VIRTUALITY_pure_virtual := 2);

      { Case sensitivity.   }
      Tdwarf_id_case = (DW_ID_case_sensitive := 0,DW_ID_up_case := 1,
        DW_ID_down_case := 2,DW_ID_case_insensitive := 3
        );

      { Calling convention.   }
      Tdwarf_calling_convention = (DW_CC_normal := $1,DW_CC_program := $2,
        DW_CC_nocall := $3,DW_CC_GNU_renesas_sh := $40
        );

      { Location atom names and codes.   }
      Tdwarf_location_atom = (DW_OP_addr := $03,DW_OP_deref := $06,DW_OP_const1u := $08,
        DW_OP_const1s := $09,DW_OP_const2u := $0a,
        DW_OP_const2s := $0b,DW_OP_const4u := $0c,
        DW_OP_const4s := $0d,DW_OP_const8u := $0e,
        DW_OP_const8s := $0f,DW_OP_constu := $10,
        DW_OP_consts := $11,DW_OP_dup := $12,DW_OP_drop := $13,
        DW_OP_over := $14,DW_OP_pick := $15,DW_OP_swap := $16,
        DW_OP_rot := $17,DW_OP_xderef := $18,DW_OP_abs := $19,
        DW_OP_and := $1a,DW_OP_div := $1b,DW_OP_minus := $1c,
        DW_OP_mod := $1d,DW_OP_mul := $1e,DW_OP_neg := $1f,
        DW_OP_not := $20,DW_OP_or := $21,DW_OP_plus := $22,
        DW_OP_plus_uconst := $23,DW_OP_shl := $24,
        DW_OP_shr := $25,DW_OP_shra := $26,DW_OP_xor := $27,
        DW_OP_bra := $28,DW_OP_eq := $29,DW_OP_ge := $2a,
        DW_OP_gt := $2b,DW_OP_le := $2c,DW_OP_lt := $2d,
        DW_OP_ne := $2e,DW_OP_skip := $2f,DW_OP_lit0 := $30,
        DW_OP_lit1 := $31,DW_OP_lit2 := $32,DW_OP_lit3 := $33,
        DW_OP_lit4 := $34,DW_OP_lit5 := $35,DW_OP_lit6 := $36,
        DW_OP_lit7 := $37,DW_OP_lit8 := $38,DW_OP_lit9 := $39,
        DW_OP_lit10 := $3a,DW_OP_lit11 := $3b,
        DW_OP_lit12 := $3c,DW_OP_lit13 := $3d,
        DW_OP_lit14 := $3e,DW_OP_lit15 := $3f,
        DW_OP_lit16 := $40,DW_OP_lit17 := $41,
        DW_OP_lit18 := $42,DW_OP_lit19 := $43,
        DW_OP_lit20 := $44,DW_OP_lit21 := $45,
        DW_OP_lit22 := $46,DW_OP_lit23 := $47,
        DW_OP_lit24 := $48,DW_OP_lit25 := $49,
        DW_OP_lit26 := $4a,DW_OP_lit27 := $4b,
        DW_OP_lit28 := $4c,DW_OP_lit29 := $4d,
        DW_OP_lit30 := $4e,DW_OP_lit31 := $4f,
        DW_OP_reg0 := $50,DW_OP_reg1 := $51,DW_OP_reg2 := $52,
        DW_OP_reg3 := $53,DW_OP_reg4 := $54,DW_OP_reg5 := $55,
        DW_OP_reg6 := $56,DW_OP_reg7 := $57,DW_OP_reg8 := $58,
        DW_OP_reg9 := $59,DW_OP_reg10 := $5a,DW_OP_reg11 := $5b,
        DW_OP_reg12 := $5c,DW_OP_reg13 := $5d,
        DW_OP_reg14 := $5e,DW_OP_reg15 := $5f,
        DW_OP_reg16 := $60,DW_OP_reg17 := $61,
        DW_OP_reg18 := $62,DW_OP_reg19 := $63,
        DW_OP_reg20 := $64,DW_OP_reg21 := $65,
        DW_OP_reg22 := $66,DW_OP_reg23 := $67,
        DW_OP_reg24 := $68,DW_OP_reg25 := $69,
        DW_OP_reg26 := $6a,DW_OP_reg27 := $6b,
        DW_OP_reg28 := $6c,DW_OP_reg29 := $6d,
        DW_OP_reg30 := $6e,DW_OP_reg31 := $6f,
        DW_OP_breg0 := $70,DW_OP_breg1 := $71,
        DW_OP_breg2 := $72,DW_OP_breg3 := $73,
        DW_OP_breg4 := $74,DW_OP_breg5 := $75,
        DW_OP_breg6 := $76,DW_OP_breg7 := $77,
        DW_OP_breg8 := $78,DW_OP_breg9 := $79,
        DW_OP_breg10 := $7a,DW_OP_breg11 := $7b,
        DW_OP_breg12 := $7c,DW_OP_breg13 := $7d,
        DW_OP_breg14 := $7e,DW_OP_breg15 := $7f,
        DW_OP_breg16 := $80,DW_OP_breg17 := $81,
        DW_OP_breg18 := $82,DW_OP_breg19 := $83,
        DW_OP_breg20 := $84,DW_OP_breg21 := $85,
        DW_OP_breg22 := $86,DW_OP_breg23 := $87,
        DW_OP_breg24 := $88,DW_OP_breg25 := $89,
        DW_OP_breg26 := $8a,DW_OP_breg27 := $8b,
        DW_OP_breg28 := $8c,DW_OP_breg29 := $8d,
        DW_OP_breg30 := $8e,DW_OP_breg31 := $8f,
        DW_OP_regx := $90,DW_OP_fbreg := $91,DW_OP_bregx := $92,
        DW_OP_piece := $93,DW_OP_deref_size := $94,
        DW_OP_xderef_size := $95,DW_OP_nop := $96,

        { DWARF 3 extensions.   }
        DW_OP_push_object_address := $97,DW_OP_call2 := $98,
        DW_OP_call4 := $99,DW_OP_call_ref := $9a,

        { GNU extensions.   }
        DW_OP_GNU_push_tls_address := $e0,

        { HP extensions.   }
        DW_OP_HP_unknown := $e0,
        DW_OP_HP_is_value := $e1,DW_OP_HP_fltconst4 := $e2,
        DW_OP_HP_fltconst8 := $e3,DW_OP_HP_mod_range := $e4,
        DW_OP_HP_unmod_range := $e5,DW_OP_HP_tls := $e6
        );

    const
      { Implementation-defined range start.   }
      DW_OP_lo_user = $e0;
      { Implementation-defined range end.   }
      DW_OP_hi_user = $ff;


    const
      DW_LNS_extended_op     = $00;

      { next copied from cfidwarf, need to go to something shared }
      DW_LNS_copy            = $01;
      DW_LNS_advance_pc      = $02;
      DW_LNS_advance_line    = $03;
      DW_LNS_set_file        = $04;
      DW_LNS_set_column      = $05;
      DW_LNS_negate_stmt     = $06;
      DW_LNS_set_basic_block = $07;
      DW_LNS_const_add_pc    = $08;

      DW_LNS_fixed_advance_pc   = $09;
      DW_LNS_set_prologue_end   = $0a;
      DW_LNS_set_epilogue_begin = $0b;
      DW_LNS_set_isa            = $0c;

      DW_LNE_end_sequence = $01;
      DW_LNE_set_address  = $02;
      DW_LNE_define_file  = $03;
      DW_LNE_lo_user      = $80;
      DW_LNE_hi_user      = $ff;

    type
      { TDirIndexItem }

      TDirIndexItem = class(TNamedIndexItem)
      private
        FFiles: TDictionary;
      public
        constructor Create(const AName: String; AIndex: Integer);
        destructor  Destroy;override;
        property Files: TDictionary read FFiles;
      end;

      { TFileIndexItem }

      TFileIndexItem = class(TNamedIndexItem)
      private
        FDirIndex: Integer;
      public
        constructor Create(const AName: String; ADirIndex, AIndex: Integer);
        property DirIndex: Integer read FDirIndex;
      end;


{****************************************************************************
                              procs
****************************************************************************}
procedure AddNamedIndexToList(p:TNamedIndexItem; arg:pointer);
begin
  TFPList(Arg).Add(p);
end;

function DirListSortCompare(AItem1, AItem2: Pointer): Integer;
begin
  Result := TDirIndexItem(AItem1).IndexNr - TDirIndexItem(AItem2).IndexNr;
end;

function FileListSortCompare(AItem1, AItem2: Pointer): Integer;
begin
  Result := TFileIndexItem(AItem1).IndexNr - TFileIndexItem(AItem2).IndexNr;
end;

{****************************************************************************
                              TDirIndexItem
****************************************************************************}

    constructor TDirIndexItem.Create(const AName: String; AIndex: Integer);
    begin
      inherited CreateName(AName);
      FFiles := TDictionary.Create;
      IndexNr := AIndex;
    end;

    destructor TDirIndexItem.Destroy;
    begin
      FFiles.Free;
      FFiles := nil;
      inherited Destroy;
    end;

{****************************************************************************
                              TFileIndexItem
****************************************************************************}

    constructor TFileIndexItem.Create(const AName: String; ADirIndex, AIndex: Integer);
    begin
      inherited CreateName(Aname);
      FDirIndex := ADirIndex;
      IndexNr := AIndex;
    end;


{****************************************************************************
                              TDebugInfoDwarf
****************************************************************************}

    function TDebugInfoDwarf.def_dwarf_lab(def:tdef) : tasmsymbol;
      begin
        { Keep track of used dwarf entries, this info is only usefull for dwarf entries
          referenced by the symbols. Definitions will always include all
          required stabs }
        if def.dbg_state=dbg_state_unused then
          def.dbg_state:=dbg_state_used;
        { Need a new label? }
        if not assigned(def.dwarf_lab) then
          begin
            if (df_has_dwarf_dbg_info in def.defoptions) then
              begin
                if not assigned(def.typesym) then
                  internalerror(200610011);
                def.dwarf_lab:=current_asmdata.RefAsmSymbol(make_mangledname('DBG',def.owner,symname(def.typesym)));
                def.dbg_state:=dbg_state_written;
              end
            else
              begin
                { Create an exported DBG symbol if we are generating a def defined in the
                  globalsymtable of the current unit }
                if assigned(def.typesym) and
                   (def.owner.symtabletype=globalsymtable) and
                   (def.owner.iscurrentunit) then
                  begin
                    def.dwarf_lab:=current_asmdata.DefineAsmSymbol(make_mangledname('DBG',def.owner,symname(def.typesym)),AB_GLOBAL,AT_DATA);
                    include(def.defoptions,df_has_dwarf_dbg_info);
                  end
                else
                  current_asmdata.getdatalabel(TAsmLabel(def.dwarf_lab));
                if def.dbg_state=dbg_state_used then
                  deftowritelist.Add(def);
              end;
            defnumberlist.Add(def);
          end;
        result:=def.dwarf_lab;
      end;

    constructor TDebugInfoDwarf.Create;
      begin
        inherited Create;
        isdwarf64 := target_cpu in [cpu_iA64,cpu_x86_64,cpu_powerpc64];
        dirlist := tdictionary.Create;
        { add current dir as first item (index=0) }
        dirlist.insert(TDirIndexItem.Create('.', 0));
        asmline := TAsmList.create;
        loclist := tdynamicarray.Create(4096);
      end;

    destructor TDebugInfoDwarf.Destroy;
      begin
        dirlist.Free;
        dirlist := nil;
        loclist.Free;
        loclist := nil;
        inherited Destroy;
      end;

    procedure TDebugInfoDwarf.enum_membersyms_callback(p: Tnamedindexitem; arg: pointer);
      begin
        case tsym(p).typ of
          fieldvarsym:
            appendsym_fieldvar(tfieldvarsym(p));
          propertysym:
            appendsym_property(tpropertysym(p));
          procsym:
            appendsym_proc(tprocsym(p));
        end;
      end;

    function TDebugInfoDwarf.get_file_index(afile: tinputfile): Integer;
      var
        dirname: String;
        diritem: TDirIndexItem;
        diridx: Integer;
        fileitem: TFileIndexItem;
      begin
        if afile.path^ = '' then
          dirname := '.'
        else
          dirname := afile.path^;

        diritem := TDirIndexItem(dirlist.search(dirname));
        if diritem = nil then
          begin
            diritem := TDirIndexItem.Create(dirname, dirlist.Count);
            diritem := TDirIndexItem(dirlist.insert(diritem));
          end;
        diridx := diritem.IndexNr;

        fileitem := TFileIndexItem(diritem.files.search(afile.name^));
        if fileitem = nil then
          begin
            Inc(filesequence);
            fileitem := TFileIndexItem.Create(afile.name^, diridx, filesequence);
            fileitem := TFileIndexItem(diritem.files.insert(fileitem));
          end;

        Result := fileitem.IndexNr;
      end;

    { writing the data through a few simply procedures allows to create easily extra information
      for debugging of debug info }
    procedure TDebugInfoDwarf.append_entry(tag : tdwarf_tag;has_children : boolean;data : array of const);
      var
        i : longint;
      begin
        { todo: store defined abbrevs, so you have to define tehm only once (for this unit) (MWE) }
        inc(currabbrevnumber);

        current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_comment.Create(strpnew('Abbrev '+tostr(currabbrevnumber))));

        { abbrev number }
        current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_uleb128bit(currabbrevnumber));
        current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(currabbrevnumber));
        { tag }
        current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(tag)));

        { children? }
        current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_8bit(ord(has_children)));

        i:=0;
        while i<=high(data) do
          begin
            { attribute }
            if data[i].VType=vtInteger then
              begin
                current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(data[i].VInteger));
              end
            else
              internalerror(200601261);
            inc(i);

            { form }
            if data[i].VType=vtInteger then
              begin
                current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(data[i].VInteger));
              end
            else
              internalerror(200601262);
            inc(i);

            { info itself }
            case tdwarf_form(data[i-1].VInteger) of
              DW_FORM_string:
                case data[i].VType of
                  vtChar:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_string.create(data[i].VChar));
                  vtString:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_string.create(data[i].VString^));
                  vtAnsistring:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_string.create(Ansistring(data[i].VAnsiString)));
                  else
                    internalerror(200601264);
                end;


              DW_FORM_flag:
                current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(byte(data[i].VBoolean)));

              DW_FORM_data1:
                 case data[i].VType of
                  vtInteger:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(data[i].VInteger));
                  vtInt64:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(data[i].VInt64^));
                  vtQWord:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(data[i].VQWord^));
                  else
                    internalerror(200602143);
                end;

              DW_FORM_data2:
                 case data[i].VType of
                  vtInteger:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_16bit(data[i].VInteger));
                  vtInt64:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_16bit(data[i].VInt64^));
                  vtQWord:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_16bit(data[i].VQWord^));
                  else
                    internalerror(200602144);
                end;

              DW_FORM_data4:
                 case data[i].VType of
                  vtInteger:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_32bit(data[i].VInteger));
                  vtInt64:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_32bit(data[i].VInt64^));
                  vtQWord:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_32bit(data[i].VQWord^));
                  else
                    internalerror(200602145);
                end;

              DW_FORM_data8:
                 case data[i].VType of
                  vtInteger:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_64bit(data[i].VInteger));
                  vtInt64:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_64bit(data[i].VInt64^));
                  vtQWord:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_64bit(data[i].VQWord^));
                  else
                    internalerror(200602146);
                end;

              DW_FORM_sdata:
                case data[i].VType of
                  vtInteger:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_sleb128bit(data[i].VInteger));
                  vtInt64:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_sleb128bit(data[i].VInt64^));
                  vtQWord:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_sleb128bit(data[i].VQWord^));
                  else
                    internalerror(200601285);
                end;

              DW_FORM_udata:
                case data[i].VType of
                  vtInteger:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_uleb128bit(data[i].VInteger));
                  vtInt64:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_uleb128bit(data[i].VInt64^));
                  vtQWord:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_uleb128bit(data[i].VQWord^));
                  else
                    internalerror(200601284);
                end;

              { block gets only the size, the rest is appended manually by the caller }
              DW_FORM_block1:
                 case data[i].VType of
                  vtInteger:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(data[i].VInteger));
                  vtInt64:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(data[i].VInt64^));
                  vtQWord:
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(data[i].VQWord^));
                  else
                    internalerror(200602141);
                end;
              else
                internalerror(200601263);
            end;
            inc(i);
          end;
      end;


    procedure TDebugInfoDwarf.append_labelentry(attr : tdwarf_attribute;sym : tasmsymbol);
      begin
        current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(attr)));
        current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(DW_FORM_addr)));
        current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_sym(sym));
      end;


    procedure TDebugInfoDwarf.append_labelentry_ref(attr : tdwarf_attribute;sym : tasmsymbol);
      begin
        current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(attr)));
        current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(DW_FORM_ref_addr)));
        current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_sym(sym));
      end;


    procedure TDebugInfoDwarf.append_labelentry_data(attr : tdwarf_attribute;sym : tasmsymbol);
      begin
        current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(attr)));
        if isdwarf64 then
          current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(DW_FORM_data8)))
        else
          current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(DW_FORM_data4)));
        current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_sym(sym));
      end;


    procedure TDebugInfoDwarf.finish_entry;
      begin
        current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_8bit(0));
        current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_8bit(0));
      end;


    procedure TDebugInfoDwarf.finish_children;
      begin
        current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(0));
      end;

    procedure TDebugInfoDwarf.appenddef_ord(def:torddef);
      begin
        case def.typ of
          s8bit,
          s16bit,
          s32bit :
            begin
              { we should generate a subrange type here }
              if assigned(def.typesym) then
                append_entry(DW_TAG_base_type,false,[
                  DW_AT_name,DW_FORM_string,symname(def.typesym)+#0,
                  DW_AT_encoding,DW_FORM_data1,DW_ATE_signed,
                  DW_AT_byte_size,DW_FORM_data1,def.size
                  ])
              else
                append_entry(DW_TAG_base_type,false,[
                  DW_AT_encoding,DW_FORM_data1,DW_ATE_signed,
                  DW_AT_byte_size,DW_FORM_data1,def.size
                  ]);
              finish_entry;
            end;
          u8bit,
          u16bit,
          u32bit :
            begin
              { we should generate a subrange type here }
              if assigned(def.typesym) then
                append_entry(DW_TAG_base_type,false,[
                  DW_AT_name,DW_FORM_string,symname(def.typesym)+#0,
                  DW_AT_encoding,DW_FORM_data1,DW_ATE_unsigned,
                  DW_AT_byte_size,DW_FORM_data1,def.size
                  ])
              else
                append_entry(DW_TAG_base_type,false,[
                  DW_AT_encoding,DW_FORM_data1,DW_ATE_unsigned,
                  DW_AT_byte_size,DW_FORM_data1,def.size
                  ]);
              finish_entry;
            end;
          uvoid :
            begin
              { gdb 6.4 doesn't support DW_TAG_unspecified_type so we
                replace it with a unsigned type with size 0 (FK)
              }
              append_entry(DW_TAG_base_type,false,[
                DW_AT_name,DW_FORM_string,'Void'#0,
                DW_AT_encoding,DW_FORM_data1,DW_ATE_unsigned,
                DW_AT_byte_size,DW_FORM_data1,0
              ]);
              finish_entry;
            end;
          uchar :
            begin
              append_entry(DW_TAG_base_type,false,[
                DW_AT_name,DW_FORM_string,'Char'#0,
                DW_AT_encoding,DW_FORM_data1,DW_ATE_unsigned_char,
                DW_AT_byte_size,DW_FORM_data1,1
                ]);
              finish_entry;
            end;
          uwidechar :
            begin
              append_entry(DW_TAG_base_type,false,[
                DW_AT_name,DW_FORM_string,'WideChar'#0,
                DW_AT_encoding,DW_FORM_data1,DW_ATE_unsigned_char,
                DW_AT_byte_size,DW_FORM_data1,2
                ]);
              finish_entry;
            end;
          bool8bit :
            begin
              append_entry(DW_TAG_base_type,false,[
                DW_AT_name,DW_FORM_string,'Boolean'#0,
                DW_AT_encoding,DW_FORM_data1,DW_ATE_unsigned_char,
                DW_AT_byte_size,DW_FORM_data1,1
                ]);
              finish_entry;
            end;
          bool16bit :
            begin
              append_entry(DW_TAG_base_type,false,[
                DW_AT_name,DW_FORM_string,'WordBool'#0,
                DW_AT_encoding,DW_FORM_data1,DW_ATE_boolean,
                DW_AT_byte_size,DW_FORM_data1,2
                ]);
              finish_entry;
            end;
          bool32bit :
            begin
              append_entry(DW_TAG_base_type,false,[
                DW_AT_name,DW_FORM_string,'LongBool'#0,
                DW_AT_encoding,DW_FORM_data1,DW_ATE_boolean,
                DW_AT_byte_size,DW_FORM_data1,4
                ]);
              finish_entry;
            end;
          bool64bit :
            begin
              append_entry(DW_TAG_base_type,false,[
                DW_AT_name,DW_FORM_string,'QWordBool'#0,
                DW_AT_encoding,DW_FORM_data1,DW_ATE_boolean,
                DW_AT_byte_size,DW_FORM_data1,8
                ]);
              finish_entry;
            end;
          u64bit :
            begin
              append_entry(DW_TAG_base_type,false,[
                DW_AT_name,DW_FORM_string,'QWord'#0,
                DW_AT_encoding,DW_FORM_data1,DW_ATE_unsigned,
                DW_AT_byte_size,DW_FORM_data1,8
                ]);
              finish_entry;
            end;
          scurrency :
            begin
              { we should use DW_ATE_signed_fixed, however it isn't supported yet by GDB (FK) }
              append_entry(DW_TAG_base_type,false,[
                DW_AT_name,DW_FORM_string,'Currency'#0,
                DW_AT_encoding,DW_FORM_data1,DW_ATE_signed,
                DW_AT_byte_size,DW_FORM_data1,8
                ]);
              finish_entry;
            end;
          s64bit :
            begin
              append_entry(DW_TAG_base_type,false,[
                DW_AT_name,DW_FORM_string,'Int64'#0,
                DW_AT_encoding,DW_FORM_data1,DW_ATE_signed,
                DW_AT_byte_size,DW_FORM_data1,8
                ]);
              finish_entry;
            end;
          else
            internalerror(200601287);
        end;
      end;

    procedure TDebugInfoDwarf.appenddef_float(def:tfloatdef);
      begin
        case def.typ of
          s32real,
          s64real,
          s80real:
            if assigned(def.typesym) then
              append_entry(DW_TAG_base_type,false,[
                DW_AT_name,DW_FORM_string,symname(def.typesym)+#0,
                DW_AT_encoding,DW_FORM_data1,DW_ATE_float,
                DW_AT_byte_size,DW_FORM_data1,def.size
                ])
            else
              append_entry(DW_TAG_base_type,false,[
                DW_AT_encoding,DW_FORM_data1,DW_ATE_float,
                DW_AT_byte_size,DW_FORM_data1,def.size
                ]);
          s64currency:
            { we should use DW_ATE_signed_fixed, however it isn't supported yet by GDB (FK) }
            if assigned(def.typesym) then
              append_entry(DW_TAG_base_type,false,[
                DW_AT_name,DW_FORM_string,symname(def.typesym)+#0,
                DW_AT_encoding,DW_FORM_data1,DW_ATE_signed,
                DW_AT_byte_size,DW_FORM_data1,8
                ])
            else
              append_entry(DW_TAG_base_type,false,[
                DW_AT_encoding,DW_FORM_data1,DW_ATE_signed,
                DW_AT_byte_size,DW_FORM_data1,8
                ]);
          s64comp:
            if assigned(def.typesym) then
              append_entry(DW_TAG_base_type,false,[
                DW_AT_name,DW_FORM_string,symname(def.typesym)+#0,
                DW_AT_encoding,DW_FORM_data1,DW_ATE_signed,
                DW_AT_byte_size,DW_FORM_data1,8
                ])
            else
              append_entry(DW_TAG_base_type,false,[
                DW_AT_encoding,DW_FORM_data1,DW_ATE_signed,
                DW_AT_byte_size,DW_FORM_data1,8
                ]);
          else
            internalerror(200601289);
        end;
        finish_entry;
      end;

    procedure TDebugInfoDwarf.appenddef_formal(def: tformaldef);
      begin
        { implemented in derived classes }
      end;


    procedure TDebugInfoDwarf.appenddef_enum(def:tenumdef);
      var
        hp : tenumsym;
      begin
        if assigned(def.typesym) then
          append_entry(DW_TAG_enumeration_type,true,[
            DW_AT_name,DW_FORM_string,symname(def.typesym)+#0,
            DW_AT_byte_size,DW_FORM_data1,def.size
            ])
        else
          append_entry(DW_TAG_enumeration_type,true,[
            DW_AT_byte_size,DW_FORM_data1,def.size
            ]);
        if assigned(def.basedef) then
          append_labelentry_ref(DW_AT_type,def_dwarf_lab(def.basedef));
        finish_entry;

        { write enum symbols }
        hp:=tenumsym(def.firstenum);
        while assigned(hp) do
          begin
            append_entry(DW_TAG_enumerator,false,[
              DW_AT_name,DW_FORM_string,symname(hp)+#0,
              DW_AT_const_value,DW_FORM_data4,hp.value
            ]);
            finish_entry;
            hp:=tenumsym(hp).nextenum;
          end;

        finish_children;
      end;

    procedure TDebugInfoDwarf.appenddef_file(def: tfiledef);
      begin
        { implemented in derived classes }
      end;


    procedure TDebugInfoDwarf.appenddef_array(def:tarraydef);
      var
        size : aint;
        elesize : aint;
      begin
        if is_special_array(def) then
          size:=def.elesize
        else
          size:=def.size;

        if not is_packed_array(def) then
          elesize := def.elesize*8
        else
          elesize := def.elepackedbitsize;

        if assigned(def.typesym) then
          append_entry(DW_TAG_array_type,true,[
            DW_AT_name,DW_FORM_string,symname(def.typesym)+#0,
            DW_AT_byte_size,DW_FORM_udata,size,
            DW_AT_stride_size,DW_FORM_udata,elesize
            ])
        else
          append_entry(DW_TAG_array_type,true,[
            DW_AT_byte_size,DW_FORM_udata,size,
            DW_AT_stride_size,DW_FORM_udata,elesize
            ]);
        append_labelentry_ref(DW_AT_type,def_dwarf_lab(def.elementtype.def));
        if is_dynamic_array(def) then
          begin
            { !!! FIXME !!! }
            { gdb's dwarf implementation sucks, so we can't use DW_OP_push_object here (FK)
            { insert location attribute manually }
            current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(DW_AT_data_location));
            current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(DW_FORM_block1));
            current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(1));
            current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(DW_OP_push_object));
            current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(DW_OP_deref));
            }

            finish_entry;
            { to simplify things, we don't write a multidimensional array here }
            append_entry(DW_TAG_subrange_type,false,[
              DW_AT_lower_bound,DW_FORM_udata,0,
              DW_AT_upper_bound,DW_FORM_udata,0
              ]);
            append_labelentry_ref(DW_AT_type,def_dwarf_lab(def.rangetype.def));
            finish_entry;
          end
        else
          begin
            finish_entry;
            { to simplify things, we don't write a multidimensional array here }
            append_entry(DW_TAG_subrange_type,false,[
              DW_AT_lower_bound,DW_FORM_sdata,def.lowrange,
              DW_AT_upper_bound,DW_FORM_sdata,def.highrange
              ]);
            append_labelentry_ref(DW_AT_type,def_dwarf_lab(def.rangetype.def));
            finish_entry;
          end;
        finish_children;
      end;


    procedure TDebugInfoDwarf.appenddef_record(def:trecorddef);
      begin
        if assigned(def.typesym) then
          append_entry(DW_TAG_structure_type,true,[
            DW_AT_name,DW_FORM_string,symname(def.typesym)+#0,
            DW_AT_byte_size,DW_FORM_udata,def.size
            ])
        else
          append_entry(DW_TAG_structure_type,true,[
            DW_AT_byte_size,DW_FORM_udata,def.size
            ]);
        finish_entry;
        def.symtable.foreach(@enum_membersyms_callback,nil);
        finish_children;
      end;


    procedure TDebugInfoDwarf.appenddef_pointer(def:tpointerdef);
      begin
        append_entry(DW_TAG_pointer_type,false,[]);
        if not(is_voidpointer(def)) then
          append_labelentry_ref(DW_AT_type,def_dwarf_lab(def.pointertype.def));
        finish_entry;
      end;


    procedure TDebugInfoDwarf.appenddef_string(def:tstringdef);
      var
        slen : aint;
        arr : tasmlabel;
      begin
        case def.string_typ of
          st_shortstring:
            begin
              { fix length of openshortstring }
              slen:=def.len;
              if slen=0 then
                slen:=255;

              { create a structure with two elements }
              current_asmdata.getdatalabel(arr);
              append_entry(DW_TAG_structure_type,true,[
                DW_AT_name,DW_FORM_string,'ShortString'#0,
                DW_AT_byte_size,DW_FORM_data1,2*sizeof(aint)
              ]);
              finish_entry;

              { length entry }
              append_entry(DW_TAG_member,false,[
                DW_AT_name,DW_FORM_string,'Length'#0,
                DW_AT_data_member_location,DW_FORM_block1,1+lengthuleb128(0)
                ]);
              current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(ord(DW_OP_plus_uconst)));
              current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_uleb128bit(0));
              append_labelentry_ref(DW_AT_type,def_dwarf_lab(u8inttype.def));
              finish_entry;

              { string data entry }
              append_entry(DW_TAG_member,false,[
                DW_AT_name,DW_FORM_string,'Data'#0,
                DW_AT_data_member_location,DW_FORM_block1,1+lengthuleb128(1)
                ]);
              current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(ord(DW_OP_plus_uconst)));
              current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_uleb128bit(1));
              append_labelentry_ref(DW_AT_type,arr);
              finish_entry;

              finish_children;

              { now the data array }
              current_asmdata.asmlists[al_dwarf_info].concat(tai_symbol.create(arr,0));
              append_entry(DW_TAG_array_type,true,[
                DW_AT_byte_size,DW_FORM_udata,def.size,
                DW_AT_stride_size,DW_FORM_udata,1*8
                ]);
              append_labelentry_ref(DW_AT_type,def_dwarf_lab(cchartype.def));
              finish_entry;
              append_entry(DW_TAG_subrange_type,false,[
                DW_AT_lower_bound,DW_FORM_udata,0,
                DW_AT_upper_bound,DW_FORM_udata,slen
                ]);
              append_labelentry_ref(DW_AT_type,def_dwarf_lab(u8inttype.def));
              finish_entry;
              finish_children;
            end;
          st_longstring:
            begin
            {
              charst:=def_stab_number(cchartype.def);
              bytest:=def_stab_number(u8inttype.def);
              longst:=def_stab_number(u32inttype.def);
              result:=def_stabstr_evaluate(def,'s$1length:$2,0,32;dummy:$6,32,8;st:ar$2;1;$3;$4,40,$5;;',
                          [tostr(def.len+5),longst,tostr(def.len),charst,tostr(def.len*8),bytest]);
            }
           end;
         st_ansistring:
           begin
             { looks like a pchar }
             append_entry(DW_TAG_pointer_type,false,[]);
             append_labelentry_ref(DW_AT_type,def_dwarf_lab(cchartype.def));
             finish_entry;
           end;
         st_widestring:
           begin
             { looks like a pwidechar }
             append_entry(DW_TAG_pointer_type,false,[]);
             append_labelentry_ref(DW_AT_type,def_dwarf_lab(cwidechartype.def));
             finish_entry;
           end;
        end;
      end;

    procedure TDebugInfoDwarf.appenddef_procvar(def:tprocvardef);

      procedure doappend;
        var
          i : longint;
        begin
          if assigned(def.typesym) then
            append_entry(DW_TAG_subroutine_type,true,[
              DW_AT_name,DW_FORM_string,symname(def.typesym)+#0,
              DW_AT_prototyped,DW_FORM_flag,true
            ])
          else
            append_entry(DW_TAG_subroutine_type,true,[
              DW_AT_prototyped,DW_FORM_flag,true
            ]);
          if not(is_void(tprocvardef(def).rettype.def)) then
            append_labelentry_ref(DW_AT_type,def_dwarf_lab(tprocvardef(def).rettype.def));
          finish_entry;

          { write parameters }
          for i:=0 to def.paras.count-1 do
            begin
              append_entry(DW_TAG_formal_parameter,false,[
                DW_AT_name,DW_FORM_string,symname(tsym(def.paras[i]))+#0
              ]);
              append_labelentry_ref(DW_AT_type,def_dwarf_lab(tparavarsym(def.paras[i]).vartype.def));
              finish_entry;
            end;

          finish_children;
        end;

      var
        proc : tasmlabel;

      begin
        if def.is_methodpointer then
          begin
            { create a structure with two elements }
            current_asmdata.getdatalabel(proc);
            append_entry(DW_TAG_structure_type,true,[
              DW_AT_byte_size,DW_FORM_data1,2*sizeof(aint)
            ]);
            finish_entry;

            { proc entry }
            append_entry(DW_TAG_member,false,[
              DW_AT_name,DW_FORM_string,'Proc'#0,
              DW_AT_data_member_location,DW_FORM_block1,1+lengthuleb128(0)
              ]);
            current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(ord(DW_OP_plus_uconst)));
            current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_uleb128bit(0));
            append_labelentry_ref(DW_AT_type,proc);
            finish_entry;

            { self entry }
            append_entry(DW_TAG_member,false,[
              DW_AT_name,DW_FORM_string,'Self'#0,
              DW_AT_data_member_location,DW_FORM_block1,1+lengthuleb128(sizeof(aint))
              ]);
            current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(ord(DW_OP_plus_uconst)));
            current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_uleb128bit(sizeof(aint)));
            append_labelentry_ref(DW_AT_type,def_dwarf_lab(class_tobject));
            finish_entry;

            finish_children;

            current_asmdata.asmlists[al_dwarf_info].concat(tai_symbol.create(proc,0));
            doappend;
          end
        else
          doappend;
      end;

    procedure TDebugInfoDwarf.appenddef(def:tdef);
      var
        labsym : tasmsymbol;
      begin
        if (def.dbg_state in [dbg_state_writing,dbg_state_written]) then
          exit;

        { never write generic template defs }
        if df_generic in def.defoptions then
          begin
            def.dbg_state:=dbg_state_written;
            exit;
          end;

        { to avoid infinite loops }
        def.dbg_state := dbg_state_writing;

        current_asmdata.asmlists[al_dwarf_info].concat(tai_comment.Create(strpnew('Definition '+def.typename)));
        labsym:=def_dwarf_lab(def);
        if df_has_dwarf_dbg_info in def.defoptions then
          current_asmdata.asmlists[al_dwarf_info].concat(tai_symbol.create_global(labsym,0))
        else
          current_asmdata.asmlists[al_dwarf_info].concat(tai_symbol.create(labsym,0));
          
        case def.deftype of
          stringdef :
            appenddef_string(tstringdef(def));
          enumdef :
            appenddef_enum(tenumdef(def));
          orddef :
            appenddef_ord(torddef(def));
          pointerdef :
            appenddef_pointer(tpointerdef(def));
          floatdef :
            appenddef_float(tfloatdef(def));
          filedef :
            appenddef_file(tfiledef(def));
          recorddef :
            appenddef_record(trecorddef(def));
          variantdef :
            appenddef_variant(tvariantdef(def));
          classrefdef :
            appenddef_pointer(tpointerdef(pvmttype.def));
          setdef :
            appenddef_set(tsetdef(def));
          formaldef :
            appenddef_formal(tformaldef(def));
          arraydef :
            appenddef_array(tarraydef(def));
          procvardef :
            appenddef_procvar(tprocvardef(def));
          objectdef :
            appenddef_object(tobjectdef(def));
          undefineddef :
            appenddef_unineddef(tundefineddef(def));
        else
          internalerror(200601281);
        end;

        def.dbg_state := dbg_state_written;
      end;


    procedure TDebugInfoDwarf.insertdef(unused:TAsmList; def:tdef);
      begin
        appenddef(def);
      end;

    procedure TDebugInfoDwarf.write_symtable_defs(unused:TAsmList;st:tsymtable);

       procedure dowritedwarf(st:tsymtable);
         var
           p : tdef;
         begin
           p:=tdef(st.defindex.first);
           while assigned(p) do
             begin
               if (p.dbg_state=dbg_state_used) then
                 appenddef(p);

               p:=tdef(p.indexnext);
             end;
         end;

      var
        old_writing_def_dwarf : boolean;
      begin
        case st.symtabletype of
          staticsymtable :
            current_asmdata.asmlists[al_dwarf_info].concat(tai_comment.Create(strpnew('Defs - Begin Staticsymtable')));
          globalsymtable :
            current_asmdata.asmlists[al_dwarf_info].concat(tai_comment.Create(strpnew('Defs - Begin unit '+st.name^+' has index '+tostr(st.moduleid))));
        end;
        old_writing_def_dwarf:=writing_def_dwarf;
        writing_def_dwarf:=true;
        dowritedwarf(st);
        writing_def_dwarf:=old_writing_def_dwarf;
        case st.symtabletype of
          staticsymtable :
            current_asmdata.asmlists[al_dwarf_info].concat(tai_comment.Create(strpnew('Defs - End Staticsymtable')));
          globalsymtable :
            current_asmdata.asmlists[al_dwarf_info].concat(tai_comment.Create(strpnew('Defs - End unit '+st.name^+' has index '+tostr(st.moduleid))));
        end;
      end;


    procedure TDebugInfoDwarf.appendprocdef(pd:tprocdef);
      var
        procendlabel : tasmlabel;
        mangled_length : longint;
        p : pchar;
        hs : string;
      begin
        if assigned(pd.procstarttai) then
          begin
            current_asmdata.asmlists[al_dwarf_info].concat(tai_comment.Create(strpnew('Procdef '+pd.fullprocname(true))));
            append_entry(DW_TAG_subprogram,true,
              [DW_AT_name,DW_FORM_string,symname(pd.procsym)+#0
              { data continues below }
              { problem: base reg isn't known here
                DW_AT_frame_base,DW_FORM_block1,1
              }
              ]);
            { append block data }
            { current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(dwarf_reg(pd.))); }

            if not(is_void(tprocdef(pd).rettype.def)) then
              append_labelentry_ref(DW_AT_type,def_dwarf_lab(tprocdef(pd).rettype.def));

            { mark end of procedure }
            current_asmdata.getlabel(procendlabel,alt_dbgtype);
            current_asmdata.asmlists[al_procedures].insertbefore(tai_label.create(procendlabel),pd.procendtai);

            append_labelentry(DW_AT_low_pc,current_asmdata.RefAsmSymbol(pd.mangledname));
            append_labelentry(DW_AT_high_pc,procendlabel);

            {
            if assigned(pd.funcretsym) and
               (tabstractnormalvarsym(pd.funcretsym).refs>0) then
              begin
                if tabstractnormalvarsym(pd.funcretsym).localloc.loc=LOC_REFERENCE then
                  begin
{$warning Need to add gdb support for ret in param register calling}
                    if paramanager.ret_in_param(pd.rettype.def,pd.proccalloption) then
                      hs:='X*'
                    else
                      hs:='X';
                    templist.concat(Tai_stab.create(stab_stabs,strpnew(
                       '"'+pd.procsym.name+':'+hs+def_stab_number(pd.rettype.def)+'",'+
                       tostr(N_tsym)+',0,0,'+tostr(tabstractnormalvarsym(pd.funcretsym).localloc.reference.offset))));
                    if (m_result in aktmodeswitches) then
                      templist.concat(Tai_stab.create(stab_stabs,strpnew(
                         '"RESULT:'+hs+def_stab_number(pd.rettype.def)+'",'+
                         tostr(N_tsym)+',0,0,'+tostr(tabstractnormalvarsym(pd.funcretsym).localloc.reference.offset))));
                  end;
              end;
            }

            finish_entry;
{
            { para types }
            write_def_stabstr(templist,pd);
}

            if assigned(pd.parast) then
              write_symtable_syms(pd.parast);
            { local type defs and vars should not be written
              inside the main proc stab }
            if assigned(pd.localst) and
               (pd.localst.symtabletype=localsymtable) then
              write_symtable_syms(pd.localst);

            { last write the types from this procdef }
            if assigned(pd.parast) then
              write_symtable_defs(nil,pd.parast);
            if assigned(pd.localst) and
               (pd.localst.symtabletype=localsymtable) then
              write_symtable_defs(nil,pd.localst);

            finish_children;
          end;

      end;

      procedure TDebugInfoDwarf.appendsym_var(sym:tabstractnormalvarsym);
        var
          templist : TAsmList;
          blocksize : longint;
          tag : tdwarf_tag;
          dreg : byte;
        begin
          { external symbols can't be resolved at link time, so we
            can't generate stabs for them

            not sure if this applies to dwarf as well (FK)
          }
          if vo_is_external in sym.varoptions then
            exit;

          { There is no space allocated for not referenced locals }
          if (sym.owner.symtabletype=localsymtable) and (sym.refs=0) then
            exit;

          templist:=TAsmList.create;

          case sym.localloc.loc of
            LOC_REGISTER,
            LOC_CREGISTER,
            LOC_MMREGISTER,
            LOC_CMMREGISTER,
            LOC_FPUREGISTER,
            LOC_CFPUREGISTER :
              begin
                templist.concat(tai_const.create_8bit(ord(DW_OP_regx)));
                dreg:=dwarf_reg(sym.localloc.register);
                templist.concat(tai_const.create_uleb128bit(dreg));
                blocksize:=1+Lengthuleb128(dreg);
              end;
            else
              begin
                case sym.typ of
                  globalvarsym:
                    begin
                      if (vo_is_thread_var in sym.varoptions) then
                        begin
{$warning !!! FIXME: dwarf for thread vars !!!}
                          blocksize:=0;
                        end
                      else
                        begin
                          templist.concat(tai_const.create_8bit(3));
                          templist.concat(tai_const.createname(sym.mangledname,0));
                          blocksize:=1+sizeof(aword);
                        end;
                    end;
                  paravarsym,
                  localvarsym:
                    begin
                      dreg:=dwarf_reg(sym.localloc.reference.base);
                      templist.concat(tai_const.create_8bit(ord(DW_OP_breg0)+dreg));
                      templist.concat(tai_const.create_sleb128bit(sym.localloc.reference.offset));
                      blocksize:=1+Lengthsleb128(sym.localloc.reference.offset);
                    end
                  else
                    internalerror(200601288);
                end;
              end;
          end;

          if sym.typ=paravarsym then
            tag:=DW_TAG_formal_parameter
          else
            tag:=DW_TAG_variable;

          append_entry(tag,false,[
            DW_AT_name,DW_FORM_string,symname(sym)+#0,
            {
            DW_AT_decl_file,DW_FORM_data1,0,
            DW_AT_decl_line,DW_FORM_data1,
            }
            DW_AT_external,DW_FORM_flag,true,
            { data continues below }
            DW_AT_location,DW_FORM_block1,blocksize
            ]);
          { append block data }
          current_asmdata.asmlists[al_dwarf_info].concatlist(templist);
          append_labelentry_ref(DW_AT_type,def_dwarf_lab(sym.vartype.def));

          templist.free;

          finish_entry;
        end;


      procedure TDebugInfoDwarf.appendsym_fieldvar(sym: tfieldvarsym);
        begin
          if sp_static in sym.symoptions then Exit;

          append_entry(DW_TAG_member,false,[
            DW_AT_name,DW_FORM_string,symname(sym)+#0,
            DW_AT_data_member_location,DW_FORM_block1,1+lengthuleb128(sym.fieldoffset)
            ]);
          current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(ord(DW_OP_plus_uconst)));
          current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_uleb128bit(sym.fieldoffset));

          append_labelentry_ref(DW_AT_type,def_dwarf_lab(sym.vartype.def));
          finish_entry;
        end;

      procedure TDebugInfoDwarf.appendsym_const(sym:tconstsym);
        begin
          append_entry(DW_TAG_constant,false,[
            DW_AT_name,DW_FORM_string,symname(sym)+#0
            ]);
          { for string constants, consttype isn't set because they have no real type }
          if not(sym.consttyp in [conststring,constresourcestring]) then
            append_labelentry_ref(DW_AT_type,def_dwarf_lab(sym.consttype.def));
          current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(DW_AT_const_value)));
          case sym.consttyp of
            conststring:
              begin
                current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(DW_FORM_string)));
                current_asmdata.asmlists[al_dwarf_info].concat(tai_string.create(strpas(pchar(sym.value.valueptr))));
                current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(0));
              end;
            constset,
            constwstring,
            constguid,
            constresourcestring:
              begin
                { write dummy for now }
                current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(DW_FORM_string)));
                current_asmdata.asmlists[al_dwarf_info].concat(tai_string.create(''));
                current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(0));
              end;
            constord:
              begin
                current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(DW_FORM_sdata)));
                current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_sleb128bit(sym.value.valueord));
              end;
            constnil:
              begin
                if isdwarf64 then
                  begin
                    current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(DW_FORM_data8)));
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_64bit(0));
                  end
                else
                  begin
                    current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(DW_FORM_data4)));
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_32bit(0));
                  end;
              end;
            constpointer:
              begin
                if isdwarf64 then
                  begin
                    current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(DW_FORM_data8)));
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_64bit(sym.value.valueordptr));
                  end
                else
                  begin
                    current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(DW_FORM_data4)));
                    current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_32bit(sym.value.valueordptr));
                  end;
              end;
            constreal:
              begin
                current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_uleb128bit(ord(DW_FORM_block1)));
                case tfloatdef(sym.consttype.def).typ of
                  s32real:
                    begin
                      current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(4));
                      current_asmdata.asmlists[al_dwarf_info].concat(tai_real_32bit.create(psingle(sym.value.valueptr)^));
                    end;
                  s64comp,
                  s64currency,
                  s64real:
                    begin
                      current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(8));
                      current_asmdata.asmlists[al_dwarf_info].concat(tai_real_64bit.create(pdouble(sym.value.valueptr)^));
                    end;
                  s80real:
                    begin
                      current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(10));
                      current_asmdata.asmlists[al_dwarf_info].concat(tai_real_80bit.create(pextended(sym.value.valueptr)^));
                    end;
                  else
                    internalerror(200601291);
                end;
              end;
            else
              internalerror(200601292);
          end;
          finish_entry;
        end;

      procedure TDebugInfoDwarf.appendsym_typedconst(sym: ttypedconstsym);
        begin
          append_entry(DW_TAG_variable,false,[
            DW_AT_name,DW_FORM_string,symname(sym)+#0,
            {
            DW_AT_decl_file,DW_FORM_data1,0,
            DW_AT_decl_line,DW_FORM_data1,
            }
            DW_AT_external,DW_FORM_flag,true,
            { data continues below }
            DW_AT_location,DW_FORM_block1,1+sizeof(aword)
          ]);
          { append block data }
          current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(3));
          current_asmdata.asmlists[al_dwarf_info].concat(tai_const.createname(sym.mangledname,0));
          append_labelentry_ref(DW_AT_type,def_dwarf_lab(sym.typedconsttype.def));

          finish_entry;
        end;

      procedure TDebugInfoDwarf.appendsym_label(sym: tlabelsym);
        begin
          { ignore label syms for now, the problem is that a label sym
            can have more than one label associated e.g. in case of
            an inline procedure expansion }
        end;

      procedure TDebugInfoDwarf.appendsym_proc(sym:tprocsym);
        var
          i : longint;
        begin
          for i:=1 to sym.procdef_count do
            appendprocdef(sym.procdef[i]);
        end;

      procedure TDebugInfoDwarf.appendsym_property(sym: tpropertysym);
        begin
          { ignored for now }
        end;

      procedure TDebugInfoDwarf.appendsym_type(sym: ttypesym);
        begin
          append_entry(DW_TAG_typedef,false,[
            DW_AT_name,DW_FORM_string,symname(sym)+#0
          ]);
          append_labelentry_ref(DW_AT_type,def_dwarf_lab(sym.restype.def));
          finish_entry;
          
          { Moved fom append sym, do we need this (MWE)
          { For object types write also the symtable entries }
          if (sym.typ=typesym) and (ttypesym(sym).restype.def.deftype=objectdef) then
            write_symtable_syms(list,tobjectdef(ttypesym(sym).restype.def).symtable);
          }
        end;

      procedure TDebugInfoDwarf.appendsym_unit(sym: tunitsym);
        begin
          { for now, we ignore unit symbols }
        end;

      procedure TDebugInfoDwarf.appendsym_absolute(sym:tabsolutevarsym);
        var
          templist : TAsmList;
          blocksize : longint;
          symlist : psymlistitem;
        begin
          templist:=TAsmList.create;
          case tabsolutevarsym(sym).abstyp of
            toaddr :
              begin
                 { MWE: replaced ifdef i368 }
                 {
                 if target_cpu = cpu_i386 then
                   begin
                    { in theory, we could write a DW_AT_segment entry here for sym.absseg,
                      however I doubt that gdb supports this (FK) }
                   end;
                 }
                 templist.concat(tai_const.create_8bit(3));
                 templist.concat(tai_const.create_aint(sym.addroffset));
                 blocksize:=1+sizeof(aword);
              end;
            toasm :
              begin
                templist.concat(tai_const.create_8bit(3));
                templist.concat(tai_const.createname(sym.mangledname,0));
                blocksize:=1+sizeof(aword);
              end;
            tovar:
              begin
                symlist:=tabsolutevarsym(sym).ref.firstsym;
                { can we insert the symbol? }
                if assigned(symlist) and
                   (symlist^.sltype=sl_load) then
                  appendsym(symlist^.sym);

                templist.free;
                exit;
              end;
          end;

          append_entry(DW_TAG_variable,false,[
            DW_AT_name,DW_FORM_string,symname(sym)+#0,
            {
            DW_AT_decl_file,DW_FORM_data1,0,
            DW_AT_decl_line,DW_FORM_data1,
            }
            DW_AT_external,DW_FORM_flag,true,
            { data continues below }
            DW_AT_location,DW_FORM_block1,blocksize
            ]);
          { append block data }
          current_asmdata.asmlists[al_dwarf_info].concatlist(templist);
          append_labelentry_ref(DW_AT_type,def_dwarf_lab(sym.vartype.def));

          templist.free;

          finish_entry;
        end;

    procedure TDebugInfoDwarf.appendsym(sym:tsym);
      begin
        if sym.isdbgwritten then
          exit;

        current_asmdata.asmlists[al_dwarf_info].concat(tai_comment.Create(strpnew('Symbol '+symname(sym))));
        case sym.typ of
          globalvarsym :
            appendsym_var(tglobalvarsym(sym));
          unitsym:
            appendsym_unit(tunitsym(sym));
          procsym :
            appendsym_proc(tprocsym(sym));
          labelsym :
            appendsym_label(tlabelsym(sym));
          localvarsym :
            appendsym_var(tlocalvarsym(sym));
          paravarsym :
            appendsym_var(tparavarsym(sym));
          typedconstsym :
            appendsym_typedconst(ttypedconstsym(sym));
          constsym :
            appendsym_const(tconstsym(sym));
          typesym :
            appendsym_type(ttypesym(sym));
          enumsym :
            { ignore enum syms, they are written by the owner }
            ;
          rttisym :
            { ignore rtti syms, they are only of internal use }
            ;
          syssym :
            { ignore sys syms, they are only of internal use }
            ;
          absolutevarsym :
            appendsym_absolute(tabsolutevarsym(sym));
          propertysym :
            appendsym_property(tpropertysym(sym));
          else
            begin
              writeln(ord(sym.typ));
              internalerror(200601242);
            end;
        end;
        sym.isdbgwritten:=true;
      end;


    procedure TDebugInfoDwarf.write_symtable_syms(st:tsymtable);
      var
        p : tsym;
        old_writing_def_dwarf : boolean;
      begin
        old_writing_def_dwarf:=writing_def_dwarf;
        writing_def_dwarf:=false;
        p:=tsym(st.symindex.first);
        while assigned(p) do
          begin
            if (not p.isdbgwritten) then
              appendsym(p);
            p:=tsym(p.indexnext);
          end;
        writing_def_dwarf:=old_writing_def_dwarf;
      end;


    procedure TDebugInfoDwarf.insertmoduleinfo;
      var
        templist: TAsmList;
        linelist: TAsmList;
        lbl: tasmlabel;
        n: Integer;
        ditem: TDirIndexItem;
        fitem: TFileIndexItem;
        dlist, flist: TFPList;
      begin
        { insert .Ltext0 label }
        templist:=TAsmList.create;
        new_section(templist,sec_code,'',0);
        templist.concat(tai_symbol.createname('.Ltext0',AT_DATA,0));
        current_asmdata.asmlists[al_start].insertlist(templist);
        templist.free;

        { insert .Letext0 label }
        templist:=TAsmList.create;
        new_section(templist,sec_code,'',0);
        templist.concat(tai_symbol.createname('.Letext0',AT_DATA,0));
        current_asmdata.asmlists[al_end].insertlist(templist);
        templist.free;

        { insert .Ldebug_abbrev0 label }
        templist:=TAsmList.create;
        new_section(templist,sec_debug_abbrev,'',0);
        templist.concat(tai_symbol.createname('.Ldebug_abbrev0',AT_DATA,0));
        current_asmdata.asmlists[al_start].insertlist(templist);
        templist.free;

        { insert .Ldebug_line0 label }
        templist:=TAsmList.create;
        new_section(templist,sec_debug_line,'',0);
        templist.concat(tai_symbol.createname('.Ldebug_line0',AT_DATA,0));
        current_asmdata.asmlists[al_start].insertlist(templist);
        templist.free;

        { debug line header }
        linelist := current_asmdata.asmlists[al_dwarf_line];
        new_section(linelist,sec_debug_line,'',0);
        linelist.concat(tai_comment.Create(strpnew('=== header start ===')));

        { size }
        current_asmdata.getlabel(lbl,alt_dbgfile);
        { currently we create only 32 bit dwarf }
        linelist.concat(tai_const.create_rel_sym(aitconst_32bit,
          lbl,tasmsymbol.create('.Ledebug_line0',AB_COMMON,AT_DATA)));

        linelist.concat(tai_label.create(lbl));

        { version }
        linelist.concat(tai_const.create_16bit(dwarf_version));

        { header length }
        current_asmdata.getlabel(lbl,alt_dbgfile);
        { currently we create only 32 bit dwarf }
        linelist.concat(tai_const.create_rel_sym(aitconst_32bit,
          lbl,tasmsymbol.create('.Lehdebug_line0',AB_COMMON,AT_DATA)));

        linelist.concat(tai_label.create(lbl));

        { minimum_instruction_length }
        linelist.concat(tai_const.create_8bit(1));

        { default_is_stmt }
        linelist.concat(tai_const.create_8bit(1));

        { line_base }
        linelist.concat(tai_const.create_8bit(LINE_BASE));

        { line_range }
        { only line increase, no adress }
        linelist.concat(tai_const.create_8bit(255));

        { opcode_base }
        linelist.concat(tai_const.create_8bit(OPCODE_BASE));

        { standard_opcode_lengths }
        { MWE: sigh... why adding the default lengths (and make those sizes sense with LEB encoding) }
          { DW_LNS_copy }
        linelist.concat(tai_const.create_8bit(0));
          { DW_LNS_advance_pc }
        linelist.concat(tai_const.create_8bit(1));
          { DW_LNS_advance_line }
        linelist.concat(tai_const.create_8bit(1));
          { DW_LNS_set_file }
        linelist.concat(tai_const.create_8bit(1));
          { DW_LNS_set_column }
        linelist.concat(tai_const.create_8bit(1));
          { DW_LNS_negate_stmt }
        linelist.concat(tai_const.create_8bit(0));
          { DW_LNS_set_basic_block }
        linelist.concat(tai_const.create_8bit(0));
          { DW_LNS_const_add_pc }
        linelist.concat(tai_const.create_8bit(0));
          { DW_LNS_fixed_advance_pc }
        linelist.concat(tai_const.create_8bit(1));
          { DW_LNS_set_prologue_end }
        linelist.concat(tai_const.create_8bit(0));
          { DW_LNS_set_epilogue_begin }
        linelist.concat(tai_const.create_8bit(0));
          { DW_LNS_set_isa }
        linelist.concat(tai_const.create_8bit(1));

        { generate directory and filelist}
        dlist := TFPList.Create;
        flist := TFPList.Create;

        dirlist.foreach_static(@AddNamedIndexToList, dlist);
        dlist.Sort(@DirListSortCompare);
        { include_directories }
        linelist.concat(tai_comment.Create(strpnew('include_directories')));
          { list }
        for n := 0 to dlist.Count - 1 do
        begin
          ditem := TDirIndexItem(dlist[n]);
          ditem.Files.foreach_static(@AddNamedIndexToList, flist);
          if ditem.Name = '.' then Continue;

          linelist.concat(tai_string.create(ditem.Name+#0));
        end;
          { end of list }
        linelist.concat(tai_const.create_8bit(0));

        { file_names }
        linelist.concat(tai_comment.Create(strpnew('file_names')));
          { list }
        flist.Sort(@FileListSortCompare);
        for n := 0 to flist.Count - 1 do
        begin
          fitem := TFileIndexItem(flist[n]);
          { file name }
          linelist.concat(tai_string.create(fitem.Name+#0));
          { directory index }
          linelist.concat(tai_const.create_uleb128bit(fitem.DirIndex));
          { last modification }
          linelist.concat(tai_const.create_uleb128bit(0));
          { file length }
          linelist.concat(tai_const.create_uleb128bit(0));
        end;
          { end of list }
        linelist.concat(tai_const.create_8bit(0));

        dlist.free;
        flist.free;

        { end of debug line header }
        linelist.concat(tai_symbol.createname('.Lehdebug_line0',AT_DATA,0));
        linelist.concat(tai_comment.Create(strpnew('=== header end ===')));

        { add line program }
        linelist.concatList(asmline);

        { end of debug line table }
        linelist.concat(tai_symbol.createname('.Ledebug_line0',AT_DATA,0));
      end;


    procedure TDebugInfoDwarf.inserttypeinfo;

      procedure write_defs_to_write;
        var
          n       : integer;
          looplist,
          templist: TFPObjectList;
          def     : tdef;
        begin
          templist := TFPObjectList.Create(False);
          looplist := deftowritelist;
          while looplist.count > 0 do
            begin
              deftowritelist := templist;
              for n := 0 to looplist.count - 1 do
                begin
                  def := tdef(looplist[n]);
                  case def.dbg_state of
                    dbg_state_written:
                      continue;
                    dbg_state_writing:
                      internalerror(200610052);
                    dbg_state_unused:
                      internalerror(200610053);
                    dbg_state_used:
                      appenddef(def)
                  else
                    internalerror(200610054);
                  end;
                end;
              looplist.clear;
              templist := looplist;
              looplist := deftowritelist;
            end;
          templist.free;
        end;

    
      var
        storefilepos  : tfileposinfo;
        lenstartlabel : tasmlabel;
        i : longint;
        def: tdef;
      begin
        storefilepos:=aktfilepos;
        aktfilepos:=current_module.mainfilepos;

        currabbrevnumber:=0;
        writing_def_dwarf:=false;

        { not used (MWE)
        nextdefnumber:=0;
        }
        defnumberlist:=TFPObjectList.create(false);
        deftowritelist:=TFPObjectList.create(false);

        { not exported (FK)
        filerecdef:=gettypedef('FILEREC');
        textrecdef:=gettypedef('TEXTREC');
        }
        vardatadef:=trecorddef(search_system_type('TVARDATA').restype.def);

        { write start labels }
        current_asmdata.asmlists[al_dwarf_info].concat(tai_section.create(sec_debug_info,'',0));
        current_asmdata.asmlists[al_dwarf_info].concat(tai_symbol.createname('.Ldebug_info0',AT_DATA,0));

        { start abbrev section }
        new_section(current_asmdata.asmlists[al_dwarf_abbrev],sec_debug_abbrev,'',0);

        { debug info header }
        current_asmdata.getlabel(lenstartlabel,alt_dbgfile);
        { size }
        { currently we create only 32 bit dwarf }
        current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_rel_sym(aitconst_32bit,
          lenstartlabel,tasmsymbol.create('.Ledebug_info0',AB_COMMON,AT_DATA)));

        current_asmdata.asmlists[al_dwarf_info].concat(tai_label.create(lenstartlabel));
        { version }
        current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_16bit(dwarf_version));
        { abbrev table (=relative from section start)}
        if isdwarf64 then
          current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_type_sym(aitconst_64bit,
            current_asmdata.RefAsmSymbol('.Ldebug_abbrev0')))
        else
          current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_type_sym(aitconst_32bit,
            current_asmdata.RefAsmSymbol('.Ldebug_abbrev0')));
        { address size }
        current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(sizeof(aint)));

        append_entry(DW_TAG_compile_unit,true,[
          DW_AT_name,DW_FORM_string,FixFileName(current_module.sourcefiles.get_file(1).name^)+#0,
          DW_AT_producer,DW_FORM_string,'Free Pascal '+full_version_string+' '+date_string+#0,
          DW_AT_comp_dir,DW_FORM_string,BsToSlash(FixPath(current_module.sourcefiles.get_file(1).path^,false))+#0,
          DW_AT_language,DW_FORM_data1,DW_LANG_Pascal83,
          DW_AT_identifier_case,DW_FORM_data1,DW_ID_case_insensitive]);

        { reference to line info section }
        append_labelentry_data(DW_AT_stmt_list,current_asmdata.RefAsmSymbol('.Ldebug_line0'));
        append_labelentry(DW_AT_low_pc,current_asmdata.RefAsmSymbol('.Ltext0'));
        append_labelentry(DW_AT_high_pc,current_asmdata.RefAsmSymbol('.Letext0'));

        finish_entry;

        { first write all global/local symbols. This will flag all required tdefs }
        if assigned(current_module.globalsymtable) then
          begin
            current_asmdata.asmlists[al_dwarf_info].concat(tai_comment.Create(strpnew('Syms - Begin unit '+current_module.globalsymtable.name^+' has index '+tostr(current_module.globalsymtable.moduleid))));
            write_symtable_syms(current_module.globalsymtable);
            current_asmdata.asmlists[al_dwarf_info].concat(tai_comment.Create(strpnew('Syms - End unit '+current_module.globalsymtable.name^+' has index '+tostr(current_module.globalsymtable.moduleid))));
          end;
        if assigned(current_module.localsymtable) then
          begin
            current_asmdata.asmlists[al_dwarf_info].concat(tai_comment.Create(strpnew('Syms - Begin Staticsymtable')));
            write_symtable_syms(current_module.localsymtable);
            current_asmdata.asmlists[al_dwarf_info].concat(tai_comment.Create(strpnew('Syms - End Staticsymtable')));
          end;

        { reset unit type info flag }
        reset_unit_type_info;

        { write used types from the used units }
        write_used_unit_type_info(current_asmdata.asmlists[al_dwarf_info],current_module);

        { last write the types from this unit }
        if assigned(current_module.globalsymtable) then
          write_symtable_defs(current_asmdata.asmlists[al_dwarf_info],current_module.globalsymtable);
        if assigned(current_module.localsymtable) then
          write_symtable_defs(current_asmdata.asmlists[al_dwarf_info],current_module.localsymtable);
          
        { write defs not written yet }
        write_defs_to_write;

        { close compilation unit entry }
        finish_children;

        { end of debug info table }
        current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(0));
        current_asmdata.asmlists[al_dwarf_info].concat(tai_symbol.createname('.Ledebug_info0',AT_DATA,0));

        { end of abbrev table }
        current_asmdata.asmlists[al_dwarf_abbrev].concat(tai_const.create_8bit(0));

        { reset all def labels }
        for i:=0 to defnumberlist.count-1 do
          begin
            def := tdef(defnumberlist[i]);
            if assigned(def) then
              begin
                def.dwarf_lab:=nil;
                def.dbg_state:=dbg_state_unused;
              end;
          end;

        defnumberlist.free;
        defnumberlist:=nil;
        deftowritelist.free;
        deftowritelist:=nil;
        
        aktfilepos:=storefilepos;
      end;


    procedure TDebugInfoDwarf.referencesections(list:TAsmList);
      begin
      end;

    function TDebugInfoDwarf.symname(sym: tsym): String;
      begin
        result := sym.Name;
      end;


    procedure TDebugInfoDwarf.insertlineinfo(list:TAsmList);
      var
        currfileinfo,
        lastfileinfo : tfileposinfo;
        currfuncname : pstring;
        currsectype  : TAsmSectiontype;
        hlabel       : tasmlabel;
        hp : tai;
        infile : tinputfile;
        current_file : tai_file;
        prevcolumn,
        diffline,
        prevline,
        prevfileidx,
        currfileidx: Integer;
        prevlabel,
        currlabel     : tasmlabel;
      begin
        FillChar(lastfileinfo,sizeof(lastfileinfo),0);
        currfuncname:=nil;
        currsectype:=sec_code;
        hp:=Tai(list.first);
        prevcolumn := 0;
        prevline := 1;
        prevfileidx := 1;
        prevlabel := nil;
        while assigned(hp) do
          begin
            case hp.typ of
              ait_section :
                currsectype:=tai_section(hp).sectype;
              ait_function_name :
                begin
                  currfuncname:=tai_function_name(hp).funcname;
                  asmline.concat(tai_comment.Create(strpnew('function: '+currfuncname^)));
                end;
              ait_force_line : begin
                lastfileinfo.line:=-1;
              end;
            end;

            if (currsectype=sec_code) and
               (hp.typ=ait_instruction) then
              begin
                currfileinfo:=tailineinfo(hp).fileinfo;
                { file changed ? (must be before line info) }
                if (currfileinfo.fileindex<>0) and
                   (lastfileinfo.fileindex<>currfileinfo.fileindex) then
                  begin
                    infile:=current_module.sourcefiles.get_file(currfileinfo.fileindex);
                    if assigned(infile) then
                      begin
                        currfileidx := get_file_index(infile);
                        if prevfileidx <> currfileidx then
                          begin
                            list.insertbefore(tai_comment.Create(strpnew('path: '+infile.path^)), hp);
                            list.insertbefore(tai_comment.Create(strpnew('file: '+infile.name^)), hp);
                            list.insertbefore(tai_comment.Create(strpnew('indx: '+tostr(currfileidx))), hp);

                            { set file }
                            asmline.concat(tai_comment.Create(strpnew('path: '+infile.path^)));
                            asmline.concat(tai_comment.Create(strpnew('file: '+infile.name^)));
                            asmline.concat(tai_const.create_8bit(DW_LNS_set_file));
                            asmline.concat(tai_const.create_uleb128bit(currfileidx));

                            prevfileidx := currfileidx;
                          end;
                        { force new line info }
                        lastfileinfo.line:=-1;
                      end;
                  end;

                { line changed ? }
                if (lastfileinfo.line<>currfileinfo.line) and (currfileinfo.line<>0) then
                  begin
                    { set address }
                    current_asmdata.getlabel(currlabel, alt_dbgline);
                    list.insertbefore(tai_label.create(currlabel), hp);

                    asmline.concat(tai_comment.Create(strpnew('['+tostr(currfileinfo.line)+':'+tostr(currfileinfo.column)+']')));

                    if prevlabel = nil then
                      begin
                        asmline.concat(tai_const.create_8bit(DW_LNS_extended_op));
                        if isdwarf64 then
                          asmline.concat(tai_const.create_uleb128bit(9))  { 1 + 8 }
                        else
                          asmline.concat(tai_const.create_uleb128bit(5)); { 1 + 4 }
                        asmline.concat(tai_const.create_8bit(DW_LNE_set_address));
                        if isdwarf64 then
                          asmline.concat(tai_const.create_type_sym(aitconst_64bit, currlabel))
                        else
                          asmline.concat(tai_const.create_type_sym(aitconst_32bit, currlabel));
                      end
                    else
                      begin
                        asmline.concat(tai_const.create_8bit(DW_LNS_advance_pc));
                        asmline.concat(tai_const.create_rel_sym(aitconst_uleb128bit, prevlabel, currlabel));
                      end;
                    prevlabel := currlabel;

                    { set column }
                    if prevcolumn <> currfileinfo.column then
                      begin
                        asmline.concat(tai_const.create_8bit(DW_LNS_set_column));
                        asmline.concat(tai_const.create_uleb128bit(currfileinfo.column));
                        prevcolumn := currfileinfo.column;
                      end;

                    { set line }
                    diffline := currfileinfo.line - prevline;
                    if (diffline >= LINE_BASE) and (OPCODE_BASE + diffline - LINE_BASE <= 255) then
                      begin
                        { use special opcode, this also adds a row }
                        asmline.concat(tai_const.create_8bit(OPCODE_BASE + diffline - LINE_BASE));
                      end
                    else
                      begin
                        if diffline <> 0 then
                          begin
                            asmline.concat(tai_const.create_8bit(DW_LNS_advance_line));
                            asmline.concat(tai_const.create_sleb128bit(diffline));
                          end;
                        { no row added yet, do it manually }
                        asmline.concat(tai_const.create_8bit(DW_LNS_copy));
                      end;
                    prevline := currfileinfo.line;
                  end;

                lastfileinfo:=currfileinfo;
              end;

            hp:=tai(hp.next);
          end;

        { end sequence }
        asmline.concat(tai_const.Create_8bit(DW_LNS_extended_op));
        asmline.concat(tai_const.Create_8bit(1));
        asmline.concat(tai_const.Create_8bit(DW_LNE_end_sequence));
        asmline.concat(tai_comment.Create(strpnew('###################')));
      end;


{****************************************************************************
                              TDebugInfoDwarf2

****************************************************************************}

    procedure TDebugInfoDwarf2.appenddef_file(def: tfiledef);
      begin
        { gdb 6.4 doesn't support files so far so we use some fake recorddef
          file recs. are less than 1k so using data2 is enough }
        if assigned(def.typesym) then
          append_entry(DW_TAG_structure_type,false,[
           DW_AT_name,DW_FORM_string,symname(def.typesym)+#0,
           DW_AT_byte_size,DW_FORM_udata,def.size
          ])
        else
          append_entry(DW_TAG_structure_type,false,[
           DW_AT_byte_size,DW_FORM_udata,def.size
          ]);
        finish_entry;
      end;

    procedure TDebugInfoDwarf2.appenddef_formal(def: tformaldef);
      begin
        { gdb 6.4 doesn't support DW_TAG_unspecified_type so we
          replace it with a unsigned type with size 0 (FK)
        }
        append_entry(DW_TAG_base_type,false,[
          DW_AT_name,DW_FORM_string,'FormalDef'#0,
          DW_AT_encoding,DW_FORM_data1,DW_ATE_unsigned,
          DW_AT_byte_size,DW_FORM_data1,0
        ]);
        finish_entry;
      end;

    procedure TDebugInfoDwarf2.appenddef_object(def: tobjectdef);
      procedure doappend;
        begin
          if assigned(def.objname) then
            append_entry(DW_TAG_structure_type,true,[
              DW_AT_name,DW_FORM_string,def.objname^+#0,
              DW_AT_byte_size,DW_FORM_udata,def.size
              ])
          else
            append_entry(DW_TAG_structure_type,true,[
              DW_AT_byte_size,DW_FORM_udata,def.size
              ]);
          finish_entry;
          if assigned(def.childof) then
            begin
              append_entry(DW_TAG_inheritance,false,[
                DW_AT_accessibility,DW_FORM_data1,DW_ACCESS_public,
                DW_AT_data_member_location,DW_FORM_block1,1+lengthuleb128(0)
              ]);
              current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(ord(DW_OP_plus_uconst)));
              current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_uleb128bit(0));
              append_labelentry_ref(DW_AT_type,def_dwarf_lab(def.childof));
              finish_entry;
            end;

          def.symtable.foreach(@enum_membersyms_callback,nil);
          finish_children;
        end;


      var
        obj : tasmlabel;

      begin
        case def.objecttype of
          odt_cppclass,
          odt_object:
            doappend;
          odt_interfacecom,
          odt_interfacecorba,
          odt_dispinterface,
          odt_class:
            begin
              current_asmdata.getdatalabel(obj);
              { implicit pointer }
              append_entry(DW_TAG_pointer_type,false,[]);
              append_labelentry_ref(DW_AT_type,obj);
              finish_entry;

              current_asmdata.asmlists[al_dwarf_info].concat(tai_symbol.create(obj,0));
              doappend;
            end;
          else
            internalerror(200602041);
        end;
      end;

    procedure TDebugInfoDwarf2.appenddef_set(def: tsetdef);
      begin
        { at least gdb up to 6.4 doesn't support sets in dwarf, there is a patch available to fix this:
          http://sources.redhat.com/ml/gdb-patches/2005-05/msg00278.html (FK) }

        if assigned(def.typesym) then
          append_entry(DW_TAG_base_type,false,[
            DW_AT_name,DW_FORM_string,symname(def.typesym)+#0,
            DW_AT_encoding,DW_FORM_data1,DW_ATE_unsigned,
            DW_AT_byte_size,DW_FORM_data2,def.size
            ])
        else
          append_entry(DW_TAG_base_type,false,[
            DW_AT_encoding,DW_FORM_data1,DW_ATE_unsigned,
            DW_AT_byte_size,DW_FORM_data2,def.size
            ]);
        finish_entry;
      end;

    procedure TDebugInfoDwarf2.appenddef_unineddef(def: tundefineddef);
      begin
        { gdb 6.4 doesn't support DW_TAG_unspecified_type so we
          replace it with a unsigned type with size 0 (FK)
        }
        append_entry(DW_TAG_base_type,false,[
          DW_AT_name,DW_FORM_string,'FormalDef'#0,
          DW_AT_encoding,DW_FORM_data1,DW_ATE_unsigned,
          DW_AT_byte_size,DW_FORM_data1,0
        ]);
        finish_entry;
      end;

    procedure TDebugInfoDwarf2.appenddef_variant(def: tvariantdef);
      begin
        { variants aren't known to dwarf2 but writting tvardata should be enough }
        appenddef_record(trecorddef(vardatadef));
      end;

    function TDebugInfoDwarf2.dwarf_version: Word;
      begin
        Result:=2;
      end;

{****************************************************************************
                              TDebugInfoDwarf3
****************************************************************************}

    procedure TDebugInfoDwarf3.appenddef_file(def: tfiledef);
      begin
        if assigned(def.typesym) then
          append_entry(DW_TAG_file_type,false,[
            DW_AT_name,DW_FORM_string,symname(def.typesym)+#0,
            DW_AT_byte_size,DW_FORM_data2,def.size
            ])
        else
          append_entry(DW_TAG_file_type,false,[
            DW_AT_byte_size,DW_FORM_data2,def.size
            ]);
        if tfiledef(def).filetyp=ft_typed then
          append_labelentry_ref(DW_AT_type,def_dwarf_lab(tfiledef(def).typedfiletype.def));
        finish_entry;
      end;

    procedure TDebugInfoDwarf3.appenddef_formal(def: tformaldef);
      begin
        append_entry(DW_TAG_unspecified_type,false,[
          ]);
        finish_entry;
      end;

    procedure TDebugInfoDwarf3.appenddef_object(def: tobjectdef);

      procedure dostruct(tag: tdwarf_tag);
        begin
          if assigned(def.objname) then
            append_entry(tag,true,[
              DW_AT_name,DW_FORM_string,def.objrealname^+#0,
              DW_AT_byte_size,DW_FORM_udata,def.size
              ])
          else
            append_entry(DW_TAG_structure_type,true,[
              DW_AT_byte_size,DW_FORM_udata,def.size
              ]);
          finish_entry;
        end;

      procedure doimplicitpointer;
        var
          obj : tasmlabel;
        begin
          current_asmdata.getdatalabel(obj);
          { implicit pointer }
          append_entry(DW_TAG_pointer_type,false,[]);
          append_labelentry_ref(DW_AT_type,obj);
          finish_entry;

          current_asmdata.asmlists[al_dwarf_info].concat(tai_symbol.create(obj,0));
        end;

      procedure doparent(isinterface: boolean);
        begin
          if not assigned(def.childof) then
            exit;

          if isinterface then
            begin
              append_entry(DW_TAG_inheritance,false,[]);
            end
          else
            begin
              append_entry(DW_TAG_inheritance,false,[
                DW_AT_accessibility,DW_FORM_data1,DW_ACCESS_public,
                DW_AT_data_member_location,DW_FORM_block1,1+lengthuleb128(0)
              ]);
              current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_8bit(ord(DW_OP_plus_uconst)));
              current_asmdata.asmlists[al_dwarf_info].concat(tai_const.create_uleb128bit(0));
            end;
          append_labelentry_ref(DW_AT_type,def_dwarf_lab(def.childof));
          finish_entry;
        end;

      var
        n: integer;

      begin
        case def.objecttype of
          odt_cppclass,
          odt_object:
            begin
              dostruct(DW_TAG_structure_type);
              doparent(false);
            end;
          odt_interfacecom,
          odt_interfacecorba,
          odt_dispinterface:
            begin
              dostruct(DW_TAG_interface_type);
              doparent(true);
            end;
          odt_class:
            begin
              { not sure if the implicit pointer is needed for tag_class (MWE)}
              {
              doimplicitpointer;
              }
              dostruct(DW_TAG_class_type);
              doparent(false);
            end;
        else
          internalerror(200609171);
        end;

        { add implemented interfaces }
        if assigned(def.implementedinterfaces) then
          for n := 1 to def.implementedinterfaces.count do
            begin
              append_entry(DW_TAG_inheritance,false,[]);
              append_labelentry_ref(DW_AT_type,def_dwarf_lab(def.implementedinterfaces.interfaces(n)));
              finish_entry;
            end;

        { add members }
        def.symtable.foreach(@enum_membersyms_callback,nil);
        finish_children;
      end;

    procedure TDebugInfoDwarf3.appenddef_set(def: tsetdef);
      begin
        if assigned(def.typesym) then
          append_entry(DW_TAG_set_type,false,[
            DW_AT_name,DW_FORM_string,symname(def.typesym)+#0,
            DW_AT_byte_size,DW_FORM_data2,def.size
            ])
        else
          append_entry(DW_TAG_set_type,false,[
            DW_AT_byte_size,DW_FORM_data2,def.size
            ]);
        if assigned(tsetdef(def).elementtype.def) then
          append_labelentry_ref(DW_AT_type,def_dwarf_lab(tsetdef(def).elementtype.def));
        finish_entry;
      end;

    procedure TDebugInfoDwarf3.appenddef_unineddef(def: tundefineddef);
      begin
        { ??? can a undefined def have a typename ? }
        if assigned(def.typesym) then
          append_entry(DW_TAG_unspecified_type,false,[
            DW_AT_name,DW_FORM_string,symname(def.typesym)+#0
            ])
        else
          append_entry(DW_TAG_unspecified_type,false,[
            ]);
        finish_entry;
      end;

    procedure TDebugInfoDwarf3.appenddef_variant(def: tvariantdef);
      const
        VARIANTS: array[1..27] of record Value: Word; Name: String end = (
          (value:0;     name:''),
          (value:1;     name:''),
          (value:2;     name:'VSMALLINT'),
          (value:3;     name:'VINTEGER'),
          (value:4;     name:'VSINGLE'),
          (value:5;     name:'VDOUBLE'),
          (value:6;     name:'VCURRENCY'),
          (value:7;     name:'VDATE'),
          (value:8;     name:'VOLESTR'),
          (value:9;     name:'VDISPATCH'),
          (value:10;    name:'VERROR'),
          (value:11;    name:'VBOOLEAN'),
          (value:12;    name:''),
          (value:13;    name:'VUNKNOWN'),
          (value:14;    name:''),
          (value:16;    name:'VSHORTINT'),
          (value:17;    name:'VBYTE'),
          (value:18;    name:'VWORD'),
          (value:19;    name:'VLONGWORD'),
          (value:20;    name:'VINT64'),
          (value:21;    name:'VQWORD'),
          (value:36;    name:'VRECORD'),
          (value:$48;   name:''),
          (value:$100;  name:'VSTRING'),
          (value:$101;  name:'VANY'),
          (value:$2000; name:'VARRAY'),
          (value:$4000; name:'VPOINTER')
        );
      var
        fs: tfieldvarsym;
        lbl: tasmlabel;
        idx: integer;
      begin
        { it could be done with DW_TAG_variant for the union part (if that info was available)
          now we do it manually for variants (MWE) }

        { struct }
        append_entry(DW_TAG_structure_type,true,[
          DW_AT_name,DW_FORM_string,'Variant'#0,
          DW_AT_byte_size,DW_FORM_udata,vardatadef.size
          ]);
        finish_entry;

        append_entry(DW_TAG_variant_part,true,[
          ]);
        current_asmdata.getaddrlabel(lbl);
        append_labelentry_ref(DW_AT_discr,lbl);
        finish_entry;

        { discriminant }
        fs := tfieldvarsym(vardatadef.symtable.search('VTYPE'));
        if (fs = nil) or (fs.typ <> fieldvarsym) then
          internalerror(200609271);
        current_asmdata.asmlists[al_dwarf_info].concat(tai_symbol.create(lbl,0));
        appendsym_fieldvar(fs);

        { variants }
        for idx := Low(VARIANTS) to High(VARIANTS) do
          begin
            append_entry(DW_TAG_variant,true,[
              DW_AT_discr_value,DW_FORM_udata,VARIANTS[idx].value
              ]);
            finish_entry;

            if VARIANTS[idx].name <> '' then
              begin
                fs := tfieldvarsym(vardatadef.symtable.search(VARIANTS[idx].name));
                if (fs = nil) or (fs.typ <> fieldvarsym) then
                  internalerror(20060927200+idx);
                appendsym_fieldvar(fs);
              end;

            finish_children; { variant }
          end;


        finish_children; { variant part }

        finish_children; { struct }
      end;

    function TDebugInfoDwarf3.dwarf_version: Word;
      begin
        Result:=3;
      end;

    function TDebugInfoDwarf3.symname(sym: tsym): String;
      begin
        Result:=sym.realname;
      end;



{****************************************************************************
****************************************************************************}
    const
      dbg_dwarf2_info : tdbginfo =
         (
           id     : dbg_dwarf2;
           idtxt  : 'DWARF2';
         );

      dbg_dwarf3_info : tdbginfo =
         (
           id     : dbg_dwarf3;
           idtxt  : 'DWARF3';
         );

initialization
  RegisterDebugInfo(dbg_dwarf2_info,TDebugInfoDwarf2);
  RegisterDebugInfo(dbg_dwarf3_info,TDebugInfoDwarf3);
end.
