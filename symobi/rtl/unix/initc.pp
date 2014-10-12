{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by Michael Van Canneyt and Peter Vreman,
    members of the Free Pascal development team

    This file links to libc, and handles the libc errno abstraction.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit initc;
interface
uses
  ctypes;
{$ifndef Symobi}
  {$linklib c}
{$endif}

function fpgetCerrno:cint;
procedure fpsetCerrno(err:cint);

property cerrno:cint read fpgetCerrno write fpsetcerrno;

const clib = 'c';

implementation
// hasn't been divided up in .inc's, because I first want to see hoe
// this idea works out.

{$ifdef OpenBSD}
{$define UseOldErrnoDirectLink}
{$endif}

{$ifdef UseOldErrnoDirectLink}
Var
  interrno : cint;external name {$ifdef OpenBSD} '_errno' {$else} 'h_errno'{$endif};

function fpgetCerrno:cint;

begin
  fpgetCerrno:=interrno;
end;

procedure fpsetCerrno(err:cint);
begin
  interrno:=err;
end;
{$else}


{$ifdef Linux}
function geterrnolocation: pcint; cdecl;external clib name '__errno_location';
{$endif}

{$ifdef FreeBSD} // tested on x86
function geterrnolocation: pcint; cdecl;external clib name '__error';
{$endif}

{$ifdef NetBSD} // from a sparc dump.
function geterrnolocation: pcint; cdecl;external clib name '__errno';
{$endif}

{$ifdef Darwin}
function geterrnolocation: pcint; cdecl;external clib name '__error';
{$endif}


{$ifdef SunOS}
function geterrnolocation: pcint; cdecl;external clib name '___errno';
{$endif}

{$ifdef beos}
function geterrnolocation: pcint; cdecl;external 'root' name '_errnop';
{$endif}

{$ifdef Symobi}
function geterrnolocation: pcint; cdecl;external clib name 'getThdErrno';
{$endif}

function fpgetCerrno:cint;

begin
  fpgetCerrno:=geterrnolocation^;
end;

procedure fpsetCerrno(err:cint);
begin
  geterrnolocation^:=err;
end;

{$endif}

end.