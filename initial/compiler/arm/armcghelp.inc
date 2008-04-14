

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