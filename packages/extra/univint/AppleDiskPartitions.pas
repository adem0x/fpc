{
     File:       AppleDiskPartitions.p
 
     Contains:   The Apple disk partition scheme as defined in Inside Macintosh: Volume V.
 
     Version:    Technology: Mac OS 9
                 Release:    Universal Interfaces 3.4.2
 
     Copyright:  � 2000-2002 by Apple Computer, Inc., all rights reserved
 
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

unit AppleDiskPartitions;
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
uses MacTypes;


{$ALIGN MAC68K}

{ Block 0 Definitions }

const
	sbSIGWord					= $4552;						{  signature word for Block 0 ('ER')  }
	sbMac						= 1;							{  system type for Mac  }

	{	 Partition Map Signatures 	}
	pMapSIG						= $504D;						{  partition map signature ('PM')  }
	pdSigWord					= $5453;						{  partition map signature ('TS')  }
	oldPMSigWord				= $5453;
	newPMSigWord				= $504D;


	{	 Driver Descriptor Map 	}

type
	Block0Ptr = ^Block0;
	Block0 = packed record
		sbSig:					UInt16;									{  unique value for SCSI block 0  }
		sbBlkSize:				UInt16;									{  block size of device  }
		sbBlkCount:				UInt32;									{  number of blocks on device  }
		sbDevType:				UInt16;									{  device type  }
		sbDevId:				UInt16;									{  device id  }
		sbData:					UInt32;									{  not used  }
		sbDrvrCount:			UInt16;									{  driver descriptor count  }
		ddBlock:				UInt32;									{  1st driver's starting block  }
		ddSize:					UInt16;									{  size of 1st driver (512-byte blks)  }
		ddType:					UInt16;									{  system type (1 for Mac+)  }
		ddPad:					array [0..242] of UInt16;				{  array[0..242] of SInt16; not used  }
	end;

	{	 Driver descriptor 	}
	DDMapPtr = ^DDMap;
	DDMap = record
		ddBlock:				UInt32;									{  1st driver's starting block  }
		ddSize:					UInt16;									{  size of 1st driver (512-byte blks)  }
		ddType:					UInt16;									{  system type (1 for Mac+)  }
	end;

	{	 Constants for the ddType field of the DDMap structure. 	}

const
	kDriverTypeMacSCSI			= $0001;
	kDriverTypeMacATA			= $0701;
	kDriverTypeMacSCSIChained	= $FFFF;
	kDriverTypeMacATAChained	= $F8FF;

	{	 Partition Map Entry 	}

type
	PartitionPtr = ^Partition;
	Partition = packed record
		pmSig:					UInt16;									{  unique value for map entry blk  }
		pmSigPad:				UInt16;									{  currently unused  }
		pmMapBlkCnt:			UInt32;									{  # of blks in partition map  }
		pmPyPartStart:			UInt32;									{  physical start blk of partition  }
		pmPartBlkCnt:			UInt32;									{  # of blks in this partition  }
		pmPartName:				packed array [0..31] of UInt8;			{  ASCII partition name  }
		pmParType:				packed array [0..31] of UInt8;			{  ASCII partition type  }
		pmLgDataStart:			UInt32;									{  log. # of partition's 1st data blk  }
		pmDataCnt:				UInt32;									{  # of blks in partition's data area  }
		pmPartStatus:			UInt32;									{  bit field for partition status  }
		pmLgBootStart:			UInt32;									{  log. blk of partition's boot code  }
		pmBootSize:				UInt32;									{  number of bytes in boot code  }
		pmBootAddr:				UInt32;									{  memory load address of boot code  }
		pmBootAddr2:			UInt32;									{  currently unused  }
		pmBootEntry:			UInt32;									{  entry point of boot code  }
		pmBootEntry2:			UInt32;									{  currently unused  }
		pmBootCksum:			UInt32;									{  checksum of boot code  }
		pmProcessor:			packed array [0..15] of UInt8;			{  ASCII for the processor type  }
		pmPad:					array [0..187] of UInt16;				{  array[0..187] of SInt16; not used  }
	end;


	{	 Flags for the pmPartStatus field of the Partition data structure. 	}

const
	kPartitionAUXIsValid		= $00000001;
	kPartitionAUXIsAllocated	= $00000002;
	kPartitionAUXIsInUse		= $00000004;
	kPartitionAUXIsBootValid	= $00000008;
	kPartitionAUXIsReadable		= $00000010;
	kPartitionAUXIsWriteable	= $00000020;
	kPartitionAUXIsBootCodePositionIndependent = $00000040;
	kPartitionIsWriteable		= $00000020;
	kPartitionIsMountedAtStartup = $40000000;
	kPartitionIsStartup			= $80000000;
	kPartitionIsChainCompatible	= $00000100;
	kPartitionIsRealDeviceDriver = $00000200;
	kPartitionCanChainToNext	= $00000400;


	{	 Well known driver signatures, stored in the first four byte of pmPad. 	}
	kPatchDriverSignature		= $70744452 (* 'ptDR' *);						{  SCSI and ATA[PI] patch driver     }
	kSCSIDriverSignature		= $00010600;					{  SCSI  hard disk driver            }
	kATADriverSignature			= $77696B69 (* 'wiki' *);						{  ATA   hard disk driver            }
	kSCSICDDriverSignature		= $43447672 (* 'CDvr' *);						{  SCSI  CD-ROM    driver            }
	kATAPIDriverSignature		= $41545049 (* 'ATPI' *);						{  ATAPI CD-ROM    driver            }
	kDriveSetupHFSSignature		= $44535531 (* 'DSU1' *);						{  Drive Setup HFS partition         }


{$ALIGN MAC68K}


end.
