//
// Created by Aleksandr Grin on 9/6/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//

//Contains utilities to construct unique and interesting levels

import SpriteKit
import GameplayKit

//Note that every single wave type MUST have at least 2 array sub elements.
// This is to facilitate the scaling function in the wave builder. Otherwise
// we this will crash out
class WaveType{
    public class func simpleSin()->[[CGFloat]]{
        return Array([
            [CGFloat](repeatElement(0, count: 10)),
            [CGFloat](repeatElement(1, count: 10)),
            [CGFloat](repeatElement(2, count: 8)),
            [CGFloat](repeatElement(3, count: 6)),
            [CGFloat](repeatElement(2, count: 8)),
            [CGFloat](repeatElement(1, count: 10)),
            [CGFloat](repeatElement(0, count: 10))
        ])
    }
    public class func simpleSquare()->[[CGFloat]]{
        return Array([
            [CGFloat](repeatElement(0, count: 60)),
            [CGFloat](repeatElement(50, count: 1)),
            [CGFloat](repeatElement(0, count: 60))
        ])
    }
    public class func simpleTriangle()->[[CGFloat]]{
        return Array([
            [CGFloat](repeatElement(1, count: 40)),
            [CGFloat](repeatElement(1, count: 40))
        ])
    }
    public class func simpleTrapezoid()->[[CGFloat]]{
        return Array([
            [CGFloat](repeatElement(0, count: 60)),
            [CGFloat](repeatElement(1, count: 60))
        ])
    }

    //When doing shifting operations the associated wait should be short
    // so as not to allow the wavehead to move into the negative values.
    public class func shiftUpwards()->[[CGFloat]]{
        return Array([
            [CGFloat](repeatElement(0, count: 30)),
            [CGFloat](repeatElement(1, count: 30))
        ])
    }
    public class func shiftDownwards()->[[CGFloat]]{
        return Array([
            [CGFloat](repeatElement(0, count: 30)),
            [CGFloat](repeatElement(1, count: 30))
        ])
    }

    public class func steady()->[[CGFloat]]{
        return Array([
            [CGFloat](repeatElement(0, count: 30)),
            [CGFloat](repeatElement(0, count: 30))
        ])
    }
}


