{	CFBitVector.h
	Copyright (c) 1998-2005, Apple, Inc. All rights reserved.
}
{       Pascal Translation:  Peter N Lewis, <peter@stairways.com.au>, 2004 }
{       Pascal Translation Updated:  Peter N Lewis, <peter@stairways.com.au>, September 2005 }
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

unit CFBitVector;
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
uses MacTypes,CFBase;
{$ALIGN POWER}


type
	CFBit = UInt32;

type
	CFBitVectorRef = ^SInt32; { an opaque 32-bit type }
	CFMutableBitVectorRef = ^SInt32; { an opaque 32-bit type }

function CFBitVectorGetTypeID: CFTypeID; external name '_CFBitVectorGetTypeID';

function CFBitVectorCreate( allocator: CFAllocatorRef; bytes: UnivPtr; numBits: CFIndex ): CFBitVectorRef; external name '_CFBitVectorCreate';
function CFBitVectorCreateCopy( allocator: CFAllocatorRef; bv: CFBitVectorRef ): CFBitVectorRef; external name '_CFBitVectorCreateCopy';
function CFBitVectorCreateMutable( allocator: CFAllocatorRef; capacity: CFIndex ): CFMutableBitVectorRef; external name '_CFBitVectorCreateMutable';
function CFBitVectorCreateMutableCopy( allocator: CFAllocatorRef; capacity: CFIndex; bv: CFBitVectorRef ): CFMutableBitVectorRef; external name '_CFBitVectorCreateMutableCopy';

function CFBitVectorGetCount( bv: CFBitVectorRef ): CFIndex; external name '_CFBitVectorGetCount';
function CFBitVectorGetCountOfBit( bv: CFBitVectorRef; range: CFRange; value: CFBit ): CFIndex; external name '_CFBitVectorGetCountOfBit';
function CFBitVectorContainsBit( bv: CFBitVectorRef; range: CFRange; value: CFBit ): Boolean; external name '_CFBitVectorContainsBit';
function CFBitVectorGetBitAtIndex( bv: CFBitVectorRef; idx: CFIndex ): CFBit; external name '_CFBitVectorGetBitAtIndex';
procedure CFBitVectorGetBits( bv: CFBitVectorRef; range: CFRange; bytes: UnivPtr ); external name '_CFBitVectorGetBits';
function CFBitVectorGetFirstIndexOfBit( bv: CFBitVectorRef; range: CFRange; value: CFBit ): CFIndex; external name '_CFBitVectorGetFirstIndexOfBit';
function CFBitVectorGetLastIndexOfBit( bv: CFBitVectorRef; range: CFRange; value: CFBit ): CFIndex; external name '_CFBitVectorGetLastIndexOfBit';

procedure CFBitVectorSetCount( bv: CFMutableBitVectorRef; count: CFIndex ); external name '_CFBitVectorSetCount';
procedure CFBitVectorFlipBitAtIndex( bv: CFMutableBitVectorRef; idx: CFIndex ); external name '_CFBitVectorFlipBitAtIndex';
procedure CFBitVectorFlipBits( bv: CFMutableBitVectorRef; range: CFRange ); external name '_CFBitVectorFlipBits';
procedure CFBitVectorSetBitAtIndex( bv: CFMutableBitVectorRef; idx: CFIndex; value: CFBit ); external name '_CFBitVectorSetBitAtIndex';
procedure CFBitVectorSetBits( bv: CFMutableBitVectorRef; range: CFRange; value: CFBit ); external name '_CFBitVectorSetBits';
procedure CFBitVectorSetAllBits( bv: CFMutableBitVectorRef; value: CFBit ); external name '_CFBitVectorSetAllBits';


end.
