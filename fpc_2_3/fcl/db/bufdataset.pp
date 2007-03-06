{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2006 by Joost van der Sluis, member of the
    Free Pascal development team

    BufDataset implementation

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit BufDataset;

{$mode objfpc}
{$h+}

interface

uses Classes,Sysutils,db,bufdataset_parser;

type
  TBufDataset = Class;

  TResolverErrorEvent = procedure(Sender: TObject; DataSet: TBufDataset; E: EUpdateError;
    UpdateKind: TUpdateKind; var Response: TResolverResponse) of object;

  { TBufBlobStream }

  PBlobBuffer = ^TBlobBuffer;
  TBlobBuffer = record
    FieldNo : integer;
    OrgBufID: integer;
    Buffer  : pointer;
    Size    : ptrint;
  end;

   TBufBlobStream = class(TStream)
  private
    FBlobBuffer : PBlobBuffer;
    FPosition   : ptrint;
    FDataset    : TBufDataset;
  protected
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
  public
    constructor Create(Field: TBlobField; Mode: TBlobStreamMode);
  end;

  { TBufDataset }

  PBufRecLinkItem = ^TBufRecLinkItem;
  TBufRecLinkItem = record
    prior   : PBufRecLinkItem;
    next    : PBufRecLinkItem;
  end;

  PBufBookmark = ^TBufBookmark;
  TBufBookmark = record
    BookmarkData : PBufRecLinkItem;
    BookmarkFlag : TBookmarkFlag;
  end;

  PRecUpdateBuffer = ^TRecUpdateBuffer;
  TRecUpdateBuffer = record
    UpdateKind         : TUpdateKind;
    BookmarkData       : pointer;
    OldValuesBuffer    : pchar;
  end;

  PBufBlobField = ^TBufBlobField;
  TBufBlobField = record
    ConnBlobBuffer : array[0..11] of byte; // It's here where the db-specific data is stored
    BlobBuffer     : PBlobBuffer;
  end;

  TRecordsUpdateBuffer = array of TRecUpdateBuffer;

  TBufDataset = class(TDBDataSet)
  private
    FCurrentRecBuf  : PBufRecLinkItem;
    FLastRecBuf     : PBufRecLinkItem;
    FFirstRecBuf    : PBufRecLinkItem;
    FFilterBuffer   : pchar;
    FBRecordCount   : integer;

    FPacketRecords  : integer;
    FRecordSize     : Integer;
    FNullmaskSize   : byte;
    FOpen           : Boolean;
    FUpdateBuffer   : TRecordsUpdateBuffer;
    FCurrentUpdateBuffer : integer;

    FParser         : TBufDatasetParser;

    FFieldBufPositions : array of longint;

    FAllPacketsFetched : boolean;
    FOnUpdateError  : TResolverErrorEvent;

    FBlobBuffers      : array of PBlobBuffer;
    FUpdateBlobBuffers: array of PBlobBuffer;

    function  GetCurrentBuffer: PChar;
    procedure CalcRecordSize;
    function LoadBuffer(Buffer : PChar): TGetResult;
    function GetFieldSize(FieldDef : TFieldDef) : longint;
    function GetRecordUpdateBuffer : boolean;
    procedure SetPacketRecords(aValue : integer);
    function  IntAllocRecordBuffer: PChar;
    procedure DoFilterRecord(var Acceptable: Boolean);
    procedure ParseFilter(const AFilter: string);
  protected
    function GetNewBlobBuffer : PBlobBuffer;
    function GetNewWriteBlobBuffer : PBlobBuffer;
    procedure SetRecNo(Value: Longint); override;
    function  GetRecNo: Longint; override;
    function GetChangeCount: integer; virtual;
    function  AllocRecordBuffer: PChar; override;
    procedure FreeRecordBuffer(var Buffer: PChar); override;
    procedure InternalInitRecord(Buffer: PChar); override;
    function  GetCanModify: Boolean; override;
    function GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    procedure InternalOpen; override;
    procedure InternalClose; override;
    function getnextpacket : integer;
    function GetRecordSize: Word; override;
    procedure InternalPost; override;
    procedure InternalCancel; Override;
    procedure InternalDelete; override;
    procedure InternalFirst; override;
    procedure InternalLast; override;
    procedure InternalSetToRecord(Buffer: PChar); override;
    procedure InternalGotoBookmark(ABookmark: Pointer); override;
    procedure SetBookmarkData(Buffer: PChar; Data: Pointer); override;
    procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag); override;
    procedure GetBookmarkData(Buffer: PChar; Data: Pointer); override;
    function GetBookmarkFlag(Buffer: PChar): TBookmarkFlag; override;
    function IsCursorOpen: Boolean; override;
    function  GetRecordCount: Longint; override;
    procedure ApplyRecUpdate(UpdateKind : TUpdateKind); virtual;
    procedure SetOnUpdateError(const aValue: TResolverErrorEvent);
    procedure SetFilterText(const Value: String); override; {virtual;}
    procedure SetFiltered(Value: Boolean); override; {virtual;}
  {abstracts, must be overidden by descendents}
    function Fetch : boolean; virtual; abstract;
    function LoadField(FieldDef : TFieldDef;buffer : pointer; out CreateBlob : boolean) : boolean; virtual; abstract;
    procedure LoadBlobIntoStream(Field: TField;AStream: TStream); virtual; abstract;
    procedure LoadBlobIntoBuffer(FieldDef: TFieldDef;ABlobBuf: PBufBlobField); virtual; abstract;

  public
    constructor Create(AOwner: TComponent); override;
    function GetFieldData(Field: TField; Buffer: Pointer;
      NativeFormat: Boolean): Boolean; override;
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
    procedure SetFieldData(Field: TField; Buffer: Pointer;
      NativeFormat: Boolean); override;
    procedure SetFieldData(Field: TField; Buffer: Pointer); override;
    procedure ApplyUpdates; virtual; overload;
    procedure ApplyUpdates(MaxErrors: Integer); virtual; overload;
    procedure CancelUpdates; virtual;
    destructor Destroy; override;
    function Locate(const keyfields: string; const keyvalues: Variant; options: TLocateOptions) : boolean; override;
    function UpdateStatus: TUpdateStatus; override;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
    property ChangeCount : Integer read GetChangeCount;
  published
    property PacketRecords : Integer read FPacketRecords write SetPacketRecords default 10;
    property OnUpdateError: TResolverErrorEvent read FOnUpdateError write SetOnUpdateError;
  end;

