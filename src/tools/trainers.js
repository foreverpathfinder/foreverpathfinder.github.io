// node src/tools/trainers.js <cartella QuestieDB con foreverNpcDB.lua>
// → src/data/profs.json professions[].trainerMax = { NPC: 2 Journeyman | 3 Expert | 4 Artisan } per le 6 profession di crafting,
//   dal titolo dell'NPC in QuestieDB Forever («Journeyman Tailor», «Expert Alchemist», «Artisan …» / «Master …»).
//   Vale per i trainer di worldmap.json (rifallo dopo map.js). Senza titolo: nessun grado (il sito e l'addon lo usano solo per Journeyman).
const fs=require('fs'),path=require('path');const Q=process.argv[2];if(!Q){console.log('serve la cartella di QuestieDB');process.exit(1)}
const R=path.join(__dirname,'../data');
const sub={};
for(const line of fs.readFileSync(path.join(Q,'foreverNpcDB.lua'),'utf8').split('\n')){const m=line.match(/^\[(\d+)\] = \{'((?:[^'\\]|\\.)*)',(.*)\},?\s*$/);if(!m)continue;
 const name=m[2].replace(/\\'/g,"'"),strs=[...m[3].matchAll(/"([^"]*)"/g)].map(x=>x[1]);(sub[name]=sub[name]||new Set()).add(strs.length>=2?strs[strs.length-1]:'')}
const P=path.join(R,'profs.json'),p=JSON.parse(fs.readFileSync(P,'utf8')),w=JSON.parse(fs.readFileSync(path.join(R,'worldmap.json'),'utf8')).continents;
const CRAFT={Alchemy:'Alchemist',Blacksmithing:'Blacksmith',Enchanting:'Enchanter',Engineering:'Engineer',Leatherworking:'Leather',Tailoring:'Tailor'};
const rank=t=>/^(Artisan|Master)\b/.test(t)?4:/^Expert\b/.test(t)?3:/^Journeyman\b/.test(t)?2:/^Apprentice\b/.test(t)?1:0;
for(const pr of p.professions){const word=CRAFT[pr.name];if(!word){delete pr.trainerMax;continue}
 const key=pr.name.toLowerCase().replace(/ /g,'-'),tm={};
 for(const c of Object.values(w))for(const t of (c.prof||{})[key]||[]){const r=Math.max(0,...[...(sub[t[0]]||[])].filter(x=>x.includes(word)).map(rank));if(r)tm[t[0]]=r}
 pr.trainerMax=tm;console.log(pr.name,Object.keys(tm).length,'trainer con grado')}
fs.writeFileSync(P,JSON.stringify(p,null,1)+'\n');
