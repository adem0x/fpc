{
    This file is part of the Free Pascal run time library.

    A file in Amiga system run time library.
    Copyright (c) 1998-2003 by Nils Sjoholm
    member of the Amiga RTL development team.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{
    History:
    Added overlay functions for Pchar->Strings, functions
    and procedures. Now you can mix PChar and Strings e.g
    OpenLibrary('whatis.library',37). No need to cast to
    a PChar.
    14 Jul 2000.

    Changed ReadArgs, removed the var for the second arg.
    Changed DOSRename from longint to a boolean.
    Aug 04 2000.

    Added functions and procedures with array of const.
    For use with fpc 1.0.7

    You have to use systemvartags. Check out that unit.
    09 Nov 2002.

    Added the define use_amiga_smartlink.
    13 Jan 2003.

    Update for AmigaOS 3.9.
    Added some const.
    26 Jan 2003.

    Changed integer > smallint.
    09 Feb 2003.

    nils.sjoholm@mailbox.swipnet.se
}

unit amigados;

INTERFACE

uses exec, utility, timer;

const

{ Predefined Amiga DOS global constants }

    DOSTRUE     = -1;
    DOSFALSE    =  0;

{ Mode parameter to Open() }

    MODE_OLDFILE        = 1005;         { Open existing file read/write
                                          positioned at beginning of file. }
    MODE_NEWFILE        = 1006;         { Open freshly created file (delete
                                          old file) read/write }
    MODE_READWRITE      = 1004;         { Open old file w/exclusive lock }

{ Relative position to Seek() }

    OFFSET_BEGINNING    = -1;           { relative to Begining Of File }
    OFFSET_CURRENT      = 0;            { relative to Current file position }
    OFFSET_END          = 1;            { relative to End Of File }

    BITSPERBYTE         = 8;
    BYTESPERLONG        = 4;
    BITSPERLONG         = 32;
    MAXINT              = $7FFFFFFF;
    MININT              = $80000000;

{ Passed as type to Lock() }

    SHARED_LOCK         = -2;           { File is readable by others }
    ACCESS_READ         = -2;           { Synonym }
    EXCLUSIVE_LOCK      = -1;           { No other access allowed }
    ACCESS_WRITE        = -1;           { Synonym }

type

    FileHandle  = BPTR;
    FileLock    = BPTR;

    pDateStamp = ^tDateStamp;
    tDateStamp = record
        ds_Days         : Longint;      { Number of days since Jan. 1, 1978 }
        ds_Minute       : Longint;      { Number of minutes past midnight }
        ds_Tick         : Longint;      { Number of ticks past minute }
    end;

const

    TICKS_PER_SECOND    = 50;           { Number of ticks in one second }

{$PACKRECORDS 4}
type

{ Returned by Examine() and ExInfo(), must be on a 4 byte boundary }

    PFileInfoBlock = ^TFileInfoBlock;
    TFileInfoBlock = record
        fib_DiskKey      : LongInt;
        fib_DirEntryType : LongInt;
                        { type of Directory. If < 0, then a plain file.
                          If > 0 a directory }
        fib_FileName     : Array [0..107] of Char;
                        { Null terminated. Max 30 chars used for now }
        fib_Protection   : LongInt;
                        { bit mask of protection, rwxd are 3-0. }
        fib_EntryType    : LongInt;
        fib_Size         : LongInt;      { Number of bytes in file }
        fib_NumBlocks    : LongInt;      { Number of blocks in file }
        fib_Date         : TDateStamp;   { Date file last changed }
        fib_Comment      : Array [0..79] of Char;
                        { Null terminated comment associated with file }
        fib_OwnerUID     : Word;
        fib_OwnerGID     : Word;
        fib_Reserved     : Array [0..31] of Char;
    end;

const

{ FIB stands for FileInfoBlock }

{* FIBB are bit definitions, FIBF are field definitions *}
{* Regular RWED bits are 0 == allowed. *}
{* NOTE: GRP and OTR RWED permissions are 0 == not allowed! *}
{* Group and Other permissions are not directly handled by the filesystem *}

    FIBB_OTR_READ       = 15;   {* Other: file is readable *}
    FIBB_OTR_WRITE      = 14;   {* Other: file is writable *}
    FIBB_OTR_EXECUTE    = 13;   {* Other: file is executable *}
    FIBB_OTR_DELETE     = 12;   {* Other: prevent file from being deleted *}
    FIBB_GRP_READ       = 11;   {* Group: file is readable *}
    FIBB_GRP_WRITE      = 10;   {* Group: file is writable *}
    FIBB_GRP_EXECUTE    = 9;    {* Group: file is executable *}
    FIBB_GRP_DELETE     = 8;    {* Group: prevent file from being deleted *}

    FIBB_SCRIPT         = 6;    { program is a script (execute) file }
    FIBB_PURE           = 5;    { program is reentrant and rexecutable}
    FIBB_ARCHIVE        = 4;    { cleared whenever file is changed }
    FIBB_READ           = 3;    { ignored by old filesystem }
    FIBB_WRITE          = 2;    { ignored by old filesystem }
    FIBB_EXECUTE        = 1;    { ignored by system, used by Shell }
    FIBB_DELETE         = 0;    { prevent file from being deleted }

    FIBF_OTR_READ      = (1 shl FIBB_OTR_READ);
    FIBF_OTR_WRITE     = (1 shl FIBB_OTR_WRITE);
    FIBF_OTR_EXECUTE   = (1 shl FIBB_OTR_EXECUTE);
    FIBF_OTR_DELETE    = (1 shl FIBB_OTR_DELETE);
    FIBF_GRP_READ      = (1 shl FIBB_GRP_READ);
    FIBF_GRP_WRITE     = (1 shl FIBB_GRP_WRITE);
    FIBF_GRP_EXECUTE   = (1 shl FIBB_GRP_EXECUTE);
    FIBF_GRP_DELETE    = (1 shl FIBB_GRP_DELETE);

    FIBF_SCRIPT         = 64;
    FIBF_PURE           = 32;
    FIBF_ARCHIVE        = 16;
    FIBF_READ           = 8;
    FIBF_WRITE          = 4;
    FIBF_EXECUTE        = 2;
    FIBF_DELETE         = 1;

{* Standard maximum length for an error string from fault.  However, most *}
{* error strings should be kept under 60 characters if possible.  Don't   *}
{* forget space for the header you pass in. *}

    FAULT_MAX  = 82;

{* All BCPL data must be long Integer aligned.  BCPL pointers are the long Integer
 *  address (i.e byte address divided by 4 (>>2)) *}

{* BCPL strings have a length in the first byte and then the characters.
 * For example:  s[0]=3 s[1]=S s[2]=Y s[3]=S                 *}


type

{ returned by Info(), must be on a 4 byte boundary }

    PInfoData = ^TInfoData;
    TInfoData = record
        id_NumSoftErrors        : LongInt;      { number of soft errors on disk }
        id_UnitNumber           : LongInt;      { Which unit disk is (was) mounted on }
        id_DiskState            : LongInt;      { See defines below }
        id_NumBlocks            : LongInt;      { Number of blocks on disk }
        id_NumBlocksUsed        : LongInt;      { Number of block in use }
        id_BytesPerBlock        : LongInt;
        id_DiskType             : LongInt;      { Disk type code }
        id_VolumeNode           : BPTR;         { BCPL pointer to volume node }
        id_InUse                : LongInt;      { Flag, zero if not in use }
    end;

{$PACKRECORDS NORMAL}

const

{ ID stands for InfoData }

        { Disk states }

    ID_WRITE_PROTECTED  = 80;   { Disk is write protected }
    ID_VALIDATING       = 81;   { Disk is currently being validated }
    ID_VALIDATED        = 82;   { Disk is consistent and writeable }

const
 ID_NO_DISK_PRESENT     = -1;
 ID_UNREADABLE_DISK     = $42414400;   { 'BAD\0' }
 ID_DOS_DISK            = $444F5300;   { 'DOS\0' }
 ID_FFS_DISK            = $444F5301;   { 'DOS\1' }
 ID_NOT_REALLY_DOS      = $4E444F53;   { 'NDOS'  }
 ID_KICKSTART_DISK      = $4B49434B;   { 'KICK'  }
 ID_MSDOS_DISK          = $4d534400;   { 'MSD\0' }
 ID_SFS_BE_DISK         = $53465300;   { 'SFS\0' }
 ID_SFS_LE_DISK         = $73667300;   { 'sfs\0' }

{ Errors from IoErr(), etc. }
 ERROR_NO_FREE_STORE              = 103;
 ERROR_TASK_TABLE_FULL            = 105;
 ERROR_BAD_TEMPLATE               = 114;
 ERROR_BAD_NUMBER                 = 115;
 ERROR_REQUIRED_ARG_MISSING       = 116;
 ERROR_KEY_NEEDS_ARG              = 117;
 ERROR_TOO_MANY_ARGS              = 118;
 ERROR_UNMATCHED_QUOTES           = 119;
 ERROR_LINE_TOO_LONG              = 120;
 ERROR_FILE_NOT_OBJECT            = 121;
 ERROR_INVALID_RESIDENT_LIBRARY   = 122;
 ERROR_NO_DEFAULT_DIR             = 201;
 ERROR_OBJECT_IN_USE              = 202;
 ERROR_OBJECT_EXISTS              = 203;
 ERROR_DIR_NOT_FOUND              = 204;
 ERROR_OBJECT_NOT_FOUND           = 205;
 ERROR_BAD_STREAM_NAME            = 206;
 ERROR_OBJECT_TOO_LARGE           = 207;
 ERROR_ACTION_NOT_KNOWN           = 209;
 ERROR_INVALID_COMPONENT_NAME     = 210;
 ERROR_INVALID_LOCK               = 211;
 ERROR_OBJECT_WRONG_TYPE          = 212;
 ERROR_DISK_NOT_VALIDATED         = 213;
 ERROR_DISK_WRITE_PROTECTED       = 214;
 ERROR_RENAME_ACROSS_DEVICES      = 215;
 ERROR_DIRECTORY_NOT_EMPTY        = 216;
 ERROR_TOO_MANY_LEVELS            = 217;
 ERROR_DEVICE_NOT_MOUNTED         = 218;
 ERROR_SEEK_ERROR                 = 219;
 ERROR_COMMENT_TOO_BIG            = 220;
 ERROR_DISK_FULL                  = 221;
 ERROR_DELETE_PROTECTED           = 222;
 ERROR_WRITE_PROTECTED            = 223;
 ERROR_READ_PROTECTED             = 224;
 ERROR_NOT_A_DOS_DISK             = 225;
 ERROR_NO_DISK                    = 226;
 ERROR_NO_MORE_ENTRIES            = 232;
{ added for 1.4 }
 ERROR_IS_SOFT_LINK               = 233;
 ERROR_OBJECT_LINKED              = 234;
 ERROR_BAD_HUNK                   = 235;
 ERROR_NOT_IMPLEMENTED            = 236;
 ERROR_RECORD_NOT_LOCKED          = 240;
 ERROR_LOCK_COLLISION             = 241;
 ERROR_LOCK_TIMEOUT               = 242;
 ERROR_UNLOCK_ERROR               = 243;

{ error codes 303-305 are defined in dosasl.h }

{ These are the return codes used by convention by AmigaDOS commands }
{ See FAILAT and IF for relvance to EXECUTE files                    }
 RETURN_OK                        =   0;  { No problems, success }
 RETURN_WARN                      =   5;  { A warning only }
 RETURN_ERROR                     =  10;  { Something wrong }
 RETURN_FAIL                      =  20;  { Complete or severe failure}

{ Bit numbers that signal you that a user has issued a break }
 SIGBREAKB_CTRL_C   = 12;
 SIGBREAKB_CTRL_D   = 13;
 SIGBREAKB_CTRL_E   = 14;
 SIGBREAKB_CTRL_F   = 15;

{ Bit fields that signal you that a user has issued a break }
{ for example:  if (SetSignal(0,0) & SIGBREAKF_CTRL_C) cleanup_and_exit(); }
 SIGBREAKF_CTRL_C   = 4096;
 SIGBREAKF_CTRL_D   = 8192;
 SIGBREAKF_CTRL_E   = 16384;
 SIGBREAKF_CTRL_F   = 32768;

{ Values returned by SameLock() }
 LOCK_SAME             =  0;
 LOCK_SAME_HANDLER     =  1;       { actually same volume }
 LOCK_DIFFERENT        =  -1;

{ types for ChangeMode() }
 CHANGE_LOCK    = 0;
 CHANGE_FH      = 1;

{ Values for MakeLink() }
 LINK_HARD      = 0;
 LINK_SOFT      = 1;       { softlinks are not fully supported yet }

{ values returned by  }
 ITEM_EQUAL     = -2;              { "=" Symbol }
 ITEM_ERROR     = -1;              { error }
 ITEM_NOTHING   = 0;               { *N, ;, endstreamch }
 ITEM_UNQUOTED  = 1;               { unquoted item }
 ITEM_QUOTED    = 2;               { quoted item }

{ types for AllocDosObject/FreeDosObject }
 DOS_FILEHANDLE        =  0;       { few people should use this }
 DOS_EXALLCONTROL      =  1;       { Must be used to allocate this! }
 DOS_FIB               =  2;       { useful }
 DOS_STDPKT            =  3;       { for doing packet-level I/O }
 DOS_CLI               =  4;       { for shell-writers, etc }
 DOS_RDARGS            =  5;       { for ReadArgs if you pass it in }


{
 *      Data structures and equates used by the V1.4 DOS functions
 * StrtoDate() and DatetoStr()
 }

{--------- String/Date structures etc }
type
       PDateTime = ^TDateTime;
       TDateTime = record
        dat_Stamp   : TDateStamp;      { DOS DateStamp }
        dat_Format,                    { controls appearance of dat_StrDate }
        dat_Flags   : Byte;           { see BITDEF's below }
        dat_StrDay,                    { day of the week string }
        dat_StrDate,                   { date string }
        dat_StrTime : STRPTR;          { time string }
       END;

{ You need this much room for each of the DateTime strings: }
const
 LEN_DATSTRING =  16;

{      flags for dat_Flags }

 DTB_SUBST      = 0;               { substitute Today, Tomorrow, etc. }
 DTF_SUBST      = 1;
 DTB_FUTURE     = 1;               { day of the week is in future }
 DTF_FUTURE     = 2;

{
 *      date format values
 }

 FORMAT_DOS     = 0;               { dd-mmm-yy }
 FORMAT_INT     = 1;               { yy-mm-dd  }
 FORMAT_USA     = 2;               { mm-dd-yy  }
 FORMAT_CDN     = 3;               { dd-mm-yy  }
 FORMAT_MAX     = FORMAT_CDN;
 FORMAT_DEF     = 4;            { use default format, as defined
                                           by locale; if locale not
                                           available, use FORMAT_DOS
                                           instead }

{**********************************************************************
************************ PATTERN MATCHING ******************************
************************************************************************

* structure expected by MatchFirst, MatchNext.
* Allocate this structure and initialize it as follows:
*
* Set ap_BreakBits to the signal bits (CDEF) that you want to take a
* break on, or NULL, if you don't want to convenience the user.
*
* If you want to have the FULL PATH NAME of the files you found,
* allocate a buffer at the END of this structure, and put the size of
* it into ap_Strlen.  If you don't want the full path name, make sure
* you set ap_Strlen to zero.  In this case, the name of the file, and stats
* are available in the ap_Info, as per usual.
*
* Then call MatchFirst() and then afterwards, MatchNext() with this structure.
* You should check the return value each time (see below) and take the
* appropriate action, ultimately calling MatchEnd() when there are
* no more files and you are done.  You can tell when you are done by
* checking for the normal AmigaDOS return code ERROR_NO_MORE_ENTRIES.
*
}

type
       PAChain = ^TAChain;
       TAChain = record
        an_Child,
        an_Parent   : PAChain;
        an_Lock     : BPTR;
        an_Info     : TFileInfoBlock;
        an_Flags    : Shortint;
        an_String   : Array[0..0] of Char;   { FIX!! }
       END;

       PAnchorPath = ^TAnchorPath;
       TAnchorPath = record
        case SmallInt of
        0 : (
        ap_First      : PAChain;
        ap_Last       : PAChain;
        );
        1 : (
        ap_Base,                    { pointer to first anchor }
        ap_Current    : PAChain;    { pointer to last anchor }
        ap_BreakBits,               { Bits we want to break on }
        ap_FoundBreak : LongInt;    { Bits we broke on. Also returns ERROR_BREAK }
        ap_Flags      : Shortint;       { New use for extra Integer. }
        ap_Reserved   : Shortint;
        ap_Strlen     : SmallInt;       { This is what ap_Length used to be }
        ap_Info       : TFileInfoBlock;
        ap_Buf        : Array[0..0] of Char;     { Buffer for path name, allocated by user !! }
        { FIX! }
        );
       END;


const
    APB_DOWILD    =  0;       { User option ALL }
    APF_DOWILD    =  1;

    APB_ITSWILD   =  1;       { Set by MatchFirst, used by MatchNext  }
    APF_ITSWILD   =  2;       { Application can test APB_ITSWILD, too }
                                { (means that there's a wildcard        }
                                { in the pattern after calling          }
                                { MatchFirst).                          }

    APB_DODIR     =  2;       { Bit is SET IF a DIR node should be }
    APF_DODIR     =  4;       { entered. Application can RESET this }
                                { bit after MatchFirst/MatchNext to AVOID }
                                { entering a dir. }

    APB_DIDDIR    =  3;       { Bit is SET for an "expired" dir node. }
    APF_DIDDIR    =  8;

    APB_NOMEMERR  =  4;       { Set on memory error }
    APF_NOMEMERR  =  16;

    APB_DODOT     =  5;       { IF set, allow conversion of '.' to }
    APF_DODOT     =  32;      { CurrentDir }

    APB_DirChanged  = 6;       { ap_Current->an_Lock changed }
    APF_DirChanged  = 64;      { since last MatchNext call }


    DDB_PatternBit  = 0;
    DDF_PatternBit  = 1;
    DDB_ExaminedBit = 1;
    DDF_ExaminedBit = 2;
    DDB_Completed   = 2;
    DDF_Completed   = 4;
    DDB_AllBit      = 3;
    DDF_AllBit      = 8;
    DDB_Single      = 4;
    DDF_Single      = 16;

{
 * Constants used by wildcard routines, these are the pre-parsed tokens
 * referred to by pattern match.  It is not necessary for you to do
 * anything about these, MatchFirst() MatchNext() handle all these for you.
 }

    P_ANY         =  $80;    { Token for '*' or '#?  }
    P_SINGLE      =  $81;    { Token for '?' }
    P_ORSTART     =  $82;    { Token for '(' }
    P_ORNEXT      =  $83;    { Token for '|' }
    P_OREND       =  $84;    { Token for ')' }
    P_NOT         =  $85;    { Token for '~' }
    P_NOTEND      =  $86;    { Token for }
    P_NOTCLASS    =  $87;    { Token for '^' }
    P_CLASS       =  $88;    { Token for '[]' }
    P_REPBEG      =  $89;    { Token for '[' }
    P_REPEND      =  $8A;    { Token for ']' }
    P_STOP        =  $8B;    { token to force end of evaluation }

{ Values for an_Status, NOTE: These are the actual bit numbers }

    COMPLEX_BIT   =  1;       { Parsing complex pattern }
    EXAMINE_BIT   =  2;       { Searching directory }

{
 * Returns from MatchFirst(), MatchNext()
 * You can also get dos error returns, such as ERROR_NO_MORE_ENTRIES,
 * these are in the dos.h file.
 }

    ERROR_BUFFER_OVERFLOW  = 303;     { User OR internal buffer overflow }
    ERROR_BREAK            = 304;     { A break character was received }
    ERROR_NOT_EXECUTABLE   = 305;     { A file has E bit cleared }

{   hunk types }
     HUNK_UNIT      = 999 ;
     HUNK_NAME      = 1000;
     HUNK_CODE      = 1001;
     HUNK_DATA      = 1002;
     HUNK_BSS       = 1003;
     HUNK_RELOC32   = 1004;
     HUNK_RELOC16   = 1005;
     HUNK_RELOC8    = 1006;
     HUNK_EXT       = 1007;
     HUNK_SYMBOL    = 1008;
     HUNK_DEBUG     = 1009;
     HUNK_END       = 1010;
     HUNK_HEADER    = 1011;

     HUNK_OVERLAY   = 1013;
     HUNK_BREAK     = 1014;

     HUNK_DREL32    = 1015;
     HUNK_DREL16    = 1016;
     HUNK_DREL8     = 1017;

     HUNK_LIB       = 1018;
     HUNK_INDEX     = 1019;

{   hunk_ext sub-types }
     EXT_SYMB       = 0  ;     {   symbol table }
     EXT_DEF        = 1  ;     {   relocatable definition }
     EXT_ABS        = 2  ;     {   Absolute definition }
     EXT_RES        = 3  ;     {   no longer supported }
     EXT_REF32      = 129;     {   32 bit reference to symbol }
     EXT_COMMON     = 130;     {   32 bit reference to COMMON block }
     EXT_REF16      = 131;     {   16 bit reference to symbol }
     EXT_REF8       = 132;     {    8 bit reference to symbol }
     EXT_DEXT32     = 133;     {   32 bit data releative reference }
     EXT_DEXT16     = 134;     {   16 bit data releative reference }
     EXT_DEXT8      = 135;     {    8 bit data releative reference }


type

{ All DOS processes have this structure }
{ Create and Device Proc returns pointer to the MsgPort in this structure }
{ dev_proc = Address(SmallInt(DeviceProc()) - SizeOf(Task)) }

    pProcess = ^tProcess;
    tProcess = record
        pr_Task         : tTask;
        pr_MsgPort      : tMsgPort;     { This is BPTR address from DOS functions  }
        pr_Pad          : SmallInt;         { Remaining variables on 4 byte boundaries }
        pr_SegList      : BPTR;         { Array of seg lists used by this process  }
        pr_StackSize    : LongInt;      { Size of process stack in bytes            }
        pr_GlobVec      : Pointer;      { Global vector for this process (BCPL)    }
        pr_TaskNum      : LongInt;      { CLI task number of zero if not a CLI      }
        pr_StackBase    : BPTR;         { Ptr to high memory end of process stack  }
        pr_Result2      : LongInt;      { Value of secondary result from last call }
        pr_CurrentDir   : BPTR;         { Lock associated with current directory   }
        pr_CIS          : BPTR;         { Current CLI Input Stream                  }
        pr_COS          : BPTR;         { Current CLI Output Stream                 }
        pr_ConsoleTask  : Pointer;      { Console handler process for current window}
        pr_FileSystemTask : Pointer;    { File handler process for current drive   }
        pr_CLI          : BPTR;         { pointer to ConsoleLineInterpreter         }
        pr_ReturnAddr   : Pointer;      { pointer to previous stack frame           }
        pr_PktWait      : Pointer;      { Function to be called when awaiting msg  }
        pr_WindowPtr    : Pointer;      { Window for error printing }
        { following definitions are new with 2.0 }
        pr_HomeDir      : BPTR;         { Home directory of executing program      }
        pr_Flags        : LongInt;      { flags telling dos about process          }
        pr_ExitCode     : Pointer;      { code to call on exit of program OR NULL  }
        pr_ExitData     : LongInt;      { Passed as an argument to pr_ExitCode.    }
        pr_Arguments    : STRPTR;       { Arguments passed to the process at start }
        pr_LocalVars    : tMinList;      { Local environment variables             }
        pr_ShellPrivate : ULONG;        { for the use of the current shell         }
        pr_CES          : BPTR;         { Error stream - IF NULL, use pr_COS       }
    end;

{
 * Flags for pr_Flags
 }
const
 PRB_FREESEGLIST       =  0 ;
 PRF_FREESEGLIST       =  1 ;
 PRB_FREECURRDIR       =  1 ;
 PRF_FREECURRDIR       =  2 ;
 PRB_FREECLI           =  2 ;
 PRF_FREECLI           =  4 ;
 PRB_CLOSEINPUT        =  3 ;
 PRF_CLOSEINPUT        =  8 ;
 PRB_CLOSEOUTPUT       =  4 ;
 PRF_CLOSEOUTPUT       =  16;
 PRB_FREEARGS          =  5 ;
 PRF_FREEARGS          =  32;


{ The long SmallInt address (BPTR) of this structure is returned by
 * Open() and other routines that return a file.  You need only worry
 * about this struct to do async io's via PutMsg() instead of
 * standard file system calls }

type

    PFileHandle = ^TFileHandle;
    TFileHandle = record
        fh_Link         : PMessage;   { EXEC message        }
        fh_Port         : PMsgPort;   { Reply port for the packet }
        fh_Type         : PMsgPort;   { Port to do PutMsg() to
                                          Address is negative if a plain file }
        fh_Buf          : LongInt;
        fh_Pos          : LongInt;
        fh_End          : LongInt;
        fh_Func1        : LongInt;
        fh_Func2        : LongInt;
        fh_Func3        : LongInt;
        fh_Arg1         : LongInt;
        fh_Arg2         : LongInt;
    end;

{ This is the extension to EXEC Messages used by DOS }

    PDosPacket = ^TDosPacket;
    TDosPacket = record
        dp_Link : PMessage;     { EXEC message        }
        dp_Port : PMsgPort;     { Reply port for the packet }
                                { Must be filled in each send. }
        case SmallInt of
        0 : (
        dp_Action : LongInt;
        dp_Status : LongInt;
        dp_Status2 : LongInt;
        dp_BufAddr : LongInt;
        );
        1 : (
        dp_Type : LongInt;      { See ACTION_... below and
                                * 'R' means Read, 'W' means Write to the
                                * file system }
        dp_Res1 : LongInt;      { For file system calls this is the result
                                * that would have been returned by the
                                * function, e.g. Write ('W') returns actual
                                * length written }
        dp_Res2 : LongInt;      { For file system calls this is what would
                                * have been returned by IoErr() }
        dp_Arg1 : LongInt;
        dp_Arg2 : LongInt;
        dp_Arg3 : LongInt;
        dp_Arg4 : LongInt;
        dp_Arg5 : LongInt;
        dp_Arg6 : LongInt;
        dp_Arg7 : LongInt;
        );
    end;


{ A Packet does not require the Message to be before it in memory, but
 * for convenience it is useful to associate the two.
 * Also see the function init_std_pkt for initializing this structure }

    PStandardPacket = ^TStandardPacket;
    TStandardPacket = record
        sp_Msg          : TMessage;
        sp_Pkt          : TDosPacket;
    end;


const

{ Packet types }
    ACTION_NIL                  = 0;
    ACTION_GET_BLOCK            = 2;    { OBSOLETE }
    ACTION_SET_MAP              = 4;
    ACTION_DIE                  = 5;
    ACTION_EVENT                = 6;
    ACTION_CURRENT_VOLUME       = 7;
    ACTION_LOCATE_OBJECT        = 8;
    ACTION_RENAME_DISK          = 9;
    ACTION_WRITE                = $57;  { 'W' }
    ACTION_READ                 = $52;  { 'R' }
    ACTION_FREE_LOCK            = 15;
    ACTION_DELETE_OBJECT        = 16;
    ACTION_RENAME_OBJECT        = 17;
    ACTION_MORE_CACHE           = 18;
    ACTION_COPY_DIR             = 19;
    ACTION_WAIT_CHAR            = 20;
    ACTION_SET_PROTECT          = 21;
    ACTION_CREATE_DIR           = 22;
    ACTION_EXAMINE_OBJECT       = 23;
    ACTION_EXAMINE_NEXT         = 24;
    ACTION_DISK_INFO            = 25;
    ACTION_INFO                 = 26;
    ACTION_FLUSH                = 27;
    ACTION_SET_COMMENT          = 28;
    ACTION_PARENT               = 29;
    ACTION_TIMER                = 30;
    ACTION_INHIBIT              = 31;
    ACTION_DISK_TYPE            = 32;
    ACTION_DISK_CHANGE          = 33;
    ACTION_SET_DATE             = 34;

    ACTION_SCREEN_MODE          = 994;

    ACTION_READ_RETURN          = 1001;
    ACTION_WRITE_RETURN         = 1002;
    ACTION_SEEK                 = 1008;
    ACTION_FINDUPDATE           = 1004;
    ACTION_FINDINPUT            = 1005;
    ACTION_FINDOUTPUT           = 1006;
    ACTION_END                  = 1007;
    ACTION_TRUNCATE             = 1022; { fast file system only }
    ACTION_WRITE_PROTECT        = 1023; { fast file system only }

{ new 2.0 packets }
    ACTION_SAME_LOCK       = 40;
    ACTION_CHANGE_SIGNAL   = 995;
    ACTION_FORMAT          = 1020;
    ACTION_MAKE_LINK       = 1021;
{}
{}
    ACTION_READ_LINK       = 1024;
    ACTION_FH_FROM_LOCK    = 1026;
    ACTION_IS_FILESYSTEM   = 1027;
    ACTION_CHANGE_MODE     = 1028;
{}
    ACTION_COPY_DIR_FH     = 1030;
    ACTION_PARENT_FH       = 1031;
    ACTION_EXAMINE_ALL     = 1033;
    ACTION_EXAMINE_FH      = 1034;

    ACTION_LOCK_RECORD     = 2008;
    ACTION_FREE_RECORD     = 2009;

    ACTION_ADD_NOTIFY      = 4097;
    ACTION_REMOVE_NOTIFY   = 4098;

    {* Added in V39: *}
    ACTION_EXAMINE_ALL_END  = 1035;
    ACTION_SET_OWNER        = 1036;

{* Tell a file system to serialize the current volume. This is typically
 * done by changing the creation date of the disk. This packet does not take
 * any arguments.  NOTE: be prepared to handle failure of this packet for
 * V37 ROM filesystems.
 *}

    ACTION_SERIALIZE_DISK  = 4200;

{
 * A structure for holding error messages - stored as array with error == 0
 * for the last entry.
 }
type
       PErrorString = ^TErrorString;
       TErrorString = record
        estr_Nums     : Pointer;
        estr_Strings  : Pointer;
       END;


{ DOS library node structure.
 * This is the data at positive offsets from the library node.
 * Negative offsets from the node is the jump table to DOS functions
 * node = (struct DosLibrary *) OpenLibrary( "dos.library" .. )      }
(*
type

    TDosLibrary = ^TDosLibrary;
    TDosLibrary = record
        dl_lib          : TLibrary;
        dl_Root         : Pointer;      { Pointer to RootNode, described below }
        dl_GV           : Pointer;      { Pointer to BCPL global vector       }
        dl_A2           : LongInt;      { Private register dump of DOS        }
        dl_A5           : LongInt;
        dl_A6           : LongInt;
        dl_Errors       : PErrorString; { pointer to array of error msgs }
        dl_TimeReq      : pTimeRequest; { private pointer to timer request }
        dl_UtilityBase  : PLibrary;     { private ptr to utility library }
        dl_IntuitionBase : PLibrary;
    end;     *)

    PRootNode = ^TRootNode;
    TRootNode = record
        rn_TaskArray    : BPTR;         { [0] is max number of CLI's
                                          [1] is APTR to process id of CLI 1
                                          [n] is APTR to process id of CLI n }
        rn_ConsoleSegment : BPTR;       { SegList for the CLI }
        rn_Time          : TDateStamp;  { Current time }
        rn_RestartSeg   : LongInt;      { SegList for the disk validator process }
        rn_Info         : BPTR;         { Pointer ot the Info structure }
        rn_FileHandlerSegment : BPTR;   { segment for a file handler }
        rn_CliList      : tMinList;     { new list of all CLI processes }
                                        { the first cpl_Array is also rn_TaskArray }
        rn_BootProc     : PMsgPort;     { private ptr to msgport of boot fs      }
        rn_ShellSegment : BPTR;         { seglist for Shell (for NewShell)         }
        rn_Flags        : LongInt;      { dos flags }
    end;

const
 RNB_WILDSTAR   = 24;
 RNF_WILDSTAR   = 16777216;
 RNB_PRIVATE1   = 1;       { private for dos }
 RNF_PRIVATE1   = 2;

type
    PDosInfo = ^TDosInfo;
    TDosInfo = record
        case SmallInt of
        0 : (
        di_ResList : BPTR;
        );
        1 : (
        di_McName       : BPTR;          { Network name of this machine; currently 0 }
        di_DevInfo      : BPTR;          { Device List }
        di_Devices      : BPTR;          { Currently zero }
        di_Handlers     : BPTR;          { Currently zero }
        di_NetHand      : Pointer;       { Network handler processid; currently zero }
        di_DevLock,                      { do NOT access directly! }
        di_EntryLock,                    { do NOT access directly! }
        di_DeleteLock   : TSignalSemaphore; { do NOT access directly! }
        );
    end;

{ ONLY to be allocated by DOS! }

       PCliProcList = ^TCliProcList;
       TCliProcList = record
        cpl_Node   : TMinNode;
        cpl_First  : LongInt;      { number of first entry in array }
        cpl_Array  : Array[0..0] of PMsgPort;
                             { [0] is max number of CLI's in this entry (n)
                              * [1] is CPTR to process id of CLI cpl_First
                              * [n] is CPTR to process id of CLI cpl_First+n-1
                              }
       END;

{ structure for the Dos resident list.  Do NOT allocate these, use       }
{ AddSegment(), and heed the warnings in the autodocs!                   }

type
       PSegment = ^TSegment;
       TSegment = record
        seg_Next  : BPTR;
        seg_UC    : LongInt;
        seg_Seg   : BPTR;
        seg_Name  : Array[0..3] of Char;      { actually the first 4 chars of BSTR name }
       END;

const
 CMD_SYSTEM    =  -1;
 CMD_INTERNAL  =  -2;
 CMD_DISABLED  =  -999;


{ DOS Processes started from the CLI via RUN or NEWCLI have this additional
 * set to data associated with them }
type
    PCommandLineInterface = ^TCommandLineInterface;
    TCommandLineInterface = record
        cli_Result2        : LongInt;      { Value of IoErr from last command }
        cli_SetName        : BSTR;         { Name of current directory }
        cli_CommandDir     : BPTR;         { Lock associated with command directory }
        cli_ReturnCode     : LongInt;      { Return code from last command }
        cli_CommandName    : BSTR;         { Name of current command }
        cli_FailLevel      : LongInt;      { Fail level (set by FAILAT) }
        cli_Prompt         : BSTR;         { Current prompt (set by PROMPT) }
        cli_StandardInput  : BPTR;         { Default (terminal) CLI input }
        cli_CurrentInput   : BPTR;         { Current CLI input }
        cli_CommandFile    : BSTR;         { Name of EXECUTE command file }
        cli_Interactive    : LongInt;      { Boolean; True if prompts required }
        cli_Background     : LongInt;      { Boolean; True if CLI created by RUN }
        cli_CurrentOutput  : BPTR;         { Current CLI output }
        cli_DefaultStack   : LongInt;      { Stack size to be obtained in long words }
        cli_StandardOutput : BPTR;         { Default (terminal) CLI output }
        cli_Module         : BPTR;         { SegList of currently loaded command }
    end;

{ This structure can take on different values depending on whether it is
 * a device, an assigned directory, or a volume.  Below is the structure
 * reflecting volumes only.  Following that is the structure representing
 * only devices.
 }

{ structure representing a volume }

    PDeviceList = ^TDeviceList;
    TDeviceList = record
        dl_Next         : BPTR;         { bptr to next device list }
        dl_Type         : LongInt;      { see DLT below }
        dl_Task         : PMsgPort;     { ptr to handler task }
        dl_Lock         : BPTR;         { not for volumes }
        dl_VolumeDate   : TDateStamp;   { creation date }
        dl_LockList     : BPTR;         { outstanding locks }
        dl_DiskType     : LongInt;      { 'DOS', etc }
        dl_unused       : LongInt;
        dl_Name         : BSTR;         { bptr to bcpl name }
    end;

{ device structure (same as the DeviceNode structure in filehandler.h) }

    PDevInfo = ^TDevInfo;
    TDevInfo = record
        dvi_Next        : BPTR;
        dvi_Type        : LongInt;
        dvi_Task        : Pointer;
        dvi_Lock        : BPTR;
        dvi_Handler     : BSTR;
        dvi_StackSize   : LongInt;
        dvi_Priority    : LongInt;
        dvi_Startup     : LongInt;
        dvi_SegList     : BPTR;
        dvi_GlobVec     : BSTR;
        dvi_Name        : BSTR;
    end;

{    structure used for multi-directory assigns. AllocVec()ed. }

       PAssignList = ^TAssignList;
       TAssignList = record
        al_Next : PAssignList;
        al_Lock : BPTR;
       END;


{ combined structure for devices, assigned directories, volumes }

   PDosList = ^TDosList;
   TDosList = record
    dol_Next            : BPTR;           {    bptr to next device on list }
    dol_Type            : LongInt;        {    see DLT below }
    dol_Task            : PMsgPort;       {    ptr to handler task }
    dol_Lock            : BPTR;
    case SmallInt of
    0 : (
        dol_Handler : record
          dol_Handler    : BSTR;      {    file name to load IF seglist is null }
          dol_StackSize,              {    stacksize to use when starting process }
          dol_Priority,               {    task priority when starting process }
          dol_Startup    : LongInt;   {    startup msg: FileSysStartupMsg for disks }
          dol_SegList,                {    already loaded code for new task }
          dol_GlobVec    : BPTR;      {    BCPL global vector to use when starting
                                 * a process. -1 indicates a C/Assembler
                                 * program. }
        end;
    );
    1 : (
        dol_Volume       : record
          dol_VolumeDate : TDateStamp; {    creation date }
          dol_LockList   : BPTR;       {    outstanding locks }
          dol_DiskType   : LongInt;    {    'DOS', etc }
        END;
    );
    2 : (
        dol_assign       :  record
          dol_AssignName : STRPTR;        {    name for non-OR-late-binding assign }
          dol_List       : PAssignList;   {    for multi-directory assigns (regular) }
        END;
    dol_Name            : BSTR;           {    bptr to bcpl name }
    );
   END;

const

{ definitions for dl_Type }

    DLT_DEVICE          = 0;
    DLT_DIRECTORY       = 1;
    DLT_VOLUME          = 2;
    DLT_LATE            = 3;       {    late-binding assign }
    DLT_NONBINDING      = 4;       {    non-binding assign }
    DLT_PRIVATE         = -1;      {    for internal use only }

{    structure return by GetDeviceProc() }
type

       PDevProc = ^TDevProc;
       TDevProc = record
        dvp_Port        : PMsgPort;
        dvp_Lock        : BPTR;
        dvp_Flags       : LongInt;
        dvp_DevNode     : PDosList;    {    DON'T TOUCH OR USE! }
       END;

const
{    definitions for dvp_Flags }
     DVPB_UNLOCK   =  0;
     DVPF_UNLOCK   =  1;
     DVPB_ASSIGN   =  1;
     DVPF_ASSIGN   =  2;

{    Flags to be passed to LockDosList(), etc }
     LDB_DEVICES   =  2;
     LDF_DEVICES   =  4;
     LDB_VOLUMES   =  3;
     LDF_VOLUMES   =  8;
     LDB_ASSIGNS   =  4;
     LDF_ASSIGNS   =  16;
     LDB_ENTRY     =  5;
     LDF_ENTRY     =  32;
     LDB_DELETE    =  6;
     LDF_DELETE    =  64;

{    you MUST specify one of LDF_READ or LDF_WRITE }
     LDB_READ      =  0;
     LDF_READ      =  1;
     LDB_WRITE     =  1;
     LDF_WRITE     =  2;

{    actually all but LDF_ENTRY (which is used for internal locking) }
     LDF_ALL       =  (LDF_DEVICES+LDF_VOLUMES+LDF_ASSIGNS);

{    error report types for ErrorReport() }
     REPORT_STREAM          = 0;       {    a stream }
     REPORT_TASK            = 1;       {    a process - unused }
     REPORT_LOCK            = 2;       {    a lock }
     REPORT_VOLUME          = 3;       {    a volume node }
     REPORT_INSERT          = 4;       {    please insert volume }

{    Special error codes for ErrorReport() }
     ABORT_DISK_ERROR       = 296;     {    Read/write error }
     ABORT_BUSY             = 288;     {    You MUST replace... }

{    types for initial packets to shells from run/newcli/execute/system. }
{    For shell-writers only }
     RUN_EXECUTE           =  -1;
     RUN_SYSTEM            =  -2;
     RUN_SYSTEM_ASYNCH     =  -3;

{    Types for fib_DirEntryType.  NOTE that both USERDIR and ROOT are      }
{    directories, and that directory/file checks should use <0 and >=0.    }
{    This is not necessarily exhaustive!  Some handlers may use other      }
{    values as needed, though <0 and >=0 should remain as supported as     }
{    possible.                                                             }
     ST_ROOT       =  1 ;
     ST_USERDIR    =  2 ;
     ST_SOFTLINK   =  3 ;      {    looks like dir, but may point to a file! }
     ST_LINKDIR    =  4 ;      {    hard link to dir }
     ST_FILE       =  -3;      {    must be negative for FIB! }
     ST_LINKFILE   =  -4;      {    hard link to file }
     ST_PIPEFILE   =  -5;      {    for pipes that support ExamineFH   }

type

{ a lock structure, as returned by Lock() or DupLock() }

    PFileLock = ^TFileLock;
    TFileLock = record
        fl_Link         : BPTR;         { bcpl pointer to next lock }
        fl_Key          : LongInt;      { disk block number }
        fl_Access       : LongInt;      { exclusive or shared }
        fl_Task         : PMsgPort;     { handler task's port }
        fl_Volume       : BPTR;         { bptr to a DeviceList }
    end;


{  NOTE: V37 dos.library, when doing ExAll() emulation, and V37 filesystems  }
{  will return an error if passed ED_OWNER.  If you get ERROR_BAD_NUMBER,    }
{  retry with ED_COMMENT to get everything but owner info.  All filesystems  }
{  supporting ExAll() must support through ED_COMMENT, and must check type   }
{  and return ERROR_BAD_NUMBER if they don't support the type.               }

{   values that can be passed for what data you want from ExAll() }
{   each higher value includes those below it (numerically)       }
{   you MUST chose one of these values }
const
     ED_NAME        = 1;
     ED_TYPE        = 2;
     ED_SIZE        = 3;
     ED_PROTECTION  = 4;
     ED_DATE        = 5;
     ED_COMMENT     = 6;
     ED_OWNER       = 7;
{
 *   Structure in which exall results are returned in.  Note that only the
 *   fields asked for will exist!
 }
type
       PExAllData = ^TExAllData;
       TExAllData = record
        ed_Next     : PExAllData;
        ed_Name     : STRPTR;
        ed_Type,
        ed_Size,
        ed_Prot,
        ed_Days,
        ed_Mins,
        ed_Ticks    : ULONG;
        ed_Comment  : STRPTR;     {   strings will be after last used field }
        ed_OwnerUID,              { new for V39 }
        ed_OwnerGID : Word;
       END;

{
 *   Control structure passed to ExAll.  Unused fields MUST be initialized to
 *   0, expecially eac_LastKey.
 *
 *   eac_MatchFunc is a hook (see utility.library documentation for usage)
 *   It should return true if the entry is to returned, false if it is to be
 *   ignored.
 *
 *   This structure MUST be allocated by AllocDosObject()!
 }

       PExAllControl = ^TExAllControl;
       TExAllControl = record
        eac_Entries,                 {   number of entries returned in buffer      }
        eac_LastKey     : ULONG;     {   Don't touch inbetween linked ExAll calls! }
        eac_MatchString : STRPTR;    {   wildcard string for pattern match OR NULL }
        eac_MatchFunc   : pHook;     {   optional private wildcard FUNCTION     }
       END;



{ The disk "environment" is a longword array that describes the
 * disk geometry.  It is variable sized, with the length at the beginning.
 * Here are the constants for a standard geometry.
}

type

    PDosEnvec = ^TDosEnvec;
    TDosEnvec = record
        de_TableSize      : ULONG;      { Size of Environment vector }
        de_SizeBlock      : ULONG;      { in longwords: standard value is 128 }
        de_SecOrg         : ULONG;      { not used; must be 0 }
        de_Surfaces       : ULONG;      { # of heads (surfaces). drive specific }
        de_SectorPerBlock : ULONG;      { not used; must be 1 }
        de_BlocksPerTrack : ULONG;      { blocks per track. drive specific }
        de_Reserved       : ULONG;      { DOS reserved blocks at start of partition. }
        de_PreAlloc       : ULONG;      { DOS reserved blocks at end of partition }
        de_Interleave     : ULONG;      { usually 0 }
        de_LowCyl         : ULONG;      { starting cylinder. typically 0 }
        de_HighCyl        : ULONG;      { max cylinder. drive specific }
        de_NumBuffers     : ULONG;      { Initial # DOS of buffers.  }
        de_BufMemType     : ULONG;      { type of mem to allocate for buffers }
        de_MaxTransfer    : ULONG;      { Max number of bytes to transfer at a time }
        de_Mask           : ULONG;      { Address Mask to block out certain memory }
        de_BootPri        : LongInt;    { Boot priority for autoboot }
        de_DosType        : ULONG;      { ASCII (HEX) string showing filesystem type;
                                        * 0X444F5300 is old filesystem,
                                        * 0X444F5301 is fast file system }
        de_Baud           : ULONG;      {     Baud rate for serial handler }
        de_Control        : ULONG;      {     Control SmallInt for handler/filesystem }
        de_BootBlocks     : ULONG;      {     Number of blocks containing boot code }
    end;

const

{ these are the offsets into the array }

    DE_TABLESIZE        = 0;    { standard value is 11 }
    DE_SIZEBLOCK        = 1;    { in longwords: standard value is 128 }
    DE_SECORG           = 2;    { not used; must be 0 }
    DE_NUMHEADS         = 3;    { # of heads (surfaces). drive specific }
    DE_SECSPERBLK       = 4;    { not used; must be 1 }
    DE_BLKSPERTRACK     = 5;    { blocks per track. drive specific }
    DE_RESERVEDBLKS     = 6;    { unavailable blocks at start.   usually 2 }
    DE_PREFAC           = 7;    { not used; must be 0 }
    DE_INTERLEAVE       = 8;    { usually 0 }
    DE_LOWCYL           = 9;    { starting cylinder. typically 0 }
    DE_UPPERCYL         = 10;   { max cylinder.  drive specific }
    DE_NUMBUFFERS       = 11;   { starting # of buffers.  typically 5 }
    DE_MEMBUFTYPE       = 12;   { type of mem to allocate for buffers. }
    DE_BUFMEMTYPE       = 12;   { same as above, better name
                                 * 1 is public, 3 is chip, 5 is fast }
    DE_MAXTRANSFER      = 13;   { Max number bytes to transfer at a time }
    DE_MASK             = 14;   { Address Mask to block out certain memory }
    DE_BOOTPRI          = 15;   { Boot priority for autoboot }
    DE_DOSTYPE          = 16;   { ASCII (HEX) string showing filesystem type;
                                 * 0X444F5300 is old filesystem,
                                 * 0X444F5301 is fast file system }
    DE_BAUD             = 17;   {     Baud rate for serial handler }
    DE_CONTROL          = 18;   {     Control SmallInt for handler/filesystem }
    DE_BOOTBLOCKS       = 19;   {     Number of blocks containing boot code }


{ The file system startup message is linked into a device node's startup
** field.  It contains a pointer to the above environment, plus the
** information needed to do an exec OpenDevice().
}

type

    PFileSysStartupMsg = ^TFileSysStartupMsg;
    TFileSysStartupMsg = record
        fssm_Unit       : ULONG;        { exec unit number for this device }
        fssm_Device     : BSTR;         { null terminated bstring to the device name }
        fssm_Environ    : BPTR;         { ptr to environment table (see above) }
        fssm_Flags      : ULONG;        { flags for OpenDevice() }
    end;


{ The include file "libraries/dosextens.h" has a DeviceList structure.
 * The "device list" can have one of three different things linked onto
 * it.  Dosextens defines the structure for a volume.  DLT_DIRECTORY
 * is for an assigned directory.  The following structure is for
 * a dos "device" (DLT_DEVICE).
}

    PDeviceNode = ^TDeviceNode;
    TDeviceNode = record
        dn_Next         : BPTR;         { singly linked list }
        dn_Type         : ULONG;        { always 0 for dos "devices" }
        dn_Task         : PMsgPort;     { standard dos "task" field.  If this is
                                         * null when the node is accesses, a task
                                         * will be started up }
        dn_Lock         : BPTR;         { not used for devices -- leave null }
        dn_Handler      : BSTR;         { filename to loadseg (if seglist is null) }
        dn_StackSize    : ULONG;        { stacksize to use when starting task }
        dn_Priority     : LongInt;      { task priority when starting task }
        dn_Startup      : BPTR;         { startup msg: FileSysStartupMsg for disks }
        dn_SegList      : BPTR;         { code to run to start new task (if necessary).
                                         * if null then dn_Handler will be loaded. }
        dn_GlobalVec    : BPTR; { BCPL global vector to use when starting
                                 * a task.  -1 means that dn_SegList is not
                                 * for a bcpl program, so the dos won't
                                 * try and construct one.  0 tell the
                                 * dos that you obey BCPL linkage rules,
                                 * and that it should construct a global
                                 * vector for you.
                                 }
        dn_Name         : BSTR;         { the node name, e.g. '\3','D','F','3' }
    end;

const
{     use of Class and code is discouraged for the time being - we might want to
   change things }
{     --- NotifyMessage Class ------------------------------------------------ }
     NOTIFY_CLASS  =  $40000000;

{     --- NotifyMessage Codes ------------------------------------------------ }
     NOTIFY_CODE   =  $1234;


{     Sent to the application if SEND_MESSAGE is specified.                    }

type
{     Do not modify or reuse the notifyrequest while active.                   }
{     note: the first LONG of nr_Data has the length transfered                }


       PNotifyRequest = ^TNotifyRequest;
       TNotifyRequest = record
            nr_Name : PChar;
            nr_FullName : PChar;
            nr_UserData : LongWord;
            nr_Flags : LongWord;
            nr_stuff : record
                case SmallInt of
                   0 : ( nr_Msg : record
                        nr_Port : PMsgPort;
                     end );
                   1 : ( nr_Signal : record
                        nr_Task : pTask;
                        nr_SignalNum : Byte;
                        nr_pad : array[0..2] of Byte;
                     end );
                end;
            nr_Reserved : array[0..3] of LongWord;
            nr_MsgCount : LongWord;
            nr_Handler : PMsgPort;
         end;

   PNotifyMessage = ^TNotifyMessage;
   TNotifyMessage = record
    nm_ExecMessage : TMessage;
    nm_Class       : LongWord;
    nm_Code        : Word;
    nm_NReq        : PNotifyRequest;     {     don't modify the request! }
    nm_DoNotTouch,                       {     like it says!  For use by handlers }
    nm_DoNotTouch2 : LongWord;            {     ditto }
   END;


const
{     --- NotifyRequest Flags ------------------------------------------------ }
     NRF_SEND_MESSAGE      =  1 ;
     NRF_SEND_SIGNAL       =  2 ;
     NRF_WAIT_REPLY        =  8 ;
     NRF_NOTIFY_INITIAL    =  16;

{     do NOT set or remove NRF_MAGIC!  Only for use by handlers! }
     NRF_MAGIC             = $80000000;

{     bit numbers }
     NRB_SEND_MESSAGE      =  0;
     NRB_SEND_SIGNAL       =  1;
     NRB_WAIT_REPLY        =  3;
     NRB_NOTIFY_INITIAL    =  4;

     NRB_MAGIC             =  31;

{     Flags reserved for private use by the handler: }
     NR_HANDLER_FLAGS      =  $ffff0000;

{   *********************************************************************
 *
 * The CSource data structure defines the input source for "ReadItem()"
 * as well as the ReadArgs call.  It is a publicly defined structure
 * which may be used by applications which use code that follows the
 * conventions defined for access.
 *
 * When passed to the dos.library functions, the value passed as
 * struct *CSource is defined as follows:
 *      if ( CSource == 0)      Use buffered IO "ReadChar()" as data source
 *      else                    Use CSource for input character stream
 *
 * The following two pseudo-code routines define how the CSource structure
 * is used:
 *
 * long CS_ReadChar( struct CSource *CSource )
 *
 *      if ( CSource == 0 )     return ReadChar();
 *      if ( CSource->CurChr >= CSource->Length )       return ENDSTREAMCHAR;
 *      return CSource->Buffer[ CSource->CurChr++ ];
 *
 *
 * BOOL CS_UnReadChar( struct CSource *CSource )
 *
 *      if ( CSource == 0 )     return UnReadChar();
 *      if ( CSource->CurChr <= 0 )     return FALSE;
 *      CSource->CurChr--;
 *      return TRUE;
 *
 *
 * To initialize a struct CSource, you set CSource->CS_Buffer to
 * a string which is used as the data source, and set CS_Length to
 * the number of characters in the string.  Normally CS_CurChr should
 * be initialized to ZERO, or left as it was from prior use as
 * a CSource.
 *
 *********************************************************************}

type
       PCSource = ^TCSource;
       TCSource = record
        CS_Buffer  : STRPTR;
        CS_Length,
        CS_CurChr  : LongInt;
       END;

{   *********************************************************************
 *
 * The RDArgs data structure is the input parameter passed to the DOS
 * ReadArgs() function call.
 *
 * The RDA_Source structure is a CSource as defined above;
 * if RDA_Source.CS_Buffer is non-null, RDA_Source is used as the input
 * character stream to parse, else the input comes from the buffered STDIN
 * calls ReadChar/UnReadChar.
 *
 * RDA_DAList is a private address which is used internally to track
 * allocations which are freed by FreeArgs().  This MUST be initialized
 * to NULL prior to the first call to ReadArgs().
 *
 * The RDA_Buffer and RDA_BufSiz fields allow the application to supply
 * a fixed-size buffer in which to store the parsed data.  This allows
 * the application to pre-allocate a buffer rather than requiring buffer
 * space to be allocated.  If either RDA_Buffer or RDA_BufSiz is NULL,
 * the application has not supplied a buffer.
 *
 * RDA_ExtHelp is a text string which will be displayed instead of the
 * template string, if the user is prompted for input.
 *
 * RDA_Flags bits control how ReadArgs() works.  The flag bits are
 * defined below.  Defaults are initialized to ZERO.
 *
 *********************************************************************}

       PRDArgs = ^TRDArgs;
       TRDArgs = record
        RDA_Source  : TCSource;     {    Select input source }
        RDA_DAList  : LongInt;      {    PRIVATE. }
        RDA_Buffer  : STRPTR;       {    Optional string parsing space. }
        RDA_BufSiz  : LongInt;      {    Size of RDA_Buffer (0..n) }
        RDA_ExtHelp : STRPTR;       {    Optional extended help }
        RDA_Flags   : LongInt;      {    Flags for any required control }
       END;

const
       RDAB_STDIN     = 0;       {    Use "STDIN" rather than "COMMAND LINE" }
       RDAF_STDIN     = 1;
       RDAB_NOALLOC   = 1;       {    If set, do not allocate extra string space.}
       RDAF_NOALLOC   = 2;
       RDAB_NOPROMPT  = 2;       {    Disable reprompting for string input. }
       RDAF_NOPROMPT  = 4;

{   *********************************************************************
 * Maximum number of template keywords which can be in a template passed
 * to ReadArgs(). IMPLEMENTOR NOTE - must be a multiple of 4.
 *********************************************************************}
       MAX_TEMPLATE_ITEMS     = 100;

{   *********************************************************************
 * Maximum number of MULTIARG items returned by ReadArgs(), before
 * an ERROR_LINE_TOO_LONG.  These two limitations are due to stack
 * usage.  Applications should allow "a lot" of stack to use ReadArgs().
 *********************************************************************}
       MAX_MULTIARGS          = 128;

const
{     Modes for LockRecord/LockRecords() }
       REC_EXCLUSIVE          = 0;
       REC_EXCLUSIVE_IMMED    = 1;
       REC_SHARED             = 2;
       REC_SHARED_IMMED       = 3;

{     struct to be passed to LockRecords()/UnLockRecords() }

type
       PRecordLock = ^TRecordLock;
       TRecordLock = record
        rec_FH    : BPTR;         {     filehandle }
        rec_Offset,               {     offset in file }
        rec_Length,               {     length of file to be locked }
        rec_Mode  : LongWord;        {     type of lock }
       END;


{      the structure in the pr_LocalVars list }
{      Do NOT allocate yourself, use SetVar()!!! This structure may grow in }
{      future releases!  The list should be left in alphabetical order, and }
{      may have multiple entries with the same name but different types.    }
type
       PLocalVar = ^TLocalVar;
       TLocalVar = record
        lv_Node  : tNode;
        lv_Flags : Word;
        lv_Value : STRPTR;
        lv_Len   : LongWord;
       END;

{
 * The lv_Flags bits are available to the application.  The unused
 * lv_Node.ln_Pri bits are reserved for system use.
 }

const
{      bit definitions for lv_Node.ln_Type: }
       LV_VAR               =   0;       {      an variable }
       LV_ALIAS             =   1;       {      an alias }
{      to be or'ed into type: }
       LVB_IGNORE           =   7;       {      ignore this entry on GetVar, etc }
       LVF_IGNORE           =   $80;

{      definitions of flags passed to GetVar()/SetVar()/DeleteVar() }
{      bit defs to be OR'ed with the type: }
{      item will be treated as a single line of text unless BINARY_VAR is used }
       GVB_GLOBAL_ONLY       =  8   ;
       GVF_GLOBAL_ONLY       =  $100;
       GVB_LOCAL_ONLY        =  9   ;
       GVF_LOCAL_ONLY        =  $200;
       GVB_BINARY_VAR        =  10  ;            {      treat variable as binary }
       GVF_BINARY_VAR        =  $400;
       GVB_DONT_NULL_TERM    =  11;            { only with GVF_BINARY_VAR }
       GVF_DONT_NULL_TERM    =  $800;

{ this is only supported in >= V39 dos.  V37 dos ignores this. }
{ this causes SetVar to affect ENVARC: as well as ENV:.        }
      GVB_SAVE_VAR           = 12 ;     { only with GVF_GLOBAL_VAR }
      GVF_SAVE_VAR           = $1000 ;


const
{   ***************************************************************************}
{    definitions for the System() call }

    SYS_Dummy      = (TAG_USER + 32);
    SYS_Input      = (SYS_Dummy + 1);
                                {    specifies the input filehandle  }
    SYS_Output     = (SYS_Dummy + 2);
                                {    specifies the output filehandle }
    SYS_Asynch     = (SYS_Dummy + 3);
                                {    run asynch, close input/output on exit(!) }
    SYS_UserShell  = (SYS_Dummy + 4);
                                {    send to user shell instead of boot shell }
    SYS_CustomShell= (SYS_Dummy + 5);
                                {    send to a specific shell (data is name) }
{         SYS_Error, }


{   ***************************************************************************}
{    definitions for the CreateNewProc() call }
{    you MUST specify one of NP_Seglist or NP_Entry.  All else is optional. }

    NP_Dummy       = (TAG_USER + 1000);
    NP_Seglist     = (NP_Dummy + 1);
                                {    seglist of code to run for the process  }
    NP_FreeSeglist = (NP_Dummy + 2);
                                {    free seglist on exit - only valid for   }
                                {    for NP_Seglist.  Default is TRUE.       }
    NP_Entry       = (NP_Dummy + 3);
                                {    entry point to run - mutually exclusive }
                                {    with NP_Seglist! }
    NP_Input       = (NP_Dummy + 4);
                                {    filehandle - default is Open("NIL:"...) }
    NP_Output      = (NP_Dummy + 5);
                                {    filehandle - default is Open("NIL:"...) }
    NP_CloseInput  = (NP_Dummy + 6);
                                {    close input filehandle on exit          }
                                {    default TRUE                            }
    NP_CloseOutput = (NP_Dummy + 7);
                                {    close output filehandle on exit         }
                                {    default TRUE                            }
    NP_Error       = (NP_Dummy + 8);
                                {    filehandle - default is Open("NIL:"...) }
    NP_CloseError  = (NP_Dummy + 9);
                                {    close error filehandle on exit          }
                                {    default TRUE                            }
    NP_CurrentDir  = (NP_Dummy + 10);
                                {    lock - default is parent's current dir  }
    NP_StackSize   = (NP_Dummy + 11);
                                {    stacksize for process - default 4000    }
    NP_Name        = (NP_Dummy + 12);
                                {    name for process - default "New Process"}
    NP_Priority    = (NP_Dummy + 13);
                                {    priority - default same as parent       }
    NP_ConsoleTask = (NP_Dummy + 14);
                                {    consoletask - default same as parent    }
    NP_WindowPtr   = (NP_Dummy + 15);
                                {    window ptr - default is same as parent  }
    NP_HomeDir     = (NP_Dummy + 16);
                                {    home directory - default curr home dir  }
    NP_CopyVars    = (NP_Dummy + 17);
                                {    boolean to copy local vars-default TRUE }
    NP_Cli         = (NP_Dummy + 18);
                                {    create cli structure - default FALSE    }
    NP_Path        = (NP_Dummy + 19);
                                {    path - default is copy of parents path  }
                                {    only valid if a cli process!    }
    NP_CommandName = (NP_Dummy + 20);
                                {    commandname - valid only for CLI        }
    NP_Arguments   = (NP_Dummy + 21);
                                {    cstring of arguments - passed with str  }
                                {    in a0, length in d0.  (copied and freed }
                                {    on exit.  Default is empty string.      }
                                {    NOTE: not operational until 2.04 - see  }
                                {    BIX/TechNotes for more info/workarounds }
                                {    NOTE: in 2.0, it DIDN'T pass "" - the   }
                                {    registers were random.                  }
{    FIX! should this be only for cli's? }
    NP_NotifyOnDeath = (NP_Dummy + 22);
                                {    notify parent on death - default FALSE  }
                                {    Not functional yet. }
    NP_Synchronous   = (NP_Dummy + 23);
                                {    don't return until process finishes -   }
                                {    default FALSE.                          }
                                {    Not functional yet. }
    NP_ExitCode      = (NP_Dummy + 24);
                                {    code to be called on process exit       }
    NP_ExitData      = (NP_Dummy + 25);
                                {    optional argument for NP_EndCode rtn -  }
                                {    default NULL                            }


{   ***************************************************************************}
{    tags for AllocDosObject }

    ADO_Dummy        = (TAG_USER + 2000);
    ADO_FH_Mode      = (ADO_Dummy + 1);
                                {    for type DOS_FILEHANDLE only            }
                                {    sets up FH for mode specified.
                                   This can make a big difference for buffered
                                   files.                                  }
        {    The following are for DOS_CLI }
        {    If you do not specify these, dos will use it's preferred values }
        {    which may change from release to release.  The BPTRs to these   }
        {    will be set up correctly for you.  Everything will be zero,     }
        {    except cli_FailLevel (10) and cli_Background (DOSTRUE).         }
        {    NOTE: you may also use these 4 tags with CreateNewProc.         }

    ADO_DirLen     = (ADO_Dummy + 2);
                                {    size in bytes for current dir buffer    }
    ADO_CommNameLen= (ADO_Dummy + 3);
                                {    size in bytes for command name buffer   }
    ADO_CommFileLen= (ADO_Dummy + 4);
                                {    size in bytes for command file buffer   }
    ADO_PromptLen  = (ADO_Dummy + 5);
                                {    size in bytes for the prompt buffer     }

{   ***************************************************************************}
{    tags for NewLoadSeg }
{    no tags are defined yet for NewLoadSeg }

procedure AbortPkt(Port : PMsgPort; Pkt : PDosPacket);
function AddBuffers(const Name : PChar; Number : LongInt) : Boolean;
function AddDosEntry(DList : PDosList) : Boolean;
function AddPart(dirname : PChar;const filename : PChar; size : LongWord) : Boolean;
function AddSegment(const Name : PChar; seg : LongInt; system : LongInt) : Boolean;
function AllocDosObject(Type_ : LongWord;const Tags : PTagItem) : Pointer;
//function AllocDosObjectTagList(Type_ : LongWord;const Tags : PTagItem) : Pointer;
function AssignAdd(const Name : PChar; Lock : LongInt) : Boolean;
function AssignLate(const Name : PChar;const Path : PChar) : Boolean;
function AssignLock(const Name : PChar; Lock : LongInt) : Boolean;
function AssignPath(const Name : PChar;const Path : PChar) : Boolean;
function AttemptLockDosList(Flags : LongWord) : PDosList;
function ChangeMode(Type_ : LongInt; fh : LongInt; NewMode : LongInt) : Boolean;
function CheckSignal(Mask : LongInt) : LongInt;
function Cli : PCommandLineInterface;
function CliInitNewcli(dp : PDosPacket) : LongInt;
function CliInitRun(dp : PDosPacket) : LongInt;
function CompareDates(const date1 : PDateStamp;const date2 : PDateStamp) : LongInt;
function CreateDir(const Name : PChar) : LongInt;
function CreateNewProc(const Tags : PTagItem) : pProcess;
//function CreateNewProcTagList(const Tags : PTagItem) : pProcess;
function CreateProc(const Name : PChar; pri : LongInt; segList : LongInt; stackSize : LongInt) : PMsgPort;
function CurrentDir(Lock : LongInt) : LongInt;
procedure DateStamp(date : pDateStamp);
function DateToStr(datetime : PDateTime) : Boolean;
function DeleteFile(const Name : PChar) : Boolean;
function DeleteVar(const Name : PChar; Flags : LongWord) : Boolean;
function DeviceProc(const Name : PChar) : PMsgPort;
function DoPkt(Port : PMsgPort; action : LongInt; arg1 : LongInt; arg2 : LongInt; arg3 : LongInt; arg4 : LongInt; arg5 : LongInt) : LongInt;
{
function DoPkt0(Port : PMsgPort; action : LongInt) : LongInt;
function DoPkt1(Port : PMsgPort; action : LongInt; arg1 : LongInt) : LongInt;
function DoPkt2(Port : PMsgPort; action : LongInt; arg1 : LongInt; arg2 : LongInt) : LongInt;
function DoPkt3(Port : PMsgPort; action : LongInt; arg1 : LongInt; arg2 : LongInt; arg3 : LongInt) : LongInt;
function DoPkt4(Port : PMsgPort; action : LongInt; arg1 : LongInt; arg2 : LongInt; arg3 : LongInt; arg4 : LongInt) : LongInt;
}
procedure DOSClose(file_ : LongInt);
procedure DOSDelay(timeout : LongInt);
procedure DOSExit(returnCode : LongInt);
function DOSFlush(fh : LongInt) : Boolean;
function DOSInput : LongInt;
function DOSOpen(const Name : PChar; accessMode : LongInt) : LongInt;
function DOSOutput : LongInt;
function DOSRead(file_ : LongInt; buffer : Pointer; length : LongInt) : LongInt;
function DOSRename(const oldName : PChar;const newName : PChar) : Boolean;
function DOSSeek(file_ : LongInt; position : LongInt; offset : LongInt) : LongInt;
function DOSWrite(file_ : LongInt; buffer : Pointer; length : LongInt) : LongInt;
function DupLock(Lock : LongInt) : LongInt;
function DupLockFromFH(fh : LongInt) : LongInt;
procedure EndNotify(notify : PNotifyRequest);
function ErrorReport(code : LongInt; Type_ : LongInt; arg1 : LongWord; device : PMsgPort) : Boolean;
function ExAll(Lock : LongInt; buffer : pExAllData; size : LongInt; data : LongInt; control : pExAllControl) : Boolean;
procedure ExAllEnd(Lock : LongInt; buffer : pExAllData; size : LongInt; data : LongInt; control : pExAllControl);
function Examine(Lock : LongInt; fileInfoBlock : PFileInfoBlock) : Boolean;
function ExamineFH(fh : LongInt; fib : PFileInfoBlock) : Boolean;
function Execute(const string_ : PChar; file_ : LongInt; file2 : LongInt) : Boolean;
function ExNext(Lock : LongInt; fileInfoBlock : PFileInfoBlock) : Boolean;
function Fault(code : LongInt; header : PChar; buffer : PChar; len : LongInt) : Boolean;
function FGetC(fh : LongInt) : LongInt;
function FGets(fh : LongInt; buf : PChar; buflen : LongWord) : PChar;
function FilePart(const Path : PChar) : PChar;
function FindArg(const keyword : PChar;const arg_template : PChar) : LongInt;
function FindCliProc(num : LongWord) : pProcess;
function FindDosEntry(const DList : PDosList;const Name : PChar; Flags : LongWord) : PDosList;
function FindSegment(const Name : PChar;const seg : PSegment; system : LongInt) : PSegment;
function FindVar(const Name : PChar; Type_ : LongWord) : PLocalVar;
function dosFormat(const filesystem : PChar;const volumename : PChar; dostype : LongWord) : Boolean;
function FPutC(fh : LongInt; ch : LongInt) : LongInt;
function FPuts(fh : LongInt;const str : PChar) : Boolean;
function FRead(fh : LongInt; block : Pointer; blocklen : LongWord; Number : LongWord) : LongInt;
procedure FreeArgs(args : PRDArgs);
procedure FreeDeviceProc(dp : pDevProc);
procedure FreeDosEntry(DList : PDosList);
procedure FreeDosObject(Type_ : LongWord; ptr : Pointer);
function FWrite(fh : LongInt; block : Pointer; blocklen : LongWord; Number : LongWord) : LongInt;
function GetArgStr : PChar;
function GetConsoleTask : PMsgPort;
function GetCurrentDirName(buf : PChar; len : LongInt) : Boolean;
function GetDeviceProc(const Name : PChar; dp : pDevProc) : pDevProc;
function GetFileSysTask : PMsgPort;
function GetProgramDir : LongInt;
function GetProgramName(buf : PChar; len : LongInt) : Boolean;
function GetPrompt(buf : PChar; len : LongInt) : Boolean;
function GetVar(const Name : PChar; buffer : PChar; size : LongInt; Flags : LongInt) : LongInt;
function Info(Lock : LongInt; parameterBlock : PInfoData) : Boolean;
function Inhibit(const Name : PChar; onoff : LongInt) : Boolean;
function InternalLoadSeg(fh : LongInt; table : LongInt;const funcarray : pLONGINT; VAR stack : LongInt) : LongInt;
function InternalUnLoadSeg(seglist : LongInt; freefunc : tPROCEDURE) : Boolean;
function IoErr : LongInt;
function IsFileSystem(const Name : PChar) : Boolean;
function IsInteractive(file_ : LongInt) : Boolean;
function LoadSeg(const Name : PChar) : LongInt;
function Lock(const Name : PChar; Type_ : LongInt) : LongInt;
function LockDosList(Flags : LongWord) : PDosList;
function LockRecord(fh : LongInt; offset : LongWord; length : LongWord; mode : LongWord; timeout : LongWord) : Boolean;
function LockRecords(recArray : PRecordLock; timeout : LongWord) : Boolean;
function MakeDosEntry(const Name : PChar; Type_ : LongInt) : PDosList;
function MakeLink(const Name : PChar; dest : LongInt; soft : LongInt) : Boolean;
procedure MatchEnd(anchor : PAnchorPath);
function MatchFirst(const pat : PChar; anchor : PAnchorPath) : LongInt;
function MatchNext(anchor : PAnchorPath) : LongInt;
function MatchPattern(const pat : PChar; str : PChar) : Boolean;
function MatchPatternNoCase(const pat : PChar; str : PChar) : Boolean;
function MaxCli : LongWord;
function NameFromFH(fh : LongInt; buffer : PChar; len : LongInt) : Boolean;
function NameFromLock(Lock : LongInt; buffer : PChar; len : LongInt) : Boolean;
function NewLoadSeg(const file_ : PChar;const Tags : PTagItem) : LongInt;
//function NewLoadSegTagList(const file_ : PChar;const Tags : PTagItem) : LongInt;
function NextDosEntry(const DList : PDosList; Flags : LongWord) : PDosList;
function OpenFromLock(Lock : LongInt) : LongInt;
function ParentDir(Lock : LongInt) : LongInt;
function ParentOfFH(fh : LongInt) : LongInt;
function ParsePattern(const pat : PChar; buf : PChar; buflen : LongInt) : LongInt;
function ParsePatternNoCase(const pat : PChar; buf : PChar; buflen : LongInt) : LongInt;
function PathPart(const Path : PChar) : PChar;
function PrintFault(code : LongInt;const header : PChar) : Boolean;
function PutStr(const str : PChar) : Boolean;
function ReadArgs(const arg_template : PChar; arra : pLONGINT; args : PRDArgs) : PRDArgs;
function ReadItem(const Name : PChar; maxchars : LongInt; cSource : PCSource) : LongInt;
function ReadLink(Port : PMsgPort; Lock : LongInt;const Path : PChar; buffer : PChar; size : LongWord) : Boolean;
function Relabel(const drive : PChar;const newname : PChar) : Boolean;
function RemAssignList(const Name : PChar; Lock : LongInt) : Boolean;
function RemDosEntry(DList : PDosList) : Boolean;
function RemSegment(seg : PSegment) : Boolean;
procedure ReplyPkt(dp : PDosPacket; res1 : LongInt; res2 : LongInt);
function RunCommand(seg : LongInt; stack : LongInt;const paramptr : PChar; paramlen : LongInt) : LongInt;
function SameDevice(lock1 : LongInt; lock2 : LongInt) : Boolean;
function SameLock(lock1 : LongInt; lock2 : LongInt) : LongInt;
function SelectInput(fh : LongInt) : LongInt;
function SelectOutput(fh : LongInt) : LongInt;
procedure SendPkt(dp : PDosPacket; Port : PMsgPort; replyport : PMsgPort);
function SetArgStr(const string_ : PChar) : Boolean;
function SetComment(const Name : PChar;const comment : PChar) : Boolean;
function SetConsoleTask(const task : PMsgPort) : PMsgPort;
function SetCurrentDirName(const Name : PChar) : Boolean;
function SetFileDate(const Name : PChar; date : pDateStamp) : Boolean;
function SetFileSize(fh : LongInt; pos : LongInt; mode : LongInt) : Boolean;
function SetFileSysTask(const task : PMsgPort) : PMsgPort;
function SetIoErr(result : LongInt) : LongInt;
function SetMode(fh : LongInt; mode : LongInt) : Boolean;
function SetOwner(const Name : PChar; owner_info : LongInt) : Boolean;
function SetProgramDir(Lock : LongInt) : LongInt;
function SetProgramName(const Name : PChar) : Boolean;
function SetPrompt(const Name : PChar) : Boolean;
function SetProtection(const Name : PChar; protect : LongInt) : Boolean;
function SetVar(const Name : PChar; buffer : PChar; size : LongInt; Flags : LongInt) : Boolean;
function SetVBuf(fh : LongInt; buff : PChar; Type_ : LongInt; size : LongInt) : Boolean;
function SplitName(const Name : PChar; seperator : LongWord; buf : PChar; oldpos : LongInt; size : LongInt) : SmallInt;
function StartNotify(notify : PNotifyRequest) : Boolean;
function StrToDate(datetime : PDateTime) : Boolean;
function StrToLong(const string_ : PChar; VAR value : LongInt) : LongInt;
function SystemTagList(const command : PChar;const Tags : PTagItem) : LongInt;
//function DOSSystem(const command : PChar;const Tags : PTagItem) : LongInt; //* Real: SystemTagList ???
function UnGetC(fh : LongInt; character : LongInt) : LongInt;
procedure UnLoadSeg(seglist : LongInt);
procedure UnLock(Lock : LongInt);
procedure UnLockDosList(Flags : LongWord);
function UnLockRecord(fh : LongInt; offset : LongWord; length : LongWord) : Boolean;
function UnLockRecords(recArray : PRecordLock) : Boolean;
function VFPrintf(fh : LongInt;const format : PChar;const argarray : Pointer) : LongInt;
procedure VFWritef(fh : LongInt;const format : PChar;const argarray : pLONGINT);
function VPrintf(const format : PChar; const argarray : Pointer) : LongInt;
function WaitForChar(file_ : LongInt; timeout : LongInt) : Boolean;
function WaitPkt : PDosPacket;
function WriteChars(const buf : PChar; buflen : LongWord) : LongInt;
{
function BADDR(bval :BPTR): Pointer;
function MKBADDR(adr: Pointer): BPTR;
}

{OVERLOADS}

function AddBuffers(Name : string; Number : LongInt) : Boolean;
function AddPart(dirname : string;const filename : PChar; size : LongWord) : Boolean;
function AddPart(dirname : PChar;filename : string; size : LongWord) : Boolean;
function AddPart(dirname : string;filename : string; size : LongWord) : Boolean;
function AssignAdd(Name : string; Lock : LongInt) : Boolean;
function AssignLate(Name : string;const Path : PChar) : Boolean;
function AssignLate(const Name : PChar;Path : string) : Boolean;
function AssignLate(Name : string;Path : string) : Boolean;
function AssignLock(Name : string; Lock : LongInt) : Boolean;
function AssignPath(Name : string; const Path : PChar) : Boolean;
function AssignPath(const Name : PChar;Path : string) : Boolean;
function AssignPath(Name : string;Path : string) : Boolean;
function CreateDir(Name : string) : LongInt;
function CreateProc(Name : string; pri : LongInt; segList : LongInt; stackSize : LongInt) : PMsgPort;
function DeleteFile(Name : string) : Boolean;
function DeleteVar(Name : string; Flags : LongWord) : Boolean;
function DeviceProc(Name : string) : PMsgPort;
function DOSOpen(Name : string; accessMode : LongInt) : LongInt;
function DOSRename(oldName : string;const newName : PChar) : boolean;
function DOSRename(const oldName : PChar;newName : string) : Boolean;
function DOSRename(oldName : string;newName : string) : Boolean;
function Execute(string_ : string; file_ : LongInt; file2 : LongInt) : Boolean;
function Fault(code : LongInt; header : string; buffer : PChar; len : LongInt) : Boolean;
function FilePart(Path : string) : PChar;
function FindArg(keyword : string;const arg_template : PChar) : LongInt;
function FindArg(const keyword : PChar; arg_template : string) : LongInt;
function FindArg(keyword : string; arg_template : string) : LongInt;
function FindDosEntry(const DList : PDosList; Name : string; Flags : LongWord) : PDosList;
function FindSegment(Name : string;const seg : PSegment; system : LongInt) : PSegment;
function FindVar(Name : string; Type_ : LongWord) : PLocalVar;
function dosFormat(filesystem : string;const volumename : PChar; dostype : LongWord) : Boolean;
function dosFormat(const filesystem : PChar; volumename : string; dostype : LongWord) : Boolean;
function dosFormat(filesystem : string; volumename : string; dostype : LongWord) : Boolean;
function FPuts(fh : LongInt; str : string) : Boolean;
function GetDeviceProc(Name : string; dp : pDevProc) : pDevProc;
function GetVar(Name : string; buffer : PChar; size : LongInt; Flags : LongInt) : LongInt;
function Inhibit(Name : string; onoff : LongInt) : Boolean;
function IsFileSystem(Name : string) : Boolean;
function LoadSeg(Name : string) : LongInt;
function Lock(Name : string; Type_ : LongInt) : LongInt;
function MakeDosEntry(Name : string; Type_ : LongInt) : PDosList;
function MakeLink(Name : string; dest : LongInt; soft : LongInt) : Boolean;
function MatchFirst(pat : string; anchor : PAnchorPath) : LongInt;
function MatchPattern(pat : string; str : PChar) : Boolean;
function MatchPattern(const pat : PChar; str : string) : Boolean;
function MatchPattern(pat : string; str : string) : Boolean;
function MatchPatternNoCase(pat : string; str : PChar) : Boolean;
function MatchPatternNoCase(const pat : PChar; str : string) : Boolean;
function MatchPatternNoCase(pat : string; str : string) : Boolean;
function NewLoadSeg(file_ : string;const Tags : PTagItem) : LongInt;
//function NewLoadSegTagList(const file_ : string;const Tags : PTagItem) : LongInt;
function PathPart(Path : string) : PChar;
function PrintFault(code : LongInt; header : string) : Boolean;
function PutStr(str : string) : Boolean;
function ReadArgs(arg_template : string; arra : pLONGINT; args : PRDArgs) : PRDArgs;
function ReadItem(Name : string; maxchars : LongInt; cSource : PCSource) : LongInt;
function ReadLink(Port : PMsgPort; Lock : LongInt; Path : string; buffer : PChar; size : LongWord) : Boolean;
function Relabel(drive : string;const newname : PChar) : Boolean;
function Relabel(const drive : PChar; newname : string) : Boolean;
function Relabel(drive : string; newname : string) : Boolean;
function RemAssignList(Name : string; Lock : LongInt) : Boolean;
function RunCommand(seg : LongInt; stack : LongInt; paramptr : string; paramlen : LongInt) : LongInt;
function SetArgStr(string_ : string) : Boolean;
function SetComment(Name : string;const comment : PChar) : Boolean;
function SetComment(const Name : PChar; comment : string) : Boolean;
function SetComment(Name : string; comment : string) : Boolean;
function SetCurrentDirName(Name : string) : Boolean;
function SetFileDate(Name : string; date : pDateStamp) : Boolean;
function SetOwner(Name : string; owner_info : LongInt) : Boolean;
function SetProgramName(Name : string) : Boolean;
function SetPrompt(Name : string) : Boolean;
function SetProtection(Name : string; protect : LongInt) : Boolean;
function SetVar(Name : string; buffer : PChar; size : LongInt; Flags : LongInt) : Boolean;
function SplitName(Name : string; seperator : LongWord; buf : PChar; oldpos : LongInt; size : LongInt) : SmallInt;
function StrToLong(string_ : string; VAR value : LongInt) : LongInt;
function SystemTagList(command : string;const Tags : PTagItem) : LongInt;
// function DOSSystem(const command : string;const Tags : PTagItem) : LongInt;


IMPLEMENTATION

uses pastoc;


procedure AbortPkt(Port : PMsgPort;  Pkt : PDosPacket);
type
  TLocalCall = procedure(Port : PMsgPort;  Pkt : PDosPacket; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,44));
  Call( Port, Pkt, AOS_DOSBase);
End;


function AddBuffers(const Name : PChar;  Number : LongInt):Boolean;
type
  TLocalCall = function(const Name : PChar;  Number : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,122));
  AddBuffers:= Call( Name, Number, AOS_DOSBase);
End;


function AddDosEntry(DList : PDosList):Boolean;
type
  TLocalCall = function(DList : PDosList; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,113));
  AddDosEntry:= Call( DList, AOS_DOSBase);
End;


function AddPart(dirname : PChar; const filename : PChar;  size : LongWord):Boolean;
type
  TLocalCall = function(dirname : PChar; const filename : PChar;  size : LongWord; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,147));
  AddPart:= Call( dirname, filename, size, AOS_DOSBase);
End;


function AddSegment(const Name : PChar;  seg : LongInt;  system : LongInt):Boolean;
type
  TLocalCall = function(const Name : PChar;  seg : LongInt;  system : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,129));
  AddSegment:= Call( Name, seg, system, AOS_DOSBase);
End;


function AllocDosObject(Type_ : LongWord; const Tags : PTagItem):Pointer;
type
  TLocalCall = function(Type_ : LongWord; const Tags : PTagItem; LibBase: Pointer):Pointer; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,38));
  AllocDosObject:= Call( Type_, Tags, AOS_DOSBase);
End;

{
function AllocDosObjectTagList(Type_ : LongWord; const Tags : PTagItem):Pointer;
type
  TLocalCall = function(Type_ : LongWord; const Tags : PTagItem; LibBase: Pointer):Pointer; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,???));
  AllocDosObjectTagList:= Call( Type_, Tags, AOS_DOSBase);
End;
}

function AssignAdd(const Name : PChar;  Lock : LongInt):Boolean;
type
  TLocalCall = function(const Name : PChar;  Lock : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,105));
  AssignAdd:= Call( Name, Lock, AOS_DOSBase);
End;


function AssignLate(const Name : PChar; const Path : PChar):Boolean;
type
  TLocalCall = function(const Name : PChar; const Path : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,103));
  AssignLate:= Call( Name, Path, AOS_DOSBase);
End;


function AssignLock(const Name : PChar;  Lock : LongInt):Boolean;
type
  TLocalCall = function(const Name : PChar;  Lock : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,102));
  AssignLock:= Call( Name, Lock, AOS_DOSBase);
End;


function AssignPath(const Name : PChar; const Path : PChar):Boolean;
type
  TLocalCall = function(const Name : PChar; const Path : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,104));
  AssignPath:= Call( Name, Path, AOS_DOSBase);
End;


function AttemptLockDosList(Flags : LongWord):PDosList;
type
  TLocalCall = function(Flags : LongWord; LibBase: Pointer):PDosList; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,111));
  AttemptLockDosList:= Call( Flags, AOS_DOSBase);
End;


function ChangeMode(Type_ : LongInt;  fh : LongInt;  NewMode : LongInt):Boolean;
type
  TLocalCall = function(Type_ : LongInt;  fh : LongInt;  NewMode : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,75));
  ChangeMode:= Call( Type_, fh, NewMode, AOS_DOSBase);
End;


function CheckSignal(Mask : LongInt):LongInt;
type
  TLocalCall = function(Mask : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,132));
  CheckSignal:= Call( Mask, AOS_DOSBase);
End;


function Cli():PCommandLineInterface;
type
  TLocalCall = function(LibBase: Pointer):PCommandLineInterface; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,82));
  Cli:= Call(AOS_DOSBase);
End;


function CliInitNewcli(dp : PDosPacket):LongInt;
type
  TLocalCall = function(dp : PDosPacket; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,155));
  CliInitNewcli:= Call( dp, AOS_DOSBase);
End;


function CliInitRun(dp : PDosPacket):LongInt;
type
  TLocalCall = function(dp : PDosPacket; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,156));
  CliInitRun:= Call( dp, AOS_DOSBase);
End;


function CompareDates(const date1 : pDateStamp; const date2 : pDateStamp):LongInt;
type
  TLocalCall = function(const date1 : pDateStamp; const date2 : pDateStamp; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,123));
  CompareDates:= Call( date1, date2, AOS_DOSBase);
