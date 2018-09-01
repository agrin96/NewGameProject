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

class WaveHead:SKSpriteNode {

    private var osciallationForces:[Double] = []

    required init?(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)
    }

    override init(texture: SKTexture?, color:UIColor, size:CGSize){
        super.init(texture: texture, color:color, size:size)
    }

    convenience init(color:UIColor, size:CGSize){
        self.init(texture: nil, color:color, size:size)
        self.generateOscillationForWaveHeadWith(amplitude: 150, frequency: 1, numSamples: 100)
    }

    //Will initialize the physics properties of the wavehead and generate a set of values for its
    // y-axis oscillation which will be used to draw the sine waves.
    private func generateOscillationForWaveHeadWith(amplitude:Double, frequency:Double, numSamples:Int){
        //Run an initialization on the wavehead to make sure that all of necessary physics values
        // are set as required.
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody!.linearDamping = 0.0
        self.physicsBody!.friction = 0.0
        self.physicsBody!.density = 1

        //Generate a set of values by which the waveHead will oscillation on the y-axis of the screen
        for i in 0..<numSamples{
            let yVal = amplitude * sin((2*Double.pi*frequency*Double(i)) / Double(numSamples+1))
            self.osciallationForces.append(yVal)
        }
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
    var dynamicWavePath:CGMutablePath?

    required init?(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)
    }

    init(color:UIColor, strokeThickness:CGFloat){
        super.init()
        self.strokeColor = color
        self.lineWidth = strokeThickness
        self.lineCap = .round

        self.dynamicWavePath = CGMutablePath()
    }

    func sample(waveHead:WaveHead, sampleDelay:Double, sampleShift:CGFloat){

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
            })

            //To make the drawing of the line seem to be a smooth process we shift the shapenode
            // back. This is done at every frame and thus can be used to speed up or slow down
            // how fast the curves move.
            let shiftWaveGen = SKAction.run({
                self.position.x -= 2
            })

            let smoothShifting = SKAction.group([shiftWaveGen, SKAction.wait(forDuration: 1/60)])
            let waveSampling = SKAction.group([waveHeadSample, SKAction.wait(forDuration: sampleDelay)])

            self.run(SKAction.repeatForever(smoothShifting))
            self.run(SKAction.repeatForever(waveSampling))
        }
    }

    func stopSampling(){
        DispatchQueue.main.async{
            self.removeAllActions()
        }
    }


}