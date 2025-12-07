//
//  MainMenuView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-08.
//
import SwiftUI

enum ActiveSheet: Identifiable {
    case help, info, levels
    var id: Int { hashValue }
}

struct MainMenuView: View {
    var startGame: () -> Void
    
    @State private var showHelp = false
    @State private var showInfo = false
    @State private var showLevels = false

    @State private var activeSheet: ActiveSheet? = nil

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

                Button("Select Level") { activeSheet = .levels }
                .mainMenuButtonStyle()
                
                Button("Help") { activeSheet = .help }
                    .mainMenuButtonStyle()
                
                Button("About Us") { activeSheet = .info }
                    .mainMenuButtonStyle()
                }
            .transition(.opacity)
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .help:
                HelpView()
            case .info:
                AboutUsView()
            case .levels:
                LevelSelectView()
            }
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
