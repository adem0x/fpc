{
    Copyright (c) 1998-2002 by Peter Vreman

    This unit implements support information structures for OS/2 via EMX

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
{ This unit implements support information structures for OS/2 via EMX. }
unit i_emx;

  interface

    uses
       systems;

    const
       res_emxbind_info : tresinfo =
          (
            id     : res_emxbind;
            resbin : 'emxbind';
            rescmd : '-b -r $RES $OBJ'
            (* Not really used - see TLinkerEMX.SetDefaultInfo in t_emx.pas. *)
          );

       system_i386_emx_info : tsysteminfo =
          (
            system       : system_i386_EMX;
            name         : 'OS/2 via EMX';
            shortname    : 'EMX';
            flags        : [tf_need_export,tf_use_8_3];
            cpu          : cpu_i386;
            unit_env     : 'EMXUNITS';
            extradefines : 'OS2';
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
            dbg          : dbg_stabs;
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
  {$ifdef EMX}
    {$IFNDEF VER1_0}
      set_source_info(system_i386_emx_info);
      { OS/2 via EMX can be run under DOS as well }
      if (OS_Mode=osDOS) or (OS_Mode=osDPMI) then
        source_info.scriptext := '.bat';
    {$ENDIF VER1_0}
  {$endif EMX}
{$endif CPU86}
end.
