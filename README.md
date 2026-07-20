# SöderLang

**SöderLang** is a COBOL-inspired programming language whose source reads like an exaggerated fictional political speech associated with Markus Söder.

> **Satire notice:** This project is fictional political satire. It is not affiliated with or endorsed by Markus Söder, the Bavarian State Government, the CSU, or any broadcaster. Language constructs are parody, not authentic quotations.

## Current status

The executable core now includes:

- COBOL-inspired divisions and `.soeder` files
- tokenizer, parser, AST, and bytecode compiler
- stack-based virtual machine
- numeric and text variables
- assignment, arithmetic, comparisons, labels, jumps, and loops
- functions, call frames, returns, and recursion
- heap allocation plus validated reads and writes
- console output and explicit termination
- compile-time variable, label, and function validation
- stack checks, division-by-zero errors, instruction limits, and heap limits
- a documented two-counter-machine construction establishing Turing completeness
- CLI, examples, tests, and GitHub Actions

## Run it

```bash
npm install
npm test
node src/cli.js run examples/recursion-memory.soeder
```

## Example

```text
IDENTIFICATION DIVISION.
PROGRAM-ID. REKURSIVE-BAYERN-MASCHINE.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 RUNDEN ZAHL WERT 3.
01 ADRESSE ZAHL WERT 0.
01 ERGEBNIS ZAHL WERT 0.
PROCEDURE DIVISION.

FUNKTION RUNTERZAEHLEN.
  SAG RUNDEN.
  SUBTRAHIERE 1 VON RUNDEN.
  WENN RUNDEN GROESSER 0 SPRINGE ZU NOCHMAL.
  ZURUECK.
NOCHMAL:
  RUF RUNTERZAEHLEN AUF.
  ZURUECK.

HAUPTPROGRAMM.
  RUF RUNTERZAEHLEN AUF.
  RESERVIERE 1 IN ADRESSE.
  SCHREIBE 42 NACH SPEICHER ADRESSE.
  LIES SPEICHER ADRESSE IN ERGEBNIS.
  SAG ERGEBNIS.
  STOPP.
```

## CLI

```bash
soeder run file.soeder
soeder compile file.soeder
soeder check file.soeder
soeder ast file.soeder
soeder tokens file.soeder
```

See [`docs/TURING-COMPLETENESS.md`](docs/TURING-COMPLETENESS.md) for the formal construction.

Next: 50+ functional Söder meme aliases, frontend/browser APIs, backend/HTTP APIs, and a playground.
