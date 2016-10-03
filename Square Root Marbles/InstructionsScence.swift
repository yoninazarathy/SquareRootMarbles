//
//  InstructionsScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit

class InstructionsScene: GeneralScene {
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        
        //QQQQ synch this code with the code in GameLevelScene and MenuScene
        let buttonSize = 45.0
        let buttonSpacing = 15.0

        
        let backButtonNode = BackButtonNode(imageNamed: "back")
        backButtonNode.isUserInteractionEnabled = true
        backButtonNode.name = "helpButton"
        backButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
        backButtonNode.position = CGPoint(x: buttonSize/2 + buttonSpacing, y:screenHeight - (buttonSize/2 + buttonSpacing))
        backButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        self.addChild(backButtonNode)
        
        let grow = SKAction.scale(by: 1.3, duration: 2.0)
        let shrink = grow.reversed()
        backButtonNode.run(SKAction.repeatForever(SKAction.sequence([grow, shrink])))
        
        GameAnalytics.addDesignEvent(withEventId: "instructionsEnter")
        
    }
    
    class BackButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! InstructionsScene).playButtonClick()
            //QQQQ this is silly code...
            (scene as! InstructionsScene).gameAppDelegate!.changeView((scene as! InstructionsScene).gameAppDelegate!.getReturnAppState())
            GameAnalytics.addDesignEvent(withEventId: "instructionsExit")

        }
    }

}
