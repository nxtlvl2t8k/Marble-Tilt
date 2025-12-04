//
//  MarblePosition.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-28.
//

// LevelLoader.swift
import Foundation
import CoreGraphics

struct MarblePosition: Codable {
    let x: CGFloat
    let y: CGFloat
    var cgPoint: CGPoint { CGPoint(x: x, y: y) }
}

class LevelLoader {
    static let shared = LevelLoader()
    private init() {}

    func loadPattern(named resourceName: String, completion: @escaping ([CGPoint]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
                print("❌ JSON not found: \(resourceName)")
                DispatchQueue.main.async { completion([]) }
                return
            }
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([MarblePosition].self, from: data)
                let pts = decoded.map { $0.cgPoint }
                DispatchQueue.main.async {
                    print("🌀 Loaded \(pts.count) positions from \(resourceName).json")
                    completion(pts)
                }
            } catch {
                print("❌ JSON decode failed: \(error)")
                DispatchQueue.main.async { completion([]) }
            }
        }
    }
}
