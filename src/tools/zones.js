// node src/tools/zones.js <cartella con qall.json> → src/data/zones.json: zone consigliate per razza e livello.
// qall.json = tutte le quest di Forever dal database di Questie (repo Questie/QuestieDB: data/Forever/forever*DB.lua +
// src/corrections/Forever/generated|traces + foreverQuestFixes.lua), unite da qdb.js (vedi AGGIORNARE.md).
// Per ogni zona della mappa (worldmap.json) conta le quest "adatte": che la razza può prendere, richieste ≤ livello,
// livello della quest tra L−3 e L+2. Le quest senza razze richieste valgono per la fazione a cui è amico chi le dà (molte quest
// nuove di Forever non hanno ancora le razze nel database). Le zone iniziali contano solo per le razze che ci nascono. Niente quest di classe, di profession, ripetibili o senza un NPC/oggetto che le dà.
const fs = require('fs'), path = require('path');
const dir = process.argv[2]; if (!dir) throw new Error('uso: node src/tools/zones.js <cartella con qall.json>');
const Q = JSON.parse(fs.readFileSync(path.join(dir, 'qall.json'), 'utf8')), ZN = JSON.parse(fs.readFileSync(path.join(dir, 'zn.json'), 'utf8')), NPC = JSON.parse(fs.readFileSync(path.join(dir, 'npc.json'), 'utf8'));
const WM = JSON.parse(fs.readFileSync(path.join(__dirname, '../data/worldmap.json'), 'utf8')).continents;
const RACES = { human: 1, orc: 2, dwarf: 4, nightelf: 8, undead: 16, tauren: 32, gnome: 64, troll: 128, skyborne_a: 2 ** 32, skyborne_h: 2 ** 33 };
const NAMES = { HUMAN: 1, ORC: 2, DWARF: 4, NIGHT_ELF: 8, UNDEAD: 16, TAUREN: 32, GNOME: 64, TROLL: 128, SKYBORNE_ALLIANCE: 2 ** 32, SKYBORNE_HORDE: 2 ** 33,
  ALL_ALLIANCE: 77 + 2 ** 32, ALL_HORDE: 178 + 2 ** 33, NONE: 0, ALL: 0 };
const mask = r => { if (r == null || r === 0) return 0; if (typeof r === 'number') return r;
  return String(r).split('+').reduce((s, t) => { const k = t.replace(/^raceIDs\./, '').trim(); if (!(k in NAMES)) throw new Error('razza ' + t); return s + NAMES[k]; }, 0); };
