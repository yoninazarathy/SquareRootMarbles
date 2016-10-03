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
    var underline: SKShapeNode! = nil
    
    func changeValue(_ newValue: Int){
        value = newValue
        labelNode.text = "\(value)"
        underline.removeFromParent()
        if has6or9(){
            self.addChild(underline)
        }
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
    
    
    func has6or9()-> Bool{
        let ones = value % 10
        let tenth = value - ones
        return ones == 6 || tenth == 6 || ones == 9 || tenth == 9
    }
    
    convenience init(initValue: Int){
        self.init(texture: SKTexture(imageNamed: "orb"), color: SKColor.red, size: CGSize(width:40, height:40))
        self.value = initValue
        labelNode = SKLabelNode(text: "\(value)")
        labelNode.fontName = "AmericanTypewriter-Bold"
        labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        labelNode.fontColor = SKColor.white
        labelNode.fontSize = 22
        labelNode.position = CGPoint(x:0,y:-8)
        labelNode.zPosition = 1
        self.addChild(labelNode)
        
        underline = SKShapeNode(rectOf: CGSize(width: 17, height: 2.5))
        
        underline.fillColor = SKColor.white
        underline.lineWidth = 0
        underline.zPosition = 2
        underline.position = CGPoint(x:0,y:-11)
        if has6or9(){
            self.addChild(underline)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Decoding length here would be nice...
        self.value = 69 //QQQQ ?
        labelNode = SKLabelNode(text: "---") //error QQQQ
        super.init(coder: aDecoder)
    }
}
