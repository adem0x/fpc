{
    Copyright (c) 2004-2013 by Joost van der Sluis, FPC contributors

    SQL database & dataset

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit sqldb;

{$mode objfpc}
{$H+}
{$M+}   // ### remove this!!!

interface

uses SysUtils, Classes, DB, bufdataset, sqlscript;

type
  TSchemaType = (stNoSchema, stTables, stSysTables, stProcedures, stColumns, stProcedureParams, stIndexes, stPackages, stSchemata);
  TConnOption = (sqSupportParams, sqSupportEmptyDatabaseName, sqEscapeSlash, sqEscapeRepeat);
  TConnOptions= set of TConnOption;
  TConnInfoType=(citAll=-1, citServerType, citServerVersion, citServerVersionString, citClientName, citClientVersion);
  TStatementType = (stUnknown, stSelect, stInsert, stUpdate, stDelete,
    stDDL, stGetSegment, stPutSegment, stExecProcedure,
    stStartTrans, stCommit, stRollback, stSelectForUpd);

  TRowsCount = LargeInt;

  TSQLStatementInfo = Record
    StatementType : TStatementType;
    TableName : String;
    Updateable : Boolean;
    WhereStartPos ,
    WhereStopPos : integer;
  end;


type
  TSQLConnection = class;
  TSQLTransaction = class;
  TCustomSQLQuery = class;
  TCustomSQLStatement = Class;
  TSQLQuery = class;
  TSQLScript = class;



  TDBEventType = (detCustom, detPrepare, detExecute, detFetch, detCommit,detRollBack);
  TDBEventTypes = set of TDBEventType;
  TDBLogNotifyEvent = Procedure (Sender : TSQLConnection; EventType : TDBEventType; Const Msg : String) of object;

  TSQLHandle = Class(TObject)
  end;

  { TSQLCursor }

  TSQLCursor = Class(TSQLHandle)
  public
    FPrepared      : Boolean;
    FSelectable    : Boolean;
    FInitFieldDef  : Boolean;
    FStatementType : TStatementType;
    FSchemaType    : TSchemaType;
  end;

type TQuoteChars = array[0..1] of char;

const
  SingleQuotes : TQuoteChars = ('''','''');
  DoubleQuotes : TQuoteChars = ('"','"');
  LogAllEvents = [detCustom, detPrepare, detExecute, detFetch, detCommit, detRollBack];
  StatementTokens : Array[TStatementType] of string = ('(unknown)', 'select',
                  'insert', 'update', 'delete',
                  'create', 'get', 'put', 'execute',
                  'start','commit','rollback', '?'
                 );

type

  { TServerIndexDefs }

  TServerIndexDefs = class(TIndexDefs)
  Private
  public
    constructor Create(ADataSet: TDataSet); override;
    procedure Update; override;
  end;

type

  { TSQLConnection }

  TSQLConnection = class (TDatabase)
  private
    FFieldNameQuoteChars : TQuoteChars;
    FLogEvents: TDBEventTypes;
    FOnLog: TDBLogNotifyEvent;
    FPassword            : string;
    FTransaction         : TSQLTransaction;
    FUserName            : string;
    FHostName            : string;
    FCharSet             : string;
    FRole                : String;
    FStatements          : TFPList;
    function GetPort: cardinal;
    procedure SetPort(const AValue: cardinal);
  protected
    FConnOptions         : TConnOptions;
    FSQLFormatSettings : TFormatSettings;
    procedure GetDBInfo(const ASchemaType : TSchemaType; const ASchemaObjectName, AReturnField : string; AList: TStrings);
    procedure SetTransaction(Value : TSQLTransaction); virtual;
    procedure DoInternalConnect; override;
    procedure DoInternalDisconnect; override;
    function GetAsSQLText(Field : TField) : string; overload; virtual;
    function GetAsSQLText(Param : TParam) : string; overload; virtual;
    function GetHandle : pointer; virtual;
    Function LogEvent(EventType : TDBEventType) : Boolean;
    Procedure Log(EventType : TDBEventType; Const Msg : String); virtual;
    Procedure RegisterStatement(S : TCustomSQLStatement);
    Procedure UnRegisterStatement(S : TCustomSQLStatement);

    Function AllocateCursorHandle : TSQLCursor; virtual; abstract;
    Procedure DeAllocateCursorHandle(var cursor : TSQLCursor); virtual; abstract;
    function StrToStatementType(s : string) : TStatementType; virtual;
    function GetStatementInfo(const ASQL: string; Full: Boolean; ASchema : TSchemaType): TSQLStatementInfo; virtual;
    procedure PrepareStatement(cursor: TSQLCursor;ATransaction : TSQLTransaction;buf : string; AParams : TParams); virtual; abstract;
    procedure UnPrepareStatement(cursor : TSQLCursor); virtual; abstract;
    procedure Execute(cursor: TSQLCursor;atransaction:tSQLtransaction; AParams : TParams); virtual; abstract;
    function RowsAffected(cursor: TSQLCursor): TRowsCount; virtual;
    function Fetch(cursor : TSQLCursor) : boolean; virtual; abstract;
    procedure AddFieldDefs(cursor: TSQLCursor; FieldDefs : TfieldDefs); virtual; abstract;
    function LoadField(cursor : TSQLCursor;FieldDef : TfieldDef;buffer : pointer; out CreateBlob : boolean) : boolean; virtual; abstract;
    procedure LoadBlobIntoBuffer(FieldDef: TFieldDef;ABlobBuf: PBufBlobField; cursor: TSQLCursor; ATransaction : TSQLTransaction); virtual; abstract;
    procedure FreeFldBuffers(cursor : TSQLCursor); virtual;

    Function AllocateTransactionHandle : TSQLHandle; virtual; abstract;
    function GetTransactionHandle(trans : TSQLHandle): pointer; virtual; abstract;
    function Commit(trans : TSQLHandle) : boolean; virtual; abstract;
    function RollBack(trans : TSQLHandle) : boolean; virtual; abstract;
    function StartdbTransaction(trans : TSQLHandle; aParams : string) : boolean; virtual; abstract;
    procedure CommitRetaining(trans : TSQLHandle); virtual; abstract;
    procedure RollBackRetaining(trans : TSQLHandle); virtual; abstract;

    procedure UpdateIndexDefs(IndexDefs : TIndexDefs;TableName : string); virtual;
    function GetSchemaInfoSQL(SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string) : string; virtual;

    Property Statements : TFPList Read FStatements;
    property Port: cardinal read GetPort write SetPort;
  public
    property Handle: Pointer read GetHandle;
    property FieldNameQuoteChars: TQuoteChars read FFieldNameQuoteChars write FFieldNameQuoteChars;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure StartTransaction; override;
    procedure EndTransaction; override;
    property ConnOptions: TConnOptions read FConnOptions;
    procedure ExecuteDirect(SQL : String); overload; virtual;
    procedure ExecuteDirect(SQL : String; ATransaction : TSQLTransaction); overload; virtual;
    procedure GetTableNames(List : TStrings; SystemTables : Boolean = false); virtual;
    procedure GetProcedureNames(List : TStrings); virtual;
    procedure GetFieldNames(const TableName : string; List : TStrings); virtual;
    procedure GetSchemaNames(List: TStrings); virtual;
    function GetConnectionInfo(InfoType:TConnInfoType): string; virtual;
    procedure CreateDB; virtual;
    procedure DropDB; virtual;
  published
    property Password : string read FPassword write FPassword;
    property Transaction : TSQLTransaction read FTransaction write SetTransaction;
    property UserName : string read FUserName write FUserName;
    property CharSet : string read FCharSet write FCharSet;
    property HostName : string Read FHostName Write FHostName;
    Property OnLog : TDBLogNotifyEvent Read FOnLog Write FOnLog;
    Property LogEvents : TDBEventTypes Read FLogEvents Write FLogEvents Default LogAllEvents;
    property Connected;
    Property Role :  String read FRole write FRole;
    property DatabaseName;
    property KeepConnection;
    property LoginPrompt;
    property Params;
    property OnLogin;
  end;

{ TSQLTransaction }

  TCommitRollbackAction = (caNone, caCommit, caCommitRetaining, caRollback,
    caRollbackRetaining);

  TSQLTransaction = class (TDBTransaction)
  private
    FTrans               : TSQLHandle;
    FAction              : TCommitRollbackAction;
    FParams              : TStringList;
    procedure SetParams(const AValue: TStringList);
  protected
    function GetHandle : Pointer; virtual;
    Procedure SetDatabase (Value : TDatabase); override;
    Function LogEvent(EventType : TDBEventType) : Boolean;
    Procedure Log(EventType : TDBEventType; Const Msg : String); virtual;
  public
    procedure Commit; virtual;
    procedure CommitRetaining; virtual;
    procedure Rollback; virtual;
    procedure RollbackRetaining; virtual;
    procedure StartTransaction; override;
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    property Handle: Pointer read GetHandle;
    procedure EndTransaction; override;
  published
    property Action : TCommitRollbackAction read FAction write FAction Default caRollBack;
    property Database;
    property Params : TStringList read FParams write SetParams;
  end;

  { TCustomSQLStatement }

  TCustomSQLStatement = Class(TComponent)
  Private
    FCursor : TSQLCursor;
    FDatabase: TSQLConnection;
    FParamCheck: Boolean;
    FParams: TParams;
    FSQL: TStrings;
    FOrigSQL : String;
    FServerSQL : String;
    FTransaction: TSQLTransaction;
    FParseSQL: Boolean;
    FDataLink : TDataLink;
    procedure SetDatabase(AValue: TSQLConnection);
    procedure SetParams(AValue: TParams);
    procedure SetSQL(AValue: TStrings);
    procedure SetTransaction(AValue: TSQLTransaction);
    Function GetPrepared : Boolean;
  Protected
    Function CreateDataLink : TDataLink; virtual;
    procedure OnChangeSQL(Sender : TObject); virtual;
    function GetDataSource: TDataSource; Virtual;
    procedure SetDataSource(AValue: TDataSource); virtual;
    Procedure CopyParamsFromMaster(CopyBound : Boolean); virtual;
    procedure AllocateCursor;
    procedure DeAllocateCursor;
    Function GetSchemaType : TSchemaType; virtual;
    Function GetSchemaObjectName : String; virtual;
    Function GetSchemaPattern: String; virtual;
    Function IsSelectable : Boolean ; virtual;
    procedure GetStatementInfo(Var ASQL: String; Full: Boolean; ASchema: TSchemaType; out Info: TSQLStatementInfo); virtual;
    Procedure DoExecute; virtual;
    procedure DoPrepare; virtual;
    procedure DoUnPrepare; virtual;
    Function CreateParams : TParams; virtual;
    Function LogEvent(EventType : TDBEventType) : Boolean;
    Procedure Log(EventType : TDBEventType; Const Msg : String); virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    Property Cursor : TSQLCursor read FCursor;
    Property Database : TSQLConnection Read FDatabase Write SetDatabase;
    Property Transaction : TSQLTransaction Read FTransaction Write SetTransaction;
    Property SQL : TStrings Read FSQL Write SetSQL;
    Property Params : TParams Read FParams Write SetParams;
    Property DataSource : TDataSource Read GetDataSource Write SetDataSource;
    Property ParseSQL : Boolean Read FParseSQL Write FParseSQL;
    Property ParamCheck : Boolean Read FParamCheck Write FParamCheck default true;
  Public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    Procedure Prepare;
    Procedure Execute;
    Procedure Unprepare;
    function ParamByName(Const AParamName : String) : TParam;
    function RowsAffected: TRowsCount; virtual;
    Property Prepared : boolean read GetPrepared;
  end;

  TSQLStatement = Class(TCustomSQLStatement)
  Published
    Property Database;
    Property DataSource;
    Property ParamCheck;
    Property Params;
    Property ParseSQL;
    Property SQL;
    Property Transaction;
  end;

{ TCustomSQLQuery }

  TCustomSQLQuery = class (TCustomBufDataset)
  private
    // FCursor              : TSQLCursor;
    FSchemaType: TSchemaType;
//    FSQL: TStringlist;
    FUpdateable          : boolean;
    FTableName           : string;
    FStatement           : TCustomSQLStatement;
    FUpdateSQL,
    FInsertSQL,
    FDeleteSQL           : TStringList;
    FIsEOF               : boolean;
    FLoadingFieldDefs    : boolean;
    FUpdateMode          : TUpdateMode;
    FusePrimaryKeyAsKey  : Boolean;
    FSQLBuf              : String;
    FWhereStartPos       : integer;
    FWhereStopPos        : integer;
    // FParseSQL            : boolean;
//    FMasterLink          : TMasterParamsDatalink;
//    FSchemaInfo          : TSchemaInfo;

    FServerFilterText    : string;
    FServerFiltered      : Boolean;

    FServerIndexDefs     : TServerIndexDefs;

    // Used by SetSchemaType
    FSchemaObjectName    : string;
    FSchemaPattern       : string;

    FUpdateQry,
    FDeleteQry,
    FInsertQry           : TCustomSQLQuery;
    procedure FreeFldBuffers;
    function GetParamCheck: Boolean;
    function GetParams: TParams;
    function GetParseSQL: Boolean;
    function GetServerIndexDefs: TServerIndexDefs;
    function GetSQL: TStringlist;
    function GetStatementType : TStatementType;
    procedure SetParamCheck(AValue: Boolean);
    procedure SetUpdateSQL(const AValue: TStringlist);
    procedure SetDeleteSQL(const AValue: TStringlist);
    procedure SetInsertSQL(const AValue: TStringlist);
    procedure SetParams(AValue: TParams);
    procedure SetParseSQL(AValue : Boolean);
    procedure SetSQL(const AValue: TStringlist);
    procedure SetUsePrimaryKeyAsKey(AValue : Boolean);
    procedure SetUpdateMode(AValue : TUpdateMode);
//    procedure OnChangeSQL(Sender : TObject);
    procedure OnChangeModifySQL(Sender : TObject);
    procedure Execute;
//    Function SQLParser(const ASQL : string) : TStatementType;
    procedure ApplyFilter;
    Function AddFilter(SQLstr : string) : string;
  protected
    // abstract & virtual methods of TBufDataset
    function Fetch : boolean; override;
    Function Cursor : TSQLCursor;
    function LoadField(FieldDef : TFieldDef;buffer : pointer; out CreateBlob : boolean) : boolean; override;
    procedure LoadBlobIntoBuffer(FieldDef: TFieldDef;ABlobBuf: PBufBlobField); override;
    // abstract & virtual methods of TDataset
    procedure UpdateServerIndexDefs; virtual;
    procedure SetDatabase(Value : TDatabase); override;
    Procedure SetTransaction(Value : TDBTransaction); override;
    procedure InternalAddRecord(Buffer: Pointer; AAppend: Boolean); override;
    procedure InternalClose; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalOpen; override;
    function  GetCanModify: Boolean; override;
    procedure ApplyRecUpdate(UpdateKind : TUpdateKind); override;
    Function IsPrepared : Boolean; virtual;
    Procedure SetActive (Value : Boolean); override;
    procedure SetServerFiltered(Value: Boolean); virtual;
    procedure SetServerFilterText(const Value: string); virtual;
    Function GetDataSource : TDataSource; override;
    Procedure SetDataSource(AValue : TDataSource);
    procedure BeforeRefreshOpenCursor; override;
    procedure SetReadOnly(AValue : Boolean); override;
    Function LogEvent(EventType : TDBEventType) : Boolean;
    Procedure Log(EventType : TDBEventType; Const Msg : String); virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    procedure Prepare; virtual;
    procedure UnPrepare; virtual;
    procedure ExecSQL; virtual;
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure SetSchemaInfo( ASchemaType : TSchemaType; ASchemaObjectName, ASchemaPattern : string); virtual;
    property Prepared : boolean read IsPrepared;
    function RowsAffected: TRowsCount; virtual;
    function ParamByName(Const AParamName : String) : TParam;
  protected

    // redeclared data set properties
    property Active;
    property Filter;
    property Filtered;
//    property FilterOptions;
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
    property AutoCalcFields;
    property Database;
  // protected
    property SchemaType : TSchemaType read FSchemaType default stNoSchema;
    property Transaction;
    property SQL : TStringlist read GetSQL write SetSQL;
    property UpdateSQL : TStringlist read FUpdateSQL write SetUpdateSQL;
    property InsertSQL : TStringlist read FInsertSQL write SetInsertSQL;
    property DeleteSQL : TStringlist read FDeleteSQL write SetDeleteSQL;
    property Params : TParams read GetParams Write SetParams;
    Property ParamCheck : Boolean Read GetParamCheck Write SetParamCheck default true;
    property ParseSQL : Boolean read GetParseSQL write SetParseSQL default true;
    property UpdateMode : TUpdateMode read FUpdateMode write SetUpdateMode default upWhereKeyOnly;
    property UsePrimaryKeyAsKey : boolean read FUsePrimaryKeyAsKey write SetUsePrimaryKeyAsKey default true;
    property StatementType : TStatementType read GetStatementType;
    Property DataSource : TDataSource Read GetDataSource Write SetDataSource;
    property ServerFilter: string read FServerFilterText write SetServerFilterText;
    property ServerFiltered: Boolean read FServerFiltered write SetServerFiltered default False;
    property ServerIndexDefs : TServerIndexDefs read GetServerIndexDefs;
  end;

{ TSQLQuery }
  TSQLQuery = Class(TCustomSQLQuery)
  public
    property SchemaType;
    Property StatementType;
  Published
    property MaxIndexesCount;
   // TDataset stuff
    property FieldDefs;
    Property Active;
    Property AutoCalcFields;
    Property Filter;
    Property Filtered;
    Property AfterCancel;
    Property AfterClose;
    Property AfterDelete;
    Property AfterEdit;
    Property AfterInsert;
    Property AfterOpen;
    Property AfterPost;
    Property AfterScroll;
    Property BeforeCancel;
    Property BeforeClose;
    Property BeforeDelete;
    Property BeforeEdit;
    Property BeforeInsert;
    Property BeforeOpen;
    Property BeforePost;
    Property BeforeScroll;
    Property OnCalcFields;
    Property OnDeleteError;
    Property OnEditError;
    Property OnFilterRecord;
    Property OnNewRecord;
    Property OnPostError;

    //    property SchemaInfo default stNoSchema;
    property Database;
    property Transaction;
    property ReadOnly;
    property SQL;
    property UpdateSQL;
    property InsertSQL;
    property DeleteSQL;
    property IndexDefs;
    property Params;
    Property ParamCheck;
    property ParseSQL;
    property UpdateMode;
    property UsePrimaryKeyAsKey;
    Property DataSource;
    property ServerFilter;
    property ServerFiltered;
    property ServerIndexDefs;
  end;

{ TSQLScript }

  TSQLScript = class (TCustomSQLscript)
  private
    FOnDirective: TSQLScriptDirectiveEvent;
    FQuery   : TCustomSQLQuery;
    FDatabase : TDatabase;
    FTransaction : TDBTransaction;
  protected
    procedure ExecuteStatement (SQLStatement: TStrings; var StopExecution: Boolean); override;
    procedure ExecuteDirective (Directive, Argument: String; var StopExecution: Boolean); override;
    procedure ExecuteCommit(CommitRetaining: boolean=true); override;
    Procedure SetDatabase (Value : TDatabase); virtual;
    Procedure SetTransaction(Value : TDBTransaction); virtual;
    Procedure CheckDatabase;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure Execute; override;
    procedure ExecuteScript;
  published
    Property DataBase : TDatabase Read FDatabase Write SetDatabase;
    Property Transaction : TDBTransaction Read FTransaction Write SetTransaction;
    property OnDirective: TSQLScriptDirectiveEvent read FOnDirective write FOnDirective;
    property Directives;
    property Defines;
    property Script;
    property Terminator;
    property CommentsinSQL;
    property UseSetTerm;
    property UseCommit;
    property UseDefines;
    property OnException;
  end;

  { TSQLConnector }

  TSQLConnector = Class(TSQLConnection)
  private
    FProxy : TSQLConnection;
    FConnectorType: String;
    procedure SetConnectorType(const AValue: String);
  protected
    procedure SetTransaction(Value : TSQLTransaction);override;
    procedure DoInternalConnect; override;
    procedure DoInternalDisconnect; override;
    Procedure CheckProxy;
    Procedure CreateProxy; virtual;
    Procedure FreeProxy; virtual;
    function StrToStatementType(s : string) : TStatementType; override;
    function GetAsSQLText(Field : TField) : string; overload; override;
    function GetAsSQLText(Param : TParam) : string; overload; override;
    function GetHandle : pointer; override;

    Function AllocateCursorHandle : TSQLCursor; override;
    Procedure DeAllocateCursorHandle(var cursor : TSQLCursor); override;
    Function AllocateTransactionHandle : TSQLHandle; override;

    procedure PrepareStatement(cursor: TSQLCursor;ATransaction : TSQLTransaction;buf : string; AParams : TParams); override;
    procedure Execute(cursor: TSQLCursor;atransaction:tSQLtransaction; AParams : TParams); override;
    function RowsAffected(cursor: TSQLCursor): TRowsCount; override;
    function Fetch(cursor : TSQLCursor) : boolean; override;
    procedure AddFieldDefs(cursor: TSQLCursor; FieldDefs : TfieldDefs); override;
    procedure UnPrepareStatement(cursor : TSQLCursor); override;
    function LoadField(cursor : TSQLCursor;FieldDef : TfieldDef;buffer : pointer; out CreateBlob : boolean) : boolean; override;
    procedure LoadBlobIntoBuffer(FieldDef: TFieldDef;ABlobBuf: PBufBlobField; cursor: TSQLCursor; ATransaction : TSQLTransaction); override;
    procedure FreeFldBuffers(cursor : TSQLCursor); override;

    function GetTransactionHandle(trans : TSQLHandle): pointer; override;
    function Commit(trans : TSQLHandle) : boolean; override;
    function RollBack(trans : TSQLHandle) : boolean; override;
    function StartdbTransaction(trans : TSQLHandle; aParams : string) : boolean; override;
    procedure CommitRetaining(trans : TSQLHandle); override;
    procedure RollBackRetaining(trans : TSQLHandle); override;
    procedure UpdateIndexDefs(IndexDefs : TIndexDefs;TableName : string); override;
    function GetSchemaInfoSQL(SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string) : string; override;
    Property Proxy : TSQLConnection Read FProxy;
  Published
    Property ConnectorType : String Read FConnectorType Write SetConnectorType;
  end;

  TSQLConnectionClass = Class of TSQLConnection;

  { TConnectionDef }
  TLibraryLoadFunction = Function (Const S : AnsiString) : Integer;
  TLibraryUnLoadFunction = Procedure;
  TConnectionDef = Class(TPersistent)
    Class Function TypeName : String; virtual;
    Class Function ConnectionClass : TSQLConnectionClass; virtual;
    Class Function Description : String; virtual;
    Class Function DefaultLibraryName : String; virtual;
    Class Function LoadFunction : TLibraryLoadFunction; virtual;
    Class Function UnLoadFunction : TLibraryUnLoadFunction; virtual;
    Class Function LoadedLibraryName : string; virtual;
    Procedure ApplyParams(Params : TStrings; AConnection : TSQLConnection); virtual;
  end;
  TConnectionDefClass = class of TConnectionDef;

Var
  GlobalDBLogHook : TDBLogNotifyEvent;

Procedure RegisterConnection(Def : TConnectionDefClass);
Procedure UnRegisterConnection(Def : TConnectionDefClass);
Procedure UnRegisterConnection(ConnectionName : String);
Function GetConnectionDef(ConnectorName : String) : TConnectionDef;
Procedure GetConnectionList(List : TSTrings);

const DefaultSQLFormatSettings : TFormatSettings = (
  CurrencyFormat: 1;
  NegCurrFormat: 5;
  ThousandSeparator: #0;
  DecimalSeparator: '.';
  CurrencyDecimals: 2;
  DateSeparator: '-';
  TimeSeparator: ':';
  ListSeparator: ' ';
  CurrencyString: '$';
  ShortDateFormat: 'yyyy-mm-dd';
  LongDateFormat: '';
  TimeAMString: '';
  TimePMString: '';
  ShortTimeFormat: 'hh:nn:ss';
  LongTimeFormat: 'hh:nn:ss.zzz';
  ShortMonthNames: ('','','','','','','','','','','','');
  LongMonthNames: ('','','','','','','','','','','','');
  ShortDayNames: ('','','','','','','');
  LongDayNames: ('','','','','','','');
  TwoDigitYearCenturyWindow: 50;
);

implementation

uses dbconst, strutils;


function TimeIntervalToString(Time: TDateTime): string;
var
  millisecond: word;
  second     : word;
  minute     : word;
  hour       : word;
begin
  DecodeTime(Time,hour,minute,second,millisecond);
  hour := hour + (trunc(Time) * 24);
  result := Format('%.2d:%.2d:%.2d.%.3d',[hour,minute,second,millisecond]);
end;

{ TCustomSQLStatement }

procedure TCustomSQLStatement.OnChangeSQL(Sender: TObject);

var
  ConnOptions : TConnOptions;
  NewParams: TParams;

begin
  UnPrepare;
  if not ParamCheck then
    exit;
  if assigned(DataBase) then
    ConnOptions:=DataBase.ConnOptions
  else
    ConnOptions := [sqEscapeRepeat,sqEscapeSlash];
  NewParams := CreateParams;
  try
    NewParams.ParseSQL(FSQL.Text, True, sqEscapeSlash in ConnOptions, sqEscapeRepeat in ConnOptions, psInterbase);
    NewParams.AssignValues(FParams);
    FParams.Assign(NewParams);
  finally
    NewParams.Free;
  end;
end;

procedure TCustomSQLStatement.SetDatabase(AValue: TSQLConnection);
begin
  if FDatabase=AValue then Exit;
  UnPrepare;
  If Assigned(FDatabase) then
    begin
    FDatabase.UnregisterStatement(Self);
    FDatabase.RemoveFreeNotification(Self);
    end;
  FDatabase:=AValue;
  If Assigned(FDatabase) then
    begin
    FDatabase.FreeNotification(Self);
    FDatabase.RegisterStatement(Self);
    if (Transaction=nil) and (Assigned(FDatabase.Transaction)) then
      transaction := FDatabase.Transaction;
    OnChangeSQL(Self);
    end;
end;

procedure TCustomSQLStatement.SetDataSource(AValue: TDataSource);

begin
  if GetDataSource=AValue then Exit;
  if (FDataLink=Nil) then
    FDataLink:=CreateDataLink;
  FDataLink.DataSource:=AValue;
end;

procedure TCustomSQLStatement.CopyParamsFromMaster(CopyBound : Boolean);
begin
  if Assigned(DataSource) and Assigned(DataSource.Dataset) then
    FParams.CopyParamValuesFromDataset(DataSource.Dataset,CopyBound);
end;

procedure TCustomSQLStatement.SetParams(AValue: TParams);
begin
  if FParams=AValue then Exit;
  FParams.Assign(AValue);
end;

procedure TCustomSQLStatement.SetSQL(AValue: TStrings);
begin
  if FSQL=AValue then Exit;
  FSQL.Assign(AValue);
end;

procedure TCustomSQLStatement.SetTransaction(AValue: TSQLTransaction);
begin
  if FTransaction=AValue then Exit;
  UnPrepare;
  if Assigned(FTransaction) then
    FTransaction.RemoveFreeNotification(Self);
  FTransaction:=AValue;
  if Assigned(FTransaction) then
    begin
    FTransaction.FreeNotification(Self);
    If (Database=Nil) then
      Database:=Transaction.Database as TSQLConnection;
    end;
end;

procedure TCustomSQLStatement.DoExecute;
begin
  If (FParams.Count>0) and Assigned(DataSource) then
    CopyParamsFromMaster(False);
  If LogEvent(detExecute) then
    Log(detExecute,FServerSQL);
  Database.Execute(FCursor,Transaction, FParams);
end;

function TCustomSQLStatement.GetPrepared: Boolean;
begin
  Result := Assigned(FCursor) and FCursor.FPrepared;
end;

function TCustomSQLStatement.CreateDataLink: TDataLink;
begin
  Result:=TDataLink.Create;
end;

function TCustomSQLStatement.CreateParams: TParams;
begin
  Result:=TParams.Create(Nil);
end;

function TCustomSQLStatement.LogEvent(EventType: TDBEventType): Boolean;
begin
  Result:=Assigned(Database) and Database.LogEvent(EventType);
end;

procedure TCustomSQLStatement.Log(EventType: TDBEventType; const Msg: String);
Var
  M : String;

begin
  If LogEvent(EventType) then
    begin
    If (Name<>'') then
      M:=Name
    else
      M:=ClassName;
    Database.Log(EventType,M+' : '+Msg);
    end;
end;

procedure TCustomSQLStatement.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (operation=opRemove) then
    If (AComponent=FTransaction) then
      FTransaction:=Nil
    else if (AComponent=FDatabase) then
      begin
      UnPrepare;
      FDatabase:=Nil;
      end;
end;

constructor TCustomSQLStatement.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSQL:=TStringList.Create;
  TStringList(FSQL).OnChange:=@OnChangeSQL;
  FParams:=CreateParams;
  FParamCheck:=True;
  FParseSQL:=True;
end;

destructor TCustomSQLStatement.Destroy;
begin
  UnPrepare;
  Transaction:=Nil;
  Database:=Nil;
  DataSource:=Nil;
  FreeAndNil(FDataLink);
  FreeAndNil(Fparams);
  FreeAndNil(FSQL);
  inherited Destroy;
end;

function TCustomSQLStatement.GetSchemaType: TSchemaType;

begin
  Result:=stNoSchema
end;

function TCustomSQLStatement.GetSchemaObjectName: String;
begin
  Result:='';
end;

function TCustomSQLStatement.GetSchemaPattern: String;
begin
  Result:='';
end;

function TCustomSQLStatement.IsSelectable: Boolean;
begin
  Result:=False;
end;


procedure TCustomSQLStatement.GetStatementInfo(var ASQL: String; Full: Boolean;
  ASchema: TSchemaType; out Info: TSQLStatementInfo);

begin
  Info:=Database.GetStatementInfo(ASQL,Full,ASchema);
end;

procedure TCustomSQLStatement.AllocateCursor;

begin
  if not assigned(FCursor) then
    // Do this as late as possible.
    FCursor:=Database.AllocateCursorHandle;
end;

procedure TCustomSQLStatement.DeAllocateCursor;
begin
  if Assigned(FCursor) and Assigned(Database) then
    DataBase.DeAllocateCursorHandle(FCursor);
end;

procedure TCustomSQLStatement.DoPrepare;

var
  StmType: TStatementType;
  I : TSQLStatementInfo;
begin
  if GetSchemaType=stNoSchema then
    FOrigSQL := TrimRight(FSQL.Text)
  else
    FOrigSQL := Database.GetSchemaInfoSQL(GetSchemaType, GetSchemaObjectName, GetSchemaPattern);
  if (FOrigSQL='') then
    DatabaseError(SErrNoStatement);
  FServerSQL:=FOrigSQL;
  GetStatementInfo(FServerSQL,ParseSQL,GetSchemaType,I);
  StmType:=I.StatementType;
  AllocateCursor;
  FCursor.FSelectable:=True; // let PrepareStatement and/or Execute alter it
  FCursor.FStatementType:=StmType;
  FCursor.FSchemaType:=GetSchemaType;
  If LogEvent(detPrepare) then
    Log(detPrepare,FServerSQL);
  Database.PrepareStatement(FCursor,Transaction,FServerSQL,FParams);
end;

procedure TCustomSQLStatement.Prepare;

begin
  if Prepared then exit;
  if not assigned(Database) then
    DatabaseError(SErrDatabasenAssigned);
  if not assigned(Transaction) then
    DatabaseError(SErrTransactionnSet);
  if not Database.Connected then
    Database.Open;
  if not Transaction.Active then
    Transaction.StartTransaction;
  try
    DoPrepare;
  except
    DeAllocateCursor;
    Raise;
  end;
end;

procedure TCustomSQLStatement.Execute;
begin
  Prepare;
  DoExecute;
end;

procedure TCustomSQLStatement.DoUnPrepare;

begin
  If Assigned(FCursor) then
    If Assigned(Database) then
      begin
      DataBase.UnPrepareStatement(FCursor);
      DeAllocateCursor;
      end
    else // this should never happen. It means a cursor handle leaks in the DB itself.
      FreeAndNil(FCursor);
end;

function TCustomSQLStatement.GetDataSource: TDataSource;
begin
  if Assigned(FDataLink) then
    Result:=FDataLink.DataSource
  else
    Result:=Nil;
end;

procedure TCustomSQLStatement.Unprepare;
begin
  // Some SQLConnections does not support statement [un]preparation, but they have allocated local cursor(s)
  //  so let them do cleanup f.e. cancel pending queries and/or free resultset
  //  and also do UnRegisterStatement!
  if assigned(FCursor) then
    DoUnprepare;
end;

function TCustomSQLStatement.ParamByName(const AParamName: String): TParam;
begin
  Result:=FParams.ParamByName(AParamName);
end;

function TCustomSQLStatement.RowsAffected: TRowsCount;
begin
  Result := -1;
  if not Assigned(Database) then
    Exit;
  Result:=Database.RowsAffected(FCursor);
end;

{ TSQLConnection }

function TSQLConnection.StrToStatementType(s : string) : TStatementType;

var T : TStatementType;

begin
  S:=Lowercase(s);
  for T:=stSelect to stRollback do
    if (S=StatementTokens[T]) then
      Exit(T);
  Result:=stUnknown;
end;

procedure TSQLConnection.SetTransaction(Value : TSQLTransaction);
begin
  if FTransaction<>value then
    begin
    if Assigned(FTransaction) and FTransaction.Active then
      DatabaseError(SErrAssTransaction);
    if Assigned(Value) then
      Value.Database := Self;
    FTransaction := Value;
    If Assigned(FTransaction) and (FTransaction.Database=Nil) then
      FTransaction.Database:=Self;
    end;
end;

procedure TSQLConnection.UpdateIndexDefs(IndexDefs : TIndexDefs;TableName : string);

begin
// Empty abstract
end;

procedure TSQLConnection.DoInternalConnect;
begin
  if (DatabaseName = '') and not(sqSupportEmptyDatabaseName in FConnOptions) then
    DatabaseError(SErrNoDatabaseName,self);
end;

procedure TSQLConnection.DoInternalDisconnect;

Var
  I : integer;

begin
  For I:=0 to FStatements.Count-1 do
    TCustomSQLStatement(FStatements[i]).Unprepare;
  FStatements.Clear;
end;

destructor TSQLConnection.Destroy;
begin
  Connected:=False; // needed because we want to de-allocate statements
  FreeAndNil(FStatements);
  inherited Destroy;
end;

procedure TSQLConnection.StartTransaction;
begin
  if not assigned(Transaction) then
    DatabaseError(SErrConnTransactionnSet)
  else
    Transaction.StartTransaction;
end;

procedure TSQLConnection.EndTransaction;
begin
  if not assigned(Transaction) then
    DatabaseError(SErrConnTransactionnSet)
  else
    Transaction.EndTransaction;
end;

procedure TSQLConnection.ExecuteDirect(SQL: String);

begin
  ExecuteDirect(SQL,FTransaction);
end;

procedure TSQLConnection.ExecuteDirect(SQL: String;
  ATransaction: TSQLTransaction);

var Cursor : TSQLCursor;

begin
  if not assigned(ATransaction) then
    DatabaseError(SErrTransactionnSet);

  if not Connected then Open;
  if not ATransaction.Active then ATransaction.StartTransaction;

  try
    SQL := TrimRight(SQL);
    if SQL = '' then
      DatabaseError(SErrNoStatement);

    Cursor := AllocateCursorHandle;
    Cursor.FStatementType := stUnknown;
    PrepareStatement(Cursor,ATransaction,SQL,Nil);
    Execute(Cursor,ATransaction, Nil);
    UnPrepareStatement(Cursor);
  finally;
    DeAllocateCursorHandle(Cursor);
  end;
end;

function TSQLConnection.GetPort: cardinal;
begin
  result := StrToIntDef(Params.Values['Port'],0);
end;

procedure TSQLConnection.SetPort(const AValue: cardinal);
begin
  if AValue<>0 then
    Params.Values['Port']:=IntToStr(AValue)
  else with params do if IndexOfName('Port') > -1 then
    Delete(IndexOfName('Port'));
end;

procedure TSQLConnection.GetDBInfo(const ASchemaType : TSchemaType; const ASchemaObjectName, AReturnField : string; AList: TStrings);

var qry : TCustomSQLQuery;

begin
  if not assigned(Transaction) then
    DatabaseError(SErrConnTransactionnSet);

  qry := TCustomSQLQuery.Create(nil);
  try
    qry.transaction := Transaction;
    qry.database := Self;
    with qry do
      begin
      ParseSQL := False;
      SetSchemaInfo(ASchemaType,ASchemaObjectName,'');
      open;
      AList.Clear;
      while not eof do
        begin
        AList.Append(trim(fieldbyname(AReturnField).asstring));
        Next;
        end;
      end;
  finally
    qry.free;
  end;  
end;

function TSQLConnection.RowsAffected(cursor: TSQLCursor): TRowsCount;
begin
  Result := -1;
end;


constructor TSQLConnection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSQLFormatSettings:=DefaultSQLFormatSettings;
  FFieldNameQuoteChars:=DoubleQuotes;
  FStatements:=TFPList.Create;
end;

procedure TSQLConnection.GetTableNames(List: TStrings; SystemTables: Boolean);
begin
  if not SystemTables then
    GetDBInfo(stTables,'','table_name',List)
  else
    GetDBInfo(stSysTables,'','table_name',List);
end;

procedure TSQLConnection.GetProcedureNames(List: TStrings);
begin
  GetDBInfo(stProcedures,'','proc_name',List);
end;

procedure TSQLConnection.GetFieldNames(const TableName: string; List: TStrings);
begin
  GetDBInfo(stColumns,TableName,'column_name',List);
end;

procedure TSQLConnection.GetSchemaNames(List: TStrings);
begin
  GetDBInfo(stSchemata,'','SCHEMA_NAME',List);
end;

function TSQLConnection.GetConnectionInfo(InfoType: TConnInfoType): string;
var i: TConnInfoType;
begin
  Result:='';
  if InfoType = citAll then
    for i:=citServerType to citClientVersion do
      begin
      if Result<>'' then Result:=Result+',';
      Result:=Result+'"'+GetConnectionInfo(i)+'"';
      end;
end;

function TSQLConnection.GetAsSQLText(Field : TField) : string;

begin
  if (not assigned(field)) or field.IsNull then Result := 'Null'
  else case field.DataType of
    ftString   : Result := QuotedStr(Field.AsString);
    ftDate     : Result := '''' + FormatDateTime('yyyy-mm-dd',Field.AsDateTime,FSqlFormatSettings) + '''';
    ftDateTime : Result := '''' + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz',Field.AsDateTime,FSqlFormatSettings) + '''';
    ftTime     : Result := QuotedStr(TimeIntervalToString(Field.AsDateTime));
  else
    Result := field.asstring;
  end; {case}
end;

function TSQLConnection.GetAsSQLText(Param: TParam) : string;
begin
  if (not assigned(param)) or param.IsNull then Result := 'Null'
  else case param.DataType of
    ftGuid,
    ftMemo,
    ftFixedChar,
    ftString   : Result := QuotedStr(Param.AsString);
    ftDate     : Result := '''' + FormatDateTime('yyyy-mm-dd',Param.AsDateTime,FSQLFormatSettings) + '''';
    ftTime     : Result := QuotedStr(TimeIntervalToString(Param.AsDateTime));
    ftDateTime : Result := '''' + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Param.AsDateTime, FSQLFormatSettings) + '''';
    ftCurrency,
    ftBcd      : Result := CurrToStr(Param.AsCurrency, FSQLFormatSettings);
    ftFloat    : Result := FloatToStr(Param.AsFloat, FSQLFormatSettings);
    ftFMTBcd   : Result := stringreplace(Param.AsString, DefaultFormatSettings.DecimalSeparator, FSQLFormatSettings.DecimalSeparator, []);
  else
    Result := Param.asstring;
  end; {case}
end;


function TSQLConnection.GetHandle: pointer;
begin
  Result := nil;
end;

function TSQLConnection.LogEvent(EventType: TDBEventType): Boolean;
begin
  Result:=(Assigned(FOnLog) or Assigned(GlobalDBLogHook)) and (EventType in LogEvents);
end;

procedure TSQLConnection.Log(EventType: TDBEventType; const Msg: String);

Var
  M : String;

begin
  If LogEvent(EventType) then
    begin
    If Assigned(FonLog) then
      FOnLog(Self,EventType,Msg);
    If Assigned(GlobalDBLogHook) then
      begin
      If (Name<>'') then
        M:=Name+' : '+Msg
      else
        M:=ClassName+' : '+Msg;
      GlobalDBLogHook(Self,EventType,M);
      end;
    end;
end;

procedure TSQLConnection.RegisterStatement(S: TCustomSQLStatement);
begin
  if FStatements.IndexOf(S)=-1 then
    FStatements.Add(S);
end;

procedure TSQLConnection.UnRegisterStatement(S: TCustomSQLStatement);
begin
  if Assigned(FStatements) then // Can be nil, when we are destroying and datasets are uncoupled.
    FStatements.Remove(S);
end;

procedure TSQLConnection.FreeFldBuffers(cursor: TSQLCursor);
begin
  // empty
end;

function TSQLConnection.GetSchemaInfoSQL( SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string) : string;

begin
  case SchemaType of
    stProcedures: Result := 'SELECT * FROM INFORMATION_SCHEMA.ROUTINES';
    stSchemata  : Result := 'SELECT * FROM INFORMATION_SCHEMA.SCHEMATA';
    else DatabaseError(SMetadataUnavailable);
  end;
end;

procedure TSQLConnection.CreateDB;

begin
  DatabaseError(SNotSupported);
end;

procedure TSQLConnection.DropDB;

begin
  DatabaseError(SNotSupported);
end;

{ TSQLTransaction }
procedure TSQLTransaction.EndTransaction;

begin
  Case Action of
    caCommit :
      Commit;
    caCommitRetaining :
      CommitRetaining;
    caNone,
    caRollback :
      RollBack;
    caRollbackRetaining :
      RollbackRetaining;
  end;
end;

procedure TSQLTransaction.SetParams(const AValue: TStringList);
begin
  FParams.Assign(AValue);
end;

function TSQLTransaction.GetHandle: pointer;
begin
  Result := TSQLConnection(Database).GetTransactionHandle(FTrans);
end;

procedure TSQLTransaction.Commit;
begin
  if active then
    begin
    closedatasets;
    If LogEvent(detCommit) then
      Log(detCommit,SCommitting);
    if TSQLConnection(Database).commit(FTrans) then
      begin
      closeTrans;
      FreeAndNil(FTrans);
      end;
    end;
end;

procedure TSQLTransaction.CommitRetaining;
begin
  if active then
    begin
    If LogEvent(detCommit) then
      Log(detCommit,SCommitRetaining);
    TSQLConnection(Database).commitRetaining(FTrans);
    end;
end;

procedure TSQLTransaction.Rollback;
begin
  if active then
    begin
    closedatasets;
    If LogEvent(detRollback) then
      Log(detRollback,SRollingBack);
    if TSQLConnection(Database).RollBack(FTrans) then
      begin
      CloseTrans;
      FreeAndNil(FTrans);
      end;
    end;
end;

procedure TSQLTransaction.RollbackRetaining;
begin
  if active then
    begin
    If LogEvent(detRollback) then
      Log(detRollback,SRollBackRetaining);
    TSQLConnection(Database).RollBackRetaining(FTrans);
    end;
end;

procedure TSQLTransaction.StartTransaction;

var db : TSQLConnection;

begin
  if Active then
    DatabaseError(SErrTransAlreadyActive);

  db := TSQLConnection(Database);

  if Db = nil then
    DatabaseError(SErrDatabasenAssigned);

  if not Db.Connected then
    Db.Open;
  if not assigned(FTrans) then FTrans := Db.AllocateTransactionHandle;

  if Db.StartdbTransaction(FTrans,FParams.CommaText) then OpenTrans;
end;

constructor TSQLTransaction.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FParams := TStringList.Create;
  Action:=caRollBack;
end;

destructor TSQLTransaction.Destroy;
begin
  EndTransaction;
  FreeAndNil(FTrans);
  FreeAndNil(FParams);
  inherited Destroy;
end;

Procedure TSQLTransaction.SetDatabase(Value : TDatabase);

begin
  If Value<>Database then
    begin
    if assigned(value) and not (Value is TSQLConnection) then
      DatabaseErrorFmt(SErrNotASQLConnection,[value.Name],self);
    CheckInactive;
    If Assigned(Database) then
      with TSQLConnection(DataBase) do
        if Transaction = self then Transaction := nil;
    inherited SetDatabase(Value);
    If Assigned(Database) and not (csLoading in ComponentState) then
      If (TSQLConnection(DataBase).Transaction=Nil) then
        TSQLConnection(DataBase).Transaction:=Self;
    end;
end;

function TSQLTransaction.LogEvent(EventType: TDBEventType): Boolean;
begin
  Result:=Assigned(Database) and TSQLConnection(Database).LogEvent(EventType);
end;

procedure TSQLTransaction.Log(EventType: TDBEventType; const Msg: String);

Var
  M : String;

begin
  If LogEVent(EventType) then
    begin
    If (Name<>'') then
      M:=Name+' : '+Msg
    else
      M:=Msg;
    TSQLConnection(Database).Log(EventType,M);
    end;
end;

{ TCustomSQLQuery }
(*
procedure TCustomSQLQuery.OnChangeSQL(Sender : TObject);

var ConnOptions : TConnOptions;
    NewParams: TParams;

begin
  FSchemaType:=stNoSchema;
  if (FSQL <> nil) and ParamCheck then
    begin
    if assigned(DataBase) then
      ConnOptions := TSQLConnection(DataBase).ConnOptions
    else
      ConnOptions := [sqEscapeRepeat,sqEscapeSlash];
    //preserve existing param. values
    NewParams := TParams.Create(Self);
    try
      NewParams.ParseSQL(FSQL.Text, True, sqEscapeSlash in ConnOptions, sqEscapeRepeat in ConnOptions, psInterbase);
      NewParams.AssignValues(FParams);
      FParams.Assign(NewParams);
    finally
      NewParams.Free;
    end;
    end;
end;
*)

function TCustomSQLQuery.ParamByName(const AParamName: String): TParam;

begin
  Result:=Params.ParamByName(AParamName);
end;

procedure TCustomSQLQuery.OnChangeModifySQL(Sender : TObject);

begin
  CheckInactive;
end;

procedure TCustomSQLQuery.SetTransaction(Value: TDBTransaction);

begin
  UnPrepare;
  inherited;
  If Assigned(FStatement) then
    FStatement.Transaction:=TSQLTransaction(Value);
  If (Transaction<>Nil) and (Database=Nil) then
    Database:=TSQLTransaction(Transaction).Database;
end;

procedure TCustomSQLQuery.SetDatabase(Value : TDatabase);

var db : tsqlconnection;

begin
  if (Database <> Value) then
    begin
    if assigned(value) and not (Value is TSQLConnection) then
      DatabaseErrorFmt(SErrNotASQLConnection,[value.Name],self);
    UnPrepare;
    db := TSQLConnection(Value);
    If Assigned(FStatement) then
      FStatement.Database:=DB;
    inherited setdatabase(value);
(*
     FStatement.Database:=Db,
    if assigned(FCursor) then TSQLConnection(DataBase).DeAllocateCursorHandle(FCursor);
*)
    if assigned(value) and (Transaction = nil) and (Assigned(db.Transaction)) then
      transaction := Db.Transaction;
//    FStatement.OnChangeSQL(Self);
    end;
end;

function TCustomSQLQuery.IsPrepared: Boolean;

begin
  if Assigned(Fstatement) then
    Result := FStatement.Prepared
  else
    Result := False;
end;

function TCustomSQLQuery.AddFilter(SQLstr: string): string;

begin
  if (FWhereStartPos > 0) and (FWhereStopPos > 0) then
    begin
    system.insert('(',SQLstr,FWhereStartPos+1);
    system.insert(')',SQLstr,FWhereStopPos+1);
    end;

  if FWhereStartPos = 0 then
    SQLstr := SQLstr + ' where (' + ServerFilter + ')'
  else if FWhereStopPos > 0 then
    system.insert(' and ('+ServerFilter+') ',SQLstr,FWhereStopPos+2)
  else
    system.insert(' where ('+ServerFilter+') ',SQLstr,FWhereStartPos);
  Result := SQLstr;
end;

procedure TCustomSQLQuery.ApplyFilter;

var S : String;

begin
  FreeFldBuffers;
  FStatement.Unprepare;
  FIsEOF := False;
  inherited InternalClose;
  FStatement.DoPrepare;
  FStatement.DoExecute;
  inherited InternalOpen;
  First;
end;

procedure TCustomSQLQuery.SetActive(Value: Boolean);

begin
  inherited SetActive(Value);
// The query is UnPrepared, so that if a transaction closes all datasets
// they also get unprepared
  if not Value and IsPrepared then UnPrepare;
end;


procedure TCustomSQLQuery.SetServerFiltered(Value: Boolean);

begin
  if Value and not ParseSQL then
    DatabaseErrorFmt(SNoParseSQL,['Filtering ']);
  if (ServerFiltered <> Value) then
    begin
    FServerFiltered := Value;
    if active then
      ApplyFilter;
    end;
end;

procedure TCustomSQLQuery.SetServerFilterText(const Value: string);
begin
  if Value <> ServerFilter then
    begin
    FServerFilterText := Value;
    if active then ApplyFilter;
    end;
end;

procedure TCustomSQLQuery.Prepare;

begin
  FStatement.Prepare;
  If Assigned(Fstatement.FCursor) then
    With FStatement.FCursor do
      FInitFieldDef:=FSelectable;
end;

procedure TCustomSQLQuery.UnPrepare;

begin
  CheckInactive;
  If Assigned(FStatement) then
    FStatement.Unprepare;
end;

procedure TCustomSQLQuery.FreeFldBuffers;
begin
  if assigned(Cursor) then
     TSQLConnection(Database).FreeFldBuffers(Cursor);
end;

function TCustomSQLQuery.GetParamCheck: Boolean;
begin
  Result:=FStatement.ParamCheck;
end;

function TCustomSQLQuery.GetParams: TParams;
begin
  Result:=FStatement.Params;
end;

function TCustomSQLQuery.GetParseSQL: Boolean;
begin
  Result:=FStatement.ParseSQL;
end;

function TCustomSQLQuery.GetServerIndexDefs: TServerIndexDefs;
begin
  Result := FServerIndexDefs;
end;

function TCustomSQLQuery.GetSQL: TStringlist;
begin
  Result:=TStringList(Fstatement.SQL);
end;

function TCustomSQLQuery.Fetch : boolean;
begin
  if Not Assigned(Cursor) then
    Exit;
  if not Cursor.FSelectable then
    Exit;
  If LogEvent(detFetch) then
    Log(detFetch,FSQLBuf);
  if not FIsEof then FIsEOF := not TSQLConnection(Database).Fetch(Cursor);
  Result := not FIsEOF;
end;

function TCustomSQLQuery.Cursor: TSQLCursor;
begin
  Result:=FStatement.Cursor;
end;

procedure TCustomSQLQuery.Execute;
begin
  FStatement.Execute;
end;

function TCustomSQLQuery.RowsAffected: TRowsCount;
begin
  Result:=Fstatement.RowsAffected;
end;

function TCustomSQLQuery.LoadField(FieldDef : TFieldDef;buffer : pointer; out CreateBlob : boolean) : boolean;
begin
  result := TSQLConnection(Database).LoadField(Cursor,FieldDef,buffer, Createblob)
end;

procedure TCustomSQLQuery.LoadBlobIntoBuffer(FieldDef: TFieldDef;
  ABlobBuf: PBufBlobField);
begin
  TSQLConnection(DataBase).LoadBlobIntoBuffer(FieldDef, ABlobBuf, Cursor,(Transaction as TSQLTransaction));
end;

procedure TCustomSQLQuery.InternalAddRecord(Buffer: Pointer; AAppend: Boolean);
begin
  // not implemented - sql dataset
end;

procedure TCustomSQLQuery.InternalClose;
begin
  if assigned(Cursor) then
    begin
    if Cursor.FSelectable then
      FreeFldBuffers;
    // Some SQLConnections does not support statement [un]preparation,
    //  so let them do cleanup f.e. cancel pending queries and/or free resultset
    if not Prepared then FStatement.DoUnprepare;
    end;
  if DefaultFields then
    DestroyFields;
  FIsEOF := False;
  if assigned(FUpdateQry) then FreeAndNil(FUpdateQry);
  if assigned(FInsertQry) then FreeAndNil(FInsertQry);
  if assigned(FDeleteQry) then FreeAndNil(FDeleteQry);
//  FRecordSize := 0;
  inherited InternalClose;
end;

procedure TCustomSQLQuery.InternalInitFieldDefs;
begin
  if FLoadingFieldDefs then
    Exit;

  FLoadingFieldDefs := True;

  try
    FieldDefs.Clear;
    if not Assigned(Database) then DatabaseError(SErrDatabasenAssigned);
    TSQLConnection(Database).AddFieldDefs(Cursor,FieldDefs);
  finally
    FLoadingFieldDefs := False;
    if Assigned(Cursor) then Cursor.FInitFieldDef := false;
  end;
end;



(*
function TCustomSQLQuery.SQLParser(const ASQL : string) : TStatementType;

Var
  I : TSQLStatementInfo;

begin
  I:=(Database as TSQLConnection).GetStatementInfo(ASQL,ParseSQL,SchemaType);
  FTableName:=I.TableName;
  FUpdateable:=I.Updateable;
  FWhereStartPos:=I.WhereStartPos;
  FWhereStopPos:=I.WhereStopPos;
  Result:=I.StatementType;
end;
*)

function TSQLConnection.GetStatementInfo(const ASQL: string; Full: Boolean;
  ASchema: TSchemaType): TSQLStatementInfo;


type TParsePart = (ppStart,ppWith,ppSelect,ppTableName,ppFrom,ppWhere,ppGroup,ppOrder,ppBogus);
     TPhraseSeparator = (sepNone, sepWhiteSpace, sepComma, sepComment, sepParentheses, sepDoubleQuote, sepEnd);
     TKeyword = (kwWITH, kwSELECT, kwINSERT, kwUPDATE, kwDELETE, kwFROM, kwJOIN, kwWHERE, kwGROUP, kwORDER, kwUNION, kwROWS, kwLIMIT, kwUnknown);

const
  KeywordNames: array[TKeyword] of string =
    ('WITH', 'SELECT', 'INSERT', 'UPDATE', 'DELETE', 'FROM', 'JOIN', 'WHERE', 'GROUP', 'ORDER', 'UNION', 'ROWS', 'LIMIT', '');

var
  PSQL, CurrentP, SavedP,
  PhraseP, PStatementPart : pchar;
  S                       : string;
  ParsePart               : TParsePart;
  BracketCount            : Integer;
  Separator               : TPhraseSeparator;
  Keyword, K              : TKeyword;

begin
  PSQL:=Pchar(ASQL);
  ParsePart := ppStart;

  CurrentP := PSQL-1;
  PhraseP := PSQL;

  Result.TableName := '';
  Result.Updateable := False;
  Result.WhereStartPos := 0;
  Result.WhereStopPos := 0;

  repeat
    begin
    inc(CurrentP);
    SavedP := CurrentP;

    case CurrentP^ of
      ' ', #9..#13:
        Separator := sepWhiteSpace;
      ',':
        Separator := sepComma;
      #0, ';':
        Separator := sepEnd;
      '(':
        begin
        Separator := sepParentheses;
        // skip everything between brackets, since it could be a sub-select, and
        // further nothing between brackets could be interesting for the parser.
        BracketCount := 1;
        repeat
          inc(CurrentP);
          if CurrentP^ = '(' then inc(BracketCount)
          else if CurrentP^ = ')' then dec(BracketCount);
        until (CurrentP^ = #0) or (BracketCount = 0);
        if CurrentP^ <> #0 then inc(CurrentP);
        end;
      '"','`':
        if SkipComments(CurrentP, sqEscapeSlash in ConnOptions, sqEscapeRepeat in ConnOptions) then
          Separator := sepDoubleQuote;
      else
        if SkipComments(CurrentP, sqEscapeSlash in ConnOptions, sqEscapeRepeat in ConnOptions) then
          Separator := sepComment
        else
          Separator := sepNone;
    end;

    if (CurrentP > SavedP) and (SavedP > PhraseP) then
      CurrentP := SavedP;  // there is something before comment or left parenthesis

    if Separator <> sepNone then
      begin
      if ((Separator in [sepWhitespace,sepComment]) and (PhraseP = SavedP)) then
        PhraseP := CurrentP;  // skip comments (but not parentheses) and white spaces

      if (CurrentP-PhraseP > 0) or (Separator = sepEnd) then
        begin
        SetString(s, PhraseP, CurrentP-PhraseP);

        Keyword := kwUnknown;
        for K in TKeyword do
          if SameText(s, KeywordNames[K]) then
          begin
            Keyword := K;
            break;
          end;

        case ParsePart of
          ppStart  : begin
                     Result.StatementType := StrToStatementType(s);
                     case Keyword of
                       kwWITH  : ParsePart := ppWith;
                       kwSELECT: ParsePart := ppSelect;
                       else      break;
                     end;
                     if not Full then break;
                     end;
          ppWith   : begin
                     // WITH [RECURSIVE] CTE_name [ ( column_names ) ] AS ( CTE_query_definition ) [, ...]
                     //  { SELECT | INSERT | UPDATE | DELETE } ...
                     case Keyword of
                       kwSELECT: Result.StatementType := stSelect;
                       kwINSERT: Result.StatementType := stInsert;
                       kwUPDATE: Result.StatementType := stUpdate;
                       kwDELETE: Result.StatementType := stDelete;
                     end;
                     if Result.StatementType <> stUnknown then break;
                     end;
          ppSelect : begin
                     if Keyword = kwFROM then
                       ParsePart := ppTableName;
                     end;
          ppTableName:
                     begin
                     // Meta-data requests are never updateable
                     //  and select statements from more than one table
                     //  and/or derived tables are also not updateable
                     if (ASchema = stNoSchema) and
                        (Separator in [sepWhitespace, sepComment, sepDoubleQuote, sepEnd]) then
                       begin
                       Result.TableName := s;
                       Result.Updateable := True;
                       end;
                     ParsePart := ppFrom;
                     end;
          ppFrom   : begin
                     if (Keyword in [kwWHERE, kwGROUP, kwORDER, kwLIMIT, kwROWS]) or
                        (Separator = sepEnd) then
                       begin
                       case Keyword of
                         kwWHERE: ParsePart := ppWhere;
                         kwGROUP: ParsePart := ppGroup;
                         kwORDER: ParsePart := ppOrder;
                         else     ParsePart := ppBogus;
                       end;

                       Result.WhereStartPos := PhraseP-PSQL+1;
                       PStatementPart := CurrentP;
                       end
                     else
                     // joined table or user_defined_function (...)
                     if (Keyword = kwJOIN) or (Separator in [sepComma, sepParentheses]) then
                       begin
                       Result.TableName := '';
                       Result.Updateable := False;
                       end;
                     end;
          ppWhere  : begin
                     if (Keyword in [kwGROUP, kwORDER, kwLIMIT, kwROWS]) or
                        (Separator = sepEnd) then
                       begin
                       ParsePart := ppBogus;
                       Result.WhereStartPos := PStatementPart-PSQL;
                       if (Separator = sepEnd) then
                         Result.WhereStopPos := CurrentP-PSQL+1
                       else
                         Result.WhereStopPos := PhraseP-PSQL+1;
                       end
                     else if (Keyword = kwUNION) then
                       begin
                       ParsePart := ppBogus;
                       Result.Updateable := False;
                       end;
                     end;
        end; {case}
        end;
      if Separator in [sepComment, sepParentheses, sepDoubleQuote] then
        dec(CurrentP);
      PhraseP := CurrentP+1;
      end
    end;
  until CurrentP^=#0;
end;

procedure TCustomSQLQuery.InternalOpen;

var counter, fieldc : integer;
    f               : TField;
    IndexFields     : TStrings;
begin
  if IsReadFromPacket then
    begin
    // When we read from file there is no need for Cursor, also note that Database may not be assigned
    //FStatement.AllocateCursor;
    //Cursor.FSelectable:=True;
    //Cursor.FStatementType:=stSelect;
    FUpdateable:=True;
    BindFields(True);
    end
  else
    begin
    Prepare;
    if not Cursor.FSelectable then
      DatabaseError(SErrNoSelectStatement,Self);

    // Call UpdateServerIndexDefs before Execute, to avoid problems with connections
    // which do not allow processing multiple recordsets at a time. (Microsoft
    // calls this MARS, see bug 13241)
    if DefaultFields and FUpdateable and FusePrimaryKeyAsKey and (not IsUniDirectional) then
      UpdateServerIndexDefs;

    Execute;
    if not Cursor.FSelectable then
      DatabaseError(SErrNoSelectStatement,Self);

    // InternalInitFieldDef is only called after a prepare. i.e. not twice if
    // a dataset is opened - closed - opened.
    if Cursor.FInitFieldDef then InternalInitFieldDefs;
    if DefaultFields then
      begin
      CreateFields;

      if FUpdateable and (not IsUniDirectional) then
        begin
        if FusePrimaryKeyAsKey then
          begin
          for counter := 0 to ServerIndexDefs.count-1 do
            begin
            if ixPrimary in ServerIndexDefs[counter].options then
              begin
                IndexFields := TStringList.Create;
                ExtractStrings([';'],[' '],pchar(ServerIndexDefs[counter].fields),IndexFields);
                for fieldc := 0 to IndexFields.Count-1 do
                  begin
                  F := Findfield(IndexFields[fieldc]);
                  if F <> nil then
                    F.ProviderFlags := F.ProviderFlags + [pfInKey];
                  end;
                IndexFields.Free;
              end;
            end;
          end;
        end;
      end
    else
      BindFields(True);
    end;

  if not ReadOnly and not FUpdateable and (FSchemaType=stNoSchema) then
    begin
    if (trim(FDeleteSQL.Text) <> '') or (trim(FUpdateSQL.Text) <> '') or
       (trim(FInsertSQL.Text) <> '') then FUpdateable := True;
    end;

  inherited InternalOpen;
end;

// public part

procedure TCustomSQLQuery.ExecSQL;
begin
  try
    Prepare;
    Execute;
  finally
    // Cursor has to be assigned, or else the prepare went wrong before PrepareStatment was
    //   called, so UnPrepareStatement shoudn't be called either
    // Don't deallocate cursor; f.e. RowsAffected is requested later
    if not Prepared and (assigned(Database)) and (assigned(Cursor)) then TSQLConnection(Database).UnPrepareStatement(Cursor);
  end;
end;

Type

  { TQuerySQLStatement }

  TQuerySQLStatement = Class(TCustomSQLStatement)
  protected
    FQuery : TCustomSQLQuery;
    Function CreateDataLink : TDataLink; override;
    Function GetSchemaType : TSchemaType; override;
    Function GetSchemaObjectName : String; override;
    Function GetSchemaPattern: String; override;
    procedure GetStatementInfo(Var ASQL: String; Full: Boolean; ASchema: TSchemaType; out Info: TSQLStatementInfo); override;
    procedure OnChangeSQL(Sender : TObject); override;
  end;

{ TQuerySQLStatement }

function TQuerySQLStatement.CreateDataLink: TDataLink;
begin
  Result:=TMasterParamsDataLink.Create(FQuery);
end;

function TQuerySQLStatement.GetSchemaType: TSchemaType;
begin
  if Assigned(FQuery) then
    Result:=FQuery.FSchemaType
  else
    Result:=stNoSchema;
end;

function TQuerySQLStatement.GetSchemaObjectName: String;
begin
  if Assigned(FQuery) then
    Result:=FQuery.FSchemaObjectname
  else
    Result:=inherited GetSchemaObjectName;
end;

function TQuerySQLStatement.GetSchemaPattern: String;
begin
  if Assigned(FQuery) then
    Result:=FQuery.FSchemaPattern
  else
    Result:=inherited GetSchemaPattern;
end;

procedure TQuerySQLStatement.GetStatementInfo(var ASQL: String; Full: Boolean;
  ASchema: TSchemaType; out Info: TSQLStatementInfo);
begin
  inherited GetStatementInfo(ASQL, Full, ASchema, Info);
  If Assigned(FQuery) then
    begin
    FQuery.FWhereStartPos:=Info.WhereStartPos;
    FQuery.FWhereStopPos:=Info.WhereStopPos;
    FQuery.FUpdateable:=info.Updateable;
    FQuery.FTableName:=Info.TableName;
    if FQuery.ServerFiltered then
      ASQL:=FQuery.AddFilter(ASQL);
    end;
end;

procedure TQuerySQLStatement.OnChangeSQL(Sender: TObject);
begin
  UnPrepare;
  inherited OnChangeSQL(Sender);
  If ParamCheck and Assigned(FDataLink) then
    (FDataLink as TMasterParamsDataLink).RefreshParamNames;
  FQuery.ServerIndexDefs.Updated:=false;
end;

constructor TCustomSQLQuery.Create(AOwner : TComponent);

Var
  F : TQuerySQLStatement;

begin
  inherited Create(AOwner);
  F:=TQuerySQLStatement.Create(Self);
  F.FQuery:=Self;
  FStatement:=F;

  //FSQL := TStringList.Create;
  // FSQL.OnChange := @OnChangeSQL;

  FUpdateSQL := TStringList.Create;
  FUpdateSQL.OnChange := @OnChangeModifySQL;
  FInsertSQL := TStringList.Create;
  FInsertSQL.OnChange := @OnChangeModifySQL;
  FDeleteSQL := TStringList.Create;
  FDeleteSQL.OnChange := @OnChangeModifySQL;

  FServerIndexDefs := TServerIndexDefs.Create(Self);

  FServerFiltered := False;
  FServerFilterText := '';

  FSchemaType:=stNoSchema;
  FSchemaObjectName:='';
  FSchemaPattern:='';

// Delphi has upWhereAll as default, but since strings and oldvalue's don't work yet
// (variants) set it to upWhereKeyOnly
  FUpdateMode := upWhereKeyOnly;
  FUsePrimaryKeyAsKey := True;
end;

destructor TCustomSQLQuery.Destroy;
begin
  if Active then Close;
  UnPrepare;
  FreeAndNil(Fstatement);
//  FreeAndNil(FSQL);
  FreeAndNil(FInsertSQL);
  FreeAndNil(FDeleteSQL);
  FreeAndNil(FUpdateSQL);
  FServerIndexDefs.Free;
  inherited Destroy;
end;

procedure TCustomSQLQuery.SetReadOnly(AValue : Boolean);

begin
  CheckInactive;
  inherited SetReadOnly(AValue);
end;

procedure TCustomSQLQuery.SetParseSQL(AValue : Boolean);

begin
  CheckInactive;
  FStatement.ParseSQL:=AValue;
  if not AValue then
    FServerFiltered := False;
end;

procedure TCustomSQLQuery.SetSQL(const AValue: TStringlist);
begin
  FStatement.SQL.Assign(AValue);
end;

procedure TCustomSQLQuery.SetUpdateSQL(const AValue: TStringlist);
begin
  FUpdateSQL.Assign(AValue);
end;

procedure TCustomSQLQuery.SetUsePrimaryKeyAsKey(AValue : Boolean);

begin
  if not Active then FusePrimaryKeyAsKey := AValue
  else
    begin
    // Just temporary, this should be possible in the future
    DatabaseError(SActiveDataset);
    end;
end;

procedure TCustomSQLQuery.UpdateServerIndexDefs;

begin
  FServerIndexDefs.Clear;
  if assigned(DataBase) and (FTableName<>'') then
    TSQLConnection(DataBase).UpdateIndexDefs(ServerIndexDefs,FTableName);
end;

procedure TCustomSQLQuery.ApplyRecUpdate(UpdateKind: TUpdateKind);

var FieldNamesQuoteChars : TQuoteChars;

  function InitialiseModifyQuery(var qry : TCustomSQLQuery): TCustomSQLQuery;

  begin
    if not assigned(qry) then
    begin
      qry := TCustomSQLQuery.Create(nil);
      qry.ParseSQL := False;
      qry.DataBase := Self.DataBase;
      qry.Transaction := Self.Transaction;
    end;
    Result:=qry;
  end;

  procedure UpdateWherePart(var sql_where : string;x : integer);

  begin
    if (pfInKey in Fields[x].ProviderFlags) or
       ((FUpdateMode = upWhereAll) and (pfInWhere in Fields[x].ProviderFlags)) or
       ((FUpdateMode = UpWhereChanged) and (pfInWhere in Fields[x].ProviderFlags) and (Fields[x].Value <> Fields[x].OldValue)) then
       if Fields[x].OldValue = NULL then
          sql_where := sql_where + FieldNamesQuoteChars[0] + Fields[x].FieldName + FieldNamesQuoteChars[1] + ' is null and '
       else
          sql_where := sql_where + '(' + FieldNamesQuoteChars[0] + Fields[x].FieldName + FieldNamesQuoteChars[1] + '= :"' + 'OLD_' + Fields[x].FieldName + '") and ';
  end;

  function ModifyRecQuery : string;

  var x          : integer;
      sql_set    : string;
      sql_where  : string;

  begin
    sql_set := '';
    sql_where := '';
    for x := 0 to Fields.Count -1 do
      begin
      UpdateWherePart(sql_where,x);

      if (pfInUpdate in Fields[x].ProviderFlags) and (not Fields[x].ReadOnly) then
        sql_set := sql_set +FieldNamesQuoteChars[0] + fields[x].FieldName + FieldNamesQuoteChars[1] +'=:"' + fields[x].FieldName + '",';
      end;

    if length(sql_set) = 0 then DatabaseErrorFmt(sNoUpdateFields,['update'],self);
    setlength(sql_set,length(sql_set)-1);
    if length(sql_where) = 0 then DatabaseErrorFmt(sNoWhereFields,['update'],self);
    setlength(sql_where,length(sql_where)-5);
    result := 'update ' + FTableName + ' set ' + sql_set + ' where ' + sql_where;

  end;

  function InsertRecQuery : string;

  var x          : integer;
      sql_fields : string;
      sql_values : string;

  begin
    sql_fields := '';
    sql_values := '';
    for x := 0 to Fields.Count -1 do
      begin
      if (not Fields[x].IsNull) and (pfInUpdate in Fields[x].ProviderFlags) and (not Fields[x].ReadOnly) then
        begin
        sql_fields := sql_fields + FieldNamesQuoteChars[0] + fields[x].FieldName + FieldNamesQuoteChars[1] + ',';
        sql_values := sql_values + ':"' + fields[x].FieldName + '",';
        end;
      end;
    if length(sql_fields) = 0 then DatabaseErrorFmt(sNoUpdateFields,['insert'],self);
    setlength(sql_fields,length(sql_fields)-1);
    setlength(sql_values,length(sql_values)-1);

    result := 'insert into ' + FTableName + ' (' + sql_fields + ') values (' + sql_values + ')';
  end;

  function DeleteRecQuery : string;

  var x          : integer;
      sql_where  : string;

  begin
    sql_where := '';
    for x := 0 to Fields.Count -1 do
      UpdateWherePart(sql_where,x);

    if length(sql_where) = 0 then DatabaseErrorFmt(sNoWhereFields,['delete'],self);
    setlength(sql_where,length(sql_where)-5);

    result := 'delete from ' + FTableName + ' where ' + sql_where;
  end;

var qry : TCustomSQLQuery;
    s   : string;
    x   : integer;
    Fld : TField;

begin
  FieldNamesQuoteChars := TSQLConnection(DataBase).FieldNameQuoteChars;

  case UpdateKind of
    ukInsert : begin
               s := trim(FInsertSQL.Text);
               if s = '' then s := InsertRecQuery;
               qry := InitialiseModifyQuery(FInsertQry);
               end;
    ukModify : begin
               s := trim(FUpdateSQL.Text);
               if (s='') and (not assigned(FUpdateQry) or (UpdateMode<>upWhereKeyOnly)) then //first time or dynamic where part
                 s := ModifyRecQuery;
               qry := InitialiseModifyQuery(FUpdateQry);
               end;
    ukDelete : begin
               s := trim(FDeleteSQL.Text);
               if (s='') and (not assigned(FDeleteQry) or (UpdateMode<>upWhereKeyOnly)) then
                 s := DeleteRecQuery;
               qry := InitialiseModifyQuery(FDeleteQry);
               end;
  end;
  if (qry.SQL.Text<>s) and (s<>'') then qry.SQL.Text:=s; //assign only when changed, to avoid UnPrepare/Prepare
  assert(qry.sql.Text<>'');
  with qry do
    begin
    for x := 0 to Params.Count-1 do with params[x] do if sametext(leftstr(name,4),'OLD_') then
      begin
      Fld := self.FieldByName(copy(name,5,length(name)-4));
      AssignFieldValue(Fld,Fld.OldValue);
      end
    else
      begin
      Fld := self.FieldByName(name);
      AssignFieldValue(Fld,Fld.Value);
      end;
    execsql;
    end;
end;


function TCustomSQLQuery.GetCanModify: Boolean;

begin
  // the test for assigned(Cursor) is needed for the case that the dataset isn't opened
  if assigned(Cursor) and (Cursor.FStatementType = stSelect) then
    Result:= FUpdateable and (not ReadOnly) and (not IsUniDirectional)
  else
    Result := False;
end;

procedure TCustomSQLQuery.SetUpdateMode(AValue : TUpdateMode);

begin
  FUpdateMode := AValue;
end;

procedure TCustomSQLQuery.SetSchemaInfo( ASchemaType : TSchemaType; ASchemaObjectName, ASchemaPattern : string);

begin
  FSchemaType:=ASchemaType;
  FSchemaObjectName:=ASchemaObjectName;
  FSchemaPattern:=ASchemaPattern;
end;

procedure TCustomSQLQuery.BeforeRefreshOpenCursor;
begin
  // This is only necessary because TIBConnection can not re-open a
  // prepared cursor. In fact this is wrong, but has never led to
  // problems because in SetActive(false) queries are always
  // unprepared. (which is also wrong, but has to be fixed later)
  if IsPrepared then with TSQLConnection(DataBase) do
    UnPrepareStatement(Cursor);
end;

function TCustomSQLQuery.LogEvent(EventType: TDBEventType): Boolean;
begin
  Result:=Assigned(Database) and TSQLConnection(Database).LogEvent(EventType);
end;

procedure TCustomSQLQuery.Log(EventType: TDBEventType; const Msg: String);

Var
  M : String;

begin
  If LogEvent(EventType) then
    begin
    M:=Msg;
    If (Name<>'') then
      M:=Name+' : '+M;
    TSQLConnection(Database).Log(EventType,M);
    end;
end;

function TCustomSQLQuery.GetStatementType : TStatementType;

begin
  if Assigned(Cursor) then
    Result:=Cursor.FStatementType
  else
    Result:=stUnknown;
end;

procedure TCustomSQLQuery.SetParamCheck(AValue: Boolean);
begin
  FStatement.ParamCheck:=AValue;
end;

procedure TCustomSQLQuery.SetDeleteSQL(const AValue: TStringlist);
begin
  FDeleteSQL.Assign(AValue);
end;

procedure TCustomSQLQuery.SetInsertSQL(const AValue: TStringlist);
begin
  FInsertSQL.Assign(AValue);
end;

procedure TCustomSQLQuery.SetParams(AValue: TParams);
begin
  FStatement.Params.Assign(AValue);
end;

procedure TCustomSQLQuery.SetDataSource(AValue: TDataSource);

Var
  DS : TDataSource;

begin
  DS:=DataSource;
  If (AValue<>DS) then
    begin
    If Assigned(AValue) and (AValue.Dataset=Self) then
      DatabaseError(SErrCircularDataSourceReferenceNotAllowed,Self);
    If Assigned(DS) then
      DS.RemoveFreeNotification(Self);
    FStatement.DataSource:=AValue;
    end;
end;

function TCustomSQLQuery.GetDataSource: TDataSource;

begin
  If Assigned(FStatement) then
    Result:=FStatement.DataSource
  else
    Result:=Nil;
end;

procedure TCustomSQLQuery.Notification(AComponent: TComponent; Operation: TOperation);

begin
  Inherited;
  If (Operation=opRemove) and (AComponent=DataSource) then
    DataSource:=Nil;
end;

{ TSQLScript }

procedure TSQLScript.ExecuteStatement(SQLStatement: TStrings;
  var StopExecution: Boolean);
begin
  fquery.SQL.assign(SQLStatement);
  fquery.ExecSQL;
end;

procedure TSQLScript.ExecuteDirective(Directive, Argument: String;
  var StopExecution: Boolean);
begin
  if assigned (FOnDirective) then
    FOnDirective (Self, Directive, Argument, StopExecution);
end;

procedure TSQLScript.ExecuteCommit(CommitRetaining: boolean=true);
begin
  if FTransaction is TSQLTransaction then
    if CommitRetaining then
      TSQLTransaction(FTransaction).CommitRetaining
    else
      begin
      TSQLTransaction(FTransaction).Commit;
      TSQLTransaction(FTransaction).StartTransaction;
      end
  else
    begin
    FTransaction.Active := false;
    FTransaction.Active := true;
    end;
end;

procedure TSQLScript.SetDatabase(Value: TDatabase);
begin
  FDatabase := Value;
end;

procedure TSQLScript.SetTransaction(Value: TDBTransaction);
begin
  FTransaction := Value;
end;

procedure TSQLScript.CheckDatabase;
begin
  If (FDatabase=Nil) then
    DatabaseError(SErrNoDatabaseAvailable,Self)
end;

constructor TSQLScript.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FQuery := TCustomSQLQuery.Create(nil);
  FQuery.ParamCheck := false; // Do not parse for parameters; breaks use of e.g. select bla into :bla in Firebird procedures
end;

destructor TSQLScript.Destroy;
begin
  FQuery.Free;
  inherited Destroy;
end;

procedure TSQLScript.Execute;
begin
  FQuery.DataBase := FDatabase;
  FQuery.Transaction := FTransaction;
  inherited Execute;
end;

procedure TSQLScript.ExecuteScript;
begin
  Execute;
end;


{ Connection definitions }

Var
  ConnDefs : TStringList;

Procedure CheckDefs;

begin
  If (ConnDefs=Nil) then
    begin
    ConnDefs:=TStringList.Create;
    ConnDefs.Sorted:=True;
    ConnDefs.Duplicates:=dupError;
    end;
end;

Procedure DoneDefs;

Var
  I : Integer;


begin
  If Assigned(ConnDefs) then
    begin
    For I:=ConnDefs.Count-1 downto 0 do
      begin
      ConnDefs.Objects[i].Free;
      ConnDefs.Delete(I);
      end;
    FreeAndNil(ConnDefs);
    end;
end;


Function GetConnectionDef(ConnectorName : String) : TConnectionDef;

Var
  I : Integer;

begin
  CheckDefs;
  I:=ConnDefs.IndexOf(ConnectorName);
  If (I<>-1) then
    Result:=TConnectionDef(ConnDefs.Objects[i])
  else
    Result:=Nil;
end;

procedure RegisterConnection(Def: TConnectionDefClass);

Var
  I : Integer;

begin
  CheckDefs;
  I:=ConnDefs.IndexOf(Def.TypeName);
  If (I=-1) then
    ConnDefs.AddObject(Def.TypeName,Def.Create)
  else
    begin
    ConnDefs.Objects[I].Free;
    ConnDefs.Objects[I]:=Def.Create;
    end;
end;

procedure UnRegisterConnection(Def: TConnectionDefClass);
begin
  UnRegisterConnection(Def.TypeName);
end;

procedure UnRegisterConnection(ConnectionName: String);

Var
  I : Integer;

begin
  if (ConnDefs<>Nil) then
    begin
    I:=ConnDefs.IndexOf(ConnectionName);
    If (I<>-1) then
      begin
      ConnDefs.Objects[I].Free;
      ConnDefs.Delete(I);
      end;
    end;
end;

procedure GetConnectionList(List: TSTrings);
begin
  CheckDefs;
  List.Text:=ConnDefs.Text;
end;

{ TSQLConnector }

procedure TSQLConnector.SetConnectorType(const AValue: String);
begin
  if FConnectorType<>AValue then
    begin
    CheckDisconnected;
    If Assigned(FProxy) then
      FreeProxy;
    FConnectorType:=AValue;
    end;
end;

procedure TSQLConnector.SetTransaction(Value: TSQLTransaction);
begin
  inherited SetTransaction(Value);
  If Assigned(FProxy) and (FProxy.Transaction<>Value) then
    FProxy.FTransaction:=Value;
end;

procedure TSQLConnector.DoInternalConnect;

Var
  D : TConnectionDef;

begin
  inherited DoInternalConnect;
  CreateProxy;
  FProxy.CharSet:=Self.CharSet;
  FProxy.Role:=Self.Role;
  FProxy.DatabaseName:=Self.DatabaseName;
  FProxy.HostName:=Self.HostName;
  FProxy.UserName:=Self.UserName;
  FProxy.Password:=Self.Password;
  FProxy.FTransaction:=Self.Transaction;
  D:=GetConnectionDef(ConnectorType);
  D.ApplyParams(Params,FProxy);
  FProxy.Connected:=True;
end;

procedure TSQLConnector.DoInternalDisconnect;
begin
  FProxy.Connected:=False;
  inherited DoInternalDisconnect;
end;

procedure TSQLConnector.CheckProxy;
begin
  If (FProxy=Nil) then
    CreateProxy;
end;

procedure TSQLConnector.CreateProxy;

Var
  D : TConnectionDef;

begin
  D:=GetConnectionDef(ConnectorType);
  If (D=Nil) then
    DatabaseErrorFmt(SErrUnknownConnectorType,[ConnectorType],Self);
  FProxy:=D.ConnectionClass.Create(Self);
  FFieldNameQuoteChars := FProxy.FieldNameQuoteChars;
end;

procedure TSQLConnector.FreeProxy;
begin
  FProxy.Connected:=False;
  FreeAndNil(FProxy);
end;

function TSQLConnector.StrToStatementType(s: string): TStatementType;
begin
  CheckProxy;
  Result:=FProxy.StrToStatementType(s);
end;

function TSQLConnector.GetAsSQLText(Field: TField): string;
begin
  CheckProxy;
  Result:=FProxy.GetAsSQLText(Field);
end;

function TSQLConnector.GetAsSQLText(Param: TParam): string;
begin
  CheckProxy;
  Result:=FProxy.GetAsSQLText(Param);
end;

function TSQLConnector.GetHandle: pointer;
begin
  CheckProxy;
  Result:=FProxy.GetHandle;
end;

function TSQLConnector.AllocateCursorHandle: TSQLCursor;
begin
  CheckProxy;
  Result:=FProxy.AllocateCursorHandle;
end;

procedure TSQLConnector.DeAllocateCursorHandle(var cursor: TSQLCursor);
begin
  CheckProxy;
  FProxy.DeAllocateCursorHandle(cursor);
end;

function TSQLConnector.AllocateTransactionHandle: TSQLHandle;
begin
  CheckProxy;
  Result:=FProxy.AllocateTransactionHandle;
end;

procedure TSQLConnector.PrepareStatement(cursor: TSQLCursor;
  ATransaction: TSQLTransaction; buf: string; AParams: TParams);
begin
  CheckProxy;
  FProxy.PrepareStatement(cursor, ATransaction, buf, AParams);
end;

procedure TSQLConnector.Execute(cursor: TSQLCursor;
  atransaction: tSQLtransaction; AParams: TParams);
begin
  CheckProxy;
  FProxy.Execute(cursor, atransaction, AParams);
end;

function TSQLConnector.Fetch(cursor: TSQLCursor): boolean;
begin
  CheckProxy;
  Result:=FProxy.Fetch(cursor);
end;

procedure TSQLConnector.AddFieldDefs(cursor: TSQLCursor; FieldDefs: TfieldDefs
  );
begin
  CheckProxy;
  FProxy.AddFieldDefs(cursor, FieldDefs);
end;

procedure TSQLConnector.UnPrepareStatement(cursor: TSQLCursor);
begin
  CheckProxy;
  FProxy.UnPrepareStatement(cursor);
end;

procedure TSQLConnector.FreeFldBuffers(cursor: TSQLCursor);
begin
  CheckProxy;
  FProxy.FreeFldBuffers(cursor);
end;

function TSQLConnector.LoadField(cursor: TSQLCursor; FieldDef: TfieldDef;
  buffer: pointer; out CreateBlob: boolean): boolean;
begin
  CheckProxy;
  Result:=FProxy.LoadField(cursor, FieldDef, buffer, CreateBlob);
end;

procedure TSQLConnector.LoadBlobIntoBuffer(FieldDef: TFieldDef;
  ABlobBuf: PBufBlobField; cursor: TSQLCursor; ATransaction: TSQLTransaction);
begin
  CheckProxy;
  FProxy.LoadBlobIntoBuffer(FieldDef, ABlobBuf, cursor, ATransaction);
end;

function TSQLConnector.RowsAffected(cursor: TSQLCursor): TRowsCount;
begin
  CheckProxy;
  Result := FProxy.RowsAffected(cursor);
end;

function TSQLConnector.GetTransactionHandle(trans: TSQLHandle): pointer;
begin
  CheckProxy;
  Result:=FProxy.GetTransactionHandle(trans);
end;

function TSQLConnector.Commit(trans: TSQLHandle): boolean;
begin
  CheckProxy;
  Result:=FProxy.Commit(trans);
end;

function TSQLConnector.RollBack(trans: TSQLHandle): boolean;
begin
  CheckProxy;
  Result:=FProxy.RollBack(trans);
end;

function TSQLConnector.StartdbTransaction(trans: TSQLHandle; aParams: string
  ): boolean;
begin
  CheckProxy;
  Result:=FProxy.StartdbTransaction(trans, aParams);
end;

procedure TSQLConnector.CommitRetaining(trans: TSQLHandle);
begin
  CheckProxy;
  FProxy.CommitRetaining(trans);
end;

procedure TSQLConnector.RollBackRetaining(trans: TSQLHandle);
begin
  CheckProxy;
  FProxy.RollBackRetaining(trans);
end;

procedure TSQLConnector.UpdateIndexDefs(IndexDefs: TIndexDefs;
  TableName: string);
begin
  CheckProxy;
  FProxy.UpdateIndexDefs(IndexDefs, TableName);
end;

function TSQLConnector.GetSchemaInfoSQL(SchemaType: TSchemaType;
  SchemaObjectName, SchemaPattern: string): string;
begin
  CheckProxy;
  Result:=FProxy.GetSchemaInfoSQL(SchemaType, SchemaObjectName, SchemaPattern
    );
end;


{ TConnectionDef }

class function TConnectionDef.TypeName: String;
begin
  Result:='';
end;

class function TConnectionDef.ConnectionClass: TSQLConnectionClass;
begin
  Result:=Nil;
end;

class function TConnectionDef.Description: String;
begin
  Result:='';
end;

class function TConnectionDef.DefaultLibraryName: String;
begin
  Result:='';
end;

class function TConnectionDef.LoadFunction: TLibraryLoadFunction;
begin
  Result:=Nil;
end;

class function TConnectionDef.UnLoadFunction: TLibraryUnLoadFunction;
begin
  Result:=Nil;
end;

class function TConnectionDef.LoadedLibraryName: string;
begin
  Result:='';
end;

procedure TConnectionDef.ApplyParams(Params: TStrings;
  AConnection: TSQLConnection);
begin
  AConnection.Params.Assign(Params);
end;

{ TServerIndexDefs }

constructor TServerIndexDefs.create(ADataset: TDataset);
begin
  if not (ADataset is TCustomSQLQuery) then
    DatabaseErrorFmt(SErrNotASQLQuery,[ADataset.Name]);
  inherited create(ADataset);
end;

procedure TServerIndexDefs.Update;
begin
  if (not updated) and assigned(Dataset) then
    begin
    TCustomSQLQuery(Dataset).UpdateServerIndexDefs;
    updated := True;
    end;
end;

Initialization

Finalization
  DoneDefs;
end.
