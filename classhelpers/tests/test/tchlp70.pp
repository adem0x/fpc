{ %FAIL }

{ a helper can not extend unspecialized generics }
program tchlp70;

{$ifdef fpc}
  {$mode delphi}
{$endif}
{$apptype console}

type
  TFoo<T> = class
    Field: T;
  end;

  TFooHelper = class helper for TFoo<T>
  end;

begin

end.
