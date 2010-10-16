{
    Copyright (c) 1998-2002 by Florian Klaempfl, Daniel Mantione, Dr. Diettrich

    Does the codegeneration at subroutine level.
    Parts extracted from subroutines in psub.
}
unit SSub;

{$i fpcdefs.inc}

{$DEFINE semobj} //using semantic Object instead of Class?

interface

uses
  symdef,
  globtype, //for SReadProcBodyInit
  procinfo,
  pdecsub,
  node; //for SBlockVarInitialization

type
  TSemSub = object
  protected
    firstpd : tprocdef;
  public
    old_current_procinfo : tprocinfo;
    old_current_objectdef : tobjectdef;
    pd: tprocdef;
    pdflags    : tpdflags;
  public
    constructor Init; //SSaveProcInfo;
    destructor  Done; //SRestoreProcInfo;
    procedure SDefaultProcOptions;
    procedure SProcDirectivesDone;
    procedure SHandleImports;
    procedure SProcDone;
  end;

procedure SBlockVarInitialization(n: tnode);
procedure SCheckIncompleteClassDefinitions;
procedure SCheckInterfaceIncompleteClassDefinitions;

type
  RReadProcBody = record
    oldfailtokenmode: tmodeswitch;
    isnestedproc: boolean;
    old_current_procinfo: tprocinfo;
  end;

procedure SReadProcBodyInit(var rrpb: RReadProcBody; pd:tprocdef);
procedure SReadProcBodyDone(var rrpb: RReadProcBody; pd:tprocdef);

implementation

uses
  globals,verbose,
  symconst,symsym,symbase,
  fmodule,systems,
  pbase, psub, {SBlockVarInitialization}
  gendef, tokens,
  aasmbase,aasmdata, ncgutil;

const //debug: ambiguous symbol, also in system.pas
  IsLibrary = 'dummy';

procedure SBlockVarInitialization(n: tnode);
begin
//from ParseBlock (former block)
  if current_procinfo.procdef.localst.symtabletype=localsymtable then
    current_procinfo.procdef.localst.SymList.ForEachCall(@initializevars,n);
end;

{ can these procedures/calls be unified? }
procedure SCheckIncompleteClassDefinitions;
begin
//from end of read_declarations()
  if (m_fpc in current_settings.modeswitches) then
    current_procinfo.procdef.localst.
      SymList.ForEachCall(@check_forward_class,nil);
end;
procedure SCheckInterfaceIncompleteClassDefinitions;
begin
//from end of read_interface_declarations()
  if (m_fpc in current_settings.modeswitches) then
    symtablestack.top.
      SymList.ForEachCall(@check_forward_class,nil);
end;

