{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2007 by Florian Klaempfl
    member of the Free Pascal development team.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    Original copyright statement follows.

}
{$mode objfpc}
unit shlobj;

  interface

uses
      windows,activex,shellapi,commctrl;

Const 
   IID_IShellFolder    : TGUID ='{000214E6-0000-0000-C000-000000000046}';
   IID_IEnumList       : TGUID ='{000214F2-0000-0000-C000-000000000046}';
   IID_IAutoComplete   : TGUID ='{00bb2762-6a77-11d0-a535-00c04fd7d062}';
   IID_IAutoComplete2  : TGUID ='{EAC04BC0-3791-11d2-BB95-0060977B464C}';
   IID_IContextMenu    : TGUID ='{000214E4-0000-0000-c000-000000000046}';
   IID_IContextMenu2   : TGUID ='{000214f4-0000-0000-c000-000000000046}';
   IID_IContextMenu3   : TGUID ='{bcfce0a0-ec17-11d0-8d10-00a0c90f2719}';
   IID_IPersistFolder  : TGUID ='{000214EA-0000-0000-C000-000000000046}';
   IID_IPersistFolder2 : TGUID ='{1AC3D9F0-175C-11d1-95BE-00609797EA4F}';
   IID_IPersistIDListr : TGUID ='{1079acfc-29bd-11d3-8e0d-00c04f6837d5}';
   IID_IEnumExtraSearch: TGUID ='{0E700BE1-9DB6-11d1-A1CE-00C04FD75D13}';
   IID_IShellFolder2   : TGUID ='{93F2F68C-1D1B-11d3-A30E-00C04F79ABD1}';
   IID_IEXtractIconW   : TGUID ='{000214fa-0000-0000-c000-000000000046}';
   IID_IEXtractIconA   : TGUID ='{000214eb-0000-0000-c000-000000000046}';
   IID_IShellLinkA     : TGUID ='{000214EE-0000-0000-C000-000000000046}';
   CLSID_ShellLink     : TGUID ='{000214EE-0000-0000-C000-000000000046}';