End;


function CreateDir(const Name : PChar):LongInt;
type
  TLocalCall = function(const Name : PChar; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,20));
  CreateDir:= Call( Name, AOS_DOSBase);
End;


function CreateNewProc(const Tags : PTagItem):pProcess;
type
  TLocalCall = function(const Tags : PTagItem; LibBase: Pointer):pProcess; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,83));
  CreateNewProc:= Call( Tags, AOS_DOSBase);
End;

{
function CreateNewProcTagList(const Tags : PTagItem):pProcess;
type
  TLocalCall = function(const Tags : PTagItem; LibBase: Pointer):pProcess; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,???));
  CreateNewProcTagList:= Call( Tags, AOS_DOSBase);
End;
}

function CreateProc(const Name : PChar;  pri : LongInt;  segList : LongInt;  stackSize : LongInt):PMsgPort;
type
  TLocalCall = function(const Name : PChar;  pri : LongInt;  segList : LongInt;  stackSize : LongInt; LibBase: Pointer):PMsgPort; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,23));
  CreateProc:= Call( Name, pri, segList, stackSize, AOS_DOSBase);
End;


function CurrentDir(Lock : LongInt):LongInt;
type
  TLocalCall = function(Lock : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,21));
  CurrentDir:= Call( Lock, AOS_DOSBase);
