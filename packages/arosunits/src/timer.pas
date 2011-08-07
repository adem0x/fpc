{
    This file is part of the Free Pascal run time library.

    A file in Amiga system run time library.
    Copyright (c) 1998-2003 by Nils Sjoholm
    member of the Amiga RTL development team.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{
    History:
    Removed the var for all functions.
    06 Sep 2000.

    Added the define use_amiga_smartlink.
    13 Jan 2003.

    nils.sjoholm@mailbox.swipnet.se

}

unit timer;

INTERFACE

uses exec;

Const

{ unit defintions }
    UNIT_MICROHZ        = 0;
    UNIT_VBLANK         = 1;
    UNIT_ECLOCK         = 2;
    UNIT_WAITUNTIL      = 3;
    UNIT_WAITECLOCK     = 4;

    TIMERNAME : PChar   = 'timer.device';

Type

    ptimeval = ^ttimeval;
    ttimeval = record
        tv_secs         : ULONG;
        tv_micro        : ULONG;
    end;

    ptimerequest = ^ttimerequest;
    ttimerequest = record
        tr_node         : tIORequest;
        tr_time         : ttimeval;
    end;

    pEClockVal = ^tEClockVal;
    tEClockVal = record
        ev_hi : ULONG;
        ev_lo : ULONG;
    end;


Const

{ IO_COMMAND to use for adding a timer }
    TR_ADDREQUEST       = CMD_NONSTD;
    TR_GETSYSTIME       = CMD_NONSTD + 1;
    TR_SETSYSTIME       = CMD_NONSTD + 2;

{  To use any of the routines below, TimerBase must be set to point
   to the timer.device, either by calling CreateTimer or by pulling
   the device pointer from a valid TimeRequest, i.e.

        TimerBase := TimeRequest.io_Device;

    _after_ you have called OpenDevice on the timer.
 }

var
    TimerBase   : Pointer;

Procedure AddTime( Dest, Source : ptimeval);
Function CmpTime( Dest, Source : ptimeval) : ULONG;
Procedure SubTime( Dest, Source : ptimeval);
function ReadEClock(Dest : pEClockVal): longint;
procedure GetSysTime( Dest : ptimeval);

IMPLEMENTATION

Procedure AddTime(Dest, Source: ptimeval);
type
  TLocalCall = procedure(Dest, Source: ptimeval; LibBase: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(TimerBase, 7));
  Call(Dest, Source, TimerBase);
end;

Function CmpTime( Dest, Source : ptimeval) : ULONG;
type
  TLocalCall = function(Dest, Source : ptimeval; LibBase: Pointer): ULONG; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(TimerBase, 9));
  CmpTime := Call(Dest, Source, TimerBase);
end;

Procedure SubTime( Dest, Source : ptimeval);
type
  TLocalCall = procedure(Dest, Source: ptimeval; LibBase: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(TimerBase, 8));
  Call(Dest, Source, TimerBase);
end;

function ReadEClock(Dest : pEClockVal): longint;
type
  TLocalCall = function(Dest : pEClockVal; LibBase: Pointer): longint; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(TimerBase, 10));
  ReadEClock := Call(Dest, TimerBase);
end;

procedure GetSysTime(Dest: ptimeval);
type
  TLocalCall = procedure(Dest: ptimeval; LibBase: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(TimerBase, 11));
  Call(Dest, TimerBase);
end;


end.
