{
    Copyright (c) 1998-2000 by Florian Klaempfl

    Basic Processor information

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

 ****************************************************************************
}
Unit cpuinfo;

{$i fpcdefs.inc}

Interface

  uses
    globtype;

Type
   bestreal = extended;
   ts32real = single;
   ts64real = double;
   ts80real = extended;
   ts128real = type extended;
   ts64comp = type extended;

   pbestreal=^bestreal;

   tcputype =
      (cpu_none,
       cpu_athlon64,
       cpu_core_avx,
       cpu_core_avx2
      );

   tfputype =
     (fpu_none,
//      fpu_soft,  { generic }
      fpu_sse64,
      fpu_sse3,
      fpu_ssse3,
      fpu_sse41,
      fpu_sse42,
      fpu_avx,
      fpu_avx2
     );

Const
   { Size of native extended type }
   extended_size = 10;
   { Size of a multimedia register }
   mmreg_size = 16;
   { target cpu string (used by compiler options) }
   target_cpu_string = 'x86_64';

   { calling conventions supported by the code generator }
   supported_calling_conventions : tproccalloptions = [
     pocall_internproc,
{     pocall_compilerproc,
     pocall_inline,}
     pocall_register,
     pocall_safecall,
     pocall_stdcall,
     pocall_cdecl,
     pocall_cppdecl,
     pocall_mwpascal
   ];

   cputypestr : array[tcputype] of string[10] = ('',
     'ATHLON64',
     'COREAVX',
     'COREAVX2'
   );

   fputypestr : array[tfputype] of string[6] = ('',
//     'SOFT',
     'SSE64',
     'SSE3',
     'SSSE3',
     'SSE41',
     'SSE42',
     'AVX',
     'AVX2'
   );

   sse_singlescalar = [fpu_sse64..fpu_avx2];
   sse_doublescalar = [fpu_sse64..fpu_avx2];

   fpu_avx_instructionsets = [fpu_avx,fpu_avx2];

   { Supported optimizations, only used for information }
   supported_optimizerswitches = genericlevel1optimizerswitches+
                                 genericlevel2optimizerswitches+
                                 genericlevel3optimizerswitches-
                                 { no need to write info about those }
                                 [cs_opt_level1,cs_opt_level2,cs_opt_level3]+
                                 [cs_opt_regvar,cs_opt_loopunroll,cs_opt_stackframe,
				  cs_opt_tailrecursion,cs_opt_nodecse,cs_opt_reorder_fields,cs_opt_fastmath];

   level1optimizerswitches = genericlevel1optimizerswitches;
   level2optimizerswitches = genericlevel2optimizerswitches + level1optimizerswitches + 
     [cs_opt_regvar,cs_opt_stackframe,cs_opt_tailrecursion,cs_opt_nodecse];
   level3optimizerswitches = genericlevel3optimizerswitches + level2optimizerswitches + [{,cs_opt_loopunroll}];
   level4optimizerswitches = genericlevel4optimizerswitches + level3optimizerswitches + [];

type
   tcpuflags =
      (CPUX86_HAS_SSEUNIT,
       CPUX86_HAS_BMI1,
       CPUX86_HAS_BMI2,
       CPUX86_HAS_POPCNT,
       CPUX86_HAS_AVXUNIT,
       CPUX86_HAS_LZCNT,
       CPUX86_HAS_MOVBE
      );

 const
   cpu_capabilities : array[tcputype] of set of tcpuflags = (
     { cpu_none      } [],
     { Athlon64      } [CPUX86_HAS_SSEUNIT],
     { cpu_core_avx  } [CPUX86_HAS_SSEUNIT,CPUX86_HAS_POPCNT,CPUX86_HAS_AVXUNIT],
     { cpu_core_avx2 } [CPUX86_HAS_SSEUNIT,CPUX86_HAS_POPCNT,CPUX86_HAS_AVXUNIT,CPUX86_HAS_BMI1,CPUX86_HAS_BMI2,CPUX86_HAS_LZCNT,CPUX86_HAS_MOVBE]
   );

Implementation

end.
