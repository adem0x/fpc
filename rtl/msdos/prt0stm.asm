; common startup code for the SMALL, TINY and MEDIUM memory models

%ifdef __MEDIUM__
        %define __FAR_CODE__
%else
        %define __NEAR_CODE__
%endif

%ifdef __FAR_CODE__
        extra_param_offset equ 2
%else
        extra_param_offset equ 0
%endif

        cpu 8086

        segment text use16 class=code

        extern PASCALMAIN
        extern dos_psp
        extern dos_version
        extern __Test8086

        extern _edata  ; defined by WLINK, indicates start of BSS
        extern _end    ; defined by WLINK, indicates end of BSS

        extern __stklen
        extern __stkbottom

        extern __nearheap_start
        extern __nearheap_end

%ifdef __TINY__
        resb 0100h
%endif
..start:
%ifdef __TINY__
        mov bx, cs
%else
        ; init the stack
        mov bx, dgroup
        mov ss, bx
        mov sp, stacktop
%endif

        ; zero fill the BSS section
        mov es, bx
        mov di, _edata wrt dgroup
        mov cx, _end wrt dgroup
        sub cx, di
        xor al, al
        cld
        rep stosb

        ; save the Program Segment Prefix
        push ds

        ; init DS
        mov ds, bx

        ; pop the PSP from stack and store it in the pascal variable dos_psp
        pop ax
        mov word [dos_psp], ax

        ; get DOS version and save it in the pascal variable dos_version
        mov ax, 3000h
        int 21h
        xchg al, ah
        mov word [dos_version], ax

        ; detect CPU
        xor bx, bx  ; 0=8086/8088/80186/80188/NEC V20/NEC V30
        ; on pre-286 processors, bits 12..15 of the FLAGS registers are always set
        pushf
        pop ax
        and ah, 0fh
        push ax
        popf
        pushf
        pop ax
        and ah, 0f0h
        cmp ah, 0f0h
        je cpu_detect_done
        ; at this point we have a 286 or higher
        inc bx
        ; on a true 286 in real mode, bits 12..15 are always clear
        pushf
        pop ax
        or ah, 0f0h
        push ax
        popf
        pushf
        pop ax
        and ah, 0f0h
        jz cpu_detect_done
        ; we have a 386+
        inc bx

cpu_detect_done:
        mov [__Test8086], bl

        ; allocate max heap
        ; TODO: also support user specified heap size
        ; try to resize our main DOS memory block until the end of the data segment
%ifdef __TINY__
        mov cx, cs
        mov dx, 1000h  ; 64kb in paragraphs
%else
        mov dx, word [dos_psp]
        mov cx, dx
        sub dx, dgroup
        neg dx  ; dx = (ds - psp) in paragraphs
        add dx, 1000h  ; 64kb in paragraphs
%endif

         ; get our MCB size in paragraphs
        dec cx
        mov es, cx
        mov bx, word [es:3]

        ; is it smaller than the maximum data segment size?
        cmp bx, dx
        jbe skip_mem_realloc

        mov bx, dx
        inc cx
        mov es, cx
        mov ah, 4Ah
        int 21h
        jc mem_realloc_err

skip_mem_realloc:

        ; bx = the new size in paragraphs
%ifndef __TINY__
        add bx, word [dos_psp]
        sub bx, dgroup
%endif
        mov cl, 4
        shl bx, cl
        sub bx, 2
        mov sp, bx

        add bx, 2
        sub bx, word [__stklen]
        and bl, 0FEh
        mov word [__stkbottom], bx

        cmp bx, _end wrt dgroup
        jb not_enough_mem

        ; heap is between [ds:_end wrt dgroup] and [ds:__stkbottom - 1]
        mov word [__nearheap_start], _end wrt dgroup
        mov bx, word [__stkbottom]
        dec bx
        mov word [__nearheap_end], bx

%ifdef __FAR_CODE__
        jmp far PASCALMAIN
%else
        jmp PASCALMAIN
%endif

not_enough_mem:
        mov dx, not_enough_mem_msg
        jmp error_msg

mem_realloc_err:
        mov dx, mem_realloc_err_msg
error_msg:
        mov ah, 9
        int 21h
        mov ax, 4CFFh
        int 21h

        global FPC_MSDOS_CARRY
FPC_MSDOS_CARRY:
        stc
        global FPC_MSDOS
FPC_MSDOS:
        mov al, 21h  ; not ax, because only the low byte is used
        pop dx
%ifdef __FAR_CODE__
        pop bx
%endif
        pop cx
        push ax
        push cx
%ifdef __FAR_CODE__
        push bx
%endif
        push dx
        global FPC_INTR
FPC_INTR:
        push bp
        mov bp, sp
        mov al, byte [ss:bp + 6 + extra_param_offset]
        mov byte [cs:int_number], al
        mov si, [ss:bp + 4 + extra_param_offset]
        push ds
        mov ax, word [si + 16]
        mov es, ax
        mov ax, word [si + 14]  ; ds
        push ax
        mov ax, word [si]
        mov bx, word [si + 2]
        mov cx, word [si + 4]
        mov dx, word [si + 6]
        mov bp, word [si + 8]
        mov di, word [si + 12]
        mov si, word [si + 10]
        
        pop ds
        db 0CDh  ; opcode of INT xx
int_number:
        db 255
        
        pushf
        push ds
        push si
        push bp
        mov bp, sp
        mov si, word [ss:bp + 8]
        mov ds, si
        mov si, word [ss:bp + 14 + extra_param_offset]
        mov word [si], ax
        mov word [si + 2], bx
        mov word [si + 4], cx
        mov word [si + 6], dx
        mov word [si + 12], di
        mov ax, es
        mov word [si + 16], ax
        pop ax
        mov word [si + 8], ax
        pop ax
        mov word [si + 10], ax
        pop ax
        mov word [si + 14], ax
        pop ax
        mov word [si + 18], ax
        
        pop ds
        pop bp
%ifdef __FAR_CODE__
        retf 4
%else
        ret 4
%endif

        segment data
mem_realloc_err_msg:
        db 'Memory allocation error', 13, 10, '$'
not_enough_mem_msg:
        db 'Not enough memory', 13, 10, '$'

        segment bss class=bss

%ifndef __TINY__
        segment stack stack class=stack
        resb 256
        stacktop:
%endif

%ifdef __TINY__
        group dgroup text data bss
%else
        group dgroup data bss stack
%endif
