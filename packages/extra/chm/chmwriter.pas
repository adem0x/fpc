{ Copyright (C) <2005> <Andrew Haines> chmwriter.pas

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}
{
  See the file COPYING.FPC, included in this distribution,
  for details about the copyright.
}
unit chmwriter;
{$MODE OBJFPC}{$H+}

interface
uses Classes, ChmBase, chmtypes, chmspecialfiles;

type

  TGetDataFunc = function (const DataName: String; out PathInChm: String; out FileName: String; var Stream: TStream): Boolean of object;
  //  DataName :  A FileName or whatever so that the getter can find and open the file to add
  //  PathInChm:  This is the absolute path in the archive. i.e. /home/user/helpstuff/
  //              becomes '/' and /home/user/helpstuff/subfolder/ > /subfolder/
  //  FileName :  /home/user/helpstuff/index.html > index.html
  //  Stream   :  the file opened with DataName should be written to this stream


  { TChmWriter }

  TChmWriter = class(TObject)
    FOnLastFile: TNotifyEvent;
  private
  
    ForceExit: Boolean;
    
    FDefaultFont: String;
    FDefaultPage: String;
    FFullTextSearch: Boolean;
    FInternalFiles: TFileEntryList; // Contains a complete list of files in the chm including
    FFrameSize: LongWord;           // uncompressed files and special internal files of the chm
    FCurrentStream: TStream; // used to buffer the files that are to be compressed
    FCurrentIndex: Integer;
    FOnGetFileData: TGetDataFunc;
    FStringsStream: TMemoryStream;
    FContextStream: TMemoryStream; // the #IVB file
    FSection0: TMemoryStream;
    FSection1: TStream; // Compressed Stream
    FSection1Size: QWord;
    FSection1ResetTable: TMemoryStream; // has a list of frame positions NOT window positions
    FDirectoryListings: TStream;
    FOutStream: TStream;
    FFileNames: TStrings;
    FDestroyStream: Boolean;
    FTempStream: TStream;
    FPostStream: TStream;
    FTitle: String;
    FHasTOC: Boolean;
    FHasIndex: Boolean;
    FWindowSize: LongWord;
    FReadCompressedSize: QWord; // Current Size of Uncompressed data that went in Section1 (compressed)
    // Linear order of file
    ITSFHeader: TITSFHeader;
    HeaderSection0Table: TITSFHeaderEntry;  // points to HeaderSection0
    HeaderSection1Table: TITSFHeaderEntry; // points to HeaderSection1
    HeaderSuffix: TITSFHeaderSuffix; //contains the offset of CONTENTSection0 from zero
    HeaderSection0: TITSPHeaderPrefix;
    HeaderSection1: TITSPHeader; // DirectoryListings header
    // DirectoryListings
    // CONTENT Section 0 (section 1 is contained in section 0)
    // EOF
    // end linear header parts
    procedure InitITSFHeader;
    procedure InitHeaderSectionTable;
    procedure SetTempRawStream(const AValue: TStream);
    procedure WriteHeader(Stream: TStream);
    procedure CreateDirectoryListings;
    procedure WriteDirectoryListings(Stream: TStream);
    procedure StartCompressingStream;
    procedure WriteSYSTEM;
    procedure WriteITBITS;
    procedure WriteSTRINGS;
    procedure WriteIVB; // context ids
    procedure WriteREADMEFile;
    procedure WriteSection0;
    procedure WriteSection1;
    procedure WriteDataSpaceFiles(const AStream: TStream);
    function AddString(AString: String): LongWord;
    // callbacks for lzxcomp
    function  AtEndOfData: Longbool;
    function  GetData(Count: LongInt; Buffer: PByte): LongInt;
    function  WriteCompressedData(Count: Longint; Buffer: Pointer): LongInt;
    procedure MarkFrame(UnCompressedTotal, CompressedTotal: LongWord);
    // end callbacks
  public
    constructor Create(OutStream: TStream; FreeStreamOnDestroy: Boolean);
    destructor Destroy; override;
    procedure Execute;
    procedure AppendTOC(AStream: TStream);
    procedure AppendIndex(AStream: TStream);
    procedure AppendSearchDB(AName: String; AStream: TStream);
    procedure AddStreamToArchive(AFileName, APath: String; AStream: TStream; Compress: Boolean = True);
    procedure PostAddStreamToArchive(AFileName, APath: String; AStream: TStream; Compress: Boolean = True);
    procedure AddContext(AContext: DWord; ATopic: String);
    property WindowSize: LongWord read FWindowSize write FWindowSize default 2; // in $8000 blocks
    property FrameSize: LongWord read FFrameSize write FFrameSize default 1; // in $8000 blocks
    property FilesToCompress: TStrings read FFileNames;
    property OnGetFileData: TGetDataFunc read FOnGetFileData write FOnGetFileData;
    property OnLastFile: TNotifyEvent read FOnLastFile write FOnLastFile;
    property OutStream: TStream read FOutStream;
    property Title: String read FTitle write FTitle;
    property FullTextSearch: Boolean read FFullTextSearch write FFullTextSearch;
    property DefaultFont: String read FDefaultFont write FDefaultFont;
    property DefaultPage: String read FDefaultPage write FDefaultPage;
    property TempRawStream: TStream read FTempStream write SetTempRawStream;
    //property LocaleID: dword read ITSFHeader.LanguageID write ITSFHeader.LanguageID;
  end;

