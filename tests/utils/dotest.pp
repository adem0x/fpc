{
    This file is part of the Free Pascal test suite.
    Copyright (c) 1999-2002 by the Free Pascal development team.

    This program makes the compilation and
    execution of individual test sources.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$H+}
{$goto on}

program dotest;
uses
  dos,
{$ifdef macos}
  macutils,
{$endif}
  teststr,
  testu,
  redir,
  bench,
  classes;

{$ifdef go32v2}
  {$define LIMIT83FS}
{$endif}
{$ifdef os2}
  {$define LIMIT83FS}
{$endif}

type
  tcompinfo = (compver,comptarget,compcpu);
  tdelexecutable = (deBefore, deAfter);
  tdelexecutables = set of tdelexecutable;

const
  ObjExt='o';
  PPUExt='ppu';
{$ifdef UNIX}
  SrcExeExt='';
{$else UNIX}
{$ifdef MACOS}
  SrcExeExt='';
{$else MACOS}
  SrcExeExt='.exe';
{$endif MACOS}
{$endif UNIX}
  ExeExt : string = '';
  DefaultTimeout=60;

var
  Config : TConfig;
  CompilerLogFile,
  ExeLogFile,
  LongLogfile,
  FailLogfile,
  RTLUnitsDir,
  TestOutputDir,
  OutputDir : string;
  CompilerBin,
  CompilerCPU,
  CompilerTarget,
  CompilerVersion,
  DefaultCompilerCPU,
  DefaultCompilerTarget,
  DefaultCompilerVersion : string;
  PPFile : TStringList;
  PPFileInfo : TStringList;
  TestName : string;
  Current : longint;

