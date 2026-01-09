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
    @State private var completedLevels: Set<Int> = [0,1,2,3,4,5] // tutorial unlocked

    // Only 3 levels: tutorial, main marbles, golf (locked)
    let levels = [
        (id: 0, name: "Tutorial", unlocked: true),
        (id: 1, name: "Tutorial2", unlocked: true),
        (id: 2, name: "Main Marbles", unlocked: true),
//        (id: 2, name: "Main Marbles", unlocked: UserDefaults.standard.bool(forKey: "TutorialCompleted")),
        (id: 3, name: "Crush Nightclub", unlocked: false),
        (id: 4, name: "Golf", unlocked: false),
        (id: 5, name: "Skool", unlocked: false)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
//            Image("levelBackground")
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Select Level")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)

                ForEach(0..<levels.count, id: \.self) { level in
                    Button {
                        if completedLevels.contains(level) {
                            levelToLoad = level
                            showGame = true
                        }
                    } label: {
                        HStack {
                            Text(levels[level].name)
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
