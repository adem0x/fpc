unit pkgcommands;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,pkghandler;

implementation

uses
  zipper,
  pkgmessages,
  pkgglobals,
  pkgoptions,
  pkgdownload,
  pkgrepos,
  fprepos;

type
  { TCommandAddConfig }

  TCommandAddConfig = Class(TPackagehandler)
  Public
    Function Execute(const Args:TActionArgs):boolean;override;
  end;

  { TCommandUpdate }

  TCommandUpdate = Class(TPackagehandler)
  Public
    Function Execute(const Args:TActionArgs):boolean;override;
  end;

  { TCommandShowAll }

  TCommandShowAll = Class(TPackagehandler)
  Public
    Function Execute(const Args:TActionArgs):boolean;override;
  end;

  { TCommandShowAvail }

  TCommandShowAvail = Class(TPackagehandler)
  Public
    Function Execute(const Args:TActionArgs):boolean;override;
  end;

  { TCommandScanPackages }

  TCommandScanPackages = Class(TPackagehandler)
  Public
    Function Execute(const Args:TActionArgs):boolean;override;
  end;

  { TCommandDownload }

  TCommandDownload = Class(TPackagehandler)
  Public
    Function Execute(const Args:TActionArgs):boolean;override;
  end;

  { TCommandUnzip }

  TCommandUnzip = Class(TPackagehandler)
  Public
    Function Execute(const Args:TActionArgs):boolean;override;
  end;

  { TCommandCompile }

  TCommandCompile = Class(TPackagehandler)
  Public
    Function Execute(const Args:TActionArgs):boolean;override;
  end;

  { TCommandBuild }

  TCommandBuild = Class(TPackagehandler)
  Public
    Function Execute(const Args:TActionArgs):boolean;override;
  end;

  { TCommandInstall }

  TCommandInstall = Class(TPackagehandler)
  Public
    Function Execute(const Args:TActionArgs):boolean;override;
  end;

  { TCommandClean }

  TCommandClean = Class(TPackagehandler)
  Public
    Function Execute(const Args:TActionArgs):boolean;override;
  end;

  { TCommandArchive }

  TCommandArchive = Class(TPackagehandler)
  Public
    Function Execute(const Args:TActionArgs):boolean;override;
  end;

  { TCommandInstallDependencies }

  TCommandInstallDependencies = Class(TPackagehandler)
  Public
    Function Execute(const Args:TActionArgs):boolean;override;
  end;


function TCommandAddConfig.Execute(const Args:TActionArgs):boolean;
begin
{
  Log(vlInfo,SLogGeneratingCompilerConfig,[S]);
  Options.InitCompilerDefaults(Args[2]);
  Options.SaveCompilerToFile(S);
}
  Result:=true;
end;


function TCommandUpdate.Execute(const Args:TActionArgs):boolean;
var
  PackagesURL :  String;
begin
  // Download mirrors.xml
  Log(vlCommands,SLogDownloading,[GlobalOptions.RemoteMirrorsURL,GlobalOptions.LocalMirrorsFile]);
  DownloadFile(GlobalOptions.RemoteMirrorsURL,GlobalOptions.LocalMirrorsFile);
  LoadLocalMirrors;
  // Download packages.xml
  PackagesURL:=GetRemoteRepositoryURL(PackagesFileName);
  Log(vlCommands,SLogDownloading,[PackagesURL,GlobalOptions.LocalPackagesFile]);
  DownloadFile(PackagesURL,GlobalOptions.LocalPackagesFile);
  // Read the repository again
  LoadLocalRepository;
  // no need to log errors again
  FindInstalledPackages(CompilerOptions,False);
  Result:=true;
end;


function TCommandShowAll.Execute(const Args:TActionArgs):boolean;
begin
  ListLocalRepository(true);
  Result:=true;
end;


function TCommandShowAvail.Execute(const Args:TActionArgs):boolean;
begin
  ListLocalRepository(false);
  Result:=true;
end;


function TCommandScanPackages.Execute(const Args:TActionArgs):boolean;
begin
  RebuildRemoteRepository;
  ListRemoteRepository;
  SaveRemoteRepository;
  Result:=true;
end;


function TCommandDownload.Execute(const Args:TActionArgs):boolean;
begin
  if not assigned(CurrentPackage) then
    Error(SErrNoPackageSpecified);
  if not FileExists(PackageLocalArchive) then
    ExecuteAction(CurrentPackage,'downloadpackage',Args);
  Result:=true;
end;


function TCommandUnzip.Execute(const Args:TActionArgs):boolean;
Var
  BuildDir : string;
  ArchiveFile : String;
begin
  BuildDir:=PackageBuildPath;
  ArchiveFile:=PackageLocalArchive;
  if not assigned(CurrentPackage) then
    Error(SErrNoPackageSpecified);
  if not FileExists(ArchiveFile) then
    ExecuteAction(CurrentPackage,'downloadpackage');
  { Create builddir, remove it first if needed }
  if DirectoryExists(BuildDir) then
    DeleteDir(BuildDir);
  ForceDirectories(BuildDir);
  SetCurrentDir(BuildDir);
  { Unzip Archive }
  With TUnZipper.Create do
    try
      Log(vlCommands,SLogUnzippping,[ArchiveFile]);
      OutputPath:=PackageBuildPath;
      UnZipAllFiles(ArchiveFile);
    Finally
      Free;
    end;
  Result:=true;
