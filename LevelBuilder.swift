//
// Created by Aleksandr Grin on 9/6/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//

//Contains utilities to construct unique and interesting levels

import SpriteKit
import GameplayKit

class WaveType{
    public class func simpleSin()->[CGFloat]{
        return Array([
            [CGFloat](repeatElement(0, count: 6)),
            [CGFloat](repeatElement(1, count: 6)),
            [CGFloat](repeatElement(2, count: 6)),
            [CGFloat](repeatElement(3, count: 6)),
            [CGFloat](repeatElement(2, count: 6)),
            [CGFloat](repeatElement(1, count: 6)),
            [CGFloat](repeatElement(0, count: 6))
        ].joined(separator: []))
    }
    public class func simpleSquare()->[CGFloat]{
        return Array([
            [CGFloat](repeatElement(0, count: 30)),
            [CGFloat](repeatElement(50, count: 1)),
            [CGFloat](repeatElement(0, count: 30))
        ].joined(separator: []))
    }
    public class func simpleTriangle()->[CGFloat]{
        return Array([
            [CGFloat](repeatElement(1, count: 60)),

        ].joined(separator: []))
    }
    public class func simpleTrapezoid()->[CGFloat]{
        return Array([
            [CGFloat](repeatElement(0, count: 30)),
            [CGFloat](repeatElement(1, count: 30))
        ].joined(separator: []))
    }

    //When doing shifting operations the associated wait should be short
    // so as not to allow the wavehead to move into the negative values.
    public class func shiftUpwards()->[CGFloat]{
        return Array([
            [CGFloat](repeatElement(0, count: 30)),
            [CGFloat](repeatElement(1, count: 30))
        ].joined(separator: []))
    }
    public class func shiftDownwards()->[CGFloat]{
        return Array([
            [CGFloat](repeatElement(0, count: 30)),
            [CGFloat](repeatElement(1, count: 30))
        ].joined(separator: []))
    }
}


class LevelBuilder{
    //Provides an SKAction which waits a certain amount of time.
    public class func wait(time:Double)->SKAction{
        return SKAction.wait(forDuration: time)
    }

    //Generates a random wait time between the two specified bounds. Used for endless
    // level generation to provide variety.
    public class func randWait(upper:Double,lower:Double)->SKAction{
        return SKAction.wait(forDuration: Double(arc4random_uniform(UInt32(upper - lower + 1))) + lower)
    }

    //Generates an SKAction which will cause the wavegenerator passed in to change oscillation.
    public class func changeWave(of:WaveGenerator, to:[CGFloat])->SKAction{
        return SKAction.run({of.updateWaveOscillationWith(forces: to)})
    }

    //Scales passed wavearray in the x and y direction. X makes the array longer by
    // duplicating elements and Y makes the individual elements larger.
    public class func scale(wave:[CGFloat], dx:Int, dy:CGFloat)->[CGFloat]{
        if dx < 0 || dy < 0{ return [] }

        var yScaledWave:[CGFloat] = wave.map({return $0 * dy})
        var finalWave:[[CGFloat]] = []

        for i in 1..<(yScaledWave.count-1) {
            //If this element is surrounded by zeros it is an instant change
            // so we shouldn't expand it, otherwise expand.
            if (yScaledWave[i-1] == 0 && yScaledWave[i+1] == 0 && yScaledWave[i] != 0) == false{
                var expandedWave:[CGFloat] = []
                for _ in 0..<dx{
                    expandedWave.append(yScaledWave[i] / CGFloat(dx))
                }
                finalWave.append(expandedWave)
            }
        }

        //Return a flat array of the expanded and scaled values
        return finalWave.flatMap({$0})
    }
}