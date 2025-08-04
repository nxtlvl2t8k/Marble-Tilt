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

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .onAppear {
                // Add other startup logic if needed
            }
    }
}
