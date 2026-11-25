// Guide di Mobalytics (mobalytics.gg/wow-forever/classes/<classe>-leveling-guide): WebFetch dà 403, si leggono dal browser integrato.
//   node src/tools/mobalytics.js talenti     → stampa il codice da eseguire sulla pagina (javascript_tool): per ogni scheda della guida
//                                               «punti (n)|Talento k, Talento k, …» = ordine dei talent dal 10 al 60
//   node src/tools/mobalytics.js rotazione   → codice che legge la sezione «Gameplay and Rotation» (clic su ogni sotto-scheda per fascia);
//                                               prima imposta window.__want = ['Nome scheda'] se la guida ha più build (es. 'Affliction 1-60')
//   node src/tools/mobalytics.js confronta <classe> <a|b|c|main> "<riga di talenti>"   → livelli in cui la build è diversa dalla nostra
// La lista con i ♥ è mobalytics.gg/wow-forever/leveling-guides (clic su «Show more» fino in fondo).
const TALENTI = `const W=ms=>new Promise(r=>setTimeout(r,ms)); await W(3000);
const grp=a=>{const o=[];a.forEach(n=>{const l=o[o.length-1];if(l&&l[0]===n)l[1]++;else o.push([n,1])});return o.map(x=>x[0]+' '+x[1]).join(', ')};
const parse=()=>{const t=document.body.innerText,k=t.indexOf('Points spent');if(k<0)return null;const seg=t.slice(k,k+3500).split('\\n').map(x=>x.trim()).filter(Boolean);const i=seg.indexOf('Leveling Path');const pts=seg.slice(2,i).join('');const out=[];for(let j=i+1;j+1<seg.length;j+=2){if(!/^\\d+$/.test(seg[j])||+seg[j]!==10+out.length)break;out.push(seg[j+1])}return pts+' ('+out.length+')|'+grp(out)};
const t0=document.body.innerText,k0=t0.indexOf('Points spent');const before=t0.slice(0,k0).split('\\n').map(x=>x.trim()).filter(Boolean);const hd=Math.max(before.lastIndexOf('Talents'),...before.map((x,i)=>/Talent Builds?$/.test(x)?i:-1));const names=before.slice(hd+1);
const res={data:t0.split('\\n').slice(0,24).filter(x=>/202\\d/.test(x)).join(' ')};
if(!names.length||names.length>6)res._=parse();else for(const n of names){const el=[...document.querySelectorAll('*')].filter(e=>e.children.length===0&&e.textContent.trim()===n).pop();if(el){el.click();await W(900);res[n]=parse()}}
JSON.stringify(res,null,1)`;
const ROTAZIONE = `const W=ms=>new Promise(r=>setTimeout(r,ms)); await W(3000);
const pos=()=>{const t=document.body.innerText;return [t,t.indexOf('Rotation\\n',t.lastIndexOf('Leveling Path'))]};
const cap=()=>{const [t,j]=pos();const e=t.indexOf('Level Walkthrough',j);return t.slice(j+9,e>0?e:j+3000).replace(/\\n+/g,' ')};
const [t,j]=pos();const labels=[];for(const l of t.slice(j+9,j+400).split('\\n').map(x=>x.trim())){if(!l||labels.length>7)break;labels.push(l)}
const click=n=>{const el=[...document.querySelectorAll('*')].filter(e=>e.children.length===0&&e.textContent.trim()===n).pop();if(el)el.click()};
const want=window.__want||[];const out={labels};for(const w of want){click(w);await W(800)}
const br=labels.filter(l=>!want.includes(l)&&!/1-60|PvP|Respec|First/.test(l));
if(!br.length)out.main=cap().slice(0,2500);for(const b of br){click(b);await W(800);out[b]=cap().slice(0,1800)}
JSON.stringify(out)`;
const [cmd, cls, id, s] = process.argv.slice(2);
if (cmd === 'talenti') console.log(TALENTI);
else if (cmd === 'rotazione') console.log(ROTAZIONE);
else if (cmd === 'confronta') {
  const c = require('../data/classes/' + cls + '.json');
  const ours = id === 'main' || id === 'a' ? c.build : c.builds.find(b => b.id === id).build;
  const theirs = []; for (const p of s.split('|')[1].split(', ')) { const m = p.match(/^(.*) (\d+)$/); for (let i = 0; i < +m[2]; i++) theirs.push(m[1]); }
  const d = []; for (let i = 0; i < 51; i++) if (ours[i] !== theirs[i]) d.push((10 + i) + ': nostro ' + ours[i] + ' / loro ' + theirs[i]);
  console.log(cls, id, s.split('|')[0], d.length ? '\n  ' + d.join('\n  ') : 'UGUALE');
} else console.log('uso: talenti | rotazione | confronta <classe> <a|b|c> "<riga>"');
