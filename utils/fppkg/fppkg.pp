program fppkg;

{$mode objfpc}{$H+}

{$if defined(VER2_2) and (FPC_PATCH<1)}
  {$fatal At least FPC 2.2.1 is required to compile fppkg}
{$endif}

uses
  // General
{$ifdef unix}
  baseunix,
{$endif}
  Classes, SysUtils, TypInfo, custapp,
  // Repository handler objects
  fprepos, fpxmlrep,
  pkgmessages, pkgglobals, pkgoptions, pkgrepos,
  // Package Handler components
  pkghandler,pkgmkconv, pkgdownload,
  pkgfpmake, pkgcommands
  // Downloaders
{$if defined(unix) or defined(windows)}
  ,pkgwget
  ,pkglnet
{$endif}
  ;

Type
  { TMakeTool }

  TMakeTool = Class(TCustomApplication)
  Private
    ParaAction   : string;
    ParaPackages : TStringList;
    procedure MaybeCreateLocalDirs;
    procedure ShowUsage;
  Public
    Constructor Create;
    Destructor Destroy;override;
    Procedure LoadGlobalDefaults;
    Procedure LoadCompilerDefaults;
    Procedure ProcessCommandLine;
    Procedure DoRun; Override;
  end;

  EMakeToolError = Class(Exception);


{ TMakeTool }

procedure TMakeTool.LoadGlobalDefaults;
var
  i : integer;
  cfgfile : String;
  GeneratedConfig,
  UseGlobalConfig : boolean;
begin
  // Default verbosity
  LogLevels:=DefaultLogLevels;
  for i:=1 to ParamCount do
    if (ParamStr(i)='-d') or (ParamStr(i)='--debug') then
      begin
        LogLevels:=AllLogLevels+[vlDebug];
        break;
      end;
  GeneratedConfig:=false;
  UseGlobalConfig:=false;
  // First try config file from command line
  if HasOption('C','config-file') then
    begin
      cfgfile:=GetOptionValue('C','config-file');
      if not FileExists(cfgfile) then
        Error(SErrNoSuchFile,[cfgfile]);
    end
  else
    begin
      // Now try if a local config-file exists
      cfgfile:=GetAppConfigFile(False,False);
      if not FileExists(cfgfile) then
        begin
          // If not, try to find a global configuration file
          cfgfile:=GetAppConfigFile(True,False);
          if FileExists(cfgfile) then
            UseGlobalConfig := true
          else
            begin
              // Create a new configuration file
              if not IsSuperUser then // Make a local, not global, configuration file
                cfgfile:=GetAppConfigFile(False,False);
              ForceDirectories(ExtractFilePath(cfgfile));
              GlobalOptions.SaveGlobalToFile(cfgfile);
              GeneratedConfig:=true;
            end;
        end;
    end;
  // Load file or create new default configuration
  if not GeneratedConfig then
    begin
      GlobalOptions.LoadGlobalFromFile(cfgfile);
      if GlobalOptions.Dirty and (not UseGlobalConfig or IsSuperUser) then
        GlobalOptions.SaveGlobalToFile(cfgfile);
    end;
  GlobalOptions.CompilerConfig:=GlobalOptions.DefaultCompilerConfig;
  // Tracing of what we've done above, need to be done after the verbosity is set
  if GeneratedConfig then
    pkgglobals.Log(vlDebug,SLogGeneratingGlobalConfig,[cfgfile])
  else
    pkgglobals.Log(vlDebug,SLogLoadingGlobalConfig,[cfgfile]);
  // Log configuration
  GlobalOptions.LogValues;
end;


procedure TMakeTool.MaybeCreateLocalDirs;
begin
  ForceDirectories(GlobalOptions.BuildDir);
  ForceDirectories(GlobalOptions.ArchivesDir);
  ForceDirectories(GlobalOptions.CompilerConfigDir);
end;


procedure TMakeTool.LoadCompilerDefaults;
var
  S : String;
