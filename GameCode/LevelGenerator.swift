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

    //Stores the obstacle generators.
    var obstacleGenerators:[ObstacleGenerator] = []

    var scoreLabel:SKLabelNode?
    var currentScore:Int = 0

    //We will be determining how long levels last based on a timing counter.
    // Each level will be a maximum of 180 seconds long.
    var currentTimeDisplay:SKLabelNode?
    var currentTime:CGFloat = 0
    weak var levelTimer:Timer?
    let maximumLevelTime:CGFloat = 45//seconds
    var gamePaused:Bool = false
    var willResignActiveCalls:Int = 0

    //Notifier of win/lose
    weak var gameStatusDelegate:GameStatusNotifier?
    var didPlayerLose:Bool = true
    var currentLevel:Int = 0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //A level consists of 2 boundary waves and 1 player wave.
    init(in view:SKView, level:Int) {
        super.init()
        var playerSettings = WaveGeneratorParameters()
        playerSettings.waveHead.isPlayer = true
        playerSettings.waveHead.headColor = .red
        playerSettings.waveDrawer.waveTexture = SKTexture(imageNamed: "PlayerSignalColor.png")
        playerSettings.waveDrawer.waveStroke = 9
        playerSettings.level = level
        self.currentLevel = level
        self.playerWave = WaveGenerator(paramters: playerSettings)
        self.addChild(self.playerWave!)
        self.playerWave!.scoreUpdateDelegate = self

        var topWaveSettings = WaveGeneratorParameters()
        topWaveSettings.location = CGPoint(x: view.bounds.width / 2, y: 70)
        topWaveSettings.waveHead.isPlayer = false
        self.topWave = WaveGenerator(paramters: topWaveSettings)
        self.addChild(self.topWave!)

        var bottomWaveSettings = WaveGeneratorParameters()
        bottomWaveSettings.location = CGPoint(x: view.bounds.width / 2, y: -70)
        bottomWaveSettings.waveHead.isPlayer = false
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
        
        //Subscribe to notifications to know when to pause and when to resume the timer.
        NotificationCenter.default.addObserver(self, selector: #selector(pauseTimer(sender:)), name: Notification.Name.init(rawValue: "ResumeGame"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseTimer(sender:)), name: UIApplication.willResignActiveNotification, object: nil)
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
            queue.addOperation({ [unowned self] in
                self.bottomWave!.activateWaveGenerator()
            })
            queue.addOperation({ [unowned self] in
                self.topWave!.activateWaveGenerator()
            })

            self.playerWave!.activateWaveGenerator()

            queue.addOperation({ [unowned self] in
                for obs in self.obstacleGenerators {
                    obs.startObstacles()
                }
            })

            //Start the level timer
            self.currentTimeDisplay!.text = "\(0)"
            self.levelTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        }
    }
    
    //Manually pause and unpause the game timer because it continues being active even
    // if the entire scene or view is paused.
    @objc func pauseTimer(sender:Notification){
        //When the application resigns it is sometimes called twice which results
        // in all kinds of timing issues hence we make sure that we ignore it after
        // the first execution.
        if sender.name == UIApplication.willResignActiveNotification {
            self.willResignActiveCalls += 1
        }
        
        if self.willResignActiveCalls == 2 {
            self.willResignActiveCalls = 0
            return
        }
        
        if self.gamePaused {
            self.levelTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            self.gamePaused = false
        }else{
            if self.levelTimer != nil{
                self.levelTimer!.invalidate()
            }
            self.gamePaused = true
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

        //At this time we will stop the obstacles and fade them out to indicate
        // that the level is over.
        if self.currentTime >= (self.maximumLevelTime - 1.250){
            for obs in self.obstacleGenerators{
                obs.stopObstacles()
            }
        }

        //If the current level time reaches the max then we have won!
        if self.currentTime >= self.maximumLevelTime {
            self.levelTimer!.invalidate()
            self.levelTimer = nil
            self.currentTime = 0
            self.gameStatusDelegate!.gameStateChanged(status: .won)
            //Take the score of the wavehead right at the end
            self.playerWave!.resetAndRunScore()

            if GameData.sharedInstance().levelData[self.currentLevel].highScore < self.currentScore{
                GameData.sharedInstance().levelData[self.currentLevel].highScore = self.currentScore
            }
            if self.currentLevel + 1 < GameData.sharedInstance().levelData.count{
                GameData.sharedInstance().levelData[self.currentLevel + 1].unlocked = true
            }
            self.playerWave!.deactivateWaveGenerator()
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
            //This prevents the double contact call from both the player node and the node it collided with
            if self.didPlayerLose == false{

                self.didPlayerLose = true
                self.topWave!.isPaused = true
                self.bottomWave!.isPaused = true
                self.playerWave!.isPaused = true
                for obs in self.obstacleGenerators{
                    obs.isPaused = true
                }
                if self.levelTimer != nil {
                    self.levelTimer!.invalidate()
                }

                //If we hit into a wave then we have lost.
                self.currentTime = 0
                if GameData.sharedInstance().levelData[self.currentLevel].highScore < self.currentScore{
                    GameData.sharedInstance().levelData[self.currentLevel].highScore = self.currentScore
                }
                self.gameStatusDelegate!.gameStateChanged(status: .lost)
            }

        }
    }

}
