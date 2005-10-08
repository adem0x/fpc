{
    Copyright (c) 2003-2004 by Peter Vreman and Florian Klaempfl

    This units contains support for STABS debug info generation

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
unit dbgstabs;

{$i fpcdefs.inc}

interface

    uses
      cclasses,
      dbgbase,
      symtype,symdef,symsym,symtable,symbase,
      aasmtai;

    type
      TDebugInfoStabs=class(TDebugInfo)
      private
        writing_def_stabs  : boolean;
        global_stab_number : word;
        { tsym writing }
        function  sym_var_value(const s:string;arg:pointer):string;
        function  sym_stabstr_evaluate(sym:tsym;const s:string;const vars:array of string):Pchar;
        procedure write_symtable_syms(list:taasmoutput;st:tsymtable);
        { tdef writing }
        function  def_stab_number(def:tdef):string;
        function  def_stab_classnumber(def:tobjectdef):string;
        function  def_var_value(const s:string;arg:pointer):string;
        function  def_stabstr_evaluate(def:tdef;const s:string;const vars:array of string):Pchar;
        procedure field_add_stabstr(p:Tnamedindexitem;arg:pointer);
        procedure method_add_stabstr(p:Tnamedindexitem;arg:pointer);
        function  def_stabstr(def:tdef):pchar;
        procedure write_def_stabstr(list:taasmoutput;def:tdef);
        procedure field_write_defs(p:Tnamedindexitem;arg:pointer);
        procedure method_write_defs(p :tnamedindexitem;arg:pointer);
        procedure write_symtable_defs(list:taasmoutput;st:tsymtable);
      public
        procedure insertsym(list:taasmoutput;sym:tsym);override;
        procedure insertdef(list:taasmoutput;def:tdef);override;
        procedure insertvmt(list:taasmoutput;objdef:tobjectdef);override;
        procedure insertmoduletypes(list:taasmoutput);override;
        procedure insertprocstart(list:taasmoutput);override;
        procedure insertprocend(list:taasmoutput);override;
        procedure insertmodulestart(list:taasmoutput);override;
        procedure insertmoduleend(list:taasmoutput);override;
        procedure insertlineinfo(list:taasmoutput);override;
        procedure referencesections(list:taasmoutput);override;
      end;

implementation

    uses
      strings,cutils,
      systems,globals,globtype,verbose,
      symconst,defutil,
      cpuinfo,cpubase,cgbase,paramgr,
      aasmbase,procinfo,
      finput,fmodule,ppu;

    const
      memsizeinc = 512;

      N_GSYM = $20;
      N_STSYM = 38;     { initialized const }
      N_LCSYM = 40;     { non initialized variable}
      N_Function = $24; { function or const }
      N_TextLine = $44;
      N_DataLine = $46;
      N_BssLine = $48;
      N_RSYM = $40;     { register variable }
      N_LSYM = $80;
      N_tsym = 160;
      N_SourceFile = $64;
      N_IncludeFile = $84;
      N_BINCL = $82;
      N_EINCL = $A2;
      N_EXCL  = $C2;

      tagtypes = [
        recorddef,
        enumdef,
        stringdef,
        filedef,
        objectdef
      ];

    type
       get_var_value_proc=function(const s:string;arg:pointer):string of object;

       Trecord_stabgen_state=record
          stabstring:Pchar;
          stabsize,staballoc,recoffset:integer;
       end;
       Precord_stabgen_state=^Trecord_stabgen_state;


    function string_evaluate(s:string;get_var_value:get_var_value_proc;
                             get_var_value_arg:pointer;
                             const vars:array of string):Pchar;

    (*
     S contains a prototype of a result. Stabstr_evaluate will expand
     variables and parameters.

     Output is s in ASCIIZ format, with the following expanded:

     ${varname}   - The variable name is expanded.
     $n           - The parameter n is expanded.
     $$           - Is expanded to $
    *)

    const maxvalue=9;
          maxdata=1023;

    var i,j:byte;
        varname:string[63];
        varno,varcounter:byte;
        varvalues:array[0..9] of Pstring;
        {1 kb of parameters is the limit. 256 extra bytes are allocated to
         ensure buffer integrity.}
        varvaluedata:array[0..maxdata+256] of char;
        varptr:Pchar;
        varidx : byte;
        len:cardinal;
        r:Pchar;

    begin
      {Two pass approach, first, calculate the length and receive variables.}
      i:=1;
      len:=0;
      varcounter:=0;
      varptr:=@varvaluedata;
      while i<=length(s) do
        begin
          if (s[i]='$') and (i<length(s)) then
            begin
             if s[i+1]='$' then
               begin
                 inc(len);
                 inc(i);
               end
             else if (s[i+1]='{') and (length(s)>2) and (i<length(s)-2) then
               begin
                 varname:='';
                 inc(i,2);
                 repeat
                   inc(varname[0]);
                   varname[length(varname)]:=s[i];
                   s[i]:=char(varcounter);
                   inc(i);
                 until s[i]='}';
                 varvalues[varcounter]:=Pstring(varptr);
                 if varptr>@varvaluedata+maxdata then
                   internalerrorproc(200411152);
                 Pstring(varptr)^:=get_var_value(varname,get_var_value_arg);
                 inc(len,length(Pstring(varptr)^));
                 inc(varptr,length(Pstring(varptr)^)+1);
                 inc(varcounter);
               end
             else if s[i+1] in ['1'..'9'] then
               begin
                 varidx:=byte(s[i+1])-byte('1');
                 if varidx>high(vars) then
                   internalerror(200509263);
                 inc(len,length(vars[varidx]));
                 inc(i);
               end;
            end
          else
            inc(len);
          inc(i);
        end;

      {Second pass, writeout result.}
      getmem(r,len+1);
      string_evaluate:=r;
      i:=1;
      while i<=length(s) do
        begin
          if (s[i]='$') and (i<length(s)) then
            begin
             if s[i+1]='$' then
               begin
                 r^:='$';
                 inc(r);
                 inc(i);
               end
             else if (s[i+1]='{') and (length(s)>2) and (i<length(s)-2) then
               begin
                 varname:='';
                 inc(i,2);
                 varno:=byte(s[i]);
                 repeat
                   inc(i);
                 until s[i]='}';
                 for j:=1 to length(varvalues[varno]^) do
                   begin
                     r^:=varvalues[varno]^[j];
                     inc(r);
                   end;
               end
             else if s[i+1] in ['0'..'9'] then
               begin
                 for j:=1 to length(vars[byte(s[i+1])-byte('1')]) do
                   begin
                     r^:=vars[byte(s[i+1])-byte('1')][j];
                     inc(r);
                   end;
                 inc(i);
               end
            end
          else
            begin
              r^:=s[i];
              inc(r);
            end;
          inc(i);
        end;
      r^:=#0;
    end;


{****************************************************************************
                               TDef support
****************************************************************************}

    function TDebugInfoStabs.def_stab_number(def:tdef):string;
      begin
        { procdefs only need a number, mark them as already written
          so they won't be written implicitly }
        if (def.deftype=procdef) then
          def.stab_state:=stab_state_written;
        { Stab must already be written, or we must be busy writing it }
        if writing_def_stabs and
           not(def.stab_state in [stab_state_writing,stab_state_written]) then
          internalerror(200403091);
        { Keep track of used stabs, this info is only usefull for stabs
          referenced by the symbols. Definitions will always include all
          required stabs }
        if def.stab_state=stab_state_unused then
          def.stab_state:=stab_state_used;
        { Need a new number? }
        if def.stab_number=0 then
          begin
            inc(global_stab_number);
            { classes require 2 numbers }
            if is_class(def) then
              inc(global_stab_number);
            def.stab_number:=global_stab_number;
          end;
        result:=tostr(def.stab_number);
      end;


    function TDebugInfoStabs.def_stab_classnumber(def:tobjectdef):string;
      begin
        if def.stab_number=0 then
          def_stab_number(def);
        result:=tostr(def.stab_number-1);
      end;


    function TDebugInfoStabs.def_var_value(const s:string;arg:pointer):string;
      var
        def : tdef;
      begin
        def:=tdef(arg);
        result:='';
        if s='numberstring' then
          result:=def_stab_number(def)
        else if s='sym_name' then
          begin
            if assigned(def.typesym) then
               result:=Ttypesym(def.typesym).name;
          end
        else if s='N_LSYM' then
          result:=tostr(N_LSYM)
        else if s='savesize' then
          result:=tostr(def.size);
      end;


    function TDebugInfoStabs.def_stabstr_evaluate(def:tdef;const s:string;const vars:array of string):Pchar;
      begin
        result:=string_evaluate(s,@def_var_value,def,vars);
      end;


    procedure TDebugInfoStabs.field_add_stabstr(p:Tnamedindexitem;arg:pointer);
      var
        newrec  : Pchar;
        spec    : string[3];
        varsize : aint;
        state   : Precord_stabgen_state;
      begin
        state:=arg;
        { static variables from objects are like global objects }
        if (Tsym(p).typ=fieldvarsym) and
           not(sp_static in Tsym(p).symoptions) then
          begin
            if ([sp_protected,sp_strictprotected]*tsym(p).symoptions)<>[] then
              spec:='/1'
            else if ([sp_private,sp_strictprivate]*tsym(p).symoptions)<>[] then
              spec:='/0'
            else
              spec:='';
            varsize:=tfieldvarsym(p).vartype.def.size;
            { open arrays made overflows !! }
            if varsize>$fffffff then
              varsize:=$fffffff;
            newrec:=def_stabstr_evaluate(nil,'$1:$2,$3,$4;',[p.name,
                                     spec+def_stab_number(tfieldvarsym(p).vartype.def),
                                     tostr(tfieldvarsym(p).fieldoffset*8),tostr(varsize*8)]);
            if state^.stabsize+strlen(newrec)>=state^.staballoc-256 then
              begin
                inc(state^.staballoc,memsizeinc);
                reallocmem(state^.stabstring,state^.staballoc);
              end;
            strcopy(state^.stabstring+state^.stabsize,newrec);
            inc(state^.stabsize,strlen(newrec));
            strdispose(newrec);
            {This should be used for case !!}
            inc(state^.recoffset,Tfieldvarsym(p).vartype.def.size);
          end;
      end;


    procedure TDebugInfoStabs.method_add_stabstr(p:Tnamedindexitem;arg:pointer);
      var virtualind,argnames : string;
          newrec : pchar;
          pd     : tprocdef;
          lindex : longint;
          arglength : byte;
          sp : char;
          state:^Trecord_stabgen_state;
          olds:integer;
          i : integer;
          parasym : tparavarsym;
      begin
        state:=arg;
        if tsym(p).typ = procsym then
         begin
           pd := tprocsym(p).first_procdef;
           if (po_virtualmethod in pd.procoptions) then
             begin
               lindex := pd.extnumber;
               {doesnt seem to be necessary
               lindex := lindex or $80000000;}
               virtualind := '*'+tostr(lindex)+';'+def_stab_classnumber(pd._class)+';'
             end
            else
             virtualind := '.';

            { used by gdbpas to recognize constructor and destructors }
            if (pd.proctypeoption=potype_constructor) then
              argnames:='__ct__'
            else if (pd.proctypeoption=potype_destructor) then
              argnames:='__dt__'
            else
              argnames := '';

           { arguments are not listed here }
           {we don't need another definition}
            for i:=0 to pd.paras.count-1 do
              begin
                parasym:=tparavarsym(pd.paras[i]);
                if Parasym.vartype.def.deftype = formaldef then
                  begin
                    case Parasym.varspez of
                      vs_var :
                        argnames := argnames+'3var';
                      vs_const :
                        argnames:=argnames+'5const';
                      vs_out :
                        argnames:=argnames+'3out';
                    end;
                  end
                else
                  begin
                    { if the arg definition is like (v: ^byte;..
                    there is no sym attached to data !!! }
                    if assigned(Parasym.vartype.def.typesym) then
                      begin
                        arglength := length(Parasym.vartype.def.typesym.name);
                        argnames := argnames + tostr(arglength)+Parasym.vartype.def.typesym.name;
                      end
                    else
                      argnames:=argnames+'11unnamedtype';
                  end;
              end;
           { here 2A must be changed for private and protected }
           { 0 is private 1 protected and 2 public }
           if ([sp_private,sp_strictprivate]*tsym(p).symoptions)<>[] then
             sp:='0'
           else if ([sp_protected,sp_strictprotected]*tsym(p).symoptions)<>[] then
             sp:='1'
           else
             sp:='2';
           newrec:=def_stabstr_evaluate(nil,'$1::$2=##$3;:$4;$5A$6;',[p.name,def_stab_number(pd),
                                    def_stab_number(pd.rettype.def),argnames,sp,
                                    virtualind]);
           { get spare place for a string at the end }
           olds:=state^.stabsize;
           inc(state^.stabsize,strlen(newrec));
           if state^.stabsize>=state^.staballoc-256 then
             begin
                inc(state^.staballoc,memsizeinc);
                reallocmem(state^.stabstring,state^.staballoc);
             end;
           strcopy(state^.stabstring+olds,newrec);
           strdispose(newrec);
           {This should be used for case !!
           RecOffset := RecOffset + pd.size;}
         end;
      end;


    function TDebugInfoStabs.def_stabstr(def:tdef):pchar;

        function stringdef_stabstr(def:tstringdef):pchar;
          var
            slen : aint;
            bytest,charst,longst : string;
          begin
            case def.string_typ of
              st_shortstring:
                begin
                  { fix length of openshortstring }
                  slen:=def.len;
                  if slen=0 then
                    slen:=255;
                  charst:=def_stab_number(cchartype.def);
                  bytest:=def_stab_number(u8inttype.def);
                  result:=def_stabstr_evaluate(def,'s$1length:$2,0,8;st:ar$2;1;$3;$4,8,$5;;',
                              [tostr(slen+1),bytest,tostr(slen),charst,tostr(slen*8)]);
                end;
              st_longstring:
                begin
                  charst:=def_stab_number(cchartype.def);
                  bytest:=def_stab_number(u8inttype.def);
                  longst:=def_stab_number(u32inttype.def);
                  result:=def_stabstr_evaluate(def,'s$1length:$2,0,32;dummy:$6,32,8;st:ar$2;1;$3;$4,40,$5;;',
                              [tostr(def.len+5),longst,tostr(def.len),charst,tostr(def.len*8),bytest]);
               end;
             st_ansistring:
               begin
                 { looks like a pchar }
                 charst:=def_stab_number(cchartype.def);
                 result:=strpnew('*'+charst);
               end;
             st_widestring:
               begin
                 { looks like a pwidechar }
                 charst:=def_stab_number(cwidechartype.def);
                 result:=strpnew('*'+charst);
               end;
            end;
          end;

        function enumdef_stabstr(def:tenumdef):pchar;
          var
            st : Pchar;
            p : Tenumsym;
            s : string;
            memsize,
            stl : aint;
          begin
            memsize:=memsizeinc;
            getmem(st,memsize);
            { we can specify the size with @s<size>; prefix PM }
            if def.size <> std_param_align then
              strpcopy(st,'@s'+tostr(def.size*8)+';e')
            else
              strpcopy(st,'e');
            p := tenumsym(def.firstenum);
            stl:=strlen(st);
            while assigned(p) do
              begin
                s :=p.name+':'+tostr(p.value)+',';
                { place for the ending ';' also }
                if (stl+length(s)+1>=memsize) then
                  begin
                    inc(memsize,memsizeinc);
                    reallocmem(st,memsize);
                  end;
                strpcopy(st+stl,s);
                inc(stl,length(s));
                p:=p.nextenum;
              end;
            st[stl]:=';';
            st[stl+1]:=#0;
            reallocmem(st,stl+2);
            result:=st;
          end;

        function orddef_stabstr(def:torddef):pchar;
          begin
            if cs_gdb_valgrind in aktglobalswitches then
              begin
                case def.typ of
                  uvoid :
                    result:=strpnew(def_stab_number(def));
                  bool8bit,
                  bool16bit,
                  bool32bit :
                    result:=def_stabstr_evaluate(def,'r${numberstring};0;255;',[]);
                  u32bit,
                  s64bit,
                  u64bit :
                    result:=def_stabstr_evaluate(def,'r${numberstring};0;-1;',[]);
                  else
                    result:=def_stabstr_evaluate(def,'r${numberstring};$1;$2;',[tostr(longint(def.low)),tostr(longint(def.high))]);
                end;
              end
            else
              begin
                case def.typ of
                  uvoid :
                    result:=strpnew(def_stab_number(def));
                  uchar :
                    result:=strpnew('-20;');
                  uwidechar :
                    result:=strpnew('-30;');
                  bool8bit :
                    result:=strpnew('-21;');
                  bool16bit :
                    result:=strpnew('-22;');
                  bool32bit :
                    result:=strpnew('-23;');
                  u64bit :
                    result:=strpnew('-32;');
                  s64bit :
                    result:=strpnew('-31;');
                  {u32bit : result:=def_stab_number(s32inttype.def)+';0;-1;'); }
                  else
                    result:=def_stabstr_evaluate(def,'r${numberstring};$1;$2;',[tostr(longint(def.low)),tostr(longint(def.high))]);
                end;
             end;
          end;

        function floatdef_stabstr(def:tfloatdef):Pchar;
          begin
            case def.typ of
              s32real,
              s64real,
              s80real:
                result:=def_stabstr_evaluate(def,'r$1;${savesize};0;',[def_stab_number(s32inttype.def)]);
              s64currency,
              s64comp:
                result:=def_stabstr_evaluate(def,'r$1;-${savesize};0;',[def_stab_number(s32inttype.def)]);
              else
                internalerror(200509261);
            end;
          end;

        function filedef_stabstr(def:tfiledef):pchar;
          begin
{$ifdef cpu64bit}
            result:=def_stabstr_evaluate(def,'s${savesize}HANDLE:$1,0,32;MODE:$1,32,32;RECSIZE:$2,64,64;'+
                                     '_PRIVATE:ar$1;1;64;$3,128,256;USERDATA:ar$1;1;16;$3,384,128;'+
                                     'NAME:ar$1;0;255;$4,512,2048;;',[def_stab_number(s32inttype.def),
                                     def_stab_number(s64inttype.def),
                                     def_stab_number(u8inttype.def),
                                     def_stab_number(cchartype.def)]);
{$else cpu64bit}
            result:=def_stabstr_evaluate(def,'s${savesize}HANDLE:$1,0,32;MODE:$1,32,32;RECSIZE:$1,64,32;'+
                                     '_PRIVATE:ar$1;1;32;$3,96,256;USERDATA:ar$1;1;16;$2,352,128;'+
                                     'NAME:ar$1;0;255;$3,480,2048;;',[def_stab_number(s32inttype.def),
                                     def_stab_number(u8inttype.def),
                                     def_stab_number(cchartype.def)]);
{$endif cpu64bit}
          end;

        function procdef_stabstr(def:tprocdef):pchar;
          Var
            RType : Char;
            Obj,Info : String;
            stabsstr : string;
            p : pchar;
          begin
            obj := def.procsym.name;
            info := '';
            if (po_global in def.procoptions) then
              RType := 'F'
            else
              RType := 'f';
            if assigned(def.owner) then
             begin
               if (def.owner.symtabletype = objectsymtable) then
                 obj := def.owner.name^+'__'+def.procsym.name;
               if not(cs_gdb_valgrind in aktglobalswitches) and
                  (def.owner.symtabletype=localsymtable) and
                  assigned(def.owner.defowner) and
                  assigned(tprocdef(def.owner.defowner).procsym) then
                 info := ','+def.procsym.name+','+tprocdef(def.owner.defowner).procsym.name;
             end;
            stabsstr:=def.mangledname;
            getmem(p,length(stabsstr)+255);
            strpcopy(p,'"'+obj+':'+RType
                  +def_stab_number(def.rettype.def)+info+'",'+tostr(n_function)
                  +',0,'+
                  tostr(def.fileinfo.line)
                  +',');
            strpcopy(strend(p),stabsstr);
            result:=strnew(p);
            freemem(p,length(stabsstr)+255);
          end;

        function recorddef_stabstr(def:trecorddef):pchar;
          var
            state : Trecord_stabgen_state;
          begin
            getmem(state.stabstring,memsizeinc);
            state.staballoc:=memsizeinc;
            strpcopy(state.stabstring,'s'+tostr(def.size));
            state.recoffset:=0;
            state.stabsize:=strlen(state.stabstring);
            def.symtable.foreach(@field_add_stabstr,@state);
            state.stabstring[state.stabsize]:=';';
            state.stabstring[state.stabsize+1]:=#0;
            reallocmem(state.stabstring,state.stabsize+2);
            result:=state.stabstring;
          end;

        function objectdef_stabstr(def:tobjectdef):pchar;
          var
            anc    : tobjectdef;
            state  :Trecord_stabgen_state;
            ts     : string;
          begin
            { Write the invisible pointer for the class? }
            if (def.objecttype=odt_class) and
               (not def.writing_class_record_stab) then
              begin
                result:=strpnew('*'+def_stab_classnumber(def));
                exit;
              end;

            state.staballoc:=memsizeinc;
            getmem(state.stabstring,state.staballoc);
            strpcopy(state.stabstring,'s'+tostr(tobjectsymtable(def.symtable).datasize));
            if assigned(def.childof) then
              begin
                {only one ancestor not virtual, public, at base offset 0 }
                {       !1           ,    0       2         0    ,       }
                strpcopy(strend(state.stabstring),'!1,020,'+def_stab_classnumber(def.childof)+';');
              end;
            {virtual table to implement yet}
            state.recoffset:=0;
            state.stabsize:=strlen(state.stabstring);
            def.symtable.foreach(@field_add_stabstr,@state);
            if (oo_has_vmt in def.objectoptions) then
              if not assigned(def.childof) or not(oo_has_vmt in def.childof.objectoptions) then
                 begin
                    ts:='$vf'+def_stab_classnumber(def)+':'+def_stab_number(vmtarraytype.def)+','+tostr(def.vmt_offset*8)+';';
                    strpcopy(state.stabstring+state.stabsize,ts);
                    inc(state.stabsize,length(ts));
                 end;
            def.symtable.foreach(@method_add_stabstr,@state);
            if (oo_has_vmt in def.objectoptions) then
              begin
                 anc := def;
                 while assigned(anc.childof) and (oo_has_vmt in anc.childof.objectoptions) do
                   anc := anc.childof;
                 { just in case anc = self }
                 ts:=';~%'+def_stab_classnumber(anc)+';';
              end
            else
              ts:=';';
            strpcopy(state.stabstring+state.stabsize,ts);
            inc(state.stabsize,length(ts));
            reallocmem(state.stabstring,state.stabsize+1);
            result:=state.stabstring;
          end;

      begin
        result:=nil;
        case def.deftype of
          stringdef :
            result:=stringdef_stabstr(tstringdef(def));
          enumdef :
            result:=enumdef_stabstr(tenumdef(def));
          orddef :
            result:=orddef_stabstr(torddef(def));
          floatdef :
            result:=floatdef_stabstr(tfloatdef(def));
          filedef :
            result:=filedef_stabstr(tfiledef(def));
          recorddef :
            result:=recorddef_stabstr(trecorddef(def));
          variantdef :
            result:=def_stabstr_evaluate(def,'formal${numberstring};',[]);
          pointerdef :
            result:=strpnew('*'+def_stab_number(tpointerdef(def).pointertype.def));
          classrefdef :
            result:=strpnew(def_stab_number(pvmttype.def));
          setdef :
            result:=def_stabstr_evaluate(def,'@s$1;S$2',[tostr(def.size*8),def_stab_number(tsetdef(def).elementtype.def)]);
          formaldef :
            result:=def_stabstr_evaluate(def,'formal${numberstring};',[]);
          arraydef :
            result:=def_stabstr_evaluate(def,'ar$1;$2;$3;$4',[def_stab_number(tarraydef(def).rangetype.def),
               tostr(tarraydef(def).lowrange),tostr(tarraydef(def).highrange),def_stab_number(tarraydef(def).elementtype.def)]);
          procdef :
            result:=procdef_stabstr(tprocdef(def));
          procvardef :
            result:=strpnew('*f'+def_stab_number(tprocvardef(def).rettype.def));
          objectdef :
            begin
              if tobjectdef(def).writing_class_record_stab then
                result:=objectdef_stabstr(tobjectdef(def))
              else
                result:=strpnew('*'+def_stab_classnumber(tobjectdef(def)));
            end;
        end;
      end;


    procedure TDebugInfoStabs.write_def_stabstr(list:taasmoutput;def:tdef);
      var
        stabchar : string[2];
        ss,st,su : pchar;
      begin
        { procdefs require a different stabs style, handle them separately }
        if def.deftype<>procdef then
          begin
            { type prefix }
            if def.deftype in tagtypes then
              stabchar := 'Tt'
            else
              stabchar := 't';
            { Here we maybe generate a type, so we have to use numberstring }
            if is_class(def) and
               tobjectdef(def).writing_class_record_stab then
              st:=def_stabstr_evaluate(def,'"${sym_name}:$1$2=',[stabchar,def_stab_classnumber(tobjectdef(def))])
            else
              st:=def_stabstr_evaluate(def,'"${sym_name}:$1$2=',[stabchar,def_stab_number(def)]);
            ss:=def_stabstr(def);
            reallocmem(st,strlen(ss)+512);
            { line info is set to 0 for all defs, because the def can be in an other
              unit and then the linenumber is invalid in the current sourcefile }
            su:=def_stabstr_evaluate(def,'",${N_LSYM},0,0,0',[]);
            strcopy(strecopy(strend(st),ss),su);
            reallocmem(st,strlen(st)+1);
            strdispose(ss);
            strdispose(su);
          end
        else
          st:=def_stabstr(def);
        { add to list }
        list.concat(Tai_stab.create(stab_stabs,st));
      end;


    procedure TDebugInfoStabs.field_write_defs(p:Tnamedindexitem;arg:pointer);
      begin
        if (Tsym(p).typ=fieldvarsym) and
           not(sp_static in Tsym(p).symoptions) then
          insertdef(taasmoutput(arg),tfieldvarsym(p).vartype.def);
      end;


    procedure TDebugInfoStabs.method_write_defs(p :tnamedindexitem;arg:pointer);
      var
        pd : tprocdef;
      begin
        if tsym(p).typ = procsym then
          begin
            pd:=tprocsym(p).first_procdef;
            insertdef(taasmoutput(arg),pd.rettype.def);
          end;
      end;


    procedure TDebugInfoStabs.insertdef(list:taasmoutput;def:tdef);
      var
        anc : tobjectdef;
        oldtypesym : tsym;
//        nb  : string[12];
      begin
        if (def.stab_state in [stab_state_writing,stab_state_written]) then
          exit;
        { to avoid infinite loops }
        def.stab_state := stab_state_writing;
        { write dependencies first }
        case def.deftype of
          stringdef :
            begin
              if tstringdef(def).string_typ=st_widestring then
                insertdef(list,cwidechartype.def)
              else
                begin
                  insertdef(list,cchartype.def);
                  insertdef(list,u8inttype.def);
                end;
            end;
          floatdef :
            insertdef(list,s32inttype.def);
          filedef :
            begin
              insertdef(list,s32inttype.def);
{$ifdef cpu64bit}
              insertdef(list,s64inttype.def);
{$endif cpu64bit}
              insertdef(list,u8inttype.def);
              insertdef(list,cchartype.def);
            end;
          classrefdef,
          pointerdef :
            insertdef(list,tpointerdef(def).pointertype.def);
          setdef :
            insertdef(list,tsetdef(def).elementtype.def);
          procvardef,
          procdef :
            insertdef(list,tprocdef(def).rettype.def);
          arraydef :
            begin
              insertdef(list,tarraydef(def).rangetype.def);
              insertdef(list,tarraydef(def).elementtype.def);
            end;
          recorddef :
            trecorddef(def).symtable.foreach(@field_write_defs,list);
          objectdef :
            begin
              insertdef(list,vmtarraytype.def);
              { first the parents }
              anc:=tobjectdef(def);
              while assigned(anc.childof) do
                begin
                  anc:=anc.childof;
                  insertdef(list,anc);
                end;
              tobjectdef(def).symtable.foreach(@field_write_defs,list);
              tobjectdef(def).symtable.foreach(@method_write_defs,list);
            end;
        end;
(*
        { Handle pointerdefs to records and objects to avoid recursion }
        if (def.deftype=pointerdef) and
           (tpointerdef(def).pointertype.def.deftype in [recorddef,objectdef]) then
          begin
            def.stab_state:=stab_state_used;
            write_def_stabstr(list,def);
            {to avoid infinite recursion in record with next-like fields }
            if tdef(tpointerdef(def).pointertype.def).stab_state=stab_state_writing then
              begin
                if assigned(tpointerdef(def).pointertype.def.typesym) then
                  begin
                    if is_class(tpointerdef(def).pointertype.def) then
                      nb:=def_stab_classnumber(tobjectdef(tpointerdef(def).pointertype.def))
                    else
                      nb:=def_stab_number(tpointerdef(def).pointertype.def);
                    list.concat(Tai_stab.create(stab_stabs,def_stabstr_evaluate(
                            def,'"${sym_name}:t${numberstring}=*$1=xs$2:",${N_LSYM},0,0,0',
                            [nb,tpointerdef(def).pointertype.def.typesym.name])));
                  end;
                def.stab_state:=stab_state_written;
              end
          end
        else
*)
        { classes require special code to write the record and the invisible pointer }
          if is_class(def) then
            begin
              { Write the record class itself }
              tobjectdef(def).writing_class_record_stab:=true;
              write_def_stabstr(list,def);
              tobjectdef(def).writing_class_record_stab:=false;
              { Write the invisible pointer class }
              oldtypesym:=def.typesym;
              def.typesym:=nil;
              write_def_stabstr(list,def);
              def.typesym:=oldtypesym;
            end
        { normal def }
        else
          write_def_stabstr(list,def);

        def.stab_state := stab_state_written;
      end;


    procedure TDebugInfoStabs.write_symtable_defs(list:taasmoutput;st:tsymtable);

       procedure dowritestabs(list:taasmoutput;st:tsymtable);
         var
           p : tdef;
         begin
           p:=tdef(st.defindex.first);
           while assigned(p) do
             begin
               { also insert local types for the current unit }
               if st.iscurrentunit then
                 begin
                   case p.deftype of
                     procdef :
                       if assigned(tprocdef(p).localst) then
                         dowritestabs(list,tprocdef(p).localst);
                     objectdef :
                       dowritestabs(list,tobjectdef(p).symtable);
                   end;
                 end;
               if (p.stab_state=stab_state_used) then
                 insertdef(list,p);
               p:=tdef(p.indexnext);
             end;
         end;

      var
        old_writing_def_stabs : boolean;
      begin
        if st.symtabletype=globalsymtable then
          list.concat(tai_comment.Create(strpnew('Begin unit '+st.name^+' has index '+tostr(st.moduleid))));
        old_writing_def_stabs:=writing_def_stabs;
        writing_def_stabs:=true;
        dowritestabs(list,st);
        writing_def_stabs:=old_writing_def_stabs;
        if st.symtabletype=globalsymtable then
          list.concat(tai_comment.Create(strpnew('End unit '+st.name^+' has index '+tostr(st.moduleid))));
      end;


{****************************************************************************
                               TSym support
****************************************************************************}

    function TDebugInfoStabs.sym_var_value(const s:string;arg:pointer):string;
      var
        sym : tsym;
      begin
        sym:=tsym(arg);
        result:='';
        if s='name' then
          result:=sym.name
        else if s='mangledname' then
          result:=sym.mangledname
        else if s='ownername' then
          result:=sym.owner.name^
        else if s='line' then
          result:=tostr(sym.fileinfo.line)
        else if s='N_LSYM' then
          result:=tostr(N_LSYM)
        else if s='N_LCSYM' then
          result:=tostr(N_LCSYM)
        else if s='N_RSYM' then
          result:=tostr(N_RSYM)
        else if s='N_TSYM' then
          result:=tostr(N_TSYM)
        else if s='N_STSYM' then
          result:=tostr(N_STSYM)
        else if s='N_FUNCTION' then
          result:=tostr(N_FUNCTION)
        else
          internalerror(200401152);
      end;


    function TDebugInfoStabs.sym_stabstr_evaluate(sym:tsym;const s:string;const vars:array of string):Pchar;
      begin
        result:=string_evaluate(s,@sym_var_value,sym,vars);
      end;


    procedure TDebugInfoStabs.insertsym(list:taasmoutput;sym:tsym);

        function fieldvarsym_stabstr(sym:tfieldvarsym):Pchar;
          begin
            result:=nil;
            if (sym.owner.symtabletype=objectsymtable) and
               (sp_static in sym.symoptions) then
              result:=sym_stabstr_evaluate(sym,'"${ownername}__${name}:S$1",${N_LCSYM},0,${line},${mangledname}',
                  [def_stab_number(sym.vartype.def)]);
          end;

        function globalvarsym_stabstr(sym:tglobalvarsym):Pchar;
          var
            st : string;
            threadvaroffset : string;
            regidx : Tregisterindex;
          begin
            result:=nil;
            st:=def_stab_number(sym.vartype.def);
            case sym.localloc.loc of
              LOC_REGISTER,
              LOC_CREGISTER,
              LOC_MMREGISTER,
              LOC_CMMREGISTER,
              LOC_FPUREGISTER,
              LOC_CFPUREGISTER :
                begin
                  regidx:=findreg_by_number(sym.localloc.register);
                  { "eax", "ecx", "edx", "ebx", "esp", "ebp", "esi", "edi", "eip", "ps", "cs", "ss", "ds", "es", "fs", "gs", }
                  { this is the register order for GDB}
                  if regidx<>0 then
                    result:=sym_stabstr_evaluate(sym,'"${name}:r$1",${N_RSYM},0,${line},$2',[st,tostr(regstabs_table[regidx])]);
                end;
              else
                begin
                  if (vo_is_thread_var in sym.varoptions) then
                    threadvaroffset:='+'+tostr(sizeof(aint))
                  else
                    threadvaroffset:='';
                  { Here we used S instead of
                    because with G GDB doesn't look at the address field
                    but searches the same name or with a leading underscore
                    but these names don't exist in pascal !}
                  st:='S'+st;
                  result:=sym_stabstr_evaluate(sym,'"${name}:$1",${N_LCSYM},0,${line},${mangledname}$2',[st,threadvaroffset]);
                end;
            end;
          end;

        function localvarsym_stabstr(sym:tlocalvarsym):Pchar;
          var
            st : string;
            regidx : Tregisterindex;
          begin
            result:=nil;
            { There is no space allocated for not referenced locals }
            if (sym.owner.symtabletype=localsymtable) and (sym.refs=0) then
              exit;

            st:=def_stab_number(sym.vartype.def);
            case sym.localloc.loc of
              LOC_REGISTER,
              LOC_CREGISTER,
              LOC_MMREGISTER,
              LOC_CMMREGISTER,
              LOC_FPUREGISTER,
              LOC_CFPUREGISTER :
                begin
                  regidx:=findreg_by_number(sym.localloc.register);
                  { "eax", "ecx", "edx", "ebx", "esp", "ebp", "esi", "edi", "eip", "ps", "cs", "ss", "ds", "es", "fs", "gs", }
                  { this is the register order for GDB}
                  if regidx<>0 then
                    result:=sym_stabstr_evaluate(sym,'"${name}:r$1",${N_RSYM},0,${line},$2',[st,tostr(regstabs_table[regidx])]);
                end;
              LOC_REFERENCE :
                { offset to ebp => will not work if the framepointer is esp
                  so some optimizing will make things harder to debug }
                result:=sym_stabstr_evaluate(sym,'"${name}:$1",${N_TSYM},0,${line},$2',[st,tostr(sym.localloc.reference.offset)])
              else
                internalerror(2003091814);
            end;
          end;

        function paravarsym_stabstr(sym:tparavarsym):Pchar;
          var
            st : string;
            regidx : Tregisterindex;
            c : char;
          begin
            result:=nil;
            { set loc to LOC_REFERENCE to get somewhat usable debugging info for -Or }
            { while stabs aren't adapted for regvars yet                             }
            if (vo_is_self in sym.varoptions) then
              begin
                case sym.localloc.loc of
                  LOC_REGISTER,
                  LOC_CREGISTER:
                    regidx:=findreg_by_number(sym.localloc.register);
                  LOC_REFERENCE: ;
                  else
                    internalerror(2003091815);
                end;
                if (po_classmethod in current_procinfo.procdef.procoptions) or
                   (po_staticmethod in current_procinfo.procdef.procoptions) then
                  begin
                    if (sym.localloc.loc=LOC_REFERENCE) then
                      result:=sym_stabstr_evaluate(sym,'"pvmt:p$1",${N_TSYM},0,0,$2',
                        [def_stab_number(pvmttype.def),tostr(sym.localloc.reference.offset)]);
      (*            else
                      result:=sym_stabstr_evaluate(sym,'"pvmt:r$1",${N_RSYM},0,0,$2',
                        [def_stab_number(pvmttype.def),tostr(regstabs_table[regidx])]) *)
                    end
                else
                  begin
                    if not(is_class(current_procinfo.procdef._class)) then
                      c:='v'
                    else
                      c:='p';
                    if (sym.localloc.loc=LOC_REFERENCE) then
                      result:=sym_stabstr_evaluate(sym,'"$$t:$1",${N_TSYM},0,0,$2',
                            [c+def_stab_number(current_procinfo.procdef._class),tostr(sym.localloc.reference.offset)]);
      (*            else
                      result:=sym_stabstr_evaluate(sym,'"$$t:r$1",${N_RSYM},0,0,$2',
                            [c+def_stab_number(current_procinfo.procdef._class),tostr(regstabs_table[regidx])]); *)
                  end;
              end
            else
              begin
                st:=def_stab_number(sym.vartype.def);

                if paramanager.push_addr_param(sym.varspez,sym.vartype.def,tprocdef(sym.owner.defowner).proccalloption) and
                   not(vo_has_local_copy in sym.varoptions) and
                   not is_open_string(sym.vartype.def) then
                  st := 'v'+st { should be 'i' but 'i' doesn't work }
                else
                  st := 'p'+st;
                case sym.localloc.loc of
                  LOC_REGISTER,
                  LOC_CREGISTER,
                  LOC_MMREGISTER,
                  LOC_CMMREGISTER,
                  LOC_FPUREGISTER,
                  LOC_CFPUREGISTER :
                    begin
                      regidx:=findreg_by_number(sym.localloc.register);
                      { "eax", "ecx", "edx", "ebx", "esp", "ebp", "esi", "edi", "eip", "ps", "cs", "ss", "ds", "es", "fs", "gs", }
                      { this is the register order for GDB}
                      if regidx<>0 then
                        result:=sym_stabstr_evaluate(sym,'"${name}:r$1",${N_RSYM},0,${line},$2',[st,tostr(longint(regstabs_table[regidx]))]);
                    end;
                  LOC_REFERENCE :
                    { offset to ebp => will not work if the framepointer is esp
                      so some optimizing will make things harder to debug }
                    result:=sym_stabstr_evaluate(sym,'"${name}:$1",${N_TSYM},0,${line},$2',[st,tostr(sym.localloc.reference.offset)])
                  else
                    internalerror(2003091814);
                end;
              end;
          end;

        function constsym_stabstr(sym:tconstsym):Pchar;
          var
            st : string;
          begin
            case sym.consttyp of
              conststring:
                st:='s'''+backspace_quote(octal_quote(strpas(pchar(sym.value.valueptr)),[#0..#9,#11,#12,#14..#31,'''']),['"','\',#10,#13])+'''';
              constord:
                st:='i'+tostr(sym.value.valueord);
              constpointer:
                st:='i'+tostr(sym.value.valueordptr);
              constreal:
                begin
                  system.str(pbestreal(sym.value.valueptr)^,st);
                  st := 'r'+st;
                end;
              else
                begin
                  { if we don't know just put zero !! }
                  st:='i0';
                end;
            end;
            { valgrind does not support constants }
            if cs_gdb_valgrind in aktglobalswitches then
              result:=nil
            else
              result:=sym_stabstr_evaluate(sym,'"${name}:c=$1;",${N_FUNCTION},0,${line},0',[st]);
          end;

        function typesym_stabstr(sym:ttypesym) : pchar;
          var
            stabchar : string[2];
          begin
            result:=nil;
            if not assigned(sym.restype.def) then
              internalerror(200509262);
            if sym.restype.def.deftype in tagtypes then
              stabchar:='Tt'
            else
              stabchar:='t';
            result:=sym_stabstr_evaluate(sym,'"${name}:$1$2",${N_LSYM},0,${line},0',[stabchar,def_stab_number(sym.restype.def)]);
          end;

      var
        stabstr : Pchar;
      begin
        stabstr:=nil;
        case sym.typ of
          labelsym :
            stabstr:=sym_stabstr_evaluate(sym,'"${name}",${N_LSYM},0,${line},0',[]);
          procsym :
            internalerror(200111171);
          fieldvarsym :
            stabstr:=fieldvarsym_stabstr(tfieldvarsym(sym));
          globalvarsym :
            stabstr:=globalvarsym_stabstr(tglobalvarsym(sym));
          localvarsym :
            stabstr:=localvarsym_stabstr(tlocalvarsym(sym));
          paravarsym :
            stabstr:=paravarsym_stabstr(tparavarsym(sym));
          typedconstsym :
            stabstr:=sym_stabstr_evaluate(sym,'"${name}:S$1",${N_STSYM},0,${line},${mangledname}',
                [def_stab_number(ttypedconstsym(sym).typedconsttype.def)]);
          constsym :
            stabstr:=constsym_stabstr(tconstsym(sym));
          typesym :
            stabstr:=typesym_stabstr(ttypesym(sym));
        end;
        if stabstr<>nil then
          list.concat(Tai_stab.create(stab_stabs,stabstr));
        sym.isstabwritten:=true;
      end;


    procedure TDebugInfoStabs.write_symtable_syms(list:taasmoutput;st:tsymtable);
      var
        p : tsym;
      begin
        p:=tsym(st.symindex.first);
        while assigned(p) do
          begin
            { Procsym and typesym are already written }
            if not(Tsym(p).typ in [procsym,typesym]) then
              begin
                if not Tsym(p).isstabwritten then
                  insertsym(list,tsym(p));
              end;
            p:=tsym(p.indexnext);
          end;
      end;

{****************************************************************************
                             Proc/Module support
****************************************************************************}

    procedure tdebuginfostabs.insertvmt(list:taasmoutput;objdef:tobjectdef);
      begin
        if assigned(objdef.owner) and
           assigned(objdef.owner.name) then
          list.concat(Tai_stab.create(stab_stabs,strpnew('"vmt_'+objdef.owner.name^+objdef.name+':S'+
                 def_stab_number(vmttype.def)+'",'+tostr(N_STSYM)+',0,0,'+objdef.vmt_mangledname)));
      end;


    procedure tdebuginfostabs.insertmoduletypes(list:taasmoutput);

       procedure reset_unit_type_info;
       var
         hp : tmodule;
       begin
         hp:=tmodule(loaded_units.first);
         while assigned(hp) do
           begin
             hp.is_stab_written:=false;
             hp:=tmodule(hp.next);
           end;
       end;

       procedure write_used_unit_type_info(list:taasmoutput;hp:tmodule);
       var
         pu : tused_unit;
       begin
         pu:=tused_unit(hp.used_units.first);
         while assigned(pu) do
           begin
             if not pu.u.is_stab_written then
               begin
                 { prevent infinte loop for circular dependencies }
                 pu.u.is_stab_written:=true;
                 { write type info from used units, use a depth first
                   strategy to reduce the recursion in writing all
                   dependent stabs }
                 write_used_unit_type_info(list,pu.u);
                 if assigned(pu.u.globalsymtable) then
                   write_symtable_defs(list,pu.u.globalsymtable);
               end;
             pu:=tused_unit(pu.next);
           end;
       end;

      var
        temptypestabs : taasmoutput;
        storefilepos : tfileposinfo;
        st : tsymtable;
      begin
        global_stab_number:=0;

        storefilepos:=aktfilepos;
        aktfilepos:=current_module.mainfilepos;
        { include symbol that will be referenced from the program to be sure to
          include this debuginfo .o file }
        if current_module.is_unit then
          begin
            current_module.flags:=current_module.flags or uf_has_debuginfo;
            st:=current_module.globalsymtable;
          end
        else
          st:=current_module.localsymtable;
        new_section(list,sec_data,st.name^,0);
        list.concat(tai_symbol.Createname_global(make_mangledname('DEBUGINFO',st,''),AT_DATA,0));
        { first write all global/local symbols again to a temp list. This will flag
          all required tdefs. After that the temp list can be removed since the debuginfo is already
          written to the stabs when the variables/consts were written }
{$warning Hack to get all needed types}
        temptypestabs:=taasmoutput.create;
        if assigned(current_module.globalsymtable) then
          write_symtable_syms(temptypestabs,current_module.globalsymtable);
        if assigned(current_module.localsymtable) then
          write_symtable_syms(temptypestabs,current_module.localsymtable);
        temptypestabs.free;
        { reset unit type info flag }
        reset_unit_type_info;
        { write used types from the used units }
        write_used_unit_type_info(list,current_module);
        { last write the types from this unit }
        if assigned(current_module.globalsymtable) then
          write_symtable_defs(list,current_module.globalsymtable);
        if assigned(current_module.localsymtable) then
          write_symtable_defs(list,current_module.localsymtable);
        aktfilepos:=storefilepos;
      end;


    procedure tdebuginfostabs.insertlineinfo(list:taasmoutput);
      var
        currfileinfo,
        lastfileinfo : tfileposinfo;
        currfuncname : pstring;
        currsectype  : tasmsectiontype;
        hlabel       : tasmlabel;
        hp : tai;
        infile : tinputfile;
      begin
        FillChar(lastfileinfo,sizeof(lastfileinfo),0);
        currfuncname:=nil;
        currsectype:=sec_code;
        hp:=Tai(list.first);
        while assigned(hp) do
          begin
            case hp.typ of
              ait_section :
                currsectype:=tai_section(hp).sectype;
              ait_function_name :
                currfuncname:=tai_function_name(hp).funcname;
              ait_force_line :
                lastfileinfo.line:=-1;
            end;

            if (currsectype=sec_code) and
               (hp.typ=ait_instruction) then
              begin
                currfileinfo:=tailineinfo(hp).fileinfo;
                { file changed ? (must be before line info) }
                if (currfileinfo.fileindex<>0) and
                   (lastfileinfo.fileindex<>currfileinfo.fileindex) then
                  begin
                    infile:=current_module.sourcefiles.get_file(currfileinfo.fileindex);
                    if assigned(infile) then
                      begin
                        objectlibrary.getlabel(hlabel,alt_dbgfile);
                        { emit stabs }
                        if (infile.path^<>'') then
                          list.insertbefore(Tai_stab.Create_str(stab_stabs,'"'+BsToSlash(FixPath(infile.path^,false))+'",'+tostr(n_includefile)+
                                            ',0,0,'+hlabel.name),hp);
                        list.insertbefore(Tai_stab.Create_str(stab_stabs,'"'+FixFileName(infile.name^)+'",'+tostr(n_includefile)+
                                          ',0,0,'+hlabel.name),hp);
                        list.insertbefore(tai_label.create(hlabel),hp);
                        { force new line info }
                        lastfileinfo.line:=-1;
                      end;
                  end;

                { line changed ? }
                if (lastfileinfo.line<>currfileinfo.line) and (currfileinfo.line<>0) then
                  begin
                     if assigned(currfuncname) and
                        (target_info.use_function_relative_addresses) then
                      begin
                        objectlibrary.getlabel(hlabel,alt_dbgline);
                        list.insertbefore(Tai_stab.Create_str(stab_stabn,tostr(n_textline)+',0,'+tostr(currfileinfo.line)+','+
                                          hlabel.name+' - '+{$IFDEF POWERPC64}'.'+{$ENDIF POWERPC64}currfuncname^),hp);
                        list.insertbefore(tai_label.create(hlabel),hp);
                      end
                     else
                      list.insertbefore(Tai_stab.Create_str(stab_stabd,tostr(n_textline)+',0,'+tostr(currfileinfo.line)),hp);
                  end;
                lastfileinfo:=currfileinfo;
              end;

            hp:=tai(hp.next);
          end;
      end;


    procedure tdebuginfostabs.insertprocstart(list:taasmoutput);
      begin
        insertdef(list,current_procinfo.procdef);
        Tprocsym(current_procinfo.procdef.procsym).isstabwritten:=true;
        { write local symtables }
        if not(po_external in current_procinfo.procdef.procoptions) then
          begin
            if assigned(current_procinfo.procdef.parast) then
              write_symtable_syms(list,current_procinfo.procdef.parast);
            { local type defs and vars should not be written
              inside the main proc stab }
            if assigned(current_procinfo.procdef.localst) and
               (current_procinfo.procdef.localst.symtabletype=localsymtable) then
              write_symtable_syms(list,current_procinfo.procdef.localst);
          end;
      end;


    procedure tdebuginfostabs.insertprocend(list:taasmoutput);
      var
        stabsendlabel : tasmlabel;
        mangled_length : longint;
        p : pchar;
        hs : string;
      begin
        objectlibrary.getlabel(stabsendlabel,alt_dbgtype);
        list.concat(tai_label.create(stabsendlabel));

        if assigned(current_procinfo.procdef.funcretsym) and
           (tabstractnormalvarsym(current_procinfo.procdef.funcretsym).refs>0) then
          begin
            if tabstractnormalvarsym(current_procinfo.procdef.funcretsym).localloc.loc=LOC_REFERENCE then
              begin
{$warning Need to add gdb support for ret in param register calling}
                if paramanager.ret_in_param(current_procinfo.procdef.rettype.def,current_procinfo.procdef.proccalloption) then
                  hs:='X*'
                else
                  hs:='X';
                list.concat(Tai_stab.create(stab_stabs,strpnew(
                   '"'+current_procinfo.procdef.procsym.name+':'+hs+def_stab_number(current_procinfo.procdef.rettype.def)+'",'+
                   tostr(N_tsym)+',0,0,'+tostr(tabstractnormalvarsym(current_procinfo.procdef.funcretsym).localloc.reference.offset))));
                if (m_result in aktmodeswitches) then
                  list.concat(Tai_stab.create(stab_stabs,strpnew(
                     '"RESULT:'+hs+def_stab_number(current_procinfo.procdef.rettype.def)+'",'+
                     tostr(N_tsym)+',0,0,'+tostr(tabstractnormalvarsym(current_procinfo.procdef.funcretsym).localloc.reference.offset))));
              end;
          end;
        mangled_length:=length(current_procinfo.procdef.mangledname);
        getmem(p,2*mangled_length+50);
        strpcopy(p,'192,0,0,');
        {$IFDEF POWERPC64}strpcopy(strend(p), '.');{$ENDIF POWERPC64}
        strpcopy(strend(p),current_procinfo.procdef.mangledname);
        if (target_info.use_function_relative_addresses) then
          begin
            strpcopy(strend(p),'-');
            {$IFDEF POWERPC64}strpcopy(strend(p), '.');{$ENDIF POWERPC64}
            strpcopy(strend(p),current_procinfo.procdef.mangledname);
          end;
        list.concat(Tai_stab.Create(stab_stabn,strnew(p)));
        strpcopy(p,'224,0,0,'+stabsendlabel.name);
        if (target_info.use_function_relative_addresses) then
          begin
            strpcopy(strend(p),'-');
            {$IFDEF POWERPC64}strpcopy(strend(p), '.');{$ENDIF POWERPC64}
            strpcopy(strend(p),current_procinfo.procdef.mangledname);
          end;
        list.concat(Tai_stab.Create(stab_stabn,strnew(p)));
        freemem(p,2*mangled_length+50);
      end;


    procedure tdebuginfostabs.insertmodulestart(list:taasmoutput);
      var
        hlabel : tasmlabel;
        infile : tinputfile;
        templist:taasmoutput;
      begin
        { emit main source n_sourcefile }
        objectlibrary.getlabel(hlabel,alt_dbgfile);
        infile:=current_module.sourcefiles.get_file(1);
        templist:=taasmoutput.create;
        new_section(templist,sec_code,'',0);
        if (infile.path^<>'') then
          templist.concat(Tai_stab.Create_str(stab_stabs,'"'+BsToSlash(FixPath(infile.path^,false))+'",'+tostr(n_sourcefile)+
                      ',0,0,'+hlabel.name));
        templist.concat(Tai_stab.Create_str(stab_stabs,'"'+FixFileName(infile.name^)+'",'+tostr(n_sourcefile)+
                    ',0,0,'+hlabel.name));
        templist.concat(tai_label.create(hlabel));
        list.insertlist(templist);
        templist.free;
      end;


    procedure tdebuginfostabs.insertmoduleend(list:taasmoutput);
      var
        hlabel : tasmlabel;
        templist:taasmoutput;
      begin
        { emit empty n_sourcefile }
        objectlibrary.getlabel(hlabel,alt_dbgfile);
        templist:=taasmoutput.create;
        new_section(templist,sec_code,'',0);
        templist.concat(Tai_stab.Create_str(stab_stabs,'"",'+tostr(n_sourcefile)+',0,0,'+hlabel.name));
        templist.concat(tai_label.create(hlabel));
        list.insertlist(templist);
        templist.free;
      end;


    procedure tdebuginfostabs.referencesections(list:taasmoutput);
      var
        hp   : tused_unit;
      begin
        { Reference all DEBUGINFO sections from the main .text section }
        if (target_info.system <> system_powerpc_macos) then
          begin
            { include reference to all debuginfo sections of used units }
            hp:=tused_unit(usedunits.first);
            while assigned(hp) do
              begin
                If (hp.u.flags and uf_has_debuginfo)=uf_has_debuginfo then
                  list.concat(Tai_const.Createname(make_mangledname('DEBUGINFO',hp.u.globalsymtable,''),AT_DATA,0));
                hp:=tused_unit(hp.next);
              end;
            { include reference to debuginfo for this program }
            list.concat(Tai_const.Createname(make_mangledname('DEBUGINFO',current_module.localsymtable,''),AT_DATA,0));
          end;
      end;


    const
      dbg_stabs_info : tdbginfo =
         (
           id     : dbg_stabs;
           idtxt  : 'STABS';
         );

initialization
  RegisterDebugInfo(dbg_stabs_info,TDebugInfoStabs);
end.
