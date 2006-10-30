{
    Copyright (c) 1998-2002 by the FPC Development Team

    Dumps the contents of a FPC unit file (PPU File)

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

 ****************************************************************************}
{$ifdef TP}
  {$N+,E+}
{$endif}
program pppdump;
uses
  dos,
  ppu,
  globals,
  tokens;

const
  Version   = 'Version 2.1.1';
  Title     = 'PPU-Analyser';
  Copyright = 'Copyright (c) 1998-2006 by the Free Pascal Development Team';

{ verbosity }
  v_none           = $0;
  v_header         = $1;
  v_defs           = $2;
  v_syms           = $4;
  v_interface      = $8;
  v_implementation = $10;
  v_browser        = $20;
  v_all            = $ff;

type
  tprocinfoflag=(
    {# procedure uses asm }
    pi_uses_asm,
    {# procedure does a call }
    pi_do_call,
    {# procedure has a try statement = no register optimization }
    pi_uses_exceptions,
    {# procedure is declared as @var(assembler), don't optimize}
    pi_is_assembler,
    {# procedure contains data which needs to be finalized }
    pi_needs_implicit_finally
  );
  tprocinfoflags=set of tprocinfoflag;

  { Copied from systems.pas }
       tsystemcpu=
       (
             cpu_no,                       { 0 }
             cpu_i386,                     { 1 }
             cpu_m68k,                     { 2 }
             cpu_alpha,                    { 3 }
             cpu_powerpc,                  { 4 }
             cpu_sparc,                    { 5 }
             cpu_vm,                       { 6 }
             cpu_iA64,                     { 7 }
             cpu_x86_64,                   { 8 }
             cpu_mips,                     { 9 }
             cpu_arm                       { 10 }
       );

var
  ppufile     : tppufile;
  space       : string;
  unitindex   : longint;
  verbose     : longint;
  derefdata   : pbyte;
  derefdatalen : longint;

{****************************************************************************
                          Helper Routines
****************************************************************************}

const has_errors : boolean = false;
Procedure Error(const S : string);
Begin
   Writeln(S);
   has_errors:=true;
End;


function ToStr(w:longint):String;
begin
  Str(w,ToStr);
end;

Function Target2Str(w:longint):string;
type
       { taken from systems.pas }
       ttarget =
       (
             target_none,               { 0 }
             target_i386_GO32V1,        { 1 }
             target_i386_GO32V2,        { 2 }
             target_i386_linux,         { 3 }
             target_i386_OS2,           { 4 }
             target_i386_Win32,         { 5 }
             target_i386_freebsd,       { 6 }
             target_m68k_Amiga,         { 7 }
             target_m68k_Atari,         { 8 }
             target_m68k_Mac,           { 9 }
             target_m68k_linux,         { 10 }
             target_m68k_PalmOS,        { 11 }
             target_alpha_linux,        { 12 }
             target_powerpc_linux,      { 13 }
             target_powerpc_macos,      { 14 }
             target_i386_sunos,         { 15 }
             target_i386_beos,          { 16 }
             target_i386_netbsd,        { 17 }
             target_m68k_netbsd,        { 18 }
             target_i386_Netware,       { 19 }
             target_i386_qnx,           { 20 }
             target_i386_wdosx,         { 21 }
             target_sparc_sunos,        { 22 }
             target_sparc_linux,        { 23 }
             target_i386_openbsd,       { 24 }
             target_m68k_openbsd,       { 25 }
             system_x86_64_linux,       { 26 }
             system_powerpc_macosx,     { 27 }
             target_i386_emx,           { 28 }
             target_powerpc_netbsd,     { 29 }
             target_powerpc_openbsd,    { 30 }
             target_arm_linux,          { 31 }
             target_i386_watcom,        { 32 }
             target_powerpc_MorphOS,    { 33 }
             target_x86_64_freebsd,     { 34 }
             target_i386_netwlibc,      { 35 }
             system_powerpc_Amiga,      { 36 }
             system_x86_64_win64,       { 37 }
             system_arm_wince,          { 38 }
             system_ia64_win64,         { 39 }
             system_i386_wince,         { 40 }
             system_x86_6432_linux,     { 41 }
             system_arm_gba             { 42 }
       );
const
  Targets : array[ttarget] of string[17]=(
  { 0 }   'none',
  { 1 }   'GO32V1',
  { 2 }   'GO32V2',
  { 3 }   'Linux-i386',
  { 4 }   'OS/2',
  { 5 }   'Win32',
  { 6 }   'FreeBSD-i386',
  { 7 }   'Amiga',
  { 8 }   'Atari',
  { 9 }   'MacOS-m68k',
  { 10 }  'Linux-m68k',
  { 11 }  'PalmOS-m68k',
  { 12 }  'Linux-alpha',
  { 13 }  'Linux-ppc',
  { 14 }  'MacOS-ppc',
  { 15 }  'Solaris-i386',
  { 16 }  'BeOS-i386',
  { 17 }  'NetBSD-i386',
  { 18 }  'NetBSD-m68k',
  { 19 }  'Netware-i386-clib',
  { 20 }  'Qnx-i386',
  { 21 }  'WDOSX-i386',
  { 22 }  'Solaris-sparc',
  { 23 }  'Linux-sparc',
  { 24 }  'OpenBSD-i386',
  { 25 }  'OpenBSD-m68k',
  { 26 }  'Linux-x86-64',
  { 27 }  'MacOSX-ppc',
  { 28 }  'OS/2 via EMX',
  { 29 }  'NetBSD-powerpc',
  { 30 }  'OpenBSD-powerpc',
  { 31 }  'Linux-arm',
  { 32 }  'Watcom-i386',
  { 33 }  'MorphOS-powerpc',
  { 34 }  'FreeBSD-x86-64',
  { 35 }  'Netware-i386-libc',
  { 36 }  'Amiga-PowerPC',
  { 37 }  'Win64-x64',
  { 38 }  'WinCE-ARM',
  { 39 }  'Win64-iA64',
  { 40 }  'WinCE-i386',
  { 41 }  'Linux-x64',
  { 42 }  'GBA-ARM'
  );
begin
  if w<=ord(high(ttarget)) then
    Target2Str:=Targets[ttarget(w)]
  else
    Target2Str:='<!! Unknown target value '+tostr(w)+'>';
end;


Function Cpu2Str(w:longint):string;
const
  CpuTxt : array[tsystemcpu] of string[8]=
    ('none','i386','m68k','alpha','powerpc','sparc','vis','ia64','x86_64','mips','arm');
begin
  if w<=ord(high(tsystemcpu)) then
    Cpu2Str:=CpuTxt[tsystemcpu(w)]
  else
    Cpu2Str:='<!! Unknown cpu value '+tostr(w)+'>';
end;


Function Varspez2Str(w:longint):string;
const
  varspezstr : array[0..4] of string[6]=('Value','Const','Var','Out','Hidden');
begin
  if w<=ord(high(varspezstr)) then
    Varspez2Str:=varspezstr[w]
  else
    Varspez2Str:='<!! Unknown varspez value '+tostr(w)+'>';
end;

Function VarRegable2Str(w:longint):string;
const
  varregableStr : array[0..3] of string[6]=('None','IntReg','FPUReg','MMReg');
begin
  if w<=ord(high(varregablestr)) then
    Varregable2Str:=varregablestr[w]
  else
    Varregable2Str:='<!! Unknown regable value '+tostr(w)+'>';
end;


function PPUFlags2Str(flags:longint):string;
type
  tflagopt=record
    mask : longint;
    str  : string[30];
  end;
const
  flagopts=19;
  flagopt : array[1..flagopts] of tflagopt=(
    (mask: $1    ;str:'init'),
    (mask: $2    ;str:'final'),
    (mask: $4    ;str:'big_endian'),
    (mask: $8    ;str:'dbx'),
    (mask: $10   ;str:'browser'),
    (mask: $20   ;str:'in_library'),
    (mask: $40   ;str:'smart_linked'),
    (mask: $80   ;str:'static_linked'),
    (mask: $100  ;str:'shared_linked'),
    (mask: $200  ;str:'local_browser'),
    (mask: $400  ;str:'no_link'),
    (mask: $800  ;str:'has_resources'),
    (mask: $1000  ;str:'little_endian'),
    (mask: $2000  ;str:'release'),
    (mask: $4000  ;str:'local_threadvars'),
    (mask: $8000  ;str:'fpu_emulation_on'),
    (mask: $10000  ;str:'has_debug_info'),
    (mask: $20000  ;str:'local_symtable'),
    (mask: $40000  ;str:'uses_variants')
  );
var
  i : longint;
  first  : boolean;
  s : string;
begin
  s:='';
  if flags<>0 then
   begin
     first:=true;
     for i:=1to flagopts do
      if (flags and flagopt[i].mask)<>0 then
       begin
         if first then
           first:=false
         else
           s:=s+', ';
         s:=s+flagopt[i].str;
       end;
   end
  else
   s:='none';
  PPUFlags2Str:=s;
end;


const
  HexTbl : array[0..15] of char='0123456789ABCDEF';
function HexB(b:byte):string;
begin
  HexB[0]:=#2;
  HexB[1]:=HexTbl[b shr 4];
  HexB[2]:=HexTbl[b and $f];
end;


function hexstr(val : cardinal;cnt : byte) : string;
const
  HexTbl : array[0..15] of char='0123456789ABCDEF';
var
  i : longint;
begin
  hexstr[0]:=char(cnt);
  for i:=cnt downto 1 do
   begin
     hexstr[i]:=hextbl[val and $f];
     val:=val shr 4;
   end;
end;


    Function L0(l:longint):string;
    {
      return the string of value l, if l<10 then insert a zero, so
      the string is always at least 2 chars '01','02',etc
    }
      var
        s : string;
      begin
        Str(l,s);
        if l<10 then
         s:='0'+s;
        L0:=s;
      end;


   function  filetimestring( t : longint) : string;
   {
     convert dos datetime t to a string YY/MM/DD HH:MM:SS
   }
     var
       DT : DateTime;
     begin
       if t=-1 then
        begin
          FileTimeString:='Not Found';
          exit;
        end;
       unpacktime(t,DT);
       filetimestring:=L0(dt.Year)+'/'+L0(dt.Month)+'/'+L0(dt.Day)+' '+L0(dt.Hour)+':'+L0(dt.min)+':'+L0(dt.sec);
     end;


{****************************************************************************
                             Read Routines
****************************************************************************}

Procedure ReadLinkContainer(const prefix:string);
{
  Read a serie of strings and write to the screen starting every line
  with prefix
}
  function maskstr(m:longint):string;
  const
    { link options }
    link_none    = $0;
    link_always  = $1;
    link_static  = $2;
    link_smart   = $4;
    link_shared  = $8;
  var
    s : string;
  begin
    s:='';
    if (m and link_always)<>0 then
     s:=s+'always ';
    if (m and link_static)<>0 then
     s:=s+'static ';
    if (m and link_smart)<>0 then
     s:=s+'smart ';
    if (m and link_shared)<>0 then
     s:=s+'shared ';
    maskstr:=s;
  end;

var
  s : string;
  m : longint;
begin
  while not ppufile.endofentry do
   begin
     s:=ppufile.getstring;
     m:=ppufile.getlongint;
     WriteLn(prefix,s,' (',maskstr(m),')');
   end;
end;


Procedure ReadContainer(const prefix:string);
{
  Read a serie of strings and write to the screen starting every line
  with prefix
}
begin
  while not ppufile.endofentry do
   WriteLn(prefix,ppufile.getstring);
end;


procedure ReadLoadUnit;
var
  ucrc,uintfcrc : cardinal;
begin
  while not ppufile.EndOfEntry do
    begin
      write('Uses unit: ',ppufile.getstring);
      ucrc:=cardinal(ppufile.getlongint);
      uintfcrc:=cardinal(ppufile.getlongint);
      writeln(' (Crc: ',hexstr(ucrc,8),', IntfcCrc: ',hexstr(uintfcrc,8),')');
    end;
end;


Procedure ReadDerefmap;
var
  i,mapsize : longint;
begin
  mapsize:=ppufile.getlongint;
  writeln('DerefMapsize: ',mapsize);
  for i:=0 to mapsize-1 do
    writeln('DerefMap[',i,'] = ',ppufile.getstring);
end;


Procedure ReadImportSymbols;
var
  extlibname  : string;
  j,
  extsymcnt   : longint;
  extsymname  : string;
  extsymordnr : longint;
  extsymisvar : boolean;
begin
  while not ppufile.endofentry do
    begin
      extlibname:=ppufile.getstring;
      extsymcnt:=ppufile.getlongint;
      writeln('External Library: ',extlibname,' (',extsymcnt,' imports)');
      for j:=0 to extsymcnt-1 do
        begin
          extsymname:=ppufile.getstring;
          extsymordnr:=ppufile.getlongint;
          extsymisvar:=ppufile.getbyte<>0;
          writeln(' ',extsymname,' (OrdNr: ',extsymordnr,' IsVar: ',extsymisvar,')');
        end;
    end;
end;


Procedure ReadDerefdata;
begin
  derefdatalen:=ppufile.entrysize;
  if derefdatalen=0 then
    begin
      writeln('!! Error: derefdatalen=0');
      exit;
    end;
  Writeln('Derefdata length: ',derefdatalen);
  derefdata:=allocmem(derefdatalen);
  ppufile.getdata(derefdata^,derefdatalen);
end;


Procedure ReadRef;
begin
  if (verbose and v_browser)=0 then
   exit;
  while (not ppufile.endofentry) and (not ppufile.error) do
   Writeln(space,'        - Refered : ',ppufile.getword,', (',ppufile.getlongint,',',ppufile.getword,')');
end;


Procedure ReadAsmSymbols;
type
  { Copied from aasmbase.pas }
  TAsmsymbind=(AB_NONE,AB_EXTERNAL,AB_COMMON,AB_LOCAL,AB_GLOBAL);
  TAsmsymtype=(AT_NONE,AT_FUNCTION,AT_DATA,AT_SECTION,AT_LABEL);
var
  s,
  bindstr,
  typestr  : string;
  i : longint;
begin
  writeln(space,'Number of AsmSymbols: ',ppufile.getlongint);
  i:=0;
  while (not ppufile.endofentry) and (not ppufile.error) do
   begin
     s:=ppufile.getstring;
     case tasmsymbind(ppufile.getbyte) of
       AB_EXTERNAL :
         bindstr:='External';
       AB_COMMON :
         bindstr:='Common';
       AB_LOCAL :
         bindstr:='Local';
       AB_GLOBAL :
         bindstr:='Global';
       else
         bindstr:='<Error !!>'
     end;
     case tasmsymtype(ppufile.getbyte) of
       AT_FUNCTION :
         typestr:='Function';
       AT_DATA :
         typestr:='Data';
       AT_SECTION :
         typestr:='Section';
       AT_LABEL :
         typestr:='Label';
       else
         typestr:='<Error !!>'
     end;
     Writeln(space,'  ',i,' : ',s,' [',bindstr,',',typestr,']');
     inc(i);
   end;
end;


Procedure ReadPosInfo;
var
  info : byte;
  fileindex,line,column : longint;
begin
  with ppufile do
   begin
     {
       info byte layout in bits:
       0-1 - amount of bytes for fileindex
       2-3 - amount of bytes for line
       4-5 - amount of bytes for column
     }
     info:=getbyte;
     case (info and $03) of
      0 : fileindex:=getbyte;
      1 : fileindex:=getword;
      2 : fileindex:=(getbyte shl 16) or getword;
      3 : fileindex:=getlongint;
     end;
     case ((info shr 2) and $03) of
      0 : line:=getbyte;
      1 : line:=getword;
      2 : line:=(getbyte shl 16) or getword;
      3 : line:=getlongint;
     end;
     case ((info shr 4) and $03) of
      0 : column:=getbyte;
      1 : column:=getword;
      2 : column:=(getbyte shl 16) or getword;
      3 : column:=getlongint;
     end;
     Writeln(fileindex,' (',line,',',column,')');
   end;
end;


procedure readderef;
type
  tdereftype = (deref_nil,
    deref_sym,
    deref_def,
    deref_aktrecord,
    deref_aktstatic,
    deref_aktglobal,
    deref_aktlocal,
    deref_aktpara,
    deref_unit,
    deref_record,
    deref_local,
    deref_para,
    deref_parent_object,
    deref_symid,
    deref_defid
  );
var
  b : tdereftype;
  first : boolean;
  unitid : word;
  idx : longint;
  i,n : byte;
  pdata : pbyte;
begin
  if not assigned(derefdata) then
    exit;
  first:=true;
  idx:=ppufile.getlongint;
  if (idx>derefdatalen) then
    begin
      writeln('!! Error: Deref idx ',idx,' > ',derefdatalen);
      exit;
    end;
  write('(',idx,') ');
  pdata:=@derefdata[idx];
  i:=0;
  n:=pdata[i];
  inc(i);
  if n<1 then
    begin
      writeln('!! Error: Deref len < 1');
      exit;
    end;
  while (i<n) do
   begin
     if not first then
      write(', ')
     else
      first:=false;
     b:=tdereftype(pdata[i]);
     inc(i);
     case b of
       deref_nil :
         write('Nil');
       deref_symid :
         begin
           idx:=pdata[i] shl 24 or pdata[i+1] shl 16 or pdata[i+2] shl 8 or pdata[i+3];
           inc(i,4);
           write('SymId ',idx);
         end;
       deref_defid :
         begin
           idx:=pdata[i] shl 24 or pdata[i+1] shl 16 or pdata[i+2] shl 8 or pdata[i+3];
           inc(i,4);
           write('DefId ',idx);
         end;
       deref_def :
         begin
           idx:=pdata[i] shl 8;
           idx:=idx or pdata[i+1];
           inc(i,2);
           write('Definition ',idx);
         end;
       deref_sym :
         begin
           idx:=pdata[i] shl 8;
           idx:=idx or pdata[i+1];
           inc(i,2);
           write('Symbol ',idx);
         end;
       deref_aktrecord :
         write('AktRecord');
       deref_aktstatic :
         write('AktStatic');
       deref_aktglobal :
         write('AktGlobal');
       deref_aktlocal :
         write('AktLocal');
       deref_aktpara :
         write('AktPara');
       deref_unit :
         begin
           idx:=pdata[i] shl 8 or pdata[i+1];
           inc(i,2);
           write('Unit ',idx);
         end;
       deref_record :
         write('RecordDef');
       deref_para :
         write('Parameter of procdef');
       deref_local :
         write('Local of procdef');
       deref_parent_object :
         write('Parent object');
       else
         begin
           writeln('!! unsupported dereftyp: ',ord(b));
           break;
         end;
     end;
   end;
  writeln;
end;


procedure readtype;
begin
  readderef;
end;


procedure readsymlist(const s:string);
type
  tsltype = (sl_none,
    sl_load,
    sl_call,
    sl_subscript,
    sl_vec
  );
const
  slstr : array[tsltype] of string[9] = ('',
    'load',
    'call',
    'subscript',
    'vec'
  );
var
  sl : tsltype;
begin
  readderef;
  repeat
    sl:=tsltype(ppufile.getbyte);
    if sl=sl_none then
     break;
    write(s,'(',slstr[sl],') ');
    case sl of
      sl_call,
      sl_load,
      sl_subscript :
        readderef;
      sl_vec :
        writeln(ppufile.getlongint);
    end;
  until false;
end;


procedure readsymoptions;
type
  tsymoption=(sp_none,
    sp_public,
    sp_private,
    sp_published,
    sp_protected,
    sp_static,
    sp_hint_deprecated,
    sp_hint_platform,
    sp_hint_library,
    sp_hint_unimplemented,
    sp_has_overloaded,
    sp_internal  { internal symbol, not reported as unused }
  );
  tsymoptions=set of tsymoption;
  tsymopt=record
    mask : tsymoption;
    str  : string[30];
  end;
const
  symopts=11;
  symopt : array[1..symopts] of tsymopt=(
     (mask:sp_public;         str:'Public'),
     (mask:sp_private;        str:'Private'),
     (mask:sp_published;      str:'Published'),
     (mask:sp_protected;      str:'Protected'),
     (mask:sp_static;         str:'Static'),
     (mask:sp_hint_deprecated;str:'Hint Deprecated'),
     (mask:sp_hint_deprecated;str:'Hint Platform'),
     (mask:sp_hint_deprecated;str:'Hint Library'),
     (mask:sp_hint_deprecated;str:'Hint Unimplemented'),
     (mask:sp_has_overloaded; str:'Has overloaded'),
     (mask:sp_internal;       str:'Internal')
  );
var
  symoptions : tsymoptions;
  i      : longint;
  first  : boolean;
begin
  ppufile.getsmallset(symoptions);
  if symoptions<>[] then
   begin
     first:=true;
     for i:=1to symopts do
      if (symopt[i].mask in symoptions) then
       begin
         if first then
           first:=false
         else
           write(', ');
         write(symopt[i].str);
       end;
   end;
  writeln;
end;


procedure readcommonsym(const s:string);
var
  symid : longint;
begin
  symid:=ppufile.getlongint;
  writeln(space,'** Symbol Nr. ',ppufile.getword,' (',symid,') ',' **');
  writeln(space,s,ppufile.getstring);
  write(space,'     File Pos : ');
  readposinfo;
  write(space,'   SymOptions : ');
  readsymoptions;
end;


procedure readcommondef(const s:string);
type
  tdefoption=(df_none,
    { init data has been generated }
    df_has_inittable,
    { rtti data has been generated }
    df_has_rttitable,
    { dwarf debug info has been generated }
    df_has_dwarf_dbg_info,
    { type is unique, i.e. declared with type = type <tdef>; }
    df_unique,
    { type is a generic }
    df_generic,
    { type is a specialization of a generic type }
    df_specialization
  );
  tdefoptions=set of tdefoption;
  tdefopt=record
    mask : tdefoption;
    str  : string[30];
  end;
const
  defopts=6;
  defopt : array[1..defopts] of tdefopt=(
     (mask:df_has_inittable;  str:'InitTable'),
     (mask:df_has_rttitable;  str:'RTTITable'),
     (mask:df_has_dwarf_dbg_info;  str:'Dwarf DbgInfo'),
     (mask:df_unique;         str:'Unique Type'),
     (mask:df_generic;        str:'Generic'),
     (mask:df_specialization; str:'Specialization')
  );
var
  defoptions : tdefoptions;
  i      : longint;
  first  : boolean;
  tokenbufsize : longint;
  tokenbuf : pbyte;
  defid : longint;
begin
  defid:=ppufile.getlongint;
  writeln(space,'** Definition Nr. ',ppufile.getword,' (',defid,') ',' **');
  writeln(space,s);
  write  (space,'      Type symbol : ');
  readderef;
  write  (space,'       DefOptions : ');
  ppufile.getsmallset(defoptions);
  if defoptions<>[] then
    begin
      first:=true;
      for i:=1to defopts do
       if (defopt[i].mask in defoptions) then
        begin
          if first then
            first:=false
          else
            write(', ');
          write(defopt[i].str);
        end;
    end;
  writeln;

  if df_unique in defoptions then
    writeln  (space,'      Unique type symbol');

  if df_has_rttitable in defoptions then
    begin
      write  (space,'      RTTI symbol : ');
      readderef;
    end;
  if df_has_inittable in defoptions then
    begin
      write  (space,'      Init symbol : ');
      readderef;
    end;
  if df_generic in defoptions then
    begin
      tokenbufsize:=ppufile.getlongint;
      writeln(space,' Tokenbuffer size : ',tokenbufsize);
      tokenbuf:=allocmem(tokenbufsize);
      ppufile.getdata(tokenbuf^,tokenbufsize);
      i:=0;
      write(space,' Tokens: ');
      while i<tokenbufsize do
        begin
          write(arraytokeninfo[ttoken(tokenbuf[i])].str);
          case ttoken(tokenbuf[i]) of
            _CWCHAR,
            _CWSTRING :
              begin
                inc(i);
              {
                replaytokenbuf.read(wlen,sizeof(SizeInt));
                setlengthwidestring(patternw,wlen);
                replaytokenbuf.read(patternw^.data^,patternw^.len*sizeof(tcompilerwidechar));
                pattern:='';
              }
              end;
            _CCHAR,
            _CSTRING,
            _INTCONST,
            _REALNUMBER :
              begin
                inc(i);
              {
                replaytokenbuf.read(pattern[0],1);
                replaytokenbuf.read(pattern[1],length(pattern));
                orgpattern:='';
              }
              end;
            _ID :
              begin
                inc(i);
              {
                replaytokenbuf.read(orgpattern[0],1);
                replaytokenbuf.read(orgpattern[1],length(orgpattern));
                pattern:=upper(orgpattern);
              }
              end;
            _GENERICSPECIALTOKEN:
              begin
                inc(i);
                inc(i);
                inc(i,sizeof(tsettings));

              {
                replaytokenbuf.read(specialtoken,1);
                case specialtoken of
                  ST_LOADSETTINGS:
                    begin
                      replaytokenbuf.read(current_settings,sizeof(current_settings));
                    end
                  else
                    internalerror(2006103010);
                end;
                continue;
              }
              end;
            else
              inc(i);
          end;

          if i<tokenbufsize then
            write(',');
        end;
      writeln;
      freemem(tokenbuf);
    end;
  if df_specialization in defoptions then
    begin
      write  (space,' Orig. GenericDef : ');
      readderef;
    end;
end;


{ Read abstract procdef and return if inline procdef }
type
  tproccalloption=(pocall_none,
    { procedure uses C styled calling }
    pocall_cdecl,
    { C++ calling conventions }
    pocall_cppdecl,
    { Far16 for OS/2 }
    pocall_far16,
    { Old style FPC default calling }
    pocall_oldfpccall,
    { Procedure has compiler magic}
    pocall_internproc,
    { procedure is a system call, applies e.g. to MorphOS and PalmOS }
    pocall_syscall,
    { pascal standard left to right }
    pocall_pascal,
    { procedure uses register (fastcall) calling }
    pocall_register,
    { safe call calling conventions }
    pocall_safecall,
    { procedure uses stdcall call }
    pocall_stdcall,
    { Special calling convention for cpus without a floating point
      unit. Floating point numbers are passed in integer registers
      instead of floating point registers. Depending on the other
      available calling conventions available for the cpu
      this replaces either pocall_fastcall or pocall_stdcall.
    }
    pocall_softfloat,
    { Metrowerks Pascal. Special case on Mac OS (X): passes all }
    { constant records by reference.                            }
    pocall_mwpascal
  );
  tproccalloptions=set of tproccalloption;
  tproctypeoption=(potype_none,
    potype_proginit,     { Program initialization }
    potype_unitinit,     { unit initialization }
    potype_unitfinalize, { unit finalization }
    potype_constructor,  { Procedure is a constructor }
    potype_destructor,   { Procedure is a destructor }
    potype_operator,     { Procedure defines an operator }
    potype_procedure,
    potype_function
  );
  tproctypeoptions=set of tproctypeoption;
  tprocoption=(po_none,
    po_classmethod,       { class method }
    po_virtualmethod,     { Procedure is a virtual method }
    po_abstractmethod,    { Procedure is an abstract method }
    po_staticmethod,      { static method }
    po_overridingmethod,  { method with override directive }
    po_methodpointer,     { method pointer, only in procvardef, also used for 'with object do' }
    po_interrupt,         { Procedure is an interrupt handler }
    po_iocheck,           { IO checking should be done after a call to the procedure }
    po_assembler,         { Procedure is written in assembler }
    po_msgstr,            { method for string message handling }
    po_msgint,            { method for int message handling }
    po_exports,           { Procedure has export directive (needed for OS/2) }
    po_external,          { Procedure is external (in other object or lib)}
    po_overload,          { procedure is declared with overload directive }
    po_varargs,           { printf like arguments }
    po_internconst,       { procedure has constant evaluator intern }
    { flag that only the address of a method is returned and not a full methodpointer }
    po_addressonly,
    { procedure is exported }
    po_public,
    { calling convention is specified explicitly }
    po_hascallingconvention,
    { reintroduce flag }
    po_reintroduce,
    { location of parameters is given explicitly as it is necessary for some syscall
      conventions like that one of MorphOS }
    po_explicitparaloc,
    { no stackframe will be generated, used by lowlevel assembler like get_frame }
    po_nostackframe,
    po_has_mangledname,
    po_has_public_name,
    po_forward,
    po_global,
    po_has_inlininginfo,
    { The different kind of syscalls on MorphOS }
    po_syscall_legacy,
    po_syscall_sysv,
    po_syscall_basesysv,
    po_syscall_sysvbase,
    po_syscall_r12base,
    po_local,
    { Procedure can be inlined }
    po_inline,
    { Procedure is used for internal compiler calls }
    po_compilerproc,
    { importing }
    po_has_importdll,
    po_has_importname
  );
  tprocoptions=set of tprocoption;
procedure read_abstract_proc_def(var proccalloption:tproccalloption;var procoptions:tprocoptions);
type
  tproccallopt=record
    mask : tproccalloption;
    str  : string[30];
  end;
  tproctypeopt=record
    mask : tproctypeoption;
    str  : string[30];
  end;
  tprocopt=record
    mask : tprocoption;
    str  : string[30];
  end;
const
  proccalloptionStr : array[tproccalloption] of string[14]=('',
     'CDecl',
     'CPPDecl',
     'Far16',
     'OldFPCCall',
     'InternProc',
     'SysCall',
     'Pascal',
     'Register',
     'SafeCall',
     'StdCall',
     'SoftFloat',
     'MWPascal'
   );
  proctypeopts=8;
  proctypeopt : array[1..proctypeopts] of tproctypeopt=(
     (mask:potype_proginit;    str:'ProgInit'),
     (mask:potype_unitinit;    str:'UnitInit'),
     (mask:potype_unitfinalize;str:'UnitFinalize'),
     (mask:potype_constructor; str:'Constructor'),
     (mask:potype_destructor;  str:'Destructor'),
     (mask:potype_operator;    str:'Operator'),
     (mask:potype_function;    str:'Function'),
     (mask:potype_procedure;   str:'Procedure')
  );
  procopts=37;
  procopt : array[1..procopts] of tprocopt=(
     (mask:po_classmethod;     str:'ClassMethod'),
     (mask:po_virtualmethod;   str:'VirtualMethod'),
     (mask:po_abstractmethod;  str:'AbstractMethod'),
     (mask:po_staticmethod;    str:'StaticMethod'),
     (mask:po_overridingmethod;str:'OverridingMethod'),
     (mask:po_methodpointer;   str:'MethodPointer'),
     (mask:po_interrupt;       str:'Interrupt'),
     (mask:po_iocheck;         str:'IOCheck'),
     (mask:po_assembler;       str:'Assembler'),
     (mask:po_msgstr;          str:'MsgStr'),
     (mask:po_msgint;          str:'MsgInt'),
     (mask:po_exports;         str:'Exports'),
     (mask:po_external;        str:'External'),
     (mask:po_overload;        str:'Overload'),
     (mask:po_varargs;         str:'VarArgs'),
     (mask:po_internconst;     str:'InternConst'),
     (mask:po_addressonly;     str:'AddressOnly'),
     (mask:po_public;          str:'Public'),
     (mask:po_hascallingconvention;str:'HasCallingConvention'),
     (mask:po_reintroduce;     str:'ReIntroduce'),
     (mask:po_explicitparaloc; str:'ExplicitParaloc'),
     (mask:po_nostackframe;    str:'NoStackFrame'),
     (mask:po_has_mangledname; str:'HasMangledName'),
     (mask:po_has_public_name; str:'HasPublicName'),
     (mask:po_forward;         str:'Forward'),
     (mask:po_global;          str:'Global'),
     (mask:po_has_inlininginfo;str:'HasInliningInfo'),
     (mask:po_syscall_legacy;  str:'SyscallLegacy'),
     (mask:po_syscall_sysv;    str:'SyscallSysV'),
     (mask:po_syscall_basesysv;str:'SyscallBaseSysV'),
     (mask:po_syscall_sysvbase;str:'SyscallSysVBase'),
     (mask:po_syscall_r12base; str:'SyscallR12Base'),
     (mask:po_local;           str:'Local'),
     (mask:po_inline;          str:'Inline'),
     (mask:po_compilerproc;    str:'CompilerProc'),
     (mask:po_has_importdll;   str:'HasImportDLL'),
     (mask:po_has_importname;  str:'HasImportName')
  );
var
  proctypeoption  : tproctypeoption;
  i     : longint;
  first : boolean;
  tempbuf : array[0..255] of byte;
begin
  write(space,'      Return type : ');
  readtype;
  writeln(space,'         Fpu used : ',ppufile.getbyte);
  proctypeoption:=tproctypeoption(ppufile.getbyte);
  write(space,'       TypeOption : ');
  first:=true;
  for i:=1 to proctypeopts do
   if (proctypeopt[i].mask=proctypeoption) then
    begin
      if first then
        first:=false
      else
        write(', ');
      write(proctypeopt[i].str);
    end;
  writeln;
  proccalloption:=tproccalloption(ppufile.getbyte);
  writeln(space,'       CallOption : ',proccalloptionStr[proccalloption]);
  ppufile.getnormalset(procoptions);
  if procoptions<>[] then
   begin
     write(space,'          Options : ');
     first:=true;
     for i:=1to procopts do
      if (procopt[i].mask in procoptions) then
       begin
         if first then
           first:=false
         else
           write(', ');
         write(procopt[i].str);
       end;
     writeln;
   end;
  if (po_explicitparaloc in procoptions) then
    begin
      i:=ppufile.getbyte;
      ppufile.getdata(tempbuf,i);
    end;
end;


type
  { options for variables }
  tvaroption=(vo_none,
    vo_is_C_var,
    vo_is_external,
    vo_is_dll_var,
    vo_is_thread_var,
    vo_has_local_copy,
    vo_is_const,  { variable is declared as const (parameter) and can't be written to }
    vo_is_exported,
    vo_is_high_para,
    vo_is_funcret,
    vo_is_self,
    vo_is_vmt,
    vo_is_result,  { special result variable }
    vo_is_parentfp,
    vo_is_loop_counter, { used to detect assignments to loop counter }
    vo_is_hidden_para,
    vo_has_explicit_paraloc,
    vo_is_syscall_lib,
    vo_has_mangledname
  );
  tvaroptions=set of tvaroption;
  { register variable }
  tvarregable=(vr_none,
    vr_intreg,
    vr_fpureg,
    vr_mmreg
  );
procedure readabstractvarsym(const s:string;var varoptions:tvaroptions);
type
  tvaropt=record
    mask : tvaroption;
    str  : string[30];
  end;
const
  varopts=18;
  varopt : array[1..varopts] of tvaropt=(
     (mask:vo_is_C_var;        str:'CVar'),
     (mask:vo_is_external;     str:'External'),
     (mask:vo_is_dll_var;      str:'DLLVar'),
     (mask:vo_is_thread_var;   str:'ThreadVar'),
     (mask:vo_has_local_copy;  str:'HasLocalCopy'),
     (mask:vo_is_const;        str:'Constant'),
     (mask:vo_is_exported;     str:'Exported'),
     (mask:vo_is_high_para;    str:'HighValue'),
     (mask:vo_is_funcret;      str:'Funcret'),
     (mask:vo_is_self;         str:'Self'),
     (mask:vo_is_vmt;          str:'VMT'),
     (mask:vo_is_result;       str:'Result'),
     (mask:vo_is_parentfp;     str:'ParentFP'),
     (mask:vo_is_loop_counter; str:'LoopCounter'),
     (mask:vo_is_hidden_para;  str:'Hidden'),
     (mask:vo_has_explicit_paraloc;str:'ExplicitParaloc'),
     (mask:vo_is_syscall_lib;  str:'SysCallLib'),
     (mask:vo_has_mangledname; str:'HasMangledName')
  );
var
  i : longint;
  first : boolean;
begin
  readcommonsym(s);
  writeln(space,'         Spez : ',Varspez2Str(ppufile.getbyte));
  writeln(space,'      Regable : ',Varregable2Str(ppufile.getbyte));
  write  (space,'     Var Type : ');
  readtype;
  ppufile.getsmallset(varoptions);
  if varoptions<>[] then
   begin
     write(space,'      Options : ');
     first:=true;
     for i:=1to varopts do
      if (varopt[i].mask in varoptions) then
       begin
         if first then
           first:=false
         else
           write(', ');
         write(varopt[i].str);
       end;
     writeln;
   end;
end;


procedure readobjectdefoptions;
type
  tobjectoption=(oo_none,
    oo_is_forward,         { the class is only a forward declared yet }
    oo_has_virtual,        { the object/class has virtual methods }
    oo_has_private,
    oo_has_protected,
    oo_has_strictprivate,
    oo_has_strictprotected,
    oo_has_constructor,    { the object/class has a constructor }
    oo_has_destructor,     { the object/class has a destructor }
    oo_has_vmt,            { the object/class has a vmt }
    oo_has_msgstr,
    oo_has_msgint,
    oo_can_have_published,{ the class has rtti, i.e. you can publish properties }
    oo_has_default_property
  );
  tobjectoptions=set of tobjectoption;
  tsymopt=record
    mask : tobjectoption;
    str  : string[30];
  end;
const
  symopts=13;
  symopt : array[1..symopts] of tsymopt=(
     (mask:oo_has_virtual;        str:'IsForward'),
     (mask:oo_has_virtual;        str:'HasVirtual'),
     (mask:oo_has_private;        str:'HasPrivate'),
     (mask:oo_has_protected;      str:'HasProtected'),
     (mask:oo_has_strictprivate;  str:'HasStrictPrivate'),
     (mask:oo_has_strictprotected;str:'HasStrictProtected'),
     (mask:oo_has_constructor;    str:'HasConstructor'),
     (mask:oo_has_destructor;     str:'HasDestructor'),
     (mask:oo_has_vmt;            str:'HasVMT'),
     (mask:oo_has_msgstr;         str:'HasMsgStr'),
     (mask:oo_has_msgint;         str:'HasMsgInt'),
     (mask:oo_can_have_published; str:'CanHavePublished'),
     (mask:oo_has_default_property;str:'HasDefaultProperty')
  );
var
  symoptions : tobjectoptions;
  i      : longint;
  first  : boolean;
begin
  ppufile.getsmallset(symoptions);
  if symoptions<>[] then
   begin
     first:=true;
     for i:=1to symopts do
      if (symopt[i].mask in symoptions) then
       begin
         if first then
           first:=false
         else
           write(', ');
         write(symopt[i].str);
       end;
   end;
  writeln;
end;


procedure readarraydefoptions;
type
  tarraydefoption=(ado_none,
    ado_IsConvertedPointer,
    ado_IsDynamicArray,
    ado_IsVariant,
    ado_IsConstructor,
    ado_IsArrayOfConst,
    ado_IsConstString
  );
  tarraydefoptions=set of tarraydefoption;
  tsymopt=record
    mask : tarraydefoption;
    str  : string[30];
  end;
const
  symopts=6;
  symopt : array[1..symopts] of tsymopt=(
     (mask:ado_IsConvertedPointer;str:'ConvertedPointer'),
     (mask:ado_IsDynamicArray;    str:'IsDynamicArray'),
     (mask:ado_IsVariant;         str:'IsVariant'),
     (mask:ado_IsConstructor;     str:'IsConstructor'),
     (mask:ado_IsArrayOfConst;    str:'ArrayOfConst'),
     (mask:ado_IsConstString;     str:'ConstString')
  );
var
  symoptions : tarraydefoptions;
  i      : longint;
  first  : boolean;
begin
  ppufile.getsmallset(symoptions);
  if symoptions<>[] then
   begin
     first:=true;
     for i:=1to symopts do
      if (symopt[i].mask in symoptions) then
       begin
         if first then
           first:=false
         else
           write(', ');
         write(symopt[i].str);
       end;
   end;
  writeln;
end;


procedure readnodetree;
var
  l : longint;
  p : pointer;
begin
  with ppufile do
   begin
     if space<>'' then
      Writeln(space,'------ nodetree ------');
     if readentry=ibnodetree then
      begin
        l:=entrysize;
        Writeln(space,'Tree size : ',l);
        { Read data to prevent error that entry is not completly read }
        getmem(p,l);
        getdata(p^,l);
        freemem(p);
      end
     else
      begin
        Writeln('!! ibnodetree not found');
      end;
   end;
end;


{****************************************************************************
                             Read Symbols Part
****************************************************************************}

procedure readsymbols(const s:string);
type
  pguid = ^tguid;
  tguid = packed record
    D1: LongWord;
    D2: Word;
    D3: Word;
    D4: array[0..7] of Byte;
  end;

  absolutetyp = (tovar,toasm,toaddr);
  tconsttyp = (constnone,
    constord,conststring,constreal,
    constset,constpointer,constnil,
    constresourcestring,constwstring,constguid
  );
var
  b      : byte;
  pc     : pchar;
  totalsyms,
  symcnt,
  i,j,len : longint;
  guid : tguid;
  tempbuf : array[0..127] of char;
  varoptions : tvaroptions;
begin
  symcnt:=1;
  with ppufile do
   begin
     if space<>'' then
      Writeln(space,'------ ',s,' ------');
     if readentry=ibstartsyms then
      begin
        totalsyms:=getlongint;
        Writeln(space,'Number of symbols : ',totalsyms);
        Writeln(space,'Symtable datasize : ',getlongint);
        Writeln(space,'Symtable alignment: ',getlongint);
      end
     else
      begin
        totalsyms:=-1;
        Writeln('!! ibstartsym not found');
      end;
     repeat
       b:=readentry;
       if not (b in [iberror,ibendsyms]) then
        inc(symcnt);
       case b of

         ibunitsym :
           readcommonsym('Unit symbol ');

         iblabelsym :
           readcommonsym('Label symbol ');

         ibtypesym :
           begin
             readcommonsym('Type symbol ');
             write(space,'  Result Type : ');
             readtype;
           end;

         ibprocsym :
           begin
             readcommonsym('Procedure symbol ');
             len:=ppufile.getword;
             for i:=1 to len do
              begin
                write(space,'   Definition : ');
                readderef;
              end;
           end;

         ibconstsym :
           begin
             readcommonsym('Constant symbol ');
             b:=getbyte;
             case tconsttyp(b) of
               constord :
                 begin
                   write  (space,'  OrdinalType : ');
                   readtype;
                   writeln(space,'        Value : ',getint64);
                 end;
               constpointer :
                 begin
                   write  (space,'  PointerType : ');
                   readtype;
                   writeln(space,'        Value : ',getlongint)
                 end;
               conststring,
               constresourcestring :
                 begin
                   len:=getlongint;
                   getmem(pc,len+1);
                   getdata(pc^,len);
                   (pc+len)^:= #0;
                   writeln(space,'       Length : ',len);
                   writeln(space,'        Value : "',pc,'"');
                   freemem(pc,len+1);
                   if tconsttyp(b)=constresourcestring then
                    writeln(space,'        Index : ',getlongint);
                 end;
               constreal :
                 writeln(space,'        Value : ',getreal);
               constset :
                 begin
                   write (space,'      Set Type : ');
                   readtype;
                   for i:=1to 4 do
                    begin
                      write (space,'        Value : ');
                      for j:=1to 8 do
                       begin
                         if j>1 then
                          write(',');
                         write(hexb(getbyte));
                       end;
                      writeln;
                    end;
                 end;
               constwstring:
                 begin
                 end;
               constguid:
                 begin
                    getdata(guid,sizeof(guid));
                    write (space,'     IID String: {',hexstr(guid.d1,8),'-',hexstr(guid.d2,4),'-',hexstr(guid.d3,4),'-');
                    for i:=0 to 7 do
                      begin
                         write(hexstr(guid.d4[i],2));
                         if i=1 then write('-');
                      end;
                    writeln('}');
                 end
               else
                 Writeln ('!! Invalid unit format : Invalid const type encountered: ',b);
             end;
           end;

         ibabsolutevarsym :
           begin
             readabstractvarsym('Absolute variable symbol ',varoptions);
             Write (space,' Relocated to ');
             b:=getbyte;
             case absolutetyp(b) of
               tovar :
                 readsymlist(space+'          Sym : ');
               toasm :
                 Writeln('Assembler name : ',getstring);
               toaddr :
                 begin
                   Write('Address : ',getlongint);
                   if tsystemcpu(ppufile.header.cpu)=cpu_i386 then
                     WriteLn(' (Far: ',getbyte<>0,')');
                 end;
               else
                 Writeln ('!! Invalid unit format : Invalid absolute type encountered: ',b);
             end;
           end;

         ibfieldvarsym :
           begin
             readabstractvarsym('Field Variable symbol ',varoptions);
             writeln(space,'      Address : ',getaint);
           end;

         ibglobalvarsym :
           begin
             readabstractvarsym('Global Variable symbol ',varoptions);
             write  (space,' DefaultConst : ');
             readderef;
             if (vo_has_mangledname in varoptions) then
               writeln(space,' Mangledname : ',getstring);
           end;

         iblocalvarsym :
           begin
             readabstractvarsym('Local Variable symbol ',varoptions);
             write  (space,' DefaultConst : ');
             readderef;
           end;

         ibparavarsym :
           begin
             readabstractvarsym('Parameter Variable symbol ',varoptions);
             write  (space,' DefaultConst : ');
             readderef;
             writeln(space,'       ParaNr : ',getword);
             writeln(space,'     VarState : ',getbyte);
             if (vo_has_explicit_paraloc in varoptions) then
               begin
                 i:=getbyte;
                 getdata(tempbuf,i);
               end;
           end;

         ibenumsym :
           begin
             readcommonsym('Enumeration symbol ');
             write  (space,'   Definition : ');
             readderef;
             writeln(space,'        Value : ',getlongint);
           end;

         ibsyssym :
           begin
             readcommonsym('Internal system symbol ');
             writeln(space,'  Internal Nr : ',getlongint);
           end;

         ibrttisym :
           begin
             readcommonsym('RTTI symbol ');
             writeln(space,'    RTTI Type : ',getbyte);
           end;

         ibmacrosym :
           begin
             readcommonsym('Macro symbol ');
             writeln(space,'          Name: ',getstring);
             writeln(space,'       Defined: ',getbyte);
             writeln(space,'  Compiler var: ',getbyte);
             len:=getlongint;
             writeln(space,'  Value length: ',len);
             if len > 0 then
               begin
                 getmem(pc,len+1);
                 getdata(pc^,len);
                 (pc+len)^:= #0;
                 writeln(space,'         Value: "',pc,'"');
                 freemem(pc,len+1);
               end;
           end;

         ibtypedconstsym :
           begin
             readcommonsym('Typed constant ');
             write  (space,'  Constant Type : ');
             readtype;
             writeln(space,'    ReallyConst : ',(getbyte<>0));
           end;

         ibpropertysym :
           begin
             readcommonsym('Property ');
             i:=getlongint;
             writeln(space,'  PropOptions : ',i);
             write  (space,' OverrideProp : ');
             readderef;
             write  (space,'    Prop Type : ');
             readtype;
             writeln(space,'        Index : ',getlongint);
             writeln(space,'      Default : ',getlongint);
             write  (space,'   Index Type : ');
             readtype;
             write  (space,'   Readaccess : ');
             readsymlist(space+'         Sym: ');
             write  (space,'  Writeaccess : ');
             readsymlist(space+'         Sym: ');
             write  (space,' Storedaccess : ');
             readsymlist(space+'         Sym: ');
           end;

         iberror :
           begin
             Writeln('!! Error in PPU');
             exit;
           end;

         ibendsyms :
           break;

         else
           WriteLn('!! Skipping unsupported PPU Entry in Symbols: ',b);
       end;
       if not EndOfEntry then
        Writeln('!! Entry has more information stored');
     until false;
     if (totalsyms<>-1) and (symcnt-1<>totalsyms) then
       Writeln('!! Only read ',symcnt-1,' of ',totalsyms,' symbols');
   end;
end;


{****************************************************************************
                         Read defintions Part
****************************************************************************}

procedure readdefinitions(const s:string;start_read : boolean);
type
  tsettype  = (normset,smallset,varset);
  tbasetype = (
    uvoid,
    u8bit,u16bit,u32bit,u64bit,
    s8bit,s16bit,s32bit,s64bit,
    bool8bit,bool16bit,bool32bit,
    uchar,uwidechar,scurrency
  );
  tobjectdeftype = (odt_none,
    odt_class,
    odt_object,
    odt_interfacecom,
    odt_interfacecorba,
    odt_cppclass,
    odt_dispinterface
  );
  tvarianttype = (
    vt_normalvariant,vt_olevariant
  );
var
  b : byte;
  totaldefs,l,j,
  defcnt : longint;
  calloption : tproccalloption;
  procoptions : tprocoptions;
  procinfooptions : tprocinfoflag;

begin
  defcnt:=0;
  with ppufile do
   begin
     if space<>'' then
      Writeln(space,'------ ',s,' ------');
     if not start_read then
       if readentry=ibstartdefs then
         begin
           totaldefs:=getlongint;
           Writeln(space,'Number of definitions: ',totaldefs);
         end
       else
         begin
           totaldefs:=-1;
           Writeln('!! ibstartdef not found');
         end;
     repeat
       b:=readentry;
       if not (b in [iberror,ibenddefs]) then
        inc(defcnt);
       case b of

         ibpointerdef :
           begin
             readcommondef('Pointer definition');
             write  (space,'     Pointed Type : ');
             readtype;
             writeln(space,'           Is Far : ',(getbyte<>0));
           end;

         iborddef :
           begin
             readcommondef('Ordinal definition');
             write  (space,'        Base type : ');
             b:=getbyte;
             case tbasetype(b) of
               uvoid     : writeln('uvoid');
               u8bit     : writeln('u8bit');
               u16bit    : writeln('u16bit');
               u32bit    : writeln('s32bit');
               u64bit    : writeln('u64bit');
               s8bit     : writeln('s8bit');
               s16bit    : writeln('s16bit');
               s32bit    : writeln('s32bit');
               s64bit    : writeln('s64bit');
               bool8bit  : writeln('bool8bit');
               bool16bit : writeln('bool16bit');
               bool32bit : writeln('bool32bit');
               uchar     : writeln('uchar');
               uwidechar : writeln('uwidechar');
               scurrency : writeln('ucurrency');
               else        writeln('!! Warning: Invalid base type ',b);
             end;
             writeln(space,'            Range : ',getint64,' to ',getint64);
           end;

         ibfloatdef :
           begin
             readcommondef('Float definition');
             writeln(space,'       Float type : ',getbyte);
           end;

         ibarraydef :
           begin
             readcommondef('Array definition');
             write  (space,'     Element type : ');
             readtype;
             write  (space,'       Range Type : ');
             readtype;
             writeln(space,'            Range : ',getaint,' to ',getaint);
             write  (space,'          Options : ');
             readarraydefoptions;
           end;

         ibprocdef :
           begin
             readcommondef('Procedure definition');
             read_abstract_proc_def(calloption,procoptions);
             if (po_has_mangledname in procoptions) then
               writeln(space,'     Mangled name : ',getstring);
             writeln(space,'           Number : ',getword);
             writeln(space,'            Level : ',getbyte);
             write  (space,'            Class : ');
             readderef;
             write  (space,'          Procsym : ');
             readderef;
             write  (space,'         File Pos : ');
             readposinfo;
             write  (space,'       SymOptions : ');
             readsymoptions;
             if tsystemcpu(ppufile.header.cpu)=cpu_powerpc then
               begin
                 { library symbol for AmigaOS/MorphOS }
                 write  (space,'   Library symbol : ');
                 readderef;
               end;
             if (po_has_importdll in procoptions) then
               writeln(space,'       Import DLL : ',getstring);
             if (po_has_importname in procoptions) then
               writeln(space,'      Import Name : ',getstring);
             writeln(space,'      Import Nr : ',getword);
             if (po_inline in procoptions) then
              begin
                write  (space,'       FuncretSym : ');
                readderef;
                ppufile.getsmallset(procinfooptions);
                writeln(space,'  ProcInfoOptions : ',dword(procinfooptions));
                b := ppufile.getbyte;
                writeln(space,' Inline node tree : ',b);
              end;
             if not EndOfEntry then
              Writeln('!! Entry has more information stored');
             space:='    '+space;
             { parast }
             readdefinitions('parast',false);
             readsymbols('parast');
             { localst }
             if (po_has_inlininginfo in procoptions) or
               ((ppufile.header.flags and uf_local_browser)<>0) then
              begin
                readdefinitions('localst',false);
                readsymbols('localst');
              end;
             if (po_has_inlininginfo in procoptions) then
               readnodetree;
             delete(space,1,4);
           end;

         ibprocvardef :
           begin
             readcommondef('Procedural type (ProcVar) definition');
             read_abstract_proc_def(calloption,procoptions);
             if not EndOfEntry then
              Writeln('!! Entry has more information stored');
             space:='    '+space;
             { parast }
             readdefinitions('parast',false);
             readsymbols('parast');
             delete(space,1,4);
           end;

         ibshortstringdef :
           begin
             readcommondef('ShortString definition');
             writeln(space,'           Length : ',getbyte);
           end;

         ibwidestringdef :
           begin
             readcommondef('WideString definition');
             writeln(space,'           Length : ',getlongint);
           end;

         ibansistringdef :
           begin
             readcommondef('AnsiString definition');
             writeln(space,'           Length : ',getlongint);
           end;

         iblongstringdef :
           begin
             readcommondef('Longstring definition');
             writeln(space,'           Length : ',getlongint);
           end;

         ibrecorddef :
           begin
             readcommondef('Record definition');
             writeln(space,'         DataSize : ',getaint);
             writeln(space,'       FieldAlign : ',getbyte);
             writeln(space,'      RecordAlign : ',getbyte);
             writeln(space,'         PadAlign : ',getbyte);
             writeln(space,'UseFieldAlignment : ',getbyte);
             if not EndOfEntry then
              Writeln('!! Entry has more information stored');
             {read the record definitions and symbols}
             space:='    '+space;
             readdefinitions('fields',false);
             readsymbols('fields');
             Delete(space,1,4);
           end;

         ibobjectdef :
           begin
             readcommondef('Object/Class definition');
             b:=getbyte;
             write  (space,'             Type : ');
             case tobjectdeftype(b) of
               odt_class          : writeln('class');
               odt_object         : writeln('object');
               odt_interfacecom   : writeln('interfacecom');
               odt_interfacecorba : writeln('interfacecorba');
               odt_cppclass       : writeln('cppclass');
               else                 writeln('!! Warning: Invalid object type ',b);
             end;
             writeln(space,'    Name of Class : ',getstring);
             writeln(space,'         DataSize : ',getaint);
             writeln(space,'       FieldAlign : ',getbyte);
             writeln(space,'      RecordAlign : ',getbyte);
             writeln(space,'       Vmt offset : ',getlongint);
             write  (space,  '   Ancestor Class : ');
             readderef;
             write  (space,'          Options : ');
             readobjectdefoptions;

             if tobjectdeftype(b) in [odt_interfacecom,odt_interfacecorba,odt_dispinterface] then
               begin
                  { IIDGUID }
                  for j:=1to 16 do
                   getbyte;
                  writeln(space,'       IID String : ',getstring);
                  writeln(space,'  Last VTable idx : ',getlongint);
               end;

             if tobjectdeftype(b) in [odt_class,odt_interfacecorba] then
              begin
                l:=getlongint;
                writeln(space,'  Impl Intf Count : ',l);
                for j:=1 to l do
                 begin
                   write  (space,'  - Definition : ');
                   readderef;
                   writeln(space,'       IOffset : ',getlongint);
                 end;
              end;

             if not EndOfEntry then
              Writeln('!! Entry has more information stored');
             {read the record definitions and symbols}
             space:='    '+space;
             readdefinitions('fields',false);
             readsymbols('fields');
             Delete(space,1,4);
           end;

         ibfiledef :
           begin
             ReadCommonDef('File definition');
             write  (space,'             Type : ');
             case getbyte of
              0 : writeln('Text');
              1 : begin
                    writeln('Typed');
                    write  (space,'      File of Type : ');
                    Readtype;
                  end;
              2 : writeln('Untyped');
             end;
           end;

         ibformaldef :
           readcommondef('Generic definition (void-typ)');

         ibundefineddef :
           readcommondef('Undefined definition (generic parameter)');

         ibenumdef :
           begin
             readcommondef('Enumeration type definition');
             write(space,'Base enumeration type : ');
             readderef;
             writeln(space,' Smallest element : ',getaint);
             writeln(space,'  Largest element : ',getaint);
             writeln(space,'             Size : ',getaint);
           end;

         ibclassrefdef :
           begin
             readcommondef('Class reference definition');
             write  (space,'    Pointed Type : ');
             readtype;
           end;

         ibsetdef :
           begin
             readcommondef('Set definition');
             write  (space,'     Element type : ');
             readtype;
             b:=getbyte;
             case tsettype(b) of
               smallset : writeln(space,'  Set with 32 Elements');
               normset  : writeln(space,'  Set with 256 Elements');
               varset   : writeln(space,'  Set with ',getlongint,' Elements');
               else       writeln('!! Warning: Invalid set type ',b);
             end;
           end;

         ibvariantdef :
           begin
             readcommondef('Variant definition');
             write  (space,'      Varianttype : ');
             b:=getbyte;
             case tvarianttype(b) of
               vt_normalvariant :
                 writeln('Normal');
               vt_olevariant :
                 writeln('OLE');
               else
                 writeln('!! Warning: Invalid varianttype ',b);
             end;

           end;

         iberror :
           begin
             Writeln('!! Error in PPU');
             exit;
           end;

         ibenddefs :
           break;

         else
           WriteLn('!! Skipping unsupported PPU Entry in definitions: ',b);
       end;
       if not EndOfEntry then
        Writeln('!! Entry has more information stored');
     until false;
     if (totaldefs<>-1) and (defcnt<>totaldefs) then
      Writeln('!! Only read ',defcnt,' of ',totaldefs,' definitions');
   end;
end;


{****************************************************************************
                           Read General Part
****************************************************************************}

procedure readinterface;
var
  b : byte;
  sourcenumber : longint;
begin
  with ppufile do
   begin
     repeat
       b:=readentry;
       case b of

         ibmodulename :
           Writeln('Module Name: ',getstring);

         ibsourcefiles :
           begin
             sourcenumber:=1;
             while not EndOfEntry do
              begin
                Writeln('Source file ',sourcenumber,' : ',getstring,' ',filetimestring(getlongint));
                inc(sourcenumber);
              end;
           end;
{$IFDEF MACRO_DIFF_HINT}
         ibusedmacros :
           begin
             while not EndOfEntry do
              begin
                Write('Conditional ',getstring);
                b:=getbyte;
                if boolean(b)=true then
                  write(' defined at startup')
                else
                  write(' not defined at startup');
                b:=getbyte;
                if boolean(b)=true then
                  writeln(' was used')
                else
                  writeln;
              end;
           end;
{$ENDIF}
         ibloadunit :
           ReadLoadUnit;

         iblinkunitofiles :
           ReadLinkContainer('Link unit object file: ');

         iblinkunitstaticlibs :
           ReadLinkContainer('Link unit static lib: ');

         iblinkunitsharedlibs :
           ReadLinkContainer('Link unit shared lib: ');

         iblinkotherofiles :
           ReadLinkContainer('Link other object file: ');

         iblinkotherstaticlibs :
           ReadLinkContainer('Link other static lib: ');

         iblinkothersharedlibs :
           ReadLinkContainer('Link other shared lib: ');

         ibImportSymbols :
           ReadImportSymbols;

         ibderefdata :
           ReadDerefData;

         ibderefmap :
           ReadDerefMap;

         iberror :
           begin
             Writeln('Error in PPU');
             exit;
           end;

         ibendinterface :
           break;

         else
           WriteLn('!! Skipping unsupported PPU Entry in General Part: ',b);
       end;
     until false;
   end;
end;



{****************************************************************************
                        Read Implementation Part
****************************************************************************}

procedure readimplementation;
var
  b : byte;
begin
  with ppufile do
   begin
     repeat
       b:=readentry;
       case b of
         ibasmsymbols :
           ReadAsmSymbols;

         ibloadunit :
           ReadLoadUnit;

         iberror :
           begin
             Writeln('Error in PPU');
             exit;
           end;
         ibendimplementation :
           break;
         else
           WriteLn('!! Skipping unsupported PPU Entry in Implementation: ',b);
       end;
     until false;
   end;
end;


{****************************************************************************
                            Read Browser Part
****************************************************************************}

procedure readbrowser;
var
  b : byte;
const indent : string = '';
begin
  Writeln(indent,'Start of symtable browser');
  indent:=indent+'**';
  with ppufile do
   begin
     repeat
       b:=readentry;
       case b of
         ibbeginsymtablebrowser :
           begin
             { here we must read object and record symtables !! }
             indent:=indent+'  ';
             Writeln(indent,'Record/Object symtable');
             readbrowser;
             Indent:=Copy(Indent,1,Length(Indent)-2);
           end;
         ibsymref :
           begin
             readderef;
             readref;
           end;
         ibdefref :
           begin
             readderef;
             readref;
             if ((ppufile.header.flags and uf_local_browser)<>0) and
                (UnitIndex=0) then
              begin
                { parast and localst }
                indent:=indent+'  ';
                b:=ppufile.readentry;
                if b=ibbeginsymtablebrowser then
                 readbrowser;
                b:=ppufile.readentry;
                if b=ibbeginsymtablebrowser then
                 readbrowser;
                Indent:=Copy(Indent,1,Length(Indent)-2);
              end;
           end;
         iberror :
           begin
             Writeln('Error in PPU');
             exit;
           end;
         ibendsymtablebrowser :
           break;
         else
           begin
             WriteLn('!! Skipping unsupported PPU Entry in Browser: ',b);
             Halt;
           end;
       end;
     until false;
   end;
  Indent:=Copy(Indent,1,Length(Indent)-2);
  Writeln(Indent,'End of symtable browser');
end;




procedure dofile (filename : string);
var
  b : byte;
begin
{ reset }
  space:='';
{ fix filename }
  if pos('.',filename)=0 then
   filename:=filename+'.ppu';
  ppufile:=tppufile.create(filename);
  if not ppufile.openfile then
   begin
     writeln ('IO-Error when opening : ',filename,', Skipping');
     exit;
   end;
{ PPU File is open, check for PPU Id }
  if not ppufile.CheckPPUID then
   begin
     writeln(Filename,' : Not a valid PPU file, Skipping');
     exit;
   end;
{ Check PPU Version }
  Writeln('Analyzing ',filename,' (v',ppufile.GetPPUVersion,')');
  if ppufile.GetPPUVersion<16 then
   begin
     writeln(Filename,' : Old PPU Formats (<v16) are not supported, Skipping');
     exit;
   end;
{ Write PPU Header Information }
  if (verbose and v_header)<>0 then
   begin
     Writeln;
     Writeln('Header');
     Writeln('-------');
     with ppufile.header do
      begin
        Writeln('Compiler version        : ',ppufile.header.compiler shr 14,'.',
                                             (ppufile.header.compiler shr 7) and $7f,'.',
                                             ppufile.header.compiler and $7f);
        WriteLn('Target processor        : ',Cpu2Str(cpu));
        WriteLn('Target operating system : ',Target2Str(target));
        Writeln('Unit flags              : ',PPUFlags2Str(flags));
        Writeln('FileSize (w/o header)   : ',size);
        Writeln('Checksum                : ',hexstr(checksum,8));
        Writeln('Interface Checksum      : ',hexstr(interface_checksum,8));
        Writeln('Definitions stored      : ',tostr(deflistsize));
        Writeln('Symbols stored          : ',tostr(symlistsize));
      end;
   end;
{read the general stuff}
  if (verbose and v_interface)<>0 then
   begin
     Writeln;
     Writeln('Interface section');
     Writeln('------------------');
     readinterface;
   end
  else
   ppufile.skipuntilentry(ibendinterface);
{read the definitions}
  if (verbose and v_defs)<>0 then
   begin
     Writeln;
     Writeln('Interface definitions');
     Writeln('----------------------');
     readdefinitions('interface',false);
   end
  else
   ppufile.skipuntilentry(ibenddefs);
{read the symbols}
  if (verbose and v_syms)<>0 then
   begin
     Writeln;
     Writeln('Interface Symbols');
     Writeln('------------------');
     readsymbols('interface');
   end
  else
   ppufile.skipuntilentry(ibendsyms);

{read the macro symbols}
  if (verbose and v_syms)<>0 then
   begin
     Writeln;
     Writeln('Interface Macro Symbols');
     Writeln('-----------------------');
   end;
  if ppufile.readentry<>ibexportedmacros then
    begin
      Writeln('!! Error in PPU');
      exit;
    end;
  if boolean(ppufile.getbyte) then
    begin
      {skip the definition section for macros (since they are never used) }
      ppufile.skipuntilentry(ibenddefs);
      {read the macro symbols}
      if (verbose and v_syms)<>0 then
        readsymbols('interface macro')
      else
        ppufile.skipuntilentry(ibendsyms);
    end
  else
    Writeln('(no exported macros)');

{read the implementation stuff}
  if (verbose and v_implementation)<>0 then
   begin
     Writeln;
     Writeln('Implementation section');
     Writeln('-----------------------');
     readimplementation;
   end
  else
   ppufile.skipuntilentry(ibendimplementation);
{read the static browser units stuff}
  if (ppufile.header.flags and uf_local_symtable)<>0 then
   begin
     if (verbose and v_defs)<>0 then
      begin
        Writeln;
        Writeln('Static definitions');
        Writeln('----------------------');
        readdefinitions('implementation',false);
      end
     else
      ppufile.skipuntilentry(ibenddefs);
   {read the symbols}
     if (verbose and v_syms)<>0 then
      begin
        Writeln;
        Writeln('Static Symbols');
        Writeln('------------------');
        readsymbols('implementation');
      end
     else
      ppufile.skipuntilentry(ibendsyms);
   end;
{read the browser units stuff}
  if (ppufile.header.flags and uf_has_browser)<>0 then
   begin
     if (verbose and v_browser)<>0 then
      begin
        Writeln;
        Writeln('Browser section');
        Writeln('---------------');
        UnitIndex:=0;
        repeat
          b:=ppufile.readentry;
          if b = ibendbrowser then break;
          if b=ibbeginsymtablebrowser then
            begin
               Writeln('Unit ',UnitIndex);
               readbrowser;
               Inc(UnitIndex);
            end
          else
            Writeln('Wrong end browser entry ',b,' should be ',ibendbrowser);
        until false;
      end;
   end;
{read the static browser units stuff}
  if (ppufile.header.flags and uf_local_browser)<>0 then
   begin
     if (verbose and v_browser)<>0 then
      begin
        Writeln;
        Writeln('Static browser section');
        Writeln('---------------');
        UnitIndex:=0;
        b:=ppufile.readentry;
        if b=ibbeginsymtablebrowser then
          readbrowser
        else
          Writeln('Wrong end browser entry ',b,' should be ',ibendbrowser);
      end;
   end;
{shutdown ppufile}
  ppufile.closefile;
  ppufile.free;
  Writeln;
end;



procedure help;
begin
  writeln('usage: ppudump [options] <filename1> <filename2>...');
  writeln;
  writeln('[options] can be:');
  writeln('    -V<verbose>  Set verbosity to <verbose>');
  writeln('                   H - Show header info');
  writeln('                   I - Show interface');
  writeln('                   M - Show implementation');
  writeln('                   S - Show interface symbols');
  writeln('                   D - Show interface definitions');
  writeln('                   B - Show browser info');
  writeln('                   A - Show all');
  writeln('    -h, -?       This helpscreen');
  halt;
end;

var
  startpara,
  nrfile,i  : longint;
  para      : string;
begin
  writeln(Title+' '+Version);
  writeln(Copyright);
  writeln;
  if paramcount<1 then
   begin
     writeln('usage: dumpppu [options] <filename1> <filename2>...');
     halt(1);
   end;
{ turn verbose on by default }
  verbose:=v_all;
{ read options }
  startpara:=1;
  while copy(paramstr(startpara),1,1)='-' do
   begin
     para:=paramstr(startpara);
     case upcase(para[2]) of
      'V' : begin
              verbose:=0;
              for i:=3 to length(para) do
               case upcase(para[i]) of
                'H' : verbose:=verbose or v_header;
                'I' : verbose:=verbose or v_interface;
                'M' : verbose:=verbose or v_implementation;
                'D' : verbose:=verbose or v_defs;
                'S' : verbose:=verbose or v_syms;
                'B' : verbose:=verbose or v_browser;
                'A' : verbose:=verbose or v_all;
               end;
            end;
      'H' : help;
      '?' : help;
     end;
     inc(startpara);
   end;
{ process files }
  for nrfile:=startpara to paramcount do
   dofile (paramstr(nrfile));
  if has_errors then
    Halt(1);
end.
