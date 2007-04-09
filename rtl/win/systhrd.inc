{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2002 by Peter Vreman,
    member of the Free Pascal development team.

    Linux (pthreads) threading support implementation

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}


{*****************************************************************************
                           Local WINApi imports
*****************************************************************************}

const
  { LocalAlloc flags  }
  LMEM_FIXED = 0;
  LMEM_ZEROINIT = 64;

{$ifndef WINCE}
function __TlsAlloc : DWord;
  stdcall;external KernelDLL name 'TlsAlloc';
function __TlsFree(dwTlsIndex : DWord) : LongBool;
  stdcall;external KernelDLL name 'TlsFree';
{$endif WINCE}
function __TlsGetValue(dwTlsIndex : DWord) : pointer;
  {$ifdef wince}cdecl{$else}stdcall{$endif};external KernelDLL name 'TlsGetValue';
function __TlsSetValue(dwTlsIndex : DWord;lpTlsValue : pointer) : LongBool;
  {$ifdef wince}cdecl{$else}stdcall{$endif};external KernelDLL name 'TlsSetValue';
function __CreateThread(lpThreadAttributes : pointer;
  dwStackSize : SIZE_T; lpStartAddress : pointer;lpParameter : pointer;
  dwCreationFlags : DWord;var lpThreadId : DWord) : THandle;
  {$ifdef wince}cdecl{$else}stdcall{$endif};external KernelDLL name 'CreateThread';
procedure __ExitThread(dwExitCode : DWord);
  {$ifdef wince}cdecl{$else}stdcall{$endif};external KernelDLL name 'ExitThread';
function __LocalAlloc(uFlags:DWord; dwBytes:DWORD):Pointer;
  {$ifdef wince}cdecl{$else}stdcall{$endif};external KernelDLL name 'LocalAlloc';
function __LocalFree(hMem : Pointer):Pointer; {$ifdef wince}cdecl{$else}stdcall{$endif};external KernelDLL name 'LocalFree';
procedure __Sleep(dwMilliseconds: DWord); {$ifdef wince}cdecl{$else}stdcall{$endif};external KernelDLL name 'Sleep';
function __SuspendThread (threadHandle : THandle) : dword; {$ifdef wince}cdecl{$else}stdcall{$endif};external KernelDLL name 'SuspendThread';
function __ResumeThread  (threadHandle : THandle) : dword; {$ifdef wince}cdecl{$else}stdcall{$endif};external KernelDLL name 'ResumeThread';
function __TerminateThread  (threadHandle : THandle; var exitCode : dword) : boolean; {$ifdef wince}cdecl{$else}stdcall{$endif};external KernelDLL name 'TerminateThread';
function __WaitForSingleObject (hHandle : THandle;Milliseconds: dword): dword; {$ifdef wince}cdecl{$else}stdcall{$endif};external KernelDLL name 'WaitForSingleObject';
function __SetThreadPriority (threadHandle : THandle; Prio: longint): boolean; {$ifdef wince}cdecl{$else}stdcall{$endif};external KernelDLL name 'SetThreadPriority';
function __GetThreadPriority (threadHandle : THandle): LongInt; {$ifdef wince}cdecl{$else}stdcall{$endif};external KernelDLL name 'GetThreadPriority';
{$ifndef WINCE}
function __CreateEvent(lpEventAttributes:pointer;bManualReset:longbool;bInitialState:longbool;lpName:pchar): THandle; stdcall; external KernelDLL name 'CreateEventA';
function __ResetEvent(hEvent:THandle):LONGBOOL; stdcall; external KernelDLL name 'ResetEvent';
function __SetEvent(hEvent:THandle):LONGBOOL; stdcall; external KernelDLL name 'SetEvent';
{$endif WINCE}

const
   WAIT_OBJECT_0 = 0;
   WAIT_ABANDONED_0 = $80;
   WAIT_TIMEOUT = $102;
   WAIT_IO_COMPLETION = $c0;
   WAIT_ABANDONED = $80;
   WAIT_FAILED = $ffffffff;


function WinThreadManagerInit(const ThrdSetup: TThreadSetupHandler; const TlsSize: PtrUInt;
  const TlsInit, TlsFree: TTlsSectionMemoryHandler): Boolean;
