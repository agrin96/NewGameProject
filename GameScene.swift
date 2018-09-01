//
//  GameScene.swift
//  Signal Process
//
//  Created by Aleksandr Grin on 8/30/18.
//  Copyright © 2018 AleksandrGrin. All rights reserved.
//

// Note: because of iphone X screen style we have to use safe insets when placing all of our scene objects.
//          This is accessed through the SkView.safeInsets parameter.

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    var player:SKSpriteNode?
    var forcesToApply:[Double] = []
    var count = 0
    var playerPath:SKShapeNode?
    var dynamicPath:CGMutablePath?
    var shift:Double = 0

    override func didMove(to view: SKView) {

        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = .gray

        let waveGen = WaveHead(color: .blue, size: CGSize(width: 9, height: 9))
        waveGen.activateWaveHead()
        self.addChild(waveGen)
        waveGen.deactivateWaveHead()


        self.player = SKSpriteNode(color: .red, size: CGSize(width: 9, height: 9))
        player!.physicsBody = SKPhysicsBody(rectangleOf: self.player!.size)
        player!.position = CGPoint(x: -self.view!.bounds.width / 4, y: 0)
        player!.physicsBody!.linearDamping = 0
        player!.physicsBody!.density = 1
        player!.physicsBody!.friction = 0
        self.addChild(self.player!)

        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        self.dynamicPath = CGMutablePath()

        self.playerPath = SKShapeNode(path: self.dynamicPath!)
        self.playerPath!.position = self.player!.position
        self.playerPath!.lineWidth = 5
        self.playerPath!.strokeColor = .red
        self.addChild(self.playerPath!)


        let numSamples = 100
        for i in 0..<numSamples{
            let yVal = 300 * sin((2*Double.pi*1*Double(i)) / Double(numSamples+1))
            self.forcesToApply.append(yVal)
        }

        print(self.forcesToApply)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        self.playerPath!.position.x -= 0.5
        self.player!.physicsBody!.velocity = CGVector(dx: 0, dy: self.forcesToApply[self.count])
        self.dynamicPath!.addLine(to: CGPoint(x: CGFloat(self.shift), y: self.player!.position.y))
        self.dynamicPath!.closeSubpath()
        self.playerPath!.path = self.dynamicPath
        self.dynamicPath!.move(to: CGPoint(x: CGFloat(self.shift), y: self.player!.position.y))
        self.shift += 0.5

        self.count += 1
        if self.count >= 100{
            self.count = 0
        }
    }
}
