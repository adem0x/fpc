{ %norun }
{ %opt=-gl }
{$goto on}
library tlib1a;

  procedure p(var a : pointer);
    label
      we;
    begin
    we:
      a:=@we;
    end;

  exports p;

begin
end.
