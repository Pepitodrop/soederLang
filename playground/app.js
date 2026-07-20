import { parse } from '../src/parser.js';
import { compile } from '../src/compiler.js';
import { execute } from '../src/vm.js';
import { executeBrowser } from '../src/web/browser-runtime.js';

const source = document.querySelector('#source');
const output = document.querySelector('#output');
const ast = document.querySelector('#ast');
const bytecode = document.querySelector('#bytecode');
const preview = document.querySelector('#preview');

source.value = `IDENTIFICATION DIVISION.
PROGRAM-ID. PLAYGROUND.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 GRUSS TEXT WERT "Servus aus dem SöderLang Playground".
01 ZAEHLER ZAHL WERT 1.
PROCEDURE DIVISION.
ICH SAGE GANZ KLAR GRUSS.
BAYERN BONUS 2 ZU ZAEHLER.
ICH SAGE GANZ KLAR ZAEHLER.
FEIERABEND IN BAYERN.
WEB-FRONTEND DIVISION.
ERSTELLE "h1" ALS TITEL.
SETZE TEXT VON TITEL AUF GRUSS.
HAENGE TITEL AN "body".`;

function show(tab) {
  document.querySelectorAll('.pane').forEach((pane) => pane.classList.toggle('active', pane.id === tab));
  document.querySelectorAll('[data-tab]').forEach((button) => button.classList.toggle('active', button.dataset.tab === tab));
}

document.querySelectorAll('[data-tab]').forEach((button) => button.addEventListener('click', () => show(button.dataset.tab)));

async function run() {
  output.classList.remove('error');
  try {
    const program = parse(source.value);
    const compiled = compile(program);
    const result = execute(compiled, { maxSteps: 100000, maxHeap: 100000 });
    output.textContent = result.output.join('\n') || '(no console output)';
    ast.textContent = JSON.stringify(program, null, 2);
    bytecode.textContent = compiled.instructions.map((instruction, index) => `${String(index).padStart(4, '0')}  ${JSON.stringify(instruction)}`).join('\n');

    preview.src = 'about:blank';
    await new Promise((resolve) => preview.addEventListener('load', resolve, { once: true }));
    const previewDocument = preview.contentDocument;
    previewDocument.body.innerHTML = '';
    if (program.frontend?.length) {
      await executeBrowser(program, {
        document: previewDocument,
        fetch: window.fetch.bind(window),
        storage: new Map(),
        call: (name) => console.info(`SöderLang handler: ${name}`)
      });
    } else {
      previewDocument.body.textContent = 'No WEB-FRONTEND DIVISION in this program.';
    }
  } catch (error) {
    output.classList.add('error');
    output.textContent = error.stack ?? error.message;
    ast.textContent = '';
    bytecode.textContent = '';
    show('output');
  }
}

document.querySelector('#run').addEventListener('click', run);
source.addEventListener('keydown', (event) => {
  if ((event.ctrlKey || event.metaKey) && event.key === 'Enter') run();
  if (event.key === 'Tab') {
    event.preventDefault();
    const start = source.selectionStart;
    source.setRangeText('  ', start, source.selectionEnd, 'end');
  }
});

run();
