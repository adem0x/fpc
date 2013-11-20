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
{ Missing:
   - LA_* -> WA_ in Clip.h
   - renderfunc.h // private function defines
   - HIDDT_* hidd unit
}

unit agraphics;

{$mode delphi}{$H+}

Interface

uses
  Exec, Hardware, Utility;

{$PACKRECORDS C}
const
  BITSET = $8000;
  BITCLR = 0;
    
type
  TPlanePtr = PByte;
  
  PPoint = ^TPoint;
  TPoint = record
    x, y: SmallInt;
  end;
  
  PBitMap = ^TBitMap;
  TBitMap = record
    BytesPerRow: Word;
    Rows: Word;
    Flags: Byte;
    Depth: Byte;
    Pad: Word;
    Planes: array[0..7] of TPlanePtr;
  end;
  
  PRectangle = ^TRectangle;
  TRectangle = record
    MinX,
    MinY: SmallInt;
    MaxX,
    MaxY: SmallInt;
  end;
   
  PRect32 = ^TRect32;
  TRect32 = record
    MinX,
    MinY: Longint;
    MaxX,
    MaxY: Longint;
  end;
  
type
// a structure to contain the 16 collision procedure addresses }
  PCollTable = ^TCollTable;
  TCollTable = array[0..15] of Pointer;
    
// flags for AllocBitMap, etc.
const
  BMB_CLEAR       = 0;
  BMB_DISPLAYABLE = 1;
  BMB_INTERLEAVED = 2;
  BMB_STANDARD    = 3;
  BMB_MINPLANES   = 4;
  BMB_SPECIALFMT	= 7; // CyberGfx Flag

  BMF_CLEAR       = 1 shl BMB_CLEAR;
  BMF_DISPLAYABLE = 1 shl BMB_DISPLAYABLE;
  BMF_INTERLEAVED = 1 shl BMB_INTERLEAVED;
  BMF_STANDARD    = 1 shl BMB_STANDARD;
  BMF_MINPLANES   = 1 shl BMB_MINPLANES;
  BMF_SPECIALFMT  = 1 shl BMB_SPECIALFMT;

  BMB_PIXFMT_SHIFTUP =  24;

  BMF_REQUESTVMEM = BMF_DISPLAYABLE or BMF_MINPLANES;
// AmigaOS v4 flags
  BMB_HIJACKED    = 7;
  BMF_HIJACKED    = 1 shl 7;
  BMB_RTGTAGS     = 8;
  BMF_RTGTAGS	    = 1 shl 8;
  BMB_RTGCHECK    = 9;
  BMF_RTGCHECK    = 1 shl 9;
  BMB_FRIENDISTAG = 10;
  BMF_FRIENDISTAG = 1 shl 10;
  BMB_INVALID     = 11;
  BMF_INVALID     = 1 shl 11;

  BMF_CHECKVALUE  = BMF_RTGTAGS or BMF_RTGCHECK or BMF_FRIENDISTAG;
  BMF_CHECKMASK   = BMF_HIJACKED or BMF_CHECKVALUE or BMF_INVALID;
  
// tags for AllocBitMap */
  BMATags_Friend              = TAG_USER + 0;
  BMATags_Depth               = TAG_USER + 1;
  BMATags_RGBFormat           = TAG_USER + 2;
  BMATags_Clear               = TAG_USER + 3;
  BMATags_Displayable         = TAG_USER + 4;
  BMATags_Private1            = TAG_USER + 5;
  BMATags_NoMemory            = TAG_USER + 6;
  BMATags_NoSprite            = TAG_USER + 7;
  BMATags_Private2            = TAG_USER + 8;
  BMATags_Private3            = TAG_USER + 9;
  BMATags_ModeWidth           = TAG_USER + 10;
  BMATags_ModeHeight          = TAG_USER + 11;
  BMATags_RenderFunc          = TAG_USER + 12;
  BMATags_SaveFunc            = TAG_USER + 13;
  BMATags_UserData            = TAG_USER + 14;
  BMATags_Alignment           = TAG_USER + 15;
  BMATags_ConstantBytesPerRow = TAG_USER + 16;
  BMATags_UserPrivate         = TAG_USER + 17;
  BMATags_Private4            = TAG_USER + 18;
  BMATags_Private5            = TAG_USER + 19;
  BMATags_Private6            = TAG_USER + 20;
  BMATags_Private7            = TAG_USER + 21;
  BMATags_BitmapColors        = TAG_USER + $29;
  BMATags_DisplayID           = TAG_USER + $32;
  BMATags_BitmapInvisible     = TAG_USER + $37;
  BMATags_BitmapColors32      = TAG_USER + $43;
// the following IDs are for GetBitMapAttr() *}
  BMA_HEIGHT = 0;
  BMA_DEPTH  = 4;
  BMA_WIDTH  = 8;
  BMA_FLAGS  = 12;

type
  PRegionRectangle = ^TRegionRectangle;
  TRegionRectangle = record
    Next, Prev: PRegionRectangle;
    Bounds: TRectangle;
  end;

  PRegion = ^TRegion;
  TRegion = record
    Bounds: TRectangle;
    RegionRectangle: PRegionRectangle;
  end;

const

// internal TClipRect flags
  CR_NEEDS_NO_CONCEALED_RASTERS       = 1;
  CR_NEEDS_NO_LAYERBLIT_DAMAGE        = 2;

// defines for code values for getcode
  ISLESSX     = 1 shl 0;
  ISLESSY     = 1 shl 1;
  ISGRTRX     = 1 shl 2;
  ISGRTRY     = 1 shl 3;
   
type
// TextAttr node, matches text attributes in RastPort
  PTextAttr = ^TTextAttr;
  TTextAttr = record
    ta_Name: STRPTR;  // name of the font
    ta_YSize: Word;   // height of the font
    ta_Style: Byte;   // intrinsic font style
    ta_Flags: Byte;   // font preferences and flags
  end;
// like TextAttr + Tags
  PTTextAttr = ^TTTextAttr;
  TTTextAttr = record
    tta_Name: STRPTR;   // name of the font
    tta_YSize: Word;    // height of the font
    tta_Style: Byte;    // intrinsic font style
    tta_Flags: Byte;    // font preferences and flags
    tta_Tags: pTagItem; // TTextAttr specific extension -> extended attributes
  end;

const
// ta_Style/tta_Style
  FS_NORMAL           = 0;       // normal text (no style bits set)
  FSB_UNDERLINED      = 0;       // underlined (under baseline)
  FSF_UNDERLINED      = 1 shl 0; 
  FSB_BOLD            = 1;       // bold face text (ORed w/ shifted)
  FSF_BOLD            = 1 shl 1;
  FSB_ITALIC          = 2;       // italic (slanted 1:2 right)
  FSF_ITALIC          = 1 shl 2;
  FSB_EXTENDED        = 3;       // extended face (wider than normal)
  FSF_EXTENDED        = 1 shl 3;
  FSB_COLORFONT       = 6;       // this uses ColorTextFont structure
  FSF_COLORFONT       = 1 shl 6;
  FSB_TAGGED          = 7;       // the TextAttr is really an TTextAttr
  FSF_TAGGED          = 1 shl 7;
// ta_Flags/tta_Flags
  FPB_ROMFONT         = 0;      // font is in rom
  FPF_ROMFONT         = 1 shl 0;
  FPB_DISKFONT        = 1;      // font is from diskfont.library
  FPF_DISKFONT        = 1 shl 1;
  FPB_REVPATH         = 2;      // designed path is reversed (e.g. left)
  FPF_REVPATH         = 1 shl 2;
  FPB_TALLDOT         = 3;      // designed for hires non-interlaced
  FPF_TALLDOT         = 1 shl 3;
  FPB_WIDEDOT         = 4;      // designed for lores interlaced
  FPF_WIDEDOT         = 1 shl 4;
  FPB_PROPORTIONAL    = 5;      //character sizes can vary from nominal
  FPF_PROPORTIONAL    = 1 shl 5;
  FPB_DESIGNED        = 6;     // size is "designed", not constructed 
  FPF_DESIGNED        = 1 shl 6;
  FPB_REMOVED         = 7;     // the font has been removed
  FPF_REMOVED         = 1 shl 7;
// tta_Tags
  TA_DeviceDPI        =  TAG_USER + 1; // Tag value is Point union: Hi Longint XDPI, Lo Longint YDPI
  
  MAXFONTMATCHWEIGHT  =  32767;   { perfect match from WeighTAMatch }

type
  PTextFont = ^TTextFont;
  TTextFont = record
    tf_Message: TMessage; // reply message for font removal
                          // font name in LN \    used in this
    tf_YSize: Word;       // font height     |    order to best
    tf_Style: Byte;       // font style      |    match a font
    tf_Flags: Byte;       // preferences and flags /    request.
    tf_XSize: Word;       // nominal font width
    tf_Baseline: Word;    // distance from the top of char to baseline
    tf_BoldSmear: Word;   // smear to affect a bold enhancement
    tf_Accessors: Word;   // access count
    tf_LoChar: Byte;      // the first character described here
    tf_HiChar: Byte;      // the last character described here
    tf_CharData: APTR;    // the bit character data
    tf_Modulo: Word;      // the row modulo for the strike font data 
    tf_CharLoc: APTR;     // ptr to location data for the strike font 2 words: bit offset then size
    tf_CharSpace: APTR;   // ptr to words of proportional spacing data 
    tf_CharKern: APTR;    // ptr to words of kerning data   
    //property tf_extension: PMsgPort read tf_Message.mn_ReplyPort write tf_Message.mn_ReplyPort;
  end;

  PTextFontExtension = ^TTextFontExtension;
  TTextFontExtension = record    // this structure is read-only
    tfe_MatchWord: Word;         // a magic cookie for the extension
    tfe_Flags0: Byte;            // (system private flags)
    tfe_Flags1: Byte;            // (system private flags)
    
    tfe_BackPtr: PTextFont;      // validation of compilation
    tfe_OrigReplyPort: PMsgPort; // original value in tf_Extension
    tfe_Tags: PTagItem;          // Text Tags for the font
    
    tfe_OFontPatchS,             // (system private use)
    tfe_OFontPatchK: PWord;      // (system private use)
    // this space is reserved for future expansion
  end;

  PColorFontColors = ^TColorFontColors;
  TColorFontColors = record
    cfc_Reserved,          // *must* be zero
    cfc_Count: Word;       // number of entries in cfc_ColorTable
    cfc_ColorTable: PWord; // 4 bit per component color map packed xRGB
  end;

  PColorTextFont = ^TColorTextFont;
  TColorTextFont = record
    ctf_TF: TTextFont;
     
    ctf_Flags: Word;      // extended flags
    ctf_Depth,            // number of bit planes
    ctf_FgColor,          // color that is remapped to FgPen
    ctf_Low,              // lowest color represented here }
    ctf_High,             // highest color represented here }
    ctf_PlanePick,        // PlanePick ala Images }
    ctf_PlaneOnOff: Byte; // PlaneOnOff ala Images
    
    ctf_ColorFontColors: PColorFontColors; // colors for font
    
    ctf_CharData: array[0..7] of APTR; // pointers to bit planes ala tf_CharData
  end;

  PTextExtent = ^TTextExtent;
  TTextExtent = record
    te_Width,               // same as TextLength
    te_Height: Word;        // same as tf_YSize
    te_Extent: TRectangle;  // relative to CP
  end;

const
// TColorTextFont.ctf_Flags
  CTB_MAPCOLOR  =  0;       // map ctf_FgColor to the rp_FgPen IF it's
  CTF_MAPCOLOR  =  1 shl 0; // is a valid color within ctf_Low..ctf_High
  CT_COLORFONT  =  1 shl 0; // color map contains designer's colors
  CT_GREYFONT   =  1 shl 1; // color map describes even-stepped brightnesses from low to high
  CT_ANTIALIAS  =  1 shl 2; // zero background thru fully saturated char
  CT_COLORMASK  =  $000F;   // mask to get to following color styles

// VSprite flags
  // user-set VSprite flags:
  VSPRITE      = $0001; // set if VSprite, clear if Bob
  SAVEBACK     = $0002; // set if background is to be saved/restored
  OVERLAY      = $0004; // set to mask image of Bob onto background
  MUSTDRAW     = $0008; // set if VSprite absolutely must be drawn
  SUSERFLAGS   = $00FF; // mask of all user-settable VSprite-flags
  // system-set VSprite flags:
  BACKSAVED    = $0100; // this Bob's background has been saved
  BOBUPDATE    = $0200; // temporary flag, useless to outside world
  GELGONE      = $0400; // set if gel is completely clipped (offscreen)
  VSOVERFLOW   = $0800; // VSprite overflow (if MUSTDRAW set we draw!)
// Bob flags
  // these are the user flag bits
  SAVEBOB      = $0001; // set to not erase Bob
  BOBISCOMP    = $0002; // set to identify Bob as AnimComp
  BUSERFLAGS   = $00FF; // mask of all user-settable Bob-flags
  // these are the system flag bits
  BWAITING     = $0100; // set while Bob is waiting on 'after'
  BDRAWN       = $0200; // set when Bob is drawn this DrawG pass
  BOBSAWAY     = $0400; // set to initiate removal of Bob
  BOBNIX       = $0800; // set when Bob is completely removed
  SAVEPRESERVE = $1000; // for back-restore during double-buffer
  OUTSTEP      = $2000; // for double-clearing if double-buffer
// defines for the animation procedures
  ANFRACSIZE   = 6;
  RINGTRIGGER  = $0001;
  ANIMHALF     = $0020;

type
{ UserStuff definitions
  the user can define these to be a single variable or a sub-structure
  if undefined by the user, the system turns these into innocuous variables
  see the manual for a thorough definition of the UserStuff definitions }
  TVUserStuff = SmallInt; // Sprite user stuff
  TBUserStuff = SmallInt; // Bob user stuff
  TAUserStuff = SmallInt; // AnimOb user stuff
  
  PBob = ^TBob;
  PAnimOb = ^TAnimOb;
  PAnimComp = ^TAnimComp;

{ GEL draw list constructed in the order the Bobs are actually drawn, then
  list is copied to clear list
  must be here in VSprite for system boundary detection
  the VSprite positions are defined in (y,x) order to make sorting
  sorting easier, since (y,x) as a long Longint} 
  PVSprite = ^TVSprite;
  TVSprite = record
   // SYSTEM VARIABLES
    NextVSprite: PVSprite; // GEL linked list forward/backward pointers sorted by y,x value
    PrevVSprite: PVSprite;
    DrawPath: PVSprite;    // pointer of overlay drawing
    ClearPath: PVSprite;   // pointer for overlay clearing
    OldY, OldX: SmallInt;  // previous position
   // COMMON VARIABLES
    Flags: SmallInt;       // VSprite flags
   // COMMON VARIABLES
    Y, X: SmallInt;        // screen position
    Height: SmallInt;
    Width: SmallInt;       // number of words per row of image data
    Depth: SmallInt;       // number of planes of data
    MeMask: SmallInt;      // which types can collide with this VSprite
    HitMask: SmallInt;     // which types this VSprite can collide with
    ImageData: PSmallInt;  // pointer to VSprite image
    BorderLine: PSmallInt; // logical OR of all VSprite bits borderLine is the one-dimensional logical OR of all
                           // the VSprite bits, used for fast collision detection of edge
    CollMask: PSmallInt;   // similar to above except this is a matrix
      //pointer to this VSprite's color definitions (not used by Bobs)
    SprColors: PSmallInt;
    VSBob: PBob;           // points home if this VSprite is part of a Bob
    PlanePick: Shortint;   { planePick flag:  set bit selects a plane from image, clear bit selects
                             use of shadow mask for that plane
                             OnOff flag: if using shadow mask to fill plane, this bit (corresponding
                             to bit in planePick) describes whether to fill with 0's or 1's
                             There are two uses for these flags:
                               - if this is the VSprite of a Bob, these flags describe how the Bob
                                 is to be drawn into memory
                               - if this is a simple VSprite and the user intends on setting the
                                 MUSTDRAW flag of the VSprite, these flags must be set too to describe
                                 which color registers the user wants for the image}
    PlaneOnOff: ShortInt;
    VUserExt: TVUserStuff; // user definable:  see note above
  end;

// dBufPacket defines the values needed to be saved across buffer to buffer when in double-buffer mode
  PDBufPacket = ^TDBufPacket;
  TDBufPacket = record
    BufY,
    BufX: SmallInt;       // save other buffers screen coordinates
    BufPath: PVSprite;    // carry the draw path over the gap
    BufBuffer: PSmallInt; // this pointer must be filled in by the user pointer to other buffer's background save buffer
  end;

// blitter-objects
  TBob = record
   // SYSTEM VARIABLES
   // COMMON VARIABLES
    Flags: SmallInt;        // general purpose flags (see definitions below)
   // USER VARIABLES
    SaveBuffer: PSmallInt;  // pointer to the buffer for background save
    ImageShadow: PSmallInt; // used by Bobs for "cookie-cutting" and multi-plane masking
    Before: PBob;           // draw this Bob before Bob pointed to by before , for correct overlay
    After: PBob;            // draw this Bob after Bob pointed to by after, for correct overlay
    BobVSprite: PVSprite;   // this Bob's VSprite definition
    BobComp: PAnimComp;     // pointer to this Bob's AnimComp def
    DBuffer: PDBufPacket;   // pointer to this Bob's dBuf packet
    BUserExt: TBUserStuff;  // Bob user extension
  end;


  TAnimComp = record
   // SYSTEM VARIABLES
   // COMMON VARIABLES
    Flags: SmallInt; // AnimComp flags for system & user
    Timer: SmallInt; // timer defines how long to keep this component active:
                     //  if set non-zero, timer decrements to zero then switches to nextSeq
                     //  if set to zero, AnimComp never switches 
   // USER VARIABLES
    TimeSet: SmallInt;     // initial value for timer when the AnimComp is activated by the system
    NextComp: PAnimComp;   // pointer to next and previous components of animation object
    PrevComp: PAnimComp;
    NextSeq: PAnimComp;    // pointer to component component definition of next image in sequence
    PrevSeq: PAnimComp;
    AnimCRoutine: Pointer; // Pointer of special animation procedure
    YTrans: SmallInt;      // initial y translation (if this is a component) }
    XTrans: SmallInt;      // initial x translation (if this is a component) }
    HeadOb: PAnimOb;
    AnimBob: PBob;
  end;

  TAnimOb = record
   // SYSTEM VARIABLES
    NextOb,
    PrevOb: PAnimOb;
    Clock: Longint;    // number of calls to Animate this AnimOb has endured
    AnOldY,
    AnOldX: SmallInt;  // old y,x coordinates
   // COMMON VARIABLES
    AnY,
    AnX: SmallInt;     // y,x coordinates of the AnimOb
   // USER VARIABLES
    YVel,
    XVel: SmallInt;        // velocities of this object
    YAccel,
    XAccel: SmallInt;      // accelerations of this object
    RingYTrans,
    RingXTrans: SmallInt;  // ring translation values
    AnimORoutine: Pointer; // Pointer of special animation procedure
    HeadComp: PAnimComp;   // pointer to first component
    AUserExt: TAUserStuff; // AnimOb user extension
  end;
   PPAnimOb = ^PAnimOb;

const
  B2NORM   = 0;
  B2SWAP   = 1;
  B2BOBBER = 2;

 
const
  MAXSUPERSAVECLIPRECTS = 20; // Max. number of cliprects that are kept preallocated in the list
    
type
  // predefinitions, for record referencing:    
  PRastPort = ^tRastPort;
  PLayer_Info = ^TLayer_Info;
  PLayer = ^TLayer;

  PClipRect = ^TClipRect;
  TClipRect = record
    Next: PClipRect;     // roms used to find next ClipRect
    Prev: PClipRect;     // ignored by roms, used by windowlib
    Lobs: PLayer;        // ignored by roms, used by windowlib
    BitMap: PBitMap;
    Bounds: TRectangle;  // set up by windowlib, used by roms
    _p1,
    _p2: Pointer;        // system reserved
    reserved: Longint;   // system use
    Flags: Longint;      // only exists in layer allocation
  end;  

  
