// node src/tools/build.js → ../WoW_Forever_Leveling_Companion.html (un solo file, funziona offline salvo immagini/mappa)
// Unisce src/data/* nel template, risolve i nomi (talent → chiavi del client, città/NPC → coordinate) e segnala gli errori.
const fs = require('fs'), path = require('path');
const SRC = path.join(__dirname, '..'), DATA = path.join(SRC, 'data'), OUT = path.join(SRC, '../WoW_Forever_Leveling_Companion.html');
const J = f => JSON.parse(fs.readFileSync(f, 'utf8'));
const dir = d => fs.readdirSync(path.join(DATA, d)).filter(f => f.endsWith('.json')).map(f => [f.slice(0, -5), J(path.join(DATA, d, f))]);
const warn = [], W = m => warn.push(m);
const common = J(path.join(DATA, 'common.json')), WM = J(path.join(DATA, 'worldmap.json')).continents;
const COLORS = { warrior: '#C69B6D', paladin: '#F48CBA', hunter: '#AAD372', rogue: '#FFF468', priest: '#FFFFFF', shaman: '#0070DD', mage: '#3FC7EB', warlock: '#8788EE', druid: '#FF7C0A' };
const MAXL = common.maxLevel;

/* ---- classi + talent dal client ---- */
const talents = {}, classes = {};
for (const [k, cl] of dir('classes')) {
  const wf = J(path.join(DATA, 'talents', k + '.json'));
  const byName = {};
  wf.trees.forEach((t, ti) => Object.entries(t.nodes).forEach(([nk, n]) => (byName[n.name.toLowerCase()] = byName[n.name.toLowerCase()] || []).push({ key: t.key + '/' + nk, ti, n })));
  // l'albero della spec = quello con più punti nella build fino al livello massimo
  const cnt = [0, 0, 0];
  cl.build.slice(0, MAXL - 9).forEach(nm => { const c = byName[nm.toLowerCase()]; if (c) cnt[c[0].ti]++; });
  const treeIndex = cnt.indexOf(Math.max(...cnt));
  const used = {}, build = [], ranks = {};
  cl.build.forEach((nm, i) => {
    const c = byName[nm.toLowerCase()];
    if (!c) return W(`${k}: talent "${nm}" (liv. ${10 + i}) non esiste nel client`);
    const t = c.find(x => x.ti === treeIndex) || c[0];
    ranks[t.key] = (ranks[t.key] || 0) + 1;
    if (ranks[t.key] > t.n.max) W(`${k}: "${nm}" oltre il rank massimo al liv. ${10 + i}`);
    const spent = build.filter(b => b.split('/')[0] === t.key.split('/')[0]).length;
    if (spent < t.n.needs) W(`${k}: "${nm}" al liv. ${10 + i} richiede ${t.n.needs} punti nell'albero (ne hai ${spent})`);
    used[t.key] = [t.n.name, t.n.icon, t.n.max, t.n.rmax, t.n.flag];
    build.push(t.key);
  });
  talents[k] = { trees: wf.trees.map(t => [t.key, t.name, Object.entries(t.nodes).sort((a, b) => a[1].index - b[1].index).map(e => e[0])]), n: used };
  const src = s => Array.isArray(s) ? s : [s.name + (s.author && !s.name.includes(s.author) ? ' (' + s.author + ')' : ''), s.url, [s.date, s.signal].filter(Boolean).join(' · '), s.used];
  const chips = (cl.chips || cl.talentSpells.filter(x => x[0] <= MAXL && !/non in build/i.test(x[1])).slice(0, 2).map(x => [x[2], x[1].replace(/ \(talent\)/i, '') + ' al ' + x[0]]));
  const races = {}; Object.entries(cl.races || {}).forEach(([rk, v]) => { const n = rk.toLowerCase().replace(/[^a-z_]/g, '').replace(/^skyborne_?(alliance|a)$/, 'skyborne_a').replace(/^skyborne_?(horde|h)$/, 'skyborne_h'); if (n === 'skyborne') { races.skyborne_a = races.skyborne_h = v; } else races[n] = v; });
  classes[k] = Object.assign({}, cl, { build, treeIndex, color: cl.color || COLORS[k], chips, sources: cl.sources.map(src), milestones: cl.milestones || {}, talentSpells: cl.talentSpells || [], rotNotes: cl.rotNotes || [], alternatives: cl.alternatives || [], compare: cl.compare || [], races, camp: (cl.camp || []).filter(c => !/non trovat/i.test(c[0])) });
  ['buildSource', 'doubts', 'class'].forEach(x => delete classes[k][x]);
  if (build.length < MAXL - 9) W(`${k}: build corta (${build.length} punti)`);
}

