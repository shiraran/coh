import SpriteKit

final class TitleScene: SKScene {
    private lazy var startLabel: SKLabelNode = {
        let label = SKLabelNode(text: "Tap to Start")
        label.fontName = "Courier-Bold"
        label.fontSize = 32
        label.position = CGPoint(x: 0, y: -40)
        return label
    }()

    override func didMove(to view: SKView) {
        backgroundColor = .black
        let title = SKLabelNode(text: "Solgard Tactics")
        title.fontName = "Courier-Bold"
        title.fontSize = 48
        title.position = CGPoint(x: 0, y: 60)
        addChild(title)
        addChild(startLabel)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = view else { return }
        let seed = UInt64.random(in: UInt64.min...UInt64.max)
        let gameScene = GameScene(size: view.bounds.size, seed: seed)
        gameScene.scaleMode = .resizeFill
        view.presentScene(gameScene, transition: .fade(withDuration: 0.5))
    }
}
