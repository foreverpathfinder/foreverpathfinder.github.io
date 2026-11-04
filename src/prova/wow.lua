-- WoW finto per la pagina di prova: oggetti dell'interfaccia con geometria, eventi, finestre di Blizzard (talenti, trainer,
-- mappa del mondo, minimappa, chat). La pagina (index.html) chiama SNAP, CLICK, WHEEL, ENTER, LEAVE, DRAG*, TICK, FIRE, SLASH.
local js = require "js"
local window = js.global
local SW, SH = 1280, 760 -- schermo del gioco finto, in unità dell'interfaccia
local function jstr(s) return '"' .. tostring(s):gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', ''):gsub('\t', ' ') .. '"' end

-- misure dei testi: le fa il browser con gli stessi caratteri (cache per testo, carattere, larghezza)
local MC = {}
local function measure(fo, w, t)
  local k = fo.file .. "|" .. fo.size .. "|" .. (w or 0) .. "|" .. t
  local m = MC[k]
  if not m then
    local a, b = tostring(window:MEASURE(fo.file, fo.size, w or 0, t)):match("([%d%.]+),([%d%.]+)")
    m = { tonumber(a), tonumber(b) }; MC[k] = m
  end
  return m
end
local FONTOBJ = { -- caratteri di Blizzard usati dalle finestre finte
  GameFontNormal = { file = "FRIZQT", size = 13, c = { 1, 0.82, 0 } }, GameFontHighlight = { file = "FRIZQT", size = 13, c = { 1, 1, 1 } },
  GameFontNormalLarge = { file = "FRIZQT", size = 16, c = { 1, 0.82, 0 } }, GameFontHighlightSmall = { file = "FRIZQT", size = 11, c = { 1, 1, 1 } },
}
local LAYERS = { BACKGROUND = 1, BORDER = 2, ARTWORK = 3, OVERLAY = 4, HIGHLIGHT = 9 }
local all, nextId = {}, 0
local new
local function detach(o) local p = o.parent; if not p then return end
  local l = (o.kind == "Texture" or o.kind == "FontString") and p.regs or p.kids
  for i, x in ipairs(l) do if x == o then table.remove(l, i); break end end end
