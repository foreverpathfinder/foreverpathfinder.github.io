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
// Tutte le coordinate diventano globali (tela del mondo di Wowhead): i 3 continenti stanno sulla stessa mappa.
for (const M of Object.values(WM)) {
  const g = (a, i) => { a[i] += M.ox; a[i + 1] += M.oy; };
  M.zones.forEach(z => g(z, 2)); M.places.forEach(p => g(p, 3)); M.fp.forEach(p => g(p, 2)); M.dg.forEach(p => g(p, 2));
  Object.values(M.trainers).forEach(a => a.forEach(p => g(p, 2))); Object.values(M.prof).forEach(a => a.forEach(p => g(p, 2))); M.inn.forEach(p => g(p, 2)); M.boat.forEach(p => g(p, 3));
  M.quests.forEach(p => g(p, 2)); M.pets.forEach(p => g(p, 3));
  M.flights.forEach(r => r[1].forEach(p => g(p, 0))); M.ships.forEach(r => r[1].forEach(p => g(p, 0)));
  Object.values(M.nodes).forEach(a => { for (let i = 0; i < a.length; i += 2) g(a, i); });
}

/* ---- NPC → posizione (quest giver, trainer, innkeeper, flight master) e milestone normalizzate ---- */
const NPCS = []; for (const M of Object.values(WM)) NPCS.push(...M.quests, ...M.inn, ...M.fp, ...Object.values(M.trainers).flat(), ...Object.values(M.prof).flat());
const RN = k => { k = String(k).toLowerCase().replace(/[^a-z_]/g, ''); return k === 'skyborne_alliance' || k === 'skyborne_high_order' ? 'skyborne_a' : k === 'skyborne_horde' || k === 'skyborne_windshaper' || k === 'skyborne_windshapers' ? 'skyborne_h' : k; };
const RFAC = { human: 1, dwarf: 1, gnome: 1, nightelf: 1, skyborne_a: 1, orc: 2, undead: 2, troll: 2, tauren: 2, skyborne_h: 2 };
function npcPos(name, side) { const n = String(name).toLowerCase().trim(), m = NPCS.filter(x => x[0].toLowerCase() === n); return m.find(x => !side || x[1] === side || !x[1]) || m[0]; }
// milestones: { "10": ["testo" | {t,r,f,npc}] } oppure [ {l,t,r,f,npc} ] → { 10: [{t, r?, f?, n?:[[npc,x,y]]}] }
function normMs(ms, side0, ctx) {
  const out = {}, add = (l, x) => {
    const o = typeof x === 'string' ? { t: x } : { t: x.t };
    if (x.r && x.r.length) o.r = x.r.map(RN);
    if (x.f) o.f = x.f;
    const side = x.f ? (x.f === 'A' ? 1 : 2) : o.r ? RFAC[o.r[0]] : side0;
    if (x.npc && x.npc.length) o.n = x.npc.map(n => { const p = npcPos(n, side); if (!p) { W(ctx + ': NPC "' + n + '" (liv. ' + l + ') non trovato sulla mappa'); return null; } return [n, p[2], p[3]]; }).filter(Boolean);
    if (!o.t) return; (out[l] = out[l] || []).push(o);
  };
  if (Array.isArray(ms)) ms.forEach(m => add(+m.l, m)); else Object.entries(ms || {}).forEach(([l, a]) => a.forEach(x => add(+l, x)));
  return out;
}