// Layer Structure  
  TLayer = record
    Front,
    Back: PLayer;         // ignored by roms
    ClipRect: PClipRect;  // read by roms to find first cliprect
    Rp: PRastPort;        // Ignored by roms, I hope
    Bounds: TRectangle;   // ignored by roms
    Parent: PLayer;        // Private!
    Priority: Word;        // system use only
    Flags: Word;           // obscured ?, Virtual BitMap?
    SuperBitMap: PBitMap;
    SuperClipRect: PClipRect; // super bitmap cliprects if VBitMap != 0 else damage cliprect list for refresh
    Window: APTR;             // reserved for user interface use
    Scroll_X,
    Scroll_Y: SmallInt;
    cr,
    cr2,
    crnew: PClipRect;              // used by dedice
    SuperSaveClipRects: PClipRect; // preallocated cr's
    _cliprects: PClipRect;         // system use during refresh
    LayerInfo: PLayer_Info;        // points to head of the list
    Lock: TSignalSemaphore;
    BackFill: PHook;
{$ifdef aros}
    VisibleRegion: PRegion;        // Private!
{$else}
    Reserved1: ULONG; 
{$endif}
    ClipRegion: PRegion;
    SaveClipRects: PRegion;        // used to back out when in trouble
    Width,
    Height: SmallInt;
{$ifdef aros}
    Shape: PRegion;              // Private!
    ShapeRegion: PRegion;        // Private!
    VisibleShape: PRegion;       // Private!
    Nesting: Word;               // Private!
    SuperSaveClipRectCounter: Byte; // Private!
    Visible: Byte;               // Private!
    Reserved2: array[0..1] of Byte;
{$else}
    Reserved2: array[0..17] of Byte;
{$endif}
    { this must stay here }
    DamageList: PRegion;   // list of rectangles to refreshthrough
  end;

  TLayer_Info = record
    Top_Layer: Player;
    check_lp: PLayer;
    Obs: PClipRect;
    FreeClipRects: PClipRect;

    PrivateReserve1: LongInt;
    PrivateReserve2: LongInt;

    Lock: TSignalSemaphore;
    gs_Head: TMinList;

    PrivateReserve3: SmallInt;
    PrivateReserve4: Pointer;

    Flags: Word;               // LIFLG_SUPPORTS_OFFSCREEN_LAYERS
    fatten_count: ShortInt;
    LockLayersCount: ShortInt;
    PrivateReserve5: SmallInt;
    BlankHook: Pointer;
    LayerInfo_extra: Pointer;
  end;

  TChangeLayerShapeMsg = record
    NewShape: PRegion;    // same as passed to ChangeLayerShape()
    ClipRect: PClipRect;
    Shape: PRegion;  
  end;

  TCollectPixelsLayerMsg = record
    xSrc: LongInt;
    ySrc: LongInt;
    Width: LongInt;
    Height: LongInt;
    xDest: LongInt;
    yDest: LongInt;
    Bm: PBitmap;
    Layer: PLayer;
    minterm: ULONG;
  end;

// Msg sent through LA_ShapeHook.
  PShapeHookMsg = ^TShapeHookMsg;  
  TShapeHookMsg = record
    Action: LongInt;
    Layer: PLayer;
    ActualShape: PRegion;
    NewBounds: TRectangle;
    OldBounds: TRectangle;
  end;
  // Hook for getting LA_ShapeHook and getting this Msg
  TShapeHookProc = function(Hook: PHook; Layer: PLayer; Msg: PShapeHookMsg): PRegion; cdecl;

  PAreaInfo = ^TAreaInfo;
  TAreaInfo = record
    VctrTbl: PSmallInt;  // ptr to start of vector table
    VctrPtr: PSmallInt;  // ptr to current vertex
    FlagTbl: PShortInt;  // ptr to start of vector flag table
    FlagPtr: PShortInt;  // ptrs to areafill flags
    Count: SmallInt;     // number of vertices in list
    MaxCount: SmallInt;  // AreaMove/Draw will not allow Count>MaxCount
    FirstX,
    FirstY: SmallInt;    // first point for this polygon
  end;

  PTmpRas = ^TTmpRas;
  TTmpRas = record
    RasPtr: PShortInt;
    Size: Longint;
  end;

  PGelsInfo = ^TGelsInfo;
  TGelsInfo = record
    sprRsrvd: Shortint;      // flag of which sprites to reserve from vsprite system
    Flags: Byte;             // system use
    gelHead,
    gelTail: PVSprite;       // dummy vSprites for list management
    NextLine: PSmallInt;     // pointer to array of 8 WORDS for sprite available lines
    LastColor: ^PSmallInt;   // pointer to array of 8 pointers for color-last-assigned to vSprites 
    CollHandler: PCollTable; // Pointeres of collision routines
    LeftMost,
    RightMost,
    TopMost,
    BottomMost: Smallint;
    FirstBlissObj,
    LastBlissObj: APTR;      // system use only
  end;
    
  TRastPort = record
    Layer: PLayer;        // LayerPtr
    BitMap: PBitMap;      // BitMapPtr
    AreaPtrn: PWord;      // ptr to areafill pattern
    TmpRas: PTmpRas;
    AreaInfo: PAreaInfo;
    GelsInfo: PGelsInfo;
    Mask: Byte;           // write mask for this raster
    FgPen: ShortInt;      // foreground pen for this raster
    BgPen: ShortInt;      // background pen
    AOlPen: ShortInt;     // areafill outline pen
    DrawMode: ShortInt;   // drawing mode for fill, lines, and text
    AreaPtSz: ShortInt;   // 2^n words for areafill pattern
    LinPatCnt: ShortInt;  // current line drawing pattern preshift
    dummy: ShortInt;
    Flags: Word;          // miscellaneous control bits
    LinePtrn: Word;       // 16 bits for textured lines
    cp_x,
    cp_y: SmallInt;       // current pen position
    minterms: array[0..7] of Byte;
    PenWidth: SmallInt;
    PenHeight: SmallInt;
    Font: PTextFont;       // (TextFontPtr) current font Pointer
    AlgoStyle: Byte;       // the algorithmically generated style
    TxFlags: Byte;         // text specific flags
    TxHeight: Word;        // text height
    TxWidth: Word;         // text nominal width
    TxBaseline: Word;      // text baseline
    TxSpacing: SmallInt;   // text spacing (per character)
    RP_User: APTR;
    longreserved: array[0..1] of IPTR;
    wordreserved: array[0..6] of Word; // used to be a node
    reserved: array[0..7] of Byte;     // for future use
  end;

const
// these are the flag bits for RastPort flags
  FRST_DOT    = $01; // draw the first dot of this line ?
  ONE_DOT     = $02; // use one dot mode for drawing lines
  DBUFFER     = $04; // flag set when RastPorts are double-buffered
// drawing modes
  JAM1        = 0; // jam 1 color into raster
  JAM2        = 1; // jam 2 colors into raster
  COMPLEMENT  = 2; // XOR bits into raster
  INVERSVID   = 4; // inverse video for drawing modes
// only used for bobs
  AREAOUTLINE = $08; // used by areafiller
  NOCROSSFILL = $20; // areafills have no crossovers

// Actions for TShapeHookMsg
  SHAPEHOOKACTION_CREATELAYER   = 0;
  SHAPEHOOKACTION_MOVELAYER     = 1;
  SHAPEHOOKACTION_SIZELAYER     = 2;
  SHAPEHOOKACTION_MOVESIZELAYER = 3;

// Tags for scale layer
  LA_SRCX	      = $4000;
  LA_SRCY       = $4001;
  LA_DESTX      = $4002;
  LA_DESTY      = $4003;
  LA_SRCWIDTH   = $4004;
  LA_SRCHEIGHT  = $4005;
  LA_DESTWIDTH  = $4006;
  LA_DESTHEIGHT = $4007;
  
  ROOTPRIORITY     =  0;
  BACKDROPPRIORITY = 10;
  UPFRONTPRIORITY  = 20;

// Layer constants
  NEWLAYERINFO_CALLED  = 1;

  LAYERSIMPLE          = 1 shl 0;
  LAYERSMART           = 1 shl 1;
  LAYERSUPER           = 1 shl 2;
  LAYERUPDATING        = 1 shl 4;
  LAYERBACKDROP        = 1 shl 6;
  LAYERREFRESH         = 1 shl 7;
  LAYER_CLIPRECTS_LOST = 1 shl 8;
  LAYERIREFRESH        = 1 shl 9;
  LAYERIREFRESH2       = 1 shl 10;
  LAYER_ROOT_LAYER     = 1 shl 14;

  LAYERS_BACKFILL: PHook   = nil;
  LAYERS_NOBACKFILL: PHook = PHook(1);

// LayerInfo Flag
  LIFLG_SUPPORTS_OFFSCREEN_LAYERS = 1 shl 8; 	// Same flag as AmigaOS hack PowerWindowsNG 

// Tags for CreateLayerTagList
  LA_Dummy       = TAG_USER + 1234;
  LA_Type        = LA_Dummy + 1; // LAYERSIMPLE, LAYERSMART (default) -or LAYERSUPER
  LA_Priority    = LA_Dummy + 2; // -128 .. 127 or LPRI_NORMAL (default) or LPRI_BACKDROP
  LA_Behind      = LA_Dummy + 3; // LongBool. Default is FALSE
  LA_Invisible   = LA_Dummy + 4; // LongBool. Default is FALSE
  LA_BackFill    = LA_Dummy + 5; // PHook. Default is LAYERS_BACKFILL
  LA_SuperBitMap = LA_Dummy + 6; // PBitMap. Default is nil (none)
  LA_Shape	     = LA_Dummy + 7; // PRegion. Default is nil (rectangular shape)

  LPRI_NORMAL 	 = 0;
  LPRI_BACKDROP	 = -50;  

 
const
// tfe_Flags0 (partial definition)
  TE0B_NOREMFONT = 0;    // disallow RemFont for this font
  TE0F_NOREMFONT = $01;
   
Const
    CleanUp     = $40;
    CleanMe     = CleanUp;

    BltClearWait        = 1;    { Waits for blit to finish }
    BltClearXY          = 2;    { Use Row/Bytes per row method }

        { Useful minterms }

    StraightCopy        = $C0;  { Vanilla copy }
    InvertAndCopy       = $30;  { Invert the source before copy }
    InvertDest          = $50;  { Forget source, invert dest }

const
// These flags are passed (in combination) to CoerceMode() to determine the type of coercion required.
  PRESERVE_COLORS = 1; // Ensure that the mode coerced to can display just as many colours as the ViewPort being coerced.
  AVOID_FLICKER   = 2; // Ensure that the mode coerced to is not interlaced.
  IGNORE_MCOMPAT  = 4; // Coercion should ignore monitor compatibility issues.
  BIDTAG_COERCE   = 1; // Private

const
{ These bit descriptors are used by the GEL collide routines.
  These bits are set in the hitMask and meMask variables of
  a GEL to describe whether or not these types of collisions
  can affect the GEL.  BNDRY_HIT is described further below;
  this bit is permanently assigned as the boundary-hit flag.
  The other bit GEL_HIT is meant only as a default to cover
  any GEL hitting any other; the user may redefine this bit.}
  BORDERHIT = 0;
{ These bit descriptors are used by the GEL boundry hit routines.
  When the user's boundry-hit routine is called (via the argument
  set by a call to SetCollision) the first argument passed to
  the user's routine is the Pointer of the GEL involved in the
  boundry-hit, and the second argument has the appropriate bit(s)
  set to describe which boundry was surpassed}
  TOPHIT    = 1;
  BOTTOMHIT = 2;
  LEFTHIT   = 4;
  RIGHTHIT  = 8;

type
  PExtendedNode = ^TExtendedNode;
  TExtendedNode = record
    xln_Succ,
    xln_Pred: PNode;
    xln_Type: Byte;          // NT_GRAPHICS
    xln_Pri: ShortInt;
    xln_Name: PChar;
    xln_Subsystem: Byte;     // see below 
    xln_Subtype: Byte;       // SS_GRAPHICS
    xln_Library : Longint;
    xln_Init : Pointer;
  end;

const
// for xln_Subtype
  SS_GRAPHICS   =  $02;
// for xln_Subsystem
  VIEW_EXTRA_TYPE       =  1;
  VIEWPORT_EXTRA_TYPE   =  2;
  SPECIAL_MONITOR_TYPE  =  3;
  MONITOR_SPEC_TYPE     =  4;

type
  PAnalogSignalInterval = ^TAnalogSignalInterval;
  TAnalogSignalInterval = record
    asi_Start,
    asi_Stop: Word;
  end;

  PSpecialMonitor = ^TSpecialMonitor;
  TSpecialMonitor = record
    spm_Node: TExtendedNode;
    spm_Flags: Word;          // Reserved, set to 0
    do_monitor,               // Driver call vector - set up a video mode
    reserved1,                // Private do not touch
    reserved2,
    reserved3: Pointer;
    hblank,                   // Signal timings by themselves 
    vblank,
    hsync,
    vsync: TAnalogSignalInterval;
  end;

  PMonitorSpec = ^TMonitorSpec;
  TMonitorSpec = record
    ms_Node: TExtendedNode;
    ms_Flags: Word;  // Flags, see below
    ratioh,
    ratiov: Longint;
    total_rows,              // Total number of scanlines per frame
    total_colorclocks,       // Total number of color clocks per line (in 1/280 ns units)
    DeniseMaxDisplayColumn,
    BeamCon0,                // Value for beamcon0 Amiga(tm) chipset register
    min_row: Word;
    
    ms_Special: PSpecialMonitor; // Synchro signal timings description (optional)
    
    ms_OpenCount: Word;         // Driver open count
    ms_transform,
    ms_translate,
    ms_scale: Pointer;
    ms_xoffset,
    ms_yoffset: Word;
    
    ms_LegalView: TRectangle;  // Allowed range for view positioning (right-bottom position included)
    
    ms_maxoscan,               // maximum legal overscan
    ms_videoscan: Pointer;     // video display overscan
    DeniseMinDisplayColumn: Word;
    DisplayCompatible: ULONG;
    
    DisplayInfoDataBase: TList;
    DisplayInfoDataBaseSemaphore: TSignalSemaphore;
    
    ms_MrgCop,             // Driver call vectors, unused by AROS
    ms_LoadView,
    ms_KillView: Pointer;
  end;

const
// Flags for TMonitorSpec.ms_Flags
  MSB_REQUEST_NTSC      =  0;
  MSB_REQUEST_PAL       =  1;
  MSB_REQUEST_SPECIAL   =  2;
  MSB_REQUEST_A2024     =  3;
  MSB_DOUBLE_SPRITES    =  4;
  MSF_REQUEST_NTSC      =  1 shl MSB_REQUEST_NTSC;
  MSF_REQUEST_PAL       =  1 shl MSB_REQUEST_PAL;
  MSF_REQUEST_SPECIAL   =  1 shl MSB_REQUEST_SPECIAL;
  MSF_REQUEST_A2024     =  1 shl MSB_REQUEST_A2024;
  MSF_DOUBLE_SPRITES    =  1 shl MSB_DOUBLE_SPRITES;

  TO_MONITOR            =  0;
  FROM_MONITOR          =  1;
  
  STANDARD_XOFFSET      =  9;
  STANDARD_YOFFSET      =  0;

{ obsolete, v37 compatible definitions follow }
  REQUEST_NTSC          =  1;
  REQUEST_PAL           =  2;
  REQUEST_SPECIAL       =  4;
  REQUEST_A2024         =  8;

  DEFAULT_MONITOR_NAME: PChar = 'default.monitor';
  NTSC_MONITOR_NAME: PChar    = 'ntsc.monitor';
  PAL_MONITOR_NAME: PChar     = 'pal.monitor';
  VGA_MONITOR_NAME: PChar     = 'vga.monitor';
  
  STANDARD_MONITOR_MASK =  REQUEST_NTSC or REQUEST_PAL;
  
// Some standard/default constants for Amiga(tm) chipset 
  STANDARD_NTSC_ROWS    =   262;
  MIN_NTSC_ROW          =    21;
  STANDARD_PAL_ROWS     =   312;
  MIN_PAL_ROW           =    29;
  STANDARD_NTSC_BEAMCON = $0000;
  STANDARD_PAL_BEAMCON  = $0020;
  SPECIAL_BEAMCON        = VARVBLANK or VARHSYNC or VARVSYNC or VARBEAM or VSYNCTRUE or LOLDIS or CSBLANK;
  STANDARD_DENISE_MIN   =    93;
  STANDARD_DENISE_MAX   =   455;
  STANDARD_COLORCLOCKS  =   226;
  STANDARD_VIEW_X =   $81;
  STANDARD_VIEW_Y =   $2C;
  STANDARD_HBSTRT =   $06;
  STANDARD_HSSTRT =   $0B;
  STANDARD_HSSTOP =   $1C;
  STANDARD_HBSTOP =   $2C;
  STANDARD_VBSTRT = $0122;
  STANDARD_VSSTRT = $02A6;
  STANDARD_VSSTOP = $03AA;
  STANDARD_VBSTOP = $1066;

  VGA_COLORCLOCKS = STANDARD_COLORCLOCKS / 2;
  VGA_TOTAL_ROWS  = STANDARD_NTSC_ROWS * 2;
  VGA_DENISE_MIN  =    59;
  MIN_VGA_ROW     =    29;
  VGA_HBSTRT      =   $08;
  VGA_HSSTRT      =   $0E;
  VGA_HSSTOP      =   $1C;
  VGA_HBSTOP      =   $1E;
  VGA_VBSTRT      = $0000;
  VGA_VSSTRT      = $0153;
  VGA_VSSTOP      = $0235;
  VGA_VBSTOP      = $0CCD;

  BROADCAST_HBSTRT  =   $01;
  BROADCAST_HSSTRT  =   $06;
  BROADCAST_HSSTOP  =   $17;
  BROADCAST_HBSTOP  =   $27;
  BROADCAST_VBSTRT  = $0000;
  BROADCAST_VSSTRT  = $02A6;
  BROADCAST_VSSTOP  = $054C;
  BROADCAST_VBSTOP  = $1C40;
  BROADCAST_BEAMCON = LOLDIS OR CSBLANK;

  RATIO_FIXEDPART   = 4;
  RATIO_UNITY       = 1 shl 4;

type
  PCopList = ^TCopList;
  PViewPort = ^TViewPort;
  PColorMap = ^TColorMap;

// Describes playfield(s) (actually bitmaps)
  PRasInfo = ^TRasInfo;
  TRasInfo = record     // used by callers to and InitDspC()
    Next: PRasInfo;     // Pointer to a next playfield (if there's more than one)
    BitMap: PBitMap;    // Actual data to display
    RxOffset,           // Offset of the playfield relative to ViewPort
    RyOffset: SmallInt; // scroll offsets in this BitMap (So that different playfields may be shifted against each other)
  end;

// structure of cprlist that points to list that hardware actually executes
  PCprList = ^TCprList;
  TCprList = record
    Next: PCprList;
    Start: PWord;       // start of copper list
    MaxCount: SmallInt; // number of long instructions
  end;

  PUCopList = ^TUCopList;
  TUCopList = record
    Next: PUCopList;
    FirstCopList: PCopList; // head node of this copper list
    CopList: PCopList;      // node in use
  end;

  PCopInit = ^TCopInit;
  TCopInit = record
    vsync_hblank: array[0..1] of Word;
    diagstrt: array[0..11] of Word;
    fm0: array[0..1] of Word;
    diwstart: array[0..9] of Word;
    bplcon2: array[0..1] of Word;
    sprfix: array[0..15] of Word;
    sprstrtup: array[0..31] of Word;
    wait14: array[0..1] of Word;
    norm_hblank: array[0..1] of Word;
    jump: array[0..1] of Word;
    wait_forever: array[0..5] of Word;
    sprstop: array[0..7] of Word;
  end;

  PView = ^TView;
  TView = record
    ViewPort: PViewPort;  // ViewPortPtr
    LOFCprList: PCprList; // used for interlaced and noninterlaced
    SHFCprList: PCprList; // only used during interlace
    DyOffset,
    DxOffset: SmallInt;   // for complete View positioning offsets are +- adjustments to standard #s
    Modes: Word;          // such as INTERLACE, GENLOC
  end;

// Additional data for Amiga(tm) chipset. Not used by other hardware.
// these structures are obtained via GfxNew and disposed by GfxFree
  PViewExtra = ^TViewExtra;
  TViewExtra = record
    n: TExtendedNode;      // Common Header
    View: PView;           // View it relates to
    Monitor: PMonitorSpec; // Monitor used for displaying this View
    TopLine: Word;
  end;
    
  // Copper structures
  PCopIns = ^TCopIns;
  TCopIns = record
    OpCode  : smallint; // 0 = move, 1 = wait
    case SmallInt of
    0:(
      NxtList: PCopList;
      );
    1:(
      VWaitPos: SmallInt; // vertical wait position
      DestAddr: SmallInt; // destination Pointer
      );
    2:(
      HWaitPos: SmallInt; // horizontal wait position
      DestData: SmallInt; // data to send
      );  
  end;
    
  TCopList = record
    Next: PCopList;       // next block for this copper list
    _CopList: PCopList;   // system use
    _ViewPort: PViewPort; // system use
    CopIns: PCopIns;      // start of this block
    CopPtr: PCopIns;      // intermediate ptr
    CopLStart: PSmallInt; // mrgcop fills this in for Long Frame
    CopSStart: PSmallInt; // mrgcop fills this in for Longint Frame
    Count: Smallint;      // intermediate counter
    MaxCount: SmallInt;   // max # of copins for this block
    DyOffset: SmallInt;   // offset this copper list vertical waits
    SLRepeat: Word;
    Flags: Word;          // EXACT_LINE or HALF_LINE
  end;
  
// Describes a displayed bitmap (or logical screen). Copperlists are relevant only to Amiga(tm) chipset,
// for other hardware they are NULL. 
  TViewPort = record
    Next: PViewPort;
    ColorMap: PColorMap; // table of colors for this viewport if this is nil, MakeVPort assumes default values
    DspIns: PCopList;    // user by MakeView(), Preliminary partial display copperlist
    SprIns: PCopList;    // used by sprite stuff, Preliminary partial sprite copperlist
    ClrIns: PCopList;    // used by sprite stuff
    UCopIns: PUCopList;  // User copper list
    DWidth,              // Width of currently displayed part in pixels
    DHeight: SmallInt;   // Height of currently displayed part in pixels
    DxOffset,            // Displacement from the (0, 0) of the physical screen to (0, 0) of the raster
    DyOffset: SmallInt;
    Modes: Word;         // The same as in View
    SpritePriorities: Byte; // used by makevp
    reserved: Byte;
    RasInfo: PRasInfo;   // Playfield specification
  end;

