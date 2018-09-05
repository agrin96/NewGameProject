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

class GameScene: SKScene, GameStatusNotifier{

    var levelToPlay:LevelGenerator?

    var gamestatus:SKLabelNode?
    var score:Int = 0

    override func didMove(to view: SKView) {
        //DO NOT TOUCH THE GRAVITY I SPENT 2 HOURS DEBUGGING THIS BEING COMMENTED OUT
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        //Make the notification bar of game win/lose
        self.gamestatus = SKLabelNode(text: "")
        self.gamestatus!.fontSize = 60
        self.gamestatus!.fontColor = .green

        //Create a level and set it as the contact delegate
        self.levelToPlay = LevelGenerator(in: self.view!)
        self.addChild(self.levelToPlay!)
        self.physicsWorld.contactDelegate = self.levelToPlay!

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = .gray

//        let playerOscillation:[Int] = [1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4]
        let playerOscillation:[Int] = [1,2,3,4]
        self.levelToPlay!.playerWave!.updateWaveOscillationWith(forces: playerOscillation)
        self.levelToPlay!.gameStatusDelegate = self
        self.levelToPlay!.beginLevel()

        let newOscillation:[Int] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
        let updateOscillation = SKAction.run({
            self.levelToPlay!.topWave!.updateWaveOscillationWith(forces: newOscillation)
        })
        self.run(SKAction.sequence([SKAction.wait(forDuration: 10),updateOscillation]))
    }

    private func resetLevel(){
        self.levelToPlay!.removeFromParent()
        self.levelToPlay = nil

        //Create a level and set it as the contact delegate
        self.levelToPlay = LevelGenerator(in: self.view!)
        self.addChild(self.levelToPlay!)
        self.physicsWorld.contactDelegate = self.levelToPlay!

        let playerOscillation:[Int] = [1,2,3,4]
        self.levelToPlay!.playerWave!.updateWaveOscillationWith(forces: playerOscillation)
        self.levelToPlay!.gameStatusDelegate = self
        self.levelToPlay!.beginLevel()

        let newOscillation:[Int] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
        let updateOscillation = SKAction.run({
            self.levelToPlay!.topWave!.updateWaveOscillationWith(forces: newOscillation)
        })
        self.run(SKAction.sequence([SKAction.wait(forDuration: 10),updateOscillation]))
    }

    func gameStateChanged(status: GameStatus) {
        if status == .won{
            print("Game won!")
        }else if status == .lost{
            print("Game Lost!")
            self.resetLevel()
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
