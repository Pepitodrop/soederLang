# SöderLang v2 — COBOL-first architecture

## Goal

SöderLang v2 makes GnuCOBOL the authoritative implementation language for the language runtime.

- Lexer: GnuCOBOL
- Parser: GnuCOBOL
- AST model: COBOL copybooks and tables
- Bytecode compiler: GnuCOBOL
- Virtual machine: GnuCOBOL
- REST/JSON backend: GnuCOBOL CGI service
- Browser client: React + TypeScript only

The browser client is not allowed to parse, compile, or execute SöderLang. It sends source code to the COBOL API and renders the JSON response.

## Runtime topology

```text
React + TypeScript
        |
        | POST /api/execute { "source": "..." }
        v
nginx / CGI gateway
        |
        v
soeder-api.cob
        |
        +--> lexer.cob
        +--> parser.cob
        +--> compiler.cob
        +--> vm.cob
        |
        v
JSON response
```

## Current merged foundation

The first runnable vertical slice provides:

- a GnuCOBOL CLI runtime supporting `SAG` and `STOPP`;
- `GET /api/health` routing in the COBOL CGI program;
- `POST /api/execute` accepting JSON and returning JSON output;
- a React/TypeScript playground that delegates execution to the COBOL API;
- CI that compiles and tests the COBOL runtime and builds the frontend;
- pinned frontend dependency versions.

This foundation is intentionally not yet feature-compatible with SöderLang v1.1.0. The stable JavaScript implementation remains available while the COBOL implementation grows incrementally.

## Migration policy

A v2 release is allowed only after:

1. the COBOL implementation passes the shared language conformance suite;
2. the React client has no direct dependency on the JavaScript parser/compiler/VM;
3. all execution endpoints are served by GnuCOBOL;
4. the supported v1 syntax subset is documented precisely;
5. containerized local development works with one command.

## Delivery phases

### Phase 1 — vertical slice

- health endpoint
- JSON execute endpoint
- COBOL lexer/parser/compiler/VM foundation
- initial `SAG` and `STOPP` execution
- React/TypeScript playground calling the COBOL API

### Phase 2 — language fundamentals

- `SETZE`
- integer arithmetic
- text values
- structured lexer, parser, AST and bytecode tables
- shared conformance fixtures

### Phase 3 — control flow and advanced runtime

- labels and jumps
- comparisons, conditionals and loops
- functions and recursion
- heap allocation/read/write
- runtime limits and structured diagnostics

### Phase 4 — web profiles

- browser host operations exposed through explicit API commands
- backend route declarations compiled by the COBOL core
- conformance parity with the stable v1 specification
- containerized deployment

## Main-focus rule

COBOL must remain the largest and most important implementation layer. TypeScript is restricted to presentation, HTTP calls, editor state, and rendering.