// Holds additional information about the ViewPort it is associated with
// this structure is obtained via GfxNew and disposed by GfxFree
  PViewPortExtra = ^TViewPortExtra;
  TViewPortExtra = record
    n: TExtendedNode;
    ViewPort: PViewPort;     // ViewPort it relates to (backward link)
    DisplayClip: TRectangle; // makevp display clipping information, Total size of displayable part
    VecTable: APTR;          // Unused in AROS
    DriverData: array[0..1] of APTR; // Private storage for display drivers. Do not touch! 
    Flags: Word;             // Flags, see below
    Origin: array[0..1] of TPoint; // First visible point relative to the DClip. One for each possible playfield.
    cop1ptr,                 // private
    cop2ptr: ULONG;          // private
  end;
  
  PPaletteExtra = ^TPaletteExtra;
  TPaletteExtra = record             // structure may be extended so watch out!
    pe_Semaphore: TSignalSemaphore;  // shared semaphore for arbitration
    pe_FirstFree,                    // *private*
    pe_NFree,                        // number of free colors
    pe_FirstShared,                  // *private*
    pe_NShared: Word;                // *private*
    pe_RefCnt: PByte;                // *private*
    pe_AllocList: PByte;             // *private*
    pe_ViewPort: PViewPort;          // back pointer to viewport
    pe_SharableColors: Word;         // the number of sharable colors.
  end;

{ This structure is the primary storage for palette data.
  Color data itself is stored in two tables: ColorTable and LowColorBits.
  These fields are actually pointer to arrays of Words. Each Word corresponds
  to one color.
  Number of Words in these array is equal to Count value in this structure.
  ColorTable stores upper nibbles of RGB values, LowColorBits stores low nibbles.
  Example:
   color number 4, value: $00ABCDEF
   ColorTable[4] := $0ACE,
   LowColorBits[4] := $0BDF
 
  SpriteBase fields keep bank number, not a color number. On m68k Amiga colors are divided into
  banks, 16 per each. So bank number is color number divided by 16. Base color is a number which
  is added to all colors of the sprite in order to look up the actual palette entry.
  AROS may run on different hardware where sprites may have base colors that do not divide by 16.
  In order to cover this bank numbers have a form: ((c and $0F) shl 8 ) or (c shr 4), where c is actual
  color number (i. e. remainder is stored in a high byte of Word).}  
  TColorMap = record
    Flags: Byte;            // see below (CMF_*)
    Type_: Byte;            // Colormap type (reflects version), see below (COLORMAP_*)
    Count: Word;            // Number of palette entries
    ColorTable: PWord;      // Table of high nibbles of color values (see description above)
      // The following fields are present only if Type_ >= COLORMAP_TYPE_V36
    cm_vpe: PViewPortExtra; // ViewPortExtra, for faster access
    
    LowColorBits: PWord;    // Table of low nibbles of color values (see above) 
    TransparencyPlane,
    SpriteResolution,       // see below
    SpriteResDefault,
    AuxFlags: Byte;
    
    cm_vp: PViewPort;       // Points back to a ViewPort this colormap belongs to
    
    NormalDisplayInfo,
    CoerceDisplayInfo : APTR;
    
    cm_batch_items: PTagItem;
    VPModeID: ULONG;
      // The following fields are present only if Type_ >= COLORMAP_TYPE_V39
    PalExtra: PPaletteExtra; // Structure controlling palette sharing
    
    SpriteBase_Even,         // Color bank for even sprites (see above)
    SpriteBase_Odd,          // The same for odd sprites
    Bp_0_base,
    Bp_1_base: Word;
  end;

const
// flags for TColorMap.Flags
  CMF_CMTRANS             = 0;
  COLORMAP_TRANSPARENCY   = 1 shl 0; 
  CMF_CPTRANS             = 1;
  COLORPLANE_TRANSPARENCY = 1 shl 1;
  CMF_BRDRBLNK            = 2;
  BORDER_BLANKING         = 1 shl 2;
  CMF_BRDNTRAN            = 3;
  BORDER_NOTRANSPARENCY   = 1 shl 3;
  VIDEOCONTROL_BATCH      = 1 shl 4;
  USER_COPPER_CLIP        = 1 shl 5;
  CMF_BRDRSPRT            = 6;
  BORDERSPRITES           = 1 shl 6;
// Types for TColorMap.Type_
  COLORMAP_TYPE_V1_2      = 0;
  COLORMAP_TYPE_V36       = 1;
  COLORMAP_TYPE_V39       = 2;
// SpriteResolution  
  SPRITERESN_ECS          = $00; 
  SPRITERESN_140NS        = $01; // ^140ns, except in 35ns viewport, where it is 70ns.
  SPRITERESN_70NS         = $02;
  SPRITERESN_35NS         = $03;
  SPRITERESN_DEFAULT      = $ff;
  
// Private Flags for TCopList.Flags
  EXACT_LINE = 1;
  HALF_LINE  = 2;
// Copper commands
  COPPER_MOVE = 0;     // pseude opcode for move #XXXX,dir
  COPPER_WAIT = 1;     // pseudo opcode for wait y,x
  CPRNXTBUF   = 2;     // continue processing with next buffer
  CPR_NT_SYS  = $2000; // copper user instruction only
  CPR_NT_SHT  = $4000; // copper instruction only for long frames
  CPR_NT_LOF  = $8000; // copper instruction only for Longint frames

  GENLOCK_VIDEO   = 1 shl 1;
  LACE            = 1 shl 2;
  DOUBLESCAN      = 1 shl 3;
  SUPERHIRES      = 1 shl 5;
  PFBA            = 1 shl 6;
  EXTRA_HALFBRITE = 1 shl 7;
  GENLOCK_AUDIO   = 1 shl 8;
  DUALPF          = 1 shl 10;
  HAM             = 1 shl 11;
  EXTENDED_MODE   = 1 shl 12;
  VP_HIDE         = 1 shl 13;
  SPRITES         = 1 shl 14;
  HIRES           = 1 shl 15;
// ViewPortExtra Flags
  VPXB_FREE_ME      = 0;       // Temporary ViewPortExtra allocated during MakeVPort(). ViewPortExtra with this flag
  VPXF_FREE_ME      = 1 shl 0; // will be automatically found and disposed during FreeVPortCopLists().
                               // Private flag in fact, don't set it by hands
  VPXB_LAST         = 1;
  VPXF_LAST         = 1 shl 1;
  VPXB_STRADDLES256 = 4;
  VPXF_STRADDLES256 = 1 shl 4;
  VPXB_STRADDLES512 = 5;
  VPXF_STRADDLES512 = 1 shl 5;
// Private
  VPB_TENHZ      = 4;
  VPF_TENHZ      = 1 shl 4;
  VPB_A2024      = 6;
  VPF_A2024      = 1 shl 6;

  EXTEND_VSTRUCT = $1000;  // unused bit in Modes field of View

// AuxFlags
  CMAB_FULLPALETTE        = 0;
  CMAF_FULLPALETTE        = 1 shl CMAB_FULLPALETTE;
  CMAB_NO_INTERMED_UPDATE = 1;
  CMAF_NO_INTERMED_UPDATE = 1 shl CMAB_NO_INTERMED_UPDATE;
  CMAB_NO_COLOR_LOAD      = 2;
  CMAF_NO_COLOR_LOAD      = 1 shl CMAB_NO_COLOR_LOAD;
  CMAB_DUALPF_DISABLE     = 3;
  CMAF_DUALPF_DISABLE     = 1 shl CMAB_DUALPF_DISABLE;
  
const
// flags values for ObtainPen
  PENB_EXCLUSIVE   = 0;
  PENB_NO_SETCOLOR = 1;
  PENF_EXCLUSIVE   = 1 shl PENB_EXCLUSIVE;
  PENF_NO_SETCOLOR = 1 shl PENB_NO_SETCOLOR;
// obsolete names for PENF_xxx flags:
  PEN_EXCLUSIVE    = PENF_EXCLUSIVE;
  PEN_NO_SETCOLOR  = PENF_NO_SETCOLOR;
// precision values for ObtainBestPen:
  PRECISION_EXACT  = -1;
  PRECISION_IMAGE  =  0;
  PRECISION_ICON   = 16;
  PRECISION_GUI    = 32;
// tags for ObtainBestPen:
  OBP_Precision    = $84000000;
  OBP_FailIfBad    = $84000001;

{ MakeVPort() will return an error if there is not enough memory,
  or the requested mode cannot be opened with the requested depth with the
  given bitmap (for higher bandwidth alignments).}
  MVP_OK           =  0; // you want to see this one
  MVP_NO_MEM       =  1; // insufficient memory for intermediate workspace
  MVP_NO_VPE       =  2; // ViewPort does not have a ViewPortExtra, and insufficient memory to allocate a temporary one.
  MVP_NO_DSPINS    =  3; // insufficient memory for intermidiate copper instructions.
  MVP_NO_DISPLAY   =  4; // BitMap data is misaligned for this viewport's mode and depth - see AllocBitMap().
  MVP_OFF_BOTTOM   =  5; // PRIVATE - you will never see this.
{ MrgCop() will return an error if there is not enough memory,
  or for some reason MrgCop() did not need to make any copper lists.}
  MCOP_OK         =  0; // you want to see this one
  MCOP_NO_MEM     =  1; // insufficient memory to allocate the system copper lists.
  MCOP_NOP        =  2; // MrgCop() did not merge any copper lists (eg, no ViewPorts in the list, or all marked as hidden).

type
  PDBufInfo = ^TDBufInfo;
  TDBufInfo = record
    dbi_Link1: APTR;
    dbi_Count1: ULONG;
    dbi_SafeMessage: TMessage; // replied to when safe to write to old bitmap
    dbi_UserData1: APTR;       // first user data

    dbi_Link2: APTR;
    dbi_Count2: ULONG;
    dbi_DispMessage: TMessage; // replied to when new bitmap has been displayed at least once
    dbi_UserData2: APTR;       // second user data
    dbi_MatchLong: ULONG;
    dbi_CopPtr1,
    dbi_CopPtr2,
    dbi_CopPtr3: APTR;
    dbi_BeamPos1,
    dbi_BeamPos2: Word;
  end;

const
  INVALID_ID = not 0;

{ With all the new modes that are available under V38 and V39, it is highly
 * recommended that you use either the asl.library screenmode requester,
 * and/or the V39 graphics.library function BestModeIDA().
 *
 * DO NOT interpret the any of the bits in the ModeID for its meaning. For
 * example, do not interpret bit 3 ($4) as meaning the ModeID is interlaced.
 * Instead, use GetDisplayInfoData() with DTAG_DISP, and examine the DIPF_...
 * flags to determine a ModeID's characteristics. The only exception to
 * this rule is that bit 7 ($80) will always mean the ModeID is
 * ExtraHalfBright, and bit 11 ($800) will always mean the ModeID is HAM.
 }

// normal identifiers
   MONITOR_ID_MASK              =   $FFFF1000;

   DEFAULT_MONITOR_ID           =   $00000000;
   NTSC_MONITOR_ID              =   $00011000;
   PAL_MONITOR_ID               =   $00021000;
   
{ the following 22 composite keys are for Modes on the default Monitor.
  NTSC & PAL "flavors" of these particular keys may be made by or'ing
  the NTSC or PAL MONITOR_ID with the desired MODE_KEY...
 
  For example, to specifically open a PAL HAM interlaced ViewPort
  (or intuition screen), you would use the modeid of
  (PAL_MONITOR_ID or HAMLACE_KEY)}
   LORES_KEY                     =  $00000000;
   LORESLACE_KEY                 =  $00000004;
   LORESSDBL_KEY                 =  $00000008;
   EXTRAHALFBRITE_KEY            =  $00000080;
   EXTRAHALFBRITELACE_KEY        =  $00000084;
   LORESEHBSDBL_KEY              =  $00000088;
   LORESDPF_KEY                  =  $00000400;
   LORESLACEDPF_KEY              =  $00000404;
   LORESDPF2_KEY                 =  $00000440;
   LORESLACEDPF2_KEY             =  $00000444;
   HAM_KEY                       =  $00000800;
   HAMLACE_KEY                   =  $00000804;
   LORESHAMSDBL_KEY              =  $00000808;
   HIRES_KEY                     =  $00008000;
   HIRESLACE_KEY                 =  $00008004;
   SUPER_KEY                     =  $00008020;
   SUPERLACE_KEY                 =  $00008024;
   HIRESEHB_KEY                  =  $00008080;
   HIRESEHBLACE_KEY              =  $00008084;   
   SUPEREHB_KEY                  =  $000080a0;
   SUPEREHBLACE_KEY              =  $000080a4;
   HIRESDPF_KEY                  =  $00008400;
   HIRESLACEDPF_KEY              =  $00008404;
   SUPERDPF_KEY                  =  $00008420;
   SUPERLACEDPF_KEY              =  $00008424;
   HIRESDPF2_KEY                 =  $00008440;
   HIRESLACEDPF2_KEY             =  $00008444;
   SUPERDPF2_KEY                 =  $00008460;
   SUPERLACEDPF2_KEY             =  $00008464;
   HIRESHAM_KEY                  =  $00008800;
   HIRESHAMLACE_KEY              =  $00008804;
   HIRESHAMSDBL_KEY              =  $00008808;
   SUPERHAM_KEY                  =  $00008820;
   SUPERHAMLACE_KEY              =  $00008824;
   
// VGA identifiers
   VGA_MONITOR_ID                =  $00031000;

   VGAEXTRALORES_KEY             =  $00031004;
   VGALORES_KEY                  =  $00039004;
   VGAPRODUCT_KEY                =  $00039024;
   VGAHAM_KEY                    =  $00031804;
   VGAEXTRALORESLACE_KEY         =  $00031005;
   VGALORESLACE_KEY              =  $00039005;
   VGAPRODUCTLACE_KEY            =  $00039025;
   VGAHAMLACE_KEY                =  $00031805;
   VGAEXTRALORESDPF_KEY          =  $00031404;
   VGALORESDPF_KEY               =  $00039404;
   VGAPRODUCTDPF_KEY             =  $00039424;
   VGAEXTRALORESLACEDPF_KEY      =  $00031405;
   VGALORESLACEDPF_KEY           =  $00039405;
   VGAPRODUCTLACEDPF_KEY         =  $00039425;
   VGAEXTRALORESDPF2_KEY         =  $00031444;
   VGALORESDPF2_KEY              =  $00039444;
   VGAPRODUCTDPF2_KEY            =  $00039464;
   VGAEXTRALORESLACEDPF2_KEY     =  $00031445;
   VGALORESLACEDPF2_KEY          =  $00039445;
   VGAPRODUCTLACEDPF2_KEY        =  $00039465;
   VGAEXTRAHALFBRITE_KEY         =  $00031084;
   VGAEXTRAHALFBRITELACE_KEY     =  $00031085;
   VGAPRODUCTHAM_KEY             =  $00039824;
   VGALORESHAM_KEY               =  $00039804;
   VGAEXTRALORESHAM_KEY          =  VGAHAM_KEY;
   VGAPRODUCTHAMLACE_KEY         =  $00039825;
   VGALORESHAMLACE_KEY           =  $00039805;
   VGAEXTRALORESHAMLACE_KEY      =  VGAHAMLACE_KEY;
   VGAEXTRALORESEHB_KEY          =  VGAEXTRAHALFBRITE_KEY;
   VGAEXTRALORESEHBLACE_KEY      =  VGAEXTRAHALFBRITELACE_KEY;
   VGALORESEHB_KEY               =  $00039084;
   VGALORESEHBLACE_KEY           =  $00039085;
   VGAEHB_KEY                    =  $000390a4;
   VGAEHBLACE_KEY                =  $000390a5;
   VGAEXTRALORESDBL_KEY          =  $00031000;
   VGALORESDBL_KEY               =  $00039000;
   VGAPRODUCTDBL_KEY             =  $00039020;
   VGAEXTRALORESHAMDBL_KEY       =  $00031800;
   VGALORESHAMDBL_KEY            =  $00039800;
   VGAPRODUCTHAMDBL_KEY          =  $00039820;
   VGAEXTRALORESEHBDBL_KEY       =  $00031080;
   VGALORESEHBDBL_KEY            =  $00039080;
   VGAPRODUCTEHBDBL_KEY          =  $000390a0;
// A2024 identifiers 
   A2024_MONITOR_ID              =  $00041000;
   A2024TENHERTZ_KEY             =  $00041000;
   A2024FIFTEENHERTZ_KEY         =  $00049000;
// prototype identifiers (private)
   PROTO_MONITOR_ID              =  $00051000;
// Euro72 defines
   EURO72_MONITOR_ID             =  $00061000;
   EURO72EXTRALORES_KEY          =  $00061004;
   EURO72LORES_KEY               =  $00069004;
   EURO72PRODUCT_KEY             =  $00069024;
   EURO72HAM_KEY                 =  $00061804;
   EURO72EXTRALORESLACE_KEY      =  $00061005;
   EURO72LORESLACE_KEY           =  $00069005;
   EURO72PRODUCTLACE_KEY         =  $00069025;
   EURO72HAMLACE_KEY             =  $00061805;
   EURO72EXTRALORESDPF_KEY       =  $00061404;
   EURO72LORESDPF_KEY            =  $00069404;
   EURO72PRODUCTDPF_KEY          =  $00069424;
   EURO72EXTRALORESLACEDPF_KEY   =  $00061405;
   EURO72LORESLACEDPF_KEY        =  $00069405;
   EURO72PRODUCTLACEDPF_KEY      =  $00069425;
   EURO72EXTRALORESDPF2_KEY      =  $00061444;
   EURO72LORESDPF2_KEY           =  $00069444;
   EURO72PRODUCTDPF2_KEY         =  $00069464;
   EURO72EXTRALORESLACEDPF2_KEY  =  $00061445;
   EURO72LORESLACEDPF2_KEY       =  $00069445;
   EURO72PRODUCTLACEDPF2_KEY     =  $00069465;
   EURO72EXTRAHALFBRITE_KEY      =  $00061084;
   EURO72EXTRAHALFBRITELACE_KEY  =  $00061085;
   EURO72PRODUCTHAM_KEY          =  $00069824;
   EURO72PRODUCTHAMLACE_KEY      =  $00069825;
   EURO72LORESHAM_KEY            =  $00069804;
   EURO72LORESHAMLACE_KEY        =  $00069805;
   EURO72EXTRALORESHAM_KEY       =  EURO72HAM_KEY;
   EURO72EXTRALORESHAMLACE_KEY   =  EURO72HAMLACE_KEY ;
   EURO72EXTRALORESEHB_KEY       =  EURO72EXTRAHALFBRITE_KEY;
   EURO72EXTRALORESEHBLACE_KEY   =  EURO72EXTRAHALFBRITELACE_KEY;
   EURO72LORESEHB_KEY            =  $00069084;
   EURO72LORESEHBLACE_KEY        =  $00069085;
   EURO72EHB_KEY                 =  $000690a4;
   EURO72EHBLACE_KEY             =  $000690a5;
{ These ModeIDs are the scandoubled equivalents of the above, with the
  exception of the DualPlayfield modes, as AA does not allow for scandoubling
  dualplayfield.}
   EURO72EXTRALORESDBL_KEY       =  $00061000;
   EURO72LORESDBL_KEY            =  $00069000;
   EURO72PRODUCTDBL_KEY          =  $00069020;
   EURO72EXTRALORESHAMDBL_KEY    =  $00061800;
   EURO72LORESHAMDBL_KEY         =  $00069800;
   EURO72PRODUCTHAMDBL_KEY       =  $00069820;
   EURO72EXTRALORESEHBDBL_KEY    =  $00061080;
   EURO72LORESEHBDBL_KEY         =  $00069080;
   EURO72PRODUCTEHBDBL_KEY       =  $000690a0;
// Euro 36
   EURO36_MONITOR_ID             =  $00071000;
{ Euro36 modeids can be ORed with the default modeids a la NTSC and PAL.
  For example, Euro36 SuperHires is
  (EURO36_MONITOR_ID OR SUPER_KEY)}
// Super 72  
   SUPER72_MONITOR_ID            =  $00081000;
{ Super72 modeids can be ORed with the default modeids a la NTSC and PAL.
 For example, Super72 SuperHiresLace (80$600) is
  (SUPER72_MONITOR_ID OR SUPERLACE_KEY).
  The following scandoubled Modes are the exception:}
   SUPER72LORESDBL_KEY           =  $00081008;
   SUPER72HIRESDBL_KEY           =  $00089008;
   SUPER72SUPERDBL_KEY           =  $00089028;
   SUPER72LORESHAMDBL_KEY        =  $00081808;
   SUPER72HIRESHAMDBL_KEY        =  $00089808;
   SUPER72SUPERHAMDBL_KEY        =  $00089828;
   SUPER72LORESEHBDBL_KEY        =  $00081088;
   SUPER72HIRESEHBDBL_KEY        =  $00089088;
   SUPER72SUPEREHBDBL_KEY        =  $000890a8;
