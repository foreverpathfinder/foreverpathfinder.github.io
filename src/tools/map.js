// node src/tools/map.js → src/data/worldmap.json
// Scarica i dati della World Map Forever di Wowhead e li riduce a quello che usa la guida,
// in coordinate locali di ogni continente (pixel a zoom 7, come le tessere).
const fs = require('fs'), path = require('path');
const OUT = path.join(__dirname, '../data/worldmap.json');

(async () => {
  const page = await (await fetch('https://www.wowhead.com/forever/world-map', { headers: { 'User-Agent': 'Mozilla/5.0' } })).text();
  const url = 'https://' + page.match(/nether\.wowhead\.com\/forever\/data\/world-map[^"' ]*/)[0];
  const txt = await (await fetch(url, { headers: { 'User-Agent': 'Mozilla/5.0' } })).text();
  const D = {};
  for (const p of txt.split('WH.setPageData("').slice(1)) {
    const k = p.slice(0, p.indexOf('"'));
    D[k.split('.').pop()] = JSON.parse(p.slice(p.indexOf('",') + 2).trim().replace(/\);\s*$/, ''));
  }
  const r = n => Math.round(n);
  const out = { source: url, fetched: new Date().toISOString().slice(0, 10), continents: {} };
  for (const c of D.config.continents) {
    const ox = c.canvasX, oy = c.canvasY, inC = (x, y) => x >= ox && x <= ox + c.width && y >= oy && y <= oy + c.height;
    const P = (x, y) => [r(x - ox), r(y - oy)];
    const pois = cat => D.pois.filter(p => (typeof cat === 'string' ? p.category === cat : cat.test(p.category)) && inC(p.x, p.y));
    const M = out.continents[c.key] = { w: c.width, h: c.height };
    M.zones = D.places.filter(p => p.kind === 'zone' && inC(p.x, p.y)).map(p => [p.name, p.levels || '', ...P(p.x, p.y)]);
    M.places = D.places.filter(p => p.kind !== 'zone' && inC(p.x, p.y)).map(p => [p.name, p.kind, p.side || 0, ...P(p.x, p.y)]);
    M.fp = pois('flight-master').map(p => [p.name, p.side, ...P(p.x, p.y)]);
    M.dg = pois(/^(dungeon|raid)$/).map(p => [p.name, p.levels || '', ...P(p.x, p.y), p.new ? 1 : 0, p.category === 'raid' ? 1 : 0]);
    M.trainers = {};
    pois(/^class-trainer-/).forEach(p => { const k = p.category.slice(14), a = M.trainers[k] = M.trainers[k] || [];
      if (!a.some(t => t[1] === p.side && Math.hypot(t[2] + ox - p.x, t[3] + oy - p.y) < 60)) a.push([p.name, p.side, ...P(p.x, p.y)]); });
    M.inn = pois('innkeeper').map(p => [p.name, p.side, ...P(p.x, p.y)]);
    M.boat = pois(/^(ship|zeppelin|tram)$/).map(p => [p.name, p.category, p.side, ...P(p.x, p.y)]);
    M.quests = pois(/quest-giver$/).map(p => [p.name, p.side, ...P(p.x, p.y), (p.quests || []).map(q => q[1] + ' (' + q[2] + ')').slice(0, 4).join(', ')]);
    M.pets = pois(/^hunter-pet-/).map(p => [p.name, p.category.slice(11), p.levels || '', ...P(p.x, p.y)]);
    const simp = pts => pts.filter((p, i) => i % 4 === 0 || i === pts.length - 1).map(p => P(p[0], p[1]));
    M.flights = D.routes.filter(x => x.vessel === 'flight-master' && x.points.every(p => inC(p[0], p[1]))).map(x => [x.side, simp(x.points)]);
    M.ships = D.routes.filter(x => /^(ship|zeppelin|tram)$/.test(x.vessel) && x.points.some(p => inC(p[0], p[1])))
      .map(x => [x.vessel, x.points.filter(p => inC(p[0], p[1])).map(p => P(p[0], p[1]))]);
    const NK = { 'ore-copper-vein': 'cu', 'ore-tin-vein': 'sn', 'ore-silver-vein': 'ag', 'ore-iron-deposit': 'fe', 'herb-peacebloom': 'pb', 'herb-silverleaf': 'sl',
      'herb-earthroot': 'er', 'herb-mageroyal': 'mr', 'herb-briarthorn': 'bt', 'herb-bruiseweed': 'bw', 'herb-stranglekelp': 'sk', 'herb-wild-steelbloom': 'ws', 'herb-kingsblood': 'kb' };
    M.nodes = {};
    D.nodes.filter(n => NK[n.category]).forEach(n => { const a = n.points.filter(p => inC(p[0], p[1])).map(p => P(p[0], p[1])).flat(); if (a.length) M.nodes[NK[n.category]] = a; });
  }
  fs.writeFileSync(OUT, JSON.stringify(out));
  console.log(OUT, (fs.statSync(OUT).size / 1024).toFixed(0) + ' KB', Object.entries(out.continents).map(([k, v]) => k + ': ' + v.places.length + ' places, ' + v.quests.length + ' NPC').join(' · '));
})();
