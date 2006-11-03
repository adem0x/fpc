{
    Copyright (c) 1998-2004 by Peter Vreman

    This unit handles the assemblerfile write and assembler calls of FPC

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
{# @abstract(This unit handles the assembler file write and assembler calls of FPC)
   Handles the calls to the actual external assemblers, as well as the generation
   of object files for smart linking. Also contains the base class for writing
   the assembler statements to file.
}
unit assemble;

{$i fpcdefs.inc}

interface


    uses
      SysUtils,
      systems,globtype,globals,aasmbase,aasmtai,aasmdata,ogbase;

    const
       { maximum of aasmoutput lists there will be }
       maxoutputlists = 20;
       { buffer size for writing the .s file }
       AsmOutSize=32768;

    type
      TAssembler=class(TAbstractAssembler)
      public
      {filenames}
        path        : string;
        name        : string;
        AsmFileName,         { current .s and .o file }
        ObjFileName,
        ppufilename  : string;
        asmprefix    : string;
        SmartAsm     : boolean;
        SmartFilesCount,
        SmartHeaderCount : longint;
        Constructor Create(smart:boolean);virtual;
        Destructor Destroy;override;
        procedure NextSmartName(place:tcutplace);
        procedure MakeObject;virtual;abstract;
      end;

      {# This is the base class which should be overriden for each each
         assembler writer. It is used to actually assembler a file,
         and write the output to the assembler file.
      }
      TExternalAssembler=class(TAssembler)
      private
        procedure CreateSmartLinkPath(const s:string);
      protected
      {outfile}
        AsmSize,
        AsmStartSize,
        outcnt   : longint;
        outbuf   : array[0..AsmOutSize-1] of char;
        outfile  : file;
        ioerror : boolean;
      public
        {# Returns the complete path and executable name of the assembler
           program.

           It first tries looking in the UTIL directory if specified,
           otherwise it searches in the free pascal binary directory, in
           the current working directory and then in the  directories
           in the $PATH environment.}
        Function  FindAssembler:string;

        {# Actually does the call to the assembler file. Returns false
           if the assembling of the file failed.}
        Function  CallAssembler(const command:string; const para:TCmdStr):Boolean;

        Function  DoAssemble:boolean;virtual;
        Procedure RemoveAsm;
        Procedure AsmFlush;
        Procedure AsmClear;

        {# Write a string to the assembler file }
        Procedure AsmWrite(const s:string);

        {# Write a string to the assembler file }
        Procedure AsmWritePChar(p:pchar);

        {# Write a string to the assembler file followed by a new line }
        Procedure AsmWriteLn(const s:string);

        {# Write a new line to the assembler file }
        Procedure AsmLn;

        procedure AsmCreate(Aplace:tcutplace);
        procedure AsmClose;

        {# This routine should be overriden for each assembler, it is used
           to actually write the abstract assembler stream to file.}
        procedure WriteTree(p:TAsmList);virtual;

        {# This routine should be overriden for each assembler, it is used
           to actually write all the different abstract assembler streams
           by calling for each stream type, the @var(WriteTree) method.}
        procedure WriteAsmList;virtual;

        {# Constructs the command line for calling the assembler }
        function MakeCmdLine: TCmdStr; virtual;
      public
        Constructor Create(smart:boolean);override;
        procedure MakeObject;override;
      end;

      TInternalAssembler=class(TAssembler)
      private
        FCObjOutput : TObjOutputclass;
        { the aasmoutput lists that need to be processed }
        lists        : byte;
        list         : array[1..maxoutputlists] of TAsmList;
        { current processing }
        currlistidx  : byte;
        currlist     : TAsmList;
        procedure WriteStab(p:pchar);
        function  MaybeNextList(var hp:Tai):boolean;
        function  TreePass0(hp:Tai):Tai;
        function  TreePass1(hp:Tai):Tai;
        function  TreePass2(hp:Tai):Tai;
        procedure writetree;
        procedure writetreesmart;
      protected
        ObjData   : TObjData;
        ObjOutput : tObjOutput;
        property CObjOutput:TObjOutputclass read FCObjOutput write FCObjOutput;
      public
        constructor create(smart:boolean);override;
        destructor  destroy;override;
        procedure MakeObject;override;
      end;

    TAssemblerClass = class of TAssembler;

    Procedure GenerateAsm(smart:boolean);
    Procedure OnlyAsm;

    procedure RegisterAssembler(const r:tasminfo;c:TAssemblerClass);
    procedure InitAssembler;
    procedure DoneAssembler;


Implementation

    uses
{$ifdef hasunix}
      unix,
{$endif}
      cutils,cfileutils,
{$ifdef memdebug}
      cclasses,
{$endif memdebug}
      script,fmodule,verbose,
{$ifdef m68k}
      cpuinfo,
{$endif m68k}
      aasmcpu,
      owbase,owar
      ;

    var
      CAssembler : array[tasm] of TAssemblerClass;


{*****************************************************************************
                                   TAssembler
*****************************************************************************}

    Constructor TAssembler.Create(smart:boolean);
      begin
      { load start values }
        AsmFileName:=current_module.AsmFilename^;
        ObjFileName:=current_module.ObjFileName^;
        name:=Lower(current_module.modulename^);
        path:=current_module.outputpath^;
        asmprefix := current_module.asmprefix^;
        if not assigned(current_module.outputpath) then
          ppufilename := ''
        else
          ppufilename := current_module.ppufilename^;
        SmartAsm:=smart;
        SmartFilesCount:=0;
        SmartHeaderCount:=0;
        SmartLinkOFiles.Clear;
      end;


    Destructor TAssembler.Destroy;
      begin
      end;


    procedure TAssembler.NextSmartName(place:tcutplace);
      var
        s : string;
      begin
        inc(SmartFilesCount);
        if SmartFilesCount>999999 then
         Message(asmw_f_too_many_asm_files);
        case place of
          cut_begin :
            begin
              inc(SmartHeaderCount);
              s:=asmprefix+tostr(SmartHeaderCount)+'h';
            end;
          cut_normal :
            s:=asmprefix+tostr(SmartHeaderCount)+'s';
          cut_end :
            s:=asmprefix+tostr(SmartHeaderCount)+'t';
        end;
        AsmFileName:=Path+FixFileName(s+tostr(SmartFilesCount)+target_info.asmext);
        ObjFileName:=Path+FixFileName(s+tostr(SmartFilesCount)+target_info.objext);
        { insert in container so it can be cleared after the linking }
        SmartLinkOFiles.Insert(ObjFileName);
      end;


{*****************************************************************************
                                 TExternalAssembler
*****************************************************************************}

    Function DoPipe:boolean;
      begin
        DoPipe:=(cs_asm_pipe in current_settings.globalswitches) and
                (([cs_asm_leave,cs_link_on_target] * current_settings.globalswitches) = []) and
                ((target_asm.id in [as_gas,as_darwin]));
      end;


    Constructor TExternalAssembler.Create(smart:boolean);
      begin
        inherited Create(smart);
        if SmartAsm then
         begin
           path:=FixPath(path+ChangeFileExt(AsmFileName,target_info.smartext),false);
           CreateSmartLinkPath(path);
         end;
        Outcnt:=0;
      end;


    procedure TExternalAssembler.CreateSmartLinkPath(const s:string);

        procedure DeleteFilesWithExt(const AExt:string);
        var
          dir : TSearchRec;
        begin
          if findfirst(s+source_info.dirsep+'*'+AExt,faAnyFile,dir) = 0 then
            begin
              repeat
                DeleteFile(s+source_info.dirsep+dir.name);
              until findnext(dir) <> 0;
            end;
          findclose(dir);
        end;

      var
        dir : TSearchRec;
        hs  : string;
      begin
        if PathExists(s,false) then
         begin
           { the path exists, now we clean only all the .o and .s files }
           DeleteFilesWithExt(target_info.objext);
           DeleteFilesWithExt(target_info.asmext);
         end
        else
         begin
           hs:=s;
           if hs[length(hs)] in ['/','\'] then
            delete(hs,length(hs),1);
           {$I-}
            mkdir(hs);
           {$I+}
           if ioresult<>0 then;
         end;
      end;


    const
      lastas  : byte=255;
    var
      LastASBin : string;
    Function TExternalAssembler.FindAssembler:string;
      var
        asfound : boolean;
        UtilExe  : string;
      begin
        asfound:=false;
        if cs_link_on_target in current_settings.globalswitches then
         begin
           { If linking on target, don't add any path PM }
           FindAssembler:=utilsprefix+ChangeFileExt(target_asm.asmbin,target_info.exeext);
           exit;
         end
        else
         UtilExe:=utilsprefix+ChangeFileExt(target_asm.asmbin,source_info.exeext);
        if lastas<>ord(target_asm.id) then
         begin
           lastas:=ord(target_asm.id);
           { is an assembler passed ? }
           if utilsdirectory<>'' then
             asfound:=FindFile(UtilExe,utilsdirectory,false,LastASBin);
           if not AsFound then
             asfound:=FindExe(UtilExe,false,LastASBin);
           if (not asfound) and not(cs_asm_extern in current_settings.globalswitches) then
            begin
              Message1(exec_e_assembler_not_found,LastASBin);
              current_settings.globalswitches:=current_settings.globalswitches+[cs_asm_extern];
            end;
           if asfound then
            Message1(exec_t_using_assembler,LastASBin);
         end;
        FindAssembler:=LastASBin;
      end;


    Function TExternalAssembler.CallAssembler(const command:string; const para:TCmdStr):Boolean;
      var
        DosExitCode : Integer;
      begin
        result:=true;
        if (cs_asm_extern in current_settings.globalswitches) then
          begin
            AsmRes.AddAsmCommand(command,para,name);
            exit;
          end;
        try
          FlushOutput;
          DosExitCode := ExecuteProcess(command,para);
          if DosExitCode <>0
          then begin
            Message1(exec_e_error_while_assembling,tostr(dosexitcode));
            result:=false;
          end;
        except on E:EOSError do
          begin
            Message1(exec_e_cant_call_assembler,tostr(E.ErrorCode));
            current_settings.globalswitches:=current_settings.globalswitches+[cs_asm_extern];
            result:=false;
          end;
        end;
      end;


    procedure TExternalAssembler.RemoveAsm;
      var
        g : file;
      begin
        if cs_asm_leave in current_settings.globalswitches then
         exit;
        if cs_asm_extern in current_settings.globalswitches then
         AsmRes.AddDeleteCommand(AsmFileName)
        else
         begin
           assign(g,AsmFileName);
           {$I-}
            erase(g);
           {$I+}
           if ioresult<>0 then;
         end;
      end;


    Function TExternalAssembler.DoAssemble:boolean;
      begin
        DoAssemble:=true;
        if DoPipe then
         exit;
        if not(cs_asm_extern in current_settings.globalswitches) then
         begin
           if SmartAsm then
            begin
              if (SmartFilesCount<=1) then
               Message1(exec_i_assembling_smart,name);
            end
           else
           Message1(exec_i_assembling,name);
         end;

        if CallAssembler(FindAssembler,MakeCmdLine) then
         RemoveAsm
        else
         begin
            DoAssemble:=false;
            GenerateError;
         end;
      end;


    Procedure TExternalAssembler.AsmFlush;
      begin
        if outcnt>0 then
         begin
           { suppress i/o error }
           {$i-}
           BlockWrite(outfile,outbuf,outcnt);
           {$i+}
           ioerror:=ioerror or (ioresult<>0);
           outcnt:=0;
         end;
      end;


    Procedure TExternalAssembler.AsmClear;
      begin
        outcnt:=0;
      end;


    Procedure TExternalAssembler.AsmWrite(const s:string);
      begin
        if OutCnt+length(s)>=AsmOutSize then
         AsmFlush;
        Move(s[1],OutBuf[OutCnt],length(s));
        inc(OutCnt,length(s));
        inc(AsmSize,length(s));
      end;


    Procedure TExternalAssembler.AsmWriteLn(const s:string);
      begin
        AsmWrite(s);
        AsmLn;
      end;


    Procedure TExternalAssembler.AsmWritePChar(p:pchar);
      var
        i,j : longint;
      begin
        i:=StrLen(p);
        j:=i;
        while j>0 do
         begin
           i:=min(j,AsmOutSize);
           if OutCnt+i>=AsmOutSize then
            AsmFlush;
           Move(p[0],OutBuf[OutCnt],i);
           inc(OutCnt,i);
           inc(AsmSize,i);
           dec(j,i);
           p:=pchar(@p[i]);
         end;
      end;


    Procedure TExternalAssembler.AsmLn;
      begin
        if OutCnt>=AsmOutSize-2 then
         AsmFlush;
        if (cs_link_on_target in current_settings.globalswitches) then
          begin
            OutBuf[OutCnt]:=target_info.newline[1];
            inc(OutCnt);
            inc(AsmSize);
            if length(target_info.newline)>1 then
             begin
               OutBuf[OutCnt]:=target_info.newline[2];
               inc(OutCnt);
               inc(AsmSize);
             end;
          end
        else
          begin
            OutBuf[OutCnt]:=source_info.newline[1];
            inc(OutCnt);
            inc(AsmSize);
            if length(source_info.newline)>1 then
             begin
               OutBuf[OutCnt]:=source_info.newline[2];
               inc(OutCnt);
               inc(AsmSize);
             end;
          end;
      end;


    function TExternalAssembler.MakeCmdLine: TCmdStr;
      begin
        result:=target_asm.asmcmd;
{$ifdef m68k}
        if current_settings.cputype = cpu_MC68020 then
          result:='-m68020 '+result
        else
          result:='-m68000 '+result;
{$endif}
        if (cs_link_on_target in current_settings.globalswitches) then
         begin
           Replace(result,'$ASM',maybequoted(ScriptFixFileName(AsmFileName)));
           Replace(result,'$OBJ',maybequoted(ScriptFixFileName(ObjFileName)));
         end
        else
         begin
{$ifdef hasunix}
          if DoPipe then
            Replace(result,'$ASM','')
          else
{$endif}
             Replace(result,'$ASM',maybequoted(AsmFileName));
           Replace(result,'$OBJ',maybequoted(ObjFileName));
         end;
      end;


    procedure TExternalAssembler.AsmCreate(Aplace:tcutplace);
      begin
        if SmartAsm then
         NextSmartName(Aplace);
{$ifdef hasunix}
        if DoPipe then
         begin
           if SmartAsm then
            begin
              if (SmartFilesCount<=1) then
               Message1(exec_i_assembling_smart,name);
            end
           else
             Message1(exec_i_assembling_pipe,AsmFileName);
           POpen(outfile,FindAssembler+' '+MakeCmdLine,'W');
         end
        else
{$endif}
         begin
           Assign(outfile,AsmFileName);
           {$I-}
           Rewrite(outfile,1);
           {$I+}
           if ioresult<>0 then
             begin
               ioerror:=true;
               Message1(exec_d_cant_create_asmfile,AsmFileName);
             end;
         end;
        outcnt:=0;
        AsmSize:=0;
        AsmStartSize:=0;
      end;


    procedure TExternalAssembler.AsmClose;
      var
        f : file;
        FileAge : longint;
      begin
        AsmFlush;
{$ifdef hasunix}
        if DoPipe then
          begin
            if PClose(outfile) <> 0 then
              GenerateError;
          end
        else
{$endif}
         begin
         {Touch Assembler time to ppu time is there is a ppufilename}
           if ppufilename<>'' then
            begin
              Assign(f,ppufilename);
              {$I-}
              reset(f,1);
              {$I+}
              if ioresult=0 then
               begin
                 FileAge := FileGetDate(GetFileHandle(f));
                 close(f);
                 reset(outfile,1);
                 FileSetDate(GetFileHandle(outFile),FileAge);
               end;
            end;
           close(outfile);
         end;
      end;


    procedure TExternalAssembler.WriteTree(p:TAsmList);
      begin
      end;


    procedure TExternalAssembler.WriteAsmList;
      begin
      end;


    procedure TExternalAssembler.MakeObject;
      begin
        AsmCreate(cut_normal);
        WriteAsmList;
        AsmClose;
        if not(ioerror) then
          DoAssemble;
      end;


{*****************************************************************************
                                  TInternalAssembler
*****************************************************************************}

    constructor TInternalAssembler.create(smart:boolean);
      begin
        inherited create(smart);
        ObjOutput:=nil;
        ObjData:=nil;
        SmartAsm:=smart;
      end;


   destructor TInternalAssembler.destroy;
{$ifdef MEMDEBUG}
      var
        d : tmemdebug;
{$endif}
      begin
{$ifdef MEMDEBUG}
        d := tmemdebug.create(name+' - agbin');
{$endif}
        if assigned(ObjData) then
          ObjData.free;
        if assigned(ObjOutput) then
          ObjOutput.free;
{$ifdef MEMDEBUG}
        d.free;
{$endif}
      end;


    procedure TInternalAssembler.WriteStab(p:pchar);

        function consumecomma(var p:pchar):boolean;
        begin
          while (p^=' ') do
            inc(p);
          result:=(p^=',');
          inc(p);
        end;

        function consumenumber(var p:pchar;out value:longint):boolean;
        var
          hs : string;
          len,
          code : integer;
        begin
          value:=0;
          while (p^=' ') do
            inc(p);
          len:=0;
          while (p^ in ['0'..'9']) do
            begin
              inc(len);
              hs[len]:=p^;
              inc(p);
            end;
          if len>0 then
            begin
              hs[0]:=chr(len);
              val(hs,value,code);
            end
          else
            code:=-1;
          result:=(code=0);
        end;

        function consumeoffset(var p:pchar;out relocsym:tobjsymbol;out value:longint):boolean;
        var
          hs        : string;
          len,
          code      : integer;
          pstart    : pchar;
          sym       : tobjsymbol;
          exprvalue : longint;
          gotmin,
          dosub     : boolean;
        begin
          result:=false;
          value:=0;
          relocsym:=nil;
          gotmin:=false;
          repeat
            dosub:=false;
            exprvalue:=0;
            if gotmin then
              begin
                dosub:=true;
                gotmin:=false;
              end;
            while (p^=' ') do
              inc(p);
            case p^ of
              #0 :
                break;
              ' ' :
                inc(p);
              '0'..'9' :
                begin
                  len:=0;
                  while (p^ in ['0'..'9']) do
                    begin
                      inc(len);
                      hs[len]:=p^;
                      inc(p);
                    end;
                  hs[0]:=chr(len);
                  val(hs,exprvalue,code);
                end;
              '.','_',
              'A'..'Z',
              'a'..'z' :
                begin
                  pstart:=p;
                  while not(p^ in [#0,' ','-','+']) do
                    inc(p);
                  len:=p-pstart;
                  if len>255 then
                    internalerror(200509187);
                  move(pstart^,hs[1],len);
                  hs[0]:=chr(len);
                  sym:=objdata.symbolref(hs);
                  { Second symbol? }
                  if assigned(relocsym) then
                    begin
                      if (relocsym.objsection<>sym.objsection) then
                        internalerror(2005091810);
                      relocsym:=nil;
                    end
                  else
                    relocsym:=sym;
                  exprvalue:=sym.address;
                end;
              '+' :
                begin
                  { nothing, by default addition is done }
                  inc(p);
                end;
              '-' :
                begin
                  gotmin:=true;
                  inc(p);
                end;
              else
                internalerror(200509189);
            end;
            if dosub then
              dec(value,exprvalue)
            else
              inc(value,exprvalue);
          until false;
          result:=true;
        end;

      const
        N_Function = $24; { function or const }
      var
        stabstrlen,
        ofs,
        nline,
        nidx,
        nother,
        i         : longint;
        stab      : TObjStabEntry;
        relocsym  : TObjSymbol;
        pstr,
        pcurr,
        pendquote : pchar;
        oldsec    : TObjSection;
        reltype   : TObjRelocationType;
      begin
        pcurr:=nil;
        pstr:=nil;
        pendquote:=nil;

        { Parse string part }
        if (p[0]='"') then
          begin
            pstr:=@p[1];
            { Ignore \" inside the string }
            i:=1;
            while not((p[i]='"') and (p[i-1]<>'\')) and
                  (p[i]<>#0) do
              inc(i);
            pendquote:=@p[i];
            pendquote^:=#0;
            pcurr:=@p[i+1];
            if not consumecomma(pcurr) then
              internalerror(200509181);
          end
        else
          pcurr:=p;

        { When in pass 1 then only alloc and leave }
        if ObjData.currpass=1 then
          begin
            ObjData.StabsSec.Alloc(sizeof(TObjStabEntry));
            if assigned(pstr) and (pstr[0]<>#0) then
              ObjData.StabStrSec.Alloc(strlen(pstr)+1);
          end
        else
          begin
            { Stabs format: nidx,nother,nline[,offset] }
            if not consumenumber(pcurr,nidx) then
              internalerror(200509182);
            if not consumecomma(pcurr) then
              internalerror(200509183);
            if not consumenumber(pcurr,nother) then
              internalerror(200509184);
            if not consumecomma(pcurr) then
              internalerror(200509185);
            if not consumenumber(pcurr,nline) then
              internalerror(200509186);
            if consumecomma(pcurr) then
              consumeoffset(pcurr,relocsym,ofs)
            else
              begin
                ofs:=0;
                relocsym:=nil;
              end;
            if assigned(relocsym) and
               (relocsym.bind<>AB_LOCAL) then
              ofs:=0;

            { Generate stab entry }
            if assigned(pstr) and (pstr[0]<>#0) then
              begin
                stabstrlen:=strlen(pstr);
{$ifdef optimizestabs}
                StabStrEntry:=nil;
                if (nidx=N_SourceFile) or (nidx=N_IncludeFile) then
                  begin
                    hs:=strpas(pstr);
                    StabstrEntry:=StabStrDict.Find(hs);
                    if not assigned(StabstrEntry) then
                      begin
                        StabstrEntry:=TStabStrEntry.Create(hs);
                        StabstrEntry:=StabStrSec.Size;
                        StabStrDict.Insert(StabstrEntry);
                        { generate new stab }
                        StabstrEntry:=nil;
                      end;
                  end;
                if assigned(StabstrEntry) then
                  stab.strpos:=StabstrEntry.strpos
                else
{$endif optimizestabs}
                  begin
                    stab.strpos:=ObjData.StabStrSec.Size;
                    ObjData.StabStrSec.write(pstr^,stabstrlen+1);
                  end;
              end
            else
              stab.strpos:=0;
            stab.ntype:=byte(nidx);
            stab.ndesc:=word(nline);
            stab.nother:=byte(nother);
            stab.nvalue:=ofs;

            { Write the stab first without the value field. Then
              write a the value field with relocation }
            oldsec:=ObjData.CurrObjSec;
            ObjData.SetSection(ObjData.StabsSec);
            ObjData.Writebytes(stab,sizeof(TObjStabEntry)-4);
            if DLLSource and RelocSection then
              reltype:=RELOC_RVA
            else
              reltype:=RELOC_ABSOLUTE;
            ObjData.Writereloc(stab.nvalue,4,relocsym,reltype);
            ObjData.setsection(oldsec);
          end;
        if assigned(pendquote) then
          pendquote^:='"';
      end;


    function TInternalAssembler.MaybeNextList(var hp:Tai):boolean;
      begin
        { maybe end of list }
        while not assigned(hp) do
         begin
           if currlistidx<lists then
            begin
              inc(currlistidx);
              currlist:=list[currlistidx];
              hp:=Tai(currList.first);
            end
           else
            begin
              MaybeNextList:=false;
              exit;
            end;
         end;
        MaybeNextList:=true;
      end;


    function TInternalAssembler.TreePass0(hp:Tai):Tai;
      begin
        while assigned(hp) do
         begin
           case hp.typ of
             ait_align :
               begin
                 { always use the maximum fillsize in this pass to avoid possible
                   short jumps to become out of range }
                 Tai_align_abstract(hp).fillsize:=Tai_align_abstract(hp).aligntype;
                 ObjData.alloc(Tai_align_abstract(hp).fillsize);
               end;
             ait_datablock :
               begin
                 ObjData.allocalign(used_align(size_2_align(Tai_datablock(hp).size),0,ObjData.CurrObjSec.secalign));
                 ObjData.SymbolDefine(Tai_datablock(hp).sym);
                 ObjData.alloc(Tai_datablock(hp).size);
               end;
             ait_real_80bit :
               ObjData.alloc(10);
             ait_real_64bit :
               ObjData.alloc(8);
             ait_real_32bit :
               ObjData.alloc(4);
             ait_comp_64bit :
               ObjData.alloc(8);
             ait_const:
               ObjData.alloc(tai_const(hp).size);
             ait_section:
               begin
                 ObjData.CreateSection(Tai_section(hp).sectype,Tai_section(hp).name^,Tai_section(hp).secorder);
                 Tai_section(hp).sec:=ObjData.CurrObjSec;
               end;
             ait_symbol :
               ObjData.SymbolDefine(Tai_symbol(hp).sym);
             ait_label :
               ObjData.SymbolDefine(Tai_label(hp).labsym);
             ait_string :
               ObjData.alloc(Tai_string(hp).len);
             ait_instruction :
               begin
                 { reset instructions which could change in pass 2 }
                 Taicpu(hp).resetpass2;
                 ObjData.alloc(Taicpu(hp).Pass1(ObjData));
               end;
             ait_cutobject :
               if SmartAsm then
                break;
           end;
           hp:=Tai(hp.next);
         end;
        TreePass0:=hp;
      end;


    function TInternalAssembler.TreePass1(hp:Tai):Tai;
      var
        InlineLevel : longint;
        objsym : TObjSymbol;
      begin
        inlinelevel:=0;
        while assigned(hp) do
         begin
           case hp.typ of
             ait_align :
               begin
                 { here we must determine the fillsize which is used in pass2 }
                 Tai_align_abstract(hp).fillsize:=align(ObjData.CurrObjSec.Size,Tai_align_abstract(hp).aligntype)-
                   ObjData.CurrObjSec.Size;
                 ObjData.alloc(Tai_align_abstract(hp).fillsize);
               end;
             ait_datablock :
               begin
                 if (oso_data in ObjData.CurrObjSec.secoptions) then
                   Message(asmw_e_alloc_data_only_in_bss);
                 ObjData.allocalign(used_align(size_2_align(Tai_datablock(hp).size),0,ObjData.CurrObjSec.secalign));
                 objsym:=ObjData.SymbolDefine(Tai_datablock(hp).sym);
                 objsym.size:=Tai_datablock(hp).size;
                 ObjData.alloc(Tai_datablock(hp).size);
               end;
             ait_real_80bit :
               ObjData.alloc(10);
             ait_real_64bit :
               ObjData.alloc(8);
             ait_real_32bit :
               ObjData.alloc(4);
             ait_comp_64bit :
               ObjData.alloc(8);
             ait_const:
               begin
                 ObjData.alloc(tai_const(hp).size);
                 if assigned(Tai_const(hp).sym) then
                   ObjData.SymbolRef(Tai_const(hp).sym);
                 if assigned(Tai_const(hp).endsym) then
                   ObjData.SymbolRef(Tai_const(hp).endsym);
               end;
             ait_section:
               begin
                 { use cached value }
                 ObjData.setsection(Tai_section(hp).sec);
               end;
             ait_stab :
               begin
                 if assigned(Tai_stab(hp).str) then
                   WriteStab(Tai_stab(hp).str);
               end;
             ait_symbol :
               ObjData.SymbolDefine(Tai_symbol(hp).sym);
             ait_symbol_end :
               begin
                 objsym:=ObjData.SymbolRef(Tai_symbol_end(hp).sym);
                 objsym.size:=ObjData.CurrObjSec.Size-objsym.offset;
               end;
             ait_label :
               ObjData.SymbolDefine(Tai_label(hp).labsym);
             ait_string :
               ObjData.alloc(Tai_string(hp).len);
             ait_instruction :
               ObjData.alloc(Taicpu(hp).Pass1(ObjData));
             ait_cutobject :
               if SmartAsm then
                break;
             ait_marker :
               if tai_marker(hp).kind=mark_InlineStart then
                 inc(InlineLevel)
               else if tai_marker(hp).kind=mark_InlineEnd then
                 dec(InlineLevel);
           end;
           hp:=Tai(hp.next);
         end;
        TreePass1:=hp;
      end;


    function TInternalAssembler.TreePass2(hp:Tai):Tai;
      var
        fillbuffer : tfillbuffer;
        InlineLevel,
        v  : int64;
{$ifdef x86}
        co : comp;
{$endif x86}
        objsym,
        objsymend : TObjSymbol;
        leblen : byte;
        lebbuf : array[0..63] of byte;
      begin
        inlinelevel:=0;
        { main loop }
        while assigned(hp) do
         begin
           case hp.typ of
             ait_align :
               begin
                 if (oso_data in ObjData.CurrObjSec.secoptions) then
                   ObjData.writebytes(Tai_align_abstract(hp).calculatefillbuf(fillbuffer)^,Tai_align_abstract(hp).fillsize)
                 else
                   ObjData.alloc(Tai_align_abstract(hp).fillsize);
               end;
             ait_section :
               begin
                 { use cached value }
                 ObjData.setsection(Tai_section(hp).sec);
               end;
             ait_symbol :
               begin
                 ObjOutput.exportsymbol(ObjData.SymbolRef(Tai_symbol(hp).sym));
               end;
             ait_datablock :
               begin
                 ObjData.allocalign(used_align(size_2_align(Tai_datablock(hp).size),0,ObjData.CurrObjSec.secalign));
                 ObjOutput.exportsymbol(ObjData.SymbolRef(Tai_datablock(hp).sym));
                 ObjData.alloc(Tai_datablock(hp).size);
               end;
             ait_real_80bit :
               ObjData.writebytes(Tai_real_80bit(hp).value,10);
             ait_real_64bit :
               ObjData.writebytes(Tai_real_64bit(hp).value,8);
             ait_real_32bit :
               ObjData.writebytes(Tai_real_32bit(hp).value,4);
             ait_comp_64bit :
               begin
{$ifdef x86}
                 co:=comp(Tai_comp_64bit(hp).value);
                 ObjData.writebytes(co,8);
{$endif x86}
               end;
             ait_string :
               ObjData.writebytes(Tai_string(hp).str^,Tai_string(hp).len);
             ait_const :
               begin
                 case tai_const(hp).consttype of
                   aitconst_64bit,
                   aitconst_32bit,
                   aitconst_16bit,
                   aitconst_8bit :
                     begin
                       if assigned(tai_const(hp).sym) then
                         begin
                           objsym:=Objdata.SymbolRef(tai_const(hp).sym);
                           if assigned(tai_const(hp).endsym) then
                             begin
                               objsymend:=Objdata.SymbolRef(tai_const(hp).endsym);
                               if objsymend.objsection<>objsym.objsection then
                                 internalerror(200404124);
                               v:=objsymend.address-objsym.address+Tai_const(hp).value;
                               ObjData.writebytes(v,tai_const(hp).size);
                             end
                           else
                             ObjData.writereloc(Tai_const(hp).value,Tai_const(hp).size,objsym,RELOC_ABSOLUTE);
                         end
                       else
                         ObjData.writebytes(Tai_const(hp).value,tai_const(hp).size);
                     end;
                   aitconst_rva_symbol :
                     { PE32+? }
                     if target_info.system=system_x86_64_win64 then
                       ObjData.writereloc(Tai_const(hp).value,sizeof(longint),Objdata.SymbolRef(tai_const(hp).sym),RELOC_RVA)
                     else
                       ObjData.writereloc(Tai_const(hp).value,sizeof(aint),Objdata.SymbolRef(tai_const(hp).sym),RELOC_RVA);
                   aitconst_uleb128bit :
                     begin
                       leblen:=EncodeUleb128(Tai_const(hp).value,lebbuf);
                       ObjData.writebytes(lebbuf,leblen);
                     end;
                   aitconst_sleb128bit :
                     begin
                       leblen:=EncodeSleb128(Tai_const(hp).value,lebbuf);
                       ObjData.writebytes(lebbuf,leblen);
                     end;
                   else
                     internalerror(200603254);
                 end;
               end;
             ait_label :
               begin
                 { exporting shouldn't be necessary as labels are local,
                   but it's better to be on the safe side (PFV) }
                 ObjOutput.exportsymbol(ObjData.SymbolRef(Tai_label(hp).labsym));
               end;
             ait_instruction :
               Taicpu(hp).Pass2(ObjData);
             ait_stab :
               WriteStab(Tai_stab(hp).str);
             ait_function_name,
             ait_force_line : ;
             ait_cutobject :
               if SmartAsm then
                break;
             ait_marker :
               if tai_marker(hp).kind=mark_InlineStart then
                 inc(InlineLevel)
               else if tai_marker(hp).kind=mark_InlineEnd then
                 dec(InlineLevel);
           end;
           hp:=Tai(hp.next);
         end;
        TreePass2:=hp;
      end;


    procedure TInternalAssembler.writetree;
      label
        doexit;
      var
        hp : Tai;
        ObjWriter : TObjectWriter;
      begin
        ObjWriter:=TObjectwriter.create;
        ObjOutput:=CObjOutput.Create(ObjWriter);
        ObjData:=ObjOutput.newObjData(ObjFileName);

        { Pass 0 }
        ObjData.currpass:=0;
        ObjData.createsection(sec_code);
        ObjData.beforealloc;
        { start with list 1 }
        currlistidx:=1;
        currlist:=list[currlistidx];
        hp:=Tai(currList.first);
        while assigned(hp) do
         begin
           hp:=TreePass0(hp);
           MaybeNextList(hp);
         end;
        ObjData.afteralloc;
        { leave if errors have occured }
        if errorcount>0 then
         goto doexit;

        { Pass 1 }
        ObjData.currpass:=1;
        ObjData.resetsections;
        ObjData.beforealloc;
        ObjData.createsection(sec_code);
        { start with list 1 }
        currlistidx:=1;
        currlist:=list[currlistidx];
        hp:=Tai(currList.first);
        while assigned(hp) do
         begin
           hp:=TreePass1(hp);
           MaybeNextList(hp);
         end;
        ObjData.createsection(sec_code);
        ObjData.afteralloc;

        { leave if errors have occured }
        if errorcount>0 then
         goto doexit;

        { Pass 2 }
        ObjData.currpass:=2;
        ObjData.resetsections;
        ObjData.beforewrite;
        ObjData.createsection(sec_code);
        { start with list 1 }
        currlistidx:=1;
        currlist:=list[currlistidx];
        hp:=Tai(currList.first);
        while assigned(hp) do
         begin
           hp:=TreePass2(hp);
           MaybeNextList(hp);
         end;
        ObjData.createsection(sec_code);
        ObjData.afterwrite;

        { don't write the .o file if errors have occured }
        if errorcount=0 then
         begin
           { write objectfile }
           ObjOutput.startobjectfile(ObjFileName);
           ObjOutput.writeobjectfile(ObjData);
         end;

      doexit:
        { Cleanup }
        ObjData.free;
        ObjData:=nil;
        ObjWriter.free;
      end;


    procedure TInternalAssembler.writetreesmart;
      var
        hp : Tai;
        startsectype : TAsmSectiontype;
        place: tcutplace;
        ObjWriter : TObjectWriter;
      begin
        if not(cs_asm_leave in current_settings.globalswitches) then
          ObjWriter:=TARObjectWriter.create(current_module.staticlibfilename^)
        else
          ObjWriter:=TObjectwriter.create;

        NextSmartName(cut_normal);
        ObjOutput:=CObjOutput.Create(ObjWriter);
        startsectype:=sec_code;

        { start with list 1 }
        currlistidx:=1;
        currlist:=list[currlistidx];
        hp:=Tai(currList.first);
        while assigned(hp) do
         begin
           ObjData:=ObjOutput.newObjData(ObjFileName);

           { Pass 0 }
           ObjData.currpass:=0;
           ObjData.resetsections;
           ObjData.beforealloc;
           ObjData.createsection(startsectype);
           TreePass0(hp);
           ObjData.afteralloc;
           { leave if errors have occured }
           if errorcount>0 then
             break;

           { Pass 1 }
           ObjData.currpass:=1;
           ObjData.resetsections;
           ObjData.beforealloc;
           ObjData.createsection(startsectype);
           TreePass1(hp);
           ObjData.afteralloc;

           { leave if errors have occured }
           if errorcount>0 then
             break;

           { Pass 2 }
           ObjData.currpass:=2;
           ObjOutput.startobjectfile(ObjFileName);
           ObjData.resetsections;
           ObjData.beforewrite;
           ObjData.createsection(startsectype);
           hp:=TreePass2(hp);
           ObjData.afterwrite;

           { leave if errors have occured }
           if errorcount>0 then
             break;

           { write the current objectfile }
           ObjOutput.writeobjectfile(ObjData);
           ObjData.free;
           ObjData:=nil;

           { end of lists? }
           if not MaybeNextList(hp) then
             break;

           { we will start a new objectfile so reset everything }
           { The place can still change in the next while loop, so don't init }
           { the writer yet (JM)                                              }
           if (hp.typ=ait_cutobject) then
             place := Tai_cutobject(hp).place
           else
             place := cut_normal;

           { avoid empty files }
           startsectype:=sec_code;
           while assigned(hp) and
                 (Tai(hp).typ in [ait_marker,ait_comment,ait_section,ait_cutobject]) do
            begin
              if Tai(hp).typ=ait_section then
                startsectype:=Tai_section(hp).sectype;
              if (Tai(hp).typ=ait_cutobject) then
                place:=Tai_cutobject(hp).place;
              hp:=Tai(hp.next);
            end;

           if not MaybeNextList(hp) then
             break;

           { start next objectfile }
           NextSmartName(place);
         end;
        ObjData.free;
        ObjData:=nil;
        ObjWriter.free;
      end;


    procedure TInternalAssembler.MakeObject;

    var to_do:set of TasmlistType;
        i:TasmlistType;
{$ifdef MEMDEBUG}
        d : tmemdebug;
{$endif}

        procedure addlist(p:TAsmList);
        begin
          inc(lists);
          list[lists]:=p;
        end;

      begin
        to_do:=[low(Tasmlisttype)..high(Tasmlisttype)];
        if usedeffileforexports then
          exclude(to_do,al_exports);
        if not(tf_section_threadvars in target_info.flags) then
          exclude(to_do,al_threadvars);
        for i:=low(TasmlistType) to high(TasmlistType) do
          if (i in to_do) and (current_asmdata.asmlists[i]<>nil) then
            addlist(current_asmdata.asmlists[i]);

        if SmartAsm then
          writetreesmart
        else
          writetree;

(*
        if assigned(objectlibrary) then
          begin
            if objectlibrary<>current_module.librarydata then
              internalerror(200603013);
{$ifdef MEMDEBUG}
            d:=tmemdebug.create(modulename^+' - librarydata');
{$endif}
            current_asmdata.free;
            objectlibrary:=nil;
            current_module.librarydata:=nil;
{$ifdef MEMDEBUG}
            d.free;
{$endif}
          end;
*)
      end;


{*****************************************************************************
                     Generate Assembler Files Main Procedure
*****************************************************************************}

    Procedure GenerateAsm(smart:boolean);
      var
        a : TAssembler;
      begin
        if not assigned(CAssembler[target_asm.id]) then
          Message(asmw_f_assembler_output_not_supported);
        a:=CAssembler[target_asm.id].Create(smart);
        a.MakeObject;
        a.Free;
      end;


    Procedure OnlyAsm;
      var
        a : TExternalAssembler;
      begin
        a:=TExternalAssembler.Create(false);
        a.DoAssemble;
        a.Free;
      end;


{*****************************************************************************
                                 Init/Done
*****************************************************************************}

    procedure RegisterAssembler(const r:tasminfo;c:TAssemblerClass);
      var
        t : tasm;
      begin
        t:=r.id;
        if assigned(asminfos[t]) then
          writeln('Warning: Assembler is already registered!')
        else
          Getmem(asminfos[t],sizeof(tasminfo));
        asminfos[t]^:=r;
        CAssembler[t]:=c;
      end;


    procedure InitAssembler;
      begin
      end;


    procedure DoneAssembler;
      begin
      end;

end.
