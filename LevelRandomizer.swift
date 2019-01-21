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
    public class func addObstacle(lvl: Level, type:Int){
        switch type{
        case 0:
            lvl.wait(time: 1.0)
            lvl.addObstacleGenerator(position: CGPoint(x: UIScreen.main.bounds.width + 25, y: 0), obsParams: ObstacleParameters(
                    obstacleTravelTime: 8.0,
                    obstacleSize: CGSize(width: 50, height: 10),
                    presetYPositions: [0,90,-90,45,-45,100]))
            break
        case 1:
            lvl.wait(time: 1.0)
            lvl.addObstacleGenerator(position: CGPoint(x: UIScreen.main.bounds.width + 25, y: 0), obsParams: ObstacleParameters(
                    obstacleTravelTime: 8.0,
                    obstacleSize: CGSize(width: 50, height: 10),
                    presetYPositions: [0,90,-90,45,-45,100]))
            break
        default:
            break
        }
    }
}

// Structure of array integers holding the level generation data
// [0:obstacle(1), 1:displacement(8), 2: segment(18), 3: segment(18), 4: segment(18), 5: segment(18)]
// We mix and match randomly to achieve a good level spread.
fileprivate let randomizedLevels:[[Int]] = [
    [0, 2, 13, 0, 11, 18],
    [0, 2, 16, 18, 12, 15],
    [0, 4, 11, 14, 12, 14],
    [0, 6, 18, 15, 12, 12],
    [0, 6, 13, 2, 1, 2],
    [1, 7, 6, 1, 7, 1],
    [0, 1, 2, 15, 16, 0],
    [1, 4, 3, 15, 17, 8],
    [0, 5, 7, 10, 17, 2],
    [0, 1, 12, 5, 18, 17],
    [0, 2, 18, 15, 18, 16],
    [0, 4, 4, 3, 17, 5],
    [0, 2, 14, 0, 7, 0],
    [0, 4, 14, 9, 6, 11],
    [1, 3, 8, 18, 2, 12],
    [0, 1, 9, 11, 13, 14],
    [0, 1, 7, 18, 15, 13],
    [0, 2, 12, 5, 12, 18],
    [1, 1, 7, 13, 8, 4],
    [0, 0, 4, 18, 11, 8],
    [0, 3, 18, 8, 17, 8],
    [0, 2, 10, 0, 17, 0],
    [1, 3, 1, 13, 11, 8],
    [1, 2, 13, 12, 15, 9],
    [1, 2, 11, 7, 12, 6],
    [0, 2, 18, 2, 1, 6],
    [0, 4, 1, 11, 15, 1],
    [1, 7, 15, 10, 5, 3],
    [1, 3, 18, 5, 10, 2],
    [0, 5, 8, 3, 14, 2],
    [0, 4, 10, 5, 19, 18],
    [1, 6, 11, 7, 6, 6],
    [0, 0, 7, 13, 14, 8],
    [0, 3, 13, 4, 13, 6],
    [0, 6, 3, 8, 12, 15],
    [1, 6, 5, 5, 3, 9],
    [1, 6, 5, 3, 2, 9],
    [0, 4, 11, 11, 10, 0],
    [1, 6, 11, 8, 18, 9],
    [1, 1, 7, 15, 10, 0],
    [1, 7, 10, 0, 13, 10],
    [0, 0, 7, 5, 6, 4],
    [1, 7, 14, 17, 9, 11],
    [1, 0, 1, 1, 19, 13],
    [0, 4, 14, 14, 3, 10],
    [0, 2, 9, 16, 4, 16],
    [0, 5, 13, 5, 12, 1],
    [1, 0, 11, 3, 7, 2],
    [1, 5, 2, 1, 18, 4],
    [0, 4, 16, 15, 3, 17],
    [0, 0, 6, 11, 7, 10],
    [0, 5, 4, 1, 0, 17],
    [0, 5, 8, 3, 4, 9],
    [0, 6, 6, 3, 13, 1],
    [1, 6, 1, 2, 6, 18],
    [0, 4, 18, 10, 7, 15],
    [0, 1, 18, 8, 3, 7],
    [0, 6, 11, 6, 11, 12],
    [1, 7, 0, 4, 18, 13],
    [0, 2, 18, 19, 8, 10],
    [1, 0, 12, 18, 14, 18],
    [1, 3, 2, 6, 1, 4],
    [1, 6, 12, 3, 16, 7],
    [1, 3, 9, 2, 0, 3],
    [0, 2, 1, 6, 13, 8],
    [1, 3, 12, 1, 18, 18],
    [1, 6, 16, 6, 11, 12],
    [1, 7, 8, 5, 18, 0],
    [0, 1, 14, 8, 18, 17],
    [0, 1, 2, 12, 13, 11],
    [0, 2, 18, 13, 2, 8],
    [1, 0, 8, 9, 0, 15],
    [0, 2, 18, 10, 9, 8],
    [0, 4, 15, 13, 4, 9],
    [1, 5, 1, 0, 2, 18],
    [0, 6, 10, 4, 6, 12],
    [0, 0, 18, 10, 12, 9],
    [0, 3, 17, 12, 13, 1],
    [0, 0, 5, 17, 12, 16],
    [0, 2, 12, 5, 7, 7],
    [1, 0, 0, 9, 14, 18],
    [1, 3, 6, 5, 18, 8],
    [0, 5, 6, 18, 15, 10],
    [0, 7, 8, 16, 0, 19],
    [1, 7, 12, 3, 4, 13],
    [1, 1, 16, 5, 13, 12],
    [0, 1, 3, 11, 12, 7],
    [1, 1, 5, 13, 4, 1],
    [0, 2, 2, 0, 10, 11],
    [0, 3, 1, 14, 2, 2],
    [0, 7, 4, 1, 10, 2],
    [0, 1, 5, 12, 0, 11],
    [1, 0, 15, 15, 18, 16],
    [0, 5, 7, 14, 17, 6],
    [1, 7, 2, 18, 5, 14],
    [1, 2, 6, 18, 6, 12],
    [1, 5, 4, 12, 14, 18],
    [1, 5, 7, 9, 6, 9],
    [0, 3, 17, 6, 5, 17],
    [1, 5, 8, 0, 1, 18]
]

