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

function LinThreadManagerInit(const ThrdSetup: TThreadSetupHandler; const TlsSize: PtrUInt;
  const TlsInit, TlsFree: TTlsSectionMemoryHandler): Boolean;
begin
  {ThrdSetupHandler := ThrdSetup;
  TlsMemorySize := TlsSize;
  TlsInitHandler := TlsInit;
  TlsFreeHandler := TlsFree;}
  Result := True;
end;

function LinThreadBegin(const StackSize: PtrUInt; const Func: TThreadFunc; const Arg: Pointer; var ThreadId: TThreadID): Boolean;
begin
  Result := False;
end;

procedure LinThreadExit(const ExitCode: PtrInt);
begin
end;

function LinThreadSuspend(const ThreadId: TThreadID): Boolean;
begin
  Result := False;
end;

function LinThreadResume(const ThreadId: TThreadID): Boolean;
begin
  Result := False;
end;

function LinThreadKill(const ThreadId: TThreadID): Boolean;
begin
  Result := False;
end;

procedure LinThreadSwitch;
begin
end;

function LinThreadWaitFor(const ThreadId: TThreadID; const TimeoutMs: Longint): TWaitResult;
begin
  Result := wrError;
end;

function LinThreadSetPriority(const ThreadId: TThreadID; const Prio: TThreadPriority): Boolean;
begin
  Result := False;
end;

function LinThreadGetPriority(const ThreadId: TThreadID): TThreadPriority;
begin
  Result := tpNormal;
end;

function LinThreadGetCurrent: TThreadID;
begin
  Result := 0;
end;

function LinTlsSectionGet: Pointer;
begin
  Result := nil;
end;

function LinMutexCreate: TMutex;
begin
  Result := nil;
end;

procedure LinMutexDestroy(const AMutex: TMutex);
begin
end;

procedure LinMutexLock(const AMutex: TMutex);
begin
end;

procedure LinMutexUnlock(const AMutex: TMutex);
begin
end;

function LinEventCreate(const InitState, ManualReset: Boolean): TEvent;
begin
  Result := nil;
end;

procedure LinEventDestroy(const AEvent: TEvent);
begin
end;

procedure LinEventSet(const AEvent: TEvent);
begin
end;

procedure LinEventReset(const AEvent: TEvent);
begin
end;

function LinEventWaitFor(const AEvent: TEvent; const TimeoutMs: Longint): TWaitResult;
begin
  Result := wrError;
end;

function LinSemaphoreCreate(const Initialcount: Longword): TSemaphore;
begin
  Result := nil;
end;

procedure LinSemaphoreDestroy(const ASemaphore: TSemaphore);
begin
end;

procedure LinSemaphorePost(const ASemaphore: TSemaphore);
begin
end;

function LinSemaphoreWaitFor(const ASemaphore: TSemaphore; const TimeoutMs: Longint): TWaitResult;
begin
  Result := wrError;
end;

const
  LinuxThreadManager: TThreadManager = (
    InitManager            : @LinThreadManagerInit;
    DoneManager            : nil;

  // Thread
    ThreadBegin            : @LinThreadBegin;
    ThreadExit             : @LinThreadExit;
    ThreadSuspend          : @LinThreadSuspend;
    ThreadResume           : @LinThreadResume;
    ThreadKill             : @LinThreadKill;
    ThreadSwitch           : @LinThreadSwitch;
    ThreadWaitFor          : @LinThreadWaitFor;
    ThreadSetPriority      : @LinThreadSetPriority;
    ThreadGetPriority      : @LinThreadGetPriority;
    ThreadGetCurrent       : @LinThreadGetCurrent;

  // TlsSection
    TlsSectionGet          : @LinTlsSectionGet;

  // Mutex
    MutexCreate            : @LinMutexCreate;
    MutexDestroy           : @LinMutexDestroy;
    MutexLock              : @LinMutexLock;
    MutexUnlock            : @LinMutexUnlock;

  // Event
    EventCreate            : @LinEventCreate;
    EventDestroy           : @LinEventDestroy;
    EventSet               : @LinEventSet;
    EventReset             : @LinEventReset;
    EventWaitFor           : @LinEventWaitFor;

  // Semaphore
    SemaphoreCreate        : @LinSemaphoreCreate;
    SemaphoreDestroy       : @LinSemaphoreDestroy;
    SemaphorePost          : @LinSemaphorePost;
    SemaphoreWaitFor       : @LinSemaphoreWaitFor
  );

procedure InitSystemThreads;
begin
  SetThreadManager(LinuxThreadManager);
end;


