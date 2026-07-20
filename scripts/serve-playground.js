import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = normalize(join(fileURLToPath(new URL('..', import.meta.url)), '..'));
const port = Number(process.env.PORT ?? 4173);
const types = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.css': 'text/css; charset=utf-8', '.json': 'application/json; charset=utf-8' };

createServer(async (req, res) => {
  try {
    const pathname = new URL(req.url, 'http://localhost').pathname;
    const requested = pathname === '/' ? '/playground/index.html' : pathname;
    const file = normalize(join(root, requested));
    if (!file.startsWith(root)) throw new Error('Forbidden');
    if (!(await stat(file)).isFile()) throw new Error('Not found');
    res.writeHead(200, { 'content-type': types[extname(file)] ?? 'application/octet-stream', 'x-content-type-options': 'nosniff' });
    res.end(await readFile(file));
  } catch {
    res.writeHead(404, { 'content-type': 'text/plain; charset=utf-8' });
    res.end('Not found');
  }
}).listen(port, () => console.log(`SöderLang Playground: http://localhost:${port}`));