fileprivate class Level {
    private var lvl:[SKAction] = []
    private var lvlGen:LevelGenerator?

    init(generator:LevelGenerator){
        self.lvlGen = generator
    }

    //Provides an SKAction which waits a certain amount of time.
    public func wait(time:Double){
        self.lvl.append(SKAction.wait(forDuration: time))
    }

    //Generates a random wait time between the two specified bounds. Used for endless
    // level generation to provide variety.
    public func randWait(upper:Double,lower:Double){
        self.lvl.append(SKAction.wait(forDuration: Double(arc4random_uniform(UInt32(upper - lower + 1))) + lower))
    }

    //Generates an SKAction which will cause the wavegenerator passed in to change oscillation.
    public func changeTopWave(to:[[CGFloat]]){
        self.lvl.append(SKAction.run({self.lvlGen!.topWave!.updateWaveOscillationWith(forces: to)}))
    }
    public func changeBottomWave(to:[[CGFloat]]){
        self.lvl.append(SKAction.run({self.lvlGen!.bottomWave!.updateWaveOscillationWith(forces: to)}))
    }
    public func changePlayerWave(to:[[CGFloat]]){
        self.lvl.append(SKAction.run({self.lvlGen!.playerWave!.updateWaveOscillationWith(forces: to)}))
    }

    public func shiftTop(dy:CGFloat){
        self.lvl.append(SKAction.run({self.lvlGen!.topWave!.position.y += dy}))
    }
    public func shiftBottom(dy:CGFloat){
        self.lvl.append(SKAction.run({self.lvlGen!.bottomWave!.position.y += dy}))
    }

    public func runBuffer(level:LevelGenerator){
        level.run(SKAction.sequence(self.lvl))
    }

    //Clears the level object.
    public func clearBuffer(){
        self.lvl = []
        self.lvlGen = nil
    }

    //Scales passed wave array in the x and y direction. X makes the array longer by
    // duplicating elements and Y makes the individual elements larger.
    public class func scale(wave:[[CGFloat]], dx:CGFloat, dy:CGFloat)->[[CGFloat]]{
        if dx < 0 || dy < 0{ return [] }

        //Compute the values scaled in the y direction.
        var yScaledWave:[[CGFloat]] = {
            var newWave:[[CGFloat]] = []
            for subset in wave{
                newWave.append(subset.map({$0 * dy}))
            }
            return newWave
        }()

        var finalWave:[[CGFloat]] = []
        if dx > 1 {
            for i in 0..<(yScaledWave.count){
                //Add the original wave parts to the new wave.
                finalWave.append(yScaledWave[i])

                //If we have reached the second to last wave then we need to break out.
                if i == (yScaledWave.count-1) {
                    break
                }
                //If the next wave is an impulse we do not interpolate.
                //We simply add the scale number of wave parts.
                if (yScaledWave[i+1].count == 1){
                    for _ in 1..<Int(dx){
                        finalWave.append(yScaledWave[i])
                    }
                //If the next wave is not an impulse and this current one is not an impulse we interpolate and make steps
                // based on the scale value, then add that number of wave parts.
                }else if (yScaledWave[i].count != 1){
                    for j in 1..<Int(dx){
                        let interpolation:CGFloat = {
                            return yScaledWave[i][0] + (((yScaledWave[i+1][0] - yScaledWave[i][0]) / dx) * CGFloat(j))
                        }()
                        let midCount = Int((yScaledWave[i].count + yScaledWave[i+1].count) / 2)
                        finalWave.append([CGFloat](repeatElement(interpolation, count: midCount)))
                    }
                //If the current wave is an impulse, to keep the wave even we add a copy of the next
                // element based on the scaling amount.
                }else if (yScaledWave[i].count == 1){
                    for _ in 1..<Int(dx){
                        finalWave.append(yScaledWave[i+1])
                    }
                }
            }
        //When the scale factor is less than 1 then that means we simply filter out each dx element
        // of the wave, thereby scaling it down.
        }else{
            let step:Int = Int(1 / dx)
            for i in stride(from: 0, to: yScaledWave.count, by: step){
                finalWave.append(yScaledWave[i])
            }
        }

        //When scaling in x, the y changes as well so we adjust to make it seem as though y didnt change.
        finalWave = {
            var downScaled:[[CGFloat]] = []
            for subset in finalWave{
                if subset.count != 1{
                    downScaled.append(subset.map({$0 / dx}))
                }else{
                    //Prevent downscaling of impulses.
                    downScaled.append(subset)
                }
            }
            return downScaled
        }()

        //Return expanded and scaled values
        return finalWave
    }

    //Flips all the wave values.
    public class func flip(wave:[[CGFloat]])->[[CGFloat]]{
        var newWave:[[CGFloat]] = []
        for subset in wave{
            newWave.append(subset.map({if ($0 == 0){ return 0 }else{ return -$0}}))
        }
        return newWave
    }
}

class LevelList {
    class func level(num:Int, gen:LevelGenerator){
        //Clear all actions just in case.
        gen.removeAllActions()

        switch num{
        case 1:
            LevelList.level1(gen: gen)
            break
        case 2:
            LevelList.level2(gen: gen)
            break
        default:
            LevelList.level3(gen: gen)
            break
        }
    }

    private class func level1(gen:LevelGenerator){
        let lvl = Level(generator: gen)
        lvl.shiftTop(dy: 35)
        lvl.shiftBottom(dy: -35)
        lvl.wait(time: 1)
        lvl.changeTopWave(to: Level.flip(wave: Level.scale(wave: WaveType.simpleTriangle(), dx: 4, dy: 2)))
        lvl.changeBottomWave(to: Level.scale(wave: WaveType.simpleTriangle(), dx: 4, dy: 2))
        lvl.runBuffer(level: gen)
    }

    private class func level2(gen:LevelGenerator){
        let lvl = Level(generator: gen)
        lvl.shiftTop(dy: 35)
        lvl.shiftBottom(dy: -35)
        lvl.wait(time: 1)
        lvl.changeTopWave(to: Level.flip(wave: Level.scale(wave: WaveType.simpleSin(), dx: 4, dy: 2)))
        lvl.changeBottomWave(to: Level.scale(wave: WaveType.simpleSin(), dx: 4, dy: 2))
        lvl.runBuffer(level: gen)
    }

    private class func level3(gen:LevelGenerator){
        let lvl = Level(generator: gen)
        lvl.shiftTop(dy: 35)
        lvl.shiftBottom(dy: -35)
        lvl.wait(time: 1)
        lvl.changeTopWave(to: Level.flip(wave: Level.scale(wave: WaveType.simpleSquare(), dx: 3, dy: 2)))
        lvl.wait(time: 3)
        lvl.changeBottomWave(to: Level.scale(wave: WaveType.simpleSquare(), dx: 3, dy: 2))
        lvl.runBuffer(level: gen)
    }
}