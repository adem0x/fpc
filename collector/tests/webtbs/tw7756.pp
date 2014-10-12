program tw7756;

{$mode objfpc}

uses Variants, SysUtils;

var
//  s : string;
  cp, cd, ci, ce, cg : integer; //iterators
  fr : TFloatRec;
  v : variant;
  precs : array [1..3] of integer = (0, 15, 50);
  decs : array [1..6] of integer =
      (0, 5, 15, 25, 50, 60);
  i : array [1..7] of integer = (-9057, -9194, -9059, 0, 9057, 9194, 9059);
  e : array [1..11] of extended = (
        -1.1E256, -5.5E256, -1.1E-256, -5.5E-256, -pi, 0.0,  pi, 1.1E-256, 5.5E-256, 1.1E256, 5.5E256);

const results: array[1..324] of string =
{$ifdef FPC_HAS_TYPE_EXTENDED}
('257-',
'258-1',
'-255-',
'-255-',
'1-',
'0+',
'1+',
'-255+',
'-255+',
'257+',
'258+1',
'257-',
'258-1',
'-255-',
'-255-',
'1-',
'0+',
'1+',
'-255+',
'-255+',
'257+',
'258+1',
'257-',
'258-1',
'-255-',
'-255-',
'1-',
'0+',
'1+',
'-255+',
'-255+',
'257+',
'258+1',
'257-',
'258-1',
'-255-',
'-255-',
'1-',
'0+',
'1+',
'-255+',
'-255+',
'257+',
'258+1',
'257-',
'258-1',
'-255-',
'-255-',
'1-',
'0+',
'1+',
'-255+',
'-255+',
'257+',
'258+1',
'257-',
'258-1',
'-255-',
'-255-',
'1-',
'0+',
'1+',
'-255+',
'-255+',
'257+',
'258+1',
'257-11',
'257-55',
'-255-',
'-255-',
'1-3',
'0+',
'1+3',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-314159',
'0+',
'1+314159',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-314159265358979',
'0+',
'1+314159265358979',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-314159265358979',
'0+',
'1+314159265358979',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-314159265358979',
'0+',
'1+314159265358979',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-314159265358979',
'0+',
'1+314159265358979',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-54999999999999998',
'-255-',
'-255-',
'1-3',
'0+',
'1+3',
'-255+',
'-255+',
'257+11',
'257+54999999999999998',
'257-11',
'257-54999999999999998',
'-255-',
'-255-',
'1-314159',
'0+',
'1+314159',
'-255+',
'-255+',
'257+11',
'257+54999999999999998',
'257-11',
'257-54999999999999998',
'-255-',
'-255-',
'1-3141592653589793',
'0+',
'1+3141592653589793',
'-255+',
'-255+',
'257+11',
'257+54999999999999998',
'257-11',
'257-54999999999999998',
'-255-',
'-255-',
'1-31415926535897931',
'0+',
'1+31415926535897931',
'-255+',
'-255+',
'257+11',
'257+54999999999999998',
'257-11',
'257-54999999999999998',
'-255-',
'-255-',
'1-31415926535897931',
'0+',
'1+31415926535897931',
'-255+',
'-255+',
'257+11',
'257+54999999999999998',
'257-11',
'257-54999999999999998',
'-255-',
'-255-',
'1-31415926535897931',
'0+',
'1+31415926535897931',
'-255+',
'-255+',
'257+11',
'257+54999999999999998',
'5-1',
'5-1',
'5-1',
'0+',
'5+1',
'5+1',
'5+1',
'5-1',
'5-1',
'5-1',
'0+',
'5+1',
'5+1',
'5+1',
'5-1',
'5-1',
'5-1',
'0+',
'5+1',
'5+1',
'5+1',
'5-1',
'5-1',
'5-1',
'0+',
'5+1',
'5+1',
'5+1',
'5-1',
'5-1',
'5-1',
'0+',
'5+1',
'5+1',
'5+1',
'5-1',
'5-1',
'5-1',
'0+',
'5+1',
'5+1',
'5+1',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059');
{$else}
('257-',
'258-1',
'-255-',
'-255-',
'1-',
'0+',
'1+',
'-255+',
'-255+',
'257+',
'258+1',
'257-',
'258-1',
'-255-',
'-255-',
'1-',
'0+',
'1+',
'-255+',
'-255+',
'257+',
'258+1',
'257-',
'258-1',
'-255-',
'-255-',
'1-',
'0+',
'1+',
'-255+',
'-255+',
'257+',
'258+1',
'257-',
'258-1',
'-255-',
'-255-',
'1-',
'0+',
'1+',
'-255+',
'-255+',
'257+',
'258+1',
'257-',
'258-1',
'-255-',
'-255-',
'1-',
'0+',
'1+',
'-255+',
'-255+',
'257+',
'258+1',
'257-',
'258-1',
'-255-',
'-255-',
'1-',
'0+',
'1+',
'-255+',
'-255+',
'257+',
'258+1',
'257-11',
'257-55',
'-255-',
'-255-',
'1-3',
'0+',
'1+3',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-314159',
'0+',
'1+314159',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-314159265358979',
'0+',
'1+314159265358979',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-314159265358979',
'0+',
'1+314159265358979',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-314159265358979',
'0+',
'1+314159265358979',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-314159265358979',
'0+',
'1+314159265358979',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-3',
'0+',
'1+3',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-314159',
'0+',
'1+314159',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-314159265358979',
'0+',
'1+314159265358979',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-314159265358979',
'0+',
'1+314159265358979',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-314159265358979',
'0+',
'1+314159265358979',
'-255+',
'-255+',
'257+11',
'257+55',
'257-11',
'257-55',
'-255-',
'-255-',
'1-314159265358979',
'0+',
'1+314159265358979',
'-255+',
'-255+',
'257+11',
'257+55',
'5-1',
'5-1',
'5-1',
'0+',
'5+1',
'5+1',
'5+1',
'5-1',
'5-1',
'5-1',
'0+',
'5+1',
'5+1',
'5+1',
'5-1',
'5-1',
'5-1',
'0+',
'5+1',
'5+1',
'5+1',
'5-1',
'5-1',
'5-1',
'0+',
'5+1',
'5+1',
'5+1',
'5-1',
'5-1',
'5-1',
'0+',
'5+1',
'5+1',
'5+1',
'5-1',
'5-1',
'5-1',
'0+',
'5+1',
'5+1',
'5+1',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059',
'4-9057',
'4-9194',
'4-9059',
'0+',
'4+9057',
'4+9194',
'4+9059');
{$endif}

function DecimalToStr(fr: TFloatRec): string;
var
  s : string;
begin
        s := IntToStr(fr.Exponent);
        if fr.Negative
          then s := s+ '-'
          else s := s+ '+';
        s := s + StrPas(@fr.Digits[0]);
        Result := s;
end;

BEGIN
  cg := 1; // grid row index
  for cp := Low(Precs) to High(Precs) do  //itarete through precisions
    for cd := Low(decs) to High(decs) do  //itarete through decimals
      for ce := Low(e) to High(e) do  //itarete through extended values
        begin
//        write(IntToStr(precs[cp]):2,';',IntToStr(decs[cd]):2,';');
//        str(e[ce]:250, s); s := Trim(s);
        v := e[ce];
//        write(s:25, ';');
        FloatToDecimal(fr, v, precs[cp], decs[cd]);
//        write(DecimalToStr(fr):25, ';');
//        writeln(DecimalToStr(fr));
        if DecimalToStr(fr) <> results[cg] then
          halt(1);
        inc(cg);
        end;
  // integers
  for cp := Low(Precs) to High(Precs) do  //itarete through precisions
    for cd := Low(decs) to High(decs) do  //itarete through decimals
      for ci := Low(i) to High(i) do  //itarete through integers
        begin
//        write(IntToStr(precs[cp]):2, ';', IntToStr(decs[cd]):2, ';');
//        s := IntToStr(i[ci]);
        v := i[ci];
//        write(s:25, ';');
        FloatToDecimal(fr, v, precs[cp], decs[cd]);
//        write(DecimalToStr(fr):25, ';');
//        writeln(DecimalToStr(fr));
        if DecimalToStr(fr) <> results[cg] then
          halt(1);
        inc(cg);
        end;
END.

