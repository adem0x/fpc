unit fpdocxmlopts;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpdocproj, dom, fptemplate;

Type
  { TXMLFPDocOptions }

  TXMLFPDocOptions = Class(TComponent)
  private
    FExpandMacros: Boolean;
    FMacros: TStrings;
    procedure SetMacros(AValue: TStrings);
  Protected
    Procedure Error(Const Msg : String);
    Procedure Error(Const Fmt : String; Args : Array of Const);
    Procedure LoadPackage(APackage : TFPDocPackage; E : TDOMElement); virtual;
    Procedure LoadPackages(Packages : TFPDocPackages; E : TDOMElement);
    Procedure LoadEngineOptions(Options : TEngineOptions; E : TDOMElement); virtual;
    Procedure SaveEngineOptions(Options : TEngineOptions; XML : TXMLDocument; AParent : TDOMElement); virtual;
    procedure SaveDescription(const ADescription: String; XML: TXMLDocument;  AParent: TDOMElement); virtual;
    procedure SaveInputFile(const AInputFile: String; XML: TXMLDocument; AParent: TDOMElement);virtual;
    Procedure SavePackage(APackage : TFPDocPackage; XML : TXMLDocument; AParent : TDOMElement); virtual;
    procedure DoMacro(Sender: TObject; const TagString: String; TagParams: TStringList; out ReplaceText: String); virtual;
    function ExpandMacrosInFile(AFileName: String): TStream; virtual;
  Public
    Constructor Create (AOwner : TComponent); override;
    Destructor Destroy; override;
    Procedure LoadOptionsFromFile(AProject : TFPDocProject; Const AFileName : String);
    Procedure LoadFromXML(AProject : TFPDocProject; XML : TXMLDocument); virtual;
    Procedure SaveOptionsToFile(AProject : TFPDocProject; Const AFileName : String);
    procedure SaveToXML(AProject : TFPDocProject; ADoc: TXMLDocument); virtual;
    Property Macros : TStrings Read FMacros Write SetMacros;
    Property ExpandMacros : Boolean Read FExpandMacros Write FExpandMacros;
  end;
  EXMLFPdoc = Class(Exception);

Function IndexOfString(S : String; List : Array of string) : Integer;

Const
  OptionCount = 11;
  OptionNames : Array[0..OptionCount] of string
         = ('hide-protected','warn-no-node','show-private',
            'stop-on-parser-error', 'ostarget','cputarget',
            'mo-dir','parse-impl','format', 'language',
            'package','dont-trim');

implementation

Uses XMLRead, XMLWrite;

Resourcestring
  SErrInvalidRootNode = 'Invalid options root node: Got "%s", expected "docproject"';
  SErrNoPackagesNode = 'No "packages" node found in docproject';
  SErrNoInputFile = 'unit tag without file attribute found';
  SErrNoDescrFile = 'description tag without file attribute';

{ TXMLFPDocOptions }

Function IndexOfString(S : String; List : Array of string) : Integer;

begin
  S:=UpperCase(S);
  Result:=High(List);
  While (Result>=0) and (S<>UpperCase(List[Result])) do
    Dec(Result);
end;

procedure TXMLFPDocOptions.SetMacros(AValue: TStrings);
begin
  if FMacros=AValue then Exit;
  FMacros.Assign(AValue);
end;

procedure TXMLFPDocOptions.Error(Const Msg: String);
begin
  Raise EXMLFPDoc.Create(Msg);
end;

procedure TXMLFPDocOptions.Error(const Fmt: String; Args: array of const);
begin
  Raise EXMLFPDoc.CreateFmt(Fmt,Args);
end;



procedure TXMLFPDocOptions.LoadPackage(APackage: TFPDocPackage; E: TDOMElement);

  Function LoadInput(I : TDOMElement) : String;

  Var
    S : String;

  begin
    Result:=I['file'];
    If (Result='') then
      Error(SErrNoInputFile);
    S:=I['options'];
    if (S<>'') then
      Result:=S+' '+Result;
  end;

  Function LoadDescription(I : TDOMElement) : String;

  begin
    Result:=I['file'];
    If (Result='') then
      Error(SErrNoDescrFile);
  end;

Var
  N,S : TDOMNode;
  O : TDomElement;

begin
  APackage.Name:=E['name'];
  APackage.output:=E['output'];
  APackage.ContentFile:=E['content'];
  N:=E.FirstChild;
  While (N<>Nil) do
    begin
    If (N.NodeType=ELEMENT_NODE) then
      begin
      O:=N as TDOMElement;
      If (O.NodeName='units') then
        begin
        S:=O.FirstChild;
        While (S<>Nil) do
          begin
          If (S.NodeType=Element_Node) and (S.NodeName='unit') then
            APackage.Inputs.add(LoadInput(S as TDomElement));
          S:=S.NextSibling;
          end;
        end
      else If (O.NodeName='descriptions') then
        begin
        S:=O.FirstChild;
        While (S<>Nil) do
          begin
          If (S.NodeType=Element_Node) and (S.NodeName='description') then
            APackage.Descriptions.add(LoadDescription(S as TDomElement));
          S:=S.NextSibling;
          end;
        end
      end;
    N:=N.NextSibling;
    end;
