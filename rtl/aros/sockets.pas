{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2007 by the Free Pascal development team

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$PACKRECORDS 2}
unit Sockets;
Interface

uses
  ctypes,exec;

type
    size_t   = cuint32;         { as definied in the C standard}
    ssize_t  = cint32;          { used by function for returning number of bytes}

    socklen_t= cuint32;
    TSocklen = socklen_t;
    pSocklen = ^socklen_t;


//{ $i unxsockh.inc}
{$define BSD}
{$define SOCK_HAS_SINLEN}
{$i socketsh.inc}

type
  TUnixSockAddr = packed Record
                  sa_len     : cuchar;
                  family       : sa_family_t;
                  path:array[0..107] of char;    //104 total for freebsd.
                  end;

type
  hostent = record
    h_name     : PChar;
    h_aliases  : PPChar;
    h_addrtype : LongInt;
    h_Length   : LongInt;
    h_addr_list: ^PDWord;
  end;
  THostEnt = hostent;
  PHostEnt = ^THostEnt;


const
  AF_UNSPEC      = 0;               {* unspecified *}
  AF_LOCAL       = 1;               {* local to host (pipes, portals) *}
  AF_UNIX        = AF_LOCAL;        {* backward compatibility *}
  AF_INET        = 2;               {* internetwork: UDP, TCP, etc. *}
  AF_IMPLINK     = 3;               {* arpanet imp addresses *}
  AF_PUP         = 4;               {* pup protocols: e.g. BSP *}
  AF_CHAOS       = 5;               {* mit CHAOS protocols *}
  AF_NS          = 6;               {* XEROX NS protocols *}
  AF_ISO         = 7;               {* ISO protocols *}
  AF_OSI         = AF_ISO;
  AF_ECMA        = 8;               {* european computer manufacturers *}
  AF_DATAKIT     = 9;               {* datakit protocols *}
  AF_CCITT       = 10;              {* CCITT protocols, X.25 etc *}
  AF_SNA         = 11;              {* IBM SNA *}
  AF_DECnet      = 12;              {* DECnet *}
  AF_DLI         = 13;              {* DEC Direct data link interface *}
  AF_LAT         = 14;              {* LAT *}
  AF_HYLINK      = 15;              {* NSC Hyperchannel *}
  AF_APPLETALK   = 16;              {* Apple Talk *}
  AF_ROUTE       = 17;              {* Internal Routing Protocol *}
  AF_LINK        = 18;              {* Link layer interface *}
  pseudo_AF_XTP  = 19;              {* eXpress Transfer Protocol (no AF) *}
  AF_COIP        = 20;              {* connection-oriented IP, aka ST II *}
  AF_CNT         = 21;              {* Computer Network Technology *}
  pseudo_AF_RTIP = 22;              {* Help Identify RTIP packets *}
  AF_IPX         = 23;              {* Novell Internet Protocol *}
  AF_SIP         = 24;              {* Simple Internet Protocol *}
  pseudo_AF_PIP  = 25;              {* Help Identify PIP packets *}

  AF_MAX         = 26;


const
  EsockEINTR            = 4; // EsysEINTR;   
  EsockEBADF            = 9; // EsysEBADF;
  EsockEFAULT           = 14; // EsysEFAULT;
  EsockEINVAL           = 22; //EsysEINVAL;
  EsockEACCESS          = 13; //ESysEAcces;
  EsockEMFILE           = 24; //ESysEmfile;
  EsockENOBUFS          = 55; //ESysENoBufs;
  EsockENOTCONN         = 57; //ESysENotConn;
  EsockEPROTONOSUPPORT  = 43; //ESysEProtoNoSupport;
  EsockEWOULDBLOCK      = 35; //ESysEWouldBlock; // same as eagain on morphos

{ unix socket specific functions }
{*
Procedure Str2UnixSockAddr(const addr:string;var t:TUnixSockAddr;var len:longint); deprecated;
Function Bind(Sock:longint;const addr:string):boolean; deprecated;
Function Connect(Sock:longint;const addr:string;var SockIn,SockOut:text):Boolean; deprecated;
Function Connect(Sock:longint;const addr:string;var SockIn,SockOut:file):Boolean; deprecated;
Function Accept(Sock:longint;var addr:string;var SockIn,SockOut:text):Boolean;    deprecated;
Function Accept(Sock:longint;var addr:string;var SockIn,SockOut:File):Boolean;    deprecated;
*}
//function  fpaccept      (s:cint; addrx : psockaddr; addrlen : psocklen):cint; maybelibc
//function  fpbind      (s:cint; addrx : psockaddr; addrlen : tsocklen):cint;  maybelibc
//function  fpconnect     (s:cint; name  : psockaddr; namelen : tsocklen):cint;  maybelibc

