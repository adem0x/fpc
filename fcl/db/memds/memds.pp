{
    This file is part of the Free Component Library (FCL)
    Copyright (c) 1999-2006 by the Free Pascal development team

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$IFDEF FPC}
{$mode objfpc}
{$ENDIF FPC}
{$H+}
{
  TMemDataset : In-memory dataset.
  - Has possibility to copy Structure/Data from other dataset.
  - Can load/save to/from stream.
  Ideas taken from THKMemTab Component by Harri Kasulke - Hamburg/Germany
  E-mail: harri.kasulke@okay.net
}


unit memds;

interface

uses
  SysUtils, Classes, DB;

Const
  //Default size used when string size is 0
  MEMDS_STRING_MAXSIZE = 200;

  // Stream Markers.
  MarkerSize  = SizeOf(Integer);

  smEOF       = 0;
  smFieldDefs = 1;
  smData      = 2;

type
  MDSError=class(Exception);

  PRecInfo=^TMTRecInfo;
  TMTRecInfo=record
    Bookmark: Longint;
    BookmarkFlag: TBookmarkFlag;
  end;

  PInteger  = ^Integer;
  PSmallInt = ^SmallInt;
  PInt64    = ^Int64;
  PFloat    = ^Extended;
  PBoolean  = ^Boolean;


  TMemDataset=class(TDataSet)
  private
    FOpenStream : TStream;
    FFileName : String;
    FModified : Boolean;
    FStream: TMemoryStream;
    FRecInfoOffset: integer;
    FRecInfoSize: integer;
    FRecCount: integer;
    FRecSize: integer;
    FRecBufferSize: integer;
    FCurrRecNo: integer;
    FIsOpen: boolean;
    FFilterBuffer: PChar;
    FFieldOffsetList : TList;
  protected
    // Mandatory
    function  AllocRecordBuffer: PChar; override;
    procedure FreeRecordBuffer(var Buffer: PChar); override;
    procedure GetBookmarkData(Buffer: PChar; Data: Pointer); override;
    function  GetBookmarkFlag(Buffer: PChar): TBookmarkFlag; override;
    function  GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
    function  GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function  GetRecordSize: Word; override;
    procedure InternalAddRecord(Buffer: Pointer; DoAppend: Boolean); override;
    procedure InternalClose; override;
    procedure InternalDelete; override;
    procedure InternalFirst; override;
    procedure InternalGotoBookmark(ABookmark: Pointer); override;
    procedure InternalInitFieldDefs; override;
    procedure InternalInitRecord(Buffer: PChar); override;
    procedure InternalLast; override;
    procedure InternalOpen; override;
    procedure InternalPost; override;
    procedure InternalSetToRecord(Buffer: PChar); override;
    function  IsCursorOpen: Boolean; override;
    procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag); override;
    procedure SetBookmarkData(Buffer: PChar; Data: Pointer); override;
    procedure SetFieldData(Field: TField; Buffer: Pointer); override;

    // Optional.
    function GetRecordCount: Integer; override;
    procedure SetRecNo(Value: Integer); override;
    function GetRecNo: Integer; override;

    // Own.
    Procedure RaiseError(Fmt : String; Args : Array of const);
    Procedure CheckMarker(F : TStream; Marker : Integer);
    Procedure WriteMarker(F : TStream; Marker : Integer);
    procedure ReadFieldDefsFromStream(F : TStream);
    procedure SaveFieldDefsToStream(F : TStream);
    // These should be overridden if you want to load more data.
    // E.g. index defs.
    Procedure LoadDataFromStream(F : TStream); virtual;
    // If SaveData=False, a size 0 block should be written.
    Procedure SaveDataToStream(F : TStream; SaveData : Boolean); virtual;

  private
    function  MDSGetRecordOffset(ARecNo: integer): longint;
    function  MDSGetFieldOffset(FieldNo: integer): integer;
    function  MDSGetFieldSize(FieldNo: integer): integer;
    function  MDSGetActiveBuffer(var Buffer: PChar): Boolean;
    procedure MDSReadRecord(Buffer:PChar;ARecNo:Integer);
    procedure MDSWriteRecord(Buffer:PChar;ARecNo:Integer);
    procedure MDSAppendRecord(Buffer:PChar);
    function  MDSFilterRecord(Buffer: PChar): Boolean;
    function  MDSGetRecInfo(Buffer: PChar): TMTRecInfo;
    procedure MDSSetRecInfo(Buffer: PChar;
                            Flag: TBookmarkFlag);
    procedure MDSSetRecInfo(Buffer: PChar;
                            Flag: TBookmarkFlag;
                            ABookmark: Longint);
    procedure MDSSetRecInfo(Buffer: PChar;
                            ABookmark: Longint);
  public
    constructor Create(AOwner:tComponent); override;
    destructor Destroy; override;
    procedure CreateTable;

    Function  DataSize : Integer;

    procedure Clear(ClearDefs : Boolean);
    procedure Clear;
    Procedure SaveToFile(AFileName : String);
    Procedure SaveToFile(AFileName : String; SaveData : Boolean);
    Procedure SaveToStream(F : TStream);
    Procedure SaveToStream(F : TStream; SaveData : Boolean);
    Procedure LoadFromStream(F : TStream);
    Procedure LoadFromFile(AFileName : String);
    Procedure CopyFromDataset(DataSet : TDataSet);
    Procedure CopyFromDataset(DataSet : TDataSet; CopyData : Boolean);

    Property Modified : Boolean Read FModified;

  published
    Property FileName : String Read FFileName Write FFileName;
    property Filtered;
    Property Active;
    Property FieldDefs;
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
    property OnDeleteError;
    property OnEditError;
    property OnNewRecord;
    property OnPostError;
    property OnFilterRecord;
  end;

