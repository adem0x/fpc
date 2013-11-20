{
    This file is part of the Free Pascal run time library.

    A file in Amiga system run time library.
    Copyright (c) 1998-2003 by Nils Sjoholm
    member of the Amiga RTL development team.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit utility;

{$mode objfpc}{$H+}
{$PACKRECORDS C}

interface

uses
  Exec;

type
  PClockData = ^TClockData;
  TClockData = record
    Sec: Word;
    Min: Word;
    Hour: Word;
    MDay: Word;
    Month: Word;
    Year: Word;
    WDay: Word;
  end;
  
// Use CALLHOOKPKT to call a hook
  PHook = ^THook;
  THookFunctionProc = function(Hook: PHook; Object_: APTR; Message: APTR): IPTR; cdecl;
  
  THook = record
    h_MinNode: TMinNode;
    h_Entry: IPTR;    // Main Entry point THookFunctionProc
    h_SubEntry: IPTR; // Secondary entry point
    h_Data: Pointer;     // owner specific
  end;
  
// The named object structure
  PNamedObject = ^TNamedObject;
  TNamedObject = record
    no_Object: APTR;  // Your pointer, for whatever you want
  END;

const
// Tags for AllocNamedObject()
  ANO_NameSpace  = 4000; // Tag to define namespace
  ANO_UserSpace  = 4001; // tag to define userspace
  ANO_Priority   = 4002; // tag to define priority
  ANO_Flags      = 4003; // tag to define flags (NSF_*)

// Flags for tag ANO_Flags
  NSB_NODUPS     = 0;
  NSF_NODUPS     = 1 shl 0; // Default allow duplicates
  NSB_CASE       = 1;
  NSF_CASE       = 1 shl 1; // Default to caseless...

//   Control attributes for Pack/UnpackStructureTags()
{ PackTable definition:
 
  The PackTable is a simple array of LONGWORDS that are evaluated by
  PackStructureTags() and UnpackStructureTags().
 
  The table contains compressed information such as the tag offset from
  the base tag. The tag offset has a limited range so the base tag is
  defined in the first longword.
 
  After the first longword, the fields look as follows:
 
       +--------- 1 = signed, 0 = unsigned (for bits, 1=inverted boolean)
       |
       |  +------ 00 = Pack/Unpack, 10 = Pack, 01 = Unpack, 11 = special
       | / \
       | | |  +-- 00 = Byte, 01 = Integer, 10 = Long, 11 = Bit
       | | | / \
       | | | | | /----- For bit operations: 1 = TAG_EXISTS is TRUE
       | | | | | |
       | | | | | | /-------------------- Tag offset from base tag value
       | | | | | | |                 \
       m n n o o p q q q q q q q q q q r r r s s s s s s s s s s s s s
                                       \   | |               |
       Bit offset (for bit operations) ----/ |               |
                                             \                       |
       Offset into data structure -----------------------------------/
 
  A -1 longword signifies that the next longword will be a new base tag
 
  A 0 longword signifies that it is the end of the pack table.
 
  What this implies is that there are only 13-bits of address offset
  and 10 bits for tag offsets from the base tag.  For most uses this
  should be enough, but when this is not, either multiple pack tables
  or a pack table with extra base tags would be able to do the trick.
  The goal here was to make the tables small and yet flexible enough to
  handle most cases.}
const
  PSTB_EXISTS = 26;       // Tag exists bit true flag hack...
  PSTF_EXISTS = 1 shl 26;
  PSTB_PACK   = 29;       // Note that these are active low...
  PSTF_PACK   = 1 shl 29;
  PSTB_UNPACK = 30;       // Note that these are active low...
  PSTF_UNPACK = 1 shl 30;  
  PSTB_SIGNED = 31;
  PSTF_SIGNED = 1 shl 31;

  PKCTRL_UBYTE      = $00000000;
  PKCTRL_BYTE       = $80000000;
  PKCTRL_UWORD      = $08000000;
  PKCTRL_WORD       = $88000000;
  PKCTRL_LongWord   = $10000000;
  PKCTRL_LONG       = $90000000;
  PKCTRL_PACKUNPACK = $00000000;
  PKCTRL_UNPACKONLY = $20000000;
  PKCTRL_PACKONLY   = $40000000;
  PKCTRL_BIT        = $18000000;
  PKCTRL_FLIPBIT    = $98000000;

{ Some handy dandy macros to easily create pack tables
 *
 * Use PACK_STARTTABLE() at the start of a pack table. You pass it the
 * base tag value that will be handled in the following chunk of the pack
 * table.
 *
 * PACK_ENDTABLE() is used to mark the end of a pack table.
 *
 * PACK_NEWOFFSET() lets you change the base tag value used for subsequent
 * entries in the table
 *
 * PACK_ENTRY() lets you define an entry in the pack table. You pass it the
 * base tag value, the tag of interest, the type of the structure to use,
 * the field name in the structure to affect and control bits (combinations of
 * the various PKCTRL_XXX bits)
 *
 * PACK_BYTEBIT() lets you define a bit-control entry in the pack table. You
 * pass it the same data as PACK_ENTRY, plus the flag bit pattern this tag
 * affects. This macro should be used when the field being affected is byte
 * sized.
 *
 * PACK_WORDBIT() lets you define a bit-control entry in the pack table. You
 * pass it the same data as PACK_ENTRY, plus the flag bit pattern this tag
 * affects. This macro should be used when the field being affected is Integer
 * sized.
 *
 * PACK_LONGBIT() lets you define a bit-control entry in the pack table. You
 * pass it the same data as PACK_ENTRY, plus the flag bit pattern this tag
 * affects. This macro should be used when the field being affected is longword
 * sized.
 *
 * EXAMPLE:
 *
 *    LongWord packTable[] =
 *    (
 *         PACK_STARTTABLE(GA_Dummy),
 *         PACK_ENTRY(GA_Dummy,GA_Left,Gadget,LeftEdge,PKCTRL_WORD|PKCTRL_PACKUNPACK),
 *         PACK_ENTRY(GA_Dummy,GA_Top,Gadget,TopEdge,PKCTRL_WORD|PKCTRL_PACKUNPACK),
 *         PACK_ENTRY(GA_Dummy,GA_Width,Gadget,Width,PKCTRL_UWORD|PKCTRL_PACKUNPACK),
 *         PACK_ENTRY(GA_Dummy,GA_Height,Gadget,Height,PKCTRL_UWORD|PKCTRL_PACKUNPACK),
 *         PACK_WORDBIT(GA_Dummy,GA_RelVerify,Gadget,Activation,PKCTRL_BIT|PKCTRL_PACKUNPACK,GACT_RELVERIFY)
 *         PACK_ENDTABLE
 *    );
 }

// TagItem, Tag, TAG_USER moved to Exec needed there already for dome definitions


const
// system tag values Tag.ti_Tag
  TAG_DONE   = 0;  // terminates array of TagItems. ti_Data unused
  TAG_END    = TAG_DONE;
  TAG_IGNORE = 1;  // ignore this item, not END of array
  TAG_MORE   = 2;  // ti_Data is pointer to another array of TagItems note that this tag terminates the current array
  TAG_SKIP   = 3;  // skip this AND the next ti_Data items
// What separates user tags from system tags
  // TAG_USER = 1 shl 31; // see exec
  TAG_OS = 16;  // The first tag used by the OS
// Tag-Offsets for the OS
  DOS_TAGBASE       = TAG_OS; // Reserve 16k tags for DOS
  INTUITION_TAGBASE = TAG_OS or $2000; // Reserve 16k tags for Intuition

{ If the TAG_USER bit is set in a tag number, it tells utility.library that
  the tag is not a control tag (like TAG_DONE, TAG_IGNORE, TAG_MORE) and is
  instead an application tag. "USER" means a client of utility.library in
  general, including system code like Intuition or ASL, it has nothing to do
  with user code.}
// Tag filter logic specifiers for use with FilterTagItems()
  TAGFILTER_AND = 0; // exclude everything but filter hits
  TAGFILTER_NOT = 1; // exclude only filter hits

// Mapping types for use with MapTags()
  MAP_REMOVE_NOT_FOUND = 0; // remove tags that aren't in mapList
  MAP_KEEP_NOT_FOUND   = 1; // keep tags that aren't in mapList

  UTILITYNAME	= 'utility.library';

type
  PUtilityBase = ^TUtilityBase;
  TUtilityBase = record
    ub_LibNode: TLibrary;
    ub_Language: Byte;
    ub_Reserved: Byte;
  end;

function AddNamedObject(NameSpace, Object_: PNamedObject): LongBool; // 37
function AllocateTagItems(Num: LongWord): PTagItem; // 11
function AllocNamedObjectA(const Name: STRPTR; TagList: PTagItem): PNamedObject; // 38
procedure Amiga2Date(Seconds: LongWord; Resultat: PClockData); // 20
procedure ApplyTagChanges(List: PTagItem; ChangeList: PTagItem); // 31
function AttemptRemNamedObject(Object_: PNamedObject): LongInt; // 39
function CallHookPkt(Hook: PHook; Object_, ParamPaket: APTR): IPTR; // 17
function CheckDate(Date: PClockData): LongWord; // 22
function CloneTagItems(const TagList: PTagItem): PTagItem; // 12
function Date2Amiga(Date: PClockData): LongWord; // 21
procedure FilterTagChanges(ChangeList: PTagItem; const Oldvalues: PTagItem; Apply: LongBool); // 9
function FilterTagItems(TagList: PTagItem; FilterArray: PTag; Logic: LongWord): LongWord; // 16
function FindNamedObject(NameSpace: PNamedObject; const Name: STRPTR; LastObject: PNamedObject): PNamedObject; // 40
function FindTagItem(TagValue: Tag; const TagList: PTagItem): PTagItem; // 5
procedure FreeNamedObject(Object_: PNamedObject); // 41
procedure FreeTagItems(TagList: PTagItem); // 13
function GetTagData(TagValue: Tag; Default: IPTR; const TagList: PTagItem): IPTR; // 6
function GetUniqueID: LongWord; // 45
procedure MapTags(TagList: PTagItem; const MapList: PTagItem; MapType: LongWord); // 10
function NamedObjectName(Object_: PNamedObject): STRPTR; // 42
function NextTagItem(var Item: PTagItem): PTagItem; // 8
function PackBoolTags(InitialFlags: LongWord; const TagList, BoolMap: PTagItem): IPTR; // 7
function PackStructureTags(Pack: APTR; PackTable: PLongWord; TagList: PTagItem): LongWord; // 35
procedure RefreshTagItemClones(Clone: PTagItem; const Original: PTagItem); // 14
procedure ReleaseNamedObject(Object_: PNamedObject); // 43
procedure RemNamedObject(Object_: PNamedObject; Message: PMessage); // 44
function SDivMod32(Dividend, Divisor: LongInt): Int64; // 25
function SMult32(Arg1, Arg2: LongInt): LongInt; // 23
function SMult64(Arg1, Arg2: LongInt): Int64; // 33
function Stricmp(const Str1: STRPTR; const Str2: STRPTR): LongInt; // 27
function Strnicmp(const Str1: STRPTR; const Str2 : STRPTR; Length_: LongInt): LongInt;
function TagInArray(TagValue: Tag; TagArray: PTag): LongBool; // 15
function ToLower(c: LongWord): Char; // 30
function ToUpper(c: LongWord): Char; // 29
function UDivMod32(Dividend, Divisor: LongWord): LongWord; // 26
function UMult32(Arg1, Arg2: LongWord): LongWord; // 24
function UMult64(Arg1, Arg2: LongWord): QWord; // 34
function UnpackStructureTags(Pack: APTR; PackTable: PLongWord; TagList: PTagItem): LongWord; // 36

// Macros
function CALLHOOKPKT_(Hook: PHook; Object_: APTR; Message: APTR): IPTR; inline;
function TAGLIST(var Args: array of const): PTagItem; // NOT threadsafe! Better use AddTags/GetTagPtr

// VarArgs Versions
function AllocNamedObject(const Name: STRPTR; const Tags: array of const): PNamedObject;
function CallHook(Hook: PHook; Object_: APTR; const Params: array of const): IPTR;

implementation

uses
  tagsarray,longarray;

function AllocNamedObject(const Name: STRPTR; const Tags: array of const): PNamedObject;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  Result := AllocNamedObjectA(Name, GetTagPtr(TagList));
end;
  
function TAGLIST(var Args: array of const): PTagItem;
begin
  Result := ReadInTags(Args);
end;

function CallHook(Hook: PHook; Object_: APTR; const Params: array of const): IPTR;
begin
  CallHook := CallHookPkt(Hook, Object_ , ReadInLongs(Params));
end;

function CALLHOOKPKT_(Hook: PHook; Object_: APTR; Message: APTR): IPTR;
var
  FuncPtr: THookFunctionProc; 
begin
  Result := 0;
  if (Hook = nil) or (Object_ = nil) or (Message = nil) then
    Exit;
  if (Hook^.h_Entry = 0) then
    Exit;
  FuncPtr := THookFunctionProc(Hook^.h_Entry);
  Result := FuncPtr(Hook, Object_, Message);
end;

function AddNamedObject(NameSpace, Object_: PNamedObject): LongBool;
type
  TLocalCall = function(NameSpace, Object_: PNamedObject; LibBase: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 37));
  AddNamedObject := Call(NameSpace, Object_, AOS_UtilityBase);
