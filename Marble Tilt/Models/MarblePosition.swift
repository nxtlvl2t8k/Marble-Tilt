//
//  MarblePosition.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-12-01.
//

import CoreGraphics

struct MarblePosition: Codable {
    let x: CGFloat
    let y: CGFloat

    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}
