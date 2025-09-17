import SpriteKit

enum SpriteFactory {
    static let tileSize = CGSize(width: 48, height: 48)

    static func makeSprite(for content: CellContent) -> SKSpriteNode {
        switch content {
        case .empty:
            return makeBaseNode(fill: Palette.boardFill, stroke: Palette.boardStroke)
        case let .unit(unit):
            let node = makeBaseNode(fill: Palette.unitFill(for: unit), stroke: Palette.boardStroke)
            node.addChild(makeLabel(text: shortLabel(for: unit.class)))
            return node
        case let .wall(wall):
            let node = makeBaseNode(fill: Palette.wallFill(for: wall), stroke: Palette.boardStroke)
            node.addChild(makeLabel(text: shortLabel(for: wall.class)))
            return node
        case let .attacker(attacker):
            let node = makeBaseNode(fill: Palette.attackerFill(for: attacker), stroke: Palette.attackerStroke)
            node.addChild(makeLabel(text: shortLabel(for: attacker.class)))
            let countdownLabel = makeLabel(text: "\(attacker.countdown)")
            countdownLabel.fontSize = 14
            countdownLabel.position = CGPoint(x: 0, y: -tileSize.height * 0.35)
            node.addChild(countdownLabel)
            return node
        }
    }

    private static func makeBaseNode(fill: SKColor, stroke: SKColor) -> SKSpriteNode {
        let container = SKSpriteNode(color: .clear, size: tileSize)
        let shape = SKShapeNode(rectOf: tileSize, cornerRadius: 8)
        shape.fillColor = fill
        shape.strokeColor = stroke
        shape.lineWidth = 2
        shape.zPosition = 1
        container.addChild(shape)
        return container
    }

    private static func makeLabel(text: String) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "Courier-Bold"
        label.fontSize = 18
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.fontColor = .black
        label.zPosition = 2
        return label
    }

    private static func shortLabel(for unitClass: UnitClass) -> String {
        switch unitClass {
        case .warrior:
            return "W"
        case .archer:
            return "A"
        case .knight:
            return "K"
        }
    }

    enum Palette {
        static let boardFill = SKColor(white: 0.12, alpha: 1.0)
        static let boardStroke = SKColor(white: 0.35, alpha: 1.0)
        static let attackerStroke = SKColor.white

        static func unitFill(for unit: Unit) -> SKColor {
            tint(base: baseColor(for: unit.class), side: unit.side)
        }

        static func wallFill(for wall: Wall) -> SKColor {
            tint(base: baseColor(for: wall.class).withAlphaComponent(0.55), side: wall.side)
        }

        static func attackerFill(for attacker: Attacker) -> SKColor {
            tint(base: baseColor(for: attacker.class).withAlphaComponent(0.8), side: attacker.side)
        }

        private static func baseColor(for unitClass: UnitClass) -> SKColor {
            switch unitClass {
            case .warrior:
                return SKColor.systemOrange
            case .archer:
                return SKColor.systemGreen
            case .knight:
                return SKColor.systemBlue
            }
        }

        private static func tint(base: SKColor, side: Side) -> SKColor {
            switch side {
            case .player:
                return base
            case .enemy:
                let shifted = base.withHueOffset(0.05)
                return shifted.withAlphaComponent(max(0.2, shifted.cgColor.alpha * 0.9))
            }
        }
    }
}

private extension SKColor {
    func withHueOffset(_ offset: CGFloat) -> SKColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            let newHue = (h + offset).truncatingRemainder(dividingBy: 1)
            return SKColor(hue: newHue < 0 ? newHue + 1 : newHue,
                           saturation: s,
                           brightness: b,
                           alpha: a)
        }
        return self
    }
}