var
  SocketBase: PLibrary;

function bsd_socket(Domain: LongInt; Type_: LongInt; Protocol: LongInt): LongInt; // 5
function bsd_bind(s: LongInt; const name: PSockAddr; NameLen: LongInt): LongInt; // 6
function bsd_listen(s: LongInt; BackLog: LongInt): LongInt; // 7
function bsd_accept(s: LongInt; Addr: PSockaddr; AddrLen: PSockLen): LongInt; // 8
function bsd_connect(s : LongInt; const Name: PSockaddr; NameLen: LongInt): LongInt; // 9
function bsd_sendto(s: LongInt; const Msg: PChar; Len: LongInt; Flags: LongInt; const To_: PSockaddr; ToLen: LongInt): LongInt; // 10
function bsd_send(s: LongInt; const msg: PChar; Len: LongInt; Flags: LongInt): LongInt; // 11
function bsd_recvfrom(s: LongInt; Buf: PChar; Len: LongInt; Flags: LongInt; From: PSockaddr; FromLen: PSockLen): LongInt; // 12
function bsd_recv(s: LongInt; buf: PChar; Len: LongInt; Flags: LongInt): LongInt; // 13
function bsd_shutdown(s: LongInt; How: LongInt): LongInt; // 14
function bsd_setsockopt(s: LongInt; level: LongInt; optname: LongInt; const optval: Pointer; optlen: LongInt) : LongInt; // 15
function bsd_getsockopt(s: LongInt; Level: LongInt; OptName: LongInt; OptVal: Pointer; OptLen: PSockLen): LongInt; // 16
function bsd_getsockname(s: LongInt; HostName: PSockaddr; NameLen: PSockLen): LongInt; // 17
function bsd_getpeername(s: LongInt; HostName: PSockaddr; NameLen: PSockLen): LongInt; // 18
function bsd_closesocket(s: LongInt): LongInt; // 20
function bsd_Errno: LongInt; // 27
function bsd_inet_ntoa(in_: LongWord): PChar; // 29
function bsd_inet_addr(const cp: PChar): LongWord; // 30
function bsd_gethostbyname(const Name: PChar): PHostEnt; //35
function bsd_gethostbyaddr(const Addr: PByte; Len: LongInt; Type_: LongInt): PHostEnt; // 36

Implementation

//Uses {$ifndef FPC_USE_LIBC}SysCall{$else}initc{$endif};

threadvar internal_socketerror: cint;

{ Include filerec and textrec structures }
{$i filerec.inc}
{$i textrec.inc}


function bsd_socket(Domain: LongInt; Type_: LongInt; Protocol: LongInt): LongInt; // 5
type
  TLocalCall = function(Domain: LongInt; Type_: LongInt; Protocol: LongInt; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 5));
  bsd_socket := Call(Domain, Type_, Protocol, SocketBase);
end;

function bsd_bind(s: LongInt; const name: PSockAddr; NameLen: LongInt): LongInt; // 6
type
  TLocalCall = function(s: LongInt; const name: PSockAddr; NameLen: LongInt; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 6));
  bsd_bind := Call(s, name, NameLen, SocketBase);
end;

function bsd_listen(s: LongInt; BackLog: LongInt): LongInt; // 7
type
  TLocalCall = function(s: LongInt; BackLog: LongInt; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 7));
  bsd_listen := Call(s, BackLog, SocketBase);
end;

function bsd_accept(s: LongInt; Addr: PSockaddr; AddrLen: PSockLen): LongInt; // 8
type
  TLocalCall = function(s: LongInt; Addr: PSockaddr; AddrLen: PSockLen; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 8));
  bsd_accept := Call(s, Addr, AddrLen, SocketBase);
end;

function bsd_connect(s : LongInt; const Name: PSockaddr; NameLen: LongInt): LongInt; // 9
type
  TLocalCall = function(s : LongInt; const Name: PSockaddr; NameLen: LongInt; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 9));
  bsd_connect := Call(s, Name, NameLen, SocketBase);
end;

