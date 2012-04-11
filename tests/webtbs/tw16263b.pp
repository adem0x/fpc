{ %target=darwin,linux,freebsd,solaris,beos,haiku,aix }
{ %NEEDLIBRARY }

{$mode delphi}
program MainApp;

uses
  dynlibs,
  Math;

const
{$ifdef windows}
  libname='tw16263a.dll';
{$else}
  {$ifdef darwin}
  libname = './libtw16263a.dylib';
  {$else darwin}
  libname = './libtw16263a.so';
  {$endif darwin}
{$endif}

var
  hdl: TLibHandle; 
begin
  // the library will perform a div-by-zero in its init code
  setexceptionmask([exZeroDivide]);
  hdl := loadlibrary(libname);
  if (hdl=nilhandle) then
    halt(1);
  unloadlibrary(hdl);
end.
