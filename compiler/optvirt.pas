{
    Virtual methods optimizations (devirtualization)

    Copyright (c) 2008 by Jonas Maebe

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
unit optvirt;

{$i fpcdefs.inc}

  interface

    uses
      globtype,
      cclasses,
      symtype,symdef,
      wpobase;

    type
       { node in an inheritance tree, contains a link to the parent type (if any) and to all
        child types
      }
      tinheritancetreenode = class
       private
        fdef: tobjectdef;
        fparent: tinheritancetreenode;
        fchilds: tfpobjectlist;
        finstantiated: boolean;

        function getchild(index: longint): tinheritancetreenode;
       public
        constructor create(_parent: tinheritancetreenode; _def: tobjectdef; _instantiated: boolean);
        { destroys both this node and all of its siblings }
        destructor destroy; override;
        function  childcount: longint;
        function  haschilds: boolean;
        property  childs[index: longint]: tinheritancetreenode read getchild;
        property  parent: tinheritancetreenode read fparent;
        property  def: tobjectdef read fdef;
        property  instantiated: boolean read finstantiated write finstantiated;
        { if def is not yet a child of this node, add it. In all cases, return node containing
          this def (either new or existing one
        }
        function  maybeaddchild(_def: tobjectdef; _instantiated: boolean): tinheritancetreenode;
      end;


      tinheritancetreecallback = procedure(node: tinheritancetreenode; arg: pointer) of object;

      tinheritancetree = class
       private
        { just a regular node with parent = nil }
        froots: tinheritancetreenode;

        classrefdefs: tfpobjectlist;

        procedure foreachnodefromroot(root: tinheritancetreenode; proctocall: tinheritancetreecallback; arg: pointer);
        function registerinstantiatedobjectdefrecursive(def: tobjectdef; instantiated: boolean): tinheritancetreenode;
        procedure markvmethods(node: tinheritancetreenode; p: pointer);
        procedure printobjectvmtinfo(node: tinheritancetreenode; arg: pointer);
        procedure setinstantiated(node: tinheritancetreenode; arg: pointer);
       public
        constructor create;
        destructor destroy; override;
        { adds an objectdef (the def itself, and all of its parents that do not yet exist) to
          the tree, and returns the leaf node
        }
        procedure registerinstantiateddef(def: tdef);
        procedure checkforclassrefinheritance(def: tdef);
        procedure foreachnode(proctocall: tinheritancetreecallback; arg: pointer);
        procedure foreachleafnode(proctocall: tinheritancetreecallback; arg: pointer);
        procedure optimizevirtualmethods;
        procedure printvmtinfo;
      end;


      { devirtualisation information for a class }

      tclassdevirtinfo = class(tfphashobject)
       private
        { array (indexed by vmt entry nr) of replacement statically callable method names }
        fstaticmethodnames: tfplist;
        function isstaticvmtentry(vmtindex: longint; out replacementname: pshortstring): boolean;
       public
        constructor create(hashobjectlist:tfphashobjectlist;const n: shortstring);reintroduce;
        destructor destroy; override;

        procedure addstaticmethod(vmtindex: longint; const replacementname: shortstring);
      end;


      { devirtualisation information for all classes in a unit }

      tunitdevirtinfo = class(tfphashobject)
       private
        { hashtable of classes }
        fclasses: tfphashobjectlist;
       public
        constructor create(hashobjectlist:tfphashobjectlist;const n: shortstring);reintroduce;
        destructor destroy; override;

        function addclass(const n: shortstring): tclassdevirtinfo;
        function findclass(const n: shortstring): tclassdevirtinfo;
      end;

      { defvirtualisation information for all units in a program }

      { tprogdevirtinfo }

      tprogdevirtinfo = class(twpodevirtualisationhandler)
       private
        { hashtable of tunitdevirtinfo (which contain tclassdevirtinfo) }
        funits: tfphashobjectlist;

        procedure converttreenode(node: tinheritancetreenode; arg: pointer);
        function addunitifnew(const n: shortstring): tunitdevirtinfo;
        function findunit(const n: shortstring): tunitdevirtinfo;
       public
        constructor create; override;
        destructor destroy; override;

        class function getwpotype: twpotype; override;
        class function generatesinfoforwposwitches: twpoptimizerswitches; override;
        class function performswpoforswitches: twpoptimizerswitches; override;

        { information collection }
        procedure constructfromcompilerstate; override;
        procedure storewpofilesection(writer: twposectionwriterintf); override;

        { infromation providing }
        procedure loadfromwpofilesection(reader: twposectionreaderintf); override;
        function staticnameforvirtualmethod(objdef, procdef: tdef; out staticname: string): boolean; override;

      end;


  implementation

    uses
      cutils,
      fmodule,
      symconst,
      symbase,
      symtable,
      nobj,
      verbose;

    const
      DEVIRT_SECTION_NAME = 'contextinsensitive_devirtualization';

   { *************************** tinheritancetreenode ************************* }
    
    constructor tinheritancetreenode.create(_parent: tinheritancetreenode; _def: tobjectdef; _instantiated: boolean);
      begin
        fparent:=_parent;
        fdef:=_def;
        finstantiated:=_instantiated;
      end;


    destructor tinheritancetreenode.destroy;
      begin
        { fchilds owns its members, so it will free them too }
        fchilds.free;
        inherited destroy;
      end;


    function tinheritancetreenode.childcount: longint;
      begin
        if assigned(fchilds) then
          result:=fchilds.count
        else
          result:=0;
      end;


    function tinheritancetreenode.haschilds: boolean;
      begin
        result:=assigned(fchilds)
      end;


    function tinheritancetreenode.getchild(index: longint): tinheritancetreenode;
      begin
        result:=tinheritancetreenode(fchilds[index]);
      end;


    function tinheritancetreenode.maybeaddchild(_def: tobjectdef; _instantiated: boolean): tinheritancetreenode;
      var
        i: longint;
      begin
        { sanity check }
        if assigned(_def.childof) then 
          begin
            if (_def.childof<>def) then
              internalerror(2008092201);
          end
        else if assigned(fparent) then
          internalerror(2008092202);

        if not assigned(fchilds) then
          fchilds:=tfpobjectlist.create(true);
        { def already a child -> return }
        for i := 0 to fchilds.count-1 do
          if (tinheritancetreenode(fchilds[i]).def=_def) then
            begin
              result:=tinheritancetreenode(fchilds[i]);
              result.finstantiated:=result.finstantiated or _instantiated;
              exit;
            end;
        { not found, add new child }
        result:=tinheritancetreenode.create(self,_def,_instantiated);
        fchilds.add(result);
      end;


    { *************************** tinheritancetree ************************* }

    constructor tinheritancetree.create;
      begin
        froots:=tinheritancetreenode.create(nil,nil,false);
        classrefdefs:=tfpobjectlist.create(false);
      end;


    destructor tinheritancetree.destroy;
      begin
        froots.free;
        classrefdefs.free;
        inherited destroy;
      end;
      

    function tinheritancetree.registerinstantiatedobjectdefrecursive(def: tobjectdef; instantiated: boolean): tinheritancetreenode;
      begin
        if assigned(def.childof) then
          begin
            { recursively add parent, of which we have no info about whether or not it is
              instantiated at this point -> default to false (will be overridden by "true"
              if necessary)
            }
            result:=registerinstantiatedobjectdefrecursive(def.childof,false);
            { and add ourselves to the parent }
            result:=result.maybeaddchild(def,instantiated);
          end
        else
          { add ourselves to the roots }
          result:=froots.maybeaddchild(def,instantiated);
      end;


    procedure tinheritancetree.registerinstantiateddef(def: tdef);
      begin
        { add the def }
        if (def.typ=objectdef) then
          registerinstantiatedobjectdefrecursive(tobjectdef(def),true)
        else if (def.typ=classrefdef) then
          classrefdefs.add(def)
        else
          internalerror(2008092401);
      end;


   procedure tinheritancetree.checkforclassrefinheritance(def: tdef);
     var
       i: longint;
     begin
       if (def.typ=objectdef) then
         begin
           for i:=0 to classrefdefs.count-1 do
             if tobjectdef(def).is_related(tclassrefdef(classrefdefs[i]).pointeddef) then
               begin
                 registerinstantiateddef(def);
                 exit;
               end;
         end;
     end;


   procedure tinheritancetree.setinstantiated(node: tinheritancetreenode; arg: pointer);
      var
        classrefdef: tclassrefdef absolute arg;
      begin
        if not(node.instantiated) then
          begin
            node.instantiated:=true;
            {$IFDEF DEBUG_DEVIRT}
            writeln('Marked ',node.def.typename,' as instantiated because instantiated ',classrefdef.typename);
            {$ENDIF}
          end;
      end;


    procedure tinheritancetree.foreachnodefromroot(root: tinheritancetreenode; proctocall: tinheritancetreecallback; arg: pointer);
        
      procedure process(const node: tinheritancetreenode);
        var
         i: longint;
        begin
          for i:=0 to node.childcount-1 do
            if node.childs[i].haschilds then
              begin
                proctocall(node.childs[i],arg);
                process(node.childs[i])
              end
            else
              proctocall(node.childs[i],arg);
        end;
        
      begin
        process(root);
      end;


    procedure tinheritancetree.foreachnode(proctocall: tinheritancetreecallback; arg: pointer);
      begin
        foreachnodefromroot(froots,proctocall,arg);
      end;


    procedure tinheritancetree.foreachleafnode(proctocall: tinheritancetreecallback; arg: pointer);

      procedure process(const node: tinheritancetreenode);
        var
         i: longint;
        begin
          for i:=0 to node.childcount-1 do
            if node.childs[i].haschilds then
              process(node.childs[i])
            else
              proctocall(node.childs[i],arg);
        end;
        
      begin
        process(froots);
      end;


    procedure tinheritancetree.markvmethods(node: tinheritancetreenode; p: pointer);
      var
        currnode: tinheritancetreenode;
        vmtbuilder: tvmtbuilder;
        pd: tobject;
        i: longint;
        makeallvirtual: boolean;
      begin
        {$IFDEF DEBUG_DEVIRT}
        writeln('processing leaf node ',node.def.typename);
        {$ENDIF}
        { todo: also process interfaces (ImplementedInterfaces) }
        if not assigned(node.def.vmtentries) then
          begin
            vmtbuilder:=tvmtbuilder.create(node.def);
            vmtbuilder.generate_vmt(false);
            vmtbuilder.free;
            { may not have any vmtentries }
            if not assigned(node.def.vmtentries) then
              exit;
          end;
        { process all vmt entries for this class/object }
        for i:=0 to node.def.vmtentries.count-1 do
          begin
            currnode:=node;
            pd:=currnode.def.vmtentries[i];
            { abstract methods cannot be called directly }
            if (po_abstractmethod in tprocdef(pd).procoptions) then
              continue;
            {$IFDEF DEBUG_DEVIRT}
            writeln('  method ',tprocdef(pd).typename);
            {$ENDIF}
            { Now mark all virtual methods static that are the same in parent
              classes as in this instantiated child class (only instantiated
              classes can be leaf nodes, since only instantiated classes were
              added to the tree) as statically callable.
              If a first child does not override a parent method while a
              a second one does, the first will mark it as statically
              callable, but the second will set it to not statically callable.
              In the opposite situation, the first will mark it as not
              statically callable and the second will leave it alone.
            }
            makeallvirtual:=false;
            repeat
              if not assigned(currnode.def.vmtentries) then
                begin
                  vmtbuilder:=tvmtbuilder.create(currnode.def);
                  vmtbuilder.generate_vmt(false);
                  vmtbuilder.free;
                  { may not have any vmtentries }
                  if not assigned(currnode.def.vmtentries) then
                    break;
                end;
              { stop when this method is not yet implemented in a parent }
              if (currnode.def.vmtentries.count<=i) then
                break;
              
              if not assigned(currnode.def.vmcallstaticinfo) then
                currnode.def.vmcallstaticinfo:=allocmem(currnode.def.vmtentries.count*sizeof(tvmcallstatic));
              { same procdef as in all instantiated childs? }
              if (currnode.def.vmcallstaticinfo^[i] in [vmcs_default,vmcs_yes]) then
                begin
                  { methods in uninstantiated classes can be made static if
                    they are the same in all instantiated derived classes
                  }
                  if ((currnode.def.vmtentries[i]=pd) or
                      (not currnode.instantiated and
                       (currnode.def.vmcallstaticinfo^[i]=vmcs_default))) and
                      not makeallvirtual then
                    begin
                      {$IFDEF DEBUG_DEVIRT}
                      writeln('    marking as static for ',currnode.def.typename);
                      {$ENDIF}
                      currnode.def.vmcallstaticinfo^[i]:=vmcs_yes;
                      { this is in case of a non-instantiated parent of an instantiated child:
                        the method declared in the child will always be called here
                      }
                      currnode.def.vmtentries[i]:=pd;
                    end
                  else
                    begin
                      {$IFDEF DEBUG_DEVIRT}
                      writeln('    marking as non-static for ',currnode.def.typename);
                      {$ENDIF}
                      makeallvirtual:=true;
                      currnode.def.vmcallstaticinfo^[i]:=vmcs_no;
                    end;
                  currnode:=currnode.parent;
                end
              else
                begin
                  {$IFDEF DEBUG_DEVIRT}
                  writeln('    not processing parents, already non-static for ',currnode.def.typename);
                  {$ENDIF}
                  { parents are also already set to vmcs_no, so no need to continue }
                  currnode:=nil;
                end;
            until not assigned(currnode) or
                  not assigned(currnode.def);
          end;
      end;


    procedure tinheritancetree.optimizevirtualmethods;
      begin
//        finalisetree;
        foreachleafnode(@markvmethods,nil);
      end;


    procedure tinheritancetree.printobjectvmtinfo(node: tinheritancetreenode; arg: pointer);
      var
        i,
        totaldevirtualised,
        totalvirtual: ptrint;
      begin
        totaldevirtualised:=0;
        totalvirtual:=0;
        writeln(node.def.typename);
        if not assigned(node.def.vmtentries) then
          begin
            writeln('  No virtual methods!');
            exit;
          end;
        for i:=0 to node.def.vmtentries.count-1 do
          if (po_virtualmethod in tabstractprocdef(node.def.vmtentries[i]).procoptions) then
            begin
              inc(totalvirtual);
              if (node.def.vmcallstaticinfo^[i]=vmcs_yes) then
                begin
                  inc(totaldevirtualised);
                  writeln('  Devirtualised: ',tabstractprocdef(node.def.vmtentries[i]).typename);
                end;
            end;
        writeln('Total devirtualised: ',totaldevirtualised,'/',totalvirtual);
        writeln;
      end;


    procedure tinheritancetree.printvmtinfo;
      begin
        foreachnode(@printobjectvmtinfo,nil);
      end;


    { helper routine: decompose a class/procdef combo into a unitname, class name and vmtentry number }

    procedure defsdecompose(objdef: tobjectdef; procdef: tprocdef; out unitname, classname: pshortstring; out vmtentry: longint);
      const
        mainprogname: string[2] = 'P$';
      var
        mainsymtab,
        objparentsymtab: tsymtable;
      begin
        objparentsymtab:=objdef.symtable;
        mainsymtab:=objparentsymtab.defowner.owner;
        { main symtable must be static or global }
        if not(mainsymtab.symtabletype in [staticsymtable,globalsymtable]) then
         internalerror(200204175);
        if (TSymtable(main_module.localsymtable)=mainsymtab) and
            (not main_module.is_unit) then
           { same convention as for mangled names }
          unitname:=@mainprogname
        else
          unitname:=mainsymtab.name;
        classname:=tobjectdef(objparentsymtab.defowner).objname;
        vmtentry:=procdef.extnumber;
        { if it's $ffff, this is not a valid virtual method }
        if (vmtentry=$ffff) then
          internalerror(2008100509);
      end;



   { tclassdevirtinfo }

    constructor tclassdevirtinfo.create(hashobjectlist:tfphashobjectlist;const n: shortstring);
      begin
        inherited create(hashobjectlist,n);
        fstaticmethodnames:=tfplist.create;
      end;

    destructor tclassdevirtinfo.destroy;
      var
        i: longint;
      begin
        for i:=0 to fstaticmethodnames.count-1 do
          if assigned(fstaticmethodnames[i]) then
            freemem(fstaticmethodnames[i]);
        fstaticmethodnames.free;
        inherited destroy;
      end;

    procedure tclassdevirtinfo.addstaticmethod(vmtindex: longint;
      const replacementname: shortstring);
      begin
        if (vmtindex>=fstaticmethodnames.count) then
          fstaticmethodnames.Count:=vmtindex+10;
        fstaticmethodnames[vmtindex]:=stringdup(replacementname);
      end;

    function tclassdevirtinfo.isstaticvmtentry(vmtindex: longint; out
      replacementname: pshortstring): boolean;
      begin
         result:=false;
         if (vmtindex>=fstaticmethodnames.count) then
           exit;

         replacementname:=fstaticmethodnames[vmtindex];
         result:=assigned(replacementname);
      end;

    { tunitdevirtinfo }

    constructor tunitdevirtinfo.create(hashobjectlist:tfphashobjectlist;const n: shortstring);
      begin
        inherited create(hashobjectlist,n);
        fclasses:=tfphashobjectlist.create(true);
      end;

    destructor tunitdevirtinfo.destroy;
      begin
        fclasses.free;
        inherited destroy;
      end;

    function tunitdevirtinfo.addclass(const n: shortstring): tclassdevirtinfo;
      begin
        result:=findclass(n);
        { can't have two classes with the same name in a single unit }
        if assigned(result) then
          internalerror(2008100501);
        result:=tclassdevirtinfo.create(fclasses,n);
      end;

    function tunitdevirtinfo.findclass(const n: shortstring): tclassdevirtinfo;
      begin
        result:=tclassdevirtinfo(fclasses.find(n));
      end;


    { tprogdevirtinfo }

    procedure tprogdevirtinfo.converttreenode(node: tinheritancetreenode; arg: pointer);
      var
        i,
        vmtentry: longint;
        unitid, classid: pshortstring;
        unitdevirtinfo: tunitdevirtinfo;
        classdevirtinfo: tclassdevirtinfo;
        first : boolean;
      begin
        if not assigned(node.def.vmtentries) then
          exit;
        first:=true;
        for i:=0 to node.def.vmtentries.count-1 do
          if (po_virtualmethod in tabstractprocdef(node.def.vmtentries[i]).procoptions) and
             (node.def.vmcallstaticinfo^[i]=vmcs_yes) then
            begin
              if first then
                begin
                  { add necessary entries for the unit and the class }
                  defsdecompose(node.def,tprocdef(node.def.vmtentries[i]),unitid,classid,vmtentry);
                  unitdevirtinfo:=addunitifnew(unitid^);
                  classdevirtinfo:=unitdevirtinfo.addclass(classid^);
                  first:=false;
                end;
              { add info about devirtualised vmt entry }
              classdevirtinfo.addstaticmethod(i,tprocdef(node.def.vmtentries[i]).mangledname);
            end;
      end;

    constructor tprogdevirtinfo.create;
      begin
        inherited create;
      end;

    destructor tprogdevirtinfo.destroy;
      begin
        funits.free;
        inherited destroy;
      end;

    class function tprogdevirtinfo.getwpotype: twpotype;
      begin
        result:=wpo_devirtualization_context_insensitive;
      end;

    class function tprogdevirtinfo.generatesinfoforwposwitches: twpoptimizerswitches;
      begin
        result:=[cs_wpo_devirtualize_calls];
      end;

    class function tprogdevirtinfo.performswpoforswitches: twpoptimizerswitches;
      begin
        result:=[cs_wpo_devirtualize_calls];
      end;


    procedure reset_all_impl_defs;

      procedure reset_used_unit_impl_defs(hp:tmodule);
        var
          pu : tused_unit;
        begin
          pu:=tused_unit(hp.used_units.first);
          while assigned(pu) do
            begin
              if not pu.u.is_reset then
                begin
                  { prevent infinte loop for circular dependencies }
                  pu.u.is_reset:=true;
                  if assigned(pu.u.localsymtable) then
                    begin
                      tstaticsymtable(pu.u.localsymtable).reset_all_defs;
                      reset_used_unit_impl_defs(pu.u);
                    end;
                end;
              pu:=tused_unit(pu.next);
            end;
        end;

      var
        hp2 : tmodule;
      begin
        hp2:=tmodule(loaded_units.first);
        while assigned(hp2) do
          begin
            hp2.is_reset:=false;
            hp2:=tmodule(hp2.next);
          end;
        reset_used_unit_impl_defs(current_module);
      end;


    procedure tprogdevirtinfo.constructfromcompilerstate;
      var
        hp: tmodule;
        i: longint;
        inheritancetree: tinheritancetree;
      begin
         { the compiler already resets all interface defs after every unit
           compilation, but not the implementation defs (because this is only
           done for the purpose of writing debug info, and you can never see
           a type defined in the implementation of one unit in another unit).

           Here, we want to record all classes constructed anywhere in the
           program, also if those class(refdef) types are defined in the
           implementation of a unit. So reset the state of all defs in
           implementation sections before starting the collection process. }
         reset_all_impl_defs;
         { register all instantiated class/object types }
         hp:=tmodule(loaded_units.first);
         while assigned(hp) do
          begin
            if assigned(hp.wpoinfo.createdobjtypes) then
              for i:=0 to hp.wpoinfo.createdobjtypes.count-1 do
                tdef(hp.wpoinfo.createdobjtypes[i]).register_created_object_type;
            hp:=tmodule(hp.next);
          end;
         inheritancetree:=tinheritancetree.create;
{$IFDEF DEBUG_DEVIRT}
         writeln('constructed object/class/classreftypes in ',current_module.realmodulename^);
{$ENDIF}
         for i := 0 to current_module.wpoinfo.createdobjtypes.count-1 do
           begin
             inheritancetree.registerinstantiateddef(tdef(current_module.wpoinfo.createdobjtypes[i]));
{$IFDEF DEBUG_DEVIRT}
             write('  ',tdef(current_module.wpoinfo.createdobjtypes[i]).GetTypeName);
{$ENDIF}
             case tdef(current_module.wpoinfo.createdobjtypes[i]).typ of
               objectdef:
                 case tobjectdef(current_module.wpoinfo.createdobjtypes[i]).objecttype of
                   odt_object:
{$IFDEF DEBUG_DEVIRT}
                     writeln(' (object)')
{$ENDIF}
                     ;
                   odt_class:
{$IFDEF DEBUG_DEVIRT}
                     writeln(' (class)')
{$ENDIF}
                     ;
                   else
                     internalerror(2008092101);
                 end;
               classrefdef:
{$IFDEF DEBUG_DEVIRT}
                 writeln(' (classrefdef)')
{$ENDIF}
                 ;
               else
                 internalerror(2008092102);
             end;
           end;
         { now add all objectdefs derived from the instantiated
           classrefdefs to the tree (as they can, in theory, all
           be instantiated as well)
         }
         hp:=tmodule(loaded_units.first);
         while assigned(hp) do
          begin
            { we cannot just walk over the module's deflist, because a bunch of
              the defs in there don't exist anymore (when destroyed, they're
              removed from their symtable but not from the module's deflist)

              procedure-local (or class-local) class definitions do not (yet) exist
            }
            { globalsymtable (interface), is nil for main program itself }
            if assigned(hp.globalsymtable) then
              for i:=0 to hp.globalsymtable.deflist.count-1 do
                inheritancetree.checkforclassrefinheritance(tdef(hp.globalsymtable.deflist[i]));
            { staticsymtable (implementation) }
            if assigned(hp.localsymtable) then
              for i:=0 to hp.localsymtable.deflist.count-1 do
                inheritancetree.checkforclassrefinheritance(tdef(hp.localsymtable.deflist[i]));
            hp:=tmodule(hp.next);
          end;
         inheritancetree.optimizevirtualmethods;
{$ifdef DEBUG_DEVIRT}
         inheritancetree.printvmtinfo;
{$endif DEBUG_DEVIRT}
         inheritancetree.foreachnode(@converttreenode,nil);
         inheritancetree.free;
      end;

    function tprogdevirtinfo.addunitifnew(const n: shortstring): tunitdevirtinfo;
      begin
        if assigned(funits) then
          result:=findunit(n)
        else
          begin
            funits:=tfphashobjectlist.create;
            result:=nil;
          end;
        if not assigned(result) then
          begin
            result:=tunitdevirtinfo.create(funits,n);
          end;
      end;

    function tprogdevirtinfo.findunit(const n: shortstring): tunitdevirtinfo;
      begin
        result:=tunitdevirtinfo(funits.find(n));
      end;

    procedure tprogdevirtinfo.loadfromwpofilesection(reader: twposectionreaderintf);
      var
        unitid,
        classid,
        vmtentryname: string;
        vmttype: string[15];
        vmtentrynrstr: string[7];
        vmtentry, error: longint;
        unitdevirtinfo: tunitdevirtinfo;
        classdevirtinfo: tclassdevirtinfo;
      begin
        { format:
            unit1^
            class1&
            basevmt
            0
            staticvmtentryforslot0
            5
            staticvmtentryforslot5
            intfvmt1
            0
            staticvmtentryforslot0

            class2&
            basevmt
            1
            staticvmtentryforslot1

            unit2^
            class3&
            ...

            currently, only basevmt is supported (no interfaces yet)
        }
        { could be empty if no classes or so }
        if not reader.sectiongetnextline(unitid) then
          exit;
        repeat
          if (unitid='') or
             (unitid[length(unitid)]<>'^') then
            internalerror(2008100502);
          { cut off the trailing ^ }
          setlength(unitid,length(unitid)-1);
          unitdevirtinfo:=addunitifnew(unitid);
          { now read classes }
          if not reader.sectiongetnextline(classid) then
            internalerror(2008100505);
          repeat
            if (classid='') or
               (classid[length(classid)]<>'&') then
              internalerror(2008100503);
            { cut off the trailing & }
            setlength(classid,length(classid)-1);
            classdevirtinfo:=unitdevirtinfo.addclass(classid);
            if not reader.sectiongetnextline(vmttype) then
              internalerror(2008100506);
            { interface info is not yet supported }
            if (vmttype<>'basevmt') then
              internalerror(2008100507);
            { read all vmt entries for this class }
            while reader.sectiongetnextline(vmtentrynrstr) and
                  (vmtentrynrstr<>'') do
              begin
                val(vmtentrynrstr,vmtentry,error);
                if (error<>0) then
                  internalerror(2008100504);
                if not reader.sectiongetnextline(vmtentryname) or
                   (vmtentryname='') then
                  internalerror(2008100508);
                classdevirtinfo.addstaticmethod(vmtentry,vmtentryname);
              end;
            { end of section -> exit }
            if not(reader.sectiongetnextline(classid)) then
              exit;
          until (classid='') or
                (classid[length(classid)]='^');
          { next unit, or error }
          unitid:=classid;
        until false;
      end;

    procedure tprogdevirtinfo.storewpofilesection(writer: twposectionwriterintf);
      var
        unitcount,
        classcount,
        vmtentrycount: longint;
        unitdevirtinfo: tunitdevirtinfo;
        classdevirtinfo: tclassdevirtinfo;
      begin
        if (funits.count=0) then
          exit;
        writer.startsection(DEVIRT_SECTION_NAME);
        for unitcount:=0 to funits.count-1 do
          begin
            unitdevirtinfo:=tunitdevirtinfo(funits[unitcount]);
            writer.sectionputline(unitdevirtinfo.name+'^');
            for classcount:=0 to unitdevirtinfo.fclasses.count-1 do
              begin
                classdevirtinfo:=tclassdevirtinfo(tunitdevirtinfo(funits[unitcount]).fclasses[classcount]);
                writer.sectionputline(classdevirtinfo.name+'&');
                writer.sectionputline('basevmt');
                for vmtentrycount:=0 to classdevirtinfo.fstaticmethodnames.count-1 do
                  if assigned(classdevirtinfo.fstaticmethodnames[vmtentrycount]) then
                    begin
                      writer.sectionputline(tostr(vmtentrycount));
                      writer.sectionputline(pshortstring(classdevirtinfo.fstaticmethodnames[vmtentrycount])^);
                    end;
                writer.sectionputline('');
              end;
          end;
      end;

    function tprogdevirtinfo.staticnameforvirtualmethod(objdef, procdef: tdef; out staticname: string): boolean;
      var
        unitid,
        classid,
        newname: pshortstring;
        unitdevirtinfo: tunitdevirtinfo;
        classdevirtinfo: tclassdevirtinfo;
        vmtentry: longint;
      begin
         { we don't support classrefs yet, nor interfaces }
         if (objdef.typ<>objectdef) or
            not(tobjectdef(objdef).objecttype in [odt_class,odt_object]) then
           begin
             result:=false;
             exit;
           end;

         { get the component names for the class/procdef combo }
         defsdecompose(tobjectdef(objdef), tprocdef(procdef),unitid,classid,vmtentry);

         { do we have any info for this unit? }
         unitdevirtinfo:=findunit(unitid^);
         result:=false;
         if not assigned(unitdevirtinfo) then
           exit;
         { and for this class? }
         classdevirtinfo:=unitdevirtinfo.findclass(classid^);
         if not assigned(classdevirtinfo) then
           exit;
         { now check whether it can be devirtualised, and if so to what }
         result:=classdevirtinfo.isstaticvmtentry(vmtentry,newname);
         if result then
           staticname:=newname^;
      end;

initialization
  twpoinfomanagerbase.registersectionreader(DEVIRT_SECTION_NAME,tprogdevirtinfo);
end.
