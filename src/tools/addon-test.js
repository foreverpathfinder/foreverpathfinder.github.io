// node src/tools/addon-test.js → prova l'addon fuori dal gioco: carica Data.lua e Core.lua in un WoW finto (addon-test.lua)
// con fengari (Lua in JavaScript). Serve fengari: npm i --prefix <cartella> fengari, poi FENGARI=<cartella>/node_modules/fengari
const path=require('path'),{lua,lauxlib,lualib,to_luastring}=require(process.env.FENGARI||'fengari');
const DIR=path.join(__dirname,'../../addon/ForeverPathfinder').replace(/\\/g,'/');
const CASES=[
 {LOCALE:'enUS',RACE:'Human',CLASS:'WARRIOR',FACTION:'Alliance',EXPECT_KEY:'human-warrior',ADDON_LANG:'it'},
 {LOCALE:'enUS',RACE:'Scourge',CLASS:'MAGE',FACTION:'Horde',EXPECT_KEY:'undead-mage'},
 {LOCALE:'deDE',RACE:'Skyborne',CLASS:'DRUID',FACTION:'Horde',EXPECT_KEY:'skyborne_h-druid'},
 {LOCALE:'itIT',RACE:'NightElf',CLASS:'HUNTER',FACTION:'Alliance',EXPECT_KEY:'nightelf-hunter'}]; // senza lingua salvata: inglese, anche col gioco in italiano
let bad=0;
for(const c of CASES){const L=lauxlib.luaL_newstate();lualib.luaL_openlibs(L);
 for(const [k,v] of Object.entries({DIR,LEVEL:1,FREE:0,SPENT:0,...c})){if(typeof v==='number')lua.lua_pushinteger(L,v);else lua.lua_pushstring(L,to_luastring(v));lua.lua_setglobal(L,to_luastring(k))}
 const st=lauxlib.luaL_loadfile(L,to_luastring(path.join(__dirname,'addon-test.lua')))||lua.lua_pcall(L,0,0,0);
 if(st){bad++;console.log('ERRORE',c.EXPECT_KEY,c.LOCALE,'\n'+lua.lua_tojsstring(L,-1))}}
console.log(bad?bad+' prove fallite':'addon: tutte le prove ok');process.exitCode=bad?1:0;
