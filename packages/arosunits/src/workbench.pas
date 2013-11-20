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

unit workbench;

{$mode objfpc}

interface

uses
  exec, amigados, utility, intuition, agraphics;

type
  POldDrawerData = ^TOldDrawerData;
  TOldDrawerData = record
    dd_NewWindow: TNewWindow; // args to open window
    dd_CurrentX: Longint;     // current x coordinate of origin
    dd_CurrentY: Longint;     // current y coordinate of origin
  end;

const
  OLDDRAWERDATAFILESIZE  = SizeOf(TOldDrawerData); // the amount of DrawerData actually written to disk

type
  PDrawerData = ^TDrawerData;
  TDrawerData = record
    dd_NewWindow: TNewWindow; // args to open window
    dd_CurrentX: Longint;     // current x coordinate of origin
    dd_CurrentY: Longint;     // current y coordinate of origin
    dd_Flags: ULONG;          // flags for drawer (DDFLAGS_*)
    dd_ViewModes: Word;       // view mode for drawer (DDVM_*)
  end;

const
  DRAWERDATAFILESIZE  = sizeof(TDrawerData); // the amount of DrawerData actually written to disk
// Definitions for dd_ViewModes
  DDVM_BYDEFAULT = 0; // Default (inherit parent's view mode)
  DDVM_BYICON    = 1; // View as icons
  DDVM_BYNAME    = 2; // View as text, sorted by name
  DDVM_BYDATE    = 3; // View as text, sorted by date
  DDVM_BYSIZE    = 4; // View as text, sorted by size
  DDVM_BYTYPE    = 5; // View as text, sorted by type
// definitions for dd_Flags 
  DDFLAGS_SHOWDEFAULT = 0; // Default (show only icons)  
  DDFLAGS_SHOWICONS   = 1; // Show only icons
  DDFLAGS_SHOWALL     = 2; // Show all files

Type
  PDiskObject = ^TDiskObject;
  TDiskObject = record
    do_Magic: Word;         // a magic number at the start of the file
    do_Version: Word;       // a version number, so we can change it
    do_Gadget: TGadget;     // a copy of in core gadget
    do_Type: Word;          
    do_DefaultTool: STRPTR;
    do_ToolTypes: PPChar;   // List of ToolTypes
    do_CurrentX: Longint;   // Current X Position of Icon
    do_CurrentY: Longint;   // Current Y Position of Icon
    do_DrawerData: PDrawerData;
    do_ToolWindow: STRPTR;  // only applies to tools
    do_StackSize: Longint;  // only applies to tools
  end;

const
  WBDISK              = 1;
  WBDRAWER            = 2;
  WBTOOL              = 3;
  WBPROJECT           = 4;
  WBGARBAGE           = 5;
  WBDEVICE            = 6;
  WBKICK              = 7;
  WBAPPICON           = 8;

  WB_DISKVERSION      = 1;      // our current version number
  WB_DISKREVISION     = 1;      // our current revision number
  WB_DISKREVISIONMASK = $FF;    // We only use the lower 8 bits of Gadget.UserData for the revision #
  WB_DISKMAGIC        = $E310;  // a magic number, not easily impersonated

type
  PFreeList = ^TFreeList;
  TFreeList = record
    fl_NumFree: SmallInt;
    fl_MemList: TList;
  end;

// Icons
const
  GFLG_GADGBACKFILL   = $0001;
  NO_ICON_POSITION    = $80000000;
  
type
  PWBArg = ^TWBArg;
  TWBArg = record
    wa_Lock: BPTR;    // a lock descriptor
    wa_Name: PChar;   // a string relative to that lock
  end;

 WBArgList = array[1..100] of TWBArg; { Only 1..smNumArgs are valid }
 PWBArgList = ^WBArgList;
 
  PWBStartup = ^TWBStartup;
  TWBStartup = record
    sm_Message: TMessage;     // a standard message structure
    sm_Process: PMsgPort;     // the process descriptor for you
    sm_Segment: BPTR;         // a descriptor for your code
    sm_NumArgs: Longint;      // the number of elements in ArgList
    sm_ToolWindow: STRPTR;    // description of window
    sm_ArgList: PWBArgList;   // the arguments themselves
  end;

const

{ each message that comes into the WorkBenchPort must have a type field
 * in the preceeding short.  These are the defines for this type
 }

    MTYPE_PSTD          = 1;    { a "standard Potion" message }
    MTYPE_TOOLEXIT      = 2;    { exit message from our tools }
    MTYPE_DISKCHANGE    = 3;    { dos telling us of a disk change }
    MTYPE_TIMER         = 4;    { we got a timer tick }
    MTYPE_CLOSEDOWN     = 5;    { <unimplemented> }
    MTYPE_IOPROC        = 6;    { <unimplemented> }
    MTYPE_APPWINDOW     = 7;    {     msg from an app window }
    MTYPE_APPICON       = 8;    {     msg from an app icon }
    MTYPE_APPMENUITEM   = 9;    {     msg from an app menuitem }
    MTYPE_COPYEXIT      = 10;   {     exit msg from copy process }
    MTYPE_ICONPUT       = 11;   {     msg from PutDiskObject in icon.library }




