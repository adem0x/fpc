unit libxml2;

{$mode objfpc}
{$macro on}

{$ALIGN 8}
{$MINENUMSIZE 4}

interface

uses
  ctypes;

{$IFDEF WINDOWS}
  {$DEFINE DYNLINK}
{$ENDIF}

{$IFDEF DYNLINK}
const
{$IF Defined(WINDOWS)}
  libxml2lib = 'libxml2.dll';
{$ELSEIF Defined(UNIX)}
  libxml2lib = 'libxml2.so';
{$ELSE}
  {$MESSAGE ERROR 'DYNLINK not supported'}
{$IFEND}
{$ELSE}
  {$LINKLIB xml2}
{$ENDIF}

{$i xmlexports.inc}
{$i xmlversion.inc}

type
  iconv_t = pointer;
  PFILE = pointer;
  va_list = pointer;
  size_t = {$IF Sizeof(pointer) = 8}qword{$ELSE}longword{$IFEND};

(*
  include pointers (forwarding)
*)
{$DEFINE POINTER}
  {$i catalog.inc}
  {$i chvalid.inc}
  {$i dict.inc}
  {$i encoding.inc}
  {$i tree.inc}
  {$i list.inc}
  {$i entities.inc}
  {$i xmlerror.inc}
  {$i xmlmemory.inc}
  {$i hash.inc}
  {$i pattern.inc}
  {$i schemasInternals.inc}
  {$i valid.inc}
  {$i parser.inc}
  {$i schematron.inc}
  {$i threads.inc}
  {$i uri.inc}
  {$i relaxng.inc}
  {$i globals.inc}
  {$i nanoftp.inc}
  {$i nanohttp.inc}
  {$i SAX.inc}
  {$i SAX2.inc}
  {$i HTMLtree.inc}
  {$i HTMLparser.inc}
  {$i xmlautomata.inc}
  {$i xmlIO.inc}
  {$i xmlmodule.inc}
  {$i xmlreader.inc}
  {$i xmlregexp.inc}
  {$i xmlsave.inc}
  {$i xmlschemas.inc}
  {$i xmlschemastypes.inc}
  {$i xmlstring.inc}
  {$i xmlunicode.inc}
  {$i xmlwriter.inc}
  {$i c14n.inc}
  {$i xpath.inc}
  {$i xlink.inc}
  {$i xinclude.inc}
  {$i xpointer.inc}
{$UNDEF POINTER}

(*
  include types
*)
{$DEFINE TYPE}
  {$i catalog.inc}
  {$i chvalid.inc}
  {$i dict.inc}
  {$i encoding.inc}
  {$i tree.inc}
  {$i list.inc}
  {$i entities.inc}
  {$i xmlerror.inc}
  {$i xmlmemory.inc}
  {$i hash.inc}
  {$i pattern.inc}
  {$i schemasInternals.inc}
  {$i valid.inc}
  {$i parser.inc}
  {$i schematron.inc}
  {$i threads.inc}
  {$i uri.inc}
  {$i relaxng.inc}
  {$i globals.inc}
  {$i nanoftp.inc}
  {$i nanohttp.inc}
  {$i SAX.inc}
  {$i SAX2.inc}
  {$i HTMLtree.inc}
  {$i HTMLparser.inc}
  {$i xmlautomata.inc}
  {$i xmlIO.inc}
  {$i xmlmodule.inc}
  {$i xmlreader.inc}
  {$i xmlregexp.inc}
  {$i xmlsave.inc}
  {$i xmlschemas.inc}
  {$i xmlschemastypes.inc}
  {$i xmlstring.inc}
  {$i xmlunicode.inc}
  {$i xmlwriter.inc}
  {$i c14n.inc}
  {$i xpath.inc}
  {$i xlink.inc}
  {$i xinclude.inc}
  {$i xpointer.inc}
{$UNDEF TYPE}

