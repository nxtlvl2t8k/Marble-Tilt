//
//  GameScene2.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    let motionManager = CMMotionManager()
    var marbles: [SKSpriteNode] = []
    var targetPositions: [CGPoint] = []
    var lockMarble: Set<CGPoint> = []
    var lockedMarbles: Set<CGPoint> = []
    var lockedVortexes: Set<SKNode> = []
    var vortexNodes: [SKSpriteNode] = []
    var sunkMarbles: [SKNode] = []
    private var selectedVortex: SKSpriteNode?
    private var lastAcceleration: CMAcceleration?
    private var shakeThreshold: Double = 0.7 // Adjust to taste
    
    var vortices: [CGPoint] = []

    static func loadLevel(levelNumber: Int) -> GameScene {
        let scene = GameScene(size: CGSize(width: 1024, height: 768))
        scene.scaleMode = .aspectFill
        scene.loadVortexData(levelNumber: levelNumber)
        return scene
    }

    func loadVortexData(levelNumber: Int) {
        if let url = Bundle.main.url(forResource: "level\(levelNumber)", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                if let array = try JSONSerialization.jsonObject(with: data) as? [[String: CGFloat]] {
                    vortices = array.compactMap { dict in
                        if let x = dict["x"], let y = dict["y"] {
                            return CGPoint(x: x, y: y)
                        }
                        return nil
                    }
                }
            } catch {
                print("Error loading vortex data: \(error)")
            }
        }
    }

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
        
        // 🔧 Use slightly smaller collision radius than image
        let bodyRadius = (vortex.size.width * 0.5) * 0.4
        vortex.physicsBody = SKPhysicsBody(circleOfRadius: bodyRadius)
        vortex.physicsBody?.isDynamic = false
        vortex.physicsBody?.categoryBitMask = 1 << 1
        vortex.physicsBody?.contactTestBitMask = 1 << 0 // detect marble proximity
        vortex.physicsBody?.collisionBitMask = 0 // ❌ NO collision — marble will pass through
        
        vortexNodes.append(vortex)
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
            marble.physicsBody?.contactTestBitMask = 1 << 1 // to detect vortex
            marble.physicsBody?.collisionBitMask = 1 << 0 //0xFFFFFFFF // collide only with other things (like frame)
            marbles.append(marble)
            addChild(marble)
        }
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
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let data = motionManager.accelerometerData {
            let acc = data.acceleration
            
            // Shake intensity logic
            if let last = lastAcceleration {
                let deltaX = acc.x - last.x
                let deltaY = acc.y - last.y
                let deltaZ = acc.z - last.z
                
                let shakeMagnitude = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
                
                if shakeMagnitude > shakeThreshold {
                    print("🤳 Shake detected! Magnitude: \(shakeMagnitude)")
                    resetAfterShake()
                }
                
            }
            
            lastAcceleration = acc
            
            // Gravity tilt (keep your existing code)
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
                
                let velocity = marble.physicsBody?.velocity ?? .zero
                  let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)

                  if distance < 6 && speed < 60 { // ⛳️ Only sink if slow and centered

                    // Sink marble into vortex
                    marble.position = vortex.position
                    marble.physicsBody?.velocity = .zero
                    marble.physicsBody?.angularVelocity = 0
                    marble.physicsBody?.isDynamic = false
                    marble.zPosition = vortex.zPosition + 1
                    marble.setScale(0.8) // Optional visual scale down
                    marble.run(SKAction.fadeAlpha(to: 1.0, duration: 0.2))
                    if let sprite = marble as? SKSpriteNode {
                        if !sunkMarbles.contains(sprite) {
                            sunkMarbles.append(sprite)
                        }
                    }
                    sunkMarbles.append(marble)
                    print("⛳️ Marble sunk into vortex at \(vortex.position)")
//                      print("⛳️ Marble vissually sunk (no loss)")
                      break
                }
            }
        }
    }
    
    func resetAfterShake() {
        // Reuse marbles
        for marble in marbles {
            // Reset physics body
            if marble.physicsBody == nil {
                marble.physicsBody = SKPhysicsBody(circleOfRadius: 12)
                marble.physicsBody?.restitution = 0.6
                marble.physicsBody?.friction = 0.1
                marble.physicsBody?.linearDamping = 0.4
                marble.physicsBody?.allowsRotation = true
                marble.physicsBody?.categoryBitMask = 1 << 0
                marble.physicsBody?.collisionBitMask = 1 << 0
            }

            marble.physicsBody?.isDynamic = true
            marble.physicsBody?.velocity = .zero
            marble.physicsBody?.angularVelocity = 0

            // Reset scale and position to bounce away
            marble.setScale(1.0)
            marble.alpha = 1.0

//            // Launch upward a bit
//            marble.position.y += 20
//            marble.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
//        }
        
        // Slight bounce to show shake effect
         marble.physicsBody?.applyImpulse(CGVector(dx: CGFloat.random(in: -30...30),
                                                   dy: CGFloat.random(in: 10...50)))
     }

        print("🔄 Reused \(marbles.count) marbles from vortex")
        sunkMarbles.removeAll()
        
        // Refresh vortex animations (optional)
        for vortex in vortexNodes {
            vortex.removeAllActions()
            vortex.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))

            // Optional: flash or wobble on reset
            let flash = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.1),
                SKAction.fadeAlpha(to: 1.0, duration: 0.1)
            ])
            vortex.run(SKAction.repeat(flash, count: 2))
        }

        print("🔄 Reset vortex and marble states after shake")
    }
    
//MARK: Edit and Move vortex
    ///DO NOT DELETE
    ///This is used to move vortex and get the co-ordinates.  Using marble_positions_handshake_scaled_ipad-2
//        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//            guard let touch = touches.first else { return }
//            let location = touch.location(in: self)
//    
//            for vortex in vortexNodes {
//                if vortex.contains(location) {
//                    selectedVortex = vortex
//                    break
//                }
//            }
//        }
//    
//        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//            guard let touch = touches.first, let vortex = selectedVortex else { return }
//            let location = touch.location(in: self)
//            vortex.position = location
//        }
//    
//        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//            if let vortex = selectedVortex {
//                print("📍 Dropped vortex at: \(vortex.position)")
//            }
//            selectedVortex = nil
//        }
//    
//        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//            selectedVortex = nil
//        }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }

        print("🤳 Device shaken. Checking to remove sunk marbles...")

        // Optional: Require minimum number of marbles to trigger
        if sunkMarbles.isEmpty {
            print("ℹ️ No sunk marbles to remove.")
            return
        }

        for marble in sunkMarbles {
            marble.removeFromParent()
        }

        print("🗑 Removed \(sunkMarbles.count) sunk marbles.")
        sunkMarbles.removeAll()
    }
}
