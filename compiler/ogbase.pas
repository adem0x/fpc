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
        available : boolean;
        secsymidx,
        datasize,
        DataPos,
        memsize,
        MemPos    : longint;
        flags     : cardinal;
        constructor create(const n:string);virtual;
        destructor  destroy;override;
        procedure AddObjSection(objsec:TObjSection);
        property ObjSectionList:TList read FObjSectionList;
      end;
      TExeSectionClass=class of TExeSection;

      TExeOutput = class
      private
        { Sections }
        FCExeSection  : TExeSectionClass;
        FCurrSec      : TExeSection;
        FSectionsDict : TDictionary;
        { Symbols }
        FExternalSyms : TList;
        FCommonSyms   : TList;
        FGlobalSyms   : TDictionary;
        { Objects }
        FObjDataList  : TList;
        { Position calculation }
        FCurrDataPos,
        FCurrMemPos   : aint;
        procedure Sections_FixUpSymbol(s:tnamedindexitem;arg:pointer);
      protected
        { writer }
        FWriter : TObjectwriter;
        function  writedata:boolean;virtual;abstract;
        globalsobjdata : TObjData;
        procedure Pass1_OutputSection(const aname:string);virtual;
        procedure Pass1_EndSection;virtual;
        procedure Pass1_InputSection(const aname:string);virtual;
        procedure Pass2_OutputSection(const aname:string);virtual;
        procedure Pass2_EndSection;virtual;
        procedure Pass2_Header;virtual;
        procedure ParseScriptPass1;
        procedure ParseScriptPass2;
        property CExeSection:TExeSectionClass read FCExeSection write FCExeSection;
      public
        constructor create;virtual;
        destructor  destroy;override;
        procedure GenerateExecutable(const fn:string);virtual;abstract;
        function  writeexefile(const fn:string):boolean;
        function  CalculateSymbols:boolean;
        procedure CalculateMemoryMap;virtual;abstract;
        procedure AddObjData(objdata:TObjData);
        procedure AddGlobalSym(const name:string;ofs:longint);
        procedure FixUpSymbols;
        procedure FixUpRelocations;
        property Writer:TObjectWriter read FWriter;
        property Sections:TDictionary read FSectionsDict;
        property ObjDataList:TList read FObjDataList;
        property ExternalSyms:TList read FExternalSyms;
        property CommonSyms:TList read FCommonSyms;
        property GlobalSyms:TDictionary read FGlobalSyms;
        property CurrSec:TExeSection read FCurrSec;
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
        FGlobalSyms:=tdictionary.create;
        FGlobalSyms.usehash;
        FGlobalSyms.noclear:=true;
        FExternalSyms:=TList.create;
        FCommonSyms:=TList.create;
        FSectionsDict:=TDictionary.create;
        globalsobjdata:=TObjData.create('*GLOBALS*');
        FCExeSection:=TExeSection;
      end;


    destructor texeoutput.destroy;
      begin
        sections.free;
        globalsyms.free;
        externalsyms.free;
        commonsyms.free;
        objdatalist.free;
        globalsobjdata.free;
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
        sec:=TExeSection(FSectionsDict.search(aname));
        if not assigned(sec) then
          begin
            sec:=CExeSection.create(aname);
            FSectionsDict.Insert(sec);
          end;
        FCurrSec:=sec;
      end;


    procedure texeoutput.Pass1_EndSection;
      begin
        if not assigned(CurrSec) then
          internalerror(200602184);
        FCurrSec:=nil;
      end;


    procedure texeoutput.Pass1_InputSection(const aname:string);
      var
        i       : longint;
        objdata : TObjData;
        objsec  : TObjSection;
      begin
        if not assigned(CurrSec) then
          internalerror(200602181);
{$warning TODO Add wildcard support like *(.text*)}
        for i:=0 to ObjDataList.Count-1 do
          begin
            objdata:=TObjData(ObjDataList[i]);
            objsec:=objdata.findsection(aname);
            if assigned(objsec) then
              CurrSec.AddObjSection(objsec);
          end;
      end;


    procedure texeoutput.Pass2_OutputSection(const aname:string);
      var
        i      : longint;
        objsec : TObjSection;
        alignedpos : aint;
      begin
        FCurrSec:=TExeSection(FSectionsDict.search(aname));
        if not assigned(CurrSec) then
          internalerror(200602182);
        { set start position of section }
        CurrSec.DataPos:=CurrDataPos;
        CurrSec.MemPos:=CurrMemPos;
        { set position of object sections }
        for i:=0 to CurrSec.ObjSectionList.Count-1 do
          begin
            objsec:=TObjSection(CurrSec.ObjSectionList[i]);
            { align section }
{$warning TODO alignment per section}
            CurrMemPos:=align(CurrMemPos,$10);
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
        if not assigned(CurrSec) then
          internalerror(200602183);
        { calculate size of the section }
        CurrSec.datasize:=CurrDataPos-CurrSec.DataPos;
        CurrSec.memsize:=CurrMemPos-CurrSec.MemPos;
        FCurrSec:=nil;
      end;


    procedure texeoutput.Pass2_Header;
      begin
      end;


    procedure texeoutput.ParseScriptPass1;
      var
        t : text;
        s,
        para,
        keyword : string;
      begin
        assign(t,'pecoff.scr');
        reset(t);
        while not eof(t) do
          begin
            readln(t,s);
            keyword:=Upper(GetToken(s,' '));
            para:=GetToken(s,' ');
            if keyword='OUTPUTSECTION' then
              Pass1_OutputSection(para)
            else if keyword='ENDSECTION' then
              Pass1_EndSection
            else if keyword='INPUTSECTION' then
              Pass1_InputSection(para);
          end;
      end;


    procedure texeoutput.ParseScriptPass2;
      var
        t : text;
        s,
        para,
        keyword : string;
      begin
        assign(t,'pecoff.scr');
        reset(t);
        while not eof(t) do
          begin
            readln(t,s);
            keyword:=Upper(GetToken(s,' '));
            para:=GetToken(s,' ');
            if keyword='OUTPUTSECTION' then
              Pass2_OutputSection(para)
            else if keyword='ENDSECTION' then
              Pass2_EndSection
            else if keyword='HEADER' then
              Pass2_Header;
          end;
      end;