/* ---- classi + talent dal client ---- */
const talents = {}, classes = {};
for (const [k, cl] of dir('classes')) {
  const wf = J(path.join(DATA, 'talents', k + '.json'));
  const byName = {};
  wf.trees.forEach((t, ti) => Object.entries(t.nodes).forEach(([nk, n]) => (byName[n.name.toLowerCase()] = byName[n.name.toLowerCase()] || []).push({ key: t.key + '/' + nk, ti, n })));
  const used = {};
  // nomi dei talent (1 per livello dal 10) → chiavi del client; l'albero della spec = quello con più punti fino al livello massimo
  function resolve(names, ctx) {
    const cnt = [0, 0, 0];
    names.slice(0, MAXL - 9).forEach(nm => { const c = byName[String(nm).toLowerCase()]; if (c) cnt[c[0].ti]++; });
    const treeIndex = cnt.indexOf(Math.max(...cnt)), build = [], ranks = {};
    names.forEach((nm, i) => {
      const c = byName[String(nm).toLowerCase()];
      if (!c) return W(`${ctx}: talent "${nm}" (liv. ${10 + i}) non esiste nel client`);
      const t = c.find(x => x.ti === treeIndex) || c[0];
      ranks[t.key] = (ranks[t.key] || 0) + 1;
      if (ranks[t.key] > t.n.max) W(`${ctx}: "${nm}" oltre il rank massimo al liv. ${10 + i}`);
      const spent = build.filter(b => b.split('/')[0] === t.key.split('/')[0]).length;
      if (spent < t.n.needs) W(`${ctx}: "${nm}" al liv. ${10 + i} richiede ${t.n.needs} punti nell'albero (ne hai ${spent})`);
      used[t.key] = [t.n.name, t.n.icon, t.n.max, t.n.rmax, t.n.flag];
      build.push(t.key);
    });
    return { build, treeIndex };
  }
  const { build, treeIndex } = resolve(cl.build, k);
  // build A/B/C: A = quella principale; B e C con il loro ordine (se manca, ereditano quello di A)
  const srcB = s => Array.isArray(s) ? s : [s.name, s.url, [s.date, s.signal].filter(Boolean).join(' · '), s.used];
  const builds = (cl.builds && cl.builds.length ? cl.builds : [{ id: 'a', name: cl.spec }]).map((b, i) => {
    const o = Object.assign({}, b, { id: b.id || 'abc'[i], sources: (b.sources || []).map(srcB) });
    if (i && b.build && b.build.length) Object.assign(o, resolve(b.build, k + ' build ' + o.id)); else { o.build = []; delete o.treeIndex; }
    if (i && o.build.length && o.build.length < MAXL - 9) W(`${k} build ${o.id}: ordine corto (${o.build.length} punti)`);
    return o;
  });
  talents[k] = { trees: wf.trees.map(t => [t.key, t.name, Object.entries(t.nodes).sort((a, b) => a[1].index - b[1].index).map(e => e[0])]), n: used };
  const src = s => Array.isArray(s) ? s : [s.name + (s.author && !s.name.includes(s.author) ? ' (' + s.author + ')' : ''), s.url, [s.date, s.signal].filter(Boolean).join(' · '), s.used];
  const chips = (cl.chips || cl.talentSpells.filter(x => x[0] <= MAXL && !/non in build/i.test(x[1])).slice(0, 2).map(x => [x[2], x[1].replace(/ \(talent\)/i, '') + ' al ' + x[0]]));
  const races = {}; Object.entries(cl.races || {}).forEach(([rk, v]) => { const n = rk.toLowerCase().replace(/[^a-z_]/g, '').replace(/^skyborne_?(alliance|a)$/, 'skyborne_a').replace(/^skyborne_?(horde|h)$/, 'skyborne_h'); if (n === 'skyborne') { races.skyborne_a = races.skyborne_h = v; } else races[n] = v; });
  classes[k] = Object.assign({}, cl, { build, treeIndex, builds, color: cl.color || COLORS[k], chips, sources: cl.sources.map(src), milestones: normMs(cl.milestones, 0, k), talentSpells: cl.talentSpells || [], rotNotes: cl.rotNotes || [], alternatives: cl.alternatives || [], compare: cl.compare || [], races, camp: (cl.camp || []).filter(c => !/non trovat/i.test(c[0])) });
  ['buildSource', 'doubts', 'class'].forEach(x => delete classes[k][x]);
  if (build.length < MAXL - 9) W(`${k}: build corta (${build.length} punti)`);
}

