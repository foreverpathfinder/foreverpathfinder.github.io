-- Forever Pathfinder: finestra con le voci della guida per il tuo livello e il prossimo talento.
-- Dati in Data.lua (generati da src/tools/addon.js dal sito). /fp apre e chiude, /fp dungeon e /fp cerca scrivono in chat.
local ADDON = ...
local LANG = GetLocale() == "itIT" and "it" or "en"
local D = ForeverPathfinderData[LANG] or ForeverPathfinderData.en
local DG = ForeverPathfinderDungeons and (ForeverPathfinderDungeons[LANG] or ForeverPathfinderDungeons.en) or {}

local T = ({
  it = {
    level = "Liv. %d", stage = "Tappa %d: %s", build = "Build: %s",
    talentNow = "Talento da prendere ora: %s (%s)", talentNext = "Prossimo talento al liv. %d: %s (%s)", talentDone = "Talenti della guida completati.",
    none = "Nessuna voce a questo livello: prosegui con la tappa.",
    unknown = "Razza o classe non riconosciute. Scrivi /fp set razza-classe (es. /fp set human-warrior); /fp list per l'elenco.",
    help = "/fp apre o chiude · /fp dungeon · /fp cerca parola · /fp set razza-classe · /fp auto · /fp list",
    dungeon = "Dungeon: %s · /fp dungeon per le quest", go = "vai", opt = "facoltativo",
    dgNone = "Nessun dungeon consigliato al liv. %d.", dgEntry = "Ingresso: %s", dgQuests = "Prima di entrare prendi:", dgClass = "(di classe)",
    found = "Trovate %d voci per \"%s\":", notFound = "Nessuna voce della guida contiene \"%s\".", lv = "Liv.",
    loaded = "caricato: /fp per aprire la guida.",
  },
  en = {
    level = "Lvl %d", stage = "Stage %d: %s", build = "Build: %s",
    talentNow = "Talent to take now: %s (%s)", talentNext = "Next talent at lvl %d: %s (%s)", talentDone = "Guide talents done.",
    none = "Nothing at this level: keep going with the stage.",
    unknown = "Race or class not recognized. Type /fp set race-class (e.g. /fp set human-warrior); /fp list for the list.",
    help = "/fp opens or closes · /fp dungeon · /fp find word · /fp set race-class · /fp auto · /fp list",
    dungeon = "Dungeon: %s · /fp dungeon for the quests", go = "go", opt = "optional",
    dgNone = "No recommended dungeon at lvl %d.", dgEntry = "Entrance: %s", dgQuests = "Before going in, pick up:", dgClass = "(class)",
    found = "Found %d items for \"%s\":", notFound = "No guide item contains \"%s\".", lv = "Lvl",
    loaded = "loaded: /fp opens the guide.",
  },
})[LANG]

-- token inglese di UnitRace → chiave del sito (Skyborne: una per fazione)
local RACES = { Human = "human", Dwarf = "dwarf", Gnome = "gnome", NightElf = "nightelf", Orc = "orc", Troll = "troll", Tauren = "tauren", Scourge = "undead", Undead = "undead" }

local C -- ForeverPathfinderChar: { done = {}, key = "razza-classe" scelto a mano }
local view -- livello mostrato

local function say(msg) DEFAULT_CHAT_FRAME:AddMessage("|cffe8b84aForever Pathfinder|r " .. msg) end

local function charKey()
  if C.key then return C.key end
  local _, r = UnitRace("player")
  local _, c = UnitClass("player")
  r = RACES[r] or (r and r:lower():find("skyborne") and (UnitFactionGroup("player") == "Horde" and "skyborne_h" or "skyborne_a"))
  return r and c and (r .. "-" .. c:lower())
end

local function guide() local k = charKey(); return k and D[k], k end