End;


procedure DateStamp(date : pDateStamp);
type
  TLocalCall = procedure(date : pDateStamp; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,32));
  Call( date, AOS_DOSBase);
End;


function DateToStr(datetime : PDateTime):Boolean;
type
  TLocalCall = function(datetime : PDateTime; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,124));
  DateToStr:= Call( datetime, AOS_DOSBase);
End;


function DeleteFile(const Name : PChar):Boolean;
type
  TLocalCall = function(const Name : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,12));
  DeleteFile:= Call( Name, AOS_DOSBase);
End;


function DeleteVar(const Name : PChar;  Flags : LongWord):Boolean;
type
  TLocalCall = function(const Name : PChar;  Flags : LongWord; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,152));
  DeleteVar:= Call( Name, Flags, AOS_DOSBase);
End;


function DeviceProc(const Name : PChar):PMsgPort;
type
  TLocalCall = function(const Name : PChar; LibBase: Pointer):PMsgPort; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,29));
  DeviceProc:= Call( Name, AOS_DOSBase);
End;


function DoPkt(Port : PMsgPort;  action : LongInt;  arg1 : LongInt;  arg2 : LongInt;  arg3 : LongInt;  arg4 : LongInt;  arg5 : LongInt):LongInt;
type
  TLocalCall = function(Port : PMsgPort;  action : LongInt;  arg1 : LongInt;  arg2 : LongInt;  arg3 : LongInt;  arg4 : LongInt;  arg5 : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,40));
  DoPkt:= Call( Port, action, arg1, arg2, arg3, arg4, arg5, AOS_DOSBase);
