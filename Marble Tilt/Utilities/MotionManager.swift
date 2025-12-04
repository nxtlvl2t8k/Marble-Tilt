//
//  MotionManager.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-12-02.
//

// MotionManager.swift
import CoreMotion
import Foundation

class MotionManager {
    static let shared = MotionManager()
    private let manager = CMMotionManager()
    private init() {}

    var lastAcceleration: CMAcceleration? = nil

    func startUpdates() {
        guard manager.isAccelerometerAvailable else { return }
        manager.accelerometerUpdateInterval = 1.0 / 60.0
        manager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let d = data else { return }
            self?.lastAcceleration = d.acceleration
        }
    }

    func stopUpdates() { manager.stopAccelerometerUpdates() }
}
