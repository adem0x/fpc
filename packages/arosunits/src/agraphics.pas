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

    Found bugs in,
    WritePixelArray8,
    WritePixelLine8,
    ReadPixelArray8,
    ReadPixelLine8,
    WriteChunkyPixels.
    They all had one argument(array_) defined as pchar,
    should be pointer, fixed.
    20 Aug 2000.

    InitTmpRas had wrong define for the buffer arg.
    Changed from pchar to PLANEPTR.
    23 Aug 2000.

    Compiler had problems with Text, changed to GText.
    24 Aug 2000.

    Added functions and procedures with array of const.
    For use with fpc 1.0.7. They are in systemvartags.
    11 Nov 2002.

    Added the defines use_amiga_smartlink and
    use_auto_openlib.
    13 Jan 2003.

    Update for AmifaOS 3.9.
    Changed start code for unit.
    Bugs in ChangeSprite, GetRGB32, LoadRGB32,
    LoadRGB4 and PolyDraw, fixed.
    01 Feb 2003.

    Changed integer > smallint,
            cardinal > longword.
    09 Feb 2003.

    nils.sjoholm@mailbox.swipnet.se

}

unit agraphics;

{$mode objfpc}

INTERFACE

uses exec, {hardware,} utility;


const

    BITSET      = $8000;
    BITCLR      = 0;

type

    PBltNode = ^TBltNode;
    TBltNode = record
      m: PBltNode;
      _function: Pointer;
      stat: Byte;
      BlitSize: SmallInt;
      BeamSync: SmallInt;
      Cleanup: Pointer;
    end;

    pRectangle = ^tRectangle;
    tRectangle = record
        MinX,MinY       : Word;
        MaxX,MaxY       : Word;
    end;

    pRect32 = ^tRect32;
    tRect32 = record
        MinX,MinY       : Longint;
        MaxX,MaxY       : Longint;
    end;

    pPoint = ^tPoint;
    tPoint = record
        x,y     : Word;
    end;

    PLANEPTR = Pointer;

    pBitMap = ^tBitMap;
    tBitMap = record
        BytesPerRow     : Word;
        Rows            : Word;
        Flags           : Byte;
        Depth           : Byte;
        pad             : Word;
        Planes          : Array [0..7] of PLANEPTR;
    end;
{* flags for AllocBitMap, etc. *}
const
     BMB_CLEAR       = 0;
     BMB_DISPLAYABLE = 1;
     BMB_INTERLEAVED = 2;
     BMB_STANDARD    = 3;
     BMB_MINPLANES   = 4;

     BMF_CLEAR       = (1 shl BMB_CLEAR);
     BMF_DISPLAYABLE = (1 shl BMB_DISPLAYABLE);
     BMF_INTERLEAVED = (1 shl BMB_INTERLEAVED);
     BMF_STANDARD    = (1 shl BMB_STANDARD);
     BMF_MINPLANES   = (1 shl BMB_MINPLANES);

{* the following are for GetBitMapAttr() *}
     BMA_HEIGHT      = 0;
     BMA_DEPTH       = 4;
     BMA_WIDTH       = 8;
     BMA_FLAGS       = 12;


TYPE

 pRegionRectangle = ^tRegionRectangle;
 tRegionRectangle = record
    Next, Prev  : pRegionRectangle;
    bounds      : tRectangle;
 END;

 pRegion = ^tRegion;
 tRegion = record
    bounds      : tRectangle;
    RegionRectangle  : pRegionRectangle;
 END;

