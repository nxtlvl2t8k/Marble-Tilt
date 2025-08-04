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
        let scene = GameScene(size: CGSize(width: 1024, height: 768))
        scene.scaleMode = .aspectFill
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