end;

procedure TXMLFPDocOptions.LoadPackages(Packages: TFPDocPackages; E: TDOMElement
  );

Var
  N : TDOMNode;

begin
  N:=E.FirstChild;
  While (N<>Nil) do
    begin
    If (N.NodeName='package') and (N.NodeType=ELEMENT_NODE) then
      LoadPackage(Packages.Add as TFPDocPackage, N as TDOMElement);
    N:=N.NextSibling;
    end;
end;

procedure TXMLFPDocOptions.LoadEngineOptions(Options: TEngineOptions;
  E: TDOMElement);

  Function TrueValue(V : String) : Boolean;

  begin
    V:=LowerCase(V);
    Result:=(v='true') or (v='1') or (v='yes');
  end;


Var
  O : TDOMnode;
  N,V : String;

begin
  O:=E.FirstChild;
  While (O<>Nil) do
    begin
    If (O.NodeType=Element_NODE) and (O.NodeName='option') then
      begin
      N:=LowerCase(TDOMElement(o)['name']);
      V:=TDOMElement(o)['value'];
      Case IndexOfString(N,OptionNames) of
        0 : Options.HideProtected:=TrueValue(v);
        1 : Options.WarnNoNode:=TrueValue(v);
        2 : Options.ShowPrivate:=TrueValue(v);
        3 : Options.StopOnParseError:=TrueValue(v);
        4 : Options.ostarget:=v;
        5 : Options.cputarget:=v;
        6 : Options.MoDir:=V;
        7 : Options.InterfaceOnly:=Not TrueValue(V);
        8 : Options.Backend:=V;
        9 : Options.Language:=v;
        10 : Options.DefaultPackageName:=V;
        11 : Options.DontTrim:=TrueValue(V);
      else
        Options.BackendOptions.add('--'+n);
        Options.BackendOptions.add(v);
      end;
      end;
    O:=O.NextSibling
    end;
end;

procedure TXMLFPDocOptions.SaveToXML(AProject: TFPDocProject; ADoc: TXMLDocument);

var
  i: integer;
  E,PE: TDOMElement;

begin
  E:=ADoc.CreateElement('docproject');
  ADoc.AppendChild(E);
  E:=ADoc.CreateElement('options');
  ADoc.DocumentElement.AppendChild(E);
  SaveEngineOptions(AProject.Options,ADoc,E);
  E:=ADoc.CreateElement('packages');
  ADoc.DocumentElement.AppendChild(E);
  for i := 0 to AProject.Packages.Count - 1 do
    begin
    PE:=ADoc.CreateElement('package');
    E.AppendChild(PE);
    SavePackage(AProject.Packages[i],ADoc,PE);
    end;
end;

Procedure TXMLFPDocOptions.SaveEngineOptions(Options : TEngineOptions; XML : TXMLDocument; AParent : TDOMElement);

  procedure AddStr(const n, v: string);
  var
    E : TDOMElement;
  begin
    if (v='') then
      Exit;
    E:=XML.CreateElement('option');
    AParent.AppendChild(E);
    E['name'] := n;
    E['value'] := v;
  end;

  procedure AddBool(const AName: string; B: Boolean);

  begin
    if B then
      AddStr(Aname,'true')
    else
      AddStr(Aname,'false');
  end;

begin
  AddStr('ostarget', Options.OSTarget);
  AddStr('cputarget', Options.CPUTarget);
  AddStr('mo-dir', Options.MoDir);
  AddStr('format', Options.Backend);
  AddStr('language', Options.Language);
  AddStr('package', Options.DefaultPackageName);
  AddBool('hide-protected', Options.HideProtected);
  AddBool('warn-no-node', Options.WarnNoNode);
  AddBool('show-private', Options.ShowPrivate);
  AddBool('stop-on-parser-error', Options.StopOnParseError);
  AddBool('parse-impl', Options.InterfaceOnly);
  AddBool('dont-trim', Options.DontTrim);
end;

