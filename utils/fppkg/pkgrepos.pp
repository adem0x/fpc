unit pkgrepos;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,Classes,
  fprepos,pkgoptions;

function GetRemoteRepositoryURL(const AFileName:string):string;

procedure LoadLocalAvailableMirrors;
procedure LoadLocalAvailableRepository;
procedure LoadUnitConfigFromFile(APackage:TFPPackage;const AFileName: String);
function LoadManifestFromFile(const AManifestFN:string):TFPPackage;
procedure FindInstalledPackages(ACompilerOptions:TCompilerOptions;showdups:boolean=true);
function  PackageIsBroken(APackage:TFPPackage):boolean;
function  FindBrokenPackages(SL:TStrings):Boolean;
procedure CheckFPMakeDependencies;
function  PackageInstalledVersionStr(const AName:String;const ShowUsed: boolean = false;const Local: boolean = false):string;
function  PackageInstalledStateStr(const AName:String):string;
function  PackageAvailableVersionStr(const AName:String):string;
procedure ListAvailablePackages;
procedure ListPackages(const ShowGlobalAndLocal: boolean);

procedure ListRemoteRepository;
procedure RebuildRemoteRepository;
procedure SaveRemoteRepository;

var
  AvailableMirrors    : TFPMirrors;
  AvailableRepository,
  InstalledRepository : TFPRepository;


implementation

uses
  zipper,
  fpxmlrep,
  pkgglobals,
  pkgmessages;

{*****************************************************************************
                           Mirror Selection
*****************************************************************************}

var
  CurrentRemoteRepositoryURL : String;

procedure LoadLocalAvailableMirrors;
var
  S : String;
  X : TFPXMLMirrorHandler;
begin
  if assigned(AvailableMirrors) then
    AvailableMirrors.Free;
  AvailableMirrors:=TFPMirrors.Create(TFPMirror);

  // Repository
  S:=GlobalOptions.LocalMirrorsFile;
  Log(vlDebug,SLogLoadingMirrorsFile,[S]);
  if not FileExists(S) then
    exit;
  try
    X:=TFPXMLMirrorHandler.Create;
    With X do
      try
        LoadFromXml(AvailableMirrors,S);
      finally
        Free;
      end;
  except
    on E : Exception do
      begin
        Log(vlError,E.Message);
        Error(SErrCorruptMirrorsFile,[S]);
      end;
  end;
end;


function SelectRemoteMirror:string;
var
  i,j : Integer;
  Bucket,
  BucketCnt : Integer;
  M : TFPMirror;
begin
  Result:='';
  M:=nil;
  if assigned(AvailableMirrors) then
   begin
     // Create array for selection
     BucketCnt:=0;
     for i:=0 to AvailableMirrors.Count-1 do
       inc(BucketCnt,AvailableMirrors[i].Weight);
     // Select random entry
     Bucket:=Random(BucketCnt);
     M:=nil;
     for i:=0 to AvailableMirrors.Count-1 do
       begin
         for j:=0 to AvailableMirrors[i].Weight-1 do
           begin
             if Bucket=0 then
               begin
                 M:=AvailableMirrors[i];
                 break;
               end;
             Dec(Bucket);
           end;
         if assigned(M) then
           break;
       end;
    end;
  if assigned(M) then
    begin
      Log(vlInfo,SLogSelectedMirror,[M.Name]);
      Result:=M.URL;
    end
  else
    Error(SErrFailedToSelectMirror);
end;


function GetRemoteRepositoryURL(const AFileName:string):string;
begin
  if CurrentRemoteRepositoryURL='' then
    begin
      if GlobalOptions.RemoteRepository='auto' then
        CurrentRemoteRepositoryURL:=SelectRemoteMirror
      else
        CurrentRemoteRepositoryURL:=GlobalOptions.RemoteRepository;
    end;
  Result:=CurrentRemoteRepositoryURL+AFileName;
end;


{*****************************************************************************
                           Local Repository
*****************************************************************************}

procedure ReadIniFile(Const AFileName: String;L:TStrings);
Var
  F : TFileStream;
  Line : String;
  I,P,PC : Integer;
