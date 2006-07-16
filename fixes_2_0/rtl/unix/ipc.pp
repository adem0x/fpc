{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2004 by the Free Pascal development team

    This file implements IPC calls calls for Linu/FreeBSD

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

Unit ipc;

interface

Uses BaseUnix;

{ ----------------------------------------------------------------------
  General IPC stuff
  ----------------------------------------------------------------------}

//Var
//  IPCError : longint;

Type

   {$IFDEF FreeBSD}
   TKey   = clong;
   {$ELSE}
   TKey   = longint;
   {$ENDIF}
   key_t  = TKey;


Const
  { IPC flags for get calls }

{$ifdef FreeBSD}  // BSD_VISIBLE
  IPC_R      =  4 shl 6;
  IPC_W      =  2 shl 6;
  IPC_M      =  2 shl 12;
{$endif}

  IPC_CREAT  =  1 shl 9;  { create if key is nonexistent }
  IPC_EXCL   =  2 shl 9;  { fail if key exists }
  IPC_NOWAIT =  4 shl 9;  { return error on wait }

  {$IFDEF FreeBSD}
  IPC_PRIVATE : TKey = 0;
  {$ENDIF}

  { Actions for ctl calls }

  IPC_RMID = 0;     { remove resource }
  IPC_SET  = 1;     { set ipc_perm options }
  IPC_STAT = 2;     { get ipc_perm options }
  IPC_INFO = 3;     { see ipcs }

type
  PIPC_Perm = ^TIPC_Perm;
  {$ifdef FreeBSD}
  TIPC_Perm = record
        cuid  : cushort;  { creator user id }
        cgid  : cushort;  { creator group id }
        uid   : cushort;  { user id }
        gid   : cushort;  { group id }
        mode  : cushort;  { r/w permission }
        seq   : cushort;  { sequence # (to generate unique msg/sem/shm id) }
        key   : key_t;    { user specified msg/sem/shm key }
        End;
  {$else} // linux
  TIPC_Perm = record
        key   : TKey;
        uid,
        gid,
        cuid,
        cgid,
        mode,
        seq   : Word;
        End;
  {$endif}

{ Function to generate a IPC key. }
Function ftok (Path : pchar;  ID : cint) : TKey;

{ ----------------------------------------------------------------------
  Sys V Shared memory stuff
  ----------------------------------------------------------------------}

Type
  PShmid_DS = ^TShmid_ds;
{$ifdef linux}
  TShmid_ds = record
    shm_perm  : TIPC_Perm;
    shm_segsz : longint;
    shm_atime : longint;
    shm_dtime : longint;
    shm_ctime : longint;
    shm_cpid  : word;
    shm_lpid  : word;
    shm_nattch : integer;
    shm_npages : word;
    shm_pages  : Pointer;
    attaches   : pointer;
  end;
{$else} // FreeBSD checked
  TShmid_ds = record
    shm_perm  : TIPC_Perm;
    shm_segsz : cint;
    shm_lpid  : pid_t;
    shm_cpid  : pid_t;
    shm_nattch : cshort;
    shm_atime : time_t;
    shm_dtime : time_t;
    shm_ctime : time_t;
    shm_internal : pointer;
  end;
{$endif}

  const
{$ifdef linux}
     SHM_R      = 4 shl 6;
     SHM_W      = 2 shl 6;
{$else}
     SHM_R      = IPC_R;
     SHM_W      = IPC_W;
{$endif}

     SHM_RDONLY = 1 shl 12;
     SHM_RND    = 2 shl 12;
{$ifdef Linux}
     SHM_REMAP  = 4 shl 12;
{$endif}

     SHM_LOCK   = 11;
     SHM_UNLOCK = 12;

{$ifdef FreeBSD}        // ipcs shmctl commands
     SHM_STAT   = 13;
     SHM_INFO   = 14;
{$endif}

type            // the shm*info kind is "kernel" only.
  PSHMinfo = ^TSHMinfo;
  TSHMinfo = record             // comment under FreeBSD: do we really need
                                // this?
    shmmax : cint;
    shmmin : cint;
    shmmni : cint;
    shmseg : cint;
    shmall : cint;
  end;

{$ifdef FreeBSD}
  PSHM_info = ^TSHM_info;
  TSHM_info = record
    used_ids : cint;
    shm_tot,
    shm_rss,
    shm_swp,
    swap_attempts,
    swap_successes : culong;
  end;
{$endif}

Function shmget(key: Tkey; size:cint; flag:cint):cint;
Function shmat (shmid:cint; shmaddr:pointer; shmflg:cint):pointer;
Function shmdt (shmaddr:pointer):cint;
Function shmctl(shmid:cint; cmd:cint; buf: pshmid_ds): cint;

{ ----------------------------------------------------------------------
  Message queue stuff
  ----------------------------------------------------------------------}

const
  MSG_NOERROR = 1 shl 12;

{$ifdef Linux}
  MSG_EXCEPT  = 2 shl 12;

  MSGMNI = 128;
  MSGMAX = 4056;
  MSGMNB = 16384;
{$endif}

type
  msglen_t = culong;
  msgqnum_t= culong;

  PMSG = ^TMSG;
  TMSG = record
{$ifndef FreeBSD}                       // opague in FreeBSD
    msg_next  : PMSG;
    msg_type  : Longint;
    msg_spot  : PChar;
    msg_stime : Longint;
    msg_ts    : Integer;
{$endif}
  end;

type

{$ifdef Linux}
  PMSQid_ds = ^TMSQid_ds;
  TMSQid_ds = record
    msg_perm   : TIPC_perm;
    msg_first  : PMsg;
    msg_last   : PMsg;
    msg_stime  : Longint;
    msg_rtime  : Longint;
    msg_ctime  : Longint;
    wwait      : Pointer;
    rwait      : pointer;
    msg_cbytes : word;
    msg_qnum   : word;
    msg_qbytes : word;
    msg_lspid  : word;
    msg_lrpid  : word;
  end;
{$else}
  PMSQid_ds = ^TMSQid_ds;
  TMSQid_ds = record
    msg_perm   : TIPC_perm;
    msg_first  : PMsg;
    msg_last   : PMsg;
    msg_cbytes : msglen_t;
    msg_qnum   : msgqnum_t;
    msg_qbytes : msglen_t;
    msg_lspid  : pid_t;
    msg_lrpid  : pid_t;
    msg_stime  : time_t;
    msg_pad1   : clong;
    msg_rtime  : time_t;
    msg_pad2   : clong;
    msg_ctime  : time_t;
    msg_pad3   : clong;
    msg_pad4   : array [0..3] of clong;
  end;
{$endif}

  PMSGbuf = ^TMSGbuf;
  TMSGbuf = record              // called mymsg on freebsd and SVID manual
    mtype : longint;
    mtext : array[0..0] of char;
  end;

{$ifdef linux}
  PMSGinfo = ^TMSGinfo;
  TMSGinfo = record
    msgpool : Longint;
    msgmap  : Longint;
    msgmax  : Longint;
    msgmnb  : Longint;
    msgmni  : Longint;
    msgssz  : Longint;
    msgtql  : Longint;
    msgseg  : Word;
  end;
{$else}
  PMSGinfo = ^TMSGinfo;
  TMSGinfo = record
    msgmax,
    msgmni,
    msgmnb,
    msgtql,
    msgssz,
    msgseg  : cint;
  end;
{$endif}

Function msgget(key: TKey; msgflg:cint):cint;
Function msgsnd(msqid:cint; msgp: PMSGBuf; msgsz: size_t; msgflg:cint): cint;
Function msgrcv(msqid:cint; msgp: PMSGBuf; msgsz: size_t; msgtyp:cint; msgflg:cint):cint;
Function msgctl(msqid:cint; cmd: cint; buf: PMSQid_ds): cint;

{ ----------------------------------------------------------------------
  Semaphores stuff
  ----------------------------------------------------------------------}

const
{$ifdef Linux}                  // renamed to many name clashes
  SEM_UNDO = $1000;
  SEM_GETPID = 11;
  SEM_GETVAL = 12;
  SEM_GETALL = 13;
  SEM_GETNCNT = 14;
  SEM_GETZCNT = 15;
  SEM_SETVAL = 16;
  SEM_SETALL = 17;

  SEM_SEMMNI = 128;
  SEM_SEMMSL = 32;
  SEM_SEMMNS = (SEM_SEMMNI * SEM_SEMMSL);
  SEM_SEMOPM = 32;
  SEM_SEMVMX = 32767;
{$else}
  SEM_UNDO = 1 shl 12;
  MAX_SOPS = 5;

  SEM_GETNCNT = 3;   { Return the value of sempid {READ}  }
  SEM_GETPID  = 4;   { Return the value of semval {READ}  }
  SEM_GETVAL  = 5;   { Return semvals into arg.array {READ}  }
  SEM_GETALL  = 6;   { Return the value of semzcnt {READ}  }
  SEM_GETZCNT = 7;   { Set the value of semval to arg.val {ALTER}  }
  SEM_SETVAL  = 8;   { Set semvals from arg.array {ALTER}  }
  SEM_SETALL  = 9;

  { Permissions  }

  SEM_A = 2 shl 6;  { alter permission  }
  SEM_R = 4 shl 6;  { read permission  }
{$endif}

type
{$ifdef Linux}
  PSEMid_ds = ^TSEMid_ds;
  TSEMid_ds = record
    sem_perm : tipc_perm;
    sem_otime : longint;
    sem_ctime : longint;
    sem_base         : pointer;
    sem_pending      : pointer;
    sem_pending_last : pointer;
    undo             : pointer;
    sem_nsems : word;
  end;
{$else}

     sem=record end; // opague

  PSEMid_ds = ^TSEMid_ds;
  TSEMid_ds = record
          sem_perm : tipc_perm;
          sem_base : ^sem;
          sem_nsems : cushort;
          sem_otime : time_t;
          sem_pad1 : cint;
          sem_ctime : time_t;
          sem_pad2 : cint;
          sem_pad3 : array[0..3] of cint;
       end;
{$endif}

  PSEMbuf = ^TSEMbuf;
  TSEMbuf = record
    sem_num : cushort;
    sem_op  : cshort;
    sem_flg : cshort;
  end;


  PSEMinfo = ^TSEMinfo;
  TSEMinfo = record
    semmap : cint;
    semmni : cint;
    semmns : cint;
    semmnu : cint;
    semmsl : cint;
    semopm : cint;
    semume : cint;
    semusz : cint;
    semvmx : cint;
    semaem : cint;
  end;

{ internal mode bits}

{$ifdef FreeBSD}
Const
  SEM_ALLOC = 1 shl 9;
  SEM_DEST  = 2 shl 9;
{$endif}

Type
  PSEMun = ^TSEMun;
  TSEMun = record
   case cint of
      0 : ( val : cint );
      1 : ( buf : PSEMid_ds );
      2 : ( arr : PWord );              // ^ushort
{$ifdef linux}
      3 : ( padbuf : PSeminfo );
      4 : ( padpad : pointer );
{$endif}
   end;

Function semget(key:Tkey; nsems:cint; semflg:cint): cint;
Function semop(semid:cint; sops: psembuf; nsops: cuint): cint;
Function semctl(semid:cint; semnum:cint; cmd:cint; var arg: tsemun): longint;

implementation

uses Syscall;

{$ifdef FPC_USE_LIBC}
 {$i ipccdecl.inc}
{$else}
 {$ifdef Linux}
  {$ifdef cpux86_64}
    {$i ipcsys.inc}
  {$else}
    {$i ipccall.inc}
  {$endif}
 {$endif}
 {$ifdef BSD}
   {$i ipcbsd.inc}
 {$endif}
{$endif}


end.
