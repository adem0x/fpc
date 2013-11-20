
function ThreadFunc(Data: Pointer): Pointer; cdecl;
var
  LThread: TThread;
  LFreeOnTerminate: Boolean;
  ISuspended: Boolean;
begin
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
  if not LThread.FTerminated then
  begin
    //try
      LThread.Execute;
    {except
      on E: Exception do
      begin
        //DebugLn('Exception in Thread '+ e.Classname + e.MEssage);
        LThread.FFatalException := TObject(AcquireExceptionObject);
        if E is EThreadDestroyCalled then
           LThread.FFreeOnTerminate := true; 
      end;
    end;}
    Sleep(0); // not sure why this is needed, but without the stack seems corrupted
              // when FreeOnTerminate = False
  end;    
  LFreeOnTerminate := LThread.FreeOnTerminate;
  LThread.DoTerminate;
  LThread.FFinished := True;
  if LFreeOnTerminate then
    LThread.Free;
end;

constructor TThread.Create(CreateSuspended: Boolean; const StackSize: SizeUInt = DefaultStackSize);
begin
  inherited Create;
  FSuspended := CreateSuspended;
  FInitialSuspended := CreateSuspended;
  
  // Mutex for suspend actions
  FSem := CreateMutex;
  FCond := CreateCondition;
  
  // Create Thread
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
  if FHandle = 0 then
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
