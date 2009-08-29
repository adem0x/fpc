{	CFXMLNode.h
	Copyright (c) 1998-2005, Apple, Inc. All rights reserved.
}
{	  Pascal Translation Updated:  Peter N Lewis, <peter@stairways.com.au>, November 2005 }
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

unit CFXMLNode;
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
uses MacTypes,CFBase,CFArray,CFDictionary,CFString,CFTree,CFURL;
{$ALIGN POWER}


const
	kCFXMLNodeCurrentVersion = 1;

type
	CFXMLNodeRef = ^SInt32; { an opaque 32-bit type }
	CFXMLNodeRefPtr = ^CFXMLNodeRef;
	CFXMLTreeRef = CFTreeRef;

{  An CFXMLNode describes an individual XML construct - like a tag, or a comment, or a string
    of character data.  Each CFXMLNode contains 3 main pieces of information - the node's type,
    the data string, and a pointer to an additional data structure.  The node's type ID is an enum
    value of type CFXMLNodeTypeID.  The data string is always a CFStringRef; the meaning of the
    string is dependent on the node's type ID. The format of the additional data is also dependent
    on the node's type; in general, there is a custom structure for each type that requires
    additional data.  See below for the mapping from type ID to meaning of the data string and
    structure of the additional data.  Note that these structures are versioned, and may change
    as the parser changes.  The current version can always be identified by kCFXMLNodeCurrentVersion;
    earlier versions can be identified and used by passing earlier values for the version number
    (although the older structures would have been removed from the header).

    An CFXMLTree is simply a CFTree whose context data is known to be an CFXMLNodeRef.  As
    such, an CFXMLTree can be used to represent an entire XML document; the CFTree
    provides the tree structure of the document, while the CFXMLNodes identify and describe
    the nodes of the tree.  An XML document can be parsed to a CFXMLTree, and a CFXMLTree
    can generate the data for the equivalent XML document - see CFXMLParser.h for more
    information on parsing XML.
    }

{ Type codes for the different possible XML nodes; this list may grow.}
type
	CFXMLNodeTypeCode = SInt32;
const
	kCFXMLNodeTypeDocument = 1;
	kCFXMLNodeTypeElement = 2;
	kCFXMLNodeTypeAttribute = 3;
	kCFXMLNodeTypeProcessingInstruction = 4;
	kCFXMLNodeTypeComment = 5;
	kCFXMLNodeTypeText = 6;
	kCFXMLNodeTypeCDATASection = 7;
	kCFXMLNodeTypeDocumentFragment = 8;
	kCFXMLNodeTypeEntity = 9;
	kCFXMLNodeTypeEntityReference = 10;
	kCFXMLNodeTypeDocumentType = 11;
	kCFXMLNodeTypeWhitespace = 12;
	kCFXMLNodeTypeNotation = 13;
	kCFXMLNodeTypeElementTypeDeclaration = 14;
	kCFXMLNodeTypeAttributeListDeclaration = 15;

type
	CFXMLElementInfoPtr = ^CFXMLElementInfo;
	CFXMLElementInfo = record
		attributes: CFDictionaryRef;
		attributeOrder: CFArrayRef;
		isEmpty: Boolean;
		_reserved1,_reserved2,_reserved3: SInt8;
	end;

type
	CFXMLProcessingInstructionInfoPtr = ^CFXMLProcessingInstructionInfo;
	CFXMLProcessingInstructionInfo = record
		dataString: CFStringRef;
	end;

type
	CFXMLDocumentInfoPtr = ^CFXMLDocumentInfo;
	CFXMLDocumentInfo = record
		sourceURL: CFURLRef;
		encoding: CFStringEncoding;
	end;

type
	CFXMLExternalIDPtr = ^CFXMLExternalID;
	CFXMLExternalID = record
		systemID: CFURLRef;
		publicID: CFStringRef;
	end;

type
	CFXMLDocumentTypeInfoPtr = ^CFXMLDocumentTypeInfo;
	CFXMLDocumentTypeInfo = record
		externalID: CFXMLExternalID;
	end;

type
	CFXMLNotationInfoPtr = ^CFXMLNotationInfo;
	CFXMLNotationInfo = record
		externalID: CFXMLExternalID;
	end;

type
	CFXMLElementTypeDeclarationInfoPtr = ^CFXMLElementTypeDeclarationInfo;
	CFXMLElementTypeDeclarationInfo = record
{ This is expected to change in future versions }
		contentDescription: CFStringRef;
	end;

type
	CFXMLAttributeDeclarationInfoPtr = ^CFXMLAttributeDeclarationInfo;
	CFXMLAttributeDeclarationInfo = record
{ This is expected to change in future versions }
		attributeName: CFStringRef;
		typeString: CFStringRef;
		defaultString: CFStringRef;
	end;

