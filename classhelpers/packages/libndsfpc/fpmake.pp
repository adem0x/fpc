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

    P:=AddPackage('libndsfpc');
    P.OSes:=[nds];
{$ifdef ALLPACKAGES}
    P.Directory:='libndsfpc';
{$endif ALLPACKAGES}
    P.Version:='2.7.1';
    P.SourcePath.Add('src');
//    P.Dependencies.Add('x11');

    // not linux compilable, skip

{$ifndef ALLPACKAGES}
    Run;
    end;
end.
{$endif ALLPACKAGES}