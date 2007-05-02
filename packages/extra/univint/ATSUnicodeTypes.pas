{
     File:       QD/ATSUnicodeTypes.h
 
     Contains:   ATSUI types and constants.
 
     Version:    Quickdraw-150~1
 
     Copyright:  � 2003 by Apple Computer, Inc., all rights reserved.
 
     Bugs?:      For bug reports, consult the following page on
                 the World Wide Web:
 
                     http://www.freepascal.org/bugs.html
 
}
{	  Pascal Translation:  Peter N Lewis, <peter@stairways.com.au>, 2004 }


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

unit ATSUnicodeTypes;
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
uses MacTypes,MacMemory,ATSLayoutTypes,Fonts,Quickdraw,SFNTTypes,SFNTLayoutTypes,ATSTypes,TextCommon;
{$ALIGN MAC68K}

{ See also ATSLayoutTypes.h for more ATSUI-related types and constants }
{ ---------------------------------------------------------------------------- }
{ ATSUI types and related constants                                            }
{ ---------------------------------------------------------------------------- }

{
 *  ATSUTextLayout
 *  
 *  Discussion:
 *    Text layout objects are the heart of ATSUI. These opaque objects
 *    associate Unicode text with style runs, store information about
 *    softbreaks, line and layout controls, and other information about
 *    the text. Text drawing is done by passing a valid layout object
 *    and a range of text to draw to the function ATSUDrawText, after
 *    initial setup work on the layout has been done. See the
 *    definitions of the functions ATSUCreateTextLayout and
 *    ATSUCreateTextLayoutWithTextPtr for more information about
 *    creating layouts.
 }
type
	ATSUTextLayout    = ^SInt32; { an opaque 32-bit type }

{
 *  ATSUStyle
 *  
 *  Discussion:
 *    Style objects retain information about text such as font, point
 *    size, color and other attributes. Styles are associated with text
 *    through a layout object. See the definitions of the functions
 *    ATSUSetRunStyle and ATSUCreateTextLayoutWithTextPtr for more
 *    information about assigning styles to runs of text in a layout
 *    object. See the definitions of the functions ATSUCreateStyle and
 *    ATSUSetAttributes for more information on creating and
 *    manipulating styles.
 }
type
	ATSUStyle    = ^SInt32; { an opaque 32-bit type }
	ATSUStylePtr = ^ATSUStyle;

{
 *  ATSUFontFallbacks
 *  
 *  Discussion:
 *    ATSUFontFallbacks objects are used to store the desired font
 *    fallback mode, list, and associated cache information. See the
 *    definitions of ATSUFontFallbackMethod and ATSUSetObjFontFallbacks
 *    for more information about setting up font fallbacks.
 }
type
	ATSUFontFallbacks    = ^SInt32; { an opaque 32-bit type }

{
 *  ATSUTextMeasurement
 *  
 *  Discussion:
 *    ATSUTextMeasurement is specific to ATSUI in that measurement
 *    quantities are in fractional Fixed format instead of shorts used
 *    in QuickDraw Text. This provides exact outline metrics and line
 *    specifications such as line width, ascent, descent, and so on.
 *    See FixMath.h for conversion functions for Fixed numbers.
 }
type
	ATSUTextMeasurement = Fixed;
	ATSUTextMeasurementPtr = ^ATSUTextMeasurement;

{
 *  ATSUFontID
 *  
 *  Discussion:
 *    ATSUFontID indicates a particular font family and face.
 *    ATSUFontID's are not guaranteed to remain constant across
 *    sessions. Clients should use the font's unique name to get a font
 *    token to store in documents which is guaranteed to remain
 *    constant across sessions.
 }
type
	ATSUFontID = FMFont;
	ATSUFontIDPtr = ^ATSUFontID;

{
 *  ATSUFontFeatureType
 *  
 *  Discussion:
 *    Used to identify a font feature type for a particular font. See
 *    the definitions of the functions ATSUGetAllFontFeatures and
 *    ATSUGetFontFeature for more information about font features.
 }
type
	ATSUFontFeatureType = UInt16;
	ATSUFontFeatureTypePtr = ^ATSUFontFeatureType;

{
 *  ATSUFontFeatureSelector
 *  
 *  Discussion:
 *    Used to identify a font feature selector for a particular font.
 *    See the definitions of the functions ATSUGetAllFontFeatures and
 *    ATSUGetFontFeature for more information about font features.
 }
type
	ATSUFontFeatureSelector = UInt16;
	ATSUFontFeatureSelectorPtr = ^ATSUFontFeatureSelector;

{
 *  ATSUFontVariationAxis
 *  
 *  Discussion:
 *    Used to identify a font variation axis for a particular font. See
 *    the definitions of the functions ATSUGetAllFontVariations and
 *    ATSUGetFontVariation for more information about font variations.
 }
type
	ATSUFontVariationAxis = FourCharCode;
	ATSUFontVariationAxisPtr = ^ATSUFontVariationAxis;

{
 *  ATSUFontVariationValue
 *  
 *  Discussion:
 *    Used to identify a font variation value for a particular font.
 *    See the definitions of the functions ATSUGetAllFontVariations and
 *    ATSUGetFontVariation for more information about font variations.
 }
type
	ATSUFontVariationValue = Fixed;
	ATSUFontVariationValuePtr = ^ATSUFontVariationValue;

{
 *  ATSUAttributeTag
 *  
 *  Summary:
 *    Constants used for style attributes, line controls, and layout
 *    controls.
 *  
 *  Discussion:
 *    The following constants are used to change settings in text
 *    layout and style objects. Use the functions ATSUSetLineControls,
 *    ATSUSetLayoutControls, and ATSUSetAttributes to set these values
 *    in lines, layouts, and styles, respectively. Apple reserves tag
 *    values 0 to 65535 (0 to 0x0000FFFF). ATSUI clients may create
 *    their own tags with any other value.
 }