Type
  PAppMessage = ^TAppMessage;
  TAppMessage = record
    am_Message: TMessage; // standard message structure
    am_Type: Word;        // message type (AMTYPE_*)
    am_UserData: IPTR;    // application specific
    am_ID: ULONG;         // application definable ID
    am_NumArgs: LongInt;  // # of elements in arglist
    am_ArgList: PWBArg;   // the arguements themselves
    am_Version: Word;     // will be AM_VERSION
    am_Class: Word;       // message class (AMCLASSICON_*)
    am_MouseX: SmallInt;  // mouse x position of event
    am_MouseY: SmallInt;  // mouse y position of event
    am_Seconds: ULONG;    // current system clock time
    am_Micros: ULONG;     // current system clock time
    am_Reserved: Array[0..7] of ULONG; // avoid recompilation
  END;

{* types of app messages *}
const
  { If you find am_Version >= AM_VERSION, you know this structure has
    at least the fields defined in this version of the include file}
  AM_VERSION   =   1;

// for am_Type
  AMTYPE_APPWINDOW   = 7; // app window message
  AMTYPE_APPICON     = 8; // app icon message
  AMTYPE_APPMENUITEM = 9; // app menu item message
{ Classes of AppIcon messages (V44)  }
  AMCLASSICON_Open        = 0; // The "Open" menu item was invoked, the icon got double-clicked or an icon got dropped on it.
  AMCLASSICON_Copy        = 1; // The "Copy" menu item was invoked
  AMCLASSICON_Rename      = 2; // The "Rename" menu item was invoked
  AMCLASSICON_Information = 3; // The "Information" menu item was invoked
  AMCLASSICON_Snapshot    = 4; // The "Snapshot" menu item was invoked
  AMCLASSICON_UnSnapshot  = 5; // The "UnSnapshot" menu item was invoked
  AMCLASSICON_LeaveOut    = 6; // The "Leave Out" menu item was invoked
  AMCLASSICON_PutAway     = 7; //The "Put Away" menu item was invoked 
  AMCLASSICON_Delete      = 8; // The "Delete" menu item was invoked
  AMCLASSICON_FormatDisk  = 9; // The "Format Disk" menu item was invoked
  AMCLASSICON_EmptyTrash  = 10; // The "Empty Trash" menu item was invoked
  AMCLASSICON_Selected    = 11; // The icon is now selected
  AMCLASSICON_Unselected  = 12; // The icon is now unselected

{ The message your AppIcon rendering hook gets invoked with. }
type
  PAppIconRenderMsg = ^TAppIconRenderMsg;
  TAppIconRenderMsg = record
    arm_RastPort: PRastPort; // RastPort to render into
    arm_Icon: PDiskObject;   // The icon to be rendered
    arm_Label: STRPTR;       // The icon label txt
    arm_Tags: PTagItem;      //Further tags to be passed on to DrawIconStateA().
    arm_Left: SmallInt;      // \ Rendering origin, not taking the
    arm_Top: SmallInt;       // / button border into account.
    arm_Width: SmallInt;     // \ Limit your rendering to
    arm_Height: SmallInt;    // / this area.
    arm_State: ULONG;        // IDS_SELECTED, IDS_NORMAL, etc.
  end;

{ The message your drop zone hook gets invoked with. }
  PAppWindowDropZoneMsg = ^TAppWindowDropZoneMsg;
  TAppWindowDropZoneMsg = record
    adzm_RastPort: PRastPort; // RastPort to render into.
    adzm_DropZoneBox: TIBox;  // Limit your rendering to this area.
    adzm_ID: ULONG;           // \ These come from straight
    adzm_UserData: ULONG;     // / from AddAppWindowDropZoneA().
    adzm_Action: LONG;        // See below for a list of actions. (ADZMACTION_*)
  end;

const
// Definitions for adzm_Action
  ADZMACTION_Enter = 0;
  ADZMACTION_Leave = 1;

{ The message your icon selection change hook is invoked with. }
type
  PIconSelectMsg = ^tIconSelectMsg;
  tIconSelectMsg = record
    ism_Length : ULONG;         // Size of this data structure (in bytes).
    ism_Drawer : BPTR;          // Lock on the drawer this object resides in, nil for Workbench backdrop (devices).
    ism_Name : STRPTR;          // Name of the object in question.
    ism_Type : UWORD;           // One of WBDISK, WBDRAWER, WBTOOL, WBPROJECT, WBGARBAGE, WBDEVICE, WBKICK or WBAPPICON.
    ism_Selected : BOOL;        //  True if currently selected, False otherwise.
    ism_Tags : PTagItem;        // Pointer to the list of tag items passed to ChangeWorkbenchSelectionA().
    ism_DrawerWindow : PWindow; // Pointer to the window attached to this icon, if the icon is a drawer-like object.
    ism_ParentWindow : PWindow; // Pointer to the window the icon resides in.
    ism_Left : WORD;            // Position and size of the icon; note that the    
    ism_Top : WORD;             // icon may not entirely reside within the visible
    ism_Width : WORD;           // bounds of the parent window.
    ism_Height : WORD;
  end;
{ These are the values your hook code can return.  }
const
  ISMACTION_Unselect = 0; // Unselect the icon
  ISMACTION_Select   = 1; // Select the icon
  ISMACTION_Ignore   = 2; // Do not change the selection state.
  ISMACTION_Stop     = 3; // Do not invoke the hook code again, leave the icon as it is.

