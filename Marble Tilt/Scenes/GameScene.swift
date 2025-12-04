//
//  GameScene2.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//
import SpriteKit
import CoreMotion

enum LevelType: Int {
    case tutorial1 = 0
    case tutorial2 = 1
    case mainMarbles = 2
    case crush = 3
    case golf = 4
}

enum TutorialStage {
    case tiltCircle
    case smileyFace
    case completed
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Motion
    let motionManager = CMMotionManager()
    private var lastAcceleration: CMAcceleration?
    private var shakeThreshold: Double = 0.7
    
    // MARK: - Nodes
    var marbles: [SKSpriteNode] = []
    var tutorialMarbles: [SKSpriteNode] = []
    var tutorialCircles: [SKShapeNode] = []
    var vortexNodes: [SKSpriteNode] = []
    var sunkMarbles: [SKNode] = []
    
    // Tutorial
    var tutorialMode: Bool = false
    var tutorialStage: TutorialStage = .tiltCircle
    private var tutorialCircle: SKShapeNode?
    private var tutorialMarble: SKSpriteNode?
    private var smileyFace: SKNode?
    
    var highestUnlockedLevel: Int {
        get {
            UserDefaults.standard.integer(forKey: "highestUnlockedLevel")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "highestUnlockedLevel")
        }
    }
    
    // Callbacks
    var onTutorialStageCompleted: (() -> Void)?
    
    // MARK: - Callbacks
    var levelCompleted: (() -> Void)?
    
    // MARK: - Load Scene
    override func didMove(to view: SKView) {
        if highestUnlockedLevel < 1 {
            highestUnlockedLevel = 2
        }
        
        print("✅ GameScene Loaded")
        backgroundColor = .black
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        motionManager.startAccelerometerUpdates()
        
        // Background
        let background = SKSpriteNode(color: .black, size: size) // solid black background
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
    }
    
    // MARK: - Tutorial
    func startTutorial() {
        tutorialStage = .tiltCircle
        
        // Clean up old data
        vortexNodes.removeAll()
        tutorialMarbles.removeAll()
        tutorialCircles.removeAll()
        
        let safeMargin: CGFloat = 80
        let spawnTop: CGFloat = size.height - 120
        let spawnBottom: CGFloat = size.height / 2 + 120
        let minVortexDistance: CGFloat = 140
        
        var usedVortexPositions: [CGPoint] = []
        
        for i in 0..<3 {
            var centerPoint: CGPoint
            repeat {
                // ✅ RANDOM POSITION FOR EACH VORTEX
                let randomX = CGFloat.random(in: safeMargin...(size.width - safeMargin))
                let randomY = CGFloat.random(in: safeMargin...(size.height - safeMargin))
                centerPoint = CGPoint(x: randomX, y: randomY)
            } while !isFarEnough(from: centerPoint,
                                 others: usedVortexPositions,
                                 minDistance: minVortexDistance)
            
            usedVortexPositions.append(centerPoint)
            
            // Vortex
            let vortex = SKSpriteNode(imageNamed: "vortex")
            vortex.position = centerPoint
            vortex.setScale(0.6)
            vortex.zPosition = 1
            vortex.name = "vortex_\(i)"
            //            vortex.userData = ["locked": false]   // ✅ future-proof lock system
            addChild(vortex)
            vortexNodes.append(vortex)
            
            // Rotate animation
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 2)
            vortex.run(SKAction.repeatForever(rotate))
            
            // Circle
            let radius: CGFloat = 50
            let circle = SKShapeNode(circleOfRadius: radius)
            circle.position = centerPoint
            circle.strokeColor = .red
            circle.lineWidth = 6
            circle.zPosition = 2
            addChild(circle)
            tutorialCircles.append(circle)
            
            let pulseUp = SKAction.scale(to: 1.1, duration: 0.6)
            let pulseDown = SKAction.scale(to: 1.0, duration: 0.6)
            circle.run(SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown])))
            
            // ✅ RANDOM MARBLE SPAWN (SPREAD OUT ABOVE)
            let marbleX = CGFloat.random(in: safeMargin...(size.width - safeMargin))
            let marbleY = CGFloat.random(in: spawnBottom...spawnTop)
            
            // Marble
            let marble = SKSpriteNode(imageNamed: "ballGrey")
            marble.size = CGSize(width: 24, height: 24)
            marble.position = CGPoint(x: marbleX, y: marbleY)
            marble.physicsBody = SKPhysicsBody(circleOfRadius: 12)
            marble.physicsBody?.allowsRotation = true
            marble.physicsBody?.restitution = 0.6
            marble.physicsBody?.linearDamping = 0.4
            marble.physicsBody?.categoryBitMask = 1 << 0
            marble.physicsBody?.contactTestBitMask = 1 << 1
            //            marble.userData = [
            //                "canLockVortex": i == 0   // ✅ ONLY FIRST MARBLE CAN LOCK LATER
            //            ]
            addChild(marble)
            tutorialMarbles.append(marble)
            
            if i == 0 { tutorialCircle = circle }
        }
    }
    
    func showNextTutorialStage() {
        // Remove circle if exists
        tutorialCircle?.removeFromParent()
        tutorialCircle = nil
        
        // Add smiley face
        let face = SKNode()
        face.position = CGPoint(x: size.width/2, y: size.height/2)
        
        let eye1 = SKShapeNode(circleOfRadius: 10)
        eye1.position = CGPoint(x: -20, y: 20)
        eye1.fillColor = .black
        face.addChild(eye1)
        
        let eye2 = SKShapeNode(circleOfRadius: 10)
        eye2.position = CGPoint(x: 20, y: 20)
        eye2.fillColor = .black
        face.addChild(eye2)
        
        let mouth = SKShapeNode(rectOf: CGSize(width: 60, height: 10), cornerRadius: 5)
        mouth.position = CGPoint(x: 0, y: -20)
        mouth.fillColor = .black
        face.addChild(mouth)
        
        addChild(face)
        smileyFace = face
        
        // Add vortex in mouth
        let vortex = SKSpriteNode(imageNamed: "vortex")
        vortex.position = CGPoint(x: size.width/2, y: size.height/2 - 20)
        vortex.setScale(0.5)
        addChild(vortex)
        vortexNodes.append(vortex)
        
        // Reset marble position
        tutorialMarble?.position = CGPoint(x: size.width/2, y: size.height/2 + 200)
        tutorialMarble?.physicsBody?.isDynamic = true
    }
    
    func showNextStageButton() {
        // Remove any existing button
        childNode(withName: "nextStageButton")?.removeFromParent()
        
        let button = SKLabelNode(text: "Way to go! Next Stage")
        button.fontSize = 24
        button.fontColor = .white
        button.position = CGPoint(x: size.width/2, y: size.height/2 - 150)
        button.name = "nextStageButton"
        button.zPosition = 100
        addChild(button)
    }
        
    func isFarEnough(from point: CGPoint, others: [CGPoint], minDistance: CGFloat) -> Bool {
        for p in others {
            let dx = p.x - point.x
            let dy = p.y - point.y
            if sqrt(dx*dx + dy*dy) < minDistance {
                return false
            }
        }
        return true
    }
    
    // MARK: - Spawn Marbles
    func spawnMarbles(count: Int) {
        for _ in 0..<count {
            let marble = SKSpriteNode(imageNamed: "ballGrey")
            marble.size = CGSize(width: 24, height: 24)
            marble.position = CGPoint(x: CGFloat.random(in: 0...size.width),
                                      y: CGFloat.random(in: 0...size.height))
            marble.physicsBody = SKPhysicsBody(circleOfRadius: 12)
            marble.physicsBody?.restitution = 0.6
            marble.physicsBody?.friction = 0.1
            marble.physicsBody?.linearDamping = 0.4
            marble.physicsBody?.allowsRotation = true
            marble.physicsBody?.categoryBitMask = 1 << 0
            marbles.append(marble)
            addChild(marble)
        }
    }
    // MARK: - Spawn Marbles From JSON Count
    func spawnMarblesFromJSON() {
        let positions = LevelLoader.loadTargetPattern()   // ✅ same JSON as vortexes

        print("⚪️ Spawning \(positions.count) marbles from JSON count")

        for _ in positions {
            let marble = SKSpriteNode(imageNamed: "ballGrey")
            marble.size = CGSize(width: 24, height: 24)

            // ✅ Spawn from top, not random chaos
            let x = CGFloat.random(in: 80...(size.width - 80))
            let y = size.height - 120

            marble.position = CGPoint(x: x, y: y)

            marble.physicsBody = SKPhysicsBody(circleOfRadius: 12)
            marble.physicsBody?.restitution = 0.6
            marble.physicsBody?.friction = 0.1
            marble.physicsBody?.linearDamping = 0.4
            marble.physicsBody?.allowsRotation = true
            marble.physicsBody?.categoryBitMask = 1 << 0

            marbles.append(marble)
            addChild(marble)
        }
    }
    func setupVortexes() {
        // Example: single center vortex
        let vortex = SKSpriteNode(imageNamed: "vortex")
        vortex.position = CGPoint(x: size.width/2, y: size.height/2)
        vortex.setScale(0.5)
        addChild(vortex)
        vortexNodes.append(vortex)
    }
    
    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        // Tilt gravity
        if let data = motionManager.accelerometerData {
            let tiltX = data.acceleration.y
            let tiltY = data.acceleration.x
            physicsWorld.gravity = CGVector(dx: tiltX * -50, dy: tiltY * 50)
        }
        
        // 🛑 HARD BLOCK — tutorial logic is NEVER allowed unless explicitly enabled
        if !tutorialMode { return }

        guard let marble = tutorialMarble else { return }

        switch tutorialStage {
        case .tiltCircle:
            handleCircleStage(marble: marble)
        case .smileyFace:
            handleSmileyStage(marble: marble)
        default:
            break
        }
    }
    
    // MARK: - Circle Stage
    private func handleCircleStage(marble: SKSpriteNode) {
        guard let circle = tutorialCircle else { return }
        let maxAllowedSpeed: CGFloat = 50
        
        // Distance & speed
        let dx = marble.position.x - circle.position.x
        let dy = marble.position.y - circle.position.y
        let distance = hypot(dx, dy)
        let velocity = marble.physicsBody?.velocity ?? .zero
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        
        // Circle feedback
        if distance > circle.frame.width / 2 {
            circle.strokeColor = .red   // too far
        } else if speed > maxAllowedSpeed {
            circle.strokeColor = .yellow  // inside but moving too fast
        } else {
            circle.strokeColor = .green   // inside and slow enough
        }
        
        // Check for lock-in via vortex
        for vortex in vortexNodes {
            let dxV = vortex.position.x - marble.position.x
            let dyV = vortex.position.y - marble.position.y
            let distV = hypot(dxV, dyV)
            
            if distV < 12 && speed <= maxAllowedSpeed {
                // Lock marble
                marble.physicsBody?.isDynamic = false
                marble.position = vortex.position
                circle.strokeColor = .green
                
                // Proceed to next stage
                tutorialStage = .smileyFace
                showNextTutorialStage()
                showNextStageButton()
            }
        }
    }
    
    // MARK: - Smiley Stage
    private func handleSmileyStage(marble: SKSpriteNode) {
        let maxAllowedSpeed: CGFloat = 50
        
        for vortex in vortexNodes {
            let dx = vortex.position.x - marble.position.x
            let dy = vortex.position.y - marble.position.y
            let distance = hypot(dx, dy)
            let velocity = marble.physicsBody?.velocity ?? .zero
            let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
            
            // Optional: marble wiggle if too fast
            if distance < 20 && speed > maxAllowedSpeed {
                marble.run(SKAction.sequence([
                    SKAction.moveBy(x: CGFloat.random(in: -5...5),
                                    y: CGFloat.random(in: -5...5),
                                    duration: 0.1)
                ]))
            }
            
            // Lock-in if centered and slow
            if distance < 12 && speed <= maxAllowedSpeed {
                marble.physicsBody?.isDynamic = false
                marble.position = vortex.position
                
                tutorialStage = .completed
                showNextStageButton()
            }
        }
    }
    // MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        for node in nodesAtPoint {
            if node.name == "nextStageButton" {
                node.removeFromParent()
                onTutorialStageCompleted?()
            }
        }
    }
    
    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        // Add if needed for marbles/vortex interactions
    }
    
    func completeLevel(currentLevel: Int) {
        print("🏁 Level \(currentLevel) Completed")
        
        // Unlock next level
        let nextLevel = currentLevel + 1
        if nextLevel <= 4 {
            UserDefaults.standard.set(true, forKey: "level_\(nextLevel)_unlocked")
        }
        
        levelCompleted?()
    }
    
    func setupVortexesFromJSON() {
        let positions = LevelLoader.loadTargetPattern()

        for (i, point) in positions.enumerated() {
            let vortex = SKSpriteNode(imageNamed: "vortex")
            vortex.position = point
            vortex.setScale(0.6)
            vortex.zPosition = 1
            vortex.name = "vortex_\(i)"
            addChild(vortex)
            vortexNodes.append(vortex)

            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2)
            vortex.run(SKAction.repeatForever(rotate))
        }
    }
}

