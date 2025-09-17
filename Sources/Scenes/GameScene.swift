import SpriteKit
import Foundation
import UIKit

final class GameScene: SKScene {
    private let turnSystem: TurnSystem
    private var context: TurnContext
    private let fusionSystem: FusionSystem
    private let matchFinder = MatchFinder()
    private var balance: BalanceProvider
    private var playerSelection: Coord?
    private let boardSeed: UInt64

    private let hud = HUD()
    private var playerNodes: [[SKSpriteNode?]] = []
    private var enemyNodes: [[SKSpriteNode?]] = []
    private let tileSize = CGSize(width: 48, height: 48)
    private var playerBoardOrigin = CGPoint.zero
    private var enemyBoardOrigin = CGPoint.zero
    private let boardGap: CGFloat = 96
    private var selectionHighlight: SKShapeNode?

    private lazy var endTurnButton: SKLabelNode = {
        let label = SKLabelNode(text: "End Turn")
        label.fontName = "Courier-Bold"
        label.fontSize = 24
        label.name = "endTurnButton"
        label.position = CGPoint(x: size.width / 2 - 100, y: -size.height / 2 + 60)
        return label
    }()

    private lazy var pauseButton: SKLabelNode = {
        let label = SKLabelNode(text: "Pause")
        label.fontName = "Courier-Bold"
        label.fontSize = 20
        label.name = "pauseButton"
        label.position = CGPoint(x: -size.width / 2 + 80, y: -size.height / 2 + 60)
        return label
    }()

    convenience init(size: CGSize,
                     balance: BalanceProvider = Balance.shared) {
        self.init(size: size,
                  seed: GameScene.makeRandomSeed(),
                  balance: balance)
    }

    init(size: CGSize,
         seed: UInt64,
         balance: BalanceProvider = Balance.shared,
         turnSystem: TurnSystem? = nil,
         context: TurnContext? = nil) {
        self.balance = balance
        self.boardSeed = seed
        let combatSystem = CombatSystem()
        self.fusionSystem = FusionSystem()
        let boardInitializer = BoardInitializer(seed: seed)
        let system = turnSystem ?? TurnSystem(combatSystem: combatSystem, balance: balance, boardInitializer: boardInitializer)
        self.turnSystem = system
        self.context = context ?? system.startBattle()
        super.init(size: size)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        let balance = Balance.shared
        let seed = GameScene.makeRandomSeed()
        let combatSystem = CombatSystem()
        let fusionSystem = FusionSystem()
        let boardInitializer = BoardInitializer(seed: seed)
        let turnSystem = TurnSystem(combatSystem: combatSystem, balance: balance, boardInitializer: boardInitializer)
        self.balance = balance
        self.boardSeed = seed
        self.fusionSystem = fusionSystem
        self.turnSystem = turnSystem
        self.context = turnSystem.startBattle()
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        scaleMode = .aspectFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(endTurnButton)
        addChild(pauseButton)
        addChild(hud)
        setupSelectionHighlight()
        layoutControls()
        computeBoardOrigins()
        createBoardNodes()
        createEnemyBoardNodes()
        redrawBoard()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutControls()
        computeBoardOrigins()
        updateNodePositions(playerNodes, origin: playerBoardOrigin)
        updateNodePositions(enemyNodes, origin: enemyBoardOrigin)
        updateSelectionHighlight(for: playerSelection)
    }

    private func layoutControls() {
        let inset: CGFloat = 60
        endTurnButton.position = CGPoint(x: size.width / 2 - inset, y: -size.height / 2 + inset)
        pauseButton.position = CGPoint(x: -size.width / 2 + inset, y: -size.height / 2 + inset)
        hud.position = CGPoint(x: 0, y: size.height / 2 - 160)
    }

    private func setupSelectionHighlight() {
        let highlight = SKShapeNode(rectOf: tileSize, cornerRadius: 10)
        highlight.strokeColor = SKColor.yellow
        highlight.lineWidth = 3
        highlight.fillColor = SKColor.clear
        highlight.zPosition = 50
        highlight.isHidden = true
        selectionHighlight = highlight
        addChild(highlight)
    }

    private func updateSelectionHighlight(for coord: Coord?) {
        guard let coord = coord else {
            selectionHighlight?.isHidden = true
            return
        }
        selectionHighlight?.position = positionForPlayerCell(x: coord.x, y: coord.y)
        selectionHighlight?.isHidden = false
    }

