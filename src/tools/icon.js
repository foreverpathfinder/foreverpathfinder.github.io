// node src/tools/icon.js . → disegna l'icona della schermata Home (oro su blu notte, Cinzel come il titolo) e la salva in 180/192/512 px nella cartella indicata
const {chromium}=require(process.env.LOCALAPPDATA+'/npm-cache/_npx/9833c18b2d85bc59/node_modules/playwright-core');
const O=process.argv[2];
const H=`<html><head><link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@800&display=swap" rel="stylesheet"><style>
html,body{margin:0}body{width:512px;height:512px;display:flex;flex-direction:column;align-items:center;justify-content:center;
background:radial-gradient(circle at 50% 38%,#1d3a5c 0,#0d1a2b 55%,#08111d 100%);font-family:Cinzel,serif}
b{font-size:300px;line-height:.9;background:linear-gradient(#ffe7a3,#e8b84a 55%,#a8761e);-webkit-background-clip:text;color:transparent;filter:drop-shadow(0 6px 10px #000a)}
i{font-style:normal;font-size:40px;letter-spacing:.2em;margin-left:.2em;color:#a9e4ff;margin-top:8px}
</style></head><body><b>F</b><i>PATHFINDER</i></body></html>`;
(async()=>{const b=await chromium.launch({channel:'chrome'});
 for(const s of [512,192,180]){const p=await b.newPage({viewport:{width:512,height:512},deviceScaleFactor:s/512});await p.setContent(H,{waitUntil:'networkidle'});await p.evaluate(()=>document.fonts.ready);
  await p.screenshot({path:O+'/icon-'+s+'.png'});await p.close()}
 await b.close()})();
