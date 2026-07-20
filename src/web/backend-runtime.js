function valueOf(expression, variables) {
  if (expression.type === 'Literal') return expression.value;
  if (!(expression.name in variables)) throw new Error(`Unbekannte Backend-Variable ${expression.name}`);
  return variables[expression.name];
}

export class BackendRuntime {
  constructor(program) {
    this.program = program;
    this.initialVariables = Object.fromEntries(program.data.map((item) => [item.name, item.value]));
    this.routes = this.buildRoutes(program.backend);
  }

  buildRoutes(statements) {
    const routes = [];
    let current = null;
    for (const statement of statements) {
      if (statement.type === 'RouteStatement') {
        current = { method: statement.method, path: valueOf(statement.path, this.initialVariables), handler: statement.handler, statements: [] };
        routes.push(current);
      } else {
        if (!current) throw new Error(`Backend-Anweisung vor erster ROUTE in Zeile ${statement.line}`);
        current.statements.push(statement);
      }
    }
    return routes;
  }

  async dispatch(request) {
    const method = String(request.method ?? 'GET').toUpperCase();
    const pathname = request.path ?? new URL(request.url, 'http://soeder.local').pathname;
    const route = this.routes.find((candidate) => candidate.method === method && candidate.path === pathname);
    if (!route) return { status: 404, headers: { 'content-type': 'application/json' }, body: JSON.stringify({ error: 'Nicht gefunden' }) };

    const variables = { ...this.initialVariables };
    let status = 200;
    let response = null;
    for (const statement of route.statements) {
      switch (statement.type) {
        case 'RequestReadStatement':
          variables[statement.target] = request[statement.field];
          break;
        case 'StatusStatement':
          status = statement.status;
          break;
        case 'JsonResponseStatement':
          response = { status, headers: { 'content-type': 'application/json; charset=utf-8' }, body: JSON.stringify(valueOf(statement.value, variables)) };
          break;
        case 'TextResponseStatement':
          response = { status, headers: { 'content-type': 'text/plain; charset=utf-8' }, body: String(valueOf(statement.value, variables)) };
          break;
        default:
          throw new Error(`Unbekannte Backend-Anweisung ${statement.type}`);
      }
    }
    return response ?? { status: 204, headers: {}, body: '' };
  }

  createNodeHandler() {
    return async (req, res) => {
      const chunks = [];
      for await (const chunk of req) chunks.push(chunk);
      const rawBody = Buffer.concat(chunks).toString('utf8');
      let body = rawBody;
      if ((req.headers['content-type'] ?? '').includes('application/json') && rawBody) body = JSON.parse(rawBody);
      const url = new URL(req.url, 'http://soeder.local');
      const result = await this.dispatch({
        method: req.method,
        url: req.url,
        path: url.pathname,
        query: Object.fromEntries(url.searchParams),
        params: {},
        body
      });
      res.writeHead(result.status, result.headers);
      res.end(result.body);
    };
  }
}

export function createBackend(program) {
  return new BackendRuntime(program);
}
