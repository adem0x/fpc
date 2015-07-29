{
    Copyright (c) 2008 by the Free Pascal development team

    Basic Processor information for the AVR

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

Unit CPUInfo;

Interface

  uses
    globtype;

Type
   bestreal = double;
{$if FPC_FULLVERSION>20700}
   bestrealrec = TDoubleRec;
{$endif FPC_FULLVERSION>20700}
   ts32real = single;
   ts64real = double;
   ts80real = type extended;
   ts128real = type extended;
   ts64comp = comp;

   pbestreal=^bestreal;

   { possible supported processors for this target }
   tcputype =
      (cpu_none,
       cpu_avr1,
       cpu_avr2,
       cpu_avr25,
       cpu_avr3,
       cpu_avr31,
       cpu_avr35,
       cpu_avr4,
       cpu_avr5,
       cpu_avr51,
       cpu_avr6
      );

   tfputype =
     (fpu_none,
      fpu_soft,
      fp_libgcc
     );

   tcontrollertype =
     (ct_none,

      ct_avrsim,

      ct_atmega645,
      ct_atmega165a,
      ct_attiny44a,
      ct_atmega649a,
      ct_atmega32u4,
      ct_attiny26,
      ct_at90usb1287,
      ct_at90pwm161,
      ct_attiny48,
      ct_atmega168p,
      ct_attiny10,
      ct_attiny84a,
      ct_at90usb82,
      ct_attiny2313,
      ct_attiny461,
      ct_atmega3250pa,
      ct_atmega3290a,
      ct_atmega165p,
      ct_attiny43u,
      ct_at90usb162,
      ct_atmega16u4,
      ct_attiny24a,
      ct_atmega88p,
      ct_attiny88,
      ct_atmega6490p,
      ct_attiny40,
      ct_atmega324p,
      ct_attiny167,
      ct_atmega328,
      ct_attiny861,
      ct_attiny85,
      ct_atmega64m1,
      ct_atmega645p,
      ct_atmega8u2,
      ct_atmega329a,
      ct_atmega8a,
      ct_atmega324pa,
      ct_atmega32hvb,
      ct_at90pwm316,
      ct_at90pwm3b,
      ct_at90usb646,
      ct_attiny20,
      ct_atmega16,
      ct_atmega48a,
      ct_attiny24,
      ct_atmega644,
      ct_atmega1284,
      ct_ata6285,
      ct_at90can64,
      ct_atmega48,
      ct_at90can32,
      ct_attiny9,
      ct_attiny87,
      ct_atmega1281,
      ct_at90pwm216,
      ct_atmega3250a,
      ct_atmega88a,
      ct_atmega128rfa1,
      ct_atmega3290pa,
      ct_at90pwm81,
      ct_atmega325p,
      ct_attiny84,
      ct_atmega328p,
      ct_attiny13a,
      ct_atmega8,
      ct_atmega1284p,
      ct_atmega16u2,
      ct_attiny45,
      ct_atmega3250,
      ct_atmega329,
      ct_atmega32a,
      ct_attiny5,
      ct_at90can128,
      ct_atmega6490,
      ct_atmega8515,
      ct_atmega88pa,
      ct_atmega168a,
      ct_atmega128,
      ct_at90usb1286,
      ct_atmega164pa,
      ct_attiny828,
      ct_atmega88,
      ct_atmega645a,
      ct_atmega3290p,
      ct_atmega644p,
      ct_atmega164a,
      ct_attiny4313,
      ct_atmega162,
      ct_atmega32c1,
      ct_atmega128a,
      ct_atmega324a,
      ct_attiny13,
      ct_atmega2561,
      ct_atmega169a,
      ct_attiny261,
      ct_atmega644a,
      ct_atmega3290,
      ct_atmega64a,
      ct_atmega169p,
      ct_atmega2560,
      ct_atmega32,
      ct_attiny861a,
      ct_attiny28,
      ct_atmega48p,
      ct_atmega8535,
      ct_atmega168pa,
      ct_atmega16m1,
      ct_atmega16hvb,
      ct_atmega164p,
      ct_atmega325a,
      ct_atmega640,
      ct_atmega6450,
      ct_atmega329p,
      ct_ata6286,
      ct_at90usb647,
      ct_atmega168,
      ct_atmega6490a,
      ct_atmega32m1,
      ct_atmega64c1,
      ct_atmega32u2,
      ct_attiny4,
      ct_atmega644pa,
      ct_at90pwm1,
      ct_attiny44,
      ct_atmega325pa,
      ct_atmega6450a,
      ct_attiny2313a,
      ct_atmega329pa,
      ct_attiny461a,
      ct_atmega6450p,
      ct_atmega64,
      ct_atmega165pa,
      ct_atmega16a,
      ct_atmega649,
      ct_atmega1280,
      ct_at90pwm2b,
      ct_atmega649p,
      ct_atmega3250p,
      ct_atmega48pa,
      ct_attiny1634,
      ct_atmega325,
      ct_atmega169pa,
      ct_attiny261a,
      ct_attiny25
     );

Const
   { Is there support for dealing with multiple microcontrollers available }
   { for this platform? }
   ControllerSupport = true;
   {# Size of native extended floating point type }
   extended_size = 12;
   {# Size of a multimedia register               }
   mmreg_size = 16;
   { target cpu string (used by compiler options) }
   target_cpu_string = 'avr';

   { calling conventions supported by the code generator }
   supported_calling_conventions : tproccalloptions = [
     pocall_internproc,
     pocall_safecall,
     pocall_stdcall,
     { same as stdcall only different name mangling }
     pocall_cdecl,
     { same as stdcall only different name mangling }
     pocall_cppdecl,
     { same as stdcall but floating point numbers are handled like equal sized integers }
     pocall_softfloat
   ];

   cputypestr : array[tcputype] of string[5] = ('',
     'AVR1',
     'AVR2',
     'AVR25',
     'AVR3',
     'AVR31',
     'AVR35',
     'AVR4',
     'AVR5',
     'AVR51',
     'AVR6'
   );

   fputypestr : array[tfputype] of string[6] = (
     'NONE',
     'SOFT',
     'LIBGCC'
   );

    { We know that there are fields after sramsize
      but we don't care about this warning }
   {$WARN 3177 OFF}
   embedded_controllers : array [tcontrollertype] of tcontrollerdatatype =
   ((
        controllertypestr:'';
        controllerunitstr:'';
        flashbase:0;
        flashsize:0;
        srambase:0;
        sramsize:0;
        eeprombase:0;
        eepromsize:0
        ),
        (
        controllertypestr:'AVRSIM';
        controllerunitstr:'AVRSIM';
        flashbase:0;
        flashsize:$20000;
        srambase:0;
        sramsize:4096;
        eeprombase:0;
        eepromsize:4096;
        )
        ,(controllertypestr:'ATMEGA645'; controllerunitstr:'ATMEGA645'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA165A'; controllerunitstr:'ATMEGA165A'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATTINY44A'; controllerunitstr:'ATTINY44A'; flashbase:0; flashsize:4096; srambase:96; sramsize:256; eeprombase:0; eepromsize:256)
        ,(controllertypestr:'ATMEGA649A'; controllerunitstr:'ATMEGA649A'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA32U4'; controllerunitstr:'ATMEGA32U4'; flashbase:0; flashsize:32768; srambase:256; sramsize:2560; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATTINY26'; controllerunitstr:'ATTINY26'; flashbase:0; flashsize:2048; srambase:96; sramsize:128; eeprombase:0; eepromsize:128)
        ,(controllertypestr:'AT90USB1287'; controllerunitstr:'AT90USB1287'; flashbase:0; flashsize:131072; srambase:256; sramsize:8192; eeprombase:0; eepromsize:4096)
        ,(controllertypestr:'AT90PWM161'; controllerunitstr:'AT90PWM161'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATTINY48'; controllerunitstr:'ATTINY48'; flashbase:0; flashsize:4096; srambase:256; sramsize:256; eeprombase:0; eepromsize:64)
        ,(controllertypestr:'ATMEGA168P'; controllerunitstr:'ATMEGA168P'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATTINY10'; controllerunitstr:'ATTINY10'; flashbase:0; flashsize:1024; srambase:64; sramsize:32; eeprombase:0; eepromsize:0)
        ,(controllertypestr:'ATTINY84A'; controllerunitstr:'ATTINY84A'; flashbase:0; flashsize:8192; srambase:96; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'AT90USB82'; controllerunitstr:'AT90USB82'; flashbase:0; flashsize:8192; srambase:256; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATTINY2313'; controllerunitstr:'ATTINY2313'; flashbase:0; flashsize:2048; srambase:96; sramsize:128; eeprombase:0; eepromsize:128)
        ,(controllertypestr:'ATTINY461'; controllerunitstr:'ATTINY461'; flashbase:0; flashsize:4096; srambase:96; sramsize:256; eeprombase:0; eepromsize:256)
        ,(controllertypestr:'ATMEGA3250PA'; controllerunitstr:'ATMEGA3250PA'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATMEGA3290A'; controllerunitstr:'ATMEGA3290A'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATMEGA165P'; controllerunitstr:'ATMEGA165P'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATTINY43U'; controllerunitstr:'ATTINY43U'; flashbase:0; flashsize:4096; srambase:96; sramsize:256; eeprombase:0; eepromsize:64)
        ,(controllertypestr:'AT90USB162'; controllerunitstr:'AT90USB162'; flashbase:0; flashsize:16384; srambase:256; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA16U4'; controllerunitstr:'ATMEGA16U4'; flashbase:0; flashsize:16384; srambase:256; sramsize:1280; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATTINY24A'; controllerunitstr:'ATTINY24A'; flashbase:0; flashsize:2048; srambase:96; sramsize:128; eeprombase:0; eepromsize:128)
        ,(controllertypestr:'ATMEGA88P'; controllerunitstr:'ATMEGA88P'; flashbase:0; flashsize:8192; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATTINY88'; controllerunitstr:'ATTINY88'; flashbase:0; flashsize:8192; srambase:256; sramsize:512; eeprombase:0; eepromsize:64)
        ,(controllertypestr:'ATMEGA6490P'; controllerunitstr:'ATMEGA6490P'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATTINY40'; controllerunitstr:'ATTINY40'; flashbase:0; flashsize:4096; srambase:64; sramsize:256; eeprombase:0; eepromsize:0)
        ,(controllertypestr:'ATMEGA324P'; controllerunitstr:'ATMEGA324P'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATTINY167'; controllerunitstr:'ATTINY167'; flashbase:0; flashsize:16384; srambase:256; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA328'; controllerunitstr:'ATMEGA328'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATTINY861'; controllerunitstr:'ATTINY861'; flashbase:0; flashsize:8192; srambase:96; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATTINY85'; controllerunitstr:'ATTINY85'; flashbase:0; flashsize:8192; srambase:96; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA64M1'; controllerunitstr:'ATMEGA64M1'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA645P'; controllerunitstr:'ATMEGA645P'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA8U2'; controllerunitstr:'ATMEGA8U2'; flashbase:0; flashsize:8192; srambase:256; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA329A'; controllerunitstr:'ATMEGA329A'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATMEGA8A'; controllerunitstr:'ATMEGA8A'; flashbase:0; flashsize:8192; srambase:96; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA324PA'; controllerunitstr:'ATMEGA324PA'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATMEGA32HVB'; controllerunitstr:'ATMEGA32HVB'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'AT90PWM316'; controllerunitstr:'AT90PWM316'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'AT90PWM3B'; controllerunitstr:'AT90PWM3B'; flashbase:0; flashsize:8192; srambase:256; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'AT90USB646'; controllerunitstr:'AT90USB646'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATTINY20'; controllerunitstr:'ATTINY20'; flashbase:0; flashsize:2048; srambase:64; sramsize:128; eeprombase:0; eepromsize:0)
        ,(controllertypestr:'ATMEGA16'; controllerunitstr:'ATMEGA16'; flashbase:0; flashsize:16384; srambase:96; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA48A'; controllerunitstr:'ATMEGA48A'; flashbase:0; flashsize:4096; srambase:256; sramsize:512; eeprombase:0; eepromsize:256)
        ,(controllertypestr:'ATTINY24'; controllerunitstr:'ATTINY24'; flashbase:0; flashsize:2048; srambase:96; sramsize:128; eeprombase:0; eepromsize:128)
        ,(controllertypestr:'ATMEGA644'; controllerunitstr:'ATMEGA644'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA1284'; controllerunitstr:'ATMEGA1284'; flashbase:0; flashsize:131072; srambase:256; sramsize:16384; eeprombase:0; eepromsize:4096)
        ,(controllertypestr:'ATA6285'; controllerunitstr:'ATA6285'; flashbase:0; flashsize:8192; srambase:256; sramsize:512; eeprombase:0; eepromsize:320)
        ,(controllertypestr:'AT90CAN64'; controllerunitstr:'AT90CAN64'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA48'; controllerunitstr:'ATMEGA48'; flashbase:0; flashsize:4096; srambase:256; sramsize:512; eeprombase:0; eepromsize:256)
        ,(controllertypestr:'AT90CAN32'; controllerunitstr:'AT90CAN32'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATTINY9'; controllerunitstr:'ATTINY9'; flashbase:0; flashsize:1024; srambase:64; sramsize:32; eeprombase:0; eepromsize:0)
        ,(controllertypestr:'ATTINY87'; controllerunitstr:'ATTINY87'; flashbase:0; flashsize:8192; srambase:256; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA1281'; controllerunitstr:'ATMEGA1281'; flashbase:0; flashsize:131072; srambase:512; sramsize:8192; eeprombase:0; eepromsize:4096)
        ,(controllertypestr:'AT90PWM216'; controllerunitstr:'AT90PWM216'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA3250A'; controllerunitstr:'ATMEGA3250A'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATMEGA88A'; controllerunitstr:'ATMEGA88A'; flashbase:0; flashsize:8192; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA128RFA1'; controllerunitstr:'ATMEGA128RFA1'; flashbase:0; flashsize:131072; srambase:512; sramsize:16384; eeprombase:0; eepromsize:4096)
        ,(controllertypestr:'ATMEGA3290PA'; controllerunitstr:'ATMEGA3290PA'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'AT90PWM81'; controllerunitstr:'AT90PWM81'; flashbase:0; flashsize:8192; srambase:256; sramsize:256; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA325P'; controllerunitstr:'ATMEGA325P'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATTINY84'; controllerunitstr:'ATTINY84'; flashbase:0; flashsize:8192; srambase:96; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA328P'; controllerunitstr:'ATMEGA328P'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATTINY13A'; controllerunitstr:'ATTINY13A'; flashbase:0; flashsize:1024; srambase:96; sramsize:64; eeprombase:0; eepromsize:64)
        ,(controllertypestr:'ATMEGA8'; controllerunitstr:'ATMEGA8'; flashbase:0; flashsize:8192; srambase:96; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA1284P'; controllerunitstr:'ATMEGA1284P'; flashbase:0; flashsize:131072; srambase:256; sramsize:16384; eeprombase:0; eepromsize:4096)
        ,(controllertypestr:'ATMEGA16U2'; controllerunitstr:'ATMEGA16U2'; flashbase:0; flashsize:16384; srambase:256; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATTINY45'; controllerunitstr:'ATTINY45'; flashbase:0; flashsize:4096; srambase:96; sramsize:256; eeprombase:0; eepromsize:256)
        ,(controllertypestr:'ATMEGA3250'; controllerunitstr:'ATMEGA3250'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATMEGA329'; controllerunitstr:'ATMEGA329'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATMEGA32A'; controllerunitstr:'ATMEGA32A'; flashbase:0; flashsize:32768; srambase:96; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATTINY5'; controllerunitstr:'ATTINY5'; flashbase:0; flashsize:512; srambase:64; sramsize:32; eeprombase:0; eepromsize:0)
        ,(controllertypestr:'AT90CAN128'; controllerunitstr:'AT90CAN128'; flashbase:0; flashsize:131072; srambase:256; sramsize:4096; eeprombase:0; eepromsize:4096)
        ,(controllertypestr:'ATMEGA6490'; controllerunitstr:'ATMEGA6490'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA8515'; controllerunitstr:'ATMEGA8515'; flashbase:0; flashsize:8192; srambase:96; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA88PA'; controllerunitstr:'ATMEGA88PA'; flashbase:0; flashsize:8192; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA168A'; controllerunitstr:'ATMEGA168A'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA128'; controllerunitstr:'ATMEGA128'; flashbase:0; flashsize:131072; srambase:256; sramsize:4096; eeprombase:0; eepromsize:4096)
        ,(controllertypestr:'AT90USB1286'; controllerunitstr:'AT90USB1286'; flashbase:0; flashsize:131072; srambase:256; sramsize:8192; eeprombase:0; eepromsize:4096)
        ,(controllertypestr:'ATMEGA164PA'; controllerunitstr:'ATMEGA164PA'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATTINY828'; controllerunitstr:'ATTINY828'; flashbase:0; flashsize:8192; srambase:256; sramsize:512; eeprombase:0; eepromsize:256)
        ,(controllertypestr:'ATMEGA88'; controllerunitstr:'ATMEGA88'; flashbase:0; flashsize:8192; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA645A'; controllerunitstr:'ATMEGA645A'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA3290P'; controllerunitstr:'ATMEGA3290P'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATMEGA644P'; controllerunitstr:'ATMEGA644P'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA164A'; controllerunitstr:'ATMEGA164A'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATTINY4313'; controllerunitstr:'ATTINY4313'; flashbase:0; flashsize:4096; srambase:96; sramsize:256; eeprombase:0; eepromsize:256)
        ,(controllertypestr:'ATMEGA162'; controllerunitstr:'ATMEGA162'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA32C1'; controllerunitstr:'ATMEGA32C1'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATMEGA128A'; controllerunitstr:'ATMEGA128A'; flashbase:0; flashsize:131072; srambase:256; sramsize:4096; eeprombase:0; eepromsize:4096)
        ,(controllertypestr:'ATMEGA324A'; controllerunitstr:'ATMEGA324A'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATTINY13'; controllerunitstr:'ATTINY13'; flashbase:0; flashsize:1024; srambase:96; sramsize:64; eeprombase:0; eepromsize:64)
        ,(controllertypestr:'ATMEGA2561'; controllerunitstr:'ATMEGA2561'; flashbase:0; flashsize:262144; srambase:512; sramsize:8192; eeprombase:0; eepromsize:4096)
        ,(controllertypestr:'ATMEGA169A'; controllerunitstr:'ATMEGA169A'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATTINY261'; controllerunitstr:'ATTINY261'; flashbase:0; flashsize:2048; srambase:96; sramsize:128; eeprombase:0; eepromsize:128)
        ,(controllertypestr:'ATMEGA644A'; controllerunitstr:'ATMEGA644A'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA3290'; controllerunitstr:'ATMEGA3290'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATMEGA64A'; controllerunitstr:'ATMEGA64A'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA169P'; controllerunitstr:'ATMEGA169P'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA2560'; controllerunitstr:'ATMEGA2560'; flashbase:0; flashsize:262144; srambase:512; sramsize:8192; eeprombase:0; eepromsize:4096)
        ,(controllertypestr:'ATMEGA32'; controllerunitstr:'ATMEGA32'; flashbase:0; flashsize:32768; srambase:96; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATTINY861A'; controllerunitstr:'ATTINY861A'; flashbase:0; flashsize:8192; srambase:96; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATTINY28'; controllerunitstr:'ATTINY28'; flashbase:0; flashsize:2048; srambase:0; sramsize:0; eeprombase:0; eepromsize:0)
        ,(controllertypestr:'ATMEGA48P'; controllerunitstr:'ATMEGA48P'; flashbase:0; flashsize:4096; srambase:256; sramsize:512; eeprombase:0; eepromsize:256)
        ,(controllertypestr:'ATMEGA8535'; controllerunitstr:'ATMEGA8535'; flashbase:0; flashsize:8192; srambase:96; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA168PA'; controllerunitstr:'ATMEGA168PA'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA16M1'; controllerunitstr:'ATMEGA16M1'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA16HVB'; controllerunitstr:'ATMEGA16HVB'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA164P'; controllerunitstr:'ATMEGA164P'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA325A'; controllerunitstr:'ATMEGA325A'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATMEGA640'; controllerunitstr:'ATMEGA640'; flashbase:0; flashsize:65536; srambase:512; sramsize:8192; eeprombase:0; eepromsize:4096)
        ,(controllertypestr:'ATMEGA6450'; controllerunitstr:'ATMEGA6450'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA329P'; controllerunitstr:'ATMEGA329P'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATA6286'; controllerunitstr:'ATA6286'; flashbase:0; flashsize:8192; srambase:256; sramsize:512; eeprombase:0; eepromsize:320)
        ,(controllertypestr:'AT90USB647'; controllerunitstr:'AT90USB647'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA168'; controllerunitstr:'ATMEGA168'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA6490A'; controllerunitstr:'ATMEGA6490A'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA32M1'; controllerunitstr:'ATMEGA32M1'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATMEGA64C1'; controllerunitstr:'ATMEGA64C1'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA32U2'; controllerunitstr:'ATMEGA32U2'; flashbase:0; flashsize:32768; srambase:256; sramsize:1024; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATTINY4'; controllerunitstr:'ATTINY4'; flashbase:0; flashsize:512; srambase:64; sramsize:32; eeprombase:0; eepromsize:0)
        ,(controllertypestr:'ATMEGA644PA'; controllerunitstr:'ATMEGA644PA'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'AT90PWM1'; controllerunitstr:'AT90PWM1'; flashbase:0; flashsize:8192; srambase:256; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATTINY44'; controllerunitstr:'ATTINY44'; flashbase:0; flashsize:4096; srambase:96; sramsize:256; eeprombase:0; eepromsize:256)
        ,(controllertypestr:'ATMEGA325PA'; controllerunitstr:'ATMEGA325PA'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATMEGA6450A'; controllerunitstr:'ATMEGA6450A'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATTINY2313A'; controllerunitstr:'ATTINY2313A'; flashbase:0; flashsize:2048; srambase:96; sramsize:128; eeprombase:0; eepromsize:128)
        ,(controllertypestr:'ATMEGA329PA'; controllerunitstr:'ATMEGA329PA'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATTINY461A'; controllerunitstr:'ATTINY461A'; flashbase:0; flashsize:4096; srambase:96; sramsize:256; eeprombase:0; eepromsize:256)
        ,(controllertypestr:'ATMEGA6450P'; controllerunitstr:'ATMEGA6450P'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA64'; controllerunitstr:'ATMEGA64'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA165PA'; controllerunitstr:'ATMEGA165PA'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA16A'; controllerunitstr:'ATMEGA16A'; flashbase:0; flashsize:16384; srambase:96; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA649'; controllerunitstr:'ATMEGA649'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA1280'; controllerunitstr:'ATMEGA1280'; flashbase:0; flashsize:131072; srambase:512; sramsize:8192; eeprombase:0; eepromsize:4096)
        ,(controllertypestr:'AT90PWM2B'; controllerunitstr:'AT90PWM2B'; flashbase:0; flashsize:8192; srambase:256; sramsize:512; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATMEGA649P'; controllerunitstr:'ATMEGA649P'; flashbase:0; flashsize:65536; srambase:256; sramsize:4096; eeprombase:0; eepromsize:2048)
        ,(controllertypestr:'ATMEGA3250P'; controllerunitstr:'ATMEGA3250P'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATMEGA48PA'; controllerunitstr:'ATMEGA48PA'; flashbase:0; flashsize:4096; srambase:256; sramsize:512; eeprombase:0; eepromsize:256)
        ,(controllertypestr:'ATTINY1634'; controllerunitstr:'ATTINY1634'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:256)
        ,(controllertypestr:'ATMEGA325'; controllerunitstr:'ATMEGA325'; flashbase:0; flashsize:32768; srambase:256; sramsize:2048; eeprombase:0; eepromsize:1024)
        ,(controllertypestr:'ATMEGA169PA'; controllerunitstr:'ATMEGA169PA'; flashbase:0; flashsize:16384; srambase:256; sramsize:1024; eeprombase:0; eepromsize:512)
        ,(controllertypestr:'ATTINY261A'; controllerunitstr:'ATTINY261A'; flashbase:0; flashsize:2048; srambase:96; sramsize:128; eeprombase:0; eepromsize:128)
        ,(controllertypestr:'ATTINY25'; controllerunitstr:'ATTINY25'; flashbase:0; flashsize:2048; srambase:96; sramsize:128; eeprombase:0; eepromsize:128)
   );

   { Supported optimizations, only used for information }
   supported_optimizerswitches = genericlevel1optimizerswitches+
                                 genericlevel2optimizerswitches+
                                 genericlevel3optimizerswitches-
                                 { no need to write info about those }
                                 [cs_opt_level1,cs_opt_level2,cs_opt_level3]+
                                 [cs_opt_regvar,cs_opt_loopunroll,cs_opt_tailrecursion,
                                  cs_opt_stackframe,cs_opt_nodecse,cs_opt_reorder_fields,cs_opt_fastmath];

   level1optimizerswitches = genericlevel1optimizerswitches;
   level2optimizerswitches = genericlevel2optimizerswitches + level1optimizerswitches +
     [cs_opt_regvar,cs_opt_stackframe,cs_opt_tailrecursion];
   level3optimizerswitches = genericlevel3optimizerswitches + level2optimizerswitches + [{,cs_opt_loopunroll}];
   level4optimizerswitches = genericlevel4optimizerswitches + level3optimizerswitches + [];

 type
   tcpuflags =
      (CPUAVR_HAS_JMP_CALL,
       CPUAVR_HAS_MOVW,
       CPUAVR_HAS_LPMX,
       CPUAVR_HAS_MUL,
       CPUAVR_HAS_RAMPZ,
       CPUAVR_HAS_ELPM,
       CPUAVR_HAS_ELPMX,
       CPUAVR_2_BYTE_PC,
       CPUAVR_3_BYTE_PC
      );

 const
   cpu_capabilities : array[tcputype] of set of tcpuflags =
     ( { cpu_none  } [],
       { cpu_avr1  } [CPUAVR_2_BYTE_PC],
       { cpu_avr2  } [CPUAVR_2_BYTE_PC],
       { cpu_avr25 } [CPUAVR_HAS_MOVW,CPUAVR_HAS_LPMX,CPUAVR_2_BYTE_PC],
       { cpu_avr3  } [CPUAVR_HAS_JMP_CALL,CPUAVR_2_BYTE_PC],
       { cpu_avr31 } [CPUAVR_HAS_JMP_CALL,CPUAVR_HAS_RAMPZ,CPUAVR_HAS_ELPM,CPUAVR_2_BYTE_PC],
       { cpu_avr35 } [CPUAVR_HAS_JMP_CALL,CPUAVR_HAS_MOVW,CPUAVR_HAS_LPMX,CPUAVR_2_BYTE_PC],
       { cpu_avr4  } [CPUAVR_HAS_MOVW,CPUAVR_HAS_LPMX,CPUAVR_HAS_MUL,CPUAVR_2_BYTE_PC],
       { cpu_avr5  } [CPUAVR_HAS_JMP_CALL,CPUAVR_HAS_MOVW,CPUAVR_HAS_LPMX,CPUAVR_HAS_MUL,CPUAVR_2_BYTE_PC],
       { cpu_avr51 } [CPUAVR_HAS_JMP_CALL,CPUAVR_HAS_MOVW,CPUAVR_HAS_LPMX,CPUAVR_HAS_MUL,CPUAVR_HAS_RAMPZ,CPUAVR_HAS_ELPM,CPUAVR_HAS_ELPMX,CPUAVR_2_BYTE_PC],
       { cpu_avr6  } [CPUAVR_HAS_JMP_CALL,CPUAVR_HAS_MOVW,CPUAVR_HAS_LPMX,CPUAVR_HAS_MUL,CPUAVR_HAS_RAMPZ,CPUAVR_HAS_ELPM,CPUAVR_HAS_ELPMX,CPUAVR_3_BYTE_PC]
     );

Implementation

end.
