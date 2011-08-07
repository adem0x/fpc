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

{
    History:

    Added functions and procedures with array of const.
    For use with fpc 1.0.7. Thay are in systemvartags.
    11 Nov 2002.


    Added the define use_amiga_smartlink.
    13 Jan 2003.

    Update for AmigaOS 3.9.
    Added a few overlays.
    06 Feb 2003.

    nils.sjoholm@mailbox.swipnet.se
}


unit utility;

{$mode objfpc}

INTERFACE
uses exec;


Type
      pClockData = ^tClockData;
      tClockData = record
        sec   : Word;
        min   : Word;
        hour  : Word;
        mday  : Word;
        month : Word;
        year  : Word;
        wday  : Word;
      END;

      pHook = ^tHook;
      tHook = record
        h_MinNode  : tMinNode;
        h_Entry    : Pointer;   { assembler entry point        }
        h_SubEntry : Pointer;   { often HLL entry point        }
        h_Data     : Pointer;   { owner specific               }
      END;

{
 * Hook calling conventions:
 *      A0 - pointer to hook data structure itself
 *      A1 - pointer to parameter structure ("message") typically
 *           beginning with a longword command code, which makes
 *           sense in the context in which the hook is being used.
 *      A2 - Hook specific address data ("object," e.g, GadgetInfo)
 *
 * Control will be passed to the routine h_Entry.  For many
 * High-Level Languages (HLL), this will be an assembly language
 * stub which pushes registers on the stack, does other setup,
 * and then calls the function at h_SubEntry.
 *
 * The C standard receiving code is:
 * CDispatcher( hook, object, message )
 *     struct Hook      *hook;
 *     APTR             object;
 *     APTR             message;
 *
 * NOTE that register natural order differs from this convention
 * for C parameter order, which is A0,A2,A1.
 *
 * The assembly language stub for "vanilla" C parameter conventions
 * could be:

 _hookEntry:
        move.l  a1,-(sp)                ; push message packet pointer
        move.l  a2,-(sp)                ; push object pointer
        move.l  a0,-(sp)                ; push hook pointer
        move.l  h_SubEntry(a0),a0       ; fetch C entry point ...
        jsr     (a0)                    ; ... and call it
        lea     12(sp),sp               ; fix stack
        rts

 * with this function as your interface stub, you can write
 * a Hook setup function as:

 SetupHook( hook, c_function, userdata )
 struct Hook    *hook;
 ULONG          (*c_function)();
 VOID           *userdata;

        ULONG   (*hookEntry)();

        hook->h_Entry =         hookEntry;
        hook->h_SubEntry =      c_function;
        hook->h_Data =                  userdata;


 * with Lattice C pragmas, you can put the C function in the
 * h_Entry field directly if you declare the function:

ULONG __saveds __asm
CDispatcher(    register __a0 struct Hook       *hook,
                register __a2 VOID              *object,
                register __a1 ULONG             *message );
 *
 ***}

 {      Namespace definitions      }


Type
{ The named object structure }
 pNamedObject = ^tNamedObject;
 tNamedObject = record
    no_Object  : Pointer;       { Your pointer, for whatever you want }
 END;

const
{ Tags for AllocNamedObject() }
 ANO_NameSpace  = 4000;    { Tag to define namespace      }
 ANO_UserSpace  = 4001;    { tag to define userspace      }
 ANO_Priority   = 4002;    { tag to define priority       }
 ANO_Flags      = 4003;    { tag to define flags          }

{ Flags for tag ANO_Flags }
 NSB_NODUPS     = 0;
 NSB_CASE       = 1;

 NSF_NODUPS     = 1;      { Default allow duplicates }
 NSF_CASE       = 2;      { Default to caseless... }


   {    Control attributes for Pack/UnpackStructureTags() }


{ PackTable definition:
 *
 * The PackTable is a simple array of LONGWORDS that are evaluated by
 * PackStructureTags() and UnpackStructureTags().
 *
 * The table contains compressed information such as the tag offset from
 * the base tag. The tag offset has a limited range so the base tag is
 * defined in the first longword.
 *
 * After the first longword, the fields look as follows:
 *
 *      +--------- 1 = signed, 0 = unsigned (for bits, 1=inverted boolean)
 *      |
 *      |  +------ 00 = Pack/Unpack, 10 = Pack, 01 = Unpack, 11 = special
 *      | / \
 *      | | |  +-- 00 = Byte, 01 = Integer, 10 = Long, 11 = Bit
 *      | | | / \
 *      | | | | | /----- For bit operations: 1 = TAG_EXISTS is TRUE
 *      | | | | | |
 *      | | | | | | /-------------------- Tag offset from base tag value
 *      | | | | | | |                 \
 *      m n n o o p q q q q q q q q q q r r r s s s s s s s s s s s s s
 *                                      \   | |               |
 *      Bit offset (for bit operations) ----/ |               |
 *                                            \                       |
 *      Offset into data structure -----------------------------------/
 *
 * A -1 longword signifies that the next longword will be a new base tag
 *
 * A 0 longword signifies that it is the end of the pack table.
 *
 * What this implies is that there are only 13-bits of address offset
 * and 10 bits for tag offsets from the base tag.  For most uses this
 * should be enough, but when this is not, either multiple pack tables
 * or a pack table with extra base tags would be able to do the trick.
 * The goal here was to make the tables small and yet flexible enough to
 * handle most cases.
 }

