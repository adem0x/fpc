{
    This unit is the interface of the compiler which can be used by
    external programs to link in the compiler

    Copyright (c) 1998-2005 by Florian Klaempfl

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

unit compiler;

{$i fpcdefs.inc}

{$ifdef FPC}
   { One of Alpha, I386 or M68K must be defined }
   {$UNDEF CPUOK}

   {$ifdef I386}
   {$define CPUOK}
   {$endif}

   {$ifdef M68K}
   {$ifndef CPUOK}
   {$DEFINE CPUOK}
   {$else}
     {$fatal cannot define two CPU switches}
   {$endif}
   {$endif}

   {$ifdef alpha}
   {$ifndef CPUOK}
   {$DEFINE CPUOK}
   {$else}
     {$fatal cannot define two CPU switches}
   {$endif}
   {$endif}

   {$ifdef vis}
   {$ifndef CPUOK}
   {$DEFINE CPUOK}
   {$else}
     {$fatal cannot define two CPU switches}
   {$endif}
   {$endif}


   {$ifdef powerpc}
   {$ifndef CPUOK}
   {$DEFINE CPUOK}
   {$else}
     {$fatal cannot define two CPU switches}
   {$endif}
   {$endif}

   {$ifdef POWERPC64}
   {$ifndef CPUOK}
   {$DEFINE CPUOK}
   {$else}
     {$fatal cannot define two CPU switches}
   {$endif}
   {$endif}

   {$ifdef ia64}
   {$ifndef CPUOK}
   {$DEFINE CPUOK}
   {$else}
     {$fatal cannot define two CPU switches}
   {$endif}
   {$endif}

   {$ifdef SPARC}
   {$ifndef CPUOK}
   {$DEFINE CPUOK}
   {$else}
     {$fatal cannot define two CPU switches}
   {$endif}
   {$endif}

   {$ifdef x86_64}
   {$ifndef CPUOK}
   {$DEFINE CPUOK}
   {$else}
     {$fatal cannot define two CPU switches}
   {$endif}
   {$endif}

   {$ifdef ARM}
   {$ifndef CPUOK}
   {$DEFINE CPUOK}
   {$else}
     {$fatal cannot define two CPU switches}
   {$endif ARM}
   {$endif ARM}


   {$ifdef MIPS}
   {$ifndef CPUOK}
   {$DEFINE CPUOK}
   {$else}
     {$fatal cannot define two CPU switches}
   {$endif MIPS}
   {$endif MIPS}

   {$ifndef CPUOK}
   {$fatal One of the switches I386, iA64, Alpha, PowerPC or M68K must be defined}
   {$endif}

   {$ifdef support_mmx}
     {$ifndef i386}
       {$fatal I386 switch must be on for MMX support}
     {$endif i386}
   {$endif support_mmx}
{$endif}

interface

uses
{$ifdef fpc}
  {$ifdef GO32V2}
    emu387,
  {$endif GO32V2}
  {$ifdef WATCOM} // wiktor: pewnie nie potrzeba
    emu387,
{    dpmiexcp, }
  {$endif WATCOM}
{$endif}
{$ifdef BrowserLog}
  browlog,
{$endif BrowserLog}
{$IFDEF USE_SYSUTILS}
{$ELSE USE_SYSUTILS}
  dos,
{$ENDIF USE_SYSUTILS}
{$IFNDEF USE_FAKE_SYSUTILS}
  sysutils,
{$ELSE}
  fksysutl,
{$ENDIF}
  verbose,comphook,systems,
  cutils,cclasses,globals,options,fmodule,parser,symtable,
  assemble,link,dbgbase,import,export,tokens,pass_1
  { cpu parameter handling }
  ,cpupara
  { procinfo stuff }
  ,cpupi
  { cpu codegenerator }
  ,cgcpu
{$ifndef NOPASS2}
  ,cpunode
{$endif}
  { cpu targets }
  ,cputarg
  { system information for source system }
  { the information about the target os  }
  { are pulled in by the t_* units       }
{$ifdef amiga}
  ,i_amiga
{$endif amiga}
{$ifdef atari}
  ,i_atari
{$endif atari}
{$ifdef beos}
  ,i_beos
{$endif beos}
{$ifdef fbsd}
  ,i_fbsd
{$endif fbsd}
{$ifdef gba}
  ,i_gba
{$endif gba}
{$ifdef go32v2}
  ,i_go32v2
{$endif go32v2}
{$ifdef linux}
  ,i_linux
{$endif linux}
{$ifdef macos}
  ,i_macos
{$endif macos}
{$ifdef nwm}
  ,i_nwm
{$endif nwm}
{$ifdef nwl}
  ,i_nwl
{$endif nwm}
{$ifdef os2}
 {$ifdef emx}
  ,i_emx
 {$else emx}
  ,i_os2
 {$endif emx}
{$endif os2}
{$ifdef palmos}
  ,i_palmos
{$endif palmos}
{$ifdef solaris}
  ,i_sunos
{$endif solaris}
{$ifdef wdosx}
  ,i_wdosx
{$endif wdosx}
{$ifdef win32}
  ,i_win
{$endif win32}
  ;

function Compile(const cmd:string):longint;


implementation

uses
  aasmcpu;

{$ifdef EXTDEBUG}
  {$define SHOWUSEDMEM}
{$endif}
{$ifdef MEMDEBUG}
  {$define SHOWUSEDMEM}
{$endif}

var
  CompilerInitedAfterArgs,
  CompilerInited : boolean;


{****************************************************************************
                                Compiler
****************************************************************************}

procedure DoneCompiler;
begin
  if not CompilerInited then
   exit;
{ Free compiler if args are read }
{$ifdef BrowserLog}
  DoneBrowserLog;
{$endif BrowserLog}
{$ifdef BrowserCol}
  do_doneSymbolInfo;
{$endif BrowserCol}
  if CompilerInitedAfterArgs then
   begin
     CompilerInitedAfterArgs:=false;
     DoneParser;
     DoneImport;
     DoneExport;
     DoneDebuginfo;
     DoneLinker;
     DoneAssembler;
     DoneAsm;
   end;
{ Free memory for the others }
  CompilerInited:=false;
  DoneSymtable;
  DoneGlobals;
  donetokens;
end;


procedure InitCompiler(const cmd:string);
begin
  if CompilerInited then
   DoneCompiler;
{ inits which need to be done before the arguments are parsed }
  InitSystems;
  { globals depends on source_info so it must be after systems }
  InitGlobals;
  { verbose depends on exe_path and must be after globals }
  InitVerbose;
{$ifdef BrowserLog}
  InitBrowserLog;
{$endif BrowserLog}
{$ifdef BrowserCol}
  do_initSymbolInfo;
{$endif BrowserCol}
  inittokens;
  InitSymtable; {Must come before read_arguments, to enable macrosymstack}
  CompilerInited:=true;
{ this is needed here for the IDE
  in case of compilation failure
  at the previous compile }
  current_module:=nil;
{ read the arguments }
  read_arguments(cmd);
{ inits which depend on arguments }
  InitParser;
  InitImport;
  InitExport;
  InitLinker;
  InitAssembler;
  InitDebugInfo;
  InitAsm;
  CompilerInitedAfterArgs:=true;
end;


function Compile(const cmd:string):longint;

{$ifdef fpc}
{$maxfpuregisters 0}
{$endif fpc}

  procedure writepathlist(w:longint;l:TSearchPathList);
  var
    hp : tstringlistitem;
  begin
    hp:=tstringlistitem(l.first);
    while assigned(hp) do
     begin
       Message1(w,hp.str);
       hp:=tstringlistitem(hp.next);
     end;
  end;

  function getrealtime : real;
  var
{$IFDEF USE_SYSUTILS}
    h,m,s,s1000 : word;
{$ELSE USE_SYSUTILS}
    h,m,s,s100 : word;
{$ENDIF USE_SYSUTILS}
  begin
{$IFDEF USE_SYSUTILS}
    DecodeTime(Time,h,m,s,s1000);
    getrealtime:=h*3600.0+m*60.0+s+s1000/1000.0;
{$ELSE USE_SYSUTILS}
    gettime(h,m,s,s100);
    getrealtime:=h*3600.0+m*60.0+s+s100/100.0;
{$ENDIF USE_SYSUTILS}
  end;

var
  starttime  : real;
  timestr    : string[20];
  linkstr    : string[64];
{$ifdef SHOWUSEDMEM}
  hstatus : TFPCHeapStatus;
{$endif SHOWUSEDMEM}
begin
  try
    try
       { Initialize the compiler }
       InitCompiler(cmd);

       { show some info }
       Message1(general_t_compilername,FixFileName(system.paramstr(0)));
       Message1(general_d_sourceos,source_info.name);
       Message1(general_i_targetos,target_info.name);
       Message1(general_t_exepath,exepath);
       WritePathList(general_t_unitpath,unitsearchpath);
       WritePathList(general_t_includepath,includesearchpath);
       WritePathList(general_t_librarypath,librarysearchpath);
       WritePathList(general_t_objectpath,objectsearchpath);

       starttime:=getrealtime;

       { Compile the program }
  {$ifdef PREPROCWRITE}
       if parapreprocess then
        parser.preprocess(inputdir+inputfile+inputextension)
       else
  {$endif PREPROCWRITE}
        parser.compile(inputdir+inputfile+inputextension);

       { Show statistics }
       if status.errorcount=0 then
        begin
          starttime:=getrealtime-starttime;
          if starttime<0 then
            starttime:=starttime+3600.0*24.0;
          timestr:=tostr(trunc(starttime))+'.'+tostr(trunc(frac(starttime)*10));
          if status.codesize<>-1 then
            linkstr:=', '+tostr(status.codesize)+' ' +strpas(MessagePChar(general_text_bytes_code))+', '+tostr(status.datasize)+' '+strpas(MessagePChar(general_text_bytes_data))
          else
            linkstr:='';
          Message3(general_i_abslines_compiled,tostr(status.compiledlines),timestr,linkstr);
          if (Status.Verbosity and V_Warning = V_Warning) and
                                               (Status.CountWarnings <> 0) then
           Message1 (general_i_number_of_warnings, tostr (Status.CountWarnings));
          if (Status.Verbosity and V_Hint = V_Hint) and
                                                  (Status.CountHints <> 0) then
           Message1 (general_i_number_of_hints, tostr (Status.CountHints));
          if (Status.Verbosity and V_Note = V_Note) and
                                               (Status.CountNotes <> 0) then
           Message1 (general_i_number_of_notes, tostr (Status.CountNotes));
        end;
     finally
       { no message possible after this !!    }
       DoneCompiler;
     end;
     DoneVerbose;
  except

    on EControlCAbort do
      begin
        try
          { in case of 50 errors, this could cause another exception,
            suppress this exception
          }
          Message(general_f_compilation_aborted);
        except
          on ECompilerAbort do
            ;
        end;
        DoneVerbose;
      end;
    on ECompilerAbort do
      begin
        try
          { in case of 50 errors, this could cause another exception,
            suppress this exception
          }
          Message(general_f_compilation_aborted);
        except
          on ECompilerAbort do
            ;
        end;
        DoneVerbose;
      end;
    on ECompilerAbortSilent do
      begin
        DoneVerbose;
      end;
    on Exception do
      begin
        { General catchall, normally not used }
        try
          { in case of 50 errors, this could cause another exception,
            suppress this exception
          }
          Message(general_f_compilation_aborted);
        except
          on ECompilerAbort do
            ;
        end;
        DoneVerbose;
        Raise;
      end;
  end;
{$ifdef SHOWUSEDMEM}
      hstatus:=GetFPCHeapStatus;
      Writeln('Max Memory used/heapsize: ',DStr(hstatus.MaxHeapUsed shr 10),'/',DStr(hstatus.MaxHeapSize shr 10),' Kb');
{$endif SHOWUSEDMEM}

  { Set the return value if an error has occurred }
  if status.errorcount=0 then
    result:=0
  else
    result:=1;
end;

end.
