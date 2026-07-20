# SöderLang

**SöderLang** is a COBOL-inspired, Turing-complete programming language whose source reads like an exaggerated fictional political speech associated with Markus Söder.

> **Satire notice:** This project is fictional political satire. It is not affiliated with or endorsed by Markus Söder, the Bavarian State Government, the CSU, or any broadcaster. Language constructs are parody, not authentic quotations.

## Current status

The executable core includes:

- COBOL-inspired divisions and `.soeder` files
- tokenizer, parser, AST, and bytecode compiler
- stack-based virtual machine
- numeric and text variables
- assignment, arithmetic, comparisons, labels, jumps, and loops
- functions, call frames, returns, and recursion
- heap allocation plus validated reads and writes
- compile-time variable, label, and function validation
- instruction, stack, division-by-zero, address, and heap safeguards
- a documented two-counter-machine construction establishing Turing completeness
- **73 functional Söder-style speech aliases** backed by one canonical registry
- CLI, examples, tests, and GitHub Actions

## Run it

```bash
npm install
npm test
node src/cli.js run examples/meme-speech.soeder
```

## Speech-style example

```text
IDENTIFICATION DIVISION.
PROGRAM-ID. BAYERISCHE-REDE.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 UMFRAGE ZAHL WERT 0.
PROCEDURE DIVISION.
BAYERN ZUERST.
PACK MAS UMFRAGE AUF 1.
WAHLKAMPF:
  ICH SAGE GANZ KLAR UMFRAGE.
  BAYERN BONUS 1 ZU UMFRAGE.
  WENN DAS SO IST UMFRAGE KLEINER 4 WEITER GEHTS ZU WAHLKAMPF.
  DAS MUSS MAN SAGEN "Mia san fertig".
  FEIERABEND IN BAYERN.
```

This is executable syntax. For example, `ICH SAGE GANZ KLAR` maps to `SAG`, `BAYERN BONUS` maps to `ADDIERE`, and `FEIERABEND IN BAYERN` maps to `STOPP`. Aliases are normalized only outside quoted strings.

## CLI

```bash
soeder run file.soeder
soeder compile file.soeder
soeder check file.soeder
soeder ast file.soeder
soeder tokens file.soeder
```

## Documentation

- [`SPEC.md`](SPEC.md) — language and VM specification
- [`docs/MEME-ALIASES.md`](docs/MEME-ALIASES.md) — all functional speech aliases
- [`docs/TURING-COMPLETENESS.md`](docs/TURING-COMPLETENESS.md) — formal computational construction

Next: frontend/browser APIs, backend/HTTP APIs, a browser playground, packaging, and production hardening.