{ The messages your copy hook is invoked with. }
type
  PCopyBeginMsg = ^TCopyBeginMsg;
  TCopyBeginMsg = record
    cbm_Length: ULONG;           // Size of this data structure in bytes.
    cbm_Action: LONG;            // Will be set to CPACTION_Begin (see below).
    cbm_SourceDrawer: BPTR;      // A lock on the source drawer.
    cbm_DestinationDrawer: BPTR; // A lock on the destination drawer.
  end;

  PCopyDataMsg = ^TCopyDataMsg;
  TCopyDataMsg = record
    cdm_Length: ULONG;           // Size of this data structure in bytes.
    cdm_Action: LONG;            // Will be set to CPACTION_Copy (see below).
    cdm_SourceLock: BPTR;        // A lock on the parent directory of the source file/drawer.
    cdm_SourceName: STRPTR;      // The name of the source file or drawer.
    cdm_DestinationLock: BPTR;   // A lock on the parent directory of the destination file/drawer.
    cdm_DestinationName: STRPTR; { The name of the destination file/drawer.
                                   This may or may not match the name of
                                   the source file/drawer in case the
                                   data is to be copied under a different
                                   name. For example, this is the case
                                   with the Workbench "Copy" command which
                                   creates duplicates of file/drawers by
                                   prefixing the duplicate's name with
                                   "Copy_XXX_of".}
    cdm_DestinationX: LONG;      { When the icon corresponding to the}
    cdm_DestinationY: LONG;      { destination is written to disk, this
                                   is the position (put into its
                                   DiskObject->do_CurrentX/DiskObject->do_CurrentY
                                   fields) it should be placed at.}
  end;

  PCopyEndMsg = ^TCopyEndMsg;
  TCopyEndMsg = record
    cem_Length: ULONG;   // Size of this data structure in bytes.
    cem_Action: LONG;    // Will be set to CPACTION_End (see below).
  end;

const
  CPACTION_Begin = 0;
  CPACTION_Copy  = 1; // This message arrives for each file or drawer to be copied.
  CPACTION_End   = 2; // This message arrives when all files/drawers have been copied. 

{ The messages your delete hook is invoked with. }
type
  PDeleteBeginMsg = ^TDeleteBeginMsg;
  TDeleteBeginMsg = record
    dbm_Length: ULONG; // Size of this data structure in bytes.
    dbm_Action: LONG;  // Will be set to either DLACTION_BeginDiscard or DLACTION_BeginEmptyTrash (see below).
  end;

  PDeleteDataMsg = ^TDeleteDataMsg;
  TDeleteDataMsg = record
    ddm_Length: ULONG; // Size of this data structure in bytes.
    ddm_Action: LONG;  // Will be set to either DLACTION_DeleteContents or DLACTION_DeleteObject (see below).
    ddm_Lock: BPTR;    // A Lock on the parent directory of the object whose contents or which itself should be deleted.
    ddm_Name: STRPTR;  // The name of the object whose contents or which itself should be deleted.
  end;

  PDeleteEndMsg = ^TDeleteEndMsg;
  TDeleteEndMsg = record
    dem_Length: ULONG;   // Size of this data structure in bytes.
    dem_Action: LONG;    // Will be set to DLACTION_End (see below).
  end;

const
  DLACTION_BeginDiscard    = 0; 
  DLACTION_BeginEmptyTrash = 1; {This indicates that the following delete
                                  operations are intended to empty the trashcan.} 
  DLACTION_DeleteContents  = 3; {This indicates that the object
                                  described by lock and name refers
                                  to a drawer; you should empty its
                                  contents but  DO NOT  delete the
                                  drawer itself!}
  DLACTION_DeleteObject    = 4; {This indicates that the object
                                  described by lock and name should
                                  be deleted; this could be a file
                                  or an empty drawer. } 
  DLACTION_End             = 5; {This indicates that the deletion process is finished. }

{ The message your setup/cleanup hook gets invoked with. }
type
  PSetupCleanupHookMsg = ^TSetupCleanupHookMsg;
  TSetupCleanupHookMsg = record
    schm_Length: ULONG;
    schm_State: LONG; // SCHMSTATE_* 
  end;