begin
  // Load default compiler config
  S:=GlobalOptions.CompilerConfigDir+GlobalOptions.CompilerConfig;
  CompilerOptions.UpdateLocalRepositoryOption;
  if FileExists(S) then
    begin
      pkgglobals.Log(vlDebug,SLogLoadingCompilerConfig,[S]);
      CompilerOptions.LoadCompilerFromFile(S)
    end
  else
    begin
      // Generate a default configuration if it doesn't exists
      if GlobalOptions.CompilerConfig='default' then
        begin
          pkgglobals.Log(vlDebug,SLogGeneratingCompilerConfig,[S]);
          CompilerOptions.InitCompilerDefaults;
          CompilerOptions.SaveCompilerToFile(S);
          if CompilerOptions.Dirty then
            CompilerOptions.SaveCompilerToFile(S);
        end
      else
        Error(SErrMissingCompilerConfig,[S]);
    end;
  // Log compiler configuration
  CompilerOptions.LogValues('');
  // Load FPMake compiler config, this is normally the same config as above
  S:=GlobalOptions.CompilerConfigDir+GlobalOptions.FPMakeCompilerConfig;
  FPMakeCompilerOptions.UpdateLocalRepositoryOption;
  if FileExists(S) then
    begin
      pkgglobals.Log(vlDebug,SLogLoadingFPMakeCompilerConfig,[S]);
      FPMakeCompilerOptions.LoadCompilerFromFile(S);
      if FPMakeCompilerOptions.Dirty then
        FPMakeCompilerOptions.SaveCompilerToFile(S);
    end
  else
    Error(SErrMissingCompilerConfig,[S]);
  // Log compiler configuration
  FPMakeCompilerOptions.LogValues('fpmake-building ');
end;


procedure TMakeTool.ShowUsage;
begin
  Writeln('Usage: ',Paramstr(0),' [options] <action> <package>');
  Writeln('Options:');
  Writeln('  -c --config        Set compiler configuration to use');
  Writeln('  -h --help          This help');
  Writeln('  -v --verbose       Show more information');
  Writeln('  -d --debug         Show debugging information');
  Writeln('  -g --global        Force installation to global (system-wide) directory');
  Writeln('  -f --force         Force installation also if the package is already installed');
  Writeln('  -r --recovery      Recovery mode, use always internal fpmkunit');
  Writeln('  -b --broken        Do not stop on broken packages');
  Writeln('  -l --showlocation  Show if the packages are installed globally or locally');
  Writeln('  -o --options=value Pass extra options to the compiler');
  Writeln('Actions:');
  Writeln('  update            Update packages list');
  Writeln('  list              List available and installed packages');
  Writeln('  build             Build package');
  Writeln('  compile           Compile package');
  Writeln('  install           Install package');
  Writeln('  clean             Clean package');
  Writeln('  archive           Create archive of package');
  Writeln('  download          Download package');
  Writeln('  convertmk         Convert Makefile.fpc to fpmake.pp');
  Writeln('  fixbroken         Recompile all (broken) packages with changed dependencies');
//  Writeln('  addconfig          Add a compiler configuration for the supplied compiler');
  Halt(0);
end;

Constructor TMakeTool.Create;
begin
  inherited Create(nil);
  ParaPackages:=TStringList.Create;
end;


Destructor TMakeTool.Destroy;
begin
  FreeAndNil(ParaPackages);
  inherited Destroy;
end;


procedure TMakeTool.ProcessCommandLine;

  Function CheckOption(Index : Integer;Short,Long : String): Boolean;
  var
    O : String;
  begin
    O:=Paramstr(Index);
    Result:=(O='-'+short) or (O='--'+long) or (copy(O,1,Length(Long)+3)=('--'+long+'='));
  end;

  Function OptionArg(Var Index : Integer) : String;
  Var
    P : Integer;
  begin
    if (Length(ParamStr(Index))>1) and (Paramstr(Index)[2]<>'-') then
      begin
        If Index<ParamCount then
          begin
            Inc(Index);
            Result:=Paramstr(Index);
          end
        else
          Error(SErrNeedArgument,[Index,ParamStr(Index)]);
      end
    else If length(ParamStr(Index))>2 then
      begin
        P:=Pos('=',Paramstr(Index));
        If (P=0) then
          Error(SErrNeedArgument,[Index,ParamStr(Index)])
        else
          begin
            Result:=Paramstr(Index);
            Delete(Result,1,P);
          end;
      end;
  end;

  function SplitSpaces(var SplitString: string) : string;
  var i : integer;
  begin
    i := pos(' ',SplitString);
    if i > 0 then
      begin
        result := copy(SplitString,1,i-1);
        delete(SplitString,1,i);
      end
    else
      begin
        result := SplitString;
        SplitString:='';
      end;
  end;

Var
  I : Integer;
  HasAction : Boolean;
  OptString : String;
