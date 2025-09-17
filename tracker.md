# Development Tracker – Chainblade Tactics

| Milestone | Description | Owner | Status | Notes |
|-----------|-------------|-------|--------|-------|
| Planning | High-level overview, plan, scaffolding | Codex | ✅ Completed | Plan, scaffolding, docs drafted (2025-09-18) |
| M1 | SpriteKit bootstrap, scene wiring, grid shell | TBD | 🚧 In Progress | App delegate, view controller, and SwiftPM manifest added; waiting on Xcode project wiring |
| M2 | Player input loop, HUD integration | TBD | ⏳ Pending | Depends on M1 completion |
| M3 | MatchFinder + Fusion integration | TBD | 🚧 In Progress | Core fusion logic in place; seeded board generation prevents premade matches |
| M4 | Turn + Combat resolution | TBD | 🚧 In Progress | Countdown advance + lane traversal logic implemented; combat tests added |
| M5 | Enemy AI + spawning | TBD | 🚧 In Progress | Spawn heuristic wired into turn flow; enemy board renders with spawn FX + audio |
| M6 | Audio + UI polish + win/lose flow | TBD | ⏳ Pending | Requires prior milestones |
| M7 | Balance pass, QA, build | TBD | ⏳ Pending | Final stretch after gameplay solid |

## Recent Activity
- 2025-09-18: Authored implementation plan, created core Swift scaffolding, established docs for idea/gameplay, initial unit tests skeleton.
- 2025-09-18: Implemented lane traversal in `CombatSystem`, added basic enemy spawn/completion heuristics, updated tracker/docs.
- 2025-09-18: Added combat and AI unit tests, integrated enemy turn execution within `TurnSystem`/`GameScene`.
- 2025-09-18: Introduced deterministic board initialization, seed display, and enemy spawn animations in `GameScene`.
- 2025-09-18: Added UIKit entry point (`AppDelegate`, `GameViewController`), documented Xcode wiring steps, and created SwiftPM package for CLI tests.
- 2025-09-18: Implemented charge lane FX, gate-hit feedback, SFX hooks, pause/restart seed entry overlay, and column-stack movement (COH-style) with new board visuals.

## Next Actions
1. Stand up Xcode SpriteKit project referencing `Sources/` tree.
2. Hook background music & contextual SFX volume controls into AudioManager.
3. Flesh out Game Over / victory scenes and pause overlay polish.

