{
    Copyright (c) 1998-2002 by Florian Klaempfl

    Generate assembler for nodes that influence the flow which are
    the same for all (most?) processors

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
unit ncgflw;

{$i fpcdefs.inc}

interface

    uses
      aasmbase,node,nflw,ncgutil;

    type
       tcgwhilerepeatnode = class(twhilerepeatnode)
          procedure pass_2;override;
          procedure sync_regvars(checkusedregvars: boolean);

          usedregvars: tusedregvars;
       end;

       tcgifnode = class(tifnode)
          procedure pass_2;override;
       end;

       tcgfornode = class(tfornode)
          procedure pass_2;override;
          procedure sync_regvars(checkusedregvars: boolean);

          usedregvars: tusedregvars;
       end;

       tcgexitnode = class(texitnode)
          procedure pass_2;override;
       end;

       tcgbreaknode = class(tbreaknode)
          procedure pass_2;override;
       end;

       tcgcontinuenode = class(tcontinuenode)
          procedure pass_2;override;
       end;

       tcggotonode = class(tgotonode)
          procedure pass_2;override;
       end;

       tcglabelnode = class(tlabelnode)
       private
          asmlabel : tasmlabel;
       public
          function getasmlabel : tasmlabel;
          procedure pass_2;override;
       end;

       tcgraisenode = class(traisenode)
          procedure pass_2;override;
       end;

       tcgtryexceptnode = class(ttryexceptnode)
          procedure pass_2;override;
       end;

       tcgtryfinallynode = class(ttryfinallynode)
          procedure pass_2;override;
       end;

       tcgonnode = class(tonnode)
          procedure pass_2;override;
       end;

implementation

    uses
      verbose,globals,systems,globtype,
      symconst,symdef,symsym,aasmtai,aasmdata,aasmcpu,defutil,
      procinfo,cgbase,pass_2,parabase,
      cpubase,cpuinfo,
      nld,ncon,
      tgobj,paramgr,
      regvars,
      cgutils,cgobj
      ;

{*****************************************************************************
                         Second_While_RepeatN
*****************************************************************************}

    procedure tcgwhilerepeatnode.sync_regvars(checkusedregvars: boolean);
      begin
         if (cs_opt_regvar in aktoptimizerswitches) and
            not(pi_has_goto in current_procinfo.flags) then
           begin
             if checkusedregvars then
               begin
                 usedregvars.intregvars.init;
                 usedregvars.fpuregvars.init;
                 usedregvars.mmregvars.init;

                 { we have to synchronise both the regvars used in the loop }
                 { and the ones in the while/until condition                }
                 get_used_regvars(self,usedregvars);
                 gen_sync_regvars(current_asmdata.CurrAsmList,usedregvars);
               end
             else
               begin
                 gen_sync_regvars(current_asmdata.CurrAsmList,usedregvars);
                 usedregvars.intregvars.done;
                 usedregvars.fpuregvars.done;
                 usedregvars.mmregvars.done;
               end;
           end;
      end;


    procedure tcgwhilerepeatnode.pass_2;
      var
         lcont,lbreak,lloop,
         oldclabel,oldblabel : tasmlabel;
         otlabel,oflabel : tasmlabel;
         oldflowcontrol : tflowcontrol;
      begin
         location_reset(location,LOC_VOID,OS_NO);

         current_asmdata.getjumplabel(lloop);
         current_asmdata.getjumplabel(lcont);
         current_asmdata.getjumplabel(lbreak);
         { arrange continue and breaklabels: }
         oldflowcontrol:=flowcontrol;
         oldclabel:=current_procinfo.CurrContinueLabel;
         oldblabel:=current_procinfo.CurrBreakLabel;

         sync_regvars(true);
{$ifdef OLDREGVARS}
         load_all_regvars(current_asmdata.CurrAsmList);
{$endif OLDREGVARS}
         { handling code at the end as it is much more efficient, and makes
           while equal to repeat loop, only the end true/false is swapped (PFV) }
         if lnf_testatbegin in loopflags then
           cg.a_jmp_always(current_asmdata.CurrAsmList,lcont);

         if not(cs_opt_size in aktoptimizerswitches) then
            { align loop target }
            current_asmdata.CurrAsmList.concat(Tai_align.Create(aktalignment.loopalign));

         cg.a_label(current_asmdata.CurrAsmList,lloop);

         current_procinfo.CurrContinueLabel:=lcont;
         current_procinfo.CurrBreakLabel:=lbreak;
         if assigned(right) then
           secondpass(right);

{$ifdef OLDREGVARS}
         load_all_regvars(current_asmdata.CurrAsmList);
{$endif OLDREGVARS}

         cg.a_label(current_asmdata.CurrAsmList,lcont);
         otlabel:=current_procinfo.CurrTrueLabel;
         oflabel:=current_procinfo.CurrFalseLabel;
         if lnf_checknegate in loopflags then
          begin
            current_procinfo.CurrTrueLabel:=lbreak;
            current_procinfo.CurrFalseLabel:=lloop;
          end
         else
          begin
            current_procinfo.CurrTrueLabel:=lloop;
            current_procinfo.CurrFalseLabel:=lbreak;
          end;
         secondpass(left);

         maketojumpbool(current_asmdata.CurrAsmList,left,lr_load_regvars);
         cg.a_label(current_asmdata.CurrAsmList,lbreak);

         sync_regvars(false);

         current_procinfo.CurrTrueLabel:=otlabel;
         current_procinfo.CurrFalseLabel:=oflabel;

         current_procinfo.CurrContinueLabel:=oldclabel;
         current_procinfo.CurrBreakLabel:=oldblabel;
         { a break/continue in a while/repeat block can't be seen outside }
         flowcontrol:=oldflowcontrol+(flowcontrol-[fc_break,fc_continue]);
      end;


{*****************************************************************************
                               tcgIFNODE
*****************************************************************************}

    procedure tcgifnode.pass_2;

      var
         hl,otlabel,oflabel : tasmlabel;
(*
         org_regvar_loaded_other,
         then_regvar_loaded_other,
         else_regvar_loaded_other : regvarother_booleanarray;
         org_regvar_loaded_int,
         then_regvar_loaded_int,
         else_regvar_loaded_int : Tsuperregisterset;
         org_list,
         then_list,
         else_list : TAsmList;
*)

      begin
         location_reset(location,LOC_VOID,OS_NO);

         otlabel:=current_procinfo.CurrTrueLabel;
         oflabel:=current_procinfo.CurrFalseLabel;
         current_asmdata.getjumplabel(current_procinfo.CurrTrueLabel);
         current_asmdata.getjumplabel(current_procinfo.CurrFalseLabel);
         secondpass(left);

(*
         { save regvars loaded in the beginning so that we can restore them }
         { when processing the else-block                                   }
         if cs_opt_regvar in aktoptimizerswitches then
           begin
             org_list := current_asmdata.CurrAsmList;
             current_asmdata.CurrAsmList := TAsmList.create;
           end;
*)
         maketojumpbool(current_asmdata.CurrAsmList,left,lr_dont_load_regvars);

(*
         if cs_opt_regvar in aktoptimizerswitches then
           begin
             org_regvar_loaded_int := rg.regvar_loaded_int;
             org_regvar_loaded_other := rg.regvar_loaded_other;
           end;
*)

         if assigned(right) then
           begin
              cg.a_label(current_asmdata.CurrAsmList,current_procinfo.CurrTrueLabel);
              secondpass(right);
           end;

         { save current asmlist (previous instructions + then-block) and }
         { loaded regvar state and create new clean ones                 }
{
         if cs_opt_regvar in aktoptimizerswitches then
           begin
             then_regvar_loaded_int := rg.regvar_loaded_int;
             then_regvar_loaded_other := rg.regvar_loaded_other;
             rg.regvar_loaded_int := org_regvar_loaded_int;
             rg.regvar_loaded_other := org_regvar_loaded_other;
             then_list := current_asmdata.CurrAsmList;
             current_asmdata.CurrAsmList := TAsmList.create;
           end;
}

         if assigned(t1) then
           begin
              if assigned(right) then
                begin
                   current_asmdata.getjumplabel(hl);
                   { do go back to if line !! }
(*
                   if not(cs_opt_regvar in aktoptimizerswitches) then
*)
                     aktfilepos:=current_asmdata.CurrAsmList.getlasttaifilepos^
(*
                   else
                     aktfilepos:=then_list.getlasttaifilepos^
*)
                   ;
                   cg.a_jmp_always(current_asmdata.CurrAsmList,hl);
                end;
              cg.a_label(current_asmdata.CurrAsmList,current_procinfo.CurrFalseLabel);
              secondpass(t1);
(*
              { save current asmlist (previous instructions + else-block) }
              { and loaded regvar state and create a new clean list       }
              if cs_opt_regvar in aktoptimizerswitches then
                begin
{                  else_regvar_loaded_int := rg.regvar_loaded_int;
                  else_regvar_loaded_other := rg.regvar_loaded_other;}
                  else_list := current_asmdata.CurrAsmList;
                  current_asmdata.CurrAsmList := TAsmList.create;
                end;
*)
              if assigned(right) then
                cg.a_label(current_asmdata.CurrAsmList,hl);
           end
         else
           begin
(*
              if cs_opt_regvar in aktoptimizerswitches then
                begin
{                  else_regvar_loaded_int := rg.regvar_loaded_int;
                  else_regvar_loaded_other := rg.regvar_loaded_other;}
                  else_list := current_asmdata.CurrAsmList;
                  current_asmdata.CurrAsmList := TAsmList.create;
                end;
*)
              cg.a_label(current_asmdata.CurrAsmList,current_procinfo.CurrFalseLabel);
           end;
         if not(assigned(right)) then
           begin
              cg.a_label(current_asmdata.CurrAsmList,current_procinfo.CurrTrueLabel);
           end;

(*
         if cs_opt_regvar in aktoptimizerswitches then
           begin
             { add loads of regvars at the end of the then- and else-blocks  }
             { so that at the end of both blocks the same regvars are loaded }

             { no else block? }
             if not assigned(t1) then
               begin
                 sync_regvars_int(org_list,then_list,org_regvar_loaded_int,then_regvar_loaded_int);
                 sync_regvars_other(org_list,then_list,org_regvar_loaded_other,then_regvar_loaded_other);
               end
             { no then block? }
             else if not assigned(right) then
               begin
                 sync_regvars_int(org_list,else_list,org_regvar_loaded_int,else_regvar_loaded_int);
                 sync_regvars_other(org_list,else_list,org_regvar_loaded_other,else_regvar_loaded_other);
               end
             { both else and then blocks }
             else
               begin
                 sync_regvars_int(then_list,else_list,then_regvar_loaded_int,else_regvar_loaded_int);
                 sync_regvars_other(then_list,else_list,then_regvar_loaded_other,else_regvar_loaded_other);
               end;
             { add all lists together }
             org_list.concatlist(then_list);
             then_list.free;
             org_list.concatlist(else_list);
             else_list.free;
             org_list.concatlist(current_asmdata.CurrAsmList);
             current_asmdata.CurrAsmList.free;
             current_asmdata.CurrAsmList := org_list;
           end;
*)

         current_procinfo.CurrTrueLabel:=otlabel;
         current_procinfo.CurrFalseLabel:=oflabel;
      end;


{*****************************************************************************
                              SecondFor
*****************************************************************************}

    procedure tcgfornode.sync_regvars(checkusedregvars: boolean);
      begin
         if (cs_opt_regvar in aktoptimizerswitches) and
            not(pi_has_goto in current_procinfo.flags) then
           begin
             if checkusedregvars then
               begin
                 usedregvars.intregvars.init;
                 usedregvars.fpuregvars.init;
                 usedregvars.mmregvars.init;

                 { We have to synchronise the loop variable and loop body. }
                 { The loop end is not necessary, unless it's a register   }
                 { variable. The start value also doesn't matter.          }

                 { loop var }
                 get_used_regvars(right,usedregvars);
                 { loop body }
                 get_used_regvars(t2,usedregvars);
                 { end value if necessary }
                 if (t1.location.loc = LOC_CREGISTER) then
                   get_used_regvars(t1,usedregvars);

                 gen_sync_regvars(current_asmdata.CurrAsmList,usedregvars);
               end
             else
               begin
                 gen_sync_regvars(current_asmdata.CurrAsmList,usedregvars);
                 usedregvars.intregvars.done;
                 usedregvars.fpuregvars.done;
                 usedregvars.mmregvars.done;
               end;
           end;
      end;


    procedure tcgfornode.pass_2;
      var
         l3,oldclabel,oldblabel : tasmlabel;
         temptovalue : boolean;
         hop : topcg;
         hcond : topcmp;
         opsize : tcgsize;
         count_var_is_signed,do_loopvar_at_end : boolean;
         cmp_const:Tconstexprint;
         oldflowcontrol : tflowcontrol;

      begin
         location_reset(location,LOC_VOID,OS_NO);
         oldflowcontrol:=flowcontrol;
         oldclabel:=current_procinfo.CurrContinueLabel;
         oldblabel:=current_procinfo.CurrBreakLabel;
         current_asmdata.getjumplabel(current_procinfo.CurrContinueLabel);
         current_asmdata.getjumplabel(current_procinfo.CurrBreakLabel);
         current_asmdata.getjumplabel(l3);

         { only calculate reference }
         opsize := def_cgsize(left.resulttype.def);
         count_var_is_signed:=is_signed(left.resulttype.def);

         { first set the to value
           because the count var can be in the expression ! }
         do_loopvar_at_end:=(lnf_dont_mind_loopvar_on_exit in loopflags)
         { if the loop is unrolled and there is a jump into the loop,
           then we can't do the trick with incrementing the loop var only at the
           end
         }
           and not(assigned(entrylabel));

         secondpass(t1);
         { calculate pointer value and check if changeable and if so }
         { load into temporary variable                       }
         if t1.nodetype<>ordconstn then
           begin
              do_loopvar_at_end:=false;
              location_force_reg(current_asmdata.CurrAsmList,t1.location,t1.location.size,true);
              temptovalue:=true;
           end
         else
           temptovalue:=false;

         { produce start assignment }
         secondpass(left);
         secondpass(right);
         case left.location.loc of
           LOC_REFERENCE,
           LOC_CREFERENCE :
             cg.a_load_loc_ref(current_asmdata.CurrAsmList,left.location.size,right.location,left.location.reference);
           LOC_REGISTER,
           LOC_CREGISTER :
             cg.a_load_loc_reg(current_asmdata.CurrAsmList,left.location.size,right.location,left.location.register);
           else
             internalerror(200501311);
         end;

         if lnf_backward in loopflags then
           if count_var_is_signed then
             hcond:=OC_LT
           else
             hcond:=OC_B
         else
           if count_var_is_signed then
             hcond:=OC_GT
           else
             hcond:=OC_A;

         sync_regvars(true);
{$ifdef OLDREGVARS}
         load_all_regvars(current_asmdata.CurrAsmList);
{$endif OLDREGVARS}

         if temptovalue then
           begin
             cg.a_cmp_reg_loc_label(current_asmdata.CurrAsmList,opsize,hcond,
               t1.location.register,left.location,current_procinfo.CurrBreakLabel);
           end
         else
           begin
             if lnf_testatbegin in loopflags then
               begin
                 cg.a_cmp_const_loc_label(current_asmdata.CurrAsmList,opsize,hcond,
                   tordconstnode(t1).value,
                   left.location,current_procinfo.CurrBreakLabel);
               end;
           end;

         {If the loopvar doesn't mind on exit, we avoid this ugly
          dec instruction and do the loopvar inc/dec after the loop
          body.}
         if not do_loopvar_at_end then
            begin
              if lnf_backward in loopflags then
                hop:=OP_ADD
              else
                hop:=OP_SUB;
              cg.a_op_const_loc(current_asmdata.CurrAsmList,hop,1,left.location);
            end;

         if assigned(entrylabel) then
           cg.a_jmp_always(current_asmdata.CurrAsmList,tcglabelnode(entrylabel).getasmlabel);

         { align loop target }
         if not(cs_opt_size in aktoptimizerswitches) then
            current_asmdata.CurrAsmList.concat(Tai_align.Create(aktalignment.loopalign));
         cg.a_label(current_asmdata.CurrAsmList,l3);

         {If the loopvar doesn't mind on exit, we avoid the loopvar inc/dec
          after the loop body instead of here.}
         if not do_loopvar_at_end then
            begin
              { according to count direction DEC or INC... }
              if lnf_backward in loopflags then
                hop:=OP_SUB
              else
                hop:=OP_ADD;
              cg.a_op_const_loc(current_asmdata.CurrAsmList,hop,1,left.location);
            end;

         if assigned(t2) then
           begin
             secondpass(t2);
{$ifdef OLDREGVARS}
             load_all_regvars(current_asmdata.CurrAsmList);
{$endif OLDREGVARS}
           end;

         {If the loopvar doesn't mind on exit, we do the loopvar inc/dec
          after the loop body instead of here.}
         if do_loopvar_at_end then
            begin
              { according to count direction DEC or INC... }
              if lnf_backward in loopflags then
                hop:=OP_SUB
              else
                hop:=OP_ADD;
              cg.a_op_const_loc(current_asmdata.CurrAsmList,hop,1,left.location);
            end;

         cg.a_label(current_asmdata.CurrAsmList,current_procinfo.CurrContinueLabel);

         if do_loopvar_at_end then
           if lnf_backward in loopflags then
             if count_var_is_signed then
               hcond:=OC_GTE
             else
               hcond:=OC_AE
            else
              if count_var_is_signed then
                hcond:=OC_LTE
              else
                hcond:=OC_BE
         else
           if lnf_backward in loopflags then
             if count_var_is_signed then
               hcond:=OC_GT
             else
               hcond:=OC_A
            else
              if count_var_is_signed then
                hcond:=OC_LT
              else
                hcond:=OC_B;
{$ifdef OLDREGVARS}
         load_all_regvars(current_asmdata.CurrAsmList);
{$endif OLDREGVARS}

         { produce comparison and the corresponding }
         { jump                                     }
         if temptovalue then
           begin
             cg.a_cmp_reg_loc_label(current_asmdata.CurrAsmList,opsize,hcond,t1.location.register,
               left.location,l3);
           end
         else
           begin
             cmp_const:=Tordconstnode(t1).value;
             if do_loopvar_at_end then
               begin
                 {Watch out for wrap around 255 -> 0.}
                 {Ugly: This code is way to long... Use tables?}
                 case opsize of
                   OS_8:
                     begin
                       if lnf_backward in loopflags then
                         begin
                           if byte(cmp_const)=low(byte) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=high(byte);
                             end
                         end
                       else
                         begin
                           if byte(cmp_const)=high(byte) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=low(byte);
                             end
                         end
                     end;
                   OS_16:
                     begin
                       if lnf_backward in loopflags then
                         begin
                           if word(cmp_const)=high(word) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=low(word);
                             end
                         end
                       else
                         begin
                           if word(cmp_const)=low(word) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=high(word);
                             end
                         end
                     end;
                   OS_32:
                     begin
                       if lnf_backward in loopflags then
                         begin
                           if cardinal(cmp_const)=high(cardinal) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=low(cardinal);
                             end
                         end
                       else
                         begin
                           if cardinal(cmp_const)=low(cardinal) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=high(cardinal);
                             end
                         end
                     end;
                   OS_64:
                     begin
                       if lnf_backward in loopflags then
                         begin
                           if qword(cmp_const)=high(qword) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=low(qword);
                             end
                         end
                       else
                         begin
                           if qword(cmp_const)=low(qword) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=high(qword);
                             end
                         end
                     end;
                   OS_S8:
                     begin
                       if lnf_backward in loopflags then
                         begin
                           if shortint(cmp_const)=low(shortint) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=high(shortint);
                             end
                         end
                       else
                         begin
                           if shortint(cmp_const)=high(shortint) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=low(shortint);
                             end
                         end
                     end;
                   OS_S16:
                     begin
                       if lnf_backward in loopflags then
                         begin
                           if integer(cmp_const)=high(smallint) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=low(smallint);
                             end
                         end
                       else
                         begin
                           if integer(cmp_const)=low(smallint) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=high(smallint);
                             end
                         end
                     end;
                   OS_S32:
                     begin
                       if lnf_backward in loopflags then
                         begin
                           if longint(cmp_const)=high(longint) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=low(longint);
                             end
                         end
                       else
                         begin
                           if longint(cmp_const)=low(longint) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=high(longint);
                             end
                         end
                     end;
                   OS_S64:
                     begin
                       if lnf_backward in loopflags then
                         begin
                           if int64(cmp_const)=high(int64) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=low(int64);
                             end
                         end
                       else
                         begin
                           if int64(cmp_const)=low(int64) then
                             begin
                               hcond:=OC_NE;
                               cmp_const:=high(int64);
                             end
                         end
                     end;
                   else
                     internalerror(200201021);
                 end;
               end;

             cg.a_cmp_const_loc_label(current_asmdata.CurrAsmList,opsize,hcond,
               aint(cmp_const),left.location,l3);
           end;

         { this is the break label: }
         cg.a_label(current_asmdata.CurrAsmList,current_procinfo.CurrBreakLabel);

         sync_regvars(false);

         current_procinfo.CurrContinueLabel:=oldclabel;
         current_procinfo.CurrBreakLabel:=oldblabel;
         { a break/continue in a while/repeat block can't be seen outside }
         flowcontrol:=oldflowcontrol+(flowcontrol-[fc_break,fc_continue]);
      end;


{*****************************************************************************
                              SecondExitN
*****************************************************************************}

    procedure tcgexitnode.pass_2;
      begin
         location_reset(location,LOC_VOID,OS_NO);

         include(flowcontrol,fc_exit);
         if assigned(left) then
           secondpass(left);

         cg.a_jmp_always(current_asmdata.CurrAsmList,current_procinfo.CurrExitLabel);
       end;


{*****************************************************************************
                              SecondBreakN
*****************************************************************************}

    procedure tcgbreaknode.pass_2;
      begin
         location_reset(location,LOC_VOID,OS_NO);

         include(flowcontrol,fc_break);
         if current_procinfo.CurrBreakLabel<>nil then
           begin
{$ifdef OLDREGVARS}
             load_all_regvars(current_asmdata.CurrAsmList);
{$endif OLDREGVARS}
             cg.a_jmp_always(current_asmdata.CurrAsmList,current_procinfo.CurrBreakLabel)
           end
         else
           CGMessage(cg_e_break_not_allowed);
      end;


{*****************************************************************************
                              SecondContinueN
*****************************************************************************}

    procedure tcgcontinuenode.pass_2;
      begin
         location_reset(location,LOC_VOID,OS_NO);

         include(flowcontrol,fc_continue);
         if current_procinfo.CurrContinueLabel<>nil then
           begin
{$ifdef OLDREGVARS}
             load_all_regvars(current_asmdata.CurrAsmList);
{$endif OLDREGVARS}
             cg.a_jmp_always(current_asmdata.CurrAsmList,current_procinfo.CurrContinueLabel)
           end
         else
           CGMessage(cg_e_continue_not_allowed);
      end;


{*****************************************************************************
                             SecondGoto
*****************************************************************************}

    procedure tcggotonode.pass_2;

       begin
         location_reset(location,LOC_VOID,OS_NO);

{$ifdef OLDREGVARS}
         load_all_regvars(current_asmdata.CurrAsmList);
{$endif OLDREGVARS}
         cg.a_jmp_always(current_asmdata.CurrAsmList,tcglabelnode(labelnode).getasmlabel)
       end;


{*****************************************************************************
                             SecondLabel
*****************************************************************************}

    function tcglabelnode.getasmlabel : tasmlabel;
      begin
        if not(assigned(asmlabel)) then
          current_asmdata.getjumplabel(asmlabel);
        result:=asmlabel
      end;


    procedure tcglabelnode.pass_2;
      begin
         location_reset(location,LOC_VOID,OS_NO);

{$ifdef OLDREGVARS}
         load_all_regvars(current_asmdata.CurrAsmList);
{$endif OLDREGVARS}
         cg.a_label(current_asmdata.CurrAsmList,getasmlabel);
         secondpass(left);
      end;


{*****************************************************************************
                             SecondRaise
*****************************************************************************}

    procedure tcgraisenode.pass_2;

      var
         a : tasmlabel;
         href2: treference;
         paraloc1,paraloc2,paraloc3 : tcgpara;
      begin
         paraloc1.init;
         paraloc2.init;
         paraloc3.init;
         paramanager.getintparaloc(pocall_default,1,paraloc1);
         paramanager.getintparaloc(pocall_default,2,paraloc2);
         paramanager.getintparaloc(pocall_default,3,paraloc3);
         location_reset(location,LOC_VOID,OS_NO);

         if assigned(left) then
           begin
              { multiple parameters? }
              if assigned(right) then
                begin
                  if assigned(frametree) then
                    secondpass(frametree);
                  secondpass(right);
                end;
              secondpass(left);
              if codegenerror then
                exit;

              { Push parameters }
              if assigned(right) then
                begin
                  paramanager.allocparaloc(current_asmdata.CurrAsmList,paraloc3);
                  if assigned(frametree) then
                    cg.a_param_loc(current_asmdata.CurrAsmList,frametree.location,paraloc3)
                  else
                    cg.a_param_const(current_asmdata.CurrAsmList,OS_INT,0,paraloc3);
                  { push address }
                  paramanager.allocparaloc(current_asmdata.CurrAsmList,paraloc2);
                  cg.a_param_loc(current_asmdata.CurrAsmList,right.location,paraloc2);
                end
              else
                begin
                   { get current address }
                   current_asmdata.getaddrlabel(a);
                   cg.a_label(current_asmdata.CurrAsmList,a);
                   reference_reset_symbol(href2,a,0);
                   { push current frame }
                   paramanager.allocparaloc(current_asmdata.CurrAsmList,paraloc3);
                   cg.a_param_reg(current_asmdata.CurrAsmList,OS_ADDR,NR_FRAME_POINTER_REG,paraloc3);
                   { push current address }
                   paramanager.allocparaloc(current_asmdata.CurrAsmList,paraloc2);
                   if target_info.system <> system_powerpc_macos then
                     cg.a_paramaddr_ref(current_asmdata.CurrAsmList,href2,paraloc2)
                   else
                     cg.a_param_const(current_asmdata.CurrAsmList,OS_INT,0,paraloc2);
                end;
              paramanager.allocparaloc(current_asmdata.CurrAsmList,paraloc1);
              cg.a_param_loc(current_asmdata.CurrAsmList,left.location,paraloc1);
              paramanager.freeparaloc(current_asmdata.CurrAsmList,paraloc1);
              paramanager.freeparaloc(current_asmdata.CurrAsmList,paraloc2);
              paramanager.freeparaloc(current_asmdata.CurrAsmList,paraloc3);
              cg.allocallcpuregisters(current_asmdata.CurrAsmList);
              cg.a_call_name(current_asmdata.CurrAsmList,'FPC_RAISEEXCEPTION');
              cg.deallocallcpuregisters(current_asmdata.CurrAsmList);
           end
         else
           begin
              cg.allocallcpuregisters(current_asmdata.CurrAsmList);
              cg.a_call_name(current_asmdata.CurrAsmList,'FPC_POPADDRSTACK');
              cg.a_call_name(current_asmdata.CurrAsmList,'FPC_RERAISE');
              cg.deallocallcpuregisters(current_asmdata.CurrAsmList);
           end;
         paraloc1.done;
         paraloc2.done;
         paraloc3.done;
       end;


{*****************************************************************************
                             SecondTryExcept
*****************************************************************************}

    var
       endexceptlabel : tasmlabel;


    { does the necessary things to clean up the object stack }
    { in the except block                                    }
    procedure cleanupobjectstack;
      var
        paraloc1 : tcgpara;
      begin
         cg.allocallcpuregisters(current_asmdata.CurrAsmList);
         cg.a_call_name(current_asmdata.CurrAsmList,'FPC_POPOBJECTSTACK');
         cg.deallocallcpuregisters(current_asmdata.CurrAsmList);
         paraloc1.init;
         paramanager.getintparaloc(pocall_default,1,paraloc1);
         paramanager.allocparaloc(current_asmdata.CurrAsmList,paraloc1);
         cg.a_param_reg(current_asmdata.CurrAsmList,OS_ADDR,NR_FUNCTION_RESULT_REG,paraloc1);
         paramanager.freeparaloc(current_asmdata.CurrAsmList,paraloc1);
         cg.allocallcpuregisters(current_asmdata.CurrAsmList);
         cg.a_call_name(current_asmdata.CurrAsmList,'FPC_DESTROYEXCEPTION');
         cg.deallocallcpuregisters(current_asmdata.CurrAsmList);
         paraloc1.done;
      end;


    procedure tcgtryexceptnode.pass_2;

      var
         exceptlabel,doexceptlabel,oldendexceptlabel,
         lastonlabel,
         exitexceptlabel,
         continueexceptlabel,
         breakexceptlabel,
         exittrylabel,
         continuetrylabel,
         breaktrylabel,
         doobjectdestroy,
         doobjectdestroyandreraise,
         oldCurrExitLabel,
         oldContinueLabel,
         oldBreakLabel : tasmlabel;
         oldflowcontrol,tryflowcontrol,
         exceptflowcontrol : tflowcontrol;
         destroytemps,
         excepttemps : texceptiontemps;
         paraloc1 : tcgpara;
      label
         errorexit;
      begin
         location_reset(location,LOC_VOID,OS_NO);

         oldflowcontrol:=flowcontrol;
         flowcontrol:=[];
         { this can be called recursivly }
         oldBreakLabel:=nil;
         oldContinueLabel:=nil;
         oldendexceptlabel:=endexceptlabel;

         { save the old labels for control flow statements }
         oldCurrExitLabel:=current_procinfo.CurrExitLabel;
         if assigned(current_procinfo.CurrBreakLabel) then
           begin
              oldContinueLabel:=current_procinfo.CurrContinueLabel;
              oldBreakLabel:=current_procinfo.CurrBreakLabel;
           end;

         { get new labels for the control flow statements }
         current_asmdata.getjumplabel(exittrylabel);
         current_asmdata.getjumplabel(exitexceptlabel);
         if assigned(current_procinfo.CurrBreakLabel) then
           begin
              current_asmdata.getjumplabel(breaktrylabel);
              current_asmdata.getjumplabel(continuetrylabel);
              current_asmdata.getjumplabel(breakexceptlabel);
              current_asmdata.getjumplabel(continueexceptlabel);
           end;

         current_asmdata.getjumplabel(exceptlabel);
         current_asmdata.getjumplabel(doexceptlabel);
         current_asmdata.getjumplabel(endexceptlabel);
         current_asmdata.getjumplabel(lastonlabel);

         get_exception_temps(current_asmdata.CurrAsmList,excepttemps);
         new_exception(current_asmdata.CurrAsmList,excepttemps,exceptlabel);

         { try block }
         { set control flow labels for the try block }
         current_procinfo.CurrExitLabel:=exittrylabel;
         if assigned(oldBreakLabel) then
          begin
            current_procinfo.CurrContinueLabel:=continuetrylabel;
            current_procinfo.CurrBreakLabel:=breaktrylabel;
          end;

         flowcontrol:=[];
         secondpass(left);
         tryflowcontrol:=flowcontrol;
         if codegenerror then
           goto errorexit;

         cg.a_label(current_asmdata.CurrAsmList,exceptlabel);

         free_exception(current_asmdata.CurrAsmList, excepttemps, 0, endexceptlabel, false);

         cg.a_label(current_asmdata.CurrAsmList,doexceptlabel);

         { set control flow labels for the except block }
         { and the on statements                        }
         current_procinfo.CurrExitLabel:=exitexceptlabel;
         if assigned(oldBreakLabel) then
          begin
            current_procinfo.CurrContinueLabel:=continueexceptlabel;
            current_procinfo.CurrBreakLabel:=breakexceptlabel;
          end;

         flowcontrol:=[];
         { on statements }
         if assigned(right) then
           secondpass(right);

         cg.a_label(current_asmdata.CurrAsmList,lastonlabel);
         { default handling except handling }
         if assigned(t1) then
           begin
              { FPC_CATCHES must be called with
                'default handler' flag (=-1)
              }
              paraloc1.init;
              paramanager.getintparaloc(pocall_default,1,paraloc1);
              paramanager.allocparaloc(current_asmdata.CurrAsmList,paraloc1);
              cg.a_param_const(current_asmdata.CurrAsmList,OS_ADDR,-1,paraloc1);
              paramanager.freeparaloc(current_asmdata.CurrAsmList,paraloc1);
              cg.allocallcpuregisters(current_asmdata.CurrAsmList);
              cg.a_call_name(current_asmdata.CurrAsmList,'FPC_CATCHES');
              cg.deallocallcpuregisters(current_asmdata.CurrAsmList);
              paraloc1.done;

              { the destruction of the exception object must be also }
              { guarded by an exception frame                        }
              current_asmdata.getjumplabel(doobjectdestroy);
              current_asmdata.getjumplabel(doobjectdestroyandreraise);

              get_exception_temps(current_asmdata.CurrAsmList,destroytemps);
              new_exception(current_asmdata.CurrAsmList,destroytemps,doobjectdestroyandreraise);

              { here we don't have to reset flowcontrol           }
              { the default and on flowcontrols are handled equal }
              secondpass(t1);
              exceptflowcontrol:=flowcontrol;

              cg.a_label(current_asmdata.CurrAsmList,doobjectdestroyandreraise);

              free_exception(current_asmdata.CurrAsmList,destroytemps,0,doobjectdestroy,false);

              cg.allocallcpuregisters(current_asmdata.CurrAsmList);
              cg.a_call_name(current_asmdata.CurrAsmList,'FPC_POPSECONDOBJECTSTACK');
              cg.deallocallcpuregisters(current_asmdata.CurrAsmList);

              paraloc1.init;
              paramanager.getintparaloc(pocall_default,1,paraloc1);
              paramanager.allocparaloc(current_asmdata.CurrAsmList,paraloc1);
              cg.a_param_reg(current_asmdata.CurrAsmList, OS_ADDR, NR_FUNCTION_RESULT_REG, paraloc1);
              paramanager.freeparaloc(current_asmdata.CurrAsmList,paraloc1);
              cg.allocallcpuregisters(current_asmdata.CurrAsmList);
              cg.a_call_name(current_asmdata.CurrAsmList,'FPC_DESTROYEXCEPTION');
              cg.deallocallcpuregisters(current_asmdata.CurrAsmList);
              paraloc1.done;
              { we don't need to restore esi here because reraise never }
              { returns                                                 }
              cg.a_call_name(current_asmdata.CurrAsmList,'FPC_RERAISE');

              cg.a_label(current_asmdata.CurrAsmList,doobjectdestroy);
              cleanupobjectstack;
              unget_exception_temps(current_asmdata.CurrAsmList,destroytemps);
              cg.a_jmp_always(current_asmdata.CurrAsmList,endexceptlabel);
           end
         else
           begin
              cg.a_call_name(current_asmdata.CurrAsmList,'FPC_RERAISE');
              exceptflowcontrol:=flowcontrol;
           end;

         if fc_exit in exceptflowcontrol then
           begin
              { do some magic for exit in the try block }
              cg.a_label(current_asmdata.CurrAsmList,exitexceptlabel);
              { we must also destroy the address frame which guards }
              { exception object                                    }
              cg.allocallcpuregisters(current_asmdata.CurrAsmList);
              cg.a_call_name(current_asmdata.CurrAsmList,'FPC_POPADDRSTACK');
              cg.deallocallcpuregisters(current_asmdata.CurrAsmList);
              cg.g_exception_reason_load(current_asmdata.CurrAsmList,excepttemps.reasonbuf);
              cleanupobjectstack;
              cg.a_jmp_always(current_asmdata.CurrAsmList,oldCurrExitLabel);
           end;

         if fc_break in exceptflowcontrol then
           begin
              cg.a_label(current_asmdata.CurrAsmList,breakexceptlabel);
              { we must also destroy the address frame which guards }
              { exception object                                    }
              cg.allocallcpuregisters(current_asmdata.CurrAsmList);
              cg.a_call_name(current_asmdata.CurrAsmList,'FPC_POPADDRSTACK');
              cg.deallocallcpuregisters(current_asmdata.CurrAsmList);
              cg.g_exception_reason_load(current_asmdata.CurrAsmList,excepttemps.reasonbuf);
              cleanupobjectstack;
              cg.a_jmp_always(current_asmdata.CurrAsmList,oldBreakLabel);
           end;

         if fc_continue in exceptflowcontrol then
           begin
              cg.a_label(current_asmdata.CurrAsmList,continueexceptlabel);
              { we must also destroy the address frame which guards }
              { exception object                                    }
              cg.allocallcpuregisters(current_asmdata.CurrAsmList);
              cg.a_call_name(current_asmdata.CurrAsmList,'FPC_POPADDRSTACK');
              cg.deallocallcpuregisters(current_asmdata.CurrAsmList);
              cg.g_exception_reason_load(current_asmdata.CurrAsmList,excepttemps.reasonbuf);
              cleanupobjectstack;
              cg.a_jmp_always(current_asmdata.CurrAsmList,oldContinueLabel);
           end;

         if fc_exit in tryflowcontrol then
           begin
              { do some magic for exit in the try block }
              cg.a_label(current_asmdata.CurrAsmList,exittrylabel);
              cg.allocallcpuregisters(current_asmdata.CurrAsmList);
              cg.a_call_name(current_asmdata.CurrAsmList,'FPC_POPADDRSTACK');
              cg.deallocallcpuregisters(current_asmdata.CurrAsmList);
              cg.g_exception_reason_load(current_asmdata.CurrAsmList,excepttemps.reasonbuf);
              cg.a_jmp_always(current_asmdata.CurrAsmList,oldCurrExitLabel);
           end;

         if fc_break in tryflowcontrol then
           begin
              cg.a_label(current_asmdata.CurrAsmList,breaktrylabel);
              cg.allocallcpuregisters(current_asmdata.CurrAsmList);
              cg.a_call_name(current_asmdata.CurrAsmList,'FPC_POPADDRSTACK');
              cg.deallocallcpuregisters(current_asmdata.CurrAsmList);
              cg.g_exception_reason_load(current_asmdata.CurrAsmList,excepttemps.reasonbuf);
              cg.a_jmp_always(current_asmdata.CurrAsmList,oldBreakLabel);
           end;

         if fc_continue in tryflowcontrol then
           begin
              cg.a_label(current_asmdata.CurrAsmList,continuetrylabel);
              cg.allocallcpuregisters(current_asmdata.CurrAsmList);
              cg.a_call_name(current_asmdata.CurrAsmList,'FPC_POPADDRSTACK');
              cg.deallocallcpuregisters(current_asmdata.CurrAsmList);
              cg.g_exception_reason_load(current_asmdata.CurrAsmList,excepttemps.reasonbuf);
              cg.a_jmp_always(current_asmdata.CurrAsmList,oldContinueLabel);
           end;
         unget_exception_temps(current_asmdata.CurrAsmList,excepttemps);
         cg.a_label(current_asmdata.CurrAsmList,endexceptlabel);

       errorexit:
         { restore all saved labels }
         endexceptlabel:=oldendexceptlabel;

         { restore the control flow labels }
         current_procinfo.CurrExitLabel:=oldCurrExitLabel;
         if assigned(oldBreakLabel) then
          begin
            current_procinfo.CurrContinueLabel:=oldContinueLabel;
            current_procinfo.CurrBreakLabel:=oldBreakLabel;
          end;

         { return all used control flow statements }
         flowcontrol:=oldflowcontrol+exceptflowcontrol+
           tryflowcontrol;
      end;


    procedure tcgonnode.pass_2;
      var
         nextonlabel,
         exitonlabel,
         continueonlabel,
         breakonlabel,
         oldCurrExitLabel,
         oldContinueLabel,
         doobjectdestroyandreraise,
         doobjectdestroy,
         oldBreakLabel : tasmlabel;
         oldflowcontrol : tflowcontrol;
         excepttemps : texceptiontemps;
         exceptref,
         href2: treference;
         paraloc1 : tcgpara;
      begin
         paraloc1.init;
         location_reset(location,LOC_VOID,OS_NO);

         oldflowcontrol:=flowcontrol;
         flowcontrol:=[];
         current_asmdata.getjumplabel(nextonlabel);

         { send the vmt parameter }
         reference_reset_symbol(href2,current_asmdata.newasmsymbol(excepttype.vmt_mangledname,AB_EXTERNAL,AT_DATA),0);
         paramanager.getintparaloc(pocall_default,1,paraloc1);
         paramanager.allocparaloc(current_asmdata.CurrAsmList,paraloc1);
         cg.a_paramaddr_ref(current_asmdata.CurrAsmList,href2,paraloc1);
         paramanager.freeparaloc(current_asmdata.CurrAsmList,paraloc1);
         cg.allocallcpuregisters(current_asmdata.CurrAsmList);
         cg.a_call_name(current_asmdata.CurrAsmList,'FPC_CATCHES');
         cg.deallocallcpuregisters(current_asmdata.CurrAsmList);

         { is it this catch? No. go to next onlabel }
         cg.a_cmp_const_reg_label(current_asmdata.CurrAsmList,OS_ADDR,OC_EQ,0,NR_FUNCTION_RESULT_REG,nextonlabel);

         { what a hack ! }
         if assigned(exceptsymtable) then
           begin
             tlocalvarsym(exceptsymtable.symindex.first).localloc.loc:=LOC_REFERENCE;
             tlocalvarsym(exceptsymtable.symindex.first).localloc.size:=OS_ADDR;
             tg.GetLocal(current_asmdata.CurrAsmList,sizeof(aint),voidpointertype.def,
                tlocalvarsym(exceptsymtable.symindex.first).localloc.reference);
             cg.a_load_reg_ref(current_asmdata.CurrAsmList,OS_ADDR,OS_ADDR,NR_FUNCTION_RESULT_REG,tlocalvarsym(exceptsymtable.symindex.first).localloc.reference);
           end
         else
           begin
             tg.GetTemp(current_asmdata.CurrAsmList,sizeof(aint),tt_normal,exceptref);
             cg.a_load_reg_ref(current_asmdata.CurrAsmList,OS_ADDR,OS_ADDR,NR_FUNCTION_RESULT_REG,exceptref);
           end;

         { in the case that another exception is risen
           we've to destroy the old one                }
         current_asmdata.getjumplabel(doobjectdestroyandreraise);

         { call setjmp, and jump to finally label on non-zero result }
         get_exception_temps(current_asmdata.CurrAsmList,excepttemps);
         new_exception(current_asmdata.CurrAsmList,excepttemps,doobjectdestroyandreraise);

         oldBreakLabel:=nil;
         oldContinueLabel:=nil;
         if assigned(right) then
           begin
              oldCurrExitLabel:=current_procinfo.CurrExitLabel;
              current_asmdata.getjumplabel(exitonlabel);
              current_procinfo.CurrExitLabel:=exitonlabel;
              if assigned(current_procinfo.CurrBreakLabel) then
               begin
                 oldContinueLabel:=current_procinfo.CurrContinueLabel;
                 oldBreakLabel:=current_procinfo.CurrBreakLabel;
                 current_asmdata.getjumplabel(breakonlabel);
                 current_asmdata.getjumplabel(continueonlabel);
                 current_procinfo.CurrContinueLabel:=continueonlabel;
                 current_procinfo.CurrBreakLabel:=breakonlabel;
               end;

              secondpass(right);
           end;
         current_asmdata.getjumplabel(doobjectdestroy);
         cg.a_label(current_asmdata.CurrAsmList,doobjectdestroyandreraise);

         free_exception(current_asmdata.CurrAsmList,excepttemps,0,doobjectdestroy,false);

         cg.allocallcpuregisters(current_asmdata.CurrAsmList);
         cg.a_call_name(current_asmdata.CurrAsmList,'FPC_POPSECONDOBJECTSTACK');
         cg.deallocallcpuregisters(current_asmdata.CurrAsmList);
         paramanager.getintparaloc(pocall_default,1,paraloc1);
         paramanager.allocparaloc(current_asmdata.CurrAsmList,paraloc1);
         cg.a_param_reg(current_asmdata.CurrAsmList, OS_ADDR, NR_FUNCTION_RESULT_REG, paraloc1);
         paramanager.freeparaloc(current_asmdata.CurrAsmList,paraloc1);
         cg.allocallcpuregisters(current_asmdata.CurrAsmList);
         cg.a_call_name(current_asmdata.CurrAsmList,'FPC_DESTROYEXCEPTION');
         cg.deallocallcpuregisters(current_asmdata.CurrAsmList);
         { we don't need to store/restore registers here because reraise never
           returns                                                             }
         cg.a_call_name(current_asmdata.CurrAsmList,'FPC_RERAISE');

         cg.a_label(current_asmdata.CurrAsmList,doobjectdestroy);
         cleanupobjectstack;
         { clear some stuff }
         if assigned(exceptsymtable) then
           begin
             tg.UngetLocal(current_asmdata.CurrAsmList,tlocalvarsym(exceptsymtable.symindex.first).localloc.reference);
             tlocalvarsym(exceptsymtable.symindex.first).localloc.loc:=LOC_INVALID;
           end
         else
           tg.Ungettemp(current_asmdata.CurrAsmList,exceptref);
         cg.a_jmp_always(current_asmdata.CurrAsmList,endexceptlabel);

         if assigned(right) then
           begin
              { special handling for control flow instructions }
              if fc_exit in flowcontrol then
                begin
                   { the address and object pop does secondtryexcept }
                   cg.a_label(current_asmdata.CurrAsmList,exitonlabel);
                   cg.a_jmp_always(current_asmdata.CurrAsmList,oldCurrExitLabel);
                end;

              if fc_break in flowcontrol then
                begin
                   { the address and object pop does secondtryexcept }
                   cg.a_label(current_asmdata.CurrAsmList,breakonlabel);
                   cg.a_jmp_always(current_asmdata.CurrAsmList,oldBreakLabel);
                end;

              if fc_continue in flowcontrol then
                begin
                   { the address and object pop does secondtryexcept }
                   cg.a_label(current_asmdata.CurrAsmList,continueonlabel);
                   cg.a_jmp_always(current_asmdata.CurrAsmList,oldContinueLabel);
                end;

              current_procinfo.CurrExitLabel:=oldCurrExitLabel;
              if assigned(oldBreakLabel) then
               begin
                 current_procinfo.CurrContinueLabel:=oldContinueLabel;
                 current_procinfo.CurrBreakLabel:=oldBreakLabel;
               end;
           end;

         unget_exception_temps(current_asmdata.CurrAsmList,excepttemps);
         cg.a_label(current_asmdata.CurrAsmList,nextonlabel);
         flowcontrol:=oldflowcontrol+flowcontrol;
         paraloc1.done;

         { next on node }
         if assigned(left) then
           secondpass(left);
      end;

{*****************************************************************************
                             SecondTryFinally
*****************************************************************************}

    procedure tcgtryfinallynode.pass_2;
      var
         reraiselabel,
         finallylabel,
         endfinallylabel,
         exitfinallylabel,
         continuefinallylabel,
         breakfinallylabel,
         oldCurrExitLabel,
         oldContinueLabel,
         oldBreakLabel : tasmlabel;
         oldflowcontrol,tryflowcontrol : tflowcontrol;
         decconst : longint;
         excepttemps : texceptiontemps;
      begin
         location_reset(location,LOC_VOID,OS_NO);

         { check if child nodes do a break/continue/exit }
         oldflowcontrol:=flowcontrol;
         flowcontrol:=[];
         current_asmdata.getjumplabel(finallylabel);
         current_asmdata.getjumplabel(endfinallylabel);
         current_asmdata.getjumplabel(reraiselabel);

         { the finally block must catch break, continue and exit }
         { statements                                            }
         oldCurrExitLabel:=current_procinfo.CurrExitLabel;
         if implicitframe then
           exitfinallylabel:=finallylabel
         else
           current_asmdata.getjumplabel(exitfinallylabel);
         current_procinfo.CurrExitLabel:=exitfinallylabel;
         if assigned(current_procinfo.CurrBreakLabel) then
          begin
            oldContinueLabel:=current_procinfo.CurrContinueLabel;
            oldBreakLabel:=current_procinfo.CurrBreakLabel;
            if implicitframe then
              begin
                breakfinallylabel:=finallylabel;
                continuefinallylabel:=finallylabel;
              end
            else
              begin
                current_asmdata.getjumplabel(breakfinallylabel);
                current_asmdata.getjumplabel(continuefinallylabel);
              end;
            current_procinfo.CurrContinueLabel:=continuefinallylabel;
            current_procinfo.CurrBreakLabel:=breakfinallylabel;
          end;

         { call setjmp, and jump to finally label on non-zero result }
         get_exception_temps(current_asmdata.CurrAsmList,excepttemps);
         new_exception(current_asmdata.CurrAsmList,excepttemps,finallylabel);

         { try code }
         if assigned(left) then
           begin
              secondpass(left);
              tryflowcontrol:=flowcontrol;
              if codegenerror then
                exit;
           end;

         cg.a_label(current_asmdata.CurrAsmList,finallylabel);
         { just free the frame information }
         free_exception(current_asmdata.CurrAsmList,excepttemps,1,finallylabel,true);

         { finally code }
         flowcontrol:=[];
         secondpass(right);
         if flowcontrol<>[] then
           CGMessage(cg_e_control_flow_outside_finally);
         if codegenerror then
           exit;

         { the value should now be in the exception handler }
         cg.g_exception_reason_load(current_asmdata.CurrAsmList,excepttemps.reasonbuf);
         if implicitframe then
           begin
             cg.a_cmp_const_reg_label(current_asmdata.CurrAsmList,OS_INT,OC_EQ,0,NR_FUNCTION_RESULT_REG,endfinallylabel);
             { finally code only needed to be executed on exception }
             flowcontrol:=[];
             secondpass(t1);
             if flowcontrol<>[] then
               CGMessage(cg_e_control_flow_outside_finally);
             if codegenerror then
               exit;
             cg.a_call_name(current_asmdata.CurrAsmList,'FPC_RERAISE');
           end
         else
           begin
             cg.a_cmp_const_reg_label(current_asmdata.CurrAsmList,OS_INT,OC_EQ,0,NR_FUNCTION_RESULT_REG,endfinallylabel);
             cg.a_op_const_reg(current_asmdata.CurrAsmList,OP_SUB,OS_INT,1,NR_FUNCTION_RESULT_REG);
             cg.a_cmp_const_reg_label(current_asmdata.CurrAsmList,OS_INT,OC_EQ,0,NR_FUNCTION_RESULT_REG,reraiselabel);
             if fc_exit in tryflowcontrol then
               begin
                  cg.a_op_const_reg(current_asmdata.CurrAsmList,OP_SUB,OS_INT,1,NR_FUNCTION_RESULT_REG);
                  cg.a_cmp_const_reg_label(current_asmdata.CurrAsmList,OS_INT,OC_EQ,0,NR_FUNCTION_RESULT_REG,oldCurrExitLabel);
                  decconst:=1;
               end
             else
               decconst:=2;
             if fc_break in tryflowcontrol then
               begin
                  cg.a_op_const_reg(current_asmdata.CurrAsmList,OP_SUB,OS_INT,decconst,NR_FUNCTION_RESULT_REG);
                  cg.a_cmp_const_reg_label(current_asmdata.CurrAsmList,OS_INT,OC_EQ,0,NR_FUNCTION_RESULT_REG,oldBreakLabel);
                  decconst:=1;
               end
             else
               inc(decconst);
             if fc_continue in tryflowcontrol then
               begin
                  cg.a_op_const_reg(current_asmdata.CurrAsmList,OP_SUB,OS_INT,decconst,NR_FUNCTION_RESULT_REG);
                  cg.a_cmp_const_reg_label(current_asmdata.CurrAsmList,OS_INT,OC_EQ,0,NR_FUNCTION_RESULT_REG,oldContinueLabel);
               end;
             cg.a_label(current_asmdata.CurrAsmList,reraiselabel);
             cg.a_call_name(current_asmdata.CurrAsmList,'FPC_RERAISE');
             { do some magic for exit,break,continue in the try block }
             if fc_exit in tryflowcontrol then
               begin
                  cg.a_label(current_asmdata.CurrAsmList,exitfinallylabel);
                  cg.g_exception_reason_load(current_asmdata.CurrAsmList,excepttemps.reasonbuf);
                  cg.g_exception_reason_save_const(current_asmdata.CurrAsmList,excepttemps.reasonbuf,2);
                  cg.a_jmp_always(current_asmdata.CurrAsmList,finallylabel);
               end;
             if fc_break in tryflowcontrol then
              begin
                 cg.a_label(current_asmdata.CurrAsmList,breakfinallylabel);
                 cg.g_exception_reason_load(current_asmdata.CurrAsmList,excepttemps.reasonbuf);
                 cg.g_exception_reason_save_const(current_asmdata.CurrAsmList,excepttemps.reasonbuf,3);
                 cg.a_jmp_always(current_asmdata.CurrAsmList,finallylabel);
               end;
             if fc_continue in tryflowcontrol then
               begin
                  cg.a_label(current_asmdata.CurrAsmList,continuefinallylabel);
                  cg.g_exception_reason_load(current_asmdata.CurrAsmList,excepttemps.reasonbuf);
                  cg.g_exception_reason_save_const(current_asmdata.CurrAsmList,excepttemps.reasonbuf,4);
                  cg.a_jmp_always(current_asmdata.CurrAsmList,finallylabel);
               end;
           end;
         unget_exception_temps(current_asmdata.CurrAsmList,excepttemps);
         cg.a_label(current_asmdata.CurrAsmList,endfinallylabel);

         current_procinfo.CurrExitLabel:=oldCurrExitLabel;
         if assigned(current_procinfo.CurrBreakLabel) then
          begin
            current_procinfo.CurrContinueLabel:=oldContinueLabel;
            current_procinfo.CurrBreakLabel:=oldBreakLabel;
          end;
         flowcontrol:=oldflowcontrol+tryflowcontrol;
      end;


begin
   cwhilerepeatnode:=tcgwhilerepeatnode;
   cifnode:=tcgifnode;
   cfornode:=tcgfornode;
   cexitnode:=tcgexitnode;
   cbreaknode:=tcgbreaknode;
   ccontinuenode:=tcgcontinuenode;
   cgotonode:=tcggotonode;
   clabelnode:=tcglabelnode;
   craisenode:=tcgraisenode;
   ctryexceptnode:=tcgtryexceptnode;
   ctryfinallynode:=tcgtryfinallynode;
   connode:=tcgonnode;
end.
