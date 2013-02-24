{$ifndef ALLPACKAGES}
{$mode objfpc}{$H+}
program fpmake;

uses fpmkunit;

Var
  P : TPackage;
  T : TTarget;
begin
  With Installer do
    begin
{$endif ALLPACKAGES}

    P:=AddPackage('newt');
{$ifdef ALLPACKAGES}
    P.Directory:='newt';
{$endif ALLPACKAGES}
    P.Version:='2.6.3';
    P.SourcePath.Add('src');
    P.OSes:=[Linux];

    T:=P.Targets.AddUnit('newt.pp');

    P.ExamplePath.Add('examples');
    P.Targets.AddExampleProgram('newt3.pas');
    P.Targets.AddExampleProgram('newt2.pas');
    P.Targets.AddExampleProgram('newt1.pas');

{$ifndef ALLPACKAGES}
    Run;
    end;
end.
{$endif ALLPACKAGES}
