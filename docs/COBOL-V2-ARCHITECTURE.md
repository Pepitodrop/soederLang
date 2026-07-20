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

## Migration policy

The existing JavaScript v1 implementation remains stable on `main` and in the v1.1.0 release while v2 is developed on `cobol-core-v2`.

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
- COBOL lexer/parser/compiler/VM modules
- `SAG`, `SETZE`, integer arithmetic, and `STOPP`
- React/TypeScript playground calling the COBOL API

### Phase 2 — control flow

- labels and jumps
- comparisons and conditionals
- loops
- bytecode diagnostics

### Phase 3 — advanced runtime

- functions and recursion
- heap allocation/read/write
- runtime limits
- structured errors with line numbers

### Phase 4 — web profiles

- browser host operations exposed through explicit API commands
- backend route declarations compiled by the COBOL core
- conformance parity with the stable v1 specification

## Main-focus rule

COBOL must remain the largest and most important implementation layer. TypeScript is restricted to presentation, HTTP calls, editor state, and rendering.