//
//  GameView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//


import SwiftUI
import SpriteKit

struct GameView: View {
    var level: Int
    var onExit: () -> Void
    var onHoleCompleted: () -> Void

    // Keep a Scene reference so we can size it to the view if needed
    @State private var scene: GameScene? // = GameScene(size: CGSize(width: 1024, height: 768))

    var body: some View {
        ZStack(alignment: .topLeading) {
            // SpriteKit view: use .resizeFill so the scene fills the SwiftUI view
            if let scene = scene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
                    .onAppear {
                        scene.holeCompletedCallback = {
                            onHoleCompleted()
                        }
                    }
//            SpriteView(scene: scene)
//                .ignoresSafeArea()
//                .onAppear {
//                    // Create the right scene for this level
//                    scene = GameScene.loadLevel(levelNumber: level)
//                    scene.scaleMode = .resizeFill
////                    scene.configureFor(level: level)
////                    scene.holeCompletedCallback = {
////                        onHoleCompleted()
////                    }
                }

            // Floating back button (game-like)
            VStack {
                HStack {
                    Button(action: {
                        // optionally stop scene updates/accelerometer
                        //scene.stopMotionUpdates
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
        .onAppear {
            // Create scene once view appears
            let newScene = GameScene.loadLevel(levelNumber: level)
            newScene.scaleMode = .resizeFill
            scene = newScene
        }
    }
}
