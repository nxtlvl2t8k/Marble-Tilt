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
            let tutorialVortexes = [CGPoint(x: 200, y: 200)]

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
