{
    Copyright (c) 1998-2002 by Florian Klaempfl, Daniel Mantione, Dr. Diettrich

    Semantic support for parsing of procedures/functions.
    Most parts copied from pdecsub.pas.
}
unit SDecSub;

{$i fpcdefs.inc}

{$DEFINE someProcs} //make some methods ordinary procedures?

interface

uses
  cclasses,globtype,
  tokens,symconst,symtype,symdef,symsym,symtable,symbase;

type
  tppv = (pv_none,pv_proc,pv_func);
  pdef = ^tdef;

  TSemParaDec = object
  public  //private //force "unused" hint, else protected
    sc      : TFPObjectList; //parameters in current clause
    arrayelementdef : tdef;
    //i       : longint;
    srsym   : tsym;
    varspez : Tvarspez;
    //defaultvalue : tconstsym;
    //defaultrequired : boolean;
    old_block_type : tblock_type;
    currparast : tparasymtable;
    parseprocvar : tppv;
    paranr : integer;
    dummytype : ttypesym;
    //need_array,is_univ: boolean;
  public
    pd      : tabstractprocdef;
    hdef    : tdef;
    pv      : tprocvardef;
    locationstr : string;
    vs      : tparavarsym;
    explicit_paraloc: boolean;
  public
    constructor SDSInit(ThePD:tabstractprocdef);
    destructor  SDSDone;
  { begin parsing of the formal parameter list }
    procedure SParamListInit;
  { set parameter kind }
    procedure SParamInit;
    procedure SParaVar;
    procedure SParaConst;
    procedure SParaOut;
    procedure SParaVarargs;
    procedure SParaProc;
    procedure SParaFunc;
  { parameter itself }
    procedure SParamNamesInit;
    procedure SParaName(const orgpattern: string);
    function  ParaIsValue: boolean;
  { anonymous procedures }
    function  ParaIsAnonymousProc: boolean;
    function  ParaIsAnonymousFunc: boolean;
    function  GetDummyType: ttypesym;
    procedure FreeDummyType;
  { parameter type }
    procedure ArrayParaInit;
    procedure ArrayParaIsConst;
    procedure ParaCheckOpenString;
    function  DefaultParam: tparavarsym;
    procedure CheckParams(is_univ: boolean; defaultvalue: tconstsym);
  {$IFDEF someProcs}
  {$ELSE}
    procedure HandleLocation; //OS specific attribute
  {$ENDIF}
  end;

  TSemProcHead = object
  public //private
    //hs       : string;
    orgsp,sp : TIDString;
    srsym : tsym;
    srsymtable : TSymtable;
    checkstack : psymtablestackitem;
    //storepos: tfileposinfo;
    procstartfilepos : tfileposinfo;
    //searchagain : boolean;
    st,
    genericst : TSymtable;
    aprocsym : tprocsym;
    popclass : boolean;
    //ImplIntf : TImplementedInterface;
    old_parse_generic : boolean;
    old_current_objectdef: tobjectdef;
  public //from caller arguments
    aclass:tobjectdef;
    potype:tproctypeoption;
  public
    constructor Init(_aclass:tobjectdef;_potype:tproctypeoption);
    destructor Done;
    procedure CheckInterfaceResolution;
    procedure DecMethod;
    procedure CheckOverload;
    procedure ProcName(var pd:tprocdef);
    procedure ParamsInit(var pd:tprocdef);
    procedure ParamsDone(var pd:tprocdef);
  end;

  TSemProcDec = object
  private
    //pd : tprocdef;
    locationstr: string;
    old_parse_generic,
    popclass: boolean;
    old_current_objectdef: tobjectdef;
  public
    constructor Init;
    procedure Done(pd: tprocdef); //destructor cannot take arguments
    procedure TypeInit(pd: tprocdef);
    procedure TypeDone(pd: tprocdef);
  {$IFDEF someProcs}
  {$ELSE}
    procedure MakeClassMethod(pd: tprocdef);
    procedure MakeProc(pd: tprocdef; isclassmethod: boolean);
    procedure MakeConstructor(pd: tprocdef; isclassmethod: boolean);
    procedure MakeDestructor(pd: tprocdef);
  {$ENDIF}
  end;

