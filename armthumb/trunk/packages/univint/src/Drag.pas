{
     File:       HIToolbox/Drag.h
 
     Contains:   Drag and Drop Interfaces.
 
     Version:    HIToolbox-219.4.81~2
 
     Copyright:  © 1992-2005 by Apple Computer, Inc., all rights reserved.
 
     Bugs?:      For bug reports, consult the following page on
                 the World Wide Web:
 
                     http://www.freepascal.org/bugs.html
 
}
{       Pascal Translation Updated:  Peter N Lewis, <peter@stairways.com.au>, August 2005 }
{
    Modified for use with Free Pascal
    Version 210
    Please report any bugs to <gpc@microbizz.nl>
}

{$mode macpas}
{$packenum 1}
{$macro on}
{$inline on}
{$calling mwpascal}

unit Drag;
interface
{$setc UNIVERSAL_INTERFACES_VERSION := $0342}
{$setc GAP_INTERFACES_VERSION := $0210}

{$ifc not defined USE_CFSTR_CONSTANT_MACROS}
    {$setc USE_CFSTR_CONSTANT_MACROS := TRUE}
{$endc}

{$ifc defined CPUPOWERPC and defined CPUI386}
	{$error Conflicting initial definitions for CPUPOWERPC and CPUI386}
{$endc}
{$ifc defined FPC_BIG_ENDIAN and defined FPC_LITTLE_ENDIAN}
	{$error Conflicting initial definitions for FPC_BIG_ENDIAN and FPC_LITTLE_ENDIAN}
{$endc}

{$ifc not defined __ppc__ and defined CPUPOWERPC}
	{$setc __ppc__ := 1}
{$elsec}
	{$setc __ppc__ := 0}
{$endc}
{$ifc not defined __i386__ and defined CPUI386}
	{$setc __i386__ := 1}
{$elsec}
	{$setc __i386__ := 0}
{$endc}

{$ifc defined __ppc__ and __ppc__ and defined __i386__ and __i386__}
	{$error Conflicting definitions for __ppc__ and __i386__}
{$endc}

{$ifc defined __ppc__ and __ppc__}
	{$setc TARGET_CPU_PPC := TRUE}
	{$setc TARGET_CPU_X86 := FALSE}
{$elifc defined __i386__ and __i386__}
	{$setc TARGET_CPU_PPC := FALSE}
	{$setc TARGET_CPU_X86 := TRUE}
{$elsec}
	{$error Neither __ppc__ nor __i386__ is defined.}
{$endc}
{$setc TARGET_CPU_PPC_64 := FALSE}

{$ifc defined FPC_BIG_ENDIAN}
	{$setc TARGET_RT_BIG_ENDIAN := TRUE}
	{$setc TARGET_RT_LITTLE_ENDIAN := FALSE}
{$elifc defined FPC_LITTLE_ENDIAN}
	{$setc TARGET_RT_BIG_ENDIAN := FALSE}
	{$setc TARGET_RT_LITTLE_ENDIAN := TRUE}
{$elsec}
	{$error Neither FPC_BIG_ENDIAN nor FPC_LITTLE_ENDIAN are defined.}
{$endc}
{$setc ACCESSOR_CALLS_ARE_FUNCTIONS := TRUE}
{$setc CALL_NOT_IN_CARBON := FALSE}
{$setc OLDROUTINENAMES := FALSE}
{$setc OPAQUE_TOOLBOX_STRUCTS := TRUE}
{$setc OPAQUE_UPP_TYPES := TRUE}
{$setc OTCARBONAPPLICATION := TRUE}
{$setc OTKERNEL := FALSE}
{$setc PM_USE_SESSION_APIS := TRUE}
{$setc TARGET_API_MAC_CARBON := TRUE}
{$setc TARGET_API_MAC_OS8 := FALSE}
{$setc TARGET_API_MAC_OSX := TRUE}
{$setc TARGET_CARBON := TRUE}
{$setc TARGET_CPU_68K := FALSE}
{$setc TARGET_CPU_MIPS := FALSE}
{$setc TARGET_CPU_SPARC := FALSE}
{$setc TARGET_OS_MAC := TRUE}
{$setc TARGET_OS_UNIX := FALSE}
{$setc TARGET_OS_WIN32 := FALSE}
{$setc TARGET_RT_MAC_68881 := FALSE}
{$setc TARGET_RT_MAC_CFM := FALSE}
{$setc TARGET_RT_MAC_MACHO := TRUE}
{$setc TYPED_FUNCTION_POINTERS := TRUE}
{$setc TYPE_BOOL := FALSE}
{$setc TYPE_EXTENDED := FALSE}
{$setc TYPE_LONGLONG := TRUE}
uses MacTypes,AEDataModel,CGImage,CGGeometry,Events,Files,AppleEvents,Quickdraw,Pasteboard,HIGeometry;


{$ALIGN MAC68K}

{
  _________________________________________________________________________________________________________
      
   ₯ DRAG MANAGER DATA TYPES
  _________________________________________________________________________________________________________
}
type
	DragRef = ^SInt32; { an opaque 32-bit type }
	DragRefPtr = ^DragRef;  { when a var xx:DragRef parameter can be nil, it is changed to xx: DragRefPtr }
