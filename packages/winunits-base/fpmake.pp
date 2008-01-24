{$ifndef ALLPACKAGES}
{$mode objfpc}{$H+}
program fpmake;

uses fpmkunit;

Var
  T : TTarget;
  P : TPackage;
begin
  With Installer do
    begin
{$endif ALLPACKAGES}

    P:=AddPackage('winunits-base');
{$ifdef ALLPACKAGES}
    P.Directory:='winunits-base';
{$endif ALLPACKAGES}
    P.Version:='2.2.1';
    P.OSes:=[win32,win64];

    P.SourcePath.Add('src');

    T:=P.Targets.AddUnit('buildwinutilsbase.pp');
      T.Install:=False;
    T:=P.Targets.AddImplicitUnit('activex.pp');
    T:=P.Targets.AddImplicitUnit('comconst.pp');
    T:=P.Targets.AddImplicitUnit('commctrl.pp');
    T:=P.Targets.AddImplicitUnit('comobj.pp');
    T:=P.Targets.AddImplicitUnit('flatsb.pp');
    T:=P.Targets.AddImplicitUnit('mmsystem.pp');
    T:=P.Targets.AddImplicitUnit('ole2.pp');
    T:=P.Targets.AddImplicitUnit('oleserver.pp');
    T:=P.Targets.AddImplicitUnit('richedit.pp');
    T:=P.Targets.AddImplicitUnit('shellapi.pp');
    T:=P.Targets.AddImplicitUnit('shfolder.pp');
    T:=P.Targets.AddImplicitUnit('shlobj.pp');
    T:=P.Targets.AddImplicitUnit('winver.pp');

{$ifndef ALLPACKAGES}
    Run;
    end;
end.
{$endif ALLPACKAGES}