end;

function AllocateTagItems(Num: LongWord): PTagItem;
type
  TLocalCall = function(Num: LongWord; LibBase: Pointer): PTagItem; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 11));
  AllocateTagItems := Call(Num, AOS_UtilityBase);
end;

function AllocNamedObjectA(const Name: STRPTR; TagList: PTagItem): PNamedObject;
type
  TLocalCall = function(const Name: STRPTR; TagList : PTagItem; LibBase: Pointer): PNamedObject; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 38));
  AllocNamedObjectA := Call(Name, TagList, AOS_UtilityBase);
end;

procedure Amiga2Date(Seconds: LongWord; Resultat: PClockData);
type
  TLocalCall = procedure(Seconds: LongWord; Resultat: PClockData; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 20));
  Call(Seconds, Resultat, AOS_UtilityBase);
end;

procedure ApplyTagChanges(List: PTagItem; ChangeList: PTagItem);
type
  TLocalCall = procedure(List: PTagItem; ChangeList: PTagItem; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 31));
  Call(List, ChangeList, AOS_UtilityBase);
end;

function AttemptRemNamedObject(Object_: PNamedObject): LongInt;
type
  TLocalCall = function(Object_: PNamedObject; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 39));
  AttemptRemNamedObject := Call(Object_, AOS_UtilityBase);