// DblNTSC
   DBLNTSC_MONITOR_ID            =  $00091000;

   DBLNTSCLORES_KEY              =  $00091000;
   DBLNTSCLORESFF_KEY            =  $00091004;
   DBLNTSCLORESHAM_KEY           =  $00091800;
   DBLNTSCLORESHAMFF_KEY         =  $00091804;
   DBLNTSCLORESEHB_KEY           =  $00091080;
   DBLNTSCLORESEHBFF_KEY         =  $00091084;
   DBLNTSCLORESLACE_KEY          =  $00091005;
   DBLNTSCLORESHAMLACE_KEY       =  $00091805;
   DBLNTSCLORESEHBLACE_KEY       =  $00091085;
   DBLNTSCLORESDPF_KEY           =  $00091400;
   DBLNTSCLORESDPFFF_KEY         =  $00091404;
   DBLNTSCLORESDPFLACE_KEY       =  $00091405;
   DBLNTSCLORESDPF2_KEY          =  $00091440;
   DBLNTSCLORESDPF2FF_KEY        =  $00091444;
   DBLNTSCLORESDPF2LACE_KEY      =  $00091445;
   DBLNTSCHIRES_KEY              =  $00099000;
   DBLNTSCHIRESFF_KEY            =  $00099004;
   DBLNTSCHIRESHAM_KEY           =  $00099800;
   DBLNTSCHIRESHAMFF_KEY         =  $00099804;
   DBLNTSCHIRESLACE_KEY          =  $00099005;
   DBLNTSCHIRESHAMLACE_KEY       =  $00099805;
   DBLNTSCHIRESEHB_KEY           =  $00099080;
   DBLNTSCHIRESEHBFF_KEY         =  $00099084;
   DBLNTSCHIRESEHBLACE_KEY       =  $00099085;
   DBLNTSCHIRESDPF_KEY           =  $00099400;
   DBLNTSCHIRESDPFFF_KEY         =  $00099404;
   DBLNTSCHIRESDPFLACE_KEY       =  $00099405;
   DBLNTSCHIRESDPF2_KEY          =  $00099440;
   DBLNTSCHIRESDPF2FF_KEY        =  $00099444;
   DBLNTSCHIRESDPF2LACE_KEY      =  $00099445;
   DBLNTSCEXTRALORES_KEY         =  $00091200;
   DBLNTSCEXTRALORESHAM_KEY      =  $00091a00;
   DBLNTSCEXTRALORESEHB_KEY      =  $00091280;
   DBLNTSCEXTRALORESDPF_KEY      =  $00091600;
   DBLNTSCEXTRALORESDPF2_KEY     =  $00091640;
   DBLNTSCEXTRALORESFF_KEY       =  $00091204;
   DBLNTSCEXTRALORESHAMFF_KEY    =  $00091a04;
   DBLNTSCEXTRALORESEHBFF_KEY    =  $00091284;
   DBLNTSCEXTRALORESDPFFF_KEY    =  $00091604;
   DBLNTSCEXTRALORESDPF2FF_KEY   =  $00091644;
   DBLNTSCEXTRALORESLACE_KEY     =  $00091205;
   DBLNTSCEXTRALORESHAMLACE_KEY  =  $00091a05;
   DBLNTSCEXTRALORESEHBLACE_KEY  =  $00091285;
   DBLNTSCEXTRALORESDPFLACE_KEY  =  $00091605;
   DBLNTSCEXTRALORESDPF2LACE_KEY =  $00091645;
// DBLPal
   DBLPAL_MONITOR_ID             =  $000a1000;

   DBLPALLORES_KEY               =  $000a1000;
   DBLPALLORESFF_KEY             =  $000a1004;
   DBLPALLORESHAM_KEY            =  $000a1800;
   DBLPALLORESHAMFF_KEY          =  $000a1804;
   DBLPALLORESEHB_KEY            =  $000a1080;
   DBLPALLORESEHBFF_KEY          =  $000a1084;
   DBLPALLORESLACE_KEY           =  $000a1005;
   DBLPALLORESHAMLACE_KEY        =  $000a1805;
   DBLPALLORESEHBLACE_KEY        =  $000a1085;
   DBLPALLORESDPF_KEY            =  $000a1400;
   DBLPALLORESDPFFF_KEY          =  $000a1404;
   DBLPALLORESDPFLACE_KEY        =  $000a1405;
   DBLPALLORESDPF2_KEY           =  $000a1440;
   DBLPALLORESDPF2FF_KEY         =  $000a1444;
   DBLPALLORESDPF2LACE_KEY       =  $000a1445;
   DBLPALHIRES_KEY               =  $000a9000;
   DBLPALHIRESFF_KEY             =  $000a9004;
   DBLPALHIRESHAM_KEY            =  $000a9800;
   DBLPALHIRESHAMFF_KEY          =  $000a9804;
   DBLPALHIRESLACE_KEY           =  $000a9005;
   DBLPALHIRESHAMLACE_KEY        =  $000a9805;
   DBLPALHIRESEHB_KEY            =  $000a9080;
   DBLPALHIRESEHBFF_KEY          =  $000a9084;
   DBLPALHIRESEHBLACE_KEY        =  $000a9085;
   DBLPALHIRESDPF_KEY            =  $000a9400;
   DBLPALHIRESDPFFF_KEY          =  $000a9404;
   DBLPALHIRESDPFLACE_KEY        =  $000a9405;
   DBLPALHIRESDPF2_KEY           =  $000a9440;
   DBLPALHIRESDPF2FF_KEY         =  $000a9444;
   DBLPALHIRESDPF2LACE_KEY       =  $000a9445;
   DBLPALEXTRALORES_KEY          =  $000a1200;
   DBLPALEXTRALORESHAM_KEY       =  $000a1a00;
   DBLPALEXTRALORESEHB_KEY       =  $000a1280;
   DBLPALEXTRALORESDPF_KEY       =  $000a1600;
   DBLPALEXTRALORESDPF2_KEY      =  $000a1640;
   DBLPALEXTRALORESFF_KEY        =  $000a1204;
   DBLPALEXTRALORESHAMFF_KEY     =  $000a1a04;
   DBLPALEXTRALORESEHBFF_KEY     =  $000a1284;
   DBLPALEXTRALORESDPFFF_KEY     =  $000a1604;
   DBLPALEXTRALORESDPF2FF_KEY    =  $000a1644;
   DBLPALEXTRALORESLACE_KEY      =  $000a1205;
   DBLPALEXTRALORESHAMLACE_KEY   =  $000a1a05;
   DBLPALEXTRALORESEHBLACE_KEY   =  $000a1285;
   DBLPALEXTRALORESDPFLACE_KEY   =  $000a1605;
   DBLPALEXTRALORESDPF2LACE_KEY  =  $000a1645;

// Tags
   BIDTAG_DIPFMustHave     = $80000001; // mask of the DIPF_ flags the ModeID must have Default - 0
   BIDTAG_DIPFMustNotHave  = $80000002; // mask of the DIPF_ flags the ModeID must not have Default - SPECIAL_FLAGS
   BIDTAG_ViewPort         = $80000003; // ViewPort for which a ModeID is sought.  Default - nil
   BIDTAG_NominalWidth     = $80000004; // \ together make the aspect ratio and
   BIDTAG_NominalHeight    = $80000005; // / override the vp^.Width/Height. Default - SourceID NominalDimensionInfo,
                                        // or vp^.DWidth/Height, or (640 * 200), in that preferred order.
   BIDTAG_DesiredWidth     = $80000006; // \ Nominal Width and Height of the
   BIDTAG_DesiredHeight    = $80000007; // / returned ModeID. Default - same as Nominal
   BIDTAG_Depth            = $80000008; // ModeID must support this depth. Default - vp^.RasInfo^.BitMap^.Depth or 1
   BIDTAG_MonitorID        = $80000009; // ModeID must use this monitor. Default - use best monitor available
   BIDTAG_SourceID         = $8000000a; // instead of a ViewPort. Default - VPModeID(vp) if BIDTAG_ViewPort is
                                        // specified, else leave the DIPFMustHave and DIPFMustNotHave values untouched.
   BIDTAG_RedBits          = $8000000b; // \
   BIDTAG_BlueBits         = $8000000c; //  > Match up from the database
   BIDTAG_GreenBits        = $8000000d; // /                 Default - 4
   BIDTAG_GfxPrivate       = $8000000e; // Private
   
type
// the "public" handle to a DisplayInfoRecord
  DisplayInfoHandle = APTR;

  PQueryHeader = ^TQueryHeader;
  TQueryHeader = record
    StructID,        // datachunk type identifier
    DisplayID,       // copy of display record key
    SkipID,          // TAG_SKIP
    Length:  ULONG;  // length of local data in double-longwords
  end;

  PDisplayInfo = ^TDisplayInfo;
  TDisplayInfo = record
    Header: TQueryHeader;
    NotAvailable: Word;       // If 0 DisplayInfo available, else not available -> see Constants DI_AVAIL_*
    PropertyFlags: ULONG;     // Properties of this mode (DIPF_*)
    Resolution: TPoint;       // ticks-per-pixel X/Y
    PixelSpeed: Word;         // approximation in nanoseconds
    NumStdSprites: Word;      // number of standard amiga sprites
    PaletteRange: Word;       // distinguishable shades available
    SpriteResolution: TPoint; // std sprite ticks-per-pixel X/Y
    pad: array[0..3] of Byte;
    RedBits: Byte;
    GreenBits: Byte;
    BlueBits: Byte;
    pad2: array[0..4] of Byte;
    Reserved: Array[0..1] of IPTR; // terminator
  end;

const
 // availability TDisplayInfo.NotAvailable 
  DI_AVAIL_NOCHIPS          = 1 shl 0;
  DI_AVAIL_NOMONITOR        = 1 shl 1;
  DI_AVAIL_NOTWITHGENLOCK   = 1 shl 2;
// Property Flags for TDisplayInfo.PropertyFlags
  DIPF_IS_LACE              = 1 shl 0;
  DIPF_IS_DUALPF            = 1 shl 1;
  DIPF_IS_PF2PRI            = 1 shl 2;
  DIPF_IS_HAM               = 1 shl 3;
  DIPF_IS_ECS               = 1 shl 4; // note: ECS modes (SHIRES, VGA, AND PRODUCTIVITY)
                                       // do not support attached sprites.
  DIPF_IS_PAL               = 1 shl 5;
  DIPF_IS_SPRITES           = 1 shl 6;
  DIPF_IS_GENLOCK           = 1 shl 7;
  DIPF_IS_WB                = 1 shl 8;
  DIPF_IS_DRAGGABLE         = 1 shl 9;
  DIPF_IS_PANELLED          = 1 shl 10;
  DIPF_IS_BEAMSYNC          = 1 shl 11;
  DIPF_IS_EXTRAHALFBRITE    = 1 shl 12;
  DIPF_IS_SPRITES_ATT       = 1 shl 13; // supports attached sprites
  DIPF_IS_SPRITES_CHNG_RES  = 1 shl 14; // supports variable sprite resolution
  DIPF_IS_SPRITES_BORDER    = 1 shl 15; // sprite can be displayed in the border
  DIPF_IS_AA                = 1 shl 16; // AA modes - may only be available if machine has correct memory
                                        // type to support required bandwidth - check availability.  
  DIPF_IS_SCANDBL           = 1 shl 17; // scan doubled
  DIPF_IS_SPRITES_CHNG_BASE = 1 shl 18; // can change the sprite base colour
  DIPF_IS_SPRITES_CHNG_PRI  = 1 shl 19; // can change the sprite priority with respect to the playfield(s).
  DIPF_IS_DBUFFER           = 1 shl 20; // can support double buffering
  DIPF_IS_PROGBEAM          = 1 shl 21; // is a programmed beam-sync mode
  DIPF_IS_FOREIGN           = 1 shl 22; // this mode is not native to the Amiga
  
// Use these tags for passing to BestModeID()
   SPECIAL_FLAGS = DIPF_IS_DUALPF or DIPF_IS_PF2PRI or DIPF_IS_HAM or DIPF_IS_EXTRAHALFBRITE;  

type
  PDimensionInfo = ^TDimensionInfo;
  TDimensionInfo = record
    Header: TQueryHeader;
    MaxDepth,              // log2(max number of colors) 
    MinRasterWidth,        // minimum width in pixels
    MinRasterHeight,       // minimum height in pixels
    MaxRasterWidth,        // maximum width in pixels
    MaxRasterHeight: Word; // maximum height in pixels
    Nominal,               // "standard" dimensions
    MaxOScan,              // fixed, hardware dependant
    VideoOScan,            // fixed, hardware dependant
    TxtOScan,              // editable via preferences
    StdOScan: TRectangle;  // editable via preferences
    Pad: array[0..13] of Byte;
    Reserved: array[0..1] of IPTR; // terminator
  end;

  PMonitorInfo = ^TMonitorInfo;
  TMonitorInfo = record
    Header: TQueryHeader;
    Mspc: PMonitorSpec;            // pointer to monitor specification
    ViewPosition,                  // editable via preferences
    ViewResolution: TPoint;        // standard monitor ticks-per-pixel
    ViewPositionRange: TRectangle; // fixed, hardware dependant
    TotalRows,                     // display height in scanlines
    TotalColorClocks,              // scanline width in 280 ns units
    MinRow: Word;                  // absolute minimum active scanline
    Compatibility: SmallInt;       // how this coexists with others (MCOMPAT_*)
    Pad: array[0..31] of Byte;
    MouseTicks: TPoint;
    DefaultViewPosition: TPoint;
    PreferredModeID: ULONG;
    Reserved: array[0..1] of IPTR; // terminator
  end;

const
// monitor compatibility TMonitorInfo.Compatibility
  MCOMPAT_NOBODY = -1;  // only one viewport at a time
  MCOMPAT_MIXED  =  0;  // can share display with other MCOMPAT_MIXED
  MCOMPAT_SELF   =  1;  // can share only within same monitor
  
  DISPLAYNAMELEN = 32;
type
  PNameInfo = ^TNameInfo;
  TNameInfo = record
    Header: TQueryHeader;
    Name: array[0..DISPLAYNAMELEN - 1] of Char;
    Reserved: array[0..1] of IPTR; // terminator
  end;
  
const
  DTAG_DISP = TAG_USER;
  DTAG_DIMS = TAG_USER + $1000;
  DTAG_MNTR = TAG_USER + $2000;
  DTAG_NAME = TAG_USER + $3000;
  DTAG_VEC  = TAG_USER + $4000;   // internal use only

type
// The following VecInfo structure is PRIVATE, for our use only Touch these, and burn!
  PVecInfo = ^TVecInfo;
  TVecInfo = record
    Header: TQueryHeader;
    Vec: APTR;
    Data: APTR;
    Type_: Word;  // original "Type" in C Includes
    pad: array[0..2] of Word;
    Reserved: array[0..1] of IPTR;
  end;
// AROS-specifics.
{$ifdef aros}
const
// Tags for AddDisplayDriverA()
  DDRV_BootMode     = TAG_USER + $01; // (LongBool) Boot mode driver which will be
                                      // unloaded when any next driver comes in, default = False 
  DDRV_MonitorID    = TAG_USER + $02; // (ULONG) Monitor ID for this driver, default = next available
  DDRV_ReserveIDs   = TAG_USER + $03;	// (ULONG) How many monitor IDs to reserve, default = 1
  DDRV_KeepBootMode = TAG_USER + $04;	// (LongBool) Do not shut down boot mode drivers, default = False
  DDRV_ResultID     = TAG_USER + $05;	// (PLongWord) Obtain assigned monitor ID
  DDRV_IDMask       = TAG_USER + $06;	// (ULONG) Use own mask for monitor ID separation
// Return codes
  DD_OK        = 0;	// No error
  DD_NO_MEM    = 1;	// Out of memory
  DD_ID_EXISTS = 2;	// Specified MonitorID is already allocated 

type
// This structure is subject to change! Private!
  PMonitorHandle = ^TMonitorHandle;
  TMonitorHandle = record
    Next: PMonitorHandle;
    id: ULONG;
    mask: ULONG;
    gfxhidd: APTR;
  end;
{$endif}

const
  VTAG_END_CM            = $00000000;
  VTAG_CHROMAKEY_CLR     = $80000000;
  VTAG_CHROMAKEY_SET     = $80000001;
  VTAG_BITPLANEKEY_CLR   = $80000002;
  VTAG_BITPLANEKEY_SET   = $80000003;
  VTAG_BORDERBLANK_CLR   = $80000004;
  VTAG_BORDERBLANK_SET   = $80000005;
  VTAG_BORDERNOTRANS_CLR = $80000006;
  VTAG_BORDERNOTRANS_SET = $80000007;
  VTAG_CHROMA_PEN_CLR    = $80000008;
  VTAG_CHROMA_PEN_SET    = $80000009;
  VTAG_CHROMA_PLANE_SET  = $8000000A;
  VTAG_ATTACH_CM_SET     = $8000000B;
  VTAG_NEXTBUF_CM        = $8000000C;
  VTAG_BATCH_CM_CLR      = $8000000D;
  VTAG_BATCH_CM_SET      = $8000000E;
  VTAG_NORMAL_DISP_GET   = $8000000F;
  VTAG_NORMAL_DISP_SET   = $80000010;
  VTAG_COERCE_DISP_GET   = $80000011;
  VTAG_COERCE_DISP_SET   = $80000012;
  VTAG_VIEWPORTEXTRA_GET = $80000013;
  VTAG_VIEWPORTEXTRA_SET = $80000014;
  VTAG_CHROMAKEY_GET     = $80000015;
  VTAG_BITPLANEKEY_GET   = $80000016;
  VTAG_BORDERBLANK_GET   = $80000017;
  VTAG_BORDERNOTRANS_GET = $80000018;
  VTAG_CHROMA_PEN_GET    = $80000019;
  VTAG_CHROMA_PLANE_GET  = $8000001A;
  VTAG_ATTACH_CM_GET     = $8000001B;
  VTAG_BATCH_CM_GET      = $8000001C;
  VTAG_BATCH_ITEMS_GET   = $8000001D;
  VTAG_BATCH_ITEMS_SET   = $8000001E;
  VTAG_BATCH_ITEMS_ADD   = $8000001F;
  VTAG_VPMODEID_GET      = $80000020;
  VTAG_VPMODEID_SET      = $80000021;
  VTAG_VPMODEID_CLR      = $80000022;
  VTAG_USERCLIP_GET      = $80000023;
  VTAG_USERCLIP_SET      = $80000024;
  VTAG_USERCLIP_CLR      = $80000025;
// The following tags are V39 specific. They will be ignored (returing error -3) by earlier versions
  VTAG_PF1_BASE_GET             =  $80000026;
  VTAG_PF2_BASE_GET             =  $80000027;
  VTAG_SPEVEN_BASE_GET          =  $80000028;
  VTAG_SPODD_BASE_GET           =  $80000029;
  VTAG_PF1_BASE_SET             =  $8000002a;
  VTAG_PF2_BASE_SET             =  $8000002b;
  VTAG_SPEVEN_BASE_SET          =  $8000002c;
  VTAG_SPODD_BASE_SET           =  $8000002d;
  VTAG_BORDERSPRITE_GET         =  $8000002e;
  VTAG_BORDERSPRITE_SET         =  $8000002f;
  VTAG_BORDERSPRITE_CLR         =  $80000030;
  VTAG_SPRITERESN_SET           =  $80000031;
  VTAG_SPRITERESN_GET           =  $80000032;
  VTAG_PF1_TO_SPRITEPRI_SET     =  $80000033;
  VTAG_PF1_TO_SPRITEPRI_GET     =  $80000034;
  VTAG_PF2_TO_SPRITEPRI_SET     =  $80000035;
  VTAG_PF2_TO_SPRITEPRI_GET     =  $80000036;
  VTAG_IMMEDIATE                =  $80000037;
  VTAG_FULLPALETTE_SET          =  $80000038;
  VTAG_FULLPALETTE_GET          =  $80000039;
  VTAG_FULLPALETTE_CLR          =  $8000003A;
  VTAG_DEFSPRITERESN_SET        =  $8000003B;
  VTAG_DEFSPRITERESN_GET        =  $8000003C; 

{ all the following tags follow the new, rational standard for videocontrol tags:
  VC_xxx,state         set the state of attribute 'xxx' to value 'state'
  VC_xxx_QUERY,&var    get the state of attribute 'xxx' and store it into the longword
                       pointed to by &var.
  The following are new for V40:}
  VC_IntermediateCLUpdate       =  $80000080; // default = True. When set graphics will update the intermediate copper
  VC_IntermediateCLUpdate_Query =  $80000081; // lists on color changes, etc. When false, it won't, and will be faster.
  VC_NoColorPaletteLoad         =  $80000082; // default = False. When set, graphics will only load color 0
  VC_NoColorPaletteLoad_Query   =  $80000083; // for this ViewPort, and so the ViewPort's colors will come from the previous ViewPort's.
                                              // NB - Using this tag and VTAG_FULLPALETTE_SET together is undefined.
  VC_DUALPF_Disable             =  $80000084; // default = False. When this flag is set, the dual-pf bit
  VC_DUALPF_Disable_Query       =  $80000085; // in Dual-Playfield screens will be turned off. Even bitplanes
                                              // will still come from the first BitMap and odd bitplanes
                                              // from the second BitMap, and both R[xy]Offsets will be
                                              // considered. This can be used (with appropriate palette
                                              // selection) for cross-fades between differently scrolling
                                              // images.
                                              // When this flag is turned on, colors will be loaded for
                                              // the viewport as if it were a single viewport of depth
                                              // depth1+depth2
const
  SPRITE_ATTACHED     = $80;

type
  PPSimpleSprite = ^PSimpleSprite;
  PSimpleSprite = ^TSimpleSprite;
  TSimpleSprite = record
    PosCtlData: PWord;
    Height: Word;
    x, y: Word;   // current position
    Num: Word;
  end;

  PExtSprite = ^TExtSprite;
  TExtSprite = record
    es_SimpleSprite: TSimpleSprite;         { conventional simple sprite structure }
    es_WordWidth: Word;                 { graphics use only, subject to change }
    es_Flags: Word;                 { graphics use only, subject to change }
{$ifdef aros} // New in AROS
    es_Bitmap: PBitmap;  // Actual image data. 
{$endif}    
  end;

