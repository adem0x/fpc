unit fftw_s;
{
   FFTW - Fastest Fourier Transform in the West library

   This interface unit is (C) 2005 by Daniel Mantione
     member of the Free Pascal development team.

   See the file COPYING.FPC, included in this distribution,
   for details about the copyright.

   This file carries, as a independend work calling a well
   documented binary interface, the Free Pascal LGPL license
   with static linking exception.

   Note that the FFTW library itself carries the GPL license
   and can therefore not be used in non-GPL software.
}

{*****************************************************************************}
                                    interface
{*****************************************************************************}

{$CALLING cdecl} {Saves some typing.}

{$MACRO on}
{$INLINE on}

type    complex_single=record
          re,im:single;
        end;
        Pcomplex_single=^complex_single;

        fftw_plan_single=type pointer;

        fftw_sign=(fftw_backward=1,fftw_forward=$ffffffff);

        fftw_flag=(fftw_measure,            {generated optimized algorithm}
                   fftw_destroy_input,      {default}
                   fftw_unaligned,          {data is unaligned}
                   fftw_conserve_memory,    {needs no explanation}
                   fftw_exhaustive,         {search optimal algorithm}
                   fftw_preserve_input,     {don't overwrite input}
                   fftw_patient,            {generate highly optimized alg.}
                   fftw_estimate);          {don't optimize, just use an alg.}
        fftw_flagset=set of fftw_flag;
                   

{Complex to complex transformations.}
function fftw_plan_dft_1d(n:cardinal;i,o:Pcomplex_single;
                          sign:fftw_sign;flags:fftw_flagset):fftw_plan_single;
         external 'fftw3f' name 'fftwf_plan_dft_1d';
function fftw_plan_dft_2d(nx,ny:cardinal;i,o:Pcomplex_single;
                          sign:fftw_sign;flags:fftw_flagset):fftw_plan_single;
         external 'fftw3f' name 'fftwf_plan_dft_2d';
function fftw_plan_dft_3d(nx,ny,nz:cardinal;i,o:Pcomplex_single;
                          sign:fftw_sign;flags:fftw_flagset):fftw_plan_single;
         external 'fftw3f' name 'fftwf_plan_dft_3d';

function fftw_plan_dft(rank:cardinal;n:Pcardinal;i,o:Pcomplex_single;
                       sign:fftw_sign;flags:fftw_flagset):fftw_plan_single;
         external 'fftw3f' name 'fftwf_plan_dft';

{Real to complex transformations.}
function fftw_plan_dft_1d(n:cardinal;i:Psingle;o:Pcomplex_single;
                          flags:fftw_flagset):fftw_plan_single;
         external 'fftw3f' name 'fftwf_plan_dft_r2c_1d';
function fftw_plan_dft_2d(nx,ny:cardinal;i:Psingle;o:Pcomplex_single;
                          flags:fftw_flagset):fftw_plan_single;
         external 'fftw3f' name 'fftwf_plan_dft_r2c_2d';
function fftw_plan_dft_3d(nx,ny,nz:cardinal;i:Psingle;o:Pcomplex_single;
                          flags:fftw_flagset):fftw_plan_single;
         external 'fftw3f' name 'fftwf_plan_dft_r2c_3d';
function fftw_plan_dft(rank:cardinal;n:Pcardinal;i:Psingle;o:Pcomplex_single;
                       flags:fftw_flagset):fftw_plan_single;
         external 'fftw3f' name 'fftwf_plan_dft_r2c';

{Complex to real transformations.}
function fftw_plan_dft_1d(n:cardinal;i:Pcomplex_single;o:Psingle;
                          flags:fftw_flagset):fftw_plan_single;
         external 'fftw3f' name 'fftwf_plan_dft_c2r_1d';
function fftw_plan_dft_2d(nx,ny:cardinal;i:Pcomplex_single;o:Psingle;
                          flags:fftw_flagset):fftw_plan_single;
         external 'fftw3f' name 'fftwf_plan_dft_c2r_2d';
function fftw_plan_dft_3d(nx,ny,nz:cardinal;i:Pcomplex_single;o:Psingle;
                          flags:fftw_flagset):fftw_plan_single;
         external 'fftw3f' name 'fftwf_plan_dft_c2r_3d';
function fftw_plan_dft(rank:cardinal;n:Pcardinal;i:Pcomplex_single;o:Psingle;
                       flags:fftw_flagset):fftw_plan_single;
         external 'fftw3f' name 'fftwf_plan_dft_c2r';


procedure fftw_destroy_plan(plan:fftw_plan_single);
          external 'fftw3f' name 'fftwf_destroy_plan';
procedure fftw_execute(plan:fftw_plan_single);
          external 'fftw3f' name 'fftwf_execute';

{*****************************************************************************}
                                  implementation
{*****************************************************************************}

{$LINKLIB fftw3f}

{Required libraries by libfftw3}
{$LINKLIB gcc}
{$LINKLIB c}
{$LINKLIB m}

{$calling register} {Back to normal!}

{Better don't use fftw_malloc and fftw_free, but provide Pascal replacements.}

{$IF defined(cpui386) or defined(cpupowerpc)}
  {$DEFINE align:=16}
{$ENDIF}

procedure fftw_getmem(var p:pointer;size:sizeint);

begin
{$IFDEF align}
  getmem(p,size+16-1);
  ptruint(p):=(ptruint(p)+align-1) and not (align-1);
{$ELSE}
  getmem(p,size);
{$ENDIF}
end;

procedure fftw_freemem(p:pointer);inline;

begin
  freemem(p);
end;

end.
