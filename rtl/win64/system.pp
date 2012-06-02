{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2006 by Florian Klaempfl and Pavel Ozerski
    member of the Free Pascal development team.

    FPC Pascal system unit for the Win64 API.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit System;
interface


{ $define SYSTEMEXCEPTIONDEBUG}

{$ifdef SYSTEMDEBUG}
  {$define SYSTEMEXCEPTIONDEBUG}
{$endif SYSTEMDEBUG}

{$define DISABLE_NO_THREAD_MANAGER}
{$define HAS_WIDESTRINGMANAGER}

{ include system-independent routine headers }
{$I systemh.inc}

const
 LineEnding = #13#10;
 LFNSupport = true;
 DirectorySeparator = '\';
 DriveSeparator = ':';
 ExtensionSeparator = '.';
 PathSeparator = ';';
 AllowDirectorySeparators : set of char = ['\','/'];
 AllowDriveSeparators : set of char = [':'];
{ FileNameCaseSensitive is defined separately below!!! }
 maxExitCode = 65535;
 MaxPathLen = 260;
 AllFilesMask = '*';

type
   PEXCEPTION_FRAME = ^TEXCEPTION_FRAME;
   TEXCEPTION_FRAME = record
     next : PEXCEPTION_FRAME;
     handler : pointer;
   end;

const
{ Default filehandles }
  UnusedHandle    : THandle = THandle(-1);
  StdInputHandle  : THandle = 0;
  StdOutputHandle : THandle = 0;
  StdErrorHandle  : THandle = 0;
  System_exception_frame : PEXCEPTION_FRAME =nil;

  FileNameCaseSensitive : boolean = true;
  CtrlZMarksEOF: boolean = true; (* #26 is considered as end of file *)

  sLineBreak = LineEnding;
  DefaultTextLineBreakStyle : TTextLineBreakStyle = tlbsCRLF;

type
  TStartupInfo = record
    cb : longint;
    lpReserved : Pointer;
    lpDesktop : Pointer;
    lpTitle : Pointer;
    dwX : longint;
    dwY : longint;
    dwXSize : longint;
    dwYSize : longint;
    dwXCountChars : longint;
    dwYCountChars : longint;
    dwFillAttribute : longint;
    dwFlags : longint;
    wShowWindow : Word;
    cbReserved2 : Word;
    lpReserved2 : Pointer;
    hStdInput : THandle;
    hStdOutput : THandle;
    hStdError : THandle;
  end;

var
{ C compatible arguments }
  argc : longint;
  argv : ppchar;
{ Win32 Info }
  startupinfo : tstartupinfo;
  StartupConsoleMode : dword;
  MainInstance : qword;
  cmdshow     : longint;
  DLLreason : dword;
  DLLparam : PtrInt;
const
  hprevinst: qword=0;
type
  TDLL_Entry_Hook = procedure (dllparam : PtrInt);

const
  Dll_Process_Detach_Hook : TDLL_Entry_Hook = nil;
  Dll_Thread_Attach_Hook : TDLL_Entry_Hook = nil;
  Dll_Thread_Detach_Hook : TDLL_Entry_Hook = nil;

Const
  { it can be discussed whether fmShareDenyNone means read and write or read, write and delete, see
    also http://bugs.freepascal.org/view.php?id=8898, this allows users to configure the used
	value
  }
  fmShareDenyNoneFlags : DWord = 3;

implementation

var
  SysInstance : qword;public;

{ used by wstrings.inc because wstrings.inc is included before sysos.inc
  this is put here (FK) }

function SysAllocStringLen(psz:pointer;len:dword):pointer;stdcall;
 external 'oleaut32.dll' name 'SysAllocStringLen';

procedure SysFreeString(bstr:pointer);stdcall;
 external 'oleaut32.dll' name 'SysFreeString';

function SysReAllocStringLen(var bstr:pointer;psz: pointer;
  len:dword): Integer; stdcall;external 'oleaut32.dll' name 'SysReAllocStringLen';


{ include system independent routines }
{$I system.inc}

{*****************************************************************************
                         System Dependent Exit code
*****************************************************************************}

procedure install_exception_handlers;forward;
procedure PascalMain;stdcall;external name 'PASCALMAIN';
procedure fpc_do_exit;stdcall;external name 'FPC_DO_EXIT';
Procedure ExitDLL(Exitcode : longint); forward;

Procedure system_exit;
begin
  { don't call ExitProcess inside
    the DLL exit code !!
    This crashes Win95 at least PM }
  if IsLibrary then
    ExitDLL(ExitCode);
  if not IsConsole then
   begin
     Close(stderr);
     Close(stdout);
     Close(erroutput);
     Close(Input);
     Close(Output);
     { what about Input and Output ?? PM }
     { now handled, FPK }
   end;

  { call exitprocess, with cleanup as required }
  ExitProcess(exitcode);
end;

var
  { old compilers emitted a reference to _fltused if a module contains
    floating type code so the linker could leave away floating point
    libraries or not. VC does this as well so we need to define this
    symbol as well (FK)
  }
  _fltused : int64;cvar;public;
  { value of the stack segment
    to check if the call stack can be written on exceptions }
  _SS : Cardinal;

procedure Exe_entry;[public,alias:'_FPC_EXE_Entry'];
  var
    ST : pointer;
  begin
     IsLibrary:=false;
     { install the handlers for exe only ?
       or should we install them for DLL also ? (PM) }
     install_exception_handlers;
     ExitCode:=0;
     asm
        movq %rsp,%rax
        movq %rax,st
     end;
     StackTop:=st;
     asm
        xorq %rax,%rax
        movw %ss,%ax
        movl %eax,_SS(%rip)
        movq %rbp,%rsi
        xorq %rbp,%rbp
        call PASCALMAIN
        movq %rsi,%rbp
     end ['RSI','RBP'];     { <-- specifying RSI allows compiler to save/restore it properly }
     { if we pass here there was no error ! }
     system_exit;
  end;

function GetConsoleMode(hConsoleHandle: THandle; var lpMode: DWORD): Boolean; stdcall; external 'kernel32' name 'GetConsoleMode';

function Dll_entry{$ifdef FPC_HAS_INDIRECT_MAIN_INFORMATION}(const info : TEntryInformation){$endif FPC_HAS_INDIRECT_MAIN_INFORMATION} : longbool;forward;



procedure _FPC_DLLMainCRTStartup(_hinstance : qword;_dllreason : dword;_dllparam:Pointer);stdcall;public name '_DLLMainCRTStartup';
begin
  IsConsole:=true;
  sysinstance:=_hinstance;
  dllreason:=_dllreason;
  dllparam:=PtrInt(_dllparam);
  DLL_Entry;
end;


procedure _FPC_DLLWinMainCRTStartup(_hinstance : qword;_dllreason : dword;_dllparam:Pointer);stdcall;public name '_DLLWinMainCRTStartup';
begin
  IsConsole:=false;
  sysinstance:=_hinstance;
  dllreason:=_dllreason;
  dllparam:=PtrInt(_dllparam);
  DLL_Entry;
end;

function GetCurrentProcess : dword;
 stdcall;external 'kernel32' name 'GetCurrentProcess';

function ReadProcessMemory(process : dword;address : pointer;dest : pointer;size : dword;bytesread : pdword) :  longbool;
 stdcall;external 'kernel32' name 'ReadProcessMemory';

function is_prefetch(p : pointer) : boolean;
  var
    a : array[0..15] of byte;
    doagain : boolean;
    instrlo,instrhi,opcode : byte;
    i : longint;
  begin
    result:=false;
    { read memory savely without causing another exeception }
    if not(ReadProcessMemory(GetCurrentProcess,p,@a,sizeof(a),nil)) then
      exit;
    i:=0;
    doagain:=true;
    while doagain and (i<15) do
      begin
        opcode:=a[i];
        instrlo:=opcode and $f;
        instrhi:=opcode and $f0;
        case instrhi of
          { prefix? }
          $20,$30:
            doagain:=(instrlo and 7)=6;
          $60:
            doagain:=(instrlo and $c)=4;
          $f0:
            doagain:=instrlo in [0,2,3];
          $0:
            begin
              result:=(instrlo=$f) and (a[i+1] in [$d,$18]);
              exit;
            end;
          else
            doagain:=false;
        end;
        inc(i);
      end;
  end;

{******************************************************************************}
{ include code common with win64 }

{$I syswin.inc}
{******************************************************************************}

//
// Hardware exception handling
//


type
  M128A = record
    Low : QWord;
    High : Int64;
  end;

  PContext = ^TContext;
  TContext = record
    P1Home : QWord;
    P2Home : QWord;
    P3Home : QWord;
    P4Home : QWord;
    P5Home : QWord;
    P6Home : QWord;
    ContextFlags : DWord;
    MxCsr : DWord;
    SegCs : word;
    SegDs : word;
    SegEs : word;
    SegFs : word;
    SegGs : word;
    SegSs : word;
    EFlags : DWord;
    Dr0 : QWord;
    Dr1 : QWord;
    Dr2 : QWord;
    Dr3 : QWord;
    Dr6 : QWord;
    Dr7 : QWord;
    Rax : QWord;
    Rcx : QWord;
    Rdx : QWord;
    Rbx : QWord;
    Rsp : QWord;
    Rbp : QWord;
    Rsi : QWord;
    Rdi : QWord;
    R8 : QWord;
    R9 : QWord;
    R10 : QWord;
    R11 : QWord;
    R12 : QWord;
    R13 : QWord;
    R14 : QWord;
    R15 : QWord;
    Rip : QWord;
    Header : array[0..1] of M128A;
    Legacy : array[0..7] of M128A;
    Xmm0 : M128A;
    Xmm1 : M128A;
    Xmm2 : M128A;
    Xmm3 : M128A;
    Xmm4 : M128A;
    Xmm5 : M128A;
    Xmm6 : M128A;
    Xmm7 : M128A;
    Xmm8 : M128A;
    Xmm9 : M128A;
    Xmm10 : M128A;
    Xmm11 : M128A;
    Xmm12 : M128A;
    Xmm13 : M128A;
    Xmm14 : M128A;
    Xmm15 : M128A;
    VectorRegister : array[0..25] of M128A;
    VectorControl : QWord;
    DebugControl : QWord;
    LastBranchToRip : QWord;
    LastBranchFromRip : QWord;
    LastExceptionToRip : QWord;
    LastExceptionFromRip : QWord;
 end;

type
  PExceptionRecord = ^TExceptionRecord;
  TExceptionRecord = record
    ExceptionCode   : DWord;
    ExceptionFlags  : DWord;
    ExceptionRecord : PExceptionRecord;
    ExceptionAddress : Pointer;
    NumberParameters : DWord;
    ExceptionInformation : array[0..EXCEPTION_MAXIMUM_PARAMETERS-1] of Pointer;
  end;

  PExceptionPointers = ^TExceptionPointers;
  TExceptionPointers = packed record
    ExceptionRecord   : PExceptionRecord;
    ContextRecord     : PContext;
  end;

  TVectoredExceptionHandler = function (excep : PExceptionPointers) : Longint;

function AddVectoredExceptionHandler(FirstHandler : DWORD;VectoredHandler : TVectoredExceptionHandler) : longint;
        external 'kernel32' name 'AddVectoredExceptionHandler';
const
  MaxExceptionLevel = 16;
  exceptLevel : Byte = 0;

var
  exceptRip       : array[0..MaxExceptionLevel-1] of Int64;
  exceptError     : array[0..MaxExceptionLevel-1] of Byte;
  resetFPU        : array[0..MaxExceptionLevel-1] of Boolean;

{$ifdef SYSTEMEXCEPTIONDEBUG}
procedure DebugHandleErrorAddrFrame(error : longint; addr, frame : pointer);
begin
  if IsConsole then
    begin
      write(stderr,'HandleErrorAddrFrame(error=',error);
      write(stderr,',addr=',hexstr(int64(addr),16));
      writeln(stderr,',frame=',hexstr(int64(frame),16),')');
    end;
  HandleErrorAddrFrame(error,addr,frame);
end;
{$endif SYSTEMEXCEPTIONDEBUG}

procedure JumpToHandleErrorFrame;
  var
    rip, rbp : int64;
    error : longint;
  begin
    // save ebp
    asm
      movq (%rbp),%rax
      movq %rax,rbp
    end;
    if exceptLevel>0 then
      dec(exceptLevel);

    rip:=exceptRip[exceptLevel];
    error:=exceptError[exceptLevel];
{$ifdef SYSTEMEXCEPTIONDEBUG}
    if IsConsole then
      writeln(stderr,'In JumpToHandleErrorFrame error=',error);
{$endif SYSTEMEXCEPTIONDEBUG}
    if resetFPU[exceptLevel] then
      SysResetFPU;
    { build a fake stack }
    asm
      movq   rbp,%r8
      movq   rip,%rdx
      movl   error,%ecx
      pushq  rip
      movq   rbp,%rbp // Change frame pointer

{$ifdef SYSTEMEXCEPTIONDEBUG}
      jmpl   DebugHandleErrorAddrFrame
{$else not SYSTEMEXCEPTIONDEBUG}
      jmpl   HandleErrorAddrFrame
{$endif SYSTEMEXCEPTIONDEBUG}
    end;
  end;


function syswin64_x86_64_exception_handler(excep : PExceptionPointers) : Longint;public;
  var
    res: longint;
    err: byte;
    must_reset_fpu: boolean;
  begin
    res:=EXCEPTION_CONTINUE_SEARCH;
{$ifdef SYSTEMEXCEPTIONDEBUG}
    if IsConsole then
      Writeln(stderr,'syswin64_x86_64_exception_handler called');
{$endif SYSTEMEXCEPTIONDEBUG}
    if excep^.ContextRecord^.SegSs=_SS then
      begin
        err := 0;
        must_reset_fpu := true;
{$ifdef SYSTEMEXCEPTIONDEBUG}
        if IsConsole then Writeln(stderr,'Exception ',
          hexstr(excep^.ExceptionRecord^.ExceptionCode,8));
{$endif SYSTEMEXCEPTIONDEBUG}
        case cardinal(excep^.ExceptionRecord^.ExceptionCode) of
          STATUS_INTEGER_DIVIDE_BY_ZERO,
          STATUS_FLOAT_DIVIDE_BY_ZERO :
            err := 200;
          STATUS_ARRAY_BOUNDS_EXCEEDED :
            begin
              err := 201;
              must_reset_fpu := false;
            end;
          STATUS_STACK_OVERFLOW :
            begin
              err := 202;
              must_reset_fpu := false;
            end;
          STATUS_FLOAT_OVERFLOW :
            err := 205;
          STATUS_FLOAT_DENORMAL_OPERAND,
          STATUS_FLOAT_UNDERFLOW :
            err := 206;
            { excep^.ContextRecord^.FloatSave.StatusWord := excep^.ContextRecord^.FloatSave.StatusWord and $ffffff00;}
          STATUS_FLOAT_INEXACT_RESULT,
          STATUS_FLOAT_INVALID_OPERATION,
          STATUS_FLOAT_STACK_CHECK :
            err := 207;
          STATUS_INTEGER_OVERFLOW :
            begin
              err := 215;
              must_reset_fpu := false;
            end;
          STATUS_ILLEGAL_INSTRUCTION:
            err := 216;
          STATUS_ACCESS_VIOLATION:
            { Athlon prefetch bug? }
            if is_prefetch(pointer(excep^.ContextRecord^.rip)) then
              begin
                { if yes, then retry }
                excep^.ExceptionRecord^.ExceptionCode := 0;
                res:=EXCEPTION_CONTINUE_EXECUTION;
              end
            else
              err := 216;

          STATUS_CONTROL_C_EXIT:
            err := 217;
          STATUS_PRIVILEGED_INSTRUCTION:
            begin
              err := 218;
              must_reset_fpu := false;
            end;
          else
            begin
              if ((excep^.ExceptionRecord^.ExceptionCode and SEVERITY_ERROR) = SEVERITY_ERROR) then
                err := 217
              else
                { pass through exceptions which aren't an error. The problem is that vectored handlers
                  always are called before structured ones so we see also internal exceptions of libraries.
                  I wonder if there is a better solution (FK)
                }
                res:=EXCEPTION_CONTINUE_SEARCH;
            end;
        end;

        if (err <> 0) and (exceptLevel < MaxExceptionLevel) then
          begin
            exceptRip[exceptLevel] := excep^.ContextRecord^.Rip;
            exceptError[exceptLevel] := err;
            resetFPU[exceptLevel] := must_reset_fpu;
            inc(exceptLevel);

            excep^.ContextRecord^.Rip := Int64(@JumpToHandleErrorFrame);
            excep^.ExceptionRecord^.ExceptionCode := 0;

            res := EXCEPTION_CONTINUE_EXECUTION;
{$ifdef SYSTEMEXCEPTIONDEBUG}
            if IsConsole then begin
              writeln(stderr,'Exception Continue Exception set at ',
                      hexstr(exceptRip[exceptLevel-1],16));
              writeln(stderr,'Rip changed to ',
                      hexstr(int64(@JumpToHandleErrorFrame),16), ' error=', err);
            end;
{$endif SYSTEMEXCEPTIONDEBUG}
        end;
    end;
    syswin64_x86_64_exception_handler := res;
  end;



procedure install_exception_handlers;
  begin
    AddVectoredExceptionHandler(1,@syswin64_x86_64_exception_handler);
  end;


procedure LinkIn(p1,p2,p3: Pointer); inline;
begin
end;

procedure _FPC_mainCRTStartup;stdcall;public name '_mainCRTStartup';
begin
  IsConsole:=true;
  GetConsoleMode(GetStdHandle((Std_Input_Handle)),StartupConsoleMode);
{$ifdef FPC_USE_TLS_DIRECTORY}
  LinkIn(@_tls_used,@FreePascal_TLS_callback,@FreePascal_end_of_TLS_callback);
{$endif FPC_USE_TLS_DIRECTORY}
  Exe_entry;
end;


procedure _FPC_WinMainCRTStartup;stdcall;public name '_WinMainCRTStartup';
begin
  IsConsole:=false;
{$ifdef FPC_USE_TLS_DIRECTORY}
  LinkIn(@_tls_used,@FreePascal_TLS_callback,@FreePascal_end_of_TLS_callback);
{$endif FPC_USE_TLS_DIRECTORY}
  Exe_entry;
end;


function CheckInitialStkLen(stklen : SizeUInt) : SizeUInt;assembler;
asm
  movq  %gs:(8),%rax
  subq  %gs:(16),%rax
end;


begin
  { pass dummy value }
  StackLength := CheckInitialStkLen($1000000);
  StackBottom := StackTop - StackLength;
  { get some helpful informations }
  GetStartupInfo(@startupinfo);
  { some misc Win32 stuff }
  if not IsLibrary then
    SysInstance:=getmodulehandle(nil);
  MainInstance:=SysInstance;
  cmdshow:=startupinfo.wshowwindow;
  { Setup heap }
  InitHeap;
  SysInitExceptions;
  SysInitStdIO;
  { Arguments }
  setup_arguments;
  { Reset IO Error }
  InOutRes:=0;
  ProcessID := GetCurrentProcessID;
  { threading }
  InitSystemThreads;
  { Reset internal error variable }
  errno:=0;
  initvariantmanager;
  initwidestringmanager;
  initunicodestringmanager;
  InitWin32Widestrings;
  DispCallByIDProc:=@DoDispCallByIDError;
end.
