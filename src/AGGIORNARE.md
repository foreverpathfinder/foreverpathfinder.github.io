# Forever Pathfinder: guida per chi ci lavora

Aggiornato il 21 nov 2026 · **sito v27** · **addon 1.10.16** (in locale, non ancora pubblicato).

Guida al leveling 1–60 per **WoW: Forever** (Classic+ di Blizzard, uscito il 5 nov 2026): 10 razze, 9 classi, italiano e inglese.
Due prodotti con gli stessi dati:
- un **sito** statico per il telefono, da tenere accanto al PC;
- un **addon** per il gioco, che porta la guida in una finestra e la collega a mappa, quest, talenti e trainer.

Il livello 1–30 è dettagliato quest per quest. Dal 30 al 44 ogni tappa nomina le quest vere (QuestieDB del 16 nov), ma l’ordine delle zone resta 🟡. Dal 44 al 60 la guida va a tappe per zona, segnate 🟡, perché non ci sono ancora guide provate.

---

## 1. Inizio sessione

1. Leggi questo file e basta. Il resto si apre solo nel punto che serve (`grep -n`).
2. Nella cartella del progetto lancia `git status` e `git log --oneline -5`. A volte ci lavorano più sessioni: committa **solo i file che hai toccato**.
3. Avvia il server locale `guida-wow` (serve la cartella Desktop sulla porta 8765). Se la 8765 è occupata, il server prende un'altra porta: passala alle prove con `PORT=<porta>`.
   - Pagina: `http://localhost:<porta>/<percorso del progetto sotto Desktop>/WoW_Forever_Leveling_Companion.html#<razza>-<classe>`.

## 2. Dove sta cosa

| Cosa | Dove |
|---|---|
| Progetto | cartella `WoW Forever leveling companion/` sul Desktop (Windows 11, Git Bash e PowerShell) |
| Sito pubblicato | https://foreverpathfinder.github.io/ (GitHub Pages da `main`), pagina dell'addon `/addon.html` |
| Repo | `foreverpathfinder/foreverpathfinder.github.io`. Il vecchio repo `Stalioot/wow-forever-leveling-companion` fa solo da rimando: non toccarlo |
| CurseForge | progetto 1787542, https://www.curseforge.com/wow/addons/forever-pathfinder (account dell'utente «Staliot») |
| Gioco dell'utente | `C:\Program Files (x86)\World of Warcraft\_forever_\`. Addon in `Interface\AddOns\`: ci sono anche Questie, OneForAll e MapUtils, con sorgenti leggibili |
| Pagina di prova | Pagina privata (link nelle note locali): l'addon in un WoW finto. Sorgenti in `src/prova/`, preparazione con `node src/tools/prova.js <cartella>`. È ferma all'aspetto di prima della 1.10 |

Il nome è **Forever Pathfinder**. I file HTML tengono il vecchio nome «WoW_Forever_Leveling_Companion» per non rompere link e QR.

## 3. Ciclo di lavoro

1. **Modifica solo i sorgenti**: `src/data/*`, `src/i18n/*`, `src/engine.js`, `src/template.html`, `src/style.css`, `addon/ForeverPathfinder/Core.lua`, `addon.html`. Gli HTML della radice, `Data.lua` e lo zip sono **generati**: non toccarli a mano.
2. **Rigenera il sito**: `node src/tools/build.js`. Leggi gli avvisi:
   - «testi senza traduzione inglese» → `src/i18n/missing-en.json` (vanno aggiunti a `en.json`, anche quando sono identici in inglese);
   - talent, NPC o quest non validi → `src/check-report.txt`;
   - «ordine corto» per alcune build B/C: è normale.
3. **Prova il sito** (serve il server):
   - `PORT=<porta> node src/tools/test.js` → in tutte e due le lingue deve dare `nbad 0`, `errors []`, `nita 0`. `nita` conta l'italiano rimasto nella pagina inglese;
   - `PORT=<porta> node src/tools/icons.js` → `rotte 0`.
4. **Addon**, se cambiano dati o `Core.lua`:
   - `node src/tools/addon.js` (circa 1 min) → rigenera `Data.lua` e `ForeverPathfinder.zip`;
   - `node src/tools/addon-test.js` → «addon: tutte le prove ok» (4 lingue × 56 combinazioni). Usa fengari in `%LOCALAPPDATA%/fp-lua`.
