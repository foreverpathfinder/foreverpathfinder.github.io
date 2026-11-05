-- Forever Pathfinder: la guida del sito dentro il gioco, con il suo aspetto. Icona sulla minimappa → finestra con le schede del sito (Percorso con la
-- checklist da spuntare, Talent, Classe, Profession, Dungeon, Alt, Altro, Info) e le Opzioni (build, dungeon, cambio continente).
-- Dati in Data.lua (generati da src/tools/addon.js dal sito). /fp apre e chiude, /fp dungeon, /fp cerca e /fp debug scrivono in chat.
local ADDON = ...
-- lingua dell'addon: la sceglie il giocatore (Opzioni o /fp lang, salvata in ForeverPathfinderDB), inglese di base;
-- il gioco non ha l'italiano. Anche in italiano i nomi di gioco (quest, NPC, spell, oggetti) restano in inglese, come sul sito
local LANG, D, POOL, PAGES, DG, LINKS = "en"
local function bindData()
  D = ForeverPathfinderData[LANG] or ForeverPathfinderData.en
  POOL = ForeverPathfinderPool[LANG] or ForeverPathfinderPool.en
  PAGES = ForeverPathfinderPages[LANG] or ForeverPathfinderPages.en
  DG = ForeverPathfinderDungeons and (ForeverPathfinderDungeons[LANG] or ForeverPathfinderDungeons.en) or {}
  LINKS = ForeverPathfinderLinks and (ForeverPathfinderLinks[LANG] or ForeverPathfinderLinks.en) or {} -- per voce: p segnaposti, q quest
end
bindData()

local TT = {
  it = {
    level = "Liv. %d", stageWord = "TAPPA", build = "Build: %s",
    talentNow = "Talento da prendere ora: %s (%s)", talentNext = "Prossimo talento al liv. %d: %s (%s)", talentDone = "Talenti della guida completati.",
    unknown = "Razza o classe non riconosciute. Scrivi /fp set razza-classe (es. /fp set human-warrior); /fp list per l'elenco.",
    help = "/fp apre o chiude · /fp opzioni · /fp dungeon · /fp cerca parola · /fp set razza-classe · /fp auto · /fp list · /fp lang · /fp debug",
    dungeon = "Dungeon: %s · /fp dungeon per le quest", go = "vai", opt = "facoltativo",
    dgNone = "Nessun dungeon consigliato al liv. %d.", dgEntry = "Ingresso: %s", dgQuests = "Prima di entrare prendi:", dgClass = "(di classe)",
    found = "Trovate %d voci per \"%s\":", notFound = "Nessuna voce della guida contiene \"%s\".", lv = "Liv.",
    loaded = "caricato: clic sull'icona della minimappa o /fp per aprire la guida.",
    dbgGuide = "Guida: %s (%s)", dbgAuto = "automatica", dbgHand = "scelta a mano",
    dbgTal = "Talenti: spesi %s, liberi %d", dbgSave = "Salvataggi: caricamenti %d, spunte %d",
    options = "Opzioni", now = "sei qui", mbHint = "Clic: apri o chiudi la guida\nClic destro: opzioni\nTrascina: sposta l'icona",
    oBuild = "Build", oRoute = "Percorso", oDg = "Dungeon nel percorso (con le loro quest)", oX = "Cambia continente dopo la zona iniziale",
    oNoX = "Per questa razza il percorso resta nello stesso continente.", oShow = "Interfaccia", oMinimap = "Icona sulla minimappa",
    oChar = "Personaggio", oAuto = "Riconosciuto dal gioco: %s. Se sbaglia, scrivi /fp set razza-classe; /fp auto per tornare automatico.",
    oSite = "La guida completa, con mappa e calcolatori: foreverpathfinder.github.io",
    oLinks = "Collegamenti col gioco", oMap = "Segnaposti della tappa sulla mappa del mondo; dal segnaposto di una voce, anche sulla minimappa",
    oQuests = "Spunta da sola le voci quando consegni la quest e mostra le quest che hai nel registro",
    oTal = "Evidenzia il talento da prendere nella finestra dei talenti", oTrainer = "Al trainer scrive e segna gli spell della guida da comprare",
    oEnglish = "Quest, talenti e spell si riconoscono per nome inglese: funzionano con il gioco in inglese.",
    inLog = "nel registro", toTurn = "da consegnare", pinSet = "Segnaposto: %s · %s %.1f, %.1f", pinHere = "Sei arrivato: %s",
    pinTip = "Mostra sulla mappa e sulla minimappa", trainerBuy = "Da comprare secondo la guida: %s", ticked = "Spuntata nella guida: %s",
    dbgLinks = "Continenti %s · segnaposto del gioco %s · finestra talenti %s · quest nel registro %d", yes = "sì", no = "no",
    qMap = "Mostra la quest sulla mappa", qMapTip = "Con le icone di Questie: chi la dà o, se è nel registro, obiettivi e consegna",
    qInfo = "Scheda della quest", qInfoTip = "Apre la quest nel Journey di Questie", qWait = "Questie si sta ancora caricando: riprova tra un momento.",
    qOff = "Questie non è attivo: spunte automatiche, mappa e schede delle quest passano da Questie.", qSync = "Spuntate %d voci già fatte (quest consegnate, spell già apprese o talenti spesi).",
    ofa = "Apri in OneForAll", ofaTip = "Carica questa build (fino al 60) nel calcolatore dei talenti di OneForAll",
    ofaFail = "OneForAll non ha caricato la build da solo: copiala con Ctrl+C e incollala in Import.",
    dgMap = "Mappa", dgMapTip = "Apre la mappa del mondo sull'ingresso, con il segnaposto", dgMapMU = "Clic sull'icona d'ingresso di MapUtils: si apre la mappa interna del dungeon",
    dgLoot = "Boss e loot", dgLootTip = "Apre il dungeon in OneForAll (boss, loot, quest)",
    dbgSpell = "Spell nel libro: %d · voce Trainer %s, mancano: %s",
    dbgAddons = "Addon collegati: Questie %s · OneForAll %s · MapUtils %s",
    behind = "Rimaste indietro (%d)", behindMore = "e altre %d: le trovi tornando indietro con <",
  },
  en = {
    level = "Lvl %d", stageWord = "STAGE", build = "Build: %s",
    talentNow = "Talent to take now: %s (%s)", talentNext = "Next talent at lvl %d: %s (%s)", talentDone = "Guide talents done.",
    unknown = "Race or class not recognized. Type /fp set race-class (e.g. /fp set human-warrior); /fp list for the list.",
    help = "/fp opens or closes · /fp options · /fp dungeon · /fp find word · /fp set race-class · /fp auto · /fp list · /fp lang · /fp debug",
    dungeon = "Dungeon: %s · /fp dungeon for the quests", go = "go", opt = "optional",
    dgNone = "No recommended dungeon at lvl %d.", dgEntry = "Entrance: %s", dgQuests = "Before going in, pick up:", dgClass = "(class)",
    found = "Found %d items for \"%s\":", notFound = "No guide item contains \"%s\".", lv = "Lvl",
    loaded = "loaded: click the minimap icon or type /fp to open the guide.",
    dbgGuide = "Guide: %s (%s)", dbgAuto = "automatic", dbgHand = "picked by hand",
    dbgTal = "Talents: spent %s, free %d", dbgSave = "Saved data: loads %d, checks %d",
    options = "Options", now = "you are here", mbHint = "Click: open or close the guide\nRight click: options\nDrag: move the icon",
    oBuild = "Build", oRoute = "Route", oDg = "Dungeons in the route (with their quests)", oX = "Switch continent after the starting zone",
    oNoX = "For this race the route stays on the same continent.", oShow = "Interface", oMinimap = "Minimap icon",
    oChar = "Character", oAuto = "Detected by the game: %s. If it is wrong, type /fp set race-class; /fp auto to go back to automatic.",
    oSite = "The full guide, with map and calculators: foreverpathfinder.github.io",
    oLinks = "Game links", oMap = "Stage waypoints on the world map; from an item's waypoint, on the minimap too",
    oQuests = "Ticks items by itself when you turn in the quest and shows the quests in your log",
    oTal = "Highlights the talent to take in the talent window", oTrainer = "At the trainer, prints and marks the guide spells to buy",
    oEnglish = "Quests, talents and spells are recognized by their English name: they work with the game in English.",
    inLog = "in your log", toTurn = "ready to turn in", pinSet = "Waypoint: %s · %s %.1f, %.1f", pinHere = "You have arrived: %s",
    pinTip = "Show on the map and the minimap", trainerBuy = "To buy according to the guide: %s", ticked = "Ticked in the guide: %s",
    dbgLinks = "Continents %s · game waypoint %s · talent window %s · quests in log %d", yes = "yes", no = "no",
    qMap = "Show the quest on the map", qMapTip = "With Questie's icons: who gives it or, if it is in your log, objectives and turn-in",
    qInfo = "Quest details", qInfoTip = "Opens the quest in Questie's Journey", qWait = "Questie is still loading: try again in a moment.",
    qOff = "Questie is not active: automatic ticks, map and quest details go through Questie.", qSync = "Ticked %d items already done (quests turned in, spells already learned or talents spent).",
    ofa = "Open in OneForAll", ofaTip = "Loads this build (up to 60) into OneForAll's talent calculator",
    ofaFail = "OneForAll did not load the build by itself: copy it with Ctrl+C and paste it into Import.",
    dgMap = "Map", dgMapTip = "Opens the world map on the entrance, with the waypoint", dgMapMU = "Click MapUtils' entrance icon: the dungeon's own map opens",
    dgLoot = "Bosses and loot", dgLootTip = "Opens the dungeon in OneForAll (bosses, loot, quests)",
    dbgSpell = "Spells in the spellbook: %d · Trainer item %s, missing: %s",
    dbgAddons = "Linked addons: Questie %s · OneForAll %s · MapUtils %s",
    behind = "Left behind (%d)", behindMore = "and %d more: go back with < to find them",
  },
}
local T = TT.en

-- token inglese di UnitRace → chiave del sito (Skyborne: una per fazione)
local RACES = { Human = "human", Dwarf = "dwarf", Gnome = "gnome", NightElf = "nightelf", Orc = "orc", Troll = "troll", Tauren = "tauren", Scourge = "undead", Undead = "undead" }

