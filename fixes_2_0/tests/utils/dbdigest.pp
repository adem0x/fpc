{
    This file is part of the Free Pascal test suite.
    Copyright (c) 2002 by the Free Pascal development team.

    This program generates a digest
    of the last tests run.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{$mode objfpc}
{$h+}

program digest;

uses
  sysutils,teststr,testu,dbtests;


Type
  TTestStatus = (
  stFailedToCompile,
  stSuccessCompilationFailed,
  stFailedCompilationsuccessful,
  stSuccessfullyCompiled,
  stFailedToRun,
  stKnownRunProblem,
  stSuccessFullyRun,
  stSkippingGraphTest,
  stSkippingInteractiveTest,
  stSkippingKnownBug,
  stSkippingCompilerVersionTooLow,
  stSkippingCompilerVersionTooHigh,
  stSkippingOtherCpu,
  stSkippingOtherTarget,
  stskippingRunUnit,
  stskippingRunTest
  );


Const
  FirstStatus = stFailedToCompile;
  LastStatus = stskippingRunTest;

  TestOK : Array[TTestStatus] of Boolean = (
    False, // stFailedToCompile,
    True,  // stSuccessCompilationFailed,
    False, // stFailedCompilationsuccessful,
    True,  // stSuccessfullyCompiled,
    False, // stFailedToRun,
    True,  // stKnownRunProblem,
    True,  // stSuccessFullyRun,
    False, // stSkippingGraphTest,
    False, // stSkippingInteractiveTest,
    False, // stSkippingKnownBug,
    False, // stSkippingCompilerVersionTooLow,
    False, // stSkippingCompilerVersionTooHigh,
    False, // stSkippingOtherCpu,
    False, // stSkippingOtherTarget,
    False, // stskippingRunUnit,
    False  // stskippingRunTest
  );

  TestSkipped : Array[TTestStatus] of Boolean = (
    False,  // stFailedToCompile,
    False,  // stSuccessCompilationFailed,
    False,  // stFailedCompilationsuccessful,
    False,  // stSuccessfullyCompiled,
    False,  // stFailedToRun,
    False,  // stKnownRunProblem,
    False,  // stSuccessFullyRun,
    True,   // stSkippingGraphTest,
    True,   // stSkippingInteractiveTest,
    True,   // stSkippingKnownBug,
    True,   // stSkippingCompilerVersionTooLow,
    True,   // stSkippingCompilerVersionTooHigh,
    True,   // stSkippingOtherCpu,
    True,   // stSkippingOtherTarget,
    True,   // stskippingRunUnit,
    True    // stskippingRunTest
  );

  ExpectRun : Array[TTestStatus] of Boolean = (
    False,  // stFailedToCompile,
    False,  // stSuccessCompilationFailed,
    False,  // stFailedCompilationsuccessful,
    True ,  // stSuccessfullyCompiled,
    False,  // stFailedToRun,
    False,  // stKnownRunProblem,
    False,  // stSuccessFullyRun,
    False,  // stSkippingGraphTest,
    False,  // stSkippingInteractiveTest,
    False,  // stSkippingKnownBug,
    False,  // stSkippingCompilerVersionTooLow,
    False,  // stSkippingCompilerVersionTooHigh,
    False,  // stSkippingOtherCpu,
    False,  // stSkippingOtherTarget,
    False,  // stskippingRunUnit,
    False   // stskippingRunTest
   );

  StatusText : Array[TTestStatus] of String = (
    failed_to_compile,
    success_compilation_failed,
    failed_compilation_successful ,
    successfully_compiled ,
    failed_to_run ,
    known_problem ,
    successfully_run ,
    skipping_graph_test ,
    skipping_interactive_test ,
    skipping_known_bug ,
    skipping_compiler_version_too_low,
    skipping_compiler_version_too_high,
    skipping_other_cpu ,
    skipping_other_target ,
    skipping_run_unit ,
    skipping_run_test
  );

  SQLField : Array[TTestStatus] of String = (
    'TU_FAILEDTOCOMPILE',
    'TU_SUCCESSFULLYFAILED',
    'TU_FAILEDTOFAIL',
    'TU_SUCCESFULLYCOMPILED',
    'TU_FAILEDTORUN',
    'TU_KNOWNPROBLEM',
    'TU_SUCCESSFULLYRUN',
    'TU_SKIPPEDGRAPHTEST',
    'TU_SKIPPEDINTERACTIVETEST',
    'TU_KNOWNBUG',
    'TU_COMPILERVERIONTOOLOW',
    'TU_COMPILERVERIONTOOHIGH',
    'TU_OTHERCPU',
    'TU_OTHERTARGET',
    'TU_UNIT',
    'TU_SKIPPINGRUNTEST'
  );


Var
  StatusCount : Array[TTestStatus] of Integer;
  UnknownLines : integer;


Procedure ExtractTestFileName(Var Line : string);

Var I : integer;

begin
  I:=Pos(' ',Line);
  If (I<>0) then
    Line:=Copy(Line,1,I-1);
end;

Function Analyse(Var Line : string; Var Status : TTestStatus) : Boolean;

Var
  TS : TTestStatus;

begin
  Result:=False;
  For TS:=FirstStatus to LastStatus do
    begin
    Result:=Pos(StatusText[TS],Line)=1;
    If Result then
      begin
      Status:=TS;
      Delete(Line,1,Length(StatusText[TS]));
      ExtractTestFileName(Line);
      Break;
      end;
    end;
end;

Type

TConfigOpt = (
  coDatabaseName,
  soHost,
  coUserName,
  coPassword,
  coLogFile,
  coOS,
  coCPU,
  coVersion,
  coDate,
  coSubmitter,
  coMachine,
  coComment,
  coTestSrcDir,
  coVerbose
 );

Const

ConfigStrings : Array [TConfigOpt] of string = (
  'databasename',
  'host',
  'username',
  'password',
  'logfile',
  'os',
  'cpu',
  'version',
  'date',
  'submitter',
  'machine',
  'comment',
  'testsrcdir',
  'verbose'
);

ConfigOpts : Array[TConfigOpt] of char
           = ('d','h','u','p','l','o','c','v','t','s','m','C','S','V');

Var
  TestOS,
  TestCPU,
  TestVersion,
  DatabaseName,
  HostName,
  UserName,
  Password,
  LogFileName,
  Submitter,
  Machine,
  Comment : String;
  TestDate : TDateTime;

Procedure SetOpt (O : TConfigOpt; Value : string);
var
  year,month,day,min,hour : word;
begin
  Case O of
    coDatabaseName : DatabaseName:=Value;
    soHost         : HostName:=Value;
    coUserName     : UserName:=Value;
    coPassword     : Password:=Value;
    coLogFile      : LogFileName:=Value;
    coOS           : TestOS:=Value;
    coCPU          : TestCPU:=Value;
    coVersion      : TestVersion:=Value;
    coDate         : 
      begin
        { Formated like YYYYMMDDhhmm }
	if Length(value)=12 then
	  begin
	    year:=StrToInt(Copy(value,1,4));
	    month:=StrToInt(Copy(value,5,2));
	    day:=StrToInt(Copy(Value,7,2));
	    hour:=StrToInt(Copy(Value,9,2));
	    min:=StrToInt(Copy(Value,11,2));
	    TestDate:=EncodeDate(year,month,day)+EncodeTime(hour,min,0,0);
	  end
	else
	  Verbose(V_Error,'Error in date format, use YYYYMMDDhhmm');  
      end;
    coSubmitter    : Submitter:=Value;
    coMachine      : Machine:=Value;
    coComment      : Comment:=Value;
    coVerbose      : DoVerbose:=true;
    coTestSrcDir   :
      begin
        TestSrcDir:=Value;
	if (TestSrcDir<>'') and (TestSrcDir[length(TestSrcDir)]<>'/') then
	  TestSrcDir:=TestSrcDir+'/';
      end;	  
  end;
end;

Function ProcessOption(S: String) : Boolean;

Var
  N : String;
  I : Integer;
  co : TConfigOpt;

begin
  Verbose(V_DEBUG,'Processing option: '+S);
  I:=Pos('=',S);
  Result:=(I<>0);
  If Result then
    begin
    N:=Copy(S,1,I-1);
    Delete(S,1,I);
    For co:=low(TConfigOpt) to high(TConfigOpt) do
      begin
      Result:=CompareText(ConfigStrings[co],N)=0;
      If Result then
        Break;
      end;
    end;
 If Result then
   SetOpt(co,S)
 else
   Verbose(V_ERROR,'Unknown option : '+n+S);
end;

Procedure ProcessConfigfile(FN : String);

Var
  F : Text;
  S : String;
  I : Integer;

begin
  If Not FileExists(FN) Then
    Exit;
  Verbose(V_DEBUG,'Parsing config file: '+FN);
  Assign(F,FN);
  {$i-}
  Reset(F);
  If IOResult<>0 then
    Exit;
  {$I+}
  While not(EOF(F)) do
    begin
    ReadLn(F,S);
    S:=trim(S);
    I:=Pos('#',S);
    If I<>0 then
      S:=Copy(S,1,I-1);
    If (S<>'') then
      ProcessOption(S);
    end;
  Close(F);
end;

Procedure ProcessCommandLine;

Var
  I : Integer;
  O : String;
  c,co : TConfigOpt;
  Found : Boolean;

begin
  I:=1;
  While I<=ParamCount do
    begin
    O:=Paramstr(I);
    Found:=Length(O)=2;
    If Found then
      For co:=low(TConfigOpt) to high(TConfigOpt) do
        begin
        Found:=(O[2]=ConfigOpts[co]);
        If Found then
          begin
          c:=co;
          Break;
          end;
        end;
    If Not Found then
      Verbose(V_ERROR,'Illegal command-line option : '+O)
    else
      begin
      Found:=(I<ParamCount);
      If Not found then
        Verbose(V_ERROR,'Option requires argument : '+O)
      else
        begin
        inc(I);
        O:=Paramstr(I);
        SetOpt(c,o);
        end;
      end;
    Inc(I);
    end;
end;

Var
  TestCPUID : Integer;
  TestOSID  : Integer;
  TestVersionID  : Integer;
  TestRunID : Integer;

Procedure GetIDs;

begin
  TestCPUID := GetCPUId(TestCPU);
  If TestCPUID=-1 then
    Verbose(V_Error,'NO ID for CPU "'+TestCPU+'" found.');
  TestOSID  := GetOSID(TestOS);
  If TestOSID=-1 then
    Verbose(V_Error,'NO ID for OS "'+TestOS+'" found.');
  TestVersionID  := GetVersionID(TestVersion);
  If TestVersionID=-1 then
    Verbose(V_Error,'NO ID for version "'+TestVersion+'" found.');
  If (Round(TestDate)=0) then
    Testdate:=Now;
  TestRunID:=GetRunID(TestOSID,TestCPUID,TestVersionID,TestDate);
  If (TestRunID=-1) then
    begin
    TestRunID:=AddRun(TestOSID,TestCPUID,TestVersionID,TestDate);
    If TestRUnID=-1 then
      Verbose(V_Error,'Could not insert new testrun record!');
    end
  else
    CleanTestRun(TestRunID);
end;

Function GetLog(FN : String) : String;

begin
  FN:=ChangeFileExt(FN,'.elg');
  If FileExists(FN) then
    Result:=GetFileContents(FN)
  else
    Result:='';
end;

Procedure Processfile (FN: String);

var
  logfile : text;
  line : string;
  TS : TTestStatus;
  ID : integer;
  Testlog : string;

begin
  Assign(logfile,FN);
{$i-}
  reset(logfile);
  if ioresult<>0 then
    Verbose(V_Error,'Unable to open log file'+logfilename);
{$i+}
  while not eof(logfile) do
    begin
    readln(logfile,line);
    If analyse(line,TS) then
      begin
      Verbose(V_NORMAL,'Analysing result for test '+Line);
      Inc(StatusCount[TS]);
      If Not ExpectRun[TS] then
        begin
        ID:=RequireTestID(Line);
        If (ID<>-1) then
          begin
          If Not (TestOK[TS] or TestSkipped[TS]) then
            TestLog:=GetLog(Line)
          else
            TestLog:='';
          AddTestResult(ID,TestRunID,Ord(TS),TestOK[TS],TestSkipped[TS],TestLog);
          end;
        end
      end
    else
      Inc(UnknownLines);
    end;
  close(logfile);
end;

procedure UpdateTestRun;

  var
     i : TTestStatus;
     qry : string;
     res : TQueryResult;

  begin
    qry:='UPDATE TESTRUN SET ';
    for i:=low(TTestStatus) to high(TTestStatus) do
      qry:=qry+format('%s=%d, ',[SQLField[i],StatusCount[i]]);
    qry:=qry+format('TU_SUBMITTER="%s", TU_MACHINE="%s", TU_COMMENT="%s", TU_DATE="%s"',[Submitter,Machine,Comment,SqlDate(TestDate)]);
    qry:=qry+' WHERE TU_ID='+format('%d',[TestRunID]);
    RunQuery(Qry,res)
  end;


begin
  ProcessConfigFile('dbdigest.cfg');
  ProcessCommandLine;
  If LogFileName<>'' then
    begin
    ConnectToDatabase(DatabaseName,HostName,UserName,Password);
    GetIDs;
    ProcessFile(LogFileName);
    UpdateTestRun;
    end
  else
    Verbose(V_ERROR,'Missing log file name');
end.
