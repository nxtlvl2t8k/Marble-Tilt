//
//  VortexNode.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-28.
//


import SpriteKit

class VortexNode: SKSpriteNode {
    
    init(position: CGPoint, size: CGSize = CGSize(width: 70, height: 70)) {
        let texture = SKTexture(imageNamed: "vortex")
        super.init(texture: texture, color: .clear, size: size)
        self.position = position
        self.name = "vortex"
        self.zPosition = 1
        self.setupPhysics()
        self.startRotation()
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    private func setupPhysics() {
        let radius = size.width * 0.4
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = 1 << 1
        physicsBody?.contactTestBitMask = 1 << 0
        physicsBody?.collisionBitMask = 0
    }
    
    private func startRotation() {
        run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
    }
}
