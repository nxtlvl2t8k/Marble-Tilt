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
            
            Button("Back") {
                withAnimation { showLevelSelect = false }
            }
            .buttonStyle(MainMenuButtonStyle())
            .padding()
        }
        .navigationTitle("Select Level")
        .onAppear {
            tutorialCompleted = UserDefaults.standard.bool(forKey: "TutorialCompleted")
        }
    }
    
    // MARK: - Unlock Logic
    private func isUnlocked(level: Int) -> Bool {
        switch level {
        case 0:
            return true // Tutorial always unlocked
        case 1:
            return UserDefaults.standard.bool(forKey: "TutorialCompleted") // Marbles unlocked after tutorial
        default:
            let maxCompleted = UserDefaults.standard.integer(forKey: "MaxLevelCompleted")
            return level <= maxCompleted + 1 // sequential unlock for other levels
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