begin
  F:=TFileStream.Create(AFileName,fmOpenRead);
  Try
    L.LoadFromStream(F);
    // Fix lines.
    For I:=L.Count-1 downto 0 do
      begin
        Line:=L[I];
        P:=Pos('=',Line);
        PC:=Pos(';',Line);  // Comment line.
        If (P=0) or ((PC<>0) and (PC<P)) then
          L.Delete(I)
        else
          L[i]:=Trim(System.Copy(Line,1,P-1)+'='+Trim(System.Copy(Line,P+1,Length(Line)-P)));
      end;
  Finally
    F.Free;
  end;
end;


function LoadManifestFromFile(const AManifestFN:string):TFPPackage;
var
  X : TFPXMLRepositoryHandler;
  NewPackages : TFPPackages;
  NewP,P : TFPPackage;
begin
  result:=nil;
  NewPackages:=TFPPackages.Create(TFPPackage);
  X:=TFPXMLRepositoryHandler.Create;
  try
    X.LoadFromXml(NewPackages,AManifestFN);
    // Update or Add packages to repository
    if NewPackages.Count=1 then
      begin
        NewP:=NewPackages[0];
        // Prevent duplicate names
{        P:=InstalledRepository.FindPackage(NewP.Name);
        if not assigned(P) then
          P:=InstalledRepository.AddPackage(NewP.Name); }
        result:=TFPPackage.Create(nil);
        // Copy contents
        result.Assign(NewP);
      end
    else
      Error(SErrManifestNoSinglePackage,[AManifestFN]);
  finally
    X.Free;
    NewPackages.Free;
  end;
end;


procedure LoadUnitConfigFromFile(APackage:TFPPackage;const AFileName: String);
Var
  L,DepSL : TStrings;
  DepName,
  V : String;
  DepChecksum : Cardinal;
  i,j,k : integer;
  D : TFPDependency;
begin
  L:=TStringList.Create;
  Try
    ReadIniFile(AFileName,L);
{$warning TODO Maybe check also CPU-OS}
    // Read fpunits.conf
    V:=L.Values['version'];
    APackage.Version.AsString:=V;
    V:=L.Values['checksum'];
    if V<>'' then
      APackage.Checksum:=StrToInt(V)
    else
      APackage.Checksum:=$ffffffff;
    // Load dependencies
    V:=L.Values['depends'];
    DepSL:=TStringList.Create;
    DepSL.CommaText:=V;
    for i:=0 to DepSL.Count-1 do
      begin
        DepName:=DepSL[i];
        k:=Pos('|',DepName);
        if k>0 then
          begin
            DepChecksum:=StrToInt(Copy(DepName,k+1,Length(DepName)-k));
            DepName:=Copy(DepName,1,k-1);
          end
        else
          DepChecksum:=$ffffffff;
        D:=nil;
        for j:=0 to APackage.Dependencies.Count-1 do
          begin
            D:=APackage.Dependencies[j];
            if D.PackageName=DepName then
              break;
            D:=nil;
          end;
        if not assigned(D) then
          D:=APackage.AddDependency(DepName,'');
        D.RequireChecksum:=DepChecksum;
      end;
    DepSL.Free;
  Finally
    L.Free;
  end;
end;