const
  DoGraph : boolean = false;
  DoInteractive : boolean = false;
  DoExecute : boolean = false;
  DoKnown : boolean = false;
  DoAll : boolean = false;
  DoUsual : boolean = true;
  { TargetDir : string = ''; unused }
  BenchmarkInfo : boolean = false;
  ExtraCompilerOpts : string = '';
  DelExecutable : TDelExecutables = [];
  RemoteAddr : string = '';
  RemotePath : string = '/tmp';
  RemotePara : string = '';
  rshprog : string = 'rsh';
  rcpprog : string = 'rcp';
  rquote : char = '''';
  UseTimeout : boolean = false;
  emulatorname : string = '';

{ Constants used in IsAbsolute function }
  TargetHasDosStyleDirectories : boolean = false;
  TargetAmigaLike : boolean = false;
  TargetIsMacOS : boolean = false;

{ extracted from rtl/macos/macutils.inc }

function IsMacFullPath (const path: string): Boolean;
  begin
    if Pos(':', path) = 0 then    {its partial}
      IsMacFullPath := false
    else if path[1] = ':' then
      IsMacFullPath := false
    else
      IsMacFullPath := true
  end;


Function IsAbsolute (Const F : String) : boolean;
{
  Returns True if the name F is a absolute file name
}
begin
  IsAbsolute:=false;
  if TargetHasDosStyleDirectories then
    begin
      if (F[1]='/') or (F[1]='\') then
        IsAbsolute:=true;
      if (Length(F)>2) and (F[2]=':') and ((F[3]='\') or (F[3]='/')) then
        IsAbsolute:=true;
    end
  else if TargetAmigaLike then
    begin
      if (length(F)>0) and (Pos(':',F) <> 0) then
        IsAbsolute:=true;
    end
  else if TargetIsMacOS then
    begin
      IsAbsolute:=IsMacFullPath(F);
    end
  { generic case }
  else if (F[1]='/') then
    IsAbsolute:=true;
end;

Function FileExists (Const F : String) : Boolean;
{
  Returns True if the file exists, False if not.
}
Var
  info : searchrec;
begin
  FindFirst (F,anyfile,Info);
  FileExists:=DosError=0;
  FindClose (Info);
end;


Function PathExists (Const F : String) : Boolean;
{
  Returns True if the file exists, False if not.
}
Var
  info : searchrec;
begin
  FindFirst (F,anyfile,Info);
  PathExists:=(DosError=0) and (Info.Attr and Directory=Directory);
  FindClose (Info);
end;


function ToStr(l:longint):string;
var
  s : string;
begin
  Str(l,s);
  ToStr:=s;
end;


function ToStrZero(l:longint;nbzero : byte):string;
var
  s : string;
begin
  Str(l,s);
  while length(s)<nbzero do
    s:='0'+s;
  ToStrZero:=s;
end;


function trimspace(const s:string):string;
var
  i,j : longint;
begin
  i:=length(s);
  while (i>0) and (s[i] in [#9,' ']) do
   dec(i);
  j:=1;
  while (j<i) and (s[j] in [#9,' ']) do
   inc(j);
  trimspace:=Copy(s,j,i-j+1);
end;


function IsInList(const entry,list:string):boolean;
var
  i,istart : longint;
begin
  IsInList:=false;
  i:=0;
  while (i<length(list)) do
   begin
     { Find list item }
     istart:=i+1;
     while (i<length(list)) and
           (list[i+1]<>',') do
      inc(i);
     if Upcase(entry)=Upcase(TrimSpace(Copy(list,istart,i-istart+1))) then
      begin
        IsInList:=true;
        exit;
      end;
     { skip , }
     inc(i);
   end;
end;


procedure SetPPFileInfo;
Var
  info : searchrec;
  dt : DateTime;
begin
  FindFirst (PPFile[current],anyfile,Info);
  If DosError=0 then
    begin
      UnpackTime(info.time,dt);
      PPFileInfo.Insert(current,PPFile[current]+' '+ToStr(dt.year)+'/'+ToStrZero(dt.month,2)+'/'+
        ToStrZero(dt.day,2)+' '+ToStrZero(dt.Hour,2)+':'+ToStrZero(dt.min,2)+':'+ToStrZero(dt.sec,2));
    end
  else
    PPFileInfo.Insert(current,PPFile[current]);
  FindClose (Info);
end;


function SplitPath(const s:string):string;
var
  i : longint;
begin
  i:=Length(s);
  while (i>0) and not(s[i] in ['/','\'{$IFDEF MACOS},':'{$ENDIF}]) do
   dec(i);
  SplitPath:=Copy(s,1,i);
end;


Function SplitFileName(const s:string):string;
var
  p : dirstr;
  n : namestr;
  e : extstr;
begin
  FSplit(s,p,n,e);
  SplitFileName:=n+e;
end;


function ForceExtension(Const HStr,ext:String):String;
{
  Return a filename which certainly has the extension ext
}
var
  j : longint;
begin
  j:=length(Hstr);
  while (j>0) and (Hstr[j]<>'.') do
   dec(j);
  if j=0 then
   j:=length(Hstr)+1;
  if Ext<>'' then
   begin
     if Ext[1]='.' then
       ForceExtension:=Copy(Hstr,1,j-1)+Ext
     else
       ForceExtension:=Copy(Hstr,1,j-1)+'.'+Ext
   end
  else
   ForceExtension:=Copy(Hstr,1,j-1);
end;


procedure mkdirtree(const s:string);
var
  hs : string;
begin
  if s='' then
    exit;
  if s[length(s)] in ['\','/'{$IFDEF MACOS},':'{$ENDIF}] then
    hs:=Copy(s,1,length(s)-1)
  else
    hs:=s;
  if not PathExists(hs) then
    begin
      { Try parent first }
      mkdirtree(SplitPath(hs));
      { make this dir }
      Verbose(V_Debug,'Making Directory '+s);
      {$I-}
       mkdir(s);
      {$I+}
      ioresult;
    end;
end;


    Function RemoveFile(const f:string):boolean;
      var
        g : file;
      begin
        assign(g,f);
        {$I-}
         erase(g);
        {$I+}
        RemoveFile:=(ioresult=0);
      end;


function Copyfile(const fn1,fn2:string;append:boolean) : longint;
const
  bufsize = 16384;
var
  f,g : file;
  addsize,
  i   : longint;
  buf : pointer;
begin
  if Append then
   Verbose(V_Debug,'Appending '+fn1+' to '+fn2)
  else
   Verbose(V_Debug,'Copying '+fn1+' to '+fn2);
  assign(f,fn1);
  assign(g,fn2);
  {$I-}
   reset(f,1);
  {$I+}
  addsize:=0;
  if ioresult<>0 then
   Verbose(V_Error,'Can''t open '+fn1);
  if append then
   begin
     {$I-}
      reset(g,1);
     {$I+}
     if ioresult<>0 then
      append:=false
     else
      seek(g,filesize(g));
   end;
  if not append then
   begin
     {$I-}
      rewrite(g,1);
     {$I+}
     if ioresult<>0 then
      Verbose(V_Error,'Can''t open '+fn2+' for output');
   end;
  getmem(buf,bufsize);
  repeat
    blockread(f,buf^,bufsize,i);
    blockwrite(g,buf^,i);
    addsize:=addsize+i;
  until i<bufsize;
  freemem(buf,bufsize);
  close(f);
  close(g);
  CopyFile:=addsize;
end;


procedure AddLog(const logfile,s:string);
var
  t : text;
begin
  assign(t,logfile);
  {$I-}
   append(t);
  {$I+}
  if ioresult<>0 then
   begin
     {$I-}
      rewrite(t);
     {$I+}
     if ioresult<>0 then
       Verbose(V_Abort,'Can''t append to '+logfile);
   end;
  writeln(t,s);
  close(t);
end;


function GetCompilerInfo(c:tcompinfo):boolean;

  function GetToken(var s:string):string;
  var
    i : longint;
  begin
    i:=pos(' ',s);
    if i=0 then
     i:=length(s)+1;
    GetToken:=Copy(s,1,i-1);
    Delete(s,1,i);
  end;

var
  t  : text;
  hs : string;
begin
  GetCompilerInfo:=false;
  { Try to get all information in one call, this is
    supported in 1.1. Older compilers 1.0.x will only
    return the first info }
  case c of
    compver :
      begin
        if DefaultCompilerVersion<>'' then
          begin
            GetCompilerInfo:=true;
            exit;
          end;
        hs:='-iVTPTO';
      end;
    compcpu :
      begin
        if DefaultCompilerCPU<>'' then
          begin
            GetCompilerInfo:=true;
            exit;
          end;
        hs:='-iTPTOV';
      end;
    comptarget :
      begin
        if DefaultCompilerTarget<>'' then
          begin
            GetCompilerInfo:=true;
            exit;
          end;
        hs:='-iTOTPV';
      end;
  end;
  ExecuteRedir(CompilerBin,hs,'','out','');
  assign(t,'out');
  {$I-}
   reset(t);
   readln(t,hs);
   close(t);
   erase(t);
  {$I+}
  if ioresult<>0 then
   Verbose(V_Error,'Can''t get Compiler Info')
  else
   begin
     Verbose(V_Debug,'Retrieved Compiler Info: "'+hs+'"');
     case c of
       compver :
         begin
           DefaultCompilerVersion:=GetToken(hs);
           DefaultCompilerCPU:=GetToken(hs);
           DefaultCompilerTarget:=GetToken(hs);
         end;
       compcpu :
         begin
           DefaultCompilerCPU:=GetToken(hs);
           DefaultCompilerTarget:=GetToken(hs);
           DefaultCompilerVersion:=GetToken(hs);
         end;
       comptarget :
         begin
           DefaultCompilerTarget:=GetToken(hs);
           DefaultCompilerCPU:=GetToken(hs);
           DefaultCompilerVersion:=GetToken(hs);
         end;
     end;
     GetCompilerInfo:=true;
   end;
end;


function GetCompilerVersion:boolean;
begin
  if CompilerVersion='' then
    begin
      GetCompilerVersion:=GetCompilerInfo(compver);
      CompilerVersion:=DefaultCompilerVersion;
    end
  else
    GetCompilerVersion:=true;
  if GetCompilerVersion then
    Verbose(V_Debug,'Compiler Version: "'+CompilerVersion+'"');
end;


function GetCompilerCPU:boolean;
begin
  if CompilerCPU='' then
    begin
      GetCompilerCPU:=GetCompilerInfo(compcpu);
      CompilerCPU:=DefaultCompilerCPU;
    end
  else
    GetCompilerCPU:=true;
  if GetCompilerCPU then
    Verbose(V_Debug,'Compiler CPU: "'+CompilerCPU+'"');
end;


function GetCompilerTarget:boolean;
begin
  if CompilerTarget='' then
    begin
      GetCompilerTarget:=GetCompilerInfo(comptarget);
      CompilerTarget:=DefaultCompilerTarget;
    end
  else
    GetCompilerTarget:=true;
  if GetCompilerTarget then
    Verbose(V_Debug,'Compiler Target: "'+CompilerTarget+'"');
end;


function CompilerFullTarget:string;
begin
  CompilerFullTarget:=CompilerCPU+'-'+CompilerTarget;
end;

{ Set the three constants above according to
  the current target }

procedure SetTargetDirectoriesStyle;
var
  LTarget : string;
  res : boolean;
begin
  { Call this first to ensure that CompilerTarget is not empty }
  res:=GetCompilerTarget;
  LTarget := lowercase(CompilerTarget);
  TargetHasDosStyleDirectories :=
    (LTarget='emx') or
    (LTarget='go32v2') or
    (LTarget='nativent') or
    (LTarget='os2') or
    (LTarget='symbian') or
    (LTarget='watcom') or
    (LTarget='wdosx') or
    (LTarget='win32') or
    (LTarget='win64');
  TargetAmigaLike:=
    (LTarget='amiga') or
    (LTarget='morphos');
  TargetIsMacOS:=
    (LTarget='macos');
  { Set ExeExt for CompilerTarget.
    This list has been set up 2011-06 using the information in
    compiler/system/i_XXX.pas units.
    We should update this list when adding new targets PM }
  if (TargetHasDosStyleDirectories) then
    ExeExt:='.exe'
  else if LTarget='atari' then
    ExeExt:='.tpp'
  else if LTarget='gba' then
    ExeExt:='.gba'
  else if LTarget='nds' then
    ExeExt:='.bin'
  else if (LTarget='netware') or (LTarget='netwlibc') then
    ExeExt:='.nlm'
  else if LTarget='wii' then
    ExeExt:='.dol'
  else if LTarget='wince' then
    ExeExt:='.exe';
end;


function OutputFileName(Const s,ext:String):String;
begin
{$ifndef macos}
  OutputFileName:=OutputDir+'/'+ForceExtension(s,ext);
{$else macos}
  OutputFileName:=ConcatMacPath(OutputDir,ForceExtension(s,ext));
{$endif macos}
end;


function TestOutputFileName(Const s,ext:String):String;
begin
{$ifndef macos}
  TestOutputFileName:=TestOutputDir+'/'+ForceExtension(SplitFileName(s),ext);
{$else macos}
  TestOutputFileName:=ConcatMacPath(TestOutputDir,ForceExtension(SplitFileName(s),ext));
{$endif macos}
end;


function ExitWithInternalError(const OutName:string):boolean;
var
  t : text;
  s : string;
begin
  ExitWithInternalError:=false;
  { open logfile }
  assign(t,Outname);
  {$I-}
   reset(t);
  {$I+}
  if ioresult<>0 then
   exit;
  while not eof(t) do
   begin
     readln(t,s);
     if pos('Fatal: Internal error ',s)>0 then
      begin
        ExitWithInternalError:=true;
        break;
      end;
   end;
  close(t);
end;


function RunCompiler:boolean;
var
  args,
  wpoargs : string;
  passnr,
  passes  : longint;
  execres : boolean;
  EndTicks,
  StartTicks : int64;
begin
  RunCompiler:=false;
  args:='-n -T'+CompilerTarget+' -Fu'+RTLUnitsDir;
  args:=args+' -FE'+TestOutputDir;
{$ifdef macos}
  args:=args+' -WT ';  {tests should be compiled as MPWTool}
{$endif macos}
  if ExtraCompilerOpts<>'' then
   args:=args+ExtraCompilerOpts;
{$ifdef unix}
  { Add runtime library path to current dir to find .so files }
  if Config.NeedLibrary then
{$ifndef darwin}
   args:=args+' -Fl'+TestOutputDir+' ''-k-rpath .''';
{$else darwin}
   args:=args+' -Fl'+TestOutputDir;
{$endif darwin}
{$endif unix}
  if Config.NeedOptions<>'' then
   args:=args+' '+Config.NeedOptions;
  wpoargs:='';
  if (Config.WpoPasses=0) or
     (Config.WpoParas='') then
    passes:=1
  else
    passes:=config.wpopasses+1;
  args:=args+' '+PPFile[current];

  for passnr:=1 to passes do
    begin
      if (passes>1) then
        begin
          wpoargs:=' -OW'+config.wpoparas+' -FW'+TestOutputFileName(PPFile[current],'wp'+tostr(passnr));
          if (passnr>1) then
            wpoargs:=wpoargs+' -Ow'+config.wpoparas+' -Fw'+TestOutputFileName(PPFile[current],'wp'+tostr(passnr-1));
        end;
      Verbose(V_Debug,'Executing '+compilerbin+' '+args+wpoargs);
      { also get the output from as and ld that writes to stderr sometimes }
      StartTicks:=GetMicroSTicks;
    {$ifndef macos}
      execres:=ExecuteRedir(CompilerBin,args+wpoargs,'',CompilerLogFile,'stdout');
    {$else macos}
      {Due to that Toolserver is not reentrant, we have to asm and link via script.}
      execres:=ExecuteRedir(CompilerBin,'-s '+args+wpoargs,'',CompilerLogFile,'stdout');
      if execres then
        execres:=ExecuteRedir(TestOutputDir + ':ppas','','',CompilerLogFile,'stdout');
    {$endif macos}
      EndTicks:=GetMicroSTicks;
      Verbose(V_Debug,'Exitcode '+ToStr(ExecuteResult));
      if BenchmarkInfo then
        begin
          Verbose(V_Normal,'Compilation took '+ToStr(EndTicks-StartTicks)+' us');
        end;

      { Error during execution? }
      if (not execres) and (ExecuteResult=0) then
        begin
          AddLog(FailLogFile,TestName);
          AddLog(ResLogFile,failed_to_compile+PPFileInfo[current]);
          AddLog(LongLogFile,line_separation);
          AddLog(LongLogFile,failed_to_compile+PPFileInfo[current]);
          if CopyFile(CompilerLogFile,LongLogFile,true)=0 then
            AddLog(LongLogFile,'IOStatus'+ToStr(IOStatus));
          { avoid to try again }
          AddLog(ExeLogFile,failed_to_compile+PPFileInfo[current]);
          Verbose(V_Warning,'IOStatus: '+ToStr(IOStatus));
          exit;
        end;

      { Check for internal error }
      if ExitWithInternalError(CompilerLogFile) then
       begin
         AddLog(FailLogFile,TestName);
         if Config.Note<>'' then
          AddLog(FailLogFile,Config.Note);
         AddLog(ResLogFile,failed_to_compile+PPFileInfo[current]+' internalerror generated');
         AddLog(LongLogFile,line_separation);
         AddLog(LongLogFile,failed_to_compile+PPFileInfo[current]);
         if Config.Note<>'' then
          AddLog(LongLogFile,Config.Note);
         if CopyFile(CompilerLogFile,LongLogFile,true)=0 then
           AddLog(LongLogFile,'Internal error in compiler');
         { avoid to try again }
         AddLog(ExeLogFile,'Failed to compile '+PPFileInfo[current]);
         Verbose(V_Warning,'Internal error in compiler');
         exit;
       end;
    end;

  { Should the compile fail ? }
  if Config.ShouldFail then
   begin
     if ExecuteResult<>0 then
      begin
        AddLog(ResLogFile,success_compilation_failed+PPFileInfo[current]);
        { avoid to try again }
        AddLog(ExeLogFile,success_compilation_failed+PPFileInfo[current]);
        RunCompiler:=true;
      end
     else
      begin
        AddLog(FailLogFile,TestName);
        if Config.Note<>'' then
          AddLog(FailLogFile,Config.Note);
        AddLog(ResLogFile,failed_compilation_successful+PPFileInfo[current]);
        AddLog(LongLogFile,line_separation);
        AddLog(LongLogFile,failed_compilation_successful+PPFileInfo[current]);
        { avoid to try again }
        AddLog(ExeLogFile,failed_compilation_successful+PPFileInfo[current]);
        if Config.Note<>'' then
          AddLog(LongLogFile,Config.Note);
        CopyFile(CompilerLogFile,LongLogFile,true);
      end;
   end
  else
   begin
     if (ExecuteResult<>0) and
        (((Config.KnownCompileNote<>'') and (Config.KnownCompileError=0)) or
         ((Config.KnownCompileError<>0) and (ExecuteResult=Config.KnownCompileError))) then
      begin
        AddLog(FailLogFile,TestName+known_problem+Config.KnownCompileNote);
        AddLog(ResLogFile,failed_to_run+PPFileInfo[current]+known_problem+Config.KnownCompileNote);
        AddLog(LongLogFile,line_separation);
        AddLog(LongLogFile,known_problem+Config.KnownCompileNote);
        AddLog(LongLogFile,failed_to_compile+PPFileInfo[current]+' ('+ToStr(ExecuteResult)+')');
        if Copyfile(CompilerLogFile,LongLogFile,true)=0 then
          AddLog(LongLogFile,known_problem+'exitcode: '+ToStr(ExecuteResult));
        Verbose(V_Warning,known_problem+'exitcode: '+ToStr(ExecuteResult));
      end
     else if ExecuteResult<>0 then
      begin
        AddLog(FailLogFile,TestName);
        if Config.Note<>'' then
          AddLog(FailLogFile,Config.Note);
        AddLog(ResLogFile,failed_to_compile+PPFileInfo[current]);
        AddLog(LongLogFile,line_separation);
        AddLog(LongLogFile,failed_to_compile+PPFileInfo[current]);
        if Config.Note<>'' then
          AddLog(LongLogFile,Config.Note);
        if CopyFile(CompilerLogFile,LongLogFile,true)=0 then
          AddLog(LongLogFile,'Exitcode: '+ToStr(ExecuteResult)+' (expected 0)');
        { avoid to try again }
        AddLog(ExeLogFile,failed_to_compile+PPFileInfo[current]);
        Verbose(V_Warning,'Exitcode: '+ToStr(ExecuteResult)+' (expected 0)');
      end
     else
      begin
        AddLog(ResLogFile,successfully_compiled+PPFileInfo[current]);
        RunCompiler:=true;
      end;
   end;
