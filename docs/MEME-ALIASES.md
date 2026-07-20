# SöderLang Speech Alias Profile

Status: version 0.4

All phrases below are fictional parody constructs. They are not presented as authentic Markus Söder quotations and do not imply endorsement or affiliation.

Aliases are normalized outside string literals before tokenization. Every entry therefore invokes the same parser, compiler, validation, and runtime behavior as its canonical keyword.

## Output → `SAG`

- `JETZT MAL KLARTEXT`
- `DAS MUSS MAN SAGEN`
- `ICH SAGE GANZ KLAR`
- `KLARE KANTE`
- `MIA SAN AUSGABE`

## Assignment → `SETZE`

- `PACK MAS`
- `JETZT WIRD GELIEFERT`
- `BAYERN MACHT DAS`
- `ORDNUNG MUSS SEIN`
- `MACHEN STATT REDEN`

## Addition → `ADDIERE`

- `MEHR DAVON`
- `NOCH EINE SCHIPPE`
- `BAYERN BONUS`
- `DOPPELT HILFT`
- `AUFWAERTS IMMER`

## Subtraction → `SUBTRAHIERE`

- `WENIGER BERLIN`
- `RUNTER DAMIT`
- `SPAREN ABER RICHTIG`
- `KEIN SCHNICKSCHNACK`
- `ROTSTIFT RAUS`

## Multiplication → `MULTIPLIZIERE`

- `BAYERN HOCH ZWEI`
- `VOLLE KRAFT`
- `MEHR MEHR MEHR`
- `WACHSTUM TURBO`
- `DOPPELTER DOPPEL-WUMMS`

## Division → `DIVIDIERE`

- `SAUBER AUFTEILEN`
- `JEDER KRIEGT SEINS`
- `FOEDERAL VERTEILEN`
- `DURCH DIE MITTE`
- `FAIRER ANTEIL`

## Jump → `SPRINGE`

- `AUF GEHTS`
- `AB NACH BAYERN`
- `WEITER GEHTS`
- `KEINE ZEIT VERLIEREN`
- `SOFORT WEITER`

## Conditional → `WENN`

- `WENN DAS SO IST`
- `FALLS BAYERN WILL`
- `NUR WENN ES PASST`
- `UNTER EINER BEDINGUNG`
- `SCHAUN MER MAL OB`

## Equality → `GLEICH`

- `GENAU SO`
- `IDENTISCH BAYERISCH`
- `DASSELBE IN GRUEN`

## Inequality → `UNGLEICH`

- `NICHT UNSER DING`
- `GANZ WAS ANDERES`
- `BERLIN IST ANDERS`

## Less-than → `KLEINER`

- `KLEIN ABER FEIN`
- `NOCH NICHT GENUG`
- `UNTER BAYERISCHEM NIVEAU`

## Greater-than → `GROESSER`

- `GROESSER DENKEN`
- `BAYERN IST SPITZE`
- `UEBER DEM DURCHSCHNITT`

## Function call → `RUF`

- `RUF DEN MINISTER`
- `HOL DIE STAATSKANZLEI`
- `DIREKTER DRAHT`

## Return → `ZURUECK`

- `ZURUECK INS STUDIO`
- `WIEDER ZUM ANFANG`
- `AUFGABE ERLEDIGT`

## Stop → `STOPP`

- `JETZT IST SCHLUSS`
- `FEIERABEND IN BAYERN`
- `DAS WARS`

## Main entry point → `HAUPTPROGRAMM`

- `BAYERN ZUERST`
- `DIE REGIERUNGSZENTRALE`
- `HAUPTSACHE BAYERN`

## Heap allocation → `RESERVIERE`

- `RESERVIER DEN BIERGARTEN`
- `MEHR PLATZ FUER BAYERN`
- `SPEICHER OFFENSIVE`

## Heap write → `SCHREIBE`

- `SCHREIBS INS GRUNDSATZPROGRAMM`
- `HALT DAS FEST`
- `AKTENKUNDIG MACHEN`

## Heap read → `LIES`

- `LIES DIE AKTE`
- `SCHAU IN DEN SPEICHER`
- `HOL DIE ZAHLEN`

## Example

```text
BAYERN ZUERST.
PACK MAS UMFRAGE AUF 1.
WAHLKAMPF:
  ICH SAGE GANZ KLAR UMFRAGE.
  BAYERN BONUS 1 ZU UMFRAGE.
  WENN DAS SO IST UMFRAGE KLEINER 4 WEITER GEHTS ZU WAHLKAMPF.
  FEIERABEND IN BAYERN.
```

The registry is also exported as `SOEDER_ALIASES`, allowing tooling, editors, documentation generators, and playgrounds to consume the same authoritative data used by the parser.
