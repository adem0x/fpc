{
    This file is part of the Free Pascal Makefile Package

    Implementation of fpmake classes and functions

    Copyright (c) 2007 by the freepascal team

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit fpmkunit;

{$Mode objfpc}
{$H+}

Interface

{$ifndef NO_UNIT_PROCESS}
  {$define HAS_UNIT_PROCESS}
{$endif NO_UNIT_PROCESS}

{$ifndef NO_UNIT_ZIPPER}
  {$define HAS_UNIT_ZIPPER}
{$endif NO_UNIT_ZIPPER}

uses
  SysUtils, Classes, StrUtils
{$ifdef HAS_UNIT_PROCESS}
  ,process
{$endif HAS_UNIT_PROCESS}
{$ifdef HAS_UNIT_ZIPPER}
  ,zipper
{$endif HAS_UNIT_ZIPPER}
  ;

Type
  TFileType = (ftSource,ftUnit,ftObject,ftResource,ftExecutable,ftStaticLibrary,
               ftSharedLibrary);
  TFileTypes = set of TFileType;

  TOS = (osNone,Amiga,Atari,Darwin,FreeBSD,Go32v2,Linux,MacOS,MorphOS,NetBSD,
         Netware,NetwLibc,OpenBSD,OS2,PalmOS,Solaris,Win32,Win64,WinCE,Emx);
  TOSes = Set of TOS;

  TCPU = (cpuNone,Arm,I386,PPC,SPARC,X86_64,M68K,PPC64);
  TCPUS = Set of TCPU;

  TCompilerMode = (cmFPC,cmTP,cmObjFPC,cmDelphi,cmMacPas);
  TCompilerModes = Set of TCompilerMode;

  TTargetType = (ttProgram,ttUnit,ttImplicitUnit,ttCleanOnlyUnit,ttExampleUnit,ttExampleProgram);
  TTargetTypes = set of TTargetType;

  TTargetState = (tsNeutral,tsCompiling,tsCompiled,tsInstalled);
  TTargetStates = Set of TTargetState;

  TSourceType = (stDoc,stSrc,stExample,stTest);
  TSourceTypes = set of TSourceType;

  TVerboseLevel = (vlError,vlWarning,vlInfo,vlCompare,vlCommand,vldebug);
  TVerboseLevels = Set of TVerboseLevel;

  TCommandAt = (caBeforeCompile,caAfterCompile,
                caBeforeInstall,caAfterInstall,
                caBeforeArchive,caAfterArchive,
                caBeforeClean,caAfterClean,
                caBeforeDownload,caAfterDownload);

  TLogEvent = Procedure (Level : TVerboseLevel; Const Msg : String) of Object;

  TRunMode = (rmCompile,rmBuild,rmInstall,rmArchive,rmClean,rmManifest,rmListSources);

Const
  // Aliases
  Amd64   = X86_64;
  PowerPC = PPC;
  PowerPC64 = PPC64;
  DOS = Go32v2;
  MacOSX = Darwin;

  AllOSs  = [Low(TOS)..High(TOS)];
  AllCPUs = [Low(TCPU)..High(TCPU)];

  // Useful
  UnitExt = '.ppu';
  PPUExt  = UnitExt;
  PasExt  = '.pas';
  PPExt   = '.pp';
  IncExt  = '.inc';
  ObjExt  = '.o';
  RstExt  = '.rst';
  LibExt  = '.a';
  SharedLibExt = '.so';
  DLLExt  = '.dll';
  ExeExt  = '.exe';
  ZipExt  = '.zip';

  ManifestFile = 'manifest.xml';

  UnitTargets = [ttUnit,ttImplicitUnit,ttCleanOnlyUnit,ttExampleUnit];
  ProgramTargets = [ttProgram,ttExampleProgram];

  AllMessages = [vlError,vlWarning,vlInfo,vlCompare,vlCommand];

Type
  { TNamedItem }

  TNamedItem = Class(TCollectionItem)
  private
    FName: String;
    procedure SetName(const AValue: String);virtual;
  Public
    property Name : String Read FName Write SetName;
  end;

  { TNamedCollection }

  TNamedCollection = Class(TCollection)
  private
    FUniqueNames: Boolean;
  Public
    Function IndexOfName(const AName : String) : Integer;
    Function ItemByName(const AName : String) : TNamedItem;
    Property UniqueNames : Boolean Read FUniqueNames;
  end;

  { TNamedItemList }

  TNamedItemList = Class(TList)
  private
    function GetNamedItem(Index : Integer): TNamedItem;
    procedure SetNamedItem(Index : Integer; const AValue: TNamedItem);
  public
    Function IndexOfName(const AName : String) : Integer;
    Function ItemByName(const ANAme : String) : TNamedItem;
    Property NamedItems[Index : Integer] : TNamedItem Read GetNamedItem Write SetNamedItem; default;
  end;

  { TCommand }
  TCommand = Class(TNamedItem)
  private
    FAfterCommand: TNotifyEvent;
    FBeforeCommand: TNotifyEvent;
    FCommand: String;
    FCommandAt: TCommandAt;
    FDestFile: String;
    FIgnoreResult: Boolean;
    FOptions: String;
    FSourceFile: String;
  Public
    Property SourceFile : String Read FSourceFile Write FSourceFile;
    Property DestFile : String Read FDestFile Write FDestFile;
    Property Command : String Read FCommand Write FCommand;
    Property Options : String Read FOptions Write FOptions;
    Property At : TCommandAt Read FCommandAt Write FCommandAt;
    Property IgnoreResult : Boolean Read FIgnoreResult Write FIgnoreResult;
    Property BeforeCommand : TNotifyEvent Read FBeforeCommand Write FBeforeCommand;
    Property AfterCommand : TNotifyEvent Read FAfterCommand Write FAfterCommand;
  end;

  { TCommands }

  TCommands = Class(TNamedCollection)
  private
    FDefaultAt: TCommandAt;
    function GetCommand(const Dest : String): TCommand;
    function GetCommandItem(Index : Integer): TCommand;
    procedure SetCommandItem(Index : Integer; const AValue: TCommand);
  Public
    Function AddCommand(Const Cmd : String) : TCommand;
    Function AddCommand(Const Cmd,Options : String) : TCommand;
    Function AddCommand(Const Cmd,Options,Dest,Source : String) : TCommand;
    Function AddCommand(At : TCommandAt; Const Cmd : String) : TCommand;
    Function AddCommand(At : TCommandAt; Const Cmd,Options : String) : TCommand;
    Function AddCommand(At : TCommandAt; Const Cmd,Options, Dest,Source : String) : TCommand;
    Property CommandItems[Index : Integer] : TCommand Read GetCommandItem Write SetCommandItem;
    Property Commands[Dest : String] : TCommand Read GetCommand; default;
    Property DefaultAt : TCommandAt Read FDefaultAt Write FDefaultAt;
  end;

  { TTarget }

  TTarget = Class(TNamedItem)
  private
    FInstall : Boolean;
    FAfterClean: TNotifyEvent;
    FAfterCompile: TNotifyEvent;
    FBeforeClean: TNotifyEvent;
    FBeforeCompile: TNotifyEvent;
    FCPUs: TCPUs;
    FMode: TCompilerMode;
    FResourceStrings: Boolean;
    FObjectPath,
    FUnitPath,
    FIncludePath,
    FDependencies: TStrings;
    FCommands : TCommands;
    FDirectory: String;
    FExtension: String;
    FFileType: TFileType;
    FOptions: String;
    FOSes: TOSes;
    FFPCTarget: String;
    FTargetState: TTargetState;
    FTargetType: TTargetType;
    function GetCommands: TCommands;
    function GetHasCommands: Boolean;
    function GetHasStrings(AIndex: integer): Boolean;
    function GetStrings(AIndex: integer): TStrings;
    procedure SetCommands(const AValue: TCommands);
    procedure SetStrings(AIndex: integer; const AValue: TStrings);
  Protected
    Function GetSourceFileName : String; virtual;
    Function GetUnitFileName : String; virtual;
    Function GetObjectFileName : String; virtual;
    Function GetRSTFileName : String; Virtual;
    Function GetProgramFileName(AnOS : TOS) : String; Virtual;
  Public
    Constructor Create(ACollection : TCollection); override;
    Destructor Destroy; override;
    Function GetOutputFileName (AOs : TOS) : String; Virtual;
    procedure SetName(const AValue: String);override;
    Procedure GetCleanFiles(List : TStrings; const APrefixU, APrefixB : String; AnOS : TOS); virtual;
    Procedure GetSourceFiles(List : TStrings; const APrefix : String; AnOS : TOS); virtual;
    Procedure GetInstallFiles(List : TStrings; const APrefixU, APrefixB: String; AnOS : TOS); virtual;
    Procedure GetArchiveFiles(List : TStrings; const APrefix : String; AnOS : TOS); virtual;
    Property HasUnitPath : Boolean Index 0 Read GetHasStrings;
    Property HasObjectPath : Boolean Index 1 Read GetHasStrings;
    Property HasIncludePath : Boolean Index 2 Read GetHasStrings;
    Property HasDependencies : Boolean Index 3 Read GetHasStrings;
    Property HasCommands : Boolean Read GetHasCommands;
    Property UnitPath : TStrings Index 0 Read GetStrings Write SetStrings;
    Property ObjectPath : TStrings Index 1  Read GetStrings Write SetStrings;
    Property IncludePath : TStrings Index 2 Read GetStrings Write SetStrings;
    Property Dependencies : TStrings Index 3 Read GetStrings Write SetStrings;
    Property Commands : TCommands Read GetCommands Write SetCommands;
    Property State : TTargetState Read FTargetState;
    Property TargetType : TTargetType Read FTargetType Write FTargetType;
    Property OS : TOSes Read FOSes Write FOSes;
    Property Mode : TCompilerMode Read FMode Write FMode;
    Property Options : String Read FOptions Write Foptions;
    Property SourceFileName: String Read GetSourceFileName ;
    Property UnitFileName : String Read GetUnitFileName;
    Property ObjectFileName : String Read GetObjectFileName;
    Property RSTFileName : String Read GetRSTFileName;
    Property CPU : TCPUs Read FCPUs Write FCPUs;
    Property FPCTarget : String Read FFPCTarget Write FFPCTarget;
    Property Extension : String Read FExtension Write FExtension;
    Property FileType : TFileType Read FFileType Write FFileType;
    Property Directory : String Read FDirectory Write FDirectory;
    Property ResourceStrings : Boolean Read FResourceStrings Write FResourceStrings;
    Property Install : Boolean Read FInstall Write FInstall;
    // Events.
    Property BeforeCompile : TNotifyEvent Read FBeforeCompile Write FBeforeCompile;
    Property AfterCompile : TNotifyEvent Read FAfterCompile Write FAfterCompile;
    Property BeforeClean : TNotifyEvent Read FBeforeClean Write FBeforeClean;
    Property AfterClean : TNotifyEvent Read FAfterClean Write FAfterClean;
  end;

  { TTargets }

  TTargets = Class(TNamedCollection)
  private
    FDefaultCPU: TCPUs;
    FDefaultDir : String;
    FDefaultOS: TOSes;
    function GetTargetItem(Index : Integer): TTarget;
    function GetTarget(const AName : String): TTarget;
    procedure SetDefaultDir(const AValue: String);
    procedure SetTargetItem(Index : Integer; const AValue: TTarget);
    Procedure ApplyDefaults(ATarget : TTarget);
  Public
    Procedure ResetDefaults;
    Function AddUnit(const AUnitName : String) : TTarget;
    Function AddImplicitUnit(const AUnitName : String;InstallUnit:boolean=true) : TTarget;
    Function AddProgram(const AProgramName : String) : TTarget;
    Function AddExampleUnit(const AUnitName : String) : TTarget;
    Function AddExampleProgram(const AProgramName : String) : TTarget;
    Property Targets[AName : String] : TTarget Read GetTarget; default;
    Property TargetItems[Index : Integer] : TTarget Read GetTargetItem Write SetTargetItem;
    Property DefaultDir : String Read FDefaultDir Write SetDefaultDir;
    Property DefaultOS : TOSes Read FDefaultOS Write FDefaultOS;
    Property DefaultCPU : TCPUs Read FDefaultCPU Write FDefaultCPU;
  end;

  { TSource }

  TSource = Class(TNamedItem)
  private
    FSourceType: TSourceType;
  Public
    Constructor Create(ACollection : TCollection); override;
    Destructor Destroy; override;
    procedure GetSourceFiles(List: TStrings);
    Property SourceType : TSourceType Read FSourceType Write FSourceType;
  end;

  { TSources }

  TSources = Class(TNamedCollection)
  private
    function GetSourceItem(Index : Integer): TSource;
    procedure SetSourceItem(Index : Integer; const AValue: TSource);
  public
    Function AddDocFiles(const AFiles : String) : TSource;
    Function AddSrcFiles(const AFiles : String) : TSource;
    Function AddExampleFiles(const AFiles : String) : TSource;
    Function AddTestFiles(const AFiles : String) : TSource;
    Property SourceItems[Index : Integer] : TSource Read GetSourceItem Write SetSourceItem;default;
  end;

  { TPackage }

  TPackage = Class(TNamedItem) // Maybe descend from/use TTarget ?
  private
    FAfterArchive: TNotifyEvent;
    FAfterClean: TNotifyEvent;
    FAfterCompile: TNotifyEvent;
    FAfterInstall: TNotifyEvent;
    FAfterManifest: TNotifyEvent;
    FBeforeArchive: TNotifyEvent;
    FBeforeClean: TNotifyEvent;
    FBeforeCompile: TNotifyEvent;
    FBeforeInstall: TNotifyEvent;
    FBeforeManifest: TNotifyEvent;
    FUnitPath,
    FObjectPath,
    FIncludePath,
    FCleanFiles,
    FArchiveFiles,
    FInstallFiles,
    FDependencies: TStrings;
    FCPU: TCPUs;
    FOS: TOses;
    FTargetState: TTargetState;
    FTargets: TTargets;
    FSources: TSources;
    FDirectory: String;
    FOptions: String;
    FFileName: String;
    FAuthor: String;
    FLicense: String;
    FExternalURL: String;
    FVersion: String;
    FEmail : String;
    FCommands : TCommands;
    FDescriptionFile : String;
    FDescription : String;
    Function GetDescription : string;
    Function GetFileName : string;
    function GetCommands: TCommands;
    function GetHasCommands: Boolean;
    function GetHasStrings(AIndex: integer): Boolean;
    function GetStrings(AIndex: integer): TStrings;
    procedure SetCommands(const AValue: TCommands);
    procedure SetStrings(AIndex: integer; const AValue: TStrings);
  Public
    constructor Create(ACollection: TCollection); override;
    destructor destroy; override;
    Function AddTarget(AName : String) : TTarget;
    Procedure AddDependency(AName : String);
    Procedure AddInstallFile(AFileName : String);
    Procedure GetCleanFiles(List : TStrings; Const APrefixU, APrefixB : String; AOS : TOS); virtual;
    procedure GetInstallFiles(List: TStrings;Types : TTargetTypes;Const APrefix, APrefixU, APrefixB: String; AOS : TOS);
    Procedure GetArchiveFiles(List : TStrings; Const APrefix : String; AOS : TOS); virtual;
    Procedure GetManifest(Manifest : TStrings);
    Property Version : String Read FVersion Write FVersion;
    Property FileName : String Read GetFileName Write FFileName;
    Property ExternalURL : String Read FExternalURL Write FExternalURL;
    Property Email : String Read FEmail Write FEmail;
    Property Author : String Read FAuthor Write FAuthor;
    Property License : String Read FLicense Write FLicense;
    Property Directory : String Read FDirectory Write FDirectory;
    Property Description : String Read GetDescription Write FDescription;
    Property DescriptionFile : String Read FDescriptionFile Write FDescriptionFile;
    // Compiler options.
    Property OS : TOses Read FOS Write FOS;
    Property CPU : TCPUs Read FCPU Write FCPU;
    Property Options: String Read FOptions Write FOptions;
    Property HasUnitPath : Boolean Index 0 Read GetHasStrings;
    Property HasObjectPath : Boolean Index 1 Read GetHasStrings;
    Property HasIncludePath : Boolean Index 2 Read GetHasStrings;
    Property HasDependencies : Boolean Index 3 Read GetHasStrings;
    Property HasInstallFiles: Boolean Index 4 Read GetHasStrings;
    Property HasCleanFiles : Boolean Index 5 Read GetHasStrings;
    Property HasArchiveFiles : Boolean Index 6 Read GetHasStrings;
    Property HasCommands : Boolean Read GetHasCommands;
    Property UnitPath : TStrings Index 0 Read GetStrings Write SetStrings;
    Property ObjectPath : TStrings Index 1  Read GetStrings Write SetStrings;
    Property IncludePath : TStrings Index 2 Read GetStrings Write SetStrings;
    // Targets and dependencies
    Property Dependencies : TStrings Index 3 Read GetStrings Write SetStrings;
    Property InstallFiles : TStrings Index 4 Read GetStrings Write SetStrings;
    Property CleanFiles : TStrings Index 5 Read GetStrings Write SetStrings;
    Property ArchiveFiles : TStrings Index 6 Read GetStrings Write SetStrings;
    Property Commands : TCommands Read GetCommands Write SetCommands;
    Property State : TTargetState Read FTargetState;
    Property Targets : TTargets Read FTargets;
    Property Sources : TSources Read FSources;
    // events
    Property BeforeCompile : TNotifyEvent Read FBeforeCompile Write FBeforeCompile;
    Property AfterCompile : TNotifyEvent Read FAfterCompile Write FAfterCompile;
    Property BeforeInstall : TNotifyEvent Read FBeforeInstall Write FBeforeInstall;
    Property AfterInstall : TNotifyEvent Read FAfterInstall Write FAfterInstall;
    Property BeforeClean : TNotifyEvent Read FBeforeClean Write FBeforeClean;
    Property AfterClean : TNotifyEvent Read FAfterClean Write FAfterClean;
    Property BeforeArchive : TNotifyEvent Read FBeforeArchive Write FBeforeArchive;
    Property AfterArchive : TNotifyEvent Read FAfterArchive Write FAfterArchive;
    Property BeforeManifest : TNotifyEvent Read FBeforeManifest Write FBeforeManifest;
    Property AfterManifest : TNotifyEvent Read FAfterManifest Write FAfterManifest;
  end;

  { TPackages }

  TPackages = Class(TNamedCollection)
  private
    function GetPackage(const AName : String): TPackage;
    function GetPackageItem(AIndex : Integer): TPackage;
    procedure SetPackageItem(AIndex : Integer; const AValue: TPackage);
  Public
    Function AddPackage(Const AName : String) : TPackage;
    Property Packages[AName : String] : TPackage Read GetPackage ; Default;
    Property PackageItems[AIndex : Integer] : TPackage Read GetPackageItem Write SetPackageItem;
  end;

  { TCustomDefaults }

  TCustomDefaults = Class(TPersistent)
  Private
    FArchive: String;
    FCompiler: String;
    FCopy: String;
    FMkDir: String;
    FMove: String;
    FOptions: String;
    FCPU: TCPU;
    FOS: TOS;
    FMode : TCompilerMode;
    FCompilerVersion : String;
    FPrefix: String;
    FLocalUnitDir,
    FGlobalUnitDir,
    FBaseInstallDir,
    FUnitInstallDir,
    FBinInstallDir,
    FDocInstallDir,
    FExamplesInstallDir : String;
    FRemove: String;
    FTarget: String;
    FUnixPaths: Boolean;
    FSourceExt : String;
    function GetLocalUnitDir: String;
    function GetGlobalUnitDir: String;
    function GetBaseInstallDir: String;
    function GetBinInstallDir: String;
    function GetCompiler: String;
    function GetDocInstallDir: String;
    function GetExamplesInstallDir: String;
    function GetUnitInstallDir: String;
    procedure SetBaseInstallDir(const AValue: String);
    procedure SetCPU(const AValue: TCPU);
    procedure SetOS(const AValue: TOS);
    procedure SetPrefix(const AValue: String);
    procedure SetTarget(const AValue: String);
  Protected
    procedure RecalcTarget;
  Public
    Constructor Create;
    Procedure InitDefaults;
    Procedure Assign(ASource : TPersistent);override;
    procedure CompilerDefaults; virtual;
    Procedure LocalInit(Const AFileName : String);
    Procedure LoadFromFile(Const AFileName : String);
    Procedure SaveToFile(Const AFileName : String);
    procedure SaveToStream(S : TStream);virtual;
    procedure LoadFromStream(S : TStream);virtual;
    // Compile Information
    Property Target : String Read FTarget Write SetTarget;
    Property OS : TOS Read FOS Write SetOS;
    Property CPU : TCPU Read FCPU Write SetCPU;
    Property Mode : TCompilerMode Read FMode Write FMode;
    Property UnixPaths : Boolean Read FUnixPaths Write FUnixPaths;
    Property Options : String Read FOptions Write FOptions;    // Default compiler options.
    Property SourceExt : String Read FSourceExt Write FSourceExt;
    // paths etc.
    Property LocalUnitDir : String Read GetLocalUnitDir Write FLocalUnitDir;
    Property GlobalUnitDir : String Read GetGlobalUnitDir Write FGlobalUnitDir;
    Property Prefix : String Read FPrefix Write SetPrefix;
    Property BaseInstallDir : String Read GetBaseInstallDir Write SetBaseInstallDir;
    Property UnitInstallDir : String Read GetUnitInstallDir Write FUnitInstallDir;
    Property BinInstallDir : String Read GetBinInstallDir Write FBinInstallDir;
    Property DocInstallDir : String Read GetDocInstallDir Write FDocInstallDir;
    Property ExamplesInstallDir : String Read GetExamplesInstallDir Write FExamplesInstallDir;
    // Command tools. If not set, internal commands  will be used.
    Property Compiler : String Read GetCompiler Write FCompiler; // Compiler. Defaults to fpc
    Property Copy : String Read FCopy Write FCopy;             // copy $(FILES) to $(DEST)
    Property Move : String Read FMove Write FMove;             // Move $(FILES) to $(DEST)
    Property Remove : String Read FRemove Write FRemove;       // Delete $(FILES)
    Property MkDir : String Read FMkDir write FMkDir;          // Make $(DIRECTORY)
    Property Archive : String Read FArchive Write FArchive;    // zip $(ARCHIVE) $(FILESORDIRS)
  end;

  { TBasicDefaults }

  TBasicDefaults = Class(TCustomDefaults)
  end;

  { TFPCDefaults }

  TFPCDefaults = Class(TCustomDefaults)
  public
    procedure CompilerDefaults; override;
  end;

  { TBuildEngine }

  TBuildEngine = Class(TComponent)
  private
    // general variables
    FCompiler : String;
    FStartDir : String;
    FTargetDir : String;
    FDefaults : TCustomDefaults;
    FForceCompile : Boolean;
    FListMode : Boolean;
{$ifdef HAS_UNIT_ZIPPER}
    FZipFile: TZipper;
{$endif HAS_UNIT_ZIPPER}
    // Variables used when compiling a package.
    // Only valid during compilation of the package.
    FCurrentOutputDir : String;
    FCurrentPackage: TPackage;
    // Events
    FOnLog: TLogEvent;
    FAfterArchive: TNotifyEvent;
    FAfterClean: TNotifyEvent;
    FAfterCompile: TNotifyEvent;
    FAfterInstall: TNotifyEvent;
    FAfterManifest: TNotifyEvent;
    FBeforeArchive: TNotifyEvent;
    FBeforeClean: TNotifyEvent;
    FBeforeCompile: TNotifyEvent;
    FBeforeInstall: TNotifyEvent;
    FBeforeManifest: TNotifyEvent;
    procedure SetDefaults(const AValue: TCustomDefaults);
    procedure SetTargetDir(const AValue: String);
  Protected
    Procedure Error(const Msg : String);
    Procedure Error(const Fmt : String; Args : Array of const);
    // Internal copy/delete/move/archive/mkdir files
    Procedure SysCopyFile(Const Src,Dest : String); virtual;
    Procedure SysMoveFile(Const Src,Dest : String); virtual;
    Procedure SysDeleteFile(Const AFileName : String); virtual;
    Procedure SysArchiveFiles(List : TStrings; Const AFileName : String); virtual;
    Procedure Log(Level : TVerboseLevel; Const Msg : String);
    Procedure Log(Level : TVerboseLevel; Const Fmt : String; Args : Array Of Const);
    Procedure EnterDir(ADir : String);
    Function GetCompiler : String;
    Procedure InstallPackageFiles(APAckage : TPackage; tt : TTargetType; Const Src,Dest : String); virtual;
    Function FileNewer(const Src,Dest : String) : Boolean;

    //package commands
    Function  GetOutputDir(AName: string; APackage : TPackage; AbsolutePath : Boolean = False) : String;

  Public
    Constructor Create(AOwner : TComponent); override;
    // Public Copy/delete/Move/Archive/Mkdir Commands.
    Procedure ExecuteCommand(const Cmd,Args : String; IgnoreError : Boolean = False); virtual;
    Procedure CmdCopyFiles(List : TStrings; Const DestDir : String);
    Procedure CmdCreateDir(const DestDir : String);
    Procedure CmdMoveFiles(List : TStrings; Const DestDir : String);
    Procedure CmdDeleteFiles(List : TStrings);
    Procedure CmdArchiveFiles(List : TStrings; Const ArchiveFile : String);
    Procedure ExecuteCommands(Commands : TCommands; At : TCommandAt);
    // Target commands
    Function  GetTargetDir(APackage : TPackage; ATarget : TTarget; AbsolutePath : Boolean = False) : String;
    Function  GetCompilerCommand(APackage : TPackage; Target : TTarget) : String;
    Function  TargetOK(Target : TTarget) : Boolean;
    Function  NeedsCompile(Target : TTarget) : Boolean;
    Procedure Compile(Target : TTarget);  virtual;
    Procedure FixDependencies(Target: TTarget);
    // Package commands
    Function  GetPackageDir(APackage : TPackage; AbsolutePath : Boolean = False) : String;
    Function  GetUnitsOutputDir(APackage : TPackage; AbsolutePath : Boolean = False) : String;
    Function  GetBinOutputDir(APackage : TPackage; AbsolutePath : Boolean = False) : String;
    Function  PackageOK(APackage : TPackage) : Boolean; virtual;
    Procedure DoBeforeCompile(APackage : TPackage);virtual;
    Procedure DoAfterCompile(APackage : TPackage);virtual;
    Procedure DoBeforeInstall(APackage : TPackage);virtual;
    Procedure DoAfterInstall(APackage : TPackage);virtual;
    Procedure DoBeforeArchive(APackage : TPackage);virtual;
    Procedure DoAfterArchive(APackage : TPackage);virtual;
    Procedure DoBeforeClean(APackage : TPackage);virtual;
    Procedure DoAfterClean(APackage : TPackage);virtual;
    Function NeedsCompile(APackage : TPackage) : Boolean; virtual;
    Procedure Compile(APackage : TPackage);
    Procedure Install(APackage : TPackage);
    Procedure Archive(APackage : TPackage);
    Procedure Clean(APackage : TPackage);
    Procedure FixDependencies(APackage : TPackage);
    Procedure GetSourceFiles(APackage : TPackage; List : TStrings);
    Procedure GetManifest(APackage : TPackage; Manifest : TStrings);
    procedure CheckExternalPackage(Const APackageName : String);
    procedure CreateOutputDir(APackage: TPackage);
    // Packages commands
    Procedure Compile(Packages : TPackages);
    Procedure Install(Packages : TPackages);
    Procedure Archive(Packages : TPackages);
    Procedure Clean(Packages : TPackages);
    Procedure GetSourceFiles(Packages : TPackages;List : TStrings);
    Procedure GetManifest(Packages : TPackages; Manifest : TStrings);
    Property ListMode : Boolean Read FListMode Write FListMode;
    Property ForceCompile : Boolean Read FForceCompile Write FForceCompile;
    Property Defaults : TCustomDefaults Read FDefaults Write SetDefaults;
    Property TargetDir : String Read FTargetDir Write SetTargetDir;
    // Events
    Property BeforeCompile : TNotifyEvent Read FBeforeCompile Write FBeforeCompile;
    Property AfterCompile : TNotifyEvent Read FAfterCompile Write FAfterCompile;
    Property BeforeInstall : TNotifyEvent Read FBeforeInstall Write FBeforeInstall;
    Property AfterInstall : TNotifyEvent Read FAfterInstall Write FAfterInstall;
    Property BeforeClean : TNotifyEvent Read FBeforeClean Write FBeforeClean;
    Property AfterClean : TNotifyEvent Read FAfterClean Write FAfterClean;
    Property BeforeArchive : TNotifyEvent Read FBeforeArchive Write FBeforeArchive;
    Property AfterArchive : TNotifyEvent Read FAfterArchive Write FAfterArchive;
    Property BeforeManifest : TNotifyEvent Read FBeforeManifest Write FBeforeManifest;
    Property AfterManifest : TNotifyEvent Read FAfterManifest Write FAfterManifest;
    Property OnLog : TLogEvent Read FOnLog Write FOnlog;
  end;

  { TCustomInstaller }

  TCustomInstaller = Class(TComponent)
  private
    FBuildEngine: TBuildEngine;
    FDefaultPackage: TPackage;
    FDefaults: TCustomDefaults;
    FPackages: TPackages;
    FRunMode: TRunMode;
    FListMode : Boolean;
    FLogLevels : TVerboseLevels;
    function GetBaseInstallDir: string;
    Function GetPackageString(Index : Integer) : String;
    Procedure SetPackageString(Index : Integer; const AValue : String);
    function GetStrings(AIndex : Integer): TStrings;
    function GetOSes: TOSes;
    function GetTargets: TTargets;
    function GetSources: TSources;
    procedure SetBaseInstallDir(const AValue: string);
    procedure SetDefaultPackage(const AValue: TPackage);
    procedure SetDefaults(const AValue: TCustomDefaults);
    procedure SetStrings(AIndex : Integer; const AValue: TStrings);
    procedure SetOses(const AValue: TOSes);
    procedure SearchFiles(const AFileName: string; Recursive: boolean; var List: TStrings);
  Protected
    Procedure Log(Level : TVerboseLevel; Const Msg : String);
    Procedure CreatePackages; virtual;
    Procedure CheckPackages; virtual;
    Procedure CreateBuildEngine; virtual;
    Procedure CheckDefaultPackage;
    Procedure Error(const Msg : String);
    Procedure Error(const Fmt : String; Args : Array of const);
    Procedure AnalyzeOptions;
    Procedure Usage(const FMT : String; Args : Array of const);
    Procedure Compile(Force : Boolean); virtual;
    Procedure Clean; virtual;
    Procedure Install; virtual;
    Procedure Archive; virtual;
    Procedure Manifest; virtual;
    Procedure GetSourceFiles; virtual;
    Property BuildEngine : TBuildEngine Read FBuildEngine;
  Public
    Constructor Create(AOwner : TComponent); virtual; abstract;
    Destructor destroy; override;
    Function StartPackage(Const AName : String) : TPackage;
    Procedure EndPackage;
    Function Run : Boolean;
    Function AddTarget(const AName : String) : TTarget;
    Procedure AddDependency(const AName : String);
    //files in package
    procedure AddDocFiles(const AFileMask: string; Recursive: boolean = False);
    procedure AddSrcFiles(const AFileMask: string; Recursive: boolean = False);
    procedure AddExampleFiles(const AFileMask: string; Recursive: boolean = False);
    procedure AddTestFiles(const AFileMask: string; Recursive: boolean = False);
    Property DefaultPackage : TPackage read FDefaultPackage write SetDefaultPackage;
    Property Packages : TPackages Read FPackages;
    Property Dependencies : TStrings Index 0 Read GetStrings Write SetStrings;
    Property InstallFiles : TStrings Index 1 Read GetStrings Write SetStrings;
    Property CleanFiles : TStrings Index 2 Read GetStrings Write SetStrings;
    Property ArchiveFiles : TStrings Index 3 Read GetStrings Write SetStrings;
    Property Defaults : TCustomDefaults Read FDefaults Write SetDefaults;
    Property RunMode : TRunMode Read FRunMode;
    Property ListMode : Boolean Read FListMode;
    Property BaseInstallDir : String Read GetBaseInstallDir Write SetBaseInstallDir;
    // Default Package redirects.
    Property Targets : TTargets Read GetTargets;
    Property Sources : TSources Read GetSources;
    Property OS: TOSes Read GetOSes Write SetOses;
    Property Author : String Index 0 Read GetPackageString Write SetPackageString;
    Property Directory : String Index 1 Read GetPackageString Write SetPackageString;
    Property License : String Index 2 Read GetPackageString Write SetPackageString;
    Property Options : String Index 3 Read GetPackageString Write SetPackageString;
    Property ExternalURL : String Index 4 Read GetPackageString Write SetPackageString;
    Property Email : String Index 5 Read GetPackageString Write SetPackageString;
    Property Description: String Index 6 Read GetPackageString Write SetPackageString;
    Property DescriptionFileName: String Index 7 Read GetPackageString Write SetPackageString;
    Property Version : String Index 8 Read GetPackageString Write SetPackageString;
    Property FileName : String Index 9 Read GetPackageString Write SetPackageString;
  end;

  { TFPCInstaller }
  TFPCInstaller = class(TCustomInstaller)
  public
    Constructor Create(AOwner : TComponent); override;
  end;

  { TBasicInstaller }
  TBasicInstaller = class(TCustomInstaller)
    Constructor Create(AOwner : TComponent); override;
  end;

  TReplaceFunction = Function (Const AName,Args : String) : String of Object;

  { TValueItem }

  TValueItem = Class(TObject)
    FValue : String;
    Constructor Create(AValue : String);
  end;

  { TFunctionItem }

  TFunctionItem = Class(TObject)
    FFunc : TReplaceFunction;
    Constructor Create(AFunc : TReplaceFunction);
  end;

  { TDictionary }

  TDictionary = Class(TComponent)
    FList : TStringList;
  Public
    Constructor Create(AOwner : TComponent); override;
    Destructor Destroy;override;
    Procedure AddVariable(Const AName,Value : String);
    Procedure AddFunction(Const AName : String; FReplacement : TReplaceFunction);
    Procedure RemoveItem(Const AName : String);
    Function GetValue(Const AName : String) : String;
    Function GetValue(Const AName,Args : String) : String; virtual;
    Function ReplaceStrings(Const ASource : String) : String; virtual;
  end;

  ECollectionError = Class(Exception);
  EDictionaryError = Class(Exception);
  EInstallerError = Class(Exception);

  TInstallerClass = Class of TCustomInstaller;
  TDictionaryClass = Class of TDictionary;

Type
  TArchiveEvent = Procedure (Const AFileName : String; List : TStrings) of Object;
  TArchiveProc = Procedure (Const AFileName : String; List : TStrings);

Var
  DictionaryClass : TDictionaryClass = TDictionary;
  OnArchiveFiles : TArchiveEvent = Nil;
  ArchiveFilesProc : TArchiveProc = Nil;

Function CurrentOS : String;
Function CurrentCPU : String;

Function Installer(InstallerClass: TInstallerClass) : TCustomInstaller; overload;
Function Installer : TCustomInstaller; overload;

Function Defaults : TCustomDefaults; // Set by installer.
Function Dictionary : TDictionary;

Function OSToString(OS: TOS) : String;
Function OSesToString(OSes: TOSes) : String;
Function CPUToString(CPU: TCPU) : String;
Function CPUSToString(CPUS: TCPUS) : String;
Function StringToOS(const S : String) : TOS;
Function OSesToString(const S : String) : TOSes;
Function StringToCPU(const S : String) : TCPU;
Function StringToCPUS(const S : String) : TCPUS;
Function ModeToString(Mode: TCompilerMode) : String;
Function StringToMode(const S : String) : TCompilerMode;
Function MakeTargetString(CPU : TCPU;OS: TOS) : String;
Procedure StringToCPUOS(const S : String; Var CPU : TCPU; Var OS: TOS);
Procedure ResolveDependencies(L : TStrings; P : TNamedCollection);
Function AddStrings(Dest,Src : TStrings) : Integer ;
function AddStrings(Dest, Src : TStrings; Const APrefix : String) : Integer ;
Function FileListToString(List : TStrings; const APrefix : String) : String;
Function FixPath (const APath : String) : String;
Procedure ChangeDir(const APath : String);
Function Substitute(Const Source : String; Macros : Array of string) : String;
Procedure SplitCommand(Const Cmd : String; Var Exe,Options : String);

Implementation

uses typinfo;

ResourceString
  SErrInvalidCPU        = 'Invalid CPU name : "%s"';
  SErrInvalidOS         = 'Invalid OS name : "%s"';
  SErrInvalidMode       = 'Invalid compiler mode : "%s"';
  SErrInvalidTarget     = 'Invalid compiler target: %s';
  SErrNameExists        = 'Name "%s" already exists in the collection.';
  SErrNoSuchName        = 'Could not find item with name "%s" in the collection.';
  SErrNoPackage         = 'No package available. Add package with StartPackage Call';
  SErrInValidArgument   = 'Invalid command-line argument at position %d : %s';
  SErrNeedArgument      = 'Option at position %d (%s) needs an argument';
  SErrNoPackagesDefined = 'No action possible: No packages were defined.';
  SErrInstaller         = 'The installer encountered the following error:';
  SErrDepUnknownTarget  = 'Unknown target in dependencies for %s: %s';
  SErrExternalCommandFailed = 'External command "%s" failed with exit code: %d';
  SErrCreatingDirectory = 'Failed to create directory: "%s"';
  SErrDeletingFile      = 'Failed to delete file: "%s"';
  SErrMovingFile        = 'Failed to move file "%s" to "%s"';
  SErrCopyingFile       = 'Failed to copy file "%s" to "%s"';
  SErrChangeDirFailed   = 'Failed to enter directory: %s';
  SErrInvalidArgumentToSubstitute = 'Invalid number of arguments to Substitute';
  SErrNoArchiveSupport  = 'This binary contains no archive support. Please recompile with archive support';
  SErrNoDictionaryItem  = 'No item called "%s" in the dictionary';
  SErrNoDictionaryValue = 'The item "%s" in the dictionary is not a value.';
  SErrNoDictionaryFunc  = 'The item "%s" in the dictionary is not a function.';
  SErrInvalidFPCInfo    = 'Compiler returns invalid information, check if fpc -iV works';
  SErrDependencyNotFound = 'Could not find unit directory for dependency package "%s"';
  SWarnCircularDependency = 'Warning: Circular dependency detected when compiling target %s: %s';
  SWarnFailedToSetTime  = 'Warning: Failed to set timestamp on file : %s';
  SWarnFailedToGetTime  = 'Warning: Failed to get timestamp from file : %s';
  SWarnFileDoesNotExist = 'Warning: File "%s" does not exist';
  SWarnAttemptingToCompileNonNeutralTarget = 'Attempting to compile non-neutral target: %s';
  SDebugCheckingDependenciesForTarget = 'Checking dependencies for target: %s';
  SDebugCheckingSAgainstS  = 'Checking : %s against %s';
  SDebugCheckingS          = 'Checking : %s';
  SDebugTargetHasWrongOS   = 'Target has wrong OS: %s';
  SDebugTargetHasWrongCPU  = 'Target has wrong CPU: %s';
  SDebugTargetIsNotAUnitOrProgram = 'Target is not a unit or program';
  SDebugConsideringTarget = 'Considering target: %s';
  SDebugUnresolvedExternalDependencyS = 'Unresolved external dependency : %s';
  SDebugBuildEngineArchiving = 'Build engine archiving.';
  SDebugBuildEngineCleaning = 'Build engine cleaning.';
  SCmdGenerating         = 'Generating %s';
  SInfoArchiving         = 'Archiving : %s';

  // Log messages
  SLogEnterDir           = 'Entering directory: %s';
  SLogCompilingPackage   = 'Compiling package : %s';
  SLogCompilingTarget    = 'Compiling target  : %s';
  SLogExecutingCommand   = 'Executing command : %s %s';
  SLogCreatingOutputDir  = 'Creating output dir : %s';
  SLogOutputDirExists    = 'Output dir exists : %s';
  SLogInstallingPackage  = 'Installing package : %s';
  SLogArchivingPackage   = 'Archiving package : %s';
  SLogCleaningPackage    = 'Cleaning package : %s';
  SLogCopyingFile        = 'Copying file "%s" to "%s"';
  SLogCompilingFileTimes = 'Comparing file "%s" time "%s" to "%s" time "%s".';
  SLogSourceNewerDest    = 'Source file "%s" (%s) is newer than destination "%s" (%s).';

  // Help messages for usage
  SValue              = 'Value';
  SHelpUsage          = 'Usage: %s command [options]';
  SHelpCommand        = 'Where command is one of the following:';
  SHelpCompile        = 'Compile all units in the package(s).';
  SHelpBuild          = 'Build all units in the package(s).';
  SHelpInstall        = 'Install all units in the package(s).';
  SHelpClean          = 'Clean (remove) all units in the package(s).';
  SHelpArchive        = 'Create archive (zip) with all units in the package(s).';
  SHelpHelp           = 'This message.';
  SHelpManifest       = 'Create a manifest suitable for import in repository.';
  SHelpListSources    = 'Create a list of sources in the package.';
  SHelpCmdOptions     = 'Where options is one or more of the following:';
  SHelpCPU            = 'Compile for indicated CPU.';
  SHelpOS             = 'Compile for indicated OS';
  SHelpTarget         = 'Compile for indicated target';
  SHelpList           = 'list commands instead of actually executing them.';
  SHelpPrefix         = 'Use indicated prefix directory for all commands.';
  SHelpNoDefaults     = 'Do not use defaults when compiling.';
  SHelpBaseInstallDir = 'Use indicated directory as base install dir.';
  SHelpLocalUnitDir   = 'Use indicated directory as local (user) unit dir.';
  SHelpGlobalUnitDir  = 'Use indicated directory as global unit dir.';
  SHelpCompiler       = 'Use indicated binary as compiler';
  SHelpConfig         = 'Use indicated config file when compiling.';
  SHelpVerbose        = 'Be verbose when working.';


Const
  // Keys for Defaults file. Do not localize.
  KeyCompiler = 'Compiler';
  KeyArchive  = 'Archive';
  KeyCopy     = 'Copy';
  KeyMkDir    = 'MkDir';
  KeyMove     = 'Move';
  KeyRemove   = 'Remove';
  KeyOptions  = 'Options';
  KeyCPU      = 'CPU';
  KeyOS       = 'OS';
  KeyMode     = 'Mode';
  KeyPrefix   = 'Prefix';
  KeyTarget   = 'Target';
  KeyLocalUnitDir       = 'LocalUnitDir';
  KeyGlobalUnitDir      = 'GlobalUnitDir';
  KeyBaseInstallDir     = 'BaseInstallDir';
  KeyUnitInstallDir     = 'UnitInstallDir';
  KeyBinInstallDir      = 'BinInstallDir';
  KeyDocInstallDir      = 'DocInstallDir';
  KeyExamplesInstallDir = 'ExamplesInstallDir';
  KeySourceExt = 'SourceExt';

// Callback for Sysutils getapplicationname.

Function GetFPMakeName : String;

begin
  Result:='fpmake';
end;


Function CurrentOS : String;

begin
  Result:=OSToString(Defaults.OS);
end;

Function CurrentCPU : String;

begin
  Result:=CPUToString(Defaults.CPU);
end;

Function OSToString(OS: TOS) : String;

begin
  Result:=LowerCase(GetenumName(TypeInfo(TOS),Ord(OS)));
end;

Function OSesToString(OSes: TOSes) : String;

begin
  Result:=LowerCase(SetToString(PtypeInfo(TypeInfo(TOSes)),Integer(OSes),False));
end;

Function CPUToString(CPU: TCPU) : String;

begin
  Result:=LowerCase(GetenumName(TypeInfo(TCPU),Ord(CPU)));
end;

Function CPUSToString(CPUS: TCPUS) : String;

begin
  Result:=LowerCase(SetToString(PTypeInfo(TypeInfo(TCPUS)),Integer(CPUS),False));
end;

Function StringToOS(const S : String) : TOS;

Var
  I : Integer;

begin
  I:=GetEnumValue(TypeInfo(TOS),S);
  if (I=-1) then
    Raise EInstallerError.CreateFmt(SErrInvalidOS,[S]);
  Result:=TOS(I);
end;


Function OSesToString(const S : String) : TOSes;

begin
  Result:=TOSes(StringToSet(PTypeInfo(TypeInfo(TOSes)),S));
end;

Function StringToCPU(const S : String) : TCPU;

Var
  I : Integer;

begin
  I:=GetEnumValue(TypeInfo(TCPU),S);
  if (I=-1) then
    Raise EInstallerError.CreateFmt(SErrInvalidCPU,[S]);
  Result:=TCPU(I);
end;

Function StringToCPUS(const S : String) : TCPUS;

begin
  Result:=TCPUS(StringToSet(PTypeInfo(TypeInfo(TCPUS)),S));
end;

Function ModeToString(Mode: TCompilerMode) : String;

begin
  Result:=LowerCase(GetenumName(TypeInfo(TCompilerMode),Ord(Mode)));
end;

Function StringToMode(const S : String) : TCompilerMode;

Var
  I : Integer;

begin
  I:=GetEnumValue(TypeInfo(TCompilerMode),S);
  if (I=-1) then
    Raise EInstallerError.CreateFmt(SErrInvalidMode,[S]);
  Result:=TCompilerMode(I);
end;


Function MakeTargetString(CPU : TCPU;OS: TOS) : String;

begin
  Result:=CPUToString(CPU)+'-'+OSToString(OS);
end;

Procedure StringToCPUOS(const S : String; Var CPU : TCPU; Var OS: TOS);

Var
  P : integer;

begin
  P:=Pos('-',S);
  If (P=0) then
    Raise EInstallerError.CreateFmt(SErrInvalidTarget,[S]);
  CPU:=StringToCPU(Copy(S,1,P-1));
  OS:=StringToOs(Copy(S,P+1,Length(S)-P));
end;


Procedure ResolveDependencies(L : TStrings; P : TNamedCollection);

Var
  I,J : Integer;

begin
  If Assigned(L) then
    For I:=0 to L.Count-1 do
      begin
      J:=P.IndexOfName(L[i]);
      If J<>-1 then
        L.Objects[I]:=P.Items[J];
      end;
end;

Function AddStrings(Dest,Src : TStrings) : Integer ;
begin
  Result:=AddStrings(Dest,Src,'');
end;

Procedure AddStrings(Var S : String; L : TStrings; const APrefix : String);
Var
  I : Integer;
begin
  For I:=0 to L.Count-1 do
    begin
    if (S<>'') then
      S:=S+' ';
    S:=S+APrefix+L[i];
    end;
end;

function AddStrings(Dest, Src : TStrings; Const APrefix : String) : Integer ;
begin
  Result:=0;
  While (Result<Src.Count) do
    begin
    If (APrefix<>'') then
      Dest.Add(APrefix+Src[Result]) // Not sure whether '' is optimized away.
    else
      Dest.Add(Src[Result]);
    Inc(Result);
    end;
end;

function FileListToString(List : TStrings; const APrefix : String) : String;

Var
  I : integer;
  S : String;

begin
  Result:='';
  For I:=0 to List.Count-1 do
    begin
    If (I>0) then
      Result:=Result+' ';
    S:=APrefix+List[i];
    If (Pos(' ',S)<>0) then
      S:='"'+S+'"';
    Result:=Result+S;
    end;
end;

function FixPath (const APath : String) : String;

Var
  P : PChar;

begin
  Result:=APath;
  If (result<>'') then
    begin
    P:=PChar(Result);
    While (P^<>#0) do
      begin
      If P^ in ['/','\'] then
        P^:=PathDelim;
      Inc(P);
      end;
    end;
end;

procedure ChangeDir(const APath : String);

begin
  if Not SetCurrentDir(APath) then
    Raise EInstallerError.CreateFmt(SErrChangeDirFailed,[APath]);
end;

procedure SplitCommand(const Cmd : String; var Exe, Options : String);

Const
  WhiteSpace = [#9,#10,#13,' '];
  QuoteChars = ['''','"'];

Var
  I : Integer;
  InQuote : Boolean;
  LastQuote : Char;
  S : String;

begin
  S:=Trim(Cmd);
  InQuote:=False;
  LastQuote:=#0;
  I:=1;
  While (I<=Length(S)) and (Inquote or not (S[I] in whiteSpace)) do
    begin
    If S[i] in QuoteChars then
      begin
      InQuote:=Not (S[i]=LastQuote);
      If InQuote then
         LastQuote:=S[i]
       else
         LastQuote:=#0;
      end;
    Inc(I);
    end;
  Exe:=Copy(S,1,I-1);
  Delete(S,1,I);
  Options:=Trim(S);
end;


{$ifdef HAS_UNIT_PROCESS}
function GetCompilerInfo(const ACompiler,AOptions:string):string;
const
  BufSize = 1024;
var
  S: TProcess;
  Buf: array [0..BufSize - 1] of char;
  Count: longint;
begin
  S:=TProcess.Create(Nil);
  S.Commandline:=ACompiler+' '+AOptions;
  S.Options:=[poUsePipes];
  S.execute;
  Count:=s.output.read(buf,BufSize);
  S.Free;
  SetLength(Result,Count);
  Move(Buf,Result[1],Count);
end;
{$endif HAS_UNIT_PROCESS}


{ TNamedItem }

procedure TNamedItem.SetName(const AValue: String);

begin
  if FName=AValue then exit;
  With TNamedCollection(Collection) do
    If UniqueNames then
      If (IndexOfName(AVAlue)<>-1) then
        Raise ECollectionError.CreateFmt(SErrNameExists,[AValue]);
  FName:=AValue;
end;

{ TNamedCollection }

function TNamedCollection.IndexOfName(const AName: String): Integer;

begin
  Result:=Count-1;
  While (Result>=0) and (CompareText(TNamedItem(Items[Result]).FName,AName)<>0) do
    Dec(Result);
end;

function TNamedCollection.ItemByName(const AName: String): TNamedItem;

Var
  I : Integer;

begin
  I:=IndexOfName(AName);
  If (I=-1) Then
    Raise ECollectionError.CreateFmt(SErrNoSuchName,[AName]);
  Result:=TNamedItem(Items[i]);
end;


{ TTargets }

function TTargets.GetTargetItem(Index : Integer): TTarget;
begin
  Result:=TTarget(Items[Index]);
end;

function TTargets.GetTarget(const AName : String): TTarget;
begin
  Result:=TTarget(ItemByName(AName));
end;

procedure TTargets.SetDefaultDir(const AValue: String);
begin
  If (AValue<>'') then
    FDefaultDir:=IncludeTrailingPathDelimiter(AValue)
  else
    FDefaultDir:='';
end;

procedure TTargets.SetTargetItem(Index : Integer; const AValue: TTarget);

begin
  Items[Index]:=AValue;
end;

procedure TTargets.ApplyDefaults(ATarget: TTarget);
begin
  If (ATarget.Directory='') then
    ATarget.Directory:=FDefaultDir;
   ATarget.OS:=FDefaultOS;
   ATarget.CPU:=FDefaultCPU;
end;

procedure TTargets.ResetDefaults;
begin
  FDefaultDir:='';
  FDefaultOS:=[];
  FDefaultCPU:=[];
end;

Function TTargets.AddUnit(const AUnitName : String) : TTarget;
begin
  Result:=Add as TTarget;
  Result.Name:=AUnitName;
  Result.TargetType:=TTUnit;
  ApplyDefaults(Result);
end;

Function TTargets.AddImplicitUnit(const AUnitName : String;InstallUnit:boolean=true) : TTarget;
begin
  Result:=Add as TTarget;
  Result.Name:=AUnitName;
  if InstallUnit then
    Result.TargetType:=TTImplicitUnit
  else
    Result.TargetType:=TTCleanOnlyUnit;
  ApplyDefaults(Result);
end;

Function TTargets.AddProgram(const AProgramName: String) : TTarget;
begin
  Result:=Add as TTarget;
  Result.Name:=AProgramName;
  Result.TargetType:=ttProgram;
  ApplyDefaults(Result);
end;

Function TTargets.AddExampleUnit(const AUnitName: String): TTarget;
begin
  Result:=Add as TTarget;
  Result.Name:=AUnitName;
  Result.TargetType:=ttExampleUnit;
  ApplyDefaults(Result);
end;

Function TTargets.AddExampleProgram(const AProgramName: String): TTarget;
begin
  Result:=Add as TTarget;
  Result.Name:=AProgramName;
  Result.TargetType:=ttExampleProgram;
  ApplyDefaults(Result);
end;


{ TSources }

function TSources.GetSourceItem(Index : Integer): TSource;
begin
  Result:=TSource(Items[Index]);
end;


procedure TSources.SetSourceItem(Index : Integer; const AValue: TSource);
begin
  Items[Index]:=AValue;
end;


function TSources.AddDocFiles(const AFiles : String) : TSource;
begin
  Result:=Add as TSource;
  Result.Name:=AFiles;
  Result.SourceType:=stDoc;
end;


function TSources.AddSrcFiles(const AFiles : String) : TSource;
begin
  Result:=Add as TSource;
  Result.Name:=AFiles;
  Result.SourceType:=stSrc;
end;

function TSources.AddExampleFiles(const AFiles : String) : TSource;
begin
  Result:=Add as TSource;
  Result.Name:=AFiles;
  Result.SourceType:=stExample;
end;

function TSources.AddTestFiles(const AFiles : String) : TSource;
begin
  Result:=Add as TSource;
  Result.Name:=AFiles;
  Result.SourceType:=stTest;
end;

{ TNamedItemList }

function TNamedItemList.GetNamedItem(Index : Integer): TNamedItem;
begin
  Result:=TNamedItem(Items[Index]);
end;

procedure TNamedItemList.SetNamedItem(Index : Integer; const AValue: TNamedItem);
begin
  Items[Index]:=AValue;
end;

function TNamedItemList.IndexOfName(const AName: String): Integer;

begin
  Result:=Count-1;
  While (Result>=0) and (CompareText(GetNamedItem(Result).Name,AName)<>0) do
    Dec(Result);
end;

function TNamedItemList.ItemByName(const ANAme: String): TNamedItem;

Var
  I : Integer;

begin
  I:=IndexOfName(AName);
  If (I=-1) Then
    Raise ECollectionError.CreateFmt(SErrNoSuchName,[AName]);
  Result:=TNamedItem(Items[i]);
end;

{ TCustomDefaults }

procedure TCustomDefaults.SetCPU(const AValue: TCPU);
begin
  FCPU:=AValue;
  RecalcTarget;
end;

function TCustomDefaults.GetBaseInstallDir: String;
begin
  If (FBaseInstallDir<>'') then
    Result:=FBaseInstallDir
  else
    if UnixPaths then
      Result:=Prefix +'lib' + PathDelim + 'fpc' + PathDelim
    else
      Result:=Prefix;

end;

function TCustomDefaults.GetBinInstallDir: String;
begin
  If (FBinInstallDir<>'') then
    Result:=FBinInstallDir
  else
    If UnixPaths then
      Result:=BaseInstallDir+'bin'
    else
      Result:=BaseInstallDir+'bin';
end;

function TCustomDefaults.GetCompiler: String;
begin
  If (FCompiler<>'') then
    Result:=FCompiler
  else
    Result:='fpc';
end;

function TCustomDefaults.GetDocInstallDir: String;
begin
  If (FBinInstallDir<>'') then
    Result:=FBinInstallDir
  else
    If UnixPaths then
      Result:=Prefix+'share'+PathDelim+'docs'
    else
      Result:=BaseInstallDir+'docs';
end;

function TCustomDefaults.GetExamplesInstallDir: String;
begin
  If (FExamplesInstallDir<>'') then
    Result:=FExamplesInstallDir
  else
    If UnixPaths then
      Result:=Prefix+'share'+PathDelim+'docs'+PathDelim+'examples'
    else
      Result:=BaseInstallDir+'examples';
end;

function TCustomDefaults.GetUnitInstallDir: String;
begin
  If (FUnitInstallDir<>'') then
    Result:=FUnitInstallDir
  else
    If UnixPaths then
      Result:=BaseInstallDir+'units'+PathDelim+Target
    else
      Result:=BaseInstallDir+'units'+PathDelim+Target;
end;

function TCustomDefaults.GetLocalUnitDir: String;
begin
  Result:=FLocalUnitDir;
end;

function TCustomDefaults.GetGlobalUnitDir: String;
begin
  If (FGlobalUnitDir<>'') then
    Result:=FGlobalUnitDir
  else
    Result:=UnitInstallDir;
end;

procedure TCustomDefaults.SetBaseInstallDir(const AValue: String);
begin
  FBaseInstallDir:=IncludeTrailingPathDelimiter(AValue);
  UnitInstallDir:='';
  BinInstallDir:='';
  ExamplesInstallDir:='';
end;

procedure TCustomDefaults.SetOS(const AValue: TOS);
begin
  FOS:=AValue;
  Recalctarget;
end;

procedure TCustomDefaults.SetPrefix(const AValue: String);
begin
  if FPrefix=AValue then exit;
  FPrefix:=IncludeTrailingPathDelimiter(AValue);
  BaseInstallDir:='';
end;

procedure TCustomDefaults.SetTarget(const AValue: String);

Var
  P : Integer;

begin
  if FTarget<>AValue then
    begin
    P:=Pos('-',AValue);
    If (P<>0) then
      begin
      FOS:=StringToOS(System.Copy(Avalue,P+1,Length(AValue)-P));
      FCPU:=StringToCPU(System.Copy(Avalue,1,P-1));
      end
    else
      FOS:=StringToOS(AValue);
    FTarget:=AValue;
    end;
end;

procedure TCustomDefaults.RecalcTarget;
begin
  Ftarget:=CPUToString(FCPU)+'-'+OStoString(FOS);
end;

constructor TCustomDefaults.Create;
begin
  InitDefaults;
end;

procedure TCustomDefaults.InitDefaults;
begin
  {$ifdef unix}
  UnixPaths:=True;
  {$else}
  UnixPaths:=False;
  {$endif}
  FSourceExt:=PPExt;
end;

procedure TCustomDefaults.Assign(ASource: TPersistent);

Var
  d : TCustomDefaults;

begin
  If ASource is TCustomDefaults then
    begin
    D:=ASource as TCustomDefaults;
    FArchive:=D.Farchive;
    FCompiler:=D.Compiler;
    FCopy:=D.FCopy;
    FCPU:=D.FCPU;
    FMode:=D.FMode;
    FMkDir:=D.FMkDir;
    FMove:=D.FMove;
    FOptions:=D.FOptions;
    FOS:=D.FOS;
    FLocalUnitDir:=D.FLocalUnitDir;
    FGlobalUnitDir:=D.FGlobalUnitDir;
    FPrefix:=D.FPrefix;
    FBaseInstallDir:=D.FBaseInstallDir;
    FUnitInstallDir:=D.FUnitInstallDir;
    FBinInstallDir:=D.FBinInstallDir;
    FDocInstallDir:=D.FDocInstallDir;
    FExamplesInstallDir:=D.FExamplesInstallDir;
    FRemove:=D.FRemove;
    FTarget:=D.FTarget;
    FUnixPaths:=D.FUnixPaths;
    FSourceExt:=D.SourceExt;
    end
  else
    Inherited;
end;

procedure TCustomDefaults.LocalInit(Const AFileName : String);

Var
  FN : String;

begin
  FN:=AFileName;
  If (FN='') then
    begin
    // Environment variable.
    FN:=GetEnvironmentVariable('FPMAKECFG');
    If (FN<>'') then
      If not FileExists(FN) then
        FN:='';
    // User config file fpmake.cfg
    If (FN='') then
      begin
      FN:=GetAppConfigFile(False);
      If Not FileExists(FN) then
        FN:='';
      end;
    // Global config file fpmake.cfg
    If (FN='') then
      begin
      FN:=GetAppConfigFile(True);
      If Not FileExists(FN) then
        FN:='';
      end;
    end;
  If (FN<>'') and FileExists(FN) then
    LoadFromFile(FN);
end;


procedure TCustomDefaults.CompilerDefaults;
{$ifdef HAS_UNIT_PROCESS}
var
  infoSL : TStringList;
{$endif HAS_UNIT_PROCESS}
begin
{$ifdef HAS_UNIT_PROCESS}
  // Detect compiler version/target from -i option
  infosl:=TStringList.Create;
  infosl.Delimiter:=' ';
  infosl.DelimitedText:=GetCompilerInfo(GetCompiler,'-iVTPTO');
  if infosl.Count<>3 then
    Raise EInstallerError.Create(SErrInvalidFPCInfo);
  FCompilerVersion:=infosl[0];
  CPU:=StringToCPU(infosl[1]);
  OS:=StringToOS(infosl[2]);
{$else HAS_UNIT_PROCESS}
  if CPU=cpuNone then
    CPU:=StringToCPU({$I %FPCTARGETCPU%});
  if OS=osNone then
    OS:=StringToOS({$I %FPCTARGETOS%});
  if FCompilerVersion='' then
    FCompilerVersion:={$I %FPCVERSION%};
{$endif HAS_UNIT_PROCESS}
end;

procedure TCustomDefaults.LoadFromFile(Const AFileName: String);

Var
  F : TFileStream;

begin
  F:=TFileStream.Create(AFileName,fmOpenRead);
  Try
    LoadFromStream(F);
  Finally
    F.Free;
  end;
end;

procedure TCustomDefaults.SaveToFile(Const AFileName: String);

Var
  F : TFileStream;

begin
  F:=TFileStream.Create(AFileName,fmCreate);
  Try
    SaveToStream(F);
  Finally
    F.Free;
  end;
end;

procedure TCustomDefaults.SaveToStream(S : TStream);

Var
  L : TStringList;

begin
  L:=TStringList.Create;
  try
    With L do
      begin
      Values[KeyArchive]:=FArchive;
      Values[KeyCompiler]:=FCompiler;
      Values[KeyCopy]:=FCopy;
      Values[KeyMkDir]:=FMkDir;
      Values[KeyMove]:=FMove;
      Values[KeyOptions]:=FOptions;
      Values[KeyCPU]:=CPUToString(FCPU);
      Values[KeyOS]:=OSToString(FOS);
      Values[KeyMode]:=ModeToString(FMode);
      Values[KeyLocalUnitDir]:=FLocalUnitDir;
      Values[KeyGlobalUnitDir]:=FGlobalUnitDir;
      Values[KeyPrefix]:=FPrefix;
      Values[KeyBaseInstallDir]:=FBaseInstallDir;
      Values[KeyUnitInstallDir]:=FUnitInstallDir;
      Values[KeyBinInstallDir]:=FBinInstallDir;
      Values[KeyDocInstallDir]:=FDocInstallDir;
      Values[KeyExamplesInstallDir]:=FExamplesInstallDir;
      Values[KeyRemove]:=FRemove;
      Values[KeyTarget]:=FTarget;
      Values[KeySourceExt]:=FSourceExt;
      end;
    L.SaveToStream(S);
  Finally
    L.Free;
  end;
end;

procedure TCustomDefaults.LoadFromStream(S: TStream);

Var
  L : TStrings;
  Line : String;
  I,P,PC : Integer;


begin
  L:=TStringList.Create;
  Try
    L.LoadFromStream(S);
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
    With L do
      begin
      FArchive:=Values[KeyArchive];
      FCompiler:=Values[KeyCompiler];
      FCopy:=Values[KeyCopy];
      FMkDir:=Values[KeyMkDir];
      FMove:=Values[KeyMove];
      FRemove:=Values[KeyRemove];
      FOptions:=Values[KeyOptions];
      Line:=Values[KeyCPU];
      If (Line<>'') then
        FCPU:=StringToCPU(Line);
      Line:=Values[KeyOS];
      If (Line<>'') then
        FOS:=StringToOS(Line);
      Line:=Values[KeyMode];
      If (Line<>'') then
        FMode:=StringToMode(Line);
      FTarget:=Values[KeyTarget];
      FLocalUnitDir:=Values[KeyLocalUnitDir];
      FGlobalUnitDir:=Values[KeyGlobalUnitDir];
      FPrefix:=Values[KeyPrefix];
      FBaseInstallDir:=Values[KeyBaseInstallDir];
      FUnitInstallDir:=Values[KeyUnitInstallDir];
      FBinInstallDir:=Values[KeyBinInstallDir];
      FDocInstallDir:=Values[KeyDocInstallDir];
      FExamplesInstallDir:=Values[KeyExamplesInstallDir];
      FSourceExt:=Values[KeySourceExt];
      If (FSourceExt='') then
        FSourceExt:=PPExt;
      end;
  Finally
    L.Free;
  end;
end;

{ TFPCDefaults }

procedure TFPCDefaults.CompilerDefaults;
var
  BD : String;
begin
  inherited CompilerDefaults;

  if (FBaseInstallDir='') and (FPrefix='') then
    begin
      // Use the same algorithm as the compiler, see options.pas
{$ifdef Unix}
      BD:=FixPath(GetEnvironmentVariable('FPCDIR'));
      if BD='' then
        begin
          BD:='/usr/local/lib/fpc/'+FCompilerVersion;
          if not DirectoryExists(BD) and
             DirectoryExists('/usr/lib/fpc/'+FCompilerVersion) then
            BD:='/usr/lib/fpc/'+FCompilerVersion;
        end;
{$else unix}
      BD:=FixPath(GetEnvironmentVariable('FPCDIR'));
      if BD='' then
        begin
          BD:=ExtractFilePath(FCompiler)+'..';
          if not(DirectoryExists(BD+'/units')) and
             not(DirectoryExists(BD+'/rtl')) then
            BD:=FBaseInstallDir+'..';
        end;
{$endif unix}
      BaseInstallDir:=BD;
    end;
end;

{ TPackage }

function TPackage.GetHasStrings(AIndex: integer): Boolean;
begin
  Result:=False;
  Case AIndex Of
    0 : Result:=FUnitPath<>Nil;
    1 : Result:=FObjectPath<>Nil;
    2 : Result:=FIncludePath<>Nil;
    3 : Result:=FDependencies<>Nil;
    4 : Result:=FInstallFiles<>Nil;
    5 : Result:=FCleanFiles<>Nil;
    6 : Result:=FArchiveFiles<>Nil;
  end;
end;

function TPackage.GetCommands: TCommands;
begin
  If Not Assigned(FCommands) then
    FCommands:=TCommands.Create(TCommand);
  Result:=FCommands;
end;

function TPackage.GetHasCommands: Boolean;
begin
  Result:=Assigned(FCommands);
end;

Procedure SplitVersion(AValue: String; Var Release,Major,Minor : Word; Var Suffix : String);

  Function NextDigit(sep : Char; var V : string) : integer;

  Var
    P : Integer;

  begin
    P:=Pos(Sep,V);
    If (P=0) then
      P:=Length(V)+1;
    Result:=StrToIntDef(Copy(V,1,P-1),-1);
    If Result<>-1 then
      Delete(V,1,P)
    else
      Result:=0;
  end;

Var
  P : Integer;
  V : String;

begin
  Release:=0;
  Major:=0;
  Minor:=0;
  Suffix:='';
  V:=AValue;
  Release:=NextDigit('.',V);
  Major:=NextDigit('.',V);
  Minor:=NextDigit('-',V);
  P:=Pos('-',V);
  If (P<>0) then
    Delete(V,1,P);
  Suffix:=V;
end;

Function QuoteXML(S : String) : string;

  Procedure W(Var J : Integer; Var R : String; T : String);

  Var
    I: integer;

  begin
    If J+Length(T)>Length(R) then
      SetLength(R,J+Length(T));
    For I:=1 to Length(t) do
      begin
      R[J]:=T[i];
      If I<Length(T) then
        Inc(J);
      end;
  end;

const
  QuotStr = '&quot;';
  AmpStr = '&amp;';
  ltStr = '&lt;';
  gtStr = '&gt;';

Var
  I,J : Integer;

begin
  SetLength(Result,Length(S));
  J:=0;
  For I:=1 to Length(S) do
    begin
    Inc(J);
    case S[i] of
      '"': W(j,Result,QuotStr);
      '&': W(J,Result,AmpStr);
      '<': W(J,Result,ltStr);
      // Escape whitespace using CharRefs to be consistent with W3 spec X 3.3.3
       #9: w(J,Result,'&#x9;');
{      #10: wrtStr('&#xA;');
       #13: wrtStr('&#xD;');}
    else
      Result[J]:=S[i];
    end;
    If (J=Length(Result)) and (I<Length(S)) then
      SetLength(Result,J+Length(S)-I);
    end;
  If J<>Length(Result) then
    SetLength(Result,J);
end;



Procedure TPackage.GetManifest(Manifest : TStrings);
Var
  S : String;
  Release,Minor,Major : Word;
  i : Integer;
begin
  With Manifest do
    begin
    Add(Format('<package name="%s">',[QuoteXml(Name)]));
    SplitVersion(Version,Release,Minor,Major,S);
    Add(Format('<version release="%d" major="%d" minor="%d" suffix="%s"/>',[Release,Minor,Major,QuoteXMl(S)]));
    Add(Format('<filename>%s</filename>',[QuoteXml(FileName + ZipExt)]));
    Add(Format('<author>%s</author>',[QuoteXml(Author)]));
    Add(Format('<license>%s</license>',[QuoteXml(License)]));
    if ExternalURL<>'' then
      Add(Format('<externalurl>%s</externalurl>',[QuoteXml(ExternalURL)]));
    Add(Format('<email>%s</email>',[QuoteXMl(Email)]));
    S:=Description;
    If (S<>'') then
      Add(Format('<description>%s</description>',[QuoteXML(S)]));
    if HasDependencies then
      begin
        If (Dependencies.Count>0) then
          begin
            Add('<dependencies>');
            for I:=0 to Dependencies.Count-1 do
              Add(Format('<dependency><package packagename="%s"/></dependency>',[QuoteXML(Dependencies[i])]));
            Add('</dependencies>');
          end;
      end;
    Add('</package>');
    end;
end;

function TPackage.GetStrings(AIndex: integer): TStrings;

  Function EnsureStrings(Var S : TStrings) : TStrings;

  begin
    If (S=Nil) then
      S:=TStringList.Create;
    Result:=S;
  end;

begin
  Result:=Nil;
  Case AIndex Of
    0 : Result:=EnsureStrings(FUnitPath);
    1 : Result:=EnsureStrings(FObjectPath);
    2 : Result:=EnsureStrings(FIncludePath);
    3 : begin
        Result:=EnsureStrings(FDependencies);
        With TStringList(Result) do
          if (Count=0) then
            begin
            Sorted:=True;
            Duplicates:=dupError;
            end;
        end;
    4 : Result:=EnsureStrings(FInstallFiles);
    5 : Result:=EnsureStrings(FCleanFiles);
    6 : Result:=EnsureStrings(FArchiveFiles);
  end;
end;

procedure TPackage.SetCommands(const AValue: TCommands);
begin
  Commands.Assign(AValue);
end;

procedure TPackage.SetStrings(AIndex: integer; const AValue: TStrings);
begin
  GetStrings(AIndex).Assign(AValue);
end;

constructor TPackage.Create(ACollection: TCollection);

Var
  L : TStringList;

begin
  inherited Create(ACollection);
  FTargets:=TTargets.Create(TTarget);
  FSources:=TSources.Create(TSource);
  L:=TStringList.Create;
  FDependencies:=L;
  FInstallFiles:=TStringList.Create;
  FCleanFiles:=TStringList.Create;
  FArchiveFiles:=TStringList.Create;
end;

destructor TPackage.destroy;
begin
  FreeAndNil(FDependencies);
  FreeAndNil(FInstallFiles);
  FreeAndNil(FCleanFiles);
  FreeAndNil(FArchiveFiles);
  FreeAndNil(FIncludePath);
  FreeAndNil(FObjectPath);
  FreeAndNil(FUnitPath);
  FreeAndNil(FSources);
  FreeAndNil(FTargets);
  inherited destroy;
end;

function TPackage.AddTarget(AName: String): TTarget;
begin
  Result:=Targets.Add as TTarget;
  Result.Name:=AName;
end;

procedure TPackage.AddDependency(AName: String);
begin
  If FDependencies.IndexOf(AName)=-1 then
    FDependencies.Add(AName);
end;

procedure TPackage.AddInstallFile(AFileName: String);
begin
  FInstallFiles.add(AFileName);
end;

procedure TPackage.GetCleanFiles(List: TStrings; Const APrefixU, APrefixB : String; AOS : TOS);

Var
  I : Integer;

begin
  AddStrings(List,CleanFiles,APrefixU);
  For I:=0 to FTargets.Count-1 do
    FTargets.TargetItems[I].GetCleanFiles(List, APrefixU, APrefixB, AOS);
end;

procedure TPackage.GetInstallFiles(List: TStrings;Types : TTargetTypes;Const APrefix, APrefixU, APrefixB: String; AOS : TOS);
Var
  I : Integer;
  T : TTarget;
begin
  AddStrings(List,InstallFiles,APrefix);
  For I:=0 to FTargets.Count-1 do
    begin
    T:=FTargets.TargetItems[I];
    if (T.TargetType in Types)  then
      T.GetInstallFiles(List, APrefixU, APrefixB, AOS);
    end;
end;


procedure TPackage.GetArchiveFiles(List: TStrings;Const APrefix : String; AOS : TOS);

Var
  I : Integer;

begin
  If (OS=[]) or (AOS in OS) then
    begin
    AddStrings(List,ArchiveFiles,APrefix);
    For I:=0 to FTargets.Count-1 do
      FTargets.TargetItems[I].GetArchiveFiles(List,APrefix,AOS);
    end;
end;

Function TPackage.GetDescription : string;

Var
  FN : String;
  L : TStringList;

begin
  If (FDescription<>'') then
    Result:=FDescription
  else
    If (FDescriptionFile<>'') then
      begin
      // Always relative to binary name.
      FN:=ExtractFilePath(ParamStr(0));
      FN:=FN+FDescriptionFile;
      If FileExists(FN) then
        begin
        L:=TStringList.Create;
        Try
          L.LoadFromFile(FN);
          Result:=L.Text;
        Finally
          L.Free;
        end;
        end;
      end;
end;


Function TPackage.GetFileName : string;
begin
  If (FFileName<>'') then
    Result:=FFileName
  else
    if Version <> '' then
      Result := Name + '-' + Version
    else
      Result := Name;
end;


{ TPackages }

function TPackages.GetPackage(const AName : String): TPackage;
begin
  Result:=TPackage(ItemByName(AName))
end;

function TPackages.GetPackageItem(AIndex : Integer): TPackage;
begin
  Result:=TPackage(Items[AIndex]);
end;

procedure TPackages.SetPackageItem(AIndex : Integer; const AValue: TPackage);
begin
  Items[AIndex]:=AValue;
end;

function TPackages.AddPackage(const AName: String): TPackage;
begin
  Result:=Add as TPackage;
  Result.Name:=AName;
end;


{ TCustomInstaller }

function TCustomInstaller.GetStrings(AIndex : Integer): TStrings;
begin
  CheckDefaultPackage;
  Case AIndex of
    0:  Result:=DefaultPackage.Dependencies;
    1:  Result:=DefaultPackage.InstallFiles;
    2:  Result:=DefaultPackage.CleanFiles;
    3:  Result:=DefaultPackage.ArchiveFiles;
  end;
end;

function TCustomInstaller.GetBaseInstallDir: string;
begin
  Result := Defaults.BaseInstallDir;
end;

Function TCustomInstaller.GetPackageString(Index : Integer) : String;
Var
  P : TPackage;
begin
  CheckDefaultPackage;
  P:=DefaultPackage;
  Case Index of
    0 : Result:=P.Author;
    1 : Result:=P.Directory;
    2 : Result:=P.License;
    3 : Result:=P.Options;
    4 : Result:=P.ExternalURL;
    5 : Result:=P.Email;
    6 : Result:=P.Description;
    7 : Result:=P.DescriptionFile;
    8 : Result:=P.Version;
    9 : Result:=P.FileName + ZipExt;
  end;
end;


Procedure TCustomInstaller.SetPackageString(Index : Integer; const AValue : String);

Var
  P : TPackage;

begin
  CheckDefaultPackage;
  P:=DefaultPackage;
  Case Index of
    0 : P.Author:=AValue;
    1 : P.Directory:=AValue;
    2 : P.License:=AValue;
    3 : P.Options:=AValue;
    4 : P.ExternalURL:=AValue;
    5 : P.Email:=AValue;
    6 : P.Description:=AValue;
    7 : P.DescriptionFile:=AValue;
    8 : P.Version:=AValue;
    9 : P.FileName:=AValue;
  end;
end;


function TCustomInstaller.GetOSes: TOSes;
begin
  CheckDefaultPackage;
  Result:=DefaultPackage.OS;
end;

function TCustomInstaller.GetTargets: TTargets;
begin
  CheckDefaultPackage;
  Result:=DefaultPackage.Targets;
end;

function TCustomInstaller.GetSources: TSources;
begin
  CheckDefaultPackage;
  Result:=DefaultPackage.Sources;
end;

procedure TCustomInstaller.SetBaseInstallDir(const AValue: string);
begin
  if AValue <> Defaults.BaseInstallDir then
    Defaults.BaseInstallDir := AValue;
end;

procedure TCustomInstaller.SetDefaultPackage(const AValue: TPackage);
begin
  if FDefaultPackage=AValue then exit;
  FDefaultPackage:=AValue;
end;

procedure TCustomInstaller.SetDefaults(const AValue: TCustomDefaults);
begin
  FDefaults.Assign(AValue);
end;

procedure TCustomInstaller.SetStrings(AIndex : Integer; const AValue: TStrings);

Var
  Res : TStrings;

begin
  CheckDefaultPackage;
  Case AIndex of
    0:  Res:=DefaultPackage.Dependencies;
    1:  Res:=DefaultPackage.InstallFiles;
    2:  Res:=DefaultPackage.CleanFiles;
    3:  Res:=DefaultPackage.ArchiveFiles;
  end;
  Res.Assign(Avalue);
end;

procedure TCustomInstaller.SetOses(const AValue: TOSes);
begin
  CheckDefaultPackage;
  DefaultPackage.OS:=AValue;
end;

procedure TCustomInstaller.SearchFiles(const AFileName: string; Recursive: boolean;
  var List: TStrings);

  procedure AddRecursiveFiles(const SearchDir, FileMask: string; Recursive: boolean);
  var
    Info : TSearchRec;
  begin
    if FindFirst(SearchDir+'*',faAnyFile and faDirectory,Info)=0 then
    begin
      repeat
          if ((Info.Attr and faDirectory) = faDirectory) and (Info.Name <> '.') and (Info.Name <> '..') and (Recursive) then
            AddRecursiveFiles(SearchDir + Info.Name + PathDelim, FileMask, Recursive);

          {$IFDEF UNIX}
          if ((Info.Attr and faDirectory) <> faDirectory) and IsWild(Info.Name, FileMask, False) then
          {$ELSE}
          if ((Info.Attr and faDirectory) <> faDirectory) and IsWild(Info.Name, FileMask, True) then
          {$ENDIF}
            List.Add(SearchDir + Info.Name);
      until FindNext(Info)<>0;
    end;
    FindClose(Info);
  end;

var
  BasePath: string;
  i: integer;
begin
  BasePath := ExtractFilePath(ExpandFileName(FileName));
  AddRecursiveFiles(BasePath, ExtractFileName(FileName), Recursive);

  for i := 0 to Pred(List.Count) do
    List[i] := ExtractRelativepath(ExtractFilePath(ParamStr(0)), List[i]);

end;

procedure TCustomInstaller.Log(Level: TVerboseLevel; const Msg: String);
begin
  If Level in FLogLevels then
    Writeln(StdErr,Msg);
end;

procedure TCustomInstaller.CreatePackages;
begin
  FPAckages:=TPackages.Create(TPackage);
end;

procedure TCustomInstaller.CreateBuildEngine;
begin
  FBuildEngine:=TBuildEngine.Create(Self);
  FBuildEngine.Defaults:=Defaults;
  FBuildEngine.ListMode:=FListMode;
  FBuildEngine.OnLog:=@Self.Log;
end;

procedure TCustomInstaller.CheckDefaultPackage;
begin
  If (FDefaultPackage=Nil) then
    Raise EInstallerError.Create(SErrNoPackage);
end;

procedure TCustomInstaller.Error(const Msg: String);
begin
  Raise EInstallerError.Create(Msg);
end;

procedure TCustomInstaller.Error(const Fmt: String; Args: array of const);
begin
  Raise EInstallerError.CreateFmt(Fmt,Args);
end;

Function TCustomInstaller.StartPackage(const AName: String) : TPackage;
begin
  FDefaultPackage:=FPackages.AddPackage(AName);
  Result:=FDefaultPackage;
end;

procedure TCustomInstaller.EndPackage;
begin
  FDefaultPackage:=Nil;
end;

procedure TCustomInstaller.AnalyzeOptions;

  Function CheckOption(Index : Integer;const Short,Long : String): Boolean;

  var
    O : String;

  begin
    O:=Paramstr(Index);
    Result:=(O='-'+short) or (O='--'+long) or (copy(O,1,Length(Long)+3)=('--'+long+'='));
  end;

  Function CheckCommand(Index : Integer;const Short,Long : String): Boolean;

  var
    O : String;

  begin
    O:=Paramstr(Index);
    Result:=(O='-'+short) or (O=long);
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
  Nodefaults : Boolean;
  DefaultsFileName : string;

begin
  I:=0;
  NoDefaults:=False;
  FListMode:=False;
  FLogLevels := [vlError,vlWarning,vlInfo];
  While (I<ParamCount) do
    begin
    Inc(I);
    if CheckOption(I,'v','verbose') then
      begin
      Try
        FLogLevels:=TVerboseLevels(StringToSet(PtypeInfo(TypeInfo(TVerboseLevels)),OptionArg(I)));
      except
        FLogLevels:=AllMessages;
      end;
      end
    else if CheckCommand(I,'m','compile') then
      FRunMode:=rmCompile
    else if CheckCommand(I,'b','build') then
      FRunMode:=rmBuild
    else if CheckCommand(I,'i','install') then
      FRunMode:=rmInstall
    else if CheckCommand(I,'c','clean') then
      FRunMode:=rmClean
    else if CheckCommand(I,'a','archive') then
      FRunMode:=rmarchive
    else if CheckCommand(I,'M','manifest') then
      FRunMode:=rmManifest
    else if CheckCommand(I,'M','listsources') then
      FRunMode:=rmListSources
    else if CheckOption(I,'h','help') then
      Usage('',[])
    else if Checkoption(I,'C','CPU') then
      Defaults.CPU:=StringToCPU(OptionArg(I))
    else if Checkoption(I,'O','OS') then
      Defaults.OS:=StringToOS(OptionArg(I))
    else if Checkoption(I,'t','target') then
      Defaults.Target:=OptionArg(I)
    else if CheckOption(I,'l','list-commands') then
      FListMode:=True
    else if Checkoption(I,'P','prefix') then
      Defaults.Prefix:=OptionArg(I)
    else if Checkoption(I,'n','nodefaults') then
      NoDefaults:=true
    else if CheckOption(I,'B','baseinstalldir') then
      Defaults.BaseInstallDir:=OptionArg(I)
    else if CheckOption(I,'UL','localunitdir') then
      Defaults.LocalUnitDir:=OptionArg(I)
    else if CheckOption(I,'UG','globalunitdir') then
      Defaults.GlobalUnitDir:=OptionArg(I)
    else if CheckOption(I,'r','compiler') then
      Defaults.Compiler:=OptionArg(I)
    else if CheckOption(I,'f','config') then
      DefaultsFileName:=OptionArg(I)
    else
      begin
      Usage(SErrInValidArgument,[I,ParamStr(I)]);
      end;
    end;
  If Not NoDefaults then
    Defaults.LocalInit(DefaultsFileName);
  Defaults.CompilerDefaults;
{$ifdef debug}
  FLogLevels:=AllMessages;
{$endif}
end;

procedure TCustomInstaller.Usage(const FMT: String; Args: array of const);

  Procedure LogCmd(const LC,Msg : String);
  begin
    Log(vlInfo,Format(' %-12s %s',[LC,MSG]));
  end;

  Procedure LogOption(const C,LC,Msg : String);
  begin
    Log(vlInfo,Format(' -%s --%-16s %s',[C,LC,MSG]));
  end;

  Procedure LogArgOption(const C,LC,Msg : String);
  begin
    Log(vlInfo,Format(' -%s --%-20s %s',[C,LC+'='+SValue,MSG]));
  end;

begin
  If (FMT<>'') then
    Log(vlInfo,Format(Fmt,Args));
  Log(vlInfo,Format(SHelpUsage,[Paramstr(0)]));
  Log(vlInfo,SHelpCommand);
  LogCmd('compile',SHelpCompile);
  LogCmd('build',SHelpBuild);
  LogCmd('install',SHelpInstall);
  LogCmd('clean',SHelpClean);
  LogCmd('archive',SHelpArchive);
  LogCmd('manifest',SHelpManifest);
  LogCmd('listsources',SHelpListSources);
  Log(vlInfo,SHelpCmdOptions);
  LogOption('h','help',SHelpHelp);
  LogOption('l','list-commands',SHelpList);
  LogOption('n','nodefaults',SHelpNoDefaults);
  LogOption('v','verbose',SHelpVerbose);
  LogArgOption('C','CPU',SHelpCPU);
  LogArgOption('O','OS',SHelpOS);
  LogArgOption('t','target',SHelpTarget);
  LogArgOption('P','prefix',SHelpPrefix);
  LogArgOption('B','baseinstalldir',SHelpBaseInstalldir);
  LogArgOption('UL','localunitdir',SHelpLocalUnitdir);
  LogArgOption('UG','globalunitdir',SHelpGlobalUnitdir);
  LogArgOption('r','compiler',SHelpCompiler);
  LogArgOption('f','config',SHelpConfig);
  Log(vlInfo,'');
  If (FMT<>'') then
    halt(1)
  else
    halt(0);
end;

procedure TCustomInstaller.Compile(Force: Boolean);
begin
  FBuildEngine.ForceCompile:=Force;
  FBuildEngine.Compile(FPackages);
end;

procedure TCustomInstaller.Clean;
begin
  BuildEngine.Clean(FPackages);
end;

procedure TCustomInstaller.Install;
begin
  BuildEngine.Install(FPackages);
end;

procedure TCustomInstaller.Archive;
begin
  FBuildEngine.Archive(FPackages);
end;

procedure TCustomInstaller.Manifest;

Var
  L : TStrings;
begin
  L:=TStringList.Create;
  Try
    Log(vlCommand, Format(SCmdGenerating, [ManifestFile]));
    L.Add('<?xml version="1.0"?>');
    BuildEngine.GetManifest(FPackages,L);
    L.SaveToFile(ManifestFile);
  Finally
    L.Free;
  end;
end;

procedure TCustomInstaller.GetSourceFiles;

Var
  L : TStrings;
begin
  L:=TStringList.Create;
  Try
    Log(vlCommand,'Generating sources.xml');
    L.Add('<?xml version="1.0"?>');
    BuildEngine.GetSourceFiles(FPackages,L);
    L.SaveToFile('sources.xml');
  Finally
    L.Free;
  end;
end;

destructor TCustomInstaller.destroy;
begin
  FreeAndNil(FDefaults);
  inherited destroy;
end;

procedure TCustomInstaller.CheckPackages;

begin
  If (FPackages.Count=0) then
    Error(SErrNoPackagesDefined);
  // Check for other obvious errors ?
end;

Function TCustomInstaller.Run : Boolean;

begin
  Result:=True;
  try
    CheckPackages;
    CreateBuildEngine;
    Case RunMode of
      rmCompile : Compile(False);
      rmBuild   : Compile(True);
      rmInstall : Install;
      rmArchive : Archive;
      rmClean    : Clean;
      rmManifest : Manifest;
      rmListSources : GetSourceFiles;
    end;
  except
    On E : Exception do
      begin
      Log(vlError,SErrInstaller);
      Log(vlError,E.Message);
      Result:=False;
      end;
  end;
  // Force returning an exitcode to the shell
  if not Result then
    ExitCode:=1;
end;

function TCustomInstaller.AddTarget(const AName: String): TTarget;
begin
  CheckDefaultPackage;
  Result:=DefaultPackage.AddTarget(AName);
end;

procedure TCustomInstaller.AddDependency(const AName: String);
begin
  CheckDefaultPackage;
  DefaultPackage.AddDependency(AName);
end;

procedure TCustomInstaller.AddDocFiles(const AFileMask: string; Recursive: boolean);
var
  List : TStrings;
  i: integer;
begin
  List := TStringList.Create;
  SearchFiles(AFileMask, Recursive, List);

  for i:= 0 to Pred(List.Count) do
    FDefaultPackage.Sources.AddDocFiles(List[i]);

  List.Free;
end;

procedure TCustomInstaller.AddSrcFiles(const AFileMask: string; Recursive: boolean);
var
  List : TStrings;
  i: integer;
begin
  List := TStringList.Create;
  SearchFiles(AFileMask, Recursive, List);

  for i:= 0 to Pred(List.Count) do
    FDefaultPackage.Sources.AddSrcFiles(List[i]);

  List.Free;
end;

procedure TCustomInstaller.AddExampleFiles(const AFileMask: string; Recursive: boolean);
var
  List : TStrings;
  i: integer;
begin
  List := TStringList.Create;
  SearchFiles(AFileMask, Recursive, List);

  for i:= 0 to Pred(List.Count) do
    FDefaultPackage.Sources.AddExampleFiles(List[i]);

  List.Free;
end;

procedure TCustomInstaller.AddTestFiles(const AFileMask: string; Recursive: boolean);
var
  List : TStrings;
  i: integer;
begin
  List := TStringList.Create;
  SearchFiles(AFileMask, Recursive, List);

  for i:= 0 to Pred(List.Count) do
    FDefaultPackage.Sources.AddTestFiles(List[i]);

  List.Free;
end;

{ TFPCInstaller }

constructor TFPCInstaller.Create(AOwner: TComponent);
begin
  FDefaults:=TFPCDefaults.Create;
  AnalyzeOptions;
  CreatePackages;
end;

{ TBasicInstaller }

constructor TBasicInstaller.Create(AOwner: TComponent);
begin
  FDefaults:=TBasicDefaults.Create;
  AnalyzeOptions;
  CreatePackages;
end;

{ TBuildEngine }

procedure TBuildEngine.SetDefaults(const AValue: TCustomDefaults);
begin
  FDefaults.Assign(AValue);
end;

procedure TBuildEngine.SetTargetDir(const AValue: String);
begin
  if FTargetDir=AValue then exit;
  FTargetDir:=AValue;
end;

procedure TBuildEngine.Error(const Msg: String);
begin
  Raise EInstallerError.Create(Msg);
end;

procedure TBuildEngine.Error(const Fmt: String; Args: array of const);
begin
  Raise EInstallerError.CreateFmt(Fmt,Args);
end;

constructor TBuildEngine.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDefaults:=TCustomDefaults.Create;
  // Maybe this should be the current directory ?
  // Or have it as a command-line option.
  // Would allow to put all 'installers' in one dir and call them
  // With --start-dir=/path/to/sources.
  FStartDir:=includeTrailingPathDelimiter(GetCurrentDir);
end;

procedure TBuildEngine.ExecuteCommand(const Cmd,Args : String; IgnoreError : Boolean = False);

Var
  E : Integer;

begin
  Log(vlCommand,SLogExecutingCommand,[Cmd,Args]);
  // We should check cmd for spaces, and move all after first space to args.
  E:=ExecuteProcess(cmd,args);
  If (E<>0) and (not IgnoreError) then
    Error(SErrExternalCommandFailed,[Cmd,E]);
end;

procedure TBuildEngine.SysCopyFile(Const Src,Dest : String);

Var
  D,S : String;
  Fin,FOut : TFileStream;
  Count : Int64;
  A : Integer;

begin
  Log(vlCommand,SLogCopyingFile,[Src,Dest]);
  FIn:=TFileStream.Create(Src,fmopenRead);
  Try
    D:=IncludeTrailingPathDelimiter(Dest);
    If DirectoryExists(D) then
      S:=D+ExtractFileName(Src)
    else
      S:=Dest;
    FOut:=TFileStream.Create(S,fmCreate);
    Try
      Count:=Fout.CopyFrom(FIn,0);
      If (Count<>Fin.Size) then
        Error(SErrCopyingFile,[Src,S]);
    Finally
      FreeAndNil(Fout);
    end;
    A:=FileGetDate(FIn.Handle);
    If (A=-1) then
      log(vlWarning,SWarnFailedToGetTime,[Src])
    else
      if FileSetDate(S,A)<>0 then
        Log(vlWarning,SWarnFailedToSetTime,[S]);
  finally
    FreeAndNil(Fin);
  end;
end;

procedure TBuildEngine.SysMoveFile(Const Src,Dest : String);

Var
  S : String;

begin
    If DirectoryExists(IncludeTrailingPathDelimiter(Dest)) then
      S:=IncludeTrailingPathDelimiter(Dest)+ExtractFileName(Src)
    else
      S:=Dest;
  If Not RenameFile(Src,S) then
    begin
    Try
      SysCopyFile(Src,S);
      SysDeleteFile(Src);
    Except
      On E : Exception Do
        Error(SErrMovingFile,[Src,S]);
    end;
    end;
end;

procedure TBuildEngine.SysDeleteFile(Const AFileName : String);

begin
  if not FileExists(AFileName) then
    Log(vlWarning,SWarnFileDoesNotExist,[AFileName])
  else If Not DeleteFile(AFileName) then
    Error(SErrDeletingFile,[AFileName]);
end;


procedure TBuildEngine.SysArchiveFiles(List: TStrings;Const AFileName: String);
begin
  If Not (Assigned(OnArchivefiles) or Assigned(ArchiveFilesProc)) then
    Raise EInstallerError.Create(SErrNoArchiveSupport);
  If Assigned(ArchiveFilesProc) then
    ArchiveFilesProc(AFileName,List)
  else
    OnArchiveFiles(AFileName,List);
end;

procedure TBuildEngine.Log(Level: TVerboseLevel; const Msg: String);
begin
  If Assigned(FOnLog) then
    FOnLog(Level,Msg);
end;

procedure TBuildEngine.Log(Level: TVerboseLevel; const Fmt: String;
  Args: array of const);
begin
  Log(Level,Format(Fmt,Args));
end;

procedure TBuildEngine.EnterDir(ADir: String);

Var
  D : String;

begin
  D:=FStartDir;
  D:=D+ADir;
  Log(vlInfo,SLogEnterDir,[D]);
  If Not SetCurrentDir(D) then
    Error(SErrChangeDirFailed,[D]);
end;


procedure TBuildEngine.CmdCopyFiles(List: TStrings; Const DestDir: String);

Var
  Args : String;
  I : Integer;

begin
  CmdCreateDir(DestDir);
  If (Defaults.Copy<>'') then
    begin
    Args:=FileListToString(List,'');
    Args:=Args+' '+DestDir;
    ExecuteCommand(Defaults.Copy,Args);
    end
  else
    For I:=0 to List.Count-1 do
      SysCopyFile(List[i],DestDir);
end;

procedure TBuildEngine.CmdCreateDir(const DestDir: String);

begin
  If (Defaults.MkDir<>'') then
    ExecuteCommand(Defaults.MkDir,DestDir)
  else
    If not ForceDirectories(DestDir) then
      Error(SErrCreatingDirectory,[DestDir]);
end;

procedure TBuildEngine.CmdMoveFiles(List: TStrings; Const DestDir: String);

Var
  Args : String;
  I : Integer;

begin
  CmdCreateDir(DestDir);
  If (Defaults.Move<>'') then
    begin
    Args:=FileListToString(List,'');
    Args:=Args+' '+DestDir;
    ExecuteCommand(Defaults.Move,Args);
    end
  else
    For I:=0 to List.Count-1 do
      SysMoveFile(List[i],DestDir);
end;

procedure TBuildEngine.CmdDeleteFiles(List: TStrings);

Var
  Args : String;
  I : Integer;

begin
  If (Defaults.Remove<>'') then
    begin
    Args:=FileListToString(List,'');
    ExecuteCommand(Defaults.Remove,Args);
    end
  else
    For I:=0 to List.Count-1 do
      SysDeleteFile(List[i]);
end;

procedure TBuildEngine.CmdArchiveFiles(List: TStrings; Const ArchiveFile: String);

Var
  S,C,O : String;

begin
  If (Defaults.Archive='') then
    SysArchiveFiles(List,ArchiveFile)
  else
    begin
    S:=FileListToString(List,'');
    SplitCommand(Defaults.Archive,C,O);
    If (O='') then
      O:=ArchiveFile+' '+S
    else
      O:=Substitute(O,['ARCHIVE',ArchiveFile,'FILESORDIRS']);
    ExecuteCommand(C,O);
    end;
end;

Function TBuildEngine.FileNewer(const Src,Dest : String) : Boolean;

Var
  DS,DD : Longint;
  D1,D2 : TDateTime;

begin
  DS:=FileAge(Src);
  DD:=FileAge(Dest);
  D1:=FileDateToDateTime(DS);
  D2:=FileDateToDateTime(DD);
  Log(vlDebug,SLogCompilingFileTimes,[Src,DateTimeToStr(D1),Dest,DateTimeToStr(D2)]);
  Result:=D1>=D2;
  If Result then
    Log(vlCompare,SLogSourceNewerDest,[Src,DateTimeToStr(D1),Dest,DateTimeToStr(D2)]);
end;

procedure TBuildEngine.ExecuteCommands(Commands: TCommands; At: TCommandAt);

Var
  C : TCommand;
  I : Integer;
  Cmd,O : String;
  E : Boolean;

begin
  For I:=0 to Commands.Count-1 do
    begin
    C:=Commands.CommandItems[i];
    if (C.At=At) then
      begin
      E:=True;
      If (C.SourceFile<>'') and (C.DestFile<>'')  then
        E:=FileNewer(C.SourceFile,IncludeTrailingPathDelimiter(Dictionary.GetValue('OUTPUTDIR'))+C.DestFile);
      If E then
        begin
        If Assigned(C.BeforeCommand) then
          C.BeforeCommand(C);
        O:=Substitute(C.Options,['SOURCE',C.SourceFile,'DEST',C.DestFile]);
        Cmd:=C.Command;
        If (ExtractFilePath(Cmd)='') then
          Cmd:=FileSearch(Cmd,GetEnvironmentvariable('PATH'));
        ExecuteCommand(Cmd,O,C.IgnoreResult);
        If Assigned(C.AfterCommand) then
          C.AfterCommand(C);
        end;
      end;
    end;
end;

// Relative to startdir.
Function TBuildEngine.GetTargetDir(APackage : TPackage; ATarget : TTarget; AbsolutePath : Boolean = False) : String;

begin
  If AbsolutePath then
    Result:=IncludeTrailingPathDelimiter(FStartDir)
  else
    Result:='';
  If (APackage.Directory<>'') then
    Result:=Result+IncludeTrailingPathDelimiter(APackage.Directory);
  If (ATarget.Directory<>'') then
    Result:=IncludeTrailingPathDelimiter(Result+ATarget.Directory);

end;

Function TBuildEngine.TargetOK(Target : TTarget) : Boolean;

begin
  Result:=(Target.TargetType in [ttUnit,ttImplicitUnit,ttProgram])
          and
          ((Target.CPU=[]) or (Defaults.CPU in Target.CPU))
          and
          ((Target.OS=[]) or (Defaults.OS in Target.OS));
  If not Result then
    begin
    log(vldebug, SDebugTargetIsNotAUnitOrProgram);
    If Not ((Target.CPU=[]) or (Defaults.CPU in Target.CPU)) then
      Log(vldebug, Format(SDebugTargetHasWrongCPU, [CPUsToString(Target.CPU)]));
    if not ((Target.OS=[]) or (Defaults.OS in Target.OS)) then
      Log(vldebug, Format(SDebugTargetHasWrongOS, [OSesToString(Target.OS)]));
    end;
end;

Function TBuildEngine.NeedsCompile(Target: TTarget): Boolean;

Var
  I : Integer;
  T : TTarget;
  OD,SD,SFN,OFN : String;

begin
  Result:=False;
  OFN:=Target.GetOutPutFileName(Defaults.OS);

  if Target.TargetType in ProgramTargets then
    OD:=GetBinOutputDir(FCurrentPackage, True)
  else
    OD:=GetUnitsOutputDir(FCurrentPackage, True);

  If (OD<>'') then
    OD:=IncludeTrailingPathDelimiter(OD);
  OFN:=OD+OFN;

  SD:=Target.Directory;
  If (SD<>'') then
      SD:=IncludeTrailingPathDelimiter(SD);

  Result:=Not FileExists(OFN);
  Log(vldebug, SDebugCheckingS, [OFN]);

  // Check dependencies
  If not Result then
    If Target.HasDependencies then
      begin
      ResolveDependencies(Target.Dependencies,Target.Collection as TTargets);
      I:=0;
      While (Not Result) and (I<Target.Dependencies.Count) do
        begin
        T:=TTarget(Target.Dependencies.Objects[i]);
        If (T<>Nil) then
          Result:=NeedsCompile(T)
        else // if it is a filename, check dates.
          if FileExists(Target.Dependencies[i]) then
            Result:=FileNewer(Target.Dependencies[i],OFN)
          else if FileExists(SD+Target.Dependencies[i]) then
            Result:=FileNewer(SD+Target.Dependencies[i],OFN);
        Inc(I)
        end;
      end;
  If not Result then
    begin
    SFN:=SD+Target.SourceFileName;
    If (ExtractFileExt(SFN)='') then
      if FileExists(SFN+PPUExt) then
        SFN:=SFN+PPUExt
      else
        SFN:=SFN+PASExt;
    Log(vldebug, SDebugCheckingSAgainstS, [OFN, SFN]);
    Result:=FileNewer(SFN,OFN);
    // here we should check file timestamps.
    end;
end;



Function TBuildEngine.GetCompilerCommand(APackage : TPackage; Target : TTarget) : String;

Var
  PD,TD,OD : String;

begin
  PD:=IncludeTrailingPathDelimiter(GetPackageDir(APackage,True));

  Result := '-n';
  // Compile mode
  If Target.Mode<>cmFPC then
    Result:=Result+' -M'+ModeToString(Target.Mode)
  else If Defaults.Mode<>cmFPC then
    Result:=Result+' -M'+ModeToString(Defaults.Mode);
  // Output file paths
  If Target.TargetType in ProgramTargets then
    begin
      OD:=IncludeTrailingPathDelimiter(GetBinOutputDir(APackage,True));
      Result:=Result+' -FE' + ExtractRelativePath(PD,OD);
    end;
  OD:=IncludeTrailingPathDelimiter(GetUnitsOutputDir(APackage,True));
  Result := Result + ' -FU' + ExtractRelativePath(PD,OD);
  // Package Input file paths
  If APackage.HasUnitPath then
    AddStrings(Result,APackage.UnitPath,'-Fu');
  If APackage.HasIncludePath then
    AddStrings(Result,APackage.IncludePath,'-Fi');
  If APackage.HasObjectPath then
    AddStrings(Result,APackage.ObjectPath,'-Fo');
  If Target.HasUnitPath then
    AddStrings(Result,Target.UnitPath,'-Fu');
  If Target.HasIncludePath then
    AddStrings(Result,Target.IncludePath,'-Fi');
  If Target.HasObjectPath then
    AddStrings(Result,Target.ObjectPath,'-Fo');
  // Global unit dirs
  If Defaults.LocalUnitDir<>'' then
    Result:=Result+' -Fu'+includeTrailingPathDelimiter(Defaults.LocalUnitDir)+'*';
  If Defaults.GlobalUnitDir<>'' then
    Result:=Result+' -Fu'+includeTrailingPathDelimiter(Defaults.GlobalUnitDir)+'*';
  // Custom Options
  If (Defaults.Options<>'') then
    Result:=Result+' '+Defaults.Options;
  If (APackage.Options<>'') then
    Result:=Result+' '+APackage.Options;
  If (Target.Options<>'') then
    Result:=Result+' '+Target.Options;
  TD:=Target.Directory;
  if (TD<>'') then
    TD:=IncludeTrailingPathDelimiter(TD);
  Result:=Result+' '+TD+Target.SourceFileName;
end;

Function TBuildEngine.GetCompiler : String;

Var
  S : String;

begin
  // Cache in FCompiler for speed.
  If (FCompiler='') then
    begin
    FCompiler:=Defaults.Compiler;
    If (ExtractFilePath(FCompiler)='') then
      begin
      S:=FileSearch(FCompiler,GetEnvironmentVariable('PATH'));
      If (S<>'') then
         FCompiler:=S;
      end;
    end;
  Result:=FCompiler;
end;

procedure TBuildEngine.Compile(Target: TTarget);

Var
  S : String;

begin
  if Target.State in [tsNeutral,tsCompiling] then
    begin
    Log(vlInfo,SLogCompilingTarget,[Target.Name]);
    If Target.HasCommands then
      ExecuteCommands(Target.Commands,caBeforeCompile);
    If Assigned(Target.BeforeCompile) then
      Target.BeforeCompile(Target);
    S:=GetCompilerCommand(FCurrentPackage,Target);
    ExecuteCommand(GetCompiler,S);
    Target.FTargetState:=tsCompiled;
    If Assigned(Target.AfterCompile) then
      Target.AfterCompile(Target);
    If Target.HasCommands then
      ExecuteCommands(Target.Commands,caAfterCompile);
    end
  else if Target.State<>tsCompiled then
    Log(vlWarning, Format(SWarnAttemptingToCompileNonNeutralTarget, [Target.Name])
      );
end;


procedure TBuildEngine.FixDependencies(Target: TTarget);

Var
  I : Integer;
  T : TTarget;

begin
  Log(vlDebug, Format(SDebugCheckingDependenciesForTarget, [Target.Name]));
  ResolveDependencies(Target.Dependencies,Target.Collection as TTargets);
  If Target.HasDependencies then
    For I:=0 to Target.Dependencies.Count-1 do
      begin
      T:=TTarget(Target.Dependencies.Objects[i]);
      If Assigned(T) then
        begin
        If (T.State=tsCompiling) then
          Log(vlWarning,SWarnCircularDependency,[Target.Name,T.Name])
        else
          Compile(T)
        end
      else if Not FileExists(Target.Dependencies[i]) then
        Error(SErrDepUnknownTarget,[Target.Name,Target.Dependencies[i]]);
      end;
end;

function TBuildEngine.GetPackageDir(APackage: TPackage; AbsolutePath: Boolean
  ): String;
begin
  If AbsolutePath then
    Result:= IncludeTrailingPathDelimiter(FStartDir)
  else
    Result:='';
  Result:=Result+APackage.Directory;
  If (Result<>'') then
    Result:= ExcludeTrailingPathDelimiter(Result)
end;

Function TBuildEngine.GetOutputDir(AName: string; APackage : TPackage; AbsolutePath : Boolean = False) : String;
begin
  If (TargetDir<>'') then
    Result:=TargetDir
  else
    begin
    If AbsolutePath then
      Result:=IncludeTrailingPathDelimiter(FStartDir)
    else
      Result:='';
    If (APackage.Directory<>'') then
      Result:=IncludeTrailingPathDelimiter(Result+APackage.Directory);
    Result := IncludeTrailingPathDelimiter(Result + AName + PathDelim + Defaults.Target);
    end;
end;

Function TBuildEngine.GetUnitsOutputDir(APackage : TPackage; AbsolutePath : Boolean = False) : String;
begin
  Result := GetOutputDir('units', APackage, AbsolutePath);
end;

Function TBuildEngine.GetBinOutputDir(APackage : TPackage; AbsolutePath : Boolean = False) : String;
begin
  Result := GetOutputDir('bin', APackage, AbsolutePath);
end;

procedure TBuildEngine.CreateOutputDir(APackage: TPackage);
Var
  D : String;
  i: integer;
begin
  //create a units directory
  D:=GetUnitsOutputDir(APackage,True);
  If DirectoryExists(D) then
    Log(vlInfo,SLogOutputDirExists,[D])
  else
    begin
    Log(vlInfo,SLogCreatingOutputDir,[D]);
    CmdCreateDir(D);
    end;

  //also create a bin directory for programtargets
  For i := 0 to Pred(APackage.Targets.Count) do
  begin
    if APackage.Targets.TargetItems[i].TargetType in ProgramTargets then
    begin
      D:=GetBinOutputDir(APackage,True);
      If DirectoryExists(D) then
        Log(vlInfo,SLogOutputDirExists,[D])
      else
      begin
        Log(vlInfo,SLogCreatingOutputDir,[D]);
        CmdCreateDir(D);
      end;

      exit; //do not continue loop, directory is made anyway
    end;
  end;
end;

Function TBuildEngine.PackageOK(APackage : TPackage) : Boolean;

begin
  Result:=((APackage.CPU=[]) or (Defaults.CPU in APackage.CPU))
          and
          ((APAckage.OS=[]) or (Defaults.OS in APackage.OS));
end;


procedure TBuildEngine.DoBeforeCompile(APackage: TPackage);
begin
  If APackage.HasCommands then
    ExecuteCommands(APackage.Commands,caBeforeCompile);
  If Assigned(APackage.BeforeCompile) then
    APackage.BeforeCompile(APackage);
end;

procedure TBuildEngine.DoAfterCompile(APackage: TPackage);
begin
  If Assigned(APackage.AfterCompile) then
    APackage.AfterCompile(APackage);
  If APackage.HasCommands then
    ExecuteCommands(APackage.Commands,caAfterCompile);
end;

procedure TBuildEngine.Compile(APackage: TPackage);
Var
  T : TTarget;
  I : Integer;
begin
  Log(vlInfo,SLogCompilingPackage,[APackage.Name]);
  FCurrentPackage:=APackage;
  FCurrentOutputDir:=GetUnitsOutputDir(APackage,True);
  Try
    If (APackage.Directory<>'') then
      EnterDir(APackage.Directory);
    CreateOutputDir(APackage);
    Dictionary.AddVariable('OUTPUTDIR',FCurrentOutputDir);
    DoBeforeCompile(APackage);
    Try
      For I:=0 to APackage.Targets.Count-1 do
        begin
        T:=APackage.Targets.TargetItems[i];
        Log(vlDebug, Format(SDebugConsideringTarget, [T.Name]));
        If TargetOK(T) then
          If (T.State=tsNeutral) then
            begin
            If (FForceCompile or NeedsCompile(T)) then
              begin
              T.FTargetState:=tsCompiling;
              FixDependencies(T);
              Compile(T);
              end;
            T.FTargetState:=tsCompiled;
            end;
        end;
      DoAfterCompile(APackage);
    Finally
      If (APackage.Directory<>'') then
        EnterDir('');
    end;
  Finally
    FCurrentPackage:=Nil;
    FCurrentOutputDir:='';
  end;
end;

procedure TBuildEngine.CheckExternalPackage(Const APackageName : String);

begin
  Log(vldebug, SDebugUnresolvedExternalDependencyS, [APackageName]);

  If not DirectoryExists(IncludeTrailingPathDelimiter(Defaults.GlobalUnitDir)+APackageName) and
     (
      (Defaults.LocalUnitDir='') or
      not DirectoryExists(IncludeTrailingPathDelimiter(Defaults.LocalUnitDir)+APackageName)
     ) then
    Error(SErrDependencyNotFound,[APackageName]);
end;

procedure TBuildEngine.FixDependencies(APackage: TPackage);

Var
  I : Integer;
  P : TPackage;

begin
  if APackage.HasDependencies then
    For I:=0 to APAckage.Dependencies.Count-1 do
      begin
      P:=TPackage(Apackage.Dependencies.Objects[i]);
      If Assigned(P) then
        Compile(P) // If it already was compiled, then State<>tsNeutral, and it won't be compiled again.
      else
        CheckExternalPackage(Apackage.Dependencies[i]);
      end;
end;

Procedure TBuildEngine.InstallPackageFiles(APAckage : TPackage; tt : TTargetType; Const Src,Dest : String);

Var
  List : TStringList;
  UnitsDir: string;
  BinDir: string;
begin
  List:=TStringList.Create;
  Try
    UnitsDir := GetUnitsOutputDir(APackage);
    BinDir := GetBinOutputDir(APackage);
    APackage.GetInstallFiles(List,[tt],Src, UnitsDir, BinDir, Defaults.OS);
    if (List.Count>0) then
      CmdCopyFiles(List,Dest);
  Finally
    List.Free;
  end;
end;

procedure TBuildEngine.DoBeforeInstall(APackage: TPackage);
begin
  If APackage.HasCommands then
    ExecuteCommands(APackage.Commands,caBeforeInstall);
  If Assigned(APackage.BeforeInstall) then
    APackage.BeforeInstall(APackage);
end;

procedure TBuildEngine.DoAfterInstall(APackage: TPackage);
begin
  If Assigned(APackage.AfterInstall) then
    APackage.AfterInstall(APackage);
  If APackage.HasCommands then
    ExecuteCommands(APackage.Commands,caAfterInstall);
end;


procedure TBuildEngine.Install(APackage: TPackage);


Var
  PD,D,O : String;

begin
  If (Apackage.State<>tsCompiled) then
    Compile(APackage);
  Log(vlInfo,SLogInstallingPackage,[APackage.Name]);
  DoBeforeInstall(APackage);
  O:=IncludeTrailingPathDelimiter(GetUnitsOutputDir(APAckage));
  PD:=IncludeTrailingPathDelimiter(GetPackageDir(APackage));
  // units
  D:=IncludeTrailingPathDelimiter(Defaults.UnitInstallDir)+APackage.Name;
  InstallPackageFiles(APAckage,ttUnit,O,D);
  InstallPackageFiles(APAckage,ttImplicitUnit,O,D);
  // Programs
  D:=IncludeTrailingPathDelimiter(Defaults.BinInstallDir);
  InstallPackageFiles(APAckage,ttProgram,PD,D);
  // Done.
  APackage.FTargetState:=tsInstalled;
  DoAfterInstall(APackage);
end;

procedure TBuildEngine.DoBeforeArchive(APackage: TPackage);
begin
  If APackage.HasCommands then
    ExecuteCommands(APackage.Commands,caBeforeArchive);
  If Assigned(APackage.BeforeArchive) then
    APackage.BeforeArchive(APackage);
end;

procedure TBuildEngine.DoAfterArchive(APackage: TPackage);
begin
  If Assigned(APackage.AfterArchive) then
    APackage.AfterArchive(APackage);
  If APackage.HasCommands then
    ExecuteCommands(APackage.Commands,caAfterArchive);
end;


procedure TBuildEngine.Archive(APackage: TPackage);
Var
  L : TStringList;
  L2: TStringList;
  A : String;
  i: integer;
begin
  Log(vlInfo,SLogArchivingPackage,[APackage.Name]);
  DoBeforeArchive(Apackage);
  L:=TStringList.Create;
  L2:=TStringList.Create;
  Try
    //get all files
    //from targets
    APackage.GetArchiveFiles(L, TargetDir, Defaults.OS);
    //from sources
    for i := 0 to Pred(APackage.Sources.Count) do
      L.Add(APackage.Sources[i].Name);

    //expand all filenames and ignore duplicates
    L2.Sorted := True;
    L2.Duplicates := dupIgnore;
    for i := 0 to Pred(L.Count) do
      L2.Add(L[i]);

    //show all files
    for i := 0 to Pred(L2.Count) do
      Log(vlInfo, Format(SInfoArchiving, [L2[i]]));

    A:=APackage.FileName + ZipExt;

{$ifdef HAS_UNIT_ZIPPER}
    if not Assigned(ArchiveFilesProc) then
      begin
        FZipFile := TZipper.Create;
        FZipFile.ZipFiles(A, L2);
      end
    else
{$endif HAS_UNIT_ZIPPER}
      CmdArchiveFiles(L2,A);
  Finally
    L.Free;
    L2.Free;

{$ifdef HAS_UNIT_ZIPPER}
    if not Assigned(ArchiveFilesProc) then
      FZipFile.Free;
{$endif HAS_UNIT_ZIPPER}
  end;
  DoAfterArchive(Apackage);
end;

procedure TBuildEngine.DoBeforeClean(APackage: TPackage);
begin
  If APackage.HasCommands then
    ExecuteCommands(APackage.Commands,caBeforeClean);
  If Assigned(APackage.BeforeClean) then
    APackage.BeforeClean(APackage);
end;

procedure TBuildEngine.DoAfterClean(APackage: TPackage);
begin
  If Assigned(APackage.AfterClean) then
    APackage.AfterClean(APackage);
  If APackage.HasCommands then
    ExecuteCommands(APackage.Commands,caAfterClean);
end;

procedure TBuildEngine.Clean(APackage: TPackage);

Var
  OU : String;
  OB : String;
  List : TStringList;

begin
  Log(vlInfo,SLogCleaningPackage,[APackage.Name]);
  DoBeforeClean(Apackage);
  OU:=IncludeTrailingPathDelimiter(GetUnitsOutputDir(APAckage));
  OB:=IncludeTrailingPathDelimiter(GetBinOutputDir(APAckage));
  List:=TStringList.Create;
  try
    APackage.GetCleanFiles(List,OU, OB,Defaults.OS);
    if (List.Count>0) then
      CmdDeleteFiles(List);
  Finally
    List.Free;
  end;
  DoAfterClean(Apackage);
end;

function TBuildEngine.NeedsCompile(APackage: TPackage): Boolean;

Var
  I : Integer;
  P : TPackage;

begin
  ResolveDependencies(APackage.Dependencies,(APackage.Collection as TPackages));
  Result:=False;
  I:=0;
  While (Not Result) and (I<APackage.Dependencies.Count) do
    begin
    P:=TPackage(APackage.Dependencies.Objects[i]);
    // I'm not sure whether the target dir is OK here ??
    Result:=Assigned(P) and NeedsCompile(P);
    Inc(I);
    end;
  If Not Result then
    begin
    I:=0;
    While (Not Result) and (I<APackage.Targets.Count) do
      begin
      Result:=NeedsCompile(APackage.Targets.TargetItems[i]);
      Inc(I);
      end;
    end;
end;

Procedure TBuildEngine.GetSourceFiles(APackage : TPackage; List : TStrings);
var
  L : TStrings;
  i : integer;
  sXMLNode: string;
begin
  try
    L:=TStringList.Create;
    //APackage.GetSourceFiles(L);

    List.Add(Format('<sources packagename="%s">',[QuoteXml(APackage.Name)]));

    for i := 0 to Pred(APackage.Sources.Count) do
    begin
      case APackage.Sources[i].SourceType of
        stDoc: sXMLNode := '<source type="document">"%s"</source>';
        stSrc: sXMLNode := '<source type="source">"%s"</source>';
        stExample: sXMLNode := '<source type="example">"%s"</source>';
        stTest: sXMLNode := '<source type="test">"%s"</source>';
      else
        sXMLNode := '<source type="unknown">"%s"</source>';
      end;

      List.Add(Format(sXMLNode,[QuoteXml(APackage.Sources[i].Name)]));
    end;

    List.Add('</sources>');
  finally
    L.Free;
  end;
end;


Procedure TBuildEngine.GetManifest(APackage : TPackage; Manifest : TStrings);

begin
  APackage.GetManifest(Manifest);
end;


procedure TBuildEngine.Compile(Packages: TPackages);

Var
  I : Integer;
  P : TPackage;

begin
  If Assigned(BeforeCompile) then
    BeforeCompile(Self);
  For I:=0 to Packages.Count-1 do
    begin
    P:=Packages.PackageItems[i];
    FCurrentPackage := P;
    If PackageOK(P) then
      If (P.State=tsNeutral) then
        begin
        If (FForceCompile or NeedsCompile(P)) then
          begin
          P.FTargetState:=tsCompiling;
          FixDependencies(P);
          Compile(P);
          end;
        P.FTargetState:=tsCompiled;
        end;
    end;
  If Assigned(AfterCompile) then
    AfterCompile(Self);
end;

procedure TBuildEngine.Install(Packages: TPackages);

Var
  I : Integer;
  P : TPackage;

begin
  If Assigned(BeforeInstall) then
    BeforeInstall(Self);
  For I:=0 to Packages.Count-1 do
    begin
    P:=Packages.PackageItems[i];
    If PackageOK(P) then
      Install(P);
    end;
  If Assigned(AfterInstall) then
    AfterInstall(Self);
end;

procedure TBuildEngine.Archive(Packages: TPackages);

Var
  I : Integer;
  P : TPackage;

begin
  If Assigned(BeforeArchive) then
    BeforeArchive(Self);
  Log(vlDebug, SDebugBuildEngineArchiving);
  For I:=0 to Packages.Count-1 do
    begin
    P:=Packages.PackageItems[i];
    If PackageOK(P) then
      Archive(P);
    end;
  If Assigned(AfterArchive) then
    AfterArchive(Self);
end;

procedure TBuildEngine.Clean(Packages: TPackages);

Var
  I : Integer;
  P : TPackage;

begin
  If Assigned(BeforeClean) then
    BeforeClean(Self);
  Log(vldebug, SDebugBuildEngineCleaning);
  For I:=0 to Packages.Count-1 do
    begin
    P:=Packages.PackageItems[i];
    If PackageOK(P) then
      Clean(P);
    end;
  If Assigned(AfterClean) then
    AfterClean(Self);
end;

Procedure TBuildEngine.GetManifest(Packages : TPackages; Manifest : TStrings);

Var
  I : Integer;

begin
  If Assigned(BeforeManifest) then
    BeforeManifest(Self);
  Manifest.Add('<packages>');
  For I:=0 to Packages.Count-1 do
    GetManifest(Packages.PackageItems[i],Manifest);
  Manifest.Add('</packages>');
  If Assigned(AfterManifest) then
    AfterManifest(Self);
end;


Procedure TBuildEngine.GetSourceFiles(Packages : TPackages; List : TStrings);

Var
  I : Integer;

begin
  List.Add('<packages>');
  For I:=0 to Packages.Count-1 do
    GetSourceFiles(Packages.PackageItems[i],List);
  List.Add('</packages>');
end;


{ TTarget }

function TTarget.GetHasStrings(AIndex: integer): Boolean;
begin
  Result:=False;
  Case AIndex Of
    0 : Result:=FUnitPath<>Nil;
    1 : Result:=FObjectPath<>Nil;
    2 : Result:=FIncludePath<>Nil;
    3 : Result:=FDependencies<>Nil;
  end;
end;

function TTarget.GetCommands: TCommands;
begin
  If FCommands=Nil then
    FCommands:=TCommands.Create(TCommand);
  Result:=FCommands;
end;

function TTarget.GetHasCommands: Boolean;
begin
  Result:=(FCommands<>Nil);
end;

function TTarget.GetStrings(AIndex: integer): TStrings;

  Function EnsureStrings(Var S : TStrings) : TStrings;

  begin
    If (S=Nil) then
      S:=TStringList.Create;
    Result:=S;
  end;

begin
  Result:=Nil;
  Case AIndex Of
    0 : Result:=EnsureStrings(FUnitPath);
    1 : Result:=EnsureStrings(FObjectPath);
    2 : Result:=EnsureStrings(FIncludePath);
    3 : Result:=EnsureStrings(FDependencies);
  end;
end;

procedure TTarget.SetCommands(const AValue: TCommands);
begin

end;

procedure TTarget.SetStrings(AIndex: integer; const AValue: TStrings);
begin
  GetStrings(AIndex).Assign(AValue);
end;


function TTarget.GetSourceFileName: String;
begin
  Result:=Name+FExtension;
end;

function TTarget.GetUnitFileName: String;
begin
  Result:=Name+UnitExt;
end;

function TTarget.GetObjectFileName: String;
begin
  Result:=Name+ObjExt;
end;

function TTarget.GetRSTFileName: String;
begin
  Result:=Name+RSText;
end;

function TTarget.GetProgramFileName(AnOS : TOS): String;
begin
  if AnOS in [Go32v2,Win32,Win64,OS2] then
    Result:=Name+ExeExt
  else
    Result:=Name;
end;

constructor TTarget.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FInstall:=True;
end;

destructor TTarget.Destroy;
begin
  FreeAndNil(FUnitPath);
  FreeAndNil(FObjectPath);
  FreeAndNil(FIncludePath);
  FreeAndNil(FDependencies);
  inherited Destroy;
end;

function TTarget.GetOutputFileName(AOs: TOS): String;
begin
  if TargetType in UnitTargets then
    Result:=GetUnitFileName
  else
    Result:=GetProgramFileName(AOs);
end;


procedure TTarget.SetName(const AValue: String);

Var
  D,N,E : String;

begin
  N:=FixPath(AValue);
  D:=ExtractFilePath(N);
  E:=ExtractFileExt(N);
  N:=ExtractFileName(N);
  If (E<>'') then
    N:=Copy(N,1,Length(N)-Length(E))
  else
    E:=Defaults.SourceExt;
  inherited SetName(N);
  FExtension:=E;
  FDirectory:=D;
end;

procedure TTarget.GetCleanFiles(List: TStrings; const APrefixU, APrefixB : String; AnOS : TOS);
begin
  If (OS=[]) or (AnOS in OS) then
    begin
    List.Add(APrefixU + ObjectFileName);
    If (TargetType in [ttUnit,ttImplicitUnit,ttExampleUnit]) then
      List.Add(APrefixU + UnitFileName)
    else If (TargetType in [ttProgram,ttExampleProgram]) then
      List.Add(APrefixB + GetProgramFileName(AnOS));
    If ResourceStrings then
      List.Add(APrefixU + RSTFileName);
    // Maybe add later ?  AddStrings(List,CleanFiles);
    end;
end;

procedure TTarget.GetSourceFiles(List: TStrings; const APrefix : String; AnOS : TOS);
begin
  If (OS=[]) or (AnOS in OS) then
    begin
    List.Add(APrefix+ObjectFileName);
    If (TargetType in [ttUnit,ttImplicitUnit,ttExampleUnit]) then
      List.Add(APrefix+UnitFileName)
    else If (TargetType in [ttProgram,ttExampleProgram]) then
      List.Add(APrefix+GetProgramFileName(AnOS));
    If ResourceStrings then
      List.Add(APrefix+RSTFileName);
    // Maybe add later ?  AddStrings(List,CleanFiles);
    end;
end;

procedure TTarget.GetInstallFiles(List: TStrings; const APrefixU, APrefixB: String; AnOS : TOS);
begin
  If (OS=[]) or (AnOS in OS) then
    begin
    If Not (TargetType in [ttProgram,ttExampleProgram]) then
      List.Add(APrefixU + ObjectFileName);
    If (TargetType in [ttUnit,ttImplicitUnit,ttExampleUnit]) then
      List.Add(APrefixU + UnitFileName)
    else If (TargetType in [ttProgram,ttExampleProgram]) then
      List.Add(APrefixB + GetProgramFileName(AnOS));
    If ResourceStrings then
      List.Add(APrefixU + RSTFileName);
    // Maybe add later ?  AddStrings(List,InstallFiles);
    end;
end;

procedure TTarget.GetArchiveFiles(List: TStrings; const APrefix : String; AnOS : TOS);
var
  Prefix : String;
begin
  Prefix:=APrefix+Directory;
  If (Prefix<>'') then
    Prefix:=Prefix;
  If (OS=[]) or (AnOS in OS) then
    begin
    List.Add(Prefix+SourceFileName);
    // Maybe add later ?  AddStrings(List,ArchiveFiles);
    end;
end;


{ TSource }

constructor TSource.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
end;

destructor TSource.Destroy;
begin
  inherited Destroy;
end;

procedure TSource.GetSourceFiles(List: TStrings);
begin
  List.Add(Name);
end;


{ TCommands }

function TCommands.GetCommand(const Dest : String): TCommand;

begin
  Result:=TCommand(ItemByName(Dest));
end;

function TCommands.GetCommandItem(Index : Integer): TCommand;
begin
  Result:=TCommand(Items[Index]);
end;

procedure TCommands.SetCommandItem(Index : Integer; const AValue: TCommand);
begin
  Items[Index]:=AValue;
end;

Function TCommands.AddCommand(const Cmd: String) : TCommand;
begin
  Result:=AddCommand(fdefaultAt,Cmd,'','','');
end;

function TCommands.AddCommand(const Cmd, Options: String): TCommand;
begin
  Result:=AddCommand(fdefaultAt,Cmd,Options,'','');
end;

function TCommands.AddCommand(const Cmd, Options, Dest, Source: String
  ): TCommand;
begin
  Result:=AddCommand(fdefaultAt,Cmd,options,Dest,Source);
end;

Function TCommands.AddCommand(At: TCommandAt; const Cmd: String) : TCommand;
begin
  Result:=AddCommand(At,Cmd,'','','');
end;

function TCommands.AddCommand(At: TCommandAt; const Cmd, Options: String
  ): TCommand;
begin
  Result:=AddCommand(At,Cmd,Options,'','');
end;

function TCommands.AddCommand(At: TCommandAt; const Cmd, Options, Dest,
  Source: String): TCommand;
begin
  Result:=Add as TCommand;
  Result.Command:=Cmd;
  Result.Options:=Options;
  Result.At:=At;
  Result.SourceFile:=Source;
  Result.DestFile:=Dest;
end;

Var
  DefInstaller : TCustomInstaller = Nil;
  DefDictionary : TDictionary = Nil;

Function Installer(InstallerClass: TInstallerClass): TCustomInstaller;
begin
  If Not Assigned(DefInstaller) then
    DefInstaller:=InstallerClass.Create(Nil);
  Result:=DefInstaller;
end;

Function Installer: TCustomInstaller;
begin
  Result := Installer(TFPCInstaller);
end;

Function Defaults : TCustomDefaults;

begin
  Result:=Installer.Defaults;
end;


function Dictionary : TDictionary;
begin
  If Not Assigned(DefDictionary) then
    DefDictionary:=DictionaryClass.Create(Nil);
  Result:=DefDictionary;
end;

{ TValueItem }

constructor TValueItem.Create(AValue: String);
begin
  FValue:=AValue;
end;

{ TFunctionItem }

constructor TFunctionItem.Create(AFunc: TReplaceFunction);
begin
  FFunc:=AFunc;
end;

{ TDictionary }

constructor TDictionary.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FList:=TStringList.Create;
  FList.Sorted:=True;
  FList.Duplicates:=dupError;
end;

destructor TDictionary.Destroy;

Var
  I : Integer;

begin
  For I:=0 to Flist.Count-1 do
    FList.Objects[i].Free;
  FreeAndNil(FList);
  inherited Destroy;
end;

procedure TDictionary.AddVariable(const AName, Value: String);

Var
  I : Integer;

begin
  I:=Flist.IndexOf(AName);
  If I=-1 then
    I:=FList.Add(Aname)
  else
    Flist.Objects[i].Free;
  Flist.Objects[i]:=TValueItem.Create(Value);
end;

procedure TDictionary.AddFunction(const AName: String;
  FReplacement: TReplaceFunction);

Var
  I : Integer;

begin
  I:=Flist.IndexOf(AName);
  If I=-1 then
    I:=Flist.Add(AName)
  else
    Flist.Objects[i].Free;
  Flist.Objects[i]:=TFunctionItem.Create(FReplacement);
end;

procedure TDictionary.RemoveItem(const AName: String);

Var
  I : Integer;

begin
  I:=Flist.IndexOf(AName);
  If (I<>-1) then
    begin
    FList.Objects[i].Free;
    FList.Delete(I);
    end;
end;

function TDictionary.GetValue(const AName: String): String;

begin
  Result:=GetValue(AName,'');
end;


function TDictionary.GetValue(const AName,Args: String): String;

Var
  O : TObject;
  I : Integer;

begin
  I:=Flist.IndexOf(AName);
  If (I=-1) then
    Raise EDictionaryError.CreateFmt(SErrNoDictionaryItem,[AName]);
  O:=Flist.Objects[I];
  If O is TValueItem then
    Result:=TValueItem(O).FValue
  else
    Result:=TFunctionItem(O).FFunc(AName,Args);
end;

function TDictionary.ReplaceStrings(Const ASource: String): String;


Var
  S,FN,FV : String;
  P: Integer;

begin
  Result:='';
  S:=ASource;
  P:=Pos('$(',S);
  While (P<>0) do
    begin
    Result:=Result+Copy(S,1,P-1);
    Delete(S,1,P+1);
    P:=Pos(')',S);
    FN:=Copy(S,1,P-1);
    Delete(S,1,P);
    P:=Pos(' ',FN);
    If (P<>0) then // function arguments ?
      begin
      FV:=FN;
      FN:=Copy(FN,1,P);
      System.Delete(FV,1,P);
      end
    else
      FV:='';
    Result:=Result+GetValue(FN,FV);
    P:=Pos('$(',S);
    end;
  Result:=Result+S;
end;

Function Substitute(Const Source : String; Macros : Array of string) : String;
Var
  I : Integer;
begin
  I:=0;
  While I<High(Macros) do
    begin
    Dictionary.AddVariable(Macros[i],Macros[I+1]);
    Inc(I,2);
    end;
  Result:=Dictionary.ReplaceStrings(Source);
  While I<High(Macros) do
    begin
    Dictionary.RemoveItem(Macros[i]);
    Inc(I,2);
    end;
end;

Initialization
  OnGetApplicationName:=@GetFPMakeName;

Finalization
  FreeAndNil(DefInstaller);
  FreeAndNil(DefDictionary);
end.