{ structures used by and constructed by windowlib.a }
{ understood by rom software }
type
    pClipRect = ^tClipRect; //checked 20.12.2012 ALB
    tClipRect = record
        Next    : pClipRect;    { roms used to find next ClipRect }
        prev    : pClipRect;    { ignored by roms, used by windowlib }
        lobs    : Pointer;      { ignored by roms, used by windowlib (LayerPtr)}
        BitMap  : pBitMap;
        bounds  : tRectangle;    { set up by windowlib, used by roms }
        _p1,
        _p2     : Pointer;    { system reserved }
        reserved : Longint;     { system use }
        Flags   : Longint;      { only exists in layer allocation }
    end;

    pLayer = ^tLayer; //checked 20.12.2012 ALB
    tLayer = record
        front,
        back            : pLayer;       { ignored by roms }
        ClipRect        : pClipRect;  { read by roms to find first cliprect }
        rp              : Pointer;      { (RastPortPtr) ignored by roms, I hope }
        bounds          : tRectangle;    { ignored by roms }
        reserved        : Array [0..3] of Byte;
        priority        : Word;        { system use only }
        Flags           : Word;        { obscured ?, Virtual BitMap? }
        SuperBitMap     : pBitMap;
        SuperClipRect   : pClipRect;  { super bitmap cliprects if
                                                VBitMap != 0}
                                        { else damage cliprect list for refresh }
        Window          : Pointer;      { reserved for user interface use }
        Scroll_X,
        Scroll_Y        : Word;
        cr,
        cr2,
        crnew           : pClipRect;  { used by dedice }
        SuperSaveClipRects : pClipRect; { preallocated cr's }
        cliprects      : pClipRect;  { system use during refresh }
        LayerInfo       : Pointer;      { points to head of the list }
        Lock            : tSignalSemaphore;
        BackFill        : pHook;
        reserved1       : ULONG;
        ClipRegion      : Pointer;
        saveClipRects   : Pointer;      { used to back out when in trouble}
        Width,
        Height          : smallint;
        reserved2       : Array [0..17] of Byte;
        { this must stay here }
        DamageList      : Pointer;      { list of rectangles to refresh
                                                through }
    end;

    tChangeLayerShapeMsg = record //checked 20.12.2012 ALB
      NewShape: pRegion;
      ClipRect: pClipRect;
      shape: pRegion;  
    end;

    tCollectPixelsLayerMsg = record //checked 20.12.2012 ALB
      xSrc: LongInt;
      ySrc: LongInt;
      width: LongInt;
      height: LongInt;
      xDest: LongInt;
      yDest: LongInt;
      bm: pBitmap;
      layer: pLayer;
      minterm: ULONG;
    end;

    tShapeHookMsg = record //checked 20.12.2012 ALB
      Action: LongInt;
      Layer: pLayer;
      ActualShape: pRegion;
      NewBounds: TRectangle;
      OldBounds: TRectangle;
    end;

const

{ internal cliprect flags }

    CR_NEEDS_NO_CONCEALED_RASTERS       = 1;
    CR_NEEDS_NO_LAYERBLIT_DAMAGE        = 2;


{ defines for code values for getcode }

    ISLESSX     = 1;
    ISLESSY     = 2;
    ISGRTRX     = 4;
    ISGRTRY     = 8;


{------ Font Styles ------------------------------------------------}

    FS_NORMAL           = 0;    { normal text (no style bits set) }
    FSB_EXTENDED        = 3;    { extended face (wider than normal) }
    FSF_EXTENDED        = 8;
    FSB_ITALIC          = 2;    { italic (slanted 1:2 right) }
    FSF_ITALIC          = 4;
    FSB_BOLD            = 1;    { bold face text (ORed w/ shifted) }
    FSF_BOLD            = 2;
    FSB_UNDERLINED      = 0;    { underlined (under baseline) }
    FSF_UNDERLINED      = 1;

    FSB_COLORFONT       = 6;       { this uses ColorTextFont structure }
    FSF_COLORFONT       = $40;
    FSB_TAGGED          = 7;       { the TextAttr is really an TTextAttr, }
    FSF_TAGGED          = $80;


{------ Font Flags -------------------------------------------------}
    FPB_ROMFONT         = 0;    { font is in rom }
    FPF_ROMFONT         = 1;
    FPB_DISKFONT        = 1;    { font is from diskfont.library }
    FPF_DISKFONT        = 2;
    FPB_REVPATH         = 2;    { designed path is reversed (e.g. left) }
    FPF_REVPATH         = 4;
    FPB_TALLDOT         = 3;    { designed for hires non-interlaced }
    FPF_TALLDOT         = 8;
    FPB_WIDEDOT         = 4;    { designed for lores interlaced }
    FPF_WIDEDOT         = 16;
    FPB_PROPORTIONAL    = 5;    { character sizes can vary from nominal }
    FPF_PROPORTIONAL    = 32;
    FPB_DESIGNED        = 6;    { size is "designed", not constructed }
    FPF_DESIGNED        = 64;
    FPB_REMOVED         = 7;    { the font has been removed }
    FPF_REMOVED         = 128;

{***** TextAttr node, matches text attributes in RastPort *********}

type

    pTextAttr = ^tTextAttr;
    tTextAttr = record
        ta_Name : STRPTR;       { name of the font }
        ta_YSize : Word;       { height of the font }
        ta_Style : Byte;        { intrinsic font style }
        ta_Flags : Byte;        { font preferences and flags }
    end;

    pTTextAttr = ^tTTextAttr;
    tTTextAttr = record
        tta_Name : STRPTR;       { name of the font }
        tta_YSize : Word;       { height of the font }
        tta_Style : Byte;        { intrinsic font style }
        tta_Flags : Byte;        { font preferences AND flags }
        tta_Tags  : pTagItem;     { extended attributes }
    end;

{***** Text Tags **************************************************}
CONST
  TA_DeviceDPI  =  (1+TAG_USER);    { Tag value is Point union: }
                                        { Hi Longint XDPI, Lo Longint YDPI }

  MAXFONTMATCHWEIGHT  =    32767;   { perfect match from WeighTAMatch }



{***** TextFonts node *********************************************}
Type

    pTextFont = ^tTextFont;
    tTextFont = record
        tf_Message      : tMessage;      { reply message for font removal }
                                        { font name in LN \    used in this }
        tf_YSize        : Word;        { font height     |    order to best }
        tf_Style        : Byte;         { font style      |    match a font }
        tf_Flags        : Byte;         { preferences and flags /    request. }
        tf_XSize        : Word;        { nominal font width }
        tf_Baseline     : Word; { distance from the top of char to baseline }
        tf_BoldSmear    : Word;        { smear to affect a bold enhancement }

        tf_Accessors    : Word;        { access count }

        tf_LoChar       : Byte;         { the first character described here }
        tf_HiChar       : Byte;         { the last character described here }
        tf_CharData     : Pointer;      { the bit character data }

        tf_Modulo       : Word; { the row modulo for the strike font data }
        tf_CharLoc      : Pointer; { ptr to location data for the strike font }
                                        { 2 words: bit offset then size }
        tf_CharSpace    : Pointer; { ptr to words of proportional spacing data }
        tf_CharKern     : Pointer;      { ptr to words of kerning data }
    end;


{----- tfe_Flags0 (partial definition) ----------------------------}
CONST
 TE0B_NOREMFONT = 0;       { disallow RemFont for this font }
 TE0F_NOREMFONT = $01;

Type

   pTextFontExtension = ^tTextFontExtension;
   tTextFontExtension = record              { this structure is read-only }
    tfe_MatchWord  : Word;                { a magic cookie for the extension }
    tfe_Flags0     : Byte;                 { (system private flags) }
    tfe_Flags1     : Byte;                 { (system private flags) }
    tfe_BackPtr    : pTextFont;          { validation of compilation }
    tfe_OrigReplyPort : pMsgPort;        { original value in tf_Extension }
    tfe_Tags       : pTagItem;              { Text Tags for the font }
    tfe_OFontPatchS,                       { (system private use) }
    tfe_OFontPatchK : Pointer;             { (system private use) }
    { this space is reserved for future expansion }
   END;

{***** ColorTextFont node *****************************************}
{----- ctf_Flags --------------------------------------------------}
CONST
 CT_COLORMASK  =  $000F;  { mask to get to following color styles }
 CT_COLORFONT  =  $0001;  { color map contains designer's colors }
 CT_GREYFONT   =  $0002;  { color map describes even-stepped }
                                { brightnesses from low to high }
 CT_ANTIALIAS  =  $0004;  { zero background thru fully saturated char }

 CTB_MAPCOLOR  =  0;      { map ctf_FgColor to the rp_FgPen IF it's }
 CTF_MAPCOLOR  =  $0001;  { is a valid color within ctf_Low..ctf_High }

{----- ColorFontColors --------------------------------------------}
Type
   pColorFontColors = ^tColorFontColors;
   tColorFontColors = record
    cfc_Reserved,                 { *must* be zero }
    cfc_Count   : Word;          { number of entries in cfc_ColorTable }
    cfc_ColorTable : Pointer;     { 4 bit per component color map packed xRGB }
   END;

{----- ColorTextFont ----------------------------------------------}

   pColorTextFont = ^tColorTextFont;
   tColorTextFont = record
    ctf_TF      : tTextFont;
    ctf_Flags   : Word;          { extended flags }
    ctf_Depth,          { number of bit planes }
    ctf_FgColor,        { color that is remapped to FgPen }
    ctf_Low,            { lowest color represented here }
    ctf_High,           { highest color represented here }
    ctf_PlanePick,      { PlanePick ala Images }
    ctf_PlaneOnOff : Byte;     { PlaneOnOff ala Images }
    ctf_ColorFontColors : pColorFontColors; { colors for font }
    ctf_CharData : Array[0..7] of APTR;    {pointers to bit planes ala tf_CharData }
   END;

{***** TextExtent node ********************************************}

   pTextExtent = ^tTextExtent;
   tTextExtent = record
    te_Width,                   { same as TextLength }
    te_Height : Word;          { same as tf_YSize }
    te_Extent : tRectangle;      { relative to CP }
   END;


const

    COPPER_MOVE = 0;    { pseude opcode for move #XXXX,dir }
    COPPER_WAIT = 1;    { pseudo opcode for wait y,x }
    CPRNXTBUF   = 2;    { continue processing with next buffer }
    CPR_NT_LOF  = $8000; { copper instruction only for Longint frames }
    CPR_NT_SHT  = $4000; { copper instruction only for long frames }
    CPR_NT_SYS  = $2000; { copper user instruction only }
type

{ Note: The combination VWaitAddr and HWaitAddr replace a three way
        union in C.  The three possibilities are:

        nxtList : CopListPtr;  or

        VWaitPos : Longint;
        HWaitPos : Longint;  or

        DestAddr : Longint;
        DestData : Longint;
}

    pCopIns = ^tCopIns;
    tCopIns = record
        OpCode  : smallint; { 0 = move, 1 = wait }
        VWaitAddr : smallint; { vertical or horizontal wait position }
        HWaitData : smallint; { destination Pointer or data to send }
    end;

{ structure of cprlist that points to list that hardware actually executes }

    pcprlist = ^tcprlist;
    tcprlist = record
        Next    : pcprlist;
        start   : psmallint;       { start of copper list }
        MaxCount : smallint;       { number of long instructions }
    end;

    pCopList = ^tCopList;
    tCopList = record
        Next    : pCopList;     { next block for this copper list }
        CopList : pCopList;    { system use }
        ViewPort : Pointer;    { system use }
        CopIns  : pCopIns;    { start of this block }
        CopPtr  : pCopIns;    { intermediate ptr }
        CopLStart : psmallint;     { mrgcop fills this in for Long Frame}
        CopSStart : psmallint;     { mrgcop fills this in for Longint Frame}
        Count   : smallint;        { intermediate counter }
        MaxCount : smallint;       { max # of copins for this block }
        DyOffset : smallint;       { offset this copper list vertical waits }
        SLRepeat : Word;
        Flags    : Word;
    end;

    pUCopList = ^tUCopList;
    tUCopList = record
        Next    : pUCopList;
        FirstCopList : pCopList;      { head node of this copper list }
        CopList : pCopList;           { node in use }
    end;

    pcopinit = ^tcopinit;
    tcopinit = record
        vsync_hblank : array [0..1] of word;
        diagstrt : Array [0..11] of word;
        fm0      : array [0..1] of word;
        diwstart : array [0..9] of word;
        bplcon2  : array [0..1] of word;
        sprfix   : array [0..(2*8)] of word;
        sprstrtup : Array [0..(2*8*2)] of Word;
        wait14    : array [0..1] of word;
        norm_hblank : array [0..1] of word;
        jump        : array [0..1] of word;
        wait_forever : array [0..5] of word;
        sprstop : Array [0..7] of Word;
    end;



    pAreaInfo = ^tAreaInfo;
    tAreaInfo = record
        VctrTbl : Pointer;      { ptr to start of vector table }
        VctrPtr : Pointer;      { ptr to current vertex }
        FlagTbl : Pointer;      { ptr to start of vector flag table }
        FlagPtr : Pointer;      { ptrs to areafill flags }
        Count   : smallint;        { number of vertices in list }
        MaxCount : smallint;       { AreaMove/Draw will not allow Count>MaxCount}
        FirstX,
        FirstY  : smallint;        { first point for this polygon }
    end;

    pTmpRas = ^tTmpRas;
    tTmpRas = record
        RasPtr  : Pointer;
        Size    : Longint;
    end;

{ unoptimized for 32bit alignment of pointers }

    pGelsInfo = ^tGelsInfo;
    tGelsInfo = record
        sprRsrvd        : Shortint; { flag of which sprites to reserve from
                                  vsprite system }
        Flags   : Byte;       { system use }
        gelHead,
        gelTail : Pointer; { (VSpritePtr) dummy vSprites for list management}

    { pointer to array of 8 WORDS for sprite available lines }

        nextLine : Pointer;

    { pointer to array of 8 pointers for color-last-assigned to vSprites }

        lastColor : Pointer;
        collHandler : Pointer;  { (collTablePtr) Pointeres of collision routines }
        leftmost,
        rightmost,
        topmost,
        bottommost      : smallint;
        firstBlissObj,
        lastBlissObj    : Pointer;    { system use only }
    end;

    pRastPort = ^tRastPort;
    tRastPort = record
        Layer           : pLayer;      { LayerPtr }
        BitMap          : pBitMap;      { BitMapPtr }
        AreaPtrn        : Pointer;      { ptr to areafill pattern }
        TmpRas          : pTmpRas;
        AreaInfo        : pAreaInfo;
        GelsInfo        : pGelsInfo;
        Mask            : Byte;         { write mask for this raster }
        FgPen           : Shortint;         { foreground pen for this raster }
        BgPen           : Shortint;         { background pen         }
        AOlPen          : Shortint;         { areafill outline pen }
        DrawMode        : Shortint; { drawing mode for fill, lines, and text }
        AreaPtSz        : Shortint;         { 2^n words for areafill pattern }
        linpatcnt       : Shortint; { current line drawing pattern preshift }
        dummy           : Shortint;
        Flags           : Word;        { miscellaneous control bits }
        LinePtrn        : Word;        { 16 bits for textured lines }
        cp_x,
        cp_y            : smallint;        { current pen position }
        minterms        : Array [0..7] of Byte;
        PenWidth        : smallint;
        PenHeight       : smallint;
        Font            : pTextFont;      { (TextFontPtr) current font Pointer }
        AlgoStyle       : Byte;         { the algorithmically generated style }
        TxFlags         : Byte;         { text specific flags }
        TxHeight        : Word;        { text height }
        TxWidth         : Word;        { text nominal width }
        TxBaseline      : Word;        { text baseline }
        TxSpacing       : smallint;        { text spacing (per character) }
        RP_User         : Pointer;
        longreserved    : Array [0..1] of ULONG;
        wordreserved    : Array [0..6] of Word;        { used to be a node }
        reserved        : Array [0..7] of Byte;         { for future use }
    end;

const

{ drawing modes }

    JAM1        = 0;    { jam 1 color into raster }
    JAM2        = 1;    { jam 2 colors into raster }
    COMPLEMENT  = 2;    { XOR bits into raster }
    INVERSVID   = 4;    { inverse video for drawing modes }

{ these are the flag bits for RastPort flags }

    FRST_DOT    = $01;  { draw the first dot of this line ? }
    ONE_DOT     = $02;  { use one dot mode for drawing lines }
    DBUFFER     = $04;  { flag set when RastPorts are double-buffered }

             { only used for bobs }

    AREAOUTLINE = $08;  { used by areafiller }
    NOCROSSFILL = $20;  { areafills have no crossovers }

{ there is only one style of clipping: raster clipping }
{ this preserves the continuity of jaggies regardless of clip window }
{ When drawing into a RastPort, if the ptr to ClipRect is nil then there }
{ is no clipping done, this is dangerous but useful for speed }


Const
    CleanUp     = $40;
    CleanMe     = CleanUp;

    BltClearWait        = 1;    { Waits for blit to finish }
    BltClearXY          = 2;    { Use Row/Bytes per row method }

        { Useful minterms }

    StraightCopy        = $C0;  { Vanilla copy }
    InvertAndCopy       = $30;  { Invert the source before copy }
    InvertDest          = $50;  { Forget source, invert dest }


 {      mode coercion definitions }

const
{  These flags are passed (in combination) to CoerceMode() to determine the
 * type of coercion required.
 }

{  Ensure that the mode coerced to can display just as many colours as the
 * ViewPort being coerced.
 }
    PRESERVE_COLORS = 1;

{  Ensure that the mode coerced to is not interlaced. }
    AVOID_FLICKER   = 2;

{  Coercion should ignore monitor compatibility issues. }
    IGNORE_MCOMPAT  = 4;


    BIDTAG_COERCE   = 1; {  Private }

const

{ VSprite flags }
{ user-set VSprite flags: }

    SUSERFLAGS  = $00FF;        { mask of all user-settable VSprite-flags }
    VSPRITE_f   = $0001;        { set if VSprite, clear if Bob }
                                { VSPRITE had to be changed for name conflict }
    SAVEBACK    = $0002;        { set if background is to be saved/restored }
    OVERLAY     = $0004;        { set to mask image of Bob onto background }
    MUSTDRAW    = $0008;        { set if VSprite absolutely must be drawn }

{ system-set VSprite flags: }

    BACKSAVED   = $0100;        { this Bob's background has been saved }
    BOBUPDATE   = $0200;        { temporary flag, useless to outside world }
    GELGONE     = $0400;        { set if gel is completely clipped (offscreen) }
    VSOVERFLOW  = $0800;        { VSprite overflow (if MUSTDRAW set we draw!) }

{ Bob flags }
{ these are the user flag bits }

    BUSERFLAGS  = $00FF;        { mask of all user-settable Bob-flags }
    SAVEBOB     = $0001;        { set to not erase Bob }
    BOBISCOMP   = $0002;        { set to identify Bob as AnimComp }

{ these are the system flag bits }

    BWAITING    = $0100;        { set while Bob is waiting on 'after' }
    BDRAWN      = $0200;        { set when Bob is drawn this DrawG pass}
    BOBSAWAY    = $0400;        { set to initiate removal of Bob }
    BOBNIX      = $0800;        { set when Bob is completely removed }
    SAVEPRESERVE = $1000;       { for back-restore during double-buffer}
    OUTSTEP     = $2000;        { for double-clearing if double-buffer }

{ defines for the animation procedures }

    ANFRACSIZE  = 6;
    ANIMHALF    = $0020;
    RINGTRIGGER = $0001;


{ UserStuff definitions
 *  the user can define these to be a single variable or a sub-structure
 *  if undefined by the user, the system turns these into innocuous variables
 *  see the manual for a thorough definition of the UserStuff definitions
 *
 }

type

    VUserStuff  = smallint;        { Sprite user stuff }
    BUserStuff  = smallint;        { Bob user stuff }
    AUserStuff  = smallint;        { AnimOb user stuff }

{********************** GEL STRUCTURES **********************************}

    pVSprite = ^tVSprite;
    tVSprite = record

{ --------------------- SYSTEM VARIABLES ------------------------------- }
{ GEL linked list forward/backward pointers sorted by y,x value }

        NextVSprite     : pVSprite;
        PrevVSprite     : pVSprite;

{ GEL draw list constructed in the order the Bobs are actually drawn, then
 *  list is copied to clear list
 *  must be here in VSprite for system boundary detection
 }

        DrawPath        : pVSprite;     { pointer of overlay drawing }
        ClearPath       : pVSprite;     { pointer for overlay clearing }

{ the VSprite positions are defined in (y,x) order to make sorting
 *  sorting easier, since (y,x) as a long Longint
 }

        OldY, OldX      : smallint;        { previous position }

{ --------------------- COMMON VARIABLES --------------------------------- }

        Flags           : smallint;        { VSprite flags }


{ --------------------- USER VARIABLES ----------------------------------- }
{ the VSprite positions are defined in (y,x) order to make sorting
 *  sorting easier, since (y,x) as a long Longint
 }

        Y, X            : smallint;        { screen position }

        Height  : smallint;
        Width   : smallint;        { number of words per row of image data }
        Depth   : smallint;        { number of planes of data }

        MeMask  : smallint;        { which types can collide with this VSprite}
        HitMask : smallint;        { which types this VSprite can collide with}

        ImageData       : Pointer;      { pointer to VSprite image }

{ borderLine is the one-dimensional logical OR of all
 *  the VSprite bits, used for fast collision detection of edge
 }

        BorderLine      : Pointer; { logical OR of all VSprite bits }
        CollMask        : Pointer; { similar to above except this is a matrix }

{ pointer to this VSprite's color definitions (not used by Bobs) }

        SprColors       : Pointer;

        VSBob   : Pointer;      { (BobPtr) points home if this VSprite
                                   is part of a Bob }

{ planePick flag:  set bit selects a plane from image, clear bit selects
 *  use of shadow mask for that plane
 * OnOff flag: if using shadow mask to fill plane, this bit (corresponding
 *  to bit in planePick) describes whether to fill with 0's or 1's
 * There are two uses for these flags:
 *      - if this is the VSprite of a Bob, these flags describe how the Bob
 *        is to be drawn into memory
 *      - if this is a simple VSprite and the user intends on setting the
 *        MUSTDRAW flag of the VSprite, these flags must be set too to describe
 *        which color registers the user wants for the image
 }

        PlanePick       : Shortint;
        PlaneOnOff      : Shortint;

        VUserExt        : VUserStuff;   { user definable:  see note above }
    end;




{ dBufPacket defines the values needed to be saved across buffer to buffer
 *  when in double-buffer mode
 }

    pDBufPacket = ^tDBufPacket;
    tDBufPacket = record
        BufY,
        BufX    : Word;        { save other buffers screen coordinates }
        BufPath : pVSprite;   { carry the draw path over the gap }

{ these pointers must be filled in by the user }
{ pointer to other buffer's background save buffer }

        BufBuffer : Pointer;
    end;





    pBob = ^tBob;
    tBob = record
{ blitter-objects }

{ --------------------- SYSTEM VARIABLES --------------------------------- }

{ --------------------- COMMON VARIABLES --------------------------------- }

        Flags   : smallint; { general purpose flags (see definitions below) }

{ --------------------- USER VARIABLES ----------------------------------- }

        SaveBuffer : Pointer;   { pointer to the buffer for background save }

{ used by Bobs for "cookie-cutting" and multi-plane masking }

        ImageShadow : Pointer;

{ pointer to BOBs for sequenced drawing of Bobs
 *  for correct overlaying of multiple component animations
 }
        Before  : pBob; { draw this Bob before Bob pointed to by before }
        After   : pBob; { draw this Bob after Bob pointed to by after }

        BobVSprite : pVSprite;        { this Bob's VSprite definition }

        BobComp : Pointer; { (AnimCompPtr) pointer to this Bob's AnimComp def }

        DBuffer : Pointer;        { pointer to this Bob's dBuf packet }

        BUserExt : BUserStuff;  { Bob user extension }
    end;

    pAnimComp = ^tAnimComp;
    tAnimComp = record

{ --------------------- SYSTEM VARIABLES --------------------------------- }

{ --------------------- COMMON VARIABLES --------------------------------- }

        Flags   : smallint;        { AnimComp flags for system & user }

{ timer defines how long to keep this component active:
 *  if set non-zero, timer decrements to zero then switches to nextSeq
 *  if set to zero, AnimComp never switches
 }

        Timer   : smallint;

{ --------------------- USER VARIABLES ----------------------------------- }
{ initial value for timer when the AnimComp is activated by the system }

        TimeSet : smallint;

{ pointer to next and previous components of animation object }

        NextComp        : pAnimComp;
        PrevComp        : pAnimComp;

{ pointer to component component definition of next image in sequence }

        NextSeq : pAnimComp;
        PrevSeq : pAnimComp;

        AnimCRoutine : Pointer; { Pointer of special animation procedure }

        YTrans  : smallint; { initial y translation (if this is a component) }
        XTrans  : smallint; { initial x translation (if this is a component) }

        HeadOb  : Pointer; { AnimObPtr }

        AnimBob : pBob;
    end;

    pAnimOb = ^tAnimOb;
    tAnimOb = record

{ --------------------- SYSTEM VARIABLES --------------------------------- }

        NextOb,
        PrevOb  : pAnimOb;

{ number of calls to Animate this AnimOb has endured }

        Clock   : Longint;

        AnOldY,
        AnOldX  : smallint;        { old y,x coordinates }

{ --------------------- COMMON VARIABLES --------------------------------- }

        AnY,
        AnX     : smallint;        { y,x coordinates of the AnimOb }

{ --------------------- USER VARIABLES ----------------------------------- }

        YVel,
        XVel    : smallint;        { velocities of this object }
        YAccel,
        XAccel  : smallint;        { accelerations of this object }

        RingYTrans,
        RingXTrans      : smallint;        { ring translation values }

        AnimORoutine    : Pointer;      { Pointer of special animation
                                          procedure }

        HeadComp        : pAnimComp;  { pointer to first component }

        AUserExt        : AUserStuff;       { AnimOb user extension }
    end;

    ppAnimOb = ^pAnimOb;


{ ************************************************************************ }

const

    B2NORM      = 0;
    B2SWAP      = 1;
    B2BOBBER    = 2;

{ ************************************************************************ }

type

{ a structure to contain the 16 collision procedure addresses }

    collTable = Array [0..15] of Pointer;
    pcollTable = ^collTable;

const

{   These bit descriptors are used by the GEL collide routines.
 *  These bits are set in the hitMask and meMask variables of
 *  a GEL to describe whether or not these types of collisions
 *  can affect the GEL.  BNDRY_HIT is described further below;
 *  this bit is permanently assigned as the boundary-hit flag.
 *  The other bit GEL_HIT is meant only as a default to cover
 *  any GEL hitting any other; the user may redefine this bit.
 }

    BORDERHIT   = 0;

{   These bit descriptors are used by the GEL boundry hit routines.
 *  When the user's boundry-hit routine is called (via the argument
 *  set by a call to SetCollision) the first argument passed to
 *  the user's routine is the Pointer of the GEL involved in the
 *  boundry-hit, and the second argument has the appropriate bit(s)
 *  set to describe which boundry was surpassed
 }

    TOPHIT      = 1;
    BOTTOMHIT   = 2;
    LEFTHIT     = 4;
    RIGHTHIT    = 8;

Type
 pExtendedNode = ^tExtendedNode;
 tExtendedNode = record
  xln_Succ,
  xln_Pred  : pNode;
  xln_Type  : Byte;
  xln_Pri   : Shortint;
  xln_Name  : STRPTR;
  xln_Subsystem : Byte;
  xln_Subtype   : Byte;
  xln_Library : Longint;
  xln_Init : Pointer;
 END;

CONST
 SS_GRAPHICS   =  $02;

 VIEW_EXTRA_TYPE       =  1;
 VIEWPORT_EXTRA_TYPE   =  2;
 SPECIAL_MONITOR_TYPE  =  3;
 MONITOR_SPEC_TYPE     =  4;

type

{ structure used by AddTOFTask }

    pIsrvstr = ^tIsrvstr;
    tIsrvstr = record
        is_Node : tNode;
        Iptr    : pIsrvstr;     { passed to srvr by os }
        code    : Pointer;
        ccode   : Pointer;
        Carg    : Pointer;
    end;

Type
 pAnalogSignalInterval = ^tAnalogSignalInterval;
 tAnalogSignalInterval = record
  asi_Start,
  asi_Stop  : Word;
 END;

 pSpecialMonitor = ^tSpecialMonitor;
 tSpecialMonitor = record
  spm_Node      : tExtendedNode;
  spm_Flags     : Word;
  do_monitor,
  reserved1,
  reserved2,
  reserved3     : Pointer;
  hblank,
  vblank,
  hsync,
  vsync : tAnalogSignalInterval;
 END;


 pMonitorSpec = ^tMonitorSpec;
 tMonitorSpec = record
    ms_Node     : tExtendedNode;
    ms_Flags    : Word;
    ratioh,
    ratiov      : Longint;
    total_rows,
    total_colorclocks,
    DeniseMaxDisplayColumn,
    BeamCon0,
    min_row     : Word;
    ms_Special  : pSpecialMonitor;
    ms_OpenCount : Word;
    ms_transform,
    ms_translate,
    ms_scale    : Pointer;
    ms_xoffset,
    ms_yoffset  : Word;
    ms_LegalView : tRectangle;
    ms_maxoscan,       { maximum legal overscan }
    ms_videoscan  : Pointer;      { video display overscan }
    DeniseMinDisplayColumn : Word;
    DisplayCompatible      : ULONG;
    DisplayInfoDataBase    : tList;
    DisplayInfoDataBaseSemaphore : tSignalSemaphore;
    ms_MrgCop,
    ms_LoadView,
    ms_KillView  : Longint;
 END;

const
  TO_MONITOR            =  0;
  FROM_MONITOR          =  1;
  STANDARD_XOFFSET      =  9;
  STANDARD_YOFFSET      =  0;

  MSB_REQUEST_NTSC      =  0;
  MSB_REQUEST_PAL       =  1;
  MSB_REQUEST_SPECIAL   =  2;
  MSB_REQUEST_A2024     =  3;
  MSB_DOUBLE_SPRITES    =  4;
  MSF_REQUEST_NTSC      =  1;
  MSF_REQUEST_PAL       =  2;
  MSF_REQUEST_SPECIAL   =  4;
  MSF_REQUEST_A2024     =  8;
  MSF_DOUBLE_SPRITES    =  16;


{ obsolete, v37 compatible definitions follow }
  REQUEST_NTSC          =  1;
  REQUEST_PAL           =  2;
  REQUEST_SPECIAL       =  4;
  REQUEST_A2024         =  8;

  DEFAULT_MONITOR_NAME  : PChar =  'default.monitor';
  NTSC_MONITOR_NAME     : PChar =  'ntsc.monitor';
  PAL_MONITOR_NAME      : PChar =  'pal.monitor';
  STANDARD_MONITOR_MASK =  ( REQUEST_NTSC OR REQUEST_PAL ) ;

  STANDARD_NTSC_ROWS    =  262;
  STANDARD_PAL_ROWS     =  312;
  STANDARD_COLORCLOCKS  =  226;
  STANDARD_DENISE_MAX   =  455;
  STANDARD_DENISE_MIN   =  93 ;
  STANDARD_NTSC_BEAMCON =  $0000;
  //STANDARD_PAL_BEAMCON  =  DISPLAYPAL ;

  //SPECIAL_BEAMCON       = ( VARVBLANK OR LOLDIS OR VARVSYNC OR VARHSYNC OR VARBEAM OR CSBLANK OR VSYNCTRUE);

  MIN_NTSC_ROW    = 21   ;
  MIN_PAL_ROW     = 29   ;
  STANDARD_VIEW_X = $81  ;
  STANDARD_VIEW_Y = $2C  ;
  STANDARD_HBSTRT = $06  ;
  STANDARD_HSSTRT = $0B  ;
  STANDARD_HSSTOP = $1C  ;
  STANDARD_HBSTOP = $2C  ;
  STANDARD_VBSTRT = $0122;
  STANDARD_VSSTRT = $02A6;
  STANDARD_VSSTOP = $03AA;
  STANDARD_VBSTOP = $1066;

  VGA_COLORCLOCKS = (STANDARD_COLORCLOCKS/2);
  VGA_TOTAL_ROWS  = (STANDARD_NTSC_ROWS*2);
  VGA_DENISE_MIN  = 59   ;
  MIN_VGA_ROW     = 29   ;
  VGA_HBSTRT      = $08  ;
  VGA_HSSTRT      = $0E  ;
  VGA_HSSTOP      = $1C  ;
  VGA_HBSTOP      = $1E  ;
  VGA_VBSTRT      = $0000;
  VGA_VSSTRT      = $0153;
  VGA_VSSTOP      = $0235;
  VGA_VBSTOP      = $0CCD;

  VGA_MONITOR_NAME  : PChar    =  'vga.monitor';

{ NOTE: VGA70 definitions are obsolete - a VGA70 monitor has never been
 * implemented.
 }
  VGA70_COLORCLOCKS = (STANDARD_COLORCLOCKS/2) ;
  VGA70_TOTAL_ROWS  = 449;
  VGA70_DENISE_MIN  = 59;
  MIN_VGA70_ROW     = 35   ;
  VGA70_HBSTRT      = $08  ;
  VGA70_HSSTRT      = $0E  ;
  VGA70_HSSTOP      = $1C  ;
  VGA70_HBSTOP      = $1E  ;
  VGA70_VBSTRT      = $0000;
  VGA70_VSSTRT      = $02A6;
  VGA70_VSSTOP      = $0388;
  VGA70_VBSTOP      = $0F73;

  //VGA70_BEAMCON     = (SPECIAL_BEAMCON XOR VSYNCTRUE);
  VGA70_MONITOR_NAME  : PChar  =      'vga70.monitor';

  BROADCAST_HBSTRT  =      $01  ;
  BROADCAST_HSSTRT  =      $06  ;
  BROADCAST_HSSTOP  =      $17  ;
  BROADCAST_HBSTOP  =      $27  ;
  BROADCAST_VBSTRT  =      $0000;
  BROADCAST_VSSTRT  =      $02A6;
  BROADCAST_VSSTOP  =      $054C;
  BROADCAST_VBSTOP  =      $1C40;
  //BROADCAST_BEAMCON =      ( LOLDIS OR CSBLANK );
  RATIO_FIXEDPART   =      4;
  RATIO_UNITY       =      16;



Type
    pRasInfo = ^tRasInfo;
    tRasInfo = record    { used by callers to and InitDspC() }
        Next    : pRasInfo;     { used for dualpf }
        BitMap  : pBitMap;
        RxOffset,
        RyOffset : smallint;       { scroll offsets in this BitMap }
    end;


    pView = ^tView;
    tView = record
        ViewPort        : Pointer;      { ViewPortPtr }
        LOFCprList      : pcprlist;   { used for interlaced and noninterlaced }
        SHFCprList      : pcprlist;   { only used during interlace }
        DyOffset,
        DxOffset        : smallint;        { for complete View positioning }
                                { offsets are +- adjustments to standard #s }
        Modes           : WORD;        { such as INTERLACE, GENLOC }
    end;

{ these structures are obtained via GfxNew }
{ and disposed by GfxFree }
Type
       pViewExtra = ^tViewExtra;
       tViewExtra = record
        n : tExtendedNode;
        View     : pView;       { backwards link }   { view in C-Includes }
        Monitor : pMonitorSpec; { monitors for this view }
        TopLine : Word;
       END;


    pViewPort = ^tViewPort;
    tViewPort = record
        Next    : pViewPort;
        ColorMap : Pointer; { table of colors for this viewport }        { ColorMapPtr }
                          { if this is nil, MakeVPort assumes default values }
        DspIns  : pCopList;   { user by MakeView() }
        SprIns  : pCopList;   { used by sprite stuff }
        ClrIns  : pCopList;   { used by sprite stuff }
        UCopIns : pUCopList;  { User copper list }
        DWidth,
        DHeight : smallint;
        DxOffset,
        DyOffset : smallint;
        Modes   : Word;
        SpritePriorities : Byte;        { used by makevp }
        reserved : Byte;
        RasInfo : pRasInfo;
    end;


{ this structure is obtained via GfxNew }
{ and disposed by GfxFree }

 pViewPortExtra = ^tViewPortExtra;
 tViewPortExtra = record
  n : tExtendedNode;
  ViewPort     : pViewPort;      { backwards link }   { ViewPort in C-Includes }
  DisplayClip  : tRectangle;  { makevp display clipping information }
        { These are added for V39 }
  VecTable     : Pointer;                { Private }
  DriverData   : Array[0..1] of Pointer;
  Flags        : WORD;
  Origin       : Array[0..1] of tPoint;  { First visible point relative to the DClip.
                                         * One for each possible playfield.
                                         }
  cop1ptr,                  { private }
  cop2ptr      : ULONG;   { private }
 END;


    pColorMap = ^tColorMap;
    tColorMap = record
        Flags   : Byte;
        CType   : Byte;         { This is "Type" in C includes }
        Count   : Word;
        ColorTable      : Pointer;
        cm_vpe  : pViewPortExtra;
        LowColorBits : Pointer;
        TransparencyPlane,
        SpriteResolution,
        SpriteResDefault,
        AuxFlags         : Byte;
        cm_vp            : pViewPort;   { ViewPortPtr }
        NormalDisplayInfo,
        CoerceDisplayInfo : Pointer;
        cm_batch_items   : pTagItem;
        VPModeID         : ULONG;
        PalExtra         : Pointer;
        SpriteBase_Even,
        SpriteBase_Odd,
        Bp_0_base,
        Bp_1_base        : Word;
    end;

{ if Type == 0 then ColorMap is V1.2/V1.3 compatible }
{ if Type != 0 then ColorMap is V36       compatible }
{ the system will never create other than V39 type colormaps when running V39 }

CONST
 COLORMAP_TYPE_V1_2     = $00;
 COLORMAP_TYPE_V1_4     = $01;
 COLORMAP_TYPE_V36      = COLORMAP_TYPE_V1_4;    { use this definition }
 COLORMAP_TYPE_V39      = $02;


{ Flags variable }
 COLORMAP_TRANSPARENCY   = $01;
 COLORPLANE_TRANSPARENCY = $02;
 BORDER_BLANKING         = $04;
 BORDER_NOTRANSPARENCY   = $08;
 VIDEOCONTROL_BATCH      = $10;
 USER_COPPER_CLIP        = $20;


CONST
 EXTEND_VSTRUCT = $1000;  { unused bit in Modes field of View }


{ defines used for Modes in IVPargs }

CONST
 GENLOCK_VIDEO  =  $0002;
 LACE           =  $0004;
 SUPERHIRES     =  $0020;
 PFBA           =  $0040;
 EXTRA_HALFBRITE=  $0080;
 GENLOCK_AUDIO  =  $0100;
 DUALPF         =  $0400;
 HAM            =  $0800;
 EXTENDED_MODE  =  $1000;
 VP_HIDE        =  $2000;
 SPRITES        =  $4000;
 HIRES          =  $8000;

 VPF_A2024      =  $40;
 VPF_AGNUS      =  $20;
 VPF_TENHZ      =  $20;

 BORDERSPRITES   = $40;

 CMF_CMTRANS   =  0;
 CMF_CPTRANS   =  1;
 CMF_BRDRBLNK  =  2;
 CMF_BRDNTRAN  =  3;
 CMF_BRDRSPRT  =  6;

 SPRITERESN_ECS       =   0;
{ ^140ns, except in 35ns viewport, where it is 70ns. }
 SPRITERESN_140NS     =   1;
 SPRITERESN_70NS      =   2;
 SPRITERESN_35NS      =   3;
 SPRITERESN_DEFAULT   =   -1;

{ AuxFlags : }
 CMAB_FULLPALETTE = 0;
 CMAF_FULLPALETTE = 1;
 CMAB_NO_INTERMED_UPDATE = 1;
 CMAF_NO_INTERMED_UPDATE = 2;
 CMAB_NO_COLOR_LOAD = 2;
 CMAF_NO_COLOR_LOAD = 4;
 CMAB_DUALPF_DISABLE = 3;
 CMAF_DUALPF_DISABLE = 8;

Type
    pPaletteExtra = ^tPaletteExtra;
    tPaletteExtra = record                            { structure may be extended so watch out! }
        pe_Semaphore  : tSignalSemaphore;                { shared semaphore for arbitration     }
        pe_FirstFree,                                   { *private*                            }
        pe_NFree,                                       { number of free colors                }
        pe_FirstShared,                                 { *private*                            }
        pe_NShared    : WORD;                           { *private*                            }
        pe_RefCnt     : Pointer;                        { *private*                            }
        pe_AllocList  : Pointer;                        { *private*                            }
        pe_ViewPort   : pViewPort;                    { back pointer to viewport             }
        pe_SharableColors : WORD;                       { the number of sharable colors.       }
    end;
{ flags values for ObtainPen }
Const
 PENB_EXCLUSIVE = 0;
 PENB_NO_SETCOLOR = 1;

 PENF_EXCLUSIVE = 1;
 PENF_NO_SETCOLOR = 2;

{ obsolete names for PENF_xxx flags: }

 PEN_EXCLUSIVE = PENF_EXCLUSIVE;
 PEN_NO_SETCOLOR = PENF_NO_SETCOLOR;

{ precision values for ObtainBestPen : }

 PRECISION_EXACT = -1;
 PRECISION_IMAGE = 0;
 PRECISION_ICON  = 16;
 PRECISION_GUI   = 32;


{ tags for ObtainBestPen: }
 OBP_Precision = $84000000;
 OBP_FailIfBad = $84000001;

{ From V39, MakeVPort() will return an error if there is not enough memory,
 * or the requested mode cannot be opened with the requested depth with the
 * given bitmap (for higher bandwidth alignments).
 }

 MVP_OK        =  0;       { you want to see this one }
 MVP_NO_MEM    =  1;       { insufficient memory for intermediate workspace }
 MVP_NO_VPE    =  2;       { ViewPort does not have a ViewPortExtra, and
                                 * insufficient memory to allocate a temporary one.
                                 }
 MVP_NO_DSPINS =  3;       { insufficient memory for intermidiate copper
                                 * instructions.
                                 }
 MVP_NO_DISPLAY = 4;       { BitMap data is misaligned for this viewport's
                                 * mode and depth - see AllocBitMap().
                                 }
 MVP_OFF_BOTTOM = 5;       { PRIVATE - you will never see this. }

{ From V39, MrgCop() will return an error if there is not enough memory,
 * or for some reason MrgCop() did not need to make any copper lists.
 }

 MCOP_OK       =  0;       { you want to see this one }
 MCOP_NO_MEM   =  1;       { insufficient memory to allocate the system
                                 * copper lists.
                                 }
 MCOP_NOP      =  2;       { MrgCop() did not merge any copper lists
                                 * (eg, no ViewPorts in the list, or all marked as
                                 * hidden).
                                 }
Type
    pDBufInfo = ^tDBufInfo;
    tDBufInfo = record
        dbi_Link1   : Pointer;
        dbi_Count1  : ULONG;
        dbi_SafeMessage : tMessage;         { replied to when safe to write to old bitmap }
        dbi_UserData1   : Pointer;                     { first user data }

        dbi_Link2   : Pointer;
        dbi_Count2  : ULONG;
        dbi_DispMessage : tMessage; { replied to when new bitmap has been displayed at least
                                                        once }
        dbi_UserData2 : Pointer;                  { second user data }
        dbi_MatchLong : ULONG;
        dbi_CopPtr1,
        dbi_CopPtr2,
        dbi_CopPtr3   : Pointer;
        dbi_BeamPos1,
        dbi_BeamPos2  : WORD;
    end;



   {   include define file for graphics display mode IDs.   }


const

   INVALID_ID                   =   NOT 0;

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

{ normal identifiers }

   MONITOR_ID_MASK              =   $FFFF1000;

   DEFAULT_MONITOR_ID           =   $00000000;
   NTSC_MONITOR_ID              =   $00011000;
   PAL_MONITOR_ID               =   $00021000;

{ the following 22 composite keys are for Modes on the default Monitor.
 * NTSC & PAL "flavors" of these particular keys may be made by or'ing
 * the NTSC or PAL MONITOR_ID with the desired MODE_KEY...
 *
 * For example, to specifically open a PAL HAM interlaced ViewPort
 * (or intuition screen), you would use the modeid of
 * (PAL_MONITOR_ID OR HAMLACE_KEY)
 }

   LORES_KEY                     =  $00000000;
   HIRES_KEY                     =  $00008000;
   SUPER_KEY                     =  $00008020;
   HAM_KEY                       =  $00000800;
   LORESLACE_KEY                 =  $00000004;
   HIRESLACE_KEY                 =  $00008004;
   SUPERLACE_KEY                 =  $00008024;
   HAMLACE_KEY                   =  $00000804;
   LORESDPF_KEY                  =  $00000400;
   HIRESDPF_KEY                  =  $00008400;
   SUPERDPF_KEY                  =  $00008420;
   LORESLACEDPF_KEY              =  $00000404;
   HIRESLACEDPF_KEY              =  $00008404;
   SUPERLACEDPF_KEY              =  $00008424;
   LORESDPF2_KEY                 =  $00000440;
   HIRESDPF2_KEY                 =  $00008440;
   SUPERDPF2_KEY                 =  $00008460;
   LORESLACEDPF2_KEY             =  $00000444;
   HIRESLACEDPF2_KEY             =  $00008444;
   SUPERLACEDPF2_KEY             =  $00008464;
   EXTRAHALFBRITE_KEY            =  $00000080;
   EXTRAHALFBRITELACE_KEY        =  $00000084;
{ New for AA ChipSet (V39) }
   HIRESHAM_KEY                  =  $00008800;
   SUPERHAM_KEY                  =  $00008820;
   HIRESEHB_KEY                  =  $00008080;
   SUPEREHB_KEY                  =  $000080a0;
   HIRESHAMLACE_KEY              =  $00008804;
   SUPERHAMLACE_KEY              =  $00008824;
   HIRESEHBLACE_KEY              =  $00008084;
   SUPEREHBLACE_KEY              =  $000080a4;
{ Added for V40 - may be useful modes for some games or animations. }
   LORESSDBL_KEY                 =  $00000008;
   LORESHAMSDBL_KEY              =  $00000808;
   LORESEHBSDBL_KEY              =  $00000088;
   HIRESHAMSDBL_KEY              =  $00008808;


{ VGA identifiers }

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
{ New for AA ChipSet (V39) }
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
{ These ModeIDs are the scandoubled equivalents of the above, with the
 * exception of the DualPlayfield modes, as AA does not allow for scandoubling
 * dualplayfield.
 }
   VGAEXTRALORESDBL_KEY          =  $00031000;
   VGALORESDBL_KEY               =  $00039000;
   VGAPRODUCTDBL_KEY             =  $00039020;
   VGAEXTRALORESHAMDBL_KEY       =  $00031800;
   VGALORESHAMDBL_KEY            =  $00039800;
   VGAPRODUCTHAMDBL_KEY          =  $00039820;
   VGAEXTRALORESEHBDBL_KEY       =  $00031080;
   VGALORESEHBDBL_KEY            =  $00039080;
   VGAPRODUCTEHBDBL_KEY          =  $000390a0;

{ a2024 identifiers }

   A2024_MONITOR_ID              =  $00041000;

   A2024TENHERTZ_KEY             =  $00041000;
   A2024FIFTEENHERTZ_KEY         =  $00049000;

{ prototype identifiers (private) }

   PROTO_MONITOR_ID              =  $00051000;


{ These monitors and modes were added for the V38 release. }

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
{ New AA modes (V39) }
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
 * exception of the DualPlayfield modes, as AA does not allow for scandoubling
 * dualplayfield.
 }
   EURO72EXTRALORESDBL_KEY       =  $00061000;
   EURO72LORESDBL_KEY            =  $00069000;
   EURO72PRODUCTDBL_KEY          =  $00069020;
   EURO72EXTRALORESHAMDBL_KEY    =  $00061800;
   EURO72LORESHAMDBL_KEY         =  $00069800;
   EURO72PRODUCTHAMDBL_KEY       =  $00069820;
   EURO72EXTRALORESEHBDBL_KEY    =  $00061080;
   EURO72LORESEHBDBL_KEY         =  $00069080;
   EURO72PRODUCTEHBDBL_KEY       =  $000690a0;


   EURO36_MONITOR_ID             =  $00071000;

{ Euro36 modeids can be ORed with the default modeids a la NTSC and PAL.
 * For example, Euro36 SuperHires is
 * (EURO36_MONITOR_ID OR SUPER_KEY)
 }

   SUPER72_MONITOR_ID            =  $00081000;

{ Super72 modeids can be ORed with the default modeids a la NTSC and PAL.
 * For example, Super72 SuperHiresLace (80$600) is
 * (SUPER72_MONITOR_ID OR SUPERLACE_KEY).
 * The following scandoubled Modes are the exception:
 }
   SUPER72LORESDBL_KEY           =  $00081008;
   SUPER72HIRESDBL_KEY           =  $00089008;
   SUPER72SUPERDBL_KEY           =  $00089028;
   SUPER72LORESHAMDBL_KEY        =  $00081808;
   SUPER72HIRESHAMDBL_KEY        =  $00089808;
   SUPER72SUPERHAMDBL_KEY        =  $00089828;
   SUPER72LORESEHBDBL_KEY        =  $00081088;
   SUPER72HIRESEHBDBL_KEY        =  $00089088;
   SUPER72SUPEREHBDBL_KEY        =  $000890a8;


{ These monitors and modes were added for the V39 release. }

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


{ Use these tags for passing to BestModeID() (V39) }

   SPECIAL_FLAGS = $100E;
   { Original:
     SPECIAL_FLAGS = DIPF_IS_DUALPF OR DIPF_IS_PF2PRI OR DIPF_IS_HAM OR DIPF_IS_EXTRAHALFBRITE;
     ( Mu?te aufgrund eines Fehler in PCQ ge?ndert werden )
   }


   BIDTAG_DIPFMustHave     = $80000001;      { mask of the DIPF_ flags the ModeID must have }
                                { Default - NULL }
   BIDTAG_DIPFMustNotHave  = $80000002;      { mask of the DIPF_ flags the ModeID must not have }
                                { Default - SPECIAL_FLAGS }
   BIDTAG_ViewPort         = $80000003;      { ViewPort for which a ModeID is sought. }
                                { Default - NULL }
   BIDTAG_NominalWidth     = $80000004;      { \ together make the aspect ratio and }
   BIDTAG_NominalHeight    = $80000005;      { / override the vp->Width/Height. }
                                { Default - SourceID NominalDimensionInfo,
                                 * or vp->DWidth/Height, or (640 * 200),
                                 * in that preferred order.
                                 }
   BIDTAG_DesiredWidth     = $80000006;      { \ Nominal Width and Height of the }
   BIDTAG_DesiredHeight    = $80000007;      { / returned ModeID. }
                                { Default - same as Nominal }
   BIDTAG_Depth            = $80000008;      { ModeID must support this depth. }
                                { Default - vp->RasInfo->BitMap->Depth or 1 }
   BIDTAG_MonitorID        = $80000009;      { ModeID must use this monitor. }
                                { Default - use best monitor available }
   BIDTAG_SourceID         = $8000000a;      { instead of a ViewPort. }
                                { Default - VPModeID(vp) if BIDTAG_ViewPort is
                                 * specified, else leave the DIPFMustHave and
                                 * DIPFMustNotHave values untouched.
                                 }
   BIDTAG_RedBits        =  $8000000b;      { \                            }
   BIDTAG_BlueBits       =  $8000000c;      {  > Match up from the database }
   BIDTAG_GreenBits      =  $8000000d;      { /                            }
                                            { Default - 4 }
   BIDTAG_GfxPrivate     =  $8000000e;      { Private }


const

{ bplcon0 defines }

    MODE_640    = $8000;
    PLNCNTMSK   = $7;           { how many bit planes? }
                                { 0 = none, 1->6 = 1->6, 7 = reserved }
    PLNCNTSHFT  = 12;           { bits to shift for bplcon0 }
    PF2PRI      = $40;          { bplcon2 bit }
    COLORON     = $0200;        { disable color burst }
    DBLPF       = $400;
    HOLDNMODIFY = $800;
    INTERLACE   = 4;            { interlace mode for 400 }

{ bplcon1 defines }

    PFA_FINE_SCROLL             = $F;
    PFB_FINE_SCROLL_SHIFT       = 4;
    PF_FINE_SCROLL_MASK         = $F;

{ display window start and stop defines }

    DIW_HORIZ_POS       = $7F;  { horizontal start/stop }
    DIW_VRTCL_POS       = $1FF; { vertical start/stop }
    DIW_VRTCL_POS_SHIFT = $7;

{ Data fetch start/stop horizontal position }

    DFTCH_MASK  = $FF;

{ vposr bits }

    VPOSRLOF    = $8000;

  {   include define file for displayinfo database }

{ the "public" handle to a DisplayInfoRecord }
Type

 DisplayInfoHandle = APTR;

{ datachunk type identifiers }

CONST
 DTAG_DISP            =   $80000000;
 DTAG_DIMS            =   $80001000;
 DTAG_MNTR            =   $80002000;
 DTAG_NAME            =   $80003000;
 DTAG_VEC             =   $80004000;      { internal use only }

Type

  pQueryHeader = ^tQueryHeader;
  tQueryHeader = record
   tructID,                    { datachunk type identifier }
   DisplayID,                  { copy of display record key   }
   SkipID,                     { TAG_SKIP -- see tagitems.h }
   Length  :  ULONG;         { length of local data in double-longwords }
  END;

  pDisplayInfo = ^tDisplayInfo;
  tDisplayInfo = record
   Header : tQueryHeader;
   NotAvailable : Word;    { IF NULL available, else see defines }
   PropertyFlags : ULONG;  { Properties of this mode see defines }
   Resolution : tPoint;     { ticks-per-pixel X/Y                 }
   PixelSpeed : Word;     { aproximation in nanoseconds         }
   NumStdSprites : Word;  { number of standard amiga sprites    }
   PaletteRange : Word;   { distinguishable shades available    }
   SpriteResolution : tPoint; { std sprite ticks-per-pixel X/Y    }
   pad : Array[0..3] of Byte;
   RedBits     : Byte;
   GreenBits   : Byte;
   BlueBits    : Byte;
   pad2        : array [0..4] of Byte;
   reserved : Array[0..1] of ULONG;    { terminator }
  END;

{ availability }

CONST
 DI_AVAIL_NOCHIPS        =$0001;
 DI_AVAIL_NOMONITOR      =$0002;
 DI_AVAIL_NOTWITHGENLOCK =$0004;

{ mode properties }

 DIPF_IS_LACE          =  $00000001;
 DIPF_IS_DUALPF        =  $00000002;
 DIPF_IS_PF2PRI        =  $00000004;
 DIPF_IS_HAM           =  $00000008;

 DIPF_IS_ECS           =  $00000010;      {      note: ECS modes (SHIRES, VGA, AND **
                                                 PRODUCTIVITY) do not support      **
                                                 attached sprites.                 **
                                                                                        }
 DIPF_IS_AA            =  $00010000;      { AA modes - may only be available
                                                ** if machine has correct memory
                                                ** type to support required
                                                ** bandwidth - check availability.
                                                ** (V39)
                                                }
 DIPF_IS_PAL           =  $00000020;
 DIPF_IS_SPRITES       =  $00000040;
 DIPF_IS_GENLOCK       =  $00000080;

 DIPF_IS_WB            =  $00000100;
 DIPF_IS_DRAGGABLE     =  $00000200;
 DIPF_IS_PANELLED      =  $00000400;
 DIPF_IS_BEAMSYNC      =  $00000800;

 DIPF_IS_EXTRAHALFBRITE = $00001000;

{ The following DIPF_IS_... flags are new for V39 }
  DIPF_IS_SPRITES_ATT           =  $00002000;      { supports attached sprites }
  DIPF_IS_SPRITES_CHNG_RES      =  $00004000;      { supports variable sprite resolution }
  DIPF_IS_SPRITES_BORDER        =  $00008000;      { sprite can be displayed in the border }
  DIPF_IS_SCANDBL               =  $00020000;      { scan doubled }
  DIPF_IS_SPRITES_CHNG_BASE     =  $00040000;
                                                   { can change the sprite base colour }
  DIPF_IS_SPRITES_CHNG_PRI      =  $00080000;
                                                                                        { can change the sprite priority
                                                                                        ** with respect to the playfield(s).
                                                                                        }
  DIPF_IS_DBUFFER       =  $00100000;      { can support double buffering }
  DIPF_IS_PROGBEAM      =  $00200000;      { is a programmed beam-sync mode }
  DIPF_IS_FOREIGN       =  $80000000;      { this mode is not native to the Amiga }

Type
 pDimensionInfo =^tDimensionInfo;
 tDimensionInfo = record
  Header : tQueryHeader;
  MaxDepth,             { log2( max number of colors ) }
  MinRasterWidth,       { minimum width in pixels      }
  MinRasterHeight,      { minimum height in pixels     }
  MaxRasterWidth,       { maximum width in pixels      }
  MaxRasterHeight : Word;      { maximum height in pixels     }
  Nominal,              { "standard" dimensions        }
  MaxOScan,             { fixed, hardware dependant    }
  VideoOScan,           { fixed, hardware dependant    }
  TxtOScan,             { editable via preferences     }
  StdOScan  : tRectangle; { editable via preferences     }
  pad  : Array[0..13] of Byte;
  reserved : Array[0..1] of Longint;          { terminator }
 END;

 pMonitorInfo = ^tMonitorInfo;
 tMonitorInfo = record
  Header : tQueryHeader;
  Mspc   : pMonitorSpec;         { pointer to monitor specification  }
  ViewPosition,                    { editable via preferences          }
  ViewResolution : tPoint;          { standard monitor ticks-per-pixel  }
  ViewPositionRange : tRectangle;   { fixed, hardware dependant }
  TotalRows,                       { display height in scanlines       }
  TotalColorClocks,                { scanline width in 280 ns units    }
  MinRow        : Word;            { absolute minimum active scanline  }
  Compatibility : smallint;           { how this coexists with others     }
  pad : Array[0..31] of Byte;
  MouseTicks    : tPoint;
  DefaultViewPosition : tPoint;
  PreferredModeID : ULONG;
  reserved : Array[0..1] of ULONG;          { terminator }
 END;

{ monitor compatibility }

CONST
 MCOMPAT_MIXED =  0;       { can share display with other MCOMPAT_MIXED }
 MCOMPAT_SELF  =  1;       { can share only within same monitor }
 MCOMPAT_NOBODY= -1;       { only one viewport at a time }

 DISPLAYNAMELEN = 32;

Type
 pNameInfo = ^tNameInfo;
 tNameInfo = record
  Header : tQueryHeader;
  Name   : Array[0..DISPLAYNAMELEN-1] of Char;
  reserved : Array[0..1] of ULONG;          { terminator }
 END;


{****************************************************************************}

{ The following VecInfo structure is PRIVATE, for our use only
 * Touch these, and burn! (V39)
 }
Type
 pVecInfo = ^tVecInfo;
 tVecInfo = record
        Header  : tQueryHeader;
        Vec     : Pointer;
        Data    : Pointer;
        vi_Type : WORD;               { Type in C Includes }
        pad     : Array[0..2] of WORD;
        reserved : Array[0..1] of ULONG;
 end;


CONST
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
{ The following tags are V39 specific. They will be ignored (returing error -3) by
        earlier versions }
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
 * VC_xxx,state         set the state of attribute 'xxx' to value 'state'
 * VC_xxx_QUERY,&var    get the state of attribute 'xxx' and store it into the longword
 *                      pointed to by &var.
 *
 * The following are new for V40:
 }

 VC_IntermediateCLUpdate       =  $80000080;
        { default=true. When set graphics will update the intermediate copper
         * lists on color changes, etc. When false, it won't, and will be faster.
         }
 VC_IntermediateCLUpdate_Query =  $80000081;

 VC_NoColorPaletteLoad         =  $80000082;
        { default = false. When set, graphics will only load color 0
         * for this ViewPort, and so the ViewPort's colors will come
         * from the previous ViewPort's.
         *
         * NB - Using this tag and VTAG_FULLPALETTE_SET together is undefined.
         }
 VC_NoColorPaletteLoad_Query   =  $80000083;

 VC_DUALPF_Disable             =  $80000084;
        { default = false. When this flag is set, the dual-pf bit
           in Dual-Playfield screens will be turned off. Even bitplanes
           will still come from the first BitMap and odd bitplanes
           from the second BitMap, and both R[xy]Offsets will be
           considered. This can be used (with appropriate palette
           selection) for cross-fades between differently scrolling
           images.
           When this flag is turned on, colors will be loaded for
           the viewport as if it were a single viewport of depth
           depth1+depth2 }
 VC_DUALPF_Disable_Query       =  $80000085;


const

    SPRITE_ATTACHED     = $80;

type

    pSimpleSprite = ^tSimpleSprite;
    tSimpleSprite = record
        posctldata      : Pointer;
        height          : Word;
        x,y             : Word;        { current position }
        num             : Word;
    end;

    pExtSprite = ^tExtSprite;
    tExtSprite = record
        es_SimpleSprite : tSimpleSprite;         { conventional simple sprite structure }
        es_wordwidth    : WORD;                 { graphics use only, subject to change }
        es_flags        : WORD;                 { graphics use only, subject to change }
    end;

const
{ tags for AllocSpriteData() }
 SPRITEA_Width          = $81000000;
 SPRITEA_XReplication   = $81000002;
 SPRITEA_YReplication   = $81000004;
 SPRITEA_OutputHeight   = $81000006;
 SPRITEA_Attached       = $81000008;
 SPRITEA_OldDataFormat  = $8100000a;      { MUST pass in outputheight if using this tag }

{ tags for GetExtSprite() }
 GSTAG_SPRITE_NUM = $82000020;
 GSTAG_ATTACHED   = $82000022;
 GSTAG_SOFTSPRITE = $82000024;

{ tags valid for either GetExtSprite or ChangeExtSprite }
 GSTAG_SCANDOUBLED     =  $83000000;      { request "NTSC-Like" height if possible. }


Type
    pBitScaleArgs = ^tBitScaleArgs;
    tBitScaleArgs = record
    bsa_SrcX, bsa_SrcY,                 { source origin }
    bsa_SrcWidth, bsa_SrcHeight,        { source size }
    bsa_XSrcFactor, bsa_YSrcFactor,     { scale factor denominators }
    bsa_DestX, bsa_DestY,               { destination origin }
    bsa_DestWidth, bsa_DestHeight,      { destination size result }
    bsa_XDestFactor, bsa_YDestFactor : Word;   { scale factor numerators }
    bsa_SrcBitMap,                           { source BitMap }
    bsa_DestBitMap : pBitMap;              { destination BitMap }
    bsa_Flags   : ULONG;              { reserved.  Must be zero! }
    bsa_XDDA, bsa_YDDA : Word;         { reserved }
    bsa_Reserved1,
    bsa_Reserved2 : Longint;
   END;

  {    tag definitions for GetRPAttr, SetRPAttr     }

const
 RPTAG_Font            =  $80000000;      { get/set font }
 RPTAG_APen            =  $80000002;      { get/set apen }
 RPTAG_BPen            =  $80000003;      { get/set bpen }
 RPTAG_DrMd            =  $80000004;      { get/set draw mode }
 RPTAG_OutlinePen      =  $80000005;      { get/set outline pen. corrected case. }
 RPTAG_WriteMask       =  $80000006;      { get/set WriteMask }
 RPTAG_MaxPen          =  $80000007;      { get/set maxpen }

 RPTAG_DrawBounds      =  $80000008;      { get only rastport draw bounds. pass &rect }






type

    pGfxBase = ^tGfxBase;
    tGfxBase = record
        LibNode         : tLibrary;
        ActiView        : pView;      { ViewPtr }
        copinit         : pcopinit; { (copinitptr) ptr to copper start up list }
        cia             : Pointer;      { for 8520 resource use }
        blitter         : Pointer;      { for future blitter resource use }
        LOFlist         : Pointer;
        SHFlist         : Pointer;
        blthd,
        blttl           : Pointer;//pbltnode;
        bsblthd,
        bsblttl         : Pointer; //pbltnode;      { Previous four are (bltnodeptr) }
        vbsrv,
        timsrv,
        bltsrv          : tInterrupt;
        TextFonts       : tList;
        DefaultFont     : pTextFont;      { TextFontPtr }
        Modes           : Word;        { copy of current first bplcon0 }
        VBlank          : Shortint;
        Debug           : Shortint;
        BeamSync        : smallint;
        system_bplcon0  : smallint; { it is ored into each bplcon0 for display }
        SpriteReserved  : Byte;
        bytereserved    : Byte;
        Flags           : Word;
        BlitLock        : smallint;
        BlitNest        : smallint;

        BlitWaitQ       : tList;
        BlitOwner       : pTask;      { TaskPtr }
        TOF_WaitQ       : tList;
        DisplayFlags    : Word;        { NTSC PAL GENLOC etc}

                { Display flags are determined at power on }

        SimpleSprites   : Pointer;      { SimpleSpritePtr ptr }
        MaxDisplayRow   : Word;        { hardware stuff, do not use }
        MaxDisplayColumn : Word;       { hardware stuff, do not use }
        NormalDisplayRows : Word;
        NormalDisplayColumns : Word;

        { the following are for standard non interlace, 1/2 wb width }

        NormalDPMX      : Word;        { Dots per meter on display }
        NormalDPMY      : Word;        { Dots per meter on display }
        LastChanceMemory : pSignalSemaphore;     { SignalSemaphorePtr }
        LCMptr          : Pointer;
        MicrosPerLine   : Word;        { 256 time usec/line }
        MinDisplayColumn : Word;
        ChipRevBits0    : Byte;
        MemType         : Byte;
        crb_reserved  :  Array[0..3] of Byte;
        monitor_id  : Word;             { normally null }
        hedley  : Array[0..7] of ULONG;
        hedley_sprites  : Array[0..7] of ULONG;     { sprite ptrs for intuition mouse }
        hedley_sprites1 : Array[0..7] of ULONG;            { sprite ptrs for intuition mouse }
        hedley_count    : smallint;
        hedley_flags    : Word;
        hedley_tmp      : smallint;
        hash_table      : Pointer;
        current_tot_rows : Word;
        current_tot_cclks : Word;
        hedley_hint     : Byte;
        hedley_hint2    : Byte;
        nreserved       : Array[0..3] of ULONG;
        a2024_sync_raster : Pointer;
        control_delta_pal : Word;
        control_delta_ntsc : Word;
        current_monitor : pMonitorSpec;
        MonitorList     : tList;
        default_monitor : pMonitorSpec;
        MonitorListSemaphore : pSignalSemaphore;
        DisplayInfoDataBase : Pointer;
        TopLine      : Word;
        ActiViewCprSemaphore : pSignalSemaphore;
        UtilityBase  : Pointer;           { for hook AND tag utilities   }
        ExecBase     : Pointer;              { to link with rom.lib }
        bwshifts     : Pointer;
        StrtFetchMasks,
        StopFetchMasks,
        Overrun,
        RealStops    : Pointer;
        SpriteWidth,                    { current width (in words) of sprites }
        SpriteFMode  : WORD;            { current sprite fmode bits    }
        SoftSprites,                    { bit mask of size change knowledgeable sprites }
        arraywidth   : Shortint;
        DefaultSpriteWidth : WORD;      { what width intuition wants }
        SprMoveDisable : Shortint;
        WantChips,
        BoardMemType,
        Bugs         : Byte;
        gb_LayersBase : Pointer;
        ColorMask    : ULONG;
        IVector,
        IData        : Pointer;
        SpecialCounter : ULONG;         { special for double buffering }
        DBList       : Pointer;
        MonitorFlags : WORD;
        ScanDoubledSprites,
        BP3Bits      : Byte;
        MonitorVBlank  : tAnalogSignalInterval;
        natural_monitor  : pMonitorSpec;
        ProgData     : Pointer;
        ExtSprites   : Byte;
        pad3         : Byte;
        GfxFlags     : WORD;
        VBCounter    : ULONG;
        HashTableSemaphore  : pSignalSemaphore;
        HWEmul       : Array[0..8] of Pointer;
    end;

const

    NTSC        = 1;
    GENLOC      = 2;
    PAL         = 4;
    TODA_SAFE   = 8;

    BLITMSG_FAULT = 4;

{ bits defs for ChipRevBits }
   GFXB_BIG_BLITS = 0 ;
   GFXB_HR_AGNUS  = 0 ;
   GFXB_HR_DENISE = 1 ;
   GFXB_AA_ALICE  = 2 ;
   GFXB_AA_LISA   = 3 ;
   GFXB_AA_MLISA  = 4 ;      { internal use only. }

   GFXF_BIG_BLITS = 1 ;
   GFXF_HR_AGNUS  = 1 ;
   GFXF_HR_DENISE = 2 ;
   GFXF_AA_ALICE  = 4 ;
   GFXF_AA_LISA   = 8 ;
   GFXF_AA_MLISA  = 16;      { internal use only }

{ Pass ONE of these to SetChipRev() }
   SETCHIPREV_A   = GFXF_HR_AGNUS;
   SETCHIPREV_ECS = (GFXF_HR_AGNUS OR GFXF_HR_DENISE);
   SETCHIPREV_AA  = (GFXF_AA_ALICE OR GFXF_AA_LISA OR SETCHIPREV_ECS);
   SETCHIPREV_BEST= $ffffffff;

{ memory type }
   BUS_16         = 0;
   NML_CAS        = 0;
   BUS_32         = 1;
   DBL_CAS        = 2;
   BANDWIDTH_1X   = (BUS_16 OR NML_CAS);
   BANDWIDTH_2XNML= BUS_32;
   BANDWIDTH_2XDBL= DBL_CAS;
   BANDWIDTH_4X   = (BUS_32 OR DBL_CAS);

{ GfxFlags (private) }
   NEW_DATABASE   = 1;

   GRAPHICSNAME   : PChar  = 'graphics.library';


var
    GfxBase : pLibrary;

procedure AddAnimOb(AnOb : PAnimOb; AnKey : PPAnimOb; Rp : PRastPort);
procedure AddBob(bob : PBob; Rp : PRastPort);
function AddDisplayDriverA(P: Pointer; tags: PTagItem): LongInt;
procedure AddFont(TextFont : PTextFont);
procedure AddVSprite(VSprite : PVSprite; Rp : PRastPort);
function AllocBitMap(sizex : LongWord; Sizey : LongWord; Depth : LongWord; Flags : LongWord;const Friend_bitmap : PBitMap) : PBitMap;
function AllocDBufInfo(Vp : PViewPort) : PDBufInfo;
function AllocRaster(Width : LongWord; Height : LongWord) : PChar;
function AllocSpriteDataA(const Bm : PBitMap;const tags : PTagItem) : PExtSprite;
procedure AndRectRegion(region : PRegion;const rectangle : pRectangle);
function AndRegionRegion(const srcRegion : PRegion; destRegion : PRegion) : BOOLEAN;
procedure Animate(AnKey : PPAnimOb; Rp : PRastPort);
function AreaDraw(Rp : PRastPort; x : LongInt; y : LongInt) : LongInt;
function AreaEllipse(Rp : PRastPort; xCenter : word; yCenter : word; a : word; b : word) : LongInt;
function AreaEnd(Rp : PRastPort) : LongInt;
function AreaMove(Rp : PRastPort; x : LongInt; y : LongInt) : LongInt;
procedure AskFont(Rp : PRastPort; textAttr : pTextAttr);
function AskSoftStyle(Rp : PRastPort) : LongWord;
function AttachPalExtra(cm : pColorMap; Vp : PViewPort) : LongInt;
function AttemptLockLayerRom(layer : pLayer) : BOOLEAN;
function BestModeIDA(const tags : PTagItem) : LongWord;
procedure BitMapScale(bitScaleArgs : pBitScaleArgs);
function BltBitMap(const srcBitMap : PBitMap; xSrc : LongInt; ySrc : LongInt; destBitMap : PBitMap; xDest : LongInt; yDest : LongInt; xSize : LongInt; ySize : LongInt; minterm : LongWord; mask : LongWord; tempA : PChar) : LongInt;
procedure BltBitMapRastPort(const srcBitMap : PBitMap; xSrc : LongInt; ySrc : LongInt; destRP : PRastPort; xDest : LongInt; yDest : LongInt; xSize : LongInt; ySize : LongInt; minterm : LongWord);
procedure BltClear(memBlock : PChar; byteCount : LongWord; Flags : LongWord);
procedure BltMaskBitMapRastPort(const srcBitMap : PBitMap; xSrc : LongInt; ySrc : LongInt; destRP : PRastPort; xDest : LongInt; yDest : LongInt; xSize : LongInt; ySize : LongInt; minterm : LongWord;const bltMask : PChar);
procedure BltPattern(Rp : PRastPort;const mask : PChar; xMin : LongInt; yMin : LongInt; xMax : LongInt; yMax : LongInt; maskBPR : LongWord);
procedure BltTemplate(const source : PChar; xSrc : LongInt; srcMod : LongInt; destRP : PRastPort; xDest : LongInt; yDest : LongInt; xSize : LongInt; ySize : LongInt);
function CalcIVG(v : pView; Vp : PViewPort) : WORD;
procedure CBump(copList : pUCopList);
function ChangeExtSpriteA(Vp : PViewPort; oldsprite : PExtSprite; newsprite : PExtSprite;const tags : PTagItem) : LongInt;
procedure ChangeSprite(Vp : PViewPort; sprite : pSimpleSprite; newData : pWORD);
procedure ChangeVPBitMap(Vp : PViewPort; Bm : PBitMap; db : PDBufInfo);
procedure ClearEOL(Rp : PRastPort);
function ClearRectRegion(region : PRegion;const rectangle : pRectangle) : BOOLEAN;
procedure ClearRegion(region : PRegion);
procedure ClearScreen(Rp : PRastPort);
procedure ClipBlit(srcRP : PRastPort; xSrc : LongInt; ySrc : LongInt; destRP : PRastPort; xDest : LongInt; yDest : LongInt; xSize : LongInt; ySize : LongInt; minterm : LongWord);
procedure CloseFont(TextFont : PTextFont);
function CloseMonitor(monitorSpec : pMonitorSpec) : BOOLEAN;
procedure CMove(copList : pUCopList; destination : Pointer; data : LongInt);
function CoerceMode(Vp : PViewPort; monitorid : LongWord; Flags : LongWord) : LongWord;
procedure CopySBitMap(layer : pLayer);
function CreateRastPort(): PRastPort;
function CloneRastPort(Rp: PRastPort): PRastPort;
procedure DeinitRastPort(Rp: PRastPort);
procedure FreeRastPort(Rp: PRastPort);
procedure CWait(copList : pUCopList; v : LongInt; h : LongInt);
procedure DisownBlitter;
procedure DisposeRegion(region : PRegion);
procedure DoCollision(Rp : PRastPort);
procedure Draw(Rp : PRastPort; x : LongInt; y : LongInt);
procedure DrawEllipse(Rp : PRastPort; xCenter : LongInt; yCenter : LongInt; a : LongInt; b : LongInt);
procedure DrawGList(Rp : PRastPort; Vp : PViewPort);
procedure EraseRect(Rp : PRastPort; xMin : LongInt; yMin : LongInt; xMax : LongInt; yMax : LongInt);
function ExtendFont(font : PTextFont;const fontTags : PTagItem) : LongWord;
function FindColor(cm : pColorMap; r : LongWord; g : LongWord; b : LongWord; maxcolor : LongInt) : LongInt;
function FindDisplayInfo(displayID : LongWord) : Pointer;
function Flood(Rp : PRastPort; mode : LongWord; x : LongInt; y : LongInt) : BOOLEAN;
procedure FontExtent(const font : PTextFont; fontExtent : pTextExtent);
procedure FreeBitMap(Bm : PBitMap);
procedure FreeColorMap(colorMap : pColorMap);
procedure FreeCopList(copList : pCopList);
procedure FreeCprList(cprList : pcprlist);
procedure FreeDBufInfo(dbi : PDBufInfo);
procedure FreeGBuffers(AnOb : PAnimOb; Rp : PRastPort; flag : LongInt);
procedure FreeRaster(p : PChar; Width : LongWord; Height : LongWord);
procedure FreeSprite(num : LongInt);
procedure FreeSpriteData(sp : PExtSprite);
procedure FreeVPortCopLists(Vp : PViewPort);
function GetAPen(Rp : PRastPort) : LongWord;
function GetBitMapAttr(const Bm : PBitMap; attrnum : LongWord) : LongWord;
function GetBPen(Rp : PRastPort) : LongWord;
function GetColorMap(entries : LongInt) : pColorMap;
function GetDisplayInfoData(const handle : Pointer; buf : PChar; size : LongWord; tagID : LongWord; displayID : LongWord) : LongWord;
function GetDrMd(Rp : PRastPort) : LongWord;
function GetExtSpriteA(ss : PExtSprite;const tags : PTagItem) : LongInt;
function GetGBuffers(AnOb : PAnimOb; Rp : PRastPort; flag : LongInt) : BOOLEAN;
function GetOutlinePen(Rp : PRastPort) : LongWord;
procedure GetRGB32(const cm : pColorMap; firstcolor : LongWord; ncolors : LongWord; table : pulong);
function GetRGB4(colorMap : pColorMap; entry : LongInt) : LongWord;
procedure GetRPAttrsA(const Rp : PRastPort;const tags : PTagItem);
function GetSprite(sprite : pSimpleSprite; num : LongInt) : smallint;
function GetVPModeID(const Vp : PViewPort) : LongInt;
procedure GfxAssociate(const associateNode : Pointer; gfxNodePtr : Pointer);
procedure GfxFree(gfxNodePtr : Pointer);
function GfxLookUp(const associateNode : Pointer) : Pointer;
function GfxNew(gfxNodeType : LongWord) : Pointer;
procedure InitArea(areaInfo : pAreaInfo; vectorBuffer : Pointer; maxVectors : LongInt);
procedure InitBitMap(bitMap : PBitMap; Depth : LongInt; Width : LongInt; Height : LongInt);
procedure InitGels(head : PVSprite; tail : PVSprite; gelsInfo : pGelsInfo);
procedure InitGMasks(AnOb : PAnimOb);
procedure InitMasks(VSprite : PVSprite);
procedure InitRastPort(Rp : PRastPort);
function InitTmpRas(tmpRas : pTmpRas; buffer : PLANEPTR; size : LongInt) : pTmpRas;
procedure InitView(view : pView);
procedure InitVPort(Vp : PViewPort);
procedure LoadRGB32(Vp : PViewPort;const table : pULONG);
procedure LoadRGB4(Vp : PViewPort;const colors : pWord; count : LongInt);
procedure LoadView(view : pView);
procedure LockLayerRom(layer : pLayer);
function MakeVPort(view : pView; Vp : PViewPort) : LongWord;
function ModeNotAvailable(modeID : LongWord) : LongInt;
procedure Move(Rp : PRastPort; x : LongInt; y : LongInt);
procedure MoveSprite(Vp : PViewPort; sprite : pSimpleSprite; x : LongInt; y : LongInt);
function MrgCop(view : pView) : LongWord;
function NewRegion : PRegion;
function NextDisplayInfo(displayID : LongWord) : LongWord;
function ObtainBestPenA(cm : pColorMap; r : LongWord; g : LongWord; b : LongWord;const tags : PTagItem) : LongInt;
function ObtainPen(cm : pColorMap; n : LongWord; r : LongWord; g : LongWord; b : LongWord; f : LongInt) : LongWord;
function OpenFont(textAttr : pTextAttr) : PTextFont;
function OpenMonitor(const monitorName : PChar; displayID : LongWord) : pMonitorSpec;
function OrRectRegion(region : PRegion;const rectangle : pRectangle) : BOOLEAN;
function OrRegionRegion(const srcRegion : PRegion; destRegion : PRegion) : BOOLEAN;
procedure OwnBlitter;
procedure PolyDraw(Rp : PRastPort; count : LongInt;const polyTable : pLongint);
procedure QBlit(blit : pbltnode);
procedure QBSBlit(blit : pbltnode);
function ReadPixel(Rp : PRastPort; x : LongInt; y : LongInt) : LongWord;
function ReadPixelArray8(Rp : PRastPort; xstart : LongWord; ystart : LongWord; xstop : LongWord; ystop : LongWord; array_ : pointer; temprp : PRastPort) : LongInt;
function ReadPixelLine8(Rp : PRastPort; xstart : LongWord; ystart : LongWord; Width : LongWord; array_ : pointer; tempRP : PRastPort) : LongInt;
procedure RectFill(Rp : PRastPort; xMin : LongInt; yMin : LongInt; xMax : LongInt; yMax : LongInt);
procedure ReleasePen(cm : pColorMap; n : LongWord);
procedure RemFont(TextFont : PTextFont);
procedure RemIBob(bob : PBob; Rp : PRastPort; Vp : PViewPort);
procedure RemVSprite(VSprite : PVSprite);
function ScalerDiv(factor : LongWord; numerator : LongWord; denominator : LongWord) : WORD;
procedure ScrollRaster(Rp : PRastPort; dx : LongInt; dy : LongInt; xMin : LongInt; yMin : LongInt; xMax : LongInt; yMax : LongInt);
procedure ScrollRasterBF(Rp : PRastPort; dx : LongInt; dy : LongInt; xMin : LongInt; yMin : LongInt; xMax : LongInt; yMax : LongInt);
procedure ScrollVPort(Vp : PViewPort);
procedure SetABPenDrMd(Rp : PRastPort; apen : LongWord; bpen : LongWord; drawmode : LongWord);
procedure SetAPen(Rp : PRastPort; pen : LongWord);
procedure SetBPen(Rp : PRastPort; pen : LongWord);
function SetChipRev(want : LongWord) : LongWord;
procedure SetCollision(num : LongWord; routine : tPROCEDURE; gelsInfo : pGelsInfo);
procedure SetDrMd(Rp : PRastPort; drawMode : LongWord);
function SetFont(Rp : PRastPort;const TextFont : PTextFont) : LongInt;
procedure SetMaxPen(Rp : PRastPort; maxpen : LongWord);
function SetOutlinePen(Rp : PRastPort; pen : LongWord) : LongWord;
procedure SetRast(Rp : PRastPort; pen : LongWord);
procedure SetRGB32(Vp : PViewPort; n : LongWord; r : LongWord; g : LongWord; b : LongWord);
procedure SetRGB32CM(cm : pColorMap; n : LongWord; r : LongWord; g : LongWord; b : LongWord);
procedure SetRGB4(Vp : PViewPort; index : LongInt; red : LongWord; green : LongWord; blue : LongWord);
procedure SetRGB4CM(colorMap : pColorMap; index : LongInt; red : LongWord; green : LongWord; blue : LongWord);
procedure SetRPAttrsA(Rp : PRastPort;const tags : PTagItem);
function SetSoftStyle(Rp : PRastPort; style : LongWord; enable : LongWord) : LongWord;
function SetWriteMask(Rp : PRastPort; msk : LongWord) : LongWord;
procedure SortGList(Rp : PRastPort);
procedure StripFont(font : PTextFont);
procedure SyncSBitMap(layer : pLayer);
function GText(Rp : PRastPort;const string_ : PChar; count : LongWord) : LongInt;
function TextExtent(Rp : PRastPort;const string_ : PChar; count : LongInt; _textExtent : pTextExtent) : smallint;
function TextFit(Rp : PRastPort;const string_ : PChar; strLen : LongWord; textExtent : pTextExtent; constrainingExtent : pTextExtent; strDirection : LongInt; constrainingBitWidth : LongWord; constrainingBitHeight : LongWord) : LongWord;
function TextLength(Rp : PRastPort;const string_ : PChar; count : LongWord) : smallint;
function UCopperListInit(uCopList : pUCopList; n : LongInt) : pCopList;
procedure UnlockLayerRom(layer : pLayer);
function VBeamPos : LongInt;
function VideoControl(colorMap : pColorMap; tagarray : PTagItem) : BOOLEAN;
procedure WaitBlit;
procedure WaitBOVP(Vp : PViewPort);
procedure WaitTOF;
function WeighTAMatch(reqTextAttr : pTextAttr; targetTextAttr : pTextAttr; targetTags : PTagItem) : smallint;
procedure WriteChunkyPixels(Rp : PRastPort; xstart : LongWord; ystart : LongWord; xstop : LongWord; ystop : LongWord; array_ : pointer; bytesperrow : LongInt);
function WritePixel(Rp : PRastPort; x : LongInt; y : LongInt) : LongInt;
function WritePixelArray8(Rp : PRastPort; xstart : LongWord; ystart : LongWord; xstop : LongWord; ystop : LongWord; array_ : pointer; temprp : PRastPort) : LongInt;
function WritePixelLine8(Rp : PRastPort; xstart : LongWord; ystart : LongWord; Width : LongWord; array_ : pointer; tempRP : PRastPort) : LongInt;
function XorRectRegion(region : PRegion;const rectangle : pRectangle) : BOOLEAN;
function XorRegionRegion(const srcRegion : PRegion; destRegion : PRegion) : BOOLEAN;

{ gfxmacros }
(*
procedure BNDRYOFF (w: PRastPort);
procedure InitAnimate (animkey: PPAnimOb);
procedure SetAfPt(w: PRastPort;p: Pointer; n: Byte);
procedure SetDrPt(w: PRastPort;p: Word);
procedure SetOPen(w: PRastPort;c: Byte);
procedure SetWrMsk(w: PRastPort; m: Byte);

procedure SafeSetOutlinePen(w : PRastPort; c : byte);
procedure SafeSetWriteMask( w : PRastPort ; m : smallint ) ;

procedure OFF_DISPLAY (cust: pCustom);
procedure ON_DISPLAY (cust: pCustom);
procedure OFF_SPRITE (cust: pCustom);
procedure ON_SPRITE (cust: pCustom);
procedure OFF_VBLANK (cust: pCustom);
procedure ON_VBLANK (cust: pCustom);
*)

IMPLEMENTATION
(*
procedure BNDRYOFF (w: PRastPort);
BEGIN
    WITH w^ DO BEGIN
        Flags := Flags AND (NOT AREAOUTLINE);
    END;
END;

procedure InitAnimate (animkey: PPAnimOb);
BEGIN
    animkey^ := NIL;
END;

procedure SetAfPt(w: PRastPort;p: Pointer; n: Byte);
BEGIN
    WITH w^ DO
    BEGIN
        AreaPtrn := p;
        AreaPtSz := n;
    END;
END;

procedure SetDrPt(w: PRastPort;p: Word);
BEGIN
    WITH w^ DO
    BEGIN
        LinePtrn    := p;
        Flags       := Flags OR FRST_DOT;
        linpatcnt   := 15;
    END;
END;

procedure SetOPen(w: PRastPort;c: Byte);
BEGIN
    WITH w^ DO
    BEGIN
        AOlPen  := c;
        Flags   := Flags OR AREAOUTLINE;
    END;
END;

{ This function is fine, but FOR OS39 the SetWriteMask() gfx function
  should be prefered because it SHOULD operate WITH gfx boards as well.
  At least I hope it does.... }
procedure SetWrMsk(w: PRastPort; m: Byte);
BEGIN
    w^.Mask := m;
END;

procedure SafeSetOutlinePen(w : PRastPort; c : byte);
begin
    IF pGfxBase(GfxBase)^.LibNode.Lib_Version < 39 THEN begin
        w^.AOlPen := c;
        w^.Flags := w^.Flags OR AREAOUTLINE;
    END ELSE begin
        c := SetOutlinePen(w,c);
    END;
END;

procedure SafeSetWriteMask( w : PRastPort ; m : smallint ) ;
  VAR x : smallint ;
BEGIN
  IF pGfxBase(GfxBase)^.LibNode.Lib_Version < 39 THEN w^.Mask := BYTE(m)
  ELSE x := SetWriteMask( w, m );
END;

procedure OFF_DISPLAY (cust: pCustom);
BEGIN
    cust^.dmacon := BITCLR OR DMAF_RASTER;
END;

procedure ON_DISPLAY (cust: pCustom);
BEGIN
    cust^.dmacon := BITSET OR DMAF_RASTER;
END;

procedure OFF_SPRITE (cust: pCustom);
BEGIN
    cust^.dmacon := BITCLR OR DMAF_SPRITE;
END;

procedure ON_SPRITE (cust: pCustom);
BEGIN
    cust^.dmacon := BITSET OR DMAF_SPRITE;
END;

procedure OFF_VBLANK (cust: pCustom);
BEGIN
    cust^.intena := BITCLR OR INTF_VERTB;
END;

procedure ON_VBLANK (cust: pCustom);
BEGIN
    cust^.intena := BITSET OR INTF_VERTB;
END;

*)

procedure AddAnimOb(AnOb : PAnimOb; AnKey : PPAnimOb; Rp : PRastPort);
type
  TLocalCall = procedure(AnOb : PAnimOb; AnKey : PPAnimOb; Rp : PRastPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 26));
  Call(AnOb, AnKey, Rp, GfxBase);
end;

procedure AddBob(bob : PBob; Rp : PRastPort);
type
  TLocalCall = procedure(bob : PBob; Rp : PRastPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 16));
  Call(bob, Rp, GfxBase);
end;

function AddDisplayDriverA(P: Pointer; tags: PTagItem): LongInt;
type
  TLocalCall = function(P: Pointer; tags: PTagItem; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 181));
  Result := Call(P, tags, GfxBase);
end;

procedure AddFont(TextFont : PTextFont);
type
  TLocalCall = procedure(TextFont : PTextFont; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 80));
  Call(TextFont, GfxBase);
end;

procedure AddVSprite(VSprite : PVSprite; Rp : PRastPort);
type
  TLocalCall = procedure(VSprite : PVSprite; Rp : PRastPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 17));
  Call(VSprite, Rp, GfxBase);
end;

function AllocBitMap(sizex : LongWord; Sizey : LongWord; Depth : LongWord; Flags : LongWord;const Friend_bitmap : PBitMap): PBitMap;
type
  TLocalCall = function(sizex : LongWord; Sizey : LongWord; Depth : LongWord; Flags : LongWord;const Friend_bitmap : PBitMap; Base: Pointer): PBitMap; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 153));
  Result := Call(sizex, Sizey, Depth, Flags, Friend_bitmap, GfxBase);
end;

function AllocDBufInfo(Vp : PViewPort): PDBufInfo;
type
  TLocalCall = function(Vp : PViewPort; Base: Pointer): PDBufInfo; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 161));
  Result := Call(Vp, GfxBase);