const
  SCHMSTATE_TryCleanup = 0; // Workbench will attempt to shut down now.
  SCHMSTATE_Cleanup = 1; // Workbench will really shut down now.
  SCHMSTATE_Setup = 2; // Workbench is operational again or could not be shut down.

{ The messages your text input hook is invoked with. }
type
  PTextInputMsg = ^TTextInputMsg;
  TTextInputMsg = record
    tim_Length: ULONG;  // Size of this data structure in bytes.
    tim_Action: LONG;   // One of the TIACTION_* values listed below.
    tim_Prompt: STRPTR; { The Workbench suggested result, depending on what
                          kind of input is requested (as indicated by the tim_Action member).}
  end;

const
  TIACTION_Rename        = 0; // A file or drawer is to be renamed.
  TIACTION_RelabelVolume = 1; // A volume is to be relabeled.
  TIACTION_NewDrawer     = 2; // A new drawer is to be created.
  TIACTION_Execute       = 3; // A program or script is to be executed.

{The following structures are private.  These are just stub structures for code compatibility...}
type
  PAppWindow = ^TAppWindow;
  TAppWindow = record
    aw_PRIVATE: Pointer;
  end;

  PAppWindowDropZone = ^TAppWindowDropZone;
  TAppWindowDropZone = record
    awdz_PRIVATE: Pointer;
  end;

  PAppIcon = ^TAppIcon;
  tAppIcon = record
    ai_PRIVATE: Pointer;
  end;

  pAppMenuItem = ^tAppMenuItem;
  tAppMenuItem = record
    ami_PRIVATE: Pointer;
  end;

// Start of Tags of workbench.library
const
  WBA_Dummy = TAG_USER + $A000;
{ Tags for use with AddAppIconA()  }  
  WBAPPICONA_SupportsOpen        = WBA_Dummy + 1; // AppIcon responds to the "Open" menu item (BOOL). 
  WBAPPICONA_SupportsCopy        = WBA_Dummy + 2; // AppIcon responds to the "Copy" menu item (BOOL). 
  WBAPPICONA_SupportsRename      = WBA_Dummy + 3; // AppIcon responds to the "Rename" menu item (BOOL). 
  WBAPPICONA_SupportsInformation = WBA_Dummy + 4; // AppIcon responds to the "Information" menu item (BOOL).
  WBAPPICONA_SupportsSnapshot    = WBA_Dummy + 5; // AppIcon responds to the "Snapshot" menu item (BOOL). 
  WBAPPICONA_SupportsUnSnapshot  = WBA_Dummy + 6; // AppIcon responds to the "UnSnapshot" menu item (BOOL). 
  WBAPPICONA_SupportsLeaveOut    = WBA_Dummy + 7; // AppIcon responds to the "LeaveOut" menu item (BOOL).
  WBAPPICONA_SupportsPutAway     = WBA_Dummy + 8; // AppIcon responds to the "PutAway" menu item (BOOL).
  WBAPPICONA_SupportsDelete      = WBA_Dummy + 9; // AppIcon responds to the "Delete" menu item (BOOL). 
  WBAPPICONA_SupportsFormatDisk  = WBA_Dummy + 10; // AppIcon responds to the "FormatDisk" menu item (BOOL).
  WBAPPICONA_SupportsEmptyTrash  = WBA_Dummy + 11; // AppIcon responds to the "EmptyTrash" menu item (BOOL).

  WBAPPICONA_PropagatePosition   = WBA_Dummy + 12; // AppIcon position should be propagated back to original DiskObject (BOOL).
  WBAPPICONA_RenderHook          = WBA_Dummy + 13; // Callback hook to be invoked when rendering this icon (PHook). 
  WBAPPICONA_NotifySelectState   = WBA_Dummy + 14; // AppIcon wants to be notified when its select state changes (BOOL).