5. **Guarda il risultato**:
   - sito: browser integrato a **390×844** e su desktop;
   - addon: `PV="Razza,CLASSE,livello" PVBG='#14181d' node src/tools/addon-preview.js itIT|enUS <scheda> <cartella>`. Schede: `livello`, `talent`, `dungeon`, `prof`, `classe`, `alt`, `altro`, `info`, `opzioni`. Varianti: `"dungeon.<nome>"` clicca un pulsante, `"talent~400"` scorre di 400 px;
   - **manda gli screenshot all'utente**.
6. **Versione**, quando cambia qualcosa di visibile:
   - sito: `version` e `updated` in `src/data/common.json` (a mano: quel file ha un formato suo). Per una data nuova serve la riga in `en.json` (es. «15 novembre 2026»);
   - addon: `## Version` in `addon/ForeverPathfinder/ForeverPathfinder.toc` e le due pill «versione» in `addon.html`, poi riscrivi `addon/changelog.md` (in inglese, solo la versione nuova).
7. **Commit** dei soli file toccati:
   - comando: `git -c user.email=80699208+Stalioot@users.noreply.github.com commit`;
   - messaggio in italiano, senza righe di attribuzione (niente `Co-Authored-By`, nessuna citazione di strumenti).
8. **Pubblica solo se l'utente lo dice** («pusha», «pusha in beta»):
   - `git push`. Pages si aggiorna in 1–2 minuti;
   - se il `.toc` ha cambiato versione, il workflow `.github/workflows/curseforge.yml` carica da solo lo zip committato su CurseForge come **beta**. Controlla con `gh run list --limit 3`: il tag `cf/v<versione>` vuol dire «già caricata»;
   - poi copia l'addon nel gioco: `cp -r addon/ForeverPathfinder/. "<gioco>/Interface/AddOns/ForeverPathfinder/"`. L'app CurseForge dell'utente a volte rimette la versione pubblicata: in quel caso ricopiala.

## 4. File

