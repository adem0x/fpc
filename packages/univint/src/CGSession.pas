{
 *  CGSession.h
 *  CoreGraphics
 *
 *  Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
 *
 }
{       Pascal Translation:  Peter N Lewis, <peter@stairways.com.au>, August 2005 }
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

unit CGSession;
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
uses MacTypes,CFDictionary,CGBase;
{$ALIGN POWER}


{
 * Fetch the current session's dictionary
 * Returns NULL if the caller is not within a GUI session, as when the caller is a UNIX daemon,
 * or if a system is configured to not run a Quartz GUI (window server disabled)
 }
function CGSessionCopyCurrentDictionary: CFDictionaryRef; external name '_CGSessionCopyCurrentDictionary';

{
 * Predefined keys for the Session dictionaries
 * Values are provided as CFSTR() macros rather than extern C data for PEF/CFM support.
 * Constant values will remain unchanged in future releases for PEF/CFM compatibility.
 *
 * These keys are guaranteed by the system to be present in a session dictionary.
 * Additional keys and values may be defined and added to the dictionary by
 * other system components as needed.
 }
{$ifc USE_CFSTR_CONSTANT_MACROS}
{$definec kCGSessionUserIDKey CFSTRP('kCGSSessionUserIDKey')}
{$endc}
        { value is a CFNumber encoding a uid_t for the session's current user. }

{$ifc USE_CFSTR_CONSTANT_MACROS}
{$definec kCGSessionUserNameKey CFSTRP('kCGSSessionUserNameKey')}
{$endc}
        { value is a CFString encoding the session's short user name as set by loginwindow }

{$ifc USE_CFSTR_CONSTANT_MACROS}
{$definec kCGSessionConsoleSetKey CFSTRP('kCGSSessionConsoleSetKey')}
{$endc}
        { value is a CFNumber encoding a 32 bit unsigned  integer value representing a set of hardware composing a console }

{$ifc USE_CFSTR_CONSTANT_MACROS}
{$definec kCGSessionOnConsoleKey CFSTRP('kCGSSessionOnConsoleKey')}
{$endc}
        { value is a CFBoolean, kCFBooleanTrue if the session is on a console, otherwise kCFBooleanFalse }

{$ifc USE_CFSTR_CONSTANT_MACROS}
{$definec kCGSessionLoginDoneKey CFSTRP('kCGSessionLoginDoneKey')}
{$endc}
        { value is a CFBoolean, kCFBooleanTrue if login operation has been done, otherwise kCFBooleanFalse }

{
 * When the GUI session on a console changes, a notification
 * is posted via the notify_post() API.  See notify (3) and
 * notify.h for details.
 }
const
	kCGNotifyGUIConsoleSessionChanged = 'com.apple.coregraphics.GUIConsoleSessionChanged';
{ When a user logs in or out of a session we post a notification via notify_post() }
const
	kCGNotifyGUISessionUserChanged = 'com.apple.coregraphics.GUISessionUserChanged';


end.
