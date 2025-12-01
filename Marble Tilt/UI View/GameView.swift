//
//  GameView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//


import SwiftUI
import SpriteKit
import CoreGraphics

struct GameView: View {
    var level: Int
    var onExit: () -> Void
    var onHoleCompleted: () -> Void

    // Keep a Scene reference so we can size it to the view if needed
    @State private var scene: GameScene = GameScene(size: CGSize(width: 1024, height: 768))

    var body: some View {
        ZStack(alignment: .topLeading) {
            // SpriteKit view: use .resizeFill so the scene fills the SwiftUI view
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    configureScene()
                }
            GameOverlayView(viewModel: GameOverlayViewModel(scene: scene, paidFeatureUnlocked: false))

            // Floating back button (game-like)
            VStack {
                HStack {
                    Button(action: {
                        onExit()
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                            .padding(8)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.top, 40)
            .padding(.leading, 8)
        }
    }
    
    // MARK: - Scene Configuration
    private func configureScene() {
        switch level {
        case 0: // Tutorial
            let tutorialMarbles = [CGPoint(x: 100, y: 300)]
            let tutorialVortexes = [CGPoint(x: 500, y: 300)]

            scene.tutorialManager = TutorialManager(
                scene: scene,
                marblePositions: tutorialMarbles,
                vortexPositions: tutorialVortexes
            ) {
                // Tutorial completed: spawn main marbles
                let mainMarbles = LevelLoader.loadMarbles(file: "marble_positions_handshake_scaled_ipad")
                scene.spawnMarbles(from: mainMarbles)

                // Notify SwiftUI
                onHoleCompleted()
            }

            scene.tutorialManager?.startTutorial()

        default:
            // Normal level: load from JSON
            let marblePositions = LevelLoader.loadMarbles(file: "level\(level)_marbles")
            let vortexPositions = LevelLoader.loadVortexes(file: "level\(level)_vortexes")

            if marblePositions.isEmpty {
                scene.spawnRandomMarbles(count: 5)
            } else {
                scene.spawnMarbles(from: marblePositions)
            }

            scene.setupVortexes(positions: vortexPositions)
        }
    }
}

//    class TutorialScene: GameScene {
//
//        private var tutorialCompleted = false
//        var onTutorialCompleted: (() -> Void)?
//        
//        override func didMove(to view: SKView) {
//            super.didMove(to: view)
//
//            // Mark this as a tutorial level so GameScene skips normal level logic
//            self.isTutorialLevel = true
//
//            // Clear all existing level content GameScene may have loaded
//            vortexNodes.removeAll()
//            marbles.removeAll()
//            sunkMarbles.removeAll()
//
//            setupTutorial()
//        }
//
//        private func setupTutorial() {
//
//            // Custom vortex positions for tutorial
//            let vortexPositions = [
//                CGPoint(x: size.width * 0.75, y: size.height * 0.60),
//                CGPoint(x: size.width * 0.55, y: size.height * 0.40),
//                CGPoint(x: size.width * 0.85, y: size.height * 0.35)
//            ]
//
//            // IMPORTANT: This matches the correct TutorialManager initializer
//            self.tutorialManager = TutorialManager(
//                scene: self,
//                customVortexPositions: vortexPositions,
//                completion: { [weak self] in
//                    self?.handleTutorialCompletion()
//                }
//            )
//
//            tutorialManager?.startStep()
//            spawnTutorialMarble()
//        }
//
//        private func spawnTutorialMarble() {
//            let marble = MarbleNode()
//            marble.position = CGPoint(x: size.width * 0.25, y: size.height / 2)
//            marbles.append(marble)
//            addChild(marble)
//        }
//
//        // MARK: - Completion
//
//        private func handleTutorialCompletion() {
//            tutorialCompleted = true
//            UserDefaults.standard.set(true, forKey: "TutorialCompleted")
//
//            // Remove tutorial marble
//            marbles.forEach { $0.removeFromParent() }
//            marbles.removeAll()
//
//            // Notify SwiftUI to dismiss this scene
//            onTutorialCompleted?()
//        }
//
//        // MARK: - Update Loop
//
//        override func update(_ currentTime: TimeInterval) {
//            super.update(currentTime)
//
//            guard let tutorial = tutorialManager else { return }
//
//            for marble in marbles where marble.physicsBody?.isDynamic == true {
//                tutorial.checkMarble(
//                    marble,
//                    sunkMarbles: &sunkMarbles
//                )
//            }
//        }
//    }
//
//    // Tutorial level
//    let tutorialMarbles = [CGPoint(x: 100, y: 300)]
//    let tutorialVortexes = [CGPoint(x: 500, y: 300)]
//
//    scene.tutorialManager = TutorialManager(
//        scene: scene,
//        marblePositions: tutorialMarbles,
//        vortexPositions: tutorialVortexes
//    ) {
//        print("Tutorial complete!")
//        // Load main marbles JSON now
//        let mainMarbles = LevelLoader.loadMarbles(file: "marble_positions_handshake_scaled_ipad")
//        scene.spawnMarbles(from: mainMarbles)
//    }
//    scene.tutorialManager?.startTutorial()
//}
