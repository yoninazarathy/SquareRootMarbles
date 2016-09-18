//
//  AfterLevelScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit

class AfterLevelScene: GeneralScene {
    
    var timer: NSTimer? = nil
    
    override func didMoveToView(view: SKView) {
        //QQQQ problem if clicked before - need to kill timer
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInAfterLevelScene, target: self, selector: #selector(timerExpired), userInfo: nil, repeats: false)
        
        self.backgroundColor = SKColor.blackColor()
        
        //QQQQ slightly improve the appDelgate so that compositions such as this aren't needed (they are used elsewhere also
        let model = gameAppDelegate!.getGameLevelModel(gameAppDelegate!.getLevel())
        
        var messageText: [String?] = Array(count: 0, repeatedValue: nil)
        if model.newScoreString == ""{
            messageText.append("No success for level \(model.levelNumber)")
            messageText.append("Level record: \(model.bestScoreString)")
        }else{
            messageText.append("Level \(model.levelNumber) in \(model.newScoreString)")

            if model.newScoreCentiSecond < model.bestScoreCentiSecond{
                if model.bestScoreString == ""{
                    messageText.append("First completion time. Record Set.")
                }else{
                    messageText.append("New record!!! Previous was \(model.bestScoreString)")
                }
                
                //update and store in UserDefaults
                model.bestScoreString = model.newScoreString
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(model.bestScoreString, forKey: "level\(model.levelNumber)best")
                
            }else{
                messageText.append("Record for level \(model.bestScoreString)")
                messageText.append("You didn't beat that time")
            }
            
        }

        let x = screenWidth/2
        var y = 0.8*screenHeight
        for txt in messageText{
            print(txt)
            let label = SKLabelNode(text: txt)
            label.position = CGPoint(x: x, y: y)
            label.fontSize = 20
            label.fontColor = SKColor.whiteColor()
            label.fontName = "AmericanTypewriter-Bold"
            y = y - 50
            self.addChild(label)
        }
    }
    
    func timerExpired(){
        gameAppDelegate!.changeView(AppState.menuScene)
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        timer!.invalidate()
        gameAppDelegate!.changeView(AppState.menuScene)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
}
