{
    Copyright (c) 2008 by Jonas Maebe

    Whole program optimisation information collection base class

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 ****************************************************************************
}

unit wpobase;

{$i fpcdefs.inc}

interface

uses
  globtype,
  cclasses,
  symtype;

type
  { the types of available whole program optimization }
  twpotype = (wpo_devirtualization_context_insensitive);
const
  wpo2str: array[twpotype] of string[16] = ('devirtualization');

type
  { ************************************************************************* }
  { ******************** General base classes/interfaces ******************** }
  { ************************************************************************* }

  { interface to reading a section from a file with wpo info }
  twposectionreaderintf = interface
    ['{51BE3F89-C9C5-4965-9C83-AE7490C92E3E}']
    function sectiongetnextline(out s: string): boolean;
  end;


  { interface to writing sections to a file with wpoinfo }
  twposectionwriterintf = interface
    ['{C056F0DD-62B1-4612-86C7-2D39944C4437}']
    procedure startsection(const name: string);
    procedure sectionputline(const s: string);
  end;


  { base class for wpo information stores }
  twpocomponentbase = class
   public
    constructor create; reintroduce; virtual;

    { type of whole program optimization information collected/provided by
      this class
    }
    class function getwpotype: twpotype; virtual; abstract;

    { whole program optimizations for which this class generated information }
    class function generatesinfoforwposwitches: twpoptimizerswitches; virtual; abstract;

    { whole program optimizations performed by this class }
    class function performswpoforswitches: twpoptimizerswitches; virtual; abstract;

    { loads the information pertinent to this whole program optimization from
      the current section being processed by reader
    }
    procedure loadfromwpofilesection(reader: twposectionreaderintf); virtual; abstract;

    { stores the information of this component to a file in a format that can
      be loaded again using loadfromwpofilesection()
    }
    procedure storewpofilesection(writer: twposectionwriterintf); virtual; abstract;

    { extracts the informations pertinent to this whole program optimization
      from the current compiler state (loaded units, ...)
    }
    procedure constructfromcompilerstate; virtual; abstract;
  end;

  twpocomponentbaseclass = class of twpocomponentbase;


  { forward declaration of overall wpo info manager class }

  twpoinfomanagerbase = class;

  { ************************************************************************* }
  { ** Information created per unit for use during subsequent compilation *** }
  { ************************************************************************* }

  { base class of information collected per unit. Still needs to be
    generalised for different kinds of wpo information, currently specific
    to devirtualization.
  }

  tunitwpoinfobase = class
   protected
    { created object types }
    fcreatedobjtypes: tfpobjectlist;
   public
    constructor create; reintroduce; virtual;
    destructor destroy; override;

    property createdobjtypes: tfpobjectlist read fcreatedobjtypes;

    procedure addcreatedobjtype(def: tdef);
  end;

  { ************************************************************************* }
  { **** Total information created for use during subsequent compilation **** }
  { ************************************************************************* }

  { class to create a file with wpo information }

  { tavailablewpofilewriter }

  twpofilewriter = class(tobject,twposectionwriterintf)
   private
    { array of class *instances* that wish to be written out to the
      whole program optimization
    }
    fsectioncontents: tfpobjectlist;

    ffilename: tcmdstr;
    foutputfile: text;

   public
    constructor create(const fn: tcmdstr);
    destructor destroy; override;

    procedure writefile;

    { starts a new section with name "name" }
    procedure startsection(const name: string);
    { writes s to the wpo file }
    procedure sectionputline(const s: string);

    procedure registerwpocomponent(component: twpocomponentbase);
  end;

  { ************************************************************************* }
  { ************ Information for use during current compilation ************* }
  { ************************************************************************* }

  { class to read a file with wpo information }
  twpofilereader = class(tobject,twposectionreaderintf)
   private
    ffilename: tcmdstr;
    flinenr: longint;
    finputfile: text;
    fcurline: string;
    fusecurline: boolean;

    { destination for the read information }
    fdest: twpoinfomanagerbase;

    function getnextnoncommentline(out s: string): boolean;
   public

     constructor create(const fn: tcmdstr; dest: twpoinfomanagerbase);
     destructor destroy; override;

     { processes the wpo info in the file }
     procedure processfile;

     { returns next line of the current section in s, and false if no more
       lines in the current section
     }
     function sectiongetnextline(out s: string): boolean;
  end;


  { ************************************************************************* }
  { ******* Specific kinds of whole program optimization components ********* }
  { ************************************************************************* }

  { method devirtualisation }
  twpodevirtualisationhandler = class(twpocomponentbase)
    { checks whether def (a procdef for a virtual method) can be replaced with
      a static call, and if so returns the mangled name in staticname.
    }
    function staticnameforvirtualmethod(objdef, procdef: tdef; out staticname: string): boolean; virtual; abstract;
  end;


  { ************************************************************************* }
  { ************ Collection of all instances of wpo components ************** }
  { ************************************************************************* }

  { class doing all the bookkeeping for everything  }

  twpoinfomanagerbase = class
   private
    { array of classrefs of handler classes for the various kinds of whole
      program optimization that we support
    }
    fsectionhandlers: tfphashlist; static;

    freader: twpofilereader;
    fwriter: twpofilewriter;
   public
    class procedure registersectionreader(const sectionname: string; sectionhandler: twpocomponentbaseclass);
    function gethandlerforsection(const secname: string): twpocomponentbaseclass;

    { instances of the various optimizers/information collectors (for
      information used during this compilation)
    }
    wpoinfouse: array[twpotype] of twpocomponentbase;

    procedure extractwpoinfofromprogram;

    procedure setwpoinputfile(const fn: tcmdstr);
    procedure setwpooutputfile(const fn: tcmdstr);
    procedure parseandcheckwpoinfo;

    { routines accessing the optimizer information }
    { 1) devirtualization at the symbol name level }
    function can_be_devirtualized(objdef, procdef: tdef; out name: shortstring): boolean; virtual; abstract;

    constructor create; reintroduce;
    destructor destroy; override;
  end;


  var
    wpoinfomanager: twpoinfomanagerbase;

