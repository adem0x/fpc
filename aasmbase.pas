{
    Copyright (c) 1998-2002 by Florian Klaempfl

    This unit implements an abstract asmoutput class for all processor types

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
{ @abstract(This unit implements an abstract asm output class for all processor types)
  This unit implements an abstract assembler output class for all processors, these
  are then overriden for each assembler writer to actually write the data in these
  classes to an assembler file.
}

unit aasmbase;

{$i fpcdefs.inc}

interface

    uses
       cutils,cclasses,
       globtype,globals,systems
       ;

    type
       TObjSection = class;
       TObjData = class;

       TAsmsymbind=(AB_NONE,AB_EXTERNAL,AB_COMMON,AB_LOCAL,AB_GLOBAL);

       TAsmsymtype=(AT_NONE,AT_FUNCTION,AT_DATA,AT_SECTION,AT_LABEL);

       TAsmRelocationType = (RELOC_ABSOLUTE,RELOC_RELATIVE,RELOC_RVA);

       TObjSectionType=(sec_none,
         sec_code,sec_data,sec_rodata,sec_bss,sec_threadvar,
         { used for executable creation }
         sec_common,
         { custom section, no prefix }
         sec_custom,
         { used for darwin import stubs }
         sec_stub,
         { stabs }
         sec_stab,sec_stabstr,
         { win32 }
         sec_idata2,sec_idata4,sec_idata5,sec_idata6,sec_idata7,sec_edata,
         { C++ exception handling unwinding (uses dwarf) }
         sec_eh_frame,
         { dwarf }
         sec_debug_frame,
         sec_debug_info,
         sec_debug_line,
         sec_debug_abbrev,
         { ELF resources }
         sec_fpc,
         { Table of contents section }
         sec_toc
       );

       TObjSectionOption = (aso_alloconly,aso_executable);
       TObjSectionOptions = set of TObjSectionOption;

       TAsmSymbol = class(TNamedIndexItem)
       private
         { this need to be incremented with every symbol loading into the
           paasmoutput, thus in loadsym/loadref/const_symbol (PFV) }
         refs       : longint;
       public
         defbind,
         currbind   : TAsmsymbind;
         typ        : TAsmsymtype;
         { the next fields are filled in the binary writer }
         section    : TObjSection;
         address,
         size       : aint;
         { Alternate symbol which can be used for 'renaming' needed for
           inlining }
         altsymbol  : tasmsymbol;
         { pointer to ObjData that is the owner of this symbol }
         owner      : TObjData;
         { Is the symbol in the used list }
         inusedlist : boolean;
         { assembler pass label is set, used for detecting multiple labels }
         pass       : byte;
         ppuidx     : longint;
         constructor create(const s:string;_bind:TAsmsymbind;_typ:Tasmsymtype);
         procedure reset;
         function  is_used:boolean;
         procedure increfs;
         procedure decrefs;
         function getrefs: longint;
         procedure setaddress(_pass:byte;sec:TObjSection;offset,len:aint);
       end;

       { is the label only there for getting an address (e.g. for i/o
         checks -> alt_addr) or is it a jump target (alt_jump), for debug
         info alt_dbgline and alt_dbgfile }
       TAsmLabelType = (alt_jump,alt_addr,alt_data,alt_dbgline,alt_dbgfile,alt_dbgtype,alt_dbgframe);

       TAsmLabel = class(TAsmSymbol)
         labelnr   : longint;
         labeltype : TAsmLabelType;
         is_set    : boolean;
         constructor createlocal(nr:longint;ltyp:TAsmLabelType);
         constructor createglobal(const modulename:string;nr:longint;ltyp:TAsmLabelType);
         function getname:string;override;
       end;

       TAsmRelocation = class(TLinkedListItem)
          address,
          orgsize  : aint;  { original size of the symbol to relocate, required for COFF }
          symbol   : TAsmSymbol;
          section  : TObjSection; { only used if symbol=nil }
          typ      : TAsmRelocationType;
          constructor CreateSymbol(Aaddress:aint;s:Tasmsymbol;Atyp:TAsmRelocationType);
          constructor CreateSymbolSize(Aaddress:aint;s:Tasmsymbol;Aorgsize:aint;Atyp:TAsmRelocationType);
          constructor CreateSection(Aaddress:aint;sec:TObjSection;Atyp:TAsmRelocationType);
       end;

       TObjSection = class(TNamedIndexItem)
         owner      : TObjData;
         secoptions : TObjSectionOptions;
         sectype    : TObjSectionType;
         secsymidx  : longint;   { index for the section in symtab }
         addralign  : longint;   { alignment of the section }
         { size of the data and in the file }
         dataalignbytes : longint;
         data      : TDynamicArray;
         datasize,
         datapos   : aint;
         { size and position in memory }
         memsize,
         mempos    : aint;
         { relocation }
         relocations : TLinkedList;
         constructor create(const Aname:string;Atype:TObjSectionType;Aalign:longint;Aoptions:TObjSectionOptions);virtual;
         destructor  destroy;override;
         function  write(const d;l:aint):aint;
         function  writestr(const s:string):aint;
         procedure writealign(l:longint);
         function  aligneddatasize:aint;
         procedure setdatapos(var dpos:aint);
         procedure alignsection;
         procedure alloc(l:aint);
         procedure addsymreloc(ofs:aint;p:tasmsymbol;relative:TAsmRelocationType);
         procedure addsectionreloc(ofs:aint;sec:TObjSection;relative:TAsmRelocationType);
         procedure fixuprelocs;virtual;
       end;
       TObjSectionClass = class of TObjSection;

       TObjData = class(TLinkedListItem)
       private
         FName      : string[80];
         FCurrSec   : TObjSection;
         { Sections will be stored in order in SectsIndex, this is at least
           required for stabs debuginfo. The SectsDict is only used for lookups (PFV) }
         FSectionsDict   : TDictionary;
         FSectionsIndex  : TIndexArray;
         FCObjSection : TObjSectionClass;
         { Symbols that will be defined in this object file }
         FSymbols   : TIndexArray;
         { Special info sections that are written to during object generation }
         FStabsRecSize : longint;
         FStabsSec,
         FStabStrSec : TObjSection;
         procedure section_reset(p:tnamedindexitem;arg:pointer);
         procedure section_fixuprelocs(p:tnamedindexitem;arg:pointer);
       protected
         property StabsRecSize:longint read FStabsRecSize write FStabsRecSize;
         property StabsSec:TObjSection read FStabsSec write FStabsSec;
         property StabStrSec:TObjSection read FStabStrSec write FStabStrSec;
         property CAsmSection:TObjSectionClass read FCObjSection write FCObjSection;
       public
         constructor create(const n:string);virtual;
         destructor  destroy;override;
         function  sectionname(atype:TObjSectiontype;const aname:string):string;virtual;
         function  createsection(atype:TObjSectiontype;const aname:string;aalign:longint;aoptions:TObjSectionOptions):TObjSection;virtual;
         function  findsection(const aname:string):TObjSection;
         procedure setsection(asec:TObjSection);
         procedure alloc(len:aint);
         procedure allocalign(len:longint);
         procedure allocstab(p:pchar);
         procedure allocsymbol(currpass:byte;p:tasmsymbol;len:aint);
         procedure writebytes(var data;len:aint);
         procedure writereloc(data,len:aint;p:tasmsymbol;relative:TAsmRelocationType);virtual;abstract;
         procedure writesymbol(p:tasmsymbol);virtual;abstract;
         procedure writestab(offset:aint;ps:tasmsymbol;nidx,nother,line:longint;p:pchar);virtual;abstract;
         procedure beforealloc;virtual;
         procedure beforewrite;virtual;
         procedure afteralloc;virtual;
         procedure afterwrite;virtual;
         procedure resetsections;
         procedure fixuprelocs;
         property Name:string[80] read FName;
         property CurrSec:TObjSection read FCurrSec;
         property Symbols:TindexArray read FSymbols;
         property Sections:TIndexArray read FSectionsIndex;
       end;
       TObjDataClass = class of TObjData;

       tasmsymbolidxarr = array[0..($7fffffff div sizeof(pointer))-1] of tasmsymbol;
       pasmsymbolidxarr = ^tasmsymbolidxarr;

       TObjLibraryData = class(TLinkedListItem)
       private
         nextaltnr   : longint;
         nextlabelnr : array[Tasmlabeltype] of longint;
       public
         name,
         realname     : string[80];
         symbolsearch : tdictionary; { contains ALL assembler symbols }
         usedasmsymbollist : tsinglelist;
         { ppu }
         asmsymbolppuidx : longint;
         asmsymbolidx : pasmsymbolidxarr; { used for translating ppu index->asmsymbol }
         constructor create(const n:string);
         destructor  destroy;override;
         procedure Freeasmsymbolidx;
         procedure DerefAsmsymbol(var s:tasmsymbol);
         { asmsymbol }
         function  newasmsymbol(const s : string;_bind:TAsmSymBind;_typ:TAsmsymtype) : tasmsymbol;
         function  getasmsymbol(const s : string) : tasmsymbol;
         function  renameasmsymbol(const sold, snew : string):tasmsymbol;
         function  newasmlabel(nr:longint;alt:tasmlabeltype;is_global:boolean) : tasmlabel;
         {# create a new assembler label }
         procedure getlabel(var l : tasmlabel;alt:tasmlabeltype);
         {# create a new assembler label for jumps }
         procedure getjumplabel(var l : tasmlabel);
         { make l as a new label and flag is_addr }
         procedure getaddrlabel(var l : tasmlabel);
         { make l as a new label and flag is_data }
         procedure getdatalabel(var l : tasmlabel);
         {# return a label number }
         procedure CreateUsedAsmSymbolList;
         procedure DestroyUsedAsmSymbolList;
         procedure UsedAsmSymbolListInsert(p:tasmsymbol);
         { generate an alternative (duplicate) symbol }
         procedure GenerateAltSymbol(p:tasmsymbol);
         { reset alternative symbol information }
         procedure UsedAsmSymbolListResetAltSym;
         procedure UsedAsmSymbolListReset;
         procedure UsedAsmSymbolListCheckUndefined;
       end;

    function LengthUleb128(a: aword) : byte;
    function LengthSleb128(a: aint) : byte;

    const
      { alt_jump,alt_addr,alt_data,alt_dbgline,alt_dbgfile }
      asmlabeltypeprefix : array[tasmlabeltype] of char = ('j','a','d','l','f','t','c');

    var
      objectlibrary : TObjLibraryData;


implementation

    uses
      strings,
      verbose;

    const
      sectsgrow   = 100;
      symbolsgrow = 100;


    function LengthUleb128(a: aword) : byte;
      var
        b: byte;
      begin
        result:=0;
        repeat
          b := a and $7f;
          a := a shr 7;
          if a<>0 then
            b := b or $80;
          inc(result);
          if a=0 then
            break;
        until false;
      end;


    function LengthSleb128(a: aint) : byte;
      var
        b, size: byte;
        neg, more: boolean;
      begin
        more := true;
        neg := a < 0;
        size := sizeof(a)*8;
        result:=0;
        repeat
          b := a and $7f;
          a := a shr 7;
          if neg then
            a := a or -(1 shl (size - 7));
          if (((a = 0) and
               (b and $40 = 0)) or
              ((a = -1) and
               (b and $40 <> 0))) then
            more := false
          else
            b := b or $80;
          inc(result);
          if not(more) then
            break;
        until false;
      end;


{*****************************************************************************
                                 TAsmSymbol
*****************************************************************************}

    constructor tasmsymbol.create(const s:string;_bind:TAsmsymbind;_typ:Tasmsymtype);
      begin;
        inherited createname(s);
        reset;
        defbind:=_bind;
        typ:=_typ;
        inusedlist:=false;
        pass:=255;
        ppuidx:=-1;
        { mainly used to remove unused labels from the al_procedures }
        refs:=0;
      end;


    procedure tasmsymbol.reset;
      begin
        { reset section info }
        section:=nil;
        address:=0;
        size:=0;
        indexnr:=-1;
        pass:=255;
        currbind:=AB_EXTERNAL;
        altsymbol:=nil;
{        taiowner:=nil;}
      end;


    function tasmsymbol.is_used:boolean;
      begin
        is_used:=(refs>0);
      end;


    procedure tasmsymbol.increfs;
      begin
        inc(refs);
      end;


    procedure tasmsymbol.decrefs;
      begin
        dec(refs);
        if refs<0 then
          internalerror(200211121);
      end;


    function tasmsymbol.getrefs: longint;
      begin
        getrefs := refs;
      end;


    procedure tasmsymbol.setaddress(_pass:byte;sec:TObjSection;offset,len:aint);
      begin
        if (_pass=pass) then
         begin
           Message1(asmw_e_duplicate_label,name);
           exit;
         end;
        pass:=_pass;
        section:=sec;
        address:=offset;
        size:=len;
        { when the bind was reset to External, set it back to the default
          bind it got when defined }
        if (currbind=AB_EXTERNAL) and (defbind<>AB_NONE) then
         currbind:=defbind;
      end;


{*****************************************************************************
                                 TAsmLabel
*****************************************************************************}

    constructor tasmlabel.createlocal(nr:longint;ltyp:TAsmLabelType);
      begin;
        inherited create(target_asm.labelprefix+asmlabeltypeprefix[ltyp]+tostr(nr),AB_LOCAL,AT_LABEL);
        labelnr:=nr;
        labeltype:=ltyp;
        is_set:=false;
      end;


    constructor tasmlabel.createglobal(const modulename:string;nr:longint;ltyp:TAsmLabelType);
      begin;
        inherited create('_$'+modulename+'$_L'+asmlabeltypeprefix[ltyp]+tostr(nr),AB_GLOBAL,AT_DATA);
        labelnr:=nr;
        labeltype:=ltyp;
        is_set:=false;
        { write it always }
        increfs;
      end;


    function tasmlabel.getname:string;
      begin
        getname:=inherited getname;
        increfs;
      end;


{****************************************************************************
                              TAsmRelocation
****************************************************************************}

    constructor TAsmRelocation.CreateSymbol(Aaddress:aint;s:Tasmsymbol;Atyp:TAsmRelocationType);
      begin
        Address:=Aaddress;
        Symbol:=s;
        OrgSize:=0;
        Section:=nil;
        Typ:=Atyp;
      end;


    constructor TAsmRelocation.CreateSymbolSize(Aaddress:aint;s:Tasmsymbol;Aorgsize:aint;Atyp:TAsmRelocationType);
      begin
        Address:=Aaddress;
        Symbol:=s;
        OrgSize:=Aorgsize;
        Section:=nil;
        Typ:=Atyp;
      end;


    constructor TAsmRelocation.CreateSection(Aaddress:aint;sec:TObjSection;Atyp:TAsmRelocationType);
      begin
        Address:=Aaddress;
        Symbol:=nil;
        OrgSize:=0;
        Section:=sec;
        Typ:=Atyp;
      end;


{****************************************************************************
                              TObjSection
****************************************************************************}

    constructor TObjSection.create(const Aname:string;Atype:TObjSectionType;Aalign:longint;Aoptions:TObjSectionOptions);
      begin
        inherited createname(Aname);
        sectype:=Atype;
        name:=Aname;
        secoptions:=Aoptions;
        secsymidx:=0;
        addralign:=Aalign;
        { data }
        datasize:=0;
        datapos:=0;
        if (aso_alloconly in aoptions) then
         data:=nil
        else
         Data:=TDynamicArray.Create(8192);
        { memory }
        mempos:=0;
        memsize:=0;
        { relocation }
        relocations:=TLinkedList.Create;
      end;


    destructor TObjSection.destroy;
      begin
        if assigned(Data) then
          Data.Free;
        relocations.free;
      end;


    function TObjSection.write(const d;l:aint):aint;
      begin
        write:=datasize;
        if assigned(Data) then
          Data.write(d,l);
        inc(datasize,l);
      end;


    function TObjSection.writestr(const s:string):aint;
      begin
        writestr:=datasize;
        if assigned(Data) then
          Data.write(s[1],length(s));
        inc(datasize,length(s));
      end;


    procedure TObjSection.writealign(l:longint);
      var
        i : longint;
        empty : array[0..63] of char;
      begin
        { no alignment needed for 0 or 1 }
        if l<=1 then
         exit;
        i:=datasize mod l;
        if i>0 then
         begin
           if assigned(data) then
            begin
              fillchar(empty,sizeof(empty),0);
              Data.write(empty,l-i);
            end;
           inc(datasize,l-i);
         end;
      end;


    function TObjSection.aligneddatasize:aint;
      begin
        aligneddatasize:=align(datasize,addralign);
      end;


    procedure TObjSection.setdatapos(var dpos:aint);
      var
        alignedpos : aint;
      begin
        { get aligned datapos }
        alignedpos:=align(dpos,addralign);
        dataalignbytes:=alignedpos-dpos;
        datapos:=alignedpos;
        { update datapos }
        dpos:=datapos+aligneddatasize;
      end;


    procedure TObjSection.alignsection;
      begin
        writealign(addralign);
      end;


    procedure TObjSection.alloc(l:aint);
      begin
        inc(datasize,l);
      end;


    procedure TObjSection.addsymreloc(ofs:aint;p:tasmsymbol;relative:TAsmRelocationType);
      var
        r : TAsmRelocation;
      begin
        r:=TAsmRelocation.Create;
        r.address:=ofs;
        r.orgsize:=0;
        r.symbol:=p;
        r.section:=nil;
        r.typ:=relative;
        relocations.concat(r);
      end;


    procedure TObjSection.addsectionreloc(ofs:aint;sec:TObjSection;relative:TAsmRelocationType);
      var
        r : TAsmRelocation;
      begin
        r:=TAsmRelocation.Create;
        r.address:=ofs;
        r.symbol:=nil;
        r.orgsize:=0;
        r.section:=sec;
        r.typ:=relative;
        relocations.concat(r);
      end;


    procedure TObjSection.fixuprelocs;
      begin
      end;


{****************************************************************************
                                TObjData
****************************************************************************}

    constructor TObjData.create(const n:string);
      begin
        inherited create;
        FName:=n;
        { sections, the SectsIndex owns the items, the FSectionsDict
          is only used for lookups }
        FSectionsDict:=tdictionary.create;
        FSectionsDict.noclear:=true;
        FSectionsIndex:=tindexarray.create(sectsgrow);
        FStabsRecSize:=1;
        FStabsSec:=nil;
        FStabStrSec:=nil;
        { symbols }
        FSymbols:=tindexarray.create(symbolsgrow);
        FSymbols.noclear:=true;
        { section class type for creating of new sections }
        FCObjSection:=TObjSection;
      end;


    destructor TObjData.destroy;
      begin
        FSectionsDict.free;
        FSectionsIndex.free;
        FSymbols.free;
      end;


    function TObjData.sectionname(atype:TObjSectiontype;const aname:string):string;
      const
        secnames : array[TObjSectiontype] of string[13] = ('',
          'code','data','rodata','bss','threadvar',
          'common',
          'note',
          'text',
          'stab','stabstr',
          'idata2','idata4','idata5','idata6','idata7','edata',
          'eh_frame',
          'debug_frame','debug_info','debug_line','debug_abbrev',
          'fpc',
          'toc'
        );
      begin
        if aname<>'' then
          result:=secnames[atype]+'.'+aname
        else
          result:=secnames[atype];
      end;


    function TObjData.createsection(atype:TObjSectiontype;const aname:string;aalign:longint;aoptions:TObjSectionOptions):TObjSection;
      var
        secname : string;
      begin
        secname:=sectionname(atype,aname);
        result:=TObjSection(FSectionsDict.search(secname));
        if not assigned(result) then
          begin
            { bss sections are always allocation only }
            if atype=sec_bss then
              include(aoptions,aso_alloconly);
            result:=CAsmSection.create(secname,atype,aalign,aoptions);
            FSectionsDict.Insert(result);
            FSectionsIndex.Insert(result);
            result.owner:=self;
          end;
        FCurrSec:=result;
      end;


    function TObjData.FindSection(const aname:string):TObjSection;
      begin
        result:=TObjSection(FSectionsDict.Search(aname));
      end;


    procedure TObjData.setsection(asec:TObjSection);
      begin
        if asec.owner<>self then
          internalerror(200403041);
        FCurrSec:=asec;
      end;


    procedure TObjData.writebytes(var data;len:aint);
      begin
        if not assigned(currsec) then
          internalerror(200402251);
        currsec.write(data,len);
      end;


    procedure TObjData.alloc(len:aint);
      begin
        if not assigned(currsec) then
          internalerror(200402252);
        currsec.alloc(len);
      end;


    procedure TObjData.allocalign(len:longint);
      var
        modulo : aint;
      begin
        if not assigned(currsec) then
          internalerror(200402253);
        modulo:=currsec.datasize mod len;
        if modulo > 0 then
          currsec.alloc(len-modulo);
      end;


    procedure TObjData.allocsymbol(currpass:byte;p:tasmsymbol;len:aint);
      begin
        p.setaddress(currpass,currsec,currsec.datasize,len);
      end;


    procedure TObjData.allocstab(p:pchar);
      begin
        if not(assigned(FStabsSec) and assigned(FStabStrSec)) then
          internalerror(200402254);
        FStabsSec.alloc(FStabsRecSize);
        if assigned(p) and (p[0]<>#0) then
          FStabStrSec.alloc(strlen(p)+1);
      end;


    procedure TObjData.section_reset(p:tnamedindexitem;arg:pointer);
      begin
        with TObjSection(p) do
          begin
            datasize:=0;
            datapos:=0;
          end;
      end;


    procedure TObjData.section_fixuprelocs(p:tnamedindexitem;arg:pointer);
      begin
        TObjSection(p).fixuprelocs;
      end;


    procedure TObjData.beforealloc;
      begin
      end;


    procedure TObjData.beforewrite;
      begin
      end;


    procedure TObjData.afteralloc;
      begin
      end;


    procedure TObjData.afterwrite;
      begin
      end;


    procedure TObjData.resetsections;
      begin
        FSectionsDict.foreach(@section_reset,nil);
      end;


    procedure TObjData.fixuprelocs;
      begin
        FSectionsDict.foreach(@section_fixuprelocs,nil);
      end;


{****************************************************************************
                                TObjLibraryData
****************************************************************************}

    constructor TObjLibraryData.create(const n:string);
      var
        alt : TAsmLabelType;
      begin
        inherited create;
        realname:=n;
        name:=upper(n);
        { symbols }
        symbolsearch:=tdictionary.create;
        symbolsearch.usehash;
        { labels }
        nextaltnr:=1;
        for alt:=low(TAsmLabelType) to high(TAsmLabelType) do
          nextlabelnr[alt]:=1;
        { ppu }
        asmsymbolppuidx:=0;
        asmsymbolidx:=nil;
      end;


    destructor TObjLibraryData.destroy;
      begin
        symbolsearch.free;
        Freeasmsymbolidx;
      end;


    procedure TObjLibraryData.Freeasmsymbolidx;
      begin
        if assigned(asmsymbolidx) then
         begin
           Freemem(asmsymbolidx);
           asmsymbolidx:=nil;
         end;
      end;


    procedure TObjLibraryData.DerefAsmsymbol(var s:tasmsymbol);
      begin
        if assigned(s) then
         begin
           if not assigned(asmsymbolidx) then
             internalerror(200208072);
           if (ptrint(pointer(s))<1) or (ptrint(pointer(s))>asmsymbolppuidx) then
             internalerror(200208073);
           s:=asmsymbolidx^[ptrint(pointer(s))-1];
         end;
      end;


    function TObjLibraryData.newasmsymbol(const s : string;_bind:TAsmSymBind;_typ:Tasmsymtype) : tasmsymbol;
      var
        hp : tasmsymbol;
      begin
        hp:=tasmsymbol(symbolsearch.search(s));
        if assigned(hp) then
         begin
           {$IFDEF EXTDEBUG}
           if (_typ <> AT_NONE) and
              (hp.typ <> _typ) and
              not(cs_compilesystem in aktmoduleswitches) and
              (target_info.system <> system_powerpc_darwin) then
             begin
               //Writeln('Error symbol '+hp.name+' type is ',Ord(_typ),', should be ',Ord(hp.typ));
               InternalError(2004031501);
             end;
           {$ENDIF}
           if (_bind<>AB_EXTERNAL) then
             hp.defbind:=_bind
         end
        else
         begin
           { Not found, insert it. }
           hp:=tasmsymbol.create(s,_bind,_typ);
           symbolsearch.insert(hp);
         end;
        newasmsymbol:=hp;
      end;


    function TObjLibraryData.getasmsymbol(const s : string) : tasmsymbol;
      begin
        getasmsymbol:=tasmsymbol(symbolsearch.search(s));
      end;


    function TObjLibraryData.renameasmsymbol(const sold, snew : string):tasmsymbol;
      begin
        renameasmsymbol:=tasmsymbol(symbolsearch.rename(sold,snew));
      end;


    procedure TObjLibraryData.CreateUsedAsmSymbolList;
      begin
        if assigned(usedasmsymbollist) then
         internalerror(78455782);
        usedasmsymbollist:=TSingleList.create;
      end;


    procedure TObjLibraryData.DestroyUsedAsmSymbolList;
      begin
        usedasmsymbollist.destroy;
        usedasmsymbollist:=nil;
      end;


    procedure TObjLibraryData.UsedAsmSymbolListInsert(p:tasmsymbol);
      begin
        if not p.inusedlist then
         usedasmsymbollist.insert(p);
        p.inusedlist:=true;
      end;


    procedure TObjLibraryData.GenerateAltSymbol(p:tasmsymbol);
      begin
        if not assigned(p.altsymbol) then
         begin
           p.altsymbol:=tasmsymbol.create(p.name+'_'+tostr(nextaltnr),p.defbind,p.typ);
           symbolsearch.insert(p.altsymbol);
           { add also the original sym to the usedasmsymbollist,
             that list is used to reset the altsymbol }
           if not p.inusedlist then
            usedasmsymbollist.insert(p);
           p.inusedlist:=true;
         end;
      end;


    procedure TObjLibraryData.UsedAsmSymbolListReset;
      var
        hp : tasmsymbol;
      begin
        hp:=tasmsymbol(usedasmsymbollist.first);
        while assigned(hp) do
         begin
           with hp do
            begin
              reset;
              inusedlist:=false;
            end;
           hp:=tasmsymbol(hp.listnext);
         end;
      end;


    procedure TObjLibraryData.UsedAsmSymbolListResetAltSym;
      var
        hp : tasmsymbol;
      begin
        hp:=tasmsymbol(usedasmsymbollist.first);
        inc(nextaltnr);
        while assigned(hp) do
         begin
           with hp do
            begin
              altsymbol:=nil;
              inusedlist:=false;
            end;
           hp:=tasmsymbol(hp.listnext);
         end;
      end;


    procedure TObjLibraryData.UsedAsmSymbolListCheckUndefined;
      var
        hp : tasmsymbol;
      begin
        hp:=tasmsymbol(usedasmsymbollist.first);
        while assigned(hp) do
         begin
           with hp do
            begin
              if is_used and
                 (section=nil) and
                 not(currbind in [AB_EXTERNAL,AB_COMMON]) then
               Message1(asmw_e_undefined_label,name);
            end;
           hp:=tasmsymbol(hp.listnext);
         end;
      end;


    function  TObjLibraryData.newasmlabel(nr:longint;alt:tasmlabeltype;is_global:boolean) : tasmlabel;
      var
        hp : tasmlabel;
      begin
        if is_global then
         hp:=tasmlabel.createglobal(name,nr,alt)
       else
         hp:=tasmlabel.createlocal(nr,alt);
        symbolsearch.insert(hp);
        newasmlabel:=hp;
      end;


    procedure TObjLibraryData.getlabel(var l : tasmlabel;alt:tasmlabeltype);
      begin
        l:=tasmlabel.createlocal(nextlabelnr[alt],alt);
        inc(nextlabelnr[alt]);
        symbolsearch.insert(l);
      end;

    procedure TObjLibraryData.getjumplabel(var l : tasmlabel);
      begin
        l:=tasmlabel.createlocal(nextlabelnr[alt_jump],alt_jump);
        inc(nextlabelnr[alt_jump]);
        symbolsearch.insert(l);
      end;


    procedure TObjLibraryData.getdatalabel(var l : tasmlabel);
      begin
        l:=tasmlabel.createglobal(name,nextlabelnr[alt_data],alt_data);
        inc(nextlabelnr[alt_data]);
        symbolsearch.insert(l);
      end;


    procedure TObjLibraryData.getaddrlabel(var l : tasmlabel);
      begin
        l:=tasmlabel.createlocal(nextlabelnr[alt_addr],alt_addr);
        inc(nextlabelnr[alt_addr]);
        symbolsearch.insert(l);
      end;


end.
