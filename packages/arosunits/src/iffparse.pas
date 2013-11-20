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

    Added the defines use_amiga_smartlink and
    use_auto_openlib. Implemented autoopening of
    the library.
    14 Jan 2003.

    Added function Make_ID.
    14 Jan 2003.

    Update for AmigaOS 3.9.
    Changed start code for unit.
    01 Feb 2003.

    Changed cardinal > longword.
    09 Feb 2003.

    nils.sjoholm@mailbox.swipnet.se Nils Sjoholm
}

unit iffparse;

interface

{$mode objfpc}

uses exec, clipboard, utility;


const
    IFFPARSENAME  : PChar = 'iffparse.library';

{
 * Struct associated with an active IFF stream.
 * "iff_Stream" is a value used by the client's read/write/seek functions -
 * it will not be accessed by the library itself and can have any value
 * (could even be a pointer or a BPTR).
 }
Type
       PIFFHandle = ^TIFFHandle;
       TIFFHandle = record
        iff_Stream,
        iff_Flags   : LongWord;
        iff_Depth   : LongInt;      {  Depth of context stack.  }
        {  There are private fields hiding here.  }
       end;

{
 * Bit masks for "iff_Flags" field.
 }
const
 IFFF_READ     =  0;                      { read mode - default }
 IFFF_WRITE    =  1;                      { write mode }
 IFFF_RWBITS   =  (IFFF_READ + IFFF_WRITE);        { read/write bits }
 IFFF_FSEEK    =  2;                 { forward seek only }
 IFFF_RSEEK    =  4;                 { random seek }
 IFFF_RESERVED =  $FFFF0000;             { Don't touch these bits. }

{
 * When the library calls your stream handler, you'll be passed a Pointer
 * to this structure as the "message packet".
 }
type
       PIFFStreamCmd = ^TIFFStreamCmd;
       TIFFStreamCmd = record
        sc_Command    : LongInt;     {  Operation to be performed (IFFCMD_) }
        sc_Buf        : Pointer;     {  Pointer to data buffer              }
        sc_NBytes     : LongInt;     {  Number of bytes to be affected      }
       end;
{
 * A node associated with a context on the iff_Stack.  Each node
 * represents a chunk, the stack representing the current nesting
 * of chunks in the open IFF file.  Each context node has associated
 * local context items in the (private) LocalItems list.  The ID, type,
 * size and scan values describe the chunk associated with this node.
 }
       PContextNode = ^TContextNode;
       TContextNode = record
        cn_Node         : TMinNode;
        cn_ID,
        cn_Type,
        cn_Size,        {  Size of this chunk             }
        cn_Scan  : LongInt;        {  # of bytes read/written so far }
        {  There are private fields hiding here.  }
       end;

{
 * Local context items live in the ContextNode's.  Each class is identified
 * by its lci_Ident code and has a (private) purge vector for when the
 * parent context node is popped.
 }
       PLocalContextItem = ^TLocalContextItem;
       TLocalContextItem = record
        lci_Node        : TMinNode;
        lci_ID,
        lci_Type,
        lci_Ident       : LongWord;
        {  There are private fields hiding here.  }
       end;

{
 * StoredProperty: a local context item containing the data stored
 * from a previously encountered property chunk.
 }
       PStoredProperty = ^TStoredProperty;
       TStoredProperty = record
        sp_Size  : LongInt;
        sp_Data  : Pointer;
       end;

{
 * Collection Item: the actual node in the collection list at which
 * client will look.  The next pointers cross context boundaries so
 * that the complete list is accessable.
 }
       PCollectionItem = ^TCollectionItem;
       TCollectionItem = record
        ci_Next                 : PCollectionItem;
        ci_Size                 : LongInt;
        ci_Data                 : Pointer;
       end;

{
 * Structure returned by OpenClipboard().  You may do CMD_POSTs and such
 * using this structure.  However, once you call OpenIFF(), you may not
 * do any more of your own I/O to the clipboard until you call CloseIFF().
 }
       PClipboardHandle = ^TClipBoardHandle;
       TClipboardHandle = record
        cbh_Req                 : TIOClipReq;
        cbh_CBport,
        cbh_SatisfyPort         : TMsgPort;
       end;

{
 * IFF return codes.  Most functions return either zero for success or
 * one of these codes.  The exceptions are the read/write functions which
 * return positive values for number of bytes or records read or written,
 * or a negative error code.  Some of these codes are not errors per sae,
 * but valid conditions such as EOF or EOC (end of Chunk).
 }
const
 IFFERR_EOF            =  -1 ;    {  Reached logical end of file }
 IFFERR_EOC            =  -2 ;    {  About to leave context      }
 IFFERR_NOSCOPE        =  -3 ;    {  No valid scope for property }
 IFFERR_NOMEM          =  -4 ;    {  Internal memory alloc failed}
 IFFERR_READ           =  -5 ;    {  Stream read error           }
 IFFERR_WRITE          =  -6 ;    {  Stream write error          }
 IFFERR_SEEK           =  -7 ;    {  Stream seek error           }
 IFFERR_MANGLED        =  -8 ;    {  Data in file is corrupt     }
 IFFERR_SYNTAX         =  -9 ;    {  IFF syntax error            }
 IFFERR_NOTIFF         =  -10;    {  Not an IFF file             }
 IFFERR_NOHOOK         =  -11;    {  No call-back hook provided  }
 IFF_RETURN2CLIENT     =  -12;    {  Client handler normal return}

{
 MAKE_ID(a,b,c,d)        \
        ((LongWord) (a)<<24 | (LongWord) (b)<<16 | (LongWord) (c)<<8 | (LongWord) (d))
     }
{
 * Universal IFF identifiers.
 }
 ID_FORM = 1179603533;
 ID_LIST = 1279873876;
 ID_CAT  = 1128354848;
 ID_PROP = 1347571536;
 ID_NULL = 538976288;

{
 * Ident codes for universally recognized local context items.
 }
 IFFLCI_PROP         = 1886547824;
 IFFLCI_COLLECTION   = 1668246636;
 IFFLCI_ENTRYHANDLER = 1701734500;
 IFFLCI_EXITHANDLER  = 1702389860;


{
 * Control modes for ParseIFF() function.
 }
 IFFPARSE_SCAN         =  0;
 IFFPARSE_STEP         =  1;
 IFFPARSE_RAWSTEP      =  2;

{
 * Control modes for StoreLocalItem().
 }
 IFFSLI_ROOT           =  1;      {  Store in default context       }
 IFFSLI_TOP            =  2;      {  Store in current context       }
 IFFSLI_PROP           =  3;      {  Store in topmost FORM OR LIST  }

{
 * "Flag" for writing functions.  If you pass this value in as a size
 * to PushChunk() when writing a file, the parser will figure out the
 * size of the chunk for you.  (Chunk sizes >= 2**31 are forbidden by the
 * IFF specification, so this works.)
 }
 IFFSIZE_UNKNOWN       =  -1;

{
 * Possible call-back command values.  (Using 0 as the value for IFFCMD_INIT
 * was, in retrospect, probably a bad idea.)
 }
 IFFCMD_INIT    = 0;       {  Prepare the stream for a session    }
 IFFCMD_CLEANUP = 1;       {  Terminate stream session            }
 IFFCMD_READ    = 2;       {  Read bytes from stream              }
 IFFCMD_WRITE   = 3;       {  Write bytes to stream               }
 IFFCMD_SEEK    = 4;       {  Seek on stream                      }
 IFFCMD_ENTRY   = 5;       {  You just entered a new context      }
 IFFCMD_EXIT    = 6;       {  You're about to leave a context     }
 IFFCMD_PURGELCI= 7;       {  Purge a LocalContextItem            }

{  Backward compatibility.  Don't use these in new code.  }
 IFFSCC_INIT    = IFFCMD_INIT;
 IFFSCC_CLEANUP = IFFCMD_CLEANUP;
 IFFSCC_READ    = IFFCMD_READ;
 IFFSCC_WRITE   = IFFCMD_WRITE;
 IFFSCC_SEEK    = IFFCMD_SEEK;

var IFFParseBase: PLibrary;

function AllocIFF: PIFFHandle;
function AllocLocalItem(Typ: LongInt; Id: LongInt; Ident: LongInt; DataSize: LongInt): PLocalContextItem;
procedure CloseClipboard(ClipHandle: PClipboardHandle);
procedure CloseIFF(Iff: PIFFHandle);
function CollectionChunk(Iff: PIFFHandle; Typ: LongInt; Id: LongInt): LongInt;
function CollectionChunks(Iff : PIFFHandle;const PropArray: PLongInt; NumPairs: LongInt): LongInt;
function CurrentChunk(const Iff: PIFFHandle): PContextNode;
function EntryHandler(Iff: PIFFHandle; Typ: LongInt; Id: LongInt; Position: LongInt; Handler: PHook; Obj: Pointer): LongInt;
function ExitHandler(Iff: PIFFHandle; Typ: LongInt; Id: LongInt; Position: LongInt; Handler: PHook; Obj: Pointer): LongInt;
function FindCollection(const Iff: PIFFHandle; Typ: LongInt; Id: LongInt): PCollectionItem;
function FindLocalItem(const Iff: PIFFHandle; Typ: LongInt; Id: LongInt; Ident: LongInt): PLocalContextItem;
function FindProp(const Iff: PIFFHandle; Typ: LongInt; Id: LongInt): PStoredProperty;
function FindPropContext(const Iff: PIFFHandle): PContextNode;
procedure FreeIFF(Iff: PIFFHandle);
procedure FreeLocalItem(LocalItem: PLocalContextItem);
function GoodID(Id: LongInt): LongInt;
function GoodType(Typ: LongInt): LongInt;
function IDtoStr(Id: LongInt; Buf: PChar): PChar;
procedure InitIFF(Iff: PIFFHandle; Flags: LongInt;const StreamHook: PHook);
procedure InitIFFasClip(Iff: PIFFHandle);
procedure InitIFFasDOS(Iff: PIFFHandle);
function LocalItemData(const LocalItem: PLocalContextItem): Pointer;
function OpenClipboard(unitNumber: LongInt): PClipboardHandle;
function OpenIFF(Iff: PIFFHandle; rwMode: LongInt): LongInt;
function ParentChunk(const contextNode: PContextNode): PContextNode;
function ParseIFF(Iff: PIFFHandle; control: LongInt): LongInt;
function PopChunk(Iff: PIFFHandle): LongInt;
function PropChunk(Iff: PIFFHandle; Typ: LongInt; Id: LongInt): LongInt;
function PropChunks(Iff: PIFFHandle;const PropArray: PLongInt; NumPairs: LongInt): LongInt;
function PushChunk(Iff: PIFFHandle; Typ: LongInt; Id: LongInt; size: LongInt): LongInt;
function ReadChunkBytes(Iff: PIFFHandle; Buf: Pointer; numBytes: LongInt): LongInt;
function ReadChunkRecords(Iff: PIFFHandle; Buf: Pointer; bytesPerRecord: LongInt; numRecords: LongInt): LongInt;
procedure SetLocalItemPurge(LocalItem: PLocalContextItem;const purgeHook: PHook);
function StopChunk(Iff: PIFFHandle; Typ: LongInt; Id: LongInt): LongInt;
function StopChunks(Iff: PIFFHandle;const PropArray: PLongInt; NumPairs: LongInt): LongInt;
function StopOnExit(Iff: PIFFHandle; Typ: LongInt; Id: LongInt): LongInt;
procedure StoreItemInContext(Iff: PIFFHandle; LocalItem: PLocalContextItem; contextNode: PContextNode);
function StoreLocalItem(Iff: PIFFHandle; LocalItem: PLocalContextItem; Position: LongInt): LongInt;
function WriteChunkBytes(Iff: PIFFHandle;const Buf: Pointer; NumBytes: LongInt): LongInt;
function WriteChunkRecords(Iff: PIFFHandle;const Buf: Pointer; BytesPerRecord: LongInt; NumRecords: LongInt): LongInt;

function Make_ID(str: String): LongInt;

implementation

function AllocIFF: PIFFHandle;
type
  TLocalCall = function(Base: Pointer): PIFFHandle; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 5));
  Result := Call(IFFParseBase);
end;

function OpenIFF(Iff: PIFFHandle; rwMode: LongInt): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle; rwMode: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 6));
  Result := Call(Iff, rwMode, IFFParseBase);
