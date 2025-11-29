//
//  PatternEditorView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//


import SwiftUI

struct PatternEditorView: View {
    @State private var vortexPositions: [CGPoint] = []
    @State private var showExportAlert = false
    @State private var exportPath: URL?
    @State private var showShareSheet = false
    
    let backgroundImage = Image("handshake") // Add this image to Assets.xcassets

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundImage
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                ForEach(0..<vortexPositions.count, id: \.self) { index in
                    let pos = vortexPositions[index]
                    Circle()
                        .fill(Color.orange.opacity(0.5))
                        .frame(width: 12, height: 12)
                        .position(pos)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        let tapLocation = value.location
                        vortexPositions.append(tapLocation)
                    }
            )
            .overlay(alignment: .top) {
                HStack {
                    Text("🌀 Vortex count: \(vortexPositions.count)")
                        .padding()
                    Spacer()
                    Button("Export JSON") {
                        exportJSON(from: vortexPositions, in: geometry.size)
                    }
                    .padding()
                }
                .background(Color.black.opacity(0.5))
                .foregroundColor(.white)
            }
        }
//        .alert(isPresented: $showExportAlert) {
//            Alert(title: Text("✅ Exported"), message: Text("File saved to \(exportPath?.lastPathComponent ?? "unknown")"), dismissButton: .default(Text("OK")))
//        }
        .background(
            Group {
                if let exportPath = exportPath, showShareSheet {
                    ShareSheet(activityItems: [exportPath])
                        .onDisappear {
                            // Reset to allow future sharing
                            showShareSheet = false
                        }
                }
            }
        )
   }

    func exportJSON(from points: [CGPoint], in size: CGSize) {
        // Normalize points relative to the screen
        let normalizedPoints = points.map { point in ["x": Double(point.x), "y": Double(point.y)] }

        do {
            let data = try JSONSerialization.data(withJSONObject: normalizedPoints, options: .prettyPrinted)
            let filename = "marble_positions_handshake_custom.json"
            //let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
            try data.write(to: url)
            //exportPath = url
            //showExportAlert = true

            print("✅ JSON saved at: \(url.path)")
            print("📄 File size: \(data.count) bytes")

            DispatchQueue.main.async {
                exportPath = url
                showShareSheet = true
            }

        } catch {
            print("❌ Failed to export JSON: \(error)")
        }
    }
}
