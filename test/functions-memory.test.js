import test from 'node:test';
import assert from 'node:assert/strict';
import { parse } from '../src/parser.js';
import { compile } from '../src/compiler.js';
import { execute } from '../src/vm.js';

function run(source, options) {
  return execute(compile(parse(source)), options);
}

const header = `IDENTIFICATION DIVISION.
PROGRAM-ID. STEP-THREE.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 N ZAHL WERT 3.
01 PTR ZAHL WERT 0.
01 RESULT ZAHL WERT 0.
PROCEDURE DIVISION.`;

test('functions use call frames and support recursion', () => {
  const result = run(`${header}
FUNKTION COUNTDOWN.
SAG N.
SUBTRAHIERE 1 VON N.
WENN N GROESSER 0 SPRINGE ZU AGAIN.
ZURUECK.
AGAIN:
RUF COUNTDOWN AUF.
ZURUECK.
HAUPTPROGRAMM.
RUF COUNTDOWN AUF.
STOPP.`);

  assert.deepEqual(result.output, ['3', '2', '1']);
  assert.equal(result.variables.N, 0);
  assert.equal(result.halted, true);
});

test('heap cells can be allocated, written, and read', () => {
  const result = run(`${header}
HAUPTPROGRAMM.
RESERVIERE 2 IN PTR.
SCHREIBE 42 NACH SPEICHER PTR.
LIES SPEICHER PTR IN RESULT.
SAG RESULT.
STOPP.`);

  assert.deepEqual(result.output, ['42']);
  assert.deepEqual(result.heap, [42, 0]);
});

test('invalid heap access is rejected', () => {
  assert.throws(() => run(`${header}
HAUPTPROGRAMM.
LIES SPEICHER 9 IN RESULT.
STOPP.`), /Ungültige Speicheradresse/);
});

test('heap limits are enforced', () => {
  assert.throws(() => run(`${header}
HAUPTPROGRAMM.
RESERVIERE 5 IN PTR.
STOPP.`, { maxHeap: 4 }), /Speicherlimit/);
});

test('functions require an explicit main program', () => {
  assert.throws(() => compile(parse(`${header}
FUNKTION TEST.
ZURUECK.`)), /HAUPTPROGRAMM fehlt/);
});
