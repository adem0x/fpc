{
    Copyright (c) 1998-2002 by the Free Pascal development team

    Basic Processor information for the PowerPC

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
   ts80real = extended;
   ts128real = extended;
   ts64comp = comp;

   pbestreal=^bestreal;

   { possible supported processors for this target }
   tcputype =
      (cpu_none,
       cpu_ppc601,
       cpu_ppc604
      );

   tfputype =
     (fpu_none,
      fpu_soft,
      fpu_standard
     );


Const
   { calling conventions supported by the code generator }
   supported_calling_conventions : tproccalloptions = [
     pocall_internproc,
     pocall_stdcall,
     { the difference to stdcall is only the name mangling }
     pocall_cdecl,
     { the difference to stdcall is only the name mangling }
     pocall_cppdecl,
     { pass all const records by reference }
     pocall_mwpascal
   ];

   cputypestr : array[tcputype] of string[10] = ('',
     '603',
     '604'
   );

   fputypestr : array[tfputype] of string[8] = ('',
     'SOFT',
     'STANDARD'
   );

   { Supported optimizations, only used for information }
   supported_optimizerswitches = [cs_opt_regvar,cs_opt_loopunroll];

   level1optimizerswitches = [cs_opt_level1];
   level2optimizerswitches = level1optimizerswitches + [cs_opt_level2,cs_opt_regvar];
   level3optimizerswitches = level2optimizerswitches + [cs_opt_level3{,cs_opt_loopunroll}];

Implementation

end.
