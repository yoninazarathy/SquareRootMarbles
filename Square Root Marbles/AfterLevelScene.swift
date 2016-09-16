//
//  AfterLevelScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit

class AfterLevelScene: GeneralScene {
    
    var sceneCam: SKCameraNode!
    
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor.orangeColor()
        
        //QQQQ How do I initilize an array member?
        
        for i in 1.stride(to: numLevels, by: 2) {
            var x = 120
            var y = 1300-75*(i-1)
            var shapeNode = SKShapeNode(rect: CGRect(x: x-30, y:y-30, width: 65, height: 65))
            shapeNode.zPosition = -5
            shapeNode.fillColor = SKColor.yellowColor()
            shapeNode.strokeColor = SKColor.blueColor()
            self.addChild(shapeNode)
            x = 414-120
            y = 1300-75*(i-1)
            
            shapeNode = SKShapeNode(rect: CGRect(x: x-30, y:y-30, width: 65, height: 65))
            shapeNode.zPosition = -5
            shapeNode.fillColor = SKColor.yellowColor()
            shapeNode.strokeColor = SKColor.blueColor()
            self.addChild(shapeNode)
        }
        
        sceneCam = SKCameraNode() //initialize your camera
        sceneCam.position = CGPoint(x: size.width/2, y: size.height/2)
        self.camera = sceneCam  //set the scene's camera
        addChild(sceneCam) //add camera to scene
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("need to get out of instruction scene")
        //(scene as! GameLevelScene).gameAppDelegate!.changeView(AppState.gameActionPaused)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        
        let positionInScene = touch!.locationInNode(self)
        let previousPosition = touch!.previousLocationInNode(self)
        let translation = CGPoint(x: 0, y: positionInScene.y - previousPosition.y)
        
        var newYPosition = sceneCam.position.y - translation.y
        //QQQQ adjust these constants and any others...
        
        //upper bound for scrolling up
        if newYPosition > 750{
            newYPosition = 750
        }
        
        //lower bound for scrolling down
        if newYPosition < -800{
            newYPosition = -800
        }
        
        sceneCam.position = CGPoint(x: sceneCam.position.x , y: newYPosition)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
