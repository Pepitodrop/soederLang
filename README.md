# SöderLang

[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](CHANGELOG.md)
[![Node](https://img.shields.io/badge/node-%3E%3D20-green.svg)](package.json)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

**SöderLang 1.1.0** is the stable JavaScript-hosted release of a COBOL-inspired, Turing-complete programming language whose source reads like exaggerated fictional political speech associated with Markus Söder. It includes a tokenizer, parser, AST, bytecode compiler, stack virtual machine, CLI, browser runtime, backend HTTP runtime, and interactive playground.

A **COBOL-first v2 foundation** is included in the repository. Its authoritative runtime is written in GnuCOBOL, while React and TypeScript are restricted to the browser interface. The initial v2 vertical slice supports `SAG` and `STOPP`, exposes COBOL-owned health and execution endpoints, and is validated by dedicated CI. It is not yet a replacement for the complete v1.1.0 implementation.

> **Satire notice:** This project is fictional political satire. It is not affiliated with or endorsed by Markus Söder, the Bavarian State Government, the CSU, Bündnis 90/Die Grünen, or any broadcaster. All speech aliases are invented parody constructs, not authentic quotations. Political phrases are exaggerated satire and contain no threats or slurs.

## SöderLang versus implementation languages

GitHub's language chart reports the languages used to implement the repository. The stable v1 compiler and VM are implemented in JavaScript. The v2 migration makes GnuCOBOL the authoritative language for lexer, parser, AST, bytecode compilation, VM execution, and REST/JSON processing. React and TypeScript remain only for presentation and HTTP communication.

## Highlights

- Turing-complete stable v1 language core with numbers, text, variables, arithmetic, comparisons, labels, jumps, and loops
- Functions, recursion, call frames, heap allocation, reads, writes, and bounded runtime safeguards
- 100 functional fictional speech aliases backed by one canonical registry
- Food-blogger, influencer, social-media, grill, meat, beer-garden, and political parody vocabulary
- Browser DOM, events, state, storage, and fetch runtime through explicit host adapters
- Backend GET/POST/PUT/PATCH/DELETE routes, named route parameters, middleware, request access, JSON/text responses, and body-size limits
- Interactive playground with console output, AST, bytecode, and sandboxed frontend preview
- COBOL-first v2 foundation with a GnuCOBOL CLI, JSON CGI API, React/TypeScript client, and dedicated CI

## Stable v1 installation

```bash
npm install
npm test
node src/cli.js run examples/meme-speech.soeder
```

## COBOL-first v2 foundation

Requirements:

- GnuCOBOL
- GNU Make
- Node.js 22 for the browser client

Build and test the COBOL runtime:

```bash
cd cobol
make test
```

Build the React/TypeScript client:

```bash
cd frontend
npm install
npm run build
```

The first vertical slice accepts:

```text
SAG 42.
STOPP.
```

The COBOL CGI API exposes:

```text
GET  /api/health
POST /api/execute
```

See [`docs/COBOL-V2-ARCHITECTURE.md`](docs/COBOL-V2-ARCHITECTURE.md) for the migration plan and current scope.

## Stable v1 CLI

```bash
soeder run file.soeder
soeder compile file.soeder
soeder check file.soeder
soeder ast file.soeder
soeder tokens file.soeder
```

## Stable v1 example

```text
IDENTIFICATION DIVISION.
PROGRAM-ID. BAYERISCHE-REDE.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 LIKES ZAHL WERT 0.
PROCEDURE DIVISION.
BAYERN ZUERST.
LINK IN DER BIO LIKES AUF 2.
FOLLOWER BONUS 3 ZU LIKES.
DOPPELTE BRATWURST 2 MIT LIKES.
DIE GRUENEN WIEDER 1 VON LIKES.
FOODBLOGGER URTEIL LIKES.
HANDY AUS ESSEN KOMMT.
```

## Architecture

```text
Stable v1:
.soeder source -> JavaScript parser/compiler -> bytecode -> JavaScript VM

COBOL-first v2 migration:
React + TypeScript -> REST/JSON -> GnuCOBOL API -> COBOL lexer/parser/compiler/VM
```

## Documentation

- [`SPEC.md`](SPEC.md) — stable v1 language and VM specification
- [`docs/MEME-ALIASES.md`](docs/MEME-ALIASES.md) — canonical speech-alias profile
- [`docs/TURING-COMPLETENESS.md`](docs/TURING-COMPLETENESS.md) — computational construction
- [`docs/WEB-PROFILES.md`](docs/WEB-PROFILES.md) — stable v1 browser and backend profiles
- [`docs/COBOL-V2-ARCHITECTURE.md`](docs/COBOL-V2-ARCHITECTURE.md) — COBOL-first v2 architecture and migration gates
- [`SECURITY.md`](SECURITY.md) — security model and vulnerability reporting
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — contribution workflow
- [`CHANGELOG.md`](CHANGELOG.md) — release history

## Stability

Version `1.1.0` remains the stable public release. The COBOL-first v2 implementation is an incremental foundation and must not be described as feature-compatible until the shared conformance suite passes.

## License

MIT. See [`LICENSE`](LICENSE).
