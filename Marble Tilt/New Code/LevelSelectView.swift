//
//  LevelSelectView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-07.
//
import SwiftUI

//struct LevelSelectView: View {
//    
//    let levels = [1] // Only Level 1 for now //= Array(1...30)
//    let unlockedLevels = 10
//    
//    var body: some View {
//        ScrollView {
//            LazyVGrid(columns: [GridItem(.flexible(), spacing: 20)], spacing: 20) {
//                ForEach(levels, id: \.self) { level in
//                    NavigationLink {
//                        MainMarbleView(showLevel: true) {
//                    } label: {
//                        LevelButton(level: level, unlocked: true)
//                    }
//                }
//            }
//            .padding()
//            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
//                ForEach(levels, id: \.self) { level in
//                    LevelButton(level: level, unlocked: level <= unlockedLevels)
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Select Level")
//    }
//}

struct LevelButton: View {
    var level: Int
    var unlocked: Bool
    
    var body: some View {
        Button(action: {
            if unlocked {
                // Load the level in SpriteKit
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(unlocked ? Color.blue : Color.gray)
                    .frame(height: 80)
                if unlocked {
                    Text("\(level)")
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
