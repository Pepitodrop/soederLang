import test from 'node:test';
import assert from 'node:assert/strict';
import { parse, tokenize } from '../src/index.js';

const source = `
IDENTIFICATION DIVISION.
PROGRAM-ID. TEST-PROGRAMM.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 ZAEHLER ZAHL WERT 40.
PROCEDURE DIVISION.
ADDIERE 2 ZU ZAEHLER.
SAG ZAEHLER.
STOPP.
`;

test('tokenizer emits source tokens and EOF', () => {
  const tokens = tokenize(source);
  assert.equal(tokens.at(-1).type, 'EOF');
  assert.ok(tokens.some((token) => token.value === 'TEST-PROGRAMM'));
});

test('parser builds a COBOL-inspired program AST', () => {
  const program = parse(source);
  assert.equal(program.name, 'TEST-PROGRAMM');
  assert.equal(program.data[0].name, 'ZAEHLER');
  assert.deepEqual(program.body.map((node) => node.type), [
    'ArithmeticStatement',
    'PrintStatement',
    'StopStatement'
  ]);
  assert.equal(program.body[0].operation, 'ADD');
});

test('parser rejects unknown instructions', () => {
  assert.throws(() => parse(source.replace('STOPP.', 'FRANKEN FIRST.')), /Unbekannte SöderLang-Anweisung/);
});
