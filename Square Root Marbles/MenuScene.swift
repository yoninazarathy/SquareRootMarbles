//
//  MenuScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit

class LevelIconNode: SKShapeNode{
    
}

let iconSize = 77.0
let levelLabelSize = 50

class MenuScene: GeneralScene {
        
    var selectionNodes = [SKShapeNode?]()
    
    var sceneCam: SKCameraNode!
    
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor.blackColor()
        
        //QQQQ How do I initilize an array member?
        
        selectionNodes.append(nil)
        for i in 1.stride(to: numLevels, by: 3) {
            let y = 1200-40*(Double(i)-1)

            var x = Double(screenWidth)/5
            var lev = i
            var levelScore = gameAppDelegate!.getGameLevelModel(lev).bestScoreString
            var levelOpen = (lev == 1  || gameAppDelegate!.getGameLevelModel(lev-1).bestScoreString != "")
            var levelNumberNode = SKLabelNode(text: "\(lev)")
            levelNumberNode.zPosition = 5
            levelNumberNode.fontColor = SKColor.blackColor()
            levelNumberNode.fontSize = 60
            levelNumberNode.fontName = "AmericanTypewriter-Bold"
            levelNumberNode.position = CGPoint(x: x, y: y)
            self.addChild(levelNumberNode)
            var levelScoreNode = SKLabelNode(text: levelScore)
            levelScoreNode.zPosition = 5
            levelScoreNode.fontColor = SKColor.blackColor()
            levelScoreNode.fontSize = 18
            levelScoreNode.fontName = "AmericanTypewriter-Bold"
            levelScoreNode.position = CGPoint(x: x, y: y-25)
            self.addChild(levelScoreNode)
            var shapeNode = SKShapeNode(rect: CGRect(x: x-30, y:y-30, width: iconSize, height: iconSize))
            shapeNode.zPosition = -5
            shapeNode.fillColor = (levelOpen ? SKColor.lightGrayColor() : SKColor.darkGrayColor())
            shapeNode.strokeColor = SKColor.whiteColor()
            self.addChild(shapeNode)
            if levelOpen{
                selectionNodes.append(shapeNode)
            }
            //QQQQ maybe be "buggy" if somehow levels open are not consecutive??? check/think


            x = Double(screenWidth)/2
            lev = lev + 1
            levelScore = gameAppDelegate!.getGameLevelModel(lev).bestScoreString
            levelOpen = (lev == 1  || gameAppDelegate!.getGameLevelModel(lev-1).bestScoreString != "")
            levelNumberNode = SKLabelNode(text: "\(lev)")
            levelNumberNode.zPosition = 5
            levelNumberNode.fontColor = SKColor.blackColor()
            levelNumberNode.fontSize = 60
            levelNumberNode.fontName = "AmericanTypewriter-Bold"
            levelNumberNode.position = CGPoint(x: x, y: y)
            self.addChild(levelNumberNode)
            levelScoreNode = SKLabelNode(text: levelScore)
            levelScoreNode.zPosition = 5
            levelScoreNode.fontColor = SKColor.blackColor()
            levelScoreNode.fontSize = 18
            levelScoreNode.fontName = "AmericanTypewriter-Bold"
            levelScoreNode.position = CGPoint(x: x, y: y-25)
            self.addChild(levelScoreNode)
            shapeNode = SKShapeNode(rect: CGRect(x: x-30, y:y-30, width: iconSize, height: iconSize))
            shapeNode.zPosition = -5
            shapeNode.fillColor = (levelOpen ? SKColor.lightGrayColor() : SKColor.darkGrayColor())
            shapeNode.strokeColor = SKColor.whiteColor()
            self.addChild(shapeNode)
            if levelOpen{
                selectionNodes.append(shapeNode)
            }
            
            x = (4*Double(screenWidth))/5
            lev = lev + 1
            levelScore = gameAppDelegate!.getGameLevelModel(lev).bestScoreString
            levelOpen = (lev == 1  || gameAppDelegate!.getGameLevelModel(lev-1).bestScoreString != "")
            levelNumberNode = SKLabelNode(text: "\(lev)")
            levelNumberNode.zPosition = 5
            levelNumberNode.fontColor = SKColor.blackColor()
            levelNumberNode.fontSize = 60
            levelNumberNode.fontName = "AmericanTypewriter-Bold"
            levelNumberNode.position = CGPoint(x: x, y: y)
            levelScoreNode = SKLabelNode(text: levelScore)
            levelScoreNode.zPosition = 5
            levelScoreNode.fontColor = SKColor.blackColor()
            levelScoreNode.fontSize = 18
            levelScoreNode.fontName = "AmericanTypewriter-Bold"
            levelScoreNode.position = CGPoint(x: x, y: y-25)
            self.addChild(levelScoreNode)
            self.addChild(levelNumberNode)
            shapeNode = SKShapeNode(rect: CGRect(x: x-30, y:y-30, width: iconSize, height: iconSize))
            shapeNode.zPosition = -5
            shapeNode.fillColor = (levelOpen ? SKColor.lightGrayColor() : SKColor.darkGrayColor())
            shapeNode.strokeColor = SKColor.whiteColor()
            self.addChild(shapeNode)
            if levelOpen{
                selectionNodes.append(shapeNode)
            }
        }
        
        sceneCam = SKCameraNode() //initialize your camera
        sceneCam.position = CGPoint(x: size.width/2, y: size.height/2)
        self.camera = sceneCam  //set the scene's camera
        addChild(sceneCam) //add camera to scene
        
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if dragging{
            dragging = false
            return
        }
        let touch = touches.first!
        for i in 1...numLevels{
            if let node = selectionNodes[i] {
                if node.containsPoint(touch.locationInNode(self)){
                    gameAppDelegate!.setLevel(i)
                    gameAppDelegate!.changeView(AppState.gameActionPlaying)
                    return
                }
            }
        }
    }
    
    var dragging = false
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dragging = true
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
        if newYPosition < 0{
            newYPosition = 0
        }
        
        sceneCam.position = CGPoint(x: sceneCam.position.x , y: newYPosition)
    }

    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
