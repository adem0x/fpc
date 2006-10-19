{$mode objfpc}
{$H+}
unit fpcgi;

interface

uses SysUtils,Classes,CustCgi,httpDefs,fpHTTP;

Type

  { TCGIApplication }
  TGetModuleEvent = Procedure (Sender : TObject; ARequest : TRequest;
                               Var ModuleClass : TCustomHTTPModuleClass) of object;

  TCGIApplication = Class(TCustomCGIApplication)
  private
    FModuleVar: String;
    FOnGetModule: TGetModuleEvent;
    FAllowDefaultModule: Boolean;
  Protected
    Function GetModuleName(Arequest : TRequest) : string;
    function FindModule(ModuleClass : TCustomHTTPModuleClass): TCustomHTTPModule;
  Public
    Constructor Create(AOwner : TComponent); override;
    Procedure CreateForm(AClass : TComponentClass; Var Reference : TComponent);
    Procedure handleRequest(ARequest : TRequest; AResponse : TResponse); override;
    Property OnGetModule : TGetModuleEvent Read FOnGetModule Write FOnGetModule;
    Property ModuleVariable : String Read FModuleVar Write FModuleVar;
    Property AllowDefaultModule : Boolean Read FAllowDefaultModule Write FAllowDefaultModule;
  end;

  EFPCGIError = Class(Exception);
  
Var
  Application : TCGIApplication;
  ShowCleanUpErrors : Boolean = False;
  
Implementation

resourcestring
  SErrNoModuleNameForRequest = 'Could not determine HTTP module name for request';
  SErrNoModuleForRequest = 'Could not determine HTTP module for request "%s"';

Procedure InitCGI;

begin
  Application:=TCGIApplication.Create(Nil);
end;

Procedure DoneCGI;

begin
  Try
    FreeAndNil(Application);
  except
    if ShowCleanUpErrors then
      Raise;
  end;
end;

{ TCGIApplication }

function TCGIApplication.GetModuleName(Arequest: TRequest): string;


begin
  If (FModuleVar<>'') then
    Result:=ARequest.QueryFields.Values[FModuleVar];
  If (Result='') then
    Result:=ARequest.GetNextPathInfo;
end;

function TCGIApplication.FindModule(ModuleClass : TCustomHTTPModuleClass): TCustomHTTPModule;

Var
  I : Integer;

begin
  I:=ComponentCount-1;
  While (I>=0) and (Not (Components[i] is ModuleClass)) do
    Dec(i);
  if (I>=0) then
    Result:=Components[i] as TCustomHTTPModule
  else
    Result:=Nil;
end;

constructor TCGIApplication.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FModuleVar:='Module'; // Do not localize
  FAllowDefaultModule:=True;
end;

procedure TCGIApplication.CreateForm(AClass: TComponentClass;
  var Reference: TComponent);
begin
  Reference:=AClass.Create(Self);
end;

procedure TCGIApplication.HandleRequest(ARequest: TRequest; AResponse: TResponse);

Var
  MC : TCustomHTTPModuleClass;
  M  : TCustomHTTPModule;
  MN : String;
  MI : TModuleItem;
  
begin
  MC:=Nil;
  If (OnGetModule<>Nil) then
    OnGetModule(Self,ARequest,MC);
  If (MC=Nil) then
    begin
    MN:=GetModuleName(ARequest);
    If (MN='') and Not AllowDefaultModule then
      Raise EFPCGIError.Create(SErrNoModuleNameForRequest);
    MI:=ModuleFactory.FindModule(MN);
    If (MI=Nil) and (ModuleFactory.Count=1) then
      MI:=ModuleFactory[0];
    if (MI=Nil) then
      begin
      Raise EFPCGIError.CreateFmt(SErrNoModuleForRequest,[MN]);
      end;
    MC:=MI.ModuleClass;
    M:=FindModule(MC); // Check if a module exists already
    end;
  If (M=Nil) then
    M:=MC.Create(Self);
  M.HandleRequest(ARequest,AResponse);
end;

Initialization
  InitCGI;
  
Finalization
  DoneCGI;
  
end.