const
// Tags for AllocSpriteData()
  SPRITEA_Width          = $81000000;
  SPRITEA_XReplication   = $81000002;
  SPRITEA_YReplication   = $81000004;
  SPRITEA_OutputHeight   = $81000006;
  SPRITEA_Attached       = $81000008;
  SPRITEA_OldDataFormat  = $8100000a; // MUST pass in outputheight if using this tag
// Tags for GetExtSprite()
  GSTAG_SPRITE_NUM       = $82000020;
  GSTAG_ATTACHED         = $82000022;
  GSTAG_SOFTSPRITE       = $82000024;
// Tags valid for either GetExtSprite or ChangeExtSprite
  GSTAG_SCANDOUBLED      = $83000000; // request "NTSC-Like" height if possible.

type
// BitScaleArgs structure used by BitMapScale()
  PBitScaleArgs = ^TBitScaleArgs;
  TBitScaleArgs = record
    bsa_SrcX, bsa_SrcY,             // source origin
    bsa_SrcWidth, bsa_SrcHeight,    // source size
    bsa_XSrcFactor, bsa_YSrcFactor, // scale factor denominators
    bsa_DestX, bsa_DestY,           // destination origin
    bsa_DestWidth, bsa_DestHeight,  // destination size result
    bsa_XDestFactor,                // scale factor numerators
    bsa_YDestFactor: Word;
    bsa_SrcBitMap,                  // source BitMap
    bsa_DestBitMap: PBitMap;        // destination BitMap
    bsa_Flags: ULONG;               // reserved.  Must be zero!
    bsa_XDDA, bsa_YDDA: Word;       // reserved
    bsa_Reserved1,
    bsa_Reserved2: Longint;
  end;

const
// tag definitions for GetRPAttr, SetRPAttr
  RPTAG_Font       = $80000000;  // get/set font
  RPTAG_APen       = $80000002;  // get/set apen
  RPTAG_BPen       = $80000003;  // get/set bpen
  RPTAG_DrMd       = $80000004;  // get/set draw mode
  RPTAG_OutlinePen = $80000005;  // get/set outline pen. corrected case.
  RPTAG_WriteMask  = $80000006;  // get/set WriteMask
  RPTAG_MaxPen     = $80000007;  // get/set maxpen
  RPTAG_DrawBounds = $80000008;  // get only rastport draw bounds. pass @rect
// Extensions taken over from MorphOS
  RPTAG_PenMode    = $80000080;
  RPTAG_FgColor    = $80000081;
  RPTAG_BgColor    = $80000082;
{$ifdef aros}
// Extensions invented by AROS
  RPTAG_PatternOriginX     = $800000C0; // SmallInt
  RPTAG_PatternOriginY     = $800000C1; // SmallInt
  RPTAG_ClipRectangle  	   = $800000C2; // PRectangle Clones PRectangle.
  RPTAG_ClipRectangleFlags = $800000C3; // LongWord
  RPTAG_RemapColorFonts	   = $800000C4; // LongBool
{$endif}

// Flags for ClipRectangleFlags
  RPCRF_RELRIGHT  = $01; // ClipRectangle.MaxX is relative to right of layer/bitmap
  RPCRF_RELBOTTOM = $02; // ClipRectangle.MaxY is relative to bottom of layer/bitmap
  RPCRF_VALID 	  = $04; // private

type
  PGfxBase = ^tGfxBase;
  TGfxBase = record
    LibNode: TLibrary;
    
    ActiView: PView;      // ViewPtr
    CopInit: PCopInit;    // ptr to copper start up list
    Cia: PLongInt;        // for 8520 resource use
    blitter: PLongInt;    // for future blitter resource use
    LOFlist: PWord;
    SHFlist: PWord;
    blthd,
    blttl: PBltNode;
    bsblthd,
    bsblttl: PBltNode;
    vbsrv,
    timsrv,
    bltsrv: TInterrupt;
    
    TextFonts: TList;    // Fonts
    DefaultFont: PTextFont; 
    
    Modes: Word;              // copy of current first bplcon0
    VBlank: Shortint;
    Debug: Shortint;
    BeamSync: SmallInt;
    system_bplcon0: SmallInt; // it is ored into each bplcon0 for display
    SpriteReserved: Byte;
    bytereserved: Byte;
    Flags: Word;
    BlitLock: SmallInt;
    BlitNest: SmallInt;

    BlitWaitQ: TList;
    BlitOwner: PTask;
    TOF_WaitQ: tList;
    
    DisplayFlags: Word;            // NTSC PAL GENLOC etc.  Display flags are determined at power on
    SimpleSprites: PPSimpleSprite; // SimpleSpritePtr ptr
    
    MaxDisplayRow: Word;       // hardware stuff, do not use
    MaxDisplayColumn: Word;    // hardware stuff, do not use
    NormalDisplayRows: Word;
    NormalDisplayColumns: Word;
     // the following are for standard non interlace, 1/2 wb width
    NormalDPMX: Word;        // Dots per meter on display
    NormalDPMY: Word;        // Dots per meter on display
    
    LastChanceMemory: PSignalSemaphore;
    
    LCMptr: PWord;
    MicrosPerLine: Word;    // 256 time usec/line
    MinDisplayColumn: Word;
    ChipRevBits0: Byte;
    MemType: Byte;
    crb_reserved:  array[0..3] of Byte;
    monitor_id: Word;            // normally 0
    hedley: array[0..7] of IPTR;
    hedley_sprites: array[0..7] of IPTR;     // sprite ptrs for intuition mouse
    hedley_sprites1: array[0..7] of IPTR;    // sprite ptrs for intuition mouse
    hedley_count: SmallInt;
    hedley_flags: Word;
    hedley_tmp: SmallInt;
    
    hash_table: ^IPTR;          // Hashtable used for GfxAssociate() and GfxLookup() (private!)
    current_tot_rows: Word;
    current_tot_cclks: Word;
    hedley_hint: Byte;
    hedley_hint2: Byte;
    nreserved: array[0..3] of ULONG;
    a2024_sync_raster: PLongWord;
    control_delta_pal: Word;
    control_delta_ntsc: Word;
    
    Current_Monitor: PMonitorSpec;          // MonitorSpec used for current display
    MonitorList: TList;                     // List of all MonitorSpecs in the system
    Default_Monitor: PMonitorSpec;          // MonitorSpec of "default.monitor"
    MonitorListSemaphore: PSignalSemaphore; // Semaphore for MonitorList access 
    
    DisplayInfoDataBase: Pointer;           // nil, unused by AROS
    TopLine: Word;
    ActiViewCprSemaphore: pSignalSemaphore; // Semaphore for active view access
    
    UtilityBase: PUtilityBase;   // for hook AND tag utilities
    ExecBase: PExecBase;         // to link with rom.lib
    
    bwshifts: PShortInt;
    StrtFetchMasks,
    StopFetchMasks,
    Overrun: PWord;
    RealStops: PSmallInt;
    SpriteWidth,               // current width (in words) of sprites
    SpriteFMode: Word;         // current sprite fmode bits
    SoftSprites,               // bit mask of size change knowledgeable sprites
    arraywidth: ShortInt;
    DefaultSpriteWidth: Word;  // what width intuition wants
    SprMoveDisable: ShortInt;
    WantChips,
    BoardMemType,
    Bugs: Byte;
    gb_LayersBase: PLongWord; // layers.library base
    ColorMask: ULONG;
    IVector,
    IData: APTR;
    SpecialCounter: ULONG;    // special for double buffering
    DBList: APTR;
    MonitorFlags: Word;
    ScanDoubledSprites,
    BP3Bits: Byte;
    
    MonitorVBlank: TAnalogSignalInterval;
    Natural_Monitor: PMonitorSpec; // Default MonitorSpec for view without explicit MonitorSpec in ViewExtra
    
    ProgData: APTR;  // nil not used in AROS
    ExtSprites: Byte;
    pad3: Byte;
    GfxFlags: Word;
    VBCounter: ULONG;
    
    HashTableSemaphore: PSignalSemaphore;  // Semaphore for hash_table access, private in fact
    
    ChunkyToPlanarPtr: PLongWord;  // HWEmul[0];
    HWEmul: array[1..8] of PLongWord;
  end;

type  
// for SetDisplayDriverCallback
  TDriverNotifyFunc = function (Obj: APTR; Add: LongBool; userdata: APTR): APTR; cdecl;
  
const
//DisplayFlags 
  // Specify some system-wide options for Amiga(tm) chipset
  NTSC             = 1 shl 0; // Default mode is NTSC
  GENLOC           = 1 shl 1; // Genlock is in use
  PAL              = 1 shl 2; // Default mode is PAL
  TODA_SAFE        = 1 shl 3;
  REALLY_PAL       = 1 shl 4;
  LPEN_SWAP_FRAMES = 1 shl 5; // When light pen is being used on interlaced screens, swap even and odd frames 
// bits defs for ChipRevBits
  GFXB_BIG_BLITS = 0 ;
  GFXB_HR_AGNUS  = 0 ;
  GFXB_HR_DENISE = 1 ;
  GFXB_AA_ALICE  = 2 ;
  GFXB_AA_LISA   = 3 ;
  GFXB_AA_MLISA  = 4 ;      { internal use only. }
// Bit Values for ChipRevBits
  GFXF_BIG_BLITS = 1 shl GFXB_BIG_BLITS;
  GFXF_HR_AGNUS  = 1 shl GFXB_HR_AGNUS;
  GFXF_HR_DENISE = 1 shl GFXB_HR_DENISE;
  GFXF_AA_ALICE  = 1 shl GFXB_AA_ALICE;
  GFXF_AA_LISA   = 1 shl GFXB_AA_LISA;
  GFXF_AA_MLISA  = 1 shl GFXB_AA_MLISA;      { internal use only }

//Pass ONE of these to SetChipRev()
  SETCHIPREV_A    = GFXF_HR_AGNUS;
  SETCHIPREV_ECS  = GFXF_HR_AGNUS or GFXF_HR_DENISE;
  SETCHIPREV_AA   = GFXF_AA_ALICE or GFXF_AA_LISA or SETCHIPREV_ECS;
  SETCHIPREV_BEST = $ffffffff;

// memory type
  BUS_16          = 0;
  BUS_32          = 1;
  NML_CAS         = 0;
  DBL_CAS         = 2;
   
  BANDWIDTH_1X    = BUS_16 or NML_CAS;
  BANDWIDTH_2XNML = BUS_32;
  BANDWIDTH_2XDBL = DBL_CAS;
  BANDWIDTH_4X    = BUS_32 or DBL_CAS;

  BLITMSG_FAULT = 4;

{ GfxFlags (private) }
  NEW_DATABASE   = 1;
 
  GRAPHICSNAME: PChar  = 'graphics.library';
  
var
  GfxBase: PGfxBase;

procedure AddAnimOb(AnOb: PAnimOb; AnKey: PPAnimOb; Rp: PRastPort); // 26
procedure AddBob(Bob: PBob; Rp: PRastPort); // 16
function AddDisplayDriverA(GfxHidd: APTR; Tags: PTagItem): LongInt; // 181
procedure AddFont(TextFont: PTextFont); // 80
procedure AddVSprite(VSprite: PVSprite; Rp: PRastPort); // 17
function AllocBitMap(Sizex, Sizey, Depth, Flags: LongWord; Friend_Bitmap: PBitMap): PBitMap;
function AllocDBufInfo(Vp: PViewPort): PDBufInfo; // 161
function AllocRaster(Width, Height: LongWord): TPlanePtr; // 82
function AllocSpriteDataA(Bitmap: PBitMap; TagList: PTagItem): PExtSprite; // 170
function AndRectRect(Rect1: PRectangle; Rect2: PRectangle; Intersect: PRectangle): LongBool; // 193
procedure AndRectRegion(Reg: PRegion; Rect :PRectangle); // 84
procedure AndRectRegionND(Reg: PRegion; Rect: PRectangle); // 107
function AndRegionRegion(SrcRegion: PRegion; DestRegion: PRegion): LongBool; // 104
function AndRegionRegionND(R1: PRegion; R2: PRegion): PRegion; // 108
procedure Animate(AnKey: PPAnimOb; Rp: PRastPort); // 27
function AreaDraw(Rp: PRastPort; x, y: SmallInt): LongWord; // 43
function AreaEllipse(Rp: PRastPort; xCenter, yCenter, a, b: SmallInt): LongWord; // 31
function AreaEnd(Rp: PRastPort): LongInt; // 44
function AreaMove(Rp: PRastPort; x, y: SmallInt): LongWord; // 42
function AreRegionsEqual(R1: PRegion; R2: PRegion): LongBool; // 189
procedure AskFont(Rp: PRastPort; TextAttr: PTextAttr); // 79
function AskSoftStyle(Rp: PRastPort): LongWord; // 14
function AttachPalExtra(Cm: PColorMap; Vp: PViewPort): LongInt; // 139
function AttemptLockLayerRom(l: PLayer): LongBool; // 109
function BestModeIDA(Tags: PTagItem): LongWord; // 175
procedure BitMapScale(BitScaleArgs: PBitScaleArgs); // 113
function BltBitMap(const SrcBitMap: PBitMap; xSrc, ySrc: LongInt; DestBitMap: PBitMap; xDest, yDest, xSize, ySize: LongInt; MinTerm : LongWord; Mask: LongWord; TempA: TPlanePtr): LongInt; // 5
procedure BltBitMapRastPort(const SrcBitMap: PBitMap; xSrc, ySrc: LongInt; DestRP: PRastPort; xDest, yDest, xSize, ySize: LongInt; MinTerm: LongWord); // 101
procedure BltClear(MemBlock: Pointer; ByteCount: LongWord; Flags: LongWord); deprecated; // 50
procedure BltMaskBitMapRastPort(SrcBitMap: PBitMap; xSrc, ySrc: LongInt; DestRP: PRastPort; xDest, yDest, xSize, ySize: LongInt; MinTerm: LongWord; bltMask: TPlanePtr); // 106
procedure BltPattern(Rp: PRastPort; mask: TPlanePtr; xMin, yMin, xMax, yMax: LongInt; ByteCnt: LongWord); // 52
procedure BltRastPortBitMap(SrcRastPort: PRastPort; xSrc, ySrc: LongInt; DestBitMap: PBitMap; xDest, yDest, xSize, ySize, MinTerm: LongWord);
procedure BltTemplate(const Source: TPlanePtr; xSrc, srcMod: LongInt; DestRP: PRastPort; xDest, yDest, xSize, ySize: LongInt); // 6
function CalcIVG(View: PView; ViewPort: PViewPort): Word; unimplemented; // 138
procedure CBump(CopList: PUCopList); // 61
function ChangeExtSpriteA(Vp: PViewPort; Oldsprite: PExtSprite; NewSprite: PExtSprite; Tags: PTagItem): LongInt; // 171
procedure ChangeSprite(Vp: PViewPort; s: PSimpleSprite; NewData: Pointer); unimplemented; // 70
procedure ChangeVPBitMap(Vp: PViewPort; Bm: PBitMap; Db: PDBufInfo); // 157
procedure ClearEOL(Rp: PRastPort); // 7
function ClearRectRegion(Reg: PRegion; Rect: PRectangle): LongBool; // 87
function ClearRectRegionND(Reg: PRegion; Rect: PRectangle): PRegion; // 124
procedure ClearRegion(Region: PRegion); // 88
function ClearRegionRegion(R1: PRegion; R2: PRegion): LongBool; // 187
function ClearRegionRegionND(R1: PRegion; R2: PRegion): PRegion; // 141
procedure ClearScreen(Rp: PRastPort); // 8
procedure ClipBlit(SrcRP: PRastPort; xSrc, ySrc: LongInt; DestRP: PRastPort; xDest, yDest, xSize, ySize: LongInt; MinTerm: Byte); // 92
procedure CloseFont(TextFont: PTextFont); // 13
function CloseMonitor(Monitor_Spec: PMonitorSpec): LongInt; // 120
procedure CMove(CopList: PUCopList; Reg: Pointer; Value: LongInt); // 62
function CoerceMode(RealViewPort: PViewPort; MonitorID: LongWord; Flags: LongWord): LongWord; unimplemented; // 156
function CopyRegion(Region: PRegion): PRegion;
procedure CopySBitMap(l: PLayer); // 75
function CreateRastPort: PRastPort; // 177
function CloneRastPort(Rp: PRastPort): PRastPort; // 178
procedure DeinitRastPort(Rp: PRastPort); // 179
procedure FreeRastPort(Rp: PRastPort); // 180
procedure CWait(CopList: PUCopList; V: SmallInt; H: SmallInt); // 63
procedure DisownBlitter; // 77
procedure DisposeRegion(Region: PRegion); // 89
procedure DoCollision(Rp: PRastPort); // 18
function DoPixelFunc(Rp: PRastPort; x, y: LongInt; Render_Func: Pointer; FuncData: APTR; Do_Update: LongBool): LongInt; // 185
function DoRenderFunc(Rp: PRastPort; Src: PPoint; Rr: PRectangle; Render_Func: Pointer; FuncData: APTR; Do_Update: LongBool): LongInt; // 184
procedure Draw(Rp: PRastPort; x, y: LongInt); // 41
procedure DrawEllipse(Rp: PRastPort; xCenter, yCenter, a, b: LongInt); // 30
procedure DrawGList(Rp: PRastPort; Vp: PViewPort); // 19
procedure EraseRect(Rp: PRastPort; xMin, yMin, xMax, yMax: LongInt); // 135
function ExtendFont(Font: PTextFont; FontTags: PTagItem): LongWord; // 136
function FillRectPenDrMd(Rp: PRastPort; x1, y1, x2, y2: LongInt; Pix: Pointer{HIDDT_Pixel}; drmd: Pointer{HIDDT_DrawMode}; Do_Update: LongBool): LongInt; // 183
function FindColor(Cm: PColorMap; r, g, b, MaxPen: LongWord): LongWord; // 168
function FindDisplayInfo(ID: LongWord): DisplayInfoHandle; // 121
function Flood(Rp: PRastPort; Mode: LongWord; x, y: LongInt): LongBool; // 55
procedure FontExtent(Font: PTextFont; FontExtent: PTextExtent); // 127
procedure FreeBitMap(Bm: PBitMap); // 154
procedure FreeColorMap(ColorMap: PColorMap); // 96
procedure FreeCopList(CopList: PCopList); // 91
procedure FreeCprList(CprList: PCprList); // 94
procedure FreeDBufInfo(Dbi: PDBufInfo); // 162
procedure FreeGBuffers(AnOb: PAnimOb; Rp: PRastPort; db: LongBool); // 100
procedure FreeRaster(p: TPlanePtr; Width, Height: LongWord); // 83
procedure FreeSprite(Pick: SmallInt); // 69
procedure FreeSpriteData(ExtSp: PExtSprite); // 172
procedure FreeVPortCopLists(Vp: PViewPort); // 90
function GetAPen(Rp: PRastPort): LongWord; // 143
function GetBitMapAttr(BitMap: PBitMap; Attribute: LongWord): IPTR; // 160
function GetBPen(Rp: PRastPort): LongWord; // 144
function GetColorMap(Entries: LongWord): PColorMap; // 95
function GetDisplayInfoData(Handle: DisplayInfoHandle; Buf: PChar; Size: LongWord; TagID: LongWord; ID: LongWord): LongWord; // 126
function GetDrMd(Rp: PRastPort): LongWord; // 145
function GetExtSpriteA(Sprite: PExtSprite; Tags: PTagItem): LongInt; // 155
function GetGBuffers(AnOb: PAnimOb; Rp: PRastPort; Db: LongBool): LongBool; // 28
function GetOutlinePen(Rp: PRastPort): LongWord; // 146
procedure GetRGB32(Cm: PColorMap; FirstColor: LongWord; NColors: LongWord; Table: PLongWord);
function GetRGB4(ColorMap: PColorMap; Entry: LongInt): LongWord; // 97
procedure GetRPAttrsA(Rp: PRastPort; Tags: PTagItem); // 174
function GetSprite(Sprite: PSimpleSprite; Pick: SmallInt): SmallInt; // 68
function GetVPModeID(Vp: PViewPort): LongWord; // 132
procedure GfxAssociate(Pointer_: Pointer; Node: PExtendedNode); // 112
procedure GfxFree(Node: PExtendedNode); // 111
function GfxLookUp(Pointer_: Pointer): PExtendedNode; // 117
function GfxNew(Node_Type: LongWord): PExtendedNode; // 110
procedure InitArea(AreaInfo: PAreaInfo; Buffer: Pointer; MaxVectors: SmallInt); // 47
procedure InitBitMap(Bm: PBitMap; Depth: ShortInt; Width, Height: Word); // 65
procedure InitGels(Head: PVSprite; Tail: PVSprite; GelsInfo: PGelsInfo); // 20
procedure InitGMasks(AnOb: PAnimOb); // 29
procedure InitMasks(VSprite: PVSprite); // 21
procedure InitRastPort(Rp: PRastPort); // 33
function InitTmpRas(TmpRas: PTmpRas; Buffer: Pointer; Size: LongWord): PTmpRas; // 78
procedure InitView(View: PView); // 60
procedure InitVPort(Vp: PViewPort); // 34
function IsPointInRegion(Reg: PRegion; x, y: SmallInt): LongBool; // 190
procedure LoadRGB32(Vp: PViewPort; const Table: PLongWord); // 147
procedure LoadRGB4(Vp: PViewPort; Colors: PWord; Count: LongInt); 
procedure LoadView(View: PView); // 37
procedure LockLayerRom(l: PLayer); // 72
function MakeVPort(View: PView; ViewPort: PViewPort): LongWord; // 36
function ModeNotAvailable(ModeID: LongWord): LongWord; // 133
procedure Move(Rp: PRastPort; x, y: SmallInt); // 40
procedure MoveSprite(Vp: PViewPort; Sprite: PSimpleSprite; x, y: SmallInt); // 71
function MrgCop(View: PView): LongWord; // 35
function NewRectRegion(MinX, MinY, MaxX, MaxY: SmallInt): PRegion; // 194
function NewRegion: PRegion; // 86
function NextDisplayInfo(Last_ID: LongWord): LongWord; // 122
function ObtainBestPenA(Cm: PColorMap; r, g, b: LongWord; Tags: PTagItem): LongInt; // 140
function ObtainPen(Cm: PColorMap; n, r, g, b: LongWord; Flags: LongWord): LongInt; // 159
function OpenFont(TextAttr: PTextAttr): PTextFont; // 12
function OpenMonitor(MonitorName: STRPTR; DisplayID: LongWord): PMonitorSpec; // 119
function OrRectRegion(Reg: PRegion; Rect: PRectangle): LongBool; // 85
function OrRectRegionND(Reg: PRegion; Rect: PRectangle): PRegion; // 123
function OrRegionRegion(SrcRegion: PRegion; DestRegion: PRegion): LongBool; // 102
function OrRegionRegionND(R1: PRegion; R2: PRegion): PRegion; // 125
procedure OwnBlitter; // 76
procedure PolyDraw(Rp: PRastPort; Count: LongInt; PolyTable: PSmallInt); // 56
procedure QBlit(Blit: PBltNode); // 46
procedure QBSBlit(Blit: PBltNode); // 49
function ReadPixel(Rp: PRastPort; x, y: LongInt): LongInt; // 53
function ReadPixelArray8(Rp: PRastPort; xStart, yStart, xStop, yStop: LongWord; Array_: PByte; TempRp: PRastPort): LongInt; // 130
function ReadPixelLine8(Rp: PRastPort; xStart, yStart, Width: LongWord; Array_: PByte; TempRP: PRastPort): LongInt; // 128
procedure RectFill(Rp: PRastPort; xMin, yMin, xMax, yMax : LongInt); // 51
procedure ReleasePen(Cm: PColorMap; n: LongWord); // 158
procedure RemFont(TextFont: PTextFont); // 81
procedure RemIBob(Bob: PBob; Rp: PRastPort; Vp: PViewPort); // 22
procedure RemVSprite(VSprite: PVSprite); // 23
function ScalerDiv(Factor: LongWord; Numerator: LongWord; Denominator: LongWord): Word; //114
procedure ShowImminentReset; // 197
procedure ScrollRaster(Rp: PRastPort; dx, dy, xMin, yMin, xMax, yMax: LongInt); // 66
procedure ScrollRasterBF(Rp: PRastPort; dx, dy, xMin, yMin, xMax, yMax: LongInt); // 167
function ScrollRegion(Region: PRegion; Rect: PRectangle; Dx, Dy: SmallInt): LongBool; // 191
procedure ScrollVPort(Vp: PViewPort); // 98
procedure SetABPenDrMd(Rp: PRastPort; APen: LongWord; BPen: LongWord; DrawMode: LongWord); // 149
procedure SetAPen(Rp: PRastPort; Pen: LongWord); // 57
procedure SetBPen(Rp: PRastPort; Pen: LongWord); // 58
function SetChipRev(ChipRev: LongWord): LongWord; platform; // 148
procedure SetCollision(Num: LongWord; Routine: TProcedure; GInfo: PGelsInfo); // 24
procedure SetDisplayDriverCallback(CallBack: TDriverNotifyFunc; UserData: APTR); // 186
procedure SetDrMd(Rp: PRastPort; DrawMode: LongWord); // 59
procedure SetFont(Rp: PRastPort; TextFont: PTextFont); // 11
procedure SetMaxPen(Rp: PRastPort; MaxPen: LongWord); // 165
function SetOutlinePen(Rp: PRastPort; Pen: LongWord): LongWord; // 163
procedure SetRast(Rp: PRastPort; Pen: LongWord); // 39
function SetRegion(Src: PRegion; Dest: PRegion): LongBool; // 195
procedure SetRGB32(Vp: PViewPort; n, r, g, b : LongWord); // 142
procedure SetRGB32CM(Cm: PColorMap; n, r, g, b: LongWord); // 166
procedure SetRGB4(Vp: PViewPort; n, r, g, b: LongWord); // 48
procedure SetRGB4CM(Cm: PColorMap; n: SmallInt; r, g, b: Byte); // 105
procedure SetRPAttrsA(Rp: PRastPort; Tags: PTagItem); // 173
function SetSoftStyle(Rp: PRastPort; Style: LongWord; Enable: LongWord): LongWord; // 15
function SetWriteMask(Rp: PRastPort; Mask: LongWord): LongWord; // 164
procedure SortGList(Rp: PRastPort); // 25
procedure StripFont(Font: PTextFont); // 137
function SwapRegions(Region1: PRegion; Region2: PRegion; Intersect: PRectangle): LongBool; // 192
procedure SyncSBitMap(l: PLayer); // 74
procedure GfxText(Rp: PRastPort; const String_: STRPTR; Count: LongWord); // 10
procedure TextExtent(Rp: PRastPort; const String_: STRPTR; Count: LongWord; TextExtent_: PTextExtent);
function TextFit(Rp: PRastPort; const String_: STRPTR; StrLen: LongWord; TextExtent_: PTextExtent; ConstrainingExtent: PTextExtent; StrDirection: LongInt; ConstrainingBitWidth: LongWord; ConstrainingBitHeight: LongWord): LongWord; // 116
function TextLength(Rp: PRastPort; const string_: STRPTR; Count: LongWord): SmallInt; // 9
function UCopperListInit(Ucl: PUCopList; n: SmallInt): PCopList; // 99
procedure UnlockLayerRom(l: PLayer); // 73
function VBeamPos: LongInt; platform; // 64
function VideoControl(Cm: PColorMap; Tags: PTagItem): LongWord; unimplemented; // 118
procedure WaitBlit; unimplemented; // 38
procedure WaitBOVP(Vp: PViewPort); unimplemented; // 67
procedure WaitTOF; // 45
function WeighTAMatch(ReqTextAttr: PTextAttr; TargetTextAttr: PTextAttr; TargetTags: PTagItem): SmallInt; // 134
procedure WriteChunkyPixels(Rp: PRastPort; xStart, yStart, xStop, yStop: LongWord; Array_: PByte; BytesPerRow: LongInt); // 176
function WritePixel(Rp: PRastPort; x, y: LongInt): LongInt; // 54
function WritePixelArray8(Rp: PRastPort; xStart, yStart, xStop, yStop: LongWord; Array_: PByte; TempRp: PRastPort): LongInt; // 131
function WritePixelLine8(Rp: PRastPort; xStart, yStart, Width: LongWord; Array_: PByte; TempRP: PRastPort): LongInt; // 129
function WritePixels8(Rp: PRastPort; Array_: PByte; Modulo: LongWord; xStart, yStart, xStop, yStop: LongWord; PixLUT: Pointer{PHIDDT_PixelLUT}; Do_Update: LongBool): LongInt;
function XorRectRegion(Reg: PRegion; Rect: PRectangle): LongBool; // 93
function XorRectRegionND(Reg: PRegion; Rect: PRectangle): PRegion; // 152
function XorRegionRegion(SrcRegion: PRegion; DestRegion: PRegion): LongBool; // 103
function XorRegionRegionND(R1: PRegion; R2: PRegion): PRegion; // 151

