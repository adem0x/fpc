program test;

var
  wa, ws : set of 1..9;
begin
  wa := [1..2];
  ws := [1..3];
  if (wa <= ws) and (wa <> ws) then writeln('True') else begin writeln('False'); halt(1) end;
  if (wa <= ws) then
    if (wa <> ws) then writeln('True') else begin writeln('False'); halt(2); end
  else halt(3);
  if (wa <= ws) then writeln('True') else begin writeln('False'); halt(4); end;
  if (wa <> ws) then writeln('True') else begin writeln('False'); halt(5); end;

end.

