export function tokenize(source) {
  const tokens = [];
  const lines = source.replace(/\r/g, '').split('\n');
  for (let lineIndex = 0; lineIndex < lines.length; lineIndex += 1) {
    const raw = lines[lineIndex].replace(/\*>.*$/, '').trim();
    if (!raw) continue;
    const parts = raw.match(/"[^"]*"|-?\d+(?:\.\d+)?|[A-Za-zÄÖÜäöüß][A-Za-z0-9ÄÖÜäöüß-]*|[.,():=+*\/<>-]/g);
    if (!parts) throw new SyntaxError(`Ungültige Syntax in Zeile ${lineIndex + 1}`);
    for (const value of parts) {
      let type = 'WORD';
      if (value.startsWith('"')) type = 'STRING';
      else if (/^-?\d/.test(value)) type = 'NUMBER';
      else if (/^[.,():=+*\/<>-]$/.test(value)) type = value;
      tokens.push({ type, value, line: lineIndex + 1 });
    }
  }
  tokens.push({ type: 'EOF', value: '', line: lines.length });
  return tokens;
}