const
 PSTB_SIGNED =31;
 PSTB_UNPACK =30;    { Note that these are active low... }
 PSTB_PACK   =29;    { Note that these are active low... }
 PSTB_EXISTS =26;    { Tag exists bit true flag hack...  }

 PSTF_SIGNED = $80000000;
 PSTF_UNPACK = $40000000;
 PSTF_PACK   = $20000000;

 PSTF_EXISTS = $4000000;


{***************************************************************************}


 PKCTRL_PACKUNPACK = $00000000;
 PKCTRL_PACKONLY   = $40000000;
 PKCTRL_UNPACKONLY = $20000000;

 PKCTRL_BYTE       = $80000000;
 PKCTRL_WORD       = $88000000;
 PKCTRL_LONG       = $90000000;

 PKCTRL_UBYTE      = $00000000;
 PKCTRL_UWORD      = $08000000;
 PKCTRL_ULONG      = $10000000;

 PKCTRL_BIT        = $18000000;
 PKCTRL_FLIPBIT    = $98000000;


{***************************************************************************}


{ Macros used by the next batch of macros below. Normally, you don't use
 * this batch directly. Then again, some folks are wierd
 }



{***************************************************************************}


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
 *    ULONG packTable[] =
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


{ ======================================================================= }
{ ==== TagItem ========================================================== }
{ ======================================================================= }
{ This data type may propagate through the system for more general use.
 * In the meantime, it is used as a general mechanism of extensible data
 * arrays for parameter specification and property inquiry (coming soon
 * to a display controller near you).
 *
 * In practice, an array (or chain of arrays) of TagItems is used.
 }
Type
    Tag = LongWord;
    pTag = ^Tag;

    pTagItem = ^tTagItem;
    tTagItem = record
     ti_Tag  : Tag;
     ti_Data : LongWord;
    END;

    ppTagItem = ^pTagItem;

{ ---- system tag values ----------------------------- }
CONST
 TAG_DONE          = 0; { terminates array of TagItems. ti_Data unused }
 TAG_END           = TAG_DONE;
 TAG_IGNORE        = 1; { ignore this item, not END of array           }
 TAG_MORE          = 2; { ti_Data is pointer to another array of TagItems
                         * note that this tag terminates the current array
                         }
 TAG_SKIP          = 3; { skip this AND the next ti_Data items         }

{ differentiates user tags from control tags }
 TAG_USER          = $80000000;    { differentiates user tags from system tags}

{* If the TAG_USER bit is set in a tag number, it tells utility.library that
 * the tag is not a control tag (like TAG_DONE, TAG_IGNORE, TAG_MORE) and is
 * instead an application tag. "USER" means a client of utility.library in
 * general, including system code like Intuition or ASL, it has nothing to do
 * with user code.
 *}


{ Tag filter logic specifiers for use with FilterTagItems() }
 TAGFILTER_AND     = 0;       { exclude everything but filter hits   }
 TAGFILTER_NOT     = 1;       { exclude only filter hits             }