(*
  include constants
*)
{$DEFINE CONST}
const
  {$i catalog.inc}
  {$i chvalid.inc}
  {$i dict.inc}
  {$i encoding.inc}
  {$i tree.inc}
  {$i list.inc}
  {$i entities.inc}
  {$i xmlerror.inc}
  {$i xmlmemory.inc}
  {$i pattern.inc}
  {$i schemasInternals.inc}
  {$i hash.inc}
  {$i valid.inc}
  {$i parser.inc}
  {$i schematron.inc}
  {$i threads.inc}
  {$i uri.inc}
  {$i relaxng.inc}
  {$i globals.inc}
  {$i nanoftp.inc}
  {$i nanohttp.inc}
  {$i SAX.inc}
  {$i SAX2.inc}
  {$i HTMLtree.inc}
  {$i HTMLparser.inc}
  {$i xmlautomata.inc}
  {$i xmlIO.inc}
  {$i xmlmodule.inc}
  {$i xmlreader.inc}
  {$i xmlregexp.inc}
  {$i xmlsave.inc}
  {$i xmlschemas.inc}
  {$i xmlschemastypes.inc}
  {$i xmlstring.inc}
  {$i xmlunicode.inc}
  {$i xmlwriter.inc}
  {$i c14n.inc}
  {$i xpath.inc}
  {$i xlink.inc}
  {$i xinclude.inc}
  {$i xpointer.inc}
{$UNDEF CONST}

(*
  include functions
*)
{$DEFINE FUNCTION}
  {$i catalog.inc}
  {$i chvalid.inc}
  {$i dict.inc}
  {$i encoding.inc}
  {$i tree.inc}
  {$i list.inc}
  {$i entities.inc}
  {$i xmlerror.inc}
  {$i xmlmemory.inc}
  {$i pattern.inc}
  {$i schemasInternals.inc}
  {$i hash.inc}
  {$i valid.inc}
  {$i parser.inc}
  {$i schematron.inc}
  {$i threads.inc}
  {$i uri.inc}
  {$i relaxng.inc}
  {$i globals.inc}
  {$i nanoftp.inc}
  {$i nanohttp.inc}
  {$i SAX.inc}
  {$i SAX2.inc}
  {$i HTMLtree.inc}
  {$i HTMLparser.inc}
  {$i xmlautomata.inc}
  {$i xmlIO.inc}
  {$i xmlmodule.inc}
  {$i xmlreader.inc}
  {$i xmlregexp.inc}
  {$i xmlsave.inc}
  {$i xmlschemas.inc}
  {$i xmlschemastypes.inc}
  {$i xmlstring.inc}
  {$i xmlunicode.inc}
  {$i xmlwriter.inc}
  {$i c14n.inc}
  {$i xpath.inc}
  {$i xlink.inc}
  {$i xinclude.inc}
  {$i xpointer.inc}
{$UNDEF FUNCTION}

implementation

procedure fpcxmlFree(mem: pointer); XMLCALL;
begin
  FreeMem(mem);
end;

function fpcxmlMalloc(size: size_t): pointer; XMLCALL;
begin
  GetMem(Result, size);
end;

function fpcxmlRealloc(mem: pointer; size: size_t): pointer; XMLCALL;
begin
  Result := mem;
  ReallocMem(Result, size);
end;

procedure fpcxmlGenericErrorHandler(ctx: pointer; msg: pchar; args: array of const); XMLCDECL;
begin
  writeln(msg);
end;

procedure fpcxmlStructuredErrorHandler(userData: pointer; error: xmlErrorPtr); XMLCALL;
begin
  writeln('struct error');
end;


(*
 * macros from chvalid.inc
 *)

function xmlIsBaseChar_ch(c: cint): cbool;
begin
  Result :=
    ((c >= $41) and (c <= $5A)) or
    ((c >= $61) and (c <= $7A)) or
    ((c >= $C0) and (c <= $D6)) or
    ((c >= $D8) and (c <= $F6)) or
     (c >= $F8);
end;

function xmlIsBaseCharQ(c: cint): cbool;
begin
  if c < $100 then
    Result := xmlIsBaseChar_ch(c)
  else
    Result := xmlCharInRange(c, @xmlIsBaseCharGroup);
