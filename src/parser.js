import { tokenize } from './tokenizer.js';

function cleanLine(line) {
  return line.replace(/\*>.*$/, '').trim();
}

export function parse(source) {
  tokenize(source);
  const lines = source.replace(/\r/g, '').split('\n');
  const program = { type: 'Program', name: null, data: [], body: [] };
  let division = null;

  for (let index = 0; index < lines.length; index += 1) {
    const lineNumber = index + 1;
    const line = cleanLine(lines[index]);
    if (!line) continue;

    if (/^IDENTIFICATION DIVISION\.$/i.test(line)) { division = 'IDENTIFICATION'; continue; }
    if (/^DATA DIVISION\.$/i.test(line)) { division = 'DATA'; continue; }
    if (/^PROCEDURE DIVISION\.$/i.test(line)) { division = 'PROCEDURE'; continue; }

    let match = line.match(/^PROGRAM-ID\.\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
    if (match) { program.name = match[1]; continue; }

    if (/^WORKING-STORAGE SECTION\.$/i.test(line)) continue;

    match = line.match(/^01\s+([A-Za-z][A-Za-z0-9-]*)\s+(ZAHL|TEXT)\s+WERT\s+(.+)\.$/i);
    if (match && division === 'DATA') {
      const [, name, valueType, rawValue] = match;
      const value = valueType.toUpperCase() === 'ZAHL'
        ? Number(rawValue)
        : rawValue.replace(/^"|"$/g, '');
      if (valueType.toUpperCase() === 'ZAHL' && Number.isNaN(value)) {
        throw new SyntaxError(`Ungültige Zahl in Zeile ${lineNumber}`);
      }
      program.data.push({ type: 'VariableDeclaration', name, valueType: valueType.toUpperCase(), value, line: lineNumber });
      continue;
    }

    match = line.match(/^SAG\s+(.+)\.$/i);
    if (match && division === 'PROCEDURE') {
      const expression = match[1];
      program.body.push({
        type: 'PrintStatement',
        value: expression.startsWith('"') ? { type: 'Literal', value: expression.replace(/^"|"$/g, '') } : { type: 'Identifier', name: expression },
        line: lineNumber
      });
      continue;
    }

    match = line.match(/^SETZE\s+([A-Za-z][A-Za-z0-9-]*)\s+AUF\s+(.+)\.$/i);
    if (match && division === 'PROCEDURE') {
      const rawValue = match[2];
      program.body.push({ type: 'SetStatement', name: match[1], value: /^-?\d+(\.\d+)?$/.test(rawValue) ? Number(rawValue) : rawValue.replace(/^"|"$/g, ''), line: lineNumber });
      continue;
    }

    match = line.match(/^ADDIERE\s+(-?\d+(?:\.\d+)?)\s+ZU\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
    if (match && division === 'PROCEDURE') {
      program.body.push({ type: 'AddStatement', amount: Number(match[1]), name: match[2], line: lineNumber });
      continue;
    }

    if (/^STOPP\.$/i.test(line) && division === 'PROCEDURE') {
      program.body.push({ type: 'StopStatement', line: lineNumber });
      continue;
    }

    throw new SyntaxError(`Unbekannte SöderLang-Anweisung in Zeile ${lineNumber}: ${line}`);
  }

  if (!program.name) throw new SyntaxError('PROGRAM-ID fehlt.');
  if (division !== 'PROCEDURE') throw new SyntaxError('PROCEDURE DIVISION fehlt.');
  return program;
}