end;

function CallHookPkt(Hook: PHook; Object_, ParamPaket: APTR): IPTR;
type
  TLocalCall = function(Hook: PHook; Object_, ParamPaket: APTR; LibBase: Pointer): IPTR; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 17));
  CallHookPkt := Call(Hook, Object_, ParamPaket, AOS_UtilityBase);
end;

function CheckDate(Date: PClockData): LongWord;
type
  TLocalCall = function(Date: PClockData; LibBase: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 22));
  CheckDate := Call(Date, AOS_UtilityBase);
end;

function CloneTagItems(const TagList: PTagItem): PTagItem;
type
  TLocalCall = function(const TagList: PTagItem; LibBase: Pointer): PTagItem; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 12));
  CloneTagItems := Call(TagList, AOS_UtilityBase);
end;

function Date2Amiga(Date: PClockData): LongWord;
type
  TLocalCall = function(Date: PClockData; LibBase: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 21));
  Date2Amiga := Call(Date, AOS_UtilityBase);
end;

procedure FilterTagChanges(ChangeList: PTagItem; const Oldvalues: PTagItem; Apply: LongBool);
type
  TLocalCall = procedure(ChangeList: PTagItem; const Oldvalues: PTagItem; Apply: LongBool; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 9));
  Call(ChangeList, Oldvalues, Apply, AOS_UtilityBase);
