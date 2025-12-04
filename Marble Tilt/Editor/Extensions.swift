//
//  Extensions.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-12-04.
//


// Extensions.swift
import CoreGraphics

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(self.x - point.x, self.y - point.y)
    }
}

extension CGVector {
    func length() -> CGFloat { return sqrt(dx*dx + dy*dy) }
}
