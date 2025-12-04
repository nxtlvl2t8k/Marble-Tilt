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

    @State private var scene = GameScene(size: CGSize(width: 1024, height: 768))

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
            scene.scaleMode = .resizeFill

//            // ✅ Level completion callback
//            scene.levelCompleted = {
//                onHoleCompleted()
//            }

            // ✅ LOAD THE ACTUAL LEVEL NOW
            scene.loadLevel(2)
        }
    }
}
