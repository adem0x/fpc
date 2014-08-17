
function ThreadFunc(Data: Pointer): Pointer; cdecl;
var
  LThread: TThread;
  LFreeOnTerminate: Boolean;
  ISuspended: Boolean;
begin
  //Debugln('Enter ThreadFunc');
  Result := nil;
  LThread := TThread(Data);
  ISuspended := LThread.FInitialSuspended;
  if ISuspended then
  begin
    if not LThread.FTerminated then
    begin
      LockMutex(LThread.FSem);
      WaitCondition(LThread.FCond, LThread.FSem);
      UnlockMutex(LThread.FSem);
    end;  
  end;
  Sleep(1);
  if not LThread.FTerminated then
  begin
    //Debugln('Execute Thread');
    //try
      LThread.Execute;
    //Debugln('Back from Thread');  
    {except
      on E: Exception do
      begin
        //DebugLn('Exception in Thread '+ e.Classname + e.MEssage);
        LThread.FFatalException := TObject(AcquireExceptionObject);
        if E is EThreadDestroyCalled then
           LThread.FFreeOnTerminate := true; 
      end;
    end;}
    Sleep(1); // not sure why this is needed, but without the stack seems corrupted
              // when FreeOnTerminate = False
  end;    
  LFreeOnTerminate := LThread.FreeOnTerminate;
  LThread.DoTerminate;
  LThread.FFinished := True;
  if LFreeOnTerminate then
    LThread.Free;
  //debugln('Finished Thread?, then what to do now?')  
end;

  
{procedure StartThreadUp(Thr: Pointer; se: Pointer; FH: Pointer); cdecl;
var
  FHandle: Integer;
  ThrC: TThread;
  FHandlePtr: PLongInt;
begin
  ThrC := TThread(Se);
  FHandlePtr := FH;
  //Debugln('here Thread with new stack');
  //FHandlePtr^ := 1;
  FHandlePtr^ := CreateThread(TThreadEntryfunction(Thr), ThrC); 
  //Debugln(' Started my Thread');
end;
}
constructor TThread.Create(CreateSuspended: Boolean; const StackSize: SizeUInt = DefaultStackSize);
//var
//  StackSwapArgs: PStackSwapArgs;
//  sss: TStackSwapStruct;
begin
  inherited Create;
  FSuspended := CreateSuspended;
  FInitialSuspended := CreateSuspended;
  
  // Mutex for suspend actions
  FSem := CreateMutex;
  FCond := CreateCondition;
  
  if not Assigned(ThreadBase) then
    raise EThread.CreateFmt(SThreadCreateError, ['ThreadLib not found']);
  // prepare  new stack 
  //ThreadStack := GetMem(StackSize);
  //sss.stk_Lower := ThreadStack;
  //sss.stk_Upper := Pointer(IPTR(ThreadStack) + StackSize);
  //sss.stk_Pointer := sss.stk_Upper;
  // Prepare Stack Arguments
  //new(StackSwapArgs);
  //StackSwapArgs^.Args[0] := IPTR(@ThreadFunc);
  //StackSwapArgs^.Args[1] := IPTR(self);
  //StackSwapArgs^.Args[2] := IPTR(@FHandle);
  //StackSwapArgs^.Args[3] := IPTR(0);
  // Stackswap = start Thread
  //NewStackswap(@sss, @StartThreadUp, StackSwapArgs);
  // Stackswap structure not needed anymore
  //Dispose(StackSwapArgs);
  FHandle := CreateThread(@ThreadFunc, Self);
  //FHandle := BeginThread(@ThreadFunc, Self);
  FThreadID := FHandle;
  if FHandle = 0 then
    raise EThread.CreateFmt(SThreadCreateError, ['Cannot Create Thread']);
  // exception if Thread cannot be created
  FFatalException := nil;
end;


destructor TThread.Destroy;
begin
  if FHandle <> 0 then
  begin
    if not FFinished then
    begin
      Terminate;
      if FSuspended then
      begin
        SignalCondition(FCond);
        Sleep(0);
      end;
      WaitFor;
    end;
  end;
  DestroyCondition(FCond);
  DestroyMutex(FSem);
  FFatalException := nil;
  FreeMem(ThreadStack);
  inherited Destroy;
end;

procedure TThread.CallOnTerminate;
begin
  FOnTerminate(Self);
end;

procedure TThread.DoTerminate;
begin
  if Assigned(FOnTerminate) then
    Synchronize(@CallOnTerminate);
end;

function TThread.GetPriority: TThreadPriority;
begin
  //
end;

procedure TThread.SetPriority(Value: TThreadPriority);
begin
  //
end;

procedure TThread.SetSuspended(Value: Boolean);
begin
  if Value <> FSuspended then
    if Value then
      Suspend
    else
      Resume;
end;

procedure TThread.Suspend;
begin
  if FThreadID = GetCurrentThreadID then
  begin
    FSuspended := True;
    LockMutex(FSem);
    WaitCondition(FCond, FSem);
    UnlockMutex(FSem);
  end else
    Raise EThread.create('Suspending one thread from inside another one is unsupported (because it is unsafe and deadlock prone) by AROS');  
end;

procedure TThread.Resume;
begin
  if FSuspended then
  begin
    SignalCondition(FCond);
    Sleep(100);
  end;
  FSuspended := False;
  FInitialSuspended := False;
end;

procedure TThread.Terminate;
begin
  FTerminated := True;
end;

function TThread.WaitFor: Integer;
begin
  if (not FSuspended) and (FHandle <> 0) then
  begin
    Sleep(1);
    WaitThread(FHandle, @Result);
  end;  
end;
