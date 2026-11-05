// node src/tools/addon.js → esporta per l'addon in gioco (addon/ForeverPathfinder/Data.lua) tutta la guida di ogni razza/classe,
// in italiano e inglese, leggendola dalla pagina già generata (stesso motore del sito) per ogni combinazione delle opzioni che
// l'addon permette di scegliere: build, dungeon sì/no, cambio continente (niente profession). Testi e pagine delle schede vanno in
// un elenco unico senza doppioni (Pool); ogni variante li richiama per numero. Poi crea ForeverPathfinder.zip da scaricare dal sito
const {chromium}=require(process.env.LOCALAPPDATA+'/npm-cache/_npx/9833c18b2d85bc59/node_modules/playwright-core');
const fs=require('fs'),path=require('path'),{execFileSync}=require('child_process');
const ROOT=path.join(__dirname,'../..'),OUT=path.join(ROOT,'addon/ForeverPathfinder');
// schede del sito portate nell'addon (Percorso e Mappa sono disegnate dall'addon stesso)
const TABS=['talent','classe','prof','dungeon','alt','altro','info'];
// i font di WoW mostrano solo l'alfabeto latino di base: via emoji e simboli, le frecce diventano "->", "|" è un codice di WoW
const clean=s=>s.replace(/→/g,'->').replace(/\|/g,'/').replace(/[^\x20-\xFF–—‘’“”…•‹›€\n]/g,'').replace(/[ \t]+/g,' ').replace(/ *\n */g,'\n').trim();
const lua=s=>'"'+String(s).replace(/\\/g,'\\\\').replace(/"/g,'\\"').replace(/\n/g,'\\n')+'"';
(async()=>{const b=await chromium.launch({channel:'chrome'}),all={};
 for(const [f,l] of [['','it'],['_EN','en']]){const p=await b.newPage();await p.addInitScript(l=>localStorage.setItem('wfcLang',l),l);
  await p.goto('file:///'+path.join(ROOT,'WoW_Forever_Leveling_Companion'+f+'.html').replace(/\\/g,'/')+'#gnome-mage',{waitUntil:'load'});
  all[l]=await p.evaluate(TABS=>{
   // una scheda del sito → righe: "1"/"2"/"3" titoli, "0" paragrafi; grassetto tra \x01 e \x02 (l'addon lo colora)
   const SKIP=/^(BUTTON|INPUT|SELECT|TEXTAREA|IMG|SVG|SCRIPT|STYLE|CANVAS|DIALOG|NAV)$/,BLOCK=/^(DIV|P|UL|OL|LI|TABLE|THEAD|TBODY|TR|H1|H2|H3|H4|H5|DETAILS|SUMMARY|SECTION|HEADER|FOOTER|BLOCKQUOTE|PRE|FIGURE|LABEL|DL|DT|DD)$/;
   // via ciò che vale solo sul sito: mappe, il calcolatore dei talent (iframe di wowforever.be), i pulsanti-link
   const hidden=e=>e.hidden||e.getAttribute('aria-hidden')==='true'||e.style.display==='none'||e.classList.contains('lwrap')||e.id==='wfBox'||e.classList.contains('wfhead')||e.classList.contains('wfmodes')||(e.previousElementSibling||{}).id==='wfBox'||(e.tagName==='A'&&e.classList.contains('btn'));
   // elementi non "inline" (span in flex o in griglia) sul sito sono separati dal layout: qui da uno spazio
   // icona del gioco (Wowhead usa gli stessi nomi del client): \x03nome\x04, poi la riga la porta davanti come "^nome^"
   const ico=n=>{const m=(n.getAttribute('src')||'').match(/zamimg\.com\/images\/wow\/icons\/\w+\/([\w-]+)\.jpg/);return m?'\x03'+m[1]+'\x04':''};
   const inl=n=>{if(n.nodeType===3)return n.textContent;if(n.nodeType===1&&n.tagName==='IMG')return ico(n);if(n.nodeType!==1||SKIP.test(n.tagName)||hidden(n))return'';if(n.tagName==='BR')return'\n';
    const t=[].map.call(n.childNodes,inl).join(''),sp=getComputedStyle(n).display!=='inline'?' ':'';return sp+(/^(B|STRONG)$/.test(n.tagName)&&t.trim()?'\x01'+t+'\x02':t)+sp};
   // le icone della riga vanno davanti (al massimo 8, es. la sequenza della rotation): tipo + "^nome,nome^" + testo
   const icoFront=x=>{const m=[...new Set([...x.matchAll(/\x03([^\x04]+)\x04/g)].map(z=>z[1]))].slice(0,8),r=x.slice(1).replace(/\x03[^\x04]*\x04/g,'').replace(/^\s+/,'');return m.length?x[0]+'^'+m.join(',')+'^'+r:x[0]+r};
   const lines=root=>{const out=[];let buf='';const flush=()=>{const t=buf.replace(/\s*\n\s*/g,'\n').replace(/[ \t\r]+/g,' ').trim();if(t.replace(/[\x01\x02]|\x03[^\x04]*\x04/g,'').trim())out.push('0'+t);buf=''};
    const walk=el=>{for(const n of el.childNodes){
     if(n.nodeType!==1||!BLOCK.test(n.tagName)){buf+=inl(n);continue}
     if(hidden(n))continue;flush();const tg=n.tagName;
     if(/^H[1-5]$/.test(tg)||tg==='SUMMARY'){const t=inl(n).replace(/[\x01\x02]/g,'').replace(/\s+/g,' ').trim();if(t)out.push((tg==='H2'?'1':tg==='H3'?'2':'3')+t);continue}
     if(tg==='TR'){const c=[].map.call(n.children,td=>{const t=inl(td).replace(/\s+/g,' ').trim();return td.tagName==='TH'&&t?'\x01'+t+'\x02':t}).filter(x=>x.replace(/[\x01\x02]/g,'').trim());if(c.length)out.push('0'+c.join(' · '));continue}
     if(tg==='LI'&&![].some.call(n.children,c=>BLOCK.test(c.tagName))){const t=inl(n).replace(/\s+/g,' ').trim();if(t)out.push('0• '+t);continue}
     walk(n);flush()}};
    // via le istruzioni per i pulsanti del sito ("Tocca un dungeon…", "Tap a class…")
    // e i titoli rimasti senza contenuto (es. "Scegli la build": sul sito sono schede da toccare, qui si sceglie nelle Opzioni)
    walk(root);flush();const o=out.map(icoFront).filter(x=>!/^0(\^[^^]*\^)?(Tocca|Tap) /.test(x));
    return o.filter((x,i)=>x[0]==='0'||(o[i+1]&&(o[i+1][0]==='0'||o[i+1][0]>x[0])))};
   const out={};
   for(const r of Object.keys(D.races))for(const c of D.races[r].classes){if(!D.classes[c])continue;
    S.r=r;S.c=c;S.o.prof=[];S.o.tal=0;S.o.x=0;S.o.dg=1;S.o.b[c]=undefined;bind();
    const builds=(CL.builds||[]).map(x=>[x.id,x.name]),xs=transferFor(D.routes[RA.start])?[0,1]:[0],v={};
    for(const bb of builds.length?builds.map(x=>x[0]):['a'])for(const dg of [1,0])for(const x of xs){
     S.o.b[c]=bb;S.o.dg=dg;S.o.x=x;renderAll();
     const ch=[],tasks=[];document.querySelectorAll('#chaps .chap').forEach((d,i)=>{ch.push(d.querySelector('summary b').textContent);
      // solo il testo della voce: via i pulsanti (mappa, calcolatore), liste separate da "; "
      d.querySelectorAll('label.task').forEach(t=>{const y=t.querySelector('.tx').cloneNode(true);y.querySelectorAll('button,a').forEach(e=>e.remove());y.querySelectorAll('br').forEach(e=>e.replaceWith(' '));y.querySelectorAll('li').forEach(e=>e.append('; '));
       const im=t.querySelector('img.ic'),ic=im?ico(im).replace(/^\x03(.*)\x04$/,'^$1^'):'';
       // segnaposti 📍 (coordinate globali della mappa del sito) e nomi in grassetto (candidati quest)
       const pins=[...t.querySelectorAll('button.go[data-x]')].map(e=>[+e.dataset.x,+e.dataset.y,e.textContent.replace(/^\W+/,'').trim()]);
       const bold=[...t.querySelectorAll('.tx b')].map(e=>e.textContent.replace(/[:\s]+$/,'').trim());
       tasks.push([parseInt(t.querySelector('.lv').textContent.replace(/\D/g,''))||1,i+1,ic+y.textContent.replace(/;\s*$/,'').trim(),pins,bold,t.querySelector('input[data-id]').dataset.id])})});
     const tal=CL.build.map((k,i)=>{const t=TAL.trees.filter(z=>z[0]===k.split('/')[0])[0];return [i+10,TAL.n[k][0],t?t[1]:'']});
     const tabs={};for(const t of TABS){const e=document.getElementById('t-'+t);tabs[t]=e?lines(e):[]}
     v[bb+dg+x]={build:CL.B?CL.B.name:CL.spec,ch,tasks,tal,tabs}}
    out[r+'-'+c]={name:RA.name+' '+CL.name,faction:RA.faction,builds,xs,v}}
   // dungeon per fazione, come nella scheda Dungeon: livelli, giudizio, ingresso, quest (anche di classe)
   const G=(D.dungeons||{}).dungeons||{},dg={};
   for(const f of ['A','H'])dg[f]=D.factions[f].dungeons.filter(d=>d[1]<=MAXL+2).map(d=>{const x=G[d[0].replace(/[★✔🟡]/g,'').trim().replace(/^The /,'').toLowerCase()]||{},v=(x.v||{})[f]||[],q=x.q||{},last=a=>a.filter(s=>typeof s==='string').pop()||'';
    return [d[0].replace(/[★✔🟡]/g,'').trim(),d[1],d[2],v[0]||'',v[1]||'',v[2]||'',x.e||'',(q[f]||[]).concat(q.N||[]).map(y=>[y[0],last(y.slice(1))]),(q.C||[]).map(y=>[y[0],y[1],last(y.slice(2))])]});
   out._dg=dg;out._dgpos=D.map.dg.map(d=>[d[0],d[2],d[3]]);out._tabs=[...document.querySelectorAll('nav button[data-tab]')].map(x=>[x.dataset.tab,x.textContent.trim()]);return out},TABS);await p.close()}
 await b.close();
 // elenco unico dei testi (voci della checklist e pagine delle schede): ogni testo una volta sola
 const pool=[],pix=new Map(),P=s=>{s=clean(s);if(!pix.has(s)){pix.set(s,pool.length+1);pool.push(s)}return pix.get(s)};
 // pagina di una scheda → numeri delle sue righe ("1…", "2…", "3…" titoli, "0…" paragrafi; grassetto tra { }): righe uguali in più varianti una volta sola
 // e la pagina stessa (lista di numeri) va nell'elenco Pages, perché molte varianti hanno la stessa
 const pages=[],gix=new Map(),G=k=>{if(!gix.has(k)){gix.set(k,pages.length+1);pages.push(k)}return gix.get(k)},page=ls=>G(ls.map(x=>P(x.replace(/\x01/g,'{').replace(/\x02/g,'}'))).join(','));
 // collegamenti col gioco per ogni voce: segnaposti (continente k/e/z e posizione 0–1 sulla sua mappa, dalla tela unica del sito)
 // e quest nominate in grassetto che esistono davvero in Forever (indice quests.txt), per spuntare la voce alla consegna
 const WM=JSON.parse(fs.readFileSync(path.join(ROOT,'src/data/worldmap.json'),'utf8')).continents,CONT={kalimdor:'k','eastern-kingdoms':'e','zephras-isle':'z'};
 const where=(x,y)=>{for(const [k,c] of Object.entries(WM))if(x>=c.ox&&x<c.ox+c.w&&y>=c.oy&&y<c.oy+c.h)return [CONT[k],(x-c.ox)/c.w,(y-c.oy)/c.h];return null};
 const QN=new Set(fs.readFileSync(path.join(ROOT,'src/data/quests.txt'),'utf8').split('\n').map(x=>x.split(' | ')[0].trim()).filter(Boolean));
 // la stessa frase può avere segnaposti diversi per razza (es. "Trainer: Fireball…": Northshire per l'Human, Anvilmar per lo Gnome):
 // allora prende un altro numero dell'elenco, con lo stesso testo, perché l'addon legge i collegamenti per numero
 const ext=new Map(),sig=new Map(),Tk=t=>{const pins=t[3].map(p=>{const w=where(p[0],p[1]);return w&&[w[0],w[1].toFixed(4),w[2].toFixed(4),clean(p[2])]}).filter(Boolean),q=[...new Set(t[4].filter(x=>QN.has(x)))];
  const e=(pins.length||q.length)?{pins,q}:null,k=clean(t[2])+'\x00'+JSON.stringify(e);if(sig.has(k))return sig.get(k);
  let i=P(t[2]);if(ext.has(i)){pool.push(clean(t[2]));i=pool.length}ext.set(i,e);sig.set(k,i);return i};
 let s='-- generato da src/tools/addon.js: non modificare a mano\nForeverPathfinderData = {\n';
 const pools={},pagesL={},links={};
 for(const l of ['it','en']){pool.length=0;pix.clear();pages.length=0;gix.clear();ext.clear();sig.clear();s+=' '+l+' = {\n';
  s+='  _tabs = { '+all[l]._tabs.filter(t=>TABS.includes(t[0])||t[0]==='livello').map(t=>'{ '+lua(t[0])+', '+lua(clean(t[1]))+' }').join(', ')+' },\n';
  for(const [k,g] of Object.entries(all[l]))if(k[0]!=='_'){
   s+='  ['+lua(k)+'] = { name = '+lua(g.name)+', faction = '+lua(g.faction)+', x = '+(g.xs.length>1)+',\n   builds = { '+g.builds.map(x=>'{ '+lua(x[0])+', '+lua(clean(x[1]))+' }').join(', ')+' },\n   v = {\n';
   for(const [vk,v] of Object.entries(g.v))
    // ch e tasks ("livello,tappa,testo;…" con i numeri dell'elenco unico) stanno in Pages, lette solo quando servono
    s+='    ['+lua(vk)+'] = { build = '+lua(clean(v.build))+', ch = '+G(v.ch.map(P).join(','))+', tasks = '+G(v.tasks.map(t=>t[0]+','+t[1]+','+Tk(t)+','+t[5]).join(';'))+
     // tal: "nome:albero;…" dal livello 10, uguale per tutte le varianti della stessa build
     ', tal = '+P(v.tal.map(t=>t[1]+':'+t[2]).join(';'))+',\n     tabs = { '+TABS.map(t=>t+' = '+page(v.tabs[t])).join(', ')+' } },\n';
   s+='   },\n  },\n'}
  s+=' },\n';pools[l]=pool.slice();pagesL[l]=pages.slice();links[l]=[...ext].filter(e=>e[1])}
 s+='}\n-- elenco unico dei testi: le varianti li richiamano per numero\nForeverPathfinderPool = {\n';
 for(const l of ['it','en'])s+=' '+l+' = {\n'+pools[l].map(x=>'  '+lua(x)+',').join('\n')+'\n },\n';
 s+='}\n-- pagine delle schede, tappe e checklist: numeri dell\'elenco unico separati da , (e ; tra le voci della checklist)\nForeverPathfinderPages = {\n';
 for(const l of ['it','en'])s+=' '+l+' = {\n'+pagesL[l].map(x=>'  '+lua(x)+',').join('\n')+'\n },\n';
 // collegamenti delle voci (numero del testo): p = segnaposti { continente, x, y, nome }, q = quest da consegnare
 s+='}\nForeverPathfinderLinks = {\n';
 for(const l of ['it','en'])s+=' '+l+' = {\n'+links[l].map(([i,e])=>'  ['+i+'] = { p = { '+e.pins.map(p=>'{ '+lua(p[0])+', '+p[1]+', '+p[2]+', '+lua(p[3])+' }').join(', ')+' }, q = { '+e.q.map(lua).join(', ')+' } },').join('\n')+'\n },\n';
 // dungeon: { nome, min, max, giudizio go/opt/skip, livello ideale, perché, ingresso, {quest, dove}, {quest di classe, classe, dove} }
 const tx=x=>lua(clean(String(x).replace(/<[^>]+>/g,'')));
 s+='}\nForeverPathfinderDungeons = {\n';
 for(const l of ['it','en']){s+=' '+l+' = {\n';
  for(const f of ['A','H'])s+='  '+f+' = {\n'+all[l]._dg[f].map(d=>'   { '+tx(d[0])+', '+d[1]+', '+d[2]+', '+lua(d[3])+', '+tx(d[4])+', '+tx(d[5])+', '+tx(d[6])+',\n    { '+d[7].map(q=>'{ '+tx(q[0])+', '+tx(q[1])+' }').join(', ')+' },\n    { '+d[8].map(q=>'{ '+tx(q[0])+', '+lua(q[1])+', '+tx(q[2])+' }').join(', ')+' } },').join('\n')+'\n  },\n';
  s+=' },\n'}
 // ingressi dei dungeon (icone della mappa del sito): { nome, continente, x, y } per il pulsante Mappa della scheda Dungeon
 s+='}\nForeverPathfinderDungeonPos = {\n'+all.it._dgpos.map(d=>{const w=where(d[1],d[2]);return w&&'  { '+lua(clean(d[0]))+', '+lua(w[0])+', '+w[1].toFixed(4)+', '+w[2].toFixed(4)+' },'}).filter(Boolean).join('\n')+'\n';
 // zone del gioco (uiMapID e rettangolo 0–1 sul continente del sito, da uimaps.json): l'addon ci converte i segnaposti, perché
 // i bordi della mappa del continente nel gioco non sono quelli di Wowhead, quelli delle zone sì
 const UM=JSON.parse(fs.readFileSync(path.join(ROOT,'src/data/uimaps.json'),'utf8')).continents;
 s+='}\nForeverPathfinderZoneMaps = {\n'+Object.entries(UM).map(([k,a])=>{const c=WM[k];return '  '+CONT[k]+' = { '+a.map(z=>'{ '+z[0]+', '+(z[2]/c.w).toFixed(4)+', '+(z[3]/c.h).toFixed(4)+', '+(z[4]/c.w).toFixed(4)+', '+(z[5]/c.h).toFixed(4)+', '+lua(z[1])+' }').join(', ')+' },'}).join('\n')+'\n';
 fs.writeFileSync(path.join(OUT,'Data.lua'),s+'}\n');
 const zip=path.join(ROOT,'ForeverPathfinder.zip');if(fs.existsSync(zip))fs.unlinkSync(zip);
 // tar di Windows (non quello di Git, che non fa zip): percorsi con / (lo zip di PowerShell usa \ e su Mac si estrae male)
 execFileSync(path.join(process.env.SystemRoot,'System32/tar.exe'),['-a','-c','-f',zip,'-C',path.dirname(OUT),path.basename(OUT)]);
 const nv=Object.values(all.it).filter(g=>g.v).reduce((a,g)=>a+Object.keys(g.v).length,0);
 console.log('Data.lua',(fs.statSync(path.join(OUT,'Data.lua')).size/1024).toFixed(0),'KB ·',Object.keys(all.it).filter(k=>k[0]!=='_').length,'combinazioni ·',nv,'varianti · testi',pools.it.length,'/',pools.en.length,'· zip',(fs.statSync(zip).size/1024).toFixed(0),'KB')})();
