//
//  GameScene2.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//
// GameScene.swift
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Motion
    let motionManager = MotionManager.shared
    let maxLockSpeed: CGFloat = 60   // only lock if slow enough
    let lockDistance: CGFloat = 12   // only lock if marble near center

    // MARK: - State
    var marbles: [MarbleNode] = []
    var vortexes: [VortexNode] = []
    var sunkMarbles: [MarbleNode] = []

    // Tutorial wiring (kept minimal)
    var tutorialManager = TutorialManager()

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        print("✅ GameScene didMove")
        backgroundColor = .black

        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self

        motionManager.startUpdates()

        // Scene background (low z so game objects sit above)
        let bg = SKSpriteNode(imageNamed: "handshake")
        bg.position = CGPoint(x: size.width/2, y: size.height/2)
        bg.zPosition = -100
        bg.size = size
        addChild(bg)

        // Do not spawn gameplay here. Call loadLevel(_:) externally to populate.
    }

    // MARK: - Level loading
    func loadLevel(_ level: Int) {
        print("🔵 loadLevel:", level)

        removeAllLevelNodes()

        switch level {
        case 0:
            // Let TutorialManager take over
            tutorialManager.start(in: self)
        case 1, 2:
            // Main marbles levels (example: 2 is default main)
            let resourceName = "marble_positions_handshake_scaled_ipad"
            LevelLoader.shared.loadPattern(named: resourceName) { [weak self] positions in
                guard let s = self else { return }
                s.setupVortexes(from: positions)
//                s.spawnMarbles(count: positions.count)
                // TEST: limit marbles for debug
                let spawnCount = min(positions.count, 10)
                s.spawnMarbles(count: spawnCount)

            }
        case 3:
            let resourceName = "marble_positions_crush" // placeholder
            LevelLoader.shared.loadPattern(named: resourceName) { [weak self] positions in
                guard let s = self else { return }
                s.setupVortexes(from: positions)
                s.spawnMarbles(count: positions.count)
            }
        case 4:
            // Golf placeholder
            let label = SKLabelNode(text: "Golf Level Coming Soon")
            label.position = CGPoint(x: size.width/2, y: size.height/2)
            addChild(label)
        default:
            print("⚠️ Unknown level")
        }
    }

    private func removeAllLevelNodes() {
        for m in marbles { m.removeFromParent() }
        for v in vortexes { v.removeFromParent() }
        marbles.removeAll()
        vortexes.removeAll()
        sunkMarbles.removeAll()
        physicsWorld.removeAllJoints()
    }

    // MARK: - Vortex & Marble population
    func setupVortexes(from positions: [CGPoint]) {
        for (i, p) in positions.enumerated() {
            let v = VortexNode(index: i)
            v.position = p
            // prevent physics stopping marble
            v.physicsBody = SKPhysicsBody(circleOfRadius: v.size.width * 0.4)
            v.physicsBody?.isDynamic = false
            v.physicsBody?.categoryBitMask = 1 << 1
            v.physicsBody?.contactTestBitMask = 1 << 0 // detect marble proximity
            v.physicsBody?.collisionBitMask = 0 // ❌ NO collision — marble will pass through
            addChild(v)
            vortexes.append(v)
        }
     }

    func spawnMarbles(count: Int) {
        let spawnTop = size.height - 150
        let spawnBottom = size.height / 2 + 50
        for _ in 0..<count {
            let x = CGFloat.random(in: 80...(size.width - 80))
            let y = CGFloat.random(in: spawnBottom...spawnTop)
            let marble = MarbleNode()
            marble.position = CGPoint(x: x, y: y)
            addChild(marble)
            marbles.append(marble)
        }
        print("⚪️ Spawned \(marbles.count) marbles")
    }
    
    // MARK: - Physics contact (preferred sink)
    func didBegin(_ contact: SKPhysicsContact) {
        guard let a = contact.bodyA.node, let b = contact.bodyB.node else { return }
        
        var marble: MarbleNode?
        var vortex: VortexNode?
        
        if let m = a as? MarbleNode { marble = m }
        if let m = b as? MarbleNode { marble = m }
        if let v = a as? VortexNode { vortex = v }
        if let v = b as? VortexNode { vortex = v }
        
        if let marble = marble, let vortex = vortex {
            // do NOT sink on fast collision
            let velocity = marble.physicsBody?.velocity ?? .zero
            let speed = hypot(velocity.dx, velocity.dy)
            
            if speed <= maxLockSpeed {
                sink(marble: marble, into: vortex)
//            } else {
//                // slow it down so update fallback can handle
//                marble.physicsBody?.velocity.dx *= 0.5
//                marble.physicsBody?.velocity.dy *= 0.5
            }
        }
    }
    
    // MARK: - Update fallback sink
    override func update(_ currentTime: TimeInterval) {
        // tilt gravity
        if let acc = motionManager.lastAcceleration {
            physicsWorld.gravity = CGVector(dx: acc.y * -50, dy: acc.x * 50)
        }
                
        // fallback: close + slow marbles
        for marble in marbles where marble.physicsBody?.isDynamic == true {
            if sunkMarbles.contains(marble) { continue }
            for vortex in vortexes {
                let dist = marble.position.distance(to: vortex.position)
                let vel = marble.physicsBody?.velocity ?? .zero
                let speed = hypot(vel.dx, vel.dy)
                
                if dist < lockDistance && speed < maxLockSpeed {
                    sink(marble: marble, into: vortex)
                    break
                }
            }
        }
    }
    
    // MARK: - Sink helper
    func sink(marble: MarbleNode, into vortex: VortexNode) {
        guard !sunkMarbles.contains(marble) else { return }

        let target = vortex.position
        let diff = CGVector(dx: target.x - marble.position.x,
                            dy: target.y - marble.position.y)
        marble.position.x += diff.dx * 0.2
        marble.position.y += diff.dy * 0.2
        marble.physicsBody?.velocity = .zero
        marble.physicsBody?.angularVelocity = 0
        marble.physicsBody?.isDynamic = false

        // Snap to center
        marble.position = vortex.position
        marble.zPosition = vortex.zPosition + 1
        marble.setScale(0.8)

        sunkMarbles.append(marble)
        print("⛳️ Locked: \(sunkMarbles.count)")
    }
    
    // MARK: - Shake reset
    func resetAfterShake() {
        for marble in marbles {
            marble.resetPhysics()
            marble.applyImpulse(CGVector(dx: CGFloat.random(in: -30...30), dy: CGFloat.random(in: 10...50)))
        }
        for v in vortexes { v.resetAnimation() }
        sunkMarbles.removeAll()
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        if sunkMarbles.isEmpty { print("ℹ️ No sunk marbles") ; return }
        for m in sunkMarbles { m.removeFromParent() }
        sunkMarbles.removeAll()
    }
}
