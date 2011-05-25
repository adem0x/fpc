{$mode objfpc}
uses
{$ifdef unix}
  cwstring,
{$endif unix}
  SysUtils;

resourcestring
  s = 'Hello world';

begin
   if s<>'Hello world' then
     halt(1);
end.