end;

function AllocRaster(Width : LongWord; Height : LongWord) : PChar;
type
  TLocalCall = function(Width : LongWord; Height : LongWord; Base: Pointer): PChar; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 82));
  Result := Call(Width, Height, GfxBase);
end;

function AllocSpriteDataA(const Bm : PBitMap;const tags : PTagItem) : PExtSprite;
type
  TLocalCall = function(const Bm : PBitMap;const tags : PTagItem; Base: Pointer): PExtSprite; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 170));
  Result := Call(Bm, tags, GfxBase);
end;

procedure AndRectRegion(region : PRegion;const rectangle : pRectangle);
type
  TLocalCall = procedure(region : PRegion;const rectangle : pRectangle; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 84));
  Call(region, rectangle, GfxBase);
end;

function AndRegionRegion(const srcRegion : PRegion; destRegion : PRegion) : BOOLEAN;
type
  TLocalCall = function(const srcRegion : PRegion; destRegion : PRegion; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 104));
  Result := Call(srcRegion, destRegion, GfxBase);
end;

procedure AndRectRegionND(region : PRegion;const rectangle : pRectangle);
type
  TLocalCall = procedure(region : PRegion;const rectangle : pRectangle; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 107));
  Call(region, rectangle, GfxBase);
end;

function AndRegionRegionND(const srcRegion : PRegion; destRegion : PRegion) : BOOLEAN;
type
  TLocalCall = function(const srcRegion : PRegion; destRegion : PRegion; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 108));
  Result := Call(srcRegion, destRegion, GfxBase);
