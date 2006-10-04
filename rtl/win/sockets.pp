{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by the Free Pascal development team

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$mode objfpc}
unit Sockets;

Interface

{$macro on}
{$define maybelibc:=}

  Uses
     winsock2,ctypes;

Type
  size_t  = cuint32;
  ssize_t = cint32;
  tsocklen= cint;
  psocklen= ^tsocklen;


  Const
     AF_MAX          = WinSock2.AF_MAX;
     PF_MAX          = AF_MAX;

{$i socketsh.inc}

Implementation

{ Include filerec and textrec structures }
{$i filerec.inc}
{$i textrec.inc}

{******************************************************************************
                          Basic Socket Functions
******************************************************************************}

//function fprecvmsg     (s:cint; msg: pmsghdr; flags:cint):ssize_t;
//function fpsendmsg    (s:cint; hdr: pmsghdr; flags:cint):ssize;

//function fpsocket     (domain:cint; xtype:cint; protocol: cint):cint;


function fpsocket       (domain:cint; xtype:cint; protocol: cint):cint;
begin
  fpSocket:=WinSock2.Socket(Domain,xtype,ProtoCol);
  if fpSocket<0 then
    SocketError:=WSAGetLastError
  else
    SocketError:=0;
end;

function fpsend (s:cint; msg:pointer; len:size_t; flags:cint):ssize_t;
begin
  fpSend:=WinSock2.Send(S,msg,len,flags);
  if fpSend<0 then
    SocketError:=WSAGetLastError
  else
    SocketError:=0;
end;

function fpsendto (s:cint; msg:pointer; len:size_t; flags:cint; tox :psockaddr; tolen: tsocklen):ssize_t;
begin
  // Dubious construct, this should be checked. (IPV6 fails ?)
  fpSendTo:=WinSock2.SendTo(S,msg,Len,Flags,Winsock2.PSockAddr(tox),toLen);
  if fpSendTo<0 then
    SocketError:=WSAGetLastError
  else
    SocketError:=0;
end;

function fprecv         (s:cint; buf: pointer; len: size_t; flags: cint):ssize_t;
begin
  fpRecv:=WinSock2.Recv(S,Buf,Len,Flags);
  if fpRecv<0 then
    SocketError:=WSAGetLastError
  else
    SocketError:=0;
end;

function fprecvfrom    (s:cint; buf: pointer; len: size_t; flags: cint; from : psockaddr; fromlen : psocklen):ssize_t;

begin
  fpRecvFrom:=WinSock2.RecvFrom(S,Buf,Len,Flags,WinSock2.PSockAddr(From),FromLen);
  if fpRecvFrom<0 then
    SocketError:=WSAGetLastError
  else
    SocketError:=0;
end;

function fpconnect     (s:cint; name  : psockaddr; namelen : tsocklen):cint;

begin
  fpConnect:=Winsock2.Connect(S,WinSock2.PSockAddr(name),nameLen);
  if fpConnect<0 then
    SocketError:=WSAGetLastError
  else
    SocketError:=0;
end;

function fpshutdown     (s:cint; how:cint):cint;
begin
  fpShutDown:=Winsock2.ShutDown(S,How);
  if fpShutDown<0 then
    SocketError:=WSAGetLastError
  else
    SocketError:=0;
end;

Function socket(Domain,SocketType,Protocol:Longint):Longint;
begin
  socket:=fpsocket(Domain,sockettype,protocol);
end;

Function Send(Sock:Longint;Const Buf;BufLen,Flags:Longint):Longint;

begin
  send:=fpsend(sock,@buf,buflen,flags);
end;

Function SendTo(Sock:Longint;Const Buf;BufLen,Flags:Longint;Var Addr; AddrLen : Longint):Longint;

begin
  sendto:=fpsendto(sock,@buf,buflen,flags,@addr,addrlen);
end;

Function Recv(Sock:Longint;Var Buf;BufLen,Flags:Longint):Longint;
begin
  Recv:=fpRecv(Sock,@Buf,BufLen,Flags);
end;

Function RecvFrom(Sock : Longint; Var Buf; Buflen,Flags : Longint; Var Addr; var AddrLen : longint) : longint;
begin
  RecvFrom:=fpRecvFrom(Sock,@Buf,BufLen,Flags,@Addr,@AddrLen);
end;

function fpbind (s:cint; addrx : psockaddr; addrlen : tsocklen):cint;

begin
  fpbind:=Winsock2.Bind(S,Winsock2.PSockAddr(Addrx),AddrLen);
  if fpbind<0 then
       SocketError:=WSAGetLastError
  else
       SocketError:=0;
end;

function fplisten      (s:cint; backlog : cint):cint;

begin
  fplisten:=Winsock2.Listen(S,backlog);
  if fplisten<0 then
       SocketError:=WSAGetLastError
  else
       SocketError:=0;
end;

function fpaccept      (s:cint; addrx : psockaddr; addrlen : psocklen):cint;
begin
  fpAccept:=Winsock2.Accept(S,Winsock2.PSockAddr(Addrx), AddrLen);
  if fpAccept<0 then
    SocketError:=WSAGetLastError
  else
    SocketError:=0;
end;

function fpgetsockname (s:cint; name  : psockaddr; namelen : psocklen):cint;

begin
  fpGetSockName:=Winsock2.GetSockName(S,Winsock2.TSockAddr(name^),nameLen^);
  if fpGetSockName<0 then
    SocketError:=WSAGetLastError
  else
    SocketError:=0;
end;

function fpgetpeername (s:cint; name  : psockaddr; namelen : psocklen):cint;
begin
  fpGetPeerName:=Winsock2.GetPeerName(S,Winsock2.TSockAddr(name^),NameLen^);
  if fpGetPeerName<0 then
    SocketError:=WSAGetLastError
  else
    SocketError:=0;