implementation

uses variants, dbconst;

{ ---------------------------------------------------------------------
    TBufDataSet
  ---------------------------------------------------------------------}

constructor TBufDataset.Create(AOwner : TComponent);
begin
  Inherited Create(AOwner);
  SetLength(FUpdateBuffer,0);
  SetLength(FBlobBuffers,0);
  SetLength(FUpdateBlobBuffers,0);
  BookmarkSize := sizeof(TBufBookmark);
  FParser := nil;
  FPacketRecords := 10;
end;

procedure TBufDataset.SetPacketRecords(aValue : integer);
begin
  if (aValue = -1) or (aValue > 0) then FPacketRecords := aValue
    else DatabaseError(SInvPacketRecordsValue);
end;

destructor TBufDataset.Destroy;
begin
  inherited destroy;
end;

Function TBufDataset.GetCanModify: Boolean;
begin
  Result:= False;
end;

function TBufDataset.intAllocRecordBuffer: PChar;
begin
  // Note: Only the internal buffers of TDataset provide bookmark information
  result := AllocMem(FRecordsize+sizeof(TBufRecLinkItem));
end;

function TBufDataset.AllocRecordBuffer: PChar;
begin
  result := AllocMem(FRecordsize + sizeof(TBufBookmark) + CalcfieldsSize);
// The records are initialised, or else the fields of an empty, just-opened dataset
// are not null
  InitRecord(result);
end;

procedure TBufDataset.FreeRecordBuffer(var Buffer: PChar);
begin
  ReAllocMem(Buffer,0);
end;

procedure TBufDataset.InternalOpen;

begin
  CalcRecordSize;

  FBRecordcount := 0;

  FFirstRecBuf := pointer(IntAllocRecordBuffer);
  FLastRecBuf := FFirstRecBuf;
  FCurrentRecBuf := FLastRecBuf;

  FAllPacketsFetched := False;

  FOpen:=True;

  // parse filter expression
  try
    ParseFilter(Filter);
  except
    // oops, a problem with parsing, clear filter for now
    on E: Exception do Filter := EmptyStr;
  end;

end;

procedure TBufDataset.InternalClose;

var pc : pchar;
    r  : integer;

begin
  FOpen:=False;
  FCurrentRecBuf := FFirstRecBuf;
  while assigned(FCurrentRecBuf) do
    begin
    pc := pointer(FCurrentRecBuf);
    FCurrentRecBuf := FCurrentRecBuf^.next;
    FreeRecordBuffer(pc);
    end;

  if Length(FUpdateBuffer) > 0 then
    begin
    for r := 0 to length(FUpdateBuffer)-1 do with FUpdateBuffer[r] do
      begin
      if assigned(BookmarkData) then
        FreeRecordBuffer(OldValuesBuffer);
      end;
    end;
  SetLength(FUpdateBuffer,0);

  FFirstRecBuf:= nil;
  SetLength(FFieldBufPositions,0);

  if assigned(FParser) then FreeAndNil(FParser);
end;

procedure TBufDataset.InternalFirst;
begin
// if FCurrentRecBuf = FLastRecBuf then the dataset is just opened and empty
// in which case InternalFirst should do nothing (bug 7211)
  if FCurrentRecBuf <> FLastRecBuf then
    FCurrentRecBuf := nil;
end;

procedure TBufDataset.InternalLast;
begin
  repeat
  until (getnextpacket < FPacketRecords) or (FPacketRecords = -1);
  if FLastRecBuf <> FFirstRecBuf then
    FCurrentRecBuf := FLastRecBuf;
end;

procedure unSetFieldIsNull(NullMask : pbyte;x : longint); //inline;
begin
  NullMask[x div 8] := (NullMask[x div 8]) and not (1 shl (x mod 8));
end;

procedure SetFieldIsNull(NullMask : pbyte;x : longint); //inline;
begin
  NullMask[x div 8] := (NullMask[x div 8]) or (1 shl (x mod 8));
end;

function GetFieldIsNull(NullMask : pbyte;x : longint) : boolean; //inline;
begin
  result := ord(NullMask[x div 8]) and (1 shl (x mod 8)) > 0
end;

function TBufDataset.GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult;

var Acceptable : Boolean;
    SaveState: TDataSetState;


