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
protocol waveGenerationNotifier:class{
    func nextWaveDrawer(drawerID:Int)
    func resetWaveDrawer(drawerID:Int)
}

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
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody!.linearDamping = 0.0
        self.physicsBody!.friction = 0.0
        self.physicsBody!.density = 1

        //Make sure that the waveheads never interact with eachother.
        self.physicsBody!.collisionBitMask = 0
        self.physicsBody!.categoryBitMask = 0
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
        DispatchQueue.main.async {
            var count = 0
            var goingUp = true

            let vectorChange = SKAction.run({
                if goingUp == true{
                    self.physicsBody!.velocity = CGVector(dx: 0, dy: self.p_osciallationForces[count])
                    count += 1
                    if count >= self.p_osciallationForces.count{
                        count = 0
                        goingUp = false
                    }
                }else{
                    self.physicsBody!.velocity = CGVector(dx: 0, dy: self.n_osciallationForces[count])
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
    }

    //Separate function which specifies when to activate the player wavehead. It takes an input parameter which
    // will be used to control whether it is moving up or down.
    func activatePlayerWavehead(direction:Direction){
        DispatchQueue.main.async{
            var count = 0
            self.currentHeadDirection = direction

            //Reset the previous action, whether it was going up or going down.
            self.removeAllActions()

            let vectorChange = SKAction.run({
                if direction == .up{
                    self.physicsBody!.velocity = CGVector(dx: 0, dy: self.p_osciallationForces[count])
                    count += 1
                    if count >= self.p_osciallationForces.count{
                        count = 0
                    }
                }else if direction == .down{
                    self.physicsBody!.velocity = CGVector(dx: 0, dy: self.n_osciallationForces[count])
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
    }

    //Stops the infinite oscillation of the WaveHead
    func deactivateWaveHead(){
        DispatchQueue.main.async {
            self.removeAllActions()
        }
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

    var waveNotificationDelegate:waveGenerationNotifier?

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
        DispatchQueue.main.async{
            //We have to shift our sampling point forward constantly because the shapeNode is moving
            // backwards so to compensate we move the sampling point forwards.
            var shift:CGFloat = 0

            //Sample wavehead using constantly modifying subpaths. Without the closing of subpath
            // the shapenode will not draw the path as it deems it incomplete.
            let waveHeadSample = SKAction.run({
                self.dynamicWavePath!.addLine(to: CGPoint(x: shift, y: waveHead.position.y))
                self.dynamicWavePath!.closeSubpath()
                self.path = self.dynamicWavePath!
                self.dynamicWavePath!.move(to: CGPoint(x: shift, y: waveHead.position.y))
                shift += sampleShift

                //When the wave is over its maximum length we notify the WaveGenerator to start the second
                // wave generator at the same time. This way the transition is smooth. The 25 unit shift
                // is to make sure that this is always called before the stop notification from the other wave.
                // Otherwise the wrong notification comes first and the wave fails.
                // NOTE: Since the waves grow to twice the max size, we prevent this notification from being
                // called too much by using a flag.
                if self.frame.width >= (self.maxWaveWidth+25) && self.called == false{
                    self.called = true
                    self.waveNotificationDelegate!.nextWaveDrawer(drawerID: self.waveDrawerNumber)
                }

                //When the wave is twice its allowable length we want to clear its path and push it to the front
                // to continue with our parallax effect. This helps achieve the "infinite wave" without killing
                // the hardware. Notifies the wavegenerator to call stopSampling.
                if self.frame.width >= (self.maxWaveWidth*2){
                    self.waveNotificationDelegate!.resetWaveDrawer(drawerID: self.waveDrawerNumber)
                }
            })

            //To make the drawing of the line seem to be a smooth process we shift the shapenode
            // back. This is done at every frame and thus can be used to speed up or slow down
            // how fast the curves move.
            let shiftWaveGen = SKAction.run({
                self.position.x -= waveSpeed
            })

            let smoothShifting = SKAction.group([shiftWaveGen, SKAction.wait(forDuration: 1/60)])
            let waveSampling = SKAction.group([waveHeadSample, SKAction.wait(forDuration: sampleDelay)])

            self.run(SKAction.repeatForever(smoothShifting))
            self.run(SKAction.repeatForever(waveSampling))
        }
    }

    //This acts as a complete reset on the wave drawer. Clearing both its path and dynamic path.
    func stopSampling(){
        DispatchQueue.main.async{
            self.removeAllActions()
            self.path = nil
            self.dynamicWavePath = CGMutablePath()
            self.called = false
        }
    }
}

//Generates a wave starting at a location and drawing backwards.
class WaveGenerator:SKNode, waveGenerationNotifier, UIGestureRecognizerDelegate{
    //This is the wave head which will serve as our drawing point.
    private var waveHead:WaveHead?

    //We use two wavedrawers to acheive an infinite wave parallalax effect
    private var waveDrawer1:WaveDrawer?
    private var waveDrawer2:WaveDrawer?

    //Store parameters for the waveGenerator
    private var params:WaveGeneratorParameters?

    //This gesture recognizer will detect the user tapping on screen.
    private var userTapRecognizer:UIGestureRecognizer?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(paramters:WaveGeneratorParameters){
        super.init()
        self.params = paramters
        self.position = self.params!.location

        self.waveHead  = WaveHead(
                color: self.params!.waveHead.headColor,
                size: self.params!.waveHead.headSize)

        self.waveHead!.generateOscillationForWaveHeadWith(
                amplitude: self.params!.waveHead.amplitude,
                frequency: self.params!.waveHead.frequency,
                numSamples: self.params!.waveHead.numSamples)
        self.addChild(self.waveHead!)

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
                print("starting 2")
                self.waveDrawer2!.position = CGPoint.zero
                self.waveDrawer2!.sample(
                        waveHead: self.waveHead!,
                        sampleDelay: self.params!.waveDrawer.sampleDelay,
                        sampleShift: self.params!.waveDrawer.sampleShift,
                        waveSpeed: self.params!.waveDrawer.waveSpeed)
            }
            if drawerID == 2{
                print("starting 1")
                self.waveDrawer1!.position = CGPoint.zero
                self.waveDrawer1!.sample(
                        waveHead: self.waveHead!,
                        sampleDelay: self.params!.waveDrawer.sampleDelay,
                        sampleShift: self.params!.waveDrawer.sampleShift,
                        waveSpeed: self.params!.waveDrawer.waveSpeed)
            }
        }
    }

    //When the respective wavedrawer reaches twice its maximum length it notifies us to reset the previous wavedrawer.
    internal func resetWaveDrawer(drawerID:Int){
        if drawerID == 1{
            print("stopping 1")
            self.waveDrawer1!.stopSampling()
        }
        if drawerID == 2{
            print("stopping 2")
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
                let linearDelay = SKAction.wait(forDuration: 3)
                let activation = SKAction.run({
                    self.waveHead!.activatePlayerWavehead(direction: .up)
                })
                self.run(SKAction.sequence([linearDelay,activation]))
            }
        }

    }

    //Trigger for changing the wave head travel direction on the y axis
    @objc private func changeWaveHeadTravelDirection(_ sender:UITapGestureRecognizer){
        if self.params != nil{
            if self.waveHead!.currentHeadDirection == .up{
                self.waveHead!.activatePlayerWavehead(direction: .down)
            }else if self.waveHead!.currentHeadDirection == .down{
                self.waveHead!.activatePlayerWavehead(direction: .up)
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
        self.amplitude = 150
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
///NOTE the sampe delay and the sample shift are associated

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