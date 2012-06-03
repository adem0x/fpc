{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by Michael Van Canneyt

    Implementation of pipe stream.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{$mode objfpc}

Unit Pipes;

Interface

Uses sysutils,Classes;

Type
  EPipeError = Class(EStreamError);
  EPipeSeek = Class (EPipeError);
  EPipeCreation = Class (EPipeError);

  { TInputPipeStream }

  TInputPipeStream = Class(THandleStream)
    Private
      FPos : Int64;
      function GetNumBytesAvailable: DWord;
    protected
      function GetPosition: Int64; override;
      procedure InvalidSeek; override;
    public
      destructor Destroy; override;
      Function Write (Const Buffer; Count : Longint) :Longint; Override;
      function Seek(const Offset: int64; Origin: TSeekOrigin): int64; override;
      Function Read (Var Buffer; Count : Longint) : longint; Override;
      property NumBytesAvailable: DWord read GetNumBytesAvailable;
    end;

  TOutputPipeStream = Class(THandleStream)
    Public
      destructor Destroy; override;
      function Seek(const Offset: int64; Origin: TSeekOrigin): int64; override;
      Function Read (Var Buffer; Count : Longint) : longint; Override;
    end;

Function CreatePipeHandles (Var Inhandle,OutHandle : THandle) : Boolean;
Procedure CreatePipeStreams (Var InPipe : TInputPipeStream;
                             Var OutPipe : TOutputPipeStream);

Const EPipeMsg = 'Failed to create pipe.';
      ENoSeekMsg = 'Cannot seek on pipes';


Implementation

{$i pipes.inc}

Procedure CreatePipeStreams (Var InPipe : TInputPipeStream;
                             Var OutPipe : TOutputPipeStream);

Var InHandle,OutHandle : THandle;

begin
  if CreatePipeHandles (InHandle, OutHandle) then
    begin
    InPipe:=TInputPipeStream.Create (InHandle);
    OutPipe:=TOutputPipeStream.Create (OutHandle);
    end
  Else
    Raise EPipeCreation.Create (EPipeMsg)
end;

destructor TInputPipeStream.Destroy;
begin
  PipeClose (Handle);
  inherited;
end;

Function TInputPipeStream.Write (Const Buffer; Count : Longint) : longint;

begin
{$ifdef ver2_2_0}
  raise EStreamError.Create( 'Cannot write to InputPipeStream');
{$else}
  WriteNotImplemented;
{$endif}
  Result := 0;
end;

Function TInputPipeStream.Read (Var Buffer; Count : Longint) : longint;

begin
  Result:=Inherited Read(Buffer,Count);
  Inc(FPos,Result);
end;

function TInputPipeStream.Seek(const Offset: int64; Origin: TSeekOrigin): int64;

begin
  FakeSeekForward(Offset,Origin,FPos);
  Result:=FPos;
end;

destructor TOutputPipeStream.Destroy;
begin
  PipeClose (Handle);
  inherited;
end;

Function TOutputPipeStream.Read(Var Buffer; Count : Longint) : longint;

begin
{$ifdef ver2_2_0}
  raise EStreamError.Create( 'Cannot read from OutputPipeStream');
{$else}
  ReadNotImplemented;
{$endif}
  Result := 0;
end;

function TOutputPipeStream.Seek(const Offset: int64; Origin: TSeekOrigin): int64;

begin
  InvalidSeek;
end;

end.
