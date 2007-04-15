{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2006 by Florian Klaempfl
    member of the Free Pascal development team.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$mode objfpc}
{$H+}
{$inline on}
unit comobj;

  interface

    uses
      Windows,Types,Variants,Sysutils,ActiveX;

    type
      EOleError = class(Exception);

      EOleSysError = class(EOleError)
      private
        FErrorCode: HRESULT;
      public
        constructor Create(const Msg: string; aErrorCode: HRESULT;aHelpContext: Integer);
        property ErrorCode: HRESULT read FErrorCode write FErrorCode;
      end;

      EOleException = class(EOleSysError)
      private
        FHelpFile: string;
        FSource: string;
      public
        constructor Create(const Msg: string; aErrorCode: HRESULT;const aSource,aHelpFile: string;aHelpContext: Integer);
        property HelpFile: string read FHelpFile write FHelpFile;
        property Source: string read FSource write FSource;
      end;

      EOleRegistrationError = class(EOleError);

      TComServerObject = class(TObject)
      protected
        function CountObject(Created: Boolean): Integer; virtual; abstract;
        function CountFactory(Created: Boolean): Integer; virtual; abstract;
        function GetHelpFileName: string; virtual; abstract;
        function GetServerFileName: string; virtual; abstract;
        function GetServerKey: string; virtual; abstract;
        function GetServerName: string; virtual; abstract;
        function GetStartSuspended: Boolean; virtual; abstract;
        function GetTypeLib: ITypeLib; virtual; abstract;
        procedure SetHelpFileName(const Value: string); virtual; abstract;
      public
        property HelpFileName: string read GetHelpFileName write SetHelpFileName;
        property ServerFileName: string read GetServerFileName;
        property ServerKey: string read GetServerKey;
        property ServerName: string read GetServerName;
        property TypeLib: ITypeLib read GetTypeLib;
        property StartSuspended: Boolean read GetStartSuspended;
      end;

    {
      TComObject = class(TObject, IUnknown, ISupportErrorInfo)
      protected
        { IUnknown }
        function IUnknown.QueryInterface = ObjQueryInterface;
        function IUnknown._AddRef = ObjAddRef;
        function IUnknown._Release = ObjRelease;
        { IUnknown methods for other interfaces }
        function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
        function _AddRef: Integer; stdcall;
        function _Release: Integer; stdcall;
        { ISupportErrorInfo }
        function InterfaceSupportsErrorInfo(const iid: TIID): HResult; stdcall;
      public
        constructor Create;
        constructor CreateAggregated(const Controller: IUnknown);
        constructor CreateFromFactory(Factory: TComObjectFactory; const Controller: IUnknown);
        destructor Destroy; override;
        procedure Initialize; virtual;
        function ObjAddRef: Integer; virtual; stdcall;
        function ObjQueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
        function ObjRelease: Integer; virtual; stdcall;
        function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HResult; override;
        property Controller: IUnknown;
        property Factory: TComObjectFactory;
        property RefCount: Integer;
        property ServerExceptionHandler: IServerExceptionHandler;
      end;
    }

    function CreateClassID : ansistring;

    function CreateComObject(const ClassID: TGUID) : IUnknown;
    function CreateRemoteComObject(const MachineName : WideString;const ClassID : TGUID) : IUnknown;
    function CreateOleObject(const ClassName : string) : IDispatch;
    function GetActiveOleObject(const ClassName: string) : IDispatch;

    procedure OleCheck(Value : HResult);inline;
    procedure OleError(Code: HResult);

    function ProgIDToClassID(const id : string) : TGUID;

    procedure DispatchInvoke(const Dispatch: IDispatch; CallDesc: PCallDesc;
       DispIDs: PDispIDList; Params: Pointer; Result: PVariant);
    procedure DispatchInvokeError(Status: HRESULT; const ExceptInfo: TExcepInfo);

    type
      TCoCreateInstanceExProc = function(const clsid: TCLSID; unkOuter: IUnknown; dwClsCtx: DWORD; ServerInfo: PCoServerInfo;
      dwCount: ULONG; rgmqResults: PMultiQIArray): HResult stdcall;
      TCoInitializeExProc = function (pvReserved: Pointer;
      coInit: DWORD): HResult; stdcall;
      TCoAddRefServerProcessProc = function : ULONG; stdcall;
      TCoReleaseServerProcessProc = function : ULONG; stdcall;
      TCoResumeClassObjectsProc = function : HResult; stdcall;
      TCoSuspendClassObjectsProc = function : HResult; stdcall;

    const
      CoCreateInstanceEx : TCoCreateInstanceExProc = nil;
      CoInitializeEx : TCoInitializeExProc = nil;
      CoAddRefServerProcess : TCoAddRefServerProcessProc = nil;
      CoReleaseServerProcess : TCoReleaseServerProcessProc = nil;
      CoResumeClassObjects : TCoResumeClassObjectsProc = nil;
      CoSuspendClassObjects : TCoSuspendClassObjectsProc = nil;

