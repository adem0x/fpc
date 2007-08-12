{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2005 by Florian Klaempfl,
    member of the Free Pascal development team.

    libc based wide string support

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 **********************************************************************}

{$mode objfpc}

unit cwstring;

interface

procedure SetCWidestringManager;

implementation

{$linklib c}

{$if not defined(linux) and not defined(solaris)}  // Linux (and maybe glibc platforms in general), have iconv in glibc.
 {$linklib iconv}
 {$define useiconv}
{$endif linux}

Uses
  BaseUnix,
  ctypes,
  unix,
  unixtype,
  initc;

Const
{$ifndef useiconv}
    libiconvname='c';  // is in libc under Linux.
{$else}
    libiconvname='iconv';
{$endif}

{ helper functions from libc }
function towlower(__wc:wint_t):wint_t;cdecl;external libiconvname name 'towlower';
function towupper(__wc:wint_t):wint_t;cdecl;external libiconvname name 'towupper';
function wcscoll (__s1:pwchar_t; __s2:pwchar_t):cint;cdecl;external libiconvname name 'wcscoll';
function strcoll (__s1:pchar; __s2:pchar):cint;cdecl;external libiconvname name 'strcoll';
function setlocale(category: cint; locale: pchar): pchar; cdecl; external clib name 'setlocale';

const
{$ifdef linux}
  __LC_CTYPE = 0;
  LC_ALL = 6;
  _NL_CTYPE_CLASS = (__LC_CTYPE shl 16);
  _NL_CTYPE_CODESET_NAME = (_NL_CTYPE_CLASS)+14;
  CODESET = _NL_CTYPE_CODESET_NAME;
{$else linux}
{$ifdef darwin}
  CODESET = 0;
  LC_ALL = 0;
{$else darwin}
{$ifdef FreeBSD} // actually FreeBSD5. internationalisation is afaik not default on 4.
  __LC_CTYPE = 0;
  LC_ALL = 0;
  _NL_CTYPE_CLASS = (__LC_CTYPE shl 16);
  _NL_CTYPE_CODESET_NAME = (_NL_CTYPE_CLASS)+14;
  CODESET = 0; // _NL_CTYPE_CODESET_NAME;
{$else freebsd}
{$ifdef solaris}
  CODESET=49;
  LC_ALL = 6;
{$else}
{$error lookup the value of CODESET in /usr/include/langinfo.h, and the value of LC_ALL in /usr/include/locale.h for your OS }
// and while doing it, check if iconv is in libc, and if the symbols are prefixed with iconv_ or libiconv_
{$endif solaris}
{$endif FreeBSD}
{$endif darwin}
{$endif linux}

{ unicode encoding name }
{$ifdef FPC_LITTLE_ENDIAN}
  unicode_encoding2 = 'UTF-16LE';
  unicode_encoding4 = 'UCS-4LE'; 
{$else  FPC_LITTLE_ENDIAN}
  unicode_encoding2 = 'UTF-16BE';
  unicode_encoding4 = 'UCS-4BE';
{$endif  FPC_LITTLE_ENDIAN}

type
  piconv_t = ^iconv_t;
  iconv_t = pointer;
  nl_item = cint;

function nl_langinfo(__item:nl_item):pchar;cdecl;external libiconvname name 'nl_langinfo';
{$ifndef bsd}
function iconv_open(__tocode:pchar; __fromcode:pchar):iconv_t;cdecl;external libiconvname name 'iconv_open';
function iconv(__cd:iconv_t; __inbuf:ppchar; __inbytesleft:psize_t; __outbuf:ppchar; __outbytesleft:psize_t):size_t;cdecl;external libiconvname name 'iconv';
function iconv_close(__cd:iconv_t):cint;cdecl;external libiconvname name 'iconv_close';
{$else}
function iconv_open(__tocode:pchar; __fromcode:pchar):iconv_t;cdecl;external libiconvname name 'libiconv_open';
function iconv(__cd:iconv_t; __inbuf:ppchar; __inbytesleft:psize_t; __outbuf:ppchar; __outbytesleft:psize_t):size_t;cdecl;external libiconvname name 'libiconv';
function iconv_close(__cd:iconv_t):cint;cdecl;external libiconvname name 'libiconv_close';
{$endif}