implementation

ResourceString
  SErrFieldTypeNotSupported = 'Fieldtype of Field "%s" not supported.';
  SErrBookMarkNotFound      = 'Bookmark %d not found.';
  SErrInvalidDataStream     = 'Error in data stream at position %d';
  SErrInvalidMarkerAtPos    = 'Wrong data stream marker at position %d. Got %d, expected %d';
  SErrNoFileName            = 'Filename must not be empty.';

{ ---------------------------------------------------------------------
    Stream functions
  ---------------------------------------------------------------------}

Function ReadInteger(S : TStream) : Integer;

begin
  S.ReadBuffer(Result,SizeOf(Result));
end;

Function ReadString(S : TStream) : String;

Var
  L : Integer;

begin
  L:=ReadInteger(S);
  Setlength(Result,L);
  If (L<>0) then
    S.ReadBuffer(Result[1],L);
end;

Procedure WriteInteger(S : TStream; Value : Integer);

begin
  S.WriteBuffer(Value,SizeOf(Value));
end;

Procedure WriteString(S : TStream; Value : String);

Var
  L : Integer;

begin
  L:=Length(Value);
  WriteInteger(S,Length(Value));
  If (L<>0) then
    S.WriteBuffer(Value[1],L);
end;

{ ---------------------------------------------------------------------
    TMemDataset
  ---------------------------------------------------------------------}


constructor TMemDataset.Create(AOwner:tComponent);

begin
  inherited create(aOwner);
  FStream:=TMemoryStream.Create;
  FFieldOffsetList := TList.Create;
  FRecInfoSize:=SizeOf(TMTRecInfo);
  FRecCount:=0;
  FRecSize:=0;
  FRecBufferSize:=0;
  FRecInfoOffset:=0;
  FCurrRecNo:=-1;
  FIsOpen:=False;
end;

Destructor TMemDataset.Destroy;
begin
  FStream.Free;
  FFieldOffsetList.Free;
  inherited Destroy;
end;

function TMemDataset.MDSGetRecordOffset(ARecNo: integer): longint;
begin
  Result:=FRecSize*ARecNo
end;

