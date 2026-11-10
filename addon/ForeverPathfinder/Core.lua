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
    dungeon = "Dungeon: %s · /fp dungeon per le quest", go = "vai", opt = "facoltativo", skip = "da saltare",
    dgAll = "‹ Tutti i dungeon", dgPick = "Clic su un dungeon: quest, boss, come arrivarci. ★ = nuovo in Forever.", dgYou = "adatto al tuo livello", dgLv = "Livelli %d–%d",
    dgIdeal = "ideale %s", dgWhere = "Dove si trova", dgKey = "Chiave d'ingresso", dgQ = "Quest da prendere prima di entrare", dgQC = "Quest di classe",
    dgNoQ = "Nessuna quest nei dati per la tua fazione.", dgFrom = "Da: %s", dgChainTip = "Mostra sulla mappa il prossimo passo della catena",
    dgBoss = "Boss", dgTips = "Consigli", dgInfo = "Come conviene farli", dgNote = "Nota", qDoneTag = "fatta", dgNew = "nuovo in Forever", oTrainers = "Tutti i trainer della tua classe sulla mappa del mondo",
    talTitle = "Talent · %s", talLv = "Livello %d", talMine = "Il mio livello (%d)", talNow = "Al livello %d prendi: {%s} %d/%d", talNext = "Poi, al %d: %s",
    talFrom10 = "I talenti cominciano al livello 10: qui vedi cosa prenderai.", talDone = "Build completa: dopo il %d non ci sono altri punti.", talWhy = "Perché questa build", talHide = "Nascondi",
    talTrees = "Passa sopra un talento per la descrizione; clic per andare al livello in cui si prende.", talOrder = "Ordine dei talenti (clic per andare a quel livello)",
    cRot = "Rotazione", cSpells = "Spell", cRace = "Razza", cNotes = "Consigli", cRotPick = "Scegli la situazione (all'apertura quella del tuo livello):",
    cSpNow = "Da comprare e prossime", cSpAll = "Tutte", cSpNone = "Niente da comprare adesso: torna dal trainer tra qualche livello.", cBuy = "da comprare", cHave = "appresa",
    cSoon = "al liv. %d", cTal = "talent", cSpTip = "Passa sopra una spell per la descrizione.", cStats = "Stats e armi", cForever = "Novità di Forever",
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
    oLate = "Dal 30 al 60", oLateTxt = "Il percorso dal 30 al 60 è fatto di tappe per zona, prese da guide non ancora provate in gioco: lo aggiorneremo quando ci saranno informazioni più attendibili.",
    oLinks = "Collegamenti col gioco", oMap = "Segnaposti della tappa sulla mappa del mondo; dal segnaposto di una voce, anche sulla minimappa",
    oQuests = "Spunta da sola le voci quando consegni la quest e mostra le quest che hai nel registro",
    oTal = "Evidenzia il talento da prendere nella finestra dei talenti", oTrainer = "Al trainer scrive e segna gli spell della guida da comprare",
    oEnglish = "Quest, talenti e spell si riconoscono per nome inglese: funzionano con il gioco in inglese.",
    inLog = "nel registro", toTurn = "da consegnare", pinSet = "Segnaposto: %s · %s %.1f, %.1f", pinHere = "Sei arrivato: %s",
    pinTip = "Mostra sulla mappa e sulla minimappa", trainerBuy = "Da comprare secondo la guida: %s", ticked = "Spuntata nella guida: %s",
    dbgLinks = "Continenti %s · segnaposto del gioco %s · finestra talenti %s · quest nel registro %d", yes = "sì", no = "no",
    qMap = "Mostra la quest sulla mappa", qMapTip = "Apre la mappa sul punto, con il segnaposto evidenziato: chi la dà o, se è nel registro, l'obiettivo o la consegna più vicina",
    qInfo = "Scheda della quest", qInfoTip = "Apre la quest nel Journey di Questie", qWait = "Questie si sta ancora caricando: riprova tra un momento.",
    qOff = "Questie non è attivo: spunte automatiche, mappa e schede delle quest passano da Questie.", qSync = "Spuntate %d voci già fatte (quest consegnate, spell già apprese o talenti spesi).",
    ofa = "Apri in OneForAll", ofaTip = "Carica questa build (fino al 60) nel calcolatore dei talenti di OneForAll",
    ofaFail = "OneForAll non ha caricato la build da solo: copiala con Ctrl+C e incollala in Import.",
    dgMap = "Mappa", dgMapTip = "Apre la mappa del mondo sull'ingresso, con il segnaposto", dgMapMU = "Clic sull'icona d'ingresso di MapUtils: si apre la mappa interna del dungeon",
    dgLoot = "Boss e loot", dgLootTip = "Apre il dungeon in OneForAll (boss, loot, quest)",
    dbgSpell = "Spell nel libro: %d · voce Trainer %s, mancano: %s",
    dbgAddons = "Addon collegati: Questie %s · OneForAll %s · MapUtils %s",
    behind = "Rimaste indietro (%d)", behindMore = "e altre %d: le trovi tornando indietro con <",
    qNoPoint = "Questie non ha un punto sulla mappa per %s (comincia da un oggetto o da un mostro).", pinSetQ = "%s: %s · %s %.1f, %.1f", pinOn = "Clic: segnaposto qui", pinOff = "Clic: togli il segnaposto",
    dgNext = "prossima", dgThis = "quest del dungeon", dgStep = "passo %d di %d", dgNowDo = "Adesso:", dgGo = "vai da {%s}",
    dgDo = "completa {%s}", dgTurn = "consegna {%s}",
    dgSteps = "Tutti i passi", dgStepsHide = "Nascondi i passi", dgGLog = "Nel registro", dgGLock = "Da sbloccare", dgGTake = "Puoi prenderle subito", dgGDone = "Fatte",
    dgQSum = "Quest:", dgQLog = "%d nel registro", dgQDone = "%d fatte", dgQDone1 = "1 fatta", dgQTake = "%d da prendere", dgQn = "quest %d/%d",
    dgNeedKey = "serve una chiave", dgNow = "Adatti al tuo livello adesso (liv. %d)", dgAllT = "Tutti i dungeon", dgSecQ = "Quest", dgSecWhere = "Come arrivarci",
    pNone = "Il personaggio non ha ancora profession. Consigliate per la tua classe:", pBrowse = "Tutte le profession (clic per vedere il percorso):", pOthers = "Altre ›",
    pSkill = "Skill %d/%d", pNotYours = "Non ce l'hai: il percorso parte da 1.", pHere = "sei qui", pApp = "Impara {Apprentice} (skill fino a 75)",
    pLearn = "Impara {%s} prima di %d · liv. %d, skill %d", pHow = "Si impara con %s", pTrainer = "Trainer più vicino sulla mappa", pShop = "Lista della spesa da %d a 300",
    pMore = "Novità di Forever, camp e gold", pHide = "Nascondi", pBag = "Tra parentesi quanti ne hai (borse e banca).", pVendor = "vendor",
    pMapT = "Trainer delle tue profession sulla mappa del mondo", pMapV = "Reagent vendor dei materiali delle tue profession sulla mappa del mondo (da Questie)",
    pCap = "%s %d/%d: impara %s prima di andare avanti (%s).", pCapT = "trainer: %s", pOfaTip = "Apre la ricetta in OneForAll (fonti, chi la conosce, skill-up)",
    pVendT = "Reagent vendor", pCamp = "Camping", pGold = "Gold",
  },
  en = {
    level = "Lvl %d", stageWord = "STAGE", build = "Build: %s",
    talentNow = "Talent to take now: %s (%s)", talentNext = "Next talent at lvl %d: %s (%s)", talentDone = "Guide talents done.",
    unknown = "Race or class not recognized. Type /fp set race-class (e.g. /fp set human-warrior); /fp list for the list.",
    help = "/fp opens or closes · /fp options · /fp dungeon · /fp find word · /fp set race-class · /fp auto · /fp list · /fp lang · /fp debug",
    dungeon = "Dungeon: %s · /fp dungeon for the quests", go = "go", opt = "optional", skip = "skip",
    dgAll = "‹ All dungeons", dgPick = "Click a dungeon: quests, bosses, how to get there. ★ = new in Forever.", dgYou = "right for your level", dgLv = "Levels %d–%d",
    dgIdeal = "best at %s", dgWhere = "Where it is", dgKey = "Entry key", dgQ = "Quests to pick up before going in", dgQC = "Class quests",
    dgNoQ = "No quests in the data for your faction.", dgFrom = "From: %s", dgChainTip = "Shows the next step of the chain on the map",
    dgBoss = "Bosses", dgTips = "Tips", dgInfo = "How to run them", dgNote = "Note", qDoneTag = "done", dgNew = "new in Forever", oTrainers = "All your class trainers on the world map",
    talTitle = "Talents · %s", talLv = "Level %d", talMine = "My level (%d)", talNow = "At level %d take: {%s} %d/%d", talNext = "Then, at %d: %s",
    talFrom10 = "Talents start at level 10: here you see what you will take.", talDone = "Build complete: no more points after %d.", talWhy = "Why this build", talHide = "Hide",
    talTrees = "Hover a talent for its description; click to go to the level where you take it.", talOrder = "Talent order (click to go to that level)",
    cRot = "Rotation", cSpells = "Spells", cRace = "Race", cNotes = "Tips", cRotPick = "Pick the situation (it opens on your level):",
    cSpNow = "To buy and next", cSpAll = "All", cSpNone = "Nothing to buy now: go back to the trainer in a few levels.", cBuy = "to buy", cHave = "learned",
    cSoon = "at lvl %d", cTal = "talent", cSpTip = "Hover a spell for its description.", cStats = "Stats and weapons", cForever = "New in Forever",
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
    oLate = "From 30 to 60", oLateTxt = "The route from 30 to 60 is made of zone stages, taken from guides not yet tested in game: we will update it when more reliable information is available.",
    oLinks = "Game links", oMap = "Stage waypoints on the world map; from an item's waypoint, on the minimap too",
    oQuests = "Ticks items by itself when you turn in the quest and shows the quests in your log",
    oTal = "Highlights the talent to take in the talent window", oTrainer = "At the trainer, prints and marks the guide spells to buy",
    oEnglish = "Quests, talents and spells are recognized by their English name: they work with the game in English.",
    inLog = "in your log", toTurn = "ready to turn in", pinSet = "Waypoint: %s · %s %.1f, %.1f", pinHere = "You have arrived: %s",
    pinTip = "Show on the map and the minimap", trainerBuy = "To buy according to the guide: %s", ticked = "Ticked in the guide: %s",
    dbgLinks = "Continents %s · game waypoint %s · talent window %s · quests in log %d", yes = "yes", no = "no",
    qMap = "Show the quest on the map", qMapTip = "Opens the map on the spot, with the highlighted waypoint: who gives it or, if it is in your log, the nearest objective or turn-in",
    qInfo = "Quest details", qInfoTip = "Opens the quest in Questie's Journey", qWait = "Questie is still loading: try again in a moment.",
    qOff = "Questie is not active: automatic ticks, map and quest details go through Questie.", qSync = "Ticked %d items already done (quests turned in, spells already learned or talents spent).",
    ofa = "Open in OneForAll", ofaTip = "Loads this build (up to 60) into OneForAll's talent calculator",
    ofaFail = "OneForAll did not load the build by itself: copy it with Ctrl+C and paste it into Import.",
    dgMap = "Map", dgMapTip = "Opens the world map on the entrance, with the waypoint", dgMapMU = "Click MapUtils' entrance icon: the dungeon's own map opens",
    dgLoot = "Bosses and loot", dgLootTip = "Opens the dungeon in OneForAll (bosses, loot, quests)",
    dbgSpell = "Spells in the spellbook: %d · Trainer item %s, missing: %s",
    dbgAddons = "Linked addons: Questie %s · OneForAll %s · MapUtils %s",
    behind = "Left behind (%d)", behindMore = "and %d more: go back with < to find them",
    qNoPoint = "Questie has no map point for %s (it starts from an item or a monster).", pinSetQ = "%s: %s · %s %.1f, %.1f", pinOn = "Click: waypoint here", pinOff = "Click: remove the waypoint",
    dgNext = "next", dgThis = "the dungeon quest", dgStep = "step %d of %d", dgNowDo = "Now:", dgGo = "go to {%s}",
    dgDo = "complete {%s}", dgTurn = "turn in {%s}",
    dgSteps = "All steps", dgStepsHide = "Hide the steps", dgGLog = "In your log", dgGLock = "To unlock", dgGTake = "You can pick these up now", dgGDone = "Done",
    dgQSum = "Quests:", dgQLog = "%d in your log", dgQDone = "%d done", dgQDone1 = "1 done", dgQTake = "%d to pick up", dgQn = "quests %d/%d",
    dgNeedKey = "needs a key", dgNow = "Right for your level now (lvl %d)", dgAllT = "All dungeons", dgSecQ = "Quests", dgSecWhere = "How to get there",
    pNone = "This character has no professions yet. Recommended for your class:", pBrowse = "All professions (click to see the route):", pOthers = "Others ›",
    pSkill = "Skill %d/%d", pNotYours = "You do not have it: the route starts at 1.", pHere = "you are here", pApp = "Learn {Apprentice} (skill up to 75)",
    pLearn = "Learn {%s} before %d · lvl %d, skill %d", pHow = "Learned with %s", pTrainer = "Nearest trainer on the map", pShop = "Shopping list from %d to 300",
    pMore = "New in Forever, camp and gold", pHide = "Hide", pBag = "In brackets how many you have (bags and bank).", pVendor = "vendor",
    pMapT = "Your profession trainers on the world map", pMapV = "Reagent vendors for your professions' materials on the world map (from Questie)",
    pCap = "%s %d/%d: learn %s before going on (%s).", pCapT = "trainer: %s", pOfaTip = "Opens the recipe in OneForAll (sources, who knows it, skill-ups)",
    pVendT = "Reagent vendor", pCamp = "Camping", pGold = "Gold",
  },
}
local T = TT.en

