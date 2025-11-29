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
    static func loadPositions(file: String = "marble_positions_handshake_scaled_ipad") -> [CGPoint] {
        guard let url = Bundle.main.url(forResource: file, withExtension: "json") else {
            print("❌ JSON file not found in bundle")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([MarblePosition].self, from: data)
            return decoded.map { $0.cgPoint }
        } catch {
            print("❌ JSON decode error: \(error)")
            return []
        }
    }
}
