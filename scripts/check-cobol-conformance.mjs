import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const fixtures = [
  'test/conformance/canonical-core.soeder'
];

function normalizeLine(line) {
  const value = line.trim();
  if (/^[+-]?\d+$/.test(value)) return BigInt(value).toString();
  return value;
}

function normalize(output) {
  return output
    .replace(/\r/g, '')
    .split('\n')
    .map(normalizeLine)
    .filter(Boolean);
}

for (const fixture of fixtures) {
  const absolute = resolve(fixture);
  const source = readFileSync(absolute, 'utf8');

  const v1 = normalize(execFileSync('node', ['src/cli.js', 'run', absolute], {
    encoding: 'utf8'
  }));

  const cobol = normalize(execFileSync('cobol/bin/soeder-v2', [], {
    input: source,
    encoding: 'utf8'
  }));

  if (JSON.stringify(v1) !== JSON.stringify(cobol)) {
    throw new Error(`Conformance mismatch for ${fixture}\nv1: ${JSON.stringify(v1)}\nCOBOL: ${JSON.stringify(cobol)}`);
  }

  console.log(`conformance ok: ${fixture}`);
}
