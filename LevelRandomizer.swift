//
// Created by Aleksandr Grin on 9/14/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//

import SpriteKit

class LevelPieceTemplates {
    enum SegmentTemplateType:Int{
        case steady = 0
        case sin1
        case sin2
        case sin3
        case sin4
        case square1
        case square2
        case square3
        case square4
        case triangle1
        case triangle2
        case triangle3
        case triangle4
        case meld1
        case meld2
        case meld3
        case meld4
        case meld5
        case meld6
    }
    class func addSegment(type:SegmentTemplateType, to lvl:Level){
        switch type {
        case .steady:
            let dxMultiplier: CGFloat = 1
            let dyMultiplier: CGFloat = 1
            let wave = WaveType.steady()

            lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            break
        case .sin1:
            let dxMultiplier: CGFloat = 1
            let dyMultiplier: CGFloat = 1
            let wave = WaveType.simpleSin()

            lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            break
        case .sin2:
            let dxMultiplier: CGFloat = 2
            let dyMultiplier: CGFloat = 2
            let wave = WaveType.simpleSin()

            lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            break
        case .sin3:
            let dxMultiplier: CGFloat = 4
            let dyMultiplier: CGFloat = 2
            let wave = WaveType.simpleSin()

            lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            break
        case .sin4:
            let dxMultiplier: CGFloat = 3
            let dyMultiplier: CGFloat = 2.5
            let wave = WaveType.simpleSin()

            lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            break
        case .square1:
            let dxMultiplier: CGFloat = 1
            let dyMultiplier: CGFloat = 1
            let wave = WaveType.simpleSquare()

            lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            break
        case .square2:
            //Needs to have larger spacing than standard. Probably the 40
            let dxMultiplier: CGFloat = 2
            let dyMultiplier: CGFloat = 2
            let wave = WaveType.simpleSquare()

            lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            break
        case .square3:
            //Needs to have larger spacing than standard. Probably the 40
            let dxMultiplier: CGFloat = 3
            let dyMultiplier: CGFloat = 2.5
            let wave = WaveType.simpleSquare()

            lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            break
        case .square4:
            let dxMultiplier: CGFloat = 3.5
            let dyMultiplier: CGFloat = 1.5
            let wave = WaveType.simpleSquare()

            lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            break
        case .triangle1:
            let dxMultiplier: CGFloat = 1
            let dyMultiplier: CGFloat = 1
            let wave = WaveType.simpleTriangle()

            lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            break
        case .triangle2:
            let dxMultiplier: CGFloat = 2
            let dyMultiplier: CGFloat = 2
            let wave = WaveType.simpleTriangle()

            lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            break
        case .triangle3:
            let dxMultiplier: CGFloat = 4
            let dyMultiplier: CGFloat = 1
            let wave = WaveType.simpleTriangle()

            lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            break
        case .triangle4:
            let dxMultiplier: CGFloat = 4
            let dyMultiplier: CGFloat = 2
            let wave = WaveType.simpleTriangle()

            lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            break
        case .meld1:
            let dxMultiplierA: CGFloat = 2
            let dyMultiplierA: CGFloat = 2
            lvl.changeTopWave(to: Level.scale(wave: WaveType.simpleSin(), dx: dxMultiplierA, dy: dyMultiplierA))

            let dxMultiplierB: CGFloat = 3
            let dyMultiplierB: CGFloat = 1.5
            lvl.changeBottomWave(to: Level.scale(wave: WaveType.simpleSquare(), dx: dxMultiplierB, dy: dyMultiplierB))
            break
        case .meld2:
            //Needs large spacing
            let dxMultiplierA: CGFloat = 1.5
            let dyMultiplierA: CGFloat = 2
            lvl.changeTopWave(to: Level.scale(wave: WaveType.simpleTriangle(), dx: dxMultiplierA, dy: dyMultiplierA))

            let dxMultiplierB: CGFloat = 3
            let dyMultiplierB: CGFloat = 2
            lvl.changeBottomWave(to: Level.scale(wave: WaveType.simpleSquare(), dx: dxMultiplierB, dy: dyMultiplierB))
            break
        case .meld3:
            let dxMultiplierA: CGFloat = 1.5
            let dyMultiplierA: CGFloat = 2
            lvl.changeTopWave(to: Level.scale(wave: WaveType.simpleTrapezoid(), dx: dxMultiplierA, dy: dyMultiplierA))

            let dxMultiplierB: CGFloat = 3
            let dyMultiplierB: CGFloat = 1
            lvl.changeBottomWave(to: Level.scale(wave: WaveType.simpleSin(), dx: dxMultiplierB, dy: dyMultiplierB))
            break
        case .meld4:
            //Needs larget spacing
            let dxMultiplierA:CGFloat = 4
            let dyMultiplierA:CGFloat = 2
            lvl.changeTopWave(to: Level.scale(wave: WaveType.simpleTriangle(), dx: dxMultiplierA, dy: dyMultiplierA))

            let dxMultiplierB:CGFloat = 1.5
            let dyMultiplierB:CGFloat = 3
            lvl.changeBottomWave(to: Level.scale(wave: WaveType.simpleTrapezoid(), dx: dxMultiplierB, dy: dyMultiplierB))
            break
        case .meld5:
            //Needs larger spacing
            let dxMultiplierA:CGFloat = 3.5
            let dyMultiplierA:CGFloat = 2
            lvl.changeTopWave(to: Level.scale(wave: WaveType.simpleSin(), dx: dxMultiplierA, dy: dyMultiplierA))

            let dxMultiplierB:CGFloat = 2
            let dyMultiplierB:CGFloat = 2
            lvl.changeBottomWave(to: Level.scale(wave: WaveType.simpleTriangle(), dx: dxMultiplierB, dy: dyMultiplierB))
            break
        case .meld6:
            //Needs larger spacing.
            let dxMultiplierA:CGFloat = 2
            let dyMultiplierA:CGFloat = 3
            lvl.changeTopWave(to: Level.scale(wave: WaveType.simpleSquare(), dx: dxMultiplierA, dy: dyMultiplierA))

            let dxMultiplierB:CGFloat = 3
            let dyMultiplierB:CGFloat = 2
            lvl.changeBottomWave(to: Level.scale(wave: WaveType.simpleSquare(), dx: dxMultiplierB, dy: dyMultiplierB))
            break
        }
    }
}

