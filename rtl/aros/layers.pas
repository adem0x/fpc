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
    use_auto_openlib. Implemented autoopening
    of the library.
    14 Jan 2003.

    Update for AmigaOS 3.9.
    Changed start code for unit.
    06 Feb 2003.

    Changed integer > smallint,
            cardinal > longword.
    09 Feb 2003.

    nils.sjoholm@mailbox.swipnet.se
}

unit layers;

interface
uses
  exec, agraphics, utility;

const

    LAYERSIMPLE         = 1;
    LAYERSMART          = 2;
    LAYERSUPER          = 4;
    LAYERUPDATING       = $10;
    LAYERBACKDROP       = $40;
    LAYERREFRESH        = $80;
    LAYER_CLIPRECTS_LOST = $100;        { during BeginUpdate }
                                        { or during layerop }
                                        { this happens if out of memory }
    LMN_REGION          = -1;

type
 PLayer_Info = ^TLayer_Info;
 TLayer_Info = record
    top_layer           : PLayer;
    check_lp            : PLayer;              { !! Private !! }
    obs                 : PClipRect;
    FreeClipRects       : PClipRect;              { !! Private !! }
    PrivateReserve1,                            { !! Private !! }
    PrivateReserve2     : LongInt;              { !! Private !! }
    Lock                : TSignalSemaphore;      { !! Private !! }
    gs_Head             : TMinList;              { !! Private !! }
    PrivateReserve3     : SmallInt;                 { !! Private !! }
    PrivateReserve4     : Pointer;              { !! Private !! }
    Flags               : WORD;
    fatten_count        : Shortint;                 { !! Private !! }
    LockLayersCount     : Shortint;                 { !! Private !! }
    PrivateReserve5     : SmallInt;                 { !! Private !! }
    BlankHook,                                  { !! Private !! }
    LayerInfo_extra     : Pointer;              { !! Private !! }
 end;

const
    NEWLAYERINFO_CALLED = 1;

{
 * LAYERS_NOBACKFILL is the value needed to get no backfill hook
 * LAYERS_BACKFILL is the value needed to get the default backfill hook
 }
 LAYERS_NOBACKFILL      = 1;
 LAYERS_BACKFILL        = 0;

 LAYERSNAME : PChar = 'layers.library';

var
  LayersBase : PLibrary;

function BeginUpdate(Layer : PLayer) : LongInt;
function BehindLayer(dummy : LongInt; Layer : PLayer) : LongInt;
function CreateBehindHookLayer(LayerInfo : PLayer_Info; Bitmap1 : PBitMap; x0 : LongInt; y0 : LongInt; x1 : LongInt; y1 : LongInt; Flags : LongInt; Hook : PHook; SuperBitmap2 : PBitMap) : PLayer;
function CreateBehindLayer(LayerInfo : PLayer_Info; Bitmap1 : PBitMap; x0 : LongInt; y0 : LongInt; x1 : LongInt; y1 : LongInt; Flags : LongInt; SuperBitmap2 : PBitMap) : PLayer;
function CreateUpfrontHookLayer(LayerInfo : PLayer_Info; Bitmap1 : PBitMap; x0 : LongInt; y0 : LongInt; x1 : LongInt; y1 : LongInt; Flags : LongInt; Hook : PHook; SuperBitmap2 : PBitMap) : PLayer;
function CreateUpfrontLayer(LayerInfo : PLayer_Info; Bitmap1 : PBitMap; x0 : LongInt; y0 : LongInt; x1 : LongInt; y1 : LongInt; Flags : LongInt; SuperBitmap2 : PBitMap) : PLayer;
function DeleteLayer(dummy : LongInt; Layer : PLayer) : LongInt;
procedure DisposeLayerInfo(LayerInfo : PLayer_Info);
procedure DoHookClipRects(Hook : PHook; RPort : PRastPort;const Rect : PRectangle);
procedure EndUpdate(Layer : PLayer; Flag : LongWord);
function FattenLayerInfo(LayerInfo : PLayer_Info) : LongInt;
procedure InitLayers(LayerInfo : PLayer_Info);
function InstallClipRegion(Layer : PLayer;const Region : PRegion) : PRegion;
function InstallLayerHook(Layer : PLayer; Hook : PHook) : PHook;
function InstallLayerInfoHook(LayerInfo : PLayer_Info;const Hook : PHook) : PHook;
procedure LockLayer(dummy : LongInt; Layer : PLayer);
procedure LockLayerInfo(LayerInfo : PLayer_Info);
procedure LockLayers(LayerInfo : PLayer_Info);
function MoveLayer(dummy : LongInt; Layer : PLayer; dx : LongInt; dy : LongInt) : LongInt;
function MoveLayerInFrontOf(layer_to_move : PLayer; other_layer : PLayer) : LongInt;
function MoveSizeLayer(Layer : PLayer; dx : LongInt; dy : LongInt; dw : LongInt; dh : LongInt) : LongInt;
function NewLayerInfo : PLayer_Info;
procedure ScrollLayer(dummy : LongInt; Layer : PLayer; dx : LongInt; dy : LongInt);
function SizeLayer(dummy : LongInt; Layer : PLayer; dx : LongInt; dy : LongInt) : LongInt;
procedure SortLayerCR(Layer : PLayer; dx : LongInt; dy : LongInt);
procedure SwapBitsRastPortClipRect(rp : PRastPort; cr : PClipRect);
procedure ThinLayerInfo(LayerInfo : PLayer_Info);
procedure UnlockLayer(Layer : PLayer);
procedure UnlockLayerInfo(LayerInfo : PLayer_Info);
procedure UnlockLayers(LayerInfo : PLayer_Info);
function UpfrontLayer(dummy : LongInt; Layer : PLayer) : LongInt;
function WhichLayer(LayerInfo : PLayer_Info; x : LongInt; y : LongInt) : PLayer;

