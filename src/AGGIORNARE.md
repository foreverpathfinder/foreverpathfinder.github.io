# Forever Pathfinder — contesto per ripartire (aggiornato 2 nov 2026, v10)

Guida leveling 1–30 per **WoW: Forever** (Classic+, lancio 5 nov 2026 ora italiana) per tutte le 10 razze e 9 classi, in italiano e inglese, più un addon in gioco.
- Sito: https://foreverpathfinder.github.io/ · repo `foreverpathfinder/foreverpathfinder.github.io` (GitHub Pages da `main`, root). Pagina addon: `/addon.html`.
- Vecchi indirizzi solo di rimando: `stalioot.github.io/wow-forever-leveling-companion/` (repo `Stalioot/wow-forever-leveling-companion`). Nome precedente: "WoW Forever Leveling Companion", cambiato perché un addon spagnolo (FLC) si chiama uguale.
- Commit: email `80699208+Stalioot@users.noreply.github.com`, trailer `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Cartella: `~/Desktop/CLAUDE/WoW Forever leveling companion/` (Windows). Utente italiano: testi in italiano, termini di gioco in inglese.

## Ciclo di lavoro
1. Modifica `src/data/*`, `src/engine.js`, `src/template.html`, `src/style.css` (mai gli HTML generati).
2. `node src/tools/build.js` → `WoW_Forever_Leveling_Companion.html` (IT), `_EN.html` (EN) e il riassunto `.md`; stampa gli avvisi (talent non validi, NPC non sulla mappa, quest non trovate → `src/check-report.txt`, coppie en-ui che non trovano più il testo, testi senza inglese → `src/i18n/missing-en.json`).
3. Server locale: preview `guida-wow` (`~/Desktop/CLAUDE/.claude/launch.json`, porta 8765, radice = Desktop) → `http://localhost:8765/CLAUDE/WoW%20Forever%20leveling%20companion/WoW_Forever_Leveling_Companion.html`.
4. `node src/tools/test.js` (IT ed EN, tutte le combinazioni × build: `nbad 0, errors []`, in inglese `nita 0`; italiano rimasto → `src/i18n/italiano-rimasto.txt`) e `node src/tools/icons.js` (`rotte 0`). Chrome headless via playwright-core in `%LOCALAPPDATA%/npm-cache/_npx/9833c18b2d85bc59/node_modules/playwright-core`; anche per gli screenshot (a 390px e desktop).
5. Se cambiano checklist o talenti: `node src/tools/addon.js` (rigenera `addon/ForeverPathfinder/Data.lua` e `ForeverPathfinder.zip`) e `node src/tools/addon-test.js` (WoW finto `addon-test.lua` su fengari: `npm i --prefix <cartella> fengari`, poi `FENGARI=<cartella>/node_modules/fengari`) → «tutte le prove ok».
6. Commit solo dei file toccati, push; Pages si aggiorna in 1–2 min (`gh api repos/foreverpathfinder/foreverpathfinder.github.io/pages/builds/latest`). Se più sessioni lavorano nella stessa cartella, non includere file di altri.

## File
| File | Contenuto |
|---|---|
| `src/data/common.json` | `version`, `updated`, `maxLevel` (30), lancio, bonus XP, regole, camping, crates, fonti comuni |
| `src/data/classes/<classe>.json` | `build` (talent, 1 per livello dal 10), `builds` A/B/C, `why`, `summary`, `compare`, `spells`, `talentSpells`, `rotation`, `milestones`, `camp`, `professions`, `races`, `sources` |
| `src/data/talents/<classe>.json` | talent dal client (wowforever.be): `node src/tools/wf.js <classe>` |
| `src/data/factions/alliance.json`, `horde.json` | razze (racial, classi, start), rotte 1–30 per zona iniziale (`segments`, `steps` con `town`, `milestones`, `bags`, `questNPCs`, `flights`, `transport`), dungeon (livelli, posizione), `crates` |
| `src/data/dungeons.json` | dettagli della scheda Dungeon (vedi Schemi) |
| `src/data/transfers.json` | cambi di continente (`junctions` + 4 passaggi) |
| `src/data/profs.json` / `alts.json` | profession; alt (`legacy` {how, perks}, `firstAlt`, `faster`, `complements`, `altClasses` ×9 con `withMain`, `altRaces` ×10 con `bestFor`, `bankAlt`, `craftAlts`, `mistakes`, `tips`, `doubts`) |
| `src/data/worldmap.json`, `quests.txt` | mappa Wowhead (`node src/tools/map.js`); indice delle 4709 quest di Forever (`node src/tools/quests.js`) |
| `src/template.html`, `style.css`, `engine.js` | pagina, stile, motore (nessun dato di gioco) |
| `src/i18n/en.json` | inglese dei dati: `{"italiano esatto": "inglese"}` (stessi tag, simboli ✔ 🟡 ★, numeri e nomi di gioco); nomi già inglesi = identici |
| `src/i18n/en-ui.json` | inglese di pagina e motore: coppie `["italiano", "inglese"]` sostituite in template ed engine. Testo nuovo nell'interfaccia = nuova coppia |
| `addon/ForeverPathfinder/` | addon: `.toc` (Interface 16001), `Core.lua`, `Data.lua` generato; `ForeverPathfinder.zip` alla radice (creato con il `tar.exe` di Windows) |
| `addon.html` | pagina dell'addon scritta a mano (IT/EN nella stessa pagina): download, installazione, setup, comandi, problemi comuni. Va aggiornata a mano se cambiano comandi o versione |
| `manifest.webmanifest`, `icon-*.png` | app sulla schermata Home; icone rigenerabili con `node src/tools/icon.js .` |

Chiavi razza: `human dwarf gnome nightelf skyborne_a orc undead troll tauren skyborne_h`. Rotte: `elwynn dunmorogh teldrassil zephras_a durotar mulgore tirisfal zephras_h`.

## Schemi chiave
- **Milestone**: `{"l":10,"t":"<b>Quest</b>: passi… Ricompensa: …","r":["dwarf"],"f":"A","npc":["Nome esatto"]}`: `r`/`f` filtrano per razza/fazione, `npc` → pulsante 📍. Verifica le quest su `quests.txt`. Niente spell/talent/profession/dungeon generici (li aggiunge la pagina), niente note sulle fonti nel testo.
- **Build**: `builds:[{id,name,spec,icon,when,pros,cons,ratings:{speed|ease|versatility|survival|aoe|gear:[1–5,motivo,fonte]},build,rotation?,sources}]`. A = guida più votata. Voto solo se una fonte lo giustifica.
- **Dungeon** (`dungeons.json`): `general`, `glossary`, `dungeons[chiave]` (nome di `factions/*.json` senza ★ e "The ", minuscolo): `e` ingresso, `k` catena chiave per fazione, `v` giudizio per fazione [go/opt/skip, livello ideale, perché], `q` quest A/H/N + C di classe, `b` boss in ordine, `t` consigli. **Ogni consiglio nomina il boss in `<b>`** (il motore lo mette sotto quel boss). **Solo dati da fonti sulla beta** (Warcraft Tavern: boss/quest; Conquest Capped: giudizi): al lancio si riverifica tutto. La build aggiunge `qp` (punto mappa per quest).

## Motore (`engine.js`)
- **Stato**: localStorage `wfcP` = `{cur, sure (filtro 🟡), in (già entrato: il link senza hash salta la pagina iniziale), list:[{n, s}]}`; `S` = personaggio attuale: `r`, `c`, `L`, `tab`, `o` {`x` cambio continente, `prof`[2], `dg`, `tal`, `b`{classe: build}}, `done`{CK: checklist}. `bind()` → `RA`, `CL`, `TAL`, `FA`, `RT` (`compose()`), `PT`. `renderAll()` = drawPick + renderClass + renderPath + drawMap + renderLevel.
- **Lingue**: bandierina `#lang` → `wfcLang` + hash; lo script in `<head>` apre la lingua salvata o del browser. Id delle voci = capitolo + livello + posizione: personaggi e spunte valgono in entrambe le lingue.
- **Pagina iniziale** `#home` (URL senza hash, prima visita): personaggi (nuovo/rinomina/elimina), fazione/razza/classe con pro e contro (`pickInfo`), build e opzioni, «💾 Salva i progressi» (file `.txt` con riga di spiegazione + `P` in base64; carica = valida, conferma, sostituisce), istruzioni per la schermata Home, riquadro «🧩 Addon in gioco».
- **Guida**: testata «World of Warcraft · Forever · Pathfinder»; barra `#cbar` con il personaggio, «🧩 Addon» (→ `addon.html`) e «👥 Personaggi» (→ pagina iniziale); su telefono i due pulsanti vanno sotto il personaggio. 9 schede (`showTab`, ruoli tab/tabpanel, frecce ← →): Livello · Talent (build con barre + calcolatore wowforever.be in iframe) · Mappa (Leaflet, tessere Wowhead) · Classe · Profession · Dungeon (una scheda per dungeon, giudizio per fazione, ordinati per livello, oro = livello attuale) · Alt · Altro · Info (fonti, contatore visite).
- **Scheda Alt** (indipendente dal main e dai personaggi): «Ti serve un alt?» → **classifica dei migliori alt** (`altRank` su `alts.rank`: per ogni classe voto della tier list di leveling Mobalytics e di Timesaver, S=4…D=0, media; a parità l’ordine della guida agli alt di Conquest Capped; criteri e fonti mostrati sopra la classifica; ogni riga mostra ruolo per l’account e lavori consigliati `rank.profs`) → **piano dell’alt** salvato in `P.alt` {c, r, prof[2]} (non tocca i personaggi): toccando una classe in classifica si scelgono razza (★ = `altRaces.bestFor`) e 2 lavori (★ = `rank.profs`), poi il giudizio ✔/🟡 su classe, razza, lavori (coppia consigliata, si riforniscono da soli con `FEED`, due di raccolta, nessuno di raccolta) e la nota Legacy → il resto in sezioni richiudibili (anche «Tutte le classi», nello stesso ordine della classifica).
- **Condivisione**: link/QR `#s=<base64 {r,c,n,L,o,d}>` aggiorna il personaggio con stessa razza+classe o ne crea uno. Pulsante issue GitHub con il contesto.
- **Accessibilità e telefono**: tutto ciò che si tocca è alto ≥ 44px sotto 520px; `RM`/`SM` = meno animazioni se il sistema lo chiede (scroll istantanei, la mappa salta invece di volare); freccia `#totop` per tornare in alto; icone con `loading="lazy"`.
- **Soldi**: pulsante ☕ PayPal (`#bPay`, paypal.me/staliot); contatore hits.sh in fondo a Info (non caricato nei test, link se un adblock lo blocca).

## Addon (v0.1.1, mai provato nel gioco vero)
Finestra spostabile con voci del livello (spuntabili, salvate in `ForeverPathfinderChar`), tappa, build e prossimo talento (punti spesi da `GetTalentTabInfo`, liberi da `UnitCharacterPoints`); frecce < >; voci ripetute tra due tappe mostrate una volta. Comandi `/fp`, `/fp set razza-classe`, `/fp auto`, `/fp list`, `/fp help`. Italiano se `GetLocale()=="itIT"`, altrimenti inglese. Percorso = opzioni di base del sito (niente cambio continente, dungeon sì, build A).

## Regole dell'utente
- Fonti migliori e attendibili, scelte per **upvote/preferiti/views** (Mobalytics ♥, YouTube); i dati client (wowforever.be, Wowhead) decidono i dettagli. ✔ più fonti · 🟡 una fonte o pre-lancio · ★ novità di Forever. Niente siti di boost/gold. Mai dati Classic spacciati per Forever.
- Agenti: massimo 2–3 in parallelo, modello più economico (Haiku), poi revisione (togli note interne tipo "indice", "JSON", "non trovato").
- Mobalytics/Icy Veins danno 403 a WebFetch → leggerli dal browser integrato. Reddit bloccato.
- Grigliate sempre con domande cliccabili. Contesto basso: niente dump grandi in chat, script nello scratchpad.

## Da fare (dal lancio, 5 nov)
1. **Addon in gioco**: verificare che si carichi (Interface e cartella AddOns di Forever; in beta `_classic_beta_`, 16001), il token di UnitRace degli Skyborne (ipotesi: contiene "Skyborne"), il talento indicato, le spunte dopo un riavvio (in beta le SavedVariables non venivano rilette). Promemoria programmato il 5 nov alle 10.
2. **Pubblicare l'addon** dopo la prova: CurseForge e Wago (account dell'utente; categoria Quests & Leveling, licenza, logo 400×400, screenshot dal gioco, rilascio beta), poi eventuale automazione su GitHub con token.
3. **Guida fino al 60**: rotte e build da fonti reali, `maxLevel` 60 (`segments`/`steps`/`milestones`/`spells` fino al 60; le build arrivano già al 60).
4. **Dungeon**: riverificare boss, quest e giudizi sul gioco uscito; aggiungere i dungeon oltre il 30.
5. **Gold farming**: quando ci saranno testimonianze dal gioco.
6. Facoltativo: `/impeccable init` per scrivere `PRODUCT.md` (obiettivi, pubblico, tono) per i prossimi giri di design.

## Dubbi aperti
Build 31–60 da una sola fonte per varie classi 🟡; molte tappe delle rotte da una fonte (games.gg) e livelli di Zephras stimati; valori di alcuni racial discordi; Legacy (costi dei perk, cap 16, 62 o 65 challenge) da confermare in gioco.
