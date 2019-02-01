//
// Created by Aleksandr Grin on 8/31/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//

//This will be responsible for taking input parameters and generating wave objects that can be plotted.
// The wave objects will consist of SKShapeNodes which can be added as a parallax effect to the main game
// screen.

import SpriteKit
import CoreGraphics
import UIKit

//Used to notify the wave generator when one of the wavedrawers needs to reset or start
protocol WaveGenerationNotifier:class{
    func nextWaveDrawer(drawerID:Int)
    func resetWaveDrawer(drawerID:Int)
}

//Used to notify the scene when the player has tapped to update score.
protocol ScoreChangeNotifier:class{
    func updateScore(scoreKeeper:SKLabelNode)
}

//Generates a wave starting at a location and drawing backwards.
class WaveGenerator:SKNode, WaveGenerationNotifier, UIGestureRecognizerDelegate{
    //This is the wave head which will serve as our drawing point.
    private var waveHead:WaveHead?

    //We use two wavedrawers to acheive an infinite wave parallalax effect
    private var waveDrawer1:WaveDrawer?
    private var waveDrawer2:WaveDrawer?

    //Store parameters for the waveGenerator
    private var params:WaveGeneratorParameters?

    //The approximate time it takes for spawned waves to get to the player
    private let levelBeginDelay:Double = 3.125

    //These will be visual aids for your wave start and end.
    private var startingReciever:SKSpriteNode?
    private var endingReciever:SKSpriteNode?

    //This gesture recognizer will detect the user tapping on screen.
    private var userTapRecognizer:UIGestureRecognizer?

    //This will allow us to calculate score
    weak var scoreUpdateDelegate:ScoreChangeNotifier?

