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
    var lockedVortexes: Set<SKNode> = []
    var vortexNodes: [SKSpriteNode] = []
    private var selectedVortex: SKSpriteNode?
    
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
        
//        //adds 1 vortex in the middle
//        addVortex(at: CGPoint(x: size.width / 2, y: size.height / 2))
        
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
        
        vortex.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        
        vortex.physicsBody = SKPhysicsBody(circleOfRadius: vortex.size.width / 2)
        vortex.physicsBody?.isDynamic = false
        vortex.physicsBody?.categoryBitMask = 1 << 1
        vortex.physicsBody?.contactTestBitMask = 1 << 0 // assuming marbles are 1 << 0
        vortex.physicsBody?.collisionBitMask = 0
        
        vortexNodes.append(vortex)
        addChild(vortex)
    }
///This is used to move vortex and get the co-ordinates.  Using marble_positions_handshake_scaled_ipad-2
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        
//        for vortex in vortexNodes {
//            if vortex.contains(location) {
//                selectedVortex = vortex
//                break
//            }
//        }
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first, let vortex = selectedVortex else { return }
//        let location = touch.location(in: self)
//        vortex.position = location
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let vortex = selectedVortex {
//            print("📍 Dropped vortex at: \(vortex.position)")
//        }
//        selectedVortex = nil
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        selectedVortex = nil
//    }
    
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
            marble.physicsBody?.collisionBitMask = 0xFFFFFFFF //1 << 1 //0xFFFFFFFF
            marbles.append(marble)
            addChild(marble)
        }
    }
    
//    func lockMarble(_ marble: SKSpriteNode, at position: CGPoint) {
//        marble.position = position
//        marble.physicsBody = nil // disable physics
//        marble.zPosition = 2
//        marble.color = .green
//        marble.colorBlendFactor = 0.6
//    }
    
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
        
//        // Lock the marble to the vortex
//        if let marble = marble, let vortex = vortex {
//            marble.physicsBody?.velocity = .zero
//            marble.physicsBody?.angularVelocity = 0
//            marble.physicsBody?.isDynamic = false
//            marble.position = vortex.position
//            print("🔒 Marble locked to vortex")
//        }
    }
        
    override func update(_ currentTime: TimeInterval) {
        if let data = motionManager.accelerometerData {
            let tiltX = data.acceleration.y
            let tiltY = data.acceleration.x
            physicsWorld.gravity = CGVector(dx: tiltX * -50, dy: tiltY * 50)
        }
        // Golf-hole style sink logic
        for marble in marbles {
            guard marble.physicsBody?.isDynamic == true else { continue }
            
            for vortex in vortexNodes {
                let dx = vortex.position.x - marble.position.x
                let dy = vortex.position.y - marble.position.y
                let distance = sqrt(dx*dx + dy*dy)
                
                if distance < 8 { // smaller radius means tighter "hole"
                    // Sink marble into vortex
                    marble.position = vortex.position
                    marble.physicsBody?.velocity = .zero
                    marble.physicsBody?.angularVelocity = 0
                    marble.physicsBody?.isDynamic = false
                    marble.zPosition = vortex.zPosition + 1
                    marble.setScale(0.8) // Optional visual scale down
                    marble.run(SKAction.fadeAlpha(to: 1.0, duration: 0.2))
                    print("⛳️ Marble sunk into vortex at \(vortex.position)")
                    break
                }
            }
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
//
//        // Optional: remove any sparks or effects
//        for child in children where child.name == "effect" {
//            child.removeFromParent()
//        }
//
//         //Spawn fresh marbles
//        spawnMarbles(count: targetPositions.count)
//    }
//}
