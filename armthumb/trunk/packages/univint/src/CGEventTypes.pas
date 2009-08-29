{
*  CGEventTypes.h
*  CoreGraphics
*
*  Copyright (c) 2004 Apple Computer, Inc. All rights reserved.
*
}
{       Pascal Translation:  Peter N Lewis, <peter@stairways.com.au>, August 2005 }
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

unit CGEventTypes;
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
uses MacTypes,MacOSXPosix,CGRemoteOperation,CGBase;
{$ALIGN POWER}


{
 * The CGEventRef object may be created or copied, retained, released, and
 * modified.  The object provides an opaque representation of one low level
 * hardware event.
 }
type
	CGEventRef = ^SInt32; { an opaque 32-bit type }

{
 * Types common to both CGEvent.h and CGEventSource.h
 }
type
	_CGMouseButton = SInt32;
const
	kCGMouseButtonLeft = 0;
	kCGMouseButtonRight = 1;
	kCGMouseButtonCenter = 2;
type
	CGMouseButton = UInt32;

{
 * The flags field includes both modifier key state at the time the event was created,
 * as well as other event related state.
 *
 * Note that any bits not specified are reserved.
 }
type
	_CGEventFlags = SInt32;
(*
Uncomment when IOKit is translated

const { Masks for the bits in event flags }
{ device-independent modifier key bits }
	kCGEventFlagMaskAlphaShift = NX_ALPHASHIFTMASK;
	kCGEventFlagMaskShift = NX_SHIFTMASK;
	kCGEventFlagMaskControl = NX_CONTROLMASK;
	kCGEventFlagMaskAlternate = NX_ALTERNATEMASK;
	kCGEventFlagMaskCommand = NX_COMMANDMASK;

    { Special key identifiers }
	kCGEventFlagMaskHelp = NX_HELPMASK;
	kCGEventFlagMaskSecondaryFn = NX_SECONDARYFNMASK;

    { Identifies key events from numeric keypad area on extended keyboards }
	kCGEventFlagMaskNumericPad = NX_NUMERICPADMASK;

    { Indicates if mouse/pen movement events are not being coalesced }
	kCGEventFlagMaskNonCoalesced = NX_NONCOALSESCEDMASK;
*)
type
	CGEventFlags = UInt64;	    { Flags for events }


{
 *
 * The following enumeration describes all event types currently presented
 * in this API.  Apple reserves the right to extend or create new event
 * types at any time.
 *
 * Notes:
 *	Tablet devices may generate mice events with embedded tablet
 *	data, or tablet pointer and proximity events.  The tablet
 *	events as mouse events allow tablets to be used with programs
 *	which are not tablet-aware.
 }

{ Event types }
type
	_CGEventType = SInt32;
(*
Uncomment when IOKit is translated

const
	kCGEventNull = NX_NULLEVENT;			{ Placeholder; the Null Event }
    { mouse events }
	kCGEventLeftMouseDown = NX_LMOUSEDOWN;		{ left mouse-down event }
	kCGEventLeftMouseUp = NX_LMOUSEUP;			{ left mouse-up event }
	kCGEventRightMouseDown = NX_RMOUSEDOWN;		{ right mouse-down event }
	kCGEventRightMouseUp = NX_RMOUSEUP;			{ right mouse-up event }
	kCGEventMouseMoved = NX_MOUSEMOVED;			{ mouse-moved event }
	kCGEventLeftMouseDragged = NX_LMOUSEDRAGGED;	{ left mouse-dragged event }
	kCGEventRightMouseDragged = NX_RMOUSEDRAGGED;	{ right mouse-dragged event }

    { keyboard events }
	kCGEventKeyDown = NX_KEYDOWN;			{ key-down event }
	kCGEventKeyUp = NX_KEYUP;				{ key-up event }
	kCGEventFlagsChanged = NX_FLAGSCHANGED;		{ flags-changed (modifier keys and status) event }

    { Specialized control devices }
	kCGEventScrollWheel = NX_SCROLLWHEELMOVED;		{ Scroll wheel input device }
	kCGEventTabletPointer = NX_TABLETPOINTER;		{ specialized tablet pointer event, in addition to tablet mouse event }
	kCGEventTabletProximity = NX_TABLETPROXIMITY;	{ specialized tablet proximity event, in addition to tablet mouse event }
	kCGEventOtherMouseDown = NX_OMOUSEDOWN;		{ Mouse button 2-31 down }
	kCGEventOtherMouseUp = NX_OMOUSEUP;			{ Mouse button 2-31 up }
	kCGEventOtherMouseDragged = NX_OMOUSEDRAGGED;	{ Drag with mouse button 2-31 down }
*)

    {
     * Out of band types, delivered for unusual conditions
     * These are delivered to the event tap callback to notify of unusual
     * conditions that disable the event tap.
     }
