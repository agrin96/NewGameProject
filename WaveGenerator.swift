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
    func updateScore(previousDirection:Direction)
}

//Used to denote the direction in which a wavehead is traveling
enum Direction{
    case up, down
}

//Creates an oscillating up and down point which can be sampled and can act as the player.
fileprivate class WaveHead:SKSpriteNode {

    private var p_osciallationForces:[Int] = []
    private var n_osciallationForces:[Int] = []

    //used to track which direction the wave head is currently traveling
    var currentHeadDirection:Direction = .up

    required init?(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)
    }

    override init(texture: SKTexture?, color:UIColor, size:CGSize){
        super.init(texture: texture, color:color, size:size)
    }

    convenience init(color:UIColor, size:CGSize){
        self.init(texture: nil, color:color, size:size)
        //Run an initialization on the wavehead to make sure that all of necessary physics values
        // are set as required.
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.physicsBody = SKPhysicsBody(circleOfRadius: (self.size.width / 2 * 0.9))
        self.physicsBody!.linearDamping = 0.0
        self.physicsBody!.friction = 0.0
        self.physicsBody!.density = 1

        //Setup wavehead to detect collision with boundary waves
        self.physicsBody!.collisionBitMask = 1
        self.physicsBody!.categoryBitMask = 1
        self.physicsBody!.contactTestBitMask = 1
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.usesPreciseCollisionDetection = true
    }

    //Will initialize the physics properties of the wavehead and generate a set of values for its
    // y-axis oscillation which will be used to draw the sine waves.
    func generateOscillationForWaveHeadWith(amplitude:Double, frequency:Double, numSamples:Int){
        //Generate a set of values by which the waveHead will oscillation on the y-axis of the screen.
        // Note we multiply the amplitude by the frequency because otherwise increasing the frequency
        // decreases the amplitude due to how we generate the sine waves.
        for i in 0..<numSamples{
            let yVal = amplitude * frequency * sin((2*Double.pi*frequency*Double(i)) / Double(numSamples+1))
            if yVal < 0{
                break
            }
            self.p_osciallationForces.append(Int(yVal))
        }
        //The loop above will return only the first positive arc of the sin function. Here we copy and
        // negate all the values to make sure our negative arc is a perfect reflection. Otherwise
        // we run into issues of desync between slightly different values
        self.n_osciallationForces = self.p_osciallationForces.map{return -$0}
    }

    //Starts the infinite oscillation of the WaveHead on a async queue since animation is taxing and we want it
    // to not hog the CPU/GPU.
    func activateWaveHead(){
        var count = 0
        var goingUp = true

        let vectorChange = SKAction.run({
            if goingUp == true{
                self.position = CGPoint(x: self.position.x, y: (self.position.y + CGFloat(self.p_osciallationForces[count])))
                count += 1
                if count >= self.p_osciallationForces.count{
                    count = 0
                    goingUp = false
                }
            }else{
                self.position = CGPoint(x: self.position.x, y: (self.position.y + CGFloat(self.n_osciallationForces[count])))
                count += 1
                if count >= self.n_osciallationForces.count{
                    count = 0
                    goingUp = true
                }
            }
        })

        //Here we set a wait time of one frame between velocity changes to make sure our framerate is synced.
        let oscillationAction = SKAction.group([vectorChange, SKAction.wait(forDuration: 1/60)])
        self.run(SKAction.repeatForever(oscillationAction))
    }

    //Separate function which specifies when to activate the player wavehead. It takes an input parameter which
    // will be used to control whether it is moving up or down.
    func activatePlayerWavehead(direction:Direction){
        var count = 0
        self.currentHeadDirection = direction

        //Reset the previous action, whether it was going up or going down.
        self.removeAllActions()

        let vectorChange = SKAction.run({
            if direction == .up{
                self.position = CGPoint(x: self.position.x, y: (self.position.y + CGFloat(self.p_osciallationForces[count])))
                count += 1
                if count >= self.p_osciallationForces.count{
                    count = 0
                }
            }else if direction == .down{
                self.position = CGPoint(x: self.position.x, y: (self.position.y + CGFloat(self.n_osciallationForces[count])))
                count += 1
                if count >= self.n_osciallationForces.count{
                    count = 0
                }
            }
        })
        //Here we set a wait time of one frame between velocity changes to make sure our framerate is synced.
        let oscillationAction = SKAction.group([vectorChange, SKAction.wait(forDuration: 1/60)])
        self.run(SKAction.repeatForever(oscillationAction))
    }

    //Stops the infinite oscillation of the WaveHead
    func deactivateWaveHead(){
        self.removeAllActions()
    }

    //This funciton is used to inject different oscillation styles into the wavehead.
    func changeOscillation(to forces:[Int]){
        self.p_osciallationForces = forces
        self.n_osciallationForces = forces.map({return -$0})
    }
}