end;

function ParseIFF(Iff: PIFFHandle; control: LongInt): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle; control: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 7));
  Result := Call(Iff, control, IFFParseBase);
end;

procedure CloseIFF(Iff: PIFFHandle);
type
  TLocalCall = procedure(Iff: PIFFHandle; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 8));
  Call(Iff, IFFParseBase);
end;

procedure FreeIFF(Iff: PIFFHandle);
type
  TLocalCall = procedure(Iff: PIFFHandle; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 9));
  Call(Iff, IFFParseBase);
end;

function ReadChunkBytes(Iff: PIFFHandle; Buf: Pointer; numBytes: LongInt): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle; Buf: Pointer; numBytes: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 10));
  Result := Call(Iff, Buf, NumBytes, IFFParseBase);
end;

function WriteChunkBytes(Iff: PIFFHandle;const Buf: Pointer; numBytes: LongInt): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle;const Buf: Pointer; numBytes: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 11));
  Result := Call(Iff, Buf, NumBytes, IFFParseBase);
end;

function ReadChunkRecords(Iff: PIFFHandle; Buf: Pointer; bytesPerRecord: LongInt; numRecords: LongInt): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle; Buf: Pointer; bytesPerRecord: LongInt; numRecords: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 12));
  Result := Call(Iff, Buf, bytesPerRecord, numRecords, IFFParseBase);
