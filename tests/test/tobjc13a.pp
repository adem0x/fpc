{ %fail }
{ %target=darwin }
{ %cpu=powerpc,i386 }
{ %norun }

{$mode objfpc}
{$modeswitch objectivec1}

type
  ta = objcclass(NSObject)
    procedure test2(l: longint); varargs; message 'class:';
  end;

  procedure ta.test2(l: longint);
   begin
   end;

begin
end.