implementation

    uses
      ComConst,Ole2;

    constructor EOleSysError.Create(const Msg: string; aErrorCode: HRESULT; aHelpContext: Integer);
      var
        m : string;
      begin
        if Msg='' then
          m:=SysErrorMessage(aErrorCode)
        else
          m:=Msg;
        inherited CreateHelp(m,HelpContext);
        FErrorCode:=aErrorCode;
      end;


    constructor EOleException.Create(const Msg: string; aErrorCode: HRESULT;const aSource,aHelpFile: string; aHelpContext: Integer);
      begin
        inherited Create(Msg,aErrorCode,aHelpContext);
        FHelpFile:=aHelpFile;
        FSource:=aSource;
      end;

    {$define FPC_COMOBJ_HAS_CREATE_CLASS_ID}
    function CreateClassID : ansistring;
      var
         ClassID : TCLSID;
         p : PWideChar;
      begin
         CoCreateGuid(ClassID);
         StringFromCLSID(ClassID,p);
         result:=p;
         CoTaskMemFree(p);
      end;


   function CreateComObject(const ClassID : TGUID) : IUnknown;
     begin
       OleCheck(CoCreateInstance(ClassID,nil,CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER,IUnknown,result));
     end;


   function CreateRemoteComObject(const MachineName : WideString;const ClassID : TGUID) : IUnknown;
     var
       flags : DWORD;
       localhost : array[0..MAX_COMPUTERNAME_LENGTH] of WideChar;
       server : TCoServerInfo;
       mqi : TMultiQI;
       size : DWORD;
     begin
       if not(assigned(CoCreateInstanceEx)) then
         raise Exception.CreateRes(@SDCOMNotInstalled);

       FillChar(server,sizeof(server),0);
       server.pwszName:=PWideChar(MachineName);

       FillChar(mqi,sizeof(mqi),0);
       mqi.iid:=@IID_IUnknown;

       flags:=CLSCTX_LOCAL_SERVER or CLSCTX_REMOTE_SERVER or CLSCTX_INPROC_SERVER;

       { actually a remote call? }
{$ifndef wince}
       //roozbeh although there is a way to retrive computer name...HKLM\Ident\Name..but are they same?
	     size:=sizeof(localhost);
       if (MachineName<>'') and
          (not(GetComputerNameW(localhost,size)) or
          (WideCompareText(localhost,MachineName)<>0)) then
           flags:=CLSCTX_REMOTE_SERVER;
{$endif}

       OleCheck(CoCreateInstanceEx(ClassID,nil,flags,@server,1,@mqi));
       OleCheck(mqi.hr);
       Result:=mqi.itf;
     end;


   function CreateOleObject(const ClassName : string) : IDispatch;
     var
       id : TCLSID;
     begin
        id:=ProgIDToClassID(ClassName);
        OleCheck(CoCreateInstance(id,nil,CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER,IDispatch,result));
     end;


   function GetActiveOleObject(const ClassName : string) : IDispatch;
     var
     	 intf : IUnknown;
       id : TCLSID;
     begin
       id:=ProgIDToClassID(ClassName);
       OleCheck(GetActiveObject(id,nil,intf));
       OleCheck(intf.QueryInterface(IDispatch,Result));
     end;


   procedure OleError(Code: HResult);
     begin
       raise EOleSysError.Create('',Code,0);
     end;


   procedure OleCheck(Value : HResult);inline;
     begin
       if not(Succeeded(Value)) then
         OleError(Value);
     end;


   function ProgIDToClassID(const id : string) : TGUID;
     begin
       OleCheck(CLSIDFromProgID(PWideChar(WideString(id)),result));
     end;


   procedure SafeCallErrorHandler(err : HResult;addr : pointer);
     var
       info : IErrorInfo;
       descr,src,helpfile : widestring;
       helpctx : DWORD;
     begin
       if GetErrorInfo(0,info)=S_OK then
         begin
           info.GetDescription(descr);
           info.GetSource(src);
           info.GetHelpFile(helpfile);
           info.GetHelpContext(helpctx);
           raise EOleException.Create(descr,err,src,helpfile,helpctx) at addr;
         end
       else
         raise EOleException.Create('',err,'','',0) at addr;
     end;


    procedure DispatchInvokeError(Status: HRESULT; const ExceptInfo: TExcepInfo);
      begin
        if Status=DISP_E_EXCEPTION then
          raise EOleException.Create(ExceptInfo.Description,ExceptInfo.scode,ExceptInfo.Source,
            ExceptInfo.HelpFile,ExceptInfo.dwHelpContext)
        else
          raise EOleSysError.Create('',Status,0);
      end;