    //Score notifier
    private var waveScoreKeeper:SKLabelNode?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(paramters:WaveGeneratorParameters){
        super.init()
        self.params = paramters
        self.position = self.params!.location
        //We want the level to start with the user being unable to tap.
        self.isUserInteractionEnabled = false

        //Setup the wavehead which will actually draw the waves.
        self.waveHead  = WaveHead(params: self.params!.waveHead)
        self.waveHead!.zPosition = 3
        self.addChild(self.waveHead!)

        //Setup the collision wavehead which will help keep score and detect collisions.
        if self.params!.waveHead.isPlayer == false{
            self.waveHead!.isHidden = true
        }

        //Setup the two wavedrawers for the infinite parallax effect
        self.waveDrawer1 = WaveDrawer(
                texture: self.params!.waveDrawer.waveTexture,
                strokeThickness: self.params!.waveDrawer.waveStroke,
                drawerNumber: 1,
                isPlayer: self.params!.waveHead.isPlayer)
        self.waveDrawer1!.waveNotificationDelegate = self
        self.waveDrawer1!.zPosition = 1
        self.addChild(self.waveDrawer1!)

        self.waveDrawer2 = WaveDrawer(
                texture: self.params!.waveDrawer.waveTexture,
                strokeThickness: self.params!.waveDrawer.waveStroke,
                drawerNumber: 2,
                isPlayer: self.params!.waveHead.isPlayer)
        self.waveDrawer2!.waveNotificationDelegate = self
        self.waveDrawer2!.zPosition = 1
        self.addChild(self.waveDrawer2!)

        //Adds a small score label to the player head as well as the starting and ending receivers.
        if self.params!.waveHead.isPlayer == true{
            self.waveScoreKeeper = SKLabelNode(text: "0")
            self.waveScoreKeeper!.fontName = "AvenirNext-Bold"
            self.waveScoreKeeper!.position = CGPoint(x: -self.waveHead!.size.width * 3, y: -self.waveHead!.size.height)
            self.waveScoreKeeper!.zPosition = 4
            self.waveScoreKeeper!.fontSize = 20
            self.waveScoreKeeper!.fontColor = .green
            self.waveHead!.addChild(self.waveScoreKeeper!)

            //Add the starting reciever and hide it.
            self.startingReciever = SKSpriteNode(color: .clear, size: CGSize(width: 0, height: 0))
            self.startingReciever!.anchorPoint = CGPoint(x: 0.5, y: 1)
            self.startingReciever!.position.x = 0
            self.startingReciever!.alpha = 1.0
            self.startingReciever!.zPosition = 2
            self.startingReciever!.isHidden = true
            self.addChild(self.startingReciever!)
        
            let startingCityLabel = SKLabelNode(text: GameData.sharedInstance().levelData[self.params!.level].cityName)
            startingCityLabel.position.x = self.startingReciever!.position.x
            startingCityLabel.position.y = self.startingReciever!.position.y + 80
            startingCityLabel.zPosition = 2
            startingCityLabel.fontName = "Helvetica-Bold"
            self.startingReciever!.addChild(startingCityLabel)

            let startingLevelImage = SKSpriteNode(imageNamed: "Tower_On.png")
            startingLevelImage.setScale(0.70)
            startingLevelImage.anchorPoint = CGPoint(x: 0.5, y: 1)
            startingLevelImage.position.x = 0
            startingLevelImage.alpha = 0.80
            startingLevelImage.zPosition = 2
            startingLevelImage.position.y += 75
            self.startingReciever!.addChild(startingLevelImage)

            let startLevelIndicator = SKLabelNode(text: "Level \(self.params!.level + 1)")
            startLevelIndicator.position.y = 120
            startLevelIndicator.fontColor = .white
            startLevelIndicator.fontName = "Helvetica-Bold"
            startLevelIndicator.alpha = 1.0
            startLevelIndicator.zPosition = 2
            self.startingReciever!.addChild(startLevelIndicator)

            //Add the ending reciever and hide it.
            self.endingReciever = SKSpriteNode(color: .clear, size: CGSize(width: 0, height: 0))
            self.endingReciever!.anchorPoint = CGPoint(x: 0.5, y: 1)
            self.endingReciever!.position.x = 187.5
            self.endingReciever!.alpha = 1.0
            self.endingReciever!.zPosition = 2
            self.endingReciever!.isHidden = true
            self.addChild(self.endingReciever!)
            
            var lvlNum:Int = {
                if self.params!.level == 99 {
                    return 0
                }else{
                    return self.params!.level + 1
                }
            }()
            
            let endingCityLabel = SKLabelNode(text: GameData.sharedInstance().levelData[lvlNum].cityName)
            endingCityLabel.position.x = self.startingReciever!.position.x
            endingCityLabel.position.y = self.startingReciever!.position.y + 80
            endingCityLabel.zPosition = 2
            endingCityLabel.fontName = "Helvetica-Bold"
            self.endingReciever!.addChild(endingCityLabel)

            let endingLevelImage = SKSpriteNode(imageNamed: "Tower_Off.png")
            endingLevelImage.setScale(0.70)
            endingLevelImage.anchorPoint = CGPoint(x: 0.5, y: 1)
            endingLevelImage.position.x = 0
            endingLevelImage.alpha = 0.80
            endingLevelImage.zPosition = 2
            endingLevelImage.name = "End"
            endingLevelImage.position.y += 75
            self.endingReciever!.addChild(endingLevelImage)

            lvlNum = {
                if self.params!.level == 99 {
                    return 1
                }else{
                    return self.params!.level + 2
                }
            }()
            
            let endLevelIndicator = SKLabelNode(text: "Level \(lvlNum)")
            endLevelIndicator.position.y = 120
            endLevelIndicator.fontColor = .white
            endLevelIndicator.fontName = "Helvetica-Bold"
            endLevelIndicator.alpha = 1.0
            endLevelIndicator.zPosition = 2
            self.endingReciever!.addChild(endLevelIndicator)
        }
    }

