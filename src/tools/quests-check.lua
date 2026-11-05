-- uso: FENGARI=<cartella>/node_modules/fengari node src/tools/runlua.js src/tools/quests-check.lua addon/ForeverPathfinder/Data.lua "<AddOns>/MapUtils/data/forever/questgivers.lua"
-- controllo dei collegamenti voce → quest per ogni razza-classe, con il database delle quest di Forever di MapUtils (QUESTINFO:
-- [id] = { livello, livello minimo, nome, fazione 1/2, categoria, livello max, razze (bit), classi (bit), … }).
-- Stampa: NOME? quest collegata che non esiste; NON-TUA quest che la tua razza/classe/fazione non può fare; MANCA nomi di quest
-- scritti nella voce ma non collegati (solo se fattibili per la combinazione)
local DATA, MU = ...
dofile(DATA)
local MapUtils = {}
assert(loadfile(MU))(nil, MapUtils)
local INFO = MapUtils.QUESTINFO
local byName = {}
for id, q in pairs(INFO) do local n = q[3]; byName[n] = byName[n] or {}; table.insert(byName[n], q) end
local RACE = { human = 1, orc = 2, dwarf = 3, nightelf = 4, scourge = 5, tauren = 6, gnome = 7, troll = 8 }
local CLASS = { warrior = 1, paladin = 2, hunter = 3, rogue = 4, priest = 5, shaman = 7, mage = 8, warlock = 9, druid = 11 }
local function bit(mask, n) return n == nil or math.floor(mask / 2 ^ (n - 1)) % 2 == 1 end
local function fits(q, side, race, class)
  if q[4] and q[4] ~= side then return false end
  if q[7] and race and not bit(q[7], race) then return false end
  if q[8] and class and not bit(q[8], class) then return false end
  return true
end
local names = {}
for n in pairs(byName) do if #n >= 10 and n:find(" ") then names[#names + 1] = n end end
local D, P, G, L = ForeverPathfinderData.en, ForeverPathfinderPool.en, ForeverPathfinderPages.en, ForeverPathfinderLinks.en
local seen, out = {}, {}
local function add(s) if not seen[s] then seen[s] = true; out[#out + 1] = s end end
for k, g in pairs(D) do
  if k:sub(1, 1) ~= "_" then
    local r, c = k:match("^(.-)%-(.+)$")
    local side = g.faction == "A" and 1 or 2
    local race = RACE[r] -- skyborne: razza nuova, bit sconosciuto → solo fazione e classe
    for _, v in pairs(g.v) do
      for lv, _, n in G[v.tasks]:gmatch("(%d+),(%d+),(%d+),%w+") do
        local t, l = P[tonumber(n)]:gsub("^%^[^%^]*%^", ""), L[tonumber(n)]
        local linked = {}
        for _, q in ipairs(l and l.q or {}) do
          linked[q] = true
          local list = byName[q]
          if not list then add("NOME?   " .. q .. "   [" .. t:sub(1, 70) .. "]")
          elseif not (l.any) then
            local ok = false
            for _, e in ipairs(list) do ok = ok or fits(e, side, race, CLASS[c]) end
            if not ok then add("NON-TUA " .. k .. ": " .. q .. "   [" .. t:sub(1, 70) .. "]") end
          end
        end
        if not t:find("^Trainer") and not t:find("^Before you leave") then
          for _, nm in ipairs(names) do
            if not linked[nm] and t:find(nm, 1, true) then
              local ok = false
              for _, e in ipairs(byName[nm]) do ok = ok or fits(e, side, race, CLASS[c]) end
              if ok then add("MANCA   " .. nm .. "   [" .. t:sub(1, 90) .. "]") end
            end
          end
        end
      end
    end
  end
end
table.sort(out)
for _, s in ipairs(out) do print(s) end
