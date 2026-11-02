// Motore della guida: legge DATA (unito da tools/build.js) e disegna tutto per razza + classe + opzioni + livello.
var D=DATA,C=D.common,LF=window.L; // Leaflet: L resta il nome globale di Leaflet
var IC=function(n){return 'https://wow.zamimg.com/images/wow/icons/large/'+n+'.jpg'};
function img(n,c,alt){return '<img class="ic'+(c?' '+c:'')+'" src="'+IC(n)+'" alt="'+(alt||'')+'" loading="lazy" onerror="icoFail(this,\''+n+'\')">'}
// icona mancante: prima wowforever.be, poi il punto di domanda di WoW (mai un riquadro vuoto)
function icoFail(i,n){if(!i.dataset.f){i.dataset.f=1;i.src='https://wowforever.be/icons/'+n+'.jpg'}else{i.onerror=null;i.src=IC('inv_misc_questionmark')}}
function store(k,v){try{if(v===undefined)return localStorage.getItem(k);localStorage.setItem(k,v)}catch(e){return null}}
function $(id){return document.getElementById(id)}
function li(a){return a.map(function(x){return '<li>'+x+'</li>'}).join('')}
function card(icon,title,body,pill){return '<div class="card" style="margin:0;padding:10px"><div class="row">'+img(icon)+'<div><b>'+title+'</b>'+(pill?' '+pill:'')+'<br><span class="note">'+body+'</span></div></div></div>'}
function srcRow(s){return '<tr><td>'+(s[1]?'<a href="'+s[1]+'" target="_blank" rel="noopener">'+s[0]+'</a>':s[0])+'</td><td>'+(s[2]||'')+'</td><td>'+(s[3]||'')+'</td></tr>'}
function txt(h){return String(h||'').replace(/<[^>]+>/g,'')}
function hash(s){var h=0;for(var i=0;i<s.length;i++)h=(h*31+s.charCodeAt(i))|0;return (h>>>0).toString(36)}
var MAXL=C.maxLevel,FN={A:'Alleanza',H:'Orda'},CN={kalimdor:'Kalimdor','eastern-kingdoms':'Eastern Kingdoms','zephras-isle':'Zephras Isle'};
var PROFS=D.profs?D.profs.professions.filter(function(p){return p.type!=='secondary'}).map(function(p){return [p.name,p.icon]}):[['Alchemy','trade_alchemy'],['Blacksmithing','trade_blacksmithing'],['Enchanting','trade_engraving'],['Engineering','trade_engineering'],['Herbalism','trade_herbalism'],['Leatherworking','trade_leatherworking'],['Mining','trade_mining'],['Skinning','inv_misc_pelt_wolf_01'],['Tailoring','trade_tailoring']];
var pkey=function(n){return n.toLowerCase().replace(/ /g,'-')};
function lv0(s){return parseInt(s)||1}
function lv1(s){var p=String(s).split(/[–-]/);return parseInt(p[1]||p[0])||MAXL}

/* ---- stato: personaggi salvati (preset), ognuno con razza, classe, opzioni, livello, checklist ---- */
// wfcP = {cur, sure, list:[{n: nome scelto, s: {r,c,L,o,tab,done}}]}; il vecchio wfc (un solo personaggio) diventa il primo preset
var SHARED=null,HOME=!/^#\w/.test(location.hash);
var P=(function(){var p=null;try{p=JSON.parse(store('wfcP'))}catch(e){}
 if(!p||!p.list||!p.list.length){var s={};try{s=JSON.parse(store('wfc')||'{}')}catch(e){}p={cur:0,sure:!!s.sure,in:!!s.r,list:[{n:'',s:s}]}}
 p.cur=Math.min(p.cur|0,p.list.length-1);var cur=p.list[p.cur].s,h=location.hash.match(/^#(\w+)-(\w+)$/);if(h){cur.r=h[1];cur.c=h[2]}
 // link da un altro dispositivo: #s=<base64 di {r,c,L,o,d,n}> → aggiorna il personaggio con la stessa razza e classe, altrimenti ne crea uno
 var m=location.hash.match(/^#s=([\w\-]+)/);if(m){try{var j=JSON.parse(decodeURIComponent(escape(atob(m[1].replace(/-/g,'+').replace(/_/g,'/'))))),i=-1;
  p.list.forEach(function(x,k){if(x.s.r===j.r&&x.s.c===j.c)i=k});if(i<0){i=p.list.push({n:j.n||'',s:{}})-1}
  var t=p.list[i].s;t.r=j.r;t.c=j.c;t.L=j.L;t.o=j.o;p.cur=i;SHARED=j.d||[]}catch(e){}}
 return p})();
function fix(s){if(!D.races[s.r])s.r='gnome';if(!ok(s.r,s.c))s.c=D.races[s.r].classes.filter(function(c){return D.classes[c]})[0]||'mage';
 s.L=Math.max(1,Math.min(MAXL,+s.L||1));s.o=s.o||{};if(s.o.dg===undefined)s.o.dg=1;s.o.prof=s.o.prof||[];s.o.b=s.o.b||{};s.done=s.done||{};return s}
var S=fix(P.list[P.cur].s);
// P.in = è già entrato nella guida: riaprendo il link normale torna dritto al suo personaggio (👥 Personaggi riapre la pagina iniziale)
if(P.in)HOME=false;
function ok(r,c){return D.races[r]&&D.races[r].classes.indexOf(c)>-1&&!!D.classes[c]}
function save(){store('wfcP',JSON.stringify(P))}
function setHash(){history.replaceState(null,'',HOME?location.pathname+location.search:'#'+S.r+'-'+S.c)}
var RA,CL,TAL,RT,FA,PT,CK;
// build scelta (A/B/C): sovrascrive ordine dei talent, albero, spec e rotation della classe
function buildView(base){var bs=base.builds||[],B=bs.filter(function(b){return b.id===S.o.b[S.c]})[0]||bs[0];if(!B)return base;
 var o=Object.create(base);o.B=B;if(B.build&&B.build.length){o.build=B.build;o.treeIndex=B.treeIndex}if(B.spec)o.spec=B.spec;if(B.icon)o.specIcon=B.icon;if(B.rotation&&B.rotation.length)o.rotation=B.rotation;return o}
function bind(){RA=D.races[S.r];CL=buildView(D.classes[S.c]);TAL=D.talents[S.c];FA=D.factions[RA.faction];RT=compose();CK=S.r+'-'+S.c+(PT?'-x':'');S.done[CK]=S.done[CK]||{};
 if(SHARED){SHARED.forEach(function(id){S.done[CK][id]=1});SHARED=null;setHash()}save()}

/* ---- percorso: rotta naturale, oppure zona iniziale + cambio di continente + rotta dell'altro continente ---- */
function transferFor(R){var to=R.trunk==='kalimdor'?'eastern-kingdoms':'kalimdor',t=D.transfers&&D.transfers[RA.faction+':'+R.trunk+'>'+to];return t&&D.routes[t.joinRoute]?t:null}
function compose(){
 var R=D.routes[RA.start];PT=S.o.x?transferFor(R):null;if(!PT)return R;
 // la rotta d'arrivo riprende dopo l'ultimo livello coperto dal passaggio (niente tappe doppie)
 var J=D.routes[PT.joinRoute],jn=lv0(PT.steps[0][1]),ms={},jl=Math.max(PT.joinLevel||jn,Math.max.apply(null,PT.steps.map(function(s){return lv1(s[1])}))+1);
 [[R.milestones,0,jn-1],[J.milestones,jl,99]].forEach(function(a){Object.keys(a[0]).forEach(function(k){if(+k>=a[1]&&+k<=a[2])ms[k]=(ms[k]||[]).concat(a[0][k])})});
 var tseg=PT.steps.map(function(s){return [lv0(s[1]),lv1(s[1]),s[0],'',s[6]]});
 return {name:R.name,icon:R.icon,hero:R.hero,trunk:J.trunk,junction:jn,
  segments:R.segments.filter(function(s){return s[0]<jn}).map(function(s){return [s[0],Math.min(s[1],jn-1),s[2],s[3],s[4]]}).concat(tseg,J.segments.filter(function(s){return s[1]>=jl}).map(function(s){return [Math.max(s[0],jl),s[1],s[2],s[3],s[4]]})),
  steps:R.steps.filter(function(s){return lv0(s[1])<jn}).concat(PT.steps,J.steps.filter(function(s){return lv1(s[1])>=jl})),
  quests:R.quests.concat(J.quests),fpNames:R.fpNames.concat(J.fpNames),zones:R.zones.concat(J.zones),milestones:ms,
  bags:R.bags.concat(J.bags.filter(function(b){return !R.bags.some(function(x){return x.name===b.name})})),
  flights:R.flights.concat(J.flights.filter(function(f){return !R.flights.some(function(x){return x.name===f.name})})),transport:R.transport.concat(J.transport)};
}

/* ---- talent (con il perk Talented i punti arrivano 5 livelli prima) ---- */
function off(){return S.o.tal?5:0}
function rankAt(l){var s={},n=Math.min(CL.build.length,Math.max(0,l-9+off()));for(var i=0;i<n;i++)s[CL.build[i]]=(s[CL.build[i]]||0)+1;return s}
function tEnc(l){var s=rankAt(l);return TAL.trees.map(function(t){return t[2].map(function(n){return s[t[0]+'/'+n]||0}).join('').replace(/0+$/,'')}).join('-').replace(/-+$/,'')}
function tAt(l){var i=l-10+off();return i>=0&&i<CL.build.length?CL.build[i]:null}

