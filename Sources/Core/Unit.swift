import Foundation

enum Side {
    case player
    case enemy

    var opponent: Side {
        switch self {
        case .player: return .enemy
        case .enemy: return .player
        }
    }
}

enum UnitClass: CaseIterable {
    case warrior
    case archer
    case knight
}

struct Unit {
    let side: Side
    let `class`: UnitClass
}

struct Wall {
    let side: Side
    let `class`: UnitClass
    var hitPoints: Int
}

struct Attacker {
    let side: Side
    let `class`: UnitClass
    var countdown: Int
    let damage: Int
}

enum CellContent {
    case empty
    case unit(Unit)
    case wall(Wall)
    case attacker(Attacker)
}
