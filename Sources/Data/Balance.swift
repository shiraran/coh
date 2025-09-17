import Foundation

struct Balance: BalanceProvider {
    static let shared = Balance()

    let gateHitPoints = 20
    let playerMovesPerTurn = 3
    let enemySpawnPerTurn = 2

    func baseDamage(for unitClass: UnitClass) -> Int {
        switch unitClass {
        case .warrior:
            return 2
        case .archer:
            return 1
        case .knight:
            return 3
        }
    }

    func baseCountdown(for unitClass: UnitClass) -> Int {
        switch unitClass {
        case .warrior:
            return 2
        case .archer:
            return 1
        case .knight:
            return 3
        }
    }

    func wallHitPoints(for unitClass: UnitClass) -> Int {
        switch unitClass {
        case .warrior:
            return 2
        case .archer:
            return 1
        case .knight:
            return 3
        }
    }
}
