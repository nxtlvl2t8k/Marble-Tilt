//
//  MarbleNode.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-28.
//

// MarbleNode.swift
import SpriteKit

class MarbleNode: SKSpriteNode {
    init() {
        let texture = SKTexture(imageNamed: "ballGrey")
        super.init(texture: texture, color: .clear, size: CGSize(width: 24, height: 24))
        name = "marble"
        zPosition = 10
        setupPhysics()
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width * 0.5)
        physicsBody?.restitution = 0.6
        physicsBody?.friction = 0.1
        physicsBody?.linearDamping = 0.4
        physicsBody?.allowsRotation = true
        physicsBody?.categoryBitMask = 1 << 0
        physicsBody?.contactTestBitMask = 1 << 1 // to detect vortex
        physicsBody?.collisionBitMask = 1 << 0 //0xFFFFFFFF // collide only with other things (like frame)
    }

    func sink(into vortex: VortexNode) {
        physicsBody?.velocity = .zero
        physicsBody?.angularVelocity = 0
        physicsBody?.isDynamic = false
        position = vortex.position
        zPosition = vortex.zPosition + 1
        run(SKAction.group([SKAction.scale(to: 0.8, duration: 0.15),
                            SKAction.fadeAlpha(to: 1.0, duration: 0.15)]))
    }

    func resetPhysics() {
        if physicsBody == nil { setupPhysics() }
        physicsBody?.isDynamic = true
        physicsBody?.velocity = .zero
        physicsBody?.angularVelocity = 0
        setScale(1.0)
        alpha = 1.0
    }

    func applyImpulse(_ v: CGVector) { physicsBody?.applyImpulse(v) }
}
