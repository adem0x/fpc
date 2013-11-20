{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2013 by Marcus Sackrow.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

type
  TThreadEntryfunction = function(data: Pointer): Pointer; cdecl;

const
   threadvarblocksize : dword = 0;     // total size of allocated threadvars
   thredvarsmainthread: pointer = nil; // to free the threadvars in the signal handler
// AROS
function  CreateThread(Entry: TThreadEntryfunction; Data: Pointer): LongWord;
type
  TLocalCall = function(Entry: TThreadEntryfunction; Data: Pointer; LibBase: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 5));
  CreateThread := Call(Entry, Data, AOS_ThreadBase);
end;

function  WaitThread(thread_id: LongWord; res: pPointer): LongBool;
type
  TLocalCall = function(thread_id: LongWord; res: pPointer; LibBase: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 6));
  WaitThread := Call(thread_id, res, AOS_ThreadBase);
end;

procedure WaitAllThreads;
type
  TLocalCall = procedure(LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 7));
  Call(AOS_ThreadBase);
end;

function  DetachThread(thread_id: LongWord): LongBool;
type
  TLocalCall = function(thread_id: LongWord; LibBase: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 8));
  DetachThread := Call(thread_id, AOS_ThreadBase);
end;

function AROSCurrentThread: LongWord;
type
  TLocalCall = function(LibBase: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 9));
  AROSCurrentThread := Call(AOS_ThreadBase);
end;

function  CreateMutex: Pointer;
type
  TLocalCall = function(LibBase: Pointer): Pointer; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 10));
  CreateMutex := Call(AOS_ThreadBase);
end;

function  DestroyMutex(mutex: Pointer): LongBool;
type
  TLocalCall = function(mutex: Pointer; LibBase: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 11));
  DestroyMutex := Call(mutex, AOS_ThreadBase);
end;

procedure LockMutex(mutex: Pointer);
type
  TLocalCall = procedure(mutex: Pointer; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 12));
  Call(mutex, AOS_ThreadBase);
end;

function  TryLockMutex(mutex: Pointer): LongBool;
type
  TLocalCall = function(mutex: Pointer; LibBase: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 13));
  TryLockMutex := Call(mutex, AOS_ThreadBase);
end;

procedure UnlockMutex(mutex: Pointer);
type
  TLocalCall = procedure(mutex: Pointer; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 14));
  Call(mutex, AOS_ThreadBase);
end;

function  CreateCondition: Pointer;
type
  TLocalCall = function(LibBase: Pointer): Pointer; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 15));
  CreateCondition := Call(AOS_ThreadBase);
end;

function  DestroyCondition(condition: Pointer): LongBool;
type
  TLocalCall = function(condition: Pointer; LibBase: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 16));
  DestroyCondition := Call(condition, AOS_ThreadBase);
end;

function  WaitCondition(condition: Pointer; mutex: Pointer): LongBool;
type
  TLocalCall = function(condition: Pointer; mutex: Pointer; LibBase: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 17));
  WaitCondition := Call(condition, mutex, AOS_ThreadBase);
end;

procedure SignalCondition(condition: Pointer);
type
  TLocalCall = procedure(condition: Pointer; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 18));
  Call(condition, AOS_ThreadBase);
end;

procedure BroadcastCondition(condition: Pointer);
type
  TLocalCall = procedure(condition: Pointer; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 19));
  Call(condition, AOS_ThreadBase);
end;

procedure ExitThread(res: Pointer);
type
  TLocalCall = procedure(res: Pointer; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ThreadBase, 20));
  Call(res, AOS_ThreadBase);
end;

procedure Switch;
type
  TLocalCall = procedure(LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_ExecBase, 9));
  Call(AOS_ExecBase);
end;

{$WARNING TODO! Most Thread related functions are just stubs}

var
  ThreadsVarList: array of Pointer;

// Thread manager:
procedure SysInitThreadvar(var offset : dword;size : dword);
begin
  //offset:=threadvarblocksize;
  //inc(threadvarblocksize,size);
end;

procedure SaveThreadVars(t: Pointer);
var
  Idx: Integer;
begin
  {Idx := AROSCurrentThread();
  if Idx >= 0 then
  begin
    if Idx > High(ThreadsVarList) then
      SetLength(ThreadsVarList, Idx + 1);
    ThreadsVarList[Idx] := t;  
  end;}
end;

function GetThreadV: Pointer;
var
  Idx: Integer;
begin
  {
  Result := nil;
  Idx := AROSCurrentThread();
  if (Idx >= 0) and (Idx <= High(ThreadsVarList)) then
  begin
    Result := ThreadsVarList[Idx];  
  end;
  }
end;

function SysRelocateThreadvar (offset: dword): Pointer;
begin
  //SysRelocateThreadvar:= GetThreadV + offset; 
end;

procedure SaveThreadV(t: Pointer);
var
  Idx: Integer;
begin
  {Idx := AROSCurrentThread();
  if Idx >= 0 then
  begin
    if Idx > High(ThreadsVarList) then
      SetLength(ThreadsVarList, Idx + 1);
    ThreadsVarList[Idx] := t;  
  end;}