type
	ATSUAttributeTag = UInt32;
	ATSUAttributeTagPtr = ^ATSUAttributeTag;
const

  {
   * (Type: ATSUTextMeasurement) (Default value: 0) Must not be less
   * than zero. May be set as a line or layout control.
   }
  kATSULineWidthTag             = 1;

  {
   * (Type: Fixed) (Default value: 0) Angle is specified in degrees in
   * right-handed coordinate system. May be set as a line control.
   }
  kATSULineRotationTag          = 2;

  {
   * (Type: Boolean) (Default value: GetSysDirection()) Must be 0 or 1.
   * See below for convenience constants. May be set as a line or
   * layout control.
   }
  kATSULineDirectionTag         = 3;

  {
   * (Type: Fract) (Default value: kATSUNoJustification) May be set as
   * a line or layout control.
   }
  kATSULineJustificationFactorTag = 4;

  {
   * (Type: Fract) (Default value: kATSUStartAlignment) May be set as a
   * line or layout control.
   }
  kATSULineFlushFactorTag       = 5;

  {
   * (Type: BslnBaselineRecord) (Default value: all zeros) Calculated
   * from other style attributes (e.g., font and point size). May be
   * set as a line or layout control.
   }
  kATSULineBaselineValuesTag    = 6;

  {
   * (Type: ATSLineLayoutOptions) (Default value: all zeros) See
   * ATSLayoutTypes.h for a definition of the ATSLineLayoutOptions type
   * and a list of possible values. May be set as a line or layout
   * control.
   }
  kATSULineLayoutOptionsTag     = 7;

  {
   * (Type: ATSUTextMeasurement) (Default value: determined by font(s))
   * Must not be less than zero. Starting in Mac OS X 10.2, you can
   * retrieve this value as a line or layout control, even if you have
   * not explicitly set it. This makes it easy to calculate line
   * height. May be set as a line or layout control.
   }
  kATSULineAscentTag            = 8;

  {
   * (Type: ATSUTextMeasurement) (Default value: determined by font(s))
   * Must not be less than zero. Starting in Mac OS X, you can retrieve
   * this value as a line or layout control, even if you have not
   * explicitly set it. This makes it easy to calculate line height.
   * May be set as a line or layout control.
   }
  kATSULineDescentTag           = 9;

  {
   * (Type: RegionCode) (Default value: kTextRegionDontCare) See
   * Script.h for possible values. May be set as a line or layout
   * control.
   }
  kATSULineLangRegionTag        = 10;

  {
   * (Type: TextBreakLocatorRef) (Default value: NULL) See
   * UnicodeUtilities.h for more information on creating a
   * TextBreakLocator. May be set as a line or layout control.
   }
  kATSULineTextLocatorTag       = 11;

  {
   * (Type: ATSULineTruncation) (Default value: kATSUTruncateNone) See
   * the definition of ATSULineTruncation for possible values. May be
   * set as a line or layout control.
   }
  kATSULineTruncationTag        = 12;

  {
   * (Type: ATSUFontFallbacks) (Default value: current global fallback
   * state) The current global fallback state is determined using the
   * ATSUSetFontFallbacks function. The use of this function is not
   * recommended. Instead, use the functions ATSUCreateFontFallbacks
   * and ATSUSetObjFontFallbacks to create a ATSUFontFallbacks object,
   * and then use the kATSULineFontFallbacksTag attribute to set the
   * font fallbacks object as a layout control. See the definition of
   * ATSUFontFallbacks for more information. May be set as a layout
   * control.
   }
  kATSULineFontFallbacksTag     = 13;

  {
   * (Type: CFStringRef) (Default value: user setting in System
   * Preferences) Indicates current setting for the decimal separator.
   * This affects the behavior of decimal tabs. May be set as a line or
   * layout control.
   }
  kATSULineDecimalTabCharacterTag = 14;

  {
   * (Type: ATSULayoutOperationOverrideSpecifier) (Default value: NULL)
   * See ATSUnicodeDirectAccess.h for a definition of the
   * ATSULayoutOperationOverrideSpecifier type. May be set as a layout
   * control.
   }
  kATSULayoutOperationOverrideTag = 15;

  {
   * (Type: CGColorRef) (Default value: user setting in System
   * Preferences) Indicates current setting for the highlight color.
   * May be set as a line or layout control.
   }
  kATSULineHighlightCGColorTag  = 17;

  {
   * This is just for convenience. It is the upper limit of the line
   * and layout tags.
   }
  kATSUMaxLineTag               = 18;

  {
   * This tag is obsolete. Please use kATSULineLangRegionTag instead.
   }
  kATSULineLanguageTag          = 10;

  {
   * (Type: CGContextRef) (Default value: NULL) Use this tag to produce
   * Quartz rendering with ATSUI. See the definitions of the functions
   * QDBeginCGContext and QDEndCGContext in Quickdraw.h for more
   * information about creating a CGContext from a graphics port. May
   * be set as a layout control.
   }
  kATSUCGContextTag             = 32767;

  {
   * (Type: Boolean) (Default value: false) For compatability purposes
   * only. Choosing typographic styles from font families is preferred.
   * Note this tag will produce a synthetic style for fonts that do not
   * have a typographic style. May be set as a style attribute.
   }
  kATSUQDBoldfaceTag            = 256;

  {
   * (Type: Boolean) (Default value: false) For compatability purposes
   * only. Choosing typographic styles from font families is preferred.
   * Note this tag will produce a synthetic style for fonts that do not
   * have a typographic style. May be set as a style attribute.
   }
  kATSUQDItalicTag              = 257;

  {
   * (Type: Boolean) (Default value: false) For compatability purposes
   * only. May be set as a style attribute.
   }
  kATSUQDUnderlineTag           = 258;

  {
   * (Type: Boolean) (Default value: false) For compatability purposes
   * only. May be set as a style attribute.
   }
  kATSUQDCondensedTag           = 259;

  {
   * (Type: Boolean) (Default value: false) For compatability purposes
   * only. May be set as a style attribute.
   }
  kATSUQDExtendedTag            = 260;

  {
   * (Type: ATSUFontID) (Default value: LMGetApFontID() or if not
   * valid, LMGetSysFontFam()) May be set as a style attribute.
   }
  kATSUFontTag                  = 261;

  {
   * (Type: Fixed) (Default value: Long2Fix(LMGetSysFontSize())) May be
   * set as a style attribute.
   }
  kATSUSizeTag                  = 262;

  {
   * (Type: RGBColor) (Default value: (0, 0, 0)) May be set as a style
   * attribute.
   }
  kATSUColorTag                 = 263;

  {
   * (Type: RegionCode) (Default value:
   * GetScriptManagerVariable(smRegionCode)) See Script.h for a list of
   * possible values. May be set as a style attribute.
   }
  kATSULangRegionTag            = 264;

  {
   * (Type: ATSUVerticalCharacterType) (Default value:
   * kATSUStronglyHorizontal) See the definition of
   * ATSUVerticalCharacterType for a list of possible values. May be
   * set as a style attribute.
   }
  kATSUVerticalCharacterTag     = 265;

  {
   * (Type: ATSUTextMeasurement) (Default value: kATSUseGlyphAdvance)
   * Must not be less than zero. May be set as a style attribute.
   }
  kATSUImposeWidthTag           = 266;

  {
   * (Type: Fixed) (Default value: 0) May be set as a style attribute.
   }
  kATSUBeforeWithStreamShiftTag = 267;

  {
   * (Type: Fixed) (Default value: 0) May be set as a style attribute.
   }
  kATSUAfterWithStreamShiftTag  = 268;

  {
   * (Type: Fixed) (Default value: 0) May be set as a style attribute.
   }
  kATSUCrossStreamShiftTag      = 269;

  {
   * (Type: Fixed) (Default value: kATSNoTracking) May be set as a
   * style attribute.
   }
  kATSUTrackingTag              = 270;

  {
   * (Type: Fract) (Default value: 0) May be set as a style attribute.
   }
  kATSUHangingInhibitFactorTag  = 271;

  {
   * (Type: Fract) (Default value: 0) May be set as a style attribute.
   }
  kATSUKerningInhibitFactorTag  = 272;

  {
   * (Type: Fixed) (Default value: 0) Must be between -1.0 and 1.0. May
   * be set as a style attribute.
   }
  kATSUDecompositionFactorTag   = 273;

  {
   * (Type: BslnBaselineClass) (Default value: kBSLNRomanBaseline) See
   * SFNTLayoutTypes.h for more information. Use the constant
   * kBSLNNoBaselineOverride to use intrinsic baselines. May be set as
   * a style attribute.
   }
  kATSUBaselineClassTag         = 274;

  {
   * (Type: ATSJustPriorityWidthDeltaOverrides) (Default value: all
   * zeros) See ATSLayoutTypes.h for more information. May be set as a
   * style attribute.
   }
  kATSUPriorityJustOverrideTag  = 275;

  {
   * (Type: Boolean) (Default value: false) When set to true, ligatures
   * and compound characters will not have divisable components. May be
   * set as a style attribute.
   }
  kATSUNoLigatureSplitTag       = 276;

  {
   * (Type: Boolean) (Default value: false) When set to true, ATSUI
   * will not use a glyph's angularity to determine its boundaries. May
   * be set as a style attribute.
   }
  kATSUNoCaretAngleTag          = 277;

  {
   * (Type: Boolean) (Default value: false) When set to true, ATSUI
   * will suppress automatic cross kerning (defined by font). May be
   * set as a style attribute.
   }
  kATSUSuppressCrossKerningTag  = 278;

  {
   * (Type: Boolean) (Default value: false) When set to true, ATSUI
   * will suppress glyphs' automatic optical positional alignment. May
   * be set as a style attribute.
   }
  kATSUNoOpticalAlignmentTag    = 279;

  {
   * (Type: Boolean) (Default value: false) When set to true, ATSUI
   * will force glyphs to hang beyond the line boundaries. May be set
   * as a style attribute.
   }
  kATSUForceHangingTag          = 280;

  {
   * (Type: Boolean) (Default value: false) When set to true, ATSUI
   * will not perform post-compensation justification if needed. May be
   * set as a style attribute.
   }
  kATSUNoSpecialJustificationTag = 281;

  {
   * (Type: TextBreakLocatorRef) (Default value: NULL) See
   * UnicodeUtilities.h for more information about creating a
   * TextBreakLocator. May be set as a style attribute.
   }
  kATSUStyleTextLocatorTag      = 282;

  {
   * (Type: ATSStyleRenderingOptions) (Default value:
   * kATSStyleNoOptions) See ATSLayoutTypes.h for a definition of
   * ATSStyleRenderingOptions and a list of possible values. May be set
   * as a style attribute.
   }
  kATSUStyleRenderingOptionsTag = 283;

  {
   * (Type: ATSUTextMeasurement) (Default value: determined by font)
   * Must not be less than zero. Starting in Mac OS X 10.2, you can
   * retrieve a value for this attribute, even if you have not
   * explicitly set it. This can make calculating line height easier.
   * May be set as a style attribute.
   }
  kATSUAscentTag                = 284;

  {
   * (Type: ATSUTextMeasurement) (Default value: determined by font)
   * Must not be less than zero. Starting in Mac OS X 10.2, you can
   * retrieve a value for this attribute, even if you have not
   * explicitly set it. This can make calculating line height easier.
   * May be set as a style attribute.
   }
  kATSUDescentTag               = 285;

  {
   * (Type: ATSUTextMeasurement) (Default value: determined by font)
   * Must not be less than zero. Starting in Mac OS X 10.2, you can
   * retrieve a value for this attribute, even if you have not
   * explicitly set it. This can make calculating line height easier.
   * May be set as a style attribute.
   }
  kATSULeadingTag               = 286;

  {
   * (Type: ATSUGlyphSelector) (Default value: 0) See the definition of
   * ATSUGlyphSelector for more information and a list of possible
   * values. May be set as a style attribute.
   }
  kATSUGlyphSelectorTag         = 287;

  {
   * (Type: ATSURGBAlphaColor) (Default value: (0, 0, 0, 1)) See the
   * definition of ATSURGBAlphaColor for more information. May be set
   * as a style attribute.
   }
  kATSURGBAlphaColorTag         = 288;

  {
   * (Type: CGAffineTransform) (Default value:
   * CGAffineTransformIdentity) See the definition of CGAffineTransform
   * in CGAffineTransform.h for more information. May be set as a style
   * attribute.
   }
  kATSUFontMatrixTag            = 289;

  {
   * (Type: ATSUStyleLineCountType) (Default value:
   * kATSUStyleSingleLineCount) Used to specify the number of strokes
   * to be drawn for an underline. May be set as a style attribute.
   }
  kATSUStyleUnderlineCountOptionTag = 290;

  {
   * (Type: CGColorRef) (Default value: NULL) Used to specify the color
   * of the strokes to draw for an underlined run of text. If NULL, the
   * text color is used. May be set as a style attribute.
   }
  kATSUStyleUnderlineColorOptionTag = 291;

  {
   * (Type: Boolean) (Default value: false) Used to specify
   * strikethrough style. May be set as a style attribute.
   }
  kATSUStyleStrikeThroughTag    = 292;

  {
   * (Type: ATSUStyleLineCountType) (Default value:
   * kATSUStyleSingleLineCount) Used to specify the number of strokes
   * to be drawn for a strikethrough. May be set as a style attribute.
   }
  kATSUStyleStrikeThroughCountOptionTag = 293;

  {
   * (Type: CGColorRef) (Default value: NULL) Used to specify the color
   * of the strokes to draw for a strikethrough style. If NULL, the
   * text color is used. May be set as a style attribute.
   }
  kATSUStyleStrikeThroughColorOptionTag = 294;

  {
   * (Type: Boolean) (Default value: false) Used to specify if text
   * should be drawn with a drop shadow. Only takes effect if a
   * CGContext is used for drawing. May be set as a style attribute.
   }
  kATSUStyleDropShadowTag       = 295;

  {
   * (Type: float) (Default value: 0.0) Used to specify the amount of
   * blur for a dropshadow. May be set as a style attribute.
   }
  kATSUStyleDropShadowBlurOptionTag = 296;

  {
   * (Type: CGSize) (Default value: (3.0, -3.0)) Used to specify the
   * amount of offset from the text to be used when drawing a
   * dropshadow. May be set as a style attribute.
   }
  kATSUStyleDropShadowOffsetOptionTag = 297;

  {
   * (Type: CGColorRef) (Default value: NULL) Used to specify the color
   * of the dropshadow. May be set as a style attribute.
   }
  kATSUStyleDropShadowColorOptionTag = 298;

  {
   * This is just for convenience. It is the upper limit of the style
   * tags.
   }
  kATSUMaxStyleTag              = 299;

  {
   * This tag is obsolete. Please use kATSULangRegionTag instead. This
   * is the maximum Apple ATSUI reserved tag value.  Client defined
   * tags must be larger.
   }
  kATSULanguageTag              = 264;
  kATSUMaxATSUITagValue         = 65535;


