# Game design

Numbers here are the current values. The source of truth is `tools/generate_data.gd`; the full table with before and after is `design/balance.md`.

## Loop

1. Pick a level in the menu (locked until the previous one is won).
2. Build towers on slots with amino acids. Enemies come in timed waves along the path.
3. Each enemy that reaches the exit takes body health. At 0 body health the level is lost.
4. Defeat every wave to win. The best body health left is saved.

Enemies drop amino acids when they die. Selling a tower returns part of its cost. The player can call the next wave early and switch to 2x speed. The top bar adds the reward only when the flying amino acid orbs reach it. Building a tower sends orbs from the top bar into the new tower. The map zooms with a two-finger pinch (Ctrl and wheel on a computer) from the zoom that fits the whole map between the bars up to 2x; the tissue goes on past the map edges so zooming out never shows an empty border. Tapping an enemy picture in the next-wave preview shows its attributes. The tissue moves slowly like a living organ; as body health drops it turns red and pus oozes from it.

## Towers

| Tower | Role | Damage type | Cost | Behaviour |
|---|---|---|---|---|
| Macrophage | single target | physical | 50 | 14 damage per second to the first enemy in range |
| Neutrophil | rapid fire | physical | 45 | 5 damage every 0.4 s |
| Mucus Cell | slow | none | 40 | Mucus puddle slows 40% for 6 s |
| Platelet | root | none | 55 | Holds up to 3 enemies for 3 s each (half for bosses), one tendril per enemy, the furthest first; the same enemy cannot be held again for 3 s |
| Hypothalamus | damage over time | thermal | 90 | Fever: 3 damage per second for 4 s |
| Lysozyme | area | chemical | 70 | 4 per second; strong on bacteria, weak on viruses |
| Interferon | area | antiviral | 70 | 5 per second, slows viruses 25%; bacteria immune |
| T Lymphocyte | single target, mobile | immunological | 90 | 55 damage every 2 s, ignores armor; charges between shots and fires a thick beam that explodes on the target |
| B Lymphocyte | summoner, mobile | antiviral | 70 | Antibodies mark up to 4 enemies: +35% damage for 5 s |
| Bone Marrow | summoner | physical | 90 | A neutrophil at once, then a clock that creates one every 15 s while there are fewer than 3 (deaths do not restart it), that each hold one enemy only (the rest walk past), and the held enemy fights back with its attack animation. They drift around their post, and walk along the path to meet any non-boss enemy that comes within 60 units of the post. Neutrophils recover 2 health per second |

Mobile towers can be moved to another slot.

**Tower information.** Holding a build card or a built tower for 0.3 s shows its attributes (role, cost, range, damage, ability) and which enemies of the current level it is good, weak or useless against. Releasing closes the panel and does not build or open the sell card. A quick tap builds or opens the sell card as before.

**Attack feedback.** Every tower plays an attack animation when it attacks. Area towers (lysozyme, interferon) also send a ring from the tower to the edge of its range in 0.6 s, coloured by damage type. The hypothalamus plays its attack animation and a heat ring whenever it ignites an enemy. The interferon mist appears only when it attacks and fades out 1.5 s later. Enemies marked by a B lymphocyte are dyed lilac while the mark lasts. The T lymphocyte plays a charging animation that fills the time between shots and fires a thick beam with an explosion. The platelet grows one tendril to each enemy it roots (up to 3); the tendril holds the enemy for as long as it is paralysed and then disappears. Enemies hurt by thermal, chemical or immunological damage flash orange, green or lilac.

## Damage types

| Type | vs virus | vs bacterium |
|---|---|---|
| physical | 1.0 | 1.0 |
| thermal | 1.0 | 1.0 |
| chemical | 0.5 | 1.5 |
| antiviral | 1.5 | 0.0 |
| immunological | 1.0 | 1.0 |

Armor (percent) reduces physical, thermal, chemical and antiviral damage; immunological ignores it. Some enemies override the table (C. difficile takes half from thermal and chemical).

## Enemies

| Enemy | Type | Health | Speed | Trait |
|---|---|---|---|---|
| Rhinovirus | virus | 20 | 45 | Appears in large groups |
| Influenza | virus | 30 | 79 | Fast |
| SARS-CoV-2 | virus | 60 | 45 | Releases 2 small rhinoviruses on death |
| Herpes Simplex | virus | 50 | 50 | Goes dormant (immune) 1.5 s every 4 s |
| HPV | virus | 85 | 40 | 30% armor |
| E. coli | bacterium | 40 | 50 | Basic |
| Streptococcus pyogenes | bacterium | 100 | 40 | Chain of 3 segments that die separately |
| Staphylococcus aureus | bacterium | 75 | 45 | Gains 50% resistance to one damage type at 40% of the path |
| Helicobacter pylori | bacterium | 60 | 45 | Immune to slowing |
| Clostridioides difficile | bacterium | 45 | 45 | Revives once with 20% health |
| HIV (boss) | virus | 400 | 30 | Aura disables nearby towers; affects lymphocytes longer |
| Mycobacterium tuberculosis (boss) | bacterium | 300 | 22 | 30% armor, very slow |
| Neisseria meningitidis (boss) | bacterium | 290 | 35 | Splits into 2 smaller copies at half health |

Body damage is 1 to 2 for regular enemies and 8 to 10 for bosses.

## Waves

Each level has 3 to 6 waves. A wave is a start time, an interval and a list of enemy groups. The first wave of levels above 1 starts after a 15 s delay; the spawn interval has a floor of 0.6 s; wave sizes ramp up inside a level. Bosses come in the last wave of levels 3, 7 and 10. When the last enemy on the field dies and no wave is still spawning, the next wave starts in at most 5 s (`Level.EMPTY_FIELD_WAIT`).

## Difficulty

| | Easy | Medium | Hard |
|---|---|---|---|
| Starting amino acids | x1.3 | x1 | x0.95 |
| Body health | x1.5 | x1 | x0.8 |
| Enemy health | x0.8 | x1 | x1.12 |
| Enemy speed | x0.9 | x1 | x1.05 |
| Amino acids dropped | x1.15 | x1 | x0.95 |
| Time between waves | x1.25 | x1 | x0.92 |

Measured win rate with the 10 bot strategies: Easy 87%, Medium 65%, Hard 42%.

## Progress

Dragging the level list scrolls it, even when the finger starts on a card. The game shows a changelog of every version the first time it opens after an update; Settings has a WHAT'S NEW button to read it again. The menu has a HOW TO PLAY tutorial of six pages (goal, amino acids, building, immune cells, damage types, waves and controls). Level n+1 opens when level n is won. The menu shows the best body health per level ("BEST n"). Difficulty is chosen in Settings and applies to every level. The game speaks English, Portuguese (Brazil), French, Spanish, Italian, Chinese and Japanese; the language button is at the top left of the start screen. Settings also has a mute switch and volume bars for music and effects (saved on the device).

**Secret code (for testing):** on the start screen, tap the enemy 3 times, the tower 2 times, then the enemy once. A chime plays and every level opens. It is not saved: it lasts until the game is closed.

## Audio

One music loop per level (185 s, three instruments) and one sound set per tower and enemy. At most 8 sounds play at once. A short tune plays once when a level is won and another when it is lost.

## Debug aids

The secret tap code on the start screen (enemy, enemy, enemy, tower, tower, enemy) opens every level and also shows an FPS readout at the top right, on the start screen and during a level. It lasts until the game is closed.
