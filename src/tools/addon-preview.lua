-- WoW finto con geometria per src/tools/addon-preview.js: registra frame, texture e testi dell addon per disegnarli in HTML
-- Globali: DIR, LOCALE, MEAS (JSON {chiave: [larghezza, altezza]}), ONLY (nome di una sola scheda, facoltativo)
local function jdec(s) -- JSON minimo: oggetto di array di 2 numeri
  local t = {}
  for k, a, b in s:gmatch('"(.-)":%[([%d%.e%-]+),([%d%.e%-]+)%]') do t[(k:gsub("\\(.)", { n = "\n", ['"'] = '"', ["\\"] = "\\" }))] = { tonumber(a), tonumber(b) } end
  return t
end
local M = jdec(MEAS)
local REQ, reqSeen = {}, {}
local function jstr(s) return '"' .. tostring(s):gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '') .. '"' end
local function key(fo, w, t) return fo.file .. "|" .. fo.size .. "|" .. (w or 0) .. "|" .. t end
local function measure(fo, w, t, nw)
  if nw then local m = measure(fo, nil, t); return { math.min(w or m[1], m[1]), m[2] } end -- una riga sola, tagliata
  local k = key(fo, w, t)
  if M[k] then return M[k] end
  if not reqSeen[k] then reqSeen[k] = true; REQ[#REQ + 1] = '{"key":' .. jstr(k) .. ',"file":' .. jstr(fo.file) .. ',"size":' .. fo.size .. ',"w":' .. (w or 0) .. ',"t":' .. jstr(t) .. '}' end
  return { #t * fo.size * 0.5, fo.size * 1.2 }
end
local LAYERS = { BACKGROUND = 1, BORDER = 2, ARTWORK = 3, OVERLAY = 4, HIGHLIGHT = 9 }
local all = {}
local new
local methods = {
  SetSize = function(s, w, h) s.w, s.h = w, h end, SetWidth = function(s, w) s.w = w end, SetHeight = function(s, h) s.h = h end,
  GetWidth = function(s) return s.w or (s.kind == "FontString" and measure(s.fo, nil, s.text or "")[1]) or 0 end, GetHeight = function(s) return s.h or 0 end,
  SetPoint = function(s, p, a, b, c, d)
    local rel, x, y = nil, 0, 0
    if type(a) == "number" then x, y = a, b or 0 elseif type(a) == "table" then rel = a; x, y = c or 0, d or 0 end
    s.pt = { p = p, rel = rel, x = x, y = y }
  end,
  ClearAllPoints = function(s) s.pt = nil end, SetAllPoints = function(s) s.fill = true end,
  Show = function(s) s.shown = true end, Hide = function(s) s.shown = false end, IsShown = function(s) return s.shown end,
  SetScript = function(s, n, fn) s.scripts[n] = fn end, GetScript = function(s, n) return s.scripts[n] end,
  CreateTexture = function(s, _, layer) return new("Texture", s, layer) end,
  CreateFontString = function(s, _, layer) return new("FontString", s, layer or "OVERLAY") end,
  SetColorTexture = function(s, r, g, b, a) s.color = { r, g, b }; s.alpha = a or 1; s.tex = nil end,
  SetTexture = function(s, p) s.tex = p; s.color = nil end, SetTexCoord = function() end, SetVertexColor = function() end,
  SetFontObject = function(s, fo) s.fo = type(fo) == "table" and fo or { file = "Barlow-Regular.ttf", size = 13 } end,
  SetTextColor = function(s, r, g, b) s.tc = { r, g, b } end,
  SetText = function(s, t) s.text = t end, GetText = function(s) return s.text end,
  GetStringHeight = function(s) return measure(s.fo, s.w, s.text or "", s.nowrap)[2] end,
  SetWordWrap = function(s, v) s.nowrap = (v == false) or nil end,
  GetStringWidth = function(s) return measure(s.fo, nil, s.text or "")[1] end,
  SetScrollChild = function(s, c) s.child = c end, SetVerticalScroll = function(s, v) s.off = v end, GetVerticalScroll = function(s) return s.off or 0 end,
  SetMinMaxValues = function(s, a, b) s.min, s.max = a, b end, GetMinMaxValues = function(s) return s.min or 0, s.max or 0 end,
  SetValue = function(s, v) s.val = v; if s.scripts.OnValueChanged then s.scripts.OnValueChanged(s, v) end end, GetValue = function(s) return s.val or 0 end,
  SetChecked = function(s, v) s.checked = v end, GetChecked = function(s) return s.checked end,
  SetCheckedTexture = function(s, t) t.onlyChecked = true end, SetThumbTexture = function(s, t) s.thumb = t end,
  GetCenter = function() return 0, 0 end, GetEffectiveScale = function() return 1 end,
  GetFrameLevel = function() return 1 end, GetZoom = function() return 0 end, HookScript = function(s, n, fn) s.scripts[n] = fn end,
}
new = function(kind, parent, layer)
  local o = setmetatable({ kind = kind, parent = parent, layer = layer, shown = true, scripts = {}, kids = {}, regs = {} },
    { __index = function(_, k) return methods[k] or (k:match("^%u") and function() end) or nil end })
  if parent then
    if kind == "Texture" or kind == "FontString" then parent.regs[#parent.regs + 1] = o else parent.kids[#parent.kids + 1] = o end
  end
  all[#all + 1] = o
  return o
end
CreateFrame = function(kind, name, parent) local o = new(kind, parent); if name then _G[name] = o end; return o end
CreateFont = function() return setmetatable({}, { __index = function(t, k)
  if k == "SetFont" then return function(fo, file, size) fo.file = file:match("[^\\]+$"); fo.size = size end end
  return function() end end }) end
UIParent = new("Frame"); UIParent.w, UIParent.h = 1280, 720
Minimap = new("Frame")
GameTooltip, BackdropTemplateMixin, SlashCmdList, UISpecialFrames = new("Frame"), {}, {}, {}
tinsert, unpack = table.insert, unpack or table.unpack
GetCursorPosition = function() return 0, 0 end
GetLocale = function() return LOCALE end
UnitRace = function() return "Human", "Human" end
UnitClass = function() return "Warrior", "WARRIOR" end
UnitFactionGroup = function() return "Alliance" end
UnitLevel = function() return 18 end
-- profession del personaggio (1.7): Blacksmithing 85/150, Mining 120/150; materiali nelle borse
GetProfessions = function() return 1, 2 end
GetProfessionInfo = function(i) if i == 1 then return "Blacksmithing", "", 85, 150 elseif i == 2 then return "Mining", "", 120, 150 end end
GetItemCount = function(id) return id == 2842 and 20 or id == 3470 and 6 or 0 end
GetNumTalentTabs = function() return 3 end
GetTalentTabInfo = function(i) return "t", nil, i == 3 and 8 or 0 end
UnitCharacterPoints = function() return 1 end
DEFAULT_CHAT_FRAME = { AddMessage = function() end }
hooksecurefunc = function() end
GetNumQuestLogEntries = function() return 2 end
GetQuestLogTitle = function(i) if i == 1 then return "The Defias Brotherhood", 18, nil, false, false, nil, nil, 1 end return "Red Silk Bandanas", 18, nil, false, false, true, nil, 2 end
-- Questie finto per l'anteprima (1.8): la catena di sei passi di The Defias Brotherhood (due fatti, il terzo nel registro con
-- l'ID 1 di GetQuestLogTitle), Collecting Memories già fatta
local function QID(n) local h = 0; for i = 1, #n do h = (h * 31 + n:byte(i)) % 100000 end; return h + 1000 end
local DBF = QID("The Defias Brotherhood")
local PRE = { [DBF] = 905, [905] = 904, [904] = 1, [1] = 902, [902] = 901 }
local GIVER = { [901] = { "Gryan Stoutmantle", "Westfall" }, [902] = { "Wiley the Black", "Redridge Mountains" }, [1] = { "Master Mathias Shaw", "Stormwind City" },
  [904] = { "Gryan Stoutmantle", "Westfall" }, [905] = { "The Defias Traitor", "Westfall" }, [DBF] = { "Gryan Stoutmantle", "Westfall" } }
LibQuestieDB = { Quest = { IdsByName = function(n) if n == "The Defias Brotherhood" then return { 1, 901, 902, 904, 905, DBF } end return { QID(n) } end } }
Questie = { API = { isReady = true }, db = { char = { complete = { [901] = true, [902] = true, [QID("Collecting Memories")] = true } } } }
QuestieLoader = { ImportModule = function(_, n)
  if n == "QuestieDB" then return { IsDoable = function() return true end,
    QueryQuestSingle = function(id, k)
      if k == "preQuestSingle" then return PRE[id] and { PRE[id] } or nil end
      if k == "startedBy" then return { { id } } end
      if k == "name" then return GIVER[id] and "The Defias Brotherhood" or "Q" end
    end,
    QueryNPCSingle = function(id, k) if k == "name" then return GIVER[id] and GIVER[id][1] end; if k == "zoneID" then return id end end }
  elseif n == "TrackerUtils" then return { GetZoneNameByID = function(_, id) return GIVER[id] and GIVER[id][2] end } end
end }
ForeverPathfinderDB = { lang = LOCALE == "itIT" and "it" or "en" } -- dalla 1.1 la lingua si sceglie nelle Opzioni (di base inglese)
assert(loadfile(DIR .. "/Data.lua"))()
assert(loadfile(DIR .. "/Core.lua"))("ForeverPathfinder")
local f = ForeverPathfinderFrame
f.scripts.OnEvent(f, "ADDON_LOADED", "ForeverPathfinder")
local fp = SlashCmdList.FOREVERPATHFINDER

-- geometria: punto TOPLEFT rispetto al genitore (o a "rel"), SetAllPoints = come il genitore; la finestra al centro di (0,0)
local function rectOf(o, pl, pt)
  if o.fill then return pl, pt, o.parent.w or 0, o.parent.h or 0 end
  local w, h = o.w, o.h
  if o.kind == "FontString" then local m = measure(o.fo, o.w, o.text or "", o.nowrap); w = o.w or m[1]; h = m[2] end
  local x, y = 0, 0
  if o.pt then x, y = o.pt.x, -o.pt.y end
  return pl + x, pt + y, w or 0, h or 0
end
local items
local function emit(s) items[#items + 1] = s end
local function num(n) return string.format("%.1f", n) end
local function walk(o, pl, pt, checkedParent)
  if not o.shown then return end
  local l, t, w, h = rectOf(o, pl, pt)
  if o == f then l, t = 0, 0 end
  o.w, o.h = o.w or w, o.h or h
  local regs = {}
  for i, r in ipairs(o.regs) do regs[#regs + 1] = { r, i } end
  table.sort(regs, function(a, b) local la, lb = LAYERS[a[1].layer or "ARTWORK"] or 3, LAYERS[b[1].layer or "ARTWORK"] or 3; if la ~= lb then return la < lb end return a[2] < b[2] end)
  for _, e in ipairs(regs) do
    local r = e[1]
    if r.shown and r.layer ~= "HIGHLIGHT" and r ~= o.thumb and (not r.onlyChecked or o.checked) then
      local rl, rt, rw, rh = rectOf(r, l, t)
      if r.kind == "FontString" and r.text and r.text ~= "" then
        local tc = r.tc or { 1, 1, 1 }
        emit('{"k":"text","l":' .. num(rl) .. ',"t":' .. num(rt) .. ',"ww":' .. (r.w or 0) .. ',"nw":' .. (r.nowrap and 1 or 0) .. ',"file":' .. jstr(r.fo.file) .. ',"size":' .. r.fo.size .. ',"c":[' .. tc[1] .. ',' .. tc[2] .. ',' .. tc[3] .. '],"text":' .. jstr(r.text) .. '}')
      elseif r.kind == "Texture" and r.color then
        emit('{"k":"rect","l":' .. num(rl) .. ',"t":' .. num(rt) .. ',"w":' .. num(rw) .. ',"h":' .. num(rh) .. ',"c":[' .. r.color[1] .. ',' .. r.color[2] .. ',' .. r.color[3] .. '],"a":' .. r.alpha .. '}')
      elseif r.kind == "Texture" and r.tex then
        emit('{"k":"icon","l":' .. num(rl) .. ',"t":' .. num(rt) .. ',"w":' .. num(rw) .. ',"h":' .. num(rh) .. ',"path":' .. jstr(r.tex) .. '}')
      end
    end
  end
  if o.kind == "Slider" and o.thumb and (o.max or 0) > 0 then -- cursore della barra
    local frac = (o.val or 0) / o.max
    emit('{"k":"rect","l":' .. num(l) .. ',"t":' .. num(t + frac * (h - 48)) .. ',"w":3,"h":48,"c":[0.23,0.22,0.21],"a":1}')
  end
  if o.kind == "ScrollFrame" then
    emit('{"k":"clip","l":' .. num(l) .. ',"t":' .. num(t) .. ',"w":' .. num(w) .. ',"h":' .. num(h) .. '}')
    if o.child then walk(o.child, 0, -(o.off or 0)) end
    emit('{"k":"endclip"}')
  end
  for _, c in ipairs(o.kids) do if c ~= o.child then walk(c, l, t) end end
end
local scenes = {}
local function snap(name)
  items = {}
  for _, o in ipairs(all) do if o.kind == "Slider" then o:SetValue(0) end end -- anteprima dall inizio della scheda
  walk(f, 0, 0)
  scenes[#scenes + 1] = '{"name":' .. jstr(name) .. ',"W":' .. f.w .. ',"H":' .. f.h .. ',"items":[' .. table.concat(items, ",") .. ']}'
end
local function findPill(label) for _, o in ipairs(all) do if o.kind == "Button" and rawget(o, "fs") and o.fs.text:upper() == label:upper() and o.parent == f then return o end end end
f.scripts.OnEvent(f, "QUEST_LOG_UPDATE"); fp("")
local n = 0
for _, o in ipairs(all) do if o.kind == "CheckButton" and o.shown and n < 2 then n = n + 1; o.checked = true; o.scripts.OnClick(o) end end
local L = ForeverPathfinderData[LOCALE == "itIT" and "it" or "en"]._tabs
local list = {}
for _, t in ipairs(L) do list[#list + 1] = t end
list[#list + 1] = { "opzioni", LOCALE == "itIT" and "Opzioni" or "Options" }
for _, t in ipairs(list) do
  if ONLY == "" or ONLY == t[1] then findPill(t[2]).scripts.OnClick(); snap(t[1]) end
end
-- sezione o parte più in basso di una scheda: "classe.Spell" = clic sul pulsante Spell, "talent~400" = scorrimento di 400
local tb, sub = ONLY:match("^(%a+)%.(.+)$")
local tb2, off = ONLY:match("^(%a+)~(%d+)$")
if tb or tb2 then
  for _, t in ipairs(list) do if t[1] == (tb or tb2) then findPill(t[2]).scripts.OnClick() end end
  if sub then for _, o in ipairs(all) do if o.kind == "Button" and rawget(o, "fs") and o.fs.text == sub and o.shown and o.parent ~= f then o.scripts.OnClick(o); break end end end
  snap(ONLY)
  if off then
    items = {}
    for _, o in ipairs(all) do if o.kind == "Slider" then o:SetValue(tonumber(off)) end end
    walk(f, 0, 0)
    scenes[#scenes] = '{"name":' .. jstr(ONLY) .. ',"W":' .. f.w .. ',"H":' .. f.h .. ',"items":[' .. table.concat(items, ",") .. ']}'
  end
end
-- scheda di un dungeon (menu della 1.5): "dgscheda" = The Deadmines dall'inizio, "dgscheda2" = più in basso
if ONLY == "dgscheda" or ONLY == "dgscheda2" then
  for _, t in ipairs(list) do if t[1] == "dungeon" then findPill(t[2]).scripts.OnClick() end end
  for _, o in ipairs(all) do if o.kind == "Button" and rawget(o, "fs") and o.fs.text == "The Deadmines" and o.shown and o.parent ~= f then o.scripts.OnClick(o); break end end
  snap(ONLY)
  if ONLY == "dgscheda2" then
    items = {}
    for _, o in ipairs(all) do if o.kind == "Slider" then o:SetValue(190) end end
    walk(f, 0, 0)
    scenes[#scenes] = '{"name":' .. jstr(ONLY) .. ',"W":' .. f.w .. ',"H":' .. f.h .. ',"items":[' .. table.concat(items, ",") .. ']}'
  end
end
OUT = '{"reqs":[' .. table.concat(REQ, ",") .. '],"scenes":[' .. table.concat(scenes, ",") .. ']}'
