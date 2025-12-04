//
//  CGPoint+Extensions.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-29.
//

// Extensions.swift
import CoreGraphics

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
            hypot(self.x - point.x, self.y - point.y)
    }
}
