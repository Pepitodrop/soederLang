import { useEffect, useState } from 'react';

type Health = {
  ok: boolean;
  runtime?: string;
  architecture?: string;
  phase?: string;
  error?: string;
};

type ExecuteResponse = {
  ok: boolean;
  runtime?: string;
  output?: string[];
  error?: string;
};

const starter = `SAG 42.
STOPP.
`;

export function App() {
  const [source, setSource] = useState(starter);
  const [status, setStatus] = useState<Health | null>(null);
  const [output, setOutput] = useState('Ready to execute through GnuCOBOL.');
  const [running, setRunning] = useState(false);

  useEffect(() => {
    fetch('/api/health')
      .then((response) => response.json())
      .then(setStatus)
      .catch((error: Error) => setStatus({ ok: false, error: error.message }));
  }, []);

  async function run() {
    setRunning(true);
    try {
      const response = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ source }),
      });
      const body = (await response.json()) as ExecuteResponse;
      setOutput(body.ok ? (body.output ?? []).join('\n') : body.error ?? 'Execution failed');
    } catch (error) {
      setOutput(error instanceof Error ? error.message : 'Execution failed');
    } finally {
      setRunning(false);
    }
  }

  return (
    <main>
      <header>
        <h1>SöderLang COBOL Playground</h1>
        <p>
          Runtime: <strong>{status?.runtime ?? 'checking…'}</strong> · Architecture:{' '}
          <strong>{status?.architecture ?? 'checking…'}</strong>
        </p>
      </header>

      <section>
        <label htmlFor="source">SöderLang source</label>
        <textarea
          id="source"
          value={source}
          onChange={(event) => setSource(event.target.value)}
          spellCheck={false}
        />
        <button type="button" onClick={run} disabled={running}>
          {running ? 'Running…' : 'Run through GnuCOBOL'}
        </button>
      </section>

      <section>
        <h2>Program output</h2>
        <pre>{output}</pre>
      </section>
    </main>
  );
}
