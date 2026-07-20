# SöderLang

[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](CHANGELOG.md)
[![Node](https://img.shields.io/badge/node-%3E%3D20-green.svg)](package.json)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

**SöderLang 1.1.0** is the stable JavaScript-hosted release of a COBOL-inspired, Turing-complete programming language whose source reads like exaggerated fictional political speech associated with Markus Söder. It includes a tokenizer, parser, AST, bytecode compiler, stack virtual machine, CLI, browser runtime, backend HTTP runtime, and interactive playground.

The repository also contains a **COBOL-first v2 core runtime** implemented in GnuCOBOL. It supports variables, text and numbers, assignment, arithmetic, output, labels, jumps, comparisons, loops, functions, nested calls, recursion, heap allocation, checked heap reads and writes, and bounded execution. A thin launcher applies the canonical 100-alias registry and then passes normalized source to GnuCOBOL. A CGI transport exposes the runtime through JSON without implementing language execution itself.

> **Satire notice:** This project is fictional political satire. It is not affiliated with or endorsed by Markus Söder, the Bavarian State Government, the CSU, Bündnis 90/Die Grünen, or any broadcaster. All speech aliases are invented parody constructs, not authentic quotations. Political phrases are exaggerated satire and contain no threats or slurs.

## SöderLang versus implementation languages

GitHub's language chart reports the languages used to implement the repository. Stable v1 is implemented in JavaScript. The v2 core execution engine is implemented in GnuCOBOL; React and TypeScript provide the browser interface, while small shell/CGI components provide process and JSON transport.

## Highlights

- Turing-complete language core with numbers, text, variables, arithmetic, comparisons, labels, jumps, and loops
- Functions, recursion, call frames, heap allocation, reads, writes, and bounded runtime safeguards
- 100 functional fictional speech aliases backed by one canonical registry
- Food-blogger, influencer, social-media, grill, meat, beer-garden, and political parody vocabulary
- Stable v1 browser DOM, events, state, storage, fetch, and backend HTTP profiles
- Interactive browser playground
- GnuCOBOL v2 core with shared conformance checks, JSON API transport, and containerized deployment

## Stable v1 installation

```bash
npm install
npm test
node src/cli.js run examples/meme-speech.soeder
```

## COBOL-first v2

Local requirements:

- GnuCOBOL
- GNU Make
- Node.js, used only by the canonical alias launcher and browser build

Build and test the core runtime:

```bash
make -C cobol test
chmod +x cobol/bin/soeder-v2
printf 'SAG 42.\nSTOPP.\n' | cobol/bin/soeder-v2
```

Run the shared stable-v1/GnuCOBOL conformance gate:

```bash
npm run conformance:cobol
```

### One-command container deployment

```bash
docker compose up --build
```

Open `http://localhost:8080`.

The deployed API exposes:

```text
GET  /api/health
POST /api/execute
```

Example request:

```bash
curl -X POST \
  -H 'Content-Type: application/json' \
  --data '{"source":"SAG 42.\nSTOPP.\n"}' \
  http://localhost:8080/api/execute
```

The production image is compiled and smoke-tested in CI, including a live health request and real GnuCOBOL execution through `/api/execute`.

## Stable v1 CLI

```bash
soeder run file.soeder
soeder compile file.soeder
soeder check file.soeder
soeder ast file.soeder
soeder tokens file.soeder
```

## Example

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

COBOL-first v2 core:
.soeder source -> canonical alias/header normalization -> GnuCOBOL interpreter
React UI -> CGI JSON transport -> GnuCOBOL interpreter
```

Stable v1 remains the complete reference implementation for the browser and backend language profiles. The GnuCOBOL runtime currently targets the portable language core rather than the DOM and HTTP host-operation instructions.

## Documentation

- [`SPEC.md`](SPEC.md) — stable v1 language and VM specification
- [`docs/MEME-ALIASES.md`](docs/MEME-ALIASES.md) — canonical speech-alias profile
- [`docs/TURING-COMPLETENESS.md`](docs/TURING-COMPLETENESS.md) — computational construction
- [`docs/WEB-PROFILES.md`](docs/WEB-PROFILES.md) — stable v1 browser and backend profiles
- [`docs/COBOL-V2-ARCHITECTURE.md`](docs/COBOL-V2-ARCHITECTURE.md) — COBOL-first architecture and migration gates
- [`SECURITY.md`](SECURITY.md) — security model and vulnerability reporting
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — contribution workflow
- [`CHANGELOG.md`](CHANGELOG.md) — release history

## Stability

Version `1.1.0` remains the stable public release. The GnuCOBOL v2 core is feature-compatible with the portable core subset covered by its dedicated tests and shared conformance gate. Stable v1 remains authoritative for browser and backend host profiles until equivalent GnuCOBOL host adapters exist.

## License

MIT. See [`LICENSE`](LICENSE).