extension GameScene {
    func loadLevel(_ level: Int) {
        print("🔵 Loading level \(level)")
        
        removeAllChildren()
        removeAllActions()
        
        // Always reset tutorial state
        tutorialMode = false
        
        switch level {
        case LevelType.tutorial1.rawValue:
            tutorialMode = true
            startTutorial()
            
        case LevelType.tutorial2.rawValue:
            tutorialMode = true
            //startTutorial2() // create a new method for tutorial2
            
        case LevelType.mainMarbles.rawValue:
            print("✅ LOADING MAIN MARBLES FROM JSON")

            // ✅ HARD KILL tutorial
            tutorialMode = false
            tutorialStage = .completed
            tutorialCircle = nil
            tutorialMarble = nil
            smileyFace = nil
            tutorialMarbles.removeAll()
            tutorialCircles.removeAll()

            // ✅ CLEAR old level nodes
            vortexNodes.removeAll()
            marbles.removeAll()

            // ✅ BACKGROUND
            let bg = SKSpriteNode(imageNamed: "handshake")
            bg.position = CGPoint(x: size.width/2, y: size.height/2)
            bg.zPosition = -10
            addChild(bg)

            // ✅ REAL LEVEL LOAD
            setupVortexesFromJSON()
            spawnMarblesFromJSON()
            
        case LevelType.crush.rawValue:
            // Crush Level (you can customize)
            let bg = SKSpriteNode(imageNamed: "crushnightclub")
            bg.position = CGPoint(x: size.width/2, y: size.height/2)
            addChild(bg)
            
            spawnMarbles(count: 8)
            setupVortexes()
            
        case LevelType.golf.rawValue:
            let label = SKLabelNode(text: "Golf Level Coming Soon")
            label.position = CGPoint(x: size.width/2, y: size.height/2)
            addChild(label)
            
        default:
            print("⚠️ Unknown level")
        }
    }
}
