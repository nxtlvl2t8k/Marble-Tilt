//
//  GolfScene.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-10.
//


import SpriteKit
import CoreMotion
import UIKit

/// GolfScene: procedural smooth heightfield + ball physics + tilt control
class GolfScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Public callbacks
    var holeCompletedCallback: (() -> Void)?

    // MARK: - Nodes
    private var ball: SKSpriteNode!
    private var holeNode: SKSpriteNode!

    // Motion
    private let motion = CMMotionManager()
    private var lastAccel: CMAcceleration?

    // Heightfield (procedural)
    // We'll use a continuous function for heights (no large grids needed).
    // You can later replace with an image-based heightmap.
    private var heightScale: CGFloat = 40.0
    private var slopeForceScale: CGFloat = 80.0 // how strongly slope pulls ball
    private var tiltGravityScale: CGFloat = 9.8  // uses device tilt to augment forces

    // Game state
    private var levelNumber: Int = 1
    private var holeRadius: CGFloat = 16
    private var ballRadius: CGFloat = 12

    // Simple flags
    private var holeCaptured = false
    private var lastHoleTime: TimeInterval = 0

    // MARK: - Configure
    func configureFor(level: Int) {
        levelNumber = level
        // adjust height function params per level if needed
    }

    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(red: 0.12, green: 0.45, blue: 0.12, alpha: 1.0)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        scaleMode = .resizeFill

        setupBackground()
        setupBall()
        setupHole()
        startMotionUpdates()
    }

    override func willMove(from view: SKView) {
        stopMotionUpdates()
    }

    // MARK: - Setup visuals
    private func setupBackground() {
        // A visual gradient to hint slope. You can replace with a custom texture.
        let bg = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        let texture = gradientTexture(size: size)
        let sprite = SpriteKit.SKSpriteNode(texture: texture)
        sprite.position = CGPoint(x: size.width/2, y: size.height/2)
        sprite.zPosition = -10
        sprite.size = size
        addChild(sprite)

        // Optionally add rough/bunker visuals (not physics-affecting here)
    }

    private func gradientTexture(size: CGSize) -> SKTexture {
        // Create a smooth radial-ish gradient texture to give a green feel.
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            let cg = ctx.cgContext
            let colors = [UIColor(red: 0.06, green: 0.5, blue: 0.06, alpha: 1).cgColor,
                          UIColor(red: 0.12, green: 0.65, blue: 0.12, alpha: 1).cgColor]
            let locations: [CGFloat] = [0, 1]
            let space = CGColorSpaceCreateDeviceRGB()
            if let grad = CGGradient(colorsSpace: space, colors: colors as CFArray, locations: locations) {
                cg.drawRadialGradient(grad,
                                      startCenter: CGPoint(x: size.width*0.4, y: size.height*0.6),
                                      startRadius: 10,
                                      endCenter: CGPoint(x: size.width*0.6, y: size.height*0.4),
                                      endRadius: max(size.width, size.height),
                                      options: [])
            }
        }
        return SKTexture(image: img)
    }

    private func setupBall() {
        ball = SpriteKit.SKSpriteNode(imageNamed: "ballCyan") // supply asset or replace with shape
        if ball.texture == nil {
            // fallback to circle
            ball = SKSpriteNode(circleOfRadius: ballRadius)
            ball.color = .white
        }
        ball.size = CGSize(width: ballRadius*2, height: ballRadius*2)
        ball.position = CGPoint(x: size.width * 0.18, y: size.height * 0.5)
        ball.zPosition = 5
        ball.name = "ballCyan"

        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        ball.physicsBody?.allowsRotation = true
        ball.physicsBody?.linearDamping = 0.4   // how quickly it slows (green speed)
        ball.physicsBody?.friction = 0.25
        ball.physicsBody?.restitution = 0.1
        ball.physicsBody?.mass = 0.2
        ball.physicsBody?.angularDamping = 0.6
        addChild(ball)
    }

    private func setupHole() {
        holeNode = SpriteKit.SKSpriteNode(imageNamed: "vortex")
        if holeNode.texture == nil {
            holeNode = SpriteKit.SKSpriteNode(color: .black, size: CGSize(width: holeRadius*2, height: holeRadius*2))
//            holeNode.cornerRadius = holeRadius
        }
        holeNode.position = CGPoint(x: size.width * 0.78, y: size.height * 0.5)
        holeNode.zPosition = 4
        holeNode.name = "vortex"

        // physics body only for detection (non-dynamic)
        holeNode.physicsBody = SKPhysicsBody(circleOfRadius: holeRadius)
        holeNode.physicsBody?.isDynamic = false
        holeNode.physicsBody?.categoryBitMask = 0x1 << 1
        holeNode.physicsBody?.contactTestBitMask = 0x1 << 0
        holeNode.physicsBody?.collisionBitMask = 0
        addChild(holeNode)
    }

    // Helper: create a circle sprite if no asset
    private func SKSpriteNode(circleOfRadius: CGFloat) -> SKSpriteNode {
        let node = SpriteKit.SKSpriteNode(texture: nil, color: .white, size: CGSize(width: circleOfRadius*2, height: circleOfRadius*2))
        node.name = "fallbackBall"
        node.zPosition = 5
        return node
    }

    // MARK: - Motion control
    func startMotionUpdates() {
        guard motion.isAccelerometerAvailable else { return }
        motion.accelerometerUpdateInterval = 1.0 / 60.0
        motion.startAccelerometerUpdates()
    }

    func stopMotionUpdates() {
        if motion.isAccelerometerActive { motion.stopAccelerometerUpdates() }
    }

    // MARK: - Heightfield: procedural smooth surface
    /// Example height function combining a few smooth bumps. Output in points (y offset).
    private func height(at point: CGPoint) -> CGFloat {
        // Normalize point to 0..1
        let nx = point.x / max(1, size.width)
        let ny = point.y / max(1, size.height)

        // Several smooth "bumps" and dips using sines/gaussians
        let bump1 = gaussian(x: nx, y: ny, cx: 0.3, cy: 0.55, sx: 0.12, sy: 0.12) * 1.0
        let bump2 = gaussian(x: nx, y: ny, cx: 0.7, cy: 0.45, sx: 0.18, sy: 0.18) * -0.7
        let ripple = 0.5 * sin((nx + ny) * 8.0) * 0.6

        let h = (bump1 + bump2 + ripple) * heightScale
        return h // in pixels
    }

    private func gaussian(x: CGFloat, y: CGFloat, cx: CGFloat, cy: CGFloat, sx: CGFloat, sy: CGFloat) -> CGFloat {
        let dx = (x - cx) / sx
        let dy = (y - cy) / sy
        return CGFloat(exp(-0.5 * (dx*dx + dy*dy)))
    }

    // Sample gradient using central differences
    private func slopeGradient(at point: CGPoint, delta: CGFloat = 4.0) -> CGVector {
        let pL = CGPoint(x: max(0, point.x - delta), y: point.y)
        let pR = CGPoint(x: min(size.width, point.x + delta), y: point.y)
        let pD = CGPoint(x: point.x, y: max(0, point.y - delta))
        let pU = CGPoint(x: point.x, y: min(size.height, point.y + delta))

        let hL = height(at: pL)
        let hR = height(at: pR)
        let hD = height(at: pD)
        let hU = height(at: pU)

        // slope in pixels per point step (approx)
        let dx = (hR - hL) / (2 * delta)
        let dy = (hU - hD) / (2 * delta)

        // downhill vector = negative gradient
        return CGVector(dx: -dx, dy: -dy)
    }

    // MARK: - Update loop
    override func update(_ currentTime: TimeInterval) {
        guard !holeCaptured else {
            // small delay then callback
            if lastHoleTime > 0 && currentTime - lastHoleTime > 0.9 {
                holeCompletedCallback?()
                holeCaptured = false
                lastHoleTime = 0
            }
            return
        }

        // 1) Apply tilt gravity from device
        if let accel = motion.accelerometerData?.acceleration {
            // Map device tilt into force vector in scene coordinates.
            // Note: you might need to swap axes for your device orientation
            let gx = CGFloat(accel.x) * tiltGravityScale
            let gy = CGFloat(accel.y) * tiltGravityScale
            // Instead of changing physicsWorld.gravity directly, apply a small force to the ball so slopes still matter.
            ball.physicsBody?.applyForce(CGVector(dx: gx * 0.15, dy: gy * 0.15))
        }

        // 2) Apply slope-based force (downhill)
        let grad = slopeGradient(at: ball.position, delta: 6.0)
        let slopeForce = CGVector(dx: grad.dx * slopeForceScale, dy: grad.dy * slopeForceScale)
        ball.physicsBody?.applyForce(slopeForce)

        // 3) Optionally clamp velocity to avoid super-high speeds
        if let vel = ball.physicsBody?.velocity {
            let maxSpeed: CGFloat = 1200
            let speed = hypot(vel.dx, vel.dy)
            if speed > maxSpeed {
                let scale = maxSpeed / speed
                ball.physicsBody?.velocity = CGVector(dx: vel.dx * scale, dy: vel.dy * scale)
            }
        }

        // 4) Visual: you could move decal nodes to match height, etc.
        // (Not required for physics; this is just for fancy visuals)
    }

    // MARK: - Contacts
    func didBegin(_ contact: SKPhysicsContact) {
        var other: SKNode? = nil
        if contact.bodyA.node == ball { other = contact.bodyB.node }
        else if contact.bodyB.node == ball { other = contact.bodyA.node }
        guard let node = other, node == holeNode else { return }

        // If ball collides with hole, check speed to simulate the ball dropping when slow enough
        if let vel = ball.physicsBody?.velocity {
            let speed = hypot(vel.dx, vel.dy)
            if speed < 200 {
                captureBallInHole()
            } else {
                // Strong collision: maybe bounce off the hole rim
                // Optionally apply a small inward impulse to slow it a bit
                let toCenter = CGVector(dx: holeNode.position.x - ball.position.x, dy: holeNode.position.y - ball.position.y)
                ball.physicsBody?.applyImpulse(CGVector(dx: toCenter.dx * 0.002, dy: toCenter.dy * 0.002))
            }
        }
    }

    private func captureBallInHole() {
        guard !holeCaptured else { return }
        holeCaptured = true
        ball.physicsBody?.velocity = .zero
        ball.physicsBody?.isDynamic = false

        // Animate ball sinking
        let sink = SKAction.group([
            SKAction.scale(to: 0.3, duration: 0.6),
            SKAction.fadeAlpha(to: 0.0, duration: 0.6),
            SKAction.move(to: holeNode.position, duration: 0.6)
        ])
        sink.timingMode = .easeIn
        ball.run(sink) { [weak self] in
            self?.lastHoleTime = CACurrentMediaTime()
            // will call holeCompletedCallback in update after short delay
        }
    }
}

