{
    Copyright (c) 1998-2002 by Florian Klaempfl

    This unit implements the first loading and searching of the modules

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
unit fppu;

{$i fpcdefs.inc}

{ close ppufiles on system that are
  short on file handles like DOS system PM }
{$ifdef GO32V2}
  {$define SHORT_ON_FILE_HANDLES}
{$endif GO32V2}
{$ifdef WATCOM}
  {$define SHORT_ON_FILE_HANDLES}
{$endif WATCOM}

interface

    uses
       cutils,cclasses,
       globtype,globals,finput,fmodule,
       symbase,ppu,symtype;

    type
       tppumodule = class(tmodule)
          ppufile    : tcompilerppufile; { the PPU file }
          sourcefn   : pstring; { Source specified with "uses .. in '..'" }
{$ifdef Test_Double_checksum}
          crc_array  : pointer;
          crc_size   : longint;
          crc_array2 : pointer;
          crc_size2  : longint;
{$endif def Test_Double_checksum}
          constructor create(LoadedFrom:TModule;const s:string;const fn:string;_is_unit:boolean);
          destructor destroy;override;
          procedure reset;override;
          function  openppu:boolean;
          procedure getppucrc;
          procedure writeppu;
          procedure loadppu;
          function  needrecompile:boolean;
       private
          function  search_unit(onlysource,shortname:boolean):boolean;
          procedure load_interface;
          procedure load_implementation;
          procedure load_symtable_refs;
          procedure load_usedunits;
          procedure writesourcefiles;
          procedure writeusedunit(intf:boolean);
          procedure writelinkcontainer(var p:tlinkcontainer;id:byte;strippath:boolean);
          procedure writederefmap;
          procedure writederefdata;
          procedure putasmsymbol_in_idx(s:tnamedindexitem;arg:pointer);
          procedure writeasmsymbols;
          procedure readsourcefiles;
          procedure readloadunit;
          procedure readlinkcontainer(var p:tlinkcontainer);
          procedure readderefmap;
          procedure readderefdata;
          procedure readasmsymbols;
{$IFDEF MACRO_DIFF_HINT}
          procedure writeusedmacro(p:TNamedIndexItem;arg:pointer);
          procedure writeusedmacros;
          procedure readusedmacros;
{$ENDIF}
       end;

    procedure reload_flagged_units;
    function registerunit(callermodule:tmodule;const s : stringid;const fn:string) : tppumodule;


implementation

uses
  verbose,systems,version,
  symtable, symsym,
  scanner,
  aasmbase,
  parser;

{****************************************************************************
                                 Helpers
 ****************************************************************************}

    procedure reload_flagged_units;
      var
        hp : tmodule;
      begin
        { now reload all dependent units }
        hp:=tmodule(loaded_units.first);
        while assigned(hp) do
         begin
           if hp.do_reload then
             tppumodule(hp).loadppu;
           hp:=tmodule(hp.next);
         end;
      end;


{****************************************************************************
                                TPPUMODULE
 ****************************************************************************}

    constructor tppumodule.create(LoadedFrom:TModule;const s:string;const fn:string;_is_unit:boolean);
      begin
        inherited create(LoadedFrom,s,_is_unit);
        ppufile:=nil;
        sourcefn:=stringdup(fn);
      end;


    destructor tppumodule.Destroy;
      begin
        if assigned(ppufile) then
         ppufile.free;
        ppufile:=nil;
        stringdispose(sourcefn);
        inherited Destroy;
      end;


    procedure tppumodule.reset;
      begin
        if assigned(ppufile) then
         begin
           ppufile.free;
           ppufile:=nil;
         end;
        inherited reset;
      end;


    function tppumodule.openppu:boolean;
      var
        ppufiletime : longint;
      begin
        openppu:=false;
        Message1(unit_t_ppu_loading,ppufilename^);
      { Get ppufile time (also check if the file exists) }
        ppufiletime:=getnamedfiletime(ppufilename^);
        if ppufiletime=-1 then
         exit;
      { Open the ppufile }
        Message1(unit_u_ppu_name,ppufilename^);
        ppufile:=tcompilerppufile.create(ppufilename^);
        if not ppufile.openfile then
         begin
           ppufile.free;
           ppufile:=nil;
           Message(unit_u_ppu_file_too_short);
           exit;
         end;
      { check for a valid PPU file }
        if not ppufile.CheckPPUId then
         begin
           ppufile.free;
           ppufile:=nil;
           Message(unit_u_ppu_invalid_header);
           exit;
         end;
      { check for allowed PPU versions }
        if not (ppufile.GetPPUVersion = CurrentPPUVersion) then
         begin
           Message1(unit_u_ppu_invalid_version,tostr(ppufile.GetPPUVersion));
           ppufile.free;
           ppufile:=nil;
           exit;
         end;
      { check the target processor }
        if tsystemcpu(ppufile.header.cpu)<>target_cpu then
         begin
           ppufile.free;
           ppufile:=nil;
           Message(unit_u_ppu_invalid_processor);
           exit;
         end;
      { check target }
        if tsystem(ppufile.header.target)<>target_info.system then
         begin
           ppufile.free;
           ppufile:=nil;
           Message(unit_u_ppu_invalid_target);
           exit;
         end;
{$ifdef cpufpemu}
       { check if floating point emulation is on?}
        if ((ppufile.header.flags and uf_fpu_emulation)<>0) and
            (cs_fp_emulation in aktmoduleswitches) then
         begin
           ppufile.free;
           ppufile:=nil;
           Message(unit_u_ppu_invalid_fpumode);
           exit;
         end;
{$endif cpufpemu}

      { Load values to be access easier }
        flags:=ppufile.header.flags;
        crc:=ppufile.header.checksum;
        interface_crc:=ppufile.header.interface_checksum;
      { Show Debug info }
        Message1(unit_u_ppu_time,filetimestring(ppufiletime));
        Message1(unit_u_ppu_flags,tostr(flags));
        Message1(unit_u_ppu_crc,hexstr(ppufile.header.checksum,8));
        Message1(unit_u_ppu_crc,hexstr(ppufile.header.interface_checksum,8)+' (intfc)');
        do_compile:=false;
        openppu:=true;
      end;


    function tppumodule.search_unit(onlysource,shortname:boolean):boolean;
      var
         singlepathstring,
         filename : string;

         Function UnitExists(const ext:string;var foundfile:string):boolean;
         begin
           Message1(unit_t_unitsearch,Singlepathstring+filename+ext);
           UnitExists:=FindFile(FileName+ext,Singlepathstring,foundfile);
         end;

         Function PPUSearchPath(const s:string):boolean;
         var
           found : boolean;
           hs    : string;
         begin
           Found:=false;
           singlepathstring:=FixPath(s,false);
         { Check for PPU file }
           Found:=UnitExists(target_info.unitext,hs);
           if Found then
            Begin
              SetFileName(hs,false);
              Found:=OpenPPU;
            End;
           PPUSearchPath:=Found;
         end;

         Function SourceSearchPath(const s:string):boolean;
         var
           found   : boolean;
           hs      : string;
         begin
           Found:=false;
           singlepathstring:=FixPath(s,false);
         { Check for Sources }
           ppufile:=nil;
           do_compile:=true;
           recompile_reason:=rr_noppu;
         {Check for .pp file}
           Found:=UnitExists(sourceext,hs);
           if not Found then
            begin
              { Check for .pas }
              Found:=UnitExists(pasext,hs);
            end;
           if not Found and (m_mac in aktmodeswitches) then
            begin
              { Check for .p, if mode is macpas}
              Found:=UnitExists(pext,hs);
            end;
           stringdispose(mainsource);
           if Found then
            begin
              sources_avail:=true;
              { Load Filenames when found }
              mainsource:=StringDup(hs);
              SetFileName(hs,false);
            end
           else
            sources_avail:=false;
           SourceSearchPath:=Found;
         end;

         Function SearchPath(const s:string):boolean;
         var
           found : boolean;
         begin
           { First check for a ppu, then for the source }
           found:=false;
           if not onlysource then
            found:=PPUSearchPath(s);
           if not found then
            found:=SourceSearchPath(s);
           SearchPath:=found;
         end;

         Function SearchPathList(list:TSearchPathList):boolean;
         var
           hp : TStringListItem;
           found : boolean;
         begin
           found:=false;
           hp:=TStringListItem(list.First);
           while assigned(hp) do
            begin
              found:=SearchPath(hp.Str);
              if found then
               break;
              hp:=TStringListItem(hp.next);
            end;
           SearchPathList:=found;
         end;

       var
         fnd : boolean;
         hs  : string;
       begin
         if shortname then
          filename:=FixFileName(Copy(realmodulename^,1,8))
         else
          filename:=FixFileName(realmodulename^);
         { try to find unit
            1. look for ppu in cwd
            2. look for ppu in outputpath if set, this is tp7 compatible (PFV)
            3. look for the specified source file (from the uses line)
            4. look for source in cwd
            5. look in same path as local unit
            6. local unit pathlist
            7. global unit pathlist }
         fnd:=false;
         if not onlysource then
          begin
            fnd:=PPUSearchPath('.');
            if (not fnd) and (outputpath^<>'') then
             fnd:=PPUSearchPath(outputpath^);
           end;
         if (not fnd) and (sourcefn^<>'') then
          begin
            { the full filename is specified so we can't use here the
              searchpath (PFV) }
            Message1(unit_t_unitsearch,AddExtension(sourcefn^,sourceext));
            fnd:=FindFile(AddExtension(sourcefn^,sourceext),'',hs);
            if not fnd then
             begin
               Message1(unit_t_unitsearch,AddExtension(sourcefn^,pasext));
               fnd:=FindFile(AddExtension(sourcefn^,pasext),'',hs);
             end;
            if not fnd and ((m_mac in aktmodeswitches) or target_info.p_ext_support) then
             begin
               Message1(unit_t_unitsearch,AddExtension(sourcefn^,pext));
               fnd:=FindFile(AddExtension(sourcefn^,pext),'',hs);
             end;
            if fnd then
             begin
               sources_avail:=true;
               do_compile:=true;
               recompile_reason:=rr_noppu;
               stringdispose(mainsource);
               mainsource:=StringDup(hs);
               SetFileName(hs,false);
             end;
          end;
         if not fnd then
           fnd:=SourceSearchPath('.');
         if (not fnd) and Assigned(Loaded_From) then
           begin
             fnd:=PPUSearchPath(Loaded_From.Path^);
             if not fnd then
               fnd:=SourceSearchPath(Loaded_From.Path^);
             if not fnd then
               fnd:=SearchPathList(Loaded_From.LocalUnitSearchPath);
           end;
         if not fnd then
           fnd:=SearchPathList(UnitSearchPath);

         { try to find a file with the first 8 chars of the modulename, like
           dos }
         if (not fnd) and (length(filename)>8) then
          begin
            filename:=copy(filename,1,8);
            fnd:=SearchPath('.');
            if (not fnd) then
             fnd:=SearchPathList(LocalUnitSearchPath);
            if not fnd then
             fnd:=SearchPathList(UnitSearchPath);
          end;
         search_unit:=fnd;
      end;


{**********************************
    PPU Reading/Writing Helpers
***********************************}

{$IFDEF MACRO_DIFF_HINT}
    var
      is_initial: Boolean;

    procedure tppumodule.writeusedmacro(p:TNamedIndexItem;arg:pointer);
      begin
        if tmacro(p).is_used or is_initial then
          begin
            ppufile.putstring(p.name);
            ppufile.putbyte(byte(is_initial));
            ppufile.putbyte(byte(tmacro(p).is_used));
          end;
      end;

    procedure tppumodule.writeusedmacros;
      begin
        ppufile.do_crc:=false;
        is_initial:= true;
        initialmacrosymtable.foreach(@writeusedmacro,nil);
        is_initial:= false;
        if assigned(globalmacrosymtable) then
          globalmacrosymtable.foreach(@writeusedmacro,nil);
        localmacrosymtable.foreach(@writeusedmacro,nil);
        ppufile.writeentry(ibusedmacros);
        ppufile.do_crc:=true;
      end;
{$ENDIF}

    procedure tppumodule.writesourcefiles;
      var
        hp  : tinputfile;
        i,j : longint;
      begin
      { second write the used source files }
        ppufile.do_crc:=false;
        hp:=sourcefiles.files;
      { write source files directly in good order }
        j:=0;
        while assigned(hp) do
          begin
            inc(j);
            hp:=hp.ref_next;
          end;
        while j>0 do
          begin
            hp:=sourcefiles.files;
            for i:=1 to j-1 do
              hp:=hp.ref_next;
            ppufile.putstring(hp.name^);
            ppufile.putlongint(hp.getfiletime);
            dec(j);
         end;
        ppufile.writeentry(ibsourcefiles);
        ppufile.do_crc:=true;
      end;


    procedure tppumodule.writeusedunit(intf:boolean);
      var
        hp : tused_unit;
        oldcrc : boolean;
      begin
        { write a reference for each used unit }
        hp:=tused_unit(used_units.first);
        while assigned(hp) do
         begin
           if hp.in_interface=intf then
             begin
               ppufile.putstring(hp.u.realmodulename^);
               { the checksum should not affect the crc of this unit ! (PFV) }
               oldcrc:=ppufile.do_crc;
               ppufile.do_crc:=false;
               ppufile.putlongint(longint(hp.checksum));
               ppufile.putlongint(longint(hp.interface_checksum));
               ppufile.do_crc:=oldcrc;
             end;
           hp:=tused_unit(hp.next);
         end;
        ppufile.do_interface_crc:=true;
        ppufile.writeentry(ibloadunit);
      end;


    procedure tppumodule.writelinkcontainer(var p:tlinkcontainer;id:byte;strippath:boolean);
      var
        hcontainer : tlinkcontainer;
        s : string;
        mask : cardinal;
      begin
        hcontainer:=TLinkContainer.Create;
        while not p.empty do
         begin
           s:=p.get(mask);
           if strippath then
            ppufile.putstring(SplitFileName(s))
           else
            ppufile.putstring(s);
           ppufile.putlongint(mask);
           hcontainer.add(s,mask);
         end;
        ppufile.writeentry(id);
        p.Free;
        p:=hcontainer;
      end;


    procedure tppumodule.writederefmap;
      var
        i : longint;
        oldcrc : boolean;
      begin
        { This does not influence crc }
        oldcrc:=ppufile.do_crc;
        ppufile.do_crc:=false;
        { The unit map used for resolving }
        ppufile.putlongint(derefmapcnt);
        for i:=0 to derefmapcnt-1 do
          begin
            if not assigned(derefmap[i].u) then
              internalerror(2005011512);
            ppufile.putstring(derefmap[i].u.modulename^)
          end;
        ppufile.writeentry(ibderefmap);
        ppufile.do_crc:=oldcrc;
      end;


    procedure tppumodule.writederefdata;
      var
        oldcrc : boolean;
        len,hlen : longint;
        buf : array[0..1023] of byte;
      begin
        if derefdataintflen>derefdata.size then
          internalerror(200310223);
        derefdata.seek(0);
        { Write interface data }
        len:=derefdataintflen;
        while (len>0) do
          begin
            if len>1024 then
              hlen:=1024
            else
              hlen:=len;
            derefdata.read(buf,hlen);
            ppufile.putdata(buf,hlen);
            dec(len,hlen);
          end;
        { Write implementation data, this does not influence crc }
        oldcrc:=ppufile.do_crc;
        ppufile.do_crc:=false;
        len:=derefdata.size-derefdataintflen;
        while (len>0) do
          begin
            if len>1024 then
              hlen:=1024
            else
              hlen:=len;
            derefdata.read(buf,hlen);
            ppufile.putdata(buf,hlen);
            dec(len,hlen);
          end;
        if derefdata.pos<>derefdata.size then
          internalerror(200310224);
        ppufile.do_crc:=oldcrc;
        ppufile.writeentry(ibderefdata);
      end;


    procedure tppumodule.putasmsymbol_in_idx(s:tnamedindexitem;arg:pointer);
      begin
        if tasmsymbol(s).ppuidx<>-1 then
         librarydata.asmsymbolidx^[tasmsymbol(s).ppuidx-1]:=tasmsymbol(s);
      end;


    procedure tppumodule.writeasmsymbols;
      var
        s : tasmsymbol;
        i : longint;
        asmsymtype : byte;
      begin
        { get an ordered list of all symbols to put in the ppu }
        getmem(librarydata.asmsymbolidx,librarydata.asmsymbolppuidx*sizeof(pointer));
        fillchar(librarydata.asmsymbolidx^,librarydata.asmsymbolppuidx*sizeof(pointer),0);
        librarydata.symbolsearch.foreach(@putasmsymbol_in_idx,nil);
        { write the number of symbols }
        ppufile.putlongint(librarydata.asmsymbolppuidx);
        { write the symbols from the indexed list to the ppu }
        for i:=1 to librarydata.asmsymbolppuidx do
         begin
           s:=librarydata.asmsymbolidx^[i-1];
           if not assigned(s) then
            internalerror(200208071);
           asmsymtype:=1;
           if s.Classtype=tasmlabel then
            begin
              if tasmlabel(s).is_addr then
               asmsymtype:=4
              else if tasmlabel(s).typ=AT_DATA then
               asmsymtype:=3
              else
               asmsymtype:=2;
            end;
           ppufile.putbyte(asmsymtype);
           case asmsymtype of
             1 :
               ppufile.putstring(s.name);
             2..4 :
               ppufile.putlongint(tasmlabel(s).labelnr);
           end;
           ppufile.putbyte(byte(s.defbind));
           ppufile.putbyte(byte(s.typ));
         end;
        ppufile.writeentry(ibasmsymbols);
      end;

{$IFDEF MACRO_DIFF_HINT}

{
  Define MACRO_DIFF_HINT for the whole compiler (and ppudump)
  to turn this facility on. Also the hint messages defined
  below must be commented in in the msg/errore.msg file.

  There is some problems with this, thats why it is shut off:

  At the first compilation, consider a macro which is not initially
  defined, but it is used (e g the check that it is undefined is true).
  Since it do not exist, there is no macro object where the is_used
  flag can be set. Later on when the macro is defined, and the ppu
  is opened, the check cannot detect this.

  Also, in which macro object should this flag be set ? It cant be set
  for macros in the initialmacrosymboltable since this table is shared
  between different files.
}

    procedure tppumodule.readusedmacros;
      var
        hs : string;
        mac : tmacro;
        was_initial,
        was_used : boolean;
      {Reads macros which was defined or used when the module was compiled.
       This is done when a ppu file is open, before it possibly is parsed.}
      begin
        while not ppufile.endofentry do
         begin
           hs:=ppufile.getstring;
           was_initial:=boolean(ppufile.getbyte);
           was_used:=boolean(ppufile.getbyte);
           mac:=tmacro(initialmacrosymtable.search(hs));
           if assigned(mac) then
             begin
{$ifndef EXTDEBUG}
           { if we don't have the sources why tell }
              if sources_avail then
{$endif ndef EXTDEBUG}
               if (not was_initial) and was_used then
                Message2(unit_h_cond_not_set_in_last_compile,hs,mainsource^);
             end
           else { not assigned }
             if was_initial and
                was_used then
              Message2(unit_h_cond_set_in_last_compile,hs,mainsource^);
         end;
      end;
{$ENDIF}

    procedure tppumodule.readsourcefiles;
      var
        temp,hs       : string;
        temp_dir      : string;
        main_dir      : string;
        found,
        is_main       : boolean;
        orgfiletime,
        source_time   : longint;
        hp            : tinputfile;
      begin
        sources_avail:=true;
        is_main:=true;
        main_dir:='';
        while not ppufile.endofentry do
         begin
           hs:=ppufile.getstring;
           orgfiletime:=ppufile.getlongint;
           temp_dir:='';
           if (flags and uf_in_library)<>0 then
            begin
              sources_avail:=false;
              temp:=' library';
            end
           else if pos('Macro ',hs)=1 then
            begin
              { we don't want to find this file }
              { but there is a problem with file indexing !! }
              temp:='';
            end
           else
            begin
              { check the date of the source files:
                 1 path of ppu
                 2 path of main source
                 3 current dir
                 4 include/unit path }
              Source_Time:=GetNamedFileTime(path^+hs);
              found:=false;
              if Source_Time<>-1 then
                hs:=path^+hs
              else
               if not(is_main) then
                begin
                  Source_Time:=GetNamedFileTime(main_dir+hs);
                  if Source_Time<>-1 then
                    hs:=main_dir+hs;
                end;
              if Source_Time=-1 then
                Source_Time:=GetNamedFileTime(hs);
              if (Source_Time=-1) then
                begin
                  if is_main then
                    found:=unitsearchpath.FindFile(hs,temp_dir)
                  else
                    found:=includesearchpath.FindFile(hs,temp_dir);
                  if found then
                   begin
                     Source_Time:=GetNamedFileTime(temp_dir);
                     if Source_Time<>-1 then
                      hs:=temp_dir;
                   end;
                end;
              if Source_Time<>-1 then
                begin
                  if is_main then
                    main_dir:=splitpath(hs);
                  temp:=' time '+filetimestring(source_time);
                  if (orgfiletime<>-1) and
                     (source_time<>orgfiletime) then
                    begin
                      if ((flags and uf_release)=0) then
                        begin
                          do_compile:=true;
                          recompile_reason:=rr_sourcenewer;
                        end
                      else
                        Message2(unit_h_source_modified,hs,ppufilename^);
                      temp:=temp+' *';
                    end;
                end
              else
                begin
                  sources_avail:=false;
                  temp:=' not found';
                end;
              hp:=tinputfile.create(hs);
              { the indexing is wrong here PM }
              sourcefiles.register_file(hp);
            end;
           if is_main then
             begin
               stringdispose(mainsource);
               mainsource:=stringdup(hs);
             end;
           Message1(unit_u_ppu_source,hs+temp);
           is_main:=false;
         end;
      { check if we want to rebuild every unit, only if the sources are
        available }
        if do_build and sources_avail and
           ((flags and uf_release)=0) then
          begin
             do_compile:=true;
             recompile_reason:=rr_build;
          end;
      end;


    procedure tppumodule.readloadunit;
      var
        hs : string;
        pu : tused_unit;
        hp : tppumodule;
        intfchecksum,
        checksum : cardinal;
      begin
        while not ppufile.endofentry do
         begin
           hs:=ppufile.getstring;
           checksum:=cardinal(ppufile.getlongint);
           intfchecksum:=cardinal(ppufile.getlongint);
           { set the state of this unit before registering, this is
             needed for a correct circular dependency check }
           hp:=registerunit(self,hs,'');
           pu:=addusedunit(hp,false,nil);
           pu.checksum:=checksum;
           pu.interface_checksum:=intfchecksum;
         end;
        in_interface:=false;
      end;


    procedure tppumodule.readlinkcontainer(var p:tlinkcontainer);
      var
        s : string;
        m : longint;
      begin
        while not ppufile.endofentry do
         begin
           s:=ppufile.getstring;
           m:=ppufile.getlongint;
           p.add(s,m);
         end;
      end;


    procedure tppumodule.readderefmap;
      var
        i : longint;
      begin
        { Load unit map used for resolving }
        derefmapsize:=ppufile.getlongint;
        getmem(derefmap,derefmapsize*sizeof(tderefmaprec));
        fillchar(derefmap^,derefmapsize*sizeof(tderefmaprec),0);
        for i:=0 to derefmapsize-1 do
          derefmap[i].modulename:=stringdup(ppufile.getstring);
      end;


    procedure tppumodule.readderefdata;
      var
        len,hlen : longint;
        buf : array[0..1023] of byte;
      begin
        len:=ppufile.entrysize;
        while (len>0) do
          begin
            if len>1024 then
              hlen:=1024
            else
              hlen:=len;
            ppufile.getdata(buf,hlen);
            derefdata.write(buf,hlen);
            dec(len,hlen);
          end;
      end;


    procedure tppumodule.readasmsymbols;
      var
        labelnr,
        i     : longint;
        name  : string;
        bind  : TAsmSymBind;
        typ   : TAsmSymType;
        asmsymtype : byte;
      begin
        librarydata.asmsymbolppuidx:=ppufile.getlongint;
        if librarydata.asmsymbolppuidx>0 then
         begin
           getmem(librarydata.asmsymbolidx,librarydata.asmsymbolppuidx*sizeof(pointer));
           fillchar(librarydata.asmsymbolidx^,librarydata.asmsymbolppuidx*sizeof(pointer),0);
           for i:=1 to librarydata.asmsymbolppuidx do
            begin
              asmsymtype:=ppufile.getbyte;
              case asmsymtype of
                1 :
                  name:=ppufile.getstring;
                2..4 :
                  labelnr:=ppufile.getlongint;
                else
                  internalerror(200208192);
              end;
              bind:=tasmsymbind(ppufile.getbyte);
              typ:=tasmsymtype(ppufile.getbyte);
              case asmsymtype of
                1 :
                 librarydata.asmsymbolidx^[i-1]:=librarydata.newasmsymbol(name,bind,typ);
                2 :
                 librarydata.asmsymbolidx^[i-1]:=librarydata.newasmlabel(labelnr,false,false);
                3 :
                 librarydata.asmsymbolidx^[i-1]:=librarydata.newasmlabel(labelnr,false,true);
                4 :
                 librarydata.asmsymbolidx^[i-1]:=librarydata.newasmlabel(labelnr,true,false);
              end;
            end;
         end;
      end;


    procedure tppumodule.load_interface;
      var
        b : byte;
        newmodulename : string;
      begin
       { read interface part }
         repeat
           b:=ppufile.readentry;
           case b of
             ibmodulename :
               begin
                 newmodulename:=ppufile.getstring;
                 if (cs_check_unit_name in aktglobalswitches) and
                    (upper(newmodulename)<>modulename^) then
                   Message2(unit_f_unit_name_error,realmodulename^,newmodulename);
                 stringdispose(modulename);
                 stringdispose(realmodulename);
                 modulename:=stringdup(upper(newmodulename));
                 realmodulename:=stringdup(newmodulename);
               end;
             ibsourcefiles :
               readsourcefiles;
{$IFDEF MACRO_DIFF_HINT}
             ibusedmacros :
               readusedmacros;
{$ENDIF}
             ibloadunit :
               readloadunit;
             iblinkunitofiles :
               readlinkcontainer(LinkUnitOFiles);
             iblinkunitstaticlibs :
               readlinkcontainer(LinkUnitStaticLibs);
             iblinkunitsharedlibs :
               readlinkcontainer(LinkUnitSharedLibs);
             iblinkotherofiles :
               readlinkcontainer(LinkotherOFiles);
             iblinkotherstaticlibs :
               readlinkcontainer(LinkotherStaticLibs);
             iblinkothersharedlibs :
               readlinkcontainer(LinkotherSharedLibs);
             ibderefmap :
               readderefmap;
             ibderefdata :
               readderefdata;
             ibendinterface :
               break;
           else
             Message1(unit_f_ppu_invalid_entry,tostr(b));
           end;
           { we can already stop when we know that we must recompile }
           if do_compile then
             exit;
         until false;
      end;


    procedure tppumodule.load_implementation;
      var
        b : byte;
      begin
         { read implementation part }
         repeat
           b:=ppufile.readentry;
           case b of
             ibloadunit :
               readloadunit;
             ibasmsymbols :
               readasmsymbols;
             ibendimplementation :
               break;
           else
             Message1(unit_f_ppu_invalid_entry,tostr(b));
           end;
         until false;
      end;


    procedure tppumodule.load_symtable_refs;
      var
         b : byte;
         i : longint;
      begin
        if (flags and uf_has_browser)<>0 then
          begin
            tstoredsymtable(globalsymtable).load_references(ppufile,true);
            for i:=0 to unitmapsize-1 do
              tstoredsymtable(globalsymtable).load_references(ppufile,false);
            b:=ppufile.readentry;
            if b<>ibendbrowser then
             Message1(unit_f_ppu_invalid_entry,tostr(b));
          end;
        if ((flags and uf_local_browser)<>0) then
          tstaticsymtable(localsymtable).load_references(ppufile,true);
      end;


    procedure tppumodule.writeppu;
      var
        pu : tused_unit;
      begin
         Message1(unit_u_ppu_write,realmodulename^);

         { create unit flags }
{$ifdef GDB}
         if cs_gdb_dbx in aktglobalswitches then
          flags:=flags or uf_has_dbx;
{$endif GDB}
         if cs_browser in aktmoduleswitches then
          flags:=flags or uf_has_browser;
         if cs_local_browser in aktmoduleswitches then
          flags:=flags or uf_local_browser;
         if do_release then
          flags:=flags or uf_release;
         if assigned(localsymtable) then
           flags:=flags or uf_local_symtable;
{$ifdef cpufpemu}
         if (cs_fp_emulation in aktmoduleswitches) then
           flags:=flags or uf_fpu_emulation;
{$endif cpufpemu}
{$ifdef Test_Double_checksum_write}
         Assign(CRCFile,s+'.IMP');
         Rewrite(CRCFile);
{$endif def Test_Double_checksum_write}

         { create new ppufile }
         ppufile:=tcompilerppufile.create(ppufilename^);
         if not ppufile.createfile then
          Message(unit_f_ppu_cannot_write);

         { first the unitname }
         ppufile.putstring(realmodulename^);
         ppufile.writeentry(ibmodulename);

         writesourcefiles;
{$IFDEF MACRO_DIFF_HINT}
         writeusedmacros;
{$ENDIF}

         { write interface uses }
         writeusedunit(true);

         { write the objectfiles and libraries that come for this unit,
           preserve the containers becuase they are still needed to load
           the link.res. All doesn't depend on the crc! It doesn't matter
           if a unit is in a .o or .a file }
         ppufile.do_crc:=false;
         writelinkcontainer(linkunitofiles,iblinkunitofiles,true);
         writelinkcontainer(linkunitstaticlibs,iblinkunitstaticlibs,true);
         writelinkcontainer(linkunitsharedlibs,iblinkunitsharedlibs,true);
         writelinkcontainer(linkotherofiles,iblinkotherofiles,false);
         writelinkcontainer(linkotherstaticlibs,iblinkotherstaticlibs,true);
         writelinkcontainer(linkothersharedlibs,iblinkothersharedlibs,true);
         ppufile.do_crc:=true;

         { generate implementation deref data, the interface deref data is
           already generated when calculating the interface crc }
         if (cs_compilesystem in aktmoduleswitches) then
           begin
             tstoredsymtable(globalsymtable).buildderef;
             derefdataintflen:=derefdata.size;
           end;
         tstoredsymtable(globalsymtable).buildderefimpl;
         if (flags and uf_local_symtable)<>0 then
           begin
             tstoredsymtable(localsymtable).buildderef;
             tstoredsymtable(localsymtable).buildderefimpl;
           end;
         writederefmap;
         writederefdata;

         ppufile.writeentry(ibendinterface);

         { write the symtable entries }
         tstoredsymtable(globalsymtable).ppuwrite(ppufile);

         if assigned(globalmacrosymtable) and (globalmacrosymtable.symindex.count > 0) then
           begin
             ppufile.putbyte(byte(true));
             ppufile.writeentry(ibexportedmacros);
             tstoredsymtable(globalmacrosymtable).ppuwrite(ppufile);
           end
         else
           begin
             ppufile.putbyte(byte(false));
             ppufile.writeentry(ibexportedmacros);
           end;

         { everything after this doesn't affect the crc }
         ppufile.do_crc:=false;

         { write implementation uses }
         writeusedunit(false);

         { write asmsymbols }
         writeasmsymbols;

         { end of implementation }
         ppufile.writeentry(ibendimplementation);

         { write static symtable
           needed for local debugging of unit functions }
         if (flags and uf_local_symtable)<>0 then
           tstoredsymtable(localsymtable).ppuwrite(ppufile);

         { write all browser section }
         if (flags and uf_has_browser)<>0 then
          begin
            tstoredsymtable(globalsymtable).write_references(ppufile,true);
            pu:=tused_unit(used_units.first);
            while assigned(pu) do
             begin
               tstoredsymtable(pu.u.globalsymtable).write_references(ppufile,false);
               pu:=tused_unit(pu.next);
             end;
            ppufile.writeentry(ibendbrowser);
          end;
         if ((flags and uf_local_browser)<>0) then
           begin
             if not assigned(localsymtable) then
               internalerror(200408271);
             tstaticsymtable(localsymtable).write_references(ppufile,true);
           end;

         { the last entry ibend is written automaticly }

         { flush to be sure }
         ppufile.flush;
         { create and write header }
         ppufile.header.size:=ppufile.size;
         ppufile.header.checksum:=ppufile.crc;
         ppufile.header.interface_checksum:=ppufile.interface_crc;
         ppufile.header.compiler:=wordversion;
         ppufile.header.cpu:=word(target_cpu);
         ppufile.header.target:=word(target_info.system);
         ppufile.header.flags:=flags;
         ppufile.writeheader;

         { save crc in current module also }
         crc:=ppufile.crc;
         interface_crc:=ppufile.interface_crc;

{$ifdef Test_Double_checksum_write}
         close(CRCFile);
{$endif Test_Double_checksum_write}

         ppufile.closefile;
         ppufile.free;
         ppufile:=nil;
      end;


    procedure tppumodule.getppucrc;
      begin
{$ifdef Test_Double_checksum_write}
         Assign(CRCFile,s+'.INT')
         Rewrite(CRCFile);
{$endif def Test_Double_checksum_write}

         { create new ppufile }
         ppufile:=tcompilerppufile.create(ppufilename^);
         ppufile.crc_only:=true;
         if not ppufile.createfile then
           Message(unit_f_ppu_cannot_write);

         { first the unitname }
         ppufile.putstring(realmodulename^);
         ppufile.writeentry(ibmodulename);

         { the interface units affect the crc }
         writeusedunit(true);

         { deref data of interface that affect the crc }
         derefdata.reset;
         tstoredsymtable(globalsymtable).buildderef;
         derefdataintflen:=derefdata.size;
         writederefmap;
         writederefdata;

         ppufile.writeentry(ibendinterface);

         { write the symtable entries }
         tstoredsymtable(globalsymtable).ppuwrite(ppufile);

         if assigned(globalmacrosymtable) and (globalmacrosymtable.symindex.count > 0) then
           begin
             ppufile.putbyte(byte(true));
             ppufile.writeentry(ibexportedmacros);
             tstoredsymtable(globalmacrosymtable).ppuwrite(ppufile);
           end
         else
           begin
             ppufile.putbyte(byte(false));
             ppufile.writeentry(ibexportedmacros);
           end;

         { save crc  }
         crc:=ppufile.crc;
         interface_crc:=ppufile.interface_crc;

         { end of implementation, to generate a correct ppufile
           for ppudump when using INTFPPU define }
         ppufile.writeentry(ibendimplementation);

{$ifdef Test_Double_checksum}
         crc_array:=ppufile.crc_test;
         ppufile.crc_test:=nil;
         crc_size:=ppufile.crc_index2;
         crc_array2:=ppufile.crc_test2;
         ppufile.crc_test2:=nil;
         crc_size2:=ppufile.crc_index2;
{$endif Test_Double_checksum}

{$ifdef Test_Double_checksum_write}
         close(CRCFile);
{$endif Test_Double_checksum_write}

         { create and write header, this will only be used
           for debugging purposes }
         ppufile.header.size:=ppufile.size;
         ppufile.header.checksum:=ppufile.crc;
         ppufile.header.interface_checksum:=ppufile.interface_crc;
         ppufile.header.compiler:=wordversion;
         ppufile.header.cpu:=word(target_cpu);
         ppufile.header.target:=word(target_info.system);
         ppufile.header.flags:=flags;
         ppufile.writeheader;

         ppufile.closefile;
         ppufile.free;
         ppufile:=nil;
      end;


    procedure tppumodule.load_usedunits;
      var
        pu           : tused_unit;
        load_refs    : boolean;
        oldobjectlibrary : tasmlibrarydata;
      begin
        if current_module<>self then
         internalerror(200212284);
        load_refs:=true;

        { load the used units from interface }
        in_interface:=true;
        pu:=tused_unit(used_units.first);
        while assigned(pu) do
         begin
           if pu.in_interface then
            begin
              tppumodule(pu.u).loadppu;
              { if this unit is compiled we can stop }
              if state=ms_compiled then
               exit;
              { add this unit to the dependencies }
              pu.u.adddependency(self);
              { need to recompile the current unit, check the interface
                crc. And when not compiled with -Ur then check the complete
                crc }
              if (pu.u.interface_crc<>pu.interface_checksum) or
                 (
                  ((ppufile.header.flags and uf_release)=0) and
                  (pu.u.crc<>pu.checksum)
                 ) then
               begin
                 Message2(unit_u_recompile_crc_change,realmodulename^,pu.u.realmodulename^);
                 recompile_reason:=rr_crcchanged;
                 do_compile:=true;
                 exit;
               end;
            end;
           pu:=tused_unit(pu.next);
         end;

        { ok, now load the interface of this unit }
        if current_module<>self then
         internalerror(200208187);
        globalsymtable:=tglobalsymtable.create(modulename^,moduleid);
        tstoredsymtable(globalsymtable).ppuload(ppufile);

        if ppufile.readentry<>ibexportedmacros then
          Message(unit_f_ppu_read_error);
        if boolean(ppufile.getbyte) then
          begin
            globalmacrosymtable:=tmacrosymtable.Create(true);
            tstoredsymtable(globalmacrosymtable).ppuload(ppufile)
          end;

        interface_compiled:=true;

        { read the implementation part, containing
          the implementation uses and objectdata }
        in_interface:=false;
        load_implementation;

        { now only read the implementation uses }
        pu:=tused_unit(used_units.first);
        while assigned(pu) do
         begin
           if (not pu.in_interface) then
            begin
              tppumodule(pu.u).loadppu;
              { if this unit is compiled we can stop }
              if state=ms_compiled then
               exit;
              { add this unit to the dependencies }
              pu.u.adddependency(self);
              { need to recompile the current unit ? }
              if (pu.u.interface_crc<>pu.interface_checksum) then
                begin
                  Message2(unit_u_recompile_crc_change,realmodulename^,pu.u.realmodulename^+' {impl}');
                  recompile_reason:=rr_crcchanged;
                  do_compile:=true;
                  exit;
                end;
            end;
           pu:=tused_unit(pu.next);
         end;

        { load implementation symtable }
        if (flags and uf_local_symtable)<>0 then
          begin
            localsymtable:=tstaticsymtable.create(modulename^,moduleid);
            tstaticsymtable(localsymtable).ppuload(ppufile);
          end;

        { we can now derefence all pointers to the implementation parts }
        oldobjectlibrary:=objectlibrary;
        objectlibrary:=librarydata;
        tstoredsymtable(globalsymtable).derefimpl;
        if assigned(localsymtable) then
          tstoredsymtable(localsymtable).derefimpl;
        objectlibrary:=oldobjectlibrary;

        { load browser info if stored }
        if ((flags and uf_has_browser)<>0) and load_refs then
         begin
           if current_module<>self then
            internalerror(200208188);
           load_symtable_refs;
         end;
      end;


    function tppumodule.needrecompile:boolean;
      var
        pu : tused_unit;
      begin
        result:=false;
        pu:=tused_unit(used_units.first);
        while assigned(pu) do
         begin
           { need to recompile the current unit, check the interface
             crc. And when not compiled with -Ur then check the complete
             crc }
           if (pu.u.interface_crc<>pu.interface_checksum) or
              (
               (pu.in_interface) and
               (pu.u.crc<>pu.checksum)
              ) then
             begin
               result:=true;
               exit;
             end;
           pu:=tused_unit(pu.next);
         end;
      end;


    procedure tppumodule.loadppu;
      const
        ImplIntf : array[boolean] of string[15]=('implementation','interface');
      var
        do_load,
        second_time : boolean;
        old_current_module : tmodule;
      begin
        old_current_module:=current_module;
        Message3(unit_u_load_unit,old_current_module.modulename^,
                 ImplIntf[old_current_module.in_interface],
                 modulename^);

        { Update loaded_from to detect cycles }
        loaded_from:=old_current_module;

        { check if the globalsymtable is already available, but
          we must reload when the do_reload flag is set }
        if (not do_reload) and
           assigned(globalsymtable) then
           exit;

        { reset }
        do_load:=true;
        second_time:=false;
        current_module:=self;
        SetCompileModule(current_module);
        Fillchar(aktfilepos,0,sizeof(aktfilepos));

        { A force reload }
        if do_reload then
         begin
           Message(unit_u_forced_reload);
           do_reload:=false;
           { When the unit is already loaded or being loaded
             we can maybe skip a complete reload/recompile }
           if assigned(globalsymtable) and
              (not needrecompile) then
             begin
               { When we don't have any data stored yet there
                 is nothing to resolve }
               if interface_compiled then
                 begin
                   Message1(unit_u_reresolving_unit,modulename^);
                   tstoredsymtable(globalsymtable).deref;
                   tstoredsymtable(globalsymtable).derefimpl;
                   if assigned(localsymtable) then
                    begin
                      tstoredsymtable(localsymtable).deref;
                      tstoredsymtable(localsymtable).derefimpl;
                    end;
                 end
               else
                 Message1(unit_u_skipping_reresolving_unit,modulename^);
               do_load:=false;
             end;
         end;

        if do_load then
         begin
           { we are loading a new module, save the state of the scanner
             and reset scanner+module }
           if assigned(current_scanner) then
             current_scanner.tempcloseinputfile;
           current_scanner:=nil;

           { loading the unit for a second time? }
           if state=ms_registered then
            state:=ms_load
           else
            begin
              { try to load the unit a second time first }
              Message1(unit_u_second_load_unit,modulename^);
              Message2(unit_u_previous_state,modulename^,ModuleStateStr[state]);
              { Flag modules to reload }
              flagdependent(old_current_module);
              { Reset the module }
              reset;
              if state in [ms_compile,ms_second_compile] then
                begin
                  Message1(unit_u_second_compile_unit,modulename^);
                  state:=ms_second_compile;
                  do_compile:=true;
                end
              else
                state:=ms_second_load;
              second_time:=true;
            end;

           { close old_current_ppu on system that are
             short on file handles like DOS PM }
{$ifdef SHORT_ON_FILE_HANDLES}
           if old_current_module.is_unit and
              assigned(tppumodule(old_current_module).ppufile) then
             tppumodule(old_current_module).ppufile.tempclose;
{$endif SHORT_ON_FILE_HANDLES}

           { try to opening ppu, skip this when we already
             know that we need to compile the unit }
           if not do_compile then
            begin
              Message1(unit_u_loading_unit,modulename^);
              search_unit(false,false);
              if not do_compile then
               begin
                 load_interface;
                 if not do_compile then
                  begin
                    load_usedunits;
                    if not do_compile then
                      Message1(unit_u_finished_loading_unit,modulename^);
                  end;
               end;
              { PPU is not needed anymore }
              if assigned(ppufile) then
               begin
                  ppufile.closefile;
                  ppufile.free;
                  ppufile:=nil;
               end;
            end;

           { Do we need to recompile the unit }
           if do_compile then
            begin
              { recompile the unit or give a fatal error if sources not available }
              if not(sources_avail) then
               begin
                 if (not search_unit(true,false)) and
                    (length(modulename^)>8) then
                   search_unit(true,true);
                 if not(sources_avail) then
                  begin
                    if recompile_reason=rr_noppu then
                      Message1(unit_f_cant_find_ppu,realmodulename^)
                    else
                      Message1(unit_f_cant_compile_unit,realmodulename^);
                  end;
               end;
              { Flag modules to reload }
              flagdependent(old_current_module);
              { Reset the module }
              reset;
              { compile this module }
              if not(state in [ms_compile,ms_second_compile]) then
                state:=ms_compile;
              compile(mainsource^);
            end
           else
            state:=ms_compiled;

           if current_module<>self then
             internalerror(200212282);

           if in_interface then
             internalerror(200212283);

           { for a second_time recompile reload all dependent units,
             for a first time compile register the unit _once_ }
           if second_time then
            reload_flagged_units
           else
            usedunits.concat(tused_unit.create(self,true,false,nil));

           { reopen the old module }
{$ifdef SHORT_ON_FILE_HANDLES}
           if old_current_module.is_unit and
              assigned(tppumodule(old_current_module).ppufile) then
             tppumodule(old_current_module).ppufile.tempopen;
{$endif SHORT_ON_FILE_HANDLES}

           { reload old scanner }
           current_scanner:=tscannerfile(old_current_module.scanner);
           if assigned(current_scanner) then
            begin
              current_scanner.tempopeninputfile;
              current_scanner.gettokenpos
            end
           else
            fillchar(aktfilepos,sizeof(aktfilepos),0);
         end;

        { we are back, restore current_module }
        current_module:=old_current_module;
        SetCompileModule(current_module);
      end;


{*****************************************************************************
                               RegisterUnit
*****************************************************************************}


    function registerunit(callermodule:tmodule;const s : stringid;const fn:string) : tppumodule;
      var
        ups   : stringid;
        hp    : tppumodule;
        hp2   : tmodule;
      begin
        { Info }
        ups:=upper(s);
        { search all loaded units }
        hp:=tppumodule(loaded_units.first);
        while assigned(hp) do
         begin
           if hp.modulename^=ups then
            begin
              { only check for units. The main program is also
                as a unit in the loaded_units list. We simply need
                to ignore this entry (PFV) }
              if hp.is_unit then
               begin
                 { both units in interface ? }
                 if callermodule.in_interface and
                    hp.in_interface then
                  begin
                    { check for a cycle }
                    hp2:=callermodule.loaded_from;
                    while assigned(hp2) and (hp2<>hp) do
                     begin
                       if hp2.in_interface then
                         hp2:=hp2.loaded_from
                       else
                         hp2:=nil;
                     end;
                    if assigned(hp2) then
                      Message2(unit_f_circular_unit_reference,callermodule.realmodulename^,hp.realmodulename^);
                  end;
                 break;
               end;
            end;
           { the next unit }
           hp:=tppumodule(hp.next);
         end;
        { the unit is not in the loaded units,
          we create an entry and register the unit }
        if not assigned(hp) then
         begin
           Message1(unit_u_registering_new_unit,Upper(s));
           hp:=tppumodule.create(callermodule,s,fn,true);
           hp.loaded_from:=callermodule;
           addloadedunit(hp);
         end;
        { return }
        registerunit:=hp;
      end;

end.