| File | Cosa contiene |
|---|---|
| `src/data/common.json` | versione, data, `maxLevel` 60, `lateNote` (avviso sul 30–60), bonus XP, regole, camping, crate, fonti comuni |
| `src/data/classes/<classe>.json` | `build` (51 talent, uno per livello dal 10), `builds` A/B/C, `why` (perché di ogni talent), `summary`, `buildSource`, `compare`, `spells` e `talentSpells` (`[livello, nome, icona, testo]`), `rotation` e `rotNotes`, `milestones`, `camp`, `professions`, `stats`, `races`, `forever` (novità), `sources`, `doubts` |
| `src/data/talents/<classe>.json` | alberi del client da foreverchanges.pro: `node src/tools/fc.js <classe>`. Il campo `wfSame` dice se wowforever.be ha lo stesso albero: se sì, il sito incorpora il suo calcolatore |
| `src/data/factions/alliance.json`, `horde.json` | razze, rotte 1–30 (`segments` e `steps`), `late` (tappe 30–60), `milestones` di fazione, `dungeons` `[nome, min, max, dove, nota]`, `crates` |
| `src/data/dungeons.json` | scheda Dungeon (schema sotto); `general` e `glossary` = «Come conviene farli» |
| `src/data/dgmaps.json`, `dgmap/*.webp` | mappe dei dungeon (scheda Mappa): immagine, boss e ingresso in pixel; li crea `dgmaps.js` |
| `src/data/dgplan.json` | piante dei dungeon per l'addon (sezione «Pianta»/«Layout» della scheda Dungeon): terreno e stanze come FileID di texture del gioco, in yard (nello zip solo numeri). Lo crea `dgmaps.js`: i FileID del terreno li legge dal `.wdt` nell'archivio di Forever con il codice di Twinmap e le chiavi che il server ha messo in `_forever_/Cache/ADB` (servono per i dungeon nuovi). `addon.js` lo mette in `ForeverPathfinderPlan`. Nei dungeon all'aperto il terreno passa da una maschera fatta da noi (`addon/ForeverPathfinder/Masks/*.tga`, la sagoma attorno a boss e ingresso); in quelli al chiuso niente terreno. Visore con zoom e trascinamento; boss col ritratto dal `displayID` di OneForAll (`SetPortraitTextureFromCreatureDisplayID`), o la sua icona di riserva |
| `src/data/zones.json` | zone consigliate per razza e livello: `node src/tools/zones.js <cartella QuestieDB>` |
| `src/data/profs.json` | percorsi 1–300 delle professioni (fonte: wowforever.be «Leveling 1-300») |
| `src/data/alts.json`, `transfers.json` | scheda Alt (classifica, piano dell'alt, Legacy); cambi di continente |
| `src/data/worldmap.json`, `uimaps.json` | mappa di Wowhead (`map.js`); zone di Wowhead con gli uiMapID del gioco (`uimaps.js`), per i segnaposti nell'addon |
| `src/data/quests.txt`, `questinfo.json` | elenco delle quest di Forever (`quests.js`; serve a controllare i nomi); chi può fare ogni quest, da MapUtils (`questinfo.js`) |
| `src/i18n/en.json` | inglese dei **dati**: `{"testo italiano esatto": "inglese"}` |
| `src/i18n/en-ui.json` | inglese di template ed engine: coppie `["italiano", "inglese"]` sostituite come sottostringhe |
| `src/engine.js`, `template.html`, `style.css` | motore del sito (nessun dato di gioco), struttura, stile (colori come variabili in `:root`) |
| `addon/ForeverPathfinder/` | `.toc` (Interface 16001), `Core.lua` (scritto a mano), `Data.lua` (generato, ~4 MB: non leggerlo intero), `icon.tga`, `Fonts/` (Barlow e Barlow Condensed, licenza OFL). Niente librerie proprie: LibDBIcon arriva da Questie |
| `addon.html` | pagina dell'addon, scritta a mano, IT ed EN nella stessa pagina |
| `addon/pubblicazione/` | immagini e testi per CurseForge (`README.md`: riassunto, galleria, descrizione in Markdown, come riordinare la galleria) |
| `PRODUCT.md` | contesto di prodotto per la skill impeccable (design) |

**Strumenti** in `src/tools/` (quelli non citati altrove):
- `mobalytics.js`: lettori delle guide e confronto delle build (vedi §8);
- `qdb.js`, `dg35.js`: dati di QuestieDB e quest dei dungeon (vedi §8);
- `dgmaps.js`: mappe dei dungeon da Twinmap installato sul PC (terreno dai blocchi, stanze da `interiors.json`, boss da `DUNGEON_PINS`/`NEW_DUNGEON_PINS`). Rilancialo quando Twinmap si aggiorna; le immagini sono ricavate dai file del gioco e l'utente ha deciso di pubblicarle (17 nov). Ritratti: `displayID` e icone di riserva da OneForAll (`Data/Dungeons/*.lua`); sul sito la miniatura del modello su Wowhead, controllata a ogni esecuzione (molti modelli nuovi di Forever non ci sono: teschio). Nel sito i boss si numerano con l'ordine di `dungeons.json`; i nomi d'incontro diversi da quelli del mostro vanno in `AK` (`dgmBoss` in `engine.js`);
- `addon-preview.(js|lua)`: anteprime dell'addon;
- `addon-test.(js|lua)`: prove dell'addon;
- `quests-check.lua` con `runlua.js`: controllo dei collegamenti delle quest;
- `icon.js`, `logo.js`: icone dell'app e logo.

**Chiavi**:
- razze: `human dwarf gnome nightelf skyborne_a orc undead troll tauren skyborne_h`;
- rotte: `elwynn dunmorogh teldrassil zephras_a durotar mulgore tirisfal zephras_h`;
- fazioni: `A`, `H`.

## 5. Schemi dei dati

- **Testi e traduzioni**: ogni testo italiano dei dati ha la sua riga in `en.json`, con chiave = testo italiano **esatto**.
  - Se cambi un testo, cambia anche la chiave: togli la riga vecchia e aggiungi la nuova.
  - I nomi di gioco restano in inglese anche nella versione italiana.
  - Per modifiche grandi scrivi uno script Node nello scratchpad che cambia il JSON ed `en.json` insieme. Riscrivili con `JSON.stringify(o, null, 1) + "\n"`: è il formato dei file, tranne `common.json`.
- **Milestone**: `{"l":10,"t":"<b>Quest</b>: …","r":["dwarf"],"f":"A","npc":["Nome esatto"]}`.
  - `r` e `f` filtrano per razza e fazione;
  - `b: ["a"]` (milestone di classe): solo con quelle build. Serve per le milestone che parlano dei talenti di una build (es. «Ferocity ×3» della A).
  - `npc` crea il pulsante 📍 (il nome deve essere identico a quello in `worldmap.json`).
  - in `en.json` il testo serve due volte: con i `<b>` e senza tag (primi 140 caratteri, per l’addon). Se manca, `build.js` lo mette in `missing-en.json`.
- **Build**: `builds:[{id, name, spec, icon, when, pros, cons, ratings:{speed|ease|versatility|survival|aoe|gear:[1–5, motivo, fonte]}, build, rotation?, respec?, sources}]`.
  - B e C prendono dalla A solo ciò che non hanno: `rotation` (se manca, quella della A: mettila se la spec è diversa), il riepilogo («Scelta» / «Perché questa build» = il loro `when`), gli spell dei talenti (calcolati da `build.js` sull'ordine della build: descrizione da `talentSpells` della classe se c'è, altrimenti ogni talento con costo o cooldown nei dati del client).
  - `respec: {at, text, build}` (solo B e C): dal livello `at` vale `build`, un secondo ordine completo contato dal primo punto (i punti fino ad `at` si rimettono tutti insieme). Sito e addon lo mostrano come «Respec al N». `text` comincia in minuscolo (segue «Respec al N:»).
  - A = la guida più votata (vedi §8);
  - un voto c'è solo se una fonte lo giustifica.
- **Rotazione**: `[{title, seq:[[icona, etichetta]], text}]`.
  - Il titolo comincia con la fascia di livello: `"10–19 · …"`, `"40+ · …"` o `"30 · …"`. L'addon apre la fascia del tuo livello (`rangeOf`; se due fasce valgono, vince l'ultima);
  - le fasce senza livello (`"AoE"`, `"Pull multipli"`) vanno in fondo;
  - le icone sono nomi di icone del gioco: prendile da `spells`, `talentSpells` o dagli alberi.
