# Pubblicare l'addon su CurseForge e Wago

Materiale pronto da copiare. Prima della pubblicazione: prova nel gioco vero (`/fp debug`), poi alza la versione in `.toc` e `addon.html` e rigenera lo zip (`node src/tools/addon.js`).

## Dati del progetto (uguali sui due siti)
| Campo | Valore |
|---|---|
| Nome | Forever Pathfinder |
| Gioco / versione | WoW: Forever, quando compare tra le versioni (in beta Interface 16001) |
| Categoria | Quests & Leveling |
| Dipendenze | **Questie** obbligatoria (CurseForge «Required Dependency»); **OneForAll** e **MapUtils** facoltative («Optional Dependency») |
| Licenza | MIT (testo in `addon/LICENSE`) |
| Logo | `logo-400.png` (400×400) |
| Sito / sorgenti | https://foreverpathfinder.github.io/addon.html · https://github.com/foreverpathfinder/foreverpathfinder.github.io |
| Segnalazioni | https://github.com/foreverpathfinder/foreverpathfinder.github.io/issues |
| File | `ForeverPathfinder.zip`, tipo di rilascio **Beta** finché non è provato da più persone |
| Screenshot | dal gioco vero: finestra (Percorso e una scheda), segnaposti sulla mappa, finestra dei talenti, trainer (da fare dal 5 nov); intanto `anteprima-en.png` |

## Riassunto (CurseForge «Summary», Wago «Short description»)
The whole leveling guide in game: route checklist, talents, class, dungeons, waypoints and quests that tick themselves. EN / IT.

## Descrizione (Markdown)

```markdown
**Forever Pathfinder** is the in-game companion of the free leveling guide at [foreverpathfinder.github.io](https://foreverpathfinder.github.io/), made for **WoW: Forever**: every race (Skyborne included) and every class.

### What it does
- **Minimap icon**: click opens the guide, right click the options.
- **Every tab of the website** in one window with the same look: Route, Talents, Class, Professions, Dungeon, Alts, More, Info.
- **Route**: one stage at a time, items per level to tick (saved per character), the talent to take and the dungeons for your level.
- **Map and minimap**: stage waypoints on the world map; one click on an item puts its waypoint on the minimap too.
- **Quests, with Questie (required)**: see which ones are in your log or ready to turn in; items tick themselves when you turn in the quest, also for quests done before installing the addon. The map button shows the quest with Questie's icons, the book opens it in Questie's Journey.
- **Talents**: the talent to take glows in the game's talent window; with **OneForAll**, one click loads the whole build into its talent calculator.
- **Dungeons**: a Map button opens the world map on the entrance (with **MapUtils**, click its entrance icon for the dungeon map); with **OneForAll**, Bosses and loot opens the dungeon in its tab.
- **Trainer**: prints and marks the guide spells to buy.
- **Options** in game: build, dungeons, continent switch, and every game link on or off.
- English or Italian, your choice in the Options (or `/fp lang`); game names stay in English. Quests, talents and spells are matched by English name.

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
| `/fp debug` | Version, race and class as the game sees them, talents, saved data, game links |

For the interactive map and the calculators, keep the website open on your phone.

Found a bug? [Open an issue](https://github.com/foreverpathfinder/foreverpathfinder.github.io/issues) with a screenshot of `/fp debug`.

---

**Italiano** — Tutta la guida di leveling dentro WoW: Forever, per tutte le razze e classi: percorso da spuntare, talenti, classe, dungeon, segnaposti sulla mappa e quest che si spuntano da sole. Guida completa e istruzioni in italiano: [foreverpathfinder.github.io/addon.html](https://foreverpathfinder.github.io/addon.html).

*Free personal project, not affiliated with Blizzard Entertainment.*
```
