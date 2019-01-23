//
// Created by Aleksandr Grin on 9/12/18.
// Copyright (c) 2018 AleksandrGrin. All rights reserved.
//

import SpriteKit

//Used to denote the direction in which a wavehead is traveling
enum Direction{
    case up, down
}

//Creates an oscillating up and down point which can be sampled and can act as the player.
class WaveHead:SKSpriteNode {

    private var p_osciallationForces:[CGFloat] = []
    private var n_osciallationForces:[CGFloat] = []
    private var oscillationCount:Int = 0

    //used to track which direction the wave head is currently traveling
    var currentHeadDirection:Direction = .up

    required init?(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)
    }

    override init(texture: SKTexture?, color:UIColor, size:CGSize){
        super.init(texture: texture, color:color, size:size)
    }

    convenience init(params:WaveHeadParameters){
        self.init(texture: nil, color:params.headColor, size:params.headSize)
        //Run an initialization on the wavehead to make sure that all of necessary physics values
        // are set as required.
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        //Setup wavehead to detect collision with boundary waves if it is the player
        if params.isPlayer == true{
            self.physicsBody = SKPhysicsBody(circleOfRadius: (self.size.width / 1.1))
            self.physicsBody!.linearDamping = 0.0
            self.physicsBody!.friction = 0.0
            self.physicsBody!.density = 1

            self.physicsBody!.collisionBitMask = 0
            self.physicsBody!.categoryBitMask = 1
            self.physicsBody!.contactTestBitMask = 1
            self.physicsBody!.allowsRotation = false
            self.physicsBody!.usesPreciseCollisionDetection = true
        }

        self.p_osciallationForces = WaveType.steady().flatMap({$0})
        self.n_osciallationForces = WaveType.steady().flatMap({$0}).map({return -$0})
    }

    //Starts the infinite oscillation of the WaveHead
    func activateWaveHead(){
        self.oscillationCount = 0
        var goingUp = true

        let vectorChange = SKAction.run({
            if goingUp == true{
                self.position = CGPoint(x: self.position.x, y: (self.position.y + CGFloat(self.p_osciallationForces[self.oscillationCount])))
                self.oscillationCount += 1
                if self.oscillationCount >= self.p_osciallationForces.count{
                    self.oscillationCount = 0
                    goingUp = false
                }
            }else{
                self.position = CGPoint(x: self.position.x, y: (self.position.y + CGFloat(self.n_osciallationForces[self.oscillationCount])))
                self.oscillationCount += 1
                if self.oscillationCount >= self.n_osciallationForces.count{
                    self.oscillationCount = 0
                    goingUp = true
                }
            }
        })

        //Here we set a wait time of one frame between velocity changes to make sure our framerate is synced.
        let oscillationAction = SKAction.group([vectorChange, SKAction.wait(forDuration: 1/120)])
        self.run(SKAction.repeatForever(oscillationAction))
    }

    //Separate function which specifies when to activate the player wavehead. It takes an input parameter which
    // will be used to control whether it is moving up or down.
    func activatePlayerWavehead(direction:Direction){
        self.oscillationCount = 0
        self.currentHeadDirection = direction

        //Reset the previous action, whether it was going up or going down.
        self.removeAllActions()

        let vectorChange = SKAction.run({
            if direction == .up{
                self.position = CGPoint(x: self.position.x, y: (self.position.y + CGFloat(self.p_osciallationForces[self.oscillationCount])))
                self.oscillationCount += 1
                if self.oscillationCount >= self.p_osciallationForces.count{
                    self.oscillationCount = 0
                }
            }else if direction == .down{
                self.position = CGPoint(x: self.position.x, y: (self.position.y + CGFloat(self.n_osciallationForces[self.oscillationCount])))
                self.oscillationCount += 1
                if self.oscillationCount >= self.n_osciallationForces.count{
                    self.oscillationCount = 0
                }
            }
        })
        //Here we set a wait time of one frame between velocity changes to make sure our framerate is synced.
        let oscillationAction = SKAction.group([vectorChange, SKAction.wait(forDuration: 1/120)])
        self.run(SKAction.repeatForever(oscillationAction))
    }

    //Stops the infinite oscillation of the WaveHead
    func deactivateWaveHead(){
        self.removeAllActions()
    }

    //This funciton is used to inject different oscillation styles into the wavehead.
    func changeOscillation(to forces:[[CGFloat]]){
        self.oscillationCount = 0
        self.p_osciallationForces = forces.flatMap({$0})
        self.n_osciallationForces = forces.flatMap({$0}).map({return -$0})

        //Reset the movement in a smooth way.
        self.deactivateWaveHead()
        self.run(SKAction.moveTo(y: 0, duration: 1.0)){
            self.activateWaveHead()
        }
    }
}

