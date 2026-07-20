# SöderLang Language Specification

Status: draft 0.2

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
- `WENN VARIABLE GLEICH value SPRINGE ZU LABEL.`
- `WENN VARIABLE UNGLEICH value SPRINGE ZU LABEL.`
- `WENN VARIABLE KLEINER value SPRINGE ZU LABEL.`
- `WENN VARIABLE GROESSER value SPRINGE ZU LABEL.`

Variables and labels are validated before execution.

## Virtual machine

The compiler emits stack bytecode with `PUSH`, `LOAD`, `STORE`, arithmetic, comparison, `JMP`, `JNZ`, `PRINT`, and `HALT`. The VM preserves source lines, detects stack underflow, rejects invalid references, handles division by zero, and applies a configurable instruction limit.

The current mutable-variable and control-flow primitives support arbitrary loops. Heap cells and functions will be added before the formal two-counter-machine proof of Turing completeness.

## Planned web profiles

`WEB-FRONTEND DIVISION` will expose sandboxed DOM construction, events, state, and fetch. `WEB-BACKEND DIVISION` will expose HTTP routes, request data, JSON responses, and server modules.

## Satirical speech profile

At least 50 documented Söder-style meme aliases will map to real compiler or runtime operations. They are fictional parody constructs, not claims of authentic quotations.
