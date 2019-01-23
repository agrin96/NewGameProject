//
// Created by Aleksandr Grin on 9/12/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//

import SpriteKit

//Holds all the parameters for the obstacle generator
struct ObstacleParameters {
    var obstacleTravelTime:Double
    var obstacleSize:CGSize
    var presetYPositions:[CGFloat]
}

//Generates an endless flow of obstacles across the screen.
class ObstacleGenerator:SKNode{
    private var obstacles:[SKSpriteNode] = []
    private var obstacleSize:CGSize = CGSize.zero
    private var obstacleTime:Double = 0
    private var obstacleSpace:Double = 0
    private var presetYPositions:[CGFloat] = []

    //Point at which the obstacles get shifted back.
    private let obstacleResetPoint:CGFloat = -(UIScreen.main.bounds.width * 2)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(params:ObstacleParameters){
        super.init()

        //Helper information
        self.obstacleTime = params.obstacleTravelTime
        self.obstacleSize = params.obstacleSize
        self.obstacleSpace = Double(UIScreen.main.bounds.width / (obstacleSize.width * CGFloat(params.presetYPositions.count)))
        self.presetYPositions = params.presetYPositions
        let count:Int = params.presetYPositions.count

        //Create the objects.
        for i in 0..<count{
            let newObstacle = SKSpriteNode(color: .blue, size: self.obstacleSize)
            newObstacle.zPosition = 4
            newObstacle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(
                    width: self.obstacleSize.width / 2,
                    height: self.obstacleSize.height / 2))

            newObstacle.physicsBody!.collisionBitMask = 1
            newObstacle.physicsBody!.contactTestBitMask = 1
            newObstacle.physicsBody!.categoryBitMask = 0
            //Prevent the obstacle from moving on collision by having much higher rest mass
            newObstacle.physicsBody!.mass = 1000
            newObstacle.position = CGPoint(x: 0, y: self.presetYPositions[i])
            self.obstacles.append(newObstacle)
            self.addChild(newObstacle)
        }
    }

    func shiftObstacleGenerator(by delta:CGFloat){
        let shiftAction = SKAction.moveTo(y: self.position.y + delta, duration: 1.5)
        self.run(shiftAction)
    }

    //Adds the SKActions that end up actually running the obstacles across the screen.
    // The actions are added to the obstacles not the generator.
    func startObstacles(){
        let moveAction = SKAction.sequence([SKAction.moveTo(x: self.obstacleResetPoint, duration: self.obstacleTime), SKAction.moveTo(x: 0, duration: 0)])

        var obsCounter:Int = 0
        let delayedActivation = SKAction.sequence([SKAction.wait(forDuration: self.obstacleSpace), SKAction.run({
            self.obstacles[obsCounter].run(SKAction.repeatForever(moveAction))
            obsCounter += 1
        })])

        self.run(SKAction.repeat(delayedActivation, count: self.obstacles.count))
    }

    //Stops the obstacles with a fading out so it is less jarring.
    func stopObstacles(){
        for obs in self.obstacles{
            obs.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5), SKAction.run({
                obs.removeAllActions()
                obs.removeFromParent()
            })]))
        }
    }
}