implementation
uses dateutils, sysutils, paslzxcomp;

const

  LZX_WINDOW_SIZE = 16; // 16 = 2 frames = 1 shl 16
  LZX_FRAME_SIZE = $8000;

{ TChmWriter }

procedure TChmWriter.InitITSFHeader;
begin
  with ITSFHeader do begin
    ITSFsig := ITSFFileSig;
    Version := NToLE(DWord(3));
    // we fix endian order when this is written to the stream
    HeaderLength := NToLE(DWord(SizeOf(TITSFHeader) + (SizeOf(TITSFHeaderEntry)*2) + SizeOf(TITSFHeaderSuffix)));
    Unknown_1 := NToLE(DWord(1));
    TimeStamp:= NToBE(MilliSecondOfTheDay(Now)); //bigendian
    LanguageID := NToLE(DWord($0409)); // English / English_US
    Guid1 := ITSFHeaderGUID;
    Guid2 := ITSFHeaderGUID;
  end;
end;

procedure TChmWriter.InitHeaderSectionTable;
begin
  // header section 0
  HeaderSection0Table.PosFromZero := LEToN(ITSFHeader.HeaderLength);
  HeaderSection0Table.Length := SizeOf(TITSPHeaderPrefix);
  // header section 1
  HeaderSection1Table.PosFromZero := HeaderSection0Table.PosFromZero + HeaderSection0Table.Length;
  HeaderSection1Table.Length := SizeOf(TITSPHeader)+FDirectoryListings.Size;
  
  //contains the offset of CONTENT Section0 from zero
  HeaderSuffix.Offset := HeaderSection1Table.PosFromZero + HeaderSection1Table.Length;
  
  // now fix endian stuff
  HeaderSection0Table.PosFromZero := NToLE(HeaderSection0Table.PosFromZero);
  HeaderSection0Table.Length := NToLE(HeaderSection0Table.Length);
  HeaderSection1Table.PosFromZero := NToLE(HeaderSection1Table.PosFromZero);
  HeaderSection1Table.Length := NToLE(HeaderSection1Table.Length);

  with HeaderSection0 do begin // TITSPHeaderPrefix;
    Unknown1 := NToLE(DWord($01FE));
    Unknown2 := 0;
    // at this point we are putting together the headers. content sections 0 and 1 are complete
    FileSize := NToLE(HeaderSuffix.Offset + FSection0.Size + FSection1Size);
    Unknown3 := 0;
    Unknown4 := 0;
  end;
  with HeaderSection1 do begin // TITSPHeader; // DirectoryListings header
    ITSPsig := ITSPHeaderSig;
    Version := NToLE(DWord(1));
    DirHeaderLength := NToLE(DWord(SizeOf(TITSPHeader)));  // Length of the directory header
    Unknown1 := NToLE(DWord($0A));
    ChunkSize := NToLE(DWord($1000));
    Density := NToLE(DWord(2));
    // updated when directory listings were created
    //IndexTreeDepth := 1 ; // 1 if there is no index 2 if there is one level of PMGI chunks. will update as
    //IndexOfRootChunk := -1;// if no root chunk
    //FirstPMGLChunkIndex,
    //LastPMGLChunkIndex: LongWord;
    
    Unknown2 := NToLE(Longint(-1));
    //DirectoryChunkCount: LongWord;
    LanguageID := NToLE(DWord($0409));
    GUID := ITSPHeaderGUID;
    LengthAgain := NToLE(DWord($54));
    Unknown3 := NToLE(Longint(-1));
    Unknown4 := NToLE(Longint(-1));
    Unknown5 := NToLE(Longint(-1));
  end;
  
  // more endian stuff
  HeaderSuffix.Offset := NToLE(HeaderSuffix.Offset);
end;

procedure TChmWriter.SetTempRawStream(const AValue: TStream);
begin
  if (FCurrentStream.Size > 0) or (FSection1.Size > 0) then
    raise Exception.Create('Cannot set the TempRawStream once data has been written to it!');
  if AValue = nil then
    raise Exception.Create('TempRawStream cannot be nil!');
  if FCurrentStream = AValue then
    exit;
  FCurrentStream.Free;
  FCurrentStream := AValue;
