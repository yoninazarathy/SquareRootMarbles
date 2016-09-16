//
//  GameLevelScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit

struct PhysicsCategory{
    static let  None        :   UInt32 = 0
    static let  All         :   UInt32 = UInt32.max
    static let  Player       :   UInt32 = 0b1
    static let  Operator    :   UInt32 = 0b10
    static let  Obstacle    :   UInt32 = 0b100
    static let  Sink        :   UInt32 = 0b1000
    static let  Background  :   UInt32 = 0b10000
}


struct GameLevelZPositions{
    static let obstacleZ = CGFloat(-20.0)
    static let sinkZ = CGFloat(-5.0)
    static let playerZ = CGFloat(0.0)
    static let operatorZ = CGFloat(5.0)
    static let popUpMenuZ = CGFloat(10.0)
    static let popUpMenuButtonsZ = CGFloat(20.0)
}

class GameLevelScene: GeneralScene, SKPhysicsContactDelegate {
    var gameLevelModel: GameLevelModel? = nil
    var obstacleMap = Dictionary<SquareCoordinates,SKShapeNode>()
    var playerNode: PlayerNode! = nil
    var operatorNodes: [OperatorNode!] = Array(count: upperBoundNumOperators, repeatedValue: nil)
    var sinkNode: SinkNode! = nil
    //QQQQ implement this
    var sinkSpring: SKPhysicsJointSpring! = nil
    var timePlayed: Int = 0
    var playing: Bool = true
    var popUpNode: SKSpriteNode? = nil
    var inEditMode: Bool  = false
    var lastSquareCoordsMove: SquareCoordinates? = nil

    
    //////////////////
    // Game Control //
    //////////////////
    
    func haultAction(){
        //pause phsyics
        physicsWorld.speed = 0.0
        
        //pause core motion
        motionManager.stopDeviceMotionUpdates()
    }
    
