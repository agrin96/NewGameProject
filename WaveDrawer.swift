//
// Created by Aleksandr Grin on 9/12/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//

import SpriteKit

//Samples a wavehead to create and display a wave using a combination of wavehead and wavedrawer parameters.
class WaveDrawer:SKShapeNode {
    //This number is used to differentiate between Wave Drawers in the wave generator.
    var waveDrawerNumber:Int = 0
    private var dynamicWavePath:CGMutablePath?
    private var physicsPath:CGMutablePath?

    //This is the maximum width of one possible wave in points.
    // chosen based on the width of the iphone X screen.
    private var maxWaveWidth:CGFloat = 400
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
        }else{
            //If this is the player wave then we don't need as long of a draw period.
            // therefore we set a smaller limit than the default 400
            self.maxWaveWidth = 200
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
                self.physicsBody!.categoryBitMask = 0
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