end;

procedure TChmWriter.WriteHeader(Stream: TStream);
begin
  Stream.Write(ITSFHeader, SizeOf(TITSFHeader));
  Stream.Write(HeaderSection0Table, SizeOf(TITSFHeaderEntry));
  Stream.Write(HeaderSection1Table, SizeOf(TITSFHeaderEntry));
  Stream.Write(HeaderSuffix, SizeOf(TITSFHeaderSuffix));
  Stream.Write(HeaderSection0, SizeOf(TITSPHeaderPrefix));

end;

procedure TChmWriter.CreateDirectoryListings;
type
  TFirstListEntry = record
    Entry: array[0..511] of byte;
    Size: Integer;
  end;
var
  Buffer: array [0..511] of Byte;
  IndexBlock: TPMGIDirectoryChunk;
  ListingBlock: TDirectoryChunk;
  I: Integer;
  Size: Integer;
  FESize: Integer;
  FileName: String;
  FileNameSize: Integer;
  LastListIndex: Integer;
  FirstListEntry: TFirstListEntry;
  ChunkIndex: Integer;
  ListHeader: TPMGListChunk;
const
  PMGL = 'PMGL';
  PMGI = 'PMGI';
  procedure UpdateLastListChunk;
  var
    Tmp: QWord;
  begin
    if ChunkIndex < 1 then begin
      Exit;
    end;
    Tmp := FDirectoryListings.Position;
    FDirectoryListings.Position := (LastListIndex) * $1000;
    FDirectoryListings.Read(ListHeader, SizeOf(TPMGListChunk));
    FDirectoryListings.Position := (LastListIndex) * $1000;
    ListHeader.NextChunkIndex := NToLE(ChunkIndex);
    FDirectoryListings.Write(ListHeader, SizeOf(TPMGListChunk));
    FDirectoryListings.Position := Tmp;
  end;
  procedure WriteIndexChunk(ShouldFinish: Boolean = False);
  var
    IndexHeader: TPMGIIndexChunk;
    ParentIndex,
    TmpIndex: TPMGIDirectoryChunk;
  begin
    with IndexHeader do begin
      PMGIsig := PMGI;
      UnusedSpace := NToLE(IndexBlock.FreeSpace);
    end;
    IndexBlock.WriteHeader(@IndexHeader);
    IndexBlock.WriteChunkToStream(FDirectoryListings, ChunkIndex, ShouldFinish);
    IndexBlock.Clear;
    if HeaderSection1.IndexOfRootChunk < 0 then HeaderSection1.IndexOfRootChunk := ChunkIndex;
    if ShouldFinish then begin;
      HeaderSection1.IndexTreeDepth := 2;
      ParentIndex := IndexBlock.ParentChunk;
      if ParentIndex <> nil then repeat // the parent index is notified by our child index when to write
        HeaderSection1.IndexOfRootChunk := ChunkIndex;
        TmpIndex := ParentIndex;
        ParentIndex := ParentIndex.ParentChunk;
        TmpIndex.Free;
        Inc(HeaderSection1.IndexTreeDepth);
        Inc(ChunkIndex);
      until ParentIndex = nil;
    end;
    Inc(ChunkIndex);

  end;
  procedure WriteListChunk;
  begin
    with ListHeader do begin
      PMGLsig := PMGL;
      UnusedSpace := NToLE(ListingBlock.FreeSpace);
      Unknown1 :=  0;
      PreviousChunkIndex := NToLE(LastListIndex);
      NextChunkIndex := NToLE(Longint(-1)); // we update this when we write the next chunk
    end;
    if HeaderSection1.FirstPMGLChunkIndex <= 0 then
      HeaderSection1.FirstPMGLChunkIndex := NToLE(ChunkIndex);
    HeaderSection1.LastPMGLChunkIndex := NToLE(ChunkIndex);
    ListingBlock.WriteHeader(@ListHeader);
    ListingBlock.WriteChunkToStream(FDirectoryListings);
    ListingBlock.Clear;
    UpdateLastListChunk;

    LastListIndex := ChunkIndex;
    Inc(ChunkIndex);
    // now add to index
    if not IndexBlock.CanHold(FirstListEntry.Size) then
      WriteIndexChunk;
    IndexBlock.WriteEntry(FirstListEntry.Size, @FirstListEntry.Entry[0])
  end;