local C  -- ForeverPathfinderChar: { done = {}, key = "razza-classe" scelto a mano, opt = { b, dg, x }, loads }
local DB -- ForeverPathfinderDB (tutti i personaggi): { angle, hide } dell'icona sulla minimappa
local tab, viewCh = "livello" -- scheda aperta, tappa mostrata nel Percorso

local function say(msg) DEFAULT_CHAT_FRAME:AddMessage("|cffe8b84aForever Pathfinder|r " .. msg) end

local function charKey()
  if C.key then return C.key end
  local _, r = UnitRace("player")
  local _, c = UnitClass("player")
  r = RACES[r] or (r and r:lower():find("skyborne") and (UnitFactionGroup("player") == "Horde" and "skyborne_h" or "skyborne_a"))
  return r and c and (r .. "-" .. c:lower())
end

-- variante della guida per le opzioni scelte (build, dungeon, cambio continente), decodificata una volta sola
local function guide()
  local k = charKey()
  local g = k and D[k]
  if not g then return end
  local o = C.opt
  local b = o.b or (g.builds[1] and g.builds[1][1]) or "a"
  local v = g.v[b .. (o.dg or 1) .. (g.x and o.x or 0)] or g.v[b .. "10"] or select(2, next(g.v))
  if not v._tasks then
    v._tasks, v._ch, v._tal = {}, {}, {}
    -- voce: livello, tappa, testo, numero del testo (collegamenti), codice della voce sul sito: con questo si salvano le spunte,
    -- uguale in tutte le lingue e dopo ogni aggiornamento dei dati (il numero del testo invece cambia)
    for lv, ch, n, id in PAGES[v.tasks]:gmatch("(%d+),(%d+),(%d+),(%w+)") do v._tasks[#v._tasks + 1] = { tonumber(lv), tonumber(ch), POOL[tonumber(n)], tonumber(n), id } end
    for n in PAGES[v.ch]:gmatch("%d+") do v._ch[#v._ch + 1] = POOL[tonumber(n)] end
    for name, tree in POOL[v.tal]:gmatch("([^:;]+):([^;]*)") do v._tal[#v._tal + 1] = { 9 + #v._tal + 1, name, tree } end
  end
  return g, k, v
end

-- dungeon adatti al livello per la fazione (come nella scheda Dungeon: niente "salta"), nel livello ideale
local function dungeonsAt(g, lv)
  local out = {}
  for _, d in ipairs(DG[g.faction] or {}) do
    -- livello ideale del giudizio ("18–22", "30+") se c'è, altrimenti tutto il range del dungeon
    local lo, hi = d[5]:match("(%d+)%D+(%d+)")
    if not lo then lo = d[5]:match("(%d+)%+"); hi = lo and d[3] end
    lo, hi = tonumber(lo) or d[2] - 1, tonumber(hi) or d[3]
    if d[4] ~= "skip" and lv >= lo and lv <= hi then out[#out + 1] = d end
  end
  return out
end
local function dgLabel(d) return d[1] .. " (" .. (T[d[4]] or "?") .. (d[5] ~= "" and " " .. d[5] or "") .. ")" end

-- punti talento spesi e liberi. Forever ha il sistema dei talenti dei client moderni (C_ClassTalents / C_Traits: si sommano i
-- punti dei nodi della configurazione attiva, come fa OneForAll); i client vecchi GetTalentTabInfo. Restituisce spesi, liberi e
-- da dove li ha letti ("traits", "tabs" o nil)
local function talentPoints()
  local spent, free = 0, UnitCharacterPoints and UnitCharacterPoints("player") or 0
  local ok, got = pcall(function()
    local cfg = C_ClassTalents and C_ClassTalents.GetActiveConfigID and C_ClassTalents.GetActiveConfigID()
    local ci = cfg and C_Traits and C_Traits.GetConfigInfo and C_Traits.GetConfigInfo(cfg)
    if not (ci and ci.treeIDs) then return end
    local n, cur = 0, 0
    for _, tree in ipairs(ci.treeIDs) do
      for _, node in ipairs(C_Traits.GetTreeNodes(tree) or {}) do
        local ni = C_Traits.GetNodeInfo(cfg, node)
        if ni then n = n + (ni.ranksPurchased or ni.currentRank or 0) end
      end
      for _, c in ipairs(C_Traits.GetTreeCurrencyInfo and C_Traits.GetTreeCurrencyInfo(cfg, tree, false) or {}) do cur = math.max(cur, c.quantity or 0) end
    end
    return { n, cur }
  end)
  if ok and got then
    spent = got[1]
    if free == 0 then free = got[2] end
    return spent, free, "traits"
  end
  local tabs = GetNumTalentTabs and GetNumTalentTabs() or 0
  for i = 1, tabs do spent = spent + (select(3, GetTalentTabInfo(i)) or 0) end
  return spent, free, tabs > 0 and "tabs" or nil
end
-- prossimo talento: i punti già spesi dicono a che punto dell'ordine della guida sei
local function talentLine(v)
  local spent, free = talentPoints()
  local t = v._tal[spent + 1]
  if not t then return T.talentDone end
  if free > 0 then return T.talentNow:format(t[2], t[3]) end
  return T.talentNext:format(t[1], t[2], t[3])
end

local function chapterOf(v, lv)
  local ch = 1
  for _, t in ipairs(v._tasks) do if t[1] <= lv then ch = t[2] end end
  return ch
end

-- collegamenti col gioco: interruttori nelle Opzioni (accesi di base)
local function on(name) return C.opt["no" .. name] ~= true end

-- continenti del gioco per le posizioni del sito (k, e, z): Kalimdor 1414 e Eastern Kingdoms 1415 come in Classic,
-- Zephras è l'altro continente sotto Azeroth (947) o sotto il cosmo (946); /fp debug li mostra
local CONT
local function continents()
  if CONT then return CONT end
  CONT = { k = 1414, e = 1415 }
  if C_Map and C_Map.GetMapChildrenInfo and Enum and Enum.UIMapType then
    for _, top in ipairs({ 947, 946 }) do
      for _, m in ipairs(C_Map.GetMapChildrenInfo(top, Enum.UIMapType.Continent) or {}) do
        if m.mapID ~= 1414 and m.mapID ~= 1415 and (not CONT.z or (m.name or ""):find("Zephras")) then CONT.z = m.mapID end
      end
    end
  end
  return CONT
end
-- posizione 0–1 sul continente → sulla mappa indicata (il continente stesso o una sua zona); nil se fuori
local function onMap(mapID, cont, x, y)
  if mapID == cont then return x, y end
  if not (C_Map and C_Map.GetMapRectOnMap) then return end
  local l, r, t, b = C_Map.GetMapRectOnMap(mapID, cont)
  if not l or r == l or b == t then return end
  local px, py = (x - l) / (r - l), (y - t) / (b - t)
  if px >= 0 and px <= 1 and py >= 0 and py <= 1 then return px, py end
end

-- posizione del sito (0–1 sul continente di Wowhead) → zona del gioco e posizione sul continente del gioco. I bordi della mappa
-- del continente nel gioco non sono quelli di Wowhead (Anvilmar finiva a Stormwind), quelli delle zone sì: passo dalla zona più
-- piccola che contiene il punto (uiMapID e rettangolo da Wowhead) e da C_Map.GetMapRectOnMap. Senza dati resta com'è.
local ZM = ForeverPathfinderZoneMaps or {}
local function gameXY(ck, x, y, zid)
  local best, ba
  for _, z in ipairs(ZM[ck] or {}) do if z[1] == zid then best = z end end -- zona scritta nei dati (griglia di Wowhead): esatta
  for _, z in ipairs(best and {} or ZM[ck] or {}) do
    if x >= z[2] and x <= z[4] and y >= z[3] and y <= z[5] then
      local a = (z[4] - z[2]) * (z[5] - z[3])
      if not ba or a < ba then best, ba = z, a end
    end
  end
  if not best then return x, y end
  local lx, ly = (x - best[2]) / (best[4] - best[2]), (y - best[3]) / (best[5] - best[3])
  local cont, l, r, t, b = continents()[ck]
  if cont and C_Map and C_Map.GetMapRectOnMap then l, r, t, b = C_Map.GetMapRectOnMap(best[1], cont) end
  if l and r ~= l then x, y = l + lx * (r - l), t + ly * (b - t) end
  return x, y, best[1], lx, ly
end
-- segnaposto { continente, x, y, nome }: posizione nel gioco calcolata una volta (gx, gy sul continente; zm, zx, zy nella zona)
local function xy(p)
  if not p.gx then p.gx, p.gy, p.zm, p.zx, p.zy = gameXY(p[1], p[2], p[3], p.z) end
  return p.gx, p.gy
end

-- quest nel registro: titolo → "log" o "done" (completa, da consegnare); id → titolo per riconoscere la consegna
local inLog, idTitle = {}, {}
local function scanLog()
  for k in pairs(inLog) do inLog[k] = nil end
  local Q = C_QuestLog and C_QuestLog.GetInfo and C_QuestLog
  local num = Q and Q.GetNumQuestLogEntries or GetNumQuestLogEntries
  for i = 1, (num and num() or 0) do
    local title, isHeader, isComplete, questID, _
    if Q then
      local q = Q.GetInfo(i)
      if q then title, isHeader, questID = q.title, q.isHeader, q.questID; isComplete = Q.IsComplete and Q.IsComplete(questID) end
    else
      title, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(i)
    end
    if title and not isHeader then
      inLog[title] = (isComplete == 1 or isComplete == true) and "done" or "log"
      if questID then idTitle[questID] = title end
    end
  end
end
-- stato delle quest di una voce, da scrivere accanto al testo
local function questTag(n)
  local L = LINKS[n]
  if not (L and on("quests")) then return "" end
  local st
  for _, q in ipairs(L.q) do st = (inLog[q] == "done" and "done") or st or (inLog[q] and "log") end
  if st == "done" then return "  |cff5fd68b[" .. T.toTurn .. "]|r" elseif st then return "  |cffa9e4ff[" .. T.inLog .. "]|r" end
  return ""
end
local setTarget -- segnaposto scelto da una voce (più sotto, con la minimappa)

-- Questie (obbligatorio, ## RequiredDeps): le quest della guida per nome → ID del suo database (LibQuestieDB),
-- così si spuntano anche quelle consegnate prima dell'addon, e mappa e scheda della quest usano la sua interfaccia.
-- Moduli interni di Questie (QuestieLoader): sempre dentro pcall, se cambiano resta il resto dell'addon.
local function QZ() return _G.Questie and Questie.API and Questie.API.isReady and _G.LibQuestieDB and _G.QuestieLoader and true end
local function mod(name) return QuestieLoader:ImportModule(name) end
local function qIDs(name)
  if not QZ() then return end
  local ok, ids = pcall(LibQuestieDB.Quest.IdsByName, name)
  return ok and ids or nil
end
-- ponytail: basta un ID con quel nome consegnato; due quest omonime (Alleanza e Orda) sarebbero un falso positivo, raro nel leveling
local function qDone(name)
  local done = Questie.db and Questie.db.char and Questie.db.char.complete or {}
  for _, id in ipairs(qIDs(name) or {}) do
    if done[id] or (C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted and C_QuestLog.IsQuestFlaggedCompleted(id)) then return true end
  end
end
-- l'ID da mostrare: quello nel registro, altrimenti il primo che Questie dice fattibile per il personaggio
local function qPick(name)
  local ids = qIDs(name)
  if not ids then return end
  for _, id in ipairs(ids) do if idTitle[id] == name then return id end end
  local ok, DBQ = pcall(mod, "QuestieDB")
  for _, id in ipairs(ids) do if not (ok and DBQ.IsDoable) or DBQ.IsDoable(id) then return id end end
  return ids[1]
end
-- mappa del mondo sulla quest: nel registro obiettivi e consegna (come il tracker di Questie), altrimenti chi la dà
local function qMap(name)
  local id = qPick(name)
  if not id then return false end
  local ok, done = pcall(function()
    if inLog[name] and mod("TrackerUtils").ShowQuestOnMap(id) then return true end
    local DBQ, Zone, QM, Compat = mod("QuestieDB"), mod("ZoneDB"), mod("QuestieMap"), mod("QuestieCompat")
    local by = DBQ.QueryQuestSingle(id, "startedBy") or {}
    for kind = 1, 2 do -- 1 NPC, 2 oggetti
      for _, sid in ipairs(by[kind] or {}) do
        local sp = kind == 1 and DBQ.QueryNPCSingle(sid, "spawns") or DBQ.QueryObjectSingle(sid, "spawns")
        for area, coords in pairs(sp or {}) do
          if coords[1] then
            if kind == 1 then QM:ShowNPC(sid) else QM:ShowObject(sid) end
            return Compat.OpenWorldMap(Zone:GetUiMapIdByAreaId(area))
          end
        end
      end
    end
  end)
  return ok and done
end
-- la scheda della quest nel Journey di Questie (scheda Cerca, per ID)
local function qInfo(name)
  local id = qPick(name)
  if not id then return false end
  return pcall(function()
    local J = mod("QuestieJourney")
    if not J:IsShown() then J:ToggleJourneyWindow() end
    J.tabGroup:SelectTab("search"); mod("QuestieSearchResults"):SetSearch("quest", id)
  end)
end

-- aspetto del sito: colori di style.css (:root), Cinzel per i titoli, Inter per i testi, riquadri (card) e icone del gioco
local HEX = { bg = "08111d", card = "112236", deep = "0b1828", tx = "e7eef7", mu = "93a6be", ac = "6fc3ff", ice = "a9e4ff",
  gold = "e8b84a", ok = "5fd68b", bd = "21384f", frame = "5a4a22", chip = "173a5c" }
local COL = {}
for k, h in pairs(HEX) do COL[k] = { tonumber(h:sub(1, 2), 16) / 255, tonumber(h:sub(3, 4), 16) / 255, tonumber(h:sub(5, 6), 16) / 255 } end
local FONTS = "Interface\\AddOns\\ForeverPathfinder\\Fonts\\"
local function font(file, size)
  local fo = CreateFont("ForeverPathfinderFont" .. file:gsub("%W", "") .. size)
  -- se il carattere dell'addon non si carica, quello standard del gioco
  if fo:SetFont(FONTS .. file, size, "") == false then fo:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", size, "") end
  fo:SetShadowOffset(1, -1); fo:SetShadowColor(0, 0, 0, 0.7)
  return fo
end
local F = {
  title = font("Cinzel-Bold.ttf", 18), big = font("Cinzel-Bold.ttf", 26), h1 = font("Cinzel-Bold.ttf", 15), brand = font("Cinzel-Bold.ttf", 10),
  h2 = font("Inter-Bold.ttf", 13), h3 = font("Inter-Bold.ttf", 12), p = font("Inter-Regular.ttf", 12), small = font("Inter-Bold.ttf", 10), nav = font("Inter-Bold.ttf", 11),
  x = font("Inter-Regular.ttf", 22),
}
-- tipo di riga delle schede: carattere, colore, spazio prima
local KIND = { ["1"] = { F.h1, "ice", 0 }, ["2"] = { F.h2, "gold", 10 }, ["3"] = { F.h3, "tx", 8 }, ["0"] = { F.p, "tx", 5 } }
local function paint(t, c, a) t:SetColorTexture(COL[c][1], COL[c][2], COL[c][3], a or 1) end
local function colorize(s) return (s:gsub("{", "|cffe8b84a"):gsub("}", "|r")) end
local function iconPath(n) return "Interface\\Icons\\" .. n end

local W, H, TOP = 680, 500, 112
local f = CreateFrame("Frame", nil, UIParent)
_G.ForeverPathfinderFrame = f
tinsert(UISpecialFrames, "ForeverPathfinderFrame") -- Esc chiude
f:SetSize(W, H); f:SetPoint("CENTER"); f:SetFrameStrata("HIGH"); f:SetToplevel(true)
f:SetMovable(true); f:EnableMouse(true); f:SetClampedToScreen(true)
f:RegisterForDrag("LeftButton"); f:SetScript("OnDragStart", f.StartMoving); f:SetScript("OnDragStop", f.StopMovingOrSizing)
f:Hide()
-- rettangolo pieno e bordo di 1 px
local function rect(parent, layer, c, a, x, y, w, h)
  local t = parent:CreateTexture(nil, layer); paint(t, c, a); t:SetPoint("TOPLEFT", x, y); t:SetSize(w, h); return t
end
local function frame(parent, c, w, h)
  rect(parent, "BORDER", c, 1, 0, 0, w, 1); rect(parent, "BORDER", c, 1, 0, -h + 1, w, 1)
  rect(parent, "BORDER", c, 1, 0, 0, 1, h); rect(parent, "BORDER", c, 1, w - 1, 0, 1, h)
end
rect(f, "BACKGROUND", "bg", 0.97, 0, 0, W, H)
rect(f, "BACKGROUND", "chip", 0.35, 0, 0, W, 70) -- testata più chiara, come il bagliore in cima al sito
frame(f, "frame", W, H)
rect(f, "BORDER", "bd", 1, 1, -70, W - 2, 1)

-- testata: icona della classe, "Forever Pathfinder", nome del personaggio, livello e build
local crest = f:CreateTexture(nil, "ARTWORK"); crest:SetPoint("TOPLEFT", 16, -14); crest:SetSize(42, 42)
local crestB = CreateFrame("Frame", nil, f); crestB:SetPoint("TOPLEFT", 15, -13); crestB:SetSize(44, 44); frame(crestB, "gold", 44, 44)
local function text(parent, fo, c, x, y, w)
  local s = parent:CreateFontString(nil, "OVERLAY"); s:SetFontObject(fo); s:SetTextColor(unpack(COL[c])); s:SetJustifyH("LEFT")
  s:SetPoint("TOPLEFT", x, y); if w then s:SetWidth(w) end; return s
end
text(f, F.brand, "ice", 70, -14):SetText("FOREVER PATHFINDER")
local title = text(f, F.title, "gold", 70, -28, W - 140)
local sub = text(f, F.nav, "mu", 70, -51, W - 140)
local close = CreateFrame("Button", nil, f); close:SetPoint("TOPLEFT", W - 34, -10); close:SetSize(24, 24)
local closeT = text(close, F.x, "mu", 5, 1); closeT:SetText("×")
close:SetScript("OnClick", function() f:Hide() end)
close:SetScript("OnEnter", function() closeT:SetTextColor(unpack(COL.tx)) end)
close:SetScript("OnLeave", function() closeT:SetTextColor(unpack(COL.mu)) end)

-- pulsante a pillola come le schede del sito: acceso = fondo chip e testo ice
local function pill(parent, label)
  local b = CreateFrame("Button", nil, parent)
  b.bg = b:CreateTexture(nil, "BACKGROUND"); b.bg:SetAllPoints()
  b.fs = text(b, F.nav, "mu", 11, -6); b.fs:SetText(label)
  b:SetSize(math.floor((b.fs:GetStringWidth() or 40) + 22), 24)
  local hl = b:CreateTexture(nil, "HIGHLIGHT"); hl:SetAllPoints(); hl:SetColorTexture(1, 1, 1, 0.06)
  b.set = function(on) paint(b.bg, on and "chip" or "card", on and 1 or 0.6); b.fs:SetTextColor(unpack(COL[on and "ice" or "mu"])) end
  b.set(false)
  return b
end

-- contenuto a scorrimento: rotella del mouse e barra sottile a destra
local scroll = CreateFrame("ScrollFrame", nil, f)
scroll:SetPoint("TOPLEFT", 12, -TOP); scroll:SetSize(W - 38, H - TOP - 12)
local BW = W - 38
local body = CreateFrame("Frame", nil, scroll)
body:SetSize(BW, 10)
scroll:SetScrollChild(body)
local bar = CreateFrame("Slider", nil, f)
bar:SetPoint("TOPLEFT", W - 18, -TOP); bar:SetSize(6, H - TOP - 12); bar:SetOrientation("VERTICAL")
rect(bar, "BACKGROUND", "deep", 1, 0, 0, 6, H - TOP - 12)
local thumb = bar:CreateTexture(nil, "OVERLAY"); paint(thumb, "bd"); thumb:SetSize(6, 48); bar:SetThumbTexture(thumb)
bar:SetMinMaxValues(0, 0); bar:SetValueStep(1); bar:SetValue(0)
bar:SetScript("OnValueChanged", function(_, v) scroll:SetVerticalScroll(v) end)
scroll:EnableMouseWheel(true)
scroll:SetScript("OnMouseWheel", function(_, d) local lo, hi = bar:GetMinMaxValues(); bar:SetValue(math.max(lo, math.min(hi, bar:GetValue() - d * 48))) end)

-- elementi riusati a ogni disegno: testi, icone, rettangoli (card e righe di separazione), caselle, pulsanti
local P = { fs = {}, ic = {}, rc = {}, ln = {}, cb = {}, bt = {}, pn = {} }
local N = { fs = 0, ic = 0, rc = 0, ln = 0, cb = 0, bt = 0, pn = 0 }
local y = 0
local function take(kind, make)
  N[kind] = N[kind] + 1
  local o = P[kind][N[kind]]
  if not o then o = make(); P[kind][N[kind]] = o end
  return o
end
local function put(o, x, yy, w, h) o:ClearAllPoints(); o:SetPoint("TOPLEFT", x, yy); if w then o:SetWidth(w) end; if h then o:SetHeight(h) end; o:Show(); return o end
local function str(fo, c, s, x, w)
  local o = take("fs", function() local t = body:CreateFontString(nil, "OVERLAY"); t:SetJustifyH("LEFT"); return t end)
  o:SetFontObject(fo); o:SetTextColor(unpack(COL[c])); put(o, x, y, w); o:SetText(colorize(s))
  return o
end
local function icon(name, x, yy, size)
  local o = take("ic", function() local t = body:CreateTexture(nil, "ARTWORK"); t:SetTexCoord(0.07, 0.93, 0.07, 0.93); return t end)
  o:SetTexture(iconPath(name)); return put(o, x, yy, size, size)
end
-- fondo delle card nel livello BACKGROUND, bordi e righe di separazione sopra (BORDER)
local function box(c, a, x, yy, w, h, line)
  local o = take(line and "ln" or "rc", function() return body:CreateTexture(nil, line and "BORDER" or "BACKGROUND") end)
  paint(o, c, a); return put(o, x, yy, w, h)
end
-- card del sito: fondo card e bordo bd, disegnata quando si sa dove finisce
local cardTop
local function cardOpen() cardTop = y end
local function cardClose()
  if not cardTop then return end
  y = y - 12
  local h = cardTop - y
  box("card", 1, 0, cardTop, BW, h)
  box("bd", 1, 0, cardTop, BW, 1, true); box("bd", 1, 0, y + 1, BW, 1, true); box("bd", 1, 0, cardTop, 1, h, true); box("bd", 1, BW - 1, cardTop, 1, h, true)
  cardTop = nil
  y = y - 10
end
local function check(id, x, yy)
  local o = take("cb", function()
    local c = CreateFrame("CheckButton", nil, body); c:SetSize(18, 18)
    local bg = c:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); paint(bg, "deep")
    frame(c, "bd", 18, 18)
    local ck = c:CreateTexture(nil, "OVERLAY"); ck:SetTexture("Interface\\Buttons\\UI-CheckBox-Check"); ck:SetPoint("TOPLEFT", -3, 3); ck:SetSize(24, 24); c:SetCheckedTexture(ck)
    local hl = c:CreateTexture(nil, "HIGHLIGHT"); hl:SetAllPoints(); hl:SetColorTexture(1, 1, 1, 0.1)
    c:SetScript("OnClick", function(self) if self.onClick then self.onClick(self:GetChecked()) else C.done[self.id] = self:GetChecked() and true or nil end end)
    return c
  end)
  o.id, o.onClick = id, nil
  o:SetChecked(C.done[id] and true or false)
  return put(o, x, yy)
end
local function button(label, x, yy, fn)
  local o = take("bt", function() return pill(body, label) end)
  o.fs:SetText(label); o:SetWidth(math.floor((o.fs:GetStringWidth() or 20) + 22)); o.set(true)
  o:SetScript("OnClick", fn); return put(o, x, yy)
end
-- pulsantino quadrato con un'icona del gioco (segnaposto, scheda della quest) e il suo tooltip
-- spell della voce "Trainer: A, B (nota)", senza le note tra parentesi
local function trainerList(text)
  local list = text:gsub("^%^[^%^]*%^", ""):match("^Trainer:%s*(.+)$")
  if not list then return end
  local out = {}
  for n in list:gsub("%b()", ""):gmatch("[^,;]+") do out[#out + 1] = (n:gsub("^%s+", ""):gsub("%s+$", "")) end
  return out
end
-- nomi delle spell nel libro degli incantesimi (come OneForAll: API vecchia e C_SpellBook dei client moderni, tutte e due se ci sono)
local function spellBook()
  local set = {}
  pcall(function()
    if GetNumSpellTabs and GetSpellTabInfo and GetSpellBookItemName then
      for tab = 1, GetNumSpellTabs() do
        local _, _, off, num = GetSpellTabInfo(tab)
        for i = (off or 0) + 1, (off or 0) + (num or 0) do local n = GetSpellBookItemName(i, BOOKTYPE_SPELL or "spell"); if n then set[n] = true end end
      end
    end
  end)
  pcall(function()
    if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines then
      local bank = (Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player) or 0
      for line = 1, C_SpellBook.GetNumSpellBookSkillLines() do
        local li = C_SpellBook.GetSpellBookSkillLineInfo(line)
        for i = (li and li.itemIndexOffset or 0) + 1, (li and li.itemIndexOffset or 0) + (li and li.numSpellBookItems or 0) do
          local info = C_SpellBook.GetSpellBookItemInfo(i, bank)
          if type(info) == "table" and info.name then set[info.name] = true end
        end
      end
    end
  end)
  return set
end
-- spell già appresa: nel libro, o per nome con C_Spell (trova solo quelle che conosci) e IsPlayerSpell
local function known(name, book)
  if book and book[name] then return true end
  local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(name)
  local id = info and info.spellID or (GetSpellInfo and select(7, GetSpellInfo(name)))
  if not id then return false end
  if IsPlayerSpell then return IsPlayerSpell(id) end
  return true
end
-- libro letto una volta e riletto quando cambiano le spell (SPELLS_CHANGED)
local BOOK
local function book() BOOK = BOOK or spellBook(); return BOOK end
-- voce Trainer: le spell che conosci già in verde
local function trainerText(t, s)
  if not on("trainer") then return s end
  local sp = trainerList(t[3])
  if not sp then return s end
  for _, n in ipairs(sp) do
    if known(n, book()) then s = s:gsub(n:gsub("%p", "%%%0"), "|cff5fd68b" .. n:gsub("%%", "%%%%") .. "|r", 1) end
  end
  return s
end
local function mini(ic, x, yy, tip, tip2, fn)
  local o = take("pn", function()
    local b = CreateFrame("Button", nil, body); b:SetSize(20, 20)
    b.tx = b:CreateTexture(nil, "ARTWORK"); b.tx:SetAllPoints(); b.tx:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    frame(b, "gold", 20, 20)
    local hl = b:CreateTexture(nil, "HIGHLIGHT"); hl:SetAllPoints(); hl:SetColorTexture(1, 1, 1, 0.2)
    b:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_LEFT"); GameTooltip:AddLine(self.tip); GameTooltip:AddLine(self.tip2, 1, 1, 1, true); GameTooltip:Show() end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    b:SetScript("OnClick", function(self) self.fn() end)
    return b
  end)
  o.tx:SetTexture(iconPath(ic)); o.tip, o.tip2, o.fn = tip, tip2, fn
  return put(o, x, yy)
end
local function clear()
  for k, l in pairs(P) do for i = 1, N[k] do l[i]:Hide() end; N[k] = 0 end
  y, cardTop = 0, nil
end
-- riga di testo dentro la card, con le sue icone ("^a,b^testo"): una icona a sinistra, più icone in fila sopra
local PAD = 14
local function line(kind, s)
  local k = KIND[kind] or KIND["0"]
  local icons, rest = s:match("^%^([^%^]*)%^(.*)$")
  s = rest or s
  y = y - k[3]
  local x, w, single = PAD, BW - 2 * PAD, false
  if s:sub(1, 3) == "• " then x, w = x + 8, w - 8 end
  if icons then
    local list = {}
    for n in icons:gmatch("[^,]+") do list[#list + 1] = n end
    if #list > 1 then
      for i, n in ipairs(list) do icon(n, x + (i - 1) * 26, y, 22) end
      y = y - 28
    else
      icon(list[1], x, y - 1, kind == "0" and 18 or 20); x, w, single = x + 26, w - 26, true
    end
  end
  local o = str(k[1], k[2], s, x, w)
  y = y - math.max(o:GetStringHeight(), single and 18 or 0)
  return o
end

local render
-- una voce della checklist dalla casella in poi: casella, icona, testo, a destra i pulsanti; top = y della riga
local function itemRow(k, t, top, after)
  local cb = check(k .. ":" .. t[5], PAD + 52, y + 1)
  if after then cb.onClick = function(v) C.done[cb.id] = v and true or nil; after() end end
  local ic, s = t[3]:match("^%^([^%^,]*)[^%^]*%^(.*)$")
  local x = PAD + 78
  if ic then icon(ic, x, y + 1, 18); x = x + 24 end
  -- a destra: voce con quest → mappa e scheda di Questie; altrimenti il segnaposto della voce (mappa e minimappa).
  -- Accanto al testo lo stato della quest nel registro
  local L, right = LINKS[t[4]], 0
  local q, p = L and not L.any and L.q[1], L and L.p[1] -- lettere di classe: niente pulsanti di Questie (la quest giusta dipende dalla classe)
  if q and on("map") then
    mini("inv_misc_map_01", BW - PAD - 20, y, q, T.qMapTip, function()
      -- la mappa del mondo sta sotto la guida: la guida si chiude (si riapre dall'icona)
      if not QZ() then say(T.qWait) elseif qMap(q) then f:Hide() elseif p then setTarget(p) end
    end)
    mini("inv_misc_book_09", BW - PAD - 46, y, q, T.qInfoTip, function() if not (QZ() and qInfo(q)) then say(T.qWait) end end)
    right = 54
  elseif p and on("map") then
    mini("inv_misc_map_01", BW - PAD - 20, y, p[4], T.pinTip, function() setTarget(p) end)
    right = 28
  end
  local o = str(F.p, "tx", trainerText(t, s or t[3]) .. questTag(t[4]), x, BW - PAD - x - right)
  y = top - math.max(o:GetStringHeight(), 20) - 6
end
-- rimaste indietro: voci dei livelli già superati non spuntate delle tappe prima (quelle di questa tappa sono sotto), le prime 5;
-- spuntandone una sparisce
local BEHIND = 5
local function drawBehind(k, v, lv, ch)
  local list, seen = {}, {}
  for _, t in ipairs(v._tasks) do
    if t[1] < lv and t[2] < ch and not seen[t[4]] and not C.done[k .. ":" .. t[5]] then seen[t[4]] = true; list[#list + 1] = t end
  end
  if #list == 0 then return end
  cardOpen(); y = y - 12
  str(F.h3, "gold", T.behind:format(#list), PAD, BW - 2 * PAD); y = y - 20
  for i = 1, math.min(BEHIND, #list) do
    local t = list[i]
    if i > 1 then box("bd", 1, PAD, y, BW - 2 * PAD, 1, true) end
    y = y - 8
    local top = y
    str(F.small, "mu", T.level:format(t[1]), PAD, 50)
    itemRow(k, t, top, function() render() end)
  end
  if #list > BEHIND then y = y - 4; local o = str(F.small, "mu", T.behindMore:format(#list - BEHIND), PAD, BW - 2 * PAD); y = y - o:GetStringHeight() end
  cardClose()
end
-- Percorso: card della tappa (numero grande, nome, frecce), card "ora" (build, talento, dungeon), card delle voci per livello
local function drawPath(g, k, v)
  local lv = UnitLevel("player")
  viewCh = viewCh or chapterOf(v, lv)
  if viewCh == chapterOf(v, lv) then drawBehind(k, v, lv, viewCh) end
  local n = #v._ch
  cardOpen(); y = y - 12
  str(F.small, "mu", T.stageWord, PAD, nil)
  button("<", BW - PAD - 68, y + 2, function() viewCh = math.max(1, viewCh - 1); render(true) end)
  button(">", BW - PAD - 32, y + 2, function() viewCh = math.min(n, viewCh + 1); render(true) end)
  y = y - 14
  str(F.big, "gold", viewCh .. "", PAD, nil)
  str(F.nav, "mu", "/ " .. n, PAD + 38, nil):SetPoint("TOPLEFT", PAD + 38, y - 10)
  local name = str(F.h1, "ice", ((v._ch[viewCh] or ""):gsub("^%d+%.%s*", "")), PAD + 76, BW - PAD * 2 - 76 - 76)
  name:SetPoint("TOPLEFT", PAD + 76, y - 6)
  y = y - 34
  line("0", "{" .. T.oBuild .. ":} " .. v.build)
  y = y - 4; str(F.h3, "gold", talentLine(v), PAD, BW - 2 * PAD); y = y - 16
  local ds, names = dungeonsAt(g, lv), {}
  for _, d in ipairs(ds) do names[#names + 1] = dgLabel(d) end
  if #ds > 0 then y = y - 2; local o = str(F.p, "ice", T.dungeon:format(table.concat(names, ", ")), PAD, BW - 2 * PAD); y = y - o:GetStringHeight() end
  cardClose()
  -- voci: livello a sinistra (verde se è il tuo), casella, icona, testo; una riga sottile tra le voci
  cardOpen(); y = y - 6
  local cur, seen, here, first = nil, {}, nil, true
  for _, t in ipairs(v._tasks) do
    if t[2] == viewCh and not seen[t[4]] then
      seen[t[4]] = true -- un livello a cavallo di due tappe compare in entrambe: ogni voce una volta sola
      if not first then box("bd", 1, PAD, y, BW - 2 * PAD, 1, true) end
      first = false
      y = y - 8
      local top = y
      if t[1] ~= cur then
        cur = t[1]
        if cur <= lv then here = -y end
        str(F.small, cur == lv and "ok" or "ac", T.level:format(cur), PAD, 50)
        if cur == lv then y = y - 13; str(F.small, "ok", T.now, PAD, 50); y = top end
      end
      itemRow(k, t, top)
    end
  end
  cardClose()
  return here
end

local function loaded(name) local fn = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded; return fn and fn(name) and true or false end
local function norm(s) return (s:lower():gsub("^the ", ""):gsub("[^%w]", "")) end

-- dungeon: ingresso dalla mappa del sito (Data.lua) → mappa del mondo con il segnaposto, dove MapUtils mette la sua icona
-- d'ingresso (un clic apre la mappa interna: MapUtils non ha funzioni per altri addon); boss e loot nella scheda di OneForAll
local DPOS
local function dgFind(title) -- il nome più lungo con cui comincia il titolo ("The Deadmines Livelli 17–26 …")
  if not DPOS then DPOS = {}; for _, d in ipairs(ForeverPathfinderDungeonPos or {}) do DPOS[#DPOS + 1] = { d[2], d[3], d[4], d[1], norm(d[1]), z = d.z } end end
  local t, best = norm(title)
  for _, p in ipairs(DPOS) do if t:sub(1, #p[5]) == p[5] and (not best or #p[5] > #best[5]) then best = p end end
  return best
end
local focus -- ingresso scelto: resta sulla mappa del mondo insieme ai segnaposti della tappa
local drawMapPins
local function dgMap(p)
  focus = p; setTarget(p)
  local cont = continents()[p[1]]
  local gx, gy = xy(p)
  local zone = not p.zm and cont and C_Map.GetMapInfoAtPosition and C_Map.GetMapInfoAtPosition(cont, gx, gy)
  local id = p.zm or zone and zone.mapID or cont
  if not id then return end
  if C_Map.OpenWorldMap then C_Map.OpenWorldMap(id) else if not WorldMapFrame:IsShown() then ShowUIPanel(WorldMapFrame) end; WorldMapFrame:SetMapID(id) end
  f:Hide(); drawMapPins()
  if loaded("MapUtils") then say(T.dgMapMU) end
end
local function ofaDungeon(name)
  local O = _G.OneForAll
  if not (O and O.DUNGEONS and O.OpenPanel) then return end
  local n = norm(name)
  for _, d in ipairs(O.DUNGEONS) do
    if norm(d.name) == n or (d.short and norm(d.short) == n) then return d end
    for _, a in ipairs(d.aliases or {}) do if norm(a) == n then return d end end
  end
end

-- OneForAll: la build della guida (tutti i punti fino al 60) come codice del suo calcolatore (TalentCode, pubblico), poi il suo
-- pulsante "Import build" con il codice già dentro; se non riesce, la sua finestra Export con il codice da copiare
local function findButton(fr, text, depth)
  if not fr or depth > 14 then return end
  if fr.IsObjectType and fr:IsObjectType("Button") and fr:IsVisible() then
    for _, r in ipairs({ fr:GetRegions() }) do if r.GetText and r:GetText() == text then return fr end end
  end
  for _, c in ipairs({ fr:GetChildren() }) do local b = findButton(c, text, depth + 1); if b then return b end end
end
local function ofaLoad(v)
  local O = _G.OneForAll
  local TC = O and O.TalentCode
  local ranks = {}
  for _, t in ipairs(v._tal) do local key = t[2]:gsub("’", "'"):lower(); ranks[key] = (ranks[key] or 0) + 1 end
  local okc, code = pcall(TC.Encode, select(3, UnitClass("player")), ranks)
  if not (okc and code) then say(T.ofaFail); return end
  O:OpenPanel("talents")
  local imp, show, ok = findButton(_G.OneForAllFrame, "Import build", 0), TC.ShowImport, false
  if imp then
    TC.ShowImport = function(cb) TC.ShowImport = show; ok = cb(code) == nil end
    pcall(imp.Click, imp)
    TC.ShowImport = show
  end
  if not ok then say(T.ofaFail); TC.ShowExport(code) end
end

-- una scheda del sito: ogni titolo "1…" apre una card, poi titoli "2…"/"3…" e paragrafi "0…".
-- Talent: in cima "Apri in OneForAll"; Dungeon: sotto il titolo di ogni dungeon "Mappa" e "Boss e loot"
local function drawPage(v, name)
  if name == "talent" and _G.OneForAll and OneForAll.TalentCode and OneForAll.OpenPanel then
    cardOpen(); y = y - 12
    button(T.ofa .. " ↗", PAD, y, function() ofaLoad(v) end); y = y - 26
    line("0", T.ofaTip)
    cardClose()
  end
  for n in PAGES[v.tabs[name]]:gmatch("%d+") do
    local s = POOL[tonumber(n)]
    local kind = s:sub(1, 1)
    if kind == "1" or not cardTop then cardClose(); cardOpen(); y = y - 12; if kind ~= "1" then y = y + 5 end end
    line(kind, s:sub(2))
    local p = name == "dungeon" and kind == "3" and dgFind(s:sub(2))
    if p then
      y = y - 4
      local b = button(T.dgMap, PAD, y, function() dgMap(p) end)
      local d = ofaDungeon(p[4])
      if d then button(T.dgLoot, PAD + b:GetWidth() + 8, y, function() OneForAll:OpenPanel("dungeons"); if OneForAll.UI and OneForAll.UI.OpenDungeon then OneForAll.UI.OpenDungeon(d) end end) end
      y = y - 26
    end
  end
  cardClose()
end

local minimapIcon -- icona sulla minimappa (più sotto)
local setLang -- lingua dell addon (più sotto, con le schede)
local function drawOptions(g, k)
  local o = C.opt
  local function opt(label, on, fn)
    y = y - 6
    local cb = check("opt", PAD, y)
    cb:SetChecked(on); cb.onClick = function(val) fn(val); render() end
    local s = str(F.p, "tx", label, PAD + 28, BW - 2 * PAD - 28); s:SetPoint("TOPLEFT", PAD + 28, y - 2)
    y = y - math.max(18, s:GetStringHeight())
  end
  cardOpen(); y = y - 12
  line("1", T.options)
  line("2", T.oBuild)
  for _, b in ipairs(g.builds) do opt(b[2], (o.b or g.builds[1][1]) == b[1], function() o.b = b[1] end) end
  line("2", T.oRoute)
  opt(T.oDg, (o.dg or 1) == 1, function(on) o.dg = on and 1 or 0 end)
  if g.x then opt(T.oX, o.x == 1, function(on) o.x = on and 1 or 0 end) else line("0", T.oNoX) end
  line("2", T.oShow)
  opt(T.oMinimap, not DB.hide, function(on) DB.hide = not on; minimapIcon() end)
  line("2", T.oLinks)
  for _, l in ipairs({ { "map", T.oMap }, { "quests", T.oQuests }, { "tal", T.oTal }, { "trainer", T.oTrainer } }) do
    opt(l[2], o["no" .. l[1]] ~= true, function(val) o["no" .. l[1]] = not val or nil end)
  end
  line("0", T.oEnglish)
  line("2", "Language · Lingua")
  opt("English", LANG == "en", function() setLang("en") end)
  opt("Italiano", LANG == "it", function() setLang("it") end)
  line("2", T.oChar)
  line("0", T.oAuto:format(g.name .. " (" .. k .. ")"))
  line("0", T.oSite)
  cardClose()
end

-- schede in alto, come sul sito
local navB, nx = {}, 12
local function navList()
  local l = {}
  for _, t in ipairs(D._tabs) do l[#l + 1] = t end
  l[#l + 1] = { "opzioni", T.options }
  return l
end
for _, t in ipairs(navList()) do
  local b = pill(f, t[2])
  b:SetScript("OnClick", function() tab = t[1]; render(true) end)
  navB[t[1]] = b
end
-- nomi delle schede nella lingua scelta, una accanto all'altra
local function layoutNav()
  nx = 12
  for _, t in ipairs(navList()) do
    local b = navB[t[1]]
    b.fs:SetText(t[2]); b:SetWidth(math.floor((b.fs:GetStringWidth() or 40) + 22))
    b:ClearAllPoints(); b:SetPoint("TOPLEFT", nx, -80); nx = nx + b:GetWidth() + 4
  end
end
layoutNav()
-- lingua dell'addon: si sceglie nelle Opzioni (o con /fp lang)
setLang = function(l)
  LANG = (l == "it") and "it" or "en"
  if DB then DB.lang = LANG end
  T = TT[LANG]; bindData(); layoutNav()
  if f:IsShown() then render() end
end

render = function(top)
  clear()
  local g, k, v = guide()
  for id, b in pairs(navB) do b.set(id == tab) end
  if not g then
    title:SetText("Forever Pathfinder"); sub:SetText(""); crest:SetTexture(iconPath("inv_misc_map_01"))
    cardOpen(); y = y - 12; line("0", T.unknown); cardClose()
  else
    local cls = k:match("-(%a+)$")
    crest:SetTexture(iconPath("classicon_" .. cls))
    title:SetText(g.name)
    sub:SetText(T.level:format(UnitLevel("player")) .. "  ·  " .. v.build)
    local here
    if tab == "livello" then here = drawPath(g, k, v)
    elseif tab == "opzioni" then drawOptions(g, k)
    else drawPage(v, tab) end
    body:SetHeight(-y + 10)
    if scroll.UpdateScrollChildRect then scroll:UpdateScrollChildRect() end
    local range = math.max(0, -y - (H - TOP - 12))
    bar:SetMinMaxValues(0, range)
    if range > 0 then bar:Show() else bar:Hide() end
    if top then bar:SetValue(here and math.min(range, math.max(0, here - 60)) or 0) end
  end
  body:SetHeight(-y + 10)
end

local function open(t)
  if t then tab = t end
  viewCh = nil
  f:Show(); render(true)
end

-- icona sulla minimappa: clic apre la guida, clic destro le opzioni. Forever ha la minimappa moderna: l'icona la mette
-- LibDBIcon (la stessa di Questie, che è obbligatorio, quindi c'è sempre); il riquadro degli addon usa AddonCompartmentFunc del .toc
local function mbClick(_, btn)
  if btn == "RightButton" then open("opzioni") elseif f:IsShown() then f:Hide() else open() end
end
ForeverPathfinder_OnCompartment = mbClick
local DBI = LibStub and LibStub("LibDBIcon-1.0", true)
local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
minimapIcon = function()
  if not (DBI and LDB) then return end
  DB.icon = DB.icon or {}
  DB.icon.hide = DB.hide and true or false
  if not DBI:IsRegistered(ADDON) then
    DBI:Register(ADDON, LDB:NewDataObject(ADDON, { type = "launcher", icon = "Interface\\AddOns\\ForeverPathfinder\\icon", OnClick = mbClick,
      OnTooltipShow = function(tt) tt:AddLine("Forever Pathfinder"); tt:AddLine(T.mbHint, 1, 1, 1) end }), DB.icon)
  end
  if DB.hide then DBI:Hide(ADDON) else DBI:Show(ADDON) end
end

-- mappa del mondo: i segnaposti della tappa (quella mostrata nel Percorso, o quella del tuo livello) sopra la mappa aperta
local mapPins = {}
local function stagePins()
  local g, k, v = guide()
  if not g then return {} end
  local ch = viewCh or chapterOf(v, UnitLevel("player"))
  local out, seen = {}, {}
  for _, t in ipairs(v._tasks) do
    local L = t[2] == ch and LINKS[t[4]]
    if L then for _, p in ipairs(L.p) do
      local id = p[4] .. p[2]
      if not seen[id] then seen[id] = true; out[#out + 1] = { p[1], p[2], p[3], p[4], t[1], z = p.z, q = L.q, done = C.done[k .. ":" .. t[5]] } end
    end end
  end
  return out
end
-- icona del segnaposto, come sulla mappa del sito: trainer di classe → icona della classe, Flight Master → grifone o viverna,
-- ingresso di un dungeon → teschio, NPC di una quest → "!" (o "?" se la quest è nel registro), altrimenti l'icona dell'addon.
-- full = icona quadrata del gioco (si ritaglia il bordo e ha il fondo scuro)
local PCLASS = { Druid = 1, Hunter = 1, Mage = 1, Paladin = 1, Priest = 1, Rogue = 1, Shaman = 1, Warlock = 1, Warrior = 1 }
local function pinIcon(p)
  local n = p[4] or ""
  local cls = n:match("^(%a+) Trainer$")
  if p.dg or (DPOS and p[5] and p[5] == norm(n)) then return iconPath("INV_Misc_Bone_HumanSkull_01"), true end
  if cls and PCLASS[cls] then return iconPath("ClassIcon_" .. cls), true end
  if n == "Flight Master" then return iconPath(UnitFactionGroup("player") == "Horde" and "Ability_Mount_Wyvern_01" or "Ability_Mount_Gryphon_01"), true end
  if p.q and p.q[1] then
    for _, q in ipairs(p.q) do if inLog[q] then return "Interface\\GossipFrame\\ActiveQuestIcon" end end
    return "Interface\\GossipFrame\\AvailableQuestIcon"
  end
  return "Interface\\AddOns\\ForeverPathfinder\\icon"
end
local function paintPin(tx, p)
  local ic, full = pinIcon(p)
  tx:SetTexture(ic)
  if full then tx:SetTexCoord(0.08, 0.92, 0.08, 0.92) else tx:SetTexCoord(0, 1, 0, 1) end
end
-- cornice delle nostre icone: bordo viola di 2 pixel e fondo scuro, così non si confondono con quelle di Questie
-- misura dell'icona e del bordo: il bordo è 1/14 dell'icona (18 pixel → poco più di 1 pixel), così con lo zoom della mappa
-- cresce insieme all'icona in unità della tela ma sullo schermo resta sottile
local function sizePin(fr, z)
  fr:SetSize(z, z)
  local t = z / 14
  fr.bd:ClearAllPoints(); fr.bd:SetPoint("TOPLEFT", -t, t); fr.bd:SetPoint("BOTTOMRIGHT", t, -t)
end
local function pinFrame(fr)
  local bd = fr:CreateTexture(nil, "BACKGROUND", nil, -1); bd:SetColorTexture(0.64, 0.21, 0.93, 1); fr.bd = bd
  local bg = fr:CreateTexture(nil, "BACKGROUND", nil, 0); bg:SetAllPoints(); bg:SetColorTexture(0.04, 0.06, 0.1, 0.9)
  sizePin(fr, fr:GetWidth() > 0 and fr:GetWidth() or 16)
end
-- misura dell'icona sulla tela della mappa per restare 18 pixel sullo schermo (la tela è ingrandita, e di più con lo zoom)
local function pinSize(canvas)
  local cs = canvas.GetEffectiveScale and canvas:GetEffectiveScale() or 1
  local us = UIParent.GetEffectiveScale and UIParent:GetEffectiveScale() or 1
  return 18 * us / ((cs and cs > 0) and cs or 1)
end
local pinZoom, pinT = nil, 0
if WorldMapFrame then
  WorldMapFrame:HookScript("OnUpdate", function(_, dt) -- con la rotella la tela cambia scala: rimisuro le icone
    pinT = pinT + (dt or 0)
    if pinT < 0.1 then return end
    pinT = 0
    local canvas = WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child
    if not canvas then return end
    local z = pinSize(canvas)
    if z ~= pinZoom then pinZoom = z; for _, p in ipairs(mapPins) do sizePin(p, z) end end
  end)
end
drawMapPins = function()
  for _, p in ipairs(mapPins) do p:Hide() end
  if not (C and WorldMapFrame and WorldMapFrame:IsShown() and on("map")) then return end
  local canvas = WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child
  local mapID = WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
  if not (canvas and mapID) then return end
  local cw, ch = canvas:GetWidth(), canvas:GetHeight()
  local cont, n = continents(), 0
  local list = stagePins()
  if focus then list[#list + 1] = { focus[1], focus[2], focus[3], focus[4], UnitLevel("player"), z = focus.z, dg = true } end
  for _, p in ipairs(list) do
    local x, y
    local gx, gy = xy(p)
    if mapID == p.zm then x, y = p.zx, p.zy elseif cont[p[1]] then x, y = onMap(mapID, cont[p[1]], gx, gy) end
    if x then
      n = n + 1
      local pin = mapPins[n]
      if not pin then
        pin = CreateFrame("Button", nil, canvas); pin:SetSize(24, 24)
        pinFrame(pin)
        pin.tx = pin:CreateTexture(nil, "OVERLAY"); pin.tx:SetAllPoints()
        pin:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(self.p[4]); GameTooltip:AddLine("Forever Pathfinder · " .. T.level:format(self.p[5]), 1, 1, 1); GameTooltip:Show() end)
        pin:SetScript("OnLeave", function() GameTooltip:Hide() end)
        pin:SetScript("OnClick", function(self) setTarget(self.p) end)
        mapPins[n] = pin
      end
      pin.p = p
      paintPin(pin.tx, p); pin:SetAlpha(p.done and 0.45 or 1) -- voce già spuntata: più chiara
      pin:SetFrameLevel(canvas:GetFrameLevel() + 2000)
      sizePin(pin, pinSize(canvas))
      pin:ClearAllPoints(); pin:SetPoint("CENTER", canvas, "TOPLEFT", x * cw, -y * ch); pin:Show()
    end
  end
end
if WorldMapFrame then
  WorldMapFrame:HookScript("OnShow", drawMapPins)
  if WorldMapFrame.OnMapChanged then hooksecurefunc(WorldMapFrame, "OnMapChanged", drawMapPins) end
end

-- segnaposto scelto da una voce: quello del gioco (mappa e minimappa) se questa versione lo permette, altrimenti il nostro sulla minimappa
local target
local mm = CreateFrame("Frame", nil, Minimap); mm:SetSize(16, 16); mm:SetFrameLevel(Minimap:GetFrameLevel() + 10); mm:Hide()
pinFrame(mm)
local mmT = mm:CreateTexture(nil, "OVERLAY"); mmT:SetAllPoints(); mmT:SetTexture("Interface\\AddOns\\ForeverPathfinder\\icon")
-- diametro della minimappa in yard per livello di zoom (all'aperto, come in Classic)
local MMY = { 466.67, 400, 333.33, 266.67, 200, 133.33 }
local function playerOn(cont) -- posizione del giocatore 0–1 sul continente
  local zone = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
  local pos = zone and C_Map.GetPlayerMapPosition(zone, "player")
  if not pos then return end
  local px, py = pos:GetXY()
  if zone == cont then return px, py end
  local l, r, t, b = C_Map.GetMapRectOnMap(zone, cont)
  if l then return l + px * (r - l), t + py * (b - t) end
end
local elapsed = 0
mm:SetScript("OnUpdate", function(self, dt)
  elapsed = elapsed + (dt or 0)
  if elapsed < 0.1 then return end
  elapsed = 0
  local cont = target and continents()[target[1]]
  local px, py, wy, hy -- (niente "a and f()": taglierebbe i valori restituiti a uno solo)
  if cont then px, py = playerOn(cont) end
  if cont and C_Map.GetMapWorldSize then wy, hy = C_Map.GetMapWorldSize(cont) end
  if not (px and wy and wy > 0 and hy) then mmT:SetAlpha(0); return end
  mmT:SetAlpha(1)
  local tx, ty = xy(target)
  local dx, dy = (tx - px) * wy, (ty - py) * hy -- yard, x verso est, y verso sud
  local dist = math.sqrt(dx * dx + dy * dy)
  if dist < 8 then say(T.pinHere:format(target[4])); target = nil; self:Hide(); return end
  -- ponytail: minimappa non ruotata (impostazione di base); con "Ruota minimappa" il punto va ruotato con GetPlayerFacing
  local r = Minimap:GetWidth() / 2
  local k = r / ((MMY[(Minimap:GetZoom() or 0) + 1] or 466.67) / 2)
  local ox, oy = dx * k, -dy * k
  local d = math.sqrt(ox * ox + oy * oy)
  if d > r - 6 then ox, oy = ox * (r - 6) / d, oy * (r - 6) / d end -- fuori portata: resta sul bordo, nella direzione giusta
  self:ClearAllPoints(); self:SetPoint("CENTER", Minimap, "CENTER", ox, oy)
end)
setTarget = function(p)
  target = p
  paintPin(mmT, p)
  local cont = continents()[p[1]]
  local gx, gy = xy(p)
  local zone, zx, zy
  if p.zm then
    zone, zx, zy = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(p.zm), p.zx, p.zy
    if zone then zone.mapID = zone.mapID or p.zm end
  else
    zone = cont and C_Map and C_Map.GetMapInfoAtPosition and C_Map.GetMapInfoAtPosition(cont, gx, gy)
    zx, zy = gx, gy
    if zone then zx, zy = onMap(zone.mapID, cont, gx, gy) end
  end
  say(T.pinSet:format(p[4], zone and zone.name or "", (zx or 0) * 100, (zy or 0) * 100))
  if zone and zx and C_Map.CanSetUserWaypointOnMap and C_Map.CanSetUserWaypointOnMap(zone.mapID) and UiMapPoint then
    C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(zone.mapID, zx, zy))
    if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then C_SuperTrack.SetSuperTrackedUserWaypoint(true) end
    mm:Hide()
  else
    mm:Show()
  end
end

-- una voce si spunta quando tutte le sue quest sono consegnate (viste consegnare dall'addon o già fatte secondo Questie)
-- o, per le voci Trainer, quando conosci già tutte le sue spell.
-- quiet: all'avvio e quando cambiano le spell una riga sola col conteggio, invece di una per voce
-- Flight Path conosciuti: salvati ogni volta che si apre la mappa dei voli (anche quando ne impari uno nuovo); in più quelli di
-- C_TaxiMap.GetTaxiNodesForMap sui continenti, ma solo se il gioco segna anche i non conosciuti (stato 2), sennò non distingue
local function fpSave()
  for i = 1, (NumTaxiNodes and NumTaxiNodes() or 0) do
    local n = TaxiNodeName(i)
    if n and TaxiNodeGetType(i) ~= "NONE" then C.fp[n] = true end
  end
end
local function fpKnown()
  local k, got, unk = {}, {}, false
  for n in pairs(C.fp) do k[#k + 1] = n:lower() end
  if C_TaxiMap and C_TaxiMap.GetTaxiNodesForMap then
    for _, m in pairs(continents()) do
      local ok, nodes = pcall(C_TaxiMap.GetTaxiNodesForMap, m)
      for _, nd in ipairs(ok and type(nodes) == "table" and nodes or {}) do
        if nd.state == 2 then unk = true elseif nd.name then got[#got + 1] = nd.name:lower() end
      end
    end
  end
  if unk then for _, n in ipairs(got) do k[#k + 1] = n end end
  return k
end
-- "Flight Path: Thelsamar" o "Flight Path: Splintertree Post (Vhulgra), Zoram'gar (Andruk)": tutti conosciuti? Il gioco li chiama
-- "Thelsamar, Loch Modan", "Zoram'gar Outpost, Ashenvale": basta che il nome del gioco cominci con quello della guida
local function fpDone(text, known)
  local list = text:match("Flight Path:%s*(.*)")
  if not list then return false end
  local all, any = true, false
  for nm in list:gsub("<[^>]*>", ""):gsub("%b()", ""):gmatch("[^,]+") do
    nm = nm:match("^%s*(.-)%s*$"):lower()
    if nm ~= "" then
      any = true
      local hit = false
      for _, g in ipairs(known) do if g:sub(1, #nm) == nm then hit = true end end
      all = all and hit
    end
  end
  return any and all
end
local function tick(quiet)
  local g, k, v = guide()
  if not g then return end
  local n, bk, tp, fk = 0, book(), nil, nil
  for _, t in ipairs(v._tasks) do
    local L = LINKS[t[4]]
    if not C.done[k .. ":" .. t[5]] then
      local all, sp = false, on("trainer") and trainerList(t[3])
      if on("quests") and L and L.q[1] then
        all = not L.any -- any: una sola basta (lettere di classe: ognuno fa solo la sua)
        for _, q in ipairs(L.q) do
          local d = C.turned[q] or qDone(q)
          if L.any then all = all or d else all = all and d end
        end
      elseif sp and sp[1] then
        all = true
        for _, s in ipairs(sp) do all = all and known(s, bk) end
      elseif t[3]:find("Flight Path:", 1, true) then
        fk = fk or fpKnown()
        all = fpDone(t[3], fk)
      elseif on("tal") and t[3]:gsub("^%^[^%^]*%^", ""):find("^Talent:") then
        -- voce Talent del livello L = punto numero L-9 dell'ordine della guida: spuntata quando ne hai spesi almeno tanti
        tp = tp or { talentPoints() }
        if tp[3] then for i, x in ipairs(v._tal) do if x[1] == t[1] then all = tp[1] >= i end end end
      end
      if all then
        C.done[k .. ":" .. t[5]] = true; n = n + 1
        if not quiet then say(T.ticked:format(t[3]:gsub("^%^[^%^]*%^", ""):sub(1, 90))) end
      end
    end
  end
  if quiet and n > 0 then say(T.qSync:format(n)) end
end
-- quest consegnata: segna la consegna (anche senza Questie pronto) e ricontrolla le voci
local function turnedIn(questID)
  local title = idTitle[questID] or (C_QuestLog and C_QuestLog.GetQuestInfo and C_QuestLog.GetQuestInfo(questID))
  if not title then return end
  C.turned[title] = true
  tick()
end

-- finestra dei talenti di Blizzard: bordo luminoso sul talento da prendere (o sulla sua scheda, se è in un altro albero)
local glow = CreateFrame("Frame", nil, UIParent); glow:Hide()
local glowT = glow:CreateTexture(nil, "OVERLAY"); glowT:SetAllPoints(); glowT:SetTexture("Interface\\Buttons\\UI-ActionButton-Border"); glowT:SetBlendMode("ADD")
local function talentUI() return (_G.TalentFrame and "TalentFrame") or (_G.PlayerTalentFrame and "PlayerTalentFrame") end
local function talentGlow()
  glow:Hide()
  local pre = talentUI()
  if not (C and pre and on("tal") and _G[pre]:IsShown()) then return end
  local g, _, v = guide()
  if not g then return end
  local spent, _, src = talentPoints()
  if src ~= "tabs" then return end -- ponytail: finestra dei talenti moderna (Forever) senza bordo luminoso; servirebbero i suoi pulsanti per nodo
  local want = v._tal[spent + 1]
  if not want then return end
  local tf = _G[pre]
  local sel = (PanelTemplates_GetSelectedTab and PanelTemplates_GetSelectedTab(tf)) or tf.selectedTab or 1
  for tabI = 1, GetNumTalentTabs() do
    for i = 1, (GetNumTalents(tabI) or 0) do
      if GetTalentInfo(tabI, i) == want[2] then
        local b = tabI == sel and _G[pre .. "Talent" .. i] or _G[pre .. "Tab" .. tabI]
        if b then
          glow:SetParent(b); glow:SetFrameLevel(b:GetFrameLevel() + 5)
          glow:ClearAllPoints(); glow:SetPoint("CENTER", b, "CENTER"); glow:SetSize(b:GetWidth() * 1.9, b:GetHeight() * 1.9); glow:Show()
        end
        return
      end
    end
  end
end

-- trainer: spell della guida fino al tuo livello (voci "Trainer: A, B") che il trainer ha disponibili
local function wanted()
  local g, _, v = guide()
  local w = {}
  if not g then return w end
  for _, t in ipairs(v._tasks) do
    if t[1] <= UnitLevel("player") then
      for _, n in ipairs(trainerList(t[3]) or {}) do w[n] = true end
    end
  end
  return w
end
local stars = {}
local function trainerMarks()
  for _, s in pairs(stars) do s:Hide() end
  if not (C and on("trainer") and GetNumTrainerServices) then return end
  local w = wanted()
  for i = 1, 30 do
    local b = _G["ClassTrainerSkill" .. i]
    if not b then break end
    local name, _, cat = GetTrainerServiceInfo(b:GetID())
    if b:IsShown() and cat == "available" and w[name] then
      local s = stars[i]
      if not s then s = b:CreateTexture(nil, "OVERLAY"); s:SetTexture("Interface\\AddOns\\ForeverPathfinder\\icon"); s:SetSize(14, 14); s:SetPoint("RIGHT", b, "RIGHT", -4, 0); stars[i] = s end
      s:Show()
    end
  end
end
local function trainerSay()
  if not (C and on("trainer") and GetNumTrainerServices) then return end
  local w, buy = wanted(), {}
  for i = 1, GetNumTrainerServices() do
    local name, sub, cat = GetTrainerServiceInfo(i)
    if cat == "available" and w[name] then buy[#buy + 1] = name .. (sub and sub ~= "" and " (" .. sub .. ")" or "") end
  end
  if #buy > 0 then say(T.trainerBuy:format(table.concat(buy, ", "))) end
end
-- le finestre di Blizzard si caricano solo quando servono: aggancio quando arrivano
local hooked = {}
local function hookBlizzard()
  if not hooked.tal and talentUI() then
    hooked.tal = true
    _G[talentUI()]:HookScript("OnShow", talentGlow)
    for _, fn in ipairs({ "TalentFrame_Update", "PlayerTalentFrame_Update" }) do if _G[fn] then hooksecurefunc(fn, talentGlow) end end
  end
  if not hooked.tr and _G.ClassTrainerFrame_Update then hooked.tr = true; hooksecurefunc("ClassTrainerFrame_Update", trainerMarks) end
end

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("CHARACTER_POINTS_CHANGED")
for _, e in ipairs({ "TRAIT_CONFIG_UPDATED", "TRAIT_NODE_CHANGED", "PLAYER_TALENT_UPDATE" }) do pcall(f.RegisterEvent, f, e) end
for _, e in ipairs({ "QUEST_LOG_UPDATE", "QUEST_TURNED_IN", "TRAINER_SHOW", "SPELLS_CHANGED", "TAXIMAP_OPENED" }) do pcall(f.RegisterEvent, f, e) end
f:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" then
    if arg1 ~= ADDON then hookBlizzard(); return end
    ForeverPathfinderChar = ForeverPathfinderChar or {}
    ForeverPathfinderDB = ForeverPathfinderDB or {}
    C, DB = ForeverPathfinderChar, ForeverPathfinderDB
    C.done = C.done or {}
    C.opt = C.opt or {}
    C.loads = (C.loads or 0) + 1 -- /fp debug: se dopo un /reload resta 1, il gioco non rilegge i salvataggi
    C.turned = C.turned or {} -- titoli delle quest consegnate
    C.fp = C.fp or {} -- Flight Path conosciuti, visti sulla mappa dei voli
    minimapIcon()
    setLang(DB.lang or "en")
    hookBlizzard()
    return
  elseif event == "PLAYER_LOGIN" then
    say(T.loaded)
    if not guide() then say(T.unknown) end
    scanLog()
    -- Questie pronto: spunta le voci con quest già consegnate (anche prima di installare l'addon)
    if _G.Questie and Questie.API and Questie.API.RegisterOnReady then
      Questie.API.RegisterOnReady(function() tick(true); if f:IsShown() then render() end end)
    else
      say(T.qOff)
    end
    return
  elseif event == "PLAYER_LEVEL_UP" then
    viewCh = nil
  elseif event == "QUEST_LOG_UPDATE" then
    scanLog()
  elseif event == "QUEST_TURNED_IN" then
    turnedIn(arg1)
  elseif event == "SPELLS_CHANGED" then
    if not C then return end
    BOOK = nil; tick(true)
  elseif event == "TAXIMAP_OPENED" then
    if not C then return end
    fpSave(); tick()
  elseif event == "TRAINER_SHOW" then
    hookBlizzard(); trainerSay(); return
  elseif event == "CHARACTER_POINTS_CHANGED" or event == "TRAIT_CONFIG_UPDATED" or event == "TRAIT_NODE_CHANGED" or event == "PLAYER_TALENT_UPDATE" then
    if C then tick(true) end
    talentGlow()
  end
  if f:IsShown() then render(event == "PLAYER_LEVEL_UP") end
  drawMapPins()
end)

SLASH_FOREVERPATHFINDER1 = "/fp"
SLASH_FOREVERPATHFINDER2 = "/pathfinder"
SlashCmdList.FOREVERPATHFINDER = function(msg)
  local cmd, arg = (msg or ""):lower():match("^%s*(%S*)%s*(.-)%s*$")
  if cmd == "set" then
    if D[arg] and arg:find("-", 1, true) then C.key = arg; say(D[arg].name) else say(T.unknown) end
  elseif cmd == "auto" then
    C.key = nil
  elseif cmd == "list" then
    local keys = {}
    for key in pairs(D) do if key:sub(1, 1) ~= "_" then keys[#keys + 1] = key end end -- solo le combinazioni razza-classe
    table.sort(keys); say(table.concat(keys, ", ")); return
  elseif cmd == "opzioni" or cmd == "options" or cmd == "config" then
    open("opzioni"); return
  elseif cmd == "dungeon" or cmd == "dungeons" or cmd == "dg" then
    -- in chat: per ogni dungeon del tuo livello giudizio, ingresso, quest da prendere prima
    local g, k = guide()
    if not g then say(T.unknown); return end
    local lv = UnitLevel("player")
    local ds = dungeonsAt(g, lv)
    if #ds == 0 then say(T.dgNone:format(lv)); return end
    local cls = k:match("-(%a+)$")
    for _, d in ipairs(ds) do
      say("|cffa9e4ff" .. dgLabel(d) .. "|r " .. d[6])
      if d[7] ~= "" then DEFAULT_CHAT_FRAME:AddMessage("  " .. T.dgEntry:format(d[7])) end
      DEFAULT_CHAT_FRAME:AddMessage("  " .. T.dgQuests)
      for _, q in ipairs(d[8]) do DEFAULT_CHAT_FRAME:AddMessage("   - |cffffd100" .. q[1] .. "|r: " .. q[2]) end
      for _, q in ipairs(d[9]) do if q[2] == cls then DEFAULT_CHAT_FRAME:AddMessage("   - |cffffd100" .. q[1] .. "|r " .. T.dgClass .. ": " .. q[3]) end end
    end
    return
  elseif cmd == "cerca" or cmd == "find" or cmd == "search" then
    -- cerca il testo in tutte le voci della guida: le prime 8 in chat, il Percorso si apre sulla tappa della prima
    local g, _, v = guide()
    if not g then say(T.unknown); return end
    local hits, seen = {}, {}
    for _, t in ipairs(v._tasks) do
      if arg ~= "" and not seen[t[4]] and t[3]:lower():find(arg, 1, true) then seen[t[4]] = true; hits[#hits + 1] = t end
    end
    if #hits == 0 then say(T.notFound:format(arg)); return end
    say(T.found:format(#hits, arg))
    for i = 1, math.min(8, #hits) do DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100" .. T.lv .. " " .. hits[i][1] .. "|r " .. hits[i][3]:sub(1, 140)) end
    tab = "livello"; f:Show(); viewCh = hits[1][2]; render(true); return
  elseif cmd == "debug" then
    -- tutto ciò che va controllato nel gioco vero, in poche righe da fotografare: versioni, token di razza e classe, talenti, salvataggi
    local meta = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    local ver, build, _, toc = GetBuildInfo()
    local rl, rt = UnitRace("player")
    local _, ct = UnitClass("player")
    local tabs = {}
    local tsp, tfr, tsrc = talentPoints()
    tabs[1] = tostring(tsp) .. " (" .. tostring(tsrc or "-") .. ")"
    local done = 0
    for _ in pairs(C.done) do done = done + 1 end
    say("v" .. tostring(meta and meta(ADDON, "Version")) .. " · client " .. tostring(ver) .. " (" .. tostring(build) .. ") · Interface " .. tostring(toc) .. " · " .. GetLocale())
    DEFAULT_CHAT_FRAME:AddMessage("  UnitRace " .. tostring(rl) .. " / " .. tostring(rt) .. " · UnitClass " .. tostring(ct) .. " · " .. tostring(UnitFactionGroup("player")) .. " · " .. T.level:format(UnitLevel("player")))
    DEFAULT_CHAT_FRAME:AddMessage("  " .. T.dbgGuide:format(charKey() or "?", C.key and T.dbgHand or T.dbgAuto))
    DEFAULT_CHAT_FRAME:AddMessage("  " .. T.dbgTal:format(table.concat(tabs, "/"), tfr))
    DEFAULT_CHAT_FRAME:AddMessage("  " .. T.dbgSave:format(C.loads, done))
    local cs, nq = continents(), 0
    for _ in pairs(inLog) do nq = nq + 1 end
    DEFAULT_CHAT_FRAME:AddMessage("  " .. T.dbgLinks:format("k" .. tostring(cs.k) .. " e" .. tostring(cs.e) .. " z" .. tostring(cs.z),
      (C_Map and C_Map.SetUserWaypoint) and T.yes or T.no, tostring(talentUI() or "-"), nq))
    local book, nb, miss, mt = spellBook(), 0, {}, nil
    for _ in pairs(book) do nb = nb + 1 end
    local g2, k2, v2 = guide()
    for _, t in ipairs(g2 and v2._tasks or {}) do
      local sp = trainerList(t[3])
      if sp and t[1] <= UnitLevel("player") and not C.done[k2 .. ":" .. t[5]] then
        for _, s in ipairs(sp) do if not known(s, book) then miss[#miss + 1] = s end end
        mt = t[1]; break
      end
    end
    DEFAULT_CHAT_FRAME:AddMessage("  " .. T.dbgSpell:format(nb, mt and T.level:format(mt) or "-", #miss > 0 and table.concat(miss, ", ") or "-"))
    DEFAULT_CHAT_FRAME:AddMessage("  " .. T.dbgAddons:format(QZ() and T.yes or (loaded("Questie") and "…" or T.no), loaded("OneForAll") and T.yes or T.no, loaded("MapUtils") and T.yes or T.no))
    return
  elseif cmd == "lang" or cmd == "lingua" or cmd == "language" then
    setLang(arg == "it" and "it" or arg == "en" and "en" or (LANG == "it" and "en" or "it")); return
  elseif cmd == "help" or cmd == "?" then
    say(T.help); return
  elseif f:IsShown() then
    f:Hide(); return
  end
  open()
end
