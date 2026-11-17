// Mappe dei dungeon dai dati di Twinmap (twinmap.app), che le ricostruisce dai file del gioco:
// - boss, ingresso e confini di ogni dungeon da DUNGEON_PINS e NEW_DUNGEON_PINS (renderer dentro app.asar);
// - terreno dai blocchi i<mappa>/blocks/<colonna>/<riga>.dxt (533,33 yard per lato);
// - stanze dai pezzi di interiors.json (yard, rotazione, piano) con le texture rooms/<file>.dxt.
// Tutti i .dxt sono DXT1 compressi con zlib. Le coordinate sono yard nello stesso spazio per boss, pezzi e blocchi.
// Scrive dgmap/<mappa>-<nome>.webp (un'immagine per dungeon o ala) e src/data/dgmaps.json (boss e ingresso in pixel).
// Uso: node src/tools/dgmaps.js   (serve Twinmap installato, con le tessere già create dall'app)
const fs = require('fs'), path = require('path'), zlib = require('zlib');
const { chromium } = require(process.env.LOCALAPPDATA + '/npm-cache/_npx/9833c18b2d85bc59/node_modules/playwright-core');
const ROOT = path.join(__dirname, '..', '..'), OUT = path.join(ROOT, 'dgmap'), BY = 1600 / 3;
const ASAR = path.join(process.env.LOCALAPPDATA, 'Programs/twinmap/resources/app.asar');
const TILES = (() => { const b = path.join(process.env.LOCALAPPDATA, 'Twinmap/tiles'); // la cartella della build più recente
  return fs.readdirSync(b).map(d => path.join(b, d)).filter(d => fs.existsSync(path.join(d, 'interiors.json'))).sort((a, c) => fs.statSync(c).mtimeMs - fs.statSync(a).mtimeMs)[0]; })();

// file dentro un .asar: intestazione JSON dopo 16 byte, poi i contenuti
function asarFile(re) {
  const fd = fs.openSync(ASAR, 'r'), b = Buffer.alloc(16); fs.readSync(fd, b, 0, 16, 0);
  const h = Buffer.alloc(b.readUInt32LE(12)); fs.readSync(fd, h, 0, h.length, 16);
  const base = 8 + b.readUInt32LE(4); let hit = null;
  (function walk(n, p) { for (const [k, v] of Object.entries(n.files || {})) { const q = p + '/' + k; if (v.files) walk(v, q); else if (re.test(q)) hit = v; } })(JSON.parse(h), '');
  const d = Buffer.alloc(hit.size); fs.readSync(fd, d, 0, hit.size, base + Number(hit.offset)); return d.toString('utf8');
}
const JS = asarFile(/out\/renderer\/assets\/index-[^/]+\.js$/);
const grab = (v) => { const i = JS.indexOf('var ' + v + ' = ['), a = JS.indexOf('[', i); let d = 0, j = a;
  for (; j < JS.length; j++) { const c = JS[j]; if (c === '[' || c === '{') d++; else if (c === ']' || c === '}') { d--; if (!d) break; } }
  return Function('return ' + JS.slice(a, j + 1))(); };
const PINS = [...grab('DUNGEON_PINS'), ...grab('NEW_DUNGEON_PINS')];
const INT = JSON.parse(fs.readFileSync(path.join(TILES, 'interiors.json'), 'utf8'));
// chiave della scheda Dungeon (dungeons.json): senza «The », minuscola; ali di Blackrock Spire e Dire Maul insieme
const keyOf = (n) => n.replace(/^The /, '').toLowerCase().replace(/^(lower|upper) blackrock spire$/, 'blackrock spire').replace(/^dire maul: \w+$/, 'dire maul');
const DG = JSON.parse(fs.readFileSync(path.join(ROOT, 'src/data/dungeons.json'), 'utf8')).dungeons;
const b64 = (f) => zlib.inflateSync(fs.readFileSync(f)).toString('base64');