{ $define DEBUG_COMDISPATCH}
    procedure DispatchInvoke(const Dispatch: IDispatch; CallDesc: PCallDesc;
      DispIDs: PDispIDList; Params: Pointer; Result: PVariant);

      var
        { we can't pass pascal ansistrings to COM routines so we've to convert them
          to/from widestring. This array contains the mapping to do so
        }
        StringMap : array[0..255] of record passtr : pansistring; comstr : pwidechar; end;
        invokekind,
        i : longint;
        invokeresult : HResult;
        exceptioninfo : TExcepInfo;
        dispparams : TDispParams;
        NextString : SizeInt;
        Arguments : array[0..255] of TVarData;
        CurrType : byte;
        MethodID : TDispID;
      begin
        NextString:=0;
        fillchar(dispparams,sizeof(dispparams),0);
        try
{$ifdef DEBUG_COMDISPATCH}
          writeln('DispatchInvoke: Got ',CallDesc^.ArgCount,' arguments   NamedArgs = ',CallDesc^.NamedArgCount);
{$endif DEBUG_COMDISPATCH}
          { copy and prepare arguments }
          for i:=0 to CallDesc^.ArgCount-1 do
            begin
{$ifdef DEBUG_COMDISPATCH}
              writeln('DispatchInvoke: Params = ',hexstr(PtrInt(Params),SizeOf(Pointer)*2));
{$endif DEBUG_COMDISPATCH}
              { get plain type }
              CurrType:=CallDesc^.ArgTypes[i] and $3f;
              { by reference? }
              if (CallDesc^.ArgTypes[i] and $80)<>0 then
                begin
                  case CurrType of
                    varStrArg:
                      begin
{$ifdef DEBUG_COMDISPATCH}
                        writeln('Translating var ansistring argument ',PString(Params^)^);
{$endif DEBUG_COMDISPATCH}
                        StringMap[NextString].ComStr:=StringToOleStr(PString(Params^)^);
                        StringMap[NextString].PasStr:=PString(Params^);
                        Arguments[i].VType:=varOleStr or varByRef;
                        Arguments[i].VPointer:=StringMap[NextString].ComStr;
                        inc(NextString);
                        inc(PPointer(Params));
                      end;
                    varVariant:
                      begin
{$ifdef DEBUG_COMDISPATCH}
                        writeln('Got ref. variant containing type: ',PVarData(PPointer(Params)^)^.VType);
{$endif DEBUG_COMDISPATCH}
                        if PVarData(PPointer(Params)^)^.VType=varString then
                          begin
{$ifdef DEBUG_COMDISPATCH}
                            writeln('  Casting nested varString: ',Ansistring(PVarData(Params^)^.vString));
{$endif DEBUG_COMDISPATCH}
                            VarCast(PVariant(Params^)^,PVariant(Params^)^,varOleStr);
                          end;

                        Arguments[i].VType:=varVariant or varByRef;
                        Arguments[i].VPointer:=PPointer(Params)^;
                        inc(PPointer(Params));
                      end
                    else
                      begin
{$ifdef DEBUG_COMDISPATCH}
                        write('DispatchInvoke: Got ref argument with type = ',CurrType);
                        case CurrType of
                          varOleStr:
                            write(' Value = ',pwidestring(PPointer(Params)^)^);
                        end;
                        writeln;
{$endif DEBUG_COMDISPATCH}
                        Arguments[i].VType:=CurrType or VarByRef;
                        Arguments[i].VPointer:=PPointer(Params)^;
                        inc(PPointer(Params));
                      end;
                  end
                end
              else
                case CurrType of
                  varStrArg:
                    begin
{$ifdef DEBUG_COMDISPATCH}
                      writeln('Translating ansistring argument ',PString(Params)^);
{$endif DEBUG_COMDISPATCH}
                      StringMap[NextString].ComStr:=StringToOleStr(PString(Params)^);
                      StringMap[NextString].PasStr:=nil;
                      Arguments[i].VType:=varOleStr;
                      Arguments[i].VPointer:=StringMap[NextString].ComStr;
                      inc(NextString);
                      inc(PPointer(Params));
                    end;

                  varVariant:
                    begin
{$ifdef DEBUG_COMDISPATCH}
                      writeln('Unimplemented variant dispatch');
{$endif DEBUG_COMDISPATCH}
                    end;
                  varCurrency,
                  varDouble,
                  VarDate:
                    begin
{$ifdef DEBUG_COMDISPATCH}
                      writeln('Got 8 byte float argument');
{$endif DEBUG_COMDISPATCH}
                      Arguments[i].VType:=CurrType;
                      move(PPointer(Params)^,Arguments[i].VDouble,sizeof(Double));
                      inc(PDouble(Params));
                    end;
                  else
                    begin
{$ifdef DEBUG_COMDISPATCH}
                      write('DispatchInvoke: Got argument with type ',CurrType);
                      case CurrType of
                        varOleStr:
                          write(' Value = ',pwidestring(Params)^);
                        else
                          write(' Value = ',hexstr(PtrInt(PPointer(Params)^),SizeOf(Pointer)*2));
                      end;
                      writeln;
{$endif DEBUG_COMDISPATCH}
                      Arguments[i].VType:=CurrType;
                      Arguments[i].VPointer:=PPointer(Params)^;
                      inc(PPointer(Params));
                    end;
                end;
            end;

          { finally prepare the call }
          with DispParams do
            begin
              rgvarg:=@Arguments;
              cNamedArgs:=CallDesc^.NamedArgCount;
              if cNamedArgs=0 then
                rgdispidNamedArgs:=nil
              else
                rgdispidNamedArgs:=@DispIDs^[1];
              cArgs:=CallDesc^.ArgCount;
            end;
          InvokeKind:=CallDesc^.CallType;
          MethodID:=DispIDs^[0];
{$ifdef DEBUG_COMDISPATCH}
          writeln('DispatchInvoke: MethodID: ',MethodID,' InvokeKind: ',InvokeKind);
{$endif DEBUG_COMDISPATCH}
          { do the call and check the result }
          invokeresult:=Dispatch.Invoke(MethodID,GUID_NULL,0,InvokeKind,DispParams,result,@exceptioninfo,nil);
          if invokeresult<>0 then
            DispatchInvokeError(invokeresult,exceptioninfo);

          { translate strings back }
          for i:=0 to NextString-1 do
            if assigned(StringMap[i].passtr) then
              OleStrToStrVar(StringMap[i].comstr,StringMap[i].passtr^);
        finally
          for i:=0 to NextString-1 do
            SysFreeString(StringMap[i].ComStr);
        end;
      end;


    procedure SearchIDs(const DispatchInterface : IDispatch; Names: PChar;
      Count: Integer; IDs: PDispIDList);
      var
      	res : HRESULT;
      	NamesArray : ^PWideChar;
      	NamesData : PWideChar;
      	OrigNames : PChar;
        NameCount,
      	NameLen,
      	NewNameLen,
        CurrentNameDataUsed,
      	CurrentNameDataSize : SizeInt;
      	i : longint;
      begin
      	getmem(NamesArray,Count*sizeof(PWideChar));
      	CurrentNameDataSize:=256;
      	CurrentNameDataUsed:=0;
      	getmem(NamesData,CurrentNameDataSize);
        NameCount:=0;
   	    OrigNames:=Names;
{$ifdef DEBUG_COMDISPATCH}
        writeln('SearchIDs: Searching ',Count,' IDs');
{$endif DEBUG_COMDISPATCH}
      	for i:=1 to Count do
      	  begin
       	    NameLen:=strlen(Names);
{$ifdef DEBUG_COMDISPATCH}
            writeln('SearchIDs: Original name: ',Names,' Len: ',NameLen);
{$endif DEBUG_COMDISPATCH}
      	    NewNameLen:=MultiByteToWideChar(0,0,Names,NameLen,nil,0)+1;
      	    if (CurrentNameDataUsed+NewNameLen)*2>CurrentNameDataSize then
      	      begin
      	      	inc(CurrentNameDataSize,256);
      	        reallocmem(NamesData,CurrentNameDataSize);
      	      end;
      	    NamesArray[i-1]:=@NamesData[CurrentNameDataUsed];
      	    MultiByteToWideChar(0,0,Names,NameLen,@NamesData[CurrentNameDataUsed],NewNameLen);
      	    NamesData[CurrentNameDataUsed+NewNameLen-1]:=#0;
{$ifdef DEBUG_COMDISPATCH}
            writeln('SearchIDs: Translated name: ',WideString(PWideChar(@NamesData[CurrentNameDataUsed])));
{$endif DEBUG_COMDISPATCH}
      	    inc(CurrentNameDataUsed,NewNameLen);
      	    inc(Names,NameLen+1);
            inc(NameCount);
      	  end;
      	res:=DispatchInterface.GetIDsOfNames(GUID_NULL,NamesArray,NameCount,
{$ifdef wince}
		     LOCALE_SYSTEM_DEFAULT
{$else wince}
         GetThreadLocale
{$endif wince}
         ,IDs);
{$ifdef DEBUG_COMDISPATCH}
        writeln('SearchIDs: GetIDsOfNames result = ',hexstr(res,SizeOf(HRESULT)*2));
        for i:=0 to Count-1 do
          writeln('SearchIDs: ID[',i,'] = ',ids^[i]);
{$endif DEBUG_COMDISPATCH}
      	if res=DISP_E_UNKNOWNNAME then
      	  raise EOleError.createresfmt(@snomethod,[OrigNames])
      	else
      	  OleCheck(res);
      	freemem(NamesArray);
      	freemem(NamesData);
      end;


    procedure ComObjDispatchInvoke(dest : PVariant;const source : Variant;
        calldesc : pcalldesc;params : pointer);cdecl;
      var
      	dispatchinterface : pointer;
      	ids : array[0..255] of TDispID;
      begin
        fillchar(ids,sizeof(ids),0);
{$ifdef DEBUG_COMDISPATCH}
        writeln('ComObjDispatchInvoke called');
        writeln('ComObjDispatchInvoke: @CallDesc = $',hexstr(PtrInt(CallDesc),SizeOf(Pointer)*2),' CallDesc^.ArgCount = ',CallDesc^.ArgCount);
{$endif DEBUG_COMDISPATCH}
      	if tvardata(source).vtype=VarDispatch then
      	  dispatchinterface:=tvardata(source).vdispatch
      	else if tvardata(source).vtype=(VarDispatch or VarByRef) then
      	  dispatchinterface:=pvardata(tvardata(source).vpointer)^.vdispatch
      	else
      	  raise eoleerror.createres(@SVarNotObject);
      	SearchIDs(IDispatch(dispatchinterface),@CallDesc^.ArgTypes[CallDesc^.ArgCount],
          CallDesc^.NamedArgCount+1,@ids);
      	if assigned(dest) then
      	  VarClear(dest^);
      	DispatchInvoke(IDispatch(dispatchinterface),calldesc,@ids,params,dest);
      end;


