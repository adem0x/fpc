{
    Copyright (c) 2004 by Joost van der Sluis

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

uses SysUtils, Classes, DB, bufdataset;

type TSchemaType = (stNoSchema, stTables, stSysTables, stProcedures, stColumns, stProcedureParams, stIndexes, stPackages);
     TConnOption = (sqSupportParams);
     TConnOptions= set of TConnOption;

type
  TSQLConnection = class;
  TSQLTransaction = class;
  TSQLQuery = class;
  TSQLScript = class;


  TStatementType = (stNone, stSelect, stInsert, stUpdate, stDelete,
    stDDL, stGetSegment, stPutSegment, stExecProcedure,
    stStartTrans, stCommit, stRollback, stSelectForUpd);

  TSQLHandle = Class(TObject)
  end;

  { TSQLCursor }

  TSQLCursor = Class(TSQLHandle)
  public
    FPrepared      : Boolean;
    FInitFieldDef  : Boolean;
    FStatementType : TStatementType;
    FBlobStrings   : TStringList;   // list of strings in which the blob-fields are stored
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;


const
 StatementTokens : Array[TStatementType] of string = ('(none)', 'select',
                  'insert', 'update', 'delete',
                  'create', 'get', 'put', 'execute',
                  'start','commit','rollback', '?'
                 );


{ TSQLConnection }
type

  { TSQLConnection }

  TSQLConnection = class (TDatabase)
  private
    FPassword            : string;
    FTransaction         : TSQLTransaction;
    FUserName            : string;
    FHostName            : string;
    FCharSet             : string;
    FRole                : String;

    procedure SetTransaction(Value : TSQLTransaction);
    procedure GetDBInfo(const SchemaType : TSchemaType; const SchemaObjectName, ReturnField : string; List: TStrings);
  protected
    FConnOptions         : TConnOptions;

    function StrToStatementType(s : string) : TStatementType; virtual;
    procedure DoInternalConnect; override;
    procedure DoInternalDisconnect; override;
    function GetAsSQLText(Field : TField) : string; overload; virtual;
    function GetAsSQLText(Param : TParam) : string; overload; virtual;
    function GetHandle : pointer; virtual; virtual;

    Function AllocateCursorHandle : TSQLCursor; virtual; abstract;
    Procedure DeAllocateCursorHandle(var cursor : TSQLCursor); virtual; abstract;
    Function AllocateTransactionHandle : TSQLHandle; virtual; abstract;

    procedure PrepareStatement(cursor: TSQLCursor;ATransaction : TSQLTransaction;buf : string; AParams : TParams); virtual; abstract;
    procedure Execute(cursor: TSQLCursor;atransaction:tSQLtransaction; AParams : TParams); virtual; abstract;
    function Fetch(cursor : TSQLCursor) : boolean; virtual; abstract;
    procedure AddFieldDefs(cursor: TSQLCursor; FieldDefs : TfieldDefs); virtual; abstract;
    procedure UnPrepareStatement(cursor : TSQLCursor); virtual; abstract;

    procedure FreeFldBuffers(cursor : TSQLCursor); virtual;
    function LoadField(cursor : TSQLCursor;FieldDef : TfieldDef;buffer : pointer) : boolean; virtual; abstract;
    function GetTransactionHandle(trans : TSQLHandle): pointer; virtual; abstract;
    function Commit(trans : TSQLHandle) : boolean; virtual; abstract;
    function RollBack(trans : TSQLHandle) : boolean; virtual; abstract;
    function StartdbTransaction(trans : TSQLHandle; aParams : string) : boolean; virtual; abstract;
    procedure CommitRetaining(trans : TSQLHandle); virtual; abstract;
    procedure RollBackRetaining(trans : TSQLHandle); virtual; abstract;
    procedure UpdateIndexDefs(var IndexDefs : TIndexDefs;TableName : string); virtual;
    function GetSchemaInfoSQL(SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string) : string; virtual;
    procedure LoadBlobIntoStream(Field: TField;AStream: TStream;cursor: TSQLCursor;ATransaction : TSQLTransaction); virtual;
  public
    property Handle: Pointer read GetHandle;
    destructor Destroy; override;
    procedure StartTransaction; override;
    procedure EndTransaction; override;
    property ConnOptions: TConnOptions read FConnOptions;
    procedure ExecuteDirect(SQL : String); overload; virtual;
    procedure ExecuteDirect(SQL : String; ATransaction : TSQLTransaction); overload; virtual;
    procedure GetTableNames(List : TStrings; SystemTables : Boolean = false); virtual;
    procedure GetProcedureNames(List : TStrings); virtual;
    procedure GetFieldNames(const TableName : string; List :  TStrings); virtual;
    procedure CreateDB; virtual;
    procedure DropDB; virtual;
  published
    property Password : string read FPassword write FPassword;
    property Transaction : TSQLTransaction read FTransaction write SetTransaction;
    property UserName : string read FUserName write FUserName;
    property CharSet : string read FCharSet write FCharSet;
    property HostName : string Read FHostName Write FHostName;

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
  protected
    function GetHandle : Pointer; virtual;
    Procedure SetDatabase (Value : TDatabase); override;
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
    property Action : TCommitRollbackAction read FAction write FAction;
    property Database;
    property Params : TStringList read FParams write FParams;
  end;

{ TSQLQuery }

  TSQLQuery = class (Tbufdataset)
  private
    FCursor              : TSQLCursor;
    FUpdateable          : boolean;
    FTableName           : string;
    FSQL                 : TStringList;
    FUpdateSQL,
    FInsertSQL,
    FDeleteSQL           : TStringList;
    FIsEOF               : boolean;
    FLoadingFieldDefs    : boolean;
    FIndexDefs           : TIndexDefs;
    FReadOnly            : boolean;
    FUpdateMode          : TUpdateMode;
    FParams              : TParams;
    FusePrimaryKeyAsKey  : Boolean;
    FSQLBuf              : String;
    FFromPart            : String;
    FWhereStartPos       : integer;
    FWhereStopPos        : integer;
    FParseSQL            : boolean;
    FMasterLink          : TMasterParamsDatalink;
//    FSchemaInfo          : TSchemaInfo;

    FServerFilterText    : string;
    FServerFiltered      : Boolean;

    FUpdateQry,
    FDeleteQry,
    FInsertQry           : TSQLQuery;

    procedure FreeFldBuffers;
    procedure InitUpdates(ASQL : string);
    function GetIndexDefs : TIndexDefs;
    function GetStatementType : TStatementType;
    procedure SetIndexDefs(AValue : TIndexDefs);
    procedure SetReadOnly(AValue : Boolean);
    procedure SetParseSQL(AValue : Boolean);
    procedure SetUsePrimaryKeyAsKey(AValue : Boolean);
    procedure SetUpdateMode(AValue : TUpdateMode);
    procedure OnChangeSQL(Sender : TObject);
    procedure OnChangeModifySQL(Sender : TObject);
    procedure Execute;
    Procedure SQLParser(var ASQL : string);
    procedure ApplyFilter;
    Function AddFilter(SQLstr : string) : string;
  protected
    // abstract & virtual methods of TBufDataset
    function Fetch : boolean; override;
    function LoadField(FieldDef : TFieldDef;buffer : pointer) : boolean; override;
    // abstract & virtual methods of TDataset
    procedure UpdateIndexDefs; override;
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
    Function GetDataSource : TDatasource; override;
    Procedure SetDataSource(AValue : TDatasource); 
    procedure LoadBlobIntoStream(Field: TField;AStream: TStream); override;
  public
    procedure Prepare; virtual;
    procedure UnPrepare; virtual;
    procedure ExecSQL; virtual;
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure SetSchemaInfo( SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string); virtual;
    property Prepared : boolean read IsPrepared;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  published
    // redeclared data set properties
    property Active;
    property Filter;
    property Filtered;
    property ServerFilter: string read FServerFilterText write SetServerFilterText;
    property ServerFiltered: Boolean read FServerFiltered write SetServerFiltered default False;
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

    property Transaction;
    property ReadOnly : Boolean read FReadOnly write SetReadOnly;
    property SQL : TStringlist read FSQL write FSQL;
    property UpdateSQL : TStringlist read FUpdateSQL write FUpdateSQL;
    property InsertSQL : TStringlist read FInsertSQL write FInsertSQL;
    property DeleteSQL : TStringlist read FDeleteSQL write FDeleteSQL;
    property IndexDefs : TIndexDefs read GetIndexDefs;
    property Params : TParams read FParams write FParams;
    property UpdateMode : TUpdateMode read FUpdateMode write SetUpdateMode;
    property UsePrimaryKeyAsKey : boolean read FUsePrimaryKeyAsKey write SetUsePrimaryKeyAsKey;
    property StatementType : TStatementType read GetStatementType;
    property ParseSQL : Boolean read FParseSQL write SetParseSQL;
    Property DataSource : TDatasource Read GetDataSource Write SetDatasource;
//    property SchemaInfo : TSchemaInfo read FSchemaInfo default stNoSchema;
  end;

{ TSQLScript }

  TSQLScript = class (Tcomponent)
  private
    FScript  : TStrings;
    FQuery   : TSQLQuery;
    FDatabase : TDatabase;
    FTransaction : TDBTransaction;
  protected
    procedure SetScript(const AValue: TStrings);
    Procedure SetDatabase (Value : TDatabase); virtual;
    Procedure SetTransaction(Value : TDBTransaction); virtual;
    Procedure CheckDatabase;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure ExecuteScript;
    Property Script : TStrings Read FScript Write SetScript;
    Property DataBase : TDatabase Read FDatabase Write SetDatabase;
    Property Transaction : TDBTransaction Read FTransaction Write SetTransaction;
  end;

implementation

uses dbconst, strutils;

{ TSQLConnection }

function TSQLConnection.StrToStatementType(s : string) : TStatementType;

var T : TStatementType;

begin
  S:=Lowercase(s);
  For t:=stselect to strollback do
    if (S=StatementTokens[t]) then
      Exit(t);
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
    end;
end;

procedure TSQLConnection.UpdateIndexDefs(var IndexDefs : TIndexDefs;TableName : string);

begin
// Empty abstract
end;

procedure TSQLConnection.DoInternalConnect;
begin
  if (DatabaseName = '') then
    DatabaseError(SErrNoDatabaseName,self);
end;

procedure TSQLConnection.DoInternalDisconnect;
begin
end;

destructor TSQLConnection.Destroy;
begin
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

Procedure TSQLConnection.ExecuteDirect(SQL: String);

begin
  ExecuteDirect(SQL,FTransaction);
end;

Procedure TSQLConnection.ExecuteDirect(SQL: String; ATransaction : TSQLTransaction);

var Cursor : TSQLCursor;

begin
  if not assigned(ATransaction) then
    DatabaseError(SErrTransactionnSet);

  if not Connected then Open;
  if not ATransaction.Active then ATransaction.StartTransaction;

  try
    Cursor := AllocateCursorHandle;

    SQL := TrimRight(SQL);

    if SQL = '' then
      DatabaseError(SErrNoStatement);

    Cursor.FStatementType := stNone;

    PrepareStatement(cursor,ATransaction,SQL,Nil);
    execute(cursor,ATransaction, Nil);
    UnPrepareStatement(Cursor);
  finally;
    DeAllocateCursorHandle(Cursor);
  end;
end;

procedure TSQLConnection.GetDBInfo(const SchemaType : TSchemaType; const SchemaObjectName, ReturnField : string; List: TStrings);

var qry : TSQLQuery;

begin
  if not assigned(Transaction) then
    DatabaseError(SErrConnTransactionnSet);

  qry := tsqlquery.Create(nil);
  qry.transaction := Transaction;
  qry.database := Self;
  with qry do
    begin
    ParseSQL := False;
    SetSchemaInfo(SchemaType,SchemaObjectName,'');
    open;
    List.Clear;
    while not eof do
      begin
      List.Append(fieldbyname(ReturnField).asstring);
      Next;
      end;
    end;
  qry.free;
end;


procedure TSQLConnection.GetTableNames(List: TStrings; SystemTables: Boolean);
begin
  if not systemtables then GetDBInfo(stTables,'','table_name',List)
    else GetDBInfo(stSysTables,'','table_name',List);
end;

procedure TSQLConnection.GetProcedureNames(List: TStrings);
begin
  GetDBInfo(stProcedures,'','proc_name',List);
end;

procedure TSQLConnection.GetFieldNames(const TableName: string; List: TStrings);
begin
  GetDBInfo(stColumns,TableName,'column_name',List);
end;

function TSQLConnection.GetAsSQLText(Field : TField) : string;

begin
  if (not assigned(field)) or field.IsNull then Result := 'Null'
  else case field.DataType of
    ftString   : Result := '''' + field.asstring + '''';
    ftDate     : Result := '''' + FormatDateTime('yyyy-mm-dd',Field.AsDateTime) + '''';
    ftDateTime : Result := '''' + FormatDateTime('yyyy-mm-dd hh:mm:ss',Field.AsDateTime) + ''''
  else
    Result := field.asstring;
  end; {case}
end;

function TSQLConnection.GetAsSQLText(Param: TParam) : string;

begin
  if (not assigned(param)) or param.IsNull then Result := 'Null'
  else case param.DataType of
    ftString   : Result := '''' + param.asstring + '''';
    ftDate     : Result := '''' + FormatDateTime('yyyy-mm-dd',Param.AsDateTime) + '''';
    ftDateTime : Result := '''' + FormatDateTime('yyyy-mm-dd hh:mm:ss',Param.AsDateTime) + ''''
  else
    Result := Param.asstring;
  end; {case}
end;


function TSQLConnection.GetHandle: pointer;
begin
  Result := nil;
end;

procedure TSQLConnection.FreeFldBuffers(cursor: TSQLCursor);
begin
  cursor.FBlobStrings.Clear;
end;

function TSQLConnection.GetSchemaInfoSQL( SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string) : string;

begin
  DatabaseError(SMetadataUnavailable);
end;

procedure TSQLConnection.LoadBlobIntoStream(Field: TField;AStream: TStream; cursor: TSQLCursor;ATransaction : TSQLTransaction);

var blobId  : pinteger;
    BlobBuf : TBufBlobField;
    s       : string;

begin
{  if not field.getData(@BlobBuf) then
    exit;
  blobId := @BlobBuf.BufBlobId;

  s := cursor.FBlobStrings.Strings[blobid^];

  AStream.WriteBuffer(s[1],length(s));

  AStream.seek(0,soFromBeginning);}
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
  rollback;
end;

function TSQLTransaction.GetHandle: pointer;
begin
  Result := (Database as tsqlconnection).GetTransactionHandle(FTrans);
end;

procedure TSQLTransaction.Commit;
begin
  if active then
    begin
    closedatasets;
    if (Database as tsqlconnection).commit(FTrans) then
      begin
      closeTrans;
      FreeAndNil(FTrans);
      end;
    end;
end;

procedure TSQLTransaction.CommitRetaining;
begin
  if active then
    (Database as tsqlconnection).commitRetaining(FTrans);
end;

procedure TSQLTransaction.Rollback;
begin
  if active then
    begin
    closedatasets;
    if (Database as tsqlconnection).RollBack(FTrans) then
      begin
      CloseTrans;
      FreeAndNil(FTrans);
      end;
    end;
end;

procedure TSQLTransaction.RollbackRetaining;
begin
  if active then
    (Database as tsqlconnection).RollBackRetaining(FTrans);
end;

procedure TSQLTransaction.StartTransaction;

var db : TSQLConnection;

begin
  if Active then
    DatabaseError(SErrTransAlreadyActive);

  db := (Database as tsqlconnection);

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
end;

destructor TSQLTransaction.Destroy;
begin
  Rollback;
  FreeAndNil(FParams);
  inherited Destroy;
end;

Procedure TSQLTransaction.SetDatabase(Value : TDatabase);

begin
  If Value<>Database then
    begin
    CheckInactive;
    If Assigned(Database) then
      with Database as TSqlConnection do
        if Transaction = self then Transaction := nil;
    inherited SetDatabase(Value);
    end;
end;

{ TSQLQuery }
procedure TSQLQuery.OnChangeSQL(Sender : TObject);

begin
  UnPrepare;
  if (FSQL <> nil) then
    begin
    FParams.ParseSQL(FSQL.Text,True);
    If Assigned(FMasterLink) then
      FMasterLink.RefreshParamNames;
    end;
end;

procedure TSQLQuery.OnChangeModifySQL(Sender : TObject);

begin
  CheckInactive;
end;

Procedure TSQLQuery.SetTransaction(Value : TDBTransaction);

begin
  UnPrepare;
  inherited;
end;

procedure TSQLQuery.SetDatabase(Value : TDatabase);

var db : tsqlconnection;

begin
  if (Database <> Value) then
    begin
    UnPrepare;
    if assigned(FCursor) then (Database as TSQLConnection).DeAllocateCursorHandle(FCursor);
    db := value as tsqlconnection;
    inherited setdatabase(value);
    if assigned(value) and (Transaction = nil) and (Assigned(db.Transaction)) then
      transaction := Db.Transaction;
    end;
end;

Function TSQLQuery.IsPrepared : Boolean;

begin
  Result := Assigned(FCursor) and FCursor.FPrepared;
end;

Function TSQLQuery.AddFilter(SQLstr : string) : string;

begin
  if FWhereStartPos = 0 then
    SQLstr := SQLstr + ' where (' + Filter + ')'
  else if FWhereStopPos > 0 then
    system.insert(' and ('+Filter+') ',SQLstr,FWhereStopPos+1)
  else
    system.insert(' where ('+Filter+') ',SQLstr,FWhereStartPos);
  Result := SQLstr;
end;

procedure TSQLQuery.ApplyFilter;

var S : String;

begin
  FreeFldBuffers;
  (Database as tsqlconnection).UnPrepareStatement(FCursor);
  FIsEOF := False;
  inherited internalclose;

  s := FSQLBuf;

  if ServerFiltered then s := AddFilter(s);

  (Database as tsqlconnection).PrepareStatement(Fcursor,(transaction as tsqltransaction),S,FParams);

  Execute;
  inherited InternalOpen;
  First;
end;

Procedure TSQLQuery.SetActive (Value : Boolean);

begin
  inherited SetActive(Value);
// The query is UnPrepared, so that if a transaction closes all datasets
// they also get unprepared
  if not Value and IsPrepared then UnPrepare;
end;


procedure TSQLQuery.SetServerFiltered(Value: Boolean);

begin
  if Value and not FParseSQL then DatabaseErrorFmt(SNoParseSQL,['Filtering ']);
  if (ServerFiltered <> Value) then
    begin
    FServerFiltered := Value;
    if active then ApplyFilter;
    end;
end;

procedure TSQLQuery.SetServerFilterText(const Value: string);
begin
  if Value <> ServerFilter then
    begin
    FServerFilterText := Value;
    if active then ApplyFilter;
    end;
end;

procedure TSQLQuery.Prepare;
var
  db    : tsqlconnection;
  sqltr : tsqltransaction;

begin
  if not IsPrepared then
    begin
    db := (Database as tsqlconnection);
    sqltr := (transaction as tsqltransaction);
    if not assigned(Db) then
      DatabaseError(SErrDatabasenAssigned);
    if not assigned(sqltr) then
      DatabaseError(SErrTransactionnSet);

    if not Db.Connected then db.Open;
    if not sqltr.Active then sqltr.StartTransaction;

//    if assigned(fcursor) then FreeAndNil(fcursor);
    if not assigned(fcursor) then
      FCursor := Db.AllocateCursorHandle;

    FSQLBuf := TrimRight(FSQL.Text);

    if FSQLBuf = '' then
      DatabaseError(SErrNoStatement);

    SQLParser(FSQLBuf);

    if ServerFiltered then
      Db.PrepareStatement(Fcursor,sqltr,AddFilter(FSQLBuf),FParams)
    else
      Db.PrepareStatement(Fcursor,sqltr,FSQLBuf,FParams);

    if (FCursor.FStatementType = stSelect) then
      begin
      FCursor.FInitFieldDef := True;
      if not ReadOnly then InitUpdates(FSQLBuf);
      end;
    end;
end;

procedure TSQLQuery.UnPrepare;

begin
  CheckInactive;
  if IsPrepared then with Database as TSQLConnection do
    UnPrepareStatement(FCursor);
end;

procedure TSQLQuery.FreeFldBuffers;
begin
  if assigned(FCursor) then (Database as tsqlconnection).FreeFldBuffers(FCursor);
end;

function TSQLQuery.Fetch : boolean;
begin
  if not (Fcursor.FStatementType in [stSelect]) then
    Exit;

  if not FIsEof then FIsEOF := not (Database as tsqlconnection).Fetch(Fcursor);
  Result := not FIsEOF;
end;

procedure TSQLQuery.Execute;
begin
  If (FParams.Count>0) and Assigned(FMasterLink) then
    FMasterLink.CopyParamsFromMaster(False);
  (Database as tsqlconnection).execute(Fcursor,Transaction as tsqltransaction, FParams);
end;

function TSQLQuery.LoadField(FieldDef : TFieldDef;buffer : pointer) : boolean;

begin
  result := (Database as tSQLConnection).LoadField(FCursor,FieldDef,buffer)
end;

procedure TSQLQuery.InternalAddRecord(Buffer: Pointer; AAppend: Boolean);
begin
  // not implemented - sql dataset
end;

procedure TSQLQuery.InternalClose;
begin
  if StatementType = stSelect then FreeFldBuffers;
// Database and FCursor could be nil, for example if the database is not assigned, and .open is called
  if (not IsPrepared) and (assigned(database)) and (assigned(FCursor)) then (database as TSQLconnection).UnPrepareStatement(FCursor);
  if DefaultFields then
    DestroyFields;
  FIsEOF := False;
  if assigned(FUpdateQry) then FreeAndNil(FUpdateQry);
  if assigned(FInsertQry) then FreeAndNil(FInsertQry);
  if assigned(FDeleteQry) then FreeAndNil(FDeleteQry);
//  FRecordSize := 0;
  inherited internalclose;
end;

procedure TSQLQuery.InternalInitFieldDefs;
begin
  if FLoadingFieldDefs then
    Exit;

  FLoadingFieldDefs := True;

  try
    FieldDefs.Clear;

    (Database as tsqlconnection).AddFieldDefs(fcursor,FieldDefs);
  finally
    FLoadingFieldDefs := False;
    FCursor.FInitFieldDef := false;
  end;
end;

procedure TSQLQuery.SQLParser(var ASQL : string);

type TParsePart = (ppStart,ppSelect,ppWhere,ppFrom,ppOrder,ppComment,ppGroup,ppBogus);

Var
  PSQL,CurrentP,
  PhraseP, PStatementPart : pchar;
  S                       : string;
  ParsePart               : TParsePart;
  StrLength               : Integer;
  EndOfComment            : Boolean;
  BracketCount            : Integer;

begin
  PSQL:=Pchar(ASQL);
  ParsePart := ppStart;

  CurrentP := PSQL-1;
  PhraseP := PSQL;

  FWhereStartPos := 0;
  FWhereStopPos := 0;

  repeat
    begin
    inc(CurrentP);
    
    EndOfComment := SkipComments(CurrentP);
    if EndOfcomment then dec(currentp);
    if EndOfComment and (ParsePart = ppStart) then PhraseP := CurrentP;
    
    // skip everything between bracket, since it could be a sub-select, and
    // further nothing between brackets could be interesting for the parser.
    if currentp^='(' then
      begin
      inc(currentp);
      BracketCount := 0;
      while (currentp^ <> #0) and ((currentp^ <> ')') or (BracketCount > 0 )) do
        begin
        if currentp^ = '(' then inc(bracketcount)
        else if currentp^ = ')' then dec(bracketcount);
        inc(currentp);
        end;
      EndOfComment := True;
      end;

    if EndOfComment or (CurrentP^ in [' ',#13,#10,#9,#0,';']) then
      begin
      if (CurrentP-PhraseP > 0) or (CurrentP^ in [';',#0]) then
        begin
        strLength := CurrentP-PhraseP;
        Setlength(S,strLength);
        if strLength > 0 then Move(PhraseP^,S[1],(strLength));
        s := uppercase(s);

        case ParsePart of
          ppStart  : begin
                     FCursor.FStatementType := (Database as tsqlconnection).StrToStatementType(s);
                     if FCursor.FStatementType = stSelect then ParsePart := ppSelect
                       else break;
                     if not FParseSQL then break;
                     PStatementPart := CurrentP;
                     end;
          ppSelect : begin
                     if s = 'FROM' then
                       begin
                       ParsePart := ppFrom;
                       PhraseP := CurrentP;
                       PStatementPart := CurrentP;
                       end;
                     end;
          ppFrom   : begin
                     if (s = 'WHERE') or (s = 'ORDER') or (s = 'GROUP') or (CurrentP^=#0) or (CurrentP^=';') then
                       begin
                       if (s = 'WHERE') then
                         begin
                         ParsePart := ppWhere;
                         StrLength := PhraseP-PStatementPart;
                         end
                       else if (s = 'GROUP') then
                         begin
                         ParsePart := ppGroup;
                         StrLength := PhraseP-PStatementPart;
                         end
                       else if (s = 'ORDER') then
                         begin
                         ParsePart := ppOrder;
                         StrLength := PhraseP-PStatementPart
                         end
                       else
                         begin
                         ParsePart := ppBogus;
                         StrLength := CurrentP-PStatementPart;
                         end;
                       Setlength(FFromPart,StrLength);
                       Move(PStatementPart^,FFromPart[1],(StrLength));
                       FFrompart := trim(FFrompart);
                       FWhereStartPos := PStatementPart-PSQL+StrLength+1;
                       PStatementPart := CurrentP;
                       end;
                     end;
          ppWhere  : begin
                     if (s = 'ORDER') or (s = 'GROUP') or (CurrentP^=#0) or (CurrentP^=';') then
                       begin
                       ParsePart := ppBogus;
                       FWhereStartPos := PStatementPart-PSQL;
                       if (s = 'ORDER') or (s = 'GROUP') then
                         FWhereStopPos := PhraseP-PSQL+1
                       else
                         FWhereStopPos := CurrentP-PSQL+1;
                       end;
                     end;
        end; {case}
        end;
      PhraseP := CurrentP+1;
      end
    end;
  until CurrentP^=#0;
  if (FWhereStartPos > 0) and (FWhereStopPos > 0) then
    begin
    system.insert('(',ASQL,FWhereStartPos+1);
    inc(FWhereStopPos);
    system.insert(')',ASQL,FWhereStopPos);
    end
end;

procedure TSQLQuery.InitUpdates(ASQL : string);


begin
  if pos(',',FFromPart) > 0 then
    FUpdateable := False // select-statements from more then one table are not updateable
  else
    begin
    FUpdateable := True;
    FTableName := FFromPart;
    end;

end;

procedure TSQLQuery.InternalOpen;

  procedure InitialiseModifyQuery(var qry : TSQLQuery; aSQL: TSTringList);
  
  begin
    qry := TSQLQuery.Create(nil);
    with qry do
      begin
      ParseSQL := False;
      DataBase := Self.DataBase;
      Transaction := Self.Transaction;
      SQL.Assign(aSQL);
      end;
  end;


var tel         : integer;
    f           : TField;
    s           : string;
begin
  try
    Prepare;
    if FCursor.FStatementType in [stSelect] then
      begin
      Execute;
      // InternalInitFieldDef is only called after a prepare. i.e. not twice if
      // a dataset is opened - closed - opened.
      if FCursor.FInitFieldDef then InternalInitFieldDefs;
      if DefaultFields then
        begin
        CreateFields;

        if FUpdateable then
          begin
          if FusePrimaryKeyAsKey then
            begin
            UpdateIndexDefs;
            for tel := 0 to indexdefs.count-1 do {with indexdefs[tel] do}
              begin
              if ixPrimary in indexdefs[tel].options then
                begin
                // Todo: If there is more then one field in the key, that must be parsed
                  s := indexdefs[tel].fields;
                  F := Findfield(s);
                  if F <> nil then
                    F.ProviderFlags := F.ProviderFlags + [pfInKey];
                end;
              end;
            end;
          end;
        end
      else
        BindFields(True);
      if FUpdateable then
        begin
        InitialiseModifyQuery(FDeleteQry,FDeleteSQL);
        InitialiseModifyQuery(FUpdateQry,FUpdateSQL);
        InitialiseModifyQuery(FInsertQry,FInsertSQL);
        end;
      end
    else
      DatabaseError(SErrNoSelectStatement,Self);
  except
    on E:Exception do
      raise;
  end;
  inherited InternalOpen;
end;

// public part

procedure TSQLQuery.ExecSQL;
begin
  try
    Prepare;
    Execute;
  finally
    // FCursor has to be assigned, or else the prepare went wrong before PrepareStatment was
    // called, so UnPrepareStatement shoudn't be called either
    if (not IsPrepared) and (assigned(database)) and (assigned(FCursor)) then (database as TSQLConnection).UnPrepareStatement(Fcursor);
  end;
end;

constructor TSQLQuery.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FParams := TParams.create(self);
  FSQL := TStringList.Create;
  FSQL.OnChange := @OnChangeSQL;

  FUpdateSQL := TStringList.Create;
  FUpdateSQL.OnChange := @OnChangeModifySQL;
  FInsertSQL := TStringList.Create;
  FInsertSQL.OnChange := @OnChangeModifySQL;
  FDeleteSQL := TStringList.Create;
  FDeleteSQL.OnChange := @OnChangeModifySQL;

  FIndexDefs := TIndexDefs.Create(Self);
  FReadOnly := false;
  FParseSQL := True;
  
  FServerFiltered := False;
  FServerFilterText := '';
  
// Delphi has upWhereAll as default, but since strings and oldvalue's don't work yet
// (variants) set it to upWhereKeyOnly
  FUpdateMode := upWhereKeyOnly;
  FUsePrimaryKeyAsKey := True;
end;

destructor TSQLQuery.Destroy;
begin
  if Active then Close;
  UnPrepare;
  if assigned(FCursor) then (Database as TSQLConnection).DeAllocateCursorHandle(FCursor);
  FreeAndNil(FMasterLink);
  FreeAndNil(FParams);
  FreeAndNil(FSQL);
  FreeAndNil(FInsertSQL);
  FreeAndNil(FDeleteSQL);
  FreeAndNil(FUpdateSQL);
  FreeAndNil(FIndexDefs);
  inherited Destroy;
end;

procedure TSQLQuery.SetReadOnly(AValue : Boolean);

begin
  CheckInactive;
  if not AValue then
    begin
    if FParseSQL then FReadOnly := False
      else DatabaseErrorFmt(SNoParseSQL,['Updating ']);
    end
  else FReadOnly := True;
end;

procedure TSQLQuery.SetParseSQL(AValue : Boolean);

begin
  CheckInactive;
  if not AValue then
    begin
    FReadOnly := True;
    FServerFiltered := False;
    FParseSQL := False;
    end
  else
    FParseSQL := True;
end;

procedure TSQLQuery.SetUsePrimaryKeyAsKey(AValue : Boolean);

begin
  if not Active then FusePrimaryKeyAsKey := AValue
  else
    begin
    // Just temporary, this should be possible in the future
    DatabaseError(SActiveDataset);
    end;
end;

Procedure TSQLQuery.UpdateIndexDefs;

begin
  if assigned(DataBase) then
    (DataBase as TSQLConnection).UpdateIndexDefs(FIndexDefs,FTableName);
end;

Procedure TSQLQuery.ApplyRecUpdate(UpdateKind : TUpdateKind);

  procedure UpdateWherePart(var sql_where : string;x : integer);

  begin
    if (pfInKey in Fields[x].ProviderFlags) or
       ((FUpdateMode = upWhereAll) and (pfInWhere in Fields[x].ProviderFlags)) or
       ((FUpdateMode = UpWhereChanged) and (pfInWhere in Fields[x].ProviderFlags) and (fields[x].value <> fields[x].oldvalue)) then
      sql_where := sql_where + '(' + fields[x].FieldName + '= :OLD_' + fields[x].FieldName + ') and ';
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

      if (pfInUpdate in Fields[x].ProviderFlags) then
        sql_set := sql_set + fields[x].FieldName + '=:' + fields[x].FieldName + ',';
      end;

    if length(sql_set) = 0 then DatabaseError(sNoUpdateFields,self);
    setlength(sql_set,length(sql_set)-1);
    if length(sql_where) = 0 then DatabaseError(sNoWhereFields,self);
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
      if (not fields[x].IsNull) and (pfInUpdate in Fields[x].ProviderFlags) then
        begin
        sql_fields := sql_fields + fields[x].FieldName + ',';
        sql_values := sql_values + ':' + fields[x].FieldName + ',';
        end;
      end;
    if length(sql_fields) = 0 then DatabaseError(sNoUpdateFields,self);
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

    if length(sql_where) = 0 then DatabaseError(sNoWhereFields,self);
    setlength(sql_where,length(sql_where)-5);

    result := 'delete from ' + FTableName + ' where ' + sql_where;
  end;

var qry : tsqlquery;
    x   : integer;
    Fld : TField;
    
begin
    case UpdateKind of
      ukModify : begin
                 qry := FUpdateQry;
                 if trim(qry.sql.Text) = '' then qry.SQL.Add(ModifyRecQuery);
                 end;
      ukInsert : begin
                 qry := FInsertQry;
                 if trim(qry.sql.Text) = '' then qry.SQL.Add(InsertRecQuery);
                 end;
      ukDelete : begin
                 qry := FDeleteQry;
                 if trim(qry.sql.Text) = '' then qry.SQL.Add(DeleteRecQuery);
                 end;
    end;
  with qry do
    begin
    for x := 0 to Params.Count-1 do with params[x] do if leftstr(name,4)='OLD_' then
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


Function TSQLQuery.GetCanModify: Boolean;

begin
  // the test for assigned(FCursor) is needed for the case that the dataset isn't opened
  if assigned(FCursor) and (FCursor.FStatementType = stSelect) then
    Result:= FUpdateable and (not FReadOnly)
  else
    Result := False;
end;

function TSQLQuery.GetIndexDefs : TIndexDefs;

begin
  Result := FIndexDefs;
end;

procedure TSQLQuery.SetIndexDefs(AValue : TIndexDefs);

begin
  FIndexDefs := AValue;
end;

procedure TSQLQuery.SetUpdateMode(AValue : TUpdateMode);

begin
  FUpdateMode := AValue;
end;

procedure TSQLQuery.SetSchemaInfo( SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string);

begin
  ReadOnly := True;
  SQL.Clear;
  SQL.Add((DataBase as tsqlconnection).GetSchemaInfoSQL(SchemaType, SchemaObjectName, SchemaPattern));
end;

procedure TSQLQuery.LoadBlobIntoStream(Field: TField;AStream: TStream);

begin
  (DataBase as tsqlconnection).LoadBlobIntoStream(Field, AStream, FCursor,(Transaction as tsqltransaction));
end;

function TSQLQuery.GetStatementType : TStatementType;

begin
  if assigned(FCursor) then Result := FCursor.FStatementType
    else Result := stNone;
end;

Procedure TSQLQuery.SetDataSource(AVAlue : TDatasource);

Var
  DS : TDatasource;

begin
  DS:=DataSource;
  If (AValue<>DS) then
    begin
    If Assigned(DS) then
      DS.RemoveFreeNotification(Self);
    If Assigned(AValue) then
      begin
      AValue.FreeNotification(Self);  
      FMasterLink:=TMasterParamsDataLink.Create(Self);
      FMasterLink.Datasource:=AValue;
      end
    else
      FreeAndNil(FMasterLink);  
    end;
end;

Function TSQLQuery.GetDataSource : TDatasource;

begin
  If Assigned(FMasterLink) then
    Result:=FMasterLink.DataSource
  else
    Result:=Nil;
end;

procedure TSQLQuery.Notification(AComponent: TComponent; Operation: TOperation); 

begin
  Inherited;
  If (Operation=opRemove) and (AComponent=DataSource) then
    DataSource:=Nil;
end;

{ TSQLScript }

procedure TSQLScript.SetScript(const AValue: TStrings);
begin
  FScript.assign(AValue);
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
  FScript := TStringList.Create;
  FQuery := TSQLQuery.Create(nil);
end;

destructor TSQLScript.Destroy;
begin
  FScript.Free;
  FQuery.Free;
  inherited Destroy;
end;

procedure TSQLScript.ExecuteScript;

var BufStr         : String;
    pBufStatStart,
    pBufPos        : PChar;
    Statement      : String;

begin
  FQuery.DataBase := FDatabase;
  FQuery.Transaction := FTransaction;

  BufStr := FScript.Text;
  pBufPos := @BufStr[1];

  repeat

  pBufStatStart := pBufPos;
  repeat
  inc(pBufPos);
  until (pBufPos^ = ';') or (pBufPos^ = #0);
  SetLength(statement,pbufpos-pBufStatStart);
  move(pBufStatStart^,Statement[1],pbufpos-pBufStatStart);
  if trim(statement) <> '' then
    begin
    fquery.SQL.Text := Statement;
    fquery.ExecSQL;
    inc(pBufPos);
    end;

  until pBufPos^ = #0;
end;

{ TSQLCursor }

constructor TSQLCursor.Create;
begin
  FBlobStrings := TStringList.Create;
  inherited;
end;

destructor TSQLCursor.Destroy;
begin
  FBlobStrings.Free;
  inherited Destroy;
end;

end.
