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
            labelNode.position = CGPoint(x:0,y:-10) //QQQQ not sure
            labelNode.zPosition = 1
            self.addChild(labelNode)
        }
        self.color = SKColor.black
        self.colorBlendFactor = 1.0
    }
}

class AfterLevelScene: GeneralScene {
    
    var timer: Timer? = nil
    
    var operationSprites: [OperationRecordSprite] = []
    
    var currentOpIndex = 0
    
    override func didMove(to view: SKView) {
        //QQQQ problem if clicked before - need to kill timer
        timer = Timer.scheduledTimer(timeInterval: timeInAfterLevelScene, target: self, selector: #selector(timerExpired), userInfo: nil, repeats: false)
        
        self.backgroundColor = SKColor.black
        
        //QQQQ slightly improve the appDelgate so that compositions such as this aren't needed (they are used elsewhere also
        let model = gameAppDelegate!.getGameLevelModel(gameAppDelegate!.getLevel())
                
        var messageText: [String?] = Array(repeating: nil, count: 0)
        
        let log = gameAppDelegate!.getOperationLog()

        if log.count == 0{
            messageText.append("Try again")
        }else{
            messageText.append("Good Effort!")
            messageText.append("See your moves:")
            
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
            print(txt)
            let label = SKLabelNode(text: txt)
            label.position = CGPoint(x: screenCenterPointX, y: y)
            label.fontSize = 30
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
    
    func timerExpired(){
        gameAppDelegate!.changeView(AppState.menuScene)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        timer!.invalidate()
//        gameAppDelegate!.changeView(AppState.menuScene)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    class OKButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let ms = (scene as! AfterLevelScene) //mother scene
            ms.playButtonClick()
            if ms.currentOpIndex < ms.operationSprites.count-1{
                ms.operationSprites[ms.currentOpIndex].removeFromParent()
                ms.currentOpIndex = ms.currentOpIndex + 1
                ms.addChild(ms.operationSprites[ms.currentOpIndex])
            }else{
                ms.gameAppDelegate!.changeView(AppState.menuScene)
            }
        }
        
    }
    

    
}
