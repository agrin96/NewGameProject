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

class WaveHead:SKSpriteNode {

    private var osciallationForces:[Int] = []

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
            self.osciallationForces.append(Int(yVal))
        }
        //The loop above will return only the first positive arc of the sin function. Here we copy and
        // negate all the values to make sure our negative arc is a perfect reflection. Otherwise
        // we run into issues of desync between slightly different values
        let negatedOscillations = self.osciallationForces.map{return -$0}
        self.osciallationForces.append(contentsOf: negatedOscillations)
    }

    //Starts the infinite oscillation of the WaveHead on a async queue since animation is taxing and we want it
    // to not hog the CPU/GPU.
    func activateWaveHead(){
        DispatchQueue.main.async {
            var count = 0

            let vectorChange = SKAction.run({
                self.physicsBody!.velocity = CGVector(dx: 0, dy: self.osciallationForces[count])
                count += 1
                if count >= self.osciallationForces.count {
                    count = 0
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

class WaveDrawer:SKShapeNode {
    //This number is used to differentiate between Wave Drawers in the wave generator.
    var waveDrawerNumber:Int = 0
    private var dynamicWavePath:CGMutablePath?

    //This is the maximum width of one possible wave in points.
    // chosen based on the width of the iphone X screen.
    private let maxWaveWidth:CGFloat = 600
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

class WaveGenerator:SKNode, waveGenerationNotifier{

    //This is the wave head which will serve as our drawing point.
    private var waveHead:WaveHead?

    //We use two wavedrawers to acheive an infinite wave parallalax effect
    private var waveDrawer1:WaveDrawer?
    private var waveDrawer2:WaveDrawer?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(wave:WaveType, headLocation:CGPoint){
        super.init()
        self.position = headLocation

        self.waveHead  = WaveHead(color: .blue, size: CGSize(width: 12, height: 12))
        self.waveHead!.generateOscillationForWaveHeadWith(amplitude: 150, frequency: 1, numSamples: 100)
        self.waveHead!.position = self.position
        self.addChild(self.waveHead!)

        self.waveDrawer1 = WaveDrawer(color: .blue, strokeThickness: 9, drawerNumber: 1)
        self.waveDrawer1!.position = self.position
        self.waveDrawer1!.waveNotificationDelegate = self
        self.addChild(self.waveDrawer1!)

        self.waveDrawer2 = WaveDrawer(color: .blue, strokeThickness: 9, drawerNumber: 2)
        self.waveDrawer2!.position = self.position
        self.waveDrawer2!.waveNotificationDelegate = self
        self.addChild(self.waveDrawer2!)
    }

    //When the respective wavedrawer reaches its maximum length it notifies us to start the next wave drawer.
    internal func nextWaveDrawer(drawerID:Int){
        if drawerID == 1{
            print("starting 2")
            self.waveDrawer2!.position = self.position
            self.waveDrawer2!.sample(waveHead: self.waveHead!, sampleDelay: 1/60, sampleShift: 3, waveSpeed: 3)
        }
        if drawerID == 2{
            print("starting 1")
            self.waveDrawer1!.position = self.position
            self.waveDrawer1!.sample(waveHead: self.waveHead!, sampleDelay: 1/60, sampleShift: 3, waveSpeed: 3)
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
            self.waveHead!.activateWaveHead()
        }
        if self.waveDrawer1 != nil{
            self.waveDrawer1!.sample(waveHead: self.waveHead!, sampleDelay: 1/60, sampleShift: 3, waveSpeed: 3)
        }
    }
}


enum WaveType:Int{
    case simpleSinusoid_1 = 0
    case simpleSinusoid_2 = 1
}