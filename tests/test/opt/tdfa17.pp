{ %OPT=-Oodfa -Sew -vw -S2 }
function f(var i : longint) : boolean;
  begin
    result:=true;
    i:=0;
  end;

var
  i : longint;

begin
  while f(i) do
    halt(i);
end.
