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
        procedure exportsymbol(p:TObjSymbol);
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
        objsymbol  : TObjSymbol;
        exesection : TExeSection;
        constructor create(sym:TObjSymbol);
      end;

      TExeSection = class(tnamedindexitem)
      private
        FSecSymIdx : longint;
        FObjSectionList : TList;
        FObjSymbolList  : Tlist;
      public
        Size,
        DataPos,
        MemPos     : aint;
        SecAlign   : shortint;
        SecOptions : TObjSectionOptions;
        constructor create(const n:string);virtual;
        destructor  destroy;override;
        procedure AddObjSection(objsec:TObjSection);
        property ObjSectionList:TList read FObjSectionList;
        property ObjSymbolList:TList read FObjSymbolList;
        property SecSymIdx:longint read FSecSymIdx write FSecSymIdx;
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
        procedure ExeSections_SymbolMap(s:tnamedindexitem;arg:pointer);
      protected
        { writer }
        FWriter : TObjectwriter;
        commonobjsection : TObjSection;
        commonobjdata,
        internalobjdata : TObjData;
        EntrySym  : TObjSymbol;
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
        procedure CalculateStabs;
        function  CalculateSymbols:boolean;
        procedure PrintMemoryMap;
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


    procedure TObjOutput.exportsymbol(p:TObjSymbol);
      begin
        { export globals and common symbols, this is needed
          for .a files }
        if p.bind in [AB_GLOBAL,AB_COMMON] then
         FWriter.writesym(p.name);
      end;


