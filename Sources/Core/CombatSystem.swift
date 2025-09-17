import Foundation

final class CombatSystem {
    func resolveCountdowns(on grid: inout Grid, opponentGrid: inout Grid, gates: inout GateState, side: Side) {
        for x in 0..<Grid.columns {
            for y in 0..<Grid.rows {
                let coord = Coord(x: x, y: y)
                guard case var .attacker(attacker)? = grid.content(at: coord), attacker.side == side else {
                    continue
                }

                attacker.countdown -= 1
                if attacker.countdown <= 0 {
                    grid.setContent(.empty, at: coord)
                    advance(attacker: attacker,
                            start: coord,
                            on: &grid,
                            opponentGrid: &opponentGrid,
                            gates: &gates,
                            side: side)
                } else {
                    grid.setContent(.attacker(attacker), at: coord)
                }
            }
        }

        grid.collapseAll(toward: side)
        opponentGrid.collapseAll(toward: side.opponent)
    }

    private func advance(attacker: Attacker,
                         start: Coord,
                         on grid: inout Grid,
                         opponentGrid: inout Grid,
                         gates: inout GateState,
                         side: Side) {
        let travelDirection = direction(for: side)

        // Check for friendly blockers; attacker stays put if obstructed.
        var y = start.y + travelDirection
        while grid.inBounds(Coord(x: start.x, y: y)) {
            let coord = Coord(x: start.x, y: y)
            guard let content = grid.content(at: coord) else { break }
            switch content {
            case .empty:
                y += travelDirection
                continue
            default:
                var delayedAttacker = attacker
                delayedAttacker.countdown = max(1, attacker.countdown)
                grid.setContent(.attacker(delayedAttacker), at: start)
                return
            }
        }

        // Traverse opponent grid for collisions.
        var opponentY = entryRowForOpponent(side: side)
        while opponentGrid.inBounds(Coord(x: start.x, y: opponentY)) {
            let coord = Coord(x: start.x, y: opponentY)
            guard let content = opponentGrid.content(at: coord) else { break }
            switch content {
            case .empty:
                opponentY += travelDirection
            case .wall(var wall):
                wall.hitPoints -= attacker.damage
                if wall.hitPoints <= 0 {
                    opponentGrid.setContent(.empty, at: coord)
                } else {
                    opponentGrid.setContent(.wall(wall), at: coord)
                }
                return
            case .unit:
                opponentGrid.setContent(.empty, at: coord)
                return
            case .attacker:
                opponentGrid.setContent(.empty, at: coord)
                return
            }
        }

        // Reaching this point means the attacker struck the enemy gate.
        switch side {
        case .player:
            gates.enemyHP -= attacker.damage
        case .enemy:
            gates.playerHP -= attacker.damage
        }
    }

    private func direction(for side: Side) -> Int {
        side == .player ? 1 : -1
    }

    private func entryRowForOpponent(side: Side) -> Int {
        side == .player ? 0 : Grid.rows - 1
    }
}