end;

function FilterTagItems(TagList: PTagItem; FilterArray: PTag; Logic: LongWord): LongWord;
type
  TLocalCall = function(TagList: PTagItem; FilterArray: PTag; Logic: LongWord; LibBase: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 16));
  FilterTagItems := Call(TagList, FilterArray, Logic, AOS_UtilityBase);
end;

function FindNamedObject(NameSpace: PNamedObject; const Name: STRPTR; LastObject: PNamedObject): PNamedObject;
type
  TLocalCall = function(NameSpace: PNamedObject; const Name: STRPTR; LastObject: PNamedObject; LibBase: Pointer): PNamedObject; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 40));
  FindNamedObject := Call(NameSpace, Name, LastObject, AOS_UtilityBase);
end;

function FindTagItem(TagValue: Tag; const TagList: PTagItem): PTagItem;
type
  TLocalCall = function(TagValue: Tag; const TagList: PTagItem; LibBase: Pointer): PTagItem; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 5));
  FindTagItem := Call(TagValue, TagList, AOS_UtilityBase);
end;

procedure FreeNamedObject(Object_: PNamedObject);
type
  TLocalCall = procedure(Object_: PNamedObject; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 41));
  Call(Object_, AOS_UtilityBase);
end;

procedure FreeTagItems(TagList: PTagItem);
type
  TLocalCall = procedure(TagList: PTagItem; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 13));
  Call(TagList, AOS_UtilityBase);
