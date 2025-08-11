//
//  MainMenuView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-08.
//
import SwiftUI

struct MainMenuView: View {
    @State private var showGame = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
//                NavigationLink("Play") {
//                    GameView()
//                }
                ///If we want full screen get rid of NavigationLink("Play") {
                Button("Play") {
                    showGame = true
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
            .fullScreenCover(isPresented: $showGame) {
                MainMarbleView()
            }

        }
    }
}
