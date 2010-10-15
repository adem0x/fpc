{
    Copyright (c) 1998-2002 by Florian Klaempfl, Daniel Mantione, Dr. Diettrich

    Does the codegeneration at subroutine level.
    Parts extracted from subroutines in psub.
}
unit SSub;

{$i fpcdefs.inc}

interface

uses
  symdef,
  procinfo,
  pdecsub,
  node; //for SBlockVarInitialization

type
  TSemSub = class
  protected
    firstpd : tprocdef;
  public
    old_current_procinfo : tprocinfo;
    old_current_objectdef : tobjectdef;
    pd: tprocdef;
    pdflags    : tpdflags;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SDefaultProcOptions;
    procedure SProcDirectivesDone;
    procedure SHandleImports;
    procedure SProcDone;
  end;

procedure SBlockVarInitialization(n: tnode);
procedure SCheckIncompleteClassDefinitions;

implementation

uses
  globtype,globals,verbose,
  symconst,symsym,
  fmodule,systems,
  pbase, psub, {SBlockVarInitialization}

  aasmbase,aasmdata, ncgutil;

const //debug: ambiguous symbol, also in system.pas
  IsLibrary = 'dummy';

procedure SBlockVarInitialization(n: tnode);
begin
  if current_procinfo.procdef.localst.symtabletype=localsymtable then
    current_procinfo.procdef.localst.SymList.ForEachCall(@initializevars,n);
end;

procedure SCheckIncompleteClassDefinitions;
begin
  if (m_fpc in current_settings.modeswitches) then
    current_procinfo.procdef.localst.SymList.ForEachCall(@check_forward_class,nil);
end;

{ TSemSub }

constructor TSemSub.Create;
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

destructor TSemSub.Destroy;
begin
  current_objectdef:=old_current_objectdef;
  current_procinfo:=old_current_procinfo;
end;

procedure TSemSub.SDefaultProcOptions;
begin
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

