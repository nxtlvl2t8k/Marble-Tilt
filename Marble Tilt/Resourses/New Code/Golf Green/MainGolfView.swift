//
//  MainMenuView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-10.
//


import SwiftUI

struct MainGolfView: View {
    @State private var showLevel = false

    var body: some View {
        ZStack {
            // --- Main menu UI ---
            VStack(spacing: 20) {
                Text("Marbles Golf")
                    .font(.largeTitle)
                    .bold()

                Button(action: { showLevel = true }) {
                    Text("Play Level 2")
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
                }
            }

            // --- Full-screen game overlay ---
            if showLevel {
                GameContainerView(level: 2, onExit: {
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