/* ---- click and go: pulsanti che portano sulla mappa ---- */
function mine(side){return !side||side===(RA.faction==='A'?1:2)}
function near(list,x,y){var b=null,d=1e12;(list||[]).forEach(function(p){if(!mine(p[1]))return;var e=(p[2]-x)*(p[2]-x)+(p[3]-y)*(p[3]-y);if(e<d){d=e;b=p}});return b}
function goBtn(label,x,y,z,pop){return '<button class="go" data-x="'+Math.round(x)+'" data-y="'+Math.round(y)+'" data-z="'+(z||6)+'" data-t="'+String(pop||label).replace(/"/g,'&quot;')+'">📍 '+label+'</button>'}
function npcBtn(p,label){return p?goBtn(label||p[0],p[2],p[3],6.25,'<b>'+(label||p[0])+'</b><br>'+p[0]):''}
function hubBtns(s){var x=s[2],y=s[3],h=goBtn(s[0],x,y,s[4],'<b>'+s[0]+'</b>');
 h+=npcBtn(near(D.map.trainers[S.c],x,y),CL.name+' Trainer')+npcBtn(near(D.map.fp,x,y),'Flight Master')+npcBtn(near(D.map.inn,x,y),'Inn');
 S.o.prof.forEach(function(p){h+=npcBtn(near(D.map.prof[pkey(p)],x,y),p+' Trainer')});return h}
function npcLinks(html,skip){var t=txt(html),h='',seen=skip||{};RT.quests.forEach(function(q){if(!seen[q[0]]&&t.indexOf(q[0])>-1){seen[q[0]]=1;h+=goBtn(q[0],q[2],q[3],6.25,'<b>'+q[0]+'</b><br>'+q[1])}});return h}
// milestone: {t, r?:[razze], f?:'A'|'H', n?:[[npc,x,y]]} → solo quelle della tua razza/fazione, con 📍 sugli NPC
function msFor(l){return [].concat(RT.milestones[l]||[],CL.milestones[l]||[],(FA.milestones&&FA.milestones[l])||[]).filter(function(m){return (!m.r||m.r.indexOf(S.r)>-1)&&(!m.f||m.f===RA.faction)})}
function msBtns(m){var seen={},h=(m.n||[]).map(function(n){seen[n[0]]=1;return goBtn(n[0],n[1],n[2],6.25,'<b>'+n[0]+'</b>')}).join('');return h+npcLinks(m.t,seen)}
function dgBtn(name){var n=name.replace(/[★✔🟡]/g,'').trim().toLowerCase(),d=D.map.dg.filter(function(x){return x[0].toLowerCase()===n||n.indexOf(x[0].toLowerCase())>-1||x[0].toLowerCase().indexOf(n)>-1})[0];return d?goBtn(name,d[2],d[3],5.5,'<b>⚔ '+d[0]+'</b><br>Livelli '+d[1]):''}
document.addEventListener('click',function(e){var b=e.target.closest('.go');if(!b)return;e.preventDefault();
 if(b.dataset.lv){S.L=+b.dataset.lv;renderLevel();return}
 if(b.dataset.sec){showTab('talent');$(b.dataset.sec).scrollIntoView({behavior:'smooth'});return}
 if(!MAPI.fly)return;if(S.tab!=='livello')showTab('mappa');$('lwrap').scrollIntoView({behavior:'smooth',block:'center'});MAPI.fly(+b.dataset.x,+b.dataset.y,+b.dataset.z,b.dataset.t)});

/* ---- attività per livello: usate da percorso e planner ---- */
function stepRange(i){var a=lv0(RT.steps[i][1]),n=RT.steps[i+1];return [i?a:1,n?Math.max(a,lv0(n[1])-1):MAXL]}
function stepAt(l){var k=0;RT.steps.forEach(function(s,i){if(lv0(s[1])<=l)k=i});return k}
function profTasks(l){var P=S.o.prof;if(!P.length)return [];var a=P.join(' e ');
 if(l===5)return ['Impara <b>'+a+'</b> dal Trainer (Apprentice, skill 1–75)'+(P.some(function(p){return /Mining|Herbalism|Skinning/.test(p)})?': raccogli lungo la rotta mentre fai quest.':'.')];
 if(l===10)return ['<b>'+a+'</b>: Journeyman (skill 50 → max 150) dal Trainer.'];
 if(l===20)return ['<b>'+a+'</b>: Expert (skill 125 → max 225) dal Trainer.'];
 if(l===35)return ['<b>'+a+'</b>: Artisan (skill 200 → max 300).'];return []}
function tasksFor(l,first){var t=[],sp=CL.spells.filter(function(x){return x[0]===l}),b=tAt(l);
 if(b){var n=TAL.n[b];t.push([img(n[1])+'<b>Talent:</b> '+n[0]+' '+rankAt(l)[b]+'/'+n[2]+' <span class="note">'+(CL.why[n[0]]||'')+'</span>','<button class="go" data-sec="build">Calcolatore ›</button>'])}
 if(sp.length)t.push([img(sp[0][2])+'<b>Trainer:</b> '+sp.map(function(x){return x[1]}).join(', '),npcBtn(near(D.map.trainers[S.c],RT.steps[stepAt(l)][2],RT.steps[stepAt(l)][3]),CL.name+' Trainer')]);
 msFor(l).forEach(function(m){t.push([m.t,msBtns(m)])});
 profTasks(l).forEach(function(m){var s=RT.steps[stepAt(l)];t.push([m,S.o.prof.map(function(p){return npcBtn(near(D.map.prof[pkey(p)],s[2],s[3]),p+' Trainer')}).join('')])});
 if(l===10)t.push(['Le <b>Waylaid Crates</b> diventano utilizzabili (consegna: '+(FA.crates||'—')+')','']);
 if(S.o.dg)FA.dungeons.forEach(function(d){if(/non consigliat|not recommended/i.test(d[4]||''))return;if(d[1]===l||(first&&d[1]<l&&d[2]>=l&&d[1]>=l-1))t.push(['⚔ <b>'+d[0]+'</b> ('+d[1]+'–'+d[2]+'): entra una volta, con tutte le quest. '+(d[4]||''),dgBtn(d[0])])});
 return t}
// id della voce = capitolo + livello + posizione: uguale in tutte le lingue (i vecchi id, dal testo italiano, vengono convertiti)
var SEQ={};
function taskRow(t,l,key){var k=key+l,id=hash(k+':'+(SEQ[k]=(SEQ[k]||0)+1)),old=hash(key+t[0]),D0=S.done[CK];if(D0[old]&&old!==id){D0[id]=1;delete D0[old];save()}var on=!!D0[id];return '<label class="task'+(on?' ok':'')+'"><input type="checkbox" data-id="'+id+'"'+(on?' checked':'')+'><span class="lv">Liv. '+l+'</span><span class="tx">'+t[0]+(t[1]?'<br>'+t[1]:'')+'</span></label>'}
document.addEventListener('change',function(e){var c=e.target;if(!c.dataset||!c.dataset.id)return;if(c.checked)S.done[CK][c.dataset.id]=1;else delete S.done[CK][c.dataset.id];save();c.parentNode.classList.toggle('ok',c.checked);progress()});

/* ---- scelta del personaggio e opzioni ---- */
function drawPick(){
 $('pkF').innerHTML=['A','H'].filter(function(f){return Object.keys(D.races).some(function(k){return D.races[k].faction===f})}).map(function(f){return '<button data-f="'+f+'" class="'+f+(RA.faction===f?' on':'')+'">'+FN[f]+'</button>'}).join('');
 $('pkR').innerHTML=Object.keys(D.races).filter(function(k){return D.races[k].faction===RA.faction}).map(function(k){var r=D.races[k];return '<button data-r="'+k+'"'+(k===S.r?' class="on"':'')+'><img src="'+IC(r.icon)+'" alt="">'+r.name+'</button>'}).join('');
 $('pkInfo').innerHTML=pickInfo();drawPresets();
 $('pkC').innerHTML=RA.classes.map(function(k){var c=D.classes[k];return '<button data-c="'+k+'"'+(k===S.c?' class="on"':'')+(c?'':' disabled')+'><img src="'+IC('classicon_'+k)+'" alt="">'+(c?c.name:k)+'</button>'}).join('');
 var R=D.routes[RA.start],T=transferFor(R),to=R.trunk==='kalimdor'?'eastern-kingdoms':'kalimdor',pick=D.profs&&D.profs.classPicks&&D.profs.classPicks[S.c]||'';
 var row=function(n,lab,btns,note){return '<div><div class="lab">'+n+' · '+lab+'</div><div class="opts">'+btns+'</div>'+(note?'<p class="note" style="margin:.3em 0 0">'+note+'</p>':'')+'</div>'};
 var b=function(k,v,on,label,dis){return '<button data-o="'+k+'" data-v="'+v+'"'+(on?' class="on"':'')+(dis?' disabled':'')+'>'+label+'</button>'};
 $('pkB').innerHTML=(D.classes[S.c].builds||[]).length>1?'<div class="lab">4 · Build</div><div class="bsel">'+bCards()+'</div>':'';
 $('pkO').innerHTML=row(5,'Percorso',b('x',0,!S.o.x,'Resta in '+CN[R.trunk])+b('x',1,!!S.o.x,T?'Passa in '+CN[to]:'Passa in '+CN[to]+' (in arrivo)',!T),T?(S.o.x?T.title+' · '+T.when:'Puoi spostarti in '+CN[to]+' dopo la zona iniziale: il percorso aggiunge quest, Flight Path e viaggi per arrivarci.'):'')+
  row(6,'Professions (max 2)',PROFS.map(function(p){var on=S.o.prof.indexOf(p[0])>-1;return '<button data-p="'+p[0]+'"'+(on?' class="on"':'')+'><img src="'+IC(p[1])+'" alt="">'+p[0]+(pick.indexOf(p[0])>-1?' ★':'')+'</button>'}).join(''),pick?'★ consigliate per il '+CL.name+': '+pick:'')+
  row(7,'Dungeon',b('dg',1,S.o.dg,'Sì, con le quest')+b('dg',0,!S.o.dg,'No, solo quest all’aperto'))+
  row(8,'Perk Legacy “Talented”',b('tal',0,!S.o.tal,'Non ce l’ho')+b('tal',1,!!S.o.tal,'Ce l’ho: talent 5 livelli prima'));
}
$('pg').addEventListener('click',function(e){if(e.target.closest('details.bwhy'))return;var b=e.target.closest('button');if(!b||b.disabled||b.closest('#pkO')&&!b.dataset.o&&!b.dataset.p)return;e.preventDefault();
 if(b.dataset.f&&b.dataset.f!==RA.faction){var r=Object.keys(D.races).filter(function(k){return D.races[k].faction===b.dataset.f});S.r=r.filter(function(k){return ok(k,S.c)})[0]||r[0]}
 if(b.dataset.r)S.r=b.dataset.r;if(b.dataset.c)S.c=b.dataset.c;
 if(b.dataset.o)S.o[b.dataset.o]=+b.dataset.v;
 if(b.dataset.bid)S.o.b[S.c]=b.dataset.bid;
 if(b.dataset.p){var P=S.o.prof,i=P.indexOf(b.dataset.p);if(i>-1)P.splice(i,1);else{P.push(b.dataset.p);if(P.length>2)P.shift()}}
 if(!ok(S.r,S.c))S.c=D.races[S.r].classes.filter(function(c){return D.classes[c]})[0];
 setHash();renderAll()});

/* ---- il tuo percorso: capitoli lineari con checklist ---- */
function renderPath(){var h='';SEQ={};
 RT.steps.forEach(function(s,i){var r=stepRange(i),rows='',key=i+':';
  if(PT&&PT.steps.indexOf(s)>-1&&PT.steps.indexOf(s)===0)rows+=taskRow(['<b>Prima di partire:</b><ul>'+li(PT.unlocks)+'</ul>'+(PT.quests.length?'<b>Quest:</b><ul>'+li(PT.quests.map(function(q){return '<i>'+q[0]+'</i> – '+q[1]+', '+q[2]+' (liv. '+q[3]+'): '+q[4]}))+'</ul>':''),''],r[0],key);
  if(s[7])rows+=taskRow(['✈ Prendi il Flight Path: <b>'+s[7]+'</b>',npcBtn(near(D.map.fp,s[2],s[3]),'Flight Master')],r[0],key);
  var fpn=s[7]?s[7].split(' (')[0]:'';
  for(var l=r[0];l<=r[1];l++)tasksFor(l,l===r[0]).forEach(function(t){if(fpn&&/Flight Path/i.test(t[0])&&txt(t[0]).indexOf(fpn)>-1)return;rows+=taskRow(t,l,key)}); // il Flight Path della tappa c'è già
  var cur=S.L>=r[0]&&S.L<=r[1],nxt=i===stepAt(S.L)+1;
  h+='<details class="chap'+(cur?' cur':'')+(nxt?' nxt':'')+'" data-i="'+i+'"'+(cur?' open':'')+'><summary><img src="'+IC(s[5])+'" alt=""><span><b>'+(i+1)+'. '+s[0]+'</b><small>Livelli '+r[0]+(r[1]>r[0]?'–'+r[1]:'')+(PT&&PT.steps.indexOf(s)>-1?' · cambio continente':'')+'</small></span><span class="pct"></span></summary><div class="body"><p>'+s[6]+'</p><div class="btns" style="margin:6px 0">'+hubBtns(s)+'<button class="go" data-lv="'+r[0]+'">Sono qui</button></div>'+rows+'</div></details>'});
 $('chaps').innerHTML=h;progress()}
function progress(){var all=0,ok=0;[].forEach.call(document.querySelectorAll('#chaps .chap'),function(c){var t=c.querySelectorAll('input[data-id]'),d=c.querySelectorAll('input[data-id]:checked');all+=t.length;ok+=d.length;
  c.querySelector('.pct').textContent=d.length+'/'+t.length;c.classList.toggle('done',t.length>0&&d.length===t.length)});
 $('pgBar').style.width=(all?ok/all*100:0)+'%';$('pgTxt').textContent=ok+' di '+all+' cose fatte · '+RA.name+' '+CL.name+' '+CL.spec+(PT?' · '+PT.title:'')+(S.o.prof.length?' · '+S.o.prof.join(' + '):'')}

/* ---- planner per livello ---- */
function segAt(l){var a=RT.segments,b=null;a.forEach(function(s){if(l>=s[0]&&l<=s[1])b=s});return b||a.filter(function(s){return s[0]<=l}).pop()||a[0]}
// evidenzia nella scheda Dungeon quelli adatti al livello attuale
function dgNow(){[].forEach.call(document.querySelectorAll('#dlist .dg'),function(e){e.classList.toggle('now',!e.classList.contains('skip')&&S.L>=e.dataset.a-1&&S.L<=+e.dataset.b)})}
function renderLevel(){dgNow();
 S.L=Math.max(1,Math.min(MAXL,S.L));save();
 var L=S.L,z=segAt(L),s=rankAt(L),nx=tAt(L),si=stepAt(L),st=RT.steps[si];$('lvn').textContent=L;$('lvr').value=L;
 $('qgo').innerHTML=hubBtns(st)+(si?'<button class="go" data-lv="'+stepRange(si-1)[0]+'">‹ Tappa '+si+'</button>':'')+(si<RT.steps.length-1?'<button class="go" data-lv="'+stepRange(si+1)[0]+'">Tappa '+(si+2)+' ›</button>':'');
 var h='<div class="box"><b class="t">Zona · tappa '+(si+1)+' di '+RT.steps.length+'</b><div style="font:800 1.15rem Cinzel,serif;color:var(--ice)">'+z[2]+'</div><div class="note">'+z[3]+'</div><p style="margin:.4em 0 0">'+z[4]+'</p>'+npcLinks(z[4]+' '+st[6])+'</div>';
 h+='<div class="box"><b class="t">Talent a questo livello</b>';
 if(nx){var t=TAL.n[nx];h+='<div class="it">'+img(t[1])+'<div><b>'+t[0]+'</b> '+s[nx]+'/'+t[2]+'<small>'+(CL.why[t[0]]||t[3])+'</small></div></div><button class="go" data-sec="build">Vedi nel calcolatore ›</button>'}
 else h+='<p class="note">I talent iniziano al livello 10 (al 5 con il perk Talented).</p>';
 h+='</div>';
 var ns=CL.spells.filter(function(x){return x[0]===L});
 h+='<div class="box"><b class="t">Spell nuove dal Trainer</b>'+(ns.length?ns.map(function(x){return '<div class="it">'+img(x[2],'s')+'<div><b>'+x[1]+'</b><small>'+x[3]+'</small></div></div>'}).join('')+npcBtn(near(D.map.trainers[S.c],st[2],st[3]),CL.name+' Trainer più vicino'):'<p class="note">Nessuna spell nuova: '+(L%2?'aggiorna i Rank al prossimo livello pari.':'aggiorna i Rank dal Trainer.')+'</p>')+'</div>';
 var dg=FA.dungeons.filter(function(d){return L>=d[1]&&L<=d[2]});
 if(dg.length&&S.o.dg)h+='<div class="box"><b class="t">Dungeon nel range</b>'+dg.map(function(d){return dgBtn(d[0])}).join('')+'</div>';
 $('plan').innerHTML=h;
 var tl='';for(var l=1;l<=MAXL;l++){var it=[],b=tAt(l);if(b)it.push(img(TAL.n[b][1],'s')+' '+TAL.n[b][0]);
  CL.spells.filter(function(x){return x[0]===l}).forEach(function(x){it.push(x[1])});it=it.concat(msFor(l).map(function(m){return m.t}));if(!it.length)continue;
  tl+='<div class="ev'+(l<L?' done':l===L?' cur':'')+'"><span class="lv">Liv. '+l+'</span><span>'+it.join(' · ')+'</span></div>'}
 $('tl').innerHTML=tl;
 [].forEach.call(document.querySelectorAll('#chaps .chap'),function(c){var i=+c.dataset.i,r=stepRange(i),cur=L>=r[0]&&L<=r[1];c.classList.toggle('cur',cur);c.classList.toggle('nxt',i===si+1);if(cur)c.open=true});
 unsure();
 drawOrder();wfSet();if(MAPI.sync)MAPI.sync();
}
$('lvm').onclick=function(){S.L--;renderLevel()};
$('lvp').onclick=function(){S.L++;renderLevel()};
$('lvr').oninput=function(){S.L=+this.value;renderLevel()};

/* ---- talent: ordine + calcolatore di wowforever.be ---- */
function drawOrder(){
 var g=[],cnt={},o='',f=10-off();
 CL.build.forEach(function(b,i){if(f+i>MAXL)return;if(g.length&&g[g.length-1].k===b)g[g.length-1].n++;else g.push({k:b,n:1,from:f+i})});
 g.forEach(function(x){cnt[x.k]=(cnt[x.k]||0)+x.n;var a=x.from,e=x.from+x.n-1,t=TAL.n[x.k];
  o+='<div class="o'+(S.L>e?' past':'')+(S.L>=a&&S.L<=e?' cur':'')+'" data-lv="'+a+'">'+img(t[1],'s')+'<div><b>'+t[0]+'</b>'+cnt[x.k]+'/'+t[2]+' · liv. '+(a===e?a:a+'–'+e)+'</div></div>'});
 $('order').innerHTML=o;
}
$('order').addEventListener('click',function(e){var b=e.target.closest('.o');if(b){S.L=+b.dataset.lv;renderLevel()}});
// Calcolatore wowforever.be a 380 px: alberi a y=763/1297/1832 (alti 512) (misurato il 1/11/2026, uguale per tutte le classi).
// ponytail: offset fissi; se il sito cambia impaginazione, c'è il pulsante "Tutti e 3 i talent tree".
// La pagina legge ?t= solo all'apertura: due iframe (il vecchio resta visibile finché il nuovo è pronto), un caricamento alla volta, solo se visibile.
var WF={mode:'tree',want:'',shown:null,loading:null,t:null,to:null,vis:false},WFY=[763,1297,1832];
var wfBox=$('wfBox'),wfF=[].slice.call(wfBox.querySelectorAll('iframe')),wfA=0,wfBadge=wfBox.querySelector('.wait');
function wfUrl(enc){return 'https://wowforever.be/it/talents/'+S.c+'/'+(enc?'?t='+enc:'')}
// "Tutti e 3": la pagina caricata larga 1100 px mette gli alberi affiancati (riga a x=30, y=452, 1029×512, uguale per tutte le classi): ritaglio quella riga e la rimpicciolisco.
function wfFit(){var W=wfBox.parentNode.clientWidth||380,all=WF.mode==='all',c=all?[22,444,1045,528]:[0,WFY[CL.treeIndex],380,520],s=Math.min(1,W/c[2]);
 wfBox.style.width=Math.round(c[2]*s)+'px';wfBox.style.height=Math.round(c[3]*s)+'px';
 wfF.forEach(function(f){f.style.width=(all?1100:380)+'px';f.style.height=(all?1400:2600)+'px';f.style.transform='scale('+s+') translate('+(-c[0])+'px,'+(-c[1])+'px)'})}
function wfLoad(){if(!WF.vis||WF.loading!==null||WF.want===WF.shown)return;
 var u=WF.want,f=wfF[1-wfA];WF.loading=u;wfBadge.textContent='Carico il talent tree…';wfBadge.hidden=false;
 clearTimeout(WF.to);WF.to=setTimeout(function(){if(WF.loading===u){WF.loading=null;wfBadge.textContent='wowforever.be non risponde: tocca “Apri ↗”'}},15000);
 f.onload=function(){if(WF.loading!==u)return;f.style.visibility='visible';wfF[wfA].style.visibility='hidden';wfA=1-wfA;WF.shown=u;WF.loading=null;wfBadge.hidden=true;wfLoad()};
 f.src=u}
function wfSet(){var lv=Math.max(10-off(),S.L);$('wfLv').textContent=lv;var u=wfUrl(tEnc(lv));$('wfLink').href=u;
 WF.want=u;clearTimeout(WF.t);WF.t=setTimeout(wfLoad,WF.shown?700:0)}
if('IntersectionObserver' in window)new IntersectionObserver(function(es){WF.vis=es[0].isIntersecting;wfLoad()},{rootMargin:'400px'}).observe(wfBox);else WF.vis=true;
$('wfm').onclick=function(){S.L=Math.max(10-off(),S.L-1);renderLevel()};
$('wfp').onclick=function(){S.L=Math.max(10-off(),S.L)+1;renderLevel()};
$('wfModes').addEventListener('click',function(e){var b=e.target.closest('button');if(!b)return;WF.mode=b.dataset.m;
 [].forEach.call(this.children,function(c){c.classList.toggle('on',c===b)});wfFit()});
addEventListener('resize',wfFit);

/* ---- sezioni che dipendono da razza, classe e opzioni ---- */
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
 $('vCards').innerHTML=(PT?'<div class="card"><h3>'+PT.title+'</h3><p>'+PT.when+'</p><ul>'+li(PT.unlocks)+'</ul>'+(PT.pros?'<p class="note"><b>Pro:</b> '+PT.pros+'<br><b>Contro:</b> '+PT.cons+'</p>':'')+'</div>':'')+
  '<div class="card"><h3>Tram, Boat, Zeppelin</h3><ul>'+li(RT.transport.concat(FA.transport||[]))+'</ul></div>'+(CL.travel?'<div class="card"><h3>Perk del '+CL.name+'</h3>'+CL.travel+'</div>':'');
 // bag
 $('bagt').innerHTML='<tr><th>Liv.</th><th>Bag</th><th>Slot</th><th>Come</th></tr>'+RT.bags.map(function(b){return '<tr><td>'+b.lvl+'</td><td><b>'+b.name+'</b></td><td>'+b.slots+'</td><td>'+b.how+'</td></tr>'}).join('')+C.bagsCommon.map(function(b){return '<tr><td>'+b.join('</td><td>')+'</td></tr>'}).join('');
 renderProf();
 // crates
 $('crc').innerHTML='<p>'+C.crates+'</p><ul>'+li(C.cratesList.concat(FA.crates?['Consegna: <b>'+FA.crates+'</b>']:[]))+'</ul>';
 // camping
 $('campT').textContent='Priorità per il '+CL.name;
 $('camp').innerHTML=CL.camp.map(function(c,i){return card(c[2],c[0],c[3],'<span class="note">· '+c[1]+'</span>'+(i<3?' <span class="pill p-ok">priorità '+(i+1)+'</span>':''))}).join('');
 // dungeon
 // scheda Dungeon: una scheda apribile per dungeon (D.dungeons da data/dungeons.json), giudizio per la tua fazione, quest tue e della tua classe
 var DG=D.dungeons||{dungeons:{},general:[]},fk=RA.faction,ql=function(a){return a.map(function(q){return '<li><b>'+q[0]+'</b> · '+q[q.length-1]+'</li>'}).join('')};
 $('dgen').innerHTML='<b class="t">Come conviene farli</b><ul>'+DG.general.map(function(t){return '<li>'+t+'</li>'}).join('')+'</ul>';
 var dx=function(d){return DG.dungeons[d[0].replace(/[★✔🟡]/g,'').trim().replace(/^The /,'').toLowerCase()]||{}},sk=function(d){var v=(dx(d).v||{})[fk];return v&&v[0]==='skip'?1:0};
 $('dlist').innerHTML=FA.dungeons.filter(function(d){return d[1]<=MAXL+2}).sort(function(a,b){return sk(a)-sk(b)||a[1]-b[1]}).map(function(d){var x=dx(d),v=(x.v||{})[fk],q=x.q||{},
   mq=(q[fk]||[]).concat(q.N||[]),cq=(q.C||[]).filter(function(c){return c[1]===S.c}),V={go:['p-ok','✔ Vai'],opt:['p-wa','🟡 Facoltativo'],skip:['p-bad','✖ Salta']}[v&&v[0]];
  return '<details class="dg'+(v&&v[0]==='skip'?' skip':'')+'" data-a="'+d[1]+'" data-b="'+d[2]+'"><summary><span><b>'+d[0]+'</b><small>Livelli '+d[1]+'–'+d[2]+' · '+d[3]+'</small></span>'+(V?'<span class="pill '+V[0]+'">'+V[1]+(v[1]?' '+v[1]:'')+'</span>':'')+'</summary>'+
   (v&&v[2]?'<p><b>'+v[2]+'</b></p>':'')+(x.e?'<p>📍 '+x.e+' '+dgBtn(d[0])+'</p>':'<p>'+dgBtn(d[0])+'</p>')+(x.k&&x.k[fk]?'<p>🔑 <b>Chiave:</b> '+x.k[fk]+'</p>':'')+
   (mq.length||cq.length?'<h4>Prima di entrare, prendi le quest</h4><ul>'+ql(mq)+ql(cq)+'</ul>':'')+(x.b?'<h4>Boss</h4><ol>'+x.b.map(function(b){return '<li>'+b+'</li>'}).join('')+'</ol>':'')+
   (x.t?'<h4>Consigli</h4><ul>'+x.t.map(function(t){return '<li>'+t+'</li>'}).join('')+'</ul>':'')+(d[4]?'<p class="note">'+d[4]+'</p>':'')+'</details>'}).join('');
 dgNow();
 // fonti
 $('srct').innerHTML='<tr><th>Fonte</th><th>Data / segnale</th><th>Cosa ho preso</th></tr>'+CL.sources.concat(FA.sources,C.sources,D.profs?D.profs.sources:[],D.alts?D.alts.sources:[]).map(srcRow).join('');
 // testata
 document.title=RA.name+' '+CL.name+' '+CL.spec+' – Forever Pathfinder';document.documentElement.style.setProperty('--cc',CL.color||'var(--ice)');
 $('hsub').innerHTML='Guida leveling 1–'+MAXL+' per WoW: Forever · '+FN[RA.faction]+' · <b>'+C.version+'</b> · '+C.updated;
 $('herobg').innerHTML=RT.hero.map(function(u){return '<img src="'+u+'" alt="">'}).join('');
 var vi=document.querySelector('.visits img');vi.onerror=function(){vi.outerHTML='Contatore visite bloccato da un adblock: <a href="'+vi.dataset.src+'" target="_blank" rel="noopener">aprilo qui</a>'};if(!navigator.webdriver)vi.src=vi.dataset.src;
 $('foot').textContent='Guida personale · Forever Pathfinder · '+C.version+' ('+C.updated+'). Non affiliata a Blizzard. Icone © Blizzard via Wowhead.';
 $('lvr').max=MAXL;$('tlsum').textContent='Tutto il percorso 1–'+MAXL+' in una riga temporale';
 WF.shown=null;wfFit();
}

/* ---- professioni e alt ---- */
function renderProf(){var P=CL.professions,X=D.profs;
 $('profc').innerHTML='<div class="card"><h3>Main: gold subito</h3><p>'+(P.gold||C.profGold)+'</p></div><div class="card"><h3>Main: più forza in leveling</h3><p>'+P.power+'</p></div><div class="card"><h3>Il consiglio per il '+CL.name+'</h3><p>'+P.advice+(X&&X.classPicks&&X.classPicks[S.c]?'<br>'+X.classPicks[S.c]:'')+'</p></div>';
 renderAlt();if(!X){$('profx').innerHTML='';return}
 var sel=S.o.prof,ps=X.professions,pc=function(p){return '<details'+(sel.indexOf(p.name)>-1?' open':'')+'><summary>'+img(p.icon,'s')+' '+p.name+' <span class="note">· '+({gathering:'raccolta',crafting:'crafting',secondary:'secondaria'}[p.type]||p.type)+(sel.indexOf(p.name)>-1?' · scelta da te':'')+'</span></summary>'+
  '<p><b>In leveling:</b> '+p.leveling+'</p><p><b>Gold:</b> '+p.gold+'</p>'+(p.pairs&&p.pairs.length?'<p><b>Si abbina con:</b> '+p.pairs.join(', ')+'</p>':'')+(p.camp?'<p><b>Camping:</b> '+p.camp+'</p>':'')+(p.skillByLevel?'<p><b>Trainer e cap:</b> '+p.skillByLevel+'</p>':'')+
  (p.recipes&&p.recipes.length?'<div class="wrap"><table><tr><th>Item / recipe</th><th>Skill</th><th>Perché</th></tr>'+p.recipes.map(function(r){return '<tr><td>'+r.join('</td><td>')+'</td></tr>'}).join('')+'</table></div>':'')+
  (p.forever&&p.forever.length?'<p><b>Novità di Forever:</b></p><ul>'+li(p.forever)+'</ul>':'')+(p.tips&&p.tips.length?'<ul>'+li(p.tips)+'</ul>':'')+'</details>'};
 $('profx').innerHTML='<h3>Le coppie migliori</h3><div class="wrap card"><table><tr><th>Coppia</th><th>Per chi</th><th>Perché</th><th>Fonti</th></tr>'+X.pairs.map(function(p){return '<tr><td><b>'+p.pair+'</b></td><td>'+p.for+'</td><td>'+p.why+'</td><td class="note">'+(p.signal||'')+'</td></tr>'}).join('')+'</table></div>'+
  (X.plan&&X.plan.length?'<h3>Come livellarle mentre livelli</h3><div class="card"><ol>'+li(X.plan)+'</ol></div>':'')+
  '<h3>Tutte le profession</h3>'+ps.filter(function(p){return sel.indexOf(p.name)>-1}).concat(ps.filter(function(p){return sel.indexOf(p.name)<0})).map(pc).join('')+
  (X.gold&&X.gold.length?'<h3>Gold</h3><div class="card"><ul>'+li(X.gold)+'</ul></div>':'');
 $('profx').innerHTML+='<div class="btns"><button class="btn" type="button" onclick="showTab(\'alt\')">Guida agli alt: cosa far fare all’alt ›</button></div>';
}

/* ---- guida alt (data/alts.json; prima versione in profs.json) ---- */
// chi alimenta chi: gathering → crafting che ne usa i materiali, e viceversa (Tailoring/Enchanting si aiutano: stoffa e disenchant)
var FEED={Mining:['Blacksmithing','Engineering'],Herbalism:['Alchemy'],Skinning:['Leatherworking'],Blacksmithing:['Mining'],Engineering:['Mining'],Alchemy:['Herbalism'],Leatherworking:['Skinning'],Tailoring:['Enchanting'],Enchanting:['Tailoring']};
// una profession per ciascuna del main, poi le seconde scelte
function altRule(P){var o=[];[0,1].forEach(function(i){P.forEach(function(p){var x=(FEED[p]||[])[i];if(x&&P.indexOf(x)<0&&o.indexOf(x)<0)o.push(x)})});['Enchanting','Tailoring','Herbalism','Skinning'].forEach(function(x){if(o.length<2&&P.indexOf(x)<0&&o.indexOf(x)<0)o.push(x)});return o.slice(0,2)}
function renderAlt(){var A=D.alts||(D.profs&&D.profs.alts)||{},P=S.o.prof,k=function(x){return x.split(/\s*\+\s*/).map(function(y){return y.trim().toLowerCase()}).sort().join('+')};
 var m=P.length===2&&(A.complements||[]).filter(function(c){return k(c.main)===k(P.join('+'))})[0];
 $('altMine').innerHTML=P.length===2?(m?'<b>Il tuo main fa '+P.join(' + ')+': all’alt fai '+m.alt+'.</b> '+m.why:'<b>Il tuo main fa '+P.join(' + ')+': all’alt fai '+altRule(P).join(' + ')+'.</b> Regola: l’alt usa i materiali che il main raccoglie, o raccoglie quelli che il main lavora (Mining → Blacksmithing/Engineering, Herbalism → Alchemy, Skinning → Leatherworking, Tailoring ↔ Enchanting). Nessuna fonte tratta questa coppia: è un consiglio ricavato, non verificato 🟡.'):'Scegli 2 profession del main in <b>👥 Personaggi</b>: qui comparirà la coppia giusta per il tuo alt.';
 var L=A.legacy||{},list=function(t,a,ol){return a&&a.length?'<div class="card"><h3>'+t+'</h3><'+(ol?'ol':'ul')+'>'+li(a)+'</'+(ol?'ol':'ul')+'></div>':''};
 $('altx').innerHTML=(A.intro?'<p>'+A.intro+'</p>':'')+
  list('Il primo alt, passo per passo',A.firstAlt,1)+list('Livellare l’alt più in fretta',A.faster)+
  ((L.how&&L.how.length)||(L.perks||A.legacy||[]).length?'<h3>Legacy: cosa resta all’account</h3>'+(L.how?'<div class="card"><ul>'+li(L.how)+'</ul></div>':'')+'<div class="wrap card"><table><tr><th>Perk</th><th>Effetto</th><th>Costo</th><th>Note</th></tr>'+(L.perks||(Array.isArray(A.legacy)?A.legacy:[])).map(function(r){return '<tr><td><b>'+r[0]+'</b></td><td>'+r[1]+'</td><td>'+(r.length>3?r[2]:'')+'</td><td>'+(r.length>3?r[3]:r[2]||'')+'</td></tr>'}).join('')+'</table></div>':'')+
  (A.complements&&A.complements.length?'<h3>Profession: main → alt</h3><div class="wrap card"><table><tr><th>Main</th><th>Alt</th><th>Perché</th></tr>'+A.complements.map(function(c){var on=m===c;return '<tr'+(on?' style="background:#2a2412"':'')+'><td><b>'+c.main+'</b></td><td><b>'+c.alt+'</b></td><td>'+c.why+'</td></tr>'}).join('')+'</table></div>':'')+
  altClasses(A)+altRaces(A)+
  '<div class="grid">'+list('Bank alt',A.bankAlt)+list('Alt per il crafting',A.craftAlts||A.craftAlt)+list('Quale alt fare e quando',A.order)+'</div>'+
  list('Errori da evitare',A.mistakes)+list('Consigli',A.tips)}

// classi come alt: tutte e 9, con utilità per l'account, gold, leveling e abbinamento col tuo main
function altClasses(A){var L=A.altClasses||(A.classes||[]).filter(function(c){return D.classes[c['class']]}).map(function(c){return {'class':c['class'],why:[c.why]}});if(!L.length)return '';
 return '<h3>Quale classe come alt</h3><p class="note">Il tuo main è '+CL.name+': le classi con “si abbina al tuo main” lo completano meglio.</p><div class="grid">'+L.slice().sort(function(x,y){var w=function(c){return c['class']===S.c?2:(c.withMain||[]).indexOf(S.c)>-1?0:1};return w(x)-w(y)}).map(function(c){var k=c['class'],X=D.classes[k]||{name:k},me=k===S.c,good=(c.withMain||[]).indexOf(S.c)>-1;
  return '<div class="card" style="margin:0;padding:10px"><div class="row">'+img('classicon_'+k)+'<div><b>'+X.name+'</b>'+(c.role?' <span class="note">· '+c.role+'</span>':'')+(good?' <span class="pill p-ok">si abbina al tuo main</span>':'')+(me?' <span class="pill p-wa">è la classe del tuo main</span>':'')+
  '<ul>'+li(c.why||[])+'</ul>'+(c.gold?'<p class="note" style="margin:.2em 0"><b>Gold e profession:</b> '+c.gold+'</p>':'')+(c.leveling?'<p class="note" style="margin:.2em 0"><b>Leveling:</b> '+c.leveling+'</p>':'')+'</div></div></div>'}).join('')+'</div>'}
// razze come alt: tutte e 10, racial dai dati del client (⚒ = profession) + perché sceglierla
var PROFRE=/Herbalism|Mining|Skinning|Engineering|Alchemy|Leatherworking|Blacksmithing|Tailoring|Enchanting|Fishing|Cooking|First Aid|Lockpicking|\berb[ae]\b/i;
function altRaces(A){var M={};(A.altRaces||[]).forEach(function(r){M[r.race]=r});
 return '<h3>Quale razza come alt</h3><p class="note">⚒ = racial che aiuta una profession. Solo le razze della tua fazione possono scambiarsi oggetti via mail con il main.</p><div class="grid">'+Object.keys(D.races).sort(function(x,y){return (D.races[x].faction===RA.faction?0:1)-(D.races[y].faction===RA.faction?0:1)}).map(function(k){var R=D.races[k],r=M[k]||{},mine=R.faction===RA.faction;
  return '<div class="card" style="margin:0;padding:10px'+(mine?'':';opacity:.75')+'"><div class="row">'+img(R.icon)+'<div><b>'+R.name+'</b> <span class="note">· '+FN[R.faction]+'</span>'+(mine?'':' <span class="pill p-wa">altra fazione</span>')+
  (r.why&&r.why.length?'<ul>'+li(r.why)+'</ul>':'')+'<p class="note" style="margin:.3em 0 0"><b>Racial:</b> '+R.racials.map(function(x){return (PROFRE.test(x[0]+' '+x[2])?'⚒ ':'')+'<b>'+x[0]+'</b>'}).join(' · ')+'</p>'+
  ((r.bestFor||[]).length?'<p class="note" style="margin:.2em 0 0"><b>Classi:</b> '+r.bestFor.filter(function(c){return D.classes[c]}).map(function(c){return D.classes[c].name}).join(', ')+'</p>':'')+'</div></div></div>'}).join('')+'</div>'}

/* ---- sezioni fisse ---- */
(function(){
 $('hlaunch').textContent=C.launchText;
 $('xpc').innerHTML=C.xpCards.map(function(x){return card(x[0],x[1],x[2])}).join('');$('xpr').innerHTML=li(C.rules);
 $('bagn').innerHTML=C.bagsNote;$('proft').innerHTML=C.profTier;$('profe').innerHTML=li(C.profErrors);$('camps').innerHTML=li(C.campSteps);
 $('limits').innerHTML='<b>Limiti onesti:</b> '+C.limits;
 var end=Date.parse(C.launchUTC),el=$('cd');function t(){var d=end-Date.now();if(d<=0){el.textContent='Forever è uscito!';return}var h=Math.floor(d/36e5);el.textContent='mancano '+Math.floor(h/24)+' g '+(h%24)+' h'}t();setInterval(t,6e4);
})();

/* ---- mappa del mondo: i 3 continenti sulla stessa tela (coordinate globali di Wowhead, pixel a zoom 7) ---- */
// Una sola mappa per tutta la pagina: le tessere e i nomi delle zone si creano una volta; al cambio di personaggio si rifanno solo i livelli che dipendono da fazione/classe/rotta.
// Le tessere che non esistono (oceano) non vengono chieste al server: niente 404, molto meno lag.
var MAP=null,MAPI={},MG={};
var ll=function(x,y){return [-y/128,x/128]},PL=function(a){return a.map(function(p){return ll(p[0],p[1])})};
var BLANK='data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==',WORLD=[ll(8192,0),ll(44544,29700)];
var NODE={cu:['ore','Copper Vein','#e08a3c'],sn:['ore','Tin Vein','#c3ccd2'],ag:['ore','Silver Vein','#e6eef5'],fe:['ore','Iron Deposit','#9aa3ad'],pb:['herb','Peacebloom','#fff6d8'],sl:['herb','Silverleaf','#a6e3a1'],er:['herb','Earthroot','#c8925a'],mr:['herb','Mageroyal','#c9a3ff'],bt:['herb','Briarthorn','#ff7d7d'],bw:['herb','Bruiseweed','#6fcf6f'],sk:['herb','Stranglekelp','#3fa58a'],ws:['herb','Wild Steelbloom','#b7c4cf'],kb:['herb','Kingsblood','#d0473f']};
function pin(n,sz,cls){return LF.divIcon({className:'gpin '+(cls||''),html:'<img src="'+IC(n)+'" alt="">',iconSize:[sz,sz],iconAnchor:[sz/2,sz/2],popupAnchor:[0,-sz/2]})}
function initMap(){
 var box=$('lmap');if(!LF){box.innerHTML='<p class="note" style="padding:16px">La mappa ha bisogno di internet (Leaflet e le immagini della mappa).</p>';return}
 var map=MAP=LF.map(box,{crs:LF.CRS.Simple,minZoom:1,maxZoom:7,zoomSnap:.25,zoomDelta:.5,preferCanvas:true,maxBounds:[ll(4000,-4000),ll(48000,34000)],maxBoundsViscosity:.6});
 var TL=LF.TileLayer.extend({getTileUrl:function(c){var K=this.options.k,M=D.map.conts[K],f=256*Math.pow(2,7-c.z),x=c.x-M.ox/f,y=c.y-M.oy/f,r=M.tiles[c.z]&&M.tiles[c.z][y];
  if(!r||!r.some(function(a){return x>=a[0]&&x<=a[1]}))return BLANK;return 'https://wow.zamimg.com/images/wow/classicplus/world-map/v3/'+K+'/'+c.z+'/'+y+'/'+x+'.webp'}});
 Object.keys(D.map.conts).forEach(function(k,i){var M=D.map.conts[k];new TL('',{k:k,tileSize:256,minZoom:1,maxZoom:7,minNativeZoom:2,maxNativeZoom:7,noWrap:true,keepBuffer:1,updateWhenZooming:false,bounds:[ll(M.ox,M.oy),ll(M.ox+M.w,M.oy+M.h)],
  attribution:i?'':'Mappa © Blizzard Entertainment · tessere e dati <a href="https://www.wowhead.com/forever/world-map" target="_blank" rel="noopener">Wowhead</a>'}).addTo(map)});
 var zl=LF.layerGroup().addTo(map),tl=LF.layerGroup();MG.zl=zl;
 MG.zm=D.map.zones.map(function(z){return [z[0],LF.marker(ll(z[2],z[3]),{interactive:false,keyboard:false,icon:LF.divIcon({className:'zlab',html:'<span><b>'+z[0]+'</b><small>'+z[1]+'</small></span>',iconSize:[0,0]})}).addTo(zl)]});
 D.map.places.forEach(function(t){LF.marker(ll(t[1],t[2]),{interactive:false,keyboard:false,icon:LF.divIcon({className:'tlab',html:'<span>'+(t[3]?'<b>'+t[0]+'</b>':t[0])+'</span>',iconSize:[0,0]})}).addTo(tl)});
 function zcls(){var z=map.getZoom();box.classList.toggle('zfar',z<2.75);box.classList.toggle('zmid',z<3.75);if(z>=4.25)tl.addTo(map);else map.removeLayer(tl)}
 map.on('zoomend',zcls);map.fitBounds(WORLD);zcls();
 var wrap=$('lwrap'),fs=$('lfs');
 fs.onclick=function(){var f=wrap.classList.toggle('full');fs.textContent=f?'✕ Chiudi':'⛶ Schermo intero';document.body.style.overflow=f?'hidden':'';setTimeout(function(){map.invalidateSize()},50)};
 $('lworld').onclick=function(){map.flyToBounds(WORLD,{duration:.6})};
 MAPI.fly=function(x,y,z,html){var to=ll(x,y),far=map.distance(map.getCenter(),to)>60;if(far)map.setView(to,z,{animate:false});else map.flyTo(to,z,{duration:.5});
  if(html)LF.popup({autoPan:false}).setLatLng(to).setContent(html).openOn(map)};
}
function drawMap(){
 var map=MAP;if(!map)return;
 Object.keys(MG).forEach(function(k){if(k!=='zl'&&MG[k] instanceof LF.Layer)map.removeLayer(MG[k])});
 MG.zm.forEach(function(z){var el=z[1].getElement();if(el)el.classList.toggle('r',RT.zones.indexOf(z[0])>-1)});
 var steps=RT.steps,G={},hidden=store('wfcLay')?JSON.parse(store('wfcLay')):{};
 var LAY=[['route','Rotta',RT.icon,1],['fp','Flight Master','ability_mount_gryphon_01',1],['q','Quest della guida','',1],['dg','Dungeons','achievement_dungeon_classicdungeonmaster',1],
  ['boat','Boat, Zeppelin, Tram','inv_misc_anchor',1],['tr',CL.name+' Trainer','classicon_'+S.c,1],['inn','Innkeeper','inv_misc_rune_01',0],['fly','Flight Path','',0],
  ['ore','Ore','inv_ore_copper_01',0],['herb','Herbalism','inv_misc_flower_02',0]];
 if(S.c==='hunter')LAY.push(['pet','Pet da tame','ability_hunter_beasttaming',0]);
 // i livelli pesanti (nodi, pet, rotte di volo) si creano solo quando li accendi
 var make={
  route:function(g){var pts=steps.map(function(s){return [s[2],s[3]]});
   for(var i=1;i<pts.length;i++){var a=pts[i-1],b=pts[i],travel=steps[i][8]!==steps[i-1][8]||Math.hypot(a[0]-b[0],a[1]-b[1])>3500;
    LF.polyline(PL([a,b]),{color:'#000',weight:travel?5:8,opacity:.35,interactive:false}).addTo(g);LF.polyline(PL([a,b]),{color:'#f2c14e',weight:travel?2.5:4.5,dashArray:travel?'4 10':null,lineCap:'round',opacity:.95,interactive:false}).addTo(g)}
   MG.stepM=steps.map(function(s,i){var m=LF.marker(ll(s[2],s[3]),{zIndexOffset:1000,icon:LF.divIcon({className:'spin',html:'<img src="'+IC(s[5])+'" alt=""><b>'+(i+1)+'</b>',iconSize:[38,38],iconAnchor:[19,19]})}).addTo(g);m.on('click',function(){go(i,true)});return m})},
  fp:function(g){D.map.fp.filter(function(f){return mine(f[1])}).forEach(function(f){var on=RT.fpNames.indexOf(f[0])>-1;LF.marker(ll(f[2],f[3]),{icon:pin('ability_mount_gryphon_01',on?28:20,on?'':'dim'),zIndexOffset:on?500:0}).bindPopup('<b>✈ '+(f[4]||f[0])+'</b><br>Flight Master: '+f[0]+(on?'<br><span style="color:#7dff9a">Sulla tua rotta</span>':'')).addTo(g)})},
  q:function(g){RT.quests.forEach(function(q){LF.marker(ll(q[2],q[3]),{zIndexOffset:1200,icon:LF.divIcon({className:'',html:'<span class="qm">!</span>',iconSize:[20,26],iconAnchor:[10,13]})}).bindPopup('<b>'+q[0]+'</b><br>'+q[1]).addTo(g)})},
  dg:function(g){D.map.dg.forEach(function(d){var lv=parseInt(d[1])||99,nr=lv<=MAXL+2;LF.marker(ll(d[2],d[3]),{icon:pin('achievement_dungeon_classicdungeonmaster',nr?28:20,nr?'':'dim')}).bindPopup('<b>⚔ '+d[0]+'</b>'+(d[4]?' ★ nuovo':'')+(d[5]?' (raid)':'')+'<br>Livelli '+(d[1]||'—')).addTo(g)})},
  boat:function(g){D.map.ships.forEach(function(s){LF.polyline(PL(s[1]),{color:s[0]==='zeppelin'?'#ffb070':'#7fd3ff',weight:2.5,dashArray:'6 6',opacity:.8,interactive:false}).addTo(g)});
   D.map.boat.filter(function(b){return mine(b[2])}).forEach(function(b){LF.marker(ll(b[3],b[4]),{icon:pin(b[1]==='tram'?'inv_gizmo_02':b[1]==='zeppelin'?'inv_misc_enggizmos_06':'inv_misc_anchor',24)}).bindPopup('<b>'+({tram:'Deeprun Tram',zeppelin:'Zeppelin',ship:'Boat'}[b[1]]||b[1])+'</b><br>'+b[0]).addTo(g)})},
  tr:function(g){(D.map.trainers[S.c]||[]).filter(function(t){return mine(t[1])}).forEach(function(t){LF.marker(ll(t[2],t[3]),{icon:pin('classicon_'+S.c,24)}).bindPopup('<b>'+CL.name+' Trainer</b><br>'+t[0]).addTo(g)})},
  inn:function(g){D.map.inn.filter(function(t){return mine(t[1])}).forEach(function(t){LF.marker(ll(t[2],t[3]),{icon:pin('inv_misc_rune_01',20)}).bindPopup('<b>Innkeeper</b><br>'+t[0]).addTo(g)})},
  fly:function(g){D.map.flights.filter(function(f){return mine(f[0])}).forEach(function(f){LF.polyline(PL(f[1]),{color:'#cfe8ff',weight:1.5,opacity:.55,interactive:false}).addTo(g)})},
  pet:function(g){D.map.pets.forEach(function(p){LF.circleMarker(ll(p[3],p[4]),{radius:4,color:'#000',weight:1,fillColor:'#ffd75a',fillOpacity:.95}).bindTooltip(p[0]+' ('+p[1]+(p[2]?', liv. '+p[2]:'')+')').addTo(g)})},
  ore:function(g){nodes(g,'ore')},herb:function(g){nodes(g,'herb')}};
 function nodes(g,t){Object.keys(NODE).forEach(function(k){if(NODE[k][0]!==t)return;var a=D.map.nodes[k]||[],n=NODE[k];for(var i=0;i<a.length;i+=2)LF.circleMarker(ll(a[i],a[i+1]),{radius:3.5,color:'#000',weight:1,fillColor:n[2],fillOpacity:.95}).bindTooltip(n[1]).addTo(g)})}
 function show(k,on){if(on){if(!G[k]){G[k]=MG[k]=LF.layerGroup();make[k](G[k])}G[k].addTo(map)}else if(G[k])map.removeLayer(G[k])}
 var vis=function(l){return hidden[l[0]]===undefined?!!l[3]:!hidden[l[0]]};
 $('lchips').innerHTML=LAY.map(function(l){var dot=l[0]==='fly'?'<i style="background:#cfe8ff"></i>':l[0]==='q'?'<span class="qm" style="width:14px;font-size:16px;line-height:18px">!</span>':'<img src="'+IC(l[2])+'" alt="">';
  if(l[0]==='ore')dot+='<i style="background:#e08a3c"></i><i style="background:#c3ccd2"></i>';if(l[0]==='herb')dot+='<i style="background:#fff6d8"></i><i style="background:#a6e3a1"></i><i style="background:#c9a3ff"></i>';
  return '<button data-k="'+l[0]+'" class="'+(vis(l)?'on':'')+'">'+dot+l[1]+'</button>'}).join('');
 LAY.forEach(function(l){show(l[0],vis(l))});
 $('lchips').onclick=function(e){var b=e.target.closest('button');if(!b)return;var k=b.dataset.k,on=!b.classList.contains('on');b.classList.toggle('on',on);hidden[k]=!on;store('wfcLay',JSON.stringify(hidden));show(k,on)};
 $('msteps').innerHTML=steps.map(function(s,i){return '<button class="mstep" data-i="'+i+'"><img src="'+IC(s[5])+'" alt=""><span>'+(i+1)+'. '+s[0]+'<small>liv. '+s[1]+'</small></span></button>'}).join('');
 var cur=-1;
 function go(i,fly){var s=steps[i];cur=i;
  [].forEach.call(document.querySelectorAll('.mstep'),function(b){b.classList.toggle('on',+b.dataset.i===i);if(+b.dataset.i===i&&fly)b.scrollIntoView({inline:'center',block:'nearest',behavior:'smooth'})});
  (MG.stepM||[]).forEach(function(m,j){var el=m.getElement();if(el)el.classList.toggle('on',j===i)});
  if(fly)MAPI.fly(s[2],s[3],s[4]);else map.setView(ll(s[2],s[3]),s[4],{animate:false});
  var r=stepRange(i),dg=S.o.dg?FA.dungeons.filter(function(d){return d[1]<=r[1]+2&&d[2]>=r[0]}):[];
  $('mpanel').innerHTML='<div class="mpanel2"><img class="z" src="'+IC(s[5])+'" alt=""><div><b class="t">Tappa '+(i+1)+' di '+steps.length+' · livelli '+s[1]+' · '+CN[s[8]]+'</b><div style="font:800 1.2rem Cinzel,serif;color:var(--ice)">'+s[0]+'</div><p style="margin:.35em 0">'+s[6]+'</p>'+
   (s[7]?'<p class="note">✈ Flight path da prendere: <b>'+s[7]+'</b></p>':'')+'<div>'+hubBtns(s).replace(new RegExp('📍 '+s[0].replace(/[.*+?^${}()|[\]\\]/g,'\\$&')),'📍 Centra')+npcLinks(s[6])+(dg.length?dg.map(function(d){return dgBtn(d[0])}).join(''):'')+'</div>'+
   '<div class="btns" style="margin-bottom:0">'+(i?'<button class="btn" data-go="'+(i-1)+'">‹ Tappa '+i+'</button>':'')+(i<steps.length-1?'<button class="btn pr" data-go="'+(i+1)+'">Tappa '+(i+2)+' ›</button>':'')+'</div></div></div>'}
 $('msteps').onclick=function(e){var b=e.target.closest('.mstep');if(b)go(+b.dataset.i,true)};
 $('mpanel').onclick=function(e){var b=e.target.closest('[data-go]');if(b)go(+b.dataset.go,true)};
 MAPI.sync=function(){var i=stepAt(S.L);if(i!==cur)go(i,false)};
 go(stepAt(S.L),false);
}


/* ---- build: schede con barre rosso → verde (voti 1–5 dalle fonti, col perché) ---- */
var CRIT=[['speed','Velocità'],['ease','Facilità'],['versatility','Versatilità'],['survival','Sopravvivenza'],['aoe','AoE / pull multipli'],['gear','Indipendenza dall’equip']];
function bars(B){var R=B.ratings||{};return '<div class="bars">'+CRIT.map(function(c){var v=R[c[0]]&&R[c[0]][0];return '<div class="bar'+(v?'':' na')+'"><span>'+c[1]+'</span><span class="tr"><i style="width:'+(v?v*20:0)+'%;background:hsl('+(v?(v-1)*30:0)+',72%,46%)"></i></span><b>'+(v||'–')+'</b></div>'}).join('')+'</div>'+
 '<details class="bwhy"><summary>Perché questi voti</summary><ul>'+CRIT.filter(function(c){return R[c[0]]&&R[c[0]][0]}).map(function(c){var r=R[c[0]];return '<li><b>'+c[1]+' '+r[0]+'/5:</b> '+r[1]+(r[2]?' <span class="note">('+r[2]+')</span>':'')+'</li>'}).join('')+'</ul></details>'}
function bCards(){var bs=D.classes[S.c].builds||[],cur=CL.B&&CL.B.id;return bs.map(function(B){return '<button type="button" class="bcard'+(B.id===cur?' on':'')+'" data-bid="'+B.id+'"><span class="bh">'+img(B.icon||CL.specIcon)+'<span><b>'+B.name+'</b>'+(B.id===bs[0].id?' <span class="pill p-ok">più votata</span>':'')+'<br><span class="note">'+(B.when||'')+'</span></span></span>'+
 ((B.pros&&B.pros.length?'<ul>'+li(B.pros.map(function(p){return '✔ '+p}))+li((B.cons||[]).map(function(p){return '✖ '+p}))+'</ul>':''))+bars(B)+'</button>'}).join('')}
document.addEventListener('click',function(e){var b=e.target.closest('#bSel .bcard');if(!b||e.target.closest('details'))return;S.o.b[S.c]=b.dataset.bid;renderAll()});

/* ---- schede ---- */
function showTab(t){S.tab=t;save();[].forEach.call(document.querySelectorAll('nav button'),function(b){var on=b.dataset.tab===t;b.classList.toggle('on',on);if(on){var n=b.parentNode;n.scrollLeft=b.offsetLeft-n.clientWidth/2+b.offsetWidth/2}});
 [].forEach.call(document.querySelectorAll('.tab'),function(d){d.classList.toggle('on',d.id==='t-'+t)});
 var w=$('lwrap');if(t==='livello')$('miniHost').appendChild(w);else if(w.parentNode.id==='miniHost')$('mappa').insertBefore(w,$('lchips'));
 if(MAP)setTimeout(function(){MAP.invalidateSize()},30);if(t==='talent'){wfFit();wfLoad()}bugLink();var n=$('nav');if(window.scrollY>n.offsetTop)window.scrollTo(0,n.offsetTop)}
$('nav').addEventListener('click',function(e){var b=e.target.closest('button');if(b)showTab(b.dataset.tab)});
$('bAllChaps').onclick=function(){var c=$('chaps').classList.toggle('all');this.textContent=c?'Mostra solo il capitolo attuale':'Mostra tutto il percorso'};

/* ---- filtro "solo dati confermati": nasconde ogni voce che contiene 🟡 ---- */
function unsure(){[].forEach.call(document.querySelectorAll('main li, main .task, main tr, main .rc, main .card, main .box p, main details.chap .body>p'),function(e){e.classList.toggle('unsure',e.textContent.indexOf('🟡')>-1&&!e.querySelector('.task,.card,li'))})}
$('bSure').onchange=function(){P.sure=this.checked;save();document.body.classList.toggle('sure',P.sure)};

/* ---- passa i progressi a un altro dispositivo: link + QR ---- */
function shareUrl(){var j={r:S.r,c:S.c,n:P.list[P.cur].n||undefined,L:S.L,o:S.o,d:Object.keys(S.done[CK]||{})},b=btoa(unescape(encodeURIComponent(JSON.stringify(j)))).replace(/\+/g,'-').replace(/\//g,'_').replace(/=+$/,'');return location.href.split('#')[0]+'#s='+b}
$('bShare').onclick=function(){var u=shareUrl();$('shareUrl').value=u;var q=$('qr');q.innerHTML='';$('shareCopy').textContent='Copia il link';
 if(window.qrcode){try{var g=qrcode(0,'L');g.addData(u);g.make();q.innerHTML=g.createSvgTag({cellSize:4,margin:2,scalable:true})}catch(e){q.textContent='Link troppo lungo per il QR: copia il link.'}}else q.textContent='QR non disponibile offline: copia il link.';
 $('shareDlg').showModal()};
$('shareCopy').onclick=function(){var i=$('shareUrl');i.select();try{navigator.clipboard.writeText(i.value)}catch(e){document.execCommand('copy')}this.textContent='Copiato ✔'};

/* ---- segnala un errore: issue già compilata nel repo GitHub ---- */
function bugLink(){var t='Errore: '+RA.name+' '+CL.name+' liv. '+S.L+' ('+(S.tab||'livello')+')',b='**Personaggio:** '+RA.name+' '+CL.name+' – build '+(CL.B?CL.B.name:CL.spec)+'\n**Livello:** '+S.L+'\n**Scheda:** '+(S.tab||'livello')+'\n**Percorso:** '+RT.name+(PT?' + '+PT.title:'')+'\n\n**Cosa non torna:**\n\n\n**Cosa dovrebbe dire (se lo sai):**\n';
 $('bBug').href='https://github.com/foreverpathfinder/foreverpathfinder.github.io/issues/new?title='+encodeURIComponent(t)+'&body='+encodeURIComponent(b)}

/* ---- pagina iniziale: personaggi salvati + scelta razza/classe; barra compatta del personaggio sopra le schede ---- */
function esc(s){return String(s).replace(/[&<>"]/g,function(c){return '&#'+c.charCodeAt(0)+';'})}
function pSpec(s){var bs=D.classes[s.c].builds||[],B=bs.filter(function(b){return b.id===(s.o.b||{})[s.c]})[0]||bs[0];return B&&B.spec||D.classes[s.c].spec}
function preBtns(add){return P.list.map(function(p,i){var s=fix(p.s),rc=D.races[s.r].name+' '+D.classes[s.c].name;
  return '<button type="button" class="pre'+(i===P.cur?' on':'')+'" data-pi="'+i+'"><img src="'+IC('classicon_'+s.c)+'" alt=""><span><b>'+esc(p.n||rc)+'</b><small>'+(p.n?rc+' ':'')+pSpec(s)+' · liv. '+s.L+'</small></span></button>'}).join('')+
 (add?'<button type="button" class="pre add" data-pi="new">＋ Nuovo personaggio</button>':'')}
// salvataggio su file: .txt con una riga di spiegazione e tutti i personaggi (P) in base64; lo rilegge solo "Carica salvataggio"
var SVH='Forever Pathfinder (WoW: Forever) - file di salvataggio. Per ripristinarlo: guida, 👥 Personaggi, Carica salvataggio. Non modificare la riga qui sotto.';
$('svSave').onclick=function(){var a=document.createElement('a');a.href=URL.createObjectURL(new Blob([SVH+'\n'+btoa(unescape(encodeURIComponent(JSON.stringify(P))))+'\n'],{type:'text/plain'}));a.download='WoW-Forever-salvataggio-'+new Date().toISOString().slice(0,10)+'.txt';a.click();setTimeout(function(){URL.revokeObjectURL(a.href)},1000)};
$('svLoad').onchange=function(){var f=this.files[0];this.value='';if(f)f.text().then(function(t){var p=null;try{p=JSON.parse(decodeURIComponent(escape(atob(t.trim().split('\n').pop().trim()))));p.list=p.list.filter(function(x){return x&&x.s})}catch(e){p=null}
 if(!p||!p.list||!p.list.length)return alert('Questo file non è un salvataggio della guida.');
 if(!confirm('Caricare '+p.list.length+(p.list.length>1?' personaggi':' personaggio')+' dal salvataggio? Sostituisce quelli su questo dispositivo.'))return;
 p.in=1;store('wfcP',JSON.stringify(p));location.href=location.pathname})};
function drawPresets(){$('pre').innerHTML=preBtns(true);$('cpre').innerHTML=preBtns(false);$('pDel').disabled=P.list.length<2}
function usePreset(i){P.cur=i;S=fix(P.list[i].s);save();setHash();renderAll();if(!HOME)showTab(S.tab||'livello')}
document.addEventListener('click',function(e){var b=e.target.closest('.pre[data-pi]');if(!b)return;
 if(b.dataset.pi==='new'){P.list.push({n:'',s:{}});usePreset(P.list.length-1);$('pg').scrollIntoView({behavior:'smooth'})}else if(+b.dataset.pi!==P.cur)usePreset(+b.dataset.pi)});
$('pRen').onclick=function(){var p=P.list[P.cur],n=prompt('Nome del personaggio (vuoto = razza e classe)',p.n||'');if(n===null)return;p.n=n.trim().slice(0,30);save();drawPresets()};
$('pDel').onclick=function(){if(P.list.length<2||!confirm('Eliminare “'+(P.list[P.cur].n||RA.name+' '+CL.name)+'” con livello e checklist?'))return;P.list.splice(P.cur,1);usePreset(Math.max(0,P.cur-1))};
function goHome(on){HOME=on;if(!on&&!P.in){P.in=1;save()}document.body.classList.toggle('home',on);setHash();window.scrollTo(0,0);if(!on)showTab(S.tab||'livello')}
$('bWiz').onclick=function(){goHome(true)};
$('lang').onclick=function(){store('wfcLang',this.hreflang);this.href=this.href.split('#')[0]+location.hash};
$('bGo').onclick=function(){goHome(false)};
// pro e contro di razza, classe e combinazione (racial e altRaces/altClasses della guida alt, build più votata)
function pickInfo(){var A=D.alts||{},ar=(A.altRaces||[]).filter(function(x){return x.race===S.r})[0],ac=(A.altClasses||[]).filter(function(x){return x.class===S.c})[0],B=(D.classes[S.c].builds||[])[0]||{},
  nm=function(k){return D.classes[k]?D.classes[k].name:k},pro=function(a){return li(a.map(function(x){return '✔ '+x}))},con=function(a){return li(a.map(function(x){return '✖ '+x}))},
  best=(A.altRaces||[]).filter(function(x){return D.races[x.race]&&D.races[x.race].faction===RA.faction&&x.bestFor.indexOf(S.c)>-1}).map(function(x){return x.race}),
  no=Object.keys(D.classes).filter(function(k){return RA.classes.indexOf(k)<0}),cr=CL.races[S.r]||CL.races[S.r.replace(/_[ah]$/,'')];
 var box=function(icon,t,body){return '<div class="card"><h4>'+img(icon)+t+'</h4>'+body+'</div>'};
 return box(RA.icon,RA.name+' <small>'+FN[RA.faction]+'</small>','<ul>'+pro(RA.racials.map(function(r){return '<b>'+r[0]+'</b>'+(/★/.test(r[2])?' ★':'')}))+
   (ar&&ar.bestFor.length?pro(['Ideale per '+ar.bestFor.map(nm).join(', ')]):'')+(no.length?con(['Niente '+no.map(nm).join(', ')]):'')+'</ul><p class="note">Inizio: '+D.routes[RA.start].name+'</p>')+
  box('classicon_'+S.c,CL.name+(ac?' <small>'+ac.role+'</small>':''),'<ul>'+pro(B.pros||[])+con(B.cons||[])+'</ul>'+(CL.chips.length?'<p class="note">'+CL.chips.map(function(c){return img(c[0])+' '+c[1]}).join(' · ')+'</p>':''))+
  box('classicon_'+S.c,RA.name+' '+CL.name,'<ul>'+(cr?pro([cr]):'')+(best.indexOf(S.r)>-1?pro(['Tra le razze più consigliate per '+CL.name]):best.length?con(['Per '+CL.name+' sono più consigliate: '+best.map(function(k){return D.races[k].name}).join(', ')]):'')+'</ul>')}

function renderAll(){bind();drawPick();renderClass();$('bSel').innerHTML=bCards();renderPath();drawMap();renderLevel();bugLink();unsure()}
initMap();renderAll();$('bSure').checked=!!P.sure;document.body.classList.toggle('sure',!!P.sure);goHome(HOME);