{****************************************************************************
                                 TExeSymbol
****************************************************************************}

    constructor TExeSymbol.create(sym:TObjSymbol);
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
        Size:=0;
        MemPos:=0;
        DataPos:=0;
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
        internalobjdata.free;
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
        internalobjdata:=CObjData.create('*GLOBALS*');
        AddObjData(internalobjdata);
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
        objsection : TObjSection;
      begin
        { Create a dummy section }
        objsection:=internalobjdata.createsection('*'+aname,0,[]);
        internalobjdata.SymbolDefine(aname,AB_GLOBAL,AT_FUNCTION);
        CurrExeSec.AddObjSection(objsection);
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
        objsec:=internalobjdata.createsection('*zeros',0,CurrExeSec.secoptions);
        internalobjdata.writebytes(zeros,len);
        internalobjdata.afteralloc;
        CurrExeSec.AddObjSection(objsec);
      end;


    procedure texeoutput.CalculateStabs;
      var
        stabexesec,
        stabstrexesec : TExeSection;
        currstabsec,
        currstabstrsec,
        mergedstabsec,
        mergedstabstrsec : TObjSection;
        nextstabreloc,
        currstabreloc : TObjRelocation;
        i,j,
        stabcnt : longint;
        skipstab : boolean;
        hstab   : TObjStabEntry;
        stabrelocofs : longint;
        buf     : array[0..1023] of byte;
        bufend,
        bufsize  : longint;
      begin
        stabexesec:=FindExeSection('.stab');
        stabstrexesec:=FindExeSection('.stabstr');
        if not(assigned(stabexesec) and assigned(stabstrexesec)) then
          exit;
        { Create new stabsection }
        stabrelocofs:=@hstab.nvalue-@hstab;
        mergedstabsec:=internalobjdata.CreateSection(sec_stab,'');
        mergedstabstrsec:=internalobjdata.CreateSection(sec_stabstr,'');

        { write stab for hdrsym }
        fillchar(hstab,sizeof(TObjStabEntry),0);
        mergedstabsec.write(hstab,sizeof(TObjStabEntry));

        { .stabstr starts with a #0 }
        buf[0]:=0;
        mergedstabstrsec.write(buf[0],1);

        { Copy stabs and corresponding relocations }
        for i:=0 to stabexesec.ObjSectionList.Count-1 do
          begin
            currstabsec:=TObjSection(stabexesec.ObjSectionList[i]);
            currstabstrsec:=currstabsec.objdata.findsection('.stabstr');
            if assigned(currstabstrsec) then
              begin
                stabcnt:=currstabsec.data.size div sizeof(TObjStabEntry);
                currstabsec.data.seek(0);
                currstabreloc:=TObjRelocation(currstabsec.relocations.first);
                for j:=0 to stabcnt-1 do
                  begin
                    skipstab:=false;
                    currstabsec.data.read(hstab,sizeof(TObjStabEntry));
                    { Only include first hdrsym stab }
                    if hstab.ntype=0 then
                      skipstab:=true;
                    if not skipstab then
                      begin
                        { Copy string in stabstr }
                        if hstab.strpos<>0 then
                          begin
                            currstabstrsec.data.seek(hstab.strpos);
                            hstab.strpos:=mergedstabstrsec.Size;
                            repeat
                              bufsize:=currstabstrsec.data.read(buf,sizeof(buf));
                              bufend:=indexbyte(buf,bufsize,0);
                              if bufend=-1 then
                                bufend:=bufsize
                              else
                                begin
                                  { include the #0 }
                                  inc(bufend);
                                end;
                              mergedstabstrsec.write(buf,bufend);
                            until (bufend<>-1) or (bufsize<sizeof(buf));
                          end;
                        { Copy relocation }
                        while assigned(currstabreloc) and
                              (currstabreloc.dataoffset<j*sizeof(TObjStabEntry)+stabrelocofs) do
                          currstabreloc:=TObjRelocation(currstabreloc.next);
                        if assigned(currstabreloc) then
                          begin
                            if (currstabreloc.dataoffset=j*sizeof(TObjStabEntry)+stabrelocofs) then
                              begin
                                currstabreloc.dataoffset:=mergedstabsec.Size+stabrelocofs;
                                nextstabreloc:=TObjRelocation(currstabreloc.next);
                                currstabsec.relocations.remove(currstabreloc);
                                mergedstabsec.relocations.concat(currstabreloc);
                                currstabreloc:=nextstabreloc;
                              end;
                          end;
                        mergedstabsec.write(hstab,sizeof(hstab));
                      end;
                  end;
              end;

            { Unload stabs }
            if assigned(currstabstrsec) then
              currstabsec.objdata.removesection(currstabstrsec);
            currstabsec.objdata.removesection(currstabsec);
          end;

        { Generate new HdrSym }
        if mergedstabsec.Size>0 then
          begin
            hstab.strpos:=1;
            hstab.ntype:=0;
            hstab.nother:=0;
            hstab.ndesc:=word((mergedstabsec.Size div sizeof(TObjStabEntry))-1);
            hstab.nvalue:=mergedstabstrsec.Size;
            mergedstabsec.data.seek(0);
            mergedstabsec.data.write(hstab,sizeof(hstab));
          end;

        { Replace all sections with our combined stabsec }
        stabexesec.ObjSectionList.Clear;
        stabstrexesec.ObjSectionList.Clear;
        stabexesec.ObjSectionList.Add(mergedstabsec);
        stabstrexesec.ObjSectionList.Add(mergedstabstrsec);
      end;


    procedure texeoutput.Pass2_ExeSection(const aname:string);
      var
        i      : longint;
        objsec : TObjSection;
      begin
        { Section can be removed }
        FCurrExeSec:=FindExeSection(aname);
        if not assigned(CurrExeSec) then
          exit;

        { Alignment of exesection }
        CurrMemPos:=align(CurrMemPos,SectionMemAlign);
        CurrExeSec.MemPos:=CurrMemPos;
        if (oso_data in currexesec.secoptions) then
          begin
            CurrDataPos:=align(CurrDataPos,SectionDataAlign);
            CurrExeSec.DataPos:=CurrDataPos;
          end;

        { set position of object ObjSections }
        for i:=0 to CurrExeSec.ObjSectionList.Count-1 do
          begin
            objsec:=TObjSection(CurrExeSec.ObjSectionList[i]);
            { Position in memory }
            objsec.setmempos(CurrMemPos);
            { Position in File }
            if (oso_data in objsec.secoptions) then
              objsec.setdatapos(CurrDataPos);
          end;
      end;


    procedure texeoutput.Pass2_EndExeSection;
      begin
        if not assigned(CurrExeSec) then
          exit;
        { calculate size of the section }
        CurrExeSec.Size:=CurrMemPos-CurrExeSec.MemPos;
        if (oso_data in CurrExeSec.secoptions) then
          CurrExeSec.Size:=CurrDataPos-CurrExeSec.DataPos;
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


    procedure texeoutput.ExeSections_SymbolMap(s:tnamedindexitem;arg:pointer);
      var
        objsec : TObjSection;
        objsym : TObjSymbol;
        i,j    : longint;
      begin
        with texesection(s) do
          begin
            exemap.AddMemoryMapExeSection(TExeSection(s));
            for i:=0 to ObjSectionList.count-1 do
              begin
                objsec:=TObjSection(ObjSectionList[i]);
                exemap.AddMemoryMapObjectSection(objsec);
                for j:=0 to ObjSymbolList.Count-1 do
                  begin
                    objsym:=TObjSymbol(ObjSymbolList[j]);
                    { Order symbols per obj file }
                    if (objsym.objsection=objsec) and
                       (objsym.bind in [AB_GLOBAL,AB_LOCAL]) then
                    exemap.AddMemoryMapSymbol(objsym);
                  end;
              end;
          end;
      end;


    procedure texeoutput.PrintMemoryMap;
      begin
        { Step 1, Update addresses }
        if assigned(exemap) then
          begin
            exemap.AddMemoryMapHeader(ImageBase);
            ExeSections.foreach(@ExeSections_SymbolMap,nil);
          end;
      end;


    procedure texeoutput.FixUpSymbols;
      var
        i   : longint;
        sym : TObjSymbol;
      begin
        { Update ImageBase to ObjData so it can access from ObjSymbols }
        for i:=0 to ObjDataList.Count-1 do
          TObjData(ObjDataList[i]).imagebase:=imagebase;

        {
          Fixing up symbols is done in the following steps:
           1. Update common references
           2. Update external references
        }

        { Step 1, Update commons }
        for i:=0 to commonExeSymbols.count-1 do
          begin
            sym:=TObjSymbol(commonExeSymbols[i]);
            if sym.bind=AB_COMMON then
              begin
                { update this symbol }
                sym.bind:=sym.altsymbol.bind;
                sym.offset:=sym.altsymbol.offset;
                sym.size:=sym.altsymbol.size;
                sym.typ:=sym.altsymbol.typ;
                sym.objsection:=sym.altsymbol.objsection;
              end;
          end;

        { Step 2, Update externals }
        for i:=0 to externalExeSymbols.count-1 do
          begin
            sym:=TObjSymbol(externalExeSymbols[i]);
            if sym.bind=AB_EXTERNAL then
              begin
                { update this symbol }
                sym.bind:=sym.altsymbol.bind;
                sym.offset:=sym.altsymbol.offset;
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
               (
                (exesec.objsectionlist.count=0) or
                (
                 (cs_link_strip in aktglobalswitches) and
                 (oso_debug in exesec.secoptions)
                )
               ) then
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
        objsym,
        commonsym : TObjSymbol;
        firstcommon : boolean;
        i,j       : longint;
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
            for j:=0 to objdata.ObjSymbols.Count-1 do
              begin
                objsym:=TObjSymbol(objdata.ObjSymbols[j]);
                if not assigned(objsym.objsection) then
                  internalerror(200206302);
                case objsym.bind of
                  AB_GLOBAL :
                    begin
                      exesym:=texesymbol(globalExeSymbols.search(objsym.name));
                      if not assigned(exesym) then
                        begin
                          globalExeSymbols.insert(texesymbol.create(objsym));
                          if assigned(objsym.objsection.exesection) then
                            TExeSection(objsym.objsection.exesection).objsymbollist.add(objsym);
                        end
                      else
                        begin
                          Comment(V_Error,'Multiple defined symbol '+objsym.name);
                          result:=false;
                        end;
                    end;
                  AB_EXTERNAL :
                    externalExeSymbols.add(objsym);
                  AB_COMMON :
                    commonExeSymbols.add(objsym);
                end;
              end;
          end;

        { Step 2, Match common symbols or add to the globals }
        firstcommon:=true;
        for i:=0 to commonExeSymbols.count-1 do
          begin
            objsym:=TObjSymbol(commonExeSymbols[i]);
            if objsym.bind=AB_COMMON then
              begin
                exesym:=texesymbol(globalExeSymbols.search(objsym.name));
                if assigned(exesym) then
                  begin
                    if exesym.objsymbol.size<>objsym.size then
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
                    commonobjdata.setsection(commonobjsection);
                    commonsym:=commonobjdata.symboldefine(objsym.name,AB_GLOBAL,AT_FUNCTION);
                    commonsym.size:=objsym.size;
                    commonobjdata.alloc(objsym.size);
                    if assigned(exemap) then
                      exemap.AddCommonSymbol(commonsym);
                    { make this symbol available as a global }
                    globalExeSymbols.insert(texesymbol.create(commonsym));
                    TExeSection(commonsym.objsection.exesection).objsymbollist.add(commonsym);
                  end;
                objsym.altsymbol:=commonsym;
              end;
          end;
        if not firstcommon then
          commonobjdata.afteralloc;

        { Step 3 }
        for i:=0 to externalExeSymbols.count-1 do
          begin
            objsym:=TObjSymbol(externalExeSymbols[i]);
            if objsym.bind=AB_EXTERNAL then
              begin
                exesym:=texesymbol(globalExeSymbols.search(objsym.name));
                if assigned(exesym) then
                  objsym.altsymbol:=exesym.objsymbol
                else
                  begin
                    Comment(V_Error,'Undefined symbol: '+objsym.name);
                    result:=false;
                  end;
              end;
          end;

        { Find entry symbol and print in map }
        exesym:=texesymbol(globalexesymbols.search(EntryName));
        if assigned(exesym) then
          begin
            EntrySym:=exesym.objsymbol;
            if assigned(exemap) then
              begin
                exemap.Add('');
                exemap.Add('Entry symbol '+EntryName);
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