    //When the respective wavedrawer reaches its maximum length it notifies us to start the next wave drawer.
    internal func nextWaveDrawer(drawerID:Int){
        if self.params != nil{
            if drawerID == 1{
                self.waveDrawer2!.position = CGPoint.zero
                self.waveDrawer2!.sample(
                        waveHead: self.waveHead!,
                        sampleDelay: self.params!.waveDrawer.sampleDelay,
                        waveSpeed: self.params!.waveDrawer.waveSpeed)
                //Here we will stop sampling because the other wave drawer has started and they would simply
                // overlap and waste system resources.
                self.waveDrawer1!.removeAction(forKey: "sampling")
            }
            if drawerID == 2{
                self.waveDrawer1!.position = CGPoint.zero
                self.waveDrawer1!.sample(
                        waveHead: self.waveHead!,
                        sampleDelay: self.params!.waveDrawer.sampleDelay,
                        waveSpeed: self.params!.waveDrawer.waveSpeed)
                //Here we will stop sampling because the other wave drawer has started and they would simply
                // overlap and waste system resources.
                self.waveDrawer2!.removeAction(forKey: "sampling")
            }
        }
    }

    //When the respective wavedrawer reaches twice its maximum length it notifies us to reset the previous wavedrawer.
    internal func resetWaveDrawer(drawerID:Int){
        if drawerID == 1{
            self.waveDrawer1!.stopSampling()
        }
        if drawerID == 2{
            self.waveDrawer2!.stopSampling()
        }
    }

    //Call to activate the wave generator.
    func activateWaveGenerator(){
        if self.waveHead != nil{
            if self.params?.waveHead.isPlayer == false{
                //This is for automatically starting the boundary waves.
                self.waveHead!.activateWaveHead()
                if self.waveDrawer1 != nil && self.params != nil{
                    self.waveDrawer1!.sample(
                            waveHead: self.waveHead!,
                            sampleDelay: self.params!.waveDrawer.sampleDelay,
                            waveSpeed: self.params!.waveDrawer.waveSpeed)
                }
            }else{
                //Initialize the tapGesture here because by now we are sure that the wavegenerator has been added to the scene.
                //Clear out recognizers between level loads.
                if self.scene!.view?.gestureRecognizers != nil {
                    for ges in self.scene!.view!.gestureRecognizers! {
                        self.scene!.view!.removeGestureRecognizer(ges)
                    }
                }

                let temp = UILongPressGestureRecognizer(target: self, action: #selector(changeWaveHeadTravelDirection))
                temp.minimumPressDuration = 0.0
                temp.allowableMovement = 10.0
                temp.numberOfTouchesRequired = 1
                temp.numberOfTapsRequired = 0
                self.userTapRecognizer = temp
                self.scene!.view!.addGestureRecognizer(self.userTapRecognizer!)

                //This causes the player wave to draw as a straight line in the beginning
                // before taking off upwards. Looks better than immediately jumping into the
                // wave
                if self.waveDrawer1 != nil && self.params != nil{
                    self.waveDrawer1!.sample(
                            waveHead: self.waveHead!,
                            sampleDelay: self.params!.waveDrawer.sampleDelay,
                            waveSpeed: self.params!.waveDrawer.waveSpeed)
                }
                let linearDelay = SKAction.wait(forDuration: 1/60)
                let activation = SKAction.run({
                    self.startingReciever!.isHidden = false
                    self.startingReciever!.position.x -= self.params!.waveDrawer.waveSpeed

                    if self.startingReciever!.position.x <= -(UIScreen.main.bounds.width / 2) && self.isUserInteractionEnabled == false{
                        //Automatically start the player wavehead moving down.
                        self.resetAndRunScore()
                        self.updateWaveOscillationWith(forces: WaveType.playerSteady1())
                        self.waveHead!.activatePlayerWavehead(direction: .down)

                        //For collision detection purposes we need to know that this is the player node.
                        self.waveHead!.name = "Player"
                        self.isUserInteractionEnabled = true
                    }
                    if self.startingReciever!.position.x <= -(UIScreen.main.bounds.width){
                        self.removeAction(forKey: "StartingLine")
                        self.startingReciever!.removeFromParent()
                    }
                })
                self.run(SKAction.repeatForever(SKAction.sequence([activation, linearDelay])), withKey: "StartingLine")
            }
        }
    }

    //At the end of the level we stop the wave drawing.
    public func deactivateWaveGenerator(){
        if self.params!.waveHead.isPlayer == false{
            self.waveDrawer1!.removeAction(forKey: "sampling")
            self.waveDrawer2!.removeAction(forKey: "sampling")
        }else{
            self.isUserInteractionEnabled = false
            //Recenter the wavehead at the end to prevent it from running away.
            self.waveHead!.removeAllActions()
            self.waveHead!.run(SKAction.move(to: CGPoint(x: self.waveHead!.position.x, y: 0), duration: 0.25))
            self.waveScoreKeeper!.isHidden = true
            self.removeAllActions()

            let linearDelay = SKAction.wait(forDuration: 1/60)
            let activation = SKAction.run({
                self.endingReciever!.isHidden = false
                self.endingReciever!.position.x -= self.params!.waveDrawer.waveSpeed
                if self.endingReciever!.position.x <= 5{
                    self.removeAction(forKey: "EndingLine")
                    (self.endingReciever!.childNode(withName: "End") as! SKSpriteNode).texture = SKTexture(imageNamed: "Tower_On.png")
                }
            })
            self.run(SKAction.repeatForever(SKAction.sequence([activation, linearDelay])), withKey: "EndingLine")
        }
    }

    //Used to update oscillation style at any point by providing an array of new points
    public func updateWaveOscillationWith(forces:[[CGFloat]]){
        if self.waveHead != nil{
            self.waveHead!.changeOscillation(to: forces)
        }
    }

    //Used to update the score.
    internal func resetAndRunScore(){
        self.removeAction(forKey: "scorer")
        self.scoreUpdateDelegate!.updateScore(scoreKeeper: self.waveScoreKeeper!)
        var counter:Int = 1
        let scorer = SKAction.run({
            self.waveScoreKeeper!.text = String(counter*counter)
            counter += 1
        })
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.2), scorer])), withKey: "scorer")
    }

    //Trigger for changing the wave head travel direction on the y axis
    @objc private func changeWaveHeadTravelDirection(_ sender:UILongPressGestureRecognizer){
        //Send a call to handle user choice. This is essentially a cheap delegation to a scene
        // method for gesture recognition
        
        //If the scene has not finished initializing this level then we need to return or we crash
        if scoreUpdateDelegate == nil{
            return
        }
        
        if self.scene!.isPaused == true {
            if let vc = (self.scene as! GameScene).parentViewController {
                vc.handleGameResume()
                return
            }
        }
        
        switch sender.state{
        case .began:
            if self.isUserInteractionEnabled == true{
                if self.params != nil{
                    //Update the player score and reset the score keeper
                    self.resetAndRunScore()

                    //Change the travel direction of the wave.
                    if self.waveHead!.currentHeadDirection == .up{
                        self.waveHead!.activatePlayerWavehead(direction: .down)
                    }else if self.waveHead!.currentHeadDirection == .down{
                        self.waveHead!.activatePlayerWavehead(direction: .up)
                    }
                }
            }
            break
        default:
            break
        }
        
        if self.scene != nil {
            (self.scene as! GameScene).handleUserChoice(sender)
        }

    }
}


