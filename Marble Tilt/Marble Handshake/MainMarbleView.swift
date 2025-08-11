//
//  ContentView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//
import SwiftUI

struct MainMarbleView: View {
    @State private var showLevel = false
//    var level: Int
//    var onExit: () -> Void // Called when back button is tapped
    //
    var body: some View {
        ZStack {
            // --- Main menu UI ---
            VStack(spacing: 20) {
                Text("Marble Tilt")
                    .font(.largeTitle)
                    .bold()
                
                Button(action: { showLevel = true }) {
                    Text("Play Level 1")
                        .font(.title2)
                        .padding()
                        .frame(minWidth: 200)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    // show help or settings
                }) {
                    Text("Help")
                    
                    //        PatternEditorView()
                    //                    GameView(level: 1, onExit: {
                }
            }
            // --- Full-screen game overlay ---
            if showLevel {
                GameView(level: 1, onExit: {
                    withAnimation { showLevel = false }
                }, onHoleCompleted: {
                    // optional: show a score screen or auto-close
                    withAnimation { showLevel = false }
                })
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
        }
        .animation(.easeInOut, value: showLevel)
        
    }
}
