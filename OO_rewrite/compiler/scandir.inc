{
    Copyright (c) 1998-2002 by Peter Vreman

    This unit implements directive parsing for the scanner

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
(* Was scandir.pas
*)

{$IFnDEF old}
{$ELSE}
unit scandir;

{$i fpcdefs.inc}

  interface

    uses
      globtype;

    const
      switchesstatestackmax = 20;

    type
      tsavedswitchesstate = record
        localsw: tlocalswitches;
        verbosity: longint;
      end;

    type
      tswitchesstatestack = array[0..switchesstatestackmax] of tsavedswitchesstate;

    var
      switchesstatestack:tswitchesstatestack;
      switchesstatestackpos: Integer;

    procedure InitScannerDirectives;

  implementation

    uses
      SysUtils,
      cutils,cfileutl,
      globals,systems,widestr,cpuinfo,
      verbose,comphook,ppu,
      scanner,switches,
      fmodule,
      symconst,symtable,
      rabase;
{$ENDIF}

{*****************************************************************************
                                    Helpers
*****************************************************************************}

    procedure tscannerfile.do_delphiswitch(sw:char);
      var
        state : char;
      begin
      { c contains the next char, a + or - would be fine }
        state:=readstate;
        if state in ['-','+'] then
          HandleSwitch(sw,state);
      end;


    procedure tscannerfile.do_setverbose(flag:char);
      var
        state : char;
      begin
      { support ON/OFF }
        state:=ReadState;
        recordpendingverbosityswitch(flag,state);
      end;


    procedure tscannerfile.do_moduleswitch(sw:tmoduleswitch);
      var
        state : char;
      begin
        state:=readstate;
        if (sw<>cs_modulenone) and (state in ['-','+']) then
         begin
           if state='-' then
            exclude(current_settings.moduleswitches,sw)
           else
            include(current_settings.moduleswitches,sw);
         end;
      end;


    procedure tscannerfile.do_localswitch(sw:tlocalswitch);
      var
        state : char;
      begin
        state:=readstate;
        if (sw<>cs_localnone) and (state in ['-','+']) then
          recordpendinglocalswitch(sw,state);
      end;

    procedure tscannerfile.do_localswitchdefault(sw:tlocalswitch);
      var
        state : char;
      begin
        state:=readstatedefault;
        if (sw<>cs_localnone) and (state in ['-','+','*']) then
          recordpendinglocalswitch(sw,state);
      end;


    procedure tscannerfile.do_message(w:integer);
      begin
        skipspace;
        Message1(w,readcomment);
      end;

{*****************************************************************************
                              Directive Callbacks
*****************************************************************************}

    procedure tscannerfile.dir_align;
      var
        hs : string;
      begin
        skipspace;
        if not(c in ['0'..'9']) then
         begin
           { Support also the ON and OFF as switch }
           hs:=readid;
           if (hs='ON') then
            current_settings.packrecords:=4
           else if (hs='OFF') then
             current_settings.packrecords:=1
           else if m_mac in current_settings.modeswitches then
             begin
               { Support switches used in Apples Universal Interfaces}
               if (hs='MAC68K') then
                 current_settings.packrecords:=mac68k_alignment
               { "power" alignment is the default C packrecords setting on
                 Mac OS X }
               else if (hs='POWER') or (hs='POWERPC') then
                 current_settings.packrecords:=C_alignment
               else if (hs='RESET') then
                 current_settings.packrecords:=0
               else
                 Message1(scan_e_illegal_pack_records,hs);
             end
           else
             Message1(scan_e_illegal_pack_records,hs);
         end
        else
         begin
           case readval of
             1 : current_settings.packrecords:=1;
             2 : current_settings.packrecords:=2;
             4 : current_settings.packrecords:=4;
             8 : current_settings.packrecords:=8;
            16 : current_settings.packrecords:=16;
            32 : current_settings.packrecords:=32;
           else
            Message1(scan_e_illegal_pack_records,hs);
           end;
         end;
      end;

{$IFDEF old}
    procedure tscannerfile.dir_a1;
      begin
        current_settings.packrecords:=1;
      end;

    procedure tscannerfile.dir_a2;
      begin
        current_settings.packrecords:=2;
      end;

    procedure tscannerfile.dir_a4;
      begin
        current_settings.packrecords:=4;
      end;

    procedure tscannerfile.dir_a8;
      begin
        current_settings.packrecords:=8;
      end;
{$ELSE}
{$ENDIF}

    procedure tscannerfile.dir_asmmode;
      var
        s : string;
      begin
        skipspace;
        s:=readid;
        If Inside_asm_statement then
          Message1(scan_w_no_asm_reader_switch_inside_asm,s);
        if s='DEFAULT' then
         current_settings.asmmode:=init_settings.asmmode
        else
         if not SetAsmReadMode(s,current_settings.asmmode) then
           Message1(scan_e_illegal_asmmode_specifier,s);
      end;

{$if defined(m68k) or defined(arm)}
    procedure tscannerfile.dir_appid;
      begin
        if target_info.system<>system_m68k_palmos then
          Message(scan_w_appid_not_support);
        { change description global var in all cases }
        { it not used but in win32 and os2 }
        skipspace;
        palmos_applicationid:=current_scanner.readcomment;
      end;

    procedure tscannerfile.dir_appname;
      begin
        if target_info.system<>system_m68k_palmos then
          Message(scan_w_appname_not_support);
        { change description global var in all cases }
        { it not used but in win32 and os2 }
        skipspace;
        palmos_applicationname:=readcomment;
      end;
{$endif defined(m68k) or defined(arm)}

    procedure tscannerfile.dir_apptype;
      var
         hs : string;
      begin
        if not (target_info.system in systems_all_windows + [system_i386_os2,
                                       system_i386_emx, system_powerpc_macos,
                                       system_arm_nds] + systems_nativent) then
          begin
            if m_delphi in current_settings.modeswitches then
              Message(scan_n_app_type_not_support)
            else
              Message(scan_w_app_type_not_support);
          end
        else
          begin
            if not current_module.in_global then
              Message(scan_w_switch_is_global)
            else
              begin
                 skipspace;
                 hs:=readid;
                 if hs='GUI' then
                   apptype:=app_gui
                 else if hs='CONSOLE' then
                   apptype:=app_cui
                 else if (hs='NATIVE') and (target_info.system in systems_windows + systems_nativent) then
                   apptype:=app_native
                 else if (hs='FS') and (target_info.system in [system_i386_os2,
                                                             system_i386_emx]) then
                   apptype:=app_fs
                 else if (hs='TOOL') and (target_info.system in [system_powerpc_macos]) then
                   apptype:=app_tool
                 else if (hs='ARM9') and (target_info.system in [system_arm_nds]) then
                   apptype:=app_arm9
                 else if (hs='ARM7') and (target_info.system in [system_arm_nds]) then
                   apptype:=app_arm7
                 else
                   Message1(scan_w_unsupported_app_type,hs);
              end;
          end;
      end;


    procedure tscannerfile.dir_calling;
      var
         hs : string;
      begin
        skipspace;
        hs:=readid;
        if (hs='') then
          Message(parser_e_proc_directive_expected)
        else
          recordpendingcallingswitch(hs);
      end;

{$IFDEF old}
    procedure tscannerfile.dir_checkpointer;
      begin
        do_localswitchdefault(cs_checkpointer);
      end;


    procedure tscannerfile.dir_objectchecks;
      begin
        do_localswitch(cs_check_object);
      end;


    procedure tscannerfile.dir_assertions;
      begin
        do_delphiswitch('C');
      end;

    procedure tscannerfile.dir_booleval;
      begin
        do_delphiswitch('B');
      end;

    procedure tscannerfile.dir_debuginfo;
      begin
        do_delphiswitch('D');
      end;
{$ELSE}
{$ENDIF}

    procedure tscannerfile.dir_description;
      begin
        if not (target_info.system in systems_all_windows+[system_i386_os2,system_i386_emx,
                 system_i386_netware,system_i386_wdosx,system_i386_netwlibc]) then
          Message(scan_w_description_not_support);
        { change description global var in all cases }
        { it not used but in win32, os2 and netware }
        skipspace;
        description:=readcomment;
        DescriptionSetExplicity:=true;
      end;

    procedure tscannerfile.dir_screenname; {ad}
      begin
        if not (target_info.system in [system_i386_netware,system_i386_netwlibc]) then
          {Message(scan_w_decription_not_support);}
          comment (V_Warning,'Screenname only supported for target netware');
        skipspace;
        nwscreenname:=readcomment;
      end;

      procedure tscannerfile.dir_threadname; {ad}
      begin
        if not (target_info.system in [system_i386_netware,system_i386_netwlibc]) then
          {Message(scan_w_decription_not_support);}
          comment (V_Warning,'Threadname only supported for target netware');
        skipspace;
        nwthreadname:=readcomment;
      end;

      procedure tscannerfile.dir_copyright; {ad}
      begin
        if not (target_info.system in [system_i386_netware,system_i386_netwlibc]) then
          {Message(scan_w_decription_not_support);}
          comment (V_Warning,'Copyright only supported for target netware');
        skipspace;
        nwcopyright:=readcomment;
      end;

{$IFDEF old}
    procedure tscannerfile.dir_error;
      begin
        do_message(scan_e_user_defined);
      end;

    procedure tscannerfile.dir_extendedsyntax;
      begin
        do_delphiswitch('X');
      end;

    procedure tscannerfile.dir_fatal;
      begin
        do_message(scan_f_user_defined);
      end;
{$ELSE}
{$ENDIF}

    procedure tscannerfile.dir_fputype;
      begin
        skipspace;
        undef_system_macro('FPU'+fputypestr[current_settings.fputype]);
        if not(SetFPUType(upper(readcomment),current_settings.fputype)) then
          comment(V_Error,'Illegal FPU type');
        def_system_macro('FPU'+fputypestr[current_settings.fputype]);
     end;

    procedure tscannerfile.dir_frameworkpath;
      begin
        if not current_module.in_global then
         Message(scan_w_switch_is_global)
        else if not(target_info.system in systems_darwin) then
          begin
            Message(scan_w_frameworks_darwin_only);
            skipspace;
            readcomment
          end
        else
          begin
            skipspace;
            current_module.localframeworksearchpath.AddPath(readcomment,false);
          end;
      end;

{$IFDEF old}
    procedure tscannerfile.dir_goto;
      begin
        do_moduleswitch(cs_support_goto);
      end;

    procedure tscannerfile.dir_hint;
      begin
        do_message(scan_h_user_defined);
      end;

    procedure tscannerfile.dir_hints;
      begin
        do_setverbose('H');
      end;

    procedure tscannerfile.dir_implicitexceptions;
      begin
        do_moduleswitch(cs_implicit_exceptions);
      end;

    procedure tscannerfile.dir_info;
      begin
        do_message(scan_i_user_defined);
      end;

    procedure tscannerfile.dir_inline;
      begin
        do_localswitch(cs_do_inline);
      end;
{$ELSE}
{$ENDIF}

    procedure tscannerfile.dir_imagebase;
      begin
        if not (target_info.system in (systems_windows+systems_wince)) then
          Message(scan_w_imagebase_not_support);
        skipspace;
        imagebase:=readval;
        ImageBaseSetExplicity:=true
      end;

    procedure tscannerfile.dir_includepath;
      begin
        if not current_module.in_global then
         Message(scan_w_switch_is_global)
        else
          begin
            skipspace;
            current_module.localincludesearchpath.AddPath(readcomment,false);
          end;
      end;

    procedure tscannerfile.dir_interfaces;
      var
        hs : string;
      begin
        {corba/com/default}
        skipspace;
        hs:=readid;
        if (hs='CORBA') then
          current_settings.interfacetype:=it_interfacecorba
        else if (hs='COM') then
          current_settings.interfacetype:=it_interfacecom
        else if (hs='DEFAULT') then
          current_settings.interfacetype:=init_settings.interfacetype
        else
          Message(scan_e_invalid_interface_type);
      end;

{$IFDEF old}
    procedure tscannerfile.dir_iochecks;
      begin
        do_delphiswitch('I');
      end;

    procedure tscannerfile.dir_libexport;
      begin
        {not implemented}
      end;
{$ELSE}
{$ENDIF}

    procedure tscannerfile.dir_librarypath;
      begin
        if not current_module.in_global then
         Message(scan_w_switch_is_global)
        else
          begin
            skipspace;
            current_module.locallibrarysearchpath.AddPath(readcomment,false);
          end;
      end;

    procedure tscannerfile.dir_link;
      var
        s : string;
      begin
        skipspace;
        if c = '''' then
          begin
            s:= readquotedstring;
            readcomment
          end
        else
          s:= trimspace(readcomment);
        s:=FixFileName(s);
        if ExtractFileExt(s)='' then
          s:=ChangeFileExt(s,target_info.objext);
        current_module.linkotherofiles.add(s,link_always);
      end;

    procedure tscannerfile.dir_linkframework;
      var
        s : string;
      begin
        skipspace;
        if c = '''' then
          begin
            s:= readquotedstring;
            readcomment
          end
        else
          s:= trimspace(readcomment);
        s:=FixFileName(s);
        if (target_info.system in systems_darwin) then
          current_module.linkotherframeworks.add(s,link_always)
        else
          Message(scan_w_frameworks_darwin_only);
      end;

    procedure tscannerfile.dir_linklib;
      type
        tLinkMode=(lm_shared,lm_static);
      var
        s : string;
        quote : char;
        libext,
        libname,
        linkmodestr : string;
        p : longint;
        linkMode : tLinkMode;
      begin
        skipspace;
        if c = '''' then
          begin
            libname:= readquotedstring;
            s:= readcomment;
            p:=pos(',',s);
          end
        else
          begin
            s:= readcomment;
            p:=pos(',',s);
            if p=0 then
              libname:=TrimSpace(s)
            else
              libname:=TrimSpace(copy(s,1,p-1));
          end;
        if p=0 then
          linkmodeStr:=''
        else
          linkmodeStr:=Upper(TrimSpace(copy(s,p+1,255)));


        if (libname='') or (libname='''''') or (libname='""') then
         exit;
        { create library name }
        if libname[1] in ['''','"'] then
         begin
           quote:=libname[1];
           Delete(libname,1,1);
           p:=pos(quote,libname);
           if p>0 then
            Delete(libname,p,1);
         end;
        libname:=FixFileName(libname);

        { get linkmode, default is to check the extension for
          the static library, otherwise shared linking is assumed }
        linkmode:=lm_shared;
        if linkModeStr='' then
         begin
           libext:=ExtractFileExt(libname);
           if libext=target_info.staticClibext then
             linkMode:=lm_static;
         end
        else if linkModeStr='STATIC' then
         linkmode:=lm_static
        else if (LinkModeStr='SHARED') or (LinkModeStr='') then
         linkmode:=lm_shared
        else
         Comment(V_Error,'Wrong link mode specified: "'+Linkmodestr+'"');

        { add to the list of other libraries }
        if linkMode=lm_static then
         current_module.linkOtherStaticLibs.add(libname,link_always)
        else
         current_module.linkOtherSharedLibs.add(libname,link_always);
      end;

{$IFDEF old}
    procedure tscannerfile.dir_localsymbols;
      begin
        do_delphiswitch('L');
      end;

    procedure tscannerfile.dir_longstrings;
      begin
        do_delphiswitch('H');
      end;

    procedure tscannerfile.dir_macro;
      begin
        do_moduleswitch(cs_support_macro);
      end;
{$ELSE}
{$ENDIF}

    procedure tscannerfile.dir_pascalmainname;
      var
        s: string;
      begin
        skipspace;
        s:=trimspace(readcomment);
        if assigned(current_module.mainname) and
           (s<>current_module.mainname^) then
          begin
            Message1(scan_w_multiple_main_name_overrides,current_module.mainname^);
            stringdispose(current_module.mainname)
          end
        else if (mainaliasname<>defaultmainaliasname) and
                (mainaliasname<>s) then
          Message1(scan_w_multiple_main_name_overrides,mainaliasname);
        mainaliasname:=s;
        if (mainaliasname<>defaultmainaliasname) then
          current_module.mainname:=stringdup(mainaliasname);
      end;

    procedure tscannerfile.dir_maxfpuregisters;
      var
         l  : integer;
         hs : string;
      begin
         skipspace;
         if not(c in ['0'..'9']) then
           begin
              hs:=readid;
              if (hs='NORMAL') or (hs='DEFAULT') then
                current_settings.maxfpuregisters:=-1
              else
                Message(scan_e_invalid_maxfpureg_value);
           end
         else
           begin
              l:=readval;
              case l of
                 0..8:
                   current_settings.maxfpuregisters:=l;
                 else
                   Message(scan_e_invalid_maxfpureg_value);
              end;
           end;
      end;

    procedure tscannerfile.dir_maxstacksize;
      begin
        if not (target_info.system in (systems_windows+systems_wince)) then
          Message(scan_w_maxstacksize_not_support);
        skipspace;
        maxstacksize:=readval;
        MaxStackSizeSetExplicity:=true;
      end;

    procedure tscannerfile.dir_memory;
      var
        l : longint;
      begin
        skipspace;
        l:=readval;
        if l>1024 then
          stacksize:=l;
        if c=',' then
          begin
            readchar;
            skipspace;
            l:=readval;
            if l>1024 then
              heapsize:=l;
          end;
      end;


    procedure tscannerfile.dir_message;
      var
        hs : string;
        w  : longint;
      begin
        w:=0;
        skipspace;
        { Message level specified? }
        if c='''' then
          w:=scan_n_user_defined
        else
          begin
            hs:=readid;
            if (hs='WARN') or (hs='WARNING') then
              w:=scan_w_user_defined
            else
              if (hs='ERROR') then
                w:=scan_e_user_defined
            else
              if (hs='FATAL') then
                w:=scan_f_user_defined
            else
              if (hs='HINT') then
                w:=scan_h_user_defined
            else
              if (hs='NOTE') then
                w:=scan_n_user_defined
            else
              Message1(scan_w_illegal_directive,hs);
          end;
        { Only print message when there was no error }
        if w<>0 then
          begin
            skipspace;
            if c='''' then
              hs:=readquotedstring
            else
              hs:=readcomment;
            Message1(w,hs);
          end
        else
          readcomment;
      end;


    procedure tscannerfile.dir_minstacksize;
      begin
        if not (target_info.system in (systems_windows+systems_wince)) then
          Message(scan_w_minstacksize_not_support);
        skipspace;
        minstacksize:=readval;
        MinStackSizeSetExplicity:=true;
      end;


    procedure tscannerfile.dir_mode;

    begin
      if not current_module.in_global then
        Message(scan_w_switch_is_global)
      else
        begin
          skipspace;
          readstring;
          if not current_module.mode_switch_allowed and
              not ((m_mac in current_settings.modeswitches) and (pattern='MACPAS')) then
            Message1(scan_e_mode_switch_not_allowed,pattern)
          else if not SetCompileMode(pattern,false) then
            Message1(scan_w_illegal_switch,pattern)
        end;
      current_module.mode_switch_allowed:= false;
    end;


    procedure tscannerfile.dir_modeswitch;
      var
        s : string;
      begin
        if not current_module.in_global then
          Message(scan_w_switch_is_global)
        else
          begin
            skipspace;
            readstring;
            s:=pattern;
            if c in ['+','-'] then
              s:=s+readstate;
            if not SetCompileModeSwitch(s,false) then
              Message1(scan_w_illegal_switch,s)
          end;
      end;

{$IFDEF old}
    procedure tscannerfile.dir_mmx;
      begin
        do_localswitch(cs_mmx);
      end;

    procedure tscannerfile.dir_note;
      begin
        do_message(scan_n_user_defined);
      end;

    procedure tscannerfile.dir_notes;
      begin
        do_setverbose('N');
      end;

    procedure tscannerfile.dir_openstrings;
      begin
        do_delphiswitch('P');
      end;

    procedure tscannerfile.dir_overflowchecks;
      begin
        do_delphiswitch('Q');
      end;
{$ELSE}
{$ENDIF}

    procedure tscannerfile.dir_objectpath;
      begin
        if not current_module.in_global then
         Message(scan_w_switch_is_global)
        else
          begin
            skipspace;
            current_module.localobjectsearchpath.AddPath(readcomment,false);
          end;
      end;

    procedure tscannerfile.dir_optimization;
      var
        hs : string;
      begin
        skipspace;
        { Support also the ON and OFF as switch }
        hs:=readid;
        if (hs='ON') then
          current_settings.optimizerswitches:=level2optimizerswitches
        else if (hs='OFF') then
          current_settings.optimizerswitches:=[]
        else if (hs='DEFAULT') then
          current_settings.optimizerswitches:=init_settings.optimizerswitches
        else
          begin
            if not UpdateOptimizerStr(hs,current_settings.optimizerswitches) then
              Message1(scan_e_illegal_optimization_specifier,hs);
          end;
      end;

    procedure tscannerfile.dir_packenum;
      var
        hs : string;
      begin
        skipspace;
        if not(c in ['0'..'9']) then
         begin
           hs:=readid;
           if (hs='NORMAL') or (hs='DEFAULT') then
            current_settings.packenum:=4
           else
            Message1(scan_e_illegal_pack_enum, hs);
         end
        else
         begin
           case readval of
            1 : current_settings.packenum:=1;
            2 : current_settings.packenum:=2;
            4 : current_settings.packenum:=4;
           else
            Message1(scan_e_illegal_pack_enum, pattern);
           end;
         end;
      end;


    procedure tscannerfile.dir_minfpconstprec;
      begin
        skipspace;
        if not SetMinFPConstPrec(readid,current_settings.minfpconstprec) then
          Message1(scan_e_illegal_minfpconstprec, pattern);
      end;


    procedure tscannerfile.dir_packrecords;
      var
        hs : string;
      begin
        skipspace;
        if not(c in ['0'..'9']) then
         begin
           hs:=readid;
           { C has the special recordalignmax of C_alignment }
           if (hs='C') then
            current_settings.packrecords:=C_alignment
           else
            if (hs='NORMAL') or (hs='DEFAULT') then
             current_settings.packrecords:=0
           else
            Message1(scan_e_illegal_pack_records,hs);
         end
        else
         begin
           case readval of
             1 : current_settings.packrecords:=1;
             2 : current_settings.packrecords:=2;
             4 : current_settings.packrecords:=4;
             8 : current_settings.packrecords:=8;
            16 : current_settings.packrecords:=16;
            32 : current_settings.packrecords:=32;
           else
            Message1(scan_e_illegal_pack_records,pattern);
           end;
         end;
      end;


    procedure tscannerfile.dir_packset;
      var
        hs : string;
      begin
        skipspace;
        if not(c in ['1','2','4','8']) then
         begin
           hs:=readid;
           if (hs='FIXED') or ((hs='DEFAULT') OR (hs='NORMAL')) then
            current_settings.setalloc:=0               {Fixed mode, sets are 4 or 32 bytes}
           else
            Message(scan_e_only_packset);
         end
        else
         begin
           case readval of
            1 : current_settings.setalloc:=1;
            2 : current_settings.setalloc:=2;
            4 : current_settings.setalloc:=4;
            8 : current_settings.setalloc:=8;
           else
            Message(scan_e_only_packset);
           end;
         end;
      end;


    procedure tscannerfile.dir_pic;
      begin
        { windows doesn't need/support pic }
        if tf_no_pic_supported in target_info.flags then
          message(scan_w_pic_ignored)
        else
          do_moduleswitch(cs_create_pic);
      end;

    procedure tscannerfile.dir_pop;

    begin
      if switchesstatestackpos < 1 then
        Message(scan_e_too_many_pop);

      Dec(switchesstatestackpos);
      recordpendinglocalfullswitch(switchesstatestack[switchesstatestackpos].localsw);
      recordpendingverbosityfullswitch(switchesstatestack[switchesstatestackpos].verbosity);
    end;

    procedure tscannerfile.dir_profile;
      begin
        do_moduleswitch(cs_profile);
        { defined/undefine FPC_PROFILE }
        if cs_profile in current_settings.moduleswitches then
          def_system_macro('FPC_PROFILE')
        else
          undef_system_macro('FPC_PROFILE');
      end;

    procedure tscannerfile.dir_push;
    begin
      if switchesstatestackpos > switchesstatestackmax then
        Message(scan_e_too_many_push);

      flushpendingswitchesstate;

      switchesstatestack[switchesstatestackpos].localsw:= current_settings.localswitches;
      switchesstatestack[switchesstatestackpos].verbosity:=status.verbosity;
      Inc(switchesstatestackpos);
    end;

{$IFDEF old}
    procedure tscannerfile.dir_rangechecks;
      begin
        do_delphiswitch('R');
      end;

    procedure tscannerfile.dir_referenceinfo;
      begin
        do_delphiswitch('Y');
      end;
{$ELSE}
{$ENDIF}

    procedure tscannerfile.dir_resource;
      var
        s : string;
      begin
        skipspace;
        if c = '''' then
          begin
            s:= readquotedstring;
            readcomment
          end
        else
          s:= trimspace(readcomment);

        { replace * with the name of the main source.
          This should always be defined. }
        if s[1]='*' then
          if Assigned(Current_Module) then
            begin
              delete(S,1,1);
              insert(ChangeFileExt(ExtractFileName(current_module.mainsource^),''),S,1 );
            end;
        s:=FixFileName(s);
        if ExtractFileExt(s)='' then
          s:=ChangeFileExt(s,target_info.resext);
        if target_info.res<>res_none then
          begin
          current_module.flags:=current_module.flags or uf_has_resourcefiles;
          if (res_single_file in target_res.resflags) and
                                 not (Current_module.ResourceFiles.Empty) then
            Message(scan_w_only_one_resourcefile_supported)
          else
            current_module.resourcefiles.insert(FixFileName(s));
          end
        else
          Message(scan_e_resourcefiles_not_supported);
      end;

{$IFDEF old}
    procedure tscannerfile.dir_saturation;
      begin
        do_localswitch(cs_mmx_saturation);
      end;

    procedure tscannerfile.dir_safefpuexceptions;
      begin
        do_localswitch(cs_fpu_fwait);
      end;

    procedure tscannerfile.dir_scopedenums;
      begin
        do_localswitch(cs_scopedenums);
      end;
{$ELSE}
{$ENDIF}

    procedure tscannerfile.dir_setpeflags;
      begin
        if not (target_info.system in (systems_all_windows)) then
          Message(scan_w_setpeflags_not_support);
        skipspace;
        peflags:=readval;
        SetPEFlagsSetExplicity:=true;
      end;

{$IFDEF old}
    procedure tscannerfile.dir_smartlink;
      begin
        do_moduleswitch(cs_create_smart);
      end;

    procedure tscannerfile.dir_stackframes;
      begin
        do_delphiswitch('W');
      end;

    procedure tscannerfile.dir_stop;
      begin
        do_message(scan_f_user_defined);
      end;
{$ELSE}
{$ENDIF}

{$ifdef powerpc}
    procedure tscannerfile.dir_syscall;
      var
        sctype : string;
      begin
        { not needed on amiga/m68k for now, because there's only one }
        { syscall convention (legacy) (KB) }
        { not needed on amiga/powerpc because there's only one }
        { syscall convention (sysv) (KB) }
        if not (target_info.system in [system_powerpc_morphos]) then
          comment (V_Warning,'Syscall directive is useless on this target.');
        skipspace;

        sctype:=readid;
        if (sctype='LEGACY') or (sctype='SYSV') or (sctype='SYSVBASE') or
          (sctype='BASESYSV') or (sctype='R12BASE') then
          syscall_convention:=sctype
        else
          comment (V_Warning,'Invalid Syscall directive ignored.');
      end;
{$endif}

{$IFDEF old}
    procedure tscannerfile.dir_typedaddress;
      begin
        do_delphiswitch('T');
      end;

    procedure tscannerfile.dir_typeinfo;
      begin
        do_delphiswitch('M');
      end;

    procedure tscannerfile.dir_varpropsetter;
      begin
        do_localswitch(cs_varpropsetter);
      end;

    procedure tscannerfile.dir_varstringchecks;
      begin
        do_delphiswitch('V');
      end;
{$ELSE}
{$ENDIF}

    procedure tscannerfile.dir_unitpath;
      begin
        if not current_module.in_global then
         Message(scan_w_switch_is_global)
        else
          with current_module,localunitsearchpath do
            begin
              skipspace;
              AddPath(path^,readcomment,false);
            end;
      end;

    procedure tscannerfile.dir_version;
      var
        major, minor, revision : longint;
        error : integer;
      begin
        if not (target_info.system in systems_all_windows+[system_i386_os2,system_i386_emx,
                 system_i386_netware,system_i386_wdosx,
                 system_i386_netwlibc]) then
          begin
            Message(scan_n_version_not_support);
            exit;
          end;
        if (compile_level<>1) then
          Message(scan_n_only_exe_version)
        else
          begin
            { change description global var in all cases }
            { it not used but in win32, os2 and netware }
            skipspace;
            { we should only accept Major.Minor format for win32 and os2 }
            readnumber;
            major:=0;
            minor:=0;
            revision:=0;
            val(pattern,major,error);
            if (error<>0) or (major > high(word)) or (major < 0) then
              begin
                Message1(scan_w_wrong_version_ignored,pattern);
                exit;
              end;
            if c='.' then
              begin
                readchar;
                readnumber;
                val(pattern,minor,error);
                if (error<>0) or (minor > high(word)) or (minor < 0) then
                  begin
                    Message1(scan_w_wrong_version_ignored,tostr(major)+'.'+pattern);
                    exit;
                  end;
                if (c='.') and
                   (target_info.system in [system_i386_netware,system_i386_netwlibc]) then
                  begin
                     readchar;
                     readnumber;
                     val(pattern,revision,error);
                     if (error<>0) or (revision > high(word)) or (revision < 0) then
                       begin
                          Message1(scan_w_wrong_version_ignored,tostr(revision)+'.'+pattern);
                          exit;
                       end;
                     dllmajor:=word(major);
                     dllminor:=word(minor);
                     dllrevision:=word(revision);
                     dllversion:=tostr(major)+','+tostr(minor)+','+tostr(revision);
                  end
                else
                  begin
                     dllmajor:=word(major);
                     dllminor:=word(minor);
                     dllversion:=tostr(major)+'.'+tostr(minor);
                  end;
              end
            else
              dllversion:=tostr(major);
          end;
      end;

    procedure tscannerfile.dir_wait;
      var
        had_info : boolean;
      begin
        had_info:=(status.verbosity and V_Info)<>0;
        { this message should allways appear !! }
        status.verbosity:=status.verbosity or V_Info;
        Message(scan_i_press_enter);
        readln;
        If not(had_info) then
          status.verbosity:=status.verbosity and (not V_Info);
      end;

    { delphi compatible warn directive:
      $warn <identifier> on
      $warn <identifier> off
      $warn <identifier> error
      not implemented yet
    }
    procedure tscannerfile.dir_warn;
      var
        ident : string;
        state : string;
        msgstate : tmsgstate;
      begin
        skipspace;
        ident:=readid;
        skipspace;
        state:=readid;

        { support both delphi and fpc switches }
        if (state='ON') or (state='+') then
          msgstate:=ms_on
        else
        if (state='OFF') or (state='-') then
          msgstate:=ms_off
        else
        if (state='ERROR') then
          msgstate:=ms_error
        else
        begin
          Message1(scanner_e_illegal_warn_state,state);
          exit;
        end;

        if ident='CONSTRUCTING_ABSTRACT' then
          recordpendingmessagestate(type_w_instance_with_abstract, msgstate)
        else
        if ident='IMPLICIT_VARIANTS' then
          recordpendingmessagestate(parser_w_implicit_uses_of_variants_unit, msgstate)
        else
        if ident='NO_RETVAL' then
          recordpendingmessagestate(sym_w_function_result_not_set, msgstate)
        else
        if ident='SYMBOL_DEPRECATED' then
          begin
            recordpendingmessagestate(sym_w_deprecated_symbol, msgstate);
            recordpendingmessagestate(sym_w_deprecated_symbol_with_msg, msgstate);
          end
        else
        if ident='SYMBOL_EXPERIMENTAL' then
          recordpendingmessagestate(sym_w_experimental_symbol, msgstate)
        else
        if ident='SYMBOL_LIBRARY' then
          recordpendingmessagestate(sym_w_library_symbol, msgstate)
        else
        if ident='SYMBOL_PLATFORM' then
          recordpendingmessagestate(sym_w_non_portable_symbol, msgstate)
        else
        if ident='SYMBOL_UNIMPLEMENTED' then
          recordpendingmessagestate(sym_w_non_implemented_symbol, msgstate)
        else
        if ident='UNIT_DEPRECATED' then
          begin
            recordpendingmessagestate(sym_w_deprecated_unit, msgstate);
            recordpendingmessagestate(sym_w_deprecated_unit_with_msg, msgstate);
          end
        else
        if ident='UNIT_EXPERIMENTAL' then
          recordpendingmessagestate(sym_w_experimental_unit, msgstate)
        else
        if ident='UNIT_LIBRARY' then
          recordpendingmessagestate(sym_w_library_unit, msgstate)
        else
        if ident='UNIT_PLATFORM' then
          recordpendingmessagestate(sym_w_non_portable_unit, msgstate)
        else
        if ident='UNIT_UNIMPLEMENTED' then
          recordpendingmessagestate(sym_w_non_implemented_unit, msgstate)
        else
        if ident='ZERO_NIL_COMPAT' then
          recordpendingmessagestate(type_w_zero_to_nil, msgstate)
        else
          Message1(scanner_w_illegal_warn_identifier,ident);
      end;

{$IFDEF old}
    procedure tscannerfile.dir_warning;
      begin
        do_message(scan_w_user_defined);
      end;

    procedure tscannerfile.dir_warnings;
      begin
        do_setverbose('W');
      end;

    procedure tscannerfile.dir_writeableconst;
      begin
        do_delphiswitch('J');
      end;

    procedure tscannerfile.dir_z1;
      begin
        current_settings.packenum:=1;
      end;

    procedure tscannerfile.dir_z2;
      begin
        current_settings.packenum:=2;
      end;

    procedure tscannerfile.dir_z4;
      begin
        current_settings.packenum:=4;
      end;

    procedure tscannerfile.dir_externalsym;
      begin
      end;

    procedure tscannerfile.dir_nodefine;
      begin
      end;

    procedure tscannerfile.dir_hppemit;
      begin
      end;

    procedure tscannerfile.dir_weakpackageunit;
      begin
      end;
{$ELSE}
{$ENDIF}

    procedure tscannerfile.dir_codealign;
      var
        s : string;
      begin
        skipspace;
        s:=readcomment;
        UpdateAlignmentStr(s,current_settings.alignment);
      end;

    procedure tscannerfile.dir_codepage;
      var
         s : string;
      begin
        if not current_module.in_global then
          Message(scan_w_switch_is_global)
        else
          begin
             skipspace;
             s:=readcomment;
             if (upper(s)='UTF8') or (upper(s)='UTF-8') then
               current_settings.sourcecodepage:='utf8'
             else if not(cpavailable(s)) then
               Message1(option_code_page_not_available,s)
             else
               current_settings.sourcecodepage:=s;
          end;
      end;

{$IFDEF old}
    procedure tscannerfile.dir_coperators;
      begin
        do_moduleswitch(cs_support_c_operators);
      end;


    procedure tscannerfile.dir_bitpacking;
      begin
        do_localswitch(cs_bitpacking);
      end;

    procedure tscannerfile.dir_region;
      begin
      end;

    procedure tscannerfile.dir_endregion;
      begin
      end;
{$ELSE}
{$ENDIF}


//end.
