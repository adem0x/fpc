unit pkgmessages;

{$mode objfpc}{$H+}

interface


Resourcestring
  SWarning                   = 'Warning: ';
  SDebug                     = 'Debug: ';

  SErrInValidArgument        = 'Invalid command-line argument at position %d : %s';
  SErrNeedArgument           = 'Option at position %d (%s) needs an argument';
  SErrMissingFPC             = 'Could not find a fpc executable in the PATH';
  SErrInvalidFPCInfo         = 'Compiler returns invalid information, check if fpc -iV works';
  SErrMissingFPMake          = 'Missing configuration fpmake.pp';
  SErrMissingMakefilefpc     = 'Missing configuration Makefile.fpc';
  SErrMissingDirectory       = 'Missing directory "%s"';
  SErrMissingCompilerConfig  = 'Could not find compiler configuration "%s"';
  SErrMissingInstallPackage  = 'Could not find package "%s"';
  SErrNoPackageSpecified     = 'No package specified';
  SErrNoPackageAvailable     = 'Package %s %s is not available';
  SErrOnlyLocalDir           = 'The speficied command "%s" works only on current dir, not on a (remote) package';
  SErrRunning                = 'The FPC make tool encountered the following error:';
  SErrActionAlreadyRegistered= 'Action "%s" is already registered';
  SErrActionNotFound         = 'Action "%s" is not supported';
  SErrFailedToCompileFPCMake = 'Could not compile fpmake driver program';
  SErrNoFTPDownload          = 'This binary has no support for FTP downloads.';
  SErrNoHTTPDownload         = 'This binary has no support for HTTP downloads.';
  SErrBackupFailed           = 'Backup of file "%s" to file "%s" failed.';
  SErrUnknownProtocol        = 'Unknown download protocol: "%s"';
  SErrNoSuchFile             = 'File "%s" does not exist.';
  SErrWGetDownloadFailed     = 'Download failed: wget reported exit status %d.';
  SErrDownloadFailed         = 'Download failed: %s';
  SErrInvalidVerbosity       = 'Invalid verbosity string: "%s"';
  SErrInvalidCommand         = 'Invalid command: %s';
  SErrChangeDirFailed        = 'Could not change directory to "%s"';

  SErrHTTPGetFailed          = 'HTTP Download failed.';
  SErrLoginFailed            = 'FTP LOGIN command failed.';
  SErrCWDFailed              = 'FTP CWD "%s" command failed.';
  SErrGETFailed              = 'FTP GET "%s" command failed.';

  SWarnFPMKUnitDirNotFound   = 'Unit directory for package "%s" is not found, compiling fpmake may file';
  SWarnFPMKUnitNotFound      = 'Package "fpmkunit" is not found, using internal bootstrap procedure';

  SLogGeneratingFPMake       = 'Generating fpmake.pp';
  SLogNotCompilingFPMake     = 'Skipping compiling of fpmake.pp, fpmake executable already exists';
  SLogCommandLineAction      = 'Adding action from commandline: "%s %s"';
  SLogRunAction              = 'Action: "%s %s"';
  SLogExecute                = 'Executing: "%s %s"';
  SLogChangeDir              = 'CurrentDir: "%s"';
  SLogDownloading            = 'Downloading "%s" to "%s"';
  SLogUnzippping             = 'Unzipping "%s"';
  SLogZippping               = 'Zipping "%s"';
  SLogLoadingGlobalConfig    = 'Loading global configuration from "%s"';
  SLogLoadingCompilerConfig  = 'Loading compiler configuration from "%s"';
  SLogGeneratingGlobalConfig = 'Generating default global configuration in "%s"';
  SLogDetectedCompiler       = 'Detected compiler "%s" (version %s for %s)';
  SLogDetectedFPCDIR         = 'Detected %s FPCDIR "%s"';
  SLogGeneratingCompilerConfig  = 'Generating default compiler configuration in "%s"';
  SLogLoadingPackagesFile    = 'Loading available packages from "%s"';
  SLogLoadingStatusFile      = 'Loading local status from "%s"';
  SLogSavingStatusFile       = 'Saving local status to "%s"';

  SDbgFound                  = 'Found';
  SDbgNotFound               = 'Not Found';
  SDbgDirectoryExists        = 'Directory "%s" %s';
  SDbgFileExists             = 'File "%s" %s';


implementation

end.

