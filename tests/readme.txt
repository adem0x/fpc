Directories
-----------
webtbs...........Tests for web-bug-database bugs (success in compilation)
                   Digits in filename refer to bug database entry
webtbf...........Tests for web-bug-database bugs (fail compile)
                   Digits in filename refer to bug database entry
test.............Testsuites for different aspects of the compiler/rtl etc
tbs..............Tests for other bugs, added by the fpc core team
                   (success in compilation) Digits in filename is a serial no
tbf..............Tests for other bugs, added by the fpc core team
                   (fail compile) Digits in filename is a serial no
units............Helper units for doing the tests
utils............Utilities for processing tests
packages.........Tests for packages: to run this tests, the full fpc sources
                 must be build


Writing a test
--------------
A test should have a name on the form t*.pp, to be recognized as a test.
It should return 0 on success, any other value indicate failure.



Test directives
---------------
At the top of the test source code, some directives
can be used to determine how the tests will be
processed (if processed automatically via make),
e. g. {%CPU=i386} :

OPT................Compiler option required to compile
CPU................Only for these CPU's (i386,m68k,etc). Might be a list.
SKIPCPU............Not for these CPU's (i386,m68k,etc). Might be a list.
TARGET.............Only for these OS targets (win32,macos,etc).
                   Might be a list.
SKIPTARGET.........Not for these OS targets (win32,macos,etc).
                   Might be a list.
VERSION............Compiler with at lest this version number required.
MAXVERSION.........Compiler with at most this version number required.
RESULT.............Exit code of execution of test expected
GRAPH..............Requires graph unit
FAIL...............Compilation must fail
RECOMPILE..........After compiling a test, recompile the test for a second
                   time. This is needed to test ppu loading issues.
NORUN..............Do not execute test, only compile it
INTERACTIVE........Do not execute test, as it requires user intervention
NOTE...............Output note when compiling/executing test
NEEDLIBRARY........Adds -rpath to the linker for unix. This is needed to
                   test runtime library tests. The library needs the -FE.
                   option to place the .so in the correct directory.
KNOWNRUNERROR......Known bug, which manifest itself at runtime. To the
                   right of the equal sign is the expected exit code,
                   followed by an optional note. Will not be logged
                   as a bug.
KNOWNCOMPILEERROR..Known bug, which manifest itself at compile time. To
                   the right of the equal sign is the expected exit code
                   from compiler, followed by an optional note. Will not
                   be logged as a bug.

  NOTE: A list consists of comma separated items, e. g. CPU=i386,m68k,linux
        No space between the elements and the comma.

Usage
-----
To actually start the testsuite:
do a simple
make full This should create a log of all failed tests.

make rundigest scans the created log file and outputs some statistics
make rundigest USESQL=YES sends the results to an SQL database

When the tests are performed, first the units (e g rtl) needed by the tests
are compiled in a clean determined way and put in the units directory. Then
webtbs/webtbf/test/tbs/tbf are searched for t*.pp to be compiled
and executed as tests.

Controling testing in more detail
---------------------------------
Calling "make full" will preform tests in a standard manner. To have
more control of the test process we must differentiate between:

* Driver enviroment: compiler/rtl etc to be used by the tools which
  runs and analyze the tests. All normal options to make, like FPC
  OS_TARGET, OPT etc controls this.

* Test environment:  compiler/rtl etc to be tested, to be used
  *in* the tests. Ususal options, prepended with TEST_ , controls
  this. If no such options are given, test and driver environment
  will be the same.

This differentiation also enables cross testing.

The following test options can be given:

TEST_FPC               defaults to FPC
TEST_OS_TARGET         defaults to default target of TEST_FPC
TEST_CPU_TARGET        defaults to default target of TEST_FPC
TEST_OPT               defaults to ""
TEST_FPC_VERSION       defaults to version of TEST_FPC
TEST_CCOMPILER         defaults to installed gcc compiler, but only
                       if driver and test full-targets are the same.
TEST_VERBOSE           let dotest be more verbose, only usefull for debugging
TEST_DELTEMP           delete temporary executable/object/ppu file, default is off

  (Please add more test options if needed)

NOTE To clean after a test session, "make clean" must be given the same
options as when running the tests.

The utils directory is considerd to belong to the driver environment,
all other directories belongs to the test environment.

Remote execution
----------------
Also remote execution of the testsuite is possible

Requirements:
- rsh/ssh must work without keyboard interaction or extra parameters

Test options:
TEST_RSH             set this to the hostname when you want to use rsh/rcp
                     to execute/copy the test
TEST_SSH             set this to use ssh/scp to execute the test
TEST_PUTTY           test using putty when remote testing (pscp and plink)
TEST_REMOTEOPT       extra options to remote program
TEST_REMOTEPATH      set remote path to use, default is /tmp
TEST_DELTEMP         delete executable after running, so the remote system
                     doesn't need much free disk space
TEST_REMOTEPW        pass a password with -pw to remote tools, mainly usefull for putty

Example:
-------
  make TEST_FPC=$HOME/fpc/compiler/ppcsparc TEST_BINUTILSPREFIX=sparc-linux- \
       TEST_RSH=sunny TEST_REMOTEPATH=/tmp/tests

  make TEST_FPC=$HOME/fpc/compiler/ppcsparc TEST_BINUTILSPREFIX=sparc-linux- \
       TEST_SSH=fpc@sunny TEST_REMOTEPATH=/tmp/tests

Example for win32/putty:

  make TEST_FPC=c:\fpc\compiler\ppcarm TEST_BINUTILSPREFIX=arm-linux- \
       TEST_PUTTY=root@192.168.42.210 TEST_REMOTEPATH=/tmp TEST_DELTEMP=1 \
       "TEST_REMOTEPW=xxx" FPC=c:\fpc\compiler\ppc386

Emulator execution
------------------

Emulator execution is possible as well. It can't be combined with remote execution though.

EMULATOR	     name of the emulator to use

Example:

make TEST_FPC=~/fpc/compiler/ppcrossarm TEST_OPT=-XParm-linux- EMULATOR=qemu-arm
make TEST_FPC=~/fpc/compiler/ppcrossarm TEST_OPT=-XParm-linux- EMULATOR=qemu-arm \
     digest DBDIGESTOPT="-C qemu-arm" USESQL=YES

Example cross testing of target MacOS with driver Darwin
--------------------------------------------------------
NOTE Today it is possible to run the test suite MacOS native.

A machine with both MacOS X and classic MacOS installed. Note that make will not
run the tests, that has to be done in MPW with the scripts in utils/macos.

  make clean alltest TEST_OS_TARGET=macos TEST_OPT="-WT -st" \
       USEUNITDIR=/Projekt/Freepascal/fpc/rtl/macos

To clean. Note that same options as above has to be given so that the correct
files will be removed.

  make clean TEST_OS_TARGET=macos USEUNITDIR=/Projekt/Freepascal/fpc/rtl/macos

Example cross testing of target arm-wince
-----------------------------------------
//arm-wince example : see FPCTRUNK\DEMO\WINCE\TESTEMU\ for additional required tools
make TEST_FPC=ppcrossarm TEST_CPU_TARGET=arm TEST_OS_TARGET=wince TEST_OPT="-XParm-wince-pe- -WC" EMULATOR=MyDisc:\My\Path\to\wcetemu.exe
