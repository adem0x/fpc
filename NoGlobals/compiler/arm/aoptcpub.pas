 {
    Copyright (c) 1998-2002 by Jonas Maebe, member of the Free Pascal
    Development Team

    This unit contains several types and constants necessary for the
    optimizer to work on the ARM architecture

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
Unit aoptcpub; { Assembler OPTimizer CPU specific Base }

{$i fpcdefs.inc}

{ enable the following define if memory references can have both a base and }
{ index register in 1 operand                                               }

{$define RefsHaveIndexReg}

{ enable the following define if memory references can have a scaled index }

{ define RefsHaveScale}

{ enable the following define if memory references can have a segment }
{ override                                                            }

{ define RefsHaveSegment}

Interface

Uses
  cpubase,aasmcpu,AOptBase;

Type
{
{ type of a normal instruction }
  TInstr = Taicpu;
  PInstr = ^TInstr;
}

{ ************************************************************************* }
{ **************************** TCondRegs ********************************** }
{ ************************************************************************* }
{ Info about the conditional registers                                      }
  TCondRegs = Object
    Constructor Init;
    Destructor Done;
  End;

{ ************************************************************************* }
{ **************************** TAoptBaseCpu ******************************* }
{ ************************************************************************* }
{$IFDEF fix}
  TAoptBaseCpu = class(TAoptBase)
  End;
{$ELSE}
(* Override virtual methods of TAoptBase
*)
  TPaiPropCpu = class(TPaiProp)
  protected
    //function CanSkip(Current: tai): boolean; override;
  public
    { returns the maximum width component of Reg. Only has to be }
    { overridden for the 80x86 (afaik)                           }
    //Function RegMaxSize(Reg: TRegister): TRegister; override;

    { returns true if Reg1 and Reg2 are of the samae width. Only has to }
    { overridden for the 80x86 (afaik)                                  }
    //Function RegsSameSize(Reg1, Reg2: TRegister): Boolean; override;

    { returns whether P is a load instruction (load contents from a }
    { memory location or (register) variable into a register)       }
    Function IsLoadMemReg(p: tai): Boolean; override;
    { returns whether P is a load constant instruction (load a constant }
    { into a register)                                                  }
    Function IsLoadConstReg(p: tai): Boolean; override;
    { returns whether P is a store instruction (store contents from a }
    { register to a memory location or to a (register) variable)      }
    Function IsStoreRegMem(p: tai): Boolean; override;

    { create a taicpu Object that loads the contents of reg1 into reg2 }
    Function a_load_reg_reg(reg1, reg2: TRegister): taicpu; override;
  end;

{$ENDIF}


{ ************************************************************************* }
{ ******************************* Constants ******************************* }
{ ************************************************************************* }
Const

{ the maximum number of things (registers, memory, ...) a single instruction }
{ changes                                                                    }

  MaxCh = 3;

{ the maximum number of operands an instruction has }

  MaxOps = 3;

{Oper index of operand that contains the source (reference) with a load }
{instruction                                                            }

  LoadSrc = 0;

{Oper index of operand that contains the destination (register) with a load }
{instruction                                                                }

  LoadDst = 1;

{Oper index of operand that contains the source (register) with a store }
{instruction                                                            }

  StoreSrc = 0;

{Oper index of operand that contains the destination (reference) with a load }
{instruction                                                                 }

  StoreDst = 1;

  aopt_uncondjmp = A_B;
  aopt_condjmp = A_B;

Implementation

{ ************************************************************************* }
{ **************************** TCondRegs ********************************** }
{ ************************************************************************* }
Constructor TCondRegs.init;
Begin
End;

Destructor TCondRegs.Done; {$ifdef inl} inline; {$endif inl}
Begin
End;

End.