End;

{
function DoPkt0(Port : PMsgPort;  action : LongInt):LongInt;
type
  TLocalCall = function(Port : PMsgPort;  action : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,???));
  DoPkt0:= Call( Port, action, AOS_DOSBase);
End;


function DoPkt1(Port : PMsgPort;  action : LongInt;  arg1 : LongInt):LongInt;
type
  TLocalCall = function(Port : PMsgPort;  action : LongInt;  arg1 : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,???));
  DoPkt1:= Call( Port, action, arg1, AOS_DOSBase);
End;


function DoPkt2(Port : PMsgPort;  action : LongInt;  arg1 : LongInt;  arg2 : LongInt):LongInt;
type
  TLocalCall = function(Port : PMsgPort;  action : LongInt;  arg1 : LongInt;  arg2 : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,???));
  DoPkt2:= Call( Port, action, arg1, arg2, AOS_DOSBase);
End;


function DoPkt3(Port : PMsgPort;  action : LongInt;  arg1 : LongInt;  arg2 : LongInt;  arg3 : LongInt):LongInt;
type
  TLocalCall = function(Port : PMsgPort;  action : LongInt;  arg1 : LongInt;  arg2 : LongInt;  arg3 : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,???));
  DoPkt3:= Call( Port, action, arg1, arg2, arg3, AOS_DOSBase);