/* ---- luoghi: nome → [continente, x, y] ---- */
const placeIdx = [];
for (const [c, M] of Object.entries(WM)) {
  M.places.forEach(p => placeIdx.push({ n: p[0].toLowerCase(), c, x: p[3], y: p[4], kind: p[1] }));
  M.zones.forEach(z => placeIdx.push({ n: z[0].toLowerCase(), c, x: z[2], y: z[3], kind: 'zone' }));
}
const lv0r = s => parseInt(s) || 0;
const txtOnly = h => String(h).replace(/<[^>]+>/g, '').slice(0, 140);
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
    const msNpc = normMs(R.milestones, side, key); Object.entries(msNpc).forEach(([l, a]) => a.forEach(m => (m.n || []).forEach(n => { if (!quests.some(q => q[0] === n[0])) quests.push([n[0], txtOnly(m.t), n[1], n[2], '']); })));
    const fpNames = [];
    (R.flights || []).forEach(fl => { let hit = null; for (const M of Object.values(WM)) { hit = M.fp.find(x => (x[1] === side || !x[1]) && (norm(x[0]) === norm(fl.master) || (norm(x[4]).includes(norm(fl.name)) || norm(fl.name).includes(norm(x[4])) && x[4]))); if (hit) break; }
      if (hit) fpNames.push(hit[0]); else W(`${key}: flight path "${fl.name}" non trovato`); });
    const zoneNames = new Set(); Object.values(WM).forEach(M => M.zones.forEach(z => { if (R.segments.some(s => (s.zone + ' ' + s.hub).includes(z[0])) || R.steps.some(s => (s.zone || '').includes(z[0]))) zoneNames.add(z[0]); }));
    const s0 = steps[0], c0 = Math.floor((s0[2] - WM[s0[8]].ox) / 1024), r0 = Math.floor((s0[3] - WM[s0[8]].oy) / 1024), hero = [];
    for (let rr = r0 - 1; rr <= r0; rr++) for (let cc = c0 - 1; cc <= c0 + 2; cc++) { const T = WM[s0[8]].tiles['5'][rr]; if (T && T.some(a => cc >= a[0] && cc <= a[1])) hero.push(`https://wow.zamimg.com/images/wow/classicplus/world-map/v3/${s0[8]}/5/${rr}/${cc}.webp`); else hero.push('data:image/gif;base64,R0lGODlhAQABAIAAAAgSHQAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=='); }
    routes[key] = { name: R.name, icon: s0[5], trunk: steps[steps.length - 1][8], junction: 0, segments: R.segments.map(s => [s.from, s.to, s.zone, s.hub, s.note]), steps, quests, fpNames, zones: [...zoneNames], hero,
      milestones: normMs(R.milestones, side, key), bags: R.bags || [], flights: R.flights || [], transport: R.transport || [] };
    const last = R.segments[R.segments.length - 1]; if (!last || last.to < MAXL) W(`${key}: la rotta non arriva al ${MAXL}`);
  }
  const src = s => Array.isArray(s) ? s : [s.name, s.url, [s.date, s.signal].filter(Boolean).join(' · '), s.used];
  factions[f] = { dungeons: F.dungeons || [], sources: (F.sources || []).map(src), transport: F.transport || [], crates: F.crates || '', milestones: normMs(F.milestones, side, fk) };
}
for (const [rk, r] of Object.entries(races)) {
  if (!routes[r.start]) W(`razza ${rk}: rotta "${r.start}" mancante`);
  r.classes.forEach(c => { if (!classes[c]) W(`classe ${c} (${rk}) senza dati: comparirà "in arrivo"`); });
}

/* ---- cambi di continente (data/transfers.json) e guida professioni/alt (data/profs.json) ---- */
const opt = f => fs.existsSync(path.join(DATA, f)) ? J(path.join(DATA, f)) : null;
const srcRow = s => Array.isArray(s) ? s : [s.name, s.url, [s.date, s.signal].filter(Boolean).join(' · '), s.used];
const transfers = {}, TF = opt('transfers.json');
if (TF) {
  Object.entries(TF.junctions || {}).forEach(([k, v]) => { if (routes[k]) routes[k].junction = v; });
  for (const [k, t] of Object.entries(TF.transfers || {})) {
    const steps = (t.steps || []).map(s => { const p = findPlace(s.town) || findPlace(s.zone); if (!p) { W(`cambio ${k}: città "${s.town}" non trovata`); return null; }
      if (p.kind !== 'zone') usedPlaces.add(p.c + '|' + p.n); return [s.title, s.levels, p.x, p.y, s.zoom || 4.75, s.zoneIcon, s.text, s.fp || '', p.c]; }).filter(Boolean);
    if (!routes[t.joinRoute]) W(`cambio ${k}: rotta "${t.joinRoute}" inesistente`);
    transfers[k] = { title: t.title, when: t.when, joinRoute: t.joinRoute, joinLevel: t.joinLevel, steps, unlocks: t.unlocks || [], quests: t.quests || [], pros: t.pros || '', cons: t.cons || '' };
  }
  common.sources = common.sources.concat((TF.sources || []).map(srcRow));
}
const profs = opt('profs.json'), alts = opt('alts.json'), dungeons = opt('dungeons.json');
if (dungeons) delete dungeons._;
// punto in mappa per ogni quest dei dungeon: chi la dà (NPC della mappa) o, se non c'è, la zona citata; "dentro il dungeon" usa l'ingresso
if (dungeons) { const ZN = Object.values(WM).flatMap(M => M.zones);
  for (const x of Object.values(dungeons.dungeons)) { x.qp = {};
    for (const q of Object.values(x.q || {}).flat()) { const w = q[q.length - 1], who = w.split(",")[0].trim(), n = NPCS.find(p => norm(p[0]) === norm(who));
      if (n) { x.qp[q[0]] = [n[2], n[3], n[0]]; continue; }
      if (/dentro|nel dungeon|ingresso|caveau|cimitero|drop dai|drop di (The Baron|Relic Guardian)|Image of Archmage Modera/i.test(w)) { x.qp[q[0]] = 0; continue; }
      const z = ZN.filter(z => w.includes(z[0])).sort((a, b) => b[0].length - a[0].length)[0]; if (z) x.qp[q[0]] = [z[2], z[3], z[0]]; } } }
