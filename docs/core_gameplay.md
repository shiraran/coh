# Core Gameplay Mechanics (v1)

## Battlefield Layout
- Mirrored 8 columns × 6 rows boards separated by a neutral gap.
- Each side has a Gate with 20 HP; destroying the opposing gate wins the match.
- Player units occupy the bottom board, enemy units the top; no diagonal movement.

## Turn Structure
1. **Player Input Phase**
   - Up to 3 lift-and-drop moves per turn; only empty destinations allowed.
   - Goal: arrange vertical triplets for attackers, horizontal triplets for walls.
2. **Player Resolve Phase**
   - Fusions resolve (attackers + walls) before countdown ticks.
   - All player attackers reduce countdown by 1; when countdown hits 0 they advance.
3. **Enemy Input Phase**
   - AI spawns/moves following simple heuristics to create matches.
4. **Enemy Resolve Phase**
   - Enemy fusions resolve, countdowns tick, attackers advance.

## Match & Fusion Rules
- **Vertical Match (3 same-class units)** → replaces middle cell with Attacker:
  - Warrior: countdown 2, damage 2.
  - Archer: countdown 1, damage 1.
  - Knight: countdown 3, damage 3.
- **Horizontal Match (3 same-class units)** → all three cells become Walls with HP by class (2/1/3).
- Optional future rule: 2×2 same-class block → Large Attacker (post v1).

## Attacker Advancement
- Attackers travel straight up/down their column when countdown reaches 0.
- Collisions resolve in order:
  1. Opposing walls (subtract wall HP, attacker removed if damage ≥ remaining HP).
  2. Opposing units/attackers (mutual destruction for v1).
  3. Empty cells (attacker keeps moving until gate).
- On reaching gate, attacker deals its damage and despawns.

## Spawn Rules
- Initial fill: semi-random units with validation to avoid pre-made matches.
- Enemy turn: spawns `Balance.enemySpawnPerTurn`  units in randomly selected empty cells of back rows.

## Failure & Victory
- Gate HP ≤ 0 → immediate outcome; no draw state.
- Player defeat triggers Game Over scene with restart option.