implementation

  uses
    globals,
    cutils,
    sysutils,
    symdef,
    verbose;


  { tcreatedwpoinfobase }

  constructor tunitwpoinfobase.create;
    begin
      fcreatedobjtypes:=tfpobjectlist.create(false);
    end;


  destructor tunitwpoinfobase.destroy;
    begin
      fcreatedobjtypes.free;
      fcreatedobjtypes:=nil;
      inherited destroy;
    end;
    
    
  procedure tunitwpoinfobase.addcreatedobjtype(def: tdef);
    begin
      fcreatedobjtypes.add(def);
    end;

  { twpofilereader }

  function twpofilereader.getnextnoncommentline(out s: string):
    boolean;
    begin
      if (fusecurline) then
        begin
          s:=fcurline;
          fusecurline:=false;
          exit;
        end;
      repeat
        readln(finputfile,s);
        if (s='') and
           eof(finputfile) then
          begin
            result:=false;
            exit;
          end;
        inc(flinenr);
      until (s='') or
            (s[1]<>'#');
      result:=true;
    end;

  constructor twpofilereader.create(const fn: tcmdstr; dest: twpoinfomanagerbase);
    begin
      if not FileExists(fn) then
        begin
          message1(wpo_cant_find_file,fn);
          exit;
        end;
      assign(finputfile,fn);
      ffilename:=fn;

      fdest:=dest;
    end;

  destructor twpofilereader.destroy;
    begin
      inherited destroy;
    end;

  procedure twpofilereader.processfile;
    var
      sectionhandler: twpocomponentbaseclass;
      i: longint;
      wpotype: twpotype;
      s,
      sectionname: string;
    begin
      message1(wpo_begin_processing,ffilename);
      reset(finputfile);
      flinenr:=0;
      while getnextnoncommentline(s) do
        begin
          if (s='') then
            continue;
          { format: "% sectionname" }
          if (s[1]<>'%') then
            begin
              message2(wpo_expected_section,tostr(flinenr),s);
              break;
            end;
          for i:=2 to length(s) do
            if (s[i]<>' ') then
              break;
          sectionname:=copy(s,i,255);

          { find handler for section and process }
          sectionhandler:=fdest.gethandlerforsection(sectionname);
          if assigned(sectionhandler) then
            begin
              wpotype:=sectionhandler.getwpotype;
              message2(wpo_found_section,sectionname,wpo2str[wpotype]);
              { do we need this information? }
              if ((sectionhandler.performswpoforswitches * init_settings.dowpoptimizerswitches) <> []) then
                begin
                  { did some other section already generate this type of information? }
                  if assigned(fdest.wpoinfouse[wpotype]) then
                    begin
                      message2(wpo_duplicate_wpotype,wpo2str[wpotype],sectionname);
                      fdest.wpoinfouse[wpotype].free;
                    end;
                  { process the section }
                  fdest.wpoinfouse[wpotype]:=sectionhandler.create;
                  twpocomponentbase(fdest.wpoinfouse[wpotype]).loadfromwpofilesection(self);
                end
              else
                message1(wpo_skipping_unnecessary_section,sectionname);
              break;
            end
          else
            begin
              message1(wpo_no_section_handler,sectionname);
              { skip the current section }
              while sectiongetnextline(s) do
                ;
            end;
        end;
      close(finputfile);
      message1(wpo_end_processing,ffilename);
    end;

  function twpofilereader.sectiongetnextline(out s: string): boolean;
    begin
      result:=getnextnoncommentline(s);
      if not result then
        exit;
      { start of new section? }
      if (s<>'') and
         (s[1]='%') then
        begin
          { keep read line for next call to getnextnoncommentline() }
          fcurline:=s;
          fusecurline:=true;
          result:=false;
        end;
    end;


  { twpocomponentbase }

  constructor twpocomponentbase.create;
    begin
      { do nothing }
    end;

  { twpofilewriter }

  constructor twpofilewriter.create(const fn: tcmdstr);
    begin
      assign(foutputfile,fn);
      ffilename:=fn;
      fsectioncontents:=tfpobjectlist.create(true);
    end;

  destructor twpofilewriter.destroy;
    begin
      fsectioncontents.free;
      inherited destroy;
    end;

  procedure twpofilewriter.writefile;
    var
      i: longint;
    begin
      rewrite(foutputfile);
      for i:=0 to fsectioncontents.count-1 do
        twpocomponentbase(fsectioncontents[i]).storewpofilesection(self);
      close(foutputfile);
    end;

  procedure twpofilewriter.startsection(const name: string);
    begin
      writeln(foutputfile,'% ',name);
    end;

  procedure twpofilewriter.sectionputline(const s: string);
    begin
      writeln(foutputfile,s);
    end;

  procedure twpofilewriter.registerwpocomponent(
    component: twpocomponentbase);
    begin
      fsectioncontents.add(component);
    end;

