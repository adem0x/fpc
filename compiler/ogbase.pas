{
    Copyright (c) 1998-2002 by Peter Vreman

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

      TExeSection = class(tnamedindexitem)
      private
        FObjSectionList : TList;
      public
        SecType   : TObjSectionType;
        available : boolean;
        secsymidx,
        datasize,
        DataPos,
        memsize,
        MemPos    : aint;
        flags     : cardinal;
        constructor create(const n:string);virtual;
        destructor  destroy;override;
        procedure AddObjSection(objsec:TObjSection);
        property ObjSectionList:TList read FObjSectionList;
      end;
      TExeSectionClass=class of TExeSection;

      TExeOutput = class
      private
        { ExeSections }
        FCExeSection     : TExeSectionClass;
        FCurrExeSec      : TExeSection;
        FExeSectionsDict : TDictionary;
        { Symbols }
        FExternalExeSymbols : TList;
        FCommonExeSymbols   : TList;
        FGlobalExeSymbols   : TDictionary;
        { Objects }
        FObjDataList  : TList;
        { Position calculation }
        FCurrDataPos,
        FCurrMemPos   : aint;
        procedure ExeSections_FixUpSymbol(s:tnamedindexitem;arg:pointer);
      protected
        { writer }
        FWriter : TObjectwriter;
        commonobjdata,
        globalsobjdata : TObjData;
        procedure AddGlobalSym(const name:string;ofs:longint);
        function  writedata:boolean;virtual;abstract;
        procedure ExeSections_write_data(p:tnamedindexitem;arg:pointer);
        property CExeSection:TExeSectionClass read FCExeSection write FCExeSection;
      public
        constructor create;virtual;
        destructor  destroy;override;
        procedure AddObjData(objdata:TObjData);
        procedure Pass1_OutputSection(const aname:string);virtual;
        procedure Pass1_EndSection;virtual;
        procedure Pass1_InputSection(const aname:string);virtual;
        procedure Pass2_OutputSection(const aname:string);virtual;
        procedure Pass2_EndSection;virtual;
        procedure Pass2_Header;virtual;
        procedure Pass2_Start;virtual;
        procedure Pass2_Symbols;virtual;
        function  CalculateSymbols:boolean;
        procedure FixUpSymbols;
        procedure FixUpRelocations;
        function  writeexefile(const fn:string):boolean;
        property Writer:TObjectWriter read FWriter;
        property ExeSections:TDictionary read FExeSectionsDict;
        property ObjDataList:TList read FObjDataList;
        property ExternalExeSymbols:TList read FExternalExeSymbols;
        property CommonExeSymbols:TList read FCommonExeSymbols;
        property GlobalExeSymbols:TDictionary read FGlobalExeSymbols;
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
                                texesection
****************************************************************************}

    constructor texesection.create(const n:string);
      begin
        inherited createname(n);
        MemPos:=0;
        memsize:=0;
        DataPos:=0;
        datasize:=0;
        secsymidx:=0;
        available:=false;
        flags:=0;
        FObjSectionList:=TList.Create;
      end;


    destructor texesection.destroy;
      begin
        ObjSectionList.Free;
      end;


    procedure texesection.AddObjSection(objsec:TObjSection);
      begin
        ObjSectionList.Add(objsec);
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
        FGlobalExeSymbols.noclear:=true;
        FExternalExeSymbols:=TList.create;
        FCommonExeSymbols:=TList.create;
        FExeSectionsDict:=TDictionary.create;
        globalsobjdata:=TObjData.create('*GLOBALS*');
        AddObjData(globalsobjdata);
        commonobjdata:=TObjData.create('*COMMON*');
        AddObjData(commonobjdata);
        FCExeSection:=TExeSection;
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
        ObjDataList.Add(objdata);
      end;


    procedure texeoutput.Pass1_OutputSection(const aname:string);
      var
        sec : TExeSection;
      begin
        sec:=TExeSection(FExeSectionsDict.search(aname));
        if not assigned(sec) then
          begin
            sec:=CExeSection.create(aname);
            FExeSectionsDict.Insert(sec);
          end;
        FCurrExeSec:=sec;
      end;


    procedure texeoutput.Pass1_EndSection;
      begin
        if not assigned(CurrExeSec) then
          internalerror(200602184);
        FCurrExeSec:=nil;
      end;


    procedure texeoutput.Pass1_InputSection(const aname:string);
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
              CurrExeSec.AddObjSection(objsec);
          end;
      end;


    procedure texeoutput.Pass2_OutputSection(const aname:string);
      var
        i      : longint;
        objsec : TObjSection;
        alignedpos : aint;
      begin
        FCurrExeSec:=TExeSection(FExeSectionsDict.search(aname));
        if not assigned(CurrExeSec) then
          internalerror(200602182);
        { set start position of section }
        CurrExeSec.DataPos:=CurrDataPos;
        CurrExeSec.MemPos:=CurrMemPos;
        { set position of object ObjSections }
        for i:=0 to CurrExeSec.ObjSectionList.Count-1 do
          begin
            objsec:=TObjSection(CurrExeSec.ObjSectionList[i]);
            { align section }
{$warning TODO alignment per section}
            CurrMemPos:=align(CurrMemPos,$1000);
            if assigned(objsec.data) then
              begin
                alignedpos:=align(CurrDataPos,$10);
                objsec.dataalignbytes:=alignedpos-CurrDataPos;
                CurrDataPos:=alignedpos;
              end;
            { set position and size of this objectfile }
            objsec.MemPos:=CurrMemPos;
            objsec.DataPos:=CurrDataPos;
            inc(CurrMemPos,objsec.datasize);
            if assigned(objsec.data) then
              inc(CurrDataPos,objsec.datasize);
         end;
      end;


    procedure texeoutput.Pass2_EndSection;
      begin
        if not assigned(CurrExeSec) then
          internalerror(200602183);
        { calculate size of the section }
        CurrExeSec.datasize:=CurrDataPos-CurrExeSec.DataPos;
        CurrExeSec.memsize:=CurrMemPos-CurrExeSec.MemPos;
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
                    if ((hsym.objsection=objsec) or
                        ((objsec.sectype=sec_bss) and (hsym.objsection.sectype=sec_common))) then
                      begin
                        if hsym.currbind=AB_EXTERNAL then
                          internalerror(200206303);
                        inc(hsym.address,objsec.MemPos);
                        if assigned(exemap) then
                          exemap.AddMemoryMapSymbol(hsym);
                      end;
                    hsym:=tasmsymbol(hsym.indexnext);
                  end;
              end;
          end;
      end;


    procedure Texeoutput.ExeSections_write_Data(p:tnamedindexitem;arg:pointer);
      var
        objsec : TObjSection;
        i      : longint;
      begin
        with texesection(p) do
          begin
            for i:=0 to ObjSectionList.Count-1 do
              begin
                objsec:=TObjSection(ObjSectionList[i]);
                if assigned(objsec.data) then
                  begin
                    FWriter.writezeros(objsec.dataalignbytes);
                    FWriter.writearray(objsec.data);
                  end;
              end;
          end;
      end;


    procedure texeoutput.FixUpSymbols;
      var
        i   : longint;
        sym : tasmsymbol;
      begin
        {
          Fixing up symbols is done in the following steps:
           1. Update addresses
           2. Update common references
           3. Update external references
        }
        { Step 1, Update addresses }
        if assigned(exemap) then
          exemap.AddMemoryMapHeader;
        ExeSections.foreach(@ExeSections_FixUpSymbol,nil);
        { Step 2, Update commons }
        for i:=0 to commonExeSymbols.count-1 do
          begin
            sym:=tasmsymbol(commonExeSymbols[i]);
            if sym.currbind=AB_COMMON then
              begin
                { update this symbol }
                sym.currbind:=sym.altsymbol.currbind;
                sym.address:=sym.altsymbol.address;
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
                sym.address:=sym.altsymbol.address;
                sym.size:=sym.altsymbol.size;
                sym.typ:=sym.altsymbol.typ;
                sym.objsection:=sym.altsymbol.objsection;
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


    procedure texeoutput.AddGlobalSym(const name:string;ofs:longint);
      var
        sym : tasmsymbol;
      begin
        sym:=tasmsymbol(globalExeSymbols.search(name));
        if not assigned(sym) then
         begin
           sym:=tasmsymbol.create(name,AB_GLOBAL,AT_FUNCTION);
           { Create a dummy section }
           sym.objsection:=globalsobjdata.createsection(sec_none,'*'+sym.name,0,[aso_alloconly]);
           globalsobjdata.ObjSymbols.insert(sym);
           globalExeSymbols.insert(sym);
         end;
        sym.currbind:=AB_GLOBAL;
        sym.address:=ofs;
      end;


    function TExeOutput.CalculateSymbols:boolean;
      var
        commonobjsection : TObjSection;
        objdata : TObjData;
        sym,p   : tasmsymbol;
        i       : longint;
      begin
        commonobjsection:=nil;
        CalculateSymbols:=true;
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
                      p:=tasmsymbol(globalExeSymbols.search(sym.name));
                      if not assigned(p) then
                        globalExeSymbols.insert(sym)
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
        for i:=0 to commonExeSymbols.count-1 do
          begin
            sym:=tasmsymbol(commonExeSymbols[i]);
            if sym.currbind=AB_COMMON then
              begin
                p:=tasmsymbol(globalExeSymbols.search(sym.name));
                if assigned(p) then
                  begin
                    if p.size<>sym.size then
                     internalerror(200206301);
                  end
                else
                  begin
                    { allocate new symbol in .bss and store it in the
                      *COMMON* module }
                    if not assigned(commonobjsection) then
                      begin
                        if assigned(exemap) then
                          exemap.AddCommonSymbolsHeader;
                        { create .bss section and add to list }
                        commonobjsection:=commonobjdata.createsection(sec_bss,'',0,[aso_alloconly]);
                      end;
                    p:=TAsmSymbol.Create(sym.name,AB_GLOBAL,AT_FUNCTION);
                    p.objsection:=commonobjsection;
                    commonobjdata.ObjSymbols.insert(p);
                    if assigned(exemap) then
                      exemap.AddCommonSymbol(p);
                    { make this symbol available as a global }
                    globalExeSymbols.insert(p);
                  end;
                sym.altsymbol:=p;
              end;
          end;
        { Step 3 }
        for i:=0 to externalExeSymbols.count-1 do
          begin
            sym:=tasmsymbol(externalExeSymbols[i]);
            if sym.currbind=AB_EXTERNAL then
              begin
                p:=tasmsymbol(globalExeSymbols.search(sym.name));
                if assigned(p) then
                  begin
                    sym.altsymbol:=p;
                  end
                else
                  begin
                    Comment(V_Error,'Undefined symbol: '+sym.name);
                    CalculateSymbols:=false;
                  end;
              end;
          end;
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