function TMemDataset.MDSGetFieldOffset(FieldNo: integer): integer;
begin
  //FFieldOffsetList calculated once in createtable
  Result:=Integer(FFieldOffsetList.Items[FieldNo-1]);
end;

Procedure TMemDataset.RaiseError(Fmt : String; Args : Array of const);

begin
  Raise MDSError.CreateFmt(Fmt,Args);
end;

function TMemDataset.MDSGetFieldSize(FieldNo: integer): integer;

begin
  case FieldDefs.Items[FieldNo-1].Datatype of
   ftString:   result:=FieldDefs.Items[FieldNo-1].Size+1;
   ftBoolean:  result:=SizeOf(Boolean);
   ftFloat:    result:=SizeOf(Extended);
   ftLargeInt: result:=SizeOf(int64);
   ftSmallInt: result:=SizeOf(SmallInt);
   ftInteger:  result:=SizeOf(Integer);
   ftDate:     result:=SizeOf(TDateTime);
   ftTime:     result:=SizeOf(TDateTime);
 else
   RaiseError(SErrFieldTypeNotSupported,[FieldDefs.Items[FieldNo-1].Name]);
 end;
end;

function TMemDataset.MDSGetActiveBuffer(var Buffer: PChar): Boolean;

begin
 case State of
   dsBrowse:
     if IsEmpty then
       Buffer:=nil
     else
       Buffer:=ActiveBuffer;

  dsEdit,
  dsInsert:
     Buffer:=ActiveBuffer;
  dsFilter:
     Buffer:=FFilterBuffer;
 else
   Buffer:=nil;
 end;
 Result:=Assigned(Buffer);
end;

procedure TMemDataset.MDSReadRecord(Buffer:PChar;ARecNo:Integer);   //Reads a Rec from Stream in Buffer
begin
  FStream.Position:=MDSGetRecordOffset(ARecNo);
  FStream.ReadBuffer(Buffer^, FRecSize);
end;

procedure TMemDataset.MDSWriteRecord(Buffer:PChar;ARecNo:Integer);  //Writes a Rec from Buffer to Stream
begin
  FStream.Position:=MDSGetRecordOffset(ARecNo);
  FStream.WriteBuffer(Buffer^, FRecSize);
  FModified:=True;
end;

procedure TMemDataset.MDSAppendRecord(Buffer:PChar);   //Appends a Rec (from Buffer) to Stream
begin
  FStream.Position:=MDSGetRecordOffset(FRecCount);
  FStream.WriteBuffer(Buffer^, FRecSize);
  FModified:=True;
end;

//Abstract Overrides
function TMemDataset.AllocRecordBuffer: PChar;
begin
  GetMem(Result,FRecBufferSize);
end;

procedure TMemDataset.FreeRecordBuffer (var Buffer: PChar);
begin
  FreeMem(Buffer);
end;

procedure TMemDataset.InternalInitRecord(Buffer: PChar);

begin
 FillChar(Buffer^,FRecSize,0);
end;

procedure TMemDataset.InternalDelete;

Var
  TS : TMemoryStream;
  OldPos,NewPos,CopySize1,CopySize2 : Cardinal;

begin
  if (FCurrRecNo<0) or (FCurrRecNo>=FRecCount) then
    Exit;
  // Very inefficient. We should simply move the last part closer to the beginning in
  // The FStream.
  TS:=TMemoryStream.Create;
  Try
    if FCurrRecNo>0 then
      begin
      FStream.Position:=MDSGetRecordOffset(0);      //Delete Rec
      if FCurrRecNo<FRecCount-1 then
        begin
        TS.CopyFrom(FStream, MDSGetRecordOffset(FCurrRecNo)-MDSGetRecordOffset(0));
        FStream.Position:=MDSGetRecordOffset(FCurrRecNo+1);
        TS.CopyFrom(FStream,(MDSGetRecordOffset(FRecCount))-MDSGetRecordOffset(FCurrRecNo+1));
        end
      else
        TS.CopyFrom(FStream,MDSGetRecordOffset(FRecCount-1));
      end
    else
      begin                                  //Delete first Rec
      FStream.Position:=MDSGetRecordOffset(FCurrRecNo+1);
      TS.CopyFrom(FStream,(MDSGetRecordOffset(FRecCount))-MDSGetRecordOffset(FCurrRecNo+1));
      end;
    FStream.loadFromStream(TS);
    Dec(FRecCount);
    if FRecCount=0 then
      FCurrRecNo:=-1
    else
      if FCurrRecNo>=FRecCount then FCurrRecNo:=FRecCount-1;
  Finally
    TS.Free;
  end;
  FModified:=True;
