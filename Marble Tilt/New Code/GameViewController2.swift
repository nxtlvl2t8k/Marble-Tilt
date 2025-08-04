//
//  GameViewController2.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-04.
//
import SpriteKit

class GameViewController2: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as? SKView {
            let scene = GameScene2(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
        }
    }

    override func loadView() {
        self.view = SKView()
    }
}
