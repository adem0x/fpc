{
    Copyright (c) 1998-2002 by Florian Klaempfl

    This unit implements some support functions

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published
    by the Free Software Foundation; either version 2 of the License, or
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
{# This unit contains some generic support functions which are used
   in the different parts of the compiler.
}
unit cutils;

{$i fpcdefs.inc}

interface


    type
       pshortstring = ^string;
       Tcharset=set of char;

    var
      internalerrorproc : procedure(i:longint);


    {# Returns the minimal value between @var(a) and @var(b) }
    function min(a,b : longint) : longint;{$ifdef USEINLINE}inline;{$endif}
    function min(a,b : int64) : int64;{$ifdef USEINLINE}inline;{$endif}
    {# Returns the maximum value between @var(a) and @var(b) }
    function max(a,b : longint) : longint;{$ifdef USEINLINE}inline;{$endif}
    function max(a,b : int64) : int64;{$ifdef USEINLINE}inline;{$endif}
    {# Returns the value in @var(x) swapped to different endian }
    Function SwapInt64(x : int64): int64;{$ifdef USEINLINE}inline;{$endif}
    {# Returns the value in @var(x) swapped to different endian }
    function SwapLong(x : longint): longint;{$ifdef USEINLINE}inline;{$endif}
    {# Returns the value in @va(x) swapped to different endian }
    function SwapWord(x : word): word;{$ifdef USEINLINE}inline;{$endif}
    {# Returns the value in @va(x) swapped to different endian }
    Function SwapQWord(x : qword) : qword;{$ifdef USEINLINE}inline;{$endif}
    {# Return value @var(i) aligned on @var(a) boundary }
    function align(i,a:longint):longint;{$ifdef USEINLINE}inline;{$endif}

    function used_align(varalign,minalign,maxalign:shortint):shortint;
    function isbetteralignedthan(new, org, limit: cardinal): boolean;
    function size_2_align(len : longint) : shortint;
    function packedbitsloadsize(bitlen: int64) : int64;
    procedure Replace(var s:string;s1:string;const s2:string);
    procedure Replace(var s:AnsiString;s1:string;const s2:string);
    procedure ReplaceCase(var s:string;const s1,s2:string);
    Function MatchPattern(const pattern,what:string):boolean;
    function upper(const s : string) : string;
    function lower(const s : string) : string;
    function trimbspace(const s:string):string;
    function trimspace(const s:string):string;
    function space (b : longint): string;
    function PadSpace(const s:string;len:longint):string;
    function GetToken(var s:string;endchar:char):string;
    procedure uppervar(var s : string);
    function realtostr(e:extended):string;{$ifdef USEINLINE}inline;{$endif}
    function tostr(i : qword) : string;{$ifdef USEINLINE}inline;{$endif}overload;
    function tostr(i : int64) : string;{$ifdef USEINLINE}inline;{$endif}overload;
    function tostr(i : longint) : string;{$ifdef USEINLINE}inline;{$endif}overload;
    function tostr_with_plus(i : int64) : string;{$ifdef USEINLINE}inline;{$endif}
    function DStr(l:longint):string;
    {# Returns true if the string s is a number }
    function is_number(const s : string) : boolean;{$ifdef USEINLINE}inline;{$endif}
    {# Returns true if value is a power of 2, the actual
       exponent value is returned in power.
    }
    function ispowerof2(value : int64;out power : longint) : boolean;
    function nextpowerof2(value : int64; out power: longint) : int64;
    function backspace_quote(const s:string;const qchars:Tcharset):string;
    function octal_quote(const s:string;const qchars:Tcharset):string;
    function maybequoted(const s:string):string;
    function maybequoted(const s:ansistring):ansistring;

    {# If the string is quoted, in accordance with pascal, it is
       dequoted and returned in s, and the function returns true.
       If it is not quoted, or if the quoting is bad, s is not touched,
       and false is returned.
    }
    function DePascalQuote(var s: string): Boolean;
    function CompareStr(const S1, S2: string): Integer;
    function CompareText(S1, S2: string): integer;

    { releases the string p and assignes nil to p }
    { if p=nil then freemem isn't called          }
    procedure stringdispose(var p : pshortstring);{$ifdef USEINLINE}inline;{$endif}


    { allocates mem for a copy of s, copies s to this mem and returns }
    { a pointer to this mem                                           }
    function stringdup(const s : string) : pshortstring;{$ifdef USEINLINE}inline;{$endif}

    {# Allocates memory for the string @var(s) and copies s as zero
       terminated string to that allocated memory and returns a pointer
       to that mem
    }
    function  strpnew(const s : string) : pchar;

    {# makes the character @var(c) lowercase, with spanish, french and german
       character set
    }
    function lowercase(c : char) : char;

    { makes zero terminated string to a pascal string }
    { the data in p is modified and p is returned     }
    function pchar2pshortstring(p : pchar) : pshortstring;

    { ambivalent to pchar2pshortstring }
    function pshortstring2pchar(p : pshortstring) : pchar;

    { Ansistring (pchar+length) support }
    procedure ansistringdispose(var p : pchar;length : longint);
    function compareansistrings(p1,p2 : pchar;length1,length2 : longint) : longint;
    function concatansistrings(p1,p2 : pchar;length1,length2 : longint) : pchar;

    {Lzw encode/decode to compress strings -> save memory.}
    function minilzw_encode(const s:string):string;
    function minilzw_decode(const s:string):string;


implementation

    uses
      SysUtils;

    var
      uppertbl,
      lowertbl  : array[char] of char;


    function min(a,b : longint) : longint;{$ifdef USEINLINE}inline;{$endif}
    {
      return the minimal of a and b
    }
      begin
         if a<=b then
           min:=a
         else
           min:=b;
      end;


    function min(a,b : int64) : int64;{$ifdef USEINLINE}inline;{$endif}
    {
      return the minimal of a and b
    }
      begin
         if a<=b then
           min:=a
         else
           min:=b;
      end;


    function max(a,b : longint) : longint;{$ifdef USEINLINE}inline;{$endif}
    {
      return the maximum of a and b
    }
      begin
         if a>=b then
           max:=a
         else
           max:=b;
      end;


    function max(a,b : int64) : int64;{$ifdef USEINLINE}inline;{$endif}
    {
      return the maximum of a and b
    }
      begin
         if a>=b then
           max:=a
         else
           max:=b;
      end;


    Function SwapLong(x : longint): longint;{$ifdef USEINLINE}inline;{$endif}
      var
        y : word;
        z : word;
      Begin
        y := x shr 16;
        y := word(longint(y) shl 8) or (y shr 8);
        z := x and $FFFF;
        z := word(longint(z) shl 8) or (z shr 8);
        SwapLong := (longint(z) shl 16) or longint(y);
      End;


    Function SwapInt64(x : int64): int64;{$ifdef USEINLINE}inline;{$endif}
      Begin
        result:=swaplong(longint(hi(x)));
        result:=result or (swaplong(longint(lo(x))) shl 32);
      End;


    Function SwapQWord(x : qword) : qword;{$ifdef USEINLINE}inline;{$endif}
      Begin
        result:=swaplong(longint(hi(x)));
        result:=result or (swaplong(longint(lo(x))) shl 32);
      End;


    Function SwapWord(x : word): word;{$ifdef USEINLINE}inline;{$endif}
      var
        z : byte;
      Begin
        z := x shr 8;
        x := x and $ff;
        x := (x shl 8);
        SwapWord := x or z;
      End;


    function align(i,a:longint):longint;{$ifdef USEINLINE}inline;{$endif}
    {
      return value <i> aligned <a> boundary
    }
      begin
        { for 0 and 1 no aligning is needed }
        if a<=1 then
          result:=i
        else
          begin
            if i<0 then
              result:=((i-a+1) div a) * a
            else
              result:=((i+a-1) div a) * a;
          end;
      end;


    function size_2_align(len : longint) : shortint;
      begin
         if len>16 then
           size_2_align:=32
         else if len>8 then
           size_2_align:=16
         else if len>4 then
           size_2_align:=8
         else if len>2 then
           size_2_align:=4
         else if len>1 then
           size_2_align:=2
         else
           size_2_align:=1;
      end;


    function packedbitsloadsize(bitlen: int64) : int64;
      begin
         case bitlen of
           1,2,4,8:
             result := 1;
           { 10 bits can never be split over 3 bytes via 1-8-1, because it }
           { always starts at a multiple of 10 bits. Same for the others.  }
           3,5,7,9,10,12,16:
             result := 2;
  {$ifdef cpu64bit}
           11,13,14,15,17..26,28,32:
             result := 4;
           else
             result := 8;
  {$else cpu64bit}
           else
             result := 4;
  {$endif cpu64bit}
         end;
      end;


    function isbetteralignedthan(new, org, limit: cardinal): boolean;
      var
        cnt: cardinal;
      begin
        cnt:=2;
        while (cnt <= limit) do
          begin
            if (org and (cnt-1)) > (new and (cnt-1)) then
              begin
                result:=true;
                exit;
              end
            else if (org and (cnt-1)) < (new and (cnt-1)) then
              begin
                result:=false;
                exit;
              end;
            cnt:=cnt*2;
          end;
        result:=false;
      end;


    function used_align(varalign,minalign,maxalign:shortint):shortint;
      begin
        { varalign  : minimum alignment required for the variable
          minalign  : Minimum alignment of this structure, 0 = undefined
          maxalign  : Maximum alignment of this structure, 0 = undefined }
        if (minalign>0) and
           (varalign<minalign) then
         used_align:=minalign
        else
         begin
           if (maxalign>0) and
              (varalign>maxalign) then
            used_align:=maxalign
           else
            used_align:=varalign;
         end;
      end;


    procedure Replace(var s:string;s1:string;const s2:string);
      var
         last,
         i  : longint;
      begin
        s1:=upper(s1);
        last:=0;
        repeat
          i:=pos(s1,upper(s));
          if i=last then
           i:=0;
          if (i>0) then
           begin
             Delete(s,i,length(s1));
             Insert(s2,s,i);
             last:=i;
           end;
        until (i=0);
      end;


    procedure Replace(var s:AnsiString;s1:string;const s2:string);
      var
         last,
         i  : longint;
      begin
        s1:=upper(s1);
        last:=0;
        repeat
          i:=pos(s1,upper(s));
          if i=last then
           i:=0;
          if (i>0) then
           begin
             Delete(s,i,length(s1));
             Insert(s2,s,i);
             last:=i;
           end;
        until (i=0);
      end;


    procedure ReplaceCase(var s:string;const s1,s2:string);
      var
         last,
         i  : longint;
      begin
        last:=0;
        repeat
          i:=pos(s1,s);
          if i=last then
           i:=0;
          if (i>0) then
           begin
             Delete(s,i,length(s1));
             Insert(s2,s,i);
             last:=i;
           end;
        until (i=0);
      end;


    Function MatchPattern(const pattern,what:string):boolean;
      var
        found : boolean;
        i1,i2 : longint;
      begin
        i1:=0;
        i2:=0;
        if pattern='' then
          begin
            result:=(what='');
            exit;
          end;
        found:=true;
        repeat
          inc(i1);
          if (i1>length(pattern)) then
            break;
          inc(i2);
          if (i2>length(what)) then
            break;
          case pattern[i1] of
            '?' :
              found:=true;
            '*' :
              begin
                found:=true;
                if (i1=length(pattern)) then
                 i2:=length(what)
                else
                 if (i1<length(pattern)) and (pattern[i1+1]<>what[i2]) then
                  begin
                    if i2<length(what) then
                     dec(i1)
                  end
                else
                 if i2>1 then
                  dec(i2);
              end;
            else
              found:=(pattern[i1]=what[i2]) or (what[i2]='?');
          end;
        until not found;
        if found then
          begin
            found:=(i2>=length(what)) and
                   (
                    (i1>length(pattern)) or
                    ((i1=length(pattern)) and
                     (pattern[i1]='*'))
                   );
          end;
        result:=found;
      end;


    function upper(const s : string) : string;
    {
      return uppercased string of s
    }
      var
        i  : longint;
      begin
        for i:=1 to length(s) do
          upper[i]:=uppertbl[s[i]];
        upper[0]:=s[0];
      end;


    function lower(const s : string) : string;
    {
      return lowercased string of s
    }
      var
        i : longint;
      begin
        for i:=1 to length(s) do
          lower[i]:=lowertbl[s[i]];
        lower[0]:=s[0];
      end;


    procedure uppervar(var s : string);
    {
      uppercase string s
    }
      var
         i : longint;
      begin
         for i:=1 to length(s) do
          s[i]:=uppertbl[s[i]];
      end;


    procedure initupperlower;
      var
        c : char;
      begin
        for c:=#0 to #255 do
         begin
           lowertbl[c]:=c;
           uppertbl[c]:=c;
           case c of
             'A'..'Z' :
               lowertbl[c]:=char(byte(c)+32);
             'a'..'z' :
               uppertbl[c]:=char(byte(c)-32);
           end;
         end;
      end;


    function DStr(l:longint):string;
      var
        TmpStr : string[32];
        i : longint;
      begin
        Str(l,TmpStr);
        i:=Length(TmpStr);
        while (i>3) do
         begin
           dec(i,3);
           if TmpStr[i]<>'-' then
            insert('.',TmpStr,i+1);
         end;
        DStr:=TmpStr;
      end;


    function trimbspace(const s:string):string;
    {
      return s with all leading spaces and tabs removed
    }
      var
        i,j : longint;
      begin
        j:=1;
        i:=length(s);
        while (j<i) and (s[j] in [#9,' ']) do
         inc(j);
        trimbspace:=Copy(s,j,i-j+1);
      end;



    function trimspace(const s:string):string;
    {
      return s with all leading and ending spaces and tabs removed
    }
      var
        i,j : longint;
      begin
        i:=length(s);
        while (i>0) and (s[i] in [#9,' ']) do
         dec(i);
        j:=1;
        while (j<i) and (s[j] in [#9,' ']) do
         inc(j);
        trimspace:=Copy(s,j,i-j+1);
      end;


    function space (b : longint): string;
      var
       s: string;
      begin
        space[0] := chr(b);
        s[0] := chr(b);
        FillChar (S[1],b,' ');
        space:=s;
      end;


    function PadSpace(const s:string;len:longint):string;
    {
      return s with spaces add to the end
    }
      begin
         if length(s)<len then
          PadSpace:=s+Space(len-length(s))
         else
          PadSpace:=s;
      end;


    function GetToken(var s:string;endchar:char):string;
      var
        i : longint;
        quote : char;
      begin
        GetToken:='';
        s:=TrimSpace(s);
        if (length(s)>0) and
           (s[1] in ['''','"']) then
         begin
           quote:=s[1];
           i:=1;
           while (i<length(s)) do
            begin
              inc(i);
              if s[i]=quote then
               begin
                 { Remove double quote }
                 if (i<length(s)) and
                    (s[i+1]=quote) then
                  begin
                    Delete(s,i,1);
                    inc(i);
                  end
                 else
                  begin
                    GetToken:=Copy(s,2,i-2);
                    Delete(s,1,i);
                    exit;
                  end;
               end;
            end;
           GetToken:=s;
           s:='';
         end
        else
         begin
           i:=pos(EndChar,s);
           if i=0 then
            begin
              GetToken:=s;
              s:='';
              exit;
            end
           else
            begin
              GetToken:=Copy(s,1,i-1);
              Delete(s,1,i);
              exit;
            end;
         end;
      end;


   function realtostr(e:extended):string;{$ifdef USEINLINE}inline;{$endif}
     begin
        str(e,result);
     end;


   function tostr(i : qword) : string;{$ifdef USEINLINE}inline;{$endif}overload;
   {
     return string of value i
   }
     begin
        str(i,result);
     end;


   function tostr(i : int64) : string;{$ifdef USEINLINE}inline;{$endif}overload;
   {
     return string of value i
   }
     begin
        str(i,result);
     end;


   function tostr(i : longint) : string;{$ifdef USEINLINE}inline;{$endif}overload;
   {
     return string of value i
   }
     begin
        str(i,result);
     end;


   function tostr_with_plus(i : int64) : string;{$ifdef USEINLINE}inline;{$endif}
   {
     return string of value i, but always include a + when i>=0
   }
     begin
        str(i,result);
        if i>=0 then
          result:='+'+result;
     end;


    function is_number(const s : string) : boolean;{$ifdef USEINLINE}inline;{$endif}
    {
      is string a correct number ?
    }
      var
         w : integer;
         l : longint;
      begin
         val(s,l,w);
         // remove warning
         l:=l;
         is_number:=(w=0);
      end;


    function ispowerof2(value : int64;out power : longint) : boolean;
    {
      return if value is a power of 2. And if correct return the power
    }
      var
         hl : int64;
         i : longint;
      begin
         if value and (value - 1) <> 0 then
           begin
             ispowerof2 := false;
             exit
           end;
         hl:=1;
         ispowerof2:=true;
         for i:=0 to 63 do
           begin
              if hl=value then
                begin
                   power:=i;
                   exit;
                end;
              hl:=hl shl 1;
           end;
         ispowerof2:=false;
      end;


    function nextpowerof2(value : int64; out power: longint) : int64;
    {
      returns the power of 2 >= value
    }
      var
        i : longint;
      begin
        result := 0;
        power := -1;
        if ((value <= 0) or
            (value >= $4000000000000000)) then
          exit;
        result := 1;
        for i:=0 to 63 do
          begin
            if result>=value then
              begin
                power := i;
                exit;
              end;
            result:=result shl 1;
          end;
      end;


    function backspace_quote(const s:string;const qchars:Tcharset):string;

    var i:byte;

    begin
      backspace_quote:='';
      for i:=1 to length(s) do
        begin
          if (s[i]=#10) and (#10 in qchars) then
            backspace_quote:=backspace_quote+'\n'
          else if (s[i]=#13) and (#13 in qchars) then
            backspace_quote:=backspace_quote+'\r'
          else
            begin
              if s[i] in qchars then
                backspace_quote:=backspace_quote+'\';
              backspace_quote:=backspace_quote+s[i];
            end;
        end;
    end;

    function octal_quote(const s:string;const qchars:Tcharset):string;

    var i:byte;

    begin
      octal_quote:='';
      for i:=1 to length(s) do
        begin
          if s[i] in qchars then
            begin
              if ord(s[i])<64 then
                octal_quote:=octal_quote+'\'+octstr(ord(s[i]),3)
              else
                octal_quote:=octal_quote+'\'+octstr(ord(s[i]),4);
            end
          else
            octal_quote:=octal_quote+s[i];
        end;
    end;

    function maybequoted(const s:ansistring):ansistring;
      const
        {$IFDEF MSWINDOWS}
          FORBIDDEN_CHARS = ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')',
                             '{', '}', '''', '`', '~'];
        {$ELSE}
          FORBIDDEN_CHARS = ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')',
                             '{', '}', '''', ':', '\', '`', '~'];
        {$ENDIF}
      var
        s1 : ansistring;
        i  : integer;
        quoted : boolean;
      begin
        quoted:=false;
        s1:='"';
        for i:=1 to length(s) do
         begin
           case s[i] of
             '"' :
               begin
                 quoted:=true;
                 s1:=s1+'\"';
               end;
             ' ',
             #128..#255 :
               begin
                 quoted:=true;
                 s1:=s1+s[i];
               end;
             else begin
               if s[i] in FORBIDDEN_CHARS then
                 quoted:=True;
               s1:=s1+s[i];
             end;
           end;
         end;
        if quoted then
          maybequoted:=s1+'"'
        else
          maybequoted:=s;
      end;


    function maybequoted(const s:string):string;
      const
        {$IFDEF MSWINDOWS}
          FORBIDDEN_CHARS = ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')',
                             '{', '}', '''', '`', '~'];
        {$ELSE}
          FORBIDDEN_CHARS = ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')',
                             '{', '}', '''', ':', '\', '`', '~'];
        {$ENDIF}
      var
        s1 : string;
        i  : integer;
        quoted : boolean;
      begin
        quoted:=false;
        s1:='"';
        for i:=1 to length(s) do
         begin
           case s[i] of
             '"' :
               begin
                 quoted:=true;
                 s1:=s1+'\"';
               end;
             ' ',
             #128..#255 :
               begin
                 quoted:=true;
                 s1:=s1+s[i];
               end;
             else begin
               if s[i] in FORBIDDEN_CHARS then
                 quoted:=True;
               s1:=s1+s[i];
             end;
           end;
         end;
        if quoted then
          maybequoted:=s1+'"'
        else
          maybequoted:=s;
      end;


    function DePascalQuote(var s: string): Boolean;
      var
        destPos, sourcePos, len: Integer;
        t: string;
        ch: Char;
    begin
      DePascalQuote:= false;
      len:= length(s);
      if (len >= 1) and (s[1] = '''') then
        begin
          {Remove quotes, exchange '' against ' }
          destPos := 0;
          sourcepos:=1;
          while (sourcepos<len) do
            begin
              inc(sourcePos);
              ch := s[sourcePos];
              if ch = '''' then
                begin
                  inc(sourcePos);
                  if (sourcePos <= len) and (s[sourcePos] = '''') then
                    {Add the quote as part of string}
                  else
                    begin
                      SetLength(t, destPos);
                      s:= t;
                      Exit(true);
                    end;
                end;
              inc(destPos);
              t[destPos] := ch;
            end;
        end;
    end;


    function pchar2pshortstring(p : pchar) : pshortstring;
      var
         w,i : longint;
      begin
         w:=strlen(p);
         for i:=w-1 downto 0 do
           p[i+1]:=p[i];
         p[0]:=chr(w);
         pchar2pshortstring:=pshortstring(p);
      end;


    function pshortstring2pchar(p : pshortstring) : pchar;
      var
         w,i : longint;
      begin
         w:=length(p^);
         for i:=1 to w do
           p^[i-1]:=p^[i];
         p^[w]:=#0;
         pshortstring2pchar:=pchar(p);
      end;


    function lowercase(c : char) : char;
       begin
          case c of
             #65..#90 : c := chr(ord (c) + 32);
             #154 : c:=#129;  { german }
             #142 : c:=#132;  { german }
             #153 : c:=#148;  { german }
             #144 : c:=#130;  { french }
             #128 : c:=#135;  { french }
             #143 : c:=#134;  { swedish/norge (?) }
             #165 : c:=#164;  { spanish }
             #228 : c:=#229;  { greek }
             #226 : c:=#231;  { greek }
             #232 : c:=#227;  { greek }
          end;
          lowercase := c;
       end;


    function strpnew(const s : string) : pchar;
      var
         p : pchar;
      begin
         getmem(p,length(s)+1);
         move(s[1],p^,length(s));
         p[length(s)]:=#0;
         result:=p;
      end;


    procedure stringdispose(var p : pshortstring);{$ifdef USEINLINE}inline;{$endif}
      begin
         if assigned(p) then
           begin
             freemem(p);
             p:=nil;
           end;
      end;


    function stringdup(const s : string) : pshortstring;{$ifdef USEINLINE}inline;{$endif}
      begin
         getmem(result,length(s)+1);
         result^:=s;
      end;


    function CompareStr(const S1, S2: string): Integer;
      var
        count, count1, count2: integer;
      begin
        result := 0;
        Count1 := Length(S1);
        Count2 := Length(S2);
        if Count1>Count2 then
          Count:=Count2
        else
          Count:=Count1;
        result := CompareChar(S1[1],S2[1], Count);
        if result=0 then
          result:=Count1-Count2;
      end;


    function CompareText(S1, S2: string): integer;
      begin
        UpperVar(S1);
        UpperVar(S2);
        Result:=CompareStr(S1,S2);
      end;


{*****************************************************************************
                               Ansistring (PChar+Length)
*****************************************************************************}

    procedure ansistringdispose(var p : pchar;length : longint);
      begin
         if assigned(p) then
           begin
             freemem(p);
             p:=nil;
           end;
      end;


    { enable ansistring comparison }
    { 0 means equal }
    { 1 means p1 > p2 }
    { -1 means p1 < p2 }
    function compareansistrings(p1,p2 : pchar;length1,length2 :  longint) : longint;
      var
         i,j : longint;
      begin
         compareansistrings:=0;
         j:=min(length1,length2);
         i:=0;
         while (i<j) do
          begin
            if p1[i]>p2[i] then
             begin
               compareansistrings:=1;
               exit;
             end
            else
             if p1[i]<p2[i] then
              begin
                compareansistrings:=-1;
                exit;
              end;
            inc(i);
          end;
         if length1>length2 then
          compareansistrings:=1
         else
          if length1<length2 then
           compareansistrings:=-1;
      end;


    function concatansistrings(p1,p2 : pchar;length1,length2 : longint) : pchar;
      var
         p : pchar;
      begin
         getmem(p,length1+length2+1);
         move(p1[0],p[0],length1);
         move(p2[0],p[length1],length2+1);
         concatansistrings:=p;
      end;


{*****************************************************************************
                       Ultra basic KISS Lzw (de)compressor
*****************************************************************************}

    {This is an extremely basic implementation of the Lzw algorithm. It
     compresses 7-bit ASCII strings into 8-bit compressed strings.
     The Lzw dictionary is preinitialized with 0..127, therefore this
     part of the dictionary does not need to be stored in the arrays.
     The Lzw code size is allways 8 bit, so we do not need complex code
     that can write partial bytes.}

    function minilzw_encode(const s:string):string;

    var t,u,i:byte;
        c:char;
        data:array[128..255] of char;
        previous:array[128..255] of byte;
        lzwptr:byte;
        next_avail:set of 0..255;

    label l1;

    begin
      minilzw_encode:='';
      if s<>'' then
        begin
          lzwptr:=127;
          t:=byte(s[1]);
          i:=2;
          u:=128;
          next_avail:=[];
          while i<=length(s) do
            begin
              c:=s[i];
              if not(t in next_avail) or (u>lzwptr) then goto l1;
              while (previous[u]<>t) or (data[u]<>c) do
                begin
                  inc(u);
                  if u>lzwptr then goto l1;
                end;
              t:=u;
              inc(i);
              continue;
            l1:
              {It's a pity that we still need those awfull tricks
               with this modern compiler. Without this performance
               of the entire procedure drops about 3 times.}
              inc(minilzw_encode[0]);
              minilzw_encode[length(minilzw_encode)]:=char(t);
              if lzwptr=255 then
                begin
                  lzwptr:=127;
                  next_avail:=[];
                end
              else
                begin
                  inc(lzwptr);
                  data[lzwptr]:=c;
                  previous[lzwptr]:=t;
                  include(next_avail,t);
                end;
              t:=byte(c);
              u:=128;
              inc(i);
            end;
          inc(minilzw_encode[0]);
          minilzw_encode[length(minilzw_encode)]:=char(t);
        end;
    end;

    function minilzw_decode(const s:string):string;

    var oldc,newc,c:char;
        i,j:byte;
        data:array[128..255] of char;
        previous:array[128..255] of byte;
        lzwptr:byte;
        t:string;

    begin
      minilzw_decode:='';
      if s<>'' then
        begin
          lzwptr:=127;
          oldc:=s[1];
          c:=oldc;
          i:=2;
          minilzw_decode:=oldc;
          while i<=length(s) do
            begin
              newc:=s[i];
              if byte(newc)>lzwptr then
                begin
                  t:=c;
                  c:=oldc;
                end
              else
                begin
                  c:=newc;
                  t:='';
                end;
              while c>=#128 do
                begin
                  inc(t[0]);
                  t[length(t)]:=data[byte(c)];
                  byte(c):=previous[byte(c)];
                end;
              inc(minilzw_decode[0]);
              minilzw_decode[length(minilzw_decode)]:=c;
              for j:=length(t) downto 1 do
                begin
                  inc(minilzw_decode[0]);
                  minilzw_decode[length(minilzw_decode)]:=t[j];
                end;
              if lzwptr=255 then
                lzwptr:=127
              else
                begin
                  inc(lzwptr);
                  previous[lzwptr]:=byte(oldc);
                  data[lzwptr]:=c;
                end;
              oldc:=newc;
              inc(i);
            end;
        end;
    end;


    procedure defaulterror(i:longint);
      begin
        writeln('Internal error ',i);
        runerror(255);
      end;


initialization
  internalerrorproc:=@defaulterror;
  initupperlower;
end.
