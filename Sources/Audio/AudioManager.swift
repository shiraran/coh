import AVFoundation
import SpriteKit

final class AudioManager {
    static let shared = AudioManager()

    private var backgroundPlayer: AVAudioPlayer?

    private init() {}

    func playBackgroundMusic(named fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            return
        }
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1
            backgroundPlayer?.volume = 0.4
            backgroundPlayer?.play()
        } catch {
            print("Failed to load BGM: \(error)")
        }
    }

    func stopBackgroundMusic() {
        backgroundPlayer?.stop()
    }

    func playEffect(named fileName: String, on node: SKNode) {
        let action = SKAction.playSoundFileNamed(fileName, waitForCompletion: false)
        node.run(action)
    }
}
