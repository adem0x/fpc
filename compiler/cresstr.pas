{
    Copyright (c) 1998-2002 by Michael van Canneyt

    Handles resourcestrings

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
unit cresstr;

{$i fpcdefs.inc}

interface

    Procedure GenerateResourceStrings;


implementation

uses
   cclasses,
   cutils,globtype,globals,
   symconst,symtype,symdef,symsym,
   verbose,fmodule,
   aasmbase,aasmtai,
   aasmcpu;

    Type
      { These are used to form a singly-linked list, ordered by hash value }
      TResourceStringItem = class(TLinkedListItem)
        Sym   : TConstSym;
        Name  : String;
        Value : Pchar;
        Len   : Longint;
        hash  : Cardinal;
        constructor Create(asym:TConstsym);
        destructor  Destroy;override;
        procedure CalcHash;
      end;

      Tresourcestrings=class
      private
        List : TLinkedList;
        procedure ConstSym_Register(p:tnamedindexitem;arg:pointer);
      public
        constructor Create;
        destructor  Destroy;override;
        procedure CreateResourceStringData;
        Procedure WriteResourceFile;
        procedure RegisterResourceStrings;
      end;



{ ---------------------------------------------------------------------
                          TRESOURCESTRING_ITEM
  ---------------------------------------------------------------------}

    constructor TResourceStringItem.Create(asym:TConstsym);
      begin
        inherited Create;
        Sym:=Asym;
        Name:=lower(asym.owner.name^+'.'+asym.Name);
        Len:=asym.value.len;
        GetMem(Value,Len);
        Move(asym.value.valueptr^,Value^,Len);
        CalcHash;
      end;


    destructor TResourceStringItem.Destroy;
      begin
        FreeMem(Value);
      end;


    procedure TResourceStringItem.CalcHash;
      Var
        g : Cardinal;
        I : longint;
      begin
        hash:=0;
        For I:=0 to Len-1 do { 0 terminated }
         begin
           hash:=hash shl 4;
           inc(Hash,Ord(Value[i]));
           g:=hash and ($f shl 28);
           if g<>0 then
            begin
              hash:=hash xor (g shr 24);
              hash:=hash xor g;
            end;
         end;
        If Hash=0 then
          Hash:=$ffffffff;
      end;


{ ---------------------------------------------------------------------
                          Tresourcestrings
  ---------------------------------------------------------------------}

    Constructor Tresourcestrings.Create;
      begin
        List:=TLinkedList.Create;
      end;


    Destructor Tresourcestrings.Destroy;
      begin
        List.Free;
      end;


    procedure Tresourcestrings.CreateResourceStringData;
      Var
        namelab,
        valuelab : tasmlabel;
        resstrlab : tasmsymbol;
        s : pchar;
        l : longint;
        R : TResourceStringItem;
      begin
        R:=TResourceStringItem(List.First);
        while assigned(R) do
          begin
            maybe_new_object_file(current_asmdata.asmlists[al_const]);
            new_section(current_asmdata.asmlists[al_const],sec_fpc_resstr_data,R.name,sizeof(aint));
            { Write default value }
            if assigned(R.value) and (R.len<>0) then
              begin
                 current_asmdata.getdatalabel(valuelab);
                 current_asmdata.asmlists[al_const].concat(tai_align.Create(const_align(sizeof(aint))));
                 current_asmdata.asmlists[al_const].concat(tai_const.create_aint(-1));
                 current_asmdata.asmlists[al_const].concat(tai_const.create_aint(R.len));
                 current_asmdata.asmlists[al_const].concat(tai_label.create(valuelab));
                 getmem(s,R.len+1);
                 move(R.value^,s^,R.len);
                 s[R.len]:=#0;
                 current_asmdata.asmlists[al_const].concat(tai_string.create_pchar(s,R.len));
                 current_asmdata.asmlists[al_const].concat(tai_const.create_8bit(0));
              end
            else
              valuelab:=nil;
            { Append the name as a ansistring. }
            current_asmdata.getdatalabel(namelab);
            l:=length(R.name);
            maybe_new_object_file(current_asmdata.asmlists[al_const]);
            current_asmdata.asmlists[al_const].concat(tai_align.create(const_align(sizeof(aint))));
            current_asmdata.asmlists[al_const].concat(tai_const.create_aint(-1));
            current_asmdata.asmlists[al_const].concat(tai_const.create_aint(l));
            current_asmdata.asmlists[al_const].concat(tai_label.create(namelab));
            getmem(s,l+1);
            move(R.Name[1],s^,l);
            s[l]:=#0;
            current_asmdata.asmlists[al_const].concat(tai_string.create_pchar(s,l));
            current_asmdata.asmlists[al_const].concat(tai_const.create_8bit(0));

            {
              Resourcestring index:

                  TResourceStringRecord = Packed Record
                     Name,
                     CurrentValue,
                     DefaultValue : AnsiString;
                     HashValue    : LongWord;
                   end;
            }
            new_section(current_asmdata.asmlists[al_resourcestrings],sec_fpc_resstr_index,r.name,sizeof(aint));
            resstrlab:=current_asmdata.newasmsymbol(make_mangledname('RESSTR',R.Sym.owner,R.Sym.name),AB_GLOBAL,AT_DATA);
            current_asmdata.asmlists[al_resourcestrings].concat(tai_symbol.Create_global(resstrlab,0));
            current_asmdata.asmlists[al_resourcestrings].concat(tai_const.create_sym(namelab));
            current_asmdata.asmlists[al_resourcestrings].concat(tai_const.create_sym(nil));
            current_asmdata.asmlists[al_resourcestrings].concat(tai_const.create_sym(valuelab));
            current_asmdata.asmlists[al_resourcestrings].concat(tai_const.create_32bit(longint(R.Hash)));
            current_asmdata.asmlists[al_resourcestrings].concat(tai_symbol_end.create(resstrlab));
            R:=TResourceStringItem(R.Next);
          end;
      end;


    Procedure Tresourcestrings.WriteResourceFile;
      Type
        TMode = (quoted,unquoted);
      Var
        F : Text;
        Mode : TMode;
        R : TResourceStringItem;
        C : char;
        Col,i : longint;
        ResFileName : string;

        Procedure Add(Const S : String);
        begin
          Write(F,S);
          inc(Col,length(s));
        end;

      begin
        If List.Empty then
          exit;
        ResFileName:=ForceExtension(current_module.ppufilename^,'.rst');
        message1 (general_i_writingresourcefile,SplitFileName(ResFileName));
        Assign(F,ResFileName);
        {$i-}
        Rewrite(f);
        {$i+}
        If IOresult<>0 then
          begin
            message1(general_e_errorwritingresourcefile,ResFileName);
            exit;
          end;
        R:=TResourceStringItem(List.First);
        while assigned(R) do
          begin
            writeln(f);
            Writeln(f,'# hash value = ',R.Hash);
            col:=0;
            Add(R.Name+'=');
            Mode:=unquoted;
            For I:=0 to R.Len-1 do
             begin
               C:=R.Value[i];
               If (ord(C)>31) and (Ord(c)<=128) and (c<>'''') then
                begin
                  If mode=Quoted then
                   Add(c)
                  else
                   begin
                     Add(''''+c);
                     mode:=quoted
                   end;
                end
               else
                begin
                  If Mode=quoted then
                   begin
                     Add('''');
                     mode:=unquoted;
                   end;
                  Add('#'+tostr(ord(c)));
                end;
               If Col>72 then
                begin
                  if mode=quoted then
                   Write (F,'''');
                  Writeln(F,'+');
                  Col:=0;
                  Mode:=unQuoted;
                end;
             end;
            if mode=quoted then
             writeln (f,'''');
            Writeln(f);
            R:=TResourceStringItem(R.Next);
          end;
        close(f);
      end;


    procedure Tresourcestrings.ConstSym_Register(p:tnamedindexitem;arg:pointer);
      begin
        if (tsym(p).typ=constsym) and
           (tconstsym(p).consttyp=constresourcestring) then
          List.Concat(tResourceStringItem.Create(TConstsym(p)));
      end;


    procedure Tresourcestrings.RegisterResourceStrings;
      begin
        if assigned(current_module.globalsymtable) then
          current_module.globalsymtable.foreach(@ConstSym_Register,nil);
        current_module.localsymtable.foreach(@ConstSym_Register,nil);
        if List.Empty then
          exit;
      end;


    Procedure GenerateResourceStrings;
      var
        resstrs : Tresourcestrings;
      begin
        resstrs:=Tresourcestrings.Create;
        resstrs.RegisterResourceStrings;
        resstrs.CreateResourceStringData;
        resstrs.WriteResourceFile;
        resstrs.Free;
      end;

end.