threadvar
  iconv_ansi2ucs4,
  iconv_ucs42ansi,
  iconv_ansi2wide,
  iconv_wide2ansi : iconv_t;
 
procedure Wide2AnsiMove(source:pwidechar;var dest:ansistring;len:SizeInt);
  var
    outlength,
    outoffset,
    srclen,
    outleft : size_t;
    srcpos : pwidechar;
    destpos: pchar;
    mynil : pchar;
    my0 : size_t;
    err: cint;
  begin
    mynil:=nil;
    my0:=0;
    { rought estimation }
    setlength(dest,len*3);
    outlength:=len*3;
    srclen:=len*2;
    srcpos:=source;
    destpos:=pchar(dest);
    outleft:=outlength;
    while iconv(iconv_wide2ansi,ppchar(@srcpos),@srclen,@destpos,@outleft)=size_t(-1) do
      begin
        err:=fpgetCerrno;
        case err of
          { last character is incomplete sequence }
          ESysEINVAL,
          { incomplete sequence in the middle }
          ESysEILSEQ:
            begin
              { skip and set to '?' }
              inc(srcpos);
              dec(srclen,2);
              destpos^:='?';
              inc(destpos);
              dec(outleft);
              { reset }
              iconv(iconv_wide2ansi,@mynil,@my0,@mynil,@my0);
              if err=ESysEINVAL then
                break;
            end;
          ESysE2BIG:
            begin
              outoffset:=destpos-pchar(dest);
              { extend }
              setlength(dest,outlength+len*3);
              inc(outleft,len*3);
              inc(outlength,len*3);
              { string could have been moved }
              destpos:=pchar(dest)+outoffset;
            end;
          else
            runerror(231);
        end;
      end;
    // truncate string
    setlength(dest,length(dest)-outleft);
  end;


procedure Ansi2WideMove(source:pchar;var dest:widestring;len:SizeInt);
  var
    outlength,
    outoffset,
    outleft : size_t;
    srcpos,
    destpos: pchar;
    mynil : pchar;
    my0 : size_t;
    err: cint;
  begin
    mynil:=nil;
    my0:=0;
    // extra space
    outlength:=len+1;
    setlength(dest,outlength);
    srcpos:=source;
    destpos:=pchar(dest);
    outleft:=outlength*2;
    while iconv(iconv_ansi2wide,@srcpos,psize(@len),@destpos,@outleft)=size_t(-1) do
      begin
        err:=fpgetCerrno;
        case err of
         ESysEINVAL,
         ESysEILSEQ:
            begin
              { skip and set to '?' }
              inc(srcpos);
              dec(len);
              pwidechar(destpos)^:='?';
              inc(destpos,2);
              dec(outleft,2);
              { reset }
              iconv(iconv_ansi2wide,@mynil,@my0,@mynil,@my0);
              if err=ESysEINVAL then
                break;
            end;
          ESysE2BIG:
            begin
              outoffset:=destpos-pchar(dest);
              { extend }
              setlength(dest,outlength+len);
              inc(outleft,len*2);
              inc(outlength,len);
              { string could have been moved }
              destpos:=pchar(dest)+outoffset;
            end;
          else
            runerror(231);
        end;
      end;
    // truncate string
    setlength(dest,length(dest)-outleft div 2);
  end;


function LowerWideString(const s : WideString) : WideString;
  var
    i : SizeInt;
  begin
    SetLength(result,length(s));
    for i:=1 to length(s) do
      result[i]:=WideChar(towlower(wint_t(s[i])));
  end;


function UpperWideString(const s : WideString) : WideString;
  var
    i : SizeInt;
  begin
    SetLength(result,length(s));
    for i:=1 to length(s) do
      result[i]:=WideChar(towupper(wint_t(s[i])));
  end;