end;


function CheckTestExitCode(const OutName:string):boolean;
var
  t : text;
  s : string;
  i,code : integer;
begin
  CheckTestExitCode:=false;
  { open logfile }
  assign(t,Outname);
  {$I-}
   reset(t);
  {$I+}
  if ioresult<>0 then
   exit;
  while not eof(t) do
   begin
     readln(t,s);
     i:=pos('TestExitCode: ',s);
     if i>0 then
      begin
        delete(s,1,i+14-1);
        val(s,ExecuteResult,code);
        if code=0 then;
        CheckTestExitCode:=true;
        break;
      end;
   end;
  close(t);
end;


function RunExecutable:boolean;
const
  MaxTrials = 5;
{$ifdef unix}
  CurrDir = './';
{$else}
  CurrDir = '';
{$endif}
var
  s,
  OldDir,
  FullExeLogFile,
  TestRemoteExe,
  TestExe  : string;
  LocalFile, RemoteFile: string;
  LocalPath: string;
  execcmd,
  pref     : string;
  execres  : boolean;
  index    : integer;
  EndTicks,
  StartTicks : int64;
  function ExecuteRemote(const prog,args:string):boolean;
    var
      Trials : longint;
      Res : boolean;
    begin
      Verbose(V_Debug,'RemoteExecuting '+Prog+' '+args);
      StartTicks:=GetMicroSTicks;
      Res:=false;
      Trials:=0;
      While (Trials<MaxTrials) and not Res do
        begin
          inc(Trials);
          Res:=ExecuteRedir(prog,args,'',EXELogFile,'stdout');
          if not Res then
            Verbose(V_Debug,'Call to '+prog+' failed: '+
              'IOStatus='+ToStr(IOStatus)+
              ' RedirErrorOut='+ToStr(RedirErrorOut)+
              ' RedirErrorIn='+ToStr(RedirErrorIn)+
              ' RedirErrorError='+ToStr(RedirErrorError)+
              ' ExecuteResult='+ToStr(ExecuteResult));
        end;

      if Trials>1 then
        Verbose(V_Debug,'Done in '+tostr(trials)+' trials');
      EndTicks:=GetMicroSTicks;
      ExecuteRemote:=res;
    end;

  function ExecuteEmulated(const prog,args:string):boolean;
    begin
      Verbose(V_Debug,'EmulatorExecuting '+Prog+' '+args);
      StartTicks:=GetMicroSTicks;
      ExecuteEmulated:=ExecuteRedir(prog,args,'',FullExeLogFile,'stdout');
      EndTicks:=GetMicroSTicks;
   end;

