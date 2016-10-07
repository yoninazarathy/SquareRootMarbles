//
//  MenuScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit


class MenuScene: GeneralScene {
        
    var selectionNodes = [SKShapeNode?]()
    
    var sceneCam: SKCameraNode!
    
    var messageLabelNode: MessageNode! = nil
    
    var camVertTranlation: Double = 0.0
    var scenePatchAdd: Double = 0.0
    
    override func didMove(to view: SKView) {
        setLowBackgroundMusicVolume()
        
        self.backgroundColor = SKColor.black
        
        sceneCam = SKCameraNode() //initialize your camera
        //sceneCam.xScale = CGFloat(screenWidth/actualScreenWidth)
        //sceneCam.yScale = CGFloat(screenHeight/actualScreenHeight)
        print("YYYY:\(view.frame.size) -- \(actualScreenWidth)--\(actualScreenHeight))")
        print("XXXXX: \(screenWidth/actualScreenWidth) -- \(screenHeight/actualScreenHeight)")
        if  (screenWidth/actualScreenWidth) > (screenHeight/actualScreenHeight){
            camVertTranlation = actualScreenHeight/2
        }else{
            camVertTranlation = screenHeight/2
        }
        
        //QQQQ nasty iPadAir patch
        if actualScreenWidth == 320 && actualScreenHeight == 480{
            scenePatchAdd = 40
        }

        sceneCam.position = CGPoint(x: size.width/2, y:CGFloat(1340 + scenePatchAdd - camVertTranlation))
        self.camera = sceneCam  //set the scene's camera
        addChild(sceneCam) //add camera to scene
        
        //QQQQ synch this code with the code in GameLevelScene
        let buttonSize = 80.0
        let buttonSpacing = 20.0
        
        let menuButtonSize = 45.0
        let menuButtonSpacing = 25.0
        
        let margin = (screenWidth - 3*buttonSize - 2*buttonSpacing)/2
     
    
        var currentY = Double(self.size.height) - 2*menuButtonSpacing - menuButtonSize/2
        
        let helpButtonNode = HelpButtonNode(imageNamed: "help")
        helpButtonNode.isUserInteractionEnabled = true
        helpButtonNode.name = "helpButton"
        helpButtonNode.size = CGSize(width:menuButtonSize, height: menuButtonSize)
        helpButtonNode.position = CGPoint(x:CGFloat(menuButtonSpacing + menuButtonSize/2), y:self.size.height - CGFloat(menuButtonSpacing + menuButtonSize/2))
        helpButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        self.addChild(helpButtonNode)
        
        let settingsButtonNode = SettingsButtonNode(imageNamed: "settings")
        settingsButtonNode.isUserInteractionEnabled = true
        settingsButtonNode.name = "resetScoresButton"
        settingsButtonNode.size = CGSize(width:menuButtonSize, height: menuButtonSize)
        settingsButtonNode.position = CGPoint(x:CGFloat(screenWidth-menuButtonSpacing - menuButtonSize/2), y:self.size.height - CGFloat(menuButtonSpacing + menuButtonSize/2))
        settingsButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        self.addChild(settingsButtonNode)

        let sqrtButtonNode = SquareRootButtonNode(imageNamed: "srm3Lines")
        sqrtButtonNode.isUserInteractionEnabled = true
        sqrtButtonNode.name = "sqrtButtonNode"
        sqrtButtonNode.colorBlendFactor = 0.8
        sqrtButtonNode.color = SKColor.green
        sqrtButtonNode.size = CGSize(width:145, height: 90)
        sqrtButtonNode.position = CGPoint(x:CGFloat(screenCenterPointX-20), y:self.size.height - CGFloat(80))
        sqrtButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        self.addChild(sqrtButtonNode)

        
        let lifesFixX = [0.0, -23.0, -14.0, -9.0, -4.0, 5.0,
                             5.0, 5.0, 5.0, 5.0, 5.0]

        let lifesFixY = [0.0, -6.0, -6.0, -6.0, -6.0, -6.0,
                         1.0, 1.0, 1.0, 1.0, 1.0]
        
        
        currentY = currentY - menuButtonSize/2 - 2 * menuButtonSpacing
        
        selectionNodes.append(nil)
        for i in stride(from: 1, to: numLevels, by: 3) {
            let y = currentY-60-40*(Double(i)-1)
            
            var x = margin
            var lev = i
            var numMarbles = gameAppDelegate!.getGameLevelModel(lev).numMarbles
            var levelOpen = (numMarbles > 0 || allowAllLevels)
            var levelNumberNode = SKLabelNode(text: "\(lev)")
            levelNumberNode.zPosition = 5
            levelNumberNode.fontColor = SKColor.black
            levelNumberNode.fontSize = 50
            levelNumberNode.fontName = "AmericanTypewriter-Bold"
            levelNumberNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
            levelNumberNode.position = CGPoint(x: x + buttonSize/2, y: y+5)
            self.addChild(levelNumberNode)
            var lifesNode = LifesNode(position: CGPoint(x: x + lifesFixX[numMarbles], y: y-28 + lifesFixY[numMarbles]), diameter: 14.0)
            lifesNode.numLifes = numMarbles
            lifesNode.refreshDisplay()
            self.addChild(lifesNode)
            var shapeNode = SKShapeNode()
            shapeNode.path = UIBezierPath(roundedRect: CGRect(x: x, y:y-30, width: buttonSize, height: buttonSize),cornerRadius: 8).cgPath
            shapeNode.zPosition = -5
            shapeNode.fillColor = (levelOpen ? SKColor.orange : SKColor.darkGray)
            shapeNode.strokeColor = SKColor.white
            self.addChild(shapeNode)
            if levelOpen{
                selectionNodes.append(shapeNode)
                shapeNode.strokeColor = SKColor.green
                shapeNode.lineWidth = 2.5
                levelNumberNode.fontColor = SKColor.green
            }else{
                shapeNode.lineWidth = 0.0
                levelNumberNode.fontColor = SKColor.lightGray
            }
            //QQQQ maybe be "buggy" if somehow levels open are not consecutive??? check/think
            
            
            x = x + buttonSize + buttonSpacing
            lev = lev + 1
            numMarbles = gameAppDelegate!.getGameLevelModel(lev).numMarbles
            levelOpen = (numMarbles > 0 || allowAllLevels)
            levelNumberNode = SKLabelNode(text: "\(lev)")
            levelNumberNode.zPosition = 5
            levelNumberNode.fontColor = SKColor.black
            levelNumberNode.fontSize = 50
            levelNumberNode.fontName = "AmericanTypewriter-Bold"
            levelNumberNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
            levelNumberNode.position = CGPoint(x: x + buttonSize/2, y: y+5)
            self.addChild(levelNumberNode)
            lifesNode = LifesNode(position: CGPoint(x: x + lifesFixX[numMarbles], y: y-28 + lifesFixY[numMarbles]), diameter: 14.0)
            lifesNode.numLifes = numMarbles
            lifesNode.refreshDisplay()
            self.addChild(lifesNode)
            shapeNode = SKShapeNode()
            shapeNode.path = UIBezierPath(roundedRect: CGRect(x: x, y:y-30, width: buttonSize, height: buttonSize),cornerRadius: 8).cgPath
            shapeNode.zPosition = -5
            shapeNode.fillColor = (levelOpen ? SKColor.orange : SKColor.darkGray)
            self.addChild(shapeNode)
            if levelOpen{
                selectionNodes.append(shapeNode)
                shapeNode.strokeColor = SKColor.green
                shapeNode.lineWidth = 2.5
                levelNumberNode.fontColor = SKColor.green
            }else{
                shapeNode.lineWidth = 0.0
                levelNumberNode.fontColor = SKColor.lightGray
            }
            
            x = x + buttonSize + buttonSpacing
            lev = lev + 1
            numMarbles = gameAppDelegate!.getGameLevelModel(lev).numMarbles
            levelOpen = (numMarbles > 0 || allowAllLevels)
            levelNumberNode = SKLabelNode(text: "\(lev)")
            levelNumberNode.zPosition = 5
            levelNumberNode.fontSize = 50
            levelNumberNode.fontName = "AmericanTypewriter-Bold"
            levelNumberNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
            levelNumberNode.position = CGPoint(x: x + buttonSize/2, y: y+5)
            self.addChild(levelNumberNode)
            lifesNode = LifesNode(position: CGPoint(x: x + lifesFixX[numMarbles], y: y-28 + lifesFixY[numMarbles]), diameter: 14.0)
            lifesNode.numLifes = numMarbles
            lifesNode.refreshDisplay()
            self.addChild(lifesNode)
            shapeNode = SKShapeNode()
            shapeNode.path = UIBezierPath(roundedRect: CGRect(x: x, y:y-30, width: buttonSize, height: buttonSize),cornerRadius: 8).cgPath
            shapeNode.zPosition = -5
            shapeNode.fillColor = (levelOpen ? SKColor.orange : SKColor.darkGray)
            shapeNode.strokeColor = SKColor.white
            self.addChild(shapeNode)
            if levelOpen{
                selectionNodes.append(shapeNode)
                shapeNode.strokeColor = SKColor.green
                shapeNode.lineWidth = 2.5
                levelNumberNode.fontColor = SKColor.green
            }else{
                shapeNode.lineWidth = 0.0
                levelNumberNode.fontColor = SKColor.lightGray
            }
        }
        
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first!
//        //print("LOCATION: \(touch.location(in: self))")
//    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dragging{
            dragging = false
            return
        }
        let touch = touches.first!
        for i in 1..<selectionNodes.count{
            if let node = selectionNodes[i] {
                if node.contains(touch.location(in: self)){
                    gameAppDelegate!.setLevel(i)
                    gameAppDelegate!.changeView(AppState.gameActionPlaying)
                    return
                }
            }
        }
    }
    
    var dragging = false
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        dragging = true
        let touch = touches.first
        
        let positionInScene = touch!.location(in: self)
        let previousPosition = touch!.previousLocation(in: self)
        let translation = CGPoint(x: 0, y: positionInScene.y - previousPosition.y)
        
        var newYPosition = sceneCam.position.y - translation.y
        //QQQQ adjust these constants and any others...
        
        //upper bound for scrolling up
        if newYPosition > CGFloat(1340 + scenePatchAdd - camVertTranlation){
            newYPosition = CGFloat(1340 + scenePatchAdd - camVertTranlation)
        }
        
        //lower bound for scrolling down
        if newYPosition < CGFloat(camVertTranlation - scenePatchAdd){
            newYPosition = CGFloat(camVertTranlation - scenePatchAdd)
        }
        
        sceneCam.position = CGPoint(x: sceneCam.position.x , y: newYPosition)
//        print("sceneCamPosition: \(sceneCam.pos)")
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
    //////////////////////////////////////
    // Internal Classes of Menu Buttons //
    //////////////////////////////////////
    
    //QQQQ copied these from GameLevelScene - consoloidate!
    
    class HelpButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! MenuScene).playButtonClick()
            (scene as! MenuScene).gameAppDelegate!.setReturnAppState(AppState.menuScene)
            (scene as! MenuScene).gameAppDelegate!.changeView(AppState.instructionScene)
        }
    }
    class SettingsButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! MenuScene).playButtonClick()
            (scene as! MenuScene).gameAppDelegate!.changeView(AppState.settingsScene)
        }
    }
    
    class SquareRootButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! MenuScene).playRandomSRM()
            removeAllActions()
            self.zRotation = 0.0
            let rotate1 = SKAction.rotate(byAngle: 0.15, duration: 0.2)
            let reverse1 = rotate1.reversed()
            let rotate2 = SKAction.rotate(byAngle: -0.15, duration: 0.2)
            let reverse2 = rotate2.reversed()
            let seq = SKAction.sequence([rotate1, reverse1, rotate2, reverse2,rotate1, reverse1, rotate2, reverse2])
            run(seq)
        }
    }

    
}