begin
  // first sort the listings
  FInternalFiles.Sort;
  HeaderSection1.IndexTreeDepth := 1;
  HeaderSection1.IndexOfRootChunk := -1;
  
  ChunkIndex := 0;

  IndexBlock := TPMGIDirectoryChunk.Create(SizeOf(TPMGIIndexChunk));
  ListingBlock := TDirectoryChunk.Create(SizeOf(TPMGListChunk));

  LastListIndex  := -1;

  // add files to a pmgl block until it is full.
  // after the block is full make a pmgi block and add the first entry of the pmgl block
  // repeat until the index block is full and start another.
  // the pmgi chunks take care of needed parent chunks in the tree
  for I := 0 to FInternalFiles.Count-1 do begin
    Size := 0;
    FileName := FInternalFiles.FileEntry[I].Path + FInternalFiles.FileEntry[I].Name;
    FileNameSize := Length(FileName);
    // filename length
    Inc(Size, WriteCompressedInteger(@Buffer[Size], FileNameSize));
    // filename
    Move(FileName[1], Buffer[Size], FileNameSize);
    Inc(Size, FileNameSize);
    FESize := Size;
    // File is compressed...
    Inc(Size, WriteCompressedInteger(@Buffer[Size], Ord(FInternalFiles.FileEntry[I].Compressed)));
    // Offset from section start
    Inc(Size, WriteCompressedInteger(@Buffer[Size], FInternalFiles.FileEntry[I].DecompressedOffset));
    // Size when uncompressed
    Inc(Size, WriteCompressedInteger(@Buffer[Size], FInternalFiles.FileEntry[I].DecompressedSize));

    if not ListingBlock.CanHold(Size) then
      WriteListChunk;
    
    ListingBlock.WriteEntry(Size, @Buffer[0]);
    
    if ListingBlock.ItemCount = 1 then begin // add the first list item to the index
      Move(Buffer[0], FirstListEntry.Entry[0], FESize);
      FirstListEntry.Size := FESize + WriteCompressedInteger(@FirstListEntry.Entry[FESize], ChunkIndex);
    end;
  end;
  if ListingBlock.ItemCount > 0 then WriteListChunk;

  if ChunkIndex > 1 then begin
    if (IndexBlock.ItemCount > 1)
    or ( (IndexBlock.ItemCount > 0) and (HeaderSection1.IndexOfRootChunk > -1) )
    then WriteIndexChunk(True);
  end;

  HeaderSection1.DirectoryChunkCount := NToLE(DWord(FDirectoryListings.Size div $1000));

  IndexBlock.Free;
  ListingBlock.Free;
  
  //now fix some endian stuff
  HeaderSection1.IndexOfRootChunk := NToLE(HeaderSection1.IndexOfRootChunk);
  HeaderSection1.IndexTreeDepth := NtoLE(HeaderSection1.IndexTreeDepth);
end;

procedure TChmWriter.WriteDirectoryListings(Stream: TStream);
begin
  Stream.Write(HeaderSection1, SizeOf(HeaderSection1));
  FDirectoryListings.Position := 0;
  Stream.CopyFrom(FDirectoryListings, FDirectoryListings.Size);
  FDirectoryListings.Position := 0;
  //TMemoryStream(FDirectoryListings).SaveToFile('dirlistings.pmg');
end;

procedure TChmWriter.WriteSystem;
var
  Entry: TFileEntryRec;
  TmpStr: String;
  TmpTitle: String;
const
  VersionStr = 'HHA Version 4.74.8702'; // does this matter?
