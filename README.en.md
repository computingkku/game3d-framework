# Game3D Framework (Godot 4.4)

The Game3D Framework is a reference architecture built on Godot Engine 4.4. It demonstrates how a maintainable and extensible 3D project can be organised through clear separation of concerns, reliance on external data assets, and signal-driven coordination between loosely coupled modules.

## Objectives
- Provide a reusable baseline for character-centric gameplay loops covering locomotion, combat, damage handling, and revival
- Illustrate the integration between GDScript modules and structured data assets (JSON/RES) to promote a data-driven production workflow
- Support teaching, experimentation, and applied research through a codebase that can be adapted with minimal integration overhead

## Key Directory Layout
- `characters/` – Character scenes and scripts, together with demonstrative 3D models
- `scripts/actors/` – Core actor logic (Actor3D, CharacterData, CharacterModel, PlayerData, MonsterData)
- `scripts/autoloads/` – Autoloaded services managing shared state (GameManager, AudioManager, Types)
- `scripts/inventory/` – Inventory and item mechanics (InventoryData, ItemData, ItemEffect, ItemHelper, LootItem)
- `objects/` – Auxiliary gameplay objects, including item drops and projectiles
- `resources/` – Data assets for animation libraries (`ArrowLib.res`, `MeleeLib.res`, `ShooterLib.res`), item definitions (`items.json`), and bone mapping (`Mixamo BoneMap.tres`)
- `resources/animations/` – Animation clips packaged as `.res` files (e.g., `idle_arrow.res`, `walk.res`, `run.res`)
- `scenes/`, `sky/` – Environment scenes and sky domes for sandbox levels
- `docs/` – HTML5/WASM export bundle ready for static web hosting
- `test/` – Technical proof-of-concept scenes and scripts

## Core Subsystems
- **Actor3D (`scripts/actors/Actor3D.gd`)**: Base class extending `CharacterBody3D`; handles physics, animation selection, and key gameplay signals (hp/mp/stamina changes, death, revival)
- **CharacterData (`scripts/actors/CharacterData.gd`)**: Resource storing statistics, regeneration, damage processing, and cumulative equipment effects
- **CharacterModel (`scripts/actors/CharacterModel.gd`)**: Plays animations, attaches equipment to bones, and emits signals for attack windows
- **Player3D / Monster3D (`characters/*.gd`)**: Specialisations that enrich Actor3D with player input handling, camera control, or enemy behaviour patterns
- **Inventory System (`scripts/inventory/`)**: Manages item definitions, stacking, stat adjustments, and helper utilities for JSON-driven content
- **GameManager (`scripts/autoloads/GameManager.gd`)**: Global coordinator for gravity, active player references, baseline item list, and UI notifications

## Data and Animation Pipeline
- Animation mapping lives in `resources/melee_animations.json` alongside the `.res` clips under `resources/animations/`, covering idle, walk, run, jump, attack, death, and weapon-specific variants
- Item definitions are consolidated in `resources/items.json`, describing category, affected statistics, and metadata (price, rarity, optional flags)

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
1. Install Godot Engine 4.4 and open the project via `project.godot`
2. Launch the default scene with F5 (already configured)
3. Use the demo controls: `W/A/S/D` to move, `Shift` to sprint, `Space` to jump, `X` or left mouse to attack, `I` to toggle the inventory, `Esc` to switch mouse modes
4. Publish the `docs/` folder when deploying the HTML5/WebAssembly build to a static host

## Extension Guidelines
### Adding a New Character
1. **Establish the baseline**: Create a new character scene that inherits from `Actor3D` (duplicating `characters/Actor3d.tscn` is a convenient starting point) and configure physics, animation, and signal parameters
2. **Choose the appropriate subclass**:
   - `Actor3D` for generic scripted actors or enemies
   - `Player3D` for controllable characters, providing input, camera control, and movement assists (e.g., coyote time)
   - `Monster3D` for AI-driven opponents with built-in drop logic
