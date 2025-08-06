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
    var marbles: [SKSpriteNode] = []
    var targetPositions: [CGPoint] = []
    var lockMarble: Set<CGPoint> = []
    var lockedMarbles: Set<CGPoint> = []
    var lockedVortexes: Set<CGPoint> = []

    
    override func didMove(to view: SKView) {
        print("✅ GameScene2 loaded")
        
        backgroundColor = .black
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        motionManager.startAccelerometerUpdates()
        
        let positions = MarbleLoader.loadPositions()
        print("🔵 Loaded \(positions.count) marbles")
        
        // 🟠 Load target vortex positions from JSON
        loadTargetPattern()
        
        
        // 🌀 Add all vortex spots now that we have positions
        for pos in targetPositions {
            addVortex(at: pos)
        }
        
        //adds 1 vortex in the middle
        addVortex(at: CGPoint(x: size.width / 2, y: size.height / 2))
                
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
        
        if let url = Bundle.main.url(forResource: "marble_positions_handshake_scaled_ipad", withExtension: "json") {
            print("📄 Found file at: \(url)")
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([MarblePosition].self, from: data)
                targetPositions = decoded.map { $0.cgPoint }
                print("🌀 Loaded \(targetPositions.count) vortex positions")
            } catch {
                print("❌ JSON decode failed: \(error)")
            }
        } else {
            print("❌ Could not find JSON file in bundle")
        }
    }
    
    func addVortex(at position: CGPoint) {
        let vortex = SKSpriteNode(imageNamed: "vortex") // your vortex image
        vortex.name = "vortex"
        vortex.position = position
        vortex.zPosition = 1
        vortex.setScale(0.5)
        vortex.name = "vortex"
        
        vortex.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        
        vortex.physicsBody = SKPhysicsBody(circleOfRadius: vortex.size.width / 2)
        vortex.physicsBody?.isDynamic = false
        vortex.physicsBody?.categoryBitMask = 1 << 1
        vortex.physicsBody?.contactTestBitMask = 1 << 0 // assuming marbles are 1 << 0
        vortex.physicsBody?.collisionBitMask = 1 << 0 // ← allow collision with marbles!

        
        addChild(vortex)
    }

    func spawnMarbles(count: Int) {
        for _ in 0..<count {
            let marble = SKSpriteNode(imageNamed: "ballGrey")
            marble.name = "ballGrey"
            marble.size = CGSize(width: 24, height: 24)
            marble.position = CGPoint(x: CGFloat.random(in: 0...size.width),
                                      y: CGFloat.random(in: 0...size.height))
            marble.physicsBody = SKPhysicsBody(circleOfRadius: 12) //4
            marble.physicsBody?.restitution = 0.6
            marble.physicsBody?.friction = 0.1
            marble.physicsBody?.linearDamping = 0.4
            marble.physicsBody?.allowsRotation = true
            marble.physicsBody?.categoryBitMask = 1 << 0
            marble.physicsBody?.contactTestBitMask = 1 << 1
            marble.physicsBody?.collisionBitMask = 1 << 1 //0xFFFFFFFF
            marbles.append(marble)
            addChild(marble)
        }
    }
    
    func lockMarble(_ marble: SKSpriteNode, at position: CGPoint) {
        marble.position = position
        marble.physicsBody = nil // disable physics
        marble.zPosition = 2
        marble.color = .green
        marble.colorBlendFactor = 0.6
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node

        var marble: SKNode?
        var vortex: SKNode?

        // Identify which is which
        if nodeA?.name == "ballGrey" && nodeB?.name == "vortex" {
            marble = nodeA
            vortex = nodeB
        } else if nodeB?.name == "ballGrey" && nodeA?.name == "vortex" {
            marble = nodeB
            vortex = nodeA
        }

        // Lock the marble to the vortex
        if let marble = marble, let vortex = vortex {
            marble.physicsBody?.velocity = .zero
            marble.physicsBody?.angularVelocity = 0
            marble.physicsBody?.isDynamic = false
            marble.position = vortex.position
            print("🔒 Marble locked to vortex")
        }
    }
    
//        guard let marble = (contact.bodyA.node as? SKSpriteNode ?? contact.bodyB.node as? SKSpriteNode),
//              marble.name == "marble" else { return }
///// this makes ballGrey lockMarkle and turns green against the wall
//        //        marble.name == "ballGrey" else { return }
//
//        let vortex = (contact.bodyA.node?.name == "vortex") ? contact.bodyA.node : contact.bodyB.node
//        guard let vortexNode = vortex as? SKSpriteNode else { return }
//
//        let vortexPos = vortexNode.position
//        if !lockedVortexes.contains(vortexPos) {
//            lockMarble(marble, at: vortexPos)
//            lockedVortexes.insert(vortexPos)
//        }
//    }
    
    override func update(_ currentTime: TimeInterval) {
        if let data = motionManager.accelerometerData {
            let tiltX = data.acceleration.y
            let tiltY = data.acceleration.x
            physicsWorld.gravity = CGVector(dx: tiltX * -50, dy: tiltY * 50)
        }
    }
}
    
    
//    func resetGame() {
//        // Remove all marbles
//        for marble in marbles {
//            marble.removeFromParent()
//        }
//        marbles.removeAll()
//        //lockedMarbles.removeAll()

//        // Optional: remove any sparks or effects
//        for child in children where child.name == "effect" {
//            child.removeFromParent()
//        }

        // Spawn fresh marbles
//        spawnMarbles(count: targetPositions.count)
//    }
//}
