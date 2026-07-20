#!/usr/bin/env node
import { readFile } from 'node:fs/promises';
import { parse } from './parser.js';
import { tokenize } from './tokenizer.js';

const [, , command = 'help', filename] = process.argv;

function usage() {
  console.log('SöderLang 0.1.0');
  console.log('  soeder check <file.soeder>');
  console.log('  soeder ast <file.soeder>');
  console.log('  soeder tokens <file.soeder>');
}

try {
  if (command === 'help' || !filename) {
    usage();
    process.exit(command === 'help' ? 0 : 1);
  }
  const source = await readFile(filename, 'utf8');
  if (command === 'check') {
    const program = parse(source);
    console.log(`Jawoll: ${program.name} ist syntaktisch gültig.`);
  } else if (command === 'ast') {
    console.log(JSON.stringify(parse(source), null, 2));
  } else if (command === 'tokens') {
    console.log(JSON.stringify(tokenize(source), null, 2));
  } else {
    usage();
    process.exitCode = 1;
  }
} catch (error) {
  console.error(`SöderLang-Fehler: ${error.message}`);
  process.exitCode = 1;
}
