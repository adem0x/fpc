{$mode objfpc}{$H+}
{$define allpackages}
program fpmake;

uses fpmkunit, sysutils, Classes;

Var
  TBuild,T : TTarget;
  PBuild,P : TPackage;
  D : TDependency;
  I : Integer;

(*

The include files are generated with the following commands:

/bin/ls -1 */fpmake.pp | awk -F '/' '/fpmake.pp/ { printf "procedure add_%s;\nbegin\n  with Installer do\n{$include %s}\nend;\n\n",gensub("-","_","g",$1),$0; }' > fpmake_proc.inc
/bin/ls -1 */fpmake.pp | awk -F '/' '/fpmake.pp/ { printf "  add_%s;\n",gensub("-","_","g",$1); }' > fpmake_add.inc

*)

{$include fpmake_proc.inc}

begin
{$include fpmake_add.inc}

  With Installer do
    begin
      // Create fpc-all package
      PBuild:=AddPackage('fpc-all');
      PBuild.Version:='2.6.4';
      Run;
    end;
end.
