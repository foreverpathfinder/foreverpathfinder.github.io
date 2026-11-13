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
  GetMapInfo = function(id) return { mapID = id, name = "zona" .. id } end,
  CanSetUserWaypointOnMap = function() return true end, SetUserWaypoint = function(p) WAYPOINT = p end,
  GetBestMapForUnit = function() return 1429 end, GetPlayerMapPosition = function() return { GetXY = function() return 0.5, 0.5 end } end,
  GetMapWorldSize = function() return 30000, 30000 end,
}
-- profession finte (1.7): Blacksmithing 85/150 e Mining 75/75 (al massimo del grado); materiali nelle borse
PROFS = { { "Blacksmithing", 85, 150 }, { "Mining", 75, 75 } }
GetProfessions = function() return 1, 2 end
GetProfessionInfo = function(i) local p = PROFS[i]; if p then return p[1], "icon", p[2], p[3] end end
GetItemCount = function(id) return id == 2842 and 20 or 3 end
QUESTLOG = {}
-- registro delle quest come in Forever: solo l'API moderna C_QuestLog (niente GetQuestLogTitle)
C_QuestLog = { GetNumQuestLogEntries = function() return #QUESTLOG end,
  GetInfo = function(i) local q = QUESTLOG[i]; return q and { title = q[1], questID = q[2], isHeader = false } end,
  IsComplete = function(id) for _, q in ipairs(QUESTLOG) do if q[2] == id then return q[3] end end return false end }