{ Tags for use with AddAppMenuItemA()  }
  
  WBAPPMENUA_CommandKeyString    = WBA_Dummy + 15; // Command key string for this AppMenu (STRPTR).
  WBAPPMENUA_GetKey              = WBA_Dummy + 65; { Item to be added should get sub menu items attached to; make room for it,
                                                     then return the key to use later for attaching the items (PLongWord).}
  WBAPPMENUA_UseKey              = WBA_Dummy + 66; { This item should be attached to a sub menu; the key provided refers to
                                                     the sub menu it should be attached to (ULONG).}
  WBAPPMENUA_GetTitleKey         = WBA_Dummy + 77; { Item to be added is in fact a new menu title; make room for it, then
                                                     return the key to use later for attaching the items (ULONG  ).}
{ Tags for use with OpenWorkbenchObjectA()  }
  WBOPENA_ArgLock                = WBA_Dummy + 16; // Corresponds to the wa_Lock member of a struct WBArg  }  
  WBOPENA_ArgName                = WBA_Dummy + 17; // Corresponds to the wa_Name member of a struct WBArg  }
  WBOPENA_Show                   = WBA_Dummy + 75; { When opening a drawer, show all files or only icons?
                                                     This must be one out of DDFLAGS_SHOWICONS,
                                                     or DDFLAGS_SHOWALL; (UBYTE); (V45)}
  WBOPENA_ViewBy                 = WBA_Dummy + 76; { When opening a drawer, view the contents by icon, name,
                                                     date, size or type? This must be one out of DDVM_BYICON,
                                                     DDVM_BYNAME, DDVM_BYDATE, DDVM_BYSIZE or DDVM_BYTYPE; (UBYTE); (V45) }
{ Tags for use with WorkbenchControlA()  }
  
  WBCTRLA_IsOpen                 = WBA_Dummy + 18; // Check if the named drawer is currently open (PLongInt).
  WBCTRLA_DuplicateSearchPath    = WBA_Dummy + 19; // Create a duplicate of the Workbench private search path list (^BPTR).
  WBCTRLA_FreeSearchPath         = WBA_Dummy + 20; // Free the duplicated search path list (BPTR).
  WBCTRLA_GetDefaultStackSize    = WBA_Dummy + 21; // Get the default stack size for launching programs with (PLongWord).
  WBCTRLA_SetDefaultStackSize    = WBA_Dummy + 22; // Set the default stack size for launching programs with (ULONG).
  WBCTRLA_RedrawAppIcon          = WBA_Dummy + 23; // Cause an AppIcon to be redrawn (PAppIcon).
  WBCTRLA_GetProgramList         = WBA_Dummy + 24; // Get a list of currently running Workbench programs (PList).
  WBCTRLA_FreeProgramList        = WBA_Dummy + 25; // Release the list of currently running Workbench programs (PList).
  WBCTRLA_GetSelectedIconList    = WBA_Dummy + 36; // Get a list of currently selected icons (PList).
  WBCTRLA_FreeSelectedIconList   = WBA_Dummy + 37; // Release the list of currently selected icons (PList).
  WBCTRLA_GetOpenDrawerList      = WBA_Dummy + 38; // Get a list of currently open drawers (PList).
  WBCTRLA_FreeOpenDrawerList     = WBA_Dummy + 39; // Release the list of currently open icons (PList).
  WBCTRLA_GetHiddenDeviceList    = WBA_Dummy + 42; // Get the list of hidden devices (PList).
  WBCTRLA_FreeHiddenDeviceList   = WBA_Dummy + 43; // Release the list of hidden devices (PList).
  WBCTRLA_AddHiddenDeviceName    = WBA_Dummy + 44; // Add the name of a device which Workbench should never try to read a disk icon from (STRPTR).
  WBCTRLA_RemoveHiddenDeviceName = WBA_Dummy + 45; // Remove a name from list of hidden devices (STRPTR).
  WBCTRLA_GetTypeRestartTime     = WBA_Dummy + 47; { Get the number of seconds that have to pass before typing the next character
                                                     in a drawer window will restart with a new file name (PLongWord).}
  WBCTRLA_SetTypeRestartTime     = WBA_Dummy + 48; { Set the number of seconds that have to pass before typing the next character
                                                     in a drawer window will restart with a new file name (ULONG).}
  WBCTRLA_GetCopyHook            = WBA_Dummy + 69; { Obtain the hook that will be invoked when Workbench starts
                                                     to copy files and data (PHook); (V45)}
  WBCTRLA_SetCopyHook            = WBA_Dummy + 70; { Install the hook that will be invoked when Workbench starts
                                                     to copy files and data (PHook); (V45)}
  WBCTRLA_GetDeleteHook          = WBA_Dummy + 71; { Obtain the hook that will be invoked when Workbench discards
                                                     files and drawers or empties the trashcan (PHook); (V45).}
  WBCTRLA_SetDeleteHook          = WBA_Dummy + 72; { Install the hook that will be invoked when Workbench discards
                                                     files and drawers or empties the trashcan (PHook); (V45).}
  WBCTRLA_GetTextInputHook       = WBA_Dummy + 73; { Obtain the hook that will be invoked when Workbench requests
                                                     that the user enters text, such as when a file is to be renamed
                                                     or a new drawer is to be created (PHook); (V45)}
  WBCTRLA_SetTextInputHook       = WBA_Dummy + 74; { Install the hook that will be invoked when Workbench requests
                                                     that the user enters text, such as when a file is to be renamed
                                                     or a new drawer is to be created (PHook); (V45)}
  WBCTRLA_AddSetupCleanupHook    = WBA_Dummy + 78; { Add a hook that will be invoked when Workbench is about
                                                     to shut down (cleanup), and when Workbench has returned
                                                     to operational state (setup) (PHook); (V45)}
  WBCTRLA_RemSetupCleanupHook    = WBA_Dummy + 79; { Remove a hook that has been installed with the
                                                     WBCTRLA_AddSetupCleanupHook tag (PHook); (V45)}

