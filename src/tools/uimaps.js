// node src/tools/uimaps.js → src/data/uimaps.json
// Zone e capitali della World Map Forever di Wowhead con il loro uiMapID del gioco e il rettangolo, in pixel locali del continente
// (come worldmap.json). Servono all'addon: la mappa del continente del gioco non ha gli stessi bordi di quella di Wowhead, quella
// della zona sì (Marryk Nurribit → Dun Morogh 28.6, 66.4, come nel gioco). Si rilancia insieme a map.js.
const fs = require('fs'), path = require('path');
const OUT = path.join(__dirname, '../data/uimaps.json');
(async () => {
  const H = { headers: { 'User-Agent': 'Mozilla/5.0' } };
  const page = await (await fetch('https://www.wowhead.com/forever/world-map', H)).text();
  const url = 'https://' + page.match(/nether\.wowhead\.com\/forever\/data\/world-map[^"' ]*/)[0];
  const txt = await (await fetch(url, H)).text(), D = {};
  for (const p of txt.split('WH.setPageData("').slice(1)) { const k = p.slice(0, p.indexOf('"')); D[k.split('.').pop()] = JSON.parse(p.slice(p.indexOf('",') + 2).trim().replace(/\);\s*$/, '')) }
  // grids: la griglia delle zone di Wowhead (quadretti di "cell" pixel): per riga [riga, colonna iniziale, area, colonna finale, area,
  // colonna finale, …], con l'origine (x, y) in pixel locali del continente; area → uiMapID dalle zone. I rettangoli si sovrappongono
  // (Darkshore dentro quello di Mount Hyjal), la griglia no.
  const out = { source: url, fetched: new Date().toISOString().slice(0, 10), continents: {}, grids: {} };
  const area = {}; D.places.forEach(p => { if (p.uiMap && p.area) area[p.area] = p.uiMap });
  for (const c of D.config.continents) {
    const ox = c.canvasX, oy = c.canvasY, inC = (x, y) => x >= ox && x <= ox + c.width && y >= oy && y <= oy + c.height;
    out.continents[c.key] = D.places.filter(p => p.uiMap && p.rect && inC(p.x, p.y))
      .map(p => [p.uiMap, p.name, Math.round(p.rect[0][0] - ox), Math.round(p.rect[0][1] - oy), Math.round(p.rect[1][0] - ox), Math.round(p.rect[1][1] - oy)]);
    const z = D.zones.find(z => z.map === c.map);
    if (z && z.rows.length) out.grids[c.key] = { x: z.x - ox, y: z.y - oy, cell: z.cell, rows: z.rows.map(r => r.map((v, i) => i >= 2 && i % 2 === 0 ? (area[v] || 0) : v)) };
  }
  fs.writeFileSync(OUT, JSON.stringify(out, null, 1) + '\n');
  console.log(Object.entries(out.continents).map(([k, a]) => k + ' ' + a.length).join(' · '));
})();
