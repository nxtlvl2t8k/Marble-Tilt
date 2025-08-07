//
//  GameView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//


import SwiftUI
import SpriteKit

struct GameView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 1024, height: 768)
        scene.scaleMode = .resizeFill
        return scene
    }
    
    @State private var gameSceneRef: GameScene?
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .onAppear {
                // Save reference to the scene
                if let skView = UIApplication.shared.windows.first?.rootViewController?.view.subviews.compactMap({ $0 as? SKView }).first,
                   let currentScene = skView.scene as? GameScene {
                    gameSceneRef = currentScene
                }
            }
        
//        Button("🔁 Reset Game") {
//            gameSceneRef?.resetGame()
//        }
//        .padding()
    }
}
