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
  TTlsSectionMemoryHandler       = procedure(var Address: Pointer);
  TThreadSetupHandler            = procedure(const Stack: Pointer; const StackSize: PtrUInt); register;
  TThreadManagerInitHandler      = function(const ThreadSetup: TThreadSetupHandler; const TlsInit, TlsFree: TTlsSectionMemoryHandler): Boolean;
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
  TMutex                         = type Pointer;
  TMutexCreateHandler            = function: TMutex;
  TMutexHandler                  = procedure(const AMutex: TMutex);

// Event Callbacks
  TEvent                         = type Pointer;
  TEventCreateHandler            = function(const InitState, ManualReset: Boolean): TEvent;
  TEventHandler                  = procedure(const AEvent: TEvent);
  TEventWaitForHandler           = function(const AEvent: TEvent; const TimeoutMs: Longint): TWaitResult;

// Semaphore Callbacks
  TSemaphore                     = type Pointer;
  TSempahoreCreateHandler        = function(const Initialcount: Longword): TSemaphore;
  TSemaphoreHandler              = procedure(const ASemaphore: TSemaphore);
  TSemaphoreWaitForHandler       = function(const ASemaphore: TSemaphore; const TimeoutMs: Longint): TWaitResult;

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
  CriticalSection Handling
*****************************************************************************}

type
  TRTLCriticalSection = TMutex;

procedure CriticalSectionInit(var cs: TRTLCriticalSection);
procedure CriticalsectionDone(const cs: TRTLCriticalSection);
procedure CriticalsectionEnter(const cs: TRTLCriticalSection);
procedure CriticalsectionLeave(const cs: TRTLCriticalSection);


{*****************************************************************************
  Mutex Handling
*****************************************************************************}

function MutexCreate: TMutex;
procedure MutexDestroy(const AMutex: TMutex);
procedure MutexLock(const AMutex: TMutex);
procedure MutexUnlock(const AMutex: TMutex);


{*****************************************************************************
  Event Handling
*****************************************************************************}

function EventCreate(const InitState, ManualReset: Boolean): TEvent;
procedure EventDestroy(const AEvent: TEvent);
procedure EventSet(const AEvent: TEvent);
procedure EventReset(const AEvent: TEvent);
function EventWaitFor(const AEvent: TEvent; const TimeoutMs: Longint): TWaitResult;


{*****************************************************************************
  Semaphore Handling
*****************************************************************************}

function SemaphoreCreate(const Initialcount: Longword): TSemaphore;
procedure SemaphoreDestroy(const ASemaphore: TSemaphore);
procedure SemaphorePost(const ASemaphore: TSemaphore);
function SemaphoreWaitFor(const ASemaphore: TSemaphore; const TimeoutMs: Longint): TWaitResult;

