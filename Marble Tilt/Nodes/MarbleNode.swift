//
//  MarbleNode.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-28.
//


import SpriteKit

class MarbleNode: SKSpriteNode {

    static func createRandom(in scene: SKScene) -> MarbleNode {
        let node = MarbleNode(imageNamed: "ballColorSoccer")
        node.name = "marble"
        node.size = CGSize(width: 24, height: 24)

        node.position = CGPoint(
            x: CGFloat.random(in: 0...scene.size.width),
            y: CGFloat.random(in: 0...scene.size.height)
        )

        node.addPhysics()
        return node
    }

    func addPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: 12)
        physicsBody?.restitution = 0.6
        physicsBody?.friction = 0.1
        physicsBody?.linearDamping = 0.4
        physicsBody?.allowsRotation = true
        physicsBody?.categoryBitMask = 1 << 0
        physicsBody?.collisionBitMask = 1 << 0
        physicsBody?.contactTestBitMask = 1 << 1
    }
}
