import Foundation

struct AIMove {
    enum Action {
        case swap(Coord, Coord)
        case spawn([(Coord, UnitClass)])
        case endTurn
    }
    let actions: [Action]
}

final class AISystem {
    private var rng: RNG

    init(rng: RNG) {
        self.rng = rng
    }

    func decideTurn(for grid: Grid, balance: BalanceProvider) -> AIMove {
        var actions: [AIMove.Action] = []
        let spawnPlan = determineSpawns(for: grid, balance: balance)
        if !spawnPlan.isEmpty {
            actions.append(.spawn(spawnPlan))
        }
        actions.append(.endTurn)
        return AIMove(actions: actions)
    }

    private func determineSpawns(for grid: Grid, balance: BalanceProvider) -> [(Coord, UnitClass)] {
        let maxSpawns = balance.enemySpawnPerTurn
        guard maxSpawns > 0 else { return [] }

        var assignments: [(Coord, UnitClass)] = []
        var reserved = Set<Coord>()

        // Priority: complete existing vertical stacks of two matching units.
        let completions = findVerticalCompletionOpportunities(in: grid)
        for completion in completions where assignments.count < maxSpawns {
            if !reserved.contains(completion.coord) {
                assignments.append((completion.coord, completion.classType))
                reserved.insert(completion.coord)
            }
        }

        // Fill remaining spawns with random units at back row positions.
        if assignments.count < maxSpawns {
            let backRow = Grid.rows - 1
            var emptyBackRow = [Coord]()
            for x in 0..<Grid.columns {
                let coord = Coord(x: x, y: backRow)
                if case .empty? = grid.content(at: coord) {
                    if !reserved.contains(coord) {
                        emptyBackRow.append(coord)
                    }
                }
            }

            while assignments.count < maxSpawns, !emptyBackRow.isEmpty {
                let index = rng.nextInt(upperBound: emptyBackRow.count)
                let coord = emptyBackRow.remove(at: index)
                reserved.insert(coord)
                let unitClass = randomUnitClass()
                assignments.append((coord, unitClass))
            }
        }

        return assignments
    }

    private func findVerticalCompletionOpportunities(in grid: Grid) -> [(coord: Coord, classType: UnitClass)] {
        var results: [(coord: Coord, classType: UnitClass)] = []
        for x in 0..<Grid.columns {
            for startY in 0..<(Grid.rows - 2) {
                let segment = (0..<3).map { Coord(x: x, y: startY + $0) }
                var units: [(Coord, UnitClass)] = []
                var emptyCoord: Coord?
                for coord in segment {
                    guard let content = grid.content(at: coord) else { continue }
                    switch content {
                    case .unit(let unit) where unit.side == .enemy:
                        units.append((coord, unit.class))
                    case .empty:
                        emptyCoord = coord
                    default:
                        emptyCoord = nil
                        units.removeAll()
                        break
                    }
                }

                if let empty = emptyCoord, units.count == 2,
                   units.first?.1 == units.last?.1 {
                    results.append((coord: empty, classType: units.first!.1))
                }
            }
        }
        return results
    }

    private func randomUnitClass() -> UnitClass {
        let index = rng.nextInt(upperBound: UnitClass.allCases.count)
        return UnitClass.allCases[index]
    }
}
