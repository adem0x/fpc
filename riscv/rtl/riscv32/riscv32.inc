{

    This file is part of the Free Pascal run time library.
    Copyright (c) 2003 by the Free Pascal development team.

    Processor dependent implementation for the system unit for
    ARM

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{$asmmode gas}


{$IFNDEF INTERNAL_BACKTRACE}
{$define FPC_SYSTEM_HAS_GET_FRAME}
function get_frame:pointer;assembler;nostackframe;
  asm
  end;
{$ENDIF not INTERNAL_BACKTRACE}


{$define FPC_SYSTEM_HAS_GET_CALLER_ADDR}
function get_caller_addr(framebp:pointer;addr:pointer=nil):pointer;assembler;
  asm
  end;


{$define FPC_SYSTEM_HAS_GET_CALLER_FRAME}
function get_caller_frame(framebp:pointer;addr:pointer=nil):pointer;assembler;
  asm
  end;


{$define FPC_SYSTEM_HAS_SPTR}
Function Sptr : pointer;assembler;
  asm
  end;

procedure fpc_cpuinit;
begin
  { don't let libraries influence the FPU cw set by the host program }
  if not IsLibrary then
    SysInitFPU;
end;

function InterLockedDecrement (var Target: longint) : longint; assembler; nostackframe;
asm
   lw v0, (a0)
   addi v0, v0, -1
   sw v0, (a0)
end;

function InterLockedIncrement (var Target: longint) : longint; assembler; nostackframe;
asm
   lw v0, (a0)
   addi v0, v0, 1
   sw v0, (a0)
end;


function InterLockedExchange (var Target: longint;Source : longint) : longint; assembler; nostackframe;
asm
   lw v0, (a0)
   sw a1, (a0)
end;

function InterLockedExchangeAdd (var Target: longint;Source : longint) : longint; assembler; nostackframe;
asm
   lw v0, (a0)
   add a1, a1, v0
   sw a1, (a0)
end;


function InterlockedCompareExchange(var Target: longint; NewValue: longint; Comperand: longint): longint; assembler; nostackframe;
asm
   lw v0, (a0)
   beq v0, a2, .Lexit
   sw a1, (a0)
.Lexit:
end;

procedure fpc_cpucodeinit;
begin
end;

{$ifndef FPC_SYSTEM_HAS_MEM_BARRIER}
{$define FPC_SYSTEM_HAS_MEM_BARRIER}

{ Generic read/readwrite barrier code.  }
procedure barrier; assembler; nostackframe;
asm
  fence.i
end;

procedure ReadBarrier;{$ifdef SYSTEMINLINE}inline;{$endif}
begin
  barrier;
end;

procedure ReadDependencyBarrier;{$ifdef SYSTEMINLINE}inline;{$endif}
begin
  { reads imply barrier on earlier reads depended on; not required on ARM }
end;

procedure ReadWriteBarrier;{$ifdef SYSTEMINLINE}inline;{$endif}
begin
  barrier;
end;

procedure WriteBarrier; assembler; nostackframe;
asm
   fence
end;

{$endif}