implementation


function BeginUpdate(Layer: PLayer): LongInt;
type
  TLocalCall = function(Layer: PLayer; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 13));
  BeginUpdate := Call(Layer, LayersBase);
end;


function BehindLayer(dummy: LongInt; Layer: PLayer):LongInt;
type
  TLocalCall = function(dummy: LongInt; Layer: PLayer; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 9));
  BehindLayer:= Call(dummy, Layer, LayersBase);
end;


function CreateBehindHookLayer(LayerInfo: PLayer_Info; Bitmap1: PBitMap; x0: LongInt; y0: LongInt; x1: LongInt; y1: LongInt; Flags: LongInt; Hook: PHook; SuperBitmap2: PBitMap): PLayer;
type
  TLocalCall = function(LayerInfo: PLayer_Info; Bitmap1: PBitMap; x0: LongInt; y0: LongInt; x1: LongInt; y1: LongInt; Flags: LongInt; Hook: PHook; SuperBitmap2: PBitMap; LibBase: Pointer): PLayer; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 32));
  CreateBehindHookLayer:= Call(LayerInfo, Bitmap1, x0, y0, x1, y1, Flags, Hook, SuperBitmap2, LayersBase);
end;


function CreateBehindLayer(LayerInfo: PLayer_Info; Bitmap1: PBitMap; x0: LongInt; y0: LongInt; x1: LongInt; y1: LongInt; Flags: LongInt; SuperBitmap2: PBitMap): PLayer;
type
  TLocalCall = function(LayerInfo: PLayer_Info; Bitmap1: PBitMap; x0: LongInt; y0: LongInt; x1: LongInt; y1: LongInt; Flags: LongInt; SuperBitmap2: PBitMap; LibBase: Pointer): PLayer; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 7));
  CreateBehindLayer := Call(LayerInfo, Bitmap1, x0, y0, x1, y1, Flags, SuperBitmap2, LayersBase);
end;


function CreateUpfrontHookLayer(LayerInfo: PLayer_Info; Bitmap1: PBitMap; x0: LongInt; y0: LongInt; x1: LongInt; y1: LongInt; Flags: LongInt; Hook: PHook; SuperBitmap2: PBitMap): PLayer;
type
  TLocalCall = function(LayerInfo: PLayer_Info; Bitmap1: PBitMap; x0: LongInt; y0: LongInt; x1: LongInt; y1: LongInt; Flags: LongInt; Hook: PHook; SuperBitmap2: PBitMap; LibBase: Pointer): PLayer; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 31));
  CreateUpfrontHookLayer := Call( LayerInfo, Bitmap1, x0, y0, x1, y1, Flags, Hook, SuperBitmap2, LayersBase);
