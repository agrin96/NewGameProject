//
// Created by Aleksandr Grin on 9/4/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//


//This class will use wave generators to create different levels with different parameters. Will Handle
// restarting and score keeping.
import SpriteKit


//Will determine whether this level has been won or lost.
enum GameStatus{
    case won, lost
}

//Used to tell whether a game is won or lost.
protocol GameStatusNotifier:class{
    func gameStateChanged(status:GameStatus)
}

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
    var currentTimeDisplay:SKLabelNode?
    var currentTime:CGFloat = 0
    var levelTimer:Timer?
    let maximumLevelTime:CGFloat = 60//seconds (1.5 minutes)

    //Notifier of win/lose
    var gameStatusDelegate:GameStatusNotifier?
    var didPlayerLose:Bool = true

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //A level consists of 2 boundary waves and 1 player wave.
    init(in view:SKView) {
        super.init()


        var playerSettings = WaveGeneratorParameters()
        playerSettings.waveHead.isPlayer = true
        playerSettings.waveHead.headColor = .red
        playerSettings.waveDrawer.waveColor = .red
        self.playerWave = WaveGenerator(paramters: playerSettings)
        self.addChild(self.playerWave!)
        self.playerWave!.scoreUpdateDelegate = self

        var topWaveSettings = WaveGeneratorParameters()
        topWaveSettings.location = CGPoint(x: view.bounds.width / 2, y: 70)
        self.topWave = WaveGenerator(paramters: topWaveSettings)
        self.addChild(self.topWave!)

        var bottomWaveSettings = WaveGeneratorParameters()
        bottomWaveSettings.location = CGPoint(x: view.bounds.width / 2, y: -70)
        self.bottomWave = WaveGenerator(paramters: bottomWaveSettings)
        self.addChild(self.bottomWave!)


        self.scoreLabel = SKLabelNode(text: "Signal Strength: \(0)")
        self.scoreLabel!.fontName = "AvenirNext-Bold"
        self.scoreLabel!.position = CGPoint(x: 0, y: 250)
        self.scoreLabel!.fontSize = 30
        self.addChild(self.scoreLabel!)

        self.currentTimeDisplay = SKLabelNode(text: "\(0)")
        self.currentTimeDisplay!.position = CGPoint(x: 0, y: -250)
        self.currentTimeDisplay!.fontSize = 30
        self.addChild(self.currentTimeDisplay!)
    }

    //Called to actually start the level
    func beginLevel(){
        if self.playerWave != nil{
            self.isPaused = false
            self.currentScore = 0
            self.didPlayerLose = false

            let queue = OperationQueue()
            queue.qualityOfService = .userInitiated

            //Start all the wave generators
            queue.addOperation({
                self.bottomWave!.activateWaveGenerator()
            })
            queue.addOperation({
                self.topWave!.activateWaveGenerator()
            })
            self.playerWave!.activateWaveGenerator()

            //Start the level timer
            self.currentTimeDisplay!.text = "\(0)"
            self.levelTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)

        }
    }

    //Update the level timer.
    @objc private func updateTime(){
        self.currentTime += 0.1
        self.currentTime = CGFloat(round(Double(self.currentTime * 10)) / 10)
        self.currentTimeDisplay?.text = "\(self.currentTime)"

        //We stop the wave generation of the bounds so that they end right at the
        // middle of the screen when the time is at the max.
        if self.currentTime >= (self.maximumLevelTime - 3.125) {
            self.bottomWave!.deactivateWaveGenerator()
            self.topWave!.deactivateWaveGenerator()
        }

        //If the current level time reaches the max then we have won!
        if self.currentTime >= self.maximumLevelTime {
            self.gameStatusDelegate!.gameStateChanged(status: .won)
            self.playerWave!.deactivateWaveGenerator()
            self.levelTimer!.invalidate()
        }
    }

    //Is called each time a player taps to update score
    internal func updateScore(scoreKeeper:SKLabelNode) {
        if didPlayerLose == false{
            self.currentScore += Int(scoreKeeper.text!)!
            self.scoreLabel!.text = "Signal Strength: \(self.currentScore)"
        }
    }

    internal func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "Player" || contact.bodyB.node?.name == "Player"{
            self.didPlayerLose = true
            self.isPaused = true
            self.levelTimer!.invalidate()

            //If we hit into a wave then we have lost.
            self.currentTime = 0
            self.gameStatusDelegate!.gameStateChanged(status: .lost)
        }
    }

}