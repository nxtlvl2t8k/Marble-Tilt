//
//  TutorialManager.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-28.
//

import SpriteKit
import Foundation

//final class TutorialManager {
//
//    // MARK: - References
//    weak var scene: GameScene?
//
//    var marblePositions: [CGPoint]
//    var vortexPositions: [CGPoint]
//
////    // Add this property
////    var customVortexPositions: [CGPoint]
//
//    // Tutorial nodes
//    private var tutorialCircle: SKShapeNode?
//    private var vortexNodes: [VortexNode] = []
//    private var smileVortexes: [VortexNode] = []
//    
//    private var completed: () -> Void
//
//    private var runningTask: Task<Void, Never>?
//
//    // MARK: - State
//    var active = false
//    var step: Step = .balanceCircle
////    var maxMarbleSpeed: CGFloat = 400.0
////    var tutorialCompleted: (() -> Void)?
//    var completion: (() -> Void)?
//
//    enum Step: Int {
//        case balanceCircle = 0
//        case smileVortex = 1
//        case completed = 2
//    }
//
//    // MARK: - Init
//    init(scene: GameScene,
//         marblePositions: [CGPoint],
//         vortexPositions: [CGPoint],
//         completion: @escaping () -> Void) {
//        
//        self.scene = scene
//        self.marblePositions = marblePositions
//        self.vortexPositions = vortexPositions
//        self.completed = completion
//    }
//
//    // MARK: - Start Tutorial
//    func startTutorial() {
//        guard let scene = scene else { return }
//
//        // Cancel old runs
//        runningTask?.cancel()
//
//        runningTask = Task { [weak self] in
//            guard let self else { return }
//            
//            active = true
//            scene.spawnMarbles(from: marblePositions)
//            scene.setupVortexes(positions: vortexPositions)
//            scene.messageLabel?.text = "Tutorial: Guide the marble!"
//            
//            // Run tutorial script
//            await runTutorial()
//        }
//    }
//
//    // ---------------------------------------------------------
//    // MARK: - Step Script
//    // ---------------------------------------------------------
//    private func runTutorial() async {
//        guard let scene = scene else { return }
//
//        // STEP 1 — balance into circle
//        let circle = await showCircle()
//        tutorialCircle = circle
//        await showMessage("Tilt your iPad to guide the marble into the circle!")
//        await waitForMarbleInside(circle, threshold: 40)
//
//        tutorialCircle?.removeFromParent()
//        tutorialCircle = nil
//
//        // STEP 2 — smile vortex
//        smileVortexes = await spawnSmileVortexes()
//        await showMessage("Now guide the marble into all the vortexes!")
//        await waitForAllMarblesSunkInto(smileVortexes)
//
//        // FINISH
//        await showMessage("Tutorial Complete! 🎉")
//
//        // Slight delay for UX
//        try? await Task.sleep(for: .seconds(1.0))
//
//        completed()
//    }
//    // ---------------------------------------------------------
//    // MARK: - Step Helpers
//    // ---------------------------------------------------------
//
//    private func showCircle() async -> SKShapeNode {
//        guard let scene = scene else { return SKShapeNode() }
//
//        let circle = SKShapeNode(circleOfRadius: 100)
//        circle.position = CGPoint(x: scene.size.width/2,
//                                  y: scene.size.height/2)
//        circle.strokeColor = .green
//        circle.lineWidth = 6
//        circle.zPosition = 50
//        scene.addChild(circle)
//
//        return circle
//    }
//
//    private func spawnSmileVortexes() async -> [VortexNode] {
//        guard let scene = scene else { return [] }
//
//        let center = CGPoint(x: scene.size.width/2,
//                             y: scene.size.height/2)
//
//        let eyeOffsetX: CGFloat = 120
//        let eyeOffsetY: CGFloat = 80
//        let mouthRadius: CGFloat = 100
//        let mouthAngles: [CGFloat] = [-.pi/4, -.pi/8, .pi/8, .pi/4]
//
//        var nodes: [VortexNode] = []
//
//        // Eyes
//        nodes.append(VortexNode(position: CGPoint(x: center.x - eyeOffsetX,
//                                                  y: center.y + eyeOffsetY)))
//        nodes.append(VortexNode(position: CGPoint(x: center.x + eyeOffsetX,
//                                                  y: center.y + eyeOffsetY)))
//
//        // Mouth
//        for angle in mouthAngles {
//            let x = center.x + cos(angle) * mouthRadius
//            let y = center.y - sin(angle) * mouthRadius - 50
//            nodes.append(VortexNode(position: CGPoint(x: x, y: y)))
//        }
//
//        for v in nodes { scene.addChild(v) }
//
//        return nodes
//    }
//
//    private func showMessage(_ text: String) async {
//        scene?.messageLabel?.text = text
//    }
//
//    // ---------------------------------------------------------
//    // MARK: - Await Conditions
//    // ---------------------------------------------------------
//
//    private func waitForMarbleInside(_ circle: SKShapeNode,
//                                     threshold: CGFloat) async {
//
//        guard let scene = scene else { return }
//
//        while true {
//            if let marble = scene.marbles.first {
//                let dist = marble.position.distance(to: circle.position)
//                if dist < threshold {
//                    break
//                }
//            }
//
//            try? await Task.sleep(for: .milliseconds(50))
//        }
//    }
//
//    private func waitForAllMarblesSunkInto(_ vortexes: [VortexNode]) async {
//        guard let scene = scene else { return }
//
//        var sunk: Set<MarbleNode> = []
//
//        while sunk.count < vortexes.count {
//
//            if let marble = scene.marbles.first {
//                for v in vortexes {
//                    if marble.position.distance(to: v.position) < 6 {
//                        sunk.insert(marble)
//                        marble.physicsBody?.isDynamic = false
//                        marble.position = v.position
//                    }
//                }
//            }
//
//            try? await Task.sleep(for: .milliseconds(50))
//        }
//    }
//}