class DisplacementTemplate {
    enum WaveDisplacements:Int {
        case outDisplace5 = 0
        case outDisplace10
        case outDisplace20
        case outDisplace40
        case inDisplace5
        case inDisplace10
        case inDisplace20
        case inDisplace40
    }

    class func addDisplacementSegment(to lvl: Level, with displaceType:WaveDisplacements){
        switch displaceType {
        //Pushes the two wave boundaries apart
        case .outDisplace5:
            lvl.shiftTop(dy: 5)
            lvl.shiftBottom(dy: -5)
            break
        case .outDisplace10:
            lvl.shiftTop(dy: 10)
            lvl.shiftBottom(dy: -10)
            break
        case .outDisplace20:
            lvl.shiftTop(dy: 20)
            lvl.shiftBottom(dy: -20)
            break
        case .outDisplace40:
            lvl.shiftTop(dy: 40)
            lvl.shiftBottom(dy: -40)
            break

        //Squishes the two wave boundaries together
        case .inDisplace5:
            lvl.shiftTop(dy: -5)
            lvl.shiftBottom(dy: 5)
            break
        case .inDisplace10:
            lvl.shiftTop(dy: -10)
            lvl.shiftBottom(dy: 10)
            break
        case .inDisplace20:
            lvl.shiftTop(dy: -20)
            lvl.shiftBottom(dy: 20)
            break
        case .inDisplace40:
            lvl.shiftTop(dy: -40)
            lvl.shiftBottom(dy: 40)
            break
        }
    }
}


class ShiftingTemplate {
    //Wave height is set via shifting by 0.25 increments.
    enum YLevelsList:Int {
        case up050 = 0
        case up075 = 1
        case down050
        case down075
    }

    public class func addYShiftingSection(to lvl:Level, newY:YLevelsList){
        var waitTime:Double = 0
        var obsDisplacement:CGFloat = 0

        //Use the new level to determine how much the shift should be.
        switch newY {
        case .up050:
            waitTime = 0.50
            obsDisplacement = 60
            break
        case .up075:
            waitTime = 0.75
            obsDisplacement = 90
            break
        case .down050:
            waitTime = 0.50
            obsDisplacement = -60
            break
        case .down075:
            waitTime = 0.75
            obsDisplacement = -90
            break
        }

        //Use the raw value to set the direction of travel
        if newY.rawValue < 2 {
            lvl.changeTopWave(to: WaveType.shiftUpwards())
            lvl.changeBottomWave(to: WaveType.shiftUpwards())
            //Shift the obstacle generators so they remain relavant
            lvl.shiftObstacleGenerators(by: obsDisplacement)
        }else{
            lvl.changeTopWave(to: WaveType.shiftDownwards())
            lvl.changeBottomWave(to: WaveType.shiftDownwards())
            lvl.shiftObstacleGenerators(by: obsDisplacement)
        }
        lvl.wait(time: waitTime)
    }
}

class ObstacleTemplate {
    public class func addObstacle(lvl: Level){
        lvl.wait(time: 1.0)
        lvl.addObstacleGenerator(position: CGPoint(x: UIScreen.main.bounds.width + 25, y: 0), obsParams: ObstacleParameters(
                obstacleTravelTime: 8.0,
                obstacleSize: CGSize(width: 50, height: 10),
                presetYPositions: [0,90,-90,45,-45,100]))
    }
}

class RandomizerTree {
    public class func generateLevel(for lvl:Level){
        //Part 1 of a level steady intro
        ObstacleTemplate.addObstacle(lvl: lvl)
        DisplacementTemplate.addDisplacementSegment(to: lvl, with: .outDisplace20)
        //Part 2 of a level choose a segment
        LevelPieceTemplates.addSegment(type: .sin3, to: lvl)
        lvl.wait(time: 9.0)
        LevelPieceTemplates.addSegment(type: .square4, to: lvl)
        lvl.wait(time: 9.0)
        LevelPieceTemplates.addSegment(type: .square4, to: lvl)
        lvl.wait(time: 9.0)
        LevelPieceTemplates.addSegment(type: .meld2, to: lvl)
        lvl.wait(time: 9.0)
        LevelPieceTemplates.addSegment(type: .steady, to: lvl)

    }
}
