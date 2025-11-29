//
//  VortexEditorScene.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-29.
//


import SpriteKit

class VortexEditorScene: SKScene {
    
    // MARK: - Nodes
    var backgroundNode: SKSpriteNode!
    var vortexNodes: [VortexNode] = []
    
    private var selectedVortex: VortexNode?
    
    // MARK: - Init with background
    convenience init(size: CGSize, background: UIImage) {
        self.init(size: size)
        
        backgroundColor = .black
        backgroundNode = SKSpriteNode(texture: SKTexture(image: background))
        backgroundNode.position = CGPoint(x: size.width/2, y: size.height/2)
        backgroundNode.size = size
        backgroundNode.zPosition = -1
        addChild(backgroundNode)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    // MARK: - Edit Mode Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if tapping on existing vortex
        selectedVortex = vortexNodes.first { $0.contains(location) }
        
        // Tap empty space: add new vortex
        if selectedVortex == nil {
            addVortex(at: location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let vortex = selectedVortex else { return }
        let location = touch.location(in: self)
        vortex.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedVortex = nil
    }
    
    // MARK: - Add/Remove
    func addVortex(at point: CGPoint) {
        let vortex = VortexNode(position: point)
        vortexNodes.append(vortex)
        addChild(vortex)
    }
    
    func removeVortex(_ vortex: VortexNode) {
        vortex.removeFromParent()
        if let index = vortexNodes.firstIndex(of: vortex) {
            vortexNodes.remove(at: index)
        }
    }
    
    // MARK: - Save/Load
    func saveLayout(to url: URL) {
        let dictArray = vortexNodes.map { ["x": Double($0.position.x), "y": Double($0.position.y)] }
        do {
            let data = try JSONSerialization.data(withJSONObject: dictArray, options: .prettyPrinted)
            try data.write(to: url)
            print("✅ Layout saved to \(url)")
        } catch {
            print("❌ Failed to save layout: \(error)")
        }
    }
    
    func loadLayout(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Double]] {
                vortexNodes.forEach { $0.removeFromParent() }
                vortexNodes.removeAll()
                
                for dict in json {
                    if let x = dict["x"], let y = dict["y"] {
                        addVortex(at: CGPoint(x: x, y: y))
                    }
                }
                print("✅ Layout loaded from \(url)")
            }
        } catch {
            print("❌ Failed to load layout: \(error)")
        }
    }
}
