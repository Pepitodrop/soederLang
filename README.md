# SöderLang

**SöderLang 1.0** is a COBOL-inspired, Turing-complete programming language whose source reads like exaggerated fictional political speech associated with Markus Söder.

> **Satire notice:** This project is fictional political satire. It is not affiliated with or endorsed by Markus Söder, the Bavarian State Government, the CSU, or any broadcaster. Language constructs are parody, not authentic quotations.

## Features

- tokenizer, parser, AST, bytecode compiler, stack VM, and CLI
- numbers, text, assignment, arithmetic, comparisons, labels, jumps, and loops
- functions, recursion, call frames, heap allocation, reads, and writes
- compile-time validation and bounded runtime safeguards
- 73 functional Söder-style aliases backed by one canonical registry
- browser DOM, events, state, and fetch runtime with explicit host adapters
- backend GET/POST/PUT/PATCH/DELETE routes, named parameters, middleware, request access, JSON/text responses, and body-size limits
- interactive browser playground with console output, AST, bytecode, and rendered preview
- examples, specifications, security policy, tests, CI, and npm release automation

## Install and run

```bash
npm install
npm test
node src/cli.js run examples/meme-speech.soeder
```

CLI commands:

```bash
soeder run file.soeder
soeder compile file.soeder
soeder check file.soeder
soeder ast file.soeder
soeder tokens file.soeder
```

## Playground

```bash
npm run playground
```

Open `http://localhost:4173`. Press **Run** or `Ctrl/Cmd + Enter` to parse and execute the program. The playground exposes output, AST, bytecode, and a sandboxed frontend preview.

## Example

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

## Documentation

- [`SPEC.md`](SPEC.md) — language and VM specification
- [`docs/MEME-ALIASES.md`](docs/MEME-ALIASES.md) — functional speech aliases
- [`docs/TURING-COMPLETENESS.md`](docs/TURING-COMPLETENESS.md) — computational construction
- [`docs/WEB-PROFILES.md`](docs/WEB-PROFILES.md) — browser and backend profiles
- [`SECURITY.md`](SECURITY.md) — security model and reporting
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — contribution workflow
- [`CHANGELOG.md`](CHANGELOG.md) — release history

## Stability

Version 1.0 defines the current core syntax and package exports. Future compatible additions may extend the language. Breaking syntax, bytecode, or public runtime API changes require a new major version.
