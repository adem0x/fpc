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
  TRTLWaitResult                 = (wrSignaled, wrTimeout, wrError);
  TRTLThreadPriority             = (tpIdle, tpLowest, tpLower, tpNormal, tpHigher, tpHighest, tpTimeCritical);

// ThreadManager Callbacks
  TTlsSectionMemoryHandler       = procedure(var Address: Pointer);
  TThreadSetupHandler            = procedure(const Stack: Pointer; const StackSize: PtrUInt); register;
  TThreadManagerInitHandler      = function(const ThreadSetup: TThreadSetupHandler; const TlsInit, TlsFree: TTlsSectionMemoryHandler): Boolean;
  TThreadManagerDoneHandler      = procedure;

// Thread Callbacks
//  TRTLThread                     = type Pointer; defined in systemh.inc
  TRTLThreadFunc                 = function(const Arg: Pointer): PtrInt; register;
  TThreadBeginHandler            = function(const StackSize: PtrUInt; const Func: TRTLThreadFunc; const Arg: Pointer; var ThreadId: TRTLThread): Boolean;
  TThreadExitHandler             = procedure(const ExitCode: PtrInt);
  TThreadHandler                 = function(const ThreadId: TRTLThread): Boolean;
  TThreadSwitchHandler           = procedure;
  TThreadWaitForHandler          = function(const ThreadId: TRTLThread; const TimeoutMs: Longint): TRTLWaitResult;
  TThreadSetPriorityHandler      = function(const ThreadId: TRTLThread; const Prio: TRTLThreadPriority): Boolean;            {-15..+15, 0=normal}
  TThreadGetPriorityHandler      = function(const ThreadId: TRTLThread): TRTLThreadPriority;
  TThreadGetCurrentHandler       = function: TRTLThread;

// TlsSection Callbacks
  TTlsSectionGetHandler          = function: Pointer;

// Mutex Callbacks
  TRTLMutex                      = type Pointer;
  TMutexCreateHandler            = function: TRTLMutex;
  TMutexHandler                  = procedure(const AMutex: TRTLMutex);

// Event Callbacks
  TRTLEvent                      = type Pointer;
  TEventCreateHandler            = function(const InitState, ManualReset: Boolean): TRTLEvent;
  TEventHandler                  = procedure(const AEvent: TRTLEvent);
  TEventWaitForHandler           = function(const AEvent: TRTLEvent; const TimeoutMs: Longint): TRTLWaitResult;

// Semaphore Callbacks
  TRTLSemaphore                  = type Pointer;
  TSemaphoreCreateHandler        = function(const Initialcount: Longword): TRTLSemaphore;
  TSemaphoreHandler              = procedure(const ASemaphore: TRTLSemaphore);
  TSemaphoreWaitForHandler       = function(const ASemaphore: TRTLSemaphore; const TimeoutMs: Longint): TRTLWaitResult;

// ThreadManager interface
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
    SemaphoreCreate        : TSemaphoreCreateHandler;
    SemaphoreDestroy       : TSemaphoreHandler;
    SemaphorePost          : TSemaphoreHandler;
    SemaphoreWaitFor       : TSemaphoreWaitForHandler;
  end;



{*****************************************************************************
  Thread Handler routines
*****************************************************************************}

function GetThreadManager(var Manager: TThreadManager): Boolean;
function SetThreadManager(const NewManager: TThreadManager): Boolean;


{*****************************************************************************
  Thread Handling
*****************************************************************************}

function BeginThread(const Func: TRTLThreadFunc): Boolean;
function BeginThread(const Func: TRTLThreadFunc; const Arg: Pointer): Boolean;
function BeginThread(const Func: TRTLThreadFunc; const Arg: Pointer; var ThreadId: TRTLThread): Boolean;
function BeginThread(const Func: TRTLThreadFunc; const Arg: Pointer; var ThreadId: TRTLThread; const StackSize: PtrUInt): Boolean;
procedure ExitThread(const ExitCode: PtrInt);
procedure ExitThread;
procedure FlushThread;
function SuspendThread(const ThreadId: TRTLThread): Boolean;
function ResumeThread(const ThreadId: TRTLThread): Boolean;
procedure ThreadSwitch;
function KillThread(const ThreadId: TRTLThread): Boolean;
function WaitForThreadTerminate(const ThreadId: TRTLThread; const TimeoutMs: Longint): TRTLWaitResult;
function SetThreadPriority(const ThreadId: TRTLThread; const Prio: TRTLThreadPriority): Boolean;
function GetThreadPriority(const ThreadId: TRTLThread): TRTLThreadPriority;
function GetCurrentThreadId: TRTLThread;


{*****************************************************************************
  CriticalSection Handling
*****************************************************************************}

type
  TRTLCriticalSection = TRTLMutex;

procedure CriticalSectionInit(var cs: TRTLCriticalSection);
procedure CriticalsectionDone(const cs: TRTLCriticalSection);
procedure CriticalsectionEnter(const cs: TRTLCriticalSection);
procedure CriticalsectionLeave(const cs: TRTLCriticalSection);


{*****************************************************************************
  Mutex Handling
*****************************************************************************}

function MutexCreate: TRTLMutex;
procedure MutexDestroy(const AMutex: TRTLMutex);
procedure MutexLock(const AMutex: TRTLMutex);
procedure MutexUnlock(const AMutex: TRTLMutex);


{*****************************************************************************
  Event Handling
*****************************************************************************}

function EventCreate(const InitState, ManualReset: Boolean): TRTLEvent;
procedure EventDestroy(const AEvent: TRTLEvent);
procedure EventSet(const AEvent: TRTLEvent);
procedure EventReset(const AEvent: TRTLEvent);
function EventWaitFor(const AEvent: TRTLEvent; const TimeoutMs: Longint): TRTLWaitResult;


{*****************************************************************************
  Semaphore Handling
*****************************************************************************}

function SemaphoreCreate(const Initialcount: Longword): TRTLSemaphore;
procedure SemaphoreDestroy(const ASemaphore: TRTLSemaphore);
procedure SemaphorePost(const ASemaphore: TRTLSemaphore);
function SemaphoreWaitFor(const ASemaphore: TRTLSemaphore; const TimeoutMs: Longint): TRTLWaitResult;

