import test from 'node:test';
import assert from 'node:assert/strict';
import { parse } from '../src/parser.js';
import { createBackend } from '../src/web/backend-runtime.js';

const source = `
IDENTIFICATION DIVISION.
PROGRAM-ID. API-V1.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 ERGEBNIS TEXT WERT "leer".
WEB-BACKEND DIVISION.
ROUTE GET "/users/:id" RUF USER-HANDLER AUF.
LIES ANFRAGE PARAMS IN ERGEBNIS.
ANTWORTE JSON ERGEBNIS.
`;

test('backend matches named route parameters', async () => {
  const backend = createBackend(parse(source));
  const response = await backend.dispatch({ method: 'GET', path: '/users/luis' });
  assert.equal(response.status, 200);
  assert.deepEqual(JSON.parse(response.body), { id: 'luis' });
});

test('middleware runs in order and can short-circuit', async () => {
  const calls = [];
  const backend = createBackend(parse(source), {
    middleware: [
      async (context, next) => { calls.push('first'); context.variables.ERGEBNIS = 'middleware'; return next(); },
      async () => ({ status: 401, headers: { 'content-type': 'application/json' }, body: '{"error":"unauthorized"}' })
    ],
    call: async () => calls.push('handler')
  });
  const response = await backend.dispatch({ method: 'GET', path: '/users/1' });
  assert.equal(response.status, 401);
  assert.deepEqual(calls, ['first']);
});
