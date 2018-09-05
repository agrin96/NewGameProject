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

class GameScene: SKScene{

    var bottomWave:WaveGenerator?
    var topWave:WaveGenerator?
    var playerWave:WaveGenerator?

    var scoreLabel:SKLabelNode?
    var score:Int = 0

    override func didMove(to view: SKView) {
        //DO NOT TOUCH THE GRAVITY I SPENT 2 HOURS DEBUGGING THIS BEING COMMENTED OUT
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        //Create a level and set it as the contact delegate
        let leveltest = LevelGenerator(in: self.view!)
        self.addChild(leveltest)
        self.physicsWorld.contactDelegate = leveltest

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = .gray

//        let playerOscillation:[Int] = [1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4]
        let playerOscillation:[Int] = [1,2,3,4]
        leveltest.playerWave!.updateWaveOscillationWith(forces: playerOscillation)
        leveltest.beginLevel()

        let newOscillation:[Int] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
        let updateOscillation = SKAction.run({
            leveltest.topWave!.updateWaveOscillationWith(forces: newOscillation)
        })
        self.run(SKAction.sequence([SKAction.wait(forDuration: 10),updateOscillation]))
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
