{
    $Id: header,v 1.1 2000/07/13 06:33:45 michael Exp $
    This file is part of the Free Component Library (FCL)
    Copyright (c) 1999-2000 by the Free Pascal development team

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$mode objfpc}
{$H+}
unit fpapache;

interface

uses
  SysUtils,Classes,CustWeb,httpDefs,fpHTTP,httpd, apr, SyncObjs;

Type

  TCustomApacheApplication = Class;

  { TApacheRequest }

  TApacheRequest = Class(TRequest)
  Private
    FApache : TCustomApacheApplication;
    FRequest : PRequest_rec;
  Protected
    Function GetFieldValue(Index : Integer) : String; override;
    Procedure InitFromRequest;
    procedure ReadContent; override;
  Public
    Constructor CreateReq(App : TCustomApacheApplication; ARequest : PRequest_rec);
    Property ApacheRequest : Prequest_rec Read FRequest;
    Property ApacheApp : TCustomApacheApplication Read FApache;
  end;

  { TApacheResponse }

  TApacheResponse = Class(TResponse)
  private
    FApache : TCustomApacheApplication;
    FRequest : PRequest_rec;
    procedure SendStream(S: TStream);
  Protected
    Procedure DoSendHeaders(Headers : TStrings); override;
    Procedure DoSendContent; override;
  Public
    Constructor CreateApache(Req : TApacheRequest);
    Property ApacheRequest : Prequest_rec Read FRequest;
    Property ApacheApp : TCustomApacheApplication Read FApache;
  end;

  { TCustomApacheApplication }
  THandlerPriority = (hpFirst,hpMiddle,hpLast);
  TBeforeRequestEvent = Procedure(Sender : TObject; Const AHandler : String;
                                  Var AllowRequest : Boolean) of object;

  TCustomApacheApplication = Class(TCustomWebApplication)
  private
    FMaxRequests: Integer;             //Maximum number of simultaneous web module requests (default=64, if set to zero no limit)
    FWorkingWebModules: TList;         //List of currently running web modules handling requests
    FIdleWebModules: TList;            //List of idle web modules available
    FCriticalSection: TCriticalSection;
    FBaseLocation: String;
    FBeforeRequest: TBeforeRequestEvent;
    FHandlerName: String;
    FModuleName: String;
    FModules : Array[0..1] of TStrings;
    FPriority: THandlerPriority;
    FModuleRecord : PModule;
    function GetModules(Index: integer): TStrings;
    procedure SetModules(Index: integer; const AValue: TStrings);
    function GetIdleModuleCount : Integer;
    function GetWorkingModuleCount : Integer;
  Protected
    Function ProcessRequest(P : PRequest_Rec) : Integer; virtual;
    Procedure DoRun; override;
    function WaitForRequest(out ARequest : TRequest; out AResponse : TResponse) : boolean; override;
    Function AllowRequest(P : PRequest_Rec) : Boolean; virtual;
  Public
    Constructor Create(AOwner : TComponent); override;
    Destructor Destroy; override;
    Procedure SetModuleRecord(Var ModuleRecord : Module);
    Procedure Initialize; override;
    Procedure ShowException(E : Exception); override;
    Procedure LogErrorMessage(Msg : String; LogLevel : integer = APLOG_INFO); virtual;
    Procedure handleRequest(ARequest : TRequest; AResponse : TResponse); override;
    Property HandlerPriority : THandlerPriority Read FPriority Write FPriority default hpMiddle;
    Property BeforeModules : TStrings Index 0 Read GetModules Write SetModules;
    Property AfterModules : TStrings Index 1 Read GetModules Write SetModules;
    Property BaseLocation : String Read FBaseLocation Write FBaseLocation;
    Property ModuleName : String Read FModuleName Write FModuleName;
    Property HandlerName : String Read FHandlerName Write FHandlerName;
    Property BeforeRequest : TBeforeRequestEvent Read FBeforeRequest Write FBeforeRequest;
    Property MaxRequests: Integer read FMaxRequests write FMaxRequests;
    Property IdleWebModuleCount: Integer read GetIdleModuleCount;
    Property WorkingWebModuleCount: Integer read GetWorkingModuleCount;
  end;

  TApacheApplication = Class(TCustomApacheApplication)
  Public
    Property HandlerPriority;
    Property BeforeModules;
    Property AfterModules;
    Property AllowDefaultModule;
    Property OnGetModule;
    Property BaseLocation;
    Property ModuleName;
    Property MaxRequests;
    Property IdleWebModuleCount;
    Property WorkingWebModuleCount;
  end;
  

  EFPApacheError = Class(Exception);
  
Var
  Application : TCustomApacheApplication = Nil;
  ShowCleanUpErrors : Boolean = False;
  AlternateHandler : ap_hook_handler_t = Nil;

