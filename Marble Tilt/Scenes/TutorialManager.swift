//
//  TutorialManager.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-28.
//

import SpriteKit
import Foundation

enum TutorialStep {
    case intro
    case singleVortex
    case multiVortex
}

class TutorialManager {
    weak var scene: GameScene?
    var customVortexPositions: [CGPoint]?
    
    var active = false
    var step: TutorialStep = .intro
    var maxMarbleSpeed: CGFloat = 400.0
    var completion: (() -> Void)?
    
    init(scene: GameScene, customVortexPositions: [CGPoint]? = nil, completion: @escaping () -> Void) {
        self.scene = scene
        self.customVortexPositions = customVortexPositions
        self.completion = completion
    }
    
    func startStep() {
        active = true
        setupVortexes()
        showMessage("Tutorial started! Place the marble into the vortex slowly.")
    }
    
    private func setupVortexes() {
        guard let scene = scene else { return }
        
        // Remove old vortexes
        scene.vortexNodes.forEach { $0.removeFromParent() }
        scene.vortexNodes.removeAll()
        
        let positions = customVortexPositions ?? LevelLoader.loadVortexPositions(level: 1)
        
        for pos in positions {
            let vortex = VortexNode(position: pos)
            scene.vortexNodes.append(vortex)
            scene.addChild(vortex)
        }
    }
    
    func checkMarble(_ marble: MarbleNode, vortices: [VortexNode], sunkMarbles: inout [MarbleNode]) {
        guard active else { return }
        
        for vortex in vortices {
            let distance = marble.position.distance(to: vortex.position)
            let speed = marble.velocityMagnitude()
            
            if distance < 6 {
                if speed > maxMarbleSpeed {
                    marble.run(SKAction.sequence([
                        SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.1),
                        SKAction.wait(forDuration: 0.2),
                        SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
                    ]))
                    showMessage("Too fast! Slow down to enter the vortex.")
                } else {
                    marble.position = vortex.position
                    marble.physicsBody?.isDynamic = false
                    if !sunkMarbles.contains(marble) { sunkMarbles.append(marble) }
                    advanceStepIfNeeded(vortexCount: vortices.count, sunkCount: sunkMarbles.count)
                }
            }
        }
    }
    
    private func advanceStepIfNeeded(vortexCount: Int, sunkCount: Int) {
        switch step {
        case .intro:
            step = .singleVortex
            showMessage("Good! Try sinking the marble in the vortex again.")
        case .singleVortex:
            if sunkCount >= 1 {
                step = .multiVortex
                showMessage("Now try multiple vortexes!")
            }
        case .multiVortex:
            if sunkCount >= vortexCount {
                showMessage("Tutorial complete!")
                completion?()
                active = false
            }
        }
    }
    
    func showMessage(_ message: String) {
        // For now, print to console. Replace with UI overlay if needed.
        print("💡 Tutorial: \(message)")
    }
}
