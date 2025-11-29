//
//  MarbleNode.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-28.
//


import SpriteKit

class MarbleNode: SKSpriteNode {
    
    var originalTexture: SKTexture?
    
    init(textureName: String = "ballColorSoccer", size: CGSize = CGSize(width: 24, height: 24)) {
        let texture = SKTexture(imageNamed: textureName)
        super.init(texture: texture, color: .clear, size: size)
        self.name = "marble"
        self.originalTexture = texture
        self.setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    private func setupPhysics() {
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2)
        self.physicsBody?.restitution = 0.6
        self.physicsBody?.friction = 0.1
        self.physicsBody?.linearDamping = 0.4
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.categoryBitMask = 1 << 0
        self.physicsBody?.contactTestBitMask = 1 << 1
        self.physicsBody?.collisionBitMask = 1 << 0
    }
    
    func velocityMagnitude() -> CGFloat {
        guard let v = physicsBody?.velocity else { return 0 }
        return sqrt(v.dx * v.dx + v.dy * v.dy)
    }
    
    func resetPhysics() {
        physicsBody?.isDynamic = true
        physicsBody?.velocity = .zero
        physicsBody?.angularVelocity = 0
        self.alpha = 1.0
        self.setScale(1.0)
        if let originalTexture = originalTexture { self.texture = originalTexture }
    }
}
