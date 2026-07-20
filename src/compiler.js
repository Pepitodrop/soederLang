function requireVariable(variables, name, line) {
  if (!(name in variables)) throw new Error(`Unbekannte Variable ${name} in Zeile ${line}`);
}

function emitValue(instructions, variables, value, line) {
  if (value.type === 'Literal') instructions.push({ op: 'PUSH', value: value.value, line });
  else {
    requireVariable(variables, value.name, line);
    instructions.push({ op: 'LOAD', name: value.name, line });
  }
}

export function compile(program) {
  const instructions = [];
  const variables = Object.fromEntries(program.data.map((item) => [item.name, item.value]));
  const labels = new Set(program.body.filter((item) => item.type === 'LabelStatement').map((item) => item.name));

  for (const statement of program.body) {
    switch (statement.type) {
      case 'LabelStatement':
        instructions.push({ op: 'LABEL', name: statement.name, line: statement.line });
        break;
      case 'PrintStatement':
        emitValue(instructions, variables, statement.value, statement.line);
        instructions.push({ op: 'PRINT', line: statement.line });
        break;
      case 'SetStatement':
        requireVariable(variables, statement.name, statement.line);
        emitValue(instructions, variables, statement.value, statement.line);
        instructions.push({ op: 'STORE', name: statement.name, line: statement.line });
        break;
      case 'ArithmeticStatement':
        requireVariable(variables, statement.name, statement.line);
        instructions.push({ op: 'LOAD', name: statement.name, line: statement.line });
        emitValue(instructions, variables, statement.value, statement.line);
        instructions.push({ op: statement.operation, line: statement.line });
        instructions.push({ op: 'STORE', name: statement.name, line: statement.line });
        break;
      case 'JumpStatement':
        if (!labels.has(statement.target)) throw new Error(`Unbekanntes Sprungziel ${statement.target} in Zeile ${statement.line}`);
        instructions.push({ op: 'JMP', target: statement.target, line: statement.line });
        break;
      case 'ConditionalJumpStatement':
        if (!labels.has(statement.target)) throw new Error(`Unbekanntes Sprungziel ${statement.target} in Zeile ${statement.line}`);
        emitValue(instructions, variables, statement.left, statement.line);
        emitValue(instructions, variables, statement.right, statement.line);
        instructions.push({ op: statement.comparison, line: statement.line });
        instructions.push({ op: 'JNZ', target: statement.target, line: statement.line });
        break;
      case 'StopStatement':
        instructions.push({ op: 'HALT', line: statement.line });
        break;
      default:
        throw new Error(`Nicht kompilierbarer AST-Knoten: ${statement.type}`);
    }
  }

  if (instructions.at(-1)?.op !== 'HALT') instructions.push({ op: 'HALT', line: 0 });
  return { name: program.name, variables, instructions };
}