    func startAction(){
        //put physics world in normal playing mode
        physicsWorld.speed = 1.0
        
        //QQQQ not sure if this should be here or elsewhere
        //QQQQ not sure these four lines of code do anything. Maybe remove (or modify)
        let sceneBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        sceneBody.friction = 1000
        sceneBody.categoryBitMask = PhysicsCategory.Background
        sceneBody.contactTestBitMask = PhysicsCategory.Player
        self.physicsBody = sceneBody
        
        motionManager.startDeviceMotionUpdates()
        motionManager.deviceMotionUpdateInterval = 0.03
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue() ) {
            (data, error) in
            //QQQQ adjust and organize these constants
            self.physicsWorld.gravity = CGVectorMake(10 * CGFloat(sin(2*data!.attitude.roll)),-10 * CGFloat(sin(2*data!.attitude.pitch)))
            self.playerNode.physicsBody!.applyForce(CGVectorMake(CGFloat(data!.userAcceleration.x*600), CGFloat(data!.userAcceleration.y*600)))
            if let error = error { // Might as well handle the optional error as well
                print(error.localizedDescription)
                return
            }
        }
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(increaseTime), userInfo: nil, repeats: true)
    }
    
    func pauseGame(){
        playing = false
        displayPopUp()
        
        
        //pause time
        //QQQQ implement
        
        haultAction()
    }
    
    func resetGame(){
        //QQQQ implement this (or not???)
    }
    
    func playGame(){
        playing = true
        
        startAction()
        
        if let popUp = popUpNode{
            popUp.removeFromParent()
        }
        
    }
    
    func increaseTime(){
        //        timePlayed = timePlayed + 1
        //        sinkNodeText.text = String(timePlayed)
    }

    //////////////////////////
    // Finalization of Game //
    //////////////////////////
    
    
    func finalizeSceneWithSuccess(){
        self.runAction(SKAction.playSoundFileNamed("chinese-gong-daniel_simon.wav",waitForCompletion:false))
        haultAction()
        //QQQQ update score here
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(moveToMenuScene), userInfo: nil, repeats: false)
    }
    
    func finalizeSceneWithFailure(){
        self.runAction(SKAction.playSoundFileNamed("smashing.wav",waitForCompletion:false))
        haultAction()
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(moveToMenuScene), userInfo: nil, repeats: false)
    }
    
    func finalizeSceneWithAbort(){
        gameAppDelegate!.changeView(AppState.menuScene)
    }

    func moveToMenuScene(){
        gameAppDelegate!.changeView(AppState.menuScene)

    }
    
    ///////////////////
    // Initilization //
    ///////////////////
    
    func createObstacleNode(coords: SquareCoordinates){
        let rect = coords.rect()
        let node = SKShapeNode(rect: rect)
        node.name = "obstacleNode"
        node.fillColor = SKColor.whiteColor()
        node.strokeColor = SKColor.redColor()
        node.lineWidth = 0
        node.physicsBody = SKPhysicsBody(edgeLoopFromRect: rect)
        node.physicsBody!.dynamic = false
        node.physicsBody!.categoryBitMask = PhysicsCategory.Obstacle
        node.physicsBody!.collisionBitMask = PhysicsCategory.Player
        node.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        obstacleMap[coords] = node
        self.addChild(node)
    }
    
    func createSinkNode(){
        sinkNode = SinkNode(target:  goalOfLevel(gameAppDelegate!.getLevel()))
        sinkNode.position = gameLevelModel!.designInfo.sinkLocation
        sinkNode.name = "sinkNode"
        sinkNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 40, height: 40))
        sinkNode.physicsBody!.dynamic = false
        sinkNode.physicsBody!.categoryBitMask = PhysicsCategory.Sink
        sinkNode.physicsBody!.collisionBitMask = PhysicsCategory.None
        sinkNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        self.addChild(sinkNode)
    }
    
    func createOperatorNodes(){
        //QQQQ how to better work with this array?
        for i in 0..<gameLevelModel!.designInfo.numOperators{
            operatorNodes[i] = OperatorNode(operatorActionString: gameLevelModel!.designInfo.operatorTypes[i])
            let node = operatorNodes[i]
            node.position = gameLevelModel!.designInfo.operatorLocations[i]
            node.zPosition = GameLevelZPositions.operatorZ
            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.dynamic = false
            node.physicsBody?.categoryBitMask = PhysicsCategory.Operator
            node.physicsBody?.collisionBitMask = PhysicsCategory.None
            node.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            self.addChild(node)
        }
    }
    
    func createPlayerNode(){
        playerNode = PlayerNode(initValue: gameAppDelegate!.getLevel())
        //playerNode.anchorPoint = CGPoint(x: 0.5, y:0.5)
        playerNode.position = gameLevelModel!.designInfo.startLocation
        playerNode.zPosition = GameLevelZPositions.playerZ
        playerNode.name = "playerNode"
        playerNode.physicsBody = SKPhysicsBody(rectangleOfSize: playerNode.size)
        playerNode.physicsBody!.friction =  0.4 //QQQQ config
        playerNode.physicsBody?.affectedByGravity = true
        playerNode.physicsBody?.dynamic = true
        playerNode.physicsBody?.categoryBitMask = PhysicsCategory.Player
        playerNode.physicsBody?.collisionBitMask = PhysicsCategory.Obstacle | PhysicsCategory.Background
        playerNode.physicsBody?.contactTestBitMask = PhysicsCategory.All
        self.addChild(playerNode)
    }

    override func didMoveToView(view: SKView) {
        
        physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor.blackColor()

        //QQQQ read the level from the controller or so....
        gameLevelModel = GameLevelModel(level: gameAppDelegate!.getLevel())
        
        
        for (coords,_) in gameLevelModel!.designInfo.obstacleMap{
            createObstacleNode(coords)
        }
        createSinkNode()
        createOperatorNodes()
        createPlayerNode()
        updateOperatorsAndSinkStatus()
        
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.numberOfTapsRequired = 2
        self.view?.addGestureRecognizer(tap)
        
        resetGame()
        playGame()
        
    }
    
    ///////////////////////
    // Game Play Actions //
    ///////////////////////
    
    
    func updateOperatorsAndSinkStatus(){
        for i in 0..<gameLevelModel!.designInfo.numOperators{
            let node = operatorNodes[i]
            if node.operatorAction!.isValid(playerNode.value){
                node.setAsValid()
            }else{
                node.setAsInvalid()
            }
        }
        if playerNode.value == sinkNode.targetValue{
            sinkNode.setAsValid()
        }else{
            sinkNode.setAsInvalid()
        }
    }

    func didBeginContact(contact: SKPhysicsContact) {
        var actionNode: SKNode?
        if contact.bodyA.node!.name! == "playerNode"{
            actionNode = contact.bodyB.node
        } else{
            actionNode = contact.bodyA.node
        }
        
        switch(actionNode!.name!){
        case "obstacleNode":
            if contact.collisionImpulse > 2{//QQQQ make this 2 a constant
                //QQQQ handle muting globally
                if gameAppDelegate?.isMuted() == false{
                    self.runAction(SKAction.playSoundFileNamed("hitMetal.wav",waitForCompletion:false))
                }
            }
        case "sinkNode":
            if playerNode.value == sinkNode.targetValue{
                finalizeSceneWithSuccess()
            }else{
                finalizeSceneWithFailure()
            }
        default:
            handleOperatorPass(actionNode as! OperatorNode)
        }
    }
    
    func handleOperatorPass(operatorNode: OperatorNode){
        if operatorNode.valid!{
            self.runAction(SKAction.playSoundFileNamed("sms-alert-1-daniel_simon.wav",waitForCompletion:false))
            let newValue = operatorNode.operatorAction.operate(playerNode.value)
            playerNode.changeValue(newValue)
            updateOperatorsAndSinkStatus()
        }
        else{
            finalizeSceneWithFailure()
        }
    }


    /////////////////
    // Pause PopUp //
    /////////////////
    
    func displayPopUp(){
        
        //QQQQ Make this whole thing a class
        
        popUpNode = SKSpriteNode(imageNamed: "backTest")
        popUpNode!.colorBlendFactor = 0.8
        popUpNode!.color = SKColor.redColor()
        popUpNode!.size = CGSize(width: 260, height: 65)
        popUpNode!.position = CGPoint(x:80, y:630)
        popUpNode!.anchorPoint = CGPoint(x:0,y:0)
        //QQQQ Update Z positions of other items
        popUpNode!.zPosition = GameLevelZPositions.popUpMenuZ
        self.addChild(popUpNode!)
        
        //QQQQ put consistant graphic anems
        
        if editModeEnabled{
            let editButtonNode = EditButtonNode(imageNamed: "edit-button")
            editButtonNode.userInteractionEnabled = true
            editButtonNode.name = "editButton"
            editButtonNode.size = CGSize(width:40, height: 40)
            editButtonNode.position = CGPoint(x:30, y:35)
            editButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
            popUpNode!.addChild(editButtonNode)
        }
        
        let audioButtonNode: AudioButtonNode
        if gameAppDelegate!.isMuted(){
            audioButtonNode = AudioButtonNode(imageNamed: "audio")
        }else{
            audioButtonNode = AudioButtonNode(imageNamed: "audioOff")
        }
        
        audioButtonNode.userInteractionEnabled = true
        audioButtonNode.name = "audioButton"
        audioButtonNode.size = CGSize(width:40, height: 40)
        audioButtonNode.position = CGPoint(x:80, y:40)
        //QQQ Not sure need to set this z position
        audioButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        popUpNode!.addChild(audioButtonNode)
        
        let stopButtonNode = StopButtonNode(imageNamed: "cross-button")
        stopButtonNode.userInteractionEnabled = true
        stopButtonNode.name = "stopButton"
        stopButtonNode.size = CGSize(width:40, height: 40)
        stopButtonNode.position = CGPoint(x:130, y:35)
        stopButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        popUpNode!.addChild(stopButtonNode)
        
        let helpButtonNode = HelpButtonNode(imageNamed: "help")
        helpButtonNode.userInteractionEnabled = true
        helpButtonNode.name = "helpButton"
        helpButtonNode.size = CGSize(width:40, height: 40)
        helpButtonNode.position = CGPoint(x:180, y:35)
        helpButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        popUpNode!.addChild(helpButtonNode)
        
        let playButtonNode = PlayButtonNode(imageNamed: "play")
        playButtonNode.userInteractionEnabled = true
        playButtonNode.name = "playButton"
        playButtonNode.size = CGSize(width:40, height: 40)
        playButtonNode.position = CGPoint(x:230, y:35)
        playButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        popUpNode!.addChild(playButtonNode)
    }

    //////////////
    // Gestures //
    //////////////
    
    func handleTap(sender:UITapGestureRecognizer){
        
        if sender.state == .Ended {
            var touchLocation: CGPoint = sender.locationInView(sender.view)
            touchLocation = self.convertPointFromView(touchLocation)
            if editModeEnabled{
                removeObstacleIfThere(squareOfPoint(Double(touchLocation.x), y: Double(touchLocation.y)))
            }
        }
    }

    //////////////////
    // Game Editing //
    //////////////////
    
    
    func removeObstacleIfThere(squareCoords: SquareCoordinates){
        if let node = obstacleMap[squareCoords]{
            node.removeFromParent()
            gameLevelModel!.designInfo.obstacleMap.removeValueForKey(squareCoords)
            obstacleMap[squareCoords] = nil
        }
    }
    
    func addObstacleIfNotThere(squareCoords: SquareCoordinates){
        let node = obstacleMap[squareCoords]
        if node == nil{
            createObstacleNode(squareCoords)
            gameLevelModel!.designInfo.obstacleMap[squareCoords] = ObstacleType.genericObstacle
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !inEditMode{ return }
        
        ///////////////////////////
        // EDIT MODE MOVE EVENTS //
        ///////////////////////////

        let touch = touches.first!

        let positionInScene = touch.locationInNode(self)
        

        for i in 0..<gameLevelModel!.designInfo.numOperators{
            if operatorNodes[i].containsPoint(positionInScene){
                operatorNodes[i].position = positionInScene
                gameLevelModel!.designInfo.operatorLocations[i] = positionInScene
                return
            }
        }
        
        if sinkNode.containsPoint(positionInScene){
            sinkNode.position = positionInScene
            gameLevelModel!.designInfo.sinkLocation = positionInScene
            return
        }
        
        if playerNode.containsPoint(positionInScene){
            playerNode.position = positionInScene
            gameLevelModel!.designInfo.startLocation = positionInScene
            return
        }
        
        
        let squareCoords = squareOfPoint(Double(positionInScene.x), y: Double(positionInScene.y))
        //QQQQ learn how to improve this if
        if lastSquareCoordsMove != nil{
            if squareCoords != lastSquareCoordsMove!{
                addObstacleIfNotThere(squareCoords)
            }
        }
        lastSquareCoordsMove = squareCoords
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if playing{
            pauseGame()
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
    //////////////////////////////////////
    // Internal Classes of Menu Buttons //
    //////////////////////////////////////
    
    class HelpButtonNode : SKSpriteNode{
        override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
            (scene as! GameLevelScene).gameAppDelegate!.changeView(AppState.instructionScene)
        }
    }
    class PlayButtonNode : SKSpriteNode{
        override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
            (scene as! GameLevelScene).playGame()
        }
    }
    class StopButtonNode : SKSpriteNode{
        override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
            (scene as! GameLevelScene).finalizeSceneWithAbort()
        }
    }
    class AudioButtonNode : SKSpriteNode{
        override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
            (scene as! GameLevelScene).gameAppDelegate!.toggleMute()
            if (scene as! GameLevelScene).gameAppDelegate!.isMuted(){
                self.texture = SKTexture(imageNamed: "audio")
            }else{
                self.texture = SKTexture(imageNamed: "audioOff")
            }
        }
    }
    class EditButtonNode : SKSpriteNode{
        override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
            if (scene as! GameLevelScene).inEditMode == false{
                (scene as! GameLevelScene).inEditMode = true
                self.texture = SKTexture(imageNamed: "editOff")
            }
            else{
                (scene as! GameLevelScene).inEditMode = false
                self.texture = SKTexture(imageNamed: "edit-button")
                
                //QQQQ Change this so that the writing isn't in here and also to one file
                
                /////////////////////////////
                // Write obstacles to file //
                /////////////////////////////
                
                var tempObstacleStringDict = Dictionary<String,String>()
                for (coords,obs) in (scene as! GameLevelScene).gameLevelModel!.designInfo.obstacleMap{
                    tempObstacleStringDict["(\(coords.values.sx),\(coords.values.sy))"] = "\(obs)"
                }
                let outputObstacleDict = tempObstacleStringDict as NSDictionary
                let obstacleFilePath = NSHomeDirectory() + "/Library/obstacles\((scene as! GameLevelScene).gameLevelModel!.levelNumber).plist"
                outputObstacleDict.writeToFile(obstacleFilePath, atomically: true)
                print("Wrote to \(obstacleFilePath)")
                
                /////////////////////////////
                // Write operators to file //
                /////////////////////////////
                
                var tempOperatorStringDict = Dictionary<String,String>()
                for i in 0..<(scene as! GameLevelScene).gameLevelModel!.designInfo.numOperators{
                    let location = (scene as! GameLevelScene).gameLevelModel!.designInfo.operatorLocations[i]
                    tempOperatorStringDict["\(i)"] = "(\(location.x),\(location.y))"
                }
                
                let outputOperatorDict = tempOperatorStringDict as NSDictionary
                let operatorFilePath = NSHomeDirectory() + "/Library/operators\((scene as! GameLevelScene).gameLevelModel!.levelNumber).plist"
                outputOperatorDict.writeToFile(operatorFilePath, atomically: true)
                print("Wrote to \(operatorFilePath)")
                
                ////////////////////////////////
                // Write startAndSink to file //
                ////////////////////////////////
                
                var tempStartAndSinkStringDict = Dictionary<String,String>()
                let sinkLocation = (scene as! GameLevelScene).gameLevelModel!.designInfo.sinkLocation
                let startLocation = (scene as! GameLevelScene).gameLevelModel!.designInfo.startLocation
                tempStartAndSinkStringDict["0"] = "(\(startLocation.x),\(startLocation.y))"     //currently "0" is start "1" is sink
                tempStartAndSinkStringDict["1"] = "(\(sinkLocation.x),\(sinkLocation.y))"
                
                let outputStartAndSinkDict = tempStartAndSinkStringDict as NSDictionary
                let startAndSinkFilePath = NSHomeDirectory() + "/Library/startAndSink\((scene as! GameLevelScene).gameLevelModel!.levelNumber).plist"
                outputStartAndSinkDict.writeToFile(startAndSinkFilePath, atomically: true)
                print("Wrote to \(startAndSinkFilePath)")

            }
        }
    }
}//end of class