/* ---- luoghi: nome → [continente, x, y] ---- */
const placeIdx = [];
for (const [c, M] of Object.entries(WM)) {
  M.places.forEach(p => placeIdx.push({ n: p[0].toLowerCase(), c, x: p[3], y: p[4], kind: p[1] }));
  M.zones.forEach(z => placeIdx.push({ n: z[0].toLowerCase(), c, x: z[2], y: z[3], kind: 'zone' }));
}
const norm = s => (s || '').toLowerCase().replace(/[’']/g, "'").trim();
function findPlace(name, pref) {
  const n = norm(name); if (!n) return null;
  const all = placeIdx.filter(p => p.n === n), part = placeIdx.filter(p => p.n.includes(n) || n.includes(p.n));
  const pick = a => a.find(p => p.c === pref) || a[0];
  return pick(all) || pick(part.sort((a, b) => b.n.length - a.n.length)) || null;
}
const nearestPlace = (M, x, y) => M.places.filter(p => p[1] !== 'landmark').reduce((b, p) => { const d = Math.hypot(p[3] - x, p[4] - y); return d < b[1] ? [p[0], d] : b; }, ['', 1e9])[0];
WM && Object.values(WM).forEach(M => M.fp.forEach(f => f[4] = nearestPlace(M, f[2], f[3])));

/* ---- fazioni: razze + rotte ---- */
const races = {}, routes = {}, factions = {}, usedPlaces = new Set();
const RKEY = (k, f) => { k = k.toLowerCase().replace(/[^a-z]/g, ''); if (k === 'nightelf') return 'nightelf'; if (k.startsWith('skyborne')) return 'skyborne_' + f.toLowerCase(); return k; };
for (const [fk, F] of dir('factions')) {
  const f = F.faction, side = f === 'A' ? 1 : 2;
  for (const [rk, r] of Object.entries(F.races)) races[RKEY(rk, f)] = { name: r.name, faction: f, start: r.start, icon: r.icon, classes: r.classes, racials: r.racials || [], tips: r.tips || '' };
  for (const [key, R] of Object.entries(F.routes)) {
    const cont0 = R.continent;
    const steps = R.steps.map(s => {
      const p = findPlace(s.town, cont0) || findPlace(s.zone, cont0);
      if (!p) { W(`${key}: città "${s.town}" non trovata sulla mappa`); return null; }
      if (p.kind !== 'zone') usedPlaces.add(p.c + '|' + p.n);
      return [s.title, s.levels, p.x, p.y, s.zoom || 4.75, s.zoneIcon, s.text, s.fp || '', p.c];
    }).filter(Boolean);
    const quests = (R.questNPCs || []).map(q => {
      for (const [c, M] of Object.entries(WM)) { const npcs = M.quests.concat(M.inn, M.fp, ...Object.values(M.trainers)); const m = npcs.filter(x => norm(x[0]) === norm(q.npc)); const hit = m.find(x => x[1] === side || !x[1]) || m[0]; if (hit) return [q.npc, q.text, hit[2], hit[3], c]; }
      W(`${key}: NPC "${q.npc}" non trovato tra i quest giver`); return null;
    }).filter(Boolean);
    const fpNames = [];
    (R.flights || []).forEach(fl => { let hit = null; for (const M of Object.values(WM)) { hit = M.fp.find(x => (x[1] === side || !x[1]) && (norm(x[0]) === norm(fl.master) || (norm(x[4]).includes(norm(fl.name)) || norm(fl.name).includes(norm(x[4])) && x[4]))); if (hit) break; }
      if (hit) fpNames.push(hit[0]); else W(`${key}: flight path "${fl.name}" non trovato`); });
    const zoneNames = new Set(); Object.values(WM).forEach(M => M.zones.forEach(z => { if (R.segments.some(s => (s.zone + ' ' + s.hub).includes(z[0])) || R.steps.some(s => (s.zone || '').includes(z[0]))) zoneNames.add(z[0]); }));
    const s0 = steps[0], c0 = Math.floor(s0[2] / 1024), r0 = Math.floor(s0[3] / 1024), hero = [];
    for (let rr = r0 - 1; rr <= r0; rr++) for (let cc = c0 - 1; cc <= c0 + 2; cc++) hero.push(`https://wow.zamimg.com/images/wow/classicplus/world-map/v3/${s0[8]}/5/${rr}/${cc}.webp`);
    routes[key] = { name: R.name, icon: s0[5], segments: R.segments.map(s => [s.from, s.to, s.zone, s.hub, s.note]), steps, quests, fpNames, zones: [...zoneNames], hero,
      milestones: R.milestones || {}, bags: R.bags || [], flights: R.flights || [], transport: R.transport || [] };
    const last = R.segments[R.segments.length - 1]; if (!last || last.to < MAXL) W(`${key}: la rotta non arriva al ${MAXL}`);
  }
  const src = s => Array.isArray(s) ? s : [s.name, s.url, [s.date, s.signal].filter(Boolean).join(' · '), s.used];
  factions[f] = { dungeons: F.dungeons || [], sources: (F.sources || []).map(src), transport: F.transport || [], crates: F.crates || '', milestones: F.milestones || {} };
}
for (const [rk, r] of Object.entries(races)) {
  if (!routes[r.start]) W(`razza ${rk}: rotta "${r.start}" mancante`);
  r.classes.forEach(c => { if (!classes[c]) W(`classe ${c} (${rk}) senza dati: comparirà "in arrivo"`); });
}

/* ---- mappa ridotta a ciò che serve ---- */
const map = {};
for (const [c, M] of Object.entries(WM)) {
  map[c] = { w: M.w, h: M.h, zones: M.zones, places: M.places.filter(p => p[1] === 'capital' || p[1] === 'town' || usedPlaces.has(c + '|' + p[0].toLowerCase())).map(p => [p[0], p[3], p[4]]),
    fp: M.fp, dg: M.dg, trainers: M.trainers, inn: M.inn, boat: M.boat, flights: M.flights, ships: M.ships, nodes: M.nodes, pets: M.pets };
}

/* ---- scrittura ---- */
const DATAJS = JSON.stringify({ common, classes, talents, races, routes, factions, map });
let html = fs.readFileSync(path.join(SRC, 'template.html'), 'utf8');
html = html.replace('/*STYLE*/', () => fs.readFileSync(path.join(SRC, 'style.css'), 'utf8'))
  .replace('/*DATA*/', () => DATAJS.replace(/<\/script/gi, '<\\/script'))
  .replace('/*ENGINE*/', () => fs.readFileSync(path.join(SRC, 'engine.js'), 'utf8'));
fs.writeFileSync(OUT, html);

/* ---- riepilogo Markdown (stessi dati della pagina) ---- */
const strip = s => String(s || '').replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();
const grp = b => { const g = []; b.slice(0, MAXL - 9).forEach((k, i) => { const l = g[g.length - 1]; if (l && l.k === k) { l.to = 10 + i; l.n++; } else g.push({ k, from: 10 + i, to: 10 + i, n: 1 }); }); return g; };
let md = `# WoW Forever – Leveling Companion 1–${MAXL} (${common.version})\n\n> Aggiornato: **${common.updated}**. Riepilogo della pagina \`WoW_Forever_Leveling_Companion.html\` (aprila per mappa, calcolatore talent e planner per livello).\n> Lancio: ${common.launchText}. Legenda: ✔ confermato · 🟡 fonte singola · ★ novità di Forever.\n\n## Razze e classi\n| Razza | Fazione | Zona iniziale | Classi |\n|---|---|---|---|\n`;
for (const r of Object.values(races)) md += `| ${r.name} | ${r.faction === 'A' ? 'Alleanza' : 'Orda'} | ${routes[r.start] ? routes[r.start].name : r.start} | ${r.classes.map(c => classes[c] ? classes[c].name : c + ' (in arrivo)').join(', ')} |\n`;
md += `\n## Build per classe (talent point 10–${MAXL})\n`;
for (const [k, c] of Object.entries(classes)) {
  const t = talents[k].n, cnt = {};
  md += `\n### ${c.name} – ${c.spec}\n${strip(c.summary)}\n\n` + grp(c.build).map(x => { cnt[x.k] = (cnt[x.k] || 0) + x.n; return `- ${x.from === x.to ? x.from : x.from + '–' + x.to}: ${t[x.k][0]} ${cnt[x.k]}/${t[x.k][2]}`; }).join('\n') + '\n';
}
md += `\n## Rotte per zona iniziale\n`;
for (const r of Object.values(routes)) md += `\n### ${r.name}\n| Livelli | Zona | Hub | Note |\n|---|---|---|---|\n` + r.segments.map(s => `| ${s[0]}–${s[1]} | ${s[2]} | ${s[3]} | ${strip(s[4])} |`).join('\n') + '\n';
md += `\n## Fonti principali\n` + [...new Set(Object.values(classes).flatMap(c => c.sources.slice(0, 3)).concat(common.sources).map(s => `- [${strip(s[0])}](${s[1]}) · ${strip(s[2])}`))].join('\n') + `\n\n${strip(common.limits)}\n`;
fs.writeFileSync(OUT.replace(/\.html$/, '.md'), md);
console.log(path.basename(OUT), (html.length / 1024).toFixed(0) + ' KB · classi:', Object.keys(classes).join(', '), '· razze:', Object.keys(races).length, '· rotte:', Object.keys(routes).join(', '));
if (warn.length) console.log('\nDa controllare (' + warn.length + '):\n- ' + warn.join('\n- '));
