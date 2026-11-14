# Pubblicare l'addon su CurseForge e Wago

Materiale pronto da copiare. Prima della pubblicazione: prova nel gioco vero (`/fp debug`), poi alza la versione in `.toc` e `addon.html` e rigenera lo zip (`node src/tools/addon.js`).

## Dati del progetto (uguali sui due siti)
| Campo | Valore |
|---|---|
| CurseForge | progetto 1787542 · https://www.curseforge.com/wow/addons/forever-pathfinder (creato il 6 nov, versione di gioco «WoW Forever 1.60.1») |
| Nome | Forever Pathfinder |
| Gioco / versione | WoW: Forever, quando compare tra le versioni (in beta Interface 16001) |
| Categoria | Quests & Leveling |
| Dipendenze | **Questie** (CurseForge 334372) obbligatoria (CurseForge «Required Dependency»); **OneForAll - Forever** (1714201) e **MapUtils** (1463967) facoltative («Optional Dependency») |
| Licenza | MIT (testo in `addon/LICENSE`) |
| Logo | `logo-400.png` (400×400) |
| Sito / sorgenti | https://foreverpathfinder.github.io/addon.html · https://github.com/foreverpathfinder/foreverpathfinder.github.io |
| Segnalazioni | https://github.com/foreverpathfinder/foreverpathfinder.github.io/issues |
| File | `ForeverPathfinder.zip`, tipo di rilascio **Beta** finché non è provato da più persone |
| Screenshot | dal gioco vero (5 nov, Gnome Mage liv. 10, addon 1.3.0): `gioco-percorso.webp`, `gioco-mappa.webp`, `gioco-talenti.webp`, `gioco-dungeon.webp`, `gioco-opzioni.webp`, `gioco-minimappa.webp` (ritagliati senza chat né nomi di giocatori) |

## Riassunto (CurseForge «Summary», Wago «Short description»)
The whole leveling guide in game: next step, recommended zones, talents, dungeon quests, professions, waypoints and quests that tick themselves. EN / IT.

## Galleria (14 nov, addon 1.10.1, caricata su CurseForge il 14 nov con titoli, didascalie e stella)
Immagini dell'addon vero, fatte con `PVSCALE=2 PVBG=#14181d node src/tools/addon-preview.js enUS <scheda>` (Human Warrior al 18; `livello~600` per la parte bassa del Percorso). Le due `gioco-*` vengono dal gioco (5 nov) e sono ancora giuste.

| File | Didascalia |
|---|---|
| `cf-1-route.png` | Route: the next thing to do, then the stage in one line per item |
| `cf-2-route-level.png` | At this level: talent, dungeons and recommended zones |
| `cf-3-talents.png` | Talents: the tree at any level, with a bar for every level |
| `cf-4-dungeon.png` | A dungeon: quests in your log, chains step by step, what to do now |
| `cf-5-dungeons.png` | Dungeons for your level and the full list |
| `cf-6-professions.png` | Professions: live skill, current step, materials in your bags |
| `cf-7-options.png` | Options |
| `gioco-mappa.webp` | World map: the stage waypoints (from the game, Nov 5) |
| `gioco-minimappa.webp` | Minimap icon (from the game, Nov 5) |

Le vecchie `gioco-percorso`, `gioco-talenti`, `gioco-dungeon`, `gioco-opzioni` (grafica di prima della 1.10) sono state tolte dalla galleria il 14 nov. Ordine rimasto: mappa e minimappa per prime (il riordino della pagina dell'autore non risponde al trascinamento automatico: va fatto a mano).

## Descrizione (Markdown)

```markdown
**Forever Pathfinder** is the in-game companion of the free leveling guide at [foreverpathfinder.github.io](https://foreverpathfinder.github.io/), made for **WoW: Forever**: every race (Skyborne included), every class, from 1 to 60.

Open it, read the next thing to do, close it and keep playing.

### What it does
- **Route**: the next thing to do in large type, with **Show on the map**, **Questie** and **Done** buttons. The other items of the stage take one line each (click a line for the details) and are saved per character. Items you skipped in earlier stages wait under *Left behind*.
- **At this level**: the talent to take, the dungeons that fit your level (one click opens their quests) and the **recommended zones**: the zones with the most quests your race can pick up right now, from game data, each with a map button. You can turn the zones off in the Options.
- **Map and quests, with Questie (required)**: the map button puts a waypoint on the exact spot from Questie's database: who gives the quest or, once it is in your log, the nearest objective or turn-in. The chosen waypoint is highlighted with the NPC and quest name, and it clears itself when you arrive. Items tick themselves when you turn in the quest, also for quests done before installing the addon, and Flight Path items tick when you learn the flight path.
- **Talents**: the tree at any level of the build. A bar with every level, plus − and +, lets you move along it; your level is marked. The talent to take glows in the game's talent window. With **OneForAll**, one click loads the whole build.
- **Dungeons**: quests for every dungeon that has them, from Ragefire Chasm to Stratholme, checked against live game data, with who gives each quest. Quests that need earlier steps show *step n of m* and what to do now. Up to level 38 also bosses in order with tips, and how to get there. **Map** opens the world map on the entrance (with **MapUtils**, its entrance icon opens the dungeon map); with **OneForAll**, *Bosses and loot* opens the dungeon in its tab.
- **Professions**: your professions with their live skill, the current step of the 1–300 route, the materials you already have in your bags and bank, the nearest trainer on the map, a warning when you reach a rank's cap, and the recipe in **OneForAll**. Optional: every trainer and reagent vendor of your professions on the world map.
- **Trainer**: prints and marks the guide spells to buy.
- **Class, Alts, More, Info**: rotation, spells, race tips, which alt to make, XP bonuses, and where every piece of advice comes from.
- **Options**: build, dungeons, continent switch, recommended zones, and every game link on or off.
- **English or Italian**, your choice in the Options (or `/fp lang`); game names stay in English.

### How the guide is made
Builds follow the most favorited leveling guides on Mobalytics; routes, quests, zones and dungeon quests are checked against live game data (Wowhead and Questie). Every piece of advice is marked as confirmed by several sources, from a single source, or new in Forever.

### Commands
| Command | What it does |
|---|---|
| `/fp` | Opens or closes the guide (also `/pathfinder` or the minimap icon) |
| `/fp options` | Opens the Options |
| `/fp dungeon` | Recommended dungeons and their quests in chat |
| `/fp find word` | Searches the whole guide |
| `/fp set race-class` | Picks the route by hand (e.g. `/fp set skyborne_h-druid`) |
| `/fp auto` | Back to automatic detection |
| `/fp list` | Every race-class combination |
| `/fp lang` | English or Italian |
| `/fp debug` | Version, race and class as the game sees them, talents, saved data, game links |

For the interactive map and the full guide, keep the website open on your phone.

Found a bug? [Open an issue](https://github.com/foreverpathfinder/foreverpathfinder.github.io/issues) with a screenshot of `/fp debug`.

---

**Italiano** — Tutta la guida di leveling dentro WoW: Forever, per tutte le razze e classi, dall'1 al 60: la prossima cosa da fare in grande, zone consigliate per il tuo livello, quest di tutti i dungeon, talenti con l'albero a ogni livello, profession, segnaposti sulla mappa e quest che si spuntano da sole con Questie. Guida completa e istruzioni in italiano: [foreverpathfinder.github.io/addon.html](https://foreverpathfinder.github.io/addon.html).

*Free personal project, not affiliated with Blizzard Entertainment.*
```
