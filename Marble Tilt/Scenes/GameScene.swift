//
//  GameScene2.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Properties
    var marbles: [MarbleNode] = []
    var vortexNodes: [VortexNode] = []
    var sunkMarbles: [SKNode] = []

    private var selectedVortex: VortexNode?

    // Loaded from LevelLoader
    var targetPositions: [CGPoint] = []

    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        print("✅ GameScene Loaded")

        backgroundColor = .black

        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        // Start motion manager
        MotionManager.shared.start()

        // Load level data (JSON)
        targetPositions = LevelLoader.loadTargetPattern()

        // Add vortex nodes
        for pos in targetPositions {
            let vortex = VortexNode.create(at: pos)
            vortexNodes.append(vortex)
            addChild(vortex)
        }

        // Background image
        let background = SKSpriteNode(imageNamed: "handshake.jpeg")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        background.size = size
        addChild(background)

        // Spawn marbles
        for _ in 0..<targetPositions.count {
            let marble = MarbleNode.createRandom(in: self)
            marbles.append(marble)
            addChild(marble)
        }
    }

    // MARK: - Collisions
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node

        var marble: SKNode?
        var vortex: SKNode?

        if nodeA?.name == "marble" && nodeB?.name == "vortex" {
            marble = nodeA
            vortex = nodeB
        } else if nodeB?.name == "marble" && nodeA?.name == "vortex" {
            marble = nodeB
            vortex = nodeA
        }

        // collision is handled in update() with sink logic
    }

    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {

        // Tilt movement
        if let acc = MotionManager.shared.currentAcceleration() {
            physicsWorld.gravity = CGVector(dx: acc.y * -50, dy: acc.x * 50)
        }

        // Detect shake
        if MotionManager.shared.isShakeDetected() {
            resetAfterShake()
        }

        // Sinking marbles
        for marble in marbles {
            guard marble.physicsBody?.isDynamic == true else { continue }

            for vortex in vortexNodes {
                let dx = vortex.position.x - marble.position.x
                let dy = vortex.position.y - marble.position.y
                let distance = sqrt(dx*dx + dy*dy)

                let vel = marble.physicsBody?.velocity ?? .zero
                let speed = sqrt(vel.dx*vel.dx + vel.dy*vel.dy)

                if distance < 6 && speed < 60 {
                    // Sink
                    marble.position = vortex.position
                    marble.physicsBody?.velocity = .zero
                    marble.physicsBody?.angularVelocity = 0
                    marble.physicsBody?.isDynamic = false
                    marble.zPosition = vortex.zPosition + 1
                    marble.setScale(0.8)

                    if !sunkMarbles.contains(marble) {
                        sunkMarbles.append(marble)
                    }

                    print("⛳️ Marble sunk at \(vortex.position)")
                    break
                }
            }
        }
    }

    // MARK: - Shake Reset
    func resetAfterShake() {
        print("🔄 Reset triggered by shake")

        for marble in marbles {
            if marble.physicsBody == nil {
                marble.addPhysics()
            }

            marble.physicsBody?.isDynamic = true
            marble.physicsBody?.velocity = .zero
            marble.physicsBody?.angularVelocity = 0
            marble.setScale(1.0)

            // Bounce effect
            marble.physicsBody?.applyImpulse(
                CGVector(dx: CGFloat.random(in: -30...30),
                         dy: CGFloat.random(in: 10...50))
            )
        }

        sunkMarbles.removeAll()

        // Reset vortex animations
        for vortex in vortexNodes {
            vortex.refreshAnimation()
        }

        print("🔄 Reset complete")
    }

    // MARK: - Shaking removal
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }

        if sunkMarbles.isEmpty {
            print("ℹ️ No sunk marbles")
            return
        }

        for m in sunkMarbles {
            m.removeFromParent()
        }

        print("🗑 Removed \(sunkMarbles.count) marbles")
        sunkMarbles.removeAll()
    }
}
