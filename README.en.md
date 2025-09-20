# Game3D Framework (Godot 4.4)

The Game3D Framework is a reference architecture built on Godot Engine 4.4. It demonstrates how a maintainable, extensible 3D game project can be organised through clear separation of concerns, reliance on external data assets, and signal-driven coordination between loosely coupled modules.

## Objectives
- Provide a reproducible baseline for character-centric gameplay loops, covering locomotion, combat, damage handling, and revival.
- Illustrate the integration between GDScript modules and structured data assets (JSON/RES), promoting a data-driven production workflow.
- Support teaching, experimentation, and applied research in game development by offering a well-structured codebase that can be adapted with minimal integration overhead.

## Key Directory Layout
- `characters/` – Character scenes, scripts, and demonstrative 3D models.
- `scripts/actors/` – Core actor logic (Actor3D, CharacterData, CharacterModel, PlayerData, MonsterData).
- `scripts/autoloads/` – Autoloaded services such as GameManager, AudioManager, and Types for managing shared state.
- `scripts/inventory/` – Inventory and item mechanics (InventoryData, ItemData, ItemEffect, ItemHelper, LootItem).
- `objects/` – Auxiliary gameplay objects, including item drops and projectiles.
- `resources/` – Data assets for animation libraries (`ArrowLib.res`, `MeleeLib.res`, `ShooterLib.res`), item definitions (`items.json`), and bone mapping (`Mixamo BoneMap.tres`).
- `resources/animations/` – Animation clips packaged as `.res` files (e.g., `idle_arrow.res`, `walk.res`, `run.res`).
- `scenes/`, `sky/` – Environment scenes and sky domes used in the sandbox levels.
- `docs/` – HTML5/WASM export bundle ready for static web hosting.
- `test/` – Technical proof-of-concept scenes or scripts for feature experiments.

## Core Subsystems
- **Actor3D (`scripts/actors/Actor3D.gd`)**: Base class extending `CharacterBody3D`, responsible for physics updates, animation selection, and broadcasting key events such as stat changes or death.
- **CharacterData (`scripts/actors/CharacterData.gd`)**: Resource that stores character statistics, handles regeneration, processes damage, and applies modifiers from equipped items.
- **CharacterModel (`scripts/actors/CharacterModel.gd`)**: Controls animation playback, attaches equipment to skeletal bones, and emits signals for attack windows or animation completions.
- **Player3D / Monster3D (`characters/*.gd`)**: Specialisations of Actor3D that add player input handling, camera control, or opponent behaviours.
- **Inventory System (`scripts/inventory/`)**: Manages item definitions, stack counts, stat adjustments, and helper utilities for loading data from JSON.
- **GameManager (`scripts/autoloads/GameManager.gd`)**: Global coordinator for shared parameters such as gravity, active player reference, baseline item list, and UI notifications.

## Data and Animation Pipeline
- The animation mapping is defined in `resources/melee_animations.json` together with the `.res` clips under `resources/animations/`, covering idle, walk, run, jump, attack, and death states, plus weapon-specific variants.
- Item definitions are consolidated in `resources/items.json`, describing category, affected statistics, and metadata (price, rarity, optional flags).

Example entry from `resources/items.json`:
```json
{
  "id": "sword",
  "name": "Sword",
  "item_type": "WEAPON",
  "effect": { "states_add": { "attack": 6 } },
  "meta": { "price": 25, "rarity": "common" }
}
```

## Usage Workflow
1. Install Godot Engine 4.4 and open the project via `project.godot`.
2. Launch the default scene with F5 (the main scene is preconfigured).
3. Use the demonstration controls: `W/A/S/D` to move, `Shift` to sprint, `Space` to jump, `X` or left mouse to attack, `I` to toggle the inventory, `Esc` to switch mouse modes.
4. Publish the contents of the `docs/` folder to host the web build on a static server.

## Extension Guidelines
- Derive new characters from Actor3D and prepare dedicated CharacterData/CharacterModel resources.
- Extend or adjust animation sets by editing `resources/melee_animations.json` and creating additional `.res` clips under `resources/animations/`.
- Customise UI elements inside `scenes/ui/` and connect the relevant signals to GameManager.
- Implement richer status effects (buffs/debuffs) by extending ItemEffect and the supporting logic within CharacterData.

## Technical Considerations
- Horizontal speed analysis combines the `x` and `z` velocity components to select walking/running animations accurately (`Actor3D.gd:101`).
- Resetting the `action` variable occurs after evaluating footstep audio conditions to avoid missed sound playback (`Actor3D.gd:147-156`).
- Type conversion in `CharacterData.get_stat()` calls `float(v)` to preserve the stored numeric value (`CharacterData.gd:74`).

## Licensing and Credits
The project is distributed under the MIT License (see `LICENSE`). Selected assets draw inspiration from Kay Lousberg (itch.io) and other creators; review each asset’s licence before redistribution.

## Contributors
Wachirawut Thamwiset and collaborators recorded in the version history.
