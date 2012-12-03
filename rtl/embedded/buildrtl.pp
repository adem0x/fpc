{ This unit is only used to edit the rtl with lazarus }
unit buildrtl;

  interface

    uses
      system, unixtype, ctypes, baseunix, strings, objpas, macpas, syscall, unixutil, heapmgr,
      fpintres, heaptrc, lineinfo, lnfodwrf,
      termio, unix, linux, initc, cmem, mmx,
      crt, printer, linuxvcs,
      sysutils, typinfo, math, matrix, varutils,
      charset, ucomplex, getopts,
      errors, sockets, gpm, ipc, serial, terminfo, dl, dynlibs,
      video, mouse, keyboard, variants, types, dateutils, sysconst, fmtbcd,
      cthreads, classes, fgl, convutils, stdconvs, strutils, rtlconsts, dos, objects, cwstring, fpcylix, clocale,
      exeinfo,
{$ifdef CPUARM}
      stellaris
{$endif CPUARM}
{$ifdef CPUAVR}
      atmega128
{$endif CPUAVR}
{$ifdef CPUAVR32}
      at32uc3b0256es,at32uc3b1256,at32uc3c1512c,at32uc3l032,at32uc3l132,at32uc3l232,at32uc3l332,
      at32uc3b0256,at32uc3c0512c,at32uc3c1512crevc,at32uc3l064,at32uc3l164,at32uc3l264,at32uc3l364,
      at32uc3b1256es,at32uc3c0512crevc,at32uc3l016,at32uc3l116,at32uc3l216,at32uc3l316
{$endif CPUAVR32}
      ;

  implementation

end.
