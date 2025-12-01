//
//  TutorialManager.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-28.
//

import SpriteKit
import Foundation

class TutorialManager {

    // MARK: - References
    weak var scene: GameScene?

    var marblePositions: [CGPoint]
    var vortexPositions: [CGPoint]

//    // Add this property
//    var customVortexPositions: [CGPoint]

    // MARK: - State
    var active = false
    var step: Step = .balanceCircle
//    var maxMarbleSpeed: CGFloat = 400.0
//    var tutorialCompleted: (() -> Void)?
    var completion: (() -> Void)?
    
    // Tutorial nodes
    private var tutorialCircle: SKShapeNode?
    private var vortexNodes: [VortexNode] = []
    
    enum Step: Int {
        case balanceCircle = 0
        case smileVortex = 1
        case complete = 2
    }

    // MARK: - Init
    init(scene: GameScene,
         marblePositions: [CGPoint],
         vortexPositions: [CGPoint],
         completion: @escaping () -> Void) {
        self.scene = scene
        self.marblePositions = marblePositions
        self.vortexPositions = vortexPositions
        self.completion = completion
    }

    // MARK: - Start Tutorial
    func startTutorial() {
        guard let scene = scene else { return }

        active = true
        scene.spawnMarbles(from: marblePositions)
        scene.setupVortexes(positions: vortexPositions)
        scene.messageLabel?.text = "Tutorial: Guide the marble!"
        
        startStep()
    }

    // MARK: - Start Step Logic
    func startStep() {
        guard let scene = scene else { return }

        switch step {

        // STEP 1 — Balance into a circle
        case .balanceCircle:
            tutorialCircle = SKShapeNode(circleOfRadius: 100)
            tutorialCircle?.position = CGPoint(x: scene.size.width/2,
                                               y: scene.size.height/2)
            tutorialCircle?.strokeColor = .green
            tutorialCircle?.lineWidth = 6
            tutorialCircle?.zPosition = 50
            
            if let circle = tutorialCircle {
                scene.addChild(circle)
            }
            showMessage("Tilt your iPad to guide the marble into the circle!")

        // STEP 2 — Smile vortex formation
        case .smileVortex:
            tutorialCircle?.removeFromParent()
            spawnSmileVortexes()
            showMessage("Now guide the marble into all the vortexes!")

        // STEP 3 — Finished!
        case .complete:
            active = false
            showMessage("Tutorial Complete! 🎉")
            completion?()
        }
    }

    // MARK: - Spawn smile vortex formation
    private func spawnSmileVortexes() {
        guard let scene = scene else { return }

        vortexNodes.forEach { $0.removeFromParent() }
        vortexNodes.removeAll()

        let center = CGPoint(x: scene.size.width/2, y: scene.size.height/2)

        let eyeOffsetX: CGFloat = 120
        let eyeOffsetY: CGFloat = 80
        let mouthRadius: CGFloat = 100
        let mouthAngles: [CGFloat] = [-.pi/4, -.pi/8, .pi/8, .pi/4]

        // Eyes
        let leftEye = VortexNode(position: CGPoint(x: center.x - eyeOffsetX,
                                                   y: center.y + eyeOffsetY))
        let rightEye = VortexNode(position: CGPoint(x: center.x + eyeOffsetX,
                                                    y: center.y + eyeOffsetY))

        vortexNodes.append(contentsOf: [leftEye, rightEye])

        // Mouth
        for angle in mouthAngles {
            let x = center.x + cos(angle) * mouthRadius
            let y = center.y - sin(angle) * mouthRadius - 50
            vortexNodes.append(VortexNode(position: CGPoint(x: x, y: y)))
        }

        for v in vortexNodes {
            scene.addChild(v)
        }
    }

    // MARK: - Marble Checking
    func checkMarble(_ marble: MarbleNode, sunkMarbles: inout [MarbleNode]) {
        guard active else { return }

        switch step {
        case .balanceCircle:
            if let circle = tutorialCircle {
                let distance = marble.position.distance(to: circle.position)
                if distance < 40 {    // in the circle
                    advanceStep()
                }
            }

        case .smileVortex:
            for vortex in vortexNodes {
                let dist = marble.position.distance(to: vortex.position)
                if dist < 6 {
                    sinkMarble(marble, into: vortex, sunkMarbles: &sunkMarbles)
                }
            }

            if sunkMarbles.count >= vortexNodes.count {
                advanceStep()
            }

        case .complete:
            break
        }
    }

    private func sinkMarble(_ marble: MarbleNode,
                            into vortex: VortexNode,
                            sunkMarbles: inout [MarbleNode]) {

        marble.position = vortex.position
        marble.physicsBody?.isDynamic = false

        if !sunkMarbles.contains(marble) {
            sunkMarbles.append(marble)
        }
    }

    // MARK: - Step Progression
    private func advanceStep() {
        step = Step(rawValue: step.rawValue + 1) ?? .complete
        startStep()
    }
    
    private func showMessage(_ text: String) {
        scene?.messageLabel?.text = text
    }
}

