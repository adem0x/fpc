unit semantics;
(* Implements parser semantic initialization and actions, by DoDi.

  The interface part of this unit can be used for any (new) OPL parser.

  The implementation part implements the FPC compiler stuff.
  It's borrowed from the parser and other p* units.
*)

{$mode objfpc}

interface

procedure parser_init;
procedure parser_done;
procedure module_init;
procedure module_done;

implementation

uses
{$IFNDEF USE_FAKE_SYSUTILS}
      sysutils,
{$ELSE}
      fksysutl,
{$ENDIF}
      cutils,cclasses,
      globtype,version,tokens,systems,globals,verbose,switches,
      symbase,symtable,symdef,symsym,
      finput,fmodule,fppu,aasmdata,
      script,gendef,
      comphook,
      scanner,scandir,
      pbase,ptype,psystem,pmodules,psub,ncgrtti,htypechk,
      cpuinfo, procinfo;

procedure parser_init;
begin
(* Semantics part of InitParser (code generation)
*)
         current_asmdata:=nil;
         current_procinfo:=nil;
         current_objectdef:=nil;

         { register all nodes and tais }
         registernodes;
         registertais;

         { memory sizes }
         if stacksize=0 then
           stacksize:=target_info.stacksize;

         { RTTI writer }
         RTTIWriter:=TRTTIWriter.Create;

         { open assembler response }
         if cs_link_on_target in current_settings.globalswitches then
           GenerateAsmRes(outputexedir+ChangeFileExt(inputfilename,'_ppas'))
         else
           GenerateAsmRes(outputexedir+'ppas');

         { open deffile }
         DefFile:=TDefFile.Create(outputexedir+ChangeFileExt(inputfilename,target_info.defext));

         { list of generated .o files, so the linker can remove them }
         SmartLinkOFiles:=TCmdStrList.Create;

         { codegen }
         if paraprintnodetree<>0 then
           printnode_reset;

         { target specific stuff }
         case target_info.system of
           system_powerpc_amiga:
             include(supported_calling_conventions,pocall_syscall);
           system_powerpc_morphos:
             include(supported_calling_conventions,pocall_syscall);
           system_m68k_amiga:
             include(supported_calling_conventions,pocall_syscall);
         end;
end;

procedure parser_done;
begin
         //current_module:=nil;
         current_procinfo:=nil;
         //current_asmdata:=nil;
         current_objectdef:=nil;

         RTTIWriter.free;

         { close ppas,deffile }
         asmres.free;
         deffile.free;

         { free list of .o files }
         SmartLinkOFiles.Free;
end;

// ---------------- Compile a module --------------------

(* Compiler state of recursive calls.
  Since this record has become a heap object, we make it a class.
  The constructor saves the current state and pushes the object onto the CompilerStack,
  the destructor restores the last (saved) state and pops the object off the stack.
*)
type
  tolddata=class
  private
  //chain
    old_data: tolddata;
    restored: boolean;
  public
  { scanner }
    oldidtoken,
    oldtoken       : ttoken;
    oldtokenpos    : tfileposinfo;
    oldc           : char;
    oldpattern,
    oldorgpattern  : string;
    old_block_type : tblock_type;
  { symtable }
    oldsymtablestack,
    oldmacrosymtablestack : TSymtablestack;
    oldaktprocsym    : tprocsym;
  { cg }
    oldparse_only  : boolean;
  { akt.. things }
    oldcurrent_filepos      : tfileposinfo;
    old_current_module : tmodule;
    oldcurrent_procinfo : tprocinfo;
    old_settings : tsettings;
    oldsourcecodepage : tcodepagestring;
    old_switchesstatestack : tswitchesstatestack;
    old_switchesstatestackpos : Integer;
  public  //methods to save and restore an compiler state
    constructor Create;
    destructor  Destroy; override;
    procedure Restore;
  end;
  //polddata=tolddata;  //obsolete

var
  CompilerStack: tolddata;

{ tolddata }

constructor tolddata.Create;
begin
  old_current_module:=current_module;

  { save symtable state }
  oldsymtablestack:=symtablestack;
  oldmacrosymtablestack:=macrosymtablestack;
  oldcurrent_procinfo:=current_procinfo;

  { save scanner state }
  oldc:=c;
  oldpattern:=pattern;
  oldorgpattern:=orgpattern;
  oldtoken:=token;
  oldidtoken:=idtoken;
  old_block_type:=block_type;
  oldtokenpos:=current_tokenpos;
  old_switchesstatestack:=switchesstatestack;
  old_switchesstatestackpos:=switchesstatestackpos;

  { save cg }
  oldparse_only:=parse_only;

  { save akt... state }
  { handle the postponed case first }
  flushpendingswitchesstate;
  oldcurrent_filepos:=current_filepos;
  old_settings:=current_settings;

//link into state stack
  old_data := CompilerStack;
  CompilerStack := Self;

//symbol stacks
   //symtablestack:=TSymtablestack.create;
   //macrosymtablestack:=TSymtablestack.create;
