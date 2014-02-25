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

    P:=AddPackage('unixutil');
{$ifdef ALLPACKAGES}
    P.Directory:='unixutil';
{$endif ALLPACKAGES}
    P.Version:='2.6.4';
    P.OSes:=[Linux];
    P.CPUs:=[i386];
    P.SourcePath.Add('src');
    T:=P.Targets.AddUnit('unixutils.pp',[i386],[linux]);
      with T.Dependencies do
        begin
          AddUnit('libc');
        end;

{$ifndef ALLPACKAGES}
    Run;
    end;
end.
{$endif ALLPACKAGES}
