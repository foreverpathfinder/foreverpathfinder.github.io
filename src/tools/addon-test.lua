-- WoW finto per provare l'addon fuori dal gioco (lo lancia addon-test.js con fengari).
-- Globali in ingresso: DIR (cartella dell'addon), LOCALE, RACE, CLASS, FACTION, LEVEL, FREE, SPENT
local texts, chat = {}, {}
local function obj(name)
  local o = { shown = false, text = "", scripts = {}, checked = false, name = name }
  local m = {
    Show = function(s) s.shown = true end, Hide = function(s) s.shown = false end, IsShown = function(s) return s.shown end,
    SetText = function(s, x) s.text = x; texts[#texts + 1] = x end, GetStringHeight = function() return 12 end,
    SetScript = function(s, n, fn) s.scripts[n] = fn end,
    SetChecked = function(s, v) s.checked = v end, GetChecked = function(s) return s.checked end,
    CreateFontString = function() return obj() end,
  }
  return setmetatable(o, { __index = function(_, k) return m[k] or function() end end })
end
local frames = {}
CreateFrame = function(_, name) local o = obj(name); frames[#frames + 1] = o; return o end
UIParent, BackdropTemplateMixin, SlashCmdList = obj(), {}, {}
GetLocale = function() return LOCALE end
UnitRace = function() return "x", RACE end
UnitClass = function() return "x", CLASS end
UnitFactionGroup = function() return FACTION end
UnitLevel = function() return LEVEL end
GetNumTalentTabs = function() return 3 end
GetTalentTabInfo = function(i) return "tree", nil, i == 1 and SPENT or 0 end
UnitCharacterPoints = function() return FREE end
GetBuildInfo = function() return "1.16.0", "99999", "Nov 5 2026", 16001 end
GetAddOnMetadata = function(_, k) return k == "Version" and "test" or nil end
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }

assert(loadfile(DIR .. "/Data.lua"))()
assert(loadfile(DIR .. "/Core.lua"))("ForeverPathfinder")
local f = frames[1]
f.scripts.OnEvent(f, "ADDON_LOADED", "ForeverPathfinder")
local fp = SlashCmdList.FOREVERPATHFINDER

-- attese: se non date, dai dati della razza-classe attesa (EXPECT_KEY), così si verifica anche il riconoscimento della razza
local lang = LOCALE == "itIT" and "it" or "en"
local g = ForeverPathfinderData[lang][EXPECT_KEY]
assert(g, "manca " .. EXPECT_KEY)
EXPECT_TITLE = EXPECT_TITLE or (g.name .. " · " .. (lang == "it" and "Liv. " or "Lvl ") .. LEVEL)
if not EXPECT_TASK then for _, t in ipairs(g.tasks) do if t[1] == LEVEL then EXPECT_TASK = t[3]; break end end end
local EXPECT_TALENT = (lang == "it" and "Talento da prendere ora: " or "Talent to take now: ") .. g.tal[1][2]

local function has(s) for _, t in ipairs(texts) do if t:find(s, 1, true) then return true end end return false end
local function check(ok, what) if not ok then error("FALLITO: " .. what .. "\nultimi testi: " .. table.concat(texts, " | ", math.max(1, #texts - 6))) end end

-- 1) apertura al proprio livello
fp("")
check(f.shown, "/fp apre la finestra")
check(has(EXPECT_TITLE), "titolo " .. EXPECT_TITLE)
check(has(EXPECT_TASK), "voce " .. EXPECT_TASK)
-- 2) level up con un punto talento libero
FREE = 1; f.scripts.OnEvent(f, "PLAYER_LEVEL_UP", 10)
check(has(EXPECT_TALENT), "talento " .. EXPECT_TALENT)
-- nessuna voce ripetuta (il 10 è spesso fine di una tappa e inizio della successiva)
local shown = {}
for _, o in ipairs(frames) do
  if rawget(o, "id") and o.shown then
    local tx = rawget(o, "text") and o.text.text
    check(not shown[tx], "voce ripetuta: " .. tostring(tx)); shown[tx] = true
  end
end
-- 3) spunta di una voce: resta salvata
local cb
for _, o in ipairs(frames) do if rawget(o, "id") and o.shown then cb = o; break end end
check(cb ~= nil, "c'è una voce da spuntare")
cb.checked = true; cb.scripts.OnClick(cb)
check(ForeverPathfinderChar.done[cb.id] == true, "spunta salvata")
-- 4) ogni razza-classe a ogni livello 1–30, con le frecce < >, senza errori
local keys = {}
for k in pairs(ForeverPathfinderData[LOCALE == "itIT" and "it" or "en"]) do keys[#keys + 1] = k end
table.sort(keys)
local prev, nextB = frames[3], frames[4]
for _, k in ipairs(keys) do
  fp("set " .. k); LEVEL = 1; f.shown = false; fp("")
  for _ = 1, 29 do nextB.scripts.OnClick(); fp("dungeon") end
  for _ = 1, 3 do prev.scripts.OnClick() end
end
-- 4b) ricerca e dungeon: lo Human Warrior trova i Deadmines nella guida, poi /fp dungeon elenca le loro quest
local function said(s) for _, m in ipairs(chat) do if m:find(s, 1, true) then return true end end return false end
fp("set human-warrior"); f.shown = false
fp("cerca deadmines")
check(f.shown and said("Deadmines"), "/fp cerca apre la finestra e scrive i risultati")
fp("dungeon")
check(said("Red Silk Bandanas") and said("The Defias Brotherhood"), "/fp dungeon elenca le quest dei Deadmines")
local n0 = #chat; fp("find zzzzzz"); check(#chat == n0 + 1, "ricerca senza risultati: un solo messaggio")
-- 4c) /fp debug: versioni, token di razza e guida riconosciuta, spunta salvata contata
fp("auto"); n0 = #chat; fp("debug")
local dbg = table.concat(chat, "\n", n0 + 1)
check(#chat == n0 + 5 and dbg:find("Interface 16001", 1, true) and dbg:find("/ " .. RACE, 1, true) and dbg:find(EXPECT_KEY, 1, true) and dbg:find("%D1%D+1$"), "/fp debug: 5 righe con Interface, razza, guida\n" .. dbg)
-- 5) razza sconosciuta: messaggio, poi /fp auto torna alla razza vera
fp("set nessuna-razza")
check(chat[#chat]:find("/fp set", 1, true) ~= nil, "messaggio per razza sconosciuta")
fp("auto")
-- 6) chiude
fp(""); f.shown = true; fp(""); check(not f.shown, "/fp chiude")
print("ok", LOCALE, RACE, CLASS, #keys .. " combinazioni x 30 livelli")
