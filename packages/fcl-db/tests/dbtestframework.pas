program dbtestframework;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}

{$APPTYPE CONSOLE}

uses
  SysUtils,
  fpcunit,  testreport, testregistry,
  DigestTestReport,
  toolsunit,
// List of supported database connectors
  sqldbtoolsunit,
  dbftoolsunit,
  bufdatasettoolsunit,
  memdstoolsunit,
  SdfDSToolsUnit,
  tcsdfdata,
// Units wich contain the tests
  TestBasics,
  TestFieldTypes,
  TestDatasources,
  TestDBBasics,
  TestBufDatasetStreams,
  TestSpecificTBufDataset;

var
  FXMLResultsWriter: TXMLResultsWriter;
  FDigestResultsWriter: TDigestResultsWriter;
  testResult: TTestResult;
begin
  InitialiseDBConnector;
  testResult := TTestResult.Create;
  FXMLResultsWriter := TXMLResultsWriter.Create;
  FDigestResultsWriter := TDigestResultsWriter.Create(nil);
  try
    testResult.AddListener(FXMLResultsWriter);
    testResult.AddListener(FDigestResultsWriter);
    FDigestResultsWriter.Comment:=dbtype;
    FDigestResultsWriter.Category:='DB';
    FDigestResultsWriter.RelSrcDir:='fcl-db';
    FXMLResultsWriter.WriteHeader;
//    FdiDBResultsWriter.OpenConnection(dbconnectorname+';'+dbconnectorparams);
    GetTestRegistry.Run(testResult);
    FXMLResultsWriter.WriteResult(testResult);
  finally
    testResult.Free;
    FXMLResultsWriter.Free;
    FDigestResultsWriter.Free;
  end;
  FreeDBConnector;
end.
