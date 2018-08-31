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

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = .gray


        let waveGen = WaveGenerator()
        waveGen.waveObject!.position.y += 75
        self.addChild(waveGen.waveObject!)

        let waveGen2 = WaveGenerator()
        waveGen2.waveObject!.position.y -= 75
        self.addChild(waveGen2.waveObject!)

        let playerWave = WaveGenerator()
        playerWave.waveObject!.strokeColor = .red
        playerWave.waveObject!.position.x -= 200
        self.addChild(playerWave.waveObject!)


    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