End;


function DoPkt4(Port : PMsgPort;  action : LongInt;  arg1 : LongInt;  arg2 : LongInt;  arg3 : LongInt;  arg4 : LongInt):LongInt;
type
  TLocalCall = function(Port : PMsgPort;  action : LongInt;  arg1 : LongInt;  arg2 : LongInt;  arg3 : LongInt;  arg4 : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,???));
  DoPkt4:= Call( Port, action, arg1, arg2, arg3, arg4, AOS_DOSBase);
End;
}

procedure DOSClose(file_ : LongInt);
type
  TLocalCall = procedure(file_ : LongInt; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,15));
  Call( file_, AOS_DOSBase);
End;


procedure DOSDelay(timeout : LongInt);
type
  TLocalCall = procedure(timeout : LongInt; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,33));
  Call( timeout, AOS_DOSBase);
End;


procedure DOSExit(returnCode : LongInt);
type
  TLocalCall = procedure(returnCode : LongInt; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,24));
  Call( returnCode, AOS_DOSBase);
End;


function DOSFlush(fh : LongInt):Boolean;
type
  TLocalCall = function(fh : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,60));
  DOSFlush:= Call( fh, AOS_DOSBase);
End;


function DOSInput():LongInt;
type
  TLocalCall = function(LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,9));
  DOSInput:= Call(AOS_DOSBase);
