{
    $Id: i_os2.pas,v 1.9 2005/03/20 22:36:45 olle Exp $
    Copyright (c) 1998-2002 by Peter Vreman

    This unit implements support information structures for OS/2

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 ****************************************************************************
}
{ This unit implements support information structures for OS/2. }
unit i_os2;

  interface

    uses
       systems;

    const
       res_emxbind_info : tresinfo =
          (
            id     : res_emxbind;
            resbin : 'emxbind';
            rescmd : '-b -r $RES $OBJ'
            (* Not really used - see TLinkeros2.SetDefaultInfo in t_os2.pas. *)
          );

       system_i386_os2_info : tsysteminfo =
          (
            system       : system_i386_OS2;
            name         : 'OS/2';
            shortname    : 'OS2';
            flags        : [tf_need_export,tf_use_8_3];
            cpu          : cpu_i386;
            unit_env     : 'OS2UNITS';
            extradefines : '';
            exeext       : '.exe';
            defext       : '.def';
            scriptext    : '.cmd';
            smartext     : '.sl';
            unitext      : '.ppu';
            unitlibext   : '.ppl';
            asmext       : '.s';
            objext       : '.o';
            resext       : '.res';
            resobjext    : '.or';
            sharedlibext : '.dll';
            staticlibext : '.a';
            staticlibprefix : '';
            sharedlibprefix : '';
            sharedClibext : '.dll';
            staticClibext : '.a';
            staticClibprefix : '';
            sharedClibprefix : '';
            p_ext_support : false;
            Cprefix      : '_';
            newline      : #13#10;
            dirsep       : '\';
            files_case_relevent : false;
            assem        : as_i386_as_aout;
            assemextern  : as_i386_as_aout;
            link         : nil;
            linkextern   : nil;
            ar           : ar_gnu_ar;
            res          : res_emxbind;
            script       : script_dos;
            endian       : endian_little;
            alignment    :
              (
                procalign       : 4;
                loopalign       : 4;
                jumpalign       : 0;
                constalignmin   : 0;
                constalignmax   : 4;
                varalignmin     : 0;
                varalignmax     : 4;
                localalignmin   : 0;
                localalignmax   : 4;
                recordalignmin  : 0;
                recordalignmax  : 2;
                maxCrecordalign : 4
              );
            first_parm_offset : 8;
            stacksize    : 256*1024;
            DllScanSupported: false;
            use_function_relative_addresses : false
          );


  implementation

initialization
{$ifdef CPU86}
  {$ifdef os2}
    {$IFNDEF EMX}
      set_source_info(system_i386_os2_info);
    {$ENDIF EMX}
    {$IFDEF VER1_0}
      set_source_info(system_i386_os2_info);
    {$ENDIF VER1_0}
  {$endif os2}
{$endif CPU86}
end.
{
  $Log: i_os2.pas,v $
  Revision 1.9  2005/03/20 22:36:45  olle
    * Cleaned up handling of source file extension.
    + Added support for .p extension for macos and darwin

  Revision 1.8  2005/02/14 17:13:10  peter
    * truncate log

}