{ Mapping types for use with MapTags() }
 MAP_REMOVE_NOT_FOUND = 0;  { remove tags that aren't in mapList }
 MAP_KEEP_NOT_FOUND   = 1;  { keep tags that aren't in mapList   }



Type
 pUtilityBase = ^tUtilityBase;
 tUtilityBase = record
    ub_LibNode   : tLibrary;
    ub_Language  : Byte;
    ub_Reserved  : Byte;
 END;

function AddNamedObject(nameSpace,obj : pNamedObject) : Boolean;
function AllocateTagItems(num : ULONG) : pTagItem;
function AllocNamedObjectA(const name : STRPTR;const TagList : pTagItem) : pNamedObject;
procedure Amiga2Date(amigatime : ULONG;resultat : pClockData);
procedure ApplyTagChanges(TagList : pTagItem; const ChangeList : pTagItem);
function AttemptRemNamedObject(obj : pNamedObject) : LongInt;
function CallHookPktA(h : pHook;obj, paramPkt : APTR) : ULONG;
function CallHookPkt(h : pHook;obj : Pointer; const tags : Array Of Const) : LongWord;
function CheckDate(const date : pClockData) : ULONG;
function CloneTagItems(const tagList : pTagItem) : pTagItem;
function Date2Amiga(const date : pClockData) : ULONG;
procedure FilterTagChanges(changelist, oldvalues : pTagItem;apply : ULONG);
function FilterTagItems(taglist : pTagItem ;const tagArray : pULONG;logic : ULONG) : ULONG;
function FindNamedObject(nameSpace : pNamedObject;const name : STRPTR;lastobject: pNamedObject) : pNamedObject;
function FindTagItem(TagVal : Tag;const TagList : pTagItem) : pTagItem;
procedure FreeNamedObject(Obj : pNamedObject);
procedure FreeTagItems(TagList : pTagItem);
function GetTagData(tagval : Tag;default : ULONG;const TagList : pTagItem) : ULONG;
function GetUniqueID : ULONG;
procedure MapTags(TagList : pTagItem;const maplist : pTagItem;IncludeMiss : ULONG);
function NamedObjectName(Obj : pNamedObject) : STRPTR;
function NextTagItem(Item : ppTagItem) : pTagItem;
function PackBoolTags(InitialFlags : ULONG;const TagList, boolmap : pTagItem) : ULONG;
function PackStructureTags(packk: APTR;const packTable : pULONG;const TagList : pTagItem) : ULONG;
procedure RefreshTagItemClones(cloneTagItem : pTagItem; const OriginalTagItems : pTagItem);
procedure ReleaseNamedObject(Obj : pNamedObject);
procedure RemNamedObject(Obj : pNamedObject;Msg : pointer);
function SDivMod32( dividend , divisor : LongInt) : LongInt;
function SMult32(Arg1, Arg2 : LongInt) : LongInt;
function SMult64(Arg1, Arg2 : LongInt) : LongInt;
function Stricmp(const Str1: STRPTR;const Str2 : STRPTR) : LongInt;
function Strnicmp(const Str1: STRPTR;const Str2 : STRPTR;len : LongInt) : LongInt;
function TagInArray(t : Tag;const TagArray : pULONG) : Boolean;
function ToLower(c : ULONG) : Char;
function ToUpper(c : ULONG) : Char;
function UDivMod32( dividend , divisor : ULONG) : ULONG;
function UMult32(Arg1, Arg2 : ULONG) : ULONG;
function UMult64(Arg1, Arg2 : ULONG) : ULONG;
function UnpackStructureTags(const pac: APTR;const packTable: pULONG;TagList : pTagItem) : ULONG;


IMPLEMENTATION

uses
  tagsarray,longarray;

function AddNamedObject(nameSpace,obj : pNamedObject) : Boolean;
type
  TLocalCall = function(nameSpace,obj : pNamedObject; LibBase: Pointer): Boolean; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 37));
  AddNamedObject := Call(nameSpace,obj, AOS_UtilityBase);
end;

function AllocateTagItems(num : ULONG) : pTagItem;
type
  TLocalCall = function(num : ULONG; LibBase: Pointer): pTagItem; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 11));
  AllocateTagItems := Call(num, AOS_UtilityBase);
end;

function AllocNamedObjectA(const name : STRPTR;const TagList : pTagItem) : pNamedObject;
type
  TLocalCall = function(const name : STRPTR;const TagList : pTagItem; LibBase: Pointer): pNamedObject; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 38));
  AllocNamedObjectA := Call(name, TagList, AOS_UtilityBase);
end;

procedure Amiga2Date(amigatime : ULONG;resultat : pClockData);
type
  TLocalCall = procedure(amigatime : ULONG;resultat : pClockData; LibBase: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 20));
  Call(amigatime, resultat, AOS_UtilityBase);
end;

procedure ApplyTagChanges(TagList : pTagItem;const ChangeList : pTagItem);
type
  TLocalCall = procedure(TagList : pTagItem;const ChangeList : pTagItem; LibBase: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 31));
  Call(TagList, ChangeList, AOS_UtilityBase);
end;

function AttemptRemNamedObject(obj : pNamedObject) : LongInt;
type
  TLocalCall = function(obj : pNamedObject; LibBase: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 39));
  AttemptRemNamedObject := Call(obj, AOS_UtilityBase);
end;

