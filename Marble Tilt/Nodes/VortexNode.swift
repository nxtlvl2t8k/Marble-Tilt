//
//  VortexNode.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-28.
//


// VortexNode.swift
import SpriteKit

class VortexNode: SKSpriteNode {
    let index: Int
    init(index: Int = 0) {
        self.index = index
        let texture = SKTexture(imageNamed: "vortex")
        super.init(texture: texture, color: .clear, size: texture.size())
        name = "vortex"
        zPosition = 1
        setScale(0.5)
        setupPhysics()
        resetAnimation()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    private func setupPhysics() {
        let r = max(8, (size.width * 0.5) * 0.4)
        physicsBody = SKPhysicsBody(circleOfRadius: r)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = 1 << 1
        physicsBody?.contactTestBitMask = 1 << 0 // detect marble proximity
        physicsBody?.collisionBitMask = 0 // ❌ NO collision — marble will pass through
    }

    func resetAnimation() {
        removeAllActions()
        run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 2)))
    }
}
