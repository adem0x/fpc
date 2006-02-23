{
    Copyright (c) 1998-2002 by Peter Vreman

    Contains the binary elf writer

    * This code was inspired by the NASM sources
      The Netwide Assembler is Copyright (c) 1996 Simon Tatham and
      Julian Hall. All rights reserved.

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
unit ogelf;

{$i fpcdefs.inc}

interface

    uses
       { common }
       cclasses,globtype,
       { target }
       systems,
       { assembler }
       cpuinfo,cpubase,aasmbase,aasmtai,assemble,
       { output }
       ogbase;

    type
       TElf32ObjSection = class(TObjSection)
       public
          secshidx  : longint; { index for the section in symtab }
          shstridx,
          shtype,
          shflags,
          shlink,
          shinfo,
          entsize   : longint;
          { relocation }
          relocsect : TElf32ObjSection;
          constructor create(const Aname:string;Atype:TObjSectionType;Aalign:longint;Aoptions:TObjSectionOptions);override;
          constructor create_ext(const Aname:string;Atype:TObjSectionType;Ashtype,Ashflags,Ashlink,Ashinfo,Aalign,Aentsize:longint);
          destructor  destroy;override;
       end;

       TElf32ObjData = class(TObjData)
       public
         symtabsect,
         strtabsect,
         shstrtabsect,
         gotpcsect,
         gotoffsect,
         goTSect,
         plTSect,
         symsect  : TElf32ObjSection;
         syms     : Tdynamicarray;
         constructor create(const n:string);
         destructor  destroy;override;
         function  sectionname(atype:TObjSectiontype;const aname:string):string;override;
         procedure writereloc(data,len:aint;p:tasmsymbol;relative:TObjRelocationType);override;
         procedure writesymbol(p:tasmsymbol);override;
         procedure writestab(offset:aint;ps:tasmsymbol;nidx,nother,line:longint;p:pchar);override;
         procedure beforealloc;override;
         procedure beforewrite;override;
       end;

       TElf32ObjectOutput = class(tObjOutput)
       private
         elf32data : TElf32ObjData;
         initsym   : longint;
         procedure createrelocsection(s:TElf32ObjSection);
         procedure createshstrtab;
         procedure createsymtab;
         procedure writesectionheader(s:TElf32ObjSection);
         procedure writesectiondata(s:TElf32ObjSection);
         procedure section_write_symbol(p:tnamedindexitem;arg:pointer);
         procedure section_write_sh_string(p:tnamedindexitem;arg:pointer);
         procedure section_number_symbol(p:tnamedindexitem;arg:pointer);
         procedure section_count_sections(p:tnamedindexitem;arg:pointer);
         procedure section_create_relocsec(p:tnamedindexitem;arg:pointer);
         procedure section_set_datapos(p:tnamedindexitem;arg:pointer);
         procedure section_relocsec_set_datapos(p:tnamedindexitem;arg:pointer);
         procedure section_write_data(p:tnamedindexitem;arg:pointer);
         procedure section_write_sechdr(p:tnamedindexitem;arg:pointer);
         procedure section_write_relocsec(p:tnamedindexitem;arg:pointer);
       protected
         function writedata(data:TObjData):boolean;override;
       public
         constructor Create(smart:boolean);override;
       end;

       TElf32assembler = class(tinternalassembler)
         constructor create(smart:boolean);override;
       end;


implementation

      uses
        strings,
        verbose,
        cutils,globals,fmodule;

    const
      symbolresize = 200*18;

    const
      R_386_32 = 1;                    { ordinary absolute relocation }
      R_386_PC32 = 2;                  { PC-relative relocation }
      R_386_GOT32 = 3;                 { an offset into GOT }
      R_386_PLT32 = 4;                 { a PC-relative offset into PLT }
      R_386_GOTOFF = 9;                { an offset from GOT base }
      R_386_GOTPC = 10;                { a PC-relative offset _to_ GOT }

      SHN_UNDEF     = 0;
      SHN_ABS       = $fff1;
      SHN_COMMON    = $fff2;

      SHT_NULL     = 0;
      SHT_PROGBITS = 1;
      SHT_SYMTAB   = 2;
      SHT_STRTAB   = 3;
      SHT_RELA     = 4;
      SHT_HASH     = 5;
      SHT_DYNAMIC  = 6;
      SHT_NOTE     = 7;
      SHT_NOBITS   = 8;
      SHT_REL      = 9;
      SHT_SHLIB    = 10;
      SHT_DYNSYM   = 11;

      SHF_WRITE     = 1;
      SHF_ALLOC     = 2;
      SHF_EXECINSTR = 4;

      STB_LOCAL   = 0;
      STB_GLOBAL  = 1;
      STB_WEAK    = 2;

      STT_NOTYPE  = 0;
      STT_OBJECT  = 1;
      STT_FUNC    = 2;
      STT_SECTION = 3;
      STT_FILE    = 4;

      type
      { Structures which are written directly to the output file }
        TElf32header=packed record
          magic0123         : longint;
          file_class        : byte;
          data_encoding     : byte;
          file_version      : byte;
          padding           : array[$07..$0f] of byte;
          e_type            : word;
          e_machine         : word;
          e_version         : longint;
          e_entry           : longint;          { entrypoint }
          e_phoff           : longint;          { program header offset }
          e_shoff           : longint;          { sections header offset }
          e_flags           : longint;
          e_ehsize          : word;             { elf header size in bytes }
          e_phentsize       : word;             { size of an entry in the program header array }
          e_phnum           : word;             { 0..e_phnum-1 of entrys }
          e_shentsize       : word;             { size of an entry in sections header array }
          e_shnum           : word;             { 0..e_shnum-1 of entrys }
          e_shstrndx        : word;             { index of string section header }
        end;
        TElf32sechdr=packed record
          sh_name           : longint;
          sh_type           : longint;
          sh_flags          : longint;
          sh_addr           : longint;
          sh_offset         : longint;
          sh_size           : longint;
          sh_link           : longint;
          sh_info           : longint;
          sh_addralign      : longint;
          sh_entsize        : longint;
        end;
        TElf32reloc=packed record
          address : longint;
          info    : longint; { bit 0-7: type, 8-31: symbol }
        end;
        TElf32symbol=packed record
          st_name  : longint;
          st_value : longint;
          st_size  : longint;
          st_info  : byte; { bit 0-3: type, 4-7: bind }
          st_other : byte;
          st_shndx : word;
        end;
        TElf32stab=packed record
          strpos  : longint;
          ntype   : byte;
          nother  : byte;
          ndesc   : word;
          nvalue  : longint;
        end;


{****************************************************************************
                               TSection
****************************************************************************}

    constructor TElf32ObjSection.create(const Aname:string;Atype:TObjSectionType;Aalign:longint;Aoptions:TObjSectionOptions);
      var
        Ashflags,Ashtype,Aentsize : longint;
      begin
        Ashflags:=0;
        Ashtype:=0;
        Aentsize:=0;
        case Atype of
          sec_code :
            begin
              Ashflags:=SHF_ALLOC or SHF_EXECINSTR;
              AshType:=SHT_PROGBITS;
              AAlign:=max(sizeof(aint),AAlign);
            end;
          sec_data :
            begin
              Ashflags:=SHF_ALLOC or SHF_WRITE;
              AshType:=SHT_PROGBITS;
              AAlign:=max(sizeof(aint),AAlign);
            end;
          sec_rodata :
            begin
{$warning TODO Remove rodata hack}
              Ashflags:=SHF_ALLOC or SHF_WRITE;
              AshType:=SHT_PROGBITS;
              AAlign:=max(sizeof(aint),AAlign);
            end;
          sec_bss,sec_threadvar :
            begin
              Ashflags:=SHF_ALLOC or SHF_WRITE;
              AshType:=SHT_NOBITS;
              AAlign:=max(sizeof(aint),AAlign);
            end;
          sec_stab :
            begin
              AshType:=SHT_PROGBITS;
              AAlign:=max(sizeof(aint),AAlign);
              Aentsize:=sizeof(TElf32stab);
            end;
          sec_stabstr :
            begin
              AshType:=SHT_STRTAB;
              AAlign:=1;
            end;
          sec_fpc :
            begin
              AshFlags:=SHF_ALLOC;
              AshType:=SHT_PROGBITS ;
              AAlign:=4;// max(sizeof(aint),AAlign);
            end;
          else
            internalerror(200509122);
        end;
        create_ext(Aname,Atype,Ashtype,Ashflags,0,0,Aalign,Aentsize);
      end;


    constructor TElf32ObjSection.create_ext(const Aname:string;Atype:TObjSectionType;Ashtype,Ashflags,Ashlink,Ashinfo,Aalign,Aentsize:longint);
      var
        aoptions : TObjSectionOptions;
      begin
        aoptions:=[];
        if (AshType=SHT_NOBITS) then
          include(aoptions,aso_alloconly);
        inherited create(Aname,Atype,Aalign,aoptions);
        secshidx:=0;
        shstridx:=0;
        shtype:=AshType;
        shflags:=AshFlags;
        shlink:=Ashlink;
        shinfo:=Ashinfo;
        entsize:=Aentsize;
        relocsect:=nil;
      end;


    destructor TElf32ObjSection.destroy;
      begin
        if assigned(relocsect) then
          relocsect.free;
        inherited destroy;
      end;


{****************************************************************************
                            TElf32ObjData
****************************************************************************}

    constructor TElf32ObjData.create(const n:string);
      begin
        inherited create(n);
        CObjSection:=TElf32ObjSection;
        { reset }
        Syms:=TDynamicArray.Create(symbolresize);
        { default sections }
        symtabsect:=TElf32ObjSection.create_ext('.symtab',sec_custom,2,0,0,0,4,16);
        strtabsect:=TElf32ObjSection.create_ext('.strtab',sec_custom,3,0,0,0,1,0);
        shstrtabsect:=TElf32ObjSection.create_ext('.shstrtab',sec_custom,3,0,0,0,1,0);
        { insert the empty and filename as first in strtab }
        strtabsect.writestr(#0);
        strtabsect.writestr(SplitFileName(current_module.mainsource^)+#0);
        { we need at least the following sections }
        createsection(sec_code,'',0,[]);
        createsection(sec_data,'',0,[]);
        createsection(sec_bss,'',0,[]);
        if tf_section_threadvars in target_info.flags then
          createsection(sec_threadvar,'',0,[]);
        { create stabs sections if debugging }
        if (cs_debuginfo in aktmoduleswitches) then
         begin
           stabssec:=createsection(sec_stab,'',0,[]);
           stabstrsec:=createsection(sec_stabstr,'',0,[]);
         end;
      end;


    destructor TElf32ObjData.destroy;
      begin
        Syms.Free;
        symtabsect.free;
        strtabsect.free;
        shstrtabsect.free;
        inherited destroy;
      end;


    function TElf32ObjData.sectionname(atype:TObjSectiontype;const aname:string):string;
      const
        secnames : array[TObjSectiontype] of string[13] = ('',
{$ifdef userodata}
          '.text','.data','.rodata','.bss','.threadvar',
{$else userodata}
          '.text','.data','.data','.bss','.threadvar',
{$endif userodata}
          'common',
          '.note',
          '.text', { darwin stubs }
          '.stab','.stabstr',
          '.idata$2','.idata$4','.idata$5','.idata$6','.idata$7','.edata',
          '.eh_frame',
          '.debug_frame','.debug_info','.debug_line','.debug_abbrev',
          'fpc',
		  ''
        );
      begin
        if (use_smartlink_section and
           (aname<>'')) or (atype=sec_fpc) then
          result:=secnames[atype]+'.'+aname
        else
          result:=secnames[atype];
      end;


    procedure TElf32ObjData.writesymbol(p:tasmsymbol);
      begin
        if CurrObjSec=nil then
          internalerror(200403291);
        { already written ? }
        if p.indexnr<>-1 then
         exit;
        { calculate symbol index }
        if (p.currbind<>AB_LOCAL) then
         begin
           { insert the symbol in the local index, the indexarray
             will take care of the numbering }
           ObjSymbols.insert(p);
         end
        else
         p.indexnr:=-2; { local }
      end;


    procedure TElf32ObjData.writereloc(data,len:aint;p:tasmsymbol;relative:TObjRelocationType);
      var
        symaddr : longint;
      begin
        if CurrObjSec=nil then
          internalerror(200403292);
{$ifdef userodata}
        if CurrObjSec.sectype in [sec_rodata,sec_bss,sec_threadvar] then
          internalerror(200408252);
{$endif userodata}
        if assigned(p) then
         begin
           { real address of the symbol }
           symaddr:=p.address;
           { Local ObjSymbols can be resolved already or need a section reloc }
           if (p.currbind=AB_LOCAL) then
             begin
               { For a relative relocation in the same section the
                 value can be calculated }
               if (p.objsection=CurrObjSec) and
                  (relative=RELOC_RELATIVE) then
                 inc(data,symaddr-len-CurrObjSec.datasize)
               else
                 begin
                   CurrObjSec.addsectionreloc(CurrObjSec.datasize,p.objsection,relative);
                   inc(data,symaddr);
                 end;
             end
           else
             begin
               writesymbol(p);
               CurrObjSec.addsymreloc(CurrObjSec.datasize,p,relative);
               if relative=RELOC_RELATIVE then
                 dec(data,len);
            end;
         end;
        CurrObjSec.write(data,len);
      end;


    procedure TElf32ObjData.writestab(offset:aint;ps:tasmsymbol;nidx,nother,line:longint;p:pchar);
      var
        stab : TElf32stab;
      begin
        fillchar(stab,sizeof(TElf32stab),0);
        if assigned(p) and (p[0]<>#0) then
         begin
           stab.strpos:=stabstrsec.datasize;
           stabstrsec.write(p^,strlen(p)+1);
         end;
        stab.ntype:=nidx;
        stab.ndesc:=line;
        stab.nother:=nother;
        stab.nvalue:=offset;
        stabssec.write(stab,sizeof(stab));
        if assigned(ps) then
          begin
            writesymbol(ps);
            stabssec.addsymreloc(stabssec.datasize-4,ps,RELOC_ABSOLUTE);
          end;
      end;


    procedure TElf32ObjData.beforealloc;
      begin
        { create stabs sections if debugging }
        if (cs_debuginfo in aktmoduleswitches) then
          begin
            StabsSec.Alloc(sizeof(TElf32stab));
            StabStrSec.Alloc(length(SplitFileName(current_module.mainsource^))+2);
          end;
      end;


    procedure TElf32ObjData.beforewrite;
      var
        s : string;
      begin
        { create stabs sections if debugging }
        if (cs_debuginfo in aktmoduleswitches) then
         begin
           writestab(0,nil,0,0,0,nil);
           { write zero pchar and name together (PM) }
           s:=#0+SplitFileName(current_module.mainsource^)+#0;
           stabstrsec.write(s[1],length(s));
         end;
      end;


{****************************************************************************
                            TElf32ObjectOutput
****************************************************************************}

    constructor TElf32ObjectOutput.create(smart:boolean);
      begin
        inherited Create(smart);
        CObjData:=TElf32ObjData;
      end;


    procedure TElf32ObjectOutput.createrelocsection(s:TElf32ObjSection);
      var
        rel  : TElf32reloc;
        r    : TObjRelocation;
        relsym,reltyp : longint;
      begin
        with elf32data do
         begin
{$ifdef userodata}
           { rodata can't have relocations }
           if s.sectype=sec_rodata then
             begin
               if assigned(s.relocations.first) then
                 internalerror(200408251);
               exit;
             end;
{$endif userodata}
           { create the reloc section }
           s.relocsect:=TElf32ObjSection.create_ext('.rel'+s.name,sec_custom,9,0,symtabsect.secshidx,s.secshidx,4,8);
           { add the relocations }
           r:=TObjRelocation(s.relocations.first);
           while assigned(r) do
            begin
              rel.address:=r.address;
              if assigned(r.symbol) then
               begin
                 if (r.symbol.currbind=AB_LOCAL) then
                  relsym:=r.symbol.objsection.secsymidx
                 else
                  begin
                    if r.symbol.indexnr=-1 then
                      internalerror(4321);
                    { indexnr starts with 1, ELF starts with 0 }
                    relsym:=r.symbol.indexnr+initsym-1;
                  end;
               end
              else
               if r.objsection<>nil then
                relsym:=r.objsection.secsymidx
               else
                relsym:=SHN_UNDEF;
              case r.typ of
                RELOC_RELATIVE :
                  reltyp:=R_386_PC32;
                RELOC_ABSOLUTE :
                  reltyp:=R_386_32;
              end;
              rel.info:=(relsym shl 8) or reltyp;
              { write reloc }
              s.relocsect.write(rel,sizeof(rel));
              r:=TObjRelocation(r.next);
            end;
         end;
      end;


    procedure TElf32ObjectOutput.section_write_symbol(p:tnamedindexitem;arg:pointer);
      var
        elfsym : TElf32symbol;
      begin
        fillchar(elfsym,sizeof(elfsym),0);
        elfsym.st_name:=TElf32ObjSection(p).shstridx;
        elfsym.st_info:=STT_SECTION;
        elfsym.st_shndx:=TElf32ObjSection(p).secshidx;
        elf32data.symtabsect.write(elfsym,sizeof(elfsym));
        { increase locals count }
        inc(plongint(arg)^);
      end;


    procedure TElf32ObjectOutput.createsymtab;
      var
        elfsym : TElf32symbol;
        locals : longint;
        sym : tasmsymbol;
      begin
        with elf32data do
         begin
           locals:=2;
           { empty entry }
           fillchar(elfsym,sizeof(elfsym),0);
           symtabsect.write(elfsym,sizeof(elfsym));
           { filename entry }
           elfsym.st_name:=1;
           elfsym.st_info:=STT_FILE;
           elfsym.st_shndx:=SHN_ABS;
           symtabsect.write(elfsym,sizeof(elfsym));
           { section }
           ObjSections.foreach(@section_write_symbol,@locals);
           { ObjSymbols }
           sym:=Tasmsymbol(ObjSymbols.First);
           while assigned(sym) do
            begin
              fillchar(elfsym,sizeof(elfsym),0);
              { symbolname, write the #0 separate to overcome 255+1 char not possible }
              elfsym.st_name:=strtabsect.datasize;
              strtabsect.writestr(sym.name);
              strtabsect.writestr(#0);
              case sym.currbind of
                AB_LOCAL,
                AB_GLOBAL :
                 elfsym.st_value:=sym.address;
                AB_COMMON :
                 elfsym.st_value:=$10;
              end;
              elfsym.st_size:=sym.size;
              case sym.currbind of
                AB_LOCAL :
                  begin
                    elfsym.st_info:=STB_LOCAL shl 4;
                    inc(locals);
                  end;
                AB_COMMON,
                AB_EXTERNAL,
                AB_GLOBAL :
                  elfsym.st_info:=STB_GLOBAL shl 4;
              end;
              if (sym.currbind<>AB_EXTERNAL) and
                 not(assigned(sym.objsection) and
                     (sym.objsection.sectype=sec_bss)) then
               begin
                 case sym.typ of
                   AT_FUNCTION :
                     elfsym.st_info:=elfsym.st_info or STT_FUNC;
                   AT_DATA :
                     elfsym.st_info:=elfsym.st_info or STT_OBJECT;
                 end;
               end;
              if sym.currbind=AB_COMMON then
               elfsym.st_shndx:=SHN_COMMON
              else
               if assigned(sym.objsection) then
                elfsym.st_shndx:=TElf32ObjSection(sym.objsection).secshidx
               else
                elfsym.st_shndx:=SHN_UNDEF;
              symtabsect.write(elfsym,sizeof(elfsym));
              sym:=tasmsymbol(sym.indexnext);
            end;
           { update the .symtab section header }
           symtabsect.shlink:=strtabsect.secshidx;
           symtabsect.shinfo:=locals;
         end;
      end;


    procedure TElf32ObjectOutput.section_write_sh_string(p:tnamedindexitem;arg:pointer);
      begin
        TElf32ObjSection(p).shstridx:=elf32data.shstrtabsect.writestr(TObjSection(p).name+#0);
        if assigned(TElf32ObjSection(p).relocsect) then
          TElf32ObjSection(p).relocsect.shstridx:=elf32data.shstrtabsect.writestr(TElf32ObjSection(p).relocsect.name+#0);
      end;


    procedure TElf32ObjectOutput.createshstrtab;
      begin
        with elf32data do
         begin
           with shstrtabsect do
            begin
              writestr(#0);
              symtabsect.shstridx:=writestr('.symtab'#0);
              strtabsect.shstridx:=writestr('.strtab'#0);
              shstrtabsect.shstridx:=writestr('.shstrtab'#0);
              ObjSections.foreach(@section_write_sh_string,nil);
            end;
         end;
      end;


    procedure TElf32ObjectOutput.writesectionheader(s:TElf32ObjSection);
      var
        sechdr : TElf32sechdr;
      begin
        fillchar(sechdr,sizeof(sechdr),0);
        sechdr.sh_name:=s.shstridx;
        sechdr.sh_type:=s.shtype;
        sechdr.sh_flags:=s.shflags;
        sechdr.sh_offset:=s.datapos;
        sechdr.sh_size:=s.datasize;
        sechdr.sh_link:=s.shlink;
        sechdr.sh_info:=s.shinfo;
        sechdr.sh_addralign:=s.addralign;
        sechdr.sh_entsize:=s.entsize;
        writer.write(sechdr,sizeof(sechdr));
      end;



    procedure TElf32ObjectOutput.writesectiondata(s:TElf32ObjSection);
      var
        hp : pdynamicblock;
      begin
        FWriter.writezeros(s.dataalignbytes);
        s.alignsection;
        hp:=s.data.firstblock;
        while assigned(hp) do
          begin
            FWriter.write(hp^.data,hp^.used);
            hp:=hp^.next;
          end;
      end;


    procedure TElf32ObjectOutput.section_number_symbol(p:tnamedindexitem;arg:pointer);
      begin
        TObjSection(p).secsymidx:=plongint(arg)^;
        inc(plongint(arg)^);
      end;


    procedure TElf32ObjectOutput.section_count_sections(p:tnamedindexitem;arg:pointer);
      begin
        TElf32ObjSection(p).secshidx:=plongint(arg)^;
        inc(plongint(arg)^);
        if TElf32ObjSection(p).relocations.count>0 then
          inc(plongint(arg)^);
      end;


    procedure TElf32ObjectOutput.section_create_relocsec(p:tnamedindexitem;arg:pointer);
      begin
        if (TElf32ObjSection(p).relocations.count>0) then
          createrelocsection(TElf32ObjSection(p));
      end;


    procedure TElf32ObjectOutput.section_set_datapos(p:tnamedindexitem;arg:pointer);
      begin
        if (aso_alloconly in TObjSection(p).secoptions) then
          TObjSection(p).datapos:=paint(arg)^
        else
          TObjSection(p).setdatapos(paint(arg)^);
      end;


    procedure TElf32ObjectOutput.section_relocsec_set_datapos(p:tnamedindexitem;arg:pointer);
      begin
        if assigned(TElf32ObjSection(p).relocsect) then
          TElf32ObjSection(p).relocsect.setdatapos(paint(arg)^);
      end;


    procedure TElf32ObjectOutput.section_write_data(p:tnamedindexitem;arg:pointer);
      begin
        if (aso_alloconly in TObjSection(p).secoptions) then
          exit;
        if TObjSection(p).data=nil then
          internalerror(200403073);
        writesectiondata(TElf32ObjSection(p));
      end;


    procedure TElf32ObjectOutput.section_write_sechdr(p:tnamedindexitem;arg:pointer);
      begin
        writesectionheader(TElf32ObjSection(p));
        if assigned(TElf32ObjSection(p).relocsect) then
          writesectionheader(TElf32ObjSection(p).relocsect);
      end;


    procedure TElf32ObjectOutput.section_write_relocsec(p:tnamedindexitem;arg:pointer);
      begin
        if assigned(TElf32ObjSection(p).relocsect) then
          writesectiondata(TElf32ObjSection(p).relocsect);
      end;



    function TElf32ObjectOutput.writedata(data:TObjData):boolean;
      var
        header : TElf32header;
        datapos : aint;
        shoffset,
        nsections : longint;
        hstab  : TElf32stab;
        empty  : array[0..63] of byte;
      begin
        result:=false;
        elf32data:=TElf32ObjData(data);
        with elf32data do
         begin
           { calc amount of sections we have }
           initsym:=2;
           nsections:=1;
           fillchar(empty,sizeof(empty),0);
           { each section requires a symbol for relocation }
           ObjSections.foreach(@section_number_symbol,@initsym);
           { also create the index in the section header table }
           ObjSections.foreach(@section_count_sections,@nsections);
           { add default sections follows }
           shstrtabsect.secshidx:=nsections;
           inc(nsections);
           symtabsect.secshidx:=nsections;
           inc(nsections);
           strtabsect.secshidx:=nsections;
           inc(nsections);
         { For the stab section we need an HdrSym which can now be
           calculated more easily }
           if assigned(stabssec) then
            begin
              hstab.strpos:=1;
              hstab.ntype:=0;
              hstab.nother:=0;
              hstab.ndesc:=(stabssec.datasize div sizeof(TElf32stab))-1{+1 according to gas output PM};
              hstab.nvalue:=stabstrsec.datasize;
              stabssec.Data.seek(0);
              stabssec.Data.write(hstab,sizeof(hstab));
            end;
         { Create the relocation sections }
           ObjSections.foreach(@section_create_relocsec,nil);
         { create .symtab and .strtab }
           createsymtab;
         { create .shstrtab }
           createshstrtab;
         { Calculate the filepositions }
           datapos:=$40; { elfheader + alignment }
           { sections first }
           ObjSections.foreach(@section_set_datapos,@datapos);
           { shstrtab }
           shstrtabsect.setdatapos(datapos);
           { section headers }
           shoffset:=datapos;
           inc(datapos,nsections*sizeof(TElf32sechdr));
           { symtab }
           symtabsect.setdatapos(datapos);
           { strtab }
           strtabsect.setdatapos(datapos);
           { .rel sections }
           ObjSections.foreach(@section_relocsec_set_datapos,@datapos);
         { Write ELF Header }
           fillchar(header,sizeof(header),0);
           header.magic0123:=$464c457f; { = #127'ELF' }
           header.file_class:=1;
           header.data_encoding:=1;
           header.file_version:=1;
           header.e_type:=1;
           header.e_machine:=3;
           header.e_version:=1;
           header.e_shoff:=shoffset;
           header.e_shstrndx:=shstrtabsect.secshidx;
           header.e_shnum:=nsections;
           header.e_ehsize:=sizeof(TElf32header);
           header.e_shentsize:=sizeof(TElf32sechdr);
           writer.write(header,sizeof(header));
           writer.write(empty,$40-sizeof(header)); { align }
         { Sections }
           ObjSections.foreach(@section_write_data,nil);
         { .shstrtab }
           writesectiondata(shstrtabsect);
         { section headers, start with an empty header for sh_undef }
           writer.write(empty,sizeof(TElf32sechdr));
           ObjSections.foreach(@section_write_sechdr,nil);
           writesectionheader(shstrtabsect);
           writesectionheader(symtabsect);
           writesectionheader(strtabsect);
         { .symtab }
           writesectiondata(symtabsect);
         { .strtab }
           writesectiondata(strtabsect);
         { .rel sections }
           ObjSections.foreach(@section_write_relocsec,nil);
         end;
        result:=true;
      end;


{****************************************************************************
                               TELFAssembler
****************************************************************************}

    constructor TElf32Assembler.Create(smart:boolean);
      begin
        inherited Create(smart);
        ObjOutput:=TElf32ObjectOutput.create(smart);
      end;


{*****************************************************************************
                                  Initialize
*****************************************************************************}

    const
       as_i386_elf32_info : tasminfo =
          (
            id     : as_i386_elf32;
            idtxt  : 'ELF';
            asmbin : '';
            asmcmd : '';
            supported_target : system_any;  //target_i386_linux;
            flags : [af_outputbinary,af_smartlink_sections];
            labelprefix : '.L';
            comment : '';
          );


initialization
  RegisterAssembler(as_i386_elf32_info,TElf32Assembler);
end.
