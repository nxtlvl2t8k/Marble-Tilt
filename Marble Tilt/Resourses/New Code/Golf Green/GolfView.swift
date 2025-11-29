//
//  GolfView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-10.
//
import SwiftUI
import SpriteKit

struct GolfView: View {
    var body: some View {
        SpriteView(scene: GolfScene(size: CGSize(width: 1024, height: 768)))
            .ignoresSafeArea()
    }
}
