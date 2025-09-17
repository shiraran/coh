# Phase-by-Phase Implementation Plan

## Phase M1 – Project Bootstrap
- Create new SpriteKit-based iOS project (iOS 16+, portrait) with `TitleScene` and `GameScene` wiring.
- Integrate asset catalogs, ensure `SKView` uses nearest-neighbor filtering.
- Set up `Sources` module structure (Core, Scenes, Rendering, Audio, Data) and shared `Balance` constants.
- Acceptance: App runs on simulator, displays TitleScene, tapping transitions to GameScene with empty grids rendered.

## Phase M2 – Player Grid Input Loop
- Implement grid population, input handling (tap/drag/lift-drop) within player 8×6 board.
- Track move counter, update HUD, disallow illegal moves.
- Acceptance: Player can move units within their grid, move counter decrements, End Turn button disabled/enabled appropriately.

## Phase M3 – Matching & Fusion Systems
- Finalize `MatchFinder` vertical/horizontal detection, ensure no duplicate matches.
- Implement `FusionSystem` to spawn attackers and walls per rules; integrate post-move auto-resolution.
- Acceptance: Forming vertical triplet generates attacker with correct countdown, horizontal triplet generates walls with proper HP, no spontaneous matches at start.

## Phase M4 – Turn & Combat Resolution
- Implement `CombatSystem.advance` to handle attacker movement, collisions with walls/units, gate damage.
- Hook countdown decrement and advance flow in `TurnSystem.endPlayerTurn` and enemy phase resolution.
- Acceptance: Attackers march down lanes after countdown, collide per spec, gate HP updates correctly, victory/defeat triggers Game Over phase.

## Phase M5 – Enemy AI & Spawn Rules
- Build deterministic `AISystem` with priority: complete vertical triplets, else spawn units in back rows.
- Integrate enemy spawn count per turn; prevent overlapping spawns, ensure RNG seeded for tests.
- Acceptance: Enemy turn populates grid respecting rules, AI creates attackers when possible, behaves consistently with fixed seed.

## Phase M6 – Audio, UI Polish, Win/Lose Flow
- Add HUD updates (gate bars, move counter), simple animations and sound hooks for fusions, hits, gate damage.
- Implement Game Over screen, restart flow, pause/menu basics.
- Acceptance: Audio loops play, SFX trigger on actions, UI communicates state, Game Over transitions to TitleScene.

## Phase M7 – Balance, QA, Device Build
- Validate tuning (gate HP, damage) via simulator playtests; adjust Balance as needed.
- Run unit tests, add additional coverage for edge cases.
- Prepare TestFlight/dev build for iPhone (primary) and confirm iPad layout adapts.
- Acceptance: Test suite passes, manual playtest stable, app archive created without warnings.