end;

procedure SysAllocateThreadVars;
var
  threadvars: Pointer;
begin
  {threadvars := AllocPooled(AOS_heapPool, threadvarblocksize);
  FillChar(threadvars^, threadvarblocksize, 0);
  SaveThreadV(threadvars);
  if thredvarsmainthread = nil then
    thredvarsmainthread := threadvars;}
end;

procedure SysReleaseThreadVars;
var
  threadvars: Pointer;
begin
  { release thread vars }
  {
  if threadvarblocksize > 0 then
  begin
    threadvars := GetThreadV;
    if threadvars <> nil then
    begin
      FreePooled(AOS_heapPool, threadvars, threadvarblocksize);
      SaveThreadVars(nil);
    end;
  end;}
end;

type
   TThreadInfo = record
      F: TThreadfunc;
      P: Pointer;
   end;
   PThreadinfo = ^TThreadinfo;

function ThreadFunc(Data: Pointer): Pointer; cdecl;
var
  Ti: TThreadinfo; 
begin
  {SysAllocateThreadVars;
  ti := PThreadInfo(Data)^;
  Dispose(PThreadInfo(Data));
  // execute
  ThreadFunc := Pointer(Ti.f(Ti.p));
  DoneThread;} 
end;

function SysBeginThread(Sa: Pointer; StackSize: PtrUInt; ThreadFunction: TThreadfunc; p: Pointer; CreationFlags: dword; var ThreadId: TThreadID): TThreadID;
var
  Ti: PThreadinfo;
begin
  Result := 0;
  if AOS_ThreadBase = nil then
    Exit;
  if not IsMultiThread then
  begin
    InitThreadVars(@SysRelocateThreadvar);
    IsMultithread:=true;
  end;
  New(Ti);
  Ti^.f := ThreadFunction;
  Ti^.p := p;
  SetLength(ThreadsVarList, 200);
  SysBeginThread := CreateThread(@ThreadFunc, Ti);
  ThreadID := SysBeginThread;
end;


procedure SysEndThread(ExitCode : DWord);
begin 
  if AOS_ThreadBase = nil then
    Exit;
  DoneThread;
  ExitThread(Pointer(ExitCode));
end;


procedure SysThreadSwitch;
begin
  Switch();
end;

function SysSuspendThread(ThreadHandle: THandle): dword;
begin
  Result := 0;
end;


function SysResumeThread(ThreadHandle: THandle): dword;
begin
  Result := 0;
end;


function  SysKillThread(threadHandle: THandle): dword;
begin
  SysKillThread := 0;  {not supported for AROS}
end;

function SysWaitForThreadTerminate(threadHandle: THandle; TimeoutMs: LongInt): dword;
begin
  Result := 0; 
end;

function  SysThreadSetPriority (threadHandle : THandle; Prio: longint): boolean; {-15..+15, 0=normal}
begin
  SysThreadSetPriority := true;
end;

function  SysThreadGetPriority (threadHandle : THandle): Longint;
begin
  SysThreadGetPriority := 0;
end;


function SysGetCurrentThreadId: LongInt;
begin
  SysGetCurrentThreadId := AROSCurrentThread;
end;

// Mutex
type
  TMutexList = array of Pointer;
  PMutexList = ^TMutexList;
  
var
  MutexList: TMutexList;
  ListMutex: Pointer;


// Add Mutex to List
  
procedure AddMutex(AMutex: Pointer);
var
  Idx: Integer;
  i: Integer;
begin
  if AOS_ThreadBase = nil then
    Exit;
  LockMutex(ListMutex);
  Idx := -1;
  for i := 0 to High(MutexList) do
  begin
    if MutexList[i] = nil then
    begin
      Idx := i;
      Break; 
    end;
  end;
  if Idx = -1 then
  begin
    Idx := Length(MutexList);
    SetLength(MutexList, Idx + 1);
  end;  
  MutexList[Idx] := AMutex;
  UnLockMutex(ListMutex);
end;

// Remove Mutex from List
procedure RemoveMutex(AMutex: Pointer);
var
  i: Integer;
begin
  if AOS_ThreadBase = nil then
    Exit;
  if AMutex = nil then
    Exit;
  LockMutex(ListMutex);
  for i := 0 to High(MutexList) do
  begin
    if MutexList[i] = AMutex then
    begin
      MutexList[i] := nil;
      Break;
    end;
  end;
  UnLockMutex(ListMutex);
end;

// Close all Semaphores
procedure SysCloseAllRemainingSemaphores;
var
  i: Integer;
begin
  if AOS_ThreadBase = nil then
    Exit;
  LockMutex(ListMutex);
  for i := 0 to High(MutexList) do
  begin
    if MutexList[i] <> nil then
    begin
      DestroyMutex(MutexList[i]);
      MutexList[i] := nil;
    end;
  end;
  UnLockMutex(ListMutex);
end;