class LevelRandomizer {
    public class func generateLevel(for lvl:Level, lvlTemplate:Int){
        //Part 1 of a level steady intro
        ObstacleTemplate.addObstacle(lvl: lvl, type: randomizedLevels[lvlTemplate][0])
        DisplacementTemplate.addDisplacementSegment(
                to: lvl,
                with: DisplacementTemplate.WaveDisplacements(rawValue: randomizedLevels[lvlTemplate][1])!)
        LevelPieceTemplates.addSegment(
                type: LevelPieceTemplates.SegmentTemplateType(rawValue: randomizedLevels[lvlTemplate][2])!,
                to: lvl)
        lvl.wait(time: 9.0)
        LevelPieceTemplates.addSegment(
                type: LevelPieceTemplates.SegmentTemplateType(rawValue: randomizedLevels[lvlTemplate][3])!,
                to: lvl)
        lvl.wait(time: 9.0)
        LevelPieceTemplates.addSegment(
                type: LevelPieceTemplates.SegmentTemplateType(rawValue: randomizedLevels[lvlTemplate][4])!,
                to: lvl)
        lvl.wait(time: 9.0)
        LevelPieceTemplates.addSegment(
                type: LevelPieceTemplates.SegmentTemplateType(rawValue: randomizedLevels[lvlTemplate][5])!,
                to: lvl)
        lvl.wait(time: 9.0)
        LevelPieceTemplates.addSegment(type: .steady, to: lvl)
    }
}