end;

procedure TMemDataset.InternalInitFieldDefs;

begin
  If (FOpenStream<>Nil) then
    ReadFieldDefsFromStream(FOpenStream);
end;

Procedure TMemDataset.CheckMarker(F : TStream; Marker : Integer);

Var
  I,P : Integer;

begin
  P:=F.Position;
  If F.Read(I,MarkerSize)<>MarkerSize then
    RaiseError(SErrInvalidDataStream,[P])
  else
    if (I<>Marker) then
      RaiseError(SErrInvalidMarkerAtPos,[P,I,Marker]);
end;

procedure TMemDataset.ReadFieldDefsFromStream(F : TStream);

Var
  I,ACount : Integer;
  FN : String;
  FS : Integer;
  B : Boolean;
  FT : TFieldType;

begin
  CheckMarker(F,smFieldDefs);
  FieldDefs.Clear;
  ACount:=ReadInteger(F);
  For I:=1 to ACount do
    begin
    FN:=ReadString(F);
    FS:=ReadInteger(F);
    FT:=TFieldType(ReadInteger(F));
    B:=ReadInteger(F)<>0;
    TFieldDef.Create(FieldDefs,FN,ft,FS,B,I);
    end;
  CreateTable;
end;

procedure TMemDataset.InternalFirst;
begin
  FCurrRecNo:=-1;
end;

procedure TMemDataset.InternalLast;
begin
  FCurrRecNo:=FRecCount;
end;

procedure TMemDataset.InternalOpen;


begin
  If (FFileName<>'') then
    FOpenStream:=TFileStream.Create(FFileName,fmOpenRead);
  Try
    InternalInitFieldDefs;
    if DefaultFields then
      CreateFields;
    BindFields(True);
    FCurrRecNo:=-1;
    If (FOpenStream<>Nil) then
      begin
      LoadDataFromStream(FOpenStream);
      CheckMarker(FOpenStream,smEOF);
      end;
  Finally
    FreeAndNil(FOpenStream);
  end;
  FIsOpen:=True;
end;

Procedure TMemDataSet.LoadDataFromStream(F : TStream);

Var
  Size : Integer;

begin
  CheckMarker(F,smData);
  Size:=ReadInteger(F);
  FStream.Clear;
  FStream.CopyFrom(F,Size);
  FRecCount:=Size div FRecSize;
  FCurrRecNo:=-1;
end;

Procedure TMemDataSet.LoadFromStream(F : TStream);

begin
  Close;
  ReadFieldDefsFromStream(F);
  LoadDataFromStream(F);
  CheckMarker(F,smEOF);
  FModified:=False;
end;

Procedure TMemDataSet.LoadFromFile(AFileName : String);

Var
  F : TFileStream;

begin
  F:=TFileStream.Create(AFileName,fmOpenRead);
  Try
    LoadFromStream(F);
  Finally
    F.Free;
  end;
end;


Procedure TMemDataset.SaveToFile(AFileName : String);

begin
  SaveToFile(AFileName,True);
end;

Procedure TMemDataset.SaveToFile(AFileName : String; SaveData : Boolean);

Var
  F : TFileStream;

begin
  If (AFileName='') then
    RaiseError(SErrNoFileName,[]);
  F:=TFileStream.Create(AFileName,fmCreate);
  try
    SaveToStream(F,SaveData);
  Finally
    F.Free;
  end;
