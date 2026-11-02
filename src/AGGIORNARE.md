# Forever Pathfinder — tutto quello che serve per lavorarci (aggiornato 2 nov 2026, sito v10, addon 0.2.0)

Guida leveling 1–30 per **WoW: Forever** (Classic+ di Blizzard, lancio 5 nov 2026 a mezzanotte ora italiana), tutte le 10 razze e 9 classi, in italiano e inglese, più un addon in gioco. Pagina unica statica generata da dati JSON, ottimizzata per telefono (si usa accanto al PC mentre si gioca).

## Inizio sessione (in quest'ordine)
1. Leggi solo questo file: non rileggere tutto il codice, apri i file solo nel punto che serve (`grep -n`).
2. `git status` e `git log --oneline -5` nella cartella del progetto: lavorano a volte più sessioni nella stessa cartella → **committa solo i file che hai toccato tu** e non toccare modifiche altrui.
3. Server locale per test e screenshot: preview `guida-wow` (configurato in `~/Desktop/CLAUDE/.claude/launch.json`: `npx -y http-server <cartella Desktop> -p 8765 -c-1`). Se la sessione parte dentro la cartella del progetto e non lo trova, crea `.claude/launch.json` uguale lì. URL: `http://localhost:8765/CLAUDE/WoW%20Forever%20leveling%20companion/WoW_Forever_Leveling_Companion.html`.

