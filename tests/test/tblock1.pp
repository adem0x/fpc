{ %target=darwin,iphonesim}
{ %skipcpu=powerpc,powerpc64 }

{$modeswitch cblocks}

type
  tblock = reference to procedure; cdecl;

procedure test(b: tblock);
  begin
    b;
  end;

procedure proc;
  begin
    writeln('called as block');
  end;

const
  bconst: tblock = @proc;

var
  b: tblock;
begin
  b:=@proc;
  b;
  test(@proc);
  test(b);
  bconst;
  test(bconst);
end.

