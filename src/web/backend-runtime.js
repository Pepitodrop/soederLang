function valueOf(expression, variables) {
  if (expression.type === 'Literal') return expression.value;
  if (!(expression.name in variables)) throw new Error(`Unbekannte Backend-Variable ${expression.name}`);
  return variables[expression.name];
}

function compilePath(path) {
  const names = [];
  const escaped = String(path).split('/').map((part) => {
    if (part.startsWith(':')) {
      names.push(part.slice(1));
      return '([^/]+)';
    }
    return part.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }).join('/');
  return { regex: new RegExp(`^${escaped}/?$`), names };
}

function matchRoute(route, pathname) {
  const match = route.pattern.regex.exec(pathname);
  if (!match) return null;
  return Object.fromEntries(route.pattern.names.map((name, index) => [name, decodeURIComponent(match[index + 1])]));
}

export class BackendRuntime {
  constructor(program, options = {}) {
    this.program = program;
    this.call = options.call ?? (async () => {});
    this.middleware = [...(options.middleware ?? [])];
    this.maxBodyBytes = options.maxBodyBytes ?? 1024 * 1024;
    this.initialVariables = Object.fromEntries(program.data.map((item) => [item.name, item.value]));
    this.routes = this.buildRoutes(program.backend);
  }

  use(middleware) {
    if (typeof middleware !== 'function') throw new TypeError('Middleware muss eine Funktion sein');
    this.middleware.push(middleware);
    return this;
  }

  buildRoutes(statements) {
    const routes = [];
    let current = null;
    for (const statement of statements) {
      if (statement.type === 'RouteStatement') {
        const path = String(valueOf(statement.path, this.initialVariables));
        current = { method: statement.method, path, pattern: compilePath(path), handler: statement.handler, statements: [] };
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
    let route = null;
    let params = null;
    for (const candidate of this.routes) {
      if (candidate.method !== method) continue;
      const candidateParams = matchRoute(candidate, pathname);
      if (candidateParams) { route = candidate; params = candidateParams; break; }
    }
    if (!route) return { status: 404, headers: { 'content-type': 'application/json; charset=utf-8' }, body: JSON.stringify({ error: 'Nicht gefunden' }) };

    const normalizedRequest = { ...request, method, path: pathname, params };
    const variables = { ...this.initialVariables };
    const context = { request: normalizedRequest, route, variables, runtime: this };

    let middlewareIndex = -1;
    const run = async (index) => {
      if (index <= middlewareIndex) throw new Error('next() wurde mehrfach aufgerufen');
      middlewareIndex = index;
      const middleware = this.middleware[index];
      if (middleware) return middleware(context, () => run(index + 1));
      return this.call(route.handler, context);
    };
    const middlewareResponse = await run(0);
    if (middlewareResponse && typeof middlewareResponse === 'object' && 'status' in middlewareResponse) return middlewareResponse;

    let status = 200;
    let response = null;
    for (const statement of route.statements) {
      switch (statement.type) {
        case 'RequestReadStatement':
          variables[statement.target] = normalizedRequest[statement.field];
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
      try {
        const chunks = [];
        let received = 0;
        for await (const chunk of req) {
          received += chunk.length;
          if (received > this.maxBodyBytes) {
            res.writeHead(413, { 'content-type': 'application/json; charset=utf-8' });
            res.end(JSON.stringify({ error: 'Anfrage zu groß' }));
            return;
          }
          chunks.push(chunk);
        }
        const rawBody = Buffer.concat(chunks).toString('utf8');
        let body = rawBody;
        if ((req.headers['content-type'] ?? '').includes('application/json') && rawBody) body = JSON.parse(rawBody);
        const url = new URL(req.url, 'http://soeder.local');
        const result = await this.dispatch({
          method: req.method,
          url: req.url,
          path: url.pathname,
          query: Object.fromEntries(url.searchParams),
          body
        });
        res.writeHead(result.status, result.headers);
        res.end(result.body);
      } catch (error) {
        res.writeHead(500, { 'content-type': 'application/json; charset=utf-8' });
        res.end(JSON.stringify({ error: error.message }));
      }
    };
  }
}

export function createBackend(program, options) {
  return new BackendRuntime(program, options);
}