// Critical Sections (done by Mutex)
procedure SysInitCriticalSection(var cs: TRTLCriticalSection);
begin
  if AOS_ThreadBase = nil then
    Exit;
  cs := CreateMutex;
  //DebugLn('Create Mutex');
end;

procedure SysDoneCriticalsection(var cs: TRTLCriticalSection);
begin
  if AOS_ThreadBase = nil then
    Exit;
  //DebugLn('Destroy Mutex');
  if Assigned(cs) then
    DestroyMutex(TRTLCriticalSection(cs));
  cs := nil;  
end;

procedure SysEnterCriticalsection(var cs: TRTLCriticalSection);
begin
  if AOS_ThreadBase = nil then
    Exit;
  //DebugLn('EnterMutex');
  if Assigned(cs) then
    LockMutex(cs);
end;

function SysTryEnterCriticalsection(var cs: TRTLCriticalSection): longint;
begin
  if AOS_ThreadBase = nil then
    Exit;
  //DebugLn('TryEnter Mutex');
  Result := 0;
  if Assigned(cs) then
    Result := LongInt(TryLockMutex(cs));
end;

procedure SysLeaveCriticalsection(var cs: TRTLCriticalSection);
begin
  if AOS_ThreadBase = nil then
    Exit;
  //DebugLn('Leave Mutex');
  if Assigned(cs) then
    UnlockMutex(cs);
end;

function SysSetThreadDataAreaPtr (newPtr:pointer):pointer;
begin
end;

function intBasicEventCreate(EventAttributes : Pointer;
AManualReset,InitialState : Boolean;const Name : ansistring):pEventState;
begin
end;

procedure intbasiceventdestroy(state:peventstate);
begin
end;

procedure intbasiceventResetEvent(state:peventstate);
begin
end;

procedure intbasiceventSetEvent(state:peventstate);
begin
end;

function intbasiceventWaitFor(Timeout : Cardinal;state:peventstate) : longint;
begin
end;

function intRTLEventCreate: PRTLEvent;
begin
end;

procedure intRTLEventDestroy(AEvent: PRTLEvent);
begin
end;

procedure intRTLEventSetEvent(AEvent: PRTLEvent);
begin
end;

procedure intRTLEventResetEvent(AEvent: PRTLEvent);
begin
end;

procedure intRTLEventWaitFor(AEvent: PRTLEvent);
begin
end;

procedure intRTLEventWaitForTimeout(AEvent: PRTLEvent;timeout : longint);
begin
end;


function SysInitManager: Boolean;
begin
  if AOS_ThreadBase = nil then
    AOS_ThreadBase := OpenLibrary('thread.library',0); 
  Result := AOS_ThreadBase <> nil;  
end;

function SysDoneManager: Boolean;
begin
  Result := True;
end;


Var
  AROSThreadManager : TThreadManager;

procedure InitSystemThreads;
begin
  AOS_ThreadBase := nil;
  with AROSThreadManager do
  begin
    InitManager            :=@SysInitManager;
    DoneManager            :=@SysDoneManager;
    BeginThread            :=@SysBeginThread;
    EndThread              :=@SysEndThread;
    SuspendThread          :=@SysSuspendThread;
    ResumeThread           :=@SysResumeThread;
    KillThread             :=@SysKillThread;
    ThreadSwitch           :=@SysThreadSwitch;
    WaitForThreadTerminate :=@SysWaitForThreadTerminate;
    ThreadSetPriority      :=@SysThreadSetPriority;
    ThreadGetPriority      :=@SysThreadGetPriority;
    GetCurrentThreadId     :=@SysGetCurrentThreadId;
    InitCriticalSection    :=TCriticalSectionHandler(@SysInitCriticalSection);
    DoneCriticalSection    :=TCriticalSectionHandler(@SysDoneCriticalSection);
    EnterCriticalSection   :=TCriticalSectionHandler(@SysEnterCriticalSection);
    LeaveCriticalSection   :=TCriticalSectionHandler(@SysLeaveCriticalSection);
    InitThreadVar          :=@SysInitThreadVar;
    RelocateThreadVar      :=@SysRelocateThreadVar;
    AllocateThreadVars     :=@SysAllocateThreadVars;
    ReleaseThreadVars      :=@SysReleaseThreadVars;
    BasicEventCreate       :=@intBasicEventCreate;
    basiceventdestroy      :=@intbasiceventdestroy;
    basiceventResetEvent   :=@intbasiceventResetEvent;
    basiceventSetEvent     :=@intbasiceventSetEvent;
    basiceventWaitFor      :=@intbasiceventWaitFor;
    RTLEventCreate         :=@intRTLEventCreate;
    RTLEventDestroy        :=@intRTLEventDestroy;
    RTLEventSetEvent       :=@intRTLEventSetEvent;
    RTLEventResetEvent     :=@intRTLEventResetEvent;
    RTLEventWaitFor        :=@intRTLEventWaitFor;
    RTLEventWaitForTimeout :=@intRTLEventWaitForTimeout;
  end;
  SetThreadManager(AROSThreadManager); 
end;



