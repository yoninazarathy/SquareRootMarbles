//
//  VictoryScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit

class VictoryScene: GeneralScene {
    
    var timer: Timer? = nil
        
    override func didMove(to view: SKView) {
        
        self.backgroundColor = SKColor.black
                        
        var messageText: [String?] = Array(repeating: nil, count: 0)
        messageText.append("You did it!!!")
        messageText.append("You got through all the levels")
        messageText.append("of Square Root Marbles!!!")
        messageText.append("")
        messageText.append("Now try to think of ")
        messageText.append("the square root of -1 ...")
        messageText.append("")
        messageText.append("Does such a number exist?")
        messageText.append("Ask your friends, teachers or family.")

        let x = screenWidth/2
        var y = 0.9*screenHeight
        for txt in messageText{
            let label = SKLabelNode(text: txt)
            label.position = CGPoint(x: x, y: y)
            label.fontSize = 20
            label.fontColor = SKColor.white
            label.fontName = "AmericanTypewriter-Bold"
            y = y - 50
            self.addChild(label)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameAppDelegate!.changeView(AppState.menuScene)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
}
