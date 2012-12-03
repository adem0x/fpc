{  Initial Pascal Translation:  Jonas Maebe, <jonas@freepascal.org>, October 2012 }
{
    Modified for use with Free Pascal
    Version 308
    Please report any bugs to <gpc@microbizz.nl>
}

{$ifc not defined MACOSALLINCLUDE or not MACOSALLINCLUDE}
{$mode macpas}
{$packenum 1}
{$macro on}
{$inline on}
{$calling mwpascal}

unit CGImageMetadata;
interface
{$setc UNIVERSAL_INTERFACES_VERSION := $0400}
{$setc GAP_INTERFACES_VERSION := $0308}

{$ifc not defined USE_CFSTR_CONSTANT_MACROS}
    {$setc USE_CFSTR_CONSTANT_MACROS := TRUE}
{$endc}

{$ifc defined CPUPOWERPC and defined CPUI386}
	{$error Conflicting initial definitions for CPUPOWERPC and CPUI386}
{$endc}
{$ifc defined FPC_BIG_ENDIAN and defined FPC_LITTLE_ENDIAN}
	{$error Conflicting initial definitions for FPC_BIG_ENDIAN and FPC_LITTLE_ENDIAN}
{$endc}

{$ifc not defined __ppc__ and defined CPUPOWERPC32}
	{$setc __ppc__ := 1}
{$elsec}
	{$setc __ppc__ := 0}
{$endc}
{$ifc not defined __ppc64__ and defined CPUPOWERPC64}
	{$setc __ppc64__ := 1}
{$elsec}
	{$setc __ppc64__ := 0}
{$endc}
{$ifc not defined __i386__ and defined CPUI386}
	{$setc __i386__ := 1}
{$elsec}
	{$setc __i386__ := 0}
{$endc}
{$ifc not defined __x86_64__ and defined CPUX86_64}
	{$setc __x86_64__ := 1}
{$elsec}
	{$setc __x86_64__ := 0}
{$endc}
{$ifc not defined __arm__ and defined CPUARM}
	{$setc __arm__ := 1}
{$elsec}
	{$setc __arm__ := 0}
{$endc}

{$ifc defined cpu64}
  {$setc __LP64__ := 1}
{$elsec}
  {$setc __LP64__ := 0}
{$endc}


{$ifc defined __ppc__ and __ppc__ and defined __i386__ and __i386__}
	{$error Conflicting definitions for __ppc__ and __i386__}
{$endc}

{$ifc defined __ppc__ and __ppc__}
	{$setc TARGET_CPU_PPC := TRUE}
	{$setc TARGET_CPU_PPC64 := FALSE}
	{$setc TARGET_CPU_X86 := FALSE}
	{$setc TARGET_CPU_X86_64 := FALSE}
	{$setc TARGET_CPU_ARM := FALSE}
	{$setc TARGET_OS_MAC := TRUE}
	{$setc TARGET_OS_IPHONE := FALSE}
	{$setc TARGET_IPHONE_SIMULATOR := FALSE}
	{$setc TARGET_OS_EMBEDDED := FALSE}
{$elifc defined __ppc64__ and __ppc64__}
	{$setc TARGET_CPU_PPC := FALSE}
	{$setc TARGET_CPU_PPC64 := TRUE}
	{$setc TARGET_CPU_X86 := FALSE}
	{$setc TARGET_CPU_X86_64 := FALSE}
	{$setc TARGET_CPU_ARM := FALSE}
	{$setc TARGET_OS_MAC := TRUE}
	{$setc TARGET_OS_IPHONE := FALSE}
	{$setc TARGET_IPHONE_SIMULATOR := FALSE}
	{$setc TARGET_OS_EMBEDDED := FALSE}
{$elifc defined __i386__ and __i386__}
	{$setc TARGET_CPU_PPC := FALSE}
	{$setc TARGET_CPU_PPC64 := FALSE}
	{$setc TARGET_CPU_X86 := TRUE}
	{$setc TARGET_CPU_X86_64 := FALSE}
	{$setc TARGET_CPU_ARM := FALSE}
{$ifc defined(iphonesim)}
 	{$setc TARGET_OS_MAC := FALSE}
	{$setc TARGET_OS_IPHONE := TRUE}
	{$setc TARGET_IPHONE_SIMULATOR := TRUE}
{$elsec}
	{$setc TARGET_OS_MAC := TRUE}
	{$setc TARGET_OS_IPHONE := FALSE}
	{$setc TARGET_IPHONE_SIMULATOR := FALSE}
{$endc}
	{$setc TARGET_OS_EMBEDDED := FALSE}
{$elifc defined __x86_64__ and __x86_64__}
	{$setc TARGET_CPU_PPC := FALSE}
	{$setc TARGET_CPU_PPC64 := FALSE}
	{$setc TARGET_CPU_X86 := FALSE}
	{$setc TARGET_CPU_X86_64 := TRUE}
	{$setc TARGET_CPU_ARM := FALSE}
	{$setc TARGET_OS_MAC := TRUE}
	{$setc TARGET_OS_IPHONE := FALSE}
	{$setc TARGET_IPHONE_SIMULATOR := FALSE}
	{$setc TARGET_OS_EMBEDDED := FALSE}
{$elifc defined __arm__ and __arm__}
	{$setc TARGET_CPU_PPC := FALSE}
	{$setc TARGET_CPU_PPC64 := FALSE}
	{$setc TARGET_CPU_X86 := FALSE}
	{$setc TARGET_CPU_X86_64 := FALSE}
	{$setc TARGET_CPU_ARM := TRUE}
	{ will require compiler define when/if other Apple devices with ARM cpus ship }
	{$setc TARGET_OS_MAC := FALSE}
	{$setc TARGET_OS_IPHONE := TRUE}
	{$setc TARGET_IPHONE_SIMULATOR := FALSE}
	{$setc TARGET_OS_EMBEDDED := TRUE}
{$elsec}
	{$error __ppc__ nor __ppc64__ nor __i386__ nor __x86_64__ nor __arm__ is defined.}
{$endc}

