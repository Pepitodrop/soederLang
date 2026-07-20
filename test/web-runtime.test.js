import test from 'node:test';
import assert from 'node:assert/strict';
import { parse } from '../src/parser.js';
import { executeBrowser } from '../src/web/browser-runtime.js';
import { createBackend } from '../src/web/backend-runtime.js';

class FakeElement {
  constructor(tag) { this.tag = tag; this.textContent = ''; this.attributes = {}; this.children = []; this.listeners = {}; }
  setAttribute(name, value) { this.attributes[name] = value; }
  appendChild(child) { this.children.push(child); }
  addEventListener(name, handler) { this.listeners[name] = handler; }
}

function fakeDocument() {
  const body = new FakeElement('body');
  return { body, createElement: (tag) => new FakeElement(tag), querySelector: (selector) => selector === 'body' ? body : null };
}

const frontendSource = `
IDENTIFICATION DIVISION.
PROGRAM-ID. WEB-DEMO.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 ANTWORT TEXT WERT "leer".
WEB-FRONTEND DIVISION.
ERSTELLE "button" ALS KNOPF.
SETZE TEXT VON KNOPF AUF "Bayern klicken".
SETZE ATTRIBUT "id" VON KNOPF AUF "bayern-knopf".
HAENGE KNOPF AN "body".
BEI "click" AUF KNOPF RUF KLICK AUF.
SPEICHERE "land" WERT "Bayern".
LIES ZUSTAND "land" IN ANTWORT.
HOLE "/api/status" IN ANTWORT.
`;

test('browser profile manipulates DOM, state, events, and fetch', async () => {
  const document = fakeDocument();
  const calls = [];
  const result = await executeBrowser(parse(frontendSource), {
    document,
    storage: new Map(),
    call: (name) => calls.push(name),
    fetch: async () => ({ headers: { get: () => 'application/json' }, json: async () => ({ ok: true }) })
  });
  const button = result.elements.get('KNOPF');
  assert.equal(button.textContent, 'Bayern klicken');
  assert.equal(button.attributes.id, 'bayern-knopf');
  assert.equal(document.body.children[0], button);
  button.listeners.click({ type: 'click' });
  assert.deepEqual(calls, ['KLICK']);
  assert.deepEqual(result.variables.ANTWORT, { ok: true });
});

const backendSource = `
IDENTIFICATION DIVISION.
PROGRAM-ID. API-DEMO.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 ERGEBNIS TEXT WERT "bereit".
WEB-BACKEND DIVISION.
ROUTE GET "/api/status" RUF STATUS-HANDLER AUF.
ANTWORTE JSON ERGEBNIS.
ROUTE POST "/api/echo" RUF ECHO-HANDLER AUF.
LIES ANFRAGE BODY IN ERGEBNIS.
STATUS 201.
ANTWORTE JSON ERGEBNIS.
`;

test('backend profile invokes handlers and dispatches request data, status, and JSON', async () => {
  const calls = [];
  const backend = createBackend(parse(backendSource), {
    call: async (name, context) => {
      calls.push(name);
      assert.equal(context.route.handler, name);
      assert.ok(context.variables);
    }
  });
  const status = await backend.dispatch({ method: 'GET', path: '/api/status' });
  assert.equal(status.status, 200);
  assert.equal(status.body, '"bereit"');
  const echo = await backend.dispatch({ method: 'POST', path: '/api/echo', body: { mia: 'san mia' } });
  assert.equal(echo.status, 201);
  assert.deepEqual(JSON.parse(echo.body), { mia: 'san mia' });
  assert.deepEqual(calls, ['STATUS-HANDLER', 'ECHO-HANDLER']);
  const missing = await backend.dispatch({ method: 'GET', path: '/missing' });
  assert.equal(missing.status, 404);
});
