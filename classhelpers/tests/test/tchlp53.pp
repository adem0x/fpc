{ %NORUN } { or fail? }

program tchlp53;

{$ifdef fpc}
  {$mode objfpc}
{$endif}

type
  TFoo = class
    procedure Test; virtual;
  end;

  TFooHelper = class helper for TFoo
    procedure Test; virtual;
  end;

  TFooSubHelper = class helper(TFooHelper) for TFoo
    procedure Test; override;
  end;

procedure TFoo.Test;
begin

end;

procedure TFooHelper.Test;
begin

end;

procedure TFooSubHelper.Test;
begin

end;

begin

end.
