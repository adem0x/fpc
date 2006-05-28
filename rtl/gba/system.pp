{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2006 by Francesco Lombardi.

    System unit for Gameboy Advance

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit System;

interface

{$define __ARM__} (* For future usage! *)
{$define FPC_IS_SYSTEM}

{$i gbabiosh.inc}

{$I systemh.inc}

const
 LineEnding = #10;
 LFNSupport = true;
 CtrlZMarksEOF: boolean = false; 
 DirectorySeparator = '/';
 DriveSeparator = ':';
 PathSeparator = ';';
 FileNameCaseSensitive = false;
 maxExitCode = 255;
 MaxPathLen = 255;


 sLineBreak : string[1] = LineEnding;
 DefaultTextLineBreakStyle : TTextLineBreakStyle = tlbsCRLF;
  
const
  UnusedHandle    = $ffff;
  StdInputHandle  = 0;
  StdOutputHandle = 1;
  StdErrorHandle  = $ffff;


var
  argc: LongInt = 0;
  argv: PPChar;
  envp: PPChar;
  errno: integer;


implementation

{$I system.inc}

{$i gbabios.inc}


function GetProcessID: SizeUInt;
begin
end;



{*****************************************************************************
                       Misc. System Dependent Functions
*****************************************************************************}
procedure System_exit;
begin
end;



{*****************************************************************************
                             ParamStr/Randomize
*****************************************************************************}

{ number of args }
function paramcount : longint;
begin
  paramcount:=0;
end;

{ argument number l }
function paramstr(l : longint) : string;
begin
  paramstr:='';
end;

{ set randseed to a new pseudo random value }
procedure randomize;
begin
end;

procedure SysInitStdIO;
begin
  OpenStdIO(Input,fmInput,StdInputHandle);
  OpenStdIO(Output,fmOutput,StdOutputHandle);
  OpenStdIO(StdOut,fmOutput,StdOutputHandle);
end;


function CheckInitialStkLen(stklen : SizeUInt) : SizeUInt;
begin
  result := stklen;
end;


begin
  StackLength := CheckInitialStkLen(InitialStkLen);
  StackBottom := Sptr - StackLength;
{ OS specific startup }

{ Set up signals handlers }

{ Setup heap }
  InitHeap;
  SysInitExceptions;
{ Setup stdin, stdout and stderr }
  SysInitStdIO;
{ Reset IO Error }
  InOutRes:=0;
{ Arguments }

  InitSystemThreads;
  initvariantmanager;
  initwidestringmanager;
end.
