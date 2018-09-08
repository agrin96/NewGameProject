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

//Used to denote the direction in which a wavehead is traveling
enum Direction{
    case up, down
}

//Creates an oscillating up and down point which can be sampled and can act as the player.
fileprivate class WaveHead:SKSpriteNode {

    private var p_osciallationForces:[CGFloat] = []
    private var n_osciallationForces:[CGFloat] = []
    private var oscillationCount:Int = 0

    //used to track which direction the wave head is currently traveling
    var currentHeadDirection:Direction = .up

    required init?(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)
    }

    override init(texture: SKTexture?, color:UIColor, size:CGSize){
        super.init(texture: texture, color:color, size:size)
    }

    convenience init(params:WaveHeadParameters){
        self.init(texture: nil, color:params.headColor, size:params.headSize)
        //Run an initialization on the wavehead to make sure that all of necessary physics values
        // are set as required.
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        //Setup wavehead to detect collision with boundary waves if it is the player
        if params.isPlayer == true{
            self.physicsBody = SKPhysicsBody(circleOfRadius: (self.size.width / 1.5))
            self.physicsBody!.linearDamping = 0.0
            self.physicsBody!.friction = 0.0
            self.physicsBody!.density = 1

            self.physicsBody!.collisionBitMask = 1
            self.physicsBody!.categoryBitMask = 1
            self.physicsBody!.contactTestBitMask = 1
            self.physicsBody!.allowsRotation = false
            self.physicsBody!.usesPreciseCollisionDetection = true
        }

        self.p_osciallationForces = WaveType.steady().flatMap({$0})
        self.n_osciallationForces = WaveType.steady().flatMap({$0}).map({return -$0})
    }

    //Starts the infinite oscillation of the WaveHead
    func activateWaveHead(){
        self.oscillationCount = 0
        var goingUp = true

        let vectorChange = SKAction.run({
            if goingUp == true{
                self.position = CGPoint(x: self.position.x, y: (self.position.y + CGFloat(self.p_osciallationForces[self.oscillationCount])))
                self.oscillationCount += 1
                if self.oscillationCount >= self.p_osciallationForces.count{
                    self.oscillationCount = 0
                    goingUp = false
                }
            }else{
                self.position = CGPoint(x: self.position.x, y: (self.position.y + CGFloat(self.n_osciallationForces[self.oscillationCount])))
                self.oscillationCount += 1
                if self.oscillationCount >= self.n_osciallationForces.count{
                    self.oscillationCount = 0
                    goingUp = true
                }
            }
        })

        //Here we set a wait time of one frame between velocity changes to make sure our framerate is synced.
        let oscillationAction = SKAction.group([vectorChange, SKAction.wait(forDuration: 1/120)])
        self.run(SKAction.repeatForever(oscillationAction))
    }

    //Separate function which specifies when to activate the player wavehead. It takes an input parameter which
    // will be used to control whether it is moving up or down.
    func activatePlayerWavehead(direction:Direction){
        self.oscillationCount = 0
        self.currentHeadDirection = direction

        //Reset the previous action, whether it was going up or going down.
        self.removeAllActions()

        let vectorChange = SKAction.run({
            if direction == .up{
                self.position = CGPoint(x: self.position.x, y: (self.position.y + CGFloat(self.p_osciallationForces[self.oscillationCount])))
                self.oscillationCount += 1
                if self.oscillationCount >= self.p_osciallationForces.count{
                    self.oscillationCount = 0
                }
            }else if direction == .down{
                self.position = CGPoint(x: self.position.x, y: (self.position.y + CGFloat(self.n_osciallationForces[self.oscillationCount])))
                self.oscillationCount += 1
                if self.oscillationCount >= self.n_osciallationForces.count{
                    self.oscillationCount = 0
                }
            }
        })
        //Here we set a wait time of one frame between velocity changes to make sure our framerate is synced.
        let oscillationAction = SKAction.group([vectorChange, SKAction.wait(forDuration: 1/120)])
        self.run(SKAction.repeatForever(oscillationAction))
    }

    //Stops the infinite oscillation of the WaveHead
    func deactivateWaveHead(){
        self.removeAllActions()
    }

    //This funciton is used to inject different oscillation styles into the wavehead.
    func changeOscillation(to forces:[[CGFloat]]){
        self.oscillationCount = 0
        self.p_osciallationForces = forces.flatMap({$0})
        self.n_osciallationForces = forces.flatMap({$0}).map({return -$0})
    }
}