{ Tags for use with AddAppWindowDropZoneA()  }  
  WBDZA_Left                     = WBA_Dummy + 26; // Zone left edge (WORD)
  WBDZA_RelRight                 = WBA_Dummy + 27; // Zone left edge, if relative to the right edge of the window (WORD)
  WBDZA_Top                      = WBA_Dummy + 28; // Zone top edge (WORD)
  WBDZA_RelBottom                = WBA_Dummy + 29; // Zone top edge, if relative to the bottom edge of the window (WORD)
  WBDZA_Width                    = WBA_Dummy + 30; // Zone width (WORD) 
  WBDZA_RelWidth                 = WBA_Dummy + 31; // Zone width, if relative to the window width (WORD)
  WBDZA_Height                   = WBA_Dummy + 32; // Zone height (WORD)
  WBDZA_RelHeight                = WBA_Dummy + 33; // Zone height, if relative to the window height (WORD)
  WBDZA_Box                      = WBA_Dummy + 34; // Zone position and size (PIBox).
  WBDZA_Hook                     = WBA_Dummy + 35; // Hook to invoke when the mouse enters or leave a drop zone (struct Hook  ).

  { Reserved tags; don't use!  }
  WBA_Reserved1 = WBA_Dummy + 40;
  WBA_Reserved2 = WBA_Dummy + 41;
  WBA_Reserved3 = WBA_Dummy + 46;
  WBA_Reserved4 = WBA_Dummy + 49;
  WBA_Reserved5 = WBA_Dummy + 50;
  WBA_Reserved6 = WBA_Dummy + 51;
  WBA_Reserved7 = WBA_Dummy + 52;
  WBA_Reserved8 = WBA_Dummy + 53;
  WBA_Reserved9 = WBA_Dummy + 54;
  WBA_Reserved10 = WBA_Dummy + 55;
  WBA_Reserved11 = WBA_Dummy + 56;
  WBA_Reserved12 = WBA_Dummy + 57;
  WBA_Reserved13 = WBA_Dummy + 58;
  WBA_Reserved14 = WBA_Dummy + 59;
  WBA_Reserved15 = WBA_Dummy + 60;
  WBA_Reserved16 = WBA_Dummy + 61;
  WBA_Reserved17 = WBA_Dummy + 62;
  WBA_Reserved18 = WBA_Dummy + 63;
  WBA_Reserved19 = WBA_Dummy + 64;

  WBA_LAST_TAG = WBA_Dummy + 64;

{ Parameters for the UpdateWorkbench() function. }
  UPDATEWB_ObjectRemoved = 0; // Object has been deleted.
  UPDATEWB_ObjectAdded   = 1; // Object is new or has changed.
  
// Aros Specifics
{$ifdef aros}
type
  TWBHM_Type = (WBHM_TYPE_SHOW,   // Open all windows
                WBHM_TYPE_HIDE,   // Close all windows
                WBHM_TYPE_OPEN,   // Open a drawer 
                WBHM_TYPE_UPDATE  // Update an object
               );

  PWBHandlerMessage = ^TWBHandlerMessage;
  TWBHandlerMessage = record
    wbhm_Message: TMessage;  
    wbhm_Type: TWBHM_Type;  // Type of message (see above)
    case smallint of
    0: (
      Open: record
        OpenName: STRPTR; // Name of drawer 
      end;  
    );
    1: (
      Update: record
        UpdateName: STRPTR;  // Name of object
        UpdateType: LongInt; // Type of object (WBDRAWER, WBPROJECT, ...)
      end;  
    );
  end;
  
const
  WBHM_SIZE = sizeof(TWBHandlerMessage);
{$endif}


const
  WORKBENCHNAME : PChar  = 'workbench.library';

var
  WorkbenchBase : PLibrary;

function AddAppIconA(ID: ULONG; UserData: ULONG; Text_: PChar; MsgPort: PMsgPort; Lock: BPTR; Diskobj: PDiskObject; const Taglist: pTagItem): PAppIcon; // 10
function AddAppMenuItemA(ID: ULONG; UserData: ULONG; Text_: PChar; MsgPort: PMsgPort; const TagList: pTagItem): PAppMenuItem; // 12
function AddAppWindowA(ID: ULONG; UserData: ULONG; Window: PWindow; MsgPort: PMsgPort; const TagList: PTagItem): PAppWindow; // 8
function RemoveAppIcon(AppIcon: PAppIcon): BOOL; // 11
function RemoveAppMenuItem(AppMenuItem: PAppMenuItem): BOOL; // 13
function RemoveAppWindow(AppWindow: PAppWindow): BOOL; // 9
function WBConfig(Unk1: ULONG; Unk2: ULONG): BOOL; // 14
function WBInfo(Lock: BPTR; Name: STRPTR; Screen: PScreen): BOOL; // 15

function AddAppWindowDropZoneA(Aw: PAppWindow; ID: ULONG; UserData: ULONG; const Tags: PTagItem): PAppWindowDropZone; // 19
function ChangeWorkbenchSelectionA(Name: STRPTR; Hook: PHook; const Tags: PTagItem): BOOL; // 21
function CloseWorkbenchObjectA(Name: STRPTR; const Tags: PTagItem): BOOL; // 17
function MakeWorkbenchObjectVisibleA(Name: STRPTR; const Tags: PTagItem): BOOL; //22
function OpenWorkbenchObjectA(Name: STRPTR; const Tags: PTagItem): BOOL; //16
function RemoveAppWindowDropZone(Aw: PAppWindow; DropZone: PAppWindowDropZone): BOOL; // 20
function WorkbenchControlA(Name: STRPTR; const Tags: PTagItem): BOOL; // 18

function UpdateWorkbench(const Name: STRPTR; Lock: BPTR; Action: LongInt): BOOL; // 5
function QuoteWorkbench(StringNum: ULONG): BOOL; // 6
function StartWorkbench(Flag: ULONG): BOOL; // 7

function RegisterWorkbench(MessagePort: PMsgPort): BOOL; // 23
function UnregisterWorkbench(MessagePort: PMsgPort): BOOL; // 24
function UpdateWorkbenchObjectA(Name: STRPTR; Type_: LongInt; const Tags: PTagItem): BOOL; // 25
function SendAppWindowMessage(Win: PWindow; NumFiles: ULONG; Files: PPChar; Class_: Word; MouseX: SmallInt; MouseY: SmallInt;
  Seconds: ULONG; Micros: ULONG): BOOL; // 26
function GetNextAppIcon(LastDiskObject: PDiskObject; Text_: PChar): PDiskObject; // 27


implementation

function AddAppIconA(ID: ULONG; UserData: ULONG; Text_: PChar; MsgPort: PMsgPort; Lock: BPTR; Diskobj: PDiskObject; const Taglist: pTagItem): PAppIcon; // 10
type
  TLocalCall = function(ID: ULONG; UserData: ULONG; Text_: PChar; MsgPort: PMsgPort; Lock: BPTR; Diskobj: PDiskObject; const Taglist: pTagItem; Base: Pointer): PAppIcon; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 10));
  AddAppIconA := Call(ID, UserData, Text_, MsgPort, Lock, Diskobj, Taglist, WorkbenchBase);