begin
  // this creates the /#SYSTEM file
  Entry.Name := '#SYSTEM';
  Entry.Path := '/';
  Entry.Compressed := False;
  Entry.DecompressedOffset := FSection0.Position;
  // EntryCodeOrder: 10 9 4 2 3 16 6 0 1 5
  FSection0.WriteDWord(NToLE(Word(3))); // Version
  if Title <> '' then
    TmpTitle := Title
  else
    TmpTitle := 'default';

  // Code -> Length -> Data
  // 10
  FSection0.WriteWord(NToLE(Word(10)));
  FSection0.WriteWord(NToLE(Word(SizeOf(DWord))));
  FSection0.WriteDWord(NToLE(MilliSecondOfTheDay(Now)));
  // 9
  FSection0.WriteWord(NToLE(Word(9)));
  FSection0.WriteWord(NToLE(Word(SizeOf(VersionStr)+1)));
  FSection0.Write(VersionStr, SizeOf(VersionStr));
  FSection0.WriteByte(0);
  // 4 A struct that is only needed to set if full text search is on.
  FSection0.WriteWord(NToLE(Word(4)));
  FSection0.WriteWord(NToLE(Word(36))); // size
  FSection0.WriteDWord(NToLE(DWord($0409)));
  FSection0.WriteDWord(NToLE(DWord(Ord(FFullTextSearch))));
  FSection0.WriteDWord(0);
  FSection0.WriteDWord(0);
  FSection0.WriteDWord(0);
  // two for a QWord
  FSection0.WriteDWord(0);
  FSection0.WriteDWord(0);
  
  FSection0.WriteDWord(0);
  FSection0.WriteDWord(0);

  

  
  ////////////////////////<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  // 2  default page to load
  if FDefaultPage <> '' then begin
    FSection0.WriteWord(NToLE(Word(2)));
    FSection0.WriteWord(NToLE(Word(Length(FDefaultPage)+1)));
    FSection0.Write(FDefaultPage[1], Length(FDefaultPage));
    FSection0.WriteByte(0);
  end;
  // 3  Title
  if FTitle <> '' then begin
    FSection0.WriteWord(NToLE(Word(3)));
    FSection0.WriteWord(NToLE(Word(Length(FTitle)+1)));
    FSection0.Write(FTitle[1], Length(FTitle));
    FSection0.WriteByte(0);
  end;

  // 16 Default Font
  if FDefaultFont <> '' then begin
    FSection0.WriteWord(NToLE(Word(16)));
    FSection0.WriteWord(NToLE(Word(Length(FDefaultFont)+1)));
    FSection0.Write(FDefaultFont[1], Length(FDefaultFont));
    FSection0.WriteByte(0);
  end;
  
  // 6
  // unneeded. if output file is :  /somepath/OutFile.chm the value here is outfile(lowercase)
  
  // 0 Table of contents filename
  if FHasTOC then begin
    TmpStr := 'default.hhc';
    FSection0.WriteWord(0);
    FSection0.WriteWord(NToLE(Word(Length(TmpStr)+1)));
    FSection0.Write(TmpStr[1], Length(TmpStr));
    FSection0.WriteByte(0);
  end;
  // 1
  // hhk Index
  if FHasIndex then begin
    TmpStr := 'default.hhk';
    FSection0.WriteWord(NToLE(Word(1)));
    FSection0.WriteWord(NToLE(Word(Length(TmpStr)+1)));
    FSection0.Write(TmpStr[1], Length(TmpStr));
    FSection0.WriteByte(0);
  end;
  // 5 Default Window.
  // Not likely needed
  
  Entry.DecompressedSize := FSection0.Position - Entry.DecompressedOffset;
  FInternalFiles.AddEntry(Entry);
end;

procedure TChmWriter.WriteITBITS;
var
  Entry: TFileEntryRec;
begin
  // This is an empty and useless file
  Entry.Name := '#ITBITS';
  Entry.Path := '/';
  Entry.Compressed := False;
  Entry.DecompressedOffset := FSection0.Position;
  Entry.DecompressedSize := 0;
  
  FInternalFiles.AddEntry(Entry);
end;

procedure TChmWriter.WriteSTRINGS;
begin
  if FStringsStream.Size = 0 then;
    FStringsStream.WriteByte(0);
  FStringsStream.Position := 0;
  AddStreamToArchive('#STRINGS', '/', FStringsStream);
end;

procedure TChmWriter.WriteIVB;
begin
  if FContextStream = nil then exit;

  FContextStream.Position := 0;
  // the size of all the entries
  FContextStream.WriteDWord(NToLE(DWord(FContextStream.Size-SizeOf(dword))));
  
  FContextStream.Position := 0;
  AddStreamToArchive('#IVB', '/', FContextStream);
end;

procedure TChmWriter.WriteREADMEFile;
const DISCLAIMER_STR = 'This archive was not made by the MS HTML Help Workshop(r)(tm) program.';
var
  Entry: TFileEntryRec;
begin
  // This procedure puts a file in the archive that says it wasn't compiled with the MS compiler
  Entry.Compressed := False;
  Entry.DecompressedOffset := FSection0.Position;
  FSection0.Write(DISCLAIMER_STR, SizeOf(DISCLAIMER_STR));
  Entry.DecompressedSize := FSection0.Position - Entry.DecompressedOffset;
  Entry.Path := '/';
  Entry.Name := '_#_README_#_'; //try to use a name that won't conflict with normal names
  FInternalFiles.AddEntry(Entry);
end;


procedure TChmWriter.WriteSection0;
begin
  FSection0.Position := 0;
  FOutStream.CopyFrom(FSection0, FSection0.Size);
end;

procedure TChmWriter.WriteSection1;
begin
  WriteContentToStream(FOutStream, FSection1);
end;

procedure TChmWriter.WriteDataSpaceFiles(const AStream: TStream);
var
  Entry: TFileEntryRec;
