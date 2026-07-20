# SöderLang Language Specification

Status: draft 0.1

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

The divisions are inspired by COBOL but are not intended to be source-compatible with a COBOL implementation.

## Core statements in version 0.1

- `01 NAME ZAHL WERT n.` declares a numeric variable.
- `01 NAME TEXT WERT "text".` declares a string variable.
- `SAG expression.` emits a value.
- `SETZE NAME AUF value.` assigns a value.
- `ADDIERE n ZU NAME.` mutates a numeric variable.
- `STOPP.` terminates execution.

## Planned computational model

The parser AST will compile into a validated stack/register bytecode. The complete language will provide unbounded integer storage subject to host resources, conditional branches, arbitrary jumps, and loops. Those primitives will permit simulation of a two-counter Minsky machine and establish Turing completeness.

## Planned web profiles

`WEB-FRONTEND DIVISION` will expose sandboxed DOM construction, event binding, state, and fetch capabilities. `WEB-BACKEND DIVISION` will expose HTTP routes, request data, JSON responses, and server-side modules.

## Satirical speech profile

At least 50 documented Söder-style meme aliases will map to real compiler or runtime operations. They will be fictional parody constructs rather than claims of authentic quotations.
