//
//  MotionManager.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-12-02.
//


import CoreMotion
import Foundation

class MotionManager {

    static let shared = MotionManager()

    private let manager = CMMotionManager()
    private var lastAcceleration: CMAcceleration?

    private let shakeThreshold = 0.7

    func start() {
        manager.startAccelerometerUpdates()
    }

    func currentAcceleration() -> CMAcceleration? {
        return manager.accelerometerData?.acceleration
    }

    func isShakeDetected() -> Bool {
        guard let acc = manager.accelerometerData?.acceleration else { return false }
        guard let last = lastAcceleration else {
            lastAcceleration = acc
            return false
        }

        let dx = acc.x - last.x
        let dy = acc.y - last.y
        let dz = acc.z - last.z

        let magnitude = sqrt(dx*dx + dy*dy + dz*dz)

        lastAcceleration = acc

        return magnitude > shakeThreshold
    }
}
