unit mesalib;

{$mode objfpc}

interface

uses
  Exec;

const
  MESANAME = 'mesa.library';
  
  // AMesaError
  AMESA_OUT_OF_MEM           = 1;
  AMESA_RASTPORT_TAG_MISSING = 2;
  AMESA_SCREEN_TAG_MISSING   = 3;
  AMESA_WINDOW_TAG_MISSING   = 4;

(*
 * This is the AROS/Mesa context structure. This is an opaque pointer.
 * All information is hidden away from user.
 *)

type
  TArosmesa_context = record
  end;

  AROSMesaContext =  ^TArosmesa_context;
  
  
const
(*
 * AROS Mesa Attribute tag ID's.  These are used in the ti_Tag field of
 * TagItem arrays passed to AROSMesaCreateContext()
 *)
  AMA_Dummy               = TAG_USER + 32;

(*
 * Offsets from rastport layer dimensions. 
 * Typically AMA_Left = window->BorderLeft, AMA_Top = window->BorderTop
 * Defaults: if rendering to non-GZZ window BorderLeft, BorderTop, in all other
 *           cases 0,0
 *)
  AMA_Left                = AMA_Dummy + $0002;
  AMA_Right               = AMA_Dummy + $0003;
  AMA_Top                 = AMA_Dummy + $0004;
  AMA_Bottom              = AMA_Dummy + $0005;

(*
 * Size in pixel of requested drawing area. Used to calculate AMA_Right, AMA_Bottom
 * if they are not passed. No defaults. Size of render area is calculated using:
 * rastport layer width - left - right, rastport layer height - top - bottom
 *)
  AMA_Width               = AMA_Dummy + $0006;
  AMA_Height              = AMA_Dummy + $0007;

(*
 * Target to which rendering will be done. Currently always pass AMA_Window
 *)
  AMA_Screen              = AMA_Dummy + $0011;
  AMA_Window              = AMA_Dummy + $0012;
  AMA_RastPort            = AMA_Dummy + $0013;

(*
 * Following boolean flags are ignored and always considered GL_TRUE
 *)
  AMA_DoubleBuf           = AMA_Dummy + $0030;
  AMA_RGBMode             = AMA_Dummy + $0031;
  AMA_AlphaFlag           = AMA_Dummy + $0032;

(* 
 * AMA_NoDepth:    don't allocate ZBuffer if GL_TRUE, default is GL_FALSE
 * AMA_NoStencil:  don't allocate StencilBuffer if GL_TRUE, default is GL_FALSE
 * AMA_NoAccum:    don't allocate AccumulationBuffer if GL_TRUE, default is GL_FALSE
 *)
  AMA_NoDepth             = AMA_Dummy + $0039;
  AMA_NoStencil           = AMA_Dummy + $003a;
  AMA_NoAccum             = AMA_Dummy + $003b;

  AMA_AROS_Extension      = AMA_Dummy + $0050;

var
  MesaBase: PLibrary;

implementation



initialization
  MesaBase := OpenLibrary(MESANAME, 0);
finalization
  CloseLibrary(MesaBase);

end.