end;

function GetTagData(TagValue: Tag; default: LongWord; const TagList: PTagItem): LongWord;
type
  TLocalCall = function(TagValue: Tag; default : LongWord;const TagList : PTagItem; LibBase: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 6));
  GetTagData := Call(TagValue, default, TagList, AOS_UtilityBase);
end;

function GetUniqueID: LongWord;
type
  TLocalCall = function(LibBase: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 45));
  GetUniqueID := Call(AOS_UtilityBase);
end;

procedure MapTags(TagList: PTagItem; const MapList: PTagItem; MapType: LongWord);
type
  TLocalCall = procedure(TagList: PTagItem; const MapList: PTagItem; MapType: LongWord; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 10));
  Call(TagList, MapList, MapType, AOS_UtilityBase);
end;

function NamedObjectName(Object_: PNamedObject): STRPTR;
type
  TLocalCall = function(Object_: PNamedObject; LibBase: Pointer): STRPTR; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 42));
  NamedObjectName := Call(Object_, AOS_UtilityBase);
end;

function NextTagItem(var Item: PTagItem): PTagItem;
type
  TLocalCall = function(var Item: PTagItem; LibBase: Pointer): PTagItem; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 8));
  NextTagItem := Call(Item, AOS_UtilityBase);
end;

function PackBoolTags(InitialFlags: LongWord; const TagList, BoolMap: PTagItem): LongWord;
type
  TLocalCall = function(InitialFlags: LongWord;const TagList, BoolMap: PTagItem; LibBase: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 7));
  PackBoolTags := Call(InitialFlags, TagList, BoolMap, AOS_UtilityBase);
end;

function PackStructureTags(Pack: APTR; PackTable: PLongWord; TagList: PTagItem): LongWord;
type
  TLocalCall = function(Pack: APTR; PackTable: PLongWord; TagList: PTagItem; LibBase: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 35));
  PackStructureTags := Call(Pack, PackTable, TagList, AOS_UtilityBase);
