{%FAIL}
program tgeneric97;

{$IFDEF FPC}
  {$MODE delphi}
{$ENDIF}

type
  TTest<TA, TB> = class(TObject)
  public
    procedure Test();
  end;

{ TTest<TA,TB> }

procedure TTest<TA, TB>.Test();
var
  A: TA;
  B: TB;
begin
  A := B; // Since the types TA and TB are not known this assignment should fail
end;

begin
end.

