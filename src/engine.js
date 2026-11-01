// Motore della guida: legge DATA (unito da tools/build.js) e disegna tutto per razza + classe + livello.
var D=DATA,C=D.common,LF=window.L; // Leaflet: L resta il nome globale di Leaflet
var IC=function(n){return 'https://wow.zamimg.com/images/wow/icons/large/'+n+'.jpg'};
function img(n,c,alt){return '<img class="ic'+(c?' '+c:'')+'" src="'+IC(n)+'" alt="'+(alt||'')+'" loading="lazy" onerror="this.onerror=null;this.src=\'https://wowforever.be/icons/'+n+'.jpg\'">'}
function store(k,v){try{if(v===undefined)return localStorage.getItem(k);localStorage.setItem(k,v)}catch(e){return null}}
function $(id){return document.getElementById(id)}
function li(a){return a.map(function(x){return '<li>'+x+'</li>'}).join('')}
function card(icon,title,body,pill){return '<div class="card" style="margin:0;padding:10px"><div class="row">'+img(icon)+'<div><b>'+title+'</b>'+(pill?' '+pill:'')+'<br><span class="note">'+body+'</span></div></div></div>'}
function srcRow(s){return '<tr><td>'+(s[1]?'<a href="'+s[1]+'" target="_blank" rel="noopener">'+s[0]+'</a>':s[0])+'</td><td>'+(s[2]||'')+'</td><td>'+(s[3]||'')+'</td></tr>'}
var MAXL=C.maxLevel,FN={A:'Alleanza',H:'Orda'};

