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
    [1, 3, 5, 5, 6, 8],
    [1, 0, 5, 5, 6, 8],
    [1, 3, 8, 6, 10, 3],
    [0, 6, 14, 9, 9, 12],
    [0, 7, 1, 14, 3, 14],
    [0, 7, 8, 13, 9, 3],
    [0, 7, 17, 16, 11, 4],
    [0, 2, 5, 7, 16, 9],
    [0, 1, 11, 8, 5, 5],
    [1, 2, 2, 14, 4, 0],
    [1, 1, 6, 18, 16, 11],
    [0, 0, 7, 5, 17, 15],
    [1, 6, 14, 13, 18, 10],
    [0, 0, 2, 13, 0, 10],
    [1, 5, 14, 13, 17, 2],
    [1, 6, 1, 0, 9, 10],
    [0, 1, 7, 14, 3, 11],
    [1, 7, 7, 5, 15, 15],
    [0, 4, 17, 4, 5, 9],
    [0, 7, 17, 14, 4, 15],
    [0, 7, 11, 2, 9, 0],
    [1, 7, 7, 0, 2, 0],
    [1, 4, 10, 10, 15, 3],
    [1, 1, 4, 14, 9, 11],
    [1, 7, 6, 17, 11, 7],
    [0, 0, 5, 4, 16, 13],
    [1, 3, 5, 12, 10, 0],
    [0, 2, 16, 11, 2, 8],
    [1, 5, 16, 7, 15, 8],
    [1, 4, 17, 16, 1, 2],
    [1, 0, 1, 16, 9, 18],
    [1, 2, 2, 2, 0, 7],
    [0, 6, 1, 7, 16, 14],
    [0, 4, 16, 13, 15, 2],
    [0, 6, 16, 18, 4, 10],
    [0, 3, 15, 11, 7, 18],
    [1, 5, 18, 2, 0, 8],
    [0, 0, 9, 15, 6, 0],
    [0, 1, 12, 18, 16, 12],
    [0, 2, 6, 0, 14, 9],
    [0, 3, 12, 0, 11, 9],
    [1, 4, 12, 11, 2, 15],
    [1, 7, 11, 8, 16, 1],
    [0, 1, 15, 11, 15, 11],
    [0, 5, 18, 14, 13, 5],
    [0, 4, 6, 9, 12, 15],
    [0, 3, 9, 8, 14, 2],
    [1, 5, 16, 4, 0, 9],
    [1, 5, 11, 2, 0, 18],
    [1, 1, 9, 10, 0, 4],
    [0, 1, 9, 1, 14, 2],
    [0, 6, 7, 3, 7, 8],
    [0, 3, 1, 17, 11, 12],
    [0, 1, 17, 16, 12, 10],
    [1, 2, 2, 10, 15, 5],
    [1, 4, 9, 2, 9, 7],
    [0, 5, 9, 4, 2, 6],
    [0, 5, 10, 18, 17, 12],
    [0, 3, 14, 0, 3, 10],
    [1, 2, 5, 0, 10, 14],
    [0, 0, 11, 6, 18, 11],
    [0, 4, 4, 13, 4, 14],
    [0, 6, 12, 11, 7, 4],
    [0, 6, 16, 9, 17, 10],
    [1, 0, 11, 9, 3, 13],
    [0, 4, 0, 0, 10, 5],
    [0, 5, 4, 6, 5, 9],
    [1, 6, 16, 10, 1, 5],
    [1, 6, 5, 13, 10, 7],
    [0, 4, 5, 6, 1, 8],
    [1, 2, 11, 16, 6, 12],
    [0, 4, 7, 17, 7, 0],
    [1, 5, 16, 1, 3, 6],
    [0, 2, 5, 2, 3, 2],
    [1, 5, 16, 0, 2, 11],
    [0, 6, 11, 6, 5, 18],
    [1, 7, 15, 1, 2, 11],
    [0, 3, 5, 6, 10, 4],
    [1, 6, 14, 11, 11, 14],
    [0, 3, 3, 12, 3, 0],
    [1, 1, 5, 0, 0, 8],
    [0, 3, 3, 12, 6, 2],
    [1, 7, 16, 14, 11, 2],
    [0, 7, 0, 2, 12, 3],
    [1, 7, 0, 14, 15, 15],
    [1, 5, 6, 9, 12, 7],
    [1, 1, 11, 0, 17, 14],
    [0, 1, 17, 12, 11, 9],
    [1, 7, 15, 10, 5, 4],
    [0, 3, 2, 9, 7, 11],
    [1, 5, 15, 8, 0, 12],
    [1, 5, 10, 0, 10, 4],
    [1, 7, 2, 18, 3, 14],
    [0, 4, 11, 17, 9, 16],
    [1, 2, 3, 7, 12, 10],
    [1, 2, 13, 0, 17, 15],
    [0, 4, 8, 16, 5, 8],
    [1, 3, 5, 15, 15, 11],
    [1, 2, 7, 14, 10, 3],
    [0, 2, 6, 6, 15, 12],
    [1, 3, 12, 9, 16, 13]
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
