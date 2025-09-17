import Foundation

struct MatchTriplet {
    let coordinates: [Coord]
    let `class`: UnitClass
}

struct MatchResults {
    let verticalTriplets: [MatchTriplet]
    let horizontalTriplets: [MatchTriplet]
}

struct MatchFinder {
    func findMatches(in grid: Grid, for side: Side) -> MatchResults {
        let vertical = findVerticalMatches(in: grid, for: side)
        let horizontal = findHorizontalMatches(in: grid, for: side)
        return MatchResults(verticalTriplets: vertical, horizontalTriplets: horizontal)
    }

    private func findVerticalMatches(in grid: Grid, for side: Side) -> [MatchTriplet] {
        var results: [MatchTriplet] = []
        for x in 0..<Grid.columns {
            var streak: [(Coord, UnitClass)] = []
            for y in 0..<Grid.rows {
                let coord = Coord(x: x, y: y)
                guard case let .unit(unit)? = grid.content(at: coord), unit.side == side else {
                    appendTriplets(from: streak, into: &results)
                    streak.removeAll()
                    continue
                }
                streak.append((coord, unit.class))
            }
            appendTriplets(from: streak, into: &results)
        }
        return results
    }

    private func findHorizontalMatches(in grid: Grid, for side: Side) -> [MatchTriplet] {
        var results: [MatchTriplet] = []
        for y in 0..<Grid.rows {
            var streak: [(Coord, UnitClass)] = []
            for x in 0..<Grid.columns {
                let coord = Coord(x: x, y: y)
                guard case let .unit(unit)? = grid.content(at: coord), unit.side == side else {
                    appendTriplets(from: streak, into: &results)
                    streak.removeAll()
                    continue
                }
                streak.append((coord, unit.class))
            }
            appendTriplets(from: streak, into: &results)
        }
        return results
    }

    private func appendTriplets(from streak: [(Coord, UnitClass)], into results: inout [MatchTriplet]) {
        guard streak.count >= 3 else { return }
        var index = 0
        while index + 2 < streak.count {
            let firstClass = streak[index].1
            if streak[index + 1].1 == firstClass && streak[index + 2].1 == firstClass {
                let coords = [streak[index].0, streak[index + 1].0, streak[index + 2].0]
                results.append(MatchTriplet(coordinates: coords, class: firstClass))
                index += 3
            } else {
                index += 1
            }
        }
    }
}
