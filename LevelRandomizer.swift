//
// Created by Aleksandr Grin on 9/14/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//

import SpriteKit

enum ShiftingDirection:Int {
    case down = -1
    case up = 1
}

enum WaveChangeGroupings {
    case top
    case bottom
    case both
}


enum DisplacementTemplate:Int {
    case displace30 = 0
    case displace45
    case displace55
    case displace75

    func run(lvl: Level, direction: ShiftingDirection, grouping:WaveChangeGroupings = .both) -> DisplacementTemplate {
        switch self {
        case .displace30:
            switch grouping{
            case .both:
                lvl.shiftTop(dy: CGFloat(30 * direction.rawValue))
                lvl.shiftBottom(dy: CGFloat(30 * direction.rawValue))
                break
            case .bottom:
                lvl.shiftBottom(dy: CGFloat(30 * direction.rawValue))
                break
            case .top:
                lvl.shiftTop(dy: CGFloat(30 * direction.rawValue))
                break
            }
            return .displace30
        case .displace45:
            switch grouping{
            case .both:
                lvl.shiftTop(dy: CGFloat(45 * direction.rawValue))
                lvl.shiftBottom(dy: CGFloat(45 * direction.rawValue))
                break
            case .bottom:
                lvl.shiftBottom(dy: CGFloat(45 * direction.rawValue))
                break
            case .top:
                lvl.shiftTop(dy: CGFloat(45 * direction.rawValue))
                break
            }
            return .displace45
        case .displace55:
            switch grouping{
            case .both:
                lvl.shiftTop(dy: CGFloat(55 * direction.rawValue))
                lvl.shiftBottom(dy: CGFloat(55 * direction.rawValue))
                break
            case .bottom:
                lvl.shiftBottom(dy: CGFloat(55 * direction.rawValue))
                break
            case .top:
                lvl.shiftTop(dy: CGFloat(55 * direction.rawValue))
                break
            }
            return .displace55
        case .displace75:
            switch grouping{
            case .both:
                lvl.shiftTop(dy: CGFloat(75 * direction.rawValue))
                lvl.shiftBottom(dy: CGFloat(75 * direction.rawValue))
                break
            case .bottom:
                lvl.shiftBottom(dy: CGFloat(75 * direction.rawValue))
                break
            case .top:
                lvl.shiftTop(dy: CGFloat(75 * direction.rawValue))
                break
            }
            return .displace75
        }
    }
}

//Wave height is set via shifting by 0.25 increments.
enum ShiftingTemplates:Int {
    case N8 = -8    //Maximum negative shift of 2.0 seconds.
    case N7
    case N6
    case N5
    case N4
    case N3
    case N2
    case N1
    case CE = 0     //Centered or default position
    case P1
    case P2
    case P3
    case P4
    case P5
    case P6
    case P7
    case P8 = 8     //Maximum upwards shift of 2.0 seconds

    func run(lvl:Level, newHeight:ShiftingTemplates, grouping:WaveChangeGroupings = .both) -> ShiftingTemplates {
        //Here we use the raw values to calculate how long we should run the shifting
        // because we arbitrarily determined the interlevel distance as a 0.25 second shift.
        let difference:Double = Double(abs(newHeight.rawValue - self.rawValue))
        let waitTime:Double = Double(difference * 0.25)

        switch grouping {
        case .both:
            if self.rawValue > newHeight.rawValue {
                //We are going down.
                lvl.changeTopWave(to: WaveType.shiftDownwards())
                lvl.changeBottomWave(to: WaveType.shiftDownwards())
            }else{
                //We are moving up.
                lvl.changeTopWave(to: WaveType.shiftUpwards())
                lvl.changeBottomWave(to: WaveType.shiftUpwards())
            }
            lvl.wait(time: waitTime)
            //Update the wave level indicator
            return newHeight
        case .top:
            if self.rawValue > newHeight.rawValue {
                //We are going down.
                lvl.changeTopWave(to: WaveType.shiftDownwards())
            }else{
                //We are moving up.
                lvl.changeTopWave(to: WaveType.shiftUpwards())
            }
            lvl.wait(time: waitTime)
            //Update the wave level indicator
            return newHeight
        case .bottom:
            if self.rawValue > newHeight.rawValue {
                //We are going down.
                lvl.changeBottomWave(to: WaveType.shiftDownwards())
            }else{
                //We are moving up.
                lvl.changeBottomWave(to: WaveType.shiftUpwards())
            }
            lvl.wait(time: waitTime)
            //Update the wave level indicator
            return newHeight
        }
    }
}

enum WaveTemplates:Int {
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

