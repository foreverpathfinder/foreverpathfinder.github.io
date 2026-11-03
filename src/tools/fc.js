// node src/tools/fc.js <classe> [out.json] → data/talents/<classe>.json dagli alberi di foreverchanges.pro (dati del client di Forever, più aggiornati di wowforever.be); tiene `order` del file vecchio.
// `link` = ordine dei nodi nei link ?b= di foreverchanges ('' = casella vuota); `wfSame` = wowforever.be ha lo stesso albero (allora la guida usa il suo calcolatore in iframe)
const fs = require('fs'), path = require('path');
const cls = process.argv[2], out = process.argv[3] || path.join(__dirname, '../data/talents/' + cls + '.json');
const URL = 'https://foreverchanges.pro/talents/' + cls;
(async () => {
  const h = await (await fetch(URL)).text();
  // payload RSC di Next.js: gli oggetti {"id":…,"kind":"talent"} hanno posizione, rank e testi
  const rsc = [...h.matchAll(/self\.__next_f\.push\(\[1,"((?:[^"\\]|\\.)*)"\]\)/g)].map(m => JSON.parse('"' + m[1] + '"')).join('');
  const objs = {};
  for (let i = 0; (i = rsc.indexOf('{"id":"', i)) >= 0; i++) {
    let d = 0, j = i, s = false;
    for (; j < rsc.length; j++) {
      const ch = rsc[j];
      if (s) { if (ch === '\\') j++; else if (ch === '"') s = false; continue; }
      if (ch === '"') s = true; else if (ch === '{') d++; else if (ch === '}' && --d === 0) break;
    }
    try { const o = JSON.parse(rsc.slice(i, j + 1)); if (o.kind === 'talent' && o.class === cls && o.calculator_eligible && o.structure && !objs[o.id]) objs[o.id] = o; } catch (e) {}
  }
  // ordine dei nodi nei link: tabella in un chunk JS della pagina (let g=JSON.parse('…'))
  let G = {};
  for (const src of new Set(h.match(/\/_next\/static\/chunks\/[\w.-]+\.js/g))) {
    const m = (await (await fetch('https://foreverchanges.pro' + src)).text()).match(/let g=JSON\.parse\('((?:[^'\\]|\\.)*)'\)/);
    if (m) { G = JSON.parse(m[1].replace(/\\'/g, "'")); break; }
  }
  if (!Object.keys(G).length) console.log(cls + ': tabella dei link non trovata, ordine per riga e colonna');
  let old = {}; try { old = JSON.parse(fs.readFileSync(path.join(__dirname, '../data/talents/' + cls + '.json'), 'utf8')); } catch (e) {}
  const slug = s => s.toLowerCase().replace(/[’']/g, '').replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
  const FLAG = { added: 'New in Forever', modified: 'Changed from Classic', moved: 'Changed from Classic' };
  const trees = [0, 1, 2].map(ti => {
    const ot = (old.trees || [])[ti], list = Object.values(objs).filter(o => o.tree_index === ti);
    if (!list.length) throw new Error(cls + ': albero ' + ti + ' vuoto');
    // nomi scritti come nel file vecchio (apostrofi diversi: le build li usano così); nome dell'albero del file vecchio (testi dell'interfaccia)
    const ap = s => s.replace(/’/g, "'"), same = {};
    if (ot) Object.values(ot.nodes).forEach(n => same[ap(n.name)] = n.name);
    const fix = s => same[ap(s)] || s;
    list.forEach(o => { o.name = fix(o.name); if (o.structure.reported_prerequisite) o.structure.reported_prerequisite = fix(o.structure.reported_prerequisite); });
    const name = ot ? ot.name : list[0].tree_name, oldKey = {};
    if (ot) Object.entries(ot.nodes).forEach(([k, n]) => oldKey[n.name] = k);
    const key = o => oldKey[o.name] || slug(o.name);
    const byName = {}; list.forEach(o => byName[o.name] = key(o));
    list.sort((a, b) => a.structure.tier - b.structure.tier || a.structure.col - b.structure.col);
    const nodes = {};
    list.forEach((o, index) => {
      const r = o.rank_texts || {}, m = o.tooltip_metadata || {}, pre = o.structure.reported_prerequisite;
      nodes[key(o)] = { index, name: o.name, icon: o.icon, row: o.structure.tier + 1, col: o.structure.col + 1, max: o.max_rank, needs: o.structure.tier * 5, req: pre ? byName[pre] || slug(pre) : '',
        flag: FLAG[o.reported_change_kind] || '', cost: m.passive === false ? [m.resource_cost, m.range, m.cast_time, m.cooldown].filter(Boolean).join(' · ') : '', r1: r[1] || '', rmax: r[o.max_rank] || r[1] || '' };
    });
    const ids = (G[list[0].tree_id] || {}).ids, keyOf = {};
    list.forEach(o => keyOf[o.id] = key(o));
    return Object.assign({ key: ot ? ot.key : slug(name), name, nodes }, ids ? { link: ids.map(id => id && keyOf[id] || '') } : {});
  });
  // wowforever.be: stessi nodi nello stesso ordine (nome + rank)?
  const w = await (await fetch('https://wowforever.be/leveling/' + cls + '/')).text();
  const ap = s => s.replace(/&#39;|&#x27;|’/g, "'").replace(/&amp;/g, '&');
  const wt = w.split('<section class="wf-tree" data-tree="').slice(1).map(sec => sec.split('<button type="button" class="wf-node"').slice(1)
    .map(b => [+(b.match(/data-index="(\d+)"/) || [])[1], (b.match(/aria-label="([^"]*)"/) || [])[1] + ':' + (b.match(/data-max="(\d+)"/) || [])[1]]).sort((a, b) => a[0] - b[0]).map(x => ap(x[1])).join('|'));
  const wfSame = trees.every((t, i) => wt[i] === Object.values(t.nodes).sort((a, b) => a.index - b.index).map(n => ap(n.name) + ':' + n.max).join('|'));
  fs.writeFileSync(out, JSON.stringify({ cls, src: URL, fetched: new Date().toISOString().slice(0, 10), wfSame, trees, order: old.order || [] }, null, 1));
  console.log(cls, trees.map(t => t.name + ':' + Object.keys(t.nodes).length).join(' '), wfSame ? '· wowforever.be uguale' : '· wowforever.be DIVERSO');
})();
