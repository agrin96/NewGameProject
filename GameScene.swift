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

        var playerSettings = WaveGeneratorParameters()
        playerSettings.waveHead.isPlayer = true
        playerSettings.waveHead.headColor = .red
        playerSettings.waveDrawer.waveColor = .red
        let player = WaveGenerator(paramters: playerSettings)
        self.addChild(player)
        player.activateWaveGenerator()

        var bottomWaveSettings = WaveGeneratorParameters()
        bottomWaveSettings.location = CGPoint(x: self.view!.bounds.width / 2, y: 70)
        let bottomWave = WaveGenerator(paramters: bottomWaveSettings)
        self.addChild(bottomWave)
        bottomWave.activateWaveGenerator()

        var topWaveSettings = WaveGeneratorParameters()
        topWaveSettings.location = CGPoint(x: self.view!.bounds.width / 2, y: -70)
        let topWave = WaveGenerator(paramters: topWaveSettings)
        self.addChild(topWave)
        topWave.activateWaveGenerator()
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
