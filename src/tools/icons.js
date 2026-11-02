// node src/tools/icons.js → controlla che esista ogni icona mostrata in tutte le combinazioni/build (serve il server locale: preview "guida-wow", porta 8765)
const {chromium}=require(process.env.LOCALAPPDATA+'/npm-cache/_npx/9833c18b2d85bc59/node_modules/playwright-core');
(async()=>{const b=await chromium.launch({channel:'chrome'}),p=await b.newPage();await p.addInitScript(()=>localStorage.setItem('wfcLang','it'));
await p.goto('http://localhost:8765/CLAUDE/WoW%20Forever%20leveling%20companion/WoW_Forever_Leveling_Companion.html',{waitUntil:'domcontentloaded'});
const srcs=await p.evaluate(()=>{const set=new Set();const grab=()=>document.querySelectorAll('img').forEach(i=>{if(i.getAttribute('src'))set.add(i.getAttribute('src'))});
 for(const r of Object.keys(D.races))for(const c of D.races[r].classes)for(const B of (D.classes[c].builds||[{id:'a'}])){S.r=r;S.c=c;S.o.b[c]=B.id;S.o.prof=['Mining','Herbalism'];renderAll();for(const L of [1,10,20,30]){S.L=L;renderLevel()}document.getElementById('chaps').classList.add('all');renderPath();grab()}
 return [...set]});
await b.close();
const icons=srcs.filter(s=>/zamimg\.com\/images\/wow\/icons/.test(s)),other=srcs.filter(s=>!/zamimg\.com\/images\/wow\/icons|^data:|world-map/.test(s));
const bad=[];await Promise.all(icons.map(async u=>{const r=await fetch(u,{method:'HEAD'}).catch(()=>({status:0}));if(r.status!==200){const n=u.split('/').pop().replace('.jpg','');const f=await fetch('https://wowforever.be/icons/'+n+'.jpg',{method:'HEAD'}).catch(()=>({status:0}));bad.push(n+' (wowforever.be '+f.status+')')}}));
const bo=[];await Promise.all(other.map(async u=>{const r=await fetch(u,{method:'HEAD'}).catch(()=>({status:0}));if(r.status!==200)bo.push(r.status+' '+u)}));
console.log('icone controllate',icons.length,'· rotte',bad.length);console.log(bad.sort().join('\n'));console.log('altre immagini rotte',JSON.stringify(bo))})();
