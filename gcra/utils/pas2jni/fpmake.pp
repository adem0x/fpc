{$ifndef ALLPACKAGES}
{$mode objfpc}{$H+}
program fpmake;

uses fpmkunit;
{$endif ALLPACKAGES}

procedure add_pas2jni(const ADirectory: string);

Var
  P : TPackage;
  T : TTarget;

begin
  With Installer do
    begin
    P:=AddPackage('utils-pas2jni');

    P.Author := 'Yury Sidorov';
    P.License := 'LGPL with modification';
    P.HomepageURL := 'www.freepascal.org';
    P.Description := 'The pas2jni utility generates a JNI (Java Native Interface) bridge for a Pascal code.';
    P.Email := '';
    P.NeedLibC:= false;

    P.Directory:=ADirectory;
    P.Version:='2.7.1';
    P.Dependencies.Add('fcl-base');
    P.Dependencies.Add('fcl-process');
    P.Dependencies.Add('fcl-json');

    T:=P.Targets.AddImplicitUnit('def.pas');
    T.Install := false;
    T:=P.Targets.AddImplicitUnit('ppuparser.pas');
    T.Install := false;
    T:=P.Targets.AddImplicitUnit('writer.pas');
    T.Install := false;
    T:=P.Targets.AddProgram('pas2jni.pas');
    end;
end;

{$ifndef ALLPACKAGES}
begin
  add_pas2jni('');
  Installer.Run;
end.
{$endif ALLPACKAGES}




