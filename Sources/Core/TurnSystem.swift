import Foundation

enum Phase {
    case playerInput
    case playerResolve
    case enemyInput
    case enemyResolve
    case gameOver
}

struct GateState {
    var playerHP: Int
    var enemyHP: Int
}

struct TurnContext {
    var grid: Grid
    var enemyGrid: Grid
    var gates: GateState
    var phase: Phase
    var playerMovesRemaining: Int
}

final class TurnSystem {
    private let combatSystem: CombatSystem
    private var aiSystem: AISystem
    private let balance: BalanceProvider
    private var boardInitializer: BoardInitializer

    init(combatSystem: CombatSystem,
         balance: BalanceProvider,
         aiSystem: AISystem = AISystem(rng: RNG(seed: 0)),
         boardInitializer: BoardInitializer = BoardInitializer(seed: 0)) {
        self.combatSystem = combatSystem
        self.aiSystem = aiSystem
        self.balance = balance
        self.boardInitializer = boardInitializer
    }

    func startBattle() -> TurnContext {
        let playerGrid = boardInitializer.makeInitialGrid(for: .player)
        let enemyGrid = boardInitializer.makeInitialGrid(for: .enemy)
        let gates = GateState(playerHP: balance.gateHitPoints, enemyHP: balance.gateHitPoints)
        let moves = balance.playerMovesPerTurn
        return TurnContext(grid: playerGrid,
                           enemyGrid: enemyGrid,
                           gates: gates,
                           phase: .playerInput,
                           playerMovesRemaining: moves)
    }

    func endPlayerTurn(context: inout TurnContext) {
        guard context.phase == .playerInput else { return }
        context.phase = .playerResolve
        resolveCountdowns(for: .player, context: &context)
        guard context.phase != .gameOver else { return }
        context.phase = .enemyInput
        context.playerMovesRemaining = balance.playerMovesPerTurn
    }

    private func resolveCountdowns(for side: Side, context: inout TurnContext) {
        switch side {
        case .player:
            combatSystem.resolveCountdowns(on: &context.grid, opponentGrid: &context.enemyGrid, gates: &context.gates, side: .player)
        case .enemy:
            combatSystem.resolveCountdowns(on: &context.enemyGrid, opponentGrid: &context.grid, gates: &context.gates, side: .enemy)
        }
        evaluateVictory(&context)
    }

    func endEnemyTurn(context: inout TurnContext) {
        guard context.phase == .enemyInput else { return }
        context.phase = .enemyResolve
        resolveCountdowns(for: .enemy, context: &context)
        if context.phase != .gameOver {
            context.phase = .playerInput
        }
    }

    func performEnemyTurn(context: inout TurnContext, matchFinder: MatchFinder, fusionSystem: FusionSystem) {
        guard context.phase == .enemyInput else { return }
        let move = aiSystem.decideTurn(for: context.enemyGrid, balance: balance)
        applyEnemy(move: move, context: &context)
        context.enemyGrid.collapseAll(toward: .enemy)

        let matches = matchFinder.findMatches(in: context.enemyGrid, for: .enemy)
        if !matches.verticalTriplets.isEmpty || !matches.horizontalTriplets.isEmpty {
            fusionSystem.resolve(matches: matches, in: &context.enemyGrid, side: .enemy, balance: balance)
            context.enemyGrid.collapseAll(toward: .enemy)
        }

        endEnemyTurn(context: &context)
    }

    private func evaluateVictory(_ context: inout TurnContext) {
        if context.gates.playerHP <= 0 || context.gates.enemyHP <= 0 {
            context.phase = .gameOver
        }
    }

    private func applyEnemy(move: AIMove, context: inout TurnContext) {
        for action in move.actions {
            switch action {
            case let .swap(a, b):
                _ = context.enemyGrid.swap(a, b)
            case let .spawn(placements):
                applyEnemySpawn(placements, grid: &context.enemyGrid)
                for placement in placements {
                    context.enemyGrid.collapseColumn(placement.0.x, toward: .enemy)
                }
            case .endTurn:
                continue
            }
        }
    }

    private func applyEnemySpawn(_ placements: [(Coord, UnitClass)], grid: inout Grid) {
        for (coord, unitClass) in placements {
            guard grid.inBounds(coord) else { continue }
            guard case .empty? = grid.content(at: coord) else { continue }
            let unit = Unit(side: .enemy, class: unitClass)
            grid.setContent(.unit(unit), at: coord)
        }
    }
}
