{ %RESULT=217 }

{$MODE objfpc}
{$H+}
program stackcrash;
uses
  sysutils;

type
  TMyClass = class
  public
    procedure Proc1;
    procedure Proc2;
  end;

procedure TMyClass.Proc1;
var
  x, y: Integer;
begin
  try
    exit;
  except
    on e: Exception do begin e.Message := '[Proc1]' + e.Message; raise e end;
  end;
end;

procedure TMyClass.Proc2;
var
  x: array[0..7] of Byte;
  crash: Boolean;
begin
  crash := True;        // <--- ! This corrupts the stack?!?
  raise Exception.Create('I will crash now...');
end;

var
  obj: TMyClass;
begin
  obj := TMyClass.Create;
  obj.Proc1;
  WriteLn('Proc1 done, calling Proc2...');
  obj.Proc2;
  WriteLn('Proc2 done');
end.
