//
//  MainMenuView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-08.
//
import SwiftUI

struct MainMenuView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink("Play") {
                    GameView()
                }
                .buttonStyle(.borderedProminent)
                .font(.title)

                NavigationLink("Help") {
                    HelpView()
                }
                .buttonStyle(.bordered)
                .font(.title)

                Spacer()
            }
            .padding()
            .navigationTitle("Marbles")
        }
    }
}
