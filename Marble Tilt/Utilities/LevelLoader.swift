//
//  MarblePosition.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-28.
//

import Foundation
import CoreGraphics

class LevelLoader {
    static func loadVortexPositions(level: Int) -> [CGPoint] {
        guard let url = Bundle.main.url(forResource: "level\(level)", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let array = try? JSONSerialization.jsonObject(with: data) as? [[String: CGFloat]]
        else { return [] }
        
        return array.compactMap { dict in
            guard let x = dict["x"], let y = dict["y"] else { return nil }
            return CGPoint(x: x, y: y)
        }
    }
    
    static func loadMarblePositions(file: String) -> [CGPoint] {
        return MarbleLoader.loadPositions(file: file)
    }
}
