{
    Copyright (c) 1998-2002 by the Free Pascal development team

    Basic Processor information for the RISC-V

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
       ts80real = type double;
       ts128real = type double;
       ts64comp = comp;

       pbestreal=^bestreal;

       { possible supported processors for this target }
       tcputype =
          (cpu_none,
           cpu_r32i,
           cpu_r32g
          );

       tfputype =(fpu_none,
                  fpu_soft,
                  fpu_libgcc,
                  fpu_r32fd);

       tabitype =
         (
         abi_none,
         abi_default
         );

       tcontrollertype =
         (ct_none,

          { Placeholder }
          ct_standard,
          ct_angel
         );

    Const
       {# Size of native extended floating point type }
       extended_size = 8;
       {# Size of a multimedia register               }
       mmreg_size = 0;
       { calling conventions supported by the code generator }
       supported_calling_conventions : tproccalloptions = [
         pocall_internproc,
         pocall_stdcall,
         pocall_safecall,
         { same as stdcall only different name mangling }
         pocall_cdecl,
         { same as stdcall only different name mangling }
         pocall_cppdecl
       ];

       { cpu strings as accepted by
         GNU assembler in -arch=XXX option
         this ilist needs to be uppercased }
       cputypestr : array[tcputype] of string[8] = ('',
         { cpu_r32i        } 'R32I',
         { cpu_r32g        } 'R32G'
       );

       fputypestr : array[tfputype] of string[9] = ('',
         'SOFT',
         'LIBGCC',
         'R32FD'
       );

       { abi strings as accepted by
         GNU assembler in -abi=XXX option }
       abitypestr : array[tabitype] of string[4] =
         ({ abi_none    } '',
          { abi_default } '32'
         );

        { We know that there are fields after sramsize
          but we don't care about this warning }
        {$WARN 3177 OFF}

       embedded_controllers : array [tcontrollertype] of tcontrollerdatatype =
       (
          (controllertypestr:'';		controllerunitstr:'';	flashbase:0;	flashsize:0;	srambase:0;	sramsize:0),

          { Placeholders }
          (controllertypestr:'STANDARD';	controllerunitstr:'STANDARD';	flashbase:$00000000;	flashsize:$00010000;	srambase:$10000000;	sramsize:$00010000),
          (controllertypestr:'ANGEL';	controllerunitstr:'ANGEL';	flashbase:$00000000;	flashsize:$10000000;	srambase:$10000000;	sramsize:$10000000)
       );


    type
       tcpuflags=(CPURISCV_HAS_MULDIV); //Todo: Does this need to be filled?

    const
      cpu_capabilities : array[tcputype] of set of tcpuflags =
        ( { cpu_none } [],
          { cpu_r32i } [],
          { cpu_r32g } [CPURISCV_HAS_MULDIV]
        );

       { Supported optimizations, only used for information }
       supported_optimizerswitches = genericlevel1optimizerswitches+
                                     genericlevel2optimizerswitches+
                                     genericlevel3optimizerswitches-
                                     { no need to write info about those }
                                     [cs_opt_level1,cs_opt_level2,cs_opt_level3]+
                                     [cs_opt_regvar,cs_opt_loopunroll,cs_opt_tailrecursion,
                                      cs_opt_stackframe,cs_opt_nodecse,cs_opt_reorder_fields,cs_opt_fastmath,cs_opt_forcenostackframe];

       level1optimizerswitches = genericlevel1optimizerswitches;
       level2optimizerswitches = level1optimizerswitches + [cs_opt_regvar,cs_opt_stackframe,cs_opt_nodecse];
       level3optimizerswitches = level2optimizerswitches + [{cs_opt_loopunroll}];
       level4optimizerswitches = genericlevel4optimizerswitches + level3optimizerswitches + [];

  Implementation

    uses
      cutils;
           
end.