end;

procedure Animate(AnKey : PPAnimOb; Rp : PRastPort);
type
  TLocalCall = procedure(AnKey : PPAnimOb; Rp : PRastPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 27));
  Call(AnKey, Rp, GfxBase);
end;

function AreaDraw(Rp : PRastPort; x : LongInt; y : LongInt) : LongInt;
type
  TLocalCall = function(Rp : PRastPort; x : LongInt; y : LongInt; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 43));
  Result := Call(Rp, x, y, GfxBase);
end;

function AreaEllipse(Rp : PRastPort; xCenter : word; yCenter : word; a : word; b : word) : LongInt;
type
  TLocalCall = function(Rp : PRastPort; xCenter : word; yCenter : word; a : word; b : word; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 31));
  Result := Call(Rp, xCenter, yCenter, a, b, GfxBase);
end;

function AreaEnd(Rp : PRastPort) : LongInt;
type
  TLocalCall = function(Rp : PRastPort; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 44));
  Result := Call(Rp, GfxBase);
end;

function AreaMove(Rp : PRastPort; x : LongInt; y : LongInt) : LongInt;
type
  TLocalCall = function(Rp : PRastPort; x : LongInt; y : LongInt; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 42));
  Result := Call(Rp, x, y, GfxBase);
end;

procedure AskFont(Rp : PRastPort; textAttr : pTextAttr);
type
  TLocalCall = procedure(Rp : PRastPort; textAttr : pTextAttr; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 79));
  Call(Rp, textAttr, GfxBase);
