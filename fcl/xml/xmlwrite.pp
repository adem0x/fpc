{
    $Id: xmlwrite.pp,v 1.19 2005/03/14 21:10:12 florian Exp $
    This file is part of the Free Component Library

    XML writing routines
    Copyright (c) 1999-2000 by Sebastian Guenther, sg@freepascal.org

    See the file COPYING.modifiedLGPL, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}


unit XMLWrite;

{$MODE objfpc}
{$H+}

interface

uses Classes, DOM;

procedure WriteXMLFile(doc: TXMLDocument; const AFileName: String); overload;
procedure WriteXMLFile(doc: TXMLDocument; var AFile: Text); overload;
procedure WriteXMLFile(doc: TXMLDocument; AStream: TStream); overload;

procedure WriteXML(Element: TDOMNode; const AFileName: String); overload;
procedure WriteXML(Element: TDOMNode; var AFile: Text); overload;
procedure WriteXML(Element: TDOMNode; AStream: TStream); overload;


// ===================================================================

implementation

uses SysUtils;

// -------------------------------------------------------------------
//   Writers for the different node types
// -------------------------------------------------------------------

procedure WriteElement(node: TDOMNode); forward;
procedure WriteAttribute(node: TDOMNode); forward;
procedure WriteText(node: TDOMNode); forward;
procedure WriteCDATA(node: TDOMNode); forward;
procedure WriteEntityRef(node: TDOMNode); forward;
procedure WriteEntity(node: TDOMNode); forward;
procedure WritePI(node: TDOMNode); forward;
procedure WriteComment(node: TDOMNode); forward;
procedure WriteDocument(node: TDOMNode); forward;
procedure WriteDocumentType(node: TDOMNode); forward;
procedure WriteDocumentFragment(node: TDOMNode); forward;
procedure WriteNotation(node: TDOMNode); forward;


type
  TWriteNodeProc = procedure(node: TDOMNode);

const
  WriteProcs: array[ELEMENT_NODE..NOTATION_NODE] of TWriteNodeProc =
    (@WriteElement, @WriteAttribute, @WriteText, @WriteCDATA, @WriteEntityRef,
     @WriteEntity, @WritePI, @WriteComment, @WriteDocument, @WriteDocumentType,
     @WriteDocumentFragment, @WriteNotation);

procedure WriteNode(node: TDOMNode);
begin
  WriteProcs[node.NodeType](node);
end;


// -------------------------------------------------------------------
//   Text file and TStream support
// -------------------------------------------------------------------

type
  TOutputProc = procedure(const Buffer; Count: Longint);

threadvar
  f: ^Text;
  stream: TStream;
  wrt, wrtln: TOutputProc;
  InsideTextNode: Boolean;

procedure Text_Write(const Buffer; Count: Longint);
var s: string;
begin
  if Count>0 then begin
    SetLength(s,Count);
    System.Move(Buffer,s[1],Count);
    Write(f^, s);
  end;
end;

procedure Text_WriteLn(const Buffer; Count: Longint);
var s: string;
begin
  if Count>0 then begin
    SetLength(s,Count);
    System.Move(Buffer,s[1],Count);
    writeln(f^, s);
  end;
end;

procedure Stream_Write(const Buffer; Count: Longint);
begin
  if Count > 0 then begin
    stream.Write(Buffer, Count);
  end;
end;

procedure Stream_WriteLn(const Buffer; Count: Longint);
begin
  if Count > 0 then begin
    stream.Write(Buffer, Count);
    stream.WriteByte(10);
  end;
end;

procedure wrtStr(const s: string);
begin
  if s<>'' then
    wrt(s[1],length(s));
end;

procedure wrtStrLn(const s: string);
begin
  if s<>'' then
    wrtln(s[1],length(s));
end;

procedure wrtChr(c: char);
begin
  wrt(c,1);
end;

