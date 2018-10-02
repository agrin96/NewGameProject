//
// Created by Aleksandr Grin on 9/14/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//

import SpriteKit

//Decides whether to change top, bottom, or both boundary waves
enum WaveChangeGroupings {
    case both
    case top
    case bottom
}

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

            lvl.wait(time: 1.0)
            lvl.addObstacleGenerator(position: CGPoint(x: UIScreen.main.bounds.width + 25, y: 0), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 1.0,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: true))
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
            let dxMultiplier: CGFloat = 2
            let dyMultiplier: CGFloat = 2
            let wave = WaveType.simpleSquare()

            lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            break
        case .square3:
            let dxMultiplier: CGFloat = 3
            let dyMultiplier: CGFloat = 2.5
            let wave = WaveType.simpleSquare()

            lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
            break
        case .square4:
            let dxMultiplier: CGFloat = 4
            let dyMultiplier: CGFloat = 2.5
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
            let dxMultiplier: CGFloat = 3
            let dyMultiplier: CGFloat = 2.5
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

            let dxMultiplierB: CGFloat = 2
            let dyMultiplierB: CGFloat = 3
            lvl.changeBottomWave(to: Level.scale(wave: WaveType.simpleSin(), dx: dxMultiplierB, dy: dyMultiplierB))
            break
        case .meld4:
            let dxMultiplierA:CGFloat = 4
            let dyMultiplierA:CGFloat = 2
            lvl.changeTopWave(to: Level.scale(wave: WaveType.simpleTriangle(), dx: dxMultiplierA, dy: dyMultiplierA))

            let dxMultiplierB:CGFloat = 1.5
            let dyMultiplierB:CGFloat = 3
            lvl.changeBottomWave(to: Level.scale(wave: WaveType.simpleTrapezoid(), dx: dxMultiplierB, dy: dyMultiplierB))
            break
        case .meld5:
            let dxMultiplierA:CGFloat = 2
            let dyMultiplierA:CGFloat = 2
            lvl.changeTopWave(to: Level.scale(wave: WaveType.simpleSin(), dx: dxMultiplierA, dy: dyMultiplierA))

            let dxMultiplierB:CGFloat = 2
            let dyMultiplierB:CGFloat = 2
            lvl.changeBottomWave(to: Level.scale(wave: WaveType.simpleTriangle(), dx: dxMultiplierB, dy: dyMultiplierB))
            break
        case .meld6:
            let dxMultiplierA:CGFloat = 2
            let dyMultiplierA:CGFloat = 4
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
        case outDisplace30 = 0
        case outDisplace45
        case outDisplace55
        case outDisplace75
        case inDisplace30
        case inDisplace45
        case inDisplace55
        case inDisplace75
    }

    class func addDisplacementSegment(to lvl: Level, with displaceType:WaveDisplacements){
        switch displaceType {
        //Pushes the two wave boundaries apart
        case .outDisplace30:
            lvl.shiftTop(dy: 30)
            lvl.shiftBottom(dy: -30)
            break
        case .outDisplace45:
            lvl.shiftTop(dy: 45)
            lvl.shiftBottom(dy: -45)
            break
        case .outDisplace55:
            lvl.shiftTop(dy: 60)
            lvl.shiftBottom(dy: -60)
            break
        case .outDisplace75:
            lvl.shiftTop(dy: 75)
            lvl.shiftBottom(dy: -75)
            break

        //Squishes the two wave boundaries together
        case .inDisplace30:
            lvl.shiftTop(dy: -30)
            lvl.shiftBottom(dy: 30)
            break
        case .inDisplace45:
            lvl.shiftTop(dy: -45)
            lvl.shiftBottom(dy: 45)
            break
        case .inDisplace55:
            lvl.shiftTop(dy: -60)
            lvl.shiftBottom(dy: 60)
            break
        case .inDisplace75:
            lvl.shiftTop(dy: -75)
            lvl.shiftBottom(dy: 75)
            break
        }
    }
}


class ShiftingTemplate {
    //Wave height is set via shifting by 0.25 increments.
    enum YLevelsList:Int {
        case up025 = 0
        case up050 = 1
        case up100 = 2
        case down025
        case down050
        case down100
    }

    public class func addYShiftingSection(to lvl:Level, newY:YLevelsList){
        var waitTime:Double = 0

        //Use the new level to determine how much the shift should be.
        switch newY {
        case .up025:
            waitTime = 0.25
            break
        case .up050:
            waitTime = 0.50
            break
        case .up100:
            waitTime = 1.0
            break
        case .down025:
            waitTime = 0.25
            break
        case .down050:
            waitTime = 0.50
            break
        case .down100:
            waitTime = 1.0
            break
        }

        //Use the raw value to set the direction of travel
        if newY.rawValue > 2 {
            lvl.changeTopWave(to: WaveType.shiftUpwards())
            lvl.changeBottomWave(to: WaveType.shiftUpwards())
            //Shift the obstacle generators so they remain relavant
            lvl.shiftObstacleGenerators(by: 30)
        }else{
            lvl.changeTopWave(to: WaveType.shiftDownwards())
            lvl.changeBottomWave(to: WaveType.shiftDownwards())
            lvl.shiftObstacleGenerators(by: -30)
        }
        lvl.wait(time: waitTime)
    }
}

class RandomizerTree {
    public class func generateLevel(for lvl:Level){
        //Add obstacles
        DisplacementTemplate.addDisplacementSegment(to: lvl, with: .outDisplace45)
        LevelPieceTemplates.addSegment(type: .steady, to: lvl)
        lvl.wait(time: 0.5)
        LevelPieceTemplates.addSegment(type: .meld2, to: lvl)
        lvl.wait(time: 15)
        ShiftingTemplate.addYShiftingSection(to: lvl, newY: .down050)
        LevelPieceTemplates.addSegment(type: .triangle3, to: lvl)
        lvl.wait(time: 15)
        ShiftingTemplate.addYShiftingSection(to: lvl, newY: .up050)

        //FIX OBSTACLE ADDITION
        //CHANGE THE SHIFTING ACTION TO FLOAT BASIS
        //MAKE SEGMENTS
    }
}