end;

function AskSoftStyle(Rp : PRastPort) : LongWord;
type
  TLocalCall = function(Rp : PRastPort; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 14));
  Result := Call(Rp, GfxBase);
end;

function AttachPalExtra(cm : pColorMap; Vp : PViewPort) : LongInt;
type
  TLocalCall = function(cm : pColorMap; Vp : PViewPort; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 139));
  Result := Call(cm, Vp, GfxBase);
end;

function AttemptLockLayerRom(layer : pLayer) : BOOLEAN;
type
  TLocalCall = function(layer : pLayer; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 109));
  Result := Call(layer, GfxBase);
end;

function BestModeIDA(const tags : PTagItem) : LongWord;
type
  TLocalCall = function(const tags : PTagItem; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 175));
  Result := Call(tags, GfxBase);
end;

procedure BitMapScale(bitScaleArgs : pBitScaleArgs);
type
  TLocalCall = procedure(bitScaleArgs : pBitScaleArgs; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 113));
  Call(bitScaleArgs, GfxBase);
end;

function BltBitMap(const srcBitMap : PBitMap; xSrc : LongInt; ySrc : LongInt; destBitMap : PBitMap; xDest : LongInt; yDest : LongInt; xSize : LongInt; ySize : LongInt; minterm : LongWord; mask : LongWord; tempA : PChar) : LongInt;
type
  TLocalCall = function(const srcBitMap : PBitMap; xSrc : LongInt; ySrc : LongInt; destBitMap : PBitMap; xDest : LongInt; yDest : LongInt; xSize : LongInt; ySize : LongInt; minterm : LongWord; mask : LongWord; tempA : PChar; Base: Pointer): LongInt ; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 5));
  Result := Call(srcBitMap, xSrc, ySrc, destBitMap, xDest, yDest, xSize, ySize, minterm, mask, tempA, GfxBase);
