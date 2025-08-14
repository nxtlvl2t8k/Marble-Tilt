//
//  MarblePosition.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//


import Foundation
import CoreGraphics

struct MarblePosition: Codable {
    let x: CGFloat
    let y: CGFloat
    
    var cgPoint: CGPoint { CGPoint(x: x, y: y) }
}

class MarbleLoader {
    static func loadPositions() -> [CGPoint] {
        guard let url = Bundle.main.url(forResource: "marble_positions_handshake_scaled_ipad", withExtension: "json") else {
            print("❌ This is located in Class MarbleLoader JSON file not found in bundle")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([MarblePosition].self, from: data)
            return decoded.map { CGPoint(x: $0.x, y: $0.y) }
        } catch {
            print("❌ JSON decode error: \(error)")
            return []
        }
    }
}

