// node src/tools/addon-preview.js itIT|enUS [scheda] [cartella] → anteprima fedele della finestra dell'addon (PNG nella cartella, di base quella attuale):
// l'addon vero gira in un WoW finto (addon-preview.lua) che registra ogni texture e ogni testo con posizione e stile;
// le misure dei testi (altezza con a capo, larghezza) vengono dal browser con gli stessi caratteri (due passate), poi si disegna in HTML
const fs=require('fs');
const {lua,lauxlib,lualib,to_luastring}=require(process.env.LOCALAPPDATA+'/fp-lua/node_modules/fengari');
const {chromium}=require(process.env.LOCALAPPDATA+'/npm-cache/_npx/9833c18b2d85bc59/node_modules/playwright-core');
const O=(process.argv[4]||process.cwd()).replace(/\\/g,'/');
const ADDON=require('path').join(__dirname,'../../addon/ForeverPathfinder').replace(/\\/g,'/');
const LANG=process.argv[2]||'itIT',ONLY=process.argv[3]&&process.argv[3]!=='tutte'?process.argv[3]:'';
const LUA=fs.readFileSync(__dirname+'/addon-preview.lua','utf8');
function run(meas){
 const L=lauxlib.luaL_newstate();lualib.luaL_openlibs(L);
 for(const [k,v] of Object.entries({DIR:ADDON,LOCALE:LANG,MEAS:JSON.stringify(meas),ONLY:ONLY||'',PV:process.env.PV||''})){lua.lua_pushstring(L,to_luastring(v));lua.lua_setglobal(L,to_luastring(k))}
 if(lauxlib.luaL_loadstring(L,to_luastring(LUA))||lua.lua_pcall(L,0,0,0)){console.log(lua.lua_tojsstring(L,-1));process.exit(1)}
 lua.lua_getglobal(L,to_luastring('OUT'));return JSON.parse(lua.lua_tojsstring(L,-1))}
const FONT=n=>'data:font/ttf;base64,'+fs.readFileSync(ADDON+'/Fonts/'+n).toString('base64');
// caratteri dell'addon (1.10: Barlow e Barlow Condensed): una famiglia per file, col nome del file
const FILES=fs.readdirSync(ADDON+'/Fonts').filter(n=>n.endsWith('.ttf'));
const FACES=FILES.map(n=>`@font-face{font-family:'${n.slice(0,-4)}';src:url('${FONT(n)}')}`).join('');
const fam=file=>"'"+String(file).replace(/.ttf$/,'')+"'";
const plain=s=>s.replace(/\|c[0-9a-fA-F]{8}/g,'').replace(/\|r/g,'');
const esc=s=>s.replace(/[&<>]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;'})[c]);
const colored=(s,base)=>esc(s).replace(/\|c[0-9a-fA-F]{2}([0-9a-fA-F]{6})/g,'<span style="color:#$1">').replace(/\|r/g,'</span>').replace(/\n/g,'<br>');
(async()=>{const b=await chromium.launch({channel:'chrome'});const p=await b.newPage();
 await p.setContent(`<html><head><style>${FACES}</style></head><body></body></html>`);
 // passata 1: quali testi vanno misurati
 const r1=run({});
 const reqs=r1.reqs;
 const meas=await p.evaluate(async({reqs,FACES})=>{await Promise.all([...document.fonts].map(f=>f.load()));const out={};
  const d=document.createElement('div');d.style.cssText='position:absolute;left:0;top:0;line-height:1.2;white-space:pre-wrap;word-wrap:break-word';document.body.appendChild(d);
  for(const q of reqs){d.style.fontFamily=q.fam;d.style.fontWeight='400';d.style.fontSize=q.size+'px';
   if(q.w>0){d.style.width=q.w+'px';d.style.whiteSpace='pre-wrap'}else{d.style.width='auto';d.style.whiteSpace='pre'}
   d.textContent=q.t;const r=d.getBoundingClientRect();out[q.key]=[r.width,r.height]}return out},{reqs:reqs.map(q=>({...q,fam:fam(q.file),t:plain(q.t)})),FACES});
 // passata 2: disegno con le misure vere
 const R=run(meas);
 const shots=[];
 for(const scene of R.scenes){
  let html='';
  for(const o of scene.items){
   const st=`left:${o.l}px;top:${o.t}px;width:${o.w}px;height:${o.h}px`;
   if(o.k==='rect')html+=`<div style="position:absolute;${st};background:rgba(${o.c.map(x=>Math.round(x*255)).join(',')},${o.a})"></div>`;
   else if(o.k==='icon')html+=o.path.startsWith('Interface\\Icons\\')?`<img src="https://wow.zamimg.com/images/wow/icons/large/${o.path.slice(16).toLowerCase()}.jpg" style="position:absolute;${st};object-fit:cover;object-position:center;transform:scale(1.16);clip-path:inset(7%)">`
    :/CheckBox-Check/.test(o.path)?`<div style="position:absolute;${st};color:#ffd100;font:700 ${Math.round(o.h*0.8)}px Arial;line-height:${o.h}px;text-align:center;text-shadow:0 0 2px #000">✔</div>`:'';
   else if(o.k==='text')html+=`<div style="position:absolute;left:${o.l}px;top:${o.t}px;${o.nw&&o.ww>0?'width:'+o.ww+'px;white-space:pre;overflow:hidden;text-overflow:ellipsis':o.ww>0?'width:'+o.ww+'px;white-space:pre-wrap;word-wrap:break-word':'white-space:pre'};font-family:${fam(o.file)};font-weight:400;font-size:${o.size}px;line-height:1.2;color:rgb(${o.c.map(x=>Math.round(x*255)).join(',')});text-shadow:none">${colored(o.text)}</div>`;
   else if(o.k==='clip')html+=`<div style="position:absolute;${st};overflow:hidden">`;
   else if(o.k==='endclip')html+='</div>';
  }
  shots.push([scene.name,`<div style="position:relative;width:${scene.W}px;height:${scene.H}px">${html}</div>`,scene.W,scene.H])}
 const pg=await b.newPage({viewport:{width:1420,height:Math.ceil(shots.length/2)*(shots[0][3]+20)+20}});
 await pg.setContent(`<html><head><style>${FACES}body{margin:0;background:#2a2f36}</style></head><body><div style="display:grid;grid-template-columns:repeat(2,${shots[0][2]}px);gap:20px;padding:20px">${shots.map(s=>s[1]).join('')}</div></body></html>`,{waitUntil:'networkidle'});
 await pg.evaluate(()=>document.fonts.ready);
 await pg.screenshot(ONLY?{path:`${O}/v4-${LANG}-${ONLY}.png`,clip:{x:20,y:20,width:shots[0][2],height:shots[0][3]}}:{path:`${O}/v4-${LANG}.png`,fullPage:true});
 console.log('ok',shots.map(s=>s[0]).join(' '),'misure',reqs.length);await b.close()})();
