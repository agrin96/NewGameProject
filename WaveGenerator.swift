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
                color: self.params!.waveDrawer.waveColor,
                strokeThickness: self.params!.waveDrawer.waveStroke,
                drawerNumber: 1,
                isPlayer: self.params!.waveHead.isPlayer)
        self.waveDrawer1!.waveNotificationDelegate = self
        self.waveDrawer1!.zPosition = 1
        self.addChild(self.waveDrawer1!)

        self.waveDrawer2 = WaveDrawer(
                color: self.params!.waveDrawer.waveColor,
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
            self.startingReciever = SKSpriteNode(color: .red, size: CGSize(width: 22, height: 400))
            self.startingReciever!.anchorPoint = CGPoint(x: 0.5, y: 1)
            self.startingReciever!.position.x = 0
            self.startingReciever!.alpha = 0.25
            self.startingReciever!.zPosition = 2
            self.startingReciever!.isHidden = true
            self.addChild(self.startingReciever!)

            //Add the ending reciever and hide it.
            self.endingReciever = SKSpriteNode(color: .red, size: CGSize(width: 22, height: 400))
            self.endingReciever!.anchorPoint = CGPoint(x: 0.5, y: 1)
            self.endingReciever!.position.x = 187.5
            self.endingReciever!.alpha = 0.25
            self.endingReciever!.zPosition = 2
            self.endingReciever!.isHidden = true
            self.addChild(self.endingReciever!)
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
                self.userTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeWaveHeadTravelDirection))
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

                    if self.startingReciever!.position.x <= -170 && self.isUserInteractionEnabled == false{
                        self.waveHead!.currentHeadDirection = .down
                        //For collision detection purposes we need to know that this is the player node.
                        self.waveHead!.name = "Player"
                        self.isUserInteractionEnabled = true
                    }
                    if self.startingReciever!.position.x <= -200{
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
                if self.endingReciever!.position.x <= 0{
                    self.removeAction(forKey: "EndingLine")
                    self.endingReciever!.color = .green
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
        var counter:Int = 1
        let scorer = SKAction.run({
            self.waveScoreKeeper!.text = String(counter*counter)
            counter += 1
        })
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.2), scorer])), withKey: "scorer")
    }

    //Trigger for changing the wave head travel direction on the y axis
    @objc private func changeWaveHeadTravelDirection(_ sender:UITapGestureRecognizer){
        switch sender.state{
        case .began,.changed,.ended:
            if self.isUserInteractionEnabled == true{
                if self.params != nil{
                    //Update the player score and reset the score keeper
                    self.scoreUpdateDelegate!.updateScore(scoreKeeper: self.waveScoreKeeper!)
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
    var waveColor:UIColor
    var waveStroke:CGFloat
    var sampleDelay:Double
    var waveSpeed:CGFloat

    //Default initialization with simple values
    init(){
        self.waveColor = .blue
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

    init(){
        self.location = CGPoint(x: 0, y: 0)
        self.waveHead = WaveHeadParameters()
        self.waveDrawer = WaveDrawerParameters()
    }
}