{
 *  ATSUAttributeValuePtr
 *  
 *  Summary:
 *    Used to provide generic access for storage of attribute values,
 *    which vary in size.
 }
type
	ATSUAttributeValuePtr = Ptr;
	ConstATSUAttributeValuePtr = Ptr;
	ATSUAttributeValuePtrPtr = ^ATSUAttributeValuePtr;

{
 *  ATSUAttributeInfo
 *  
 *  Discussion:
 *    ATSUAttributeInfo is used to provide a tag/size pairing. This
 *    makes it possible to provide the client information about all the
 *    attributes for a given range of text.  This structure is only
 *    used to return to the client information about a complete set of
 *    attributes.  An array of ATSUAttributeInfos is passed as a
 *    parameter so that the client can find out what attributes are set
 *    and what their individual sizes are; with that information, they
 *    can then query about the values of the attributes they're
 *    interested in. Because arrays of ATSUAttributeInfos are used as
 *    parameters to functions, they have to be of a fixed size, hence
 *    the value is not included in the structure.
 }
type
	ATSUAttributeInfo = record
		fTag: ATSUAttributeTag;
		fValueSize: ByteCount;
	end;
	ATSUAttributeInfoPtr = ^ATSUAttributeInfo;

{
 *  ATSUCaret
 *  
 *  Discussion:
 *    Contains the complete information needed to render a caret.  fX
 *    and fY is the position of one of the caret's ends relative to the
 *    origin position of the line the caret belongs. fDeltaX and
 *    fDeltaY is the position of the caret's other end. Hence, to draw
 *    a caret, simply call MoveTo(fX, fY) followed by LineTo(fDeltaX,
 *    fDeltaY) or equivalent.  The ATSUCaret will contain the positions
 *    needed to draw carets on angled lines and reflect angled carets
 *    and leading/trailing split caret appearances.
 }