end;

procedure BltBitMapRastPort(const srcBitMap : PBitMap; xSrc : LongInt; ySrc : LongInt; destRP : PRastPort; xDest : LongInt; yDest : LongInt; xSize : LongInt; ySize : LongInt; minterm : LongWord);
type
  TLocalCall = procedure(const srcBitMap : PBitMap; xSrc : LongInt; ySrc : LongInt; destRP : PRastPort; xDest : LongInt; yDest : LongInt; xSize : LongInt; ySize : LongInt; minterm : LongWord; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 101));
  Call(srcBitMap, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm, GfxBase);
end;

procedure BltClear(memBlock : PChar; byteCount : LongWord; Flags : LongWord);
type
  TLocalCall = procedure(memBlock : PChar; byteCount : LongWord; Flags : LongWord; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 50));
  Call(memBlock, byteCount, Flags, GfxBase);
end;

procedure BltMaskBitMapRastPort(const srcBitMap : PBitMap; xSrc : LongInt; ySrc : LongInt; destRP : PRastPort; xDest : LongInt; yDest : LongInt; xSize : LongInt; ySize : LongInt; minterm : LongWord;const bltMask : PChar);
type
  TLocalCall = procedure(const srcBitMap : PBitMap; xSrc : LongInt; ySrc : LongInt; destRP : PRastPort; xDest : LongInt; yDest : LongInt; xSize : LongInt; ySize : LongInt; minterm : LongWord;const bltMask : PChar; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 106));
  Call(srcBitMap, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm, bltMask, GfxBase);
end;

procedure BltPattern(Rp : PRastPort;const mask : PChar; xMin : LongInt; yMin : LongInt; xMax : LongInt; yMax : LongInt; maskBPR : LongWord);
type
  TLocalCall = procedure(Rp : PRastPort;const mask : PChar; xMin : LongInt; yMin : LongInt; xMax : LongInt; yMax : LongInt; maskBPR : LongWord; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 52));
  Call(Rp, mask, xMin, yMin, xMax, yMax, maskBPR, GfxBase);
end;

procedure BltTemplate(const source : PChar; xSrc : LongInt; srcMod : LongInt; destRP : PRastPort; xDest : LongInt; yDest : LongInt; xSize : LongInt; ySize : LongInt);
type
  TLocalCall = procedure(const source : PChar; xSrc : LongInt; srcMod : LongInt; destRP : PRastPort; xDest : LongInt; yDest : LongInt; xSize : LongInt; ySize : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 6));
  Call(source, xSrc, srcMod, destRP, xDest, yDest, xSize, ySize, GfxBase);
end;

function CalcIVG(v : pView; Vp : PViewPort) : WORD;
type
  TLocalCall = function(v : pView; Vp : PViewPort; Base: Pointer): WORD; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 138));
  Result := Call(v, Vp, GfxBase);
end;

procedure CBump(copList : pUCopList);
type
  TLocalCall = procedure(copList : pUCopList; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 62));
  Call(copList, GfxBase);
end;

function ChangeExtSpriteA(Vp : PViewPort; oldsprite : PExtSprite; newsprite : PExtSprite;const tags : PTagItem) : LongInt;
type
  TLocalCall = function(Vp : PViewPort; oldsprite : PExtSprite; newsprite : PExtSprite;const tags : PTagItem; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 171));
  Result := Call(Vp, oldsprite, newsprite, tags, GfxBase);
end;

procedure ChangeSprite(Vp : PViewPort; sprite : pSimpleSprite; newData : pWORD);
type
  TLocalCall = procedure(Vp : PViewPort; sprite : pSimpleSprite; newData : pWORD; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 70));
  Call(Vp, sprite, newData, GfxBase);
end;

procedure ChangeVPBitMap(Vp : PViewPort; Bm : PBitMap; db : PDBufInfo);
type
  TLocalCall = procedure(Vp : PViewPort; Bm : PBitMap; db : PDBufInfo; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 157));
  Call(Vp, Bm, db, GfxBase);
end;

procedure ClearEOL(Rp : PRastPort);
type
  TLocalCall = procedure(Rp : PRastPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 7));
  Call(Rp, GfxBase);
end;

