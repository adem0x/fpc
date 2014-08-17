unit threadlib;
{$MODE OBJFPC}{$H+}

{$PACKRECORDS C}
 
interface
 
uses
  Exec;
 
type
  uint32_t = LongWord;
  
type
  TThreadEntryfunction = function(data: Pointer): Pointer; cdecl;
 
var
  ThreadBase: pLibrary;
 
 
function  CreateThread(entry: TThreadEntryfunction; data: Pointer): uint32_t;
function  WaitThread(thread_id: uint32_t; res: pPointer): LongBool;
procedure WaitAllThreads;
function  DetachThread(thread_id: uint32_t): LongBool;
function  CurrentThread: uint32_t;
function  CreateMutex: Pointer;
function  DestroyMutex(mutex: Pointer): LongBool;
procedure LockMutex(mutex: Pointer);
function  TryLockMutex(mutex: Pointer): LongBool;
procedure UnlockMutex(mutex: Pointer);
function  CreateCondition: Pointer;
function  DestroyCondition(condition: Pointer): LongBool;
function  WaitCondition(condition: Pointer; mutex: Pointer): LongBool;
procedure SignalCondition(condition: Pointer);
procedure BroadcastCondition(condition: Pointer);
procedure ExitThread(res: Pointer);
 
 
implementation
 
function  CreateThread(entry: TThreadEntryfunction; data: Pointer): uint32_t;
type
  TLocalCall = function(entry: TThreadEntryfunction; data: Pointer; LibBase: Pointer): uint32_t; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 5));
  CreateThread := Call(entry, data, ThreadBase);
end;
 
 
 
function  WaitThread(thread_id: uint32_t; res: pPointer): LongBool;
type
  TLocalCall = function(thread_id: uint32_t; res: pPointer; LibBase: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 6));
  WaitThread := Call(thread_id, res, ThreadBase);
end;
 
 
 
procedure WaitAllThreads;
type
  TLocalCall = procedure(LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 7));
  Call(ThreadBase);
end;
 
 
 
function  DetachThread(thread_id: uint32_t): LongBool;
type
  TLocalCall = function(thread_id: uint32_t; LibBase: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 8));
  DetachThread := Call(thread_id, ThreadBase);
end;
 
 
 
function  CurrentThread: uint32_t;
type
  TLocalCall = function(LibBase: Pointer): uint32_t; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 9));
  CurrentThread := Call(ThreadBase);
end;
 
 
 
function  CreateMutex: Pointer;
type
  TLocalCall = function(LibBase: Pointer): Pointer; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 10));
  CreateMutex := Call(ThreadBase);
end;
 
 
 
function  DestroyMutex(mutex: Pointer): LongBool;
type
  TLocalCall = function(mutex: Pointer; LibBase: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 11));
  DestroyMutex := Call(mutex, ThreadBase);
end;
 
 
 
procedure LockMutex(mutex: Pointer);
type
  TLocalCall = procedure(mutex: Pointer; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 12));
  Call(mutex, ThreadBase);
end;
 
 
 
function  TryLockMutex(mutex: Pointer): LongBool;
type
  TLocalCall = function(mutex: Pointer; LibBase: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 13));
  TryLockMutex := Call(mutex, ThreadBase);
end;
 
 
 
procedure UnlockMutex(mutex: Pointer);
type
  TLocalCall = procedure(mutex: Pointer; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 14));
  Call(mutex, ThreadBase);
end;
 
 
 
function  CreateCondition: Pointer;
type
  TLocalCall = function(LibBase: Pointer): Pointer; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 15));
  CreateCondition := Call(ThreadBase);
end;
 
 
function  DestroyCondition(condition: Pointer): LongBool;
type
  TLocalCall = function(condition: Pointer; LibBase: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 16));
  DestroyCondition := Call(condition, ThreadBase);
end;
 
 
function  WaitCondition(condition: Pointer; mutex: Pointer): LongBool;
type
  TLocalCall = function(condition: Pointer; mutex: Pointer; LibBase: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 17));
  WaitCondition := Call(condition, mutex, ThreadBase);
end;
 
 
procedure SignalCondition(condition: Pointer);
type
  TLocalCall = procedure(condition: Pointer; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 18));
  Call(condition, ThreadBase);
end;
 
 
procedure BroadcastCondition(condition: Pointer);
type
  TLocalCall = procedure(condition: Pointer; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 19));
  Call(condition, ThreadBase);
end;
 
 
procedure ExitThread(res: Pointer);
type
  TLocalCall = procedure(res: Pointer; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(ThreadBase, 20));
  Call(res, ThreadBase);
end;
 
 
 
initialization
  ThreadBase := AOS_ThreadBase;
 
finalization
 
end.