function BestModeID(Tags: array of const): LongWord;
function AllocSpriteData(Bitmap: PBitMap; Tags: array of const): PExtSprite;
function ChangeExtSprite(Vp: PViewPort; Oldsprite: PExtSprite; NewSprite: PExtSprite; Tags: array of const): LongInt;
function ExtendFontTags(Font: PTextFont; Tags: array of const): LongWord;
function GetExtSprite(Sprite: PExtSprite; Tags: array of const): LongInt;
procedure GetRPAttrs(Rp: PRastPort; Tags: array of const);
function ObtainBestPen(Cm: PColorMap; r, g, b: LongWord; Tags: array of const): LongInt;
procedure SetRPAttrs(Rp: PRastPort; Tags: array of const);
function VideoControlTags(Cm: PColorMap; Tags: array of const): LongWord; unimplemented;

// gfxmacros

// This one is used for determining optimal offset for blitting into cliprects 
function Align_Offset(x: Pointer): Pointer;
function Is_Visible(l: PLayer): Boolean;
procedure InitAnimate(var Animkey: PAnimOb);
procedure RemBob(B: PBob);

function RasSize(w, h: Word): Integer;
function BitmapFlags_are_Extended(f: LongInt): Boolean;
function GetTextFontReplyPort(Font: PTextFont): PMsgPort;

procedure BNDRYOFF(w: PRastPort);

procedure SetAfPt(w: PRastPort; p: Pointer; n: Byte);
procedure SetDrPt(w: PRastPort; p: Word);
procedure SetOPen(w: PRastPort; c: Byte);
procedure SetWrMsk(w: PRastPort; m: Byte);
  
function SetAOlPen(Rp: PRastPort; Pen: LongWord): LongWord;

procedure DrawCircle(Rp: PRastPort; xCenter, yCenter, r: LongInt);
function AreaCircle(Rp: PRastPort; xCenter, yCenter, r: SmallInt): LongWord;

// Copper helper
function CINIT(c: PUCopList; n: SmallInt): PCopList;
procedure CMOVE1(c: PUCopList; a: Pointer; b: LongInt);
procedure CWAIT1(c: PUCopList; a: SmallInt; b: SmallInt);
procedure CEND(c: PUCopList);

implementation

uses
  tagsarray;

function BestModeID(Tags: array of const): LongWord;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  Result := BestModeIDA(GetTagPtr(TagList));
end; 

function AllocSpriteData(Bitmap: PBitMap; Tags: array of const): PExtSprite;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  Result := AllocSpriteDataA(Bitmap, GetTagPtr(TagList));
end;

function ChangeExtSprite(Vp: PViewPort; Oldsprite: PExtSprite; NewSprite: PExtSprite; Tags: array of const): LongInt;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  Result := ChangeExtSpriteA(Vp, Oldsprite, NewSprite, GetTagPtr(TagList));
end;

function ExtendFontTags(Font: PTextFont; Tags: array of const): LongWord;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  Result := ExtendFont(Font, GetTagPtr(TagList));
end;

function GetExtSprite(Sprite: PExtSprite; Tags: array of const): LongInt;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  Result := GetExtSpriteA(Sprite, GetTagPtr(TagList));
end;

procedure GetRPAttrs(Rp: PRastPort; Tags: array of const);
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  GetRPAttrsA(Rp, GetTagPtr(TagList));
end;

function ObtainBestPen(Cm: PColorMap; r, g, b: LongWord; Tags: array of const): LongInt;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  Result := ObtainBestPenA(Cm, r, g, b, GetTagPtr(TagList));
end;

procedure SetRPAttrs(Rp: PRastPort; Tags: array of const);
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  SetRPAttrsA(Rp, GetTagPtr(TagList));
end;

function VideoControlTags(Cm: PColorMap; Tags: array of const): LongWord;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  {$WARNINGS OFF} // suppress unimplemented Warning
  Result := VideoControl(Cm, GetTagPtr(TagList));
  {$WARNINGS ON}
end;

function Align_Offset(x: Pointer): Pointer; inline;
begin
  Align_Offset := Pointer(PtrUInt(x) and $0F);
end;

function Is_Visible(l: PLayer): Boolean; inline;
begin
  Is_Visible := l^.Visible <> 0;
end;

procedure InitAnimate(var AnimKey: PAnimOb); inline;
begin
  AnimKey := nil;
end;

procedure RemBob(B: PBob); inline;
begin
  B^.Flags := B^.Flags or BOBSAWAY; 
end;

function RasSize(w, h: Word): Integer; inline;
begin
  Result := h * (((w + 15) shr 3) and $FFFE);
end;

function BitmapFlags_are_Extended(f: LongInt): Boolean; inline;
begin
  BitmapFlags_are_Extended := (f and BMF_CHECKMASK) = BMF_CHECKVALUE;
end;

function GetTextFontReplyPort(Font: PTextFont): PMsgPort; inline;
var
  tfe: PTextFontExtension; 
begin
	 tfe := PTextFontExtension(ExtendFont(Font, nil));
	 if Assigned(tfe) then
	   GetTextFontReplyPort := tfe^.tfe_OrigReplyPort
	 else  
	   GetTextFontReplyPort :=  Font^.tf_Message.mn_ReplyPort;
end;

function SetAOlPen(Rp: PRastPort; Pen: LongWord): LongWord; inline;
begin
  Result := SetOutlinePen(Rp, Pen);
end;

procedure BNDRYOFF (w: PRastPort); inline;
begin
  w^.Flags := w^.Flags and (not AREAOUTLINE);
end;

procedure SetAfPt(w: PRastPort; p: Pointer; n: Byte); inline;
begin
  w^.AreaPtrn := p;
  w^.AreaPtSz := n;
end;

procedure SetDrPt(w: PRastPort; p: Word); inline;
begin
  w^.LinePtrn := p;
  w^.Flags := w^.Flags or (FRST_DOT or $10);
  w^.linpatcnt := 15;
end;

procedure SetOPen(w: PRastPort; c: Byte); inline;
begin
  w^.AOlPen := c;
  w^.Flags := w^.Flags or AREAOUTLINE;
end;

{ This function is fine, but FOR OS39 the SetWriteMask() gfx function
  should be prefered because it SHOULD operate WITH gfx boards as well.
  At least I hope it does.... }
procedure SetWrMsk(w: PRastPort; m: Byte); inline;
begin
  w^.Mask := m;
end;

procedure DrawCircle(Rp: PRastPort; xCenter, yCenter, r: LongInt); inline;
begin
  DrawEllipse(Rp, xCenter, yCenter, r, r);
end;

function AreaCircle(Rp: PRastPort; xCenter, yCenter, r: SmallInt): LongWord; inline;
begin
  Result := AreaEllipse(Rp, xCenter, yCenter, r, r);
end;

function CINIT(c: PUCopList; n: SmallInt): PCopList; inline;
begin
  Result := UCopperListInit(c, n);
end;

procedure CMOVE1(c: PUCopList; a: Pointer; b: LongInt);
begin
  CMove(c, a, b);
  CBump(c);
end;

procedure CWait1(c: PUCopList; a: SmallInt; b: SmallInt); inline;
begin
  CWait(c, a, b);
  CBump(c);
end;

procedure CEND(c: PUCopList); inline;
begin
  CWAIT(c, 10000, 255);
end;

// Library Functions

procedure AddAnimOb(AnOb: PAnimOb; AnKey: PPAnimOb; Rp: PRastPort);
type
  TLocalCall = procedure(AnOb: PAnimOb; AnKey: PPAnimOb; Rp: PRastPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 26));
  Call(AnOb, AnKey, Rp, GfxBase);
end;

procedure AddBob(Bob: PBob; Rp: PRastPort);
type
  TLocalCall = procedure(Bob: PBob; Rp: PRastPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 16));
  Call(bob, Rp, GfxBase);
end;

function AddDisplayDriverA(GfxHidd: APTR; Tags: PTagItem): LongInt;
type
  TLocalCall = function(GfxHidd: APTR; Tags: PTagItem; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 181));
  Result := Call(GfxHidd, Tags, GfxBase);
end;

procedure AddFont(TextFont: PTextFont);
type
  TLocalCall = procedure(TextFont: PTextFont; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 80));
  Call(TextFont, GfxBase);
end;

procedure AddVSprite(VSprite: PVSprite; Rp: PRastPort);
type
  TLocalCall = procedure(VSprite: PVSprite; Rp: PRastPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 17));
  Call(VSprite, Rp, GfxBase);
end;

function AllocBitMap(Sizex, Sizey, Depth, Flags: LongWord; Friend_Bitmap: PBitMap): PBitMap;
type
  TLocalCall = function(Sizex, Sizey, Depth, Flags: LongWord; Friend_Bitmap: PBitMap; Base: Pointer): PBitMap; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 153));
  Result := Call(Sizex, Sizey, Depth, Flags, Friend_Bitmap, GfxBase);
end;

function AllocDBufInfo(Vp: PViewPort): PDBufInfo;
type
  TLocalCall = function(Vp: PViewPort; Base: Pointer): PDBufInfo; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 161));
  Result := Call(Vp, GfxBase);
end;

function AllocRaster(Width, Height: LongWord): TPlanePtr;
type
  TLocalCall = function(Width, Height: LongWord; Base: Pointer): TPlanePtr; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 82));
  Result := Call(Width, Height, GfxBase);
end;

function AllocSpriteDataA(Bitmap: PBitMap; TagList: PTagItem): PExtSprite;
type
  TLocalCall = function(Bitmap: PBitMap; TagList: PTagItem; Base: Pointer): PExtSprite; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 170));
  Result := Call(Bitmap, TagList, GfxBase);
end;

function AndRectRect(Rect1: PRectangle; Rect2: PRectangle; Intersect: PRectangle): LongBool;
type
  TLocalCall = function(Rect1: PRectangle; Rect2: PRectangle; Intersect: PRectangle; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 193));
  Result := Call(Rect1, Rect2, Intersect, GfxBase);
end;

procedure AndRectRegion(Reg: PRegion; Rect :PRectangle);
type
  TLocalCall = procedure(Reg: PRegion; Rect :PRectangle; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 84));
  Call(Reg, Rect, GfxBase);
end;

function AndRegionRegion(SrcRegion: PRegion; DestRegion: PRegion): LongBool;
type
  TLocalCall = function(SrcRegion: PRegion; DestRegion: PRegion; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 104));
  Result := Call(SrcRegion, DestRegion, GfxBase);
end;

procedure AndRectRegionND(Reg: PRegion; Rect: PRectangle);
type
  TLocalCall = procedure(Reg: PRegion; Rect: PRectangle; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 107));
  Call(Reg, Rect, GfxBase);
end;

function AndRegionRegionND(R1: PRegion; R2: PRegion): PRegion;
type
  TLocalCall = function(R1: PRegion; R2: PRegion; Base: Pointer): PRegion; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 108));
  Result := Call(R1, R2, GfxBase);
end;

procedure Animate(AnKey: PPAnimOb; Rp: PRastPort);
type
  TLocalCall = procedure(AnKey: PPAnimOb; Rp: PRastPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 27));
  Call(AnKey, Rp, GfxBase);
end;

function AreaDraw(Rp: PRastPort; x, y: SmallInt): LongWord;
type
  TLocalCall = function(Rp: PRastPort; x, y: SmallInt; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 43));
  Result := Call(Rp, x, y, GfxBase);
end;

function AreaEllipse(Rp: PRastPort; xCenter, yCenter, a, b: SmallInt): LongWord;
type
  TLocalCall = function(Rp: PRastPort; xCenter, yCenter, a, b: SmallInt; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 31));
  Result := Call(Rp, xCenter, yCenter, a, b, GfxBase);
end;

function AreaEnd(Rp: PRastPort) : LongInt;
type
  TLocalCall = function(Rp: PRastPort; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 44));
  Result := Call(Rp, GfxBase);
end;

function AreaMove(Rp: PRastPort; x, y: SmallInt): LongWord;
type
  TLocalCall = function(Rp: PRastPort; x, y: SmallInt; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 42));
  Result := Call(Rp, x, y, GfxBase);
end;

function AreRegionsEqual(R1: PRegion; R2: PRegion): LongBool;
type
  TLocalCall = function(R1: PRegion; R2: PRegion; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 189));
  Result := Call(R1, R2, GfxBase);
end;

procedure AskFont(Rp: PRastPort; TextAttr: PTextAttr);
type
  TLocalCall = procedure(Rp: PRastPort; TextAttr: PTextAttr; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 79));
  Call(Rp, TextAttr, GfxBase);
end;

function AskSoftStyle(Rp: PRastPort) : LongWord;
type
  TLocalCall = function(Rp: PRastPort; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 14));
  Result := Call(Rp, GfxBase);
end;

function AttachPalExtra(Cm: PColorMap; Vp: PViewPort): LongInt;
type
  TLocalCall = function(Cm: PColorMap; Vp: PViewPort; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 139));
  Result := Call(Cm, Vp, GfxBase);
end;

function AttemptLockLayerRom(l: PLayer): LongBool;
type
  TLocalCall = function(l: PLayer; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 109));
  Result := Call(l, GfxBase);
end;

function BestModeIDA(Tags: PTagItem): LongWord;
type
  TLocalCall = function(Tags: PTagItem; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 175));
  Result := Call(Tags, GfxBase);
end;

procedure BitMapScale(BitScaleArgs: PBitScaleArgs);
type
  TLocalCall = procedure(BitScaleArgs: PBitScaleArgs; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 113));
  Call(BitScaleArgs, GfxBase);
end;