{ twpoinfomanagerbase }

  class procedure twpoinfomanagerbase.registersectionreader(const sectionname: string; sectionhandler: twpocomponentbaseclass);
    begin
      { avoid having to check all the time whether it's assigned or not }
      if not assigned(fsectionhandlers) then
        fsectionhandlers:=tfphashlist.create;
      fsectionhandlers.add(sectionname,sectionhandler);
    end;


  function twpoinfomanagerbase.gethandlerforsection(const secname: string
      ): twpocomponentbaseclass;
    begin
      result:=twpocomponentbaseclass(fsectionhandlers.find(secname));
    end;

  procedure twpoinfomanagerbase.setwpoinputfile(const fn: tcmdstr);
    begin
      freader:=twpofilereader.create(fn,self);
    end;

  procedure twpoinfomanagerbase.setwpooutputfile(const fn: tcmdstr);
    begin
      fwriter:=twpofilewriter.create(fn);
    end;

  procedure twpoinfomanagerbase.parseandcheckwpoinfo;
    begin
      { error if we don't have to optimize yet have an input feedback file }
      if (init_settings.dowpoptimizerswitches=[]) and
         assigned(freader) then
        begin
          message(wpo_input_without_info_use);
          exit;
        end;

      { error if we have to optimize yet don't have an input feedback file }
      if (init_settings.dowpoptimizerswitches<>[]) and
         not assigned(freader) then
        begin
          message(wpo_no_input_specified);
          exit;
        end;

      { if we have to generate wpo information, check that a file has been
        specified and that we have something to write to it
      }
      if (init_settings.genwpoptimizerswitches<>[]) and
         not assigned(fwriter) then
        begin
          message(wpo_no_output_specified);
          exit;
        end;

      if (init_settings.genwpoptimizerswitches=[]) and
         assigned(fwriter) then
        begin
          message(wpo_output_without_info_gen);
          exit;
        end;

      { now read the input feedback file }
      if assigned(freader) then
        begin
          freader.processfile;
          freader.free;
          freader:=nil;
        end;

      { and for each specified optimization check whether the input feedback
        file contained the necessary information
      }
      if (cs_wpo_devirtualize_calls in init_settings.dowpoptimizerswitches) and
         not assigned(wpoinfouse[wpo_devirtualization_context_insensitive]) then
        begin
          message1(wpo_not_enough_info,wpo2str[wpo_devirtualization_context_insensitive]);
          exit;
        end;

    end;

  procedure twpoinfomanagerbase.extractwpoinfofromprogram;
    var
      i: longint;
      info: twpocomponentbase;
    begin
      { if don't have to write anything, fwriter has not been created }
      if not assigned(fwriter) then
        exit;

      { let all wpo components gather the necessary info from the compiler state }
      for i:=0 to fsectionhandlers.count-1 do
        if (twpocomponentbaseclass(fsectionhandlers[i]).generatesinfoforwposwitches*current_settings.genwpoptimizerswitches)<>[] then
          begin
            info:=twpocomponentbaseclass(fsectionhandlers[i]).create;
            info.constructfromcompilerstate;
            fwriter.registerwpocomponent(info);
          end;
      { and write their info to disk }
      fwriter.writefile;
      fwriter.free;
      fwriter:=nil;
    end;

  constructor twpoinfomanagerbase.create;
    begin
      inherited create;
    end;

  destructor twpoinfomanagerbase.destroy;
    var
      i: twpotype;
    begin
      freader.free;
      freader:=nil;
      fwriter.free;
      fwriter:=nil;
      for i:=low(wpoinfouse) to high(wpoinfouse) do
        if assigned(wpoinfouse[i]) then
          wpoinfouse[i].free;
      inherited destroy;
    end;

finalization
  twpoinfomanagerbase.fsectionhandlers.free;
  twpoinfomanagerbase.fsectionhandlers:=nil;
end.