end;


function TCommandCompile.Execute(const Args:TActionArgs):boolean;
begin
  if assigned(CurrentPackage) then
    begin
      // For local files we need the information inside the zip to get the
      // dependencies
      if CurrentPackage.IsLocalPackage then
        begin
          ExecuteAction(CurrentPackage,'unzip',Args);
          ExecuteAction(CurrentPackage,'installdependencies',Args);
        end
      else
        begin
          ExecuteAction(CurrentPackage,'installdependencies',Args);
          ExecuteAction(CurrentPackage,'unzip',Args);
        end;
    end;
  ExecuteAction(CurrentPackage,'fpmakecompile',Args);
  Result:=true;
end;


function TCommandBuild.Execute(const Args:TActionArgs):boolean;
begin
  if assigned(CurrentPackage) then
    begin
      // For local files we need the information inside the zip to get the
      // dependencies
      if CurrentPackage.IsLocalPackage then
        begin
          ExecuteAction(CurrentPackage,'unzip',Args);
          ExecuteAction(CurrentPackage,'installdependencies',Args);
        end
      else
        begin
          ExecuteAction(CurrentPackage,'installdependencies',Args);
          ExecuteAction(CurrentPackage,'unzip',Args);
        end;
    end;
  ExecuteAction(CurrentPackage,'fpmakebuild',Args);
  Result:=true;
end;


function TCommandInstall.Execute(const Args:TActionArgs):boolean;
begin
  if assigned(CurrentPackage) then
    ExecuteAction(CurrentPackage,'build',Args);
  ExecuteAction(CurrentPackage,'fpmakeinstall',Args);
  // Update local status file
  if assigned(CurrentPackage) then
    CurrentPackage.InstalledVersion.Assign(CurrentPackage.Version);
  Result:=true;
end;


function TCommandClean.Execute(const Args:TActionArgs):boolean;
begin
  ExecuteAction(CurrentPackage,'fpmakeclean',Args);
  Result:=true;
end;


function TCommandArchive.Execute(const Args:TActionArgs):boolean;
begin
  ExecuteAction(CurrentPackage,'fpmakearchive',Args);
  Result:=true;
end;


function TCommandInstallDependencies.Execute(const Args:TActionArgs):boolean;
var
  i : Integer;
  MissingDependency,
  D : TFPDependency;
  P,
  DepPackage : TFPPackage;
  L : TStringList;
  status : string;
begin
  if not assigned(CurrentPackage) then
    Error(SErrNoPackageSpecified);
  // Load dependencies for local packages
  if CurrentPackage.IsLocalPackage then
    begin
      ExecuteAction(CurrentPackage,'fpmakemanifest',Args);
      P:=LoadPackageManifest(ManifestFileName);
      // Update CurrentPackage
      CurrentPackage.Assign(P);
      CurrentPackage.IsLocalPackage:=true;
    end;
  // Find and List dependencies
  MissingDependency:=nil;
  L:=TStringList.Create;
  for i:=0 to CurrentPackage.Dependencies.Count-1 do
    begin
      D:=CurrentPackage.Dependencies[i];
      if (CompilerOptions.CompilerOS in D.OSes) and
         (CompilerOptions.CompilerCPU in D.CPUs) then
        begin
          DepPackage:=CurrentRepository.PackageByName(D.PackageName);
          // Need installation?
          if (DepPackage.InstalledVersion.Empty) or
             (DepPackage.InstalledVersion.CompareVersion(D.MinVersion)<0) then
            begin
              if DepPackage.Version.CompareVersion(D.MinVersion)<0 then
                begin
                  status:='Not Available!';
                  MissingDependency:=D;
                end
              else
                begin
                  status:='Updating';
                  L.Add(DepPackage.Name);
                end;
            end
          else
            status:='OK';
          Log(vlInfo,SLogPackageDependency,
              [D.PackageName,D.MinVersion.AsString,DepPackage.InstalledVersion.AsString,DepPackage.Version.AsString,status]);
        end
      else
        Log(vlDebug,SDbgPackageDependencyOtherTarget,[D.PackageName,MakeTargetString(CompilerOptions.CompilerCPU,CompilerOptions.CompilerOS)]);
    end;
  // Give error on first missing dependency
  if assigned(MissingDependency) then
    Error(SErrNoPackageAvailable,[MissingDependency.PackageName,MissingDependency.MinVersion.AsString]);
  // Install needed updates
  for i:=0 to L.Count-1 do
    begin
      DepPackage:=CurrentRepository.PackageByName(L[i]);
      ExecuteAction(DepPackage,'install');
    end;
  FreeAndNil(L);
  Result:=true;
end;


initialization
  RegisterPkgHandler('update',TCommandUpdate);
  RegisterPkgHandler('showall',TCommandShowAll);
  RegisterPkgHandler('showavail',TCommandShowAvail);
  RegisterPkgHandler('scan',TCommandScanPackages);
  RegisterPkgHandler('download',TCommandDownload);
  RegisterPkgHandler('unzip',TCommandUnzip);
  RegisterPkgHandler('compile',TCommandCompile);
  RegisterPkgHandler('build',TCommandBuild);
  RegisterPkgHandler('install',TCommandInstall);
  RegisterPkgHandler('clean',TCommandClean);
  RegisterPkgHandler('archive',TCommandArchive);
  RegisterPkgHandler('installdependencies',TCommandInstallDependencies);
end.