-- spell nel libro: per nome il gioco trova solo quelle che conosci
KNOWN = {}
C_Spell = { GetSpellInfo = function(n) if KNOWN[n] then return { spellID = #n } end end }
IsPlayerSpell = function() return true end
-- LibDBIcon e LibDataBroker come li porta Questie
DBICON = {}
local LIBS = { ["LibDataBroker-1.1"] = { NewDataObject = function(_, _, o) return o end },
  ["LibDBIcon-1.0"] = { Register = function(_, n, o, db) DBICON[n] = { o = o, db = db } end, IsRegistered = function(_, n) return DBICON[n] ~= nil end,
    Show = function(_, n) DBICON[n].shown = true end, Hide = function(_, n) DBICON[n].shown = false end } }
LibStub = function(n) return LIBS[n] end
TALENT = nil
GetNumTalents = function() return 1 end
GetTalentInfo = function() return TALENT end
TRAINER = {}
GetNumTrainerServices = function() return #TRAINER end
GetTrainerServiceInfo = function(i) local s = TRAINER[i]; if s then return s, "", "available" end end

ShowUIPanel = function(fr) fr:Show() end
-- Questie finto: ID per nome, quest consegnate (QDONE), moduli interni che l'addon chiama (QCALLS registra le chiamate)
QDONE, QCALLS = {}, {}
function QID(name) local h = 0; for i = 1, #name do h = (h * 31 + name:byte(i)) % 100000 end; return h + 1 end
LibQuestieDB = { Quest = { IdsByName = function(n) return { QID(n) } end } }
local readyCbs = {}
Questie = { API = { isReady = false, RegisterOnReady = function(cb) if Questie.API.isReady then cb() else readyCbs[#readyCbs + 1] = cb end end }, db = { char = { complete = QDONE } } }
function QUESTIE_READY() Questie.API.isReady = true; for _, cb in ipairs(readyCbs) do cb() end; readyCbs = {} end
local QMOD = {
  -- catena finta di 3 passi: The Defias Brotherhood richiede la 777 (The Defias Traitor), che richiede la 776 (Messenger to Stormwind);
  -- tutte date da Gryan Stoutmantle in Westfall. GetQuest: chi la dà e a chi si consegna, per il punto sulla mappa
  QuestieDB = { IsDoable = function() return true end,
    GetQuest = function(id) return { Id = id, Starts = { NPC = { 4242 } }, Finisher = { NPC = { 4243 } } } end,
    QueryQuestSingle = function(id, k)
      if k == "startedBy" then return { { id == QID("Simple Letter") and 4244 or 4242 } } end
      if k == "preQuestSingle" and id == QID("The Defias Brotherhood") then return { 777 } end
      if k == "preQuestSingle" and id == 777 then return { 776 } end
      if k == "name" then return id == 777 and "The Defias Traitor" or id == 776 and "Messenger to Stormwind" or "Q" .. id end
    end,
    QueryNPCSingle = function(n, k) if k == "name" then return n == 4244 and "Marshal McBride" or "Gryan Stoutmantle" elseif k == "zoneID" then return 40 end return { [12] = { { 40, 60 } } } end,
    QueryObjectSingle = function() end },
  ZoneDB = { GetUiMapIdByAreaId = function() return 1429 end },
  -- il punto più vicino: chi dà la quest (41.8, 67.2) o, se è nel registro, l'obiettivo (30, 40)
  DistanceUtils = { GetNearestFinisherOrStarter = function(st) QCALLS[#QCALLS + 1] = "start" .. tostring(st.NPC and st.NPC[1]); return { 41.8, 67.2 }, 40, "Gryan Stoutmantle" end,
    GetNearestSpawnForQuest = function(q) QCALLS[#QCALLS + 1] = "obj" .. q.Id; return { 30, 40 }, 40, "Defias Pillager" end },
  QuestieMap = { ShowNPC = function(_, id) QCALLS[#QCALLS + 1] = "npc" .. id end, ShowObject = function() end },
  QuestieCompat = { OpenWorldMap = function(id) QCALLS[#QCALLS + 1] = "map" .. id; return true end },
  TrackerUtils = { ShowQuestOnMap = function(id) QCALLS[#QCALLS + 1] = "track" .. id; return true end, GetZoneNameByID = function() return "Westfall" end },
  QuestieJourney = { IsShown = function() return false end, ToggleJourneyWindow = function() QCALLS[#QCALLS + 1] = "journey" end,
    tabGroup = { SelectTab = function(_, t) QCALLS[#QCALLS + 1] = "tab " .. t end } },
  QuestieSearchResults = { SetSearch = function(_, t, id) QCALLS[#QCALLS + 1] = t .. id end },
}
QuestieLoader = { ImportModule = function(_, n) return QMOD[n] end }
-- OneForAll finto: codice della build, scheda Talent Trees col pulsante "Import build", dungeon
OFA = {}
OneForAll = { TalentCode = { ShowExport = function(t) OFA.export = t end, ShowImport = function() end,
    Encode = function(cls, ranks) local n = 0; for _, r in pairs(ranks) do n = n + r end; OFA.n = n; return "OFA1:" .. tostring(cls) .. ":" .. n end },
  OpenPanel = function(_, k) OFA.panel = k end, DUNGEONS = { { name = "Deadmines", key = "dm" } }, UI = { OpenDungeon = function(d) OFA.dungeon = d.name end } }
local impB = obj("Button"); impB.IsObjectType = function() return true end; impB.IsVisible = function() return true end
impB.GetRegions = function() local fs = obj("FontString"); fs.text = "Import build"; return fs end
impB.Click = function() OneForAll.TalentCode.ShowImport(function(code) OFA.imported = code end) end
OneForAllFrame = obj("Frame"); OneForAllFrame.GetChildren = function() return impB end
IsAddOnLoaded = function(n) return n == "Questie" or n == "OneForAll" or n == "MapUtils" end

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
local mb = DBICON.ForeverPathfinder
check(mb ~= nil and mb.shown, "icona sulla minimappa (LibDBIcon)")
check(ForeverPathfinder_OnCompartment ~= nil, "voce nel riquadro degli addon")
-- 1) clic sull'icona: si apre il Percorso sulla tappa del livello, con build e voci da spuntare
mb.o.OnClick(nil, "LeftButton")
check(f.shown, "il clic sull'icona apre la finestra")
check(has(g.name), "titolo con " .. g.name)
-- il numero di tappe cambia con la razza; dall'8 nov il percorso arriva al 60 (almeno 17 tappe)
local nStages = 0
for _, t in ipairs(shownTexts()) do local n = tonumber(t:match("^/ (%d+)$")); if n then nStages = n end end
check(has(lang == "it" and "TAPPA" or "STAGE") and nStages >= 17, "tappa 1 di N fino al 60 (trovate " .. nStages .. ")")
check(#boxes() > 0, "voci da spuntare")
-- 2) un punto talento libero: la riga gialla dice quale prendere
FREE = 1; f.scripts.OnEvent(f, "CHARACTER_POINTS_CHANGED")
local v = select(2, next(g.v))
local firstTal = ForeverPathfinderPool[lang][v.tal]:match("^([^:]+)")
if firstTal then check(has(firstTal), "talento " .. firstTal) end
-- 2b) talenti come in Forever (sistema moderno C_ClassTalents / C_Traits): un punto speso → il Percorso propone il secondo talento
local tals = {}; for n in ForeverPathfinderPool[lang][v.tal]:gmatch("([^:;]+):[^;]*") do tals[#tals + 1] = n end
if tals[2] then
  local oldFree = FREE; FREE = 0
  C_ClassTalents = { GetActiveConfigID = function() return 7 end }
  C_Traits = { GetConfigInfo = function() return { treeIDs = { 1 } } end, GetTreeNodes = function() return { 11, 12 } end,
    GetNodeInfo = function(_, n) return { ranksPurchased = n == 11 and 1 or 0 } end, GetTreeCurrencyInfo = function() return { { quantity = 0 } } end }
  f.scripts.OnEvent(f, "TRAIT_CONFIG_UPDATED")
  check(has(tals[2]) and has(lang == "it" and "Prossimo talento al liv. 11" or "Next talent at lvl 11"), "talenti moderni: dopo un punto speso il talento successivo (" .. tals[2] .. ")")
  -- e la voce "Talent:" del livello 10 (primo punto della guida) si spunta da sola
  local tv, tt
  for _, x in pairs(g.v) do if x._tasks then tv = x end end
  for _, t in ipairs(tv and tv._tasks or {}) do if t[1] == 10 and t[3]:gsub("^%^[^%^]*%^", ""):find("^Talent:") then tt = t end end
  check(tt == nil or ForeverPathfinderChar.done[EXPECT_KEY .. ":" .. tt[5]] == true, "voce Talent del livello 10 spuntata dopo il primo punto")
  if tt then ForeverPathfinderChar.done[EXPECT_KEY .. ":" .. tt[5]] = nil end
  C_ClassTalents, C_Traits, FREE = nil, nil, oldFree; f.scripts.OnEvent(f, "CHARACTER_POINTS_CHANGED")
end
-- 2c) Flight Path: aprendo la mappa dei voli, le voci "Flight Path: X" dei voli conosciuti si spuntano da sole
do
  local fv, ft
  for _, x in pairs(g.v) do if x._tasks then fv = x end end
  for _, t in ipairs(fv and fv._tasks or {}) do if not ft and t[3]:find("Flight Path:", 1, true) then ft = t end end
  if ft then
    local name = ft[3]:match("Flight Path:%s*([^,(<]+)"):gsub("%s+$", "")
    local nodes = { { name .. ", Somewhere", "REACHABLE" }, { "Elsewhere, Nowhere", "NONE" } }
    NumTaxiNodes = function() return #nodes end
    TaxiNodeName = function(i) return nodes[i][1] end
    TaxiNodeGetType = function(i) return nodes[i][2] end
    local key = EXPECT_KEY .. ":" .. ft[5]
    ForeverPathfinderChar.done[key] = nil
    f.scripts.OnEvent(f, "TAXIMAP_OPENED")
    check(ForeverPathfinderChar.done[key] == true, "Flight Path " .. name .. " spuntato aprendo la mappa dei voli")
    check(ForeverPathfinderChar.fp["Elsewhere, Nowhere"] == nil, "Flight Path non conosciuto non salvato")
    ForeverPathfinderChar.done[key] = nil; ForeverPathfinderChar.fp = {}
    NumTaxiNodes, TaxiNodeName, TaxiNodeGetType = nil, nil, nil
    FPTESTED = (FPTESTED or 0) + 1
  end
end
-- 3) spunta: resta salvata e si rivede dopo un nuovo disegno
local cb = boxes()[1]
cb.checked = true; cb.scripts.OnClick(cb)
check(ForeverPathfinderChar.done[cb.id] == true, "spunta salvata")
local id = cb.id
f.scripts.OnEvent(f, "CHARACTER_POINTS_CHANGED")
local again = false
for _, x in ipairs(boxes()) do if x.id == id and x.checked then again = true end end
check(again, "spunta ancora visibile")
-- 3b) rimaste indietro: al livello 12 le voci non spuntate delle tappe prima stanno in cima; spuntandone una sparisce
local function behind() for _, t in ipairs(shownTexts()) do local n = t:match("^Rimaste indietro %((%d+)%)") or t:match("^Left behind %((%d+)%)"); if n then return tonumber(n) end end end
LEVEL = 12; f.scripts.OnEvent(f, "PLAYER_LEVEL_UP")
local nb = behind()
check(nb and nb > 0, "card Rimaste indietro al livello 12")
local bcb = find(function(o) return o.kind == "CheckButton" and o.shown and rawget(o, "onClick") end)
check(bcb ~= nil, "casella di una voce rimasta indietro")
local bid = bcb.id -- la casella si riusa al nuovo disegno
bcb.checked = true; bcb.scripts.OnClick(bcb)
check(ForeverPathfinderChar.done[bid] == true and (behind() or 0) == nb - 1, "spuntata: la voce sparisce dalla card (" .. tostring(behind()) .. ")")
ForeverPathfinderChar.done[bid] = nil; LEVEL = 1; f.scripts.OnEvent(f, "PLAYER_LEVEL_UP")
check(behind() == nil, "al livello 1 nessuna voce rimasta indietro")
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
check(#chat == n0 + 8 and dbg:find("OneForAll", 1, true) and dbg:find("Interface 16001", 1, true) and dbg:find("/ " .. RACE, 1, true) and dbg:find(EXPECT_KEY, 1, true), "/fp debug: 5 righe con Interface, razza, guida\n" .. dbg)
-- 4d) collegamenti col gioco (Human Warrior al livello 1)
fp("set human-warrior"); ForeverPathfinderChar.opt = {}
local hw = D["human-warrior"]
local hv = select(2, next(hw.v))
local L = ForeverPathfinderLinks[lang]
-- stessa frase, segnaposti della propria razza: lo Gnome Mage va dal trainer di Anvilmar (Marryk Nurribit), non da quello di Northshire
local gv, PL, PG, gok = select(2, next(D["gnome-mage"].v)), ForeverPathfinderPool[lang], ForeverPathfinderPages[lang], false
for lv, _, n in PG[gv.tasks]:gmatch("(%d+),(%d+),(%d+),%w+") do local l = L[tonumber(n)]; if lv == "1" and PL[tonumber(n)]:find("Trainer:", 1, true) and l and l.p[1] and math.abs(l.p[1][2] - 0.3592) < 0.002 then gok = true end end
check(gok, "Gnome Mage: trainer del livello 1 ad Anvilmar")
-- quest: una voce con quest nel registro mostra lo stato; alla consegna si spunta da sola
local qtask
for _, t in ipairs(hv._tasks or {}) do if L[t[4]] and L[t[4]].q[1] and not L[t[4]].any then qtask = t; break end end
if not qtask then fp(""); fp(""); hv = select(2, next(hw.v)); for _, t in ipairs(hv._tasks) do if L[t[4]] and L[t[4]].q[1] and not L[t[4]].any then qtask = t; break end end end
check(qtask ~= nil, "una voce con una quest")
local qname = L[qtask[4]].q[1]
QUESTLOG = { { qname, 777, true } }
f.scripts.OnEvent(f, "QUEST_LOG_UPDATE")
LEVEL = qtask[1]; f.shown = false; fp("")
check(has(lang == "it" and "da consegnare" or "ready to turn in"), "stato della quest nel registro: " .. qname)
for _, q in ipairs(L[qtask[4]].q) do QUESTLOG = { { q, 777, true } }; f.scripts.OnEvent(f, "QUEST_LOG_UPDATE"); f.scripts.OnEvent(f, "QUEST_TURNED_IN", 777) end
check(ForeverPathfinderChar.done["human-warrior:" .. qtask[5]] == true, "voce spuntata alla consegna di " .. qname)
-- Questie pronto: le voci con quest già consegnate (storico di Questie) si spuntano da sole, con una riga sola in chat
local qtask2
for _, t in ipairs(hv._tasks) do if t ~= qtask and L[t[4]] and L[t[4]].q[1] and not L[t[4]].any and not ForeverPathfinderChar.done["human-warrior:" .. t[5]] then qtask2 = t; break end end
check(qtask2 ~= nil, "un'altra voce con quest")
for _, q in ipairs(L[qtask2[4]].q) do QDONE[QID(q)] = true end
QUESTIE_READY()
check(ForeverPathfinderChar.done["human-warrior:" .. qtask2[5]] == true and said(lang == "it" and "Spuntate" or "Ticked"), "voce spuntata dallo storico di Questie")
-- voci Trainer: si spuntano da sole quando conosci già tutte le loro spell (SPELLS_CHANGED)
local ttask
for _, t in ipairs(hv._tasks) do if t[3]:find("Trainer:", 1, true) and not ForeverPathfinderChar.done["human-warrior:" .. t[5]] then ttask = t; break end end
check(ttask ~= nil, "una voce Trainer")
local spells = {}
for n in ttask[3]:gsub("^%^[^%^]*%^", ""):match("^Trainer:%s*(.+)$"):gsub("%b()", ""):gmatch("[^,;]+") do spells[#spells + 1] = (n:gsub("^%s+", ""):gsub("%s+$", "")) end
for i = 1, #spells - 1 do KNOWN[spells[i]] = true end
f.scripts.OnEvent(f, "SPELLS_CHANGED")
check(not ForeverPathfinderChar.done["human-warrior:" .. ttask[5]], "voce Trainer non spuntata con una spell mancante: " .. spells[#spells])
if #spells > 1 then LEVEL = ttask[1]; f.shown = false; fp(""); check(has("|cff5fd68b" .. spells[1] .. "|r"), "spell già appresa in verde nella voce Trainer: " .. spells[1]) end
KNOWN[spells[#spells]] = true
f.scripts.OnEvent(f, "SPELLS_CHANGED")
check(ForeverPathfinderChar.done["human-warrior:" .. ttask[5]] == true, "voce Trainer spuntata con le spell già apprese: " .. table.concat(spells, ", "))
-- lettera di classe: solo quella della propria classe e razza (Human Warrior: Simple Letter), che la spunta
local ltask
for _, t in ipairs(hv._tasks) do if t[3]:find(lang == "it" and "Lettera di classe" or "Class letter", 1, true) then ltask = t; break end end
check(ltask ~= nil and L[ltask[4]] and #L[ltask[4]].q == 1 and L[ltask[4]].q[1] == "Simple Letter", "lettera di classe dello Human Warrior: Simple Letter")
-- (la prova dello storico di Questie può averla già spuntata con tutte le lettere: si riparte da zero)
for _, q in ipairs(L[ltask[4]].q) do QDONE[QID(q)] = nil; ForeverPathfinderChar.turned[q] = nil end
ForeverPathfinderChar.done["human-warrior:" .. ltask[5]] = nil; f.scripts.OnEvent(f, "SPELLS_CHANGED")
check(not ForeverPathfinderChar.done["human-warrior:" .. ltask[5]], "lettera di classe non consegnata: voce da spuntare")
QDONE[QID("Simple Letter")] = true; f.scripts.OnEvent(f, "SPELLS_CHANGED")
check(ForeverPathfinderChar.done["human-warrior:" .. ltask[5]] == true, "lettera di classe consegnata: voce spuntata")
-- segnaposto di una voce: sulla zona del gioco (uiMapID da ForeverPathfinderZoneMaps), non dai bordi del continente di Wowhead
LEVEL = 1; f.shown = false; fp("")
local pinB = find(function(o) return o.kind == "Button" and rawget(o, "fn") and o.shown and o.tip2 == (lang == "it" and "Mostra sulla mappa e sulla minimappa" or "Show on the map and the minimap") end)
check(pinB ~= nil, "pulsante del segnaposto di una voce")
WAYPOINT = nil; WorldMapFrame.shown = false; pinB.scripts.OnClick(pinB)
check(WorldMapFrame.shown and not f.shown, "il pulsante del segnaposto apre la mappa del mondo (e chiude la guida)")
local zid = WAYPOINT and WAYPOINT[1]
local inZM = false
for _, a in pairs(ForeverPathfinderZoneMaps) do for _, z in ipairs(a) do if z[1] == zid then inZM = true end end end
check(inZM and WAYPOINT[2] >= 0 and WAYPOINT[2] <= 1 and WAYPOINT[3] >= 0 and WAYPOINT[3] <= 1 and said("zona" .. zid), "segnaposto sulla zona del gioco (uiMap " .. tostring(zid) .. ")")
-- pulsanti della voce con quest: mappa con le icone di Questie (chi la dà: NPC 4242 nella sua zona) e scheda nel Journey
LEVEL = qtask[1]; QUESTLOG = {}; f.scripts.OnEvent(f, "QUEST_LOG_UPDATE"); f.shown = false; fp("")
local function mini(name, tip2) return find(function(o) return o.kind == "Button" and rawget(o, "fn") and o.shown and o.tip == name and (not tip2 or o.tip2:find(tip2, 1, true)) end) end
local HOT = lang == "it" and "segnaposto evidenziato" or "highlighted waypoint"
local qMapB, qInfoB = mini(qname, HOT), mini(qname, "Journey")
check(qMapB and qInfoB, "pulsanti mappa e scheda di Questie nella voce di " .. qname)
-- 1.8: il pulsante mappa mette il nostro segnaposto sul punto esatto (chi dà la quest), con riga in chat e mappa sulla sua zona
QCALLS = {}; WAYPOINT = nil; WorldMapFrame.shown = false; qMapB.scripts.OnClick(qMapB)
check(QCALLS[1] == "start4242" and WAYPOINT and WAYPOINT[1] == 1429 and math.abs(WAYPOINT[2] - 0.418) < 0.001 and math.abs(WAYPOINT[3] - 0.672) < 0.001,
  "mappa: segnaposto su chi dà la quest (" .. table.concat(QCALLS, ",") .. ")")
check(WorldMapFrame.shown and not f.shown and said(qname .. ": Gryan Stoutmantle"), "mappa aperta e riga in chat con quest e NPC")
local function hotPin() return find(function(o) return o.kind == "Button" and rawget(o, "p") and rawget(o, "hot") and o.shown end) end
check(hotPin() and hotPin().p.sub == qname, "segnaposto scelto evidenziato sulla mappa del mondo")
-- arrivo: a meno di 10 yard dal punto il segnaposto scelto si toglie da solo
local oldPos = C_Map.GetPlayerMapPosition
C_Map.GetPlayerMapPosition = function() return { GetXY = function() return 0.418, 0.672 end } end
for _, o in ipairs(frames) do if o.kind == "Frame" and o ~= WorldMapFrame and o.scripts.OnUpdate then pcall(o.scripts.OnUpdate, o, 1) end end
C_Map.GetPlayerMapPosition = oldPos
check(not hotPin() and said(lang == "it" and "Sei arrivato" or "You have arrived"), "all'arrivo il segnaposto si toglie")
qMapB.scripts.OnClick(qMapB); check(hotPin() ~= nil, "segnaposto rimesso")
hotPin().scripts.OnClick(hotPin())
check(not hotPin(), "un clic sul segnaposto evidenziato lo toglie")
QUESTLOG = { { qname, QID(qname), false } }; f.scripts.OnEvent(f, "QUEST_LOG_UPDATE"); QCALLS = {}; f.shown = false; fp("")
qMapB = mini(qname, HOT); qMapB.scripts.OnClick(qMapB)
check(QCALLS[1] == "obj" .. QID(qname) and math.abs(WAYPOINT[2] - 0.30) < 0.001 and said("Defias Pillager"), "mappa: quest nel registro → obiettivo più vicino")
f.shown = false; fp(""); qInfoB = mini(qname, "Journey")
QCALLS = {}; qInfoB.scripts.OnClick(qInfoB)
check(table.concat(QCALLS, ",") == "journey,tab search,quest" .. QID(qname), "scheda della quest nel Journey (" .. table.concat(QCALLS, ",") .. ")")
QUESTLOG = {}; f.scripts.OnEvent(f, "QUEST_LOG_UPDATE")
-- Talent: "Apri in OneForAll" carica tutta la build (un punto per livello dal 10) con il suo Import
local tabName = function(key) for _, t in ipairs(D._tabs) do if t[1] == key then return t[2] end end end
nav(tabName("talent")).scripts.OnClick()
local ofaB = nav((lang == "it" and "Apri in OneForAll" or "Open in OneForAll") .. " ↗")
check(ofaB ~= nil, "pulsante Apri in OneForAll")
ofaB.scripts.OnClick(ofaB)
check(OFA.panel == "talents" and OFA.imported and OFA.n == #hv._tal and not OFA.export, "build importata in OneForAll (" .. tostring(OFA.n) .. "/" .. #hv._tal .. ")")
-- Talent (dalla 1.6): livello mostrato, › passa al dopo, nodi dell'albero con rank e tooltip
local function lvShown() for _, t in ipairs(shownTexts()) do local n = t:match("^" .. (lang == "it" and "Livello" or "Level") .. " (%d+)$"); if n then return tonumber(n) end end end
local l0 = lvShown()
check(l0 ~= nil, "livello nella scheda Talent")
local nx = nav("›"); nx.scripts.OnClick(nx)
check(lvShown() == l0 + 1, "› mostra il livello dopo (" .. tostring(l0) .. " → " .. tostring(lvShown()) .. ")")
check(find(function(o) return o.kind == "Button" and rawget(o, "rk") and o.shown and o.t2 and o.t2 ~= "" end) ~= nil, "nodi dell'albero con descrizione")
-- Classe (dalla 1.6): le quattro sezioni, ognuna con contenuto
nav(tabName("classe")).scripts.OnClick()
for _, s in ipairs(lang == "it" and { "Rotazione", "Spell", "Razza", "Consigli" } or { "Rotation", "Spells", "Race", "Tips" }) do
  local b = nav(s); check(b ~= nil, "sezione " .. s .. " della scheda Classe")
  b.scripts.OnClick(b); check(#shownTexts() >= 6, "sezione " .. s .. " con contenuto")
end
-- Dungeon (dalla 1.5): menu con i dungeon; un clic apre la scheda del dungeon. "Mappa" apre la mappa del mondo sull'ingresso
-- con il segnaposto; "Boss e loot" apre il dungeon in OneForAll; le quest con la prima della catena (Questie)
nav(tabName("dungeon")).scripts.OnClick()
QDONE[776] = true
check(has(lang == "it" and "Adatti al tuo livello adesso" or "Right for your level now"), "menu: riquadro dei dungeon adatti al livello")
local dmMenu = nav("The Deadmines")
check(dmMenu and nav("Hall of Thanes ★") and not nav(lang == "it" and "Mappa" or "Map"), "menu dei dungeon (senza pulsanti Mappa)")
dmMenu.scripts.OnClick(dmMenu)
check(nav(lang == "it" and "‹ Tutti i dungeon" or "‹ All dungeons") and has(lang == "it" and "da prendere" or "to pick up"), "scheda dei Deadmines: testata con le quest, ritorno al menu")
if g.faction == "A" then
  -- 1.8.1: quest a gruppi; The Defias Brotherhood da sbloccare (776 fatta, 777 adesso, poi la quest del dungeon): riquadro Adesso
  -- con da chi andare, e l'elenco completo dei passi solo con "Tutti i passi"
  check(has("Red Silk Bandanas") and has(lang == "it" and "Da sbloccare" or "To unlock") and has(lang == "it" and "passo 2 di 3" or "step 2 of 3")
    and has("Gryan Stoutmantle") and not has("Messenger to Stormwind"), "quest dei Deadmines: gruppi e riga Adesso della catena")
  local stepsB = nav(lang == "it" and "Tutti i passi" or "All steps")
  check(stepsB ~= nil, "pulsante Tutti i passi")
  stepsB.scripts.OnClick(stepsB)
  check(has("Messenger to Stormwind") and has("The Defias Traitor") and has("Gryan Stoutmantle, Westfall"), "elenco completo dei passi")
end
local function sec(prefix) return find(function(o) return o.kind == "Button" and rawget(o, "fs") and o.shown and o.scripts.OnClick and o.fs.text:sub(1, #prefix) == prefix end) end
local bossB, whereB = sec((lang == "it" and "Boss" or "Bosses") .. "  "), sec(lang == "it" and "Come arrivarci" or "How to get there")
check(bossB and whereB, "sezioni Boss e Come arrivarci")
bossB.scripts.OnClick(bossB); check(has("Rhahk'zor"), "sezione Boss")
whereB.scripts.OnClick(whereB); check(has(lang == "it" and "Dove si trova" or "Where it is"), "sezione Come arrivarci")
local dmB, lootB = nav(lang == "it" and "Mappa" or "Map"), nav(lang == "it" and "Boss e loot" or "Bosses and loot")
check(dmB and lootB, "pulsanti Mappa e Boss e loot nella scheda Dungeon")
WorldMapFrame.shown = false; dmB.scripts.OnClick(dmB)
check(WorldMapFrame.shown and said("zona") and said("MapUtils"), "mappa sull'ingresso, segnaposto e indicazione per MapUtils")
lootB.scripts.OnClick(lootB)
check(OFA.panel == "dungeons" and OFA.dungeon == "Deadmines", "dungeon aperto in OneForAll")
-- mappa del mondo aperta: segnaposti della tappa (e l'ingresso scelto) sulla tela
WorldMapFrame.scripts.OnShow()
check(find(function(o) return o.kind == "Button" and rawget(o, "p") and o.point and o.point[2] == canvas end) ~= nil, "segnaposti sulla mappa del mondo")
-- 1.8.1: sotto l'NPC le quest che dà o ritira (da Questie), non quelle degli altri NPC della voce
do
  local function stPin(n) return find(function(o) return o.kind == "Button" and rawget(o, "p") and o.shown and o.p[4] == n end) end
  check(stPin("Marshal McBride") and stPin("Marshal McBride").p.sub == "Simple Letter" and stPin("Sam Sarsaparilla") and stPin("Sam Sarsaparilla").p.sub == nil,
    "segnaposto: nome della quest sotto l'NPC che la dà")
  local mc = stPin("Marshal McBride"); mc.scripts.OnClick(mc)
  check(said("Simple Letter: Marshal McBride"), "riga in chat con quest e NPC del segnaposto")
  WorldMapFrame.scripts.OnShow(); hotPin().scripts.OnClick(hotPin())
end
-- dalla 1.6 anche tutti i trainer della classe (con il nome dell'NPC nel tooltip)
check(find(function(o) return o.kind == "Button" and rawget(o, "p") and o.p.who and o.shown end) ~= nil, "trainer della classe sulla mappa del mondo")
-- icone di OneForAll sulla tela: quella sopra un nostro segnaposto si nasconde, quella lontana resta
local ofaNear, ofaFar = obj("Button"), obj("Button")
ofaNear.entry, ofaFar.entry = {}, {}
ofaFar.GetCenter = function() return 900, 900 end
canvas.GetChildren = function() return ofaNear, ofaFar end
WorldMapFrame.scripts.OnShow()
check(not ofaNear.shown and ofaFar.shown, "icona di OneForAll sopra il nostro segnaposto nascosta, quella lontana no")
canvas.GetChildren = nil
-- 1.7: Profession del gioco con la skill, passo attuale, materiali nelle borse, avviso al massimo del grado (una volta), trainer e
-- reagent vendor (da Questie) sulla mappa quando accesi
f.shown = true
nav(tabName("prof")).scripts.OnClick()
check(has("Silver Skeleton Key") and has(lang == "it" and "sei qui" or "you are here"), "Profession: passo della skill 85 di Blacksmithing")
check(has("Silver Bar |cff5fd68b(20)"), "Profession: Silver Bar nelle borse (20 di 17)")
local nc = #chat
f.scripts.OnEvent(f, "SKILL_LINES_CHANGED")
check(said("Mining 75/75") and said("Journeyman") and not said("Blacksmithing 85"), "avviso al massimo del grado")
f.scripts.OnEvent(f, "SKILL_LINES_CHANGED")
check(#chat == nc + 1, "avviso una volta sola")
nav("Mining  75").scripts.OnClick()
check(has("Copper Vein") and has(lang == "it" and "Oppure fondendo (fino a 185)" or "Or by smelting (up to 185)"), "Profession: percorso di Mining con la fusione")
LibQuestieDB.Item = { vendors = function(id) return id == 2880 and { 1 } or nil end }
LibQuestieDB.Npc = { friendlyToFaction = function() return "AH" end, name = function() return "Tharynn Bouden" end, spawns = function() return { [12] = { { 41.8, 67.2 } } } end }
QMOD.ZoneDB.GetUiMapIdByAreaId = function() return 1429 end
ForeverPathfinderChar.opt.ptr, ForeverPathfinderChar.opt.pvd = true, true
WorldMapFrame.shown = true; WorldMapFrame.scripts.OnShow()
check(find(function(o) return o.kind == "Button" and rawget(o, "p") and o.p[4] == "Mining Trainer" and o.shown end) ~= nil, "trainer delle profession sulla mappa")
check(find(function(o) return o.kind == "Button" and rawget(o, "p") and o.p.who and o.p.who:find("Tharynn Bouden (Weak Flux", 1, true) and o.shown end) ~= nil, "reagent vendor da Questie sulla mappa")
ForeverPathfinderChar.opt.ptr, ForeverPathfinderChar.opt.pvd = nil, nil
-- finestra dei talenti: bordo sul talento da prendere
TalentFrame, TalentFrameTalent1 = obj("Frame"), obj("Frame")
TALENT = hv._tal[1] and hv._tal[1][2]
f.scripts.OnEvent(f, "ADDON_LOADED", "Blizzard_TalentUI")
SPENT = 0; TalentFrame.scripts.OnShow()
local glowF = find(function(o) return o.kind == "Frame" and o.shown and o.point and o.point[2] == TalentFrameTalent1 end)
check(TALENT == nil or glowF ~= nil, "talento evidenziato nella finestra dei talenti")
-- 1.8: finestra dei talenti moderna (C_Traits, come in Forever): bordo sul pulsante del nodo con il talento da prendere
if TALENT then
  local tb = obj("Button")
  tb.GetEntryID = function() return 5 end
  PlayerSpellsFrame = obj("Frame"); PlayerSpellsFrame.shown = true
  PlayerSpellsFrame.TalentsFrame = { EnumerateAllTalentButtons = function() local done; return function() if not done then done = true; return tb end end end }
  C_ClassTalents = { GetActiveConfigID = function() return 1 end }
  C_Traits = { GetConfigInfo = function() return { treeIDs = {} } end, GetNodeInfo = function() end, GetEntryInfo = function() return { definitionID = 9 } end,
    GetDefinitionInfo = function() return { overrideName = TALENT } end }
  f.scripts.OnEvent(f, "TRAIT_CONFIG_UPDATED")
  check(find(function(o) return o.kind == "Frame" and o.shown and o.point and o.point[2] == tb end) ~= nil, "talento evidenziato nella finestra dei talenti moderna")
  C_ClassTalents, C_Traits, PlayerSpellsFrame = nil, nil, nil
end
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
mb.o.OnClick(nil, "RightButton")
check(has(lang == "it" and "Opzioni" or "Options"), "clic destro apre le opzioni")
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
