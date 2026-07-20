# SöderLang Web Profiles

SöderLang 0.5 adds dependency-free frontend and backend execution profiles.

## Frontend

`WEB-FRONTEND DIVISION.` supports:

- `ERSTELLE "tag" ALS NAME.`
- `SETZE TEXT VON NAME AUF value.`
- `SETZE ATTRIBUT "name" VON NAME AUF value.`
- `HAENGE NAME AN "selector".`
- `BEI "event" AUF NAME RUF HANDLER AUF.`
- `SPEICHERE "key" WERT value.`
- `LIES ZUSTAND "key" IN VARIABLE.`
- `HOLE "url" IN VARIABLE.`

`BrowserRuntime` receives explicit `document`, `fetch`, storage, and function-call adapters. This makes DOM and network authority visible and testable rather than relying on ambient globals.

## Backend

`WEB-BACKEND DIVISION.` supports route blocks:

```text
ROUTE POST "/api/echo" RUF ECHO-HANDLER AUF.
LIES ANFRAGE BODY IN ERGEBNIS.
STATUS 201.
ANTWORTE JSON ERGEBNIS.
```

Available statements:

- `ROUTE METHOD "path" RUF HANDLER AUF.`
- `LIES ANFRAGE BODY|PARAMS|QUERY|METHOD|PATH IN VARIABLE.`
- `STATUS code.`
- `ANTWORTE JSON value.`
- `ANTWORTE TEXT value.`

`createBackend(program, { call })` accepts an asynchronous handler adapter. Every matched route invokes its declared handler before the route response statements execute. The adapter receives the request, route metadata, mutable request-local variables, and the runtime instance.

`BackendRuntime.dispatch()` works without opening sockets. `createNodeHandler()` returns a standard Node HTTP request handler and converts uncaught handler, parsing, or dispatch errors into JSON HTTP 500 responses.

## Security model

The browser runtime has no authority unless a host adapter is supplied. The backend runtime performs exact method/path matching, does not evaluate JavaScript, and has no filesystem or process APIs. Production hosts should still apply authentication, request-size limits, origin policy, rate limiting, and schema validation.