- **Dungeon**: `dungeons.json` → `dungeons[chiave]`. La chiave è il nome in `factions/*.json`, minuscolo, senza ★ e senza «The » (es. `scarlet monastery: library`). Campi:
  - `e`: ingresso;
  - `k`: chiave d'ingresso per fazione;
  - `v`: giudizio per fazione `[go|opt|skip, livello ideale o "", perché]`;
  - `q`: quest `A`, `H`, `N` (tutte e due) = `[quest, "NPC, zona, dopo …"]`, più `C` per le quest di classe;
  - `b`: boss in ordine;
  - `t`: consigli. Un consiglio che nomina un boss in `<b>` finisce sotto quel boss.

  I nomi devono essere uguali a quelli di OneForAll (es. «Scarlet Monastery: Library»), così il pulsante «Boss e loot» apre la pagina giusta.
- **Trainer delle profession** (`profs.json` → `professions[].trainerMax`): per le 6 di crafting, NPC → grado più alto che insegna (2 Journeyman, 3 Expert, 4 Artisan), dal titolo in `foreverNpcDB.lua` di QuestieDB («Journeyman Tailor», «Expert …», «Artisan …»/«Master …»). Sito (`ptrain`) e addon (`nearestTrainer`, `mx`) per ogni grado scelgono il più vicino che lo insegna; senza titolo vale solo per Journeyman. Raccolta e secondarie: titoli generici, nessun filtro. Se cambia `worldmap.json`, rifai `trainerMax` con `node src/tools/trainers.js <cartella QuestieDB>`.
- **Classifica degli alt** (`alts.rank`): `tiers {classe: [voto Mobalytics, voto Timesaver]}` con S=4…D=0, `order` (spareggio), `profs`.

## 6. Sito (`engine.js`)

- **Stato**: in localStorage `wfcP`.
  - `S` = personaggio attuale: `r` razza, `c` classe, `L` livello, `tab`, `done` (spunte), `o` = opzioni;
  - opzioni: `x` cambio continente, `prof`, `dg`, `zn`, `tal`, `b` (build per classe).
  - `bind()` calcola `RA`, `CL`, `TAL`, `FA`, `RT`, `PT`; `renderAll()` ridisegna tutto.
- **Pagina iniziale** `#home`: personaggi, scelta di razza e classe, opzioni, salvataggio su file, riquadro dell'addon.
- **Schede**: Percorso (`renderLevel` + `renderPath`: livello, zone consigliate, tappe con checklist), Talent, Mappa (Leaflet con tessere Wowhead, `MAPI.fly`), Classe, Profession (`renderProf`), Dungeon, Alt, Altro, Info.
- **Altre funzioni**:
  - ricerca 🔍 (`sIndex`);
  - condivisione `#s=<base64>`;
  - «Segnala un errore» apre `report.html` (link corto `foreverpathfinder.github.io/report`) (scritta a mano, IT/EN) col contesto già scritto; la pagina manda le segnalazioni, senza login, a un Google Form dell’utente (`FORM` ed `entry.*` in fondo alla pagina: se cambi i campi del modulo, aggiornali). Anche l’addon (`/fp bug`) e `addon.html` puntano lì. Le risposte vengono controllate ogni giorno con il task pianificato `segnalazioni-forever-pathfinder`;
  - ☕ PayPal;
  - contatore hits.sh.
