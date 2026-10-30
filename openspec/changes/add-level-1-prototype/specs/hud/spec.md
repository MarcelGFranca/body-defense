## Purpose

Defines the heads-up display of the portrait tower defense: what is shown, how the player builds and sells towers by tapping, how enemy information and the next wave are presented, and how pause and game speed work.

## ADDED Requirements

### Requirement: Portrait layout
The HUD SHALL use a portrait layout with a top bar, the map in the middle and a bottom area. The top bar SHALL stay inside the device's safe area so it is not covered by a notch or camera cutout. Every tappable control SHALL be at least 48 dp wide and tall.

#### Scenario: Safe area
- **WHEN** the device has a camera cutout at the top
- **THEN** no HUD element is hidden by it

#### Scenario: Touch target size
- **WHEN** the HUD is measured on a device
- **THEN** every button, tower choice and slot has a tap area of at least 48 dp by 48 dp

### Requirement: Scrolling the map
The player SHALL scroll the map by dragging on it. A press that moves less than a small distance (14 px) before it is released SHALL count as a tap, not as a drag. The view SHALL stop at the edges of the map, so the whole map can be brought between the HUD bars but never further. Taps SHALL act on what is under the finger on the scrolled map. Scrolling SHALL close any open menu. The HUD SHALL show a thin indicator of which part of the map is on screen, with marks for the enemies, so enemies outside the screen can be located. On a desktop the mouse wheel SHALL also scroll the map.

#### Scenario: Drag to scroll
- **WHEN** the player presses on the map and drags the finger up by 100 px
- **THEN** the map scrolls by 50 map units, so the part below comes into view

#### Scenario: Edges of the map
- **WHEN** the player keeps dragging past the end of the map
- **THEN** the view stops at the edge and does not show beyond it

#### Scenario: Tap or drag
- **WHEN** the player presses and releases moving less than 14 px
- **THEN** it counts as a tap and the map does not scroll

#### Scenario: Tap on a scrolled map
- **WHEN** the map is scrolled and the player taps a slot on screen
- **THEN** the slot under the finger is selected

#### Scenario: Scrolling closes menus
- **WHEN** a build menu is open and the player starts dragging the map
- **THEN** the menu closes

#### Scenario: Locate enemies
- **WHEN** an enemy is outside the screen
- **THEN** the scroll indicator shows a mark where it is on the map

### Requirement: Top bar information
The top bar SHALL show the name of the level, the body's health, the amino acid balance, the current wave out of the total number of waves, a pause button and a speed button. It SHALL NOT show ATP while ATP is not enabled.

#### Scenario: Level name
- **WHEN** a level is playing
- **THEN** the top bar shows the level's name, taken from the level data

#### Scenario: Values stay current
- **WHEN** the body takes damage or amino acids change
- **THEN** the top bar shows the new values immediately

#### Scenario: No ATP yet
- **WHEN** the HUD is shown while ATP is not enabled
- **THEN** no ATP counter appears

### Requirement: Build by tapping a slot
To build a tower, the player SHALL tap an empty slot, which opens a menu listing the towers available in the level with their costs, and then tap the tower to build. A tower the player cannot afford SHALL be shown as unavailable and SHALL NOT be built when tapped. Tapping outside the menu SHALL close it without building.

#### Scenario: Build a tower
- **WHEN** the player taps an empty slot and then an affordable tower in the menu
- **THEN** the tower is built on that slot, its cost is charged and the menu closes

#### Scenario: Not enough amino acids
- **WHEN** the player taps a tower whose cost is greater than the balance
- **THEN** no tower is built, the balance is unchanged and the player gets feedback that amino acids are insufficient

#### Scenario: Cancel
- **WHEN** the menu is open and the player taps outside it
- **THEN** the menu closes and nothing is built

### Requirement: Tower card and selling
Tapping a built tower SHALL show a card with the tower's name, the damage it deals, its ability, and below them a sell button that shows the amino acids it will return. The damage SHALL be shown per second with its damage type, or as none for towers that do not deal damage. Confirming the sell button SHALL remove the tower and add the refund to the balance. Tapping elsewhere SHALL close the card.

#### Scenario: Tower card
- **WHEN** the player taps a Macrophage
- **THEN** a card shows "MACROPHAGE", "DAMAGE: 12/S (PHYSICAL)", its ability text, and a sell button below

#### Scenario: Tower without damage
- **WHEN** the player taps a Mucus Cell
- **THEN** the damage line says that it deals no damage, and the ability explains the mucus

#### Scenario: Sell
- **WHEN** the player taps the sell button of a tower that cost 50 amino acids
- **THEN** the tower is removed and 30 amino acids are added to the balance

#### Scenario: Close the card
- **WHEN** the card is open and the player taps outside it
- **THEN** the card closes and the tower stays

### Requirement: Next wave information and call button
The HUD SHALL show a countdown to the next wave, a preview of the enemies in it (icons marked as virus or bacterium), and the button to call the next wave early.

#### Scenario: Countdown
- **WHEN** the next wave is 20 s away
- **THEN** the HUD shows the countdown and the icons of the enemies that will come

#### Scenario: Call the wave
- **WHEN** the player taps the call button
- **THEN** the next wave starts immediately as defined by the wave system

### Requirement: Enemy info card
Tapping an enemy SHALL show a card with its name, type, current and maximum health, role, and its weaknesses and immunities. The card SHALL close when the player taps elsewhere.

#### Scenario: Open the card
- **WHEN** the player taps an enemy
- **THEN** a card shows its name, health, role, weaknesses and immunities

#### Scenario: Bacterium immune to antiviral
- **WHEN** the card of a bacterium is shown
- **THEN** it lists antiviral damage as an immunity

### Requirement: Pause
The pause button SHALL stop the game and show an overlay with resume and restart options. While paused, building and selling SHALL be disabled.

#### Scenario: Pause and resume
- **WHEN** the player pauses and then resumes
- **THEN** the game continues from the same state

### Requirement: Game speed
The speed button SHALL toggle between 1× and 2× speed. The current speed SHALL be visible on the button. The speed SHALL apply to the whole simulation as defined by the wave system and SHALL reset to 1× when a level starts.

#### Scenario: Toggle speed
- **WHEN** the player taps the speed button while at 1×
- **THEN** the game runs at 2× and the button shows 2×

#### Scenario: Reset on level start
- **WHEN** a level starts after the previous one ended at 2×
- **THEN** the speed is 1×

### Requirement: Result screens
Victory and defeat SHALL each show an overlay with the result and a restart option.

#### Scenario: Defeat overlay
- **WHEN** the body's health reaches zero
- **THEN** a defeat overlay appears with a restart option
