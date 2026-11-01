# Come aggiornare la guida (note per Claude)

La pagina che l'utente apre è `../WoW_Forever_Leveling_Companion.html`: **un solo file generato**. Non modificarla a mano.
Modifica i dati in `data/`, poi rigenera:

```bash
node src/tools/build.js
```
Poi `git commit` + `git push`: il sito pubblico https://stalioot.github.io/wow-forever-leveling-companion/ (GitHub Pages da `main`, cartella root) si aggiorna da solo in 1–2 minuti. `index.html` rimanda alla guida mantenendo l'`#razza-classe`.
Il build stampa "Da controllare": talent inesistenti o oltre il rank, prerequisiti di riga, città/NPC/flight path non trovati sulla mappa, classi senza dati. Poi `node src/tools/test.js` (prova tutte le combinazioni in Chrome; deve dire nbad 0 e errors []). Il build deve restare pulito (gli NPC che non sono quest giver/trainer/innkeeper/flight master possono mancare: non compaiono sulla mappa, nient'altro).

## Dove sta cosa
| File | Contenuto | Fonte primaria |
|---|---|---|
| `data/common.json` | versione, data, `maxLevel` (oggi 30 → portare a 60), lancio, bonus XP, regole, camping, crates, video, fonti comuni | guide + Kargoz |
| `data/classes/<classe>.json` | spec, build (nomi talent inglesi esatti, 1 per livello dal 10), why, compare, spell, rotation, milestones, camp, professions, razze, fonti | Mobalytics (♥), wowforever.be, Icy Veins, Method, Warcraft Tavern |
| `data/talents/<classe>.json` | talent dal client (nomi, icone, rank, tooltip, prerequisiti) + build di wowforever.be | `node src/tools/wf.js <classe>` |
| `data/factions/alliance.json`, `horde.json` | razze (racial, classi, zona iniziale), rotte per zona iniziale (segments, steps con città esatte, milestones, bags, questNPCs, flights, transport), dungeon, fonti | guide rotte + Wowhead map |
| `data/transfers.json` | cambi di continente: `junctions` (livello in cui finisce la zona iniziale di ogni rotta) e 4 passaggi `A:eastern-kingdoms>kalimdor` ecc. (steps, unlocks, quest, rotta d'arrivo) | Method, Warcraft Tavern, Wowhead map |
| `data/profs.json` | guida profession (tutte, coppie, consigli per classe, piano, gold) e alt (Legacy, bank alt, crafting alt) | Wowhead, Warcraft Tavern, wow-professions.com |
| `data/worldmap.json` | dati mappa Wowhead (3 continenti, coordinate locali a zoom 7) | `node src/tools/map.js` |
| `template.html`, `style.css`, `engine.js` | pagina, stile, motore (non contengono dati di gioco) | — |

Chiavi razza: `human dwarf gnome nightelf skyborne_a orc undead troll tauren skyborne_h`. Rotte: `elwynn dunmorogh teldrassil zephras_a durotar mulgore tirisfal zephras_h`.
Il motore compone il percorso: rotta naturale, oppure zona iniziale fino a `junction` + passaggio + rotta d'arrivo (dal livello dopo l'ultimo del passaggio). Opzioni dell'utente: percorso, 2 profession, dungeon sì/no, Talented. Calcola anche: talent per livello, link `?t=` del calcolatore wowforever.be (ranghi per albero in ordine di `data-index`, zeri finali tolti, alberi separati da `-`), tappa della mappa, dungeon nel range.

## Regole sulle fonti (richieste dall'utente)
- Scegli spec e build per **upvote/preferiti/recensioni**: Mobalytics ♥ (pagine `leveling-guides`, `creator-leveling-guides`, `community-leveling-guides`), views YouTube, data. A parità, i dati del client (wowforever.be, Wowhead) decidono i dettagli.
- ✔ più fonti o client · 🟡 una sola fonte · ★ novità di Forever. Mai dati di Classic Era spacciati per Forever.
- Reddit è bloccato. Mobalytics e Icy Veins: 403 con WebFetch e Cloudflare in headless → leggerli dal **browser integrato** (`javascript_tool`, estrarre solo il necessario; su Mobalytics il testo dopo "Points Invested" contiene "Level X-Y — Talent").
- wowforever.be, Wowhead, Warcraft Tavern, Method: `curl`/WebFetch o `scratchpad/tools/read.js` (Chrome headless via playwright-core in `%LOCALAPPDATA%/npm-cache/_npx/9833c18b2d85bc59`).
- Agenti di ricerca su Sonnet: brief e formato in `scratchpad/BRIEF.md`, `CLASS_TASK.md`, `ROUTE_TASK.md` della sessione del 1 nov (ricrearli se servono: schema = chiavi dei file in `data/`).

## Dopo il lancio (4 nov 2026) — cosa ricontrollare
1. `node src/tools/wf.js <classe>` per tutte le classi (hotfix ai talent) e `node src/tools/map.js`; rigenera e guarda gli avvisi.
2. Classifica Mobalytics aggiornata: se la guida più votata di una classe cambia spec o ordine, aggiorna `build`, `summary`, `compare`.
3. Nuove guide/video attendibili con dati reali dal gioco (RestedXP/Kargoz, Icy Veins, Wowhead, creator con molte views): rotte reali, livelli delle zone, bag, NPC.
4. Togli 🟡 dove arriva la conferma; correggi i dubbi elencati sotto.
5. Per arrivare al 60: `maxLevel: 60` in `common.json`, prolunga `segments`/`steps`/`milestones` delle rotte e `spells`/`milestones` delle classi; le build arrivano già al 60. Aggiorna `version` e `updated`, e il registro nel file MD della cartella principale.

## Dubbi aperti (1 nov)
- Priest: Shadow (Mobalytics 47 ♥) vs ibrido Disc di wowforever.be/Method; 43–60 ricostruito 🟡.
- Paladin: ordine scritto sul consenso dopo l'hotfix del 31 ott; 36–60 proiettato 🟡.
- Warrior: 31–60 solo da wowforever.be 🟡. Warlock 41–60 proiettato 🟡. Rogue 36–60 composto 🟡.
- Rotte: molte tappe da una sola fonte (games.gg); livelli Zephras Isle stimati; Excavation Site 24–29 (mappa) vs 26–33 (Warcraft Tavern).
- Racial con valori discordi tra fonti (Human Ruthless 1%/2%, Blood Fury, Berserking); Orda segue le note Blizzard 26–27 ott.
- Shaman: liv. 24 Anticipation e 30 Improved Stormstrike da Mobalytics Tiqqle (66 ♥) invece di wowforever.be; 31–60 solo wowforever.be 🟡.
- Druid: albero rimescolato il 30 ott (Berserk rimosso, Lacerate nuovo); ordine solo da wowforever.be 🟡.
- Orda: bag gratuite delle zone iniziali solo da LepreStore 🟡; NPC di The Great Outdoors per Tauren non trovato; tratto 20–30 Stonetalon/Ashenvale sintetizzato 🟡. Crates Orda: Dokimi fuori da Crossroads (50.1 29.3).
- Sleeping Bag: +3% per 2 ore (Kargoz) vs +1%/min fino a 3% (Warcraft Tavern).
- NPC non sulla mappa Wowhead (cuochi): Tomas (Elwynn), Gremlock Pilsnor (Dun Morogh).

## Mappa
Tutti i continenti stanno su una tela unica (coordinate globali = locali + `ox/oy` del continente, come Wowhead). Le tessere che il manifest non elenca non vengono richieste. Livelli pesanti (nodi, pet, rotte di volo) si creano solo quando l'utente li accende. Non mettere `position` sui marker `.spin`: rompe la posizione delle tappe.
