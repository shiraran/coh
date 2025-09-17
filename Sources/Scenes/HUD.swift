import SpriteKit

final class HUD: SKNode {
    private let playerGateLabel = SKLabelNode(fontNamed: "Courier-Bold")
    private let enemyGateLabel = SKLabelNode(fontNamed: "Courier-Bold")
    private let movesLabel = SKLabelNode(fontNamed: "Courier-Bold")
    private let seedLabel = SKLabelNode(fontNamed: "Courier")
    private let flashDuration: TimeInterval = 0.2

    override init() {
        super.init()
        setupLabels()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabels()
    }

    private func setupLabels() {
        playerGateLabel.fontSize = 20
        playerGateLabel.horizontalAlignmentMode = .left
        playerGateLabel.position = CGPoint(x: -200, y: 140)
        addChild(playerGateLabel)

        enemyGateLabel.fontSize = 20
        enemyGateLabel.horizontalAlignmentMode = .right
        enemyGateLabel.position = CGPoint(x: 200, y: 140)
        addChild(enemyGateLabel)

        movesLabel.fontSize = 20
        movesLabel.position = CGPoint(x: 0, y: 140)
        addChild(movesLabel)

        seedLabel.fontSize = 14
        seedLabel.position = CGPoint(x: 0, y: 110)
        addChild(seedLabel)
    }

    func update(gates: GateState, movesRemaining: Int, maxMoves: Int, seed: UInt64) {
        playerGateLabel.text = "Player Gate: \(max(0, gates.playerHP))"
        enemyGateLabel.text = "Enemy Gate: \(max(0, gates.enemyHP))"
        movesLabel.text = "Moves: \(movesRemaining)/\(maxMoves)"
        seedLabel.text = "Seed: \(seed)"
    }

    func flashGate(for side: Side) {
        let label = (side == .player) ? playerGateLabel : enemyGateLabel
        label.removeAction(forKey: "flash")
        let originalColor = label.fontColor ?? .white
        let flashColor = (side == .player ? SKColor.systemTeal : SKColor.systemRed)
        let colorize = SKAction.run { label.fontColor = flashColor }
        let wait = SKAction.wait(forDuration: flashDuration)
        let reset = SKAction.run { label.fontColor = originalColor }
        label.run(SKAction.sequence([colorize, wait, reset]), withKey: "flash")
    }
}
