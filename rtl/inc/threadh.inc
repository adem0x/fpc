{
    This file is part of the Free Pascal Run time library.
    Copyright (c) 2000 by the Free Pascal development team

    This file contains the OS indenpendend declartions for multi
    threading support in FPC

    See the File COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

const
  { including 16384 margin for stackchecking }
  DefaultStackSize               = 32768;

type
  TWaitResult                    = (wrSignaled, wrTimeout, wrError);
  TThreadPriority                = (tpIdle, tpLowest, tpLower, tpNormal, tpHigher, tpHighest, tpTimeCritical);

// ThreadManager Callbacks
  TTlsSectionMemoryHandler       = procedure(const Address: Pointer);
  TThreadSetupHandler            = procedure(const Stack: Pointer; const StackSize: PtrUInt); register;
  TThreadManagerInitHandler      = function(const ThreadSetup: TThreadSetupHandler; const TlsSize: PtrUInt; const TlsInit, TlsFree: TTlsSectionMemoryHandler): Boolean;
  TThreadManagerDoneHandler      = procedure;

// Thread Callbacks
  TThreadFunc                    = function(const Arg: Pointer): PtrInt; register;
  TThreadBeginHandler            = function(const StackSize: PtrUInt; const Func: TThreadFunc; const Arg: Pointer; var ThreadId: TThreadID): Boolean;
  TThreadExitHandler             = procedure(const ExitCode: PtrInt);
  TThreadHandler                 = function(const ThreadId: TThreadID): Boolean;
  TThreadSwitchHandler           = procedure;
  TThreadWaitForHandler          = function(const ThreadId: TThreadID; const TimeoutMs: Longint): TWaitResult;
  TThreadSetPriorityHandler      = function(const ThreadId: TThreadID; const Prio: TThreadPriority): Boolean;            {-15..+15, 0=normal}
  TThreadGetPriorityHandler      = function(const ThreadId: TThreadID): TThreadPriority;
  TThreadGetCurrentHandler       = function: TThreadID;

// TlsSection Callbacks
  TTlsSectionGetHandler          = function: Pointer;

// Mutex Callbacks
  PMutex                         = type Pointer;
  TMutexCreateHandler            = function: PMutex;
  TMutexHandler                  = procedure(const AMutex: PMutex);

// Event Callbacks
  PEvent                         = type Pointer;
  TEventCreateHandler            = function(const InitState, ManualReset: Boolean): PEvent;
  TEventHandler                  = procedure(const AEvent: PEvent);
  TEventWaitForHandler           = function(const AEvent: PEvent; const TimeoutMs: Longint): TWaitResult;

// Semaphore Callbacks
  PSemaphore                     = type Pointer;
  TSempahoreCreateHandler        = function(const Initialcount: Longword): PSemaphore;
  TSemaphoreHandler              = procedure(const ASemaphore: PSemaphore);
  TSemaphoreWaitForHandler       = function(const ASemaphore: PSemaphore; const TimeoutMs: Longint): TWaitResult;

// ThreadManager interface.
  TThreadManager = record
    InitManager            : TThreadManagerInitHandler;
    DoneManager            : TThreadManagerDoneHandler;

  // Thread
    ThreadBegin            : TThreadBeginHandler;
    ThreadExit             : TThreadExitHandler;
    ThreadSuspend          : TThreadHandler;
    ThreadResume           : TThreadHandler;
    ThreadKill             : TThreadHandler;
    ThreadSwitch           : TThreadSwitchHandler;
    ThreadWaitFor          : TThreadWaitForHandler;
    ThreadSetPriority      : TThreadSetPriorityHandler;
    ThreadGetPriority      : TThreadGetPriorityHandler;
    ThreadGetCurrent       : TThreadGetCurrentHandler;

  // TlsSection
    TlsSectionGet          : TTlsSectionGetHandler;

  // Mutex
    MutexCreate            : TMutexCreateHandler;
    MutexDestroy           : TMutexHandler;
    MutexLock              : TMutexHandler;
    MutexUnlock            : TMutexHandler;

  // Event
    EventCreate            : TEventCreateHandler;
    EventDestroy           : TEventHandler;
    EventSet               : TEventHandler;
    EventReset             : TEventHandler;
    EventWaitFor           : TEventWaitForHandler;

  // Semaphore
    SemaphoreCreate        : TSempahoreCreateHandler;
    SemaphoreDestroy       : TSemaphoreHandler;
    SemaphorePost          : TSemaphoreHandler;
    SemaphoreWaitFor       : TSemaphoreWaitForHandler;
  end;



{*****************************************************************************
  Thread Handler routines
*****************************************************************************}

function GetThreadManager(var Manager: TThreadManager): Boolean;
function SetThreadManager(const NewManager: TThreadManager; var OldManager: TThreadManager): Boolean;
function SetThreadManager(const NewManager: TThreadManager): Boolean;


{*****************************************************************************
  Thread Handling
*****************************************************************************}

function BeginThread(const Func: TThreadFunc): Boolean;
function BeginThread(const Func: TThreadFunc; const Arg: Pointer): Boolean;
function BeginThread(const Func: TThreadFunc; const Arg: Pointer; var ThreadId: TThreadID): Boolean;
function BeginThread(const Func: TThreadFunc; const Arg: Pointer; var ThreadId: TThreadID; const StackSize: PtrUInt): Boolean;
procedure ExitThread(const ExitCode: PtrInt);
procedure ExitThread;
procedure FlushThread;
function SuspendThread(const ThreadId: TThreadID): Boolean;
function ResumeThread(const ThreadId: TThreadID): Boolean;
procedure ThreadSwitch;
function KillThread(const ThreadId: TThreadID): Boolean;
function WaitForThreadTerminate(const ThreadId: TThreadID; const TimeoutMs: Longint): TWaitResult;
function SetThreadPriority(const ThreadId: TThreadID; const Prio: TThreadPriority): Boolean;
function GetThreadPriority(const ThreadId: TThreadID): TThreadPriority;
function GetCurrentThreadId: TThreadID;


{*****************************************************************************
  CriticalSection Handling (backward compatibility)
*****************************************************************************}

type
  TRTLCriticalSection = PMutex;

procedure InitCriticalSection(var cs: TRTLCriticalSection);
procedure DoneCriticalsection(const cs: TRTLCriticalSection);
procedure EnterCriticalsection(const cs: TRTLCriticalSection);
procedure LeaveCriticalsection(const cs: TRTLCriticalSection);


{*****************************************************************************
  Mutex Handling
*****************************************************************************}

function MutexCreate: PMutex;
procedure MutexDestroy(const AMutex: PMutex);
procedure MutexLock(const AMutex: PMutex);
procedure MutexUnlock(const AMutex: PMutex);


{*****************************************************************************
  Event Handling
*****************************************************************************}

function EventCreate(const InitState, ManualReset: Boolean): PEvent;
procedure EventDestroy(const AEvent: PEvent);
procedure EventSet(const AEvent: PEvent);
procedure EventReset(const AEvent: PEvent);
function EventWaitFor(const AEvent: PEvent; const TimeoutMs: Longint): TWaitResult;


{*****************************************************************************
  Semaphore Handling
*****************************************************************************}

function SemaphoreCreate(const Initialcount: Longword): PSemaphore;
procedure SemaphoreDestroy(const ASemaphore: PSemaphore);
procedure SemaphorePost(const ASemaphore: PSemaphore);
function SemaphoreWaitFor(const ASemaphore: PSemaphore; const TimeoutMs: Longint): TWaitResult;

