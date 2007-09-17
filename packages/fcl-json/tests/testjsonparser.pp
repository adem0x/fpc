unit testjsonparser;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry,fpjson,
  jsonParser,testjsondata;

type

  { TTestParser }

  TTestParser= class(TTestJSON)
  private
    procedure DoTestError(S: String);
    procedure DoTestFloat(F: TJSONFloat); overload;
    procedure DoTestFloat(F: TJSONFloat; S: String); overload;
    procedure DoTestObject(S: String; const ElNames: array of String);
    procedure DoTestString(S : String);
    procedure DoTestArray(S: String; ACount: Integer);
  published
    procedure TestEmpty;
    procedure TestNull;
    procedure TestTrue;
    procedure TestFalse;
    procedure TestFloat;
    procedure TestInteger;
    procedure TestString;
    procedure TestArray;
    procedure TestObject;
    procedure TestMixed;
    procedure TestErrors;
  end;

implementation

procedure TTestParser.TestEmpty;

Var
  P : TJSONParser;
  J : TJSONData;
  
begin
  P:=TJSONParser.Create('');
  Try
    J:=P.Parse;
    If (J<>Nil) then
      Fail('Empty returns Nil');
  Finally
    FreeAndNil(J);
    FreeAndNil(P);
  end;
end;

procedure TTestParser.TestInteger;

Var
  P : TJSONParser;
  J : TJSONData;

begin
  P:=TJSONParser.Create('1');
  Try
    J:=P.Parse;
    If (J=Nil) then
      Fail('Parse of 1 fails');
    TestJSONType(J,jtNumber);
    TestAsInteger(J,1);
  Finally
    FreeAndNil(J);
    FreeAndNil(P);
  end;
end;

procedure TTestParser.TestNull;

Var
  P : TJSONParser;
  J : TJSONData;

begin
  P:=TJSONParser.Create('Null');
  Try
    J:=P.Parse;
    If (J=Nil) then
      Fail('Parse of Null fails');
    TestJSONType(J,jtNull);
  Finally
    FreeAndNil(J);
    FreeAndNil(P);
  end;
end;

procedure TTestParser.TestTrue;

Var
  P : TJSONParser;
  J : TJSONData;

begin
  P:=TJSONParser.Create('True');
  Try
    J:=P.Parse;
    If (J=Nil) then
      Fail('Parse of True fails');
    TestJSONType(J,jtBoolean);
    TestAsBoolean(J,True);
  Finally
    FreeAndNil(J);
    FreeAndNil(P);
  end;
end;

procedure TTestParser.TestFalse;

Var
  P : TJSONParser;
  J : TJSONData;

begin
  P:=TJSONParser.Create('False');
  Try
    J:=P.Parse;
    If (J=Nil) then
      Fail('Parse of False fails');
    TestJSONType(J,jtBoolean);
    TestAsBoolean(J,False);
  Finally
    FreeAndNil(J);
    FreeAndNil(P);
  end;
end;

procedure TTestParser.TestFloat;


begin
  DoTestFloat(1.2);
  DoTestFloat(-1.2);
  DoTestFloat(0);
  DoTestFloat(1.2e1);
  DoTestFloat(-1.2e1);
  DoTestFloat(0);
  DoTestFloat(1.2,'1.2');
  DoTestFloat(-1.2,'-1.2');
  DoTestFloat(0,'0.0');
end;

procedure TTestParser.TestString;

begin
  DoTestString('A string');
  DoTestString('');
  DoTestString('\"');
end;


procedure TTestParser.TestArray;

Var
  S1,S2,S3 : String;


begin
  DoTestArray('[]',0);
  DoTestArray('[Null]',1);
  DoTestArray('[True]',1);
  DoTestArray('[False]',1);
  DoTestArray('[1]',1);
  DoTestArray('[1, 2]',2);
  DoTestArray('[1, 2, 3]',3);
  Str(1.2,S1);
  Str(2.3,S2);
  Str(3.4,S3);
  DoTestArray('['+S1+']',1);
  DoTestArray('['+S1+', '+S2+']',2);
  DoTestArray('['+S1+', '+S2+', '+S3+']',3);
  DoTestArray('["A string"]',1);
  DoTestArray('["A string", "Another string"]',2);
  DoTestArray('["A string", "Another string", "Yet another string"]',3);
  DoTestArray('[Null, False]',2);
  DoTestArray('[True, False]',2);
  DoTestArray('[Null, 1]',2);
  DoTestArray('[1, "A string"]',2);
  DoTestArray('[1, []]',2);
  DoTestArray('[1, [1, 2]]',2);
