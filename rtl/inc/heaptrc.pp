{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by the Free Pascal development team.

    Heap tracer

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit heaptrc;
interface

{$ifdef FPC_HEAPTRC_EXTRA}
  {$define EXTRA}
{$endif FPC_HEAPTRC_EXTRA}

{$checkpointer off}
{$goto on}

{$if defined(win32) or defined(wince)}
  {$define windows}
{$endif}

Procedure DumpHeap;

{ define EXTRA to add more
  tests :
   - keep all memory after release and
   check by CRC value if not changed after release
   WARNING this needs extremely much memory (PM) }

type
   tFillExtraInfoProc = procedure(p : pointer);
   tdisplayextrainfoProc = procedure (var ptext : text;p : pointer);

{ Allows to add info pre memory block, see ppheap.pas of the compiler
  for example source }
procedure SetHeapExtraInfo( size : ptrint;fillproc : tfillextrainfoproc;displayproc : tdisplayextrainfoproc);

{ Redirection of the output to a file }
procedure SetHeapTraceOutput(const name : string);

const
  { tracing level
    splitted in two if memory is released !! }
{$ifdef EXTRA}
  tracesize = 16;
{$else EXTRA}
  tracesize = 8;
{$endif EXTRA}
  { install heaptrc memorymanager }
  useheaptrace : boolean=true;
  { less checking }
  quicktrace : boolean=true;
  { calls halt() on error by default !! }
  HaltOnError : boolean = true;
  { Halt on exit if any memory was not freed }
  HaltOnNotReleased : boolean = false;

  { set this to true if you suspect that memory
    is freed several times }
{$ifdef EXTRA}
  keepreleased : boolean=true;
{$else EXTRA}
  keepreleased : boolean=false;
{$endif EXTRA}
  { add a small footprint at the end of memory blocks, this
    can check for memory overwrites at the end of a block }
  add_tail : boolean = true;
  { put crc in sig
    this allows to test for writing into that part }
  usecrc : boolean = true;


implementation

type
   pptrint = ^ptrint;

const
  { allows to add custom info in heap_mem_info, this is the size that will
    be allocated for this information }
  extra_info_size : ptrint = 0;
  exact_info_size : ptrint = 0;
  EntryMemUsed    : ptrint = 0;
  { function to fill this info up }
  fill_extra_info_proc : TFillExtraInfoProc = nil;
  display_extra_info_proc : TDisplayExtraInfoProc = nil;
  error_in_heap : boolean = false;
  inside_trace_getmem : boolean = false;
  { indicates where the output will be redirected }
  { only set using environment variables          }
  outputstr : shortstring = '';

type
  pheap_extra_info = ^theap_extra_info;
  theap_extra_info = record
    check       : cardinal;  { used to check if the procvar is still valid }
    fillproc    : tfillextrainfoProc;
    displayproc : tdisplayextrainfoProc;
    data : record
           end;
  end;

  { warning the size of theap_mem_info
    must be a multiple of 8
    because otherwise you will get
    problems when releasing the usual memory part !!
    sizeof(theap_mem_info = 16+tracesize*4 so
    tracesize must be even !! PM }
  pheap_mem_info = ^theap_mem_info;
  theap_mem_info = record
    previous,
    next     : pheap_mem_info;
    size     : ptrint;
    sig      : longword;
{$ifdef EXTRA}
    release_sig : longword;
    prev_valid  : pheap_mem_info;
{$endif EXTRA}
    calls    : array [1..tracesize] of pointer;
    exact_info_size : word;
    extra_info_size : word;
    extra_info      : pheap_extra_info;
  end;

var
  useownfile : boolean;
  ownfile : text;
{$ifdef EXTRA}
  error_file : text;
  heap_valid_first,
  heap_valid_last : pheap_mem_info;
{$endif EXTRA}
  heap_mem_root : pheap_mem_info;
  getmem_cnt,
  freemem_cnt   : ptrint;
  getmem_size,
  freemem_size   : ptrint;
  getmem8_size,
  freemem8_size   : ptrint;


{*****************************************************************************
                                   Crc 32
*****************************************************************************}

var
  Crc32Tbl : array[0..255] of longword;

procedure MakeCRC32Tbl;
var
  crc : longword;
  i,n : byte;
begin
  for i:=0 to 255 do
   begin
     crc:=i;
     for n:=1 to 8 do
      if odd(crc) then
       crc:=(crc shr 1) xor $edb88320
      else
       crc:=crc shr 1;
     Crc32Tbl[i]:=crc;
   end;
end;


Function UpdateCrc32(InitCrc:longword;var InBuf;InLen:ptrint):longword;
var
  i : ptrint;
  p : pchar;
begin
  p:=@InBuf;
  for i:=1 to InLen do
   begin
     InitCrc:=Crc32Tbl[byte(InitCrc) xor byte(p^)] xor (InitCrc shr 8);
     inc(p);
   end;
  UpdateCrc32:=InitCrc;
end;

Function calculate_sig(p : pheap_mem_info) : longword;
var
   crc : longword;
   pl : pptrint;
begin
   crc:=cardinal($ffffffff);
   crc:=UpdateCrc32(crc,p^.size,sizeof(ptrint));
   crc:=UpdateCrc32(crc,p^.calls,tracesize*sizeof(ptrint));
   if p^.extra_info_size>0 then
     crc:=UpdateCrc32(crc,p^.extra_info^,p^.exact_info_size);
   if add_tail then
     begin
        { Check also 4 bytes just after allocation !! }
        pl:=pointer(p)+p^.extra_info_size+sizeof(theap_mem_info)+p^.size;
        crc:=UpdateCrc32(crc,pl^,sizeof(ptrint));
     end;
   calculate_sig:=crc;
end;

{$ifdef EXTRA}
Function calculate_release_sig(p : pheap_mem_info) : longword;
var
   crc : longword;
   pl : pptrint;
begin
   crc:=$ffffffff;
   crc:=UpdateCrc32(crc,p^.size,sizeof(ptrint));
   crc:=UpdateCrc32(crc,p^.calls,tracesize*sizeof(ptrint));
   if p^.extra_info_size>0 then
     crc:=UpdateCrc32(crc,p^.extra_info^,p^.exact_info_size);
   { Check the whole of the whole allocation }
   pl:=pointer(p)+p^.extra_info_size+sizeof(theap_mem_info);
   crc:=UpdateCrc32(crc,pl^,p^.size);
   { Check also 4 bytes just after allocation !! }
   if add_tail then
     begin
        { Check also 4 bytes just after allocation !! }
        pl:=pointer(p)+p^.extra_info_size+sizeof(theap_mem_info)+p^.size;
        crc:=UpdateCrc32(crc,pl^,sizeof(ptrint));
     end;
   calculate_release_sig:=crc;
end;
{$endif EXTRA}


{*****************************************************************************
                                Helpers
*****************************************************************************}

procedure call_stack(pp : pheap_mem_info;var ptext : text);
var
  i  : ptrint;
begin
  writeln(ptext,'Call trace for block $',hexstr(ptrint(pointer(pp)+sizeof(theap_mem_info)),2*sizeof(pointer)),' size ',pp^.size);
  for i:=1 to tracesize do
   if pp^.calls[i]<>nil then
     writeln(ptext,BackTraceStrFunc(pp^.calls[i]));
  { the check is done to be sure that the procvar is not overwritten }
  if assigned(pp^.extra_info) and
     (pp^.extra_info^.check=$12345678) and
     assigned(pp^.extra_info^.displayproc) then
   pp^.extra_info^.displayproc(ptext,@pp^.extra_info^.data);
end;


procedure call_free_stack(pp : pheap_mem_info;var ptext : text);
var
  i  : ptrint;
begin
  writeln(ptext,'Call trace for block at $',hexstr(ptrint(pointer(pp)+sizeof(theap_mem_info)),2*sizeof(pointer)),' size ',pp^.size);
  for i:=1 to tracesize div 2 do
   if pp^.calls[i]<>nil then
     writeln(ptext,BackTraceStrFunc(pp^.calls[i]));
  writeln(ptext,' was released at ');
  for i:=(tracesize div 2)+1 to tracesize do
   if pp^.calls[i]<>nil then
     writeln(ptext,BackTraceStrFunc(pp^.calls[i]));
  { the check is done to be sure that the procvar is not overwritten }
  if assigned(pp^.extra_info) and
     (pp^.extra_info^.check=$12345678) and
     assigned(pp^.extra_info^.displayproc) then
   pp^.extra_info^.displayproc(ptext,@pp^.extra_info^.data);
end;


procedure dump_already_free(p : pheap_mem_info;var ptext : text);
begin
  Writeln(ptext,'Marked memory at $',HexStr(ptrint(pointer(p)+sizeof(theap_mem_info)),2*sizeof(pointer)),' released');
  call_free_stack(p,ptext);
  Writeln(ptext,'freed again at');
  dump_stack(ptext,get_caller_frame(get_frame));
end;

procedure dump_error(p : pheap_mem_info;var ptext : text);
begin
  Writeln(ptext,'Marked memory at $',HexStr(ptrint(pointer(p)+sizeof(theap_mem_info)),2*sizeof(pointer)),' invalid');
  Writeln(ptext,'Wrong signature $',hexstr(p^.sig,8),' instead of ',hexstr(calculate_sig(p),8));
  dump_stack(ptext,get_caller_frame(get_frame));
end;

{$ifdef EXTRA}
procedure dump_change_after(p : pheap_mem_info;var ptext : text);
 var pp : pchar;
     i : ptrint;
begin
  Writeln(ptext,'Marked memory at $',HexStr(ptrint(pointer(p)+sizeof(theap_mem_info)),2*sizeof(pointer)),' invalid');
  Writeln(ptext,'Wrong release CRC $',hexstr(p^.release_sig,8),' instead of ',hexstr(calculate_release_sig(p),8));
  Writeln(ptext,'This memory was changed after call to freemem !');
  call_free_stack(p,ptext);
  pp:=pointer(p)+sizeof(theap_mem_info);
  for i:=0 to p^.size-1 do
    if byte(pp[i])<>$F0 then
      Writeln(ptext,'offset',i,':$',hexstr(i,2*sizeof(pointer)),'"',pp[i],'"');
end;
{$endif EXTRA}

procedure dump_wrong_size(p : pheap_mem_info;size : ptrint;var ptext : text);
begin
  Writeln(ptext,'Marked memory at $',HexStr(ptrint(pointer(p)+sizeof(theap_mem_info)),2*sizeof(pointer)),' invalid');
  Writeln(ptext,'Wrong size : ',p^.size,' allocated ',size,' freed');
  dump_stack(ptext,get_caller_frame(get_frame));
  { the check is done to be sure that the procvar is not overwritten }
  if assigned(p^.extra_info) and
     (p^.extra_info^.check=$12345678) and
     assigned(p^.extra_info^.displayproc) then
   p^.extra_info^.displayproc(ptext,@p^.extra_info^.data);
  call_stack(p,ptext);
end;


function is_in_getmem_list (p : pheap_mem_info) : boolean;
var
  i  : ptrint;
  pp : pheap_mem_info;
begin
  is_in_getmem_list:=false;
  pp:=heap_mem_root;
  i:=0;
  while pp<>nil do
   begin
     if ((pp^.sig<>$DEADBEEF) or usecrc) and
        ((pp^.sig<>calculate_sig(pp)) or not usecrc) and
        (pp^.sig <>$AAAAAAAA) then
      begin
        if useownfile then
          writeln(ownfile,'error in linked list of heap_mem_info')
        else
          writeln(stderr,'error in linked list of heap_mem_info');
        RunError(204);
      end;
     if pp=p then
      is_in_getmem_list:=true;
     pp:=pp^.previous;
     inc(i);
     if i>getmem_cnt-freemem_cnt then
       if useownfile then
         writeln(ownfile,'error in linked list of heap_mem_info')
       else
         writeln(stderr,'error in linked list of heap_mem_info');
   end;
end;


{*****************************************************************************
                               TraceGetMem
*****************************************************************************}

Function TraceGetMem(size:ptrint):pointer;
var
  allocsize,i : ptrint;
  oldbp,
  bp : pointer;
  pl : pdword;
  p  : pointer;
  pp : pheap_mem_info;
begin
  inc(getmem_size,size);
  inc(getmem8_size,((size+7) div 8)*8);
{ Do the real GetMem, but alloc also for the info block }
{$ifdef cpuarm}
  allocsize:=(size + 3) and not 3+sizeof(theap_mem_info)+extra_info_size;
{$else cpuarm}
  allocsize:=size+sizeof(theap_mem_info)+extra_info_size;
{$endif cpuarm}
  if add_tail then
    inc(allocsize,sizeof(ptrint));
  p:=SysGetMem(allocsize);
  pp:=pheap_mem_info(p);
  inc(p,sizeof(theap_mem_info));
{ Create the info block }
  pp^.sig:=$DEADBEEF;
  pp^.size:=size;
  pp^.extra_info_size:=extra_info_size;
  pp^.exact_info_size:=exact_info_size;
  {
    the end of the block contains:
    <tail>   4 bytes
    <extra_info>   X bytes
  }
  if extra_info_size>0 then
   begin
     pp^.extra_info:=pointer(pp)+allocsize-extra_info_size;
     fillchar(pp^.extra_info^,extra_info_size,0);
     pp^.extra_info^.check:=$12345678;
     pp^.extra_info^.fillproc:=fill_extra_info_proc;
     pp^.extra_info^.displayproc:=display_extra_info_proc;
     if assigned(fill_extra_info_proc) then
      begin
        inside_trace_getmem:=true;
        fill_extra_info_proc(@pp^.extra_info^.data);
        inside_trace_getmem:=false;
      end;
   end
  else
   pp^.extra_info:=nil;
  if add_tail then
    begin
      pl:=pointer(pp)+allocsize-pp^.extra_info_size-sizeof(ptrint);
      pl^:=$DEADBEEF;
    end;
  { clear the memory }
  fillchar(p^,size,#255);
  { retrieve backtrace info }
  bp:=get_caller_frame(get_frame);
  for i:=1 to tracesize do
   begin
     pp^.calls[i]:=get_caller_addr(bp);
     oldbp:=bp;
     bp:=get_caller_frame(bp);
     if (bp<oldbp) or (bp>(StackBottom + StackLength)) then
       bp:=nil;
   end;
  { insert in the linked list }
  if heap_mem_root<>nil then
   heap_mem_root^.next:=pp;
  pp^.previous:=heap_mem_root;
  pp^.next:=nil;
{$ifdef EXTRA}
  pp^.prev_valid:=heap_valid_last;
  heap_valid_last:=pp;
  if not assigned(heap_valid_first) then
    heap_valid_first:=pp;
{$endif EXTRA}
  heap_mem_root:=pp;
  { must be changed before fill_extra_info is called
    because checkpointer can be called from within
    fill_extra_info PM }
  inc(getmem_cnt);
  { update the signature }
  if usecrc then
    pp^.sig:=calculate_sig(pp);
  TraceGetmem:=p;
end;


{*****************************************************************************
                                TraceFreeMem
*****************************************************************************}

function TraceFreeMemSize(p:pointer;size:ptrint):ptrint;
var
  i,ppsize : ptrint;
  bp : pointer;
  pp : pheap_mem_info;
{$ifdef EXTRA}
  pp2 : pheap_mem_info;
{$endif}
  extra_size : ptrint;
  ptext : ^text;
begin
  if useownfile then
    ptext:=@ownfile
  else
    ptext:=@stderr;
  if p=nil then
    begin
      TraceFreeMemSize:=0;
      exit;
    end;
  inc(freemem_size,size);
  inc(freemem8_size,((size+7) div 8)*8);
  pp:=pheap_mem_info(p-sizeof(theap_mem_info));
  ppsize:= size + sizeof(theap_mem_info)+pp^.extra_info_size;
  if add_tail then
    inc(ppsize,sizeof(ptrint));
  if not quicktrace then
    begin
      if not(is_in_getmem_list(pp)) then
       RunError(204);
    end;
  if (pp^.sig=$AAAAAAAA) and not usecrc then
    begin
       error_in_heap:=true;
       dump_already_free(pp,ptext^);
       if haltonerror then halt(1);
    end
  else if ((pp^.sig<>$DEADBEEF) or usecrc) and
        ((pp^.sig<>calculate_sig(pp)) or not usecrc) then
    begin
       error_in_heap:=true;
       dump_error(pp,ptext^);
{$ifdef EXTRA}
       dump_error(pp,error_file);
{$endif EXTRA}
       { don't release anything in this case !! }
       if haltonerror then halt(1);
       exit;
    end
  else if pp^.size<>size then
    begin
       error_in_heap:=true;
       dump_wrong_size(pp,size,ptext^);
{$ifdef EXTRA}
       dump_wrong_size(pp,size,error_file);
{$endif EXTRA}
       if haltonerror then halt(1);
       { don't release anything in this case !! }
       exit;
    end;
  { save old values }
  extra_size:=pp^.extra_info_size;
  { now it is released !! }
  pp^.sig:=$AAAAAAAA;
  if not keepreleased then
    begin
       if pp^.next<>nil then
         pp^.next^.previous:=pp^.previous;
       if pp^.previous<>nil then
         pp^.previous^.next:=pp^.next;
       if pp=heap_mem_root then
         heap_mem_root:=heap_mem_root^.previous;
    end
  else
    begin
       bp:=get_caller_frame(get_frame);
       for i:=(tracesize div 2)+1 to tracesize do
        begin
          pp^.calls[i]:=get_caller_addr(bp);
          bp:=get_caller_frame(bp);
        end;
    end;
  inc(freemem_cnt);
  { clear the memory }
  fillchar(p^,size,#240); { $F0 will lead to GFP if used as pointer ! }
  { this way we keep all info about all released memory !! }
  if keepreleased then
    begin
{$ifdef EXTRA}
       { We want to check if the memory was changed after release !! }
       pp^.release_sig:=calculate_release_sig(pp);
       if pp=heap_valid_last then
         begin
            heap_valid_last:=pp^.prev_valid;
            if pp=heap_valid_first then
              heap_valid_first:=nil;
            TraceFreememsize:=size;
            exit;
         end;
       pp2:=heap_valid_last;
       while assigned(pp2) do
         begin
            if pp2^.prev_valid=pp then
              begin
                 pp2^.prev_valid:=pp^.prev_valid;
                 if pp=heap_valid_first then
                   heap_valid_first:=pp2;
                 TraceFreememsize:=size;
                 exit;
              end
            else
              pp2:=pp2^.prev_valid;
         end;
{$endif EXTRA}
       TraceFreememsize:=size;
       exit;
    end;
   { release the normal memory at least }
   i:=SysFreeMemSize(pp,ppsize);
   { return the correct size }
   dec(i,sizeof(theap_mem_info)+extra_size);
   if add_tail then
     dec(i,sizeof(ptrint));
   TraceFreeMemSize:=i;
end;


function TraceMemSize(p:pointer):ptrint;
var
  pp : pheap_mem_info;
begin
  pp:=pheap_mem_info(p-sizeof(theap_mem_info));
  TraceMemSize:=pp^.size;
end;


function TraceFreeMem(p:pointer):ptrint;
var
  l  : ptrint;
  pp : pheap_mem_info;
begin
  if p=nil then
    begin
      TraceFreeMem:=0;
      exit;
    end;
  pp:=pheap_mem_info(p-sizeof(theap_mem_info));
  l:=SysMemSize(pp);
  dec(l,sizeof(theap_mem_info)+pp^.extra_info_size);
  if add_tail then
   dec(l,sizeof(ptrint));
  { this can never happend normaly }
  if pp^.size>l then
   begin
     if useownfile then
       dump_wrong_size(pp,l,ownfile)
     else
       dump_wrong_size(pp,l,stderr);

{$ifdef EXTRA}
     dump_wrong_size(pp,l,error_file);
{$endif EXTRA}
   end;
  TraceFreeMem:=TraceFreeMemSize(p,pp^.size);
end;


{*****************************************************************************
                                ReAllocMem
*****************************************************************************}

function TraceReAllocMem(var p:pointer;size:ptrint):Pointer;
var
  newP: pointer;
  allocsize,
  movesize,
  i  : ptrint;
  bp : pointer;
  pl : pdword;
  pp : pheap_mem_info;
  oldsize,
  oldextrasize,
  oldexactsize : ptrint;
  old_fill_extra_info_proc : tfillextrainfoproc;
  old_display_extra_info_proc : tdisplayextrainfoproc;
begin
{ Free block? }
  if size=0 then
   begin
     if p<>nil then
      TraceFreeMem(p);
     p:=nil;
     TraceReallocMem:=P;
     exit;
   end;
{ Allocate a new block? }
  if p=nil then
   begin
     p:=TraceGetMem(size);
     TraceReallocMem:=P;
     exit;
   end;
{ Resize block }
  pp:=pheap_mem_info(p-sizeof(theap_mem_info));
  { test block }
  if ((pp^.sig<>$DEADBEEF) or usecrc) and
     ((pp^.sig<>calculate_sig(pp)) or not usecrc) then
   begin
     error_in_heap:=true;
     if useownfile then
       dump_error(pp,ownfile)
     else
       dump_error(pp,stderr);
{$ifdef EXTRA}
     dump_error(pp,error_file);
{$endif EXTRA}
     { don't release anything in this case !! }
     if haltonerror then halt(1);
     exit;
   end;
  { save info }
  oldsize:=pp^.size;
  oldextrasize:=pp^.extra_info_size;
  oldexactsize:=pp^.exact_info_size;
  if pp^.extra_info_size>0 then
   begin
     old_fill_extra_info_proc:=pp^.extra_info^.fillproc;
     old_display_extra_info_proc:=pp^.extra_info^.displayproc;
   end;
  { Do the real ReAllocMem, but alloc also for the info block }
{$ifdef cpuarm}
  allocsize:=(size + 3) and not 3+sizeof(theap_mem_info)+pp^.extra_info_size;
{$else cpuarm}
  allocsize:=size+sizeof(theap_mem_info)+pp^.extra_info_size;
{$endif cpuarm}
  if add_tail then
   inc(allocsize,sizeof(ptrint));
  { Try to resize the block, if not possible we need to do a
    getmem, move data, freemem }
  if not SysTryResizeMem(pp,allocsize) then
   begin
     { get a new block }
     newP := TraceGetMem(size);
     { move the data }
     if newP <> nil then
      begin
        movesize:=TraceMemSize(p);
        {if the old size is larger than the new size,
         move only the new size}
        if movesize>size then
          movesize:=size;
        move(p^,newP^,movesize);
      end;
     { release p }
     traceFreeMem(p);
     { return the new pointer }
     p:=newp;
     traceReAllocMem := newp;
     exit;
   end;
{ Recreate the info block }
  pp^.sig:=$DEADBEEF;
  pp^.size:=size;
  pp^.extra_info_size:=oldextrasize;
  pp^.exact_info_size:=oldexactsize;
  { add the new extra_info and tail }
  if pp^.extra_info_size>0 then
   begin
     pp^.extra_info:=pointer(pp)+allocsize-pp^.extra_info_size;
     fillchar(pp^.extra_info^,extra_info_size,0);
     pp^.extra_info^.check:=$12345678;
     pp^.extra_info^.fillproc:=old_fill_extra_info_proc;
     pp^.extra_info^.displayproc:=old_display_extra_info_proc;
     if assigned(pp^.extra_info^.fillproc) then
      pp^.extra_info^.fillproc(@pp^.extra_info^.data);
   end
  else
   pp^.extra_info:=nil;
  if add_tail then
    begin
      pl:=pointer(pp)+allocsize-pp^.extra_info_size-sizeof(ptrint);
      pl^:=$DEADBEEF;
    end;
  { adjust like a freemem and then a getmem, so you get correct
    results in the summary display }
  inc(freemem_size,oldsize);
  inc(freemem8_size,((oldsize+7) div 8)*8);
  inc(getmem_size,size);
  inc(getmem8_size,((size+7) div 8)*8);
  { generate new backtrace }
  bp:=get_caller_frame(get_frame);
  for i:=1 to tracesize do
   begin
     pp^.calls[i]:=get_caller_addr(bp);
     bp:=get_caller_frame(bp);
   end;
  { regenerate signature }
  if usecrc then
    pp^.sig:=calculate_sig(pp);
  { return the pointer }
  p:=pointer(pp)+sizeof(theap_mem_info);
  TraceReAllocmem:=p;
end;



{*****************************************************************************
                              Check pointer
*****************************************************************************}

{$ifndef Unix}
  {$S-}
{$endif}

{$ifdef go32v2}
var
   __stklen : longword;external name '__stklen';
   __stkbottom : longword;external name '__stkbottom';
   edata : longword; external name 'edata';
{$endif go32v2}

{$ifdef linux}
var
   etext: ptruint; external name '_etext';
   edata : ptruint; external name '_edata';
   eend : ptruint; external name '_end';
{$endif}

{$ifdef os2}
(* Currently still EMX based - possibly to be changed in the future. *)
var
   etext: ptruint; external name '_etext';
   edata : ptruint; external name '_edata';
   eend : ptruint; external name '_end';
{$endif}

{$ifdef windows}
var
   sdata : ptruint; external name '__data_start__';
   edata : ptruint; external name '__data_end__';
   sbss : ptruint; external name '__bss_start__';
   ebss : ptruint; external name '__bss_end__';
{$endif}


procedure CheckPointer(p : pointer); [public, alias : 'FPC_CHECKPOINTER'];
var
  i  : ptrint;
  pp : pheap_mem_info;
{$ifdef go32v2}
  get_ebp,stack_top : longword;
  data_end : longword;
{$endif go32v2}
{$ifdef morphos}
  stack_top: longword;
{$endif morphos}
  ptext : ^text;
label
  _exit;
begin
  if p=nil then
    runerror(204);

  i:=0;

  if useownfile then
    ptext:=@ownfile
  else
    ptext:=@stderr;

{$ifdef go32v2}
  if ptruint(p)<$1000 then
    runerror(216);
  asm
     movl %ebp,get_ebp
     leal edata,%eax
     movl %eax,data_end
  end;
  stack_top:=__stkbottom+__stklen;
  { allow all between start of code and end of data }
  if ptruint(p)<=data_end then
    goto _exit;
  { stack can be above heap !! }

  if (ptruint(p)>=get_ebp) and (ptruint(p)<=stack_top) then
    goto _exit;
{$endif go32v2}

  { I don't know where the stack is in other OS !! }
{$ifdef windows}
  { inside stack ? }
  if (ptruint(p)>ptruint(get_frame)) and
     (p<StackTop) then
    goto _exit;
  { inside data ? }
  if (ptruint(p)>=ptruint(@sdata)) and (ptruint(p)<ptruint(@edata)) then
    goto _exit;

  { inside bss ? }
  if (ptruint(p)>=ptruint(@sbss)) and (ptruint(p)<ptruint(@ebss)) then
    goto _exit;
{$endif windows}

{$IFDEF OS2}
  { inside stack ? }
  if (PtrUInt (P) > PtrUInt (Get_Frame)) and
     (PtrUInt (P) < PtrUInt (StackTop)) then
    goto _exit;
  { inside data or bss ? }
  if (PtrUInt (P) >= PtrUInt (@etext)) and (PtrUInt (P) < PtrUInt (@eend)) then
    goto _exit;
{$ENDIF OS2}

{$ifdef linux}
  { inside stack ? }
  if (ptruint(p)>ptruint(get_frame)) and
     (ptruint(p)<$c0000000) then      //todo: 64bit!
    goto _exit;
  { inside data or bss ? }
  if (ptruint(p)>=ptruint(@etext)) and (ptruint(p)<ptruint(@eend)) then
    goto _exit;
{$endif linux}

{$ifdef morphos}
  { inside stack ? }
  stack_top:=ptruint(StackBottom)+StackLength;
  if (ptruint(p)<stack_top) and (ptruint(p)>ptruint(StackBottom)) then
    goto _exit;
  { inside data or bss ? }
  {$WARNING data and bss checking missing }
{$endif morphos}

  {$ifdef darwin}
  {$warning No checkpointer support yet for Darwin}
  exit;
  {$endif}

  { first try valid list faster }

{$ifdef EXTRA}
  pp:=heap_valid_last;
  while pp<>nil do
   begin
     { inside this valid block ! }
     { we can be changing the extrainfo !! }
     if (ptruint(p)>=ptruint(pp)+sizeof(theap_mem_info){+extra_info_size}) and
        (ptruint(p)<=ptruint(pp)+sizeof(theap_mem_info)+extra_info_size+pp^.size) then
       begin
          { check allocated block }
          if ((pp^.sig=$DEADBEEF) and not usecrc) or
             ((pp^.sig=calculate_sig(pp)) and usecrc) or
          { special case of the fill_extra_info call }
             ((pp=heap_valid_last) and usecrc and (pp^.sig=$DEADBEEF)
              and inside_trace_getmem) then
            goto _exit
          else
            begin
              writeln(ptext^,'corrupted heap_mem_info');
              dump_error(pp,ptext^);
              halt(1);
            end;
       end
     else
       pp:=pp^.prev_valid;
     inc(i);
     if i>getmem_cnt-freemem_cnt then
      begin
         writeln(ptext^,'error in linked list of heap_mem_info');
         halt(1);
      end;
   end;
  i:=0;
{$endif EXTRA}
  pp:=heap_mem_root;
  while pp<>nil do
   begin
     { inside this block ! }
     if (ptruint(p)>=ptruint(pp)+sizeof(theap_mem_info)+ptruint(extra_info_size)) and
        (ptruint(p)<=ptruint(pp)+sizeof(theap_mem_info)+ptruint(extra_info_size)+ptruint(pp^.size)) then
        { allocated block }
       if ((pp^.sig=$DEADBEEF) and not usecrc) or
          ((pp^.sig=calculate_sig(pp)) and usecrc) then
          goto _exit
       else
         begin
            writeln(ptext^,'pointer $',hexstr(ptrint(p),2*sizeof(pointer)),' points into invalid memory block');
            dump_error(pp,ptext^);
            runerror(204);
         end;
     pp:=pp^.previous;
     inc(i);
     if i>getmem_cnt then
      begin
         writeln(ptext^,'error in linked list of heap_mem_info');
         halt(1);
      end;
   end;
  writeln(ptext^,'pointer $',hexstr(ptrint(p),2*sizeof(pointer)),' does not point to valid memory block');
  dump_error(p,ptext^);
  runerror(204);
_exit:
end;

{*****************************************************************************
                              Dump Heap
*****************************************************************************}

procedure dumpheap;
var
  pp : pheap_mem_info;
  i : ptrint;
  ExpectedHeapFree : ptrint;
  status : TFPCHeapStatus;
  ptext : ^text;
begin
  if useownfile then
    ptext:=@ownfile
  else
    ptext:=@stderr;
  pp:=heap_mem_root;
  Writeln(ptext^,'Heap dump by heaptrc unit');
  Writeln(ptext^,getmem_cnt, ' memory blocks allocated : ',getmem_size,'/',getmem8_size);
  Writeln(ptext^,freemem_cnt,' memory blocks freed     : ',freemem_size,'/',freemem8_size);
  Writeln(ptext^,getmem_cnt-freemem_cnt,' unfreed memory blocks : ',getmem_size-freemem_size);
  status:=SysGetFPCHeapStatus;
  Write(ptext^,'True heap size : ',status.CurrHeapSize);
  if EntryMemUsed > 0 then
    Writeln(ptext^,' (',EntryMemUsed,' used in System startup)')
  else
    Writeln(ptext^);
  Writeln(ptext^,'True free heap : ',status.CurrHeapFree);
  ExpectedHeapFree:=status.CurrHeapSize-(getmem8_size-freemem8_size)-
    (getmem_cnt-freemem_cnt)*(sizeof(theap_mem_info)+extra_info_size)-EntryMemUsed;
  If ExpectedHeapFree<>status.CurrHeapFree then
    Writeln(ptext^,'Should be : ',ExpectedHeapFree);
  i:=getmem_cnt-freemem_cnt;
  while pp<>nil do
   begin
     if i<0 then
       begin
          Writeln(ptext^,'Error in heap memory list');
          Writeln(ptext^,'More memory blocks than expected');
          exit;
       end;
     if ((pp^.sig=$DEADBEEF) and not usecrc) or
        ((pp^.sig=calculate_sig(pp)) and usecrc) then
       begin
          { this one was not released !! }
          if exitcode<>203 then
            call_stack(pp,ptext^);
          dec(i);
       end
     else if pp^.sig<>$AAAAAAAA then
       begin
          dump_error(pp,ptext^);
{$ifdef EXTRA}
          dump_error(pp,error_file);
{$endif EXTRA}
          error_in_heap:=true;
       end
{$ifdef EXTRA}
     else if pp^.release_sig<>calculate_release_sig(pp) then
       begin
          dump_change_after(pp,ptext^);
          dump_change_after(pp,error_file);
          error_in_heap:=true;
       end
{$endif EXTRA}
       ;
     pp:=pp^.previous;
   end;
  if HaltOnNotReleased and (getmem_cnt<>freemem_cnt) then
    exitcode:=203;
end;


{*****************************************************************************
                                AllocMem
*****************************************************************************}

function TraceAllocMem(size:ptrint):Pointer;
begin
  TraceAllocMem:=SysAllocMem(size);
end;


{*****************************************************************************
                            No specific tracing calls
*****************************************************************************}

function TraceGetHeapStatus:THeapStatus;
begin
  TraceGetHeapStatus:=SysGetHeapStatus;
end;

function TraceGetFPCHeapStatus:TFPCHeapStatus;
begin
    TraceGetFPCHeapStatus:=SysGetFPCHeapStatus;
end;


{*****************************************************************************
                             Program Hooks
*****************************************************************************}

Procedure SetHeapTraceOutput(const name : string);
var i : ptrint;
begin
   if useownfile then
     begin
       useownfile:=false;
       close(ownfile);
     end;
   assign(ownfile,name);
{$I-}
   append(ownfile);
   if IOResult<>0 then
     Rewrite(ownfile);
{$I+}
   useownfile:=true;
   for i:=0 to Paramcount do
     write(ownfile,paramstr(i),' ');
   writeln(ownfile);
end;

procedure SetHeapExtraInfo( size : ptrint;fillproc : tfillextrainfoproc;displayproc : tdisplayextrainfoproc);
begin
  { the total size must stay multiple of 8, also allocate 2 pointers for
    the fill and display procvars }
  exact_info_size:=size + sizeof(theap_extra_info);
  extra_info_size:=((exact_info_size+7) div 8)*8;
  fill_extra_info_proc:=fillproc;
  display_extra_info_proc:=displayproc;
end;


{*****************************************************************************
                           Install MemoryManager
*****************************************************************************}

const
  TraceManager:TMemoryManager=(
    NeedLock : true;
    Getmem  : @TraceGetMem;
    Freemem : @TraceFreeMem;
    FreememSize : @TraceFreeMemSize;
    AllocMem : @TraceAllocMem;
    ReAllocMem : @TraceReAllocMem;
    MemSize : @TraceMemSize;
    GetHeapStatus : @TraceGetHeapStatus;
    GetFPCHeapStatus : @TraceGetFPCHeapStatus;
  );


procedure TraceInit;
var
  initheapstatus : TFPCHeapStatus;
begin
  initheapstatus:=SysGetFPCHeapStatus;
  EntryMemUsed:=initheapstatus.CurrHeapUsed;
  MakeCRC32Tbl;
  SetMemoryManager(TraceManager);
  useownfile:=false;
  if outputstr <> '' then
     SetHeapTraceOutput(outputstr);
{$ifdef EXTRA}
  Assign(error_file,'heap.err');
  Rewrite(error_file);
{$endif EXTRA}
end;


procedure TraceExit;
begin
  { no dump if error
    because this gives long long listings }
  { clear inoutres, in case the program that quit didn't }
  ioresult;
  if (exitcode<>0) and (erroraddr<>nil) then
    begin
       if useownfile then
         begin
           Writeln(ownfile,'No heap dump by heaptrc unit');
           Writeln(ownfile,'Exitcode = ',exitcode);
         end
       else
         begin
           Writeln(stderr,'No heap dump by heaptrc unit');
           Writeln(stderr,'Exitcode = ',exitcode);
         end;
       if useownfile then
         begin
           useownfile:=false;
           close(ownfile);
         end;
       exit;
    end;
  if not error_in_heap then
    Dumpheap;
  if error_in_heap and (exitcode=0) then
    exitcode:=203;
{$ifdef EXTRA}
  Close(error_file);
{$endif EXTRA}
   if useownfile then
     begin
       useownfile:=false;
       close(ownfile);
     end;
end;

{$if defined(win32) or defined(win64)}
   function GetEnvironmentStrings : pchar; stdcall;
     external 'kernel32' name 'GetEnvironmentStringsA';
   function FreeEnvironmentStrings(p : pchar) : longbool; stdcall;
     external 'kernel32' name 'FreeEnvironmentStringsA';
Function  GetEnv(envvar: string): string;
var
   s : string;
   i : ptrint;
   hp,p : pchar;
begin
   getenv:='';
   p:=GetEnvironmentStrings;
   hp:=p;
   while hp^<>#0 do
     begin
        s:=strpas(hp);
        i:=pos('=',s);
        if upcase(copy(s,1,i-1))=upcase(envvar) then
          begin
             getenv:=copy(s,i+1,length(s)-i);
             break;
          end;
        { next string entry}
        hp:=hp+strlen(hp)+1;
     end;
   FreeEnvironmentStrings(p);
end;
{$else defined(win32) or defined(win64)}

{$ifdef wince}
Function GetEnv(P:string):Pchar;
begin
  { WinCE does not have environment strings.
    Add some way to specify heaptrc options? }
  GetEnv:=nil;
end;
{$else wince}

Function GetEnv(P:string):Pchar;
{
  Searches the environment for a string with name p and
  returns a pchar to it's value.
  A pchar is used to accomodate for strings of length > 255
}
var
  ep    : ppchar;
  i     : ptrint;
  found : boolean;
Begin
  p:=p+'=';            {Else HOST will also find HOSTNAME, etc}
  ep:=envp;
  found:=false;
  if ep<>nil then
   begin
     while (not found) and (ep^<>nil) do
      begin
        found:=true;
        for i:=1 to length(p) do
         if p[i]<>ep^[i-1] then
          begin
            found:=false;
            break;
          end;
        if not found then
         inc(ep);
      end;
   end;
  if found then
   getenv:=ep^+length(p)
  else
   getenv:=nil;
end;
{$endif wince}
{$endif win32}

procedure LoadEnvironment;
var
  i,j : ptrint;
  s   : string;
begin
  s:=Getenv('HEAPTRC');
  if pos('keepreleased',s)>0 then
   keepreleased:=true;
  if pos('disabled',s)>0 then
   useheaptrace:=false;
  if pos('nohalt',s)>0 then
   haltonerror:=false;
  if pos('haltonnotreleased',s)>0 then
   HaltOnNotReleased :=true;
  i:=pos('log=',s);
  if i>0 then
   begin
     outputstr:=copy(s,i+4,255);
     j:=pos(' ',outputstr);
     if j=0 then
      j:=length(outputstr)+1;
     delete(outputstr,j,255);
   end;
end;


Initialization
  LoadEnvironment;
  { heaptrc can be disabled from the environment }
  if useheaptrace then
   TraceInit;
finalization
  if useheaptrace then
   TraceExit;
end.
