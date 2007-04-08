{
    This file is part of the Free Pascal Run time library.
    Copyright (c) 2000 by the Free Pascal development team

    OS independent thread functions/overloads

    See the File COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}


{*****************************************************************************
      ThreadManager which gives run-time error. Use if no thread support.
*****************************************************************************}

{ resourcestrings are not supported by the system unit,
  they are in the objpas unit and not available for fpc/tp modes }
const
  SNoThreads = 'This binary has no thread support compiled in.';
  SRecompileWithThreads = 'Recompile the application with a thread-driver in the program uses clause before other units using thread.';

procedure NoThreadError(const Func: String);
begin
{$ifdef FPC_HAS_FEATURE_CONSOLEIO}
  if IsConsole then
  begin
    Writeln(StdErr, Func, ': ', SNoThreads);
    Writeln(StdErr, SRecompileWithThreads);
  end;
{$endif FPC_HAS_FEATURE_CONSOLEIO}
  RunError(232);
end;

function NoThreadManagerInit(const ThrdSetup: TThreadSetupHandler; const TlsSize: PtrUInt;
  const TlsInit, TlsFree: TTlsSectionMemoryHandler): Boolean;
begin
  Result := False;
end;

function NoThreadBegin(const StackSize: PtrUInt; const Func: TThreadFunc; const Arg: Pointer; var ThreadId: TThreadID): Boolean;
begin
  NoThreadError('No ThreadBegin');
  Result := False;
end;

procedure NoThreadExit(const ExitCode: PtrInt);
begin
  NoThreadError('No ThreadExit');
end;

function NoThreadSuspend(const ThreadId: TThreadID): Boolean;
begin
  NoThreadError('No ThreadSuspend');
  Result := False;
end;

function NoThreadResume(const ThreadId: TThreadID): Boolean;
begin
  NoThreadError('No ThreadResume');
  Result := False;
end;

function NoThreadKill(const ThreadId: TThreadID): Boolean;
begin
  NoThreadError('No ThreadKill');
  Result := False;
end;

procedure NoThreadSwitch;
begin
  NoThreadError('No ThreadSwitch');
end;

function NoThreadWaitFor(const ThreadId: TThreadID; const TimeoutMs: Longint): TWaitResult;
begin
  NoThreadError('No ThreadWaitFor');
  Result := wrError;
end;

function NoThreadSetPriority(const ThreadId: TThreadID; const Prio: TThreadPriority): Boolean;
begin
  NoThreadError('No ThreadSetPriority');
  Result := False;
end;

function NoThreadGetPriority(const ThreadId: TThreadID): TThreadPriority;
begin
  NoThreadError('No ThreadGetPriority');
  Result := tpNormal;
end;

function NoThreadGetCurrent: TThreadID;
begin
  NoThreadError('No ThreadGetCurrent');
  Result := 0;
end;

function NoTlsSectionGet: Pointer;
begin
  NoThreadError('No TlsSectionGet');
  Result := nil;
end;

function NoMutexCreate: PMutex;
begin
  NoThreadError('No MutexCreate');
  Result := nil;
end;

procedure NoMutexDestroy(const AMutex: PMutex);
begin
  NoThreadError('No MutexDestroy');
end;

procedure NoMutexLock(const AMutex: PMutex);
begin
  NoThreadError('No MutexLock');
end;

procedure NoMutexUnlock(const AMutex: PMutex);
begin
  NoThreadError('No MutexUnlock');
end;

function NoEventCreate(const InitState, ManualReset: Boolean): PEvent;
begin
  NoThreadError('No EventCreate');
  Result := nil;
end;

procedure NoEventDestroy(const AEvent: PEvent);
begin
  NoThreadError('No EventDestroy');
end;

procedure NoEventSet(const AEvent: PEvent);
begin
  NoThreadError('No EventSet');
end;

procedure NoEventReset(const AEvent: PEvent);
begin
  NoThreadError('No EventReset');
end;

function NoEventWaitFor(const AEvent: PEvent; const TimeoutMs: Longint): TWaitResult;
begin
  NoThreadError('No EventWaitFor');
  Result := wrError;
end;

function NoSemaphoreCreate(const Initialcount: Longword): PSemaphore;
begin
  NoThreadError('No SemaphoreCreate');
  Result := nil;
end;

procedure NoSemaphoreDestroy(const ASemaphore: PSemaphore);
begin
  NoThreadError('No SemaphoreDestroy');
end;

procedure NoSemaphorePost(const ASemaphore: PSemaphore);
begin
  NoThreadError('No SemaphorePost');
end;

function NoSemaphoreWaitFor(const ASemaphore: PSemaphore; const TimeoutMs: Longint): TWaitResult;
begin
  NoThreadError('No SemaphoreWaitFor');
  Result := wrError;
end;

