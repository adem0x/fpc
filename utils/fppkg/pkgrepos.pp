unit pkgrepos;

{$mode objfpc}{$H+}

interface

uses
  Classes,SysUtils,
  fprepos;

procedure LoadLocalRepository;
procedure LoadLocalStatus;
procedure SaveLocalStatus;
procedure ListLocalRepository(all:boolean=false);

procedure ListRemoteRepository;
procedure RebuildRemoteRepository;
procedure SaveRemoteRepository;

var
  CurrentRepository : TFPRepository;


implementation

uses
  zipper,
  fpxmlrep,
  pkgglobals,
  pkgoptions,
  pkgmessages;

{*****************************************************************************
                           Local Repository
*****************************************************************************}

procedure LoadLocalRepository;
var
  S : String;
  X : TFPXMLRepositoryHandler;
begin
  if assigned(CurrentRepository) then
    CurrentRepository.Free;
  CurrentRepository:=TFPRepository.Create(Nil);
  // Repository
  S:=GlobalOptions.LocalPackagesFile;
  Log(vDebug,SLogLoadingPackagesFile,[S]);
  if not FileExists(S) then
    exit;
  try
    X:=TFPXMLRepositoryHandler.Create;
    With X do
      try
        LoadFromXml(CurrentRepository,S);
      finally
        Free;
      end;
  except
    on E : Exception do
      begin
        Log(vError,E.Message);
        Error(SErrCorruptPackagesFile,[S]);
      end;
  end;
end;


procedure LoadLocalStatus;
var
  S : String;
begin
  S:=GlobalOptions.LocalVersionsFile(GlobalOptions.CompilerConfig);
  Log(vDebug,SLogLoadingStatusFile,[S]);
  if FileExists(S) then
    CurrentRepository.LoadStatusFromFile(S);
end;


procedure SaveLocalStatus;
var
  S : String;
begin
  S:=GlobalOptions.LocalVersionsFile(GlobalOptions.CompilerConfig);
  Log(vDebug,SLogSavingStatusFile,[S]);
  CurrentRepository.SaveStatusToFile(S);
end;


procedure ListLocalRepository(all:boolean=false);
var
  P : TFPPackage;
  i : integer;
begin
  Writeln(Format('%-20s %-12s %-12s',['Name','Installed','Available']));
  for i:=0 to CurrentRepository.PackageCount-1 do
    begin
      P:=CurrentRepository.Packages[i];
      if all or (P.Version.CompareVersion(P.InstalledVersion)>0) then
        begin
          Writeln(Format('%-20s %-12s %-12s',[P.Name,P.InstalledVersion.AsString,P.Version.AsString]));
        end;
    end;
end;


{*****************************************************************************
                           Remote Repository
*****************************************************************************}

procedure ListRemoteRepository;
var
  P : TFPPackage;
  i : integer;
begin
  Writeln(Format('%-20s %-12s %-20s',['Name','Available','FileName']));
  for i:=0 to CurrentRepository.PackageCount-1 do
    begin
      P:=CurrentRepository.Packages[i];
      Writeln(Format('%-20s %-12s %-20s',[P.Name,P.Version.AsString,P.FileName]));
    end;
end;


procedure RebuildRemoteRepository;
var
  X : TFPXMLRepositoryHandler;
  i : integer;
  ArchiveSL : TStringList;
  ManifestSL : TStringList;
begin
  if assigned(CurrentRepository) then
    CurrentRepository.Free;
  CurrentRepository:=TFPRepository.Create(Nil);
  try
    ManifestSL:=TStringList.Create;
    ManifestSL.Add(DefaultManifestFile);
    { Find all archives }
    ArchiveSL:=TStringList.Create;
    SearchFiles(ArchiveSL,'*.zip');
    if ArchiveSL.Count=0 then
      Error('No archive files found');
    { Process all archives }
    for i:=0 to ArchiveSL.Count-1 do
      begin
        Writeln('Processing ',ArchiveSL[i]);
        { Unzip manifest.xml }
        With TUnZipper.Create do
          try
            Log(vCommands,SLogUnzippping,[ArchiveSL[i]]);
            OutputPath:='.';
            UnZipFiles(ArchiveSL[i],ManifestSL);
          Finally
            Free;
          end;
        { Load manifest.xml }
        if FileExists(DefaultManifestFile) then
          begin
            X:=TFPXMLRepositoryHandler.Create;
            With X do
              try
                LoadFromXml(CurrentRepository.PackageCollection,DefaultManifestFile);
              finally
                Free;
              end;
            DeleteFile(DefaultManifestFile);
          end
        else
          Writeln('No manifest found in archive ',ArchiveSL[i]);
      end;
  finally
    ArchiveSL.Free;
    ManifestSL.Free;
  end;
end;


procedure SaveRemoteRepository;
var
  X : TFPXMLRepositoryHandler;
begin
  // Repository
  Writeln('Saving repository in packages.xml');
  X:=TFPXMLRepositoryHandler.Create;
  With X do
    try
      SaveToXml(CurrentRepository,'packages.xml');
    finally
      Free;
    end;
end;



initialization
end.
