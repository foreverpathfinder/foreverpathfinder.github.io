// node src/tools/test.js → prova in Chrome tutte le combinazioni razza/classe/percorso e i click-and-go (serve il server locale: preview "guida-wow", porta 8765)
const {chromium}=require(process.env.LOCALAPPDATA+'/npm-cache/_npx/9833c18b2d85bc59/node_modules/playwright-core');
(async()=>{const b=await chromium.launch({channel:'chrome'}),p=await b.newPage({viewport:{width:1100,height:900}});
const errs=[];p.on('pageerror',e=>errs.push(e.message));
await p.goto('http://localhost:8765/CLAUDE/WoW%20Forever%20leveling%20companion/WoW_Forever_Leveling_Companion.html#gnome-mage',{waitUntil:'networkidle'});
const r=await p.evaluate(async()=>{const bad=[];let n=0;
 for(const r of Object.keys(D.races))for(const c of D.races[r].classes)for(const x of [0,1]){S.r=r;S.c=c;S.o.x=x;S.o.prof=['Mining','Skinning'];
  try{renderAll();if(x&&!PT&&transferFor(D.routes[RA.start]))bad.push(r+c+' no transfer');
   for(const L of [1,10,15,20,30]){S.L=L;renderLevel();const t=document.getElementById('plan').innerText+document.getElementById('chaps').innerText;if(/undefined|NaN|\[object/.test(t))bad.push(r+'-'+c+'-'+x+'@'+L)}
   if(!document.querySelectorAll('#chaps .chap').length)bad.push(r+c+' nochap');n++}catch(e){bad.push(r+'-'+c+'-'+x+' '+e.message)}}
 // ogni build (A/B/C) di ogni classe: talent, calcolatore, planner
 for(const r of Object.keys(D.races))for(const c of D.races[r].classes)for(const B of (D.classes[c].builds||[])){S.r=r;S.c=c;S.o.x=0;S.o.b[c]=B.id;try{renderAll();for(const L of [10,20,30]){S.L=L;renderLevel();if(document.getElementById('wfLink').href.indexOf('?t=')<0)bad.push(r+c+B.id+'@'+L+' enc');if(/undefined|NaN/.test(document.getElementById('plan').innerText))bad.push(r+c+B.id+'@'+L)}n++}catch(e){bad.push(r+c+B.id+' '+e.message)}S.o.b[c]='a'}
 // checklist + go
 const cb=document.querySelector('#chaps input[data-id]');cb.click();const okc=!!S.done[CK][cb.dataset.id];
 const go=document.querySelector('#qgo .go[data-x]');go.click();await new Promise(r=>setTimeout(r,800));
 return {n,bad:bad.slice(0,10),nbad:bad.length,okc,zoom:MAP.getZoom(),popup:!!document.querySelector('.leaflet-popup')}});
console.log(JSON.stringify(r),'errors',JSON.stringify(errs.slice(0,5)));await b.close()})();