if (alts) alts.sources = (alts.sources || []).map(srcRow);
if (profs) profs.sources = (profs.sources || []).map(srcRow);

/* ---- mappa ridotta a ciò che serve ---- */
const map = { conts: {}, zones: [], places: [], fp: [], dg: [], trainers: {}, prof: {}, inn: [], boat: [], flights: [], ships: [], nodes: {}, pets: [] };
for (const [c, M] of Object.entries(WM)) {
  map.conts[c] = { ox: M.ox, oy: M.oy, w: M.w, h: M.h, tiles: M.tiles };
  map.zones.push(...M.zones);
  map.places.push(...M.places.filter(p => p[1] === 'capital' || p[1] === 'town' || usedPlaces.has(c + '|' + p[0].toLowerCase())).map(p => [p[0], p[3], p[4], p[1] === 'capital' ? 1 : 0]));
  ['fp', 'dg', 'inn', 'boat', 'flights', 'ships', 'pets'].forEach(k => map[k].push(...M[k]));
  Object.entries(M.trainers).forEach(([k, a]) => (map.trainers[k] = map.trainers[k] || []).push(...a));
  Object.entries(M.prof).forEach(([k, a]) => (map.prof[k] = map.prof[k] || []).push(...a));
  Object.entries(M.nodes).forEach(([k, a]) => (map.nodes[k] = map.nodes[k] || []).push(...a));
}

/* ---- controllo quest: ogni <b>/<i> citato che sembra una quest deve esistere in Forever (data/quests.txt, da tools/quests.js) ---- */
const QF = path.join(DATA, 'quests.txt'), report = [];
if (fs.existsSync(QF)) {
  const Q = {}; fs.readFileSync(QF, 'utf8').split('\n').forEach(l => { const p = l.split(' | '); if (p[0]) (Q[p[0].toLowerCase()] = Q[p[0].toLowerCase()] || []).push(+p[1]); });
  const known = new Set(); // nomi che non sono quest: talent, spell, zone, città, NPC, item noti
  Object.values(talents).forEach(t => Object.values(t.n).forEach(n => known.add(n[0].toLowerCase())));
  Object.values(classes).forEach(c => (c.spells || []).concat(c.talentSpells || []).forEach(x => known.add(String(x[1]).toLowerCase())));
  placeIdx.forEach(p => known.add(p.n)); NPCS.forEach(n => known.add(n[0].toLowerCase()));
  Object.values(factions).forEach(F => F.dungeons.forEach(d => known.add(d[0].replace(/[★✔🟡]/g, '').trim().toLowerCase()))); known.add('hearthstone');
  let ok = 0;
  const check = (t, l, ctx) => (String(t).match(/<(b|i)>([^<]{4,60})<\/\1>/g) || []).forEach(m => {
    const n = m.replace(/<[^>]+>/g, '').replace(/[:.]$/, '').trim(), k = n.toLowerCase();
    if (known.has(k)) return; // spell, talent, zona, NPC o dungeon con lo stesso nome di una quest
    if (Q[k]) { ok++; if (l && Math.min(...Q[k].map(q => Math.abs(q - l))) > 6) report.push(`${ctx} liv. ${l}: "${n}" in Forever è di livello ${Q[k].join('/')}`); return; }
    if (/🟡/.test(t) || /Flight Path|Lettera|Escort|Skycutter|Ammo/.test(n) || !/^[A-Z][\w'’!-]*( [\w'’!:-]+){0,6}$/.test(n) || /\d|Bag|Wand|Totem$|Form$|slot|Trainer/.test(n)) return;
    report.push(`${ctx} liv. ${l || '-'}: "${n}" non è una quest di Forever (o è un item/spell): controlla`);
  });
  Object.entries(classes).forEach(([k, c]) => Object.entries(c.milestones).forEach(([l, a]) => a.forEach(m => check(m.t, +l, k))));
  Object.entries(routes).forEach(([k, r]) => { Object.entries(r.milestones).forEach(([l, a]) => a.forEach(m => check(m.t, +l, k))); r.steps.forEach(st => check(st[6], lv0r(st[1]), k)); });
  fs.writeFileSync(path.join(SRC, 'check-report.txt'), report.join('\n'));
  console.log('Quest verificate sull\'indice di Forever:', ok, '· da controllare:', report.length, '(src/check-report.txt)');
}