type
	DragItemRef = UInt32;
type
	FlavorType = OSType;
{
  _________________________________________________________________________________________________________
      
   ₯ DRAG ATTRIBUTES
  _________________________________________________________________________________________________________
}
type
	DragAttributes = UInt32;
const
	kDragHasLeftSenderWindow = 1 shl 0; { drag has left the source window since TrackDrag}
	kDragInsideSenderApplication = 1 shl 1; { drag is occurring within the sender application}
	kDragInsideSenderWindow = 1 shl 2; { drag is occurring within the sender window}

{
  _________________________________________________________________________________________________________
      
   ₯ DRAG BEHAVIORS
  _________________________________________________________________________________________________________
}
type
	DragBehaviors = UInt32;
const
	kDragBehaviorNone = 0;
	kDragBehaviorZoomBackAnimation = 1 shl 0; { do zoomback animation for failed drags (normally enabled).}

{
  _________________________________________________________________________________________________________
      
   ₯ DRAG IMAGE FLAGS
  _________________________________________________________________________________________________________
}

{
 *  DragImageFlags
 *  
 *  Summary:
 *    Parameters to SetDragImage and SetDragImageWithCGImage.
 }
type
	DragImageFlags = UInt32;
const
{
   * Indicates that the outline region passed to TrackDrag should be
   * drawn onscreen, in addition to the translucent drag image.
   }
	kDragRegionAndImage = 1 shl 4;

  {
   * Indicates that the image and offset being passed in are already at
   * device resolution, and the image should be drawn as-is. If this
   * option is not specified, the image will be scaled according to the
   * user's current scaling factor. Available in Mac OS X 10.4 and
   * later.
   }
	kDragDoNotScaleImage = 1 shl 5;

{
  _________________________________________________________________________________________________________
      
   ₯ DRAG IMAGE TRANSLUCENCY LEVELS
  _________________________________________________________________________________________________________
}

const
	kDragStandardTranslucency = 0;   { 65% image translucency (standard)}
	kDragDarkTranslucency = 1;   { 50% image translucency}
	kDragDarkerTranslucency = 2;   { 25% image translucency}
	kDragOpaqueTranslucency = 3;    { 0% image translucency (opaque)}

{
  _________________________________________________________________________________________________________
      
   ₯ DRAG DRAWING PROCEDURE MESSAGES
  _________________________________________________________________________________________________________
}

type
	DragRegionMessage = SInt16;
const
	kDragRegionBegin = 1;    { initialize drawing}
	kDragRegionDraw = 2;    { draw drag feedback}
	kDragRegionHide = 3;    { hide drag feedback}
	kDragRegionIdle = 4;    { drag feedback idle time}
	kDragRegionEnd = 5;     { end of drawing}

{
  _________________________________________________________________________________________________________
      
   ₯ ZOOM ACCELERATION
  _________________________________________________________________________________________________________
}

type
	ZoomAcceleration = SInt16;
const
	kZoomNoAcceleration = 0;    { use linear interpolation}
	kZoomAccelerate = 1;    { ramp up step size}
	kZoomDecelerate = 2;     { ramp down step size}

{
  _________________________________________________________________________________________________________
      
   ₯ FLAVOR FLAGS
  _________________________________________________________________________________________________________
}

type
	FlavorFlags = UInt32;
const
	flavorSenderOnly = 1 shl 0; { flavor is available to sender only}
	flavorSenderTranslated = 1 shl 1; { flavor is translated by sender}
	flavorNotSaved = 1 shl 2; { flavor should not be saved}
	flavorSystemTranslated = 1 shl 8; { flavor is translated by system}
	flavorDataPromised = 1 shl 9; { flavor data is promised by sender}

{
  _________________________________________________________________________________________________________
      
   ₯ FILE SYSTEM CONSTANTS
  _________________________________________________________________________________________________________
}

const
	kDragFlavorTypeHFS = FourCharCode('hfs '); { flavor type for HFS data}
	kDragFlavorTypePromiseHFS = FourCharCode('phfs'); { flavor type for promised HFS data}
	flavorTypeHFS = kDragFlavorTypeHFS; { old name}
	flavorTypePromiseHFS = kDragFlavorTypePromiseHFS; { old name}

const
	kDragPromisedFlavorFindFile = FourCharCode('rWm1'); { promisedFlavor value for Find File}
	kDragPromisedFlavor = FourCharCode('fssP'); { promisedFlavor value for everything else}

const
	kDragPseudoCreatorVolumeOrDirectory = FourCharCode('MACS'); { "creator code" for volume or directory}
	kDragPseudoFileTypeVolume = FourCharCode('disk'); { "file type" for volume}
	kDragPseudoFileTypeDirectory = FourCharCode('fold'); { "file type" for directory}

{
  _________________________________________________________________________________________________________
      
   ₯ SPECIAL FLAVORS
  _________________________________________________________________________________________________________
}

const
	flavorTypeDirectory = FourCharCode('diry'); { flavor type for AOCE directories}

{
  _________________________________________________________________________________________________________
      
   ₯ FLAVORS FOR FINDER 8.0 AND LATER
  _________________________________________________________________________________________________________
}

