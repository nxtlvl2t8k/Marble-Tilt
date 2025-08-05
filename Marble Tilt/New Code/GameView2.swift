//
//  GameView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//


import SwiftUI
import SpriteKit

struct GameView2: View {
    var scene: SKScene {
        let scene = GameScene2()
        scene.size = CGSize(width: 1024, height: 768)
        scene.scaleMode = .resizeFill
        return scene
    }
    
    @State private var gameSceneRef: GameScene2?
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .onAppear {
                // Save reference to the scene
                if let skView = UIApplication.shared.windows.first?.rootViewController?.view.subviews.compactMap({ $0 as? SKView }).first,
                   let currentScene = skView.scene as? GameScene2 {
                    gameSceneRef = currentScene
                }
            }
        
//        Button("🔁 Reset Game") {
//            gameSceneRef?.resetGame()
//        }
//        .padding()
    }
}