const has = (m, bit) => m === 0 || Math.floor(m / bit) % 2 === 1;
const SIDE = { A: 77 + 2 ** 32, H: 178 + 2 ** 33 };
const HOME = { 'Elwynn Forest': ['human'], 'Dun Morogh': ['dwarf', 'gnome'], Teldrassil: ['nightelf'], 'Zephras Isle': ['skyborne_a', 'skyborne_h'], Durotar: ['orc', 'troll'], Mulgore: ['tauren'], 'Tirisfal Glades': ['undead'] };
// quest senza razze: la fazione di chi la dà (NPC amico di A, H o entrambe)
const sideMask = q => { const f = [...new Set(q.by.map(n => (NPC[n] || [])[2] || '').filter(Boolean))]; if (!f.length || f.some(x => x === 'AH') || (f.includes('A') && f.includes('H'))) return 0; return SIDE[f[0]]; };
const norm = s => String(s).toLowerCase().replace(/[^a-z]/g, '');
const zones = []; // [nome, livelli, continente, x, y] con coordinate del continente (build.js le rende globali)
for (const [c, M] of Object.entries(WM)) for (const z of M.zones) zones.push([z[0], z[1], c, z[2], z[3]]);
const zi = {}; zones.forEach((z, i) => zi[norm(z[0])] = i);
const zoneOf = z => { if (z == null) return -1; const n = typeof z === 'number' ? ZN[z] : String(z).replace(/^zoneIDs\./, ''); const i = n == null ? undefined : zi[norm(n)]; return i === undefined ? -1 : i; };
const per = zones.map(() => []); // per zona: [maschera razze, livello, livello richiesto]
for (const [id, q] of Object.entries(Q)) {
  const i = zoneOf(q.z); if (i < 0) continue;
  if (+id >= 77000 && +id < 92000) continue; // quest di Season of Discovery rimaste nei dati del client (es. «Duskwood Mission»): in Forever non ci sono
  if (q.c || q.sk || (typeof q.sp === 'number' && q.sp % 2 === 1) || !(q.by.length || q.ob) || /[<>]|UNUSED|DEPRECATED|\bTEST\b/.test(q.n)) continue;
  if (!(q.lv >= 1 && q.lv <= 60)) continue;
  const m = mask(q.r); per[i].push([m === 0 ? sideMask(q) : m, q.lv, q.rq || 1]);
}
// zone senza livelli su Wowhead (es. Mount Hyjal): dai livelli delle loro quest
zones.forEach((z, i) => { if (!z[1] && per[i].length >= 5) { const l = per[i].map(x => x[1]).sort((a, b) => a - b); z[1] = l[Math.floor(l.length * 0.1)] + '–' + l[Math.floor(l.length * 0.9)]; } });
// ponytail: sotto il 20 le zone del continente dove nasce la razza contano doppio nell'ordine (il numero mostrato resta quello vero):
// un Human al 12 non attraversa il mare per Darkshore. Se servisse di più: distanza vera dalla tappa della rotta.
const CONT = { human: 'eastern-kingdoms', dwarf: 'eastern-kingdoms', gnome: 'eastern-kingdoms', undead: 'eastern-kingdoms', nightelf: 'kalimdor', orc: 'kalimdor', troll: 'kalimdor', tauren: 'kalimdor' };
// la zona conta solo se il livello sta nei suoi livelli (±1): niente Darkshore al 22 o Tanaris al 60 per qualche quest fuori fascia
const inRange = (z, L) => { const m = /(\d+)\D+(\d+)/.exec(z[1] || ''); return !m || (L >= (HOME[z[0]] ? 1 : +m[1] - 1) && L <= +m[2] + 1); }; // le zone iniziali valgono dal livello 1
const rec = {};
for (const [race, bit] of Object.entries(RACES)) {
  rec[race] = [];
  for (let L = 1; L <= 60; L++) {
    const sc = per.map((a, i) => [i, (HOME[zones[i][0]] && !HOME[zones[i][0]].includes(race)) || !inRange(zones[i], L) ? 0 : a.filter(x => has(x[0], bit) && x[2] <= L && x[1] >= L - 3 && x[1] <= L + 2).length]).filter(x => x[1] > 0).map(x => [x[0], x[1], x[1] * (L < 20 && zones[x[0]][2] === CONT[race] ? 2 : 1)]).sort((a, b) => b[2] - a[2]);
    const best = sc.length ? sc[0][2] : 0;
    rec[race].push(sc.filter(x => x[1] >= (L < 6 ? 1 : 4) && x[2] >= best * 0.4).slice(0, 3).map(x => [x[0], x[1]]));
  }
}
const out = { _: 'Generato da src/tools/zones.js: zone consigliate per razza e livello. zones = [nome, livelli, continente, x, y]; rec[razza][livello−1] = [[indice della zona, quest adatte], …] (al massimo 3).',
  source: 'Questie/QuestieDB (Forever) + Wowhead Forever (livelli e posizione delle zone)', fetched: new Date().toISOString().slice(0, 10), zones, rec };
fs.writeFileSync(path.join(__dirname, '../data/zones.json'), JSON.stringify(out) + '\n');
for (const r of ['human', 'nightelf', 'skyborne_a', 'orc', 'undead', 'skyborne_h']) console.log(r + ': ' + [3, 8, 12, 16, 20, 25, 30, 35, 40, 45, 50, 55, 60].map(L => L + ' ' + rec[r][L - 1].map(x => zones[x[0]][0] + ' ' + x[1]).join(', ')).join(' | '));
