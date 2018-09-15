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

///NOTE: make custom enums + struct of level editing scripting style so like:
// enum Action: case wait,change
// struct Level: Action,Data
// so it would look like [Wait(3), change([]), wait(10), change([])]
// can mask it under regular SKAction subclass


class GameScene: SKScene, GameStatusNotifier{
    var levelToPlay:LevelGenerator?
    var currentLevel:Int = 2
    //Win/lose
    var gamestatus:SKLabelNode?
    var score:Int = 0

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
        self.levelToPlay = LevelGenerator(in: self.view!)
        self.addChild(self.levelToPlay!)
        self.physicsWorld.contactDelegate = self.levelToPlay!

        let playerOscillation:[[CGFloat]] = [[1,1,1,1]]
        self.levelToPlay!.playerWave!.updateWaveOscillationWith(forces: playerOscillation)
        LevelList.level(num: self.currentLevel, gen: self.levelToPlay!)
        self.levelToPlay!.gameStatusDelegate = self
        self.levelToPlay!.beginLevel()
    }

    override func sceneDidLoad() {
        super.sceneDidLoad()
    }

    //Resets the current level by nulling out the level values and actions and then reinitializing them.
    // This is easier and cleaner than writing some kind of crazy reset function to zero out all the values
    // inside the Wavegenerator class.
    private func resetLevel(){
        self.removeAllActions()
        self.levelToPlay!.removeFromParent()
        self.levelToPlay = nil

        //Create a level and set it as the contact delegate
        self.levelToPlay = LevelGenerator(in: self.view!)
        self.addChild(self.levelToPlay!)
        self.physicsWorld.contactDelegate = self.levelToPlay!

        let playerOscillation:[[CGFloat]] = [[1,1,1,1]]
        self.levelToPlay!.playerWave!.updateWaveOscillationWith(forces: playerOscillation)
        LevelList.level(num: self.currentLevel, gen: self.levelToPlay!)
        self.levelToPlay!.gameStatusDelegate = self
        self.levelToPlay!.beginLevel()
    }

    //Function which handles win/lose condition and reseting the level.
    func gameStateChanged(status: GameStatus) {
        if status == .won{
            self.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run({
                self.gamestatus!.text = "SIGNAL RECEIVED!"
                self.gamestatus!.fontSize = 36
                self.gamestatus!.fontColor = .green
                self.gamestatus!.run(SKAction.sequence([
                    SKAction.fadeIn(withDuration: 0.5),
                    SKAction.wait(forDuration: 2),
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.run({
                        self.currentLevel += 1
                        if self.currentLevel == 3 {
                            self.currentLevel = 0
                        }
                        self.resetLevel()
                })]))
            })]))
        }else if status == .lost{
            self.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run({
                self.gamestatus!.text = "SIGNAL LOST!"
                self.gamestatus!.fontSize = 48
                self.gamestatus!.fontColor = .red
                self.gamestatus!.run(SKAction.sequence([
                    SKAction.fadeIn(withDuration: 0.5),
                    SKAction.wait(forDuration: 2),
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.run({
                        self.resetLevel()
                })]))
            })]))
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
