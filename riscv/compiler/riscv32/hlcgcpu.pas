{
    Copyright (c) 1998-2010 by Florian Klaempfl and Jonas Maebe
    Member of the Free Pascal development team

    This unit contains routines to create a pass-through high-level code
    generator. This is used by most regular code generators.

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

unit hlcgcpu;

{$i fpcdefs.inc}

interface

uses
  globtype,
  aasmbase, aasmdata,
  cgbase, cgutils,
  symconst,symtype,symdef,
  parabase, hlcgobj, hlcg2ll;

  type
    thlcgriscv = class(thlcg2ll)
    end;

  procedure create_hlcodegen;

implementation

  uses
    verbose,
    aasmtai,
    aasmcpu,
    cutils,
    globals,
    defutil,
    cgobj,
    cpubase,
    cpuinfo,
    cgcpu;


  procedure create_hlcodegen;
    begin
      hlcg:=thlcgriscv.create;
      create_codegen;
    end;

end.
