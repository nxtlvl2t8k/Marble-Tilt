//
//  LevelSelectView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-07.
//
import SwiftUI

struct LevelSelectView: View {
    @Binding var showLevel: Int?
    @Binding var showLevelSelect: Bool  // For back button
    
    @State private var tutorialCompleted = UserDefaults.standard.bool(forKey: "TutorialCompleted")
    @State private var showEditor = false

    let levels = [
        (id: 0, name: "Tutorial"),
        (id: 1, name: "Marbles"),
        (id: 2, name: "Golf")
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 20)], spacing: 20) {
                    ForEach(levels, id: \.id) { level in
                        LevelButton(levelName: level.name,
                                    unlocked: isUnlocked(level: level.id)) {
                            withAnimation {
                                showLevel = level.id
                                showLevelSelect = false
                            }
                        }
                    }
                }
                .padding()
            }
            
            SwiftUI.Button("Back") {
                if UserDefaults.standard.bool(forKey: "hasPurchasedEditor") {
                    showEditor = true
                } else {
                    print("Prompt user to buy editor feature")
                }
            }
            .buttonStyle(MainMenuButtonStyle())
            .padding(.bottom, 10)
            
            SwiftUI.Button("Back") {
                withAnimation { showLevelSelect = false }
            }
            .buttonStyle(MainMenuButtonStyle())
            .padding()
        }
        .sheet(isPresented: $showEditor) {
            if let bgImage = UIImage(named: "handshake") {
                //VortexEditorView(background: bgImage)
            } else {
                Text("No background image found")
            }
        }
        .navigationTitle("Select Level")
        .onAppear {
            tutorialCompleted = UserDefaults.standard.bool(forKey: "TutorialCompleted")
        }

        // MARK: - Level loading sheet
        .sheet(item: $showLevel) { level in
            GameView(
                level: level,
                onExit: {
                    showLevel = nil
                    showLevelSelect = true
                },
                onHoleCompleted: {
                    handleLevelCompletion(level: level)
                }
            )
        }
    }

    // MARK: - Unlock Logic
    private func handleLevelCompletion(level: Int) {
        // Tutorial special handling
        if level == 0 {
            UserDefaults.standard.set(true, forKey: "TutorialCompleted")
            UserDefaults.standard.set(1, forKey: "MaxLevelCompleted")
        }

        // Unlock next level
        let currentMax = UserDefaults.standard.integer(forKey: "MaxLevelCompleted")
        if level >= currentMax {
            UserDefaults.standard.set(level + 1, forKey: "MaxLevelCompleted")
        }

        // Close level and return to LevelSelect
        withAnimation {
            showLevel = nil
            showLevelSelect = true
        }
    }
    
    // MARK: - Unlock Logic
    private func isUnlocked(level: Int) -> Bool {
        switch level {
        case 0:
            return true
        case 1:
            return UserDefaults.standard.bool(forKey: "TutorialCompleted") // Marbles unlocked after tutorial
        default:
            let maxCompleted = UserDefaults.standard.integer(forKey: "MaxLevelCompleted")
            return level <= maxCompleted // sequential unlock for other levels
        }
    }
}


struct LevelButton: View {
    var levelName: String
    var unlocked: Bool
    var action: () -> Void

    var body: some View {
        Button(action: { if unlocked { action() } }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(unlocked ? Color.blue : Color.gray)
                    .frame(height: 80)
                if unlocked {
                    Text(levelName)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(!unlocked)
    }
}

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}