end;

function fpgetsockopt  (s:cint; level:cint; optname:cint; optval:pointer; optlen : psocklen):cint;
begin
  fpGetSockOpt:=Winsock2.GetSockOpt(S,Level,OptName,OptVal,OptLen^);
  if fpGetSockOpt<0 then
    SocketError:=WSAGetLastError
  else
    SocketError:=0;
end;

function fpsetsockopt  (s:cint; level:cint; optname:cint; optval:pointer; optlen :tsocklen):cint;

begin
  fpSetSockOpt:=Winsock2.SetSockOpt(S,Level,OptName,OptVal,OptLen);
  if fpSetSockOpt<0 then
    SocketError:=WSAGetLastError
  else
    SocketError:=0;
end;

function fpsocketpair  (d:cint; xtype:cint; protocol:cint; sv:pcint):cint;
begin
  fpsocketpair:=-1;
  SocketError:=EOPNOTSUPP;
end;

Function CloseSocket(Sock:Longint):Longint;
var i : longint;
begin
  i := Winsock2.CloseSocket (Sock);
  if i <> 0 then
  begin
    SocketError:=WSAGetLastError;
    CloseSocket := i;
  end else
  begin
    CloseSocket := 0;
    SocketError := 0;
  end;
end;

Function Bind(Sock:Longint;Const Addr;AddrLen:Longint):Boolean;

begin
  bind:=fpBind(Sock,@Addr,AddrLen)=0;
end;

Function Listen(Sock,MaxConnect:Longint):Boolean;

begin
  Listen:=fplisten(Sock,MaxConnect)=0;
end;

Function Accept(Sock:Longint;Var Addr;Var Addrlen:Longint):Longint;

begin
  Accept:=FPAccept(sock,@addr,@addrlen);
end;

Function Shutdown(Sock:Longint;How:Longint):Longint;

begin
 shutdown:=fpshutdown(sock,how);
end;

Function Connect(Sock:Longint;Const Addr;Addrlen:Longint):Boolean;

begin
 connect:=fpconnect(sock,@addr,addrlen)=0;
end;

Function GetSocketName(Sock:Longint;Var Addr;Var Addrlen:Longint):Longint;
begin
 GetSocketName:=fpGetSockName(sock,@addr,@addrlen);
end;

Function GetPeerName(Sock:Longint;Var Addr;Var Addrlen:Longint):Longint;
begin
 GetPeerName:=fpGetPeerName(Sock,@addr,@addrlen);
end;

Function GetSocketOptions(Sock,Level,OptName:Longint;Var OptVal;Var optlen:longint):Longint;
begin
 GetSocketOptions:=fpGetSockOpt(sock,level,optname,@optval,@optlen);
end;

Function SetSocketOptions(Sock,Level,OptName:Longint;Const OptVal;optlen:longint):Longint;

begin
 SetSocketOptions:=fpsetsockopt(sock,level,optname,@optval,optlen);
end;

Function SocketPair(Domain,SocketType,Protocol:Longint;var Pair:TSockArray):Longint;
begin
  SocketPair:=fpsocketpair(domain,sockettype,protocol,@pair[1]);
end;

{$ifdef unix}
{ mimic the linux fpWrite/fpRead calls for the file/text socket wrapper }
function fpWrite(handle : longint;Const bufptr;size : dword) : dword;
begin
  fpWrite := dword(Winsock2.send(handle, bufptr, size, 0));
  if fpWrite = dword(SOCKET_ERROR) then
  begin
    SocketError := WSAGetLastError;
    fpWrite := 0;
  end
  else
    SocketError := 0;
end;

function fpRead(handle : longint;var bufptr;size : dword) : dword;
  var
     d : dword;

  begin
     if ioctlsocket(handle,FIONREAD,@d) = SOCKET_ERROR then
       begin
         SocketError:=WSAGetLastError;
         fpRead:=0;
         exit;
       end;
     if d>0 then
       begin
         if size>d then
           size:=d;
         fpRead := dword(Winsock2.recv(handle, bufptr, size, 0));
         if fpRead = dword(SOCKET_ERROR) then
         begin
           SocketError:= WSAGetLastError;
           fpRead := 0;
         end else
           SocketError:=0;
       end
     else
       SocketError:=0;
  end;
{$else}
{ mimic the linux fdWrite/fdRead calls for the file/text socket wrapper }
function fdWrite(handle : longint;Const bufptr;size : dword) : dword;
begin
  fdWrite := dword(Winsock2.send(handle, bufptr, size, 0));
  if fdWrite = dword(SOCKET_ERROR) then
  begin
    SocketError := WSAGetLastError;
    fdWrite := 0;
  end
  else
    SocketError := 0;
end;

function fdRead(handle : longint;var bufptr;size : dword) : dword;
  var
     d : dword;

  begin
     if ioctlsocket(handle,FIONREAD,@d) = SOCKET_ERROR then
       begin
         SocketError:=WSAGetLastError;
         fdRead:=0;
         exit;
       end;
     if d>0 then
       begin
         if size>d then
           size:=d;
         fdRead := dword(Winsock2.recv(handle, bufptr, size, 0));
         if fdRead = dword(SOCKET_ERROR) then
         begin
           SocketError:= WSAGetLastError;
           fdRead := 0;
         end else
           SocketError:=0;
       end
     else
       SocketError:=0;
  end;
{$endif}

{$i sockets.inc}

{ Winsocket stack needs an init. and cleanup code }
var
  wsadata : twsadata;

initialization
  WSAStartUp($2,wsadata);
finalization
  WSACleanUp;
end.