Procedure TXMLFPDocOptions.SaveInputFile(Const AInputFile : String; XML : TXMLDocument; AParent: TDOMElement);

  Function GetNextWord(Var s : string) : String;

  Const
    WhiteSpace = [' ',#9,#10,#13];

  var
    i,j: integer;

  begin
    I:=1;
    While (I<=Length(S)) and (S[i] in WhiteSpace) do
      Inc(I);
    J:=I;
    While (J<=Length(S)) and (not (S[J] in WhiteSpace)) do
      Inc(J);
    if (I<=Length(S)) then
      Result:=Copy(S,I,J-I);
    Delete(S,1,J);
  end;


Var
  S,W,F,O : String;

begin
  S:=AInputFile;
  O:='';
  F:='';
  While (S<>'') do
    begin
    W:=GetNextWord(S);
    If (W<>'') then
      begin
      if W[1]='-' then
        begin
        if (O<>'') then
          O:=O+' ';
        o:=O+W;
        end
      else
        F:=W;
      end;
    end;
  AParent['file']:=F;
  AParent['options']:=O;
end;

Procedure TXMLFPDocOptions.SaveDescription(Const ADescription : String; XML : TXMLDocument; AParent: TDOMElement);

begin
  AParent['file']:=ADescription;
end;

Procedure TXMLFPDocOptions.SavePackage(APackage: TFPDocPackage; XML : TXMLDocument; AParent: TDOMElement);


var
  i: integer;
  E,PE : TDomElement;

begin
  AParent['name']:=APackage.Name;
  AParent['output']:=APackage.Output;
  AParent['content']:=APackage.ContentFile;
  // Units
  PE:=XML.CreateElement('units');
  AParent.AppendChild(PE);
  for i:=0 to APackage.Inputs.Count-1 do
    begin
    E:=XML.CreateElement('unit');
    PE.AppendChild(E);
    SaveInputFile(APackage.Inputs[i],XML,E);
    end;
  // Descriptions
  PE:=XML.CreateElement('descriptions');
  AParent.AppendChild(PE);
  for i:=0 to APackage.Descriptions.Count-1 do
    begin
    E:=XML.CreateElement('description');
    PE.AppendChild(E);
    SaveDescription(APackage.Descriptions[i],XML,E);
    end;
end;

constructor TXMLFPDocOptions.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMacros:=TStringList.Create;
end;

destructor TXMLFPDocOptions.Destroy;
begin
  FreeAndNil(FMacros);
  inherited Destroy;
end;

procedure TXMLFPDocOptions.DoMacro(Sender: TObject; const TagString: String;
  TagParams: TStringList; out ReplaceText: String);
begin
  ReplaceText:=FMacros.Values[TagString];
end;

Function TXMLFPDocOptions.ExpandMacrosInFile(AFileName : String) : TStream;

Var
  F : TFileStream;
  T : TTemplateParser;

begin
  F:=TFileStream.Create(AFileName,fmOpenRead or fmShareDenyWrite);
  try
    Result:=TMemoryStream.Create;
    try
      T:=TTemplateParser.Create;
      try
        T.StartDelimiter:='$(';
        T.EndDelimiter:=')';
        T.AllowTagParams:=true;
        T.OnReplaceTag:=@DoMacro;
        T.ParseStream(F,Result);
      finally
        T.Free;
      end;
    except
      FreeAndNil(Result);
      Raise;
    end;
  finally
    F.Free;
  end;
end;

procedure TXMLFPDocOptions.LoadOptionsFromFile(AProject: TFPDocProject; const AFileName: String);

Var
  XML : TXMLDocument;
  S : TStream;

begin
  If ExpandMacros then
    S:=ExpandMacrosInFile(AFileName)
  else
    S:=TFileStream.Create(AFileName,fmOpenRead or fmShareDenyWrite);
  try
    ReadXMLFile(XML,S,AFileName);
    try
      LoadFromXML(AProject,XML);
    finally
      FreeAndNil(XML);
    end;
  finally
    S.Free;
  end;
end;

procedure TXMLFPDocOptions.LoadFromXML(AProject: TFPDocProject;
  XML: TXMLDocument);

Var
  E : TDOMElement;
  N : TDomNode;

begin
  E:=XML.DocumentElement;
  if (E.NodeName<>'docproject') then
    Error(SErrInvalidRootNode,[E.NodeName]);
  N:=E.FindNode('packages');
  If (N=Nil) or (N.NodeType<>ELEMENT_NODE) then
    Error(SErrNoPackagesNode);
  LoadPackages(AProject.Packages,N as TDomElement);
  N:=E.FindNode('options');
  If (N<>Nil) and (N.NodeType=ELEMENT_NODE) then
    LoadEngineOptions(AProject.Options,N as TDOMElement);
end;

Procedure TXMLFPDocOptions.SaveOptionsToFile(AProject: TFPDocProject; const AFileName: String);

Var
  XML : TXMLDocument;

begin
  XML:=TXMLDocument.Create;
  try
    SaveToXML(AProject,XML);
    WriteXMLFile(XML, AFileName);
  finally
    XML.Free;
  end;
end;

end.

