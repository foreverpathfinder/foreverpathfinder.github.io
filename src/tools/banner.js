// node src/tools/banner.js → addon/pubblicazione/banner.png (600×160) e kofi.png (210×160) da banner.html, angoli trasparenti, per CurseForge
const path = require('path');
const { chromium } = require(process.env.LOCALAPPDATA + '/npm-cache/_npx/9833c18b2d85bc59/node_modules/playwright-core');
const DIR = path.join(__dirname, '../../addon/pubblicazione');
(async () => {
  const b = await chromium.launch({ channel: 'chrome' }), p = await b.newPage({ deviceScaleFactor: 1 });
  await p.goto('file:///' + path.join(DIR, 'banner.html').replace(/\\/g, '/'), { waitUntil: 'networkidle' });
  await p.evaluate(() => document.fonts.ready);
  for (const id of ['banner', 'kofi']) await p.locator('#' + id).screenshot({ path: path.join(DIR, id + '.png'), omitBackground: true });
  await b.close(); console.log('ok banner.png kofi.png');
})();
