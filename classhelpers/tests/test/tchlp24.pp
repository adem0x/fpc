{ %FAIL }

{ class helpers may not be referenced in any way - test 7 }
program tchlp24;

{$ifdef fpc}
  {$mode objfpc}
{$endif}

type
  TObjectHelper = class helper for TObject
  end;

  TObjectHelperSub = class(TObjectHelper)
  end;

begin
end.