end;

procedure TTestParser.TestMixed;

begin
  DoTestArray('[1, {}]',2);
  DoTestArray('[1, { "a" : 1 }]',2);
  DoTestArray('[1, { "a" : 1 }, 1]',3);
  DoTestObject('{ "a" : [1, 2] }',['a']);
  DoTestObject('{ "a" : [1, 2], "B" : { "c" : "d" } }',['a','B']);
end;

procedure TTestParser.TestObject;
begin
  DoTestObject('{}',[]);
  DoTestObject('{ "a" : 1 }',['a']);
  DoTestObject('{ "a" : 1, "B" : "String" }',['a','B']);
  DoTestObject('{ "a" : 1, "B" : {} }',['a','B']);
  DoTestObject('{ "a" : 1, "B" : { "c" : "d" } }',['a','B']);
end;


procedure TTestParser.DoTestObject(S : String; Const ElNames : Array of String);

Var
  P : TJSONParser;
  J : TJSONData;
  O : TJSONObject;
  I : Integer;

begin
  P:=TJSONParser.Create(S);
  Try
    J:=P.Parse;
    If (J=Nil) then
      Fail('Parse of object "'+S+'" fails');
    TestJSONType(J,jtObject);
    TestItemCount(J,High(ElNames)-Low(ElNames)+1);
    O:=TJSONObject(J);
    For I:=Low(ElNames) to High(ElNames) do
      AssertEquals(Format('Element %d name',[I-Low(Elnames)])
                   ,ElNames[i], O.Names[I-Low(ElNames)]);
    TestJSON(J,S);
  Finally
    FreeAndNil(J);
    FreeAndNil(P);
  end;
end;


procedure TTestParser.DoTestArray(S : String; ACount : Integer);

Var
  P : TJSONParser;
  J : TJSONData;

begin
  P:=TJSONParser.Create(S);
  Try
    J:=P.Parse;
    If (J=Nil) then
      Fail('Parse of array "'+S+'" fails');
    TestJSONType(J,jtArray);
    TestItemCount(J,ACount);
    TestJSON(J,S);
  Finally
    FreeAndNil(J);
    FreeAndNil(P);
  end;
end;

procedure TTestParser.TestErrors;

begin
  DoTestError('a');
  DoTestError('"b');
  DoTestError('1Tru');
  DoTestError('b"');
  DoTestError('{"a" : }');
  DoTestError('{"a" : ""');
  DoTestError('{"a : ""');
  DoTestError('[1,]');
  DoTestError('[,]');
  DoTestError('[,,]');
  DoTestError('[1,,]');
end;

procedure TTestParser.DoTestError(S : String);

Var
  P : TJSONParser;
  J : TJSONData;
  ParseOK : Boolean;
  N : String;

begin
  ParseOK:=False;
  P:=TJSONParser.Create(S);
  J:=Nil;
  Try
    Try
      Repeat
        FreeAndNil(J);
        J:=P.Parse;
        ParseOK:=True;
        If (J<>Nil) then
          N:=J.ClassName;
      Until (J=Nil)
    Finally
      FreeAndNil(J);
      FreeAndNil(P);
    end;
  except
    ParseOk:=False;
  end;
  If ParseOK then
    Fail('Parse of JSON string "'+S+'" should fail, but returned '+N);
end;

procedure TTestParser.DoTestString(S: String);

Var
  P : TJSONParser;
  J : TJSONData;

begin
  P:=TJSONParser.Create('"'+S+'"');
  Try
    J:=P.Parse;
    If (J=Nil) then
      Fail('Parse of string "'+S+'" fails');
    TestJSONType(J,jtString);
    TestAsString(J,JSONStringToString(S));
    TestJSON(J,'"'+S+'"');
  Finally
    FreeAndNil(J);
    FreeAndNil(P);
  end;

end;

procedure TTestParser.DoTestFloat(F : TJSONFloat);

Var
  S : String;

begin
  Str(F,S);
  DoTestFloat(F,S);
end;

procedure TTestParser.DoTestFloat(F : TJSONFloat; S : String);

Var
  P : TJSONParser;
  J : TJSONData;

begin
  P:=TJSONParser.Create(S);
  Try
    J:=P.Parse;
    If (J=Nil) then
      Fail('Parse of float '+S+' fails');
    TestJSONType(J,jtNumber);
    TestAsFloat(J,F);
  Finally
    FreeAndNil(J);
    FreeAndNil(P);
  end;
end;


initialization
  RegisterTest(TTestParser);
end.