begin
  // This procedure will write all files starting with ::
  Entry.Compressed := False; // None of these files are compressed

  //  ::DataSpace/NameList
  Entry.DecompressedOffset := FSection0.Position;
  Entry.DecompressedSize := WriteNameListToStream(FSection0, [snUnCompressed,snMSCompressed]);
  Entry.Path := '::DataSpace/';
  Entry.Name := 'NameList';
  FInternalFiles.AddEntry(Entry, False);

  //  ::DataSpace/Storage/MSCompressed/ControlData
  Entry.DecompressedOffset := FSection0.Position;
  Entry.DecompressedSize := WriteControlDataToStream(FSection0, 2, 2, 1);
  Entry.Path := '::DataSpace/Storage/MSCompressed/';
  Entry.Name := 'ControlData';
  FInternalFiles.AddEntry(Entry, False);
  
  //  ::DataSpace/Storage/MSCompressed/SpanInfo
  Entry.DecompressedOffset := FSection0.Position;
  Entry.DecompressedSize := WriteSpanInfoToStream(FSection0, FReadCompressedSize);
  Entry.Path := '::DataSpace/Storage/MSCompressed/';
  Entry.Name := 'SpanInfo';
  FInternalFiles.AddEntry(Entry, False);

  //  ::DataSpace/Storage/MSCompressed/Transform/List
  Entry.DecompressedOffset := FSection0.Position;
  Entry.DecompressedSize := WriteTransformListToStream(FSection0);
  Entry.Path := '::DataSpace/Storage/MSCompressed/Transform/';
  Entry.Name := 'List';
  FInternalFiles.AddEntry(Entry, False);

  //  ::DataSpace/Storage/MSCompressed/Transform/{7FC28940-9D31-11D0-9B27-00A0C91E9C7C}/
  //  ::DataSpace/Storage/MSCompressed/Transform/{7FC28940-9D31-11D0-9B27-00A0C91E9C7C}/InstanceData/ResetTable
  Entry.DecompressedOffset := FSection0.Position;
  Entry.DecompressedSize := WriteResetTableToStream(FSection0, FSection1ResetTable);
  Entry.Path := '::DataSpace/Storage/MSCompressed/Transform/{7FC28940-9D31-11D0-9B27-00A0C91E9C7C}/InstanceData/';
  Entry.Name := 'ResetTable';
  FInternalFiles.AddEntry(Entry, True);


  //  ::DataSpace/Storage/MSCompressed/Content do this last
  Entry.DecompressedOffset := FSection0.Position;
  Entry.DecompressedSize := FSection1Size; // we will write it directly to FOutStream later
  Entry.Path := '::DataSpace/Storage/MSCompressed/';
  Entry.Name := 'Content';
  FInternalFiles.AddEntry(Entry, False);

  
end;

function TChmWriter.AddString(AString: String): LongWord;
begin
  // #STRINGS starts with a null char
  if FStringsStream.Size = 0 then FStringsStream.WriteByte(0);
  // each entry is a null terminated string
  Result := FStringsStream.Position;
  FStringsStream.WriteBuffer(AString[1], Length(AString));
  FStringsStream.WriteByte(0);
end;

function _AtEndOfData(arg: pointer): LongBool; cdecl;
begin
  Result := TChmWriter(arg).AtEndOfData;
end;

function TChmWriter.AtEndOfData: LongBool;
begin
  Result := ForceExit or (FCurrentIndex >= FFileNames.Count-1);
  if Result then
    Result := Integer(FCurrentStream.Position) >= Integer(FCurrentStream.Size)-1;
end;

function _GetData(arg: pointer; Count: LongInt; Buffer: Pointer): LongInt; cdecl;
begin
  Result := TChmWriter(arg).GetData(Count, PByte(Buffer));
end;

function TChmWriter.GetData(Count: LongInt; Buffer: PByte): LongInt;
var
  FileEntry: TFileEntryRec;
begin
  Result := 0;
  while (Result < Count) and (not AtEndOfData) do begin
    Inc(Result, FCurrentStream.Read(Buffer[Result], Count-Result));
    if (Result < Count) and (not AtEndOfData)
    then begin
      // the current file has been read. move to the next file in the list
      FCurrentStream.Position := 0;
      Inc(FCurrentIndex);
      ForceExit := OnGetFileData(FFileNames[FCurrentIndex], FileEntry.Path, FileEntry.Name, FCurrentStream);
      FileEntry.DecompressedSize := FCurrentStream.Size;
      FileEntry.DecompressedOffset := FReadCompressedSize; //269047723;//to test writing really large numbers
      FileEntry.Compressed := True;
      
      FInternalFiles.AddEntry(FileEntry);
      // So the next file knows it's offset
      Inc(FReadCompressedSize,  FileEntry.DecompressedSize);
      FCurrentStream.Position := 0;
    end;

    // this is intended for programs to add perhaps a file
    // after all the other files have been added.
    if (AtEndOfData)
    and (FCurrentStream <> FPostStream) then
    begin
      if Assigned(FOnLastFile) then
        FOnLastFile(Self);
      FCurrentStream.Free;
      FCurrentStream := FPostStream;
      FCurrentStream.Position := 0;
      Inc(FReadCompressedSize, FCurrentStream.Size);
    end;
  end;