function SGetParaLocation(explicit_paraloc: boolean): string;
//subject to become TProcDef methods/properties
procedure SMakeClassMethod(pd: tprocdef);
procedure SMakeProc(pd: tprocdef; isclassmethod: boolean);
procedure SMakeConstructor(pd: tprocdef; isclassmethod: boolean);
procedure SMakeDestructor(pd: tprocdef);

implementation

uses
  globals,verbose,cutils,defutil,
  scanner,pbase, ptype,paramgr,
  fmodule, systems;

{ TSemParaDec }

constructor TSemParaDec.SDSInit(ThePD:tabstractprocdef);
begin
  pd := ThePD;
  old_block_type:=block_type;
  explicit_paraloc:=false;
end;

procedure TSemParaDec.SParamListInit;
begin
  currparast:=tparasymtable(pd.parast);
  { reset }
  sc:=TFPObjectList.create(false);
  //defaultrequired:=false;
  paranr:=0;
  inc(testcurobject);
  block_type:=bt_var;
end;

procedure TSemParaDec.SParamInit;
begin
  parseprocvar:=pv_none;
  varspez:=vs_value;
end;

procedure TSemParaDec.SParaVar;
begin
  varspez:=vs_var;
end;

procedure TSemParaDec.SParaConst;
begin
  varspez:=vs_const;
end;

procedure TSemParaDec.SParaOut;
begin
  varspez:=vs_out;
end;

procedure TSemParaDec.SParaVarargs;
begin
  include(pd.procoptions,po_varargs);
end;

procedure TSemParaDec.SParaProc;
begin
  parseprocvar:=pv_proc;
  varspez:=vs_const;
end;

procedure TSemParaDec.SParaFunc;
begin
  parseprocvar:=pv_func;
  varspez:=vs_const;
end;

procedure TSemParaDec.SParamNamesInit;
begin
  //defaultvalue:=nil;
  hdef:=nil;
  { read identifiers and insert with error type }
  sc.clear;
  locationstr:='';
end;

procedure TSemParaDec.SParaName(const orgpattern: string);
begin
  inc(paranr);
  vs:=tparavarsym.create(orgpattern,paranr*10,varspez,generrordef,[]);
  currparast.insert(vs);
  if assigned(vs.owner) then
   sc.add(vs)
  else
   vs.free;
end;

function TSemParaDec.ParaIsAnonymousProc: boolean;
begin
  Result := parseprocvar<>pv_none;
  if Result then begin { inline procvar definitions are always nested procvars }
    pv:=tprocvardef.create(normal_function_level+1);
    hdef:=pv;
  end;
end;

function TSemParaDec.ParaIsAnonymousFunc: boolean;
begin
  Result := parseprocvar=pv_func;
end;

function TSemParaDec.GetDummyType: ttypesym;
begin
  Result := ttypesym.create('unnamed',hdef);
  dummytype := Result;
end;

procedure TSemParaDec.FreeDummyType;
begin
  dummytype.typedef:=nil;
  hdef.typesym:=nil;
  dummytype.free;
end;

function TSemParaDec.ParaIsValue: boolean;
begin
  Result := varspez=vs_value;
end;

procedure TSemParaDec.ArrayParaInit;
begin
  hdef:=tarraydef.create(0,-1,s32inttype);
end;

procedure TSemParaDec.ArrayParaIsConst;
begin
  srsym:=search_system_type('TVARREC');
  tarraydef(hdef).elementdef:=ttypesym(srsym).typedef;
  include(tarraydef(hdef).arrayoptions,ado_IsArrayOfConst);
end;