end;

function AddAppMenuItemA(ID: ULONG; UserData: ULONG; Text_: PChar; MsgPort: PMsgPort; const TagList: pTagItem): PAppMenuItem; // 12
type
  TLocalCall = function(ID: ULONG; UserData: ULONG; Text_: PChar; MsgPort: PMsgPort; const Taglist: pTagItem; Base: Pointer): PAppMenuItem; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 12));
  AddAppMenuItemA := Call(ID, UserData, Text_, MsgPort, Taglist, WorkbenchBase);
end;

function AddAppWindowA(ID: ULONG; UserData: ULONG; Window: PWindow; MsgPort: PMsgPort; const TagList: PTagItem): PAppWindow; // 8
type
  TLocalCall = function(ID: ULONG; UserData: ULONG; Window: PWindow; MsgPort: PMsgPort; const Taglist: pTagItem; Base: Pointer): PAppWindow; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 8));
  AddAppWindowA := Call(ID, UserData, Window, MsgPort, Taglist, WorkbenchBase);
end;

function RemoveAppIcon(AppIcon: PAppIcon): BOOL; // 11
type
  TLocalCall = function(AppIcon: PAppIcon; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 11));
  RemoveAppIcon := Call(AppIcon, WorkbenchBase);
end;

function RemoveAppMenuItem(AppMenuItem: PAppMenuItem): BOOL; // 13
type
  TLocalCall = function(AppMenuItem: PAppMenuItem; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 13));
  RemoveAppMenuItem := Call(AppMenuItem, WorkbenchBase);
end;

function RemoveAppWindow(AppWindow: PAppWindow): BOOL; // 9
type
  TLocalCall = function(AppWindow: PAppWindow; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 9));
  RemoveAppWindow := Call(AppWindow, WorkbenchBase);
end;

function WBConfig(Unk1: ULONG; Unk2: ULONG): BOOL; // 14
type
  TLocalCall = function(Unk1: ULONG; Unk2: ULONG; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 14));
  WBConfig := Call(Unk1, Unk2, WorkbenchBase);
end;

function WBInfo(Lock: BPTR; Name: STRPTR; Screen: PScreen): BOOL; // 15
type
  TLocalCall = function(Lock: BPTR; Name: STRPTR; Screen: PScreen; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 15));
  WBInfo := Call(Lock, Name, Screen, WorkbenchBase);
end;

function AddAppWindowDropZoneA(Aw: PAppWindow; ID: ULONG; UserData: ULONG; const Tags: PTagItem): PAppWindowDropZone; // 19
type
  TLocalCall = function(Aw: PAppWindow; ID: ULONG; UserData: ULONG; const Tags: PTagItem; Base: Pointer): PAppWindowDropZone; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 19));
  AddAppWindowDropZoneA := Call(Aw, ID, UserData, Tags, WorkbenchBase);