end;

function _WriteCompressedData(arg: pointer; Count: LongInt; Buffer: Pointer): LongInt; cdecl;
begin
  Result := TChmWriter(arg).WriteCompressedData(Count, Buffer);
end;

function TChmWriter.WriteCompressedData(Count: Longint; Buffer: Pointer): LongInt;
begin
  // we allocate a MB at a time to limit memory reallocation since this
  // writes usually 2 bytes at a time
  if (FSection1 is TMemoryStream) and (FSection1.Position >= FSection1.Size-1) then begin
    FSection1.Size := FSection1.Size+$100000;
  end;
  Result := FSection1.Write(Buffer^, Count);
  Inc(FSection1Size, Result);
end;

procedure _MarkFrame(arg: pointer; UncompressedTotal, CompressedTotal: LongWord); cdecl;
begin
  TChmWriter(arg).MarkFrame(UncompressedTotal, CompressedTotal);
end;

procedure TChmWriter.MarkFrame(UnCompressedTotal, CompressedTotal: LongWord);
  procedure WriteQWord(Value: QWord);
  begin
    FSection1ResetTable.Write(NToLE(Value), 8);
  end;
  procedure IncEntryCount;
  var
    OldPos: QWord;
    Value: DWord;
  begin
    OldPos := FSection1ResetTable.Position;
    FSection1ResetTable.Position := $4;
    Value := LeToN(FSection1ResetTable.ReadDWord)+1;
    FSection1ResetTable.Position := $4;
    FSection1ResetTable.WriteDWord(NToLE(Value));
    FSection1ResetTable.Position := OldPos;
  end;
  procedure UpdateTotalSizes;
  var
    OldPos: QWord;
  begin
    OldPos := FSection1ResetTable.Position;
    FSection1ResetTable.Position := $10;
    WriteQWord(FReadCompressedSize); // size of read data that has been compressed
    WriteQWord(CompressedTotal);
    FSection1ResetTable.Position := OldPos;
  end;
begin
  if FSection1ResetTable.Size = 0 then begin
    // Write the header
    FSection1ResetTable.WriteDWord(NtoLE(DWord(2)));
    FSection1ResetTable.WriteDWord(0); // number of entries. we will correct this with IncEntryCount
    FSection1ResetTable.WriteDWord(NtoLE(DWord(8))); // Size of Entries (qword)
    FSection1ResetTable.WriteDWord(NtoLE(DWord($28))); // Size of this header
    WriteQWord(0); // Total Uncompressed Size
    WriteQWord(0); // Total Compressed Size
    WriteQWord(NtoLE($8000)); // Block Size
    WriteQWord(0); // First Block start
  end;
  IncEntryCount;
  UpdateTotalSizes;
  WriteQWord(CompressedTotal); // Next Block Start
  // We have to trim the last entry off when we are done because there is no next block in that case
end;

constructor TChmWriter.Create(OutStream: TStream; FreeStreamOnDestroy: Boolean);
begin
  if OutStream = nil then Raise Exception.Create('TChmWriter.OutStream Cannot be nil!');
  FCurrentStream := TMemoryStream.Create;
  FCurrentIndex := -1;
  FOutStream := OutStream;
  FInternalFiles := TFileEntryList.Create;
  FStringsStream := TmemoryStream.Create;
  FSection0 := TMemoryStream.Create;
  FSection1 := TMemoryStream.Create;
  FSection1ResetTable := TMemoryStream.Create;
  FDirectoryListings := TMemoryStream.Create;
  FPostStream := TMemoryStream.Create;;
  FDestroyStream := FreeStreamOnDestroy;
  FFileNames := TStringList.Create;
end;

destructor TChmWriter.Destroy;
begin
  if FDestroyStream then FOutStream.Free;
  if Assigned(FContextStream) then FContextStream.Free;
  FInternalFiles.Free;
  FCurrentStream.Free;
  FStringsStream.Free;
  FSection0.Free;
  FSection1.Free;
  FSection1ResetTable.Free;
  FDirectoryListings.Free;
  FFileNames.Free;
  inherited Destroy;
end;