(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  const br = await chromium.launch({ channel: 'chrome' }), pg = await br.newPage(), out = [], plan = [];
  for (const d of PINS) {
    const key = keyOf(d.name); if (!DG[key]) { console.log('salto', d.name); continue; }
    const [u1, v1, u2, v2] = d.bounds, M = 24, x0 = u1 - M, y0 = v1 - M, W = u2 - u1 + 2 * M, H = v2 - v1 + 2 * M;
    const s = Math.min(2, 2000 / Math.max(W, H)); // pixel per yard: le texture arrivano a circa 2
    const m = INT.maps.find((x) => x.id === d.map), dir = path.join(TILES, 'i' + d.map, 'blocks'), blocks = [];
    if (fs.existsSync(dir)) for (const c of fs.readdirSync(dir)) for (const r of fs.readdirSync(path.join(dir, c))) {
      const col = +c, row = parseInt(r);
      if ((col + 1) * BY > x0 && col * BY < x0 + W && (row + 1) * BY > y0 && row * BY < y0 + H) blocks.push({ col, row, data: b64(path.join(dir, c, r)) });
    }
    const reach = (p) => Math.hypot(p.width, p.height) / 2;
    const pieces = (m ? m.pieces : []).filter((p) => p.u + reach(p) > x0 && p.u - reach(p) < x0 + W && p.v + reach(p) > y0 && p.v - reach(p) < y0 + H)
      .map((p) => ({ u: p.u, v: p.v, w: p.width, h: p.height, a: p.angle, file: p.file, lv: p.level, data: b64(path.join(TILES, 'rooms', p.file + '.dxt')) }));
    const url = await pg.evaluate(({ blocks, pieces, x0, y0, W, H, s, BY }) => {
      // DXT1 → canvas (come roomPixels di Twinmap: il colore 3 con c0 <= c1 è trasparente)
      const pic = (b64, w) => { const bin = atob(b64), n = bin.length, dv = new DataView(new Uint8Array([...bin].map((ch) => ch.charCodeAt(0))).buffer);
        const width = w || Math.sqrt(n * 2), height = n * 2 / width, px = new Uint8ClampedArray(width * height * 4);
        const col = (c) => [(c >> 11 & 31) * 255 / 31, (c >> 5 & 63) * 255 / 63, (c & 31) * 255 / 31];
        for (let by = 0, p = 0; by < height; by += 4) for (let bx = 0; bx < width; bx += 4, p += 8) {
          const c0 = dv.getUint16(p, true), c1 = dv.getUint16(p + 2, true), a = col(c0), b = col(c1), ch = dv.getUint32(p + 4, true);
          const f = c0 > c1 ? [a, b, a.map((x, i) => (2 * x + b[i]) / 3), a.map((x, i) => (x + 2 * b[i]) / 3)] : [a, b, a.map((x, i) => (x + b[i]) / 2), null];
          for (let i = 0; i < 16; i++) { const c = f[ch >>> i * 2 & 3]; if (c) px.set([c[0], c[1], c[2], 255], ((by + (i >> 2)) * width + bx + (i & 3)) * 4); }
        }
        const cv = document.createElement('canvas'); cv.width = width; cv.height = height; cv.getContext('2d').putImageData(new ImageData(px, width, height), 0, 0); return cv; };
      const cv = document.createElement('canvas'); cv.width = Math.round(W * s); cv.height = Math.round(H * s);
      const g = cv.getContext('2d'); g.fillStyle = '#0b1626'; g.fillRect(0, 0, cv.width, cv.height); g.imageSmoothingQuality = 'high';
      for (const b of blocks) g.drawImage(pic(b.data), (b.col * BY - x0) * s, (b.row * BY - y0) * s, BY * s, BY * s);
      for (const p of pieces) { // dal piano più basso: quelli sopra coprono quelli sotto, come in Twinmap
        const n = atob(p.data).length, w = Math.round(Math.sqrt(n * 2 * p.w / p.h));
        g.setTransform(1, 0, 0, 1, 0, 0); g.translate((p.u - x0) * s, (p.v - y0) * s); g.rotate(-p.a);
        g.drawImage(pic(p.data, w), -p.w / 2 * s, -p.h / 2 * s, p.w * s, p.h * s);
      }
      return cv.toDataURL('image/webp', 0.82);
    }, { blocks, pieces, x0, y0, W, H, s, BY });
    const file = d.map + '-' + d.name.toLowerCase().replace(/^the /, '').replace(/[^a-z0-9]+/g, '-').replace(/-$/, '') + '.webp';
    fs.writeFileSync(path.join(OUT, file), Buffer.from(url.split(',')[1], 'base64'));
    const P = (u, v) => [Math.round((u - x0) * s), Math.round((v - y0) * s)];
    out.push({ k: key, n: d.name, img: 'dgmap/' + file, w: Math.round(W * s), h: Math.round(H * s),
      e: d.entrance ? P(d.entrance[0], d.entrance[1]) : null, b: d.bosses.map((x) => [x[0], ...P(x[1], x[2])]) });
    // per l'addon (pianta nella scheda Dungeon): solo i dungeon al chiuso, perché il terreno non ha numeri di file da caricare nel gioco
    if (!blocks.length) { const r1 = (n) => Math.round(n * 10) / 10, Y = (u, v) => [r1(u - x0), r1(v - y0)];
      plan.push({ k: key, n: d.name, w: r1(W), h: r1(H), e: d.entrance ? Y(d.entrance[0], d.entrance[1]) : null, b: d.bosses.map((x) => [x[0], ...Y(x[1], x[2])]),
        p: pieces.map((q) => [q.file, ...Y(q.u, q.v), r1(q.w), r1(q.h), Math.round(q.a * 1e4) / 1e4, q.lv]) }); }
    console.log(file, Math.round(W * s) + 'x' + Math.round(H * s), 'blocchi', blocks.length, 'stanze', pieces.length, (fs.statSync(path.join(OUT, file)).size / 1024).toFixed(0) + ' KB');
  }
  await br.close();
  fs.writeFileSync(path.join(ROOT, 'src/data/dgmaps.json'), JSON.stringify({ _: 'Mappe dei dungeon da Twinmap (src/tools/dgmaps.js): k = chiave in dungeons.json, img, w/h in pixel, e = ingresso, b = boss [nome, x, y] in pixel dell\'immagine.', maps: out }, null, 1) + '\n');
  fs.writeFileSync(path.join(ROOT, 'src/data/dgplan.json'), JSON.stringify({ _: "Piante dei dungeon al chiuso per l'addon (src/tools/dgmaps.js): yard dall'angolo in alto a sinistra; p = pezzi [FileID della texture, x, y, larghezza, altezza, angolo, piano].", maps: plan }) + '\n');
  console.log('mappe', out.length, "· piante per l'addon", plan.length);
})();
