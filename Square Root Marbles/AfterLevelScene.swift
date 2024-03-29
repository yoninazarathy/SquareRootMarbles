//
//  AfterLevelScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit


class OperationRecordSprite: SKSpriteNode{
    
    var labelNode: SKLabelNode
    
    var imageNode: SKSpriteNode! = nil
    
    override init(texture: SKTexture?,
                  color: UIColor,
                  size: CGSize){
        labelNode = SKLabelNode(text: "---") //error QQQQ
        super.init(texture: texture,color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Decoding length here would be nice...
        labelNode = SKLabelNode(text: "---") //error QQQQ
        super.init(coder: aDecoder)
    }

    convenience init(initValue: (String,Int,Int)){
        self.init(texture: SKTexture(imageNamed: "popup"), color: SKColor.red, size: CGSize(width:120, height:40))
        
        //QQQQ brutally duplicated from MessageNode
        let strOp: String
        switch initValue.0{
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
        case "sqrt":
            imageNode = SKSpriteNode(imageNamed: "sqrtCalc\(initValue.2)")
            imageNode.size = CGSize(width: 1.5*120, height: 1.5*40) //QQQQ
            imageNode.zPosition = 1;
            imageNode.position = CGPoint(x: 0, y:0)
            imageNode.color = SKColor.white
            imageNode.colorBlendFactor = 1.0
            self.addChild(imageNode)
            strOp = "sqrt"
        default:
            strOp = "error" //QQQQ
        }
        
        if initValue.0 != "sqrt"{
            labelNode = SKLabelNode(text: "\(initValue.1) \(strOp) = \(initValue.2)")
            labelNode.fontName = "AmericanTypewriter-Bold"
            labelNode.fontColor = SKColor.white
            labelNode.fontSize = 38
            labelNode.position = CGPoint(x:0,y:-14) //QQQQ not sure
            labelNode.zPosition = 1
            self.addChild(labelNode)
        }
        self.color = SKColor.black
        self.colorBlendFactor = 1.0
    }
}

class AfterLevelScene: GeneralScene {
    
    var operationSprites: [OperationRecordSprite] = []
    
    var currentOpIndex = 0
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
                        
        var messageText: [String?] = Array(repeating: nil, count: 0)
        
        let log = gameAppDelegate!.getOperationLog()

        if log.count == 0{
            //messageText.append("Try again")
            gameAppDelegate!.changeView(AppState.menuScene)
            //QQQQ not sure this is what to do here
        }else{
            if gameAppDelegate!.getAppState() == AppState.afterLevelSceneFinished{
                messageText.append("Good Effort!")
                messageText.append("Your last moves:")
            }else{
                messageText.append("Going Good!")
                messageText.append("Your last moves:")
            }
            
            for ev in log{
                let sprite = OperationRecordSprite(initValue: (ev.0,ev.1,ev.2))
                sprite.position =  CGPoint(x: screenCenterPointX, y: 0.65 * screenHeight)
                sprite.size = CGSize(width: 220.0, height: 80.0)
                operationSprites.append(sprite)
                //messageText.append(ev.0)
            }
            self.addChild(operationSprites[currentOpIndex])
        }
        
        var y = 0.85*screenHeight
        for txt in messageText{
            let label = SKLabelNode(text: txt)
            label.position = CGPoint(x: screenCenterPointX, y: y)
            label.fontSize = 32
            label.fontColor = SKColor.white
            label.fontName = "AmericanTypewriter-Bold"
            y = y - 45
            self.addChild(label)
        }

        
        let okButton = OKButtonNode(imageNamed: "ok-button-md")
        okButton.size = CGSize(width: 60, height: 60) //QQQQ
        okButton.position = CGPoint(x: screenCenterPointX, y: screenCenterPointY)
        okButton.isUserInteractionEnabled = true

        self.addChild(okButton)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        timer!.invalidate()
//        gameAppDelegate!.changeView(AppState.menuScene)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    class OKButtonNode : SKSpriteNode{
        
     //   var active: Bool = true
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//            if !active{
//                return
//            }
            
            
            let ms = (scene as! AfterLevelScene) //mother scene
            ms.playButtonClick()
            
            //had this here when had a wait, but now no.
            //self.active = false
            
    //        var sqrtSoundPlaying = false

            
            if ms.currentOpIndex < ms.operationSprites.count-1{
                ms.operationSprites[ms.currentOpIndex].removeFromParent()
                ms.currentOpIndex = ms.currentOpIndex + 1
                ms.addChild(ms.operationSprites[ms.currentOpIndex])
                if ms.operationSprites[ms.currentOpIndex].imageNode != nil{
                    ms.playRandomSRM()
            //        sqrtSoundPlaying = true
                }
            }else{
                let delegate = ms.gameAppDelegate!
                delegate.clearOperationLog()
                if delegate.getAppState() == AppState.afterLevelSceneFinished{
                    delegate.changeView(AppState.menuScene)
                }else{
                    delegate.setLevel(delegate.getLevel()+1)
                    delegate.changeView(AppState.gameActionPlaying)
                }
            }
            
            //removed the wait...
//            let fade = SKAction.fadeOut(withDuration: sqrtSoundPlaying ? 1.0 : 0.4)
//            let rFade = fade.reversed()
//            let enable = SKAction.run {
//                self.active = true
//            }
//            self.run(SKAction.sequence([fade, rFade, enable]))

        }
        
    }
    

    
}
