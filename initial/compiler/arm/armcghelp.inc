CONST
use_framepointer = false;
MAX_VIRTUAL_TEMPREGS_PER_INSTR = 1;
{$note FIXME: only one virtual reg supported for VIRTUALLOAD/SAVE}

function tcgarm.invertop(op : TAsmOp) : TAsmOp;
begin
  case op of
    A_MOV : invertop :=A_MVN;
    A_ORR : invertop :=A_BIC;
    A_BIC : invertop :=A_ORR;
    A_SUB : invertop :=A_ADD;
    A_ADD : invertop :=A_SUB;
    A_LDR : invertop :=A_STR;
    A_STR : invertop :=A_LDR;
    else internalerror(200803309);
  end;
end;

function tcgarm.do_inv(op : TAsmOp; b : boolean) : TAsmOp;
begin
  if b then do_inv := invertop(op)
  else do_inv := op;  
end;

procedure tcgarm.concatMovSplitConst(list : TAsmList; sc : Tsplitconst; reg : Tregister);
VAR i : longint;
begin
  if (sc.parts=0) then internalerror(200804051);
  list.concat(taicpu.op_reg_const(do_inv(A_MOV,sc.inv),reg,sc.part[0]));
  for i := 1 to sc.parts-1 do begin
    list.concat(taicpu.op_reg_reg_const(do_inv(A_ORR,sc.inv),reg,reg,sc.part[i]));
  end;
end;

function tcgarm.calc_prefered_transfersize(tcgs1 : TCGsize) : longint;
var ts1 : longint;
begin
  ts1 := 1;
  case tcgs1 of
    OS_8, OS_S8  : ts1 := 1;
    OS_16,OS_S16 : ts1 := 2;
    OS_32,OS_S32 : ts1 := 4;
    OS_64,OS_S64 : ts1 := 8;
  end;
  calc_prefered_transfersize := ts1;
end;


function tcgarm.test_aligned(regsize,refsize : TCGsize; const ref : Treference) : boolean;
var prets : longint;
begin
  prets := calc_prefered_transfersize(refsize);
  if (ref.alignment=0)or(ref.alignment=prets) 
  then test_aligned := true 
  else test_aligned := false;
end;

function tcgarm.is_simple_ref(const ref : Treference; refsize : TCGsize) : boolean;
var ts : longint;
begin
  ts := calc_prefered_transfersize(refsize);
  is_simple_ref := valid_ARMoffset(ref.offset,ts)
                   and test_aligned(refsize,refsize,ref);
end;

function tcgarm.calc_needed_tempregs(op : Tasmop; fromsize,tosize : Tcgsize; a1,a2 : longint; const ref : Treference) : longint;
VAR refsize,regsize : TCGsize;
begin
  if op=A_ZZZ_VIRTUALLOAD then begin
    refsize := fromsize;
    regsize := tosize;
  end else begin
    refsize := tosize;
    regsize := fromsize;
  end;
  result := 0;
  case op of
    A_ZZZ_VIRTUALCOPY : result := 3;
    A_ZZZ_VIRTUALLOAD : if test_aligned(regsize,refsize,ref) 
                        then result := 0
                        else result := 2;
    { For save, often waste 1 tempreg on easy offsets;
      not ideal, but since tempregs of these instrcutions
      are virtually used only by the one virtual
      instruction, the following code can take advantage 
      of the (then) freed reg, so this isn't too dramatic.
      The only way around this would be to force the use
      of a framepointer, that makes offsets independent
      of actual stack layout, thus making offsets known
      at body-compilation time. However, in that case,
      following code normally can't make use of the 
      (then all-time-)allocated framepointer-reg. 
    }
    A_ZZZ_VIRTUALSAVE : if use_framepointer and is_simple_ref(ref,refsize)
                        then result := 0
                        else result := 1;
  end;
//  result := 1;
end;