begin
  Result := grOK;
  repeat
  Acceptable := True;
  case GetMode of
    gmPrior :
      if not assigned(PBufRecLinkItem(FCurrentRecBuf)^.prior) then
        begin
        Result := grBOF;
        end
      else
        begin
        FCurrentRecBuf := PBufRecLinkItem(FCurrentRecBuf)^.prior;
        end;
    gmCurrent :
      if FCurrentRecBuf = FLastRecBuf then
        Result := grError;
    gmNext :
      if FCurrentRecBuf = FLastRecBuf then // Dataset is empty (just opened)
        begin
        if getnextpacket = 0 then result := grEOF;
        end
      else if FCurrentRecBuf = nil then FCurrentRecBuf := FFirstRecBuf
      else if (PBufRecLinkItem(FCurrentRecBuf)^.next = FLastRecBuf) then
        begin
        if getnextpacket > 0 then
          begin
          FCurrentRecBuf := PBufRecLinkItem(FCurrentRecBuf)^.next;
          end
        else
          begin
          result:=grEOF;
          end
        end
      else
        begin
        FCurrentRecBuf := PBufRecLinkItem(FCurrentRecBuf)^.next;
        end;
  end;

  if Result = grOK then
    begin

    with PBufBookmark(Buffer + FRecordSize)^ do
      begin
      BookmarkData := FCurrentRecBuf;
      BookmarkFlag := bfCurrent;
      end;
    move((pointer(FCurrentRecBuf)+sizeof(TBufRecLinkItem))^,buffer^,FRecordSize);
    GetCalcFields(Buffer);

    if Filtered then
      begin
      FFilterBuffer := Buffer;
      SaveState := SetTempState(dsFilter);
      DoFilterRecord(Acceptable);
      if (GetMode = gmCurrent) and not Acceptable then
        begin
        Acceptable := True;
        Result := grError;
        end;
      RestoreState(SaveState);
      end;
    end
  else if (Result = grError) and doCheck then
    DatabaseError('No record');
  until Acceptable;
end;

function TBufDataset.GetRecordUpdateBuffer : boolean;

var x : integer;
    CurrBuff : PChar;

begin
  GetBookmarkData(ActiveBuffer,@CurrBuff);
  if (FCurrentUpdateBuffer >= length(FUpdateBuffer)) or (FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData <> CurrBuff) then
   for x := 0 to high(FUpdateBuffer) do
    if FUpdateBuffer[x].BookmarkData = CurrBuff then
      begin
      FCurrentUpdateBuffer := x;
      break;
      end;
  Result := (FCurrentUpdateBuffer < length(FUpdateBuffer))  and (FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData = CurrBuff);
end;

procedure TBufDataset.InternalSetToRecord(Buffer: PChar);
begin
  FCurrentRecBuf := PBufBookmark(Buffer + FRecordSize)^.BookmarkData;
end;

procedure TBufDataset.SetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  PBufBookmark(Buffer + FRecordSize)^.BookmarkData := pointer(Data^);
end;

procedure TBufDataset.SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag);
begin
  PBufBookmark(Buffer + FRecordSize)^.BookmarkFlag := Value;
end;

procedure TBufDataset.GetBookmarkData(Buffer: PChar; Data: Pointer);
begin
  pointer(Data^) := PBufBookmark(Buffer + FRecordSize)^.BookmarkData;
end;

function TBufDataset.GetBookmarkFlag(Buffer: PChar): TBookmarkFlag;
begin
  Result := PBufBookmark(Buffer + FRecordSize)^.BookmarkFlag;
end;

procedure TBufDataset.InternalGotoBookmark(ABookmark: Pointer);
begin
  // note that ABookMark should be a PBufBookmark. But this way it can also be
  // a pointer to a TBufRecLinkItem
  FCurrentRecBuf := pointer(ABookmark^);
end;

function TBufDataset.getnextpacket : integer;

var i : integer;
    pb : pchar;
    
begin
  if FAllPacketsFetched then
    begin
    result := 0;
    exit;
    end;
  i := 0;
  pb := pchar(pointer(FLastRecBuf)+sizeof(TBufRecLinkItem));
  while ((i < FPacketRecords) or (FPacketRecords = -1)) and (loadbuffer(pb) = grOk) do
    begin
    FLastRecBuf^.next := pointer(IntAllocRecordBuffer);
    FLastRecBuf^.next^.prior := FLastRecBuf;
    FLastRecBuf := FLastRecBuf^.next;
    pb := pchar(pointer(FLastRecBuf)+sizeof(TBufRecLinkItem));
    inc(i);
    end;
  FBRecordCount := FBRecordCount + i;
  result := i;
end;

function TBufDataset.GetFieldSize(FieldDef : TFieldDef) : longint;

begin
  case FieldDef.DataType of
    ftString,
      ftFixedChar: result := FieldDef.Size + 1;
    ftSmallint,
      ftInteger,
      ftword     : result := sizeof(longint);
    ftBoolean    : result := sizeof(wordbool);
    ftBCD        : result := sizeof(currency);
    ftFloat      : result := sizeof(double);
    ftLargeInt   : result := sizeof(largeint);
    ftTime,
      ftDate,
      ftDateTime : result := sizeof(TDateTime);
    ftBlob       : result := sizeof(TBufBlobField)
  else Result := 10
  end;

end;

function TBufDataset.LoadBuffer(Buffer : PChar): TGetResult;

var NullMask        : pbyte;
    x               : longint;
    CreateblobField : boolean;
    BufBlob         : PBufBlobField;

