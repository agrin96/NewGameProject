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
    var levelConstruct:LevelList?
    
    var currentLevel:Int = 0
    weak var parentViewController:GameViewController?
    
    //Win/lose
    var gamestatus:SKLabelNode?
    var score:Int = 0

    let maxLevels:Int = 100
    
    var numberOfTransitions:Int = 0
    let transitionsBetweenAds:Int = 2
    
    var resumeGame:SKLabelNode?
    
    var continueQuestion:SKNode?

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
        
        let mainScreen = SKSpriteNode(color: .black, size: CGSize(width: 380, height: 605))
        mainScreen.alpha = 0.90
        mainScreen.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mainScreen.zPosition = 1
        mainScreen.position = CGPoint.zero
        mainScreen.position.y += 5
        self.addChild(mainScreen)
        mainScreen.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.run {
                mainScreen.color = .white
            },
            SKAction.fadeAlpha(to: 0.30, duration: 0.5)
            ]))

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = .white
        
        let background = SKSpriteNode(imageNamed: "GameScreen.png")
        background.size = self.size
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.position = CGPoint.zero
        background.zPosition = -1
        self.addChild(background)

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
            self.levelToPlay!.gameStatusDelegate = nil
            self.physicsWorld.contactDelegate = nil
            self.levelToPlay = nil
            if self.levelConstruct != nil {
                self.levelConstruct!.clearLevel()
                self.levelConstruct = nil
            }
        }

        if self.levelToPlay == nil {
            //Create a level and set it as the contact delegate
            self.levelToPlay = LevelGenerator(in: self.view!,level:self.currentLevel)
            self.addChild(self.levelToPlay!)
            self.physicsWorld.contactDelegate = self.levelToPlay!

            let playerOscillation:[[CGFloat]] = WaveType.steady()
            self.levelToPlay!.playerWave!.updateWaveOscillationWith(forces: playerOscillation)
            self.levelConstruct = LevelList(num: self.currentLevel, gen: self.levelToPlay!)
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
                    SKAction.fadeOut(withDuration: 1.0),
                    SKAction.run({ [unowned self] in
                        self.currentLevel += 1
                        if self.currentLevel == self.maxLevels {
                            self.currentLevel = 0
                        }
                        
                        //After winning or losing the game we present a full screen ad.
                        if self.numberOfTransitions >= self.transitionsBetweenAds{
                            if let vc = self.parentViewController{
                                vc.presentFullScreenAd()
                            }
                            self.numberOfTransitions = 0
                        }
                    
                        self.resetLevel()
                        self.numberOfTransitions += 1
                })]))
            })]))
        }else if status == .lost{
            self.gameLostAnimation()
            self.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run({ [unowned self] in
                self.gamestatus!.text = "SIGNAL LOST!"
                self.gamestatus!.fontSize = 48
                self.gamestatus!.fontColor = .red
                self.gamestatus!.run(SKAction.sequence([
                    SKAction.fadeIn(withDuration: 0.25),
                    SKAction.wait(forDuration: 0.75),
                    SKAction.fadeOut(withDuration: 0.25),
                    SKAction.run({ [unowned self] in
                        self.presentUserContinueChoice()
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
                SKAction.scaleX(to: 0.01, duration: 1.0),
                SKAction.scaleY(to: 0.01, duration: 1.0),
                SKAction.fadeOut(withDuration: 1.0)
            ])
        ])
        self.levelToPlay!.run(interferenceAnimation)
    }
    
    //After losing, we ask the player if they want to continue or if they want to return
    // to the menu
    func presentUserContinueChoice(){
        if self.continueQuestion == nil {
            self.continueQuestion = SKNode()
            self.continueQuestion!.position = CGPoint.zero
            self.continueQuestion!.zPosition = 3
            self.addChild(self.continueQuestion!)
            
            let continueGame = SpriteButton(button: SKTexture(imageNamed: "Button"), buttonTouched: SKTexture(imageNamed: "Button_Touched"))
            continueGame.setButtonText(text: "Continue")
            continueGame.setButtonScale(to: 0.5)
            continueGame.zPosition = 3
            continueGame.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            continueGame.position = CGPoint.zero
            continueGame.alpha = 0.9
            continueGame.name = "ContinueGame"
            continueGame.position.y -= 100
            self.continueQuestion!.addChild(continueGame)
            
            let stopGame = SpriteButton(button: SKTexture(imageNamed: "Button"), buttonTouched: SKTexture(imageNamed: "Button_Touched"))
            stopGame.setButtonText(text: "Main Menu")
            stopGame.setButtonScale(to: 0.5)
            stopGame.zPosition = 3
            stopGame.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            stopGame.position = CGPoint.zero
            stopGame.alpha = 0.9
            stopGame.name = "StopGame"
            stopGame.position.y += 100
            self.continueQuestion!.addChild(stopGame)
        }else{
            self.continueQuestion?.isHidden = false
            self.continueQuestion!.isUserInteractionEnabled = true
        }
    }
    
    func continueGame(){
        //After winning or losing the game we present a full screen ad.
        if self.numberOfTransitions >= self.transitionsBetweenAds{
            if let vc = self.parentViewController{
                vc.presentFullScreenAd()
            }
            self.numberOfTransitions = 0
        }
        self.resetLevel()
        self.numberOfTransitions += 1
    }
    
    func handleUserChoice(_ sender:UILongPressGestureRecognizer){
        if self.continueQuestion == nil {
            return
        }
        
        let coordinates = sender.location(in: self.view!)
        let tapLocation = self.convertPoint(fromView: coordinates)
        
        if let node = self.continueQuestion!.childNode(withName: "ContinueGame"){
            if self.continueQuestion!.isHidden == false{
                if node.contains(tapLocation){
                    (node as! SpriteButton).buttonTouchedUpInside {
                        self.continueGame()
                        self.continueQuestion!.isHidden = true
                        self.continueQuestion!.isUserInteractionEnabled = false
                    }
                }
            }
        }
        if let node = self.continueQuestion!.childNode(withName: "StopGame"){
            if self.continueQuestion!.isHidden == false{
                if node.contains(tapLocation){
                    (node as! SpriteButton).buttonTouchedUpInside {
                        if let nav = self.parentViewController?.navigationController{
                            self.continueQuestion!.isHidden = true
                            self.continueQuestion!.isUserInteractionEnabled = false
                            
                            nav.popViewController(animated: true)
                            let scene = ((nav.topViewController as! MainMenuViewController).view as! SKView).scene as! MainMenuScene
                            scene.view?.isPaused = false
                            scene.isPaused = false
                            scene.resetMainMenu()
                        }
                    }
                }
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

