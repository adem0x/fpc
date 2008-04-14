uses splitconst;




FUNCTION rebuildMOV(sc :  Tsplitconst) : longint;
VAR i,j : longint;
BEGIN
  if (sc.parts=0) then begin
    writeln('ERROR: Got a 0-length constant for MOV');
    halt(15);
  end else if not sc.inv then begin
    j := 0;
    for i := sc.parts-1 downto 0 do begin
      j := j + longint(dword(sc.part[i]));
    end;
  end else begin
    j := -1;
    for i := sc.parts-1 downto 0 do begin
      j := j and not(sc.part[i]);
    end;    
  end;
  rebuildMOV := j;
END;


FUNCTION rebuildADD(sc :  Tsplitconst) : longint;
VAR i,j : longint;
BEGIN
  if (sc.parts=0) then begin
    j := 0;
  end else if not sc.inv then begin
    j := 0;
    for i := sc.parts-1 downto 0 do begin
      j := j + longint(dword(sc.part[i]));
    end;
  end else begin
    j := 0;
    for i := sc.parts-1 downto 0 do begin
      j := j - longint(dword(sc.part[i]));
    end;    
  end;
  rebuildADD := j;
END;


FUNCTION rebuildORR(sc :  Tsplitconst) : longint;
VAR i,j : longint;
BEGIN
  if (sc.parts=0) then begin
    j := 0;
  end else if not sc.inv then begin
    j := 0;
    for i := sc.parts-1 downto 0 do begin
      j := j + longint(dword(sc.part[i]));
    end;
  end else begin
    writeln('ERROR: Got a INV-constant for logical mode');
    halt(16);
  end;
  rebuildORR := j;
END;



FUNCTION rebuild_offset(sc :  Tsplitconst) : longint;
VAR i,j : longint;
BEGIN
  if sc.parts=0 then begin
    j := 0;
  end else if not sc.inv then begin
    j := 0;
    for i := sc.parts-1 downto 1 do begin
      j := j + longint(dword(sc.part[i]));
    end;
    j := j + longint(sc.part[0]);
  end else begin
    j := -1;
    for i := sc.parts-1 downto 1 do begin
      j := j - longint(dword(sc.part[i]));
    end;    
    j := j + longint(sc.part[0]);
  end;
  rebuild_offset := j;
END;

TYPE Tarr = ARRAY[0..5] of dword;

PROCEDURE printresult(s : string; k : longint; tests : int64; VAR lens : Tarr);
VAR j : longint;
BEGIN
  write('$',hexstr(k-1,8));
  write(' ('+s+') = ');
  for j := 1 to 5 do begin
    if lens[j]=0 then write(j,':',' NEVER , ')
                 else write(j,':',(100/tests*lens[j]):6:2,'%, ');
  end;
  writeln;
END;

FUNCTION checkbounds(var sc : Tsplitconst; n : longint) : boolean;
VAR i : longint;
BEGIN
  i := longint(sc.part[0]);
  case n of
    12 : checkbounds := (i>-4096)and(i<4096);
    10 : checkbounds := (i>-1024)and(i<1024);
     8 : checkbounds := (i> -256)and(i< 256);
     6 : checkbounds := (i>  -64)and(i<  64);
  end;
END;

VAR sc : Tsplitconst;
i,j,k : longint;
lens1,lens2,lens3,lens4,lens5,lens6,lens7 : Tarr;
tests : int64;

BEGIN
  tests := 0;
  for i := 0 to 4 do lens1[i] := 0;
  for i := 0 to 4 do lens2[i] := 0;
  for i := 0 to 4 do lens3[i] := 0;
  for i := 0 to 4 do lens4[i] := 0;
  for i := 0 to 4 do lens5[i] := 0;
  for i := 0 to 4 do lens6[i] := 0;
  for i := 0 to 4 do lens7[i] := 0;
  k := $10;
  i := 0;
//  i := $80000000;
//  i := -1000000;
  repeat
    repeat


      buildConstParts(i,sc,true,true);
      j := rebuildMOV(sc);
      inc(lens1[sc.parts]);
      if not(j=i) then begin
        writeln('ERROR1 ',i,' Result=',j,'#',sc.parts,sc.inv);
        halt(1);
      end;


      buildConstParts(i,sc,false,false);
      j := rebuildORR(sc);
      inc(lens2[sc.parts]);
      if not(j=i) then begin
        writeln('ERROR2 ',i,' Result=',j);
        halt(2);
      end;

      buildConstParts(i,sc,true,false);
      j := rebuildADD(sc);
      inc(lens3[sc.parts]);
      if not(j=i) then begin
        writeln('ERROR3 ',i,' Result=',j);
        halt(3);
      end;

      buildConstPartsOffset(i,4,sc);
      j := rebuild_offset(sc);
      inc(lens4[sc.parts]);
      if not(j=i) or not(checkbounds(sc,12)) then begin 
        writeln('ERROR4 ',i,' Result=',j); 
        halt(4); 
      end;

      buildSaferConstPartsOffset(i,4,sc);
      j := rebuild_offset(sc);
      inc(lens5[sc.parts]);
      if not(j=i) or not(checkbounds(sc,10)) then begin 
        writeln('ERROR5 ',i,' Result=',j); 
        halt(5); 
      end;

      buildConstPartsOffset(i,2,sc);
      j := rebuild_offset(sc);
      inc(lens6[sc.parts]);
      if not(j=i) or not(checkbounds(sc,8)) then begin 
        writeln('ERROR6 ',i,' Result=',j); 
        halt(6); 
      end;

      buildSaferConstPartsOffset(i,2,sc);
      j := rebuild_offset(sc);
      inc(lens7[sc.parts]);
      if not(j=i) or not(checkbounds(sc,6)) then begin 
        writeln('ERROR7 ',i,' Result=',j); 
        halt(7); 
      end;

      tests := tests + 1;
      inc(i);
    until (i=k); 


    printresult('    MOV',k,tests,lens1);
    printresult('logical',k,tests,lens2);
    printresult('ADD/SUB',k,tests,lens3);
    printresult('Offs.12',k,tests,lens4);
    printresult('Offs.10',k,tests,lens5);
    printresult('Offs. 8',k,tests,lens6);
    printresult('Offs. 6',k,tests,lens7);

    writeln;


    k := k shl 1;
  until (k=0)and(i=0);
  halt(0);
END.