    func run(lvl: Level, grouping: WaveChangeGroupings = .both){
        switch self {
        case .sin1:
            let dxMultiplier:CGFloat = 1
            let dyMultiplier:CGFloat = 1
            let wave = WaveType.simpleSin()
            switch grouping {
            case .both:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .top:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .bottom:
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            }
        case .sin2:
            let dxMultiplier:CGFloat = 2
            let dyMultiplier:CGFloat = 2
            let wave = WaveType.simpleSin()
            switch grouping {
            case .both:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .top:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .bottom:
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            }
        case .sin3:
            let dxMultiplier:CGFloat = 4
            let dyMultiplier:CGFloat = 2
            let wave = WaveType.simpleSin()
            switch grouping {
            case .both:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .top:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .bottom:
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            }
        case .sin4:
            let dxMultiplier:CGFloat = 3
            let dyMultiplier:CGFloat = 2.5
            let wave = WaveType.simpleSin()
            switch grouping {
            case .both:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .top:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .bottom:
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            }
        case .square1:
            let dxMultiplier:CGFloat = 1
            let dyMultiplier:CGFloat = 1
            let wave = WaveType.simpleSquare()
            switch grouping {
            case .both:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .top:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .bottom:
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            }
        case .square2:
            let dxMultiplier:CGFloat = 2
            let dyMultiplier:CGFloat = 2
            let wave = WaveType.simpleSquare()
            switch grouping {
            case .both:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .top:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .bottom:
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            }
        case .square3:
            let dxMultiplier:CGFloat = 3
            let dyMultiplier:CGFloat = 2.5
            let wave = WaveType.simpleSquare()
            switch grouping {
            case .both:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .top:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .bottom:
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            }
        case .square4:
            let dxMultiplier:CGFloat = 4
            let dyMultiplier:CGFloat = 2.5
            let wave = WaveType.simpleSquare()
            switch grouping {
            case .both:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .top:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .bottom:
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            }
        case .triangle1:
            let dxMultiplier:CGFloat = 1
            let dyMultiplier:CGFloat = 1
            let wave = WaveType.simpleTriangle()
            switch grouping {
            case .both:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .top:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .bottom:
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            }
        case .triangle2:
            let dxMultiplier:CGFloat = 2
            let dyMultiplier:CGFloat = 2
            let wave = WaveType.simpleTriangle()
            switch grouping {
            case .both:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .top:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .bottom:
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            }
        case .triangle3:
            let dxMultiplier:CGFloat = 3
            let dyMultiplier:CGFloat = 2.5
            let wave = WaveType.simpleTriangle()
            switch grouping {
            case .both:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .top:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .bottom:
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            }
        case .triangle4:
            let dxMultiplier:CGFloat = 4
            let dyMultiplier:CGFloat = 2
            let wave = WaveType.simpleTriangle()
            switch grouping {
            case .both:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .top:
                lvl.changeTopWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            case .bottom:
                lvl.changeBottomWave(to: Level.scale(wave: wave, dx: dxMultiplier, dy: dyMultiplier))
                break
            }
        }
    }

    private mutating func change(to: WaveTemplates){
        self = to
    }
}

enum ObstacleTemplates:Int {
    case obstacle1
    case obstacle2
    case obstacle3
    case obstacle4
    case obstacle5

    func run(lvl: Level){
        //Before an obstacle is added there is a 1 second lead time.
        lvl.wait(time: 1)
        switch self {
        case .obstacle1:
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: 0), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 0.5,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: 30), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 0.5,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: -30), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 0.5,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
        case .obstacle2:
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: 0), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 0.5,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: 60), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 0.5,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: -60), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 0.5,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
        case .obstacle3:
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: 0), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 0.5,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: 90), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 0.5,
                    obstacleTravelTime: 3,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: -90), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 0.5,
                    obstacleTravelTime: 3,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
        case .obstacle4:
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: 0), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 1.5,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: 120), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 1,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: -120), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 1.5,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
        case .obstacle5:
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: 0), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 0.5,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: 30), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 0.5,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: -30), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 0.5,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
        }
    }
}

class RandomizerTree {
    public class func generateLevel(for lvl:Level){
        //Set initial displacement
        if DisplacementTemplate.displace30.run(lvl: lvl, direction: .up, grouping: .top) != .displace30 { return }
        if DisplacementTemplate.displace30.run(lvl: lvl, direction: .down, grouping: .bottom) != .displace30 { return }

        //Set wavetype
        WaveTemplates.sin2.run(lvl: lvl)

        //Add obstacles
        ObstacleTemplates.obstacle4.run(lvl: lvl)
//        ObstacleTemplates.obstacle5.run(lvl: lvl)

        lvl.wait(time: 10)
        if ShiftingTemplates.CE.run(lvl: lvl, newHeight: .P3, grouping: .both) != .P3 { return }
        WaveTemplates.square3.run(lvl: lvl)
        lvl.wait(time: 10)
        if ShiftingTemplates.P3.run(lvl: lvl, newHeight: .CE, grouping: .both) != .CE { return }
        WaveTemplates.triangle3.run(lvl: lvl)
    }
}
