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
    @State private var scene: GameScene = GameScene(size: CGSize(width: 1024, height: 768))

    var body: some View {
        ZStack(alignment: .topLeading) {
            // SpriteKit view: use .resizeFill so the scene fills the SwiftUI view
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
//                    scene.configureFor(level: level)
//                    scene.holeCompletedCallback = {
//                        onHoleCompleted()
//                    }
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
    }
}

//    var scene: SKScene {
//        let scene = GameScene()
//        scene.size = CGSize(width: 1024, height: 768)
//        scene.scaleMode = .resizeFill
//        return scene
//    }
    
//    @State private var gameSceneRef: GameScene?
    
//    var body: some View {
//        SpriteView(scene: scene)
//            .ignoresSafeArea()
//            .onAppear {
//                // Save reference to the scene
//                if let skView = UIApplication.shared.windows.first?.rootViewController?.view.subviews.compactMap({ $0 as? SKView }).first,
//                   let currentScene = skView.scene as? GameScene {
//                    gameSceneRef = currentScene
//                }
//            }
        
//        Button("🔁 Reset Game") {
//            gameSceneRef?.resetGame()
//        }
//        .padding()
//    }
//}
