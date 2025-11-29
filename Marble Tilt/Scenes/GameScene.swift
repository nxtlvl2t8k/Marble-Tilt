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
    
    var tutorial: TutorialManager!
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        tutorial = TutorialManager(scene: self)
        tutorial.startStep()
        
        spawnMarbles(count: 5)
        setupVortexes()
        startTiltUpdates()
    }
   
    func spawnTutorialMarbles() {
        // Clear existing
        marbles.forEach { $0.removeFromParent() }
        marbles.removeAll()
        
        let count = tutorial.step == .multiVortex ? vortexNodes.count : 1
        for _ in 0..<count {
            let marble = MarbleNode()
            marble.position = CGPoint(x: size.width/2, y: size.height/2 - 200)
            marbles.append(marble)
            addChild(marble)
        }
    }

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
    
    override func update(_ currentTime: TimeInterval) {
        for marble in marbles {
            guard marble.physicsBody?.isDynamic == true else { continue }
            tutorial.checkMarble(marble, vortices: vortexNodes, sunkMarbles: &sunkMarbles)
            for vortex in vortexNodes {
                let distance = marble.position.distance(to: vortex.position)
                let speed = marble.velocityMagnitude()
                
                if distance < 6 {
                    if tutorial.active && speed > tutorial.maxMarbleSpeed {
                        marble.run(SKAction.sequence([
                            SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.1),
                            SKAction.wait(forDuration: 0.2),
                            SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
                        ]))
                        tutorial.showMessage("Too fast! Slow down to enter the vortex.")
                    } else {
                        marble.position = vortex.position
                        marble.physicsBody?.isDynamic = false
                        if !sunkMarbles.contains(marble) { sunkMarbles.append(marble) }
                        if tutorial.step == .singleVortex || (tutorial.step == .multiVortex && sunkMarbles.count == vortexNodes.count) {
                            tutorial.advanceStep()
                        }
                    }
                }
            }
        }
    }
}
