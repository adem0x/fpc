{
    This file is part of the Free Component Library

    XML utility routines.
    Copyright (c) 2006 by Sergei Gorelkin, sergei_gorelkin@mail.ru

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit xmlutils;

{$ifdef fpc}
{$MODE objfpc}{$H+}
{$endif}

interface

uses
  SysUtils;

 {$IFNDEF FPC}

type   ptrint=integer;
{$ENDIF} 

function IsXmlName(const Value: WideString; Xml11: Boolean = False): Boolean; overload;
function IsXmlName(Value: PWideChar; Len: Integer; Xml11: Boolean = False): Boolean; overload;
function IsXmlNames(const Value: WideString; Xml11: Boolean = False): Boolean;
function IsXmlNmToken(const Value: WideString; Xml11: Boolean = False): Boolean;
function IsXmlNmTokens(const Value: WideString; Xml11: Boolean = False): Boolean;
function IsValidXmlEncoding(const Value: WideString): Boolean;
function Xml11NamePages: PByteArray;
procedure NormalizeSpaces(var Value: WideString);
function IsXmlWhiteSpace(c: WideChar): Boolean;
function Hash(InitValue: LongWord; Key: PWideChar; KeyLen: Integer): LongWord;
{ beware, works in ASCII range only }
function WStrLIComp(S1, S2: PWideChar; Len: Integer): Integer;

{ a simple hash table with WideString keys }

type
  PTabPHashItem = ^TTabPHashItem;
  PPHashItem = ^PHashItem;
  PHashItem = ^THashItem;
  THashItem = record
    Key: WideString;
    HashValue: LongWord;
    Next: PHashItem;
    Data: TObject;
  end;
  TTabPHashItem = array[0..0] of pHashItem;

  THashForEach = function(Entry: PHashItem; arg: Pointer): Boolean;

  THashTable = class(TObject)
  private
    FCount: LongWord;
    FBucketCount: LongWord;
    FBucket: PTabPHashItem;
    FOwnsObjects: Boolean;
    function Lookup(Key: PWideChar; KeyLength: Integer; var Found: Boolean; CanCreate: Boolean): PHashItem;
    procedure Resize(NewCapacity: LongWord);
  public
    constructor Create(InitSize: Integer; OwnObjects: Boolean);
    destructor Destroy; override;
    procedure Clear;
    function Find(Key: PWideChar; KeyLen: Integer): PHashItem;
    function FindOrAdd(Key: PWideChar; KeyLen: Integer; var Found: Boolean): PHashItem; overload;
    function FindOrAdd(Key: PWideChar; KeyLen: Integer): PHashItem; overload;
    function Get(Key: PWideChar; KeyLen: Integer): TObject;
    function Remove(Entry: PHashItem): Boolean;
    function RemoveData(aData: TObject): Boolean;
    procedure ForEach(proc: THashForEach; arg: Pointer);
    property Count: LongWord read FCount;
  end;

{ another hash, for detecting duplicate namespaced attributes without memory allocations }

  PWideString = ^WideString;
  PExpHashEntry = ^TExpHashEntry;
  TExpHashEntry = record
    rev: LongWord;
    hash: LongWord;
    uriPtr: PWideString;
    lname: PWideChar;
    lnameLen: Integer;
  end;
  PTabExpHashEntry = ^TTabExpHashEntry;
  tTabExpHashEntry = array[0..0] of   TExpHashEntry;


  TDblHashArray = class(TObject)
  private
    FSizeLog: Integer;
    FRevision: LongWord;
    FData: PTabExpHashEntry;
  public  
    procedure Init(NumSlots: Integer);
    function Locate(uri: PWideString; localName: PWideChar; localLength: Integer): Boolean;
    destructor Destroy; override;
  end;

{$i names.inc}

implementation

var
  Xml11Pg: PByteArray = nil;

function Xml11NamePages: PByteArray;
var
  I: Integer;
  p: PByteArray;
begin
  if Xml11Pg = nil then
  begin
    GetMem(p, 512);
    for I := 0 to 255 do
      p^[I] := ord(Byte(I) in Xml11HighPages);
    p^[0] := 2;
    p^[3] := $2c;
    p^[$20] := $2a;
    p^[$21] := $2b;
    p^[$2f] := $29;
    p^[$30] := $2d;
    p^[$fd] := $28;
    p^[$ff] := $30;

    Move(p^, p^[256], 256);
    p^[$100] := $19;
    p^[$103] := $2E;
    p^[$120] := $2F;
    Xml11Pg := p;
  end;
  Result := Xml11Pg;
end;

function IsXml11Char(Value: PWideChar; var Index: Integer): Boolean; overload;
begin
  if (Value[Index] >= #$D800) and (Value[Index] <= #$DB7F) then
  begin
    Inc(Index);
    Result := (Value[Index] >= #$DC00) and (Value[Index] <= #$DFFF);
  end
  else
    Result := False;
end;

function IsXml11Char(const Value: WideString; var Index: Integer): Boolean; overload;
begin
  if (Value[Index] >= #$D800) and (Value[Index] <= #$DB7F) then
  begin
    Inc(Index);
    Result := (Value[Index] >= #$DC00) and (Value[Index] <= #$DFFF);
  end
  else
    Result := False;
end;

function IsXmlName(const Value: WideString; Xml11: Boolean): Boolean;
begin
  Result := IsXmlName(PWideChar(Value), Length(Value), Xml11);
end;

function IsXmlName(Value: PWideChar; Len: Integer; Xml11: Boolean = False): Boolean; overload;
var
  Pages: PByteArray;
  I: Integer;
begin
  Result := False;
  if Xml11 then
    Pages := Xml11NamePages
  else
    Pages := @NamePages;

  I := 0;
  if (Len = 0) or not ((Byte(Value[I]) in NamingBitmap[Pages^[hi(Word(Value[I]))]]) or
    (Value[I] = ':') or
    (Xml11 and IsXml11Char(Value, I))) then
      Exit;
  Inc(I);
  while I < Len do
  begin
    if not ((Byte(Value[I]) in NamingBitmap[Pages^[$100+hi(Word(Value[I]))]]) or
      (Value[I] = ':') or
      (Xml11 and IsXml11Char(Value, I))) then
        Exit;
    Inc(I);
  end;
  Result := True;
end;

function IsXmlNames(const Value: WideString; Xml11: Boolean): Boolean;
var
  Pages: PByteArray;
  I: Integer;
  Offset: Integer;
begin
  if Xml11 then
    Pages := Xml11NamePages
  else
    Pages := @NamePages;
  Result := False;
  if Value = '' then
    Exit;
  I := 1;
  Offset := 0;
  while I <= Length(Value) do
  begin
    if not ((Byte(Value[I]) in NamingBitmap[Pages^[Offset+hi(Word(Value[I]))]]) or
      (Value[I] = ':') or
      (Xml11 and IsXml11Char(Value, I))) then
    begin
      if (I = Length(Value)) or (Value[I] <> #32) then
        Exit;
      Offset := 0;
      Inc(I);
      Continue;
    end;
    Offset := $100;
    Inc(I);
  end;
  Result := True;
end;

function IsXmlNmToken(const Value: WideString; Xml11: Boolean): Boolean;
var
  I: Integer;
  Pages: PByteArray;
begin
  if Xml11 then
    Pages := Xml11NamePages
  else
    Pages := @NamePages;
  Result := False;
  if Value = '' then
    Exit;
  I := 1;
  while I <= Length(Value) do
  begin
    if not ((Byte(Value[I]) in NamingBitmap[Pages^[$100+hi(Word(Value[I]))]]) or
      (Value[I] = ':') or
      (Xml11 and IsXml11Char(Value, I))) then
        Exit;
    Inc(I);
  end;
  Result := True;
end;

function IsXmlNmTokens(const Value: WideString; Xml11: Boolean): Boolean;
var
  I: Integer;
  Pages: PByteArray;
begin
  if Xml11 then
    Pages := Xml11NamePages
  else
    Pages := @NamePages;
  I := 1;
  Result := False;
  if Value = '' then
    Exit;
  while I <= Length(Value) do
  begin
    if not ((Byte(Value[I]) in NamingBitmap[Pages^[$100+hi(Word(Value[I]))]]) or
      (Value[I] = ':') or
      (Xml11 and IsXml11Char(Value, I))) then
    begin
      if (I = Length(Value)) or (Value[I] <> #32) then
        Exit;
    end;
    Inc(I);
  end;
  Result := True;
end;

function IsValidXmlEncoding(const Value: WideString): Boolean;
var
  I: Integer;
begin
  Result := False;
  if (Value = '') or (Value[1] > #255) or not (char(ord(Value[1])) in ['A'..'Z', 'a'..'z']) then
    Exit;
  for I := 2 to Length(Value) do
    if (Value[I] > #255) or not (char(ord(Value[I])) in ['A'..'Z', 'a'..'z', '0'..'9', '.', '_', '-']) then
      Exit;
  Result := True;
end;

procedure NormalizeSpaces(var Value: WideString);
var
  I, J: Integer;
begin
  I := Length(Value);
  // speed: trim only whed needed
  if (I > 0) and ((Value[1] = #32) or (Value[I] = #32)) then
    Value := Trim(Value);
  I := 1;
  while I < Length(Value) do
  begin
    if Value[I] = #32 then
    begin
      J := I+1;
      while (J <= Length(Value)) and (Value[J] = #32) do Inc(J);
      if J-I > 1 then Delete(Value, I+1, J-I-1);
    end;
    Inc(I);
  end;
end;

function IsXmlWhiteSpace(c: WideChar): Boolean;
begin
  Result := (c = #32) or (c = #9) or (c = #10) or (c = #13);
end;

function WStrLIComp(S1, S2: PWideChar; Len: Integer): Integer;
var
  counter: Integer;
  c1, c2: Word;
begin
  counter := 0;
  result := 0;
  if Len = 0 then
    exit;
  repeat
    c1 := ord(S1[counter]);
    c2 := ord(S2[counter]);
    if (c1 = 0) or (c2 = 0) then break;
    if c1 <> c2 then
    begin
      if c1 in [97..122] then
        Dec(c1, 32);
      if c2 in [97..122] then
        Dec(c2, 32);
      if c1 <> c2 then
        Break;
    end;
    Inc(counter);
  until counter >= Len;
  result := c1 - c2;
end;

function Hash(InitValue: LongWord; Key: PWideChar; KeyLen: Integer): LongWord;
begin
  Result := InitValue;
  while KeyLen <> 0 do
  begin
    Result := Result * $F4243 xor ord(Key^);
    Inc(Key);
    Dec(KeyLen);
  end;
end;

function KeyCompare(const Key1: WideString; Key2: Pointer; Key2Len: Integer): Boolean;
begin
  {$IFDEF FPC}
  Result := (Length(Key1)=Key2Len) and (CompareWord(Pointer(Key1)^, Key2^, Key2Len) = 0);
  {$ELSE}
  Result := comparemem(Pointer(Key1),key2,key2len*2);
  {$ENDIF}
end;

{ THashTable }

constructor THashTable.Create(InitSize: Integer; OwnObjects: Boolean);
var
  I: Integer;
begin
  inherited Create;
  FOwnsObjects := OwnObjects;
  I := 256;
  while I < InitSize do I := I shl 1;
  FBucketCount := I;
  FBucket := AllocMem(I * sizeof(PHashItem));
end;

destructor THashTable.Destroy;
begin
  Clear;
  FreeMem(FBucket);
  inherited Destroy;
end;

procedure THashTable.Clear;
var
  I: Integer;
  item, next: PHashItem;
begin
  for I := 0 to FBucketCount-1 do
  begin
    item := FBucket[I];
    while Assigned(item) do
    begin
      next := item^.Next;
      if FOwnsObjects then
        item^.Data.Free;
      Dispose(item);
      item := next;
    end;
  end;
  FillChar(FBucket^, FBucketCount * sizeof(PHashItem), 0);
end;

function THashTable.Find(Key: PWideChar; KeyLen: Integer): PHashItem;
var
  Dummy: Boolean;
begin
  Result := Lookup(Key, KeyLen, Dummy, False);
end;

function THashTable.FindOrAdd(Key: PWideChar; KeyLen: Integer;
  var Found: Boolean): PHashItem;
begin
  Result := Lookup(Key, KeyLen, Found, True);
end;

function THashTable.FindOrAdd(Key: PWideChar; KeyLen: Integer): PHashItem;
var
  Dummy: Boolean;
begin
  Result := Lookup(Key, KeyLen, Dummy, True);
end;

function THashTable.Get(Key: PWideChar; KeyLen: Integer): TObject;
var
  e: PHashItem;
  Dummy: Boolean;
begin
  e := Lookup(Key, KeyLen, Dummy, False);
  if Assigned(e) then
    Result := e^.Data
  else
    Result := nil;  
end;

function THashTable.Lookup(Key: PWideChar; KeyLength: Integer;
  var Found: Boolean; CanCreate: Boolean): PHashItem;
var
  Entry: PPHashItem;
  h: LongWord;
begin
  h := Hash(0, Key, KeyLength);
  Entry := @FBucket[h mod FBucketCount];
  while Assigned(Entry^) and not ((Entry^^.HashValue = h) and KeyCompare(Entry^^.Key, Key, KeyLength) ) do
    Entry := @Entry^^.Next;
  Found := Assigned(Entry^);
  if Found or (not CanCreate) then
  begin
    Result := Entry^;
    Exit;
  end;
  if FCount > FBucketCount then  { arbitrary limit, probably too high }
  begin
    Resize(FBucketCount * 2);
    Result := Lookup(Key, KeyLength, Found, CanCreate);
  end
  else
  begin
    New(Result);
    // SetString for WideStrings trims on zero chars
    // need to investigate and report
    SetLength(Result^.Key, KeyLength);
    Move(Key^, Pointer(Result^.Key)^, KeyLength*sizeof(WideChar));
    Result^.HashValue := h;
    Result^.Data := nil;
    Result^.Next := nil;
    Inc(FCount);
    Entry^ := Result;
  end;
end;

procedure THashTable.Resize(NewCapacity: LongWord);
var
  p    : PTabPHashItem;
  chain: PPHashItem;
  i: Integer;
  e, n: PHashItem;
begin
  p := AllocMem(NewCapacity * sizeof(PHashItem));
  for i := 0 to FBucketCount-1 do
  begin
    e := FBucket[i];
    while Assigned(e) do
    begin
      chain := @p[e^.HashValue mod NewCapacity];
      n := e^.Next;
      e^.Next := chain^;
      chain^ := e;
      e := n;
    end;
  end;
  FBucketCount := NewCapacity;
  FreeMem(FBucket);
  FBucket := p;
end;

function THashTable.Remove(Entry: PHashItem): Boolean;
var
  chain: PPHashItem;
begin
  chain := @FBucket[Entry^.HashValue mod FBucketCount];
  while Assigned(chain^) do
  begin
    if chain^ = Entry then
    begin
      chain^ := Entry^.Next;
      if FOwnsObjects then
        Entry^.Data.Free;
      Dispose(Entry);
      Dec(FCount);
      Result := True;
      Exit;
    end;
    chain := @chain^^.Next;
  end;
  Result := False;
end;

// this does not free the aData object
function THashTable.RemoveData(aData: TObject): Boolean;
var
  i: Integer;
  chain: PPHashItem;
  e: PHashItem;
begin
  for i := 0 to FBucketCount-1 do
  begin
    chain := @FBucket[i];
    while Assigned(chain^) do
    begin
      if chain^^.Data = aData then
      begin
        e := chain^;
        chain^ := e^.Next;
        Dispose(e);
        Dec(FCount);
        Result := True;
        Exit;
      end;
      chain := @chain^^.Next;
    end;
  end;
  Result := False;
end;

procedure THashTable.ForEach(proc: THashForEach; arg: Pointer);
var
  i: Integer;
  e: PHashItem;
begin
  for i := 0 to FBucketCount-1 do
  begin
    e := FBucket[i];
    while Assigned(e) do
    begin
      if not proc(e, arg) then
        Exit;
      e := e^.Next;
    end;
  end;
end;

{ TDblHashArray }

destructor TDblHashArray.Destroy;
begin
  FreeMem(FData);
  inherited Destroy;
end;

procedure TDblHashArray.Init(NumSlots: Integer);
var
  i: Integer;
begin
  if ((NumSlots * 2) shr FSizeLog) <> 0 then   // need at least twice more entries, and no less than 8
  begin
    FSizeLog := 3;
    while (NumSlots shr FSizeLog) <> 0 do
      Inc(FSizeLog);
    ReallocMem(FData, (1 shl FSizeLog) * sizeof(TExpHashEntry));
    FRevision := 0;
  end;
  if FRevision = 0 then
  begin
    FRevision := $FFFFFFFF;
    for i := (1 shl FSizeLog)-1 downto 0 do
      FData[i].rev := FRevision;
  end;
  Dec(FRevision);
end;

function TDblHashArray.Locate(uri: PWideString; localName: PWideChar; localLength: Integer): Boolean;
var
  step: Byte;
  mask: LongWord;
  idx: Integer;
  HashValue: LongWord;
begin
  HashValue := Hash(0, PWideChar(uri^), Length(uri^));
  HashValue := Hash(HashValue, localName, localLength);

  mask := (1 shl FSizeLog) - 1;
  step := (HashValue and (not mask)) shr (FSizeLog-1) and (mask shr 2) or 1;
  idx := HashValue and mask;
  result := True;
  while FData[idx].rev = FRevision do
  begin
    if (HashValue = FData[idx].hash) and (FData[idx].uriPtr^ = uri^) and
      (FData[idx].lnameLen = localLength) and
       CompareMem(FData[idx].lname, localName, localLength * sizeof(WideChar)) then
      Exit;
    if idx < step then
      Inc(idx, (1 shl FSizeLog) - step)
    else
      Dec(idx, step);
  end;
  with FData[idx] do
  begin
    rev := FRevision;
    hash := HashValue;
    uriPtr := uri;
    lname := localName;
    lnameLen := localLength;
  end;
  result := False;
end;

initialization

finalization
  if Assigned(Xml11Pg) then
    FreeMem(Xml11Pg);

end.