local methods = {
  SetSize = function(s, w, h) s.w, s.h = w, h end, SetWidth = function(s, w) s.w = w end, SetHeight = function(s, h) s.h = h end,
  GetWidth = function(s) if s.kind == "FontString" and not s.w then return measure(s.fo, nil, s.text or "")[1] end return s.w or 0 end,
  GetHeight = function(s) return s.h or 0 end, GetSize = function(s) return s.w or 0, s.h or 0 end,
  SetPoint = function(s, p, a, b, c, d)
    local rel, rp, x, y = nil, p, 0, 0
    if type(a) == "number" then x, y = a, b or 0
    elseif type(a) == "table" then rel = a; if type(b) == "string" then rp, x, y = b, c or 0, d or 0 else x, y = b or 0, c or 0 end end
    s.pt = { p = p, rel = rel, rp = rp, x = x, y = y }; s.fill = nil
  end,
  ClearAllPoints = function(s) s.pt = nil end, SetAllPoints = function(s) s.fill = true end,
  Show = function(s) if not s.shown then s.shown = true; if s.scripts.OnShow then s.scripts.OnShow(s) end end end,
  Hide = function(s) s.shown = false end, IsShown = function(s) return s.shown end, IsVisible = function(s) return s.shown end,
  SetScript = function(s, n, fn) s.scripts[n] = fn end, GetScript = function(s, n) return s.scripts[n] end,
  HookScript = function(s, n, fn) local old = s.scripts[n]; s.scripts[n] = old and function(...) old(...); fn(...) end or fn end,
  RegisterEvent = function(s, e) s.events[e] = true end, UnregisterEvent = function(s, e) s.events[e] = nil end,
  RegisterForDrag = function(s) s.drag = true end, StartMoving = function(s) s.moving = true end, StopMovingOrSizing = function(s) s.moving = false end,
  CreateTexture = function(s, _, layer) return new("Texture", s, layer or "ARTWORK") end,
  CreateFontString = function(s, _, layer, tmpl) local o = new("FontString", s, layer or "OVERLAY"); if tmpl then o:SetFontObject(tmpl) end; return o end,
  SetColorTexture = function(s, r, g, b, a) s.color = { r, g, b }; s.alpha = a or 1; s.tex = nil end,
  SetTexture = function(s, p) s.tex = p; s.color = nil end, SetAlpha = function(s, a) s.op = a end, SetBlendMode = function(s, m) s.blend = m end,
  SetFontObject = function(s, fo) if type(fo) == "string" then fo = FONTOBJ[fo] or FONTOBJ.GameFontNormal end; s.fo = fo; if fo.c then s.tc = fo.c end end,
  SetTextColor = function(s, r, g, b) s.tc = { r, g, b } end,
  SetText = function(s, t) if s.fs then s.fs:SetText(t) else s.text = t end end, GetText = function(s) return s.text end,
  GetStringHeight = function(s) return measure(s.fo, s.w, s.text or "")[2] end, GetStringWidth = function(s) return measure(s.fo, nil, s.text or "")[1] end,
  SetScrollChild = function(s, c) s.child = c end, SetVerticalScroll = function(s, v) s.off = v end, GetVerticalScroll = function(s) return s.off or 0 end,
  SetMinMaxValues = function(s, a, b) s.min, s.max = a, b end, GetMinMaxValues = function(s) return s.min or 0, s.max or 0 end,
  SetValue = function(s, v) s.val = v; if s.scripts.OnValueChanged then s.scripts.OnValueChanged(s, v) end end, GetValue = function(s) return s.val or 0 end,
  SetChecked = function(s, v) s.checked = v and true or false end, GetChecked = function(s) return s.checked end,
  SetCheckedTexture = function(_, t) t.onlyChecked = true end, SetThumbTexture = function(s, t) s.thumb = t end,
  SetFrameLevel = function(s, l) s.level = l end, GetFrameLevel = function(s) return s.level or 1 end,
  SetParent = function(s, p) detach(s); s.parent = p; p.kids[#p.kids + 1] = s end, GetParent = function(s) return s.parent end,
  GetID = function(s) return s.ID or 0 end, SetID = function(s, i) s.ID = i end, GetName = function(s) return s.name end,
  GetEffectiveScale = function() return 1 end, GetZoom = function() return 0 end, GetScale = function() return 1 end,
  GetChildren = function(s) return unpack(s.kids) end, GetRegions = function(s) return unpack(s.regs) end,
  IsObjectType = function(s, t) return s.kind == t end, Click = function(s) if s.scripts.OnClick then s.scripts.OnClick(s, "LeftButton") end end,
}
new = function(kind, parent, layer)
  nextId = nextId + 1
  local o = setmetatable({ _oid = nextId, kind = kind, parent = parent, layer = layer, shown = true, scripts = {}, events = {}, kids = {}, regs = {} },
    { __index = function(_, k) return methods[k] or (type(k) == "string" and k:match("^%u") and function() end) or nil end })
  if parent then local l = (kind == "Texture" or kind == "FontString") and parent.regs or parent.kids; l[#l + 1] = o end
  all[#all + 1] = o
  return o
end
CreateFrame = function(kind, name, parent) local o = new(kind, parent or UIParent); o.name = name; if name then _G[name] = o end; return o end
CreateFont = function(name) local fo = { file = "FRIZQT", size = 12 }
  fo.SetFont = function(self, file, size) self.file = file:match("[^\\]+$"):gsub("%.%w+$", ""); self.size = size; return true end
  fo.SetShadowOffset = function() end; fo.SetShadowColor = function() end
  if name then _G[name] = fo end; return fo end
UIParent = new("Frame"); UIParent.w, UIParent.h = SW, SH; UIParent.root = true
STANDARD_TEXT_FONT = "Fonts\\FRIZQT__.TTF"
UISpecialFrames, SlashCmdList = {}, {}
tinsert, unpack, wipe = table.insert, unpack or table.unpack, function(t) for k in pairs(t) do t[k] = nil end return t end
strtrim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
hooksecurefunc = function(a, b, c)
  if type(a) == "table" then local old = a[b]; a[b] = function(...) local r = old and old(...); c(...); return r end
  else local old = _G[a]; _G[a] = function(...) local r = old and old(...); b(...); return r end end
end
-- chat e tooltip
CHAT = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) CHAT[#CHAT + 1] = m; if #CHAT > 60 then table.remove(CHAT, 1) end end }
GameTooltip = new("Frame", UIParent); GameTooltip.shown = false; GameTooltip.lines = {}
GameTooltip.SetOwner = function(s, o) s.owner = o; s.lines = {} end
GameTooltip.AddLine = function(s, t, r, g, b) s.lines[#s.lines + 1] = { t, r or 1, g or 0.82, b or 0 } end
GameTooltip.ClearLines = function(s) s.lines = {} end
-- il personaggio e il mondo (li cambia la pagina)
PLAYER = PLAYER or { race = "Human", class = "WARRIOR", faction = "Alliance", level = 18, spent = 8, cont = 1415, x = 0.46, y = 0.71, locale = "itIT" }
local CL = { WARRIOR = "Warrior", MAGE = "Mage", PRIEST = "Priest", ROGUE = "Rogue", HUNTER = "Hunter", WARLOCK = "Warlock", DRUID = "Druid", PALADIN = "Paladin", SHAMAN = "Shaman" }
GetLocale = function() return PLAYER.locale end
UnitRace = function() return PLAYER.race, PLAYER.race end
local CLASSID = { WARRIOR = 1, PALADIN = 2, HUNTER = 3, ROGUE = 4, PRIEST = 5, SHAMAN = 7, MAGE = 8, WARLOCK = 9, DRUID = 11 }
UnitClass = function() return CL[PLAYER.class] or PLAYER.class, PLAYER.class, CLASSID[PLAYER.class] end
UnitFactionGroup = function() return PLAYER.faction end
UnitLevel = function() return PLAYER.level end
UnitName = function() return "Aldric" end
GetBuildInfo = function() return "1.60.1", "70707", "Nov 5 2026", 16001 end
GetAddOnMetadata = function(_, k) return k == "Version" and "1.0.0" or nil end
GetCursorPosition = function() return CURSOR_X or 0, SH - (CURSOR_Y or 0) end
-- talenti: la guida dice l'ordine; i punti spesi seguono quell'ordine, divisi per albero
local function guideTal()
  local key = (PLAYER.raceKey or "human") .. "-" .. PLAYER.class:lower()
  local L = ForeverPathfinderData[(ForeverPathfinderDB or {}).lang or "en"]
  local g = L[key] or L["human-warrior"]
  local v = select(2, next(g.v))
  local P = ForeverPathfinderPool[(ForeverPathfinderDB or {}).lang or "en"]
  local list, trees, byTree = {}, {}, {}
  for name, tree in P[v.tal]:gmatch("([^:;]+):([^;]*)") do
    list[#list + 1] = { name, tree }
    if not byTree[tree] then byTree[tree] = {}; trees[#trees + 1] = tree end
    local seen = false
    for _, n in ipairs(byTree[tree]) do if n == name then seen = true end end
    if not seen then table.insert(byTree[tree], name) end
  end
  while #trees < 3 do trees[#trees + 1] = "—"; byTree["—"] = {} end
  return list, trees, byTree
end
GetNumTalentTabs = function() return 3 end
GetTalentTabInfo = function(i)
  local list, trees = guideTal()
  local n = 0
  for k = 1, math.min(PLAYER.spent, #list) do if list[k][2] == trees[i] then n = n + 1 end end
  return trees[i], nil, n
end
GetNumTalents = function(i) local _, trees, by = guideTal(); return #by[trees[i]] end
GetTalentInfo = function(i, j) local _, trees, by = guideTal(); return by[trees[i]][j], nil, 1, j, 0, 5 end
UnitCharacterPoints = function() return math.max(0, PLAYER.level - 9 - PLAYER.spent) end
PanelTemplates_GetSelectedTab = function(f) return f.selectedTab or 1 end
-- mappe: tre continenti (Zephras con un numero finto), nessuna zona; il segnaposto del gioco non c'è, si usa quello dell'addon
Enum = { UIMapType = { Continent = 2 } }
local CNAME = { [1414] = "Kalimdor", [1415] = "Eastern Kingdoms", [2000] = "Zephras Isle" }
C_Map = {
  GetMapChildrenInfo = function() return { { mapID = 1414, name = "Kalimdor" }, { mapID = 1415, name = "Eastern Kingdoms" }, { mapID = 2000, name = "Zephras Isle" } } end,
  -- zone: lo stesso rettangolo che l'addon ha in ForeverPathfinderZoneMaps (qui il continente finto è quello del sito)
  GetMapRectOnMap = function(a, b) if a == b then return 0, 1, 0, 1 end; for _, l in pairs(ForeverPathfinderZoneMaps or {}) do for _, z in ipairs(l) do if z[1] == a then return z[2], z[4], z[3], z[5] end end end end,
  GetMapInfoAtPosition = function() return nil end,
  GetMapInfo = function(id) local n = CNAME[id]; for _, l in pairs(ForeverPathfinderZoneMaps or {}) do for _, z in ipairs(l) do if z[1] == id then n = z[6] end end end; return { mapID = id, name = n } end,
  CanSetUserWaypointOnMap = function() return false end,
  GetBestMapForUnit = function() return PLAYER.cont end,
  GetPlayerMapPosition = function(m) if m == PLAYER.cont then return { GetXY = function() return PLAYER.x, PLAYER.y end } end end,
  GetMapWorldSize = function() return 36000, 24000 end,
}
-- registro delle quest (lo cambia la pagina: prendi, completa, consegna)
QUESTS = {}
GetNumQuestLogEntries = function() return #QUESTS end
GetQuestLogTitle = function(i) local q = QUESTS[i]; return q.title, PLAYER.level, nil, false, false, q.done and 1 or nil, nil, q.id end
-- Forever ha l'API moderna: l'addon legge C_QuestLog.GetInfo (quelle vecchie qui sopra restano solo per confronto)
C_QuestLog = { GetQuestInfo = function(id) for _, q in ipairs(QUESTS) do if q.id == id then return q.title end end end,
  GetNumQuestLogEntries = function() return #QUESTS end,
  GetInfo = function(i) local q = QUESTS[i]; return q and { title = q.title, questID = q.id, isHeader = false, level = PLAYER.level } end,
  IsComplete = function(id) for _, q in ipairs(QUESTS) do if q.id == id then return q.done == true end end return false end }

-- finestre di Blizzard finte, con fondo e bordo da texture (le disegna lo stesso motore)
local function panel(f, w, h, title)
  f:SetSize(w, h)
  local bg = f:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); bg:SetColorTexture(0.09, 0.08, 0.06, 0.96)
  local top = f:CreateTexture(nil, "BORDER"); top:SetPoint("TOPLEFT", 0, 0); top:SetSize(w, 26); top:SetColorTexture(0.28, 0.06, 0.04, 1)
  for _, e in ipairs({ { 0, 0, w, 2 }, { 0, -h + 2, w, 2 }, { 0, 0, 2, h }, { w - 2, 0, 2, h } }) do
    local t = f:CreateTexture(nil, "BORDER"); t:SetPoint("TOPLEFT", e[1], e[2]); t:SetSize(e[3], e[4]); t:SetColorTexture(0.55, 0.47, 0.3, 1)
  end
  local t = f:CreateFontString(nil, "OVERLAY", "GameFontNormal"); t:SetPoint("TOPLEFT", 10, -6); t:SetText(title); f.title = t
  local x = CreateFrame("Button", nil, f); x:SetPoint("TOPLEFT", w - 24, -3); x:SetSize(20, 20)
  local xb = x:CreateTexture(nil, "ARTWORK"); xb:SetAllPoints(); xb:SetColorTexture(0.55, 0.08, 0.05, 1)
  local xt = x:CreateFontString(nil, "OVERLAY", "GameFontHighlight"); xt:SetPoint("TOPLEFT", 6, -3); xt:SetText("x")
  x:SetScript("OnClick", function() f:Hide() end)
  f.shown = false
end
local function textButton(parent, label, x, y, w, h, fn)
  local b = CreateFrame("Button", nil, parent); b:SetPoint("TOPLEFT", x, y); b:SetSize(w, h)
  b.bg = b:CreateTexture(nil, "BACKGROUND"); b.bg:SetAllPoints(); b.bg:SetColorTexture(0.2, 0.17, 0.12, 1)
  b.fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); b.fs:SetPoint("TOPLEFT", 6, -5); b.fs:SetWidth(w - 12); b.fs:SetText(label)
  b:SetScript("OnClick", fn)
  return b
end
-- finestra dei talenti: tre schede (alberi della guida), un pulsante per talento; la guida dice dove sono i punti
TalentFrame = CreateFrame("Frame", "TalentFrame", UIParent); panel(TalentFrame, 340, 460, "Talents"); TalentFrame:SetPoint("TOPLEFT", 40, -90)
TalentFrame.selectedTab = 1
for i = 1, 3 do
  local b = textButton(TalentFrame, "", 10 + (i - 1) * 108, -32, 104, 22, function() TalentFrame.selectedTab = i; TalentFrame_Update() end)
  _G["TalentFrameTab" .. i] = b
end
for i = 1, 14 do
  local b = textButton(TalentFrame, "", 14 + ((i - 1) % 2) * 160, -66 - math.floor((i - 1) / 2) * 52, 150, 44, function() end)
  b:SetID(i); b.shown = false; _G["TalentFrameTalent" .. i] = b
end
TalentFrame_Update = function()
  local _, trees, by = guideTal()
  for i = 1, 3 do local n = select(3, GetTalentTabInfo(i)); _G["TalentFrameTab" .. i].fs:SetText(trees[i] .. " (" .. n .. ")")
    _G["TalentFrameTab" .. i].bg:SetColorTexture(i == TalentFrame.selectedTab and 0.45 or 0.2, i == TalentFrame.selectedTab and 0.12 or 0.17, i == TalentFrame.selectedTab and 0.08 or 0.12, 1) end
  local names = by[trees[TalentFrame.selectedTab]]
  for i = 1, 14 do local b = _G["TalentFrameTalent" .. i]
    if names[i] then b.fs:SetText(names[i]); b:Show() else b:Hide() end end
  TalentFrame.title:SetText("Talents · " .. UnitCharacterPoints("player") .. " punti liberi")
end
TalentFrame:SetScript("OnShow", function() TalentFrame_Update() end)
-- trainer: spell della guida fino a qualche livello sopra il tuo; quelli già imparati non sono più "available"
LEARNED = LEARNED or {}
-- spell nel libro: per nome il gioco trova solo quelle apprese (al trainer finto, o le prime del livello 1)
C_Spell = { GetSpellInfo = function(n) if LEARNED[n] then return { spellID = 1, name = n } end end }
IsPlayerSpell = function() return true end
TRAINER = {}
GetNumTrainerServices = function() return #TRAINER end
GetTrainerServiceInfo = function(i) local s = TRAINER[i]; if s then return s[1], "", LEARNED[s[1]] and "used" or (s[2] <= PLAYER.level and "available" or "unavailable") end end
ClassTrainerFrame = CreateFrame("Frame", "ClassTrainerFrame", UIParent); panel(ClassTrainerFrame, 340, 460, "Trainer"); ClassTrainerFrame:SetPoint("TOPLEFT", 40, -90)
for i = 1, 14 do
  local b = textButton(ClassTrainerFrame, "", 12, -34 - (i - 1) * 29, 316, 26, function(self)
    local s = TRAINER[self:GetID()]; if s and s[2] <= PLAYER.level then LEARNED[s[1]] = true; ClassTrainerFrame_Update(); FIRE("SPELLS_CHANGED") end end)
  b.shown = false; _G["ClassTrainerSkill" .. i] = b
end
ClassTrainerFrame_Update = function()
  for i = 1, 14 do local b = _G["ClassTrainerSkill" .. i]; local s = TRAINER[i]
    if s then local _, _, cat = GetTrainerServiceInfo(i); b:SetID(i)
      b.fs:SetText(s[1] .. "  ·  " .. (cat == "available" and "Impara" or cat == "used" and "imparato" or ("liv. " .. s[2])))
      b.fs:SetTextColor(cat == "available" and 0.2 or 0.6, cat == "available" and 1 or 0.6, cat == "available" and 0.2 or 0.6); b:Show()
    else b:Hide() end end
end
-- mappa del mondo: continente scelto dalla pagina, tela 1000×640; clic sulla tela = sposta il personaggio
WorldMapFrame = CreateFrame("Frame", "WorldMapFrame", UIParent); panel(WorldMapFrame, 1000, 640, "World Map"); WorldMapFrame:SetPoint("TOPLEFT", 140, -60)
local canvas = CreateFrame("Frame", nil, WorldMapFrame); canvas:SetPoint("TOPLEFT", 0, -26); canvas:SetSize(1000, 614); canvas.isCanvas = true
local cbg = canvas:CreateTexture(nil, "BACKGROUND"); cbg:SetAllPoints(); cbg:SetColorTexture(0.33, 0.29, 0.2, 1)
WorldMapFrame.ScrollContainer = { Child = canvas }
WorldMapFrame.GetMapID = function() return MAPID or PLAYER.cont end
WorldMapFrame.OnMapChanged = function() end
local you = canvas:CreateTexture(nil, "OVERLAY"); you:SetSize(14, 14); you:SetColorTexture(1, 0.85, 0.1, 1); WorldMapFrame.you = you
canvas:SetScript("OnClick", function(_, _, x, y) PLAYER.cont = WorldMapFrame:GetMapID(); PLAYER.x, PLAYER.y = x / 1000, y / 614 end)
-- minimappa in alto a destra
Minimap = CreateFrame("Frame", "Minimap", UIParent); Minimap:SetPoint("TOPLEFT", SW - 170, -20); Minimap:SetSize(140, 140); Minimap.round = true
Minimap.GetCenter = function() return SW - 100, SH - 90 end
-- LibDBIcon e LibDataBroker come li porta Questie: un pulsante tondo sul bordo della minimappa
local LIBS = { ["LibDataBroker-1.1"] = { NewDataObject = function(_, _, o) return o end } }
LIBS["LibDBIcon-1.0"] = {
  btn = {},
  Register = function(self, n, o)
    local b = CreateFrame("Button", "LibDBIcon10_" .. n, Minimap); b:SetSize(31, 31); b:SetPoint("CENTER", Minimap, "CENTER", -75, -27)
    local ic = b:CreateTexture(nil, "BACKGROUND"); ic:SetTexture(o.icon); ic:SetSize(20, 20); ic:SetPoint("TOPLEFT", 7, -5)
    local bd = b:CreateTexture(nil, "OVERLAY"); bd:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder"); bd:SetSize(53, 53); bd:SetPoint("TOPLEFT")
    b:SetScript("OnClick", function(_, btn) o.OnClick(b, btn) end)
    b:SetScript("OnEnter", function() GameTooltip:SetOwner(b, "ANCHOR_LEFT"); o.OnTooltipShow(GameTooltip); GameTooltip:Show() end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    self.btn[n] = b
  end,
  IsRegistered = function(self, n) return self.btn[n] ~= nil end,
  Show = function(self, n) self.btn[n]:Show() end, Hide = function(self, n) self.btn[n]:Hide() end,
}
LibStub = function(n) return LIBS[n] end
ShowUIPanel = function(fr) fr:SetParent(UIParent); fr:Show() end
WorldMapFrame.SetMapID = function(_, id) MAPID = id end

-- Questie finto (l'addon lo richiede): ID per nome, quest già consegnate (QDONE, salvate con il personaggio),
-- mappa con i suoi segni (! chi dà la quest, ? obiettivi e consegna) e la scheda della quest nel suo Journey
QDONE = QDONE or {}
local QNAME = {}
local function QID(name) local h = 0; for i = 1, #name do h = (h * 31 + name:byte(i)) % 100000 end; QNAME[h + 1] = name; return h + 1 end
LibQuestieDB = { Quest = { IdsByName = function(n) return { QID(n) } end } }
Questie = { API = { isReady = true, RegisterOnReady = function(cb) cb() end }, db = { char = { complete = QDONE } } }
C_AddOns = { IsAddOnLoaded = function(n) return n == "Questie" or n == "OneForAll" or n == "MapUtils" end }
-- dove la guida mette la quest (primo segnaposto della voce che la nomina): lì il segno di Questie
local function questPin(title)
  local L = ForeverPathfinderLinks[(ForeverPathfinderDB or {}).lang or "en"] or {}
  for _, l in pairs(L) do for _, q in ipairs(l.q) do if q == title and l.p[1] then return l.p[1] end end end
end
local CONTID = { k = 1414, e = 1415, z = 2000 }
local qMark = canvas:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge"); qMark.shown = false
local function questieShow(title, sign)
  local p = questPin(title)
  if p then MAPID = CONTID[p[1]]; qMark:SetText(sign); qMark:SetTextColor(1, 0.82, 0); qMark:SetPoint("TOPLEFT", p[2] * 1000 - 6, -p[3] * 614 + 14); qMark.cont = MAPID; qMark:Show() end
  WorldMapFrame:SetParent(UIParent); WorldMapFrame:Show(); WorldMapFrame:OnMapChanged()
  DEFAULT_CHAT_FRAME:AddMessage("|cff1eff00Questie|r " .. (sign == "!" and "chi dà" or "obiettivi e consegna di") .. " |cffffd100" .. title .. "|r sulla mappa" .. (p and "" or " (posizione non nota al banco di prova)"))
  return true
end
local journey = CreateFrame("Frame", "QuestieJourneyFrame", UIParent); panel(journey, 380, 220, "Questie · My Journey"); journey:SetPoint("TOPLEFT", 460, -120)
local jText = journey:CreateFontString(nil, "OVERLAY", "GameFontHighlight"); jText:SetPoint("TOPLEFT", 14, -40); jText:SetWidth(352)
local QMOD = {
  QuestieDB = { IsDoable = function() return true end, QueryQuestSingle = function(id, k) return k == "startedBy" and { { id } } or nil end,
    QueryNPCSingle = function() return { [1] = { { 50, 50 } } } end, QueryObjectSingle = function() end },
  ZoneDB = { GetUiMapIdByAreaId = function() return PLAYER.cont end },
  QuestieMap = { ShowNPC = function(_, id) questieShow(QNAME[id] or "?", "!") end, ShowObject = function() end },
  QuestieCompat = { OpenWorldMap = function() return true end },
  TrackerUtils = { ShowQuestOnMap = function(id) return questieShow(QNAME[id] or "?", "?") end },
  QuestieJourney = { IsShown = function() return journey.shown end, ToggleJourneyWindow = function() if journey.shown then journey:Hide() else journey:SetParent(UIParent); journey:Show() end end, tabGroup = { SelectTab = function() end } },
  QuestieSearchResults = { SetSearch = function(_, _, id)
    local t, st = QNAME[id] or "?", "da prendere"
    for _, q in ipairs(QUESTS) do if q.title == t then st = q.done and "completa, da consegnare" or "nel registro" end end
    if QDONE[id] then st = "consegnata" end
    local p = questPin(t)
    jText:SetText("|cffffd100" .. t .. "|r\n\nQuest ID " .. id .. " · " .. st .. (p and ("\nIniziata da: " .. p[4]) or "") .. "\n\n(Scheda Cerca del Journey di Questie: nel gioco vero obiettivi, ricompense e NPC.)")
  end },
}
QuestieLoader = { ImportModule = function(_, n) return QMOD[n] end }
-- quest che Questie sa già consegnate (fatte prima di installare l'addon): la pagina le segna, poi /reload
function QUEST_PAST(t) QDONE[QID(t)] = true end

-- OneForAll finto: finestra con la scheda Talent Trees (pulsante "Import build") o Dungeons & Raids
local ofaF = CreateFrame("Frame", "OneForAllFrame", UIParent); panel(ofaF, 460, 420, "OneForAll"); ofaF:SetPoint("TOPLEFT", 420, -80)
local ofaText = ofaF:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); ofaText:SetPoint("TOPLEFT", 14, -70); ofaText:SetWidth(432)
local ofaRanks = {}
OneForAll = { TalentCode = {
    Encode = function(cls, ranks) ofaRanks = ranks; local n = 0; for _, r in pairs(ranks) do n = n + r end; return "OFA1:" .. tostring(cls) .. ":" .. n end,
    ShowImport = function() end,
    ShowExport = function(code) ofaText:SetText("Export build\n\n" .. code .. "\n\n(Ctrl+C, poi Import)") end },
  OpenPanel = function(_, key) ofaF.title:SetText(key == "talents" and "OneForAll · Talent Trees" or "OneForAll · Dungeons & Raids"); ofaText:SetText(""); ofaF.imp[key == "talents" and "Show" or "Hide"](ofaF.imp); ofaF:SetParent(UIParent); ofaF:Show() end, -- SetParent: in cima, come la sua strata DIALOG
  DUNGEONS = {}, UI = { OpenDungeon = function(d) ofaText:SetText("|cffffd100" .. d.name .. "|r\n\nBoss, loot e quest del dungeon nella scheda Dungeons di OneForAll (qui una finestra finta).") end } }
ofaF.imp = textButton(ofaF, "Import build", 14, -34, 120, 24, function()
  OneForAll.TalentCode.ShowImport(function(code)
    local list = {}
    for k, r in pairs(ofaRanks) do list[#list + 1] = k .. " " .. r end
    table.sort(list)
    ofaText:SetText("|cff66ff66Build imported|r  " .. code .. "\n\n" .. table.concat(list, " · "))
  end)
end)

-- caricamento dell'addon con i salvataggi passati dalla pagina
function LOAD_ADDON(data, core)
  assert(load(data, "Data.lua"))()
  Questie.db.char.complete = QDONE -- QDONE arriva dai salvataggi della pagina
  OneForAll.DUNGEONS = {}
  for _, d in ipairs(ForeverPathfinderDungeonPos or {}) do OneForAll.DUNGEONS[#OneForAll.DUNGEONS + 1] = { name = d[1] } end
  assert(load(core, "Core.lua"))("ForeverPathfinder")
  for _, o in ipairs(all) do if o.events.ADDON_LOADED and o.scripts.OnEvent then o.scripts.OnEvent(o, "ADDON_LOADED", "ForeverPathfinder") end end
  FIRE("PLAYER_LOGIN")
end
function FIRE(e, a)
  for _, o in ipairs(all) do if o.events[e] and o.scripts.OnEvent then o.scripts.OnEvent(o, e, a) end end
end
function SLASH(msg) SlashCmdList.FOREVERPATHFINDER(msg) end
-- elenco del trainer: gli spell delle voci "Trainer:" della guida (stessa variante delle Opzioni), da 8 livelli sotto a 6 sopra
function MAKE_TRAINER()
  local lang = (ForeverPathfinderDB or {}).lang or "en"
  local g = ForeverPathfinderData[lang][(PLAYER.raceKey or "human") .. "-" .. PLAYER.class:lower()]
  if not g then TRAINER = {}; return end
  local o = (ForeverPathfinderChar or {}).opt or {}
  local b = o.b or (g.builds[1] and g.builds[1][1]) or "a"
  local v = g.v[b .. (o.dg or 1) .. (g.x and o.x or 0)] or select(2, next(g.v))
  local P, G = ForeverPathfinderPool[lang], ForeverPathfinderPages[lang]
  TRAINER = {}
  for lv, _, k in G[v.tasks]:gmatch("(%d+),(%d+),(%d+)") do
    lv = tonumber(lv)
    local list = P[tonumber(k)]:gsub("^%^[^%^]*%^", ""):match("^Trainer:%s*(.+)$")
    if list and lv >= PLAYER.level - 8 and lv <= PLAYER.level + 6 then
      for nme in list:gsub("%b()", ""):gmatch("[^,;]+") do
        nme = strtrim(nme)
        local dup = false
        for _, s in ipairs(TRAINER) do if s[1] == nme then dup = true end end -- un rank nuovo dello stesso spell: una riga sola
        if not dup and #TRAINER < 14 then TRAINER[#TRAINER + 1] = { nme, lv } end
      end
    end
  end
end
-- quest della tappa del tuo livello che la guida nomina (per i pulsanti Prendi / Completa / Consegna della pagina)
function STAGE_QUESTS()
  local lang = (ForeverPathfinderDB or {}).lang or "en"
  local g = ForeverPathfinderData[lang][(PLAYER.raceKey or "human") .. "-" .. PLAYER.class:lower()]
  if not g then return "[]" end
  local o = (ForeverPathfinderChar or {}).opt or {}
  local b = o.b or (g.builds[1] and g.builds[1][1]) or "a"
  local v = g.v[b .. (o.dg or 1) .. (g.x and o.x or 0)] or select(2, next(g.v))
  local P, G, L = ForeverPathfinderPool[lang], ForeverPathfinderPages[lang], ForeverPathfinderLinks[lang]
  local ch, rows, seen = 1, {}, {}
  for lv, c in G[v.tasks]:gmatch("(%d+),(%d+),%d+") do if tonumber(lv) <= PLAYER.level then ch = tonumber(c) end end
  for lv, c, k in G[v.tasks]:gmatch("(%d+),(%d+),(%d+)") do
    local l = L[tonumber(k)]
    if tonumber(c) == ch and l then for _, q in ipairs(l.q) do if not seen[q] then seen[q] = true; rows[#rows + 1] = '{"t":' .. jstr(q) .. ',"lv":' .. lv .. ',"turned":' .. tostring(((ForeverPathfinderChar or {}).turned or {})[q] == true or QDONE[QID(q)] == true) .. '}' end end end
  end
  return "[" .. table.concat(rows, ",") .. "]"
end

-- geometria e istantanea per la pagina
local PTS = { TOPLEFT = { 0, 0 }, TOP = { 0.5, 0 }, TOPRIGHT = { 1, 0 }, LEFT = { 0, 0.5 }, CENTER = { 0.5, 0.5 }, RIGHT = { 1, 0.5 }, BOTTOMLEFT = { 0, 1 }, BOTTOM = { 0.5, 1 }, BOTTOMRIGHT = { 1, 1 } }
local R
local function size(o)
  if o.kind == "FontString" then local m = measure(o.fo, o.w, o.text or ""); return o.w or m[1], m[2] end
  return o.w or 0, o.h or 0
end
local function rect(o)
  if R[o] then return unpack(R[o]) end
  local l, t, w, h
  if o.root then l, t, w, h = 0, 0, SW, SH
  elseif o.parent and o.parent.child == o then
    local pl, pt = rect(o.parent); l, t = pl, pt - (o.parent.off or 0); w, h = size(o)
  elseif o.fill then l, t, w, h = rect(o.parent)
  else
    w, h = size(o)
    local rl, rt, rw, rh = rect(o.pt and o.pt.rel or o.parent)
    local p, rp, x, y = "TOPLEFT", "TOPLEFT", 0, 0
    if o.pt then p, rp, x, y = o.pt.p, o.pt.rp or o.pt.p, o.pt.x, o.pt.y end
    if o == ForeverPathfinderFrame and o.pt and o.pt.p == "CENTER" and not o.pt.rel then rl, rt, rw, rh = 0, 0, SW, SH end
    local a, b = PTS[p] or PTS.TOPLEFT, PTS[rp] or PTS.TOPLEFT
    l = rl + b[1] * rw + x - a[1] * w
    t = rt + b[2] * rh - y - a[2] * h
  end
  R[o] = { l, t, w, h }
  return l, t, w, h
end
local function n(x) return string.format("%.1f", x) end
local items
local function emit(s) items[#items + 1] = s end
local function walk(o)
  if not o.shown then return end
  local l, t, w, h = rect(o)
  if o.round then emit('{"k":"minimap","l":' .. n(l) .. ',"t":' .. n(t) .. ',"w":' .. n(w) .. ',"h":' .. n(h) .. '}') end
  local regs = {}
  for i, r in ipairs(o.regs) do regs[#regs + 1] = { r, i } end
  table.sort(regs, function(a, b) local la, lb = LAYERS[a[1].layer] or 3, LAYERS[b[1].layer] or 3; if la ~= lb then return la < lb end return a[2] < b[2] end)
  for _, e in ipairs(regs) do
    local r = e[1]
    if r.shown and r.layer ~= "HIGHLIGHT" and r ~= o.thumb and (not r.onlyChecked or o.checked) then
      local rl, rt, rw, rh = rect(r)
      local op = r.op or 1
      if r.kind == "FontString" and r.text and r.text ~= "" then
        local tc = r.tc or { 1, 1, 1 }
        emit('{"k":"text","l":' .. n(rl) .. ',"t":' .. n(rt) .. ',"ww":' .. (r.w or 0) .. ',"file":' .. jstr(r.fo.file) .. ',"size":' .. r.fo.size .. ',"c":[' .. tc[1] .. ',' .. tc[2] .. ',' .. tc[3] .. '],"text":' .. jstr(r.text) .. '}')
      elseif r.kind == "Texture" and r.color then
        emit('{"k":"rect","l":' .. n(rl) .. ',"t":' .. n(rt) .. ',"w":' .. n(rw) .. ',"h":' .. n(rh) .. ',"c":[' .. r.color[1] .. ',' .. r.color[2] .. ',' .. r.color[3] .. '],"a":' .. (r.alpha * op) .. '}')
      elseif r.kind == "Texture" and r.tex then
        emit('{"k":"icon","l":' .. n(rl) .. ',"t":' .. n(rt) .. ',"w":' .. n(rw) .. ',"h":' .. n(rh) .. ',"a":' .. op .. ',"path":' .. jstr(r.tex) .. '}')
      end
    end
  end
  if o.kind == "Slider" and o.thumb and (o.max or 0) > 0 then
    emit('{"k":"rect","l":' .. n(l) .. ',"t":' .. n(t + (o.val or 0) / o.max * (h - 48)) .. ',"w":6,"h":48,"c":[0.33,0.45,0.58],"a":1}')
  end
  -- zone cliccabili: pulsanti, caselle, la tela della mappa, la zona che scorre, le finestre da trascinare
  local s = o.scripts
  if s.OnClick or s.OnMouseWheel or o.drag or s.OnEnter then
    emit('{"k":"hit","id":' .. o._oid .. ',"l":' .. n(l) .. ',"t":' .. n(t) .. ',"w":' .. n(w) .. ',"h":' .. n(h) .. ',"click":' .. tostring(s.OnClick ~= nil) .. ',"wheel":' .. tostring(s.OnMouseWheel ~= nil) .. ',"drag":' .. tostring(o.drag == true) .. ',"enter":' .. tostring(s.OnEnter ~= nil) .. '}')
  end
  if o.kind == "ScrollFrame" then
    emit('{"k":"clip","l":' .. n(l) .. ',"t":' .. n(t) .. ',"w":' .. n(w) .. ',"h":' .. n(h) .. '}')
    if o.child then walk(o.child) end
    emit('{"k":"endclip"}')
  end
  local kids = {}
  for i, c in ipairs(o.kids) do if c ~= o.child then kids[#kids + 1] = { c, i } end end
  table.sort(kids, function(a, b) local la, lb = a[1].level or 0, b[1].level or 0; if la ~= lb then return la < lb end return a[2] < b[2] end)
  for _, c in ipairs(kids) do if c[1] ~= GameTooltip then walk(c[1]) end end
end
function SNAP()
  R, items = {}, {}
  if WorldMapFrame.shown then local yl, yt = PLAYER.x * 1000 - 7, PLAYER.y * 614 - 7
    WorldMapFrame.you:SetPoint("TOPLEFT", yl, -yt); WorldMapFrame.you.shown = (WorldMapFrame:GetMapID() == PLAYER.cont) end
  walk(UIParent)
  local tip = "null"
  if GameTooltip.shown and GameTooltip.owner then
    local l, t, w, h = rect(GameTooltip.owner)
    local ls = {}
    for _, x in ipairs(GameTooltip.lines) do ls[#ls + 1] = '[' .. jstr(x[1]) .. ',' .. x[2] .. ',' .. x[3] .. ',' .. x[4] .. ']' end
    tip = '{"l":' .. n(l) .. ',"t":' .. n(t) .. ',"w":' .. n(w) .. ',"h":' .. n(h) .. ',"lines":[' .. table.concat(ls, ",") .. ']}'
  end
  local ch = {}
  for i = math.max(1, #CHAT - 14), #CHAT do ch[#ch + 1] = jstr(CHAT[i]) end
  local q = {}
  for _, x in ipairs(QUESTS) do q[#q + 1] = '{"title":' .. jstr(x.title) .. ',"done":' .. tostring(x.done == true) .. ',"id":' .. x.id .. '}' end
  return '{"items":[' .. table.concat(items, ",") .. '],"tip":' .. tip .. ',"chat":[' .. table.concat(ch, ",") .. '],"quests":[' .. table.concat(q, ",") .. '],"free":' .. UnitCharacterPoints() .. ',"map":' .. tostring(WorldMapFrame.shown) .. ',"mapid":' .. WorldMapFrame:GetMapID() .. '}'
end
local function byId(id) for _, o in ipairs(all) do if o._oid == id then return o end end end
function CLICK(id, btn, x, y)
  local o = byId(id); if not (o and o.scripts.OnClick) then return end
  if o.kind == "CheckButton" then o.checked = not o.checked end
  o.scripts.OnClick(o, btn or "LeftButton", x, y)
end
function WHEEL(id, d) local o = byId(id); if o and o.scripts.OnMouseWheel then o.scripts.OnMouseWheel(o, d) end end
function ENTER(id) local o = byId(id); if o and o.scripts.OnEnter then o.scripts.OnEnter(o) end end
function LEAVE(id) local o = byId(id); if o and o.scripts.OnLeave then o.scripts.OnLeave(o) end end
local moving
function DRAGSTART(id) local o = byId(id); if o and o.scripts.OnDragStart then o.scripts.OnDragStart(o); moving = o end end
function DRAGMOVE(dx, dy) if moving and moving.moving then local p = moving.pt or { p = "CENTER", x = 0, y = 0 }; p.x, p.y = p.x + dx, p.y - dy; moving.pt = p end end
function DRAGSTOP() if moving and moving.scripts.OnDragStop then moving.scripts.OnDragStop(moving) end; moving = nil end
function TICK(dt) local any = false
  for _, o in ipairs(all) do if o.shown and o.scripts.OnUpdate then o.scripts.OnUpdate(o, dt); any = true end end
  return any end
-- salvataggi da passare al prossimo /reload (testo Lua)
local function ser(v, ind)
  if type(v) == "table" then local p = {}
    for k, x in pairs(v) do if type(x) ~= "function" then p[#p + 1] = "[" .. (type(k) == "string" and string.format("%q", k) or tostring(k)) .. "]=" .. ser(x) end end
    return "{" .. table.concat(p, ",") .. "}" end
  if type(v) == "string" then return string.format("%q", v) end
  return tostring(v)
end
function SAVED_CHAR() return "ForeverPathfinderChar=" .. ser(ForeverPathfinderChar or {}) .. "\nQDONE=" .. ser(QDONE) end
function SAVED_DB() return "ForeverPathfinderDB=" .. ser(ForeverPathfinderDB or {}) end
-- comandi della pagina
function SETCURSOR(x, y) CURSOR_X, CURSOR_Y = x, y end
function SNAPPOS() return '{"cont":' .. PLAYER.cont .. ',"x":' .. PLAYER.x .. ',"y":' .. PLAYER.y .. '}' end
function SAYCHAT(t) DEFAULT_CHAT_FRAME:AddMessage("|cffffffff[Aldric]: " .. t .. "|r") end
function SPENT() return PLAYER.spent end
local qid = 1000
function QUEST_ADD(t) for _, q in ipairs(QUESTS) do if q.title == t then return end end; qid = qid + 1; QUESTS[#QUESTS + 1] = { title = t, id = qid }; FIRE("QUEST_LOG_UPDATE") end
function QUEST_DONE(id) for _, q in ipairs(QUESTS) do if q.id == id then q.done = true end end; FIRE("QUEST_LOG_UPDATE") end
function QUEST_TURNIN(id) for i, q in ipairs(QUESTS) do if q.id == id then table.remove(QUESTS, i); QUEST_PAST(q.title); FIRE("QUEST_TURNED_IN", id); break end end; FIRE("QUEST_LOG_UPDATE") end
function KEYS() local k = {}
  for key in pairs(ForeverPathfinderData.it) do if key:sub(1, 1) ~= "_" then k[#k + 1] = jstr(key) end end
  table.sort(k); return "[" .. table.concat(k, ",") .. "]" end
function TOGGLE(name) local f = _G[name]; if f.shown then f:Hide() else f:SetParent(UIParent); f:Show() end end
function SET_MAP(id) MAPID = id; if qMark.cont ~= id then qMark:Hide() end; WorldMapFrame:OnMapChanged() end
function OPEN_TRAINER() MAKE_TRAINER(); ClassTrainerFrame:Show(); FIRE("TRAINER_SHOW"); ClassTrainerFrame_Update() end
function LEVEL(lv) PLAYER.level = lv; FIRE("PLAYER_LEVEL_UP", lv); if TalentFrame.shown then TalentFrame_Update() end end
function SPEND() if UnitCharacterPoints() > 0 then PLAYER.spent = PLAYER.spent + 1; FIRE("CHARACTER_POINTS_CHANGED"); if TalentFrame.shown then TalentFrame_Update() end end end
