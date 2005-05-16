{*****************************************************************************}
{
    $Id: fpreadpnm.pp,v 1.5 2005/02/14 17:13:12 peter Exp $
    This file is part of the Free Pascal's "Free Components Library".
    Copyright (c) 2003 by Mazen NEIFER of the Free Pascal development team

    PNM writer implementation.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
{*****************************************************************************}

{
The PNM (Portable aNyMaps) is a generic name for :
  PBM : Portable BitMaps,
  PGM : Portable GrayMaps,
  PPM : Portable PixMaps.
There is no file format associated  with PNM itself.}

{$mode objfpc}{$h+}
unit FPReadPNM;

interface

uses FPImage, classes, sysutils;

type
  TFPReaderPNM=class (TFPCustomImageReader)
    private
      FBitMapType : Integer;
      FWidth      : Integer;
      FHeight     : Integer;
    protected
      FMaxVal     : Integer;
      FBitPP        : Byte;
      FScanLineSize : Integer;
      FScanLine   : PByte;
      procedure ReadHeader(Stream : TStream);
      function  InternalCheck (Stream:TStream):boolean;override;
      procedure InternalRead(Stream:TStream;Img:TFPCustomImage);override;
      procedure ReadScanLine(Row : Integer; Stream:TStream);
      procedure WriteScanLine(Row : Integer; Img : TFPCustomImage);
  end;

implementation

function TFPReaderPNM.InternalCheck(Stream:TStream):boolean;

begin
  InternalCheck:=True;
end;

const
  WhiteSpaces=[#9,#10,#13,#32]; {Whitespace (TABs, CRs, LFs, blanks) are separators in the PNM Headers}

function DropWhiteSpaces(Stream : TStream) :Char;

begin
  with Stream do
    begin
    repeat
      ReadBuffer(DropWhiteSpaces,1);
{If we encounter comment then eate line}
      if DropWhiteSpaces='#' then
      repeat
        ReadBuffer(DropWhiteSpaces,1);
      until DropWhiteSpaces=#10;
    until not(DropWhiteSpaces in WhiteSpaces);
    end;
end;

function ReadInteger(Stream : TStream) :Integer;

var
  s:String[7];

begin
  s:='';
  s[1]:=DropWhiteSpaces(Stream);
  with Stream do
    repeat
      Inc(s[0]);
      ReadBuffer(s[Length(s)+1],1)
    until s[Length(s)+1] in WhiteSpaces;
  Result:=StrToInt(s);
end;

procedure TFPReaderPNM.ReadHeader(Stream : TStream);

Var
  C : Char;

begin
  Stream.ReadBuffer(C,1);
  If (C<>'P') then
    Raise Exception.Create('Not a valid PNM image.');
  Stream.ReadBuffer(C,1);
  FBitmapType:=Ord(C)-Ord('0');
  If Not (FBitmapType in [1..6]) then
    Raise Exception.CreateFmt('Unknown PNM subtype : %s',[C]);
  FWidth:=ReadInteger(Stream);
  FHeight:=ReadInteger(Stream);
  if FBitMapType in [1,4]
  then
    FMaxVal:=1
  else
    FMaxVal:=ReadInteger(Stream);
  If (FWidth<=0) or (FHeight<=0) or (FMaxVal<=0) then
    Raise Exception.Create('Invalid PNM header data');
  case FBitMapType of
    1: FBitPP := SizeOf(Word);
    2: FBitPP := 8 * SizeOf(Word);   // Grayscale (text)
    3: FBitPP := 8 * SizeOf(Word)*3; // RGB (text)
    4: FBitPP := 1; // 1bit PP (row)
    5: If (FMaxval>255) then   // Grayscale (raw);
         FBitPP:= 8 * 2
       else
         FBitPP:= 8;
    6: if (FMaxVal>255) then    // RGB (raw)
         FBitPP:= 8 * 6
       else
         FBitPP:= 8 * 3
  end;
//  Writeln(FWidth,'x',Fheight,' Maxval: ',FMaxVal,' BitPP: ',FBitPP);
end;

procedure TFPReaderPNM.InternalRead(Stream:TStream;Img:TFPCustomImage);

var
  Row,Coulumn,nBpLine,ReadSize:Integer;
  aColor:TFPcolor;
  aLine:PByte;

begin
  ReadHeader(Stream);
  Img.SetSize(FWidth,FHeight);
  FScanLineSize:=FBitPP*((FWidth+7)shr 3);
  GetMem(FScanLine,FScanLineSize);
  try
    for Row:=0 to img.Height-1 do
      begin
      ReadScanLine(Row,Stream);
      WriteScanLine(Row,Img);
      end;
  finally
    FreeMem(FScanLine);
  end;
end;

procedure TFPReaderPNM.ReadScanLine(Row : Integer; Stream:TStream);

Var
  P : PWord;
  I,j : Integer;

begin
  Case FBitmapType of
    1 : begin
        P:=PWord(FScanLine);
        For I:=0 to ((FWidth+7)shr 3)-1 do
          begin
            P^:=0;
            for j:=0 to 7 do
              P^:=(P^ shr 1)or ReadInteger(Stream);
            Inc(P);
          end;
        end;
    2 : begin
        P:=PWord(FScanLine);
        For I:=0 to FWidth-1 do
          begin
          P^:=ReadInteger(Stream);
          Inc(P);
          end;
        end;
    3 : begin
        P:=PWord(FScanLine);
        For I:=0 to FWidth-1 do
          begin
          P^:=ReadInteger(Stream); // Red
          Inc(P);
          P^:=ReadInteger(Stream); // Green
          Inc(P);
          P^:=ReadInteger(Stream); // Blue;
          Inc(P)
          end;
        end;
    4,5,6 : Stream.ReadBuffer(FScanLine^,FScanLineSize);
    end;
end;


procedure TFPReaderPNM.WriteScanLine(Row : Integer; Img : TFPCustomImage);

Var
  C : TFPColor;
  L : Cardinal;
  FHalfMaxVal : Word;

  Procedure ByteBnWScanLine;

  Var
    P : PByte;
    I,j,x : Integer;

  begin
    P:=PByte(FScanLine);
    x:=7;
    For I:=0 to ((FWidth+7)shr 3)-1 do
      begin
      L:=P^;
      for j:=0 to 7 do
        begin
          if odd(L)
          then
            Img.Colors[x,Row]:=colBlack
          else
            Img.Colors[x,Row]:=colWhite;
          L:=L shr 1;
          dec(x);
        end;
      Inc(P);
      Inc(x,16);
      end;
  end;

  Procedure WordGrayScanLine;

  Var
    P : PWord;
    I : Integer;

  begin
    P:=PWord(FScanLine);
    For I:=0 to FWidth-1 do
      begin
      L:=(((P^ shl 16)+FHalfMaxVal) div FMaxVal) and $FFFF;
      C.Red:=L;
      C.Green:=L;
      C.Blue:=L;
      Img.Colors[I,Row]:=C;
      Inc(P);
      end;
  end;

  Procedure WordRGBScanLine;

  Var
    P : PWord;
    I : Integer;

  begin
    P:=PWord(FScanLine);
    For I:=0 to FWidth-1 do
      begin
      L:=(((P^ shl 16)+FHalfMaxVal) div FMaxVal) and $FFFF;
      C.Red:=L;
      Inc(P);
      L:=(((P^ shl 16)+FHalfMaxVal) div FMaxVal) and $FFFF;
      C.Green:=L;
      Inc(P);
      L:=(((P^ shl 16)+FHalfMaxVal) div FMaxVal) and $FFFF;
      C.Blue:=L;
      Img.Colors[I,Row]:=C;
      Inc(P);
      end;
  end;

  Procedure ByteGrayScanLine;

  Var
    P : PByte;
    I : Integer;

  begin
    P:=PByte(FScanLine);
    For I:=0 to FWidth-1 do
      begin
      L:=(((P^ shl 16)+FHalfMaxVal) div FMaxVal) and $FFFF;
      C.Red:=L;
      C.Green:=L;
      C.Blue:=L;
      Img.Colors[I,Row]:=C;
      Inc(P);
      end;
  end;

  Procedure ByteRGBScanLine;

  Var
    P : PByte;
    I : Integer;

  begin
    P:=PByte(FScanLine);
    For I:=0 to FWidth-1 do
      begin
      L:=(((P^ shl 16)+FHalfMaxVal) div FMaxVal) and $FFFF;
      C.Red:=L;
      Inc(P);
      L:=(((P^ shl 16)+FHalfMaxVal) div FMaxVal) and $FFFF;
      C.Green:=L;
      Inc(P);
      L:=(((P^ shl 16)+FHalfMaxVal) div FMaxVal) and $FFFF;
      C.Blue:=L;
      Img.Colors[I,Row]:=C;
      Inc(P);
      end;
  end;

begin
  C.Alpha:=AlphaOpaque;
  FHalfMaxVal:=(FMaxVal div 2);
  Case FBitmapType of
    1 : ;
    2 : WordGrayScanline;
    3 : WordRGBScanline;
    4 : ByteBnWScanLine;
    5 : If FBitPP=1 then
          ByteGrayScanLine
        else
          WordGrayScanLine;
    6 : If FBitPP=3 then
          ByteRGBScanLine
        else
          WordRGBScanLine;
    end;
end;

initialization
  ImageHandlers.RegisterImageReader ('PNM Format', 'PNM;PGM;PBM', TFPReaderPNM);
end.
{
$Log: fpreadpnm.pp,v $
Revision 1.5  2005/02/14 17:13:12  peter
  * truncate log

}
