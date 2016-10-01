//
//  SettingsScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit

//QQQQ
//audioButtonNode.isUserInteractionEnabled = true
//audioButtonNode.name = "audioButton"
//audioButtonNode.size = CGSize(width:menuButtonSize, height: menuButtonSize)
//audioButtonNode.position = CGPoint(x:auidoXOffset, y:0)
//
////QQQ Not sure need to set this z position
//audioButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
//self.addChild(audioButtonNode)


class SettingsScene: GeneralScene {
    
    var messageLabelNode: MessageNode! = nil
    
    var clicksToReset = 3

    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black

        //QQQQ synch this code with the code in GameLevelScene and MenuScene
        let buttonSize = 45.0
        let buttonSpacing = 15.0
        
        let backXOffset = 0 - buttonSpacing - buttonSize
        let resetXOffset = 0
        let auidoXOffset = -1*(backXOffset)
        
        
        let menuWidth = 3*buttonSize+4*buttonSpacing
        let menuHeight = buttonSize + 2*buttonSpacing
        
        let menuNode = SKSpriteNode(imageNamed: "popup")
        menuNode.size = CGSize(width: menuWidth, height: menuHeight)
        menuNode.position = CGPoint(x: screenCenterPointX , y: 0.6*screenHeight)
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
        
        let audioButtonNode = AudioButtonNode(imageNamed: "audio")
        audioButtonNode.name = "audioButton"
        audioButtonNode.isUserInteractionEnabled = true
        audioButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
        audioButtonNode.position = CGPoint(x:auidoXOffset, y:0)
        audioButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        menuNode.addChild(audioButtonNode)

        messageLabelNode = MessageNode(position: CGPoint(x: screenCenterPointX , y: 0.4*screenHeight))
        messageLabelNode.label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        messageLabelNode.displayMessage("Settings")
        self.addChild(messageLabelNode)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if self.messageLabelNode.hasFaded(){
            clicksToReset = 3
        }
    }
    
    func resetAllScores(){
        print("Resetting All Scores")
        GameAnalytics.addDesignEvent(withEventId: "resetAllScores")
        let defaults = UserDefaults.standard
        for lev in 1...numLevels{
            //QQQQ probably nicer way to do this
            if let _ = defaults.string(forKey: "level\(lev)marbles") {
                    defaults.removeObject(forKey: "level\(lev)marbles")
            }
            gameAppDelegate!.getGameLevelModel(lev).numMarbles = lev == 1 ? 3 : 0
        }
    }
    
    //////////////////////////////////////
    // Internal Classes of Menu Buttons //
    //////////////////////////////////////
    
    //QQQQ copied these from GameLevelScene - consoloidate!
    
    class ResetScoresButtonNode : SKSpriteNode{
        
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let messageNode = (scene as! SettingsScene).messageLabelNode!
            let settingsScene = (scene as! SettingsScene)
            switch settingsScene.clicksToReset{
            case 3:
                settingsScene.playButtonClick()
                messageNode.displayFadingMessage("Reset marbles? Click 3 times", duration: 2.0)
                settingsScene.clicksToReset = 2
            case 2:
                settingsScene.playButtonClick()
                if messageNode.hasFaded() == false{
                    messageNode.displayFadingMessage("Reset marbles? Click 2 times", duration: 2.0)
                    settingsScene.clicksToReset = 1
                }else{
                    settingsScene.clicksToReset = 3
                }
            case 1:
                settingsScene.playButtonClick()
                if messageNode.hasFaded() == false{
                    messageNode.displayFadingMessage("Reset marbles? Click again", duration: 2.0)
                    settingsScene.clicksToReset = 0
                }else{
                    settingsScene.clicksToReset = 3
                }
            case 0:
                if messageNode.hasFaded() == false{
                    messageNode.displayFadingMessage("Marbles reset", duration: 2.0)
                    settingsScene.clicksToReset = 3
                    settingsScene.playTrashSound()
                    settingsScene.resetAllScores()
                }else{
                    //this won't really happen due to update() QQQQ
                    settingsScene.clicksToReset = 3
                    settingsScene.playButtonClick()
                }
            default:
                break
            }
        }
    }

    class BackButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! SettingsScene).playButtonClick()
            (scene as! SettingsScene).gameAppDelegate!.changeView(AppState.menuScene)
        }
    }
    
    class AudioButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! SettingsScene).playButtonClick()
            (scene as! SettingsScene).clicksToReset = 3
            
            (scene as! SettingsScene).toggleAudio()

            if GeneralScene.audioOff{
                (scene as! SettingsScene).messageLabelNode.displayFadingMessage("Audio Off", duration: 2.0)
            }else{
                (scene as! SettingsScene).messageLabelNode.displayFadingMessage("Audio On", duration: 2.0)
            }
        }
    }
}