function CallHookPktA(h : pHook;obj, paramPkt : APTR) : ULONG;
type
  TLocalCall = function(h : pHook;obj, paramPkt : APTR; LibBase: Pointer): ULONG; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 17));
  CallHookPktA := Call(h, obj, paramPkt, AOS_UtilityBase);
end;

function CallHookPkt(h : pHook;obj : Pointer; const tags : Array Of Const) : LongWord;
begin
  CallHookPkt := CallHookPktA(h, obj , readinlongs(tags));
end;

function CheckDate(const date : pClockData) : ULONG;
type
  TLocalCall = function(const date : pClockData; LibBase: Pointer): ULONG; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 22));
  CheckDate := Call(date, AOS_UtilityBase);
end;

function CloneTagItems(const tagList : pTagItem) : pTagItem;
type
  TLocalCall = function(const tagList : pTagItem; LibBase: Pointer): pTagItem; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 12));
  CloneTagItems := Call(tagList, AOS_UtilityBase);
end;

function Date2Amiga(const date : pClockData) : ULONG;
type
  TLocalCall = function(const date : pClockData; LibBase: Pointer): ULONG; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 21));
  Date2Amiga := Call(date, AOS_UtilityBase);
end;

procedure FilterTagChanges(changelist, oldvalues : pTagItem;apply : ULONG);
type
  TLocalCall = procedure(changelist, oldvalues : pTagItem;apply : ULONG; LibBase: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 9));
  Call(changelist, oldvalues, apply, AOS_UtilityBase);
end;

function FilterTagItems(taglist : pTagItem ;const tagArray : pULONG;logic : ULONG) : ULONG;
type
  TLocalCall = function(taglist : pTagItem ;const tagArray : pULONG;logic : ULONG; LibBase: Pointer): ULONG; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 16));
  FilterTagItems := Call(taglist, tagArray, logic, AOS_UtilityBase);
end;

function FindNamedObject(nameSpace : pNamedObject;const name : STRPTR;lastobject: pNamedObject) : pNamedObject;
type
  TLocalCall = function(nameSpace : pNamedObject;const name : STRPTR;lastobject: pNamedObject; LibBase: Pointer): pNamedObject; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 40));
  FindNamedObject := Call(nameSpace, name, lastobject, AOS_UtilityBase);
end;

function FindTagItem(TagVal : Tag;const TagList : pTagItem) : pTagItem;
type
  TLocalCall = function(TagVal : Tag;const TagList : pTagItem; LibBase: Pointer): pTagItem; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 5));
  FindTagItem := Call(TagVal, TagList, AOS_UtilityBase);
end;

procedure FreeNamedObject(Obj : pNamedObject);
type
  TLocalCall = procedure(Obj : pNamedObject; LibBase: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 41));
  Call(Obj, AOS_UtilityBase);
end;

procedure FreeTagItems(TagList : pTagItem);
type
  TLocalCall = procedure(TagList : pTagItem; LibBase: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 13));
  Call(TagList, AOS_UtilityBase);
end;

function GetTagData(tagval : Tag;default : ULONG;const TagList : pTagItem) : ULONG;
type
  TLocalCall = function(tagval : Tag;default : ULONG;const TagList : pTagItem; LibBase: Pointer): ULONG; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 6));
  GetTagData := Call(tagval, default, TagList, AOS_UtilityBase);
end;

function GetUniqueID : ULONG;
type
  TLocalCall = function(LibBase: Pointer): ULONG; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 45));
  GetUniqueID := Call(AOS_UtilityBase);
end;

procedure MapTags(TagList : pTagItem;const maplist : pTagItem;IncludeMiss : ULONG);
type
  TLocalCall = procedure(TagList : pTagItem;const maplist : pTagItem;IncludeMiss : ULONG; LibBase: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 10));
  Call(TagList, maplist, IncludeMiss, AOS_UtilityBase);
end;

function NamedObjectName(Obj : pNamedObject) : STRPTR;
type
  TLocalCall = function(Obj : pNamedObject; LibBase: Pointer): STRPTR; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 42));
  NamedObjectName := Call(Obj, AOS_UtilityBase);
end;

function NextTagItem(Item : ppTagItem) : pTagItem;
type
  TLocalCall = function(Item : ppTagItem; LibBase: Pointer): pTagItem; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 8));
  NextTagItem := Call(Item, AOS_UtilityBase);
end;

function PackBoolTags(InitialFlags : ULONG;const TagList, boolmap : pTagItem) : ULONG;
type
  TLocalCall = function(InitialFlags : ULONG;const TagList, boolmap : pTagItem; LibBase: Pointer): ULONG; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 7));
  PackBoolTags := Call(InitialFlags, TagList, boolmap, AOS_UtilityBase);
