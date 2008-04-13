uses splitconst;




FUNCTION rebuild(sc :  Tsplitconst) : longint;
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
    j := -1;
    for i := sc.parts-1 downto 0 do begin
      j := j - longint(dword(sc.part[i]));
    end;    
  end;
  rebuild := j;

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


VAR sc : Tsplitconst;
i,j,k : longint;
lens1 : ARRAY[0..4] of dword;
lens2 : ARRAY[0..4] of dword;
lens3 : ARRAY[0..4] of dword;
tests : int64;

BEGIN
  tests := 0;
  for i := 0 to 4 do lens1[i] := 0;
  for i := 0 to 4 do lens2[i] := 0;
  for i := 0 to 4 do lens3[i] := 0;
  k := $1000;
  i := 0;
//  i := $80000000;
//  i := -1000000;
  repeat
    repeat
      buildConstParts(i,sc,false,true);
      j := rebuild(sc);
      inc(lens1[sc.parts]);
      if not(j=i) then begin
        writeln('ERROR1 ',i,' Result=',j);
        halt(1);
      end;

      buildConstParts(i,sc,true,true);
      j := rebuild(sc);
      inc(lens2[sc.parts]);
      if not(j=i) then begin
        writeln('ERROR2 ',i,' Result=',j,'#',sc.parts,sc.inv);
        halt(2);
      end;

      buildConstPartsOffset(i,4,sc);
      j := rebuild_offset(sc);
      inc(lens3[sc.parts]);
      if not(j=i) then begin 
        writeln('ERROR3 ',i,' Result=',j); 
        halt(3); 
      end;

      tests := tests + 1;
      inc(i);
    until (i=k); 

    write('mask $',hexstr(k-1,8));
    write(' (noinvert) = ');
    for j := 1 to 4 do begin
      if lens1[j]=0 then write(j,':',' NEVER , ')
                    else write(j,':',(100/tests*lens1[j]):6:2,'%, ');
    end;
    writeln;

    write('mask $',hexstr(k-1,8));
    write(' (with inv) = ');
    for j := 1 to 4 do begin
      if lens2[j]=0 then write(j,':',' NEVER , ')
                    else write(j,':',(100/tests*lens2[j]):6:2,'%, ');
    end;
    writeln;

    write('mask $',hexstr(k-1,8));
    write(' (addrops ) = ');
    for j := 1 to 4 do begin
      if lens3[j]=0 then write(j,':',' NEVER , ')
                    else write(j,':',(100/tests*lens3[j]):6:2,'%, ');
    end;

    writeln;
    writeln;


    k := k shl 1;
  until (k=0)and(i=0);
  halt(0);
END.




