program test;

{$mode objfpc}

uses
  classes, sysutils, ctypes, openal, mad, ogg, vorbis;

var
  source     : TStream;
  codec      : Integer;
  codec_bs   : Longword;
  codec_read : function(const Buffer: Pointer; const Count: Longword): Longword = nil;
  codec_rate : Longword;
  codec_chan : Longword;


// mad
const
  MAD_INPUT_BUFFER_SIZE = 5*8192;

var
  m_stream  : mad_stream;
  m_frame   : mad_frame;
  m_synth   : mad_synth;
  m_inbuf   : array[0..MAD_INPUT_BUFFER_SIZE-1] of Byte;

{procedure mad_reset;
begin
  mad_stream_finish(m_stream);
  mad_stream_init(m_stream);
  source.Position := 0;
end;}

function mad_read(const Buffer: Pointer; const Count: Longword): Longword;
var
  X         : Integer;
  Num       : Longword;
  Ofs       : Longword;
  Remaining : Integer;
  ReadStart : Pointer;
  ReadSize  : Integer;
  Output    : PSmallint;
begin
  Ofs := 0;
  Num := Count;
  while Num > 0 do
  begin
    if (m_stream.buffer = nil) or (m_stream.error = MAD_ERROR_BUFLEN) then
    begin
      if Assigned(m_stream.next_frame) then
      begin
        Remaining := PtrInt(m_stream.bufend) - PtrInt(m_stream.next_frame);
        Move(m_stream.next_frame^, m_inbuf, Remaining);
        ReadStart := Pointer(PtrInt(@m_inbuf) + Remaining);
        ReadSize  := MAD_INPUT_BUFFER_SIZE - Remaining;
      end else begin
        ReadSize  := MAD_INPUT_BUFFER_SIZE;
        ReadStart := @m_inbuf;
        Remaining := 0;
      end;

      ReadSize := source.Read(ReadStart^, ReadSize);
      if ReadSize = 0 then
        Break;

      mad_stream_buffer(m_stream, @m_inbuf, ReadSize+Remaining);
      m_stream.error := MAD_ERROR_NONE;
    end;

    if mad_frame_decode(m_frame, m_stream) <> 0 then
    begin
      if MAD_RECOVERABLE(m_stream.error) or (m_stream.error = MAD_ERROR_BUFLEN) then
        Continue;

      Exit(0);
    end;

    mad_synth_frame(m_synth, m_frame);

    Output := Pointer(PtrUInt(Buffer) + Ofs);
    with m_synth do
    if pcm.channels = 2 then
    begin
      for X := 0 to pcm.length -1 do
      begin
         if pcm.samples[0][X] >= MAD_F_ONE then
           pcm.samples[0][X] := MAD_F_ONE - 1;
         if pcm.samples[0][X] < -MAD_F_ONE then
           pcm.samples[0][X] := -MAD_F_ONE;
         pcm.samples[0][X] := pcm.samples[0][X] shr (MAD_F_FRACBITS + 1 - 16);
         Output[X shl 1] := pcm.samples[0][X] div 2;

         if pcm.samples[1][X] >= MAD_F_ONE then
           pcm.samples[1][X] := MAD_F_ONE - 1;
         if pcm.samples[1][X] < -MAD_F_ONE then
           pcm.samples[1][X] := -MAD_F_ONE;
         pcm.samples[1][X] := pcm.samples[1][X] shr (MAD_F_FRACBITS + 1 - 16);
         Output[(X shl 1)+1] := pcm.samples[1][X] div 2;
      end;
    end else begin
      for X := 0 to pcm.length -1 do
      begin
         if pcm.samples[0][X] >= MAD_F_ONE then
           pcm.samples[0][X] := MAD_F_ONE - 1;
         if pcm.samples[0][X] < -MAD_F_ONE then
           pcm.samples[0][X] := -MAD_F_ONE;
         pcm.samples[0][X] := pcm.samples[0][X] shr (MAD_F_FRACBITS + 1 - 16);

         Output[X shl 1] := pcm.samples[0][X] div 2;
         Output[(X shl 1)+1] := pcm.samples[0][X] div 2;
      end;
    end;

    Ofs := Ofs + PtrUInt(4*m_synth.pcm.length);
    Num := Num - PtrUInt(4*m_synth.pcm.length);
  end;

  Result := Ofs;
end;


// oggvorbis
var
  ogg_vorbis    : OggVorbis_File;
  ogg_callbacks : ov_callbacks;

function ogg_read_func(ptr: pointer; size, nmemb: csize_t; datasource: pointer): csize_t; cdecl;
begin
  WriteLn('ogg_read_func');
  Result := TStream(datasource).Read(ptr^, size*nmemb);
end;

function ogg_seek_func(datasource: pointer; offset: ogg_int64_t; whence: cint): cint; cdecl;
begin
  WriteLn('ogg_seek_func');
  //TStream(datasource).Seek(offset, );
  Result := -1;
end;

function ogg_close_func(datasource: pointer): cint; cdecl;
begin
  WriteLn('ogg_close_func');
  TStream(datasource).Position := 0;
  Result := 0;
end;

function ogg_tell_func(datasource: pointer): clong; cdecl;
begin
  WriteLn('ogg_tell_func');
  Result := TStream(datasource).Position;
end;

{procedure ogg_reset;
begin
  ov_pcm_seek(ogg_vorbis, 0);
end;}

function ogg_read(const Buffer: Pointer; const Count: Longword): Longword;
var
  Ofs: Longword;
  Num: Longword;
