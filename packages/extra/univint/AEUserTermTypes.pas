{
     File:       AEUserTermTypes.p
 
     Contains:   AppleEvents AEUT resource format Interfaces.
 
     Version:    Technology: System 7.5
                 Release:    Universal Interfaces 3.4.2
 
     Copyright:  � 1991-2002 by Apple Computer, Inc., all rights reserved
 
     Bugs?:      For bug reports, consult the following page on
                 the World Wide Web:
 
                     http://developer.apple.com/bugreporter/
 
}


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

unit AEUserTermTypes;
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
uses MacTypes,ConditionalMacros;


{$ALIGN MAC68K}


const
	kAEUserTerminology			= $61657574 (* 'aeut' *);						{   0x61657574   }
	kAETerminologyExtension		= $61657465 (* 'aete' *);						{   0x61657465   }
	kAEScriptingSizeResource	= $7363737A (* 'scsz' *);						{   0x7363737a   }
	kAEOSAXSizeResource			= $6F73697A (* 'osiz' *);

	kAEUTHasReturningParam		= 31;							{  if event has a keyASReturning param  }
	kAEUTOptional				= 15;							{  if something is optional  }
	kAEUTlistOfItems			= 14;							{  if property or reply is a list.  }
	kAEUTEnumerated				= 13;							{  if property or reply is of an enumerated type.  }
	kAEUTReadWrite				= 12;							{  if property is writable.  }
	kAEUTChangesState			= 12;							{  if an event changes state.  }
	kAEUTTightBindingFunction	= 12;							{  if this is a tight-binding precedence function.  }
																{  AppleScript 1.3: new bits for reply, direct parameter, parameter, and property flags  }
	kAEUTEnumsAreTypes			= 11;							{  if the enumeration is a list of types, not constants  }
	kAEUTEnumListIsExclusive	= 10;							{  if the list of enumerations is a proper set  }
	kAEUTReplyIsReference		= 9;							{  if the reply is a reference, not a value  }
	kAEUTDirectParamIsReference	= 9;							{  if the direct parameter is a reference, not a value  }
	kAEUTParamIsReference		= 9;							{  if the parameter is a reference, not a value  }
	kAEUTPropertyIsReference	= 9;							{  if the property is a reference, not a value  }
	kAEUTNotDirectParamIsTarget	= 8;							{  if the direct parameter is not the target of the event  }
	kAEUTParamIsTarget			= 8;							{  if the parameter is the target of the event  }
	kAEUTApostrophe				= 3;							{  if a term contains an apostrophe.  }
	kAEUTFeminine				= 2;							{  if a term is feminine gender.  }
	kAEUTMasculine				= 1;							{  if a term is masculine gender.  }
	kAEUTPlural					= 0;							{  if a term is plural.  }


type
	TScriptingSizeResourcePtr = ^TScriptingSizeResource;
	TScriptingSizeResource = record
		scriptingSizeFlags:		SInt16;
		minStackSize:			UInt32;
		preferredStackSize:		UInt32;
		maxStackSize:			UInt32;
		minHeapSize:			UInt32;
		preferredHeapSize:		UInt32;
		maxHeapSize:			UInt32;
	end;


const
	kLaunchToGetTerminology		= $8000;						{     If kLaunchToGetTerminology is 0, 'aete' is read directly from res file.  If set to 1, then launch and use 'gdut' to get terminology.  }
	kDontFindAppBySignature		= $4000;						{     If kDontFindAppBySignature is 0, then find app with signature if lost.  If 1, then don't  }
	kAlwaysSendSubject			= $2000;						{     If kAlwaysSendSubject 0, then send subject when appropriate. If 1, then every event has Subject Attribute  }

	{	 old names for above bits. 	}
	kReadExtensionTermsMask		= $8000;

																{  AppleScript 1.3: Bit positions for osiz resource  }
																{  AppleScript 1.3: Bit masks for osiz resources  }
	kOSIZDontOpenResourceFile	= 15;							{  If set, resource file is not opened when osax is loaded  }
	kOSIZdontAcceptRemoteEvents	= 14;							{  If set, handler will not be called with events from remote machines  }
	kOSIZOpenWithReadPermission	= 13;							{  If set, file will be opened with read permission only  }
	kOSIZCodeInSharedLibraries	= 11;							{  If set, loader will look for handler in shared library, not osax resources  }

{$ALIGN MAC68K}


end.