begin
  if not Fetch then
    begin
    Result := grEOF;
    FAllPacketsFetched := True;
    Exit;
    end;

  NullMask := pointer(buffer);
  fillchar(Nullmask^,FNullmaskSize,0);
  inc(buffer,FNullmaskSize);

  for x := 0 to FieldDefs.count-1 do
    begin
    if not LoadField(FieldDefs[x],buffer,CreateblobField) then
      SetFieldIsNull(NullMask,x)
    else if CreateblobField then
      begin
      BufBlob := PBufBlobField(Buffer);
      BufBlob^.BlobBuffer := GetNewBlobBuffer;
      LoadBlobIntoBuffer(FieldDefs[x],BufBlob);
      end;
    inc(buffer,GetFieldSize(FieldDefs[x]));
    end;
  Result := grOK;
end;

function TBufDataset.GetCurrentBuffer: PChar;
begin
  if State = dsFilter then Result := FFilterBuffer
  else if state = dsCalcFields then Result := CalcBuffer
  else Result := ActiveBuffer;
end;


function TBufDataset.GetFieldData(Field: TField; Buffer: Pointer;
  NativeFormat: Boolean): Boolean;
begin
  Result := GetFieldData(Field, Buffer);
end;

function TBufDataset.GetFieldData(Field: TField; Buffer: Pointer): Boolean;

var CurrBuff : pchar;

begin
  Result := False;
  if state = dsOldValue then
    begin
    if not GetRecordUpdateBuffer then
      begin
      // There is no old value available
      result := false;
      exit;
      end;
    currbuff := FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer+sizeof(TBufRecLinkItem);
    end
  else
    begin
    CurrBuff := GetCurrentBuffer;
    if not assigned(CurrBuff) then
      begin
      result := false;
      exit;
      end;
    end;

  If Field.Fieldno > 0 then // If = 0, then calculated field or something similar
    begin
    if GetFieldIsnull(pbyte(CurrBuff),Field.Fieldno-1) then
      begin
      result := false;
      exit;
      end;
    if assigned(buffer) then
      begin
      inc(CurrBuff,FFieldBufPositions[Field.FieldNo-1]);
      Move(CurrBuff^, Buffer^, GetFieldSize(FieldDefs[Field.FieldNo-1]));
      end;
    Result := True;
    end
  else
    begin
    Inc(CurrBuff, GetRecordSize + Field.Offset);
    Result := Boolean(CurrBuff^);
    if result and assigned(Buffer) then
      begin
      inc(CurrBuff);
      Move(CurrBuff^, Buffer^, Field.Datasize);
      end;
    end;
end;

procedure TBufDataset.SetFieldData(Field: TField; Buffer: Pointer;
  NativeFormat: Boolean);
begin
  SetFieldData(Field,Buffer);
end;

procedure TBufDataset.SetFieldData(Field: TField; Buffer: Pointer);

var CurrBuff : pointer;
    NullMask : pbyte;

begin
  if not (state in [dsEdit, dsInsert, dsFilter, dsCalcFields]) then
    begin
    DatabaseErrorFmt(SNotInEditState,[Name],self);
    exit;
    end;
  if state = dsFilter then  // Set the value into the 'temporary' FLastRecBuf buffer for Locate and Lookup
    CurrBuff := pointer(FLastRecBuf) + sizeof(TBufRecLinkItem)
  else
    CurrBuff := GetCurrentBuffer;
  If Field.Fieldno > 0 then // If = 0, then calculated field or something
    begin
    NullMask := CurrBuff;

    inc(CurrBuff,FFieldBufPositions[Field.FieldNo-1]);
    if assigned(buffer) then
      begin
      Move(Buffer^, CurrBuff^, GetFieldSize(FieldDefs[Field.FieldNo-1]));
      unSetFieldIsNull(NullMask,Field.FieldNo-1);
      end
    else
      SetFieldIsNull(NullMask,Field.FieldNo-1);
    end
  else
    begin
    Inc(CurrBuff, GetRecordSize + Field.Offset);
    Boolean(CurrBuff^) := Buffer <> nil;
    inc(CurrBuff);
    if assigned(Buffer) then
      Move(Buffer^, CurrBuff^, Field.Datasize);
    end;
  if not (State in [dsCalcFields, dsFilter, dsNewValue]) then
    DataEvent(deFieldChange, Ptrint(Field));
end;

procedure TBufDataset.InternalDelete;

begin
  GetBookmarkData(ActiveBuffer,@FCurrentRecBuf);

  if FCurrentRecBuf <> FFirstRecBuf then FCurrentRecBuf^.prior^.next := FCurrentRecBuf^.next
  else FFirstRecBuf := FCurrentRecBuf^.next;

  FCurrentRecBuf^.next^.prior :=  FCurrentRecBuf^.prior;

  if not GetRecordUpdateBuffer then
    begin
    FCurrentUpdateBuffer := length(FUpdateBuffer);
    SetLength(FUpdateBuffer,FCurrentUpdateBuffer+1);

    FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer := pchar(FCurrentRecBuf);
    FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData := FCurrentRecBuf;

    FCurrentRecBuf := FCurrentRecBuf^.next;
    end
  else
    begin
    if FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind = ukModify then
      begin
      FCurrentRecBuf := FCurrentRecBuf^.next;
      FreeRecordBuffer(pchar(FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData));
      FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData := FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer;
      end
    else
      begin
      FCurrentRecBuf := FCurrentRecBuf^.next;
      FreeRecordBuffer(pchar(FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData));
      FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData := nil;  //this 'disables' the updatebuffer
      end;
    end;

  dec(FBRecordCount);
  FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind := ukDelete;
end;


procedure TBufDataset.ApplyRecUpdate(UpdateKind : TUpdateKind);

