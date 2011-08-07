{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2006 Karoly Balogh

    exec functions (V40) for Amiga/PowerPC

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

var
  LocalExecBase   : Pointer; external name '_ExecBase';

function GetLibAdress(Base: Pointer; Offset: LongInt): Pointer;
begin
  if Base = nil then
    Halt(1);
  GetLibAdress := Pointer((Base -(Offset * SizeOf(Pointer)))^);
end;

function execAllocMem(byteSize: Cardinal; requirements: Cardinal): Pointer;
type
  TAllocMem = function(byteSize: Cardinal; requirements: Cardinal; Base: Pointer): Pointer; stdcall;
var
  Call: TAllocMem;
begin
  Call := TAllocMem(GetLibAdress(LocalExecBase, 33));
  execAllocMem := Call(byteSize, requirements, LocalExecBase);
end;

procedure execFreeMem(memoryBlock: Pointer; byteSize: Cardinal);
type
  TFreeMem = function(memoryBlock: Pointer; byteSize: Cardinal; Base: Pointer): Pointer; stdcall;
var
  Call: TFreeMem;
begin
  Call := TFreeMem(GetLibAdress(LocalExecBase, 35));
  Call(memoryBlock, byteSize, LocalExecBase);
end;

function FindTask(name: PChar): PTask;
type
  TFindTask = function(name: PChar; Base: Pointer): PTask; stdcall;
var
  Call: TFindTask;
begin
  Call := TFindTask(GetLibAdress(LocalExecBase, 49));
  FindTask := Call(name, LocalExecBase);
end;

function SetSignal(newSignals: Cardinal; signalSet : Cardinal): Cardinal;
type
  TSetSignal = function(newSignals: Cardinal; signalSet : Cardinal; Base: Pointer): Cardinal; stdcall;
var
  Call: TSetSignal;
begin
  Call := TSetSignal(GetLibAdress(LocalExecBase, 51));
  SetSignal := Call(newSignals, signalSet, LocalExecBase);
end;

function AllocSignal(signalNum: LongInt): ShortInt;
type
  TAllocSignal = function(signalNum: LongInt; Base: Pointer): ShortInt; stdcall;
var
  Call: TAllocSignal;
begin
  Call := TAllocSignal(GetLibAdress(LocalExecBase, 55));
  AllocSignal := Call(signalNum, LocalExecBase);
end;

procedure FreeSignal(signalNum: LongInt);
type
  TFreeSignal = procedure(signalNum: LongInt; Base: Pointer); stdcall;
var
  Call: TFreeSignal;
begin
  Call := TFreeSignal(GetLibAdress(LocalExecBase, 56)); 
  Call(signalNum, LocalExecBase);
end;

procedure AddPort(port: PMsgPort);
type
  TAddPort = procedure(port: PMsgPort; Base: Pointer); stdcall;
var
  Call: TAddPort;
begin
  Call := TAddPort(GetLibAdress(LocalExecBase, 59)); 
  Call(port, LocalExecBase);
end;

procedure RemPort(port: PMsgPort);
type
  TRemPort = procedure(port: PMsgPort; Base: Pointer); stdcall;
var
  Call: TRemPort;
begin
  Call := TRemPort(GetLibAdress(LocalExecBase, 60)); 
  Call(port, LocalExecBase);
end;

function GetMsg(port: PMsgPort): PMessage;
type
  TGetMsg = function(port: PMsgPort; Base: Pointer): PMessage; stdcall;
var
  Call: TGetMsg;
begin
  Call := TGetMsg(GetLibAdress(LocalExecBase, 62));
  GetMsg := Call(port, LocalExecBase);
end;

function WaitPort(port: PMsgPort): PMessage;
type
  TWaitPort = function(port: PMsgPort; Base: Pointer): PMessage; stdcall;
var
  Call: TWaitPort;
begin
  Call := TWaitPort(GetLibAdress(LocalExecBase, 64));
  WaitPort := Call(port, LocalExecBase);
end;

procedure CloseLibrary(libHandle: PLibrary);
type
  TCloseLibrary = procedure(libHandle: PLibrary; Base: Pointer); stdcall;
var
  Call: TCloseLibrary;
begin
  Call := TCloseLibrary(GetLibAdress(LocalExecBase, 69)); 
  Call(libHandle, LocalExecBase);
end;

function OpenDevice(devName: PChar; numunit: Cardinal; ioRequest: pIORequest; flags: Cardinal): ShortInt;
type
  TOpenDevice = function(devName: PChar; numunit: Cardinal; ioRequest: pIORequest; flags: Cardinal; Base: Pointer): ShortInt; stdcall;
var
  Call: TOpenDevice;
begin
  Call := TOpenDevice(GetLibAdress(LocalExecBase, 74));
  OpenDevice := Call(devName, numunit, ioRequest, flags, LocalExecBase);
end;

procedure CloseDevice(ioRequest: PIORequest);
type
  TCloseDevice = procedure(ioRequest: PIORequest; Base: Pointer); stdcall;
var
  Call: TCloseDevice;
begin
  Call := TCloseDevice(GetLibAdress(LocalExecBase, 75)); 
  Call(ioRequest, LocalExecBase);
end;

function DoIO(ioRequest: PIORequest): ShortInt;
type
  TDoIO = function(ioRequest: PIORequest; Base: Pointer): ShortInt; stdcall;
var
  Call: TDoIO;
begin
  Call := TDoIO(GetLibAdress(LocalExecBase, 76));
  DoIO := Call(ioRequest, LocalExecBase);
end;

function OpenLibrary(libname: PChar; libver : Cardinal): Pointer;
type
  TOpenLibrary = function(libname: PChar; libver : Cardinal; Base: Pointer): Pointer; stdcall;
var
  Call: TOpenLibrary;
begin
  Call := TOpenLibrary(GetLibAdress(LocalExecBase, 92));
  OpenLibrary := Call(libname, libver, LocalExecBase);
end;

function CreatePool(requirements: Cardinal; puddleSize: Cardinal; threshSize: Cardinal): Pointer;
type
  TCreatePool = function(requirements: Cardinal; puddleSize: Cardinal; threshSize: Cardinal; Base: Pointer): Pointer; stdcall;
var
  Call: TCreatePool;
begin
  Call := TCreatePool(GetLibAdress(LocalExecBase, 116));
  CreatePool := Call(requirements, puddleSize, threshSize, LocalExecBase);
end;

procedure DeletePool(poolHeader: Pointer);
type
  TDeletePool = procedure(poolHeader: Pointer; Base: Pointer); stdcall;
var
  Call: TDeletePool;
begin
  Call := TDeletePool(GetLibAdress(LocalExecBase, 117));
  Call(poolHeader, LocalExecBase);
end;

function AllocPooled(poolHeader: Pointer; memSize: Cardinal): Pointer;
type
  TAllocPooled = function (poolHeader: Pointer; memSize: Cardinal; Base: Pointer): Pointer; stdcall;
var
  Call: TAllocPooled;
begin
  Call := TAllocPooled(GetLibAdress(LocalExecBase, 118));
  AllocPooled := Call(poolHeader, memSize, LocalExecBase);
end;

function FreePooled(poolHeader: Pointer; memory: Pointer; memSize: Cardinal): Pointer;
type
  TFreePooled = function (poolHeader: Pointer; memory: Pointer; memSize: Cardinal; Base: Pointer): Pointer; stdcall;
var
  Call: TFreePooled;
begin
  Call := TFreePooled(GetLibAdress(LocalExecBase, 119));
  FreePooled := Call(poolHeader, memory, memSize, LocalExecBase);
end;

