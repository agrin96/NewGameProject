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
        //DO NOT TOUCH THE GRAVITY I SPENT 2 HOURS DEBUGGING THIS BEING COMMENTED OUT
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = .gray

        let topWave = WaveGenerator(wave: .simpleSinusoid_1, headLocation: CGPoint(x: 150, y: 75))
        self.addChild(topWave)
        topWave.activateWaveGenerator()

        let bottomWave = WaveGenerator(wave: .simpleSinusoid_1, headLocation: CGPoint(x: 150, y: -75))
        bottomWave.activateWaveGenerator()
        self.addChild(bottomWave)

        let player = WaveGenerator(wave: .simpleSinusoid_1, headLocation: CGPoint(x: 0, y: 0))
        player.activateWaveGenerator()
        self.addChild(player)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