procedure FindInstalledPackages(ACompilerOptions:TCompilerOptions;showdups:boolean=true);

  function AddInstalledPackage(const AName,AFileName: String; const Local: boolean):TFPPackage;
  begin
    result:=InstalledRepository.FindPackage(AName);
    if not assigned(result) then
      result:=InstalledRepository.AddPackage(AName)
    else
      begin
        result.UnusedVersion:=result.Version;
        // Log packages found in multiple locations (local and global) ?
        if showdups then
          Log(vlDebug,SDbgPackageMultipleLocations,[result.Name,ExtractFilePath(AFileName)]);
      end;
    result.InstalledLocally:=Local;
  end;

  procedure LoadPackagefpcFromFile(APackage:TFPPackage;const AFileName: String);
  Var
    L : TStrings;
    V : String;
  begin
    L:=TStringList.Create;
    Try
      ReadIniFile(AFileName,L);
      V:=L.Values['version'];
      APackage.Version.AsString:=V;
    Finally
      L.Free;
    end;
  end;

  function CheckUnitDir(const AUnitDir:string; const Local: boolean):boolean;
  var
    SR : TSearchRec;
    P  : TFPPackage;
    UD,UF : String;
  begin
    Result:=false;
    if FindFirst(IncludeTrailingPathDelimiter(AUnitDir)+AllFiles,faDirectory,SR)=0 then
      begin
        Log(vlDebug,SLogFindInstalledPackages,[AUnitDir]);
        repeat
          if ((SR.Attr and faDirectory)=faDirectory) and (SR.Name<>'.') and (SR.Name<>'..') then
            begin
              UD:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(AUnitDir)+SR.Name);
              // Try new fpunits.conf
              UF:=UD+UnitConfigFileName;
              if FileExistsLog(UF) then
                begin
                  P:=AddInstalledPackage(SR.Name,UF,Local);
                  LoadUnitConfigFromFile(P,UF)
                end
              else
                begin
                  // Try Old style Package.fpc
                  UF:=UD+'Package.fpc';
                  if FileExistsLog(UF) then
                    begin
                      P:=AddInstalledPackage(SR.Name,UF,Local);
                      LoadPackagefpcFromFile(P,UF);
                    end;
                end;
            end;
        until FindNext(SR)<>0;
      end;
  end;

begin
  if assigned(InstalledRepository) then
    InstalledRepository.Free;
  InstalledRepository:=TFPRepository.Create(nil);
  // First scan the global directory
  // The local directory will overwrite the versions
  if ACompilerOptions.GlobalUnitDir<>'' then
    CheckUnitDir(ACompilerOptions.GlobalUnitDir, False);
  if ACompilerOptions.LocalUnitDir<>'' then
    CheckUnitDir(ACompilerOptions.LocalUnitDir, True);
end;


function PackageIsBroken(APackage:TFPPackage):boolean;
var
  j : integer;
  D : TFPDependency;
  DepPackage : TFPPackage;
begin
  result:=false;
  for j:=0 to APackage.Dependencies.Count-1 do
    begin
      D:=APackage.Dependencies[j];
      if (CompilerOptions.CompilerOS in D.OSes) and
         (CompilerOptions.CompilerCPU in D.CPUs) then
        begin
          DepPackage:=InstalledRepository.FindPackage(D.PackageName);
          // Don't stop on missing dependencies
          if assigned(DepPackage) then
            begin
              if (DepPackage.Checksum<>D.RequireChecksum) then
                begin
                  Log(vlInfo,SLogPackageChecksumChanged,[APackage.Name,D.PackageName]);
                  result:=true;
                  exit;
                end;
            end
          else
            Log(vlDebug,SDbgObsoleteDependency,[D.PackageName]);
        end;
    end;
end;


function FindBrokenPackages(SL:TStrings):Boolean;
var
  i : integer;
  P : TFPPackage;
begin
  SL.Clear;
  for i:=0 to InstalledRepository.PackageCount-1 do
    begin
      P:=InstalledRepository.Packages[i];
      if PackageIsBroken(P) then
        SL.Add(P.Name);
    end;
  Result:=(SL.Count>0);
end;


procedure CheckFPMakeDependencies;
var
  i : Integer;
  P,AvailP : TFPPackage;
  AvailVerStr : string;
  ReqVer : TFPVersion;
