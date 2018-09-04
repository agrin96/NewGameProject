//
// Created by Aleksandr Grin on 9/4/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//


//This class will use wave generators to create different levels with different parameters. Will Handle
// restarting and score keeping.
import SpriteKit


class LevelGenerator:SKNode, SKPhysicsContactDelegate, ScoreChangeNotifier{
    //Stores the wave generator
    var bottomWave:WaveGenerator?
    var topWave:WaveGenerator?
    var playerWave:WaveGenerator?

    var scoreLabel:SKLabelNode?
    var currentScore:Int = 0

    //We will have a star scoring system for levels based on score.
    // The user will try to achieve these goals to get the relevant score.
    var score3Star:Int = 1000
    var score2Star:Int = 800
    var score1Star:Int = 300

    //We will be determining how long levels last based on a timing counter.
    // Each level will be a maximum of 180 seconds long.
    var currentLevelTime:CGFloat = 0
    let maximumLevelTime:CGFloat = 180//seconds (3 minutes)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(in view:SKView) {
        super.init()

        let queue = OperationQueue()

        queue.addOperation({
            var playerSettings = WaveGeneratorParameters()
            playerSettings.waveHead.isPlayer = true
            playerSettings.waveHead.headColor = .red
            playerSettings.waveDrawer.waveColor = .red
            self.playerWave = WaveGenerator(paramters: playerSettings)
            self.addChild(self.playerWave!)
            self.playerWave!.scoreUpdateDelegate = self
        })

        queue.addOperation({
            var bottomWaveSettings = WaveGeneratorParameters()
            bottomWaveSettings.location = CGPoint(x: view.bounds.width / 2, y: 70)
            self.bottomWave = WaveGenerator(paramters: bottomWaveSettings)
            self.addChild(self.bottomWave!)
        })

        queue.addOperation({
            var topWaveSettings = WaveGeneratorParameters()
            topWaveSettings.location = CGPoint(x: view.bounds.width / 2, y: -70)
            self.topWave = WaveGenerator(paramters: topWaveSettings)
            self.addChild(self.topWave!)
        })

        self.scoreLabel = SKLabelNode(text: "Score: \(0)")
        self.scoreLabel?.position = CGPoint(x: 0, y: 250)
        self.scoreLabel?.fontSize = 30
        self.addChild(self.scoreLabel!)

    }

    //Called to actually start the level
    func beginLevel(){
        if self.playerWave != nil{
            //Start all the wave generators
            self.bottomWave!.activateWaveGenerator()
            self.topWave!.activateWaveGenerator()

            self.playerWave!.activateWaveGenerator()
        }
    }

    internal func updateScore(previousDirection: Direction) {
        if previousDirection == .up {
            //This means we are closest to the top wave so lets take the score.
            let distance = abs(self.playerWave!.getPrimaryWaveHeadPosition() - self.topWave!.getCollisionWaveHeadPosition())
            print(distance)
            self.currentScore += Int(10000 / (distance*distance))
            self.scoreLabel!.text = "Score: \(self.currentScore)"
        }else if previousDirection == .down{
            //This means we are closest to the bottom wave so lets take the score.
            let distance = abs(self.playerWave!.getPrimaryWaveHeadPosition() - self.bottomWave!.getCollisionWaveHeadPosition())
            self.currentScore += Int(10000 / (distance*distance))
            self.scoreLabel!.text = "Score: \(self.currentScore)"
        }
    }

    internal func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "Player" || contact.bodyB.node?.name == "Player"{
            print("contact!!")
            self.isPaused = true
        }
    }

}