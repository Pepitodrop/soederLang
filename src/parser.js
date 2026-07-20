import { tokenize } from './tokenizer.js';
import { normalizeAliases } from './aliases.js';

function cleanLine(line) { return line.replace(/\*>.*$/, '').trim(); }
function parseValue(raw) {
  const value = raw.trim();
  if (/^-?\d+(?:\.\d+)?$/.test(value)) return { type: 'Literal', value: Number(value) };
  if (/^".*"$/.test(value)) return { type: 'Literal', value: value.slice(1, -1) };
  return { type: 'Identifier', name: value };
}

export function parse(source) {
  const normalizedSource = normalizeAliases(source);
  tokenize(normalizedSource);
  const lines = normalizedSource.replace(/\r/g, '').split('\n');
  const program = { type: 'Program', name: null, data: [], body: [], frontend: [], backend: [] };
  let division = null;

  for (let index = 0; index < lines.length; index += 1) {
    const lineNumber = index + 1;
    const line = cleanLine(lines[index]);
    if (!line) continue;

    if (/^IDENTIFICATION DIVISION\.$/i.test(line)) { division = 'IDENTIFICATION'; continue; }
    if (/^DATA DIVISION\.$/i.test(line)) { division = 'DATA'; continue; }
    if (/^PROCEDURE DIVISION\.$/i.test(line)) { division = 'PROCEDURE'; continue; }
    if (/^WEB-FRONTEND DIVISION\.$/i.test(line)) { division = 'FRONTEND'; continue; }
    if (/^WEB-BACKEND DIVISION\.$/i.test(line)) { division = 'BACKEND'; continue; }

    let match = line.match(/^PROGRAM-ID\.\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
    if (match) { program.name = match[1]; continue; }
    if (/^WORKING-STORAGE SECTION\.$/i.test(line)) continue;

    match = line.match(/^01\s+([A-Za-z][A-Za-z0-9-]*)\s+(ZAHL|TEXT)\s+WERT\s+(.+)\.$/i);
    if (match && division === 'DATA') {
      const parsed = parseValue(match[3]);
      if (parsed.type !== 'Literal') throw new SyntaxError(`Initialwert muss literal sein in Zeile ${lineNumber}`);
      if (match[2].toUpperCase() === 'ZAHL' && typeof parsed.value !== 'number') throw new SyntaxError(`Ungültige Zahl in Zeile ${lineNumber}`);
      program.data.push({ type: 'VariableDeclaration', name: match[1], valueType: match[2].toUpperCase(), value: parsed.value, line: lineNumber });
      continue;
    }

    if (division === 'FRONTEND') {
      match = line.match(/^ERSTELLE\s+(.+)\s+ALS\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
      if (match) { program.frontend.push({ type: 'CreateElementStatement', tag: parseValue(match[1]), target: match[2], line: lineNumber }); continue; }
      match = line.match(/^SETZE\s+TEXT\s+VON\s+([A-Za-z][A-Za-z0-9-]*)\s+AUF\s+(.+)\.$/i);
      if (match) { program.frontend.push({ type: 'SetTextStatement', target: match[1], value: parseValue(match[2]), line: lineNumber }); continue; }
      match = line.match(/^SETZE\s+ATTRIBUT\s+(.+)\s+VON\s+([A-Za-z][A-Za-z0-9-]*)\s+AUF\s+(.+)\.$/i);
      if (match) { program.frontend.push({ type: 'SetAttributeStatement', attribute: parseValue(match[1]), target: match[2], value: parseValue(match[3]), line: lineNumber }); continue; }
      match = line.match(/^HAENGE\s+([A-Za-z][A-Za-z0-9-]*)\s+AN\s+(.+)\.$/i);
      if (match) { program.frontend.push({ type: 'AppendElementStatement', target: match[1], parent: parseValue(match[2]), line: lineNumber }); continue; }
      match = line.match(/^BEI\s+(.+)\s+AUF\s+([A-Za-z][A-Za-z0-9-]*)\s+RUF\s+([A-Za-z][A-Za-z0-9-]*)\s+AUF\.$/i);
      if (match) { program.frontend.push({ type: 'BindEventStatement', event: parseValue(match[1]), target: match[2], handler: match[3], line: lineNumber }); continue; }
      match = line.match(/^SPEICHERE\s+(.+)\s+WERT\s+(.+)\.$/i);
      if (match) { program.frontend.push({ type: 'StateWriteStatement', key: parseValue(match[1]), value: parseValue(match[2]), line: lineNumber }); continue; }
      match = line.match(/^LIES\s+ZUSTAND\s+(.+)\s+IN\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
      if (match) { program.frontend.push({ type: 'StateReadStatement', key: parseValue(match[1]), target: match[2], line: lineNumber }); continue; }
      match = line.match(/^HOLE\s+(.+)\s+IN\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
      if (match) { program.frontend.push({ type: 'FetchStatement', url: parseValue(match[1]), target: match[2], line: lineNumber }); continue; }
    }

    if (division === 'BACKEND') {
      match = line.match(/^ROUTE\s+(GET|POST|PUT|DELETE|PATCH)\s+(.+)\s+RUF\s+([A-Za-z][A-Za-z0-9-]*)\s+AUF\.$/i);
      if (match) { program.backend.push({ type: 'RouteStatement', method: match[1].toUpperCase(), path: parseValue(match[2]), handler: match[3], line: lineNumber }); continue; }
      match = line.match(/^ANTWORTE\s+JSON\s+(.+)\.$/i);
      if (match) { program.backend.push({ type: 'JsonResponseStatement', value: parseValue(match[1]), line: lineNumber }); continue; }
      match = line.match(/^ANTWORTE\s+TEXT\s+(.+)\.$/i);
      if (match) { program.backend.push({ type: 'TextResponseStatement', value: parseValue(match[1]), line: lineNumber }); continue; }
      match = line.match(/^STATUS\s+(\d{3})\.$/i);
      if (match) { program.backend.push({ type: 'StatusStatement', status: Number(match[1]), line: lineNumber }); continue; }
      match = line.match(/^LIES\s+ANFRAGE\s+(BODY|PARAMS|QUERY|METHOD|PATH)\s+IN\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
      if (match) { program.backend.push({ type: 'RequestReadStatement', field: match[1].toLowerCase(), target: match[2], line: lineNumber }); continue; }
    }

    if (division === 'PROCEDURE') {
      match = line.match(/^FUNKTION\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
      if (match) { program.body.push({ type: 'FunctionStatement', name: match[1], line: lineNumber }); continue; }
      if (/^HAUPTPROGRAMM\.$/i.test(line)) { program.body.push({ type: 'MainStatement', line: lineNumber }); continue; }
      if (/^ZURUECK\.$/i.test(line)) { program.body.push({ type: 'ReturnStatement', line: lineNumber }); continue; }
      match = line.match(/^RUF\s+([A-Za-z][A-Za-z0-9-]*)\s+AUF\.$/i);
      if (match) { program.body.push({ type: 'CallStatement', target: match[1], line: lineNumber }); continue; }
      match = line.match(/^RESERVIERE\s+(.+)\s+IN\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
      if (match) { program.body.push({ type: 'AllocateStatement', size: parseValue(match[1]), target: match[2], line: lineNumber }); continue; }
      match = line.match(/^SCHREIBE\s+(.+)\s+NACH\s+SPEICHER\s+(.+)\.$/i);
      if (match) { program.body.push({ type: 'HeapWriteStatement', value: parseValue(match[1]), address: parseValue(match[2]), line: lineNumber }); continue; }
      match = line.match(/^LIES\s+SPEICHER\s+(.+)\s+IN\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
      if (match) { program.body.push({ type: 'HeapReadStatement', address: parseValue(match[1]), target: match[2], line: lineNumber }); continue; }
      match = line.match(/^([A-Za-z][A-Za-z0-9-]*):$/);
      if (match) { program.body.push({ type: 'LabelStatement', name: match[1], line: lineNumber }); continue; }
      match = line.match(/^SAG\s+(.+)\.$/i);
      if (match) { program.body.push({ type: 'PrintStatement', value: parseValue(match[1]), line: lineNumber }); continue; }
      match = line.match(/^SETZE\s+([A-Za-z][A-Za-z0-9-]*)\s+AUF\s+(.+)\.$/i);
      if (match) { program.body.push({ type: 'SetStatement', name: match[1], value: parseValue(match[2]), line: lineNumber }); continue; }
      match = line.match(/^(ADDIERE|SUBTRAHIERE|MULTIPLIZIERE|DIVIDIERE)\s+(.+)\s+(?:ZU|VON|MIT|DURCH)\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
      if (match) { program.body.push({ type: 'ArithmeticStatement', operation: { ADDIERE: 'ADD', SUBTRAHIERE: 'SUB', MULTIPLIZIERE: 'MUL', DIVIDIERE: 'DIV' }[match[1].toUpperCase()], value: parseValue(match[2]), name: match[3], line: lineNumber }); continue; }
      match = line.match(/^SPRINGE\s+ZU\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
      if (match) { program.body.push({ type: 'JumpStatement', target: match[1], line: lineNumber }); continue; }
      match = line.match(/^WENN\s+([A-Za-z][A-Za-z0-9-]*)\s+(GLEICH|UNGLEICH|KLEINER|GROESSER)\s+(.+)\s+SPRINGE\s+ZU\s+([A-Za-z][A-Za-z0-9-]*)\.$/i);
      if (match) { program.body.push({ type: 'ConditionalJumpStatement', left: { type: 'Identifier', name: match[1] }, comparison: { GLEICH: 'EQ', UNGLEICH: 'NE', KLEINER: 'LT', GROESSER: 'GT' }[match[2].toUpperCase()], right: parseValue(match[3]), target: match[4], line: lineNumber }); continue; }
      if (/^STOPP\.$/i.test(line)) { program.body.push({ type: 'StopStatement', line: lineNumber }); continue; }
    }

    throw new SyntaxError(`Unbekannte SöderLang-Anweisung in Zeile ${lineNumber}: ${line}`);
  }

  if (!program.name) throw new SyntaxError('PROGRAM-ID fehlt.');
  if (!program.body.length && !program.frontend.length && !program.backend.length) throw new SyntaxError('Mindestens eine ausführbare Division fehlt.');
  return program;
}
