{
    Copyright (c) 2014 by Jonas Maebe

    Generates code for typed constant declarations for the LLVM target

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
unit nllvmtcon;

{$i fpcdefs.inc}

interface

  uses
    cclasses,constexp,globtype,
    aasmbase,aasmtai,aasmcnst,aasmllvm,
    symconst,symtype,symdef,symsym,
    ngtcon;

  type
    tllvmtai_typedconstbuilder = class(ttai_lowleveltypedconstbuilder)
     protected
      { aggregates (from outer to inner nested) that have been encountered,
        if any }
      faggregates: tfplist;

      fqueued_def: tdef;
      fqueued_tai,
      flast_added_tai: tai;
      fqueued_tai_opidx: longint;

      procedure finalize_asmlist(sym: tasmsymbol; def: tdef; section: TAsmSectiontype; const secname: TSymStr; alignment: shortint; const options: ttcasmlistoptions); override;
      { outerai: the ai that should become fqueued_tai in case it's still nil,
          or that should be filled in the fqueued_tai_opidx of the current
          fqueued_tai if it's not nil
        innerai: the innermost ai (possibly an operand of outerai) in which
          newindex indicates which operand is empty and can be filled with the
          next queued tai }
      procedure update_queued_tai(resdef: tdef; outerai, innerai: tai; newindex: longint);
      procedure emit_tai_intern(p: tai; def: tdef);
      function wrap_with_type(p: tai; def: tdef): tai;
      procedure begin_aggregate_intern(tck: ttypedconstkind; def: tdef);
     public
      constructor create; override;
      destructor destroy; override;
      procedure emit_tai(p: tai; def: tdef); override;
      procedure emit_tai_procvar2procdef(p: tai; pvdef: tprocvardef); override;
      procedure maybe_begin_aggregate(def: tdef); override;
      procedure maybe_end_aggregate(def: tdef); override;
      procedure begin_anonymous_record(const optionalname: string; packrecords: shortint); override;
      function end_anonymous_record: trecorddef; override;
      procedure queue_init(todef: tdef); override;
      procedure queue_vecn(def: tdef; const index: tconstexprint); override;
      procedure queue_subscriptn(def: tabstractrecorddef; vs: tfieldvarsym); override;
      procedure queue_typeconvn(fromdef, todef: tdef); override;
      procedure queue_emit_staticvar(vs: tstaticvarsym); override;
      procedure queue_emit_asmsym(sym: tasmsymbol; def: tdef); override;

      class function get_string_symofs(typ: tstringtype; winlikewidestring: boolean): pint; override;
    end;


    tllvmasmlisttypedconstbuilder = class(tasmlisttypedconstbuilder)
     protected
      procedure tc_emit_string_offset(const ll: tasmlabofs; const strlength: longint; const st: tstringtype; const winlikewidestring: boolean; const charptrdef: tdef); override;
    end;

implementation

  uses
    verbose,
    aasmdata,
    cpubase,llvmbase,
    symbase,symtable,llvmdef,defutil;

  procedure tllvmtai_typedconstbuilder.finalize_asmlist(sym: tasmsymbol; def: tdef; section: TAsmSectiontype; const secname: TSymStr; alignment: shortint; const options: ttcasmlistoptions);
    var
      newasmlist: tasmlist;
    begin
      { todo }
      if section = sec_user then
        internalerror(2014052904);
      newasmlist:=tasmlist.create_without_marker;
      { llvm declaration with as initialisation data all the elements from the
        original asmlist }
      newasmlist.concat(taillvmdecl.create(sym,def,fasmlist,section,alignment));
      fasmlist:=newasmlist;
    end;

  procedure tllvmtai_typedconstbuilder.update_queued_tai(resdef: tdef; outerai, innerai: tai; newindex: longint);
    begin
      { the outer tai must always be a typed constant (possibly a wrapper
        around a taillvm or so), in order for result type information to be
        available }
      if outerai.typ<>ait_typedconst then
        internalerror(2014060401);
      { is the result of the outermost expression different from the type of
        this typed const? -> insert type conversion }
      if not assigned(fqueued_tai) and
         (resdef<>fqueued_def) and
         (llvmencodetype(resdef)<>llvmencodetype(fqueued_def)) then
        queue_typeconvn(resdef,fqueued_def);
      if assigned(fqueued_tai) then
        begin
          taillvm(flast_added_tai).loadtai(fqueued_tai_opidx,outerai);
          { already flushed? }
          if fqueued_tai_opidx=-1 then
            internalerror(2014062201);
        end
      else
        begin
          fqueued_tai:=outerai;
          fqueued_def:=resdef;
        end;
      fqueued_tai_opidx:=newindex;
      flast_added_tai:=innerai;
    end;


  procedure tllvmtai_typedconstbuilder.emit_tai_intern(p: tai; def: tdef);
    var
      ai: tai;
      stc: tai_abstracttypedconst;
      kind: ttypedconstkind;
    begin
      if assigned(fqueued_tai) then
        begin
          kind:=tck_simple;
          { finalise the queued expression }
          ai:=tai_simpletypedconst.create(kind,def,p);
          { set the new index to -1, so we internalerror should we try to
            add anything further }
          update_queued_tai(def,ai,ai,-1);
          { and emit it }
          stc:=tai_abstracttypedconst(fqueued_tai);
          def:=fqueued_def;
          { ensure we don't try to emit this one again }
          fqueued_tai:=nil;
        end
      else
        stc:=tai_simpletypedconst.create(tck_simple,def,p);
      { these elements can be aggregates themselves, e.g. a shortstring can
        be emitted as a series of bytes and string data arrays }
      kind:=aggregate_kind(def);
      if (kind<>tck_simple) and
         (not assigned(faggregates) or
          (faggregates.count=0) or
          (tai_aggregatetypedconst(faggregates[faggregates.count-1]).adetyp<>kind)) then
        internalerror(2014052906);
      if assigned(faggregates) and
         (faggregates.count>0) then
        tai_aggregatetypedconst(faggregates[faggregates.count-1]).addvalue(stc)
      else
        inherited emit_tai(stc,def);
    end;


  function tllvmtai_typedconstbuilder.wrap_with_type(p: tai; def: tdef): tai;
    begin
      result:=tai_simpletypedconst.create(tck_simple,def,p);
    end;


  procedure tllvmtai_typedconstbuilder.begin_aggregate_intern(tck: ttypedconstkind; def: tdef);
    var
      agg: tai_aggregatetypedconst;
    begin
      if not assigned(faggregates) then
        faggregates:=tfplist.create;
      agg:=tai_aggregatetypedconst.create(tck,def);
      { nested aggregate -> add to parent }
      if faggregates.count>0 then
        tai_aggregatetypedconst(faggregates[faggregates.count-1]).addvalue(agg)
      { otherwise add to asmlist }
      else
        fasmlist.concat(agg);
      { new top level aggregate, future data will be added to it }
      faggregates.add(agg);
    end;


  constructor tllvmtai_typedconstbuilder.create;
    begin
      inherited create;
      { constructed as needed }
      faggregates:=nil;
    end;


  destructor tllvmtai_typedconstbuilder.destroy;
    begin
      faggregates.free;
      inherited destroy;
    end;


  procedure tllvmtai_typedconstbuilder.emit_tai(p: tai; def: tdef);
    begin
      emit_tai_intern(p,def);
    end;


  procedure tllvmtai_typedconstbuilder.emit_tai_procvar2procdef(p: tai; pvdef: tprocvardef);
    begin
      if not pvdef.is_addressonly then
        pvdef:=tprocvardef(pvdef.getcopyas(procvardef,pc_address_only));
      emit_tai_intern(p,pvdef);
    end;


  procedure tllvmtai_typedconstbuilder.maybe_begin_aggregate(def: tdef);
    var
      tck: ttypedconstkind;
    begin
      tck:=aggregate_kind(def);
      if tck<>tck_simple then
        begin_aggregate_intern(tck,def);
      inherited;
    end;


  procedure tllvmtai_typedconstbuilder.maybe_end_aggregate(def: tdef);
    begin
      if aggregate_kind(def)<>tck_simple then
        begin
          if not assigned(faggregates) or
             (faggregates.count=0) then
            internalerror(2014060101);
          tai_aggregatetypedconst(faggregates[faggregates.count-1]).finish;
          { already added to the asmlist if necessary }
          faggregates.count:=faggregates.count-1;
        end;
      inherited;
    end;


  procedure tllvmtai_typedconstbuilder.begin_anonymous_record(const optionalname: string; packrecords: shortint);
    var
      recorddef: trecorddef;
    begin
      inherited;
      recorddef:=crecorddef.create_global_internal(optionalname,packrecords);
      begin_aggregate_intern(tck_record,recorddef);
    end;


  function tllvmtai_typedconstbuilder.end_anonymous_record: trecorddef;
    var
      agg: tai_aggregatetypedconst;
      ele: tai_abstracttypedconst;
      defs: tfplist;
    begin
      result:=inherited;
      if assigned(result) then
        exit;
      if not assigned(faggregates) or
         (faggregates.count=0) or
         (tai_aggregatetypedconst(faggregates[faggregates.count-1]).def.typ<>recorddef) then
        internalerror(2014080201);
      agg:=tai_aggregatetypedconst(faggregates[faggregates.count-1]);
      defs:=tfplist.create;
      for ele in agg do
        defs.add(ele.def);
      result:=trecorddef(agg.def);
      result.add_fields_from_deflist(defs);
      { already added to the asmlist if necessary }
      faggregates.count:=faggregates.count-1;
    end;


  procedure tllvmtai_typedconstbuilder.queue_init(todef: tdef);
    begin
      inherited;
      fqueued_tai:=nil;
      flast_added_tai:=nil;
      fqueued_tai_opidx:=-1;
      fqueued_def:=todef;
    end;


  procedure tllvmtai_typedconstbuilder.queue_vecn(def: tdef; const index: tconstexprint);
    var
      ai: taillvm;
      aityped: tai;
      eledef: tdef;
    begin
      { update range checking info }
      inherited;
      ai:=taillvm.getelementptr_reg_tai_size_const(NR_NO,nil,ptrsinttype,index.svalue,true);
      case def.typ of
        arraydef:
          eledef:=tarraydef(def).elementdef;
        stringdef:
          case tstringdef(def).stringtype of
            st_shortstring,
            st_longstring,
            st_ansistring:
              eledef:=cansichartype;
            st_widestring,
            st_unicodestring:
              eledef:=cwidechartype;
            else
              internalerror(2014062202);
          end;
        else
          internalerror(2014062203);
      end;
      aityped:=wrap_with_type(ai,getpointerdef(eledef));
      update_queued_tai(getpointerdef(eledef),aityped,ai,1);
    end;


  procedure tllvmtai_typedconstbuilder.queue_subscriptn(def: tabstractrecorddef; vs: tfieldvarsym);
    var
      getllvmfieldaddr,
      getpascalfieldaddr,
      getllvmfieldaddrtyped: tai;
      llvmfielddef: tdef;
    begin
      { update range checking info }
      inherited;
      llvmfielddef:=tabstractrecordsymtable(def.symtable).llvmst[vs.llvmfieldnr].def;
      { get the address of the llvm-struct field that corresponds to this
        Pascal field }
      getllvmfieldaddr:=taillvm.getelementptr_reg_tai_size_const(NR_NO,nil,s32inttype,vs.llvmfieldnr,true);
      { getelementptr doesn't contain its own resultdef, so encode it via a
        tai_simpletypedconst tai }
      getllvmfieldaddrtyped:=wrap_with_type(getllvmfieldaddr,getpointerdef(llvmfielddef));
      { if it doesn't match the requested field exactly (variant record),
        fixup the result }
      getpascalfieldaddr:=getllvmfieldaddrtyped;
      if (vs.offsetfromllvmfield<>0) or
         (llvmfielddef<>vs.vardef) then
        begin
          { offset of real field relative to llvm-struct field <> 0? }
          if vs.offsetfromllvmfield<>0 then
            begin
              { convert to a pointer to a 1-sized element }
              if llvmfielddef.size<>1 then
                begin
                  getpascalfieldaddr:=taillvm.op_reg_tai_size(la_bitcast,NR_NO,getpascalfieldaddr,u8inttype);
                  { update the current fielddef of the expression }
                  llvmfielddef:=u8inttype;
                end;
              { add the offset }
              getpascalfieldaddr:=taillvm.getelementptr_reg_tai_size_const(NR_NO,getpascalfieldaddr,ptrsinttype,vs.offsetfromllvmfield,true);
              { ... and set the result type of the getelementptr }
              getpascalfieldaddr:=wrap_with_type(getpascalfieldaddr,getpointerdef(u8inttype));
              llvmfielddef:=u8inttype;
            end;
          { bitcast the data at the final offset to the right type }
          if llvmfielddef<>vs.vardef then
            getpascalfieldaddr:=wrap_with_type(taillvm.op_reg_tai_size(la_bitcast,NR_NO,getpascalfieldaddr,getpointerdef(vs.vardef)),getpointerdef(vs.vardef));
        end;
      update_queued_tai(getpointerdef(vs.vardef),getpascalfieldaddr,getllvmfieldaddr,1);
    end;


  procedure tllvmtai_typedconstbuilder.queue_typeconvn(fromdef, todef: tdef);
    var
      ai: taillvm;
      typedai: tai;
      tmpintdef: tdef;
      op,
      firstop,
      secondop: tllvmop;
    begin
      inherited;
      { special case: procdef -> procvardef/pointerdef: must take address of
        the procdef }
      if (fromdef.typ=procdef) and
         (todef.typ<>procdef) then
        fromdef:=tprocdef(fromdef).getcopyas(procvardef,pc_address_only);
      op:=llvmconvop(fromdef,todef);
      case op of
        la_ptrtoint_to_x,
        la_x_to_inttoptr:
          begin
            { convert via an integer with the same size as "x" }
            if op=la_ptrtoint_to_x then
              begin
                tmpintdef:=cgsize_orddef(def_cgsize(todef));
                firstop:=la_ptrtoint;
                secondop:=la_bitcast
              end
            else
              begin
                tmpintdef:=cgsize_orddef(def_cgsize(fromdef));
                firstop:=la_bitcast;
                secondop:=la_inttoptr;
              end;
            { since we have to queue operations from outer to inner, first queue
              the conversion from the tempintdef to the todef }
            ai:=taillvm.op_reg_tai_size(secondop,NR_NO,nil,todef);
            typedai:=wrap_with_type(ai,todef);
            update_queued_tai(todef,typedai,ai,1);
            todef:=tmpintdef;
            op:=firstop
          end;
      end;
      ai:=taillvm.op_reg_tai_size(op,NR_NO,nil,todef);
      typedai:=wrap_with_type(ai,todef);
      update_queued_tai(todef,typedai,ai,1);
    end;


  procedure tllvmtai_typedconstbuilder.queue_emit_staticvar(vs: tstaticvarsym);
    begin
      { we've already incorporated the offset via the inserted operations above,
        make sure it doesn't get emitted again as part of the tai_const for
        the tasmsymbol }
      fqueue_offset:=0;
      inherited;
    end;


  procedure tllvmtai_typedconstbuilder.queue_emit_asmsym(sym: tasmsymbol; def: tdef);
    begin
      { we've already incorporated the offset via the inserted operations above,
        make sure it doesn't get emitted again as part of the tai_const for
        the tasmsymbol }
      fqueue_offset:=0;
      inherited;
    end;


  class function tllvmtai_typedconstbuilder.get_string_symofs(typ: tstringtype; winlikewidestring: boolean): pint;
    begin
      { LLVM does not support labels in the middle of a declaration }
      result:=get_string_header_size(typ,winlikewidestring);
    end;


  { tllvmasmlisttypedconstbuilder }

  procedure tllvmasmlisttypedconstbuilder.tc_emit_string_offset(const ll: tasmlabofs; const strlength: longint; const st: tstringtype; const winlikewidestring: boolean; const charptrdef: tdef);
    var
      srsym     : tsym;
      srsymtable: tsymtable;
      strrecdef : trecorddef;
      offset: pint;
      field: tfieldvarsym;
      dataptrdef: tdef;
    begin
      { if the returned offset is <> 0, then the string data
        starts at that offset -> translate to a field for the
        high level code generator }
      if ll.ofs<>0 then
        begin
          { get the recorddef for this string constant }
          if not searchsym_type(ctai_typedconstbuilder.get_dynstring_rec_name(st,winlikewidestring,strlength),srsym,srsymtable) then
            internalerror(2014080406);
          strrecdef:=trecorddef(ttypesym(srsym).typedef);
          { offset in the record of the the string data }
          offset:=ctai_typedconstbuilder.get_string_symofs(st,winlikewidestring);
          { field corresponding to this offset }
          field:=trecordsymtable(strrecdef.symtable).findfieldbyoffset(offset);
          { pointerdef to the string data array }
          dataptrdef:=getpointerdef(field.vardef);
          ftcb.queue_init(charptrdef);
          ftcb.queue_addrn(dataptrdef,charptrdef);
          ftcb.queue_subscriptn(strrecdef,field);
          ftcb.queue_emit_asmsym(ll.lab,strrecdef);
        end
      else
       { since llvm doesn't support labels in the middle of structs, this
         offset should never be 0  }
       internalerror(2014080506);
    end;


begin
  ctai_typedconstbuilder:=tllvmtai_typedconstbuilder;
  ctypedconstbuilder:=tllvmasmlisttypedconstbuilder;
end.

