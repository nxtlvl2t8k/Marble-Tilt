//
//  GameScene.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2021-11-06.
//

import CoreMotion
import SpriteKit

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case ball1 = 3
    case ball2 = 4
    case vortex1 = 5
    case vortex2 = 6
    case vortex3 = 7
    case vortex4 = 8
    case vortex5 = 9
    case vortex6 = 10
    case vortex7 = 11
    case vortex8 = 12
    case finish = 64
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    var count: Int = 0
    var motionManager: CMMotionManager!
    var player: SKSpriteNode!
//    var ball1: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    var isGameOver = false
    var isSpot1Taken = false
    var isSpot2Taken = false
    var isSpot3Taken = false
    var isSpot4Taken = false
    var isSpot5Taken = false
    var isSpot6Taken = false
    var isSpot7Taken = false
    var isSpot8Taken = false
    var scoreLabel: SKLabelNode!

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
        loadLevel()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
            createPlayer()
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }

    override func update(_ currentTime: TimeInterval) {
    #if targetEnvironment(simulator)
        if let currentTouch = lastTouchPosition {
            let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
    #else
        if let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
    #endif
    }

    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else {
            fatalError("Could not find level1.txt in the app bundle.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level1.txt from the app bundle.")
        }
        
        let lines = levelString.components(separatedBy: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) - 32)
                
                if letter == "x" {
                    let node = SKSpriteNode(imageNamed: "block")
                    node.position = position
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
                    node.physicsBody?.isDynamic = false
                    addChild(node)
                }else if letter == "b" {
                    let node = SKSpriteNode(imageNamed: "ballGrey")
                    node.position = position
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.categoryBitMask = CollisionTypes.ball1.rawValue
                    node.physicsBody?.isDynamic = true
                    addChild(node)
                } else if letter == "v"  {
                    count = count + 1
                    if "vortex\(count)" == "vortex1" {
                        let node = SKSpriteNode(imageNamed: "vortex")
                        node.name = "vortex\(count)"
                        NSLog("vortex\(count)")
                        node.position = position
                        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 8)
                        node.physicsBody?.isDynamic = false
                        node.physicsBody?.categoryBitMask = CollisionTypes.vortex1.rawValue
                        node.physicsBody?.collisionBitMask = 0
                        addChild(node)
                    }
                    if "vortex\(count)" == "vortex2" {
                        let node = SKSpriteNode(imageNamed: "vortex")
                        node.name = "vortex\(count)"
                        NSLog("vortex\(count)")
                        node.position = position
                        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 8)
                        node.physicsBody?.isDynamic = false
                        node.physicsBody?.categoryBitMask = CollisionTypes.vortex2.rawValue
                        node.physicsBody?.collisionBitMask = 0
                        addChild(node)
                    }
                    if "vortex\(count)" == "vortex3" {
                        let node = SKSpriteNode(imageNamed: "vortex")
                        node.name = "vortex\(count)"
                        NSLog("vortex\(count)")
                        node.position = position
                        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 8)
                        node.physicsBody?.isDynamic = false
                        node.physicsBody?.categoryBitMask = CollisionTypes.vortex2.rawValue
                        node.physicsBody?.collisionBitMask = 0
                        addChild(node)
                    }
                    if "vortex\(count)" == "vortex4" {
                        let node = SKSpriteNode(imageNamed: "vortex")
                        node.name = "vortex\(count)"
                        NSLog("vortex\(count)")
                        node.position = position
                        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 8)
                        node.physicsBody?.isDynamic = false
                        node.physicsBody?.categoryBitMask = CollisionTypes.vortex2.rawValue
                        node.physicsBody?.collisionBitMask = 0
                        addChild(node)
                    }
                    if "vortex\(count)" == "vortex5" {
                        let node = SKSpriteNode(imageNamed: "vortex")
                        node.name = "vortex\(count)"
                        NSLog("vortex\(count)")
                        node.position = position
                        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 8)
                        node.physicsBody?.isDynamic = false
                        node.physicsBody?.categoryBitMask = CollisionTypes.vortex2.rawValue
                        node.physicsBody?.collisionBitMask = 0
                        addChild(node)
                    }
                    if "vortex\(count)" == "vortex6" {
                        let node = SKSpriteNode(imageNamed: "vortex")
                        node.name = "vortex\(count)"
                        NSLog("vortex\(count)")
                        node.position = position
                        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 8)
                        node.physicsBody?.isDynamic = false
                        node.physicsBody?.categoryBitMask = CollisionTypes.vortex2.rawValue
                        node.physicsBody?.collisionBitMask = 0
                        addChild(node)
                    }
                    if "vortex\(count)" == "vortex7" {
                        let node = SKSpriteNode(imageNamed: "vortex")
                        node.name = "vortex\(count)"
                        NSLog("vortex\(count)")
                        node.position = position
                        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 8)
                        node.physicsBody?.isDynamic = false
                        node.physicsBody?.categoryBitMask = CollisionTypes.vortex2.rawValue
                        node.physicsBody?.collisionBitMask = 0
                        addChild(node)
                    }
                    if "vortex\(count)" == "vortex8" {
                        let node = SKSpriteNode(imageNamed: "vortex")
                        node.name = "vortex\(count)"
                        NSLog("vortex\(count)")
                        node.position = position
                        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 8)
                        node.physicsBody?.isDynamic = false
                        node.physicsBody?.categoryBitMask = CollisionTypes.vortex2.rawValue
                        node.physicsBody?.collisionBitMask = 0
                        addChild(node)
                    }
                } else if letter == "s"  {

                } else if letter == "f"  {

                } else if letter == " " {
                    // this is an empty space – do nothing!
                } else {
                    fatalError("Unknown level letter: \(letter)")
                }
            }
        }
    }
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "ballRed")
        player.position = CGPoint(x: 396, y: 472)
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5

        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.vortex1.rawValue | CollisionTypes.vortex2.rawValue | CollisionTypes.vortex3.rawValue | CollisionTypes.vortex4.rawValue | CollisionTypes.vortex5.rawValue | CollisionTypes.vortex6.rawValue | CollisionTypes.finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue | CollisionTypes.player.rawValue | CollisionTypes.ball1.rawValue
        addChild(player)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            ball1Collided(with: nodeB)
        } else if nodeB == player {
            ball1Collided(with: nodeA)
        }
    }
    
    func ball1Collided(with node: SKNode) {
        //New balls fall into vortex and they shou;d bounce off
        if node.name == "ballRed" {
            player.physicsBody?.isDynamic = false
            //            isGameOver = true
            score += 1
        } else if node.name == "vortex8" {
            count = 8
            if "vortex\(count)" == "vortex8" {
                if !isSpot8Taken {
                    player.physicsBody?.isDynamic = false
                    self.isSpot8Taken = true
                    score += 1
                    
                    let move = SKAction.move(to: node.position, duration: 0.25)
                    //            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
                    //            let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([move]) //, scale, remove])
                    
                    player.run(sequence) { [weak self] in
                        self?.createPlayer()
                        //                self?.isGameOver = false
                    }
                }
            }
        } else if node.name == "vortex7" {
            count = 7
            if "vortex\(count)" == "vortex7" {
                if !isSpot7Taken {
                    player.physicsBody?.isDynamic = false
                    self.isSpot7Taken = true
                    score += 1
                    
                    let move = SKAction.move(to: node.position, duration: 0.25)
                    //            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
                    //            let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([move]) //, scale, remove])
                    
                    player.run(sequence) { [weak self] in
                        self?.createPlayer()
                        //                self?.isGameOver = false
                    }
                }
            }
        } else if node.name == "vortex6" {
            count = 6
            if "vortex\(count)" == "vortex6" {
                if !isSpot6Taken {
                    player.physicsBody?.isDynamic = false
                    self.isSpot6Taken = true
                    score += 1
                    
                    let move = SKAction.move(to: node.position, duration: 0.25)
                    //            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
                    //            let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([move]) //, scale, remove])
                    
                    player.run(sequence) { [weak self] in
                        self?.createPlayer()
                        //                self?.isGameOver = false
                    }
                }
            }
        } else if node.name == "vortex5" {
            count = 5
            if "vortex\(count)" == "vortex5" {
                if !isSpot5Taken {
                    player.physicsBody?.isDynamic = false
                    self.isSpot5Taken = true
                    score += 1
                    
                    let move = SKAction.move(to: node.position, duration: 0.25)
                    //            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
                    //            let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([move]) //, scale, remove])
                    
                    player.run(sequence) { [weak self] in
                        self?.createPlayer()
                        //                self?.isGameOver = false
                    }
                }
            }
        } else if node.name == "vortex4" {
            count = 4
            if "vortex\(count)" == "vortex4" {
                if !isSpot4Taken {
                    player.physicsBody?.isDynamic = false
                    self.isSpot4Taken = true
                    score += 1
                    
                    let move = SKAction.move(to: node.position, duration: 0.25)
                    //            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
                    //            let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([move]) //, scale, remove])
                    
                    player.run(sequence) { [weak self] in
                        self?.createPlayer()
                        //                self?.isGameOver = false
                    }
                }
            }
        } else if node.name == "vortex3" {
            count = 3
            if "vortex\(count)" == "vortex3" {
                if !isSpot3Taken {
                    player.physicsBody?.isDynamic = false
                    self.isSpot3Taken = true
                    score += 1
                    
                    let move = SKAction.move(to: node.position, duration: 0.25)
                    //            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
                    //            let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([move]) //, scale, remove])
                    
                    player.run(sequence) { [weak self] in
                        self?.createPlayer()
                        //                self?.isGameOver = false
                    }
                }
            }
        } else if node.name == "vortex2" {
            count = 2
            if "vortex\(count)" == "vortex2" {
                if !isSpot2Taken {
                    player.physicsBody?.isDynamic = false
                    self.isSpot2Taken = true
                    score += 1
                    
                    let move = SKAction.move(to: node.position, duration: 0.25)
                    //            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
                    //            let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([move]) //, scale, remove])
                    
                    player.run(sequence) { [weak self] in
                        self?.createPlayer()
                        //                self?.isGameOver = false
                    }
                }
            }
        } else if node.name == "vortex1" {
            count = 1
            if "vortex\(count)" == "vortex1" {
                if !isSpot1Taken {
                    player.physicsBody?.isDynamic = false
                    self.isSpot1Taken = true
                    score += 1
                    
                    let move = SKAction.move(to: node.position, duration: 0.25)
                    //            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
                    //            let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([move]) //, scale, remove])
                    
                    player.run(sequence) { [weak self] in
                        self?.createPlayer()
                        //                self?.isGameOver = false
                    }
                }
            }
        }
        
    }
    func shake() {
        print("Shake")

        
    }
}
