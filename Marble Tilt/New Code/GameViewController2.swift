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
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        becomeFirstResponder()
//    }
//
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
//
//    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//        if let skView = self.view as? SKView,
//           let scene = skView.scene as? GameScene2 {
//            scene.motionEnded(motion, with: event)
//        }
//    }
//    
    override func loadView() {
        self.view = SKView()
    }
}

