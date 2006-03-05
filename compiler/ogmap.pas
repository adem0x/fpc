{
    Copyright (c) 2001-2002 by Peter Vreman

    Contains the class for generating a map file

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
unit ogmap;

{$i fpcdefs.inc}

interface

    uses
       { common }
       cclasses,globtype,systems,
       { object writer }
       aasmbase,ogbase
       ;

    type
       texemap = class
       private
         t : text;
         FImageBase : aint;
       public
         constructor Create(const s:string);
         destructor Destroy;override;
         procedure Add(const s:string);
         procedure AddHeader(const s:string);
         procedure AddCommonSymbolsHeader;
         procedure AddCommonSymbol(p:TObjSymbol);
         procedure AddMemoryMapHeader(abase:aint);
         procedure AddMemoryMapExeSection(p:texesection);
         procedure AddMemoryMapObjectSection(p:TObjSection);
         procedure AddMemoryMapSymbol(p:TObjSymbol);
       end;

    var
      exemap : texemap;


implementation

    uses
      cutils,globals,verbose;


{****************************************************************************
                                  TExeMap
****************************************************************************}

     constructor TExeMap.Create(const s:string);
       begin
         Assign(t,FixFileName(s));
         Rewrite(t);
         FImageBase:=0;
       end;


     destructor TExeMap.Destroy;
       begin
         Close(t);
       end;


     procedure TExeMap.Add(const s:string);
       begin
         writeln(t,s);
       end;


     procedure TExeMap.AddHeader(const s:string);
       begin
         Add('');
         Add(s);
       end;


     procedure TExeMap.AddCommonSymbolsHeader;
       begin
         AddHeader('Allocating common symbols');
         Add('Common symbol       size              file');
         Add('');
       end;


     procedure TExeMap.AddCommonSymbol(p:TObjSymbol);
       var
         s : string;
       begin
         { Common symbol       size              file }
         s:=p.name;
         if length(s)>20 then
          begin
            writeln(t,p.name);
            s:='';
          end;
         Add(PadSpace(s,20)+'0x'+PadSpace(hexstr(p.size,1),16)+p.objsection.objdata.name);
       end;


     procedure TExeMap.AddMemoryMapHeader(abase:aint);
       var
         imagebasestr : string;
       begin
         FImageBase:=abase;
         if FImageBase<>0 then
           imagebasestr:=' (ImageBase='+HexStr(FImageBase,sizeof(aint)*2)+')'
         else
           imagebasestr:='';
         AddHeader('Memory map'+imagebasestr);
         Add('');
       end;


     procedure TExeMap.AddMemoryMapExeSection(p:texesection);
       begin
         { .text           0x000018a8     0xd958 }
         Add(PadSpace(p.name,18)+PadSpace('0x'+HexStr(p.mempos+Fimagebase,sizeof(aint)*2),12)+
             '0x'+HexStr(p.size,sizeof(aint)));
       end;


     procedure TExeMap.AddMemoryMapObjectSection(p:TObjSection);
       begin
         { .text           0x000018a8     0xd958     object.o }
         Add(' '+PadSpace(p.name,17)+PadSpace('0x'+HexStr(p.mempos+FImageBase,sizeof(aint)*2),12)+
             '0x'+HexStr(p.size,sizeof(aint))+' '+p.objdata.name);
       end;


     procedure TExeMap.AddMemoryMapSymbol(p:TObjSymbol);
       begin
         {                 0x00001e30                setup_screens }
         Add(Space(18)+PadSpace('0x'+HexStr(p.address+Fimagebase,sizeof(aint)*2),26)+p.name);
       end;

end.