begin
  // Reset availability
  for i:=1 to FPMKUnitDepCount do
    FPMKUnitDepAvailable[i]:=false;
  // Not version check needed in Recovery mode, we always need to use
  // the internal bootstrap procedure
  if GlobalOptions.RecoveryMode then
    exit;
  // Check for fpmkunit dependencies
  for i:=1 to FPMKUnitDepCount do
    begin
      P:=InstalledRepository.FindPackage(FPMKUnitDeps[i].package);
      if P<>nil then
        begin
          AvailP:=AvailableRepository.FindPackage(FPMKUnitDeps[i].package);
          if AvailP<>nil then
            AvailVerStr:=AvailP.Version.AsString
          else
            AvailVerStr:='<not available>';
          ReqVer:=TFPVersion.Create;
          ReqVer.AsString:=FPMKUnitDeps[i].ReqVer;
          Log(vlDebug,SLogFPMKUnitDepVersion,[P.Name,ReqVer.AsString,P.Version.AsString,AvailVerStr]);
          if ReqVer.CompareVersion(P.Version)<=0 then
            FPMKUnitDepAvailable[i]:=true
          else
            Log(vlDebug,SLogFPMKUnitDepTooOld,[FPMKUnitDeps[i].package]);
        end
      else
        Log(vlDebug,SLogFPMKUnitDepTooOld,[FPMKUnitDeps[i].package]);
    end;
end;


{*****************************************************************************
                           Local Available Repository
*****************************************************************************}

procedure LoadLocalAvailableRepository;
var
  S : String;
  X : TFPXMLRepositoryHandler;
begin
  if assigned(AvailableRepository) then
    AvailableRepository.Free;
  AvailableRepository:=TFPRepository.Create(Nil);
  // Repository
  S:=GlobalOptions.LocalPackagesFile;
  Log(vlDebug,SLogLoadingPackagesFile,[S]);
  if not FileExists(S) then
    exit;
  try
    X:=TFPXMLRepositoryHandler.Create;
    With X do
      try
        LoadFromXml(AvailableRepository,S);
      finally
        Free;
      end;
  except
    on E : Exception do
      begin
        Log(vlError,E.Message);
        Error(SErrCorruptPackagesFile,[S]);
      end;
  end;
end;


function PackageAvailableVersionStr(const AName:String):string;
var
  P : TFPPackage;
begin
  P:=AvailableRepository.FindPackage(AName);
  if P<>nil then
    result:=P.Version.AsString
  else
    result:='-';
end;


function PackageInstalledVersionStr(const AName:String;const ShowUsed: boolean = false;const Local: boolean = false):string;
var
  P : TFPPackage;
begin
  P:=InstalledRepository.FindPackage(AName);
  if P<>nil then
    begin
      if not ShowUsed then
        result:=P.Version.AsString
      else if Local=p.InstalledLocally then
        result:=P.Version.AsString
      else if not P.UnusedVersion.Empty then
        result:=P.UnusedVersion.AsString
      else
        result:='-';
    end
  else
    result:='-';
end;


function PackageInstalledStateStr(const AName:String):string;
var
  P : TFPPackage;
begin
  result := '';
  P:=InstalledRepository.FindPackage(AName);
  if (P<>nil) and PackageIsBroken(P) then
    result:='B';
end;


procedure ListAvailablePackages;
var
  InstalledP,
  AvailP : TFPPackage;
  i : integer;
  SL : TStringList;
begin
  SL:=TStringList.Create;
  SL.Sorted:=true;
  for i:=0 to AvailableRepository.PackageCount-1 do
    begin
      AvailP:=AvailableRepository.Packages[i];
      InstalledP:=InstalledRepository.FindPackage(AvailP.Name);
      if not assigned(InstalledP) or
         (AvailP.Version.CompareVersion(InstalledP.Version)>0) then
        SL.Add(Format('%-20s %-12s %-12s',[AvailP.Name,PackageInstalledVersionStr(AvailP.Name),AvailP.Version.AsString]));
    end;
  Writeln(Format('%-20s %-12s %-12s',['Name','Installed','Available']));
  for i:=0 to SL.Count-1 do
    Writeln(SL[i]);
  FreeAndNil(SL);
end;


procedure ListPackages(const ShowGlobalAndLocal: boolean);
var
  i : integer;
  SL : TStringList;
  PackageName : String;
