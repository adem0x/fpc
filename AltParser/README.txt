The AltParser branch adds support for multiple parsers (front-ends).

Existing code stays almost untouched, except for the selection of the parser.
A TParser class is added, with virtual methods for alternative parsing.
Additional parser classes inherit from TParser, and register themselves.

The existing codebase should be reused as much as possible.
This means that the separation of the syntax from the semantic should be

Roadmap
=======

2010:

* Parser registration and selection.
The selection will be based on filetypes (extensions).

*Add alternative OPL parser (based on existing p* units).
Clone pmodule functionality (proc_unit...) to the alternative parser.

* Split parser code into syntax and semantic procedures.
Make standard semantic helper procedures (in p*) available to all parsers.
Add further semantic procedures, extracted from the old parser procedures,
move them into a new unit for common use.
The same for all other parts of the language...

2011:

* Add parser(s) for alternative languages (Modula, Oberon?).

* Add parser for C (Objective C?).