    private func updateNodePositions(_ nodes: [[SKSpriteNode?]], origin: CGPoint) {
        guard nodes.count == Grid.columns else { return }
        for x in 0..<Grid.columns {
            guard nodes[x].count == Grid.rows else { continue }
            for y in 0..<Grid.rows {
                guard let node = nodes[x][y] else { continue }
                let offsetX = CGFloat(x) * tileSize.width
                let offsetY = CGFloat(y) * tileSize.height
                node.position = CGPoint(x: origin.x + offsetX, y: origin.y + offsetY)
            }
        }
    }

    private static func makeRandomSeed() -> UInt64 {
        var generator = SystemRandomNumberGenerator()
        return UInt64.random(in: UInt64.min...UInt64.max, using: &generator)
    }

    private func computeBoardOrigins() {
        let boardWidth = CGFloat(Grid.columns) * tileSize.width
        let boardHeight = CGFloat(Grid.rows) * tileSize.height
        playerBoardOrigin = CGPoint(x: -boardWidth / 2, y: -boardHeight - boardGap / 2)
        enemyBoardOrigin = CGPoint(x: -boardWidth / 2, y: boardGap / 2)
    }

    private func createBoardNodes() {
        playerNodes = Array(repeating: Array(repeating: nil, count: Grid.rows), count: Grid.columns)
        for x in 0..<Grid.columns {
            for y in 0..<Grid.rows {
                let placeholder = SKSpriteNode(color: .clear, size: tileSize)
                placeholder.position = positionForPlayerCell(x: x, y: y)
                addChild(placeholder)
                playerNodes[x][y] = placeholder
            }
        }
    }

    private func createEnemyBoardNodes() {
        enemyNodes = Array(repeating: Array(repeating: nil, count: Grid.rows), count: Grid.columns)
        for x in 0..<Grid.columns {
            for y in 0..<Grid.rows {
                let placeholder = SKSpriteNode(color: .clear, size: tileSize)
                placeholder.position = positionForEnemyCell(x: x, y: y)
                addChild(placeholder)
                enemyNodes[x][y] = placeholder
            }
        }
    }

    private func redrawBoard() {
        redrawPlayerBoard()
        redrawEnemyBoard()
        hud.update(gates: context.gates,
                   movesRemaining: context.playerMovesRemaining,
                   maxMoves: balance.playerMovesPerTurn,
                   seed: boardSeed)
    }

    private func redrawPlayerBoard() {
        for x in 0..<Grid.columns {
            for y in 0..<Grid.rows {
                guard let node = playerNodes[x][y] else { continue }
                let coord = Coord(x: x, y: y)
                node.removeAllChildren()
                node.texture = nil
                node.color = .clear

                guard let content = context.grid.content(at: coord) else { continue }
                let sprite = SpriteFactory.makeSprite(for: content)
                sprite.position = .zero
                sprite.zPosition = 1
                node.addChild(sprite)
            }
        }
    }

    private func redrawEnemyBoard() {
        for x in 0..<Grid.columns {
            for y in 0..<Grid.rows {
                guard let node = enemyNodes[x][y] else { continue }
                let coord = Coord(x: x, y: y)
                node.removeAllChildren()
                node.texture = nil
                node.color = .clear

                guard let content = context.enemyGrid.content(at: coord) else { continue }
                let sprite = SpriteFactory.makeSprite(for: content)
                sprite.position = .zero
                sprite.zPosition = 1
                node.addChild(sprite)
            }
        }
    }

    private func animateEnemyBoardChanges(from previous: Grid, to current: Grid) {
        guard enemyNodes.count == Grid.columns else { return }
        for x in 0..<Grid.columns {
            guard enemyNodes[x].count == Grid.rows else { continue }
            for y in 0..<Grid.rows {
                guard let node = enemyNodes[x][y] else { continue }
                let coord = Coord(x: x, y: y)
                let before = previous.content(at: coord) ?? .empty
                let after = current.content(at: coord) ?? .empty
                if isSpawn(before: before, after: after) {
                    runSpawnAnimation(on: node)
                }
                if didAttackerCharge(before: before, after: after, side: .enemy) {
                    animateAttackerCharge(from: coord, side: .enemy)
                }
            }
        }
    }

    private func animatePlayerBoardChanges(from previous: Grid, to current: Grid) {
        guard playerNodes.count == Grid.columns else { return }
        for x in 0..<Grid.columns {
            guard playerNodes[x].count == Grid.rows else { continue }
            for y in 0..<Grid.rows {
                guard let node = playerNodes[x][y] else { continue }
                let coord = Coord(x: x, y: y)
                let before = previous.content(at: coord) ?? .empty
                let after = current.content(at: coord) ?? .empty
                if isSpawn(before: before, after: after) {
                    runSpawnAnimation(on: node)
                }
                if didAttackerCharge(before: before, after: after, side: .player) {
                    animateAttackerCharge(from: coord, side: .player)
                }
            }
        }
    }

