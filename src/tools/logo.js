// node src/tools/logo.js addon/pubblicazione/logo-400.png addon/ForeverPathfinder/icon.tga → logo dell'addon 400×400 per CurseForge e Wago: mappa dipinta (mare, foreste, montagne, fiume, rosa dei venti, sentiero fino alla X) + "!" delle quest, cornice sottile. Senza percorso: anteprima con 64 e 32 px nella cartella dello script
const {chromium}=require(process.env.LOCALAPPDATA+'/npm-cache/_npx/9833c18b2d85bc59/node_modules/playwright-core');
const fs=require('fs');const O=__dirname.replace(/\\/g,'/');const OUT=process.argv[2];
const MAP='M54 98 L150 84 L246 102 L346 88 L352 332 L256 348 L158 332 L50 346 Z';
const DEFS=`<defs>
<radialGradient id="bg" cx="50%" cy="42%" r="75%"><stop offset="0" stop-color="#22466f"/><stop offset=".55" stop-color="#0e1c2e"/><stop offset="1" stop-color="#060c16"/></radialGradient>
<linearGradient id="parch" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#f4e3b5"/><stop offset=".55" stop-color="#e3c48b"/><stop offset="1" stop-color="#b8894c"/></linearGradient>
<radialGradient id="burn" cx="50%" cy="50%" r="64%"><stop offset=".62" stop-color="#6b4319" stop-opacity="0"/><stop offset="1" stop-color="#4a2a0c" stop-opacity=".7"/></radialGradient>
<filter id="paper" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency=".03" numOctaves="4" seed="8" result="n"/>
 <feColorMatrix in="n" type="matrix" values="0 0 0 0 .42  0 0 0 0 .26  0 0 0 0 .1  1.3 0 0 0 -.55" result="c"/><feComposite in="c" in2="SourceAlpha" operator="in" result="t"/>
 <feMerge><feMergeNode in="SourceGraphic"/><feMergeNode in="t"/></feMerge></filter>
<linearGradient id="q" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff3a0"/><stop offset=".25" stop-color="#ffdc2e"/><stop offset=".75" stop-color="#ffb300"/><stop offset="1" stop-color="#d06a00"/></linearGradient><linearGradient id="qside" x1="0" y1="0" x2="1" y2="0"><stop offset=".55" stop-color="#7a3a00" stop-opacity="0"/><stop offset="1" stop-color="#7a3a00" stop-opacity=".45"/></linearGradient>
<radialGradient id="qdot" cx="42%" cy="35%"><stop offset="0" stop-color="#fffbd0"/><stop offset=".45" stop-color="#ffd21f"/><stop offset="1" stop-color="#c86200"/></radialGradient>
<filter id="bloom" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="14"/></filter>
<linearGradient id="frame" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#f6dc8c"/><stop offset=".3" stop-color="#a8761f"/><stop offset=".55" stop-color="#f0cf78"/><stop offset=".8" stop-color="#7d5216"/><stop offset="1" stop-color="#d9b25a"/></linearGradient>
<filter id="sh" x="-25%" y="-25%" width="150%" height="150%"><feDropShadow dx="0" dy="7" stdDeviation="7" flood-color="#000" flood-opacity=".7"/></filter>
<clipPath id="mc"><path d="${MAP}"/></clipPath>
</defs>`;
const stars=(n,seed)=>{let s=seed,o='';const r=()=>(s=(s*9301+49297)%233280)/233280;for(let i=0;i<n;i++)o+=`<circle cx="${(r()*400).toFixed(0)}" cy="${(r()*400).toFixed(0)}" r="${(r()*1.3+.4).toFixed(1)}" fill="#cfefff" opacity="${(r()*.5+.25).toFixed(2)}"/>`;return o};
// montagna con lato in luce e lato in ombra
const mtn=(x,y,s)=>`<g transform="translate(${x} ${y}) scale(${s})"><path d="M0 0 L18 -30 L36 0Z" fill="#a57a45"/><path d="M18 -30 L36 0 L22 0 L20 -14Z" fill="#6e4b23"/><path d="M12 -20 L18 -30 L24 -20 L20 -17 L17 -21Z" fill="#f6ecd2"/></g>`;
const tree=(x,y,s=1)=>`<g transform="translate(${x} ${y}) scale(${s})"><path d="M0 -16 L8 0 H-8Z" fill="#5d6f2e"/><path d="M0 -16 L8 0 H2Z" fill="#3f4d1d"/></g>`;
const forest=(pts)=>pts.map(([x,y,s])=>tree(x,y,s)).join('');
const rose=(x,y)=>`<g transform="translate(${x} ${y})" opacity=".8"><circle r="17" fill="none" stroke="#6e4b23" stroke-width="2"/>${[0,90,180,270].map(a=>`<path transform="rotate(${a})" d="M0 0 L-5 0 L0 -22Z" fill="#6e4b23"/><path transform="rotate(${a})" d="M0 0 L5 0 L0 -22Z" fill="#a3271d"/>`).join('')}<circle r="3" fill="#f4e3b5"/></g>`;
const BAR='M151 64 Q151 56 160 56 L222 56 Q231 56 231 64 L209 258 Q191 266 173 258 Z';
const svg=`<svg viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg">${DEFS}<rect width="400" height="400" fill="url(#bg)"/>${stars(34,5)}
<g transform="rotate(-8 200 215)" filter="url(#sh)"><g filter="url(#paper)">
 <path d="${MAP}" fill="url(#parch)"/>
 <g clip-path="url(#mc)">
  <path d="M250 70 C 262 120, 300 150, 360 150 V60Z" fill="#7fb2b0" opacity=".55"/>
  <path d="M250 70 C 262 120, 300 150, 360 150" fill="none" stroke="#5c4120" stroke-width="3"/>
  <path d="M290 100 q6 -4 12 0 q6 4 12 0 M310 124 q6 -4 12 0 q6 4 12 0" fill="none" stroke="#3f6f73" stroke-width="2" opacity=".7"/>
  <path d="M40 220 C 70 214, 96 236, 120 226 S 150 196, 178 200" fill="none" stroke="#5f97b0" stroke-width="5" stroke-linecap="round" opacity=".75"/>
  ${mtn(70,150,1.1)}${mtn(100,142,1.35)}${mtn(132,152,1)}${mtn(250,214,1.1)}${mtn(276,206,.9)}
  ${forest([[84,268,1],[98,262,1.1],[112,270,.9],[92,284,1],[106,280,1],[262,312,1],[276,306,1.1],[290,314,.9],[230,160,.9],[244,166,1]])}
  <path d="${MAP}" fill="url(#burn)"/>
 </g>
 <path d="M150 84 L158 332 M246 102 L256 348" stroke="#8c6434" stroke-width="2.5" opacity=".4"/>
</g>
 ${rose(86,112)}
 <path d="M70 330 C 100 318, 126 300, 140 276 S 150 236, 168 226 M214 226 C 238 236, 236 270, 262 280 S 300 280, 310 278" fill="none" stroke="#a3271d" stroke-width="6" stroke-linecap="round" stroke-dasharray="1 13"/>
 <g stroke-linecap="round"><path d="M300 266 l26 26 M326 266 l-26 26" stroke="#3a0d08" stroke-width="13"/><path d="M300 266 l26 26 M326 266 l-26 26" stroke="#c0302a" stroke-width="8"/></g>
</g>
<g filter="url(#bloom)" opacity=".85"><path d="${BAR}" fill="#ffc400"/><circle cx="191" cy="312" r="30" fill="#ffc400"/></g>
<g filter="url(#sh)">
 <path d="${BAR}" fill="url(#q)" stroke="#3a1a00" stroke-width="8" stroke-linejoin="round"/><path d="${BAR}" fill="url(#qside)"/>
 <path d="M162 66 L182 66 L180 248 L176 250 Z" fill="#fffbe0" opacity=".35"/>
 <circle cx="191" cy="312" r="27" fill="url(#qdot)" stroke="#3a1a00" stroke-width="8"/>
 <ellipse cx="182" cy="303" rx="9" ry="6" fill="#fffbe0" opacity=".6"/>
</g>
<rect x="5" y="5" width="390" height="390" rx="10" fill="none" stroke="#120902" stroke-width="10"/>
<rect x="5" y="5" width="390" height="390" rx="10" fill="none" stroke="url(#frame)" stroke-width="5"/>
<rect x="10.5" y="10.5" width="379" height="379" rx="6" fill="none" stroke="#000" stroke-width="2" opacity=".8"/>
</svg>`;
(async()=>{const b=await chromium.launch({channel:'chrome'});const p=await b.newPage({viewport:{width:400,height:400}});
 await p.setContent(`<html><body style="margin:0">${svg}</body></html>`);await p.screenshot({path:OUT||`${O}/logo-H.png`});
 // secondo argomento: icona dell'addon per la minimappa, TGA 64×64 a 32 bit (WoW legge TGA e BLP)
 const TGA=process.argv[3];
 if(TGA){const px=await p.evaluate(svg=>new Promise(ok=>{const im=new Image();im.onload=()=>{const c=document.createElement('canvas');c.width=c.height=64;const x=c.getContext('2d');x.drawImage(im,0,0,64,64);ok([...x.getImageData(0,0,64,64).data])};im.src='data:image/svg+xml;base64,'+btoa(unescape(encodeURIComponent(svg)))}),svg);
  const h=Buffer.from([0,0,2,0,0,0,0,0,0,0,0,0,64,0,64,0,32,8]),d=Buffer.alloc(64*64*4);
  for(let r=0;r<64;r++)for(let c=0;c<64;c++){const s=((63-r)*64+c)*4,o=(r*64+c)*4;d[o]=px[s+2];d[o+1]=px[s+1];d[o+2]=px[s];d[o+3]=px[s+3]}
  fs.writeFileSync(TGA,Buffer.concat([h,d]))}
 if(OUT){await b.close();return}
 const img='data:image/png;base64,'+fs.readFileSync(`${O}/logo-H.png`).toString('base64');
 await p.setViewportSize({width:560,height:430});
 await p.setContent(`<body style="margin:0;background:#1b1b1f;display:flex;gap:20px;padding:15px;align-items:center"><img src="${img}" width="400"><div style="display:flex;flex-direction:column;gap:16px;align-items:center"><img src="${img}" width="64"><img src="${img}" width="32"></div></body>`);
 await p.screenshot({path:`${O}/logo-H-confronto.png`});await b.close()})();