procedure TSemParaDec.ParaCheckOpenString;
begin
  if is_shortstring(hdef) then begin
    case varspez of
    vs_var,vs_out:
      begin
        { not 100% Delphi-compatible: type xstr=string[255] cannot
          become an openstring there, while here it can }
        if (cs_openstring in current_settings.moduleswitches) and
           (tstringdef(hdef).len=255) then
          hdef:=openshortstringtype
      end;
    vs_value:
     begin
       { value "openstring" parameters don't make sense (the
          original string can never be modified, so there's no
          use in passing its original length), so change these
          into regular shortstring parameters (seems to be what
          Delphi also does) }
      if is_open_string(hdef) then
        hdef:=cshortstringtype;
     end;
    end;
end;
end;

function TSemParaDec.DefaultParam: tparavarsym;
begin
  Result := tparavarsym(sc[0]);
  vs := Result;
  if sc.count>1 then
    Message(parser_e_default_value_only_one_para);
end;

procedure TSemParaDec.CheckParams(is_univ: boolean; defaultvalue: tconstsym);
var
  i: integer;
begin
{ File types are only allowed for var and out parameters }
  if (hdef.typ=filedef) and not(varspez in [vs_out,vs_var]) then
    CGMessage(cg_e_file_must_call_by_reference);
{ univ cannot be used with types whose size is not known at compile
    time }
  if is_univ and not is_valid_univ_para_type(hdef) then
    Message1(parser_e_invalid_univ_para,hdef.typename);

  for i:=0 to sc.count-1 do begin
    vs:=tparavarsym(sc[i]);
    vs.univpara:=is_univ;
    { update varsym }
    vs.vardef:=hdef;
    vs.defaultconstsym:=defaultvalue; //when a default value is given, only one parameter can exist in sc

    if (target_info.system in [system_powerpc_morphos,system_m68k_amiga]) then begin
      if locationstr<>'' then begin
        if sc.count>1 then
          Message(parser_e_paraloc_only_one_para);
        if (paranr>1) and not(explicit_paraloc) then
          Message(parser_e_paraloc_all_paras);
        explicit_paraloc:=true;
        include(vs.varoptions,vo_has_explicit_paraloc);
        if not(paramanager.parseparaloc(vs,upper(locationstr))) then
          message(parser_e_illegal_explicit_paraloc);
      end else if explicit_paraloc then
        Message(parser_e_paraloc_all_paras);
    end;
  end;
end;

destructor TSemParaDec.SDSDone;
begin
  if explicit_paraloc then begin
    pd.has_paraloc_info:=callerside;
    include(pd.procoptions,po_explicitparaloc);
  end;
  { remove parasymtable from stack }
  sc.free;
  { reset object options }
  dec(testcurobject);
  block_type:=old_block_type;
end;

//TSemParaDec.HandleLocation
function SGetParaLocation(explicit_paraloc: boolean): string;
begin
  if (target_info.system in [system_powerpc_morphos,system_m68k_amiga]) then begin
    if (idtoken=_LOCATION) then begin
      consume(_LOCATION);
      Result:=cstringpattern;
      consume(_CSTRING);
    end else begin
      if explicit_paraloc then
        Message(parser_e_paraloc_all_paras);
      Result:='';
    end;
  end else
    Result:='';
end;

{ TSemProcHead }

constructor TSemProcHead.Init(_aclass:tobjectdef;_potype:tproctypeoption);
begin
  aclass := _aclass;
  potype := _potype;

  procstartfilepos:=current_tokenpos;
  old_parse_generic:=parse_generic;

  //result:=false;
  //pd:=nil;
  aprocsym:=nil;

  if potype=potype_operator then
    begin
      sp:=overloaded_names[optoken];
      orgsp:=sp;
    end
  else
    begin
      sp:=pattern;
      orgsp:=orgpattern;
      consume(_ID);
    end;
end;

procedure TSemProcHead.CheckInterfaceResolution;
var
  hs: string;
  ImplIntf : TImplementedInterface;
  storepos: tfileposinfo;