end;


function CreateUpfrontLayer(LayerInfo: PLayer_Info; Bitmap1: PBitMap; x0: LongInt; y0: LongInt; x1: LongInt; y1: LongInt; Flags: LongInt; SuperBitmap2: PBitMap): PLayer;
type
  TLocalCall = function(LayerInfo: PLayer_Info; Bitmap1: PBitMap; x0: LongInt; y0: LongInt; x1: LongInt; y1: LongInt; Flags: LongInt; SuperBitmap2: PBitMap; LibBase: Pointer): PLayer; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 6));
  CreateUpfrontLayer := Call(LayerInfo, Bitmap1, x0, y0, x1, y1, Flags, SuperBitmap2, LayersBase);
end;


function DeleteLayer(dummy: LongInt; Layer: PLayer):LongInt;
type
  TLocalCall = function(dummy: LongInt; Layer: PLayer; LibBase: Pointer):LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 15));
  DeleteLayer := Call( dummy, Layer, LayersBase);
end;


procedure DisposeLayerInfo(LayerInfo: PLayer_Info);
type
  TLocalCall = procedure(LayerInfo: PLayer_Info; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 25));
  Call(LayerInfo, LayersBase);
end;


procedure DoHookClipRects(Hook: PHook; RPort: PRastPort; const Rect: PRectangle);
type
  TLocalCall = procedure(Hook : PHook;  RPort: PRastPort; const Rect: PRectangle; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 36));
  Call(Hook, RPort, Rect, LayersBase);
end;


procedure EndUpdate(Layer: PLayer; Flag: LongWord);
type
  TLocalCall = procedure(Layer: PLayer; Flag: LongWord; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 14));
  Call(Layer, flag, LayersBase);
end;


function FattenLayerInfo(LayerInfo: PLayer_Info):LongInt;
type
  TLocalCall = function(LayerInfo: PLayer_Info; LibBase: Pointer):LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 26));
  FattenLayerInfo := Call(LayerInfo, LayersBase);
end;


procedure InitLayers(LayerInfo: PLayer_Info);
type
  TLocalCall = procedure(LayerInfo: PLayer_Info; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase,5));
  Call(LayerInfo, LayersBase);
end;


function InstallClipRegion(Layer: PLayer; const Region: PRegion): PRegion;
type
  TLocalCall = function(Layer: PLayer; const Region: PRegion; LibBase: Pointer): PRegion; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 29));
  InstallClipRegion := Call( Layer, Region, LayersBase);
end;


function InstallLayerHook(Layer: PLayer; Hook: PHook): PHook;
type
  TLocalCall = function(Layer: PLayer; Hook: PHook; LibBase: Pointer): PHook; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 33));
  InstallLayerHook := Call(Layer, Hook, LayersBase);
end;


function InstallLayerInfoHook(LayerInfo: PLayer_Info; const Hook: PHook): PHook;
type
  TLocalCall = function(LayerInfo: PLayer_Info; const Hook: PHook; LibBase: Pointer): PHook; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 34));
  InstallLayerInfoHook := Call(LayerInfo, Hook, LayersBase);
end;


procedure LockLayer(dummy: LongInt; Layer: PLayer);
type
  TLocalCall = procedure(dummy: LongInt; Layer: PLayer; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 16));
  Call(dummy, Layer, LayersBase);
end;


procedure LockLayerInfo(LayerInfo: PLayer_Info);
type
  TLocalCall = procedure(LayerInfo: PLayer_Info; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 20));
  Call(LayerInfo, LayersBase);
end;


procedure LockLayers(LayerInfo: PLayer_Info);
type
  TLocalCall = procedure(LayerInfo: PLayer_Info; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 18));
  Call(LayerInfo, LayersBase);
end;


