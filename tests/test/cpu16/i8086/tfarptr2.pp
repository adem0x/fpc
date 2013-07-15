{ %cpu=i8086 }

{ far pointer equality (=, <>) comparison tests }

{ = and <> should compare *both* the segment and the offset }
{ >, <, >= and <= should compare only the offset }

var
  ErrorCode: Integer;

procedure Error(Code: Integer);
begin
  Writeln('Error: ', code);
  ErrorCode := Code;
end;

type
  TFarPtrRec = packed record
    offset: Word;
    segment: Word;
  end;

var
  FarPtr: FarPointer;
  FarPtr2: FarPointer;
  FarPtrRec: TFarPtrRec absolute FarPtr;
  eq, neq: Boolean;
begin
  ErrorCode := 0;

  Writeln('var, var');
  FarPtr := Ptr($1234, $5678);
  FarPtr2 := Ptr($1234, $5678);
  eq := FarPtr = FarPtr2;
  neq := FarPtr <> FarPtr2;
  if not eq or neq then
    Error(1);

  FarPtr := Ptr($1234, $5678);
  FarPtr2 := Ptr($4321, $5678);
  eq := FarPtr = FarPtr2;
  neq := FarPtr <> FarPtr2;
  if eq or not neq then
    Error(2);

  FarPtr := Ptr($1234, $5678);
  FarPtr2 := Ptr($1234, $8765);
  eq := FarPtr = FarPtr2;
  neq := FarPtr <> FarPtr2;
  if eq or not neq then
    Error(3);

  FarPtr := Ptr($1234, $5678);
  FarPtr2 := Ptr($4321, $8765);
  eq := FarPtr = FarPtr2;
  neq := FarPtr <> FarPtr2;
  if eq or not neq then
    Error(4);

  Writeln('var, ptr(const)');
  FarPtr := Ptr($1234, $5678);
  eq := FarPtr = Ptr($1234, $5678);
  neq := FarPtr <> Ptr($1234, $5678);
  if not eq or neq then
    Error(1);

  FarPtr := Ptr($1234, $5678);
  eq := FarPtr = Ptr($4321, $5678);
  neq := FarPtr <> Ptr($4321, $5678);
  if eq or not neq then
    Error(2);

  FarPtr := Ptr($1234, $5678);
  eq := FarPtr = Ptr($1234, $8765);
  neq := FarPtr <> Ptr($1234, $8765);
  if eq or not neq then
    Error(3);

  FarPtr := Ptr($1234, $5678);
  eq := FarPtr = Ptr($4321, $8765);
  neq := FarPtr <> Ptr($4321, $8765);
  if eq or not neq then
    Error(4);

  Writeln('ptr(const), ptr(const)');
  eq := Ptr($1234, $5678) = Ptr($1234, $5678);
  neq := Ptr($1234, $5678) <> Ptr($1234, $5678);
  if not eq or neq then
    Error(1);

  eq := Ptr($1234, $5678) = Ptr($4321, $5678);
  neq := Ptr($1234, $5678) <> Ptr($4321, $5678);
  if eq or not neq then
    Error(2);

  eq := Ptr($1234, $5678) = Ptr($1234, $8765);
  neq := Ptr($1234, $5678) <> Ptr($1234, $8765);
  if eq or not neq then
    Error(3);

  eq := Ptr($1234, $5678) = Ptr($4321, $8765);
  neq := Ptr($1234, $5678) <> Ptr($4321, $8765);
  if eq or not neq then
    Error(4);

  if ErrorCode = 0 then
    Writeln('Success!')
  else
    Halt(ErrorCode);
end.