- **Cookie**: il calcolatore di wowforever.be si carica solo dopo «Accetta e carica», perché salva cookie di Google Analytics. Il sito da solo non salva cookie.
- **Accessibilità**: sotto 520 px tutto ciò che si tocca è almeno 44 px; meno animazioni se il sistema lo chiede.

## 7. Addon (`Core.lua`)

- **Finestra**: 680×500 (`W, H, TOP, RW`). Si apre dall'icona della minimappa (LibDBIcon di Questie) o con `/fp`, e si chiude con Esc.
  - Grandezza (1.10.9): le maniglie negli angoli in basso (texture del gioco `UI-ChatIM-SizeGrabber`, solo il percorso) cambiano la **scala** di tutta la finestra (0.6–1.6), salvata in `ForeverPathfinderDB.scale`. Il contenuto non si ridispone: resta largo `BW`.
  - Aspetto della 1.10: sfondo nero all'85%, accento **verderame #7fd4b0**, rame `e0a074` per i numeri nei sottotitoli, caratteri Barlow. La palette sta in `HEX`.
  - Schede in colonna a sinistra (`NAVORD`): Percorso, Talent, Dungeon, Profession | Classe, Alt, Altro, Info; Opzioni in fondo.
- **Schede**:

  | Scheda | Funzione | Cosa fa |
  |---|---|---|
  | Percorso | `drawPath` | «Adesso» (prima voce non spuntata, con i pulsanti Mappa, Questie e Fatto), le altre voci su una riga, RIMASTE INDIETRO, A QUESTO LIVELLO, ZONE CONSIGLIATE |
  | Talent | `drawTalents` | albero al livello scelto, barra di tutti i livelli con − e +, I PROSSIMI |
  | Classe | `drawClass` | Rotazione, Spell, Razza, Consigli |
  | Dungeon | `drawDungeons` | menu, poi la scheda del dungeon con Quest, Boss, Come arrivarci, Consigli |
  | Profession | `drawProfs` | skill vera, passo della skill, materiali nelle borse, trainer più vicino |

- **Dati da `Data.lua`**:
  - `ForeverPathfinderData`, `Pool`, `Pages`: varianti, testi, tappe;
  - `Links`: segnaposti e quest per voce;
  - `Dungeons`, `DungeonPos`: dungeon e ingressi;
  - `ZoneMaps`, `Trees`, `Class`, `Zones`, `Profs`, `ProfTrainers`, `Trainers`.

  `addon.js` li ricava aprendo le pagine generate del sito per ogni razza, classe e variante di opzioni (524 varianti).
- **API**: Forever ha le API dei client moderni:
  - `C_QuestLog.*` per il registro delle quest;
  - `C_Spell.GetSpellInfo` e `IsPlayerSpell` per le spell;
  - `C_ClassTalents` e `C_Traits` per i punti spesi;
  - `C_Map` per i segnaposti.

  Tutto passa per i **nomi inglesi** del gioco.
- **Collegamenti con altri addon**:
  - **Questie** (obbligatorio, `RequiredDeps`): da nome a ID, quest già consegnate, segnaposto sul punto esatto (`qPointId`), catena delle quest dei dungeon (`qChain`), finestra Journey. Ogni chiamata ai moduli interni va in `pcall`;
  - **OneForAll** (facoltativo): import della build (`TalentCode`) e «Boss e loot» (`ofaDungeon`, per nome esatto);
  - **MapUtils** (facoltativo): non ha funzioni pubbliche. La mappa si apre sulla zona dell'ingresso (`dgFind`) e MapUtils mostra la sua icona.
- **Spunte automatiche**: quest consegnate, Flight Path imparati (`fpDone`), punti talento spesi, spell del trainer già nel libro.
- **Lingua**: inglese di base; l'utente la cambia nelle Opzioni o con `/fp lang`. Niente pulsante della lingua in testata.
- **Comandi**: `/fp`, `options`, `lang`, `dungeon`, `find <parola>`, `set <razza-classe>`, `auto`, `list`, `debug`, `help`. Se ne aggiungi uno, mettilo anche nelle tabelle IT ed EN di `addon.html`.
- **Limite di Lua**: al massimo 200 variabili locali per file. Lo stato delle schede sta nella tabella `V` e i blocchi grandi sono chiusi in `do … end`.