function MoveLayer(dummy: LongInt; Layer: PLayer; dx: LongInt; dy: LongInt): LongInt;
type
  TLocalCall = function(dummy: LongInt; Layer: PLayer; dx: LongInt; dy: LongInt; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 10));
  MoveLayer := Call(dummy, Layer, dx, dy, LayersBase);
end;


function MoveLayerInFrontOf(layer_to_move: PLayer; other_layer: PLayer):LongInt;
type
  TLocalCall = function(layer_to_move: PLayer; other_layer: PLayer; LibBase: Pointer):LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 28));
  MoveLayerInFrontOf := Call(layer_to_move, other_layer, LayersBase);
end;


function MoveSizeLayer(Layer: PLayer; dx: LongInt; dy: LongInt; dw: LongInt; dh: LongInt): LongInt;
type
  TLocalCall = function(Layer: PLayer; dx: LongInt; dy: LongInt; dw: LongInt; dh: LongInt; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 30));
  MoveSizeLayer := Call(Layer, dx, dy, dw, dh, LayersBase);
end;


function NewLayerInfo(): PLayer_Info;
type
  TLocalCall = function(LibBase: Pointer): PLayer_Info; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 24));
  NewLayerInfo := Call(LayersBase);
end;


procedure ScrollLayer(dummy: LongInt; Layer: PLayer; dx: LongInt; dy: LongInt);
type
  TLocalCall = procedure(dummy: LongInt;  Layer: PLayer;  dx: LongInt; dy: LongInt; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 12));
  Call(dummy, Layer, dx, dy, LayersBase);
end;


function SizeLayer(dummy: LongInt; Layer: PLayer; dx: LongInt; dy: LongInt): LongInt;
type
  TLocalCall = function(dummy: LongInt; Layer: PLayer; dx: LongInt; dy: LongInt; LibBase: Pointer): LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 11));
  SizeLayer := Call(dummy, Layer, dx, dy, LayersBase);
end;


procedure SortLayerCR(Layer: PLayer; dx: LongInt; dy: LongInt);
type
  TLocalCall = procedure(Layer: PLayer; dx: LongInt; dy: LongInt; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 35));
  Call(Layer, dx, dy, LayersBase);
end;


procedure SwapBitsRastPortClipRect(rp: pRastPort; cr: PClipRect);
type
  TLocalCall = procedure(rp: pRastPort; cr: PClipRect; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 21));
  Call(rp, cr, LayersBase);
end;


procedure ThinLayerInfo(LayerInfo: PLayer_Info);
type
  TLocalCall = procedure(LayerInfo: PLayer_Info; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 27));
  Call(LayerInfo, LayersBase);
end;


procedure UnlockLayer(Layer: PLayer);
type
  TLocalCall = procedure(Layer: PLayer; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 17));
  Call(Layer, LayersBase);
end;


procedure UnlockLayerInfo(LayerInfo: PLayer_Info);
type
  TLocalCall = procedure(LayerInfo: PLayer_Info; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call:=TLocalCall(GetLibAdress(LayersBase, 23));
  Call(LayerInfo, LayersBase);
end;


procedure UnlockLayers(LayerInfo: PLayer_Info);
type
  TLocalCall = procedure(LayerInfo: PLayer_Info; LibBase: Pointer); cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 19));
  Call(LayerInfo, LayersBase);
end;


function UpfrontLayer(dummy: LongInt;  Layer: PLayer):LongInt;
type
  TLocalCall = function(dummy: LongInt; Layer: PLayer; LibBase: Pointer):LongInt; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 8));
  UpfrontLayer := Call(dummy, Layer, LayersBase);
end;


function WhichLayer(LayerInfo: PLayer_Info; x: LongInt; y: LongInt):PLayer;
type
  TLocalCall = function(LayerInfo: PLayer_Info; x: LongInt; y: LongInt; LibBase: Pointer):PLayer; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(LayersBase, 22));
  WhichLayer := Call(LayerInfo, x, y, LayersBase);
end;

initialization
  LayersBase := OpenLibrary(LAYERSNAME, 36);

finalization
  CloseLibrary(LayersBase);

eND. (* UNIT LAYERS *)