end;

function xmlIsBlank_ch(c: cint): cbool;
begin
  Result := (c = $20) or ((c >= $9) and (c <= $A)) or (c = $D);
end;

function xmlIsBlankQ(c: cint): cbool;
begin
  if c < $100 then
    Result := xmlIsBaseChar_ch(c)
  else
    Result := false;
end;

function xmlIsChar_ch(c: cint): cbool;
begin
  Result := ((c >= $9) and (c <= $A)) or (c = $D) or (c >= $20);
end;

function xmlIsCharQ(c: cint): cbool;
begin
  if c < $100 then
    Result := xmlIsChar_ch(c)
  else
    Result :=
          ((c >= $000100) and (c <= $00D7FF)) or
          ((c >= $00E000) and (c <= $00FFFD)) or
          ((c >= $010000) and (c <= $10FFFF));
end;

function xmlIsCombiningQ(c: cint): cbool;
begin
    if c < $100 then
    Result := false
  else
    Result := xmlCharInRange(c, @xmlIsCombiningGroup);
end;

function xmlIsDigit_ch(c: cint): cbool;
begin
  Result := (c >= $30) and (c <= $39);
end;

function xmlIsDigitQ(c: cint): cbool;
begin
  if c < $100 then
    Result := xmlIsDigit_ch(c)
  else
    Result := xmlCharInRange(c, @xmlIsDigitGroup);
end;

function xmlIsExtender_ch(c: cint): cbool;
begin
  Result := c = $B7;
end;

function xmlIsExtenderQ(c: cint): cbool;
begin
  if c < $100 then
    Result := xmlIsExtender_ch(c)
  else
    Result := xmlCharInRange(c, @xmlIsExtenderGroup);
end;

function xmlIsIdeographicQ(c: cint): cbool;
begin
  if c < $100 then
    Result := false
  else
    Result :=
      ((c >= $4E00) and (c <= $9FA5)) or
       (c  = $3007) or
      ((c >= $3021) and (c <= $3029));
end;

function xmlIsPubidChar_ch(c: cint): cbool;
begin
  if (c >= 0) and (c <= 255) then
    Result := xmlIsPubidChar_tab[c]
  else
    Result := false;
end;

function xmlIsPubidCharQ(c: cint): cbool;
begin
  if c < $100 then
    Result := xmlIsPubidChar_ch(c)
  else
    Result := false;
end;


(*
 * macros from globals.inc
 *)


(*
 * macros from xpath.inc
 *)

function xmlXPathNodeSetGetLength(ns: xmlNodeSetPtr): cint;
begin
  if assigned(ns) then
    Result := ns^.nodeNr
  else
    Result := 0;
end;

function xmlXPathNodeSetItem(ns: xmlNodeSetPtr; index: cint): xmlNodePtr;
begin
  if assigned(ns) and (index >= 0) and (index < ns^.nodeNr) then
    Result := ns^.nodeTab[index]
  else
    Result := nil;
end;

function xmlXPathNodeSetIsEmpty(ns: xmlNodeSetPtr): boolean;
begin
  Result := not assigned(ns) or (ns^.nodeNr = 0) or (ns^.nodeTab = nil);
end;

initialization
(*
 * this initialize the library and check potential ABI mismatches
 * between the version it was compiled for and the actual shared
 * library used.
 *)
  LIBXML_TEST_VERSION;

(*
 * overloading the memory functions
 *)
  xmlMemSetup(@fpcxmlFree, @fpcxmlMalloc, @fpcxmlRealloc, nil);

(*
 * overloading the error functions
 *)
  xmlSetGenericErrorFunc(nil, @fpcxmlGenericErrorHandler);
  xmlSetStructuredErrorFunc(nil, @fpcxmlStructuredErrorHandler);

finalization
(*
 * Cleanup function for the XML library.
 *)
  xmlCleanupParser();

(*
 * this is to debug memory for regression tests
 *)
  xmlMemoryDump();

end.
