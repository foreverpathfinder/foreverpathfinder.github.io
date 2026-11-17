// Mappe dei dungeon dai dati di Twinmap (twinmap.app), che le ricostruisce dai file del gioco:
// - boss, ingresso e confini di ogni dungeon da DUNGEON_PINS e NEW_DUNGEON_PINS (renderer dentro app.asar);
// - terreno dai blocchi i<mappa>/blocks/<colonna>/<riga>.dxt (533,33 yard per lato) e, per l'addon, i loro FileID dal .wdt;
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
// FileID dell'immagine della minimappa di ogni blocco di terreno, per l'addon (che le carica dal gioco per numero).
// Si leggono dal .wdt di ogni mappa nell'archivio di Forever, con il lettore di Twinmap: interiors e geo copiati
// in una cartella temporanea, tabelle (wdc5) e chiavi mandate dal server (keys) prese dal suo worker.
function groundIds() {
  const tmp = fs.mkdtempSync(path.join(require('os').tmpdir(), 'twinmap-')), mod = {};
  for (const n of ['geo', 'interiors', 'tiles-worker']) mod[n] = asarFile(new RegExp('out/main/' + n + '-[^/]+\\.js$'));
  const geoName = mod.interiors.match(/require\("\.\/(geo-[^"]+)"\)/)[1];
  fs.writeFileSync(path.join(tmp, geoName), mod.geo); fs.writeFileSync(path.join(tmp, 'interiors.js'), mod.interiors);
  const I = require(path.join(tmp, 'interiors.js')), G = require(path.join(tmp, geoName)), w = mod['tiles-worker'];
  const part = (from) => { const a = w.indexOf(from); return w.slice(a, w.indexOf('// src/', a + 10)); };
  const readTable = Function(part('// src/shared/wdc5.ts') + ';return readTable')();
  const sentKeys = Function('node_fs', 'node_path', part('// src/main/keys.ts') + ';return sentKeys')(fs, path);
  const game = I.gameFolderFrom([I.registryInstallPath() || '', 'C:/Program Files (x86)/World of Warcraft/_forever_']);
  const files = I.openClientFiles(game, sentKeys(game)), T = readTable(files.read(1349477, true), (k) => files.opens(k)), out = {};
  for (const r of T.rows) { const wdt = r.int(21) && files.read(r.int(21)); if (wdt) out[r.id] = G.minimapTiles(wdt); } // blocco (riga * 64 + colonna) → FileID
  fs.rmSync(tmp, { recursive: true, force: true });
  return out;
}
const GROUND = groundIds();
const grab = (v) => { const i = JS.indexOf('var ' + v + ' = ['), a = JS.indexOf('[', i); let d = 0, j = a;
  for (; j < JS.length; j++) { const c = JS[j]; if (c === '[' || c === '{') d++; else if (c === ']' || c === '}') { d--; if (!d) break; } }
  return Function('return ' + JS.slice(a, j + 1))(); };
const PINS = [...grab('DUNGEON_PINS'), ...grab('NEW_DUNGEON_PINS')];
const INT = JSON.parse(fs.readFileSync(path.join(TILES, 'interiors.json'), 'utf8'));
// chiave della scheda Dungeon (dungeons.json): senza «The », minuscola; ali di Blackrock Spire e Dire Maul insieme
const keyOf = (n) => n.replace(/^The /, '').toLowerCase().replace(/^(lower|upper) blackrock spire$/, 'blackrock spire').replace(/^dire maul: \w+$/, 'dire maul');
const DG = JSON.parse(fs.readFileSync(path.join(ROOT, 'src/data/dungeons.json'), 'utf8')).dungeons;
const b64 = (f) => zlib.inflateSync(fs.readFileSync(f)).toString('base64');
// ritratti dei boss: displayID da OneForAll (Data/Dungeons/*.lua, presi dalle pagine NPC di Wowhead Forever)
const norm = (n) => n.toLowerCase().replace(/[^a-z]+/g, '');
const OFA = (() => { const dir = path.join(process.env.WOWADDONS || 'C:/Program Files (x86)/World of Warcraft/_forever_/Interface/AddOns', 'OneForAll/Data/Dungeons'), out = {};
  if (fs.existsSync(dir)) for (const f of fs.readdirSync(dir)) for (const m of fs.readFileSync(path.join(dir, f), 'utf8').matchAll(/name = "((?:[^"\\]|\\.)+)",(?:\s*npcID = \d+,[^\n]*)?\s*(?:displayID = (\d+)|fallbackIcon = "Interface\\\\Icons\\\\([^"]+)")/g)) out[norm(m[1])] = m[2] ? +m[2] : m[3].toLowerCase();
  // ritratto: numero = displayID del modello; testo = nome dell'icona di riserva (modello che il client non disegna)
  return out; })();
