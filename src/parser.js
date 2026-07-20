import { tokenize } from './tokenizer.js';

function cleanLine(line) {
  return line.replace(/\*>.*$/, '').trim();
}

function parseValue(raw) {
  const value = raw.trim();
  if (/^-?\d+(?:\.\d+)?$/.test(value)) return { type: 'Literal', value: Number(value) };
  if (/^".*"$/.test(value)) return { type: 'Literal', value: value.slice(1, -1) };
  return { type: 'Identifier', name: value };
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
      const parsed = parseValue(rawValue);
      if (parsed.type !== 'Literal') throw new SyntaxError(`Initialwert muss literal sein in Zeile ${lineNumber}`);
      if (valueType.toUpperCase() === 'ZAHL' && typeof parsed.value !== 'number') throw new SyntaxError(`Ungültige Zahl in Zeile ${lineNumber}`);
      program.data.push({ type: 'VariableDeclaration', name, valueType: valueType.toUpperCase(), value: parsed.value, line: lineNumber });
      continue;
    }

    if (division === 'PROCEDURE') {
      match = line.match(/^([A-Za-z][A-Za-z0-9-]*):$/);
      if (match) { program.body.push({ type: 'LabelStatement', name: match[1], line: lineNumber }); continue; }

      match = line.match(/^SAG\s+(.+)\.$/i);
      if (match) { program.body.push({ type: 'PrintStatement', value: parseValue(match[1]), line: lineNumber }); continue; }

      match = line.match(/^SETZE\s+([A-Za-z][A-Za-z0-9-]*)\s+AUF\s+(.+)\.$/i);
      if (match) { program.body.push({ type: 'SetStatement', name: match[1], value: parseValue(match[2]), line: lineNumber }); continue; }

      match = line.match(/^(ADDIERE|SUBTRAHIERE|MULTIPLIZIERE|DIVIDIERE)\s+(.+)\s+(?:ZU|VON|MIT|DURCH)\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
      if (match) {
        const operation = { ADDIERE: 'ADD', SUBTRAHIERE: 'SUB', MULTIPLIZIERE: 'MUL', DIVIDIERE: 'DIV' }[match[1].toUpperCase()];
        program.body.push({ type: 'ArithmeticStatement', operation, value: parseValue(match[2]), name: match[3], line: lineNumber });
        continue;
      }

      match = line.match(/^SPRINGE\s+ZU\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
      if (match) { program.body.push({ type: 'JumpStatement', target: match[1], line: lineNumber }); continue; }

      match = line.match(/^WENN\s+([A-Za-z][A-Za-z0-9-]*)\s+(GLEICH|UNGLEICH|KLEINER|GROESSER)\s+(.+)\s+SPRINGE\s+ZU\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
      if (match) {
        const comparison = { GLEICH: 'EQ', UNGLEICH: 'NE', KLEINER: 'LT', GROESSER: 'GT' }[match[2].toUpperCase()];
        program.body.push({ type: 'ConditionalJumpStatement', left: { type: 'Identifier', name: match[1] }, comparison, right: parseValue(match[3]), target: match[4], line: lineNumber });
        continue;
      }

      if (/^STOPP\.$/i.test(line)) { program.body.push({ type: 'StopStatement', line: lineNumber }); continue; }
    }

    throw new SyntaxError(`Unbekannte SöderLang-Anweisung in Zeile ${lineNumber}: ${line}`);
  }

  if (!program.name) throw new SyntaxError('PROGRAM-ID fehlt.');
  if (division !== 'PROCEDURE') throw new SyntaxError('PROCEDURE DIVISION fehlt.');
  return program;
}
