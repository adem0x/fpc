{
    Copyright (c) 1998-2002 by Jan Bruns

    Handles constant-splitting for ARM

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
UNIT splitconst;


INTERFACE


CONST
maxsplitconstinstr = 4; // 5 Parts can happen with buildSaferConstPartsOffset(,ts in [2,8],)

TYPE 
Tsplitconst = record
  parts : longint;
  part  : ARRAY[0..maxsplitconstinstr] of dword;
  inv : boolean; 
end;

// sc.inv tells if inverted instructions shound be used 
// (MOV->MVN, ORR->BIC, or ADD->SUB)
// it's the same for all needed instructions



    { 
      Build a split constant to be loaded/op'ed.
        
      d : the constant
      allowinvert: instruction in [MOV,ADD,SUB] 
      isformove  : instruction in [MOV]

      So for op in [EOR,AND,BIC,ORR], leave alloinvert false
      To build MOV-constants, use MOV/MVN first, then ORR/BIC
    }
  FUNCTION buildConstParts(d : dword;  VAR sc : Tsplitconst; allowinvert,isformove : boolean) : longint;




    { 
      Build a constant for adress-offsets
      
      ARM supports 12 bit offsets for 1 and 4 byte transfers,
      and 8 Bit offsets for 2 and 8 byte transfers:

      ts : transfersize (either 1,2,4 or 8) : 
    }
  PROCEDURE buildConstPartsOffset(d,ts : longint;  VAR sc : Tsplitconst);





    { 
      Like buildConstPartsOffset, but will limit the direct
      Offset to 2 Bits less then actually supported by the CPU,
      leaving space for adress-ranges (for concatcopy): 
    }
  PROCEDURE buildSaferConstPartsOffset(d,ts : longint;  VAR sc : Tsplitconst);



IMPLEMENTATION



FUNCTION shortblockval(d : dword; s : byte) : dword; inline;
BEGIN
  shortblockval := (d shr s) and 3;
END;

FUNCTION byteblockval(d : dword; s : byte; inv : boolean) : dword; inline;
VAR m : dword;
BEGIN
  if inv then d := not(d);
  m := (($FF shl s)or($ff shr (32-s)));
  byteblockval := m and d
END;

FUNCTION testgap(d : dword; s : byte; allowinvert : boolean) : boolean;
VAR r ,i: dword; await : longint;
BEGIN
  testgap := false;
  await := 0;
  r := shortblockval(d,s);
  if (r=1)or(r=2) then exit;
  if (r=3) and not(allowinvert) then exit;
  r := r and 1;
  r := (r+r+r);
  i := s;
  while (await<4) and (r=shortblockval(d,i and 31)) do begin
    i := i + 2;
    await := await + 1;
  end;
  i := i + 8;
  while (await<4) and (r=shortblockval(d,i and 31)) do begin
    i := i + 2;
    await := await + 1;
  end;
  i := i + 8;
  while (await<4) and (r=shortblockval(d,i and 31)) do begin
    i := i + 2;
    await := await + 1;
  end;
  testgap := (await>=4);
END;

PROCEDURE buildConstTo3Instr(d,s : dword; VAR sc : Tsplitconst);
VAR r,i: dword; await,g01 : dword; j : longint;
BEGIN
  await := 0;
  r := shortblockval(d,s) and 1;
  r := (r+r+r);
  i := s;
  sc.inv := (r=3);
  j := 0;
  repeat
    i := s;
    await := 0;
    g01 := i;
    while (await<16) and (r=shortblockval(d,i and 31)) do begin
      i := i + 2;
      await := await + 1;
      g01 := i;
    end;
    if (await<16) then begin
      sc.part[j] := byteblockval(d,g01 and 31,sc.inv);
      if sc.inv then d := d or sc.part[j]
                else d := d and not(sc.part[j]);
      inc(j);
    end;
    s := i + 8;
  until (await=16)or(j=4);

  sc.parts := j;
END;

FUNCTION tryConstTo3Parts(d : dword; VAR sc : Tsplitconst; allowinvert : boolean) : boolean;
VAR i : longint; tmpsc : Tsplitconst;
BEGIN
    { try to split d into 3 parts, that don't bitwise overlap,
      where ech part is always 8 bits in size, and 
        d = part1 or part2 or part3
      or, if allowinvert and sc.inv:
        d = $FFFFFFFF and (not(part1)) and (not(part2)) and (not(part3))  
    }
  tryConstTo3Parts := false;
  sc.parts := 4;
  for i := 0 to 15 do begin
    if testgap(d,i+i,allowinvert) then begin
       { There are at least 4 blocks of 2bits, that are all the same,
         so we're garanteed that we found a solution; 
       }
      buildConstTo3Instr(d,i+i,tmpsc);
      if sc.parts>tmpsc.parts then sc := tmpsc;
      tryConstTo3Parts := true;
    end;
  end;
END;

PROCEDURE buildQuad(d : dword; VAR sc : Tsplitconst);
BEGIN
  with sc do begin
    parts := 4;
    part[0] := d and $FF;
    part[1] := d and $FF00;
    part[2] := d and $FF0000;
    part[3] := d and $FF000000;
    inv := false;
  end;
END;

FUNCTION buildConstParts(d : dword;  VAR sc : Tsplitconst; allowinvert,isformove : boolean) : longint;
VAR sc2 : Tsplitconst;
BEGIN
  if isformove then begin
    if not tryConstTo3Parts(d,sc,allowinvert) then begin
      buildQuad(d,sc);
    end else if (sc.parts=0) then begin
      sc.parts := 1;
      sc.part[0] := 0;
    end;
  end else begin
    if not tryConstTo3Parts(d,sc,false) then buildQuad(d,sc);
    if allowinvert then begin
      if not tryConstTo3Parts(-longint(d),sc2,false) then buildQuad(-longint(d),sc2);
      if sc2.parts<sc.parts then begin
        sc := sc2;
        sc.inv := true;
      end;
    end;
  end;
  buildConstParts := sc.parts;
END;


PROCEDURE buildConstPartsOffset_mask(d,m : longint;  VAR sc : Tsplitconst);
VAR i,j : longint; sc2 : Tsplitconst;
BEGIN
  if not tryConstTo3Parts(d and     m ,sc ,true) then buildQuad(d and     m ,sc );
  if not tryConstTo3Parts(d or  not(m),sc2,true) then buildQuad(d or  not(m),sc2);
  if sc2.parts>=sc.parts then begin
    // s = ssssssssssssssssssss000000000000
    // x = 00000000000000000000xxxxxxxxxxxx  // offset = s+x
    i := d and not(m);
  end else begin
    // s = ssssssssssssssssssss111111111111
    // x = 00000000000000000000xxxxxxxxxxxx  // offset = s-x
    i := -(not(d) and not(m));
    sc := sc2;
  end;
  for j := maxsplitconstinstr downto 1 do begin
    sc.part[j] := sc.part[j-1];
  end;
  sc.part[0] := i;  // if i>=0 then [sum_reg + i] 
                    //         else [sum_reg - abs(i)] = [sum_reg + i]
  inc(sc.parts);
END;


PROCEDURE buildConstPartsOffset(d,ts : longint;  VAR sc : Tsplitconst);
BEGIN
  case ts of
    1,4 : buildConstPartsOffset_mask(d,longint($FFFFF000),sc);
    2,8 : buildConstPartsOffset_mask(d,longint($FFFFFF00),sc);
    else  buildConstPartsOffset_mask(d,longint($FFFFFF00),sc); // errorneous
  end;
END;



PROCEDURE buildSaferConstPartsOffset(d,ts : longint;  VAR sc : Tsplitconst);
BEGIN
  case ts of
    1,4 : buildConstPartsOffset_mask(d,longint($FFFFFC00),sc);
    2,8 : buildConstPartsOffset_mask(d,longint($FFFFFFC0),sc);
    else  buildConstPartsOffset_mask(d,longint($FFFFFFC0),sc); // errorneous
  end;
END;


BEGIN
END.
