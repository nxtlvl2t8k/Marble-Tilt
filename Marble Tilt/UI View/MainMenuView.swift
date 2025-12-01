//
//  MainMenuView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-08.
//
import SwiftUI

struct MainMenuView: View {
    @State private var showHelp = false
    @State private var showInfo = false
    @State private var showLevelSelect = false  // NEW: level select page
    @State private var selectedLevel: Int? = nil
    
    @State private var tutorialCompleted =
    UserDefaults.standard.bool(forKey: "TutorialCompleted")
    
    var body: some View {
        ZStack {
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
                }
            .transition(.opacity)
        }
        .sheet(isPresented: $showHelp) { HelpView() }
        .sheet(isPresented: $showInfo) { AboutUsView() }
        .sheet(isPresented: $showLevelSelect) {
            LevelSelectView(
                showLevel: $selectedLevel,
                showLevelSelect: $showLevelSelect
            )
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
