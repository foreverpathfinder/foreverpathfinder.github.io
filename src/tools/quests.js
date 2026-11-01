// node src/tools/quests.js <out.txt> → indice di tutte le quest di Forever (dati mappa Wowhead):
// "Nome quest | livello | NPC | A/H/- | luogo più vicino". Serve per verificare nomi, NPC e livelli prima di scrivere le milestone.
const fs = require('fs');
(async () => {
  const H = { headers: { 'User-Agent': 'Mozilla/5.0' } }, page = await (await fetch('https://www.wowhead.com/forever/world-map', H)).text();
  const txt = await (await fetch('https://' + page.match(/nether\.wowhead\.com\/forever\/data\/world-map[^"' ]*/)[0], H)).text(), D = {};
  for (const p of txt.split('WH.setPageData("').slice(1)) D[p.slice(0, p.indexOf('"')).split('.').pop()] = JSON.parse(p.slice(p.indexOf('",') + 2).trim().replace(/\);\s*$/, ''));
  const pl = D.places.filter(p => p.kind !== 'landmark'), near = (x, y) => pl.reduce((b, p) => { const d = (p.x - x) ** 2 + (p.y - y) ** 2; return d < b[1] ? [p.name, d] : b; }, ['', 1e15])[0];
  const out = [];
  D.pois.filter(p => /quest-giver$/.test(p.category) && p.quests).forEach(p => p.quests.forEach(q => out.push([q[1], q[2], p.name, p.side === 1 ? 'A' : p.side === 2 ? 'H' : '-', near(p.x, p.y)].join(' | '))));
  fs.writeFileSync(process.argv[2] || 'forever_quests.txt', [...new Set(out)].sort().join('\n'));
  console.log(out.length, 'quest');
})();