const
  NoThreadManager: TThreadManager = (
    InitManager            : @NoThreadManagerInit;
    DoneManager            : nil;

  // Thread
    ThreadBegin            : @NoThreadBegin;
    ThreadExit             : @NoThreadExit;
    ThreadSuspend          : @NoThreadSuspend;
    ThreadResume           : @NoThreadResume;
    ThreadKill             : @NoThreadKill;
    ThreadSwitch           : @NoThreadSwitch;
    ThreadWaitFor          : @NoThreadWaitFor;
    ThreadSetPriority      : @NoThreadSetPriority;
    ThreadGetPriority      : @NoThreadGetPriority;
    ThreadGetCurrent       : @NoThreadGetCurrent;

  // TlsSection
    TlsSectionGet          : @NoTlsSectionGet;

  // Mutex
    MutexCreate            : @NoMutexCreate;
    MutexDestroy           : @NoMutexDestroy;
    MutexLock              : @NoMutexLock;
    MutexUnlock            : @NoMutexUnlock;

  // Event
    EventCreate            : @NoEventCreate;
    EventDestroy           : @NoEventDestroy;
    EventSet               : @NoEventSet;
    EventReset             : @NoEventReset;
    EventWaitFor           : @NoEventWaitFor;

  // Semaphore
    SemaphoreCreate        : @NoSemaphoreCreate;
    SemaphoreDestroy       : @NoSemaphoreDestroy;
    SemaphorePost          : @NoSemaphorePost;
    SemaphoreWaitFor       : @NoSemaphoreWaitFor
  );



{*****************************************************************************
                         Thread Handler routines
*****************************************************************************}

procedure ThreadSetup(const Stack: Pointer; const StackSize: PtrUInt);
begin
  if not IsMultiThread then
    IsMultiThread := True;

  { install threadvar handler }
  if fpc_threadvar_relocate_proc = nil then
    fpc_threadvar_relocate_proc := @ThreadVarLocate;

  SysResetFPU;
  { ExceptAddrStack and ExceptObjectStack are threadvars       }
  { so every thread has its on exception handling capabilities }
  SysInitExceptions;
  { Open all stdio fds again }
  SysInitStdio;
  InOutRes := 0;
  // ErrNo := 0;
  { Stack checking }
  // maybe check if Sptr is inside the range of Stack and Stack-StackSize
  StackLength := CheckInitialStkLen(StackSize);
  StackBottom := Stack - StackLength;
  StackTop := Stack;
  ThreadID := __CurrentTM.ThreadGetCurrent();
end;

{$ifndef HAS_MT_MEMORYMANAGER}
var
  HeapMutex : PMutex;

procedure HeapMutexInit;
begin
  HeapMutex := __CurrentTM.MutexCreate;
end;

procedure HeapMutexDone;
begin
  __CurrentTM.MutexDestroy(HeapMutex);
end;

procedure HeapMutexLock;
begin
  __CurrentTM.MutexLock(HeapMutex);
end;

procedure HeapMutexUnlock;
begin
  __CurrentTM.MutexUnlock(HeapMutex);
end;

const
  HeapMutexManager: TMemoryMutexManager = (
    MutexInit   : @HeapMutexInit;
    MutexDone   : @HeapMutexDone;
    MutexLock   : @HeapMutexLock;
    MutexUnlock : @HeapMutexUnlock;
  );
{$endif HAS_MT_MEMORYMANAGER}

function GetThreadManager(var Manager: TThreadManager): Boolean;
begin
  Manager := __CurrentTM;
  Result := True;
end;

function SetThreadManager(const NewManager: TThreadManager; var OldManager: TThreadManager): Boolean;
begin
  GetThreadManager(OldManager);
  Result := SetThreadManager(NewManager);
end;

function SetThreadManager(const NewManager: TThreadManager): Boolean;
var
  OldManager: TThreadManager;
begin
  if IsMultiThread then
    Exit(False);

  OldManager := __CurrentTM;
{$ifndef HAS_MT_MEMORYMANAGER}
  SetMemoryMutexManager(MemoryMutexManager);
{$endif HAS_MT_MEMORYMANAGER}
  fpc_threadvar_relocate_proc := nil;
  __CurrentTM := NoThreadManager;

  if Assigned(OldManager.DoneManager) then
    OldManager.DoneManager();

  Result := NewManager.InitManager(@ThreadSetup, Sizeof(TTlsSection), @InitTlsSection, @FreeTlsSection);
  if Result then
  begin
    __CurrentTM := NewManager;
  {$ifndef HAS_MT_MEMORYMANAGER}
    SetMemoryMutexManager(HeapMutexManager);
  {$endif HAS_MT_MEMORYMANAGER}
    ThreadID := GetCurrentThreadID;
  end;
end;



{*****************************************************************************
                         Thread Handling
*****************************************************************************}

function BeginThread(const Func: TThreadFunc): Boolean;
var
  dummy: TThreadID;
begin
  Result := BeginThread(Func, nil, dummy, DefaultStackSize);
end;

function BeginThread(const Func: TThreadFunc; const Arg: Pointer): Boolean;
var
  dummy: TThreadID;
begin
  Result := BeginThread(Func, Arg, dummy, DefaultStackSize);
end;

