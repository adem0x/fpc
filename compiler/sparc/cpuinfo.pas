{
    Copyright (c) 1998-2002 by Florian Klaempfl

    Basic Processor information for the SPARC

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
unit cpuinfo;

{$i fpcdefs.inc}

interface

uses
  globtype;

type
  bestreal = double;
  ts32real = single;
  ts64real = double;
  ts80real = extended;
  ts128real = type extended;
  ts64comp = type extended;
  pbestreal=^bestreal;

  { possible supported processors for this target }
  tcputype=(cpu_none,
    cpu_SPARC_V7,
    cpu_SPARC_V8,
    cpu_SPARC_V9
  );

  tfputype =(fpu_none,
    fpu_soft,
    fpu_hard
  );


const
  { calling conventions supported by the code generator }
  supported_calling_conventions : tproccalloptions = [
    pocall_internproc,
    pocall_stdcall,
    pocall_cdecl,
    pocall_cppdecl
  ];

   cputypestr : array[tcputype] of string[10] = ('',
     'SPARC V7',
     'SPARC V8',
     'SPARC V9'
   );

   fputypestr : array[tfputype] of string[6] = ('',
     'SOFT',
     'HARD'
   );

   level1optimizerswitches = [cs_opt_level1];
   level2optimizerswitches = level1optimizerswitches + [cs_opt_level2,cs_opt_regvar];
   level3optimizerswitches = level2optimizerswitches + [cs_opt_level3,cs_opt_loopunroll];

implementation

end.
