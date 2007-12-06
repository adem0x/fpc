

type
  // Quadruple representing an unresolved component property.
  TUnresolvedReference = class(TlinkedListItem)
  Private
    FRoot: TComponent;     // Root component when streaming
    FPropInfo: PPropInfo;  // Property to set.
    FGlobal,               // Global component.
    FRelative : string;    // Path relative to global component.
    Function Resolve(Instance : TPersistent) : Boolean; // Resolve this reference
    Function RootMatches(ARoot : TComponent) : Boolean; Inline; // True if Froot matches or ARoot is nil.
    Function NextRef : TUnresolvedReference; inline;
  end;  

  // Linked list of TPersistent items that have unresolved properties.  
  TUnResolvedInstance = Class(TLinkedListItem)
    Instance : TPersistent; // Instance we're handling unresolveds for
    FUnresolved : TLinkedList; // The list
    Function RootUnresolved : TUnresolvedReference; inline; // Return root element in list.
    Function ResolveReferences : Boolean; // Return true if all unresolveds were resolved.
  end;

  // Builds a list of TUnResolvedInstances, removes them from global list on free.
  TBuildListVisitor = Class(TLinkedListVisitor)
    List : TFPList;
    Procedure Add(Item : TlinkedListItem); // Add TUnResolvedInstance item to list. Create list if needed
    Destructor Destroy; override; // All elements in list (if any) are removed from the global list.
  end;
  
  // Visitor used to try and resolve instances in the global list
  TResolveReferenceVisitor = Class(TBuildListVisitor)
    Function Visit(Item : TLinkedListItem) : Boolean; override;
  end;
  
  // Visitor used to remove all references to a certain component.
  TRemoveReferenceVisitor = Class(TBuildListVisitor)
    FRef : String;
    FRoot : TComponent;
    Constructor Create(ARoot : TComponent;Const ARef : String);
    Function Visit(Item : TLinkedListItem) : Boolean; override;
  end;

  // Visitor used to collect reference names.
  TReferenceNamesVisitor = Class(TLinkedListVisitor)
    FList : TStrings;
    FRoot : TComponent;
    Function Visit(Item : TLinkedListItem) : Boolean; override;
    Constructor Create(ARoot : TComponent;AList : TStrings);
  end;

  // Visitor used to collect instance names.  
  TReferenceInstancesVisitor = Class(TLinkedListVisitor)
    FList : TStrings;
    FRef  : String;
    FRoot : TComponent;
    Function Visit(Item : TLinkedListItem) : Boolean; override;
    Constructor Create(ARoot : TComponent;Const ARef : String; AList : TStrings);
  end;
  
  // Visitor used to redirect links to another root component.
  TRedirectReferenceVisitor = Class(TLinkedListVisitor)
    FOld,
    FNew : String;
    FRoot : TComponent;
    Function Visit(Item : TLinkedListItem) : Boolean; override;
    Constructor Create(ARoot : TComponent;Const AOld,ANew : String);
  end;
  
var
  NeedResolving : TLinkedList;
  ResolveSection : TRTLCriticalSection;

// Add an instance to the global list of instances which need resolving.
Function AddtoResolveList(AInstance: TPersistent) : TUnResolvedInstance;

begin
  EnterCriticalSection(ResolveSection);
  Try
    If not Assigned(NeedResolving) then
      NeedResolving:=TLinkedList.Create(TUnResolvedInstance);
    Result:=NeedResolving.Add as TUnResolvedInstance;
    Result.Instance:=AInstance;
  finally
    LeaveCriticalSection(ResolveSection);
  end;  
end;

// Walk through the global list of instances to be resolved.  

Procedure VisitResolveList(V : TLinkedListVisitor);

begin
  EnterCriticalSection(ResolveSection);
  Try
    try
      NeedResolving.Foreach(V);
    Finally
      FreeAndNil(V);
    end;  
  Finally
    LeaveCriticalSection(ResolveSection);
  end;  
end;

procedure GlobalFixupReferences;

var
  V : TResolveReferenceVisitor;
  I : Integer;
    
begin
  If (NeedResolving=Nil) then 
    Exit;
  GlobalNameSpace.BeginWrite;
  try
    VisitResolveList(TResolveReferenceVisitor.Create);
  finally
    GlobalNameSpace.EndWrite;
  end;
end;


procedure GetFixupReferenceNames(Root: TComponent; Names: TStrings);

begin
  If (NeedResolving=Nil) then 
    Exit;
  VisitResolveList(TReferenceNamesVisitor.Create(Root,Names));
end;

procedure GetFixupInstanceNames(Root: TComponent; const ReferenceRootName: string; Names: TStrings);

begin
  If (NeedResolving=Nil) then
    Exit;
  VisitResolveList(TReferenceInstancesVisitor.Create(Root,ReferenceRootName,Names));
end;

procedure RedirectFixupReferences(Root: TComponent; const OldRootName, NewRootName: string);

begin
  If (NeedResolving=Nil) then
      Exit;
  VisitResolveList(TRedirectReferenceVisitor.Create(Root,OldRootName,NewRootName));
end;

procedure RemoveFixupReferences(Root: TComponent; const RootName: string);

