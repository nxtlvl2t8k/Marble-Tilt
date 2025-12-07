//
//  MarblesApp.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//
import SwiftUI

@main
struct MarblesApp: App {
    @State private var showGame = false

    var body: some Scene {
        WindowGroup {
            if showGame {
                GameView(
                    level: 1,
                    onExit: {
                        showGame = false   // ✅ BACK WORKS
                    },
                    onHoleCompleted: {
                        print("Hole completed!")
                    }
                )
            } else {
                MainMenuView(startGame: {
                    showGame = true      // ✅ FORWARD WORKS
                })
            }
        }
    }
}