## Dove sta cosa
- Cartella: `~/Desktop/CLAUDE/WoW Forever leveling companion/` (Windows 11; Git Bash e PowerShell).
- Sito: https://foreverpathfinder.github.io/ (GitHub Pages da `main`, radice) · pagina addon `/addon.html`.
- Repo: `foreverpathfinder/foreverpathfinder.github.io` (org dell'utente). Vecchio indirizzo `stalioot.github.io/wow-forever-leveling-companion/` = repo `Stalioot/wow-forever-leveling-companion` di solo rimando (non toccare).
- Commit: `git -c user.email=80699208+Stalioot@users.noreply.github.com commit`, messaggio in italiano, ultima riga `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Push su `main`; Pages si aggiorna in 1–2 min (`gh api repos/foreverpathfinder/foreverpathfinder.github.io/pages/builds/latest --jq '.status+" "+.commit[0:7]'`).
- Nome: **Forever Pathfinder** (prima "WoW Forever Leveling Companion": cambiato perché un addon spagnolo, FLC, si chiama uguale). I file HTML mantengono il vecchio nome per non rompere link e QR.

## Ciclo di lavoro
1. Modifica solo `src/data/*`, `src/engine.js`, `src/template.html`, `src/style.css` (mai gli HTML generati). `addon.html` e i file in `addon/` sono a parte (vedi Addon).
2. `node src/tools/build.js` → `WoW_Forever_Leveling_Companion.html` (IT), `..._EN.html` (EN), `..._Companion.md` (riassunto testuale). Avvisi da leggere: coppie en-ui che non trovano più il testo, testi senza inglese (→ `src/i18n/missing-en.json`), talent/NPC/quest non validi (→ `src/check-report.txt`).
3. `node src/tools/test.js` (serve il server) → in entrambe le lingue `nbad 0`, `errors []`, `nita 0` (italiano rimasto nella pagina inglese → `src/i18n/italiano-rimasto.txt`). `node src/tools/icons.js` → `rotte 0`.
4. Se cambiano checklist, talenti o dungeon: `node src/tools/addon.js` (rigenera `addon/ForeverPathfinder/Data.lua` e `ForeverPathfinder.zip`) e `node src/tools/addon-test.js` → «tutte le prove ok».
5. Screenshot e prove nel browser: script Node con playwright-core da `%LOCALAPPDATA%/npm-cache/_npx/9833c18b2d85bc59/node_modules/playwright-core` (`chromium.launch({channel:'chrome'})`), a **390×844** (telefono) e 1280×800. Il pannello browser dell'app spesso è nascosto: usa gli script. Script temporanei nello scratchpad, mai `/tmp` (Node su Windows non lo vede).
6. Commit dei soli file toccati, push, verifica online con `curl` sulla pagina pubblicata.

## File
| File | Contenuto |
|---|---|
| `src/data/common.json` | `version`, `updated`, `maxLevel` (30), lancio, bonus XP, regole, camping, crates, fonti comuni |
| `src/data/classes/<classe>.json` | `build` (talent, 1 per livello dal 10), `builds` A/B/C con `ratings` (voto 1–5 + motivo + fonte), `why`, `summary`, `compare`, `spells`, `talentSpells`, `rotation`, `milestones`, `camp`, `professions`, `races`, `sources` |
| `src/data/talents/<classe>.json` | talent dal client (wowforever.be): `node src/tools/wf.js <classe>` |
| `src/data/factions/alliance.json`, `horde.json` | razze (racial, classi, zona iniziale), rotte 1–30 (`segments`, `steps` con `town`, `milestones`, `bags`, `questNPCs`, `flights`, `transport`), dungeon `[nome, min, max, dove, nota interna]`, `crates` |
| `src/data/dungeons.json` | scheda Dungeon (vedi Schemi) |
| `src/data/alts.json` | alt: `rank` (classifica), `legacy` {how, perks}, `firstAlt`, `faster`, `complements`, `altClasses` (role, why, gold, leveling, withMain), `altRaces` (why, bestFor), `bankAlt`, `craftAlts`, `mistakes`, `tips`, `doubts`, `sources` |
| `src/data/profs.json`, `transfers.json` | profession; cambi di continente |
| `src/data/worldmap.json`, `quests.txt` | mappa Wowhead (`node src/tools/map.js`); indice delle 4709 quest di Forever (`node src/tools/quests.js`): usalo per verificare i nomi delle quest |
| `src/template.html`, `style.css`, `engine.js` | struttura, stile (colori come variabili in `:root`), motore (nessun dato di gioco) |
| `src/i18n/en.json` | inglese dei **dati**: `{"italiano esatto": "inglese"}`; stessi tag HTML, simboli ✔ 🟡 ★, numeri; i nomi di gioco restano in inglese (stringhe già inglesi = identiche) |
| `src/i18n/en-ui.json` | inglese di **template ed engine**: coppie `["italiano", "inglese"]` sostituite come sottostringhe (le più lunghe prima). Ogni testo nuovo nell'interfaccia = nuova coppia; se cambi un testo, aggiorna la coppia |
| `addon/ForeverPathfinder/` | `ForeverPathfinder.toc` (Interface 16001, `## Version`), `Core.lua` (a mano), `Data.lua` (generato) |
| `ForeverPathfinder.zip`, `addon.html` | download dell'addon; pagina dell'addon scritta a mano (IT ed EN nella stessa pagina) |
| `manifest.webmanifest`, `icon-*.png`, `index.html` | app sulla schermata Home (`node src/tools/icon.js .`); `index.html` rimanda alla pagina italiana |
| `src/tools/` | `build`, `test`, `icons`, `addon`, `addon-test(.lua)`, `icon`, `wf`, `map`, `quests` |

Chiavi razza: `human dwarf gnome nightelf skyborne_a orc undead troll tauren skyborne_h`. Rotte: `elwynn dunmorogh teldrassil zephras_a durotar mulgore tirisfal zephras_h`. Fazioni: `A`, `H`.

## Schemi chiave
- **Milestone**: `{"l":10,"t":"<b>Quest</b>: passi… Ricompensa: …","r":["dwarf"],"f":"A","npc":["Nome esatto"]}`: `r`/`f` filtrano, `npc` → pulsante 📍 (nome identico a `worldmap.json`). Niente spell/talent/profession/dungeon generici (li aggiunge il motore), niente note sulle fonti nel testo.
- **Build**: `builds:[{id,name,spec,icon,when,pros,cons,ratings:{speed|ease|versatility|survival|aoe|gear:[1–5,motivo,fonte]},build,rotation?,sources}]`. A = guida più votata. Un voto solo se una fonte lo giustifica.
- **Dungeon** (`dungeons.json`): `general`, `glossary`, `dungeons[chiave]` con chiave = nome di `factions/*.json` senza ★ e senza "The ", minuscolo: `e` ingresso, `k` catena per la chiave per fazione, `v` giudizio per fazione `[go|opt|skip, livello ideale, perché]`, `q` quest `A`/`H`/`N` (+ `C` di classe `[quest, classe, dove]`), `b` boss in ordine, `t` consigli. Ogni consiglio nomina il boss in `<b>` (il motore lo mette sotto quel boss). Solo dati da fonti sulla beta (Warcraft Tavern: boss/quest; Conquest Capped: giudizi). La checklist usa gli stessi giudizi (i dungeon da saltare non compaiono).
- **Classifica alt** (`alts.rank`): `criteria` (testo mostrato), `sources`, `tiers` {classe: [voto Mobalytics, voto Timesaver]} con S=4…D=0 e media, `order` (spareggio: guida alt di Conquest Capped), `profs` {classe: [lavoro, lavoro, fonte]}.

## Motore (`engine.js`)
- **Stato** (localStorage `wfcP`): `{cur, sure (filtro 🟡), in (già entrato: il link senza hash salta la pagina iniziale), alt (piano dell'alt: {c, r, prof[2]}), list:[{n, s}]}`. `S` = personaggio attuale: `r`, `c`, `L`, `tab`, `o` {`x` cambio continente, `prof`[2], `dg`, `tal`, `b`{classe: build}}, `done`{CK: spunte}. `bind()` → `RA`, `CL`, `TAL`, `FA`, `RT` (`compose()`), `PT`. `renderAll()` = drawPick + renderClass (anche `renderAlt`) + renderPath + drawMap + renderLevel.
- **Lingua**: bandierina `#lang` → `wfcLang` + hash; script in `<head>` apre la lingua salvata o quella del browser. Id delle spunte = capitolo + livello + posizione: valgono in entrambe le lingue.
- **Pagina iniziale** `#home`: personaggi (nuovo/rinomina/elimina), fazione/razza/classe con pro e contro (`pickInfo`), build e opzioni, «💾 Salva i progressi» (file `.txt`: una riga di spiegazione + `P` in base64), istruzioni per la schermata Home, riquadro «🧩 Addon in gioco».
- **Guida**: testata «World of Warcraft · Forever · Pathfinder»; barra `#cbar`: personaggio, 🔍 ricerca, «🧩 Addon» (→ `addon.html`), «👥 Personaggi» (→ pagina iniziale). 9 schede (`showTab`, chiavi interne tra parentesi): **Percorso** (`livello`: livello −/+, zona, talento, spell, mini-mappa con schermo intero, tappe con checklist) · Talent · Mappa (Leaflet, tessere Wowhead, `MAPI.fly(x,y,zoom,popup)`) · Classe · Profession · Dungeon · Alt · Altro · Info (fonti, contatore visite).
- **Scheda Alt** (indipendente dai personaggi): «Ti serve un alt?» → classifica `altRank` (ogni riga è un pulsante che sceglie la classe del piano) → piano dell'alt `altPlan` (razza ★ = `altRaces.bestFor`, 2 lavori ★ = `rank.profs`, giudizio ✔/🟡 con motivi; `FEED` = chi rifornisce chi) → resto in `<details>`.
- **Ricerca** (🔍, `/`, Ctrl+K; `<dialog id="sDlg">`): `sIndex()` a ogni apertura. Nella guida = testi della pagina del personaggio attuale (voci della checklist, titoli apribili, righe di liste/tabelle, schede foglia) → apre scheda e sezioni, scorre, evidenzia (`.hit`). Sulla mappa = `D.map` (zone, città, dungeon, Flight Master/Inn/trainer della fazione, pet) + NPC dei pulsanti 📍 → `MAPI.fly`. Testi in `SL`.
- **Condivisione**: link/QR `#s=<base64 {r,c,n,L,o,d}>`. Pulsante «Segnala un errore» = issue GitHub precompilata.
- **Telefono e accessibilità**: tutto ciò che si tocca è ≥ 44px sotto 520px; schede con ruoli tab/tabpanel e frecce; `RM`/`SM` = meno animazioni se richiesto dal sistema; freccia `#totop`; icone `loading="lazy"`.
- **Soldi**: ☕ PayPal (`#bPay`, paypal.me/staliot); contatore hits.sh in fondo a Info (non caricato nei test automatici).

## Addon (0.2.0, mai provato nel gioco vero)
- Finestra spostabile: titolo razza-classe e livello, tappa, build, talento da prendere (punti spesi da `GetTalentTabInfo`, liberi da `UnitCharacterPoints`), riga dei dungeon adatti (livello ideale del giudizio, fazione dalla razza, niente «salta»), voci del livello spuntabili (salvate in `ForeverPathfinderChar`), frecce < >.
- Comandi: `/fp` (apre/chiude), `/fp dungeon`, `/fp cerca|find parola`, `/fp set razza-classe`, `/fp auto`, `/fp list`, `/fp help`. Italiano se `GetLocale()=="itIT"`, altrimenti inglese.
- Dati: `src/tools/addon.js` apre le pagine generate (file://) e legge checklist, talenti e dungeon dal motore stesso (opzioni di base: niente cambio continente, dungeon sì, build A). Testi ripuliti per i font di WoW (niente emoji, → diventa ->).
- Prova: `addon-test.js` carica `Data.lua` + `Core.lua` in un WoW finto (`addon-test.lua`) con **fengari** (Lua in JS). Già installato in `%LOCALAPPDATA%/fp-lua` (se manca: `npm i --prefix "$LOCALAPPDATA/fp-lua" fengari`); lancio: `FENGARI="$LOCALAPPDATA/fp-lua/node_modules/fengari" node src/tools/addon-test.js`.
- Versione: cambiala in `.toc` e in `addon.html` (due pill «versione»); i comandi nuovi vanno anche nelle tabelle di `addon.html` (IT ed EN).

## Regole dell'utente
- Testi in italiano, termini di gioco in inglese; ogni testo visibile anche in inglese (en.json / en-ui.json).
- Fonti migliori e attendibili, scelte per upvote/preferiti/views (Mobalytics ♥, YouTube); i dati del client (wowforever.be, Wowhead) decidono i dettagli. ✔ più fonti · 🟡 una fonte o pre-lancio · ★ novità di Forever. Niente siti che vendono boost/gold. Mai dati Classic spacciati per Forever. Criteri dei consigli sempre dichiarati.
- Agenti: al massimo 2–3, modello più economico (Haiku), poi revisione (togli note interne tipo «indice», «JSON», «non trovato»).
- Domande all'utente sempre cliccabili (AskUserQuestion), una decisione alla volta.
- Contesto basso: niente dump grandi in chat (attento a `Data.lua`, 1,2 MB, e alle pagine generate: estrai solo righe precise), script nello scratchpad.
- Ogni modifica visibile: verifica a 390px e su desktop, manda lo screenshot all'utente.
- Prima di azioni verso l'esterno (nuovi repo, pubblicazioni, account) chiedi conferma.

## Trappole già incontrate
- Script con backslash o regex: scrivili con Write in un file `.js`, non con heredoc in Bash.
- Zip: usa `C:\Windows\System32\tar.exe -a -c -f` (il `tar` di Git non fa zip; `Compress-Archive` mette `\` nei percorsi e su Mac si estrae male).
- Mobalytics e Icy Veins danno 403 a WebFetch: leggili dal browser integrato (`javascript_tool` → testo della pagina). Reddit è bloccato.
- In JS di pagina non chiamare variabili globali `top`, `name`, `status` (proprietà di `window`).
- Le regole CSS con `#id` vincono su quelle con classe: lo schermo intero della mappa nella scheda Percorso ha richiesto `#miniHost .lwrap.full #lmap`.
- GitHub ogni tanto risponde 500 al push: riprova.

## Da fare (in ordine)
1. **Dal 5 nov, addon nel gioco vero** (promemoria programmato il 5 nov alle 10): si carica? Interface e cartella AddOns di Forever (in beta `_classic_beta_`, 16001); token di `UnitRace` degli Skyborne (ipotesi: contiene «Skyborne»); talento indicato giusto; spunte dopo un riavvio (in beta le SavedVariables non venivano rilette). Correggere e alzare la versione.
2. **Pubblicare l'addon** dopo la prova: CurseForge e Wago (account dell'utente; categoria Quests & Leveling, licenza, logo 400×400 da `icon-512.png`, screenshot dal gioco, rilascio beta), poi eventuale caricamento automatico da GitHub con token.
3. **Guida fino al 60**: rotte e build da fonti reali sul gioco uscito, `maxLevel` 60 (`segments`/`steps`/`milestones`/`spells` fino al 60; le build arrivano già al 60).
4. **Ricontrollare sul gioco uscito**: dungeon (boss, quest, giudizi), classifica degli alt (le tier list erano sulla beta 1–30), Legacy.
5. **Gold farming**: quando ci saranno testimonianze dal gioco.
6. Facoltativo: `/impeccable init` per `PRODUCT.md`. Le eccezioni del controllo di design (font Inter, titolo dorato, linea della cronologia) sono in `.impeccable/config.json` (locale, non nel repo).

## Dubbi aperti
Build 31–60 da una sola fonte per varie classi 🟡; molte tappe delle rotte da una fonte (games.gg) e livelli di Zephras stimati; valori di alcuni racial discordi; Legacy (costi dei perk, cap 16, 62 o 65 challenge) da confermare in gioco.