end;

Procedure TMemDataset.WriteMarker(F : TStream; Marker : Integer);

begin
  Writeinteger(F,Marker);
end;

Procedure TMemDataset.SaveToStream(F : TStream);

begin
  SaveToStream(F,True);
end;

Procedure TMemDataset.SaveToStream(F : TStream; SaveData : Boolean);

begin
  SaveFieldDefsToStream(F);
  If SaveData then
    SaveDataToStream(F,SaveData);
  WriteMarker(F,smEOF);
end;

Procedure TMemDataset.SaveFieldDefsToStream(F : TStream);

Var
  I,ACount : Integer;
  FN : String;
  FS : Integer;
  B : Boolean;
  FT : TFieldType;
  FD : TFieldDef;

begin
  WriteMarker(F,smFieldDefs);
  WriteInteger(F,FieldDefs.Count);
  For I:=1 to FieldDefs.Count do
    begin
    FD:=FieldDefs[I-1];
    WriteString(F,FD.Name);
    WriteInteger(F,FD.Size);
    WriteInteger(F,Ord(FD.DataType));
    WriteInteger(F,Ord(FD.Required));
    end;
end;

Procedure TMemDataset.SaveDataToStream(F : TStream; SaveData : Boolean);

begin
  if SaveData then
    begin
    WriteMarker(F,smData);
    WriteInteger(F,FStream.Size);
    FStream.Position:=0;
    F.CopyFrom(FStream,FStream.Size);
    FModified:=False;
    end
  else
    begin
    WriteMarker(F,smData);
    WriteInteger(F,0);
    end;
end;

procedure TMemDataset.InternalClose;

begin
  if (FModified) and (FFileName<>'') then
    SaveToFile(FFileName,True);
  FIsOpen:=False;
  FModified:=False;
  BindFields(False);
  if DefaultFields then
    DestroyFields;
end;

procedure TMemDataset.InternalPost;
begin
  CheckActive;
  if ((State<>dsEdit) and (State<>dsInsert)) then
    Exit;
  if (State=dsEdit) then
    MDSWriteRecord(ActiveBuffer, FCurrRecNo)
  else
    InternalAddRecord(ActiveBuffer,True);
end;

function TMemDataset.IsCursorOpen: Boolean;

begin
  Result:=FIsOpen;
end;

function TMemDataset.GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
var
  Accepted: Boolean;

begin
  Result:=grOk;
  Accepted:=False;
  if (FRecCount<1) then
    begin
    Result:=grEOF;
    exit;
    end;
  repeat
    case GetMode of
      gmCurrent:
        if (FCurrRecNo>=FRecCount) or (FCurrRecNo<0) then
          Result:=grError;
      gmNext:
        if (FCurrRecNo<FRecCount-1) then
          Inc(FCurrRecNo)
        else
          Result:=grEOF;
      gmPrior:
        if (FCurrRecNo>0) then
          Dec(FCurrRecNo)
        else
          result:=grBOF;
    end;
    if result=grOK then
      begin
      MDSReadRecord(Buffer, FCurrRecNo);
      MDSSetRecInfo( Buffer,bfCurrent,FCurrRecNo );

      if (Filtered) then
        Accepted:=MDSFilterRecord(Buffer) //Filtering
      else
        Accepted:=True;
      if (GetMode=gmCurrent) and not Accepted then
        result:=grError;
      end;
  until (result<>grOK) or Accepted;
end;

function TMemDataset.GetFieldData(Field: TField; Buffer: Pointer): Boolean;

var
  SrcBuffer: PChar;

begin
 result:=False;
 if not MDSGetActiveBuffer(SrcBuffer) then
   Exit;
 if (Field.FieldNo>0) and (Assigned(Buffer)) and (Assigned(SrcBuffer)) then
   begin
   Move((SrcBuffer+MDSGetFieldOffset(Field.FieldNo))^, Buffer^, MDSGetFieldSize(Field.FieldNo));
   result:=True;
   end;