## 8. Fonti e come aggiornarle

**Regola**: le fonti si scelgono per voti e preferiti; i dati del client decidono i dettagli.
- ✔ = confermato da più fonti, 🟡 = una sola fonte o prima del lancio, ★ = novità di Forever.
- Niente siti che vendono boost o gold. Mai dati di Classic spacciati per Forever.
  - Eccezione decisa dall'utente il 18 nov: Timesaver e Conquest Capped (vendono boost e gold) si usano per la classifica degli alt e per i dungeon, dicendolo nel testo; si prende solo il loro giudizio sulle classi o sui dungeon.
- Il criterio di ogni consiglio va dichiarato.
- Negli elenchi delle fonti restano solo quelle da cui la guida ha preso qualcosa: niente video non visti, pagine non lette o «solo segnale» (pulizia del 18 nov).

**Siti e cosa prendere**:
- **Build A di ogni classe**: la guida di leveling con più ♥ su https://mobalytics.gg/wow-forever/leveling-guides.
  - Al 19 nov: Warlock Crix (789 ♥, agg. 18 nov), Hunter Feor (649, 18 nov), Paladin yumytv (492, 12 nov), Shaman Tiqqle (435, 13 nov), Mage Asuna_qt (397, 18 nov), Warrior Ahlaundoh (392, 17 nov, scheda «Protection 1-60»; la B è la sua «Arms 1-60»), Druid yumytv (252, 14 nov), Priest DoubleZug (217, 9 nov), Rogue Djexde (187, 12 nov).
  - Le build A sono tutte uguali alle loro. Dal 19 nov seguono le guide più votate anche Warlock B (Demonology di Crix), Mage B (scheda «Arcane Leveling 1-60» di Asuna_qt) e Rogue B (scheda «1-60 Subtlety» di Djexde); per le altre B e C restano Icy Veins o i dati del client.
  - ♥ e date compaiono nei testi delle classi (summary, buildSource, fonti): quando cambiano, aggiornali anche lì e in `en.json`.
  - Come leggerle: nel browser integrato, sulla pagina della guida, esegui con `javascript_tool` il codice stampato da `node src/tools/mobalytics.js talenti` (o `rotazione`). Poi confronta con `node src/tools/mobalytics.js confronta <classe> a "<riga>"`.
- **Alberi, spell, patch, dungeon**: https://foreverchanges.pro, che legge i dati del client.
  - Pagine utili: `/talents/<classe>` (con `fc.js`), `/spellbook/<classe>` (spell anticipate in Forever), `/patch-notes`, `/dungeons` (livelli di ogni dungeon e ala) e `/dungeons/<nome>` (boss).
- **Quest**:
  - QuestieDB per Forever (repo `Questie/QuestieDB`): `data/Forever/foreverQuestDB.lua` e `foreverNpcDB.lua`, `src/corrections/Forever/generated|traces`, `foreverQuestFixes.lua`, `support/Forever/Zones/areaIdToUiMapId.lua`;
  - scaricali con `gh api repos/Questie/QuestieDB/contents/<percorso> -H "Accept: application/vnd.github.raw"` in una cartella, insieme a `whdq.json` (quest per dungeon dalle pagine zona di Wowhead, via `fetch` dal browser integrato);
  - copia lì `qdb.js` e `dg35.js` ed eseguili da lì.