{ $define DEBUG_DISPATCH}
    procedure DoDispCallByID(res : Pointer; const disp : IDispatch;desc : PDispDesc; params : Pointer);
      var
        exceptioninfo : TExcepInfo;
        dispparams : TDispParams;
        flags : WORD;
        invokeresult : HRESULT;
        preallocateddata : array[0..15] of TVarData;
        Arguments : ^TVarData;
        NamedArguments : PPointer;
        CurrType : byte;
        namedcount,i : byte;
      begin
        { use preallocated space, i.e. can we avoid a getmem call? }
        if desc^.calldesc.argcount<=Length(preallocateddata) then
          Arguments:=@preallocateddata
        else
          GetMem(Arguments,desc^.calldesc.argcount*sizeof(TVarData));

        { prepare parameters }
        for i:=0 to desc^.CallDesc.ArgCount-1 do
          begin
{$ifdef DEBUG_DISPATCH}
            writeln('DoDispCallByID: Params = ',hexstr(PtrInt(Params),SizeOf(Pointer)*2));
{$endif DEBUG_DISPATCH}
            { get plain type }
            CurrType:=desc^.CallDesc.ArgTypes[i] and $3f;
            { by reference? }
            if (desc^.CallDesc.ArgTypes[i] and $80)<>0 then
              begin
{$ifdef DEBUG_DISPATCH}
                write('DispatchInvoke: Got ref argument with type = ',CurrType);
                writeln;
{$endif DEBUG_DISPATCH}
                Arguments[i].VType:=CurrType or VarByRef;
                Arguments[i].VPointer:=PPointer(Params)^;
                inc(PPointer(Params));
              end
            else
              begin
{$ifdef DEBUG_DISPATCH}
                writeln('DispatchInvoke: Got ref argument with type = ',CurrType);
{$endif DEBUG_DISPATCH}
                case CurrType of
                  varVariant:
                    begin
                      Arguments[i].VType:=CurrType;
                      move(PVarData(Params)^,Arguments[i],sizeof(TVarData));
                      inc(PVarData(Params));
                    end;
                  varCurrency,
                  varDouble,
                  VarDate:
                    begin
{$ifdef DEBUG_DISPATCH}
                      writeln('DispatchInvoke: Got 8 byte float argument');
{$endif DEBUG_DISPATCH}
                      Arguments[i].VType:=CurrType;
                      move(PPointer(Params)^,Arguments[i].VDouble,sizeof(Double));
                      inc(PDouble(Params));
                    end;
                else
                  begin
{$ifdef DEBUG_DISPATCH}
                    writeln('DispatchInvoke: Got argument with type ',CurrType);
{$endif DEBUG_DISPATCH}
                    Arguments[i].VType:=CurrType;
                    Arguments[i].VPointer:=PPointer(Params)^;
                    inc(PPointer(Params));
                  end;
              end;
            end;
          end;
        dispparams.cArgs:=desc^.calldesc.argcount;
        dispparams.rgvarg:=pointer(Arguments);

        { handle properties properly here ! }
        namedcount:=desc^.calldesc.namedargcount;
        if desc^.calldesc.calltype=DISPATCH_PROPERTYPUT then
          inc(namedcount)
        else
          NamedArguments:=@desc^.CallDesc.ArgTypes[desc^.CallDesc.ArgCount];
        dispparams.cNamedArgs:=namedcount;
        dispparams.rgdispidNamedArgs:=pointer(NamedArguments);
        flags:=0;
        invokeresult:=disp.Invoke(
                desc^.DispId, { DispID: LongInt; }
                GUID_NULL, { const iid : TGUID; }
                0, { LocaleID : longint; }
                flags, { Flags: Word; }
                dispparams, { var params; }
                res,@exceptioninfo,nil { VarResult,ExcepInfo,ArgErr : pointer) }
          );
        if invokeresult<>0 then
          DispatchInvokeError(invokeresult,exceptioninfo);
        if desc^.calldesc.argcount>Length(preallocateddata) then
          FreeMem(Arguments);
      end;


