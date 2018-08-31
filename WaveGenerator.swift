//
// Created by Aleksandr Grin on 8/31/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//

//This will be responsible for taking input parameters and generating wave objects that can be plotted.
// The wave objects will consist of SKShapeNodes which can be added as a parallax effect to the main game
// screen.

import SpriteKit
import CoreGraphics

class WaveGenerator {

    var waveObject:SKShapeNode?

    init(){
        if self.waveObject == nil{
            self.waveObject = SKShapeNode()
            self.waveObject!.path = generateSinusoid(amplitude: 30, frequency: 3, width: 360, numSamples: 200)
            self.waveObject!.lineWidth = 3
        }
    }

    func generateSinusoid(amplitude:Double, frequency:Double, width:Double, numSamples:Int) -> CGMutablePath{
        //Create a mutable path object and move it to the starting location
        let newPath = CGMutablePath()

        //Since we stroke a path by adding a curve between successive points we find a deltaX value for the points
        let deltaX:Double = width / Double(numSamples)

        //This will center our path on the center of the node.
        let offsetX:Double = width / 2

        for i in 0..<numSamples{
            if i == 0{
                let yVal = amplitude * sin((2*Double.pi*frequency*Double(i)) / Double(numSamples))
                newPath.move(to: CGPoint(x: Double(i)*deltaX - offsetX, y: yVal))
            }else{
                let yVal = amplitude * sin((2*Double.pi*frequency*Double(i)) / Double(numSamples))
                newPath.addLine(to: CGPoint(x: Double(i)*deltaX - offsetX, y: yVal))
            }
        }

        return newPath
    }
}