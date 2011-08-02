{
    Copyright (c) 1998-2002 by Florian Klaempfl

    Does declaration (but not type) parsing for Free Pascal

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
unit pdecl;

{$i fpcdefs.inc}

interface

    uses
      { common }
      cclasses,
      { global }
      globtype,
      { symtable }
      symsym,symdef,
      { pass_1 }
      node;

    function  readconstant(const orgname:string;const filepos:tfileposinfo):tconstsym;

    procedure const_dec;
    procedure consts_dec(in_structure: boolean);
    procedure label_dec;
    procedure type_dec;
    procedure types_dec(in_structure: boolean);
    procedure var_dec;
    procedure threadvar_dec;
    procedure property_dec(is_classpropery: boolean);
    procedure resourcestring_dec;

    { generics support }
    function parse_generic_parameters:TFPObjectList;
    procedure insert_generic_parameter_types(def:tstoreddef;genericdef:tstoreddef;genericlist:TFPObjectList);

implementation

    uses
       SysUtils,
       { common }
       cutils,
       { global }
       globals,tokens,verbose,widestr,constexp,
       systems,
       { aasm }
       aasmbase,aasmtai,aasmdata,fmodule,
       { symtable }
       symconst,symbase,symtype,symtable,paramgr,defutil,
       { pass 1 }
       nmat,nadd,ncal,nset,ncnv,ninl,ncon,nld,nflw,nobj,
       { codegen }
       ncgutil,
       { parser }
       scanner,
       pbase,pexpr,ptype,ptconst,pdecsub,pdecvar,pdecobj,
       { cpu-information }
       cpuinfo
       ;


    function readconstant(const orgname:string;const filepos:tfileposinfo):tconstsym;
      var
        hp : tconstsym;
        p : tnode;
        ps : pconstset;
        pd : pbestreal;
        pg : pguid;
        sp : pchar;
        pw : pcompilerwidestring;
        storetokenpos : tfileposinfo;
      begin
        readconstant:=nil;
        if orgname='' then
         internalerror(9584582);
        hp:=nil;
        p:=comp_expr(true,false);
        storetokenpos:=current_tokenpos;
        current_tokenpos:=filepos;
        case p.nodetype of
           ordconstn:
             begin
               if p.resultdef.typ=pointerdef then
                 hp:=tconstsym.create_ordptr(orgname,constpointer,tordconstnode(p).value.uvalue,p.resultdef)
               else
                 hp:=tconstsym.create_ord(orgname,constord,tordconstnode(p).value,p.resultdef);
             end;
           stringconstn:
             begin
               if is_wide_or_unicode_string(p.resultdef) then
                 begin
                   initwidestring(pw);
                   copywidestring(pcompilerwidestring(tstringconstnode(p).value_str),pw);
                   hp:=tconstsym.create_wstring(orgname,constwstring,pw);
                 end
               else
                 begin
                   getmem(sp,tstringconstnode(p).len+1);
                   move(tstringconstnode(p).value_str^,sp^,tstringconstnode(p).len+1);
                   hp:=tconstsym.create_string(orgname,conststring,sp,tstringconstnode(p).len);
                 end;
             end;
           realconstn :
             begin
                new(pd);
                pd^:=trealconstnode(p).value_real;
                hp:=tconstsym.create_ptr(orgname,constreal,pd,p.resultdef);
             end;
           setconstn :
             begin
               new(ps);
               ps^:=tsetconstnode(p).value_set^;
               hp:=tconstsym.create_ptr(orgname,constset,ps,p.resultdef);
             end;
           pointerconstn :
             begin
               hp:=tconstsym.create_ordptr(orgname,constpointer,tpointerconstnode(p).value,p.resultdef);
             end;
           niln :
             begin
               hp:=tconstsym.create_ord(orgname,constnil,0,p.resultdef);
             end;
           typen :
             begin
               if is_interface(p.resultdef) then
                begin
                  if assigned(tobjectdef(p.resultdef).iidguid) then
                   begin
                     new(pg);
                     pg^:=tobjectdef(p.resultdef).iidguid^;
                     hp:=tconstsym.create_ptr(orgname,constguid,pg,p.resultdef);
                   end
                  else
                   Message1(parser_e_interface_has_no_guid,tobjectdef(p.resultdef).objrealname^);
                end
               else
                Message(parser_e_illegal_expression);
             end;
           else
             Message(parser_e_illegal_expression);
        end;
        current_tokenpos:=storetokenpos;
        p.free;
        readconstant:=hp;
      end;

    procedure const_dec;
      begin
        consume(_CONST);
        consts_dec(false);
      end;

    procedure consts_dec(in_structure: boolean);
      var
         orgname : TIDString;
         hdef : tdef;
         sym, tmp : tsym;
         dummysymoptions : tsymoptions;
         deprecatedmsg : pshortstring;
         storetokenpos,filepos : tfileposinfo;
         old_block_type : tblock_type;
         skipequal : boolean;
         tclist : tasmlist;
         varspez : tvarspez;
         static_name : string;
         sl : tpropaccesslist;
      begin
         old_block_type:=block_type;
         block_type:=bt_const;
         repeat
           orgname:=orgpattern;
           filepos:=current_tokenpos;
           consume(_ID);
           case token of

             _EQ:
                begin
                   consume(_EQ);
                   sym:=readconstant(orgname,filepos);
                   { Support hint directives }
                   dummysymoptions:=[];
                   deprecatedmsg:=nil;
                   try_consume_hintdirective(dummysymoptions,deprecatedmsg);
                   if assigned(sym) then
                     begin
                       sym.symoptions:=sym.symoptions+dummysymoptions;
                       sym.deprecatedmsg:=deprecatedmsg;
                       sym.visibility:=symtablestack.top.currentvisibility;
                       symtablestack.top.insert(sym);
                     end
                   else
                     stringdispose(deprecatedmsg);
                   consume(_SEMICOLON);
                end;

             _COLON:
                begin
                   { set the blocktype first so a consume also supports a
                     caret, to support const s : ^string = nil }
                   block_type:=bt_const_type;
                   consume(_COLON);
                   read_anon_type(hdef,false);
                   block_type:=bt_const;
                   skipequal:=false;
                   { create symbol }
                   storetokenpos:=current_tokenpos;
                   current_tokenpos:=filepos;
                   if not (cs_typed_const_writable in current_settings.localswitches) then
                     varspez:=vs_const
                   else
                     varspez:=vs_value;
                   { if we are dealing with structure const then we need to handle it as a
                     structure static variable: create a symbol in unit symtable and a reference
                     to it from the structure or linking will fail }
                   if symtablestack.top.symtabletype in [recordsymtable,ObjectSymtable] then
                     begin
                       { generate the symbol which reserves the space }
                       static_name:=lower(generate_nested_name(symtablestack.top,'_'))+'_'+orgname;
                       sym:=tstaticvarsym.create('$_static_'+static_name,varspez,hdef,[]);
                       include(sym.symoptions,sp_internal);
                       tabstractrecordsymtable(symtablestack.top).get_unit_symtable.insert(sym);
                       { generate the symbol for the access }
                       sl:=tpropaccesslist.create;
                       sl.addsym(sl_load,sym);
                       tmp:=tabsolutevarsym.create_ref(orgname,hdef,sl);
                       tmp.visibility:=symtablestack.top.currentvisibility;
                       symtablestack.top.insert(tmp);
                     end
                   else
                     begin
                       sym:=tstaticvarsym.create(orgname,varspez,hdef,[]);
                       sym.visibility:=symtablestack.top.currentvisibility;
                       symtablestack.top.insert(sym);
                     end;
                   current_tokenpos:=storetokenpos;
                   { procvar can have proc directives, but not type references }
                   if (hdef.typ=procvardef) and
                      (hdef.typesym=nil) then
                    begin
                      { support p : procedure;stdcall=nil; }
                      if try_to_consume(_SEMICOLON) then
                       begin
                         if check_proc_directive(true) then
                          parse_var_proc_directives(sym)
                         else
                          begin
                            Message(parser_e_proc_directive_expected);
                            skipequal:=true;
                          end;
                       end
                      else
                      { support p : procedure stdcall=nil; }
                       begin
                         if check_proc_directive(true) then
                          parse_var_proc_directives(sym);
                       end;
                      { add default calling convention }
                      handle_calling_convention(tabstractprocdef(hdef));
                    end;
                   if not skipequal then
                    begin
                      { get init value }
                      consume(_EQ);
                      if (cs_typed_const_writable in current_settings.localswitches) then
                        tclist:=current_asmdata.asmlists[al_typedconsts]
                      else
                        tclist:=current_asmdata.asmlists[al_rotypedconsts];
                      read_typed_const(tclist,tstaticvarsym(sym),in_structure);
                    end;
                end;

              else
                { generate an error }
                consume(_EQ);
           end;
         until (token<>_ID)or(in_structure and (idtoken in [_PRIVATE,_PROTECTED,_PUBLIC,_PUBLISHED,_STRICT]));
         block_type:=old_block_type;
      end;


    procedure label_dec;
      var
        labelsym : tlabelsym;
      begin
         consume(_LABEL);
         if not(cs_support_goto in current_settings.moduleswitches) then
           Message(sym_e_goto_and_label_not_supported);
         repeat
           if not(token in [_ID,_INTCONST]) then
             consume(_ID)
           else
             begin
                if token=_ID then
                  labelsym:=tlabelsym.create(orgpattern)
                else
                  labelsym:=tlabelsym.create(pattern);
                symtablestack.top.insert(labelsym);
                if m_non_local_goto in current_settings.modeswitches then
                  begin
                    if symtablestack.top.symtabletype=localsymtable then
                      begin
                        labelsym.jumpbuf:=tlocalvarsym.create('LABEL$_'+labelsym.name,vs_value,rec_jmp_buf,[]);
                        symtablestack.top.insert(labelsym.jumpbuf);
                      end
                    else
                      begin
                        labelsym.jumpbuf:=tstaticvarsym.create('LABEL$_'+labelsym.name,vs_value,rec_jmp_buf,[]);
                        symtablestack.top.insert(labelsym.jumpbuf);
                        insertbssdata(tstaticvarsym(labelsym.jumpbuf));
                      end;
                    include(labelsym.jumpbuf.symoptions,sp_internal);
                    { the buffer will be setup later, but avoid a hint }
                    tabstractvarsym(labelsym.jumpbuf).varstate:=vs_written;
                  end;
                consume(token);
             end;
           if token<>_SEMICOLON then consume(_COMMA);
         until not(token in [_ID,_INTCONST]);
         consume(_SEMICOLON);
      end;

    function parse_generic_parameters:TFPObjectList;
    var
      generictype : ttypesym;
    begin
      result:=TFPObjectList.Create(false);
      repeat
        if token=_ID then
          begin
            generictype:=ttypesym.create(orgpattern,cundefinedtype);
            include(generictype.symoptions,sp_generic_para);
            result.add(generictype);
          end;
        consume(_ID);
      until not try_to_consume(_COMMA) ;
    end;

    procedure insert_generic_parameter_types(def:tstoreddef;genericdef:tstoreddef;genericlist:TFPObjectList);
      var
        i: longint;
        generictype: ttypesym;
        st: tsymtable;
      begin
        def.genericdef:=genericdef;
        if not assigned(genericlist) then
          exit;

        case def.typ of
          recorddef,objectdef: st:=tabstractrecorddef(def).symtable;
          arraydef: st:=tarraydef(def).symtable;
          procvardef,procdef: st:=tabstractprocdef(def).parast;
          else
            internalerror(201101020);
        end;

        for i:=0 to genericlist.count-1 do
          begin
            generictype:=ttypesym(genericlist[i]);
            if generictype.typedef.typ=undefineddef then
              include(def.defoptions,df_generic)
            else
              include(def.defoptions,df_specialization);
            st.insert(generictype);
          end;
       end;

    procedure types_dec(in_structure: boolean);

      procedure finalize_objc_class_or_protocol_external_status(od: tobjectdef);
        begin
          if  [oo_is_external,oo_is_forward] <= od.objectoptions then
            begin
              { formal definition: x = objcclass external; }
              exclude(od.objectoptions,oo_is_forward);
              include(od.objectoptions,oo_is_formal);
            end;
        end;

      var
         typename,orgtypename : TIDString;
         newtype  : ttypesym;
         sym      : tsym;
         hdef     : tdef;
         defpos,storetokenpos : tfileposinfo;
         old_block_type : tblock_type;
         old_checkforwarddefs: TFPObjectList;
         objecttype : tobjecttyp;
         isgeneric,
         isunique,
         istyperenaming : boolean;
         generictypelist : TFPObjectList;
         generictokenbuf : tdynamicarray;
         vmtbuilder : TVMTBuilder;
      begin
         old_block_type:=block_type;
         { save unit container of forward declarations -
           we can be inside nested class type block }
         old_checkforwarddefs:=current_module.checkforwarddefs;
         current_module.checkforwarddefs:=TFPObjectList.Create(false);
         block_type:=bt_type;
         repeat
           defpos:=current_tokenpos;
           istyperenaming:=false;
           generictypelist:=nil;
           generictokenbuf:=nil;

           { fpc generic declaration? }
           isgeneric:=not(m_delphi in current_settings.modeswitches) and try_to_consume(_GENERIC);

           typename:=pattern;
           orgtypename:=orgpattern;
           consume(_ID);

           { delphi generic declaration? }
           if (m_delphi in current_settings.modeswitches) then
             isgeneric:=token=_LSHARPBRACKET;

           { Generic type declaration? }
           if isgeneric then
             begin
               if assigned(current_genericdef) then
                 Message(parser_f_no_generic_inside_generic);

               consume(_LSHARPBRACKET);
               generictypelist:=parse_generic_parameters;
               consume(_RSHARPBRACKET);
             end;

           consume(_EQ);

           { support 'ttype=type word' syntax }
           isunique:=try_to_consume(_TYPE);

           { MacPas object model is more like Delphi's than like TP's, but }
           { uses the object keyword instead of class                      }
           if (m_mac in current_settings.modeswitches) and
              (token = _OBJECT) then
             token := _CLASS;

           { Start recording a generic template }
           if assigned(generictypelist) then
             begin
               generictokenbuf:=tdynamicarray.create(256);
               current_scanner.startrecordtokens(generictokenbuf);
             end;

           { is the type already defined? -- must be in the current symtable,
             not in a nested symtable or one higher up the stack -> don't
             use searchsym & frinds! }
           sym:=tsym(symtablestack.top.find(typename));
           newtype:=nil;
           { found a symbol with this name? }
           if assigned(sym) then
            begin
              if (sym.typ=typesym) then
               begin
                 if ((token=_CLASS) or
                     (token=_INTERFACE) or
                     (token=_DISPINTERFACE) or
                     (token=_OBJCCLASS) or
                     (token=_OBJCPROTOCOL) or
                     (token=_OBJCCATEGORY)) and
                    (assigned(ttypesym(sym).typedef)) and
                    is_implicit_pointer_object_type(ttypesym(sym).typedef) and
                    (oo_is_forward in tobjectdef(ttypesym(sym).typedef).objectoptions) then
                  begin
                    case token of
                      _CLASS :
                        objecttype:=odt_class;
                      _INTERFACE :
                        if current_settings.interfacetype=it_interfacecom then
                          objecttype:=odt_interfacecom
                        else
                          objecttype:=odt_interfacecorba;
                      _DISPINTERFACE :
                        objecttype:=odt_dispinterface;
                      _OBJCCLASS,
                      _OBJCCATEGORY :
                        objecttype:=odt_objcclass;
                      _OBJCPROTOCOL :
                        objecttype:=odt_objcprotocol;
                      else
                        internalerror(200811072);
                    end;
                    consume(token);
                    { we can ignore the result, the definition is modified }
                    object_dec(objecttype,orgtypename,nil,nil,tobjectdef(ttypesym(sym).typedef),ht_none);
                    newtype:=ttypesym(sym);
                    hdef:=newtype.typedef;
                  end
                 else
                  message1(parser_h_type_redef,orgtypename);
               end;
            end;
           { no old type reused ? Then insert this new type }
           if not assigned(newtype) then
            begin
              { insert the new type first with an errordef, so that
                referencing the type before it's really set it
                will give an error (PFV) }
              hdef:=generrordef;
              storetokenpos:=current_tokenpos;
              newtype:=ttypesym.create(orgtypename,hdef);
              newtype.visibility:=symtablestack.top.currentvisibility;
              symtablestack.top.insert(newtype);
              current_tokenpos:=defpos;
              current_tokenpos:=storetokenpos;
              { read the type definition }
              read_named_type(hdef,orgtypename,nil,generictypelist,false);
              { update the definition of the type }
              if assigned(hdef) then
                begin
                  if assigned(hdef.typesym) then
                    istyperenaming:=true;
                  if isunique then
                    begin
                      if is_objc_class_or_protocol(hdef) then
                        Message(parser_e_no_objc_unique);

                      hdef:=tstoreddef(hdef).getcopy;

                      { fix name, it is used e.g. for tables }
                      if is_class_or_interface_or_dispinterface(hdef) then
                        with tobjectdef(hdef) do
                          begin
                            stringdispose(objname);
                            stringdispose(objrealname);
                            objrealname:=stringdup(orgtypename);
                            objname:=stringdup(upper(orgtypename));
                          end;

                      include(hdef.defoptions,df_unique);
                      if (hdef.typ in [pointerdef,classrefdef]) and
                         (tabstractpointerdef(hdef).pointeddef.typ=forwarddef) then
                        current_module.checkforwarddefs.add(hdef);
                    end;
                  if not assigned(hdef.typesym) then
                    hdef.typesym:=newtype;
                end;
              newtype.typedef:=hdef;
              { KAZ: handle TGUID declaration in system unit }
              if (cs_compilesystem in current_settings.moduleswitches) and not assigned(rec_tguid) and
                 (typename='TGUID') and { name: TGUID and size=16 bytes that is 128 bits }
                 assigned(hdef) and (hdef.typ=recorddef) and (hdef.size=16) then
                rec_tguid:=trecorddef(hdef);
            end;
           if assigned(hdef) then
            begin
              case hdef.typ of
                pointerdef :
                  begin
                    try_consume_hintdirective(newtype.symoptions,newtype.deprecatedmsg);
                    consume(_SEMICOLON);
                    if try_to_consume(_FAR) then
                     begin
                       tpointerdef(hdef).is_far:=true;
                       consume(_SEMICOLON);
                     end;
                  end;
                procvardef :
                  begin
                    { in case of type renaming, don't parse proc directives }
                    if istyperenaming then
                      begin
                        try_consume_hintdirective(newtype.symoptions,newtype.deprecatedmsg);
                        consume(_SEMICOLON);
                      end
                    else
                     begin
                       if not check_proc_directive(true) then
                         begin
                           try_consume_hintdirective(newtype.symoptions,newtype.deprecatedmsg);
                           consume(_SEMICOLON);
                         end;
                       parse_var_proc_directives(tsym(newtype));
                       handle_calling_convention(tprocvardef(hdef));
                       if try_consume_hintdirective(newtype.symoptions,newtype.deprecatedmsg) then
                         consume(_SEMICOLON);
                     end;
                  end;
                objectdef :
                  begin
                    try_consume_hintdirective(newtype.symoptions,newtype.deprecatedmsg);
                    consume(_SEMICOLON);

                    { change a forward and external objcclass declaration into
                      formal external definition, so the compiler does not
                      expect an real definition later }
                    if is_objc_class_or_protocol(hdef) then
                      finalize_objc_class_or_protocol_external_status(tobjectdef(hdef));

                    { Build VMT indexes, skip for type renaming and forward classes }
                    if (hdef.typesym=newtype) and
                       not(oo_is_forward in tobjectdef(hdef).objectoptions) and
                       not(df_generic in hdef.defoptions) then
                      begin
                        vmtbuilder:=TVMTBuilder.Create(tobjectdef(hdef));
                        vmtbuilder.generate_vmt;
                        vmtbuilder.free;
                      end;

                    { In case of an objcclass, verify that all methods have a message
                      name set. We only check this now, because message names can be set
                      during the protocol (interface) mapping. At the same time, set the
                      mangled names (these depend on the "external" name of the class),
                      and mark private fields of external classes as "used" (to avoid
                      bogus notes about them being unused)
                    }
                    { watch out for crashes in case of errors }
                    if is_objc_class_or_protocol(hdef) and
                       (not is_objccategory(hdef) or
                        assigned(tobjectdef(hdef).childof)) then
                      tobjectdef(hdef).finish_objc_data;

                    if is_cppclass(hdef) then
                      tobjectdef(hdef).finish_cpp_data;
                  end;
                recorddef :
                  begin
                    try_consume_hintdirective(newtype.symoptions,newtype.deprecatedmsg);
                    consume(_SEMICOLON);
                  end;
                else
                  begin
                    try_consume_hintdirective(newtype.symoptions,newtype.deprecatedmsg);
                    consume(_SEMICOLON);
                  end;
              end;
            end;

           if isgeneric and (not(hdef.typ in [objectdef,recorddef,arraydef,procvardef])
               or is_objectpascal_helper(hdef)) then
             message(parser_e_cant_create_generics_of_this_type);

           { Stop recording a generic template }
           if assigned(generictypelist) then
             begin
               current_scanner.stoprecordtokens;
               tstoreddef(hdef).generictokenbuf:=generictokenbuf;
               { Generic is never a type renaming }
               hdef.typesym:=newtype;
               generictypelist.free;
             end;
         until (token<>_ID)or(in_structure and (idtoken in [_PRIVATE,_PROTECTED,_PUBLIC,_PUBLISHED,_STRICT]));
         { resolve type block forward declarations and restore a unit
           container for them }
         resolve_forward_types;
         current_module.checkforwarddefs.free;
         current_module.checkforwarddefs:=old_checkforwarddefs;
         block_type:=old_block_type;
      end;


    { reads a type declaration to the symbol table }
    procedure type_dec;
      begin
        consume(_TYPE);
        types_dec(false);
      end;


    procedure var_dec;
    { parses variable declarations and inserts them in }
    { the top symbol table of symtablestack         }
      begin
        consume(_VAR);
        read_var_decls([]);
      end;


    procedure property_dec(is_classpropery: boolean);
      var
         old_block_type : tblock_type;
      begin
         consume(_PROPERTY);
         if not(symtablestack.top.symtabletype in [staticsymtable,globalsymtable]) then
           message(parser_e_resourcestring_only_sg);
         old_block_type:=block_type;
         block_type:=bt_const;
         repeat
           read_property_dec(is_classpropery, nil);
           consume(_SEMICOLON);
         until token<>_ID;
         block_type:=old_block_type;
      end;


    procedure threadvar_dec;
    { parses thread variable declarations and inserts them in }
    { the top symbol table of symtablestack                }
      begin
        consume(_THREADVAR);
        if not(symtablestack.top.symtabletype in [staticsymtable,globalsymtable]) then
          message(parser_e_threadvars_only_sg);
        read_var_decls([vd_threadvar]);
      end;


    procedure resourcestring_dec;
      var
         orgname : TIDString;
         p : tnode;
         dummysymoptions : tsymoptions;
         deprecatedmsg : pshortstring;
         storetokenpos,filepos : tfileposinfo;
         old_block_type : tblock_type;
         sp : pchar;
         sym : tsym;
      begin
         consume(_RESOURCESTRING);
         if not(symtablestack.top.symtabletype in [staticsymtable,globalsymtable]) then
           message(parser_e_resourcestring_only_sg);
         old_block_type:=block_type;
         block_type:=bt_const;
         repeat
           orgname:=orgpattern;
           filepos:=current_tokenpos;
           consume(_ID);
           case token of
             _EQ:
                begin
                   consume(_EQ);
                   p:=comp_expr(true,false);
                   storetokenpos:=current_tokenpos;
                   current_tokenpos:=filepos;
                   sym:=nil;
                   case p.nodetype of
                      ordconstn:
                        begin
                           if is_constcharnode(p) then
                             begin
                                getmem(sp,2);
                                sp[0]:=chr(tordconstnode(p).value.svalue);
                                sp[1]:=#0;
                                sym:=tconstsym.create_string(orgname,constresourcestring,sp,1);
                             end
                           else
                             Message(parser_e_illegal_expression);
                        end;
                      stringconstn:
                        with Tstringconstnode(p) do
                          begin
                             getmem(sp,len+1);
                             move(value_str^,sp^,len+1);
                             sym:=tconstsym.create_string(orgname,constresourcestring,sp,len);
                          end;
                      else
                        Message(parser_e_illegal_expression);
                   end;
                   current_tokenpos:=storetokenpos;
                   { Support hint directives }
                   dummysymoptions:=[];
                   deprecatedmsg:=nil;
                   try_consume_hintdirective(dummysymoptions,deprecatedmsg);
                   if assigned(sym) then
                     begin
                       sym.symoptions:=sym.symoptions+dummysymoptions;
                       sym.deprecatedmsg:=deprecatedmsg;
                       symtablestack.top.insert(sym);
                     end
                   else
                     stringdispose(deprecatedmsg);
                   consume(_SEMICOLON);
                   p.free;
                end;
              else consume(_EQ);
           end;
         until token<>_ID;
         block_type:=old_block_type;
      end;

end.
