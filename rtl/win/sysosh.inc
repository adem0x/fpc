{
    Basic Windows stuff

    This file is part of the Free Pascal run time library.
    Copyright (c) 2002-2005 by Free Pascal development team

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{ Platform specific information }
type
{$ifdef CPU64}
  THandle = QWord;
  ULONG_PTR = QWord;
{$else CPU64}
  THandle = DWord;
  ULONG_PTR = DWord;
{$endif CPU64}
  TThreadID = THandle;
  SIZE_T = ULONG_PTR;

const
{$ifdef WINCE}
  KernelDLL = 'coredll';
  ApiSuffix = 'W';
{$else WINCE}
  KernelDLL = 'kernel32';
  ApiSuffix = 'A';
{$endif WINCE}

  function OleStrToString(source: PWideChar) : ansistring;inline;
  procedure OleStrToStrVar(source : PWideChar;var dest : ansistring);inline;
  function StringToOleStr(const source : ansistring) : PWideChar;inline;