end;

function PackStructureTags(packk: APTR;const packTable : pULONG;const TagList : pTagItem) : ULONG;
type
  TLocalCall = function(packk: APTR;const packTable : pULONG;const TagList : pTagItem; LibBase: Pointer): ULONG; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 35));
  PackStructureTags := Call(packk, packTable, TagList, AOS_UtilityBase);
end;

procedure RefreshTagItemClones(cloneTagItem : pTagItem; const OriginalTagItems : pTagItem);
type
  TLocalCall = procedure(cloneTagItem : pTagItem; const OriginalTagItems : pTagItem; LibBase: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 14));
  Call(cloneTagItem, OriginalTagItems, AOS_UtilityBase);
end;

procedure ReleaseNamedObject(Obj : pNamedObject);
type
  TLocalCall = procedure(Obj : pNamedObject; LibBase: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 43));
  Call(Obj, AOS_UtilityBase);
end;

procedure RemNamedObject(Obj : pNamedObject;Msg : pointer);
type
  TLocalCall = procedure(Obj : pNamedObject;Msg : pointer; LibBase: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 44));
  Call(Obj, Msg, AOS_UtilityBase);
end;

function SDivMod32(dividend , divisor : LongInt) : LongInt;
type
  TLocalCall = function(dividend , divisor : LongInt; LibBase: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 25));
  SDivMod32 := Call(dividend , divisor, AOS_UtilityBase);
end;

function SMult32(Arg1, Arg2 : LongInt) : LongInt;
type
  TLocalCall = function(Arg1, Arg2 : LongInt; LibBase: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 23));
  SMult32 := Call(Arg1, Arg2, AOS_UtilityBase);
end;

function SMult64(Arg1, Arg2 : LongInt) : LongInt;
type
  TLocalCall = function(Arg1, Arg2 : LongInt; LibBase: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 33));
  SMult64 := Call(Arg1, Arg2, AOS_UtilityBase);
end;

function Stricmp(const Str1: STRPTR;const Str2 : STRPTR) : LongInt;
type
  TLocalCall = function(const Str1: STRPTR;const Str2 : STRPTR; LibBase: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 27));
  Stricmp := Call(Str1, Str2, AOS_UtilityBase);
end;

function Strnicmp(const Str1: STRPTR;const Str2 : STRPTR;len : LongInt) : LongInt;
type
  TLocalCall = function(const Str1: STRPTR;const Str2 : STRPTR;len : LongInt; LibBase: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 28));
  Strnicmp := Call(Str1, Str2, len, AOS_UtilityBase);
end;

function TagInArray(t : Tag;const TagArray : pULONG) : Boolean;
type
  TLocalCall = function(t : Tag;const TagArray : pULONG; LibBase: Pointer): Boolean; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 15));
  TagInArray := Call(t, TagArray, AOS_UtilityBase);
end;

function ToLower(c : ULONG) : Char;
type
  TLocalCall = function(c : ULONG; LibBase: Pointer): Char; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 30));
  ToLower := Call(c, AOS_UtilityBase);
end;

function ToUpper(c : ULONG) : Char;
type
  TLocalCall = function(c : ULONG; LibBase: Pointer): Char; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 29));
  ToUpper := Call(c, AOS_UtilityBase);
end;

function UDivMod32(dividend , divisor : ULONG) : ULONG;
type
  TLocalCall = function(dividend , divisor : ULONG; LibBase: Pointer): ULONG; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 26));
  UDivMod32 := Call(dividend , divisor, AOS_UtilityBase);
end;

function UMult32(Arg1, Arg2 : ULONG) : ULONG;
type
  TLocalCall = function(Arg1, Arg2 : ULONG; LibBase: Pointer): ULONG; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 24));
  UMult32 := Call(Arg1, Arg2, AOS_UtilityBase);
end;

function UMult64(Arg1, Arg2 : ULONG) : ULONG;
type
  TLocalCall = function(Arg1, Arg2 : ULONG; LibBase: Pointer): ULONG; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 34));
  UMult64 := Call(Arg1, Arg2, AOS_UtilityBase);
end;

function UnpackStructureTags(const pac: APTR;const packTable: pULONG;TagList : pTagItem) : ULONG;
type
  TLocalCall = function(const pac: APTR;const packTable: pULONG;TagList : pTagItem; LibBase: Pointer): ULONG; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(AOS_UtilityBase, 36));
  UnpackStructureTags := Call(pac, packTable, TagList, AOS_UtilityBase);
end;

end.
