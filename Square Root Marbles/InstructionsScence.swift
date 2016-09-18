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
    
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor.orangeColor()
        
        //QQQQ How do I initilize an array member?
        
        sceneCam = SKCameraNode() //initialize your camera
        sceneCam.position = CGPoint(x: size.width/2, y: size.height/2)
        self.camera = sceneCam  //set the scene's camera
        addChild(sceneCam) //add camera to scene
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //QQQQ this is silly code...
        (scene as! InstructionsScene).gameAppDelegate!.changeView((scene as! InstructionsScene).gameAppDelegate!.getReturnAppState())
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        
        let positionInScene = touch!.locationInNode(self)
        let previousPosition = touch!.previousLocationInNode(self)
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
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
