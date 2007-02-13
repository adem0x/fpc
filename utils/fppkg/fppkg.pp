program fppkg;

{$mode objfpc}{$H+}

uses
  // General
{$ifdef unix}
  baseunix,
{$endif}
  Classes, SysUtils, TypInfo, custapp,
  // Repository handler objects
  fprepos, fpxmlrep,
  pkgmessages, pkgglobals, pkgoptions,
  // Package Handler components
  pkghandler,pkgmkconv, pkgdownload,
  pkgarchive, pkgfpmake, pkgcommands
  // Downloaders
{$if defined(unix) or defined(windows)}
  ,pkgwget
{$endif}
  ;

Type
  { TMakeTool }

  TMakeTool = Class(TCustomApplication)
  Private
    ActionStack : TActionStack;
    ParaAction : string;
    ParaPackages : TStringList;
    FRepository : TFPRepository;
    FCompilerConfig : String;
    procedure GenerateParaActions;
    procedure LoadRepository;
    procedure MaybeCreateLocalDirs;
    procedure ShowUsage;
  Public
    Constructor Create;
    Destructor Destroy;override;
    Function GetConfigFileName : String;
    Procedure LoadGlobalDefaults;
    Procedure LoadCompilerDefaults;
    Procedure ProcessCommandLine;
    Procedure DoRun; Override;
  end;

  EMakeToolError = Class(Exception);


{ TMakeTool }

function TMakeTool.GetConfigFileName: String;
var
  G : Boolean;
begin
  if HasOption('C','config-file') then
    Result:=GetOptionValue('C','config-file')
  else
    begin
{$ifdef unix}
      g:=(fpgetuid=0);
{$else}
      g:=true;
{$endif}
      Result:=GetAppConfigFile(G,False);
    end
end;


procedure TMakeTool.LoadGlobalDefaults;
var
  SL : TStringList;
  i : integer;
  cfgfile : String;
  GeneratedConfig : boolean;
begin
  cfgfile:=GetConfigFileName;
  GeneratedConfig:=false;
  // Load file or create new default configuration
  if FileExists(cfgfile) then
    Defaults.LoadGlobalFromFile(cfgfile)
  else
    begin
      ForceDirectories(ExtractFilePath(cfgfile));
      Defaults.SaveGlobalToFile(cfgfile);
      GeneratedConfig:=true;
    end;
  // Load default verbosity from config
  SL:=TStringList.Create;
  SL.CommaText:=Defaults.DefaultVerbosity;
  for i:=0 to SL.Count-1 do
    Include(Verbosity,StringToVerbosity(SL[i]));
  SL.Free;
  FCompilerConfig:=Defaults.DefaultCompilerConfig;
  // Tracing of what we've done above, need to be done after the verbosity is set
  if GeneratedConfig then
    Log(vDebug,SLogGeneratingGlobalConfig,[cfgfile])
  else
    Log(vDebug,SLogLoadingGlobalConfig,[cfgfile])
end;


procedure TMakeTool.MaybeCreateLocalDirs;
begin
  ForceDirectories(Defaults.BuildDir);
  ForceDirectories(Defaults.PackagesDir);
  ForceDirectories(Defaults.CompilerConfigDir);
end;


procedure TMakeTool.LoadCompilerDefaults;
var
  S : String;
begin
  S:=Defaults.CompilerConfigDir+FCompilerConfig;
  if FileExists(S) then
    begin
      Log(vDebug,SLogLoadingCompilerConfig,[S]);
      Defaults.LoadCompilerFromFile(S)
    end
  else
    begin
      Log(vDebug,SLogGeneratingCompilerConfig,[S]);
      Defaults.InitCompilerDefaults;
      Defaults.SaveCompilerToFile(S);
    end;
end;


procedure TMakeTool.LoadRepository;
var
  S : String;
  X : TFPXMLRepositoryHandler;
begin
  FRepository:=TFPRepository.Create(Nil);
  // Repository
  Log(vDebug,SLogLoadingRepository,[Defaults.LocalRepository]);
  if FileExists(Defaults.LocalRepository) then
    begin
      X:=TFPXMLRepositoryHandler.Create;
      With X do
        try
          LoadFromXml(FRepository,Defaults.LocalRepository);
        finally
          Free;
        end;
    end;
  // Versions
  S:=Defaults.LocalVersions(FCompilerConfig);
  Log(vDebug,SLogLoadingVersions,[S]);
  if FileExists(S) then
    FRepository.LoadStatusFromFile(S);
end;


procedure TMakeTool.ShowUsage;
begin
  Writeln('Usage: ',Paramstr(0),' [options] <action> <package>');
  Writeln('Options:');
  Writeln('  -c --config        Set compiler configuration to use');
  Writeln('  -h --help          This help');
  Writeln('  -v --verbose       Set verbosity');
  Writeln('Actions:');
  Writeln('  update             Update available packages');
  Writeln('  listpackages       List available packages');
  Writeln('  build              Build package');
  Writeln('  install            Install package');
  Writeln('  download           Download package');
  Writeln('  convertmk          Convert Makefile.fpc to fpmake.pp');
  Halt(0);
end;

Constructor TMakeTool.Create;
begin
  inherited Create(nil);
  ParaPackages:=TStringList.Create;
  ActionStack:=TActionStack.Create;
end;


Destructor TMakeTool.Destroy;
begin
  FreeAndNil(ActionStack);
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

Var
  I : Integer;
  HasAction : Boolean;
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
        FCompilerConfig:=OptionArg(I)
      else if CheckOption(I,'v','verbose') then
        Include(Verbosity,StringToVerbosity(OptionArg(I)))
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


procedure TMakeTool.GenerateParaActions;
var
  ActionPackage : TFPPackage;
  i : integer;
begin
  if GetPkgHandler(ParaAction)<>nil then
    begin
      if ParaPackages.Count=0 then
        begin
          Log(vDebug,SLogCommandLineAction,['[<currentdir>]',ParaAction]);
          ActionStack.Push(nil,ParaAction,[]);
        end
      else
        begin
          for i:=0 to ParaPackages.Count-1 do
            begin
              ActionPackage:=FRepository.PackageByName(ParaPackages[i]);
              Log(vDebug,SLogCommandLineAction,['['+ActionPackage.Name+']',ParaAction]);
              ActionStack.Push(ActionPackage,ParaAction,[]);
            end;
        end;
    end
  else
    Raise EMakeToolError.CreateFmt(SErrInvalidCommand,[ParaAction]);
end;


procedure TMakeTool.DoRun;
var
  Action : string;
  ActionPackage : TFPPackage;
  Args   : TActionArgs;
  OldCurrDir : String;
begin
  LoadGlobalDefaults;
  OldCurrDir:=GetCurrentDir;
  Try
    ProcessCommandLine;
    MaybeCreateLocalDirs;
    LoadCompilerDefaults;
    LoadRepository;
    GenerateParaActions;

    repeat
      if not ActionStack.Pop(ActionPackage,Action,Args) then
        break;
      pkghandler.ExecuteAction(ActionPackage,Action,Args);
    until false;
    Terminate;

  except
    On E : Exception do
      begin
        Writeln(StdErr,SErrRunning);
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

