unit uw6822a;
{$mode objfpc}{$H+}

interface

implementation

var
  t: text;

initialization
  writeln('Unit 1');
  writeln('initialization');
finalization
  writeln('Unit 1'); // problem
  writeln('finalization'); 
  assign(t,'uw6822a.txt');
  rewrite(t);
  close(t);
end.
