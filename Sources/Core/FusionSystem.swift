import Foundation

struct FusionOutcome {
    var attackers: [Coord: Attacker] = [:]
    var walls: [Coord: Wall] = [:]
    var clearedCoords: Set<Coord> = []
}

struct FusionSystem {
    func resolve(matches: MatchResults, in grid: inout Grid, side: Side, balance: BalanceProvider) -> FusionOutcome {
        var outcome = FusionOutcome()

        for triplet in matches.verticalTriplets {
            let classType = triplet.class
            let countdown = balance.baseCountdown(for: classType)
            let damage = balance.baseDamage(for: classType)
            let attacker = Attacker(side: side, class: classType, countdown: countdown, damage: damage)
            let middle = triplet.coordinates[1]

            for coord in triplet.coordinates {
                grid.setContent(.empty, at: coord)
                outcome.clearedCoords.insert(coord)
            }

            grid.setContent(.attacker(attacker), at: middle)
            outcome.attackers[middle] = attacker
        }

        for triplet in matches.horizontalTriplets {
            let classType = triplet.class
            let hitPoints = balance.wallHitPoints(for: classType)
            let wall = Wall(side: side, class: classType, hitPoints: hitPoints)

            for coord in triplet.coordinates {
                grid.setContent(.wall(wall), at: coord)
                outcome.walls[coord] = wall
            }
        }

        return outcome
    }
}

protocol BalanceProvider {
    var gateHitPoints: Int { get }
    var playerMovesPerTurn: Int { get }
    var enemySpawnPerTurn: Int { get }
    func baseDamage(for unitClass: UnitClass) -> Int
    func baseCountdown(for unitClass: UnitClass) -> Int
    func wallHitPoints(for unitClass: UnitClass) -> Int
}
