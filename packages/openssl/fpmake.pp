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

    P:=AddPackage('openssl');
{$ifdef ALLPACKAGES}
    P.Directory:=ADirectory;
{$endif ALLPACKAGES}
    P.Version:='2.7.1';
    P.SourcePath.Add('src');
    P.OSes := AllUnixOSes+AllWindowsOSes-[qnx];
//    P.Dependencies.Add('x11');

    T:=P.Targets.AddUnit('openssl.pas');
    T:=P.Targets.AddUnit('fpopenssl.pp');

    P.ExamplePath.Add('examples');
    P.Targets.AddExampleProgram('test1.pas');

{$ifndef ALLPACKAGES}
    Run;
    end;
end.
{$endif ALLPACKAGES}
