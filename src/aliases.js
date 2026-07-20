const entries = [
  ['JETZT MAL KLARTEXT', 'SAG'],
  ['DAS MUSS MAN SAGEN', 'SAG'],
  ['ICH SAGE GANZ KLAR', 'SAG'],
  ['KLARE KANTE', 'SAG'],
  ['MIA SAN AUSGABE', 'SAG'],
  ['PACK MAS', 'SETZE'],
  ['JETZT WIRD GELIEFERT', 'SETZE'],
  ['BAYERN MACHT DAS', 'SETZE'],
  ['ORDNUNG MUSS SEIN', 'SETZE'],
  ['MACHEN STATT REDEN', 'SETZE'],
  ['MEHR DAVON', 'ADDIERE'],
  ['NOCH EINE SCHIPPE', 'ADDIERE'],
  ['BAYERN BONUS', 'ADDIERE'],
  ['DOPPELT HILFT', 'ADDIERE'],
  ['AUFWAERTS IMMER', 'ADDIERE'],
  ['WENIGER BERLIN', 'SUBTRAHIERE'],
  ['RUNTER DAMIT', 'SUBTRAHIERE'],
  ['SPAREN ABER RICHTIG', 'SUBTRAHIERE'],
  ['KEIN SCHNICKSCHNACK', 'SUBTRAHIERE'],
  ['ROTSTIFT RAUS', 'SUBTRAHIERE'],
  ['BAYERN HOCH ZWEI', 'MULTIPLIZIERE'],
  ['VOLLE KRAFT', 'MULTIPLIZIERE'],
  ['MEHR MEHR MEHR', 'MULTIPLIZIERE'],
  ['WACHSTUM TURBO', 'MULTIPLIZIERE'],
  ['DOPPELTER DOPPEL-WUMMS', 'MULTIPLIZIERE'],
  ['SAUBER AUFTEILEN', 'DIVIDIERE'],
  ['JEDER KRIEGT SEINS', 'DIVIDIERE'],
  ['FOEDERAL VERTEILEN', 'DIVIDIERE'],
  ['DURCH DIE MITTE', 'DIVIDIERE'],
  ['FAIRER ANTEIL', 'DIVIDIERE'],
  ['AUF GEHTS', 'SPRINGE'],
  ['AB NACH BAYERN', 'SPRINGE'],
  ['WEITER GEHTS', 'SPRINGE'],
  ['KEINE ZEIT VERLIEREN', 'SPRINGE'],
  ['SOFORT WEITER', 'SPRINGE'],
  ['WENN DAS SO IST', 'WENN'],
  ['FALLS BAYERN WILL', 'WENN'],
  ['NUR WENN ES PASST', 'WENN'],
  ['UNTER EINER BEDINGUNG', 'WENN'],
  ['SCHAUN MER MAL OB', 'WENN'],
  ['GENAU SO', 'GLEICH'],
  ['IDENTISCH BAYERISCH', 'GLEICH'],
  ['DASSELBE IN GRUEN', 'GLEICH'],
  ['NICHT UNSER DING', 'UNGLEICH'],
  ['GANZ WAS ANDERES', 'UNGLEICH'],
  ['BERLIN IST ANDERS', 'UNGLEICH'],
  ['KLEIN ABER FEIN', 'KLEINER'],
  ['NOCH NICHT GENUG', 'KLEINER'],
  ['UNTER BAYERISCHEM NIVEAU', 'KLEINER'],
  ['GROESSER DENKEN', 'GROESSER'],
  ['BAYERN IST SPITZE', 'GROESSER'],
  ['UEBER DEM DURCHSCHNITT', 'GROESSER'],
  ['RUF DEN MINISTER', 'RUF'],
  ['HOL DIE STAATSKANZLEI', 'RUF'],
  ['DIREKTER DRAHT', 'RUF'],
  ['ZURUECK INS STUDIO', 'ZURUECK'],
  ['WIEDER ZUM ANFANG', 'ZURUECK'],
  ['AUFGABE ERLEDIGT', 'ZURUECK'],
  ['JETZT IST SCHLUSS', 'STOPP'],
  ['FEIERABEND IN BAYERN', 'STOPP'],
  ['DAS WARS', 'STOPP'],
  ['BAYERN ZUERST', 'HAUPTPROGRAMM'],
  ['DIE REGIERUNGSZENTRALE', 'HAUPTPROGRAMM'],
  ['HAUPTSACHE BAYERN', 'HAUPTPROGRAMM'],
  ['RESERVIER DEN BIERGARTEN', 'RESERVIERE'],
  ['MEHR PLATZ FUER BAYERN', 'RESERVIERE'],
  ['SPEICHER OFFENSIVE', 'RESERVIERE'],
  ['SCHREIBS INS GRUNDSATZPROGRAMM', 'SCHREIBE'],
  ['HALT DAS FEST', 'SCHREIBE'],
  ['AKTENKUNDIG MACHEN', 'SCHREIBE'],
  ['LIES DIE AKTE', 'LIES'],
  ['SCHAU IN DEN SPEICHER', 'LIES'],
  ['HOL DIE ZAHLEN', 'LIES']
];

export const SOEDER_ALIASES = Object.freeze(entries.map(([alias, canonical]) => ({ alias, canonical })));

const ordered = [...SOEDER_ALIASES].sort((a, b) => b.alias.length - a.alias.length);

function replaceOutsideStrings(line) {
  const parts = line.split(/("(?:[^"\\]|\\.)*")/g);
  return parts.map((part, index) => {
    if (index % 2 === 1) return part;
    let normalized = part;
    for (const { alias, canonical } of ordered) {
      const escaped = alias.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      normalized = normalized.replace(new RegExp(`\\b${escaped}\\b`, 'gi'), canonical);
    }
    return normalized;
  }).join('');
}

export function normalizeAliases(source) {
  return source.replace(/\r/g, '').split('\n').map(replaceOutsideStrings).join('\n');
}