label
  done;
begin
  RunExecutable:=false;
  execres:=true;

  TestExe:=OutputFileName(PPFile[current],ExeExt);

  if EmulatorName<>'' then
    begin
      { Get full name out log file, because we change the directory during
        execution }
      FullExeLogFile:=FExpand(EXELogFile);
      {$I-}
       GetDir(0,OldDir);
       ChDir(TestOutputDir);
      {$I+}
      ioresult;
      s:=CurrDir+SplitFileName(TestExe);
      execres:=ExecuteEmulated(EmulatorName,s);
      {$I-}
       ChDir(OldDir);
      {$I+}
    end
  else if RemoteAddr<>'' then
    begin
      { We don't want to create subdirs, remove paths from the test }
      TestRemoteExe:=RemotePath+'/'+SplitFileName(TestExe);
      if deBefore in DelExecutable then
        ExecuteRemote(rshprog,RemotePara+' '+RemoteAddr+' rm -f '+TestRemoteExe);
      execres:=ExecuteRemote(rcpprog,RemotePara+' '+TestExe+' '+RemoteAddr+':'+TestRemoteExe);
      if not execres then
      begin
        Verbose(V_normal, 'Could not copy executable '+TestExe);
        goto done;
      end;
      s:=Config.Files;
      if length(s) > 0 then
      begin
        LocalPath:=SplitPath(PPFile[current]);
        if Length(LocalPath) > 0 then
          LocalPath:=LocalPath+'/';
        repeat
          index:=pos(' ',s);
          if index=0 then
            LocalFile:=s
          else
            LocalFile:=copy(s,1,index-1);
          RemoteFile:=RemotePath+'/'+SplitFileName(LocalFile);
          LocalFile:=LocalPath+LocalFile;
          if DoVerbose and (rcpprog='pscp') then
            pref:='-v '
          else
            pref:='';
          execres:=ExecuteRemote(rcpprog,pref+RemotePara+' '+LocalFile+' '+RemoteAddr+':'+RemoteFile);
          if not execres then
          begin
            Verbose(V_normal, 'Could not copy required file '+LocalFile);
            goto done;
          end;
          if index=0 then
            break;
          s:=copy(s,index+1,length(s)-index);
        until false;
      end;
      { rsh doesn't pass the exitcode, use a second command to print the exitcode
        on the remoteshell to stdout }
      if DoVerbose and (rshprog='plink') then
        execcmd:='-v '
      else
        execcmd:='';
      execcmd:=execcmd+RemotePara+' '+RemoteAddr+' '+rquote+
         'chmod 755 '+TestRemoteExe+
          ' ; cd '+RemotePath+' ; ';
      if UseTimeout then
      begin
        execcmd:=execcmd+'timeout -9 ';
        if Config.Timeout=0 then
          Config.Timeout:=DefaultTimeout;
        str(Config.Timeout,s);
        execcmd:=execcmd+s;
      end;
      { as we moved to RemotePath, if path is not absolute
        we need to use ./execfilename only }
      if not isabsolute(TestRemoteExe) then
        execcmd:=execcmd+' ./'+SplitFileName(TestRemoteExe)
      else
        execcmd:=execcmd+' '+TestRemoteExe;
      execcmd:=execcmd+' ; echo "TestExitCode: $?"';
      if (deAfter in DelExecutable) and
         not Config.NeededAfter then
        execcmd:=execcmd+' ; rm -f '+TestRemoteExe;
      execcmd:=execcmd+rquote;
      execres:=ExecuteRemote(rshprog,execcmd);
      { Check for TestExitCode error in output, sets ExecuteResult }
      CheckTestExitCode(EXELogFile);
    end
  else
    begin
      { Get full name out log file, because we change the directory during
        execution }
      FullExeLogFile:=FExpand(EXELogFile);
      Verbose(V_Debug,'Executing '+TestExe);
      {$I-}
       GetDir(0,OldDir);
       ChDir(TestOutputDir);
      {$I+}
      ioresult;
      { don't redirect interactive and graph programs }
      StartTicks:=GetMicroSTicks;
      if Config.IsInteractive or Config.UsesGraph then
        execres:=ExecuteRedir(CurrDir+SplitFileName(TestExe),'','','','')
      else
        execres:=ExecuteRedir(CurrDir+SplitFileName(TestExe),'','',FullExeLogFile,'stdout');
      EndTicks:=GetMicroSTicks;
      {$I-}
       ChDir(OldDir);
      {$I+}
      ioresult;
    end;

  { Error during execution? }
  Verbose(V_Debug,'Exitcode '+ToStr(ExecuteResult));
  if BenchmarkInfo then
    begin
      Verbose(V_Normal,'Execution took '+ToStr(EndTicks-StartTicks)+' us');
    end;
done:
  if (not execres) and (ExecuteResult=0) then
    begin
      AddLog(FailLogFile,TestName);
      AddLog(ResLogFile,failed_to_run+PPFileInfo[current]);
      AddLog(LongLogFile,line_separation);
      AddLog(LongLogFile,failed_to_run+PPFileInfo[current]);
      if CopyFile(EXELogFile,LongLogFile,true)=0 then
        AddLog(LongLogFile,'IOStatus: '+ToStr(IOStatus));
      { avoid to try again }
      AddLog(ExeLogFile,failed_to_run+PPFileInfo[current]);
      Verbose(V_Warning,'IOStatus: '+ToStr(IOStatus));
      exit;
    end;

  if ExecuteResult<>Config.ResultCode then
   begin
     if (ExecuteResult<>0) and
        (ExecuteResult=Config.KnownRunError) then
       begin
         AddLog(FailLogFile,TestName+known_problem+Config.KnownRunNote);
         AddLog(ResLogFile,failed_to_run+PPFileInfo[current]+known_problem+Config.KnownRunNote);
         AddLog(LongLogFile,line_separation);
         AddLog(LongLogFile,known_problem+Config.KnownRunNote);
         AddLog(LongLogFile,failed_to_run+PPFileInfo[current]+' ('+ToStr(ExecuteResult)+')');
         if Copyfile(EXELogFile,LongLogFile,true)=0 then
           begin
             AddLog(LongLogFile,known_problem+'exitcode: '+ToStr(ExecuteResult)+' (expected '+ToStr(Config.ResultCode)+')');
             AddLog(ExeLogFile,known_problem+'exitcode: '+ToStr(ExecuteResult)+' (expected '+ToStr(Config.ResultCode)+')');
           end;
         Verbose(V_Warning,known_problem+'exitcode: '+ToStr(ExecuteResult)+' (expected '+ToStr(Config.ResultCode)+')');
       end
     else
       begin
         AddLog(FailLogFile,TestName);
         AddLog(ResLogFile,failed_to_run+PPFileInfo[current]);
         AddLog(LongLogFile,line_separation);
         AddLog(LongLogFile,failed_to_run+PPFileInfo[current]+' ('+ToStr(ExecuteResult)+')');
         if Copyfile(EXELogFile,LongLogFile,true)=0 then
           begin
             AddLog(LongLogFile,'Exitcode: '+ToStr(ExecuteResult)+' (expected '+ToStr(Config.ResultCode)+')');
             AddLog(ExeLogFile,'Exitcode: '+ToStr(ExecuteResult)+' (expected '+ToStr(Config.ResultCode)+')');
           end;
         Verbose(V_Warning,'Exitcode: '+ToStr(ExecuteResult)+' (expected '+ToStr(Config.ResultCode)+')');
       end
   end
  else
   begin
     AddLog(ResLogFile,successfully_run+PPFileInfo[current]);
     RunExecutable:=true;
   end;

  if (deAfter in DelExecutable) and not Config.NeededAfter then
    begin
      Verbose(V_Debug,'Deleting executable '+TestExe);
      RemoveFile(TestExe);
      RemoveFile(ForceExtension(TestExe,ObjExt));
      RemoveFile(ForceExtension(TestExe,PPUExt));
    end;
end;


procedure getargs;
var
  para : string;
  i  : longint;

  procedure helpscreen;
  begin
    writeln('dotest [Options] <File>');
    writeln;
    writeln('Options can be:');
    writeln('  !ENV_NAME     parse environment variable ENV_NAME for options');
    writeln('  -A            include ALL tests');
    writeln('  -B            delete executable before remote upload');
    writeln('  -C<compiler>  set compiler to use');
    writeln('  -D            display execution time');
    writeln('  -E            execute test also');
    writeln('  -G            include graph tests');
    writeln('  -I            include interactive tests');
    writeln('  -K            include known bug tests');
    writeln('  -M<emulator>  run the tests using the given emulator');
    writeln('  -O            use timeout wrapper for (remote) execution');
    writeln('  -P<path>      path to the tests tree on the remote machine');
    writeln('  -R<remote>    run the tests remotely with the given rsh/ssh address');
    writeln('  -S            use ssh instead of rsh');
    writeln('  -T[cpu-]<os>  run tests for target cpu and os');
    writeln('  -U<remotepara>');
    writeln('                pass additional parameter to remote program. Multiple -U can be used');
    writeln('  -V            be verbose');
    writeln('  -W            use putty compatible file names when testing (plink and pscp)');
    writeln('  -X            don''t use COMSPEC');
    writeln('  -Y<opts>      extra options passed to the compiler. Several -Y<opt> can be given.');
    writeln('  -Z            remove temporary files (executable,ppu,o)');
    halt(1);
  end;

  procedure interpret_option (arg : string);
  var
    ch : char;
    j : longint;
  begin
    ch:=Upcase(para[2]);
    delete(para,1,2);
    case ch of
     'A' :
       begin
         DoGraph:=true;
         DoInteractive:=true;
         DoKnown:=true;
         DoAll:=true;
       end;

     'B' : Include(DelExecutable,deBefore);

     'C' : CompilerBin:=Para;

     'D' : BenchMarkInfo:=true;

     'E' : DoExecute:=true;

     'G' : begin
             DoGraph:=true;
             if para='-' then
               DoUsual:=false;
           end;

     'I' : begin
             DoInteractive:=true;
             if para='-' then
               DoUsual:=false;
           end;

     'K' : begin
             DoKnown:=true;
             if para='-' then
               DoUsual:=false;
           end;

     'M' : EmulatorName:=Para;

     'O' : UseTimeout:=true;

     'P' : RemotePath:=Para;

     'R' : RemoteAddr:=Para;

     'S' :
       begin
         rshprog:='ssh';
         rcpprog:='scp';
       end;

     'T' :
       begin
         j:=Pos('-',Para);
         if j>0 then
           begin
             CompilerCPU:=Copy(Para,1,j-1);
             CompilerTarget:=Copy(Para,j+1,length(para));
           end
         else
           CompilerTarget:=Para
       end;

     'U' :
       RemotePara:=RemotePara+' '+Para;

     'V' : DoVerbose:=true;

     'W' :
       begin
         rshprog:='plink';
         rcpprog:='pscp';
         rquote:='"';
       end;

     'X' : UseComSpec:=false;

     'Y' : ExtraCompilerOpts:= ExtraCompilerOpts +' '+ Para;

     'Z' : Include(DelExecutable,deAfter);
    end;
 end;

 procedure interpret_env(arg : string);
 var
   para : string;
   pspace : longint;
 begin
   { Get rid of leading '!' }
   delete(arg,1,1);
   arg:=getenv(arg);
   while (length(arg)>0) do
     begin
       while (length(arg)>0) and (arg[1]=' ') do
         delete(arg,1,1);
       pspace:=pos(' ',arg);
       if pspace=0 then
         pspace:=length(arg)+1;
       para:=copy(arg,1,pspace-1);
       if (length(para)>0) and (para[1]='-') then
         interpret_option (para)
       else
         begin
           PPFile.Insert(current,ForceExtension(Para,'pp'));
           inc(current);
         end;
       delete(arg,1,pspace);
     end;
 end;

begin
  CompilerBin:='ppc386'+srcexeext;
  for i:=1 to paramcount do
   begin
     para:=Paramstr(i);
     if (para[1]='-') then
      interpret_option(para)
     else if (para[1]='!') then
       interpret_env(para)
     else
       begin
         PPFile.Insert(current,ForceExtension(Para,'pp'));
         inc(current);
       end;
   end;
  if current=0 then
    HelpScreen;
  { disable graph,interactive when running remote }
  if RemoteAddr<>'' then
    begin
      DoGraph:=false;
      DoInteractive:=false;
    end;
end;


procedure RunTest;
var
  PPDir : string;
  Res : boolean;
begin
  Res:=GetConfig(PPFile[current],Config);

  if Res then
    begin
      Res:=GetCompilerCPU;
      Res:=GetCompilerTarget;
{$ifndef MACOS}
      RTLUnitsDir:='units/'+{$ifdef LIMIT83FS}CompilerTarget{$else}CompilerFullTarget{$endif};
{$else MACOS}
      RTLUnitsDir:=':units:'+CompilerFullTarget;
{$endif MACOS}
      if not PathExists(RTLUnitsDir) then
        Verbose(V_Abort,'Unit path "'+RTLUnitsDir+'" does not exists');
{$ifndef MACOS}
      OutputDir:='output/'+{$ifdef LIMIT83FS}CompilerTarget{$else}CompilerFullTarget{$endif};
{$else MACOS}
      OutputDir:=':output:'+CompilerFullTarget;
{$endif MACOS}
      if not PathExists(OutputDir) then
        Verbose(V_Abort,'Output path "'+OutputDir+'" does not exists');
      { Global log files }
      ResLogFile:=OutputFileName('log','');
      LongLogFile:=OutputFileName('longlog','');
      FailLogFile:=OutputFileName('faillist','');
      { Make subdir in output if needed }
      PPDir:=SplitPath(PPFile[current]);
      if PPDir[length(PPDir)] in ['/','\'{$ifdef MACOS},':'{$endif MACOS}] then
        Delete(PPDir,length(PPDir),1);
      if PPDir<>'' then
        begin
{$ifndef MACOS}
          TestOutputDir:=OutputDir+'/'+PPDir;
{$else MACOS}
          TestOutputDir:=OutputDir+PPDir;
{$endif MACOS}
          mkdirtree(TestOutputDir);
        end
      else
        TestOutputDir:=OutputDir;
      { Per test logfiles }
      CompilerLogFile:=TestOutputFileName(SplitFileName(PPFile[current]),'log');
      ExeLogFile:=TestOutputFileName(SplitFileName(PPFile[current]),'elg');
      Verbose(V_Debug,'Using Compiler logfile: '+CompilerLogFile);
      Verbose(V_Debug,'Using Execution logfile: '+ExeLogFile);
    end;

  if Res then
   begin
     if Config.UsesGraph and (not DoGraph) then
      begin
        AddLog(ResLogFile,skipping_graph_test+PPFileInfo[current]);
        { avoid a second attempt by writing to elg file }
        AddLog(EXELogFile,skipping_graph_test+PPFileInfo[current]);
        Verbose(V_Warning,skipping_graph_test);
        Res:=false;
      end;
   end;

  if Res then
   begin
     if Config.IsInteractive and (not DoInteractive) then
      begin
        { avoid a second attempt by writing to elg file }
        AddLog(EXELogFile,skipping_interactive_test+PPFileInfo[current]);
        AddLog(ResLogFile,skipping_interactive_test+PPFileInfo[current]);
        Verbose(V_Warning,skipping_interactive_test);
        Res:=false;
      end;
   end;

  if Res then
   begin
     if Config.IsKnownCompileError and (not DoKnown) then
      begin
        { avoid a second attempt by writing to elg file }
        AddLog(EXELogFile,skipping_known_bug+PPFileInfo[current]);
        AddLog(ResLogFile,skipping_known_bug+PPFileInfo[current]);
        Verbose(V_Warning,skipping_known_bug);
        Res:=false;
      end;
   end;

  if Res and not DoUsual then
    res:=(Config.IsInteractive and DoInteractive) or
         (Config.IsKnownRunError and DoKnown) or
         (Config.UsesGraph and DoGraph);

  if Res then
   begin
     if (Config.MinVersion<>'') and not DoAll then
      begin
        Verbose(V_Debug,'Required compiler version: '+Config.MinVersion);
        Res:=GetCompilerVersion;
        if CompilerVersion<Config.MinVersion then
         begin
           { avoid a second attempt by writing to elg file }
           AddLog(EXELogFile,skipping_compiler_version_too_low+PPFileInfo[current]);
           AddLog(ResLogFile,skipping_compiler_version_too_low+PPFileInfo[current]);
           Verbose(V_Warning,'Compiler version too low '+CompilerVersion+' < '+Config.MinVersion);
           Res:=false;
         end;
      end;
   end;

  if Res then
   begin
     if (Config.MaxVersion<>'') and not DoAll then
      begin
        Verbose(V_Debug,'Highest compiler version: '+Config.MaxVersion);
        Res:=GetCompilerVersion;
        if CompilerVersion>Config.MaxVersion then
         begin
           { avoid a second attempt by writing to elg file }
           AddLog(EXELogFile,skipping_compiler_version_too_high+PPFileInfo[current]);
           AddLog(ResLogFile,skipping_compiler_version_too_high+PPFileInfo[current]);
           Verbose(V_Warning,'Compiler version too high '+CompilerVersion+' > '+Config.MaxVersion);
           Res:=false;
         end;
      end;
   end;

  if Res then
   begin
     if Config.NeedCPU<>'' then
      begin
        Verbose(V_Debug,'Required compiler cpu: '+Config.NeedCPU);
        if not IsInList(CompilerCPU,Config.NeedCPU) then
         begin
           { avoid a second attempt by writing to elg file }
           AddLog(EXELogFile,skipping_other_cpu+PPFileInfo[current]);
           AddLog(ResLogFile,skipping_other_cpu+PPFileInfo[current]);
           Verbose(V_Warning,'Compiler cpu "'+CompilerCPU+'" is not in list "'+Config.NeedCPU+'"');
           Res:=false;
         end;
      end;
   end;

  if Res then
   begin
     if Config.SkipCPU<>'' then
      begin
        Verbose(V_Debug,'Skip compiler cpu: '+Config.SkipCPU);
        if IsInList(CompilerCPU,Config.SkipCPU) then
         begin
           { avoid a second attempt by writing to elg file }
           AddLog(EXELogFile,skipping_other_cpu+PPFileInfo[current]);
           AddLog(ResLogFile,skipping_other_cpu+PPFileInfo[current]);
           Verbose(V_Warning,'Compiler cpu "'+CompilerCPU+'" is in list "'+Config.SkipCPU+'"');
           Res:=false;
         end;
      end;
   end;

  if Res then
   begin
     if Config.SkipEmu<>'' then
      begin
        Verbose(V_Debug,'Skip emulator: '+emulatorname);
        if IsInList(emulatorname,Config.SkipEmu) then
         begin
           { avoid a second attempt by writing to elg file }
           AddLog(EXELogFile,skipping_other_cpu+PPFileInfo[current]);
           AddLog(ResLogFile,skipping_other_cpu+PPFileInfo[current]);
           Verbose(V_Warning,'Emulator "'+emulatorname+'" is in list "'+Config.SkipEmu+'"');
           Res:=false;
         end;
      end;
   end;

  if Res then
   begin
     if Config.NeedTarget<>'' then
      begin
        Verbose(V_Debug,'Required compiler target: '+Config.NeedTarget);
        if not IsInList(CompilerTarget,Config.NeedTarget) then
         begin
           { avoid a second attempt by writing to elg file }
           AddLog(EXELogFile,skipping_other_target+PPFileInfo[current]);
           AddLog(ResLogFile,skipping_other_target+PPFileInfo[current]);
           Verbose(V_Warning,'Compiler target "'+CompilerTarget+'" is not in list "'+Config.NeedTarget+'"');
           Res:=false;
         end;
      end;
   end;

  if Res then
   begin
     if Config.SkipTarget<>'' then
      begin
        Verbose(V_Debug,'Skip compiler target: '+Config.NeedTarget);
        if IsInList(CompilerTarget,Config.SkipTarget) then
         begin
           { avoid a second attempt by writing to elg file }
           AddLog(EXELogFile,skipping_other_target+PPFileInfo[current]);
           AddLog(ResLogFile,skipping_other_target+PPFileInfo[current]);
           Verbose(V_Warning,'Compiler target "'+CompilerTarget+'" is in list "'+Config.SkipTarget+'"');
           Res:=false;
         end;
      end;
   end;

  if Res then
   begin
     Res:=RunCompiler;
     if Res and Config.NeedRecompile then
      Res:=RunCompiler;
   end;

  if Res and (not Config.ShouldFail) then
   begin
     if (Config.NoRun) then
      begin
        { avoid a second attempt by writing to elg file }
        AddLog(EXELogFile,skipping_run_test+PPFileInfo[current]);
        AddLog(ResLogFile,skipping_run_test+PPFileInfo[current]);
        Verbose(V_Debug,skipping_run_test);
      end
     else if Config.IsKnownRunError and (not DoKnown) then
      begin
        { avoid a second attempt by writing to elg file }
        AddLog(EXELogFile,skipping_known_bug+PPFileInfo[current]);
        AddLog(ResLogFile,skipping_known_bug+PPFileInfo[current]);
        Verbose(V_Warning,skipping_known_bug);
      end
     else
      begin
        if DoExecute then
         begin
           if FileExists(TestOutputFilename(PPFile[current],'ppu')) or
              FileExists(TestOutputFilename(PPFile[current],'ppo')) or
              FileExists(TestOutputFilename(PPFile[current],'ppw')) then
             begin
               AddLog(ExeLogFile,skipping_run_unit+PPFileInfo[current]);
               AddLog(ResLogFile,skipping_run_unit+PPFileInfo[current]);
               Verbose(V_Debug,'Unit found, skipping run test')
             end
           else
            Res:=RunExecutable;
         end;
      end;
   end;
end;


begin
  Current:=0;
  PPFile:=TStringList.Create;
  PPFile.Capacity:=10;
  PPFileInfo:=TStringList.Create;
  PPFileInfo.Capacity:=10;
  GetArgs;
  SetTargetDirectoriesStyle;
  Verbose(V_Debug,'Found '+ToStr(PPFile.Count)+' tests to run');
  if current>0 then
    for current:=0 to PPFile.Count-1 do
      begin
        SetPPFileInfo;
        TestName:=Copy(PPFile[current],1,Pos('.pp',PPFile[current])-1);
        Verbose(V_Normal,'Running test '+TestName+', file '+PPFile[current]);
        RunTest;
      end;
  PPFile.Free;
  PPFileInfo.Free;
end.