begin
  Ofs := 0;
  Num := Count;

  while Num > 0 do
  begin
    if ov_read(ogg_vorbis, Pointer(PtrUInt(Buffer) + Ofs), Num, 0, 2, 1, nil) < 0 then
      Exit(0);

    if Result = 0 then
      Break;

    Ofs := Ofs + Result;
    Num := Num - Result;
  end;

  Result := Ofs;
end;


// openal
const
  al_format  : array[1..2] of ALenum = (AL_FORMAT_MONO16, AL_FORMAT_STEREO16);

// Note: if you lower the al_bufcount, then you have to modify the al_polltime also!
  al_bufcount           = 4;
  al_polltime           = 100;

var
  al_device  : PALCdevice;
  al_context : PALCcontext;
  al_source  : ALuint;
  al_buffers : array[0..al_bufcount-1] of ALuint;
  al_bufsize : Longword;
  al_readbuf : Pointer;

procedure alPlay;
var
  i: Integer;
begin
  alSourceStop(al_source);
  alSourceRewind(al_source);
  alSourcei(al_source, AL_BUFFER, 0);

  for i := 0 to al_bufcount - 1 do
  begin
    if codec_read(al_readbuf, al_bufsize) = 0 then
      Break;

    alBufferData(al_buffers[i], al_format[codec_chan], al_readbuf, al_bufsize, codec_rate);
    alSourceQueueBuffers(al_source, 1, @al_buffers[i]);
  end;

  // Under windows, AL_LOOPING = AL_TRUE breaks queueing, no idea why
  alSourcei(al_source, AL_LOOPING, AL_FALSE);
  alSourcePlay(al_source);
end;

procedure alStop;
begin
  alSourceStop(al_source);
  alSourceRewind(al_source);
  alSourcei(al_source, AL_BUFFER, 0);
  WriteLn('Stop');
end;

function alProcess: Boolean;
var
  processed : ALint;
  buffer    : ALuint;
begin
  alGetSourcei(al_source, AL_BUFFERS_PROCESSED, processed);
  while (processed > 0) and (processed <= al_bufcount) do
  begin
    alSourceUnqueueBuffers(al_source, 1, @buffer);

    if codec_read(al_readbuf, al_bufsize) = 0 then
    begin
      alStop;
      Exit(False);
    end;

    alBufferData(buffer, al_format[codec_chan], al_readbuf, al_bufsize, codec_rate);
    alSourceQueueBuffers(al_source, 1, @buffer);

    Dec(processed);
  end;

  Result := True;
end;

var
  Filename: String;
  ov: pvorbis_info;
begin
// define codec
  {WriteLn('Define codec');
  Writeln('  (1) mp3');
  Writeln('  (2) ogg');
  Write('Enter: '); ReadLn(codec);
  Write('File: '); ReadLn(Filename);}

  codec := 2;
  Filename := '/test.ogg';


// load file
  source := TFileStream.Create(Filename, fmOpenRead);


// inittialize codec
  case codec of
    1: // mad
      begin
        mad_stream_init(m_stream);
        mad_frame_init(m_frame);
        mad_synth_init(m_synth);
        codec_bs   := 4*1152;
        codec_read := @mad_read;
        codec_rate := 44100;
        codec_chan := 2;
      end;

    2: // oggvorbis
      begin
        WriteLn('a');

        ogg_callbacks.read  := @ogg_read_func;
        ogg_callbacks.seek  := @ogg_seek_func;
        ogg_callbacks.close := @ogg_close_func;
        ogg_callbacks.tell  := @ogg_tell_func;

        //writeln(format('Foo: %p', [@ogg_callbacks]));

        if ov_open_callbacks(source, ogg_vorbis, nil, 0, ogg_callbacks) >= 0 then
        begin
          WriteLn('b');
          ov := ov_info(ogg_vorbis, -1);
          codec_bs   := 4;
          codec_read := @ogg_read;
          codec_rate := ov^.rate;
          codec_chan := ov^.channels;
        end;
      end;
  end;

  if not Assigned(codec_read) then
    Exit;

  al_bufsize := 20000 - (20000 mod codec_bs);
  WriteLn('Codec Blocksize    : ', codec_bs);
  WriteLn('Codec Rate         : ', codec_rate);
  WriteLn('Codec Channels     : ', codec_chan);
  WriteLn('OpenAL Buffers     : ', al_bufcount);
  WriteLn('OpenAL Buffer Size : ', al_bufsize);


// init openal
  al_device := alcOpenDevice(nil);
  al_context := alcCreateContext(al_device, nil);
  alcMakeContextCurrent(al_context);

  alDistanceModel(AL_INVERSE_DISTANCE_CLAMPED);
  alGenSources(1, @al_source);
  alGenBuffers(al_bufcount, @al_buffers);

  GetMem(al_readbuf, al_bufsize);


// play
  alPlay;
  while alProcess do
    Sleep(al_polltime);

// finalize openal
  alDeleteSources(1, @al_source);
  alDeleteBuffers(al_bufcount, @al_buffers);
  alcDestroyContext(al_context);
  alcCloseDevice(al_device);
  FreeMem(al_readbuf);


// finalize codec
  case codec of
    1: // mad
      begin
        mad_synth_finish(m_synth);
        mad_frame_finish(m_frame);
        mad_stream_finish(m_stream);
      end;

    2: // oggvorbis
      begin
        ov_clear(ogg_vorbis);
      end;
  end;


// close file
  source.Free;
end.