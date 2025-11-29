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
    @State private var showEditor = false
    @State private var showLevelSelect = false  // NEW: level select page
    
    @State private var tutorialCompleted =
        UserDefaults.standard.bool(forKey: "TutorialCompleted")

    var body: some View {
        ZStack {
            if let level = showLevel {
                // MARK: - Levels
                if level == 0 {
                    // Tutorial Level
                    GameView(level: 0,
                             onExit: { closeLevel() },
                             onHoleCompleted: {
                                 UserDefaults.standard.set(true, forKey: "TutorialCompleted")
                        // Unlock Marbles level (id=1)
                        updateMaxLevel(level: 0)

                        // Close tutorial and return to LevelSelectView
                        withAnimation {
                            showLevel = nil
                            showLevelSelect = true
                        }
                    })
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                } else if level == 1 {
                    GameView(level: 1,
                             onExit: { withAnimation { showLevel = nil } },
                             onHoleCompleted: {
                                 updateMaxLevel(level: 1)
                                 withAnimation { showLevel = nil }
                             })
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                } else if level == 2 {
                    GameContainerView(level: 2,
                                      onExit: { withAnimation { showLevel = nil } },
                                      onHoleCompleted: {
                                          updateMaxLevel(level: 2)
                                          withAnimation { showLevel = nil }
                                      })
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                }
            } else if showLevelSelect {
                // MARK: - Level Select View
                LevelSelectView(showLevel: $showLevel, showLevelSelect: $showLevelSelect)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            } else {
                // MARK: - Main Menu
                VStack(spacing: 20) {
                    Text("Welcome to Marble Tilt")
                        .font(.largeTitle)
                        .bold()
                    
                    Button("Select Level") {
                        withAnimation { showLevelSelect = true }
                    }
                    .buttonStyle(MainMenuButtonStyle())
                    
                    Button("Help") { showHelp = true }
                        .buttonStyle(MainMenuButtonStyle())
                    
                    Button("About Us") { showInfo = true }
                        .buttonStyle(MainMenuButtonStyle())
                    
                    // Editor button (optional feature)
                    Button("Edit Level Layout") {
                        if UserDefaults.standard.bool(forKey: "hasPurchasedEditor") {
                            showEditor = true
                        } else {
                            print("Prompt user to buy editor feature")
                        }
                    }
                    .buttonStyle(MainMenuButtonStyle())
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showLevel)
        .sheet(isPresented: $showHelp) { HelpView() }
        .sheet(isPresented: $showInfo) { AboutUsView() }
        .sheet(isPresented: $showEditor) {
            if let bgImage = UIImage(named: "handshake") {
                VortexEditorView(background: bgImage)
            } else {
                Text("No background image found")
            }
        }
    }
    
    // MARK: - Helpers
    private func closeLevel() {
        withAnimation { showLevel = nil }
    }
    
    private func updateMaxLevel(level: Int) {
        let currentMax = UserDefaults.standard.integer(forKey: "MaxLevelCompleted")
        if level > currentMax {
            UserDefaults.standard.set(level, forKey: "MaxLevelCompleted")
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
