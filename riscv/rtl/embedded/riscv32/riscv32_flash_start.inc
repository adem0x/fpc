var
 _stack_top: record end; external name '_stack_top';
 _data: record end; external name '_data';
 _edata: record end; external name '_edata';
 _text_start: record end; external name '_text_start';
 _etext: record end; external name '_etext';
 _bss_start: record end; external name '_bss_start';
 _bss_end: record end; external name '_bss_end';

procedure Pascalmain; external name 'PASCALMAIN';

procedure HaltProc; assembler; nostackframe; public name'_haltproc';
asm
.Lloop:
   j .Lloop
end;

procedure Startup; assembler; nostackframe; [public, alias: '_START'];
asm
  jal RA, PASCALMAIN
  j HaltProc
end;