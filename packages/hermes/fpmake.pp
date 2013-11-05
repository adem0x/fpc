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

    P:=AddPackage('hermes');
{$ifdef ALLPACKAGES}
    P.Directory:='hermes';
{$endif ALLPACKAGES}
    P.Version:='2.6.4rc1';

    P.Author := 'Nikolay Nikolov (translation to Pascal), Christian Nentwich (original C version)';
    P.License := 'LGPL with modification, ';
    P.HomepageURL := 'www.freepascal.org';
    P.Email := '';
    P.Description := 'Library for pixel graphics conversion';
    P.NeedLibC := false;

    P.SourcePath.Add('src');
    P.IncludePath.Add('src');
    P.IncludePath.Add('src/i386',[i386],AllOSes);
    P.IncludePath.Add('src/x86_64',[x86_64],AllOSes);

T:=P.Targets.AddUnit('hermes.pp');
  with T.Dependencies do
    begin
      AddInclude('hermdef.inc');
      AddInclude('hermconf.inc');
<<<<<<< .working
      AddInclude('malloc.inc');
      AddInclude('debug.inc');
      AddInclude('dither.inc');
=======
      AddInclude('hermes_debug.inc');
      AddInclude('hermes_dither.inc');
>>>>>>> .merge-right.r23003
      AddInclude('headp.inc');
      AddInclude('p_16.inc');
      AddInclude('p_24.inc');
      AddInclude('p_32.inc');
      AddInclude('p_clr.inc');
      AddInclude('p_cnv.inc');
      AddInclude('p_cpy.inc');
      AddInclude('p_g.inc');
      AddInclude('p_ga.inc');
      AddInclude('p_gac.inc');
      AddInclude('p_gca.inc');
      AddInclude('p_gcc.inc');
      AddInclude('p_i8.inc');
      AddInclude('p_muhmu.inc');
      AddInclude('d_32.inc');
<<<<<<< .working
      AddInclude('headi386.inc',[i386],AllOSes);
      AddInclude('headmmx.inc',[i386],AllOSes); 
=======
>>>>>>> .merge-right.r23003
      AddInclude('factconv.inc');
      AddInclude('list.inc');
      AddInclude('utility.inc');
      AddInclude('format.inc');
      AddInclude('palette.inc');
      AddInclude('convert.inc');
      AddInclude('clear.inc');
      AddInclude('factory.inc');
      AddInclude('headi386.inc',[i386],AllOSes);
      AddInclude('headmmx.inc',[i386],AllOSes);
      AddInclude('mmx_clr.inc',[i386],AllOSes);
      AddInclude('mmx_main.inc',[i386],AllOSes);
      AddInclude('mmxp2_32.inc',[i386],AllOSes);
      AddInclude('mmxp_32.inc',[i386],AllOSes);
      AddInclude('x8616lut.inc',[i386],AllOSes);
      AddInclude('x86_clr.inc',[i386],AllOSes);
      AddInclude('x86_main.inc',[i386],AllOSes);
      AddInclude('x86p_16.inc',[i386],AllOSes);
      AddInclude('x86p_32.inc',[i386],AllOSes);
      AddInclude('x86p_cpy.inc',[i386],AllOSes);
      AddInclude('x86p_i8.inc',[i386],AllOSes);
      AddInclude('x86p_s32.inc',[i386],AllOSes);
      AddInclude('x86pscpy.inc',[i386],AllOSes);
      AddInclude('headx86_64.inc',[x86_64],AllOSes);
      AddInclude('x86_64_i8.inc',[x86_64],AllOSes);
   end;


{$ifndef ALLPACKAGES}
    Run;
    end;
end.
{$endif ALLPACKAGES}