(*
    procedure texeoutput.MapObjData(var DataPos:longint;var MemPos:longint);
      var
        sec : TSection;
        s   : TObjSection;
        alignedpos : longint;
        objdata : TObjData;
      begin
        { calculate offsets of each objdata }
        for sec:=low(TSection) to high(TSection) do
         begin
           if sections[sec].available then
            begin
              { set start position of section }
              sections[sec].DataPos:=DataPos;
              sections[sec].MemPos:=MemPos;
              { update objectfiles }
              objdata:=TObjData(objdatalist.first);
              while assigned(objdata) do
               begin
                 s:=objdata.Sections[sec];
                 if assigned(s) then
                  begin
                    { align section }
                    MemPos:=align(MemPos,$10);
                    if assigned(s.data) then
                     begin
                       alignedpos:=align(DataPos,$10);
                       s.dataalignbytes:=alignedpos-DataPos;
                       DataPos:=alignedpos;
                     end;
                    { set position and size of this objectfile }
                    s.MemPos:=MemPos;
                    s.DataPos:=DataPos;
                    inc(MemPos,s.datasize);
                    if assigned(s.data) then
                     inc(DataPos,s.datasize);
                  end;
                 objdata:=TObjData(objdata.next);
               end;
              { calculate size of the section }
              sections[sec].datasize:=DataPos-sections[sec].DataPos;
              sections[sec].memsize:=MemPos-sections[sec].MemPos;
            end;
         end;
*)


    procedure texeoutput.Sections_FixUpSymbol(s:tnamedindexitem;arg:pointer);
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
                hsym:=tasmsymbol(objsec.owner.symbols.first);
                while assigned(hsym) do
                  begin
                    { process only the symbols that are defined in this section
                      and are located in this module }
                    if ((hsym.section=objsec) or
                        ((objsec.sectype=sec_bss) and (hsym.section.sectype=sec_common))) then
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
        sections.foreach(@sections_fixupsymbol,nil);
        { Step 2, Update commons }
        for i:=0 to commonsyms.count-1 do
          begin
            sym:=tasmsymbol(commonsyms[i]);
            if sym.currbind=AB_COMMON then
              begin
                { update this symbol }
                sym.currbind:=sym.altsymbol.currbind;
                sym.address:=sym.altsymbol.address;
                sym.size:=sym.altsymbol.size;
                sym.section:=sym.altsymbol.section;
                sym.typ:=sym.altsymbol.typ;
                sym.owner:=sym.altsymbol.owner;
              end;
          end;
        { Step 3, Update externals }
        for i:=0 to externalsyms.count-1 do
          begin
            sym:=tasmsymbol(externalsyms[i]);
            if sym.currbind=AB_EXTERNAL then
              begin
                { update this symbol }
                sym.currbind:=sym.altsymbol.currbind;
                sym.address:=sym.altsymbol.address;
                sym.size:=sym.altsymbol.size;
                sym.section:=sym.altsymbol.section;
                sym.typ:=sym.altsymbol.typ;
                sym.owner:=sym.altsymbol.owner;
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
        sym:=tasmsymbol(globalsyms.search(name));
        if not assigned(sym) then
         begin
           sym:=tasmsymbol.create(name,AB_GLOBAL,AT_FUNCTION);
           globalsyms.insert(sym);
         end;
        sym.currbind:=AB_GLOBAL;
        sym.address:=ofs;
      end;


    function TExeOutput.CalculateSymbols:boolean;
      var
        commonobjdata,
        objdata : TObjData;
        sym,p   : tasmsymbol;
        i       : longint;
      begin
        commonobjdata:=nil;
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
            sym:=tasmsymbol(objdata.symbols.first);
            while assigned(sym) do
              begin
                if not assigned(sym.owner) then
                  internalerror(200206302);
                case sym.currbind of
                  AB_GLOBAL :
                    begin
                      p:=tasmsymbol(globalsyms.search(sym.name));
                      if not assigned(p) then
                        globalsyms.insert(sym)
                      else
                        begin
                          Comment(V_Error,'Multiple defined symbol '+sym.name);
                          result:=false;
                        end;
                    end;
                  AB_EXTERNAL :
                    externalsyms.add(sym);
                  AB_COMMON :
                    commonsyms.add(sym);
                end;
                sym:=tasmsymbol(sym.indexnext);
              end;
          end;
        { Step 2, Match common symbols or add to the globals }
        for i:=0 to commonsyms.count-1 do
          begin
            sym:=tasmsymbol(commonsyms[i]);
            if sym.currbind=AB_COMMON then
              begin
                p:=tasmsymbol(globalsyms.search(sym.name));
                if assigned(p) then
                  begin
                    if p.size<>sym.size then
                     internalerror(200206301);
                  end
                else
                  begin
                    { allocate new symbol in .bss and store it in the
                      *COMMON* module }
                    if not assigned(commonobjdata) then
                      begin
                        if assigned(exemap) then
                          exemap.AddCommonSymbolsHeader;
                        { create .bss section and add to list }
                        commonobjdata:=TObjData.create('*COMMON*');
                        commonobjdata.createsection(sec_bss,'',0,[aso_alloconly]);
                        AddObjData(commonobjdata);
                      end;
                    p:=TAsmSymbol.Create(sym.name,AB_GLOBAL,AT_FUNCTION);
                    commonobjdata.writesymbol(p);
                    if assigned(exemap) then
                      exemap.AddCommonSymbol(p);
                    { make this symbol available as a global }
                    globalsyms.insert(p);
                  end;
                sym.altsymbol:=p;
              end;
          end;
        { Step 3 }
        for i:=0 to externalsyms.count-1 do
          begin
            sym:=tasmsymbol(externalsyms[i]);
            if sym.currbind=AB_EXTERNAL then
              begin
                p:=tasmsymbol(globalsyms.search(sym.name));
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
