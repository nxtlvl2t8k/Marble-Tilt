//
//  VortexEditorView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-29.
//


import SwiftUI
import SpriteKit

struct VortexEditorView: View {
    @Environment(\.dismiss) var dismiss
    
    var background: UIImage
    @State private var scene: VortexEditorScene?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let scene = scene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            } else {
                Text("Loading...")
            }
            
            VStack {
                Button(action: saveLayout) {
                    Text("Save")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: { dismiss() }) {
                    Text("Close")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .onAppear {
            let editor = VortexEditorScene(size: UIScreen.main.bounds.size, background: background)
            self.scene = editor
        }
    }
    
    func saveLayout() {
        guard let scene = scene else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("vortex_layout.json")
        scene.saveLayout(to: url)
    }
}