function BltBitMap(const SrcBitMap: PBitMap; xSrc, ySrc: LongInt; DestBitMap: PBitMap; xDest, yDest, xSize, ySize: LongInt; MinTerm : LongWord; Mask: LongWord; TempA: TPlanePtr): LongInt; // 5
type
  TLocalCall = function(const SrcBitMap: PBitMap; xSrc, ySrc: LongInt; DestBitMap: PBitMap; xDest, yDest, xSize, ySize: LongInt; MinTerm : LongWord; Mask: LongWord; TempA: TPlanePtr; Base: Pointer): LongInt ; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 5));
  Result := Call(SrcBitMap, xSrc, ySrc, DestBitMap, xDest, yDest, xSize, ySize, MinTerm, Mask, TempA, GfxBase);
end;

procedure BltBitMapRastPort(const SrcBitMap: PBitMap; xSrc, ySrc: LongInt; DestRP: PRastPort; xDest, yDest, xSize, ySize: LongInt; MinTerm: LongWord);
type
  TLocalCall = procedure(const SrcBitMap: PBitMap; xSrc, ySrc: LongInt; DestRP: PRastPort; xDest, yDest, xSize, ySize: LongInt; MinTerm: LongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 101));
  Call(SrcBitMap, xSrc, ySrc, DestRP, xDest, yDest, xSize, ySize, MinTerm, GfxBase);
end;

procedure BltClear(MemBlock: Pointer; ByteCount: LongWord; Flags: LongWord);
type
  TLocalCall = procedure(MemBlock: Pointer; ByteCount: LongWord; Flags: LongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 50));
  Call(MemBlock, ByteCount, Flags, GfxBase);
end;

procedure BltMaskBitMapRastPort(SrcBitMap: PBitMap; xSrc, ySrc: LongInt; DestRP: PRastPort; xDest, yDest, xSize, ySize: LongInt; MinTerm: LongWord; bltMask: TPlanePtr);
type
  TLocalCall = procedure(SrcBitMap: PBitMap; xSrc, ySrc: LongInt; DestRP: PRastPort; xDest, yDest, xSize, ySize: LongInt; MinTerm: LongWord; bltMask: TPlanePtr; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 106));
  Call(SrcBitMap, xSrc, ySrc, DestRP, xDest, yDest, xSize, ySize, MinTerm, bltMask, GfxBase);
end;

procedure BltPattern(Rp: PRastPort; Mask: TPlanePtr; xMin, yMin, xMax, yMax: LongInt; ByteCnt: LongWord);
type
  TLocalCall = procedure(Rp: PRastPort; Mask: TPlanePtr; xMin, yMin, xMax, yMax: LongInt; ByteCnt: LongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 52));
  Call(Rp, Mask, xMin, yMin, xMax, yMax, ByteCnt, GfxBase);
end;

procedure BltRastPortBitMap(SrcRastPort: PRastPort; xSrc, ySrc: LongInt; DestBitMap: PBitMap; xDest, yDest, xSize, ySize, MinTerm: LongWord);
type
  TLocalCall = procedure(SrcRastPort: PRastPort; xSrc, ySrc: LongInt; DestBitMap: PBitMap; xDest, yDest, xSize, ySize, MinTerm: LongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 196));
  Call(SrcRastPort, xSrc, ySrc, DestBitMap, xDest, yDest, xSize, ySize, MinTerm, GfxBase);
end;

procedure BltTemplate(const Source: TPlanePtr; xSrc, srcMod: LongInt; DestRP: PRastPort; xDest, yDest, xSize, ySize: LongInt);
type
  TLocalCall = procedure(const Source: TPlanePtr; xSrc, srcMod: LongInt; DestRP: PRastPort; xDest, yDest, xSize, ySize: LongInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 6));
  Call(Source, xSrc, srcMod, DestRP, xDest, yDest, xSize, ySize, GfxBase);
end;

function CalcIVG(View: PView; ViewPort: PViewPort): Word;
type
  TLocalCall = function(View: PView; ViewPort: PViewPort; Base: Pointer): Word; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 138));
  Result := Call(View, ViewPort, GfxBase);
end;

procedure CBump(CopList: PUCopList);
type
  TLocalCall = procedure(CopList: PUCopList; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 62));
  Call(CopList, GfxBase);
end;

function ChangeExtSpriteA(Vp: PViewPort; Oldsprite: PExtSprite; NewSprite: PExtSprite; Tags: PTagItem): LongInt;
type
  TLocalCall = function(Vp: PViewPort; Oldsprite: PExtSprite; NewSprite: PExtSprite; Tags: PTagItem; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 171));
  Result := Call(Vp, OldSprite, NewSprite, Tags, GfxBase);
end;

procedure ChangeSprite(Vp: PViewPort; s: PSimpleSprite; NewData: Pointer);
type
  TLocalCall = procedure(Vp: PViewPort; s: PSimpleSprite; NewData: Pointer; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 70));
  Call(Vp, s, NewData, GfxBase);
end;

procedure ChangeVPBitMap(Vp: PViewPort; Bm: PBitMap; Db: PDBufInfo);
type
  TLocalCall = procedure(Vp: PViewPort; Bm: PBitMap; Db: PDBufInfo; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 157));
  Call(Vp, Bm, db, GfxBase);
end;

procedure ClearEOL(Rp: PRastPort);
type
  TLocalCall = procedure(Rp: PRastPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 7));
  Call(Rp, GfxBase);
end;

function ClearRectRegion(Reg: PRegion; Rect: PRectangle): LongBool;
type
  TLocalCall = function(Reg: PRegion; Rect: PRectangle; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 87));
  Result := Call(Reg, Rect, GfxBase);
end;

function ClearRectRegionND(Reg: PRegion; Rect: PRectangle): PRegion;
type
  TLocalCall = function(Reg: PRegion; Rect: PRectangle; Base: Pointer): PRegion; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 124));
  Result := Call(Reg, Rect, GfxBase);
end;

function ClearRegionRegion(R1: PRegion; R2: PRegion): LongBool;
type
  TLocalCall = function(R1: PRegion; R2: PRegion; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 187));
  Result := Call(R1, R2, GfxBase);
end;

function ClearRegionRegionND(R1: PRegion; R2: PRegion): PRegion;
type
  TLocalCall = function(R1: PRegion; R2: PRegion; Base: Pointer): PRegion; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 141));
  Result := Call(R1, R2, GfxBase);
end;

procedure ClearRegion(Region: PRegion);
type
  TLocalCall = procedure(Region: PRegion; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 88));
  Call(Region, GfxBase);
end;

procedure ClearScreen(Rp: PRastPort);
type
  TLocalCall = procedure(Rp: PRastPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 8));
  Call(Rp, GfxBase);
end;

procedure ClipBlit(SrcRP: PRastPort; xSrc, ySrc: LongInt; DestRP: PRastPort; xDest, yDest, xSize, ySize: LongInt; MinTerm: Byte);
type
  TLocalCall = procedure(SrcRP: PRastPort; xSrc, ySrc: LongInt; DestRP: PRastPort; xDest, yDest, xSize, ySize: LongInt; MinTerm: Byte; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 92));
  Call(SrcRP, xSrc, ySrc, DestRP, xDest, yDest, xSize, ySize, MinTerm, GfxBase);
end;

procedure CloseFont(TextFont: PTextFont);
type
  TLocalCall = procedure(TextFont: PTextFont; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 13));
  Call(TextFont, GfxBase);
end;

function CloseMonitor(Monitor_Spec: PMonitorSpec): LongInt;
type
  TLocalCall = function(Monitor_Spec: PMonitorSpec; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 120));
  Result := Call(Monitor_Spec, GfxBase);
end;

procedure CMove(CopList: PUCopList; Reg: Pointer; Value: LongInt);
type
  TLocalCall = procedure(CopList: PUCopList; Reg: Pointer; Value: LongInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 62));
  Call(CopList, Reg, Value, GfxBase);
end;

function CoerceMode(RealViewPort: PViewPort; MonitorID: LongWord; Flags: LongWord): LongWord;
type
  TLocalCall = function(RealViewPort: PViewPort; MonitorID: LongWord; Flags: LongWord; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 156));
  Result := Call(RealViewPort, MonitorID, Flags, GfxBase);
end;

function CopyRegion(Region: PRegion): PRegion;
type
  TLocalCall = function(Region: PRegion; Base: Pointer): PRegion; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 188));
  Result := Call(Region, GfxBase);
end;

procedure CopySBitMap(l: PLayer);
type
  TLocalCall = procedure(l: PLayer; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 75));
  Call(l, GfxBase);
end;

function CreateRastPort(): PRastPort;
type
  TLocalCall = function(Base: Pointer): PRastPort; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 177));
  Result := Call(GfxBase);
end;

function CloneRastPort(Rp: PRastPort): PRastPort;
type
  TLocalCall = function(Rp: PRastPort; Base: Pointer): PRastPort; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 178));
  Result := Call(Rp, GfxBase);
end;

procedure DeinitRastPort(Rp: PRastPort);
type
  TLocalCall = procedure(Rp: PRastPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 179));
  Call(Rp, GfxBase);
end;

procedure FreeRastPort(Rp: PRastPort);
type
  TLocalCall = procedure(Rp: PRastPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 180));
  Call(Rp, GfxBase);
end;

procedure CWait(CopList: PUCopList; V: SmallInt; H: SmallInt);
type
  TLocalCall = procedure(CopList: PUCopList; V: SmallInt; H: SmallInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 63));
  Call(CopList, V, H, GfxBase);
end;

procedure DisownBlitter;
type
  TLocalCall = procedure(Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 77));
  Call(GfxBase);
end;

procedure DisposeRegion(Region: PRegion);
type
  TLocalCall = procedure(Region: PRegion; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 89));
  Call(Region, GfxBase);
end;

procedure DoCollision(Rp: PRastPort);
type
  TLocalCall = procedure(Rp: PRastPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 18));
  Call(Rp, GfxBase);
end;

function DoPixelFunc(Rp: PRastPort; x, y: LongInt; Render_Func: Pointer; FuncData: APTR; Do_Update: LongBool): LongInt;
type
  TLocalCall = function(Rp: PRastPort;  x, y: LongInt; Render_Func: Pointer; FuncData: APTR; Do_Update: LongBool; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 185));
  Result := Call(Rp, x, y, Render_Func, FuncData, Do_Update, GfxBase);
end;

function DoRenderFunc(Rp: PRastPort; Src: PPoint; Rr: PRectangle; Render_Func: Pointer; FuncData: APTR; Do_Update: LongBool): LongInt;
type
  TLocalCall = function(Rp: PRastPort; Src: PPoint; Rr: PRectangle; Render_Func: Pointer; FuncData: APTR; Do_Update: LongBool; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 184));
  Result := Call(Rp, Src, Rr, Render_Func, FuncData, Do_Update, GfxBase);
end;

procedure Draw(Rp: PRastPort; x, y: LongInt);
type
  TLocalCall = procedure(Rp: PRastPort; x, y: LongInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 41));
  Call(Rp, x, y, GfxBase);
end;

procedure DrawEllipse(Rp: PRastPort; xCenter, yCenter, a, b: LongInt);
type
  TLocalCall = procedure(Rp: PRastPort; xCenter, yCenter, a, b: LongInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 30));
  Call(Rp, xCenter, yCenter, a, b, GfxBase);
end;

procedure DrawGList(Rp: PRastPort; Vp: PViewPort);
type
  TLocalCall = procedure(Rp: PRastPort; Vp: PViewPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 19));
  Call(Rp, Vp, GfxBase);
end;

procedure EraseRect(Rp: PRastPort; xMin, yMin, xMax, yMax: LongInt);
type
  TLocalCall = procedure(Rp: PRastPort; xMin, yMin, xMax, yMax: LongInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 135));
  Call(Rp, xMin, yMin, xMax, yMax, GfxBase);
end;

function ExtendFont(Font: PTextFont; FontTags: PTagItem): LongWord;
type
  TLocalCall = function(Font: PTextFont; FontTags: PTagItem; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 136));
  Result := Call(Font, FontTags, GfxBase);
end;

function FillRectPenDrMd(Rp: PRastPort; x1, y1, x2, y2: LongInt; Pix: Pointer{HIDDT_Pixel}; drmd: Pointer{HIDDT_DrawMode}; Do_Update: LongBool): LongInt;
type
  TLocalCall = function(Rp: PRastPort; x1, y1, x2, y2: LongInt; Pix: Pointer{HIDDT_Pixel}; drmd: Pointer{HIDDT_DrawMode}; Do_Update: LongBool; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 183));
  Result := Call(Rp, x1, y1, x2, y2, Pix, drmd, Do_Update, GfxBase);
end;

function FindColor(Cm: PColorMap; r, g, b, MaxPen: LongWord): LongWord;
type
  TLocalCall = function(Cm: PColorMap; r, g, b, MaxPen: LongWord; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 168));
  Result := Call(cm, r, g, b, MaxPen, GfxBase);
end;

function FindDisplayInfo(ID: LongWord): DisplayInfoHandle;
type
  TLocalCall = function(ID: LongWord; Base: Pointer): DisplayInfoHandle; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 121));
  Result := Call(ID, GfxBase);
end;

function Flood(Rp: PRastPort; Mode: LongWord; x, y : LongInt): LongBool;
type
  TLocalCall = function(Rp: PRastPort; Mode: LongWord; x, y : LongInt; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 55));
  Result := Call(Rp, mode, x, y, GfxBase);
end;

procedure FontExtent(Font: PTextFont; FontExtent: PTextExtent);
type
  TLocalCall = procedure(Font: PTextFont; FontExtent: PTextExtent; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 127));
  Call(Font, FontExtent, GfxBase);
end;

procedure FreeBitMap(Bm : PBitMap);
type
  TLocalCall = procedure(Bm : PBitMap; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 154));
  Call(Bm, GfxBase);
end;

procedure FreeColorMap(ColorMap: PColorMap);
type
  TLocalCall = procedure(ColorMap: PColorMap; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 96));
  Call(ColorMap, GfxBase);
end;

procedure FreeCopList(CopList: PCopList);
type
  TLocalCall = procedure(CopList: PCopList; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 91));
  Call(CopList, GfxBase);
end;

procedure FreeCprList(CprList: PCprlist);
type
  TLocalCall = procedure(CprList: PCprlist; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 94));
  Call(CprList, GfxBase);
end;

procedure FreeDBufInfo(Dbi: PDBufInfo);
type
  TLocalCall = procedure(Dbi: PDBufInfo; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 162));
  Call(Dbi, GfxBase);
end;

procedure FreeGBuffers(AnOb: PAnimOb; Rp: PRastPort; db: LongBool);
type
  TLocalCall = procedure(AnOb: PAnimOb; Rp: PRastPort; db: LongBool; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 100));
  Call(AnOb, Rp, db, GfxBase);
end;

procedure FreeRaster(p: TPlanePtr; Width, Height: LongWord);
type
  TLocalCall = procedure(p: TPlanePtr; Width, Height: LongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 83));
  Call(p, Width, Height, GfxBase);
end;

procedure FreeSprite(Pick: SmallInt);
type
  TLocalCall = procedure(Pick: SmallInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 69));
  Call(Pick, GfxBase);
end;

procedure FreeSpriteData(ExtSp: PExtSprite);
type
  TLocalCall = procedure(ExtSp: PExtSprite; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 172));
  Call(ExtSp, GfxBase);
end;

procedure FreeVPortCopLists(Vp : PViewPort);
type
  TLocalCall = procedure(Vp : PViewPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 91));
  Call(Vp, GfxBase);
end;

function GetAPen(Rp: PRastPort): LongWord;
type
  TLocalCall = function(Rp: PRastPort; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 143));
  Result := Call(Rp, GfxBase);
end;

function GetBitMapAttr(BitMap: PBitMap; Attribute: LongWord): IPTR;
type
  TLocalCall = function(BitMap: PBitMap; Attribute: LongWord; Base: Pointer): IPTR; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 160));
  Result := Call(BitMap, Attribute, GfxBase);
end;

function GetBPen(Rp: PRastPort): LongWord;
type
  TLocalCall = function(Rp: PRastPort; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 144));
  Result := Call(Rp, GfxBase);
end;

function GetColorMap(Entries: LongWord): PColorMap;
type
  TLocalCall = function(Entries: LongWord; Base: Pointer): PColorMap; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 95));
  Result := Call(Entries, GfxBase);
end;

function GetDisplayInfoData(Handle: DisplayInfoHandle; Buf: PChar; Size: LongWord; TagID: LongWord; ID: LongWord): LongWord;
type
  TLocalCall = function(Handle: DisplayInfoHandle; Buf: PChar; Size: LongWord; TagID: LongWord; ID: LongWord; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 126));
  Result := Call(Handle, Buf, Size, TagID, ID, GfxBase);
end;

function GetDrMd(Rp: PRastPort): LongWord;
type
  TLocalCall = function(Rp: PRastPort; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 145));
  Result := Call(Rp, GfxBase);
end;

function GetExtSpriteA(Sprite: PExtSprite; Tags: PTagItem): LongInt;
type
  TLocalCall = function(Sprite: PExtSprite; Tags: PTagItem; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 155));
  Result := Call(Sprite, Tags, GfxBase);
end;

function GetGBuffers(AnOb: PAnimOb; Rp: PRastPort; Db: LongBool): LongBool;
type
  TLocalCall = function(AnOb: PAnimOb; Rp: PRastPort; Db: LongBool; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 28));
  Result := Call(AnOb, Rp, Db, GfxBase);
end;

function GetOutlinePen(Rp: PRastPort): LongWord;
type
  TLocalCall = function(Rp: PRastPort; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 146));
  Result := Call(Rp, GfxBase);
end;

procedure GetRGB32(Cm: PColorMap; FirstColor: LongWord; NColors: LongWord; Table: PLongWord);
type
  TLocalCall = procedure(Cm: PColorMap; FirstColor: LongWord; NColors: LongWord; Table: PLongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 150));
  Call(Cm, FirstColor, NColors, Table, GfxBase);
end;

function GetRGB4(ColorMap: PColorMap; Entry: LongInt): LongWord;
type
  TLocalCall = function(ColorMap: PColorMap; Entry: LongInt; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 97));
  Result := Call(ColorMap, Entry, GfxBase);
end;

procedure GetRPAttrsA(Rp: PRastPort; Tags: PTagItem);
type
  TLocalCall = procedure(Rp: PRastPort; Tags: PTagItem; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 174));
  Call(Rp, Tags, GfxBase);
end;

function GetSprite(Sprite: PSimpleSprite; Pick: SmallInt): SmallInt;
type
  TLocalCall = function(Sprite: PSimpleSprite; Pick: SmallInt; Base: Pointer): SmallInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 68));
  Result := Call(Sprite, Pick, GfxBase);
end;

function GetVPModeID(Vp: PViewPort): LongWord;
type
  TLocalCall = function(Vp: PViewPort; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 132));
  Result := Call(Vp, GfxBase);
end;

procedure GfxAssociate(Pointer_: Pointer; Node: PExtendedNode);
type
  TLocalCall = procedure(Pointer_: Pointer; Node: PExtendedNode; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 112));
  Call(Pointer_, Node, GfxBase);
end;

procedure GfxFree(Node: PExtendedNode);
type
  TLocalCall = procedure(Node: PExtendedNode; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 111));
  Call(Node, GfxBase);
end;

function GfxLookUp(Pointer_: Pointer): PExtendedNode;
type
  TLocalCall = function(Pointer_: Pointer; Base: Pointer): PExtendedNode; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 117));
  Result := Call(Pointer_, GfxBase);
end;

function GfxNew(Node_Type: LongWord): PExtendedNode;
type
  TLocalCall = function(Node_Type: LongWord; Base: Pointer): PExtendedNode; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 110));
  Result := Call(Node_Type, GfxBase);
end;

procedure InitArea(AreaInfo: PAreaInfo; Buffer: Pointer; MaxVectors: SmallInt);
type
  TLocalCall = procedure(AreaInfo: PAreaInfo; Buffer: Pointer; MaxVectors: SmallInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 47));
  Call(AreaInfo, Buffer, MaxVectors, GfxBase);
end;

procedure InitBitMap(Bm: PBitMap; Depth: ShortInt; Width, Height: Word);
type
  TLocalCall = procedure(Bm: PBitMap; Depth: ShortInt; Width, Height: Word; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 65));
  Call(Bm, Depth, Width, Height, GfxBase);
end;

procedure InitGels(Head: PVSprite; Tail: PVSprite; GelsInfo: PGelsInfo);
type
  TLocalCall = procedure(Head: PVSprite; Tail: PVSprite; GelsInfo: PGelsInfo; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 20));
  Call(Head, Tail, GelsInfo, GfxBase);
end;

procedure InitGMasks(AnOb: PAnimOb);
type
  TLocalCall = procedure(AnOb: PAnimOb; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 29));
  Call(AnOb, GfxBase);
end;

procedure InitMasks(VSprite: PVSprite);
type
  TLocalCall = procedure(VSprite: PVSprite; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 22));
  Call(VSprite, GfxBase);
end;

procedure InitRastPort(Rp: PRastPort);
type
  TLocalCall = procedure(Rp: PRastPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 33));
  Call(Rp, GfxBase);
end;

function InitTmpRas(TmpRas: PTmpRas; Buffer: Pointer; Size: LongWord): PTmpRas;
type
  TLocalCall = function(TmpRas: PTmpRas; Buffer: Pointer; Size: LongWord; Base: Pointer): PTmpRas; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 78));
  Result := Call(TmpRas, Buffer, Size, GfxBase);
end;

procedure InitView(View: PView);
type
  TLocalCall = procedure(View: PView; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 60));
  Call(View, GfxBase);
end;

