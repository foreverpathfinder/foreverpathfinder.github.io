// Quest dei dungeon 35–60 (e controllo degli altri) da qdq.json: solo quelle date da un NPC, niente Season of Discovery,
// eventi, catene del livello 60 (tier 0.5, Lunar Festival) e passi intermedi (resta l'ultima quest di ogni catena).
// node dg35.js        → stampa   ·   node dg35.js scrivi → aggiorna dungeons.json ed en.json
const fs = require('fs'), D = __dirname + '/', ROOT = 'C:/Users/damia/Desktop/CLAUDE/WoW Forever leveling companion/';
const db = JSON.parse(fs.readFileSync(D + 'qdq.json', 'utf8')), Q = JSON.parse(fs.readFileSync(D + 'qall.json', 'utf8')), N = JSON.parse(fs.readFileSync(D + 'npc.json', 'utf8'));
const KEYS = ['drowned city', 'uldaman', 'razorfen downs', "krol'dok stronghold", "zul'farrak", 'maraudon', 'alcaz prison', "temple of atal'hakkar", 'blackrock depths', 'blackrock spire', 'blackmaw hold', 'dire maul', 'scholomance', 'stratholme'];
const DNAME = { 'drowned city': /drowned city/i, uldaman: /uldaman/i, 'razorfen downs': /razorfen downs/i, "krol'dok stronghold": /krol.?dok/i, "zul'farrak": /zul.?farrak/i, maraudon: /maraudon/i, 'alcaz prison': /alcaz/i,
  "temple of atal'hakkar": /atal.?hakkar|sunken temple/i, 'blackrock depths': /blackrock depths/i, 'blackrock spire': /blackrock spire/i, 'blackmaw hold': /blackmaw/i, 'dire maul': /dire maul/i, scholomance: /scholomance/i, stratholme: /stratholme/i };
const BAD = /[<>]|UNUSED|Elder$|the Elder|Fortune Awaits|Anthion|Valthalak|^The Challenge$|Favor Amongst the Brotherhood|Bodley|I See Alcaz Island|^Libram of|Dreadsteed|Xoroth|Arcanite Barding|Ancient Equine|Mea Culpa|Eranikus, Tyrant/;
const A = 77 + 2 ** 32, H = 178 + 2 ** 33;
const NAMES = { ALL_ALLIANCE: 'A', ALL_HORDE: 'H', NONE: 'N' };
const sideOf = (id) => { const q = Q[id], r = q.r;
  if (typeof r === 'number' && r !== 0) { const lo = r % 2 ** 32, a = (lo & 77) || Math.floor(r / 2 ** 32) % 2, h = (lo & 178) || Math.floor(r / 2 ** 33) % 2; return a && h ? 'N' : a ? 'A' : 'H'; }
  if (typeof r === 'string' && NAMES[r.replace('raceIDs.', '')] && r !== 'raceIDs.NONE') return NAMES[r.replace('raceIDs.', '')];
  const f = [...new Set(q.by.map(n => (N[n] || [])[2] || '').filter(Boolean))];
  if (!f.length || f.includes('AH') || (f.includes('A') && f.includes('H'))) return 'N'; return f[0]; };
const title = s => s.toLowerCase().replace(/_/g, ' ').replace(/\b[a-z]/g, c => c.toUpperCase()).replace(/ Of /g, ' of ').replace(/ The /g, ' the ');
const zoneTxt = z => !z ? '' : /^zona zoneIDs\./.test(z) ? title(z.replace('zona zoneIDs.', '')) : /^zona /.test(z) ? '' : z.replace(/ -> .*/, '');
const out = {};
for (const k of KEYS) {
  const list = (db[k] || []).filter(x => !x.missing && !(x.id >= 77000 && x.id < 92000) && !BAD.test(x.name) && Q[x.id] && Q[x.id].by.length && !Q[x.id].c && !(typeof Q[x.id].sp === 'number' && Q[x.id].sp % 2));
  const ids = new Set(list.map(x => x.id)), isPre = new Set();
  for (const x of list) for (const p of Q[x.id].pre) if (ids.has(p)) isPre.add(p);
  const o = { A: [], H: [], N: [] }, seen = {};
  for (const x of list.sort((a, b) => a.lv - b.lv)) {
    if (isPre.has(x.id)) continue;
    const q = Q[x.id], s = sideOf(x.id), npc = N[q.by[0]] || ['?', ''], z = zoneTxt(npc[1]);
    const inside = DNAME[k].test(z) || /Referenced dungeon area/.test(z);
    const pre = q.pre.map(p => Q[p] && Q[p].n).filter(Boolean)[0];
    const where = [npc[0] + (inside ? ', dentro il dungeon' : z ? ', ' + z : ''), pre && pre !== x.name ? 'dopo ' + pre : ''].filter(Boolean).join(', ');
    if (seen[s + x.name]) continue; seen[s + x.name] = 1;
    o[s].push([x.name, where, x.lv]);
  }
  // stessa quest per le due fazioni con lo stesso NPC → una sola riga in N
  for (const a of o.A.slice()) { const h = o.H.find(y => y[0] === a[0] && y[1] === a[1]); if (h) { o.A.splice(o.A.indexOf(a), 1); o.H.splice(o.H.indexOf(h), 1); o.N.push(a); } }
  out[k] = o;
}
if (process.argv[2] !== 'scrivi') { for (const [k, o] of Object.entries(out)) { console.log('\n## ' + k + '  A ' + o.A.length + ' · H ' + o.H.length + ' · N ' + o.N.length); for (const f of 'AHN') for (const q of o[f]) console.log('  ' + f + ' L' + q[2] + ' ' + q[0] + ' — ' + q[1]); } process.exit(); }
const DF = ROOT + 'src/data/dungeons.json', EF = ROOT + 'src/i18n/en.json';
const d = JSON.parse(fs.readFileSync(DF, 'utf8')), E = JSON.parse(fs.readFileSync(EF, 'utf8'));
let n = 0;
for (const [k, o] of Object.entries(out)) {
  const x = d.dungeons[k] || (d.dungeons[k] = {}); x.q = {};
  for (const f of 'AHN') if (o[f].length) x.q[f] = o[f].map(q => { n++; const w = q[1]; E[w] = w.replace(', dentro il dungeon', ', inside the dungeon').replace(', dopo ', ', after '); if (/ /.test(q[0]) && E[q[0]] === undefined) E[q[0]] = q[0]; return [q[0], w]; });
}
fs.writeFileSync(DF, JSON.stringify(d, null, 1) + '\n'); fs.writeFileSync(EF, JSON.stringify(E, null, 1) + '\n');
console.log('scritte', n, 'quest in', Object.keys(out).length, 'dungeon');
