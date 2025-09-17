import Foundation

struct Coord: Hashable {
    let x: Int
    let y: Int
}

struct Grid {
    static let columns = 8
    static let rows = 6

    private(set) var cells: [[CellContent]]

    init(fillWith: CellContent = .empty) {
        let columnTemplate = Array(repeating: fillWith, count: Grid.rows)
        cells = Array(repeating: columnTemplate, count: Grid.columns)
    }

    func inBounds(_ coord: Coord) -> Bool {
        coord.x >= 0 && coord.x < Grid.columns && coord.y >= 0 && coord.y < Grid.rows
    }

    func content(at coord: Coord) -> CellContent? {
        guard inBounds(coord) else { return nil }
        return cells[coord.x][coord.y]
    }

    mutating func setContent(_ content: CellContent, at coord: Coord) {
        guard inBounds(coord) else { return }
        cells[coord.x][coord.y] = content
    }

    mutating func swap(_ a: Coord, _ b: Coord) -> Bool {
        guard inBounds(a), inBounds(b) else { return false }
        guard a != b else { return false }
        let temp = cells[a.x][a.y]
        cells[a.x][a.y] = cells[b.x][b.y]
        cells[b.x][b.y] = temp
        return true
    }

    func column(_ x: Int) -> [CellContent] {
        guard x >= 0 && x < Grid.columns else { return [] }
        return cells[x]
    }

    func row(_ y: Int) -> [CellContent] {
        guard y >= 0 && y < Grid.rows else { return [] }
        return cells.map { $0[y] }
    }

    mutating func collapseAll(toward side: Side) {
        for x in 0..<Grid.columns {
            collapseColumn(x, toward: side)
        }
    }

    mutating func collapseColumn(_ x: Int, toward side: Side) {
        guard x >= 0 && x < Grid.columns else { return }
        switch side {
        case .player:
            var stack: [CellContent] = []
            for y in 0..<Grid.rows {
                let content = cells[x][y]
                if case .empty = content { continue }
                stack.append(content)
            }
            for y in 0..<Grid.rows {
                if y < stack.count {
                    cells[x][y] = stack[y]
                } else {
                    cells[x][y] = .empty
                }
            }
        case .enemy:
            var stack: [CellContent] = []
            for y in (0..<Grid.rows).reversed() {
                let content = cells[x][y]
                if case .empty = content { continue }
                stack.append(content)
            }
            var index = 0
            for y in (0..<Grid.rows).reversed() {
                if index < stack.count {
                    cells[x][y] = stack[index]
                    index += 1
                } else {
                    cells[x][y] = .empty
                }
            }
        }
    }

    func frontCoord(for side: Side, column x: Int) -> Coord? {
        guard x >= 0 && x < Grid.columns else { return nil }
        switch side {
        case .player:
            for y in 0..<Grid.rows {
                let coord = Coord(x: x, y: y)
                guard let content = content(at: coord), !content.isEmpty else { continue }
                return coord
            }
        case .enemy:
            for y in (0..<Grid.rows).reversed() {
                let coord = Coord(x: x, y: y)
                guard let content = content(at: coord), !content.isEmpty else { continue }
                return coord
            }
        }
        return nil
    }

    func nextInsertionCoord(for side: Side, column x: Int) -> Coord? {
        guard x >= 0 && x < Grid.columns else { return nil }
        switch side {
        case .player:
            for y in 0..<Grid.rows {
                let coord = Coord(x: x, y: y)
                guard let content = content(at: coord) else { return coord }
                if content.isEmpty { return coord }
            }
        case .enemy:
            for y in (0..<Grid.rows).reversed() {
                let coord = Coord(x: x, y: y)
                guard let content = content(at: coord) else { return coord }
                if content.isEmpty { return coord }
            }
        }
        return nil
    }

    func isFrontCell(_ coord: Coord, for side: Side) -> Bool {
        guard let front = frontCoord(for: side, column: coord.x) else { return false }
        return front == coord
    }
}

private extension CellContent {
    var isEmpty: Bool {
        if case .empty = self { return true }
        return false
    }
}
