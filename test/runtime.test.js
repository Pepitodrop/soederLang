import test from 'node:test';
import assert from 'node:assert/strict';
import { parse } from '../src/parser.js';
import { compile } from '../src/compiler.js';
import { SoederVM } from '../src/vm.js';

function run(source, options) {
  return new SoederVM(compile(parse(source)), options).run();
}

test('executes arithmetic and output', () => {
  const result = run(`
IDENTIFICATION DIVISION.
PROGRAM-ID. RECHNER.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 ERGEBNIS ZAHL WERT 10.
PROCEDURE DIVISION.
ADDIERE 5 ZU ERGEBNIS.
MULTIPLIZIERE 2 MIT ERGEBNIS.
SAG ERGEBNIS.
STOPP.
`);
  assert.deepEqual(result.output, ['30']);
  assert.equal(result.variables.ERGEBNIS, 30);
  assert.equal(result.halted, true);
});

test('executes conditional loop', () => {
  const result = run(`
IDENTIFICATION DIVISION.
PROGRAM-ID. SCHLEIFE.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 X ZAHL WERT 3.
PROCEDURE DIVISION.
NOCHMAL:
SAG X.
SUBTRAHIERE 1 VON X.
WENN X GROESSER 0 SPRINGE ZU NOCHMAL.
STOPP.
`);
  assert.deepEqual(result.output, ['3', '2', '1']);
  assert.equal(result.variables.X, 0);
});

test('rejects division by zero', () => {
  assert.throws(() => run(`
IDENTIFICATION DIVISION.
PROGRAM-ID. FEHLER.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 X ZAHL WERT 5.
PROCEDURE DIVISION.
DIVIDIERE 0 DURCH X.
STOPP.
`), /Division durch null/);
});

test('stops infinite programs at configured limit', () => {
  assert.throws(() => run(`
IDENTIFICATION DIVISION.
PROGRAM-ID. EWIG.
PROCEDURE DIVISION.
WEITER:
SPRINGE ZU WEITER.
`, { maxSteps: 20 }), /Ausführungslimit/);
});
