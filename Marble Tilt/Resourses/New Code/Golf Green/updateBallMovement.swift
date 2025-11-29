//
//  updateBallMovement.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-10.
//

import Foundation
import SpriteKit

func updateBallMovement(ball: SKSpriteNode) {
    let pos = ball.position
    let slopeX = heightAt(x: pos.x + 1, y: pos.y) - heightAt(x: pos.x - 1, y: pos.y)
    let slopeY = heightAt(x: pos.x, y: pos.y + 1) - heightAt(x: pos.x, y: pos.y - 1)
    let slopeVector = CGVector(dx: -slopeX * 0.05, dy: -slopeY * 0.05)
    ball.physicsBody?.applyForce(slopeVector)
}

func heightAt(x: CGFloat, y: CGFloat) -> CGFloat {
    // Example: smooth sinusoidal contour
    return sin(x / 100) * 10 + cos(y / 120) * 8
}