procedure Ansi2UCS4Move(source:pchar;var dest:UCS4String;len:SizeInt);
  var
    outlength,
    outoffset,
    outleft : size_t;
    srcpos,
    destpos: pchar;
    mynil : pchar;
    my0 : size_t;
  begin
    mynil:=nil;
    my0:=0;
    // extra space
    outlength:=len+1;
    setlength(dest,outlength);
    outlength:=len+1;
    srcpos:=source;
    destpos:=pchar(dest);
    outleft:=outlength*4;
    while iconv(iconv_ansi2ucs4,@srcpos,psize(@len),@destpos,@outleft)=size_t(-1) do
      begin
        case fpgetCerrno of
          ESysE2BIG:
            begin
              outoffset:=destpos-pchar(dest);
              { extend }
              setlength(dest,outlength+len);
              inc(outleft,len*4);
              inc(outlength,len);
              { string could have been moved }
              destpos:=pchar(dest)+outoffset;
            end;
          else
            runerror(231);
        end;
      end;
    // truncate string
    setlength(dest,length(dest)-outleft div 4);
  end;


function CompareWideString(const s1, s2 : WideString) : PtrInt;
  var
    hs1,hs2 : UCS4String;
  begin
    hs1:=WideStringToUCS4String(s1);
    hs2:=WideStringToUCS4String(s2);
    result:=wcscoll(pwchar_t(hs1),pwchar_t(hs2));
  end;


function CompareTextWideString(const s1, s2 : WideString): PtrInt;
  begin
    result:=CompareWideString(UpperWideString(s1),UpperWideString(s2));
  end;


function StrCompAnsi(s1,s2 : PChar): PtrInt;
  begin
    result:=strcoll(s1,s2);
  end;


procedure InitThread;
begin
  iconv_wide2ansi:=iconv_open(nl_langinfo(CODESET),unicode_encoding2);
  iconv_ansi2wide:=iconv_open(unicode_encoding2,nl_langinfo(CODESET));
  iconv_ucs42ansi:=iconv_open(nl_langinfo(CODESET),unicode_encoding4);
  iconv_ansi2ucs4:=iconv_open(unicode_encoding4,nl_langinfo(CODESET));
end;


procedure FiniThread;
begin
  if (iconv_wide2ansi <> iconv_t(-1)) then
    iconv_close(iconv_wide2ansi);
  if (iconv_ansi2wide <> iconv_t(-1)) then
    iconv_close(iconv_ansi2wide);
  if (iconv_ucs42ansi <> iconv_t(-1)) then
    iconv_close(iconv_ucs42ansi);
  if (iconv_ansi2ucs4 <> iconv_t(-1)) then
    iconv_close(iconv_ansi2ucs4);
end;


Procedure SetCWideStringManager;
Var
  CWideStringManager : TWideStringManager;
begin
  CWideStringManager:=widestringmanager;
  With CWideStringManager do
    begin
      Wide2AnsiMoveProc:=@Wide2AnsiMove;
      Ansi2WideMoveProc:=@Ansi2WideMove;

      UpperWideStringProc:=@UpperWideString;
      LowerWideStringProc:=@LowerWideString;

      CompareWideStringProc:=@CompareWideString;
      CompareTextWideStringProc:=@CompareTextWideString;
      {
      CharLengthPCharProc

      UpperAnsiStringProc
      LowerAnsiStringProc
      CompareStrAnsiStringProc
      CompareTextAnsiStringProc
      }
      StrCompAnsiStringProc:=@StrCompAnsi;
      {
      StrICompAnsiStringProc
      StrLCompAnsiStringProc
      StrLICompAnsiStringProc
      StrLowerAnsiStringProc
      StrUpperAnsiStringProc
      }
      ThreadInitProc:=@InitThread;
      ThreadFiniProc:=@FiniThread;
    end;
  SetWideStringManager(CWideStringManager);
end;


initialization
  SetCWideStringManager;

  { you have to call setlocale(LC_ALL,'') to initialise the langinfo stuff  }
  { with the information from the environment variables according to POSIX  }
  { (some OSes do this automatically, but e.g. Darwin and Solaris don't)    }
  setlocale(LC_ALL,'');

  { init conversion tables for main program }
  InitThread;
finalization
  { fini conversion tables for main program }
  FiniThread;
end.