const
	kFlavorTypeClippingName = FourCharCode('clnm'); { name hint for clipping file (preferred over 'clfn')}
	kFlavorTypeClippingFilename = FourCharCode('clfn'); { name for clipping file}
	kFlavorTypeUnicodeClippingName = FourCharCode('ucln'); { unicode name hint for clipping file (preferred over 'uclf')}
	kFlavorTypeUnicodeClippingFilename = FourCharCode('uclf'); { unicode name for clipping file}
	kFlavorTypeDragToTrashOnly = FourCharCode('fdtt'); { for apps that want to allow dragging private data to the trash}
	kFlavorTypeFinderNoTrackingBehavior = FourCharCode('fntb'); { Finder completely ignores any drag containing this flavor}

{
  _________________________________________________________________________________________________________
      
   ₯ DRAG TRACKING HANDLER MESSAGES
  _________________________________________________________________________________________________________
}

type
	DragTrackingMessage = SInt16;
const
	kDragTrackingEnterHandler = 1;    { drag has entered handler}
	kDragTrackingEnterWindow = 2;    { drag has entered window}
	kDragTrackingInWindow = 3;    { drag is moving within window}
	kDragTrackingLeaveWindow = 4;    { drag has exited window}
	kDragTrackingLeaveHandler = 5;     { drag has exited handler}

{
  ΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡ
   ₯ STANDARD DROP LOCATIONS
  ΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡΡ
}


{
 *  Summary:
 *    Standard Drop Location constants
 *  
 *  Discussion:
 *    The following constants define common "meta" drop locations.
 }
const
{
   * The drop location was in the trash.  This is set when a drag is
   * dropped on the trash icon.  Setting this standard drop location
   * sets the traditional drop location to an alias to the trash folder
   * automatically.
   }
	kDragStandardDropLocationTrash = FourCharCode('trsh');

  {
   * The receiver did not specify a drop lcoation. This is the default.
   }
	kDragStandardDropLocationUnknown = FourCharCode('unkn');

type
	StandardDropLocation = OSType;
{
  _________________________________________________________________________________________________________
      
   ₯ DRAG ACTIONS
  _________________________________________________________________________________________________________
}

{
 *  Summary:
 *    Drag Action constants
 *  
 *  Discussion:
 *    The following constants define, in a general way, what actions a
 *    drag should or has performed.  Some drag actions enforce a mode
 *    of operation while others are flexible suggestions.  These
 *    constants are used in conjunction with the
 *    Get/SetDragAllowableActions() and Get/SetDragDropAction() APIs. 
 *    Adopting the Drag Action APIs increases compatability with the
 *    Cocoa drag operation model.
 }
const
{
   * Suggests nothing should be/was done with the data in a drag.  When
   * set as an allowable action for remote drags, the drag will not be
   * sent to apps other than the sender.
   }
	kDragActionNothing = 0;

  {
   * Suggests the data contained within the drag can be/was copied.
   }
	kDragActionCopy = 1;

  {
   * Suggests the data contained within the drag can be/is shared.
   }
	kDragActionAlias = 1 shl 1;

  {
   * Suggests the drag action is can be defined by the drag destination
   * or was not defined by the drag destination.
   }
	kDragActionGeneric = 1 shl 2;

  {
   * Suggests the drag action should be negotiated privately between
   * the drag source and destination.
   }
	kDragActionPrivate = 1 shl 3;

  {
   * Description forthcoming.
   }
	kDragActionMove = 1 shl 4;

  {
   * Description forthcoming.
   }
	kDragActionDelete = 1 shl 5;

  {
   * All of the above drag actions are allowed.
   }
	kDragActionAll = $FFFFFFFF;

type
	DragActions = UInt32;
{
  _________________________________________________________________________________________________________
      
   ₯ HFS FLAVORS
  _________________________________________________________________________________________________________
}
type
	HFSFlavorPtr = ^HFSFlavor;
	HFSFlavor = record
		fileType: OSType;               { file type }
		fileCreator: OSType;            { file creator }
		fdFlags: UInt16;                { Finder flags }
		fileSpec: FSSpec;               { file system specification }
	end;
type
	PromiseHFSFlavorPtr = ^PromiseHFSFlavor;
	PromiseHFSFlavor = record
		fileType: OSType;               { file type }
		fileCreator: OSType;            { file creator }
		fdFlags: UInt16;                { Finder flags }
		promisedFlavor: FlavorType;         { promised flavor containing an FSSpec }
	end;
{
  _________________________________________________________________________________________________________
      
   ₯ APPLICATION-DEFINED DRAG HANDLER ROUTINES
  _________________________________________________________________________________________________________
}
type
	DragTrackingHandlerProcPtr = function( message: DragTrackingMessage; theWindow: WindowRef; handlerRefCon: UnivPtr; theDrag: DragRef ): OSErr;
type
	DragReceiveHandlerProcPtr = function( theWindow: WindowRef; handlerRefCon: UnivPtr; theDrag: DragRef ): OSErr;
type
	DragTrackingHandlerUPP = DragTrackingHandlerProcPtr;