//Samples a wavehead to create and display a wave using a combination of wavehead and wavedrawer parameters.
fileprivate class WaveDrawer:SKShapeNode {
    //This number is used to differentiate between Wave Drawers in the wave generator.
    var waveDrawerNumber:Int = 0
    private var dynamicWavePath:CGMutablePath?

    //This is the maximum width of one possible wave in points.
    // chosen based on the width of the iphone X screen.
    private let maxWaveWidth:CGFloat = 400
    private var called:Bool = false

    var waveNotificationDelegate: WaveGenerationNotifier?

    required init?(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)
    }

    init(color:UIColor, strokeThickness:CGFloat, drawerNumber:Int){
        super.init()
        self.strokeColor = color
        self.lineWidth = strokeThickness
        self.lineCap = .round

        self.waveDrawerNumber = drawerNumber
        self.dynamicWavePath = CGMutablePath()
    }

    func sample(waveHead:WaveHead, sampleDelay:Double, sampleShift:CGFloat, waveSpeed:CGFloat){
        //We have to shift our sampling point forward constantly because the shapeNode is moving
        // backwards so to compensate we move the sampling point forwards.
        var shift:CGFloat = 0

        //Sample wavehead using constantly modifying subpaths. Without the closing of subpath
        // the shapenode will not draw the path as it deems it incomplete.
        self.dynamicWavePath!.move(to: CGPoint(x: shift, y: waveHead.position.y))
        let waveHeadSample = SKAction.run({
            self.dynamicWavePath!.addLine(to: CGPoint(x: shift, y: waveHead.position.y))
            self.dynamicWavePath!.closeSubpath()
            self.path = self.dynamicWavePath!
            self.dynamicWavePath!.move(to: CGPoint(x: shift, y: waveHead.position.y))
            shift += sampleShift

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

        let smoothShifting = SKAction.group([shiftWaveGen, SKAction.wait(forDuration: 1/60)])
        let waveSampling = SKAction.group([waveHeadSample, SKAction.wait(forDuration: sampleDelay)])

        self.run(SKAction.repeatForever(smoothShifting), withKey: "shifting")
        self.run(SKAction.repeatForever(waveSampling), withKey: "sampling")
    }

    //This acts as a complete reset on the wave drawer. Clearing both its path and dynamic path.
    func stopSampling(){
        self.removeAllActions()
        self.path = nil
        self.dynamicWavePath = CGMutablePath()
        self.called = false
    }
}

//Generates a wave starting at a location and drawing backwards.
class WaveGenerator:SKNode, WaveGenerationNotifier, UIGestureRecognizerDelegate{
    //This is the wave head which will serve as our drawing point.
    private var waveHead:WaveHead?

    //Here we define a hidden wavehead which will help us keep score and collision detection.
    private var collisionWaveHead:WaveHead?

    //We use two wavedrawers to acheive an infinite wave parallalax effect
    private var waveDrawer1:WaveDrawer?
    private var waveDrawer2:WaveDrawer?

    //Store parameters for the waveGenerator
    private var params:WaveGeneratorParameters?
    //The approximate time it takes for spawned waves to get to the player
    private let levelBeginDelay:Double = 3.125

    //This gesture recognizer will detect the user tapping on screen.
    private var userTapRecognizer:UIGestureRecognizer?

    //This will allow us to calculate score
    var scoreUpdateDelegate:ScoreChangeNotifier?

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
        self.waveHead  = WaveHead(
                color: self.params!.waveHead.headColor,
                size: self.params!.waveHead.headSize)
        self.waveHead!.generateOscillationForWaveHeadWith(
                amplitude: self.params!.waveHead.amplitude,
                frequency: self.params!.waveHead.frequency,
                numSamples: self.params!.waveHead.numSamples)
        self.addChild(self.waveHead!)

        //Setup the collision wavehead which will help keep score and detect collisions.
        if self.params!.waveHead.isPlayer == false{
            self.collisionWaveHead = WaveHead(
                    color: self.params!.waveHead.headColor,
                    size: CGSize(
                            width: self.params!.waveHead.headSize.width,
                            height: self.params!.waveHead.headSize.height))

            //Hide waveheads from view if this isn't a player.
            self.collisionWaveHead!.isHidden = true
            self.waveHead!.isHidden = true

            //Center the collision WaveHead on the screen
            self.collisionWaveHead!.position = CGPoint(x: -self.params!.location.x, y: 0)
            self.collisionWaveHead!.generateOscillationForWaveHeadWith(
                    amplitude: self.params!.waveHead.amplitude,
                    frequency: self.params!.waveHead.frequency,
                    numSamples: self.params!.waveHead.numSamples)
            self.addChild(self.collisionWaveHead!)
        }

        //Setup the two wavedrawers for the infinite parallax effect
        self.waveDrawer1 = WaveDrawer(
                color: self.params!.waveDrawer.waveColor,
                strokeThickness: self.params!.waveDrawer.waveStroke,
                drawerNumber: 1)
        self.waveDrawer1!.waveNotificationDelegate = self
        self.addChild(self.waveDrawer1!)

        self.waveDrawer2 = WaveDrawer(
                color: self.params!.waveDrawer.waveColor,
                strokeThickness: self.params!.waveDrawer.waveStroke,
                drawerNumber: 2)
        self.waveDrawer2!.waveNotificationDelegate = self
        self.addChild(self.waveDrawer2!)
    }

    //When the respective wavedrawer reaches its maximum length it notifies us to start the next wave drawer.
    internal func nextWaveDrawer(drawerID:Int){
        if self.params != nil{
            if drawerID == 1{
                self.waveDrawer2!.position = CGPoint.zero
                self.waveDrawer2!.sample(
                        waveHead: self.waveHead!,
                        sampleDelay: self.params!.waveDrawer.sampleDelay,
                        sampleShift: self.params!.waveDrawer.sampleShift,
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
                        sampleShift: self.params!.waveDrawer.sampleShift,
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
                            sampleShift: self.params!.waveDrawer.sampleShift,
                            waveSpeed: self.params!.waveDrawer.waveSpeed)
                }
                //We start the collision detection wave head only when the player has made it to the wave.
                let linearDelay = SKAction.wait(forDuration: levelBeginDelay)
                let activation = SKAction.run({
                    self.collisionWaveHead!.activateWaveHead()
                })
                self.run(SKAction.sequence([linearDelay,activation]))

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
                            sampleShift: self.params!.waveDrawer.sampleShift,
                            waveSpeed: self.params!.waveDrawer.waveSpeed)
                }
                let linearDelay = SKAction.wait(forDuration: levelBeginDelay)
                let activation = SKAction.run({
                    self.waveHead!.activatePlayerWavehead(direction: .up)
                    //For collision detection purposes we need to know that this is the player node.
                    self.waveHead!.name = "Player"
                    self.isUserInteractionEnabled = true
                })
                self.run(SKAction.sequence([linearDelay,activation]))
            }
        }
    }

    //Used to stop all relevant wave generating operations.
    func deactivateWaveGenerator(){
        if self.waveHead != nil{
            self.position = self.params!.location
            self.waveHead!.deactivateWaveHead()
            self.waveHead!.position = CGPoint.zero

            self.waveDrawer1!.stopSampling()
            self.waveDrawer1!.position = CGPoint.zero

            self.waveDrawer2!.stopSampling()
            self.waveDrawer2!.position = CGPoint.zero

            //Reset the collision only if this isnt a player.
            if self.params!.waveHead.isPlayer == false{
                self.collisionWaveHead!.deactivateWaveHead()
                self.collisionWaveHead!.position = CGPoint(x: -self.params!.location.x, y: 0)
                self.removeAllActions()
            }
        }
    }

    //Utility for getting position used in score calculation.
    //Note, for this to work we need to convert position to scene coordinates so everything matches
    public func getCollisionWaveHeadPosition() -> CGFloat {
        if self.collisionWaveHead != nil {
            return self.scene!.convert(self.collisionWaveHead!.position, from: self).y
        }else{
            return 0
        }
    }

    //Utility for getting position used in score calculation
    //Note, for this to work we need to convert position to scene coordinates so everything matches
    public func getPrimaryWaveHeadPosition() -> CGFloat {
        if self.waveHead != nil {
            return self.scene!.convert(self.waveHead!.position, from: self).y
        }else{
            return 0
        }
    }

    //Used to update oscillation style at any point by providing an array of new points
    public func updateWaveOscillationWith(forces:[Int]){
        if self.waveHead != nil{
            self.waveHead!.changeOscillation(to: forces)
            //If this isn't a player wave we have to also change the collision wavehead oscillation
            if self.collisionWaveHead != nil{
                self.run(SKAction.sequence([SKAction.wait(forDuration: self.levelBeginDelay), SKAction.run({
                    self.collisionWaveHead!.changeOscillation(to: forces)
                })]))
            }
        }
    }

    //Trigger for changing the wave head travel direction on the y axis
    @objc private func changeWaveHeadTravelDirection(_ sender:UITapGestureRecognizer){
        if self.isUserInteractionEnabled == true{
            if self.params != nil{
                if self.waveHead!.currentHeadDirection == .up{
                    //Update score and change direction.
                    self.scoreUpdateDelegate!.updateScore(previousDirection: .up)
                    self.waveHead!.activatePlayerWavehead(direction: .down)
                }else if self.waveHead!.currentHeadDirection == .down{
                    //Update score and change direction
                    self.scoreUpdateDelegate!.updateScore(previousDirection: .down)
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
    var amplitude:Double
    var frequency:Double
    var numSamples:Int
    var isPlayer:Bool

    //Default initialization with simple values
    init(){
        self.headColor = .blue
        self.headSize = CGSize(width: 9, height: 9)
        self.amplitude = 3
        self.frequency = 1
        self.numSamples = 100
        self.isPlayer = false
    }
}

struct WaveDrawerParameters{
    var waveColor:UIColor
    var waveStroke:CGFloat
    var sampleDelay:Double
    var sampleShift:CGFloat
    var waveSpeed:CGFloat

    //Default initialization with simple values
    init(){
        self.waveColor = .blue
        self.waveStroke = 9
        self.sampleDelay = 2/60
        self.sampleShift = 2
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

    mutating func setSimpleSinusoid() {

    }
}