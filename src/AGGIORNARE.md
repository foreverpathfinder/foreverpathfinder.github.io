# WoW Forever Leveling Companion — contesto per ripartire (aggiornato 2 nov 2026, v10.3)

Guida leveling 1–30 per **WoW: Forever** (Classic+, lancio 4 nov 2026) per tutte le 10 razze e 9 classi. Pubblica:
https://stalioot.github.io/wow-forever-leveling-companion/ · repo `Stalioot/wow-forever-leveling-companion` (GitHub Pages da `main`, root; commit con email noreply `80699208+Stalioot@users.noreply.github.com`, trailer `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`).
Cartella: `~/Desktop/CLAUDE/WoW Forever leveling companion/`. Utente italiano: testi in italiano, termini di gioco in inglese.

## Ciclo di lavoro
1. Modifica `src/data/*`, `src/engine.js`, `src/template.html` o `src/style.css` (mai l'HTML generato).
2. `node src/tools/build.js` → genera `WoW_Forever_Leveling_Companion.html` (italiano, + `.md` riassunto) e `WoW_Forever_Leveling_Companion_EN.html` (inglese) e stampa gli avvisi (talent non validi sul client, città/NPC non sulla mappa, quest non trovate → `src/check-report.txt`).
3. Server locale: preview `guida-wow` (`~/Desktop/CLAUDE/.claude/launch.json`, porta 8765, radice = Desktop) → URL `http://localhost:8765/CLAUDE/WoW%20Forever%20leveling%20companion/WoW_Forever_Leveling_Companion.html`.
4. `node src/tools/test.js` (italiano e inglese, tutte le combinazioni × build: deve dire `nbad 0, errors []` e in inglese `nita 0`; le righe italiane rimaste finiscono in `src/i18n/italiano-rimasto.txt`) e `node src/tools/icons.js` (`rotte 0`). Usano Chrome headless via playwright-core in `%LOCALAPPDATA%/npm-cache/_npx/9833c18b2d85bc59/node_modules/playwright-core`. Per screenshot usa lo stesso modulo (il pannello browser dell'app spesso è nascosto → screenshot vuoti).
5. `git add -A && git commit && git push` → Pages si aggiorna in 1–2 min (`gh api repos/Stalioot/wow-forever-leveling-companion/pages/builds/latest`).

## File
| File | Contenuto |
|---|---|
| `src/data/common.json` | `version`, `updated`, `maxLevel` (30), lancio, bonus XP, regole, camping, crates, video, fonti comuni |
| `src/data/classes/<classe>.json` | `build` (nomi talent esatti, 1 per livello dal 10), `builds` A/B/C (vedi sotto), `why`, `summary`, `compare`, `spells`, `talentSpells`, `rotation`, `milestones`, `camp`, `professions`, `races`, `sources` |
| `src/data/talents/<classe>.json` | talent dal client (wowforever.be): `node src/tools/wf.js <classe>` |
| `src/data/factions/alliance.json`, `horde.json` | razze (racial, classi, start) e rotte 1–30 per zona iniziale (`segments`, `steps` con `town` esatto, `milestones`, `bags`, `questNPCs`, `flights`, `transport`), dungeon, `crates` |
| `src/data/transfers.json` | cambi di continente (`junctions` + 4 passaggi `A:eastern-kingdoms>kalimdor` ecc.) |
| `src/data/profs.json` / `alts.json` | guida profession; guida alt (`legacy`, `firstAlt`, `faster`, `complements`, `altClasses` ×9, `altRaces` ×10, …) |
| `src/data/worldmap.json` | mappa Wowhead (3 continenti; `node src/tools/map.js`) · `src/data/quests.txt`: indice delle 4709 quest di Forever (`node src/tools/quests.js src/data/quests.txt`) |
| `src/template.html`, `style.css`, `engine.js` | pagina, stile, motore (nessun dato di gioco) |
| `src/i18n/en.json` | traduzione inglese dei dati: `{"testo italiano esatto": "inglese"}`. Se cambi un testo italiano nei dati, la build lo segnala e lo mette in `src/i18n/missing-en.json`: traducilo e aggiungilo qui (termini di gioco identici, stessi tag HTML, simboli ✔ 🟡 ★ e numeri) |
| `src/i18n/en-ui.json` | traduzione di pagina e motore: coppie `["italiano", "inglese"]` sostituite in `template.html` ed `engine.js` (la build avvisa se una coppia non trova più il testo). Testo nuovo nell'interfaccia = nuova coppia |

Chiavi razza: `human dwarf gnome nightelf skyborne_a orc undead troll tauren skyborne_h`. Rotte: `elwynn dunmorogh teldrassil zephras_a durotar mulgore tirisfal zephras_h`.

## Schemi chiave
- **Milestone**: `{"l":10,"t":"<b>Quest</b>: passi… Ricompensa: …","r":["dwarf"],"f":"A","npc":["Nome esatto"]}` — `r`/`f` filtrano per razza/fazione, `npc` → pulsante 📍. Verifica le quest su `quests.txt`. Niente spell/talent/profession/dungeon generici (li aggiunge la pagina), niente note sulle fonti nel testo.
- **Build**: `builds:[{id,name,spec,icon,when,pros,cons,ratings:{speed|ease|versatility|survival|aoe|gear:[1–5,motivo,fonte]},build:[…] (vuoto per A),rotation?,sources}]`. A = guida più votata. Voto solo se una fonte lo giustifica (altrimenti barra vuota).

## Motore (`engine.js`)
Preset (personaggi salvati) in localStorage `wfcP` = `{cur, sure (filtro 🟡), list:[{n nome, s}]}` (il vecchio `wfc` viene migrato nel primo preset). `S` = `P.list[P.cur].s`: `r`, `c`, `L`, `tab`, `o` = opzioni {`x` cambio continente, `prof`[2], `dg`, `tal` Talented, `b`{classe: id build}}, `done`{CK: checklist}. `bind()` → `RA` razza, `CL` classe con build scelta (`buildView`), `TAL`, `FA` fazione, `RT` percorso composto (`compose()`), `PT` passaggio. `renderAll()` = drawPick + renderClass (talent, rotation, spell, razza, viaggi, bag, profession, alt, crates, camping, dungeon, fonti) + renderPath (capitoli/checklist) + drawMap + renderLevel.
Lingue: bandierina `#lang` in alto a destra (🇬🇧 nella pagina italiana, 🇮🇹 in quella inglese) → salva `wfcLang` e porta l'hash; lo script in `<head>` apre la lingua salvata, altrimenti quella del browser. Stesso localStorage: personaggi e checklist valgono in entrambe le lingue (id delle voci = capitolo + livello + posizione, non il testo).
UI: **pagina iniziale** `#home` (body `.home`, si apre se l'URL non ha hash): personaggi salvati (`preBtns`, nuovo/rinomina/elimina), fazione/razza/classe con pro e contro (`pickInfo`: racial + `alts.altRaces/altClasses` + build più votata + `races` della classe), build A/B/C e opzioni; "Entra nella guida" mette l'hash `#razza-classe` (ricaricando resti nella guida). Testata = titolo fisso "World of Warcraft Forever Leveling Companion" (`.ttl`); sopra le schede la barra `#cbar` con i personaggi (un tocco per cambiare) e "⚙ Personaggi" (torna alla pagina iniziale). 8 schede (`showTab`): Livello (planner + capitolo corrente + mini-mappa) · Talent (selettore build con barre + calcolatore wowforever.be in iframe `?t=`) · Mappa (Leaflet, mondo intero, tessere Wowhead) · Classe · Profession · Alt · Altro · Info (solo fonti). Link/QR `#s=<base64 {r,c,n,L,o,d}>`: aggiorna il preset con stessa razza+classe o ne crea uno, filtro 🟡 (`.unsure`), pulsante issue GitHub. Mappa: tela unica (coordinate globali), niente `position` su `.spin`.

## Regole dell'utente
- Fonti migliori e attendibili, scelte per **upvote/preferiti/views** (Mobalytics ♥, YouTube); i dati client (wowforever.be, Wowhead) decidono i dettagli. ✔ più fonti · 🟡 una fonte o pre-lancio · ★ novità di Forever. Niente siti di boost/gold. Mai dati Classic spacciati per Forever.
- Agenti: massimo 2–3 in parallelo, modello più economico (Haiku), poi revisione mia (togli note interne tipo "indice", "JSON", "non trovato").
- Mobalytics/Icy Veins: 403 a WebFetch → leggerli dal browser integrato (`javascript_tool`, estrarre solo il necessario). Reddit bloccato.
- Grigliate (grill-me) sempre con domande cliccabili (AskUserQuestion).
- Contesto basso: niente dump grandi in chat, script su file nello scratchpad.

## Da fare
Fatto il 2 nov: pagina iniziale con pro/contro, titolo in testata, preset personaggi (v10.3).
Poi, dopo il 4 nov: rotte e build da fonti reali, `maxLevel` 60 (`segments`/`steps`/`milestones`/`spells` fino al 60; le build arrivano già al 60).

## Dubbi aperti (sintesi)
Build 31–60 da una sola fonte per varie classi 🟡; molte tappe delle rotte da una fonte (games.gg) e livelli di Zephras stimati; valori di alcuni racial discordi; Legacy (costi perk, cap 16, 62 vs 65 challenge) da confermare in gioco.
