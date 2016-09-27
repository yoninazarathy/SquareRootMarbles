//
//  SettingsScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit

class SettingsScene: GeneralScene {
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black

        //QQQQ synch this code with the code in GameLevelScene and MenuScene
        let buttonSize = 45.0
        let buttonSpacing = 15.0
        let resetXOffset = 0 - buttonSpacing/2 - buttonSize/2
        let backXOffset = -1*(resetXOffset)
        
        let menuWidth = 2*buttonSize+3*buttonSpacing
        let menuHeight = buttonSize + 2*buttonSpacing
        
        let menuNode = SKSpriteNode(imageNamed: "popup")
        //menuNode.colorBlendFactor = 0.8
        //menuNode.color = SKColor.redColor()
        menuNode.size = CGSize(width: menuWidth, height: menuHeight)
        menuNode.position = CGPoint(x: screenCenterPointX , y: screenCenterPointY)
        menuNode.zPosition = GameLevelZPositions.popUpMenuZ
        self.addChild(menuNode)
        
        let resetButtonNode = ResetScoresButtonNode(imageNamed: "reset")
        resetButtonNode.isUserInteractionEnabled = true
        resetButtonNode.name = "helpButton"
        resetButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
        resetButtonNode.position = CGPoint(x:resetXOffset, y:0)
        resetButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        menuNode.addChild(resetButtonNode)
        
        let backButtonNode = BackButtonNode(imageNamed: "back")
        backButtonNode.isUserInteractionEnabled = true
        backButtonNode.name = "helpButton"
        backButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
        backButtonNode.position = CGPoint(x:backXOffset, y:0)
        backButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        menuNode.addChild(backButtonNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameAppDelegate!.changeView(AppState.menuScene)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func resetAllScores(){
        print("Resetting All Scores")
        let defaults = UserDefaults.standard
        for lev in 1...numLevels{
            //QQQQ probably nicer way to do this
            if let _ = defaults.string(forKey: "level\(lev)best") {
                    defaults.removeObject(forKey: "level\(lev)best")
            }
            gameAppDelegate!.getGameLevelModel(lev).bestScoreString = ""
        }
    }
    
    //////////////////////////////////////
    // Internal Classes of Menu Buttons //
    //////////////////////////////////////
    
    //QQQQ copied these from GameLevelScene - consoloidate!
    
    class ResetScoresButtonNode : SKSpriteNode{
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! SettingsScene).resetAllScores()
            //QQQQ need here an "alert" saying, are you sure....
        }
    }

    class BackButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! SettingsScene).gameAppDelegate!.changeView(AppState.menuScene)
        }
    }
}
