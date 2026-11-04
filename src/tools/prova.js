// node src/tools/prova.js <cartella> → prepara la pagina di prova dell'addon (WoW finto nel browser con l'addon vero) in <cartella>:
// copia src/prova (index.html, wow.lua) e Data.lua/Core.lua dell'addon, scarica le icone che mancano in <cartella>/icone (Wowhead,
// stessi nomi del gioco) e le mette in icons.json come data URI; poi si pubblica la cartella come Artifact (i .lua come text/plain)
const fs=require('fs'),path=require('path'),{execFileSync}=require('child_process');
const ROOT=path.join(__dirname,'../..'),OUT=process.argv[2];
if(!OUT){console.log('uso: node src/tools/prova.js <cartella>');process.exit(1)}
const ICO=path.join(OUT,'icone');fs.mkdirSync(ICO,{recursive:true});
for(const f of ['index.html','wow.lua'])fs.copyFileSync(path.join(ROOT,'src/prova',f),path.join(OUT,f));
for(const f of ['Data.lua','Core.lua'])fs.copyFileSync(path.join(ROOT,'addon/ForeverPathfinder',f),path.join(OUT,f));
const data=fs.readFileSync(path.join(OUT,'Data.lua'),'utf8');
const names=new Set(['inv_misc_map_01','inv_misc_book_09',...['warrior','mage','priest','rogue','hunter','warlock','druid','paladin','shaman'].map(c=>'classicon_'+c)]);
for(const m of data.matchAll(/\^([a-z0-9_,-]+)\^/g))for(const n of m[1].split(','))names.add(n);
const I={};
for(const n of names){const f=path.join(ICO,n+'.jpg');
 if(!fs.existsSync(f))try{execFileSync('curl',['-sf','-o',f,`https://wow.zamimg.com/images/wow/icons/medium/${n}.jpg`])}catch(e){console.log('manca',n);continue}
 I[n]='data:image/jpeg;base64,'+fs.readFileSync(f).toString('base64')}
I.__logo='data:image/png;base64,'+fs.readFileSync(path.join(ROOT,'addon/pubblicazione/logo-400.png')).toString('base64');
fs.writeFileSync(path.join(OUT,'icons.json'),JSON.stringify(I));
console.log('pagina di prova in',OUT,'· icone',Object.keys(I).length);
