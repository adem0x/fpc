{
    This file is part of the Free Component library.
    Copyright (c) 2005 by Michael Van Canneyt, member of
    the Free Pascal development team

    Unit implementing one-way IPC between 2 processes

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit simpleipc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

Const
  MsgVersion = 1;
  
Type

  TMessageType = (mtUnknown,mtString); // For now
  TMsgHeader = Packed record
    Version : Byte;
    msgType : TMessageType;
    MsgLen  : Integer;
  end;

  TSimpleIPCServer = class;
  TSimpleIPCClient = class;

  { TIPCServerComm }
  
  TIPCServerComm = Class(TObject)
  Private
    FOwner  : TSimpleIPCServer;
  Public
    Constructor Create(AOwner : TSimpleIPCServer); virtual;
    Property Owner : TSimpleIPCServer read FOwner;
    Procedure StartServer; virtual; Abstract;
    Procedure StopServer;virtual; Abstract;
    Function  PeekMessage(TimeOut : Integer) : Boolean;virtual; Abstract;
    Function  GetInstanceID : String; virtual; abstract;
    Procedure ReadMessage ;virtual; Abstract;
    Property InstanceID : String read GetInstanceID;
  end;
  TIPCServerCommClass = Class of TIPCServerComm;

  { TSimpleIPC }
  TSimpleIPC = Class(TComponent)
  Private
    procedure SetActive(const AValue: Boolean);
    procedure SetServerID(const AValue: String);
  Protected
    FBusy: Boolean;
    FActive : Boolean;
    FServerID : String;
    Procedure DoError(Msg : String; Args : Array of const);
    Procedure CheckInactive;
    Procedure CheckActive;
    Procedure Activate; virtual; abstract;
    Procedure Deactivate; virtual; abstract;
    Property Busy : Boolean Read FBusy;
  Published
    Property Active : Boolean Read FActive Write SetActive;
    Property ServerID : String Read FServerID Write SetServerID;
  end;

  { TSimpleIPCServer }

  TSimpleIPCServer = Class(TSimpleIPC)
  private
    FGlobal: Boolean;
    FOnMessage: TNotifyEvent;
    FMsgData : TStream;
    function GetInstanceID: String;
    function GetStringMessage: String;
    procedure SetGlobal(const AValue: Boolean);
  Protected
    FIPCComm: TIPCServerComm;
    Function CommClass : TIPCServerCommClass; virtual;
    Procedure Activate; override;
    Procedure Deactivate; override;
    Procedure ReadMessage;
  Public
    Constructor Create(AOwner : TComponent); override;
    Destructor destroy; override;
    Procedure StartServer;
    Procedure StopServer;
    Function PeekMessage(TimeOut : Integer; DoReadMessage : Boolean): Boolean;
    Property  StringMessage : String Read GetStringMessage;
    Procedure GetMessageData(Stream : TStream);
    Property  MsgData : TStream Read FMsgData;
    Property  InstanceID : String Read GetInstanceID;
  Published
    Property Global : Boolean Read FGlobal Write SetGlobal;
    Property OnMessage : TNotifyEvent Read FOnMessage Write FOnMessage;
  end;


  { TIPCClientComm}
  TIPCClientComm = Class(TObject)
  private
    FOwner: TSimpleIPCClient;
  Public
    Constructor Create(AOwner : TSimpleIPCClient); virtual;
    Property  Owner : TSimpleIPCClient read FOwner;
    Procedure Connect; virtual; abstract;
    Procedure Disconnect; virtual; abstract;
    Function  ServerRunning : Boolean; virtual; abstract;
    Procedure SendMessage(MsgType : TMessageType; Stream : TStream);virtual;Abstract;
  end;
  TIPCClientCommClass = Class of TIPCClientComm;
  
  { TSimpleIPCClient }
  TSimpleIPCClient = Class(TSimpleIPC)
  Private
    FServerInstance: String;
    procedure SetServerInstance(const AValue: String);
  Protected
    FIPCComm : TIPCClientComm;
    Procedure Activate; override;
    Procedure Deactivate; override;
    Function CommClass : TIPCClientCommClass; virtual;
  Public
    Constructor Create(AOwner : TComponent); override;
    Destructor destroy; override;
    Procedure Connect;
    Procedure Disconnect;
    Function  ServerRunning : Boolean;
    Procedure SendMessage(MsgType : TMessageType; Stream: TStream);
    Procedure SendStringMessage(Msg : String);
    Procedure SendStringmessageFmt(Msg : String; Args : Array of const);
    Property  ServerInstance : String Read FServerInstance Write SetServerInstance;
  end;


  EIPCError = Class(Exception);

Var
  DefaultIPCServerClass : TIPCServerCommClass = Nil;
  DefaultIPCClientClass : TIPCClientCommClass = Nil;

resourcestring
  SErrServerNotActive = 'Server with ID %s is not active.';
  SErrActive = 'This operation is illegal when the server is active.';
  SErrInActive = 'This operation is illegal when the server is inactive.';


implementation

{ ---------------------------------------------------------------------
  Include platform specific implementation. 
  Should implement the CommClass method of both server and client component, 
  as well as the communication class itself.
  
  This comes first, to allow the uses clause to be set.
  --------------------------------------------------------------------- }

{$i simpleipc.inc}

{ ---------------------------------------------------------------------
    TIPCServerComm
  ---------------------------------------------------------------------}

constructor TIPCServerComm.Create(AOwner: TSimpleIPCServer);
begin
  FOwner:=AOWner;
end;

{ ---------------------------------------------------------------------
    TIPCClientComm
  ---------------------------------------------------------------------}
  
constructor TIPCClientComm.Create(AOwner: TSimpleIPCClient);
begin
  FOwner:=AOwner;
end;

{ ---------------------------------------------------------------------
    TSimpleIPC
  ---------------------------------------------------------------------}

procedure TSimpleIPC.DoError(Msg: String; Args: array of const);
begin
  Raise EIPCError.Create(Name+': '+Format(Msg,Args));
end;

procedure TSimpleIPC.CheckInactive;
begin
  If Active then
    DoError(SErrActive,[]);
end;

procedure TSimpleIPC.CheckActive;
begin
  If Not Active then
    DoError(SErrInActive,[]);
end;

procedure TSimpleIPC.SetActive(const AValue: Boolean);
begin
  if (FActive<>AValue) then
    begin
    If AValue then
      Activate
    else
      Deactivate;
    end;
end;

procedure TSimpleIPC.SetServerID(const AValue: String);
begin
  if (FServerID<>AValue) then
    begin
    CheckInactive;
    FServerID:=AValue
    end;
end;

{ ---------------------------------------------------------------------
    TSimpleIPCServer
  ---------------------------------------------------------------------}

constructor TSimpleIPCServer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGlobal:=False;
  FActive:=False;
  FBusy:=False;
  FMsgData:=TStringStream.Create('');
end;

destructor TSimpleIPCServer.destroy;
begin
  Active:=False;
  inherited destroy;
end;

procedure TSimpleIPCServer.SetGlobal(const AValue: Boolean);
begin
  if (FGlobal<>AValue) then
    begin
    CheckInactive;
    FGlobal:=AValue;
    end;
end;

function TSimpleIPCServer.GetInstanceID: String;
begin
  Result:=FIPCComm.InstanceID;
end;


function TSimpleIPCServer.GetStringMessage: String;
begin
  Result:=TStringStream(FMsgData).DataString;
end;


procedure TSimpleIPCServer.StartServer;
begin
  If (FServerID='') then
    FServerID:=ApplicationName;
  FIPCComm:=CommClass.Create(Self);
  FIPCComm.StartServer;
  FActive:=True;
end;

procedure TSimpleIPCServer.StopServer;
begin
  FIPCComm.StopServer;
  FreeAndNil(FIPCComm);
  FActive:=False;
end;

function TSimpleIPCServer.PeekMessage(TimeOut: Integer; DoReadMessage: Boolean
  ): Boolean;
begin
  CheckActive;
  FBusy:=True;
  Try
    Result:=FIPCComm.PeekMessage(Timeout);
  Finally
    FBusy:=False;
  end;
  If Result then
    If DoReadMessage then
      Readmessage;
end;

procedure TSimpleIPCServer.ReadMessage;
begin
  CheckActive;
  FBusy:=True;
  Try
    FIPCComm.ReadMessage;
    If Assigned(FOnMessage) then
      FOnMessage(Self);
  Finally
    FBusy:=False;
  end;
end;

procedure TSimpleIPCServer.GetMessageData(Stream: TStream);
begin
  Stream.CopyFrom(FMsgData,0);
end;

procedure TSimpleIPCServer.Activate;
begin
  StartServer;
end;

procedure TSimpleIPCServer.Deactivate;
begin
  StopServer;
end;

{ ---------------------------------------------------------------------
    TSimpleIPCClient
  ---------------------------------------------------------------------}

procedure TSimpleIPCClient.SetServerInstance(const AValue: String);
begin
  CheckInactive;
  FServerInstance:=AVAlue;
end;

procedure TSimpleIPCClient.Activate;
begin
  Connect;
end;

procedure TSimpleIPCClient.Deactivate;
begin
  DisConnect;
end;
constructor TSimpleIPCClient.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TSimpleIPCClient.destroy;
begin
  Active:=False;
  Inherited;
end;

procedure TSimpleIPCClient.Connect;
begin
  FIPCComm:=CommClass.Create(Self);
  FIPCComm.Connect;
  FActive:=True;
end;

procedure TSimpleIPCClient.Disconnect;
begin
  FIPCComm.DisConnect;
  FreeAndNil(FIPCComm);
  FActive:=False;
end;

function TSimpleIPCClient.ServerRunning: Boolean;

begin
  If Assigned(FIPCComm) then
    Result:=FIPCComm.ServerRunning
  else
    With CommClass.Create(Self) do
      Try
        Result:=ServerRunning;
      finally
        Free;
      end;
end;

procedure TSimpleIPCClient.SendMessage(MsgType : TMessageType; Stream: TStream);

begin
  CheckActive;
  FBusy:=True;
  Try
    FIPCComm.SendMessage(MsgType,Stream);
  Finally
    FBusy:=False;
  end;
end;

procedure TSimpleIPCClient.SendStringMessage(Msg: String);

Var
  S : TStringStream;

begin
  S:=TStringStream.Create(Msg);
  SendMessage(mtString,S);
end;

procedure TSimpleIPCClient.SendStringmessageFmt(Msg: String;
  Args: array of const);
begin
  SendStringmessage(Format(Msg,Args));
end;

end.