end;

function WriteChunkRecords(Iff: PIFFHandle;const Buf: Pointer; bytesPerRecord: LongInt; numRecords: LongInt): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle;const Buf: Pointer;  bytesPerRecord: LongInt; numRecords: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 13));
  Result := Call(Iff, Buf, bytesPerRecord, numRecords, IFFParseBase);
end;

function PushChunk(Iff: PIFFHandle; Typ: LongInt; Id: LongInt; size: LongInt): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle; Typ: LongInt; Id: LongInt; size: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 14));
  Result := Call(Iff, Typ, Id, Size, IFFParseBase);
end;

function PopChunk(Iff: PIFFHandle): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 15));
  Result := Call(Iff, IFFParseBase);
end;

function EntryHandler(Iff: PIFFHandle; Typ: LongInt; Id: LongInt; Position: LongInt; Handler: PHook; Obj: Pointer): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle; Typ: LongInt; Id: LongInt; Position: LongInt; Handler: PHook; Obj: Pointer; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 17));
  Result := Call(Iff, Typ, Id, Position, Handler, Obj, IFFParseBase);
end;

function ExitHandler(Iff: PIFFHandle; Typ: LongInt; Id: LongInt; Position: LongInt; Handler: PHook; Obj: Pointer): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle; Typ: LongInt; Id: LongInt; Position: LongInt; Handler: PHook; Obj: Pointer; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 18));
  Result := Call(Iff, Typ, Id, Position, Handler, Obj, IFFParseBase);