end;

procedure TMemDataset.SetFieldData(Field: TField; Buffer: Pointer);

var
  DestBuffer: PChar;

begin
 MDSGetActiveBuffer(DestBuffer);
 if (Field.FieldNo>0) and (Assigned(Buffer)) and (Assigned(DestBuffer)) then
   Move(Buffer^,(DestBuffer+MDSGetFieldOffset(Field.FieldNo))^, MDSGetFieldSize(Field.FieldNo));
end;

function TMemDataset.GetRecordSize: Word;

begin
  Result:=FRecSize;
end;

procedure TMemDataset.InternalGotoBookmark(ABookmark: Pointer);

var
  ReqBookmark: integer;

begin
  ReqBookmark:=PInteger(ABookmark)^;
  if (ReqBookmark>=0) and (ReqBookmark<FRecCount) then
    FCurrRecNo:=ReqBookmark
  else
    RaiseError(SErrBookMarkNotFound,[ReqBookmark]);
end;

procedure TMemDataset.InternalSetToRecord(Buffer: PChar);

var
  ReqBookmark: integer;

begin
  ReqBookmark:=MDSGetRecInfo(Buffer).Bookmark;
  InternalGotoBookmark (@ReqBookmark);
end;

function TMemDataset.GetBookmarkFlag(Buffer: PChar): TBookmarkFlag;
begin
 Result:=MDSGetRecInfo(Buffer).BookmarkFlag;
end;

procedure TMemDataset.SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag);
begin
  MDSSetRecInfo(Buffer,Value);
end;

procedure TMemDataset.GetBookmarkData(Buffer: PChar; Data: Pointer);

begin
  if Data<>nil then
    PInteger(Data)^:=MDSGetRecInfo(Buffer).Bookmark;
end;

procedure TMemDataset.SetBookmarkData(Buffer: PChar; Data: Pointer);

begin
  if Data<>nil then
    MDSSetRecInfo(Buffer, PInteger(Data)^)
  else
    MDSSetRecInfo( Buffer, 0);
end;

function TMemDataset.MDSFilterRecord(Buffer: PChar): Boolean;

var
  SaveState: TDatasetState;

begin
  Result:=True;
  if not Assigned(OnFilterRecord) then
    Exit;
  SaveState:=SetTempState(dsFilter);
  FFilterBuffer:=Buffer;
  OnFilterRecord(Self,Result);
  RestoreState(SaveState);
end;

function  TMemDataset.MDSGetRecInfo(Buffer: PChar): TMTRecInfo;
begin
  Move(PRecInfo(Buffer+FRecInfoOffset)^,Result,FRecInfoSize);
end;

procedure TMemDataset.MDSSetRecInfo(Buffer: PChar;
                                    Flag: TBookmarkFlag);
begin
  Unaligned(PRecInfo(Buffer+FRecInfoOffset)^).BookmarkFlag := Flag;
end;

procedure TMemDataset.MDSSetRecInfo(Buffer: PChar;
                                    Flag: TBookmarkFlag;
                                    ABookmark: Longint);
var ARecInfo: TMTRecInfo;
begin
  Unaligned(PRecInfo(Buffer+FRecInfoOffset)^).Bookmark := ABookmark;
  Unaligned(PRecInfo(Buffer+FRecInfoOffset)^).BookmarkFlag := Flag;
end;

procedure TMemDataset.MDSSetRecInfo(Buffer: PChar;
                                    ABookmark: Longint);
var ARecInfo: TMTRecInfo;
begin
  Unaligned(PRecInfo(Buffer+FRecInfoOffset)^).BookmarkFlag := ABookmark;
end;

Function TMemDataset.DataSize : Integer;

begin
  Result:=FStream.Size;
end;

procedure TMemDataset.Clear;

begin
  Clear(True);
end;

procedure TMemDataset.Clear(ClearDefs : Boolean);

