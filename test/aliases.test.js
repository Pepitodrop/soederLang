import test from 'node:test';
import assert from 'node:assert/strict';
import { SOEDER_ALIASES, normalizeAliases } from '../src/aliases.js';
import { parse } from '../src/parser.js';
import { compile } from '../src/compiler.js';
import { execute } from '../src/vm.js';

test('ships exactly one hundred functional aliases', () => {
  assert.equal(SOEDER_ALIASES.length, 100);
  assert.equal(new Set(SOEDER_ALIASES.map(({ alias }) => alias)).size, SOEDER_ALIASES.length);
});

test('does not normalize phrases inside quoted text', () => {
  const source = 'JETZT MAL KLARTEXT "PACK MAS und JETZT IST SCHLUSS".';
  assert.equal(normalizeAliases(source), 'SAG "PACK MAS und JETZT IST SCHLUSS".');
});

test('executes a program written with speech aliases', () => {
  const source = `IDENTIFICATION DIVISION.
PROGRAM-ID. MEME-DEMO.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 ZAHLER ZAHL WERT 0.
PROCEDURE DIVISION.
BAYERN ZUERST.
PACK MAS ZAHLER AUF 1.
RUNDE:
JETZT MAL KLARTEXT ZAHLER.
NOCH EINE SCHIPPE 1 ZU ZAHLER.
SCHAUN MER MAL OB ZAHLER KLEINER 4 AUF GEHTS ZU RUNDE.
JETZT MAL KLARTEXT "JETZT IST SCHLUSS bleibt Text".
JETZT IST SCHLUSS.`;

  const result = execute(compile(parse(source)));
  assert.deepEqual(result.output, ['1', '2', '3', 'JETZT IST SCHLUSS bleibt Text']);
  assert.equal(result.variables.ZAHLER, 4);
});

test('food blogger, influencer, meat, and political parody aliases execute', () => {
  const source = `IDENTIFICATION DIVISION.
PROGRAM-ID. CONTENT-DEMO.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 LIKES ZAHL WERT 0.
PROCEDURE DIVISION.
BAYERN ZUERST.
LINK IN DER BIO LIKES AUF 2.
FOLLOWER BONUS 3 ZU LIKES.
DOPPELTE BRATWURST 2 MIT LIKES.
DIE GRUENEN WIEDER 1 VON LIKES.
FOODBLOGGER URTEIL LIKES.
HANDY AUS ESSEN KOMMT.`;

  const result = execute(compile(parse(source)));
  assert.deepEqual(result.output, ['9']);
  assert.equal(result.variables.LIKES, 9);
});

test('function and heap aliases compile to real operations', () => {
  const source = `IDENTIFICATION DIVISION.
PROGRAM-ID. ALIAS-MEMORY.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 ADRESSE ZAHL WERT 0.
01 WERTUNG ZAHL WERT 0.
PROCEDURE DIVISION.
FUNKTION HELFER.
SCHREIBS INS GRUNDSATZPROGRAMM 42 NACH SPEICHER ADRESSE.
ZURUECK INS STUDIO.
BAYERN ZUERST.
RESERVIER DEN BIERGARTEN 1 IN ADRESSE.
RUF DEN MINISTER HELFER AUF.
LIES DIE AKTE SPEICHER ADRESSE IN WERTUNG.
ICH SAGE GANZ KLAR WERTUNG.
FEIERABEND IN BAYERN.`;

  const result = execute(compile(parse(source)));
  assert.deepEqual(result.output, ['42']);
});