function bsd_sendto(s: LongInt; const Msg: PChar; Len: LongInt; Flags: LongInt; const To_: PSockaddr; ToLen: LongInt): LongInt; // 10
type
  TLocalCall = function(s: LongInt; const Msg: PChar; Len: LongInt; Flags: LongInt; const To_: PSockaddr; ToLen: LongInt; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 10));
  bsd_sendto := Call(s, Msg, Len, Flags, To_, ToLen, SocketBase);
end;

function bsd_send(s: LongInt; const msg: PChar; Len: LongInt; Flags: LongInt): LongInt; // 11
type
  TLocalCall = function(s: LongInt; const msg: PChar; Len: LongInt; Flags: LongInt; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 11));
  bsd_send := Call(s, msg, Len, Flags, SocketBase);
end;

function bsd_recvfrom(s: LongInt; Buf: PChar; Len: LongInt; Flags: LongInt; From: PSockaddr; FromLen: PSockLen): LongInt; // 12
type
  TLocalCall = function(s: LongInt; Buf: PChar; Len: LongInt; Flags: LongInt; From: PSockaddr; FromLen: PSockLen; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 12));
  bsd_recvfrom := Call(s, Buf, Len, Flags, From, FromLen, SocketBase);
end;

function bsd_recv(s: LongInt; buf: PChar; Len: LongInt; Flags: LongInt): LongInt; // 13
type
  TLocalCall = function(s: LongInt; buf: PChar; Len: LongInt; Flags: LongInt; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 13));
  bsd_recv := Call(s, buf, Len, Flags, SocketBase);
end;

function bsd_shutdown(s: LongInt; How: LongInt): LongInt; // 14
type
  TLocalCall = function(s: LongInt; How: LongInt; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 14));
  bsd_shutdown := Call(s, How, SocketBase);
end;

function bsd_setsockopt(s: LongInt; level: LongInt; optname: LongInt; const optval: Pointer; optlen: LongInt) : LongInt; // 15
type
  TLocalCall = function(s: LongInt; Level: LongInt; OptName: LongInt; const OptVal: Pointer; OptLen: LongInt; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 15));
  bsd_setsockopt := Call(s, Level, OptName, OptVal, OptLen, SocketBase);
end;


function bsd_getsockopt(s: LongInt; Level: LongInt; OptName: LongInt; OptVal: Pointer; OptLen: pSockLen): LongInt; // 16
type
  TLocalCall = function(s: LongInt; Level: LongInt; OptName: LongInt; OptVal: Pointer; OptLen: pSockLen; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 16));
  bsd_getsockopt := Call(s, Level, OptName, OptVal, OptLen, SocketBase);
end;

function bsd_getsockname(s: LongInt; HostName: PSockaddr; NameLen: PSockLen): LongInt; // 17
type
  TLocalCall = function(s: LongInt; HostName: PSockaddr; NameLen: PSockLen; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 17));
  bsd_getsockname := Call(s, HostName, NameLen, SocketBase);
end;

function bsd_getpeername(s: LongInt; HostName: PSockaddr; NameLen: PSockLen): LongInt; // 18
type
  TLocalCall = function(s: LongInt; HostName: PSockaddr; NameLen: PSockLen; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 18));
  bsd_getpeername := Call(s, HostName, NameLen, SocketBase);
end;

function bsd_closesocket(s: LongInt): LongInt; // 20
type
  TLocalCall = function(s: LongInt; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 20));
  bsd_closesocket := Call(s, SocketBase);
end;

function bsd_Errno: LongInt; // 27
type
  TLocalCall = function(LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 27));
  bsd_Errno := Call(SocketBase);
end;

function bsd_inet_ntoa(in_: LongWord): PChar; // 29
type
  TLocalCall = function(in_: LongWord; LibBase: Pointer): PChar; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 29));
  bsd_inet_ntoa := Call(in_, SocketBase);
end;

function bsd_inet_addr(const cp: PChar): LongWord; // 30
type
  TLocalCall = function(const cp: PChar; LibBase: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 30));
  bsd_inet_addr := Call(cp, SocketBase);
end;

function bsd_gethostbyname(const Name: PChar): PHostEnt; //35
type
  TLocalCall = function(const Name: PChar; LibBase: Pointer): PHostEnt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 35));
  bsd_gethostbyname := Call(Name, SocketBase);
end;

function bsd_gethostbyaddr(const Addr: PByte; Len: LongInt; Type_: LongInt): PHostEnt; // 36
type
  TLocalCall = function(const Addr: PByte; Len: LongInt; Type_: LongInt; LibBase: Pointer): PHostEnt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(SocketBase, 36));
  bsd_gethostbyaddr := Call(Addr, Len, Type_, SocketBase);