begin
  {ThrdSetupHandler := ThrdSetup;
  TlsMemorySize := TlsSize;
  TlsInitHandler := TlsInit;
  TlsFreeHandler := TlsFree;}
  Result := True;
end;

function WinThreadBegin(const StackSize: PtrUInt; const Func: TThreadFunc; const Arg: Pointer; var ThreadId: TThreadID): Boolean;
begin
  Result := False;
end;

procedure WinThreadExit(const ExitCode: PtrInt);
begin
end;

function WinThreadSuspend(const ThreadId: TThreadID): Boolean;
begin
  Result := False;
end;

function WinThreadResume(const ThreadId: TThreadID): Boolean;
begin
  Result := False;
end;

function WinThreadKill(const ThreadId: TThreadID): Boolean;
begin
  Result := False;
end;

procedure WinThreadSwitch;
begin
end;

function WinThreadWaitFor(const ThreadId: TThreadID; const TimeoutMs: Longint): TWaitResult;
begin
  Result := wrError;
end;

function WinThreadSetPriority(const ThreadId: TThreadID; const Prio: TThreadPriority): Boolean;
begin
  Result := False;
end;

function WinThreadGetPriority(const ThreadId: TThreadID): TThreadPriority;
begin
  Result := tpNormal;
end;

function WinThreadGetCurrent: TThreadID;
begin
  Result := 0;
end;

function WinTlsSectionGet: Pointer;
begin
  Result := nil;
end;

function WinMutexCreate: TMutex;
begin
  Result := nil;
end;

procedure WinMutexDestroy(const AMutex: TMutex);
begin
end;

procedure WinMutexLock(const AMutex: TMutex);
begin
end;

procedure WinMutexUnlock(const AMutex: TMutex);
begin
end;

function WinEventCreate(const InitState, ManualReset: Boolean): TEvent;
begin
  Result := nil;
end;

procedure WinEventDestroy(const AEvent: TEvent);
begin
end;

procedure WinEventSet(const AEvent: TEvent);
begin
end;

procedure WinEventReset(const AEvent: TEvent);
begin
end;

function WinEventWaitFor(const AEvent: TEvent; const TimeoutMs: Longint): TWaitResult;
begin
  Result := wrError;
end;

function WinSemaphoreCreate(const Initialcount: Longword): TSemaphore;
begin
  Result := nil;
end;

procedure WinSemaphoreDestroy(const ASemaphore: TSemaphore);
begin
end;

procedure WinSemaphorePost(const ASemaphore: TSemaphore);
begin
end;

function WinSemaphoreWaitFor(const ASemaphore: TSemaphore; const TimeoutMs: Longint): TWaitResult;
begin
  Result := wrError;
end;

const
  WindowsThreadManager: TThreadManager = (
    InitManager            : @WinThreadManagerInit;
    DoneManager            : nil;

  // Thread
    ThreadBegin            : @WinThreadBegin;
    ThreadExit             : @WinThreadExit;
    ThreadSuspend          : @WinThreadSuspend;
    ThreadResume           : @WinThreadResume;
    ThreadKill             : @WinThreadKill;
    ThreadSwitch           : @WinThreadSwitch;
    ThreadWaitFor          : @WinThreadWaitFor;
    ThreadSetPriority      : @WinThreadSetPriority;
    ThreadGetPriority      : @WinThreadGetPriority;
    ThreadGetCurrent       : @WinThreadGetCurrent;

  // TlsSection
    TlsSectionGet          : @WinTlsSectionGet;

  // Mutex
    MutexCreate            : @WinMutexCreate;
    MutexDestroy           : @WinMutexDestroy;
    MutexLock              : @WinMutexLock;
    MutexUnlock            : @WinMutexUnlock;

  // Event
    EventCreate            : @WinEventCreate;
    EventDestroy           : @WinEventDestroy;
    EventSet               : @WinEventSet;
    EventReset             : @WinEventReset;
    EventWaitFor           : @WinEventWaitFor;

  // Semaphore
    SemaphoreCreate        : @WinSemaphoreCreate;
    SemaphoreDestroy       : @WinSemaphoreDestroy;
    SemaphorePost          : @WinSemaphorePost;
    SemaphoreWaitFor       : @WinSemaphoreWaitFor
  );

procedure InitSystemThreads;
begin
  SetThreadManager(WindowsThreadManager);
end;