type
	DragReceiveHandlerUPP = DragReceiveHandlerProcPtr;
{
 *  NewDragTrackingHandlerUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
function NewDragTrackingHandlerUPP( userRoutine: DragTrackingHandlerProcPtr ): DragTrackingHandlerUPP; external name '_NewDragTrackingHandlerUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  NewDragReceiveHandlerUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
function NewDragReceiveHandlerUPP( userRoutine: DragReceiveHandlerProcPtr ): DragReceiveHandlerUPP; external name '_NewDragReceiveHandlerUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  DisposeDragTrackingHandlerUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
procedure DisposeDragTrackingHandlerUPP( userUPP: DragTrackingHandlerUPP ); external name '_DisposeDragTrackingHandlerUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  DisposeDragReceiveHandlerUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
procedure DisposeDragReceiveHandlerUPP( userUPP: DragReceiveHandlerUPP ); external name '_DisposeDragReceiveHandlerUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  InvokeDragTrackingHandlerUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
function InvokeDragTrackingHandlerUPP( message: DragTrackingMessage; theWindow: WindowRef; handlerRefCon: UnivPtr; theDrag: DragRef; userUPP: DragTrackingHandlerUPP ): OSErr; external name '_InvokeDragTrackingHandlerUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  InvokeDragReceiveHandlerUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
function InvokeDragReceiveHandlerUPP( theWindow: WindowRef; handlerRefCon: UnivPtr; theDrag: DragRef; userUPP: DragReceiveHandlerUPP ): OSErr; external name '_InvokeDragReceiveHandlerUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
  _________________________________________________________________________________________________________
      
   ₯ APPLICATION-DEFINED ROUTINES
  _________________________________________________________________________________________________________
}
type
	DragSendDataProcPtr = function( theType: FlavorType; dragSendRefCon: UnivPtr; theItemRef: DragItemRef; theDrag: DragRef ): OSErr;
type
	DragInputProcPtr = function( var mouse: Point; var modifiers: SInt16; dragInputRefCon: UnivPtr; theDrag: DragRef ): OSErr;
type
	DragDrawingProcPtr = function( message: DragRegionMessage; showRegion: RgnHandle; showOrigin: Point; hideRegion: RgnHandle; hideOrigin: Point; dragDrawingRefCon: UnivPtr; theDrag: DragRef ): OSErr;
type
	DragSendDataUPP = DragSendDataProcPtr;
type
	DragInputUPP = DragInputProcPtr;
type
	DragDrawingUPP = DragDrawingProcPtr;
{
 *  NewDragSendDataUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
function NewDragSendDataUPP( userRoutine: DragSendDataProcPtr ): DragSendDataUPP; external name '_NewDragSendDataUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  NewDragInputUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
function NewDragInputUPP( userRoutine: DragInputProcPtr ): DragInputUPP; external name '_NewDragInputUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  NewDragDrawingUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
function NewDragDrawingUPP( userRoutine: DragDrawingProcPtr ): DragDrawingUPP; external name '_NewDragDrawingUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  DisposeDragSendDataUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
procedure DisposeDragSendDataUPP( userUPP: DragSendDataUPP ); external name '_DisposeDragSendDataUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  DisposeDragInputUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
procedure DisposeDragInputUPP( userUPP: DragInputUPP ); external name '_DisposeDragInputUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  DisposeDragDrawingUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
procedure DisposeDragDrawingUPP( userUPP: DragDrawingUPP ); external name '_DisposeDragDrawingUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  InvokeDragSendDataUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
function InvokeDragSendDataUPP( theType: FlavorType; dragSendRefCon: UnivPtr; theItemRef: DragItemRef; theDrag: DragRef; userUPP: DragSendDataUPP ): OSErr; external name '_InvokeDragSendDataUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  InvokeDragInputUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
function InvokeDragInputUPP( var mouse: Point; var modifiers: SInt16; dragInputRefCon: UnivPtr; theDrag: DragRef; userUPP: DragInputUPP ): OSErr; external name '_InvokeDragInputUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  InvokeDragDrawingUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
function InvokeDragDrawingUPP( message: DragRegionMessage; showRegion: RgnHandle; showOrigin: Point; hideRegion: RgnHandle; hideOrigin: Point; dragDrawingRefCon: UnivPtr; theDrag: DragRef; userUPP: DragDrawingUPP ): OSErr; external name '_InvokeDragDrawingUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
  _________________________________________________________________________________________________________
      
   ₯ INSTALLING AND REMOVING HANDLERS API'S
  _________________________________________________________________________________________________________
}

{
 *  InstallTrackingHandler()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function InstallTrackingHandler( trackingHandler: DragTrackingHandlerUPP; theWindow: WindowRef; handlerRefCon: UnivPtr ): OSErr; external name '_InstallTrackingHandler';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  InstallReceiveHandler()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function InstallReceiveHandler( receiveHandler: DragReceiveHandlerUPP; theWindow: WindowRef; handlerRefCon: UnivPtr ): OSErr; external name '_InstallReceiveHandler';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  RemoveTrackingHandler()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function RemoveTrackingHandler( trackingHandler: DragTrackingHandlerUPP; theWindow: WindowRef ): OSErr; external name '_RemoveTrackingHandler';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  RemoveReceiveHandler()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function RemoveReceiveHandler( receiveHandler: DragReceiveHandlerUPP; theWindow: WindowRef ): OSErr; external name '_RemoveReceiveHandler';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
  _________________________________________________________________________________________________________
      
   ₯ CREATING & DISPOSING
  _________________________________________________________________________________________________________
}

