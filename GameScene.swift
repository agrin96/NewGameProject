//
//  GameScene.swift
//  Signal Process
//
//  Created by Aleksandr Grin on 8/30/18.
//  Copyright © 2018 AleksandrGrin. All rights reserved.
//

// Note: because of iphone X screen style we have to use safe insets when placing all of our scene objects.
//          This is accessed through the SkView.safeInsets parameter.

import SpriteKit
import GameplayKit

class GameScene: SKScene {


    override func didMove(to view: SKView) {

        // Test!
        let label = SKLabelNode(text: "HelloWorld")
        label.alpha = 1.0
        label.fontColor = .white
        label.fontSize = 80
        label.zPosition = 0
        label.position = CGPoint(x: 0, y: 0)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = .gray
        self.addChild(label)



    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