begin
  storepos:=current_tokenpos;
  current_tokenpos:=procstartfilepos;
  { get interface syms}
  searchsym(sp,srsym,srsymtable);
  if not assigned(srsym) then
  begin
    identifier_not_found(orgsp);
    srsym:=generrorsym;
  end;
  current_tokenpos:=storepos;
  { qualifier is interface? }
  ImplIntf:=nil;
  if (srsym.typ=typesym) and
    (ttypesym(srsym).typedef.typ=objectdef) then
   ImplIntf:=aclass.find_implemented_interface(tobjectdef(ttypesym(srsym).typedef));
  if ImplIntf=nil then
    Message(parser_e_interface_id_expected);
  consume(_ID);
  { Create unique name <interface>.<method> }
  hs:=sp+'.'+pattern;
  consume(_EQUAL);
  if assigned(ImplIntf) and (token=_ID) then
   ImplIntf.AddMapping(hs,pattern);
  consume(_ID);
end;

procedure TSemProcHead.DecMethod;
var
  searchagain : boolean;
  storepos: tfileposinfo;
begin
  repeat
    searchagain:=false;
    if not assigned(aclass) then
     begin
       { search for object name }
       storepos:=current_tokenpos;
       current_tokenpos:=procstartfilepos;
       searchsym(sp,srsym,srsymtable);
       if not assigned(srsym) then
        begin
          identifier_not_found(orgsp);
          srsym:=generrorsym;
        end;
       current_tokenpos:=storepos;
     end;
    { consume proc name }
    sp:=pattern;
    orgsp:=orgpattern;
    procstartfilepos:=current_tokenpos;
    consume(_ID);
    { qualifier is class name ? }
    if (srsym.typ=typesym) and
      (ttypesym(srsym).typedef.typ=objectdef) then
    begin
      aclass:=tobjectdef(ttypesym(srsym).typedef);
      if (token<>_POINT) and (potype in [potype_class_constructor,potype_class_destructor]) then
        sp := lower(sp);
      srsym:=tsym(aclass.symtable.Find(sp));
      if assigned(srsym) then
       begin
         if srsym.typ=procsym then
           aprocsym:=tprocsym(srsym)
         else
         if (srsym.typ=typesym) and
            (ttypesym(srsym).typedef.typ=objectdef) then
           begin
             searchagain:=true;
             consume(_POINT);
           end
         else
           begin
             {  we use a different error message for tp7 so it looks more compatible }
             if (m_fpc in current_settings.modeswitches) then
               Message1(parser_e_overloaded_no_procedure,srsym.realname)
             else
               Message(parser_e_methode_id_expected);
             { rename the name to an unique name to avoid an
               error when inserting the symbol in the symtable }
             orgsp:=orgsp+'$'+tostr(current_filepos.line);
           end;
       end
      else
       begin
         Message(parser_e_methode_id_expected);
         { recover by making it a normal procedure instead of method }
         aclass:=nil;
       end;
    end
    else
      Message(parser_e_class_id_expected);
  until not searchagain;
end;

procedure TSemProcHead.CheckOverload;
var
  searchagain : boolean;
begin
  { check for constructor/destructor which is not allowed here }
  if (not parse_only) and
    (potype in [potype_constructor,potype_destructor,
                potype_class_constructor,potype_class_destructor]) then
   Message(parser_e_constructors_always_objects);

  repeat
   searchagain:=false;
   current_tokenpos:=procstartfilepos;

   srsymtable:=symtablestack.top;
   srsym:=tsym(srsymtable.Find(sp));

   { Also look in the globalsymtable if we didn't found
     the symbol in the localsymtable }
   if not assigned(srsym) and
      not(parse_only) and
      (srsymtable=current_module.localsymtable) and
      assigned(current_module.globalsymtable) then
     srsym:=tsym(current_module.globalsymtable.Find(sp));

   { Check if overloaded is a procsym }
   if assigned(srsym) then
     begin
       if srsym.typ=procsym then
         aprocsym:=tprocsym(srsym)
       else
         begin
           { when the other symbol is a unit symbol then hide the unit
             symbol, this is not supported in tp7 }
           if not(m_tp7 in current_settings.modeswitches) and
              (srsym.typ=unitsym) then
            begin
              HideSym(srsym);
              searchagain:=true;
            end
           else
            begin
              {  we use a different error message for tp7 so it looks more compatible }
              if (m_fpc in current_settings.modeswitches) then
                Message1(parser_e_overloaded_no_procedure,srsym.realname)
              else
                Message1(sym_e_duplicate_id,srsym.realname);
              { rename the name to an unique name to avoid an
                error when inserting the symbol in the symtable }
              orgsp:=orgsp+'$'+tostr(current_filepos.line);
            end;
         end;
    end;
  until not searchagain;