function ClearRectRegion(region : PRegion;const rectangle : pRectangle) : BOOLEAN;
type
  TLocalCall = function(region : PRegion;const rectangle : pRectangle; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 87));
  Result := Call(region, rectangle, GfxBase);
end;

function ClearRectRegionND(region : PRegion;const rectangle : pRectangle) : BOOLEAN;
type
  TLocalCall = function(region : PRegion;const rectangle : pRectangle; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 124));
  Result := Call(region, rectangle, GfxBase);
end;

procedure ClearRegionRegionND(region1 : PRegion; region2 : PRegion);
type
  TLocalCall = procedure(region1 : PRegion; region2 : PRegion; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 141));
  Call(region1,region2, GfxBase);
end;

procedure ClearRegion(region : PRegion);
type
  TLocalCall = procedure(region : PRegion; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 88));
  Call(region, GfxBase);
end;

procedure ClearScreen(Rp : PRastPort);
type
  TLocalCall = procedure(Rp : PRastPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 8));
  Call(Rp, GfxBase);
end;

procedure ClipBlit(srcRP : PRastPort; xSrc : LongInt; ySrc : LongInt; destRP : PRastPort; xDest : LongInt; yDest : LongInt; xSize : LongInt; ySize : LongInt; minterm : LongWord);
type
  TLocalCall = procedure(srcRP : PRastPort; xSrc : LongInt; ySrc : LongInt; destRP : PRastPort; xDest : LongInt; yDest : LongInt; xSize : LongInt; ySize : LongInt; minterm : LongWord; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 92));
  Call(srcRP, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm, GfxBase);
end;

procedure CloseFont(TextFont : PTextFont);
type
  TLocalCall = procedure(TextFont : PTextFont; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 13));
  Call(TextFont, GfxBase);
end;

function CloseMonitor(monitorSpec : pMonitorSpec) : BOOLEAN;
type
  TLocalCall = function(monitorSpec : pMonitorSpec; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 120));
  Result := Call(monitorSpec, GfxBase);
end;

procedure CMove(copList : pUCopList; destination : Pointer; data : LongInt);
type
  TLocalCall = procedure(copList : pUCopList; destination : Pointer; data : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 63));
  Call(copList, destination, data, GfxBase);
end;

function CoerceMode(Vp : PViewPort; monitorid : LongWord; Flags : LongWord) : LongWord;
type
  TLocalCall = function(Vp : PViewPort; monitorid : LongWord; Flags : LongWord; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 156));
  Result := Call(Vp, monitorid, Flags, GfxBase);
end;

procedure CopySBitMap(layer : pLayer);
type
  TLocalCall = procedure(layer : pLayer; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 75));
  Call(layer, GfxBase);
end;

function CreateRastPort(): PRastPort;
type
  TLocalCall = function(Base: Pointer): PRastPort; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 177));
  Result := Call(GfxBase);
end;

function CloneRastPort(Rp: PRastPort): PRastPort;
type
  TLocalCall = function(Rp: PRastPort; Base: Pointer): PRastPort; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 178));
  Result := Call(Rp, GfxBase);
end;

procedure DeinitRastPort(Rp: PRastPort);
type
  TLocalCall = procedure(Rp: PRastPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 179));
  Call(Rp, GfxBase);
end;

procedure FreeRastPort(Rp: PRastPort);
type
  TLocalCall = procedure(Rp: PRastPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 180));
  Call(Rp, GfxBase);
end;

procedure CWait(copList : pUCopList; v : LongInt; h : LongInt);
type
  TLocalCall = procedure(copList : pUCopList; v : LongInt; h : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 63));
  Call(copList, v, h, GfxBase);
end;

procedure DisownBlitter;
type
  TLocalCall = procedure(Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 77));
  Call(GfxBase);
end;

procedure DisposeRegion(region : PRegion);
type
  TLocalCall = procedure(region : PRegion; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 89));
  Call(region, GfxBase);
end;

procedure DoCollision(Rp : PRastPort);
type
  TLocalCall = procedure(Rp : PRastPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 18));
  Call(Rp, GfxBase);
end;

procedure Draw(Rp : PRastPort; x : LongInt; y : LongInt);
type
  TLocalCall = procedure(Rp : PRastPort; x : LongInt; y : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 41));
  Call(Rp, x, y, GfxBase);
end;

procedure DrawEllipse(Rp : PRastPort; xCenter : LongInt; yCenter : LongInt; a : LongInt; b : LongInt);
type
  TLocalCall = procedure(Rp : PRastPort; xCenter : LongInt; yCenter : LongInt; a : LongInt; b : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 30));
  Call(Rp, xCenter, yCenter, a, b, GfxBase);
end;

procedure DrawGList(Rp : PRastPort; Vp : PViewPort);
type
  TLocalCall = procedure(Rp : PRastPort; Vp : PViewPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 19));
  Call(Rp, Vp, GfxBase);
end;

procedure EraseRect(Rp : PRastPort; xMin : LongInt; yMin : LongInt; xMax : LongInt; yMax : LongInt);
type
  TLocalCall = procedure(Rp : PRastPort; xMin : LongInt; yMin : LongInt; xMax : LongInt; yMax : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 135));
  Call(Rp, xMin, yMin, xMax, yMax, GfxBase);
end;

function ExtendFont(font : PTextFont;const fontTags : PTagItem) : LongWord;
type
  TLocalCall = function(font : PTextFont;const fontTags : PTagItem; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 136));
  Result := Call(font, fontTags, GfxBase);
end;

function FindColor(cm : pColorMap; r : LongWord; g : LongWord; b : LongWord; maxcolor : LongInt) : LongInt;
type
  TLocalCall = function(cm : pColorMap; r : LongWord; g : LongWord; b : LongWord; maxcolor : LongInt; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 168));
  Result := Call(cm, r, g, b, maxcolor, GfxBase);
end;

function FindDisplayInfo(displayID : LongWord) : Pointer;
type
  TLocalCall = function(displayID : LongWord; Base: Pointer): Pointer; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 122));
  Result := Call(displayID, GfxBase);
end;

function Flood(Rp : PRastPort; mode : LongWord; x : LongInt; y : LongInt) : BOOLEAN;
type
  TLocalCall = function(Rp : PRastPort; mode : LongWord; x : LongInt; y : LongInt; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 55));
  Result := Call(Rp, mode, x, y, GfxBase);
end;

procedure FontExtent(const font : PTextFont; fontExtent : pTextExtent);
type
  TLocalCall = procedure(const font : PTextFont; fontExtent : pTextExtent; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 127));
  Call(font, fontExtent, GfxBase);
end;

procedure FreeBitMap(Bm : PBitMap);
type
  TLocalCall = procedure(Bm : PBitMap; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 154));
  Call(Bm, GfxBase);
end;

procedure FreeColorMap(colorMap : pColorMap);
type
  TLocalCall = procedure(colorMap : pColorMap; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 96));
  Call(colorMap, GfxBase);
end;

procedure FreeCopList(copList : pCopList);
type
  TLocalCall = procedure(copList : pCopList; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 91));
  Call(copList, GfxBase);
end;

procedure FreeCprList(cprList : pcprlist);
type
  TLocalCall = procedure(cprList : pcprlist; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 94));
  Call(cprList, GfxBase);
end;

procedure FreeDBufInfo(dbi : PDBufInfo);
type
  TLocalCall = procedure(dbi : PDBufInfo; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 162));
  Call(dbi, GfxBase);
end;

procedure FreeGBuffers(AnOb : PAnimOb; Rp : PRastPort; flag : LongInt);
type
  TLocalCall = procedure(AnOb : PAnimOb; Rp : PRastPort; flag : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 100));
  Call(AnOb, Rp, flag, GfxBase);
end;

procedure FreeRaster(p : PChar; Width : LongWord; Height : LongWord);
type
  TLocalCall = procedure(p : PChar; Width : LongWord; Height : LongWord; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 83));
  Call(p, Width, Height, GfxBase);
end;

procedure FreeSprite(num : LongInt);
type
  TLocalCall = procedure(num : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 69));
  Call(num, GfxBase);
end;

procedure FreeSpriteData(sp : PExtSprite);
type
  TLocalCall = procedure(sp : PExtSprite; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 172));
  Call(sp, GfxBase);
end;

procedure FreeVPortCopLists(Vp : PViewPort);
type
  TLocalCall = procedure(Vp : PViewPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 91));
  Call(Vp, GfxBase);
end;

function GetAPen(Rp : PRastPort) : LongWord;
type
  TLocalCall = function(Rp : PRastPort; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 143));
  Result := Call(Rp, GfxBase);
end;

function GetBitMapAttr(const Bm : PBitMap; attrnum : LongWord) : LongWord;
type
  TLocalCall = function(const Bm : PBitMap; attrnum : LongWord; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 160));
  Result := Call(Bm, attrnum, GfxBase);
end;

function GetBPen(Rp : PRastPort) : LongWord;
type
  TLocalCall = function(Rp : PRastPort; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 144));
  Result := Call(Rp, GfxBase);
end;

function GetColorMap(entries : LongInt) : pColorMap;
type
  TLocalCall = function(entries : LongInt; Base: Pointer): pColorMap; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 95));
  Result := Call(entries, GfxBase);
end;

function GetDisplayInfoData(const handle : Pointer; buf : PChar; size : LongWord; tagID : LongWord; displayID : LongWord) : LongWord;
type
  TLocalCall = function(const handle : Pointer; buf : PChar; size : LongWord; tagID : LongWord; displayID : LongWord; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 126));
  Result := Call(handle, buf, size, tagID, displayID, GfxBase);
end;

function GetDrMd(Rp : PRastPort) : LongWord;
type
  TLocalCall = function(Rp : PRastPort; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 145));
  Result := Call(Rp, GfxBase);
end;

function GetExtSpriteA(ss : PExtSprite;const tags : PTagItem) : LongInt;
type
  TLocalCall = function(ss : PExtSprite;const tags : PTagItem; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 155));
  Result := Call(ss, tags, GfxBase);
end;

function GetGBuffers(AnOb : PAnimOb; Rp : PRastPort; flag : LongInt) : BOOLEAN;
type
  TLocalCall = function(AnOb : PAnimOb; Rp : PRastPort; flag : LongInt; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 28));
  Result := Call(AnOb, Rp, flag, GfxBase);
end;

function GetOutlinePen(Rp : PRastPort) : LongWord;
type
  TLocalCall = function(Rp : PRastPort; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 146));
  Result := Call(Rp, GfxBase);
end;

procedure GetRGB32(const cm : pColorMap; firstcolor : LongWord; ncolors : LongWord; table : pUlong);
type
  TLocalCall = procedure(const cm : pColorMap; firstcolor : LongWord; ncolors : LongWord; table : pUlong; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 150));
  Call(cm, firstcolor, ncolors, table, GfxBase);
end;

function GetRGB4(colorMap : pColorMap; entry : LongInt) : LongWord;
type
  TLocalCall = function(colorMap : pColorMap; entry : LongInt; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 97));
  Result := Call(colorMap, entry, GfxBase);
end;

procedure GetRPAttrsA(const Rp : PRastPort;const tags : PTagItem);
type
  TLocalCall = procedure(const Rp : PRastPort;const tags : PTagItem; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 174));
  Call(Rp, tags, GfxBase);
end;

function GetSprite(sprite : pSimpleSprite; num : LongInt) : smallint;
type
  TLocalCall = function(sprite : pSimpleSprite; num : LongInt; Base: Pointer): smallint; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 68));
  Result := Call(sprite, num, GfxBase);
end;

function GetVPModeID(const Vp : PViewPort) : LongInt;
type
  TLocalCall = function(const Vp : PViewPort; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 132));
  Result := Call(Vp, GfxBase);
end;

procedure GfxAssociate(const associateNode : Pointer; gfxNodePtr : Pointer);
type
  TLocalCall = procedure(const associateNode : Pointer; gfxNodePtr : Pointer; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 112));
  Call(associateNode, gfxNodePtr, GfxBase);
end;

procedure GfxFree(gfxNodePtr : Pointer);
type
  TLocalCall = procedure(gfxNodePtr : Pointer; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 111));
  Call(gfxNodePtr, GfxBase);
end;

function GfxLookUp(const associateNode : Pointer) : Pointer;
type
  TLocalCall = function(const associateNode : Pointer; Base: Pointer): Pointer; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 117));
  Result := Call(associateNode, GfxBase);
end;

function GfxNew(gfxNodeType : LongWord) : Pointer;
type
  TLocalCall = function(gfxNodeType : LongWord; Base: Pointer): Pointer; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 110));
  Result := Call(gfxNodeType, GfxBase);
end;

procedure InitArea(areaInfo : pAreaInfo; vectorBuffer : Pointer; maxVectors : LongInt);
type
  TLocalCall = procedure(areaInfo : pAreaInfo; vectorBuffer : Pointer; maxVectors : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 47));
  Call(areaInfo, vectorBuffer, maxVectors, GfxBase);
end;

procedure InitBitMap(bitMap : PBitMap; Depth : LongInt; Width : LongInt; Height : LongInt);
type
  TLocalCall = procedure(bitMap : PBitMap; Depth : LongInt; Width : LongInt; Height : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 65));
  Call(bitMap, Depth, Width, Height, GfxBase);
end;

procedure InitGels(head : PVSprite; tail : PVSprite; gelsInfo : pGelsInfo);
type
  TLocalCall = procedure(head : PVSprite; tail : PVSprite; gelsInfo : pGelsInfo; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 20));
  Call(head, tail, gelsInfo, GfxBase);
end;

procedure InitGMasks(AnOb : PAnimOb);
type
  TLocalCall = procedure(AnOb : PAnimOb; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 29));
  Call(AnOb, GfxBase);
end;

procedure InitMasks(VSprite : PVSprite);
type
  TLocalCall = procedure(VSprite : PVSprite; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 22));
  Call(VSprite, GfxBase);
end;

procedure InitRastPort(Rp : PRastPort);
type
  TLocalCall = procedure(Rp : PRastPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 33));
  Call(Rp, GfxBase);
end;

function InitTmpRas(tmpRas : pTmpRas; buffer : PLANEPTR; size : LongInt) : pTmpRas;
type
  TLocalCall = function(tmpRas : pTmpRas; buffer : PLANEPTR; size : LongInt; Base: Pointer): pTmpRas; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 78));
  Result := Call(tmpRas, buffer, size, GfxBase);
end;

procedure InitView(view : pView);
type
  TLocalCall = procedure(view : pView; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 60));
  Call(view, GfxBase);
end;

procedure InitVPort(Vp : PViewPort);
type
  TLocalCall = procedure(Vp : PViewPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 34));
  Call(Vp, GfxBase);
end;

procedure LoadRGB32(Vp : PViewPort;const table : pULONG);
type
  TLocalCall = procedure(Vp : PViewPort;const table : pULONG; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 147));
  Call(Vp, table, GfxBase);
end;

procedure LoadRGB4(Vp : PViewPort;const colors : pWord; count : LongInt);
type
  TLocalCall = procedure(Vp : PViewPort;const colors : pWord; count : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 32));
  Call(Vp, colors, count, GfxBase);
end;

procedure LoadView(view : pView);
type
  TLocalCall = procedure(view : pView; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 37));
  Call(view, GfxBase);
end;

procedure LockLayerRom(layer : pLayer);
type
  TLocalCall = procedure(layer : pLayer; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 72));
  Call(layer, GfxBase);
end;

function MakeVPort(view : pView; Vp : PViewPort) : LongWord;
type
  TLocalCall = function(view : pView; Vp : PViewPort; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 36));
  Result := Call(view, Vp, GfxBase);
end;

function ModeNotAvailable(modeID : LongWord) : LongInt;
type
  TLocalCall = function(modeID : LongWord; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 133));
  Result := Call(modeID, GfxBase);
end;

procedure Move(Rp : PRastPort; x : LongInt; y : LongInt);
type
  TLocalCall = procedure(Rp : PRastPort; x : LongInt; y : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 40));
  Call(Rp, x, y, GfxBase);
end;

procedure MoveSprite(Vp : PViewPort; sprite : pSimpleSprite; x : LongInt; y : LongInt);
type
  TLocalCall = procedure(Vp : PViewPort; sprite : pSimpleSprite; x : LongInt; y : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 71));
  Call(Vp, sprite, x, y, GfxBase);
end;

function MrgCop(view : pView) : LongWord;
type
  TLocalCall = function(view : pView; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 35));
  Result := Call(view, GfxBase);
end;

function NewRegion : PRegion;
type
  TLocalCall = function(Base: Pointer): PRegion; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 86));
  Result := Call(GfxBase);
end;

function NextDisplayInfo(displayID : LongWord) : LongWord;
type
  TLocalCall = function(displayID : LongWord; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 122));
  Result := Call(displayID, GfxBase);
end;

function ObtainBestPenA(cm : pColorMap; r : LongWord; g : LongWord; b : LongWord;const tags : PTagItem) : LongInt;
type
  TLocalCall = function(cm : pColorMap; r : LongWord; g : LongWord; b : LongWord;const tags : PTagItem; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 140));
  Result := Call(cm, r, g, b, tags, GfxBase);
end;

function ObtainPen(cm : pColorMap; n : LongWord; r : LongWord; g : LongWord; b : LongWord; f : LongInt) : LongWord;
type
  TLocalCall = function(cm : pColorMap; n : LongWord; r : LongWord; g : LongWord; b : LongWord; f : LongInt; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 159));
  Result := Call(cm, n, r, g, b, f, GfxBase);