type
	ATSUCaret = record
		fX: Fixed;
		fY: Fixed;
		fDeltaX: Fixed;
		fDeltaY: Fixed;
	end;
	ATSUCaretPtr = ^ATSUCaret;

{
 *  ATSUCursorMovementType
 *  
 *  Discussion:
 *    Used to indicate how much to move the cursor when using the ATSUI
 *    cusor movement routines. Note that kATSUByCharacterCluster is
 *    only available in Mac OS X and in CarbonLib versions 1.3 and
 *    later.
 }
type ATSUCursorMovementType = UInt16;
const

  {
   * Cursor movement based on individual characters. The cursor will
   * step through individual characters within ligatures.
   }
  kATSUByCharacter              = 0;

  {
   * Like kATSUByCharacter, but the cursor will treat ligatures as
   * single entities.
   }
  kATSUByTypographicCluster     = 1;

  {
   * Cursor movement by whole words.
   }
  kATSUByWord                   = 2;

  {
   * Cursor movement by clusters based on characters only.
   }
  kATSUByCharacterCluster       = 3;

  {
   * Obsolete name for kATSUByTypographicCluster; do not use.
   }
  kATSUByCluster                = 1;


{
 *  ATSULineTruncation
 *  
 *  Summary:
 *    Constants used with the kATSULineTruncationTag layout and line
 *    control.
 *  
 *  Discussion:
 *    The constants kATSUTruncateNone, kATSUTruncateStart,
 *    kATSUTruncateEnd, and kATSUTruncateMiddle represent different
 *    places in the text where glyphs should be replaced with an
 *    elipsis should the text not fit within the width set by the
 *    kATSULineWidthTag line and layout control. The constant
 *    kATSUTruncFeatNoSquishing is special and can be bitwise OR'd with
 *    any of the other constants. It indicates that ATSUI should not
 *    perform negative justification to make the text fit. This can be
 *    desirable for situations such as live resize, to prevent the text
 *    from "wiggling".
 }
