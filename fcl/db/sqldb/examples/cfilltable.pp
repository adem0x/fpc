(******************************************************************************
 *                                                                            *
 *  (c) 2005 CNOC v.o.f.                                                      *
 *                                                                            *
 *  File:        cFillTable.pp                                                *
 *  Author:      Joost van der Sluis (joost@cnoc.nl)                          *
 *  Description: SQLDB example and test program                               *
 *  License:     GPL                                                          *
 *                                                                            *
 ******************************************************************************)

program CFillTable;

{$mode objfpc}{$H+}

uses
  Classes,
  sqldb, pqconnection, mysql4conn, IBConnection,
  SqldbExampleUnit;

begin
  ReadIniFile;

  CreateFConnection;
  CreateFTransaction;

// create FQuery
  Fquery := TSQLQuery.create(nil);
  with Fquery do
    begin
    database := Fconnection;
    transaction := Ftransaction;
    end;

  with Fquery do
    begin

    SQL.Clear;
    SQL.Add('insert into FPDEV (       ');
    SQL.Add('  id,                        ');
    SQL.Add('  Name,                      ');
    SQL.Add('  Email,                     ');
    SQL.Add('  Birthdate)                 ');
    SQL.Add('values (                     ');
    SQL.Add('  1,                         ');
    SQL.Add('  ''Florian Klaempfl'',      ');
    SQL.Add('  ''florian@freepascal.org'',');
    SQL.Add('  ''1-1-1975''               ');
    SQL.Add(');                           ');

    ExecSql;

    end;
  Ftransaction.CommitRetaining;

  Fquery.Free;
  Ftransaction.Free;
  Fconnection.Free;
end.

