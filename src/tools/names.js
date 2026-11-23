// node src/tools/names.js <cartella QuestieDB> [cartella Questie] → src/i18n/names-es.json e names-fr.json: { "nome inglese": "nome del client" }
// per quest, NPC, oggetti e object (QuestieDB: data/Forever/forever*DB.lua, src/corrections/Forever/generated/foreverBase*.lua,
// l10n/Forever/lookup<Tipo>/<lingua>.lua e l10n/Forever/traces/lookup<Tipo>/<lingua>.lua) e per le zone (Questie installato:
// Localization/Translations/Zones/*.lua). Nella cartella QuestieDB bastano i file con questi nomi, anche tutti allo stesso livello:
// le traces (dati raccolti in Forever) vincono sui lookup del Classic. Restano solo i nomi che compaiono nel testo inglese della guida.
const fs = require('fs'), path = require('path');
const ROOT = path.join(__dirname, '../..'), QDB = process.argv[2];
const QST = process.argv[3] || 'C:/Program Files (x86)/World of Warcraft/_forever_/Interface/AddOns/Questie';
if (!QDB) { console.log('uso: node src/tools/names.js <cartella QuestieDB> [cartella Questie]'); process.exit(1); }
const files = []; (function walk(d) { for (const f of fs.readdirSync(d)) { const p = path.join(d, f); fs.statSync(p).isDirectory() ? walk(p) : files.push(p); } })(QDB);
const find = re => files.filter(f => re.test(f.replace(/\\/g, '/')));
const rd = f => fs.readFileSync(f, 'utf8');
const str = s => s.replace(/\\(["'\\])/g, '$1');
const TYPES = { Quests: 'Quest', Npcs: 'Npc', Items: 'Item', Objects: 'Object' };
const en = {}; // tipo → id → nome inglese
for (const [T, t] of Object.entries(TYPES)) {
  const m = en[T] = {};
  for (const f of find(new RegExp('forever' + t + 'DB\\.lua$'))) for (const x of rd(f).matchAll(/^\[(\d+)\] = \{(['"])((?:\\.|(?!\2).)*)\2/gm)) m[x[1]] = str(x[3]);
  // delta di Forever: "[id] = { -- Nome : url" e, se c'è, "[xKeys.name] = "…"" nel blocco
  for (const f of find(new RegExp('foreverBase' + t + '\\.lua$'))) for (const b of rd(f).split(/\n(?=        \[\d+\] = \{)/)) {
    const h = b.match(/^        \[(\d+)\] = \{ -- (.+?) : https/), n = b.match(/\[\w+Keys\.name\] = "((?:\\.|[^"])*)"/);
    if (h) m[h[1]] = n ? str(n[1]) : h[2];
  }
}
// una parola sola: solo zone e NPC (le quest e gli oggetti di una parola sono parole comuni: Discipline, Bear, Book…), niente demoni dei Warlock
const PETS = new Set(['Imp', 'Voidwalker', 'Succubus', 'Felhunter', 'Infernal', 'Doomguard', 'Felguard']);
const out = {};
for (const [L, loc] of [['es', 'esES'], ['fr', 'frFR']]) {
  const cnt = {}, kind = {}; // nome inglese → { localizzato: volte }, tipi da cui viene
  const add = (e, l, T, w) => { if (!e || !l || e === l || /^<|\bNYI\b/.test(e)) return; (kind[e] = kind[e] || new Set()).add(T); const c = cnt[e] = cnt[e] || {}; c[l] = (c[l] || 0) + w; };
  for (const T of Object.keys(TYPES)) {
    const loc2 = {};
    for (const re of [new RegExp('lookup' + T + '/' + loc + '\\.lua$'), new RegExp('traces/lookup' + T + '/' + loc + '\\.lua$')])
      for (const f of find(re).filter(f => re.source.startsWith('traces') === /traces/.test(f.replace(/\\/g, '/'))))
        for (const x of rd(f).matchAll(/^\[(\d+)\] = \{?"((?:\\.|[^"])*)"/gm)) loc2[x[1]] = str(x[2]);
    for (const [id, l] of Object.entries(loc2)) add(en[T][id], l, T, 1);
  }
  // zone: ["English"] = { ["enUS"] = true, … ["esES"] = "…" }; vincono sugli omonimi
  const ZD = path.join(QST, 'Localization/Translations/Zones');
  if (fs.existsSync(ZD)) for (const f of fs.readdirSync(ZD)) for (const b of rd(path.join(ZD, f)).matchAll(/\["((?:\\.|[^"])+)"\] = \{([^{}]*)\}/g)) {
    // Forever è Classic Era: in "(Questie.IsClassic and X) or Y" vale X (true = nome inglese)
    const l = b[2].match(new RegExp('\\["' + loc + '"\\] = (?:\\([^()]*? and )?"((?:\\\\.|[^"])*)"'));
    if (l && !new RegExp('\\["' + loc + '"\\] = \\([^()]*? and true\\)').test(b[2])) add(str(b[1]), str(l[1]), 'Zone', 1000);
  }
  out[L] = Object.fromEntries(Object.entries(cnt).filter(([e]) => /\s/.test(e) || kind[e].has('Zone') || kind[e].has('Npcs') && !PETS.has(e))
    .map(([e, c]) => [e, Object.entries(c).sort((a, b) => b[1] - a[1])[0][0]]));
}
// solo i nomi usati: compaiono nel testo inglese della guida (en.json) come parola intera
const EN = JSON.parse(rd(path.join(ROOT, 'src/i18n/en.json'))), big = '\n' + [...new Set(Object.values(EN))].join('\n') + '\n';
const used = e => { let i = -1; while ((i = big.indexOf(e, i + 1)) >= 0) if (!/[\w’']/.test(big[i - 1]) && !/\w/.test(big[i + e.length] || '')) return true; return false; };
// spell, talenti e alberi restano in inglese (nessuna fonte per i loro nomi): via anche i totem, gli oggetti e gli NPC che si chiamano come loro
const D = path.join(ROOT, 'src/data'), SP = new Set();
for (const f of fs.readdirSync(path.join(D, 'classes'))) { const c = JSON.parse(rd(path.join(D, 'classes', f))); for (const s of (c.spells || []).concat(c.talentSpells || [])) SP.add(s[1]); }
for (const f of fs.readdirSync(path.join(D, 'talents'))) for (const t of JSON.parse(rd(path.join(D, 'talents', f))).trees || []) { SP.add(t.name); for (const n of Object.values(t.nodes || {})) SP.add(n.name); }
for (const [L, m] of Object.entries(out)) {
  const keep = Object.fromEntries(Object.keys(m).filter(e => e.length > 3 && !SP.has(e) && used(e)).sort().map(e => [e, m[e]]));
  fs.writeFileSync(path.join(ROOT, 'src/i18n/names-' + L + '.json'), JSON.stringify(keep, null, 1) + '\n');
  console.log('names-' + L + '.json', Object.keys(keep).length, 'nomi (su', Object.keys(m).length + ')');
}
