{
    Copyright (c) 1998-2002 by Florian Klaempfl

    This unit implements some support functions and global variables

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
unit globals;

{$i fpcdefs.inc}

interface

    uses
{$ifdef win32}
      windows,
{$endif}
{$ifdef os2}
      dos,
{$endif os2}
{$ifdef hasunix}
      Baseunix,unix,
{$endif}

{$IFNDEF USE_FAKE_SYSUTILS}
      sysutils,
{$ELSE}
      fksysutl,
{$ENDIF}

      { comphook pulls in sysutils anyways }
      cutils,cclasses,cfileutils,
      cpuinfo,
      globtype,version,systems;

    const
       delphimodeswitches : tmodeswitches=
         [m_delphi,m_all,m_class,m_objpas,m_result,m_string_pchar,
          m_pointer_2_procedure,m_autoderef,m_tp_procvar,m_initfinal,m_default_ansistring,
          m_out,m_default_para,m_duplicate_names,m_hintdirective,m_add_pointer,
          m_property,m_default_inline,m_except];
       fpcmodeswitches    : tmodeswitches=
         [m_fpc,m_all,m_string_pchar,m_nested_comment,m_repeat_forward,
          m_cvar_support,m_initfinal,m_add_pointer,m_hintdirective,
          m_property,m_default_inline];
       objfpcmodeswitches : tmodeswitches=
         [m_objfpc,m_fpc,m_all,m_class,m_objpas,m_result,m_string_pchar,m_nested_comment,
          m_repeat_forward,m_cvar_support,m_initfinal,m_add_pointer,m_out,m_default_para,m_hintdirective,
          m_property,m_default_inline,m_except];
       tpmodeswitches     : tmodeswitches=
         [m_tp7,m_all,m_tp_procvar,m_duplicate_names];
       gpcmodeswitches    : tmodeswitches=
         [m_gpc,m_all,m_tp_procvar];
       macmodeswitches : tmodeswitches=
         [m_mac,m_all,m_result,m_cvar_support,m_mac_procvar];

       { maximum nesting of routines }
       maxnesting = 32;

       { Filenames and extensions }
       sourceext  = '.pp';
       pasext     = '.pas';
       pext       = '.p';

       treelogfilename = 'tree.log';

{$if defined(CPUARM) and defined(FPUFPA)}
       MathQNaN : tdoublerec = (bytes : (0,0,252,255,0,0,0,0));
       MathInf : tdoublerec = (bytes : (0,0,240,127,0,0,0,0));
       MathNegInf : tdoublerec = (bytes : (0,0,240,255,0,0,0,0));
       MathPi : tdoublerec =  (bytes : (251,33,9,64,24,45,68,84));
{$else}
{$ifdef FPC_LITTLE_ENDIAN}
       MathQNaN : tdoublerec = (bytes : (0,0,0,0,0,0,252,255));
       MathInf : tdoublerec = (bytes : (0,0,0,0,0,0,240,127));
       MathNegInf : tdoublerec = (bytes : (0,0,0,0,0,0,240,255));
       MathPi : tdoublerec = (bytes : (24,45,68,84,251,33,9,64));
       MathPiExtended : textendedrec = (bytes : (53,194,104,33,162,218,15,201,0,64));
{$else FPC_LITTLE_ENDIAN}
       MathQNaN : tdoublerec = (bytes : (255,252,0,0,0,0,0,0));
       MathInf : tdoublerec = (bytes : (127,240,0,0,0,0,0,0));
       MathNegInf : tdoublerec = (bytes : (255,240,0,0,0,0,0,0));
       MathPi : tdoublerec =  (bytes : (64,9,33,251,84,68,45,24));
       MathPiExtended : textendedrec = (bytes : (64,0,201,15,218,162,33,104,194,53));
{$endif FPC_LITTLE_ENDIAN}
{$endif}

    type
       TFPUException = (exInvalidOp, exDenormalized, exZeroDivide,
                        exOverflow, exUnderflow, exPrecision);
       TFPUExceptionMask = set of TFPUException;

       pfileposinfo = ^tfileposinfo;
       tfileposinfo = record
         line      : longint;
         column    : word;
         fileindex : word;
         moduleindex : word;
       end;

       tcodepagestring = string[20];

       tsettings = record
         globalswitches  : tglobalswitches;
         moduleswitches  : tmoduleswitches;
         localswitches   : tlocalswitches;
         modeswitches    : tmodeswitches;
         optimizerswitches : toptimizerswitches;
         { 0: old behaviour for sets <=256 elements
           >0: round to this size }
         setalloc,
         packenum        : shortint;
         alignment       : talignmentinfo;
         cputype,
         optimizecputype : tcputype;
         fputype         : tfputype;
         asmmode         : tasmmode;
         interfacetype   : tinterfacetypes;
         defproccall     : tproccalloption;
         sourcecodepage  : tcodepagestring;

         packrecords     : shortint;
         maxfpuregisters : shortint;
       end;

    var
       { specified inputfile }
       inputfilepath     : string;
       inputfilename     : string;
       { specified outputfile with -o parameter }
       outputfilename    : string;
       outputprefix      : pshortstring;
       outputsuffix      : pshortstring;
       { specified with -FE or -FU }
       outputexedir      : TPathStr;
       outputunitdir     : TPathStr;

       { things specified with parameters }
       paratarget        : tsystem;
       paratargetdbg     : tdbg;
       paratargetasm     : tasm;
       paralinkoptions,
       paradynamiclinker : string;
       paraprintnodetree : byte;
       parapreprocess    : boolean;
       printnodefile     : text;

       {  typical cross compiling params}

       { directory where the utils can be found (options -FD) }
       utilsdirectory : TPathStr;
       { targetname specific prefix used by these utils (options -XP<path>) }
       utilsprefix    : TPathStr;
       cshared        : boolean;        { pass --shared to ld to link C libs shared}
       Dontlinkstdlibpath: Boolean;     { Don't add std paths to linkpath}
       rlinkpath      : TPathStr;         { rpath-link linkdir override}

       { some flags for global compiler switches }
       do_build,
       do_release,
       do_make       : boolean;
       { path for searching units, different paths can be seperated by ; }
       exepath            : TPathStr;  { Path to ppc }
       librarysearchpath,
       unitsearchpath,
       objectsearchpath,
       includesearchpath  : TSearchPathList;
       autoloadunits      : string;

       { linking }
       usewindowapi  : boolean;
       description   : string;
       SetPEFlagsSetExplicity,
       ImageBaseSetExplicity,
       MinStackSizeSetExplicity,
       MaxStackSizeSetExplicity,
       DescriptionSetExplicity : boolean;
       dllversion    : string;
       dllmajor,
       dllminor,
       dllrevision   : word;  { revision only for netware }
       { win pe  }
       peflags : longint;
       minstacksize,
       maxstacksize,
       imagebase : aword;
       UseDeffileForExports    : boolean;
       UseDeffileForExportsSetExplicitly : boolean;
       GenerateImportSection,
       GenerateImportSectionSetExplicitly,
       RelocSection : boolean;
       RelocSectionSetExplicitly : boolean;
       LinkTypeSetExplicitly : boolean;

       current_tokenpos,                       { position of the last token }
       current_filepos : tfileposinfo;    { current position }

       nwscreenname : string;
       nwthreadname : string;
       nwcopyright  : string;

       codegenerror : boolean;           { true if there is an error reported }

       block_type : tblock_type;         { type of currently parsed block }

       parsing_para_level : integer;     { parameter level, used to convert
                                           proc calls to proc loads in firstcalln }
       compile_level : word;
       make_ref : boolean;
       resolving_forward : boolean;      { used to add forward reference as second ref }
       inlining_procedure : boolean;     { are we inlining a procedure }
       exceptblockcounter    : integer;  { each except block gets a unique number check gotos      }
       aktexceptblock        : integer;  { the exceptblock number of the current block (0 if none) }
       LinkLibraryAliases : TLinkStrMap;
       LinkLibraryOrder   : TLinkStrMap;

       init_settings,
       current_settings   : tsettings;

       nextlocalswitches : tlocalswitches;
       localswitcheschanged : boolean;

     { Memory sizes }
       heapsize,
       stacksize,
       jmp_buf_size : longint;

{$Ifdef EXTDEBUG}
     { parameter switches }
       debugstop : boolean;
{$EndIf EXTDEBUG}
       { windows / OS/2 application type }
       apptype : tapptype;

    const
       DLLsource : boolean = false;
       DLLImageBase : pshortstring = nil;

       { used to set all registers used for each global function
         this should dramatically decrease the number of
         recompilations needed PM }
       simplify_ppu : boolean = true;

       { should we allow non static members ? }
       allow_only_static : boolean = false;

       Inside_asm_statement : boolean = false;

       global_unit_count : word = 0;

       { for error info in pp.pas }
       parser_current_file : string = '';

{$if defined(m68k) or defined(arm)}
       { PalmOS resources }
       palmos_applicationname : string = 'FPC Application';
       palmos_applicationid : string[4] = 'FPCA';
{$endif defined(m68k) or defined(arm)}

{$ifdef powerpc}
       { default calling convention used on MorphOS }
       syscall_convention : string = 'LEGACY';
{$endif powerpc}

       { default name of the C-style "main" procedure of the library/program }
       { (this will be prefixed with the target_info.cprefix)                }
       mainaliasname : string = 'main';

       { by default no local variable trashing }
       localvartrashing: longint = -1;
       { actual values are defined in ncgutil.pas }
       nroftrashvalues = 4;

    procedure abstract;

    function bstoslash(const s : string) : string;

    function getdatestr:string;
    function gettimestr:string;
    function filetimestring( t : longint) : string;

    procedure DefaultReplacements(var s:string);

    function Shell(const command:string): longint;
    function  GetEnvPChar(const envname:string):pchar;
    procedure FreeEnvPChar(p:pchar);

    procedure SetFPUExceptionMask(const Mask: TFPUExceptionMask);
    function is_number_float(d : double) : boolean;
    { discern +0.0 and -0.0 }
    function get_real_sign(r: bestreal): longint;

    procedure InitGlobals;
    procedure DoneGlobals;

    function  string2guid(const s: string; var GUID: TGUID): boolean;
    function  guid2string(const GUID: TGUID): string;

    function SetAktProcCall(const s:string; var a:tproccalloption):boolean;
    function Setcputype(const s:string;var a:tcputype):boolean;
    function SetFpuType(const s:string;var a:tfputype):boolean;
    function UpdateAlignmentStr(s:string;var a:talignmentinfo):boolean;
    function UpdateOptimizerStr(s:string;var a:toptimizerswitches):boolean;

    {# Routine to get the required alignment for size of data, which will
       be placed in bss segment, according to the current alignment requirements }
    function var_align(siz: shortint): shortint;
    {# Routine to get the required alignment for size of data, which will
       be placed in data/const segment, according to the current alignment requirements }
    function const_align(siz: shortint): shortint;

implementation

    uses
{$ifdef macos}
      macutils,
{$endif}
      comphook;

    procedure abstract;
      begin
        do_internalerror(255);
      end;


    function bstoslash(const s : string) : string;
    {
      return string s with all \ changed into /
    }
      var
         i : longint;
      begin
        for i:=1to length(s) do
         if s[i]='\' then
          bstoslash[i]:='/'
         else
          bstoslash[i]:=s[i];
         bstoslash[0]:=s[0];
      end;


{****************************************************************************
                               Time Handling
****************************************************************************}

    Function L0(l:longint):string;
    {
      return the string of value l, if l<10 then insert a zero, so
      the string is always at least 2 chars '01','02',etc
    }
      var
        s : string;
      begin
        Str(l,s);
        if l<10 then
         s:='0'+s;
        L0:=s;
      end;


   function gettimestr:string;
   {
     get the current time in a string HH:MM:SS
   }
      var
        hour,min,sec,hsec : word;
      begin
        DecodeTime(Time,hour,min,sec,hsec);
        gettimestr:=L0(Hour)+':'+L0(min)+':'+L0(sec);
      end;


   function getdatestr:string;
   {
     get the current date in a string YY/MM/DD
   }
      var
        Year,Month,Day: Word;
      begin
        DecodeDate(Date,year,month,day);
        getdatestr:=L0(Year)+'/'+L0(Month)+'/'+L0(Day);
      end;


   function  filetimestring( t : longint) : string;
   {
     convert dos datetime t to a string YY/MM/DD HH:MM:SS
   }
     var
       DT : TDateTime;
       hsec : word;
       Year,Month,Day: Word;
       hour,min,sec : word;
     begin
       if t=-1 then
        begin
          Result := 'Not Found';
          exit;
        end;
       DT := FileDateToDateTime(t);
       DecodeTime(DT,hour,min,sec,hsec);
       DecodeDate(DT,year,month,day);
       Result := L0(Year)+'/'+L0(Month)+'/'+L0(Day)+' '+L0(Hour)+':'+L0(min)+':'+L0(sec);
     end;


{****************************************************************************
                          Default Macro Handling
****************************************************************************}

     procedure DefaultReplacements(var s:string);
       begin
         { Replace some macros }
         Replace(s,'$FPCVERSION',version_string);
         Replace(s,'$FPCFULLVERSION',full_version_string);
         Replace(s,'$FPCDATE',date_string);
         Replace(s,'$FPCCPU',target_cpu_string);
         Replace(s,'$FPCOS',target_os_string);
         if tf_use_8_3 in Source_Info.Flags then
           Replace(s,'$FPCTARGET',target_os_string)
         else
           Replace(s,'$FPCTARGET',target_full_string);
       end;


 {****************************************************************************
                               OS Dependent things
 ****************************************************************************}

    function GetEnvPChar(const envname:string):pchar;
      {$ifdef win32}
      var
        s     : string;
        i,len : longint;
        hp,p,p2 : pchar;
      {$endif}
      begin
      {$ifdef hasunix}
        GetEnvPchar:=BaseUnix.fpGetEnv(envname);
        {$define GETENVOK}
      {$endif}
      {$ifdef win32}
        GetEnvPchar:=nil;
        p:=GetEnvironmentStrings;
        hp:=p;
        while hp^<>#0 do
         begin
           s:=strpas(hp);
           i:=pos('=',s);
           len:=strlen(hp);
           if upper(copy(s,1,i-1))=upper(envname) then
            begin
              GetMem(p2,len-length(envname));
              Move(hp[i],p2^,len-length(envname));
              GetEnvPchar:=p2;
              break;
            end;
           { next string entry}
           hp:=hp+len+1;
         end;
        FreeEnvironmentStrings(p);
        {$define GETENVOK}
      {$endif}
      {$ifdef os2}
        GetEnvPChar := Dos.GetEnvPChar (EnvName);
        {$define GETENVOK}
      {$endif}
      {$ifdef GETENVOK}
        {$undef GETENVOK}
      {$else}
        GetEnvPchar:=StrPNew(GetEnvironmentVariable(envname));
      {$endif}
      end;


    procedure FreeEnvPChar(p:pchar);
      begin
      {$ifndef hasunix}
       {$ifndef os2}
        freemem(p);
       {$endif}
      {$endif}
      end;

{$if defined(MORPHOS) or defined(AMIGA)}
  {$define AMIGASHELL}
{$endif}

    function Shell(const command:string): longint;
      { This is already defined in the linux.ppu for linux, need for the *
        expansion under linux }
{$ifdef hasunix}
      begin
        result := Unix.Shell(command);
      end;
{$else hasunix}
  {$ifdef amigashell}
      begin
        result := ExecuteProcess('',command);
      end;
  {$else amigashell}
      var
        comspec : string;
      begin
        comspec:=GetEnvironmentVariable('COMSPEC');
        result := ExecuteProcess(comspec,' /C '+command);
      end;
   {$endif amigashell}
{$endif hasunix}

{$UNDEF AMIGASHELL}

{$ifdef CPUI386}
  {$asmmode att}

  {$define HASSETFPUEXCEPTIONMASK}
      { later, this should be replaced by the math unit }
      const
        Default8087CW : word = $1332;

      procedure Set8087CW(cw:word);assembler;
        asm
          movw cw,%ax
          movw %ax,default8087cw
          fnclex
          fldcw default8087cw
        end;


      function Get8087CW:word;assembler;
        asm
          pushl $0
          fnstcw (%esp)
          popl %eax
        end;


      procedure SetFPUExceptionMask(const Mask: TFPUExceptionMask);
        var
          CtlWord: Word;
        begin
          CtlWord:=Get8087CW;
          Set8087CW( (CtlWord and $FFC0) or Byte(Longint(Mask)) );
        end;
{$endif CPUI386}

{$ifdef CPUX86_64}
  {$define HASSETFPUEXCEPTIONMASK}
      { later, this should be replaced by the math unit }
      const
        Default8087CW : word = $1332;

      procedure Set8087CW(cw:word);assembler;
        asm
          movw cw,%ax
          movw %ax,default8087cw
          fnclex
          fldcw default8087cw
        end;


      function Get8087CW:word;assembler;
        asm
          pushq $0
          fnstcw (%rsp)
          popq %rax
        end;


      procedure SetSSECSR(w : dword);
        var
          _w : dword;
        begin
          _w:=w;
          asm
            ldmxcsr _w
          end;
        end;


      function GetSSECSR : dword;
          var
            _w : dword;
          begin
            asm
              stmxcsr _w
            end;
            result:=_w;
          end;


      procedure SetFPUExceptionMask(const Mask: TFPUExceptionMask);
        var
          CtlWord: Word;
          newmask : dword;
        const
          MM_MaskInvalidOp = %0000000010000000;
          MM_MaskDenorm    = %0000000100000000;
          MM_MaskDivZero   = %0000001000000000;
          MM_MaskOverflow  = %0000010000000000;
          MM_MaskUnderflow = %0000100000000000;
          MM_MaskPrecision = %0001000000000000;
        begin
          { classic FPU }
          CtlWord:=Get8087CW;
          Set8087CW( (CtlWord and $FFC0) or Byte(Longint(Mask)) );

          { SSE }

          newmask:=GetSSECSR;

          { invalid operation }
          if (exInvalidOp in mask) then
            newmask:=newmask or MM_MaskInvalidOp
          else
            newmask:=newmask and not(MM_MaskInvalidOp);

          { denormals }
          if (exDenormalized in mask) then
            newmask:=newmask or MM_MaskDenorm
          else
            newmask:=newmask and not(MM_MaskDenorm);

          { zero divide }
          if (exZeroDivide in mask) then
            newmask:=newmask or MM_MaskDivZero
          else
            newmask:=newmask and not(MM_MaskDivZero);

          { overflow }
          if (exOverflow in mask) then
            newmask:=newmask or MM_MaskOverflow
          else
            newmask:=newmask and not(MM_MaskOverflow);

          { underflow }
          if (exUnderflow in mask) then
            newmask:=newmask or MM_MaskUnderflow
          else
            newmask:=newmask and not(MM_MaskUnderflow);

          { Precision (inexact result) }
          if (exPrecision in mask) then
            newmask:=newmask or MM_MaskPrecision
          else
            newmask:=newmask and not(MM_MaskPrecision);
          SetSSECSR(newmask);
        end;
{$endif CPUX86_64}

{$ifdef CPUPOWERPC}
  {$define HASSETFPUEXCEPTIONMASK}
      procedure SetFPUExceptionMask(const Mask: TFPUExceptionMask);
        var
          newmask: record
            case byte of
               1: (d: double);
               2: (a,b: cardinal);
            end;
        begin
          { load current control register contents }
          asm
            mffs f0
            stfd f0,newmask.d
          end;
          { invalid operation: bit 24 (big endian, bit 0 = left-most bit) }
          if (exInvalidOp in mask) then
            newmask.b := newmask.b and not(1 shl (31-24))
          else
            newmask.b := newmask.b or (1 shl (31-24));

          { denormals can not cause exceptions on the PPC }

          { zero divide: bit 27 }
          if (exZeroDivide in mask) then
            newmask.b := newmask.b and not(1 shl (31-27))
          else
            newmask.b := newmask.b or (1 shl (31-27));

          { overflow: bit 25 }
          if (exOverflow in mask) then
            newmask.b := newmask.b and not(1 shl (31-25))
          else
            newmask.b := newmask.b or (1 shl (31-25));

          { underflow: bit 26 }
          if (exUnderflow in mask) then
            newmask.b := newmask.b and not(1 shl (31-26))
          else
            newmask.b := newmask.b or (1 shl (31-26));

          { Precision (inexact result): bit 28 }
          if (exPrecision in mask) then
            newmask.b := newmask.b and not(1 shl (31-28))
          else
            newmask.b := newmask.b or (1 shl (31-28));
          { update control register contents }
          asm
            lfd   f0, newmask.d
            mtfsf 255,f0
          end;
        end;
{$endif CPUPOWERPC}

{$ifdef CPUSPARC}
  {$define HASSETFPUEXCEPTIONMASK}
      procedure SetFPUExceptionMask(const Mask: TFPUExceptionMask);
        var
          fsr : cardinal;
        begin
          { load current control register contents }
          asm
            st %fsr,fsr
          end;
          { invalid operation: bit 27 }
          if (exInvalidOp in mask) then
            fsr:=fsr and not(1 shl 27)
          else
            fsr:=fsr or (1 shl 27);

          { zero divide: bit 24 }
          if (exZeroDivide in mask) then
            fsr:=fsr and not(1 shl 24)
          else
            fsr:=fsr or (1 shl 24);

          { overflow: bit 26 }
          if (exOverflow in mask) then
            fsr:=fsr and not(1 shl 26)
          else
            fsr:=fsr or (1 shl 26);

          { underflow: bit 25 }
          if (exUnderflow in mask) then
            fsr:=fsr and not(1 shl 25)
          else
            fsr:=fsr or (1 shl 25);

          { Precision (inexact result): bit 23 }
          if (exPrecision in mask) then
            fsr:=fsr and not(1 shl 23)
          else
            fsr:=fsr or (1 shl 23);
          { update control register contents }
          asm
            ld fsr,%fsr
          end;
        end;
{$endif CPUSPARC}

{$ifndef HASSETFPUEXCEPTIONMASK}
      procedure SetFPUExceptionMask(const Mask: TFPUExceptionMask);
        begin
        end;
{$endif HASSETFPUEXCEPTIONMASK}

      function is_number_float(d : double) : boolean;
        var
           bytearray : array[0..7] of byte;
        begin
          move(d,bytearray,8);
          { only 1.1 save, 1.0.x will use always little endian }
{$ifdef FPC_BIG_ENDIAN}
          result:=((bytearray[0] and $7f)<>$7f) or ((bytearray[1] and $f0)<>$f0);
{$else FPC_BIG_ENDIAN}
          result:=((bytearray[7] and $7f)<>$7f) or ((bytearray[6] and $f0)<>$f0);
{$endif FPC_BIG_ENDIAN}
        end;

    function get_real_sign(r: bestreal): longint;
      var
        p: pbyte;
      begin
        p := pbyte(@r);
{$ifdef CPU_ARM}
        inc(p,4);
{$else}
{$ifdef FPC_LITTLE_ENDIAN}
        inc(p,sizeof(r)-1);
{$endif}
{$endif}
        if (p^ and $80) = 0 then
          result := 1
        else
          result := -1;
      end;

    function convertdoublerec(d : tdoublerec) : tdoublerec;{$ifdef USEINLINE}inline;{$endif}
{$ifdef CPUARM}
      var
        i : longint;
      begin
        for i:=0 to 3 do
          begin
            result.bytes[i+4]:=d.bytes[i];
            result.bytes[i]:=d.bytes[i+4];
          end;
{$else CPUARM}
      begin
        result:=d;
{$endif CPUARM}
      end;


    { '('D1:'00000000-'D2:'0000-'D3:'0000-'D4:'0000-000000000000)' }
    function string2guid(const s: string; var GUID: TGUID): boolean;
        function ishexstr(const hs: string): boolean;
          var
            i: integer;
          begin
            ishexstr:=false;
            for i:=1 to Length(hs) do begin
              if not (hs[i] in ['0'..'9','A'..'F','a'..'f']) then
                exit;
            end;
            ishexstr:=true;
          end;
        function hexstr2longint(const hexs: string): longint;
          var
            i: integer;
            rl: longint;
          begin
            rl:=0;
            for i:=1 to length(hexs) do begin
              rl:=rl shl 4;
              case hexs[i] of
                '0'..'9' : inc(rl,ord(hexs[i])-ord('0'));
                'A'..'F' : inc(rl,ord(hexs[i])-ord('A')+10);
                'a'..'f' : inc(rl,ord(hexs[i])-ord('a')+10);
              end
            end;
            hexstr2longint:=rl;
          end;
      var
        i: integer;
      begin
        if (Length(s)=38) and (s[1]='{') and (s[38]='}') and
           (s[10]='-') and (s[15]='-') and (s[20]='-') and (s[25]='-') and
           ishexstr(copy(s,2,8)) and ishexstr(copy(s,11,4)) and
           ishexstr(copy(s,16,4)) and ishexstr(copy(s,21,4)) and
           ishexstr(copy(s,26,12)) then begin
          GUID.D1:=dword(hexstr2longint(copy(s,2,8)));
          { these values are arealdy in the correct range (4 chars = word) }
          GUID.D2:=word(hexstr2longint(copy(s,11,4)));
          GUID.D3:=word(hexstr2longint(copy(s,16,4)));
          for i:=0 to 1 do
            GUID.D4[i]:=byte(hexstr2longint(copy(s,21+i*2,2)));
          for i:=2 to 7 do
            GUID.D4[i]:=byte(hexstr2longint(copy(s,22+i*2,2)));
          string2guid:=true;
        end
        else
          string2guid:=false;
      end;


    function guid2string(const GUID: TGUID): string;
        function long2hex(l, len: longint): string;
          const
            hextbl: array[0..15] of char = '0123456789ABCDEF';
          var
            rs: string;
            i: integer;
          begin
            rs[0]:=chr(len);
            for i:=len downto 1 do begin
              rs[i]:=hextbl[l and $F];
              l:=l shr 4;
            end;
            long2hex:=rs;
          end;
      begin
        guid2string:=
          '{'+long2hex(GUID.D1,8)+
          '-'+long2hex(GUID.D2,4)+
          '-'+long2hex(GUID.D3,4)+
          '-'+long2hex(GUID.D4[0],2)+long2hex(GUID.D4[1],2)+
          '-'+long2hex(GUID.D4[2],2)+long2hex(GUID.D4[3],2)+
              long2hex(GUID.D4[4],2)+long2hex(GUID.D4[5],2)+
              long2hex(GUID.D4[6],2)+long2hex(GUID.D4[7],2)+
          '}';
      end;


    function SetAktProcCall(const s:string; var a:tproccalloption):boolean;
      const
        DefProcCallName : array[tproccalloption] of string[12] = ('',
         'CDECL',
         'CPPDECL',
         'FAR16',
         'OLDFPCCALL',
         '', { internproc }
         '', { syscall }
         'PASCAL',
         'REGISTER',
         'SAFECALL',
         'STDCALL',
         'SOFTFLOAT',
         'MWPASCAL'
        );
      var
        t  : tproccalloption;
        hs : string;
      begin
        result:=false;
        if (s = '') then
          exit;
        hs:=upper(s);
        if (hs = 'DEFAULT') then
          begin
            a := pocall_default;
            result := true;
            exit;
          end;
        for t:=low(tproccalloption) to high(tproccalloption) do
         if DefProcCallName[t]=hs then
          begin
            a:=t;
            result:=true;
            break;
          end;
      end;


    function Setcputype(const s:string;var a:tcputype):boolean;
      var
        t  : tcputype;
        hs : string;
      begin
        result:=false;
        hs:=Upper(s);
        for t:=low(tcputype) to high(tcputype) do
          if cputypestr[t]=hs then
            begin
              a:=t;
              result:=true;
              break;
            end;
      end;


    function SetFpuType(const s:string;var a:tfputype):boolean;
      var
        t : tfputype;
      begin
        result:=false;
        for t:=low(tfputype) to high(tfputype) do
          if fputypestr[t]=s then
            begin
              a:=t;
              result:=true;
              break;
            end;
      end;


    function UpdateAlignmentStr(s:string;var a:talignmentinfo):boolean;
      var
        tok  : string;
        vstr : string;
        l    : longint;
        code : integer;
        b    : talignmentinfo;
      begin
        UpdateAlignmentStr:=true;
        uppervar(s);
        fillchar(b,sizeof(b),0);
        repeat
          tok:=GetToken(s,'=');
          if tok='' then
           break;
          vstr:=GetToken(s,',');
          val(vstr,l,code);
          if tok='PROC' then
           b.procalign:=l
          else if tok='JUMP' then
           b.jumpalign:=l
          else if tok='LOOP' then
           b.loopalign:=l
          else if tok='CONSTMIN' then
           b.constalignmin:=l
          else if tok='CONSTMAX' then
           b.constalignmax:=l
          else if tok='VARMIN' then
           b.varalignmin:=l
          else if tok='VARMAX' then
           b.varalignmax:=l
          else if tok='LOCALMIN' then
           b.localalignmin:=l
          else if tok='LOCALMAX' then
           b.localalignmax:=l
          else if tok='RECORDMIN' then
           b.recordalignmin:=l
          else if tok='RECORDMAX' then
           b.recordalignmax:=l
          else { Error }
           UpdateAlignmentStr:=false;
        until false;
        UpdateAlignment(a,b);
      end;


    function UpdateOptimizerStr(s:string;var a:toptimizerswitches):boolean;
      var
        tok   : string;
        doset,
        found : boolean;
        opt   : toptimizerswitch;
      begin
        result:=true;
        uppervar(s);
        repeat
          tok:=GetToken(s,',');
          if tok='' then
           break;
          if Copy(tok,1,2)='NO' then
            begin
              delete(tok,1,2);
              doset:=false;
            end
          else
            doset:=true;
          found:=false;
          for opt:=low(toptimizerswitch) to high(toptimizerswitch) do
            begin
              if OptimizerSwitchStr[opt]=tok then
                begin
                  found:=true;
                  break;
                end;
            end;
          if found then
            begin
              if doset then
                include(a,opt)
              else
                exclude(a,opt);
            end
          else
            result:=false;
        until false;
      end;


    function var_align(siz: shortint): shortint;
      begin
        siz := size_2_align(siz);
        var_align := used_align(siz,current_settings.alignment.varalignmin,current_settings.alignment.varalignmax);
      end;


    function const_align(siz: shortint): shortint;
      begin
        siz := size_2_align(siz);
        const_align := used_align(siz,current_settings.alignment.constalignmin,current_settings.alignment.constalignmax);
      end;


{****************************************************************************
                                    Init
****************************************************************************}

{$ifdef unix}
  {$define need_path_search}
{$endif unix}
{$ifdef os2}
  {$define need_path_search}
{$endif os2}
{$ifdef macos}
  {$define need_path_search}
{$endif macos}

   procedure get_exepath;
     var
       exeName:String;
{$ifdef need_path_search}
       hs1 : TPathStr;
       p   : pchar;
{$endif need_path_search}
     begin
       exepath:=GetEnvironmentVariable('PPC_EXEC_PATH');
       if exepath='' then
         begin
           exeName := FixFileName(system.paramstr(0));
           exepath := ExtractFilePath(exeName);
         end;
{$ifdef need_path_search}
       if exepath='' then
        begin
          hs1 := ExtractFileName(exeName);
          ChangeFileExt(hs1,source_info.exeext);
{$ifdef macos}
          p:=GetEnvPchar('Commands');
{$else macos}
          p:=GetEnvPchar('PATH');
{$endif macos}
          FindFilePChar(hs1,p,exepath);
          FreeEnvPChar(p);
          exepath:=ExtractFilePath(exepath);
        end;
{$endif need_path_search}
       exepath:=FixPath(exepath,false);
     end;



   procedure DoneGlobals;
     begin
       if assigned(DLLImageBase) then
         StringDispose(DLLImageBase);
       librarysearchpath.Free;
       unitsearchpath.Free;
       objectsearchpath.Free;
       includesearchpath.Free;
     end;

   procedure InitGlobals;
     begin
        get_exepath;

        { reset globals }
        do_build:=false;
        do_release:=false;
        do_make:=true;
        compile_level:=0;
        DLLsource:=false;
        inlining_procedure:=false;
        resolving_forward:=false;
        make_ref:=false;
        LinkTypeSetExplicitly:=false;
        paratarget:=system_none;
        paratargetasm:=as_none;
        paratargetdbg:=dbg_none;

        { Output }
        OutputFileName:='';
        OutputPrefix:=Nil;
        OutputSuffix:=Nil;

        OutputExeDir:='';
        OutputUnitDir:='';

        { Utils directory }
        utilsdirectory:='';
        utilsprefix:='';
        cshared:=false;
        rlinkpath:='';

        { Search Paths }
        librarysearchpath:=TSearchPathList.Create;
        unitsearchpath:=TSearchPathList.Create;
        includesearchpath:=TSearchPathList.Create;
        objectsearchpath:=TSearchPathList.Create;

        { Def file }
        usewindowapi:=false;
        description:='Compiled by FPC '+version_string+' - '+target_cpu_string;
        DescriptionSetExplicity:=false;
        SetPEFlagsSetExplicity:=false;
        ImageBaseSetExplicity:=false;
        MinStackSizeSetExplicity:=false;
        MaxStackSizeSetExplicity:=false;

        dllversion:='';
        dllmajor:=1;
        dllminor:=0;
        dllrevision:=0;
        nwscreenname := '';
        nwthreadname := '';
        nwcopyright  := '';
        UseDeffileForExports:=false;
        UseDeffileForExportsSetExplicitly:=false;
        GenerateImportSection:=false;
        RelocSection:=false;
        RelocSectionSetExplicitly:=false;
        LinkTypeSetExplicitly:=false;
        { memory sizes, will be overriden by parameter or default for target
          in options or init_parser }
        stacksize:=0;
        { not initialized yet }
        jmp_buf_size:=-1;
        apptype:=app_cui;

        { Init values }
        init_settings.modeswitches:=fpcmodeswitches;
        init_settings.localswitches:=[cs_check_io,cs_typed_const_writable];
        init_settings.moduleswitches:=[cs_extsyntax,cs_implicit_exceptions];
        init_settings.globalswitches:=[cs_check_unit_name,cs_link_static];
        init_settings.optimizerswitches:=[];
        init_settings.sourcecodepage:='8859-1';
        init_settings.packenum:=4;
        init_settings.setalloc:=0;
        fillchar(init_settings.alignment,sizeof(talignmentinfo),0);
        { might be overridden later }
        init_settings.asmmode:=asmmode_standard;
        init_settings.cputype:=cpu_none;
        init_settings.optimizecputype:=cpu_none;
        init_settings.fputype:=fpu_none;
        init_settings.interfacetype:=it_interfacecom;
        init_settings.defproccall:=pocall_default;

        { Target specific defaults, these can override previous default options }
{$ifdef i386}
        init_settings.cputype:=cpu_Pentium;
        init_settings.optimizecputype:=cpu_Pentium3;
        init_settings.fputype:=fpu_x87;
{$endif i386}
{$ifdef m68k}
        init_settings.cputype:=cpu_MC68020;
        init_settings.fputype:=fpu_soft;
{$endif m68k}
{$ifdef powerpc}
        init_settings.cputype:=cpu_PPC604;
        init_settings.fputype:=fpu_standard;
{$endif powerpc}
{$ifdef POWERPC64}
        init_settings.cputype:=cpu_PPC970;
        init_settings.fputype:=fpu_standard;
{$endif POWERPC64}
{$ifdef sparc}
        init_settings.cputype:=cpu_SPARC_V8;
        init_settings.fputype:=fpu_hard;
{$endif sparc}
{$ifdef arm}
        init_settings.cputype:=cpu_armv3;
        init_settings.fputype:=fpu_fpa;
{$endif arm}
{$ifdef x86_64}
        init_settings.cputype:=cpu_athlon64;
        init_settings.fputype:=fpu_sse64;
{$endif x86_64}
        if init_settings.optimizecputype=cpu_none then
          init_settings.optimizecputype:=init_settings.cputype;

        LinkLibraryAliases :=TLinkStrMap.Create;
        LinkLibraryOrder   :=TLinkStrMap.Create;

     end;

end.
