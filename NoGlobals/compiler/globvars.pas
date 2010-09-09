unit GlobVars;
(* Contains all general global variables.
  May be merged into Globals?

  This unit must be used only in implementations.
*)

{$I fpcdefs.inc}

interface

uses
  fmodule,procinfo;
  //ncgrtti, aasmdata,aasmtai, cgobj,procinfo,
  //nbas, ncal,nadd,nmem,nmat,nflw,ncnv,nopt,nset,ncon,nld;

// --- compiler state ---

var //to become threadvar
{ Current module which is compiled or loaded }
  current_module: tmodule;  //from FModule

// --- initial settings ---
var
  GlobalModule: TGlobalModule;  //from FModule

  //tprocinfo class - cpu specific
  //cprocinfo : tcprocinfo; //from procinfo

{$IFDEF old}
//code generation specific?
// --- code generation ... ---
  RTTIWriter : TRTTIWriter; //from ncgRTTI
  CAsmCFI : TAsmCFIClass;   //from aasmdata
{$ELSE}
//in cgGlobVars
{$ENDIF}

implementation

end.

