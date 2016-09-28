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
    
    
    override func didMove(to view: SKView) {
        setLowBackgroundMusicVolume()
        
        self.backgroundColor = SKColor.black
        
        sceneCam = SKCameraNode() //initialize your camera
        sceneCam.position = CGPoint(x: size.width/2, y: size.height/2)
        self.camera = sceneCam  //set the scene's camera
        addChild(sceneCam) //add camera to scene
        
        //QQQQ synch this code with the code in GameLevelScene
        let buttonSize = 80.0
        let buttonSpacing = 20.0
        
        let menuButtonSize = 45.0
        let menuButtonSpacing = 15.0
        
        let margin = (screenWidth - 3*buttonSize - 2*buttonSpacing)/2
        let auidoXOffset = 0 - menuButtonSpacing - menuButtonSize
        let helpXOffset = 0
        let settingsXOffset = -1*(auidoXOffset)
     
        let menuWidth = 3*menuButtonSize+4*menuButtonSpacing
        let menuHeight = menuButtonSize + 2*menuButtonSpacing
        
        var currentY = Double(self.size.height) - 2*menuButtonSpacing - menuButtonSize/2
        
        let menuNode = SKSpriteNode(imageNamed: "popup")
        //menuNode.colorBlendFactor = 0.8
        //menuNode.color = SKColor.redColor()
        menuNode.size = CGSize(width: menuWidth, height: menuHeight)
        menuNode.position = CGPoint(x: Double(self.size.width/2), y: currentY)
        menuNode.zPosition = GameLevelZPositions.popUpMenuZ
        self.addChild(menuNode)

        let audioButtonNode: AudioButtonNode
        if gameAppDelegate!.isMuted(){
            audioButtonNode = AudioButtonNode(imageNamed: "audio")
        }else{
            audioButtonNode = AudioButtonNode(imageNamed: "audioOff")
        }

        audioButtonNode.isUserInteractionEnabled = true
        audioButtonNode.name = "audioButton"
        audioButtonNode.size = CGSize(width:menuButtonSize, height: menuButtonSize)
        audioButtonNode.position = CGPoint(x:auidoXOffset, y:0)

        //QQQ Not sure need to set this z position
        audioButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        menuNode.addChild(audioButtonNode)

        let helpButtonNode = HelpButtonNode(imageNamed: "help")
        helpButtonNode.isUserInteractionEnabled = true
        helpButtonNode.name = "helpButton"
        helpButtonNode.size = CGSize(width:menuButtonSize, height: menuButtonSize)
        helpButtonNode.position = CGPoint(x:helpXOffset, y:0)
        helpButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        menuNode.addChild(helpButtonNode)
        
        let settingsButtonNode = SettingsButtonNode(imageNamed: "settings")
        settingsButtonNode.isUserInteractionEnabled = true
        settingsButtonNode.name = "resetScoresButton"
        settingsButtonNode.size = CGSize(width:menuButtonSize, height: menuButtonSize)
        settingsButtonNode.position = CGPoint(x:settingsXOffset, y:0)
        settingsButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        menuNode.addChild(settingsButtonNode)

        currentY = currentY - menuButtonSize/2 - 2 * menuButtonSpacing - 20
        
        messageLabelNode = MessageNode(position: CGPoint(x: screenCenterPointX , y: currentY))
      //  messageLabelNode.position = CGPoint(x: screenCenterPointX - Double(messageLabelNode.size.width/2), y: currentY) //QQQQ /funky
        messageLabelNode.label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        messageLabelNode.displayMessage("Square Root Marbles")
        self.addChild(messageLabelNode)
        
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
            levelNumberNode.position = CGPoint(x: x + buttonSize/2, y: y)
            self.addChild(levelNumberNode)
            var lifesNode = LifesNode(position: CGPoint(x: x, y: y-32), diameter: 12.5)
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
            levelNumberNode.position = CGPoint(x: x + buttonSize/2, y: y)
            self.addChild(levelNumberNode)
            lifesNode = LifesNode(position: CGPoint(x: x, y: y-32), diameter: 12.5)
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
            }
            
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
            levelNumberNode.position = CGPoint(x: x + buttonSize/2, y: y)
            self.addChild(levelNumberNode)
            lifesNode = LifesNode(position: CGPoint(x: x, y: y-32), diameter: 12.5)
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
            }
        }
        
    }
    
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
    
    
    //////////////////////////////////////
    // Internal Classes of Menu Buttons //
    //////////////////////////////////////
    
    //QQQQ copied these from GameLevelScene - consoloidate!
    
    class HelpButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! MenuScene).gameAppDelegate!.setReturnAppState(AppState.menuScene)
            (scene as! MenuScene).gameAppDelegate!.changeView(AppState.instructionScene)
        }
    }
    class SettingsButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! MenuScene).gameAppDelegate!.changeView(AppState.settingsScene)
        }
    }
    class AudioButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! MenuScene).gameAppDelegate!.toggleMute()
            if (scene as! MenuScene).gameAppDelegate!.isMuted(){
                self.texture = SKTexture(imageNamed: "audio")
                (scene as! MenuScene).messageLabelNode.displayFadingMessage("Audio Off", duration: 2.0)
                (scene as! MenuScene).stopBackgroundMusic()
            }else{
                self.texture = SKTexture(imageNamed: "audioOff")
                (scene as! MenuScene).messageLabelNode.displayFadingMessage("Audio On", duration: 2.0)
                (scene as! MenuScene).playBackgroundMusic()
            }
        }
    }    
}