//Samples a wavehead to create and display a wave using a combination of wavehead and wavedrawer parameters.
fileprivate class WaveDrawer:SKShapeNode {
    //This number is used to differentiate between Wave Drawers in the wave generator.
    var waveDrawerNumber:Int = 0
    private var dynamicWavePath:CGMutablePath?
    private var physicsPath:CGMutablePath?

    //This is the maximum width of one possible wave in points.
    // chosen based on the width of the iphone X screen.
    private let maxWaveWidth:CGFloat = 400
    private var called:Bool = false

    var waveNotificationDelegate: WaveGenerationNotifier?

    required init?(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)
    }

    init(color:UIColor, strokeThickness:CGFloat, drawerNumber:Int, isPlayer:Bool){
        super.init()
        self.strokeColor = color
        self.lineWidth = strokeThickness
        self.lineCap = .round

        self.name = "drawer\(drawerNumber)"
        self.waveDrawerNumber = drawerNumber
        self.dynamicWavePath = CGMutablePath()
        if isPlayer == false{
            self.physicsPath = CGMutablePath()
        }
    }

    func sample(waveHead:WaveHead, sampleDelay:Double, waveSpeed:CGFloat){
        //We have to shift our sampling point forward constantly because the shapeNode is moving
        // backwards so to compensate we move the sampling point forwards.
        var shift:CGFloat = 0

        //Sample wavehead using constantly modifying subpaths. Without the closing of subpath
        // the shapenode will not draw the path as it deems it incomplete.
        self.dynamicWavePath!.move(to: CGPoint(x: shift, y: waveHead.position.y))

        //Secondary path which is continuous and will draw the physics body. We test if it is nil
        // because that means that this is the player wave and we do not use it here.
        if self.physicsPath != nil{
            self.physicsPath!.move(to: CGPoint(x: shift, y: waveHead.position.y))
        }
        let waveHeadSample = SKAction.run({
            self.dynamicWavePath!.addLine(to: CGPoint(x: shift, y: waveHead.position.y))
            if self.physicsPath != nil{
                self.physicsPath!.addLine(to: CGPoint(x: shift, y: waveHead.position.y))
            }
            self.dynamicWavePath!.closeSubpath()
            self.path = self.dynamicWavePath!

            shift += waveSpeed
            self.dynamicWavePath!.move(to: CGPoint(x: shift, y: waveHead.position.y))

            //When the wave is over its maximum length we notify the WaveGenerator to start the second
            // wave generator at the same time. This way the transition is smooth.
            // Otherwise the wrong notification comes first and the wave fails.
            // NOTE: Since the waves grow to twice the max size, we prevent this notification from being
            // called too much by using a flag.
            if self.frame.width >= (self.maxWaveWidth) && self.called == false{
                self.called = true
                self.waveNotificationDelegate!.nextWaveDrawer(drawerID: self.waveDrawerNumber)
            }
        })

        //To make the drawing of the line seem to be a smooth process we shift the shapenode
        // back. This is done at every frame and thus can be used to speed up or slow down
        // how fast the curves move.
        let shiftWaveGen = SKAction.run({
            self.position.x -= waveSpeed

            //When the wave is twice its allowable length we want to clear its path and push it to the front
            // to continue with our parallax effect. This helps achieve the "infinite wave" without killing
            // the hardware. Notifies the wavegenerator to call stopSampling.The 25 unit shift
            // is to make sure that this is always called after the start notification from the other wave.
            if self.position.x <= -(self.maxWaveWidth * 2 - 25) && self.called == true{
                self.waveNotificationDelegate!.resetWaveDrawer(drawerID: self.waveDrawerNumber)
            }
        })

        let smoothShifting = SKAction.group([shiftWaveGen, SKAction.wait(forDuration: sampleDelay)])
        let waveSampling = SKAction.group([waveHeadSample, SKAction.wait(forDuration: sampleDelay)])

        self.run(SKAction.repeatForever(smoothShifting), withKey: "shifting")
        self.run(SKAction.repeatForever(waveSampling), withKey: "sampling")

        if self.physicsPath != nil{
            updatePhysicsPath(waveSpeed: waveSpeed)
        }
    }

    //Updates the physics body of the object every X seconds to make sure that it is current.
    func updatePhysicsPath(waveSpeed:CGFloat){
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        queue.addOperation({
            let updatePath = SKAction.run({
                self.physicsBody = SKPhysicsBody(edgeChainFrom: self.physicsPath!)
                self.physicsBody!.contactTestBitMask = 1
                self.physicsBody!.collisionBitMask = 1
            })
            self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: Double(2 / waveSpeed)), updatePath])))
        })
    }

    //This acts as a complete reset on the wave drawer. Clearing both its path and dynamic path.
    func stopSampling(){
        self.removeAllActions()
        self.path = nil
        self.dynamicWavePath = CGMutablePath()
        if self.physicsPath != nil{
            self.physicsPath = CGMutablePath()
        }
        self.called = false
    }
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
    private var startingLine:SKSpriteNode?

    //This gesture recognizer will detect the user tapping on screen.
    private var userTapRecognizer:UIGestureRecognizer?

    //This will allow us to calculate score
    var scoreUpdateDelegate:ScoreChangeNotifier?

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

        //Adds a starting line that shows when the player can start to tap.
        self.startingLine = SKSpriteNode(color: .white, size: CGSize(width: 5, height: 900))
        self.startingLine!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.startingLine!.position.x = 187.5
        self.startingLine!.alpha = 0.25
        self.startingLine!.zPosition = 2
        self.addChild(self.startingLine!)

        //Adds a small score label to the player head.
        if self.params!.waveHead.isPlayer == true{
            self.waveScoreKeeper = SKLabelNode(text: "0")
            self.waveScoreKeeper!.fontName = "AvenirNext-Bold"
            self.waveScoreKeeper!.position = CGPoint(x: -self.waveHead!.size.width * 3, y: -self.waveHead!.size.height)
            self.waveScoreKeeper!.zPosition = 4
            self.waveScoreKeeper!.fontSize = 20
            self.waveScoreKeeper!.fontColor = .green
            self.waveHead!.addChild(self.waveScoreKeeper!)
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
                if self.params!.waveHead.isPlayer == true{
                    self.userTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeWaveHeadTravelDirection))
                    self.scene!.view!.addGestureRecognizer(self.userTapRecognizer!)
                }

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
                    self.startingLine!.position.x -= self.params!.waveDrawer.waveSpeed
                    if self.startingLine!.position.x <= 0 && self.isUserInteractionEnabled == false{
                        self.waveHead!.currentHeadDirection = .down
                        //For collision detection purposes we need to know that this is the player node.
                        self.waveHead!.name = "Player"
                        self.isUserInteractionEnabled = true
                    }
                    if self.startingLine!.position.x <= -300{
                        self.removeAction(forKey: "StartingLine")
                        self.startingLine!.removeFromParent()
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