begin
  FStream.Clear;
  FRecCount:=0;
  FCurrRecNo:=-1;
  if Active then
    Resync([]);
  If ClearDefs then
    begin
    Close;
    FieldDefs.Clear;
    end;
end;

procedure TMemDataset.CreateTable;
var
  i, iSize : Longint;
begin
  FStream.Clear;
  FRecCount:=0;
  FCurrRecNo:=-1;
  FIsOpen:=False;
  iSize:=0;
  for I:=1 to FieldDefs.Count do begin
    FFieldOffsetList.Add(Pointer(iSize));
    iSize:=iSize+MDSGetFieldSize(I);
  end;
  FRecInfoOffset:=iSize;
  FRecSize:=iSize+FRecInfoSize;
  FRecBufferSize:=FRecSize;
end;

procedure TMemDataset.InternalAddRecord(Buffer: Pointer; DoAppend: Boolean);

begin
  MDSAppendRecord(ActiveBuffer);
  InternalLast;
  Inc(FRecCount);
end;

procedure TMemDataset.SetRecNo(Value: Integer);
begin
  CheckBrowseMode;
  if (Value>1) and (Value<=FRecCount) then
    begin
    FCurrRecNo:=Value-1;
    Resync([]);
    end;
end;

Function TMemDataset.GetRecNo: Longint;

begin
  UpdateCursorPos;
  if (FCurrRecNo<0) then
    Result:=1
  else
    Result:=FCurrRecNo+1;
end;

Function TMemDataset.GetRecordCount: Longint;

begin
  CheckActive;
  Result:=FRecCount;
end;

Procedure TMemDataset.CopyFromDataset(DataSet : TDataSet);

begin
  CopyFromDataset(Dataset,True);
end;

Procedure TMemDataset.CopyFromDataset(DataSet : TDataSet; CopyData : Boolean);

Var
  I, iDataSize : Integer;
  F,F1,F2 : TField;
  L1,L2  : TList;
  N : String;

begin
  Clear(True);
  // NOT from fielddefs. The data may not be available in buffers !!
  For I:=0 to Dataset.FieldCount-1 do
    begin
     F:=Dataset.Fields[I];
     if (F.DataType=ftString) and (F.Size=0)
     then iDataSize:=MEMDS_STRING_MAXSIZE
     else iDataSize:=F.Size;

     TFieldDef.Create(FieldDefs,F.FieldName,F.DataType,iDataSize,F.Required,F.FieldNo);
    end;
  CreateTable;
  If CopyData then
    begin
    Open;
    L1:=TList.Create;
    Try
      L2:=TList.Create;
      Try
        For I:=0 to FieldDefs.Count-1 do
          begin
          N:=FieldDefs[I].Name;
          F1:=FieldByName(N);
          F2:=DataSet.FieldByName(N);
          L1.Add(F1);
          L2.Add(F2);
          end;
        Dataset.DisableControls;
        Try
          Dataset.Open;
          While not Dataset.EOF do
            begin
            Append;
            For I:=0 to L1.Count-1 do
              begin
              F1:=TField(L1[i]);
              F2:=TField(L2[I]);
              Case F1.DataType of
                ftString   : F1.AsString:=F2.AsString;
                ftBoolean  : F1.AsBoolean:=F2.AsBoolean;
                ftFloat    : F1.AsFloat:=F2.AsFloat;
                ftLargeInt : F1.AsInteger:=F2.AsInteger;
                ftSmallInt : F1.AsInteger:=F2.AsInteger;
                ftInteger  : F1.AsInteger:=F2.AsInteger;
                ftDate     : F1.AsDateTime:=F2.AsDateTime;
                ftTime     : F1.AsDateTime:=F2.AsDateTime;
              end;
              end;
            Try
              Post;
            except
              Cancel;
              Raise;
            end;
            Dataset.Next;
            end;
        Finally
          Dataset.EnableControls;
        end;
      finally
        L2.Free;
      end;
    finally
      l1.Free;
    end;
    end;
end;

end.