Implementation
uses ctypes;

resourcestring
  SErrNoModuleNameForRequest = 'Could not determine HTTP module name for request';
  SErrNoModuleForRequest = 'Could not determine HTTP module for request "%s"';
  SErrNoModuleRecord = 'No module record location set.';
  SErrNoModuleName = 'No module name set';
  SErrTooManyRequests = 'Too many simultaneous requests.';

const
  HPRIO : Array[THandlerPriority] of Integer
        = (APR_HOOK_FIRST,APR_HOOK_MIDDLE,APR_HOOK_LAST);


Procedure InitApache;

begin
  Application:=TCustomApacheApplication.Create(Nil);
end;

Procedure DoneApache;

begin
  Try
    FreeAndNil(Application);
  except
    if ShowCleanUpErrors then
      Raise;
  end;
end;

Function DefaultApacheHandler(P : PRequest_Rec) : integer;cdecl;

begin
  If (AlternateHandler<>Nil) then
    Result:=AlternateHandler(P)
  else
    If Application.AllowRequest(P) then
      Result:=Application.ProcessRequest(P)
    else
      Result:=DECLINED;
end;

Procedure RegisterApacheHooks(P: PApr_pool_t);cdecl;

Var
  H : ap_hook_handler_t;
  PP1,PP2 : PPChar;

begin
  H:=AlternateHandler;
  If (H=Nil) then
    H:=@DefaultApacheHandler;
  PP1:=Nil;
  PP2:=Nil;
  ap_hook_handler(H,PP1,PP2,HPRIO[Application.HandlerPriority]);
end;

{ TCustomApacheApplication }

function TCustomApacheApplication.GetModules(Index: integer): TStrings;
begin
  If (FModules[Index]=Nil) then
    FModules[Index]:=TStringList.Create;
  Result:=FModules[Index];
end;

procedure TCustomApacheApplication.SetModules(Index: integer;
  const AValue: TStrings);
begin
  If (FModules[Index]=Nil) then
    FModules[Index]:=TStringList.Create;
  FModules[Index].Assign(AValue);
end;

Function TCustomApacheApplication.ProcessRequest(P: PRequest_Rec) : Integer;

Var
  Req : TApacheRequest;
  Resp : TApacheResponse;

begin
LogErrorMessage('Test 1',3);
  Req:=TApacheRequest.CreateReq(Self,P);
  Try
    Req.InitRequestVars;
    Resp:=TApacheResponse.CreateApache(Req);
    Try
LogErrorMessage('Test 2',3);
      HandleRequest(Req,Resp);
LogErrorMessage('Test 3',3);
      If Not Resp.ContentSent then
        Resp.SendContent;
    Finally
      Result:=OK;
      Resp.Free;
    end;
  Finally
    Req.Free;
  end;
end;

procedure TCustomApacheApplication.DoRun;
begin
  // Do nothing. This is a library
end;

function TCustomApacheApplication.WaitForRequest(out ARequest: TRequest;
  out AResponse: TResponse): boolean;
begin
  // Do nothing. Requests are triggered by Apache
end;

function TCustomApacheApplication.AllowRequest(P: PRequest_Rec): Boolean;

Var
  Hn : String;

begin
  HN:=StrPas(p^.Handler);
  Result:=CompareText(HN,FHandlerName)=0;
  If Assigned(FBeforeRequest) then
    FBeforeRequest(Self,HN,Result);
end;

constructor TCustomApacheApplication.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPriority:=hpMiddle;
  FMaxRequests:=64;
  FWorkingWebModules:=TList.Create;
  FIdleWebModules:=TList.Create;
  FCriticalSection:=TCriticalSection.Create;
end;

destructor TCustomApacheApplication.Destroy;
var I:Integer;
begin
  FCriticalSection.Free;
  for I := FIdleWebModules.Count - 1 downto 0 do
    TComponent(FIdleWebModules[I]).Free;
  FIdleWebModules.Free;
  for I := FWorkingWebModules.Count - 1 downto 0 do
    TComponent(FWorkingWebModules[I]).Free;
  FWorkingWebModules.Free;
  inherited Destroy;
end;


procedure TCustomApacheApplication.SetModuleRecord(var ModuleRecord: Module);
begin
  FModuleRecord:=@ModuleRecord;
  FillChar(ModuleRecord,SizeOf(ModuleRecord),0);
end;

procedure TCustomApacheApplication.Initialize;

