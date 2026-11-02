-- WoW finto per provare l'addon fuori dal gioco (lo lancia addon-test.js con fengari).
-- Globali in ingresso: DIR (cartella dell'addon), LOCALE, RACE, CLASS, FACTION, LEVEL, FREE, SPENT, EXPECT_KEY
local texts, chat, fstrings, frames = {}, {}, {}, {}
local function obj(kind, name, template)
  local o = { shown = true, text = "", scripts = {}, checked = false, kind = kind, name = name, template = template }
  local m = {
    Show = function(s) s.shown = true end, Hide = function(s) s.shown = false end, IsShown = function(s) return s.shown end,
    SetText = function(s, x) s.text = x; texts[#texts + 1] = x end, GetText = function(s) return s.text end, GetStringHeight = function() return 12 end,
    SetScript = function(s, n, fn) s.scripts[n] = fn end, GetScript = function(s, n) return s.scripts[n] end,
    SetChecked = function(s, v) s.checked = v end, GetChecked = function(s) return s.checked end,
    CreateFontString = function() local x = obj("FontString"); fstrings[#fstrings + 1] = x; return x end,
    CreateTexture = function() return obj("Texture") end,
    GetCenter = function() return 100, 100 end, GetEffectiveScale = function() return 1 end, GetStringWidth = function() return 40 end,
    GetWidth = function() return 60 end, GetMinMaxValues = function() return 0, 100 end, GetValue = function() return 0 end,
    GetHeight = function() return 40 end, GetFrameLevel = function() return 1 end, GetID = function() return 1 end, GetZoom = function() return 0 end,
    HookScript = function(s, n, fn) s.scripts[n] = fn end,
    SetPoint = function(s, ...) s.point = { ... } end,
  }
  -- come nel gioco: i metodi (con la maiuscola) esistono sempre, i campi mancanti sono nil
  return setmetatable(o, { __index = function(_, k) return m[k] or (k:match("^%u") and function() end) or nil end })
end
CreateFrame = function(kind, name, _, template) local o = obj(kind, name, template); o.shown = kind ~= "Frame" or name ~= nil; frames[#frames + 1] = o; if name then _G[name] = o end; return o end
UIParent, Minimap, BackdropTemplateMixin, SlashCmdList, UISpecialFrames = obj(), obj(), {}, {}, {}
tinsert, unpack = table.insert, unpack or table.unpack -- in WoW (Lua 5.1) unpack è globale
GameTooltip = obj()
CreateFont = function() return obj("Font") end
GetCursorPosition = function() return 100, 180 end
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
-- collegamenti col gioco: mappa del mondo, mappe, registro delle quest, finestra dei talenti, trainer
local hooks = {}
hooksecurefunc = function(a, b, c) if type(a) == "table" then hooks[b] = c else hooks[a] = b end end
local canvas = obj("Frame")
WorldMapFrame = obj("Frame"); WorldMapFrame.ScrollContainer = { Child = canvas }
WorldMapFrame.GetMapID = function() return 1415 end; WorldMapFrame.OnMapChanged = function() end
Enum = { UIMapType = { Continent = 2 } }
UiMapPoint = { CreateFromCoordinates = function(m, x, y) return { m, x, y } end }
WAYPOINT = nil
C_Map = {
  GetMapChildrenInfo = function() return { { mapID = 1414 }, { mapID = 1415 }, { mapID = 2500, name = "Zephras Isle" } } end,
  GetMapRectOnMap = function() return 0.3, 0.5, 0.6, 0.8 end,
  GetMapInfoAtPosition = function() return { mapID = 1429, name = "Elwynn Forest" } end,
  CanSetUserWaypointOnMap = function() return true end, SetUserWaypoint = function(p) WAYPOINT = p end,
  GetBestMapForUnit = function() return 1429 end, GetPlayerMapPosition = function() return { GetXY = function() return 0.5, 0.5 end } end,
  GetMapWorldSize = function() return 30000, 30000 end,
}
QUESTLOG = {}
GetNumQuestLogEntries = function() return #QUESTLOG end
GetQuestLogTitle = function(i) local q = QUESTLOG[i]; return q[1], 1, nil, false, false, q[3], nil, q[2] end
TALENT = nil
GetNumTalents = function() return 1 end
GetTalentInfo = function() return TALENT end
TRAINER = {}
GetNumTrainerServices = function() return #TRAINER end
GetTrainerServiceInfo = function(i) local s = TRAINER[i]; if s then return s, "", "available" end end

ForeverPathfinderDB = ADDON_LANG and { lang = ADDON_LANG } or nil -- lingua scelta nell addon (di base inglese, qualunque sia la lingua del gioco)
assert(loadfile(DIR .. "/Data.lua"))()
assert(loadfile(DIR .. "/Core.lua"))("ForeverPathfinder")
local f = ForeverPathfinderFrame
f.scripts.OnEvent(f, "ADDON_LOADED", "ForeverPathfinder")
f.scripts.OnEvent(f, "PLAYER_LOGIN")
local fp = SlashCmdList.FOREVERPATHFINDER

local lang = ADDON_LANG or "en"
local D = ForeverPathfinderData[lang]
local g = D[EXPECT_KEY]
assert(g, "manca " .. EXPECT_KEY)

local function said(s) for _, m in ipairs(chat) do if m:find(s, 1, true) then return true end end return false end
local function shownTexts() local o = {} for _, x in ipairs(fstrings) do if x.shown and x.text ~= "" then o[#o + 1] = x.text end end return o end
local function has(s) for _, t in ipairs(shownTexts()) do if t:find(s, 1, true) then return true end end return false end
local function check(ok, what) if not ok then error("FALLITO: " .. what .. "\nultimi testi: " .. table.concat(shownTexts(), " | ", 1, math.min(8, #shownTexts()))) end end
local function find(pred) for _, o in ipairs(frames) do if pred(o) then return o end end end
local function boxes() local o = {} for _, x in ipairs(frames) do if x.kind == "CheckButton" and x.shown then o[#o + 1] = x end end return o end
local function nav(label) return find(function(o) return o.kind == "Button" and rawget(o, "fs") and o.fs.text == label and o.scripts.OnClick end) end

-- 0) messaggio di benvenuto e icona sulla minimappa
check(said(lang == "it" and "minimappa" or "minimap"), "messaggio di caricamento")
local mb = ForeverPathfinderMinimapButton
check(mb ~= nil, "icona sulla minimappa")
-- 1) clic sull'icona: si apre il Percorso sulla tappa del livello, con build e voci da spuntare
mb.scripts.OnClick(mb, "LeftButton")
check(f.shown, "il clic sull'icona apre la finestra")
check(has(g.name), "titolo con " .. g.name)
check(has(lang == "it" and "TAPPA" or "STAGE") and has("/ 9"), "tappa 1 di 9")
check(#boxes() > 0, "voci da spuntare")
-- 2) un punto talento libero: la riga gialla dice quale prendere
FREE = 1; f.scripts.OnEvent(f, "CHARACTER_POINTS_CHANGED")
local v = select(2, next(g.v))
local firstTal = ForeverPathfinderPool[lang][v.tal]:match("^([^:]+)")
if firstTal then check(has(firstTal), "talento " .. firstTal) end
-- 3) spunta: resta salvata e si rivede dopo un nuovo disegno
local cb = boxes()[1]
cb.checked = true; cb.scripts.OnClick(cb)
check(ForeverPathfinderChar.done[cb.id] == true, "spunta salvata")
local id = cb.id
f.scripts.OnEvent(f, "CHARACTER_POINTS_CHANGED")
local again = false
for _, x in ipairs(boxes()) do if x.id == id and x.checked then again = true end end
check(again, "spunta ancora visibile")
-- 4) ogni razza-classe: ogni scheda ha contenuto, ogni tappa con < >, ogni opzione cliccabile, senza errori
local keys = {}
for k in pairs(D) do if k:sub(1, 1) ~= "_" then keys[#keys + 1] = k end end
table.sort(keys)
local labels = {}
for _, t in ipairs(D._tabs) do labels[#labels + 1] = t end
labels[#labels + 1] = { "opzioni", lang == "it" and "Opzioni" or "Options" }
for _, k in ipairs(keys) do
  fp("set " .. k); f.shown = true
  for _, t in ipairs(labels) do
    local b = nav(t[2]); check(b ~= nil, "pulsante della scheda " .. t[2])
    b.scripts.OnClick(b)
    check(#shownTexts() >= 3, k .. ": scheda " .. t[1] .. " vuota")
  end
  -- opzioni: clic su ogni casella (build, dungeon, continente, icona) e ritorno
  for _, x in ipairs(boxes()) do x.checked = not x.checked; x.scripts.OnClick(x) end
  fp("lang " .. lang) -- le caselle della lingua hanno appena cambiato lingua: si torna a quella della prova
  nav(labels[1][2]).scripts.OnClick()
  local nx = nav(">")
  for _ = 1, 12 do nx.scripts.OnClick() end
  fp("dungeon")
end
ForeverPathfinderChar.opt = {}
-- 4b) ricerca e dungeon: lo Human Warrior trova i Deadmines nella guida, poi /fp dungeon (al 18) elenca le loro quest
fp("set human-warrior"); f.shown = false
fp("cerca deadmines")
check(f.shown and said("Deadmines") and has("Deadmines"), "/fp cerca apre il Percorso sulla tappa giusta e scrive i risultati")
local lv0 = LEVEL; LEVEL = 18; fp("dungeon"); LEVEL = lv0
check(said("Red Silk Bandanas") and said("The Defias Brotherhood"), "/fp dungeon elenca le quest dei Deadmines")
local n0 = #chat; fp("find zzzzzz"); check(#chat == n0 + 1, "ricerca senza risultati: un solo messaggio")
-- 4c) /fp debug: versioni, token di razza e guida riconosciuta
fp("auto"); n0 = #chat; fp("debug")
local dbg = table.concat(chat, "\n", n0 + 1)
check(#chat == n0 + 6 and dbg:find("Interface 16001", 1, true) and dbg:find("/ " .. RACE, 1, true) and dbg:find(EXPECT_KEY, 1, true), "/fp debug: 5 righe con Interface, razza, guida\n" .. dbg)
-- 4d) collegamenti col gioco (Human Warrior al livello 1)
fp("set human-warrior"); ForeverPathfinderChar.opt = {}
local hw = D["human-warrior"]
local hv = select(2, next(hw.v))
local L = ForeverPathfinderLinks[lang]
-- quest: una voce con quest nel registro mostra lo stato; alla consegna si spunta da sola
local qtask
for _, t in ipairs(hv._tasks or {}) do if L[t[4]] and L[t[4]].q[1] then qtask = t; break end end
if not qtask then fp(""); fp(""); hv = select(2, next(hw.v)); for _, t in ipairs(hv._tasks) do if L[t[4]] and L[t[4]].q[1] then qtask = t; break end end end
check(qtask ~= nil, "una voce con una quest")
local qname = L[qtask[4]].q[1]
QUESTLOG = { { qname, 777, true } }
f.scripts.OnEvent(f, "QUEST_LOG_UPDATE")
LEVEL = qtask[1]; f.shown = false; fp("")
check(has(lang == "it" and "da consegnare" or "ready to turn in"), "stato della quest nel registro: " .. qname)
for _, q in ipairs(L[qtask[4]].q) do QUESTLOG = { { q, 777, true } }; f.scripts.OnEvent(f, "QUEST_LOG_UPDATE"); f.scripts.OnEvent(f, "QUEST_TURNED_IN", 777) end
check(ForeverPathfinderChar.done["human-warrior:" .. qtask[4]] == true, "voce spuntata alla consegna di " .. qname)
-- segnaposto di una voce: segnaposto del gioco e messaggio con zona e coordinate
local pinB = find(function(o) return o.kind == "Button" and rawget(o, "p") and o.shown end)
check(pinB ~= nil, "pulsante del segnaposto nella voce")
pinB.scripts.OnClick(pinB)
check(WAYPOINT and WAYPOINT[1] == 1429 and said("Elwynn Forest"), "segnaposto del gioco impostato")
-- mappa del mondo aperta: segnaposti della tappa sulla tela
WorldMapFrame.scripts.OnShow()
check(find(function(o) return o.kind == "Button" and rawget(o, "p") and o.point and o.point[2] == canvas end) ~= nil, "segnaposti sulla mappa del mondo")
-- finestra dei talenti: bordo sul talento da prendere
TalentFrame, TalentFrameTalent1 = obj("Frame"), obj("Frame")
TALENT = hv._tal[1] and hv._tal[1][2]
f.scripts.OnEvent(f, "ADDON_LOADED", "Blizzard_TalentUI")
SPENT = 0; TalentFrame.scripts.OnShow()
local glowF = find(function(o) return o.kind == "Frame" and o.shown and o.point and o.point[2] == TalentFrameTalent1 end)
check(TALENT == nil or glowF ~= nil, "talento evidenziato nella finestra dei talenti")
-- trainer: gli spell della guida disponibili vengono scritti in chat
LEVEL = 1; TRAINER = { "Battle Shout", "Something Else" }
f.scripts.OnEvent(f, "TRAINER_SHOW")
check(said("Battle Shout") and not said("Something Else"), "trainer: spell da comprare")
LEVEL = 1
-- 5) razza sconosciuta: messaggio, poi /fp auto torna alla razza vera
fp("set nessuna-razza")
check(chat[#chat]:find("/fp set", 1, true) ~= nil, "messaggio per razza sconosciuta")
fp("auto")
-- 6) clic destro sull'icona: Opzioni; trascinamento: l'icona cambia posto; /fp chiude
mb.scripts.OnClick(mb, "RightButton")
check(has(lang == "it" and "Opzioni" or "Options"), "clic destro apre le opzioni")
mb.scripts.OnDragStart(mb); mb.scripts.OnUpdate(); mb.scripts.OnDragStop(mb)
check(ForeverPathfinderDB.angle and math.abs(ForeverPathfinderDB.angle - 90) < 1, "icona trascinata sopra la minimappa")
fp(""); check(not f.shown, "/fp chiude")
-- 7) lingua solo nelle Opzioni (niente pulsante in testata): la casella dell'altra lingua cambia i nomi delle schede; /fp lang torna indietro
fp("opzioni")
local other = lang == "it" and "English" or "Italiano"
check(find(function(o) return o.kind == "Button" and rawget(o, "fs") and o.fs.text == other and o.shown end) == nil, "nessun pulsante della lingua in testata")
check(has(other), "voce " .. other .. " nelle Opzioni")
fp("lang " .. (lang == "it" and "en" or "it"))
check(has(lang == "it" and "Route" or "Percorso") and ForeverPathfinderDB.lang == (lang == "it" and "en" or "it"), "lingua cambiata")
fp("lang"); check(ForeverPathfinderDB.lang == lang and has(lang == "it" and "Percorso" or "Route"), "/fp lang torna indietro")
print("ok", LOCALE, "addon " .. lang, RACE, CLASS, #keys .. " combinazioni x " .. #labels .. " schede")
