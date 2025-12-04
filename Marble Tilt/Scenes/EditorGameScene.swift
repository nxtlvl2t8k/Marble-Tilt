//
//  EditorGameScene.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-12-01.
//


import SpriteKit

class EditorGameScene: GameScene {

    private var saveHandler: (([CGPoint]) -> Void)?

    func configureForEditing(saveHandler: @escaping ([CGPoint]) -> Void) {
        //self.editingMode = true
        self.saveHandler = saveHandler
    }

//    func collectVortexPositions() -> [CGPoint] {
//        return VortexNode.map { $0.position }
//    }

//    func saveChanges() {
//        let positions = collectVortexPositions()
//        saveHandler?(positions)
//    }
}