end;

function PropChunk(Iff: PIFFHandle; Typ: LongInt; Id: LongInt): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle; Typ: LongInt; Id: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 19));
  Result := Call(Iff, Typ, Id, IFFParseBase);
end;

function PropChunks(Iff: PIFFHandle;const  PropArray: PLongInt; NumPairs: LongInt): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle;const  PropArray: PLongInt; NumPairs: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 20));
  Result := Call(Iff,  PropArray, NumPairs, IFFParseBase);
end;

function StopChunk(Iff: PIFFHandle; Typ: LongInt; Id: LongInt): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle; Typ: LongInt; Id: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 21));
  Result := Call(Iff, Typ, Id, IFFParseBase);
end;


function StopChunks(Iff: PIFFHandle; const PropArray: PLongInt; NumPairs: LongInt): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle;const  PropArray: PLongInt; NumPairs: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 22));
  Result := Call(Iff,  PropArray, NumPairs, IFFParseBase);
end;

function CollectionChunk(Iff: PIFFHandle; Typ: LongInt; Id: LongInt): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle; Typ: LongInt; Id: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 23));
  Result := Call(Iff, Typ, Id, IFFParseBase);
end;

function CollectionChunks(Iff: PIFFHandle;const PropArray: PLongInt; NumPairs: LongInt): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle;const  PropArray: PLongInt; NumPairs: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 24));
  Result := Call(Iff,  PropArray, NumPairs, IFFParseBase);
end;

function StopOnExit(Iff: PIFFHandle; Typ: LongInt; Id: LongInt): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle; Typ: LongInt; Id: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 25));
  Result := Call(Iff, Typ, Id, IFFParseBase);
end;

function FindProp(const Iff: PIFFHandle; Typ: LongInt; Id: LongInt): PStoredProperty;
type
  TLocalCall = function(Iff: PIFFHandle; Typ: LongInt; Id: LongInt; Base: Pointer): PStoredProperty; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 26));
  Result := Call(Iff, Typ, Id, IFFParseBase);
end;

function FindCollection(const Iff: PIFFHandle; Typ: LongInt; Id: LongInt): PCollectionItem;
type
  TLocalCall = function(Iff: PIFFHandle; Typ: LongInt; Id: LongInt; Base: Pointer): PCollectionItem; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 27));
  Result := Call(Iff, Typ, Id, IFFParseBase);
end;

function FindPropContext(const Iff: PIFFHandle): PContextNode;
type
  TLocalCall = function(Iff: PIFFHandle; Base: Pointer): PContextNode; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 28));
  Result := Call(Iff, IFFParseBase);
end;

function CurrentChunk(const Iff: PIFFHandle): PContextNode;
type
  TLocalCall = function(Iff: PIFFHandle; Base: Pointer): PContextNode; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 29));
  Result := Call(Iff, IFFParseBase);
end;

function ParentChunk(const contextNode: PContextNode): PContextNode;
type
  TLocalCall = function(const contextNode: PContextNode; Base: Pointer): PContextNode; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 30));
  Result := Call(contextNode, IFFParseBase);
