//
//  GameScene2.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//
import SpriteKit
import CoreMotion

class GameScene2: SKScene, SKPhysicsContactDelegate {
    let motionManager = CMMotionManager()
    var marbles: [SKShapeNode] = []
    var targetPositions: [CGPoint] = []
    
    override func didMove(to view: SKView) {
        print("✅ GameScene2 loaded")
        
        backgroundColor = .black
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        motionManager.startAccelerometerUpdates()
        
        let positions = MarbleLoader.loadPositions()
        print("🔵 Loaded \(positions.count) marbles")
        
        for position in positions {
            let marble = SKShapeNode(circleOfRadius: 10)
            marble.fillColor = .blue
            marble.position = position
            marble.physicsBody = SKPhysicsBody(circleOfRadius: 10)
            marble.physicsBody?.affectedByGravity = true
            marble.physicsBody?.restitution = 0.6
            addChild(marble)
        }
    }
    
    func loadTargetPattern() {
        if let url = Bundle.main.url(forResource: "marble_positions_handshake", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let positions = try? JSONDecoder().decode([CGPoint].self, from: data) {
            targetPositions = positions
        }
    }
    
    func spawnMarbles(count: Int) {
        for i in 0..<count {
            let marble = SKShapeNode(circleOfRadius: 4)
            marble.fillColor = .white
            marble.strokeColor = .gray
            marble.position = CGPoint(x: CGFloat.random(in: 0...size.width),
                                      y: CGFloat.random(in: 0...size.height))
            marble.physicsBody = SKPhysicsBody(circleOfRadius: 4)
            marble.physicsBody?.restitution = 0.6
            marble.physicsBody?.friction = 0.1
            marble.physicsBody?.linearDamping = 0.4
            marble.physicsBody?.allowsRotation = true
            marbles.append(marble)
            addChild(marble)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let data = motionManager.accelerometerData {
            let tiltX = data.acceleration.y
            let tiltY = data.acceleration.x
            physicsWorld.gravity = CGVector(dx: tiltX * -50, dy: tiltY * 50)
        }
    }
}
