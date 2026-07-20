export class SoederVM {
  constructor(program, options = {}) {
    this.program = program;
    this.variables = { ...program.variables };
    this.stack = [];
    this.output = [];
    this.maxSteps = options.maxSteps ?? 100000;
    this.write = options.write ?? false;
    this.labels = new Map();
    program.instructions.forEach((instruction, index) => {
      if (instruction.op === 'LABEL') this.labels.set(instruction.name, index);
    });
  }

  pop(instruction) {
    if (this.stack.length === 0) throw new Error(`Stack-Unterlauf in Zeile ${instruction.line}`);
    return this.stack.pop();
  }

  jump(target, instruction) {
    if (!this.labels.has(target)) throw new Error(`Unbekanntes Sprungziel ${target} in Zeile ${instruction.line}`);
    return this.labels.get(target);
  }

  run() {
    const code = this.program.instructions;
    let ip = 0;
    let steps = 0;
    let halted = false;

    while (ip < code.length && !halted) {
      if (steps++ >= this.maxSteps) throw new Error(`Ausführungslimit von ${this.maxSteps} Schritten überschritten`);
      const instruction = code[ip];
      let next = ip + 1;

      switch (instruction.op) {
        case 'LABEL': break;
        case 'PUSH': this.stack.push(instruction.value); break;
        case 'LOAD':
          if (!(instruction.name in this.variables)) throw new Error(`Unbekannte Variable ${instruction.name} in Zeile ${instruction.line}`);
          this.stack.push(this.variables[instruction.name]);
          break;
        case 'STORE':
          if (!(instruction.name in this.variables)) throw new Error(`Unbekannte Variable ${instruction.name} in Zeile ${instruction.line}`);
          this.variables[instruction.name] = this.pop(instruction);
          break;
        case 'ADD': { const b = this.pop(instruction); const a = this.pop(instruction); this.stack.push(a + b); break; }
        case 'SUB': { const b = this.pop(instruction); const a = this.pop(instruction); this.stack.push(a - b); break; }
        case 'MUL': { const b = this.pop(instruction); const a = this.pop(instruction); this.stack.push(a * b); break; }
        case 'DIV': {
          const b = this.pop(instruction); const a = this.pop(instruction);
          if (b === 0) throw new Error(`Division durch null in Zeile ${instruction.line}`);
          this.stack.push(a / b); break;
        }
        case 'EQ': { const b = this.pop(instruction); const a = this.pop(instruction); this.stack.push(a === b ? 1 : 0); break; }
        case 'NE': { const b = this.pop(instruction); const a = this.pop(instruction); this.stack.push(a !== b ? 1 : 0); break; }
        case 'LT': { const b = this.pop(instruction); const a = this.pop(instruction); this.stack.push(a < b ? 1 : 0); break; }
        case 'GT': { const b = this.pop(instruction); const a = this.pop(instruction); this.stack.push(a > b ? 1 : 0); break; }
        case 'JMP': next = this.jump(instruction.target, instruction); break;
        case 'JNZ': if (this.pop(instruction) !== 0) next = this.jump(instruction.target, instruction); break;
        case 'PRINT': {
          const value = String(this.pop(instruction));
          this.output.push(value);
          if (this.write) console.log(value);
          break;
        }
        case 'HALT': halted = true; break;
        default: throw new Error(`Unbekannter Opcode ${instruction.op}`);
      }
      ip = next;
    }

    return { output: [...this.output], variables: { ...this.variables }, steps, halted };
  }
}

export function execute(program, options) {
  return new SoederVM(program, options).run();
}
