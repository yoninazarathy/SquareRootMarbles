//
//  LifesNode.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 24/09/2016.
//  Copyright © 2016 oneonepsilon. All rights reserved.
//

import Foundation
import SpriteKit

class LifesNode: SKSpriteNode{
    
    var numLifes: Int = 0
    var lifeSprites: [SKSpriteNode?]
    
    var currentLife: Double = 1.0
    
    var coverMask: SKShapeNode! = nil
    
    var diameter = 25.0
    
    var moveLifeInProgress = false
    
    var nextFreePoint: CGPoint{
        get{ //QQQQ This code is used twice in below
            return CGPoint(x: self.size.width - CGFloat(diameter*(Double((numLifes-1)%5+1)-0.5)), y: self.size.height - CGFloat(diameter*(0.5+Double((numLifes-1)/5))))
        }
    }
    
    func refreshDisplay(){
        if moveLifeInProgress{
            return
        }
        
        //QQQQ Didn't implement this...
//        if numLifes == 1{
//            if nil == lifeSprites[0]?.action(forKey: "playerAlmostDead"){
//                lifeSprites[0]?.color = SKColor.red
//                let almostDeadAction1 = SKAction.colorize(withColorBlendFactor: 1.0, duration: 0.15)
//                let almostDeadAction2 = almostDeadAction1.reversed()
//                let sequence = SKAction.sequence([almostDeadAction1, almostDeadAction2])
//                lifeSprites[0]?.run(SKAction.repeatForever(sequence), withKey: "playerAlmostDead")
//            }
//        }else{
//            lifeSprites[0]?.removeAction(forKey: "playerAlmostDead")
//        }

        
        
        removeAllChildren()
        for i in 0..<numLifes{
            let sprite = lifeSprites[i]
            sprite?.position = CGPoint(x: self.size.width - CGFloat(diameter*(Double(i%5+1)-0.5)), y: self.size.height - CGFloat(diameter*(0.5+Double(i/5))))
            addChild(sprite!)
        }
        if currentLife < 1.0{
            let bezierPath = UIBezierPath(arcCenter: CGPoint(x:0,y:0), radius: CGFloat(0.5*diameter), startAngle: 0.5 * .pi , endAngle: CGFloat(0.5 * .pi - ((1-currentLife) * 2.0) * .pi), clockwise: false)
            bezierPath.addLine(to: CGPoint(x: 0, y:0))
            bezierPath.close()
            coverMask = SKShapeNode(path: bezierPath.cgPath)
            coverMask.fillColor = SKColor.black
            coverMask.position = CGPoint(x: self.size.width - CGFloat(diameter*(Double((numLifes-1)%5+1)-0.5)), y: self.size.height - CGFloat(diameter*(0.5+Double((numLifes-1)/5))))
            coverMask.zPosition = 200
            coverMask.lineWidth = 0
            self.addChild(coverMask)
        }
    }
        
    func setLifes(_ numLifes: Int){
        self.numLifes = numLifes
        refreshDisplay()
    }
    
    func decrementLifes(){
        if numLifes > 0{
            numLifes = numLifes - 1
        }
        
        refreshDisplay()
    }

    
    func incrementLifes(_ startPosition: CGPoint){
        let srmNode = SKSpriteNode(imageNamed: "BlueSRmarble")
        srmNode.size = CGSize(width: 43, height: 43) //QQQQ const like operator node
        srmNode.position = startPosition
        srmNode.zPosition = 100 //QQQQ use constants
        scene!.addChild(srmNode)
        //QQQQ move to position offset by nextFreePoint
        currentLife = 1.0
        refreshDisplay()
        numLifes = numLifes + 1
        moveLifeInProgress = true
        let dest = convert(nextFreePoint, to: scene!)
        let move = SKAction.move(to: dest, duration: 1.2)
        let shrink = SKAction.resize(toWidth: CGFloat(diameter), height: CGFloat(diameter), duration: 1.2)
        let endMove = SKAction.run(){
            srmNode.removeFromParent()//QQQQ
            // NOTE NEEDED srmNode.size = CGSize(width: self.diameter, height: self.diameter)
            self.refreshDisplay()
            self.moveLifeInProgress = false
        }
        srmNode.run(SKAction.sequence([move, endMove]))
        srmNode.run(shrink)
    }
    

    init(position: CGPoint, diameter: Double = 25.0 ){
        self.diameter = diameter
        //QQQQ max number of lifes
        self.lifeSprites = Array<SKSpriteNode!>(repeating: nil, count: 10)
        for i in 0..<lifeSprites.count{
            lifeSprites[i] =  SKSpriteNode(imageNamed: "BlueSRmarble")
            lifeSprites[i]?.size = CGSize(width: diameter, height: diameter)
            lifeSprites[i]?.zPosition = 100 //QQQQ use constants
        }
        //QQQQ this whole thing is a bit wrong...
        super.init(texture: SKTexture(imageNamed: "popup"),color: SKColor.clear, size: CGSize(width: 5*diameter, height: 2.0*diameter))
        self.colorBlendFactor = 1.0
        self.position = position
        self.anchorPoint = CGPoint(x:0, y:0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.lifeSprites = Array<SKSpriteNode>(repeating: SKSpriteNode(), count: 5)
        
        // Decoding length here would be nice...
        super.init(coder: aDecoder)
    }
    
}
