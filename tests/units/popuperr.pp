{
  $Id: popuperr.pp,v 1.2 2005/02/14 17:13:37 peter Exp $
    This file is part of the Free Pascal test suite.
    Copyright (c) 1999-2004 by the Free Pascal development team.

    Used to avoid getting pop up windows for critical errors under Windows
    and OS/2 operating systems (extension of win32err unit by Pierre Muller).

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit popuperr;

interface

implementation

{$ifdef win32}
uses
  windows;
{$endif win32}

{$IFDEF OS2}
function _DosError (Error: longint): longint; cdecl;
                                                 external 'DOSCALLS' index 212;
{$ENDIF OS2}

begin
{$ifdef win32}
  SetErrorMode(
    SEM_FAILCRITICALERRORS or
    SEM_NOGPFAULTERRORBOX or
    SEM_NOOPENFILEERRORBOX);
{$endif win32}
{$IFDEF OS2}
  if os_Mode = osOS2 then _DosError (0);
{$ENDIF OS2}
end.

{
  $Log: popuperr.pp,v $
  Revision 1.2  2005/02/14 17:13:37  peter
    * truncate log

}