procedure InitVPort(Vp: PViewPort);
type
  TLocalCall = procedure(Vp: PViewPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 34));
  Call(Vp, GfxBase);
end;

function IsPointInRegion(Reg: PRegion; x, y: SmallInt): LongBool;
type
  TLocalCall = function(Reg: PRegion; x, y: SmallInt; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 190));
  Result := Call(Reg, x, y, GfxBase);
end;


procedure LoadRGB32(Vp: PViewPort;const Table: PLongWord);
type
  TLocalCall = procedure(Vp : PViewPort;const Table: PLongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 147));
  Call(Vp, table, GfxBase);
end;

procedure LoadRGB4(Vp: PViewPort; Colors: PWord; Count: LongInt);
type
  TLocalCall = procedure(Vp: PViewPort; Colors: PWord; Count: LongInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 32));
  Call(Vp, Colors, Count, GfxBase);
end;

procedure LoadView(View: PView);
type
  TLocalCall = procedure(View: PView; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 37));
  Call(View, GfxBase);
end;

procedure LockLayerRom(l: PLayer);
type
  TLocalCall = procedure(l: PLayer; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 72));
  Call(l, GfxBase);
end;

function MakeVPort(View: PView; ViewPort: PViewPort) : LongWord;
type
  TLocalCall = function(View: PView; ViewPort: PViewPort; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 36));
  Result := Call(View, ViewPort, GfxBase);
end;

function ModeNotAvailable(ModeID: LongWord): LongWord;
type
  TLocalCall = function(ModeID: LongWord; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 133));
  Result := Call(ModeID, GfxBase);
end;

procedure Move(Rp: PRastPort; x, y: SmallInt);
type
  TLocalCall = procedure(Rp: PRastPort; x, y: SmallInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 40));
  Call(Rp, x, y, GfxBase);
end;

procedure MoveSprite(Vp: PViewPort; Sprite: PSimpleSprite; x, y: SmallInt);
type
  TLocalCall = procedure(Vp: PViewPort; Sprite: PSimpleSprite; x, y: SmallInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 71));
  Call(Vp, Sprite, x, y, GfxBase);
end;

function MrgCop(View: PView): LongWord;
type
  TLocalCall = function(View: PView; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 35));
  Result := Call(View, GfxBase);
end;

function NewRectRegion(MinX, MinY, MaxX, MaxY: SmallInt): PRegion;
type
  TLocalCall = function(MinX, MinY, MaxX, MaxY: SmallInt; Base: Pointer): PRegion; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 194));
  Result := Call(MinX, MinY, MaxX, MaxY, GfxBase);
end;

function NewRegion: PRegion;
type
  TLocalCall = function(Base: Pointer): PRegion; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 86));
  Result := Call(GfxBase);
end;

function NextDisplayInfo(Last_ID: LongWord): LongWord;
type
  TLocalCall = function(Last_ID: LongWord; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 122));
  Result := Call(Last_ID, GfxBase);
end;

function ObtainBestPenA(Cm: PColorMap; r, g, b: LongWord; Tags: PTagItem): LongInt;
type
  TLocalCall = function(Cm: PColorMap; r, g, b: LongWord; Tags: PTagItem; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 140));
  Result := Call(Cm, r, g, b, Tags, GfxBase);
end;

function ObtainPen(Cm: PColorMap; n, r, g, b: LongWord; Flags: LongWord): LongInt;
type
  TLocalCall = function(Cm: PColorMap; n, r, g, b: LongWord; Flags: LongWord; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 159));
  Result := Call(cm, n, r, g, b, Flags, GfxBase);
end;

function OpenFont(TextAttr: PTextAttr): PTextFont;
type
  TLocalCall = function(TextAttr: PTextAttr; Base: Pointer): PTextFont; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 12));
  Result := Call(TextAttr, GfxBase);
end;

function OpenMonitor(MonitorName: STRPTR; DisplayID: LongWord): PMonitorSpec;
type
  TLocalCall = function(MonitorName: STRPTR; DisplayID: LongWord; Base: Pointer): PMonitorSpec; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 119));
  Result := Call(MonitorName, DisplayID, GfxBase);
end;

function OrRectRegion(Reg: PRegion; Rect: PRectangle): LongBool;
type
  TLocalCall = function(Reg: PRegion; Rect: PRectangle; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 85));
  Result := Call(Reg, Rect, GfxBase);
end;

function OrRectRegionND(Reg: PRegion; Rect: PRectangle): PRegion;
type
  TLocalCall = function(Reg: PRegion; Rect: PRectangle; Base: Pointer): PRegion; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 123));
  Result := Call(Reg, Rect, GfxBase);
end;

function OrRegionRegion(SrcRegion: PRegion; DestRegion: PRegion): LongBool;
type
  TLocalCall = function(SrcRegion: PRegion; DestRegion: PRegion; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 102));
  Result := Call(SrcRegion, DestRegion, GfxBase);
end;

function OrRegionRegionND(R1: PRegion; R2: PRegion): PRegion;
type
  TLocalCall = function(R1: PRegion; R2: PRegion; Base: Pointer): PRegion; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 125));
  Result := Call(R1, R2, GfxBase);
end;

procedure OwnBlitter;
type
  TLocalCall = procedure(Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 76));
  Call(GfxBase);
end;

procedure PolyDraw(Rp: PRastPort; Count: LongInt; PolyTable: PSmallInt);
type
  TLocalCall = procedure(Rp: PRastPort; Count: LongInt; PolyTable: PSmallInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 56));
  Call(Rp, Count, PolyTable, GfxBase);
end;

procedure QBlit(Blit: PBltNode);
type
  TLocalCall = procedure(Blit: PBltNode; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 46));
  Call(Blit, GfxBase);
end;

procedure QBSBlit(Blit: PBltNode);
type
  TLocalCall = procedure(blit : pbltnode; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 49));
  Call(Blit, GfxBase);
end;

function ReadPixel(Rp: PRastPort; x, y: LongInt): LongInt;
type
  TLocalCall = function(Rp: PRastPort; x, y: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 53));
  Result := Call(Rp, x, y, GfxBase);
end;

function ReadPixelArray8(Rp: PRastPort; xStart, yStart, xStop, yStop: LongWord; Array_: PByte; TempRp: PRastPort): LongInt;
type
  TLocalCall = function(Rp: PRastPort; xStart, yStart, xStop, yStop: LongWord; Array_: PByte; TempRp: PRastPort; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 130));
  Result := Call(Rp, xStart, yStart, xStop, yStop, Array_, TempRp, GfxBase);
end;

function ReadPixelLine8(Rp: PRastPort; xStart, yStart, Width: LongWord; Array_: PByte; TempRP: PRastPort): LongInt;
type
  TLocalCall = function(Rp: PRastPort; xStart, yStart, Width: LongWord; Array_: PByte; TempRP: PRastPort; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 128));
  Result := Call(Rp, xStart, yStart, Width, Array_, TempRP, GfxBase);
end;

procedure RectFill(Rp: PRastPort; xMin, yMin, xMax, yMax : LongInt);
type
  TLocalCall = procedure(Rp: PRastPort; xMin, yMin, xMax, yMax : LongInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 51));
  Call(Rp, xMin, yMin, xMax, yMax, GfxBase);
end;

procedure ReleasePen(Cm: PColorMap; n: LongWord);
type
  TLocalCall = procedure(Cm: PColorMap; n: LongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 158));
  Call(Cm, n, GfxBase);
end;

procedure RemFont(TextFont: PTextFont);
type
  TLocalCall = procedure(TextFont: PTextFont; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 81));
  Call(TextFont, GfxBase);
end;

procedure RemIBob(Bob: PBob; Rp: PRastPort; Vp: PViewPort);
type
  TLocalCall = procedure(Bob: PBob; Rp: PRastPort; Vp: PViewPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 22));
  Call(Bob, Rp, Vp, GfxBase);
end;

procedure RemVSprite(VSprite: PVSprite);
type
  TLocalCall = procedure(VSprite: PVSprite; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 23));
  Call(VSprite, GfxBase);
end;

function ScalerDiv(Factor: LongWord; Numerator: LongWord; Denominator: LongWord): Word;
type
  TLocalCall = function(Factor: LongWord; Numerator: LongWord; Denominator: LongWord; Base: Pointer): Word; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 114));
  Result := Call(Factor, Numerator, Denominator, GfxBase);
end;

procedure ShowImminentReset;
type
  TLocalCall = procedure(Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 197));
  Call(GfxBase);
end;

procedure ScrollRaster(Rp: PRastPort; dx, dy, xMin, yMin, xMax, yMax: LongInt);
type
  TLocalCall = procedure(Rp: PRastPort; dx, dy, xMin, yMin, xMax, yMax: LongInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 66));
  Call(Rp, dx, dy, xMin, yMin, xMax, yMax, GfxBase);
end;

procedure ScrollRasterBF(Rp: PRastPort; dx, dy, xMin, yMin, xMax, yMax: LongInt);
type
  TLocalCall = procedure(Rp: PRastPort; dx, dy, xMin, yMin, xMax, yMax: LongInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 167));
  Call(Rp, dx, dy, xMin, yMin, xMax, yMax, GfxBase);
end;

function ScrollRegion(Region: PRegion; Rect: PRectangle; Dx, Dy: SmallInt): LongBool;
type
  TLocalCall = function(Region: PRegion; Rect: PRectangle; Dx, Dy: SmallInt; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 191));
  Result := Call(Region, Rect, Dx, Dy, GfxBase);
end;

procedure ScrollVPort(Vp : PViewPort);
type
  TLocalCall = procedure(Vp : PViewPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 98));
  Call(Vp, GfxBase);
end;

procedure SetABPenDrMd(Rp: PRastPort; APen: LongWord; BPen: LongWord; DrawMode: LongWord);
type
  TLocalCall = procedure(Rp: PRastPort; APen: LongWord; BPen: LongWord; DrawMode: LongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 149));
  Call(Rp, APen, BPen, DrawMode, GfxBase);
end;

procedure SetAPen(Rp: PRastPort; Pen: LongWord);
type
  TLocalCall = procedure(Rp: PRastPort; Pen: LongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 57));
  Call(Rp, Pen, GfxBase);
end;

procedure SetBPen(Rp: PRastPort; Pen: LongWord);
type
  TLocalCall = procedure(Rp: PRastPort; Pen: LongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 58));
  Call(Rp, Pen, GfxBase);
end;

function SetChipRev(ChipRev: LongWord): LongWord;
type
  TLocalCall = function(ChipRev: LongWord; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 148));
  Result := Call(ChipRev, GfxBase);
end;

procedure SetCollision(Num: LongWord; Routine: TProcedure; GInfo: PGelsInfo);
type
  TLocalCall = procedure(Num: LongWord; Routine: TProcedure; GInfo: PGelsInfo; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 24));
  Call(Num, Routine, GInfo, GfxBase);
end;

procedure SetDisplayDriverCallback(CallBack: TDriverNotifyFunc; UserData: APTR);
type
  TLocalCall = procedure(CallBack: TDriverNotifyFunc; UserData: APTR; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 186));
  Call(CallBack, UserData, GfxBase);
end;

procedure SetDrMd(Rp: PRastPort; DrawMode: LongWord);
type
  TLocalCall = procedure(Rp: PRastPort; DrawMode: LongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 59));
  Call(Rp, DrawMode, GfxBase);
end;

procedure SetFont(Rp: PRastPort; TextFont: PTextFont);
type
  TLocalCall = procedure(Rp: PRastPort; TextFont: PTextFont; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 11));
  Call(Rp, TextFont, GfxBase);
end;

procedure SetMaxPen(Rp: PRastPort; MaxPen: LongWord);
type
  TLocalCall = procedure(Rp: PRastPort; MaxPen: LongWord; Base: Pointer) ; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 165));
  Call(Rp, MaxPen, GfxBase);
end;

function SetOutlinePen(Rp: PRastPort; Pen: LongWord): LongWord;
type
  TLocalCall = function(Rp: PRastPort; Pen: LongWord; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 163));
  Result := Call(Rp, Pen, GfxBase);
end;

procedure SetRast(Rp: PRastPort; Pen: LongWord);
type
  TLocalCall = procedure(Rp: PRastPort; Pen: LongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 39));
  Call(Rp, Pen, GfxBase);
end;

function SetRegion(Src: PRegion; Dest: PRegion): LongBool;
type
  TLocalCall = function(Src: PRegion; Dest: PRegion; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 195));
  Result := Call(Src, Dest, GfxBase);
end;



procedure SetRGB32(Vp: PViewPort; n, r, g, b : LongWord);
type
  TLocalCall = procedure(Vp: PViewPort; n, r, g, b : LongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 142));
  Call(Vp, n, r, g, b, GfxBase);
end;

procedure SetRGB32CM(Cm: PColorMap; n, r, g, b: LongWord);
type
  TLocalCall = procedure(Cm: PColorMap; n, r, g, b : LongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 166));
  Call(cm, n, r, g, b, GfxBase);
end;

procedure SetRGB4(Vp: PViewPort; n, r, g, b: LongWord);
type
  TLocalCall = procedure(Vp: PViewPort; n, r, g, b: LongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 48));
  Call(Vp, n, r, g, b, GfxBase);
end;

procedure SetRGB4CM(Cm: PColorMap; n: SmallInt; r, g, b: Byte);
type
  TLocalCall = procedure(Cm: PColorMap; n: SmallInt; r, g, b: Byte; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 106));
  Call(Cm, n, r, g, b, GfxBase);
end;

procedure SetRPAttrsA(Rp: PRastPort; Tags: PTagItem);
type
  TLocalCall = procedure(Rp: PRastPort; Tags: PTagItem; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 173));
  Call(Rp, Tags, GfxBase);
end;

function SetSoftStyle(Rp: PRastPort; Style: LongWord; Enable: LongWord): LongWord;
type
  TLocalCall = function(Rp: PRastPort; Style: LongWord; Enable: LongWord; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 15));
  Result := Call(Rp, Style, Enable, GfxBase);
end;

function SetWriteMask(Rp: PRastPort; Mask: LongWord): LongWord;
type
  TLocalCall = function(Rp: PRastPort; Mask: LongWord; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 164));
  Result := Call(Rp, Mask, GfxBase);
end;

procedure SortGList(Rp: PRastPort);
type
  TLocalCall = procedure(Rp: PRastPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 25));
  Call(Rp, GfxBase);
end;

procedure StripFont(Font: PTextFont);
type
  TLocalCall = procedure(Font: PTextFont; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 137));
  Call(Font, GfxBase);
end;

function SwapRegions(Region1: PRegion; Region2: PRegion; Intersect: PRectangle): LongBool;
type
  TLocalCall = function(Region1: PRegion; Region2: PRegion; Intersect: PRectangle; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 192));
  Result := Call(Region1, Region2, Intersect, GfxBase);
end;

procedure SyncSBitMap(l: PLayer);
type
  TLocalCall = procedure(l: PLayer; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 74));
  Call(l, GfxBase);
end;

procedure GfxText(Rp: PRastPort; const String_: STRPTR; Count: LongWord);
type
  TLocalCall = procedure(Rp: PRastPort; const String_: STRPTR; Count: LongWord; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 10));
  Call(Rp, String_, Count, GfxBase);
end;

procedure TextExtent(Rp: PRastPort; const string_: STRPTR; Count: LongWord; TextExtent_: PTextExtent);
type
  TLocalCall = procedure(Rp: PRastPort; const string_: STRPTR; Count: LongWord; TextExtent_: PTextExtent; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 115));
  Call(Rp, String_, Count, TextExtent_, GfxBase);
end;

function TextFit(Rp: PRastPort; const String_: STRPTR; StrLen: LongWord; TextExtent_: PTextExtent; ConstrainingExtent: PTextExtent; StrDirection: LongInt; ConstrainingBitWidth: LongWord; ConstrainingBitHeight: LongWord): LongWord;
type
  TLocalCall = function(Rp: PRastPort; const String_: STRPTR; StrLen: LongWord; TextExtent_: PTextExtent; ConstrainingExtent: PTextExtent; StrDirection: LongInt; ConstrainingBitWidth: LongWord; ConstrainingBitHeight: LongWord; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 116));
  Result := Call(Rp, string_, strLen, textExtent_, constrainingExtent, strDirection, constrainingBitWidth, constrainingBitHeight, GfxBase);
end;

function TextLength(Rp: PRastPort; const String_: PChar; Count: LongWord): SmallInt;
type
  TLocalCall = function(Rp: PRastPort; const String_: PChar; Count: LongWord; Base: Pointer): SmallInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 9));
  Result := Call(Rp, String_, Count, GfxBase);
end;

function UCopperListInit(Ucl: PUCopList; n: SmallInt): PCopList;
type
  TLocalCall = function(Ucl: PUCopList; n: SmallInt; Base: Pointer): PCopList; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 99));
  Result := Call(Ucl, n, GfxBase);
end;

procedure UnlockLayerRom(l: PLayer);
type
  TLocalCall = procedure(l: PLayer; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 73));
  Call(l, GfxBase);
end;

function VBeamPos: LongInt;
type
  TLocalCall = function(Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 64));
  Result := Call(GfxBase);
end;

function VideoControl(Cm: PColorMap; Tags: PTagItem): LongWord;
type
  TLocalCall = function(Cm: PColorMap; Tags: PTagItem; Base: Pointer): LongWord; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 118));
  Result := Call(Cm, Tags, GfxBase);
end;

procedure WaitBlit;
type
  TLocalCall = procedure(Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 38));
  Call(GfxBase);
end;

procedure WaitBOVP(Vp: PViewPort);
type
  TLocalCall = procedure(Vp: PViewPort; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 67));
  Call(Vp, GfxBase);
end;

procedure WaitTOF;
type
  TLocalCall = procedure(Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 45));
  Call(GfxBase);
end;

function WeighTAMatch(ReqTextAttr: PTextAttr; TargetTextAttr: PTextAttr; TargetTags: PTagItem): SmallInt;
type
  TLocalCall = function(ReqTextAttr: PTextAttr; TargetTextAttr: PTextAttr; TargetTags: PTagItem; Base: Pointer): SmallInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 134));
  Result := Call(ReqTextAttr, TargetTextAttr, TargetTags, GfxBase);
end;

procedure WriteChunkyPixels(Rp: PRastPort; xStart, yStart, xStop, yStop: LongWord; Array_: PByte; BytesPerRow: LongInt);
type
  TLocalCall = procedure(Rp: PRastPort; xStart, yStart, xStop, yStop: LongWord; Array_: PByte; BytesPerRow: LongInt; Base: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 176));
  Call(Rp, xStart, yStart, xStop, yStop, Array_, BytesPerRow, GfxBase);
end;

function WritePixel(Rp: PRastPort; x, y: LongInt): LongInt;
type
  TLocalCall = function(Rp : PRastPort; x, y: LongInt; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 54));
  Result := Call(Rp, x, y, GfxBase);
end;

function WritePixelArray8(Rp: PRastPort; xStart, yStart, xStop, yStop: LongWord; Array_: PByte; TempRp: PRastPort): LongInt;
type
  TLocalCall = function(Rp: PRastPort; xStart, yStart, xStop, yStop: LongWord; Array_: PByte; TempRp: PRastPort; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 131));
  Result := Call(Rp, xStart, yStart, xStop, yStop, Array_, TempRp, GfxBase);
end;

function WritePixelLine8(Rp: PRastPort; xStart, yStart, Width: LongWord; Array_: PByte; TempRP: PRastPort): LongInt;
type
  TLocalCall = function(Rp: PRastPort; xStart, yStart, Width: LongWord; Array_: PByte; TempRP: PRastPort; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 129));
  Result := Call(Rp, xStart, yStart, Width, Array_, TempRP, GfxBase);
end;

function WritePixels8(Rp: PRastPort; Array_: PByte; Modulo: LongWord; xStart, yStart, xStop, yStop: LongWord; PixLUT: Pointer{PHIDDT_PixelLUT}; Do_Update: LongBool): LongInt;
type
  TLocalCall = function(Rp: PRastPort; Array_: PByte; Modulo: LongWord; xStart, yStart, xStop, yStop: LongWord; PixLUT: Pointer{PHIDDT_PixelLUT}; Do_Update: LongBool; Base: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 182));
  Result := Call(Rp, Array_, Modulo, xStart, yStart, xStop, yStop, PixLUT, Do_Update, GfxBase);
end;

function XorRectRegion(Reg: PRegion; Rect: PRectangle): LongBool;
type
  TLocalCall = function(Reg: PRegion; Rect: PRectangle; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 93));
  Result := Call(Reg, Rect, GfxBase);
end;

function XorRectRegionND(Reg: PRegion; Rect: PRectangle): PRegion;
type
  TLocalCall = function(Reg: PRegion; Rect: PRectangle; Base: Pointer): PRegion; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 152));
  Result := Call(Reg, Rect, GfxBase);
end;

function XorRegionRegion(SrcRegion: PRegion; DestRegion: PRegion): LongBool;
type
  TLocalCall = function(SrcRegion: PRegion; DestRegion: PRegion; Base: Pointer): LongBool; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 103));
  Result := Call(SrcRegion, DestRegion, GfxBase);
end;

function XorRegionRegionND(R1: PRegion; R2: PRegion): PRegion;
type
  TLocalCall = function(R1: PRegion; R2: PRegion; Base: Pointer): PRegion; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 151));
  Result := Call(R1, R2, GfxBase);
end;

initialization
  GfxBase := PGfxBase(OpenLibrary(GRAPHICSNAME, 36));
finalization
  CloseLibrary(PLibrary(GfxBase));
end.






