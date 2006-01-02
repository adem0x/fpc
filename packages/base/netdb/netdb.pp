{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2003 by the Free Pascal development team

    Implement networking routines.
    
    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$mode objfpc}
{$h+}

unit netdb;
{
  WARNING
  This unit hardly does any error checking. For example, stringfromlabel
  could easily be exploited by  someone sending malicious UDP packets in
  order to crash  your program.  So if you really want to depend on this
  in critical programs then you'd better fix a lot of code in here.
  Otherwise, it appears to work pretty well.
}

Interface

{ i hsh.inc} // disappears if part of resolve.pp !!

Uses Sockets;

Type
  THostAddr = in_addr;		// historical aliases for these.
  THostAddr6= Tin6_addr;
  TNetAddr  = THostAddr;	// but in net order.

Const
  DNSPort        = 53;
  MaxServers     = 4;
  MaxResolveAddr = 10;
  SResolveFile   = '/etc/resolv.conf';
  SServicesFile  = '/etc/services'; 
  SHostsFile     = '/etc/hosts';
  SNetworksFile  = '/etc/networks';
  SProtocolFile  = '/etc/protocols';

  MaxRecursion = 10;
  MaxIP4Mapped = 10;
  
Type
  TDNSServerArray = Array[1..MaxServers] of THostAddr;
  TServiceEntry = record
    Name     : String;
    Protocol : String;
    Port     : Word;
    Aliases  : String;
  end;
     
  THostEntry = record
    Name : String;
    Addr : THostAddr;
    Aliases : String;
  end;  
  
  TNetworkEntry = Record
    Name : String;
    Addr : TNetAddr;
    Aliases : String;
  end;  

  TProtocolEntry = Record
    Name : String;
    Number : integer;
    Aliases : String;
  end;  

Var  
  DNSServers            : TDNSServerArray;
  DNSServerCount        : Integer;
  DefaultDomainList     : String;
  CheckResolveFileAge   : Boolean; 
  TimeOutS,TimeOutMS    : Longint;
  
  
Function GetDNSServers(FN : String) : Integer;

Function ResolveName(HostName : String; Var Addresses : Array of THostAddr) : Integer;
Function ResolveName6(HostName : String; Var Addresses : Array of THostAddr6) : Integer;


Function ResolveAddress(HostAddr : THostAddr; Var Addresses : Array of String) : Integer;
Function ResolveAddress6(HostAddr: THostAddr6; var Addresses: Array of string) : Integer;

function IN6_IS_ADDR_V4MAPPED(HostAddr: THostAddr6): boolean;

Function ResolveHostByName(HostName : String; Var H : THostEntry) : Boolean;
Function ResolveHostByAddr(HostAddr : THostAddr; Var H : THostEntry) : Boolean;

Function GetHostByName(HostName: String;  Var H : THostEntry) : boolean;
Function GetHostByAddr(Addr: THostAddr;  Var H : THostEntry) : boolean;

Function GetNetworkByName(NetName: String; Var N : TNetworkEntry) : boolean;
Function GetNetworkByAddr(Addr: THostAddr; Var N : TNetworkEntry) : boolean;

Function GetServiceByName(Const Name,Proto : String; Var E : TServiceEntry) : Boolean;
Function GetServiceByPort(Port : Word;Const Proto : String; Var E : TServiceEntry) : Boolean;

Function GetProtocolByName(ProtoName: String;  Var H : TProtocolEntry) : boolean;
Function GetProtocolByNumber(proto: Integer;  Var H : TProtocolEntry) : boolean;


Implementation

uses 
   BaseUnix,
   sysutils;