end;


{******************************************************************************
                          Kernel Socket Callings
******************************************************************************}

function socketerror: cint;
begin
  socketerror := internal_socketerror;
end;

function fpgeterrno: longint; inline;
begin
  fpgeterrno := bsd_Errno;
end;

function fpClose(d: LongInt): LongInt; inline;
begin
  fpClose := bsd_CloseSocket(d);
end;

function fpaccept(s: cint; addrx: PSockaddr; Addrlen: PSocklen): cint;
begin
  fpaccept := bsd_accept(s,addrx,addrlen);
  internal_socketerror := fpgeterrno; 
end;

function fpbind(s:cint; addrx: psockaddr; addrlen: tsocklen): cint;
begin
  fpbind := bsd_bind(s, addrx, addrlen);
  internal_socketerror := fpgeterrno;
end;

function fpconnect(s:cint; name: psockaddr; namelen: tsocklen): cint;
begin
  fpconnect := bsd_connect(s, name, namelen);
  internal_socketerror := fpgeterrno;
end;

function fpgetpeername (s:cint; name  : psockaddr; namelen : psocklen):cint;
begin
  fpgetpeername := bsd_getpeername(s,name,namelen);
  internal_socketerror := fpgeterrno;
end;

function fpgetsockname(s:cint; name  : psockaddr; namelen : psocklen):cint;
begin
  fpgetsockname := bsd_getsockname(s,name,namelen);
  internal_socketerror := fpgeterrno;
end;

function fpgetsockopt  (s:cint; level:cint; optname:cint; optval:pointer; optlen : psocklen):cint;
begin
  fpgetsockopt := bsd_getsockopt(s,level,optname,optval,optlen);
  internal_socketerror := fpgeterrno;
end;

function fplisten(s:cint; backlog : cint):cint;
begin
  fplisten := bsd_listen(s, backlog);
  internal_socketerror := fpgeterrno;
end;

function fprecv(s:cint; buf: pointer; len: size_t; Flags: cint): ssize_t;
begin
  fprecv := bsd_recv(s,buf,len,flags);
  internal_socketerror := fpgeterrno;
end;

function fprecvfrom(s:cint; buf: pointer; len: size_t; flags: cint; from : psockaddr; fromlen : psocklen):ssize_t;
begin
  fprecvfrom := bsd_recvfrom(s, buf, len, flags, from, fromlen);
  internal_socketerror := fpgeterrno;
end;

function fpsend(s:cint; msg:pointer; len:size_t; flags:cint):ssize_t;
begin
  fpsend := bsd_send(s, msg, len, flags);
  internal_socketerror := fpgeterrno;
end;

function fpsendto(s:cint; msg:pointer; len:size_t; flags:cint; tox :psockaddr; tolen: tsocklen):ssize_t;
begin
  fpsendto := bsd_sendto(s, msg, len, flags, tox, tolen);
  internal_socketerror := fpgeterrno;
end;

function fpsetsockopt(s:cint; level:cint; optname:cint; optval:pointer; optlen :tsocklen):cint;
begin
  fpsetsockopt := bsd_setsockopt(s, level, optname, optval, optlen);
  internal_socketerror := fpgeterrno;
end;

function fpshutdown(s: cint; how: cint): cint;
begin
  fpshutdown := bsd_shutdown(s, how);
  internal_socketerror := fpgeterrno;
end;

function fpsocket(domain: cint; xtype: cint; protocol: cint): cint;
begin
  fpsocket := bsd_socket(domain, xtype, protocol);
  internal_socketerror := fpgeterrno;
end;


function fpsocketpair(d:cint; xtype:cint; protocol:cint; sv:pcint):cint;
begin
{
  fpsocketpair:=cfpsocketpair(d,xtype,protocol,sv);
  internal_socketerror:=fpgeterrno;
}
  fpsocketpair:=-1;
end;


{$i sockovl.inc}
{$i sockets.inc}

// FIXME: this doesn't make any sense here, because SocketBase should be task-specific
// but FPC doesn't support that yet (TODO)
{$WARNING FIX ME, TODO}


initialization
  SocketBase := nil;
  SocketBase:=OpenLibrary('bsdsocket.library',0);
finalization
  if SocketBase <> nil then
    CloseLibrary(SocketBase);
end.