{$ifc defined __LP64__ and __LP64__ }
  {$setc TARGET_CPU_64 := TRUE}
{$elsec}
  {$setc TARGET_CPU_64 := FALSE}
{$endc}

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
{$setc TARGET_OS_UNIX := FALSE}
{$setc TARGET_OS_WIN32 := FALSE}
{$setc TARGET_RT_MAC_68881 := FALSE}
{$setc TARGET_RT_MAC_CFM := FALSE}
{$setc TARGET_RT_MAC_MACHO := TRUE}
{$setc TYPED_FUNCTION_POINTERS := TRUE}
{$setc TYPE_BOOL := FALSE}
{$setc TYPE_EXTENDED := FALSE}
{$setc TYPE_LONGLONG := TRUE}
uses MacTypes,CFBase,CFArray,CFData,CFDictionary,CFError;
{$endc} {not MACOSALLINCLUDE}

{$ALIGN POWER}

{$ifc TARGET_OS_MAC}

// *****************************************************************************
// CGImageMetadata.h
// *****************************************************************************


{!
 * @header CGImageMetadata.h
 * @abstract Implements access to image metadata
 * @description CGImageMetadata APIs allow clients to view and modify metadata
 * for popular image formats. ImageIO supports the EXIF, IPTC, and XMP
 * metadata specifications. Please refer to CGImageSource.h for functions to 
 * read metadata from a CGImageSource, and CGImageDestination.h for functions to
 * write metadata to a CGImageDestination. CGImageDestinationCopyImageSource can
 * be used to modify metadata without recompressing the image.
 *
 * Developers can enable additional debugging information by setting the
 * environment variable IIO_DEBUG_METADATA=1.
 * @related CGImageSource.h
 * @related CGImageDestination.h
 * @ignorefuncmacro IMAGEIO_AVAILABLE_STARTING
 * @ignore extern
 * @unsorted
 }

{!
 * @typedef CGImageMetadataRef 
 * @abstract an immutable container for CGImageMetadataTags
 }
type
	CGImageMetadataRef = ^OpaqueCGImageMetadata; { an opaque type }
	OpaqueCGImageMetadata = record end;

//{! @functiongroup Creating and identifying CGImageMetadata containers }
{!
 * @function CGImageMetadataGetTypeID
 * @abstract Gets the type identifier for the CGImageMetadata opaque type
 * @return the type identifier for the CGImageMetadata opaque type
 }
function CGImageMetadataGetTypeID: CFTypeID; external name '_CGImageMetadataGetTypeID';

{!
 * @typedef CGMutableImageMetadataRef
 * @abstract a mutable container for CGImageMetadataTags
 * @discussion A CGMutableImageMetadataRef can be used in any function that
 * accepts a CGImageMetadataRef.
 }
type
	CGMutableImageMetadataRef = ^OpaqueCGImageMetadata;

{!
 * @function CGImageMetadataCreateMutable
 * @abstract Creates an empty CGMutableImageMetadataRef
 }
function CGImageMetadataCreateMutable: CGMutableImageMetadataRef; external name '_CGImageMetadataCreateMutable';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

{!
 * @function CGImageMetadataCreateMutableCopy
 * @abstract Creates a deep mutable copy of another CGImageMetadataRef
 * @discussion Before modifying an immutable CGImageMetadataRef (such as metadata
 * from CGImageSourceCopyMetadataAtIndex) you must first make a copy.
 * This function makes a deep copy of all CGImageMetadataTags and their values.
 }
function CGImageMetadataCreateMutableCopy( metadata: CGImageMetadataRef ): CGMutableImageMetadataRef; external name '_CGImageMetadataCreateMutableCopy';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

// ****************************************************************************
// CGImageMetadataTag - an individual metadata tag, encapsulating an EXIF tag, 
// IPTC tag, or XMP property.
// ****************************************************************************

{!
 * @typedef CGImageMetadataTagRef
 * @abstract an individual metadata tag
 * @discussion A CGImageMetadataTag encapsulates an EXIF, IPTC, or XMP property.
 * All tags contain a namespace, prefix, name, type, and value. Please see
 * @link CGImageMetadataTagCreate @/link for more details.
 }
type
	CGImageMetadataTagRef = ^CGImageMetadataTag; { an opaque type }
	CGImageMetadataTag = record end;

