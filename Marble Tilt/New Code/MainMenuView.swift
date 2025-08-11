//
//  MainMenuView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-08.
//
import SwiftUI

struct MainMenuView: View {
    @State private var showLevel: Int? = nil

    var body: some View {
        ZStack {
            if let level = showLevel {
                if level == 1 {
                    // Show marbles game container
                    GameView(level: 1,
                                   onExit: { withAnimation { showLevel = nil } },
                                   onHoleCompleted: {
                                        withAnimation { showLevel = nil }
                                    })
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                } else if level == 2 {
                    // Show golf game container
                    GameContainerView(level: 2,
                                      onExit: { withAnimation { showLevel = nil } },
                                      onHoleCompleted: {
                                          withAnimation { showLevel = nil }
                                      })
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                }
            } else {
                VStack(spacing: 20) {
                    Text("Multi-Level Game")
                        .font(.largeTitle)
                        .bold()

                    Button("Play Marble Level 1") {
                        withAnimation {
                            showLevel = 1
                        }
                    }
                    .buttonStyle(MainMenuButtonStyle())

                    Button("Play Golf Level 2") {
                        withAnimation {
                            showLevel = 2
                        }
                    }
                    .buttonStyle(MainMenuButtonStyle())
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showLevel)
    }
}

struct MainMenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .frame(minWidth: 220, minHeight: 50)
            .background(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
    }
}
