//
//  LevelSelectView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-07.
//
import SwiftUI
///Not used yet
///
struct LevelSelectView: View {
    @Binding var showLevel: Int?
    let levels = [1, 2, 3, 4, 5]
    let unlockedLevels = 5 // 2
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 20)], spacing: 20) {
                ForEach(levels, id: \.self) { level in
                    LevelButton(level: level, unlocked: level <= unlockedLevels) {
                        withAnimation {
                            showLevel = level
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Select Pattern")
    }
}

struct LevelButton: View {
    var level: Int
    var unlocked: Bool
    var action: () -> Void

    var body: some View {
        Button(action: { if unlocked { action() } }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(unlocked ? Color.blue : Color.gray)
                    .frame(height: 80)
                if unlocked {
                    Text(label(for: level))
                        .font(.title2)
                        .foregroundColor(.white)
//                    Text(level == 1 ? "Marbles" : "Golf")
//                        .font(.largeTitle)
//                        .foregroundColor(.white)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(!unlocked)
    }

    private func label(for level: Int) -> String {
        switch level {
        case 1: return "Handshake"
        case 2: return "Smile"
        case 3: return "Elephant"
        case 4: return "Sailboat"
        default: return "Level \(level)"
        }
    }
}