//{! @functiongroup Creating and identifying CGImageMetadataTags }
{!
 * @function CGImageMetadataTagGetTypeID
 * @abstract Gets the type identifier for the CGImageMetadataTag opaque type
 * @return the type identifier for the CGImageMetadataTagGetTypeID opaque type
 }
function CGImageMetadataTagGetTypeID: CFTypeID; external name '_CGImageMetadataTagGetTypeID';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)


// ****************************************************************************
// Constants for use in a CGImageMetadataTag
// ****************************************************************************

// All metadata tags must contain a namespace. Clients may use one of the 
// public namespaces defined below or create their own namespace. If a caller
// defines their own namespace, it should comply with the guidelines set forth
// by Adobe in their XMP specification at:
// http://www.adobe.com/devnet/xmp.html.
// For example: "http://ns.adobe.com/exif/1.0/". 
// The caller must also register a custom namespace using 
// CGImageMetadataRegisterNamespaceForPrefix.

// Public, common namespaces.
var kCGImageMetadataNamespaceExif: CFStringRef; external name '_kCGImageMetadataNamespaceExif'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)
var kCGImageMetadataNamespaceExifAux: CFStringRef; external name '_kCGImageMetadataNamespaceExifAux'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)
var kCGImageMetadataNamespaceDublinCore: CFStringRef; external name '_kCGImageMetadataNamespaceDublinCore'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)
var kCGImageMetadataNamespaceIPTCCore: CFStringRef; external name '_kCGImageMetadataNamespaceIPTCCore'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)
var kCGImageMetadataNamespacePhotoshop: CFStringRef; external name '_kCGImageMetadataNamespacePhotoshop'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)
var kCGImageMetadataNamespaceTIFF: CFStringRef; external name '_kCGImageMetadataNamespaceTIFF'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)
var kCGImageMetadataNamespaceXMPBasic: CFStringRef; external name '_kCGImageMetadataNamespaceXMPBasic'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)
var kCGImageMetadataNamespaceXMPRights: CFStringRef; external name '_kCGImageMetadataNamespaceXMPRights'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

// All metadata tags must contain a prefix. For the public namespaces defined
// above, no prefix is required - ImageIO will use appropriate defaults.  For 
// other namespaces a prefix is required. For example, while the exif namespace 
// is rather long ("http://ns.adobe.com/exif/1.0/"), when exported the shorter 
// string "exif" will be used to prefix all properties in the exif namespace 
// (example - "exif:Flash").

// Public, common prefixes.
var kCGImageMetadataPrefixExif: CFStringRef; external name '_kCGImageMetadataPrefixExif'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)
var kCGImageMetadataPrefixExifAux: CFStringRef; external name '_kCGImageMetadataPrefixExifAux'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)
var kCGImageMetadataPrefixDublinCore: CFStringRef; external name '_kCGImageMetadataPrefixDublinCore'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)
var kCGImageMetadataPrefixIPTCCore: CFStringRef; external name '_kCGImageMetadataPrefixIPTCCore'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)
var kCGImageMetadataPrefixPhotoshop: CFStringRef; external name '_kCGImageMetadataPrefixPhotoshop'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)
var kCGImageMetadataPrefixTIFF: CFStringRef; external name '_kCGImageMetadataPrefixTIFF'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)
var kCGImageMetadataPrefixXMPBasic: CFStringRef; external name '_kCGImageMetadataPrefixXMPBasic'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)
var kCGImageMetadataPrefixXMPRights: CFStringRef; external name '_kCGImageMetadataPrefixXMPRights'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

// Metadata value type constants.
{!
 * @typedef CGImageMetadataType
 * @abstract The XMP type for a CGImageMetadataTag
 * @discussion CGImageMetadataType defines a list of constants used to indicate
 * the type for a CGImageMetadataTag. If you are reading metadata, use the type 
 * to determine how to interpret the CGImageMetadataTag's value. If you are 
 * creating a CGImageMetadataTag, use the type to specify how the tag 
 * should be serialized in XMP. String types have CFStringRef values, array 
 * types have CFArray values, and structure types have CFDictionary values.
 * @const kCGImageMetadataTypeDefault The type will be interpretted based on the
 * CFType of the tag's value. This is only used when creating a new 
 * CGImageMetadataTag - no existing tags should have this value. CFString 
 * defaults to kCGImageMetadataTypeString, CFArray defaults to 
 * kCGImageMetadataTypeArrayOrdered, and CFDictionary defaults to
 * kCGImageMetadataTypeStructure.
 * @const kCGImageMetadataTypeString A string value. CFNumber and CFBoolean 
 * values will be converted to a string.
 * @const kCGImageMetadataTypeArrayUnordered An array where order does not matter.
 * Serialized in XMP as <rdf:Bag>.
 * @const kCGImageMetadataTypeArrayOrdered An array where order is preserved.
 * Serialized in XMP as <rdf:Seq>.
 * @const kCGImageMetadataTypeAlternateArray An ordered array where all elements
 * are alternates for the same value. Serialized in XMP as <rdf:Alt>.
 * @const kCGImageMetadataTypeAlternateText A special case of an alternate array
 * where all elements are different localized strings for the same value. 
 * Serialized in XMP as an alternate array of strings with xml:lang qualifiers.
 * @const kCGImageMetadataTypeStructure A collection of keys and values. Unlike
 * array elements, fields of a structure may belong to different namespaces.
 }
