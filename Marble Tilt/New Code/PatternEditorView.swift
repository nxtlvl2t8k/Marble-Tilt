//
//  PatternEditorView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//


import SwiftUI

struct PatternEditorView: View {
    @State private var tapLocation: CGPoint = .zero
    @State private var marblePositions: [CGPoint] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.white
                    .ignoresSafeArea()
                    .gesture(
                        TapGesture()
                            .onEnded { _ in
                                marblePositions.append(tapLocation)
                                print("Added marble at: \(tapLocation)")
                            }
                    )
                    .background(
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        tapLocation = value.location
                                    }
                            )
                    )

                ForEach(marblePositions.indices, id: \.self) { index in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)
                        .position(marblePositions[index])
                }
            }
        }
    }
}
