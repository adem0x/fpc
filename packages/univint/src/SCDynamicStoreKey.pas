{
 * Copyright (c) 2000-2002 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 * 
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY of ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES of MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 * 
 * @APPLE_LICENSE_HEADER_END@
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

unit SCDynamicStoreKey;
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
uses MacTypes,CFBase;
{$ALIGN MAC68K}

{!
	@header SCDynamicStoreKey
 }

{
 * SCDynamicStoreKeyCreate*
 * - convenience routines that create a CFString key for an item in the store
 }

{!
	@function SCDynamicStoreKeyCreate
	@discussion Creates a store key using the given format.
 }
// function SCDynamicStoreKeyCreate( allocator: CFAllocatorRef; fmt: CFStringRef; ... ): CFStringRef;

{!
	@function SCDynamicStoreKeyCreateNetworkGlobalEntity
 }
function SCDynamicStoreKeyCreateNetworkGlobalEntity( allocator: CFAllocatorRef; domain: CFStringRef; entity: CFStringRef ): CFStringRef; external name '_SCDynamicStoreKeyCreateNetworkGlobalEntity';

{!
	@function SCDynamicStoreKeyCreateNetworkInterface
 }
function SCDynamicStoreKeyCreateNetworkInterface( allocator: CFAllocatorRef; domain: CFStringRef ): CFStringRef; external name '_SCDynamicStoreKeyCreateNetworkInterface';

{!
	@function SCDynamicStoreKeyCreateNetworkInterfaceEntity
 }
function SCDynamicStoreKeyCreateNetworkInterfaceEntity( allocator: CFAllocatorRef; domain: CFStringRef; ifname: CFStringRef; entity: CFStringRef ): CFStringRef; external name '_SCDynamicStoreKeyCreateNetworkInterfaceEntity';

{!
	@function SCDynamicStoreKeyCreateNetworkServiceEntity
 }
function SCDynamicStoreKeyCreateNetworkServiceEntity( allocator: CFAllocatorRef; domain: CFStringRef; serviceID: CFStringRef; entity: CFStringRef ): CFStringRef; external name '_SCDynamicStoreKeyCreateNetworkServiceEntity';

{!
	@function SCDynamicStoreKeyCreateComputerName
	@discussion Creates a key that can be used by the SCDynamicStoreSetNotificationKeys()
		function to receive notifications when the current
		computer/host name changes.
	@result A notification string for the current computer/host name.
}
function SCDynamicStoreKeyCreateComputerName( allocator: CFAllocatorRef ): CFStringRef; external name '_SCDynamicStoreKeyCreateComputerName';

{!
	@function SCDynamicStoreKeyCreateConsoleUser
	@discussion Creates a key that can be used by the SCDynamicStoreSetNotificationKeys()
		function to receive notifications when the current "Console"
		user changes.
	@result A notification string for the current "Console" user.
}
function SCDynamicStoreKeyCreateConsoleUser( allocator: CFAllocatorRef ): CFStringRef; external name '_SCDynamicStoreKeyCreateConsoleUser';

{!
	@function SCDynamicStoreKeyCreateHostNames
	@discussion Creates a key that can be used in conjunction with
		SCDynamicStoreSetNotificationKeys() to receive
		notifications when the HostNames entity changes.  The
		HostNames entity contains the LocalHostName.
	@result A notification string for the HostNames entity.
}
function SCDynamicStoreKeyCreateHostNames( allocator: CFAllocatorRef ): CFStringRef; external name '_SCDynamicStoreKeyCreateHostNames';

{!
	@function SCDynamicStoreKeyCreateLocation
	@discussion Creates a key that can be used in conjunction with
		SCDynamicStoreSetNotificationKeys() to receive
		notifications when the "location" identifier changes.
	@result A notification string for the current "location" identifier.
}
function SCDynamicStoreKeyCreateLocation( allocator: CFAllocatorRef ): CFStringRef; external name '_SCDynamicStoreKeyCreateLocation';

{!
	@function SCDynamicStoreKeyCreateProxies
	@discussion Creates a key that can be used by the SCDynamicStoreSetNotificationKeys()
		function to receive notifications when the current network proxy
		settings (HTTP, FTP, ...) are changed.
	@result A notification string for the current proxy settings.
}
function SCDynamicStoreKeyCreateProxies( allocator: CFAllocatorRef ): CFStringRef; external name '_SCDynamicStoreKeyCreateProxies';

end.