end;

procedure TSemProcHead.ProcName(var pd:tprocdef);
begin
  { test again if assigned, it can be reset to recover }
  if not assigned(aprocsym) then
    begin
      { create a new procsym and set the real filepos }
      current_tokenpos:=procstartfilepos;
      { for operator we have only one procsym for each overloaded
        operation }
      if (potype=potype_operator) then
        begin
          aprocsym:=Tprocsym(symtablestack.top.Find(sp));
          if aprocsym=nil then
            aprocsym:=tprocsym.create('$'+sp);
        end
      else
      if (potype in [potype_class_constructor,potype_class_destructor]) then
        aprocsym:=tprocsym.create('$'+lower(sp))
      else
        aprocsym:=tprocsym.create(orgsp);
      symtablestack.top.insert(aprocsym);
    end;

  { to get the correct symtablelevel we must ignore ObjectSymtables }
  st:=nil;
  checkstack:=symtablestack.stack;
  while assigned(checkstack) do
    begin
      st:=checkstack^.symtable;
      if st.symtabletype in [staticsymtable,globalsymtable,localsymtable] then
        break;
      checkstack:=checkstack^.next;
    end;
  pd:=tprocdef.create(st.symtablelevel+1);
  pd._class:=aclass;
  pd.procsym:=aprocsym;
  pd.proctypeoption:=potype;

  { methods inherit df_generic or df_specialization from the objectdef }
  if assigned(pd._class) and
     (pd.parast.symtablelevel=normal_function_level) then
    begin
      if (df_generic in pd._class.defoptions) then
        begin
          include(pd.defoptions,df_generic);
          parse_generic:=true;
        end;
      if (df_specialization in pd._class.defoptions) then
        begin
          include(pd.defoptions,df_specialization);
          { Find corresponding genericdef, we need it later to
            replay the tokens to generate the body }
          if not assigned(pd._class.genericdef) then
            internalerror(200512113);
          genericst:=pd._class.genericdef.GetSymtable(gs_record);
          if not assigned(genericst) then
            internalerror(200512114);
          { We are parsing the same objectdef, the def index numbers
            are the same }
          pd.genericdef:=tstoreddef(genericst.DefList[pd.owner.DefList.IndexOf(pd)]);
          if not assigned(pd.genericdef) or
             (pd.genericdef.typ<>procdef) then
            internalerror(200512115);
        end;
    end;

  { methods need to be exported }
  if assigned(aclass) and
     (
      (symtablestack.top.symtabletype=ObjectSymtable) or
      (symtablestack.top.symtablelevel=main_program_level)
     ) then
    include(pd.procoptions,po_global);

  { symbol options that need to be kept per procdef }
  pd.fileinfo:=procstartfilepos;
  pd.visibility:=symtablestack.top.currentvisibility;
  if symtablestack.top.currentlyoptional then
    include(pd.procoptions,po_optional);
end;