-- dungeon adatti al livello per la fazione del percorso (come nella scheda Dungeon: niente "salta"), nel livello ideale
local ALLIANCE = { human = true, dwarf = true, gnome = true, nightelf = true, skyborne_a = true }
local function dungeonsAt(k, lv)
  local fac = ALLIANCE[(k or ""):match("^([^-]+)")] and "A" or "H"
  local out = {}
  for _, d in ipairs(DG[fac] or {}) do
    -- livello ideale del giudizio ("18–22", "30+") se c'è, altrimenti tutto il range del dungeon
    local lo, hi = d[5]:match("(%d+)%D+(%d+)")
    if not lo then lo = d[5]:match("(%d+)%+"); hi = lo and d[3] end
    lo, hi = tonumber(lo) or d[2] - 1, tonumber(hi) or d[3]
    if d[4] ~= "skip" and lv >= lo and lv <= hi then out[#out + 1] = d end
  end
  return out
end
local function dgLabel(d) return d[1] .. " (" .. (T[d[4]] or "?") .. (d[5] ~= "" and " " .. d[5] or "") .. ")" end

-- prossimo talento: i punti già spesi dicono a che punto dell'ordine della guida sei
local function talentLine(g)
  local spent = 0
  for i = 1, (GetNumTalentTabs and GetNumTalentTabs() or 0) do spent = spent + (select(3, GetTalentTabInfo(i)) or 0) end
  local t = g.tal[spent + 1]
  if not t then return T.talentDone end
  local free = UnitCharacterPoints and UnitCharacterPoints("player") or 0
  if free > 0 then return T.talentNow:format(t[2], t[3]) end
  return T.talentNext:format(t[1], t[2], t[3])
end

-- finestra
local f = CreateFrame("Frame", "ForeverPathfinderFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
f:SetSize(330, 120)
f:SetPoint("RIGHT", UIParent, "RIGHT", -60, 60)
f:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
f:SetBackdropColor(0.03, 0.07, 0.12, 0.9)
f:SetMovable(true); f:EnableMouse(true); f:SetClampedToScreen(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)
f:Hide()

local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", 12, -10); title:SetWidth(240); title:SetJustifyH("LEFT")
local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", 0, 0)
local prev = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
prev:SetSize(24, 20); prev:SetText("<"); prev:SetPoint("TOPRIGHT", -56, -8)
local nextB = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
nextB:SetSize(24, 20); nextB:SetText(">"); nextB:SetPoint("TOPRIGHT", -30, -8)
local sub = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
sub:SetPoint("TOPLEFT", 12, -30); sub:SetWidth(306); sub:SetJustifyH("LEFT")
local tal = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
tal:SetWidth(306); tal:SetJustifyH("LEFT")
local dgl = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
dgl:SetWidth(306); dgl:SetJustifyH("LEFT"); dgl:SetTextColor(0.66, 0.89, 1)
local rows = {}

local function row(i)
  if rows[i] then return rows[i] end
  local cb = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
  cb:SetSize(20, 20)
  cb.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  cb.text:SetWidth(278); cb.text:SetJustifyH("LEFT")
  cb:SetScript("OnClick", function(self) C.done[self.id] = self:GetChecked() and true or nil end)
  rows[i] = cb
  return cb
end

local function refresh()
  local g, k = guide()
  for _, r in ipairs(rows) do r:Hide(); r.text:Hide() end
  if not g then
    title:SetText("Forever Pathfinder"); sub:SetText(T.unknown); tal:SetText(""); dgl:SetText("")
    tal:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -6); f:SetHeight(48 + sub:GetStringHeight()); return
  end
  local ch = 1
  for _, t in ipairs(g.tasks) do if t[1] <= view then ch = t[2] end end
  title:SetText(g.name .. " · " .. T.level:format(view))
  sub:SetText(T.stage:format(ch, ((g.ch[ch] or ""):gsub("^%d+%.%s*", ""))) .. "\n" .. T.build:format(g.build))
  tal:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -6)
  tal:SetText(talentLine(g))
  local ds, names = dungeonsAt(k, view), {}
  for _, d in ipairs(ds) do names[#names + 1] = dgLabel(d) end
  dgl:SetPoint("TOPLEFT", tal, "BOTTOMLEFT", 0, -4)
  dgl:SetText(#ds > 0 and T.dungeon:format(table.concat(names, ", ")) or "")
  -- un livello a cavallo di due tappe compare in entrambe: ogni voce una volta sola
  local y, n, seen = -(36 + sub:GetStringHeight() + 8 + tal:GetStringHeight() + (#ds > 0 and dgl:GetStringHeight() + 4 or 0) + 8), 0, {}
  for i, t in ipairs(g.tasks) do
    if t[1] == view and not seen[t[3]] then
      seen[t[3]] = true
      n = n + 1
      local r = row(n)
      r.id = k .. ":" .. i
      r:SetChecked(C.done[r.id] and true or false)
      r:SetPoint("TOPLEFT", 10, y)
      r.text:SetPoint("TOPLEFT", 36, y - 3)
      r.text:SetText(t[3])
      r:Show(); r.text:Show()
      y = y - math.max(20, r.text:GetStringHeight()) - 6
    end
  end
  if n == 0 then
    local r = row(1); r.text:SetPoint("TOPLEFT", 14, y - 3); r.text:SetText(T.none); r.text:Show()
    y = y - r.text:GetStringHeight() - 6
  end
  f:SetHeight(-y + 10)
end

prev:SetScript("OnClick", function() view = math.max(1, view - 1); refresh() end)
nextB:SetScript("OnClick", function() view = math.min(60, view + 1); refresh() end)

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("CHARACTER_POINTS_CHANGED")
f:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" then
    if arg1 ~= ADDON then return end
    ForeverPathfinderChar = ForeverPathfinderChar or {}
    C = ForeverPathfinderChar
    C.done = C.done or {}
    view = UnitLevel("player")
    say(T.loaded)
    if not guide() then say(T.unknown) end
  elseif event == "PLAYER_LEVEL_UP" then
    view = arg1
  end
  if f:IsShown() then refresh() end
end)

SLASH_FOREVERPATHFINDER1 = "/fp"
SLASH_FOREVERPATHFINDER2 = "/pathfinder"
SlashCmdList.FOREVERPATHFINDER = function(msg)
  local cmd, arg = (msg or ""):lower():match("^%s*(%S*)%s*(.-)%s*$")
  if cmd == "set" then
    if D[arg] then C.key = arg; say(D[arg].name) else say(T.unknown) end
  elseif cmd == "auto" then
    C.key = nil
  elseif cmd == "list" then
    local keys = {}
    for key in pairs(D) do keys[#keys + 1] = key end -- solo le combinazioni razza-classe
    table.sort(keys); say(table.concat(keys, ", ")); return
  elseif cmd == "dungeon" or cmd == "dungeons" or cmd == "dg" then
    -- in chat: per ogni dungeon del livello mostrato (o di quello attuale) giudizio, ingresso, quest da prendere prima
    local g, k = guide()
    if not g then say(T.unknown); return end
    local lv = f:IsShown() and view or UnitLevel("player")
    local ds = dungeonsAt(k, lv)
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
    -- cerca il testo in tutte le voci della guida: le prime 8 in chat, la finestra si apre al livello della prima
    local g = guide()
    if not g then say(T.unknown); return end
    local hits, seen = {}, {}
    for _, t in ipairs(g.tasks) do
      if arg ~= "" and not seen[t[3]] and t[3]:lower():find(arg, 1, true) then seen[t[3]] = true; hits[#hits + 1] = t end
    end
    if #hits == 0 then say(T.notFound:format(arg)); return end
    say(T.found:format(#hits, arg))
    for i = 1, math.min(8, #hits) do DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100" .. T.lv .. " " .. hits[i][1] .. "|r " .. hits[i][3]:sub(1, 140)) end
    view = hits[1][1]; f:Show(); refresh(); return
  elseif cmd == "help" or cmd == "?" then
    say(T.help); return
  elseif f:IsShown() then
    f:Hide(); return
  end
  view = UnitLevel("player")
  f:Show(); refresh()
end
