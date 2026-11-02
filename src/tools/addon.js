// node src/tools/addon.js → esporta per l'addon in gioco (addon/ForeverPathfinder/Data.lua) la checklist e l'ordine dei talenti
// di ogni razza/classe, in italiano e inglese, leggendoli dalla pagina già generata (stesso motore del sito: opzioni di base,
// percorso senza cambio continente, dungeon sì, build A, niente profession); poi crea ForeverPathfinder.zip da scaricare dal sito
const {chromium}=require(process.env.LOCALAPPDATA+'/npm-cache/_npx/9833c18b2d85bc59/node_modules/playwright-core');
const fs=require('fs'),path=require('path'),{execFileSync}=require('child_process');
const ROOT=path.join(__dirname,'../..'),OUT=path.join(ROOT,'addon/ForeverPathfinder');
// i font di WoW mostrano solo l'alfabeto latino di base: via emoji e simboli, le frecce diventano "->"
const clean=s=>s.replace(/→/g,'->').replace(/[^\x20-\xFF–—‘’“”…•‹›€]/g,'').replace(/\s+/g,' ').trim();
const lua=s=>'"'+String(s).replace(/\\/g,'\\\\').replace(/"/g,'\\"')+'"';
(async()=>{const b=await chromium.launch({channel:'chrome'}),all={};
 for(const [f,l] of [['','it'],['_EN','en']]){const p=await b.newPage();await p.addInitScript(l=>localStorage.setItem('wfcLang',l),l);
  await p.goto('file:///'+path.join(ROOT,'WoW_Forever_Leveling_Companion'+f+'.html').replace(/\\/g,'/')+'#gnome-mage',{waitUntil:'load'});
  all[l]=await p.evaluate(()=>{const out={};
   for(const r of Object.keys(D.races))for(const c of D.races[r].classes){if(!D.classes[c])continue;
    S.r=r;S.c=c;S.o.x=0;S.o.prof=[];S.o.dg=1;S.o.tal=0;S.o.b[c]='a';renderAll();
    const ch=[],tasks=[];document.querySelectorAll('#chaps .chap').forEach((d,i)=>{ch.push(d.querySelector('summary b').textContent);
     // solo il testo della voce: via i pulsanti (mappa, calcolatore), liste separate da "; "
     d.querySelectorAll('label.task').forEach(t=>{const x=t.querySelector('.tx').cloneNode(true);x.querySelectorAll('button,a').forEach(e=>e.remove());x.querySelectorAll('br').forEach(e=>e.replaceWith(' '));x.querySelectorAll('li').forEach(e=>e.append('; '));
      tasks.push([parseInt(t.querySelector('.lv').textContent.replace(/\D/g,''))||1,i+1,x.textContent.replace(/;\s*$/,'')])})});
    const tal=CL.build.map((k,i)=>{const t=TAL.trees.filter(x=>x[0]===k.split('/')[0])[0];return [i+10,TAL.n[k][0],t?t[1]:'']});
    out[r+'-'+c]={name:RA.name+' '+CL.name,build:CL.B?CL.B.name:CL.spec,ch,tasks,tal}}
   return out});await p.close()}
 await b.close();
 let s='-- generato da src/tools/addon.js: non modificare a mano\nForeverPathfinderData = {\n';
 for(const l of ['it','en']){s+=' '+l+' = {\n';
  for(const [k,v] of Object.entries(all[l]))s+='  ['+lua(k)+'] = { name = '+lua(v.name)+', build = '+lua(clean(v.build))+',\n   ch = { '+v.ch.map(x=>lua(clean(x))).join(', ')+' },\n   tasks = {\n'+
   v.tasks.map(t=>'    { '+t[0]+', '+t[1]+', '+lua(clean(t[2]))+' },').join('\n')+'\n   },\n   tal = { '+v.tal.map(t=>'{ '+t[0]+', '+lua(t[1])+', '+lua(t[2])+' }').join(', ')+' },\n  },\n';
  s+=' },\n'}
 fs.writeFileSync(path.join(OUT,'Data.lua'),s+'}\n');
 const zip=path.join(ROOT,'ForeverPathfinder.zip');if(fs.existsSync(zip))fs.unlinkSync(zip);
 // tar di Windows (non quello di Git, che non fa zip): percorsi con / (lo zip di PowerShell usa \ e su Mac si estrae male)
 execFileSync(path.join(process.env.SystemRoot,'System32/tar.exe'),['-a','-c','-f',zip,'-C',path.dirname(OUT),path.basename(OUT)]);
 console.log('Data.lua',(fs.statSync(path.join(OUT,'Data.lua')).size/1024).toFixed(0),'KB ·',Object.keys(all.it).length,'combinazioni · zip',(fs.statSync(zip).size/1024).toFixed(0),'KB')})();
