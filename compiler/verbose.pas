{
    Copyright (c) 1998-2002 by Peter Vreman

    This unit handles the verbose management

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
unit verbose;

{$i fpcdefs.inc}

interface

    uses
{$IFNDEF MACOS_USE_FAKE_SYSUTILS}
      sysutils,
{$ENDIF}
      cutils,
      globals,finput,
      cmsgs;

{$ifndef EXTERN_MSG}
  {$i msgtxt.inc}
{$endif}

{$i msgidx.inc}

    Const
      { Levels }
      V_None         = $0;
      V_Fatal        = $1;
      V_Error        = $2;
      V_Normal       = $4; { doesn't show a text like Error: }
      V_Warning      = $8;
      V_Note         = $10;
      V_Hint         = $20;
      V_LineInfoMask = $fff;
      { From here by default no line info }
      V_Info         = $1000;
      V_Status       = $2000;
      V_Used         = $4000;
      V_Tried        = $8000;
      V_Conditional  = $10000;
      V_Debug        = $20000;
      V_Executable   = $40000;
      V_LevelMask    = $fffffff;
      V_All          = V_LevelMask;
      V_Default      = V_Fatal + V_Error + V_Normal;
      { Flags }
      V_LineInfo     = $10000000;

    var
      msg : pmessage;

    const
      msgfilename : string = '';

    procedure SetRedirectFile(const fn:string);
    function  SetVerbosity(const s:string):boolean;
    procedure PrepareReport;

    function  CheckVerbosity(v:longint):boolean;
    procedure SetCompileModule(p:tmodulebase);
    procedure ShowStatus;
    function  ErrorCount:longint;
    procedure SetErrorFlags(const s:string);
    procedure GenerateError;
    procedure Internalerror(i:longint);
    procedure Comment(l:longint;s:string);
    function  MessagePchar(w:longint):pchar;
    procedure Message(w:longint);
    procedure Message1(w:longint;const s1:string);
    procedure Message2(w:longint;const s1,s2:string);
    procedure Message3(w:longint;const s1,s2,s3:string);
    procedure Message4(w:longint;const s1,s2,s3,s4:string);
    procedure MessagePos(const pos:tfileposinfo;w:longint);
    procedure MessagePos1(const pos:tfileposinfo;w:longint;const s1:string);
    procedure MessagePos2(const pos:tfileposinfo;w:longint;const s1,s2:string);
    procedure MessagePos3(const pos:tfileposinfo;w:longint;const s1,s2,s3:string);
    procedure MessagePos4(const pos:tfileposinfo;w:longint;const s1,s2,s3,s4:string);

    { message calls with codegenerror support }
    procedure cgmessage(t : longint);
    procedure cgmessage1(t : longint;const s : string);
    procedure cgmessage2(t : longint;const s1,s2 : string);
    procedure cgmessage3(t : longint;const s1,s2,s3 : string);
    procedure CGMessagePos(const pos:tfileposinfo;t:longint);
    procedure CGMessagePos1(const pos:tfileposinfo;t:longint;const s1:string);
    procedure CGMessagePos2(const pos:tfileposinfo;t:longint;const s1,s2:string);
    procedure CGMessagePos3(const pos:tfileposinfo;t:longint;const s1,s2,s3:string);

    procedure InitVerbose;
    procedure DoneVerbose;



implementation

    uses
      comphook;

var
  compiling_module : tmodulebase;


{****************************************************************************
                       Extra Handlers for default compiler
****************************************************************************}

    procedure DoneRedirectFile;
      begin
        if status.use_redir then
         begin
           close(status.redirfile);
           status.use_redir:=false;
         end;
        if status.use_bugreport then
         begin
           close(status.reportbugfile);
           status.use_bugreport:=false;
         end;
      end;


    procedure SetRedirectFile(const fn:string);
      begin
        assign(status.redirfile,fn);
        {$I-}
         append(status.redirfile);
         if ioresult <> 0 then
          rewrite(status.redirfile);
        {$I+}
        status.use_redir:=(ioresult=0);
      end;


    procedure PrepareReport;
      var
        fn : string;
      begin
        if status.use_bugreport then
         exit;
        fn:='fpcdebug.txt';
        assign(status.reportbugfile,fn);
        {$I-}
         append(status.reportbugfile);
         if ioresult <> 0 then
          rewrite(status.reportbugfile);
        {$I+}
        status.use_bugreport:=(ioresult=0);
        if status.use_bugreport then
         writeln(status.reportbugfile,'FPC bug report file');
      end;


    function CheckVerbosity(v:longint):boolean;
      begin
        CheckVerbosity:=status.use_bugreport or
                        ((status.verbosity and (v and V_LevelMask))=(v and V_LevelMask));
      end;


    function SetVerbosity(const s:string):boolean;
      var
        m : Longint;
        i : Integer;
        inverse : boolean;
        c : char;
      begin
        Setverbosity:=false;
        val(s,m,i);
        if (i=0) and (s<>'') then
         status.verbosity:=m
        else
         begin
           i:=1;
           while i<=length(s) do
             begin
                c:=upcase(s[i]);
                inverse:=false;
                { on/off ? }
                if (i<length(s)) then
                 case s[i+1] of
                  '-' : begin
                          inc(i);
                          inverse:=true;
                        end;
                  '+' : inc(i);
                 end;
                { handle switch }
                case c of
                { Special cases }
                 'A' : status.verbosity:=V_All;
                 'B' : begin
                          if inverse then
                            status.print_source_path:=false
                          else
                            status.print_source_path:=true;
                       end;
                 '0' : status.verbosity:=V_Default;
                 'P' : begin
                         if inverse then
                          paraprintnodetree:=0
                         else
                          paraprintnodetree:=1;
                       end;
                 'R' : begin
                          if inverse then
                            begin
                               status.use_gccoutput:=false;
                               status.use_stderr:=false;
                            end
                          else
                            begin
                               status.use_gccoutput:=true;
                               status.use_stderr:=true;
                            end;
                       end;
                 'Z' : begin
                          if inverse then
                            status.use_stderr:=false
                          else
                            status.use_stderr:=true;
                       end;
                { Normal cases - do an or }
                 'E' : if inverse then
                         status.verbosity:=status.verbosity and (not V_Error)
                       else
                         status.verbosity:=status.verbosity or V_Error;
                 'I' : if inverse then
                         status.verbosity:=status.verbosity and (not V_Info)
                       else
                         status.verbosity:=status.verbosity or V_Info;
                 'W' : if inverse then
                         status.verbosity:=status.verbosity and (not V_Warning)
                       else
                         status.verbosity:=status.verbosity or V_Warning;
                 'N' : if inverse then
                         status.verbosity:=status.verbosity and (not V_Note)
                       else
                         status.verbosity:=status.verbosity or V_Note;
                 'H' : if inverse then
                         status.verbosity:=status.verbosity and (not V_Hint)
                       else
                         status.verbosity:=status.verbosity or V_Hint;
                 'L' : if inverse then
                         status.verbosity:=status.verbosity and (not V_Status)
                       else
                         status.verbosity:=status.verbosity or V_Status;
                 'U' : if inverse then
                         status.verbosity:=status.verbosity and (not V_Used)
                       else
                         status.verbosity:=status.verbosity or V_Used;
                 'T' : if inverse then
                         status.verbosity:=status.verbosity and (not V_Tried)
                       else
                         status.verbosity:=status.verbosity or V_Tried;
                 'C' : if inverse then
                         status.verbosity:=status.verbosity and (not V_Conditional)
                       else
                         status.verbosity:=status.verbosity or V_Conditional;
                 'D' : if inverse then
                         status.verbosity:=status.verbosity and (not V_Debug)
                       else
                         status.verbosity:=status.verbosity or V_Debug;
                 'X' : if inverse then
                         status.verbosity:=status.verbosity and (not V_Executable)
                       else
                         status.verbosity:=status.verbosity or V_Executable;
                 'V' : PrepareReport;
                 end;
                inc(i);
             end;
           end;
        if status.verbosity=0 then
         status.verbosity:=V_Default;
        setverbosity:=true;
      end;


    procedure Loadprefixes;

        function loadprefix(w:longint):string;
        var
          s : string;
          idx : longint;
        begin
          s:=msg^.get(w,[]);
          idx:=pos('_',s);
          if idx>0 then
           Loadprefix:=Copy(s,idx+1,255)
          else
           Loadprefix:=s;
        end;

      begin
      { Load the prefixes }
        fatalstr:=Loadprefix(general_i_fatal);
        errorstr:=Loadprefix(general_i_error);
        warningstr:=Loadprefix(general_i_warning);
        notestr:=Loadprefix(general_i_note);
        hintstr:=Loadprefix(general_i_hint);
      end;


    procedure LoadMsgFile(const fn:string);
      begin
        { reload the internal messages if not already loaded }
{$ifndef EXTERN_MSG}
        if not msg^.msgintern then
         msg^.LoadIntern(@msgtxt,msgtxtsize);
{$endif}
        if not msg^.LoadExtern(fn) then
         begin
{$ifdef EXTERN_MSG}
           writeln('Fatal: Cannot find error message file.');
           halt(3);
{$else}
           msg^.LoadIntern(@msgtxt,msgtxtsize);
{$endif}
         end;
        { reload the prefixes using the new messages }
        Loadprefixes;
      end;


    procedure MaybeLoadMessageFile;
      begin
        { Load new message file }
        if (msgfilename<>'')  then
         begin
           LoadMsgFile(msgfilename);
           msgfilename:='';
         end;
      end;


    procedure SetCompileModule(p:tmodulebase);
      begin
        compiling_module:=p;
      end;


      var
        lastfileidx,
        lastmoduleidx : longint;
    Procedure UpdateStatus;
      begin
      { fix status }
        status.currentline:=aktfilepos.line;
        status.currentcolumn:=aktfilepos.column;
        if assigned(compiling_module) and
           assigned(compiling_module.sourcefiles) and
           ((compiling_module.unit_index<>lastmoduleidx) or
            (aktfilepos.fileindex<>lastfileidx)) then
         begin
           { update status record }
           status.currentmodule:=compiling_module.modulename^;
           status.currentsource:=compiling_module.sourcefiles.get_file_name(aktfilepos.fileindex);
           status.currentsourcepath:=compiling_module.sourcefiles.get_file_path(aktfilepos.fileindex);
           { update lastfileidx only if name known PM }
           if status.currentsource<>'' then
             lastfileidx:=aktfilepos.fileindex
           else
             lastfileidx:=0;
           lastmoduleidx:=compiling_module.unit_index;
         end;
        if assigned(compiling_module) then
          status.compiling_current:=(compiling_module.state in [ms_compile,ms_second_compile]);
      end;


    procedure ShowStatus;
      begin
        UpdateStatus;
        if do_status() then
          raise ECompilerAbort.Create;
      end;


    function ErrorCount:longint;
      begin
        ErrorCount:=status.errorcount;
      end;


    procedure SetErrorFlags(const s:string);
      var
        code : integer;
        i,j,l : longint;
      begin
      { empty string means error count = 1 for backward compatibility (PFV) }
        if s='' then
         begin
           status.maxerrorcount:=1;
           exit;
         end;
        i:=0;
        while (i<length(s)) do
         begin
           inc(i);
           case s[i] of
             '0'..'9' :
                begin
                  j:=i;
                  while (j<=length(s)) and (s[j] in ['0'..'9']) do
                   inc(j);
                  val(copy(s,i,j-i),l,code);
                  if code<>0 then
                   l:=1;
                  status.maxerrorcount:=l;
                  i:=j;
                end;
              'w','W' :
                status.errorwarning:=true;
              'n','N' :
                status.errornote:=true;
              'h','H' :
                status.errorhint:=true;
           end;
         end;
      end;


    procedure GenerateError;
      begin
        inc(status.errorcount);
      end;


    procedure internalerror(i : longint);
      begin
        UpdateStatus;
        do_internalerror(i);
        inc(status.errorcount);
        raise ECompilerAbort.Create;
      end;


    procedure Comment(l:longint;s:string);
      var
        dostop : boolean;
      begin
        dostop:=((l and V_Fatal)<>0);
        if ((l and V_Error)<>0) or
           (status.errorwarning and ((l and V_Warning)<>0)) or
           (status.errornote and ((l and V_Note)<>0)) or
           (status.errorhint and ((l and V_Hint)<>0)) then
         inc(status.errorcount);
      { check verbosity level }
        if not CheckVerbosity(l) then
          exit;
        if (l and V_LineInfoMask)<>0 then
          l:=l or V_LineInfo;
      { Create status info }
        UpdateStatus;
      { Fix replacements }
        DefaultReplacements(s);
      { show comment }
        if do_comment(l,s) or dostop then
          raise ECompilerAbort.Create;
        if (status.errorcount>=status.maxerrorcount) and not status.skip_error then
         begin
           Message1(unit_f_errors_in_unit,tostr(status.errorcount));
           status.skip_error:=true;
           raise ECompilerAbort.Create;
         end;
      end;


    Procedure Msg2Comment(s:string);
      var
        idx,i,v : longint;
        dostop  : boolean;
      begin
      {Reset}
        dostop:=false;
        v:=0;
      {Parse options}
        idx:=pos('_',s);
        if idx=0 then
         v:=V_Normal
        else
         if (idx >= 1) And (idx <= 5) then
          begin
            for i:=1 to idx do
             begin
               case upcase(s[i]) of
                'F' :
                  begin
                    v:=v or V_Fatal;
                    inc(status.errorcount);
                    dostop:=true;
                  end;
                'E' :
                  begin
                     v:=v or V_Error;
                    inc(status.errorcount);
                  end;
                'O' :
                  v:=v or V_Normal;
                'W':
                  begin
                    v:=v or V_Warning;
                    if status.errorwarning then
                     inc(status.errorcount);
                  end;
                'N' :
                  begin
                    v:=v or V_Note;
                    if status.errornote then
                     inc(status.errorcount);
                  end;
                'H' :
                  begin
                    v:=v or V_Hint;
                    if status.errorhint then
                     inc(status.errorcount);
                  end;
                'I' :
                  v:=v or V_Info;
                'L' :
                  v:=v or V_LineInfo;
                'U' :
                  v:=v or V_Used;
                'T' :
                  v:=v or V_Tried;
                'C' :
                  v:=v or V_Conditional;
                'D' :
                  v:=v or V_Debug;
                'X' :
                  v:=v or V_Executable;
                'S' :
                  dostop:=true;
                '_' : ;
               end;
             end;
          end;
        Delete(s,1,idx);
      { check verbosity level }
        if not CheckVerbosity(v) then
          exit;
        if (v and V_LineInfoMask)<>0 then
          v:=v or V_LineInfo;
      { fix status }
        UpdateStatus;
      { Fix replacements }
        DefaultReplacements(s);
      { show comment }
        if do_comment(v,s) or dostop then
          raise ECompilerAbort.Create;
        if (status.errorcount>=status.maxerrorcount) and not status.skip_error then
         begin
           Message1(unit_f_errors_in_unit,tostr(status.errorcount));
           status.skip_error:=true;
           raise ECompilerAbort.Create;
         end;
      end;


    function  MessagePchar(w:longint):pchar;
      begin
        MaybeLoadMessageFile;
        MessagePchar:=msg^.GetPchar(w)
      end;


    procedure Message(w:longint);
      begin
        MaybeLoadMessageFile;
        Msg2Comment(msg^.Get(w,[]));
      end;


    procedure Message1(w:longint;const s1:string);

      begin
        MaybeLoadMessageFile;
        Msg2Comment(msg^.Get(w,[s1]));
      end;


    procedure Message2(w:longint;const s1,s2:string);
      begin
        MaybeLoadMessageFile;
        Msg2Comment(msg^.Get(w,[s1,s2]));
      end;


    procedure Message3(w:longint;const s1,s2,s3:string);
      begin
        MaybeLoadMessageFile;
        Msg2Comment(msg^.Get(w,[s1,s2,s3]));
      end;


    procedure Message4(w:longint;const s1,s2,s3,s4:string);
      begin
        MaybeLoadMessageFile;
        Msg2Comment(msg^.Get(w,[s1,s2,s3,s4]));
      end;


    procedure MessagePos(const pos:tfileposinfo;w:longint);
      var
        oldpos : tfileposinfo;
      begin
        oldpos:=aktfilepos;
        aktfilepos:=pos;
        MaybeLoadMessageFile;
        Msg2Comment(msg^.Get(w,[]));
        aktfilepos:=oldpos;
      end;


    procedure MessagePos1(const pos:tfileposinfo;w:longint;const s1:string);
      var
        oldpos : tfileposinfo;
      begin
        oldpos:=aktfilepos;
        aktfilepos:=pos;
        MaybeLoadMessageFile;
        Msg2Comment(msg^.Get(w,[s1]));
        aktfilepos:=oldpos;
      end;


    procedure MessagePos2(const pos:tfileposinfo;w:longint;const s1,s2:string);
      var
        oldpos : tfileposinfo;
      begin
        oldpos:=aktfilepos;
        aktfilepos:=pos;
        MaybeLoadMessageFile;
        Msg2Comment(msg^.Get(w,[s1,s2]));
        aktfilepos:=oldpos;
      end;


    procedure MessagePos3(const pos:tfileposinfo;w:longint;const s1,s2,s3:string);
      var
        oldpos : tfileposinfo;
      begin
        oldpos:=aktfilepos;
        aktfilepos:=pos;
        MaybeLoadMessageFile;
        Msg2Comment(msg^.Get(w,[s1,s2,s3]));
        aktfilepos:=oldpos;
      end;


    procedure MessagePos4(const pos:tfileposinfo;w:longint;const s1,s2,s3,s4:string);
      var
        oldpos : tfileposinfo;
      begin
        oldpos:=aktfilepos;
        aktfilepos:=pos;
        MaybeLoadMessageFile;
        Msg2Comment(msg^.Get(w,[s1,s2,s3,s4]));
        aktfilepos:=oldpos;
      end;


{*****************************************************************************
            override the message calls to set codegenerror
*****************************************************************************}

    procedure cgmessage(t : longint);
      var
         olderrorcount : longint;
      begin
         if not(codegenerror) then
           begin
              olderrorcount:=Errorcount;
              verbose.Message(t);
              codegenerror:=olderrorcount<>Errorcount;
           end;
      end;

    procedure cgmessage1(t : longint;const s : string);
      var
         olderrorcount : longint;
      begin
         if not(codegenerror) then
           begin
              olderrorcount:=Errorcount;
              verbose.Message1(t,s);
              codegenerror:=olderrorcount<>Errorcount;
           end;
      end;

    procedure cgmessage2(t : longint;const s1,s2 : string);
      var
         olderrorcount : longint;
      begin
         if not(codegenerror) then
           begin
              olderrorcount:=Errorcount;
              verbose.Message2(t,s1,s2);
              codegenerror:=olderrorcount<>Errorcount;
           end;
      end;

    procedure cgmessage3(t : longint;const s1,s2,s3 : string);
      var
         olderrorcount : longint;
      begin
         if not(codegenerror) then
           begin
              olderrorcount:=Errorcount;
              verbose.Message3(t,s1,s2,s3);
              codegenerror:=olderrorcount<>Errorcount;
           end;
      end;


    procedure cgmessagepos(const pos:tfileposinfo;t : longint);
      var
         olderrorcount : longint;
      begin
         if not(codegenerror) then
           begin
              olderrorcount:=Errorcount;
              verbose.MessagePos(pos,t);
              codegenerror:=olderrorcount<>Errorcount;
           end;
      end;

    procedure cgmessagepos1(const pos:tfileposinfo;t : longint;const s1 : string);
      var
         olderrorcount : longint;
      begin
         if not(codegenerror) then
           begin
              olderrorcount:=Errorcount;
              verbose.MessagePos1(pos,t,s1);
              codegenerror:=olderrorcount<>Errorcount;
           end;
      end;

    procedure cgmessagepos2(const pos:tfileposinfo;t : longint;const s1,s2 : string);
      var
         olderrorcount : longint;
      begin
         if not(codegenerror) then
           begin
              olderrorcount:=Errorcount;
              verbose.MessagePos2(pos,t,s1,s2);
              codegenerror:=olderrorcount<>Errorcount;
           end;
      end;

    procedure cgmessagepos3(const pos:tfileposinfo;t : longint;const s1,s2,s3 : string);
      var
         olderrorcount : longint;
      begin
         if not(codegenerror) then
           begin
              olderrorcount:=Errorcount;
              verbose.MessagePos3(pos,t,s1,s2,s3);
              codegenerror:=olderrorcount<>Errorcount;
           end;
      end;


{*****************************************************************************
                                Initialization
*****************************************************************************}

    procedure InitVerbose;
      begin
      { Init }
        msg:=new(pmessage,Init(20,msgidxmax));
        if msg=nil then
         begin
           writeln('Fatal: MsgIdx Wrong');
           halt(3);
         end;
{$ifndef EXTERN_MSG}
        msg^.LoadIntern(@msgtxt,msgtxtsize);
{$else EXTERN_MSG}
        LoadMsgFile(exepath+'errore.msg');
{$endif EXTERN_MSG}
        FillChar(Status,sizeof(TCompilerStatus),0);
        status.verbosity:=V_Default;
        Status.MaxErrorCount:=50;
        Status.codesize:=-1;
        Status.datasize:=-1;
        Loadprefixes;
        lastfileidx:=-1;
        lastmoduleidx:=-1;
        status.currentmodule:='';
        status.currentsource:='';
        status.currentsourcepath:='';
        status.compiling_current:=false;
        compiling_module:=nil;
        { Register internalerrorproc for cutils/cclasses }
        internalerrorproc:=@internalerror;
      end;


    procedure DoneVerbose;
      begin
        if assigned(msg) then
         begin
           dispose(msg,Done);
           msg:=nil;
         end;
        DoneRedirectFile;
      end;


initialization
finalization
  { Be sure to close the redirect files to flush all data }
  DoneRedirectFile;
end.
