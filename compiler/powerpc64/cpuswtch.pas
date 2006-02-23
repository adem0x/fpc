{
    Copyright (c) 1998-2002 by Florian Klaempfl, Pierre Muller

    interprets the commandline options which are PowerPC64 specific

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

 ****************************************************************************
}
unit cpuswtch;

{$I fpcdefs.inc}

interface

uses
  options;

type
  toptionpowerpc = class(toption)
    procedure interpret_proc_specific_options(const opt: string); override;
  end;

implementation

uses
  cutils, globtype, systems, globals;

procedure toptionpowerpc.interpret_proc_specific_options(const opt: string);
var
  more: string;
  j: longint;
begin
  More := Upper(copy(opt, 3, length(opt) - 2));
  case opt[2] of
    'O':
      begin
        j := 3;
        while (j <= Length(Opt)) do
        begin
          case opt[j] of
            '-':
              begin
                initglobalswitches := initglobalswitches - [cs_optimize,
                  cs_fastoptimize, cs_slowoptimize, cs_littlesize,
                  cs_regvars, cs_uncertainopts];
                FillChar(ParaAlignment, sizeof(ParaAlignment), 0);
              end;
            'a':
              begin
                UpdateAlignmentStr(Copy(Opt, j + 1, 255), ParaAlignment);
                j := length(Opt);
              end;
            'g': initglobalswitches := initglobalswitches + [cs_littlesize];
            'G': initglobalswitches := initglobalswitches - [cs_littlesize];
            'r':
              begin
                initglobalswitches := initglobalswitches + [cs_regvars];
                Simplify_ppu := false;
              end;
            'u': initglobalswitches := initglobalswitches + [cs_uncertainopts];
            '1': initglobalswitches := initglobalswitches - [cs_fastoptimize,
              cs_slowoptimize] + [cs_optimize];
            '2': initglobalswitches := initglobalswitches - [cs_slowoptimize] +
              [cs_optimize, cs_fastoptimize];
            '3': initglobalswitches := initglobalswitches + [cs_optimize,
              cs_fastoptimize, cs_slowoptimize];
{$IFDEF dummy}
            'p':
              begin
                if j < Length(Opt) then
                begin
                  case opt[j + 1] of
                    '1': initoptprocessor := Class386;
                    '2': initoptprocessor := ClassP5;
                    '3': initoptprocessor := ClassP6
                  else
                    IllegalPara(Opt)
                  end;
                  Inc(j);
                end
                else
                  IllegalPara(opt)
              end;
{$ENDIF dummy}
          else
            IllegalPara(opt);
          end;
          Inc(j)
        end;
      end;
{$IFDEF dummy}
    'R':
      begin
        if More = 'GAS' then
          initasmmode := asmmode_ppc_gas
        else if More = 'MOTOROLA' then
          initasmmode := asmmode_ppc_motorola
        else if More = 'DIRECT' then
          initasmmode := asmmode_direct
        else
          IllegalPara(opt);
      end;
{$ENDIF dummy}
  else
    IllegalPara(opt);
  end;
end;

initialization
  coption := toptionpowerpc;
end.

