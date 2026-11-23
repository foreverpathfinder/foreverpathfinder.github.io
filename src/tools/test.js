// node src/tools/test.js [it,en,es,fr] → prova in Chrome, in ogni lingua, tutte le combinazioni razza/classe/percorso e i click-and-go; nelle pagine non italiane cerca anche
// testo italiano rimasto (nita), in spagnolo e francese anche frasi inglesi rimaste (neng: fuori da grassetto, link e codice, nomi di spell e talenti a parte).
// Le frasi trovate vanno in src/i18n/rimasto-<lingua>.txt. Serve il server locale: preview "guida-wow", porta 8765
const {chromium}=require(process.env.LOCALAPPDATA+'/npm-cache/_npx/9833c18b2d85bc59/node_modules/playwright-core');
const fs=require('fs'),path=require('path'),PAGES={it:'',en:'_EN',es:'_ES',fr:'_FR'},ONLY=(process.argv[2]||'it,en,es,fr').split(',');
const ENJ=JSON.parse(fs.readFileSync(path.join(__dirname,'../i18n/en.json'),'utf8')),IDN=Object.keys(ENJ).filter(k=>ENJ[k]===k&&k.length>3&&!/<|\s(the|and|with|you|your|from)\s.*\s(the|and|with|you|your|from)\s/i.test(k)).sort((a,b)=>b.length-a.length);
(async()=>{const b=await chromium.launch({channel:'chrome'});
for(const lang of ONLY){const f=PAGES[lang],p=await b.newPage({viewport:{width:1100,height:900}});await p.addInitScript(l=>localStorage.setItem('wfcLang',l),lang);
const errs=[];p.on('pageerror',e=>errs.push(e.message));
await p.goto('http://localhost:'+(process.env.PORT||8765)+'/'+encodeURI(path.relative(require('os').homedir()+'/Desktop',path.join(__dirname,'../..')).split(path.sep).join('/'))+'/WoW_Forever_Leveling_Companion'+f+'.html#gnome-mage',{waitUntil:'networkidle'});
const r=await p.evaluate(async()=>{const bad=[];let n=0;const LG=document.documentElement.lang;
 // pagine non italiane: testo (anche delle schede nascoste) con parole italiane (nomi di gioco a parte non ce ne devono essere);
 // le parole comuni anche alla lingua della pagina non contano (cosa e fino in spagnolo, il e non in francese)
 const SAME={es:['cosa','fino'],fr:['il','non']}[LG]||[];
 const ita=new Set(),IT=new RegExp('[^.!?;:]{0,40}(?<![\\wÀ-ÿ’\'-])('+'della|delle|degli|dello|nella|nelle|che|non|sono|anche|più|già|quando|dopo|oppure|puoi|devi|è|il|livello|livelli|razza|perché|questo|questa|ogni|alla|alle|dal|dalla|sulla|cosa|fino|tutte|tutti'.split('|').filter(w=>!SAME.includes(w)).join('|')+')(?![\\wÀ-ÿ’\'-])[^.!?;:]{0,40}','gi');
 // spagnolo e francese: frasi inglesi fuori da grassetto, corsivo, link e codice (lì stanno i nomi di gioco), tolti i nomi di spell e talenti
 const eng=new Set(),EW=/[^.!?;:]{0,40}(?<![\wÀ-ÿ’'-])(the|and|with|you|your|when|after|before|from|this|that|which|until|then|only|into|while|because|should|level|levels|quests? giver|to get|you can)(?![\wÀ-ÿ’'-])[^.!?;:]{0,40}/gi;
 const NAMES=[...new Set([].concat(...Object.values(D.classes).map(c=>(c.spells||[]).concat(c.talentSpells||[]).map(s=>s[1])),...Object.values(D.talents).map(t=>Object.values(t.n||{}).map(x=>x[0]))))].filter(x=>x&&x.length>3).sort((a,b)=>b.length-a.length);
 const plain=q=>{const o=[],w=document.createTreeWalker(document.querySelector(q),NodeFilter.SHOW_TEXT);let x;while(x=w.nextNode())if(!x.parentElement.closest('a,code,b,strong,i,script,style'))o.push(x.nodeValue);let s=o.join('\n');for(const nm of NAMES)s=s.split(nm).join(' ');return s};
 const scan=()=>{if(LG==='it')return;['header','#home','#cbar','main','footer'].forEach(q=>{const s=document.querySelector(q).textContent;let m;IT.lastIndex=0;while(m=IT.exec(s))ita.add(m[0].trim());
  if(LG==='es'||LG==='fr'){const t=plain(q);EW.lastIndex=0;while(m=EW.exec(t))eng.add(m[0].trim())}})};
 for(const r of Object.keys(D.races))for(const c of D.races[r].classes)for(const x of [0,1]){S.r=r;S.c=c;S.o.x=x;S.o.prof=['Mining','Skinning'];
  try{renderAll();if(x&&!PT&&transferFor(D.routes[RA.start]))bad.push(r+c+' no transfer');
   for(const L of [1,10,15,20,30]){S.L=L;renderLevel();const t=document.getElementById('plan').innerText+document.getElementById('chaps').innerText;if(/undefined|NaN|\[object/.test(t))bad.push(r+'-'+c+'-'+x+'@'+L)}
   if(!document.querySelectorAll('#chaps .chap').length)bad.push(r+c+' nochap');scan();n++}catch(e){bad.push(r+'-'+c+'-'+x+' '+e.message)}}
 // ogni build (A/B/C) di ogni classe: talent, calcolatore, planner
 for(const r of Object.keys(D.races))for(const c of D.races[r].classes)for(const B of (D.classes[c].builds||[])){S.r=r;S.c=c;S.o.x=0;S.o.b[c]=B.id;try{renderAll();for(const L of [10,20,30]){S.L=L;renderLevel();if(!/[?]t=|[?]b=/.test(document.getElementById('wfLink').href))bad.push(r+c+B.id+'@'+L+' enc');if(/undefined|NaN/.test(document.getElementById('plan').innerText))bad.push(r+c+B.id+'@'+L)}n++}catch(e){bad.push(r+c+B.id+' '+e.message)}S.o.b[c]='a'}
 // checklist + go
 const cb=document.querySelector('#chaps input[data-id]');cb.click();const okc=!!S.done[CK][cb.dataset.id];
 const go=document.querySelector('#qgo .go[data-x]');go.click();await new Promise(r=>setTimeout(r,800));
 goHome(true);scan();
 return {lang:LG,n,bad:bad.slice(0,10),nbad:bad.length,okc,zoom:MAP.getZoom(),popup:!!document.querySelector('.leaflet-popup'),ita:[...ita],eng:[...eng]}});
// frasi inglesi: non contano quelle che lo sono solo per nomi propri rimasti in inglese (testi uguali in italiano e in inglese: zone, quest, fonti)
const EW=/(?<![\w’'-])(the|and|with|you|your|when|after|before|from|this|that|which|until|then|only|into|while|because|should|level|levels|quests? giver|to get|you can)(?![\w’'-])/i;
r.eng=r.eng.filter(s=>{for(const n of IDN)if(s.includes(n))s=s.split(n).join(' ');return EW.test(s)});
const left=[...r.ita,...r.eng];r.nita=r.ita.length;if(lang==='es'||lang==='fr')r.neng=r.eng.length;delete r.ita;delete r.eng;
console.log(JSON.stringify(r),'errors',JSON.stringify(errs.slice(0,5)));
const out=path.join(__dirname,'../i18n/rimasto-'+lang+'.txt');if(left.length)fs.writeFileSync(out,left.join('\n')+'\n');else if(fs.existsSync(out))fs.unlinkSync(out);await p.close()}
await b.close()})();
