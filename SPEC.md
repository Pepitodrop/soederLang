# SöderLang Language Specification

Status: draft 0.4

## Design

SöderLang is a fictional political-satire programming language. Its high-level source is intentionally verbose and borrows structural ideas from COBOL while targeting a portable virtual machine. It is not affiliated with Markus Söder, the CSU, or the Bavarian State Government.

## File format

UTF-8 source files use the `.soeder` extension. Keywords are case-insensitive. Statements end in a period. `*>` begins a line comment.

## Program structure

```text
IDENTIFICATION DIVISION.
PROGRAM-ID. NAME.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 VARIABLE ZAHL WERT 42.
PROCEDURE DIVISION.
SAG VARIABLE.
STOPP.
```

The divisions are inspired by COBOL but are not source-compatible with COBOL.

## Data and assignment

- `01 NAME ZAHL WERT n.` declares a number.
- `01 NAME TEXT WERT "text".` declares text.
- `SETZE NAME AUF value.` assigns a literal or another variable.

## Arithmetic

- `ADDIERE value ZU NAME.`
- `SUBTRAHIERE value VON NAME.`
- `MULTIPLIZIERE value MIT NAME.`
- `DIVIDIERE value DURCH NAME.`

Each statement updates `NAME`. Division by zero is a runtime error.

## Output and control flow

- `SAG expression.` emits a value.
- `STOPP.` terminates execution.
- `LABEL:` declares a jump target.
- `SPRINGE ZU LABEL.` performs an unconditional jump.
- `WENN VARIABLE GLEICH|UNGLEICH|KLEINER|GROESSER value SPRINGE ZU LABEL.` performs a conditional jump.

Variables and labels are validated before execution.

## Functions

Functions are declared before an explicit main-program marker:

```text
FUNKTION NAME.
  *> function body
  ZURUECK.
HAUPTPROGRAMM.
  RUF NAME AUF.
```

`RUF` creates a call frame containing the return instruction pointer. `ZURUECK` removes that frame, enabling nested calls and recursion. Version 0.4 uses program-level variables; scoped parameters and locals are planned extensions.

## Heap memory

- `RESERVIERE size IN ADDRESS-VARIABLE.` allocates zero-filled cells and stores their base address.
- `SCHREIBE value NACH SPEICHER address.` writes one cell.
- `LIES SPEICHER address IN TARGET.` reads one cell.

Addresses and allocation sizes are checked. The runtime applies a configurable heap-cell limit.

## Speech alias normalization

Version 0.4 defines a canonical registry of 73 fictional Söder-style aliases. Each alias maps to an existing canonical keyword before tokenization, so aliases receive exactly the same validation and runtime semantics as ordinary syntax.

Normalization is:

- case-insensitive;
- longest-match-first;
- performed independently on each source line;
- disabled inside double-quoted string literals;
- exposed through the public `normalizeAliases` and `SOEDER_ALIASES` APIs.

Examples:

- `ICH SAGE GANZ KLAR` → `SAG`
- `PACK MAS` → `SETZE`
- `BAYERN BONUS` → `ADDIERE`
- `WENN DAS SO IST` → `WENN`
- `WEITER GEHTS` → `SPRINGE`
- `RUF DEN MINISTER` → `RUF`
- `RESERVIER DEN BIERGARTEN` → `RESERVIERE`
- `FEIERABEND IN BAYERN` → `STOPP`

The complete normative list is in `docs/MEME-ALIASES.md`. All phrases are fictional parody constructs rather than claims of authentic quotations.

## Virtual machine

The compiler emits stack bytecode with `PUSH`, `LOAD`, `STORE`, arithmetic, comparison, `JMP`, `JNZ`, `CALL`, `RET`, `ALLOC`, `HLOAD`, `HSTORE`, `PRINT`, and `HALT`. The VM has separate operand and call stacks, preserves source lines, detects stack underflow, rejects invalid references, handles division by zero, and applies configurable instruction and heap limits.

## Turing completeness

SöderLang can directly simulate a deterministic two-counter Minsky machine using integer variables, increment, decrement, zero testing, labelled jumps, and halt. See `docs/TURING-COMPLETENESS.md` for the finite translation. Runtime limits constrain physical executions but not the abstract language model.

## Planned web profiles

`WEB-FRONTEND DIVISION` will expose sandboxed DOM construction, events, state, and fetch. `WEB-BACKEND DIVISION` will expose HTTP routes, request data, JSON responses, and server modules.
