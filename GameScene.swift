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

class GameScene: SKScene, SKPhysicsContactDelegate, ScoreChangeNotifier{

    var bottomWave:WaveGenerator?
    var topWave:WaveGenerator?
    var playerWave:WaveGenerator?

    var scoreLabel:SKLabelNode?
    var score:Int = 0

    override func didMove(to view: SKView) {
        //DO NOT TOUCH THE GRAVITY I SPENT 2 HOURS DEBUGGING THIS BEING COMMENTED OUT
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = .gray

        let queue = OperationQueue()

        queue.addOperation({
            var playerSettings = WaveGeneratorParameters()
            playerSettings.waveHead.isPlayer = true
            playerSettings.waveHead.headColor = .red
            playerSettings.waveDrawer.waveColor = .red
            self.playerWave = WaveGenerator(paramters: playerSettings)
            self.addChild(self.playerWave!)
            self.playerWave!.scoreUpdateDelegate = self
            self.playerWave!.activateWaveGenerator()
        })

        queue.addOperation({
            var bottomWaveSettings = WaveGeneratorParameters()
            bottomWaveSettings.location = CGPoint(x: self.view!.bounds.width / 2, y: 70)
            self.bottomWave = WaveGenerator(paramters: bottomWaveSettings)
            self.addChild(self.bottomWave!)
            self.bottomWave!.activateWaveGenerator()
        })

        queue.addOperation({
            var topWaveSettings = WaveGeneratorParameters()
            topWaveSettings.location = CGPoint(x: self.view!.bounds.width / 2, y: -70)
            self.topWave = WaveGenerator(paramters: topWaveSettings)
            self.addChild(self.topWave!)
            self.topWave!.activateWaveGenerator()
        })

        self.scoreLabel = SKLabelNode(text: "Score: \(0)")
        self.scoreLabel?.position = CGPoint(x: 0, y: 250)
        self.scoreLabel?.fontSize = 30
        self.addChild(self.scoreLabel!)

    }

    func updateScore(previousDirection: Direction) {
        if previousDirection == .up {
            //This means we are closest to the top wave so lets take the score.
            let distance = abs(self.playerWave!.getPrimaryWaveHeadPosition() - self.topWave!.getCollisionWaveHeadPosition())
            print(distance)
            self.score += Int(10000 / (distance*distance))
            self.scoreLabel!.text = "Score: \(self.score)"
        }else if previousDirection == .down{
            //This means we are closest to the bottom wave so lets take the score.
            let distance = abs(self.playerWave!.getPrimaryWaveHeadPosition() - self.bottomWave!.getCollisionWaveHeadPosition())
            self.score += Int(10000 / (distance*distance))
            self.scoreLabel!.text = "Score: \(self.score)"
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "Player" || contact.bodyB.node?.name == "Player"{
            print("contact!!")
            self.isPaused = true
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