const
    kCGImageMetadataTypeInvalid = -1;
    kCGImageMetadataTypeDefault = 0;
    kCGImageMetadataTypeString = 1;
    kCGImageMetadataTypeArrayUnordered = 2;
    kCGImageMetadataTypeArrayOrdered = 3;
    kCGImageMetadataTypeAlternateArray = 4;
    kCGImageMetadataTypeAlternateText = 5;
    kCGImageMetadataTypeStructure = 6;
type
  CGImageMetadataType = UInt32;

// ****************************************************************************
// Creating a CGImageMetadataTag
// ****************************************************************************
{!
 * @function CGImageMetadataTagCreate
 * @abstract Creates a new CGImageMetadataTag
 * @param xmlns The namespace for the tag. The value can be a common XMP namespace
 * defined above, such as kCGImageMetadataNamespaceExif, or a CFString with a
 * custom namespace URI. Custom namespaces must be a valid XML namespace. By
 * convention, namespaces should end with either '/' or '#'. For example, exif
 * uses the namespace "http://ns.adobe.com/exif/1.0/".
 * @param prefix An abbreviation for the XML namespace. The value can be NULL if
 * the namespace is defined as a constant. Custom prefixes must be a valid XML
 * name. For example, the prefix used for "http://ns.adobe.com/exif/1.0/" is "exif".
 * The XMP serialization of the tag will use the prefix. Prefixes are also
 * important for path-based CGImageMetadata functions, such as 
 * @link CGImageMetadataCopyStringValueWithPath @/link or 
 * @link CGImageMetadataSetValueWithPath @/link.
 * @param name The name of the tag. It must be a valid XMP name.
 * @param type The type of the tag's value. Must be a constant from @link 
 * CGImageMetadataType @/link.
 * @param value The value of the tag. Allowable CFTypes include CFStringRef,
 * CFNumberRef, CFBooleanRef, CFArrayRef, and CFDictionaryRef. The CFType of 'value'
 * must correspond to the 'type'. The elements of a CFArray must be either a 
 * CFStringRef or CGImageMetadataTagRef. The keys of a CFDictionary must be 
 * CFStringRefs with valid XMP names. The values of a CFDictionary must be either
 * CFStringRefs or CGImageMetadataTagRefs. A shallow copy of the value is stored
 * in the tag. Therefore, modifying a mutable value after the tag is created 
 * will not affect the tag's value.
 * @result Returns a pointer to a new CGImageMetadataTag. Returns NULL if a tag
 * could not be created with the specified parameters.
 }
function CGImageMetadataTagCreate( xmlns: CFStringRef; prefix: CFStringRef; name: CFStringRef; typ: CGImageMetadataType; value: CFTypeRef ): CGImageMetadataTagRef; external name '_CGImageMetadataTagCreate';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

// ****************************************************************************
// Getting attributes of a CGImageMetadataTag
// ****************************************************************************
//{! @functiongroup Getting attributes of a CGImageMetadataTag }
{!
 * @function CGImageMetadataTagCopyNamespace 
 * @abstract Returns a copy of the tag's namespace
 }
function CGImageMetadataTagCopyNamespace( tag: CGImageMetadataTagRef ): CFStringRef; external name '_CGImageMetadataTagCopyNamespace';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

{!
 * @function CGImageMetadataTagCopyPrefix 
 * @abstract Returns a copy of the tag's prefix
 }
function CGImageMetadataTagCopyPrefix( tag: CGImageMetadataTagRef ): CFStringRef; external name '_CGImageMetadataTagCopyPrefix';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

{!
 * @function CGImageMetadataTagCopyName 
 * @abstract Returns a copy of the tag's name
 }
function CGImageMetadataTagCopyName( tag: CGImageMetadataTagRef ): CFStringRef; external name '_CGImageMetadataTagCopyName';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

{!
 * @function CGImageMetadataTagCopyValue 
 * @abstract Returns a shallow copy of the tag's value
 * @discussion This function should only be used to read the tag's value. 
 * CGImageMetadataCopyTagWithPath returns a copy of the tag (including a copy of
 * the tag's value). Therefore mutating a tag's value returned from this function
 * may not actually mutate the value in the CGImageMetadata. It is recommended 
 * to create a new tag followed by CGImageMetadataSetTagWithPath, or use 
 * CGImageMetadataSetValueWithPath to mutate a metadata value. 
 }
function CGImageMetadataTagCopyValue( tag: CGImageMetadataTagRef ): CFTypeRef; external name '_CGImageMetadataTagCopyValue';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

{!
 * @function CGImageMetadataTagGetType
 * @abstract Get the type of the CGImageMetadataTag
 * @return Returns a CGImageMetadataType constant for the CGImageMetadataTag.
 * This is primarily used to determine how to interpret the tag's value.
 }
function CGImageMetadataTagGetType( tag: CGImageMetadataTagRef ): CGImageMetadataType; external name '_CGImageMetadataTagGetType';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

{!
 * @function CGImageMetadataTagCopyQualifiers
 * @abstract Return a copy of the tag's qualifiers
 * @discussion XMP allows properties to contain supplemental properties called
 * qualifiers. Qualifiers are themselves CGImageMetadataTags with their own 
 * namespace, prefix, name, and value. A common use is the xml:lang qualifier
 * for elements of an alternate-text array.
 * @return Returns a copy of the array of qualifiers. Elements of the array are 
 * CGImageMetadataTags. Returns NULL if the tag does not have any qualifiers. 
 * The copy is shallow, the qualifiers are not deep copied.
 }
function CGImageMetadataTagCopyQualifiers( tag: CGImageMetadataTagRef ): CFArrayRef; external name '_CGImageMetadataTagCopyQualifiers';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)