end;

function OpenFont(textAttr : pTextAttr) : PTextFont;
type
  TLocalCall = function(textAttr : pTextAttr; Base: Pointer): PTextFont; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 12));
  Result := Call(textAttr, GfxBase);
end;

function OpenMonitor(const monitorName : PChar; displayID : LongWord) : pMonitorSpec;
type
  TLocalCall = function(const monitorName : PChar; displayID : LongWord; Base: Pointer): pMonitorSpec; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 119));
  Result := Call(monitorName, displayID, GfxBase);
end;

function OrRectRegion(region : PRegion;const rectangle : pRectangle) : BOOLEAN;
type
  TLocalCall = function(region : PRegion;const rectangle : pRectangle; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 85));
  Result := Call(region, rectangle, GfxBase);
end;

function OrRectRegionND(region : PRegion;const rectangle : pRectangle) : BOOLEAN;
type
  TLocalCall = function(region : PRegion;const rectangle : pRectangle; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 123));
  Result := Call(region, rectangle, GfxBase);
end;

function OrRegionRegion(const srcRegion : PRegion; destRegion : PRegion) : BOOLEAN;
type
  TLocalCall = function(const srcRegion : PRegion; destRegion : PRegion; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 102));
  Result := Call(srcRegion, destRegion, GfxBase);
end;

function OrRegionRegionND(const srcRegion : PRegion; destRegion : PRegion) : BOOLEAN;
type
  TLocalCall = function(const srcRegion : PRegion; destRegion : PRegion; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 125));
  Result := Call(srcRegion, destRegion, GfxBase);
end;

procedure OwnBlitter;
type
  TLocalCall = procedure(Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 76));
  Call(GfxBase);
end;

procedure PolyDraw(Rp : PRastPort; count : LongInt;const polyTable : pLongint);
type
  TLocalCall = procedure(Rp : PRastPort; count : LongInt;const polyTable : pLongint; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 56));
  Call(Rp, count, polyTable, GfxBase);
end;

procedure QBlit(blit : pbltnode);
type
  TLocalCall = procedure(blit : pbltnode; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 46));
  Call(blit, GfxBase);
end;

procedure QBSBlit(blit : pbltnode);
type
  TLocalCall = procedure(blit : pbltnode; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 49));
  Call(blit, GfxBase);
end;

function ReadPixel(Rp : PRastPort; x : LongInt; y : LongInt) : LongWord;
type
  TLocalCall = function(Rp : PRastPort; x : LongInt; y : LongInt; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 53));
  Result := Call(Rp, x, y, GfxBase);
end;

function ReadPixelArray8(Rp : PRastPort; xstart : LongWord; ystart : LongWord; xstop : LongWord; ystop : LongWord; array_ : pointer; temprp : PRastPort) : LongInt;
type
  TLocalCall = function(Rp : PRastPort; xstart : LongWord; ystart : LongWord; xstop : LongWord; ystop : LongWord; array_ : pointer; temprp : PRastPort; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 131));
  Result := Call(Rp, xstart, ystart, xstop, ystop, array_, temprp, GfxBase);
end;

function ReadPixelLine8(Rp : PRastPort; xstart : LongWord; ystart : LongWord; Width : LongWord; array_ : pointer; tempRP : PRastPort) : LongInt;
type
  TLocalCall = function(Rp : PRastPort; xstart : LongWord; ystart : LongWord; Width : LongWord; array_ : pointer; tempRP : PRastPort; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 128));
  Result := Call(Rp, xstart, ystart, Width, array_, tempRP, GfxBase);
end;

procedure RectFill(Rp : PRastPort; xMin : LongInt; yMin : LongInt; xMax : LongInt; yMax : LongInt);
type
  TLocalCall = procedure(Rp : PRastPort; xMin : LongInt; yMin : LongInt; xMax : LongInt; yMax : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 51));
  Call(Rp, xMin, yMin, xMax, yMax, GfxBase);
end;

procedure ReleasePen(cm : pColorMap; n : LongWord);
type
  TLocalCall = procedure(cm : pColorMap; n : LongWord; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 158));
  Call(cm, n, GfxBase);
end;

procedure RemFont(TextFont : PTextFont);
type
  TLocalCall = procedure(TextFont : PTextFont; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 81));
  Call(TextFont, GfxBase);
end;

procedure RemIBob(bob : PBob; Rp : PRastPort; Vp : PViewPort);
type
  TLocalCall = procedure(bob : PBob; Rp : PRastPort; Vp : PViewPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 22));
  Call(bob, Rp, Vp, GfxBase);
end;

procedure RemVSprite(VSprite : PVSprite);
type
  TLocalCall = procedure(VSprite : PVSprite; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 23));
  Call(VSprite, GfxBase);
end;

function ScalerDiv(factor : LongWord; numerator : LongWord; denominator : LongWord) : WORD;
type
  TLocalCall = function(factor : LongWord; numerator : LongWord; denominator : LongWord; Base: Pointer): WORD; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 114));
  Result := Call(factor, numerator, denominator, GfxBase);
end;

procedure ScrollRaster(Rp : PRastPort; dx : LongInt; dy : LongInt; xMin : LongInt; yMin : LongInt; xMax : LongInt; yMax : LongInt);
type
  TLocalCall = procedure(Rp : PRastPort; dx : LongInt; dy : LongInt; xMin : LongInt; yMin : LongInt; xMax : LongInt; yMax : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 66));
  Call(Rp, dx, dy, xMin, yMin, xMax, yMax, GfxBase);
end;

procedure ScrollRasterBF(Rp : PRastPort; dx : LongInt; dy : LongInt; xMin : LongInt; yMin : LongInt; xMax : LongInt; yMax : LongInt);
type
  TLocalCall = procedure(Rp : PRastPort; dx : LongInt; dy : LongInt; xMin : LongInt; yMin : LongInt; xMax : LongInt; yMax : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 167));
  Call(Rp, dx, dy, xMin, yMin, xMax, yMax, GfxBase);
end;

procedure ScrollVPort(Vp : PViewPort);
type
  TLocalCall = procedure(Vp : PViewPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 98));
  Call(Vp, GfxBase);
end;

procedure SetABPenDrMd(Rp : PRastPort; apen : LongWord; bpen : LongWord; drawmode : LongWord);
type
  TLocalCall = procedure(Rp : PRastPort; apen : LongWord; bpen : LongWord; drawmode : LongWord; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 149));
  Call(Rp, apen, bpen, drawmode, GfxBase);
end;

procedure SetAPen(Rp : PRastPort; pen : LongWord);
type
  TLocalCall = procedure(Rp : PRastPort; pen : LongWord; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 57));
  Call(Rp, pen, GfxBase);
end;

procedure SetBPen(Rp : PRastPort; pen : LongWord);
type
  TLocalCall = procedure(Rp : PRastPort; pen : LongWord; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 58));
  Call(Rp, pen, GfxBase);
end;

function SetChipRev(want : LongWord) : LongWord;
type
  TLocalCall = function(want : LongWord; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 148));
  Result := Call(want, GfxBase);
end;

procedure SetCollision(num : LongWord; routine : tPROCEDURE; gelsInfo : pGelsInfo);
type
  TLocalCall = procedure(num : LongWord; routine : tPROCEDURE; gelsInfo : pGelsInfo; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 24));
  Call(num, routine, gelsInfo, GfxBase);
end;

procedure SetDrMd(Rp : PRastPort; drawMode : LongWord);
type
  TLocalCall = procedure(Rp : PRastPort; drawMode : LongWord; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 59));
  Call(Rp, drawMode, GfxBase);
end;

function SetFont(Rp : PRastPort;const TextFont : PTextFont) : LongInt;
type
  TLocalCall = function(Rp : PRastPort;const TextFont : PTextFont; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 11));
  Result := Call(Rp, TextFont, GfxBase);
end;

procedure SetMaxPen(Rp : PRastPort; maxpen : LongWord);
type
  TLocalCall = procedure(Rp : PRastPort; maxpen : LongWord; Base: Pointer) ; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 165));
  Call(Rp, maxpen, GfxBase);
end;

function SetOutlinePen(Rp : PRastPort; pen : LongWord) : LongWord;
type
  TLocalCall = function(Rp : PRastPort; pen : LongWord; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 163));
  Result := Call(Rp, pen, GfxBase);
end;

procedure SetRast(Rp : PRastPort; pen : LongWord);
type
  TLocalCall = procedure(Rp : PRastPort; pen : LongWord; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 39));
  Call(Rp, pen, GfxBase);
end;

procedure SetRGB32(Vp : PViewPort; n : LongWord; r : LongWord; g : LongWord; b : LongWord);
type
  TLocalCall = procedure(Vp : PViewPort; n : LongWord; r : LongWord; g : LongWord; b : LongWord; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 142));
  Call(Vp, n, r, g, b, GfxBase);
end;

procedure SetRGB32CM(cm : pColorMap; n : LongWord; r : LongWord; g : LongWord; b : LongWord);
type
  TLocalCall = procedure(cm : pColorMap; n : LongWord; r : LongWord; g : LongWord; b : LongWord; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 166));
  Call(cm, n, r, g, b, GfxBase);
end;

procedure SetRGB4(Vp : PViewPort; index : LongInt; red : LongWord; green : LongWord; blue : LongWord);
type
  TLocalCall = procedure(Vp : PViewPort; index : LongInt; red : LongWord; green : LongWord; blue : LongWord; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 48));
  Call(Vp, index, red, green, blue, GfxBase);
end;

procedure SetRGB4CM(colorMap : pColorMap; index : LongInt; red : LongWord; green : LongWord; blue : LongWord);
type
  TLocalCall = procedure(colorMap : pColorMap; index : LongInt; red : LongWord; green : LongWord; blue : LongWord; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 106));
  Call(colorMap, index, red, green, blue, GfxBase);
end;

procedure SetRPAttrsA(Rp : PRastPort;const tags : PTagItem);
type
  TLocalCall = procedure(Rp : PRastPort;const tags : PTagItem; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 173));
  Call(Rp, tags, GfxBase);
end;

function SetSoftStyle(Rp : PRastPort; style : LongWord; enable : LongWord) : LongWord;
type
  TLocalCall = function(Rp : PRastPort; style : LongWord; enable : LongWord; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 15));
  Result := Call(Rp, style, enable, GfxBase);
end;

function SetWriteMask(Rp : PRastPort; msk : LongWord) : LongWord;
type
  TLocalCall = function(Rp : PRastPort; msk : LongWord; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 164));
  Result := Call(Rp, msk, GfxBase);
end;

procedure SortGList(Rp : PRastPort);
type
  TLocalCall = procedure(Rp : PRastPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 25));
  Call(Rp, GfxBase);
end;

procedure StripFont(font : PTextFont);
type
  TLocalCall = procedure(font : PTextFont; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 137));
  Call(font, GfxBase);
end;

procedure SyncSBitMap(layer : pLayer);
type
  TLocalCall = procedure(layer : pLayer; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 74));
  Call(layer, GfxBase);
end;

function GText(Rp : PRastPort;const string_ : PChar; count : LongWord) : LongInt;
type
  TLocalCall = function(Rp : PRastPort;const string_ : PChar; count : LongWord; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 10));
  Result := Call(Rp, string_, count, GfxBase);
end;

function TextExtent(Rp : PRastPort;const string_ : PChar; count : LongInt; _textExtent : pTextExtent) : smallint;
type
  TLocalCall = function(Rp : PRastPort;const string_ : PChar; count : LongInt; _textExtent : pTextExtent; Base: Pointer): smallint; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 115));
  Result := Call(Rp, string_, count, _textExtent, GfxBase);
end;

function TextFit(Rp : PRastPort;const string_ : PChar; strLen : LongWord; textExtent : pTextExtent; constrainingExtent : pTextExtent; strDirection : LongInt; constrainingBitWidth : LongWord; constrainingBitHeight : LongWord) : LongWord;
type
  TLocalCall = function(Rp : PRastPort;const string_ : PChar; strLen : LongWord; textExtent : pTextExtent; constrainingExtent : pTextExtent; strDirection : LongInt; constrainingBitWidth : LongWord; constrainingBitHeight : LongWord; Base: Pointer): LongWord; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 116));
  Result := Call(Rp, string_, strLen, textExtent, constrainingExtent, strDirection, constrainingBitWidth, constrainingBitHeight, GfxBase);
end;

function TextLength(Rp : PRastPort;const string_ : PChar; count : LongWord) : smallint;
type
  TLocalCall = function(Rp : PRastPort;const string_ : PChar; count : LongWord; Base: Pointer): smallint; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 9));
  Result := Call(Rp, string_, count, GfxBase);
end;

function UCopperListInit(uCopList : pUCopList; n : LongInt) : pCopList;
type
  TLocalCall = function(uCopList : pUCopList; n : LongInt; Base: Pointer): pCopList; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 99));
  Result := Call(uCopList, n, GfxBase);
end;

procedure UnlockLayerRom(layer : pLayer);
type
  TLocalCall = procedure(layer : pLayer; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 73));
  Call(layer, GfxBase);
end;

function VBeamPos : LongInt;
type
  TLocalCall = function(Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 64));
  Result := Call(GfxBase);
end;

function VideoControl(colorMap : pColorMap; tagarray : PTagItem) : BOOLEAN;
type
  TLocalCall = function(colorMap : pColorMap; tagarray : PTagItem; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 118));
  Result := Call(colorMap, tagarray, GfxBase);
end;

procedure WaitBlit;
type
  TLocalCall = procedure(Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 38));
  Call(GfxBase);
end;

procedure WaitBOVP(Vp : PViewPort);
type
  TLocalCall = procedure(Vp : PViewPort; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 67));
  Call(Vp, GfxBase);
end;

procedure WaitTOF;
type
  TLocalCall = procedure(Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 45));
  Call(GfxBase);
end;

function WeighTAMatch(reqTextAttr : pTextAttr; targetTextAttr : pTextAttr; targetTags : PTagItem) : smallint;
type
  TLocalCall = function(reqTextAttr : pTextAttr; targetTextAttr : pTextAttr; targetTags : PTagItem; Base: Pointer): smallint; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 134));
  Result := Call(reqTextAttr, targetTextAttr, targetTags, GfxBase);
end;

procedure WriteChunkyPixels(Rp : PRastPort; xstart : LongWord; ystart : LongWord; xstop : LongWord; ystop : LongWord; array_ : pointer; bytesperrow : LongInt);
type
  TLocalCall = procedure(Rp : PRastPort; xstart : LongWord; ystart : LongWord; xstop : LongWord; ystop : LongWord; array_ : pointer; bytesperrow : LongInt; Base: Pointer); stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 176));
  Call(Rp, xstart, ystart, xstop, ystop, array_, bytesperrow, GfxBase);
end;

function WritePixel(Rp : PRastPort; x : LongInt; y : LongInt) : LongInt;
type
  TLocalCall = function(Rp : PRastPort; x : LongInt; y : LongInt; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 54));
  Result := Call(Rp, x, y, GfxBase);
end;

function WritePixelArray8(Rp : PRastPort; xstart : LongWord; ystart : LongWord; xstop : LongWord; ystop : LongWord; array_ : pointer; temprp : PRastPort) : LongInt;
type
  TLocalCall = function(Rp : PRastPort; xstart : LongWord; ystart : LongWord; xstop : LongWord; ystop : LongWord; array_ : pointer; temprp : PRastPort; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 131));
  Result := Call(Rp, xstart, ystart, xstop, ystop, array_, temprp, GfxBase);
end;

function WritePixelLine8(Rp : PRastPort; xstart : LongWord; ystart : LongWord; Width : LongWord; array_ : pointer; tempRP : PRastPort) : LongInt;
type
  TLocalCall = function(Rp : PRastPort; xstart : LongWord; ystart : LongWord; Width : LongWord; array_ : pointer; tempRP : PRastPort; Base: Pointer): LongInt; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 130));
  Result := Call(Rp, xstart, ystart, Width, array_, tempRP, GfxBase);
end;

function XorRectRegion(region : PRegion;const rectangle : pRectangle) : BOOLEAN;
type
  TLocalCall = function(region : PRegion;const rectangle : pRectangle; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 93));
  Result := Call(region, rectangle, GfxBase);
end;

function XorRectRegionND(region : PRegion;const rectangle : pRectangle) : BOOLEAN;
type
  TLocalCall = function(region : PRegion;const rectangle : pRectangle; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 152));
  Result := Call(region, rectangle, GfxBase);
end;


function XorRegionRegion(const srcRegion : PRegion; destRegion : PRegion) : BOOLEAN;
type
  TLocalCall = function(const srcRegion : PRegion; destRegion : PRegion; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 103));
  Result := Call(srcRegion, destRegion, GfxBase);
end;

function XorRegionRegionND(const srcRegion : PRegion; destRegion : PRegion) : BOOLEAN;
type
  TLocalCall = function(const srcRegion : PRegion; destRegion : PRegion; Base: Pointer): BOOLEAN; stdcall;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(GfxBase, 151));
  Result := Call(srcRegion, destRegion, GfxBase);
end;


initialization
  GfxBase := OpenLibrary('graphics.library',36);
finalization
  CloseLibrary(GfxBase);

END. (* UNIT GRAPHICS *)






