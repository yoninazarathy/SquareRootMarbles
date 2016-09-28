//
//  AfterLevelScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit

class AfterLevelScene: GeneralScene {
    
    var timer: Timer? = nil
    
    override func didMove(to view: SKView) {
        //QQQQ problem if clicked before - need to kill timer
        timer = Timer.scheduledTimer(timeInterval: timeInAfterLevelScene, target: self, selector: #selector(timerExpired), userInfo: nil, repeats: false)
        
        self.backgroundColor = SKColor.black
        
        //QQQQ slightly improve the appDelgate so that compositions such as this aren't needed (they are used elsewhere also
        let model = gameAppDelegate!.getGameLevelModel(gameAppDelegate!.getLevel())
                
        var messageText: [String?] = Array(repeating: nil, count: 0)
//        if model.newScoreString == ""{
//            messageText.append("No success for level \(model.levelNumber)")
//            messageText.append("Level record: \(model.bestScoreString)")
//        }else{
//            messageText.append("Level \(model.levelNumber) in \(model.newScoreString)")
//
//            if model.newScoreCentiSecond < model.bestScoreCentiSecond{
//                if model.bestScoreString == ""{
//                    messageText.append("First completion time. Record Set.")
//                }else{
//                    messageText.append("New record!!! Previous was \(model.bestScoreString)")
//                }
//                
//                //update and store in UserDefaults
//                model.bestScoreString = model.newScoreString
//                let defaults = UserDefaults.standard
//                defaults.set(model.bestScoreString, forKey: "level\(model.levelNumber)best")
//                
//            }else{
//                messageText.append("Record for level \(model.bestScoreString)")
//                messageText.append("You didn't beat that time")
//            }
//            
//        }

        let x = screenWidth/2
        var y = 0.8*screenHeight
        for txt in messageText{
            print(txt)
            let label = SKLabelNode(text: txt)
            label.position = CGPoint(x: x, y: y)
            label.fontSize = 20
            label.fontColor = SKColor.white
            label.fontName = "AmericanTypewriter-Bold"
            y = y - 50
            self.addChild(label)
        }
    }
    
    func timerExpired(){
        gameAppDelegate!.changeView(AppState.menuScene)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        timer!.invalidate()
        gameAppDelegate!.changeView(AppState.menuScene)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
}
