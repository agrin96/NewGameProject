//
// Created by Aleksandr Grin on 9/12/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//

import SpriteKit

//Holds all the parameters for the obstacle generator
struct ObstacleParameters {
    var timeBetweenObstacles:Double
    var obstacleTravelTime:Double
    var obstacleSize:CGSize
}

//Generates an endless flow of obstacles across the screen.
class ObstacleGenerator:SKNode{
    private var obstacles:[SKSpriteNode] = []
    private var obstacleSize:CGSize = CGSize.zero
    private var obstacleTime:Double = 0
    private var obstacleSpace:Double = 0

    //Point at which the obstacles get shifted back.
    private let obstacleResetPoint:CGFloat = -600

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(params:ObstacleParameters){
        super.init()

        //Helper information
        self.obstacleTime = params.obstacleTravelTime
        self.obstacleSize = params.obstacleSize
        self.obstacleSpace = params.timeBetweenObstacles
        let count:Int = 5

        //Create the objects.
        for _ in 0..<count{
            let newObstacle = SKSpriteNode(color: .blue, size: self.obstacleSize)
            newObstacle.zPosition = 4
            newObstacle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(
                    width: self.obstacleSize.width / 2,
                    height: self.obstacleSize.height / 2))

            newObstacle.physicsBody!.collisionBitMask = 1
            newObstacle.physicsBody!.contactTestBitMask = 1
            newObstacle.physicsBody!.categoryBitMask = 0
            newObstacle.position = CGPoint(x: 0, y: 0)
            self.obstacles.append(newObstacle)
            self.addChild(newObstacle)
        }
    }

    //Adds the SKActions that end up actually running the obstacles across the screen.
    // The actions are added to the obstacles not the generator.
    func startObstacles(){
        let moveAction = SKAction.sequence([SKAction.moveTo(x: -600, duration: self.obstacleTime), SKAction.moveTo(x: 0, duration: 0)])

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