begin
  raise EDatabaseError.Create(SApplyRecNotSupported);
end;

procedure TBufDataset.CancelUpdates;

var r              : Integer;

begin
  CheckBrowseMode;

  if Length(FUpdateBuffer) > 0 then
    begin
    r := Length(FUpdateBuffer) -1;
    while r > -1 do with FUpdateBuffer[r] do
      begin
      if assigned(FUpdateBuffer[r].BookmarkData) then
        begin
        if UpdateKind = ukModify then
          begin
          move(pchar(OldValuesBuffer+sizeof(TBufRecLinkItem))^,pchar(BookmarkData+sizeof(TBufRecLinkItem))^,FRecordSize);
          FreeRecordBuffer(OldValuesBuffer);
          end
        else if UpdateKind = ukDelete then
          begin
          if assigned(PBufRecLinkItem(BookmarkData)^.prior) then  // or else it was the first record
            PBufRecLinkItem(BookmarkData)^.prior^.next := BookmarkData
          else
            FFirstRecBuf := BookmarkData;
          PBufRecLinkItem(BookmarkData)^.next^.prior := BookmarkData;
          inc(FBRecordCount);
          end
        else if UpdateKind = ukInsert then
          begin
          if assigned(PBufRecLinkItem(BookmarkData)^.prior) then // or else it was the first record
            PBufRecLinkItem(BookmarkData)^.prior^.next := PBufRecLinkItem(BookmarkData)^.next
          else
            FFirstRecBuf := PBufRecLinkItem(BookmarkData)^.next;
          PBufRecLinkItem(BookmarkData)^.next^.prior := PBufRecLinkItem(BookmarkData)^.prior;
          // resync won't work if the currentbuffer is freed...
          if FCurrentRecBuf = BookmarkData then FCurrentRecBuf := FCurrentRecBuf^.next;
          FreeRecordBuffer(BookmarkData);
          dec(FBRecordCount);
          end;
        end;
      dec(r)
      end;

    SetLength(FUpdateBuffer,0);
    Resync([]);
    end;
end;

procedure TBufDataset.SetOnUpdateError(const AValue: TResolverErrorEvent);

begin
  FOnUpdateError := AValue;
end;

procedure TBufDataset.ApplyUpdates; // For backwards-compatibility

begin
  ApplyUpdates(0);
end;

procedure TBufDataset.ApplyUpdates(MaxErrors: Integer);

var r            : Integer;
    FailedCount  : integer;
    Response     : TResolverResponse;
    StoreRecBuf  : PBufRecLinkItem;
    AUpdateErr   : EUpdateError;

begin
  CheckBrowseMode;

  StoreRecBuf := FCurrentRecBuf;

  r := 0;
  FailedCount := 0;
  Response := rrApply;
  try
    while (r < Length(FUpdateBuffer)) and (Response <> rrAbort) do
      begin
      if assigned(FUpdateBuffer[r].BookmarkData) then
        begin
        InternalGotoBookmark(@FUpdateBuffer[r].BookmarkData);
        Resync([rmExact,rmCenter]);
        Response := rrApply;
        try
          ApplyRecUpdate(FUpdateBuffer[r].UpdateKind);
        except
          on E: EDatabaseError do
            begin
            Inc(FailedCount);
            if failedcount > word(MaxErrors) then Response := rrAbort
            else Response := rrSkip;
            if assigned(FOnUpdateError) then
              begin
              AUpdateErr := EUpdateError.Create(SOnUpdateError,E.Message,0,0,Exception(AcquireExceptionObject));
              FOnUpdateError(Self,Self,AUpdateErr,FUpdateBuffer[r].UpdateKind,Response);
              AUpdateErr.Free;
              if Response in [rrApply, rrIgnore] then dec(FailedCount);
              if Response = rrApply then dec(r);
              end
            else if Response = rrAbort then
              Raise EUpdateError.Create(SOnUpdateError,E.Message,0,0,Exception(AcquireExceptionObject));
            end
          else
            raise;
        end;
        if response in [rrApply, rrIgnore] then
          begin
          FreeRecordBuffer(FUpdateBuffer[r].OldValuesBuffer);
          FUpdateBuffer[r].BookmarkData := nil;
          end
        end;
      inc(r);
      end;
  finally
    if failedcount = 0 then
      begin
      SetLength(FUpdateBuffer,0);

      if assigned(FUpdateBlobBuffers) then for r:=0 to length(FUpdateBlobBuffers)-1 do
       if assigned(FUpdateBlobBuffers[r]) then
        begin
        if FUpdateBlobBuffers[r]^.OrgBufID >= 0 then
          begin
          Freemem(FBlobBuffers[FUpdateBlobBuffers[r]^.OrgBufID]^.Buffer);
          Dispose(FBlobBuffers[FUpdateBlobBuffers[r]^.OrgBufID]);
          FBlobBuffers[FUpdateBlobBuffers[r]^.OrgBufID] :=FUpdateBlobBuffers[r];
          end
        else
          begin
          setlength(FBlobBuffers,length(FBlobBuffers)+1);
          FUpdateBlobBuffers[r]^.OrgBufID := high(FBlobBuffers);
          FBlobBuffers[high(FBlobBuffers)] := FUpdateBlobBuffers[r];
          
          end;
        end;
      SetLength(FUpdateBlobBuffers,0);
      end;

    FCurrentRecBuf := StoreRecBuf;
    Resync([]);
  end;
end;


procedure TBufDataset.InternalCancel;

Var i            : integer;