// ****************************************************************************
// Functions for copying CGImageMetadataTagRefs from a CGImageMetadataRef. 
// These functions make it easier for the caller to traverse complex nested 
// structures of metadata, similar to KVC-compliant Objective-C classes.
// ****************************************************************************
//{! @functiongroup Retrieving CGImageMetadataTagRefs from a CGImageMetadataRef }
{!
 * @function CGImageMetadataCopyTags
 * @abstract Obtain an array of tags from a CGImageMetadataRef
 * @return Returns an array with a shallow copy of all top-level 
 * CGImageMetadataTagRefs in a CGImageMetadataRef.
 }
function CGImageMetadataCopyTags( metadata: CGImageMetadataRef ): CFArrayRef; external name '_CGImageMetadataCopyTags';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

{!
 * @function CGImageMetadataCopyTagWithPath
 * @abstract Searches for a specific CGImageMetadataTag in a CGImageMetadataRef
 * @discussion This is the primary function for clients to obtain specific 
 * metadata properties from an image. The 'path' mechanism provides a way to 
 * access both simple top-level properties, such as Date & Time, or complex 
 * deeply-nested properties with ease.
 * @param metadata A collection of metadata tags.
 * @param parent A parent tag. If NULL, the path is relative to the root of the
 * CGImageMetadataRef (i.e. it is not a child of another property). If the parent
 * is provided, the effective path will be the concatenation of the parent's path
 * and the 'path' parameter. This is useful for accessing array elements or 
 * structure fields inside nested tags.
 * @param path A string representing a path to the desired tag. Paths consist of
 * a tag prefix (i.e. "exif") joined with a tag name (i.e. "Flash") by a colon 
 * (":"), such as CFSTR("exif:Flash"). 
 * Elements of ordered and unordered arrays are accessed via 0-based indices inside square [] brackets.
 * Elements of alternate-text arrays are accessed by an RFC 3066 language code inside square [] brackets.
 * Fields of a structure are delimited by a period, '.'.
 * Qualifiers are delimited by the '?' character. Only tags with string values (kCGImageMetadataTypeString)
 * are allowed to have qualifiers - arrays and structures may not contain qualifiers.
 *
 * If parent is NULL, a prefix must be specified for the first tag. Prefixes for
 * all subsequent tags are optional. If unspecified, the prefix is 
 * inherented from the nearest parent tag with a prefix. Custom prefixes must be
 * registered using @link CGImageMetadataRegisterNamespaceForPrefix @/link prior to use 
 * in any path-based functions.
 *
 * Examples:
 *  <ul>
 *    <li>'path' = CFSTR("xmp:CreateDate")</li>       
 *    <li>'path' = CFSTR("exif:Flash.Fired")</li>
 *    <li>'parent' = tag at path CFSTR("exif:Flash"), path = CFSTR("exif:Fired") (equivilent to previous)</li>
 *    <li>'path' = CFSTR("exif:Flash.RedEyeMode")</li>
 *    <li>'path' = CFSTR("dc:title")</li>
 *    <li>'path' = CFSTR("dc:subject")</li>
 *    <li>'path' = CFSTR("dc:subject[2]") </li>
 *    <li>'parent' = tag at path CFSTR("dc:subject"), path = CFSTR("[2]") (equivilent to previous)</li>
 *    <li>'path' = CFSTR("dc:description[x-default])"</li>
 *    <li>'path' = CFSTR("dc.description[de])"</li>
 *    <li>'path' = CFSTR("dc.description[fr])"</li>
 *    <li>'path' = CFSTR("foo:product)"</li>
 *    <li>'path' = CFSTR("foo:product?bar:manufacturer)"</li>
 *  </ul>
 * @return Returns a copy of CGImageMetadataTag matching 'path', or NULL if no 
 * match is found. The copy of the tag's value is shallow. Tags
 * copied from an immutable CGImageMetadataRef are also immutable. Because this
 * function returns a copy of the tag's value, any modification of the tag's 
 * value must be followed by a CGImageMetadataSetTagWithPath to commit the 
 * change to the metadata container.
 }
function CGImageMetadataCopyTagWithPath( metadata: CGImageMetadataRef; parent: CGImageMetadataTagRef; path: CFStringRef ): CGImageMetadataTagRef; external name '_CGImageMetadataCopyTagWithPath';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

{!
 * @function CGImageMetadataCopyStringValueWithPath
 * @abstract Searches for a specific tag in a CGImageMetadataRef and returns its
 * string value.
 * @discussion This is a convenience method for searching for a tag at path and
 * extracting the string value.
 * @param metadata A collection of metadata tags.
 * @param parent A parent tag. If NULL, the path is relative to the root of the
 * CGImageMetadataRef (i.e. it is not a child of another property).
 * @param path A string with the path to the desired tag. Please consult
 * the documentation of @link CGImageMetadataCopyTagWithPath @/link for 
 * information about path syntax.
 * @return Returns a string from a CGImageMetadataTag located at 'path'. The 
 * tag must be of type kCGImageMetadataTypeString or kCGImageMetadataTypeAlternateText.
 * For AlternateText tags, the element with the "x-default" language qualifier 
 * will be returned. For other types, NULL will be returned.
 }
function CGImageMetadataCopyStringValueWithPath( metadata: CGImageMetadataRef; parent: CGImageMetadataTagRef; path: CFStringRef ): CFStringRef; external name '_CGImageMetadataCopyStringValueWithPath';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

// ****************************************************************************
// Functions for modifying a CGMutableImageMetadataRef
// ****************************************************************************
//{! @functiongroup Modifying a CGMutableImageMetadataRef }
{!
 * @function CGImageMetadataRegisterNamespaceForPrefix
 * @abstract Associates an XMP namespace URI with a prefix string.
 * @discussion This allows ImageIO to create custom metadata when it encounters 
 * an unrecognized prefix in a path (see CGImageMetadataCopyTagWithPath for more
 * information about path syntax). A namespace must be registered before it can 
 * be used to add custom metadata. All namespaces found in the image's metadata,
 * or defined as a constant above, will be pre-registered. Namespaces and 
 * prefixes must be unique.
 * @return Returns true if successful. Returns false and sets 'err' if an error 
 * or conflict occurs.
 }
function CGImageMetadataRegisterNamespaceForPrefix( metadata: CGMutableImageMetadataRef; xmlns: CFStringRef; prefix: CFStringRef; var err: CFErrorRef ): CBool; external name '_CGImageMetadataRegisterNamespaceForPrefix';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

{!
 * @function CGImageMetadataSetTagWithPath
 * @abstract Sets the tag at a specific path in a CGMutableImageMetadata container or a parent tag
 * @discussion This is the primary function for adding new metadata tags to a 
 * metadata container, or updating existing tags. All tags required to reach 
 * the final tag (at the end of the path) will be created, if needed. Tags will
 * created with default types (ordered arrays). Creating tags will fail if a 
 * prefix is encountered that has not been registered. Use
 * @link CGImageMetadataRegisterNamespaceForPrefix @/link to associate a prefix
 * with a namespace prior to using a path-based CGImageMetadata function.
 * Note that if a parent tag is provided,
 * the children of that tag reference will be modified, which may be a different
 * reference from the tag stored in the metadata container. Since tags are normally
 * obtained as a copy, it is typically neccesary to use CGImageMetadataSetTagWithPath
 * to commit the changed parent object back to the metadata container (using
 * the parent's path and NULL for the parent).
 * @param metadata A mutable collection of metadata tags. 
 * Use @link CGImageMetadataCreateMutableCopy @/link or 
 * @link CGImageMetadataCreateMutable @/link to obtain a mutable metadata container.
 * @param parent A parent tag. If NULL, the path is relative to the root of the
 * CGImageMetadataRef (i.e. it is not a child of another property). 
 * Note that if a parent tag is provided,
 * the children of that tag reference will be modified, which may be a different
 * reference from the tag stored in the metadata container. Since tags are normally
 * obtained as a copy, it is typically neccesary to use CGImageMetadataSetTagWithPath
 * to commit the changed parent object back to the metadata container (using
 * the parent's path and NULL for the parent).
 * @param path A string with the path to the desired tag. Please consult
 * the documentation of @link CGImageMetadataCopyTagWithPath @/link for 
 * information about path syntax.
 * @param tag The CGImageMetadataTag to be added to the metadata. The tag
 * will be retained.
 * @return Returns true if successful, false otherwise.
 }
function CGImageMetadataSetTagWithPath( metadata: CGMutableImageMetadataRef; parent: CGImageMetadataTagRef; path: CFStringRef; tag: CGImageMetadataTagRef ): CBool; external name '_CGImageMetadataSetTagWithPath';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

{!
 * @function CGImageMetadataSetValueWithPath
 * @abstract Sets the value of the tag at a specific path in a CGMutableImageMetadataRef container or a parent tag
 * @discussion This function is used to add new metadata values to a 
 * metadata container, or update existing tag values. All tags required to reach 
 * the final tag (at the end of the path) are created, if needed. Tags are
 * created with default types (i.e. arrays will be ordered). Creating tags will 
 * fail if a prefix is encountered that has not been registered. Use
 * @link CGImageMetadataRegisterNamespaceForPrefix @/link to associate a prefix
 * with a namespace prior to using a path-based CGImageMetadata function.
 *
 * Examples
 * <ul>
 *     <li>'path' = CFSTR("xmp:CreateDate"), 'value' = CFSTR("2011-09-20T14:54:47-08:00")</li>
 *     <li>'path' = CFSTR("dc:subject[0]"), 'value' = CFSTR("San Francisco")</li>
 *     <li>'path' = CFSTR("dc:subject[1]"), 'value' = CFSTR("Golden Gate Bridge")</li>
 *     <li>'path' = CFSTR("dc:description[en]") 'value' = CFSTR("my image description")</li>
 *     <li>'path' = CFSTR("dc:description[de]") 'value' = CFSTR("meine bildbeschreibung")</li>
 * </ul>
 * Note that if a parent tag is provided,
 * the children of that tag reference will be modified, which may be a different
 * reference from the tag stored in the metadata container. Since tags are normally
 * obtained as a copy, it is typically neccesary to use CGImageMetadataSetTagWithPath
 * to commit the changed parent object back to the metadata container (using
 * the parent's path and NULL for the parent).
 * @param metadata A mutable collection of metadata tags. 
 * Use @link CGImageMetadataCreateMutableCopy @/link or 
 * @link CGImageMetadataCreateMutable @/link to obtain a mutable metadata container.
 * @param parent A parent tag. If NULL, the path is relative to the root of the
 * CGImageMetadataRef (i.e. it is not a child of another property).
 * @param path A string with the path to the desired tag. Please consult
 * the documentation of @link CGImageMetadataCopyTagWithPath @/link for 
 * information about path syntax.
 * @param value The value to be added to the CGImageMetadataTag matching the path.
 * The tag will be retained. The restrictions for the value are the same as in @link
 * CGImageMetadataTagCreate @/link.
 * @return Returns true if successful, false otherwise.
 }
function CGImageMetadataSetValueWithPath( metadata: CGMutableImageMetadataRef; parent: CGImageMetadataTagRef; path: CFStringRef; value: CFTypeRef ): CBool; external name '_CGImageMetadataSetValueWithPath';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

{!
 * @function CGImageMetadataRemoveTagWithPath
 * @abstract Removes the tag at a specific path from a CGMutableImageMetadata container or from the parent tag
 * @discussion Use this function to delete a metadata tag matching a specific 
 * path from a mutable metadata container. Note that if a parent tag is provided,
 * the children of that tag reference will be modified, which may be a different
 * reference from the tag stored in the metadata container. Since tags are normally
 * obtained as a copy, it is typically neccesary to use CGImageMetadataSetTagWithPath
 * to commit the changed parent object back to the metadata container (using
 * the parent's path and NULL for the parent).
 * @param parent A parent tag. If NULL, the path is relative to the root of the
 * CGImageMetadataRef (i.e. it is not a child of another property).
 * @param path A string with the path to the desired tag. Please consult
 * the documentation of @link CGImageMetadataCopyTagWithPath @/link for 
 * information about path syntax.
 }
function CGImageMetadataRemoveTagWithPath( metadata: CGMutableImageMetadataRef; parent: CGImageMetadataTagRef; path: CFStringRef ): CBool; external name '_CGImageMetadataRemoveTagWithPath';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)


// A key for the 'options' of CGImageMetadataEnumerateTagsUsingBlock. If present,
// the value should be a CFBoolean. If true, tags will be enumerated recursively,
// if false, only the direct children of 'rootPath' will be enumerated. 
// The default is non-recursive.
var kCGImageMetadataEnumerateRecursively: CFStringRef; external name '_kCGImageMetadataEnumerateRecursively'; (* attribute const *)
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)


// ****************************************************************************
// Functions for working with constants defined in CGImageProperties.h
// Provides a bridge for values from CGImageCopyPropertiesAtIndex().
// Simplifies metadata access for properties defined EXIF and IPTC standards, 
// which have no notion of namespaces, prefixes, or XMP property types.
// Metadata Working Group guidance is factored into the mapping of 
// CGImageProperties to XMP. For example, setting Exif DateTimeOriginal will
// set the value of the corresponding XMP tag, which is photoshop:DateCreated
// ****************************************************************************

//{! @functiongroup Working with CGImageProperties }
{!
 * @function CGImageMetadataCopyTagMatchingImageProperty
 * @abstract Searches for a specific CGImageMetadataTag matching a kCGImageProperty constant
 * @discussion Provides a bridge for values from CGImageCopyPropertiesAtIndex, simplifying 
 * access for properties defined in EXIF and IPTC standards, which have no notion of 
 * namespaces, prefixes, or XMP property types.
 * Metadata Working Group guidance is factored into the mapping of CGImageProperties to 
 * XMP compatible CGImageMetadataTags.
 * For example, kCGImagePropertyExifDateTimeOriginal will get the value of the 
 * corresponding XMP tag, which is photoshop:DateCreated. Note that property values will 
 * still be in their XMP forms, such as "YYYY-MM-DDThh:mm:ss" for DateTime, rather than
 * the EXIF or IPTC DateTime formats.
 * @param metadata A collection of metadata tags
 * @param dictionaryName the metadata subdictionary to which the image property belongs,
 * such as kCGImagePropertyExifDictionary or kCGImagePropertyIPTCDictionary. Not all
 * dictionaries and properties are supported at this time.
 * @param propertyName the name of the property. This must be a defined property constant
 * corresponding to the 'dictionaryName'. For example, kCGImagePropertyTIFFOrientation,
 * kCGImagePropertyExifDateTimeOriginal, or kCGImagePropertyIPTCKeywords. A warning
 * will be logged if the CGImageProperty is unsupported by CGImageMetadata.
 * @return Returns a CGImageMetadataTagRef with the appropriate namespace, prefix, 
 * tag name, and XMP value for the corresponding CGImageProperty. Returns NULL if the 
 * property could not be found.
 }
function CGImageMetadataCopyTagMatchingImageProperty( metadata: CGImageMetadataRef; dictionaryName: CFStringRef; propertyName: CFStringRef ): CGImageMetadataTagRef; external name '_CGImageMetadataCopyTagMatchingImageProperty';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

{!
 * @function CGImageMetadataSetValueMatchingImageProperty
 * @abstract Sets the value of the CGImageMetadataTag matching a kCGImageProperty constant
 * @discussion Provides a bridge for values from CGImageCopyPropertiesAtIndex, simplifying 
 * changing property values defined in EXIF and IPTC standards, which have no notion of 
 * namespaces, prefixes, or XMP property types.
 * Metadata Working Group guidance is factored into the mapping of CGImageProperties to 
 * XMP compatible CGImageMetadataTags.
 * For example, setting kCGImagePropertyExifDateTimeOriginal will set the value of the 
 * corresponding XMP tag, which is photoshop:DateCreated. Note that property values should 
 * still be in their XMP forms, such as "YYYY-MM-DDThh:mm:ss" for DateTime, rather than
 * the EXIF or IPTC DateTime formats. Although this function will allow the caller to set
 * custom values for these properties, you should consult the appropriate specifications 
 * for details about property value formats for EXIF and IPTC tags in XMP.
 * @param metadata A mutable collection of metadata tags
 * @param dictionaryName the metadata subdictionary to which the image property belongs,
 * such as kCGImagePropertyExifDictionary or kCGImagePropertyIPTCDictionary. Not all
 * dictionaries and properties are supported at this time.
 * @param propertyName the name of the property. This must be a defined property constant
 * corresponding to the 'dictionaryName'. For example, kCGImagePropertyTIFFOrientation,
 * kCGImagePropertyExifDateTimeOriginal, or kCGImagePropertyIPTCKeywords. A warning
 * will be logged if the CGImageProperty is unsupported by CGImageMetadata.
 * @param value A CFTypeRef with the value for the tag. The same value restrictions apply
 * as in @link CGImageMetadataTagCreate @/link.
 * @return Returns true if successful, false otherwise.
 }
function CGImageMetadataSetValueMatchingImageProperty( metadata: CGMutableImageMetadataRef; dictionaryName: CFStringRef; propertyName: CFStringRef; value: CFTypeRef ): CBool; external name '_CGImageMetadataSetValueMatchingImageProperty';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)


// ****************************************************************************
// Functions for converting metadata to and from XMP packets
// ****************************************************************************
//{! @functiongroup Reading and Writing XMP }

{!
 * @function CGImageMetadataCreateXMPData
 * @abstract Serializes the CGImageMetadataRef to XMP data
 * @discussion This converts all of the metadata tags to a block of XMP data. Common uses
 * include creating sidecar files that contain metadata for image formats that do not 
 * support embedded XMP, or cannot be edited due to other format restrictions (such as
 * proprietary RAW camera formats).
 * @param metadata A collection of metadata tags.
 * @param options should be NULL. Options are currently not used, but may be used in 
 * future release.
 * @return Returns a CFData containing an XMP representation of the metadata. Returns
 * NULL if an error occurred. 
 }
function CGImageMetadataCreateXMPData( metadata: CGImageMetadataRef; options: CFDictionaryRef ): CFDataRef; external name '_CGImageMetadataCreateXMPData';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

{!
 * @function CGImageMetadataCreateFromXMPData
 * @abstract Creates a collection of CGImageMetadataTags from a block of XMP data
 * @discussion Converts XMP data into a collection of metadata tags.
 * The data must be a complete XMP tree. XMP packet  headers (<?xpacket .. ?>) are 
 * supported.
 * @param data The XMP data.
 * @return Returns a collection of CGImageMetadata tags. Returns NULL if an error occurred. 
 }
function CGImageMetadataCreateFromXMPData( data: CFDataRef ): CGImageMetadataRef; external name '_CGImageMetadataCreateFromXMPData';
(* IMAGEIO_AVAILABLE_STARTING(__MAC_10_8, __IPHONE_NA) *)

{!
 *  @constant kCFErrorDomainCGImageMetadata
 *  @discussion Error domain for all errors originating in ImageIO for CGImageMetadata APIs.
 *      Error codes may be interpreted using the list below.
 }
var kCFErrorDomainCGImageMetadata: CFStringRef; external name '_kCFErrorDomainCGImageMetadata'; (* attribute const *)

{!
 *  @enum CGImageMetadataErrors
 *  @discussion the list of all error codes returned under the error domain kCFErrorDomainCGImageMetadata
 }
const
    kCGImageMetadataErrorUnknown = 0;
    kCGImageMetadataErrorUnsupportedFormat = 1;
    kCGImageMetadataErrorBadArgument = 2;
    kCGImageMetadataErrorConflictingArguments = 3;
    kCGImageMetadataErrorPrefixConflict = 4;
type
  CGImageMetadataErrors = UInt32;

{$endc} { TARGET_OS_MAC }
{$ifc not defined MACOSALLINCLUDE or not MACOSALLINCLUDE}

end.
{$endc} {not MACOSALLINCLUDE}