end;

function AllocLocalItem(Typ: LongInt; Id: LongInt; Ident: LongInt; DataSize: LongInt): PLocalContextItem;
type
  TLocalCall = function(Typ: LongInt; Id: LongInt; Ident: LongInt; DataSize: LongInt; Base: Pointer): PLocalContextItem; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 31));
  Result := Call(Typ, Id, Ident, DataSize, IFFParseBase);
end;

function LocalItemData(const LocalItem: PLocalContextItem): Pointer;
type
  TLocalCall = function(const LocalItem: PLocalContextItem; Base: Pointer): Pointer; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 32));
  Result := Call(LocalItem, IFFParseBase);
end;

procedure SetLocalItemPurge(LocalItem: PLocalContextItem;const purgeHook: PHook);
type
  TLocalCall = procedure(LocalItem: PLocalContextItem;const purgeHook: PHook; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 33));
  Call(LocalItem, purgeHook, IFFParseBase);
end;

procedure FreeLocalItem(LocalItem: PLocalContextItem);
type
  TLocalCall = procedure(LocalItem: PLocalContextItem; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 34));
  Call(LocalItem, IFFParseBase);
end;

function FindLocalItem(const Iff: PIFFHandle; Typ: LongInt; Id: LongInt; Ident: LongInt): PLocalContextItem;
type
  TLocalCall = function(const Iff: PIFFHandle; Typ: LongInt; Id: LongInt; Ident: LongInt; Base: Pointer): PLocalContextItem; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 35));
  Result := Call(Iff, Typ, Id, Ident, IFFParseBase);
end;

function StoreLocalItem(Iff: PIFFHandle; LocalItem: PLocalContextItem; Position: LongInt): LongInt;
type
  TLocalCall = function(Iff: PIFFHandle; LocalItem: PLocalContextItem; Position: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 36));
  Result := Call(Iff, LocalItem, Position, IFFParseBase);
end;

procedure StoreItemInContext(Iff: PIFFHandle; LocalItem: PLocalContextItem; contextNode: PContextNode);
type
  TLocalCall = procedure(Iff: PIFFHandle; LocalItem: PLocalContextItem; contextNode: PContextNode; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 37));
  Call(Iff, LocalItem, contextNode, IFFParseBase);
end;

procedure InitIFF(Iff: PIFFHandle; Flags: LongInt;const StreamHook: PHook);
type
  TLocalCall = procedure(Iff: PIFFHandle; Flags: LongInt;const StreamHook: PHook; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 38));
  Call(Iff, Flags, StreamHook, IFFParseBase);
end;

procedure InitIFFasDOS(Iff: PIFFHandle);
type
  TLocalCall = procedure(Iff: PIFFHandle; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 39));
  Call(Iff, IFFParseBase);
end;

procedure InitIFFasClip(Iff: PIFFHandle);
type
  TLocalCall = procedure(Iff: PIFFHandle; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 40));
  Call(Iff, IFFParseBase);
end;

function OpenClipboard(UnitNumber: LongInt): PClipboardHandle;
type
  TLocalCall = function(UnitNumber: LongInt; Base: Pointer): PClipboardHandle; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 41));
  Result := Call(UnitNumber, IFFParseBase);
end;

procedure CloseClipboard(ClipHandle: PClipboardHandle);
type
  TLocalCall = procedure(ClipHandle: PClipboardHandle; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 42));
  Call(ClipHandle, IFFParseBase);
end;

function GoodID(Id: LongInt): LongInt;
type
  TLocalCall = function(Id: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 43));
  Result := Call(id, IFFParseBase);
end;

function GoodType(Typ: LongInt): LongInt;
type
  TLocalCall = function(Typ: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 44));
  Result := Call(Typ, IFFParseBase);
end;

function IDtoStr(Id: LongInt; Buf: PChar): PChar;
type
  TLocalCall = function(Id: LongInt; Buf: PChar; Base: Pointer): PChar; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(IFFParseBase, 45));
  Result := Call(Id, Buf, IFFParseBase);
end;


function Make_ID(str: String): LongInt;
begin
        Make_ID:= (LongInt(Ord(Str[1])) shl 24) or
                  (LongInt(Ord(Str[2])) shl 16 ) or
                  (LongInt(Ord(Str[3])) shl 8 ) or (LongInt(Ord(Str[4])));
end;

initialization
  IFFParseBase := OpenLibrary(IFFPARSENAME, 0);
finalization
  CloseLibrary(IFFParseBase);
end. (* UNIT IFFPARSE *)





