/*
  $Id: gprt0.as,v 1.4 2004/11/05 21:36:36 florian Exp $
*/
        .section ".text"
        .align 4
        .global _start
        .type _start,#function
_start:

  /* Terminate the stack frame, and reserve space for functions to
     drop their arguments.  */
        mov     %g0, %fp
        sub     %sp, 6*4, %sp

  	/* Extract the arguments and environment as encoded on the stack.  The
     	   argument info starts after one register window (16 words) past the SP.  */
	       ld	[%sp+22*4], %o2
        sethi	%hi(operatingsystem_parameter_argc),%o1
        or	%o1,%lo(operatingsystem_parameter_argc),%o1
       	st	%o2, [%o1]

        add	%sp, 23*4, %o0
        sethi	%hi(operatingsystem_parameter_argv),%o1
       	or	%o1,%lo(operatingsystem_parameter_argv),%o1
       	st	%o0, [%o1]

  	/* envp=(argc+1)*4+argv */
       	inc     %o2
       	sll     %o2, 2, %o2
        add	%o2, %o0, %o2
       	sethi	%hi(operatingsystem_parameter_envp),%o1
       	or	%o1,%lo(operatingsystem_parameter_envp),%o1
       	st	%o2, [%o1]

  /* reload the addresses for C startup code  */
        ld      [%sp+22*4], %o1
        add     %sp, 23*4, %o2


  /* Load the addresses of the user entry points.  */
        sethi   %hi(main_stub), %o0
        sethi   %hi(_init), %o3
        sethi   %hi(_fini), %o4
        or      %o0, %lo(main_stub), %o0
        or      %o3, %lo(_init), %o3
        or      %o4, %lo(_fini), %o4

  /* When starting a binary via the dynamic linker, %g1 contains the
     address of the shared library termination function, which will be
     registered with atexit().  If we are statically linked, this will
     be NULL.  */
        mov     %g1, %o5

  /* Let libc do the rest of the initialization, and call main.  */
        call    __libc_start_main
        nop

  /* Die very horribly if exit returns.  */
        unimp

       .size _start, .-_start

  main_stub:
        /* Initialize gmon */
        sethi   %hi(_start), %o0
        sethi   %hi(_etext), %o1
        or      %o0, %lo(_start), %o0
        or      %o1, %lo(_etext), %o1
        call    monstartup
        nop

        sethi   %hi(_mcleanup), %o0
        or      %o0, %lo(_mcleanup), %o0
        call    atexit
        nop

        /* start the program */
        call    PASCALMAIN
        nop

        ba      _haltproc
        nop

        .globl  _haltproc
        .type   _haltproc,@function
  _haltproc:
        mov	1, %g1			/* "exit" system call */
        sethi	%hi(operatingsystem_result),%o0
        or	%o0,%lo(operatingsystem_result),%o0
        ldsh	[%o0], %o0			/* give exit status to parent process*/
        ta	0x10			/* dot the system call */
        nop				/* delay slot */
        /* Die very horribly if exit returns.  */
        unimp

.data

        .comm   ___fpc_brk_addr,4        /* heap management */

        .comm operatingsystem_parameter_envp,4
        .comm operatingsystem_parameter_argc,4
        .comm operatingsystem_parameter_argv,4
/*
  $Log: gprt0.as,v $
  Revision 1.4  2004/11/05 21:36:36  florian
    * initial implementation

  Revision 1.3  2003/05/23 21:09:14  florian
    + dummy implementation readded to satisfy makefile
*/