{
 *  NewDrag()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function NewDrag( var theDrag: DragRef ): OSErr; external name '_NewDrag';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  DisposeDrag()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function DisposeDrag( theDrag: DragRef ): OSErr; external name '_DisposeDrag';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
  _________________________________________________________________________________________________________
      
   ₯ DRAG PASTEBOARD
  _________________________________________________________________________________________________________
}

{
 *  NewDragWithPasteboard()
 *  
 *  Discussion:
 *    Creates a new Drag reference containing the pasteboard reference
 *    provided.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inPasteboard:
 *      A pasteboard created by the drag sender for use with the drag.
 *      Items may be added to the pasteboard via the Pasteboard Manager
 *      API either before or after this routine is called. It is still
 *      possible to add data via the Drag Manager API, but only after
 *      this routine is called. It is the drag sender's responsibility
 *      to clear the pasteboard before adding items. It is also the
 *      drag sender's responsibility to release the pasteboard.  This
 *      may be done at any time after this routine is called. The
 *      pasteboard is retained by the Drag Manager for the duration of
 *      the drag.
 *    
 *    outDrag:
 *      A drag reference which receives the newly created drag.
 *  
 *  Result:
 *    An operating system result code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function NewDragWithPasteboard( inPasteboard: PasteboardRef; var outDrag: DragRef ): OSStatus; external name '_NewDragWithPasteboard';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  GetDragPasteboard()
 *  
 *  Discussion:
 *    Returns the pasteboard reference contained within the provided
 *    drag reference. This routine may be called by a drag sender or
 *    receiver at any point after a valid drag reference has been
 *    created/received.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inDrag:
 *      The drag reference containing the requested pasteboard.
 *    
 *    outPasteboard:
 *      A pasteboard reference which receives the pasteboard contained
 *      by the drag.
 *  
 *  Result:
 *    An operating system result code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function GetDragPasteboard( inDrag: DragRef; var outPasteboard: PasteboardRef ): OSStatus; external name '_GetDragPasteboard';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
  _________________________________________________________________________________________________________
      
   ₯ ADDING DRAG ITEM FLAVORS
  _________________________________________________________________________________________________________
}

{
    The method for setting Drag Manager promises differs from that for Scrap Manger promises.  This chart
    describes the method for setting drag promises via AddDragItemFlavor().
    
        dataPtr         dataSize                                result
     pointer value  actual data size    The data of size dataSize pointed to by dataPtr is added to the drag.
        NULL             ignored        A promise is placed on the drag.
}
{
 *  AddDragItemFlavor()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function AddDragItemFlavor( theDrag: DragRef; theItemRef: DragItemRef; theType: FlavorType; dataPtr: {const} UnivPtr; dataSize: Size; theFlags: FlavorFlags ): OSErr; external name '_AddDragItemFlavor';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  SetDragItemFlavorData()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function SetDragItemFlavorData( theDrag: DragRef; theItemRef: DragItemRef; theType: FlavorType; dataPtr: {const} UnivPtr; dataSize: Size; dataOffset: UInt32 ): OSErr; external name '_SetDragItemFlavorData';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
  _________________________________________________________________________________________________________
      
   ₯ PROVIDING CALLBACK PROCEDURES
  _________________________________________________________________________________________________________
}

{
 *  SetDragSendProc()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function SetDragSendProc( theDrag: DragRef; sendProc: DragSendDataUPP; dragSendRefCon: UnivPtr ): OSErr; external name '_SetDragSendProc';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  SetDragInputProc()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function SetDragInputProc( theDrag: DragRef; inputProc: DragInputUPP; dragInputRefCon: UnivPtr ): OSErr; external name '_SetDragInputProc';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  SetDragDrawingProc()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function SetDragDrawingProc( theDrag: DragRef; drawingProc: DragDrawingUPP; dragDrawingRefCon: UnivPtr ): OSErr; external name '_SetDragDrawingProc';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
  _________________________________________________________________________________________________________
      
   ₯ SETTING THE DRAG IMAGE
  _________________________________________________________________________________________________________
}

{
 *  SetDragImageWithCGImage()
 *  
 *  Discussion:
 *    Used by the sender of the drag to set the image, in CGImage
 *    format, to be displayed as user feedback during the drag.  This
 *    API may be called  at any point during the drag to update the
 *    image.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inDrag:
 *      The drag reference for which the image will be displayed.
 *    
 *    inCGImage:
 *      The CGImageRef for the image to be displayed during the drag. 
 *      The image is retained internally by the Drag Manager for the
 *      duration of the drag so it may be released by the client
 *      immediately after setting.
 *    
 *    inImageOffsetPt:
 *      A pointer to the offset from the mouse to the upper left of the
 *      image (normally expressed in negative values).  This differs
 *      from the usage of the offset passed to SetDragImage().  Here,
 *      an offset of ( -30, -30 ) will center a 60x60 pixel image on
 *      the drag mouse.
 *    
 *    inImageFlags:
 *      The flags determining image drawing during the drag.
 *  
 *  Result:
 *    An operating system result code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.2 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x
 *    Non-Carbon CFM:   not available
 }
