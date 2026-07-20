#!/usr/bin/env node
import { readFile } from 'node:fs/promises';
import { parse } from './parser.js';
import { tokenize } from './tokenizer.js';
import { compile } from './compiler.js';
import { SoederVM } from './vm.js';

const [, , command = 'help', filename] = process.argv;

function usage() {
  console.log('SöderLang 0.2.0');
  console.log('  soeder run <file.soeder>');
  console.log('  soeder compile <file.soeder>');
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
    compile(program);
    console.log(`Jawoll: ${program.name} ist syntaktisch und semantisch gültig.`);
  } else if (command === 'ast') {
    console.log(JSON.stringify(parse(source), null, 2));
  } else if (command === 'tokens') {
    console.log(JSON.stringify(tokenize(source), null, 2));
  } else if (command === 'compile') {
    console.log(JSON.stringify(compile(parse(source)), null, 2));
  } else if (command === 'run') {
    const bytecode = compile(parse(source));
    new SoederVM(bytecode, { write: true }).run();
  } else {
    usage();
    process.exitCode = 1;
  }
} catch (error) {
  console.error(`SöderLang-Fehler: ${error.message}`);
  process.exitCode = 1;
}