end;

function ChangeWorkbenchSelectionA(Name: STRPTR; Hook: PHook; const Tags: PTagItem): BOOL; // 21
type
  TLocalCall = function(Name: STRPTR; Hook: PHook; const Tags: PTagItem; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 21));
  ChangeWorkbenchSelectionA := Call(Name, Hook, Tags, WorkbenchBase);
end;

function CloseWorkbenchObjectA(Name: STRPTR; const Tags: PTagItem): BOOL; // 17
type
  TLocalCall = function(Name: STRPTR; const Tags: PTagItem; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 17));
  CloseWorkbenchObjectA := Call(Name, Tags, WorkbenchBase);
end;

function MakeWorkbenchObjectVisibleA(Name: STRPTR; const Tags: PTagItem): BOOL; //22
type
  TLocalCall = function(Name: STRPTR; const Tags: PTagItem; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 22));
  MakeWorkbenchObjectVisibleA := Call(Name, Tags, WorkbenchBase);
end;

function OpenWorkbenchObjectA(Name: STRPTR; const Tags: PTagItem): BOOL; //16
type
  TLocalCall = function(Name: STRPTR; const Tags: PTagItem; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 16));
  OpenWorkbenchObjectA := Call(Name, Tags, WorkbenchBase);
end;

function RemoveAppWindowDropZone(Aw: PAppWindow; DropZone: PAppWindowDropZone): BOOL; // 20
type
  TLocalCall = function(Aw: PAppWindow; DropZone: PAppWindowDropZone; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 20));
  RemoveAppWindowDropZone := Call(Aw, DropZone, WorkbenchBase);
end;

function WorkbenchControlA(Name: STRPTR; const Tags: PTagItem): BOOL; // 18
type
  TLocalCall = function(Name: STRPTR; const Tags: PTagItem; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 18));
  WorkbenchControlA := Call(Name, Tags, WorkbenchBase);
end;

function UpdateWorkbench(const Name: STRPTR; Lock: BPTR; Action: LongInt): BOOL; // 5
type
  TLocalCall = function(const Name: STRPTR; Lock: BPTR; Action: LongInt; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 5));
  UpdateWorkbench := Call(Name, Lock, Action, WorkbenchBase);
end;

function QuoteWorkbench(StringNum: ULONG): BOOL; // 6
type
  TLocalCall = function(StringNum: ULONG; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 6));
  QuoteWorkbench := Call(StringNum, WorkbenchBase);
end;

function StartWorkbench(Flag: ULONG): BOOL; // 7
type
  TLocalCall = function(Flag: ULONG; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 7));
  StartWorkbench := Call(Flag, WorkbenchBase);
end;

function RegisterWorkbench(MessagePort: PMsgPort): BOOL; // 23
type
  TLocalCall = function(MessagePort: PMsgPort; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 23));
  RegisterWorkbench := Call(MessagePort, WorkbenchBase);
end;

function UnregisterWorkbench(MessagePort: PMsgPort): BOOL; // 24
type
  TLocalCall = function(MessagePort: PMsgPort; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 24));
  UnregisterWorkbench := Call(MessagePort, WorkbenchBase);
end;

function UpdateWorkbenchObjectA(Name: STRPTR; Type_: LongInt; const Tags: PTagItem): BOOL; // 25
type
  TLocalCall = function(Name: STRPTR; Type_: LongInt; const Tags: PTagItem; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 25));
  UpdateWorkbenchObjectA := Call(Name, Type_, Tags, WorkbenchBase);
end;

function SendAppWindowMessage(Win: PWindow; NumFiles: ULONG; Files: PPChar; Class_: Word; MouseX: SmallInt; MouseY: SmallInt;
  Seconds: ULONG; Micros: ULONG): BOOL; // 26
type
  TLocalCall = function(Win: PWindow; NumFiles: ULONG; Files: PPChar; Class_: Word; MouseX: SmallInt; MouseY: SmallInt;
  Seconds: ULONG; Micros: ULONG; Base: Pointer): BOOL; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 26));
  SendAppWindowMessage := Call(Win, NumFiles, Files, Class_, MouseX, MouseY, Seconds, Micros, WorkbenchBase);
end;  
  
function GetNextAppIcon(LastDiskObject: PDiskObject; Text_: PChar): PDiskObject; // 27
type
  TLocalCall = function(LastDiskObject: PDiskObject; Text_: PChar; Base: Pointer): PDiskObject; cdecl;
var
  Call: TLocalCall;
begin
  Call := TLocalCall(GetLibAdress(WorkbenchBase, 27));
  GetNextAppIcon := Call(LastDiskObject, Text_, WorkbenchBase);
end;

initialization
  WorkbenchBase := OpenLibrary(WORKBENCHNAME,0);
finalization
  CloseLibrary(WorkbenchBase);

END. (* UNIT WB *)




