// Quest dei dungeon (ID da Wowhead Forever) arricchite dal database di Questie per Forever (QuestieDB):
// base grezza → delta generato → tracce → correzioni. Esce qdq.json: per dungeon, quest con nome, livelli, fazione,
// chi la dà (NPC, zona), quest richieste prima, obiettivo. Uso: node qdb.js
const fs = require('fs'), D = __dirname + '/';
// mini-parser per i letterali Lua delle tabelle (stringhe, numeri, nil, true/false, identificatori e somme come testo)
function parse(src, i0) {
  let i = i0;
  const ws = () => { for (;;) { while (/\s/.test(src[i])) i++; if (src.startsWith('--', i)) { if (src.startsWith('--[[', i)) i = src.indexOf(']]', i) + 2; else { const n = src.indexOf('\n', i); i = n < 0 ? src.length : n; } } else break; } };
  const str = () => { const q = src[i++]; let s = ''; while (src[i] !== q) { if (src[i] === '\\') { i++; const c = src[i++]; s += c === 'n' ? '\n' : c; } else s += src[i++]; } i++; return s; };
  const val = () => {
    ws(); const c = src[i];
    if (c === '{') return tbl();
    if (c === '"' || c === "'") return str();
    if (src.startsWith('[[', i)) { const e = src.indexOf(']]', i); const s = src.slice(i + 2, e); i = e + 2; return s; }
    const m = /^(-?\d+(\.\d+)?(e-?\d+)?|nil|true|false|[A-Za-z_][\w.]*)/.exec(src.slice(i, i + 200));
    if (!m) throw new Error('parse a ' + i + ': ' + src.slice(i, i + 40));
    i += m[0].length;
    let v = m[1] === 'nil' ? null : m[1] === 'true' ? true : m[1] === 'false' ? false : /^-?\d/.test(m[1]) ? +m[1] : m[1];
    ws();
    if (src[i] === '(') { i++; const a = []; ws(); while (src[i] !== ')') { a.push(val()); ws(); if (src[i] === ',') i++; ws(); } i++; v = a[0]; }
    while (src[i] === '+') { i++; const r = val(); v = String(v) + '+' + String(r); ws(); }
    return v;
  };
  const tbl = () => {
    i++; const o = {}; let n = 1;
    for (;;) {
      ws(); if (src[i] === '}') { i++; return o; }
      let k;
      if (src[i] === '[' && src[i + 1] !== '[') { i++; k = val(); ws(); i++; ws(); i++; }
      else { const m = /^([A-Za-z_]\w*)\s*=(?!=)/.exec(src.slice(i, i + 80)); if (m) { k = m[1]; i += m[0].length; } else k = n++; }
      o[k] = val(); ws(); if (src[i] === ',' || src[i] === ';') i++;
    }
  };
  const v = val(); return { v, end: i };
}
const ret = (file, from) => { const s = fs.readFileSync(D + file, 'utf8'); const k = s.indexOf('return {', from ? s.indexOf(from) : 0); return parse(s, k + 7).v; };
const keyIdx = (file, name) => { const s = fs.readFileSync(D + file, 'utf8'); const o = {}; const b = s.slice(s.indexOf(name + ' = {'), s.indexOf('\n}', s.indexOf(name + ' = {'))); for (const m of b.matchAll(/\['(\w+)'\]\s*=\s*(\d+)/g)) o[m[1]] = +m[2]; return o; };
const QK = keyIdx('foreverQuestDB.lua', 'QuestieDB.questKeys'), NK = keyIdx('foreverNpcDB.lua', 'QuestieDB.npcKeys');
// base grezza: stringa [[return {...}]] con campi per posizione
const raw = (file, marker) => { const s = fs.readFileSync(D + file, 'utf8'); const a = s.indexOf(marker); const k = s.indexOf('return {', a); return parse(s, k + 7).v; };
const Q = raw('foreverQuestDB.lua', 'QuestieDB.questData'), N = raw('foreverNpcDB.lua', 'QuestieDB.npcData');
// strati con chiavi "questKeys.nome": base generata, tracce (…_add = aggiunte), correzioni
const layer = (T, file, keys, from) => {
  let L; try { L = ret(file, from); } catch (e) { console.error('salto', file, e.message); return; }
  for (const [id, rec] of Object.entries(L)) {
    if (typeof rec !== 'object' || rec === null) continue;
    const t = T[id] || (T[id] = {});
    for (const [kk, v] of Object.entries(rec)) {
      const nm = String(kk).replace(/^\w+Keys\./, ''), add = nm.endsWith('_add'), key = keys[nm.replace(/_add$/, '')];
      if (!key) continue;
      if (add && t[key]) { const a = t[key], b = v; for (const j of Object.keys(b)) a[j] = Object.values(Object.assign({}, a[j] || {}, ...Object.values(b[j] || {}).map((x, n) => ({ ['x' + Object.keys(a[j] || {}).length + n]: x })))); }
      else t[key] = v;
    }
  }
};
layer(Q, 'foreverBaseQuest.lua', QK, 'function ForeverBaseQuest:Load');
layer(Q, 'foreverQuestTraces.lua', QK);
layer(Q, 'foreverQuestFixes.lua', QK, 'function ForeverQuestFixes:Load');
layer(N, 'foreverBaseNpc.lua', NK, 'function ForeverBaseNpc:Load');
// nomi delle zone: commenti di areaIdToUiMapId.lua ("[331] = 1440, -- Ashenvale")
const ZN = {}; for (const m of fs.readFileSync(D + 'areaIdToUiMapId.lua', 'utf8').matchAll(/\[(\d+)\]\s*=\s*\d+,\s*--\s*([^\n]+)/g)) ZN[m[1]] = m[2].trim();
const arr = x => x == null ? [] : Array.isArray(x) ? x : Object.values(x);
const npcName = id => { const n = N[id]; return n ? n[NK.name] : null; };
const npcZone = id => { const n = N[id]; if (!n) return null; const z = n[NK.zoneID] || Object.keys(n[NK.spawns] || {})[0]; return ZN[z] || (z ? 'zona ' + z : null); };
const side = r => { const s = String(r || ''); return /ALL_ALLIANCE/.test(s) ? 'A' : /ALL_HORDE/.test(s) ? 'H' : !r || r === 0 ? 'N' : 'r:' + s.slice(0, 40); };
const qName = id => Q[id] ? Q[id][QK.name] : '#' + id;
const W = JSON.parse(fs.readFileSync(D + 'whdq.json', 'utf8')), out = {};
for (const [dg, list] of Object.entries(W)) {
  out[dg] = list.split(',').map(x => { const [id, s] = x.split(':'); const q = Q[id]; if (!q) return { id: +id, wh: s, missing: true };
    const st = arr(q[QK.startedBy]), np = arr(st[0]), ob = arr(st[1]), it = arr(st[2]);
    const pre = [...arr(q[QK.preQuestSingle]), ...arr(q[QK.preQuestGroup])];
    return { id: +id, name: q[QK.name], lv: q[QK.questLevel], req: q[QK.requiredLevel], side: side(q[QK.requiredRaces]), cls: q[QK.requiredClasses] || null, wh: s,
      by: np.map(n => npcName(n) + (npcZone(n) ? ', ' + npcZone(n) : '')).concat(ob.map(o => 'oggetto ' + o), it.map(o => 'item ' + o)),
      pre: pre.map(qName), obj: arr(q[QK.objectivesText])[0] || '' };
  });
}
fs.writeFileSync(D + 'qdq.json', JSON.stringify(out, null, 1));
console.log(Object.entries(out).map(([k, v]) => k + ' ' + v.length + (v.some(x => x.missing) ? ' (mancano ' + v.filter(x => x.missing).length + ')' : '')).join('\n'));
// tutte le quest, campi essenziali (per le zone consigliate e i dungeon 35–60)
{
  const all = {};
  for (const [id, q] of Object.entries(Q)) { if (!q || typeof q !== 'object' || !q[QK.name]) continue;
    const st = arr(q[QK.startedBy]);
    all[id] = { n: q[QK.name], lv: q[QK.questLevel], rq: q[QK.requiredLevel], r: q[QK.requiredRaces] ?? null, c: q[QK.requiredClasses] ?? null, z: q[QK.zoneOrSort] ?? null,
      sp: q[QK.specialFlags] ?? null, fl: q[QK.questFlags] ?? null, by: arr(st[0]), ob: arr(st[1]).length, it: arr(st[2]).length, pre: [...arr(q[QK.preQuestSingle]), ...arr(q[QK.preQuestGroup])],
      sk: q[QK.requiredSkill] ? 1 : 0, ex: arr(q[QK.exclusiveTo]).length, par: q[QK.parentQuest] || 0 }; }
  fs.writeFileSync(D + 'qall.json', JSON.stringify(all));
  const np = {}; for (const [id, n] of Object.entries(N)) if (n && n[NK.name]) np[id] = [n[NK.name], npcZone(id), n[NK.friendlyToFaction] || ""];
  fs.writeFileSync(D + 'npc.json', JSON.stringify(np));
  fs.writeFileSync(D + 'zn.json', JSON.stringify(ZN));
  console.log('quest', Object.keys(all).length, 'npc', Object.keys(np).length);
}
