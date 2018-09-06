//
// Created by Aleksandr Grin on 9/6/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//

//Contains utilities to construct unique and interesting levels

import SpriteKit

class WaveType{
    public class func simpleSin()->[CGFloat]{
        return Array([
            [CGFloat](repeatElement(0, count: 5)),
            [CGFloat](repeatElement(1, count: 5)),
            [CGFloat](repeatElement(2, count: 5)),
            [CGFloat](repeatElement(3, count: 5)),
            [CGFloat](repeatElement(4, count: 5)),
            [CGFloat](repeatElement(3, count: 5)),
            [CGFloat](repeatElement(2, count: 5)),
            [CGFloat](repeatElement(1, count: 5)),
            [CGFloat](repeatElement(0, count: 5))
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
    public class func wait(time:Double)->SKAction{
        return SKAction.wait(forDuration: time)
    }
    public class func changeWave(of:WaveGenerator, to:[CGFloat])->SKAction{
        return SKAction.run({of.updateWaveOscillationWith(forces: to)})
    }
    public class func scale(wave:[CGFloat], dx:CGFloat, dy:CGFloat)->[CGFloat]{
        var newWave:[CGFloat] = wave.map({return $0 * dy})
        for element in newWave{
            let xscale:Int = Int(floor(Double(dx)))
            //TODO how to scale X?
        }
        return newWave
    }
}