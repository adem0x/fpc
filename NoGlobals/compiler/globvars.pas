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
{ target specific tais - from aasmtai}
  cai_align : tai_align_class;
  cai_cpu   : tai_cpu_class;
//from cgobj
  {# Main code generator class }
  cg : tcg;
{$ifndef cpu64bitalu}
  {# Code generator class for all operations working with 64-Bit operands }
  cg64 : tcg64;
{$endif cpu64bitalu}

// --- nodes ---
var
  { caddnode is used to create nodes of the add type }
  { the virtual constructor allows to assign         }
  { another class type to caddnode => processor      }
  { specific node types can be created               }
  caddnode : taddnodeclass; //from nadd
//from nmem
  cloadvmtaddrnode : tloadvmtaddrnodeclass;
  cloadparentfpnode : tloadparentfpnodeclass;
  caddrnode : taddrnodeclass;
  cderefnode : tderefnodeclass;
  csubscriptnode : tsubscriptnodeclass;
  cvecnode : tvecnodeclass;
  cwithnode : twithnodeclass;
//from nbas
  cnothingnode : tnothingnodeclass;
  cerrornode : terrornodeclass;
  casmnode : tasmnodeclass;
  cstatementnode : tstatementnodeclass;
  cblocknode : tblocknodeclass;
  ctempcreatenode : ttempcreatenodeclass;
  ctemprefnode : ttemprefnodeclass;
  ctempdeletenode : ttempdeletenodeclass;
//from nflw
  cwhilerepeatnode : twhilerepeatnodeclass;
  cifnode : tifnodeclass;
  cfornode : tfornodeclass;
  cexitnode : texitnodeclass;
  cbreaknode : tbreaknodeclass;
  ccontinuenode : tcontinuenodeclass;
  cgotonode : tgotonodeclass;
  clabelnode : tlabelnodeclass;
  craisenode : traisenodeclass;
  ctryexceptnode : ttryexceptnodeclass;
  ctryfinallynode : ttryfinallynodeclass;
  connode : tonnodeclass;
//from ncnv
  ctypeconvnode : ttypeconvnodeclass;
  casnode : tasnodeclass;
  cisnode : tisnodeclass;
//from nmat
  cmoddivnode : tmoddivnodeclass;
  cshlshrnode : tshlshrnodeclass;
  cunaryminusnode : tunaryminusnodeclass;
  cnotnode : tnotnodeclass;
//from ncal
  ccallnode : tcallnodeclass;
  ccallparanode : tcallparanodeclass;
//from nopt
  caddsstringcharoptnode: taddsstringcharoptnodeclass;
  caddsstringcsstringoptnode: taddsstringcsstringoptnodeclass;
//from nset
  csetelementnode : tsetelementnodeclass;
  cinnode : tinnodeclass;
  crangenode : trangenodeclass;
  ccasenode : tcasenodeclass;
//from ncon
  cdataconstnode : tdataconstnodeclass;
  crealconstnode : trealconstnodeclass;
  cordconstnode : tordconstnodeclass;
  cpointerconstnode : tpointerconstnodeclass;
  cstringconstnode : tstringconstnodeclass;
  csetconstnode : tsetconstnodeclass;
  cguidconstnode : tguidconstnodeclass;
  cnilnode : tnilnodeclass;
//from nld
  cloadnode : tloadnodeclass;
  cassignmentnode : tassignmentnodeclass;
  carrayconstructorrangenode : tarrayconstructorrangenodeclass;
  carrayconstructornode : tarrayconstructornodeclass;
  ctypenode : ttypenodeclass;
  crttinode : trttinodeclass;
{$ELSE}
//in cgGlobVars
{$ENDIF}

implementation

{$IFDEF old}
{ Current callnode, this is needed for having a link
 between the callparanodes and the callnode they belong to }
function  aktcallnode : tcallnode; //from ncal
begin
  Result := tcallnode(current_module.callnode);
end;

function  PushCallNode(n: tcallnode): tcallnode;
begin
  Result := aktcallnode;
  current_module.callnode := n;
end;

procedure PopCallNode(n: tcallnode);
begin
  current_module.callnode := n;
end;

{ Current assignment node }
function  aktassignmentnode : tassignmentnode; //from nld
begin
  TObject(Result) := current_module.assignnode;
end;

function  PushAssignmentNode(n: tassignmentnode): tassignmentnode;
begin
  TObject(Result) := current_module.assignnode;
  current_module.assignnode := n;
end;

procedure PopAssignmentNode(n: tassignmentnode);
begin
  current_module.assignnode := n;
end;
{$ELSE}
{$ENDIF}

end.