type ATSULineTruncation = UInt32;
const
  kATSUTruncateNone             = 0;
  kATSUTruncateStart            = 1;
  kATSUTruncateEnd              = 2;
  kATSUTruncateMiddle           = 3;
  kATSUTruncateSpecificationMask = $00000007;
  kATSUTruncFeatNoSquishing     = $00000008;


{
 *  ATSUStyleLineCountType
 *  
 *  Discussion:
 *    ATSUStyleLineCountType is used to designate how many lines will
 *    be drawn for a given style type.  Currently only the underline
 *    and strikethrough styles support this type.
 }
type ATSUStyleLineCountType = UInt16;
const
  kATSUStyleSingleLineCount     = 1;
  kATSUStyleDoubleLineCount     = 2;


{
 *  ATSUVerticalCharacterType
 *  
 *  Discussion:
 *    Use these constants along with the kATSUVerticalCharacterTag
 *    layout control to determine whether the vertical or horizontal
 *    forms of glyphs should be used. Note that this is independent of
 *    line rotation.
 }
type ATSUVerticalCharacterType = UInt16;
const
  kATSUStronglyHorizontal       = 0;
  kATSUStronglyVertical         = 1;


{
 *  ATSUStyleComparison
 *  
 *  Discussion:
 *    ATSUStyleComparison is an enumeration with four values, and is
 *    used by ATSUCompareStyles() to indicate if the first style
 *    parameter contains as a proper subset, is equal to, or is
 *    contained by the second style parameter.
 }
type ATSUStyleComparison = UInt16;
const
  kATSUStyleUnequal             = 0;
  kATSUStyleContains            = 1;
  kATSUStyleEquals              = 2;
  kATSUStyleContainedBy         = 3;


{
 *  ATSUFontFallbackMethod
 *  
 *  Discussion:
 *    ATSUFontFallbackMethod type defines the method by which ATSUI
 *    will try to find an appropriate font for a character if the
 *    assigned font does not contain the needed glyph(s) to represent
 *    it.  This affects ATSUMatchFontsToText and font selection during
 *    layout and drawing when ATSUSetTransientFontMatching is set ON.
 }
type ATSUFontFallbackMethod = UInt16;
const

  {
   * When this constant is specified, all fonts on the system are
   * searched for substitute glyphs.
   }
  kATSUDefaultFontFallbacks     = 0;

  {
   * This constant specifies that only the special last resort font be
   * used for substitute glyphs.
   }
  kATSULastResortOnlyFallback   = 1;

  {
   * This constant specifies that a font list you provide should be
   * sequentially searched for substitute glyphs before the ATSUI
   * searches through all available fonts on the system. You specify
   * this list through the iFonts parameter to the
   * ATSUSetObjFontFallbacks function.
   }
  kATSUSequentialFallbacksPreferred = 2;

  {
   * This constants specifies that only the font list you provide
   * should be sequentially searched for substitute glyphs. All other
   * fonts on the system are ignored, except for the special last
   * resort font. You specify the list of fonts you want ATSUI to use
   * by passing it to the iFonts parameter of the
   * ATSUSetObjFontFallbacks function.
   }
  kATSUSequentialFallbacksExclusive = 3;


{
 *  ATSUTabType
 *  
 *  Discussion:
 *    ATSUTabType type defines the characteristic of ATSUI tabs. A Left
 *    tab type specifies that the left side of affected text is to be
 *    maintained flush against the tab stop.  A Right tab type
 *    specifies that the right side of affected text is to be
 *    maintained flush against the tab stop.  A Center tab type
 *    specifies that the affected text centered about the tab stop. A
 *    Decimal tab type specifies that the affected text will be aligned
 *    such that the decimal character will by flush against the tab
 *    stop.  The default decimal character is defined in System
 *    Preferences.  A different decimal character can be defined by
 *    using the ATSUAttributeTag kATSULineDecimalTabCharacterTag.
 }

type ATSUTabType = UInt16;
const
  kATSULeftTab                  = 0;
  kATSUCenterTab                = 1;
  kATSURightTab                 = 2;
  kATSUDecimalTab               = 3;
  kATSUNumberTabTypes           = 4;


{
 *  ATSUTab
 *  
 *  Discussion:
 *    ATSUTab specifies the position and type of tab stop to be applied
 *    to a ATSUTextLayout set through the ATSUI routine ATSUSetTabArray
 *    and returned through ATSUGetTabArray.
 }
