// node src/tools/questinfo.js "<AddOns>/MapUtils/data/forever/questgivers.lua" → src/data/questinfo.json
// Chi può fare ogni quest di Forever, dal database dell'addon MapUtils (MapUtils.QUESTINFO: [id] = { livello, livello minimo, nome,
// fazione 1/2, categoria, livello max, razze, classi, … }). Indice ridotto: nome → [[fazione, razze, classi, livello], …] (0 = tutti; bit
// come nel gioco: razza n = 2^(n-1), Skyborne 33 Alleanza / 34 Orda; classe n = 2^(n-1)). addon.js lo usa per collegare a ogni voce
// solo le quest che quel personaggio può fare (es. "Consecrated Rune / Archaic Rune": il Dwarf Paladin fa solo la prima).
const fs = require('fs'), path = require('path');
const src = process.argv[2];
if (!src) { console.log('uso: node src/tools/questinfo.js <MapUtils/data/forever/questgivers.lua>'); process.exit(1) }
const txt = fs.readFileSync(src, 'utf8'), start = txt.indexOf('MapUtils.QUESTINFO');
const out = {};
const re = /^\s*\[(\d+)\] = \{(\d+), (\d+), "((?:[^"\\]|\\.)*)"(?:, (\w+))?(?:, (\w+))?(?:, (\w+))?(?:, (\w+))?(?:, (\w+))?/gm;
re.lastIndex = start;
let m, n = 0;
const num = v => (v && v !== 'nil') ? Number(v) : 0;
while ((m = re.exec(txt))) {
  const name = m[4].replace(/\\(.)/g, '$1'), e = [num(m[5]), num(m[8]), num(m[9]), Number(m[2])];
  (out[name] = out[name] || []).some(x => x.join() === e.join()) || out[name].push(e); n++;
}
fs.writeFileSync(path.join(__dirname, '../data/questinfo.json'), JSON.stringify({ source: 'MapUtils data/forever/questgivers.lua (QUESTINFO)', made: new Date().toISOString().slice(0, 10), quests: out }) + '\n');
console.log(n, 'quest ·', Object.keys(out).length, 'nomi');
