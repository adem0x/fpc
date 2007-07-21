{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2004 by Marco van de Voort, member of the
    Free Pascal development team

    Implements C types for in header conversions

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


 **********************************************************************}

unit ctypes;

interface

{$ifdef unix}
uses unixtype;
{$i aliasctp.inc}
{$else}

type
{$ifndef FPC}
    qword = int64;  // Keep h2pas "uses ctypes" headers working with delphi.
{$endif}

  { the following type definitions are compiler dependant }
  { and system dependant                                  }

  cint8                  = shortint;           pcint8                 = ^cint8;
  cuint8                 = byte;               pcuint8                = ^cuint8;
  cchar                  = cint8;              pcchar                 = ^cchar;
  cschar                 = cint8;              pcschar                = ^cschar;
  cuchar                 = cuint8;             pcuchar                = ^cuchar;

  cint16                 = smallint;           pcint16                = ^cint16;
  cuint16                = word;               pcuint16               = ^cuint16;
  cshort                 = cint16;             pcshort                = ^cshort;
  csshort                = cint16;             pcsshort               = ^csshort;
  cushort                = cuint16;            pcushort               = ^cushort;

  cint32                 = longint;            pcint32                = ^cint32;
  cuint32                = longword;           pcuint32               = ^cuint32;
  cint                   = cint32;             pcint                  = ^cint;              { minimum range is : 32-bit    }
  csint                  = cint32;             pcsint                 = ^csint;             { minimum range is : 32-bit    }
  cuint                  = cuint32;            pcuint                 = ^cuint;             { minimum range is : 32-bit    }
  csigned                = cint;               pcsigned               = ^csigned;
  cunsigned              = cuint;              pcunsigned             = ^cunsigned;

  cint64                 = int64;              pcint64                = ^cint64;
  cuint64                = qword;              pcuint64               = ^cuint64;
  clonglong              = cint64;             pclonglong             = ^clonglong;
  cslonglong             = cint64;             pcslonglong            = ^cslonglong;
  culonglong             = cuint64;            pculonglong            = ^culonglong;

  cbool                  = longbool;           pcbool                 = ^cbool;

{$if defined(cpu64) and not(defined(win64) and defined(cpux86_64))}
  clong                  = int64;              pclong                 = ^clong;
  cslong                 = int64;              pcslong                = ^cslong;
  culong                 = qword;              pculong                = ^culong;
{$else}
  clong                  = longint;            pclong                 = ^clong;
  cslong                 = longint;            pcslong                = ^cslong;
  culong                 = cardinal;           pculong                = ^culong;
{$endif}

  cfloat                 = single;             pcfloat                = ^cfloat;
  cdouble                = double;             pcdouble               = ^cdouble;

{$ifdef windows}
  clongdouble=double;
{$else}
  {$ifdef x86}
  {$define longdouble_assignment_overload_real80}
  clongdouble = packed record
    value:extended;
  {$ifdef defined(cpu64) or defined(darwin)}
    padding:array[0..5] of byte;
  {$else}
    padding:array[0..1] of byte;
  {$endif}
  end;
  {$else}
  {$define longdouble_assignment_overload_real128}
  clongdouble = packed array [0..15] of byte;
  {$endif}
{$endif}
  Pclongdouble=^clongdouble;

// Kylix compat types
  u_long  = culong;
  u_short = cushort;

{$endif}

{$ifdef longdouble_assignment_overload_real80}
operator := (const v:clongdouble):r:extended;
operator := (const v:extended):r:clongdouble;
{$endif}

{$ifdef longdouble_assignment_overload_real128}
{Non-x86 typically doesn't have extended. To be fixed once this changes.}
operator := (const v:clongdouble):r:double;
operator := (const v:double):r:clongdouble;
{$endif}

implementation

{$ifdef longdouble_assignment_overload_real80}
operator := (const v:clongdouble):r:extended;inline;

begin
  r:=v.value;
end;

operator := (const v:extended):r:clongdouble;inline;

begin
  r.value:=v;
end;
{$endif}

{$ifdef longdouble_assignment_overload_real128}

{$ifdef ENDIAN_LITTLE}
const r128_mantissa_ofs=0;
      r128_exponent_ofs=14;
{$else}
const r128_mantissa_ofs=2;
      r128_exponent_ofs=0;
{$endif}

operator := (const v:clongdouble):r:double;inline;

begin
  qword(r):=(qword(Pword(@v[r128_exponent_ofs])^) shl 52) or
            (Pqword(@v[r128_mantissa_ofs])^ shr 12);
end;

operator := (const v:double):r:clongdouble;inline;

begin
  Pword(@r[r128_exponent_ofs])^:=qword(v) shr 52;
  Pqword(@r[r128_mantissa_ofs])^:=qword(v) shl 12;
  Pcardinal(@r[r128_mantissa_ofs+8])^:=0;
  Pword(@r[r128_mantissa_ofs+12])^:=0;
end;
{$endif}

end.