3. **Prepare CharacterData**: Author a new `CharacterData` resource (or `PlayerData`/`MonsterData`) specifying base statistics, equipment presets, and bind it through the `_data` property
4. **Wire up models and animations**: Assign `model_scene` or attach a model node under `Actor3D`, configure `CharacterModel` to recognise animation clips and weapon attachment points, and adjust `Mixamo BoneMap.tres` or create a new bone map when using different skeletons
5. **Integrate with the game loop**: Place the character in a test or main scene, update `GameManager.player` if required, and verify that UI/Inventory signals respond correctly

### Extending the Weapon System (Handgun Example)
1. **Review existing weapons**: Inspect the sword (`sword`) and bow (`bow`) entries in `resources/items.json` to understand how melee and ranged weapons are described
2. **Add a new item definition**: Insert a JSON object such as
   ```json
   {
     "id": "handgun",
     "name": "Handgun",
     "item_type": "WEAPON",
     "effect": { "states_add": { "attack": 18 } },
     "meta": { "price": 150, "rarity": "rare" },
     "projectile": "res://objects/bullet/Bullet.tscn"
   }
   ```
3. **Provide models and projectiles**: Create the firearm and projectile scenes under `objects/` (e.g., `objects/bullet/Bullet.tscn`), and update `CharacterModel` so that the appropriate hand node (`right_hand` or `left_hand`) anchors the weapon
4. **Extend combat logic**: Enhance `CharacterModel.gd` or implement complementary scripts in `scripts/weapons/` to spawn projectiles on `attack`/`weapon_hit`, manage projectile velocity, cooldown, and audio cues
5. **Expand the animation set**: Add or adjust a `shoot` action within `resources/melee_animations.json` and supply matching `.res` clips in `resources/animations/`
6. **Test and tune**: Insert the weapon into the inventory via `InventoryData.add_item_by_id`, verify damage output, animation transitions, and balance relative to existing weapons

## Multiplayer Design Considerations
### Networking Architecture
- Split GameManager into two roles: a **Server Authoritative Manager** that executes physics, combat resolution, and actor lifecycle, and a **Client Presentation Manager** that renders UI/effects while relaying filtered input to the server
- Employ Godot’s Multiplayer API (`MultiplayerAPI`, `SceneMultiplayer`, or custom transports) so the server owns node creation/destruction for `Actor3D`, `Player3D`, and `Monster3D`, broadcasting changes via RPC/RSET

### Character and Data Model
- Adapt `Actor3D`, `Player3D`, and `Monster3D` to a **state-replication** model: keep physics on the server, publish velocity/animation/item-impact snapshots to clients with rate limiting and interpolation helpers
- Maintain `CharacterData` as a **server authority copy** (full read/write) alongside a **client shadow copy** (read-only). Define serialization for key stats (hp/mp/stamina, buffs/debuffs) to avoid desynchronisation

### Weapons and Combat Flow
- Route every weapon command (including firearms) through the server, letting the server perform hit detection and damage calculation before broadcasting authoritative results to affected peers
- When spawning projectiles (e.g., `objects/bullet/Bullet.tscn`), instantiate them on the server and assign network authority so collisions are resolved consistently

### UI and Inventory Synchronisation
- Dispatch critical events (item gain/loss, skill changes) from the server via signals, then replicate them to clients as RPC calls that update read-only `InventoryData` mirrors and trigger UI refreshes
- Extend `GameManager.notify` with network-aware queues and compact event codes so status messages remain lightweight across the wire

### Security and Testing
- Restrict client RPCs to validated input commands, employ server reconciliation against late packets, and reject out-of-band state mutations
- Build simulation tests that inject latency/jitter on the server to verify that client/server states converge within acceptable thresholds
## Technical Considerations
- Horizontal speed analysis combines the `x` and `z` velocity components to select walking/running animations accurately (`Actor3D.gd:101`)
- Resetting `action` occurs after evaluating footstep audio conditions to avoid missed sound playback (`Actor3D.gd:147-156`)
- Type conversion in `CharacterData.get_stat()` relies on `float(v)` to preserve stored numeric values (`CharacterData.gd:74`)

## Licensing and Credits
Distributed under the MIT License (see `LICENSE`). Selected assets draw inspiration from Kay Lousberg (itch.io) and other creators; review each asset licence before redistribution

## Contributors
Wachirawut Thamviset and collaborators recorded in the version history

