//
//  TutorialScene.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-29.
//

import SpriteKit
import CoreMotion

class TutorialScene: GameScene {

    private var tutorialCompleted = false
    var onTutorialCompleted: (() -> Void)?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        // Mark this as a tutorial level so GameScene skips normal level logic
        self.isTutorialLevel = true

        // Clear all existing level content GameScene may have loaded
        vortexNodes.removeAll()
        marbles.removeAll()
        sunkMarbles.removeAll()

        setupTutorial()
    }

    private func setupTutorial() {

        // Custom vortex positions for tutorial
        let vortexPositions = [
            CGPoint(x: size.width * 0.75, y: size.height * 0.60),
            CGPoint(x: size.width * 0.55, y: size.height * 0.40),
            CGPoint(x: size.width * 0.85, y: size.height * 0.35)
        ]

        // IMPORTANT: This matches the correct TutorialManager initializer
        self.tutorialManager = TutorialManager(
            scene: self,
            customVortexPositions: vortexPositions,
            completion: { [weak self] in
                self?.handleTutorialCompletion()
            }
        )

        tutorialManager?.startStep()
        spawnTutorialMarble()
    }

    private func spawnTutorialMarble() {
        let marble = MarbleNode()
        marble.position = CGPoint(x: size.width * 0.25, y: size.height / 2)
        marbles.append(marble)
        addChild(marble)
    }

    // MARK: - Completion

    private func handleTutorialCompletion() {
        tutorialCompleted = true
        UserDefaults.standard.set(true, forKey: "TutorialCompleted")

        // Remove tutorial marble
        marbles.forEach { $0.removeFromParent() }
        marbles.removeAll()

        // Notify SwiftUI to dismiss this scene
        onTutorialCompleted?()
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        guard let tutorial = tutorialManager else { return }

        for marble in marbles where marble.physicsBody?.isDynamic == true {
            tutorial.checkMarble(
                marble,
                sunkMarbles: &sunkMarbles
            )
        }
    }
}
