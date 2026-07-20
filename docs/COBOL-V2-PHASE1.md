# COBOL v2 parity — Phase 1

This phase moves the stable core data operations into GnuCOBOL.

Implemented in the COBOL CLI runtime:

- numeric declarations: `01 NAME ZAHL WERT n.`
- text declarations: `01 NAME TEXT WERT "text".`
- assignment: `SETZE NAME AUF value.`
- output: `SAG value.`
- arithmetic: `ADDIERE`, `SUBTRAHIERE`, `MULTIPLIZIERE`, `DIVIDIERE`
- variable lookup and type checking
- division-by-zero, unknown-variable, syntax, and type errors
- `STOPP.` termination

Arithmetic updates the named target variable. `DIVIDIERE value DURCH NAME.` computes `NAME / value`, matching the stable runtime semantics.

The REST execution service remains a deliberately small transport adapter. Full source transport through the shared COBOL compiler/VM is tracked for the following parity phase; no parsing or execution is moved into TypeScript.
