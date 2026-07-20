function valueOf(expression, variables) {
  if (expression.type === 'Literal') return expression.value;
  if (!(expression.name in variables)) throw new Error(`Unbekannte Web-Variable ${expression.name}`);
  return variables[expression.name];
}

export class BrowserRuntime {
  constructor(program, host = {}) {
    this.program = program;
    this.document = host.document;
    this.fetch = host.fetch;
    this.storage = host.storage ?? new Map();
    this.call = host.call ?? (() => {});
    this.variables = Object.fromEntries(program.data.map((item) => [item.name, item.value]));
    this.elements = new Map();
    if (!this.document) throw new Error('BrowserRuntime benötigt einen document-Adapter');
  }

  async run() {
    for (const statement of this.program.frontend) {
      switch (statement.type) {
        case 'CreateElementStatement': {
          const element = this.document.createElement(String(valueOf(statement.tag, this.variables)));
          this.elements.set(statement.target, element);
          break;
        }
        case 'SetTextStatement':
          this.requireElement(statement.target).textContent = String(valueOf(statement.value, this.variables));
          break;
        case 'SetAttributeStatement':
          this.requireElement(statement.target).setAttribute(
            String(valueOf(statement.attribute, this.variables)),
            String(valueOf(statement.value, this.variables))
          );
          break;
        case 'AppendElementStatement': {
          const parentRef = valueOf(statement.parent, this.variables);
          const parent = this.elements.get(String(parentRef)) ?? this.document.querySelector(String(parentRef));
          if (!parent) throw new Error(`DOM-Ziel ${parentRef} nicht gefunden in Zeile ${statement.line}`);
          parent.appendChild(this.requireElement(statement.target));
          break;
        }
        case 'BindEventStatement':
          this.requireElement(statement.target).addEventListener(
            String(valueOf(statement.event, this.variables)),
            (event) => this.call(statement.handler, { event, runtime: this })
          );
          break;
        case 'StateWriteStatement': {
          const key = String(valueOf(statement.key, this.variables));
          const value = valueOf(statement.value, this.variables);
          this.storage.set ? this.storage.set(key, value) : this.storage.setItem(key, JSON.stringify(value));
          break;
        }
        case 'StateReadStatement': {
          const key = String(valueOf(statement.key, this.variables));
          let value = this.storage.get ? this.storage.get(key) : this.storage.getItem(key);
          if (!this.storage.get && value !== null) {
            try { value = JSON.parse(value); } catch { /* preserve text */ }
          }
          this.variables[statement.target] = value;
          break;
        }
        case 'FetchStatement': {
          if (!this.fetch) throw new Error('HOLE benötigt einen fetch-Adapter');
          const response = await this.fetch(String(valueOf(statement.url, this.variables)));
          const contentType = response.headers?.get?.('content-type') ?? '';
          this.variables[statement.target] = contentType.includes('json') ? await response.json() : await response.text();
          break;
        }
        default:
          throw new Error(`Unbekannte Frontend-Anweisung ${statement.type}`);
      }
    }
    return { variables: { ...this.variables }, elements: this.elements };
  }

  requireElement(name) {
    const element = this.elements.get(name);
    if (!element) throw new Error(`DOM-Element ${name} wurde nicht erstellt`);
    return element;
  }
}

export async function executeBrowser(program, host) {
  return new BrowserRuntime(program, host).run();
}
