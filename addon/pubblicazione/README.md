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

Le vecchie `gioco-percorso`, `gioco-talenti`, `gioco-dungeon`, `gioco-opzioni` (grafica di prima della 1.10) sono state tolte dalla galleria il 14 nov. Ordine sistemato il 14 nov: le 7 nuove, poi minimappa e mappa. Il riordino (Media → Reorder gallery, griglia di 3 colonne) non risponde al trascinamento automatico ma alla tastiera: fuoco sull'immagine (li draggable), Spazio, frecce (sinistra/destra dentro la riga, giù/su tra le righe), Spazio, poi Done.

## Descrizione (Markdown, pubblicata su CurseForge il 20 nov)
Stesse regole della descrizione di Forever Cleanse (inglese, poi un paragrafo in italiano; frase in grassetto in cima; «Good to know» con WoW: Forever, niente file Blizzard e link alle segnalazioni), stile diverso: una partita raccontata passo per passo e una tabella delle schede. Va in **Description**, editor in Markdown, senza il titolo (CurseForge mostra già il nome).

```markdown
**Your leveling guide, one keypress away, for WoW: Forever.**

You log in. You press `/fp`. The guide already knows your race, class and level, and it shows one thing in large type: what to do next. You go, you do it, the line ticks itself when you turn in the quest. Close the window and keep playing.

That is the whole idea. Everything else is there for when you want it.

## A session with Pathfinder

**Starting out.** The *Route* tab opens on the next step, with three buttons: *Show on the map*, *Questie*, *Done*. The rest of the stage is one line per item; click a line to read it. If you skipped something earlier, it waits under *Left behind*.

**Finding the way.** The map button drops a waypoint exactly where Questie says: the quest giver, or, once the quest is in your log, the nearest objective or turn-in. The waypoint clears itself when you get there.

**Ding.** *At this level* tells you which talent to take (it glows in the game's talent window), which dungeons fit you now and which zones have the most quests for your race right now.

**Group time.** Pick a dungeon and you get its quests, who gives them and the step you are on, the bosses in order with what to do, and a map of the inside with the bosses numbered. *Entrance* opens the world map on the door you walk in through. Dungeons with more than one door show a button for each.

**Crafting.** *Professions* follows your live skill: the current step of the 1–300 route, the materials already in your bags and bank, and, when you hit a cap, the trainer who teaches the next rank and where to find them. Hover an item for its tooltip, Shift + click to link it in chat.

## The tabs

| Tab | What you find |
|---|---|
| Route | The next thing to do, then the stage one line per item |
| Talents | The tree at any level of the build, with a bar to slide along it |
| Dungeons | Quests, bosses, map and entrance of every dungeon, 13 to 60 |
| Professions | Skill, route step, materials, trainers |
| Class | Rotation, spells, race tips |
| Alts | Which alt to make next and how the Legacy points work |
| More · Info | XP bonuses, and where every piece of advice comes from |
| Options | Build A, B or C, dungeons on or off, zones, every game link, language |

The window can be resized from its corners.

## Works with

- **Questie**: required. Waypoints, automatic ticks and quest details come from it.
- **OneForAll**: optional. One click loads the whole talent build; *Bosses and loot* opens the dungeon in its tab.
- **MapUtils**: optional. Its entrance icon opens the dungeon map.

## Commands

`/fp` open or close · `/fp options` · `/fp find <word>` search the whole guide · `/fp dungeon` dungeons for your level in chat · `/fp set race-class` pick a route by hand, `/fp auto` to go back · `/fp lang` English or Italian · `/fp debug` what the addon sees

## Good to know

- Made for **WoW: Forever**, every race (Skyborne included) and every class, from 1 to 60.
- Builds follow the most voted leveling guides on Mobalytics. Quests, zones and dungeons are checked against live game data. Each tip says whether it is confirmed by several sources, comes from a single one, or is new in Forever.
- The same guide is on the web at [foreverpathfinder.github.io](https://foreverpathfinder.github.io/), with the interactive map: handy on your phone next to the PC.
- No Blizzard files are bundled: game icons are used by name.
- Found a bug? [Open an issue](https://github.com/foreverpathfinder/foreverpathfinder.github.io/issues) with a screenshot of `/fp debug`.

---

## Italiano

Premi `/fp` e la guida ti dice la prossima cosa da fare, già per la tua razza, classe e livello; la voce si spunta da sola quando consegni la quest. Poi ci sono i segnaposti sulla mappa con Questie, il talento da prendere a ogni livello, quest, boss, mappa e ingresso di ogni dungeon, le profession con i materiali che hai e il trainer giusto a ogni cap. Testi in italiano e inglese: si sceglie nelle Opzioni o con `/fp lang`. Guida completa e istruzioni: [foreverpathfinder.github.io/addon.html](https://foreverpathfinder.github.io/addon.html).

*Free personal project, not affiliated with Blizzard Entertainment.*
```
