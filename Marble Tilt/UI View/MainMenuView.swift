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
    @State private var showLevels = false
    @State private var selectedLevel: Int? = nil
    
    @State private var tutorialCompleted =
    UserDefaults.standard.bool(forKey: "TutorialCompleted")
    
    var body: some View {
        ZStack {
            // MARK: - Main Menu
//            Image("menuBackground")
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Welcome to Marble Tilt")
                    .font(.system(size: 48, weight: .heavy))
                    .foregroundColor(.white)
                    .shadow(radius: 10)

                Button("Select Level") {
                    withAnimation { showLevels = true }
                }
                .mainMenuButtonStyle()
                
                Button("Help") { showHelp = true }
                    .mainMenuButtonStyle()
                
                Button("About Us") { showInfo = true }
                    .mainMenuButtonStyle()
                }
            .transition(.opacity)
        }
        .sheet(isPresented: $showHelp) { HelpView() }
        .sheet(isPresented: $showInfo) { AboutUsView() }
        .sheet(isPresented: $showLevels) {
            LevelSelectView()
        }
    }
}

extension Button {
    func mainMenuButtonStyle() -> some View {
        self.frame(width: 200, height: 50)
            .background(Color.blue.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(radius: 8)
    }
}