-- token inglese di UnitRace → chiave del sito (Skyborne: una per fazione)
local RACES = { Human = "human", Dwarf = "dwarf", Gnome = "gnome", NightElf = "nightelf", Orc = "orc", Troll = "troll", Tauren = "tauren", Scourge = "undead", Undead = "undead" }

local C  -- ForeverPathfinderChar: { done = {}, key = "razza-classe" scelto a mano, opt = { b, dg, x }, loads }
local DB -- ForeverPathfinderDB (tutti i personaggi): { angle, hide } dell'icona sulla minimappa
local tab, viewCh = "livello" -- scheda aperta, tappa mostrata nel Percorso
-- stato delle schede (una tabella sola: Lua ammette 200 variabili locali per file). Dungeon: dgSel nome del dungeon aperto (nil = menu),
-- V.dgSec sezione ("q" quest, "b" boss, "w" come arrivarci, "t" consigli); Talent: V.talLv livello mostrato (nil = il tuo), V.tWhy testo aperto;
-- Classe: V.clsSec sezione, V.rotSel rotazione, V.spAll tutte le spell, V.noteSel consiglio; Profession: V.profSel aperta, V.profAll anche le altre,
-- V.profMore novità aperte, V.profShop lista della spesa aperta
local V = {}

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
local inLog, idTitle, idLog = {}, {}, {} -- idLog: id → "log" o "done" delle quest ora nel registro
local function scanLog()
  for k in pairs(inLog) do inLog[k] = nil end
  for k in pairs(idLog) do idLog[k] = nil end
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
      if questID then idTitle[questID] = title; idLog[questID] = inLog[title] end
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
local mapAt -- segnaposto e mappa del mondo aperta lì (più sotto, con i dungeon)

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
-- punto in una zona del gioco (uiMapID, posizione 0–1) → segnaposto come quelli del sito, con continente e posizione sul continente
local function zonePin(zm, zx, zy, name, sub)
  local p = { nil, 0, 0, name, nil, zm = zm, zx = zx, zy = zy, gx = 0, gy = 0, sub = sub }
  for ck, cid in pairs(continents()) do
    local ok, l, r, t, b = pcall(C_Map.GetMapRectOnMap, zm, cid)
    if ok and l and r ~= l and l >= 0 and r <= 1 and t >= 0 and b <= 1 then p[1] = ck; p.gx, p.gy = l + zx * (r - l), t + zy * (b - t); break end
  end
  return p
end
local function qDoneId(id)
  local done = Questie.db and Questie.db.char and Questie.db.char.complete or {}
  return (done[id] or (C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted and C_QuestLog.IsQuestFlaggedCompleted(id))) and true or false
end
-- dove andare per una quest (1.8), dal database di Questie: se è nel registro l'obiettivo o la consegna più vicina, altrimenti
-- chi la dà (il più vicino a te). Restituisce un segnaposto nostro: così la mappa si apre sulla zona giusta e il punto si vede
local function qPointId(id, name)
  if not (id and QZ()) then return end
  local ok, p = pcall(function()
    local DBQ, DU, Zone = mod("QuestieDB"), mod("DistanceUtils"), mod("ZoneDB")
    local quest = DBQ.GetQuest(id)
    if not quest then return end
    local sp, zone, who
    if idLog[id] then sp, zone, who = DU.GetNearestSpawnForQuest(quest) end
    if not sp then sp, zone, who = DU.GetNearestFinisherOrStarter(quest.Starts or {}) end
    local zm = sp and zone and Zone:GetUiMapIdByAreaId(zone)
    if not zm or zm == 0 then return end
    local pin = zonePin(zm, sp[1] / 100, sp[2] / 100, who or name, name)
    pin.q = { name }
    return pin
  end)
  return ok and p or nil
