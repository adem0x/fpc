{
     File:       GestaltEqu.p
 
     Contains:   Gestalt Interfaces.
 
     Version:    Technology: Mac OS 9.1
                 Release:    Universal Interfaces 3.4.2
 
     Copyright:  � 1988-2002 by Apple Computer, Inc.  All rights reserved
 
     Bugs?:      For bug reports, consult the following page on
                 the World Wide Web:
 
                     http://www.freepascal.org/bugs.html
 
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

unit GestaltEqu;
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
uses MacTypes,MixedMode;


{$ALIGN MAC68K}


type
{$ifc TYPED_FUNCTION_POINTERS}
	SelectorFunctionProcPtr = function(selector: OSType; var response: SInt32): OSErr;
{$elsec}
	SelectorFunctionProcPtr = ProcPtr;
{$endc}

{$ifc OPAQUE_UPP_TYPES}
	SelectorFunctionUPP = ^SInt32; { an opaque UPP }
{$elsec}
	SelectorFunctionUPP = UniversalProcPtr;
{$endc}	
{
 *  Gestalt()
 *  
 *  Summary:
 *    Gestalt returns information about the operating environment.
 *  
 *  Discussion:
 *    The Gestalt function places the information requested by the
 *    selector parameter in the variable parameter response . Note that
 *    Gestalt returns the response from all selectors in a long word,
 *    which occupies 4 bytes. When not all 4 bytes are needed, the
 *    significant information appears in the low-order byte or bytes.
 *    Although the response parameter is declared as a variable
 *    parameter, you cannot use it to pass information to Gestalt or to
 *    a Gestalt selector function. Gestalt interprets the response
 *    parameter as an address at which it is to place the result
 *    returned by the selector function specified by the selector
 *    parameter. Gestalt ignores any information already at that
 *    address.
 *    
 *    The Apple-defined selector codes fall into two categories:
 *    environmental selectors, which supply specific environmental
 *    information you can use to control the behavior of your
 *    application, and informational selectors, which supply
 *    information you can't use to determine what hardware or software
 *    features are available. You can use one of the selector codes
 *    defined by Apple (listed in the "Constants" section beginning on
 *    page 1-14 ) or a selector code defined by a third-party
 *    product.
 *    
 *    The meaning of the value that Gestalt returns in the response
 *    parameter depends on the selector code with which it was called.
 *    For example, if you call Gestalt using the gestaltTimeMgrVersion
 *    selector, it returns a version code in the response parameter. In
 *    this case, a returned value of 3 indicates that the extended Time
 *    Manager is available.
 *    
 *    In most cases, the last few characters in the selector's symbolic
 *    name form a suffix that indicates what type of value you can
 *    expect Gestalt to place in the response parameter. For example,
 *    if the suffix in a Gestalt selector is Size , then Gestalt
 *    returns a size in the response parameter.
 *    
 *    Attr:  A range of 32 bits, the meanings of which are defined by a
 *    list of constants. Bit 0 is the least significant bit of the long
 *    word.
 *    Count: A number indicating how many of the indicated type of item
 *    exist.
 *    Size: A size, usually in bytes.
 *    Table: The base address of a table.
 *    Type: An index to a list of feature descriptions.
 *    Version: A version number, which can be either a constant with a
 *    defined meaning or an actual version number, usually stored as
 *    four hexadecimal digits in the low-order word of the return
 *    value. Implied decimal points may separate digits. The value
 *    $0701, for example, returned in response to the
 *    gestaltSystemVersion selector, represents system software version
 *    7.0.1.
 *    
 *    Selectors that have the suffix Attr deserve special attention.
 *    They cause Gestalt to return a bit field that your application
 *    must interpret to determine whether a desired feature is present.
 *    For example, the application-defined sample function
 *    MyGetSoundAttr , defined in Listing 1-2 on page 1-6 , returns a
 *    LongInt that contains the Sound Manager attributes field
 *    retrieved from Gestalt . To determine whether a particular
 *    feature is available, you need to look at the designated bit.
 *  
 *  Mac OS X threading:
 *    Thread safe since version 10.3
 *  
 *  Parameters:
 *    
 *    selector:
 *      The selector to return information for
 *    
 *    response:
 *      On exit, the requested information whose format depends on the
 *      selector specified.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.1 and later
 }
function Gestalt(selector: OSType; var response: SInt32): OSErr; external name '_Gestalt';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  ReplaceGestalt()   *** DEPRECATED ***
 *  
 *  Deprecated:
 *    Use NewGestaltValue instead wherever possible.
 *  
 *  Summary:
 *    Replaces the gestalt function associated with a selector.
 *  
 *  Discussion:
 *    The ReplaceGestalt function replaces the selector function
 *    associated with an existing selector code.
 *    
 *    So that your function can call the function previously associated
 *    with the selector, ReplaceGestalt places the address of the old
 *    selector function in the oldGestaltFunction parameter. If
 *    ReplaceGestalt returns an error of any type, then the value of
 *    oldGestaltFunction is undefined.
 *  
 *  Mac OS X threading:
 *    Thread safe since version 10.3
 *  
 *  Parameters:
 *    
 *    selector:
 *      the selector to replace
 *    
 *    gestaltFunction:
 *      a UPP for the new selector function
 *    
 *    oldGestaltFunction:
 *      on exit, a pointer to the UPP of the previously associated with
 *      the specified selector
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework but deprecated in 10.3
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.1 and later
 }
function ReplaceGestalt(selector: OSType; gestaltFunction: SelectorFunctionUPP; var oldGestaltFunction: SelectorFunctionUPP): OSErr; external name '_ReplaceGestalt';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_3 *)

{
 *  NewGestalt()   *** DEPRECATED ***
 *  
 *  Deprecated:
 *    Use NewGestaltValue instead wherever possible.
 *  
 *  Summary:
 *    Adds a selector code to those already recognized by Gestalt.
 *  
 *  Discussion:
 *    The NewGestalt function registers a specified selector code with
 *    the Gestalt Manager so that when the Gestalt function is called
 *    with that selector code, the specified selector function is
 *    executed. Before calling NewGestalt, you must define a selector
 *    function callback. See SelectorFunctionProcPtr for a description
 *    of how to define your selector function.
 *    
 *    Registering with the Gestalt Manager is a way for software such
 *    as system extensions to make their presence known to potential
 *    users of their services.
 *    
 *    In Mac OS X, the selector and replacement value are on a
 *    per-context basis. That means they are available only to the
 *    application or other code that installs them. You cannot use this
 *    function to make information available to another process.
 *     
 *    A Gestalt selector registered with NewGestalt() can not be
 *    deleted.
 *  
 *  Mac OS X threading:
 *    Thread safe since version 10.3
 *  
 *  Parameters:
 *    
 *    selector:
 *      the selector to create
 *    
 *    gestaltFunction:
 *      a UPP for the new selector function, which Gestalt executes
 *      when it receives the new selector code. See
 *      SelectorFunctionProcPtr for more information on the callback
 *      you need to provide.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework but deprecated in 10.3
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.1 and later
 }
function NewGestalt(selector: OSType; gestaltFunction: SelectorFunctionUPP): OSErr; external name '_NewGestalt';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_3 *)

{   The GestaltValue functions are available in System 7.5 and later }

{
 *  NewGestaltValue()
 *  
 *  Summary:
 *    Adds a selector code to those already recognized by Gestalt.
 *  
 *  Discussion:
 *    The NewGestalt function registers a specified selector code with
 *    the Gestalt Manager so that when the Gestalt function is called
 *    with that selector code, the specified selector function is
 *    executed. Before calling NewGestalt, you must define a selector
 *    function callback. See SelectorFunctionProcPtr for a description
 *    of how to define your selector function.
 *    
 *    Registering with the Gestalt Manager is a way for software such
 *    as system extensions to make their presence known to potential
 *    users of their services.
 *    
 *    In Mac OS X, the selector and replacement value are on a
 *    per-context basis. That means they are available only to the
 *    application or other code that installs them. You cannot use this
 *    function to make information available to another process.
 *  
 *  Mac OS X threading:
 *    Thread safe since version 10.3
 *  
 *  Parameters:
 *    
 *    selector:
 *      the selector to create
 *    
 *    newValue:
 *      the value to return for the new selector code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.5 and later
 }
function NewGestaltValue(selector: OSType; newValue: SInt32): OSErr; external name '_NewGestaltValue';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  ReplaceGestaltValue()
 *  
 *  Summary:
 *    Replaces the value that the function Gestalt returns for a
 *    specified selector code with the value provided to the function.
 *  
 *  Discussion:
 *    You use the function ReplaceGestaltValue to replace an existing
 *    value. You should not call this function to introduce a value
 *    that doesn't already exist; instead call the function
 *    NewGestaltValue.
 *    
 *    In Mac OS X, the selector and replacement value are on a
 *    per-context basis. That means they are available only to the
 *    application or other code that installs them. You cannot use this
 *    function to make information available to another process.
 *  
 *  Mac OS X threading:
 *    Thread safe since version 10.3
 *  
 *  Parameters:
 *    
 *    selector:
 *      the selector to create
 *    
 *    replacementValue:
 *      the new value to return for the new selector code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.5 and later
 }
function ReplaceGestaltValue(selector: OSType; replacementValue: SInt32): OSErr; external name '_ReplaceGestaltValue';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  SetGestaltValue()
 *  
 *  Summary:
 *    Sets the value the function Gestalt will return for a specified
 *    selector code, installing the selector if it was not already
 *    installed.
 *  
 *  Discussion:
 *    You use SetGestaltValue to establish a value for a selector,
 *    without regard to whether the selector was already installed.
 *     
 *    In Mac OS X, the selector and replacement value are on a
 *    per-context basis. That means they are available only to the
 *    application or other code that installs them. You cannot use this
 *    function to make information available to another process.
 *  
 *  Mac OS X threading:
 *    Thread safe since version 10.3
 *  
 *  Parameters:
 *    
 *    selector:
 *      the selector to create
 *    
 *    newValue:
 *      the new value to return for the new selector code.
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.5 and later
 }
function SetGestaltValue(selector: OSType; newValue: SInt32): OSErr; external name '_SetGestaltValue';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  DeleteGestaltValue()
 *  
 *  Summary:
 *    Deletes a Gestalt selector code so that it is no longer
 *    recognized by Gestalt.
 *  
 *  Discussion:
 *    After calling this function, subsequent query or replacement
 *    calls for the selector code will fail as if the selector had
 *    never been installed 
 *    
 *    In Mac OS X, the selector and replacement value are on a
 *    per-context basis. That means they are available only to the
 *    application or other code that installs them.
 *  
 *  Mac OS X threading:
 *    Thread safe since version 10.3
 *  
 *  Parameters:
 *    
 *    selector:
 *      the selector to delete
 *  
 *  Availability:
 *    Mac OS X:         in version 10.0 and later in CoreServices.framework
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Non-Carbon CFM:   in InterfaceLib 7.5 and later
 }
function DeleteGestaltValue(selector: OSType): OSErr; external name '_DeleteGestaltValue';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

const
	uppSelectorFunctionProcInfo = $000003E0;
	{
	 *  NewSelectorFunctionUPP()
	 *  
	 *  Availability:
	 *    Non-Carbon CFM:   available as macro/inline
	 *    CarbonLib:        in CarbonLib 1.0 and later
	 *    Mac OS X:         in version 10.0 and later
	 	}
function NewSelectorFunctionUPP(userRoutine: SelectorFunctionProcPtr): SelectorFunctionUPP; external name '_NewSelectorFunctionUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  DisposeSelectorFunctionUPP()
 *  
 *  Availability:
 *    Non-Carbon CFM:   available as macro/inline
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Mac OS X:         in version 10.0 and later
 }
procedure DisposeSelectorFunctionUPP(userUPP: SelectorFunctionUPP); external name '_DisposeSelectorFunctionUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{
 *  InvokeSelectorFunctionUPP()
 *  
 *  Availability:
 *    Non-Carbon CFM:   available as macro/inline
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Mac OS X:         in version 10.0 and later
 }
function InvokeSelectorFunctionUPP(selector: OSType; var response: SInt32; userRoutine: SelectorFunctionUPP): OSErr; external name '_InvokeSelectorFunctionUPP';
(* AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER *)

{ Environment Selectors }

