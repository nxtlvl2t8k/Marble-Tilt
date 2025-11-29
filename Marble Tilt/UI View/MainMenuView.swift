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
    @State private var showEditor = false  // NEW: editor modal
    
    // MARK: - Tutorial Check
    @State private var tutorialCompleted =
        UserDefaults.standard.bool(forKey: "TutorialCompleted")

    var body: some View {
        ZStack {
            if let level = showLevel {
                // Tutorial Level (Level 0)
                if level == 0 {
                    GameView(level: 0,
                             onExit: { closeLevel() },
                             onHoleCompleted: {
                                 UserDefaults.standard.set(true, forKey: "TutorialCompleted")
                                 tutorialCompleted = true
                                 closeLevel()
                             })
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                }

                else if level == 1 {
                    GameView(level: 1,
                             onExit: { withAnimation { showLevel = nil } },
                             onHoleCompleted: { withAnimation { showLevel = nil } })
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                    
                } else if level == 2 {
                    GameContainerView(level: 2,
                                      onExit: { withAnimation { showLevel = nil } },
                                      onHoleCompleted: { withAnimation { showLevel = nil } })
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
//                } else if level == 0 {
//                    LevelSelectView(showLevel: $showLevel)
//                        .transition(.move(edge: .trailing))
//                        .zIndex(1)
                }
            } else {
                VStack(spacing: 20) {
                    Text("Multi-Level Game")
                        .font(.largeTitle)
                        .bold()
                    
                    // MARK: - Tutorial Button
                     if !tutorialCompleted {
                         Button("Start Tutorial") {
                             showLevel = 0   // Level 0 is tutorial
                         }
                         .buttonStyle(MainMenuButtonStyle())
                     } else {
                         Button("Replay Tutorial") { showLevel = 0 }
                             .buttonStyle(MainMenuButtonStyle())
                     }

                    Button("Select Level") { showLevel = 0 }
                        .buttonStyle(MainMenuButtonStyle())
                    
                    Button("Help") { showHelp = true }
                        .buttonStyle(MainMenuButtonStyle())
                    
                    Button("About Us") { showInfo = true }
                        .buttonStyle(MainMenuButtonStyle())
                    
                    // NEW: Editor button (could be paid feature)
                    Button("Edit Level Layout") {
                        if UserDefaults.standard.bool(forKey: "hasPurchasedEditor") {
                            showEditor = true
                        } else {
                            // Show purchase flow
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
            // Supply your background image here
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
