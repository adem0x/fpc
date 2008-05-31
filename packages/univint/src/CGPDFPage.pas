{ CoreGraphics - CGPDFPage.h
 * Copyright (c) 2001-2004 Apple Computer, Inc.
 * All rights reserved.
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

unit CGPDFPage;
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
uses MacTypes,CGAffineTransforms,CFBase,CGBase,CGPDFDocument,CGGeometry;
{$ALIGN POWER}


// CGPDFPageRef defined in CGBase


type
	CGPDFBox = SInt32;
const
	kCGPDFMediaBox = 0;
	kCGPDFCropBox = 1;
	kCGPDFBleedBox = 2;
	kCGPDFTrimBox = 3;
	kCGPDFArtBox = 4;


{ Equivalent to `CFRetain(page)', except it doesn't crash (as CFRetain
 * does) if `page' is NULL. }

function CGPDFPageRetain( page: CGPDFPageRef ): CGPDFPageRef; external name '_CGPDFPageRetain'; (* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)

{ Equivalent to `CFRelease(page)', except it doesn't crash (as CFRelease
 * does) if `page' is NULL. }

procedure CGPDFPageRelease( page: CGPDFPageRef ); external name '_CGPDFPageRelease'; (* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)

{ Return the document of `page'. }

function CGPDFPageGetDocument( page: CGPDFPageRef ): CGPDFDocumentRef; external name '_CGPDFPageGetDocument'; (* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)

{ Return the page number of `page'. }

function CGPDFPageGetPageNumber( page: CGPDFPageRef ): size_t; external name '_CGPDFPageGetPageNumber'; (* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)

{ Return the rectangle associated with `box' in `page'.  This is the value
 * of the corresponding entry (such as /MediaBox, /ArtBox, and so on) in
 * the page's dictionary. }

function CGPDFPageGetBoxRect( page: CGPDFPageRef; box: CGPDFBox ): CGRect; external name '_CGPDFPageGetBoxRect'; (* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)

{ Return the rotation angle (in degrees) of `page'.  This is the value of
 * the /Rotate entry in the page's dictionary. }

function CGPDFPageGetRotationAngle( page: CGPDFPageRef ): SInt32; external name '_CGPDFPageGetRotationAngle'; (* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)

{ Return a transform mapping the box specified by `box' to `rect' as
 * follows:
 *   - Compute the effective rect by intersecting the rect associated with
 *     `box' and the /MediaBox entry of the page.
 *   - Rotate the effective rect according to the page's /Rotate entry.
 *   - Center the resulting rect on `rect'.  If `rotation' is non-zero,
 *     then the rect will rotated clockwise by `rotation' degrees.
 *     `rotation' must be a multiple of 90.
 *   - Scale the rect down, if necessary, so that it coincides with the
 *     edges of `rect'.  If `preserveAspectRatio' is true, then the final
 *     rect will coincide with the edges of `rect' only in the more
 *     restrictive dimension. }

function CGPDFPageGetDrawingTransform( page: CGPDFPageRef; box: CGPDFBox; rect: CGRect; rotate: SInt32; preserveAspectRatio: CBool ): CGAffineTransform; external name '_CGPDFPageGetDrawingTransform'; (* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)

{ Return the dictionary of `page'. }

function CGPDFPageGetDictionary( page: CGPDFPageRef ): CGPDFDictionaryRef; external name '_CGPDFPageGetDictionary'; (* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)

{ Return the CFTypeID for CGPDFPageRefs. }

function CGPDFPageGetTypeID: CFTypeID; external name '_CGPDFPageGetTypeID'; (* AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER *)


end.