begin
  If (FModuleRecord=nil) then
    Raise EFPApacheError.Create(SErrNoModuleRecord);
  if (FModuleName='') and (FModuleRecord^.Name=Nil) then
    Raise EFPApacheError.Create(SErrNoModuleName);
  STANDARD20_MODULE_STUFF(FModuleRecord^);
  If (StrPas(FModuleRecord^.name)<>FModuleName) then
    FModuleRecord^.Name:=PChar(FModuleName);
  FModuleRecord^.register_hooks:=@RegisterApacheHooks;
end;

procedure TCustomApacheApplication.ShowException(E: Exception);
begin
  ap_log_error(pchar(FModuleName),0,APLOG_ERR,0,Nil,'module: %s',[Pchar(E.Message)]);
end;

procedure TCustomApacheApplication.LogErrorMessage(Msg: String;
  LogLevel: integer);
begin
  ap_log_error(pchar(FModuleName),0,LogLevel,0,Nil,'module: %s',[pchar(Msg)]);
end;

function TCustomApacheApplication.GetIdleModuleCount : Integer;
begin
  FCriticalSection.Enter;
  try
    Result := FIdleWebModules.Count;
  finally
    FCriticalSection.Leave;
  end;
end;

function TCustomApacheApplication.GetWorkingModuleCount : Integer;
begin
  FCriticalSection.Enter;
  try
    Result := FWorkingWebModules.Count;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TCustomApacheApplication.HandleRequest(ARequest: TRequest; AResponse: TResponse);

Var
  MC : TCustomHTTPModuleClass;
  M  : TCustomHTTPModule;
  MN : String;
  MI : TModuleItem;

  Procedure GetAWebModule;
  Var II:Integer;
  begin
    FCriticalSection.Enter;
LogErrorMessage('Test I',3);
    try
      if (FMaxRequests>0) and (FWorkingWebModules.Count>=FMaxRequests) then
        Raise EFPApacheError.Create(SErrTooManyRequests);
LogErrorMessage('Test II',3);
      if (FIdleWebModules.Count>0) then
      begin
        II := FIdleWebModules.Count - 1;
        while (II>=0) and not (TComponent(FIdleWebModules[II]) is MC) do
          Dec(II);
        if (II>=0) then
        begin
          M:=TCustomHTTPModule(FIdleWebModules[II]);
          FIdleWebModules.Delete(II);
        end;
      end;
LogErrorMessage('Test III',3);
      if (M=nil) then
      begin
LogErrorMessage('Test IV',3);
if assigned(mc) then LogErrorMessage('Test ---',3);
        M:=MC.Create(Self);
LogErrorMessage('Test V',3);
        M.Name := '';
      end;
LogErrorMessage('Test VI',3);
      FWorkingWebModules.Add(M);
    finally
      FCriticalSection.Leave;
    end;
LogErrorMessage('Test VII',3);
  end;

begin
LogErrorMessage('Test a',3);
  try
    MC:=Nil;
    M := Nil;
    If (OnGetModule<>Nil) then
      OnGetModule(Self,ARequest,MC);
    If (MC=Nil) then
    begin
      MN:=GetModuleName(ARequest);
      If (MN='') and Not AllowDefaultModule then
        Raise EFPApacheError.Create(SErrNoModuleNameForRequest);
      MI:=ModuleFactory.FindModule(MN);
      If (MI=Nil) and (ModuleFactory.Count=1) then
        MI:=ModuleFactory[0];
      if (MI=Nil) then
        Raise EFPApacheError.CreateFmt(SErrNoModuleForRequest,[MN]);

      MC:=MI.ModuleClass;
    end;
LogErrorMessage('Test b',3);
    GetAWebModule;
LogErrorMessage('Test c',3);
    M.HandleRequest(ARequest,AResponse);
LogErrorMessage('Test d',3);

    FCriticalSection.Enter;
    try
      FWorkingWebModules.Remove(M);
      FIdleWebModules.Add(M);
    finally
      FCriticalSection.Leave;
    end;
  except
    On E : Exception do
      begin
      ShowException(E);
      ShowRequestException(AResponse,E);
      end;
  end;
LogErrorMessage('Test e',3);
end;

{ TApacheRequest }

function TApacheRequest.GetFieldValue(Index: Integer): String;

var
  P : Pchar;
  FN : String;
  I : Integer;
  