begin
  if assigned(FUpdateBlobBuffers) then for i:=0 to length(FUpdateBlobBuffers)-1 do
   if assigned(FUpdateBlobBuffers[i]) and (FUpdateBlobBuffers[i]^.FieldNo>0) then
    begin
    Reallocmem(FUpdateBlobBuffers[i]^.Buffer,0);
    Dispose(FUpdateBlobBuffers[i]);
    FUpdateBlobBuffers[i] := nil;
    end;
end;

procedure TBufDataset.InternalPost;

Var tmpRecBuffer : PBufRecLinkItem;
    CurrBuff     : PChar;
    i            : integer;
    blobbuf      : tbufblobfield;
    NullMask     : pbyte;

begin
  if assigned(FUpdateBlobBuffers) then for i:=0 to length(FUpdateBlobBuffers)-1 do
   if assigned(FUpdateBlobBuffers[i]) and (FUpdateBlobBuffers[i]^.FieldNo>0) then
    begin
    blobbuf.BlobBuffer := FUpdateBlobBuffers[i];
    CurrBuff := ActiveBuffer;
    NullMask := pbyte(CurrBuff);

    inc(CurrBuff,FFieldBufPositions[FUpdateBlobBuffers[i]^.FieldNo-1]);
    Move(blobbuf, CurrBuff^, GetFieldSize(FieldDefs[FUpdateBlobBuffers[i]^.FieldNo-1]));
    unSetFieldIsNull(NullMask,FUpdateBlobBuffers[i]^.FieldNo-1);
    
    FUpdateBlobBuffers[i]^.FieldNo := -1;
    end;

  if state = dsInsert then
    begin
    if GetBookmarkFlag(ActiveBuffer) = bfEOF then
      // Append
      FCurrentRecBuf := FLastRecBuf
    else
      // The active buffer is the newly created TDataset record,
      // from which the bookmark is set to the record where the new record should be
      // inserted
      GetBookmarkData(ActiveBuffer,@FCurrentRecBuf);

    // Create the new record buffer
    tmpRecBuffer := FCurrentRecBuf^.prior;

    FCurrentRecBuf^.prior := pointer(IntAllocRecordBuffer);
    FCurrentRecBuf^.prior^.next := FCurrentRecBuf;
    FCurrentRecBuf := FCurrentRecBuf^.prior;
    If assigned(tmpRecBuffer) then // if not, it's the first record
      begin
      FCurrentRecBuf^.prior := tmpRecBuffer;
      tmpRecBuffer^.next := FCurrentRecBuf
      end
    else
      FFirstRecBuf := FCurrentRecBuf;

    // Link the newly created record buffer to the newly created TDataset record
    with PBufBookmark(ActiveBuffer + FRecordSize)^ do
      begin
      BookmarkData := FCurrentRecBuf;
      BookmarkFlag := bfInserted;
      end;
      
    inc(FBRecordCount);
    end
  else
    GetBookmarkData(ActiveBuffer,@FCurrentRecBuf);

  if not GetRecordUpdateBuffer then
    begin
    FCurrentUpdateBuffer := length(FUpdateBuffer);
    SetLength(FUpdateBuffer,FCurrentUpdateBuffer+1);

    FUpdateBuffer[FCurrentUpdateBuffer].BookmarkData := FCurrentRecBuf;

    if state = dsEdit then
      begin
      // Update the oldvalues-buffer
      FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer := intAllocRecordBuffer;
      move(FCurrentRecBuf^,FUpdateBuffer[FCurrentUpdateBuffer].OldValuesBuffer^,FRecordSize+sizeof(TBufRecLinkItem));
      FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind := ukModify;
      end
    else
      FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind := ukInsert;
    end;

  CurrBuff := pchar(FCurrentRecBuf);
  inc(Currbuff,sizeof(TBufRecLinkItem));
  move(ActiveBuffer^,CurrBuff^,FRecordSize);
end;

procedure TBufDataset.CalcRecordSize;

var x : longint;

begin
  FNullmaskSize := 1+((FieldDefs.count-1) div 8);
  FRecordSize := FNullmaskSize;
  SetLength(FFieldBufPositions,FieldDefs.count);
  for x := 0 to FieldDefs.count-1 do
    begin
    FFieldBufPositions[x] := FRecordSize;
    inc(FRecordSize, GetFieldSize(FieldDefs[x]));
    end;
end;

function TBufDataset.GetRecordSize : Word;

begin
  result := FRecordSize + sizeof(TBufBookmark);
end;

function TBufDataset.GetChangeCount: integer;

begin
  result := length(FUpdateBuffer);
end;


procedure TBufDataset.InternalInitRecord(Buffer: PChar);

