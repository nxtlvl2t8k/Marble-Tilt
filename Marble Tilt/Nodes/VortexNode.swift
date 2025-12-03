//
//  VortexNode.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-28.
//


import SpriteKit

class VortexNode: SKSpriteNode {

    static func create(at position: CGPoint) -> VortexNode {
        let node = VortexNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        node.zPosition = 1
        node.setScale(0.5)

        node.setupPhysics()
        node.startSpin()

        return node
    }

    func startSpin() {
        let spin = SKAction.rotate(byAngle: .pi, duration: 1)
        run(SKAction.repeatForever(spin))
    }

    func refreshAnimation() {
        removeAllActions()
        startSpin()

        let flash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        run(SKAction.repeat(flash, count: 2))
    }

    private func setupPhysics() {
        let radius = (size.width * 0.5) * 0.4
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = 1 << 1
        physicsBody?.contactTestBitMask = 1 << 0
        physicsBody?.collisionBitMask = 0
    }
}
