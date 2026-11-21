// node src/tools/vendors.js <cartella QuestieDB> → src/data/vendors.json
// Reagent vendor e Trade Supplies di Forever, per la mappa dell'addon (opzione «Reagent vendor e Trade Supplies»):
// - reagent vendor = chi vende almeno uno dei reagent delle classi (REAG, dai venditori degli oggetti in foreverItemDB + vendors_add
//   dello strato generato), oppure ha il sottotitolo «Reagents…» / «Reagent …»; QuestieDB lascia vuoto il sottotitolo di molti NPC;
// - Trade Supplies = sottotitolo «Trade Supplies», «Trade Supplier» o «Trade Goods».
// NPC e spawn da foreverNpcDB.lua più foreverBaseNpc.lua (NPC nuovi di Forever e cambi); zone da areaIdToUiMapId.lua.
// File nella cartella: foreverNpcDB.lua, foreverItemDB.lua (data/Forever), foreverBaseNpc.lua, foreverBaseItem.lua
// (src/corrections/Forever/generated), areaIdToUiMapId.lua (support/Forever/Zones), tutti dal repo Questie/QuestieDB.
// Uscita: [nome, "R" reagents | "T" trade supplies, fazione "A"/"H"/"AH", uiMapID, x, y] con x, y 0–100.
const fs = require('fs'), path = require('path');
const Q = process.argv[2]; if (!Q) { console.log('uso: node src/tools/vendors.js <cartella con i file di QuestieDB>'); process.exit(1); }
const rd = f => fs.readFileSync(path.join(Q, f), 'utf8');
// Arcane Powder, Rune of Teleportation/Portals, Light Feather, Holy/Sacred Candle, Symbol of Divinity/Kings, Ankh, semi e bacche del Druid,
// Flash Powder, Infernal Stone, Demonic Figurine, Fish Oil, Shiny Fish Scales
const REAG = [17020, 17031, 17032, 17056, 17028, 17029, 17033, 21177, 17030, 17034, 17035, 17036, 17037, 17038, 17021, 17026, 5140, 5565, 16583, 17058, 17057];
const SKIP = /^(Reagent Bot|Repair Bot)$/; // NPC evocati dai giocatori (Engineering), non vendor fissi
const A2U = {}; for (const m of rd('areaIdToUiMapId.lua').matchAll(/\[(\d+)\] = (\d+),/g)) A2U[m[1]] = A2U[m[1]] || +m[2];
// chi vende i reagent: base (campo vendors, il 14°, ultimo della riga) + vendors_add dello strato generato
const sellers = new Set();
for (const l of rd('foreverItemDB.lua').split('\n')) {
  const m = l.match(/^\[(\d+)\] = \{/); if (!m || !REAG.includes(+m[1])) continue;
  const v = l.match(/,\{([\d,]+)\}\},?\s*$/); if (v) v[1].split(',').forEach(x => sellers.add(x));
}
const gi = rd('foreverBaseItem.lua'), ri = /\n\s*\[(\d+)\] = \{[^\n]*\n([\s\S]*?)\n\s*\},/g; let g;
while ((g = ri.exec(gi))) if (REAG.includes(+g[1])) { const v = g[2].match(/vendors(?:_add)?\]\s*=\s*\{([\d,\s]+)\}/); if (v) v[1].split(',').forEach(x => sellers.add(x.trim())); }
// NPC: [id] = {'nome',…,{spawns},…,"A/H/AH","sottotitolo",flag}
const npc = {};
for (const l of rd('foreverNpcDB.lua').split('\n')) {
  const m = l.match(/^\[(\d+)\] = \{'((?:[^'\\]|\\.)*)',[^{]*?(\{.*?\}\}|nil),/); if (!m) continue;
  const s = [...l.matchAll(/"([^"]*)"/g)].map(x => x[1]);
  npc[m[1]] = { name: m[2].replace(/\\'/g, "'"), sp: m[3], fac: s.length >= 2 ? s[s.length - 2] : s[0] || '', sub: s.length >= 2 ? s[s.length - 1] : '' };
}
const gn = rd('foreverBaseNpc.lua'); ri.lastIndex = 0;
while ((g = ri.exec(gn))) {
  const id = g[1], b = g[2], n = npc[id] || (npc[id] = { name: '', sp: 'nil', fac: '', sub: '' });
  const f = k => (b.match(new RegExp('\\[npcKeys\\.' + k + '\\]\\s*=\\s*(.*?),?\\s*(--.*)?$', 'm')) || [])[1], s = x => x.replace(/^"|"$/g, '');
  if (f('name')) n.name = s(f('name')); if (f('subName')) n.sub = s(f('subName')); if (f('friendlyToFaction')) n.fac = s(f('friendlyToFaction')); if (f('spawns')) n.sp = f('spawns');
}
const out = [];
for (const [id, n] of Object.entries(npc)) {
  const kind = /^Trade (Supplies|Supplier|Goods)$/.test(n.sub) ? 'T' : sellers.has(id) || /^Reagent/.test(n.sub) ? 'R' : '';
  if (!kind || SKIP.test(n.name) || !/^(A|H|AH)$/.test(n.fac) || !n.sp || n.sp === 'nil') continue;
  for (const z of n.sp.matchAll(/\[(\d+)\]\s*=\s*\{((?:\s*\{[^}]*\},?)*)\s*\}/g)) {
    const um = A2U[z[1]]; if (!um) continue;
    for (const c of z[2].matchAll(/\{\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)\s*\}/g)) if (+c[1] >= 0) out.push([n.name, kind, n.fac, um, +(+c[1]).toFixed(2), +(+c[2]).toFixed(2)]);
  }
}
out.sort((a, b) => a[3] - b[3] || a[0].localeCompare(b[0]));
fs.writeFileSync(path.join(__dirname, '../data/vendors.json'), JSON.stringify({ source: 'QuestieDB Forever (foreverNpcDB, foreverItemDB e strato generato)', made: new Date().toISOString().slice(0, 10), vendors: out }) + '\n');
console.log('vendor', out.length, 'reagents', out.filter(v => v[1] === 'R').length, 'trade', out.filter(v => v[1] === 'T').length, '· venditori di reagent', sellers.size);
