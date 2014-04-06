{ %cpu=i8086 }

{ far pointer arithmetic tests }

{ far pointer arithmetic should work only on the offset,
  without changing the segment }

{$R-}

var
  ErrorCode: Integer;

procedure Error(Code: Integer);
begin
  Writeln('Error: ', code);
  ErrorCode := Code;
end;

var
  FarPtr: FarPointer;
  FarPtr2: FarPointer;
  int16: Integer;
  int32: LongInt;
begin
  ErrorCode := 0;

  Writeln('farptr + int16_var');
  FarPtr := Ptr($1234, $5678);
  int16 := $F0AD;
  FarPtr2 := nil;
  FarPtr2 := FarPtr + int16;
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(1);
  Writeln('int16_var + farptr');
  FarPtr := Ptr($1234, $5678);
  int16 := $F0AD;
  FarPtr2 := nil;
  FarPtr2 := int16 + FarPtr;
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(2);
  Writeln('farptr + int32_var');
  FarPtr := Ptr($1234, $5678);
  int32 := $55AAF0AD;
  FarPtr2 := nil;
  FarPtr2 := FarPtr + int32;
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(3);
  Writeln('int32_var + farptr');
  FarPtr := Ptr($1234, $5678);
  int32 := $55AAF0AD;
  FarPtr2 := nil;
  FarPtr2 := int32 + FarPtr;
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(4);
  Writeln('farptr + int16_const');
  FarPtr := Ptr($1234, $5678);
  FarPtr2 := nil;
  FarPtr2 := FarPtr + $F0AD;
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(5);
  Writeln('int16_const + farptr');
  FarPtr := Ptr($1234, $5678);
  FarPtr2 := nil;
  FarPtr2 := $F0AD + FarPtr;
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(6);
  Writeln('farptr + int32_const');
  FarPtr := Ptr($1234, $5678);
  FarPtr2 := nil;
  FarPtr2 := FarPtr + $55AAF0AD;
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(7);
  Writeln('int32_const + farptr');
  FarPtr := Ptr($1234, $5678);
  FarPtr2 := nil;
  FarPtr2 := $55AAF0AD + FarPtr;
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(8);
  { const }
  Writeln('farptr_const + int16_var');
  int16 := $F0AD;
  FarPtr2 := nil;
  FarPtr2 := FarPointer($12345678) + int16;
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(9);
  Writeln('int16_var + farptr_const');
  int16 := $F0AD;
  FarPtr2 := nil;
  FarPtr2 := int16 + FarPointer($12345678);
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(10);
  Writeln('farptr_const + int32_var');
  int32 := $55AAF0AD;
  FarPtr2 := nil;
  FarPtr2 := FarPointer($12345678) + int32;
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(11);
  Writeln('int32_var + farptr_const');
  int32 := $55AAF0AD;
  FarPtr2 := nil;
  FarPtr2 := int32 + FarPointer($12345678);
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(12);
  Writeln('farptr_const + int16_const');
  FarPtr2 := nil;
  FarPtr2 := FarPointer($12345678) + $F0AD;
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(13);
  Writeln('int16_const + farptr_const');
  FarPtr2 := nil;
  FarPtr2 := $F0AD + FarPointer($12345678);
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(14);
  Writeln('farptr_const + int32_const');
  FarPtr2 := nil;
  FarPtr2 := FarPointer($12345678) + $55AAF0AD;
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(15);
  Writeln('int32_const + farptr_const');
  FarPtr2 := nil;
  FarPtr2 := $55AAF0AD + FarPointer($12345678);
  if FarPtr2 <> Ptr($1234, $4725) then
    Error(16);

  Writeln('farptr - int16_var');
  FarPtr := Ptr($1234, $5678);
  int16 := $F0AD;
  FarPtr2 := nil;
  FarPtr2 := FarPtr - int16;
  if FarPtr2 <> Ptr($1234, $65CB) then
    Error(17);
  Writeln('farptr - int32_var');
  FarPtr := Ptr($1234, $5678);
  int32 := $55AAF0AD;
  FarPtr2 := nil;
  FarPtr2 := FarPtr - int32;
  if FarPtr2 <> Ptr($1234, $65CB) then
    Error(18);
  Writeln('farptr - int16_const');
  FarPtr := Ptr($1234, $5678);
  FarPtr2 := nil;
  FarPtr2 := FarPtr - $F0AD;
  if FarPtr2 <> Ptr($1234, $65CB) then
    Error(19);
  Writeln('farptr - int32_const');
  FarPtr := Ptr($1234, $5678);
  FarPtr2 := nil;
  FarPtr2 := FarPtr - $55AAF0AD;
  if FarPtr2 <> Ptr($1234, $65CB) then
    Error(20);
  Writeln('farptr_const - int16_var');
  int16 := $F0AD;
  FarPtr2 := nil;
  FarPtr2 := FarPointer($12345678) - int16;
  if FarPtr2 <> Ptr($1234, $65CB) then
    Error(21);
  Writeln('farptr_const - int32_var');
  int32 := $55AAF0AD;
  FarPtr2 := nil;
  FarPtr2 := FarPointer($12345678) - int32;
  if FarPtr2 <> Ptr($1234, $65CB) then
    Error(22);
  Writeln('farptr_const - int16_const');
  FarPtr2 := nil;
  FarPtr2 := FarPointer($12345678) - $F0AD;
  if FarPtr2 <> Ptr($1234, $65CB) then
    Error(23);
  Writeln('farptr_const - int32_const');
  FarPtr2 := nil;
  FarPtr2 := FarPointer($12345678) - $55AAF0AD;
  if FarPtr2 <> Ptr($1234, $65CB) then
    Error(24);

  if ErrorCode = 0 then
    Writeln('Success!')
  else
    Halt(ErrorCode);
end.