const
  { from http://www.iana.org/assignments/dns-parameters }
  DNSQRY_A     = 1;                     // name to IP address 
  DNSQRY_AAAA  = 28;                    // name to IP6 address
  DNSQRY_A6    = 38;                    // name to IP6 (new)
  DNSQRY_PTR   = 12;                    // IP address to name 
  DNSQRY_MX    = 15;                    // name to MX 
  DNSQRY_TXT   = 16;                    // name to TXT
  DNSQRY_CNAME = 5;

  // Flags 1
  QF_QR     = $80;
  QF_OPCODE = $78;
  QF_AA     = $04;
  QF_TC     = $02;  // Truncated.
  QF_RD     = $01;

  // Flags 2
  QF_RA     = $80;
  QF_Z      = $70;
  QF_RCODE  = $0F;


   
Type 
  TPayLoad  = Array[0..511] of char;
  TQueryData = packed Record
    id      : Array[0..1] of Byte;
    flags1  : Byte;
    flags2  : Byte; 
    qdcount : word;
    ancount : word;
    nscount : word;
    arcount : word;
    Payload : TPayLoad;
  end;
  
  TRRData = Packed record       // RR record
    Atype    : Word;            // Answer type
    AClass   : Word;
    TTL      : Cardinal;
    RDLength : Word;
  end;

Var
  ResolveFileAge  : Longint;
  ResolveFileName : String;

{ ---------------------------------------------------------------------
   Resolve.conf handling
  ---------------------------------------------------------------------}
  
Function GetDNSServers(Fn : String) : Integer;

Var
  R : Text;
  L : String;
  I : Integer;
  H : THostAddr;

  Function CheckDirective(Dir : String) : Boolean;
  
  Var
    P : Integer;
  
  begin
    P:=Pos(Dir,L);
    Result:=(P<>0);
    If Result then
      begin
      Delete(L,1,P+Length(Dir));
      L:=Trim(L);
      end;
  end;
   
begin
  Result:=0;
  ResolveFileName:=Fn;
  ResolveFileAge:=FileAge(FN);
  {$i-}
  Assign(R,FN);
  Reset(R);
  {$i+}
  If (IOResult<>0) then 
    exit;
  Try  
    While not EOF(R) do
      begin
      Readln(R,L);
      I:=Pos('#',L);
      If (I<>0) then
        L:=Copy(L,1,I-1)
      else
        begin
          I:=Pos(';',L);
          If (I<>0) then
            L:=Copy(L,1,I-1)
	end;
      If CheckDirective('nameserver') then
        begin
        H:=HostToNet(StrToHostAddr(L));
        If H.s_bytes[1]<>0 then
          begin
          Inc(Result);
          DNSServers[Result]:=H;
          end;
        end
      else if CheckDirective('domain') then
        DefaultDomainList:=L
      else if CheckDirective('search') then
        DefaultDomainList:=L;
      end;
  Finally
    Close(R);
  end;    
  DNSServerCount:=Result;
end;

Procedure CheckResolveFile;

Var
  F : Integer;

begin
  If CheckResolveFileAge then
    begin
    F:=FileAge(ResolveFileName);
    If ResolveFileAge<F then
      GetDnsServers(ResolveFileName);
    end;  
end;

{ ---------------------------------------------------------------------
    Payload handling functions.
  ---------------------------------------------------------------------}
  

Procedure DumpPayLoad(Q : TQueryData; L : Integer);

Var 
  i : Integer;

begin
  Writeln('Payload : ',l);
  For I:=0 to L-1 do
    Write(Byte(Q.Payload[i]),' ');
  Writeln;  
end;
  
Function BuildPayLoad(Var Q : TQueryData; Name : String; RR : Word; QClass : Word) : Integer;

Var
  P : PByte;
  l,S : Integer;
  
begin
  Result:=-1;
  If length(Name)>506 then
    Exit;
  Result:=0;  
  P:=@Q.Payload;
  Repeat
    L:=Pos('.',Name);
    If (L=0) then
      S:=Length(Name)
    else
      S:=L-1;
    P[Result]:=S;
    Move(Name[1],P[Result+1],S);
    Inc(Result,S+1);
    If (L>0) then
      Delete(Name,1,L);
  Until (L=0);
  P[Result]:=0;
  rr := htons(rr);
  Move(rr,P[Result+1],2);
  Inc(Result,3);
  QClass := htons(QClass);
  Move(qclass,P[Result],2);
  Inc(Result,2);
end;



Function NextRR(Const PayLoad : TPayLoad;Var Start : LongInt; AnsLen : LongInt; Var RR : TRRData) : Boolean;

Var
  I : Integer;
  HaveName : Boolean;
  PA : ^TRRData;
  
begin
  Result:=False;
  I:=Start;
  // Skip labels and pointers. At least 1 label or pointer is present.
  Repeat
    HaveName:=True;
    If (Payload[i]>#63) then // Pointer, skip
      Inc(I,2)
    else If Payload[i]=#0 then // Null termination of label, skip.
      Inc(i)
    else  
      begin
      Inc(I,Ord(Payload[i])+1); // Label, continue scan.
      HaveName:=False;
      end;
  Until HaveName or (I>(AnsLen-SizeOf(TRRData)));
  Result:=(I<=(AnsLen-SizeOf(TRRData)));
  // Check RR record.
  PA:=@Payload[i];
  RR:=PA^;
  Start:=I+SizeOf(TRRData);
end;


Function BuildName (Const PayLoad : TPayLoad; Start,len : Integer) : String;

Const
  FIREDNS_POINTER_VALUE = $C000;
  
Var
  I,O : Integer;
  P : Word;
  
begin
  SetLength(Result,512);
  I:=Start;
  O:=1;
  // Copy labels and pointers. At least 1 label or pointer is present.
  Repeat
    If (Payload[i]>#63) then // Pointer, move.
      begin
      Move(Payload[i],P,2);
      I:=ntohs(p)-FIREDNS_POINTER_VALUE-12;
      end
    else if Payload[i]<>#0 then // Label, copy
      begin
      If O<>1 then
        begin
        Result[O]:='.';
        Inc(O);
        end;
      P:=Ord(Payload[i]);  
      Move(Payload[i+1],Result[o],P);
      Inc(I,P+1);
      Inc(O,P);
      end;
   Until (Payload[I]=#0);    
end;


{ ---------------------------------------------------------------------
    QueryData handling functions
  ---------------------------------------------------------------------}
  
Function CheckAnswer(Const Qry : TQueryData; Var Ans : TQueryData) : Boolean;

begin
  Result:=False;
  With Ans do
    begin
    // Check ID.
    If (ID[1]<>QRY.ID[1]) or (ID[0]<>Qry.ID[0]) then
      exit;  
    // Flags ?
    If (Flags1 and QF_QR)=0 then
      exit;
    if (Flags1 and QF_OPCODE)<>0 then 
      exit;  
    if (Flags2 and QF_RCODE)<>0 then
      exit;  
    // Number of answers ?  
    AnCount := htons(Ancount);
    If Ancount<1 then
      Exit;
    Result:=True;
    end;
end;

Function SkipAnsQueries(Var Ans : TQueryData; L : Integer) : integer;

Var
  Q,I : Integer;

begin
  Result:=0;
  With Ans do
    begin
    qdcount := htons(qdcount);
    i:=0;
    q:=0;
    While (Q<qdcount) and (i<l) do  
      begin
      If Ord(Payload[i])>63 then
        begin
        Inc(I,6);
        Inc(Q);
        end
      else
        begin
        If Payload[i]=#0 then
          begin
          inc(q);
          Inc(I,5);
          end
        else
          Inc(I,Ord(Payload[i])+1);  
        end;  
      end;
    Result:=I;  
    end;  
end;

{ ---------------------------------------------------------------------
    DNS Query functions.
  ---------------------------------------------------------------------}
  

Function Query(Resolver : Integer; Var Qry,Ans : TQueryData; QryLen : Integer; Var AnsLen : Integer) : Boolean;

Var
  SA : TInetSockAddr;
  Sock,L : Longint;
  Al,RTO : Longint;
  ReadFDS : TFDSet;
  
begin
  Result:=False;
  With Qry do
    begin
    ID[0]:=Random(256);
    ID[1]:=Random(256);
    Flags1:=QF_RD;
    Flags2:=0;
    qdcount:=htons(1); // was 1 shl 8;
    ancount:=0;
    nscount:=0;
    arcount:=0;
    end;
  Sock:=Socket(PF_INET,SOCK_DGRAM,0);
  If Sock=-1 then 
    exit;
  With SA do
    begin
    family:=AF_INET;
    port:=htons(DNSport);
    addr:=cardinal(DNSServers[Resolver]); // dnsservers already in net order
    end;
  sendto(sock,qry,qrylen+12,0,SA,SizeOf(SA));
  // Wait for answer.
  RTO:=TimeOutS*1000+TimeOutMS;
  fpFD_ZERO(ReadFDS);
  fpFD_Set(sock,readfds);
  if fpSelect(Sock+1,@readfds,Nil,Nil,RTO)<=0 then
    begin
    fpclose(Sock);
    exit;
    end;
  AL:=SizeOf(SA);
  L:=recvfrom(Sock,ans,SizeOf(Ans),0,SA,AL);
  fpclose(Sock);
  // Check lenght answer and fields in header data.
  If (L<12) or not CheckAnswer(Qry,Ans) Then
    exit;
  // Return Payload length.  
  Anslen:=L-12;  
  Result:=True;  
end;

function stringfromlabel(pl: TPayLoad; start: integer): string;
var
  l,i: integer;
begin
  result := '';
  l := 0;
  i := 0;
  repeat
    l := ord(pl[start]);
    { compressed reply }
    while (l >= 192) do
      begin
        { the -12 is because of the reply header length }
        start := (l and not(192)) shl 8 + ord(pl[start+1]) - 12;
        l := ord(pl[start]);
      end;
    if l <> 0 then begin
      setlength(result,length(result)+l);
      move(pl[start+1],result[i+1],l);
      result := result + '.';
      inc(start,l); inc(start);
      inc(i,l); inc(i);
    end;
  until l = 0;
  if result[length(result)] = '.' then setlength(result,length(result)-1);
end;

Function ResolveNameAt(Resolver : Integer; HostName : String; Var Addresses : Array of THostAddr; Recurse: Integer) : Integer;

Var
  Qry, Ans            : TQueryData;
  MaxAnswer,I,QryLen,
  AnsLen,AnsStart     : Longint;
  RR                  : TRRData;
  cname               : string;
begin
  Result:=0;
  QryLen:=BuildPayLoad(Qry,HostName,DNSQRY_A,1);
  If Not Query(Resolver,Qry,Ans,QryLen,AnsLen) then
    Result:=-1
  else  
    begin
    AnsStart:=SkipAnsQueries(Ans,AnsLen);
    MaxAnswer:=Ans.AnCount-1;
    If MaxAnswer>High(Addresses) then
      MaxAnswer:=High(Addresses);
    I:=0;
    While (I<=MaxAnswer) and NextRR(Ans.Payload,AnsStart,AnsLen,RR) do
      begin
      if htons(rr.AClass) = 1 then
        case ntohs(rr.AType) of
          DNSQRY_A: begin
            Move(Ans.PayLoad[AnsStart],Addresses[i],SizeOf(THostAddr));
            inc(Result);
            Inc(AnsStart,htons(RR.RDLength));
          end;
          DNSQRY_CNAME: begin
            if Recurse >= MaxRecursion then begin
              Result := -1;
              exit;
            end;
            rr.rdlength := ntohs(rr.rdlength);
            setlength(cname, rr.rdlength);
            cname := stringfromlabel(ans.payload, ansstart);
            Result := ResolveNameAt(Resolver, cname, Addresses, Recurse+1);
            exit; // FIXME: what about other servers?!
          end;
        end;
        Inc(I);
      end;  
    end;
end;

Function ResolveName(HostName : String; Var Addresses : Array of THostAddr) : Integer;

Var
  I : Integer;

begin
  CheckResolveFile;
  I:=1;
  Result:=0;
  While (Result<=0) and (I<=DNSServerCount) do
    begin
    Result:=ResolveNameAt(I,HostName,Addresses,0);
    Inc(I);
    end;
end;

//const NoAddress6 : array[0..7] of word = (0,0,0,0,0,0,0,0);

Function ResolveNameAt6(Resolver : Integer; HostName : String; Var Addresses : Array of THostAddr6; Recurse: Integer) : Integer;
                                                                                                                                        
Var
  Qry, Ans            : TQueryData;
  MaxAnswer,I,QryLen,
  AnsLen,AnsStart     : Longint;
  RR                  : TRRData;
  cname               : string;
  LIP4mapped: array[0..MaxIP4Mapped-1] of THostAddr;
  LIP4count: Longint;
                                                                                                                                        
begin
  Result:=0;
  QryLen:=BuildPayLoad(Qry,HostName,DNSQRY_AAAA,1);
  If Not Query(Resolver,Qry,Ans,QryLen,AnsLen) then begin
    // no answer? try IPv4 mapped addresses, maybe that will generate one
    LIP4Count := ResolveName(HostName, LIP4Mapped);
    if LIP4Count > 0 then begin
      inc(LIP4Count); // we loop to LIP4Count-1 later
      if LIP4Count > MaxIP4Mapped then LIP4Count := MaxIP4Mapped;
      if LIP4Count > Length(Addresses) then LIP4Count := Length(Addresses);
      for i := 0 to LIP4Count-2 do begin
        Addresses[i] := NoAddress6;
        Addresses[i].u6_addr16[5] := $FFFF;
        Move(LIP4Mapped[i], Addresses[i].u6_addr16[6], 4);
      end;
      Result := LIP4Count;
    end else begin
      Result:=-1
    end;
  end else
    begin
    AnsStart:=SkipAnsQueries(Ans,AnsLen);
    MaxAnswer:=Ans.AnCount-1;
    If MaxAnswer>High(Addresses) then
      MaxAnswer:=High(Addresses);
    I:=0;
    While (I<=MaxAnswer) and NextRR(Ans.Payload,AnsStart,AnsLen,RR) do
      begin
      if (1=NtoHS(RR.AClass)) then
      case ntohs(rr.atype) of
        DNSQRY_AAAA: begin
            Move(Ans.PayLoad[AnsStart],Addresses[i],SizeOf(THostAddr6));
            inc(Result);
            rr.rdlength := ntohs(rr.rdlength);
            Inc(AnsStart,RR.RDLength);
          end;
        DNSQRY_CNAME: begin
          if Recurse >= MaxRecursion then begin
            Result := -1;
            exit;
          end;
          rr.rdlength := ntohs(rr.rdlength);
          setlength(cname, rr.rdlength);
          cname := stringfromlabel(ans.payload, ansstart);
          Result := ResolveNameAt6(Resolver, cname, Addresses, Recurse+1);
          exit; // FIXME: what about other servers?!
        end;
      end;
      Inc(I);
      end;
    end;
end;
                                                                                                                                        


Function ResolveName6(HostName: String; Var Addresses: Array of THostAddr6) : Integer;
var
  i: Integer;
begin
  CheckResolveFile;
  i := 1;
  Result := 0;
  while (Result <= 0) and (I<= DNSServerCount) do begin
    Result := ResolveNameAt6(I, Hostname, Addresses, 0);
    Inc(i);
  end;
end;

Function ResolveAddressAt(Resolver : Integer; Address : String; Var Names : Array of String) : Integer;


Var
  Qry, Ans            : TQueryData;
  MaxAnswer,I,QryLen,
  AnsLen,AnsStart     : Longint;
  RR                  : TRRData;

begin
  Result:=0;
  QryLen:=BuildPayLoad(Qry,Address,DNSQRY_PTR,1);
  If Not Query(Resolver,Qry,Ans,QryLen,AnsLen) then
    Result:=-1
  else  
    begin
    AnsStart:=SkipAnsQueries(Ans,AnsLen);
    MaxAnswer:=Ans.AnCount-1;
    If MaxAnswer>High(Names) then
      MaxAnswer:=High(Names);
    I:=0;
    While (I<=MaxAnswer) and NextRR(Ans.Payload,AnsStart,AnsLen,RR) do
      begin
      if (Ntohs(RR.AType)=DNSQRY_PTR) and (1=NtoHS(RR.AClass)) then
        begin
        Names[i]:=BuildName(Ans.Payload,AnsStart,AnsLen);
        inc(Result);
        RR.RDLength := ntohs(RR.RDLength);
        Inc(AnsStart,RR.RDLength);
        end;
      Inc(I);
      end;  
    end;
end;


Function ResolveAddress(HostAddr : THostAddr; Var Addresses : Array of String) : Integer;

Var
  I : Integer;
  S : String;
  nt : tnetaddr;
  
begin
  CheckResolveFile;
  I:=1;
  Result:=0;
  nt:=hosttonet(hostaddr);
  S:=Format('%d.%d.%d.%d.in-addr.arpa',[nt.s_bytes[4],nt.s_bytes[3],nt.s_bytes[2],nt.s_bytes[1]]);
  While (Result=0) and (I<=DNSServerCount) do
    begin
    Result:=ResolveAddressAt(I,S,Addresses);
    Inc(I);
    end;
end;

Function ResolveAddress6(HostAddr : THostAddr6; Var Addresses : Array of String) : Integer;

const
  hexdig: string[16] = '0123456789abcdef';
                                                                                
Var
  I : Integer;
  S : ShortString;
                                                                                
begin
  CheckResolveFile;
  Result:=0;
  S := '0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.int';
  for i := 7 downto 0 do begin
    S[5+(7-i)*8] := hexdig[1+(HostAddr.u6_addr16[i] and $000F) shr 00];
    S[7+(7-i)*8] := hexdig[1+(HostAddr.u6_addr16[i] and $00F0) shr 04];
    S[1+(7-i)*8] := hexdig[1+(HostAddr.u6_addr16[i] and $0F00) shr 08];
    S[3+(7-i)*8] := hexdig[1+(HostAddr.u6_addr16[i] and $F000) shr 12];
  end;
  I := 1;
  While (Result=0) and (I<=DNSServerCount) do
    begin
    Result:=ResolveAddressAt(I,S,Addresses);
    Inc(I);
    end;
end;

function IN6_IS_ADDR_V4MAPPED(HostAddr: THostAddr6): boolean;
begin
  Result := 
   (HostAddr.u6_addr16[0] = 0) and
   (HostAddr.u6_addr16[1] = 0) and
   (HostAddr.u6_addr16[2] = 0) and
   (HostAddr.u6_addr16[3] = 0) and
   (HostAddr.u6_addr16[4] = 0) and
   (HostAddr.u6_addr16[5] = $FFFF);
end;


Function ResolveHostByName(HostName : String; Var H : THostEntry) : Boolean;

Var
  Address : Array[1..MaxResolveAddr] of THostAddr;
  L : Integer;
  
begin
  L:=ResolveName(HostName,Address);
  Result:=(L>0);
  If Result then
    begin
    // We could add a reverse call here to get the real name and aliases.
    H.Name:=HostName;
    H.Addr:=Address[1];
    H.aliases:='';
    end;
end;

Function ResolveHostByAddr(HostAddr : THostAddr; Var H : THostEntry) : Boolean;

Var
  Names : Array[1..MaxResolveAddr] of String;
  I,L : Integer;
  
begin
  L:=ResolveAddress(HostAddr,Names);
  Result:=(L>0);
  If Result then
    begin
    H.Name:=Names[1];
    H.Addr:=HostAddr;
    H.Aliases:='';
    If (L>1) then
      For I:=2 to L do
        If (I=2) then
          H.Aliases:=Names[i]
        else  
          H.Aliases:=H.Aliases+','+Names[i];
    end;
end;

{ ---------------------------------------------------------------------
    Some Parsing routines
  ---------------------------------------------------------------------}

Const 
  Whitespace = [' ',#9];

Function NextWord(Var Line : String) : String;

Var 
  I,J : Integer;

begin
  I:=1;
  While (I<=Length(Line)) and (Line[i] in Whitespace) do
    inc(I);
  J:=I;
  While (J<=Length(Line)) and Not (Line[J] in WhiteSpace) do
    inc(j);
  Result:=Copy(Line,I,J-I);  
  Delete(Line,1,J);  
end;
  
Procedure StripComment(Var line : String);

Var
  P : Integer;

begin
  P:=Pos('#',Line);
  If (P<>0) then
    Line:=Trim(Copy(Line,1,P-1));
end;

Function MatchNameOrAlias(Const Entry,Name: String; Aliases : String) : Boolean;

Var
  P : Integer;
  A : String;

begin
  Result:=CompareText(Entry,Name)=0;
  If Not Result then
    While (Not Result) and (Length(Aliases)>0) do
      begin
      P:=Pos(',',Aliases);
      If (P=0) then
        P:=Length(Aliases)+1;
      A:=Copy(Aliases,1,P-1);
      Delete(Aliases,1,P);
      Result:=CompareText(A,Entry)=0;
      end;
end;

{ ---------------------------------------------------------------------
    /etc/hosts handling.
  ---------------------------------------------------------------------}

Function GetNextHostEntry(var F : Text; Var H : THostEntry): boolean;

Var
  Line,S : String;
  
begin
  Result:=False;
  Repeat
    ReadLn(F,Line);
    StripComment(Line);
    S:=NextWord(Line);
    If (S<>'') then
      begin
      H.Addr:=StrTonetAddr(S);		// endianness problem here. (fixed)
      if (H.Addr.s_bytes[1]<>0) then
        begin
        S:=NextWord(Line);
        If (S<>'') then
          begin
          H.Name:=S;
          Result:=True;
          H.Aliases:='';
          Repeat
            S:=NextWord(line);
            If (S<>'') then
              If (H.Aliases='') then
                H.Aliases:=S
              else
                H.Aliases:=H.Aliases+','+S;  
          until (S='');
          end;
        end;      
      end;
  until Result or EOF(F);
end;  

Function FindHostEntryInHostsFile(N: String; Addr: THostAddr; Var H : THostEntry) : boolean;

Var
  F : Text;
  HE : THostEntry;
  
begin
  Result:=False;
  If FileExists(SHostsFile) then
    begin
    Assign(F,SHostsFile);
    {$i-}
    Reset(F);
    {$i+}
    If (IOResult=0) then
      begin
      While Not Result and GetNextHostEntry(F,HE) do
        begin
        If (N<>'') then
          Result:=MatchNameOrAlias(N,HE.Name,HE.Aliases)
        else
          Result:=Cardinal(hosttonet(Addr))=Cardinal(HE.Addr);
        end; 
      Close(f);
      If Result then
        begin
        H.Name:=HE.Name;
        H.Addr:=nettohost(HE.Addr);
        H.Aliases:=HE.Aliases;
        end;
      end;  
    end;
end;

//const NoAddress : in_addr = (s_addr: 0);

Function GetHostByName(HostName: String;  Var H : THostEntry) : boolean;

begin
  Result:=FindHostEntryInHostsFile(HostName,NoAddress,H);
end;


Function GetHostByAddr(Addr: THostAddr;  Var H : THostEntry) : boolean;

begin
  Result:=FindHostEntryInHostsFile('',Addr,H);
end;

{ ---------------------------------------------------------------------
    /etc/protocols handling.
  ---------------------------------------------------------------------}

Function GetNextProtoEntry(var F : Text; Var H : TProtocolEntry): boolean;

Var
  Line,S : String;
  I      : integer;
  
begin
  Result:=False;
  Repeat
    ReadLn(F,Line);
    StripComment(Line);
    S:=NextWord(Line);
    If (S<>'') then
      begin
        H.Name:=S;	
        S:=NextWord(Line);
	i:=strtointdef(s,-1);
        If (i<>-1) then
          begin
          H.number:=i;
          Result:=True;
          H.Aliases:='';
          Repeat
            S:=NextWord(line);
            If (S<>'') then
              If (H.Aliases='') then
                H.Aliases:=S
              else
                H.Aliases:=H.Aliases+','+S;  
          until (S='');
          end;
      end;
  until Result or EOF(F);
end;  

Function FindProtoEntryInProtoFile(N: String; prot: integer; Var H : TProtocolEntry) : boolean;

Var
  F : Text;
  HE : TProtocolEntry;
  
begin
  Result:=False;
  If FileExists(SProtocolFile) then
    begin
    Assign(F,SProtocolFile);
    {$i-}
    Reset(F);
    {$i+}
    If (IOResult=0) then
      begin
      While Not Result and GetNextProtoEntry(F,HE) do
        begin
        If (N<>'') then
          Result:=MatchNameOrAlias(N,HE.Name,HE.Aliases)
        else
          Result:=prot=he.number;
        end; 
      Close(f);
      If Result then
        begin
        H.Name:=HE.Name;
        H.number:=he.number;
        H.Aliases:=HE.Aliases;
        end;
      end;  
    end;
end;

Function GetProtocolByName(ProtoName: String;  Var H : TProtocolEntry) : boolean;

begin
  Result:=FindProtoEntryInProtoFile(ProtoName,0,H);
end;


Function GetProtocolByNumber(proto: Integer;  Var H : TProtocolEntry) : boolean;

begin
  Result:=FindProtoEntryInProtoFile('',Proto,H);
end;

{ ---------------------------------------------------------------------
    /etc/networks handling
  ---------------------------------------------------------------------}

function StrTonetpartial( IP : AnsiString) : in_addr ;

Var
    Dummy : AnsiString;
    I,j,k     : Longint;
    Temp : in_addr;

begin
  strtonetpartial.s_addr:=0;              //:=NoAddress;
  i:=0; j:=0;
  while (i<4) and (j=0) do
   begin
     J:=Pos('.',IP);
     if j=0 then j:=length(ip)+1;
     Dummy:=Copy(IP,1,J-1);
     Delete (IP,1,J);
     Val (Dummy,k,J);
     if j=0 then
      strtonetpartial.s_bytes[i+1]:=k;
     inc(i);
   end;
   if (i=0) then strtonetpartial.s_addr:=0;
end;

Function GetNextNetworkEntry(var F : Text; Var N : TNetworkEntry): boolean;

Var
  NN,Line,S : String;
  A : TNetAddr;
  
begin
  Result:=False;
  Repeat
    ReadLn(F,Line);
    StripComment(Line);
    S:=NextWord(Line);
    If (S<>'') then
      begin
      NN:=S;
      A:=StrTonetpartial(NextWord(Line));
      Result:=(NN<>'') and (A.s_bytes[1]<>0); // Valid addr.
      If result then
        begin
        N.Addr.s_addr:=A.s_addr; // keep it host.
        N.Name:=NN;
        N.Aliases:='';
        end;      
      end;
  until Result or EOF(F);
end;  

Function FindNetworkEntryInNetworksFile(Net: String; Addr: TNetAddr; Var N : TNetworkEntry) : boolean;

Var
  F : Text;
  NE : TNetworkEntry;
  
begin
  Result:=False;
  If FileExists(SNetworksFile) then
    begin
    Assign(F,SNetworksFile);
    {$i-}
    Reset(F);
    {$i+}
    If (IOResult=0) then
      begin
      While Not Result and GetNextNetworkEntry(F,NE) do
        begin
        If (Net<>'') then
          Result:=MatchNameOrAlias(Net,NE.Name,NE.Aliases)
        else
          Result:=Cardinal(Addr)=Cardinal(NE.Addr);
        end; 
      Close(f);
      If Result then
        begin
        N.Name:=NE.Name;
        N.Addr:=nettohost(NE.Addr);
        N.Aliases:=NE.Aliases;
        end;
      end;  
    end;
end;

Const NoNet : in_addr = (s_addr:0);
  
Function GetNetworkByName(NetName: String; Var N : TNetworkEntry) : boolean;

begin
  Result:=FindNetworkEntryInNetworksFile(NetName,NoNet,N);
end;

Function GetNetworkByAddr(Addr: THostAddr; Var N : TNetworkEntry) : boolean;

begin
  Result:=FindNetworkEntryInNetworksFile('',Addr,N);
end;

{ ---------------------------------------------------------------------
    /etc/services section
  ---------------------------------------------------------------------}

Function GetNextServiceEntry(Var F : Text; Var E : TServiceEntry) : Boolean;


Var
  Line,S : String;
  P : INteger;
  
begin
  Result:=False;
  Repeat
    ReadLn(F,Line);
    StripComment(Line);
    S:=NextWord(Line);
    If (S<>'') then
      begin
      E.Name:=S;
      S:=NextWord(Line);
      P:=Pos('/',S);
      If (P<>0) then
        begin
        E.Port:=StrToIntDef(Copy(S,1,P-1),0);
        If (E.Port<>0) then
          begin
          E.Protocol:=Copy(S,P+1,Length(S)-P);
          Result:=length(E.Protocol)>0;
          E.Aliases:='';
          Repeat
            S:=NextWord(Line);
            If (S<>'') then
              If (Length(E.Aliases)=0) then
                E.aliases:=S
              else  
                E.Aliases:=E.Aliases+','+S;
          until (S='');
          end;
        end;
      end;
  until Result or EOF(F);
end;


Function FindServiceEntryInFile(Const Name,Proto : String; Port : Integer; Var E : TServiceEntry) : Boolean;

Var
  F : Text;
  TE : TServiceEntry;
  
begin
  Result:=False;
  If FileExists(SServicesFile) then
    begin
    Assign(F,SServicesFile);
    {$i-}
    Reset(F);
    {$i+}
    If (IOResult=0) then
      begin
      While Not Result and GetNextServiceEntry(F,TE) do
        begin
        If (Port=-1) then
          Result:=MatchNameOrAlias(Name,TE.Name,TE.Aliases)
        else 
          Result:=(Port=TE.Port);
        If Result and (Proto<>'') then
          Result:=(Proto=TE.Protocol);
        end; 
      Close(f);
      If Result then
        begin
        E.Name:=TE.Name;
        E.Port:=TE.Port;
        E.Protocol:=TE.Protocol;
        E.Aliases:=TE.Aliases;
        end;
      end;  
    end;
end;

Function GetServiceByName(Const Name,Proto : String; Var E : TServiceEntry) : Boolean;

begin
  Result:=FindServiceEntryInFile(Name,Proto,-1,E);  
end;

Function GetServiceByPort(Port : Word;Const Proto : String; Var E : TServiceEntry) : Boolean;

begin
  Result:=FindServiceEntryInFile('',Proto,Port,E);  
end;

{ ---------------------------------------------------------------------
    Initialization section
  ---------------------------------------------------------------------}

Procedure InitResolver;

Var
  I : Integer;

begin
  TimeOutS :=5;
  TimeOutMS:=0;
  CheckResolveFileAge:=False;
  If FileExists(SResolveFile) then
    GetDNsservers(SResolveFile);
end;

begin
  InitResolver;
end.