type 
	ATSUTab = record
  	tabPosition: ATSUTextMeasurement;
	  tabType: ATSUTabType;
	end;
	ATSUTabPtr = ^ATSUTab;

{
 *  ATSURGBAlphaColor
 *  
 *  Discussion:
 *    Use this structure with the kATSURGBAlphaColorTag attribute to
 *    specify color for your text in an ATSUStyle. All values range
 *    from 0.0 to 1.0.
 }
type
	ATSURGBAlphaColor = record
		red: Float32;
		green: Float32;
		blue: Float32;
		alpha: Float32;
	end;
	ATSURGBAlphaColorPtr = ^ATSURGBAlphaColor;

{
 *  GlyphCollection
 *  
 *  Discussion:
 *    GlyphCollection types represent the specific character
 *    collection.  If the value is zero, kGlyphCollectionGID, then this
 *    indicates that the glyph value represents the actual glyphID of a
 *    specific font. Adobe collections are based on CID, rather than
 *    glyph ID.
 }

type GlyphCollection = UInt16;
const
  kGlyphCollectionGID           = 0;
  kGlyphCollectionAdobeCNS1     = 1;
  kGlyphCollectionAdobeGB1      = 2;
  kGlyphCollectionAdobeJapan1   = 3;
  kGlyphCollectionAdobeJapan2   = 4;
  kGlyphCollectionAdobeKorea1   = 5;
  kGlyphCollectionUnspecified   = $FF;


{
 *  ATSUGlyphSelector
 *  
 *  Discussion:
 *    ATSUGlyphSelector can direct ATSUI to use a specific glyph
 *    instead of the one that ATSUI normally derives.  The glyph can be
 *    specified either as a glyphID (specific to the font used) or CID
 *    from a specfic collection defined by the collection entry.
 }
type
	ATSUGlyphSelector = record

  {
   * A glyph collection constant. See the definition of GlyphCollection
   * for possible values for this field.
   }
		collection: GlyphCollection;

  {
   * The glyph ID of the glyph (when collection is
   * kGlyphCollectionGID). For Adobe glyph collections, this value
   * represents a CID
   }
		glyphID: GlyphID_GAP_Private_field_type_fix;
	end;
	ATSUGlyphSelectorPtr = ^ATSUGlyphSelector;

type ATSUCustomAllocFunc = function( refCon: UnivPtr; howMuch: ByteCount ): Ptr;
type ATSUCustomFreeFunc = procedure( refCon: UnivPtr; doomedBlock: UnivPtr );
type ATSUCustomGrowFunc = function( refCon: UnivPtr; oldBlock: UnivPtr; oldSize: ByteCount; newSize: ByteCount ): Ptr;

{
 *  ATSUMemoryCallbacks
 *  
 *  Discussion:
 *    ATSUMemoryCallbacks is a union struct that allows the ATSUI
 *    client to specify a specific heap for ATSUI use or allocation
 *    callbacks of which ATSUI is to use each time ATSUI performs a
 *    memory operation (alloc, grow, free).
 }
type
	ATSUMemoryCallbacks = record
		case SInt16 of
			1: (
				callbacks: record
					Alloc: ATSUCustomAllocFunc;
					Free: ATSUCustomFreeFunc;
					Grow: ATSUCustomGrowFunc;
					memoryRefCon: Ptr;
				end;
			);
			2: (
				heapToUse: THz;
			);
	end;
	ATSUMemoryCallbacksPtr = ^ATSUMemoryCallbacks;

{
 *  ATSUHeapSpec
 *  
 *  Discussion:
 *    ATSUHeapSpec provides the ATSUI client a means of specifying the
 *    heap from which ATSUI should allocate its dynamic memory or
 *    specifying that ATSUI should use the memory callback provided by
 *    the client.
 }
type ATSUHeapSpec = UInt16;
const
  kATSUUseCurrentHeap           = 0;
  kATSUUseAppHeap               = 1;
  kATSUUseSpecificHeap          = 2;
  kATSUUseCallbacks             = 3;


{
 *  ATSUMemorySetting
 *  
 *  Discussion:
 *    ATSUMemorySetting is used to store the results from a
 *    ATSUSetMemoryAlloc or a ATSUGetCurrentMemorySetting call.  It can
 *    also be used to change the current ATSUMemorySetting by passing
 *    it into the ATSUSetCurrentMemorySetting call.
 }
type
	ATSUMemorySetting    = ^SInt32; { an opaque 32-bit type }


{
 *  ATSUGlyphInfo
 *  
 *  Summary:
 *    Structure returned by ATSUGetGlyphInfo
 *  
 *  Discussion:
 *    ATSUGetGlyphInfo will return an array of these structs, one for
 *    each glyph in the specified range. You can then make changes to
 *    the data before drawing it with ATSUDrawGlyphInfo. These
 *    functions are no longer recommended; see ATSUnicodeDirectAccess.h
 *    for replacement functions.
 }
type
	ATSUGlyphInfo = record
		glyphID: GlyphID_GAP_Private_field_type_fix;
		reserved: UInt16;
		layoutFlags: UInt32;
		charIndex: UniCharArrayOffset;
		style: ATSUStyle;
		deltaY: Float32;
		idealX: Float32;
		screenX: SInt16;
		caretX: SInt16;
	end;
	ATSUGlyphInfoPtr = ^ATSUGlyphInfo;

{
 *  ATSUGlyphInfoArray
 *  
 *  Summary:
 *    Structure returned by ATSUGetGlyphInfo
 *  
 *  Discussion:
 *    This data structure is returned by ATSUGetGlyphInfo. layout is
 *    the same layout you pass in to ATSUGetGlyphInfo, numGlyphs is the
 *    number of glyphs stored in the array glyphs. See the definition
 *    of ATSUGlyphInfo for more information about the data structures
 *    contained in the glyphs array. The ATSUGetGlyphInfo function is
 *    no longer recommended; see ATSUnicodeDirectAccess.h for
 *    replacement functions.
 }
