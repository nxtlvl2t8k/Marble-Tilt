//
//  MainMenuView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-08.
//
import SwiftUI

struct MainMenuView: View {
    @State private var showLevel: Int? = nil
    @State private var showHelp = false
    @State private var showInfo = false

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
                } else if level == 0 {
                    // Show Level Select View
                    LevelSelectView(showLevel: $showLevel)
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                }
            } else {
                VStack(spacing: 20) {
                    Text("Multi-Level Game")
                        .font(.largeTitle)
                        .bold()

                    Button("Select Level") {
                            showLevel = 0 // Use 0 to mean “open level select”
                    }
                    .buttonStyle(MainMenuButtonStyle())
                    
                    Button("Help") {
                        showHelp = true
                    }
                    .buttonStyle(MainMenuButtonStyle())

                    Button("Info") {
                        showInfo = true
                    }
                    .buttonStyle(MainMenuButtonStyle())

                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showLevel)
        // Present Help View modally
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
        // Present Info View modally
        .sheet(isPresented: $showInfo) {
            InfoView()
        }

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
