# SöderLang

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)
[![GnuCOBOL](https://img.shields.io/badge/core-GnuCOBOL-005CA5.svg)](cobol/)
[![Node](https://img.shields.io/badge/node-%3E%3D20-green.svg)](package.json)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

**SöderLang 2.0.0** is a COBOL-inspired, Turing-complete satirical programming language whose source reads like exaggerated fictional political speech associated with Markus Söder.

The portable language core is implemented in **GnuCOBOL** and supports variables, text and numbers, assignment, arithmetic, output, labels, jumps, comparisons, loops, functions, nested calls, recursion, heap allocation, checked memory access, and bounded execution. All 100 fictional speech aliases are normalized through one canonical registry before execution.

The repository also retains the JavaScript implementation as a compatibility runtime for the optional browser DOM and backend HTTP host-operation profiles.

> **Satire notice:** This project is fictional political satire. It is not affiliated with or endorsed by Markus Söder, the Bavarian State Government, the CSU, Bündnis 90/Die Grünen, or any broadcaster. All speech aliases are invented parody constructs, not authentic quotations.

## Features

- Turing-complete GnuCOBOL core
- Numeric and text variables
- Assignment and arithmetic
- Output, labels, conditions, jumps, and loops
- Functions, nested calls, and recursion
- Heap allocation, reads, and writes
- Runtime safeguards for instructions, call depth, and memory
- 100 functional fictional parody aliases
- JSON execution API backed by the real GnuCOBOL runtime
- React and TypeScript browser interface
- Docker and Docker Compose deployment
- Shared JavaScript/GnuCOBOL conformance checks
- Dedicated compiler, runtime, alias, frontend, container, and live API tests

## Quick start with Docker

The simplest way to run SöderLang v2 is:

```bash
docker compose up --build
```

Open:

```text
http://localhost:8080
```

The deployed API exposes:

```text
GET  /api/health
POST /api/execute
```

Example execution request:

```bash
curl -X POST \
  -H 'Content-Type: application/json' \
  --data '{"source":"SAG 42.\nSTOPP.\n"}' \
  http://localhost:8080/api/execute
```

## Local GnuCOBOL runtime

Requirements:

- GnuCOBOL
- GNU Make
- Node.js 20 or newer for alias normalization and supporting tooling

Build and test:

```bash
make -C cobol test
```

Run source through the v2 launcher:

```bash
chmod +x cobol/bin/soeder-v2
printf 'SAG 42.\nSTOPP.\n' | cobol/bin/soeder-v2
```

Run the shared conformance gate:

```bash
npm install
npm run conformance:cobol
```

## Language example

```text
IDENTIFICATION DIVISION.
PROGRAM-ID. BAYERISCHE-REDE.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 LIKES ZAHL WERT 0.
01 ADDRESS ZAHL WERT 0.
01 RESULT ZAHL WERT 0.

PROCEDURE DIVISION.
FUNKTION ERHOEHE.
ADDIERE 1 ZU LIKES.
ZURUECK.

HAUPTPROGRAMM.
LOOP:
RUF ERHOEHE AUF.
WENN LIKES KLEINER 5 SPRINGE ZU LOOP.
RESERVIERE 1 IN ADDRESS.
SCHREIBE LIKES NACH SPEICHER ADDRESS.
LIES SPEICHER ADDRESS IN RESULT.
SAG RESULT.
STOPP.
```

Aliases can replace canonical instructions. For example:

```text
FOODBLOGGER URTEIL RESULT.
HANDY AUS ESSEN KOMMT.
```

## Runtime limits

The GnuCOBOL core enforces bounded execution:

- Maximum instructions: `100,000`
- Maximum call depth: `100`
- Maximum heap cells: `10,000`

Invalid variables, labels, functions, types, memory addresses, allocations, returns, and division by zero produce runtime errors rather than unchecked behavior.

## Architecture

```text
.soeder source
    |
    v
canonical alias and header normalization
    |
    v
GnuCOBOL interpreter
    |
    +--> CLI output
    |
    +--> CGI JSON transport --> React/TypeScript interface
```

The transport layer does not implement the language. Program execution remains owned by `cobol/bin/soeder-core`.

## JavaScript compatibility runtime

The original JavaScript tokenizer, parser, compiler, VM, CLI, playground, browser DOM profile, and backend HTTP profile remain available.

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

The JavaScript runtime remains authoritative specifically for browser DOM and backend HTTP host-operation instructions. The portable computational language core is available through GnuCOBOL.

## Testing

The CI pipeline verifies:

- JavaScript tests and examples
- GnuCOBOL compilation
- variables, arithmetic, conditions, jumps, and loops
- functions, nested calls, and recursion
- heap allocation and checked memory access
- all canonical aliases
- JavaScript/GnuCOBOL core conformance
- React and TypeScript production build
- production Docker image build
- live `/api/health` and `/api/execute` container requests

## Documentation

- [`SPEC.md`](SPEC.md) — language and VM specification
- [`docs/MEME-ALIASES.md`](docs/MEME-ALIASES.md) — canonical alias profile
- [`docs/TURING-COMPLETENESS.md`](docs/TURING-COMPLETENESS.md) — computational construction
- [`docs/WEB-PROFILES.md`](docs/WEB-PROFILES.md) — browser and backend host profiles
- [`docs/COBOL-V2-ARCHITECTURE.md`](docs/COBOL-V2-ARCHITECTURE.md) — GnuCOBOL architecture
- [`SECURITY.md`](SECURITY.md) — security model and vulnerability reporting
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — contribution workflow
- [`CHANGELOG.md`](CHANGELOG.md) — release history

## Release status

**Version 2.0.0 is the stable release of the portable SöderLang core.**

Browser DOM and backend HTTP host profiles remain optional JavaScript compatibility integrations and do not affect completion of the portable language core.

## License

MIT. See [`LICENSE`](LICENSE).