end;

procedure RefreshTagItemClones(Clone: PTagItem; const Original: PTagItem);
type
  TLocalCall = procedure(Clone: PTagItem; const Original: PTagItem; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 14));
  Call(Clone, Original, AOS_UtilityBase);
end;

procedure ReleaseNamedObject(Object_: PNamedObject);
type
  TLocalCall = procedure(Object_: PNamedObject; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 43));
  Call(Object_, AOS_UtilityBase);
end;

procedure RemNamedObject(Object_: PNamedObject; Message: PMessage);
type
  TLocalCall = procedure(Object_: PNamedObject; Message: PMessage; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 44));
  Call(Object_, Message, AOS_UtilityBase);
end;

function SDivMod32(Dividend, Divisor: LongInt): Int64;
type
  TLocalCall = function(Dividend, Divisor : LongInt; LibBase: Pointer): Int64; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 25));
  SDivMod32 := Call(Dividend, Divisor, AOS_UtilityBase);
end;

function SMult32(Arg1, Arg2: LongInt): LongInt;
type
  TLocalCall = function(Arg1, Arg2: LongInt; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 23));
  SMult32 := Call(Arg1, Arg2, AOS_UtilityBase);
end;

function SMult64(Arg1, Arg2: LongInt): Int64;
type
  TLocalCall = function(Arg1, Arg2: LongInt; LibBase: Pointer): Int64; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 33));
  SMult64 := Call(Arg1, Arg2, AOS_UtilityBase);
end;

function Stricmp(const Str1: STRPTR; const Str2 : STRPTR) : LongInt;
type
  TLocalCall = function(const Str1: STRPTR; const Str2 : STRPTR; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 27));
  Stricmp := Call(Str1, Str2, AOS_UtilityBase);
end;

function Strnicmp(const Str1: STRPTR; const Str2: STRPTR; Length_: LongInt): LongInt;
type
  TLocalCall = function(const Str1: STRPTR; const Str2: STRPTR; Length_: LongInt; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 28));
  Strnicmp := Call(Str1, Str2, Length_, AOS_UtilityBase);
end;

function TagInArray(TagValue: Tag; TagArray: PTag): LongBool;
type
  TLocalCall = function(TagValue: Tag; TagArray: PTag; LibBase: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 15));
  TagInArray := Call(TagValue, TagArray, AOS_UtilityBase);
end;

function ToLower(c: LongWord): Char;
type
  TLocalCall = function(c: LongWord; LibBase: Pointer): Char; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 30));
  ToLower := Call(c, AOS_UtilityBase);
end;

function ToUpper(c: LongWord): Char;
type
  TLocalCall = function(c: LongWord; LibBase: Pointer): Char; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 29));
  ToUpper := Call(c, AOS_UtilityBase);
end;

function UDivMod32(Dividend, Divisor: LongWord): LongWord;
type
  TLocalCall = function(Dividend, Divisor: LongWord; LibBase: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 26));
  UDivMod32 := Call(Dividend, Divisor, AOS_UtilityBase);
end;

function UMult32(Arg1, Arg2: LongWord): LongWord;
type
  TLocalCall = function(Arg1, Arg2: LongWord; LibBase: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 24));
  UMult32 := Call(Arg1, Arg2, AOS_UtilityBase);
end;

function UMult64(Arg1, Arg2: LongWord): QWord;
type
  TLocalCall = function(Arg1, Arg2: LongWord; LibBase: Pointer): QWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 34));
  UMult64 := Call(Arg1, Arg2, AOS_UtilityBase);
end;

function UnpackStructureTags(Pack: APTR; PackTable: PLongWord; TagList: PTagItem): LongWord;
type
  TLocalCall = function(Pack: APTR; PackTable: PLongWord; TagList: PTagItem; LibBase: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 36));
  UnpackStructureTags := Call(Pack, PackTable, TagList, AOS_UtilityBase);
end;

end.