function SetDragImageWithCGImage( inDrag: DragRef; inCGImage: CGImageRef; const (*var*) inImageOffsetPt: HIPoint; inImageFlags: DragImageFlags ): OSStatus; external name '_SetDragImageWithCGImage';
(* AVAILABLE_MAC_OS_X_VERSION_10_2_AND_LATER *)


{
  _________________________________________________________________________________________________________
      
   ₯ ALTERING THE BEHAVIOR OF A DRAG
  _________________________________________________________________________________________________________
}
{
 *  ChangeDragBehaviors()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 9.0 and later
 }
function ChangeDragBehaviors( theDrag: DragRef; inBehaviorsToSet: DragBehaviors; inBehaviorsToClear: DragBehaviors ): OSErr; external name '_ChangeDragBehaviors';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
  _________________________________________________________________________________________________________
      
   ₯ PERFORMING A DRAG
  _________________________________________________________________________________________________________
}
{
 *  TrackDrag()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function TrackDrag( theDrag: DragRef; const (*var*) theEvent: EventRecord; theRegion: RgnHandle ): OSErr; external name '_TrackDrag';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
  _________________________________________________________________________________________________________
      
   ₯ GETTING DRAG ITEM INFORMATION
  _________________________________________________________________________________________________________
}

{
 *  CountDragItems()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function CountDragItems( theDrag: DragRef; var numItems: UInt16 ): OSErr; external name '_CountDragItems';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetDragItemReferenceNumber()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function GetDragItemReferenceNumber( theDrag: DragRef; index: UInt16; var theItemRef: DragItemRef ): OSErr; external name '_GetDragItemReferenceNumber';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  CountDragItemFlavors()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function CountDragItemFlavors( theDrag: DragRef; theItemRef: DragItemRef; var numFlavors: UInt16 ): OSErr; external name '_CountDragItemFlavors';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetFlavorType()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function GetFlavorType( theDrag: DragRef; theItemRef: DragItemRef; index: UInt16; var theType: FlavorType ): OSErr; external name '_GetFlavorType';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetFlavorFlags()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function GetFlavorFlags( theDrag: DragRef; theItemRef: DragItemRef; theType: FlavorType; var theFlags: FlavorFlags ): OSErr; external name '_GetFlavorFlags';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetFlavorDataSize()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function GetFlavorDataSize( theDrag: DragRef; theItemRef: DragItemRef; theType: FlavorType; var dataSize: Size ): OSErr; external name '_GetFlavorDataSize';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetFlavorData()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function GetFlavorData( theDrag: DragRef; theItemRef: DragItemRef; theType: FlavorType; dataPtr: UnivPtr; var dataSize: Size; dataOffset: UInt32 ): OSErr; external name '_GetFlavorData';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
  _________________________________________________________________________________________________________
      
   ₯ DRAG ITEM BOUNDS
  _________________________________________________________________________________________________________
}

{
 *  GetDragItemBounds()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function GetDragItemBounds( theDrag: DragRef; theItemRef: DragItemRef; var itemBounds: Rect ): OSErr; external name '_GetDragItemBounds';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  SetDragItemBounds()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function SetDragItemBounds( theDrag: DragRef; theItemRef: DragItemRef; const (*var*) itemBounds: Rect ): OSErr; external name '_SetDragItemBounds';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
  _________________________________________________________________________________________________________
      
   ₯ DROP LOCATIONS
  _________________________________________________________________________________________________________
}

{
 *  GetDropLocation()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function GetDropLocation( theDrag: DragRef; var dropLocation: AEDesc ): OSErr; external name '_GetDropLocation';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  SetDropLocation()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function SetDropLocation( theDrag: DragRef; const (*var*) dropLocation: AEDesc ): OSErr; external name '_SetDropLocation';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
  _________________________________________________________________________________________________________
      
   ₯ STANDARD DROP LOCATIONS
  _________________________________________________________________________________________________________
}
{
 *  GetStandardDropLocation()
 *  
 *  Discussion:
 *    Gets the standard drop location that was set by the receiver of
 *    the drag.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    theDrag:
 *      The drag reference from which to retrieve the allowable drag
 *      actions.
 *    
 *    outDropLocation:
 *      A pointer to the standard drop location, set by the receiver,
 *      representing the location where the drag was dropped.
 *  
 *  Result:
 *    An operating system result code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.2 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.2 and later
 *    Non-Carbon CFM:   not available
 }
function GetStandardDropLocation( theDrag: DragRef; var outDropLocation: StandardDropLocation ): OSStatus; external name '_GetStandardDropLocation';
(* AVAILABLE_MAC_OS_X_VERSION_10_2_AND_LATER *)


{
 *  SetStandardDropLocation()
 *  
 *  Discussion:
 *    Used by the receiver of the drag to set the standard drop
 *    location.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    theDrag:
 *      The drag reference from which to retrieve the allowable drag
 *      actions.
 *    
 *    dropLocation:
 *      The standard drop location representing the location where the
 *      drag was dropped.
 *  
 *  Result:
 *    An operating system result code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.2 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.2 and later
 *    Non-Carbon CFM:   not available
 }