// nomi d'incontro di Twinmap → nome del mostro (per il ritratto)
const ALIAS = { deathlessguardians: 'deathlessmarrow', doomrel: 'theseven', overseermugg: 'overlordmugg', handlerashka: 'warhandlerashka' };
// nome dell'incontro (Twinmap) → nome del mostro che si vede nel gioco (Questie, Wowhead)
const SHOW = { 'Deathless Guardians': 'Deathless Marrow', 'Handler Ashka': 'War Handler Ashka', 'Overseer Mugg': 'Overlord Mugg' }, nm = (n) => SHOW[n] || n;
const did = (n) => OFA[norm(n)] || OFA[ALIAS[norm(n)]] || (Object.entries(OFA).find(([k]) => k.includes(norm(n)) || norm(n).includes(k)) || [])[1] || 0;
// inviluppo convesso (catena monotona)
function hull(pts) { const p = [...pts].sort((a, b) => a[0] - b[0] || a[1] - b[1]), cr = (o, a, b) => (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);
  const lo = [], up = []; for (const q of p) { while (lo.length > 1 && cr(lo[lo.length - 2], lo[lo.length - 1], q) <= 0) lo.pop(); lo.push(q); }
  for (const q of p.reverse()) { while (up.length > 1 && cr(up[up.length - 2], up[up.length - 1], q) <= 0) up.pop(); up.push(q); }
  return lo.slice(0, -1).concat(up.slice(0, -1)); }
// maschera dell'addon: TGA 32 bit, bianco con l'opacità della sagoma (origine in alto a sinistra)
function tga(alpha, n) { const b = Buffer.alloc(18 + n * n * 4); b[2] = 2; b.writeUInt16LE(n, 12); b.writeUInt16LE(n, 14); b[16] = 32; b[17] = 0x28;
  for (let i = 0; i < n * n; i++) b.set([255, 255, 255, alpha[i]], 18 + i * 4); return b; }
const MASKS = path.join(ROOT, 'addon/ForeverPathfinder/Masks'), MR = 80, MF = 25; // yard di margine e di sfumatura della sagoma

// sul sito il ritratto è la miniatura del modello su Wowhead: c'è solo per i modelli che Wowhead ha già (non per molti nuovi di Forever);
// dove manca, l'icona di riserva di OneForAll o un teschio. L'addon tiene il displayID: il gioco disegna il modello da solo
const THUMB = (d) => 'https://wow.zamimg.com/modelviewer/classic/webthumbs/npc/' + (d & 255) + '/' + d + '.webp', WEB = {};
async function webPics() { const ids = [...new Set(PINS.flatMap((d) => d.bosses.map((b) => did(nm(b[0])))).filter((d) => typeof d === 'number' && d > 0))];
  for (let i = 0; i < ids.length; i += 16) await Promise.all(ids.slice(i, i + 16).map(async (d) => { try { WEB[d] = (await fetch(THUMB(d), { method: 'HEAD' })).ok; } catch { WEB[d] = false; } })); }
const webPic = (n) => { const d = did(n); return typeof d === 'number' ? (d > 0 && WEB[d] ? d : 'inv_misc_bone_skull_02') : d || 'inv_misc_bone_skull_02'; };

