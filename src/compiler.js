function emitValue(instructions, value, line) {
  if (value.type === 'Literal') instructions.push({ op: 'PUSH', value: value.value, line });
  else instructions.push({ op: 'LOAD', name: value.name, line });
}

export function compile(program) {
  const instructions = [];
  const variables = Object.fromEntries(program.data.map((item) => [item.name, item.value]));

  for (const statement of program.body) {
    switch (statement.type) {
      case 'LabelStatement':
        instructions.push({ op: 'LABEL', name: statement.name, line: statement.line });
        break;
      case 'PrintStatement':
        emitValue(instructions, statement.value, statement.line);
        instructions.push({ op: 'PRINT', line: statement.line });
        break;
      case 'SetStatement':
        emitValue(instructions, statement.value, statement.line);
        instructions.push({ op: 'STORE', name: statement.name, line: statement.line });
        break;
      case 'ArithmeticStatement':
        instructions.push({ op: 'LOAD', name: statement.name, line: statement.line });
        emitValue(instructions, statement.value, statement.line);
        instructions.push({ op: statement.operation, line: statement.line });
        instructions.push({ op: 'STORE', name: statement.name, line: statement.line });
        break;
      case 'JumpStatement':
        instructions.push({ op: 'JMP', target: statement.target, line: statement.line });
        break;
      case 'ConditionalJumpStatement':
        emitValue(instructions, statement.left, statement.line);
        emitValue(instructions, statement.right, statement.line);
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
