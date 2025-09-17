import Foundation

struct BoardInitializer {
    private var rng: RNG
    private let playerEmptyTarget = 6

    init(seed: UInt64) {
        rng = RNG(seed: seed)
    }

    mutating func makeInitialGrid(for side: Side) -> Grid {
        var grid = Grid()
        for x in 0..<Grid.columns {
            for y in 0..<Grid.rows {
                if shouldLeaveEmpty(side: side, y: y) {
                    continue
                }
                placeUnitIfPossible(side: side, at: Coord(x: x, y: y), in: &grid)
            }
        }

        if side == .player {
            carveAdditionalEmpties(into: &grid, target: playerEmptyTarget, side: side)
        }

        grid.collapseAll(toward: side)
        return grid
    }

    private func shouldLeaveEmpty(side: Side, y: Int) -> Bool {
        switch side {
        case .player:
            return false
        case .enemy:
            return y == Grid.rows - 1
        }
    }

    private mutating func placeUnitIfPossible(side: Side, at coord: Coord, in grid: inout Grid) {
        var options = Array(UnitClass.allCases)
        while !options.isEmpty {
            let index = rng.nextInt(upperBound: options.count)
            let candidate = options.remove(at: index)
            if !createsMatch(in: grid, at: coord, unitClass: candidate, side: side) {
                let unit = Unit(side: side, class: candidate)
                grid.setContent(.unit(unit), at: coord)
                return
            }
        }
        // Fallback: leave empty if no safe candidate (rare on 3-unit roster)
    }

    private func createsMatch(in grid: Grid, at coord: Coord, unitClass candidate: UnitClass, side: Side) -> Bool {
        if formsHorizontalMatch(in: grid, at: coord, unitClass: candidate, side: side) {
            return true
        }
        if formsVerticalMatch(in: grid, at: coord, unitClass: candidate, side: side) {
            return true
        }
        return false
    }

    private func formsHorizontalMatch(in grid: Grid, at coord: Coord, unitClass candidate: UnitClass, side: Side) -> Bool {
        guard coord.x >= 2 else { return false }
        let left1 = Coord(x: coord.x - 1, y: coord.y)
        let left2 = Coord(x: coord.x - 2, y: coord.y)
        guard case let .unit(unit1)? = grid.content(at: left1), unit1.side == side else { return false }
        guard case let .unit(unit2)? = grid.content(at: left2), unit2.side == side else { return false }
        return unit1.class == candidate && unit2.class == candidate
    }

    private func formsVerticalMatch(in grid: Grid, at coord: Coord, unitClass candidate: UnitClass, side: Side) -> Bool {
        guard coord.y >= 2 else { return false }
        let below1 = Coord(x: coord.x, y: coord.y - 1)
        let below2 = Coord(x: coord.x, y: coord.y - 2)
        guard case let .unit(unit1)? = grid.content(at: below1), unit1.side == side else { return false }
        guard case let .unit(unit2)? = grid.content(at: below2), unit2.side == side else { return false }
        return unit1.class == candidate && unit2.class == candidate
    }

    private mutating func carveAdditionalEmpties(into grid: inout Grid, target: Int, side: Side) {
        var currentEmpty = countPlayableEmpties(in: grid)
        while currentEmpty < target {
            let coord = Coord(x: rng.nextInt(upperBound: Grid.columns), y: rng.nextInt(upperBound: Grid.rows))
            if shouldLeaveEmpty(side: side, y: coord.y) { continue }
            guard case .unit? = grid.content(at: coord) else { continue }
            grid.setContent(.empty, at: coord)
            currentEmpty += 1
        }
        grid.collapseAll(toward: side)
    }

    private func countPlayableEmpties(in grid: Grid) -> Int {
        var total = 0
        for x in 0..<Grid.columns {
            for y in 0..<Grid.rows {
                let coord = Coord(x: x, y: y)
                if case .empty? = grid.content(at: coord) {
                    total += 1
                }
            }
        }
        return total
    }
}
