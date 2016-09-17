//
//  PlayerNode.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 13/09/2016.
//  Copyright © 2016 oneonepsilon. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerNode: SKSpriteNode{

    var value: Int
    var labelNode: SKLabelNode! = nil
    
    func changeValue(newValue: Int){
        value = newValue
        labelNode.text = "\(value)"
    }
        
    func persistentSummary() -> String{
        return "(\(self.position.x),\(self.position.y))"
    }
    
    override init(texture: SKTexture?,
                  color: UIColor,
                  size: CGSize){
        self.value = 69 //QQQQ?
        super.init(texture: texture,color: color, size: size)
    }
    
    
    convenience init(initValue: Int){
        self.init(texture: SKTexture(imageNamed: "orb"), color: SKColor.redColor(), size: CGSize(width:40, height:40))
        self.value = initValue
        labelNode = SKLabelNode(text: "\(value)")
        labelNode.fontName = "AmericanTypewriter-Bold"
        labelNode.fontColor = SKColor.blueColor()
        labelNode.fontSize = 23
        labelNode.position = CGPoint(x:0,y:-8)
        labelNode.zPosition = 1
        self.addChild(labelNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Decoding length here would be nice...
        self.value = 69 //QQQQ ?
        labelNode = SKLabelNode(text: "---") //error QQQQ
        super.init(coder: aDecoder)
    }
}