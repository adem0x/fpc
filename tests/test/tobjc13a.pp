{ %fail }
{ %target=darwin }
{ %cpu=powerpc,powerpc64,i386,x86_64,arm }
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
