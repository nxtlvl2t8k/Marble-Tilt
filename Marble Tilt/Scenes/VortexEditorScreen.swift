//
//  VortexEditorScreen.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-12-01.
//


import SwiftUI
import SpriteKit

struct VortexEditorScreen: View {

    @Environment(\.dismiss) var dismiss
    let backgroundName: String
    let level: Int

    @State private var scene: EditorGameScene?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            if let scene = scene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            } else {
                ProgressView("Loading Editor…")
            }

            VStack(spacing: 12) {

                Button("Save") {
                    if let scene = scene {
                        //let points = scene.collectVortexPositions()
                        //saveToJSON(points)
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .onAppear { loadEditorScene() }
    }
}

// MARK: - Helper Functions
extension VortexEditorScreen {

    func loadEditorScene() {
        let newScene = EditorGameScene(size: UIScreen.main.bounds.size)
        newScene.scaleMode = .resizeFill

        newScene.configureForEditing { positions in
            saveToJSON(positions)
        }

        self.scene = newScene
    }

    func saveToJSON(_ positions: [CGPoint]) {
        let encoded = positions.map { ["x": $0.x, "y": $0.y] }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("vortex_level_\(level).json")

        do {
            let data = try JSONSerialization.data(withJSONObject: encoded, options: .prettyPrinted)
            try data.write(to: url)
            print("✅ Saved vortex positions to: \(url)")
        } catch {
            print("❌ Failed to save vortex layout: \(error)")
        }
    }
}
