{
     File:       HIToolbox/HITheme.h
 
     Contains:   HIToolbox HITheme interfaces.
 
     Version:    HIToolbox-219.4.81~2
 
     Copyright:  � 1994-2005 by Apple Computer, Inc., all rights reserved.
 
     Bugs?:      For bug reports, consult the following page on
                 the World Wide Web:
 
                     http://www.freepascal.org/bugs.html
 
}
{       Pascal Translation:  Peter N Lewis, <peter@stairways.com.au>, 2004 }
{       Pascal Translation Updated:  Peter N Lewis, <peter@stairways.com.au>, August 2005 }
{
    Modified for use with Free Pascal
    Version 200
    Please report any bugs to <gpc@microbizz.nl>
}

{$mode macpas}
{$packenum 1}
{$macro on}
{$inline on}
{$CALLING MWPASCAL}

unit HITheme;
interface
{$setc UNIVERSAL_INTERFACES_VERSION := $0342}
{$setc GAP_INTERFACES_VERSION := $0200}

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
uses MacTypes,CFBase,CGBase,Appearance,HIShape,HIGeometry,Drag,CFDate,CGContext,MacWindows,Controls;


{$ALIGN MAC68K}

{ -------------------------------------------------------------------------- }
{  HIThemeOrientation information                                            }
{ -------------------------------------------------------------------------- }

const
{
   * The passed context has an origin at the top left. This is the
   * default of a context passed to you by HIToolbox.
   }
	kHIThemeOrientationNormal = 0;

  {
   * The passed context has an origin at the bottom left. This is the
   * default for a context you create.
   }
	kHIThemeOrientationInverted = 1;

type
	HIThemeOrientation = UInt32;
{ -------------------------------------------------------------------------- }
{  Splitter types                                                            }
{ -------------------------------------------------------------------------- }

const
{
   * Draw the splitter with its normal appearance.
   }
	kHIThemeSplitterAdornmentNone = 0;

  {
   * Draw the splitter with its metal appearance.
   }
	kHIThemeSplitterAdornmentMetal = 1;

type
	HIThemeSplitterAdornment = UInt32;
{ -------------------------------------------------------------------------- }
{  Window Grow Box                                                           }
{ -------------------------------------------------------------------------- }

const
{
   * The grow box corner for a window that has no scroll bars.
   }
	kHIThemeGrowBoxKindNormal = 0;

  {
   * The grow box corner for a window that has no grow box. This sounds
   * paradoxical, but this type of grow box, formerly known as the
   * "NoGrowBox" is used to fill in the corner left blank by the
   * intersection of a horizontal and a vertical scroll bar.
   }
	kHIThemeGrowBoxKindNone = 1;

type
	HIThemeGrowBoxKind = UInt32;

const
{
   * Draw the grow box for normal windows.
   }
	kHIThemeGrowBoxSizeNormal = 0;

  {
   * Draw the smaller grow box for utility or floating windows.
   }
	kHIThemeGrowBoxSizeSmall = 1;

type
	HIThemeGrowBoxSize = UInt32;

const
{
   * The group box is drawn with the primary variant.
   }
	kHIThemeGroupBoxKindPrimary = 0;

  {
   * The group box is drawn with the secondary variant.
   }
	kHIThemeGroupBoxKindSecondary = 1;

  {
   * The group box is drawn with the primary variant. This group box
   * draws opaque. This does not match the Mac OS X 10.3 appearance
   * 100%, as the boxes should be transparent, but draws this way for
   * the sake of compatibility. Please update to use the newer
   * transparent variant.
   }
	kHIThemeGroupBoxKindPrimaryOpaque = 3;

  {
   * The group box is drawn with the secondary variant. This group box
   * draws opaque. This does not match the Mac OS X 10.3 appearance
   * 100%, as the boxes should be transparent, but draws this way for
   * the sake of compatibility. Please update to use the newer
   * transparent variant.
   }
	kHIThemeGroupBoxKindSecondaryOpaque = 4;

type
	HIThemeGroupBoxKind = UInt32;

const
{
   * A header drawn above window content that has no top border of its
   * own. (i.e. the same as the status bar in an icon view Finder
   * window).
   }
	kHIThemeHeaderKindWindow = 0;

  {
   * A header drawn above window content that has a top border of its
   * own. (i.e. the same as the status bar in an list view Finder
   * window).
   }
	kHIThemeHeaderKindList = 1;

type
	HIThemeHeaderKind = UInt32;

const
{
   * The default sized square text field (like Edit Text).
   }
	kHIThemeFrameTextFieldSquare = 0;
	kHIThemeFrameListBox = 1;

type
	HIThemeFrameKind = UInt32;

const
{
   * Indicates that a menu title should be drawn in a condensed
   * appearance. This constant is used in the
   * HIThemeMenuTitleDrawInfo.attributes field.
   }
	kHIThemeMenuTitleDrawCondensed = 1 shl 0;

{ -------------------------------------------------------------------------- }
{  DrawInfo                                                                  }
{ -------------------------------------------------------------------------- }

{
 *  HIScrollBarTrackInfo
 *  
 *  Summary:
 *    Drawing parameters passed to scroll bar drawing and measuring
 *    theme APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIScrollBarTrackInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeTrackEnableState for the scroll bar to be drawn.
   }
		enableState: SInt8 {ThemeTrackEnableState};

  {
   * The ThemeTrackPressState for the scroll bar to be drawn.
   }
		pressState: SInt8 {ThemeTrackPressState};

  {
   * The view range size.
   }
		viewsize: Float32;
	end;
	HIScrollBarTrackInfoPtr = ^HIScrollBarTrackInfo;

{
 *  HIThemeTrackDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to track drawing and measuring theme
 *    APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3, but based on legacy TrackDrawInfo.
 }
type
	HIThemeTrackDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;                { current version is 0 }

  {
   * The ThemeTrackKind of the track being drawn or measured.
   }
		kind: ThemeTrackKind;                   { what kind of track this info is for }

  {
   * An HIRect describing the bounds of the track being drawn or
   * measured.
   }
		bounds: HIRect;                 { track basis rectangle }

  {
   * The minimum allowable value for the track being drawn or measured.
   }
		min: SInt32;                    { min track value }

  {
   * The maximum allowable value for the track being drawn or measured.
   }
		max: SInt32;                    { max track value }

  {
   * The value for the track being drawn or measured.
   }
		value: SInt32;                  { current thumb value }

  {
   * Leave this reserved field set to 0.
   }
		reserved: UInt32;


  {
   * A set of ThemeTrackAttributes for the track to be drawn or
   * measured.
   }
		attributes: ThemeTrackAttributes;           { various track attributes }

  {
   * A ThemeTrackEnableState describing the state of the track to be
   * drawn or measured.
   }
		enableState: SInt8 {ThemeTrackEnableState};         { enable state }

  {
   * Leave this reserved field set to 0.
   }
		filler1: SInt8;

	case SInt16 of
		0: (
			scrollbar: ScrollBarTrackInfo;
		   );
		1: (
			slider: SliderTrackInfo;
			);
		2: (
			progress: ProgressTrackInfo;
			);
	end;
	HIThemeTrackDrawInfoPtr = ^HIThemeTrackDrawInfo;

