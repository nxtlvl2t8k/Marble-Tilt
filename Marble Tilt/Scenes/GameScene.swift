//
//  GameScene2.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Nodes
    var marbles: [MarbleNode] = []
    var vortexNodes: [VortexNode] = []
    var sunkMarbles: [MarbleNode] = []
    var messageLabel: SKLabelNode?

    // MARK: - Managers
    var motionManager = CMMotionManager()
    var tutorialManager: TutorialManager?

    // MARK: - Tutorial Flags
    var tutorialMarble: MarbleNode?
    var isTutorialLevel = false
    
    // MARK: - Editing Mode
    var editingMode: Bool = false
    private var selectedVortex: VortexNode?


    // ============================================================
    // MARK: - Scene Setup
    // ============================================================
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self

        setupMessageLabel()
        startTiltUpdates()
        
        startTutorial()   // Auto-enter tutorial for now
    }

    
    // ============================================================
    // MARK: - UI
    // ============================================================
    func setupMessageLabel() {
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.fontSize = 28
        label.fontColor = .white
        label.position = CGPoint(x: size.width/2, y: size.height - 70)
        label.zPosition = 100
        addChild(label)
        messageLabel = label
    }


    // ============================================================
    // MARK: - Tutorial Flow
    // ============================================================
    func startTutorial() {
        isTutorialLevel = true
        
        // Clear previous content
        sunkMarbles.removeAll()
        vortexNodes.forEach { $0.removeFromParent() }
        vortexNodes.removeAll()
        marbles.forEach { $0.removeFromParent() }
        marbles.removeAll()

        tutorialManager = TutorialManager(scene: self,
                                          customVortexPositions: []) { [weak self] in
            self?.tutorialCompleted()
        }
        
        tutorialManager?.startTutorial()

        // Spawn tutorial marble
        let marble = MarbleNode()
        marble.position = CGPoint(x: size.width * 0.25, y: size.height / 2)
        addChild(marble)
        tutorialMarble = marble
    }

    func tutorialCompleted() {
        print("🎉 Tutorial completed")
        UserDefaults.standard.set(true, forKey: "TutorialCompleted")

        tutorialMarble?.removeFromParent()
        tutorialMarble = nil
        isTutorialLevel = false

        setupVortexes()
        spawnMarbles(count: 5)

        messageLabel?.text = "Tutorial Complete!"
    }


    // ============================================================
    // MARK: - Normal Gameplay Setup
    // ============================================================
    func spawnMarbles(count: Int) {
        for _ in 0..<count {
            let marble = MarbleNode()
            marble.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            marbles.append(marble)
            addChild(marble)
        }
    }

    func setupVortexes() {
        let positions = LevelLoader.loadVortexPositions(level: 1)
        for pos in positions {
            let vortex = VortexNode(position: pos)
            vortexNodes.append(vortex)
            addChild(vortex)
        }
    }


    // ============================================================
    // MARK: - Tilt Physics
    // ============================================================
    func startTiltUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1/60
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self = self, let motion = motion else { return }
            let tiltX = motion.gravity.y
            let tiltY = motion.gravity.x
            self.physicsWorld.gravity = CGVector(dx: tiltX * -50, dy: tiltY * 50)
        }
    }


    // ============================================================
    // MARK: - Editing Mode
    // ============================================================
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editingMode, let touch = touches.first else { return }

        let location = touch.location(in: self)
        selectedVortex = vortexNodes.first { $0.contains(location) }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editingMode,
              let touch = touches.first,
              let vortex = selectedVortex else { return }

        vortex.position = touch.location(in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editingMode else { return }

        if let vortex = selectedVortex {
            print("📍 Dropped vortex at: \(vortex.position)")
        }
        selectedVortex = nil
    }


    // ============================================================
    // MARK: - Frame Updates
    // ============================================================
    override func update(_ currentTime: TimeInterval) {
        if editingMode { return }

        if isTutorialLevel, let marble = tutorialMarble {
            tutorialManager?.checkMarble(marble, sunkMarbles: &sunkMarbles)
        }

        // Normal marble handling
        for marble in marbles where marble.physicsBody?.isDynamic == true {
            tutorialManager?.checkMarble(marble, sunkMarbles: &sunkMarbles)
        }
    }


    // ============================================================
    // MARK: - Editing Controls
    // ============================================================
    func enableEditingMode() {
        editingMode = true
        print("🔧 Editing mode enabled")
    }

    func disableEditingMode() {
        editingMode = false
        selectedVortex = nil
        print("🔧 Editing mode disabled")
    }
}

//func loadVortexLayout(from url: URL) {
//    do {
//        let data = try Data(contentsOf: url)
//        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Double]] else {
//            print("❌ Invalid JSON format")
//            return
//        }
//
//        // Remove existing vortexes
//        vortexNodes.forEach { $0.removeFromParent() }
//        vortexNodes.removeAll()
//
//        // Add vortexes from JSON
//        for item in json {
//            if let x = item["x"], let y = item["y"] {
//                let vortex = VortexNode(position: CGPoint(x: x, y: y))
//                vortexNodes.append(vortex)
//                addChild(vortex)
//            }
//        }
//
//        print("✅ Loaded \(vortexNodes.count) vortexes from custom layout")
//    } catch {
//        print("❌ Failed to load vortex layout: \(error)")
//    }
//}

//func exportVortexLayout() -> URL? {
//    let positions = vortexNodes.map { ["x": Double($0.position.x), "y": Double($0.position.y)] }
//    do {
//        let data = try JSONSerialization.data(withJSONObject: positions, options: .prettyPrinted)
//        let filename = "custom_vortex_layout.json"
//        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            .appendingPathComponent(filename)
//        try data.write(to: url)
//        print("✅ Saved custom vortex layout to \(url.path)")
//        return url
//    } catch {
//        print("❌ Failed to export layout: \(error)")
//        return nil
//    }
//}
