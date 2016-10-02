//
//  MessageNode.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 17/09/2016.
//  Copyright © 2016 oneonepsilon. All rights reserved.
//

import Foundation
import SpriteKit

class MessageNode: SKSpriteNode{

    var label: SKLabelNode! = nil
    var image: SKSpriteNode! = nil
    
    //QQQQ How to preallocate 10?
    var squareRootTextures: [SKTexture]=[]
    
    static var messageLog: [(String,Int,Int)] = []
    
    //QQQQ do this as a computed propery
    func hasFaded() -> Bool{
        return label.alpha < 0.02
    }
    
    func displayMessage(_ text: String){
        image.removeFromParent()
        self.addChild(label)
        removeAllActions()
        label.text = text
        label.alpha = 1.0
    }
    
    func displayFadingMessage(_ text: String, duration: Double){
        label.removeFromParent()
        image.removeFromParent()
        self.addChild(label)
        image.removeAllActions()
        label.removeAllActions()
        
        label.text = text
        label.alpha = 1.0
        label.removeAllActions()
        label.run(SKAction.fadeAlpha(to: 0, duration: duration))
    }
    
    func displayFadingImage(_ texture: SKTexture, duration: Double){
        label.removeFromParent()
        image.removeFromParent()
        self.addChild(image)
        image.removeAllActions()
        label.removeAllActions()

        image.texture = texture
        image.alpha = 1.0
        
        image.run(SKAction.fadeAlpha(to: 0, duration: duration))
    }

    
    init(position: CGPoint){
        
        for i in 0...10{
            squareRootTextures.append(SKTexture(imageNamed: "sqrtCalc\(i)")) //QQQQ
        }

        //QQQQ this whole thing is a bit wrong...
        super.init(texture: SKTexture(imageNamed: "popup"),color: SKColor.clear, size: CGSize(width: 200, height: 30))
        self.colorBlendFactor = 1.0
        self.position = position
        self.anchorPoint = CGPoint(x:0, y:0.5)
        label = SKLabelNode()
        label.zPosition = 1;
        label.position = CGPoint(x: 0, y:0)
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        label.color = SKColor.white
        label.fontSize = 26
        label.fontName = "AmericanTypewriter-Bold"
        
        image = SKSpriteNode()
        image.size = CGSize(width: 120, height: 40)
        image.zPosition = 1;
        image.position = CGPoint(x: 40, y:15) //????
        image.color = SKColor.white
        image.colorBlendFactor = 1.0
     }
    
    required init?(coder aDecoder: NSCoder) {
        // Decoding length here would be nice...
        super.init(coder: aDecoder)
    }

    
    func displayOperationPass(_ operation: String, oldValue: Int, newValue: Int, duration: Double){
        if operation == "sqrt"{
            displayFadingImage(squareRootTextures[newValue],duration: duration)
        }else{
            let strOp: String
            switch operation{
                case "-1":
                strOp = "- 1"
                case "+1":
                    strOp = "+ 1"
                case "*2":
                    strOp = "x 2"
                case "*3":
                    strOp = "x 3"
                case "*4":
                    strOp = "x 4"
                case "*5":
                    strOp = "x 5"
            default:
                strOp = "error" //QQQQ
            }
            let string = "\(oldValue) \(strOp)  = \(newValue)"
            //QQQQ slice white spaces here
            displayFadingMessage(string, duration: duration)
        }
    }
}