End;


function DOSOpen(const Name : PChar;  accessMode : LongInt):LongInt;
type
  TLocalCall = function(const Name : PChar;  accessMode : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,5));
  DOSOpen:= Call( Name, accessMode, AOS_DOSBase);
End;


function DOSOutput():LongInt;
type
  TLocalCall = function(LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,10));
  DOSOutput:= Call(AOS_DOSBase);
End;


function DOSRead(file_ : LongInt;  buffer : Pointer;  length : LongInt):LongInt;
type
  TLocalCall = function(file_ : LongInt;  buffer : Pointer;  length : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,7));
  DOSRead:= Call( file_, buffer, length, AOS_DOSBase);
End;


function DOSRename(const oldName : PChar; const newName : PChar):Boolean;
type
  TLocalCall = function(const oldName : PChar; const newName : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,13));
  DOSRename:= Call( oldName, newName, AOS_DOSBase);
End;


function DOSSeek(file_ : LongInt;  position : LongInt;  offset : LongInt):LongInt;
type
  TLocalCall = function(file_ : LongInt;  position : LongInt;  offset : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,11));
  DOSSeek:= Call( file_, position, offset, AOS_DOSBase);
End;


function DOSWrite(file_ : LongInt;  buffer : Pointer;  length : LongInt):LongInt;
type
  TLocalCall = function(file_ : LongInt;  buffer : Pointer;  length : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,8));
  DOSWrite:= Call( file_, buffer, length, AOS_DOSBase);
End;


function DupLock(Lock : LongInt):LongInt;
type
  TLocalCall = function(Lock : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,62));
  DupLock:= Call( Lock, AOS_DOSBase);
End;


function DupLockFromFH(fh : LongInt):LongInt;
type
  TLocalCall = function(fh : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,62));
  DupLockFromFH:= Call( fh, AOS_DOSBase);
End;


procedure EndNotify(notify : PNotifyRequest);
type
  TLocalCall = procedure(notify : PNotifyRequest; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,149));
  Call( notify, AOS_DOSBase);
End;


function ErrorReport(code : LongInt;  Type_ : LongInt;  arg1 : LongWord;  device : PMsgPort):Boolean;
type
  TLocalCall = function(code : LongInt;  Type_ : LongInt;  arg1 : LongWord;  device : PMsgPort; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,80));
  ErrorReport:= Call( code, Type_, arg1, device, AOS_DOSBase);
End;


function ExAll(Lock : LongInt;  buffer : pExAllData;  size : LongInt;  data : LongInt;  control : pExAllControl):Boolean;
type
  TLocalCall = function(Lock : LongInt;  buffer : pExAllData;  size : LongInt;  data : LongInt;  control : pExAllControl; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,72));
  ExAll:= Call( Lock, buffer, size, data, control, AOS_DOSBase);
End;


procedure ExAllEnd(Lock : LongInt;  buffer : pExAllData;  size : LongInt;  data : LongInt;  control : pExAllControl);
type
  TLocalCall = procedure(Lock : LongInt;  buffer : pExAllData;  size : LongInt;  data : LongInt;  control : pExAllControl; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,165));
  Call( Lock, buffer, size, data, control, AOS_DOSBase);
End;


function Examine(Lock : LongInt;  fileInfoBlock : PFileInfoBlock):Boolean;
type
  TLocalCall = function(Lock : LongInt;  fileInfoBlock : PFileInfoBlock; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,65));
  Examine:= Call( Lock, fileInfoBlock, AOS_DOSBase);
End;


function ExamineFH(fh : LongInt;  fib : PFileInfoBlock):Boolean;
type
  TLocalCall = function(fh : LongInt;  fib : PFileInfoBlock; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,65));
  ExamineFH:= Call( fh, fib, AOS_DOSBase);
End;


function Execute(const string_ : PChar;  file_ : LongInt;  file2 : LongInt):Boolean;
type
  TLocalCall = function(const string_ : PChar;  file_ : LongInt;  file2 : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,37));
  Execute:= Call( string_, file_, file2, AOS_DOSBase);
End;


function ExNext(Lock : LongInt;  fileInfoBlock : PFileInfoBlock):Boolean;
type
  TLocalCall = function(Lock : LongInt;  fileInfoBlock : PFileInfoBlock; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,18));
  ExNext:= Call( Lock, fileInfoBlock, AOS_DOSBase);
End;


function Fault(code : LongInt;  header : PChar;  buffer : PChar;  len : LongInt):Boolean;
type
  TLocalCall = function(code : LongInt;  header : PChar;  buffer : PChar;  len : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,78));
  Fault:= Call( code, header, buffer, len, AOS_DOSBase);
End;


function FGetC(fh : LongInt):LongInt;
type
  TLocalCall = function(fh : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,51));
  FGetC:= Call( fh, AOS_DOSBase);
End;


function FGets(fh : LongInt;  buf : PChar;  buflen : LongWord):PChar;
type
  TLocalCall = function(fh : LongInt;  buf : PChar;  buflen : LongWord; LibBase: Pointer):PChar; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,56));
  FGets:= Call( fh, buf, buflen, AOS_DOSBase);
End;


function FilePart(const Path : PChar):PChar;
type
  TLocalCall = function(const Path : PChar; LibBase: Pointer):PChar; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,145));
  FilePart:= Call( Path, AOS_DOSBase);
End;


function FindArg(const keyword : PChar; const arg_template : PChar):LongInt;
type
  TLocalCall = function(const keyword : PChar; const arg_template : PChar; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,134));
  FindArg:= Call( keyword, arg_template, AOS_DOSBase);
End;


function FindCliProc(num : LongWord):pProcess;
type
  TLocalCall = function(num : LongWord; LibBase: Pointer):pProcess; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,91));
  FindCliProc:= Call( num, AOS_DOSBase);
End;


function FindDosEntry(const DList : PDosList; const Name : PChar;  Flags : LongWord):PDosList;
type
  TLocalCall = function(const DList : PDosList; const Name : PChar;  Flags : LongWord; LibBase: Pointer):PDosList; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,114));
  FindDosEntry:= Call( DList, Name, Flags, AOS_DOSBase);
End;


function FindSegment(const Name : PChar; const seg : PSegment;  system : LongInt):PSegment;
type
  TLocalCall = function(const Name : PChar; const seg : PSegment;  system : LongInt; LibBase: Pointer):PSegment; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,130));
  FindSegment:= Call( Name, seg, system, AOS_DOSBase);
End;


function FindVar(const Name : PChar;  Type_ : LongWord):PLocalVar;
type
  TLocalCall = function(const Name : PChar;  Type_ : LongWord; LibBase: Pointer):PLocalVar; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,153));
  FindVar:= Call( Name, Type_, AOS_DOSBase);
End;


function dosFormat(const filesystem : PChar; const volumename : PChar;  dostype : LongWord):Boolean;
type
  TLocalCall = function(const filesystem : PChar; const volumename : PChar;  dostype : LongWord; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,119));
  dosFormat:= Call( filesystem, volumename, dostype, AOS_DOSBase);
End;


function FPutC(fh : LongInt;  ch : LongInt):LongInt;
type
  TLocalCall = function(fh : LongInt;  ch : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,52));
  FPutC:= Call( fh, ch, AOS_DOSBase);
End;


function FPuts(fh : LongInt; const str : PChar):Boolean;
type
  TLocalCall = function(fh : LongInt; const str : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,57));
  FPuts:= Call( fh, str, AOS_DOSBase);
End;


function FRead(fh : LongInt;  block : Pointer;  blocklen : LongWord;  Number : LongWord):LongInt;
type
  TLocalCall = function(fh : LongInt;  block : Pointer;  blocklen : LongWord;  Number : LongWord; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,54));
  FRead:= Call( fh, block, blocklen, Number, AOS_DOSBase);
End;


procedure FreeArgs(args : PRDArgs);
type
  TLocalCall = procedure(args : PRDArgs; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,143));
  Call( args, AOS_DOSBase);
End;


procedure FreeDeviceProc(dp : pDevProc);
type
  TLocalCall = procedure(dp : pDevProc; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,108));
  Call( dp, AOS_DOSBase);
End;


procedure FreeDosEntry(DList : PDosList);
type
  TLocalCall = procedure(DList : PDosList; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,117));
  Call( DList, AOS_DOSBase);
End;


procedure FreeDosObject(Type_ : LongWord;  ptr : Pointer);
type
  TLocalCall = procedure(Type_ : LongWord;  ptr : Pointer; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,39));
  Call( Type_, ptr, AOS_DOSBase);
End;


function FWrite(fh : LongInt;  block : Pointer;  blocklen : LongWord;  Number : LongWord):LongInt;
type
  TLocalCall = function(fh : LongInt;  block : Pointer;  blocklen : LongWord;  Number : LongWord; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,55));
  FWrite:= Call( fh, block, blocklen, Number, AOS_DOSBase);
End;


function GetArgStr():PChar;
type
  TLocalCall = function(LibBase: Pointer):PChar; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,89));
  GetArgStr:= Call(AOS_DOSBase);
End;


function GetConsoleTask():PMsgPort;
type
  TLocalCall = function(LibBase: Pointer):PMsgPort; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,85));
  GetConsoleTask:= Call(AOS_DOSBase);
End;


function GetCurrentDirName(buf : PChar;  len : LongInt):Boolean;
type
  TLocalCall = function(buf : PChar;  len : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,94));
  GetCurrentDirName:= Call( buf, len, AOS_DOSBase);