procedure wrtLineEnd;
begin
  wrt(#10,1);
end;

// -------------------------------------------------------------------
//   Indent handling
// -------------------------------------------------------------------

threadvar
  Indent: String;
  IndentCount: integer;

procedure wrtIndent;
var i: integer;
begin
  for i:=1 to IndentCount do
    wrtStr(Indent);
end;

procedure IncIndent;
begin
  inc(IndentCount);
end;

procedure DecIndent;
begin
  if IndentCount>0 then dec(IndentCount);
end;


// -------------------------------------------------------------------
//   String conversion
// -------------------------------------------------------------------

type
  TCharacters = set of Char;
  TSpecialCharCallback = procedure(c: Char);

const
  AttrSpecialChars = ['<', '>', '"', '&'];
  TextSpecialChars = ['<', '>', '&'];


procedure ConvWrite(const s: String; const SpecialChars: TCharacters;
  const SpecialCharCallback: TSpecialCharCallback);
var
  StartPos, EndPos: Integer;
begin
  StartPos := 1;
  EndPos := 1;
  while EndPos <= Length(s) do
  begin
    if s[EndPos] in SpecialChars then
    begin
      wrt(s[StartPos],EndPos - StartPos);
      SpecialCharCallback(s[EndPos]);
      StartPos := EndPos + 1;
    end;
    Inc(EndPos);
  end;
  if StartPos <= length(s) then
    wrt(s[StartPos], EndPos - StartPos);
end;

procedure AttrSpecialCharCallback(c: Char);
const
  QuotStr = '&quot;';
  AmpStr = '&amp;';
begin
  if c = '"' then
    wrtStr(QuotStr)
  else if c = '&' then
    wrtStr(AmpStr)
  else
    wrt(c,1);
end;

procedure TextnodeSpecialCharCallback(c: Char);
const
  ltStr = '&lt;';
  gtStr = '&gt;';
  AmpStr = '&amp;';
begin
  if c = '<' then
    wrtStr(ltStr)
  else if c = '>' then
    wrtStr(gtStr)
  else if c = '&' then
    wrtStr(AmpStr)
  else
    wrt(c,1);
end;


// -------------------------------------------------------------------
//   Node writers implementations
// -------------------------------------------------------------------

procedure WriteElement(node: TDOMNode);
var
  i: Integer;
  attr, child: TDOMNode;
  SavedInsideTextNode: Boolean;
  s: String;
begin
  if not InsideTextNode then
    wrtIndent;
  wrtChr('<');
  wrtStr(node.NodeName);
  for i := 0 to node.Attributes.Length - 1 do
  begin
    attr := node.Attributes.Item[i];
    wrtChr(' ');
    wrtStr(attr.NodeName);
    wrtChr('=');
    s := attr.NodeValue;
    // !!!: Replace special characters in "s" such as '&', '<', '>'
    wrtChr('"');
    ConvWrite(s, AttrSpecialChars, @AttrSpecialCharCallback);
    wrtChr('"');
  end;
  Child := node.FirstChild;
  if Child = nil then begin
    wrtChr('/');
    wrtChr('>');
    if not InsideTextNode then wrtLineEnd;
  end else
  begin
    SavedInsideTextNode := InsideTextNode;
    wrtChr('>');
    if not (InsideTextNode or Child.InheritsFrom(TDOMText)) then
      wrtLineEnd;
    IncIndent;
    repeat
      if Child.InheritsFrom(TDOMText) then
        InsideTextNode := True;
      WriteNode(Child);
      Child := Child.NextSibling;
    until child = nil;
    DecIndent;
    if not InsideTextNode then
      wrtIndent;
    InsideTextNode := SavedInsideTextNode;
    wrtChr('<');
    wrtChr('/');
    wrtStr(node.NodeName);
    wrtChr('>');
    if not InsideTextNode then
      wrtLineEnd;
  end;
end;

procedure WriteAttribute(node: TDOMNode);
begin
  if node=nil then ;
end;

procedure WriteText(node: TDOMNode);
begin
  ConvWrite(node.NodeValue, TextSpecialChars, @TextnodeSpecialCharCallback);
  if node=nil then ;
end;

procedure WriteCDATA(node: TDOMNode);
begin
  if not InsideTextNode then
    wrtStr('<![CDATA[' + node.NodeValue + ']]>')
  else begin
    wrtIndent;
    wrtStrln('<![CDATA[' + node.NodeValue + ']]>')
  end;
end;

procedure WriteEntityRef(node: TDOMNode);
begin
  wrtChr('&');
  wrtStr(node.NodeName);
  wrtChr(';');
end;

procedure WriteEntity(node: TDOMNode);
begin
  if node=nil then ;
end;

procedure WritePI(node: TDOMNode);
begin
  if not InsideTextNode then wrtIndent;
  wrtChr('<'); wrtChr('!');
  wrtStr(TDOMProcessingInstruction(node).Target);
  wrtChr(' ');
  wrtStr(TDOMProcessingInstruction(node).Data);
  wrtChr('>');
  if not InsideTextNode then wrtLineEnd;
end;

procedure WriteComment(node: TDOMNode);
begin
  if not InsideTextNode then wrtIndent;
  wrtStr('<!--');
  wrtStr(node.NodeValue);
  wrtStr('-->');
  if not InsideTextNode then wrtLineEnd;
end;

procedure WriteDocument(node: TDOMNode);
begin
  if node=nil then ;
end;

procedure WriteDocumentType(node: TDOMNode);
begin
  if node=nil then ;
end;

procedure WriteDocumentFragment(node: TDOMNode);
begin
  if node=nil then ;
end;

procedure WriteNotation(node: TDOMNode);
begin
  if node=nil then ;
end;


procedure InitWriter;
begin
  InsideTextNode := False;
  SetLength(Indent, 0);
end;

procedure RootWriter(doc: TXMLDocument);
var
  Child: TDOMNode;
begin
  InitWriter;
  wrtStr('<?xml version="');
  if Length(doc.XMLVersion) > 0 then
    ConvWrite(doc.XMLVersion, AttrSpecialChars, @AttrSpecialCharCallback)
  else
    wrtStr('1.0');
  wrtChr('"');
  if Length(doc.Encoding) > 0 then
  begin
    wrtStr(' encoding="');
    ConvWrite(doc.Encoding, AttrSpecialChars, @AttrSpecialCharCallback);
    wrtStr('"');
  end;
  wrtStrln('?>');

  if Length(doc.StylesheetType) > 0 then
  begin
    wrtStr('<?xml-stylesheet type="');
    ConvWrite(doc.StylesheetType, AttrSpecialChars, @AttrSpecialCharCallback);
    wrtStr('" href="');
    ConvWrite(doc.StylesheetHRef, AttrSpecialChars, @AttrSpecialCharCallback);
    wrtStrln('"?>');
  end;

  Indent := '  ';
  IndentCount := 0;

  child := doc.FirstChild;
  while Assigned(Child) do
  begin
    WriteNode(Child);
    Child := Child.NextSibling;
  end;
end;


procedure WriteXMLMemStream(doc: TXMLDocument);
// internally used by the WriteXMLFile procedures
begin
  Stream:=TMemoryStream.Create;
  WriteXMLFile(doc,Stream);
  Stream.Position:=0;
end;

// -------------------------------------------------------------------
//   Interface implementation
// -------------------------------------------------------------------

{$IFDEF FPC}
  {$IFNDEF VER1_0}
    {$DEFINE UsesFPCWidestrings}
  {$ENDIF}
{$ENDIF}

{$IFDEF UsesFPCWidestrings}

{procedure SimpleWide2AnsiMove(source:pwidechar;dest:pchar;len:sizeint);
var
  i : sizeint;
begin
  for i:=1 to len do
   begin
     if word(source^)<256 then
      dest^:=char(word(source^))
     else
      dest^:='?';
     inc(dest);
     inc(source);
   end;
end;

procedure SimpleAnsi2WideMove(source:pchar;dest:pwidechar;len:sizeint);
var
  i : sizeint;
begin
  for i:=1 to len do
   begin
     dest^:=widechar(byte(source^));
     inc(dest);
     inc(source);
   end;
end;}

{$ENDIF}

procedure WriteXMLFile(doc: TXMLDocument; const AFileName: String);
var
  fs: TFileStream;
begin
  // write first to memory buffer and then as one whole block to file
  WriteXMLMemStream(doc);
  try
    fs := TFileStream.Create(AFileName, fmCreate);
    fs.CopyFrom(Stream,Stream.Size);
    fs.Free;
  finally
    Stream.Free;
  end;
end;

procedure WriteXMLFile(doc: TXMLDocument; var AFile: Text);
{$IFDEF UsesFPCWidestrings}
var
  MyWideStringManager,OldWideStringManager: TWideStringManager;
{$ENDIF}
begin
  {$IFDEF UsesFPCWidestrings}
  GetWideStringManager(MyWideStringManager);

  MyWideStringManager.Wide2AnsiMoveProc:=@defaultWide2AnsiMove;
  MyWideStringManager.Ansi2WideMoveProc:=@defaultAnsi2WideMove;
  SetWideStringManager(MyWideStringManager, OldWideStringManager);
  try
  {$ENDIF}
    f := @AFile;
    wrt := @Text_Write;
    wrtln := @Text_WriteLn;
    RootWriter(doc);
  {$IFDEF UsesFPCWidestrings}
  finally
    SetWideStringManager(OldWideStringManager);
  end;
  {$ENDIF}
end;

procedure WriteXMLFile(doc: TXMLDocument; AStream: TStream);
{$IFDEF UsesFPCWidestrings}
var
  OldWideStringManager: TWideStringManager;
{$ENDIF}
begin
  {$IFDEF UsesFPCWidestrings}
  SetWideStringManager(WideStringManager, OldWideStringManager);
  try
  {$ENDIF}
    Stream := AStream;
    wrt := @Stream_Write;
    wrtln := @Stream_WriteLn;
    RootWriter(doc);
  {$IFDEF UsesFPCWidestrings}
  finally
    SetWideStringManager(OldWideStringManager);
  end;
  {$ENDIF}
end;


procedure WriteXML(Element: TDOMNode; const AFileName: String);
{$IFDEF UsesFPCWidestrings}
var
  OldWideStringManager: TWideStringManager;
{$ENDIF}
begin
  {$IFDEF UsesFPCWidestrings}
  SetWideStringManager(WideStringManager, OldWideStringManager);
  try
  {$ENDIF}
    Stream := TFileStream.Create(AFileName, fmCreate);
    wrt := @Stream_Write;
    wrtln := @Stream_WriteLn;
    InitWriter;
    WriteNode(Element);
    Stream.Free;
  {$IFDEF UsesFPCWidestrings}
  finally
    SetWideStringManager(OldWideStringManager);
  end;
  {$ENDIF}
end;

procedure WriteXML(Element: TDOMNode; var AFile: Text);
{$IFDEF UsesFPCWidestrings}
var
  OldWideStringManager: TWideStringManager;
{$ENDIF}
begin
  {$IFDEF UsesFPCWidestrings}
  SetWideStringManager(WideStringManager, OldWideStringManager);
  try
  {$ENDIF}
    f := @AFile;
    wrt := @Text_Write;
    wrtln := @Text_WriteLn;
    InitWriter;
    WriteNode(Element);
  {$IFDEF UsesFPCWidestrings}
  finally
    SetWideStringManager(OldWideStringManager);
  end;
  {$ENDIF}
end;

procedure WriteXML(Element: TDOMNode; AStream: TStream);
{$IFDEF UsesFPCWidestrings}
var
  OldWideStringManager: TWideStringManager;
{$ENDIF}
begin
  {$IFDEF UsesFPCWidestrings}
  SetWideStringManager(WideStringManager, OldWideStringManager);
  try
  {$ENDIF}
    stream := AStream;
    wrt := @Stream_Write;
    wrtln := @Stream_WriteLn;
    InitWriter;
    WriteNode(Element);
  {$IFDEF UsesFPCWidestrings}
  finally
    SetWideStringManager(OldWideStringManager);
  end;
  {$ENDIF}
end;

end.
{
  $Log: xmlwrite.pp,v $
  Revision 1.19  2005/03/14 21:10:12  florian
    * adapated for the new widestring manager

  Revision 1.18  2005/02/14 17:13:18  peter
    * truncate log

  Revision 1.17  2005/02/01 20:23:39  florian
    * adapted to new widestring manager

  Revision 1.16  2005/01/08 01:32:06  michael
  + Fixed writing of fragments

}