//Note the WaveHeadParams and WaveDrawerParams should only be used inside the WaveGenerator Params and not
// set indepenedently.
struct WaveHeadParameters{
    var headColor:UIColor
    var headSize:CGSize
    var isPlayer:Bool

    //Default initialization with simple values
    init(){
        self.headColor = .blue
        self.headSize = CGSize(width: 9, height: 9)
        self.isPlayer = false
    }
}

struct WaveDrawerParameters{
    var waveTexture:SKTexture
    var waveStroke:CGFloat
    var sampleDelay:Double
    var waveSpeed:CGFloat

    //Default initialization with simple values
    init(){
        self.waveTexture = SKTexture(imageNamed: "ObstacleSignalColor.png")
        self.waveStroke = 9
        self.sampleDelay = 1/60
        self.waveSpeed = 1
    }
}
///NOTE the sample delay and the sample shift are associated

//All relavent options for controlling how a wave is drawn and displayed.
struct WaveGeneratorParameters{
    var location:CGPoint
    var waveHead:WaveHeadParameters
    var waveDrawer:WaveDrawerParameters
    var level:Int

    init(){
        self.location = CGPoint(x: 0, y: 0)
        self.waveHead = WaveHeadParameters()
        self.waveDrawer = WaveDrawerParameters()
        self.level = 0
    }
}