End;


function GetDeviceProc(const Name : PChar;  dp : pDevProc):pDevProc;
type
  TLocalCall = function(const Name : PChar;  dp : pDevProc; LibBase: Pointer):pDevProc; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,107));
  GetDeviceProc:= Call( Name, dp, AOS_DOSBase);
End;


function GetFileSysTask():PMsgPort;
type
  TLocalCall = function(LibBase: Pointer):PMsgPort; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,87));
  GetFileSysTask:= Call(AOS_DOSBase);
End;


function GetProgramDir():LongInt;
type
  TLocalCall = function(LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,100));
  GetProgramDir:= Call(AOS_DOSBase);
End;


function GetProgramName(buf : PChar;  len : LongInt):Boolean;
type
  TLocalCall = function(buf : PChar;  len : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,96));
  GetProgramName:= Call( buf, len, AOS_DOSBase);
End;


function GetPrompt(buf : PChar;  len : LongInt):Boolean;
type
  TLocalCall = function(buf : PChar;  len : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,98));
  GetPrompt:= Call( buf, len, AOS_DOSBase);
End;


function GetVar(const Name : PChar;  buffer : PChar;  size : LongInt;  Flags : LongInt):LongInt;
type
  TLocalCall = function(const Name : PChar;  buffer : PChar;  size : LongInt;  Flags : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,151));
  GetVar:= Call( Name, buffer, size, Flags, AOS_DOSBase);
End;


function Info(Lock : LongInt;  parameterBlock : PInfoData):Boolean;
type
  TLocalCall = function(Lock : LongInt;  parameterBlock : PInfoData; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,19));
  Info:= Call( Lock, parameterBlock, AOS_DOSBase);
End;


function Inhibit(const Name : PChar;  onoff : LongInt):Boolean;
type
  TLocalCall = function(const Name : PChar;  onoff : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,121));
  Inhibit:= Call( Name, onoff, AOS_DOSBase);
End;


function InternalLoadSeg(fh : LongInt;  table : LongInt; const funcarray : pLONGINT;  VAR stack : LongInt):LongInt;
type
  TLocalCall = function(fh : LongInt;  table : LongInt; const funcarray : pLONGINT;  VAR stack : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,126));
  InternalLoadSeg:= Call( fh, table, funcarray, stack, AOS_DOSBase);
End;


function InternalUnLoadSeg(seglist : LongInt;  freefunc : tPROCEDURE):Boolean;
type
  TLocalCall = function(seglist : LongInt;  freefunc : tPROCEDURE; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,127));
  InternalUnLoadSeg:= Call( seglist, freefunc, AOS_DOSBase);
End;


function IoErr():LongInt;
type
  TLocalCall = function(LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,22));
  IoErr:= Call(AOS_DOSBase);
End;


function IsFileSystem(const Name : PChar):Boolean;
type
  TLocalCall = function(const Name : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,118));
  IsFileSystem:= Call( Name, AOS_DOSBase);
End;


function IsInteractive(file_ : LongInt):Boolean;
type
  TLocalCall = function(file_ : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,36));
  IsInteractive:= Call( file_, AOS_DOSBase);
End;


function LoadSeg(const Name : PChar):LongInt;
type
  TLocalCall = function(const Name : PChar; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,25));
  LoadSeg:= Call( Name, AOS_DOSBase);
End;


function Lock(const Name : PChar;  Type_ : LongInt):LongInt;
type
  TLocalCall = function(const Name : PChar;  Type_ : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,14));
  Lock:= Call( Name, Type_, AOS_DOSBase);
End;


function LockDosList(Flags : LongWord):PDosList;
type
  TLocalCall = function(Flags : LongWord; LibBase: Pointer):PDosList; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,109));
  LockDosList:= Call( Flags, AOS_DOSBase);
End;


function LockRecord(fh : LongInt;  offset : LongWord;  length : LongWord;  mode : LongWord;  timeout : LongWord):Boolean;
type
  TLocalCall = function(fh : LongInt;  offset : LongWord;  length : LongWord;  mode : LongWord;  timeout : LongWord; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,45));
  LockRecord:= Call( fh, offset, length, mode, timeout, AOS_DOSBase);
End;


function LockRecords(recArray : PRecordLock;  timeout : LongWord):Boolean;
type
  TLocalCall = function(recArray : PRecordLock;  timeout : LongWord; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,46));
  LockRecords:= Call( recArray, timeout, AOS_DOSBase);
End;


function MakeDosEntry(const Name : PChar;  Type_ : LongInt):PDosList;
type
  TLocalCall = function(const Name : PChar;  Type_ : LongInt; LibBase: Pointer):PDosList; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,116));
  MakeDosEntry:= Call( Name, Type_, AOS_DOSBase);
End;


function MakeLink(const Name : PChar;  dest : LongInt;  soft : LongInt):Boolean;
type
  TLocalCall = function(const Name : PChar;  dest : LongInt;  soft : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,74));
  MakeLink:= Call( Name, dest, soft, AOS_DOSBase);
End;


procedure MatchEnd(anchor : PAnchorPath);
type
  TLocalCall = procedure(anchor : PAnchorPath; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,139));
  Call( anchor, AOS_DOSBase);
End;


function MatchFirst(const pat : PChar;  anchor : PAnchorPath):LongInt;
type
  TLocalCall = function(const pat : PChar;  anchor : PAnchorPath; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,137));
  MatchFirst:= Call( pat, anchor, AOS_DOSBase);
End;


function MatchNext(anchor : PAnchorPath):LongInt;
type
  TLocalCall = function(anchor : PAnchorPath; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,138));
  MatchNext:= Call( anchor, AOS_DOSBase);
End;


function MatchPattern(const pat : PChar;  str : PChar):Boolean;
type
  TLocalCall = function(const pat : PChar;  str : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,141));
  MatchPattern:= Call( pat, str, AOS_DOSBase);
End;


function MatchPatternNoCase(const pat : PChar;  str : PChar):Boolean;
type
  TLocalCall = function(const pat : PChar;  str : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,162));
  MatchPatternNoCase:= Call( pat, str, AOS_DOSBase);
End;


function MaxCli():LongWord;
type
  TLocalCall = function(LibBase: Pointer):LongWord; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,92));
  MaxCli:= Call(AOS_DOSBase);
End;


function NameFromFH(fh : LongInt;  buffer : PChar;  len : LongInt):Boolean;
type
  TLocalCall = function(fh : LongInt;  buffer : PChar;  len : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,68));
  NameFromFH:= Call( fh, buffer, len, AOS_DOSBase);
End;


function NameFromLock(Lock : LongInt;  buffer : PChar;  len : LongInt):Boolean;
type
  TLocalCall = function(Lock : LongInt;  buffer : PChar;  len : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,68));
  NameFromLock:= Call( Lock, buffer, len, AOS_DOSBase);
End;


function NewLoadSeg(const file_ : PChar; const Tags : PTagItem):LongInt;
type
  TLocalCall = function(const file_ : PChar; const Tags : PTagItem; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,128));
  NewLoadSeg:= Call( file_, Tags, AOS_DOSBase);
End;

{
function NewLoadSegTagList(const file_ : PChar; const Tags : PTagItem):LongInt;
type
  TLocalCall = function(const file_ : PChar; const Tags : PTagItem; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,???));
  NewLoadSegTagList:= Call( file_, Tags, AOS_DOSBase);
End;
}

function NextDosEntry(const DList : PDosList;  Flags : LongWord):PDosList;
type
  TLocalCall = function(const DList : PDosList;  Flags : LongWord; LibBase: Pointer):PDosList; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,115));
  NextDosEntry:= Call( DList, Flags, AOS_DOSBase);
End;


function OpenFromLock(Lock : LongInt):LongInt;
type
  TLocalCall = function(Lock : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,63));
  OpenFromLock:= Call( Lock, AOS_DOSBase);
End;


function ParentDir(Lock : LongInt):LongInt;
type
  TLocalCall = function(Lock : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,35));
  ParentDir:= Call( Lock, AOS_DOSBase);
End;


function ParentOfFH(fh : LongInt):LongInt;
type
  TLocalCall = function(fh : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,64));
  ParentOfFH:= Call( fh, AOS_DOSBase);
End;


function ParsePattern(const pat : PChar;  buf : PChar;  buflen : LongInt):LongInt;
type
  TLocalCall = function(const pat : PChar;  buf : PChar;  buflen : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,140));
  ParsePattern:= Call( pat, buf, buflen, AOS_DOSBase);
End;


function ParsePatternNoCase(const pat : PChar;  buf : PChar;  buflen : LongInt):LongInt;
type
  TLocalCall = function(const pat : PChar;  buf : PChar;  buflen : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,161));
  ParsePatternNoCase:= Call( pat, buf, buflen, AOS_DOSBase);
End;


function PathPart(const Path : PChar):PChar;
type
  TLocalCall = function(const Path : PChar; LibBase: Pointer):PChar; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,146));
  PathPart:= Call( Path, AOS_DOSBase);
End;


function PrintFault(code : LongInt; const header : PChar):Boolean;
type
  TLocalCall = function(code : LongInt; const header : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,79));
  PrintFault:= Call( code, header, AOS_DOSBase);
End;


function PutStr(const str : PChar):Boolean;
type
  TLocalCall = function(const str : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,158));
  PutStr:= Call( str, AOS_DOSBase);
End;


function ReadArgs(const arg_template : PChar;  arra : pLONGINT;  args : PRDArgs):PRDArgs;
type
  TLocalCall = function(const arg_template : PChar;  arra : pLONGINT;  args : PRDArgs; LibBase: Pointer):PRDArgs; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,133));
  ReadArgs:= Call( arg_template, arra, args, AOS_DOSBase);
End;


function ReadItem(const Name : PChar;  maxchars : LongInt;  cSource : PCSource):LongInt;
type
  TLocalCall = function(const Name : PChar;  maxchars : LongInt;  cSource : PCSource; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,135));
  ReadItem:= Call( Name, maxchars, cSource, AOS_DOSBase);
End;


function ReadLink(Port : PMsgPort;  Lock : LongInt; const Path : PChar;  buffer : PChar;  size : LongWord):Boolean;
type
  TLocalCall = function(Port : PMsgPort;  Lock : LongInt; const Path : PChar;  buffer : PChar;  size : LongWord; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,73));
  ReadLink:= Call( Port, Lock, Path, buffer, size, AOS_DOSBase);
End;


function Relabel(const drive : PChar; const newname : PChar):Boolean;
type
  TLocalCall = function(const drive : PChar; const newname : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,120));
  Relabel:= Call( drive, newname, AOS_DOSBase);
End;


function RemAssignList(const Name : PChar;  Lock : LongInt):Boolean;
type
  TLocalCall = function(const Name : PChar;  Lock : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,106));
  RemAssignList:= Call( Name, Lock, AOS_DOSBase);
End;


function RemDosEntry(DList : PDosList):Boolean;
type
  TLocalCall = function(DList : PDosList; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,112));
  RemDosEntry:= Call( DList, AOS_DOSBase);
End;


function RemSegment(seg : PSegment):Boolean;
type
  TLocalCall = function(seg : PSegment; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,131));
  RemSegment:= Call( seg, AOS_DOSBase);
End;


procedure ReplyPkt(dp : PDosPacket;  res1 : LongInt;  res2 : LongInt);
type
  TLocalCall = procedure(dp : PDosPacket;  res1 : LongInt;  res2 : LongInt; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,43));
  Call( dp, res1, res2, AOS_DOSBase);
End;


function RunCommand(seg : LongInt;  stack : LongInt; const paramptr : PChar;  paramlen : LongInt):LongInt;
type
  TLocalCall = function(seg : LongInt;  stack : LongInt; const paramptr : PChar;  paramlen : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,84));
  RunCommand:= Call( seg, stack, paramptr, paramlen, AOS_DOSBase);
End;


function SameDevice(lock1 : LongInt;  lock2 : LongInt):Boolean;
type
  TLocalCall = function(lock1 : LongInt;  lock2 : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,164));
  SameDevice:= Call( lock1, lock2, AOS_DOSBase);
End;


function SameLock(lock1 : LongInt;  lock2 : LongInt):LongInt;
type
  TLocalCall = function(lock1 : LongInt;  lock2 : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,70));
  SameLock:= Call( lock1, lock2, AOS_DOSBase);
End;


function SelectInput(fh : LongInt):LongInt;
type
  TLocalCall = function(fh : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,49));
  SelectInput:= Call( fh, AOS_DOSBase);
End;


function SelectOutput(fh : LongInt):LongInt;
type
  TLocalCall = function(fh : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,50));
  SelectOutput:= Call( fh, AOS_DOSBase);
End;


procedure SendPkt(dp : PDosPacket;  Port : PMsgPort;  replyport : PMsgPort);
type
  TLocalCall = procedure(dp : PDosPacket;  Port : PMsgPort;  replyport : PMsgPort; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,41));
  Call( dp, Port, replyport, AOS_DOSBase);
End;


function SetArgStr(const string_ : PChar):Boolean;
type
  TLocalCall = function(const string_ : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,90));
  SetArgStr:= Call( string_, AOS_DOSBase);
End;


function SetComment(const Name : PChar; const comment : PChar):Boolean;
type
  TLocalCall = function(const Name : PChar; const comment : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,30));
  SetComment:= Call( Name, comment, AOS_DOSBase);
End;


function SetConsoleTask(const task : PMsgPort):PMsgPort;
type
  TLocalCall = function(const task : PMsgPort; LibBase: Pointer):PMsgPort; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,86));
  SetConsoleTask:= Call( task, AOS_DOSBase);
End;


function SetCurrentDirName(const Name : PChar):Boolean;
type
  TLocalCall = function(const Name : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,93));
  SetCurrentDirName:= Call( Name, AOS_DOSBase);
End;


function SetFileDate(const Name : PChar;  date : pDateStamp):Boolean;
type
  TLocalCall = function(const Name : PChar;  date : pDateStamp; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,66));
  SetFileDate:= Call( Name, date, AOS_DOSBase);
End;


function SetFileSize(fh : LongInt;  pos : LongInt;  mode : LongInt):Boolean;
type
  TLocalCall = function(fh : LongInt;  pos : LongInt;  mode : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,76));
  SetFileSize:= Call( fh, pos, mode, AOS_DOSBase);
End;


function SetFileSysTask(const task : PMsgPort):PMsgPort;
type
  TLocalCall = function(const task : PMsgPort; LibBase: Pointer):PMsgPort; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,88));
  SetFileSysTask:= Call( task, AOS_DOSBase);
End;


function SetIoErr(result : LongInt):LongInt;
type
  TLocalCall = function(result : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,77));
  SetIoErr:= Call( result, AOS_DOSBase);
End;


function SetMode(fh : LongInt;  mode : LongInt):Boolean;
type
  TLocalCall = function(fh : LongInt;  mode : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,71));
  SetMode:= Call( fh, mode, AOS_DOSBase);
End;


function SetOwner(const Name : PChar;  owner_info : LongInt):Boolean;
type
  TLocalCall = function(const Name : PChar;  owner_info : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,166));
  SetOwner:= Call( Name, owner_info, AOS_DOSBase);
End;


function SetProgramDir(Lock : LongInt):LongInt;
type
  TLocalCall = function(Lock : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,99));
  SetProgramDir:= Call( Lock, AOS_DOSBase);
End;


function SetProgramName(const Name : PChar):Boolean;
type
  TLocalCall = function(const Name : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,95));
  SetProgramName:= Call( Name, AOS_DOSBase);
End;


function SetPrompt(const Name : PChar):Boolean;
type
  TLocalCall = function(const Name : PChar; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,97));
  SetPrompt:= Call( Name, AOS_DOSBase);
End;


function SetProtection(const Name : PChar;  protect : LongInt):Boolean;
type
  TLocalCall = function(const Name : PChar;  protect : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,31));
  SetProtection:= Call( Name, protect, AOS_DOSBase);
End;


function SetVar(const Name : PChar;  buffer : PChar;  size : LongInt;  Flags : LongInt):Boolean;
type
  TLocalCall = function(const Name : PChar;  buffer : PChar;  size : LongInt;  Flags : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,150));
  SetVar:= Call( Name, buffer, size, Flags, AOS_DOSBase);
End;


function SetVBuf(fh : LongInt;  buff : PChar;  Type_ : LongInt;  size : LongInt):Boolean;
type
  TLocalCall = function(fh : LongInt;  buff : PChar;  Type_ : LongInt;  size : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,61));
  SetVBuf:= Call( fh, buff, Type_, size, AOS_DOSBase);
End;


function SplitName(const Name : PChar;  seperator : LongWord;  buf : PChar;  oldpos : LongInt;  size : LongInt):SmallInt;
type
  TLocalCall = function(const Name : PChar;  seperator : LongWord;  buf : PChar;  oldpos : LongInt;  size : LongInt; LibBase: Pointer):SmallInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,69));
  SplitName:= Call( Name, seperator, buf, oldpos, size, AOS_DOSBase);
