//
//  SinkNode.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 15/09/2016.
//  Copyright © 2016 oneonepsilon. All rights reserved.
//

import Foundation
import SpriteKit

class SinkNode: SKSpriteNode{
    
    var targetValue: Int
    var labelNode: SKLabelNode! = nil
    
    var valid: Bool! = nil
    
    func setAsValid(){
        valid = true
        physicsBody!.categoryBitMask = PhysicsCategory.Sink
        color = SKColor.green
        colorBlendFactor = 0.75
    }
    
    func setAsInvalid(){
        valid = false
        color = SKColor.red
        physicsBody!.categoryBitMask = PhysicsCategory.Sink | PhysicsCategory.BlockingOperator
        colorBlendFactor = 0.75
    }
    
    func persistentSummary() -> String{
        return "(\(self.position.x),\(self.position.y))"
    }
    
    override init(texture: SKTexture?,
                  color: UIColor,
                  size: CGSize){
        self.targetValue = 42
        super.init(texture: texture,color: color, size: size)
    }
    
    
    convenience init(target: Int){
        self.init(texture: SKTexture(imageNamed: "sink"), color: SKColor.red, size: CGSize(width:55, height:55)) //QQQQ
        self.targetValue = target
        labelNode = SKLabelNode(text: "\(targetValue)")
        
        labelNode.fontName = "AmericanTypewriter-Bold"
        labelNode.fontColor = SKColor.white
        labelNode.fontSize = 31
        labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        labelNode.position = CGPoint(x:0, y: -12) //QQQQ
        labelNode.blendMode = SKBlendMode.add
        labelNode.colorBlendFactor = 0
        //labelNode.position = ???
        labelNode.zPosition = 1
        self.addChild(labelNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Decoding length here would be nice...
        self.targetValue = 69
        labelNode = SKLabelNode(text: "---") //error QQQQ
        super.init(coder: aDecoder)
    }
}
