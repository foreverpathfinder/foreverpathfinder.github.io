// node runlua.js script.lua arg → esegue uno script Lua con fengari (FENGARI = cartella del modulo), passando arg come ...
const { lua, lauxlib, lualib, to_luastring } = require(process.env.FENGARI);
const L = lauxlib.luaL_newstate(); lualib.luaL_openlibs(L);
if (lauxlib.luaL_loadfile(L, to_luastring(process.argv[2])) !== 0) throw new Error(lua.lua_tojsstring(L, -1));
const args = process.argv.slice(3); args.forEach(a => lua.lua_pushstring(L, to_luastring(a)));
if (lua.lua_pcall(L, args.length, 0, 0) !== 0) throw new Error(lua.lua_tojsstring(L, -1));