type
	ATSUGlyphInfoArray = record
		layout: ATSUTextLayout;
		numGlyphs: ItemCount;
  	glyphs: array[0..0] of ATSUGlyphInfo;
	end;
	ATSUGlyphInfoArrayPtr = ^ATSUGlyphInfoArray;
{*******************************************************************************}
{  ATSUI highlighting method constants and typedefs                             }
{*******************************************************************************}

{
 *  ATSUHighlightMethod
 *  
 *  Discussion:
 *    Use the constants with the function ATSUSetHighlightingMethod to
 *    determine the method of highlighting to use. kInvertHighlighting
 *    will cause ATSUI to perform a simple color inversion on the area
 *    around the text. Although this method requires the least work, it
 *    does not produce the best visual results. kRedrawHighlighting
 *    will cause ATSUI to redraw the text whenever highlighting or
 *    unhighlighting it. This method produces the best visual results,
 *    but it does require you to specify a way for ATSUI to redraw the
 *    background behind the text after an unhighlight operation. See
 *    the definitions of ATSUUnhighlightData, ATSUBackgroundData,
 *    ATSUBackgroundDataType, and RedrawBackgroundProcPtr for more
 *    information.
 }
type ATSUHighlightMethod = UInt32;
const
  kInvertHighlighting           = 0;
  kRedrawHighlighting           = 1;


{
 *  ATSUBackgroundDataType
 *  
 *  Discussion:
 *    Use these constants for the dataType field in the
 *    ATSUUnhighlightData structure. kATSUBackgroundColor refers to a
 *    solid color background, while kATSUBackgroundCallback refers to a
 *    redrawing callback function. Note that if you specify
 *    kATSUBackgroundCallback, you must provide a callback function.
 }
type ATSUBackgroundDataType = UInt32;
const
  kATSUBackgroundColor          = 0;
  kATSUBackgroundCallback       = 1;


{
 *  ATSUBackgroundColor
 *  
 *  Discussion:
 *    A background color used by ATSUI to redraw the background after a
 *    call to ATSUUnhighlight text when the highlighting method is set
 *    to kRedrawHighlighting. See the definitions of ATSUBackgroundData
 *    and ATSUUnhighlightData for more information.
 }

type ATSUBackgroundColor = ATSURGBAlphaColor;

{
 *  RedrawBackgroundProcPtr
 *  
 *  Discussion:
 *    RedrawBackgroundProcPtr is a pointer to a client-supplied
 *    callback function (e.g. MyRedrawBackgroundProc) for redrawing
 *    complex backgrounds (and optionally the text as well) that can be
 *    called by ATSUI for highlighting if the client has called
 *    ATSUSetHighlightingMethod with kRedrawHighlighting for the
 *    iMethod parameter. In order for ATSUI to call the client
 *    function, the client must (1) pass a pointer to the client
 *    function to NewRedrawBackgroundUPP() in order to obtain a
 *    RedrawBackgroundUPP, and (2) pass the RedrawBackgroundUPP in the
 *    unhighlightData.backgroundUPP field of the iUnhighlightData
 *    parameter for the ATSUSetHighlightingMethod call. When finished,
 *    the client should call DisposeRedrawBackgroundUPP with the
 *    RedrawBackgroundUPP.
 *  
 *  Parameters:
 *    
 *    iLayout:
 *      The layout to which the highlighting is being applied. The
 *      client function can use this to redraw the text.
 *    
 *    iTextOffset:
 *      The offset of the text that is being highlighted; can be used
 *      by the client function to redraaw the text.
 *    
 *    iTextLength:
 *      The length of the text that is being highlighted; can be used
 *      by the client function to redraaw the text.
 *    
 *    iUnhighlightArea:
 *      An array of ATSTrapezoids that describes the highlight area.
 *      The ATSTrapezoid array is ALWAYS in QD coordinates.
 *    
 *    iTrapezoidCount:
 *      The count of ATSTrapezoids in iUnhighlightArea.
 *  
 *  Result:
 *    A Boolean result indicating whether ATSUI should redraw the text.
 *    If the client function redraws the text, it should return false,
 *    otherwise it should return true to have ATSUI redraw any text
 *    that needs to be redrawn.
 }
type RedrawBackgroundProcPtr = function( iLayout: ATSUTextLayout; iTextOffset: UniCharArrayOffset; iTextLength: UniCharCount; iUnhighlightArea: ATSTrapezoidPtr; iTrapezoidCount: ItemCount ): Boolean;
// typedef STACK_UPP_TYPE(RedrawBackgroundProcPtr)                 RedrawBackgroundUPP;
// Beats me what this translates to.  If someone finds out they can tell me and we'll update it
type RedrawBackgroundUPP = Ptr;

{
 *  NewRedrawBackgroundUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.0 and later
 *    Non-Carbon CFM:   not available
 }
// AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER
function NewRedrawBackgroundUPP( userRoutine: RedrawBackgroundProcPtr ): RedrawBackgroundUPP; external name '_NewRedrawBackgroundUPP';

{
 *  DisposeRedrawBackgroundUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.0 and later
 *    Non-Carbon CFM:   not available
 }
// AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER
procedure DisposeRedrawBackgroundUPP( userUPP: RedrawBackgroundUPP ); external name '_DisposeRedrawBackgroundUPP';

{
 *  InvokeRedrawBackgroundUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in ApplicationServices.framework
 *    CarbonLib:        not available in CarbonLib 1.x, is available on Mac OS X version 10.0 and later
 *    Non-Carbon CFM:   not available
 }
// AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER
function InvokeRedrawBackgroundUPP( iLayout: ATSUTextLayout; iTextOffset: UniCharArrayOffset; iTextLength: UniCharCount; iUnhighlightArea: ATSTrapezoidPtr; iTrapezoidCount: ItemCount; userUPP: RedrawBackgroundUPP ): Boolean; external name '_InvokeRedrawBackgroundUPP';