function SetStandardDropLocation( theDrag: DragRef; dropLocation: StandardDropLocation ): OSStatus; external name '_SetStandardDropLocation';
(* AVAILABLE_MAC_OS_X_VERSION_10_2_AND_LATER *)


{
  _________________________________________________________________________________________________________
      
   ₯ GETTING INFORMATION ABOUT A DRAG
  _________________________________________________________________________________________________________
}

{
 *  GetDragAttributes()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function GetDragAttributes( theDrag: DragRef; var flags: DragAttributes ): OSErr; external name '_GetDragAttributes';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetDragMouse()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function GetDragMouse( theDrag: DragRef; var mouse: Point; var globalPinnedMouse: Point ): OSErr; external name '_GetDragMouse';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  SetDragMouse()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function SetDragMouse( theDrag: DragRef; globalPinnedMouse: Point ): OSErr; external name '_SetDragMouse';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetDragOrigin()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function GetDragOrigin( theDrag: DragRef; var globalInitialMouse: Point ): OSErr; external name '_GetDragOrigin';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetDragModifiers()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function GetDragModifiers( theDrag: DragRef; var modifiers: SInt16; var mouseDownModifiers: SInt16; var mouseUpModifiers: SInt16 ): OSErr; external name '_GetDragModifiers';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
  _________________________________________________________________________________________________________
      
   ₯ ACCESSING DRAG ACTIONS
  _________________________________________________________________________________________________________
}

{
 *  GetDragAllowableActions()
 *  
 *  Discussion:
 *    Gets the actions the drag sender has allowed the receiver to
 *    perform. These are not requirements, but they highly suggested
 *    actions which allows the drag receiver to improve harmony across
 *    the system.  The allowable actions received are always those
 *    local to the caller's process.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    theDrag:
 *      The drag reference from which to retreive the allowable drag
 *      actions.
 *    
 *    outActions:
 *      A pointer to receive the field of allowable drag actions.
 *  
 *  Result:
 *    An operating system result code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.1 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.1 and later
 *    Non-Carbon CFM:   not available
 }
function GetDragAllowableActions( theDrag: DragRef; var outActions: DragActions ): OSStatus; external name '_GetDragAllowableActions';
(* AVAILABLE_MAC_OS_X_VERSION_10_1_AND_LATER *)


{
 *  SetDragAllowableActions()
 *  
 *  Discussion:
 *    Sets the actions the receiver of the drag is allowed to perform. 
 *    These are not requirements, but they highly suggested actions
 *    which allows the drag receiver to improve harmony across the
 *    system.  The caller may select wether these drag actions apply to
 *    a local or remote process.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    theDrag:
 *      The drag reference in which to set the allowable drag actions.
 *    
 *    inActions:
 *      A field of allowable drag actions to be set.
 *    
 *    isLocal:
 *      A boolean value allowing the drag sender to distinguish between
 *      those drag actions allowable by the local receiver versus a
 *      remote one.
 *  
 *  Result:
 *    An operating system result code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.1 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.1 and later
 *    Non-Carbon CFM:   not available
 }
function SetDragAllowableActions( theDrag: DragRef; inActions: DragActions; isLocal: Boolean ): OSStatus; external name '_SetDragAllowableActions';
(* AVAILABLE_MAC_OS_X_VERSION_10_1_AND_LATER *)


{
 *  GetDragDropAction()
 *  
 *  Discussion:
 *    Gets the action performed by the receiver of the drag.  More than
 *    one action may have been performed.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    theDrag:
 *      The drag reference from which to retreive the performed drop
 *      action.
 *    
 *    outAction:
 *      A pointer to receive the drag action performed.
 *  
 *  Result:
 *    An operating system result code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.1 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.1 and later
 *    Non-Carbon CFM:   not available
 }
function GetDragDropAction( theDrag: DragRef; var outAction: DragActions ): OSStatus; external name '_GetDragDropAction';
(* AVAILABLE_MAC_OS_X_VERSION_10_1_AND_LATER *)


{
 *  SetDragDropAction()
 *  
 *  Discussion:
 *    Sets the action performed by the receiver of the drag.  More than
 *    one action may be performed.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    theDrag:
 *      The drag reference in which to set the performed drop action.
 *    
 *    inAction:
 *      The drop action performed.
 *  
 *  Result:
 *    An operating system result code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.1 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.1 and later
 *    Non-Carbon CFM:   not available
 }
function SetDragDropAction( theDrag: DragRef; inAction: DragActions ): OSStatus; external name '_SetDragDropAction';
(* AVAILABLE_MAC_OS_X_VERSION_10_1_AND_LATER *)


{
  _________________________________________________________________________________________________________
      
   ₯ DRAG HIGHLIGHTING
  _________________________________________________________________________________________________________
}

{
 *  ShowDragHilite()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function ShowDragHilite( theDrag: DragRef; hiliteFrame: RgnHandle; inside: Boolean ): OSErr; external name '_ShowDragHilite';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  HideDragHilite()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function HideDragHilite( theDrag: DragRef ): OSErr; external name '_HideDragHilite';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  DragPreScroll()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function DragPreScroll( theDrag: DragRef; dH: SInt16; dV: SInt16 ): OSErr; external name '_DragPreScroll';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  DragPostScroll()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function DragPostScroll( theDrag: DragRef ): OSErr; external name '_DragPostScroll';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  UpdateDragHilite()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function UpdateDragHilite( theDrag: DragRef; updateRgn: RgnHandle ): OSErr; external name '_UpdateDragHilite';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  GetDragHiliteColor()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 7.5 and later
 }
