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

uses
  globtype, globals;

(* pendingstate moved into scanner, from globals.
  Retyped into object, to eliminate indirect references.
*)
    type

      { tpendingstate }

      TPendingState = object //was: record
      private //?
        nextverbositystr : shortstring;
        nextlocalswitches : tlocalswitches;
        nextverbosityfullswitch: longint;
        nextcallingstr : shortstring;
        verbosityfullswitched,
        localswitcheschanged : boolean;
        current_settings: psettings;  //to be inited by scanner
      public
        constructor Init(scanner_settings: psettings);
        function CheckSwitch(switch, state: char): boolean;
        procedure HandleSwitch(switch, state: char);

        procedure flushpendingswitchesstate;
        procedure recordpendingcallingswitch(const str: shortstring);
        procedure recordpendinglocalfullswitch(const switches: tlocalswitches);
        procedure recordpendinglocalswitch(sw: tlocalswitch; state: char);
        procedure recordpendingmessagestate(msg: longint; state: tmsgstate);
        procedure recordpendingverbosityfullswitch(verbosity: longint);
        procedure recordpendingverbosityswitch(sw: char; state: char);
      end;
      PPendingState = ^tpendingstate;

function PendingState: PPendingState;

implementation
uses
  systems,cpuinfo,
  //globals,
  verbose,comphook,
  fmodule, scanner;

{****************************************************************************
                          Main Switches Parsing
****************************************************************************}

type
  TSwitchType=(ignoredsw,localsw,modulesw,globalsw,illegalsw,unsupportedsw,alignsw,optimizersw,packenumsw,pentiumfdivsw);
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
   {U} (typesw:pentiumfdivsw; setsw:ord(cs_localnone)),
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


{ tpendingstate }

constructor tpendingstate.Init(scanner_settings: psettings);
begin
  current_settings := scanner_settings;
end;

function PendingState: PPendingState;
begin
  Result := current_module.PendingState; //special in GlobalModule
end;

procedure tpendingstate.HandleSwitch(switch,state:char);

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
  if m_mac in current_settings^.modeswitches  then
    switchTablePtr:= @macSwitchTable
  else
    switchTablePtr:= @turboSwitchTable;

{ Handle the switch }
   with switchTablePtr^[switch] do
   begin
     case typesw of
       alignsw:
         if state='+' then
           current_settings^.packrecords:=4
         else
           current_settings^.packrecords:=1;
       optimizersw :
         begin
           if state='+' then
             current_settings^.optimizerswitches:=level2optimizerswitches
           else
             current_settings^.optimizerswitches:=[];
         end;
       ignoredsw :
         Message1(scan_n_ignored_switch,'$'+switch);
       illegalsw :
         Message1(scan_w_illegal_switch,'$'+switch);
       unsupportedsw :
         Message1(scan_w_unsupported_switch,'$'+switch);
       localsw :
         recordpendinglocalswitch(tlocalswitch(setsw),state);
       modulesw :
         begin
           if current_module.in_global then
            begin
{$ifndef cpufpemu}
              if tmoduleswitch(setsw)=cs_fp_emulation then
                begin
                  Message1(scan_w_unsupported_switch_by_target,'$'+switch);
                end
              else
{$endif cpufpemu}
                begin
                  if state='+' then
                    include(current_settings^.moduleswitches,tmoduleswitch(setsw))
                  else
                    begin
                      { Turning off debuginfo when lineinfo is requested
                        is not possible }
                      if not((cs_use_lineinfo in current_settings^.globalswitches) and
                             (tmoduleswitch(setsw)=cs_debuginfo)) then
                        exclude(current_settings^.moduleswitches,tmoduleswitch(setsw));
                    end;
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
               include(current_settings^.globalswitches,tglobalswitch(setsw))
              else
               exclude(current_settings^.globalswitches,tglobalswitch(setsw));
            end
           else
            Message(scan_w_switch_is_global);
         end;
       packenumsw:
         begin
           if state='-' then
             current_settings^.packenum:=1
           else
             current_settings^.packenum:=4;
         end;
       pentiumfdivsw:
         begin
           { Switch u- means pentium-safe fdiv off -> fpc default. We don't }
           { support u+                                                     }
           if state='+' then
             Message1(scan_w_unsupported_switch,'$'+switch);
         end;
     end;
   end;
end;


function tpendingstate.CheckSwitch(switch,state:char):boolean;

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
  if m_mac in current_settings^.modeswitches then
    switchTablePtr:= @macSwitchTable
  else
    switchTablePtr:= @turboSwitchTable;

{ Check the switch }
   with switchTablePtr^[switch] do
   begin
     case typesw of
      localsw : found:=(tlocalswitch(setsw) in current_settings^.localswitches);
     modulesw : found:=(tmoduleswitch(setsw) in current_settings^.moduleswitches);
     globalsw : found:=(tglobalswitch(setsw) in current_settings^.globalswitches);
     packenumsw : found := (current_settings^.packenum = 4);
     else
      found:=false;
     end;
     if state='-' then
      found:=not found;
     CheckSwitch:=found;
   end;
end;


procedure tpendingstate.recordpendingverbosityswitch(sw: char; state: char);
  begin
    {pendingstate.}nextverbositystr:={pendingstate.}nextverbositystr+sw+state;
  end;

procedure tpendingstate.recordpendingmessagestate(msg: longint; state: tmsgstate);
  begin
    { todo }
  end;

procedure tpendingstate.recordpendinglocalswitch(sw: tlocalswitch; state: char);
  begin
    if not localswitcheschanged then
       nextlocalswitches:=current_settings^.localswitches;
    if state='-' then
      exclude(nextlocalswitches,sw)
    else if state='+' then
      include(nextlocalswitches,sw)
    else { state = '*' }
      begin
        if sw in init_settings.localswitches then
         include(nextlocalswitches,sw)
        else
         exclude(nextlocalswitches,sw);
      end;
    localswitcheschanged:=true;
  end;


procedure tpendingstate.recordpendinglocalfullswitch(const switches: tlocalswitches);
  begin
    nextlocalswitches:=switches;
    localswitcheschanged:=true;
  end;


procedure tpendingstate.recordpendingverbosityfullswitch(verbosity: longint);
  begin
    nextverbositystr:='';
    nextverbosityfullswitch:=verbosity;
    verbosityfullswitched:=true;
  end;

procedure tpendingstate.recordpendingcallingswitch(const str: shortstring);
  begin
    nextcallingstr:=str;
  end;


procedure tpendingstate.flushpendingswitchesstate;
  var
    tmpproccal: tproccalloption;
  begin
    { process pending localswitches (range checking, etc) }
    if localswitcheschanged then
      begin
        current_settings^.localswitches:=nextlocalswitches;
        localswitcheschanged:=false;
      end;
    { process pending verbosity changes (warnings on, etc) }
    if verbosityfullswitched then
      begin
        status.verbosity:=nextverbosityfullswitch;
        verbosityfullswitched:=false;
      end;
    if nextverbositystr<>'' then
      begin
        setverbosity(nextverbositystr);
        nextverbositystr:='';
      end;
    { process pending calling convention changes (calling x) }
    if nextcallingstr<>'' then
      begin
        if not SetAktProcCall(nextcallingstr,tmpproccal) then
          Message1(parser_w_unknown_proc_directive_ignored,nextcallingstr)
        else if not(tmpproccal in supported_calling_conventions) then
          Message1(parser_e_illegal_calling_convention,nextcallingstr)
        else
          current_settings^.defproccall:=tmpproccal;
        nextcallingstr:='';
      end;
  end;


end.
