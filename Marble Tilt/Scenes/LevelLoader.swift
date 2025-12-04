//
//  MarblePosition.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-28.
//

import Foundation
import CoreGraphics

class LevelLoader {

    static func loadTargetPattern() -> [CGPoint] {

        guard let url = Bundle.main.url(
            forResource: "marble_positions_handshake_scaled_ipad",
            withExtension: "json"
        ) else {
            print("❌ JSON not found")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([MarblePosition].self, from: data)
            let points = decoded.map { $0.cgPoint }
            print("🌀 Loaded \(points.count) vortex positions")
            return points
        } catch {
            print("❌ JSON decode failed: \(error)")
            return []
        }
    }
}
