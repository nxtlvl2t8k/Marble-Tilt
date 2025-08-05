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
//    var lockedMarbles: Set<Int> = []

    
    override func didMove(to view: SKView) {
        print("✅ GameScene2 loaded")
        
        backgroundColor = .black
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        motionManager.startAccelerometerUpdates()
        //adds 1 vortex in the middle
        addVortex(at: CGPoint(x: size.width / 2, y: size.height / 2))
        
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
////        // 🟠 Load target vortex positions from JSON
////        loadTargetPattern()
//        
//        // 🌀 Add all vortex spots now that we have positions
//        for pos in targetPositions {
//            addVortex(at: pos)
//        }
        
        // 🌌 Add background image
        let background = SKSpriteNode(imageNamed: "handshake.jpeg") // use your image name
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        background.size = size
        addChild(background)
        
        // ⚪ Spawn marbles to match target pattern
        spawnMarbles(count: targetPositions.count)
        
    }
    
    func loadTargetPattern() {
        for position in targetPositions {
            let vortex = SKShapeNode(circleOfRadius: 6)
            vortex.position = position
            vortex.strokeColor = .clear
            vortex.fillColor = .orange
            vortex.alpha = 0.3
            vortex.zPosition = -0.5
            addChild(vortex)
        }
        
        if let url = Bundle.main.url(forResource: "marble_positions_handshake", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let positions = try? JSONDecoder().decode([CGPoint].self, from: data) {
            targetPositions = positions
        }
    }
        
    func addVortex(at position: CGPoint) {
        let vortex = SKSpriteNode(imageNamed: "vortex") // your vortex image
        vortex.position = position
        vortex.zPosition = 1
        vortex.setScale(0.5)
        
        vortex.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        
        vortex.physicsBody = SKPhysicsBody(circleOfRadius: vortex.size.width / 2)
        vortex.physicsBody?.isDynamic = false
        vortex.physicsBody?.categoryBitMask = 1 << 1
        vortex.physicsBody?.contactTestBitMask = 1 << 0 // assuming marbles are 1 << 0
        vortex.physicsBody?.collisionBitMask = 0
        
        addChild(vortex)
    }
    
    func spawnMarbles(count: Int) {
        for _ in 0..<count {
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
            marble.physicsBody?.categoryBitMask = 1 << 0
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
//    override func update(_ currentTime: TimeInterval) {
//        for (i, marble) in marbles.enumerated() where i < targetPositions.count {
//            guard i < targetPositions.count else { continue }
//            guard !lockedMarbles.contains(i) else { continue }
//            
//            let target = targetPositions[i]
//            let dx = target.x - marble.position.x
//            let dy = target.y - marble.position.y
//            let distance = sqrt(dx*dx + dy*dy)
//
//            // ✅ If close to the target position, lock it in place
//            if distance < 5 {
//                marble.position = target
//                marble.physicsBody = SKPhysicsBody(circleOfRadius: 4)
//                marble.physicsBody?.isDynamic = false // ✅ Locks it in place
//                marble.physicsBody?.categoryBitMask = 1 << 2
//                marble.physicsBody?.collisionBitMask = 0xFFFFFFFF // collide with everything
//                marble.physicsBody?.restitution = 0.6
//                marble.fillColor = .green
//                lockedMarbles.insert(i)
//            } else {
//                // ✅ Apply small steering force toward target
//                let vector = CGVector(dx: dx * 0.01, dy: dy * 0.01)
//                marble.physicsBody?.applyForce(vector)
//            }
//        }
//    }
    func resetGame() {
        // Remove all marbles
        for marble in marbles {
            marble.removeFromParent()
        }
        marbles.removeAll()
//        lockedMarbles.removeAll()

        // Optional: remove any sparks or effects
        for child in children where child.name == "effect" {
            child.removeFromParent()
        }

        // Spawn fresh marbles
        spawnMarbles(count: targetPositions.count)
    }
}