Const
  SV2GV_CURRENTVIEW  = DWORD(-1);
  SV2GV_DEFAULTVIEW  = DWORD(-2);

  INTERNET_MAX_URL_LENGTH =  2083;
  MAX_COLUMN_NAME_LEN = 80;
  MAX_COLUMN_DESC_LEN = 128;


  CMF_NORMAL              = $00000000;
  CMF_DEFAULTONLY         = $00000001;
  CMF_VERBSONLY           = $00000002;
  CMF_EXPLORE             = $00000004;
  CMF_NOVERBS             = $00000008;
  CMF_CANRENAME           = $00000010;
  CMF_NODEFAULT           = $00000020;
  CMF_INCLUDESTATIC       = $00000040;
  CMF_EXTENDEDVERBS       = $00000100;      // rarely used verbs
  CMF_RESERVED            = $ffff0000;      // View specific
  GCS_VERBA        = $00000000;     // canonical verb
  GCS_HELPTEXTA    = $00000001;     // help text (for status bar)
  GCS_VALIDATEA    = $00000002;     // validate command exists
  GCS_VERBW        = $00000004;     // canonical verb (unicode)
  GCS_HELPTEXTW    = $00000005;     // help text (unicode version)
  GCS_VALIDATEW    = $00000006;     // validate command exists (unicode)
  GCS_UNICODE      = $00000004;     // for bit testing - Unicode string
  CMIC_MASK_SHIFT_DOWN    = $10000000;
  CMIC_MASK_CONTROL_DOWN  = $40000000;
  CMIC_MASK_PTINVOKE      = $20000000;
  GIL_OPENICON     = $0001;      // allows containers to specify an "open" look
  GIL_FORSHELL     = $0002;      // icon is to be displayed in a ShellFolder
  GIL_ASYNC        = $0020;      // this is an async extract, return E_PENDING
  GIL_DEFAULTICON  = $0040;      // get the default icon location if the final one takes too long to get
  GIL_FORSHORTCUT  = $0080;      // the icon is for a shortcut to the object
  GIL_SIMULATEDOC  = $0001;      // simulate this document icon for this
  GIL_PERINSTANCE  = $0002;      // icons from this class are per instance (each file has its own)
  GIL_PERCLASS     = $0004;      // icons from this class per class (shared for all files of this type)
  GIL_NOTFILENAME  = $0008;      // location is not a filename, must call ::ExtractIcon
  GIL_DONTCACHE    = $0010;      // this icon should not be cached
  ISIOI_ICONFILE            = $00000001;          // path is returned through pwszIconFile
  ISIOI_ICONINDEX           = $00000002;          // icon index in pwszIconFile is returned through pIndex
  OI_ASYNC = $FFFFEEEE;
  IDO_SHGIOI_SHARE  = $0FFFFFFF;
  IDO_SHGIOI_LINK   = $0FFFFFFE;
  IDO_SHGIOI_SLOWFILE = $0FFFFFFFD;
  NT_CONSOLE_PROPS_SIG = $A0000002;
  NT_FE_CONSOLE_PROPS_SIG = $A0000004;
  EXP_DARWIN_ID_SIG       = $A0000006;
  EXP_LOGO3_ID_SIG        = $A0000007;
  EXP_SPECIAL_FOLDER_SIG         = $A0000005;   // LPEXP_SPECIAL_FOLDER
  EXP_SZ_LINK_SIG                = $A0000001;   // LPEXP_SZ_LINK (target)
  EXP_SZ_ICON_SIG                = $A0000007;   // LPEXP_SZ_LINK (icon)
  FO_MOVE           = $0001;
  FO_COPY           = $0002;
  FO_DELETE         = $0003;
  FO_RENAME         = $0004;
  FOF_MULTIDESTFILES         = $0001;
  FOF_CONFIRMMOUSE           = $0002;
  FOF_SILENT                 = $0004;  // don't create progress/report
  FOF_RENAMEONCOLLISION      = $0008;
  FOF_NOCONFIRMATION         = $0010;  // Don't prompt the user.
  FOF_WANTMAPPINGHANDLE      = $0020;  // Fill in SHFILEOPSTRUCT.hNameMappings
  FOF_ALLOWUNDO              = $0040;
  FOF_FILESONLY              = $0080;  // on *.*, do only files
  FOF_SIMPLEPROGRESS         = $0100;  // means don't show names of files
  FOF_NOCONFIRMMKDIR         = $0200;  // don't confirm making any needed dirs
  FOF_NOERRORUI              = $0400;  // don't put up error UI
  FOF_NOCOPYSECURITYATTRIBS  = $0800;  // dont copy NT file Security Attributes
  FOF_NORECURSION            = $1000;  // don't recurse into directories.
  FOF_NO_CONNECTED_ELEMENTS  = $2000;  // don't operate on connected file elements.
  FOF_WANTNUKEWARNING        = $4000;  // during delete operation, warn if nuking instead of recycling (partially overrides FOF_NOCONFIRMATION)
  FOF_NORECURSEREPARSE       = $8000;  // treat reparse points as objects, not containers
  PO_DELETE                  = $0013;  // printer is being deleted
  PO_RENAME                  = $0014;  // printer is being renamed
  PO_PORTCHANGE              = $0020;  // port this printer connected to is being changed
  PO_REN_PORT                = $0034;  // PO_RENAME and PO_PORTCHANGE at same time.
  FVSIF_RECT                 = $00000001;      // The rect variable has valid data.
  FVSIF_PINNED               = $00000002;      // We should Initialize pinned
  FVSIF_NEWFAILED            = $08000000;      // The new file passed back failed
  FVSIF_NEWFILE              = $80000000;      // A new file to view has been returned
  FVSIF_CANVIEWIT            = $40000000;      // The viewer can view it.
  FCIDM_SHVIEWFIRST          = $0000;
  FCIDM_SHVIEWLAST           = $7fff;
  FCIDM_BROWSERFIRST         = $a000;
  FCIDM_BROWSERLAST          = $bf00;
  FCIDM_GLOBALFIRST          = $8000;
  FCIDM_GLOBALLAST           = $9fff;
  FCIDM_MENU_FILE            = (FCIDM_GLOBALFIRST + $0000);
  FCIDM_MENU_EDIT            = (FCIDM_GLOBALFIRST + $0040);
  FCIDM_MENU_VIEW            = (FCIDM_GLOBALFIRST + $0080);
  FCIDM_MENU_VIEW_SEP_OPTIONS= (FCIDM_GLOBALFIRST + $0081);
  FCIDM_MENU_TOOLS           = (FCIDM_GLOBALFIRST + $00c0); // for Win9x compat
  FCIDM_MENU_TOOLS_SEP_GOTO  = (FCIDM_GLOBALFIRST + $00c1); // for Win9x compat
  FCIDM_MENU_HELP            = (FCIDM_GLOBALFIRST + $0100);
  FCIDM_MENU_FIND            = (FCIDM_GLOBALFIRST + $0140);
  FCIDM_MENU_EXPLORE         = (FCIDM_GLOBALFIRST + $0150);
  FCIDM_MENU_FAVORITES       = (FCIDM_GLOBALFIRST + $0170);
  CDBOSC_SETFOCUS            = $00000000;
  CDBOSC_KILLFOCUS           = $00000001;
  CDBOSC_SELCHANGE           = $00000002;
  CDBOSC_RENAME              = $00000003;
  CDBOSC_STATECHANGE         = $00000004;
  CDB2N_CONTEXTMENU_DONE     = $00000001;
  CDB2N_CONTEXTMENU_START    = $00000002;
  CDB2GVF_SHOWALLFILES       = $00000001;
  CSIDL_DESKTOP                   = $0000;        // <desktop>
  CSIDL_INTERNET                  = $0001;        // Internet Explorer (icon on desktop)
  CSIDL_PROGRAMS                  = $0002;        // Start Menu\Programs
  CSIDL_CONTROLS                  = $0003;        // My Computer\Control Panel
  CSIDL_PRINTERS                  = $0004;        // My Computer\Printers
  CSIDL_PERSONAL                  = $0005;        // My Documents
  CSIDL_FAVORITES                 = $0006;        // <user name>\Favorites
  CSIDL_STARTUP                   = $0007;        // Start Menu\Programs\Startup
  CSIDL_RECENT                    = $0008;        // <user name>\Recent
  CSIDL_SENDTO                    = $0009;        // <user name>\SendTo
  CSIDL_BITBUCKET                 = $000a;        // <desktop>\Recycle Bin
  CSIDL_STARTMENU                 = $000b;        // <user name>\Start Menu
  CSIDL_MYDOCUMENTS               = $000c;        // logical "My Documents" desktop icon
  CSIDL_MYMUSIC                   = $000d;        // "My Music" folder
  CSIDL_MYVIDEO                   = $000e;        // "My Videos" folder
  CSIDL_DESKTOPDIRECTORY          = $0010;        // <user name>\Desktop
  CSIDL_DRIVES                    = $0011;        // My Computer
  CSIDL_NETWORK                   = $0012;        // Network Neighborhood (My Network Places)
  CSIDL_NETHOOD                   = $0013;        // <user name>\nethood
  CSIDL_FONTS                     = $0014;        // windows\fonts
  CSIDL_TEMPLATES                 = $0015;
  CSIDL_COMMON_STARTMENU          = $0016;        // All Users\Start Menu
  CSIDL_COMMON_PROGRAMS           = $0017;        // All Users\Start Menu\Programs
  CSIDL_COMMON_STARTUP            = $0018;        // All Users\Startup
  CSIDL_COMMON_DESKTOPDIRECTORY   = $0019;        // All Users\Desktop
  CSIDL_APPDATA                   = $001a;        // <user name>\Application Data
  CSIDL_PRINTHOOD                 = $001b;        // <user name>\PrintHood
  CSIDL_LOCAL_APPDATA             = $001c;        // <user name>\Local Settings\Applicaiton Data (non roaming)
  CSIDL_ALTSTARTUP                = $001d;        // non localized startup
  CSIDL_COMMON_ALTSTARTUP         = $001e;        // non localized common startup
  CSIDL_COMMON_FAVORITES          = $001f;
  CSIDL_INTERNET_CACHE            = $0020;
  CSIDL_COOKIES                   = $0021;
  CSIDL_HISTORY                   = $0022;
  CSIDL_COMMON_APPDATA            = $0023;        // All Users\Application Data
  CSIDL_WINDOWS                   = $0024;        // GetWindowsDirectory()
  CSIDL_SYSTEM                    = $0025;        // GetSystemDirectory()
  CSIDL_PROGRAM_FILES             = $0026;        // C:\Program Files
  CSIDL_MYPICTURES                = $0027;        // C:\Program Files\My Pictures
  CSIDL_PROFILE                   = $0028;        // USERPROFILE
  CSIDL_SYSTEMX86                 = $0029;        // x86 system directory on RISC
  CSIDL_PROGRAM_FILESX86          = $002a;        // x86 C:\Program Files on RISC
  CSIDL_PROGRAM_FILES_COMMON      = $002b;        // C:\Program Files\Common
  CSIDL_PROGRAM_FILES_COMMONX86   = $002c;        // x86 Program Files\Common on RISC
  CSIDL_COMMON_TEMPLATES          = $002d;        // All Users\Templates
  CSIDL_COMMON_DOCUMENTS          = $002e;        // All Users\Documents
  CSIDL_COMMON_ADMINTOOLS         = $002f;        // All Users\Start Menu\Programs\Administrative Tools
  CSIDL_ADMINTOOLS                = $0030;        // <user name>\Start Menu\Programs\Administrative Tools
  CSIDL_CONNECTIONS               = $0031;        // Network and Dial-up Connections
  CSIDL_COMMON_MUSIC              = $0035;        // All Users\My Music
  CSIDL_COMMON_PICTURES           = $0036;        // All Users\My Pictures
  CSIDL_COMMON_VIDEO              = $0037;        // All Users\My Video
  CSIDL_RESOURCES                 = $0038;        // Resource Direcotry
  CSIDL_RESOURCES_LOCALIZED       = $0039;        // Localized Resource Direcotry
  CSIDL_COMMON_OEM_LINKS          = $003a;        // Links to All Users OEM specific apps
  CSIDL_CDBURN_AREA               = $003b;        // USERPROFILE\Local Settings\Application Data\Microsoft\CD Burning
  CSIDL_COMPUTERSNEARME           = $003d;        // Computers Near Me (computered from Workgroup membership)
  CSIDL_FLAG_CREATE               = $8000;        // combine with CSIDL_ value to force folder creation in SHGetFolderPath()
  CSIDL_FLAG_DONT_VERIFY          = $4000;        // combine with CSIDL_ value to return an unverified folder path
  CSIDL_FLAG_NO_ALIAS             = $1000;        // combine with CSIDL_ value to insure non-alias versions of the pidl
  CSIDL_FLAG_PER_USER_INIT        = $0800;        // combine with CSIDL_ value to indicate per-user init (eg. upgrade)
  CSIDL_FLAG_MASK                 = $FF00;        // mask for all possible flag values
  FCS_READ                        = $00000001;
  FCS_FORCEWRITE                  = $00000002;
  FCSM_VIEWID                     = $00000001;
  FCSM_WEBVIEWTEMPLATE            = $00000002;
  FCSM_INFOTIP                    = $00000004;
  FCSM_CLSID                      = $00000008;
  FCSM_ICONFILE                   = $00000010;
  FCSM_LOGO                       = $00000020;
  FCSM_FLAGS                      = $00000040;
  BIF_RETURNONLYFSDIRS            = $0001;  // For finding a folder to start document searching
  BIF_DONTGOBELOWDOMAIN           = $0002;  // For starting the Find Computer
  BIF_STATUSTEXT                  = $0004;   // Top of the dialog has 2 lines of text for BROWSEINFO.lpszTitle and one line if
  BIF_RETURNFSANCESTORS           = $0008;
  BIF_EDITBOX                     = $0010;   // Add an editbox to the dialog
  BIF_VALIDATE                    = $0020;   // insist on valid result (or CANCEL)
  BIF_NEWDIALOGSTYLE              = $0040;   // Use the new dialog layout with the ability to resize
  BIF_BROWSEINCLUDEURLS           = $0080;   // Allow URLs to be displayed or entered. (Requires BIF_USENEWUI)
  BIF_UAHINT                      = $0100;   // Add a UA hint to the dialog, in place of the edit box. May not be combined with BIF_EDITBOX
  BIF_NONEWFOLDERBUTTON           = $0200;   // Do not add the "New Folder" button to the dialog.  Only applicable with BIF_NEWDIALOGSTYLE.
  BIF_NOTRANSLATETARGETS          = $0400;   // don't traverse target as shortcut
  BIF_BROWSEFORCOMPUTER           = $1000;  // Browsing for Computers.
  BIF_BROWSEFORPRINTER            = $2000;  // Browsing for Printers
  BIF_BROWSEINCLUDEFILES          = $4000;  // Browsing for Everything
  BIF_SHAREABLE                   = $8000;  // sharable resources displayed (remote shares, requires BIF_USENEWUI)
  PROGDLG_NORMAL                  = $00000000;      // default normal progress dlg behavior
  PROGDLG_MODAL                   = $00000001;      // the dialog is modal to its hwndParent (default is modeless)
  PROGDLG_AUTOTIME                = $00000002;      // automatically updates the "Line3" text with the "time remaining" (you cant call SetLine3 if you passs this!)
  PROGDLG_NOTIME                  = $00000004;      // we dont show the "time remaining" if this is set. We need this if dwTotal < dwCompleted for sparse files
  PROGDLG_NOMINIMIZE              = $00000008;      // Do not have a minimize button in the caption bar.
  PROGDLG_NOPROGRESSBAR           = $00000010;      // Don't display the progress bar
  PDTIMER_RESET                   = $00000001;       // Reset the timer so the progress will be calculated from now until the first ::SetProgress() is called so
  DWFRF_NORMAL                    = $0000;
  DWFRF_DELETECONFIGDATA          = $0001;
  DWFAF_HIDDEN                    = $0001;   // add hidden
  ITSSFLAG_COMPLETE_ON_DESTROY        = $0000;
  ITSSFLAG_KILL_ON_DESTROY            = $0001;
  ITSSFLAG_SUPPORTS_TERMINATE         = $0002;
  ITSSFLAG_FLAGS_MASK                 = $0003;
  ITSSFLAG_THREAD_TERMINATE_TIMEOUT   = $0010;
  ITSSFLAG_THREAD_POOL_TIMEOUT        = $0020;
  ITSAT_DEFAULT_LPARAM        = $ffffffff;
  ITSAT_DEFAULT_PRIORITY      = $10000000;
  ITSAT_MAX_PRIORITY          = $7fffffff;
  ITSAT_MIN_PRIORITY          = $00000000;
  ITSSFLAG_TASK_PLACEINFRONT = $00000001;
  ITSSFLAG_TASK_PLACEINBACK  = $00000002;
  SHIMSTCAPFLAG_LOCKABLE    = $0001;       // does the store require/support locking
  SHIMSTCAPFLAG_PURGEABLE   = $0002;       // does the store require dead items purging externally ?
  ISFB_MASK_STATE           = $00000001; // TRUE if dwStateMask and dwState is valid
  ISFB_MASK_BKCOLOR         = $00000002; // TRUE if crBkgnd field is valid
  ISFB_MASK_VIEWMODE        = $00000004; // TRUE if wViewMode field is valid
  ISFB_MASK_SHELLFOLDER     = $00000008;
  ISFB_MASK_IDLIST          = $00000010;
  ISFB_MASK_COLORS          = $00000020; // TRUE if crXXXX fields are valid (except bkgnd)
  ISFB_STATE_DEFAULT        = $00000000;
  ISFB_STATE_DEBOSSED       = $00000001;
  ISFB_STATE_ALLOWRENAME    = $00000002;
  ISFB_STATE_NOSHOWTEXT     = $00000004; // TRUE if _fNoShowText
  ISFB_STATE_CHANNELBAR     = $00000010; // TRUE if we want NavigateTarget support
  ISFB_STATE_QLINKSMODE     = $00000020; // TRUE if we want to turn off drag & drop onto content items
  ISFB_STATE_FULLOPEN       = $00000040; // TRUE if band should maximize when opened
  ISFB_STATE_NONAMESORT     = $00000080; // TRUE if band should _not_ sort icons by name
  ISFB_STATE_BTNMINSIZE     = $00000100; // TRUE if band should report min thickness of button
  ISFBVIEWMODE_SMALLICONS   = $0001;
  ISFBVIEWMODE_LARGEICONS   = $0002;
  ISFBVIEWMODE_LOGOS        = $0003;
  COMPONENT_TOP 	      = $3fffffff;  // izOrder value meaning component is at the top
  IS_NORMAL                 = $00000001;
  IS_FULLSCREEN             = $00000002;
  IS_SPLIT                  = $00000004;
  IS_VALIDSTATEBITS         = dword(IS_NORMAL or IS_SPLIT or IS_FULLSCREEN or $80000000 or $40000000);  // All of the currently defined IS_* bits.
  AD_APPLY_SAVE             = $00000001;
  AD_APPLY_HTMLGEN          = $00000002;
  AD_APPLY_REFRESH          = $00000004;
  AD_APPLY_FORCE            = $00000008;
  AD_APPLY_BUFFERED_REFRESH = $00000010;
  AD_APPLY_DYNAMICREFRESH   = $00000020;
  COMP_ELEM_TYPE          = $00000001;
  COMP_ELEM_CHECKED       = $00000002;
  COMP_ELEM_DIRTY         = $00000004;
  COMP_ELEM_NOSCROLL      = $00000008;
  COMP_ELEM_POS_LEFT      = $00000010;
  COMP_ELEM_POS_TOP       = $00000020;
  COMP_ELEM_SIZE_WIDTH    = $00000040;
  COMP_ELEM_SIZE_HEIGHT   = $00000080;
  COMP_ELEM_POS_ZINDEX    = $00000100;
  COMP_ELEM_SOURCE        = $00000200;
  COMP_ELEM_FRIENDLYNAME  = $00000400;
  COMP_ELEM_SUBSCRIBEDURL = $00000800;
  COMP_ELEM_ORIGINAL_CSI  = $00001000;
  COMP_ELEM_RESTORED_CSI  = $00002000;
  COMP_ELEM_CURITEMSTATE  = $00004000;
  ADDURL_SILENT           = $0001;
  COMPONENT_DEFAULT_LEFT    = ($FFFF);
  COMPONENT_DEFAULT_TOP     = ($FFFF);
  SSM_CLEAR   = $0000;
  SSM_SET     = $0001;
  SSM_REFRESH = $0002;
  SSM_UPDATE  = $0004;
  SCHEME_DISPLAY          = $0001;
  SCHEME_EDIT             = $0002;
  SCHEME_LOCAL            = $0004;
  SCHEME_GLOBAL           = $0008;
  SCHEME_REFRESH          = $0010;
  SCHEME_UPDATE           = $0020;
  SCHEME_DONOTUSE         = $0040; // used to be SCHEME_ENUMERATE; no longer supported
  SCHEME_CREATE           = $0080;
  GADOF_DIRTY             = $00000001;
  SHCDF_UPDATEITEM        = $00000001;      // this flag is a hint that the file has changed since the last call to GetItemData
  SHCNE_RENAMEITEM          = DWord($00000001);
  SHCNE_CREATE              = DWord($00000002);
  SHCNE_DELETE              = DWord($00000004);
  SHCNE_MKDIR               = DWord($00000008);
  SHCNE_RMDIR               = DWord($00000010);
  SHCNE_MEDIAINSERTED       = DWord($00000020);
  SHCNE_MEDIAREMOVED        = DWord($00000040);
  SHCNE_DRIVEREMOVED        = DWord($00000080);
  SHCNE_DRIVEADD            = DWord($00000100);
  SHCNE_NETSHARE            = DWord($00000200);
  SHCNE_NETUNSHARE          = DWord($00000400);
  SHCNE_ATTRIBUTES          = DWord($00000800);
  SHCNE_UPDATEDIR           = DWord($00001000);
  SHCNE_UPDATEITEM          = DWord($00002000);
  SHCNE_SERVERDISCONNECT    = DWord($00004000);
  SHCNE_UPDATEIMAGE         = DWord($00008000);
  SHCNE_DRIVEADDGUI         = DWord($00010000);
  SHCNE_RENAMEFOLDER        = DWord($00020000);
  SHCNE_FREESPACE           = DWord($00040000);
  SHCNE_EXTENDED_EVENT      = DWord($04000000);
  SHCNE_ASSOCCHANGED        = DWord($08000000);
  SHCNE_DISKEVENTS          = DWord($0002381F);
  SHCNE_GLOBALEVENTS        = DWord($0C0581E0); // Events that dont match pidls first
  SHCNE_ALLEVENTS           = DWord($7FFFFFFF);
  SHCNE_INTERRUPT           = DWord($80000000); // The presence of this flag indicates
  SHCNF_IDLIST      = $0000;        // LPITEMIDLIST
  SHCNF_PATHA       = $0001;        // path name
  SHCNF_PRINTERA    = $0002;        // printer friendly name
  SHCNF_DWORD       = $0003;        // DWORD
  SHCNF_PATHW       = $0005;        // path name
  SHCNF_PRINTERW    = $0006;        // printer friendly name
  SHCNF_TYPE        = $00FF;  
  SHCNF_FLUSH       = $1000;  
  SHCNF_FLUSHNOWAIT = $2000;  
  QITIPF_DEFAULT          = $00000000;
  QITIPF_USENAME          = $00000001;
  QITIPF_LINKNOTARGET     = $00000002;
  QITIPF_LINKUSETARGET    = $00000004;
  QITIPF_USESLOWTIP       = $00000008;  // Flag says it's OK to take a long time generating tip
  QIF_CACHED          = $00000001;
  QIF_DONTEXPANDFOLDER= $00000002;
  SHARD_PIDL          = DWord($00000001);
  SHARD_PATHA         = DWord($00000002);
  SHARD_PATHW         = DWord($00000003);
  PRF_VERIFYEXISTS            = $0001;
  PRF_TRYPROGRAMEXTENSIONS    = ($0002 or PRF_VERIFYEXISTS);
  PRF_FIRSTDIRDEF             = $0004;
  PRF_DONTFINDLNK             = $0008;      // if PRF_TRYPROGRAMEXTENSIONS is specified
  PCS_FATAL           = $80000000;
  PCS_REPLACEDCHAR    = $00000001;
  PCS_REMOVEDCHAR     = $00000002;
  PCS_TRUNCATED       = $00000004;
  PCS_PATHTOOLONG     = $00000008;  // Always combined with FATA);
  MM_ADDSEPARATOR     = dword($00000001);
  MM_SUBMENUSHAVEIDS  = dword($00000002);
  MM_DONTREMOVESEPS   = dword($00000004);
  SHOP_PRINTERNAME    = $00000001;  // lpObject points to a printer friendly name
  SHOP_FILEPATH       = $00000002;  // lpObject points to a fully qualified path+file name
  SHOP_VOLUMEGUID     = $00000004;  // lpObject points to a Volume GUID
  SHFMT_ID_DEFAULT    = $FFFF;
  SHFMT_OPT_FULL      = $0001;
  SHFMT_OPT_SYSONLY   = $0002;
  SHFMT_ERROR         = dword($FFFFFFFF);     // Error on last format, drive may be formatable
  SHFMT_CANCEL        = dword($FFFFFFFE);     // Last format was canceled
  SHFMT_NOFORMAT      = dword($FFFFFFFD);     // Drive is not formatable
  PPCF_ADDQUOTES              = $00000001;        // return a quoted name if required
  PPCF_ADDARGUMENTS           = $00000003;        // appends arguments (and wraps in quotes if required)
  PPCF_NODIRECTORIES          = $00000010;        // don't match to directories
  PPCF_FORCEQUALIFY           = $00000040;        // qualify even non-relative names
  PPCF_LONGESTPOSSIBLE        = $00000080;        // always find the longest possible name
  VALIDATEUNC_NOUI            = $0002;          // don't bring up UI
  VALIDATEUNC_CONNECT         = $0001;          // connect a drive letter
  VALIDATEUNC_PRINT           = $0004;          // validate as print share instead of disk share
  VALIDATEUNC_VALID           = $0007;          // valid flags
  OPENPROPS_NONE              = $0000;
  OPENPROPS_INHIBITPIF        = $8000;
  GETPROPS_NONE               = $0000;
  SETPROPS_NONE               = $0000;
  CLOSEPROPS_NONE             = $0000;	
  CLOSEPROPS_DISCARD          = $0001;		
  TBIF_DEFAULT                = $00000000;
  TBIF_INTERNETBAR  	        = $00010000;
  TBIF_STANDARDTOOLBAR        = $00020000;
  TBIF_NOTOOLBAR              = $00030000;
  SFVM_REARRANGE              = $00000001;
  SFVM_ADDOBJECT              = $00000003;
  SFVM_REMOVEOBJECT           = $00000006;
  SFVM_UPDATEOBJECT           = $00000007;
  SFVM_GETSELECTEDOBJECTS     = $00000009;
  SFVM_SETITEMPOS             = $0000000e;
  SFVM_SETCLIPBOARD           = $00000010;
  SFVM_SETPOINTS              = $00000017;
  PIDISF_RECENTLYCHANGED      = $00000001;
  PIDISF_CACHEDSTICKY         = $00000002;
  PIDISF_CACHEIMAGES          = $00000010;
  PIDISF_FOLLOWALLLINKS       = $00000020;
  SSF_SHOWALLOBJECTS          = $00000001;
  SSF_SHOWEXTENSIONS          = $00000002;
  SSF_HIDDENFILEEXTS          = $00000004;
  SSF_SERVERADMINUI           = $00000004;
  SSF_SHOWCOMPCOLOR           = $00000008;
  SSF_SORTCOLUMNS             = $00000010;
  SSF_SHOWSYSFILES            = $00000020;
  SSF_DOUBLECLICKINWEBVIEW    = $00000080;
  SSF_SHOWATTRIBCOL           = $00000100;
  SSF_DESKTOPHTML             = $00000200;
  SSF_WIN95CLASSIC            = $00000400;
  SSF_DONTPRETTYPATH          = $00000800;
  SSF_SHOWINFOTIP             = $00002000;
  SSF_MAPNETDRVBUTTON         = $00001000;
  SSF_NOCONFIRMRECYCLE        = $00008000;
  SSF_HIDEICONS               = $00004000;
  SSF_FILTER                  = $00010000;
  SSF_WEBVIEW                 = $00020000;
  SSF_SHOWSUPERHIDDEN         = $00040000;
  SSF_SEPPROCESS              = $00080000;
  SSF_NONETCRAWLING           = $00100000;
  SSF_STARTPANELON            = $00200000;
  SSF_SHOWSTARTPAGE           = $00400000;
  SHPPFW_NONE                 = $00000000;
  SHPPFW_DIRCREATE            = $00000001;              // Create the directory if it doesn't exist without asking the user.
  SHPPFW_ASKDIRCREATE         = $00000002;              // Create the directory if it doesn't exist after asking the user.
  SHPPFW_IGNOREFILENAME       = $00000004;              // Ignore the last item in pszPath because it's a file.  Example: pszPath="C:\DirA\DirB", only use "C:\DirA".
  SHPPFW_NOWRITECHECK         = $00000008;              // Caller only needs to read from the drive, so don't check if it's READ ONLY.
  SHPPFW_MEDIACHECKONLY       = $00000010;              // do the retrys on the media (or net path), return errors if the file can't be found
  PUIFNF_DEFAULT          = $00000000;
  PUIFNF_MNEMONIC         = $00000001;   // include mnemonic in display name
  PUIF_DEFAULT            = $00000000;
  PUIF_RIGHTALIGN         = $00000001;   // this property should be right alligned
  PUIF_NOLABELININFOTIP   = $00000002;   // this property should not display a label in the infotip
  PUIFFDF_DEFAULT         = $00000000;
  PUIFFDF_RIGHTTOLEFT     = $00000001;   // BIDI support, right to left caller
  PUIFFDF_SHORTFORMAT     = $00000002;   // short format version of string
  PUIFFDF_NOTIME          = $00000004;   // truncate time to days, not hours/mins/sec
  PUIFFDF_FRIENDLYDATE    = $00000008;   // "Today", "Yesterday", etc
  PUIFFDF_NOUNITS         = $00000010;   // don't do "KB", "MB", "KHz"
  CATINFO_NORMAL          = $00000000;   // Apply default properties to this category
  CATINFO_COLLAPSED       = $00000001;   // This category should appear collapsed. useful for the "None" category. 
  CATINFO_HIDDEN          = $00000002;   // This category should follow the "Hidden" files setting for being displayed
  CATSORT_DEFAULT         = $00000000;   // Default Sort order
  CATSORT_NAME            = $00000001;   // Sort by name
  SLR_NO_UI               = $0001;   // don't post any UI durring the resolve operation, not msgs are pumped
  SLR_ANY_MATCH           = $0002;   // no longer used
  SLR_UPDATE              = $0004;   // save the link back to it's file if the track made it dirty
  SLR_NOUPDATE            = $0008;
  SLR_NOSEARCH            = $0010;   // don't execute the search heuristics
  SLR_NOTRACK             = $0020;   // don't use NT5 object ID to track the link
  SLR_NOLINKINFO          = $0040;   // don't use the net and volume relative info
  SLR_INVOKE_MSI          = $0080;   // if we have a darwin link, then call msi to fault in the applicaion
  SLR_NO_UI_WITH_MSG_PUMP = $0101;   // SLR_NO_UI + requires an enable modeless site or HWND
  SLGP_SHORTPATH          = $0001;
  SLGP_UNCPRIORITY        = $0002;
  SLGP_RAWPATH            = $0004;
  SPINITF_NORMAL          = $00000000;      // default normal progress behavior
  SPINITF_MODAL           = $00000001;      // call punkSite->EnableModeless() or EnableWindow()
  SPINITF_NOMINIMIZE      = $00000008;      // Do not have a minimize button in the caption bar.
  ARCONTENT_AUTORUNINF    = $00000002; // That's the one we have today, and always had 
  ARCONTENT_AUDIOCD       = $00000004; // Audio CD (not MP3 and the like, the stuff you buy at the store) 
  ARCONTENT_DVDMOVIE      = $00000008; // DVD Movie (not MPEGs, the stuff you buy at the store) 
  ARCONTENT_BLANKCD       = $00000010; // Blank CD-R/CD-RW 
  ARCONTENT_BLANKDVD      = $00000020; // Blank DVD-R/DVD-RW 
  ARCONTENT_UNKNOWNCONTENT= $00000040; // Whatever files.  Mean that it's formatted.
  ARCONTENT_AUTOPLAYPIX   = $00000080; // Whatever files.  Mean that it's formatted.
  ARCONTENT_AUTOPLAYMUSIC = $00000100; // Whatever files.  Mean that it's formatted.
  ARCONTENT_AUTOPLAYVIDEO = $00000200; // Whatever files.  Mean that it's formatted.
  SPBEGINF_NORMAL         = $00000000;      // default normal progress behavior
  SPBEGINF_AUTOTIME       = $00000002;      // automatically updates the "time remaining" text 
  SPBEGINF_NOPROGRESSBAR  = $00000010;      // Don't display the progress bar (SetProgress() wont be called)
  SPBEGINF_MARQUEEPROGRESS= $00000020;      // use marquee progress (comctl32 v6 required)
  EXPPS_FILETYPES         = $00000001;
  IEI_PRIORITY_MAX        = ITSAT_MAX_PRIORITY;
  IEI_PRIORITY_MIN        = ITSAT_MIN_PRIORITY;
  IEIT_PRIORITY_NORMAL    = ITSAT_DEFAULT_PRIORITY;
  IEIFLAG_ASYNC           = $0001;      // ask the extractor if it supports ASYNC extract (free threaded)
  IEIFLAG_CACHE           = $0002;      // returned from the extractor if it does NOT cache the thumbnail
  IEIFLAG_ASPECT          = $0004;      // passed to the extractor to beg it to render to the aspect ratio of the supplied rect
  IEIFLAG_OFFLINE         = $0008;      // if the extractor shouldn't hit the net to get any content neede for the rendering
  IEIFLAG_GLEAM           = $0010;      // does the image have a gleam ? this will be returned if it does
  IEIFLAG_SCREEN          = $0020;      // render as if for the screen  (this is exlusive with IEIFLAG_ASPECT )
  IEIFLAG_ORIGSIZE        = $0040;      // render to the approx size passed, but crop if neccessary
  IEIFLAG_NOSTAMP         = $0080;      // returned from the extractor if it does NOT want an icon stamp on the thumbnail
  IEIFLAG_NOBORDER        = $0100;      // returned from the extractor if it does NOT want an a border around the thumbnail
  IEIFLAG_QUALITY         = $0200;      // passed to the Extract method to indicate that a slower, higher quality image is desired, re-compute the thumbnail
  IEIFLAG_REFRESH         = $0400;      // returned from the extractor if it would like to have Refresh Thumbnail available
  DBIM_MINSIZE            = $0001;
  DBIM_MAXSIZE            = $0002;
  DBIM_INTEGRAL           = $0004;
  DBIM_ACTUAL             = $0008;
  DBIM_TITLE              = $0010;
  DBIM_MODEFLAGS          = $0020;
  DBIM_BKCOLOR            = $0040;
  DBIMF_NORMAL            = $0000;
  DBIMF_FIXED             = $0001;
  DBIMF_FIXEDBMP          = $0004;   // a fixed background bitmap (if supported)
  DBIMF_VARIABLEHEIGHT    = $0008;
  DBIMF_UNDELETEABLE      = $0010;
  DBIMF_DEBOSSED          = $0020;
  DBIMF_BKCOLOR           = $0040;
  DBIMF_USECHEVRON        = $0080;
  DBIMF_BREAK             = $0100;
  DBIMF_ADDTOFRONT        = $0200;
  DBIMF_TOPALIGN          = $0400;
  DBIF_VIEWMODE_NORMAL    = $0000;
  DBIF_VIEWMODE_VERTICAL  = $0001;
  DBIF_VIEWMODE_FLOATING  = $0002;
  DBIF_VIEWMODE_TRANSPARENT    = $0004;
  DBID_BANDINFOCHANGED    = 0;
  DBID_SHOWONLY           = 1;
  DBID_MAXIMIZEBAND       = 2;      // Maximize the specified band (VT_UI4 == dwID)
  DBID_PUSHCHEVRON        = 3;
  DBID_DELAYINIT          = 4;      // Note: _bandsite_ calls _band_ with this code
  DBID_FINISHINIT         = 5;      // Note: _bandsite_ calls _band_ with this code
  DBID_SETWINDOWTHEME     = 6;      // Note: _bandsite_ calls _band_ with this code
  DBID_PERMITAUTOHIDE     = 7;
  IDD_WIZEXTN_FIRST       = $5000;
  IDD_WIZEXTN_LAST        = $5100;
  SHPWHF_NORECOMPRESS     = $00000001;  // don't allow/prompt for recompress of streams
  SHPWHF_NONETPLACECREATE = $00000002;  // don't create a network place when transfer is complete
  SHPWHF_NOFILESELECTOR   = $00000004;  // don't show the file selector
  SHPWHF_VALIDATEVIAWEBFOLDERS    = $00010000;  // enable web folders to validate network places (ANP support)

  CDBE_RET_DEFAULT        = $00000000;
  CDBE_RET_DONTRUNOTHEREXTS = $00000001;
  CDBE_RET_STOPWIZARD     = $00000002;
  CDBE_TYPE_MUSIC         = $00000001;
  CDBE_TYPE_DATA  	    = $00000002;
  CDBE_TYPE_ALL   	    = $FFFFFFFF;
  BSIM_STATE              = $00000001;
  BSIM_STYLE              = $00000002;
  BSSF_VISIBLE            = $00000001;
  BSSF_NOTITLE            = $00000002;
  BSSF_UNDELETEABLE       = $00001000;
  BSIS_AUTOGRIPPER        = $00000000;
  BSIS_NOGRIPPER          = $00000001;
  BSIS_ALWAYSGRIPPER      = $00000002;
  BSIS_LEFTALIGN          = $00000004;
  BSIS_SINGLECLICK        = $00000008;
  BSIS_NOCONTEXTMENU      = $00000010;
  BSIS_NODROPTARGET       = $00000020;
  BSIS_NOCAPTION          = $00000040;
  BSIS_PREFERNOLINEBREAK  = $00000080;
  BSIS_LOCKED             = $00000100;

  NSWF_NONE_IMPLIES_ALL   = $00000001;
  NSWF_ONE_IMPLIES_ALL    = $00000002;
  NSWF_DONT_TRAVERSE_LINKS= $00000004;
  NSWF_DONT_ACCUMULATE_RESULT    = $00000008;
  NSWF_TRAVERSE_STREAM_JUNCTIONS = $00000010;
  NSWF_FILESYSTEM_ONLY    = $00000020;
  NSWF_SHOW_PROGRESS      = $00000040;
  NSWF_FLAG_VIEWORDER     = $00000080;
  NSWF_IGNORE_AUTOPLAY_HIDA      = $00000100;
  MPPF_SETFOCUS           = $00000001;    // Menu can take the focus
  MPPF_INITIALSELECT      = $00000002;    // Select the first item
  MPPF_NOANIMATE          = $00000004;    // Do not animate this show
  MPPF_KEYBOARD           = $00000010;    // The menu is activated by keyboard
  MPPF_REPOSITION         = $00000020;    // Resposition the displayed bar.
  MPPF_FORCEZORDER        = $00000040;    // internal: Tells menubar to ignore Submenu positions
  MPPF_FINALSELECT        = $00000080;    // Select the last item
  MPPF_TOP                = $20000000;    // Popup menu up from point
  MPPF_LEFT               = $40000000;    // Popup menu left from point
  MPPF_RIGHT              = $60000000;    // Popup menu right from point
  MPPF_BOTTOM             = $80000000;    // Popup menu below point
  MPPF_POS_MASK           = $E0000000;     // Menu Position Mask
  SIGDN_NORMALDISPLAY             = $00000000;
  SIGDN_PARENTRELATIVEPARSING     = $80018001;
  SIGDN_PARENTRELATIVEFORADDRESSBAR = $8001c001;
  SIGDN_DESKTOPABSOLUTEPARSING    = $80028000;
  SIGDN_PARENTRELATIVEEDITING     = $80031001;
  SIGDN_DESKTOPABSOLUTEEDITING    = $8004c000;
  SIGDN_FILESYSPATH               = $80058000;
  SIGDN_URL                       = $80068000;
  SICHINT_DISPLAY         = $00000000;   
  SICHINT_ALLFIELDS       = $80000000;   
  SICHINT_CANONICAL       = $10000000;   
  BFO_NONE                            = $00000000;      // Do nothing.
  BFO_BROWSER_PERSIST_SETTINGS        = $00000001;      // Does this item want the browser stream? (Same window position as IE browser windows?)
  BFO_RENAME_FOLDER_OPTIONS_TOINTERNET= $00000002;     // Rename "Folder Options" to "Internet Options" in the Tools or View menu?
  BFO_BOTH_OPTIONS                    = $00000004;      // Keep both "Folder Options" and "Internet Options" in the Tools or View menu?
  BIF_PREFER_INTERNET_SHORTCUT        = $00000008;      // NSE would prefer a .url shortcut over a .lnk shortcut
  BFO_BROWSE_NO_IN_NEW_PROCESS        = $00000010;      // Specify this flag if you don't want the "Browse in New Process" via invoking a shortcut.
  BFO_ENABLE_HYPERLINK_TRACKING       = $00000020;      // Does this NSE want it's display name tracked to determine when hyperlinks should be tagged as previously used?
  BFO_USE_IE_OFFLINE_SUPPORT          = $00000040;      // Use "Internet Explorer"'s offline support?
  BFO_SUBSTITUE_INTERNET_START_PAGE   = $00000080;      // Does this NSE want to use the Start Page support?
  BFO_USE_IE_LOGOBANDING              = $00000100;      // Use the Brand block in the Toolbar.  (Spinning globe or whatever it is this year)
  BFO_ADD_IE_TOCAPTIONBAR             = $00000200;      // Should " - Internet Explorer" be appended to display name in the Captionbar
  BFO_USE_DIALUP_REF                  = $00000400;      // Should the DialUp ref count get a ref while the browse is navigated to this location?  This will also enable the ICW and Software update.
  BFO_USE_IE_TOOLBAR                  = $00000800;      // Should the IE toolbar be used?
  BFO_NO_PARENT_FOLDER_SUPPORT        = $00001000;      // Can you NOT navigate to a parent folder?  Used for Backspace button to parent folder or the View.GoTo.ParentFolder feature.
  BFO_NO_REOPEN_NEXT_RESTART          = $00002000;      // Browser windows are NOT reopened the next time the shell boots if the windows were left open on the previous logoff.  Does this NSE want the same feature?
  BFO_GO_HOME_PAGE                    = $00004000;      // Add "Home Page" to menu (Go).
  BFO_PREFER_IEPROCESS                = $00008000;      // prefers to use IEXPLORE.EXE over EXPLORER.EXE
  BFO_SHOW_NAVIGATION_CANCELLED       = $00010000;      // If navigation is aborted, show the "Action Cancelled" HTML page.
  BFO_USE_IE_STATUSBAR                = $00020000;      // Use the persisted IE status bar settings
  BFO_QUERY_ALL                       = $FFFFFFFF;      // Return all values set.
  NWMF_UNLOADING          = $0001;  // The query is occuring during onBeforeUnload or onUnload
  NWMF_USERINITED         = $0002;  // The query is occuring in the context of what trident considers to be a user initiated action
  NWMF_FIRST              = $0004;  // This is the first query since the begining of the last user initiated action
  NWMF_OVERRIDEKEY        = $0008;  // The override key was pressed at the time the query was made
  NWMF_SHOWHELP           = $0010;  // New window is an HTML help window
  NWMF_HTMLDIALOG         = $0020;  // New window is an HTML dialog
  NWMF_FROMDIALOGCHILD    = $0040;  // Called from an HTML dialog - do not show UI in parent window
  NWMF_USERREQUESTED      = $0080;  // There is no doubt the user requested this window (from RClick->Open in New Window, or Shift+Clicked a link)
  NWMF_USERALLOWED        = $0100;  // This popup is the result of the user requesting a replay that resulted in a refresh
  SMDM_SHELLFOLDER        = $00000001;  // This is for an item in the band
  SMDM_HMENU              = $00000002;  // This is for the Band itself
  SMDM_TOOLBAR            = $00000004;  // Plain toolbar, not associated with a shell folder or hmenu
  SMIM_TYPE               = $00000001;
  SMIM_FLAGS              = $00000002;
  SMIM_ICON               = $00000004;
  SMIT_SEPARATOR          = $00000001;
  SMIT_STRING             = $00000002;
  SMIF_ICON               = $00000001;       // Show an icon
  SMIF_ACCELERATOR        = $00000002;       // Underline the character marked w/ '&'
  SMIF_DROPTARGET         = $00000004;       // Item is a drop target
  SMIF_SUBMENU            = $00000008;       // Item has a submenu
  SMIF_CHECKED            = $00000020;       // Item has a Checkmark
  SMIF_DROPCASCADE        = $00000040;       // Item can cascade out during drag/drop
  SMIF_HIDDEN             = $00000080;       // Don't display item
  SMIF_DISABLED           = $00000100;       // Should be unselectable. Gray.
  SMIF_TRACKPOPUP         = $00000200;       // Should be unselectable. Gray.
  SMIF_DEMOTED            = $00000400;       // Display item in "Demoted" state.
  SMIF_ALTSTATE           = $00000800;       // Displayed in "Altered State"
  SMIF_DRAGNDROP          = $00001000;       // If item that is being dragged hovers over an item for long enough then it SMC_EXECs that item
  SMIF_NEW                = $00002000;       // Item is newly-installed or otherwise attractive (XP)
  SMC_INITMENU            = $00000001;  // The callback is called to init a menuband
  SMC_CREATE              = $00000002;
  SMC_EXITMENU            = $00000003;  // The callback is called when menu is collapsing
  SMC_GETINFO             = $00000005;  // The callback is called to return DWORD values
  SMC_GETSFINFO           = $00000006;  // The callback is called to return DWORD values
  SMC_GETOBJECT           = $00000007;  // The callback is called to get some object
  SMC_GETSFOBJECT         = $00000008;  // The callback is called to get some object
  SMC_SFEXEC              = $00000009;  // The callback is called to execute an shell folder item
  SMC_SFSELECTITEM        = $0000000A;  // The callback is called when an item is selected
  SMC_REFRESH             = $00000010;  // Menus have completely refreshed. Reset your state.
  SMC_DEMOTE              = $00000011;  // Demote an item
  SMC_PROMOTE             = $00000012;  // Promote an item, wParam = SMINV_* flag
  SMC_DEFAULTICON         = $00000016;  // Returns Default icon location in wParam, index in lParam
  SMC_NEWITEM             = $00000017;  // Notifies item is not in the order stream.
  SMC_CHEVRONEXPAND       = $00000019;  // Notifies of a expansion via the chevron 
  SMC_DISPLAYCHEVRONTIP   = $0000002A;  // S_OK display, S_FALSE not. 
  SMC_SETSFOBJECT         = $0000002D;  // Called to save the passed object
  SMC_SHCHANGENOTIFY      = $0000002E;  // Called when a Change notify is received. lParam points to SMCSHCHANGENOTIFYSTRUCT
  SMC_CHEVRONGETTIP       = $0000002F;  // Called to get the chevron tip text. wParam = Tip title, Lparam = TipText Both MAX_PATH
  SMC_SFDDRESTRICTED      = $00000030;  // Called requesting if it's ok to drop. wParam = IDropTarget.
  ATTACHMENT_PROMPT_NONE  = $0000;
  ATTACHMENT_PROMPT_SAVE  = $0001;
  ATTACHMENT_PROMPT_EXEC  = $0002;             
  ATTACHMENT_PROMPT_EXEC_OR_SAVE      = $0003;             
  ATTACHMENT_ACTION_CANCEL= $0000; 
  ATTACHMENT_ACTION_SAVE  = $0001;
  ATTACHMENT_ACTION_EXEC  = $0002;             
  SMINIT_DEFAULT          = $00000000;  // No Options
  SMINIT_RESTRICT_DRAGDROP= $00000002;  // Don't allow Drag and Drop
  SMINIT_TOPLEVEL         = $00000004;  // This is the top band.
  SMINIT_CACHED           = $00000010;
  SMINIT_VERTICAL         = $10000000;  // This is a vertical menu
  SMINIT_HORIZONTAL       = $20000000;  // This is a horizontal menu    (does not inherit)
  ANCESTORDEFAULT         = dword(-1);
  SMSET_TOP               = $10000000;    // Bias this namespace to the top of the menu
  SMSET_BOTTOM            = $20000000;    // Bias this namespace to the bottom of the menu
  SMSET_DONTOWN           = $00000001;    // The Menuband doesn't own the non-ref counted object
  SMINV_REFRESH           = $00000001;
  SMINV_ID                = $00000008;

