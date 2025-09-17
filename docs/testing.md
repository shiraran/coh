# Testing Strategy – Chainblade Tactics

## Automated Tests
- **Unit Tests (Swift/XCTest)**
  - `Tests/MatchFinderTests.swift`: verifies vertical/horizontal detection.
  - `Tests/FusionSystemTests.swift`: checks attackers/walls spawn with correct stats.
  - `Tests/TurnSystemTests.swift`: ensures turn phases advance correctly and no premade matches are generated at battle start.
  - `Tests/CombatSystemTests.swift`: covers attacker countdown resolution, wall collisions, gate damage, and friendly blocking behavior.
  - `Tests/AISystemTests.swift`: confirms AI completes vertical triplets when possible.
  - `Tests/BoardInitializerTests.swift`: validates seeded grid generation has required empties and no initial matches.

### Running Tests
1. Open the Xcode project configured per `docs/ios_setup.md`.
2. Select the `ChainbladeTactics` scheme.
3. Press `⌘U` to execute the unit test bundle.
4. For command-line runs, you have two options:
   - Xcode: `xcodebuild test -scheme ChainbladeTactics -destination "platform=iOS Simulator,name=iPhone 14"`
   - SwiftPM (headless):
     ```bash
     pushd ChainbladeTactics
     swift test
     popd
     ```
   The Swift Package references `Sources/` (excluding `App/`) and reuses the same XCTest targets.

## Manual Playtests
- **Daily Smoke Test:**
  - Launch the game on iPhone 14 simulator.
  - Verify seed label shows on HUD.
  - Play one battle: confirm 3-move limit, attacker countdowns, spawn/charge animations, SFX playback, and gate HP updates.
- **Device Test (weekly):**
  - Install on actual hardware (e.g., iPhone 13, iPad mini) to confirm performance and touch responsiveness.

## Regression Checklist (pre-release)
- No pre-made matches at spawn for both player and enemy boards.
- Attacker countdown reduces each turn and handles friendly blockers without duplicating movers.
- Enemy AI completes available triplets; spawn animation triggers.
- Gate HP decreases on successful charges and game transitions to Game Over when ≤0.
- Audio loops and SFX fire (once integrated).

## Future Enhancements
- Snapshot tests for board layouts given specific RNG seeds.
- Integration tests that simulate turn sequences using deterministic RNG to verify gate outcomes.
- UI Test suite to ensure HUD updates, End Turn button, and seed display respond correctly.
