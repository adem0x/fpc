program terecs3;

{$mode delphi}
{$apptype console}

uses
  terecs_u1;

var
  F: TFoo;
begin
  F.F3 := 0;
  F.F4 := 1;
  if F.F3 <> 0 then
    halt(1);
  if F.F4 <> 1 then
    halt(2);
  if F.C <> 1 then
    halt(3);
  WriteLn('ok');
end.