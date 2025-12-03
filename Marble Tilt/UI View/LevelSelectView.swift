//
//  LevelSelectView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-07.
//
import SwiftUI

struct LevelSelectView: View {
    @Environment(\.dismiss) var dismiss
    
//    @Binding var showLevel: Int?
//    @Binding var showLevelSelect: Bool  // For back button
    
    @State private var showGame = false
    @State private var levelToLoad: Int? = nil
//    @State private var tutorialCompleted = UserDefaults.standard.bool(forKey: "TutorialCompleted")
//    @State private var showEditor = false
    @State private var completedLevels: Set<Int> = [0] // tutorial unlocked

    // Only 3 levels: tutorial, main marbles, golf (locked)
    let levels = [
        (id: 0, name: "Tutorial", unlocked: true),
        (id: 1, name: "Main Marbles", unlocked: UserDefaults.standard.bool(forKey: "TutorialCompleted")),
        (id: 2, name: "Golf", unlocked: false)
    ]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
//            Image("levelBackground")
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Select Level")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)

                ForEach(0..<5) { level in
                    Button(action: {
                        if completedLevels.contains(level) {
                            levelToLoad = level
                            showGame = true
                        }
                    }) {
                        HStack {
                            Text(level == 0 ? "Tutorial" : "Level \(level)")
                                .foregroundColor(.white)
                                .font(.title3)
                            Spacer()
                            Image(systemName: completedLevels.contains(level)
                                  ? "lock.open"
                                  : "lock")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                    }
                }

                Spacer()

                Button("Back") { dismiss() }
                    .padding(.bottom, 30)
            }
            .padding(.horizontal, 30)
        }
        .fullScreenCover(isPresented: $showGame) {
            GameView(
                level: levelToLoad ?? 0,
                onExit: {
                    showGame = false
                },
                onHoleCompleted: {
                    unlockNextLevel()
                }
            )
        }
    }

    private func unlockNextLevel() {
        guard let level = levelToLoad else { return }
        completedLevels.insert(level + 1)
    }
}
