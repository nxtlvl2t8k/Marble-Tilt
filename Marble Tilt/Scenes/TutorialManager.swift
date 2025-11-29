//
//  TutorialManager.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-28.
//

import SpriteKit

class TutorialManager {
    
    enum Step: Int {
        case balanceCircle = 0
        case singleVortex
        case multiVortex
        case complete
    }
    
    var step: Step = .balanceCircle
    var active: Bool = true
    weak var scene: SKScene?
    
    var tutorialCircle: SKShapeNode?
    var messageLabel: SKLabelNode?
    
    // Threshold for vortex capture
    let maxMarbleSpeed: CGFloat = 60
    
    init(scene: SKScene) {
        self.scene = scene
        setupLabel()
    }
    
    private func setupLabel() {
        guard let scene = scene else { return }
        messageLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        messageLabel?.fontSize = 28
        messageLabel?.fontColor = .white
        messageLabel?.position = CGPoint(x: scene.size.width/2, y: scene.size.height - 100)
        messageLabel?.zPosition = 50
        if let label = messageLabel { scene.addChild(label) }
    }
    
    func showMessage(_ text: String) { messageLabel?.text = text }
    
    func startStep() {
        guard let scene = scene else { return }
        switch step {
        case .balanceCircle:
            tutorialCircle = SKShapeNode(circleOfRadius: 100)
            tutorialCircle?.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
            tutorialCircle?.strokeColor = .green
            tutorialCircle?.lineWidth = 6
            tutorialCircle?.zPosition = 10
            if let circle = tutorialCircle { scene.addChild(circle) }
            showMessage("Tilt your iPad to guide the marble into the circle!")
            
        case .singleVortex:
            tutorialCircle?.removeFromParent()
            showMessage("Tilt your iPad to move the marble into the vortex!")
            
        case .multiVortex:
            showMessage("Tilt to reach all vortexes. Slow down to catch them!")
            
        case .complete:
            active = false
            showMessage("Tutorial Complete! 🎉")
        }
    }
    
    func advanceStep() {
        step = Step(rawValue: step.rawValue + 1) ?? .complete
        startStep()
    }
    
    // Tutorial collision check
    func checkMarble(_ marble: MarbleNode, vortices: [VortexNode], sunkMarbles: inout [MarbleNode]) {
        guard active else { return }
        
        switch step {
        case .balanceCircle:
            if let circle = tutorialCircle {
                let distance = marble.position.distance(to: circle.position)
                if distance < 100 {
                    showMessage("Perfect! You balanced the marble!")
                    advanceStep()
                }
            }
            
        case .singleVortex, .multiVortex:
            for vortex in vortices where vortex.parent != nil {
                let distance = marble.position.distance(to: vortex.position)
                let speed = marble.velocityMagnitude()
                
                if distance < 6 {
                    if speed > maxMarbleSpeed {
                        flashMarbleTooFast(marble)
                    } else {
                        marble.position = vortex.position
                        marble.physicsBody?.isDynamic = false
                        if !sunkMarbles.contains(marble) { sunkMarbles.append(marble) }
                        
                        // Advance tutorial if conditions met
                        if step == .singleVortex || (step == .multiVortex && sunkMarbles.count == vortices.count) {
                            advanceStep()
                        }
                    }
                }
            }
        default: break
        }
    }
    
    private func flashMarbleTooFast(_ marble: MarbleNode) {
        marble.run(SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.1),
            SKAction.wait(forDuration: 0.2),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
        ]))
        showMessage("Too fast! Slow down to enter the vortex.")
    }
}