begin
  SL:=TStringList.Create;
  SL.Sorted:=true;
  SL.Duplicates:=dupIgnore;
  for i:=0 to AvailableRepository.PackageCount-1 do
    SL.Add(AvailableRepository.Packages[i].Name);
  for i:=0 to InstalledRepository.PackageCount-1 do
    SL.Add(InstalledRepository.Packages[i].Name);
  if ShowGlobalAndLocal then
    Writeln(Format('%-20s %-14s %-14s %-3s %-12s',['Name','Installed (G)','Installed (L)','','Available']))
  else
    Writeln(Format('%-20s %-12s %-3s %-12s',['Name','Installed','','Available']));
  for i:=0 to SL.Count-1 do
    begin
      PackageName:=SL[i];
      if (PackageName<>CmdLinePackageName) and (PackageName<>CurrentDirPackageName) then
        begin
          if ShowGlobalAndLocal then
            Writeln(Format('%-20s %-14s %-14s %-3s %-12s',[PackageName,PackageInstalledVersionStr(PackageName,True,False),PackageInstalledVersionStr(PackageName,True,True),PackageInstalledStateStr(PackageName),PackageAvailableVersionStr(PackageName)]))
          else
            Writeln(Format('%-20s %-12s %-3s %-12s',[PackageName,PackageInstalledVersionStr(PackageName),PackageInstalledStateStr(PackageName),PackageAvailableVersionStr(PackageName)]));
        end;
    end;
  FreeAndNil(SL);
end;


{*****************************************************************************
                           Remote Repository
*****************************************************************************}


procedure ListRemoteRepository;
var
  P : TFPPackage;
  i : integer;
  SL : TStringList;
begin
  SL:=TStringList.Create;
  SL.Sorted:=true;
  for i:=0 to InstalledRepository.PackageCount-1 do
    begin
      P:=InstalledRepository.Packages[i];
      SL.Add(Format('%-20s %-12s %-20s',[P.Name,P.Version.AsString,P.FileName]));
    end;
  Writeln(Format('%-20s %-12s %-20s',['Name','Available','FileName']));
  for i:=0 to SL.Count-1 do
    Writeln(SL[i]);
  FreeAndNil(SL);
end;


procedure RebuildRemoteRepository;

  procedure LoadPackageManifest(const AManifestFN:string);
  var
    X : TFPXMLRepositoryHandler;
    i : integer;
    DoAdd : Boolean;
    P,NewP : TFPPackage;
    NewPackages : TFPPackages;
  begin
    NewPackages:=TFPPackages.Create(TFPPackage);
    X:=TFPXMLRepositoryHandler.Create;
    try
      X.LoadFromXml(NewPackages,AManifestFN);
      // Update or Add packages to repository
      for i:=0 to NewPackages.Count-1 do
        begin
          NewP:=NewPackages[i];
          DoAdd:=True;
          P:=InstalledRepository.FindPackage(NewP.Name);
          if assigned(P) then
            begin
              if NewP.Version.CompareVersion(P.Version)<0 then
                begin
                  Writeln(Format('Ignoring package %s-%s (old %s)',[NewP.Name,NewP.Version.AsString,P.Version.AsString]));
                  DoAdd:=False;
                end
              else
                Writeln(Format('Updating package %s-%s (old %s)',[NewP.Name,NewP.Version.AsString,P.Version.AsString]));
            end
          else
            P:=InstalledRepository.PackageCollection.AddPackage(NewP.Name);
          // Copy contents
          if DoAdd then
            P.Assign(NewP);
        end;
    finally
      X.Free;
      NewPackages.Free;
    end;
  end;

var
  i : integer;
  ArchiveSL : TStringList;
  ManifestSL : TStringList;
begin
  if assigned(InstalledRepository) then
    InstalledRepository.Free;
  InstalledRepository:=TFPRepository.Create(Nil);
  try
    ManifestSL:=TStringList.Create;
    ManifestSL.Add(ManifestFileName);
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
            Log(vlCommands,SLogUnzippping,[ArchiveSL[i]]);
            OutputPath:='.';
            UnZipFiles(ArchiveSL[i],ManifestSL);
          Finally
            Free;
          end;
        { Load manifest.xml }
        if FileExists(ManifestFileName) then
          begin
            LoadPackageManifest(ManifestFileName);
            DeleteFile(ManifestFileName);
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
      SaveToXml(InstalledRepository,'packages.xml');
    finally
      Free;
    end;
end;

end.
