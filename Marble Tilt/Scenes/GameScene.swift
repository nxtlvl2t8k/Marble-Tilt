//
//  GameScene2.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//
import SpriteKit
import CoreMotion

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
    var vortexNodes: [SKSpriteNode] = []
    var sunkMarbles: [SKNode] = []
    
    // Tutorial
    var tutorialMode: Bool = false
    var tutorialStage: TutorialStage = .tiltCircle
    private var tutorialCircle: SKShapeNode?
    private var tutorialMarble: SKSpriteNode?
    private var smileyFace: SKNode?
    
    // Callbacks
    var onTutorialStageCompleted: (() -> Void)?
    
    // MARK: - Callbacks
    var levelCompleted: (() -> Void)?

    // MARK: - Load Scene
    override func didMove(to view: SKView) {
        print("✅ GameScene Loaded")
        backgroundColor = .black
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        motionManager.startAccelerometerUpdates()
        
        // Background
        let bgName = tutorialMode ? "handshake" : "handshake" // Use real background image
        let background = SKSpriteNode(imageNamed: bgName)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        background.size = size
        addChild(background)
        
        if tutorialMode {
            startTutorial()
        } else {
            // Normal level
            spawnMarbles(count: 5)
            setupVortexes()
        }
    }
    
    // MARK: - Tutorial
    func startTutorial() {
        tutorialStage = .tiltCircle
        
        // Circle
        let radius: CGFloat = 40
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.position = CGPoint(x: size.width/2, y: size.height/2)
        circle.strokeColor = .red
        circle.lineWidth = 6
        addChild(circle)
        tutorialCircle = circle
        
        // Marble
        let marble = SKSpriteNode(imageNamed: "ballGrey")
        marble.size = CGSize(width: 24, height: 24)
        marble.position = CGPoint(x: size.width/2, y: size.height/2 + 200)
        marble.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        marble.physicsBody?.allowsRotation = true
        marble.physicsBody?.restitution = 0.6
        marble.physicsBody?.linearDamping = 0.4
        marble.physicsBody?.categoryBitMask = 1 << 0
        marble.physicsBody?.contactTestBitMask = 1 << 1
        addChild(marble)
        tutorialMarble = marble
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
        
        // Tutorial stage checks
        guard tutorialMode, let marble = tutorialMarble else { return }
        
        if tutorialMode, let marble = tutorialMarble {
            switch tutorialStage {
            case .tiltCircle:
                guard let circle = tutorialCircle else { break }
                
                let dx = marble.position.x - circle.position.x
                let dy = marble.position.y - circle.position.y
                let distance = hypot(dx, dy)
                
                let velocityX = marble.physicsBody?.velocity.dx ?? 0
                let velocityY = marble.physicsBody?.velocity.dy ?? 0
                let speed = sqrt(velocityX * velocityX + velocityY * velocityY)
                
                if distance < circle.frame.width / 2 && speed < 50 {
                    if circle.strokeColor != .green && circle.strokeColor != .yellow {
                        circle.strokeColor = .yellow // first feedback
                        
                        let waitAction = SKAction.wait(forDuration: 1.5)
                        let checkAction = SKAction.run { [weak self] in
                            guard let self = self else { return }
                            
                            let newDx = marble.position.x - circle.position.x
                            let newDy = marble.position.y - circle.position.y
                            let newDistance = hypot(newDx, newDy)
                            
                            let newVelocityX = marble.physicsBody?.velocity.dx ?? 0
                            let newVelocityY = marble.physicsBody?.velocity.dy ?? 0
                            let newSpeed = sqrt(newVelocityX * newVelocityX + newVelocityY * newVelocityY)
                            
                            if newDistance < circle.frame.width / 2 && newSpeed < 50 {
                                circle.strokeColor = .green
                                self.tutorialStage = .smileyFace
                                self.showNextTutorialStage()
                            } else {
                                circle.strokeColor = .red
                            }
                        }
                        
                        run(SKAction.sequence([waitAction, checkAction]))
                    }
                }
                
            case .smileyFace:
                for vortex in vortexNodes {
                    let dx = vortex.position.x - marble.position.x
                    let dy = vortex.position.y - marble.position.y
                    let distance = sqrt(dx*dx + dy*dy)
                    
                    let velocityX = marble.physicsBody?.velocity.dx ?? 0
                    let velocityY = marble.physicsBody?.velocity.dy ?? 0
                    let speed = sqrt(velocityX * velocityX + velocityY * velocityY)
                    
                    if distance < 6 && speed < 60 {
                        marble.physicsBody?.isDynamic = false
                        showNextStageButton()
                        tutorialStage = .completed
                    }
                }
                
            default: break
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

    // Call this when the current level is beaten:
    func completeLevel() {
        print("🏁 Level Completed")
        levelCompleted?()
    }
}
extension GameScene {
    func loadLevel(_ level: Int) {

        print("🔵 Loading level \(level)")

        removeAllChildren()
        removeAllActions()

        // Example: add your background
        if let bg = SKSpriteNode(imageNamed: "handshake") as SKSpriteNode? {
            bg.position = CGPoint(x: size.width/2, y: size.height/2)
            bg.zPosition = -10
            addChild(bg)
        }

        /// Example: load marbles / vortexes later
        // spawnMarbles(from: ...)
        // setupVortexes(positions: ...)
    }
}