const
	gestaltAddressingModeAttr	= $61646472 (* 'addr' *);						{  addressing mode attributes  }
	gestalt32BitAddressing		= 0;							{  using 32-bit addressing mode  }
	gestalt32BitSysZone			= 1;							{  32-bit compatible system zone  }
	gestalt32BitCapable			= 2;							{  Machine is 32-bit capable  }

	gestaltAFPClient			= $61667073 (* 'afps' *);
	gestaltAFPClientVersionMask	= $0000FFFF;					{  low word of long is the  }
																{  client version 0x0001 -> 0x0007 }
	gestaltAFPClient3_5			= $0001;
	gestaltAFPClient3_6			= $0002;
	gestaltAFPClient3_6_1		= $0003;
	gestaltAFPClient3_6_2		= $0004;
	gestaltAFPClient3_6_3		= $0005;						{  including 3.6.4, 3.6.5 }
	gestaltAFPClient3_7			= $0006;						{  including 3.7.1 }
	gestaltAFPClient3_7_2		= $0007;						{  including 3.7.3, 3.7.4 }
	gestaltAFPClient3_8			= $0008;
	gestaltAFPClient3_8_1		= $0009;						{  including 3.8.2  }
	gestaltAFPClient3_8_3		= $000A;
	gestaltAFPClient3_8_4		= $000B;						{  including 3.8.5, 3.8.6  }
	gestaltAFPClientAttributeMask = $FFFF0000;					{  high word of long is a  }
																{  set of attribute bits }
	gestaltAFPClientCfgRsrc		= 16;							{  Client uses config resources }
	gestaltAFPClientSupportsIP	= 29;							{  Client supports AFP over TCP/IP }
	gestaltAFPClientVMUI		= 30;							{  Client can put up UI from the PBVolMount trap }
	gestaltAFPClientMultiReq	= 31;							{  Client supports multiple outstanding requests }


	gestaltAliasMgrAttr			= $616C6973 (* 'alis' *);						{  Alias Mgr Attributes  }
	gestaltAliasMgrPresent		= 0;							{  True if the Alias Mgr is present  }
	gestaltAliasMgrSupportsRemoteAppletalk = 1;					{  True if the Alias Mgr knows about Remote Appletalk  }
	gestaltAliasMgrSupportsAOCEKeychain = 2;					{  True if the Alias Mgr knows about the AOCE Keychain  }
	gestaltAliasMgrResolveAliasFileWithMountOptions = 3;		{  True if the Alias Mgr implements gestaltAliasMgrResolveAliasFileWithMountOptions() and IsAliasFile()  }
	gestaltAliasMgrFollowsAliasesWhenResolving = 4;
	gestaltAliasMgrSupportsExtendedCalls = 5;
	gestaltAliasMgrSupportsFSCalls = 6;							{  true if Alias Mgr supports HFS+ Calls  }
	gestaltAliasMgrPrefersPath = 7;                             {  True if the Alias Mgr prioritizes the path over file id during resolution by default }
	gestaltAliasMgrRequiresAccessors = 8;                       {  Set if Alias Manager requires accessors for size and usertype }

	{	 Gestalt selector and values for the Appearance Manager 	}
	gestaltAppearanceAttr		= $61707072 (* 'appr' *);
	gestaltAppearanceExists		= 0;
	gestaltAppearanceCompatMode	= 1;

	{	 Gestalt selector for determining Appearance Manager version   	}
	{	 If this selector does not exist, but gestaltAppearanceAttr    	}
	{	 does, it indicates that the 1.0 version is installed. This    	}
	{	 gestalt returns a BCD number representing the version of the  	}
	{	 Appearance Manager that is currently running, e.g. 0x0101 for 	}
	{	 version 1.0.1.                                                	}
	gestaltAppearanceVersion	= $61707672 (* 'apvr' *);

	gestaltArbitorAttr			= $61726220 (* 'arb ' *);
	gestaltSerialArbitrationExists = 0;							{  this bit if the serial port arbitrator exists }

	gestaltAppleScriptVersion	= $61736376 (* 'ascv' *);						{  AppleScript version }

	gestaltAppleScriptAttr		= $61736372 (* 'ascr' *);						{  AppleScript attributes }
	gestaltAppleScriptPresent	= 0;
	gestaltAppleScriptPowerPCSupport = 1;

	gestaltATAAttr				= $61746120 (* 'ata ' *);						{  ATA is the driver to support IDE hard disks  }
	gestaltATAPresent			= 0;							{  if set, ATA Manager is present  }

	gestaltATalkVersion			= $61746B76 (* 'atkv' *);						{  Detailed AppleTalk version; see comment above for format  }

	gestaltAppleTalkVersion		= $61746C6B (* 'atlk' *);						{  appletalk version  }

	{	
	    FORMAT of gestaltATalkVersion RESPONSE
	    --------------------------------------
	    The version is stored in the high three bytes of the response value.  Let us number
	    the bytes in the response value from 0 to 3, where 0 is the least-significant byte.
	
	        Byte#:     3 2 1 0
	        Value:  0xMMNNRR00
	
	    Byte 3 (MM) contains the major revision number, byte 2 (NN) contains the minor
	    revision number, and byte 1 (RR) contains a constant that represents the release
	    stage.  Byte 0 always contains 0x00.  The constants for the release stages are:
	
	        development = 0x20
	        alpha       = 0x40
	        beta        = 0x60
	        final       = 0x80
	        release     = 0x80
	
	    For example, if you call Gestalt with the 'atkv' selector when AppleTalk version 57
	    is loaded, you receive the long SInt16 response value 0x39008000.
		}
	gestaltAUXVersion			= $612F7578 (* 'a/ux' *);						{  a/ux version, if present  }

	gestaltMacOSCompatibilityBoxAttr = $62626F78 (* 'bbox' *);					{  Classic presence and features  }
	gestaltMacOSCompatibilityBoxPresent = 0;					{  True if running under the Classic  }
	gestaltMacOSCompatibilityBoxHasSerial = 1;					{  True if Classic serial support is implemented.  }
	gestaltMacOSCompatibilityBoxless = 2;						{  True if we're Boxless (screen shared with Carbon/Cocoa)  }

	gestaltBusClkSpeed			= $62636C6B (* 'bclk' *);		{  main I/O bus clock speed in hertz  }

	gestaltBusClkSpeedMHz = $62636C6D (* 'bclm' *);             { main I/O bus clock speed in megahertz ( an unsigned long ) }

	gestaltCloseViewAttr		= $42534461 (* 'BSDa' *);						{  CloseView attributes  }
	gestaltCloseViewEnabled		= 0;							{  Closeview enabled (dynamic bit - returns current state)  }
	gestaltCloseViewDisplayMgrFriendly = 1;						{  Closeview compatible with Display Manager (FUTURE)  }

	gestaltCarbonVersion		= $63626F6E (* 'cbon' *);						{  version of Carbon API present in system  }

	gestaltCFMAttr				= $63667267 (* 'cfrg' *);						{  Selector for information about the Code Fragment Manager  }
	gestaltCFMPresent			= 0;							{  True if the Code Fragment Manager is present  }
	gestaltCFMPresentMask		= $0001;
	gestaltCFM99Present			= 2;							{  True if the CFM-99 features are present.  }
	gestaltCFM99PresentMask		= $0004;

	gestaltProcessorCacheLineSize = $6373697A (* 'csiz' *);     { The size, in bytes, of the processor cache line. }

	gestaltCollectionMgrVersion	= $636C746E (* 'cltn' *);						{  Collection Manager version  }

	gestaltColorMatchingAttr	= $636D7461 (* 'cmta' *);						{  ColorSync attributes  }
	gestaltHighLevelMatching	= 0;
	gestaltColorMatchingLibLoaded = 1;

	gestaltColorMatchingVersion	= $636D7463 (* 'cmtc' *);
	gestaltColorSync10			= $0100;						{  0x0100 & 0x0110 _Gestalt versions for 1.0-1.0.3 product  }
	gestaltColorSync11			= $0110;						{    0x0100 == low-level matching only  }
	gestaltColorSync104			= $0104;						{  Real version, by popular demand  }
	gestaltColorSync105			= $0105;
	gestaltColorSync20			= $0200;						{  ColorSync 2.0  }
	gestaltColorSync21			= $0210;
	gestaltColorSync211			= $0211;
	gestaltColorSync212			= $0212;
	gestaltColorSync213			= $0213;
	gestaltColorSync25			= $0250;
	gestaltColorSync26			= $0260;
	gestaltColorSync261			= $0261;
	gestaltColorSync30			= $0300;

	gestaltControlMgrVersion	= $636D7672 (* 'cmvr' *);						{  NOTE: The first version we return is 3.0.1, on Mac OS X plus update 2 }

	gestaltControlMgrAttr		= $636E746C (* 'cntl' *);						{  Control Mgr }
	gestaltControlMgrPresent	= $00000001;					{  NOTE: this is a bit mask, whereas all other Gestalt constants of }
																{  this type are bit index values.   Universal Interfaces 3.2 slipped }
																{  out the door with this mistake. }
	gestaltControlMgrPresentBit	= 0;							{  bit number }
	gestaltControlMsgPresentMask = $00000001;

	gestaltConnMgrAttr			= $636F6E6E (* 'conn' *);						{  connection mgr attributes     }
	gestaltConnMgrPresent		= 0;
	gestaltConnMgrCMSearchFix	= 1;							{  Fix to CMAddSearch?      }
	gestaltConnMgrErrorString	= 2;							{  has CMGetErrorString()  }
	gestaltConnMgrMultiAsyncIO	= 3;							{  CMNewIOPB, CMDisposeIOPB, CMPBRead, CMPBWrite, CMPBIOKill  }

	gestaltColorPickerVersion	= $63706B72 (* 'cpkr' *);						{  returns version of ColorPicker  }
	gestaltColorPicker			= $63706B72 (* 'cpkr' *);						{  gestaltColorPicker is old name for gestaltColorPickerVersion  }

	gestaltComponentMgr			= $63706E74 (* 'cpnt' *);						{  Component Mgr version  }
	gestaltComponentPlatform	= $636F706C (* 'copl' *);						{  Component Platform number  }

	{	
	    The gestaltNativeCPUtype ('cput') selector can be used to determine the
	    native CPU type for all Macs running System 7.5 or later.
	
	    The 'cput' selector is not available when running System 7.0 (or earlier)
	    on most 68K machines.  If 'cput' is not available, then the 'proc' selector
	    should be used to determine the processor type.
	
	    An application should always try the 'cput' selector first.  This is because,
	    on PowerPC machines, the 'proc' selector will reflect the CPU type of the
	    emulator's "virtual processor" rather than the native CPU type.
	
	    The values specified below are accurate.  Prior versions of the Gestalt
	    interface file contained values that were off by one.
	
	    The Quadra 840AV and the Quadra 660AV contain a bug in the ROM code that
	    causes the 'cput' selector to respond with the value 5.  This behavior
	    occurs only when running System 7.1.  System 7.5 fixes the bug by replacing
	    the faulty 'cput' selector function with the correct one.
	
	    The gestaltNativeCPUfamily ('cpuf') selector can be used to determine the
	    general family the native CPU is in. This can be helpful for determing how
	    blitters and things should be written. In general, it is smarter to use this
	    selector (when available) than gestaltNativeCPUtype since newer processors
	    in the same family can be handled without revising your code.
	
	    gestaltNativeCPUfamily uses the same results as gestaltNativeCPUtype, but
	    will only return certain CPU values.
		}
	gestaltNativeCPUtype		= $63707574 (* 'cput' *);						{  Native CPU type                           }
	gestaltNativeCPUfamily		= $63707566 (* 'cpuf' *);						{  Native CPU family                       }
	gestaltCPU68000				= 0;							{  Various 68k CPUs...     }
	gestaltCPU68010				= 1;
	gestaltCPU68020				= 2;
	gestaltCPU68030				= 3;
	gestaltCPU68040				= 4;
	gestaltCPU601				= $0101;						{  IBM 601                                }
	gestaltCPU603				= $0103;
	gestaltCPU604				= $0104;
	gestaltCPU603e				= $0106;
	gestaltCPU603ev				= $0107;
	gestaltCPU750				= $0108;						{  Also 740 - "G3"  }
	gestaltCPU604e				= $0109;
	gestaltCPU604ev				= $010A;						{  Mach 5, 250Mhz and up  }
	gestaltCPUG4				= $010C;						{  Max  }
	gestaltCPUG47450			= $0110;						{  Vger , Altivec  }

	gestaltCPUApollo            = $0111;                        { Apollo , Altivec, G4 7455 }
	gestaltCPUG47447            = $0112;
	gestaltCPU750FX             = $0120;                        { Sahara,G3 like thing }
	gestaltCPU970               = $0139;                        { G5 }
	gestaltCPU970FX             = $013C;                        { another G5 }

																{  x86 CPUs all start with 'i' in the high nybble  }
	gestaltCPU486				= $69343836 (* 'i486' *);
	gestaltCPUPentium			= $69353836 (* 'i586' *);
	gestaltCPUPentiumPro		= $69357072 (* 'i5pr' *);
	gestaltCPUPentiumII			= $69356969 (* 'i5ii' *);
	gestaltCPUX86				= $69787878 (* 'ixxx' *);
	gestaltCPUPentium4          = $69356976 (* 'i5iv' *);


	gestaltCRMAttr				= $63726D20 (* 'crm ' *);						{  comm resource mgr attributes  }
	gestaltCRMPresent			= 0;
	gestaltCRMPersistentFix		= 1;							{  fix for persistent tools  }
	gestaltCRMToolRsrcCalls		= 2;							{  has CRMGetToolResource/ReleaseToolResource  }

	gestaltControlStripVersion	= $63737672 (* 'csvr' *);						{  Control Strip version (was 'sdvr')  }

	gestaltCountOfCPUs          = $63707573 (* 'cpus' *);       { the number of CPUs on the computer, Mac OS X 10.4 and later }

	gestaltCTBVersion			= $63746276 (* 'ctbv' *);						{  CommToolbox version  }

	gestaltDBAccessMgrAttr		= $64626163 (* 'dbac' *);						{  Database Access Mgr attributes  }
	gestaltDBAccessMgrPresent	= 0;							{  True if Database Access Mgr present  }

	gestaltDiskCacheSize		= $6463737A (* 'dcsz' *);						{  Size of disk cache's buffers, in bytes  }

	gestaltSDPFindVersion		= $64666E64 (* 'dfnd' *);						{  OCE Standard Directory Panel }

	gestaltDictionaryMgrAttr	= $64696374 (* 'dict' *);						{  Dictionary Manager attributes  }
	gestaltDictionaryMgrPresent	= 0;							{  Dictionary Manager attributes  }

	gestaltDITLExtAttr			= $6469746C (* 'ditl' *);						{  AppenDITL, etc. calls from CTB  }
	gestaltDITLExtPresent		= 0;							{  True if calls are present  }
	gestaltDITLExtSupportsIctb	= 1;							{  True if AppendDITL, ShortenDITL support 'ictb's  }

	gestaltDialogMgrAttr		= $646C6F67 (* 'dlog' *);						{  Dialog Mgr }
	gestaltDialogMgrPresent		= $00000001;					{  NOTE: this is a bit mask, whereas all other Gestalt constants of }
																{  this type are bit index values.   Universal Interfaces 3.2 slipped }
																{  out the door with this mistake. }
	gestaltDialogMgrPresentBit	= 0;							{  bit number }
	gestaltDialogMgrHasAquaAlertBit = 2;						{  bit number }
	gestaltDialogMgrPresentMask	= $00000001;
	gestaltDialogMgrHasAquaAlertMask = $00000004;
	gestaltDialogMsgPresentMask	= $00000001;					{  compatibility mask }

	gestaltDesktopPicturesAttr	= $646B7078 (* 'dkpx' *);						{  Desktop Pictures attributes  }
	gestaltDesktopPicturesInstalled = 0;						{  True if control panel is installed  }
	gestaltDesktopPicturesDisplayed = 1;						{  True if a picture is currently displayed  }

	gestaltDisplayMgrVers		= $64706C76 (* 'dplv' *);						{  Display Manager version  }

	gestaltDisplayMgrAttr		= $64706C79 (* 'dply' *);						{  Display Manager attributes  }
	gestaltDisplayMgrPresent	= 0;							{  True if Display Mgr is present  }
	gestaltDisplayMgrCanSwitchMirrored = 2;						{  True if Display Mgr can switch modes on mirrored displays  }
	gestaltDisplayMgrSetDepthNotifies = 3;						{  True SetDepth generates displays mgr notification  }
	gestaltDisplayMgrCanConfirm	= 4;							{  True Display Manager supports DMConfirmConfiguration  }
	gestaltDisplayMgrColorSyncAware = 5;						{  True if Display Manager supports profiles for displays  }
	gestaltDisplayMgrGeneratesProfiles = 6;						{  True if Display Manager will automatically generate profiles for displays  }
	gestaltDisplayMgrSleepNotifies = 7;                         {  True if Display Mgr generates "displayWillSleep", "displayDidWake" notifications }

	gestaltDragMgrAttr			= $64726167 (* 'drag' *);						{  Drag Manager attributes  }
	gestaltDragMgrPresent		= 0;							{  Drag Manager is present  }
	gestaltDragMgrFloatingWind	= 1;							{  Drag Manager supports floating windows  }
	gestaltPPCDragLibPresent	= 2;							{  Drag Manager PPC DragLib is present  }
	gestaltDragMgrHasImageSupport = 3;							{  Drag Manager allows SetDragImage call  }
	gestaltCanStartDragInFloatWindow = 4;						{  Drag Manager supports starting a drag in a floating window  }
	gestaltSetDragImageUpdates	= 5;							{  Drag Manager supports drag image updating via SetDragImage  }

	gestaltDrawSprocketVersion	= $64737076 (* 'dspv' *);						{  Draw Sprocket version (as a NumVersion)  }

	gestaltDigitalSignatureVersion = $64736967 (* 'dsig' *);					{  returns Digital Signature Toolbox version in low-order word }

	{
	   Desktop Printing Feature Gestalt
	   Use this gestalt to check if third-party printer driver support is available
	}
	gestaltDTPFeatures			= $64747066 (* 'dtpf' *);
	kDTPThirdPartySupported		= $00000004;					{  mask for checking if third-party drivers are supported }


	{
	   Desktop Printer Info Gestalt
	   Use this gestalt to get a hold of information for all of the active desktop printers
	}
	gestaltDTPInfo				= $64747078 (* 'dtpx' *);						{  returns GestaltDTPInfoHdle }

	gestaltEasyAccessAttr		= $65617379 (* 'easy' *);						{  Easy Access attributes  }
	gestaltEasyAccessOff		= 0;							{  if Easy Access present, but off (no icon)  }
	gestaltEasyAccessOn			= 1;							{  if Easy Access "On"  }
	gestaltEasyAccessSticky		= 2;							{  if Easy Access "Sticky"  }
	gestaltEasyAccessLocked		= 3;							{  if Easy Access "Locked"  }

	gestaltEditionMgrAttr		= $6564746E (* 'edtn' *);						{  Edition Mgr attributes  }
	gestaltEditionMgrPresent	= 0;							{  True if Edition Mgr present  }
	gestaltEditionMgrTranslationAware = 1;						{  True if edition manager is translation manager aware  }

	gestaltAppleEventsAttr		= $65766E74 (* 'evnt' *);						{  Apple Events attributes  }
	gestaltAppleEventsPresent	= 0;							{  True if Apple Events present  }
	gestaltScriptingSupport		= 1;
	gestaltOSLInSystem			= 2;							{  OSL is in system so don�t use the one linked in to app  }
	gestaltSupportsApplicationURL = 4;							{  Supports the typeApplicationURL addressing mode  }

	gestaltExtensionTableVersion = $6574626C (* 'etbl' *);						{  ExtensionTable version  }


	gestaltFBCIndexingState		= $66626369 (* 'fbci' *);						{  Find By Content indexing state }
	gestaltFBCindexingSafe		= 0;							{  any search will result in synchronous wait }
	gestaltFBCindexingCritical	= 1;							{  any search will execute immediately }

	gestaltFBCVersion			= $66626376 (* 'fbcv' *);						{  Find By Content version }
	gestaltFBCCurrentVersion	= $0011;						{  First release for OS 8/9 }
	gestaltOSXFBCCurrentVersion	= $0100;						{  First release for OS X }


	gestaltFileMappingAttr		= $666C6D70 (* 'flmp' *);						{  File mapping attributes }
	gestaltFileMappingPresent	= 0;							{  bit is set if file mapping APIs are present }
	gestaltFileMappingMultipleFilesFix = 1;						{  bit is set if multiple files per volume can be mapped }

	gestaltFloppyAttr			= $666C7079 (* 'flpy' *);						{  Floppy disk drive/driver attributes  }
	gestaltFloppyIsMFMOnly		= 0;							{  Floppy driver only supports MFM disk formats  }
	gestaltFloppyIsManualEject	= 1;							{  Floppy drive, driver, and file system are in manual-eject mode  }
	gestaltFloppyUsesDiskInPlace = 2;							{  Floppy drive must have special DISK-IN-PLACE output; standard DISK-CHANGED not used  }

	gestaltFinderAttr			= $666E6472 (* 'fndr' *);						{  Finder attributes  }
	gestaltFinderDropEvent		= 0;							{  Finder recognizes drop event  }
	gestaltFinderMagicPlacement	= 1;							{  Finder supports magic icon placement  }
	gestaltFinderCallsAEProcess	= 2;							{  Finder calls AEProcessAppleEvent  }
	gestaltOSLCompliantFinder	= 3;							{  Finder is scriptable and recordable  }
	gestaltFinderSupports4GBVolumes = 4;						{  Finder correctly handles 4GB volumes  }
	gestaltFinderHasClippings	= 6;							{  Finder supports Drag Manager clipping files  }
	gestaltFinderFullDragManagerSupport = 7;					{  Finder accepts 'hfs ' flavors properly  }
	gestaltFinderFloppyRootComments = 8;						{  in MacOS 8 and later, will be set if Finder ever supports comments on Floppy icons  }
	gestaltFinderLargeAndNotSavedFlavorsOK = 9;					{  in MacOS 8 and later, this bit is set if drags with >1024-byte flavors and flavorNotSaved flavors work reliably  }
	gestaltFinderUsesExtensibleFolderManager = 10;				{  Finder uses Extensible Folder Manager (for example, for Magic Routing)  }
	gestaltFinderUnderstandsRedirectedDesktopFolder = 11;		{  Finder deals with startup disk's desktop folder residing on another disk  }

	gestaltFindFolderAttr		= $666F6C64 (* 'fold' *);						{  Folder Mgr attributes  }
	gestaltFindFolderPresent	= 0;							{  True if Folder Mgr present  }
	gestaltFolderDescSupport	= 1;							{  True if Folder Mgr has FolderDesc calls  }
	gestaltFolderMgrFollowsAliasesWhenResolving = 2;			{  True if Folder Mgr follows folder aliases  }
	gestaltFolderMgrSupportsExtendedCalls = 3;					{  True if Folder Mgr supports the Extended calls  }
	gestaltFolderMgrSupportsDomains = 4;						{  True if Folder Mgr supports domains for the first parameter to FindFolder  }
	gestaltFolderMgrSupportsFSCalls = 5;						{  True if FOlder manager supports __FindFolderFSRef & __FindFolderExtendedFSRef  }

	gestaltFindFolderRedirectionAttr = $666F6C65 (* 'fole' *);


	gestaltFontMgrAttr			= $666F6E74 (* 'font' *);						{  Font Mgr attributes  }
	gestaltOutlineFonts			= 0;							{  True if Outline Fonts supported  }

	gestaltFPUType				= $66707520 (* 'fpu ' *);						{  fpu type  }
	gestaltNoFPU				= 0;							{  no FPU  }
	gestalt68881				= 1;							{  68881 FPU  }
	gestalt68882				= 2;							{  68882 FPU  }
	gestalt68040FPU				= 3;							{  68040 built-in FPU  }

	gestaltFSAttr				= $66732020 (* 'fs  ' *);						{  file system attributes  }
	gestaltFullExtFSDispatching	= 0;							{  has really cool new HFSDispatch dispatcher  }
	gestaltHasFSSpecCalls		= 1;							{  has FSSpec calls  }
	gestaltHasFileSystemManager	= 2;							{  has a file system manager  }
	gestaltFSMDoesDynamicLoad	= 3;							{  file system manager supports dynamic loading  }
	gestaltFSSupports4GBVols	= 4;							{  file system supports 4 gigabyte volumes  }
	gestaltFSSupports2TBVols	= 5;							{  file system supports 2 terabyte volumes  }
	gestaltHasExtendedDiskInit	= 6;							{  has extended Disk Initialization calls  }
	gestaltDTMgrSupportsFSM		= 7;							{  Desktop Manager support FSM-based foreign file systems  }
	gestaltFSNoMFSVols			= 8;							{  file system doesn't supports MFS volumes  }
	gestaltFSSupportsHFSPlusVols = 9;							{  file system supports HFS Plus volumes  }
	gestaltFSIncompatibleDFA82	= 10;							{  VCB and FCB structures changed; DFA 8.2 is incompatible  }

	gestaltFSSupportsDirectIO   = 11;                           {  file system supports DirectIO }

	gestaltHasHFSPlusAPIs		= 12;							{  file system supports HFS Plus APIs  }
	gestaltMustUseFCBAccessors	= 13;							{  FCBSPtr and FSFCBLen are invalid - must use FSM FCB accessor functions }
	gestaltFSUsesPOSIXPathsForConversion = 14;					{  The path interchange routines operate on POSIX paths instead of HFS paths  }
	gestaltFSSupportsExclusiveLocks = 15;                       {  File system uses POSIX O_EXLOCK for opens }
	gestaltFSSupportsHardLinkDetection = 16;                    {  File system returns if an item is a hard link }
	gestaltFSAllowsConcurrentAsyncIO = 17;                      {  File Manager supports concurrent async reads and writes }

	gestaltAdminFeaturesFlagsAttr = $66726564 (* 'fred' *);						{  a set of admin flags, mostly useful internally.  }
	gestaltFinderUsesSpecialOpenFoldersFile = 0;				{  the Finder uses a special file to store the list of open folders  }

	gestaltFSMVersion			= $66736D20 (* 'fsm ' *);						{  returns version of HFS External File Systems Manager (FSM)  }

	gestaltFXfrMgrAttr			= $66786672 (* 'fxfr' *);						{  file transfer manager attributes  }
	gestaltFXfrMgrPresent		= 0;
	gestaltFXfrMgrMultiFile		= 1;							{  supports FTSend and FTReceive  }
	gestaltFXfrMgrErrorString	= 2;							{  supports FTGetErrorString  }
	gestaltFXfrMgrAsync			= 3;							{ supports FTSendAsync, FTReceiveAsync, FTCompletionAsync }

	gestaltGraphicsAttr			= $67667861 (* 'gfxa' *);						{  Quickdraw GX attributes selector  }
	gestaltGraphicsIsDebugging	= $00000001;
	gestaltGraphicsIsLoaded		= $00000002;
	gestaltGraphicsIsPowerPC	= $00000004;

	gestaltGraphicsVersion		= $67726678 (* 'grfx' *);						{  Quickdraw GX version selector  }
	gestaltCurrentGraphicsVersion = $00010200;					{  the version described in this set of headers  }

	gestaltHardwareAttr			= $68647772 (* 'hdwr' *);						{  hardware attributes  }
	gestaltHasVIA1				= 0;							{  VIA1 exists  }
	gestaltHasVIA2				= 1;							{  VIA2 exists  }
	gestaltHasASC				= 3;							{  Apple Sound Chip exists  }
	gestaltHasSCC				= 4;							{  SCC exists  }
	gestaltHasSCSI				= 7;							{  SCSI exists  }
	gestaltHasSoftPowerOff		= 19;							{  Capable of software power off  }
	gestaltHasSCSI961			= 21;							{  53C96 SCSI controller on internal bus  }
	gestaltHasSCSI962			= 22;							{  53C96 SCSI controller on external bus  }
	gestaltHasUniversalROM		= 24;							{  Do we have a Universal ROM?  }
	gestaltHasEnhancedLtalk		= 30;							{  Do we have Enhanced LocalTalk?  }

	gestaltHelpMgrAttr			= $68656C70 (* 'help' *);						{  Help Mgr Attributes  }
	gestaltHelpMgrPresent		= 0;							{  true if help mgr is present  }
	gestaltHelpMgrExtensions	= 1;							{  true if help mgr extensions are installed  }
	gestaltAppleGuideIsDebug	= 30;
	gestaltAppleGuidePresent	= 31;							{  true if AppleGuide is installed  }

	gestaltHardwareVendorCode	= $68726164 (* 'hrad' *);						{  Returns hardware vendor information  }
	gestaltHardwareVendorApple	= $4170706C (* 'Appl' *);						{  Hardware built by Apple  }

	gestaltCompressionMgr		= $69636D70 (* 'icmp' *);						{  returns version of the Image Compression Manager  }

	gestaltIconUtilitiesAttr	= $69636F6E (* 'icon' *);						{  Icon Utilities attributes  (Note: available in System 7.0, despite gestalt)  }
	gestaltIconUtilitiesPresent	= 0;							{  true if icon utilities are present  }
	gestaltIconUtilitiesHas48PixelIcons = 1;					{  true if 48x48 icons are supported by IconUtilities  }
	gestaltIconUtilitiesHas32BitIcons = 2;						{  true if 32-bit deep icons are supported  }
	gestaltIconUtilitiesHas8BitDeepMasks = 3;					{  true if 8-bit deep masks are supported  }
	gestaltIconUtilitiesHasIconServices = 4;					{  true if IconServices is present  }

	gestaltInternalDisplay		= $69647370 (* 'idsp' *);						{  slot number of internal display location  }

	{	
	    To obtain information about the connected keyboard(s), one should
	    use the ADB Manager API.  See Technical Note OV16 for details.
		}
	gestaltKeyboardType			= $6B626420 (* 'kbd ' *);						{  keyboard type  }
	gestaltMacKbd				= 1;
	gestaltMacAndPad			= 2;
	gestaltMacPlusKbd			= 3;
	gestaltExtADBKbd			= 4;
	gestaltStdADBKbd			= 5;
	gestaltPrtblADBKbd			= 6;
	gestaltPrtblISOKbd			= 7;
	gestaltStdISOADBKbd			= 8;
	gestaltExtISOADBKbd			= 9;
	gestaltADBKbdII				= 10;
	gestaltADBISOKbdII			= 11;
	gestaltPwrBookADBKbd		= 12;
	gestaltPwrBookISOADBKbd		= 13;
	gestaltAppleAdjustKeypad	= 14;
	gestaltAppleAdjustADBKbd	= 15;
	gestaltAppleAdjustISOKbd	= 16;
	gestaltJapanAdjustADBKbd	= 17;							{  Japan Adjustable Keyboard  }
	gestaltPwrBkExtISOKbd		= 20;							{  PowerBook Extended International Keyboard with function keys  }
	gestaltPwrBkExtJISKbd		= 21;							{  PowerBook Extended Japanese Keyboard with function keys       }
	gestaltPwrBkExtADBKbd		= 24;							{  PowerBook Extended Domestic Keyboard with function keys       }
	gestaltPS2Keyboard			= 27;							{  PS2 keyboard  }
	gestaltPwrBkSubDomKbd		= 28;							{  PowerBook Subnote Domestic Keyboard with function keys w/  inverted T   }
	gestaltPwrBkSubISOKbd		= 29;							{  PowerBook Subnote International Keyboard with function keys w/  inverted T      }
	gestaltPwrBkSubJISKbd		= 30;							{  PowerBook Subnote Japanese Keyboard with function keys w/ inverted T     }
	gestaltPortableUSBANSIKbd   = 37;                           {  Powerbook USB-based internal keyboard, ANSI layout }
	gestaltPortableUSBISOKbd    = 38;                           {  Powerbook USB-based internal keyboard, ISO layout }
	gestaltPortableUSBJISKbd    = 39;                           {  Powerbook USB-based internal keyboard, JIS layout }
	gestaltThirdPartyANSIKbd    = 40;                           {  Third party keyboard, ANSI layout.  Returned in Mac OS X Tiger and later. }
	gestaltThirdPartyISOKbd     = 41;                           {  Third party keyboard, ISO layout. Returned in Mac OS X Tiger and later. }
	gestaltThirdPartyJISKbd     = 42;                           {  Third party keyboard, JIS layout. Returned in Mac OS X Tiger and later. }
	gestaltPwrBkEKDomKbd		= 195;							{  (0xC3) PowerBook Domestic Keyboard with Embedded Keypad, function keys & inverted T     }
	gestaltPwrBkEKISOKbd		= 196;							{  (0xC4) PowerBook International Keyboard with Embedded Keypad, function keys & inverted T    }
	gestaltPwrBkEKJISKbd		= 197;							{  (0xC5) PowerBook Japanese Keyboard with Embedded Keypad, function keys & inverted T       }
	gestaltUSBCosmoANSIKbd		= 198;							{  (0xC6) original USB Domestic (ANSI) Keyboard  }
	gestaltUSBCosmoISOKbd		= 199;							{  (0xC7) original USB International (ISO) Keyboard  }
	gestaltUSBCosmoJISKbd		= 200;							{  (0xC8) original USB Japanese (JIS) Keyboard  }
	gestaltPwrBk99JISKbd		= 201;							{  (0xC9) '99 PowerBook JIS Keyboard with Embedded Keypad, function keys & inverted T                }
	gestaltUSBAndyANSIKbd		= 204;							{  (0xCC) USB Pro Keyboard Domestic (ANSI) Keyboard                                  }
	gestaltUSBAndyISOKbd		= 205;							{  (0xCD) USB Pro Keyboard International (ISO) Keyboard                                }
	gestaltUSBAndyJISKbd		= 206;							{  (0xCE) USB Pro Keyboard Japanese (JIS) Keyboard                                     }

	gestaltPortable2001ANSIKbd  = 202;                          {  (0xCA) PowerBook and iBook Domestic (ANSI) Keyboard with 2nd cmd key right & function key moves.     }
	gestaltPortable2001ISOKbd   = 203;                          {  (0xCB) PowerBook and iBook International (ISO) Keyboard with 2nd cmd key right & function key moves.   }
	gestaltPortable2001JISKbd   = 207;                          {  (0xCF) PowerBook and iBook Japanese (JIS) Keyboard with function key moves.                   }

	gestaltUSBProF16ANSIKbd     = 34;                           {  (0x22) USB Pro Keyboard w/ F16 key Domestic (ANSI) Keyboard }
	gestaltUSBProF16ISOKbd      = 35;                           {  (0x23) USB Pro Keyboard w/ F16 key International (ISO) Keyboard }
	gestaltUSBProF16JISKbd      = 36;                           {  (0x24) USB Pro Keyboard w/ F16 key Japanese (JIS) Keyboard }
	gestaltProF16ANSIKbd        = 31;                           {  (0x1F) Pro Keyboard w/F16 key Domestic (ANSI) Keyboard }
	gestaltProF16ISOKbd         = 32;                           {  (0x20) Pro Keyboard w/F16 key International (ISO) Keyboard }
	gestaltProF16JISKbd         = 33;                           {  (0x21) Pro Keyboard w/F16 key Japanese (JIS) Keyboard }

	{
	    This gestalt indicates the highest UDF version that the active UDF implementation supports.
	    The value should be assembled from a read version (upper word) and a write version (lower word)
	}
	gestaltUDFSupport			= $6B756466 (* 'kudf' *);						{     Used for communication between UDF implementations }

	gestaltLowMemorySize		= $6C6D656D (* 'lmem' *);						{  size of low memory area  }

	gestaltLogicalRAMSize		= $6C72616D (* 'lram' *);						{  logical ram size  }

	{	
	    MACHINE type CONSTANTS NAMING CONVENTION
	
	        All future machine type constant names take the following form:
	
	            gestalt<lineName><modelNumber>
	
	    Line Names
	
	        The following table contains the lines currently produced by Apple and the
	        lineName substrings associated with them:
	
	            Line                        lineName
	            -------------------------   ------------
	            Macintosh LC                "MacLC"
	            Macintosh Performa          "Performa"
	            Macintosh PowerBook         "PowerBook"
	            Macintosh PowerBook Duo     "PowerBookDuo"
	            Power Macintosh             "PowerMac"
	            Apple Workgroup Server      "AWS"
	
	        The following table contains lineNames for some discontinued lines:
	
	            Line                        lineName
	            -------------------------   ------------
	            Macintosh Quadra            "MacQuadra" (preferred)
	                                        "Quadra" (also used, but not preferred)
	            Macintosh Centris           "MacCentris"
	
	    Model Numbers
	
	        The modelNumber is a string representing the specific model of the machine
	        within its particular line.  For example, for the Power Macintosh 8100/80,
	        the modelNumber is "8100".
	
	        Some Performa & LC model numbers contain variations in the rightmost 1 or 2
	        digits to indicate different RAM and Hard Disk configurations.  A single
	        machine type is assigned for all variations of a specific model number.  In
	        this case, the modelNumber string consists of the constant leftmost part
	        of the model number with 0s for the variant digits.  For example, the
	        Performa 6115 and Performa 6116 are both return the same machine type
	        constant:  gestaltPerforma6100.
	
	
	    OLD NAMING CONVENTIONS
	
	    The "Underscore Speed" suffix
	
	        In the past, Apple differentiated between machines that had the same model
	        number but different speeds.  For example, the Power Macintosh 8100/80 and
	        Power Macintosh 8100/100 return different machine type constants.  This is
	        why some existing machine type constant names take the form:
	
	            gestalt<lineName><modelNumber>_<speed>
	
	        e.g.
	
	            gestaltPowerMac8100_110
	            gestaltPowerMac7100_80
	            gestaltPowerMac7100_66
	
	        It is no longer necessary to use the "underscore speed" suffix.  Starting with
	        the Power Surge machines (Power Macintosh 7200, 7500, 8500 and 9500), speed is
	        no longer used to differentiate between machine types.  This is why a Power
	        Macintosh 7200/75 and a Power Macintosh 7200/90 return the same machine type
	        constant:  gestaltPowerMac7200.
	
	    The "Screen Type" suffix
	
	        All PowerBook models prior to the PowerBook 190, and all PowerBook Duo models
	        before the PowerBook Duo 2300 take the form:
	
	            gestalt<lineName><modelNumber><screenType>
	
	        Where <screenType> is "c" or the empty string.
	
	        e.g.
	
	            gestaltPowerBook100
	            gestaltPowerBookDuo280
	            gestaltPowerBookDuo280c
	            gestaltPowerBook180
	            gestaltPowerBook180c
	
	        Starting with the PowerBook 190 series and the PowerBook Duo 2300 series, machine
	        types are no longer differentiated based on screen type.  This is why a PowerBook
	        5300cs/100 and a PowerBook 5300c/100 both return the same machine type constant:
	        gestaltPowerBook5300.
	
	        Macintosh LC 630                gestaltMacLC630
	        Macintosh Performa 6200         gestaltPerforma6200
	        Macintosh Quadra 700            gestaltQuadra700
	        Macintosh PowerBook 5300        gestaltPowerBook5300
	        Macintosh PowerBook Duo 2300    gestaltPowerBookDuo2300
	        Power Macintosh 8500            gestaltPowerMac8500
		}

	gestaltMachineType			= $6D616368 (* 'mach' *);						{  machine type  }
	gestaltClassic				= 1;
	gestaltMacXL				= 2;
	gestaltMac512KE				= 3;
	gestaltMacPlus				= 4;
	gestaltMacSE				= 5;
	gestaltMacII				= 6;
	gestaltMacIIx				= 7;
	gestaltMacIIcx				= 8;
	gestaltMacSE030				= 9;
	gestaltPortable				= 10;
	gestaltMacIIci				= 11;
	gestaltPowerMac8100_120		= 12;
	gestaltMacIIfx				= 13;
	gestaltMacClassic			= 17;
	gestaltMacIIsi				= 18;
	gestaltMacLC				= 19;
	gestaltMacQuadra900			= 20;
	gestaltPowerBook170			= 21;
	gestaltMacQuadra700			= 22;
	gestaltClassicII			= 23;
	gestaltPowerBook100			= 24;
	gestaltPowerBook140			= 25;
	gestaltMacQuadra950			= 26;
	gestaltMacLCIII				= 27;
	gestaltPerforma450			= 27;
	gestaltPowerBookDuo210		= 29;
	gestaltMacCentris650		= 30;
	gestaltPowerBookDuo230		= 32;
	gestaltPowerBook180			= 33;
	gestaltPowerBook160			= 34;
	gestaltMacQuadra800			= 35;
	gestaltMacQuadra650			= 36;
	gestaltMacLCII				= 37;
	gestaltPowerBookDuo250		= 38;
	gestaltAWS9150_80			= 39;
	gestaltPowerMac8100_110		= 40;
	gestaltAWS8150_110			= 40;
	gestaltPowerMac5200			= 41;
	gestaltPowerMac5260			= 41;
	gestaltPerforma5300			= 41;
	gestaltPowerMac6200			= 42;
	gestaltPerforma6300			= 42;
	gestaltMacIIvi				= 44;
	gestaltMacIIvm				= 45;
	gestaltPerforma600			= 45;
	gestaltPowerMac7100_80		= 47;
	gestaltMacIIvx				= 48;
	gestaltMacColorClassic		= 49;
	gestaltPerforma250			= 49;
	gestaltPowerBook165c		= 50;
	gestaltMacCentris610		= 52;
	gestaltMacQuadra610			= 53;
	gestaltPowerBook145			= 54;
	gestaltPowerMac8100_100		= 55;
	gestaltMacLC520				= 56;
	gestaltAWS9150_120			= 57;
	gestaltPowerMac6400			= 58;
	gestaltPerforma6400			= 58;
	gestaltPerforma6360			= 58;
	gestaltMacCentris660AV		= 60;
	gestaltMacQuadra660AV		= 60;
	gestaltPerforma46x			= 62;
	gestaltPowerMac8100_80		= 65;
	gestaltAWS8150_80			= 65;
	gestaltPowerMac9500			= 67;
	gestaltPowerMac9600			= 67;
	gestaltPowerMac7500			= 68;
	gestaltPowerMac7600			= 68;
	gestaltPowerMac8500			= 69;
	gestaltPowerMac8600			= 69;
	gestaltAWS8550				= 68;
	gestaltPowerBook180c		= 71;
	gestaltPowerBook520			= 72;
	gestaltPowerBook520c		= 72;
	gestaltPowerBook540			= 72;
	gestaltPowerBook540c		= 72;
	gestaltPowerMac5400			= 74;
	gestaltPowerMac6100_60		= 75;
	gestaltAWS6150_60			= 75;
	gestaltPowerBookDuo270c		= 77;
	gestaltMacQuadra840AV		= 78;
	gestaltPerforma550			= 80;
	gestaltPowerBook165			= 84;
	gestaltPowerBook190			= 85;
	gestaltMacTV				= 88;
	gestaltMacLC475				= 89;
	gestaltPerforma47x			= 89;
	gestaltMacLC575				= 92;
	gestaltMacQuadra605			= 94;
	gestaltMacQuadra630			= 98;
	gestaltMacLC580				= 99;
	gestaltPerforma580			= 99;
	gestaltPowerMac6100_66		= 100;
	gestaltAWS6150_66			= 100;
	gestaltPowerBookDuo280		= 102;
	gestaltPowerBookDuo280c		= 103;
	gestaltPowerMacLC475		= 104;							{  Mac LC 475 & PPC Processor Upgrade Card }
	gestaltPowerMacPerforma47x	= 104;
	gestaltPowerMacLC575		= 105;							{  Mac LC 575 & PPC Processor Upgrade Card  }
	gestaltPowerMacPerforma57x	= 105;
	gestaltPowerMacQuadra630	= 106;							{  Quadra 630 & PPC Processor Upgrade Card }
	gestaltPowerMacLC630		= 106;							{  Mac LC 630 & PPC Processor Upgrade Card }
	gestaltPowerMacPerforma63x	= 106;							{  Performa 63x & PPC Processor Upgrade Card }
	gestaltPowerMac7200			= 108;
	gestaltPowerMac7300			= 109;
	gestaltPowerMac7100_66		= 112;
	gestaltPowerBook150			= 115;
	gestaltPowerMacQuadra700	= 116;							{  Quadra 700 & Power PC Upgrade Card }
	gestaltPowerMacQuadra900	= 117;							{  Quadra 900 & Power PC Upgrade Card  }
	gestaltPowerMacQuadra950	= 118;							{  Quadra 950 & Power PC Upgrade Card  }
	gestaltPowerMacCentris610	= 119;							{  Centris 610 & Power PC Upgrade Card  }
	gestaltPowerMacCentris650	= 120;							{  Centris 650 & Power PC Upgrade Card  }
	gestaltPowerMacQuadra610	= 121;							{  Quadra 610 & Power PC Upgrade Card  }
	gestaltPowerMacQuadra650	= 122;							{  Quadra 650 & Power PC Upgrade Card  }
	gestaltPowerMacQuadra800	= 123;							{  Quadra 800 & Power PC Upgrade Card  }
	gestaltPowerBookDuo2300		= 124;
	gestaltPowerBook500PPCUpgrade = 126;
	gestaltPowerBook5300		= 128;
	gestaltPowerBook1400		= 310;
	gestaltPowerBook3400		= 306;
	gestaltPowerBook2400		= 307;
	gestaltPowerBookG3Series	= 312;
	gestaltPowerBookG3			= 313;
	gestaltPowerBookG3Series2	= 314;
	gestaltPowerMacNewWorld		= 406;							{  All NewWorld architecture Macs (iMac, blue G3, etc.) }
	gestaltPowerMacG3			= 510;
	gestaltPowerMac5500			= 512;
	gestalt20thAnniversary		= 512;
	gestaltPowerMac6500			= 513;
	gestaltPowerMac4400_160		= 514;							{  slower machine has different machine ID }
	gestaltPowerMac4400			= 515;
	gestaltMacOSCompatibility	= 1206;							{     Mac OS Compatibility on Mac OS X (Classic) }


	gestaltQuadra605			= 94;
	gestaltQuadra610			= 53;
	gestaltQuadra630			= 98;
	gestaltQuadra650			= 36;
	gestaltQuadra660AV			= 60;
	gestaltQuadra700			= 22;
	gestaltQuadra800			= 35;
	gestaltQuadra840AV			= 78;
	gestaltQuadra900			= 20;
	gestaltQuadra950			= 26;

	kMachineNameStrID			= -16395;

	gestaltSMPMailerVersion		= $6D616C72 (* 'malr' *);						{  OCE StandardMail }

	gestaltMediaBay				= $6D626568 (* 'mbeh' *);						{  media bay driver type  }
	gestaltMBLegacy				= 0;							{  media bay support in PCCard 2.0  }
	gestaltMBSingleBay			= 1;							{  single bay media bay driver  }
	gestaltMBMultipleBays		= 2;							{  multi-bay media bay driver  }

	gestaltMessageMgrVersion	= $6D657373 (* 'mess' *);						{  GX Printing Message Manager Gestalt Selector  }


	{   Menu Manager Gestalt (Mac OS 8.5 and later) }
	gestaltMenuMgrAttr			= $6D656E75 (* 'menu' *);						{  If this Gestalt exists, the Mac OS 8.5 Menu Manager is installed  }
	gestaltMenuMgrPresent		= $00000001;					{  NOTE: this is a bit mask, whereas all other Gestalt constants of this nature  }
																{  are bit index values. 3.2 interfaces slipped out with this mistake unnoticed.  }
																{  Sincere apologies for any inconvenience. }
	gestaltMenuMgrPresentBit	= 0;							{  bit number  }
	gestaltMenuMgrAquaLayoutBit	= 1;							{  menus have the Aqua 1.0 layout }
	gestaltMenuMgrMultipleItemsWithCommandIDBit = 2;			{  CountMenuItemsWithCommandID/GetIndMenuItemWithCommandID support multiple items with the same command ID }
	gestaltMenuMgrRetainsIconRefBit = 3;						{  SetMenuItemIconHandle, when passed an IconRef, calls AcquireIconRef }
	gestaltMenuMgrSendsMenuBoundsToDefProcBit = 4;				{  kMenuSizeMsg and kMenuPopUpMsg have menu bounding rect information }
	gestaltMenuMgrMoreThanFiveMenusDeepBit = 5;                 {  the Menu Manager supports hierarchical menus more than five deep}
	gestaltMenuMgrCGImageMenuTitleBit = 6;                      {  SetMenuTitleIcon supports CGImageRefs}
																{  masks for the above bits }
	gestaltMenuMgrPresentMask	= $00000001;
	gestaltMenuMgrAquaLayoutMask = $00000002;
	gestaltMenuMgrMultipleItemsWithCommandIDMask = $00000004;
	gestaltMenuMgrRetainsIconRefMask = $00000008;
	gestaltMenuMgrSendsMenuBoundsToDefProcMask = $00000010;
	gestaltMenuMgrMoreThanFiveMenusDeepMask = 1 shl gestaltMenuMgrMoreThanFiveMenusDeepBit;
	gestaltMenuMgrCGImageMenuTitleMask = 1 shl gestaltMenuMgrCGImageMenuTitleBit;


	gestaltMultipleUsersState	= $6D666472 (* 'mfdr' *);						{  Gestalt selector returns MultiUserGestaltHandle (in Folders.h) }


	gestaltMachineIcon			= $6D69636E (* 'micn' *);						{  machine icon  }

	gestaltMiscAttr				= $6D697363 (* 'misc' *);						{  miscellaneous attributes  }
	gestaltScrollingThrottle	= 0;							{  true if scrolling throttle on  }
	gestaltSquareMenuBar		= 2;							{  true if menu bar is square  }


	{	
	    The name gestaltMixedModeVersion for the 'mixd' selector is semantically incorrect.
	    The same selector has been renamed gestaltMixedModeAttr to properly reflect the
	    Inside Mac: PowerPC System Software documentation.  The gestaltMixedModeVersion
	    symbol has been preserved only for backwards compatibility.
	
	    Developers are forewarned that gestaltMixedModeVersion has a limited lifespan and
	    will be removed in a future release of the Interfaces.
	
	    For the first version of Mixed Mode, both meanings of the 'mixd' selector are
	    functionally identical.  They both return 0x00000001.  In subsequent versions
	    of Mixed Mode, however, the 'mixd' selector will not respond with an increasing
	    version number, but rather, with 32 attribute bits with various meanings.
		}
	gestaltMixedModeVersion		= $6D697864 (* 'mixd' *);						{  returns version of Mixed Mode  }

	gestaltMixedModeAttr		= $6D697864 (* 'mixd' *);						{  returns Mixed Mode attributes  }
	gestaltMixedModePowerPC		= 0;							{  true if Mixed Mode supports PowerPC ABI calling conventions  }
	gestaltPowerPCAware			= 0;							{  old name for gestaltMixedModePowerPC  }
	gestaltMixedModeCFM68K		= 1;							{  true if Mixed Mode supports CFM-68K calling conventions  }
	gestaltMixedModeCFM68KHasTrap = 2;							{  true if CFM-68K Mixed Mode implements _MixedModeDispatch (versions 1.0.1 and prior did not)  }
	gestaltMixedModeCFM68KHasState = 3;							{  true if CFM-68K Mixed Mode exports Save/RestoreMixedModeState  }

	gestaltQuickTimeConferencing = $6D746C6B (* 'mtlk' *);						{  returns QuickTime Conferencing version  }

	gestaltMemoryMapAttr		= $6D6D6170 (* 'mmap' *);						{  Memory map type  }
	gestaltMemoryMapSparse		= 0;							{  Sparse memory is on  }

	gestaltMMUType				= $6D6D7520 (* 'mmu ' *);						{  mmu type  }
	gestaltNoMMU				= 0;							{  no MMU  }
	gestaltAMU					= 1;							{  address management unit  }
	gestalt68851				= 2;							{  68851 PMMU  }
	gestalt68030MMU				= 3;							{  68030 built-in MMU  }
	gestalt68040MMU				= 4;							{  68040 built-in MMU  }
	gestaltEMMU1				= 5;							{  Emulated MMU type 1   }

                                                                { On Mac OS X, the user visible machine name may something like "PowerMac3,4", which is}
                                                                { a unique string for each signifigant Macintosh computer which Apple creates, but is}
                                                                { not terribly useful as a user visible string.}
	gestaltUserVisibleMachineName = $6D6E616D (* 'mnam' *);						{  Coerce response into a StringPtr to get a user visible machine name  }

	gestaltMPCallableAPIsAttr	= $6D707363 (* 'mpsc' *);						{  Bitmap of toolbox/OS managers that can be called from MPLibrary MPTasks  }
	gestaltMPFileManager		= 0;							{  True if File Manager calls can be made from MPTasks  }
	gestaltMPDeviceManager		= 1;							{  True if synchronous Device Manager calls can be made from MPTasks  }
	gestaltMPTrapCalls			= 2;							{  True if most trap-based calls can be made from MPTasks  }

	gestaltStdNBPAttr			= $6E6C7570 (* 'nlup' *);						{  standard nbp attributes  }
	gestaltStdNBPPresent		= 0;
	gestaltStdNBPSupportsAutoPosition = 1;						{  StandardNBP takes (-1,-1) to mean alert position main screen  }

	gestaltNotificationMgrAttr	= $6E6D6772 (* 'nmgr' *);						{  notification manager attributes  }
	gestaltNotificationPresent	= 0;							{  notification manager exists  }

	gestaltNameRegistryVersion	= $6E726567 (* 'nreg' *);						{  NameRegistryLib version number, for System 7.5.2+ usage  }

	gestaltNuBusSlotCount		= $6E756273 (* 'nubs' *);						{  count of logical NuBus slots present  }

	gestaltOCEToolboxVersion	= $6F636574 (* 'ocet' *);						{  OCE Toolbox version  }
	gestaltOCETB				= $0102;						{  OCE Toolbox version 1.02  }
	gestaltSFServer				= $0100;						{  S&F Server version 1.0  }

	gestaltOCEToolboxAttr		= $6F636575 (* 'oceu' *);						{  OCE Toolbox attributes  }
	gestaltOCETBPresent			= $01;							{  OCE toolbox is present, not running  }
	gestaltOCETBAvailable		= $02;							{  OCE toolbox is running and available  }
	gestaltOCESFServerAvailable	= $04;							{  S&F Server is running and available  }
	gestaltOCETBNativeGlueAvailable = $10;						{  Native PowerPC Glue routines are availible  }

	gestaltOpenFirmwareInfo		= $6F706677 (* 'opfw' *);						{  Open Firmware info  }

	gestaltOSAttr				= $6F732020 (* 'os  ' *);						{  o/s attributes  }
	gestaltSysZoneGrowable		= 0;							{  system heap is growable  }
	gestaltLaunchCanReturn		= 1;							{  can return from launch  }
	gestaltLaunchFullFileSpec	= 2;							{  can launch from full file spec  }
	gestaltLaunchControl		= 3;							{  launch control support available  }
	gestaltTempMemSupport		= 4;							{  temp memory support  }
	gestaltRealTempMemory		= 5;							{  temp memory handles are real  }
	gestaltTempMemTracked		= 6;							{  temporary memory handles are tracked  }
	gestaltIPCSupport			= 7;							{  IPC support is present  }
	gestaltSysDebuggerSupport	= 8;							{  system debugger support is present  }
	gestaltNativeProcessMgrBit	= 19;							{  the process manager itself is native  }
	gestaltAltivecRegistersSwappedCorrectlyBit = 20;			{  Altivec registers are saved correctly on process switches  }

	gestaltOSTable				= $6F737474 (* 'ostt' *);						{   OS trap table base   }


	{	******************************************************************************
	*   Gestalt Selectors for Open Transport Network Setup
	*
	*   Note: possible values for the version "stage" byte are:
	*   development = 0x20, alpha = 0x40, beta = 0x60, final & release = 0x80
	*******************************************************************************	}
	gestaltOpenTptNetworkSetup	= $6F746366 (* 'otcf' *);
	gestaltOpenTptNetworkSetupLegacyImport = 0;
	gestaltOpenTptNetworkSetupLegacyExport = 1;
	gestaltOpenTptNetworkSetupSupportsMultihoming = 2;

	gestaltOpenTptNetworkSetupVersion = $6F746376 (* 'otcv' *);

	{	******************************************************************************
	*   Gestalt Selectors for Open Transport-based Remote Access/PPP
	*
	*   Note: possible values for the version "stage" byte are:
	*   development = 0x20, alpha = 0x40, beta = 0x60, final & release = 0x80
	*******************************************************************************	}
	gestaltOpenTptRemoteAccess	= $6F747261 (* 'otra' *);
	gestaltOpenTptRemoteAccessPresent = 0;
	gestaltOpenTptRemoteAccessLoaded = 1;
	gestaltOpenTptRemoteAccessClientOnly = 2;
	gestaltOpenTptRemoteAccessPServer = 3;
	gestaltOpenTptRemoteAccessMPServer = 4;
	gestaltOpenTptPPPPresent	= 5;
	gestaltOpenTptARAPPresent	= 6;

	gestaltOpenTptRemoteAccessVersion = $6F747276 (* 'otrv' *);


	{  ***** Open Transport Gestalt ***** }


	gestaltOpenTptVersions		= $6F747672 (* 'otvr' *);						{  Defined by OT 1.1 and higher, response is NumVersion. }

	gestaltOpenTpt				= $6F74616E (* 'otan' *);						{  Defined by all versions, response is defined below. }
	gestaltOpenTptPresentMask	= $00000001;
	gestaltOpenTptLoadedMask	= $00000002;
	gestaltOpenTptAppleTalkPresentMask = $00000004;
	gestaltOpenTptAppleTalkLoadedMask = $00000008;
	gestaltOpenTptTCPPresentMask = $00000010;
	gestaltOpenTptTCPLoadedMask	= $00000020;
	gestaltOpenTptIPXSPXPresentMask = $00000040;
	gestaltOpenTptIPXSPXLoadedMask = $00000080;
	gestaltOpenTptPresentBit	= 0;
	gestaltOpenTptLoadedBit		= 1;
	gestaltOpenTptAppleTalkPresentBit = 2;
	gestaltOpenTptAppleTalkLoadedBit = 3;
	gestaltOpenTptTCPPresentBit	= 4;
	gestaltOpenTptTCPLoadedBit	= 5;
	gestaltOpenTptIPXSPXPresentBit = 6;
	gestaltOpenTptIPXSPXLoadedBit = 7;


	gestaltPCCard				= $70636364 (* 'pccd' *);						{     PC Card attributes }
	gestaltCardServicesPresent	= 0;							{     PC Card 2.0 (68K) API is present }
	gestaltPCCardFamilyPresent	= 1;							{     PC Card 3.x (PowerPC) API is present }
	gestaltPCCardHasPowerControl = 2;							{     PCCardSetPowerLevel is supported }
	gestaltPCCardSupportsCardBus = 3;							{     CardBus is supported }

	gestaltProcClkSpeed			= $70636C6B (* 'pclk' *);						{  processor clock speed in hertz  }

	gestaltProcClkSpeedMHz = $6D636C6B (* 'mclk' *); { processor clock speed in megahertz (an unsigned long) }

	gestaltPCXAttr				= $70637867 (* 'pcxg' *);						{  PC Exchange attributes  }
	gestaltPCXHas8and16BitFAT	= 0;							{  PC Exchange supports both 8 and 16 bit FATs  }
	gestaltPCXHasProDOS			= 1;							{  PC Exchange supports ProDOS  }
	gestaltPCXNewUI				= 2;
	gestaltPCXUseICMapping		= 3;							{  PC Exchange uses InternetConfig for file mappings  }

	gestaltLogicalPageSize		= $7067737A (* 'pgsz' *);						{  logical page size  }

	{	    System 7.6 and later.  If gestaltScreenCaptureMain is not implemented,
	    PictWhap proceeds with screen capture in the usual way.
	
	    The high word of gestaltScreenCaptureMain is reserved (use 0).
	
	    To disable screen capture to disk, put zero in the low word.  To
	    specify a folder for captured pictures, put the vRefNum in the
	    low word of gestaltScreenCaptureMain, and put the directory ID in
	    gestaltScreenCaptureDir.
		}
	gestaltScreenCaptureMain	= $70696331 (* 'pic1' *);						{  Zero, or vRefNum of disk to hold picture  }
	gestaltScreenCaptureDir		= $70696332 (* 'pic2' *);						{  Directory ID of folder to hold picture  }

	gestaltGXPrintingMgrVersion	= $706D6772 (* 'pmgr' *);						{  QuickDraw GX Printing Manager Version }

	gestaltPopupAttr			= $706F7021 (* 'pop!' *);						{  popup cdef attributes  }
	gestaltPopupPresent			= 0;

	gestaltPowerMgrAttr			= $706F7772 (* 'powr' *);						{  power manager attributes  }
	gestaltPMgrExists			= 0;
	gestaltPMgrCPUIdle			= 1;
	gestaltPMgrSCC				= 2;
	gestaltPMgrSound			= 3;
	gestaltPMgrDispatchExists	= 4;
	gestaltPMgrSupportsAVPowerStateAtSleepWake = 5;

	gestaltPowerMgrVers			= $70777276 (* 'pwrv' *);						{  power manager version  }

	{	
	 * PPC will return the combination of following bit fields.
	 * e.g. gestaltPPCSupportsRealTime +gestaltPPCSupportsIncoming + gestaltPPCSupportsOutGoing
	 * indicates PPC is cuurently is only supports real time delivery
	 * and both incoming and outgoing network sessions are allowed.
	 * By default local real time delivery is supported as long as PPCInit has been called.	}
	gestaltPPCToolboxAttr		= $70706320 (* 'ppc ' *);						{  PPC toolbox attributes  }
	gestaltPPCToolboxPresent	= $0000;						{  PPC Toolbox is present  Requires PPCInit to be called  }
	gestaltPPCSupportsRealTime	= $1000;						{  PPC Supports real-time delivery  }
	gestaltPPCSupportsIncoming	= $0001;						{  PPC will allow incoming network requests  }
	gestaltPPCSupportsOutGoing	= $0002;						{  PPC will allow outgoing network requests  }
	gestaltPPCSupportsTCP_IP	= $0004;						{  PPC supports TCP/IP transport   }
	gestaltPPCSupportsIncomingAppleTalk = $0010;
	gestaltPPCSupportsIncomingTCP_IP = $0020;
	gestaltPPCSupportsOutgoingAppleTalk = $0100;
	gestaltPPCSupportsOutgoingTCP_IP = $0200;

{
    Programs which need to know information about particular features of the processor should
    migrate to using sysctl() and sysctlbyname() to get this kind of information.  No new
    information will be added to the 'ppcf' selector going forward.
}
	gestaltPowerPCProcessorFeatures = $70706366 (* 'ppcf' *);					{  Optional PowerPC processor features  }
	gestaltPowerPCHasGraphicsInstructions = 0;					{  has fres, frsqrte, and fsel instructions  }
	gestaltPowerPCHasSTFIWXInstruction = 1;						{  has stfiwx instruction  }
	gestaltPowerPCHasSquareRootInstructions = 2;				{  has fsqrt and fsqrts instructions  }
	gestaltPowerPCHasDCBAInstruction = 3;						{  has dcba instruction  }
	gestaltPowerPCHasVectorInstructions = 4;					{  has vector instructions  }
	gestaltPowerPCHasDataStreams = 5;							{  has dst, dstt, dstst, dss, and dssall instructions  }
	gestaltPowerPCHas64BitSupport = 6;                          {  double word LSU/ALU, etc. }
	gestaltPowerPCHasDCBTStreams = 7;                           {  TH field of DCBT recognized }
	gestaltPowerPCASArchitecture = 8;                           {  chip uses new 'A/S' architecture }
	gestaltPowerPCIgnoresDCBST = 9;                             { }

	gestaltProcessorType		= $70726F63 (* 'proc' *);						{  processor type  }
	gestalt68000				= 1;
	gestalt68010				= 2;
	gestalt68020				= 3;
	gestalt68030				= 4;
	gestalt68040				= 5;

	gestaltSDPPromptVersion		= $70727076 (* 'prpv' *);						{  OCE Standard Directory Panel }

	gestaltParityAttr			= $70727479 (* 'prty' *);						{  parity attributes  }
	gestaltHasParityCapability	= 0;							{  has ability to check parity  }
	gestaltParityEnabled		= 1;							{  parity checking enabled  }

	gestaltQD3DVersion			= $71337620 (* 'q3v ' *);						{  Quickdraw 3D version in pack BCD }

	gestaltQD3DViewer			= $71337663 (* 'q3vc' *);						{  Quickdraw 3D viewer attributes }
	gestaltQD3DViewerPresent	= 0;							{  bit 0 set if QD3D Viewer is available }

{$ifc OLDROUTINENAMES}
	gestaltQD3DViewerNotPresent	= $00;
	gestaltQD3DViewerAvailable	= $01;

{$endc}  {OLDROUTINENAMES}

	gestaltQuickdrawVersion		= $71642020 (* 'qd  ' *);						{  quickdraw version  }
	gestaltOriginalQD			= $0000;						{  original 1-bit QD  }
	gestalt8BitQD				= $0100;						{  8-bit color QD  }
	gestalt32BitQD				= $0200;						{  32-bit color QD  }
	gestalt32BitQD11			= $0201;						{  32-bit color QDv1.1  }
	gestalt32BitQD12			= $0220;						{  32-bit color QDv1.2  }
	gestalt32BitQD13			= $0230;						{  32-bit color QDv1.3  }
	gestaltAllegroQD			= $0250;						{  Allegro QD OS 8.5  }
	gestaltMacOSXQD				= $0300;						{  0x310, 0x320 etc. for 10.x.y  }

	gestaltQD3D					= $71643364 (* 'qd3d' *);						{  Quickdraw 3D attributes }
	gestaltQD3DPresent			= 0;							{  bit 0 set if QD3D available }

{$ifc OLDROUTINENAMES}
	gestaltQD3DNotPresent		= $00;
	gestaltQD3DAvailable		= $01;

{$endc}  {OLDROUTINENAMES}

	gestaltGXVersion			= $71646778 (* 'qdgx' *);						{  Overall QuickDraw GX Version }

	gestaltQuickdrawFeatures	= $71647277 (* 'qdrw' *);						{  quickdraw features  }
	gestaltHasColor				= 0;							{  color quickdraw present  }
	gestaltHasDeepGWorlds		= 1;							{  GWorlds can be deeper than 1-bit  }
	gestaltHasDirectPixMaps		= 2;							{  PixMaps can be direct (16 or 32 bit)  }
	gestaltHasGrayishTextOr		= 3;							{  supports text mode grayishTextOr  }
	gestaltSupportsMirroring	= 4;							{  Supports video mirroring via the Display Manager.  }
	gestaltQDHasLongRowBytes	= 5;							{  Long rowBytes supported in GWorlds  }

	gestaltQDTextVersion		= $71647478 (* 'qdtx' *);						{  QuickdrawText version  }
	gestaltOriginalQDText		= $0000;						{  up to and including 8.1  }
	gestaltAllegroQDText		= $0100;						{  starting with 8.5  }
	gestaltMacOSXQDText			= $0200;						{  we are in Mac OS X  }

	gestaltQDTextFeatures		= $71647466 (* 'qdtf' *);						{  QuickdrawText features  }
	gestaltWSIISupport			= 0;							{  bit 0: WSII support included  }
	gestaltSbitFontSupport		= 1;							{  sbit-only fonts supported  }
	gestaltAntiAliasedTextAvailable = 2;						{  capable of antialiased text  }
	gestaltOFA2available		= 3;							{  OFA2 available  }
	gestaltCreatesAliasFontRsrc	= 4;							{  "real" datafork font support  }
	gestaltNativeType1FontSupport = 5;							{  we have scaler for Type1 fonts  }
	gestaltCanUseCGTextRendering = 6;


	gestaltQuickTimeConferencingInfo = $71746369 (* 'qtci' *);					{  returns pointer to QuickTime Conferencing information  }

	gestaltQuickTimeVersion		= $7174696D (* 'qtim' *);						{  returns version of QuickTime  }
	gestaltQuickTime			= $7174696D (* 'qtim' *);						{  gestaltQuickTime is old name for gestaltQuickTimeVersion  }

	gestaltQuickTimeFeatures	= $71747273 (* 'qtrs' *);
	gestaltPPCQuickTimeLibPresent = 0;							{  PowerPC QuickTime glue library is present  }

	gestaltQuickTimeStreamingFeatures = $71747366 (* 'qtsf' *);

	gestaltQuickTimeStreamingVersion = $71747374 (* 'qtst' *);

	gestaltQuickTimeThreadSafeFeaturesAttr = $71747468 (* 'qtth' *); { Quicktime thread safety attributes }
	gestaltQuickTimeThreadSafeICM = 0;
	gestaltQuickTimeThreadSafeMovieToolbox = 1;
	gestaltQuickTimeThreadSafeMovieImport = 2;
	gestaltQuickTimeThreadSafeMovieExport = 3;
	gestaltQuickTimeThreadSafeGraphicsImport = 4;
	gestaltQuickTimeThreadSafeGraphicsExport = 5;
	gestaltQuickTimeThreadSafeMoviePlayback = 6;

	gestaltQTVRMgrAttr			= $71747672 (* 'qtvr' *);						{  QuickTime VR attributes                                }
	gestaltQTVRMgrPresent		= 0;							{  QTVR API is present                                    }
	gestaltQTVRObjMoviesPresent	= 1;							{  QTVR runtime knows about object movies                 }
	gestaltQTVRCylinderPanosPresent = 2;						{  QTVR runtime knows about cylindrical panoramic movies  }
	gestaltQTVRCubicPanosPresent = 3;							{  QTVR runtime knows about cubic panoramic movies        }

	gestaltQTVRMgrVers			= $71747676 (* 'qtvv' *);						{  QuickTime VR version                                   }

{    
    Because some PowerPC machines now support very large physical memory capacities, including
    some above the maximum value which can held in a 32 bit quantity, there is now a new selector,
    gestaltPhysicalRAMSizeInMegabytes, which returns the size of physical memory scaled
    in megabytes.  It is recommended that code transition to using this new selector if
    it wants to get a useful value for the amount of physical memory on the system.  Code can
    also use the sysctl() and sysctlbyname() BSD calls to get these kinds of values.
    
    For compatability with code which assumed that the value in returned by the
    gestaltPhysicalRAMSize selector would be a signed quantity of bytes, this selector will
    now return 2 gigabytes-1 ( LONG_MAX ) if the system has 2 gigabytes of physical memory or more.
}
	gestaltPhysicalRAMSize		= $72616D20 (* 'ram ' *);						{  physical RAM size  }

	gestaltPhysicalRAMSizeInMegabytes = $72616D6D (* 'ramm' *);                 { physical RAM size, scaled in megabytes }

	gestaltRBVAddr				= $72627620 (* 'rbv ' *);						{  RBV base address   }

	gestaltROMSize				= $726F6D20 (* 'rom ' *);						{  rom size  }

	gestaltROMVersion			= $726F6D76 (* 'romv' *);						{  rom version  }

	gestaltResourceMgrAttr		= $72737263 (* 'rsrc' *);						{  Resource Mgr attributes  }
	gestaltPartialRsrcs			= 0;							{  True if partial resources exist  }
	gestaltHasResourceOverrides	= 1;							{  Appears in the ROM; so put it here.  }

	gestaltResourceMgrBugFixesAttrs = $726D6267 (* 'rmbg' *);					{  Resource Mgr bug fixes  }
	gestaltRMForceSysHeapRolledIn = 0;
	gestaltRMFakeAppleMenuItemsRolledIn = 1;
	gestaltSanityCheckResourceFiles = 2;						{  Resource manager does sanity checking on resource files before opening them  }
	gestaltSupportsFSpResourceFileAlreadyOpenBit = 3;			{  The resource manager supports GetResFileRefNum and FSpGetResFileRefNum and FSpResourceFileAlreadyOpen  }
	gestaltRMSupportsFSCalls	= 4;							{  The resource manager supports OpenResFileFSRef, CreateResFileFSRef and  ResourceFileAlreadyOpenFSRef  }
	gestaltRMTypeIndexOrderingReverse = 8;						{  GetIndType() calls return resource types in opposite order to original 68k resource manager  }


	gestaltRealtimeMgrAttr		= $72746D72 (* 'rtmr' *);						{  Realtime manager attributes          }
	gestaltRealtimeMgrPresent	= 0;							{  true if the Realtime manager is present     }


	gestaltSafeOFAttr			= $73616665 (* 'safe' *);
	gestaltVMZerosPagesBit		= 0;
	gestaltInitHeapZerosOutHeapsBit = 1;
	gestaltNewHandleReturnsZeroedMemoryBit = 2;
	gestaltNewPtrReturnsZeroedMemoryBit = 3;
	gestaltFileAllocationZeroedBlocksBit = 4;


	gestaltSCCReadAddr			= $73636372 (* 'sccr' *);						{  scc read base address   }

	gestaltSCCWriteAddr			= $73636377 (* 'sccw' *);						{  scc read base address   }

	gestaltScrapMgrAttr			= $73637261 (* 'scra' *);						{  Scrap Manager attributes  }
	gestaltScrapMgrTranslationAware = 0;						{  True if scrap manager is translation aware  }

	gestaltScriptMgrVersion		= $73637269 (* 'scri' *);						{  Script Manager version number      }

	gestaltScriptCount			= $73637223 (* 'scr#' *);						{  number of active script systems    }

	gestaltSCSI					= $73637369 (* 'scsi' *);						{  SCSI Manager attributes  }
	gestaltAsyncSCSI			= 0;							{  Supports Asynchronous SCSI  }
	gestaltAsyncSCSIINROM		= 1;							{  Async scsi is in ROM (available for booting)  }
	gestaltSCSISlotBoot			= 2;							{  ROM supports Slot-style PRAM for SCSI boots (PDM and later)  }
	gestaltSCSIPollSIH			= 3;							{  SCSI Manager will poll for interrupts if Secondary Interrupts are busy.  }

	gestaltControlStripAttr		= $73646576 (* 'sdev' *);						{  Control Strip attributes  }
	gestaltControlStripExists	= 0;							{  Control Strip is installed  }
	gestaltControlStripVersionFixed = 1;						{  Control Strip version Gestalt selector was fixed  }
	gestaltControlStripUserFont	= 2;							{  supports user-selectable font/size  }
	gestaltControlStripUserHotKey = 3;							{  support user-selectable hot key to show/hide the window  }

	gestaltSDPStandardDirectoryVersion = $73647672 (* 'sdvr' *);				{  OCE Standard Directory Panel }

	gestaltSerialAttr			= $73657220 (* 'ser ' *);						{  Serial attributes  }
	gestaltHasGPIaToDCDa		= 0;							{  GPIa connected to DCDa }
	gestaltHasGPIaToRTxCa		= 1;							{  GPIa connected to RTxCa clock input }
	gestaltHasGPIbToDCDb		= 2;							{  GPIb connected to DCDb  }
	gestaltHidePortA			= 3;							{  Modem port (A) should be hidden from users  }
	gestaltHidePortB			= 4;							{  Printer port (B) should be hidden from users  }
	gestaltPortADisabled		= 5;							{  Modem port (A) disabled and should not be used by SW  }
	gestaltPortBDisabled		= 6;							{  Printer port (B) disabled and should not be used by SW  }

	gestaltShutdownAttributes	= $73687574 (* 'shut' *);						{  ShutDown Manager Attributes  }
	gestaltShutdownHassdOnBootVolUnmount = 0;					{  True if ShutDown Manager unmounts boot & VM volume at shutdown time.  }

	gestaltNuBusConnectors		= $736C7463 (* 'sltc' *);						{  bitmap of NuBus connectors }

	gestaltSlotAttr				= $736C6F74 (* 'slot' *);						{  slot attributes   }
	gestaltSlotMgrExists		= 0;							{  true is slot mgr exists   }
	gestaltNuBusPresent			= 1;							{  NuBus slots are present   }
	gestaltSESlotPresent		= 2;							{  SE PDS slot present   }
	gestaltSE30SlotPresent		= 3;							{  SE/30 slot present   }
	gestaltPortableSlotPresent	= 4;							{  Portable�s slot present   }

	gestaltFirstSlotNumber		= $736C7431 (* 'slt1' *);						{  returns first physical slot  }

	gestaltSoundAttr			= $736E6420 (* 'snd ' *);						{  sound attributes  }
	gestaltStereoCapability		= 0;							{  sound hardware has stereo capability  }
	gestaltStereoMixing			= 1;							{  stereo mixing on external speaker  }
	gestaltSoundIOMgrPresent	= 3;							{  The Sound I/O Manager is present  }
	gestaltBuiltInSoundInput	= 4;							{  built-in Sound Input hardware is present  }
	gestaltHasSoundInputDevice	= 5;							{  Sound Input device available  }
	gestaltPlayAndRecord		= 6;							{  built-in hardware can play and record simultaneously  }
	gestalt16BitSoundIO			= 7;							{  sound hardware can play and record 16-bit samples  }
	gestaltStereoInput			= 8;							{  sound hardware can record stereo  }
	gestaltLineLevelInput		= 9;							{  sound input port requires line level  }
																{  the following bits are not defined prior to Sound Mgr 3.0  }
	gestaltSndPlayDoubleBuffer	= 10;							{  SndPlayDoubleBuffer available, set by Sound Mgr 3.0 and later  }
	gestaltMultiChannels		= 11;							{  multiple channel support, set by Sound Mgr 3.0 and later  }
	gestalt16BitAudioSupport	= 12;							{  16 bit audio data supported, set by Sound Mgr 3.0 and later  }

	gestaltSplitOSAttr			= $73706F73 (* 'spos' *);
	gestaltSplitOSBootDriveIsNetworkVolume = 0;					{  the boot disk is a network 'disk', from the .LANDisk drive.  }
	gestaltSplitOSAware			= 1;							{  the system includes the code to deal with a split os situation.  }
	gestaltSplitOSEnablerVolumeIsDifferentFromBootVolume = 2;	{  the active enabler is on a different volume than the system file.  }
	gestaltSplitOSMachineNameSetToNetworkNameTemp = 3;			{  The machine name was set to the value given us from the BootP server  }
	gestaltSplitOSMachineNameStartupDiskIsNonPersistent = 5;	{  The startup disk ( vRefNum == -1 ) is non-persistent, meaning changes won't persist across a restart.  }

	gestaltSMPSPSendLetterVersion = $7370736C (* 'spsl' *);						{  OCE StandardMail }

	gestaltSpeechRecognitionAttr = $73727461 (* 'srta' *);						{  speech recognition attributes  }
	gestaltDesktopSpeechRecognition = 1;						{  recognition thru the desktop microphone is available  }
	gestaltTelephoneSpeechRecognition = 2;						{  recognition thru the telephone is available  }

	gestaltSpeechRecognitionVersion = $73727462 (* 'srtb' *);					{  speech recognition version (0x0150 is the first version that fully supports the API)  }

	gestaltSoftwareVendorCode	= $73726164 (* 'srad' *);						{  Returns system software vendor information  }
	gestaltSoftwareVendorApple	= $4170706C (* 'Appl' *);						{  System software sold by Apple  }
	gestaltSoftwareVendorLicensee = $4C636E73 (* 'Lcns' *);						{  System software sold by licensee  }

	gestaltStandardFileAttr		= $73746466 (* 'stdf' *);						{  Standard File attributes  }
	gestaltStandardFile58		= 0;							{  True if selectors 5-8 (StandardPutFile-CustomGetFile) are supported  }
	gestaltStandardFileTranslationAware = 1;					{  True if standard file is translation manager aware  }
	gestaltStandardFileHasColorIcons = 2;						{  True if standard file has 16x16 color icons  }
	gestaltStandardFileUseGenericIcons = 3;						{  Standard file LDEF to use only the system generic icons if true  }
	gestaltStandardFileHasDynamicVolumeAllocation = 4;			{  True if standard file supports more than 20 volumes  }

	gestaltSysArchitecture		= $73797361 (* 'sysa' *);						{  Native System Architecture  }
	gestalt68k					= 1;							{  Motorola MC68k architecture  }
	gestaltPowerPC				= 2;							{  IBM PowerPC architecture  }
	gestaltIntel                = 10;                           {  Intel x86 architecture }

	gestaltSystemUpdateVersion	= $73797375 (* 'sysu' *);						{  System Update version  }

{  
    Returns the system version as a 32 bit packed BCD ( binary coded decimal )
    version representation.  Bits 0 through 3 are the "bug fix" revision number.
    Bits 4 through 7 are the minor revision, and bits 8 through 31 are the bcd
    decimal digits of the major release version.
    
      Value:  0xMMMMMMRB = M.R.B            Example: 0x00001023 = 10.2.3
                ^^^^^^     major rev                   ^^^^^^   major rev   = 10
                      ^    minor rev                         ^  minor rev   =  2
                       ^   bug fix rev                        ^ bug fix rev =  3
    
    If the values of the minor or bug fix revision are larger than 9, then
    gestaltSystemVersion will substitute the value 9 for them.  For example,
    Mac OS X 10.3.15 will be returned as 0x1039, and Mac OS X 10.10.5 will
    return 0x1095.
    
    A better way to get version information on Mac OS X would be to read in the
    system version information from the file /System/Library/CoreServices/SystemVersion.plist.
}
	gestaltSystemVersion		= $73797376 (* 'sysv' *);						{  system version }
	gestaltSystemVersionMajor   = $73797331 (* 'sys1' *);                       {  The major system version number; in 10.4.17 this would be the decimal value 10 }
	gestaltSystemVersionMinor   = $73797332 (* 'sys2' *);                       {  The minor system version number; in 10.4.17 this would be the decimal value 4 }
	gestaltSystemVersionBugFix  = $73797333 (* 'sys3' *);                       {  The bug fix system version number; in 10.4.17 this would be the decimal value 17 }

	gestaltToolboxTable			= $74627474 (* 'tbtt' *);						{   OS trap table base   }

	gestaltTextEditVersion		= $74652020 (* 'te  ' *);						{  TextEdit version number  }
	gestaltTE1					= 1;							{  TextEdit in MacIIci ROM  }
	gestaltTE2					= 2;							{  TextEdit with 6.0.4 Script Systems on MacIIci (Script bug fixes for MacIIci)  }
	gestaltTE3					= 3;							{  TextEdit with 6.0.4 Script Systems all but MacIIci  }
	gestaltTE4					= 4;							{  TextEdit in System 7.0  }
	gestaltTE5					= 5;							{  TextWidthHook available in TextEdit  }

	gestaltTE6                  = 6;                            { TextEdit with integrated TSMTE and improved UI }

	gestaltTEAttr				= $74656174 (* 'teat' *);						{  TextEdit attributes  }
	gestaltTEHasGetHiliteRgn	= 0;							{  TextEdit has TEGetHiliteRgn  }
	gestaltTESupportsInlineInput = 1;							{  TextEdit does Inline Input  }
	gestaltTESupportsTextObjects = 2;							{  TextEdit does Text Objects  }
	gestaltTEHasWhiteBackground	= 3;							{  TextEdit supports overriding the TERec's background to white  }

	gestaltTeleMgrAttr			= $74656C65 (* 'tele' *);						{  Telephone manager attributes  }
	gestaltTeleMgrPresent		= 0;
	gestaltTeleMgrPowerPCSupport = 1;
	gestaltTeleMgrSoundStreams	= 2;
	gestaltTeleMgrAutoAnswer	= 3;
	gestaltTeleMgrIndHandset	= 4;
	gestaltTeleMgrSilenceDetect	= 5;
	gestaltTeleMgrNewTELNewSupport = 6;

	gestaltTermMgrAttr			= $7465726D (* 'term' *);						{  terminal mgr attributes  }
	gestaltTermMgrPresent		= 0;
	gestaltTermMgrErrorString	= 2;

	gestaltThreadMgrAttr		= $74686473 (* 'thds' *);						{  Thread Manager attributes  }
	gestaltThreadMgrPresent		= 0;							{  bit true if Thread Mgr is present  }
	gestaltSpecificMatchSupport	= 1;							{  bit true if Thread Mgr supports exact match creation option  }
	gestaltThreadsLibraryPresent = 2;							{  bit true if Thread Mgr shared library is present  }

	gestaltTimeMgrVersion		= $746D6772 (* 'tmgr' *);						{  time mgr version  }
	gestaltStandardTimeMgr		= 1;							{  standard time mgr is present  }
	gestaltRevisedTimeMgr		= 2;							{  revised time mgr is present  }
	gestaltExtendedTimeMgr		= 3;							{  extended time mgr is present  }
	gestaltNativeTimeMgr		= 4;							{  PowerPC native TimeMgr is present  }

	gestaltTSMTEVersion			= $746D5456 (* 'tmTV' *);
	gestaltTSMTE1				= $0100;						{  Original version of TSMTE  }
	gestaltTSMTE15				= $0150;						{  System 8.0  }
	gestaltTSMTE152				= $0152;						{  System 8.2  }

	gestaltTSMTEAttr			= $746D5445 (* 'tmTE' *);
	gestaltTSMTEPresent			= 0;
	gestaltTSMTE				= 0;							{  gestaltTSMTE is old name for gestaltTSMTEPresent  }

	gestaltAVLTreeAttr			= $74726565 (* 'tree' *);						{  AVLTree utility routines attributes.  }
	gestaltAVLTreePresentBit	= 0;							{  if set, then the AVL Tree routines are available.  }
	gestaltAVLTreeSupportsHandleBasedTreeBit = 1;				{  if set, then the AVL Tree routines can store tree data in a single handle  }
	gestaltAVLTreeSupportsTreeLockingBit = 2;					{  if set, the AVLLockTree() and AVLUnlockTree() routines are available.  }

	gestaltALMAttr				= $74726970 (* 'trip' *);						{  Settings Manager attributes (see also gestaltALMVers)  }
	gestaltALMPresent			= 0;							{  bit true if ALM is available  }
	gestaltALMHasSFGroup		= 1;							{  bit true if Put/Get/Merge Group calls are implmented  }
	gestaltALMHasCFMSupport		= 2;							{  bit true if CFM-based modules are supported  }
	gestaltALMHasRescanNotifiers = 3;							{  bit true if Rescan notifications/events will be sent to clients  }

	gestaltALMHasSFLocation		= 1;

	gestaltTSMgrVersion			= $74736D76 (* 'tsmv' *);						{  Text Services Mgr version, if present  }
	gestaltTSMgr15				= $0150;
	gestaltTSMgr20				= $0200;                        { Version 2.0 as of MacOSX 10.0 }
	gestaltTSMgr22              = $0220;                        { Version 2.2 as of MacOSX 10.3 }
	gestaltTSMgr23              = $0230;                        { Version 2.3 as of MacOSX 10.4 }

	gestaltTSMgrAttr			= $74736D61 (* 'tsma' *);						{  Text Services Mgr attributes, if present  }
	gestaltTSMDisplayMgrAwareBit = 0;							{  TSM knows about display manager  }
	gestaltTSMdoesTSMTEBit		= 1;							{  TSM has integrated TSMTE  }

	gestaltSpeechAttr			= $74747363 (* 'ttsc' *);						{  Speech Manager attributes  }
	gestaltSpeechMgrPresent		= 0;							{  bit set indicates that Speech Manager exists  }
	gestaltSpeechHasPPCGlue		= 1;							{  bit set indicates that native PPC glue for Speech Manager API exists  }

	gestaltTVAttr				= $74762020 (* 'tv  ' *);						{  TV version  }
	gestaltHasTVTuner			= 0;							{  supports Philips FL1236F video tuner  }
	gestaltHasSoundFader		= 1;							{  supports Philips TEA6330 Sound Fader chip  }
	gestaltHasHWClosedCaptioning = 2;							{  supports Philips SAA5252 Closed Captioning  }
	gestaltHasIRRemote			= 3;							{  supports CyclopsII Infra Red Remote control  }
	gestaltHasVidDecoderScaler	= 4;							{  supports Philips SAA7194 Video Decoder/Scaler  }
	gestaltHasStereoDecoder		= 5;							{  supports Sony SBX1637A-01 stereo decoder  }
	gestaltHasSerialFader		= 6;							{  has fader audio in serial with system audio  }
	gestaltHasFMTuner			= 7;							{  has FM Tuner from donnybrook card  }
	gestaltHasSystemIRFunction	= 8;							{  Infra Red button function is set up by system and not by Video Startup  }
	gestaltIRDisabled			= 9;							{  Infra Red remote is not disabled.  }
	gestaltINeedIRPowerOffConfirm = 10;							{  Need IR power off confirm dialog.  }
	gestaltHasZoomedVideo		= 11;							{  Has Zoomed Video PC Card video input.  }


	gestaltATSUVersion			= $75697376 (* 'uisv' *);
	gestaltOriginalATSUVersion	= $00010000;					{  ATSUI version 1.0  }
	gestaltATSUUpdate1			= $00020000;					{  ATSUI version 1.1  }
	gestaltATSUUpdate2			= $00030000;					{  ATSUI version 1.2  }
	gestaltATSUUpdate3			= $00040000;					{  ATSUI version 2.0  }
	gestaltATSUUpdate4			= $00050000;					{  ATSUI version in Mac OS X - SoftwareUpdate 1-4 for Mac OS 10.0.1 - 10.0.4  }
	gestaltATSUUpdate5			= $00060000;					{  ATSUI version 2.3 in MacOS 10.1  }
	gestaltATSUUpdate6          = 7 shl 16;                     {  ATSUI version 2.4 in MacOS 10.2 }
	gestaltATSUUpdate7          = 8 shl 16;                     {  ATSUI version 2.5 in MacOS 10.3 }

	gestaltATSUFeatures			= $75697366 (* 'uisf' *);
	gestaltATSUTrackingFeature	= $00000001;					{  feature introduced in ATSUI version 1.1  }
	gestaltATSUMemoryFeature	= $00000001;					{  feature introduced in ATSUI version 1.1  }
	gestaltATSUFallbacksFeature	= $00000001;					{  feature introduced in ATSUI version 1.1  }
	gestaltATSUGlyphBoundsFeature = $00000001;					{  feature introduced in ATSUI version 1.1  }
	gestaltATSULineControlFeature = $00000001;					{  feature introduced in ATSUI version 1.1  }
	gestaltATSULayoutCreateAndCopyFeature = $00000001;			{  feature introduced in ATSUI version 1.1  }
	gestaltATSULayoutCacheClearFeature = $00000001;				{  feature introduced in ATSUI version 1.1  }
	gestaltATSUTextLocatorUsageFeature = $00000002;				{  feature introduced in ATSUI version 1.2  }
	gestaltATSULowLevelOrigFeatures = $00000004;				{  first low-level features introduced in ATSUI version 2.0  }
	gestaltATSUFallbacksObjFeatures = $00000008;				{  feature introduced - ATSUFontFallbacks objects introduced in ATSUI version 2.3  }
	gestaltATSUIgnoreLeadingFeature = $00000008;				{  feature introduced - kATSLineIgnoreFontLeading LineLayoutOption introduced in ATSUI version 2.3  }
	gestaltATSUByCharacterClusterFeature = $00000010;           {  ATSUCursorMovementTypes introduced in ATSUI version 2.4 }
	gestaltATSUAscentDescentControlsFeature = $00000010;        {  attributes introduced in ATSUI version 2.4 }
	gestaltATSUHighlightInactiveTextFeature = $00000010;        {  feature introduced in ATSUI version 2.4 }
	gestaltATSUPositionToCursorFeature = $00000010;             {  features introduced in ATSUI version 2.4 }
	gestaltATSUBatchBreakLinesFeature = $00000010;              {  feature introduced in ATSUI version 2.4 }
	gestaltATSUTabSupportFeature = $00000010;                   {  features introduced in ATSUI version 2.4 }
	gestaltATSUDirectAccess = $00000010;                        {  features introduced in ATSUI version 2.4 }
	gestaltATSUDecimalTabFeature = $00000020;                   {  feature introduced in ATSUI version 2.5 }
	gestaltATSUBiDiCursorPositionFeature = $00000020;           {  feature introduced in ATSUI version 2.5 }
	gestaltATSUNearestCharLineBreakFeature = $00000020;         {  feature introduced in ATSUI version 2.5 }
	gestaltATSUHighlightColorControlFeature = $00000020;        {  feature introduced in ATSUI version 2.5 }
	gestaltATSUUnderlineOptionsStyleFeature = $00000020;        {  feature introduced in ATSUI version 2.5 }
	gestaltATSUStrikeThroughStyleFeature = $00000020;           {  feature introduced in ATSUI version 2.5 }
	gestaltATSUDropShadowStyleFeature = $00000020;              {  feature introduced in ATSUI version 2.5 }

	gestaltUSBAttr				= $75736220 (* 'usb ' *);						{  USB Attributes  }
	gestaltUSBPresent			= 0;							{  USB Support available  }
	gestaltUSBHasIsoch			= 1;							{  USB Isochronous features available  }

	gestaltUSBVersion			= $75736276 (* 'usbv' *);						{  USB version  }

	gestaltVersion				= $76657273 (* 'vers' *);						{  gestalt version  }
	gestaltValueImplementedVers	= 5;							{  version of gestalt where gestaltValue is implemented.  }

	gestaltVIA1Addr				= $76696131 (* 'via1' *);						{  via 1 base address   }

	gestaltVIA2Addr				= $76696132 (* 'via2' *);						{  via 2 base address   }

	gestaltVMAttr				= $766D2020 (* 'vm  ' *);						{  virtual memory attributes  }
	gestaltVMPresent			= 0;							{  true if virtual memory is present  }
	gestaltVMHasLockMemoryForOutput = 1;						{  true if LockMemoryForOutput is available  }
	gestaltVMFilemappingOn		= 3;							{  true if filemapping is available  }
	gestaltVMHasPagingControl	= 4;							{  true if MakeMemoryResident, MakeMemoryNonResident, FlushMemory, and ReleaseMemoryData are available  }

	gestaltVMInfoType			= $766D696E (* 'vmin' *);						{  Indicates how the Finder should display information about VM in  }
																{  the Finder about box.  }
	gestaltVMInfoSizeStorageType = 0;							{  Display VM on/off, backing store size and name  }
	gestaltVMInfoSizeType		= 1;							{  Display whether VM is on or off and the size of the backing store  }
	gestaltVMInfoSimpleType		= 2;							{  Display whether VM is on or off  }
	gestaltVMInfoNoneType		= 3;							{  Display no VM information  }

	gestaltVMBackingStoreFileRefNum = $766D6273 (* 'vmbs' *);					{  file refNum of virtual memory's main backing store file (returned in low word of result)  }


	gestaltALMVers				= $77616C6B (* 'walk' *);						{  Settings Manager version (see also gestaltALMAttr)  }

	gestaltWindowMgrAttr		= $77696E64 (* 'wind' *);						{  If this Gestalt exists, the Mac OS 8.5 Window Manager is installed }
	gestaltWindowMgrPresent		= $00000001;					{  NOTE: this is a bit mask, whereas all other Gestalt constants of }
																{  this type are bit index values.   Universal Interfaces 3.2 slipped }
																{  out the door with this mistake. }
	gestaltWindowMgrPresentBit	= 0;							{  bit number }
	gestaltExtendedWindowAttributes = 1;						{  Has ChangeWindowAttributes; GetWindowAttributes works for all windows }
	gestaltExtendedWindowAttributesBit = 1;						{  Has ChangeWindowAttributes; GetWindowAttributes works for all windows }
	gestaltHasFloatingWindows	= 2;							{  Floating window APIs work }
	gestaltHasFloatingWindowsBit = 2;							{  Floating window APIs work }
	gestaltHasWindowBuffering	= 3;							{  This system has buffering available }
	gestaltHasWindowBufferingBit = 3;							{  This system has buffering available }
	gestaltWindowLiveResizeBit	= 4;							{  live resizing of windows is available }
	gestaltWindowMinimizeToDockBit = 5;							{  windows minimize to the dock and do not windowshade (Mac OS X) }
	gestaltHasWindowShadowsBit	= 6;							{  windows have shadows }
	gestaltSheetsAreWindowModalBit = 7;							{  sheet windows are modal only to their parent window }
	gestaltFrontWindowMayBeHiddenBit = 8;                       {  FrontWindow and related APIs will return the front window even when the app is hidden}
																{  masks for the above bits }
	gestaltWindowMgrPresentMask	= $00000001;
	gestaltExtendedWindowAttributesMask = $00000002;
	gestaltHasFloatingWindowsMask = $00000004;
	gestaltHasWindowBufferingMask = $00000008;
	gestaltWindowLiveResizeMask	= $00000010;
	gestaltWindowMinimizeToDockMask = $00000020;
	gestaltHasWindowShadowsMask	= $00000040;
	gestaltSheetsAreWindowModalMask = $00000080;
	gestaltFrontWindowMayBeHiddenMask = 1 shl gestaltFrontWindowMayBeHiddenBit;

	gestaltHasSingleWindowModeBit = 8;                          {  This system supports single window mode}
	gestaltHasSingleWindowModeMask = 1 shl gestaltHasSingleWindowModeBit;


{ gestaltX86Features is a convenience for 'cpuid' instruction.  Note
   that even though the processor may support a specific feature, the
   OS may not support all of these features.  These bitfields
   correspond directly to the bits returned by cpuid }

	gestaltX86Features			= $78383666 (* 'x86f' *);
	gestaltX86HasFPU			= 0;							{  has an FPU that supports the 387 instructions }
	gestaltX86HasVME			= 1;							{  supports Virtual-8086 Mode Extensions }
	gestaltX86HasDE				= 2;							{  supports I/O breakpoints (Debug Extensions) }
	gestaltX86HasPSE			= 3;							{  supports 4-Mbyte pages (Page Size Extension) }
	gestaltX86HasTSC			= 4;							{  supports RTDSC instruction (Time Stamp Counter) }
	gestaltX86HasMSR			= 5;							{  supports Model Specific Registers }
	gestaltX86HasPAE			= 6;							{  supports physical addresses > 32 bits (Physical Address Extension) }
	gestaltX86HasMCE			= 7;							{  supports Machine Check Exception }
	gestaltX86HasCX8			= 8;							{  supports CMPXCHG8 instructions (Compare Exchange 8 bytes) }
	gestaltX86HasAPIC			= 9;							{  contains local APIC }
	gestaltX86Reserved10		= 10;							{  do not count on this bit value }
	gestaltX86HasSEP			= 11;							{  supports fast system call (SysEnter Present) }
	gestaltX86HasMTRR			= 12;							{  supports Memory Type Range Registers }
	gestaltX86HasPGE			= 13;							{  supports Page Global Enable }
	gestaltX86HasMCA			= 14;							{  supports Machine Check Architecture }
	gestaltX86HasCMOV			= 15;							{  supports CMOVcc instruction (Conditional Move). }
																{  If FPU bit is also set, supports FCMOVcc and FCOMI, too }
	gestaltX86HasPAT			= 16;							{  supports Page Attribute Table }
	gestaltX86HasPSE36			= 17;							{  supports 36-bit Page Size Extension }
	gestaltX86HasPSN            = 18;                           {  Processor Serial Number}
	gestaltX86HasCLFSH          = 19;                           {  CLFLUSH Instruction supported}
	gestaltX86Serviced20        = 20;                           {  do not count on this bit value}
	gestaltX86HasDS             = 21;                           {  Debug Store}
	gestaltX86ResACPI           = 22;                           {  Thermal Monitor, SW-controlled clock}
	gestaltX86HasMMX			= 23;							{  supports MMX instructions }
	gestaltX86HasFXSR			= 24;							{  Supports FXSAVE and FXRSTOR instructions (fast FP save/restore) }
	gestaltX86HasSSE            = 25;                           {  Streaming SIMD extensions}
	gestaltX86HasSSE2           = 26;                           {  Streaming SIMD extensions 2}
	gestaltX86HasSS             = 27;                           {  Self-Snoop}
	gestaltX86HasHTT            = 28;                           {  Hyper-Threading Technology}
	gestaltX86HasTM             = 29;                           {  Thermal Monitor}

{ 'cpuid' now returns a 64 bit value, and the following 
    gestalt selector and field definitions apply
    to the extended form of this instruction }

	gestaltX86AdditionalFeatures = $78383661 (* 'x86a' *);
	gestaltX86HasSSE3           = 0;                            {  Prescott New Inst.}
	gestaltX86HasMONITOR        = 3;                            {  Monitor/mwait}
	gestaltX86HasDSCPL          = 4;                            {  Debug Store CPL}
	gestaltX86HasVMX            = 5;                            {  VMX}
	gestaltX86HasSMX            = 6;                            {  SMX}
	gestaltX86HasEST            = 7;                            {  Enhanced SpeedsTep (GV3)}
	gestaltX86HasTM2            = 8;                            {  Thermal Monitor 2}
	gestaltX86HasSupplementalSSE3 = 9;                          {  Supplemental SSE3 instructions}
	gestaltX86HasCID            = 10;                           {  L1 Context ID}
	gestaltX86HasCX16           = 13;                           {  CmpXchg16b instruction}
	gestaltX86HasxTPR           = 14;                           {  Send Task PRiority msgs}


	gestaltTranslationAttr		= $786C6174 (* 'xlat' *);						{  Translation Manager attributes  }
	gestaltTranslationMgrExists	= 0;							{  True if translation manager exists  }
	gestaltTranslationMgrHintOrder = 1;							{  True if hint order reversal in effect  }
	gestaltTranslationPPCAvail	= 2;
	gestaltTranslationGetPathAPIAvail = 3;

	gestaltExtToolboxTable		= $78747474 (* 'xttt' *);						{  Extended Toolbox trap table base  }

	gestaltUSBPrinterSharingVersion = $7A616B20 (* 'zak ' *);					{  USB Printer Sharing Version }
	gestaltUSBPrinterSharingVersionMask = $0000FFFF;			{  mask for bits in version }
	gestaltUSBPrinterSharingAttr = $7A616B20 (* 'zak ' *);						{  USB Printer Sharing Attributes }
	gestaltUSBPrinterSharingAttrMask = $FFFF0000;				{   mask for attribute bits }
	gestaltUSBPrinterSharingAttrRunning = $80000000;			{  printer sharing is running }
	gestaltUSBPrinterSharingAttrBooted = $40000000;				{  printer sharing was installed at boot time }

	{ WorldScript settings; }
	gestaltWorldScriptIIVersion	= $646F7562 (* 'doub' *);
	gestaltWorldScriptIIAttr	= $77736174 (* 'wsat' *);
	gestaltWSIICanPrintWithoutPrGeneralBit = 0;					{  bit 0 is on if WS II knows about PrinterStatus callback  }


{$ALIGN MAC68K}


end.
