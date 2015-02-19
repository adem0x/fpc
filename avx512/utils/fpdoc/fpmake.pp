{$ifndef ALLPACKAGES}
{$mode objfpc}{$H+}
program fpmake;

uses fpmkunit, sysutils;
{$endif ALLPACKAGES}

procedure add_fpdoc(const ADirectory: string);

Var
  P : TPackage;
  T : TTarget;
  Bin2Obj : string;

begin
  AddCustomFpmakeCommandlineOption('bin2obj', 'Use indicated bin2obj executable.');
  With Installer do
    begin
    P:=AddPackage('utils-fpdoc');
    P.ShortName:='fpdoc';

    P.Author := '<various>';
    P.License := 'LGPL with modification';
    P.HomepageURL := 'www.freepascal.org';
    P.Email := '';
    P.Description := 'Free Pascal documentation generation utility.';
    P.NeedLibC:= false;

    P.Dependencies.Add('fcl-base');
    P.Dependencies.Add('fcl-xml');
    P.Dependencies.Add('fcl-passrc');
    P.Dependencies.Add('fcl-process');
    P.Dependencies.Add('chm');
    P.Dependencies.Add('univint',[darwin,iphonesim]);

    P.Directory:=ADirectory;
    P.Version:='3.1.1';

    P.Options.Add('-S2h');

    T:=P.Targets.AddProgram('fpdoc.pp');
    T.Dependencies.AddUnit('dglobals');
    T.Dependencies.AddUnit('dw_ipflin');
    T.Dependencies.AddUnit('dwriter');
    T.Dependencies.AddUnit('dw_xml');
    T.Dependencies.AddUnit('dglobals');
    T.Dependencies.AddUnit('sh_pas');
    T.Dependencies.AddUnit('dw_html');
    T.Dependencies.AddUnit('dw_latex');
    T.Dependencies.AddUnit('dwlinear');
    T.Dependencies.AddUnit('dw_txt');
    T.Dependencies.AddUnit('dw_linrtf');

    T:=P.Targets.AddProgram('makeskel.pp');
    T.ResourceStrings:=true;
    T.Dependencies.AddUnit('dglobals');

    T:=P.Targets.AddProgram('unitdiff.pp');
    T:=P.Targets.AddProgram('fpclasschart.pp');

    T := P.Targets.AddUnit('dglobals.pp');
    T.install:=false;
    T.ResourceStrings:=true;

    T := P.Targets.AddUnit('dwriter.pp');
    T.install:=false;
    T.ResourceStrings:=true;

    T := P.Targets.AddUnit('fpdocxmlopts.pas');
    T.install:=false;
    T.ResourceStrings:=true;

    P.Targets.AddUnit('dw_xml.pp').install:=false;
    P.Targets.AddUnit('sh_pas.pp').install:=false;
    P.Targets.AddUnit('dw_html.pp').install:=false;
    P.Targets.AddUnit('dw_latex.pp').install:=false;
    P.Targets.AddUnit('dw_txt.pp').install:=false;
    P.Targets.AddUnit('dw_man.pp').install:=false;
    P.Targets.AddUnit('dwlinear.pp').install:=false;
    P.Targets.AddUnit('dw_linrtf.pp').install:=false;
    P.Targets.AddUnit('dw_dxml.pp').install:=false;
    P.Targets.AddUnit('fpdocproj.pas').install:=false;
    P.Targets.AddUnit('mkfpdoc.pp').install:=false;
    P.Targets.AddUnit('dw_ipflin.pas').install:=false;

    Bin2Obj := GetCustomFpmakeCommandlineOptionValue('bin2obj');
    if Bin2Obj<>'' then
      Bin2Obj:= ExpandFileName(Bin2Obj);
    if Bin2Obj='' then
      Bin2Obj := ExeSearch(AddProgramExtension('bin2obj', Defaults.BuildOS));
    if Bin2Obj <> '' then
      begin
      P.Commands.AddCommand(Bin2Obj,'-o $(DEST) -c DefaultCSS $(SOURCE)','css.inc','fpdoc.css');
      P.Commands.AddCommand(Bin2Obj,'-o $(DEST) -c PlusImageData $(SOURCE)','plusimage.inc','images/plus.png');
      P.Commands.AddCommand(Bin2Obj,'-o $(DEST) -c MinusImageData $(SOURCE)','minusimage.inc','images/minus.png');
      end;
    end;
end;

{$ifndef ALLPACKAGES}
begin
  add_fpdoc('');
  Installer.Run;
end.
{$endif ALLPACKAGES}




