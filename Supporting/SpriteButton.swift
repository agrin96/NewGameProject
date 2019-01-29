//
//  SpriteButton.swift
//  Signal Process
//
//  Created by Aleksandr Grin on 1/28/19.
//  Copyright © 2019 AleksandrGrin. All rights reserved.
//

import SpriteKit

class SpriteButton: SKSpriteNode {
    
    var buttonDefault:SKTexture?
    var buttonTouched:SKTexture?
    var text:SKLabelNode?
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(button: SKTexture, buttonTouched: SKTexture){
        let size = button.size()
        self.init(texture: button, color: .white, size: size)
        
        self.buttonDefault = button
        self.buttonTouched = buttonTouched
    }
    
    func setButtonText(text: String){
        let newLabel = SKLabelNode(text: text)
        newLabel.fontName = "Futura-CondensedExtraBold"
        newLabel.fontSize = 16
        newLabel.fontColor = .black
        newLabel.zPosition = 1000
        newLabel.horizontalAlignmentMode = .center
        newLabel.verticalAlignmentMode = .center
        self.text = newLabel
        self.addChild(self.text!)
    }
    
    func setButtonScale(to: CGFloat){
        self.setScale(to)
        self.text!.setScale(1.0/to)
    }
    
    func setButtonTextFont(size: CGFloat){
        self.text!.fontSize = size
        if self.text != nil {
            if self.text!.children.count > 0 {
                for node in self.text!.children {
                    (node as! SKLabelNode).fontSize = size
                }
            }
        }
    }
    
    func buttonTouchedUpInside(completion: @escaping () -> ()){
        if self.hasActions() == false{
            let currentTexture = self.texture
            let textureToDefault = SKAction.setTexture(currentTexture!)
            let textureToPress = SKAction.setTexture(buttonTouched!)
            let pressAnimation = SKAction.sequence([textureToPress, SKAction.wait(forDuration: 0.25), textureToDefault])
            
            self.run(pressAnimation)
            completion()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
