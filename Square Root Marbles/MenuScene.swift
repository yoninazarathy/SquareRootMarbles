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
    
    var messageLabelNode: MessageNode! = nil
    
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        
        sceneCam = SKCameraNode() //initialize your camera
        sceneCam.position = CGPoint(x: size.width/2, y: size.height/2)
        self.camera = sceneCam  //set the scene's camera
        addChild(sceneCam) //add camera to scene
        
        //QQQQ synch this code with the code in GameLevelScene
        let buttonSize = 45.0
        let buttonSpacing = 15.0
        let auidoXOffset = 0 - buttonSpacing - buttonSize
        let helpXOffset = 0
        let settingsXOffset = -1*(auidoXOffset)
     
        let menuWidth = 3*buttonSize+4*buttonSpacing
        let menuHeight = buttonSize + 2*buttonSpacing
        
        var currentY = Double(self.size.height) - 2*buttonSpacing - buttonSize/2
        
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
        audioButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
        audioButtonNode.position = CGPoint(x:auidoXOffset, y:0)

        //QQQ Not sure need to set this z position
        audioButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        menuNode.addChild(audioButtonNode)

        let helpButtonNode = HelpButtonNode(imageNamed: "help")
        helpButtonNode.isUserInteractionEnabled = true
        helpButtonNode.name = "helpButton"
        helpButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
        helpButtonNode.position = CGPoint(x:helpXOffset, y:0)
        helpButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        menuNode.addChild(helpButtonNode)
        
        let settingsButtonNode = SettingsButtonNode(imageNamed: "settings")
        settingsButtonNode.isUserInteractionEnabled = true
        settingsButtonNode.name = "resetScoresButton"
        settingsButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
        settingsButtonNode.position = CGPoint(x:settingsXOffset, y:0)
        settingsButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        menuNode.addChild(settingsButtonNode)

        currentY = currentY - buttonSize/2 - 2 * buttonSpacing - 20
        
        messageLabelNode = MessageNode(position: CGPoint(x: Double(self.size.width/2), y: currentY))
        messageLabelNode.displayMessage("Square Root Marbles")
        self.addChild(messageLabelNode)

        let xLabelFix = 8.0 //QQQQ note sure why we need this
        
        selectionNodes.append(nil)
        for i in stride(from: 1, to: numLevels, by: 3) {
            let y = currentY-60-40*(Double(i)-1)
            
            var x = Double(screenWidth)/5
            var lev = i
            var levelScore = "\(gameAppDelegate!.getGameLevelModel(lev).numMarbles)"
            //var levelOpen = (lev == 1  || gameAppDelegate!.getGameLevelModel(lev-1).bestScoreString != "" || allowAllLevels)
            var levelOpen = (lev == 1  || gameAppDelegate!.getGameLevelModel(lev).numMarbles > 0 || allowAllLevels)
            var levelNumberNode = SKLabelNode(text: "\(lev)")
            levelNumberNode.zPosition = 5
            levelNumberNode.fontColor = SKColor.black
            levelNumberNode.fontSize = 55
            levelNumberNode.fontName = "AmericanTypewriter-Bold"
            levelNumberNode.position = CGPoint(x: x+xLabelFix, y: y)
            self.addChild(levelNumberNode)
            var levelScoreNode = SKLabelNode(text: levelScore)
            levelScoreNode.zPosition = 5
            levelScoreNode.fontColor = SKColor.black
            levelScoreNode.fontSize = 18
            levelScoreNode.fontName = "AmericanTypewriter-Bold"
            levelScoreNode.position = CGPoint(x: x+xLabelFix, y: y-25)
            self.addChild(levelScoreNode)
            var shapeNode = SKShapeNode()
            shapeNode.path = UIBezierPath(roundedRect: CGRect(x: x-30, y:y-30, width: iconSize, height: iconSize),cornerRadius: 8).cgPath
            shapeNode.zPosition = -5
            shapeNode.fillColor = (levelOpen ? SKColor.lightGray : SKColor.darkGray)
            shapeNode.strokeColor = SKColor.white
            self.addChild(shapeNode)
            if levelOpen{
                selectionNodes.append(shapeNode)
            }
            //QQQQ maybe be "buggy" if somehow levels open are not consecutive??? check/think
            
            
            x = Double(screenWidth)/2
            lev = lev + 1
            levelScore = "\(gameAppDelegate!.getGameLevelModel(lev).numMarbles)"
            levelOpen = (lev == 1  || gameAppDelegate!.getGameLevelModel(lev).numMarbles > 0 || allowAllLevels)
            levelNumberNode = SKLabelNode(text: "\(lev)")
            levelNumberNode.zPosition = 5
            levelNumberNode.fontColor = SKColor.black
            levelNumberNode.fontSize = 55
            levelNumberNode.fontName = "AmericanTypewriter-Bold"
            levelNumberNode.position = CGPoint(x: x+xLabelFix, y: y)
            self.addChild(levelNumberNode)
            levelScoreNode = SKLabelNode(text: levelScore)
            levelScoreNode.zPosition = 5
            levelScoreNode.fontColor = SKColor.black
            levelScoreNode.fontSize = 18
            levelScoreNode.fontName = "AmericanTypewriter-Bold"
            levelScoreNode.position = CGPoint(x: x+xLabelFix, y: y-25)
            self.addChild(levelScoreNode)
            shapeNode = SKShapeNode()
            shapeNode.path = UIBezierPath(roundedRect: CGRect(x: x-30, y:y-30, width: iconSize, height: iconSize),cornerRadius: 8).cgPath
            shapeNode.zPosition = -5
            shapeNode.fillColor = (levelOpen ? SKColor.lightGray : SKColor.darkGray)
            shapeNode.strokeColor = SKColor.white
            self.addChild(shapeNode)
            if levelOpen{
                selectionNodes.append(shapeNode)
            }
            
            x = (4*Double(screenWidth))/5
            lev = lev + 1
            levelScore = "\(gameAppDelegate!.getGameLevelModel(lev).numMarbles)"
            levelOpen = (lev == 1  || gameAppDelegate!.getGameLevelModel(lev).numMarbles > 0 || allowAllLevels)
            levelNumberNode = SKLabelNode(text: "\(lev)")
            levelNumberNode.zPosition = 5
            levelNumberNode.fontColor = SKColor.black
            levelNumberNode.fontSize = 55
            levelNumberNode.fontName = "AmericanTypewriter-Bold"
            levelNumberNode.position = CGPoint(x: x+xLabelFix, y: y)
            levelScoreNode = SKLabelNode(text: levelScore)
            levelScoreNode.zPosition = 5
            levelScoreNode.fontColor = SKColor.black
            levelScoreNode.fontSize = 18
            levelScoreNode.fontName = "AmericanTypewriter-Bold"
            levelScoreNode.position = CGPoint(x: x+xLabelFix, y: y-25)
            self.addChild(levelScoreNode)
            self.addChild(levelNumberNode)
            shapeNode = SKShapeNode()
            shapeNode.path = UIBezierPath(roundedRect: CGRect(x: x-30, y:y-30, width: iconSize, height: iconSize),cornerRadius: 8).cgPath
            shapeNode.zPosition = -5
            shapeNode.fillColor = (levelOpen ? SKColor.lightGray : SKColor.darkGray)
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
                    gameAppDelegate!.setNumberOfMarblesX(3) //QQQQ read from level start
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
            }else{
                self.texture = SKTexture(imageNamed: "audioOff")
                (scene as! MenuScene).messageLabelNode.displayFadingMessage("Audio On", duration: 2.0)
            }
        }
    }    
}
