// node src/tools/wf.js <classe> [out.json] → data/talents/<classe>.json: talenti (dati client) + build di leveling 10–60 di wowforever.be
const fs=require("fs");const cls=process.argv[2],out=process.argv[3]||require("path").join(__dirname,"../data/talents/"+cls+".json");
(async()=>{const h=await (await fetch('https://wowforever.be/leveling/'+cls+'/')).text();
const dec=s=>s.replace(/<[^>]+>/g,'').replace(/&amp;/g,'&').replace(/&#39;|&#x27;/g,'’').replace(/&quot;/g,'"').trim();
const trees=[];h.split('<section class="wf-tree" data-tree="').slice(1).forEach(sec=>{const tk=sec.slice(0,sec.indexOf('"'));
 const name=dec((sec.match(/wf-tree__name">([^<]*)/)||[])[1]||tk);const nodes={};
 sec.split('<button type="button" class="wf-node"').slice(1).forEach(b=>{const a=k=>(b.match(new RegExp(k+'="([^"]*)"'))||[])[1];
  const ranks=[...b.matchAll(/wf-tip__rank"><b>[^<]*<\/b>(.*?)<\/span>/g)].map(m=>dec(m[1]));
  const st=b.match(/grid-row:(\d+);grid-column:(\d+)/)||[];
  nodes[a("data-node")]={index:+a("data-index"),name:dec(a('aria-label')||''),icon:(b.match(/icons\/([a-z0-9_]+)\.jpg/)||[])[1],row:+st[1],col:+st[2],max:+a('data-max'),needs:+a('data-needs'),req:a('data-requires')||'',
   flag:dec((b.match(/wf-tip__flag">([^<]*)/)||[])[1]||''),cost:dec((b.match(/wf-tip__cost">([^<]*)/)||[])[1]||''),r1:ranks[0]||'',rmax:ranks[ranks.length-1]||''}});
 trees.push({key:tk,name,nodes})});
const order=[...h.matchAll(/class="wf-levelrow[^"]*" data-point="(\d+)" data-key="([^"]+)"><span class="wf-levelrow__level" data-row-level>(\d+)/g)].map(m=>[+m[3],m[2]]);
fs.writeFileSync(out,JSON.stringify({cls,src:'https://wowforever.be/leveling/'+cls+'/',fetched:new Date().toISOString().slice(0,10),trees,order},null,1));
const cnt={};order.filter(o=>o[0]<=30).forEach(o=>{const t=o[1].split('/')[0];cnt[t]=(cnt[t]||0)+1});
console.log(cls,trees.map(t=>t.name+':'+Object.keys(t.nodes).length).join(' '),'order',order.length,'≤30:',JSON.stringify(cnt))})();
