{$ifndef ALLPACKAGES}
{$mode objfpc}{$H+}
program fpmake;

uses fpmkunit;
{$endif ALLPACKAGES}

procedure add_unicode;

Var
  P : TPackage;
  T : TTarget;

begin
  With Installer do
    begin
    P:=AddPackage('unicode');

    P.Author := 'Inoussa OUEDRAOGO';
    P.License := 'LGPL with modification';
    P.HomepageURL := 'www.freepascal.org';
    P.Email := '';

{$ifdef ALLPACKAGES}
    P.Directory:='unicode';
{$endif ALLPACKAGES}
    P.Version:='2.7.1';
    P.Dependencies.Add('rtl');
    P.Dependencies.Add('fcl-base');
    P.Dependencies.Add('fcl-xml');

    P.OSes:=[win32, win64, linux, darwin];

    T := P.Targets.AddImplicitUnit('helper.pas');
    T.ResourceStrings := true;
    T.Install := false;
    T := P.Targets.AddImplicitUnit('cldrxml.pas');
    T.ResourceStrings := true;
    T.Install := false;
    T := P.Targets.AddImplicitUnit('unicodeset.pas');
    T.ResourceStrings := true;
    T.Install := false;
    T := P.Targets.AddImplicitUnit('uca_test.pas');
    T.Install := false;
    T := P.Targets.AddImplicitUnit('cldrhelper.pas');
    T.Install := false;
    T := P.Targets.AddImplicitUnit('cldrtest.pas');
    T.Install := false;
    T := P.Targets.AddImplicitUnit('grbtree.pas');
    T.Install := false;
    T := P.Targets.AddImplicitUnit('trie.pas');
    T.Install := false;
    T := P.Targets.AddImplicitUnit('unicodeset.pas');
    T.Install := false;

    T:=P.Targets.AddProgram('cldrparser.lpr');
    T:=P.Targets.AddProgram('unihelper.lpr');

    end;
end;

{$ifndef ALLPACKAGES}
begin
  add_unicode;
  Installer.Run;
end.
{$endif ALLPACKAGES}




