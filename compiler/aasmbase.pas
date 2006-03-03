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

       TObjRelocationType = (RELOC_ABSOLUTE,RELOC_RELATIVE,RELOC_RVA);

       TAsmSectiontype=(sec_none,
         sec_code,
         sec_data,
         sec_rodata,
         sec_bss,
         sec_threadvar,
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

       TObjSectionOption = (
         { Has data available in the file }
         oso_data,
         { Is loaded into memory }
         oso_load,
         { Not loaded into memory }
         oso_noload,
         { Read only }
         oso_readonly,
         { Read/Write }
         oso_write,
         { Contains executable instructions }
         oso_executable,
         { Never discard section }
         oso_keep,
         { Special common symbols }
         oso_common,
         { Contains debug info and can be stripped }
         oso_debug,
         { Contains only strings }
         oso_strings
       );

       TObjSectionOptions = set of TObjSectionOption;

       TAsmSymbol = class(TNamedIndexItem)
       private
         { this need to be incremented with every symbol loading into the
           taasmoutput with loadsym/loadref/const_symbol (PFV) }
         refs       : longint;
       public
         bind       : TAsmsymbind;
         typ        : TAsmsymtype;
         { Alternate symbol which can be used for 'renaming' needed for
           asm inlining. Also used for external and common solving during linking }
         altsymbol  : TAsmSymbol;
         { Cached objsymbol }
         cachedobjsymbol : TObject;
         constructor create(const s:string;_bind:TAsmsymbind;_typ:Tasmsymtype);
         function  is_used:boolean;
         procedure increfs;
         procedure decrefs;
         function getrefs: longint;
       end;

       { is the label only there for getting an DataOffset (e.g. for i/o
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

       TObjSymbol = class(TNamedIndexItem)
       public
         bind       : TAsmsymbind;
         typ        : TAsmsymtype;
         { Current assemble pass, used to detect duplicate labels }
         pass       : byte;
         objsection : TObjSection;
         symidx     : longint;
         offset,
         size       : aint;
         { Used for external and common solving during linking }
         altsymbol  : TObjSymbol;
         constructor create(const s:string);
         function  address:aint;
         procedure SetAddress(apass:byte;aobjsec:TObjSection;abind:TAsmsymbind;atyp:Tasmsymtype);
       end;

       { Stabs is common for all targets }
       TObjStabEntry=packed record
          strpos  : longint;
          ntype   : byte;
          nother  : byte;
          ndesc   : word;
          nvalue  : longint;
       end;
       PObjStabEntry=^TObjStabEntry;

       TObjRelocation = class(TLinkedListItem)
          DataOffset,
          orgsize    : aint;  { original size of the symbol to relocate, required for COFF }
          symbol     : TObjSymbol;
          objsection : TObjSection; { only used if symbol=nil }
          typ        : TObjRelocationType;
          constructor CreateSymbol(ADataOffset:aint;s:TObjSymbol;Atyp:TObjRelocationType);
          constructor CreateSymbolSize(ADataOffset:aint;s:TObjSymbol;Aorgsize:aint;Atyp:TObjRelocationType);
          constructor CreateSection(ADataOffset:aint;aobjsec:TObjSection;Atyp:TObjRelocationType);
       end;

       TObjSection = class(TNamedIndexItem)
         ObjData    : TObjData;
         SecOptions : TObjSectionOptions;
         SecSymIdx  : longint;   { index for the section in symtab }
         SecAlign   : shortint;   { alignment of the section }
         { section data }
         Data       : TDynamicArray;
         Size,
         DataPos,
         MemPos     : aint;
         DataAlignBytes : shortint;
         { executable linking }
         exesection  : TNamedIndexItem; { TExeSection }
         { relocation }
         relocations : TLinkedList;
         constructor create(const Aname:string;Aalign:shortint;Aoptions:TObjSectionOptions);virtual;
         destructor  destroy;override;
         function  write(const d;l:aint):aint;
         function  writestr(const s:string):aint;
         function  WriteZeros(l:longint):aint;
         procedure setmempos(var mpos:aint);
         procedure setdatapos(var dpos:aint);
         procedure alloc(l:aint);
         procedure addsymreloc(ofs:aint;p:TObjSymbol;relative:TObjRelocationType);
         procedure addsectionreloc(ofs:aint;aobjsec:TObjSection;relative:TObjRelocationType);
         procedure fixuprelocs;virtual;
       end;
       TObjSectionClass = class of TObjSection;

       TObjData = class(TLinkedListItem)
       private
         FName       : string[80];
         FCurrObjSec : TObjSection;
         { ObjSections will be stored in order in SectsIndex, this is at least
           required for stabs debuginfo. The SectsDict is only used for lookups (PFV) }
         FObjSectionsDict   : TDictionary;
         FObjSectionsIndex  : TIndexArray;
         FCObjSection       : TObjSectionClass;
         { Symbols that will be defined in this object file }
         FObjSymbolsIndex   : TList;
         FObjSymbolsDict    : TDictionary;
         FCachedAsmSymbolList : tlist;
         { Special info sections that are written to during object generation }
         FStabsObjSec,
         FStabStrObjSec : TObjSection;
         procedure section_reset(p:tnamedindexitem;arg:pointer);
         procedure section_afteralloc(p:tnamedindexitem;arg:pointer);
         procedure section_afterwrite(p:tnamedindexitem;arg:pointer);
         procedure section_fixuprelocs(p:tnamedindexitem;arg:pointer);
       protected
         property StabsSec:TObjSection read FStabsObjSec write FStabsObjSec;
         property StabStrSec:TObjSection read FStabStrObjSec write FStabStrObjSec;
         property CObjSection:TObjSectionClass read FCObjSection write FCObjSection;
       public
         CurrPass  : byte;
         ImageBase : aint;
         constructor create(const n:string);virtual;
         destructor  destroy;override;
         { Sections }
         function  sectionname(atype:TAsmSectiontype;const aname:string):string;virtual;
         function  sectiontype2options(atype:TAsmSectiontype):TObjSectionOptions;virtual;
         function  sectiontype2align(atype:TAsmSectiontype):shortint;virtual;
         function  createsection(atype:TAsmSectionType;const aname:string):TObjSection;
         function  createsection(const aname:string;aalign:shortint;aoptions:TObjSectionOptions):TObjSection;virtual;
         procedure CreateDebugSections;virtual;
         function  findsection(const aname:string):TObjSection;
         procedure removesection(asec:TObjSection);
         procedure setsection(asec:TObjSection);
         { Symbols }
         function  symboldefine(asmsym:TAsmSymbol):TObjSymbol;
         function  symboldefine(const aname:string;abind:TAsmsymbind;atyp:Tasmsymtype):TObjSymbol;
         function  symbolref(asmsym:TAsmSymbol):TObjSymbol;
         function  symbolref(const aname:string):TObjSymbol;
         procedure ResetCachedAsmSymbols;
         { Allocation }
         procedure alloc(len:aint);
         procedure allocalign(len:shortint);
         procedure allocstab(p:pchar);
         procedure writebytes(var data;len:aint);
         procedure writereloc(data,len:aint;p:TObjSymbol;relative:TObjRelocationType);virtual;abstract;
         procedure writestab(offset:aint;ps:TObjSymbol;nidx,nother:byte;ndesc:word;p:pchar);virtual;abstract;
         procedure beforealloc;virtual;
         procedure beforewrite;virtual;
         procedure afteralloc;virtual;
         procedure afterwrite;virtual;
         procedure resetsections;
         procedure fixuprelocs;
         property Name:string[80] read FName;
         property CurrObjSec:TObjSection read FCurrObjSec;
         property ObjSymbols:TList read FObjSymbolsIndex;
         property ObjSections:TIndexArray read FObjSectionsIndex;
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
         AltSymbollist : tlist;
         constructor create(const n:string);
         destructor  destroy;override;
         { asmsymbol }
         function  newasmsymbol(const s : string;_bind:TAsmSymBind;_typ:TAsmsymtype) : tasmsymbol;
         function  getasmsymbol(const s : string) : tasmsymbol;
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
         { generate an alternative (duplicate) symbol }
         procedure GenerateAltSymbol(p:tasmsymbol);
         procedure ResetAltSymbols;
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
        bind:=_bind;
        typ:=_typ;
        { used to remove unused labels from the al_procedures }
        refs:=0;
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


{*****************************************************************************
                                 TObjSymbol
*****************************************************************************}

    constructor TObjSymbol.create(const s:string);
      begin;
        inherited createname(s);
        bind:=AB_EXTERNAL;
        typ:=AT_NONE;
        symidx:=-1;
        size:=0;
        offset:=0;
        objsection:=nil;
      end;


    function TObjSymbol.address:aint;
      begin
        if assigned(objsection) then
          result:=offset+objsection.mempos
        else
          result:=0;
      end;


    procedure TObjSymbol.SetAddress(apass:byte;aobjsec:TObjSection;abind:TAsmsymbind;atyp:Tasmsymtype);
      begin
        if not(abind in [AB_GLOBAL,AB_LOCAL,AB_COMMON]) then
          internalerror(200603016);
        if not assigned(aobjsec) then
          internalerror(200603017);
        if (bind=AB_EXTERNAL) then
          begin
            bind:=abind;
            typ:=atyp;
          end
        else
          begin
            if pass=apass then
              Message1(asmw_e_duplicate_label,name);
          end;
        pass:=apass;
        { Code can never grow after a pass }
        if assigned(objsection) and
           (aobjsec.size>offset) then
          internalerror(200603014);
        objsection:=aobjsec;
        offset:=aobjsec.size;
      end;

{****************************************************************************
                              TObjRelocation
****************************************************************************}

    constructor TObjRelocation.CreateSymbol(ADataOffset:aint;s:TObjSymbol;Atyp:TObjRelocationType);
      begin
        DataOffset:=ADataOffset;
        Symbol:=s;
        OrgSize:=0;
        ObjSection:=nil;
        Typ:=Atyp;
      end;


    constructor TObjRelocation.CreateSymbolSize(ADataOffset:aint;s:TObjSymbol;Aorgsize:aint;Atyp:TObjRelocationType);
      begin
        DataOffset:=ADataOffset;
        Symbol:=s;
        OrgSize:=Aorgsize;
        ObjSection:=nil;
        Typ:=Atyp;
      end;


    constructor TObjRelocation.CreateSection(ADataOffset:aint;aobjsec:TObjSection;Atyp:TObjRelocationType);
      begin
        DataOffset:=ADataOffset;
        Symbol:=nil;
        OrgSize:=0;
        ObjSection:=aobjsec;
        Typ:=Atyp;
      end;


{****************************************************************************
                              TObjSection
****************************************************************************}

    constructor TObjSection.create(const Aname:string;Aalign:shortint;Aoptions:TObjSectionOptions);
      begin
        inherited createname(Aname);
        name:=Aname;
        secoptions:=Aoptions;
        secsymidx:=0;
        secalign:=Aalign;
        { data }
        Size:=0;
        datapos:=0;
        mempos:=0;
        if (oso_data in aoptions) then
          Data:=TDynamicArray.Create(8192)
        else
          data:=nil;
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
        result:=size;
        if assigned(Data) then
          begin
            if Size<>data.size then
              internalerror(200602281);
            Data.write(d,l);
            inc(Size,l);
          end
        else
          internalerror(200602289);
      end;


    function TObjSection.writestr(const s:string):aint;
      begin
        result:=Write(s[1],length(s));
      end;


    function TObjSection.WriteZeros(l:longint):aint;
      var
        empty : array[0..1023] of byte;
      begin
        if l>sizeof(empty) then
          internalerror(200404082);
        if l>0 then
          begin
            fillchar(empty,l,0);
            result:=Write(empty,l);
          end
        else
          result:=Size;
      end;


    procedure TObjSection.setdatapos(var dpos:aint);
      begin
        if oso_data in secoptions then
          begin
            { get aligned datapos }
            datapos:=align(dpos,secalign);
            dataalignbytes:=datapos-dpos;
            { return updated datapos }
            dpos:=datapos+size;
          end
        else
          datapos:=dpos;
      end;


    procedure TObjSection.setmempos(var mpos:aint);
      begin
        mempos:=align(mpos,secalign);
        { return updated mempos }
        mpos:=mempos+size;
      end;


    procedure TObjSection.alloc(l:aint);
      begin
        inc(size,l);
      end;


    procedure TObjSection.addsymreloc(ofs:aint;p:TObjSymbol;relative:TObjRelocationType);
      var
        r : TObjRelocation;
      begin
        r:=TObjRelocation.Create;
        r.DataOffset:=ofs;
        r.orgsize:=0;
        r.symbol:=p;
        r.objsection:=nil;
        r.typ:=relative;
        relocations.concat(r);
      end;


    procedure TObjSection.addsectionreloc(ofs:aint;aobjsec:TObjSection;relative:TObjRelocationType);
      var
        r : TObjRelocation;
      begin
        r:=TObjRelocation.Create;
        r.DataOffset:=ofs;
        r.symbol:=nil;
        r.orgsize:=0;
        r.objsection:=aobjsec;
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
        { sections, the SectsIndex owns the items, the FObjSectionsDict
          is only used for lookups }
        FObjSectionsDict:=tdictionary.create;
        FObjSectionsDict.noclear:=true;
        FObjSectionsIndex:=tindexarray.create(sectsgrow);
        FStabsObjSec:=nil;
        FStabStrObjSec:=nil;
        { symbols }
        FObjSymbolsDict:=tdictionary.create;
        FObjSymbolsDict.noclear:=true;
        FObjSymbolsIndex:=TList.create;
        FCachedAsmSymbolList:=TList.create;
        { section class type for creating of new sections }
        FCObjSection:=TObjSection;
      end;


    destructor TObjData.destroy;
{$ifdef MEMDEBUG}
       var
         d : tmemdebug;
{$endif}
      begin
{$ifdef MEMDEBUG}
        d:=tmemdebug.create(name+' - objdata symbols');
{$endif}
        ResetCachedAsmSymbols;
        FCachedAsmSymbolList.free;
        FObjSymbolsDict.free;
        FObjSymbolsIndex.free;
{$ifdef MEMDEBUG}
        d.free;
{$endif}
{$ifdef MEMDEBUG}
        d:=tmemdebug.create(name+' - objdata sections');
{$endif}
        FObjSectionsDict.free;
        FObjSectionsIndex.free;
{$ifdef MEMDEBUG}
        d.free;
{$endif}
      end;


    function TObjData.sectionname(atype:TAsmSectiontype;const aname:string):string;
      const
        secnames : array[TAsmSectiontype] of string[13] = ('',
          'code',
          'data',
          'rodata',
          'bss',
          'threadvar',
          'stub',
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


    function TObjData.sectiontype2options(atype:TAsmSectiontype):TObjSectionOptions;
      const
        secoptions : array[TAsmSectiontype] of TObjSectionOptions = ([],
          {code} [oso_data,oso_load,oso_readonly,oso_executable,oso_keep],
          {data} [oso_data,oso_load,oso_write,oso_keep],
{$warning TODO Fix rodata be really read-only}
          {rodata} [oso_data,oso_load,oso_write,oso_keep],
          {bss} [oso_load,oso_write,oso_keep],
          {threadvar} [oso_load,oso_write],
          {stub} [oso_data,oso_load,oso_readonly,oso_executable],
          {stab} [oso_data,oso_noload,oso_debug],
          {stabstr} [oso_data,oso_noload,oso_strings,oso_debug],
          {idata2} [oso_data,oso_load,oso_write],
          {idata4} [oso_data,oso_load,oso_write],
          {idata5} [oso_data,oso_load,oso_write],
          {idata6} [oso_data,oso_load,oso_write],
          {idata7} [oso_data,oso_load,oso_write],
          {edata} [oso_data,oso_load,oso_readonly],
          {eh_frame} [oso_data,oso_load,oso_readonly],
          {debug_frame} [oso_data,oso_noload,oso_debug],
          {debug_info} [oso_data,oso_noload,oso_debug],
          {debug_line} [oso_data,oso_noload,oso_debug],
          {debug_abbrev} [oso_data,oso_noload,oso_debug],
          {fpc} [oso_data,oso_load,oso_write,oso_keep],
          {toc} [oso_data,oso_load,oso_readonly]
        );
      begin
        result:=secoptions[atype];
      end;


    function TObjData.sectiontype2align(atype:TAsmSectiontype):shortint;
      begin
        result:=sizeof(aint);
      end;


    function TObjData.createsection(atype:TAsmSectionType;const aname:string):TObjSection;
      begin
        result:=createsection(sectionname(atype,aname),sectiontype2align(atype),sectiontype2options(atype));
      end;


    function TObjData.createsection(const aname:string;aalign:shortint;aoptions:TObjSectionOptions):TObjSection;
      begin
        result:=TObjSection(FObjSectionsDict.search(aname));
        if not assigned(result) then
          begin
            result:=CObjSection.create(aname,aalign,aoptions);
            FObjSectionsDict.Insert(result);
            FObjSectionsIndex.Insert(result);
            result.ObjData:=self;
          end;
        FCurrObjSec:=result;
      end;


    procedure TObjData.CreateDebugSections;
      begin
      end;


    function TObjData.FindSection(const aname:string):TObjSection;
      begin
        result:=TObjSection(FObjSectionsDict.Search(aname));
      end;


    procedure TObjData.removesection(asec:TObjSection);
      begin
        FObjSectionsDict.Delete(asec.name);
        FObjSectionsIndex.DeleteIndex(asec);
        asec.free;
      end;


    procedure TObjData.setsection(asec:TObjSection);
      begin
        if asec.ObjData<>self then
          internalerror(200403041);
        FCurrObjSec:=asec;
      end;


    function TObjData.symboldefine(asmsym:TAsmSymbol):TObjSymbol;
      begin
        if assigned(asmsym) then
          begin
            if not assigned(asmsym.cachedobjsymbol) then
              begin
                asmsym.cachedobjsymbol:=symboldefine(asmsym.name,asmsym.bind,asmsym.typ);
                FCachedAsmSymbolList.add(asmsym);
              end
            else
              begin
                result:=TObjSymbol(asmsym.cachedobjsymbol);
                result.SetAddress(CurrPass,CurrObjSec,asmsym.bind,asmsym.typ);
              end;
          end
        else
          result:=nil;
      end;


    function TObjData.symboldefine(const aname:string;abind:TAsmsymbind;atyp:Tasmsymtype):TObjSymbol;
      begin
        result:=TObjSymbol(FObjSymbolsDict.search(aname));
        if not assigned(result) then
          begin
            result:=TObjSymbol.Create(aname);
            FObjSymbolsDict.Insert(result);
            FObjSymbolsIndex.Add(result);
          end;
        result.SetAddress(CurrPass,CurrObjSec,abind,atyp);
      end;


    function TObjData.symbolref(asmsym:TAsmSymbol):TObjSymbol;
      begin
        if assigned(asmsym) then
          begin
            if not assigned(asmsym.cachedobjsymbol) then
              begin
                asmsym.cachedobjsymbol:=symbolref(asmsym.name);
                FCachedAsmSymbolList.add(asmsym);
              end;
            result:=TObjSymbol(asmsym.cachedobjsymbol);
          end
        else
          result:=nil;
      end;


    function TObjData.symbolref(const aname:string):TObjSymbol;
      begin
        result:=TObjSymbol(FObjSymbolsDict.search(aname));
        if not assigned(result) then
          begin
            result:=TObjSymbol.Create(aname);
            FObjSymbolsDict.Insert(result);
            FObjSymbolsIndex.Add(result);
          end;
      end;


    procedure TObjData.ResetCachedAsmSymbols;
      var
        i  : longint;
      begin
        for i:=0 to FCachedAsmSymbolList.Count-1 do
          tasmsymbol(FCachedAsmSymbolList[i]).cachedobjsymbol:=nil;
        FCachedAsmSymbolList.Clear;
      end;


    procedure TObjData.writebytes(var data;len:aint);
      begin
        if not assigned(CurrObjSec) then
          internalerror(200402251);
        CurrObjSec.write(data,len);
      end;


    procedure TObjData.alloc(len:aint);
      begin
        if not assigned(CurrObjSec) then
          internalerror(200402252);
        CurrObjSec.alloc(len);
      end;


    procedure TObjData.allocalign(len:shortint);
      begin
        if not assigned(CurrObjSec) then
          internalerror(200402253);
        CurrObjSec.alloc(align(CurrObjSec.size,len)-CurrObjSec.size);
      end;


    procedure TObjData.allocstab(p:pchar);
      begin
        if not(assigned(FStabsObjSec) and assigned(FStabStrObjSec)) then
          internalerror(200402254);
        FStabsObjSec.alloc(sizeof(TObjStabEntry));
        if assigned(p) and (p[0]<>#0) then
          FStabStrObjSec.alloc(strlen(p)+1);
      end;


    procedure TObjData.section_afteralloc(p:tnamedindexitem;arg:pointer);
      begin
        with TObjSection(p) do
          alloc(align(size,secalign)-size);
      end;


    procedure TObjData.section_afterwrite(p:tnamedindexitem;arg:pointer);
      begin
        with TObjSection(p) do
          begin
            if assigned(data) then
              writezeros(align(size,secalign)-size);
          end;
      end;


    procedure TObjData.section_reset(p:tnamedindexitem;arg:pointer);
      begin
        with TObjSection(p) do
          begin
            Size:=0;
            datapos:=0;
            mempos:=0;
          end;
      end;


    procedure TObjData.section_fixuprelocs(p:tnamedindexitem;arg:pointer);
      begin
        TObjSection(p).fixuprelocs;
      end;


    procedure TObjData.beforealloc;
      begin
        { create stabs sections if debugging }
        if assigned(StabsSec) then
          begin
            StabsSec.Alloc(sizeof(TObjStabEntry));
            StabStrSec.Alloc(1);
          end;
      end;


    procedure TObjData.beforewrite;
      var
        s : string[1];
      begin
        { create stabs sections if debugging }
        if assigned(StabsSec) then
         begin
           writestab(0,nil,0,0,0,nil);
           s:=#0;
           stabstrsec.write(s[1],length(s));
         end;
      end;


    procedure TObjData.afteralloc;
      begin
        FObjSectionsDict.foreach(@section_afteralloc,nil);
      end;


    procedure TObjData.afterwrite;
      var
        s : string[1];
        hstab : TObjStabEntry;
      begin
        FObjSectionsDict.foreach(@section_afterwrite,nil);
        { For the stab section we need an HdrSym which can now be
          calculated more easily }
        if assigned(StabsSec) then
          begin
            { header stab }
            s:=#0;
            stabstrsec.write(s[1],length(s));
            hstab.strpos:=1;
            hstab.ntype:=0;
            hstab.nother:=0;
            hstab.ndesc:=(StabsSec.Size div sizeof(TObjStabEntry))-1;
            hstab.nvalue:=StabStrSec.Size;
            StabsSec.data.seek(0);
            StabsSec.data.write(hstab,sizeof(hstab));
          end;
      end;


    procedure TObjData.resetsections;
      begin
        FObjSectionsDict.foreach(@section_reset,nil);
      end;


    procedure TObjData.fixuprelocs;
      begin
        FObjSectionsDict.foreach(@section_fixuprelocs,nil);
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
        AltSymbollist:=TList.Create;
        { labels }
        nextaltnr:=1;
        for alt:=low(TAsmLabelType) to high(TAsmLabelType) do
          nextlabelnr[alt]:=1;
      end;


    destructor TObjLibraryData.destroy;
      begin
        AltSymbollist.free;
        symbolsearch.free;
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
             hp.bind:=_bind
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


    procedure TObjLibraryData.GenerateAltSymbol(p:tasmsymbol);
      begin
        if not assigned(p.altsymbol) then
         begin
           p.altsymbol:=tasmsymbol.create(p.name+'_'+tostr(nextaltnr),p.bind,p.typ);
           symbolsearch.insert(p.altsymbol);
           AltSymbollist.Add(p);
         end;
      end;


    procedure TObjLibraryData.ResetAltSymbols;
      var
        i  : longint;
      begin
        for i:=0 to AltSymbollist.Count-1 do
          tasmsymbol(AltSymbollist[i]).altsymbol:=nil;
        AltSymbollist.Clear;
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
