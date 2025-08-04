//
//  MarbleGameView2.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//


import SwiftUI
import SpriteKit

struct MarbleGameView2: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController2 {
        return GameViewController2()
    }

    func updateUIViewController(_ uiViewController: GameViewController2, context: Context) {
        // No-op
    }
}
