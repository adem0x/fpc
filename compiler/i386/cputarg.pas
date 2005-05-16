{
    $Id: cputarg.pas,v 1.16 2005/02/14 17:13:09 peter Exp $
    Copyright (c) 2001-2002 by Peter Vreman

    Includes the i386 dependent target units

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
unit cputarg;

{$i fpcdefs.inc}

interface


implementation

    uses
      systems { prevent a syntax error when nothing is included }

{**************************************
             Targets
**************************************}

    {$ifndef NOTARGETLINUX}
      ,t_linux
    {$endif}
    {$ifndef NOTARGETBSD}
      ,t_bsd
    {$endif}
    {$ifndef NOTARGETSUNOS}
      ,t_sunos
    {$endif}
    {$ifndef NOTARGETEMX}
      ,t_emx
    {$endif}
    {$ifndef NOTARGETOS2}
      ,t_os2
    {$endif}
    {$ifndef NOTARGETWIN32}
      ,t_win32
    {$endif}
    {$ifndef NOTARGETNETWARE}
      ,t_nwm
    {$endif}
    {$ifndef NOTARGETNETWLIBC}
      ,t_nwl
    {$endif}
    {$ifndef NOTARGETGO32V2}
      ,t_go32v2
    {$endif}
    {$ifndef NOTARGETBEOS}
      ,t_beos
    {$endif}
    {$ifndef NOTARGETWDOSX}
      ,t_wdosx
    {$endif}
    {$ifndef NOTARGETWATCOM}
      ,t_watcom
    {$endif}

{**************************************
             Assemblers
**************************************}

    {$ifndef NOAG386ATT}
      ,agx86att
    {$endif}
    {$ifndef NOAG386NSM}
      ,ag386nsm
    {$endif}
    {$ifndef NOAG386INT}
      ,ag386int
    {$endif}

      ,ogcoff
      ,ogelf
      ;

end.
{
  $Log: cputarg.pas,v $
  Revision 1.16  2005/02/14 17:13:09  peter
    * truncate log

}
