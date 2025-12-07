//
//  GameView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//


import SwiftUI
import SpriteKit

struct GameView: View {
    let level: Int
    let onExit: () -> Void
    let onHoleCompleted: () -> Void

    @State private var scene: GameScene = {
        let newScene = GameScene(size: CGSize(width: 1024, height: 768))
        newScene.scaleMode = .resizeFill
        return newScene
    }()

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: { onExit() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                    }
                    Spacer()
                }
                .padding()

                Spacer()
            }
        }
        .onAppear {
            // ✅ PROPERLY LOAD AND DISPLAY THE LEVEL
            let loadedScene = GameScene.loadLevel(levelNumber: level)
            loadedScene.scaleMode = .resizeFill

//            // ✅ If you re-enable this later
//            loadedScene.levelCompleted = {
//                onHoleCompleted()
//            }

            scene = loadedScene   // ✅ THIS IS THE KEY FIX
        }
    }
}
