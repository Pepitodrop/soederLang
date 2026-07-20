# SöderLang

[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](CHANGELOG.md)
[![Node](https://img.shields.io/badge/node-%3E%3D20-green.svg)](package.json)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

**SöderLang 1.1.0** is a COBOL-inspired, Turing-complete programming language whose source reads like exaggerated fictional political speech associated with Markus Söder. It includes a tokenizer, parser, AST, bytecode compiler, stack virtual machine, CLI, browser runtime, backend HTTP runtime, and interactive playground.

> **Satire notice:** This project is fictional political satire. It is not affiliated with or endorsed by Markus Söder, the Bavarian State Government, the CSU, Bündnis 90/Die Grünen, or any broadcaster. All speech aliases are invented parody constructs, not authentic quotations. Political phrases are exaggerated satire and contain no threats or slurs.

## Highlights

- Turing-complete language core with numbers, text, variables, arithmetic, comparisons, labels, jumps, and loops
- Functions, recursion, call frames, heap allocation, reads, writes, and bounded runtime safeguards
- 100 functional fictional speech aliases backed by one canonical registry
- Food-blogger, influencer, social-media, grill, meat, beer-garden, and political parody vocabulary
- Browser DOM, events, state, storage, and fetch runtime through explicit host adapters
- Backend GET/POST/PUT/PATCH/DELETE routes, named route parameters, middleware, request access, JSON/text responses, and body-size limits
- Interactive playground with console output, AST, bytecode, and sandboxed frontend preview
- Automated tests on Node.js 20 and 22, CI, npm packaging, release automation, specifications, and security guidance

## Install

```bash
npm install
npm test
```

Run an example:

```bash
node src/cli.js run examples/meme-speech.soeder
```

After npm publication:

```bash
npm install -g soeder-lang
soeder run program.soeder
```

## CLI

```bash
soeder run file.soeder       # execute a program
soeder compile file.soeder   # print compiled bytecode
soeder check file.soeder     # validate syntax and compilation
soeder ast file.soeder       # print the parsed AST
soeder tokens file.soeder    # print normalized tokens
```

## Playground

```bash
npm run playground
```

Open `http://localhost:4173`. Press **Run** or `Ctrl/Cmd + Enter` to parse and execute the current program. The playground displays program output, AST, bytecode, and a sandboxed frontend preview.

## Example

```text
IDENTIFICATION DIVISION.
PROGRAM-ID. BAYERISCHE-REDE.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 LIKES ZAHL WERT 0.
PROCEDURE DIVISION.
BAYERN ZUERST.
LINK IN DER BIO LIKES AUF 2.
FOLLOWER BONUS 3 ZU LIKES.
DOPPELTE BRATWURST LIKES MIT 2.
DIE GRUENEN WIEDER 1 VON LIKES.
FOODBLOGGER URTEIL LIKES.
HANDY AUS ESSEN KOMMT.
```

## Complete meme alias reference

Aliases are case-insensitive, normalized outside quoted strings, and map to the same canonical language constructs used by ordinary SöderLang syntax.

| Canonical construct | Fictional aliases |
|---|---|
| `SAG` | `JETZT MAL KLARTEXT`, `DAS MUSS MAN SAGEN`, `ICH SAGE GANZ KLAR`, `KLARE KANTE`, `MIA SAN AUSGABE`, `FOODBLOGGER URTEIL`, `JETZT KOMMT DER GESCHMACKSTEST`, `AB IN DIE STORY`, `KAMERA LAEUFT`, `JETZT EIN REEL`, `SELFIE MIT ANSAGE` |
| `SETZE` | `PACK MAS`, `JETZT WIRD GELIEFERT`, `BAYERN MACHT DAS`, `ORDNUNG MUSS SEIN`, `MACHEN STATT REDEN`, `LINK IN DER BIO`, `CONTENT PLAN STEHT`, `GRILL IST AN`, `TELLER WIRD ANGERICHTET` |
| `ADDIERE` | `MEHR DAVON`, `NOCH EINE SCHIPPE`, `BAYERN BONUS`, `DOPPELT HILFT`, `AUFWAERTS IMMER`, `MEHR FLEISCH`, `SCHWEINEBRATEN BONUS`, `FOLLOWER BONUS`, `NOCH EINE BRATWURST` |
| `SUBTRAHIERE` | `WENIGER BERLIN`, `RUNTER DAMIT`, `SPAREN ABER RICHTIG`, `KEIN SCHNICKSCHNACK`, `ROTSTIFT RAUS`, `WENIGER GRUEN`, `DIE GRUENEN WIEDER`, `GRUENEN CHECK NICHT BESTANDEN` |
| `MULTIPLIZIERE` | `BAYERN HOCH ZWEI`, `VOLLE KRAFT`, `MEHR MEHR MEHR`, `WACHSTUM TURBO`, `DOPPELTER DOPPEL-WUMMS`, `DOPPELTE BRATWURST`, `LIKES MAL LIKES`, `CONTENT OFFENSIVE` |
| `DIVIDIERE` | `SAUBER AUFTEILEN`, `JEDER KRIEGT SEINS`, `FOEDERAL VERTEILEN`, `DURCH DIE MITTE`, `FAIRER ANTEIL`, `TELLER GERECHT TEILEN` |
| `SPRINGE` | `AUF GEHTS`, `AB NACH BAYERN`, `WEITER GEHTS`, `KEINE ZEIT VERLIEREN`, `SOFORT WEITER`, `NAECHSTER DREHORT`, `AB ZUM BIERGARTEN` |
| `WENN` | `WENN DAS SO IST`, `FALLS BAYERN WILL`, `NUR WENN ES PASST`, `UNTER EINER BEDINGUNG`, `SCHAUN MER MAL OB`, `WENN DER GESCHMACK PASST` |
| `GLEICH` | `GENAU SO`, `IDENTISCH BAYERISCH`, `DASSELBE IN GRUEN`, `GESCHMACKLICH IDENTISCH` |
| `UNGLEICH` | `NICHT UNSER DING`, `GANZ WAS ANDERES`, `BERLIN IST ANDERS`, `NICHT MIT DEN GRUENEN` |
| `KLEINER` | `KLEIN ABER FEIN`, `NOCH NICHT GENUG`, `UNTER BAYERISCHEM NIVEAU` |
| `GROESSER` | `GROESSER DENKEN`, `BAYERN IST SPITZE`, `UEBER DEM DURCHSCHNITT` |
| `RUF` | `RUF DEN MINISTER`, `HOL DIE STAATSKANZLEI`, `DIREKTER DRAHT` |
| `ZURUECK` | `ZURUECK INS STUDIO`, `WIEDER ZUM ANFANG`, `AUFGABE ERLEDIGT` |
| `STOPP` | `JETZT IST SCHLUSS`, `FEIERABEND IN BAYERN`, `DAS WARS`, `HANDY AUS ESSEN KOMMT` |
| `HAUPTPROGRAMM` | `BAYERN ZUERST`, `DIE REGIERUNGSZENTRALE`, `HAUPTSACHE BAYERN` |
| `RESERVIERE` | `RESERVIER DEN BIERGARTEN`, `MEHR PLATZ FUER BAYERN`, `SPEICHER OFFENSIVE` |
| `SCHREIBE` | `SCHREIBS INS GRUNDSATZPROGRAMM`, `HALT DAS FEST`, `AKTENKUNDIG MACHEN` |
| `LIES` | `LIES DIE AKTE`, `SCHAU IN DEN SPEICHER`, `HOL DIE ZAHLEN` |

The canonical registry is exported as `SOEDER_ALIASES`; the detailed reference is also available in [`docs/MEME-ALIASES.md`](docs/MEME-ALIASES.md).

## Architecture

```text
.soeder source
    ↓ alias normalization
 tokenizer → parser → AST
                    ├─ compiler → bytecode → VM
                    ├─ browser runtime → host DOM/fetch adapters
                    └─ backend runtime → HTTP routes/middleware
```

The language core does not evaluate arbitrary JavaScript. Browser and backend capabilities are provided through explicit host adapters and bounded runtime options.

## Package exports

```js
import { parse, compile, execute } from 'soeder-lang';
import { executeBrowser } from 'soeder-lang/browser';
import { createBackend } from 'soeder-lang/backend';
```

## Documentation

- [`SPEC.md`](SPEC.md) — language and VM specification
- [`docs/MEME-ALIASES.md`](docs/MEME-ALIASES.md) — canonical speech-alias profile
- [`docs/TURING-COMPLETENESS.md`](docs/TURING-COMPLETENESS.md) — computational construction
- [`docs/WEB-PROFILES.md`](docs/WEB-PROFILES.md) — browser and backend profiles
- [`SECURITY.md`](SECURITY.md) — security model and vulnerability reporting
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — contribution workflow
- [`CHANGELOG.md`](CHANGELOG.md) — release history

## Stability

Version `1.1.0` preserves the stable 1.0 core syntax, bytecode behavior, CLI, and public package exports while adding backward-compatible aliases. Breaking syntax, bytecode, or public runtime API changes require a new major version.

## License

MIT. See [`LICENSE`](LICENSE).