const
  Initialized : boolean = false;
var
  Ole32Dll : HModule;
initialization
  Ole32Dll:=GetModuleHandle('ole32.dll');
  if Ole32Dll<>0 then
    begin
      Pointer(CoCreateInstanceEx):=GetProcAddress(Ole32Dll,'CoCreateInstanceExProc');
      Pointer(CoInitializeEx):=GetProcAddress(Ole32Dll,'CoInitializeExProc');
      Pointer(CoAddRefServerProcess):=GetProcAddress(Ole32Dll,'CoAddRefServerProcessProc');
      Pointer(CoReleaseServerProcess):=GetProcAddress(Ole32Dll,'CoReleaseServerProcessProc');
      Pointer(CoResumeClassObjects):=GetProcAddress(Ole32Dll,'CoResumeClassObjectsProc');
      Pointer(CoSuspendClassObjects):=GetProcAddress(Ole32Dll,'CoSuspendClassObjectsProc');
    end;

  if not(IsLibrary) then
    Initialized:=Succeeded(CoInitialize(nil));
  SafeCallErrorProc:=@SafeCallErrorHandler;
  VarDispProc:=@ComObjDispatchInvoke;
  DispCallByIDProc:=@DoDispCallByID;
finalization
  VarDispProc:=nil;
  SafeCallErrorProc:=nil;
  if Initialized then
    CoUninitialize;
end.


