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
       cpu_armv3,
       cpu_armv4,
       cpu_armv5,
       cpu_armv6,
       cpu_armv7,
       cpu_armv7m,
       cpu_cortexm3
      );

Const
   cpu_arm = [cpu_none,cpu_armv3,cpu_armv4,cpu_armv5];
   cpu_thumb = [];
   cpu_thumb2 = [cpu_armv7m,cpu_cortexm3];

Type
   tfputype =
     (fpu_none,
      fpu_soft,
      fpu_libgcc,
      fpu_fpa,
      fpu_fpa10,
      fpu_fpa11,
      fpu_vfpv2,
      fpu_vfpv3
     );

   tcontrollertype =
     (ct_none,

      { Phillips }
      ct_lpc2114,
      ct_lpc2124,
      ct_lpc2194,

      { ATMEL }
      ct_at91sam7s256,
      ct_at91sam7se256,
      ct_at91sam7x256,
      ct_at91sam7xc256,
		
      { STMicroelectronics }
      ct_stm32f103re,

      { TI }
      stellaris
     );

Const
   {# Size of native extended floating point type }
   extended_size = 12;
   {# Size of a multimedia register               }
   mmreg_size = 16;
   { target cpu string (used by compiler options) }
   target_cpu_string = 'arm';

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
     pocall_mwpascal,
     { used for interrupt handling }
     pocall_interrupt
   ];

   cputypestr : array[tcputype] of string[8] = ('',
     'ARMV3',
     'ARMV4',
     'ARMV5',
     'ARMV6',
     'ARMV7',
     'ARMV7M',
     'CORTEXM3'
   );

   fputypestr : array[tfputype] of string[6] = ('',
     'SOFT',
     'LIBGCC',
     'FPA',
     'FPA10',
     'FPA11',
     'VFPV2',
     'VFPV3'
   );

   controllertypestr : array[tcontrollertype] of string[20] =
     ('',
      'LPC2114',
      'LPC2124',
      'LPC2194',
      'AT91SAM7S256',
      'AT91SAM7SE256',
      'AT91SAM7X256',
      'AT91SAM7XC256',
      'STM32F103RE',
      'STELLARIS'
     );

   controllerunitstr : array[tcontrollertype] of string[20] =
     ('',
      'LPC21x4',
      'LPC21x4',
      'LPC21x4',
      'AT91SAM7x256',
      'AT91SAM7x256',
      'AT91SAM7x256',
      'AT91SAM7x256',
      'STM32F103',
      'STELLARIS'
     );

   interruptvectors : array[tcontrollertype] of longint =
     (0,
      8,
      8,
      8,
      8,
      8,
      8,
      8,
      12+59, { XL-density }
      12 { No model specified }
     );

   vfp_scalar = [fpu_vfpv2,fpu_vfpv3];

   { Supported optimizations, only used for information }
   supported_optimizerswitches = genericlevel1optimizerswitches+
                                 genericlevel2optimizerswitches+
                                 genericlevel3optimizerswitches-
                                 { no need to write info about those }
                                 [cs_opt_level1,cs_opt_level2,cs_opt_level3]+
                                 [cs_opt_regvar,cs_opt_loopunroll,cs_opt_tailrecursion,
								  cs_opt_stackframe,cs_opt_nodecse];

   level1optimizerswitches = genericlevel1optimizerswitches;
   level2optimizerswitches = genericlevel2optimizerswitches + level1optimizerswitches +
     [cs_opt_regvar,cs_opt_stackframe,cs_opt_tailrecursion,cs_opt_nodecse];
   level3optimizerswitches = genericlevel3optimizerswitches + level2optimizerswitches + [{,cs_opt_loopunroll}];

Implementation

end.
