//
//  MarblePosition.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-28.
//

import Foundation
import CoreGraphics

struct MarblePosition: Codable {
    let x: CGFloat
    let y: CGFloat
    var cgPoint: CGPoint { CGPoint(x: x, y: y) }
}

struct VortexPosition: Codable {
    let x: CGFloat
    let y: CGFloat
    var cgPoint: CGPoint { CGPoint(x: x, y: y) }
}

// MARK: - Loader
class LevelLoader {

    static func loadMarbles(file: String) -> [CGPoint] {
        guard let url = Bundle.main.url(forResource: file, withExtension: "json") else {
            print("❌ Marble JSON not found: \(file).json")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([MarblePosition].self, from: data)
            return decoded.map { $0.cgPoint }
        } catch {
            print("❌ Marble JSON decode error: \(error)")
            return []
        }
    }

    static func loadVortexes(file: String) -> [CGPoint] {
        guard let url = Bundle.main.url(forResource: file, withExtension: "json") else {
            print("❌ Vortex JSON not found: \(file).json")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([VortexPosition].self, from: data)
            return decoded.map { $0.cgPoint }
        } catch {
            print("❌ Vortex JSON decode error: \(error)")
            return []
        }
    }
}
