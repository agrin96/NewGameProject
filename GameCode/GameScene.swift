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
    var currentLevel:Int = 0
    //Win/lose
    var gamestatus:SKLabelNode?
    var score:Int = 0

    let maxLevels:Int = 100

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        //DO NOT TOUCH THE GRAVITY I SPENT 2 HOURS DEBUGGING THIS BEING COMMENTED OUT
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        //Make the notification bar of game win/lose
        self.gamestatus = SKLabelNode(text: "")
        self.gamestatus!.fontName = "AvenirNext-Bold"
        self.gamestatus!.isHidden = false
        self.gamestatus!.zPosition = 10
        self.addChild(self.gamestatus!)

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = .black

        //Create a level and set it as the contact delegate
        self.resetLevel()
    }

    override func sceneDidLoad() {
        super.sceneDidLoad()
    }

    //Resets the current level by nulling out the level values and actions and then reinitializing them.
    // This is easier and cleaner than writing some kind of crazy reset function to zero out all the values
    // inside the Wavegenerator class.
    private func resetLevel(){
        //Remove references to reduce ARC and allow deinit of object
        if self.levelToPlay != nil {
            self.removeAllActions()
            self.levelToPlay!.removeAllActions()
            self.levelToPlay!.removeFromParent()
            self.physicsWorld.contactDelegate = nil
            self.levelToPlay = nil
        }

        if self.levelToPlay == nil {
            //Create a level and set it as the contact delegate
            self.levelToPlay = LevelGenerator(in: self.view!,level:self.currentLevel)
            self.addChild(self.levelToPlay!)
            self.physicsWorld.contactDelegate = self.levelToPlay!

            let playerOscillation:[[CGFloat]] = WaveType.playerSteady1()
            self.levelToPlay!.playerWave!.updateWaveOscillationWith(forces: playerOscillation)
            LevelList.level(num: self.currentLevel, gen: self.levelToPlay!)
            self.levelToPlay!.gameStatusDelegate = self
            self.levelToPlay!.beginLevel()
        }
    }

    //Function which handles win/lose condition and reseting the level.
    func gameStateChanged(status: GameStatus) {
        if status == .won{
            self.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run({ [unowned self] in
                self.gamestatus!.text = "SIGNAL RECEIVED!"
                self.gamestatus!.fontSize = 36
                self.gamestatus!.fontColor = .green
                self.gamestatus!.run(SKAction.sequence([
                    SKAction.fadeIn(withDuration: 0.5),
                    SKAction.wait(forDuration: 2),
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.run({ [unowned self] in
                        self.currentLevel += 1
                        if self.currentLevel == self.maxLevels {
                            self.currentLevel = 0
                        }
                        self.resetLevel()
                })]))
            })]))
        }else if status == .lost{
            self.gameLostAnimation()
            self.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run({ [unowned self] in
                self.gamestatus!.text = "SIGNAL LOST!"
                self.gamestatus!.fontSize = 48
                self.gamestatus!.fontColor = .red
                self.gamestatus!.run(SKAction.sequence([
                    SKAction.fadeIn(withDuration: 0.5),
                    SKAction.wait(forDuration: 2),
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.run({ [unowned self] in
                        self.resetLevel()
                })]))
            })]))
        }
    }

    //Fade and stretch the screen to show the signal being lost.
    func gameLostAnimation(){
        let interferenceAnimation = SKAction.sequence([
            SKAction.wait(forDuration: 0.25),
            SKAction.group([
                SKAction.move(by: CGVector(dx: Int(arc4random_uniform(100))-50, dy: Int(arc4random_uniform(60))-30), duration: 1.0),
                SKAction.scaleX(to: 1.45, duration: 1.5),
                SKAction.scaleY(to: 2.0, duration: 1.5),
                SKAction.fadeOut(withDuration: 1.5)
            ])
        ])
        self.levelToPlay!.run(interferenceAnimation)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
