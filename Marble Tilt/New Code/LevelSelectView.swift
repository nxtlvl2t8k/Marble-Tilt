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
    let levels = [1, 2]
    let unlockedLevels = 1 // 2
    
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
        .navigationTitle("Select Level")
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
                    Text(level == 1 ? "Marbles" : "Golf")
                        .font(.largeTitle)
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
