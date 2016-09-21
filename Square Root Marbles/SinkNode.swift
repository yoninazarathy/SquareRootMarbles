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
        color = SKColor.greenColor()
        colorBlendFactor = 0.75
    }
    
    func setAsInvalid(){
        valid = false
        color = SKColor.redColor()
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
        self.init(texture: SKTexture(imageNamed: "sink"), color: SKColor.redColor(), size: CGSize(width:50, height:50))
        self.targetValue = target
        labelNode = SKLabelNode(text: "\(targetValue)")
        
        labelNode.fontName = "AmericanTypewriter-Bold"
        labelNode.fontColor = SKColor.whiteColor()
        labelNode.fontSize = 40
        labelNode.position = CGPoint(x:0, y: -15) //QQQQ
        labelNode.blendMode = SKBlendMode.Add
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