function GetDragHiliteColor( window: WindowRef; var color: RGBColor ): OSErr; external name '_GetDragHiliteColor';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
  _________________________________________________________________________________________________________
      
   ₯ UTILITIES
  _________________________________________________________________________________________________________
}


{
 *  WaitMouseMoved()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function WaitMouseMoved( initialGlobalMouse: Point ): Boolean; external name '_WaitMouseMoved';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  ZoomRects()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function ZoomRects( const (*var*) fromRect: Rect; const (*var*) toRect: Rect; zoomSteps: SInt16; acceleration: ZoomAcceleration ): OSErr; external name '_ZoomRects';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{
 *  ZoomRegion()
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 1.1 and later
 }
function ZoomRegion( region: RgnHandle; zoomDistance: Point; zoomSteps: SInt16; acceleration: ZoomAcceleration ): OSErr; external name '_ZoomRegion';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)


{--------------------------------------------------------------------------------------}
{  ₯ DEPRECATED                                                                        }
{  All functions below this point are either deprecated (they continue to function     }
{  but are not the most modern nor most efficient solution to a problem), or they are  }
{  completely unavailable on Mac OS X.                                                 }
{--------------------------------------------------------------------------------------}


{
 *  SetDragImage()   *** DEPRECATED ***
 *  
 *  Deprecated:
 *    Applications should use SetDragImageWithCGImage instead.
 *  
 *  Summary:
 *    Associates an image with a drag reference.
 *  
 *  Discussion:
 *    Used by the sender of the drag to set the image, in PixMapHandle
 *    format, to be displayed as user feedback during the drag.  This
 *    API may be called  at any point during the drag to update the
 *    image.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inDrag:
 *      The drag reference for which the image will be displayed.
 *    
 *    inImagePixMap:
 *      The PixMapHandle for the image to be displayed during the drag.
 *    
 *    inImageRgn:
 *      A mask describing the portion of the PixMap contained in the
 *      imagePixMap parameter which contains the drag image. Pass NULL
 *      for inImageRgn if the entire PixMap, including white space,
 *      should be dragged.
 *    
 *    inImageOffsetPt:
 *      The offset required to move the PixMap specified in the
 *      imagePixMap parameter to the global coordinates where the image
 *      initially appears. If this parameter is (0,0), the PixMap
 *      should already be in global coordinates.
 *    
 *    inImageFlags:
 *      Flags controlling the appearance of the drag image.
 *  
 *  Result:
 *    An operating system result code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework but deprecated in 10.4
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in DragLib 7.5 and later
 }
function SetDragImage( inDrag: DragRef; inImagePixMap: PixMapHandle; inImageRgn: RgnHandle; inImageOffsetPt: Point; inImageFlags: DragImageFlags ): OSErr; external name '_SetDragImage';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4 *)


{
  _________________________________________________________________________________________________________
   ₯ OLD NAMES
     These are provided for compatiblity with older source bases.  It is recommended to not use them since
     they may removed from this interface file at any time.
  _________________________________________________________________________________________________________
}


type
	DragReference = DragRef;
type
	ItemReference = DragItemRef;
(*
#if OLDROUTINENAMES
const
	dragHasLeftSenderWindow = kDragHasLeftSenderWindow; { drag has left the source window since TrackDrag }
	dragInsideSenderApplication = kDragInsideSenderApplication; { drag is occurring within the sender application }
	dragInsideSenderWindow = kDragInsideSenderWindow; { drag is occurring within the sender window }

const
	dragTrackingEnterHandler = kDragTrackingEnterHandler; { drag has entered handler }
	dragTrackingEnterWindow = kDragTrackingEnterWindow; { drag has entered window }
	dragTrackingInWindow = kDragTrackingInWindow; { drag is moving within window }
	dragTrackingLeaveWindow = kDragTrackingLeaveWindow; { drag has exited window }
	dragTrackingLeaveHandler = kDragTrackingLeaveHandler; { drag has exited handler }

const
	dragRegionBegin = kDragRegionBegin; { initialize drawing }
	dragRegionDraw = kDragRegionDraw; { draw drag feedback }
	dragRegionHide = kDragRegionHide; { hide drag feedback }
	dragRegionIdle = kDragRegionIdle; { drag feedback idle time }
	dragRegionEnd = kDragRegionEnd; { end of drawing }

const
	zoomNoAcceleration = kZoomNoAcceleration; { use linear interpolation }
	zoomAccelerate = kZoomAccelerate; { ramp up step size }
	zoomDecelerate = kZoomDecelerate; { ramp down step size }

const
	kDragStandardImage = kDragStandardTranslucency; { 65% image translucency (standard)}
	kDragDarkImage = kDragDarkTranslucency; { 50% image translucency}
	kDragDarkerImage = kDragDarkerTranslucency; { 25% image translucency}
	kDragOpaqueImage = kDragOpaqueTranslucency; { 0% image translucency (opaque)}

#endif  { OLDROUTINENAMES }
*)



end.