function BeginThread(const Func: TThreadFunc; const Arg: Pointer; var ThreadId: TThreadID): Boolean;
begin
  Result := BeginThread(Func, Arg, ThreadId, DefaultStackSize);
end;

function BeginThread(const Func: TThreadFunc; const Arg: Pointer; var ThreadId: TThreadID; const StackSize: PtrUInt): Boolean;
begin
  Result := __CurrentTM.ThreadBegin(StackSize, Func, Arg, ThreadId);
end;

procedure ExitThread(const ExitCode: PtrInt);
begin
  FlushThread;
  __CurrentTM.ThreadExit(ExitCode);
end;

procedure ExitThread;
begin
  ExitThread(0);
end;

procedure FlushThread;
begin
{$ifdef FPC_HAS_FEATURE_CONSOLEIO}
  { Make sure that all output is written to the redirected file }
  Flush(Output);
  Flush(ErrOutput);
  Flush(StdOut);
  Flush(StdErr);
{$endif FPC_HAS_FEATURE_CONSOLEIO}
end;

function SuspendThread(const ThreadId: TThreadID): Boolean;
begin
  Result := __CurrentTM.ThreadSuspend(ThreadId);
end;

function ResumeThread(const ThreadId: TThreadID): Boolean;
begin
  Result := __CurrentTM.ThreadResume(ThreadId);
end;

procedure ThreadSwitch;
begin
  __CurrentTM.ThreadSwitch;
end;

function KillThread(const ThreadId: TThreadID): Boolean;
begin
  Result := __CurrentTM.ThreadKill(ThreadId);
end;

function WaitForThreadTerminate(const ThreadId: TThreadID; const TimeoutMs: Longint): TWaitResult;
begin
  Result := __CurrentTM.ThreadWaitFor(ThreadId, TimeoutMs);
end;

function SetThreadPriority(const ThreadId: TThreadID; const Prio: TThreadPriority): Boolean;
begin
  Result := __CurrentTM.ThreadSetPriority(ThreadId, Prio);
end;

function GetThreadPriority(const ThreadId: TThreadID): TThreadPriority;
begin
  Result := __CurrentTM.ThreadGetPriority(ThreadId);
end;

function GetCurrentThreadId: TThreadID;
begin
  Result := __CurrentTM.ThreadGetCurrent();
end;



{*****************************************************************************
                         CriticalSection Handling
*****************************************************************************}

procedure InitCriticalSection(var cs: TRTLCriticalSection);
begin
  cs := __CurrentTM.MutexCreate;
end;

procedure DoneCriticalsection(const cs: TRTLCriticalSection);
begin
  __CurrentTM.MutexDestroy(cs);
end;

procedure EnterCriticalsection(const cs: TRTLCriticalSection);
begin
  __CurrentTM.MutexLock(cs);
end;

procedure LeaveCriticalsection(const cs: TRTLCriticalSection);
begin
  __CurrentTM.MutexUnlock(cs);
end;



{*****************************************************************************
                         Mutex Handling
*****************************************************************************}

function MutexCreate: PMutex;
begin
  Result := __CurrentTM.MutexCreate;
end;

procedure MutexDestroy(const AMutex: PMutex);
begin
  __CurrentTM.MutexDestroy(AMutex);
end;

procedure MutexLock(const AMutex: PMutex);
begin
  __CurrentTM.MutexLock(AMutex);
end;

procedure MutexUnlock(const AMutex: PMutex);
begin
  __CurrentTM.MutexUnlock(AMutex);
end;


{*****************************************************************************
                         Event Handling
*****************************************************************************}

function EventCreate(const InitState, ManualReset: Boolean): PEvent;
begin
  Result := __CurrentTM.EventCreate(InitState, ManualReset);
end;

procedure EventDestroy(const AEvent: PEvent);
begin
  __CurrentTM.EventDestroy(AEvent);
end;

procedure EventSet(const AEvent: PEvent);
begin
  __CurrentTM.EventSet(AEvent);
end;

procedure EventReset(const AEvent: PEvent);
begin
  __CurrentTM.EventReset(AEvent);
end;

function EventWaitFor(const AEvent: PEvent; const TimeoutMs: Longint): TWaitResult;
begin
  Result := __CurrentTM.EventWaitFor(AEvent, TimeoutMs);
end;



{*****************************************************************************
                         Semaphore Handling
*****************************************************************************}

function SemaphoreCreate(const Initialcount: Longword): PSemaphore;
begin
  Result := __CurrentTM.SemaphoreCreate(Initialcount);
end;

procedure SemaphoreDestroy(const ASemaphore: PSemaphore);
begin
  __CurrentTM.SemaphoreDestroy(ASemaphore);
end;

procedure SemaphorePost(const ASemaphore: PSemaphore);
begin
  __CurrentTM.SemaphorePost(ASemaphore);
end;

function SemaphoreWaitFor(const ASemaphore: PSemaphore; const TimeoutMs: Longint): TWaitResult;
begin
  Result := __CurrentTM.SemaphoreWaitFor(ASemaphore, TimeoutMs);
end;
