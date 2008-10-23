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

    P:=AddPackage('graph');
{$ifdef ALLPACKAGES}
    P.Directory:='graph';
{$endif ALLPACKAGES}
    P.Version:='2.2.2-0';
    P.SourcePath.Add('src');
    P.SourcePath.Add('src/macosx',[darwin]);
    P.SourcePath.Add('src/amiga',[amiga]);
    P.SourcePath.Add('src/go32v2',[go32v2]);
    P.SourcePath.Add('src/win32',[win32,win64]);
    P.SourcePath.Add('src/unix',[freebsd,linux]);  // Darwin has own.

    P.IncludePath.Add('src/inc');
    P.IncludePath.Add('src/go32v2',[go32v2]);
    P.IncludePath.Add('src/unix',[freebsd,linux]);  // Darwin has own.
    P.IncludePath.Add('src/go32v2',[go32v2]);

    T:=P.Targets.AddUnit('ggigraph.pp',[linux,freebsd]);
      with T.Dependencies do
        begin
          AddInclude('graphh.inc');
          AddInclude('graph.inc');
          AddInclude('fontdata.inc');
          AddInclude('clip.inc');
          AddInclude('palette.inc');
          AddInclude('modes.inc');
          AddInclude('fills.inc');
          AddInclude('gtext.inc');
        end;
    T:=P.Targets.AddUnit('graph.pp');
      with T.Dependencies do
        begin
          AddInclude('graphh.inc');
          AddInclude('graph.inc');
          AddInclude('fontdata.inc');
          AddInclude('clip.inc');
          AddInclude('palette.inc');
          AddInclude('modes.inc');
          AddInclude('fills.inc');
          AddInclude('gtext.inc');
          AddInclude('graph16.inc',[freebsd,linux]);
        end;
    T:=P.Targets.AddUnit('sdlgraph.pp');
      with T.Dependencies do
        begin
          AddInclude('graphh.inc');
          AddInclude('graph.inc');
          AddInclude('fontdata.inc');
          AddInclude('clip.inc');
          AddInclude('palette.inc');
          AddInclude('modes.inc');
          AddInclude('fills.inc');
          AddInclude('gtext.inc');
          AddUnit('sdl');
          AddUnit('sdlutils');
          AddUnit('logger');
        end;


{$ifndef ALLPACKAGES}
    Run;
    end;
end.
{$endif ALLPACKAGES}
