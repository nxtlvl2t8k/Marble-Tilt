//
//  ContentView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//
import SwiftUI

struct ContentView: View {
    var level: Int
    
    var body: some View {
//        PatternEditorView()
        GameView()
            .edgesIgnoringSafeArea(.all)
    }
}