procedure SReadProcBodyInit(var rrpb: RReadProcBody; pd:tprocdef);
begin
  Message1(parser_d_procedure_start,pd.fullprocname(false));
{ create a new procedure }
  current_procinfo:=cprocinfo.create(rrpb.old_current_procinfo);
  current_module.procinfo:=current_procinfo;
  current_procinfo.procdef:=pd;
  rrpb.isnestedproc:=(current_procinfo.procdef.parast.symtablelevel>normal_function_level);
{ Insert mangledname }
  pd.aliasnames.insert(pd.mangledname);
{ Handle Export of this procedure }
  if (po_exports in pd.procoptions) and
     (target_info.system in [system_i386_os2,system_i386_emx]) then
    begin
      pd.aliasnames.insert(pd.procsym.realname);
      if cs_link_deffile in current_settings.globalswitches then
        deffile.AddExport(pd.mangledname);
    end;
{ Insert result variables in the localst }
  insert_funcret_local(pd);
{ check if there are para's which require initing -> set }
  { pi_do_call (if not yet set)                            }
  if not(pi_do_call in current_procinfo.flags) then
    pd.parast.SymList.ForEachCall(@check_init_paras,nil);
{ set _FAIL as keyword if constructor }
  if (pd.proctypeoption=potype_constructor) then
   begin
     rrpb.oldfailtokenmode:=tokeninfo^[_FAIL].keyword;
     tokeninfo^[_FAIL].keyword:=m_all;
   end;
end;

procedure SReadProcBodyDone(var rrpb: RReadProcBody; pd:tprocdef);
begin
{ We can't support inlining for procedures that have nested
    procedures because the nested procedures use a fixed offset
    for accessing locals in the parent procedure (PFV) }
  if (tcgprocinfo(current_procinfo).nestedprocs.count>0) then
    begin
      if (df_generic in current_procinfo.procdef.defoptions) then
        Comment(V_Error,'Generic methods cannot have nested procedures')
      else
       if (po_inline in current_procinfo.procdef.procoptions) then
        begin
          Message1(parser_w_not_supported_for_inline,'nested procedures');
          Message(parser_w_inlining_disabled);
          exclude(current_procinfo.procdef.procoptions,po_inline);
        end;
    end;
{ When it's a nested procedure then defer the code generation,
    when back at normal function level then generate the code
    for all defered nested procedures and the current procedure }
  if rrpb.isnestedproc then
    tcgprocinfo(current_procinfo.parent).nestedprocs.insert(current_procinfo)
  else if not(df_generic in current_procinfo.procdef.defoptions) then
        tcgprocinfo(current_procinfo).do_generate_code;
{ reset _FAIL as _SELF normal }
  if (pd.proctypeoption=potype_constructor) then
    tokeninfo^[_FAIL].keyword:=rrpb.oldfailtokenmode;
{ release procinfo }
  if tprocinfo(current_module.procinfo)<>current_procinfo then
    internalerror(200304274);
  current_module.procinfo:=current_procinfo.parent;
end;

{ TSemSub }

//constructor TSemSub.Create;
//procedure TSemSub.SSaveProcInfo;
constructor TSemSub.Init;
begin
//from read_proc
{ save old state }
  old_current_procinfo:=current_procinfo;
  old_current_objectdef:=current_objectdef;
{ reset current_procinfo.procdef to nil to be sure that nothing is writing
   to another procdef }
  current_procinfo:=nil;
  current_objectdef:=nil;
end;

//destructor TSemSub.Destroy;
//procedure TSemSub.SRestoreProcInfo;
destructor TSemSub.Done;
begin
//from read_proc
  current_objectdef:=old_current_objectdef;
  current_procinfo:=old_current_procinfo;
end;

procedure TSemSub.SDefaultProcOptions;
begin
//from read_proc
{ set the default function options }
  if parse_only then
  begin
    pd.forwarddef:=true;
    { set also the interface flag, for better error message when the
      implementation doesn't much this header }
    pd.interfacedef:=true;
    include(pd.procoptions,po_global);
    pdflags:=[pd_interface];
  end
  else
  begin
    pdflags:=[pd_body];
    if (not current_module.in_interface) then
      include(pdflags,pd_implemen);
    if (not current_module.is_unit) or
       create_smartlink or
      {
        taking addresses of static procedures goes wrong
        if they aren't global when pic is used (FK)
      }
      (cs_create_pic in current_settings.moduleswitches) then
      include(pd.procoptions,po_global);
    pd.forwarddef:=false;
  end;
end;

procedure TSemSub.SProcDirectivesDone;
begin
//from read_proc
{ Set calling convention }
  handle_calling_convention(pd);
{ search for forward declarations }
  if not proc_add_definition(pd) then
  begin
   { A method must be forward defined (in the object declaration) }
   if assigned(pd._class)
   and (not assigned(old_current_objectdef)) then begin
      MessagePos1(pd.fileinfo,parser_e_header_dont_match_any_member,pd.fullprocname(false));
      tprocsym(pd.procsym).write_parameter_lists(pd);
   end else begin
    { Give a better error if there is a forward def in the interface and only
        a single implementation }
      firstpd:=tprocdef(tprocsym(pd.procsym).ProcdefList[0]);
      if (not pd.forwarddef) and (not pd.interfacedef)
      and (tprocsym(pd.procsym).ProcdefList.Count>1)
      and firstpd.forwarddef and firstpd.interfacedef
      and not(tprocsym(pd.procsym).ProcdefList.Count>2)
      and { don't give an error if it may be an overload }
         not(m_fpc in current_settings.modeswitches)
      and (not(po_overload in pd.procoptions)
          or not(po_overload in firstpd.procoptions))
      then begin
         MessagePos1(pd.fileinfo,parser_e_header_dont_match_forward,pd.fullprocname(false));
         tprocsym(pd.procsym).write_parameter_lists(pd);
      end;
    end;
  end;
{ Set mangled name }
  proc_set_mangledname(pd);
end;

procedure TSemSub.SHandleImports;
var
  s          : string;
begin  //SHandleImports
//from read_proc
{ Handle imports }
  if not (po_external in pd.procoptions) then
    exit;

  { External declared in implementation, and there was already a
  forward (or interface) declaration then we need to generate
  a stub that calls the external routine }
  if (not pd.forwarddef) and (pd.hasforward)
  and not(assigned(pd.import_dll)
        and (target_info.system in [system_i386_wdosx,
                              system_arm_wince,system_i386_wince]) )
  then begin
    s:=proc_get_importname(pd);
    if s<>'' then
      gen_external_stub(current_asmdata.asmlists[al_procedures],pd,s);
  end;

  { Import DLL specified? }
  if assigned(pd.import_dll) then
    current_module.AddExternalImport(pd.import_dll^,proc_get_importname(pd),pd.import_nr,false,pd.import_name=nil)
  else begin
   { add import name to external list for DLL scanning }
   if tf_has_dllscanner in target_info.flags then
     current_module.dllscannerinputlist.Add(proc_get_importname(pd),pd);
  end;
end;

procedure TSemSub.SProcDone;
begin //SProcDone
//from read_proc
{ make sure that references to forward-declared functions are not }
  { treated as references to external symbols, needed for darwin.   }
{ make sure we don't change the binding of real external symbols }
  if not(po_external in pd.procoptions) then
  begin
   if (po_global in pd.procoptions) or
      (cs_profile in current_settings.moduleswitches) then
     current_asmdata.DefineAsmSymbol(pd.mangledname,AB_GLOBAL,AT_FUNCTION)
   else
     current_asmdata.DefineAsmSymbol(pd.mangledname,AB_LOCAL,AT_FUNCTION);
  end;
end;

end.