    private func runSpawnAnimation(on node: SKNode) {
        node.removeAllActions()
        node.setScale(0.0)
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.12)
        let settle = SKAction.scale(to: 1.0, duration: 0.1)
        node.run(SKAction.sequence([scaleUp, settle]))
        AudioManager.shared.playEffect(named: "spawn.wav", on: self)
    }

    private func isSpawn(before: CellContent, after: CellContent) -> Bool {
        switch (before, after) {
        case (.empty, .unit), (.empty, .wall), (.empty, .attacker):
            return true
        default:
            return false
        }
    }

    private func didAttackerCharge(before: CellContent, after: CellContent, side: Side) -> Bool {
        guard case let .attacker(previousAttacker) = before, previousAttacker.side == side else {
            return false
        }
        if case let .attacker(nextAttacker) = after, nextAttacker.side == side {
            return false
        }
        return true
    }

    private func animateAttackerCharge(from coord: Coord, side: Side) {
        let cellCenter: CGPoint
        switch side {
        case .player:
            cellCenter = positionForPlayerCell(x: coord.x, y: coord.y)
        case .enemy:
            cellCenter = positionForEnemyCell(x: coord.x, y: coord.y)
        }

        let topOffset = tileSize.height / 2
        let bottomOffset = -tileSize.height / 2

        let anchorPoint: CGPoint
        let startPoint: CGPoint
        let beamHeight: CGFloat
        switch side {
        case .player:
            anchorPoint = CGPoint(x: 0.5, y: 0.0)
            startPoint = CGPoint(x: cellCenter.x, y: cellCenter.y + topOffset)
            let targetY = enemyBoardOrigin.y + CGFloat(Grid.rows) * tileSize.height + boardGap / 4
            beamHeight = max(0, targetY - startPoint.y)
        case .enemy:
            anchorPoint = CGPoint(x: 0.5, y: 1.0)
            startPoint = CGPoint(x: cellCenter.x, y: cellCenter.y + bottomOffset)
            let targetY = playerBoardOrigin.y - boardGap / 4
            beamHeight = max(0, startPoint.y - targetY)
        }

        guard beamHeight > 0 else { return }

        let color: UIColor = (side == .player ? UIColor.systemTeal : UIColor.systemRed).withAlphaComponent(0.35)
        let beam = SKSpriteNode(color: color, size: CGSize(width: tileSize.width * 0.45, height: beamHeight))
        beam.anchorPoint = anchorPoint
        beam.position = startPoint
        beam.zPosition = 25
        addChild(beam)

        let expand = SKAction.scaleX(to: 1.3, duration: 0.08)
        let fade = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()
        beam.run(SKAction.sequence([expand, fade, remove]))
        AudioManager.shared.playEffect(named: "charge.wav", on: self)
    }

    private func handleEndTurn() {
        playerSelection = nil
        updateSelectionHighlight(for: nil)

        let previousPlayerGrid = context.grid
        let previousGates = context.gates

        turnSystem.endPlayerTurn(context: &context)
        redrawBoard()
        animatePlayerBoardChanges(from: previousPlayerGrid, to: context.grid)
        handleGateDamage(previous: previousGates, current: context.gates)

        if context.phase == .enemyInput {
            let enemyPreGrid = context.enemyGrid
            let playerPreGrid = context.grid
            let gatesBeforeEnemy = context.gates

            turnSystem.performEnemyTurn(context: &context, matchFinder: matchFinder, fusionSystem: fusionSystem)
            redrawBoard()
            animateEnemyBoardChanges(from: enemyPreGrid, to: context.enemyGrid)
            animatePlayerBoardChanges(from: playerPreGrid, to: context.grid)
            handleGateDamage(previous: gatesBeforeEnemy, current: context.gates)
        }
    }

    private func handleGateDamage(previous: GateState, current: GateState) {
        if current.enemyHP < previous.enemyHP {
            playGateHit(for: .enemy)
        }
        if current.playerHP < previous.playerHP {
            playGateHit(for: .player)
        }
    }

    private func playGateHit(for side: Side) {
        AudioManager.shared.playEffect(named: "gate_hit.wav", on: self)
        hud.flashGate(for: side)
        removeAction(forKey: "gateShake")
        let amplitude: CGFloat = 8
        let direction: CGFloat = (side == .player) ? amplitude : -amplitude
        let up = SKAction.moveBy(x: 0, y: direction, duration: 0.05)
        let down = up.reversed()
        let shake = SKAction.sequence([up, down, up, down])
        run(shake, withKey: "gateShake")
    }

    private func presentSeedPrompt() {
        guard let view = view, let controller = view.window?.rootViewController else { return }
        playerSelection = nil
        updateSelectionHighlight(for: nil)

        let alert = UIAlertController(title: "Restart Battle",
                                      message: "Enter a numeric seed or leave blank for random.",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Seed"
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            let input = alert.textFields?.first?.text ?? ""
            let customSeed = UInt64(input)
            let seed = customSeed ?? GameScene.makeRandomSeed()
            let newScene = GameScene(size: self.size,
                                     seed: seed,
                                     balance: self.balance)
            newScene.scaleMode = self.scaleMode
            view.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.4))
        }))
        controller.present(alert, animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if pauseButton.contains(location) {
            presentSeedPrompt()
            return
        }

        if endTurnButton.contains(location) {
            handleEndTurn()
            return
        }

        guard let column = columnForPlayerBoard(at: location),
              let frontCoord = context.grid.frontCoord(for: .player, column: column),
              let content = context.grid.content(at: frontCoord),
              case let .unit(unit) = content,
              unit.side == .player else {
            playerSelection = nil
            updateSelectionHighlight(for: nil)
            return
        }

        playerSelection = frontCoord
        updateSelectionHighlight(for: frontCoord)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // TODO: Provide drag preview feedback.
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let start = playerSelection, let touch = touches.first else { return }
        let location = touch.location(in: self)
        guard let destinationColumn = columnForPlayerBoard(at: location) else {
            playerSelection = nil
            updateSelectionHighlight(for: nil)
            return
        }
        attemptMove(from: start, toColumn: destinationColumn)
        playerSelection = nil
        updateSelectionHighlight(for: nil)
    }

    private func attemptMove(from start: Coord, toColumn destinationColumn: Int) {
        guard context.phase == .playerInput else { return }
        guard context.playerMovesRemaining > 0 else { return }
        guard context.grid.isFrontCell(start, for: .player) else { return }
        guard let content = context.grid.content(at: start), case let .unit(unit) = content, unit.side == .player else { return }
        guard destinationColumn >= 0 && destinationColumn < Grid.columns else { return }
        guard destinationColumn != start.x else { return }

        context.grid.collapseColumn(destinationColumn, toward: .player)
        guard let insertionCoord = context.grid.nextInsertionCoord(for: .player, column: destinationColumn) else { return }

        var previousGrid = context.grid
        context.grid.setContent(.empty, at: start)
        context.grid.collapseColumn(start.x, toward: .player)
        context.grid.setContent(.unit(unit), at: insertionCoord)
        context.grid.collapseColumn(destinationColumn, toward: .player)
        context.playerMovesRemaining -= 1
        resolvePlayerMatches()
        context.grid.collapseAll(toward: .player)
        redrawBoard()
        animatePlayerBoardChanges(from: previousGrid, to: context.grid)
        playerSelection = nil
        updateSelectionHighlight(for: nil)
    }

    private func resolvePlayerMatches() {
        let results = matchFinder.findMatches(in: context.grid, for: .player)
        guard !results.verticalTriplets.isEmpty || !results.horizontalTriplets.isEmpty else { return }
        _ = fusionSystem.resolve(matches: results, in: &context.grid, side: .player, balance: balance)
        context.grid.collapseAll(toward: .player)
    }

    private func positionForPlayerCell(x: Int, y: Int) -> CGPoint {
        let offsetX = CGFloat(x) * tileSize.width
        let offsetY = CGFloat(y) * tileSize.height
        return CGPoint(x: playerBoardOrigin.x + offsetX, y: playerBoardOrigin.y + offsetY)
    }

    private func positionForEnemyCell(x: Int, y: Int) -> CGPoint {
        let offsetX = CGFloat(x) * tileSize.width
        let offsetY = CGFloat(y) * tileSize.height
        return CGPoint(x: enemyBoardOrigin.x + offsetX, y: enemyBoardOrigin.y + offsetY)
    }

    private func columnForPlayerBoard(at point: CGPoint) -> Int? {
        let relativeX = point.x - playerBoardOrigin.x
        guard relativeX >= 0 else { return nil }
        let column = Int(relativeX / tileSize.width)
        guard column >= 0 && column < Grid.columns else { return nil }
        let relativeY = point.y - playerBoardOrigin.y
        guard relativeY >= 0, relativeY <= CGFloat(Grid.rows) * tileSize.height else { return nil }
        return column
    }

    private func coordForPlayerBoard(at point: CGPoint) -> Coord? {
        guard let column = columnForPlayerBoard(at: point) else { return nil }
        let relativeY = point.y - playerBoardOrigin.y
        guard relativeY >= 0 else { return nil }
        let row = Int(relativeY / tileSize.height)
        let coord = Coord(x: column, y: row)
        return context.grid.inBounds(coord) ? coord : nil
    }
}
