{ %OPT=-Nu }
var
  i : integer;
  s : single;

begin
  s:=0.0;
  for i:=1 to 10 do
    s:=s+1;
  for i:=1 to 11 do
    s:=s+1;
  if s<>21 then
    halt(1);
  writeln('ok');
end.
