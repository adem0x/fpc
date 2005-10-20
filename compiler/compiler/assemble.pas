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
{$IFDEF USE_SYSUTILS}
      sysutils,
{$ELSE USE_SYSUTILS}
      strings,
      dos,
{$ENDIF USE_SYSUTILS}
      systems,globtype,globals,aasmbase,aasmtai,ogbase;

    const
       { maximum of aasmoutput lists there will be }
       maxoutputlists = 20;
       { buffer size for writing the .s file }
       AsmOutSize=32768;

    type
      TAssembler=class(TAbstractAssembler)
      public
      {filenames}
        path     : pathstr;
        name     : namestr;
        asmfile,         { current .s and .o file }
        objfile  : string;
        ppufilename : string;
        asmprefix : string;
        SmartAsm : boolean;
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
        procedure WriteTree(p:TAAsmoutput);virtual;

        {# This routine should be overriden for each assembler, it is used
           to actually write all the different abstract assembler streams
           by calling for each stream type, the @var(WriteTree) method.}
        procedure WriteAsmList;virtual;
      public
        Constructor Create(smart:boolean);override;
        procedure MakeObject;override;
      end;

      TInternalAssembler=class(TAssembler)
      public
        constructor create(smart:boolean);override;
        destructor  destroy;override;
        procedure MakeObject;override;
      protected
        objectdata   : TAsmObjectData;
        objectoutput : tobjectoutput;
      private
        { the aasmoutput lists that need to be processed }
        lists        : byte;
        list         : array[1..maxoutputlists] of TAAsmoutput;
        { current processing }
        currlistidx  : byte;
        currlist     : TAAsmoutput;
        currpass     : byte;
        procedure convertstab(p:pchar);
        function  MaybeNextList(var hp:Tai):boolean;
        function  TreePass0(hp:Tai):Tai;
        function  TreePass1(hp:Tai):Tai;
        function  TreePass2(hp:Tai):Tai;
        procedure writetree;
        procedure writetreesmart;
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
  {$ifdef havelinuxrtl10}
      linux,
  {$else}
      unix,
  {$endif}
{$endif}
      cutils,script,fmodule,verbose,
{$ifdef memdebug}
      cclasses,
{$endif memdebug}
{$ifdef m68k}
      cpuinfo,
{$endif m68k}
      aasmcpu
      ;

    var
      CAssembler : array[tasm] of TAssemblerClass;


{*****************************************************************************
                                   TAssembler
*****************************************************************************}

    Constructor TAssembler.Create(smart:boolean);
      begin
      { load start values }
        asmfile:=current_module.get_asmfilename;
        objfile:=current_module.objfilename^;
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
        AsmFile:=Path+FixFileName(s+tostr(SmartFilesCount)+target_info.asmext);
        ObjFile:=Path+FixFileName(s+tostr(SmartFilesCount)+target_info.objext);
        { insert in container so it can be cleared after the linking }
        SmartLinkOFiles.Insert(Objfile);
      end;