const
	kCGEventTapDisabledByTimeout = $FFFFFFFE;
	kCGEventTapDisabledByUserInput = $FFFFFFFF;
type
	CGEventType = UInt32;


type
	CGEventTimestamp = UInt64;  { Event timestamp, roughly, nanoseconds since startup }

{
 * Low level functions provide access to specialized fields of the events
 * The fields are identified by tokens defined in this enumeration.
 }
type
	_CGEventField = SInt32;
const
{ Additional keys and values found in mouse events, including the OtherMouse events: }

	kCGMouseEventNumber = 0;
    { Key associated with an integer encoding the mouse button event number as an integer.  Matching mouse-down and mouse-up events will have the same event number. }

	kCGMouseEventClickState = 1;
    { Key associated with an integer encoding the mouse button clickState as an integer.  A clickState of 1 represents a single click.  A clickState of 2 represents a double-click.  A clickState of 3 represents a triple-click. }

	kCGMouseEventPressure = 2;
    { Key associated with a double encoding the mouse button pressurr.  The pressure value may range from 0 to 1.0, with 0 representing the mouse being up.  This value is commonly set by tablet pens mimicing a mouse. }

	kCGMouseEventButtonNumber = 3;
    { Key associated with an integer representing the mouse button number.  The left mouse button reports as button 0.  A right mouse button reports as button 1.  A middle button reports as button 2, and additional buttons report as the appropriate USB button. }

	kCGMouseEventDeltaX = 4;
	kCGMouseEventDeltaY = 5;
    { Key associated with an integer encoding the mouse delta since the last mouse movement event. }

	kCGMouseEventInstantMouser = 6;
    { Key associated with an integer value, non-zero if the event should be ignored by the Inkwell subsystem. }

	kCGMouseEventSubtype = 7;
    {
     * Key associated with an integer encoding the mouse event subtype as a kCFNumberIntType.
     *
     * Tablets may generate specially annotated mouse events,
     * which will contain additional keys and values.
     *
     * Mouse events of subtype kCGEventMouseSubtypeTabletPoint may also use the tablet  accessor keys.
     * Mouse events of subtype kCGEventMouseSubtypeTabletProximity may also use the tablet  proximity accessor keys.
     }

    { Additional keys and values found in keyboard events:	}

	kCGKeyboardEventAutorepeat = 8;
    { Key associated with an integer, non-zero when when this is an autorepeat of a key-down, and zero otherwise. }

	kCGKeyboardEventKeycode = 9;
    { Key associated with the integer virtual keycode of the key-down or key-up event. }

	kCGKeyboardEventKeyboardType = 10;
    { Key associated with the integer representing the keyboard type identifier. }


    { Additional keys and values found in scroll wheel events:	}

	kCGScrollWheelEventDeltaAxis1 = 11;
	kCGScrollWheelEventDeltaAxis2 = 12;
	kCGScrollWheelEventDeltaAxis3 = 13;
    { Key associated with an integer value representing a change in scrollwheel position. }

	kCGScrollWheelEventInstantMouser = 14;
    { Key associated with an integer value, non-zero if the event should be ignored by the Inkwell subsystem. }


    {
     * Additional keys and values found in tablet pointer events,
     * and in mouse events containing embedded tablet event data:
     }

	kCGTabletEventPointX = 15;
	kCGTabletEventPointY = 16;
	kCGTabletEventPointZ = 17;
    { Key associated with an integer encoding the absolute X, Y, or Z tablet coordinate in tablet space at full tablet resolution. }

	kCGTabletEventPointButtons = 18;
    { Key associated with an integer encoding the tablet button state. Bit 0 is the first button, and a set bit represents a closed or pressed button. Up to 16 buttons are supported. }

	kCGTabletEventPointPressure = 19;
    { Key associated with a double encoding the tablet pen pressure.  0 represents no pressure, and 1.0 represents maximum pressure. }

	kCGTabletEventTiltX = 20;
	kCGTabletEventTiltY = 21;
    { Key associated with a double encoding the tablet pen tilt.  0 represents no tilt, and 1.0 represents maximum tilt. } 

	kCGTabletEventRotation = 22;
    { Key associated with a double encoding the tablet pen rotation. }

	kCGTabletEventTangentialPressure = 23;
    { Key associated with a double encoding the tangential pressure on the device. 0 represents no pressure, and 1.0 represents maximum pressure.  }

	kCGTabletEventDeviceID = 24;
    { Key associated with an integer encoding the system-assigned unique device ID. }

	kCGTabletEventVendor1 = 25;
	kCGTabletEventVendor2 = 26;
	kCGTabletEventVendor3 = 27;
    { Key associated with an integer containing vendor-specified values.}


    {
     * Additional keys and values found in tablet proximity events,
     * and in mouse events containing embedded tablet proximity data:
     }

	kCGTabletProximityEventVendorID = 28;
    { Key associated with an integer encoding the vendor-defined ID, typically the USB vendor ID. }

	kCGTabletProximityEventTabletID = 29;
    { Key associated with an integer encoding the vendor-defined tablet ID, typically the USB product ID. }

	kCGTabletProximityEventPointerID = 30;
    { Key associated with an integer encoding the vendor-defined ID of the pointing device. }

	kCGTabletProximityEventDeviceID = 31;
    { Key associated with an integer encoding the system-assigned device ID. }

	kCGTabletProximityEventSystemTabletID = 32;
    { Key associated with an integer encoding the system-assigned unique tablet ID. }

	kCGTabletProximityEventVendorPointerType = 33;
    { Key associated with an integer encoding the vendor-assigned pointer type. }

	kCGTabletProximityEventVendorPointerSerialNumber = 34;
    { Key associated with an integer encoding the vendor-defined pointer serial number. }

	kCGTabletProximityEventVendorUniqueID = 35;
    { Key associated with an integer encoding the vendor-defined unique ID. }

	kCGTabletProximityEventCapabilityMask = 36;
    { Key associated with an integer encoding the device capabilities mask. }

	kCGTabletProximityEventPointerType = 37;
    { Key associated with an integer encoding the pointer type. }

	kCGTabletProximityEventEnterProximity = 38;
    { Key associated with an integer, non-zero when pen is in proximity to the tablet, and zero when leaving the tablet. }

	kCGEventTargetProcessSerialNumber = 39;
    { Key for the event target process serial number as a 64 bit longword. }

	kCGEventTargetUnixProcessID = 40;
    { Key for the event target Unix process ID }

	kCGEventSourceUnixProcessID = 41;
    { Key for the event source, or poster's Unix process ID }

	kCGEventSourceUserData = 42;
    { Key for the event source user-supplied data, up to 64 bits }

	kCGEventSourceUserID = 43;
    { Key for the event source Unix effective UID }

	kCGEventSourceGroupID = 44;
    { Key for the event source Unix effective GID }
    
	kCGEventSourceStateID = 45;
    { Key for the event source state ID used to create this event }
type
	CGEventField = UInt32;

{ Values used with the kCGMouseEventSubtype }
type
	_CGEventMouseSubtype = SInt32;
const
	kCGEventMouseSubtypeDefault = 0;
	kCGEventMouseSubtypeTabletPoint = 1;
	kCGEventMouseSubtypeTabletProximity = 2;
type
	CGEventMouseSubtype = UInt32;

{
 * Event Taps
 *
 * Taps may be placed at the point where HIDSystem events enter
 * the server, at the point where HIDSystem and remote control
 * events enter a session, at the point where events have been
 * annotated to flow to a specific application, or at the point
 * where events are delivered to the application.  Taps may be
 * inserted at a specified point at the head of pre-existing filters,
 * or appended after any pre-existing filters.
 *
 * Taps may be passive event listeners, or active filters.
 * An active filter may pass an event through unmodified, modify
 * an event, or discard an event.  When a tap is registered, it
 * identifies the set of events to be observed with a mask, and
 * indicates if it is a passive or active event filter.  Multiple
 * event type bitmasks may be ORed together.
 *
 * Taps may only be placed at kCGHIDEventTap by a process running
 * as the root user.  NULL is returned for other users.
 *
 * Taps placed at kCGHIDEventTap, kCGSessionEventTap,
 * kCGAnnotatedSessionEventTap, or on a specific process may
 * only receive key up and down events if access for assistive
 * devices is enabled (Preferences Universal Access panel,
 * Keyboard view). If the tap is not permitted to monitor these
 * when the tap is being created, then the appropriate bits
 * in the mask are cleared.  If that results in an empty mask,
 * then NULL is returned.
 *
 * The CGEventTapProxy is an opaque reference to state within
 * the client application associated with the tap.  The tap
 * function may pass this reference to other functions, such as
 * the event-posting routines.
 *
 }
{ Possible tapping points for events }
type
	_CGEventTapLocation = SInt32;
const
	kCGHIDEventTap = 0;
	kCGSessionEventTap = 1;
	kCGAnnotatedSessionEventTap = 2;
type
	CGEventTapLocation = UInt32;

type
	_CGEventTapPlacement = SInt32;
const
	kCGHeadInsertEventTap = 0;
	kCGTailAppendEventTap = 1;
type
	CGEventTapPlacement = UInt32;

type
	_CGEventTapOptions = SInt32;
const
	kCGEventTapOptionListenOnly = $00000001;
type
	CGEventTapOptions = UInt32;


type
	CGEventMask = UInt64;
{
#define CGEventMaskBit(eventType)	((CGEventMask)1 << (eventType))
}

type
	CGEventTapProxy = ^SInt32; { an opaque 32-bit type }

{
 * The callback is passed a proxy for the tap, the event type, the incoming event,
 * and the refcon the callback was registered with.
 * The function should return the (possibly modified) passed in event,
 * a newly constructed event, or NULL if the event is to be deleted.
 *
 * The CGEventRef passed into the callback is retained by the calling code, and is
 * released after the callback returns and the data is passed back to the event
 * system.  If a different event is returned by the callback function, then that
 * event will be released by the calling code along with the original event, after
 * the event data has been passed back to the event system.
 }
type
	CGEventTapCallBack = function( proxy: CGEventTapProxy; typ: CGEventType; event: CGEventRef; refcon: UnivPtr ): CGEventRef;


{
 * When an event tap is installed or released, a notification
 * is posted via the notify_post() API.  See notify (3) and
 * notify.h for details.
 }
const
	kCGNotifyEventTapAdded = 'com.apple.coregraphics.eventTapAdded';
const
	kCGNotifyEventTapRemoved = 'com.apple.coregraphics.eventTapRemoved';

{
 * Structure used to report information on event taps
 }
type
	CGEventTapInformationPtr = ^CGEventTapInformation;
	CGEventTapInformation = record
		eventTapID: UInt32;
		tapPoint: CGEventTapLocation;		{ HID, session, annotated session }
		options: CGEventTapOptions;		{ Listener, Filter }
		eventsOfInterest: CGEventMask;	{ Mask of events being tapped }
		tappingProcess: pid_t;		{ Process that is tapping events }
		processBeingTapped: pid_t;	{ Zero if not a per-process tap }
		enabled: CBool;		{ True if tap is enabled }
		minUsecLatency: Float32;		{ Minimum latency in microseconds }
		avgUsecLatency: Float32;		{ Average latency in microseconds }
		maxUsecLatency: Float32;		{ Maximum latency in microseconds }
	end;


{
 * The CGEventSourceRef is an opaque representation of the source of an event.
 *
 * API is provided to obtain the CGEventSource from an event, and to create
 * a new event with a CGEventSourceRef.
 }
type
	CGEventSourceRef = ^SInt32; { an opaque 32-bit type }

type
	CGEventSourceStateID = UInt32;
const
	kCGEventSourceStatePrivate = -1;
	kCGEventSourceStateCombinedSessionState = 0;
	kCGEventSourceStateHIDSystemState = 1;

type
	CGEventSourceKeyboardType = UInt32;

const
	kCGAnyInputEventType = $FFFFFFFF;


end.