procedure TChmWriter.Execute;
begin
  InitITSFHeader;
  FOutStream.Position := 0;
  FSection1Size := 0;

  // write any internal files to FCurrentStream that we want in the compressed section
  WriteIVB;
  WriteSTRINGS;
  
  // written to Section0 (uncompressed)
  WriteREADMEFile;
  
  // move back to zero so that we can start reading from zero :)
  FReadCompressedSize := FCurrentStream.Size;
  FCurrentStream.Position := 0;  // when compressing happens, first the FCurrentStream is read
                                 // before loading user files. So we can fill FCurrentStream with
                                 // internal files first.

  // this gathers ALL files that should be in section1 (the compressed section)
  StartCompressingStream;
  FSection1.Size := FSection1Size;

  // This creates and writes the #ITBITS (empty) file to section0
  WriteITBITS;
  // This creates and writes the #SYSTEM file to section0
  WriteSystem;

  //this creates all special files in the archive that start with ::DataSpace
  WriteDataSpaceFiles(FSection0);
  
  // creates all directory listings including header
  CreateDirectoryListings;

  // do this after we have compressed everything so that we know the values that must be written
  InitHeaderSectionTable;

  // Now we can write everything to FOutStream
  WriteHeader(FOutStream);
  WriteDirectoryListings(FOutStream);
  WriteSection0; //does NOT include section 1 even though section0.content IS section1
  WriteSection1; // writes section 1 to FOutStream
end;

procedure TChmWriter.AppendTOC(AStream: TStream);
begin
  FHasTOC := True;
  PostAddStreamToArchive('default.hhc', '/', AStream, True);
end;

procedure TChmWriter.AppendIndex(AStream: TStream);
begin
  FHasIndex := True;
  PostAddStreamToArchive('default.hhk', '/', AStream, True);
end;

procedure TChmWriter.AppendSearchDB(AName: String; AStream: TStream);
begin
  PostAddStreamToArchive(AName, '/', AStream);
end;


// this procedure is used to manually add files to compress to an internal stream that is
// processed before FileToCompress is called. Files added this way should not be
// duplicated in the FilesToCompress property.
procedure TChmWriter.AddStreamToArchive(AFileName, APath: String; AStream: TStream; Compress: Boolean = True);
var
  TargetStream: TStream;
  Entry: TFileEntryRec;
begin
  if AStream = nil then Exit;
  if Compress then
    TargetStream := FCurrentStream
  else
    TargetStream := FSection0;

  Entry.Name := AFileName;
  Entry.Path := APath;
  Entry.Compressed :=  Compress;
  Entry.DecompressedOffset := TargetStream.Position;
  Entry.DecompressedSize := AStream.Size;
  FInternalFiles.AddEntry(Entry);
  AStream.Position := 0;
  TargetStream.CopyFrom(AStream, AStream.Size);
end;

procedure TChmWriter.PostAddStreamToArchive(AFileName, APath: String;
  AStream: TStream; Compress: Boolean);
var
  TargetStream: TStream;
  Entry: TFileEntryRec;
begin
  if AStream = nil then Exit;
  if Compress then
    TargetStream := FPostStream
  else
    TargetStream := FSection0;

  Entry.Name := AFileName;
  Entry.Path := APath;
  Entry.Compressed :=  Compress;
  if not Compress then
    Entry.DecompressedOffset := TargetStream.Position
  else
    Entry.DecompressedOffset := FReadCompressedSize + TargetStream.Position;
  Entry.DecompressedSize := AStream.Size;
  FInternalFiles.AddEntry(Entry);
  AStream.Position := 0;
  TargetStream.CopyFrom(AStream, AStream.Size);
end;

procedure TChmWriter.AddContext(AContext: DWord; ATopic: String);
var
  Offset: DWord;
begin
  if FContextStream = nil then begin
    // #IVB starts with a dword which is the size of the stream - sizeof(dword)
    FContextStream.WriteDWord(0);
    // we will update this when we write the file to the final stream
  end;
  // an entry is a context id and then the offset of the name of the topic in the strings file
  FContextStream.WriteDWord(NToLE(AContext));
  Offset := NToLE(AddString(ATopic));
  FContextStream.WriteDWord(Offset);
end;

procedure TChmWriter.StartCompressingStream;
var
  LZXdata: Plzx_data;
  WSize: LongInt;
begin
  lzx_init(@LZXdata, LZX_WINDOW_SIZE, @_GetData, Self, @_AtEndOfData,
              @_WriteCompressedData, Self, @_MarkFrame, Self);

  WSize := 1 shl LZX_WINDOW_SIZE;
  while not AtEndOfData do begin
    lzx_reset(LZXdata);
    lzx_compress_block(LZXdata, WSize, True);
  end;

  //we have to mark the last frame manually
  MarkFrame(LZXdata^.len_uncompressed_input, LZXdata^.len_compressed_output);

  lzx_finish(LZXdata, nil);
end;

end.