- **Boss dei dungeon**: Twinmap (twinmap.app, di un amico dell'utente; app installata in `%LOCALAPPDATA%/Programs/twinmap`). In `resources/app.asar` il renderer ha `DUNGEON_PINS` (dungeon classici) e `NEW_DUNGEON_PINS` (i 9 nuovi di Forever), ricostruiti dai file del gioco: per ogni dungeon nome, mappa, ingresso e boss con coordinate. L'ordine è quello degli incontri nei file, non il percorso; i nomi sono quelli degli incontri (es. «Deathless Guardians», «Ravasaur Hunters»): per il nome del mostro guarda gli NPC di Questie. L'asar si legge con un piccolo script node (intestazione JSON dopo 16 byte), senza installare niente.
- **Reagent vendor e Trade Supplies** (opzione della mappa nell'addon): `src/data/vendors.json` con `node src/tools/vendors.js <cartella QuestieDB>` (foreverNpcDB, foreverItemDB, lo strato generato foreverBaseNpc/foreverBaseItem e areaIdToUiMapId.lua). Reagent vendor = chi vende i reagent delle classi (Arcane Powder, Light Feather, candele, semi…), perché il sottotitolo in QuestieDB spesso manca; Trade Supplies dal sottotitolo. Se un giocatore segnala un vendor che lì non c'è, chiedigli il nome: QuestieDB può non averlo.
- **Ingressi dei dungeon**: `src/data/entrances.json` (coordinate della zona, più ingressi = più voci, il primo è il principale) sostituisce in `build.js` i segnaposti di Wowhead. Wowhead, MapUtils e Twinmap a volte segnano il portale o l'icona della mappa e si copiano a vicenda (Krol'dok era sbagliato in tutti e tre): per i dungeon classici vale la porta di QuestieDB (`support/Forever/Zones/dungeons.lua`, già convertita per le zone cambiate) confermata dalla meeting stone (`foreverObjectDB`); per quelli nuovi servono due fonti che concordano o la prova nel gioco. Se non è sicuro, metti la meeting stone. Coordinate nei testi «Come arrivarci» uguali a quelle del file.
- **Icy Veins, ordine dei talent**: il link «Open in Calculator» della guida ha l'ordine dei punti dopo `#tc-` (prima di `~`): ogni carattere è il `data-talenturlid` di un talento nel calcolatore. Apri il link nel browser integrato e leggi i nomi dagli `input[data-talenturlid]` (controlla che i conteggi coincidano con i ranghi mostrati).
- **Altre**: Icy Veins (guide di leveling aggiornate il 13–17 nov, data in `dateModified`; Holy Paladin e Restoration Shaman ricontrollate il 19 nov: uguali alle nostre Paladin B e Shaman C; Arcane Mage e alcune altre ferme al 4 nov), Wowhead Forever (mappa, zone), wowforever.be (calcolatore, professioni), Warcraft Tavern e Conquest Capped (dungeon, giudizi).

## 9. Regole dell'utente

- Rispondi in italiano, con i termini di gioco in inglese. Ogni testo visibile deve esistere anche in inglese.
- Le domande all'utente sono **sempre cliccabili** (AskUserQuestion), una decisione alla volta.
- **Push e pubblicazioni solo quando l'utente lo dice.** Su CurseForge sempre in **beta**, mai release. Prima di azioni verso l'esterno (repo nuovi, account, pubblicazioni) chiedi.
- Ogni modifica visibile: controlla a 390 px e su desktop (o con l'anteprima dell'addon) e **manda lo screenshot**.
- L'utente giudica l'addon **usandolo nel gioco**: dopo una versione nuova copiala nella cartella del gioco e aspetta il suo «funziona».
- Mai file di Blizzard nello zip: le icone si usano per nome (`Interface\Icons\<nome>`).
- Contesto basso:
  - niente file grandi in chat (`Data.lua`, pagine generate): estrai solo le righe che servono;
  - script temporanei nello scratchpad.
- Agenti solo se servono: al massimo 2–3, con il modello più economico, e poi rivedi tu il risultato.
- Design: per lavori di interfaccia l'utente ha usato la skill impeccable (progettare con Fable, realizzare con Opus). Vuole un'interfaccia user friendly, che non sembri «fatta con IA», con sfondo nero, minimale, accento verderame.

## 10. Trappole già incontrate

- **Lua del gioco (5.1) e delle prove (fengari, 5.3)**: nel gioco `ipairs`/`pairs` su un testo danno errore. `addon-test.lua` li rende severi, ma con dati misti controlla sempre `type(x) == "table"`.
- **Caratteri dell'addon**: Barlow non ha ★ ✔ ↗ ■ e simili, che nel gioco escono come quadrati vuoti. Per «nuovo in Forever» si usa il pallino • verderame; controlla ogni simbolo nuovo sulla tabella cmap del font.
- **Season of Discovery**: i dati del client contengono le quest con ID 77000–91999, che in Forever non ci sono. Vanno scartate sempre.
- **QuestieDB**: nelle correzioni la zona è scritta come nome (`zoneIDs.RIVERGLADES`), non come numero: cercala in tutti e due i modi. Riverglades (2548) è nei dati dal 16 nov.
- **Siti che bloccano**:
  - Mobalytics e Icy Veins danno 403 a WebFetch: usa il browser integrato;
  - le pagine delle singole quest e spell di Wowhead chiedono la verifica umana: non usarle;
  - Reddit è bloccato.
- **Bash su Windows**:
  - script con backslash o regex: scrivili in un file `.js`, non in un heredoc;
  - `cat > /dev/null` prima di un heredoc resta in attesa per sempre;
  - Node non vede `/tmp`: usa lo scratchpad.
- **Nomi di file**: su Windows un `:` nel nome crea un file vuoto (stream alternativo). `addon-preview.js` lo sostituisce con `_`.
- **Zip**: usa `C:\Windows\System32\tar.exe -a -c -f`. Lo fa già `addon.js`; il `tar` di Git non fa zip.
- **JS di pagina**: non chiamare variabili globali `top`, `name`, `status`.
- **CSS**: le regole con `#id` vincono su quelle con classe.
- **GitHub**: ogni tanto risponde 500 al push; riprova.
- **Pagina principale di CurseForge**: è in cache lato server, per cui riassunto e galleria si aggiornano dopo ore. Per riordinare la galleria serve la tastiera (vedi `addon/pubblicazione/README.md`).

## 11. Aperto e da fare

1. **30–60 quest per quest**: fatto il 17 nov (44–60 con QuestieDB del 16 nov: quest con XP osservata, per hub; posizioni dei quest giver da `worldmap.json`, rinfrescato con `map.js`; `quests.txt` rinfrescato con `quests.js` per le quest di Mount Hyjal). Mount Hyjal ★ ha 33 quest 56–60: è la tappa del 60 e compare come alternativa nelle milestone 58–59. Da ricontrollare quando ci saranno guide provate (ordine delle quest 🟡). I dungeon 35–60 hanno giudizio, boss e consigli dal 17 nov (Warcraft Tavern, Conquest Capped, ordine dei boss da Twinmap): da ricontrollare quando ci saranno più run. Il 30–44 va ricontrollato quando ci saranno guide provate. Il 20 nov: `quests.txt` e `questinfo.json` rifatti (Wowhead e MapUtils del 20 nov); confronto delle correzioni di QuestieDB dal 16 al 20 nov sulle quest della guida: nessuna quest tolta, prerequisiti dei dungeon giusti, cambiano solo razze di alcune quest di classe e qualche livello minimo.
2. **Build B e C fino al 60**: fatto il 17 nov. Mage B è Arcane vera (dal 19 nov ordine di Asuna_qt, prima Icy Veins 10–60; la partenza Arcane con respec Frost al 31 dal 31 era uguale alla A) e Priest B (Discipline, respec Shadow al 40) ha il `respec`; Paladin B (Holy) e Shaman C (Restoration) seguono Icy Veins 10–60; Warlock C l'ordine 10–60 di wowforever.be.
3. **Da ricontrollare nel gioco uscito**:
   - classifica degli alt: fatto il 18 nov. Tre voti (`rank.voters`): Mobalytics (17 set, prima del lancio), Timesaver (13 nov) e Conquest Capped (10 nov), rifatte dopo il lancio. Da ricontrollare quando Mobalytics aggiorna la sua.
   - Legacy: fatto il 18 nov (wiki del 15 nov e Icy Veins: 65 challenge con PvP 12, punti non duplicabili, Talented 9/8/7/6/5, Field Guide 8/16/25%, Bartering 5/10%, Bear Cub a 25). Resta sconosciuto il costo del reset.
   - Scarlet Monastery Alleanza: fatto il 18 nov. Graveyard «skip» (nessuna quest), Library, Armory e Cathedral «opzionale» con le 3 quest Alleanza e il viaggio apposta. Rituals of Power spostata tra le quest di classe (solo Mage).
4. **Gold farming**: solo quando ci saranno testimonianze dal gioco. Il 19 nov letta la «Rogue Gold Farming Guide» di Rogue's Diary (Mobalytics, Verified, 18 nov): l'elenco è quello del Classic («la maggior parte resterà valida») con stime, quindi non basta.
5. **Wago**: l'addon non c'è ancora.
6. **Pagina di prova**: aggiornarla all'aspetto della 1.10, se l'utente la chiede.
7. **Dubbi aperti**:
   - build 31–60 da una sola fonte per alcune classi;
   - tappe delle rotte da una sola fonte e livelli di Zephras stimati;
   - alcuni racial con valori discordi.