Type
      SFGAOF = ULONG;
      TSFGAOF = SFGAOF;
      PSFGAOF = ^SFGAOF;
      PROPERTYUI_NAME_FLAGS = DWord; // enum
      PROPERTYUI_FORMAT_FLAGS = DWord;
      PROPERTYUI_FLAGS = Dword;
      CATSORT_FLAGS    = DWORD;
      CATEGORYINFO_FLAGS = DWord;

      PPROPERTYUI_NAME_FLAGS    = ^PROPERTYUI_NAME_FLAGS;
      PPROPERTYUI_FORMAT_FLAGS  = ^PROPERTYUI_FORMAT_FLAGS;
      PPROPERTYUI_FLAGS         = ^PROPERTYUI_FLAGS;
      PCATSORT_FLAGS            = ^CATSORT_FLAGS;
      PCATEGORYINFO_FLAGS	= ^CATEGORYINFO_FLAGS;

      RESTRICTIONS = DWORD;
      TRESTRICTIONS = RESTRICTIONS;
      PRESTRICTIONS = ^RESTRICTIONS;
      FOLDERVIEWMODE = DWORD;
      SHColumnID = packed record
                    fmtid : TGUID;
                    pid   : DWORD;
                   end;
      CATEGORY_INFO = record
                         cif : CATEGORYINFO_FLAGS;
                         wsname: array[0..259] of wchar;
			 end;
      TCATEGORY_INFO = CATEGORY_INFO;
      PCATEGORY_INFO = ^CATEGORY_INFO;

      LPSHColumnID = SHColumnID;
      TSHColumnid = SHColumnID;
      pSHColumnID = LPSHColumnID;

     IShellView = Interface;
     IShellFolder = Interface;
     IShellBrowser = Interface;
     LPFNVIEWCALLBACK = function (psvouter:IShellView;psf : IShellFolder;hwndMain:HWND ;uMSG:UINT;wParam:WPARAM;lParam:LPARAM) :HRESULT; StdCall;
     LPFNDFMCALLBACK   = function (psf:IShellFolder; HWND: hwnd;pdtobj:IDataObject;uMsg:UINT;WPARAM:wParam; LPARAM: lParam) :HRESULT; StdCall;

     IShellFolderViewCB = Interface(IUnknown)
        ['{2047E320-F2A9-11CE-AE65-08002B2E1262}']
        function MessageSFVCB (uMSG: UINT;wparam:WPARAM;LPARAM:lParam):HResult; stdcall;
        end;


     LPTBBUTTONSB = LPTBBUTTON;
     SVSIF = UINT;
     TSVSIF = SVSIF;
     SHELLVIEWID = TGUID;
     TSHELLVIEWID = TGUID;
     PSHELLVIEWID = ^TGUID;
     LPVIEWSETTINGS = Pchar;

     _CMInvokeCommandInfoEx = record
          cbSize : DWORD;                 { must be sizeof(CMINVOKECOMMANDINFOEX) }
          fMask : DWORD;                  { any combination of CMIC_MASK_* }
          hwnd : HWND;                    { might be NULL (indicating no owner window) }
          lpVerb : LPCSTR;                { either a string or MAKEINTRESOURCE(idOffset) }
          lpParameters : LPCSTR;          { might be NULL (indicating no parameter) }
          lpDirectory : LPCSTR;           { might be NULL (indicating no specific directory) }
          nShow : longint;                { one of SW_ values for ShowWindow() API }
          dwHotKey : DWORD;
          hIcon : HANDLE;
          lpTitle : LPCSTR;               { For CreateProcess-StartupInfo.lpTitle }
          lpVerbW : LPCWSTR;              { Unicode verb (for those who can use it) }
          lpParametersW : LPCWSTR;        { Unicode parameters (for those who can use it) }
          lpDirectoryW : LPCWSTR;         { Unicode directory (for those who can use it) }
          lpTitleW : LPCWSTR;             { Unicode title (for those who can use it) }
          ptInvoke : POINT;               { Point where it's invoked }
       end;
     TCMINVOKECOMMANDINFOEX = _CMInvokeCommandInfoEx;
     PCMINVOKECOMMANDINFOEX = ^TCMINVOKECOMMANDINFOEX;
     LPCMINVOKECOMMANDINFOEX = PCMInvokeCommandInfoEx;
     PLPCMINVOKECOMMANDINFOEX = ^LPCMINVOKECOMMANDINFOEX;

     PPERSIST_FOLDER_TARGET_INFO = ^PERSIST_FOLDER_TARGET_INFO;
     PERSIST_FOLDER_TARGET_INFO = record
          pidlTargetFolder : LPITEMIDLIST;                         { pidl for the folder we want to intiailize }
          szTargetParsingName : array[0..(MAX_PATH)-1] of WCHAR;   { optional parsing name for the target }
          szNetworkProvider : array[0..(MAX_PATH)-1] of WCHAR;     { optional network provider }
          dwAttributes : DWORD;                                    { optional FILE_ATTRIBUTES_ flags (-1 if not used) }
          csidl : longint;                                         { optional folder index (SHGetFolderPath()) -1 if not used }
       end;
     TPERSIST_FOLDER_TARGET_INFO = PERSIST_FOLDER_TARGET_INFO;

     DATABLOCK_HEADER = record
          cbSize : DWORD;                 { Size of this extra data block }
          dwSignature : DWORD;            { signature of this extra data block }
       end;
     TDATABLOCKHEADER = DATABLOCK_HEADER;
     TDATABLOCK_HEADER = DATABLOCK_HEADER;
     PDATABLOCK_HEADER = ^TDATABLOCK_HEADER;
     PDATABLOCKHEADER = ^TDATABLOCKHEADER;
     LPDATABLOCK_HEADER = PDATABLOCK_HEADER;
     PLPDATABLOCK_HEADER = ^LPDATABLOCK_HEADER;
     LPDBLIST = PDATABLOCK_HEADER;
     PLPDBLIST = ^LPDBLIST;

     PNT_CONSOLE_PROPS = ^NT_CONSOLE_PROPS;
     NT_CONSOLE_PROPS = record
          dbh : DATABLOCK_HEADER;      
          wFillAttribute : WORD;         { fill attribute for console }
          wPopupFillAttribute : WORD;    { fill attribute for console popups }
          dwScreenBufferSize : COORD;    { screen buffer size for console }
          dwWindowSize : COORD;          { window size for console }
          dwWindowOrigin : COORD;        { window origin for console }
          nFont : DWORD;
          nInputBufferSize : DWORD;
          dwFontSize : COORD;
          uFontFamily : UINT;
          uFontWeight : UINT;
          FaceName : array[0..(LF_FACESIZE)-1] of WCHAR;
          uCursorSize : UINT;
          bFullScreen : BOOL;
          bQuickEdit : BOOL;
          bInsertMode : BOOL;
          bAutoPosition : BOOL;
          uHistoryBufferSize : UINT;
          uNumberOfHistoryBuffers : UINT;
          bHistoryNoDup : BOOL;
          ColorTable : array[0..15] of COLORREF;
       end;
     TNT_CONSOLE_PROPS = NT_CONSOLE_PROPS;
     LPNT_CONSOLE_PROPS = PNT_CONSOLE_PROPS;
     PLPNT_CONSOLE_PROPS = ^LPNT_CONSOLE_PROPS;

     PNT_FE_CONSOLE_PROPS = ^NT_FE_CONSOLE_PROPS;
     NT_FE_CONSOLE_PROPS = record
          dbh : DATABLOCK_HEADER;
          uCodePage : UINT;            { This is a FE Console property }
       end;
     TNT_FE_CONSOLE_PROPS = NT_FE_CONSOLE_PROPS;
     LPNT_FE_CONSOLE_PROPS = PNT_FE_CONSOLE_PROPS;
     PLPNT_FE_CONSOLE_PROPS = ^LPNT_FE_CONSOLE_PROPS;

     PEXP_DARWIN_LINK = ^EXP_DARWIN_LINK;
     EXP_DARWIN_LINK = record
          dbh : DATABLOCK_HEADER;
          szDarwinID : array[0..(MAX_PATH)-1] of CHAR;    { ANSI darwin ID associated with link }
          szwDarwinID : array[0..(MAX_PATH)-1] of WCHAR;  { UNICODE darwin ID associated with link }
       end;
     TEXP_DARWIN_LINK = EXP_DARWIN_LINK;
     LPEXP_DARWIN_LINK = PEXP_DARWIN_LINK;
     PLPEXP_DARWIN_LINK = ^LPEXP_DARWIN_LINK;

     PEXP_SPECIAL_FOLDER = ^EXP_SPECIAL_FOLDER;
     EXP_SPECIAL_FOLDER = record
          cbSize : DWORD;             { Size of this extra data block }
          dwSignature : DWORD;        { signature of this extra data block }
          idSpecialFolder : DWORD;    { special folder id this link points into }
          cbOffset : DWORD;           { ofset into pidl from SLDF_HAS_ID_LIST for child }
       end;
     LPEXP_SPECIAL_FOLDER = PEXP_SPECIAL_FOLDER;
     PLPEXP_SPECIAL_FOLDER = ^LPEXP_SPECIAL_FOLDER;
     TEXP_SPECIAL_FOLDER = EXP_SPECIAL_FOLDER;

     PEXP_SZ_LINK = ^EXP_SZ_LINK;
     EXP_SZ_LINK = record
          cbSize : DWORD;                                 { Size of this extra data block }
          dwSignature : DWORD;                            { signature of this extra data block }
          szTarget : array[0..(MAX_PATH)-1] of CHAR;      { ANSI target name w/EXP_SZ in it }
          swzTarget : array[0..(MAX_PATH)-1] of WCHAR;    { UNICODE target name w/EXP_SZ in it }
       end;
     LPEXP_SZ_LINK = PEXP_SZ_LINK;
     PLPEXP_SZ_LINK = ^LPEXP_SZ_LINK;
     TEXP_SZ_LINK = EXP_SZ_LINK;

     PFVSHOWINFO = ^FVSHOWINFO;
     FVSHOWINFO = record                                        { Stuff passed into viewer (in) }
          cbSize : DWORD;                                       { Size of structure for future expansion... }
          hwndOwner : HWND;                                     { who is the owner window. }
          iShow : longint;                                      { The show command }
                                                                { Passed in and updated  (in/Out) }
          dwFlags : DWORD;                                      { flags }
          rect : RECT;                                          { Where to create the window may have defaults }
          punkRel :  IUnknown;                                  { Relese this interface when window is visible }
                                                                { Stuff that might be returned from viewer (out) }
          strNewFile : array[0..(MAX_PATH)-1] of OLECHAR;       { New File to view. }
       end;                                                     
     TFVSHOWINFO = FVSHOWINFO;
     LPFVSHOWINFO = PFVSHOWINFO;
     PLPFVSHOWINFO = ^LPFVSHOWINFO;

     PSHFOLDERCUSTOMSETTINGSA = ^SHFOLDERCUSTOMSETTINGSA;
     SHFOLDERCUSTOMSETTINGSA = record
          dwSize : DWORD;                             
          dwMask : DWORD;                            { IN/OUT   Which Attributes to Get/Set }             
          pvid : PSHELLVIEWID;                       { OUT - if dwReadWrite is FCS_READ, IN - otherwise }
                                                     { The folder's WebView template path }
          pszWebViewTemplate : LPSTR;                { OUT - if dwReadWrite is FCS_READ, IN - otherwise }  
          cchWebViewTemplate : DWORD;                { IN - Specifies the size of the buffer pointed to by pszWebViewTemplate }            
          pszWebViewTemplateVersion : LPSTR;         { Ignored if dwReadWrite is FCS_READ }
          pszInfoTip : LPSTR;                        { currently IN only }
          cchInfoTip : DWORD;                        { Infotip for the folder }
                                                     { OUT - if dwReadWrite is FCS_READ, IN - otherwise }
                                                     { IN - Specifies the size of the buffer pointed to by pszInfoTip }
          pclsid : PCLSID;                           { Ignored if dwReadWrite is FCS_READ }
                                                     { CLSID that points to more info in the registry }
          dwFlags : DWORD;                           { OUT - if dwReadWrite is FCS_READ, IN - otherwise }
          pszIconFile : LPSTR;                       { Other flags for the folder. Takes FCS_FLAG_* values }
          cchIconFile : DWORD;                       { OUT - if dwReadWrite is FCS_READ, IN - otherwise }
                                                     { OUT - if dwReadWrite is FCS_READ, IN - otherwise }
          iIconIndex : longint;                      { IN - Specifies the size of the buffer pointed to by pszIconFile }
                                                     { Ignored if dwReadWrite is FCS_READ }
          pszLogo : LPSTR;                           { OUT - if dwReadWrite is FCS_READ, IN - otherwise }
          cchLogo : DWORD;                           { OUT - if dwReadWrite is FCS_READ, IN - otherwise }
       end;                                          { IN - Specifies the size of the buffer pointed to by pszIconFile }
                                                     { Ignored if dwReadWrite is FCS_READ }

     LPSHFOLDERCUSTOMSETTINGSA = PSHFOLDERCUSTOMSETTINGSA;
     PLPSHFOLDERCUSTOMSETTINGSA = ^LPSHFOLDERCUSTOMSETTINGSA;
     TSHFOLDERCUSTOMSETTINGSA =   SHFOLDERCUSTOMSETTINGSA;

     PSHFOLDERCUSTOMSETTINGSW = ^SHFOLDERCUSTOMSETTINGSW;
     SHFOLDERCUSTOMSETTINGSW = record
          dwSize : DWORD;
          dwMask : DWORD;
          pvid : PSHELLVIEWID;
          pszWebViewTemplate : LPWSTR;
          cchWebViewTemplate : DWORD;
          pszWebViewTemplateVersion : LPWSTR;
          pszInfoTip : LPWSTR;
          cchInfoTip : DWORD;
          pclsid : PCLSID;
          dwFlags : DWORD;
          pszIconFile : LPWSTR;
          cchIconFile : DWORD;
          iIconIndex : longint;
          pszLogo : LPWSTR;
          cchLogo : DWORD;
       end;
     LPSHFOLDERCUSTOMSETTINGSW = PSHFOLDERCUSTOMSETTINGSW;
     PLPSHFOLDERCUSTOMSETTINGSW = ^LPSHFOLDERCUSTOMSETTINGSW;
     TSHFOLDERCUSTOMSETTINGSW = SHFOLDERCUSTOMSETTINGSW;

     _browseinfoA = record
          hwndOwner : HWND;
          pidlRoot : LPCITEMIDLIST;
          pszDisplayName : LPSTR;    { Return display name of item selected. }
          lpszTitle : LPCSTR;        { text to go in the banner over the tree. }
          ulFlags : UINT;            { Flags that control the return stuff }
          lpfn : BFFCALLBACK;        
          lParam : LPARAM;           { extra info that's passed back in callbacks }
          iImage : longint;          { output var: where to return the Image index. }
       end;
     BROWSEINFOA = _browseinfoA;
     PBROWSEINFOA = ^BROWSEINFOA;
     TBROWSEINFOA = BROWSEINFOA;
     PPBROWSEINFOA = ^PBROWSEINFOA;
     LPBROWSEINFOA = PbrowseinfoA;
     PLPBROWSEINFOA = ^LPBROWSEINFOA;

     _browseinfoW = record
          hwndOwner : HWND;
          pidlRoot : LPCITEMIDLIST;
          pszDisplayName : LPWSTR;    { Return display name of item selected. }
          lpszTitle : LPCWSTR;        { text to go in the banner over the tree. }
          ulFlags : UINT;             { Flags that control the return stuff }
          lpfn : BFFCALLBACK;         
          lParam : LPARAM;            { extra info that's passed back in callbacks }
          iImage : longint;           { output var: where to return the Image index. }
       end;
     BROWSEINFOW = _browseinfoW;
     PBROWSEINFOW = ^BROWSEINFOW;
     PPBROWSEINFOW = ^PBROWSEINFOW;
     LPBROWSEINFOW = PbrowseinfoW;
     PLPBROWSEINFOW = ^LPBROWSEINFOW;
     TBROWSEINFOW = BROWSEINFOW;

     P_EnumImageStoreDATAtag = ^_EnumImageStoreDATAtag;
     _EnumImageStoreDATAtag = record
          szPath : array[0..(MAX_PATH)-1] of WCHAR;
          ftTimeStamp : FILETIME;
       end;
     ENUMSHELLIMAGESTOREDATA = _EnumImageStoreDATAtag;
     PENUMSHELLIMAGESTOREDATA = ^ENUMSHELLIMAGESTOREDATA;
     PPENUMSHELLIMAGESTOREDATA = ^PENUMSHELLIMAGESTOREDATA;
     TENUMSHELLIMAGESTOREDATA = _EnumImageStoreDATAtag;
     PBANDINFOSFB = ^BANDINFOSFB;
     BANDINFOSFB = record
          dwMask : DWORD;       { [in] ISFB_MASK mask of valid fields from crBkgnd on }
          dwStateMask : DWORD;  { [in] ISFB_STATE mask of dwState bits being set/queried }
          dwState : DWORD;      { [in/out] ISFB_STATE bits }
          crBkgnd : COLORREF;   { [in/out] }
          crBtnLt : COLORREF;   { [in/out] }
          crBtnDk : COLORREF;   { [in/out] }
          wViewMode : WORD;     { [in/out] }
          wAlign : WORD;        { not used (yet) }
          psf : IShellFolder;  { [out] }
          pidl : LPITEMIDLIST;  { [out] }
       end;
     PPBANDINFOSFB = ^PBANDINFOSFB;

     _tagWALLPAPEROPT = record
          dwSize : DWORD;        { size of this Structure. }
          dwStyle : DWORD;       { WPSTYLE_* mentioned above }
       end;
     WALLPAPEROPT  = _tagWALLPAPEROPT;
     TWALLPAPEROPT = _tagWALLPAPEROPT;
     PWALLPAPEROPT = ^WALLPAPEROPT;

     PLPWALLPAPEROPT = ^LPWALLPAPEROPT;
     LPWALLPAPEROPT = WALLPAPEROPT;

     PLPCWALLPAPEROPT = ^LPCWALLPAPEROPT;
     LPCWALLPAPEROPT = WALLPAPEROPT;

     _tagCOMPONENTSOPT = record
          dwSize : DWORD;               {Size of this structure }
          fEnableComponents : BOOL;     {Enable components? }
          fActiveDesktop : BOOL;        { Active desktop enabled ? }
       end;
     COMPONENTSOPT = _tagCOMPONENTSOPT;
     TCOMPONENTSOPT = _tagCOMPONENTSOPT;
     PCOMPONENTSOPT = ^COMPONENTSOPT;
     PLPCOMPONENTSOPT = ^LPCOMPONENTSOPT;
     LPCOMPONENTSOPT = COMPONENTSOPT;
     PLPCCOMPONENTSOPT = ^LPCCOMPONENTSOPT;
     LPCCOMPONENTSOPT = COMPONENTSOPT;

     _tagCOMPPOS = record
          dwSize : DWORD;               {Size of this structure }
          iLeft : longint;              {Left of top-left corner in screen co-ordinates. }
          iTop : longint;               {Top of top-left corner in screen co-ordinates. }
          dwWidth : DWORD;              { Width in pixels. }
          dwHeight : DWORD;             { Height in pixels. }
          izIndex : longint;            { Indicates the Z-order of the component. }
          fCanResize : BOOL;            { Is the component resizeable? }
          fCanResizeX : BOOL;           { Resizeable in X-direction? }
          fCanResizeY : BOOL;           { Resizeable in Y-direction? }
          iPreferredLeftPercent : longint;{Left of top-left corner as percent of screen width }
          iPreferredTopPercent : longint; {Top of top-left corner as percent of screen height }
       end;
     COMPPOS  = _tagCOMPPOS;
     TCOMPPOS = _tagCOMPPOS;
     PCOMPPOS = ^COMPPOS;
     PLPCOMPPOS = ^LPCOMPPOS;
     LPCOMPPOS = COMPPOS;

     PLPCCOMPPOS = ^LPCCOMPPOS;
     LPCCOMPPOS = COMPPOS;
  
     _tagCOMPSTATEINFO = record
          dwSize : DWORD;             { Size of this structure. }
          iLeft : longint;            { Left of the top-left corner in screen co-ordinates. }
          iTop : longint;             { Top of top-left corner in screen co-ordinates. }
          dwWidth : DWORD;            { Width in pixels. }
          dwHeight : DWORD;           { Height in pixels. }
          dwItemState : DWORD;        { State of the component (full-screen mode or split-screen or normal state. }
       end;
     COMPSTATEINFO = _tagCOMPSTATEINFO;
     TCOMPSTATEINFO = _tagCOMPSTATEINFO;
     PCOMPSTATEINFO = ^COMPSTATEINFO;
     PLPCOMPSTATEINFO = ^LPCOMPSTATEINFO;
     LPCOMPSTATEINFO = COMPSTATEINFO;
     PLPCCOMPSTATEINFO = ^LPCCOMPSTATEINFO;
     LPCCOMPSTATEINFO = COMPSTATEINFO;

     _tagIE4COMPONENT = record
          dwSize : DWORD;                  {Size of this structure }                                       
          dwID : DWORD;                    {Reserved: Set it always to zero. }
          iComponentType : longint;        {One of COMP_TYPE_* }
          fChecked : BOOL;                 { Is this component enabled? }
          fDirty : BOOL;                   { Had the component been modified and not yet saved to disk? }
          fNoScroll : BOOL;                { Is the component scrollable? }
          cpPos : COMPPOS;                 { Width, height etc., } {}
          wszFriendlyName : array[0..(MAX_PATH)-1] of WCHAR;                             { Friendly name of component. }
          wszSource : array[0..(INTERNET_MAX_URL_LENGTH)-1] of WCHAR;                    {URL of the component. }
          wszSubscribedURL : array[0..(INTERNET_MAX_URL_LENGTH)-1] of WCHAR;             {Subscrined URL }
       end;
     IE4COMPONENT = _tagIE4COMPONENT;
     TIE4COMPONENT = _tagIE4COMPONENT;
     PIE4COMPONENT = ^IE4COMPONENT;
     PLPIE4COMPONENT = ^LPIE4COMPONENT;
     LPIE4COMPONENT = IE4COMPONENT;

     PLPCIE4COMPONENT = ^LPCIE4COMPONENT;
     LPCIE4COMPONENT = IE4COMPONENT;
     _tagCOMPONENT = record
          dwSize : DWORD;                                                        {Size of this structure }
          dwID : DWORD;                                              {}            {Reserved: Set it always to zero. }
          iComponentType : longint;                                              {One of COMP_TYPE_* }
          fChecked : BOOL;                                                       { Is this component enabled? }
          fDirty : BOOL;                                                         { Had the component been modified and not yet saved to disk? }
          fNoScroll : BOOL;                                                      { Is the component scrollable? }
          cpPos : COMPPOS;                                                       { Width, height etc., }
          wszFriendlyName : array[0..(MAX_PATH)-1] of WCHAR;                     { Friendly name of component. }
          wszSource : array[0..(INTERNET_MAX_URL_LENGTH)-1] of WCHAR;            {URL of the component. }
          wszSubscribedURL : array[0..(INTERNET_MAX_URL_LENGTH)-1] of WCHAR;     {Subscrined URL }
                                                                                 {New fields are added below. Everything above here must exactly match the IE4COMPONENT Structure. }
          dwCurItemState : DWORD;                                                { Current state of the Component. }
          csiOriginal : COMPSTATEINFO;                                           { Original state of the component when it was first added. }
          csiRestored : COMPSTATEINFO;                                           { Restored state of the component. }
       end;
     COMPONENT = _tagCOMPONENT;
     PCOMPONENT = ^COMPONENT;
     // no tcomponent because ambiguous.
     PLPCOMPONENT = ^LPCOMPONENT;
     LPCOMPONENT = COMPONENT;

     PLPCCOMPONENT = ^LPCCOMPONENT;
     LPCCOMPONENT = COMPONENT;

     PSHCOLUMNINFO = ^SHCOLUMNINFO;
     SHCOLUMNINFO = record
          scid : SHCOLUMNID;                                                { OUT the unique identifier of this column}
          vt : VARTYPE;                                                     { OUT the native type of the data return}
          fmt : DWORD;                                                      { OUT this listview format (LVCFMT_LEFT}
          cChars : UINT;                                                    { OUT the default width of the column,}
          csFlags : DWORD;                                                  { OUT SHCOLSTATE flags }
          wszTitle : array[0..(MAX_COLUMN_NAME_LEN)-1] of WCHAR;            { OUT the title of the column }
          wszDescription : array[0..(MAX_COLUMN_DESC_LEN)-1] of WCHAR;      { OUT full description of this column }
       end;
     TSHCOLUMNINFO = SHCOLUMNINFO;
     LPSHCOLUMNINFO = PSHCOLUMNINFO;
     PLPSHCOLUMNINFO = ^LPSHCOLUMNINFO;

     PSHCOLUMNINIT = ^SHCOLUMNINIT;
     SHCOLUMNINIT = record                             
          dwFlags : ULONG;                               { initialization flags }
          dwReserved : ULONG;                            { reserved for future use. }
          wszFolder : array[0..(MAX_PATH)-1] of WCHAR;   { fully qualified folder path (or empty if multiple folders) }
       end;
     TSHCOLUMNINIT = SHCOLUMNINIT;
     LPSHCOLUMNINIT = PSHCOLUMNINIT;
     PLPSHCOLUMNINIT = ^LPSHCOLUMNINIT;

     PLPCSHCOLUMNINIT = ^LPCSHCOLUMNINIT;
     LPCSHCOLUMNINIT = SHCOLUMNINIT;

     PSHCOLUMNDATA = ^SHCOLUMNDATA;
     SHCOLUMNDATA = record
          dwFlags : ULONG;                                   { combination of SHCDF_ flags. }
          dwFileAttributes : DWORD;                          { file attributes. }
          dwReserved : ULONG;                                { reserved for future use. }
          pwszExt : PWCHAR;                                  { address of file name extension }
          wszFile : array[0..(MAX_PATH)-1] of WCHAR;         { Absolute path of file. }
       end;
     TSHCOLUMNDAT=SHCOLUMNDATA;
     LPSHCOLUMNDATA = PSHCOLUMNDATA;
     PLPSHCOLUMNDATA = ^LPSHCOLUMNDATA;

     PLPCSHCOLUMNDATA = ^LPCSHCOLUMNDATA;
     LPCSHCOLUMNDATA = SHCOLUMNDATA;
  
     PSHDRAGIMAGE = ^SHDRAGIMAGE;
     SHDRAGIMAGE = record
          sizeDragImage : SIZE;     { OUT - The length and Width of the rendered image }
          ptOffset : POINT;         { OUT - The Offset from the mouse cursor to the upper left corner of the image }
          hbmpDragImage : HBITMAP;  { OUT - The Bitmap containing the rendered drag images }
          crColorKey : COLORREF;    { OUT - The COLORREF that has been blitted to the background of the images }
       end;
     LPSHDRAGIMAGE = PSHDRAGIMAGE;
     PLPSHDRAGIMAGE = ^LPSHDRAGIMAGE;
     TSHDRAGIMAGE = SHDRAGIMAGE;

     _NRESARRAY = record
          cItems : UINT;
          nr : array[0..0] of NETRESOURCE;
       end;
     NRESARRAY = _NRESARRAY;
     TNRESARRAY = _NRESARRAY;
     PNRESARRAY = ^NRESARRAY;
     LPNRESARRAY = PNRESARRAY;
     PLPNRESARRAY = ^LPNRESARRAY;

     _IDA = record
          cidl : UINT;                             { number of relative IDList }
          aoffset : array[0..0] of UINT;           { [0]: folder IDList, [1]-[cidl]: item IDList }
       end;
     CIDA = _IDA;
     TIDA = _IDA;
     PIDA  = ^TIDA;
     PCIDA = ^CIDA;
     LPIDA = PCIDA;
     PLPIDA = ^LPIDA;

     _FILEDESCRIPTORA = record
          dwFlags : DWORD;
          clsid : CLSID;
          sizel : SIZEL;
          pointl : POINTL;
          dwFileAttributes : DWORD;
          ftCreationTime : FILETIME;
          ftLastAccessTime : FILETIME;
          ftLastWriteTime : FILETIME;
          nFileSizeHigh : DWORD;
          nFileSizeLow : DWORD;
          cFileName : array[0..(MAX_PATH)-1] of CHAR;
       end;
     FILEDESCRIPTORA = _FILEDESCRIPTORA;
     TFILEDESCRIPTORA = _FILEDESCRIPTORA;
     PFILEDESCRIPTORA = ^FILEDESCRIPTORA;
     LPFILEDESCRIPTORA = PFILEDESCRIPTORA;
     PLPFILEDESCRIPTORA = ^LPFILEDESCRIPTORA;

     _FILEDESCRIPTORW = record
          dwFlags : DWORD;
          clsid : CLSID;
          sizel : SIZEL;
          pointl : POINTL;
          dwFileAttributes : DWORD;
          ftCreationTime : FILETIME;
          ftLastAccessTime : FILETIME;
          ftLastWriteTime : FILETIME;
          nFileSizeHigh : DWORD;
          nFileSizeLow : DWORD;
          cFileName : array[0..(MAX_PATH)-1] of WCHAR;
       end;
     FILEDESCRIPTORW = _FILEDESCRIPTORW;
     TFILEDESCRIPTORW = _FILEDESCRIPTORW;
     PFILEDESCRIPTORW = ^FILEDESCRIPTORW;
     LPFILEDESCRIPTORW = PFILEDESCRIPTORW;
     PLPFILEDESCRIPTORW = ^LPFILEDESCRIPTORW;

     _FILEGROUPDESCRIPTORA = record
          cItems : UINT;
          fgd : array[0..0] of FILEDESCRIPTORA;
       end;
     FILEGROUPDESCRIPTORA = _FILEGROUPDESCRIPTORA;
     TFILEGROUPDESCRIPTORA = _FILEGROUPDESCRIPTORA;
     PFILEGROUPDESCRIPTORA = ^FILEGROUPDESCRIPTORA;
     LPFILEGROUPDESCRIPTORA = PFILEGROUPDESCRIPTORA;
     PLPFILEGROUPDESCRIPTORA = ^LPFILEGROUPDESCRIPTORA;

     _FILEGROUPDESCRIPTORW = record
          cItems : UINT;
          fgd : array[0..0] of FILEDESCRIPTORW;
       end;
     FILEGROUPDESCRIPTORW = _FILEGROUPDESCRIPTORW;
     TFILEGROUPDESCRIPTORW = _FILEGROUPDESCRIPTORW;
     PFILEGROUPDESCRIPTORW = ^FILEGROUPDESCRIPTORW;
     LPFILEGROUPDESCRIPTORW = PFILEGROUPDESCRIPTORW;
     PLPFILEGROUPDESCRIPTORW = ^LPFILEGROUPDESCRIPTORW;
  
     _DROPFILES = record
          pFiles : DWORD;        { offset of file list }
          pt : POINT;            { drop point (client coords) }
          fNC : BOOL;            { is it on NonClient area }
          fWide : BOOL;          { and pt is in screen coords }
       end;                      { WIDE character switch }
     DROPFILES = _DROPFILES;
     TDROPFILES = _DROPFILES;
     PDROPFILES = ^DROPFILES;
     LPDROPFILES = PDROPFILES;
     PLPDROPFILES = ^LPDROPFILES;

  {====== File System Notification APIs =============================== }

     _SHChangeNotifyEntry = record
          pidl : LPCITEMIDLIST;
          fRecursive : BOOL;
       end;
     SHChangeNotifyEntry = _SHChangeNotifyEntry;
     TSHChangeNotifyEntry = _SHChangeNotifyEntry;
     PSHChangeNotifyEntry = ^SHChangeNotifyEntry;

     _SHChangeDWORDAsIDList = record
          cb : USHORT;
          dwItem1 : DWORD;
          dwItem2 : DWORD;
          cbZero : USHORT;
       end;
     SHChangeDWORDAsIDList = _SHChangeDWORDAsIDList;
     TSHChangeDWORDAsIDList = _SHChangeDWORDAsIDList;
     PSHChangeDWORDAsIDList = ^SHChangeDWORDAsIDList;
     LPSHChangeDWORDAsIDList = PSHChangeDWORDAsIDList;
     PLPSHChangeDWORDAsIDList = ^LPSHChangeDWORDAsIDList;

     _SHChangeUpdateImageIDList = record
          cb : USHORT;
          iIconIndex : longint;
          iCurIndex : longint;
          uFlags : UINT;
          dwProcessID : DWORD;
          szName : array[0..(MAX_PATH)-1] of WCHAR;
          cbZero : USHORT;
       end;
     SHChangeUpdateImageIDList = _SHChangeUpdateImageIDList;
     TSHChangeUpdateImageIDList = _SHChangeUpdateImageIDList;
     PSHChangeUpdateImageIDList = ^SHChangeUpdateImageIDList;
     LPSHChangeUpdateImageIDList = PSHChangeUpdateImageIDList;
     PLPSHChangeUpdateImageIDList = ^LPSHChangeUpdateImageIDList;

     _SHChangeProductKeyAsIDList = record
          cb : USHORT;
          wszProductKey : array[0..38] of WCHAR;
          cbZero : USHORT;
       end;
     SHChangeProductKeyAsIDList = _SHChangeProductKeyAsIDList;
     TSHChangeProductKeyAsIDList = _SHChangeProductKeyAsIDList;
     PSHChangeProductKeyAsIDList = ^SHChangeProductKeyAsIDList;
     LPSHChangeProductKeyAsIDList = PSHChangeProductKeyAsIDList;
     PLPSHChangeProductKeyAsIDList = ^LPSHChangeProductKeyAsIDList;

     _SHDESCRIPTIONID = record
          dwDescriptionId : DWORD;
          clsid : CLSID;
       end;
     SHDESCRIPTIONID = _SHDESCRIPTIONID;
     TSHDESCRIPTIONID = _SHDESCRIPTIONID;
     PSHDESCRIPTIONID = ^SHDESCRIPTIONID;
     LPSHDESCRIPTIONID = PSHDESCRIPTIONID;
     PLPSHDESCRIPTIONID = ^LPSHDESCRIPTIONID;

  const
     NUM_POINTS = 3;     
  { asd }

  type

     PAUTO_SCROLL_DATA = ^AUTO_SCROLL_DATA;
      AUTO_SCROLL_DATA= record
          iNextSample : longint;
          dwLastScroll : DWORD;
          bFull : BOOL;
          pts : array[0..(NUM_POINTS)-1] of POINT;
          dwTimes : array[0..(NUM_POINTS)-1] of DWORD;
       end;
     TAUTO_SCROLL_DATA = AUTO_SCROLL_DATA;

     PCABINETSTATE = ^CABINETSTATE;
     CABINETSTATE = record 
          cLength : WORD;            { NT: Show compressed volumes in a different colour }
          nVersion : WORD;           { NT: Do 8.3 name conversion, or not! }
          flag0 : word;              { NT: Administrators create comon groups }
          fMenuEnumFilter : UINT;
       end;
     TCABINETSTATE =  CABINETSTATE;
     LPCABINETSTATE = PCABINETSTATE;
     PLPCABINETSTATE = ^LPCABINETSTATE;



     FOLDERSettings = Packed Record 
                        ViewMode : UINT;       // View mode (FOLDERVIEWMODE values)
                        fFlags   : UINT;       // View options (FOLDERFLAGS bits)
                      end;
     TFOLDERSettings = FOLDERSettings;
     PFOLDERSettings = ^FOLDERSettings;
     LPFOLDERSettings= PFOLDERSettings;
     LPCFOLDERSettings= LPFOLDERSettings;
     PSV2CVW2_PARAMS = ^TSV2CVW2_PARAMS; 
     TSV2CVW2_PARAMS = packed record  // actually  <pshpack8.h>")
          cbSize    : DWORD;
          psvPrev   : IShellView;
          pfs       : LPCFOLDERSETTINGS;
          psbOwner  : IShellBrowser;
          prcView   : PRECT;
          pvid      : PSHELLVIEWID;
          hwndView  : HWND;
       end;
     LPSV2CVW2_PARAMS = PSV2CVW2_PARAMS;
      _SHELLDETAILS        =  record
                               fmt,
                               cxChar    : longint;
                               str       : TSTRRET;
                               end;
      TShellDetails        =  _SHELLDETAILS;
      SHELLDETAILS         =  _SHELLDETAILS;
      PShellDetails        =  ^TShellDetails;
      LPSHELLDETAILS       = PSHELLDETAILS;

      TShellDetailsEx      =  record
         Index:            UINT;
         Detail:           TShellDetails;
      end;
      tagEXTRASEARCH = packed record
                              guidSearch :     TGUID;
                              wszFriendlyName : array[0..80-1] of WideChar;
                              wszUrl : array[0..2084-1] of WideChar;
                             end;
      EXTRASEARCH  = TagEXTRASEARCH;
      TEXTRASEARCH  = TagEXTRASEARCH;
      LPEXTRASEARCH = ^EXTRASEARCH;
      PEXTRASEARCH  = ^EXTRASEARCH;

      SHCOLSTATEF = DWORD;
      PSHCOLSTATEF = ^SHCOLSTATEF;
      TSHCOLSTATEF = SHCOLSTATEF;

      PLPITEMIDLIST = ^LPITEMIDLIST;

     PROPPRG = record
          flPrg : WORD;
          flPrgInit : WORD;
          achTitle : array[0..(PIFNAMESIZE)-1] of CHAR;
          achCmdLine : array[0..((PIFSTARTLOCSIZE+PIFPARAMSSIZE)+1)-1] of CHAR;
          achWorkDir : array[0..(PIFDEFPATHSIZE)-1] of CHAR;
          wHotKey : WORD;
          achIconFile : array[0..(PIFDEFFILESIZE)-1] of CHAR;
          wIconIndex : WORD;
          dwEnhModeFlags : DWORD;
          dwRealModeFlags : DWORD;
          achOtherFile : array[0..(PIFDEFFILESIZE)-1] of CHAR;
          achPIFFile : array[0..(PIFMAXFILEPATH)-1] of CHAR;
       end;
     TPROPPRG = PROPPRG;
     PPPROPPRG = ^PPROPPRG;
     PPROPPRG = PROPPRG;

     PLPPROPPRG = ^LPPROPPRG;
     LPPROPPRG = PROPPRG;

     PLPCPROPPRG = ^LPCPROPPRG;
     LPCPROPPRG = PROPPRG;

     _QCMINFO_IDMAP_PLACEMENT = record
          id : UINT;
          fFlags : UINT;
       end;
     QCMINFO_IDMAP_PLACEMENT = _QCMINFO_IDMAP_PLACEMENT;
     TQCMINFO_IDMAP_PLACEMENT = _QCMINFO_IDMAP_PLACEMENT;
     PQCMINFO_IDMAP_PLACEMENT = ^QCMINFO_IDMAP_PLACEMENT;

     PQCMINFO_IDMAP = ^_QCMINFO_IDMAP;
     _QCMINFO_IDMAP = record
          nMaxIds : UINT;
          pIdList : array[0..0] of QCMINFO_IDMAP_PLACEMENT;
       end;
     QCMINFO_IDMAP = _QCMINFO_IDMAP;
     TQCMINFO_IDMAP = _QCMINFO_IDMAP;

     _QCMINFO = record
          hmenu : HMENU;
          indexMenu : UINT;
          idCmdFirst : UINT;
          idCmdLast : UINT;
          pIdMap : PQCMINFO_IDMAP;
       end;
     QCMINFO  = _QCMINFO;
     TQCMINFO = _QCMINFO;
     PQCMINFO = ^QCMINFO;

     PLPQCMINFO = ^LPQCMINFO;
     LPQCMINFO = QCMINFO;

     _TBINFO = record
          cbuttons : UINT;
          uFlags : UINT;
       end;
     TBINFO = _TBINFO;
     TTBINFO = _TBINFO;
     PTBINFO = ^TBINFO;

     _DETAILSINFO = record
          pidl : LPCITEMIDLIST;
          fmt : longint;
          cxChar : longint;
          str : STRRET;
          iImage : longint;
       end;
     DETAILSINFO = _DETAILSINFO;
     TDETAILSINFO = _DETAILSINFO;
     PDETAILSINFO = ^DETAILSINFO;

     _SFVM_PROPPAGE_DATA = record
          dwReserved : DWORD;
          pfn : LPFNADDPROPSHEETPAGE;
          lParam : LPARAM;
       end;
     SFVM_PROPPAGE_DATA = _SFVM_PROPPAGE_DATA;
     TSFVM_PROPPAGE_DATA = _SFVM_PROPPAGE_DATA;
     PSFVM_PROPPAGE_DATA = ^SFVM_PROPPAGE_DATA;

     _SFVM_HELPTOPIC_DATA = record
          wszHelpFile : array[0..(MAX_PATH)-1] of WCHAR;
          wszHelpTopic : array[0..(MAX_PATH)-1] of WCHAR;
       end;
     SFVM_HELPTOPIC_DATA = _SFVM_HELPTOPIC_DATA;
     TSFVM_HELPTOPIC_DATA = _SFVM_HELPTOPIC_DATA;
     PSFVM_HELPTOPIC_DATA = ^SFVM_HELPTOPIC_DATA;

     _SFV_CREATE = record
          cbSize : UINT;
          pshf : IShellFolder;
          psvOuter : IShellView;
          psfvcb : IShellFolderViewCB;
       end;
     SFV_CREATE = _SFV_CREATE;
     TSFV_CREATE = _SFV_CREATE;
     PSFV_CREATE = ^SFV_CREATE;

     _CSFV = record
          cbSize : UINT;
          pshf : IShellFolder;
          psvOuter : IShellView;
          pidl : LPCITEMIDLIST;
          lEvents : LONG;
          pfnCallback : LPFNVIEWCALLBACK;
          fvm : FOLDERVIEWMODE;
       end;
     CSFV = _CSFV;
     TCSFV = _CSFV;
     PCSFV = ^CSFV;
     LPCSFV = PCSFV;
     PLPCSFV = ^LPCSFV;

     _SFV_SETITEMPOS = record
          pidl : LPCITEMIDLIST;
          pt : POINT;
       end;
     SFV_SETITEMPOS = _SFV_SETITEMPOS;
     TSFV_SETITEMPOS = _SFV_SETITEMPOS;
     PSFV_SETITEMPOS = ^SFV_SETITEMPOS;
     LPSFV_SETITEMPOS = PSFV_SETITEMPOS;
     PLPSFV_SETITEMPOS = ^LPSFV_SETITEMPOS;

     PSHELLSTATEA = ^SHELLSTATEA;
     SHELLSTATEA = record
          flag0 : longint;                   { No longer used, dead bit }
          dwWin95Unused : DWORD;             { Win95 only - no longer supported pszHiddenFileExts }
          uWin95Unused : UINT;               { Win95 only - no longer supported cbHiddenFileExts }
          lParamSort : LONG;                 { Note: Not a typo!  This is a persisted structure so we cannot use LPARAM }
          iSortDirection : longint;          { new for win2k. need notUsed var to calc the right size of ie4 struct }
          version : UINT;                    { FIELD_OFFSET does not work on bit fields }
          uNotUsed : UINT;                   { feel free to rename and use }
          flag1 : word;                      { new for Whistler. }
       end;                                  {Indicates if the Whistler StartPanel mode is ON or OFF. }
     LPSHELLSTATEA = PSHELLSTATEA;           {Indicates if the Whistler StartPage on desktop is ON or OFF. }
     PLPSHELLSTATEA = ^LPSHELLSTATEA;
     TSHELLSTATEA = SHELLSTATEA;
     LPSHELLSTATE = LPSHELLSTATEA;

     PSHELLSTATEW = ^SHELLSTATEW;
     SHELLSTATEW = record
          flag0 : longint;             { Win95 only - no longer supported pszHiddenFileExts }
          dwWin95Unused : DWORD;       { Win95 only - no longer supported cbHiddenFileExts }
          uWin95Unused : UINT;         { Note: Not a typo!  This is a persisted structure so we cannot use LPARAM }
          lParamSort : LONG;           { new for win2k. need notUsed var to calc the right size of ie4 struct }
          iSortDirection : longint;    { FIELD_OFFSET does not work on bit fields }
          version : UINT;              { feel free to rename and use }
          uNotUsed : UINT;             { new for Whistler. }
          flag1 : word;                {Indicates if the Whistler StartPage mode is ON or OFF. }
       end;                            {Indicates if the Whistler StartPage on desktop is ON or OFF. }
     LPSHELLSTATEW = PSHELLSTATEW;     { If you need a new flag, steal a bit from from fSpareFlags. }
     PLPSHELLSTATEW = ^LPSHELLSTATEW;
     TSHELLSTATE = SHELLSTATEW;

     PSHELLFLAGSTATE = ^SHELLFLAGSTATE;
     SHELLFLAGSTATE = record
          flag0 : word;
       end;
     LPSHELLFLAGSTATE = PSHELLFLAGSTATE;
     PLPSHELLFLAGSTATE = ^LPSHELLFLAGSTATE;
     TSHELLFLAGSTATE = SHELLFLAGSTATE;

     PtagAAMENUFILENAME = ^tagAAMENUFILENAME;
     tagAAMENUFILENAME = record
          cbTotal : SHORT;
          rgbReserved : array[0..11] of BYTE;
          szFileName : array[0..0] of WCHAR;
       end;
     AASHELLMENUFILENAME = tagAAMENUFILENAME;
     TAASHELLMENUFILENAME = tagAAMENUFILENAME;
     PAASHELLMENUFILENAME = ^AASHELLMENUFILENAME;
     LPAASHELLMENUFILENAME = PtagAAMENUFILENAME;
     PLPAASHELLMENUFILENAME = ^LPAASHELLMENUFILENAME;


     PtagAASHELLMENUITEM = ^tagAASHELLMENUITEM;
     tagAASHELLMENUITEM = record
          lpReserved1 : pointer;
          iReserved : longint;
          uiReserved : UINT;
          lpName : LPAASHELLMENUFILENAME;    { name of file }
          psz : LPWSTR;  	  	    { text to use if no file }
       end;
     AASHELLMENUITEM = tagAASHELLMENUITEM;
     TAASHELLMENUITEM = tagAASHELLMENUITEM;
     PAASHELLMENUITEM = ^AASHELLMENUITEM;
     LPAASHELLMENUITEM = PtagAASHELLMENUITEM;
     PLPAASHELLMENUITEM = ^LPAASHELLMENUITEM;


   IPersistFolder = Interface(IPersist)
        ['{000214EA-0000-0000-C000-000000000046}']
        function Initialize (pild : LPCITEMIDLIST): HResult; StdCall;
    end;

   IPersistFolder2 = Interface(IPersistFolder)
        ['{1AC3D9F0-175C-11d1-95BE-00609797EA4F}']
        function GetCurFolder(Out ppidl : LPITEMIDLIST):HResult; StdCall;
       end;

   IPersistIDList = Interface(IPersist)
        ['{1079acfc-29bd-11d3-8e0d-00c04f6837d5}']
         function SetIdList(pid:LPCITEMIDLIST):HResult;StdCall; 
        function GetIdList(out pid:LPCITEMIDLIST):HResult;StdCall;
        end;

   IEnumIDList = interface(IUnknown)
        ['{000214F2-0000-0000-C000-000000000046}']
        function Next(celt: ULONG; out rgelt: PItemIDList; var pceltFetched: ULONG): HRESULT; stdcall;
        function Skip(celt: ULONG): HRESULT; stdcall; function Reset: HRESULT; stdcall;
        function Clone(out ppenum: IEnumIDList): HRESULT; stdcall;
      end;

   IEnumExtraSearch = Interface(IUnknown)
       ['{0E700BE1-9DB6-11d1-A1CE-00C04FD75D13}']
       function Next(celt: ULONG; out rgelt: EXTRASEARCH; var pceltFetched: ULONG): HRESULT; stdcall;
       function Skip(celt: ULONG): HRESULT; stdcall; function Reset: HRESULT; stdcall;
       function Clone(out ppenum: IEnumExtraSearch): HRESULT; stdcall;
      end;
    
   IShellFolder = interface(IUnknown)
        ['{000214E6-0000-0000-C000-000000000046}']
        function ParseDisplayName(hwndOwner: HWND; pbcReserved: Pointer; lpszDisplayName: POLESTR; out pchEaten: ULONG; out ppidl: PItemIDList; var dwAttributes: ULONG): HRESULT; stdcall;
        function EnumObjects(hwndOwner: HWND; grfFlags: DWORD; out EnumIDList: IEnumIDList): HRESULT; stdcall;
        function BindToObject(pidl: PItemIDList; pbcReserved: Pointer; const riid: TIID; out ppvOut): HRESULT; stdcall;
        function BindToStorage(pidl: PItemIDList; pbcReserved: Pointer; const riid: TIID; out ppvObj): HRESULT; stdcall;
        function CompareIDs(lParam: LPARAM; pidl1, pidl2: PItemIDList): HRESULT; stdcall;
        function CreateViewObject(hwndOwner: HWND; const riid: TIID; out ppvOut): HRESULT; stdcall;
        function GetAttributesOf(cidl: UINT; var apidl: PItemIDList; var rgfInOut: UINT): HRESULT; stdcall;
        function GetUIObjectOf(hwndOwner: HWND; cidl: UINT; var apidl: PItemIDList; const riid: TIID; prgfInOut: Pointer; out ppvOut): HRESULT; stdcall;
        function GetDisplayNameOf(pidl: PItemIDList; uFlags: DWORD; var lpName: TStrRet): HRESULT; stdcall;
        function SetNameOf(hwndOwner: HWND; pidl: PItemIDList; lpszName: POLEStr; uFlags: DWORD; var ppidlOut: PItemIDList): HRESULT; stdcall;
      end;

   IShellFolder2 = interface(IShellFolder)
     ['{93F2F68C-1D1B-11d3-A30E-00C04F79ABD1}']
      function GetDefaultSearchGUID(out guid:TGUID):HResult;StdCall;
      function EnumSearches(out ppenum:IEnumExtraSearch):HResult;StdCall;    
      function GetDefaultColumn(dwres:DWORD;psort :pulong; pdisplay:pulong):HResult;StdCall;   
      function GetDefaultColumnStart(icolumn:UINT;pscflag:PSHCOLSTATEF):HResult;StdCall;   
      function GetDetailsEx(pidl:LPCITEMIDLIST;pscid:PSHCOLUMNID; pv : pOLEvariant):HResult;StdCall;   
      function GetDetailsOf(pidl:LPCITEMIDLIST;iColumn:UINT;psd:PSHELLDETAILS):HResult;StdCall;   
      function MapColumnToSCID(iColumn:UINT;pscid:PSHCOLUMNID):HResult;StdCall;   
     end;

   IAutoComplete = interface(IUnknown)
        ['{00bb2762-6a77-11d0-a535-00c04fd7d062}']
        function Init(hwndEdit: HWND; punkACL: IUnknown; pwszRegKeyPath: LPCWSTR; pwszQuickComplete: LPCWSTR): HRESULT; stdcall;
        function Enable(fEnable: BOOL): HRESULT; stdcall;
      end;

  IShellView    = Interface(IOleWindow)
         ['{000214E3-0000-0000-C000-000000000046}']
         function TranslateAccelerator( pm :PMSG):HResult; StdCall;
         function EnableModeless(fEnable : BOOL):HResult; StdCall;
         function UIActivate(uState:UINT):HResult; StdCall;
         function Refresh:HResult; StdCall;
         function CreateViewWindow(psvPrevious:IShellView;pfs:LPCFOLDERSETTINGS;psb:IShellBrowser;prcview:prect;var ph:HWND):HResult;StdCall;
         function DestroyViewWindow:HResult; StdCall;        
         function GetCurrentInfo(pfs: LPFOLDERSETTINGS):HResult; StdCall;     
         function AddPropertySheetPages(dwreserved : DWORD;pfn:pointer{LPFNSVADDPROPSHEETPAGE};lp:lparam):HResult; StdCall;     
         function SaveViewState:HResult; StdCall;       
         function SelectItem( pidlItem: LPCITEMIDLIST;uflags:TSVSIF):HResult; StdCall;       
         function GetItemObject(uitem:UINT;const riid:TGUID;out ppv :PPOinter):HResult;StdCall;
       end;

  IShellView2    = Interface(IShellView)
         ['{88E39E80-3578-11CF-AE69-08002B2E1262}']
         function GetView(var pvid:TSHELLVIEWID ;uview:ULONG):HResult;StdCall;
         function CreateViewWindow2(lpParams:LPSV2CVW2_PARAMS):HResult;StdCall;
         function HandleRename(pidlNew: LPCITEMIDLIST ):HResult;StdCall;
         function SelectAndPositionItem(pidlItem:LPCITEMIDLIST ;uflags:UINT;ppt:PPOINT):HRESULT;STDCALL;
         end;

   IFolderView = Interface(IUnknown)
        ['{cde725b0-ccc9-4519-917e-325d72fab4ce}']
        function GetCurrentViewMode(pViewMode:PUINT):HResult; StdCall;       
        function SetCurrentViewMode(ViewMode:UINT):HResult; StdCall;       
        function GetFolder(const riid:TGUID;ppv:pointer):HResult; StdCall;       
        function Item(iItemIndex:longint;ppidl:LPITEMIDLIST):HResult; StdCall;       
        function ItemCount(uflags:uint;pcitems:plongint):HResult; StdCall;       
        function Items (uflags:uint;const id :TGUID;out ppv: pointer):HResult; StdCall;       
        function GetSelectionMarkedItem(piItem:pint):HResult; StdCall;       
        function GetFocussedItem(piItem:pint):HResult; StdCall;       
        function GetItemPosition(pidl:LPCITEMIDLIST;ppt:PPOINT):HResult; StdCall;       
        function GetSpacing(ppt:ppoint):HResult; StdCall;       
        function GetDefaultSpacing(ppt:ppoint):HResult; StdCall;       
        function GetAutoArrange:HResult; StdCall;       
        function SelectItem(iItem : longint;dwflags:Dword) :HResult; StdCall;       
        function SelectAndPositionItems(cild:uint;var apid: LPCITEMIDLIST   ;apt:PPOINT;dwflags:DWord):HResult; StdCall;       
       end;           
    IFolderFilterSite = Interface(IUnknown)
          ['{C0A651F5-B48B-11d2-B5ED-006097C686F6}']
          function SetFilter(punk:IUnknown):HResult; StdCall;
          end;
    IFolderFilter = Interface(IUnknown)
          ['{9CC22886-DC8E-11d2-B1D0-00C04F8EEB3E}']
          function ShouldShow(Psf:IShellFolder;pidlfolder:LPCITEMIDLIST;pidlItem:LPCITEMIDLIST):HResult; StdCall;
          function GetEnumFlags(Psf:IShellFolder;pidlfolder:LPCITEMIDLIST;var hwnd: hwnd;out pgrfflags:DWORD):HResult; StdCall;
          end;

//cpp_quote("#include <commctrl.h>")
//cpp_quote("typedef LPTBBUTTON LPTBBUTTONSB;")

    IShellBrowser = interface(IOleWindow)
          ['{000214E2-0000-0000-C000-000000000046}']
    function InsertMenusSB(hmenuShared: HMenu; var menuWidths: TOleMenuGroupWidths): HResult;StdCall;
    function SetMenuSB(hmenuShared: HMenu; holemenu: HOLEMenu; hwndActiveObject: HWnd): HResult;StdCall;
    function RemoveMenusSB(hmenuShared: HMenu): HResult;StdCall;
    function SetStatusTextSB(pszStatusText: POleStr): HResult;StdCall;
    function EnableModelessSB(fEnable: BOOL): HResult;StdCall;
    function TranslateAcceleratorSB(var msg: TMsg; wID: Word): HResult;StdCall;
    function BrowseObject(pidl:LPCITEMIDLIST;wFlags:UINT): HResult;StdCall;
    function GetViewStateStream(grfMode :DWORD; out ppstrm :IStream): HResult;StdCall;
    function GetControlWindow(id:UINT;var h:HWND): HResult;StdCall;
    function SendCOntrolMsg(id:uint;umsg:UINT;wparam:wparam;lparam:lparam;pret:PLRESULT): HResult;StdCall;
    function QueryActiveShellView(out ppsh :IShellView): HResult;StdCall;
    function OnViewWindowActive(psh :IShellView): HResult;StdCall;
    function SetToolBarItems(lpButtons:LPTBBUTTONSB;nButtons:UINT;uFlags:uint): HResult;StdCall;
    end;         

    const
      CLSID_AutoComplete: TGUID = '{00BB2763-6A77-11D0-A535-00C04FD7D062}';

    const
      { IAutoComplete2 options }
      ACO_NONE           = 0;
      ACO_AUTOSUGGEST    = $1;
      ACO_AUTOAPPEND     = $2;
      ACO_SEARCH         = $4;
      ACO_FILTERPREFIXES = $8;
      ACO_USETAB         = $10;
      ACO_UPDOWNKEYDROPSLIST = $20;
      ACO_RTLREADING     = $40;

    type
      IAutoComplete2 = interface(IAutoComplete)
        ['{EAC04BC0-3791-11d2-BB95-0060977B464C}']
        function SetOptions(dwFlag: DWORD): HRESULT; stdcall;
        function GetOptions(var dwFlag: DWORD): HRESULT; stdcall;
      end;

     PCMINVOKECOMMANDINFO = ^TCMINVOKECOMMANDINFO;
     TCMINVOKECOMMANDINFO = packed record
          cbSize : DWORD;
          fMask  : DWORD;
          hwnd   : HWND;
          lpVerb : LPCSTR;
          lpParameters : LPCSTR;
          lpDirectory : LPCSTR;
          nShow  :  longint;
          dwHotKey: DWORD;
          hIcon  : THANDLE;
       end;
     LPCMINVOKECOMMANDINFO = PCMINVOKECOMMANDINFO;

    IContextMenu = interface(IUnknown)
         ['{000214E4-0000-0000-c000-000000000046}']
         function QueryContextMenu(hmenu:HMENU;indexMenu:UINT;idCmdFirst:UINT;idCmdLast:UINT;UFlags:uint):HRESULT;StdCall;
         function InvokeCommand(var lpici : TCMINVOKECOMMANDINFO):HResult; StdCall;         
         function GetCommandString(idcmd:UINT_Ptr;uType:UINT;pwreserved:puint;pszName:LPStr;cchMax:uint):HResult;StdCall;
       end;
    IContextMenu2 = interface(IContextMenu)
         ['{000214f4-0000-0000-c000-000000000046}']
         function HandleMenuMsg(uMsg:UINT;wParam:WPARAM;lParam:WPARAM):HResult;StdCall;
         end;
    IContextMenu3 = interface(IContextMenu2)
         ['{bcfce0a0-ec17-11d0-8d10-00a0c90f2719}']
         function HandleMenuMsg2(uMsg:UINT;wParam:WPARAM;lParam:WPARAM;presult:PLRESULT):HResult;StdCall;
         end;
    IEXtractIconA = interface(IUNknown)
         ['{000214eb-0000-0000-c000-000000000046}']
         function GetIconLocation(uFlags:UINT;szIconFIle:LPSTR;cchMax:UINT;var piIndex : longint; var pwflags:uint):HResult;StdCall;
         function Extract(pszFile:LPCStr;nIconIndex:UINT;var phiconLarge:HICON;var phiconSmall:HICON;nIconSize:UINT):HResult;StdCall;
         end;

    IEXtractIconW = interface(IUNknown)
         ['{000214fa-0000-0000-c000-000000000046}']
         function GetIconLocation(uFlags:UINT;szIconFIle:LPWSTR;cchMax:UINT;var piIndex : longint; var pwflags:uint):HResult;StdCall;
         function Extract(pszFile:LPCWStr;nIconIndex:UINT;var phiconLarge:HICON;var hiconSmall:HICON;nIconSize:UINT):HResult;StdCall;
         end;
    IEXtractIcon=IExtractIconA;

    SPINITF = DWORD;
    EXPPS = UINT;

    IProfferService = interface (IUnknown)
        ['{cb728b20-f786-11ce-92ad-00aa00a74cd0}']
        function ProfferService(const guid:TGUID;psp:IServiceProvider;var pdwcookie:DWORD):HRESULT;StdCall;
        function RevokeService(dwCookie:DWORD):HRESULT;StdCall;
        end;
{
    IPropertyUI = interface(IUnknown)
        ['{757a7d9f-919a-4118-99d7-dbb208c8cc66}']
        function ParsePropertyName(pszName:LPCWSTR; pfmtid:pFMTID; ppid:pPROPID; pchEaten:pULONG):HRESULT;StdCall;
        function GetCannonicalName(const fmtid:FMTID; pid:PROPID; pwszText:LPWSTR; cchText:DWORD):HRESULT;StdCall;
        function GetDisplayName(const fmtid:FMTID; pid:PROPID; flags:PROPERTYUI_NAME_FLAGS; pwszText:LPWSTR; cchText:DWORD):HRESULT;StdCall;
        function GetPropertyDescription(const fmtid:FMTID; pid:PROPID; pwszText:LPWSTR; cchText:DWORD):HRESULT;StdCall;
        function GetDefaultWidth(const fmtid:FMTID; pid:PROPID; pcxChars:pULONG):HRESULT;StdCall;
        function GetFlags(const fmtid:FMTID; pid:PROPID; pFlags:pPROPERTYUI_FLAGS):HRESULT;StdCall;
        function FormatForDisplay(const fmtid:FMTID; pid:PROPID; pvar:pPROPVARIANT; flags:PROPERTYUI_FORMAT_FLAGS;wszText:LPWSTR;cchText:DWORD):HRESULT;StdCall;
        function GetHelpInfo(const fmtid:FMTID; pid:PROPID; pwszHelpFile:LPWSTR; cch:DWORD; puHelpID:pUINT):HRESULT;StdCall;   
        end;
}
    ICategoryProvider =interface(IUnknown)
        ['{9af64809-5864-4c26-a720-c1f78c086ee3}']
        function CanCategorizeOnSCID(pscid:pSHCOLUMNID):HRESULT;StdCall;
        function GetDefaultCategory(pguid:pGUID; pscid:pSHCOLUMNID):HRESULT;StdCall;
        function GetCategoryForSCID(pscid:pSHCOLUMNID; pguid:pGUID):HRESULT;StdCall;
        function EnumCategories(out penum:IEnumGUID):HRESULT;StdCall;
        function GetCategoryName(pguid:pGUID; pszName:LPWSTR; cch:UINT):HRESULT;StdCall;
        function CreateCategory(pguid:pGUID; riid:REFIID; ppv:Ppointer):HRESULT;StdCall;
        end;

    ICategorizer =Interface(IUnknown)
        ['{a3b14589-9174-49a8-89a3-06a1ae2b9ba7}']
        function GetDescription(pszDesc:LPWSTR; cch:UINT):HRESULT;StdCall;
        function GetCategory(cidl:UINT; var apidl:LPCITEMIDLIST; rgCategoryIds:pDWORD):HRESULT;StdCall;
        function GetCategoryInfo(dwCategoryId:DWORD; pci:pCATEGORY_INFO):HRESULT;StdCall;
        function CompareCategory(csfFlags:CATSORT_FLAGS; dwCategoryId1:DWORD; dwCategoryId2:DWORD):HRESULT;StdCall;
        end;

   IQueryInfo = Interface(IUnknown)
        ['{00021500-0000-0000-c000-000000000046}']
        function GetInfoTip (dwFlags:DWord;var pwsztip:pwchar):HResult;StdCall;
        function GetInfoFlags (var dwflags:dword):HResult;Stdcall;
        end;
 
    IShellLinkA  = Interface(IUnknown)
        ['{000214EE-0000-0000-C000-000000000046}']
        function GetPath(pszFile:LPSTR; cch:longint;var  pfd:WIN32_FIND_DATA; fFlags:DWORD):HRESULT;StdCall;
        function GetIDList(var ppidl:LPITEMIDLIST):HRESULT;StdCall;
        function SetIDList(pidl:LPCITEMIDLIST):HRESULT;StdCall;
        function GetDescription(pszName:LPSTR; cch:longint):HRESULT;StdCall;
        function SetDescription(pszName:LPCSTR):HRESULT;StdCall;
        function GetWorkingDirectory(pszDir:LPSTR; cch:longint):HRESULT;StdCall;
        function SetWorkingDirectory(pszDir:LPCSTR):HRESULT;StdCall;
        function GetArguments(pszArgs:LPSTR; cch:longint):HRESULT;StdCall;
        function SetArguments(pszArgs:LPCSTR):HRESULT;StdCall;
        function GetHotkey(var pwHotkey:WORD):HRESULT;StdCall;
        function SetHotkey(wHotkey:WORD):HRESULT;StdCall;
        function GetShowCmd(var piShowCmd:longint):HRESULT;StdCall;
        function SetShowCmd(iShowCmd:longint):HRESULT;StdCall;
        function GetIconLocation(pszIconPath:LPSTR; cch:longint;var iIcon:longint):HRESULT;StdCall;
        function SetIconLocation(pszIconPath:LPCSTR; iIcon:longint):HRESULT;StdCall;
        function SetRelativePath(pszPathRel:LPCSTR; dwReserved:DWORD):HRESULT;StdCall;
        function Resolve(hwnd:HWND; fFlags:DWORD):HRESULT;StdCall;
        function SetPath(pszFile:LPCSTR):HRESULT;StdCall;
        end; 
 
    IShellLinkW = interface (IUnknown)
        ['{000214F9-0000-0000-C000-000000000046}']
        function GetPath(pszFile:LPWSTR; cch:longint; pfd:pWIN32_FIND_DATAW; fFlags:DWORD):HRESULT;StdCall;
        function GetIDList(ppidl:pLPITEMIDLIST):HRESULT;StdCall;
        function SetIDList(pidl:LPCITEMIDLIST):HRESULT;StdCall;
        function GetDescription(pszName:LPWSTR; cch:longint):HRESULT;StdCall;
        function SetDescription(pszName:LPCWSTR):HRESULT;StdCall;
        function GetWorkingDirectory(pszDir:LPWSTR; cch:longint):HRESULT;StdCall;
        function SetWorkingDirectory(pszDir:LPCWSTR):HRESULT;StdCall;
        function GetArguments(pszArgs:LPWSTR; cch:longint):HRESULT;StdCall;
        function SetArguments(pszArgs:LPCWSTR):HRESULT;StdCall;
        function GetHotkey(pwHotkey:pWORD):HRESULT;StdCall;
        function SetHotkey(wHotkey:WORD):HRESULT;StdCall;
        function GetShowCmd(piShowCmd:plongint):HRESULT;StdCall;
        function SetShowCmd(iShowCmd:longint):HRESULT;StdCall;
        function GetIconLocation(pszIconPath:LPWSTR; cch:longint; piIcon:plongint):HRESULT;StdCall;
        function SetIconLocation(pszIconPath:LPCWSTR; iIcon:longint):HRESULT;StdCall;
        function SetRelativePath(pszPathRel:LPCWSTR; dwReserved:DWORD):HRESULT;StdCall;
        function Resolve(hwnd:HWND; fFlags:DWORD):HRESULT;StdCall;
        function SetPath(pszFile:LPCWSTR):HRESULT;StdCall;
        end;
     IShellLink = IShellLinkA;

function SHGetMalloc(out ppmalloc: IMalloc):HResult;StdCall; external 'shell32' name 'SHGetMalloc';
function SHGetDesktopFolder(out ppshf:IShellFolder):HResult;StdCall; external 'shell32' name 'SHGetDesktopFolder';

function  SHOpenFolderAndSelectItems(pidlFolder:LPCITEMIDLIST;cidl:UINT;var  apidl: LPCITEMIDLIST; dwflags: DWORD):HResult;StdCall; external 'shell32' name 'SHOpenFolderAndSelectItems';
//function  SHCreateShellItem( pidlParent:LPCITEMIDLIST; psfparent:IShellFolder; pidl: LPCITEMIDLIST pidl; out ppsi: IShellItem):HResult;StdCall; external 'shell32' name 'SHCreateShellItem';
function  SHGetSpecialFolderLocation( hwnd:HWND; csidl:longint;out ppidl: LPITEMIDLIST):HResult;StdCall; external 'shell32' name 'SHGetSpecialFolderLocation';
procedure SHFlushSFCache;StdCall; external 'shell32' name 'SHFlushSFCache';
function  SHCloneSpecialIDList(HWND:hwnd; csidl:longint;fcreate:BOOL):LPITEMIDLIST; StdCall; external 'shell32' name 'SHCloneSpecialIDList';
function  SHGetSpecialFolderPathA(HWND:hwnd;pszpath: LPSTR; csidl:Longint;fcreate:bool):bool;StdCall; external 'shell32' name 'SHGetSpecialFolderPathA';
function  SHGetSpecialFolderPath(HWND:hwnd;pszpath: LPSTR; csidl:Longint;fcreate:bool):bool;StdCall; external 'shell32' name 'SHGetSpecialFolderPathA';
function  SHGetSpecialFolderPathW(HWND:hwnd;pszpath: LPWSTR; csidl:Longint;fcreate:bool):bool;StdCall; external 'shell32' name 'SHGetSpecialFolderPathA';
function  SHGetFolderPathA(HWND:hwnd;csidl:longint;htoken:THandle;dwflags:dword;pszpath:lpstr):HResult;StdCall; external 'shell32' name 'SHGetFolderPathA';
function  SHGetFolderPath(HWND:hwnd;csidl:longint;htoken:THandle;dwflags:dword;pszpath:lpstr):HResult;StdCall; external 'shell32' name 'SHGetFolderPathA';
function  SHGetFolderPathW(HWND:hwnd;csidl:longint;htoken:THandle;dwflags:dword;pszpath:lpWstr):HResult;StdCall; external 'shell32' name 'SHGetFolderPathW';
function  SHGetFolderPathAndSubDirA(HWND:hwnd;csidl:longint;htoken:THandle;dwflags:dword;pszsubdir:LPCStr;pszpath:lpstr):HResult;StdCall; external 'shell32' name 'SHGetFolderPathAndSubDirA';
function  SHGetFolderPathAndSubDir(HWND:hwnd;csidl:longint;htoken:THandle;dwflags:dword;pszsubdir:LPCStr;pszpath:lpstr):HResult;StdCall; external 'shell32' name 'SHGetFolderPathAndSubDirA';
function  SHGetFolderPathAndSubDirW(HWND:hwnd;csidl:longint;htoken:THandle;dwflags:dword;pszsubdir:LPCWStr;pszpath:lpWstr):HResult; external 'shell32' name 'SHGetFolderPathAndSubDirW';
function  SHFolderLocation(HWND:hwnd;csidl:longint;htoken:THandle;dwflags:dword;var ppidl:LPITEMIDLIST):HRESULT;StdCall; external 'shell32' name 'SHFolderLocation';


Const External_Library = 'shell32';

  function SHAlloc(cb:SIZE_T):pointer;StdCall;external External_library name 'SHAlloc';
  procedure SHFree(pv:pointer);StdCall;external External_library name 'SHFree';
  function SHGetIconOverlayIndexA(pszIconPath:lpcstr; iIconIndex:Longint):Longint;StdCall;external External_library name 'SHGetIconOverlayIndexA';
  function SHGetIconOverlayIndexW(pszIconPath:lpcwstr; iIconIndex:Longint):Longint;StdCall;external External_library name 'SHGetIconOverlayIndexW';
  function SHGetPathFromIDListA(pidl:LPCITEMIDLIST; pszPath:LPStr):BOOL;StdCall;external External_library name 'SHGetPathFromIDListA';
  function SHGetPathFromIDListW(pidl:LPCITEMIDLIST; pszPath:LPWStr):BOOL;StdCall;external External_library name 'SHGetPathFromIDListW';
  function SHCreateDirectory(hwnd:HWND; pszPath:lpcwstr):Longint;StdCall;external External_library name 'SHCreateDirectory';
  function SHCreateDirectoryExA(hwnd:HWND; pszPath:lpcstr; psa:LPSECURITY_ATTRIBUTES):Longint;StdCall;external External_library name 'SHCreateDirectoryExA';
  function SHCreateDirectoryExW(hwnd:HWND; pszPath:lpcwstr; psa:LPSECURITY_ATTRIBUTES):Longint;StdCall;external External_library name 'SHCreateDirectoryExW';
{
  function SHOpenFolderAndSelectItems(pidlFolder:LPCITEMIDLIST; cidl:UINT; var apidl:LPCITEMIDLIST; dwFlags:DWord):HRESULT;StdCall;external External_library name 'SHOpenFolderAndSelectItems';
  function SHCreateShellItem(pidlParent:LPCITEMIDLIST; psfParent:IShellFolder; pidl:LPCITEMIDLIST;out ppsi:IShellItem):HRESULT;StdCall;external External_library name 'SHCreateShellItem';
  function SHGetSpecialFolderLocation(hwnd:HWND; csidl:Longint; var ppidl:LPITEMIDLIST):HRESULT;StdCall;external External_library name 'SHGetSpecialFolderLocation';
  procedure SHFlushSFCache;StdCall;external External_library name 'SHFlushSFCache';
  function SHCloneSpecialIDList(hwnd:HWND; csidl:Longint; fCreate:BOOL):LPITEMIDLIST;StdCall;external External_library name 'SHCloneSpecialIDList';
  function SHGetSpecialFolderPathA(hwnd:HWND; pszPath:LPStr; csidl:Longint; fCreate:BOOL):BOOL;StdCall;external External_library name 'SHGetSpecialFolderPathA';
  function SHGetSpecialFolderPathW(hwnd:HWND; pszPath:LPWStr; csidl:Longint; fCreate:BOOL):BOOL;StdCall;external External_library name 'SHGetSpecialFolderPathW';
  function SHGetFolderLocation(hwnd:HWND; csidl:Longint; hToken:THANDLE; dwFlags:DWord;var ppidl:LPITEMIDLIST):HRESULT;StdCall;external External_library name 'SHGetFolderLocation';
}
  function SHGetSetFolderCustomSettingsA(pfcs:LPSHFOLDERCUSTOMSETTINGSA; pszPath:lpcstr; dwReadWrite:DWord):HRESULT;StdCall;external External_library name 'SHGetSetFolderCustomSettingsA';
  function SHGetSetFolderCustomSettingsW(pfcs:LPSHFOLDERCUSTOMSETTINGSW; pszPath:lpcwstr; dwReadWrite:DWord):HRESULT;StdCall;external External_library name 'SHGetSetFolderCustomSettingsW';
  function SHBrowseForFolderA(lpbi:LPBROWSEINFOA):LPITEMIDLIST;StdCall;external External_library name 'SHBrowseForFolderA';
  function SHBrowseForFolderW(lpbi:LPBROWSEINFOW):LPITEMIDLIST;StdCall;external External_library name 'SHBrowseForFolderW';
  function SHLoadInProc(const rclsid:Tguid):HRESULT;StdCall;external External_library name 'SHLoadInProc';
  function SHEnableServiceObject(const rclsid:Tguid; fEnable:BOOL):HRESULT;StdCall;external External_library name 'SHEnableServiceObject';
//  function SHGetDesktopFolder(out ppshf:IShellFolder):HRESULT;StdCall;external External_library name 'SHGetDesktopFolder';
  procedure SHChangeNotify(wEventId:LONG; uFlags:UINT; dwItem1:POINTER; dwItem2:POINTER);StdCall;external External_library name 'SHChangeNotify';
  procedure SHAddToRecentDocs(uFlags:UINT; pv:POINTER);StdCall;external External_library name 'SHAddToRecentDocs';
  function SHHandleUpdateImage(pidlExtra:LPCITEMIDLIST):Longint;StdCall;external External_library name 'SHHandleUpdateImage';
  procedure SHUpdateImageA(pszHashItem:lpcstr; iIndex:Longint; uFlags:UINT; iImageIndex:Longint);StdCall;external External_library name 'SHUpdateImageA';
  procedure SHUpdateImageW(pszHashItem:lpcwstr; iIndex:Longint; uFlags:UINT; iImageIndex:Longint);StdCall;external External_library name 'SHUpdateImageW';
  function SHChangeNotifyRegister(hwnd:HWND; fSources:Longint; fEvents:LONG; wMsg:UINT; cEntries:Longint; 
             pshcne:PSHChangeNotifyEntry):ULONG;StdCall;external External_library name 'SHChangeNotifyRegister';
  function SHChangeNotifyDeregister(ulID:ulong):BOOL;StdCall;external External_library name 'SHChangeNotifyDeregister';
  function SHChangeNotification_Lock(hChangeNotification:THANDLE; dwProcessId:DWord; var pppidl:PLPITEMIDLIST; plEvent:PLONG):THANDLE;StdCall;external External_library name 'SHChangeNotification_Lock';
  function SHChangeNotification_Unlock(hLock:THANDLE):BOOL;StdCall;external External_library name 'SHChangeNotification_Unlock';
  function SHGetRealIDL(psf:IShellFolder; pidlSimple:LPCITEMIDLIST; var ppidlReal:LPITEMIDLIST):HRESULT;StdCall;external External_library name 'SHGetRealIDL';
  function SHGetInstanceExplorer(out ppunk:IUnknown):HRESULT;StdCall;external External_library name 'SHGetInstanceExplorer';
  function SHGetDataFromIDListA(psf:IShellFolder; pidl:LPCITEMIDLIST; nFormat:Longint; pv:pointer; cb:Longint):HRESULT;StdCall;external External_library name 'SHGetDataFromIDListA';
  function SHGetDataFromIDListW(psf:IShellFolder; pidl:LPCITEMIDLIST; nFormat:Longint; pv:pointer; cb:Longint):HRESULT;StdCall;external External_library name 'SHGetDataFromIDListW';
  function RestartDialog(hwnd:HWND; lpPrompt:lpcwstr; dwReturn:DWord):Longint;StdCall;external External_library name 'RestartDialog';
  function RestartDialogEx(hwnd:HWND; lpPrompt:lpcwstr; dwReturn:DWord; dwReasonCode:DWord):Longint;StdCall;external External_library name 'RestartDialogEx';
  function SHCoCreateInstance(pszCLSID:lpcwstr; pclsid:PCLSID; pUnkOuter:IUnknown; riid:TREFIID; ppv:Ppointer):HRESULT;StdCall;external External_library name 'SHCoCreateInstance';
//  function CallCPLEntry16(hinst:HINSTANCE; lpfnEntry:TFARPROC16; hwndCPL:HWND; msg:UINT; lParam1:lparam; lParam2:lparam):LRESULT;StdCall;external External_library name 'CallCPLEntry16';
  function SHCreateStdEnumFmtEtc(cfmt:UINT; afmt:array of TFORMATETC; var ppenumFormatEtc:IEnumFORMATETC):HRESULT;StdCall;external External_library name 'SHCreateStdEnumFmtEtc';
  function SHDoDragDrop(hwnd:HWND; pdata:IDataObject; pdsrc:IDropSource; dwEffect:DWord; pdwEffect:PDWORD):HRESULT;StdCall;external External_library name 'SHDoDragDrop';
  function DAD_SetDragImage(him:HIMAGELIST; pptOffset:PPOINT):BOOL;StdCall;external External_library name 'DAD_SetDragImage';
  function DAD_DragEnterEx(hwndTarget:HWND; ptStart:TPOINT):BOOL;StdCall;external External_library name 'DAD_DragEnterEx';
  function DAD_DragEnterEx2(hwndTarget:HWND; ptStart:TPOINT; pdtObject:IDataObject):BOOL;StdCall;external External_library name 'DAD_DragEnterEx2';
  function DAD_ShowDragImage(fShow:BOOL):BOOL;StdCall;external External_library name 'DAD_ShowDragImage';
  function DAD_DragMove(pt:TPOINT):BOOL;StdCall;external External_library name 'DAD_DragMove';
  function DAD_DragLeave:BOOL;StdCall;external External_library name 'DAD_DragLeave';
  function DAD_AutoScroll(hwnd:HWND; pad:PAUTO_SCROLL_DATA; pptNow:PPOINT):BOOL;StdCall;external External_library name 'DAD_AutoScroll';
  function ReadCabinetState(lpState:LPCABINETSTATE; iSize:Longint):BOOL;StdCall;external External_library name 'ReadCabinetState';
  function WriteCabinetState(lpState:LPCABINETSTATE):BOOL;StdCall;external External_library name 'WriteCabinetState';
  function PathMakeUniqueName(pszUniqueName:LPWStr; cchMax:UINT; pszTemplate:lpcwstr; pszLongPlate:lpcwstr; pszDir:lpcwstr):BOOL;StdCall;external External_library name 'PathMakeUniqueName';
  procedure PathQualify(psz:LPWStr);StdCall;external External_library name 'PathQualify';
  function PathIsExe(pszPath:lpcwstr):BOOL;StdCall;external External_library name 'PathIsExe';
  function PathIsSlowA(pszFile:lpcstr; dwAttr:DWord):BOOL;StdCall;external External_library name 'PathIsSlowA';
  function PathIsSlowW(pszFile:lpcwstr; dwAttr:DWord):BOOL;StdCall;external External_library name 'PathIsSlowW';
  function PathCleanupSpec(pszDir:lpcwstr; pszSpec:LPWStr):Longint;StdCall;external External_library name 'PathCleanupSpec';
  function PathResolve(pszPath:LPWStr; dirs:array of lpcwstr; fFlags:UINT):Longint;StdCall;external External_library name 'PathResolve';
  function GetFileNameFromBrowse(hwnd:HWND; pszFilePath:LPWStr; cbFilePath:UINT; pszWorkingDir:lpcwstr; pszDefExt:lpcwstr; 
             pszFilters:lpcwstr; pszTitle:lpcwstr):BOOL;StdCall;external External_library name 'GetFileNameFromBrowse';
  function DriveType(iDrive:Longint):Longint;StdCall;external External_library name 'DriveType';
  function RealDriveType(iDrive:Longint; fOKToHitNet:BOOL):Longint;StdCall;external External_library name 'RealDriveType';
  function IsNetDrive(iDrive:Longint):Longint;StdCall;external External_library name 'IsNetDrive';
  function Shell_MergeMenus(hmDst:HMENU; hmSrc:HMENU; uInsert:UINT; uIDAdjust:UINT; uIDAdjustMax:UINT; 
             uFlags:ULONG):UINT;StdCall;external External_library name 'Shell_MergeMenus';
  function SHObjectProperties(hwnd:HWND; dwType:DWord; lpObject:lpcwstr; lpPage:lpcwstr):BOOL;StdCall;external External_library name 'SHObjectProperties';
  function SHFormatDrive(hwnd:HWND; drive:UINT; fmtID:UINT; options:UINT):DWord;StdCall;external External_library name 'SHFormatDrive';
  function ILClone(pidl:LPCITEMIDLIST):LPITEMIDLIST;StdCall;external External_library name 'ILClone';
  function ILGetNext(pidl:LPCITEMIDLIST):LPITEMIDLIST;StdCall;external External_library name 'ILGetNext';
  function ILGetSize(pidl:LPCITEMIDLIST):UINT;StdCall;external External_library name 'ILGetSize';
  function ILFindLastID(pidl:LPCITEMIDLIST):LPITEMIDLIST;StdCall;external External_library name 'ILFindLastID';
  function ILRemoveLastID(pidl:LPITEMIDLIST):BOOL;StdCall;external External_library name 'ILRemoveLastID';
  function ILAppendID(pidl:LPITEMIDLIST; pmkid:LPCSHITEMID; fAppend:BOOL):LPITEMIDLIST;StdCall;external External_library name 'ILAppendID';
  procedure ILFree(pidl:LPITEMIDLIST);StdCall;external External_library name 'ILFree';
  function ILCloneFirst(pidl:LPCITEMIDLIST):LPITEMIDLIST;StdCall;external External_library name 'ILCloneFirst';
  function ILIsEqual(pidl1:LPCITEMIDLIST; pidl2:LPCITEMIDLIST):BOOL;StdCall;external External_library name 'ILIsEqual';
  function ILIsParent(pidl1:LPCITEMIDLIST; pidl2:LPCITEMIDLIST; fImmediate:BOOL):BOOL;StdCall;external External_library name 'ILIsParent';
  function ILFindChild(pidlParent:LPCITEMIDLIST; pidlChild:LPCITEMIDLIST):LPITEMIDLIST;StdCall;external External_library name 'ILFindChild';
  function ILCombine(pidl1:LPCITEMIDLIST; pidl2:LPCITEMIDLIST):LPITEMIDLIST;StdCall;external External_library name 'ILCombine';
  function ILLoadFromStream(pstm:IStream; var pidl:LPITEMIDLIST):HRESULT;StdCall;external External_library name 'ILLoadFromStream';
  function ILSaveToStream(pstm:IStream; pidl:LPCITEMIDLIST):HRESULT;StdCall;external External_library name 'ILSaveToStream';
  function ILCreateFromPathA(pszPath:lpcstr):LPITEMIDLIST;StdCall;external External_library name 'ILCreateFromPathA';
  function ILCreateFromPathW(pszPath:lpcwstr):LPITEMIDLIST;StdCall;external External_library name 'ILCreateFromPathW';
  function ILCreateFromPath(pszPath:LPCTSTR):LPITEMIDLIST;StdCall;external External_library name 'ILCreateFromPath';
  function SHILCreateFromPath(szPath:lpcwstr;var ppidl:LPITEMIDLIST; rgfInOut:PDWORD):HRESULT;StdCall;external External_library name 'SHILCreateFromPath';
  function OpenRegStream(hkey:HKEY; pszSubkey:lpcwstr; pszValue:lpcwstr; grfMode:DWord):IStream;StdCall;external External_library name 'OpenRegStream';
  function SHFindFiles(pidlFolder:LPCITEMIDLIST; pidlSaveFile:LPCITEMIDLIST):BOOL;StdCall;external External_library name 'SHFindFiles';
  procedure PathGetShortPath(pszLongPath:LPWStr);StdCall;external External_library name 'PathGetShortPath';
  function PathYetAnotherMakeUniqueName(pszUniqueName:LPWStr; pszPath:lpcwstr; pszShort:lpcwstr; pszFileSpec:lpcwstr):BOOL;StdCall;external External_library name 'PathYetAnotherMakeUniqueName';
  function Win32DeleteFile(pszPath:lpcwstr):BOOL;StdCall;external External_library name 'Win32DeleteFile';
  function PathProcessCommand(lpSrc:lpcwstr; lpDest:LPWStr; iMax:Longint; dwFlags:DWord):LONG;StdCall;external External_library name 'PathProcessCommand';
  function SHRestricted(rest:TRESTRICTIONS):DWord;StdCall;external External_library name 'SHRestricted';
  function SignalFileOpen(pidl:LPCITEMIDLIST):BOOL;StdCall;external External_library name 'SignalFileOpen';
  function SHSimpleIDListFromPath(pszPath:lpcwstr):LPITEMIDLIST;StdCall;external External_library name 'SHSimpleIDListFromPath';
  function SHLoadOLE(lParam:lparam):HRESULT;StdCall;external External_library name 'SHLoadOLE';
  function SHStartNetConnectionDialogA(hwnd:HWND; pszRemoteName:lpcstr; dwType:DWord):HRESULT;StdCall;external External_library name 'SHStartNetConnectionDialogA';
  function SHStartNetConnectionDialogW(hwnd:HWND; pszRemoteName:lpcwstr; dwType:DWord):HRESULT;StdCall;external External_library name 'SHStartNetConnectionDialogW';
  function SHDefExtractIconA(pszIconFile:lpcstr; iIndex:Longint; uFlags:UINT; phiconLarge:PHICON; phiconSmall:PHICON; 
             nIconSize:UINT):HRESULT;StdCall;external External_library name 'SHDefExtractIconA';
  function SHDefExtractIconW(pszIconFile:lpcwstr; iIndex:Longint; uFlags:UINT; phiconLarge:PHICON; phiconSmall:PHICON; 
             nIconSize:UINT):HRESULT;StdCall;external External_library name 'SHDefExtractIconW';
  function Shell_GetImageLists(var phiml:HIMAGELIST; var phimlSmall:HIMAGELIST):BOOL;StdCall;external External_library name 'Shell_GetImageLists';
  function Shell_GetCachedImageIndex(pszIconPath:lpcwstr; iIconIndex:Longint; uIconFlags:UINT):Longint;StdCall;external External_library name 'Shell_GetCachedImageIndex';
  function SHValidateUNC(hwndOwner:HWND; pszFile:LPWStr; fConnect:UINT):BOOL;StdCall;external External_library name 'SHValidateUNC';
  function PifMgr_OpenProperties(pszApp:lpcwstr; pszPIF:lpcwstr; hInf:UINT; flOpt:UINT):THANDLE;StdCall;external External_library name 'PifMgr_OpenProperties';
  function PifMgr_GetProperties(hProps:THANDLE; pszGroup:lpcstr; lpProps:pointer; cbProps:Longint; flOpt:UINT):Longint;StdCall;external External_library name 'PifMgr_GetProperties';
  function PifMgr_SetProperties(hProps:THANDLE; pszGroup:lpcstr; lpProps:pointer; cbProps:Longint; flOpt:UINT):Longint;StdCall;external External_library name 'PifMgr_SetProperties';
  function PifMgr_CloseProperties(hProps:THANDLE; flOpt:UINT):THANDLE;StdCall;external External_library name 'PifMgr_CloseProperties';
  procedure SHSetInstanceExplorer(punk:IUnknown);StdCall;external External_library name 'SHSetInstanceExplorer';
  function IsUserAnAdmin:BOOL;StdCall;external External_library name 'IsUserAnAdmin';
  function SHShellFolderView_Message(hwndMain:HWND; uMsg:UINT; lParam:lparam):lresult;StdCall;external External_library name 'SHShellFolderView_Message';
  function SHCreateShellFolderView(pcsfv:PSFV_CREATE; out ppsv:IShellView):HRESULT;StdCall;external External_library name 'SHCreateShellFolderView';
  function CDefFolderMenu_Create2(pidlFolder:LPCITEMIDLIST; hwnd:HWND; cidl:UINT;var apidl:LPCITEMIDLIST; psf:IShellFolder; 
             lpfn:LPFNDFMCALLBACK; nKeys:UINT; ahkeyClsKeys:PHKEY; out ppcm:IContextMenu):HRESULT;StdCall;external External_library name 'CDefFolderMenu_Create2';
  function SHOpenPropSheetA(pszCaption:lpcstr; ahkeys:array of HKEY; cikeys:UINT; pclsidDefault:PCLSID; pdtobj:IDataObject; 
             psb:IShellBrowser; pStartPage:lpcstr):BOOL;StdCall;external External_library name 'SHOpenPropSheetA';
  function SHOpenPropSheetW(pszCaption:lpcwstr; ahkeys:array of HKEY; cikeys:UINT; pclsidDefault:PCLSID; pdtobj:IDataObject; 
             psb:IShellBrowser; pStartPage:lpcwstr):BOOL;StdCall;external External_library name 'SHOpenPropSheetW';
  function SHFind_InitMenuPopup(hmenu:HMENU; hwndOwner:HWND; idCmdFirst:UINT; idCmdLast:UINT):IContextMenu;StdCall;external External_library name 'SHFind_InitMenuPopup';
  function SHCreateShellFolderViewEx(pcsfv:LPCSFV; out ppsv:IShellView):HRESULT;StdCall;external External_library name 'SHCreateShellFolderViewEx';
  procedure SHGetSetSettings(lpss:LPSHELLSTATE; dwMask:DWord; bSet:BOOL);StdCall;external External_library name 'SHGetSetSettings';
  procedure SHGetSettings(lpsfs:LPSHELLFLAGSTATE; dwMask:DWord);StdCall;external External_library name 'SHGetSettings';
  function SHBindToParent(pidl:LPCITEMIDLIST; riid:TREFIID; ppv:Ppointer; var ppidlLast:LPCITEMIDLIST):HRESULT;StdCall;external External_library name 'SHBindToParent';
  function SHParseDisplayName(pszName:PCWSTR; pbc:IBindCtx; var ppidl:LPITEMIDLIST; sfgaoIn:TSFGAOF; psfgaoOut:PSFGAOF):HRESULT;StdCall;external External_library name 'SHParseDisplayName';
  function SHPathPrepareForWriteA(hwnd:HWND; punkEnableModless:IUnknown; pszPath:lpcstr; dwFlags:DWord):HRESULT;StdCall;external External_library name 'SHPathPrepareForWriteA';
  function SHPathPrepareForWriteW(hwnd:HWND; punkEnableModless:IUnknown; pszPath:lpcwstr; dwFlags:DWord):HRESULT;StdCall;external External_library name 'SHPathPrepareForWriteW';
{  function SHPropStgCreate(psstg:IPropertySetStorage; fmtid:TREFFMTID; pclsid:PCLSID; grfFlags:DWord; grfMode:DWord; 
             dwDisposition:DWord; out ppstg:IPropertyStorage; puCodePage:PUINT):HRESULT;StdCall;external External_library name 'SHPropStgCreate';
  function SHPropStgReadMultiple(pps:IPropertyStorage; uCodePage:UINT; cpspec:ULONG; rgpspec:array of TPROPSPEC; rgvar:array of TPROPVARIANT):HRESULT;StdCall;external External_library name 'SHPropStgReadMultiple';
  function SHPropStgWriteMultiple(pps:IPropertyStorage; puCodePage:PUINT; cpspec:ULONG; rgpspec:array of TPROPSPEC; rgvar:array of TPROPVARIANT; 
             propidNameFirst:TPROPID):HRESULT;StdCall;external External_library name 'SHPropStgWriteMultiple';
}
  function SHCreateFileExtractIconA(pszFile:lpcstr; dwFileAttributes:DWord; riid:TREFIID; ppv:Ppointer):HRESULT;StdCall;external External_library name 'SHCreateFileExtractIconA';
  function SHCreateFileExtractIconW(pszFile:lpcwstr; dwFileAttributes:DWord; riid:TREFIID; ppv:Ppointer):HRESULT;StdCall;external External_library name 'SHCreateFileExtractIconW';
  function SHLimitInputEdit(hwndEdit:HWND; psf:IShellFolder):HRESULT;StdCall;external External_library name 'SHLimitInputEdit';
  function SHMultiFileProperties(pdtobj:IDataObject; dwFlags:DWord):HRESULT;StdCall;external External_library name 'SHMultiFileProperties';
//  function SHMapIDListToImageListIndexAsync(pts:IShellTaskScheduler; psf:IShellFolder; pidl:LPCITEMIDLIST; flags:UINT; pfn:TPFNASYNCICONTASKBALLBACK; 
//             pvData:pointer; pvHint:pointer; piIndex:plongint; piIndexSel:plongint):HRESULT;StdCall;external External_library name 'SHMapIDListToImageListIndexAsync';
  function SHMapPIDLToSystemImageListIndex(pshf:IShellFolder; pidl:LPCITEMIDLIST; piIndexSel:plongint):Longint;StdCall;external External_library name 'SHMapPIDLToSystemImageListIndex';

implementation
end.
