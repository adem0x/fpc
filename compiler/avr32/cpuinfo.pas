{
    Copyright (c) 1998-2002 by the Free Pascal development team

    Basic Processor information for the ARM

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
   ts32real = single;
   ts64real = double;
   ts80real = type extended;
   ts128real = type extended;
   ts64comp = comp;

   pbestreal=^bestreal;

   { possible supported processors for this target }
   tcputype =
      (cpu_none,
       cpu_ap,
       cpu_ucr1,
       cpu_ucr2,
       cpu_ucr3,
       cpu_ucr3fp,
       cpu_all_insn
      );

Type
   tfputype =
     (fpu_none,
      fpu_libgcc,
      fpu_soft,
      fpu_avr32
     );

   tcontrollertype =
     (ct_none,
      ct_at32uc3l016,
      ct_at32uc3l032,
      ct_at32uc3l064,
      ct_at32uc3l116,
      ct_at32uc3l132,
      ct_at32uc3l164,
      ct_at32uc3l216,
      ct_at32uc3l232,
      ct_at32uc3l264,
      ct_at32uc3l316,
      ct_at32uc3l332,
      ct_at32uc3l364,
      ct_at32uc3b0256es,
      ct_at32uc3b0256,
      ct_at32uc3b1256es,
      ct_at32uc3b1256,
      ct_at32uc3c0512c,
      ct_at32uc3c0512crevc,
      ct_at32uc3c1512c,
      ct_at32uc3c1512crevc
     );

Const
   {# Size of native extended floating point type }
   extended_size = 12;
   {# Size of a multimedia register               }
   mmreg_size = 16;
   { target cpu string (used by compiler options) }
   target_cpu_string = 'avr32';

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
     pocall_softfloat,
     { same as stdcall (requires that all const records are passed by
       reference, but that's already done for stdcall) }
     pocall_mwpascal
   ];

   cputypestr : array[tcputype] of string[8] = ('',
     'ap',
     'ucr1',
     'ucr2',
     'ucr3',
     'ucr3fp',
     'all-insn'
   );

   fputypestr : array[tfputype] of string[6] = ('',
     'LIBGCC',
     'SOFT',
     'AVR32'
   );


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
   	controllertypestr:'AT32UC3L016';
        controllerunitstr:'AT32UC3L016';
        flashbase:$80000000;
        flashsize:$4000;
        srambase:0;
        sramsize:$2000;
        eeprombase:0;
        eepromsize:0
        ),
        (
   	controllertypestr:'AT32UC3L032';
        controllerunitstr:'AT32UC3L032';
        flashbase:$80000000;
        flashsize:$8000;
        srambase:0;
        sramsize:$4000;
        eeprombase:0;
        eepromsize:0
        ),
   	(
        controllertypestr:'AT32UC3L064';
        controllerunitstr:'AT32UC3L064';
        flashbase:$80000000;
        flashsize:$10000;
        srambase:0;
        sramsize:$4000;
        eeprombase:0;
        eepromsize:0;
        ),
        (
   	controllertypestr:'AT32UC3L116';
        controllerunitstr:'AT32UC3L116';
        flashbase:$80000000;
        flashsize:$4000;
        srambase:0;
        sramsize:$2000;
        eeprombase:0;
        eepromsize:0
        ),
        (
   	controllertypestr:'AT32UC3L132';
        controllerunitstr:'AT32UC3L132';
        flashbase:$80000000;
        flashsize:$8000;
        srambase:0;
        sramsize:$4000;
        eeprombase:0;
        eepromsize:0
        ),
   	(
        controllertypestr:'AT32UC3L164';
        controllerunitstr:'AT32UC3L164';
        flashbase:$80000000;
        flashsize:$10000;
        srambase:0;
        sramsize:$4000;
        eeprombase:0;
        eepromsize:0;
        ),
        (
   	controllertypestr:'AT32UC3L216';
        controllerunitstr:'AT32UC3L216';
        flashbase:$80000000;
        flashsize:$4000;
        srambase:0;
        sramsize:$2000;
        eeprombase:0;
        eepromsize:0
        ),
        (
   	controllertypestr:'AT32UC3L232';
        controllerunitstr:'AT32UC3L232';
        flashbase:$80000000;
        flashsize:$8000;
        srambase:0;
        sramsize:$4000;
        eeprombase:0;
        eepromsize:0
        ),
   	(
        controllertypestr:'AT32UC3L264';
        controllerunitstr:'AT32UC3L264';
        flashbase:$80000000;
        flashsize:$10000;
        srambase:0;
        sramsize:$4000;
        eeprombase:0;
        eepromsize:0;
        ),
        (
   	controllertypestr:'AT32UC3L316';
        controllerunitstr:'AT32UC3L316';
        flashbase:$80000000;
        flashsize:$4000;
        srambase:0;
        sramsize:$2000;
        eeprombase:0;
        eepromsize:0
        ),
        (
   	controllertypestr:'AT32UC3L332';
        controllerunitstr:'AT32UC3L332';
        flashbase:$80000000;
        flashsize:$8000;
        srambase:0;
        sramsize:$4000;
        eeprombase:0;
        eepromsize:0
        ),
   	(
        controllertypestr:'AT32UC3L364';
        controllerunitstr:'AT32UC3L364';
        flashbase:$80000000;
        flashsize:$10000;
        srambase:0;
        sramsize:$4000;
        eeprombase:0;
        eepromsize:0;
        ),
   	(
        controllertypestr:'AT32UC3B0256ES';
        controllerunitstr:'AT32UC3B0256ES';
        flashbase:$80000000;
        flashsize:$40000;
        srambase:0;
        sramsize:$8000;
        eeprombase:0;
        eepromsize:0;
        ),
   	(
        controllertypestr:'AT32UC3B0256';
        controllerunitstr:'AT32UC3B0256';
        flashbase:$80000000;
        flashsize:$40000;
        srambase:0;
        sramsize:$8000 ;
        eeprombase:0;
        eepromsize:0;
        ),
   	(
        controllertypestr:'AT32UC3B1256ES';
        controllerunitstr:'AT32UC3B1256ES';
        flashbase:$80000000;
        flashsize:$40000;
        srambase:0;
        sramsize:$8000;
        eeprombase:0;
        eepromsize:0;
        ),
   	(
        controllertypestr:'AT32UC3B1256';
        controllerunitstr:'AT32UC3B1256';
        flashbase:$80000000;
        flashsize:$40000;
        srambase:0;
        sramsize:$8000 ;
        eeprombase:0;
        eepromsize:0;
        ),
   	(
        controllertypestr:'AT32UC3B0512C';
        controllerunitstr:'AT32UC3B0512C';
        flashbase:$80000000;
        flashsize:$80000;
        srambase:0;
        sramsize:$10000;
        eeprombase:0;
        eepromsize:0;
        ),
   	(
        controllertypestr:'AT32UC3B0512CREVC';
        controllerunitstr:'AT32UC3B0512CREVC';
        flashbase:$80000000;
        flashsize:$80000;
        srambase:0;
        sramsize:$1000 ;
        eeprombase:0;
        eepromsize:0;
        ),
   	(
        controllertypestr:'AT32UC3B1512C';
        controllerunitstr:'AT32UC3B1512C';
        flashbase:$80000000;
        flashsize:$80000;
        srambase:0;
        sramsize:$10000;
        eeprombase:0;
        eepromsize:0;
        ),
   	(
        controllertypestr:'AT32UC3B1512CREVC';
        controllerunitstr:'AT32UC3B1512CREVC';
        flashbase:$80000000;
        flashsize:$80000;
        srambase:0;
        sramsize:$10000 ;
        eeprombase:0;
        eepromsize:0;
        )
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
     [cs_opt_regvar,cs_opt_stackframe,cs_opt_tailrecursion,cs_opt_nodecse];
   level3optimizerswitches = genericlevel3optimizerswitches + level2optimizerswitches + [cs_opt_scheduler{,cs_opt_loopunroll}];
   level4optimizerswitches = genericlevel4optimizerswitches + level3optimizerswitches + [];


Implementation

end.
