//
//  HelpView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-07.
//
import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("How to Play")
                    .font(.largeTitle)
                    .bold()
                
                GameTipRow(icon: "gyroscope", text: "Tilt your device to roll the marbles.")
                GameTipRow(icon: "flame", text: "Place 1 marble in each Vortex and lock it in place.")
                GameTipRow(icon: "flag.checkered", text: "Fill all the holes and win the level.")
                
                Divider()
                
                Text("Power-Ups")
                    .font(.title2)
                GameTipRow(icon: "shield", text: "Protects you from hazards for a short time.")
                GameTipRow(icon: "timer", text: "Slows time to navigate tricky areas.")
                GameTipRow(icon: "star", text: "Earn extra points.")
            }
            .padding()
        }
        .overlay(alignment: .topTrailing) {
            Button("Close") { dismiss() }
                .padding()
        }
    }
}

struct GameTipRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
                .frame(width: 40)
            Text(text)
                .font(.body)
            Spacer()
        }
    }
}