{*****************************************************************************
                                 TExternalAssembler
*****************************************************************************}

    Function DoPipe:boolean;
      begin
        DoPipe:=(cs_asm_pipe in aktglobalswitches) and
                not(cs_asm_leave in aktglobalswitches)
                and ((target_asm.id in [as_gas,as_darwin]));
      end;


    Constructor TExternalAssembler.Create(smart:boolean);
      begin
        inherited Create(smart);
        if SmartAsm then
         begin
           path:=FixPath(path+FixFileName(name)+target_info.smartext,false);
           CreateSmartLinkPath(path);
         end;
        Outcnt:=0;
      end;


    procedure TExternalAssembler.CreateSmartLinkPath(const s:string);
      var
{$IFDEF USE_SYSUTILS}
        dir : TSearchRec;
{$ELSE USE_SYSUTILS}
        dir : searchrec;
{$ENDIF USE_SYSUTILS}
        hs  : string;
      begin
        if PathExists(s) then
         begin
           { the path exists, now we clean only all the .o and .s files }
           { .o files }
{$IFDEF USE_SYSUTILS}
           if findfirst(s+source_info.dirsep+'*'+target_info.objext,faAnyFile,dir) = 0
           then repeat
              RemoveFile(s+source_info.dirsep+dir.name);
           until findnext(dir) <> 0;
{$ELSE USE_SYSUTILS}
           findfirst(s+source_info.dirsep+'*'+target_info.objext,anyfile,dir);
           while (doserror=0) do
            begin
              RemoveFile(s+source_info.dirsep+dir.name);
              findnext(dir);
            end;
{$ENDIF USE_SYSUTILS}
           findclose(dir);
           { .s files }
{$IFDEF USE_SYSUTILS}
           if findfirst(s+source_info.dirsep+'*'+target_info.asmext,faAnyFile,dir) = 0
           then repeat
             RemoveFile(s+source_info.dirsep+dir.name);
           until findnext(dir) <> 0;
{$ELSE USE_SYSUTILS}
           findfirst(s+source_info.dirsep+'*'+target_info.asmext,anyfile,dir);
           while (doserror=0) do
            begin
              RemoveFile(s+source_info.dirsep+dir.name);
              findnext(dir);
            end;
{$ENDIF USE_SYSUTILS}
           findclose(dir);
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
      LastASBin : pathstr;
    Function TExternalAssembler.FindAssembler:string;
      var
        asfound : boolean;
        UtilExe  : string;
      begin
        asfound:=false;
        if cs_link_on_target in aktglobalswitches then
         begin
           { If linking on target, don't add any path PM }
           FindAssembler:=utilsprefix+AddExtension(target_asm.asmbin,target_info.exeext);
           exit;
         end
        else
         UtilExe:=utilsprefix+AddExtension(target_asm.asmbin,source_info.exeext);
        if lastas<>ord(target_asm.id) then
         begin
           lastas:=ord(target_asm.id);
           { is an assembler passed ? }
           if utilsdirectory<>'' then
             asfound:=FindFile(UtilExe,utilsdirectory,LastASBin);
           if not AsFound then
             asfound:=FindExe(UtilExe,LastASBin);
           if (not asfound) and not(cs_asm_extern in aktglobalswitches) then
            begin
              Message1(exec_e_assembler_not_found,LastASBin);
              aktglobalswitches:=aktglobalswitches+[cs_asm_extern];
            end;
           if asfound then
            Message1(exec_t_using_assembler,LastASBin);
         end;
        FindAssembler:=LastASBin;
      end;


    Function TExternalAssembler.CallAssembler(const command:string; const para:TCmdStr):Boolean;
{$IFDEF USE_SYSUTILS}
      var
        DosExitCode:Integer;
{$ENDIF USE_SYSUTILS}
      begin
        callassembler:=true;
        if not(cs_asm_extern in aktglobalswitches) then
{$IFDEF USE_SYSUTILS}
        try
          DosExitCode := ExecuteProcess(command,para);
          if DosExitCode <>0
          then begin
            Message1(exec_e_error_while_assembling,tostr(dosexitcode));
            callassembler:=false;
          end;
        except on E:EOSError do
          begin
            Message1(exec_e_cant_call_assembler,tostr(E.ErrorCode));
            aktglobalswitches:=aktglobalswitches+[cs_asm_extern];
            callassembler:=false;
          end
        end
{$ELSE USE_SYSUTILS}
         begin
           swapvectors;
           exec(maybequoted(command),para);
           swapvectors;
           if (doserror<>0) then
            begin
              Message1(exec_e_cant_call_assembler,tostr(doserror));
              aktglobalswitches:=aktglobalswitches+[cs_asm_extern];
              callassembler:=false;
            end
           else
            if (dosexitcode<>0) then
             begin
              Message1(exec_e_error_while_assembling,tostr(dosexitcode));
              callassembler:=false;
             end;
         end
{$ENDIF USE_SYSUTILS}
        else
         AsmRes.AddAsmCommand(command,para,name);
      end;


    procedure TExternalAssembler.RemoveAsm;
      var
        g : file;
      begin
        if cs_asm_leave in aktglobalswitches then
         exit;
        if cs_asm_extern in aktglobalswitches then
         AsmRes.AddDeleteCommand(AsmFile)
        else
         begin
           assign(g,AsmFile);
           {$I-}
            erase(g);
           {$I+}
           if ioresult<>0 then;
         end;
      end;


    Function TExternalAssembler.DoAssemble:boolean;
      var
        s : TCmdStr;
      begin
        DoAssemble:=true;
        if DoPipe then
         exit;
        if not(cs_asm_extern in aktglobalswitches) then
         begin
           if SmartAsm then
            begin
              if (SmartFilesCount<=1) then
               Message1(exec_i_assembling_smart,name);
            end
           else
           Message1(exec_i_assembling,name);
         end;
        s:=target_asm.asmcmd;
{$ifdef m68k}
        if aktoptprocessor = MC68020 then
          s:='-m68020 '+s
        else
          s:='-m68000 '+s;
{$endif}
        if (cs_link_on_target in aktglobalswitches) then
         begin
           Replace(s,'$ASM',maybequoted(ScriptFixFileName(AsmFile)));
           Replace(s,'$OBJ',maybequoted(ScriptFixFileName(ObjFile)));
         end
        else
         begin
           Replace(s,'$ASM',maybequoted(AsmFile));
           Replace(s,'$OBJ',maybequoted(ObjFile));
         end;
        if CallAssembler(FindAssembler,s) then
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
        if (cs_link_on_target in aktglobalswitches) then
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


    procedure TExternalAssembler.AsmCreate(Aplace:tcutplace);
      begin
        if SmartAsm then
         NextSmartName(Aplace);
{$ifdef hasunix}
        if DoPipe then
         begin
           Message1(exec_i_assembling_pipe,asmfile);
           POpen(outfile,'as -o '+objfile,'W');
         end
        else
{$endif}
         begin
           Assign(outfile,asmfile);
           {$I-}
           Rewrite(outfile,1);
           {$I+}
           if ioresult<>0 then
             begin
               ioerror:=true;
               Message1(exec_d_cant_create_asmfile,asmfile);
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
{$IFDEF USE_SYSUTILS}
                 FileAge := FileGetDate(GetFileHandle(f));
{$ELSE USE_SYSUTILS}
                 GetFTime(f, FileAge);
{$ENDIF USE_SYSUTILS}
                 close(f);
                 reset(outfile,1);
{$IFDEF USE_SYSUTILS}
                 FileSetDate(GetFileHandle(outFile),FileAge);
{$ELSE USE_SYSUTILS}
                 SetFTime(f, FileAge);
{$ENDIF USE_SYSUTILS}
               end;
            end;
           close(outfile);
         end;
      end;


    procedure TExternalAssembler.WriteTree(p:TAAsmoutput);
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
        objectoutput:=nil;
        objectdata:=nil;
        SmartAsm:=smart;
        currpass:=0;
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
        objectdata.free;
        objectoutput.free;
{$ifdef MEMDEBUG}
        d.free;
{$endif}
      end;


    procedure TInternalAssembler.convertstab(p:pchar);

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

        function consumeoffset(var p:pchar;out relocsym:tasmsymbol;out value:longint):boolean;
        var
          hs        : string;
          len,
          code      : integer;
          pstart    : pchar;
          sym       : tasmsymbol;
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
                  sym:=objectlibrary.newasmsymbol(hs,AB_EXTERNAL,AT_NONE);
                  if not assigned(sym) then
                    internalerror(200509188);
                  objectlibrary.UsedAsmSymbolListInsert(sym);
                  { Second symbol? }
                  if assigned(relocsym) then
                    begin
                      if (relocsym.section<>sym.section) then
                        internalerror(2005091810);
                      relocsym:=nil;
                    end
                  else
                    begin
                      relocsym:=sym;
                    end;
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
        ofs,
        nline,
        nidx,
        nother,
        i         : longint;
        relocsym  : tasmsymbol;
        pstr,
        pcurr,
        pendquote : pchar;
      begin
        pcurr:=nil;
        pstr:=nil;
        pendquote:=nil;

        { Parse string part }
        if p[0]='"' then
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
        if currpass=1 then
          objectdata.allocstab(pstr)
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
            if (nidx=N_Function) and
               target_info.use_function_relative_addresses then
              ofs:=0;
            objectdata.writestab(ofs,relocsym,nidx,nother,nline,pstr);
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
      var
        l : longint;
      begin
        while assigned(hp) do
         begin
           case hp.typ of
             ait_align :
               begin
                 { always use the maximum fillsize in this pass to avoid possible
                   short jumps to become out of range }
                 Tai_align(hp).fillsize:=Tai_align(hp).aligntype;
                 objectdata.alloc(Tai_align(hp).fillsize);
               end;
             ait_datablock :
               begin
                 l:=used_align(size_2_align(Tai_datablock(hp).size),0,objectdata.currsec.addralign);
                 if SmartAsm or (not Tai_datablock(hp).is_global) then
                   begin
                     objectdata.allocalign(l);
                     objectdata.alloc(Tai_datablock(hp).size);
                   end;
               end;
             ait_real_80bit :
               objectdata.alloc(10);
             ait_real_64bit :
               objectdata.alloc(8);
             ait_real_32bit :
               objectdata.alloc(4);
             ait_comp_64bit :
               objectdata.alloc(8);
             ait_const_64bit,
             ait_const_32bit,
             ait_const_16bit,
             ait_const_8bit,
             ait_const_rva_symbol,
             ait_const_indirect_symbol :
               objectdata.alloc(tai_const(hp).size);
             ait_section:
               begin
                 objectdata.CreateSection(Tai_section(hp).sectype,Tai_section(hp).name^,Tai_section(hp).secalign,[]);
                 Tai_section(hp).sec:=objectdata.CurrSec;
               end;
             ait_symbol :
               objectdata.allocsymbol(currpass,Tai_symbol(hp).sym,0);
             ait_label :
               objectdata.allocsymbol(currpass,Tai_label(hp).l,0);
             ait_string :
               objectdata.alloc(Tai_string(hp).len);
             ait_instruction :
               begin
{$ifdef i386}
{$ifndef NOAG386BIN}
                 { reset instructions which could change in pass 2 }
                 Taicpu(hp).resetpass2;
                 objectdata.alloc(Taicpu(hp).Pass1(objectdata.currsec.datasize));
{$endif NOAG386BIN}
{$endif i386}
{$ifdef arm}
                 { reset instructions which could change in pass 2 }
                 Taicpu(hp).resetpass2;
                 objectdata.alloc(Taicpu(hp).Pass1(objectdata.currsec.datasize));
{$endif arm}
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
        InlineLevel,
        l,
        i : longint;
      begin
        inlinelevel:=0;
        while assigned(hp) do
         begin
           case hp.typ of
             ait_align :
               begin
                 { here we must determine the fillsize which is used in pass2 }
                 Tai_align(hp).fillsize:=align(objectdata.currsec.datasize,Tai_align(hp).aligntype)-
                   objectdata.currsec.datasize;
                 objectdata.alloc(Tai_align(hp).fillsize);
               end;
             ait_datablock :
               begin
                 if not (objectdata.currsec.sectype in [sec_bss,sec_threadvar]) then
                   Message(asmw_e_alloc_data_only_in_bss);
                 l:=used_align(size_2_align(Tai_datablock(hp).size),0,objectdata.currsec.addralign);
{                 if Tai_datablock(hp).is_global and
                    not SmartAsm then
                  begin}
{                    objectdata.allocsymbol(currpass,Tai_datablock(hp).sym,Tai_datablock(hp).size);}
                    { force to be common/external, must be after setaddress as that would
                      set it to AB_GLOBAL }
{                    Tai_datablock(hp).sym.currbind:=AB_COMMON;
                  end
                 else
                  begin}
                    objectdata.allocalign(l);
                    objectdata.allocsymbol(currpass,Tai_datablock(hp).sym,Tai_datablock(hp).size);
                    objectdata.alloc(Tai_datablock(hp).size);
{                  end;}
                 objectlibrary.UsedAsmSymbolListInsert(Tai_datablock(hp).sym);
               end;
             ait_real_80bit :
               objectdata.alloc(10);
             ait_real_64bit :
               objectdata.alloc(8);
             ait_real_32bit :
               objectdata.alloc(4);
             ait_comp_64bit :
               objectdata.alloc(8);
             ait_const_64bit,
             ait_const_32bit,
             ait_const_16bit,
             ait_const_8bit,
             ait_const_rva_symbol,
             ait_const_indirect_symbol :
               begin
                 objectdata.alloc(tai_const(hp).size);
                 if assigned(Tai_const(hp).sym) then
                   objectlibrary.UsedAsmSymbolListInsert(Tai_const(hp).sym);
                 if assigned(Tai_const(hp).endsym) then
                   objectlibrary.UsedAsmSymbolListInsert(Tai_const(hp).endsym);
               end;
             ait_section:
               begin
                 { use cached value }
                 objectdata.setsection(Tai_section(hp).sec);
               end;
             ait_stab :
               begin
                 if assigned(Tai_stab(hp).str) then
                   convertstab(Tai_stab(hp).str);
               end;
             ait_function_name,
             ait_force_line : ;
             ait_symbol :
               begin
                 objectdata.allocsymbol(currpass,Tai_symbol(hp).sym,0);
                 objectlibrary.UsedAsmSymbolListInsert(Tai_symbol(hp).sym);
               end;
             ait_symbol_end :
               begin
                 if target_info.system in [system_i386_linux,system_i386_beos] then
                  begin
                    Tai_symbol_end(hp).sym.size:=objectdata.currsec.datasize-Tai_symbol_end(hp).sym.address;
                    objectlibrary.UsedAsmSymbolListInsert(Tai_symbol_end(hp).sym);
                  end;
                end;
             ait_label :
               begin
                 objectdata.allocsymbol(currpass,Tai_label(hp).l,0);
                 objectlibrary.UsedAsmSymbolListInsert(Tai_label(hp).l);
               end;
             ait_string :
               objectdata.alloc(Tai_string(hp).len);
             ait_instruction :
               begin
                 objectdata.alloc(Taicpu(hp).Pass1(objectdata.currsec.datasize));
                 { fixup the references }
                 for i:=1 to Taicpu(hp).ops do
                  begin
                    with Taicpu(hp).oper[i-1]^ do
                     begin
                       case typ of
                         top_ref :
                           begin
                             if assigned(ref^.symbol) then
                              objectlibrary.UsedAsmSymbolListInsert(ref^.symbol);
                             if assigned(ref^.relsymbol) then
                              objectlibrary.UsedAsmSymbolListInsert(ref^.symbol);
                           end;
                       end;
                     end;
                  end;
               end;
             ait_cutobject :
               if SmartAsm then
                break;
             ait_marker :
               if tai_marker(hp).kind=InlineStart then
                 inc(InlineLevel)
               else if tai_marker(hp).kind=InlineEnd then
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
        l  : longint;
        v  : int64;
{$ifdef x86}
        co : comp;
{$endif x86}
      begin
        inlinelevel:=0;
        { main loop }
        while assigned(hp) do
         begin
           case hp.typ of
             ait_align :
               begin
                 if objectdata.currsec.sectype in [sec_bss,sec_threadvar] then
                   objectdata.alloc(Tai_align(hp).fillsize)
                 else
                   objectdata.writebytes(Tai_align(hp).calculatefillbuf(fillbuffer)^,Tai_align(hp).fillsize);
               end;
             ait_section :
               begin
                 { use cached value }
                 objectdata.setsection(Tai_section(hp).sec);
               end;
             ait_symbol :
               begin
                 objectdata.writesymbol(Tai_symbol(hp).sym);
                 objectoutput.exportsymbol(Tai_symbol(hp).sym);
               end;
             ait_datablock :
               begin
                 l:=used_align(size_2_align(Tai_datablock(hp).size),0,objectdata.currsec.addralign);
                 objectdata.writesymbol(Tai_datablock(hp).sym);
                 objectoutput.exportsymbol(Tai_datablock(hp).sym);
{                 if SmartAsm or (not Tai_datablock(hp).is_global) then
                   begin}
                     objectdata.allocalign(l);
                     objectdata.alloc(Tai_datablock(hp).size);
{                   end;}
               end;
             ait_real_80bit :
               objectdata.writebytes(Tai_real_80bit(hp).value,10);
             ait_real_64bit :
               objectdata.writebytes(Tai_real_64bit(hp).value,8);
             ait_real_32bit :
               objectdata.writebytes(Tai_real_32bit(hp).value,4);
             ait_comp_64bit :
               begin
{$ifdef x86}
                 co:=comp(Tai_comp_64bit(hp).value);
                 objectdata.writebytes(co,8);
{$endif x86}
               end;
             ait_string :
               objectdata.writebytes(Tai_string(hp).str^,Tai_string(hp).len);
             ait_const_64bit,
             ait_const_32bit,
             ait_const_16bit,
             ait_const_8bit :
               begin
                 if assigned(tai_const(hp).sym) then
                   begin
                     if assigned(tai_const(hp).endsym) then
                       begin
                         if tai_const(hp).endsym.section<>tai_const(hp).sym.section then
                           internalerror(200404124);
                         v:=tai_const(hp).endsym.address-tai_const(hp).sym.address+Tai_const(hp).value;
                         objectdata.writebytes(v,tai_const(hp).size);
                       end
                     else
                       objectdata.writereloc(Tai_const(hp).value,Tai_const(hp).size,
                                             Tai_const(hp).sym,RELOC_ABSOLUTE);
                   end
                 else
                   objectdata.writebytes(Tai_const(hp).value,tai_const(hp).size);
               end;
             ait_const_rva_symbol :
               objectdata.writereloc(Tai_const(hp).value,sizeof(aint),Tai_const(hp).sym,RELOC_RVA);
             ait_label :
               begin
                 objectdata.writesymbol(Tai_label(hp).l);
                 { exporting shouldn't be necessary as labels are local,
                   but it's better to be on the safe side (PFV) }
                 objectoutput.exportsymbol(Tai_label(hp).l);
               end;
             ait_instruction :
               Taicpu(hp).Pass2(objectdata);
             ait_stab :
               convertstab(Tai_stab(hp).str);
             ait_function_name,
             ait_force_line : ;
             ait_cutobject :
               if SmartAsm then
                break;
             ait_marker :
               if tai_marker(hp).kind=InlineStart then
                 inc(InlineLevel)
               else if tai_marker(hp).kind=InlineEnd then
                 dec(InlineLevel);
           end;
           hp:=Tai(hp.next);
         end;
        TreePass2:=hp;
      end;


    procedure TInternalAssembler.writetree;
      var
        hp : Tai;
      label
        doexit;
      begin
        objectdata:=objectoutput.newobjectdata(Objfile);
        { reset the asmsymbol list }
        objectlibrary.CreateUsedAsmsymbolList;

      { Pass 0 }
        currpass:=0;
        objectdata.createsection(sec_code,'',0,[]);
        objectdata.beforealloc;
        { start with list 1 }
        currlistidx:=1;
        currlist:=list[currlistidx];
        hp:=Tai(currList.first);
        while assigned(hp) do
         begin
           hp:=TreePass0(hp);
           MaybeNextList(hp);
         end;
        objectdata.afteralloc;
        { leave if errors have occured }
        if errorcount>0 then
         goto doexit;

      { Pass 1 }
        currpass:=1;
        objectdata.resetsections;
        objectdata.beforealloc;
        objectdata.createsection(sec_code,'',0,[]);
        { start with list 1 }
        currlistidx:=1;
        currlist:=list[currlistidx];
        hp:=Tai(currList.first);
        while assigned(hp) do
         begin
           hp:=TreePass1(hp);
           MaybeNextList(hp);
         end;
        objectdata.createsection(sec_code,'',0,[]);
        objectdata.afteralloc;
        { check for undefined labels and reset }
        objectlibrary.UsedAsmSymbolListCheckUndefined;

        { leave if errors have occured }
        if errorcount>0 then
         goto doexit;

      { Pass 2 }
        currpass:=2;
        objectdata.resetsections;
        objectdata.beforewrite;
        objectdata.createsection(sec_code,'',0,[]);
        { start with list 1 }
        currlistidx:=1;
        currlist:=list[currlistidx];
        hp:=Tai(currList.first);
        while assigned(hp) do
         begin
           hp:=TreePass2(hp);
           MaybeNextList(hp);
         end;
        objectdata.createsection(sec_code,'',0,[]);
        objectdata.afterwrite;

        { don't write the .o file if errors have occured }
        if errorcount=0 then
         begin
           { write objectfile }
           objectoutput.startobjectfile(ObjFile);
           objectoutput.writeobjectfile(objectdata);
           objectdata.free;
           objectdata:=nil;
         end;

      doexit:
        { reset the used symbols back, must be after the .o has been
          written }
        objectlibrary.UsedAsmsymbolListReset;
        objectlibrary.DestroyUsedAsmsymbolList;
      end;


    procedure TInternalAssembler.writetreesmart;
      var
        hp : Tai;
        startsectype : TAsmSectionType;
        place: tcutplace;
      begin
        NextSmartName(cut_normal);
        objectdata:=objectoutput.newobjectdata(Objfile);
        startsectype:=sec_code;

        { start with list 1 }
        currlistidx:=1;
        currlist:=list[currlistidx];
        hp:=Tai(currList.first);
        while assigned(hp) do
         begin
         { reset the asmsymbol list }
           objectlibrary.CreateUsedAsmSymbolList;

         { Pass 0 }
           currpass:=0;
           objectdata.resetsections;
           objectdata.beforealloc;
           objectdata.createsection(startsectype,'',0,[]);
           TreePass0(hp);
           objectdata.afteralloc;
           { leave if errors have occured }
           if errorcount>0 then
            exit;

         { Pass 1 }
           currpass:=1;
           objectdata.resetsections;
           objectdata.beforealloc;
           objectdata.createsection(startsectype,'',0,[]);
           TreePass1(hp);
           objectdata.afteralloc;
           { check for undefined labels }
           objectlibrary.UsedAsmSymbolListCheckUndefined;

           { leave if errors have occured }
           if errorcount>0 then
            exit;

         { Pass 2 }
           currpass:=2;
           objectoutput.startobjectfile(Objfile);
           objectdata.resetsections;
           objectdata.beforewrite;
           objectdata.createsection(startsectype,'',0,[]);
           hp:=TreePass2(hp);
           { save section type for next loop, must be done before EndFileLineInfo
             because that changes the section to sec_code }
           startsectype:=objectdata.currsec.sectype;
           objectdata.afterwrite;
           { leave if errors have occured }
           if errorcount>0 then
            exit;

           { write the current objectfile }
           objectoutput.writeobjectfile(objectdata);
           objectdata.free;
           objectdata:=nil;

           { reset the used symbols back, must be after the .o has been
             written }
           objectlibrary.UsedAsmsymbolListReset;
           objectlibrary.DestroyUsedAsmsymbolList;

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
           while assigned(hp) and
                 (Tai(hp).typ in [ait_marker,ait_comment,ait_section,ait_cutobject]) do
            begin
              if Tai(hp).typ=ait_section then
               startsectype:=Tai_section(hp).sectype
              else if (Tai(hp).typ=ait_cutobject) then
               place:=Tai_cutobject(hp).place;
              hp:=Tai(hp.next);
            end;
           { there is a problem if startsectype is sec_none !! PM }
           if startsectype=sec_none then
             startsectype:=sec_code;

           if not MaybeNextList(hp) then
             break;

           { start next objectfile }
           NextSmartName(place);
           objectdata:=objectoutput.newobjectdata(Objfile);
         end;
      end;


    procedure TInternalAssembler.MakeObject;

    var to_do:set of Tasmlist;
        i:Tasmlist;

        procedure addlist(p:TAAsmoutput);
        begin
          inc(lists);
          list[lists]:=p;
        end;

      begin
        to_do:=[low(Tasmlist)..high(Tasmlist)];
        if usedeffileforexports then
          exclude(to_do,al_exports);
        {$warning TODO internal writer support for dwarf}
        exclude(to_do,al_dwarf);
{$ifndef segment_threadvars}
        exclude(to_do,al_threadvars);
{$endif}
        for i:=low(Tasmlist) to high(Tasmlist) do
          if (i in to_do) and (asmlist[i]<>nil) then
            addlist(asmlist[i]);

        if SmartAsm then
          writetreesmart
        else
          writetree;
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