end
-- pulsante mappa di una quest: segnaposto evidenziato sul punto e mappa del mondo aperta lì; false se Questie non ha un punto
local function qMap(name, id)
  local p = qPointId(id or qPick(name), name)
  if not p then return false end
  return mapAt(p)
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
-- catene (1.8). qFinal(nome) = la quest "vera" di quel nome: più quest di una catena hanno spesso lo stesso nome (The Defias
-- Brotherhood: sei passi), e quella del dungeon è l'ultima, cioè quella che nessun'altra con lo stesso nome richiede.
-- qChain(nome) = tutti i passi dal primo, ognuno { id, nome, "NPC, zona", NPC, zona }; nil se non ha quest richieste prima.
-- ponytail: di un gruppo di quest richieste insieme (preQuestGroup) segue solo la prima; tra le alternative (preQuestSingle)
-- quella fatta o nel registro, altrimenti la prima che Questie dice fattibile
local qFinal, qChain
do
  local function preOf(DBQ, q)
    local pre = DBQ.QueryQuestSingle(q, "preQuestSingle")
    if not (pre and pre[1]) then pre = DBQ.QueryQuestSingle(q, "preQuestGroup") end
    return pre or {}
  end
  local function chainIds(DBQ, id)
    local ids, seen, cur = { id }, { [id] = true }, id
    while #ids < 25 do
      local pre, p = preOf(DBQ, cur), nil
      for _, x in ipairs(pre) do if not p and (qDoneId(x) or idLog[x]) then p = x end end
      for _, x in ipairs(pre) do if not p and DBQ.IsDoable and DBQ.IsDoable(x) then p = x end end
      p = p or pre[1]
      if not p or seen[p] or not DBQ.QueryQuestSingle(p, "name") then break end
      seen[p], cur = true, p
      table.insert(ids, 1, p)
    end
    return ids
  end
  local FINAL = {} -- solo quando la scelta non dipende da cosa hai fatto (un'unica candidata)
  function qFinal(name)
    if FINAL[name] then return FINAL[name] end
    local all = qIDs(name)
    if not (all and all[1]) then return end
    local ok, id, fixed = pcall(function()
      local DBQ, isPre, cands = mod("QuestieDB"), {}, {}
      for _, q in ipairs(all) do for _, x in ipairs(preOf(DBQ, q)) do isPre[x] = true end end
      for _, q in ipairs(all) do if not isPre[q] then cands[#cands + 1] = q end end
      if #cands <= 1 then return cands[1] or all[1], true end
      -- stesso nome per catene diverse (es. una per fazione): quella in cui hai già fatto qualcosa, poi quella che puoi cominciare
      for _, q in ipairs(cands) do for _, x in ipairs(chainIds(DBQ, q)) do if qDoneId(x) or idLog[x] then return q end end end
      for _, q in ipairs(cands) do if DBQ.IsDoable and DBQ.IsDoable(chainIds(DBQ, q)[1]) then return q end end
      return cands[1]
    end)
    if not ok then return all[1] end
    if fixed then FINAL[name] = id end
    return id
  end
  function qChain(name)
    local id = qFinal(name)
    if not id then return end
    local ok, res = pcall(function()
      local DBQ = mod("QuestieDB")
      local ids = chainIds(DBQ, id)
      if #ids < 2 then return end
      local out = {}
      for i, q in ipairs(ids) do
        local by = DBQ.QueryQuestSingle(q, "startedBy") or {}
        local npc = by[1] and by[1][1]
        local who = npc and DBQ.QueryNPCSingle(npc, "name")
        local zid = npc and DBQ.QueryNPCSingle(npc, "zoneID")
        local zone = zid and select(2, pcall(function() return mod("TrackerUtils"):GetZoneNameByID(zid) end))
        if type(zone) ~= "string" then zone = nil end
        out[i] = { q, DBQ.QueryQuestSingle(q, "name"), who and (zone and who .. ", " .. zone or who) or zone, who, zone }
      end
      return out
    end)
    return ok and res or nil
  end
end

-- aspetto del sito: colori di style.css (:root), Cinzel per i titoli, Inter per i testi, riquadri (card) e icone del gioco
local HEX = { bg = "08111d", card = "112236", deep = "0b1828", tx = "e7eef7", mu = "93a6be", ac = "6fc3ff", ice = "a9e4ff",
  gold = "e8b84a", ok = "5fd68b", bd = "21384f", frame = "5a4a22", chip = "173a5c", goldbg = "2a2412" }
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
local P = { fs = {}, ic = {}, rc = {}, ln = {}, cb = {}, bt = {}, pn = {}, hv = {}, nd = {} }
local N = { fs = 0, ic = 0, rc = 0, ln = 0, cb = 0, bt = 0, pn = 0, hv = 0, nd = 0 }
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
  o:SetFontObject(fo); o:SetTextColor(unpack(COL[c])); o:SetJustifyH("LEFT"); put(o, x, y, w); o:SetText(colorize(s))
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
      if not QZ() then say(T.qWait) elseif qMap(q) then return elseif p then mapAt(p) else say(T.qNoPoint:format(q)) end
    end)
    mini("inv_misc_book_09", BW - PAD - 46, y, q, T.qInfoTip, function() if not (QZ() and qInfo(q)) then say(T.qWait) end end)
    right = 54
  elseif p and on("map") then
    mini("inv_misc_map_01", BW - PAD - 20, y, p[4], T.pinTip, function() mapAt(p) end)
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
local target, clearTarget -- segnaposto scelto (evidenziato sulla mappa) e come toglierlo (più sotto, con la minimappa)
local drawMapPins
-- segnaposto e mappa del mondo aperta sulla sua zona (la guida si chiude: la mappa sta sotto); dg = ingresso di un dungeon
mapAt = function(p, dg)
  if dg then focus = p end
  setTarget(p)
  local cont = continents()[p[1]]
  local gx, gy = xy(p)
  local zone = not p.zm and cont and C_Map.GetMapInfoAtPosition and C_Map.GetMapInfoAtPosition(cont, gx, gy)
  local id = p.zm or zone and zone.mapID or cont
  if not id then return end
  if C_Map.OpenWorldMap then C_Map.OpenWorldMap(id) else if not WorldMapFrame:IsShown() then ShowUIPanel(WorldMapFrame) end; WorldMapFrame:SetMapID(id) end
  f:Hide(); drawMapPins()
  return true
end
local function dgMap(p) if mapAt(p, true) and loaded("MapUtils") then say(T.dgMapMU) end end
local function ofaDungeon(name)
  local O = _G.OneForAll
  if not (O and O.DUNGEONS and O.OpenPanel) then return end
  local n = norm(name)
  for _, d in ipairs(O.DUNGEONS) do
    if norm(d.name) == n or (d.short and norm(d.short) == n) then return d end
    for _, a in ipairs(d.aliases or {}) do if norm(a) == n then return d end end
  end
end

-- scheda Dungeon (dalla 1.5): menu con tutti i dungeon della fazione; un clic apre la scheda del dungeon
-- (giudizio, dove si trova, chiave, quest con Questie e la prima quest della catena, boss con i loro consigli)
-- pulsanti che vanno a capo; sel = quello scelto (evidenziato)
local function flow(labels, sel, fn)
  local x = PAD
  for i, l in ipairs(labels) do
    local b = button(l, x, y, function() fn(i) end)
    local w = b:GetWidth()
    if x > PAD and x + w > BW - PAD then x = PAD; y = y - 28; b:ClearAllPoints(); b:SetPoint("TOPLEFT", x, y) end
    if i ~= sel then b.set(false) end
    x = x + w + 6
  end
  y = y - 30
end
local drawDungeons
do
local VCOL = { go = "ok", opt = "gold", skip = "mu" }
local function low(x) return (x:gsub("’", "'"):lower()) end
-- quest di un dungeon per il tuo personaggio: quelle della fazione più quelle della tua classe, { nome, da chi, di classe }
local function dgQuests(d)
  local out, cls = {}, low(select(2, UnitClass("player")) or "")
  for _, q in ipairs(d[8]) do out[#out + 1] = { q[1], q[2] } end
  for _, q in ipairs(d[9]) do if low(q[2]) == cls then out[#out + 1] = { q[1], q[3], true } end end
  return out
end
-- quante ne hai: totale, nel registro, fatte (da Questie)
local function dgCount(d)
  local qs, lg, dn, ready = dgQuests(d), 0, 0, QZ()
  for _, q in ipairs(qs) do
    local fin = ready and qFinal(q[1])
    if inLog[q[1]] then lg = lg + 1 elseif fin and qDoneId(fin) then dn = dn + 1 end
  end
  return #qs, lg, dn
end
-- "Quest: 2 nel registro · 1 fatta · 4 da prendere"
local function dgQuestLine(d)
  local n, lg, dn = dgCount(d)
  if n == 0 then return end
  local parts = {}
  if lg > 0 then parts[#parts + 1] = "|cffa9e4ff" .. T.dgQLog:format(lg) .. "|r" end
  if dn > 0 then parts[#parts + 1] = "|cff5fd68b" .. (dn == 1 and T.dgQDone1 or T.dgQDone:format(dn)) .. "|r" end
  if n - lg - dn > 0 then parts[#parts + 1] = "|cffe8b84a" .. T.dgQTake:format(n - lg - dn) .. "|r" end
  return T.dgQSum .. " " .. table.concat(parts, "  ·  ")
end
-- stato di una quest del dungeon per il tuo personaggio: quest finale, catena, prossimo passo, fatta, da sbloccare (ha passi prima)
local function dgQState(name)
  local fin = QZ() and qFinal(name)
  local ch = fin and qChain(name)
  local nextI
  for i, s in ipairs(ch or {}) do if not nextI and not qDoneId(s[1]) then nextI = i end end
  return { fin = fin, ch = ch, nextI = nextI, done = fin and qDoneId(fin) or false, locked = nextI ~= nil and nextI < #ch }
end
local function toMap(id, nm)
  if not QZ() then say(T.qWait) elseif not qMap(nm, id) then say(T.qNoPoint:format(nm)) end
end
local function clsTag(q) return q[3] and "  |cff93a6be" .. T.dgClass .. "|r" or "" end
-- quest senza passi da fare prima, in una riga: nome e stato, chi la dà; a destra mappa e scheda di Questie
local function questRow(q, s)
  local name = q[1]
  y = y - 8
  local right = 0
  if on("map") then
    mini("inv_misc_map_01", BW - PAD - 20, y, name, T.qMapTip, function() toMap(s.fin or nil, name) end)
    mini("inv_misc_book_09", BW - PAD - 46, y, name, T.qInfoTip, function() if not (QZ() and qInfo(name)) then say(T.qWait) end end)
    right = 54
  end
  local st = inLog[name] == "done" and "  |cff5fd68b[" .. T.toTurn .. "]|r" or inLog[name] and "  |cffa9e4ff[" .. T.inLog .. "]|r" or ""
  local from = q[2] and q[2] ~= "" and "   |cff93a6be" .. q[2] .. "|r" or ""
  local top = y
  local o = str(F.h3, "gold", name .. clsTag(q) .. st .. from, PAD, BW - 2 * PAD - right)
  y = top - math.max(20, o:GetStringHeight() + 2)
end
-- quest da sbloccare (1.8): titolo con "passo n di m", barra a segmenti con "Tutti i passi" a destra, una riga "Adesso" con la sola
-- cosa da fare e il suo pulsante mappa; l'elenco completo dei passi solo a richiesta
local function chainRow(q, s)
  local name, ch, n = q[1], s.ch, s.nextI
  local cur = ch[n]
  y = y - 10
  if on("map") then mini("inv_misc_book_09", BW - PAD - 20, y, name, T.qInfoTip, function() if not (QZ() and qInfo(name)) then say(T.qWait) end end) end
  local o = str(F.h3, "gold", name .. clsTag(q) .. "   |cffa9e4ff" .. T.dgStep:format(n, #ch) .. "|r", PAD, BW - 2 * PAD - 28); y = y - o:GetStringHeight() - 6
  V.dgOpen = V.dgOpen or {}
  local open = V.dgOpen[name]
  local top = y
  local b = button(open and T.dgStepsHide or T.dgSteps, 0, y + 2, function() V.dgOpen[name] = not open; render() end); b.set(open and true or false)
  b:ClearAllPoints(); b:SetPoint("TOPLEFT", BW - PAD - b:GetWidth(), y + 2)
  local sw = math.min(34, math.floor((BW - 2 * PAD - b:GetWidth() - 12 - (#ch - 1) * 3) / #ch))
  for i = 1, #ch do box(i < n and "ok" or i == n and "gold" or "bd", 1, PAD + (i - 1) * (sw + 3), y - 9, sw, 5, true) end
  y = top - 28
  -- Adesso: da chi andare (e dove), o completa / consegna se è già nel registro
  local st = idLog[cur[1]]
  local what = st == "done" and T.dgTurn:format(cur[2]) or st and T.dgDo:format(cur[2])
    or T.dgGo:format(cur[4] or cur[2]) .. (cur[5] and "  |cff93a6be" .. cur[5] .. "|r" or "")
  local bt = y
  y = y - 7
  o = str(F.p, "tx", "|cffe8b84a" .. T.dgNowDo .. "|r   " .. what, PAD + 10, BW - 2 * PAD - 50); y = y - o:GetStringHeight() - 7
  box("goldbg", 1, PAD, bt, BW - 2 * PAD, bt - y, true)
  box("gold", 1, PAD, bt, 2, bt - y, true)
  if on("map") then mini("inv_misc_map_01", BW - PAD - 26, bt - math.floor((bt - y - 20) / 2), cur[2], T.dgChainTip, function() toMap(cur[1], cur[2]) end) end
  y = y - 4
  if not open then return end
  y = y - 4
  for i, x in ipairs(ch) do
    local tag = i < n and "|cff5fd68b[" .. T.qDoneTag .. "]|r"
      or i == n and (st == "done" and "|cff5fd68b[" .. T.toTurn .. "]|r" or st and "|cffa9e4ff[" .. T.inLog .. "]|r" or "|cffe8b84a[" .. T.dgNext .. "]|r")
      or (i == #ch and "|cff93a6be[" .. T.dgThis .. "]|r") or ""
    str(F.small, i == n and "gold" or "mu", tostring(i), PAD + 8, 24)
    local so = str(F.p, i < n and "mu" or "tx", x[2] .. (x[3] and "  |cff93a6be" .. x[3] .. "|r" or "") .. (tag ~= "" and "  " .. tag or ""), PAD + 34, BW - 2 * PAD - 34)
    y = y - math.max(so:GetStringHeight(), 14) - 5
  end
end
-- riga del menu: pulsante del dungeon (★ = nuovo in Forever), livelli e giudizio; nel riquadro "adatti al tuo livello" anche
-- quante quest hai e se serve una chiave, sulla stessa riga
local function dgMenuRow(x, fit, full)
  y = y - 6
  local top = y
  local b = button(x[1] .. (x[15] and " ★" or ""), PAD, y, function() V.dgSel, V.dgSec = x[1], nil; render(true) end)
  local bx = PAD + b:GetWidth() + 10
  local t = x[2] .. "–" .. x[3] .. (x[4] ~= "" and "  ·  " .. (T[x[4]] or x[4]) or "")
  if full then
    local n, lg, dn = dgCount(x)
    if n > 0 then t = t .. "  ·  |cff93a6be" .. T.dgQn:format(lg + dn, n) .. "|r" end
    if x[10] ~= "" then t = t .. "  ·  |cffe8b84a" .. T.dgNeedKey .. "|r" end
  end
  local o = str(F.p, VCOL[x[4]] or "tx", t, bx, BW - PAD - bx); o:SetPoint("TOPLEFT", bx, y - 5)
  y = top - math.max(24, o:GetStringHeight() + 10)
end
function drawDungeons(g)
  local lv, list, fit, d = UnitLevel("player"), DG[g.faction] or {}, {}, nil
  local fits = dungeonsAt(g, lv)
  for _, x in ipairs(fits) do fit[x[1]] = true end
  for _, x in ipairs(list) do if x[1] == V.dgSel then d = x end end
  if not d then
    V.dgSel = nil
    local sorted = {}
    for _, x in ipairs(list) do sorted[#sorted + 1] = x end
    table.sort(sorted, function(a, b) if a[2] ~= b[2] then return a[2] < b[2] end return a[1] < b[1] end)
    -- in cima quelli adatti al tuo livello adesso, con le quest che hai e cosa manca
    cardOpen(); y = y - 12
    line("2", T.dgNow:format(lv))
    local any = false
    for _, x in ipairs(sorted) do if fit[x[1]] then any = true; dgMenuRow(x, true, true) end end
    if not any then line("0", T.dgNone:format(lv)) end
    cardClose()
    cardOpen(); y = y - 12
    line("2", T.dgAllT); line("0", T.dgPick); y = y - 4
    for _, x in ipairs(sorted) do dgMenuRow(x, fit[x[1]]) end
    cardClose()
    if DG.info and #DG.info > 0 then
      cardOpen(); y = y - 12
      line("2", T.dgInfo)
      for _, t in ipairs(DG.info) do line("0", "• " .. t) end
      if DG.glossary and DG.glossary ~= "" then line("0", DG.glossary) end
      cardClose()
    end
    return
  end
  button(T.dgAll, 0, y, function() V.dgSel = nil; render(true) end); y = y - 32
  -- testata: nome, a destra Mappa e Boss e loot, livelli e giudizio, perché, le quest che hai
  local p, od = dgFind(d[1]), ofaDungeon(d[1])
  cardOpen(); y = y - 12
  local top, bxr = y, BW - PAD
  line("1", d[1])
  local function rbtn(label, fn) local b = button(label, 0, top - 2, fn); bxr = bxr - b:GetWidth(); b:ClearAllPoints(); b:SetPoint("TOPLEFT", bxr, top - 2); bxr = bxr - 8 end
  if od then rbtn(T.dgLoot, function() OneForAll:OpenPanel("dungeons"); if OneForAll.UI and OneForAll.UI.OpenDungeon then OneForAll.UI.OpenDungeon(od) end end) end
  if p then rbtn(T.dgMap, function() dgMap(p) end) end
  y = math.min(y, top - 26) - 4
  local vt = d[4] ~= "" and (T[d[4]] or d[4]) .. (d[5] ~= "" and " · " .. T.dgIdeal:format(d[5]) or "") or ""
  local o = str(F.h3, VCOL[d[4]] or "tx", T.dgLv:format(d[2], d[3]) .. (vt ~= "" and "  ·  " .. vt or "") .. (d[15] and "  ·  " .. T.dgNew or "") .. (fit[d[1]] and "  ·  |cff5fd68b" .. T.dgYou .. "|r" or ""), PAD, BW - 2 * PAD)
  y = y - o:GetStringHeight()
  if d[6] ~= "" then line("0", d[6]) end
  local ql = dgQuestLine(d)
  if ql then line("0", ql) end
  -- sezioni a pulsanti, come nella scheda Classe: Quest, Boss, Come arrivarci, Consigli (solo quelle con contenuto)
  local used, loose = {}, 0
  for _, b in ipairs(d[11]) do
    local bn = low(b:gsub("%s*%b()", ""))
    for i, t in ipairs(d[12]) do
      local bold = t:match("{([^}]*)}")
      if not used[i] and bold and bold ~= "" and (low(bold):find(bn, 1, true) or bn:find(low(bold), 1, true)) then used[i] = b end
    end
  end
  for i in ipairs(d[12]) do if not used[i] then loose = loose + 1 end end
  local qs = dgQuests(d)
  local secs = { { "q", T.dgSecQ .. "  " .. #qs } }
  if #d[11] > 0 then secs[#secs + 1] = { "b", T.dgBoss .. "  " .. #d[11] } end
  secs[#secs + 1] = { "w", T.dgSecWhere }
  if loose > 0 then secs[#secs + 1] = { "t", T.dgTips } end
  local sel = 1
  for i, s in ipairs(secs) do if s[1] == V.dgSec then sel = i end end
  local labels = {}
  for i, s in ipairs(secs) do labels[i] = s[2] end
  y = y - 10
  flow(labels, sel, function(i) V.dgSec = secs[i][1]; render() end)
  y = y + 18
  cardClose()
  local sec = secs[sel][1]
  cardOpen(); y = y - 12
  if sec == "q" then
    -- quest a gruppi: nel registro, da sbloccare (con passi prima: riquadro "Adesso"), da prendere subito, fatte (una riga)
    if #qs == 0 then line("0", T.dgNoQ) end
    local G, first = { {}, {}, {}, {} }, true
    for _, q in ipairs(qs) do
      local st = dgQState(q[1])
      local gi = st.done and 4 or st.locked and 2 or inLog[q[1]] and 1 or 3
      G[gi][#G[gi] + 1] = { q, st }
    end
    for gi, title in ipairs({ T.dgGLog, T.dgGLock, T.dgGTake, T.dgGDone }) do
      if #G[gi] > 0 then
        if not first then y = y - 12 end
        first = false
        line("2", title .. "  " .. #G[gi])
        if gi == 4 then
          local names = {}
          for i, e in ipairs(G[gi]) do names[i] = e[1][1] end
          line("0", table.concat(names, "  ·  "))
        else
          for _, e in ipairs(G[gi]) do if gi == 2 then chainRow(e[1], e[2]) else questRow(e[1], e[2]) end end
        end
      end
    end
  elseif sec == "b" then
    -- boss in ordine, ognuno con i consigli che lo nominano in grassetto
    line("2", T.dgBoss)
    for _, b in ipairs(d[11]) do
      line("3", b)
      for i, t in ipairs(d[12]) do if used[i] == b then line("0", "• " .. t) end end
    end
  elseif sec == "w" then
    line("2", T.dgWhere); line("0", d[7] ~= "" and d[7] or d[13])
    if d[10] ~= "" then line("2", T.dgKey); line("0", d[10]) end
    if d[7] == "" and d[14] ~= "" then line("2", T.dgNote); line("0", d[14]) end
    if p then y = y - 8; button(T.dgMap, PAD, y, function() dgMap(p) end); y = y - 26 end
  else
    line("2", T.dgTips)
    for i, t in ipairs(d[12]) do if not used[i] then line("0", "• " .. t) end end
  end
  cardClose()
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

-- schede Talent e Classe (dalla 1.6): dati in ForeverPathfinderTrees (alberi del client) e ForeverPathfinderClass (per lingua)
local function clsData() return ForeverPathfinderClass and (ForeverPathfinderClass[LANG] or ForeverPathfinderClass.en) or {} end
-- zona invisibile con tooltip (spell, racial; item = id di un oggetto: il tooltip del gioco)
local function hover(x, yy, w, h, t1, t2, item)
  local o = take("hv", function()
    local b = CreateFrame("Button", nil, body)
    b:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      if self.item and GameTooltip.SetItemByID then GameTooltip:SetItemByID(self.item) else GameTooltip:AddLine(self.t1); if self.t2 and self.t2 ~= "" then GameTooltip:AddLine(colorize(self.t2), 1, 1, 1, true) end end
      GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return b
  end)
  o.t1, o.t2, o.item = t1, t2, item
  return put(o, x, yy, w, h)
end
-- nodo dell'albero: icona, bordo (oro = talento del livello, verde = con punti, spento = vuoto), rank, tooltip
local function node(ic, x, yy, st, rank, max)
  local o = take("nd", function()
    local b = CreateFrame("Button", nil, body); b:SetSize(30, 30)
    b.tx = b:CreateTexture(nil, "ARTWORK"); b.tx:SetAllPoints(); b.tx:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b.bd = { rect(b, "OVERLAY", "bd", 1, 0, 0, 30, 2), rect(b, "OVERLAY", "bd", 1, 0, -28, 30, 2), rect(b, "OVERLAY", "bd", 1, 0, 0, 2, 30), rect(b, "OVERLAY", "bd", 1, 28, 0, 2, 30) }
    rect(b, "OVERLAY", "bg", 0.85, 12, -19, 20, 12) -- riquadrino scuro del rank, nell'angolo in basso a destra
    b.rk = b:CreateFontString(nil, "OVERLAY"); b.rk:SetFontObject(F.small); b.rk:SetPoint("TOPLEFT", 13, -19); b.rk:SetWidth(19); b.rk:SetJustifyH("CENTER")
    local hl = b:CreateTexture(nil, "HIGHLIGHT"); hl:SetAllPoints(); hl:SetColorTexture(1, 1, 1, 0.15)
    b:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(self.t1); GameTooltip:AddLine(self.t2, 1, 1, 1, true)
      if self.t3 then GameTooltip:AddLine(" "); GameTooltip:AddLine(colorize(self.t3), 0.66, 0.89, 1, true) end
      GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return b
  end)
  o.tx:SetTexture(iconPath(ic)); o.tx:SetDesaturated(st == "off"); o.tx:SetAlpha(st == "off" and 0.4 or 1)
  local c = st == "now" and "gold" or st == "on" and "ok" or "bd"
  for _, t in ipairs(o.bd) do paint(t, c) end
  o.rk:SetText(rank .. "/" .. max); o.rk:SetTextColor(unpack(COL[st == "off" and "mu" or c]))
  return put(o, x, yy)
end

-- Talent: livello scelto (‹ ›), talento di quel livello e perché, i tre alberi con i punti fino a lì, ordine dei talenti
local function drawTalents(g, k, v)
  local cls = k:match("-(%a+)$")
  local CD, trees, list = clsData()[cls] or {}, ForeverPathfinderTrees and ForeverPathfinderTrees[cls] or {}, v._tal
  local me = UnitLevel("player")
  local first, last = list[1] and list[1][1] or 10, list[#list] and list[#list][1] or 10
  local L = math.max(first, math.min(last, V.talLv or me))
  local rk, cur, nxt, maxOf = {}, nil, nil, {}
  for _, tr in ipairs(trees) do for _, nd in ipairs(tr[2]) do maxOf[nd[1]] = nd[5] end end
  for _, t in ipairs(list) do
    if t[1] <= L then rk[t[2]] = (rk[t[2]] or 0) + 1 end
    if t[1] == L then cur = t elseif t[1] > L and not nxt then nxt = t end
  end
  cardOpen(); y = y - 12
  line("1", T.talTitle:format(v.build))
  y = y - 10
  local top = y
  local b1 = button("‹", PAD, y, function() V.talLv = math.max(first, L - 1); render() end)
  local o = str(F.h2, "gold", T.talLv:format(L), PAD + b1:GetWidth() + 10, 90); o:SetPoint("TOPLEFT", PAD + b1:GetWidth() + 10, y - 4)
  local bx = PAD + b1:GetWidth() + 14 + math.max(70, o:GetStringWidth())
  local b2 = button("›", bx, y, function() V.talLv = math.min(last, L + 1); render() end)
  bx = bx + b2:GetWidth() + 10
  if L ~= math.max(first, math.min(last, me)) then button(T.talMine:format(me), bx, y, function() V.talLv = nil; render() end) end
  if _G.OneForAll and OneForAll.TalentCode and OneForAll.OpenPanel then
    local ob = button(T.ofa .. " ↗", 0, y, function() ofaLoad(v) end); ob:ClearAllPoints(); ob:SetPoint("TOPRIGHT", body, "TOPLEFT", BW - PAD, y)
  end
  y = top - 32
  if me < first and not V.talLv then line("0", T.talFrom10) end
  if cur then
    y = y - 2
    local nd
    for _, tr in ipairs(trees) do for _, x in ipairs(tr[2]) do if x[1] == cur[2] then nd = x end end end
    if nd then icon(nd[2], PAD, y - 1, 22) end
    o = str(F.h2, "tx", T.talNow:format(L, cur[2], rk[cur[2]] or 1, maxOf[cur[2]] or 1) .. (cur[3] ~= "" and "  |cff93a6be(" .. cur[3] .. ")|r" or ""), PAD + 28, BW - 2 * PAD - 28)
    y = y - math.max(22, o:GetStringHeight() + 4)
    if CD.why and CD.why[cur[2]] then line("0", CD.why[cur[2]]) end
  elseif L >= last then line("0", T.talDone:format(last)) end
  if nxt then line("0", T.talNext:format(nxt[1], nxt[2])) end
  if CD.summary and CD.summary ~= "" then
    y = y - 8
    button(V.tWhy and T.talHide or T.talWhy, PAD, y, function() V.tWhy = not V.tWhy; render() end); y = y - 28
    if V.tWhy then line("0", CD.summary) end
  end
  cardClose()
  -- alberi uno accanto all'altro, come nel gioco (righe e colonne del client)
  if #trees > 0 then
    cardOpen(); y = y - 12
    line("0", T.talTrees); y = y - 8
    local gap, n, step = 10, #trees, 38
    local tw = math.floor((BW - 2 * PAD - gap * (n - 1)) / n)
    top = y
    local rows = 0
    for i, tr in ipairs(trees) do
      local x0, pts = PAD + (i - 1) * (tw + gap), 0
      for _, nd in ipairs(tr[2]) do pts = pts + math.min(rk[nd[1]] or 0, nd[5]); rows = math.max(rows, nd[3]) end
      y = top
      str(F.h3, pts > 0 and "gold" or "mu", tr[1] .. "  " .. pts, x0, tw)
      local gx = x0 + math.floor((tw - (4 * step - 8)) / 2)
      for _, nd in ipairs(tr[2]) do
        local r = math.min(rk[nd[1]] or 0, nd[5])
        local b = node(nd[2], gx + (nd[4] - 1) * step, top - 22 - (nd[3] - 1) * step, cur and cur[2] == nd[1] and "now" or r > 0 and "on" or "off", r, nd[5])
        b.t1, b.t2, b.t3 = nd[1] .. "  " .. r .. "/" .. nd[5], nd[7], CD.why and CD.why[nd[1]]
        b:SetScript("OnClick", function() for _, t in ipairs(list) do if t[2] == nd[1] then V.talLv = t[1]; render(); return end end end)
      end
    end
    y = top - 22 - rows * step
    cardClose()
  end
  -- ordine: gruppi di livelli consecutivi con lo stesso talento
  cardOpen(); y = y - 12
  line("2", T.talOrder); y = y - 6
  local groups, cnt, sel, labels = {}, {}, nil, {}
  for _, t in ipairs(list) do
    local gp = groups[#groups]
    if gp and gp.n == t[2] then gp.to = t[1]; gp.c = gp.c + 1 else groups[#groups + 1] = { n = t[2], from = t[1], to = t[1], c = 1 } end
  end
  for i, gp in ipairs(groups) do
    cnt[gp.n] = (cnt[gp.n] or 0) + gp.c
    labels[i] = (gp.from == gp.to and gp.from or gp.from .. "–" .. gp.to) .. "  " .. gp.n .. " " .. cnt[gp.n] .. "/" .. (maxOf[gp.n] or "?")
    if L >= gp.from and L <= gp.to then sel = i end
  end
  flow(labels, sel, function(i) V.talLv = groups[i].from; render() end)
  cardClose()
end

-- Classe: sezioni a pulsanti (Rotazione, Spell, Razza, Consigli)
local function rangeOf(title) -- "10–19 · …" → 10, 19; "20+ · …" → 20, 60; "30 · …" → 30, 30
  local t = title:gsub("–", "-") -- la lineetta (3 byte) diventa un trattino
  local a, b = t:match("^(%d+)%-(%d+)")
  if a then return tonumber(a), tonumber(b) end
  a = title:match("^(%d+)%+"); if a then return tonumber(a), 60 end
  a = title:match("^(%d+)"); if a then return tonumber(a), tonumber(a) end
end
local function drawClass(g, k, v)
  local cls, race = k:match("-(%a+)$"), k:match("^(.-)%-%a+$")
  local CD, me = clsData()[cls] or {}, UnitLevel("player")
  V.clsSec = V.clsSec or 1
  cardOpen(); y = y - 12
  flow({ T.cRot, T.cSpells, T.cRace, T.cNotes }, V.clsSec, function(i) V.clsSec = i; render(true) end)
  y = y + 18
  cardClose()
  if V.clsSec == 1 then
    local bid = C.opt.b or (g.builds[1] and g.builds[1][1])
    local R = (CD.brot and CD.brot[bid]) or CD.rot or {}
    if not (V.rotSel and R[V.rotSel]) then
      V.rotSel = 1
      for i, r in ipairs(R) do local a, b = rangeOf(r[1]); if a and me >= a and me <= b then V.rotSel = i end end
    end
    cardOpen(); y = y - 12
    line("0", T.cRotPick); y = y - 6
    local labels = {}
    for i, r in ipairs(R) do labels[i] = r[1] end
    flow(labels, V.rotSel, function(i) V.rotSel = i; render() end)
    local r = R[V.rotSel]
    if r then
      -- sequenza: icone numerate con il nome sotto, 6 per riga
      local per = 6
      local cw = math.floor((BW - 2 * PAD) / per)
      local top = y
      for i, sp in ipairs(r[2]) do
        local x0, y0 = PAD + ((i - 1) % per) * cw, top - math.floor((i - 1) / per) * 78
        local ix = x0 + math.floor((cw - 34) / 2)
        icon(sp[1], ix, y0, 34)
        y = y0 + 2; local nb = str(F.small, "gold", tostring(i), ix - 12, 12)
        y = y0 - 38; local nm = str(F.p, "tx", sp[2], x0 + 2, cw - 4); nm:SetJustifyH("CENTER")
      end
      y = top - math.ceil(#r[2] / per) * 78
      if r[3] ~= "" then line("0", r[3]) end
    end
    cardClose()
  elseif V.clsSec == 2 then
    cardOpen(); y = y - 12
    flow({ T.cSpNow, T.cSpAll }, V.spAll and 2 or 1, function(i) V.spAll = i == 2; render() end)
    line("0", T.cSpTip); y = y - 4
    local bk, any = book(), false
    for _, sp in ipairs(CD.spells or {}) do
      local base = sp[2]:gsub("%s+%d+$", "")
      local have = base == sp[2] and known(base, bk)
      -- con il rank nel nome ("Heroic Strike 2") il libro non dice quale rank hai: solo se è del tuo livello o di poco sopra
      if V.spAll or (sp[1] <= me + 4 and not have and (base == sp[2] or sp[1] >= me - 1)) then
        any = true
        y = y - 6
        local top = y
        icon(sp[3], PAD, y, 20)
        local st, c = sp[1] > me and T.cSoon:format(sp[1]) or have and T.cHave or T.cBuy, sp[1] > me and "mu" or have and "ok" or "gold"
        local o = str(F.p, c, T.lv .. " " .. sp[1] .. "   {" .. sp[2] .. "}   " .. st .. (sp[5] and "  ·  " .. T.cTal or ""), PAD + 28, BW - 2 * PAD - 28)
        o:SetPoint("TOPLEFT", PAD + 28, y - 3)
        y = top - math.max(20, o:GetStringHeight() + 6)
        hover(PAD, top, BW - 2 * PAD, top - y, sp[2], sp[4])
      end
    end
    if not any then line("0", T.cSpNone) end
    cardClose()
  elseif V.clsSec == 3 then
    local RC = (clsData()._races or {})[race] or {}
    cardOpen(); y = y - 12
    line("1", RC[1] or race)
    local cr = CD.races and (CD.races[race] or CD.races[(race:gsub("_[ah]$", ""))])
    if cr then line("3", g.name); line("0", cr) end
    for _, rc in ipairs(RC[2] or {}) do
      y = y - 10
      local top = y
      icon(rc[2], PAD, y, 28)
      local o = str(F.h3, "gold", rc[1], PAD + 36, BW - 2 * PAD - 36); y = y - o:GetStringHeight() - 2
      o = str(F.p, "tx", rc[3], PAD + 36, BW - 2 * PAD - 36); y = y - o:GetStringHeight()
      y = math.min(y, top - 30)
    end
    if RC[3] and RC[3] ~= "" then y = y - 6; line("0", RC[3]) end
    cardClose()
  else
    local list = {}
    for _, n in ipairs(CD.notes or {}) do list[#list + 1] = n end
    if CD.stats and CD.stats ~= "" then list[#list + 1] = { T.cStats, CD.stats } end
    if CD.forever and #CD.forever > 0 then list[#list + 1] = { T.cForever, "• " .. table.concat(CD.forever, "\n• ") } end
    V.noteSel = math.max(1, math.min(V.noteSel or 1, #list))
    cardOpen(); y = y - 12
    local labels = {}
    for i, n in ipairs(list) do labels[i] = n[1] end
    flow(labels, V.noteSel, function(i) V.noteSel = i; render() end)
    local n = list[V.noteSel]
    if n then for para in (n[2] .. "\n"):gmatch("([^\n]*)\n") do if para ~= "" then line("0", para) end end end
    cardClose()
  end
end

-- riga con casella (Opzioni e opzioni della mappa nella scheda Profession): dopo il clic ridisegna
local function optRow(label, on, fn)
  y = y - 6
  local cb = check("opt", PAD, y)
  cb:SetChecked(on); cb.onClick = function(val) fn(val); render() end
  local s = str(F.p, "tx", label, PAD + 28, BW - 2 * PAD - 28); s:SetPoint("TOPLEFT", PAD + 28, y - 2)
  y = y - math.max(18, s:GetStringHeight())
end

-- Profession (1.7): le profession che il personaggio ha davvero (lette dal gioco, con la skill), il percorso 1–300 a passi con
-- quello della tua skill evidenziato, i materiali con quanti ne hai, il trainer più vicino per ogni grado, la ricetta in OneForAll;
-- in cima le opzioni della mappa (trainer e reagent vendor delle tue profession)
local nearestTrainer -- trainer più vicino di una profession (più sotto, con la posizione del giocatore)
local function profData() return ForeverPathfinderProfs and (ForeverPathfinderProfs[LANG] or ForeverPathfinderProfs.en) end
local function pkey(n) return (n:lower():gsub(" ", "-")) end
-- profession del personaggio { nome inglese, skill, max }: API moderna (GetProfessions) e skill line come in Classic; prima le principali
local function myProfs()
  local PD, out, seen = profData(), {}, {}
  if not PD then return out end
  local function add(n, r, m) if n and PD.list[n] and not seen[n] then seen[n] = true; out[#out + 1] = { n, r or 0, m or 0 } end end
  pcall(function()
    if GetProfessions and GetProfessionInfo then
      local l = { GetProfessions() }
      for i = 1, 6 do if l[i] then local n, _, r, m = GetProfessionInfo(l[i]); add(n, r, m) end end
    end
  end)
  pcall(function()
    if GetNumSkillLines and GetSkillLineInfo then
      for i = 1, GetNumSkillLines() do local n, hdr, _, r, _, _, m = GetSkillLineInfo(i); if not hdr then add(n, r, m) end end
    end
  end)
  table.sort(out, function(a, b)
    local sa, sb = PD.list[a[1]].type == "secondary", PD.list[b[1]].type == "secondary"
    if sa ~= sb then return sb end
    return a[1] < b[1]
  end)
  return out
end
-- quanti ne hai (borse e banca)
local function itemCount(id)
  if not id or id == 0 then return end
  local fn = (C_Item and C_Item.GetItemCount) or GetItemCount
  if not fn then return end
  local ok, n = pcall(fn, id, true)
  return ok and n or nil
end
-- ricetta nei dati di OneForAll (stesso oggetto creato, o stesso nome) e apertura nel suo pannello Professions
local function ofaRecipe(prof, id, name)
  local O = _G.OneForAll
  local list = O and O.OpenPanel and O.ShowRecipeInProfessions and O.PROFESSION_RECIPES and O.PROFESSION_RECIPES[prof]
  for _, r in ipairs(list or {}) do if (id ~= 0 and r.i == id) or r.n == name then return r end end
end
local function ofaRecipeOpen(prof, r)
  pcall(function() OneForAll:OpenPanel("professions"); OneForAll.ShowRecipeInProfessions(prof, r.s) end)
end
-- passi del percorso: fascia, icona, cosa (tooltip dell'oggetto), volte, materiali con quanti ne hai, dove; ranks = righe dei gradi
-- (Apprentice in cima, poi prima del passo che supera il cap); restituisce la posizione del passo attuale per lo scorrimento
local function profSteps(name, P, rt, sk, ranks)
  local here, found, ri, w = nil, false, 1, BW - 2 * PAD - 88 - 28
  local function sep() box("bd", 1, PAD, y + 3, BW - 2 * PAD, 1, true) end
  local function rankRow(cap, rname, lvl, need, first)
    y = y - 6
    local top = y
    local how = not first and P.how[rname]
    local s = first and T.pApp or T.pLearn:format(rname, cap, lvl, need)
    if how then s = s .. "\n" .. T.pHow:format(how) end
    str(F.small, "mu", tostring(first and 1 or cap), PAD + 4, 56)
    icon("inv_scroll_03", PAD + 62, y, 18)
    local o = str(F.p, sk > cap and "mu" or "ice", s, PAD + 88, w)
    if not how then mini("inv_misc_map_01", BW - PAD - 20, top, name .. " Trainer", T.pTrainer, function() local p = nearestTrainer(name, not first); if p then mapAt(p) end end) end
    y = top - math.max(22, o:GetStringHeight()) - 6
    sep()
  end
  if ranks then rankRow(75, "Apprentice", 1, 1, true) end
  for _, s in ipairs(rt) do
    if ranks then while ranks[ri] and s[2] > ranks[ri][1] do local r = ranks[ri]; rankRow(r[1], r[2], r[3], r[4]); ri = ri + 1 end end
    local past, cur = sk >= s[2], false
    if not past and not found then found, cur = true, true end
    y = y - 8
    local top = y
    str(F.small, past and "mu" or cur and "gold" or "tx", s[1] .. "–" .. s[2], PAD + 4, 56)
    icon(s[5] ~= "" and s[5] or "inv_misc_questionmark", PAD + 62, y, 20)
    local times = s[6] > 0 and "  ×" .. s[6] or ""
    local o = str(F.h3, past and "mu" or "tx", past and s[3] .. times or "{" .. s[3] .. "}" .. times .. (cur and "   |cffe8b84a" .. T.pHere .. "|r" or ""), PAD + 88, w)
    if s[4] ~= 0 then hover(PAD + 88, top, math.min(w, o:GetStringWidth() + 4), 16, nil, nil, s[4]) end
    y = y - o:GetStringHeight() - 3
    if #s[7] > 0 then
      local parts = {}
      for _, m in ipairs(s[7]) do
        local h = not past and itemCount(m[3])
        parts[#parts + 1] = m[1] .. "× " .. m[2] .. (m[5] == 1 and " (" .. T.pVendor .. ")" or "") .. (h and ((h >= m[1] and " |cff5fd68b(" or " |cffe7eef7(") .. h .. ")|r") or "")
      end
      local mo = str(F.p, "mu", table.concat(parts, ", "), PAD + 88, w); y = y - mo:GetStringHeight() - 2
    end
    if s[8] ~= "" then local wo = str(F.p, "mu", s[8], PAD + 88, w); y = y - wo:GetStringHeight() - 2 end
    local r = s[6] > 0 and ofaRecipe(name, s[4], s[3])
    if r then mini(P.icon, BW - PAD - 20, top, s[3], T.pOfaTip, function() ofaRecipeOpen(name, r) end) end
    y = math.min(y, top - 22) - 4
    if cur then
      here = -top
      box("goldbg", 1, PAD - 4, top + 4, BW - 2 * PAD + 8, top - y, true)
      box("gold", 1, PAD - 4, top + 4, 2, top - y, true)
    end
    sep()
  end
  return here
end
local function drawProfs(g, k)
  local PD = profData()
  if not PD then return end
  local mine, own, names, labels, sel = myProfs(), {}, {}, {}, nil
  for _, p in ipairs(mine) do own[p[1]] = p; names[#names + 1] = p[1] end
  if not (V.profSel and PD.list[V.profSel]) then V.profSel = mine[1] and mine[1][1] end
  if #mine == 0 or V.profAll then for _, n in ipairs(PD.order) do if not own[n] then names[#names + 1] = n end end end
  cardOpen(); y = y - 12
  optRow(T.pMapT, C.opt.ptr == true, function(v) C.opt.ptr = v or nil; drawMapPins() end)
  optRow(T.pMapV, C.opt.pvd == true, function(v) C.opt.pvd = v or nil; drawMapPins() end)
  y = y - 8
  if #mine == 0 then
    line("0", T.pNone)
    local pick = PD.picks[k:match("-(%a+)$")]
    if pick then line("0", pick) end
    y = y - 4; line("0", T.pBrowse); y = y - 6
  end
  for i, n in ipairs(names) do labels[i] = own[n] and (n .. "  " .. own[n][2]) or n; if n == V.profSel then sel = i end end
  if #mine > 0 and not V.profAll then labels[#labels + 1] = T.pOthers end
  y = y - 4
  flow(labels, sel, function(i) if names[i] then V.profSel = names[i] else V.profAll = true end; render(true) end)
  y = y + 18
  cardClose()
  if not V.profSel then return end
  local P, o = PD.list[V.profSel], own[V.profSel]
  local sk = o and math.max(1, o[2]) or 1
  cardOpen(); y = y - 12
  local top = y
  icon(P.icon, PAD, y, 30)
  str(F.h1, "ice", V.profSel, PAD + 40, BW - 2 * PAD - 40)
  y = top - 18
  str(F.h2, o and "gold" or "mu", o and T.pSkill:format(o[2], o[3]) or T.pNotYours, PAD + 40, BW - 2 * PAD - 40)
  y = top - 38
  if o then line("0", T.pBag); y = y - 4 end
  local here = profSteps(V.profSel, P, P.route, sk, PD.ranks)
  if #P.alt > 0 then y = y - 10; line("2", P.altTitle); profSteps(V.profSel, P, P.alt, sk) end
  y = y - 6; line("0", PD.src)
  cardClose()
  -- lista della spesa (dalla tua skill a 300) e novità, a scomparsa
  cardOpen(); y = y - 12
  local b1 = button(T.pShop:format(sk), PAD, y, function() V.profShop = not V.profShop; render() end); b1.set(V.profShop and true or false)
  local b2 = button(T.pMore, PAD + b1:GetWidth() + 8, y, function() V.profMore = not V.profMore; render() end); b2.set(V.profMore and true or false)
  y = y - 30
  if V.profShop then
    local tot, keys = {}, {}
    for _, list in ipairs({ P.route, P.alt }) do for _, s in ipairs(list) do if s[2] > sk then for _, m in ipairs(s[7]) do
      if not tot[m[2]] then tot[m[2]] = { 0, m[3], m[5] }; keys[#keys + 1] = m[2] end
      tot[m[2]][1] = tot[m[2]][1] + m[1]
    end end end end
    table.sort(keys)
    for _, n in ipairs(keys) do
      local t, h = tot[n], itemCount(tot[n][2])
      line("0", "• " .. t[1] .. "× " .. n .. (t[3] == 1 and " (" .. T.pVendor .. ")" or "") .. (h and h > 0 and "  |cff5fd68b(" .. h .. ")|r" or ""))
    end
  end
  if V.profMore then
    for _, x in ipairs(P.forever) do line("0", "• " .. x) end
    if P.camp ~= "" then line("3", T.pCamp); line("0", P.camp) end
    if P.gold ~= "" then line("3", T.pGold); line("0", P.gold) end
    for _, x in ipairs(P.tips) do line("0", "• " .. x) end
  end
  if V.profShop or V.profMore then y = y - 4 else y = y + 18 end
  cardClose()
  return here
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
  local opt = optRow
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
  for _, l in ipairs({ { "map", T.oMap }, { "trainers", T.oTrainers }, { "quests", T.oQuests }, { "tal", T.oTal }, { "trainer", T.oTrainer } }) do
    opt(l[2], o["no" .. l[1]] ~= true, function(val) o["no" .. l[1]] = not val or nil end)
  end
  -- trainer e reagent vendor delle profession (1.7): spenti di base, come le caselle in cima alla scheda Profession
  opt(T.pMapT, o.ptr == true, function(val) o.ptr = val or nil end)
  opt(T.pMapV, o.pvd == true, function(val) o.pvd = val or nil end)
  line("0", T.oEnglish)
  line("2", "Language · Lingua")
  opt("English", LANG == "en", function() setLang("en") end)
  opt("Italiano", LANG == "it", function() setLang("it") end)
  line("2", T.oChar)
  line("0", T.oAuto:format(g.name .. " (" .. k .. ")"))
  line("0", T.oSite)
  line("2", T.oLate)
  line("0", T.oLateTxt)
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
  b:SetScript("OnClick", function() if t[1] == "dungeon" then V.dgSel = nil end; tab = t[1]; render(true) end)
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
    elseif tab == "dungeon" then drawDungeons(g)
    elseif tab == "talent" and ForeverPathfinderTrees then drawTalents(g, k, v)
    elseif tab == "classe" and ForeverPathfinderClass then drawClass(g, k, v)
    elseif tab == "prof" and ForeverPathfinderProfs then here = drawProfs(g, k)
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
  if p.ic then return iconPath(p.ic), true end -- trainer e reagent vendor delle profession: icona della profession o della borsa
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
  if fr.lab then fr.lab:SetScale(math.max(0.01, z / 18)) end
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
    -- il bordo dorato del segnaposto scelto pulsa
    for _, p in ipairs(mapPins) do if p.hot and GetTime then p.bd:SetAlpha(0.35 + 0.65 * math.abs(math.sin(GetTime() * 3))) end end
  end)
end
local TRP -- segnaposti dei trainer della tua classe, calcolati una volta
local function classTrainers()
  if TRP then return TRP end
  TRP = {}
  local cls = (select(2, UnitClass("player")) or ""):lower()
  local side = UnitFactionGroup("player") == "Horde" and 2 or 1
  local label = cls:sub(1, 1):upper() .. cls:sub(2) .. " Trainer"
  for _, t in ipairs(ForeverPathfinderTrainers and ForeverPathfinderTrainers[cls] or {}) do
    if t[5] == 0 or t[5] == side then TRP[#TRP + 1] = { t[2], t[3], t[4], label, nil, z = t.z, who = t[1] } end
  end
  return TRP
end
local profPins
do
-- reagent vendor delle tue profession (1.7): chi vende i materiali "vendor" dei loro percorsi, dal database di Questie
-- (Item.vendors → NPC amici della tua fazione → spawns per zona); calcolati una volta per insieme di profession
local PVP, PVK
local function vendorPins(mine)
  local key = {}
  for _, p in ipairs(mine) do key[#key + 1] = p[1] end
  key = table.concat(key, ",")
  if PVP and PVK == key then return PVP end
  if not (QZ() and LibQuestieDB.Item and LibQuestieDB.Npc) then return {} end
  PVK, PVP = key, {}
  local fac = UnitFactionGroup("player") == "Horde" and "H" or "A"
  local Zone, byNpc = mod("ZoneDB"), {}
  for _, pr in ipairs(mine) do
    for _, s in ipairs(profData().list[pr[1]].route) do for _, m in ipairs(s[7]) do
      if m[5] == 1 and m[3] ~= 0 then
        local ok, ids = pcall(LibQuestieDB.Item.vendors, m[3])
        for _, npc in ipairs(ok and ids or {}) do
          local ok2, fr = pcall(LibQuestieDB.Npc.friendlyToFaction, npc)
          if ok2 and fr and fr:find(fac) then
            local e = byNpc[npc] or { mats = {}, seen = {} }
            byNpc[npc] = e
            if not e.seen[m[2]] then e.seen[m[2]] = true; e.mats[#e.mats + 1] = m[2] end
          end
        end
      end
    end end
  end
  for npc, e in pairs(byNpc) do
    local _, name = pcall(LibQuestieDB.Npc.name, npc)
    local ok, sp = pcall(LibQuestieDB.Npc.spawns, npc)
    for area, list in pairs(ok and type(sp) == "table" and sp or {}) do
      local okz, zm = pcall(Zone.GetUiMapIdByAreaId, Zone, area)
      for _, c in ipairs(okz and zm and zm ~= 0 and list or {}) do
        if c[1] and c[1] >= 0 then
          local p = zonePin(zm, c[1] / 100, c[2] / 100, T.pVendT)
          p.who, p.ic = tostring(name or "?") .. " (" .. table.concat(e.mats, ", ") .. ")", "inv_misc_bag_10"
          if p[1] then PVP[#PVP + 1] = p end
        end
      end
    end
  end
  return PVP
end
-- segnaposti delle profession sulla mappa del mondo: trainer (mappa del sito) e reagent vendor, se accesi nelle opzioni
function profPins()
  local out, mine = {}, myProfs()
  local side = UnitFactionGroup("player") == "Horde" and 2 or 1
  if C.opt.ptr then
    for _, pr in ipairs(mine) do
      for _, t in ipairs(ForeverPathfinderProfTrainers and ForeverPathfinderProfTrainers[pkey(pr[1])] or {}) do
        if t[5] == 0 or t[5] == side then out[#out + 1] = { t[2], t[3], t[4], pr[1] .. " Trainer", nil, z = t.z, who = t[1], ic = profData().list[pr[1]].icon } end
      end
    end
  end
  if C.opt.pvd then for _, p in ipairs(vendorPins(mine)) do out[#out + 1] = p end end
  return out
end
end
do
local hideOfaOver -- icone di OneForAll sopra i nostri segnaposti (più sotto)
-- due segnaposti sono lo stesso punto (le copie fatte a ogni disegno hanno le stesse posizioni)
local function samePin(a, b)
  return a == b or (a[1] == b[1] and a[2] == b[2] and a[3] == b[3] and a[4] == b[4] and a.zx == b.zx and a.zy == b.zy)
end
-- segnaposto scelto (1.8): della misura degli altri (come i "!" di Questie), bordo dorato sottile che pulsa, sotto il nome e la quest, così si vede subito tra gli altri
local function dressPin(pin)
  local p, hot = pin.p, pin.hot
  if hot then pin.bd:SetColorTexture(0.91, 0.72, 0.29, 1) else pin.bd:SetColorTexture(0.64, 0.21, 0.93, 1) end
  pin.bd:SetAlpha(1)
  if not hot then
    if pin.lab then pin.lab:Hide() end
    return
  end
  if not pin.lab then
    pin.lab = CreateFrame("Frame", nil, pin)
    local bg = pin.lab:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); bg:SetColorTexture(0.04, 0.06, 0.1, 0.9)
    pin.l1 = pin.lab:CreateFontString(nil, "OVERLAY"); pin.l1:SetFontObject(F.h3); pin.l1:SetTextColor(unpack(COL.gold)); pin.l1:SetPoint("TOP", 0, -4)
    pin.l2 = pin.lab:CreateFontString(nil, "OVERLAY"); pin.l2:SetFontObject(F.p); pin.l2:SetTextColor(unpack(COL.tx)); pin.l2:SetPoint("TOP", 0, -20)
  end
  local l2 = (p.sub and p.sub ~= p[4] and p.sub) or (p.who and p[4]) or ""
  pin.l1:SetText(p.who or p[4] or ""); pin.l2:SetText(l2)
  pin.lab:SetSize(math.max(pin.l1:GetStringWidth() or 0, pin.l2:GetStringWidth() or 0, 40) + 14, l2 ~= "" and 38 or 22)
  pin.lab:ClearAllPoints(); pin.lab:SetPoint("TOP", pin, "BOTTOM", 0, -6)
  pin.lab:Show()
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
  -- tutti i trainer della tua classe e fazione (ForeverPathfinderTrainers), con l'icona della classe
  if on("trainers") then for _, p in ipairs(classTrainers()) do list[#list + 1] = p end end
  if C.opt.ptr or C.opt.pvd then for _, p in ipairs(profPins()) do list[#list + 1] = p end end
  if target then xy(target); list[#list + 1] = target end -- il segnaposto scelto: per ultimo, sopra gli altri
  for i, p in ipairs(list) do
    local x, y
    local gx, gy = xy(p)
    local hot = target ~= nil and i == #list
    if mapID == p.zm then x, y = p.zx, p.zy elseif cont[p[1]] then x, y = onMap(mapID, cont[p[1]], gx, gy) end
    if x and (hot or not (target and samePin(p, target))) then
      n = n + 1
      local pin = mapPins[n]
      if not pin then
        pin = CreateFrame("Button", nil, canvas); pin:SetSize(24, 24)
        pinFrame(pin)
        pin.tx = pin:CreateTexture(nil, "OVERLAY"); pin.tx:SetAllPoints()
        pin:SetScript("OnEnter", function(self)
          GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(self.p.who and self.p[4] .. ": " .. self.p.who or self.p[4])
          if self.p.sub and self.p.sub ~= self.p[4] then GameTooltip:AddLine(self.p.sub, 0.91, 0.72, 0.29) end
          GameTooltip:AddLine("Forever Pathfinder" .. (self.p[5] and " · " .. T.level:format(self.p[5]) or ""), 1, 1, 1)
          GameTooltip:AddLine(self.hot and T.pinOff or T.pinOn, 0.58, 0.65, 0.75); GameTooltip:Show()
        end)
        pin:SetScript("OnLeave", function() GameTooltip:Hide() end)
        pin:SetScript("OnClick", function(self) if self.hot then clearTarget() else setTarget(self.p) end end)
        mapPins[n] = pin
      end
      pin.p, pin.hot = p, hot
      paintPin(pin.tx, p); pin:SetAlpha(p.done and not hot and 0.45 or 1) -- voce già spuntata: più chiara
      pin:SetFrameLevel(canvas:GetFrameLevel() + (hot and 2100 or 2000))
      dressPin(pin)
      sizePin(pin, pinSize(canvas))
      pin:ClearAllPoints(); pin:SetPoint("CENTER", canvas, "TOPLEFT", x * cw, -y * ch); pin:Show()
    end
  end
  hideOfaOver()
  if C_Timer and C_Timer.After then C_Timer.After(0, hideOfaOver) end -- dopo i ganci di OneForAll sulla stessa mappa
end
-- icone di OneForAll sulla mappa (ingressi, libri: MapLandmarks; il suo segnaposto OneForAllMapPin) stanno più in alto delle
-- nostre e le coprono: nascoste dove si sovrappongono a un nostro segnaposto (scelta dell'utente del 10 nov), anche quando
-- OneForAll le ridisegna (zoom, cambio mappa)
function hideOfaOver()
  local canvas = WorldMapFrame and WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child
  if not (canvas and _G.OneForAll and WorldMapFrame:IsShown()) then return end
  local ours = {}
  for _, p in ipairs(mapPins) do
    local x, yy
    if p:IsShown() then x, yy = p:GetCenter() end -- (niente "a and f()": taglierebbe i valori restituiti a uno solo)
    if x and yy then local s = p:GetEffectiveScale(); ours[#ours + 1] = { x * s, yy * s, (p:GetWidth() or 0) * s / 2 } end
  end
  if #ours == 0 then return end
  for _, c in ipairs({ canvas:GetChildren() }) do
    if (rawget(c, "entry") or c == _G.OneForAllMapPin) and c:IsShown() then
      local x, yy = c:GetCenter()
      if x then
        local s = c:GetEffectiveScale()
        x, yy = x * s, yy * s
        local r = (c:GetWidth() or 0) * s / 2 * 0.7
        for _, o in ipairs(ours) do
          if math.abs(o[1] - x) < o[3] + r and math.abs(o[2] - yy) < o[3] + r then c:Hide(); break end
        end
      end
    end
  end
end
if _G.OneForAll and type(OneForAll.MapLandmarks) == "table" and OneForAll.MapLandmarks.Refresh then hooksecurefunc(OneForAll.MapLandmarks, "Refresh", hideOfaOver) end
end
if WorldMapFrame then
  WorldMapFrame:HookScript("OnShow", drawMapPins)
  if WorldMapFrame.OnMapChanged then hooksecurefunc(WorldMapFrame, "OnMapChanged", drawMapPins) end
end

-- segnaposto scelto da una voce: quello del gioco (mappa e minimappa) se questa versione lo permette, altrimenti il nostro sulla minimappa
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
-- trainer più vicino di una profession sul tuo continente (della tua fazione; adv = per un grado dopo Apprentice: niente trainer
-- delle zone iniziali che insegnano solo Apprentice); se sul continente non c'è, il primo che va bene
nearestTrainer = function(prof, adv)
  local side, here, best, bd, any = UnitFactionGroup("player") == "Horde" and 2 or 1, {}
  for ck, cid in pairs(continents()) do local px, py = playerOn(cid); if px and px >= 0 and px <= 1 and py >= 0 and py <= 1 then here[ck] = { px, py } end end
  for _, t in ipairs(ForeverPathfinderProfTrainers and ForeverPathfinderProfTrainers[pkey(prof)] or {}) do
    if (t[5] == 0 or t[5] == side) and not (adv and t.ap) then
      local p = { t[2], t[3], t[4], prof .. " Trainer", nil, z = t.z, who = t[1] }
      any = any or p
      local h = here[t[2]]
      if h then local gx, gy = xy(p); local d = (gx - h[1]) ^ 2 + (gy - h[2]) ^ 2; if not bd or d < bd then best, bd = p, d end end
    end
  end
  return best or any
end
-- al massimo del grado (75, 150, 225) una riga in chat, una volta per profession e grado: cosa imparare e da chi
local function capCheck()
  local PD = profData()
  if not (PD and C) then return end
  C.capw = C.capw or {}
  for _, p in ipairs(myProfs()) do
    for _, r in ipairs(PD.ranks) do
      if p[3] == r[1] and p[2] >= r[1] and not C.capw[p[1] .. r[1]] then
        C.capw[p[1] .. r[1]] = true
        local how = PD.list[p[1]].how[r[2]]
        if not how then local t = nearestTrainer(p[1], true); how = T.pCapT:format(t and t.who or "?") end
        say(T.pCap:format(p[1], p[2], p[3], r[2], how))
      end
    end
  end
end
do
-- yard dal giocatore al segnaposto (x verso est, y verso sud): sulla mappa della sua zona se ci sei, altrimenti sul continente
local function offset(t)
  local W = C_Map and C_Map.GetMapWorldSize
  if not W then return end
  if t.zm and C_Map.GetPlayerMapPosition then
    local pos = C_Map.GetPlayerMapPosition(t.zm, "player")
    local w, h = W(t.zm)
    if pos and w and w > 0 and h then local px, py = pos:GetXY(); if px then return (t.zx - px) * w, (t.zy - py) * h end end
  end
  local cont = continents()[t[1]]
  if not cont then return end
  local px, py = playerOn(cont)
  local w, h = W(cont)
  if not (px and w and w > 0 and h) then return end
  local tx, ty = xy(t)
  return (tx - px) * w, (ty - py) * h
end
-- toglie il segnaposto scelto (all'arrivo, o con un clic sul segnaposto evidenziato): anche quello del gioco, se l'abbiamo messo noi
local ownWp = false
clearTarget = function(arrived)
  if not target then return end
  if arrived then say(T.pinHere:format(target.who or target[4])) end
  target = nil; mm:Hide()
  if ownWp and C_Map.ClearUserWaypoint then pcall(C_Map.ClearUserWaypoint) end
  ownWp = false
  drawMapPins()
end
-- ogni 0,2 s: arrivato (meno di 10 yard) → il segnaposto si toglie; il nostro punto sulla minimappa segue la direzione
local watch, elapsed = CreateFrame("Frame"), 0
watch:SetScript("OnUpdate", function(_, dt)
  elapsed = elapsed + (dt or 0)
  if elapsed < 0.2 then return end
  elapsed = 0
  if not target then return end
  local dx, dy = offset(target)
  if not dx then mmT:SetAlpha(0); return end
  mmT:SetAlpha(1)
  local dist = math.sqrt(dx * dx + dy * dy)
  if dist < 10 then clearTarget(true); return end
  if not mm:IsShown() then return end
  -- ponytail: minimappa non ruotata (impostazione di base); con "Ruota minimappa" il punto va ruotato con GetPlayerFacing
  local r = Minimap:GetWidth() / 2
  local k = r / ((MMY[(Minimap:GetZoom() or 0) + 1] or 466.67) / 2)
  local ox, oy = dx * k, -dy * k
  local d = math.sqrt(ox * ox + oy * oy)
  if d > r - 6 then ox, oy = ox * (r - 6) / d, oy * (r - 6) / d end -- fuori portata: resta sul bordo, nella direzione giusta
  mm:ClearAllPoints(); mm:SetPoint("CENTER", Minimap, "CENTER", ox, oy)
end)
-- segnaposto scelto: riga in chat (quest, NPC, zona e coordinate), segnaposto del gioco con la freccia se questa versione lo
-- permette (altrimenti il nostro punto sulla minimappa), ed evidenziato sulla mappa del mondo
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
  local who, zn = p.who and (p[4] .. ": " .. p.who) or p[4], zone and zone.name or ""
  if p.sub and p.sub ~= p[4] then say(T.pinSetQ:format(p.sub, who, zn, (zx or 0) * 100, (zy or 0) * 100))
  else say(T.pinSet:format(who, zn, (zx or 0) * 100, (zy or 0) * 100)) end
  if zone and zx and C_Map.CanSetUserWaypointOnMap and C_Map.CanSetUserWaypointOnMap(zone.mapID) and UiMapPoint then
    C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(zone.mapID, zx, zy))
    if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then C_SuperTrack.SetSuperTrackedUserWaypoint(true) end
    ownWp = true
    mm:Hide()
  else
    mm:Show()
  end
  drawMapPins()
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
local talentUI, traitFrame, talentGlow, traitDebug
do
local glow = CreateFrame("Frame", nil, UIParent); glow:Hide()
local glowT = glow:CreateTexture(nil, "OVERLAY"); glowT:SetAllPoints(); glowT:SetTexture("Interface\\Buttons\\UI-ActionButton-Border"); glowT:SetBlendMode("ADD")
function talentUI() return (_G.TalentFrame and "TalentFrame") or (_G.PlayerTalentFrame and "PlayerTalentFrame") end
-- finestra dei talenti moderna (1.8; Forever usa C_Traits): la parte con i pulsanti dei nodi, tra i nomi che ha nei client moderni
function traitFrame()
  for _, c in ipairs({ { "PlayerSpellsFrame", "TalentsFrame" }, { "ClassTalentFrame", "TalentsTab" }, { "PlayerTalentFrame", "TalentsFrame" },
    { "ClassTalentFrame" }, { "PlayerTalentFrame" }, { "TalentFrame" } }) do
    local top = _G[c[1]]
    local fr = top
    if fr and c[2] then fr = fr[c[2]] end
    if type(fr) == "table" and fr.EnumerateAllTalentButtons then return fr, top, c[1] end
  end
end
-- nome del talento di un pulsante: nodo → voce → definizione → spell
local function traitName(b)
  local ok, n = pcall(function()
    local cfg = C_ClassTalents.GetActiveConfigID()
    local ni = (b.GetNodeInfo and b:GetNodeInfo()) or b.nodeInfo or (b.GetNodeID and C_Traits.GetNodeInfo(cfg, b:GetNodeID()))
    local entry = (b.GetEntryID and b:GetEntryID()) or (ni and ((ni.activeEntry and ni.activeEntry.entryID) or (ni.entryIDs and ni.entryIDs[1])))
    local ei = entry and C_Traits.GetEntryInfo(cfg, entry)
    local di = ei and ei.definitionID and C_Traits.GetDefinitionInfo(ei.definitionID)
    if not di then return end
    if di.overrideName and di.overrideName ~= "" then return di.overrideName end
    local sid = di.spellID
    return sid and ((C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(sid)) or (GetSpellInfo and (GetSpellInfo(sid))))
  end)
  return ok and n or nil
end
local function plainName(s) return (tostring(s):gsub("’", "'"):lower()) end
local function glowOn(b)
  glow:SetParent(b); glow:SetFrameLevel(b:GetFrameLevel() + 5)
  glow:ClearAllPoints(); glow:SetPoint("CENTER", b, "CENTER"); glow:SetSize(b:GetWidth() * 1.9, b:GetHeight() * 1.9); glow:Show()
end
function talentGlow()
  glow:Hide()
  if not (C and on("tal")) then return end
  local g, _, v = guide()
  if not g then return end
  local spent, _, src = talentPoints()
  local want = v._tal[spent + 1]
  if not want then return end
  if src == "traits" then
    local tf, top = traitFrame()
    if not (tf and top:IsShown()) then return end
    local wn = plainName(want[2])
    pcall(function()
      for b in tf:EnumerateAllTalentButtons() do
        local n = traitName(b)
        if n and plainName(n) == wn then glowOn(b); return end
      end
    end)
    return
  end
  local pre = talentUI()
  if not (pre and src == "tabs" and _G[pre]:IsShown()) then return end
  local tf = _G[pre]
  local sel = (PanelTemplates_GetSelectedTab and PanelTemplates_GetSelectedTab(tf)) or tf.selectedTab or 1
  for tabI = 1, GetNumTalentTabs() do
    for i = 1, (GetNumTalents(tabI) or 0) do
      if GetTalentInfo(tabI, i) == want[2] then
        local b = tabI == sel and _G[pre .. "Talent" .. i] or _G[pre .. "Tab" .. tabI]
        if b then glowOn(b) end
        return
      end
    end
  end
end
-- /fp debug: quale finestra dei talenti moderna c'è, quanti pulsanti ha e di quanti si legge il nome
function traitDebug()
  local tf, _, name = traitFrame()
  if not tf then return "-" end
  local n, named = 0, 0
  pcall(function() for b in tf:EnumerateAllTalentButtons() do n = n + 1; if traitName(b) then named = named + 1 end end end)
  return name .. " " .. named .. "/" .. n
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
  if not hooked.trait then
    local tf, top = traitFrame()
    if tf and top and top.HookScript then
      hooked.trait = true
      local later = function() talentGlow(); if C_Timer and C_Timer.After then C_Timer.After(0.3, talentGlow) end end
      top:HookScript("OnShow", later)
      if tf ~= top and tf.HookScript then tf:HookScript("OnShow", later) end
    end
  end
  if not hooked.tr and _G.ClassTrainerFrame_Update then hooked.tr = true; hooksecurefunc("ClassTrainerFrame_Update", trainerMarks) end
end

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("CHARACTER_POINTS_CHANGED")
for _, e in ipairs({ "TRAIT_CONFIG_UPDATED", "TRAIT_NODE_CHANGED", "PLAYER_TALENT_UPDATE" }) do pcall(f.RegisterEvent, f, e) end
for _, e in ipairs({ "QUEST_LOG_UPDATE", "QUEST_TURNED_IN", "TRAINER_SHOW", "SPELLS_CHANGED", "TAXIMAP_OPENED", "SKILL_LINES_CHANGED", "CHAT_MSG_SKILL", "BAG_UPDATE_DELAYED" }) do pcall(f.RegisterEvent, f, e) end
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
  elseif event == "SKILL_LINES_CHANGED" or event == "CHAT_MSG_SKILL" then -- profession: avviso al massimo del grado, scheda aggiornata
    if not C then return end
    capCheck()
    if tab ~= "prof" then return end
  elseif event == "BAG_UPDATE_DELAYED" then -- materiali nelle borse della scheda Profession
    if tab == "prof" and f:IsShown() then render() end
    return
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
      (C_Map and C_Map.SetUserWaypoint) and T.yes or T.no, tostring(talentUI() or "-") .. " · " .. traitDebug(), nq))
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