begin
  I:=0;
  HasAction:=false;
  // We can't use the TCustomApplication option handling,
  // because they cannot handle [general opts] [command] [cmd-opts] [args]
  While (I<ParamCount) do
    begin
      Inc(I);
      // Check options.
      if CheckOption(I,'c','config') then
        GlobalOptions.CompilerConfig:=OptionArg(I)
      else if CheckOption(I,'v','verbose') then
        LogLevels:=AllLogLevels
      else if CheckOption(I,'d','debug') then
        LogLevels:=AllLogLevels+[vlDebug]
      else if CheckOption(I,'g','global') then
        GlobalOptions.InstallGlobal:=true
      else if CheckOption(I,'r','recovery') then
        GlobalOptions.RecoveryMode:=true
      else if CheckOption(I,'b','broken') then
        GlobalOptions.AllowBroken:=true
      else if CheckOption(I,'l','showlocation') then
        GlobalOptions.ShowLocation:=true
      else if CheckOption(I,'o','options') then
        begin
          OptString := OptionArg(I);
          while OptString <> '' do
            CompilerOptions.Options.Add(SplitSpaces(OptString));
        end
      else if CheckOption(I,'h','help') then
        begin
          ShowUsage;
          halt(0);
        end
      else if (Length(Paramstr(i))>0) and (Paramstr(I)[1]='-') then
        Raise EMakeToolError.CreateFmt(SErrInvalidArgument,[I,ParamStr(i)])
      else
      // It's a command or target.
        begin
          if HasAction then
            ParaPackages.Add(Paramstr(i))
          else
            begin
              ParaAction:=Paramstr(i);
              HasAction:=true;
            end;
        end;
    end;
  if not HasAction then
    ShowUsage;
end;


procedure TMakeTool.DoRun;
var
  ActionPackage : TFPPackage;
  OldCurrDir : String;
  i      : Integer;
  SL     : TStringList;
begin
  OldCurrDir:=GetCurrentDir;
  Try
    LoadGlobalDefaults;
    ProcessCommandLine;

    // Scan is special, it doesn't need a valid local setup
    if (ParaAction='scan') then
      begin
        RebuildRemoteRepository;
        ListRemoteRepository;
        SaveRemoteRepository;
        halt(0);
      end;

    MaybeCreateLocalDirs;
    LoadCompilerDefaults;
    LoadLocalAvailableMirrors;

    // Load local repository, update first if this is a new installation
    // errors will only be reported as warning. The user can be bootstrapping
    // and do an update later
    if not FileExists(GlobalOptions.LocalPackagesFile) then
      begin
        try
          pkghandler.ExecuteAction('','update');
        except
          on E: Exception do
            pkgglobals.Log(vlWarning,E.Message);
        end;
      end;
    LoadLocalAvailableRepository;
    FindInstalledPackages(FPMakeCompilerOptions,true);
    CheckFPMakeDependencies;
    // We only need to reload the status when we use a different
    // configuration for compiling fpmake
    if GlobalOptions.CompilerConfig<>GlobalOptions.FPMakeCompilerConfig then
      FindInstalledPackages(CompilerOptions,true);

    // Check for broken dependencies
    if not GlobalOptions.AllowBroken and
       (((ParaAction='fixbroken') and (ParaPackages.Count>0)) or
        (ParaAction='compile') or
        (ParaAction='build') or
        (ParaAction='install') or
        (ParaAction='archive')) then
      begin
        pkgglobals.Log(vlDebug,SLogCheckBrokenDependenvies);
        SL:=TStringList.Create;
        if FindBrokenPackages(SL) then
          Error(SErrBrokenPackagesFound);
        FreeAndNil(SL);
      end;

    if ParaPackages.Count=0 then
      begin
        ActionPackage:=AvailableRepository.AddPackage(CurrentDirPackageName);
        pkghandler.ExecuteAction(CurrentDirPackageName,ParaAction);
      end
    else
      begin
        // Process packages
        for i:=0 to ParaPackages.Count-1 do
          begin
            if sametext(ExtractFileExt(ParaPackages[i]),'.zip') and FileExists(ParaPackages[i]) then
              begin
                ActionPackage:=AvailableRepository.AddPackage(CmdLinePackageName);
                ActionPackage.LocalFileName:=ExpandFileName(ParaPackages[i]);
                pkghandler.ExecuteAction(CmdLinePackageName,ParaAction);
              end
            else
              begin
                pkgglobals.Log(vlDebug,SLogCommandLineAction,['['+ParaPackages[i]+']',ParaAction]);
                pkghandler.ExecuteAction(ParaPackages[i],ParaAction);
              end;
          end;
      end;

    // Recompile all packages dependent on this package
    if (ParaAction='install') then
      pkghandler.ExecuteAction('','fixbroken');

    Terminate;

  except
    On E : Exception do
      begin
        Writeln(StdErr,SErrException);
        Writeln(StdErr,E.Message);
        Halt(1);
      end;
  end;
  SetCurrentDir(OldCurrDir);
end;


begin
  With TMakeTool.Create do
    try
      run;
    finally
      Free;
    end;
end.

