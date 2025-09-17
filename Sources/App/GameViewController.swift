import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        presentTitleScene()
    }

    private func configureView() {
        guard let skView = view as? SKView else {
            let skView = SKView(frame: view.bounds)
            skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            skView.ignoresSiblingOrder = true
            skView.isMultipleTouchEnabled = true
            view = skView
            return
        }
        skView.ignoresSiblingOrder = true
        skView.isMultipleTouchEnabled = true
    }

    private func presentTitleScene() {
        guard let skView = view as? SKView else { return }
        let scene = TitleScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override func loadView() {
        view = SKView(frame: UIScreen.main.bounds)
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