begin
  If (NeedResolving=Nil) then
      Exit;
  VisitResolveList(TRemoveReferenceVisitor.Create(Root,RootName));
end;

procedure RemoveFixups(Instance: TPersistent);

begin
  // This needs work.
{
  if not Assigned(GlobalFixupList) then
    exit;

  with GlobalFixupList.LockList do
    try
      for i := Count - 1 downto 0 do
      begin
        CurFixup := TPropFixup(Items[i]);
        if (CurFixup.FInstance = Instance) then
        begin
          Delete(i);
          CurFixup.Free;
        end;
      end;
    finally
      GlobalFixupList.UnlockList;
    end;
}
end;

{ TUnresolvedReference }

Function TUnresolvedReference.Resolve(Instance : TPersistent) : Boolean;

Var
  C : TComponent;

begin
  C:=FindGlobalComponent(FGlobal);
  Result:=(C<>Nil);
  If Result then
    begin
    C:=FindNestedComponent(C,FRelative);
    Result:=C<>Nil;
    If Result then
      SetObjectProp(Instance, FPropInfo,C);
    end;
end; 

Function TUnresolvedReference.RootMatches(ARoot : TComponent) : Boolean; Inline;

begin
  Result:=(ARoot=Nil) or (ARoot=FRoot);
end;

Function TUnResolvedReference.NextRef : TUnresolvedReference;

begin
  Result:=TUnresolvedReference(Next);
end;

{ TUnResolvedInstance }

Function TUnResolvedInstance.RootUnresolved : TUnresolvedReference; 

begin
  Result:=Nil;
  If Assigned(FUnResolved) then
    Result:=TUnresolvedReference(FUnResolved.Root);
end;

Function TUnResolvedInstance.ResolveReferences:Boolean;

begin
  // TO DO
  Result:=False;
end;

{ TReferenceNamesVisitor }

Constructor TReferenceNamesVisitor.Create(ARoot : TComponent;AList : TStrings);

begin
  FRoot:=ARoot;
  FList:=FList;
end;

Function TReferenceNamesVisitor.Visit(Item : TLinkedListItem) : Boolean;

Var
  R : TUnresolvedReference;

begin
  R:=TUnResolvedInstance(Item).RootUnresolved;
  While (R<>Nil) do
    begin
    If R.RootMatches(FRoot) then
      If (FList.IndexOf(R.FGlobal)=-1) then 
        FList.Add(R.FGlobal);
    R:=R.NextRef;
    end;
  Result:=True;
end;

{ TReferenceInstancesVisitor }

Constructor TReferenceInstancesVisitor.Create(ARoot : TComponent; Const ARef : String;AList : TStrings);

begin
  FRoot:=ARoot;
  FRef:=UpperCase(ARef);
  FList:=AList;
end;

Function TReferenceInstancesVisitor.Visit(Item : TLinkedListItem) : Boolean;

Var
  R : TUnresolvedReference;

begin
  R:=TUnResolvedInstance(Item).RootUnresolved;
  While (R<>Nil) do
    begin
    If (FRoot=R.FRoot) and (FRef=UpperCase(R.FGLobal)) Then
      If Flist.IndexOf(R.FRelative)=-1 then
        Flist.Add(R.FRelative);
    R:=R.NextRef;
    end;
  Result:=True;
end;

{ TRedirectReferenceVisitor }

Constructor TRedirectReferenceVisitor.Create(ARoot : TComponent; Const AOld,ANew  : String);

begin
  FRoot:=ARoot;
  FOld:=UpperCase(AOld);
  FNew:=ANew;
end;

Function TRedirectReferenceVisitor.Visit(Item : TLinkedListItem) : Boolean;

Var
  R : TUnresolvedReference;

begin
  R:=TUnResolvedInstance(Item).RootUnresolved;
  While (R<>Nil) do
    begin
    If R.RootMatches(FRoot) and (FOld=UpperCase(R.FGLobal)) Then
      R.FGlobal:=FNew;
    R:=R.NextRef;
    end;
  Result:=True;
end;

{ TRemoveReferenceVisitor }

Constructor TRemoveReferenceVisitor.Create(ARoot : TComponent; Const ARef  : String);

begin
  FRoot:=ARoot;
  FRef:=UpperCase(ARef);
end;

Function TRemoveReferenceVisitor.Visit(Item : TLinkedListItem) : Boolean;

begin
  // TO DO
  Result:=True;
end;

{ TBuildListVisitor }

Procedure TBuildListVisitor.Add(Item : TlinkedListItem);

begin
  If (List=Nil) then
    List:=TFPList.Create;
  List.Add(Item);
end;  

Destructor TBuildListVisitor.Destroy;

Var
  I : Integer;

begin
  If Assigned(List) then
    For I:=0 to List.Count-1 do
      NeedResolving.RemoveItem(TLinkedListItem(List[I]),True);
  FreeAndNil(List);
  Inherited;
end;

{ TResolveReferenceVisitor }

Function TResolveReferenceVisitor.Visit(Item : TLinkedListItem) : Boolean; 

begin
  If TUnResolvedInstance(Item).ResolveReferences then
    Add(Item);
  Result:=True;  
end;