function tcgarm.get_real_tempregs(list : Tasmlist; real_tempregs : longint) : Tcpuregisterset;
var i : longint; rs : Tcpuregisterset;
const fixed_tempreg : ARRAY[1..6] of Tsuperregister = (RS_R4,RS_R5,RS_R6,RS_R7,RS_R8,RS_R9);
begin
  if (real_tempregs<=0) then exit;
  rs := [];
  for i := 1 to real_tempregs do begin
    include(rs,fixed_tempreg[i]);
  end;
  get_real_tempregs := rs;
  alloccpuregisters(list,R_INTREGISTER,rs);
end;


procedure tcgarm.put_virtual_meminstr(list : Tasmlist; op : Tasmop; fromsize,tosize : Tcgsize; len : aint; const srcref,dstref : Treference; reg : Tregister);
var reglist : Treglist; 
    regsetlist : Tregsetlist;  
    reflist : Treflist;
    needed_tempregs,virtual_tempregs,real_tempregs,
    instrregs,instrrefs,i,j : longint;
    thisai : Taicpu;
begin

  needed_tempregs  := calc_needed_tempregs(op,fromsize,tosize,srcref.alignment,dstref.alignment,dstref);
  virtual_tempregs := min(needed_tempregs,MAX_VIRTUAL_TEMPREGS_PER_INSTR);


  if (op=A_ZZZ_VIRTUALCOPY) then begin
{$note FIXME: VIRTUALCOPY can't use any virtual regs}
    virtual_tempregs := 0;
  end;

  real_tempregs := needed_tempregs - virtual_tempregs;

  instrrefs := 1;
  if (op = A_ZZZ_VIRTUALCOPY) then instrrefs := 2;

  { if the chosen instruction-layout doesn't fit into 
    something that looks similar to a real instruction,
    make virtual regs into real ones:
  }
  while ((instrrefs+virtual_tempregs+ord(real_tempregs>0))>max_operands) do begin
    inc(real_tempregs);
    dec(virtual_tempregs);
  end;

  regsetlist[0] := get_real_tempregs(list,real_tempregs);

  j := 0;
  instrregs := virtual_tempregs;
  if (op in [A_ZZZ_VIRTUALLOAD,A_ZZZ_VIRTUALSAVE]) then begin
    inc(instrregs);
    reglist[0] := reg;
    j := 1;
  end;
  for i := 1 to virtual_tempregs do begin
    reglist[j] := getintregister(list,OS_ADDR);
    inc(j);
  end;

  reflist[0] := srcref;
  reflist[1] := dstref;


  // this is only here until the virtual instr. are expanded
  // up till then, this avoids some internalerror@asmwriter
  if assigned(reflist[0].symbol) then reflist[0].base := NR_PC;
  if assigned(reflist[1].symbol) then reflist[1].base := NR_PC;



  thisai := taicpu.op_variable(op,instrregs,ord(real_tempregs>0),instrrefs,reglist,regsetlist,reflist);
  thisai.sizefrom := fromsize;
  thisai.sizeto   := tosize;
  thisai.copylen  := len;
  list.concat(thisai);

  dealloccpuregisters(list,R_INTREGISTER,regsetlist[0]);
end;



function tcgarm.valid_ARMoffset(o,transactionsize : longint) : boolean;
begin
  case transactionsize of
    1,4 : valid_ARMoffset := (o>-4095)and(o<4095);
    2,8 : valid_ARMoffset := (o>-255 )and(o< 255);
    else valid_ARMoffset := false;
  end;
end;


procedure tcgarm.emit_comment(list : Tasmlist; s : string);
var p : pchar;
begin
  s := s + #0;
  getmem(p,length(s));
  move(s[1],p[0],length(s)); 
  list.concat(tai_comment.create(p));
end;

procedure tcgarm.emit_rol(list : Tasmlist; treg : Tregister; cnt : longint);
var so : tshifterop;
begin
  cnt := -cnt;
  if (cnt and 31)=0 then exit;
  shifterop_reset(so);
  so.shiftmode:=SM_ROR;
  so.shiftimm:=cnt and 31;
  list.concat(taicpu.op_reg_reg_shifterop(A_MOV,treg,treg,so));
end;