end;

destructor tolddata.Destroy;
begin
  if not restored then
    Restore;

  set_current_module(old_current_module);

//handle symbol stacks?
(* for symmetry reasons, either the stacks are created and destroyed in this class,
  or must be managed outside, if their (old) content may be of further interest.
*)

//unlink
  CompilerStack := old_data;

  inherited Destroy;  //nop
end;

procedure tolddata.Restore;
begin
  { restore scanner }
  c:=oldc;
  pattern:=oldpattern;
  orgpattern:=oldorgpattern;
  token:=oldtoken;
  idtoken:=oldidtoken;
  current_tokenpos:=oldtokenpos;
  block_type:=old_block_type;
  switchesstatestack:=old_switchesstatestack;
  switchesstatestackpos:=old_switchesstatestackpos;

  { restore cg }
  parse_only:=oldparse_only;

  { restore symtable state }
  symtablestack:=oldsymtablestack;
  macrosymtablestack:=oldmacrosymtablestack;
  current_procinfo:=oldcurrent_procinfo;
  current_filepos:=oldcurrent_filepos;
  current_settings:=old_settings;
  current_exceptblock:=0;
  exceptblockcounter:=0;

  restored := True;
end;

procedure module_init; //(const filename:string);
(* Initialize module compilation (code generation framework)
  The filename is available in parser_current_file.
*)
begin
   inc(compile_level);
   //parser_current_file:=filename;
   { Uses heap memory instead of placing everything on the
     stack. This is needed because compile() can be called
     recursively }
   tolddata.Create;  //new(olddata);

 { reset parser, a previous fatal error could have left these variables in an unreliable state, this is
   important for the IDE }
   afterassignment:=false;
   in_args:=false;
   named_args_allowed:=false;
   got_addrn:=false;
   getprocvardef:=nil;
   allow_array_constructor:=false;

{ TODO : the following should be moved
into compile_module - as far as the framework (module...) is affected - or
into TOldData create/destroy (symbol stacks)
}
//---
 { show info }
   //Message1(parser_i_compiling,filename); --> compile_module

 { reset symtable }
   //symtablestack:=TSymtablestack.create;
   //macrosymtablestack:=TSymtablestack.create;
   systemunit:=nil;
   current_settings.defproccall:=init_settings.defproccall;
   current_exceptblock:=0;
   exceptblockcounter:=0;
   current_settings.maxfpuregisters:=-1;
 //---

 { reset the unit or create a new program }
   { a unit compiled at command line must be inside the loaded_unit list }
   if (compile_level=1) then
     begin
       if assigned(current_module) then
         internalerror(200501158);
       //set_current_module(tppumodule.create(nil,filename,'',false));
       set_current_module(tppumodule.create(nil,parser_current_file,'',false));
       addloadedunit(current_module);
       main_module:=current_module;
       current_module.state:=ms_compile;
     end;
   if not(assigned(current_module) and
          (current_module.state in [ms_compile,ms_second_compile])) then
     internalerror(200212281);

   { load current asmdata from current_module }
   current_asmdata:=TAsmData(current_module.asmdata);
end; //pre_compile

procedure module_done;
(* This was the finally part of compile(), excluding scanner finalization.
*)
var
 //olddata : polddata; - moved into tolddata
 hp,hp2 : tmodule;
begin
   if assigned(current_module) then
     begin
       { module is now compiled }
       tppumodule(current_module).state:=ms_compiled;

       { free ppu }
       if assigned(tppumodule(current_module).ppufile) then
         begin
           tppumodule(current_module).ppufile.free;
           tppumodule(current_module).ppufile:=nil;
         end;

       { free asmdata }
       if assigned(current_module.asmdata) then
         begin
           current_module.asmdata.free;
           current_module.asmdata:=nil;
         end;
     end; //assigned(current_module)

    if (compile_level=1) and
       (status.errorcount=0) then
      { Write Browser Collections }
      do_extractsymbolinfo;

   CompilerStack.Restore;

    { Shut down things when the last file is compiled succesfull }
    if (compile_level=1) and
        (status.errorcount=0) then
      begin
        parser_current_file:='';
        { Close script }
        if (not AsmRes.Empty) then
        begin
          Message1(exec_i_closing_script,AsmRes.Fn);
          AsmRes.WriteToDisk;
        end;
      end;

  { free now what we did not free earlier in
    proc_program PM }
  if (compile_level=1) and needsymbolinfo then
    begin
      hp:=tmodule(loaded_units.first);
      while assigned(hp) do
       begin
         hp2:=tmodule(hp.next);
         if (hp<>current_module) then
           begin
             loaded_units.remove(hp);
             hp.free;
           end;
         hp:=hp2;
       end;
      { free also unneeded units we didn't free before }
      unloaded_units.Clear;
     end;
   dec(compile_level);

   //set_current_module(olddata^.old_current_module); - in TCompilerStatus.destroy
   CompilerStack.Free; //dispose(olddata);
end;


end.