type
	CFXMLAttributeListDeclarationInfoPtr = ^CFXMLAttributeListDeclarationInfo;
	CFXMLAttributeListDeclarationInfo = record
		numberOfAttributes: CFIndex;
		attributes: CFXMLAttributeDeclarationInfoPtr;
	end;

type
	CFXMLEntityTypeCode = SInt32;
const
	kCFXMLEntityTypeParameter = 0;							{  Implies parsed, internal  }
	kCFXMLEntityTypeParsedInternal = 1;
	kCFXMLEntityTypeParsedExternal = 2;
	kCFXMLEntityTypeUnparsed = 3;
	kCFXMLEntityTypeCharacter = 4;

type
	CFXMLEntityInfoPtr = ^CFXMLEntityInfo;
	CFXMLEntityInfo = record
		entityType: CFXMLEntityTypeCode;
		replacementText: CFStringRef;     { NULL if entityType is external or unparsed }
		entityID: CFXMLExternalID;          { entityID.systemID will be NULL if entityType is internal }
		notationName: CFStringRef;        { NULL if entityType is parsed }
	end;

type
	CFXMLEntityReferenceInfoPtr = ^CFXMLEntityReferenceInfo;
	CFXMLEntityReferenceInfo = record
		entityType: CFXMLEntityTypeCode;
	end;

{
 dataTypeCode                       meaning of dataString                format of infoPtr
 ===========                        =====================                =================
 kCFXMLNodeTypeDocument             <currently unused>                   CFXMLDocumentInfo *
 kCFXMLNodeTypeElement              tag name                             CFXMLElementInfo *
 kCFXMLNodeTypeAttribute            <currently unused>                   <currently unused>
 kCFXMLNodeTypeProcessingInstruction   name of the target                   CFXMLProcessingInstructionInfo *
 kCFXMLNodeTypeComment              text of the comment                  NULL
 kCFXMLNodeTypeText                 the text's contents                  NULL
 kCFXMLNodeTypeCDATASection         text of the CDATA                    NULL
 kCFXMLNodeTypeDocumentFragment     <currently unused>                   <currently unused>
 kCFXMLNodeTypeEntity               name of the entity                   CFXMLEntityInfo *
 kCFXMLNodeTypeEntityReference      name of the referenced entity        CFXMLEntityReferenceInfo *
 kCFXMLNodeTypeDocumentType         name given as top-level element      CFXMLDocumentTypeInfo *
 kCFXMLNodeTypeWhitespace           text of the whitespace               NULL
 kCFXMLNodeTypeNotation             notation name                        CFXMLNotationInfo *
 kCFXMLNodeTypeElementTypeDeclaration     tag name                       CFXMLElementTypeDeclarationInfo *
 kCFXMLNodeTypeAttributeListDeclaration   tag name                       CFXMLAttributeListDeclarationInfo *
}

function CFXMLNodeGetTypeID: CFTypeID; external name '_CFXMLNodeGetTypeID';

{ Creates a new node based on xmlType, dataString, and additionalInfoPtr.  version (together with xmlType) determines the expected structure of additionalInfoPtr }
function CFXMLNodeCreate( alloc: CFAllocatorRef; xmlType: CFXMLNodeTypeCode; dataString: CFStringRef; additionalInfoPtr: {const} UnivPtr; version: CFIndex ): CFXMLNodeRef; external name '_CFXMLNodeCreate';

{ Creates a copy of origNode (which may not be NULL). }
function CFXMLNodeCreateCopy( alloc: CFAllocatorRef; origNode: CFXMLNodeRef ): CFXMLNodeRef; external name '_CFXMLNodeCreateCopy';

function CFXMLNodeGetTypeCode( node: CFXMLNodeRef ): CFXMLNodeTypeCode; external name '_CFXMLNodeGetTypeCode';

function CFXMLNodeGetString( node: CFXMLNodeRef ): CFStringRef; external name '_CFXMLNodeGetString';

function CFXMLNodeGetInfoPtr( node: CFXMLNodeRef ): UnivPtr; external name '_CFXMLNodeGetInfoPtr';

function CFXMLNodeGetVersion( node: CFXMLNodeRef ): CFIndex; external name '_CFXMLNodeGetVersion';

{ CFXMLTreeRef }

{ Creates a childless, parentless tree from node }
function CFXMLTreeCreateWithNode( allocator: CFAllocatorRef; node: CFXMLNodeRef ): CFXMLTreeRef; external name '_CFXMLTreeCreateWithNode';

{ Extracts and returns the node stored in xmlTree }
function CFXMLTreeGetNode( xmlTree: CFXMLTreeRef ): CFXMLNodeRef; external name '_CFXMLTreeGetNode';


end.
