{ %target=darwin }
{ %cpu=powerpc,i386 }

{$mode objfpc}
{$modeswitch objectivec1}

type
  MyOverride = objcclass(NSObject)
    procedure release; override;
    class procedure testClassOverride; message 'testClassOverride';
  end;

  MyOverride2 = objcclass(MyOverride)
    procedure release; override;
    class procedure testClassOverride; override;
  end;

var
  overridescalled: longint;

procedure MyOverride.release;
begin
  writeln('releasing override!');
  if (overridescalled<>3) then
    halt(1);
  inc(overridescalled);
  inherited release;
end;

class procedure MyOverride.testClassOverride;
begin
  writeln('MyOverride.testClassOverride');
  if (overridescalled<>1) then
    halt(3);
  inc(overridescalled);
end;

procedure MyOverride2.release;
begin
  inherited testClassOverride;
  writeln('releasing override2!');
  if (overridescalled<>2) then
    halt(2);
  inc(overridescalled);
  inherited release;
end;

class procedure MyOverride2.testClassOverride;
begin
  if (overridescalled<>0) then
    halt(5);
  writeln('MyOverride2.testClassOverride');
  inc(overridescalled);
  inherited testClassOverride;
end;

var
  a: MyOverride;
begin
  a:=MyOverride2.alloc;
  a:=a.init;
  MyOverride2.testClassOverride;
  if (overridescalled<>2) then
    halt(6);
  dec(overridescalled);
  MyOverride.testClassOverride;
  if (overridescalled<>2) then
    halt(7);
  overridescalled:=0;
  a.testClassOverride;
  overridescalled:=1;
  a.release;
end.