{
 *  HIThemeAnimationTimeInfo
 *  
 *  Summary:
 *    Time parameters passed to button drawing and measuring theme APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeAnimationTimeInfo = record
{
   * The CFAbsoluteTime of the beginning of the animation of the
   * button.  This only applies to buttons that animate -- currently
   * only kThemePushButton.  All other buttons will ignore this field. 
   * If there is to be no animation, set this field to 0.
   }
		start: CFAbsoluteTime;

  {
   * The CFAbsoluteTime of the current animation frame of the button. 
   * This only applies to buttons that animate -- currently only
   * kThemePushButton.  All other buttons will ignore this field.  If
   * there is to be no animation, set this field to 0.
   }
		current: CFAbsoluteTime;
	end;
	HIThemeAnimationTimeInfoPtr = ^HIThemeAnimationTimeInfo;

{
 *  HIThemeAnimationFrameInfo
 *  
 *  Summary:
 *    Frame parameters passed to button drawing and measuring theme
 *    APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeAnimationFrameInfo = record
{
   * The index of the frame of the animation to draw. If the index is
   * greater that the maximum number of animation frames, it will be
   * modded to calculate which frame to draw.
   }
		index: UInt32;
	end;
	HIThemeAnimationFrameInfoPtr = ^HIThemeAnimationFrameInfo;

{
 *  HIThemeButtonDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to button drawing and measuring theme
 *    APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeButtonDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeDrawState of the button being drawn or measured.
   }
		state: ThemeDrawState;

  {
   * A ThemeButtonKind indicating the type of button to be drawn.
   }
		kind: ThemeButtonKind;

  {
   * The ThemeButtonValue of the button being drawn or measured.
   }
		value: ThemeButtonValue;

  {
   * The ThemeButtonAdornment(s) with which the button is being drawn
   * or measured.
   }
		adornment: ThemeButtonAdornment;
	case SInt16 of
		0: (
				time: HIThemeAnimationTimeInfo;
		   );
		1: (
				frame: HIThemeAnimationFrameInfo;
			);
	end;
	HIThemeButtonDrawInfoPtr = ^HIThemeButtonDrawInfo;

{
 *  HIThemeSplitterDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to splitter drawing and measuring theme
 *    APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeSplitterDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeDrawState of the splitter being drawn or measured.
   }
		state: ThemeDrawState;

  {
   * The HIThemeSplitterAdornments of the splitter being drawn or
   * measured.
   }
		adornment: HIThemeSplitterAdornment;
	end;
	HIThemeSplitterDrawInfoPtr = ^HIThemeSplitterDrawInfo;

const
{
   * No tab adornments are to be drawn.
   }
	kHIThemeTabAdornmentNone = 0;

  {
   * A focus ring is to be drawn around the tab.
   }
	kHIThemeTabAdornmentFocus = 1 shl 2; { to match button focus adornment }

  {
   * If available, a leading separator is to be drawn on the tab,
   * either to the left or above, depending on orientation. Note that
   * tabs overlap and if the separators are drawn over top each other,
   * the shadows multiply undesirably. New in Mac OS X 10.4.
   }
	kHIThemeTabAdornmentLeadingSeparator = 1 shl 3;

  {
   * If available, a right separator is to be drawn on the tab, either
   * to the right or below, depending on the orientation. Note that
   * tabs overlap and if the separators are drawn over top each other,
   * the shadows multiply undesirably. New in Mac OS X 10.4.
   }
	kHIThemeTabAdornmentTrailingSeparator = 1 shl 4;

type
	HIThemeTabAdornment = UInt32;

{
 *  Summary:
 *    These values are similar to kControlSize constants for
 *    convenience.
 }
const
{
   * The tabs are normal (large) sized.
   }
	kHIThemeTabSizeNormal = 0;

  {
   * The tabs are drawn as the small variant.
   }
	kHIThemeTabSizeSmall = 1;

  {
   * The tabs are drawn as the mini variant.
   }
	kHIThemeTabSizeMini = 3;

type
	HIThemeTabSize = UInt32;

{
 *  Summary:
 *    Available values for HIThemeTabPosition. These are positions of
 *    the tabs within the tab control. New in Mac OS X 10.4.
 }
const
{
   * The first position of a tab control. Left or top tab.
   }
	kHIThemeTabPositionFirst = 0;

  {
   * A middle tab.
   }
	kHIThemeTabPositionMiddle = 1;

  {
   * The last position of a tab control. Right or bottom tab.
   }
	kHIThemeTabPositionLast = 2;

  {
   * The only position of a tab control. It is simultaneously first and
   * last. You know, only. There is only one tab. It looks pretty much
   * like a button. Please don't use this if you can avoid it. It's
   * ugly.
   }
	kHIThemeTabPositionOnly = 3;

type
	HIThemeTabPosition = UInt32;

{
 *  Summary:
 *    Available values for HIThemeTabKind.
 }
const
	kHIThemeTabKindNormal = 0;

type
	HIThemeTabKind = UInt32;

{
 *  HIThemeTabDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to tab drawing and measuring theme APIs.
 *  
 *  Discussion:
 *    In Mac OS X 10.4, added kind and position fields.
 }
type
	HIThemeTabDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 1.
   }
		version: UInt32;

  {
   * A ThemeTabStyle describing the style of the tab to be drawn.
   }
		style: ThemeTabStyle;

  {
   * A ThemeTabDirection describing the side on which the tab is being
   * drawn.
   }
		direction: ThemeTabDirection;

  {
   * An HIThemeTabSize indicating what size of tab to draw.
   }
		size: HIThemeTabSize;

  {
   * An HIThemeTabAdornment describing any additional adornments that
   * are to be drawn on the tab.
   }
		adornment: HIThemeTabAdornment;             { various tab attributes }

  {
   * An HIThemeTabKind indicating what kind of tab to draw.
   }
		kind: HIThemeTabKind;

  {
   * The HIThemeTabPositions of the tab to be drawn or measured.
   }
		position: HIThemeTabPosition;
	end;
	HIThemeTabDrawInfoPtr = ^HIThemeTabDrawInfo;

{
 *  HIThemeTabDrawInfoVersionZero
 *  
 *  Summary:
 *    This structure is left here as a reference to the previous
 *    version of the tab drawing parameters. Please use the current
 *    version.
 *  
 *  Discussion:
 *    Shipped with Mac OS X 10.3.
 }
type
	HIThemeTabDrawInfoVersionZero = record
		version: UInt32;
		style: ThemeTabStyle;
		direction: ThemeTabDirection;
		size: HIThemeTabSize;
		adornment: HIThemeTabAdornment;             { various tab attributes }
	end;

{
 *  Summary:
 *    Values for HIThemeTabPaneAdornment.
 }
const
	kHIThemeTabPaneAdornmentNormal = 0;


type
	HIThemeTabPaneAdornment = UInt32;

{
 *  HIThemeTabPaneDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to tab pane drawing and measuring theme
 *    APIs.
 *  
 *  Discussion:
 *    In Mac OS X 10.4, added kind and adornment fields.
 }
type
	HIThemeTabPaneDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeDrawState for the tab pane to be drawn.
   }
		state: ThemeDrawState;

  {
   * A ThemeTabDirection describing on which side of the pane the tabs
   * will be drawn.
   }
		direction: ThemeTabDirection;

  {
   * An HIThemeTabSize indicating what size of tab pane to draw.
   }
		size: HIThemeTabSize;

  {
   * An HIThemeTabKind indicating what kind of tab to draw this pane
   * for.
   }
		kind: HIThemeTabKind;

  {
   * An HIThemeTabPaneAdornment describing any additional adornments
   * that are to be drawn on the tab pane.
   }
		adornment: HIThemeTabPaneAdornment;
	end;

{
 *  HIThemeTabPaneDrawInfoVersionZero
 *  
 *  Summary:
 *    This structure is left here as a reference to the previous
 *    version of the tab pane drawing parameters. Please use the
 *    current version.
 *  
 *  Discussion:
 *    Shipped with Mac OS X 10.3.
 }
type
	HIThemeTabPaneDrawInfoVersionZero = record
		version: UInt32;
		state: ThemeDrawState;
		direction: ThemeTabDirection;
		size: HIThemeTabSize;
	end;

{
 *  HIThemeMenuDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to menu drawing and measuring theme
 *    APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeMenuDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * A ThemeMenuType indicating which type of menu is to be drawn.
   }
		menuType: ThemeMenuType;
	end;
	HIThemeMenuDrawInfoPtr = ^HIThemeMenuDrawInfo;

{
 *  HIThemeMenuItemDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to menu item drawing and measuring
 *    theme APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeMenuItemDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * A ThemeMenuItemType indicating what type of menu item is to be
   * drawn.
   }
		itemType: ThemeMenuItemType;

  {
   * The ThemeMenuState of the menu item to be drawn.
   }
		state: ThemeMenuState;
	end;
	HIThemeMenuItemDrawInfoPtr = ^HIThemeMenuItemDrawInfo;

{
 *  HIThemeFrameDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to frame drawing and measuring theme
 *    APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeFrameDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The HIThemeFrameKind of the frame to be drawn.
   }
		kind: HIThemeFrameKind;

  {
   * The ThemeDrawState of the frame to be drawn.
   }
		state: ThemeDrawState;

  {
   * A Boolean indicating whether the frame is to be drawn with focus
   * or without.
   }
		isFocused: Boolean;
	end;
	HIThemeFrameDrawInfoPtr = ^HIThemeFrameDrawInfo;

{
 *  HIThemeGroupBoxDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to group box drawing and measuring
 *    theme APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeGroupBoxDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeDrawState for the group box to be drawn.
   }
		state: ThemeDrawState;

  {
   * An HIThemeGroupBoxKind indicating which type of group box is to be
   * drawn.
   }
		kind: HIThemeGroupBoxKind;
	end;
	HIThemeGroupBoxDrawInfoPtr = ^HIThemeGroupBoxDrawInfo;

{
 *  HIThemeGrabberDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to grabber drawing and measuring theme
 *    APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeGrabberDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeDrawState for the grabber to be drawn.
   }
		state: ThemeDrawState;
	end;
	HIThemeGrabberDrawInfoPtr = ^HIThemeGrabberDrawInfo;

{
 *  HIThemePlacardDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to placard drawing and measuring theme
 *    APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemePlacardDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeDrawState for the placard to be drawn.
   }
		state: ThemeDrawState;
	end;
	HIThemePlacardDrawInfoPtr = ^HIThemePlacardDrawInfo;

{
 *  HIThemeHeaderDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to header drawing and measuring theme
 *    APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeHeaderDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeDrawState for the header to be drawn.
   }
		state: ThemeDrawState;

  {
   * The HIThemeHeaderKind for the header to be drawn.
   }
		kind: HIThemeHeaderKind;
	end;
	HIThemeHeaderDrawInfoPtr = ^HIThemeHeaderDrawInfo;

{
 *  HIThemeMenuBarDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to HIThemeDrawMenuBarBackground.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeMenuBarDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeMenuBarState for the menu bar to be drawn.
   }
		state: ThemeMenuBarState;

  {
   * The attributes of the menu bar to be drawn.
   }
		attributes: UInt32;
	end;
	HIThemeMenuBarDrawInfoPtr = ^HIThemeMenuBarDrawInfo;

{
 *  HIThemeMenuTitleDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to HIThemeDrawMenuTitle.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeMenuTitleDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeMenuState for the menu title to be drawn.
   }
		state: ThemeMenuState;

  {
   * The attributes of the menu title to be drawn. Must be either 0 or
   * kHIThemeMenuTitleDrawCondensed.
   }
		attributes: UInt32;

  {
   * The border space between the menu title rect and the menu title
   * text when the menu title spacing is being condensed. This field is
   * only observed by the Appearance Manager when the attributes field
   * contains kHIThemeMenuTitleDrawCondensed. The valid values for this
   * field range from the value returned by GetThemeMenuTitleExtra(
   * &extra, false ) to the value returned by GetThemeMenuTitleExtra(
   * &extra, true ). You may pass 0 in this field to use the minimum
   * condensed title extra.
   }
		condensedTitleExtra: Float32;
	end;
	HIThemeMenuTitleDrawInfoPtr = ^HIThemeMenuTitleDrawInfo;

