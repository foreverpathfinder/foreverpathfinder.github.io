# Pubblicare l'addon su CurseForge e Wago

Materiale pronto da copiare. Prima della pubblicazione: prova nel gioco vero (`/fp debug`), poi alza la versione in `.toc` e `addon.html` e rigenera lo zip (`node src/tools/addon.js`).

## Dati del progetto (uguali sui due siti)
| Campo | Valore |
|---|---|
| Nome | Forever Pathfinder |
| Gioco / versione | WoW: Forever, quando compare tra le versioni (in beta Interface 16001) |
| Categoria | Quests & Leveling |
| Licenza | MIT (testo in `addon/LICENSE`) |
| Logo | `logo-400.png` (400×400) |
| Sito / sorgenti | https://foreverpathfinder.github.io/addon.html · https://github.com/foreverpathfinder/foreverpathfinder.github.io |
| Segnalazioni | https://github.com/foreverpathfinder/foreverpathfinder.github.io/issues |
| File | `ForeverPathfinder.zip`, tipo di rilascio **Beta** finché non è provato da più persone |
| Screenshot | dal gioco vero: finestra aperta, `/fp dungeon`, `/fp cerca` (da fare dal 5 nov) |

## Riassunto (CurseForge «Summary», Wago «Short description»)
Leveling checklist, next talent and dungeons for your level in WoW: Forever. English and Italian.

## Descrizione (Markdown)

```markdown
**Forever Pathfinder** is the in-game companion of the free leveling guide at [foreverpathfinder.github.io](https://foreverpathfinder.github.io/), made for **WoW: Forever**: every race (Skyborne included) and every class.

### What it does
- Detects your race, class and level by itself.
- Shows the guide items for your level: trainers, talents, Flight Paths, key quests, dungeons. Tick them as you go: they are saved per character.
- Tells you your route stage and the build you are following.
- **Talents**: with a free point it tells you which talent to take; otherwise which one comes next and at what level.
- **Dungeons**: which ones to run at your level (go or optional). `/fp dungeon` prints the entrance and the quests to pick up first, class quests included.
- **Search**: `/fp find word` finds a quest, an NPC or a place in the whole guide.
- Updates when you level up; `<` `>` show the levels before and after.
- Italian if your game is in Italian, English otherwise.

### Commands
| Command | What it does |
|---|---|
| `/fp` | Opens or closes the window (also `/pathfinder`) |
| `/fp dungeon` | Recommended dungeons and their quests in chat |
| `/fp find word` | Searches the whole guide |
| `/fp set race-class` | Picks the route by hand (e.g. `/fp set skyborne_h-druid`) |
| `/fp auto` | Back to automatic detection |
| `/fp list` | Every race-class combination |
| `/fp debug` | Version, race and class as the game sees them, talents, saved data |

For the map, clickable coordinates and the other builds, keep the website open on your phone.

Found a bug? [Open an issue](https://github.com/foreverpathfinder/foreverpathfinder.github.io/issues) with a screenshot of `/fp debug`.

---

**Italiano** — Checklist di leveling, prossimo talento e dungeon adatti al tuo livello in WoW: Forever, per tutte le razze e classi. Si spunta mentre giochi e ricorda tutto per personaggio. Guida completa e istruzioni in italiano: [foreverpathfinder.github.io/addon.html](https://foreverpathfinder.github.io/addon.html).

*Free personal project, not affiliated with Blizzard Entertainment.*
```
