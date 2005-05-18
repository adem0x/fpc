{
    $Id: t_amiga.pas,v 1.4 2005/02/14 17:13:10 peter Exp $
    Copyright (c) 2001-2002 by Peter Vreman

    This unit implements support import,export,link routines
    for the (m68k/powerpc) Amiga target

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
unit t_amiga;

{$i fpcdefs.inc}

interface


implementation

    uses
       link,
       cutils,cclasses,
       globtype,globals,systems,verbose,script,fmodule,i_amiga;

{*****************************************************************************
                                     Initialize
*****************************************************************************}

initialization
  RegisterTarget(system_m68k_amiga_info);
end.
{
  $Log: t_amiga.pas,v $
  Revision 1.4  2005/02/14 17:13:10  peter
    * truncate log

  Revision 1.3  2005/02/03 03:54:07  karoly
  t_morph.pas

}