{
 *  ATSUBackgroundData
 *  
 *  Summary:
 *    Data describing one of two methods for ATSUI to unhighlight text.
 *  
 *  Discussion:
 *    When you call ATSUUnhighlightText and the highlighting method
 *    used is kRedrawHighlighting, ATSUI must redraw the text,
 *    including the background, when unhighlighting. The two ways of
 *    doing this are by telling ATSUI to (1) use a solid color to
 *    repaint the background (2) use a callback function to repaint the
 *    background. This union provides that information to ATSUI. See
 *    the definitions of ATSUUnhighlightData, RedrawBackgroundProcPtr,
 *    and ATSUSetHighlightingMethod for more information.
 }
type
	ATSUBackgroundData = record
		case SInt16 of
			1: (
				{
				 * Specifies a color for ATSUI to repaint the background.
				 }
					backgroundColor: ATSUBackgroundColor;
			);
			2: (
				{
				 * Specifies a Universal Procedure Pointer for ATSUI to call to
				 * redraw the background.
				 }
					backgroundUPP: RedrawBackgroundUPP;
			);
	end;
	ATSUBackgroundDataPtr = ^ATSUBackgroundData;

{
 *  ATSUUnhighlightData
 *  
 *  Summary:
 *    Struct for defining a method for ATSUI to unhighlight text.
 *  
 *  Discussion:
 *    There are two methods of highlighting available on Mac OS X:
 *    invert and redraw. For the invert method, no unhighlight method
 *    needs to be specified. ATSUI will simply higlight text by
 *    performing a color inversion on the area surrounding the test.
 *    However, for best results, the redraw method is perferred. With
 *    this method, ATSUI will redraw text with a new background when
 *    highlighting, and redraw it again when unhighlighting. When using
 *    the redraw method, ATSUI needs to know how to restore the
 *    backround when unhighlighting text. That is where the unhighlight
 *    data comes in. This struct tells ATSUI how to restore the
 *    background after a highlight. There are two methods for
 *    specifying this information to ATSUI. One is by specifying a
 *    solid color, the other by providing a callback for redrawing part
 *    of the background.
 }
type
	ATSUUnhighlightData = record

  {
   * Determines which method to use for restoring the background after
   * a highlight; solid color (kATSUBackgroundColor), or drawing
   * callback (kATSUBackgroundCallback). See also the definition of
   * ATSUBackgroundDataType.
   }
		dataType: ATSUBackgroundDataType;

  {
   * This union provides the actual data for ATSUI to use when
   * redrawing the background. See the definition of ATSUBackgroundData
   * for more information.
   }
		unhighlightData: ATSUBackgroundData;
	end;
	ATSUUnhighlightDataPtr = ^ATSUUnhighlightData;
{******************************************************************************}
{ Other ATSUI constants                                                        }
{******************************************************************************}

{
 *  Summary:
 *    Line direction types
 *  
 *  Discussion:
 *    These constants are used with the kATSULineDirectionTag control
 *    to determine overall line direction.
 }
const
  {
   * Imposes left-to-right or top-to-bottom dominant direction.
   }
  kATSULeftToRightBaseDirection = 0;

  {
   * Impose right-to-left or bottom-to-top dominant direction.
   }
  kATSURightToLeftBaseDirection = 1;

const
	kATSUStartAlignment    = Fract($00000000);
	kATSUEndAlignment      = Fract($40000000);
	kATSUCenterAlignment   = Fract($20000000);
	kATSUNoJustification   = Fract($00000000);
	kATSUFullJustification = Fract($40000000);

{
 *  Summary:
 *    This constant will be returned from ATSUFindFontFromName if no
 *    valid font can be found. If you pass this constant to
 *    ATSUSetAttributes, it will produce an error.
 }
const
  kATSUInvalidFontID            = 0;


{
 *  Summary:
 *    Pass this constant to line breaking functions (i.e.,
 *    ATSUBreakLine, ATSUBatchBreakLines) if you have already set a
 *    line width as a layout control via the kATSULineWidthTag
 *    attribute.
 }
const
  kATSUUseLineControlWidth      = $7FFFFFFF;


{
 *  Summary:
 *    Pass this constant to the iSelector parameter of the
 *    ATSUGetFontFeatureNameCode function if you wish to obtain the
 *    name code for a feature type rather than a feature selector.
 }
const
  kATSUNoSelector               = $0000FFFF;


{
 *  Summary:
 *    Text buffer convenience constants.
 *  
 *  Discussion:
 *    These constants refer to the beginning and end of a text buffer.
 *    Functions which accept these constants are marked below. Do not
 *    pass these constants to functions which do not explicity state
 *    they will accept them.
 }
const

  {
   * Refers to the beginning of a text buffer.
   }
  kATSUFromTextBeginning        = $FFFFFFFF;

  {
   * Refers to the end of a text buffer.
   }
  kATSUToTextEnd                = $FFFFFFFF;

  {
   * Used for bidi cursor movement between paragraphs.
   }
  kATSUFromPreviousLayout       = $FFFFFFFE;

  {
   * Used for bidi cursor movement between paragraphs.
   }
  kATSUFromFollowingLayout      = $FFFFFFFD;


{
 *  Summary:
 *    Other convenience constants.
 }
const

  {
   * Pass this constant to functions that require a set of coordinates
   * (i.e., ATSUDrawText, ATSUHighlightText) if you want ATSUI to use
   * the current Quickdraw graphics port pen location.
   }
  kATSUUseGrafPortPenLoc        = $FFFFFFFF;

  {
   * Pass this constant to functions such as ATSUClearAttributes and
   * ATSUClearLayoutControls if you wish to clear all settings instead
   * of a specific array of settings.
   }
  kATSUClearAll                 = $FFFFFFFF;

end.