End;


function StartNotify(notify : PNotifyRequest):Boolean;
type
  TLocalCall = function(notify : PNotifyRequest; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,148));
  StartNotify:= Call( notify, AOS_DOSBase);
End;


function StrToDate(datetime : PDateTime):Boolean;
type
  TLocalCall = function(datetime : PDateTime; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,125));
  StrToDate:= Call( datetime, AOS_DOSBase);
End;


function StrToLong(const string_ : PChar;  VAR value : LongInt):LongInt;
type
  TLocalCall = function(const string_ : PChar;  VAR value : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,136));
  StrToLong:= Call( string_, value, AOS_DOSBase);
End;


function SystemTagList(const command : PChar; const Tags : PTagItem):LongInt;
type
  TLocalCall = function(const command : PChar; const Tags : PTagItem; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,101));
  SystemTagList:= Call( command, Tags, AOS_DOSBase);
End;

{
function DOSSystem(const command : PChar; const Tags : PTagItem):LongInt;
type
  TLocalCall = function(const command : PChar; const Tags : PTagItem; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,???));
  DOSSystem:= Call( command, Tags, AOS_DOSBase);
End;
}

function UnGetC(fh : LongInt;  character : LongInt):LongInt;
type
  TLocalCall = function(fh : LongInt;  character : LongInt; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,53));
  UnGetC:= Call( fh, character, AOS_DOSBase);
End;


procedure UnLoadSeg(seglist : LongInt);
type
  TLocalCall = procedure(seglist : LongInt; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,26));
  Call( seglist, AOS_DOSBase);
End;


procedure UnLock(Lock : LongInt);
type
  TLocalCall = procedure(Lock : LongInt; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,15));
  Call( Lock, AOS_DOSBase);
End;


procedure UnLockDosList(Flags : LongWord);
type
  TLocalCall = procedure(Flags : LongWord; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,110));
  Call( Flags, AOS_DOSBase);
End;


function UnLockRecord(fh : LongInt;  offset : LongWord;  length : LongWord):Boolean;
type
  TLocalCall = function(fh : LongInt;  offset : LongWord;  length : LongWord; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,47));
  UnLockRecord:= Call( fh, offset, length, AOS_DOSBase);
End;


function UnLockRecords(recArray : PRecordLock):Boolean;
type
  TLocalCall = function(recArray : PRecordLock; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,48));
  UnLockRecords:= Call( recArray, AOS_DOSBase);
End;


function VFPrintf(fh : LongInt; const format : PChar; const argarray : Pointer):LongInt;
type
  TLocalCall = function(fh : LongInt; const format : PChar; const argarray : Pointer; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,59));
  VFPrintf:= Call( fh, format, argarray, AOS_DOSBase);
End;


procedure VFWritef(fh : LongInt; const format : PChar; const argarray : pLONGINT);
type
  TLocalCall = procedure(fh : LongInt; const format : PChar; const argarray : pLONGINT; LibBase: Pointer); cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,58));
  Call( fh, format, argarray, AOS_DOSBase);
End;


function VPrintf(const format : PChar;  const argarray : Pointer):LongInt;
type
  TLocalCall = function(const format : PChar;  const argarray : Pointer; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,159));
  VPrintf:= Call( format, argarray, AOS_DOSBase);
End;


function WaitForChar(file_ : LongInt;  timeout : LongInt):Boolean;
type
  TLocalCall = function(file_ : LongInt;  timeout : LongInt; LibBase: Pointer):Boolean; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,34));
  WaitForChar:= Call( file_, timeout, AOS_DOSBase);
End;


function WaitPkt():PDosPacket;
type
  TLocalCall = function(LibBase: Pointer):PDosPacket; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,42));
  WaitPkt:= Call(AOS_DOSBase);
End;


function WriteChars(const buf : PChar;  buflen : LongWord):LongInt;
type
  TLocalCall = function(const buf : PChar;  buflen : LongWord; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,157));
  WriteChars:= Call( buf, buflen, AOS_DOSBase);
End;

{
function BADDR(bval :BPTR):Pointer;
type
  TLocalCall = function(bval :BPTR; LibBase: Pointer):Pointer; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,???));
  BADDR:= Call( bval, AOS_DOSBase);
End;


function MKBADDR(adr: Pointer):BPTR;
type
  TLocalCall = function(adr: Pointer; LibBase: Pointer):BPTR; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,???));
  MKBADDR:= Call( adr, AOS_DOSBase);
End;
}

{OVERLOADS}

function AddBuffers(Name : string;  Number : LongInt):Boolean;
Begin
  AddBuffers := AddBuffers( pas2c(Name), Number);
End;


function AddPart(dirname : string; const filename : PChar;  size : LongWord):Boolean;
Begin
  AddPart:= AddPart( pas2c(dirname), filename, size);
End;


function AddPart(dirname : PChar; filename : string;  size : LongWord):Boolean;
Begin
  AddPart:= AddPart( dirname, pas2c(filename), size);
End;


function AddPart(dirname : string; filename : string;  size : LongWord):Boolean;
Begin
  AddPart:= AddPart( pas2c(dirname), pas2c(filename), size);
End;


function AssignAdd(Name : string;  Lock : LongInt):Boolean;
Begin
  AssignAdd:= AssignAdd( pas2c(Name), Lock);
End;


function AssignLate(Name : string; const Path : PChar):Boolean;
Begin
  AssignLate:= AssignLate( pas2c(Name), Path);
End;


function AssignLate(const Name : PChar; Path : string):Boolean;
Begin
  AssignLate:= AssignLate( Name, pas2c(Path));
End;


function AssignLate(Name : string; Path : string):Boolean;
Begin
  AssignLate:= AssignLate( pas2c(Name), pas2c(Path));
End;


function AssignLock(Name : string;  Lock : LongInt):Boolean;
Begin
  AssignLock:= AssignLock( pas2c(Name), Lock);
End;


function AssignPath(Name : string;  const Path : PChar):Boolean;
Begin
  AssignPath:= AssignPath( pas2c(Name), Path);
End;


function AssignPath(const Name : PChar; Path : string):Boolean;
Begin
  AssignPath:= AssignPath( Name, pas2c(Path));
End;


function AssignPath(Name : string; Path : string):Boolean;
Begin
  AssignPath:= AssignPath( pas2c(Name), pas2c(Path));
End;


function CreateDir(Name : string):LongInt;
Begin
  CreateDir:= CreateDir( pas2c(Name));
End;


function CreateProc(Name : string;  pri : LongInt;  segList : LongInt;  stackSize : LongInt):PMsgPort;
Begin
  CreateProc:= CreateProc( pas2c(Name), pri, segList, stackSize);
End;


function DeleteFile(Name : string):Boolean;
Begin
  DeleteFile:= DeleteFile( pas2c(Name));
End;


function DeleteVar(Name : string;  Flags : LongWord):Boolean;
Begin
  DeleteVar:= DeleteVar( pas2c(Name), Flags);
End;


function DeviceProc(Name : string):PMsgPort;
Begin
  DeviceProc:= DeviceProc( pas2c(Name));
End;


function DOSOpen(Name : string;  accessMode : LongInt):LongInt;
Begin
  DOSOpen:= DOSOpen( pas2c(Name), accessMode);
End;


function DOSRename(oldName : string; const newName : PChar):boolean;
Begin
  DOSRename:= DOSRename( pas2c(oldName), newName);
End;


function DOSRename(const oldName : PChar; newName : string):Boolean;
Begin
  DOSRename:= DOSRename( oldName, pas2c(newName));
End;


function DOSRename(oldName : string; newName : string):Boolean;
Begin
  DOSRename:= DOSRename( pas2c(oldName), pas2c(newName));
End;


function Execute(string_ : string;  file_ : LongInt;  file2 : LongInt):Boolean;
Begin
  Execute:= Execute( pas2c(string_), file_, file2);
End;


function Fault(code : LongInt;  header : string;  buffer : PChar;  len : LongInt):Boolean;
Begin
  Fault:= Fault( code, pas2c(header), buffer, len);
End;


function FilePart(Path : string):PChar;
Begin
  FilePart:= FilePart( pas2c(Path));
End;


function FindArg(keyword : string; const arg_template : PChar):LongInt;
Begin
  FindArg:= FindArg( pas2c(keyword), arg_template);
End;


function FindArg(const keyword : PChar; arg_template : string):LongInt;
Begin
  FindArg:= FindArg( keyword, pas2c(arg_template));
End;


function FindArg(keyword : string; arg_template : string):LongInt;
Begin
  FindArg:= FindArg( pas2c(keyword), pas2c(arg_template));
End;


function FindDosEntry(const DList : PDosList; Name : string;  Flags : LongWord):PDosList;
Begin
  FindDosEntry:= FindDosEntry( DList, pas2c(Name), Flags);
End;


function FindSegment(Name : string; const seg : PSegment;  system : LongInt):PSegment;
Begin
  FindSegment:= FindSegment( pas2c(Name), seg, system);
End;


function FindVar(Name : string;  Type_ : LongWord):PLocalVar;
Begin
  FindVar:= FindVar( pas2c(Name), Type_);
End;


function dosFormat(filesystem : string; const volumename : PChar;  dostype : LongWord):Boolean;
Begin
  dosFormat:= dosFormat( pas2c(filesystem), volumename, dostype);
End;


function dosFormat(const filesystem : PChar; volumename : string;  dostype : LongWord):Boolean;
Begin
  dosFormat:= dosFormat( filesystem, pas2c(volumename), dostype);
End;


function dosFormat(filesystem : string; volumename : string;  dostype : LongWord):Boolean;
Begin
  dosFormat:= dosFormat( pas2c(filesystem), pas2c(volumename), dostype);
End;


function FPuts(fh : LongInt; str : string):Boolean;
Begin
  FPuts:= FPuts( fh, pas2c(str));
End;


function GetDeviceProc(Name : string;  dp : pDevProc):pDevProc;
Begin
  GetDeviceProc:= GetDeviceProc( pas2c(Name), dp);
End;


function GetVar(Name : string;  buffer : PChar;  size : LongInt;  Flags : LongInt):LongInt;
Begin
  GetVar:= GetVar( pas2c(Name), buffer, size, Flags);
End;


function Inhibit(Name : string;  onoff : LongInt):Boolean;
Begin
  Inhibit:= Inhibit( pas2c(Name), onoff);
End;


function IsFileSystem(Name : string):Boolean;
Begin
  IsFileSystem:= IsFileSystem( pas2c(Name));
End;


function LoadSeg(Name : string):LongInt;
Begin
  LoadSeg:= LoadSeg( pas2c(Name));
End;


function Lock(Name : string;  Type_ : LongInt):LongInt;
Begin
  Lock:= Lock( pas2c(Name), Type_);
End;


function MakeDosEntry(Name : string;  Type_ : LongInt):PDosList;
Begin
  MakeDosEntry:= MakeDosEntry( pas2c(Name), Type_);
End;


function MakeLink(Name : string;  dest : LongInt;  soft : LongInt):Boolean;
Begin
  MakeLink:= MakeLink( pas2c(Name), dest, soft);
End;


function MatchFirst(pat : string;  anchor : PAnchorPath):LongInt;
Begin
  MatchFirst:= MatchFirst( pas2c(pat), anchor);
End;


function MatchPattern(pat : string;  str : PChar):Boolean;
Begin
  MatchPattern:= MatchPattern( pas2c(pat), str);
End;


function MatchPattern(const pat : PChar;  str : string):Boolean;
Begin
  MatchPattern:= MatchPattern( pat, pas2c(str));
End;


function MatchPattern(pat : string;  str : string):Boolean;
Begin
  MatchPattern:= MatchPattern( pas2c(pat), pas2c(str));
End;


function MatchPatternNoCase(pat : string;  str : PChar):Boolean;
Begin
  MatchPatternNoCase:= MatchPatternNoCase( pas2c(pat), str);
End;


function MatchPatternNoCase(const pat : PChar;  str : string):Boolean;
Begin
  MatchPatternNoCase:= MatchPatternNoCase( pat, pas2c(str));
End;


function MatchPatternNoCase(pat : string;  str : string):Boolean;
Begin
  MatchPatternNoCase:= MatchPatternNoCase( pas2c(pat), pas2c(str));
End;


function NewLoadSeg(file_ : string; const Tags : PTagItem):LongInt;
Begin
  NewLoadSeg:= NewLoadSeg( pas2c(file_), Tags);
End;

{
function NewLoadSegTagList(const file_ : string; const Tags : PTagItem):LongInt;
type
  TLocalCall = function(const file_ : string; const Tags : PTagItem; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,???));
  NewLoadSegTagList:= Call( file_, Tags, AOS_DOSBase);
End;
}

function PathPart(Path : string):PChar;
Begin
  PathPart:= PathPart( pas2c(Path));
End;


function PrintFault(code : LongInt; header : string):Boolean;
Begin
  PrintFault:= PrintFault( code, pas2c(header));
End;


function PutStr(str : string):Boolean;
Begin
  PutStr:= PutStr( pas2c(str));
End;


function ReadArgs(arg_template : string;  arra : pLONGINT;  args : PRDArgs):PRDArgs;
Begin
  ReadArgs:= ReadArgs( pas2c(arg_template), arra, args);
End;


function ReadItem(Name : string;  maxchars : LongInt;  cSource : PCSource):LongInt;
Begin
  ReadItem:= ReadItem( pas2c(Name), maxchars, cSource);
End;


function ReadLink(Port : PMsgPort;  Lock : LongInt; Path : string;  buffer : PChar;  size : LongWord):Boolean;
Begin
  ReadLink:= ReadLink( Port, Lock, pas2c(Path), buffer, size);
End;


function Relabel(drive : string; const newname : PChar):Boolean;
Begin
  Relabel:= Relabel( pas2c(drive), newname);
End;


function Relabel(const drive : PChar; newname : string):Boolean;
Begin
  Relabel:= Relabel( drive, pas2c(newname));
End;


function Relabel(drive : string; newname : string):Boolean;
Begin
  Relabel:= Relabel( pas2c(drive), pas2c(newname));
End;


function RemAssignList(Name : string;  Lock : LongInt):Boolean;
Begin
  RemAssignList:= RemAssignList( pas2c(Name), Lock);
End;


function RunCommand(seg : LongInt;  stack : LongInt; paramptr : string;  paramlen : LongInt):LongInt;
Begin
  RunCommand:= RunCommand( seg, stack, pas2c(paramptr), paramlen);
End;


function SetArgStr(string_ : string):Boolean;
Begin
  SetArgStr:= SetArgStr( pas2c(string_));
End;


function SetComment(Name : string; const comment : PChar):Boolean;
Begin
  SetComment:= SetComment( pas2c(Name), comment);
End;


function SetComment(const Name : PChar; comment : string):Boolean;
Begin
  SetComment:= SetComment( Name, pas2c(comment));
End;


function SetComment(Name : string; comment : string):Boolean;
Begin
  SetComment:= SetComment( pas2c(Name), pas2c(comment));
End;


function SetCurrentDirName(Name : string):Boolean;
Begin
  SetCurrentDirName:= SetCurrentDirName( pas2c(Name));
End;


function SetFileDate(Name : string;  date : pDateStamp):Boolean;
Begin
  SetFileDate:= SetFileDate( pas2c(Name), date);
End;


function SetOwner(Name : string;  owner_info : LongInt):Boolean;
Begin
  SetOwner:= SetOwner( pas2c(Name), owner_info);
End;


function SetProgramName(Name : string):Boolean;
Begin
  SetProgramName:= SetProgramName( pas2c(Name));
End;


function SetPrompt(Name : string):Boolean;
Begin
  SetPrompt:= SetPrompt( pas2c(Name));
End;


function SetProtection(Name : string;  protect : LongInt):Boolean;
Begin
  SetProtection:= SetProtection( pas2c(Name), protect);
End;


function SetVar(Name : string;  buffer : PChar;  size : LongInt;  Flags : LongInt):Boolean;
Begin
  SetVar:= SetVar( pas2c(Name), buffer, size, Flags);
End;


function SplitName(Name : string;  seperator : LongWord;  buf : PChar;  oldpos : LongInt;  size : LongInt):SmallInt;
Begin
  SplitName:= SplitName( pas2c(Name), seperator, buf, oldpos, size);
End;


function StrToLong(string_ : string;  VAR value : LongInt):LongInt;
Begin
  StrToLong:= StrToLong( pas2c(string_), value);
End;


function SystemTagList(command : string; const Tags : PTagItem):LongInt;
Begin
  SystemTagList:= SystemTagList( pas2c(command), Tags);
End;

{
function DOSSystem(const command : string; const Tags : PTagItem):LongInt;
type
  TLocalCall = function(const command : string; const Tags : PTagItem; LibBase: Pointer):LongInt; cdecl;
Var
  Call: TLocalCall;
Begin
  Call:=TLocalCall(GetLibAdress(AOS_DOSBase,???));
  DOSSystem:= Call( command, Tags, AOS_DOSBase);
End;
}

END. (* UNIT DOS *)


