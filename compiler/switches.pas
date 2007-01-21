{
    Copyright (c) 1998-2002 by Peter Vreman

    This unit implements the parsing of the switches like $I-

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
unit switches;

{$i fpcdefs.inc}

interface

procedure HandleSwitch(switch,state:char);
function CheckSwitch(switch,state:char):boolean;


implementation
uses
  globtype,systems,cpuinfo,
  globals,verbose,fmodule;

{****************************************************************************
                          Main Switches Parsing
****************************************************************************}

type
  TSwitchType=(ignoredsw,localsw,modulesw,globalsw,illegalsw,unsupportedsw,alignsw,optimizersw,packenumsw);
  SwitchRec=record
    typesw : TSwitchType;
    setsw  : byte;
  end;
  SwitchRecTable = array['A'..'Z'] of SwitchRec;

const
  turboSwitchTable: SwitchRecTable =(
   {A} (typesw:alignsw; setsw:ord(cs_localnone)),
   {B} (typesw:localsw; setsw:ord(cs_full_boolean_eval)),
   {C} (typesw:localsw; setsw:ord(cs_do_assertion)),
   {D} (typesw:modulesw; setsw:ord(cs_debuginfo)),
   {E} (typesw:modulesw; setsw:ord(cs_fp_emulation)),
   {F} (typesw:ignoredsw; setsw:ord(cs_localnone)),
   {G} (typesw:ignoredsw; setsw:ord(cs_localnone)),
   {H} (typesw:localsw; setsw:ord(cs_ansistrings)),
   {I} (typesw:localsw; setsw:ord(cs_check_io)),
   {J} (typesw:localsw; setsw:ord(cs_typed_const_writable)),
   {K} (typesw:unsupportedsw; setsw:ord(cs_localnone)),
   {L} (typesw:unsupportedsw; setsw:ord(cs_localnone)),
   {M} (typesw:localsw; setsw:ord(cs_generate_rtti)),
   {N} (typesw:unsupportedsw; setsw:ord(cs_localnone)),
   {O} (typesw:optimizersw; setsw:ord(cs_opt_none)),
   {P} (typesw:modulesw; setsw:ord(cs_openstring)),
   {Q} (typesw:localsw; setsw:ord(cs_check_overflow)),
   {R} (typesw:localsw; setsw:ord(cs_check_range)),
   {S} (typesw:localsw; setsw:ord(cs_check_stack)),
   {T} (typesw:localsw; setsw:ord(cs_typed_addresses)),
   {U} (typesw:illegalsw; setsw:ord(cs_localnone)),
   {V} (typesw:localsw; setsw:ord(cs_strict_var_strings)),
   {W} (typesw:localsw; setsw:ord(cs_generate_stackframes)),
   {X} (typesw:modulesw; setsw:ord(cs_extsyntax)),
   {Y} (typesw:unsupportedsw; setsw:ord(cs_localnone)),
   {Z} (typesw:packenumsw; setsw:ord(cs_localnone))
    );


  macSwitchTable: SwitchRecTable =(
   {A} (typesw:unsupportedsw; setsw:ord(cs_localnone)),
   {B} (typesw:localsw; setsw:ord(cs_full_boolean_eval)),
   {C} (typesw:localsw; setsw:ord(cs_do_assertion)),
   {D} (typesw:modulesw; setsw:ord(cs_debuginfo)),
   {E} (typesw:modulesw; setsw:ord(cs_fp_emulation)),
   {F} (typesw:ignoredsw; setsw:ord(cs_localnone)),
   {G} (typesw:ignoredsw; setsw:ord(cs_localnone)),
   {H} (typesw:localsw; setsw:ord(cs_ansistrings)),
   {I} (typesw:localsw; setsw:ord(cs_check_io)),
   {J} (typesw:localsw; setsw:ord(cs_external_var)),
   {K} (typesw:unsupportedsw; setsw:ord(cs_localnone)),
   {L} (typesw:unsupportedsw; setsw:ord(cs_localnone)),
   {M} (typesw:localsw; setsw:ord(cs_generate_rtti)),
   {N} (typesw:unsupportedsw; setsw:ord(cs_localnone)),
   {O} (typesw:optimizersw; setsw:ord(cs_opt_none)),
   {P} (typesw:modulesw; setsw:ord(cs_openstring)),
   {Q} (typesw:localsw; setsw:ord(cs_check_overflow)),
   {R} (typesw:localsw; setsw:ord(cs_check_range)),
   {S} (typesw:localsw; setsw:ord(cs_check_stack)),
   {T} (typesw:localsw; setsw:ord(cs_typed_addresses)),
   {U} (typesw:illegalsw; setsw:ord(cs_localnone)),
   {V} (typesw:localsw; setsw:ord(cs_strict_var_strings)),
   {W} (typesw:localsw; setsw:ord(cs_generate_stackframes)),
   {X} (typesw:modulesw; setsw:ord(cs_extsyntax)),
   {Y} (typesw:unsupportedsw; setsw:ord(cs_localnone)),
   {Z} (typesw:localsw; setsw:ord(cs_externally_visible))
    );

procedure HandleSwitch(switch,state:char);

var
  switchTablePtr: ^SwitchRecTable;

begin
  switch:=upcase(switch);
{ Is the Switch in the letters ? }
  if not ((switch in ['A'..'Z']) and (state in ['-','+'])) then
   begin
     Message(scan_w_illegal_switch);
     exit;
   end;

{ Select switch table }
  if m_mac in current_settings.modeswitches  then
    switchTablePtr:= @macSwitchTable
  else
    switchTablePtr:= @turboSwitchTable;

{ Handle the switch }
   with switchTablePtr^[switch] do
   begin
     case typesw of
       alignsw:
         if state='+' then
           current_settings.packrecords:=4
         else
           current_settings.packrecords:=1;
       optimizersw :
         begin
           if state='+' then
             current_settings.optimizerswitches:=level2optimizerswitches
           else
             current_settings.optimizerswitches:=[];
         end;
       ignoredsw :
         Message1(scan_n_ignored_switch,'$'+switch);
       illegalsw :
         Message1(scan_w_illegal_switch,'$'+switch);
       unsupportedsw :
         Message1(scan_w_unsupported_switch,'$'+switch);
       localsw :
         begin
           if not localswitcheschanged then
             nextlocalswitches:=current_settings.localswitches;
           if state='+' then
            include(nextlocalswitches,tlocalswitch(setsw))
           else
            exclude(nextlocalswitches,tlocalswitch(setsw));
           localswitcheschanged:=true;
         end;
       modulesw :
         begin
           if current_module.in_global then
            begin
              if state='+' then
                include(current_settings.moduleswitches,tmoduleswitch(setsw))
              else
                begin
                  { Turning off debuginfo when lineinfo is requested
                    is not possible }
                  if not((cs_use_lineinfo in current_settings.globalswitches) and
                         (tmoduleswitch(setsw)=cs_debuginfo)) then
                    exclude(current_settings.moduleswitches,tmoduleswitch(setsw));
                end;
            end
           else
            Message(scan_w_switch_is_global);
         end;
       globalsw :
         begin
           if current_module.in_global and (current_module=main_module) then
            begin
              if state='+' then
               include(current_settings.globalswitches,tglobalswitch(setsw))
              else
               exclude(current_settings.globalswitches,tglobalswitch(setsw));
            end
           else
            Message(scan_w_switch_is_global);
         end;
       packenumsw:
         begin
           if state='-' then
             current_settings.packenum:=1
           else
             current_settings.packenum:=4;
         end;
     end;
   end;
end;


function CheckSwitch(switch,state:char):boolean;

var
  found : boolean;
  switchTablePtr: ^SwitchRecTable;

begin
  switch:=upcase(switch);
{ Is the Switch in the letters ? }
  if not ((switch in ['A'..'Z']) and (state in ['-','+'])) then
   begin
     Message(scan_w_illegal_switch);
     CheckSwitch:=false;
     exit;
   end;

{ Select switch table }
  if m_mac in current_settings.modeswitches then
    switchTablePtr:= @macSwitchTable
  else
    switchTablePtr:= @turboSwitchTable;

{ Check the switch }
   with switchTablePtr^[switch] do
   begin
     case typesw of
      localsw : found:=(tlocalswitch(setsw) in current_settings.localswitches);
     modulesw : found:=(tmoduleswitch(setsw) in current_settings.moduleswitches);
     globalsw : found:=(tglobalswitch(setsw) in current_settings.globalswitches);
     packenumsw : found := (current_settings.packenum = 4);
     else
      found:=false;
     end;
     if state='-' then
      found:=not found;
     CheckSwitch:=found;
   end;
end;


end.
