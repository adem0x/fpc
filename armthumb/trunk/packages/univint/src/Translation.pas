{
     File:       HIToolbox/Translation.h
 
     Contains:   Translation Manager (Macintosh Easy Open) Interfaces.
 
     Version:    HIToolbox-219.4.81~2
 
     Copyright:  � 1991-2005 by Apple Computer, Inc., all rights reserved.
 
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

unit Translation;
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
uses MacTypes,Files,Components,TranslationExtensions;


{$ALIGN MAC68K}

{
   Carbon clients should use Translation Services. The definitions below will NOT work for Carbon and
   are only defined for those files that need to build pre-Carbon applications.
}

{ enumerated types on how a document can be opened}
type
	DocOpenMethod = SInt16;
const
	domCannot = 0;
	domNative = 1;
	domTranslateFirst = 2;
	domWildcard = 3;

{ 0L terminated array of OSTypes, or FileTypes}
type
	TypesBlock = array [0..63] of OSType;
	TypesBlockPtr = ^TypesBlock;
{ Progress dialog resource ID}
const
	kTranslationScrapProgressDialogID = -16555;

{ block of data that describes how to translate}
type
	FileTranslationSpecPtr = ^FileTranslationSpec;
	FileTranslationSpec = record
		componentSignature: OSType;
		translationSystemInfo: UnivPtr;
		src: FileTypeSpec;
		dst: FileTypeSpec;
	end;
type
	FileTranslationSpecArray = array [0..$7F000000 div SizeOf(FileTranslationSpec)-1] of FileTranslationSpec;
	FileTranslationSpecArrayPtr = ^FileTranslationSpecArray;
	FileTranslationSpecArrayHandle = ^FileTranslationSpecArrayPtr;

{
 *  GetFileTypesThatAppCanNativelyOpen()   *** DEPRECATED ***
 *  
 *  Deprecated:
 *    There is no direct replacement at this time.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework but deprecated in 10.3
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in Translation 1.0 and later
 }
function GetFileTypesThatAppCanNativelyOpen( appVRefNumHint: SInt16; appSignature: OSType; var nativeTypes: TypesBlock ): OSErr; external name '_GetFileTypesThatAppCanNativelyOpen';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_3 *)


{
 *  ExtendFileTypeList()   *** DEPRECATED ***
 *  
 *  Deprecated:
 *    Use TranslationCreateWithSourceArray instead.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework but deprecated in 10.3
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in Translation 1.0 and later
 }
function ExtendFileTypeList( originalTypeList: {variable-size-array} FileTypePtr; numberOriginalTypes: SInt16; extendedTypeList: {variable-size-array} FileTypePtr; var numberExtendedTypes: SInt16 ): OSErr; external name '_ExtendFileTypeList';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_3 *)


{
 *  CanDocBeOpened()   *** DEPRECATED ***
 *  
 *  Deprecated:
 *    Use the Launch Services API instead.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework but deprecated in 10.3
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in Translation 1.0 and later
 }
function CanDocBeOpened( const (*var*) targetDocument: FSSpec; appVRefNumHint: SInt16; appSignature: OSType; nativeTypes: {variable-size-array} FileTypePtr; onlyNative: Boolean; var howToOpen: DocOpenMethod; var howToTranslate: FileTranslationSpec ): OSErr; external name '_CanDocBeOpened';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_3 *)


{
 *  GetFileTranslationPaths()   *** DEPRECATED ***
 *  
 *  Deprecated:
 *    Use TranslationCreateWithSourceArray instead.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework but deprecated in 10.3
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in Translation 1.0 and later
 }
function GetFileTranslationPaths( const (*var*) srcDocument: FSSpec; dstDocType: FileType; maxResultCount: UInt16; resultBuffer: FileTranslationSpecArrayPtr ): SInt16; external name '_GetFileTranslationPaths';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_3 *)


{
 *  GetPathFromTranslationDialog()   *** DEPRECATED ***
 *  
 *  Deprecated:
 *    There is no direct replacement at this time, but all the
 *    necessary information can be obtained from the Launch Services,
 *    Translation Services and Uniform Type Identification APIs.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework but deprecated in 10.3
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in Translation 1.0 and later
 }
function GetPathFromTranslationDialog( const (*var*) theDocument: FSSpec; const (*var*) theApplication: FSSpec; typeList: TypesBlockPtr; var howToOpen: DocOpenMethod; var howToTranslate: FileTranslationSpec ): OSErr; external name '_GetPathFromTranslationDialog';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_3 *)


{
 *  TranslateFile()   *** DEPRECATED ***
 *  
 *  Deprecated:
 *    Use TranslationPerformForFile or TranslationPerformForURL instead.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework but deprecated in 10.3
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in Translation 1.0 and later
 }
function TranslateFile( const (*var*) sourceDocument: FSSpec; const (*var*) destinationDocument: FSSpec; const (*var*) howToTranslate: FileTranslationSpec ): OSErr; external name '_TranslateFile';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_3 *)


{
 *  GetDocumentKindString()   *** DEPRECATED ***
 *  
 *  Deprecated:
 *    Use the Launch Services API instead.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework but deprecated in 10.3
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in Translation 1.0 and later
 }
function GetDocumentKindString( docVRefNum: SInt16; docType: OSType; docCreator: OSType; var kindString: Str63 ): OSErr; external name '_GetDocumentKindString';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_3 *)


{
 *  GetTranslationExtensionName()   *** DEPRECATED ***
 *  
 *  Deprecated:
 *    There is no direct replacement at this time, but
 *    TranslationCopySourceType and TranslationCopyDestinationType in
 *    conjunction with UTTypeCopyDescription will provide useful user
 *    level information.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework but deprecated in 10.3
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in Translation 1.0 and later
 }
function GetTranslationExtensionName( const (*var*) translationMethod: FileTranslationSpec; var extensionName: Str31 ): OSErr; external name '_GetTranslationExtensionName';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_3 *)


{
 *  GetScrapDataProcPtr
 }
type
	GetScrapDataProcPtr = function( requestedFormat: ScrapType; dataH: Handle; srcDataGetterRefCon: UnivPtr ): OSErr;
	GetScrapDataUPP = GetScrapDataProcPtr;
{
 *  NewGetScrapDataUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
function NewGetScrapDataUPP( userRoutine: GetScrapDataProcPtr ): GetScrapDataUPP; external name '_NewGetScrapDataUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_3 *)

{
 *  DisposeGetScrapDataUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
procedure DisposeGetScrapDataUPP( userUPP: GetScrapDataUPP ); external name '_DisposeGetScrapDataUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_3 *)

{
 *  InvokeGetScrapDataUPP()
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   available as macro/inline
 }
function InvokeGetScrapDataUPP( requestedFormat: ScrapType; dataH: Handle; srcDataGetterRefCon: UnivPtr; userUPP: GetScrapDataUPP ): OSErr; external name '_InvokeGetScrapDataUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_3 *)

type
	GetScrapData = GetScrapDataUPP;
{
 *  TranslateScrap()   *** DEPRECATED ***
 *  
 *  Deprecated:
 *    Use TranslationPerformForData instead.
 *  
 *  Mac OS X threading:
 *    Not thread safe
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in Carbon.framework but deprecated in 10.3
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in Translation 1.0 and later
 }
function TranslateScrap( sourceDataGetter: GetScrapDataUPP; sourceDataGetterRefCon: UnivPtr; destinationFormat: ScrapType; destinationData: Handle; progressDialogID: SInt16 ): OSErr; external name '_TranslateScrap';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_3 *)




end.