(async () => {
  await webPics();
  fs.mkdirSync(OUT, { recursive: true }); fs.rmSync(MASKS, { recursive: true, force: true }); fs.mkdirSync(MASKS, { recursive: true });
  const br = await chromium.launch({ channel: 'chrome' }), pg = await br.newPage(), out = [], plan = [];
  for (const d of PINS) {
    const key = keyOf(d.name); if (!DG[key]) { console.log('salto', d.name); continue; }
    const m = INT.maps.find((x) => x.id === d.map), reach = (p) => Math.hypot(p.width, p.height) / 2, [bu1, bv1, bu2, bv2] = d.bounds;
    // stanze dentro i confini di Twinmap; angoli di ogni stanza girata (come la disegna la tela: rotate(-angolo))
    const rooms = (m ? m.pieces : []).filter((p) => p.u + reach(p) > bu1 - 24 && p.u - reach(p) < bu2 + 24 && p.v + reach(p) > bv1 - 24 && p.v - reach(p) < bv2 + 24);
    const corners = rooms.flatMap((p) => { const c = Math.cos(p.angle), sn = Math.sin(p.angle);
      return [[-1, -1], [1, -1], [1, 1], [-1, 1]].map(([i, j]) => { const x = i * p.width / 2, y = j * p.height / 2; return [p.u + x * c + y * sn, p.v - x * sn + y * c]; }); });
    const inRoom = ([u, v]) => rooms.some((p) => { const c = Math.cos(p.angle), sn = Math.sin(p.angle), du = u - p.u, dv = v - p.v;
      return Math.abs(du * c - dv * sn) <= p.width / 2 + 15 && Math.abs(du * sn + dv * c) <= p.height / 2 + 15; });
    const pts = d.bosses.map((b) => [b[1], b[2]]).concat(d.entrance ? [d.entrance] : []);
    // all'aperto se un boss o l'ingresso sta fuori dalle stanze: allora il terreno, ma solo dentro la sagoma
    // all'aperto: la sagoma è l'inviluppo di boss e ingresso (le stanze lontane dentro i confini di Twinmap restano fuori)
    const outdoor = pts.some((q) => !inRoom(q)), shape = hull(pts);
    const near = (u, v, r) => { let inside = false; // dentro la sagoma o a meno di r yard dal bordo
      for (let i = 0, j = shape.length - 1; i < shape.length; j = i++) { const [a, b] = shape[i], [c, e] = shape[j];
        if ((b > v) !== (e > v) && u < (c - a) * (v - b) / (e - b) + a) inside = !inside;
        const L = (c - a) ** 2 + (e - b) ** 2, t = L ? Math.max(0, Math.min(1, ((u - a) * (c - a) + (v - b) * (e - b)) / L)) : 0;
        if (Math.hypot(u - a - t * (c - a), v - b - t * (e - b)) <= r) return true; }
      return inside; };
    const keep = outdoor ? rooms.filter((p) => near(p.u, p.v, MR)) : rooms;
    const all = outdoor ? shape : corners.concat(pts), G0 = outdoor ? MR + 10 : 20;
    const x0 = Math.min(...all.map((q) => q[0])) - G0, y0 = Math.min(...all.map((q) => q[1])) - G0;
    const W = Math.max(...all.map((q) => q[0])) + G0 - x0, H = Math.max(...all.map((q) => q[1])) + G0 - y0;
    const s = Math.min(2, 2000 / Math.max(W, H)); // pixel per yard: le texture arrivano a circa 2
    const dir = path.join(TILES, 'i' + d.map, 'blocks'), blocks = [];
    if (outdoor && fs.existsSync(dir)) for (const c of fs.readdirSync(dir)) for (const r of fs.readdirSync(path.join(dir, c))) {
      const col = +c, row = parseInt(r);
      if ((col + 1) * BY > x0 && col * BY < x0 + W && (row + 1) * BY > y0 && row * BY < y0 + H) blocks.push({ col, row, data: b64(path.join(dir, c, r)) });
    }
    const pieces = keep.filter((p) => p.u + reach(p) > x0 && p.u - reach(p) < x0 + W && p.v + reach(p) > y0 && p.v - reach(p) < y0 + H)
      .map((p) => ({ u: p.u, v: p.v, w: p.width, h: p.height, a: p.angle, file: p.file, lv: p.level, data: b64(path.join(TILES, 'rooms', p.file + '.dxt')) }));
    const res = await pg.evaluate(({ blocks, pieces, x0, y0, W, H, s, BY, shape, MR, MF, outdoor }) => {
      // sagoma sfumata: l'inviluppo allargato di MR yard, a sx/sy pixel per yard
      const mask = (w, h, sx, sy) => { const c = document.createElement('canvas'); c.width = w; c.height = h; const k = c.getContext('2d');
        k.filter = 'blur(' + Math.max(1, MF * Math.min(sx, sy)) + 'px)'; k.fillStyle = k.strokeStyle = '#fff'; k.lineJoin = 'round'; k.lineWidth = 2 * MR * Math.min(sx, sy);
        k.beginPath(); shape.forEach(([x, y], i) => { const X = (x - x0) * sx, Y = (y - y0) * sy; if (i) k.lineTo(X, Y); else k.moveTo(X, Y); }); k.closePath(); k.fill(); k.stroke(); return c; };
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
      if (blocks.length) { // terreno su una tela a parte, poi tenuto solo dentro la sagoma
        const gc = document.createElement('canvas'); gc.width = cv.width; gc.height = cv.height; const k = gc.getContext('2d');
        for (const b of blocks) k.drawImage(pic(b.data), (b.col * BY - x0) * s, (b.row * BY - y0) * s, BY * s, BY * s);
        k.globalCompositeOperation = 'destination-in'; k.drawImage(mask(cv.width, cv.height, s, s), 0, 0); g.drawImage(gc, 0, 0);
      }
      for (const p of pieces) { // dal piano più basso: quelli sopra coprono quelli sotto, come in Twinmap
        const n = atob(p.data).length, w = Math.round(Math.sqrt(n * 2 * p.w / p.h));
        g.setTransform(1, 0, 0, 1, 0, 0); g.translate((p.u - x0) * s, (p.v - y0) * s); g.rotate(-p.a);
        g.drawImage(pic(p.data, w), -p.w / 2 * s, -p.h / 2 * s, p.w * s, p.h * s);
      }
      // la maschera dell'addon: 128x128 sulla stessa area, solo l'opacità
      const mk = blocks.length ? [...mask(128, 128, 128 / W, 128 / H).getContext('2d').getImageData(0, 0, 128, 128).data].filter((_, i) => i % 4 === 3) : null;
      return { url: cv.toDataURL('image/webp', 0.82), mk };
    }, { blocks, pieces, x0, y0, W, H, s, BY, shape, MR, MF, outdoor });
    const slug = d.map + '-' + d.name.toLowerCase().replace(/^the /, '').replace(/[^a-z0-9]+/g, '-').replace(/-$/, ''), file = slug + '.webp';
    fs.writeFileSync(path.join(OUT, file), Buffer.from(res.url.split(',')[1], 'base64'));
    if (res.mk) fs.writeFileSync(path.join(MASKS, slug + '.tga'), tga(res.mk, 128));
    const nodid = d.bosses.filter((b) => !did(nm(b[0]))).map((b) => b[0]); if (nodid.length) console.log('  senza ritratto:', nodid.join(', '));
    const P = (u, v) => [Math.round((u - x0) * s), Math.round((v - y0) * s)];
    out.push({ k: key, n: d.name, img: 'dgmap/' + file, w: Math.round(W * s), h: Math.round(H * s),
      e: d.entrance ? P(d.entrance[0], d.entrance[1]) : null, b: d.bosses.map((x) => [nm(x[0]), ...P(x[1], x[2]), webPic(nm(x[0]))]) });
    // per l'addon (pianta nella scheda Dungeon): terreno g = [FileID, x, y] (blocchi di BY yard) con la maschera mk, stanze p, tutto in yard
    { const r1 = (n) => Math.round(n * 10) / 10, Y = (u, v) => [r1(u - x0), r1(v - y0)], gm = GROUND[d.map], g = [];
      for (const k of blocks) { const id = gm && gm.get(k.row * 64 + k.col); if (id) g.push([id, ...Y(k.col * BY, k.row * BY)]); }
      if (blocks.length && g.length < blocks.length) console.log('  terreno senza FileID:', blocks.length - g.length);
      plan.push({ k: key, n: d.name, w: r1(W), h: r1(H), e: d.entrance ? Y(d.entrance[0], d.entrance[1]) : null, b: d.bosses.map((x) => [nm(x[0]), ...Y(x[1], x[2]), did(nm(x[0]))]), g,
        mk: res.mk ? slug : null, p: pieces.map((q) => [q.file, ...Y(q.u, q.v), r1(q.w), r1(q.h), Math.round(q.a * 1e4) / 1e4, q.lv]) }); }
    console.log(file, outdoor ? 'aperto' : 'chiuso', Math.round(W * s) + 'x' + Math.round(H * s), 'blocchi', blocks.length, 'stanze', pieces.length, (fs.statSync(path.join(OUT, file)).size / 1024).toFixed(0) + ' KB');
  }
  await br.close();
  fs.writeFileSync(path.join(ROOT, 'src/data/dgmaps.json'), JSON.stringify({ _: 'Mappe dei dungeon da Twinmap (src/tools/dgmaps.js): k = chiave in dungeons.json, img, w/h in pixel, e = ingresso, b = boss [nome, x, y] in pixel dell\'immagine.', maps: out }, null, 1) + '\n');
  fs.writeFileSync(path.join(ROOT, 'src/data/dgplan.json'), JSON.stringify({ _: "Piante dei dungeon per l'addon (src/tools/dgmaps.js): yard dall'angolo in alto a sinistra; g = terreno [FileID della minimappa, x, y] a blocchi di 533,33 yard; p = stanze [FileID della texture, x, y, larghezza, altezza, angolo, piano].", maps: plan }) + '\n');
  console.log('mappe', out.length, "· piante per l'addon", plan.length);
})();