/* ---- scrittura: pagina italiana (sorgente) e inglese ---- */
// src/i18n/en.json = { "testo italiano dei dati": "inglese" } · en-ui.json = [["italiano", "inglese"]] sostituiti in template.html ed engine.js
const ALL = { common, classes, talents, races, routes, factions, transfers, profs, alts, dungeons, map };
const I18N = path.join(SRC, 'i18n'), EN = J(path.join(I18N, 'en.json')), ENUI = J(path.join(I18N, 'en-ui.json')).sort((a, b) => b[0].length - a[0].length);
const page = (data, tpl, eng) => tpl.replace('/*STYLE*/', () => fs.readFileSync(path.join(SRC, 'style.css'), 'utf8'))
  .replace('/*DATA*/', () => JSON.stringify(data).replace(/<\/script/gi, '<\\/script'))
  .replace('/*ENGINE*/', () => eng);
const TPL = fs.readFileSync(path.join(SRC, 'template.html'), 'utf8'), ENG = fs.readFileSync(path.join(SRC, 'engine.js'), 'utf8');
const html = page(ALL, TPL, ENG);
fs.writeFileSync(OUT, html);
// inglese: ogni testo dei dati con uno spazio deve avere la sua traduzione (talent e mappa sono già i nomi del client)
const miss = new Set(), tr = v => typeof v === 'string' ? (v in EN ? EN[v] : (/\s/.test(v) && /[a-z]/i.test(v) && !/^https?:\S+$/.test(v) && miss.add(v), v))
  : Array.isArray(v) ? v.map(tr) : v && typeof v === 'object' ? Object.fromEntries(Object.entries(v).map(([k, x]) => [k, tr(x)])) : v;
const DATA_EN = Object.fromEntries(Object.entries(ALL).map(([k, v]) => [k, k === 'talents' || k === 'map' ? v : tr(v)]));
let tplEn = TPL, engEn = ENG;
ENUI.forEach(([a, b]) => { if (!tplEn.includes(a) && !engEn.includes(a)) W('en-ui: "' + a + '" non trovato'); tplEn = tplEn.split(a).join(b); engEn = engEn.split(a).join(b); });
fs.writeFileSync(OUT.replace(/\.html$/, '_EN.html'), page(DATA_EN, tplEn, engEn));
fs.writeFileSync(path.join(I18N, 'missing-en.json'), JSON.stringify([...miss], null, 1));
if (miss.size) W(miss.size + ' testi senza traduzione inglese → src/i18n/missing-en.json');

/* ---- riepilogo Markdown (stessi dati della pagina) ---- */
const strip = s => String(s || '').replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();
const grp = b => { const g = []; b.slice(0, MAXL - 9).forEach((k, i) => { const l = g[g.length - 1]; if (l && l.k === k) { l.to = 10 + i; l.n++; } else g.push({ k, from: 10 + i, to: 10 + i, n: 1 }); }); return g; };
let md = `# Forever Pathfinder – WoW: Forever leveling 1–${MAXL} (${common.version})\n\n> Aggiornato: **${common.updated}**. Riepilogo della pagina \`WoW_Forever_Leveling_Companion.html\` (aprila per mappa, calcolatore talent e planner per livello).\n> Lancio: ${common.launchText}. Legenda: ✔ confermato · 🟡 fonte singola · ★ novità di Forever.\n\n## Razze e classi\n| Razza | Fazione | Zona iniziale | Classi |\n|---|---|---|---|\n`;
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