{
 *  HIThemeTickMarkDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to tick mark drawing and measuring
 *    theme APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeTickMarkDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeDrawState for the tick mark to be drawn.
   }
		state: ThemeDrawState;
	end;
	HIThemeTickMarkDrawInfoPtr = ^HIThemeTickMarkDrawInfo;

{
 *  HIThemeWindowDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to window drawing and measuring theme
 *    APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3, but based on legacy ThemeWindowMetrics.
 }
type
	HIThemeWindowDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * A ThemeDrawState which describes the state of the window to be
   * drawn.
   }
		state: ThemeDrawState;

  {
   * A ThemeWindowType specifying the type of window to be drawn.
   }
		windowType: ThemeWindowType;

  {
   * The ThemeWindowAttributes describing the window to be drawn.
   }
		attributes: ThemeWindowAttributes;

  {
   * The height of the title of the window.
   }
		titleHeight: Float32;

  {
   * The width of the title of the window.
   }
		titleWidth: Float32;
	end;
	HIThemeWindowDrawInfoPtr = ^HIThemeWindowDrawInfo;

{
 *  HIThemeWindowWidgetDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to window widget drawing and measuring
 *    theme APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3, but based on legacy ThemeWindowMetrics.
 }
type
	HIThemeWindowWidgetDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * A ThemeDrawState which describes the state of the widget to be
   * drawn.
   }
		widgetState: ThemeDrawState;

  {
   * A ThemeTitleBarWidget specifying the type of window widget to be
   * drawn.
   }
		widgetType: ThemeTitleBarWidget;

  {
   * A ThemeDrawState which describes the state of the window for which
   * the widget is to be drawn.
   }
		windowState: ThemeDrawState;

  {
   * A ThemeWindowType specifying the type of window to be drawn.
   }
		windowType: ThemeWindowType;

  {
   * The ThemeWindowAttributes describing the window to be drawn.
   }
		attributes: ThemeWindowAttributes;

  {
   * The height of the title of the window.
   }
		titleHeight: Float32;

  {
   * The width of the title of the window.
   }
		titleWidth: Float32;
	end;
	HIThemeWindowWidgetDrawInfoPtr = ^HIThemeWindowWidgetDrawInfo;

{
 *  HIThemeSeparatorDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to separator drawing and measuring
 *    theme APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeSeparatorDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeDrawState for the separator to be drawn.
   }
		state: ThemeDrawState;
	end;
	HIThemeSeparatorDrawInfoPtr = ^HIThemeSeparatorDrawInfo;

{
 *  HIThemeScrollBarDelimitersDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to separator drawing and measuring
 *    theme APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeScrollBarDelimitersDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeDrawState for the separator to be drawn.
   }
		state: ThemeDrawState;

  {
   * A ThemeWindowType specifying the type of window for which to draw
   * the delimiters.
   }
		windowType: ThemeWindowType;

  {
   * The ThemeWindowAttributes of the window for which the scroll bar
   * delimters are to be drawn.
   }
		attributes: ThemeWindowAttributes;
	end;
	HIThemeScrollBarDelimitersDrawInfoPtr = ^HIThemeScrollBarDelimitersDrawInfo;

{
 *  HIThemeChasingArrowsDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to chasing arrows drawing and measuring
 *    theme APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeChasingArrowsDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeDrawState for the chasing arrows to be drawn.
   }
		state: ThemeDrawState;

  {
   * A UInt32 used to calculate which frame of the chasing arrow
   * animation is to be drawn.
   }
		index: UInt32;
	end;
	HIThemeChasingArrowsDrawInfoPtr = ^HIThemeChasingArrowsDrawInfo;

{
 *  HIThemePopupArrowDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to popup arrow drawing and measuring
 *    theme APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemePopupArrowDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeDrawState for the popup arrow to be drawn.
   }
		state: ThemeDrawState;

  {
   * A ThemeArrowOrientation for the orientation of the popup arrow to
   * be drawn.
   }
		orientation: ThemeArrowOrientation;

  {
   * A ThemePopupArrowSize for the size of the popup arrow to be drawn.
   }
		size: ThemePopupArrowSize;
	end;
	HIThemePopupArrowDrawInfoPtr = ^HIThemePopupArrowDrawInfo;

{
 *  HIThemeGrowBoxDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to grow box drawing and measuring theme
 *    APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3.
 }
type
	HIThemeGrowBoxDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeDrawState for the grow box to be drawn.
   }
		state: ThemeDrawState;

  {
   * A ThemeGrowBoxKind indicating in which kind of grow box to draw.
   }
		kind: HIThemeGrowBoxKind;

  {
   * A ThemeGrowDirection indicating in which direction the window will
   * grow.
   }
		direction: ThemeGrowDirection;

  {
   * An HIThemeGrowBoxSize describing the size of the grow box to draw.
   }
		size: HIThemeGrowBoxSize;
	end;
	HIThemeGrowBoxDrawInfoPtr = ^HIThemeGrowBoxDrawInfo;

{
 *  HIThemeBackgroundDrawInfo
 *  
 *  Discussion:
 *    New in Mac OS X 10.3, but based on legacy TrackDrawInfo.
 }