procedure TSemProcHead.ParamsInit(var pd:tprocdef);
begin
  { Add ObjectSymtable to be able to find generic type definitions }
  popclass:=false;
  if assigned(pd._class) and
     (pd.parast.symtablelevel=normal_function_level) and
     (symtablestack.top.symtabletype<>ObjectSymtable) then
    begin
      symtablestack.push(pd._class.symtable);
      old_current_objectdef:=current_objectdef;
      current_objectdef:=pd._class;
      popclass:=true;
    end;
  { Add parameter symtable }
  if pd.parast.symtabletype<>staticsymtable then
    symtablestack.push(pd.parast);
end;

procedure TSemProcHead.ParamsDone(var pd:tprocdef);
begin
  if pd.parast.symtabletype<>staticsymtable then
    symtablestack.pop(pd.parast);
  if popclass then
  begin
    current_objectdef:=old_current_objectdef;
    symtablestack.pop(pd._class.symtable);
  end;
end;

destructor TSemProcHead.Done;
begin
  parse_generic:=old_parse_generic;
end;

{ TSemProcDec }

constructor TSemProcDec.Init;
begin
  locationstr:='';
  //pd:=nil;
end;

procedure TSemProcDec.TypeInit(pd: tprocdef);
begin
  old_parse_generic:=parse_generic;
  inc(testcurobject);
  { Add ObjectSymtable to be able to find generic type definitions }
  popclass:=false;
  if assigned(pd._class) and
    (pd.parast.symtablelevel=normal_function_level) and
    (symtablestack.top.symtabletype<>ObjectSymtable) then
   begin
     symtablestack.push(pd._class.symtable);
     popclass:=true;
     parse_generic:=(df_generic in pd._class.defoptions);
     old_current_objectdef:=current_objectdef;
     current_objectdef:=pd._class;
   end;
end;

procedure TSemProcDec.TypeDone(pd: tprocdef);
begin
  if popclass then
   begin
     current_objectdef:=old_current_objectdef;
     symtablestack.pop(pd._class.symtable);
   end;
  dec(testcurobject);
  parse_generic:=old_parse_generic;
//put this amiga-specific code here, even if it parses an attribute
  if (target_info.system in [system_m68k_amiga]) then
  begin
   if (idtoken=_LOCATION) then
    begin
     if po_explicitparaloc in pd.procoptions then
      begin
       consume(_LOCATION);
       locationstr:=cstringpattern;
       consume(_CSTRING);
      end
     else
      { I guess this needs a new message... (KB) }
      Message(parser_e_paraloc_all_paras);
    end
   else
    begin
     if po_explicitparaloc in pd.procoptions then
      { assign default locationstr, if none specified }
      { and we've arguments with explicit paraloc }
      locationstr:='D0';
    end;
  end;
end;

procedure SMakeClassMethod(pd: tprocdef);
begin
  include(pd.procoptions,po_classmethod);
end;

procedure SMakeProc(pd: tprocdef; isclassmethod: boolean);
begin
  pd.returndef:=voidtype;
  if isclassmethod then
    include(pd.procoptions,po_classmethod); //MakeClassMethod(pd);
end;

procedure SMakeConstructor(pd: tprocdef; isclassmethod: boolean);
begin
  if not isclassmethod and
     assigned(pd) and
     assigned(pd._class) then
    begin
      { Set return type, class constructors return the
        created instance, object constructors return boolean }
      if is_class(pd._class) then
        pd.returndef:=pd._class
      else
{$ifdef CPU64bitaddr}
        pd.returndef:=bool64type;
{$else CPU64bitaddr}
        pd.returndef:=bool32type;
{$endif CPU64bitaddr}
    end
  else
    pd.returndef:=voidtype;
end;

procedure SMakeDestructor(pd: tprocdef);
begin
  if assigned(pd) then
    pd.returndef:=voidtype;
end;

procedure TSemProcDec.Done(pd: tprocdef);
begin
  if locationstr<>'' then
   begin
     if not(paramanager.parsefuncretloc(pd,upper(locationstr))) then
       { I guess this needs a new message... (KB) }
       message(parser_e_illegal_explicit_paraloc);
   end;
end;

end.

