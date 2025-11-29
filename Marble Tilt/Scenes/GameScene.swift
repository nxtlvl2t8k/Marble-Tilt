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
    
    var marbles: [MarbleNode] = []
    var vortexNodes: [VortexNode] = []
    var sunkMarbles: [MarbleNode] = []
    
    var tutorial: TutorialManager?
    var tutorialMarble: MarbleNode?
    
    // MARK: - Edit Mode
    var editModeEnabled = false     // toggle this later for paid feature
    private var selectedVortex: VortexNode?
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        startTiltUpdates()
        startTutorial()
    }
    
    // MARK: - Tutorial
    func startTutorial(customLayoutURL: URL? = nil) {
        var positions: [CGPoint]? = nil

        if let url = customLayoutURL {
            do {
                let data = try Data(contentsOf: url)
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Double]] {
                    positions = json.compactMap { dict in
                        if let x = dict["x"], let y = dict["y"] {
                            return CGPoint(x: x, y: y)
                        }
                        return nil
                    }
                }
            } catch {
                print("❌ Failed to load custom layout: \(error)")
            }
        }
        
        tutorial = TutorialManager(scene: self, customVortexPositions: positions) { [weak self] in
            print("Tutorial finished! Starting level 1...")
            self?.tutorialMarble?.removeFromParent()
            self?.tutorialMarble = nil
            self?.startLevel1()
        }
        
        tutorial?.startStep()
        
        // Spawn tutorial marble
        let marble = MarbleNode()
        marble.position = CGPoint(x: size.width * 0.2, y: size.height / 2)
        addChild(marble)
        tutorialMarble = marble
    }
    
    // MARK: - Marble spawning
    func spawnMarbles(count: Int) {
        for _ in 0..<count {
            let marble = MarbleNode()
            marble.position = CGPoint(x: CGFloat.random(in: 0...size.width),
                                      y: CGFloat.random(in: 0...size.height))
            marbles.append(marble)
            addChild(marble)
        }
    }
    
    func setupVortexes() {
        let positions = LevelLoader.loadVortexPositions(level: 1)
        for pos in positions {
            let vortex = VortexNode(position: pos)
            vortexNodes.append(vortex)
            addChild(vortex)
        }
    }
    
    // MARK: - Tilt / Motion
    func startTiltUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1/60
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, _) in
            guard let self = self, let motion = motion else { return }
            let tiltX = motion.gravity.y
            let tiltY = motion.gravity.x
            self.physicsWorld.gravity = CGVector(dx: tiltX * -50, dy: tiltY * 50)
        }
    }
    
    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        for marble in marbles {
            guard marble.physicsBody?.isDynamic == true else { continue }
            
            tutorial?.checkMarble(marble, vortices: vortexNodes, sunkMarbles: &sunkMarbles)
            
            for vortex in vortexNodes {
                let distance = marble.position.distance(to: vortex.position)
                let speed = marble.velocityMagnitude()
                
                if distance < 6 {
                    if tutorial?.active == true && speed > tutorial?.maxMarbleSpeed ?? 400 {
                        marble.run(SKAction.sequence([
                            SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.1),
                            SKAction.wait(forDuration: 0.2),
                            SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
                        ]))
                        tutorial?.showMessage("Too fast! Slow down to enter the vortex.")
                    } else {
                        marble.position = vortex.position
                        marble.physicsBody?.isDynamic = false
                        if !sunkMarbles.contains(marble) { sunkMarbles.append(marble) }
                    }
                }
            }
        }
    }
    
    // MARK: - Placeholder
    func startLevel1() {
        // spawn normal level marbles or vortexes
        print("Starting level 1...")
    }
    
    // MARK: - Edit Mode Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editModeEnabled, let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        for vortex in vortexNodes {
            if vortex.contains(location) {
                selectedVortex = vortex
                break
            }
        }
        
        // Tap empty space to add a new vortex
        if selectedVortex == nil {
            let newVortex = VortexNode(position: location)
            vortexNodes.append(newVortex)
            addChild(newVortex)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editModeEnabled, let touch = touches.first, let vortex = selectedVortex else { return }
        let location = touch.location(in: self)
        vortex.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editModeEnabled else { return }
        selectedVortex = nil
    }
    
    // MARK: - Save Layout
    func saveVortexLayout(to url: URL) {
        let dictArray = vortexNodes.map { ["x": Double($0.position.x), "y": Double($0.position.y)] }
        do {
            let data = try JSONSerialization.data(withJSONObject: dictArray, options: .prettyPrinted)
            try data.write(to: url)
            print("✅ Vortex layout saved to \(url)")
        } catch {
            print("❌ Failed to save layout: \(error)")
        }
    }
}