type
	HIThemeBackgroundDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeDrawState of the background to be drawn. Currently,
   * HIThemeDrawBackground backgrounds do not have state, so this field
   * has no meaning. Set it to kThemeStateActive.
   }
		state: ThemeDrawState;

  {
   * The ThemeBackgroundKind with which to fill the background.
   }
		kind: ThemeBackgroundKind;
	end;
	HIThemeBackgroundDrawInfoPtr = ^HIThemeBackgroundDrawInfo;
{ -------------------------------------------------------------------------- }
{  Buttons                                                                   }
{ -------------------------------------------------------------------------- }
{
 *  HIThemeDrawButton()
 *  
 *  Summary:
 *    Draw a themed button.
 *  
 *  Discussion:
 *    This generic button drawing theme primitive draws not just a push
 *    button, but all of the kinds of buttons described by
 *    ThemeButtonKind.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inBounds:
 *      The HIRect in which to draw.  Note that this API may draw
 *      outside of its bounds.
 *    
 *    inDrawInfo:
 *      An HIThemeButtonDrawInfo describing the button that will be
 *      drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *    
 *    outLabelRect:
 *      A pointer to an HIRect into which to put the bounds of the
 *      label rect.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawButton( const (*var*) inBounds: HIRect; const (*var*) inDrawInfo: HIThemeButtonDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation; outLabelRect: HIRectPtr { can be NULL } ): OSStatus; external name '_HIThemeDrawButton';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetButtonShape()
 *  
 *  Summary:
 *    Get a shape of a themed button.
 *  
 *  Discussion:
 *    This API was mistakenly named as a "Get" API. It behaves as
 *    "Copy" API. THE CALLER IS RESPONSIBLE FOR RELEASING THE RETURNED
 *    SHAPE.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inBounds:
 *      The HIRect in which to draw.
 *    
 *    inDrawInfo:
 *      An HIThemeButtonDrawInfo describing the button that will be
 *      drawn.
 *    
 *    outShape:
 *      A pointer to an HIShapeRef which will be set to the shape of
 *      the button. Needs to be released by caller.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetButtonShape( const (*var*) inBounds: HIRect; const (*var*) inDrawInfo: HIThemeButtonDrawInfo; var outShape: HIShapeRef ): OSStatus; external name '_HIThemeGetButtonShape';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetButtonContentBounds()
 *  
 *  Summary:
 *    Get the bounds of a themed button's content.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inBounds:
 *      An HIRect indicating where the button is to be drawn.
 *    
 *    inDrawInfo:
 *      An HIThemeButtonDrawInfo describing the button that will be
 *      drawn.
 *    
 *    outBounds:
 *      A pointer to an HIRect in which will be returned the rectangle
 *      of the button content bounds.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetButtonContentBounds( const (*var*) inBounds: HIRect; const (*var*) inDrawInfo: HIThemeButtonDrawInfo; var outBounds: HIRect ): OSStatus; external name '_HIThemeGetButtonContentBounds';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetButtonBackgroundBounds()
 *  
 *  Summary:
 *    Get the bounds of the background of a themed button.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inBounds:
 *      An HIRect indicating where the button is to be drawn.
 *    
 *    inDrawInfo:
 *      An HIThemeButtonDrawInfo describing the button that will be
 *      drawn.
 *    
 *    outBounds:
 *      A pointer to an HIRect in which will be returned the rectangle
 *      of the button background bounds.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetButtonBackgroundBounds( const (*var*) inBounds: HIRect; const (*var*) inDrawInfo: HIThemeButtonDrawInfo; var outBounds: HIRect ): OSStatus; external name '_HIThemeGetButtonBackgroundBounds';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawChasingArrows()
 *  
 *  Summary:
 *    Draw themed chasing arrows.
 *  
 *  Discussion:
 *    Draw a frame from the chasing arrows animation.  The animation
 *    frame is based on a modulo value calculated from the index.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inBounds:
 *      An HIRect indicating where the chasing arrows are to be drawn.
 *    
 *    inDrawInfo:
 *      An HIThemeChasingArrowsDrawInfo describing the chasing arrows
 *      to be drawn or measured.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawChasingArrows( const (*var*) inBounds: HIRect; const (*var*) inDrawInfo: HIThemeChasingArrowsDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawChasingArrows';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawPopupArrow()
 *  
 *  Summary:
 *    Draws a themed popup arrow.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inBounds:
 *      The HIRect in which to draw.
 *    
 *    inDrawInfo:
 *      An HIThemePopupArrowDrawInfo describing the popup arrow to be
 *      drawn or measured.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawPopupArrow( const (*var*) inBounds: HIRect; const (*var*) inDrawInfo: HIThemePopupArrowDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawPopupArrow';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{ -------------------------------------------------------------------------- }
{  Menus                                                                     }
{ -------------------------------------------------------------------------- }
{
 *  HIThemeDrawMenuBarBackground()
 *  
 *  Summary:
 *    Draws the menu bar background for a given area.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inBounds:
 *      The HIRect in which to draw.
 *    
 *    inDrawInfo:
 *      The HIThemeMenuBarDrawInfo of the menu bar to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawMenuBarBackground( const (*var*) inBounds: HIRect; const (*var*) inDrawInfo: HIThemeMenuBarDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawMenuBarBackground';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawMenuTitle()
 *  
 *  Summary:
 *    Draws the menu title background for a menu.
 *  
 *  Discussion:
 *    This API draws the background of a menu title. It does not draw
 *    the menu title text; it is the caller's responsibility to draw
 *    the text after this API has returned. The text should be drawn
 *    into the bounds returned in the outLabelRect parameter; the
 *    caller should ensure that the text is not drawn outside of those
 *    bounds, either by truncating or clipping the text.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inMenuBarRect:
 *      An HIRect indicating the bounds of the whole menu bar for which
 *      the menu title is to be drawn.
 *    
 *    inTitleRect:
 *      An HIRect for the bounds of the menu title to be drawn.
 *    
 *    inDrawInfo:
 *      The HIThemeMenuTitleDrawInfo of the menu title to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *    
 *    outLabelRect:
 *      On exit, contains the bounds in which the menu title text
 *      should be drawn. May be NULL if you don't need this information.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawMenuTitle( const (*var*) inMenuBarRect: HIRect; const (*var*) inTitleRect: HIRect; const (*var*) inDrawInfo: HIThemeMenuTitleDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation; outLabelRect: HIRectPtr { can be NULL } ): OSStatus; external name '_HIThemeDrawMenuTitle';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawMenuBackground()
 *  
 *  Summary:
 *    Draws the theme menu background in a rectangle.  This API may
 *    draw outside of the specified rectangle.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inMenuRect:
 *      An HIRect indicating the bounds of the whole menu for which the
 *      background is to be drawn.
 *    
 *    inMenuDrawInfo:
 *      An HIThemeMenuDrawInfo describing the menu to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawMenuBackground( const (*var*) inMenuRect: HIRect; const (*var*) inMenuDrawInfo: HIThemeMenuDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawMenuBackground';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawMenuItem()
 *  
 *  Summary:
 *    Draws a themed menu item.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inMenuRect:
 *      An HIRect indicating the bounds of the whole menu for which the
 *      menu item is to be drawn.
 *    
 *    inItemRect:
 *      An HIRect for the bounds of the menu item to be drawn.
 *    
 *    inItemDrawInfo:
 *      An HIThemeMenuItemDrawInfo describing the drawing
 *      characteristics of the menu item to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *    
 *    outContentRect:
 *      An HIRect that will be filled with the rectangle describing
 *      where the menu item content is to be drawn.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawMenuItem( const (*var*) inMenuRect: HIRect; const (*var*) inItemRect: HIRect; const (*var*) inItemDrawInfo: HIThemeMenuItemDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation; var outContentRect: HIRect ): OSStatus; external name '_HIThemeDrawMenuItem';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawMenuSeparator()
 *  
 *  Summary:
 *    Draws a themed menu separator.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inMenuRect:
 *      An HIRect indicating the bounds of the whole menu for which the
 *      menu separator is to be drawn.
 *    
 *    inItemRect:
 *      An HIRect for the bounds of the menu separator to be drawn.
 *    
 *    inItemDrawInfo:
 *      An HIThemeMenuItemDrawInfo describing the drawing
 *      characteristics of the menu item to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawMenuSeparator( const (*var*) inMenuRect: HIRect; const (*var*) inItemRect: HIRect; const (*var*) inItemDrawInfo: HIThemeMenuItemDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawMenuSeparator';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetMenuBackgroundShape()
 *  
 *  Summary:
 *    Gets the shape of the background for a themed menu.
 *  
 *  Discussion:
 *    This shape can extend outside of the bounds of the specified
 *    rectangle.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inMenuRect:
 *      An HIRect indicating the bounds of the menu for which the menu
 *      background is to be drawn.
 *    
 *    inMenuDrawInfo:
 *      An HIThemeMenuDrawInfo describing the menu to be measured.
 *    
 *    outShape:
 *      A valid HIShape that will be cleared and filled with the shape
 *      of the menu background.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetMenuBackgroundShape( const (*var*) inMenuRect: HIRect; const (*var*) inMenuDrawInfo: HIThemeMenuDrawInfo; var outShape: HIShapeRef ): OSStatus; external name '_HIThemeGetMenuBackgroundShape';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{ -------------------------------------------------------------------------- }
{  Segments                                                                  }
{ -------------------------------------------------------------------------- }

{
 *  Summary:
 *    Available values for HIThemeSegmentPosition. These are positions
 *    of the segments within the segmented view.
 }
const
{
   * The first position of a segmented view.
   }
	kHIThemeSegmentPositionFirst = 0;

  {
   * A middle segment.
   }
	kHIThemeSegmentPositionMiddle = 1;

  {
   * The last position of a segmented view.
   }
	kHIThemeSegmentPositionLast = 2;

  {
   * The only position of a segmented view. It is simultaneously first
   * and last. You know, only. There is only one segment. It looks
   * pretty much like a button. Please don't use this if you can avoid
   * it. It's ugly.
   }
	kHIThemeSegmentPositionOnly = 3;

type
	HIThemeSegmentPosition = UInt32;

{
 *  Summary:
 *    Available values for HIThemeSegmentKind.
 }
const
{
   * The outset looking segment. Do not use on metal or metal-like
   * windows.
   }
	kHIThemeSegmentKindNormal = 0;

  {
   * The inset segment. Use on metal or metal-like windows.
   }
	kHIThemeSegmentKindInset = 1;

type
	HIThemeSegmentKind = UInt32;

{
 *  Summary:
 *    Available values for HIThemeSegmentSize.
 }
const
{
   * The normally sized segment.
   }
	kHIThemeSegmentSizeNormal = 0;

  {
   * The small segment. Not available with as inset.
   }
	kHIThemeSegmentSizeSmall = 1;

  {
   * The mini segment. Not available with as inset.
   }
	kHIThemeSegmentSizeMini = 3;

type
	HIThemeSegmentSize = UInt32;

const
{
   * No segment adornments are to be drawn.
   }
	kHIThemeSegmentAdornmentNone = 0;

  {
   * A focus ring is to be drawn around the segment.
   }
	kHIThemeSegmentAdornmentFocus = 1 shl 2; { to match button focus adornment }

  {
   * If available, a leading separator is to be drawn on the segment.
   * Note that segments overlap and if the separators are drawn over
   * top each other, the shadows multiply undesirably.
   }
	kHIThemeSegmentAdornmentLeadingSeparator = 1 shl 3;

  {
   * If available, a trailing separator is to be drawn on the segment.
   * Note that segments overlap and if the separators are drawn over
   * top each other, the shadows multiply undesirably.
   }
	kHIThemeSegmentAdornmentTrailingSeparator = 1 shl 4;

type
	HIThemeSegmentAdornment = UInt32;

{
 *  HIThemeSegmentDrawInfo
 *  
 *  Summary:
 *    Drawing parameters passed to segment drawing and measuring theme
 *    APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.4.
 }
type
	HIThemeSegmentDrawInfo = record
{
   * The version of this data structure.  Currently, it is always 0.
   }
		version: UInt32;

  {
   * The ThemeDrawState for the segment to be drawn or measured.
   }
		state: ThemeDrawState;

  {
   * The ThemeButtonValue of the segment to be drawn or measured.
   }
		value: ThemeButtonValue;
		size: HIThemeSegmentSize;

  {
   * The HIThemeSegmentKind of the segment to be drawn or measured.
   }
		kind: HIThemeSegmentKind;

  {
   * The HIThemeSegmentPositions of the segment to be drawn or measured.
   }
		position: HIThemeSegmentPosition;

  {
   * The HIThemeSegmentAdornment of the segment to be drawn or measured.
   }
		adornment: HIThemeSegmentAdornment;
	end;
	HIThemeSegmentDrawInfoPtr = ^HIThemeSegmentDrawInfo;
{
 *  HIThemeDrawSegment()
 *  
 *  Summary:
 *    Draw a piece of a segmented view.
 *  
 *  Discussion:
 *    New in Mac OS X 10.4. Please note that segments can draw a
 *    separator outside of the specified bounds and the adornments of
 *    the individual segments must coordinate their drawing of
 *    separators (with the adornment field of the passed in
 *    HIThemeSegmentDrawInfo) to avoid overdrawing.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inBounds:
 *      The bounds of the segment to be drawn.
 *    
 *    inDrawInfo:
 *      A HIThemeSegmentDrawInfo describing the segment to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.4 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawSegment( const (*var*) inBounds: HIRect; const (*var*) inDrawInfo: HIThemeSegmentDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawSegment';
(* AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER *)


{ -------------------------------------------------------------------------- }
{  Tabs                                                                      }
{ -------------------------------------------------------------------------- }
{
 *  HIThemeDrawTabPane()
 *  
 *  Summary:
 *    Draws a themed tab pane.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inRect:
 *      The HIRect in which to draw the pane.
 *    
 *    inDrawInfo:
 *      The HIThemeTabPaneDrawInfo of the tab pane to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawTabPane( const (*var*) inRect: HIRect; const (*var*) inDrawInfo: HIThemeTabPaneDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawTabPane';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawTab()
 *  
 *  Summary:
 *    Draw a themed tab.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inRect:
 *      The HIRect in which to draw.
 *    
 *    inDrawInfo:
 *      An HIThemeTabDrawInfo describing the tab to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *    
 *    outLabelRect:
 *      An HIRect into which to put the bounds of the label rect.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawTab( const (*var*) inRect: HIRect; const (*var*) inDrawInfo: HIThemeTabDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation; outLabelRect: HIRectPtr { can be NULL } ): OSStatus; external name '_HIThemeDrawTab';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetTabPaneDrawShape()
 *  
 *  Summary:
 *    Gets the shape of the draw area relative to the full bounds of
 *    the tab+pane.
 *  
 *  Discussion:
 *    This API was mistakenly named as a "Get" API. It behaves as
 *    "Copy" API. THE CALLER IS RESPONSIBLE FOR RELEASING THE RETURNED
 *    SHAPE.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inRect:
 *      The HIRect for which to get the shape.
 *    
 *    inDirection:
 *      A ThemeTabDirection describing on which side of the pane the
 *      tabs will be drawn.
 *    
 *    inTabSize:
 *      An HIThemeTabSize indicating what size of tab pane to draw.
 *    
 *    outShape:
 *      A pointer to an HIShapeRef which will be set to the shape of
 *      the draw area. Needs to be released by caller.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetTabPaneDrawShape( const (*var*) inRect: HIRect; inDirection: ThemeTabDirection; inTabSize: HIThemeTabSize; var outShape: HIShapeRef ): OSStatus; external name '_HIThemeGetTabPaneDrawShape';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetTabPaneContentShape()
 *  
 *  Summary:
 *    Gets the shape of the content area relative to the full bounds of
 *    the tab+pane.
 *  
 *  Discussion:
 *    This API was mistakenly named as a "Get" API. It behaves as
 *    "Copy" API. THE CALLER IS RESPONSIBLE FOR RELEASING THE RETURNED
 *    SHAPE.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inRect:
 *      The HIRect for which to get the shape.
 *    
 *    inDirection:
 *      A ThemeTabDirection describing on which side of the pane the
 *      tabs will be drawn.
 *    
 *    inTabSize:
 *      An HIThemeTabSize indicating what size of tab pane to draw.
 *    
 *    outShape:
 *      A pointer to an HIShapeRef which will be set to the shape of
 *      the draw content. Needs to be released by caller.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetTabPaneContentShape( const (*var*) inRect: HIRect; inDirection: ThemeTabDirection; inTabSize: HIThemeTabSize; var outShape: HIShapeRef ): OSStatus; external name '_HIThemeGetTabPaneContentShape';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetTabDrawShape()
 *  
 *  Summary:
 *    Gets the shape of the tab drawing area relative to the full
 *    bounds of the tab+pane.
 *  
 *  Discussion:
 *    This API was mistakenly named as a "Get" API. It behaves as
 *    "Copy" API. THE CALLER IS RESPONSIBLE FOR RELEASING THE RETURNED
 *    SHAPE.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inRect:
 *      The HIRect for which to get the shape.
 *    
 *    inDrawInfo:
 *      An HIThemeTabDrawInfo describing the tab that will be drawn.
 *    
 *    outShape:
 *      A pointer to an HIShapeRef which will be set to the shape of
 *      the tab drawing area. Needs to be released by caller.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetTabDrawShape( const (*var*) inRect: HIRect; const (*var*) inDrawInfo: HIThemeTabDrawInfo; var outShape: HIShapeRef ): OSStatus; external name '_HIThemeGetTabDrawShape';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetTabShape()
 *  
 *  Summary:
 *    Gets the shape for a themed tab.
 *  
 *  Discussion:
 *    This API was mistakenly named as a "Get" API. It behaves as
 *    "Copy" API. THE CALLER IS RESPONSIBLE FOR RELEASING THE RETURNED
 *    SHAPE.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inRect:
 *      An HIRect indicating the entire tabs area for which the tab
 *      shape is to be retrieved.
 *    
 *    inDrawInfo:
 *      An HIThemeTabDrawInfo describing the tab that will be drawn.
 *    
 *    outShape:
 *      A pointer to an HIShapeRef which will be set to the shape of
 *      the tab. Needs to be released by caller.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetTabShape( const (*var*) inRect: HIRect; const (*var*) inDrawInfo: HIThemeTabDrawInfo; var outShape: HIShapeRef ): OSStatus; external name '_HIThemeGetTabShape';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{ -------------------------------------------------------------------------- }
{  Text                                                                      }
{ -------------------------------------------------------------------------- }

const
{
   * Don't truncate the measured or drawn text.
   }
	kHIThemeTextTruncationNone = 0;

  {
   * During measure or draw, if the text will not fit within the
   * available bounds, truncate the text in the middle of the last
   * visible line.
   }
	kHIThemeTextTruncationMiddle = 1;

  {
   * During measure or draw, if the text will not fit within the
   * available bounds, truncate the text at the end of the last visible
   * line.
   }
	kHIThemeTextTruncationEnd = 2;

type
	HIThemeTextTruncation = UInt32;

const
{
   * The text will be drawn flush with the left side of the bounding
   * box.
   }
	kHIThemeTextHorizontalFlushLeft = 0;

  {
   * The text will be centered within the bounding box.
   }
	kHIThemeTextHorizontalFlushCenter = 1;

  {
   * The text will be drawn flush with the right side of the bounding
   * box.
   }
	kHIThemeTextHorizontalFlushRight = 2;

type
	HIThemeTextHorizontalFlush = UInt32;

const
{
   * Draw the text vertically flush with the top of the box
   }
	kHIThemeTextVerticalFlushTop = 0;

  {
   * Vertically center the text
   }
	kHIThemeTextVerticalFlushCenter = 1;

  {
   * Draw the text vertically flush with the bottom of the box
   }
	kHIThemeTextVerticalFlushBottom = 2;

type
	HIThemeTextVerticalFlush = UInt32;

const
	kHIThemeTextBoxOptionNone = 0;
	kHIThemeTextBoxOptionStronglyVertical = 1 shl 1;

type
	HIThemeTextBoxOptions = OptionBits;
const
	kHIThemeTextInfoVersionZero = 0;


{
 *  HIThemeTextInfo
 *  
 *  Summary:
 *    Drawing parameters passed to text drawing and measuring theme
 *    APIs.
 *  
 *  Discussion:
 *    New in Mac OS X 10.3, this structure is used for measuring and
 *    drawing text with the HIThemeGetTextDimensions and
 *    HIThemeDrawTextBox APIs. If truncationPosition is
 *    kHIThemeTextTruncationNone, the other fields with the truncation
 *    prefix are ignored.
 }
type
	HIThemeTextInfo = record
{
   * The version of this data structure. Currently, it is always 0.
   }
		version: UInt32;                { current version is 0 }

  {
   * The theme draw state in which to draw the string.
   }
		state: ThemeDrawState;

  {
   * The font in which to draw the string.
   }
		fontID: ThemeFontID;

  {
   * The horizontal flushness of the text. One of the
   * kHIThemeTextHorizontalFlush[Left/Center/Right] constants. When
   * this structure is used for HIThemeGetTextDimensions, this field
   * has no effect on the returned dimensions. However, providing the
   * same flushness that will be used with a subsequent draw will
   * trigger a performance optimization.
   }
		horizontalFlushness: HIThemeTextHorizontalFlush; { kHIThemeTextHorizontalFlush[Left/Center/Right] }

  {
   * The vertical flushness of the text. One of the
   * kHIThemeTextVerticalFlush[Top/Center/Bottom] constants. When this
   * paramblock is used for HIThemeGetTextDimensions, this field has no
   * effect on the returned dimensions. However, providing the same
   * flushness that will be used with a subsequent draw will trigger a
   * performance optimization.
   }
		verticalFlushness: HIThemeTextVerticalFlush; { kHIThemeTextVerticalFlush[Top/Center/Bottom] }

  {
   * Currently, the only option available is for strongly vertical text
   * with the kThemeTextBoxOptionStronglyVertical option bit.
   }
		options: HIThemeTextBoxOptions;             { includes kHIThemeTextBoxOptionStronglyVertical }

  {
   * Specifies where truncation should occur. If this field is
   * kHIThemeTruncationNone, no truncation will occur, and all fields
   * with the truncation prefix will be ignored.
   }
		truncationPosition: HIThemeTextTruncation;  { kHIThemeTextTruncation[None/Middle/End], If none the following field is ignored }

  {
   * The maximum number of lines to measure or draw before truncation
   * occurs. Ignored if truncationPosition is kHIThemeTruncationNone.
   }
		truncationMaxLines: UInt32;     { the maximum number of lines before truncation occurs }

  {
   * On output, if the text has been truncated, this is set to true. If
   * the text fit completely within the parameters specified and the
   * text was not truncated, this is set to false.
   }
		truncationHappened: Boolean;     { on output, whether truncation needed to happen }
	end;
	HIThemeTextInfoPtr = ^HIThemeTextInfo;
{
 *  HIThemeGetTextDimensions()
 *  
 *  Summary:
 *    Get text dimensions of a string
 *  
 *  Discussion:
 *    This allows you to get various dimension characteristics of a
 *    string bound to certain criteria that you specify. It allows you
 *    to get the absolute bounds of a string laid out in a single line,
 *    or the bounds of a string constrained to a given width.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inString:
 *      A CFStringRef containing the unicode characters you wish to
 *      measure. You MUST NOT pass in a CFStringRef that was allocated
 *      with any of the "NoCopy" CFString creation APIs; a string
 *      created with a "NoCopy" API has transient storage which is
 *      incompatible with HIThemeGetTextDimensions's caches.
 *    
 *    inWidth:
 *      The width to constrain the text before wrapping. If inWidth is
 *      0, the text will not wrap and will be laid out as a single
 *      line, unless it contains embedded carriage return or linefeed
 *      characters; CR/LF will cause the text to wrap and the resulting
 *      measurements will include space for multiple lines of text. If
 *      inWidth is not 0, the text will wrap at the given width and the
 *      measurements will be returned from the multi-line layout.
 *      
 *      
 *      To force single-line layout even in the presence of embedded
 *      CR/LF characters, pass FLT_MAX for inWidth,
 *      kHIThemeTextTruncationEnd for inTextInfo.truncationPosition,
 *      and 1 for inTextInfo.truncationMaxLines.
 *    
 *    inTextInfo:
 *      The HIThemeTextInfo parameter block specifying additional
 *      options for flushness and truncation. The truncationHappened
 *      field is the only field that will be written to by this API
 *      (and the reason for inTextInfo not being const).
 *    
 *    outWidth:
 *      On output, will contain the width of the string. This width may
 *      be smaller than the constrain inWidth parameter if the text has
 *      wrapped. It will return the true bounding width of the layout.
 *      Can be NULL.
 *    
 *    outHeight:
 *      On output, will contain the height of the string. Can be NULL.
 *    
 *    outBaseline:
 *      On output, will contain the baseline of the string. This is the
 *      delta from the top of the text to the baseline of the first
 *      line. Can be NULL.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetTextDimensions( inString: CFStringRef; inWidth: Float32; var inTextInfo: HIThemeTextInfo; outWidth: Float32Ptr { can be NULL }; outHeight: Float32Ptr { can be NULL }; outBaseline: Float32Ptr { can be NULL } ): OSStatus; external name '_HIThemeGetTextDimensions';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawTextBox()
 *  
 *  Summary:
 *    Draw the string into the given bounding box
 *  
 *  Discussion:
 *    Draw the string into the bounding box given. You can specify
 *    options such as truncation and justification as well as
 *    determining whether the text was truncated when it was drawn.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inString:
 *      A CFStringRef containing the unicode characters you wish to
 *      render. You MUST NOT pass in a CFStringRef that was allocated
 *      with any of the "NoCopy" CFString creation APIs; a string
 *      created with a "NoCopy" API has transient storage which is
 *      incompatible with HIThemeDrawTextBox's caches.
 *    
 *    inBounds:
 *      The HIRect that bounds where the text is to be drawn
 *    
 *    inTextInfo:
 *      The HIThemeTextInfo parameter block specifying additional
 *      options for truncation and flushness. You can control the
 *      number of lines drawn by specifying a truncation of
 *      kHIThemeTextTruncationMiddle or kHIThemeTextTruncationEnd for
 *      the truncationPosition field and then specifying a maximum
 *      number of lines to draw before truncation occurs in the
 *      truncationMaxLines field. The truncationHappened field is the
 *      only field that will be written to by this API (and the reason
 *      for inTextInfo not being const).
 *    
 *    inContext:
 *      The CGContextRef into which to draw the text.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawTextBox( inString: CFStringRef; const (*var*) inBounds: HIRect; var inTextInfo: HIThemeTextInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawTextBox';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{ -------------------------------------------------------------------------- }
{  Tracks                                                                    }
{ -------------------------------------------------------------------------- }
{
 *  HIThemeDrawTrack()
 *  
 *  Summary:
 *    Draw a themed track item.
 *  
 *  Discussion:
 *    Used to draw any tracked element including sliders and scroll
 *    bars.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inDrawInfo:
 *      An HIThemeTrackDrawInfo describing the track that will be drawn.
 *    
 *    inGhostRect:
 *      An HIRect describing the location of the ghost indicator to be
 *      drawn. Generally, this should be NULL and the control using
 *      this primitive should support live feeback.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawTrack( const (*var*) inDrawInfo: HIThemeTrackDrawInfo; {const} inGhostRect: HIRectPtr { can be NULL }; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawTrack';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawTrackTickMarks()
 *  
 *  Summary:
 *    Draws the tick marks for a slider track.
 *  
 *  Discussion:
 *    This primitive only draws evenly distributed tick marks. 
 *    Internally, it calls HIThemeDrawTickMark to do the actual tick
 *    mark drawing, and any custom (non-even distribution) drawing of
 *    tick marks should be done with HIThemeDrawTickMark.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inDrawInfo:
 *      An HIThemeTrackDrawInfo describing the track tick marks that
 *      will be drawn.
 *    
 *    inNumTicks:
 *      A value indicating the number of tick marks to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawTrackTickMarks( const (*var*) inDrawInfo: HIThemeTrackDrawInfo; inNumTicks: ItemCount; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawTrackTickMarks';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawTickMark()
 *  
 *  Summary:
 *    Draws a single tick mark.
 *  
 *  Discussion:
 *    This primitive draws a single tick mark and can be used to draw
 *    custom tick marks that are not easily drawn by
 *    HIThemeDrawTrackTickMarks, which only draws evenly distributed
 *    tick marks.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inBounds:
 *      The HIRect in which to draw.
 *    
 *    inDrawInfo:
 *      The HIThemeTickMarkDrawInfo of the tick mark to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawTickMark( const (*var*) inBounds: HIRect; const (*var*) inDrawInfo: HIThemeTickMarkDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawTickMark';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetTrackThumbShape()
 *  
 *  Summary:
 *    Get the thumb shape of a themed track.
 *  
 *  Discussion:
 *    This API was mistakenly named as a "Get" API. It behaves as
 *    "Copy" API. THE CALLER IS RESPONSIBLE FOR RELEASING THE RETURNED
 *    SHAPE.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inDrawInfo:
 *      An HIThemeTrackDrawInfo describing the track to be measured.
 *    
 *    outThumbShape:
 *      A pointer to an HIShapeRef which will be set to the shape of
 *      the themed track's thumb. Needs to be released by caller.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetTrackThumbShape( const (*var*) inDrawInfo: HIThemeTrackDrawInfo; var outThumbShape: HIShapeRef ): OSStatus; external name '_HIThemeGetTrackThumbShape';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeHitTestTrack()
 *  
 *  Summary:
 *    Hit test the themed track.
 *  
 *  Discussion:
 *    Returns true if the track was hit and fills in outPartHit. 
 *    Otherwise, returns false.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inDrawInfo:
 *      An HIThemeTabDrawInfo describing the tab that will be drawn.
 *    
 *    inMousePoint:
 *      An HIPoint which will be location basis for the test.
 *    
 *    outPartHit:
 *      A pointer to a ControlPartCode that will be filled with the
 *      part hit by the incoming point.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeHitTestTrack( const (*var*) inDrawInfo: HIThemeTrackDrawInfo; const (*var*) inMousePoint: HIPoint; var outPartHit: ControlPartCode ): Boolean; external name '_HIThemeHitTestTrack';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetTrackBounds()
 *  
 *  Summary:
 *    Gets the track bounds of a themed track.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inDrawInfo:
 *      An HIThemeTrackDrawInfo describing the track that will be drawn.
 *    
 *    outBounds:
 *      A pointer to an HIRect in which will be returned the rectangle
 *      of the track bounds.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetTrackBounds( const (*var*) inDrawInfo: HIThemeTrackDrawInfo; var outBounds: HIRect ): OSStatus; external name '_HIThemeGetTrackBounds';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetTrackPartBounds()
 *  
 *  Summary:
 *    Returns measurements for the bounds of the a track part,
 *    according to the specifics of that track as specified in the
 *    incoming draw info record.
 *  
 *  Discussion:
 *    HIThemeGetTrackPartBounds allows you to get the boundaries of
 *    individual pieces of a track's theme layout.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inDrawInfo:
 *      An HIThemeTrackDrawInfo describing the track to be measured.
 *    
 *    inPartCode:
 *      A ControlPartCode describing which part to measure.  A list of
 *      available ControlPartCodes can be retrieved using
 *      HIThemeGetTrackParts.
 *    
 *    outPartBounds:
 *      The bounds of the specified part relative to the start
 *      rectangle specified in inDrawInfo.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetTrackPartBounds( const (*var*) inDrawInfo: HIThemeTrackDrawInfo; inPartCode: ControlPartCode; var outPartBounds: HIRect ): OSStatus; external name '_HIThemeGetTrackPartBounds';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetTrackParts()
 *  
 *  Summary:
 *    Counts the number of parts that make up a track.  Optionally
 *    returns an array of ControlPartCodes that describe each of the
 *    counted parts.
 *  
 *  Discussion:
 *    HIThemeGetTrackParts allows you to count the number of parts that
 *    make up a track.  This is useful if you need to iterate through
 *    the parts of a track and get information about them, i.e. using
 *    HIThemeGetTrackPartBounds.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inDrawInfo:
 *      An HIThemeTrackDrawInfo describing the track to be measured.
 *    
 *    outNumberOfParts:
 *      A pointer to a UInt32 in which to return the number of counted
 *      parts.
 *    
 *    inMaxParts:
 *      The maximum number of ControlPartCodes that can be copied into
 *      the supplied ioPartsBuffer.  This value is ignored if
 *      ioPartsBuffer is NULL.
 *    
 *    ioPartsBuffer:
 *      An pointer to an array into which HIThemeGetTrackPartBounds
 *      will copy ControlPartCodes that describe each of the counted
 *      parts.  This pointer can be NULL if you are just counting parts.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetTrackParts( const (*var*) inDrawInfo: HIThemeTrackDrawInfo; var outNumberOfParts: UInt32; inMaxParts: UInt32; ioPartsBuffer: ControlPartCodePtr { can be NULL } ): OSStatus; external name '_HIThemeGetTrackParts';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetTrackDragRect()
 *  
 *  Summary:
 *    Get the rectangle of the drag area of a themed track.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inDrawInfo:
 *      An HIThemeTrackDrawInfo describing the track to be measured.
 *    
 *    outDragRect:
 *      A pointer to an HIRect in which will be returned the rectangle
 *      of the drag area of the track.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetTrackDragRect( const (*var*) inDrawInfo: HIThemeTrackDrawInfo; var outDragRect: HIRect ): OSStatus; external name '_HIThemeGetTrackDragRect';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetTrackThumbPositionFromOffset()
 *  
 *  Summary:
 *    Get the track's relative thumb position based on the offset.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inDrawInfo:
 *      An HIThemeTrackDrawInfo describing the track to be measured.
 *    
 *    inThumbOffset:
 *      An HIPoint describing the position of the thumb as an offset
 *      from the track bounds.
 *    
 *    outRelativePosition:
 *      On output, the track-relative position calculated from the
 *      thumb offset.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetTrackThumbPositionFromOffset( const (*var*) inDrawInfo: HIThemeTrackDrawInfo; const (*var*) inThumbOffset: HIPoint; var outRelativePosition: Float32 ): OSStatus; external name '_HIThemeGetTrackThumbPositionFromOffset';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetTrackThumbPositionFromBounds()
 *  
 *  Summary:
 *    Get the themed track thumb position from its bounds.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inDrawInfo:
 *      A pointer to an HIThemeTrackDrawInfo describing the track to be
 *      measured.
 *    
 *    inThumbBounds:
 *      The bounds of the thumb from which the postion is to be
 *      calculated.
 *    
 *    outRelativePosition:
 *      On output, the track-relative position calculated from the
 *      thumb location.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetTrackThumbPositionFromBounds( const (*var*) inDrawInfo: HIThemeTrackDrawInfo; const (*var*) inThumbBounds: HIRect; var outRelativePosition: Float32 ): OSStatus; external name '_HIThemeGetTrackThumbPositionFromBounds';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetTrackLiveValue()
 *  
 *  Summary:
 *    Get the themed track live value.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inDrawInfo:
 *      An HIThemeTrackDrawInfo describing the track to be measured.
 *    
 *    inRelativePosition:
 *      An HIPoint describing the position of the thumb as an offset
 *      from the track bounds.
 *    
 *    outValue:
 *      On output, the track value as calculated from the relative
 *      postion of the thumb.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetTrackLiveValue( const (*var*) inDrawInfo: HIThemeTrackDrawInfo; inRelativePosition: Float32; var outValue: SInt32 ): OSStatus; external name '_HIThemeGetTrackLiveValue';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetScrollBarTrackRect()
 *  
 *  Summary:
 *    Gets the rectangle of the tracking area of a themed scroll bar.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inBounds:
 *      An HIRect indicating the area in which the scroll bar will be
 *      drawn.
 *    
 *    inTrackInfo:
 *      An HIScrollBarTrackInfo for the scroll bar to be drawn.
 *      Currently, only the pressState and enableState fields are used.
 *    
 *    inIsHoriz:
 *      A Boolean where true means that the scroll bar is to be
 *      horizontal and false means that the scroll bar is to be
 *      vertical.
 *    
 *    outTrackBounds:
 *      A pointer to an HIRect in which will be returned the rectangle
 *      of the track area of the scroll bar.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetScrollBarTrackRect( const (*var*) inBounds: HIRect; const (*var*) inTrackInfo: HIScrollBarTrackInfo; inIsHoriz: Boolean; var outTrackBounds: HIRect ): OSStatus; external name '_HIThemeGetScrollBarTrackRect';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeHitTestScrollBarArrows()
 *  
 *  Summary:
 *    Hit test the theme scroll bar arrows to determine where the hit
 *    occurred.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inScrollBarBounds:
 *      An HIRect indicating the bounds of the scroll bar that will be
 *      hit tested.
 *    
 *    inTrackInfo:
 *      An HIScrollBarTrackInfo for the scroll bar to be drawn.
 *      Currently, only the version, pressState and enableState fields
 *      are used.
 *    
 *    inIsHoriz:
 *      A Boolean where true means that the scroll bar is to be
 *      horizontal and false means that the scroll bar is to be
 *      vertical.
 *    
 *    inPtHit:
 *      An HIPoint indicating where the control was hit and which will
 *      be used for hit testing.
 *    
 *    outTrackBounds:
 *      A pointer to an HIRect in which will be returned the rectangle
 *      of the track area of the scroll bar.  Can be NULL.
 *    
 *    outPartCode:
 *      A pointer to a ControlPartCode in which the part code of the
 *      hit part will be returned.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeHitTestScrollBarArrows( const (*var*) inScrollBarBounds: HIRect; const (*var*) inTrackInfo: HIScrollBarTrackInfo; inIsHoriz: Boolean; const (*var*) inPtHit: HIPoint; outTrackBounds: HIRectPtr { can be NULL }; var outPartCode: ControlPartCode ): Boolean; external name '_HIThemeHitTestScrollBarArrows';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawScrollBarDelimiters()
 *  
 *  Summary:
 *    Draw themed scroll bar delimiters.
 *  
 *  Discussion:
 *    Draws the grow lines delimiting the scroll bar areas.  Does not
 *    draw the size box.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inContRect:
 *      An HIRect indicating the rectangle of the content area of the
 *      window to be drawn.
 *    
 *    inDrawInfo:
 *      The HIThemeScrollBarDelimitersDrawInfo of the delimiters to be
 *      drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawScrollBarDelimiters( const (*var*) inContRect: HIRect; const (*var*) inDrawInfo: HIThemeScrollBarDelimitersDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawScrollBarDelimiters';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{ -------------------------------------------------------------------------- }
{  Windows                                                                   }
{ -------------------------------------------------------------------------- }
{
 *  HIThemeDrawWindowFrame()
 *  
 *  Summary:
 *    Draws a themed window frame.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inContRect:
 *      An HIRect indicating the rectangle of the content area of the
 *      window to be drawn.
 *    
 *    inDrawInfo:
 *      The HIThemeWindowDrawInfo of the window frame to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *    
 *    outTitleRect:
 *      A pointer to an HIRect into which to put the bounds of the
 *      title rect.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawWindowFrame( const (*var*) inContRect: HIRect; const (*var*) inDrawInfo: HIThemeWindowDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation; outTitleRect: HIRectPtr { can be NULL } ): OSStatus; external name '_HIThemeDrawWindowFrame';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawTitleBarWidget()
 *  
 *  Summary:
 *    Draws the requested theme title bar widget.
 *  
 *  Discussion:
 *    HIThemeDrawTitleBarWidget renders the requested theme title bar
 *    widget in the proper location of a window.  A common
 *    misconception when using this API is that the client must specify
 *    the exact location of the widget in the window. The widget will
 *    locate itself in the window based relative to the content rect
 *    passed in content rectangle -- the contRect parameter.  Another
 *    common problem is to ignore the window's attributes.  The
 *    attributes must be set up properly to describe the window for
 *    which the widget is to be drawn.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inContRect:
 *      A rectangle describing the window's content area.  The widget
 *      is drawn relative to the content rectangle of the window, so
 *      this parameter does not describe the actual widget bounds, it
 *      describes the window's content rectangle.
 *    
 *    inDrawInfo:
 *      The HIThemeWindowWidgetDrawInfo of the window widget to be
 *      drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawTitleBarWidget( const (*var*) inContRect: HIRect; const (*var*) inDrawInfo: HIThemeWindowWidgetDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawTitleBarWidget';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawGrowBox()
 *  
 *  Summary:
 *    Draws a theme grow box.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inOrigin:
 *      The origin from which to draw the grow box.
 *    
 *    inDrawInfo:
 *      An HIThemeGrowBoxDrawInfo describing the grow box to be drawn
 *      or measured.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawGrowBox( const (*var*) inOrigin: HIPoint; const (*var*) inDrawInfo: HIThemeGrowBoxDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawGrowBox';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetGrowBoxBounds()
 *  
 *  Summary:
 *    Gets the bounds for a grow box.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inOrigin:
 *      The origin from which to draw the grow box.
 *    
 *    inDrawInfo:
 *      An HIThemeGrowBoxDrawInfo describing the grow box to be drawn
 *      or measured. The state field is ignored.
 *    
 *    outBounds:
 *      A pointer to an HIRect in which will be returned the rectangle
 *      of the standalone grow box bounds.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetGrowBoxBounds( const (*var*) inOrigin: HIPoint; const (*var*) inDrawInfo: HIThemeGrowBoxDrawInfo; var outBounds: HIRect ): OSStatus; external name '_HIThemeGetGrowBoxBounds';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetWindowShape()
 *  
 *  Summary:
 *    Obtains the specified window shape.
 *  
 *  Discussion:
 *    This API was mistakenly named as a "Get" API. It behaves as
 *    "Copy" API. THE CALLER IS RESPONSIBLE FOR RELEASING THE RETURNED
 *    SHAPE.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inContRect:
 *      An HIRect indicating the rectangle of the content area of the
 *      window to be drawn.
 *    
 *    inDrawInfo:
 *      The HIThemeWindowDrawInfo of the window frame to be measured.
 *    
 *    inWinRegion:
 *      A WindowRegionCode indicating the desired region for which to
 *      return the shape.
 *    
 *    outShape:
 *      A pointer to an HIShapeRef which will be set to the shape of
 *      the requested window region. Needs to be released by caller.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetWindowShape( const (*var*) inContRect: HIRect; const (*var*) inDrawInfo: HIThemeWindowDrawInfo; inWinRegion: WindowRegionCode; var outShape: HIShapeRef ): OSStatus; external name '_HIThemeGetWindowShape';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeGetWindowRegionHit()
 *  
 *  Summary:
 *    Get the window region hit in a themed window.
 *  
 *  Discussion:
 *    Not that this call does not return a region, but a region code.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inContRect:
 *      An HIRect indicating the rectangle of the content area of the
 *      window to be drawn.
 *    
 *    inDrawInfo:
 *      The HIThemeWindowDrawInfo of the window frame to be measured.
 *    
 *    inPoint:
 *      An HIPoint against which the test will occur.
 *    
 *    outRegionHit:
 *      The output WindowRegionCode of hit window region.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeGetWindowRegionHit( const (*var*) inContRect: HIRect; const (*var*) inDrawInfo: HIThemeWindowDrawInfo; const (*var*) inPoint: HIPoint; var outRegionHit: WindowRegionCode ): Boolean; external name '_HIThemeGetWindowRegionHit';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{ -------------------------------------------------------------------------- }
{  Miscellaneous                                                             }
{ -------------------------------------------------------------------------- }
{
 *  HIThemeDrawFrame()
 *  
 *  Summary:
 *    Draws a variety of frames frame.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inRect:
 *      The HIRect in which to draw.
 *    
 *    inDrawInfo:
 *      An HIThemeFrameDrawInfo describing the frame to be drawn or
 *      measured.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawFrame( const (*var*) inRect: HIRect; const (*var*) inDrawInfo: HIThemeFrameDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawFrame';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawGroupBox()
 *  
 *  Summary:
 *    Draws a themed primary group box.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inRect:
 *      The HIRect in which to draw.
 *    
 *    inDrawInfo:
 *      An HIThemeGroupBoxDrawInfo describing the group box to be drawn
 *      or measured.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawGroupBox( const (*var*) inRect: HIRect; const (*var*) inDrawInfo: HIThemeGroupBoxDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawGroupBox';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawGenericWell()
 *  
 *  Summary:
 *    Draws a themed generic well.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inRect:
 *      The HIRect in which to draw.
 *    
 *    inDrawInfo:
 *      An HIThemeButtonDrawInfo that describes attributes of the well
 *      to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawGenericWell( const (*var*) inRect: HIRect; const (*var*) inDrawInfo: HIThemeButtonDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawGenericWell';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawPaneSplitter()
 *  
 *  Summary:
 *    Draws a themed pane splitter.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inRect:
 *      The HIRect in which to draw.
 *    
 *    inDrawInfo:
 *      The HIThemeSplitterDrawInfo of the pane splitter to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawPaneSplitter( const (*var*) inRect: HIRect; const (*var*) inDrawInfo: HIThemeSplitterDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawPaneSplitter';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawGrabber()
 *  
 *  Summary:
 *    Draws a themed grabber.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inRect:
 *      The HIRect in which to draw.
 *    
 *    inDrawInfo:
 *      The HIThemeGrabberDrawInfo of the grabber to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawGrabber( const (*var*) inRect: HIRect; const (*var*) inDrawInfo: HIThemeGrabberDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawGrabber';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawPlacard()
 *  
 *  Summary:
 *    Draws a themed placard.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inRect:
 *      The HIRect in which to draw.
 *    
 *    inDrawInfo:
 *      The HIThemePlacardDrawInfo of the placard to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawPlacard( const (*var*) inRect: HIRect; const (*var*) inDrawInfo: HIThemePlacardDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawPlacard';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawHeader()
 *  
 *  Summary:
 *    Draws a themed window header in the specified rectangle.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inRect:
 *      The HIRect in which to draw.
 *    
 *    inDrawInfo:
 *      The HIThemeHeaderDrawInfo of the window frame to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawHeader( const (*var*) inRect: HIRect; const (*var*) inDrawInfo: HIThemeHeaderDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawHeader';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawFocusRect()
 *  
 *  Summary:
 *    Draws a themed focus rectangle in the specified rectangle.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inRect:
 *      The HIRect in which to draw.
 *    
 *    inHasFocus:
 *      Pass in true to draw focus. Passing false effectively makes
 *      this API a no-op.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawFocusRect( const (*var*) inRect: HIRect; inHasFocus: Boolean; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawFocusRect';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawSeparator()
 *  
 *  Summary:
 *    Draw a themed separator element.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inRect:
 *      The HIRect in which to draw.
 *    
 *    inDrawInfo:
 *      The HIThemeSeparatorDrawInfo of the window frame to be drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawSeparator( const (*var*) inRect: HIRect; const (*var*) inDrawInfo: HIThemeSeparatorDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawSeparator';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeSetFill()
 *  
 *  Summary:
 *    Set the context fill color to that specified by the requested
 *    brush.
 *  
 *  Discussion:
 *    Note that this call does not actually draw anything. It sets the
 *    passed context's fill color to that of the specified theme brush.
 *    Subsequent fills in the context will be with the color specified
 *    by the theme brush.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inBrush:
 *      The ThemeBrush describing the requested fill color.
 *    
 *    inInfo:
 *      Not used. Should always be NULL.
 *    
 *    inContext:
 *      The CG context for which the fill color is to be set.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.4 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.4 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeSetFill( inBrush: ThemeBrush; inInfo: UnivPtr; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeSetFill';
(* AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER *)


{
 *  HIThemeSetStroke()
 *  
 *  Summary:
 *    Set the context stroke color to that specified by the requested
 *    brush.
 *  
 *  Discussion:
 *    Note that this call does not actually draw anything. It sets the
 *    passed context's stroke color to that of the specified theme
 *    brush. Subsequent strokes in the context will be with the color
 *    specified by the theme brush.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inBrush:
 *      The ThemeBrush describing the requested stroke color.
 *    
 *    inInfo:
 *      Not used. Should always be NULL.
 *    
 *    inContext:
 *      The CG context for which the stroke color is to be set.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.4 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.4 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeSetStroke( inBrush: ThemeBrush; inInfo: UnivPtr; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeSetStroke';
(* AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER *)


{
 *  HIThemeSetTextFill()
 *  
 *  Summary:
 *    Set the context text fill color to that specified by the
 *    requested brush.
 *  
 *  Discussion:
 *    Note that this call does not actually draw anything. It sets the
 *    passed context's text fill color to that of the specified
 *    ThemeTextColor. Subsequent text drawing in the context will be
 *    with the color specified by the ThemeTextColor.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inColor:
 *      A ThemeTextColor describing the requested text fill color.
 *    
 *    inInfo:
 *      Not used. Should always be NULL.
 *    
 *    inContext:
 *      The CG context for which the fill color is to be set.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.4 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.4 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeSetTextFill( inColor: ThemeTextColor; inInfo: UnivPtr; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeSetTextFill';
(* AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER *)


{
 *  HIThemeApplyBackground()
 *  
 *  Summary:
 *    Apply a themed background for a rectangle.
 *  
 *  Discussion:
 *    Note that this call does not actually draw anything. It sets the
 *    passed context's fill color to the requested theme background.
 *    Subsequent fills in the context will fill with the theme
 *    background.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inBounds:
 *      An HIRect enclosing the whole background. This rectangle is
 *      used to calculate the pattern phase (if there is one) of the
 *      background as it is set up in the context.
 *    
 *    inDrawInfo:
 *      An HIThemeBackgroundDrawInfo describing the background.
 *    
 *    inContext:
 *      The CG context for which the background is to be set.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeApplyBackground( const (*var*) inBounds: HIRect; const (*var*) inDrawInfo: HIThemeBackgroundDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeApplyBackground';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeDrawBackground()
 *  
 *  Summary:
 *    Draw a themed background for a rectangle.
 *  
 *  Discussion:
 *    Currently, this call only works with kThemeBackgroundMetal.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inBounds:
 *      An HIRect indicating the bounds to fill with the background.
 *      For backgrounds that need pattern continuity, such as
 *      kThemeBackgroundMetal, this rectangle is the full bounds of the
 *      rectangle for which the filling is to occur. If drawing a
 *      sub-rectangle of that background, set the clip and draw the
 *      full rectangle. This routine has been optimized to not perform
 *      calculations on the non-clip part of the drawing bounds.
 *    
 *    inDrawInfo:
 *      An HIThemeBackgroundDrawInfo describing the background to be
 *      drawn.
 *    
 *    inContext:
 *      The CG context in which the drawing is to be done.
 *    
 *    inOrientation:
 *      An HIThemeOrientation that describes the orientation of the
 *      passed in context.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.3 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.3 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeDrawBackground( const (*var*) inBounds: HIRect; const (*var*) inDrawInfo: HIThemeBackgroundDrawInfo; inContext: CGContextRef; inOrientation: HIThemeOrientation ): OSStatus; external name '_HIThemeDrawBackground';
(* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


{
 *  HIThemeBrushCreateCGColor()
 *  
 *  Summary:
 *    Create a CGColor for a ThemeBrush.
 *  
 *  Discussion:
 *    Color is an ambiguous term. The color may be a pattern.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Parameters:
 *    
 *    inBrush:
 *      The ThemeBrush describing the requested color.
 *    
 *    outColor:
 *      A pointer to a CGColorRef that will be set to the newly created
 *      CGColor.
 *  
 *  Result:
 *    An operating system result code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.4 and later in Carbon.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.4 and later
 *    Non-Carbon CFM:   not available
 }
function HIThemeBrushCreateCGColor( inBrush: ThemeBrush; var outColor: CGColorRef ): OSStatus; external name '_HIThemeBrushCreateCGColor';
(* AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER *)




end.