begin
  Result:='';
  If (Index in [1..NoHTTPFields]) then
    begin
    FN:=HTTPFieldNames[Index];
    P:=apr_table_get(FRequest^.headers_in,pchar(FN));
    If (P<>Nil) then
      Result:=StrPas(P);
    end;
  if (Result='') then
    case Index of
      0  : Result:=strpas(FRequest^.protocol); // ProtocolVersion
      7  : Result:=Strpas(FRequest^.content_encoding); //ContentEncoding
      25 : Result:=StrPas(FRequest^.path_info); // PathInfo
      26 : Result:=StrPas(FRequest^.filename); // PathTranslated
      27 : // RemoteAddr
           If (FRequest^.Connection<>Nil) then
             Result:=StrPas(FRequest^.Connection^.remote_ip);
      28 : // RemoteHost
           If (FRequest^.Connection<>Nil) then
             Result:=StrPas(ap_get_remote_host(FRequest^.Connection,
                                FRequest^.Per_Dir_Config,
                                REMOTE_HOST,Nil));
      29 : begin // ScriptName
           Result:=StrPas(FRequest^.unparsed_uri);
           I:=Pos('?',Result)-1;
           If (I=-1) then
             I:=Length(Result);
           Result:=Copy(Result,1,I-Length(PathInfo));
           end;
      30 : Result:=IntToStr(ap_get_server_port(FRequest)); // ServerPort
      31 : Result:=StrPas(FRequest^.method); // Method
      32 : Result:=StrPas(FRequest^.unparsed_uri); // URL
      33 : Result:=StrPas(FRequest^.args); // Query
      34 : Result:=StrPas(FRequest^.HostName); // Host
    else
      Result:=inherited GetFieldValue(Index);
    end;
end;

procedure TApacheRequest.ReadContent;

  Function MinS(A,B : Integer) : Integer;
  
  begin
    If A<B then
      Result:=A
    else
      Result:=B;
  end;

Var
  Left,Len,Count,Bytes : Integer;
  P : Pchar;
  
begin
  ap_setup_client_block(FRequest,REQUEST_CHUNKED_DECHUNK);
  If (ap_should_client_block(FRequest)=1) then
    begin
    Len:=ContentLength;
    If (Len>0) then
      begin
      SetLength(FContent,Len);
      P:=PChar(FContent);
      Left:=Len;
      Count:=0;
      Repeat
        Bytes:=ap_get_client_block(FRequest,P,MinS(10*1024,Left));
        Dec(Left,Bytes);
        Inc(P,Bytes);
        Inc(Count,Bytes);
      Until (Count>=Len) or (Bytes=0);
      SetLength(FContent,Count);
      end;
    end;
  FContentRead:=True;
end;

procedure TApacheRequest.InitFromRequest;
begin
  ParseCookies;
end;

Constructor TApacheRequest.CreateReq(App : TCustomApacheApplication; ARequest : PRequest_rec);

begin
  FApache:=App;
  FRequest:=Arequest;
  ReturnedPathInfo:=App.BaseLocation;
  Inherited Create;
  InitFromRequest;
end;

{ TApacheResponse }

procedure TApacheResponse.DoSendHeaders(Headers: TStrings);

Var
  I,P : Integer;
  N,V : String;

begin
  For I:=0 to Headers.Count-1 do
    begin
    V:=Headers[i];
    P:=Pos(':',V);
    If (P<>0) and (P<Length(V)) then
      begin
      N:=Copy(V,1,P-1);
      System.Delete(V,1,P);
      V := Trim(V);//no need space before the value, apache puts it there
      apr_table_set(FRequest^.headers_out,Pchar(N),Pchar(V));
      end;
    end;
end;

procedure TApacheResponse.DoSendContent;

Var
  S : String;
  I : Integer;

begin
  S:=ContentType;
  If (S<>'') then
    FRequest^.content_type:=apr_pstrdup(FRequest^.pool,Pchar(S));
  S:=ContentEncoding;
  If (S<>'') then
    FRequest^.content_encoding:=apr_pstrdup(FRequest^.pool,Pchar(S));
  If Code <> 200 then
    FRequest^.status := Code;
  If assigned(ContentStream) then
    SendStream(Contentstream)
  else
    for I:=0 to Contents.Count-1 do
      begin
      S:=Contents[i]+LineEnding;
      // If there is a null, it's written also with ap_rwrite
      ap_rwrite(PChar(S),Length(S),FRequest);
      end;
end;

Procedure TApacheResponse.SendStream(S : TStream);

Var
  Buf : Array[0..(10*1024)-1] of Byte;
  Count : Integer;

begin
  S.Seek(0,soBeginning);
  Repeat
    Count:=S.Read(Buf,SizeOf(Buf));
    If Count>0 then
      ap_rwrite(@Buf,Count,FRequest);
  Until (Count=0);
end;


Constructor TApacheResponse.CreateApache(Req : TApacheRequest);
begin
  FApache:=Req.ApacheApp;
  Frequest:=Req.ApacheRequest;
  Inherited Create(Req);
end;

function __dummythread(p: pointer): ptrint;
begin
//empty
end;

Initialization
//  BeginThread(@__dummythread);//crash prevention for simultaneous requests
  sleep(300);

  InitApache;
  
Finalization
  DoneApache;
  
end.