begin
  FillChar(Buffer^, FRecordSize, #0);

  fillchar(Buffer^,FNullmaskSize,255);
end;

procedure TBufDataset.SetRecNo(Value: Longint);

var recnr        : integer;
    TmpRecBuffer : PBufRecLinkItem;

begin
  checkbrowsemode;
  if value > RecordCount then
    begin
    repeat until (getnextpacket < FPacketRecords) or (value <= RecordCount) or (FPacketRecords = -1);
    if value > RecordCount then
      begin
      DatabaseError(SNoSuchRecord,self);
      exit;
      end;
    end;
  TmpRecBuffer := FFirstRecBuf;
  for recnr := 1 to value-1 do
    TmpRecBuffer := TmpRecBuffer^.next;
  GotoBookmark(@TmpRecBuffer);
end;

function TBufDataset.GetRecNo: Longint;

Var SearchRecBuffer : PBufRecLinkItem;
    TmpRecBuffer    : PBufRecLinkItem;
    recnr           : integer;
    abuf            : PChar;

begin
  abuf := GetCurrentBuffer;
  // If abuf isn't assigned, the recordset probably isn't opened.
  if assigned(abuf) and (FBRecordCount>0) and (state <> dsInsert) then
    begin
    GetBookmarkData(abuf,@SearchRecBuffer);
    TmpRecBuffer := FFirstRecBuf;
    recnr := 1;
    while TmpRecBuffer <> SearchRecBuffer do
      begin
      inc(recnr);
      TmpRecBuffer := TmpRecBuffer^.next;
      end;
    result := recnr;
    end
  else result := 0;
end;

function TBufDataset.IsCursorOpen: Boolean;

begin
  Result := FOpen;
end;

Function TBufDataset.GetRecordCount: Longint;

begin
  Result := FBRecordCount;
end;

Function TBufDataSet.UpdateStatus: TUpdateStatus;

begin
  Result:=usUnmodified;
  if GetRecordUpdateBuffer then
    case FUpdateBuffer[FCurrentUpdateBuffer].UpdateKind of
      ukModify : Result := usModified;
      ukInsert : Result := usInserted;
      ukDelete : Result := usDeleted;
    end;
end;

function TbufDataset.GetNewBlobBuffer : PBlobBuffer;

var ABlobBuffer : PBlobBuffer;

begin
  setlength(FBlobBuffers,length(FBlobBuffers)+1);
  new(ABlobBuffer);
  fillbyte(ABlobBuffer^,sizeof(ABlobBuffer^),0);
  ABlobBuffer^.OrgBufID := high(FUpdateBlobBuffers);
  FBlobBuffers[high(FBlobBuffers)] := ABlobBuffer;
  result := ABlobBuffer;
end;

function TbufDataset.GetNewWriteBlobBuffer : PBlobBuffer;

var ABlobBuffer : PBlobBuffer;

begin
  setlength(FUpdateBlobBuffers,length(FUpdateBlobBuffers)+1);
  new(ABlobBuffer);
  fillbyte(ABlobBuffer^,sizeof(ABlobBuffer^),0);
  FUpdateBlobBuffers[high(FUpdateBlobBuffers)] := ABlobBuffer;
  result := ABlobBuffer;
end;

function TBufBlobStream.Seek(Offset: Longint; Origin: Word): Longint;

begin
  Case Origin of
    soFromBeginning : FPosition:=Offset;
    soFromEnd       : FPosition:=FBlobBuffer^.Size+Offset;
    soFromCurrent   : FpoSition:=FPosition+Offset;
  end;
  Result:=FPosition;
end;


function TBufBlobStream.Read(var Buffer; Count: Longint): Longint;

var ptr : pointer;

begin
  if FPosition + count > FBlobBuffer^.Size then
    count := FBlobBuffer^.Size-FPosition;
  ptr := FBlobBuffer^.Buffer+FPosition;
  move(ptr^,buffer,count);
  inc(FPosition,count);
  result := count;
end;

function TBufBlobStream.Write(const Buffer; Count: Longint): Longint;

var ptr : pointer;

begin
  ReAllocMem(FBlobBuffer^.Buffer,FPosition+Count);
  ptr := FBlobBuffer^.Buffer+FPosition;
  move(buffer,ptr^,count);
  inc(FBlobBuffer^.Size,count);
  inc(FPosition,count);
  Result := count;
end;

constructor TBufBlobStream.Create(Field: TBlobField; Mode: TBlobStreamMode);

var bufblob : TBufBlobField;

begin
  FDataset := Field.DataSet as TBufDataset;
  if mode = bmread then
    begin
    if not field.getData(@bufblob) then
      DatabaseError(SFieldIsNull);
    if not assigned(bufblob.BlobBuffer) then with FDataSet do
      begin
      FBlobBuffer := GetNewBlobBuffer;
      bufblob.BlobBuffer := FBlobBuffer;
      LoadBlobIntoBuffer(FieldDefs[field.FieldNo-1],@bufblob);
      end
    else
      FBlobBuffer := bufblob.BlobBuffer;
    end
  else if mode=bmWrite then with FDataSet as TBufDataset do
    begin
    FBlobBuffer := GetNewWriteBlobBuffer;
    FBlobBuffer^.FieldNo := Field.FieldNo;
    if (field.getData(@bufblob)) and assigned(bufblob.BlobBuffer) then
      FBlobBuffer^.OrgBufID := bufblob.BlobBuffer^.OrgBufID
    else
      FBlobBuffer^.OrgBufID := -1;
    end;
end;

function TBufDataset.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;

var bufblob : TBufBlobField;

begin
  result := nil;
  if mode=bmread then
    begin
    if not field.getData(@bufblob) then
      exit;

    result := TBufBlobStream.Create(Field as tblobfield,bmread);
    end
  else if mode=bmWrite then
    begin
    if not (state in [dsEdit, dsInsert, dsFilter, dsCalcFields]) then
      begin
      DatabaseErrorFmt(SNotInEditState,[Name],self);
      exit;
      end;

    result := TBufBlobStream.Create(Field as tblobfield,bmWrite);

    if not (State in [dsCalcFields, dsFilter, dsNewValue]) then
      DataEvent(deFieldChange, Ptrint(Field));
    end;
end;

procedure TBufDataset.DoFilterRecord(var Acceptable: Boolean);
begin
  Acceptable := true;
  // check user filter
  if Assigned(OnFilterRecord) then
    OnFilterRecord(Self, Acceptable);

  // check filtertext
  if Acceptable and (Length(Filter) > 0) then
    Acceptable := Boolean((FParser.ExtractFromBuffer(GetCurrentBuffer))^);

end;

procedure TBufDataset.SetFilterText(const Value: String);
begin
  if Value = Filter then
    exit;

  // parse
  ParseFilter(Value);

  // call dataset method
  inherited;

  // refilter dataset if filtered
  if IsCursorOpen and Filtered then Refresh;
end;

procedure TBufDataset.SetFiltered(Value: Boolean); {override;}
begin
  if Value = Filtered then
    exit;

  // pass on to ancestor
  inherited;

  // only refresh if active
  if IsCursorOpen then
    Refresh;
end;

procedure TBufDataset.ParseFilter(const AFilter: string);
begin
  // parser created?
  if Length(AFilter) > 0 then
  begin
    if (FParser = nil) and IsCursorOpen then
    begin
      FParser := TBufDatasetParser.Create(Self);
    end;
    // have a parser now?
    if FParser <> nil then
    begin
      // set options
      FParser.PartialMatch := not (foNoPartialCompare in FilterOptions);
      FParser.CaseInsensitive := foCaseInsensitive in FilterOptions;
      // parse expression
      FParser.ParseExpression(AFilter);
    end;
  end;
end;


Function TBufDataset.Locate(const KeyFields: string; const KeyValues: Variant; options: TLocateOptions) : boolean;


  function CompareText0(substr, astr: pchar; len : integer; options: TLocateOptions): integer;

  var
    i : integer; Chr1, Chr2: byte;
  begin
    result := 0;
    i := 0;
    chr1 := 1;
    while (result=0) and (i<len) and (chr1 <> 0) do
      begin
      Chr1 := byte(substr[i]);
      Chr2 := byte(astr[i]);
      inc(i);
      if loCaseInsensitive in options then
        begin
        if Chr1 in [97..122] then
          dec(Chr1,32);
        if Chr2 in [97..122] then
          dec(Chr2,32);
        end;
      result := Chr1 - Chr2;
      end;
    if (result <> 0) and (chr1 = 0) and (loPartialKey in options) then result := 0;
  end;


var keyfield    : TField;     // Field to search in
    ValueBuffer : pchar;      // Pointer to value to search for, in TField' internal format
    VBLength    : integer;

    FieldBufPos : PtrInt;     // Amount to add to the record buffer to get the FieldBuffer
    CurrLinkItem: PBufRecLinkItem;
    CurrBuff    : pchar;
    bm          : TBufBookmark;

    CheckNull   : Boolean;
    SaveState   : TDataSetState;

begin
// For now it is only possible to search in one field at the same time
  result := False;

  if IsEmpty then exit;

  keyfield := FieldByName(keyfields);
  CheckNull := VarIsNull(KeyValues);

  if not CheckNull then
    begin
    SaveState := State;
    SetTempState(dsFilter);
    keyfield.Value := KeyValues;
    RestoreState(SaveState);

    FieldBufPos := FFieldBufPositions[keyfield.FieldNo-1];
    VBLength := keyfield.DataSize;
    ValueBuffer := AllocMem(VBLength);
    currbuff := pointer(FLastRecBuf)+sizeof(TBufRecLinkItem)+FieldBufPos;
    move(currbuff^,ValueBuffer^,VBLength);
    end;

  CurrLinkItem := FFirstRecBuf;

  if CheckNull then
    begin
    repeat
    currbuff := pointer(CurrLinkItem)+sizeof(TBufRecLinkItem);
    if GetFieldIsnull(pbyte(CurrBuff),keyfield.Fieldno-1) then
      begin
      result := True;
      break;
      end;
    CurrLinkItem := CurrLinkItem^.next;
    if CurrLinkItem = FLastRecBuf then getnextpacket;
    until CurrLinkItem = FLastRecBuf;
    end
  else if keyfield.DataType = ftString then
    begin
    repeat
    currbuff := pointer(CurrLinkItem)+sizeof(TBufRecLinkItem);
    if not GetFieldIsnull(pbyte(CurrBuff),keyfield.Fieldno-1) then
      begin
      inc(CurrBuff,FieldBufPos);
      if CompareText0(ValueBuffer,CurrBuff,VBLength,options) = 0 then
        begin
        result := True;
        break;
        end;
      end;
    CurrLinkItem := CurrLinkItem^.next;
    if CurrLinkItem = FLastRecBuf then getnextpacket;
    until CurrLinkItem = FLastRecBuf;
    end
  else
    begin
    repeat
    currbuff := pointer(CurrLinkItem)+sizeof(TBufRecLinkItem);
    if not GetFieldIsnull(pbyte(CurrBuff),keyfield.Fieldno-1) then
      begin
      inc(CurrBuff,FieldBufPos);
      if CompareByte(ValueBuffer^,CurrBuff^,VBLength) = 0 then
        begin
        result := True;
        break;
        end;
      end;

    CurrLinkItem := CurrLinkItem^.next;
    if CurrLinkItem = FLastRecBuf then getnextpacket;
    until CurrLinkItem = FLastRecBuf;
    end;


  if Result then
    begin
    bm.BookmarkData := CurrLinkItem;
    bm.BookmarkFlag := bfCurrent;
    GotoBookmark(@bm);
    end;

  ReAllocmem(ValueBuffer,0);
end;

begin
end.
