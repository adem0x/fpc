{$mode objfpc}{$H+}

type
  generic TGListItem<T> = class(TObject)
  public var
    FValue: T;
    FNext: specialize TGListItem<T>;
    procedure SetValue(Value: T);
    function GetValue: T;
    procedure Assign(Source: specialize TGListItem<T>);
    function Merge(Other: specialize TGListItem<T>): specialize TGListItem<T>;
  end;

procedure TGListItem<T>.SetValue(Value: T);
begin
  FValue := Value;
end;

function TGListItem<T>.GetValue: T;
begin
  Result := FValue;
end;

procedure TGListItem<T>.Assign(Source: specialize TGListItem<T>);
begin
  FNext := Source;
end;

function TGListItem<T>.Merge(Other: specialize TGListItem<T>): specialize TGListItem<T>;
var
  Temp: specialize TGListItem<T>;
begin
  Temp := specialize TGListItem<T>.Create;
  Temp.SetValue(FNext.GetValue + Other.FNext.GetValue);
  Result := Temp;
end;

type
  TIntListItem = specialize TGListItem<Integer>;

var
  A, A2, B, B2: TIntListItem;
begin
  A := TIntListItem.Create;
  A2 := TIntListItem.Create;
  A.Assign(A2);
  if A.FNext <> A2 then
    halt(1);

  B := TIntListItem.Create;
  B2 := TIntListItem.Create;
  B.Assign(B2);
  if B.FNext <> B2 then
    halt(1);
  
  A2.SetValue(5);
  if A2.GetValue <> 5 then
    halt(1);
  
  B2.SetValue(7);
  if B2.GetValue <> 7 then
    halt(1);
  
  if A.Merge(B).GetValue <> 12 then
    halt(1);
end.
