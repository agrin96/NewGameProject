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

    func run(lvl: Level, direction: ShiftingDirection) -> DisplacementTemplate {
        switch self {
        case .displace30:
            lvl.shiftTop(dy: 30 * direction.rawValue)
            lvl.shiftBottom(dy: 30 * direction.rawValue)
            break
        case .displace45:
            lvl.shiftTop(dy: 45 * direction.rawValue)
            lvl.shiftBottom(dy: 45 * direction.rawValue)
            break
        case .displace55:
            lvl.shiftTop(dy: 55 * direction.rawValue)
            lvl.shiftBottom(dy: 55 * direction.rawValue)
            break
        case .displace75:
            lvl.shiftTop(dy: 75 * direction.rawValue)
            lvl.shiftBottom(dy: 75 * direction.rawValue)
            break
        }
        return self
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

    func run(lvl:Level, newHeight:ShiftingTemplates, grouping:WaveChangeGroupings) -> ShiftingTemplates {
        //Here we use the raw values to calculate how long we should run the shifting
        // because we arbitrarily determined the interlevel distance as a 0.25 second shift.
        let difference:Int = self.rawValue - newHeight.rawValue
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
            self.changeLevel(to: newHeight)
            return self
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
            self.changeLevel(to: newHeight)
            return self
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
            self.changeLevel(to: newHeight)
            return self
        }
    }

    mutating private func changeLevel(to: ShiftingTemplates){
        self = to
    }

    init() {
        self.changeLevel(to: ShiftingTemplates.CE)
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

    func run(lvl: Level, grouping: WaveChangeGroupings) -> WaveTemplates {
        switch self {
        case .sin1:
            let dxMultiplier = 1
            let dyMultiplier = 1
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
            return .sin1
        case .sin2:
            let dxMultiplier = 2
            let dyMultiplier = 2
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
            return .sin2
        case .sin3:
            let dxMultiplier = 4
            let dyMultiplier = 2
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
            return .sin3
        case .sin4:
            let dxMultiplier = 3
            let dyMultiplier = 2.5
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
            return .sin4
        case .square1:
            let dxMultiplier = 1
            let dyMultiplier = 1
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
            return .square1
        case .square2:
            let dxMultiplier = 2
            let dyMultiplier = 2
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
            return .square2
        case .square3:
            let dxMultiplier = 3
            let dyMultiplier = 2.5
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
            return .square3
        case .square4:
            let dxMultiplier = 4
            let dyMultiplier = 2.5
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
            return .square4
        case .triangle1:
            let dxMultiplier = 1
            let dyMultiplier = 1
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
            return .triangle1
        case .triangle2:
            let dxMultiplier = 2
            let dyMultiplier = 2
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
            return .triangle2
        case .triangle3:
            let dxMultiplier = 3
            let dyMultiplier = 2.5
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
            return .triangle3
        case .triangle4:
            let dxMultiplier = 4
            let dyMultiplier = 2
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
            return .triangle4
        }
    }
}

enum ObstacleTemplates:Int {
    case obstacle1
    case obstacle2
    case obstacle3
    case obstacle4
    case obstacle5

    func run(lvl: Level) -> ObstacleTemplates{
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
            return .obstacle1
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
            return .obstacle2
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
            return .obstacle3
        case .obstacle4:
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: 0), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 0.5,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: 120), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 0.5,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
            lvl.addObstacleGenerator(position: CGPoint(x: 400, y: -120), obsParams: ObstacleParameters(
                    timeBetweenObstacles: 0.5,
                    obstacleTravelTime: 5,
                    obstacleSize: CGSize(width: 50, height: 10),
                    randomPositions: false))
            return .obstacle4
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
            return .obstacle5
        }
    }
}

class RandomizerTree {
    init(lvl:Level){
        let a = DisplacementTemplate.displace30.run(lvl: lvl, direction: .down)
        let b = WaveTemplates.sin2.run(lvl: lvl, grouping: .both)
        let c = ObstacleTemplates.obstacle3.run(lvl: lvl)
        let d = ShiftingTemplates.CE.run(lvl: lvl, newHeight: ShiftingTemplates.N3, grouping: .both)
    }
}
