{
    Copyright (c) 1998-2006 by Peter Vreman

    Contains the base stuff for binary object file writers

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
unit ogbase;

{$i fpcdefs.inc}

interface

    uses
      { common }
      cclasses,
      { targets }
      systems,globtype,
      { outputwriters }
      owbase,owar,
      { assembler }
      aasmbase,aasmtai;

    type
      TObjOutput = class
      private
        FCObjData : TObjDataClass;
      protected
        { writer }
        FWriter    : TObjectwriter;
        function  writedata(data:TObjData):boolean;virtual;abstract;
        property CObjData : TObjDataClass read FCObjData write FCObjData;
      public
        constructor create(smart:boolean);virtual;
        destructor  destroy;override;
        function  newObjData(const n:string):TObjData;
        function  startObjectfile(const fn:string):boolean;
        function  writeobjectfile(data:TObjData):boolean;
        procedure exportsymbol(p:tasmsymbol);
        property Writer:TObjectWriter read FWriter;
      end;
      TObjOutputClass=class of TObjOutput;

      TObjInput = class
      private
        FCObjData : TObjDataClass;
      protected
        { reader }
        FReader    : TObjectreader;
        function  readObjData(data:TObjData):boolean;virtual;abstract;
        property CObjData : TObjDataClass read FCObjData write FCObjData;
      public
        constructor create;virtual;
        destructor  destroy;override;
        function  newObjData(const n:string):TObjData;
        function  readobjectfile(const fn:string;data:TObjData):boolean;virtual;
        property Reader:TObjectReader read FReader;
      end;
      TObjInputClass=class of TObjInput;

      TExeSection = class;

      TExeSymbol = class(TNamedIndexItem)
        objsymbol  : TAsmSymbol;
        exesection : TExeSection;
        constructor create(sym:TAsmSymbol);
      end;

      TExeSection = class(tnamedindexitem)
      private
        FSecSymIdx : longint;
        FObjSectionList : TList;
        FObjSymbolList  : Tlist;
        procedure SetSecSymIdx(idx:longint);
      public
        DataSize,
        DataPos,
        MemSize,
        MemPos     : aint;
        SecAlign   : shortint;
        secoptions : TObjSectionOptions;
        constructor create(const n:string);virtual;
        destructor  destroy;override;
        procedure AddObjSection(objsec:TObjSection);
        property ObjSectionList:TList read FObjSectionList;
        property ObjSymbolList:TList read FObjSymbolList;
        property SecSymIdx:longint read FSecSymIdx write SetSecSymIdx;
      end;
      TExeSectionClass=class of TExeSection;

      TExeOutput = class
      private
        { ExeSections }
        FCObjData         : TObjDataClass;
        FCExeSection      : TExeSectionClass;
        FCurrExeSec       : TExeSection;
        FExeSectionsIndex : TIndexArray;
        FExeSectionsDict  : TDictionary;
        { Symbols }
        FExternalExeSymbols : TList;
        FCommonExeSymbols   : TList;
        FGlobalExeSymbols   : TDictionary;
        FEntryName          : string;
        { Objects }
        FObjDataList  : TList;
        { Position calculation }
        FImageBase    : aint;
        FCurrDataPos,
        FCurrMemPos   : aint;
        procedure ExeSections_FixUpSymbol(s:tnamedindexitem;arg:pointer);
      protected
        { writer }
        FWriter : TObjectwriter;
        commonobjsection : TObjSection;
        commonobjdata,
        globalsobjdata : TObjData;
        EntrySym  : TAsmSymbol;
        SectionDataAlign,
        SectionMemAlign : aint;
        function  writedata:boolean;virtual;abstract;
        property CExeSection:TExeSectionClass read FCExeSection write FCExeSection;
        property CObjData:TObjDataClass read FCObjData write FCObjData;
      public
        constructor create;virtual;
        destructor  destroy;override;
        procedure AddObjData(objdata:TObjData);
        function  FindExeSection(const aname:string):TExeSection;
        procedure Pass1_Start;virtual;
        procedure Pass1_EntryName(const aname:string);virtual;
        procedure Pass1_ExeSection(const aname:string);virtual;
        procedure Pass1_EndExeSection;virtual;
        procedure Pass1_ObjSection(const aname:string);virtual;
        procedure Pass1_Symbol(const aname:string);virtual;
        procedure Pass1_Zeros(const aname:string);virtual;
        procedure Pass2_ExeSection(const aname:string);virtual;
        procedure Pass2_EndExeSection;virtual;
        procedure Pass2_Header;virtual;
        procedure Pass2_Start;virtual;
        procedure Pass2_Symbols;virtual;
        function  CalculateSymbols:boolean;
        procedure FixUpSymbols;
        procedure FixUpRelocations;
        procedure RemoveEmptySections;
        function  writeexefile(const fn:string):boolean;
        property Writer:TObjectWriter read FWriter;
        property ExeSections:TIndexArray read FExeSectionsIndex;
        property ObjDataList:TList read FObjDataList;
        property ExternalExeSymbols:TList read FExternalExeSymbols;
        property CommonExeSymbols:TList read FCommonExeSymbols;
        property GlobalExeSymbols:TDictionary read FGlobalExeSymbols;
        property EntryName:string read FEntryName write FEntryName;
        property ImageBase:aint read FImageBase write FImageBase;
        property CurrExeSec:TExeSection read FCurrExeSec;
        property CurrDataPos:aint read FCurrDataPos write FCurrDataPos;
        property CurrMemPos:aint read FCurrMemPos write FCurrMemPos;
      end;
      TExeOutputClass=class of TExeOutput;

    var
      exeoutput : texeoutput;


implementation

    uses
      cutils,globals,verbose,fmodule,ogmap;



{****************************************************************************
                                TObjOutput
****************************************************************************}

    constructor TObjOutput.create(smart:boolean);
      begin
      { init writer }
        if smart and
           not(cs_asm_leave in aktglobalswitches) then
          FWriter:=tarobjectwriter.create(current_module.staticlibfilename^)
        else
          FWriter:=TObjectwriter.create;
        CObjData:=TObjData;
      end;


    destructor TObjOutput.destroy;
      begin
        FWriter.free;
      end;


    function TObjOutput.newObjData(const n:string):TObjData;
      begin
        result:=CObjData.create(n);
        if (cs_use_lineinfo in aktglobalswitches) or
           (cs_debuginfo in aktmoduleswitches) then
          result.CreateDebugSections;
      end;


    function TObjOutput.startObjectfile(const fn:string):boolean;
      begin
        result:=false;
        { start the writer already, so the .a generation can initialize
          the position of the current objectfile }
        if not FWriter.createfile(fn) then
         Comment(V_Fatal,'Can''t create object '+fn);
        result:=true;
      end;


    function TObjOutput.writeobjectfile(data:TObjData):boolean;
      begin
        if errorcount=0 then
         result:=writedata(data)
        else
         result:=true;
        { close the writer }
        FWriter.closefile;
      end;


    procedure TObjOutput.exportsymbol(p:tasmsymbol);
      begin
        { export globals and common symbols, this is needed
          for .a files }
        if p.currbind in [AB_GLOBAL,AB_COMMON] then
         FWriter.writesym(p.name);
      end;


{****************************************************************************
                                 TExeSymbol
****************************************************************************}

    constructor TExeSymbol.create(sym:TAsmSymbol);
      begin
        inherited createname(sym.name);
        objsymbol:=sym;
      end;


{****************************************************************************
                                texesection
****************************************************************************}

    constructor texesection.create(const n:string);
      begin
        inherited createname(n);
        MemPos:=0;
        MemSize:=0;
        DataPos:=0;
        DataSize:=0;
        FSecSymIdx:=0;
        FObjSectionList:=TList.Create;
        FObjSymbolList:=TList.Create;
      end;


    destructor texesection.destroy;
      begin
        ObjSectionList.Free;
        ObjSymbolList.Free;
      end;


    procedure texesection.AddObjSection(objsec:TObjSection);
      begin
        ObjSectionList.Add(objsec);
        if (secoptions<>[]) then
          begin
            if (oso_data in secoptions)<>(oso_data in objsec.secoptions) then
              Comment(V_Error,'Incompatible section options');
          end;
        { relate objsection to exesection }
        objsec.exesection:=self;
      end;


    procedure texesection.SetSecSymIdx(idx:longint);
      var
        i : longint;
      begin
        FSecSymIdx:=idx;
//        for i:=0 to ObjSectionList.count-1 do
//          TObjSection(ObjSectionList[i]).SecSymIdx:=idx;
      end;


{****************************************************************************
                                texeoutput
****************************************************************************}

    constructor texeoutput.create;
      begin
        { init writer }
        FWriter:=TObjectwriter.create;
        { object files }
        FObjDataList:=tlist.create;
        { symbols }
        FGlobalExeSymbols:=tdictionary.create;
        FGlobalExeSymbols.usehash;
        FExternalExeSymbols:=TList.create;
        FCommonExeSymbols:=TList.create;
        FExeSectionsDict:=TDictionary.create;
        FExeSectionsIndex:=TIndexArray.create(10);
        FEntryName:='start';
        FImageBase:=0;
        SectionMemAlign:=$1000;
        SectionDataAlign:=$200;
        FCExeSection:=TExeSection;
        FCObjData:=TObjData;
      end;


    destructor texeoutput.destroy;
      begin
        ExeSections.free;
        globalExeSymbols.free;
        externalExeSymbols.free;
        commonExeSymbols.free;
        objdatalist.free;
        globalsobjdata.free;
        commonobjdata.free;
        FWriter.free;
      end;


    function texeoutput.writeexefile(const fn:string):boolean;
      begin
        result:=false;
        if FWriter.createfile(fn) then
         begin
           { Only write the .o if there are no errors }
           if errorcount=0 then
             result:=writedata
           else
             result:=true;
           { close the writer }
           FWriter.closefile;
         end
        else
         Comment(V_Fatal,'Can''t create executable '+fn);
      end;


    procedure texeoutput.AddObjData(objdata:TObjData);
      begin
        if objdata.classtype<>FCObjData then
          Comment(V_Error,'Invalid input object format for '+objdata.name+' got '+objdata.classname+' expected '+FCObjData.classname);
        ObjDataList.Add(objdata);
      end;


    function  texeoutput.FindExeSection(const aname:string):TExeSection;
      begin
        result:=TExeSection(FExeSectionsDict.Search(aname));
      end;


    procedure texeoutput.Pass1_Start;
      begin
        { Globals defined in the linker script }
        globalsobjdata:=CObjData.create('*GLOBALS*');
        AddObjData(globalsobjdata);
        { Common data }
        commonobjdata:=CObjData.create('*COMMON*');
        commonobjsection:=commonobjdata.createsection(sec_bss,'');
        AddObjData(commonobjdata);
      end;


    procedure texeoutput.Pass1_EntryName(const aname:string);
      begin
        EntryName:=aname;
      end;


    procedure texeoutput.Pass1_ExeSection(const aname:string);
      var
        sec : TExeSection;
      begin
        sec:=FindExeSection(aname);
        if not assigned(sec) then
          begin
            sec:=CExeSection.create(aname);
            FExeSectionsDict.Insert(sec);
            FExeSectionsIndex.Insert(sec);
          end;
        FCurrExeSec:=sec;
      end;


    procedure texeoutput.Pass1_EndExeSection;
      begin
        if not assigned(CurrExeSec) then
          internalerror(200602184);
        FCurrExeSec:=nil;
      end;


    procedure texeoutput.Pass1_ObjSection(const aname:string);
      var
        i       : longint;
        objdata : TObjData;
        objsec  : TObjSection;
      begin
        if not assigned(CurrExeSec) then
          internalerror(200602181);
{$warning TODO Add wildcard support like *(.text*)}
        for i:=0 to ObjDataList.Count-1 do
          begin
            objdata:=TObjData(ObjDataList[i]);
            objsec:=objdata.findsection(aname);
            if assigned(objsec) then
              begin
                CurrExeSec.AddObjSection(objsec);
                { inherit section options }
                if CurrExeSec.secoptions=[] then
                  begin
                    CurrExeSec.SecAlign:=CurrExeSec.secalign;
                    CurrExeSec.secoptions:=CurrExeSec.secoptions+objsec.secoptions;
                  end;
              end;
          end;
      end;


    procedure texeoutput.Pass1_Symbol(const aname:string);
      var
        sym : tasmsymbol;
      begin
(*
        sym:=tasmsymbol.create(aname,AB_GLOBAL,AT_FUNCTION);
        { Create a dummy section }
        sym.objsection:=globalsobjdata.createsection('*'+sym.name,0,[]);
        globalsobjdata.ObjSymbols.insert(sym);
        CurrExeSec.AddObjSection(sym.objsection);
*)
      end;


    procedure texeoutput.Pass1_Zeros(const aname:string);
      var
        zeros : array[0..1023] of byte;
        code  : integer;
        len   : longint;
        objsec : TObjSection;
      begin
        val(aname,len,code);
        if len<=0 then
          exit;
        if len>sizeof(zeros) then
          internalerror(200602254);
        fillchar(zeros,len,0);
        objsec:=globalsobjdata.createsection('*zeros',0,CurrExeSec.secoptions);
        globalsobjdata.writebytes(zeros,len);
        globalsobjdata.afteralloc;
        CurrExeSec.AddObjSection(objsec);
      end;


    procedure texeoutput.Pass2_ExeSection(const aname:string);
      type
       coffstab=packed record
         strpos  : longint;
         ntype   : byte;
         nother  : byte;
         ndesc   : word;
         nvalue  : longint;
       end;
      var
        hstab  : coffstab;
        stabcnt,
        i,j    : longint;
        stabsec,
        objsec : TObjSection;
        alignedpos : aint;
      begin
        { Section can be removed }
        FCurrExeSec:=FindExeSection(aname);
        if not assigned(CurrExeSec) then
          exit;
        { Alignment of exesection }
        if (oso_load in currexesec.secoptions) then
          begin
            CurrMemPos:=align(CurrMemPos,SectionMemAlign);
            CurrExeSec.MemPos:=CurrMemPos;
          end;
        if (oso_data in currexesec.secoptions) then
          begin
            CurrDataPos:=align(CurrDataPos,SectionDataAlign);
            CurrExeSec.DataPos:=CurrDataPos;
          end;

        { For the stab section we need an HdrSym }
{$warning TODO Remove Stabs hack}
        if aname='.stab' then
          begin
            inc(CurrDataPos,sizeof(coffstab));
          end;


        { set position of object ObjSections }
        for i:=0 to CurrExeSec.ObjSectionList.Count-1 do
          begin
            objsec:=TObjSection(CurrExeSec.ObjSectionList[i]);
            { Position in memory }
            if (oso_load in currexesec.secoptions) then
              begin
                CurrMemPos:=align(CurrMemPos,objsec.secalign);
                objsec.MemPos:=CurrMemPos;
                inc(CurrMemPos,objsec.alignedmemsize);
              end;
            { Position in File }
            if (oso_data in objsec.secoptions) then
              begin
                alignedpos:=align(CurrDataPos,objsec.secalign);
                objsec.dataalignbytes:=alignedpos-CurrDataPos;
                CurrDataPos:=alignedpos;
                objsec.DataPos:=CurrDataPos;
                inc(CurrDataPos,objsec.aligneddatasize);
              end;

            { Update references to stabstr }
    {$warning TODO Remove Stabs hack}
            if objsec.name='.stabstr' then
              begin
                stabsec:=objsec.objdata.findsection('.stab');
                stabcnt:=stabsec.data.size div sizeof(coffstab);
                for j:=0 to stabcnt-1 do
                  begin
                    stabsec.data.seek(j*sizeof(coffstab));
                    stabsec.data.read(hstab,sizeof(coffstab));
                    if hstab.strpos<>0 then
                      begin
                        inc(hstab.strpos,objsec.datapos-CurrExeSec.DataPos);
                        stabsec.data.seek(j*sizeof(coffstab));
                        stabsec.data.write(hstab,sizeof(coffstab));
                      end;
                  end;
              end;

          end;
      end;


    procedure texeoutput.Pass2_EndExeSection;
      begin
        if not assigned(CurrExeSec) then
          exit;
        { calculate size of the section }
        CurrExeSec.memsize:=CurrMemPos-CurrExeSec.MemPos;
        if (oso_data in CurrExeSec.secoptions) then
          CurrExeSec.datasize:=CurrDataPos-CurrExeSec.DataPos;
        { Reset current section }
        FCurrExeSec:=nil;
      end;


    procedure texeoutput.Pass2_Start;
      begin
        CurrMemPos:=0;
        CurrDataPos:=0;
      end;


    procedure texeoutput.Pass2_Header;
      begin
      end;


    procedure texeoutput.Pass2_Symbols;
      begin
      end;


    procedure texeoutput.ExeSections_FixUpSymbol(s:tnamedindexitem;arg:pointer);
      var
        objsec : TObjSection;
        hsym    : TAsmSymbol;
        i       : longint;
      begin
        with texesection(s) do
          begin
            if assigned(exemap) then
              exemap.AddMemoryMapExeSection(TExeSection(s));
            for i:=0 to ObjSectionList.count-1 do
              begin
                objsec:=TObjSection(ObjSectionList[i]);
                if assigned(exemap) then
                  exemap.AddMemoryMapObjectSection(objsec);
                hsym:=tasmsymbol(objsec.objdata.objsymbols.first);
                while assigned(hsym) do
                  begin
                    { process only the symbols that are defined in this section
                      and are located in this module }
                    if (hsym.objsection=objsec) and
                       (hsym.currbind in [AB_GLOBAL,AB_LOCAL]) then
                      begin
                        if assigned(exemap) then
                          exemap.AddMemoryMapSymbol(hsym);
                      end;
                    hsym:=tasmsymbol(hsym.indexnext);
                  end;
              end;
          end;
      end;


    procedure texeoutput.FixUpSymbols;
      var
        i   : longint;
        sym : tasmsymbol;
        objdata : TObjData;
      begin
        { Update ImageBase to ObjData so it can access from ObjSymbols }
        for i:=0 to ObjDataList.Count-1 do
          begin
            objdata:=TObjData(ObjDataList[i]);
            objdata.imagebase:=imagebase;
          end;

        {
          Fixing up symbols is done in the following steps:
           1. Update addresses
           2. Update common references
           3. Update external references
        }
        { Step 1, Update addresses }
        if assigned(exemap) then
          exemap.AddMemoryMapHeader(ImageBase);
        ExeSections.foreach(@ExeSections_FixUpSymbol,nil);
        { Step 2, Update commons }
        for i:=0 to commonExeSymbols.count-1 do
          begin
            sym:=tasmsymbol(commonExeSymbols[i]);
            if sym.currbind=AB_COMMON then
              begin
                { update this symbol }
                sym.currbind:=sym.altsymbol.currbind;
                sym.memoffset:=sym.altsymbol.memoffset;
                sym.size:=sym.altsymbol.size;
                sym.typ:=sym.altsymbol.typ;
                sym.objsection:=sym.altsymbol.objsection;
              end;
          end;
        { Step 3, Update externals }
        for i:=0 to externalExeSymbols.count-1 do
          begin
            sym:=tasmsymbol(externalExeSymbols[i]);
            if sym.currbind=AB_EXTERNAL then
              begin
                { update this symbol }
                sym.currbind:=sym.altsymbol.currbind;
                sym.memoffset:=sym.altsymbol.memoffset;
                sym.size:=sym.altsymbol.size;
                sym.typ:=sym.altsymbol.typ;
                sym.objsection:=sym.altsymbol.objsection;
              end;
          end;
      end;


    procedure texeoutput.RemoveEmptySections;
      var
        i      : longint;
        exesec : TExeSection;
      begin
        for i:=1 to FExeSectionsIndex.Count do
          begin
            exesec:=TExeSection(FExeSectionsIndex.Search(i));
            if not(oso_keep in exesec.secoptions) and
               (exesec.objsectionlist.count=0) then
              begin
                FExeSectionsIndex.DeleteIndex(exesec);
                FExeSectionsDict.Delete(exesec.name);
              end;
          end;
      end;


    procedure texeoutput.FixUpRelocations;
      var
        i       : longint;
        objdata : TObjData;
      begin
        for i:=0 to ObjDataList.Count-1 do
          begin
            objdata:=TObjData(ObjDataList[i]);
            objdata.fixuprelocs;
          end;
      end;


    function TExeOutput.CalculateSymbols:boolean;
      var
        objdata   : TObjData;
        exesym    : TExeSymbol;
        sym,
        commonsym : tasmsymbol;
        firstcommon : boolean;
        i         : longint;
      begin
        result:=true;

        {
          The symbol calculation is done in 3 steps:
           1. register globals
              register externals
              register commons
           2. try to find commons, if not found then
              add to the globals (so externals can be resolved)
           3. try to find externals
        }

        { Step 1, Register symbols }
        for i:=0 to ObjDataList.Count-1 do
          begin
            objdata:=TObjData(ObjDataList[i]);
            sym:=tasmsymbol(objdata.objsymbols.first);
            while assigned(sym) do
              begin
                if not assigned(sym.objsection) then
                  internalerror(200206302);
                case sym.currbind of
                  AB_GLOBAL :
                    begin
                      exesym:=texesymbol(globalExeSymbols.search(sym.name));
                      if not assigned(exesym) then
                        begin
                          globalExeSymbols.insert(texesymbol.create(sym));
                          TExeSection(sym.objsection.exesection).objsymbollist.add(sym);
                        end
                      else
                        begin
                          Comment(V_Error,'Multiple defined symbol '+sym.name);
                          result:=false;
                        end;
                    end;
                  AB_EXTERNAL :
                    externalExeSymbols.add(sym);
                  AB_COMMON :
                    commonExeSymbols.add(sym);
                end;
                sym:=tasmsymbol(sym.indexnext);
              end;
          end;

        { Step 2, Match common symbols or add to the globals }
        firstcommon:=true;
        for i:=0 to commonExeSymbols.count-1 do
          begin
            sym:=tasmsymbol(commonExeSymbols[i]);
            if sym.currbind=AB_COMMON then
              begin
                exesym:=texesymbol(globalExeSymbols.search(sym.name));
                if assigned(exesym) then
                  begin
                    if exesym.objsymbol.size<>sym.size then
                     internalerror(200206301);
                  end
                else
                  begin
                    { allocate new symbol in .bss and store it in the
                      *COMMON* module }
                    if firstcommon then
                      begin
                        if assigned(exemap) then
                          exemap.AddCommonSymbolsHeader;
                        firstcommon:=false;
                      end;
                    commonsym:=TAsmSymbol.Create(sym.name,AB_GLOBAL,AT_FUNCTION);
                    commonobjdata.setsection(commonobjsection);
                    commonobjdata.allocsymbol(2,commonsym,sym.size);
                    commonobjdata.alloc(sym.size);
                    commonobjdata.writesymbol(commonsym);
                    if assigned(exemap) then
                      exemap.AddCommonSymbol(commonsym);
                    { make this symbol available as a global }
                    globalExeSymbols.insert(texesymbol.create(commonsym));
                    TExeSection(commonsym.objsection.exesection).objsymbollist.add(commonsym);
                  end;
                sym.altsymbol:=commonsym;
              end;
          end;
        if not firstcommon then
          commonobjdata.afteralloc;

        { Step 3 }
        for i:=0 to externalExeSymbols.count-1 do
          begin
            sym:=tasmsymbol(externalExeSymbols[i]);
            if sym.currbind=AB_EXTERNAL then
              begin
                exesym:=texesymbol(globalExeSymbols.search(sym.name));
                if assigned(exesym) then
                  sym.altsymbol:=exesym.objsymbol
                else
                  begin
                    Comment(V_Error,'Undefined symbol: '+sym.name);
                    result:=false;
                  end;
              end;
          end;

        { Find entry symbol in map }
        exesym:=texesymbol(globalexesymbols.search(EntryName));
        if assigned(exesym) then
          begin
            EntrySym:=exesym.objsymbol;
            if assigned(exemap) then
              begin
                exemap.Add('Entry symbol '+EntryName);
                exemap.Add('');
              end;
          end
        else
          Comment(V_Error,'Entrypoint '+EntryName+' not defined');
      end;


{****************************************************************************
                                TObjInput
****************************************************************************}

    constructor TObjInput.create;
      begin
        { init reader }
        FReader:=TObjectreader.create;
      end;


    destructor TObjInput.destroy;
      begin
        FReader.free;
      end;


    function TObjInput.newObjData(const n:string):TObjData;
      begin
        result:=CObjData.create(n);
      end;


    function TObjInput.readobjectfile(const fn:string;data:TObjData):boolean;
      begin
        result:=false;
        { start the reader }
        if FReader.openfile(fn) then
         begin
           result:=readObjData(data);
           FReader.closefile;
         end;
      end;


end.
