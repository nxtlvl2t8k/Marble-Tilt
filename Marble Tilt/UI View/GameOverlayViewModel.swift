//
//  GameOverlayViewModel.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-29.
//


import Foundation
import SpriteKit

class GameOverlayViewModel: ObservableObject {
    @Published var showUnlockAlert: Bool = false
    var scene: GameScene
    var paidFeatureUnlocked: Bool = false // change to true to unlock

    init(scene: GameScene, paidFeatureUnlocked: Bool = false) {
        self.scene = scene
        self.paidFeatureUnlocked = paidFeatureUnlocked
    }

    func toggleEditingMode() {
        if scene.editingMode {
            scene.disableEditingMode()
        } else {
            scene.enableEditingMode()
        }
    }
}