/* ---- stato: razza, classe, livello ---- */
var S=(function(){var s={};try{s=JSON.parse(store('wfc')||'{}')}catch(e){}var h=location.hash.match(/^#(\w+)-(\w+)$/);if(h){s.r=h[1];s.c=h[2]}
 if(!D.races[s.r])s.r='gnome';if(!ok(s.r,s.c))s.c=D.races[s.r].classes.filter(function(c){return D.classes[c]})[0]||'mage';s.L=Math.max(1,Math.min(MAXL,+s.L||1));return s})();
function ok(r,c){return D.races[r]&&D.races[r].classes.indexOf(c)>-1&&!!D.classes[c]}
var RA,CL,TAL,RT,FA;
function bind(){RA=D.races[S.r];CL=D.classes[S.c];TAL=D.talents[S.c];RT=D.routes[RA.start];FA=D.factions[RA.faction];store('wfc',JSON.stringify(S))}

/* ---- scelta del personaggio ---- */
function drawPick(){
 $('pkF').innerHTML=['A','H'].filter(function(f){return Object.keys(D.races).some(function(k){return D.races[k].faction===f})}).map(function(f){return '<button data-f="'+f+'" class="'+f+(RA.faction===f?' on':'')+'">'+FN[f]+'</button>'}).join('');
 $('pkR').innerHTML=Object.keys(D.races).filter(function(k){return D.races[k].faction===RA.faction}).map(function(k){var r=D.races[k];return '<button data-r="'+k+'"'+(k===S.r?' class="on"':'')+'><img src="'+IC(r.icon)+'" alt="">'+r.name+'</button>'}).join('');
 $('pkC').innerHTML=RA.classes.map(function(k){var c=D.classes[k];return '<button data-c="'+k+'"'+(k===S.c?' class="on"':'')+(c?'':' disabled title="Dati in arrivo"')+'><img src="'+IC('classicon_'+k)+'" alt="">'+(c?c.name:k[0].toUpperCase()+k.slice(1)+' (in arrivo)')+'</button>'}).join('');
}
$('pg').addEventListener('click',function(e){var b=e.target.closest('button');if(!b||b.disabled)return;
 if(b.dataset.f&&b.dataset.f!==RA.faction){var r=Object.keys(D.races).filter(function(k){return D.races[k].faction===b.dataset.f});S.r=r.filter(function(k){return ok(k,S.c)})[0]||r[0]}
 if(b.dataset.r)S.r=b.dataset.r;if(b.dataset.c)S.c=b.dataset.c;
 if(!ok(S.r,S.c))S.c=RA&&D.races[S.r].classes.filter(function(c){return D.classes[c]})[0];
 history.replaceState(null,'','#'+S.r+'-'+S.c);renderAll()});

/* ---- talent ---- */
function rankAt(l){var s={};for(var i=0;i<Math.max(0,l-9)&&i<CL.build.length;i++)s[CL.build[i]]=(s[CL.build[i]]||0)+1;return s}
function tEnc(l){var s=rankAt(l);return TAL.trees.map(function(t){return t[2].map(function(n){return s[t[0]+'/'+n]||0}).join('').replace(/0+$/,'')}).join('-').replace(/-+$/,'')}
function tAt(l){return l>=10&&l-10<CL.build.length?CL.build[l-10]:null}

/* ---- planner ---- */
function segAt(l){var a=RT.segments;for(var i=0;i<a.length;i++)if(l>=a[i][0]&&l<=a[i][1])return a[i];return a[a.length-1]}
function todoAt(l){var t=[].concat((RT.milestones[l]||[]),(CL.milestones[l]||[]),(FA.milestones&&FA.milestones[l])||[]);
 if(l===10)t.push('Primo talent point','Le <b>Waylaid Crates</b> diventano utilizzabili');if(l===20)t.push('Crates Expert utilizzabili');return t}
function renderLevel(){
 S.L=Math.max(1,Math.min(MAXL,S.L));store('wfc',JSON.stringify(S));
 var L=S.L;$('lvn').textContent=L;$('lvr').value=L;
 var z=segAt(L),s=rankAt(L),nx=tAt(L);
 var h='<div class="box"><b class="t">Zona</b><div style="font:800 1.15rem Cinzel,serif;color:var(--ice)">'+z[2]+'</div><div class="note">'+z[3]+'</div><p style="margin:.4em 0 0">'+z[4]+'</p><a href="#mappa" class="note">Vedi sulla mappa ›</a></div>';
 h+='<div class="box"><b class="t">Talent a questo livello</b>';
 if(nx){var t=TAL.n[nx];h+='<div class="it">'+img(t[1])+'<div><b>'+t[0]+'</b> '+s[nx]+'/'+t[2]+'<small>'+(CL.why[t[0]]||t[3])+'</small></div></div>'}
 else h+='<p class="note">I talent iniziano al livello 10 (al 5 con il perk Talented).</p>';
 h+='</div>';
 var ns=CL.spells.filter(function(x){return x[0]===L});
 h+='<div class="box"><b class="t">Spell nuove dal Trainer</b>'+(ns.length?ns.map(function(x){return '<div class="it">'+img(x[2],'s')+'<div><b>'+x[1]+'</b><small>'+x[3]+'</small></div></div>'}).join(''):'<p class="note">Nessuna spell nuova: '+(L%2?'aggiorna i Rank al prossimo livello pari.':'aggiorna i Rank dal Trainer.')+'</p>')+'</div>';
 var td=[];for(var k=Math.max(1,L-1);k<=L;k++)td=td.concat(todoAt(k));
 var dg=FA.dungeons.filter(function(d){return L>=d[1]&&L<=d[2]});
 h+='<div class="box"><b class="t">Da non perdere</b>'+(td.length?'<ul>'+li(td)+'</ul>':'<p class="note">Quest nella zona e raccolta lungo la strada.</p>')+(dg.length?'<p class="note">⚔ Dungeon nel range: '+dg.map(function(d){return d[0]}).join(', ')+'</p>':'')+'</div>';
 $('plan').innerHTML=h;
 var tl='';for(var l=1;l<=MAXL;l++){var it=[],b=tAt(l);if(b)it.push(img(TAL.n[b][1],'s')+' '+TAL.n[b][0]);
  CL.spells.filter(function(x){return x[0]===l}).forEach(function(x){it.push(x[1])});it=it.concat(todoAt(l));if(!it.length)continue;
  tl+='<div class="ev'+(l<L?' done':l===L?' cur':'')+'"><span class="lv">Liv. '+l+'</span><span>'+it.join(' · ')+'</span></div>'}
 $('tl').innerHTML=tl;
 drawOrder();wfSet();if(mapSync)mapSync();
}
$('lvm').onclick=function(){S.L--;renderLevel()};
$('lvp').onclick=function(){S.L++;renderLevel()};
$('lvr').oninput=function(){S.L=+this.value;renderLevel()};

/* ---- talent: ordine + calcolatore di wowforever.be ---- */
function drawOrder(){
 var g=[],cnt={},o='';
 CL.build.forEach(function(b,i){if(10+i>MAXL)return;if(g.length&&g[g.length-1].k===b)g[g.length-1].n++;else g.push({k:b,n:1,from:10+i})});
 g.forEach(function(x){cnt[x.k]=(cnt[x.k]||0)+x.n;var a=x.from,e=x.from+x.n-1,t=TAL.n[x.k];
  o+='<div class="o'+(S.L>e?' past':'')+(S.L>=a&&S.L<=e?' cur':'')+'" data-lv="'+a+'">'+img(t[1],'s')+'<div><b>'+t[0]+'</b>'+cnt[x.k]+'/'+t[2]+' · liv. '+(a===e?a:a+'–'+e)+'</div></div>'});
 $('order').innerHTML=o;
}
$('order').addEventListener('click',function(e){var b=e.target.closest('.o');if(b){S.L=+b.dataset.lv;renderLevel()}});
// Calcolatore wowforever.be a 380 px: alberi a y=763/1297/1832 (alti 512), pagina 2552 (misurato il 1/11/2026, uguale per tutte le classi).
// ponytail: offset fissi; se il sito cambia impaginazione, c'è il pulsante "Tutti e 3 i talent tree".
// La pagina legge ?t= solo all'apertura: due iframe (il vecchio resta visibile finché il nuovo è pronto), un caricamento alla volta, solo se visibile.
var WF={mode:'tree',want:'',shown:null,loading:null,t:null,to:null,vis:false},WFY=[763,1297,1832];
var wfBox=$('wfBox'),wfF=[].slice.call(wfBox.querySelectorAll('iframe')),wfA=0,wfBadge=wfBox.querySelector('.wait');
function wfUrl(enc){return 'https://wowforever.be/it/talents/'+S.c+'/'+(enc?'?t='+enc:'')}
function wfFit(){var s=Math.min(1,(wfBox.parentNode.clientWidth||380)/380),m=WF.mode==='tree'?[WFY[CL.treeIndex],520]:[0,2552];
 wfBox.style.width=Math.round(380*s)+'px';wfBox.style.height=Math.round(m[1]*s)+'px';
 wfF.forEach(function(f){f.style.transform='scale('+s+') translateY('+(-m[0])+'px)'})}
function wfLoad(){if(!WF.vis||WF.loading!==null||WF.want===WF.shown)return;
 var u=WF.want,f=wfF[1-wfA];WF.loading=u;wfBadge.textContent='Carico il talent tree…';wfBadge.hidden=false;
 clearTimeout(WF.to);WF.to=setTimeout(function(){if(WF.loading===u){WF.loading=null;wfBadge.textContent='wowforever.be non risponde: tocca “Apri ↗”'}},15000);
 f.onload=function(){if(WF.loading!==u)return;f.style.visibility='visible';wfF[wfA].style.visibility='hidden';wfA=1-wfA;WF.shown=u;WF.loading=null;wfBadge.hidden=true;wfLoad()};
 f.src=u}
function wfSet(){var lv=Math.max(10,S.L);$('wfLv').textContent=lv;var u=wfUrl(tEnc(lv));$('wfLink').href=u;
 WF.want=u;clearTimeout(WF.t);WF.t=setTimeout(wfLoad,WF.shown?700:0)}
if('IntersectionObserver' in window)new IntersectionObserver(function(es){WF.vis=es[0].isIntersecting;wfLoad()},{rootMargin:'400px'}).observe(wfBox);else WF.vis=true;
$('wfm').onclick=function(){S.L=Math.max(10,Math.max(10,S.L)-1);renderLevel()};
$('wfp').onclick=function(){S.L=Math.max(10,S.L)+1;renderLevel()};
$('wfModes').addEventListener('click',function(e){var b=e.target.closest('button');if(!b)return;WF.mode=b.dataset.m;
 [].forEach.call(this.children,function(c){c.classList.toggle('on',c===b)});wfFit()});
addEventListener('resize',wfFit);

/* ---- sezioni che dipendono da razza e classe ---- */
function renderClass(){
 var tree=TAL.trees[CL.treeIndex][1];
 $('bTitle').textContent='Talents: '+CL.spec+' 1–'+MAXL;$('bSum').innerHTML='<b>Scelta:</b> '+CL.summary;
 $('wfLab').textContent=tree+' talent tree al livello';$('wfTreeBtn').textContent=tree+' talent tree';
 $('bCmp').innerHTML='<tr><th>Fonte</th><th>Segnale di qualità</th><th>10–19</th><th>20</th><th>21–30</th></tr>'+CL.compare.map(function(r){return '<tr><td>'+r.source+'</td><td>'+r.signal+'</td><td>'+r.l10_19+'</td><td>'+r.l20+'</td><td>'+r.l21_30+'</td></tr>'}).join('');
 $('bAlt').innerHTML=CL.alternatives.map(function(a){return '<details><summary>'+a.title+'</summary>'+a.html+'</details>'}).join('');
 $('rotc').innerHTML=CL.rotation.map(function(r){return '<div class="rc"><h4>'+r.title+'</h4><div class="seq">'+r.seq.map(function(x,i){return (i?'<i>→</i>':'')+'<span class="it" style="margin:0">'+img(x[0],'s')+'<small style="color:var(--tx)">'+x[1]+'</small></span>'}).join('')+'</div><p class="note" style="margin:0">'+r.text+'</p></div>'}).join('');
 $('rotn').innerHTML=CL.rotNotes.map(function(a){return '<details><summary>'+a.title+'</summary>'+a.html+'</details>'}).join('')+(CL.stats?'<details><summary>Stats e weapon</summary><p>'+CL.stats+'</p></details>':'')+(CL.forever&&CL.forever.length?'<details><summary>Novità di Forever ★ per la classe</summary><ul>'+li(CL.forever)+'</ul></details>':'');
 $('spells').innerHTML=CL.spells.filter(function(x){return x[0]<=MAXL}).map(function(x){return card(x[2],x[1],x[3],'<span class="pill p-ok">Liv. '+x[0]+'</span>')}).join('')+
  CL.talentSpells.filter(function(x){return x[0]<=MAXL}).map(function(x){return card(x[2],x[1],x[3],'<span class="pill p-new">Liv. '+x[0]+'</span>')}).join('');
 // razza
 var cr=CL.races[S.r]||CL.races[S.r.replace(/_[ah]$/,'')];
 $('rTitle').textContent='Razza: '+RA.name;
 $('rBody').innerHTML=(cr?'<div class="callout g"><b>'+RA.name+' '+CL.name+':</b> '+cr+'</div>':'')+'<div class="grid">'+RA.racials.map(function(r){return card(r[1],r[0],r[2])}).join('')+'</div>'+(RA.tips?'<p class="note">'+RA.tips+'</p>':'')+
  '<details><summary>Le altre razze per '+CL.name+'</summary><ul>'+Object.keys(CL.races).filter(function(k){return D.races[k]&&k!==S.r}).map(function(k){return '<li><b>'+D.races[k].name+'</b> ('+FN[D.races[k].faction]+'): '+CL.races[k]+'</li>'}).join('')+'</ul></details>';
 // viaggi
 $('vFp').innerHTML='<tr><th>#</th><th>Flight path</th><th>Flight Master</th><th>Quando</th></tr>'+RT.flights.map(function(f,i){return '<tr><td>'+(i+1)+'</td><td><b>'+f.name+'</b></td><td>'+(f.master||'—')+(f.way?' <code>/way '+f.way+'</code>':'')+'</td><td>'+(f.when||'')+'</td></tr>'}).join('');
 $('vCards').innerHTML='<div class="card"><h3>Tram, Boat, Zeppelin</h3><ul>'+li(RT.transport.concat(FA.transport||[]))+'</ul></div>'+(CL.travel?'<div class="card"><h3>Perk del '+CL.name+'</h3>'+CL.travel+'</div>':'');
 // bag
 $('bagt').innerHTML='<tr><th>Liv.</th><th>Bag</th><th>Slot</th><th>Come</th></tr>'+RT.bags.map(function(b){return '<tr><td>'+b.lvl+'</td><td><b>'+b.name+'</b></td><td>'+b.slots+'</td><td>'+b.how+'</td></tr>'}).join('')+C.bagsCommon.map(function(b){return '<tr><td>'+b.join('</td><td>')+'</td></tr>'}).join('');
 // professioni
 var P=CL.professions;$('profc').innerHTML='<div class="card"><h3>Main: gold subito</h3><p>'+(P.gold||C.profGold)+'</p></div><div class="card"><h3>Main: più forza in leveling</h3><p>'+P.power+'</p></div><div class="card"><h3>Il consiglio</h3><p>'+P.advice+'</p></div>';
 // crates
 $('crc').innerHTML='<p>'+C.crates+'</p><ul>'+li(C.cratesList.concat(FA.crates?['Consegna: <b>'+FA.crates+'</b>']:[]))+'</ul>';
 // camping
 $('campT').textContent='Priorità per il '+CL.name;
 $('camp').innerHTML=CL.camp.map(function(c,i){return card(c[2],c[0],c[3],'<span class="note">· '+c[1]+'</span>'+(i<3?' <span class="pill p-ok">priorità '+(i+1)+'</span>':''))}).join('');
 // dungeon
 $('dtab').innerHTML='<tr><th>Dungeon</th><th>Livelli</th><th>Dove</th><th>Note</th></tr>'+FA.dungeons.filter(function(d){return d[1]<=MAXL+2}).map(function(d){return '<tr><td><b>'+d[0]+'</b></td><td>'+d[1]+'–'+d[2]+'</td><td>'+d[3]+'</td><td>'+(d[4]||'')+'</td></tr>'}).join('');
 // fonti
 $('srct').innerHTML='<tr><th>Fonte</th><th>Data / segnale</th><th>Cosa ho preso</th></tr>'+CL.sources.concat(FA.sources,C.sources).map(srcRow).join('');
 // testata
 var tl=RA.name+' '+CL.name;document.title=tl+' '+CL.spec+' – WoW Forever';document.documentElement.style.setProperty('--cc',CL.color||'var(--ice)');
 $('htitle').innerHTML=img('classicon_'+S.c,'')+' '+RA.name+' '+CL.name+' <span>'+CL.spec+'</span>';
 $('hsub').innerHTML='Guida leveling 1–'+MAXL+' per WoW: Forever · '+FN[RA.faction]+' · <b>'+C.version+'</b> · '+C.updated;
 $('hchips').innerHTML='<span class="chip">'+img(CL.specIcon,'')+'Build: '+CL.spec+'</span><span class="chip">'+img(RT.icon,'')+'Inizio: '+RT.name+'</span>'+CL.chips.map(function(c){return '<span class="chip">'+img(c[0],'')+c[1]+'</span>'}).join('')+'<span class="chip">✔ dati dal client 1.60.1.70707</span>';
 $('herobg').innerHTML=RT.hero.map(function(u){return '<img src="'+u+'" alt="">'}).join('');
 $('foot').textContent='Guida personale · WoW: Forever Leveling Companion · '+C.version+' ('+C.updated+'). Non affiliata a Blizzard. Icone © Blizzard via Wowhead.';
 $('lvr').max=MAXL;$('tlsum').textContent='Tutto il percorso 1–'+MAXL+' in una riga temporale';
 WF.shown=null;wfFit();
}

/* ---- sezioni fisse ---- */
(function(){
 $('hlaunch').textContent=C.launchText;
 $('xpc').innerHTML=C.xpCards.map(function(x){return card(x[0],x[1],x[2])}).join('');$('xpr').innerHTML=li(C.rules);
 $('bagn').innerHTML=C.bagsNote;$('proft').innerHTML=C.profTier;$('profe').innerHTML=li(C.profErrors);$('camps').innerHTML=li(C.campSteps);
 var V=C.video;$('vtitle').textContent='Video: '+V.title;$('vsum').innerHTML=li(V.summary);$('yt').src='https://www.youtube-nocookie.com/embed/'+V.id;
 $('vchap').innerHTML=V.chapters.map(function(c){return '<button data-t="'+c[1]+'">'+c[0]+' '+Math.floor(c[1]/60)+':'+('0'+c[1]%60).slice(-2)+'</button>'}).join('');
 $('vchap').addEventListener('click',function(e){var b=e.target.closest('button');if(b)$('yt').src='https://www.youtube-nocookie.com/embed/'+V.id+'?autoplay=1&start='+b.dataset.t});
 $('limits').innerHTML='<b>Limiti onesti:</b> '+C.limits;
 var end=Date.parse(C.launchUTC),el=$('cd');function t(){var d=end-Date.now();if(d<=0){el.textContent='Forever è uscito!';return}var h=Math.floor(d/36e5);el.textContent='mancano '+Math.floor(h/24)+' g '+(h%24)+' h'}t();setInterval(t,6e4);
})();

/* ---- mappa del gioco: tessere e dati della World Map Forever di Wowhead (pixel locali del continente, zoom 7) ---- */
var mapSync=null,MAP=null;
function drawMap(){
 var box=$('lmap'),steps=RT.steps,side=RA.faction==='A'?1:2,mine=function(s){return !s||s===side};
 $('msteps').innerHTML=steps.map(function(s,i){return '<button class="mstep" data-i="'+i+'"><img src="'+IC(s[5])+'" alt=""><span>'+(i+1)+'. '+s[0]+'<small>liv. '+s[1]+'</small></span></button>'}).join('');
 if(!LF){box.innerHTML='<p class="note" style="padding:16px">La mappa ha bisogno di internet (Leaflet e le immagini della mappa).</p>';return}
 // Una sola mappa per tutta la pagina: al cambio di personaggio si svuota (ricrearla rompe il renderer canvas di Leaflet).
 if(MAP){MAP.stop();MAP.off('zoomend');MAP.eachLayer(function(l){if(!(l instanceof LF.Renderer))MAP.removeLayer(l)})}
 else MAP=LF.map(box,{crs:LF.CRS.Simple,minZoom:2,maxZoom:7,zoomSnap:.25,zoomDelta:.5,preferCanvas:true});
 var ll=function(x,y){return [-y/128,x/128]},P=function(a){return a.map(function(p){return ll(p[0],p[1])})};
 var map=MAP;
 var tiles=null,cont=null,G={},gold='#f2c14e';
 var pin=function(n,sz,cls){return LF.divIcon({className:'gpin '+(cls||''),html:'<img src="'+IC(n)+'" alt="">',iconSize:[sz,sz],iconAnchor:[sz/2,sz/2],popupAnchor:[0,-sz/2]})};
 var qm=function(){return LF.divIcon({className:'',html:'<span class="qm">!</span>',iconSize:[20,26],iconAnchor:[10,13]})};
 var LAY=[['route','Rotta',RT.icon,1],['fp','Flight Master','ability_mount_gryphon_01',1],['q','Quest della guida','',1],['dg','Dungeons','achievement_dungeon_classicdungeonmaster',1],
  ['boat','Boat, Zeppelin, Tram','inv_misc_anchor',1],['tr',CL.name+' Trainer','classicon_'+S.c,0],['inn','Innkeeper','inv_misc_rune_01',0],['fly','Flight Path','',0],
  ['ore','Ore','inv_ore_copper_01',0],['herb','Herbalism','inv_misc_flower_02',0]];
 if(S.c==='hunter')LAY.push(['pet','Pet da tame','ability_hunter_beasttaming',0]);
 LAY.forEach(function(l){G[l[0]]=LF.layerGroup()});
 var lab=LF.layerGroup().addTo(map);
 var NODE={cu:['ore','Copper Vein','#e08a3c'],sn:['ore','Tin Vein','#c3ccd2'],ag:['ore','Silver Vein','#e6eef5'],fe:['ore','Iron Deposit','#9aa3ad'],pb:['herb','Peacebloom','#fff6d8'],sl:['herb','Silverleaf','#a6e3a1'],er:['herb','Earthroot','#c8925a'],mr:['herb','Mageroyal','#c9a3ff'],bt:['herb','Briarthorn','#ff7d7d'],bw:['herb','Bruiseweed','#6fcf6f'],sk:['herb','Stranglekelp','#3fa58a'],ws:['herb','Wild Steelbloom','#b7c4cf'],kb:['herb','Kingsblood','#d0473f']};
 function fill(c){var M=D.map[c];cont=c;lab.clearLayers();LAY.forEach(function(l){G[l[0]].clearLayers()});
  if(tiles)map.removeLayer(tiles);
  tiles=LF.tileLayer('https://wow.zamimg.com/images/wow/classicplus/world-map/v3/'+c+'/{z}/{y}/{x}.webp',{tileSize:256,minZoom:2,maxZoom:7,maxNativeZoom:7,noWrap:true,bounds:[ll(0,0),ll(M.w,M.h)],
   errorTileUrl:'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==',attribution:'Mappa © Blizzard Entertainment · tessere e dati <a href="https://www.wowhead.com/forever/world-map" target="_blank" rel="noopener">Wowhead</a>'}).addTo(map);
  map.setMaxBounds([ll(-2000,-2000),ll(M.w+2000,M.h+2000)]);
  var rz=RT.zones;
  M.zones.forEach(function(z){LF.marker(ll(z[2],z[3]),{interactive:false,keyboard:false,icon:LF.divIcon({className:'zlab'+(rz.indexOf(z[0])>-1?' r':''),html:'<span><b>'+z[0]+'</b><small>'+z[1]+'</small></span>',iconSize:[0,0]})}).addTo(lab)});
  M.places.forEach(function(t){LF.marker(ll(t[1],t[2]),{interactive:false,keyboard:false,icon:LF.divIcon({className:'tlab',html:'<span>'+t[0]+'</span>',iconSize:[0,0]})}).addTo(lab)});
  // rotta: linea tra le tappe dello stesso continente
  var pts=steps.filter(function(s){return s[8]===c}).map(function(s){return [s[2],s[3]]});
  if(pts.length>1){LF.polyline(P(pts),{color:'#000',weight:7,opacity:.4}).addTo(G.route);LF.polyline(P(pts),{color:gold,weight:3.5,dashArray:'2 9',lineCap:'round',opacity:.95}).addTo(G.route)}
  steps.forEach(function(s,i){if(s[8]!==c)return;var m=LF.marker(ll(s[2],s[3]),{zIndexOffset:1000,icon:LF.divIcon({className:'spin'+(i===cur?' on':''),html:'<img src="'+IC(s[5])+'" alt=""><b>'+(i+1)+'</b>',iconSize:[38,38],iconAnchor:[19,19]})}).addTo(G.route);m.on('click',function(){go(i,true)})});
  M.fp.filter(function(f){return mine(f[1])}).forEach(function(f){var on=RT.fpNames.indexOf(f[4])>-1;LF.marker(ll(f[2],f[3]),{icon:pin('ability_mount_gryphon_01',on?28:22,on?'':'dim'),zIndexOffset:on?500:0}).bindPopup('<b>✈ '+f[4]+'</b><br>Flight Master: '+f[0]+(on?'<br><span style="color:#7dff9a">Sulla tua rotta</span>':'')).addTo(G.fp)});
  M.dg.forEach(function(d){var lv=parseInt(d[1])||99,near=lv<=MAXL+2;LF.marker(ll(d[2],d[3]),{icon:pin('achievement_dungeon_classicdungeonmaster',near?28:20,near?'':'dim')}).bindPopup('<b>⚔ '+d[0]+'</b>'+(d[4]?' ★ nuovo':'')+(d[5]?' (raid)':'')+'<br>Livelli '+(d[1]||'—')).addTo(G.dg)});
  RT.quests.filter(function(q){return q[4]===c}).forEach(function(q){LF.marker(ll(q[2],q[3]),{zIndexOffset:1200,icon:qm()}).bindPopup('<b>'+q[0]+'</b><br>'+q[1]).addTo(G.q)});
  M.ships.forEach(function(s){LF.polyline(P(s[1]),{color:s[0]==='zeppelin'?'#ffb070':'#7fd3ff',weight:2.5,dashArray:'6 6',opacity:.8}).addTo(G.boat)});
  M.boat.filter(function(b){return mine(b[2])}).forEach(function(b){LF.marker(ll(b[3],b[4]),{icon:pin(b[1]==='tram'?'inv_gizmo_02':b[1]==='zeppelin'?'inv_misc_enggizmos_06':'inv_misc_anchor',24)}).bindPopup('<b>'+({tram:'Deeprun Tram',zeppelin:'Zeppelin',ship:'Boat'}[b[1]]||b[1])+'</b><br>'+b[0]).addTo(G.boat)});
  M.flights.filter(function(f){return mine(f[0])}).forEach(function(f){LF.polyline(P(f[1]),{color:'#cfe8ff',weight:1.5,opacity:.55}).addTo(G.fly)});
  (M.trainers[S.c]||[]).filter(function(t){return mine(t[1])}).forEach(function(t){LF.marker(ll(t[2],t[3]),{icon:pin('classicon_'+S.c,24)}).bindPopup('<b>'+CL.name+' Trainer</b><br>'+t[0]).addTo(G.tr)});
  M.inn.filter(function(t){return mine(t[1])}).forEach(function(t){LF.marker(ll(t[2],t[3]),{icon:pin('inv_misc_rune_01',20)}).bindPopup('<b>Innkeeper</b><br>'+t[0]).addTo(G.inn)});
  if(G.pet)M.pets.forEach(function(p){LF.circleMarker(ll(p[3],p[4]),{radius:4,color:'#000',weight:1,fillColor:'#ffd75a',fillOpacity:.95}).bindTooltip(p[0]+' ('+p[1]+(p[2]?', liv. '+p[2]:'')+')').addTo(G.pet)});
  Object.keys(NODE).forEach(function(k){var a=M.nodes[k]||[],n=NODE[k];for(var i=0;i<a.length;i+=2)LF.circleMarker(ll(a[i],a[i+1]),{radius:3.5,color:'#000',weight:1,fillColor:n[2],fillOpacity:.95}).bindTooltip(n[1]).addTo(G[n[0]])});
 }
 var chips=$('lchips');
 chips.innerHTML=LAY.map(function(l){var dot=l[0]==='fly'?'<i style="background:#cfe8ff"></i>':l[0]==='q'?'<span class="qm" style="width:14px;font-size:16px;line-height:18px">!</span>':'<img src="'+IC(l[2])+'" alt="">';
  if(l[0]==='ore')dot+='<i style="background:#e08a3c"></i><i style="background:#c3ccd2"></i>';if(l[0]==='herb')dot+='<i style="background:#fff6d8"></i><i style="background:#a6e3a1"></i><i style="background:#c9a3ff"></i>';
  return '<button data-k="'+l[0]+'" class="'+(l[3]?'on':'')+'">'+dot+l[1]+'</button>'}).join('');
 LAY.forEach(function(l){if(l[3])G[l[0]].addTo(map)});
 chips.onclick=function(e){var b=e.target.closest('button');if(!b)return;var g=G[b.dataset.k];if(map.hasLayer(g)){map.removeLayer(g);b.classList.remove('on')}else{g.addTo(map);b.classList.add('on')}};
 function zcls(){var z=map.getZoom();box.classList.toggle('zlow',z<4.25);box.classList.toggle('zfar',z<3)}
 map.on('zoomend',zcls);
 var cur=-1;
 function go(i,fly){var s=steps[i],prev=cur;cur=i;if(s[8]!==cont)fill(s[8]);
  [].forEach.call(document.querySelectorAll('.mstep'),function(b){b.classList.toggle('on',+b.dataset.i===i);if(+b.dataset.i===i&&fly)b.scrollIntoView({inline:'center',block:'nearest',behavior:'smooth'})});
  G.route.eachLayer(function(m){var el=m.getElement&&m.getElement();if(el&&el.classList.contains('spin'))el.classList.toggle('on',m.getLatLng().equals(LF.latLng(ll(s[2],s[3]))))});
  if(fly&&prev>=0&&steps[prev][8]===s[8])map.flyTo(ll(s[2],s[3]),s[4],{duration:.8});else map.setView(ll(s[2],s[3]),s[4]);
  var hi=parseInt(s[1].split('–')[1]||s[1]),lo=parseInt(s[1]);
  var dg=FA.dungeons.filter(function(d){return d[1]<=hi+2&&d[2]>=lo}).map(function(d){return d[0]+' ('+d[1]+'–'+d[2]+')'});
  $('mpanel').innerHTML='<div class="mpanel2"><img class="z" src="'+IC(s[5])+'" alt=""><div><b class="t">Tappa '+(i+1)+' di '+steps.length+' · livelli '+s[1]+'</b><div style="font:800 1.2rem Cinzel,serif;color:var(--ice)">'+s[0]+'</div><p style="margin:.35em 0">'+s[6]+'</p>'+
   (s[7]?'<p class="note">✈ Flight path da prendere: <b>'+s[7]+'</b></p>':'')+(dg.length?'<p class="note">⚔ Dungeon nel range: '+dg.join(', ')+'</p>':'')+
   '<div class="btns" style="margin-bottom:0">'+(i?'<button class="btn" data-go="'+(i-1)+'">‹ Tappa '+i+'</button>':'')+(i<steps.length-1?'<button class="btn pr" data-go="'+(i+1)+'">Tappa '+(i+2)+' ›</button>':'')+'</div></div></div>'}
 $('msteps').onclick=function(e){var b=e.target.closest('.mstep');if(b)go(+b.dataset.i,true)};
 $('mpanel').onclick=function(e){var b=e.target.closest('[data-go]');if(b)go(+b.dataset.go,true)};
 var stepFor=function(){var i=0;steps.forEach(function(s,j){if(S.L>=parseInt(s[1]))i=j});return i};
 mapSync=function(){var i=stepFor();if(i!==cur)go(i,false)};
 go(stepFor(),false);zcls();
 var wrap=$('lwrap'),fs=$('lfs');
 fs.onclick=function(){var f=wrap.classList.toggle('full');fs.textContent=f?'✕ Chiudi':'⛶ Schermo intero';document.body.style.overflow=f?'hidden':'';setTimeout(function(){map.invalidateSize()},50)};
}

/* ---- nav attiva ---- */
(function(){var links=[].slice.call(document.querySelectorAll('nav a'));var io=new IntersectionObserver(function(es){es.forEach(function(e){if(e.isIntersecting){links.forEach(function(a){var on=a.getAttribute('href')==='#'+e.target.id;a.classList.toggle('on',on);if(on){var n=a.parentNode;n.scrollLeft=a.offsetLeft-n.clientWidth/2+a.offsetWidth/2}})}})},{rootMargin:'-45% 0px -50% 0px'});document.querySelectorAll('section').forEach(function(s){io.observe(s)})})();

function renderAll(){bind();drawPick();renderClass();mapSync=null;drawMap();renderLevel()}
renderAll();
