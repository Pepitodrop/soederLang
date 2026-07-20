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
- console output and explicit termination
- compile-time variable and label validation
- stack checks, division-by-zero errors, and instruction limits
- CLI, examples, tests, and GitHub Actions

## Run it

```bash
npm install
npm test
node src/cli.js run examples/countdown.soeder
```

## Example

```text
IDENTIFICATION DIVISION.
PROGRAM-ID. BAVARIA-COUNTDOWN.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 ZAEHLER ZAHL WERT 5.
PROCEDURE DIVISION.
RUNDE:
  SAG ZAEHLER.
  SUBTRAHIERE 1 VON ZAEHLER.
  WENN ZAEHLER GROESSER 0 SPRINGE ZU RUNDE.
  SAG "Mia san fertig".
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

Next: functions, heap memory, formal Turing-completeness proof, 50+ functional meme aliases, frontend/browser APIs, backend/HTTP APIs, and a playground.
