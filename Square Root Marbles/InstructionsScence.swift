//
//  InstructionsScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit

class InstructionsScene: GeneralScene {
    
    var sceneCam: SKCameraNode!
    
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.orange
        
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

        
        
        sceneCam = SKCameraNode() //initialize your camera
        sceneCam.position = CGPoint(x: size.width/2, y: size.height/2)
        self.camera = sceneCam  //set the scene's camera
        addChild(sceneCam) //add camera to scene
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        let positionInScene = touch!.location(in: self)
        let previousPosition = touch!.previousLocation(in: self)
        let translation = CGPoint(x: 0, y: positionInScene.y - previousPosition.y)
        
        var newYPosition = sceneCam.position.y - translation.y
        //QQQQ adjust these constants and any others...
        
        //upper bound for scrolling up
        if newYPosition > CGFloat(screenHeight){
            newYPosition = CGFloat(screenHeight)
        }
        
        //lower bound for scrolling down
        if newYPosition < 0{
            newYPosition = 0
        }
        
        sceneCam.position = CGPoint(x: sceneCam.position.x , y: newYPosition)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    class BackButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! InstructionsScene).playButtonClick()
            //QQQQ this is silly code...
            (scene as! InstructionsScene).gameAppDelegate!.changeView((scene as! InstructionsScene).gameAppDelegate!.getReturnAppState())        }
    }

}
