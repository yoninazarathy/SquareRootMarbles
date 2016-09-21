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
    static let backZ = CGFloat(-100.0)
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
    var timeLabelNode: SKLabelNode! = nil
    var messageLabelNode: MessageNode! = nil

    //QQQQ implement this
    var sinkSpring: SKPhysicsJointSpring! = nil
    var centiSecondsPlayed: Int = 0
    var timeString: String! = nil
    var playing: Bool = true
    var popUpNode: SKSpriteNode? = nil
    var inEditMode: Bool  = false
        //note: More edit mode member variables are below
    
    //////////////////
    // Game Control //
    //////////////////
    
    func haultAction(){
        //pause phsyics
        physicsWorld.speed = 0.0
        
        self.removeActionForKey("timerAction")
        
        //pause core motion
        motionManager.stopDeviceMotionUpdates()
        
        stopBackgroundMusic()
    }
    
    func startAction(){
        //QQQQ give thought to memory leak with this closure (or not???)... the "weak story"
        //QQQQ note sure how exact this time is
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(0.1), SKAction.runBlock(){self.increaseTime()}])),
                                                   withKey: "timerAction")
        
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
            self.physicsWorld.gravity = CGVectorMake(10 * CGFloat(sin(data!.attitude.roll)),-10 * CGFloat(sin(data!.attitude.pitch)))
            self.playerNode.physicsBody!.applyForce(CGVectorMake(CGFloat(data!.userAcceleration.x*600), CGFloat(data!.userAcceleration.y*600)))
            if let error = error { // Might as well handle the optional error as well
                print(error.localizedDescription)
                return
            }
        }
        
        playBackgroundMusic()
    }
    
    func pauseGame(){
        playing = false
        displayPopUp()
        
        self.removeActionForKey("timerAction")
        
        haultAction()
    }
    
    func resetGame(){
        centiSecondsPlayed = 0
    }
    
    func playGame(){
        playing = true
        
        messageLabelNode.DisplayFadingMessage("Your goal: \(sinkNode.targetValue)",duration: 3.0)
        
        //wait for 400ms to let user see screen before gravity kicks in
        //QQQQ change this to use SKAction
        NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(startAction), userInfo: nil, repeats: false)
        
        if let popUp = popUpNode{
            popUp.removeFromParent()
        }
    }
    
    func increaseTime(){
        centiSecondsPlayed = centiSecondsPlayed + 10
        let secondsPlayed = centiSecondsPlayed / 100 % 100
        //timeString = String(format:"%02i:%02i", secondsPlayed, centiSecondsPlayed % 100)
        timeString = String(format:"%02i.%02i", secondsPlayed, centiSecondsPlayed % 100)
        timeLabelNode.text = String(timeString)
    }

    //////////////////////////
    // Finalization of Game //
    //////////////////////////
    
    
    func finalizeSceneWithSuccess(){
        playing = false
        self.runAction(SKAction.playSoundFileNamed("0015_game_event_02_victory.wav",waitForCompletion:false))
        haultAction()

        
        
        //QQQQ Replace this spring stuff or improve it
        //physicsWorld.speed = 1.0
        //        sinkSpring = SKPhysicsJointSpring.jointWithBodyA(playerNode.physicsBody!, bodyB: sinkNode.physicsBody! ,anchorA: playerNode.anchorPoint, anchorB: sinkNode.position)
//        sinkSpring.frequency = 1.0
//        sinkSpring.damping  = 0.0
//        self.physicsWorld.addJoint(sinkSpring)

        gameLevelModel!.newScoreString = timeString //record score
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(moveToAfterLevelScene), userInfo: nil, repeats: false)
    }
    
    func finalizeSceneWithFailure(){
        playing = false
        self.runAction(SKAction.playSoundFileNamed("0015_game_event_02_victory.wav",waitForCompletion:false))
        let badExplosionEmitterNode = SKEmitterNode(fileNamed:"BadExplosionParticle")
        playerNode.addChild(badExplosionEmitterNode!)
        haultAction()
        gameLevelModel!.newScoreString = "" //indicate a failure in the level

        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(moveToAfterLevelScene), userInfo: nil, repeats: false)
    }
    
    func finalizeSceneWithAbort(){
        gameAppDelegate!.changeView(AppState.menuScene)
    }

    func moveToMenuScene(){
        gameAppDelegate!.changeView(AppState.menuScene)
    }
    
    func moveToAfterLevelScene(){
        gameAppDelegate!.changeView(AppState.afterLevelScene)
    }

    
    ///////////////////
    // Initilization //
    ///////////////////
    
    func createObstacleNode(coords: SquareCoordinates){
        let rect = coords.rect()
        let node = SKShapeNode(rect: rect)
        node.name = "obstacleNode"
        node.fillColor = SKColor.darkGrayColor()
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
        sinkNode.position = gameLevelModel!.designInfo.sinkLocation.point()
        sinkNode.name = "sinkNode"
        sinkNode.physicsBody = SKPhysicsBody(circleOfRadius: sinkNode.size.width/2)
        sinkNode.physicsBody!.dynamic = false
        sinkNode.physicsBody!.categoryBitMask = PhysicsCategory.Sink
        sinkNode.physicsBody!.collisionBitMask = PhysicsCategory.None
        sinkNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        self.addChild(sinkNode)
        
        let shrink = SKAction.scaleTo(0.8,duration: 1.2)
        let grow = SKAction.scaleTo(1.0, duration: 0.5)
        let sequence = SKAction.sequence([shrink, grow])
        sinkNode.runAction(SKAction.repeatActionForever(sequence))
    }
    
    func createOperatorNodes(){
        //QQQQ how to better work with this array?
        for i in 0..<gameLevelModel!.designInfo.numOperators{
            operatorNodes[i] = OperatorNode(operatorActionString: gameLevelModel!.designInfo.operatorTypes[i])
            let node = operatorNodes[i]
            node.position = gameLevelModel!.designInfo.operatorLocations[i].point()
            node.zPosition = GameLevelZPositions.operatorZ
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width/2)
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.dynamic = false
            node.physicsBody?.categoryBitMask = PhysicsCategory.Operator
            node.physicsBody?.collisionBitMask = PhysicsCategory.None
            node.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            //QQQQ maybe we won't use this...
            let deltaX = messageLabelNode.position.x-node.position.x
            let deltaY = messageLabelNode.position.y-node.position.y
            node.angleToFire = atan(deltaY/deltaX)+CGFloat(M_PI)
            self.addChild(node)
        }
    }
    
    func createPlayerNode(){
        playerNode = PlayerNode(initValue: gameAppDelegate!.getLevel())
        //playerNode.anchorPoint = CGPoint(x: 0.5, y:0.5) //QQQQ
        playerNode.position = gameLevelModel!.designInfo.startLocation.point()
        playerNode.zPosition = GameLevelZPositions.playerZ
        playerNode.name = "playerNode"
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerNode.size.width/2)
        playerNode.physicsBody!.friction =  0.4 //QQQQ config
        playerNode.physicsBody?.affectedByGravity = true
        playerNode.physicsBody?.dynamic = true
        playerNode.physicsBody?.categoryBitMask = PhysicsCategory.Player
        playerNode.physicsBody?.collisionBitMask = PhysicsCategory.Obstacle | PhysicsCategory.Background
        playerNode.physicsBody?.contactTestBitMask = PhysicsCategory.All
        self.addChild(playerNode)
    }

    func createDashBoard(){
        timeLabelNode = SKLabelNode(text: "00:00")
        timeLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        timeLabelNode.position = CGPoint(x:340, y:620) //QQQQ handle position of this
        timeLabelNode.color = SKColor.whiteColor()
        timeLabelNode.fontSize = 20
        timeLabelNode.fontName = "AmericanTypewriter-Bold"
        self.addChild(timeLabelNode)
        
        messageLabelNode = MessageNode()
        messageLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        messageLabelNode.position = CGPoint(x:20, y:620) //QQQQ handle position of this
        messageLabelNode.color = SKColor.whiteColor()
        messageLabelNode.fontSize = 20
        messageLabelNode.fontName = "AmericanTypewriter-Bold"
        self.addChild(messageLabelNode)
    }
    
    override func didMoveToView(view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "orangeBack")
        background.size = CGSize(width: gameHorzSize, height: gameVertSize)
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x:0,y:0)
        background.zPosition = GameLevelZPositions.backZ
        addChild(background)
        
        physicsWorld.contactDelegate = self
        physicsWorld.speed = 0.0 //will be set to 1.0 when starting
        physicsWorld.gravity = CGVectorMake(0,0)

        self.backgroundColor = SKColor.blackColor()

        //QQQQ read the level from the controller or so....
        gameLevelModel = gameAppDelegate!.getGameLevelModel(gameAppDelegate!.getLevel())
        
        for (coords,_) in gameLevelModel!.designInfo.obstacleMap{
            createObstacleNode(coords)
        }
        createDashBoard()
        createSinkNode()
        createOperatorNodes()
        createPlayerNode()
        updateOperatorsAndSinkStatus()
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.numberOfTapsRequired = 2
        self.view?.addGestureRecognizer(tap)
        
        resetGame()
        if gameAppDelegate!.getAppState() == AppState.gameActionPlaying{
            playGame()
        }else{//assert it is paused QQQQ
            pauseGame()
        }
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
        if !playing {return} //this is mostly a safety guard QQQQ
        
        var actionNode: SKNode?
        if contact.bodyA.node!.name! == "playerNode"{
            actionNode = contact.bodyB.node
        } else{
            actionNode = contact.bodyA.node
        }
        
        switch(actionNode!.name!){
        case "obstacleNode":
            if contact.collisionImpulse > 6{//QQQQ make this 2 a constant
                //QQQQ handle muting globally
                if gameAppDelegate?.isMuted() == false{
                    self.runAction(SKAction.playSoundFileNamed("knock.wav",waitForCompletion:false))
                }
            }
        case "sinkNode":
            if playerNode.value == sinkNode.targetValue{
                finalizeSceneWithSuccess()
            }else{
                finalizeSceneWithFailure()
            }
        default:
            let op = actionNode as! OperatorNode
            if op.active{
                handleOperatorPass(op)
            }
        }
    }
    
    func handleOperatorPass(operatorNode: OperatorNode){
        if operatorNode.valid!{
            messageLabelNode.DisplayFadingMessage("You hit \(operatorNode.operatorAction.operationString())",duration: 1.0)
            
            let newValue = operatorNode.operatorAction.operate(playerNode.value)
            
            operatorNode.active = false
            
            let rotate = SKAction.rotateByAngle(CGFloat(2*M_PI), duration: 2)
            operatorNode.runAction(rotate)

            let fadeout = SKAction.fadeAlphaTo(0.3, duration: 1.0)
            let fadein = SKAction.fadeAlphaTo(1.0, duration: 1.0)
            let revive = SKAction.runBlock(){operatorNode.active = true}
            let sequence = SKAction.sequence([fadeout, fadein,revive])
            operatorNode.runAction(sequence)
            
            //maybe delete this particle story...
//            let squareRootExplosionEmitterNode = SKEmitterNode(fileNamed:"SquareRootParticle")
//            squareRootExplosionEmitterNode?.emissionAngle = operatorNode.angleToFire
//            operatorNode.addChild(squareRootExplosionEmitterNode!)
//            let particleRemove = SKAction.sequence([SKAction.waitForDuration(1.3), SKAction.runBlock(){squareRootExplosionEmitterNode?.removeFromParent()}])
//            operatorNode.runAction(particleRemove)
            
            
            //operators are of two categories: sqrts  - get attention, others - minor
            if operatorNode.operatorAction.operationString() == "sqrt"{
                self.runAction(SKAction.playSoundFileNamed("0015_game_event_03_achieve.wav",waitForCompletion:false))
                
            }else{
                //QQQQ do a non square root shot here
                self.runAction(SKAction.playSoundFileNamed("robotBlip",waitForCompletion:false))
                
            }
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
    
    //QQQQ clean this whole thing up...
    var popUpDesiredPosition: CGPoint! = nil
    
    func displayPopUp(){
        
        //QQQQ Make this whole thing a class
        
        let buttonSize = 45.0
        let buttonSpacing = 15.0
        let playXOffest = 0 - buttonSpacing/2 - buttonSize - buttonSpacing - buttonSize/2
        let stopXOffest = 0 - buttonSpacing/2 - buttonSize/2
        let auidoXOffset = -1*(stopXOffest)
        let helpXOffset = -1*(playXOffest)
        let editXOffset = helpXOffset + buttonSpacing + buttonSize
        
        var popUpWidth = 4*buttonSize+5*buttonSpacing
        if editModeEnabled{
            popUpWidth += buttonSize + buttonSpacing
        }
        let popUpHeight = buttonSize + 2*buttonSpacing
        
        popUpNode = SKSpriteNode(imageNamed: "popup")
        //popUpNode!.colorBlendFactor = 0.8
        //popUpNode!.color = SKColor.redColor()
        popUpNode!.size = CGSize(width: popUpWidth, height: popUpHeight)
        popUpNode!.zPosition = GameLevelZPositions.popUpMenuZ
        if editModeEnabled{
            popUpNode!.anchorPoint = CGPoint(x:2.0/5.0,y: 0.5)
            popUpNode!.position = CGPoint(x:screenCenterPointX-(buttonSize+buttonSpacing)/2, y:screenCenterPointY)
        }else{
            popUpNode!.anchorPoint = CGPoint(x:0.5,y: 0.5)
            popUpNode!.position = CGPoint(x:screenCenterPointX, y:screenCenterPointY)
        }
        popUpDesiredPosition = popUpNode!.position
        
        let playButtonNode = PlayButtonNode(imageNamed: "play")
        playButtonNode.userInteractionEnabled = true
        playButtonNode.name = "playButton"
        playButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
        playButtonNode.position = CGPoint(x:playXOffest, y:0)
        playButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        popUpNode!.addChild(playButtonNode)

        let stopButtonNode = StopButtonNode(imageNamed: "cross-button")
        stopButtonNode.userInteractionEnabled = true
        stopButtonNode.name = "stopButton"
        stopButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
        stopButtonNode.position = CGPoint(x:stopXOffest, y:0)
        stopButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        popUpNode!.addChild(stopButtonNode)

        let audioButtonNode: AudioButtonNode
        if gameAppDelegate!.isMuted(){
            audioButtonNode = AudioButtonNode(imageNamed: "audio")
        }else{
            audioButtonNode = AudioButtonNode(imageNamed: "audioOff")
        }
        
        audioButtonNode.userInteractionEnabled = true
        audioButtonNode.name = "audioButton"
        audioButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
        audioButtonNode.position = CGPoint(x:auidoXOffset, y:0)

        //QQQ Not sure need to set this z position
        audioButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        popUpNode!.addChild(audioButtonNode)
        
        
        let helpButtonNode = HelpButtonNode(imageNamed: "help")
        helpButtonNode.userInteractionEnabled = true
        helpButtonNode.name = "helpButton"
        helpButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
        helpButtonNode.position = CGPoint(x:helpXOffset, y:0)
        helpButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        popUpNode!.addChild(helpButtonNode)
        
        if editModeEnabled{
            let editButtonNode = EditButtonNode(imageNamed: "edit-button")
            editButtonNode.userInteractionEnabled = true
            editButtonNode.name = "editButton"
            editButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
            editButtonNode.position = CGPoint(x:editXOffset, y:0)
            editButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
            popUpNode!.addChild(editButtonNode)
        }
        
        self.addChild(popUpNode!)

        messageLabelNode.DisplayFadingMessage("Paused", duration: 10.0)
    }

    //////////////
    // Gestures //
    //////////////
    
    func handleTap(sender:UITapGestureRecognizer){
        
        if sender.state == .Ended {
            var touchLocation: CGPoint = sender.locationInView(sender.view)
            touchLocation = self.convertPointFromView(touchLocation)
            if editModeEnabled{
                let squarePoint = squareOfPoint(Double(touchLocation.x), y: Double(touchLocation.y))
                let setToKill = squarePoint.NeighbourSquares()
                for pt in setToKill{
                    removeObstacleIfThere(pt)
                }
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
    
    enum CurrentEditAction{
        case None
        case DrawingObstacle    //still not known if Vert of Horz
        case DrawingObstacleVert
        case DrawingObstacleHorz
        case DraggingOperator
        case DraggingStart
        case DraggingSink
    }

    ////////////////////////////////////////////////
    // Member variables associated with edit mode //
    ////////////////////////////////////////////////
    
    var currentEditAction = CurrentEditAction.None
    var currentDraggedOperator: Int! = nil
    var drawObstacleStartPos: SquareCoordinates! = nil
    var startSquareCoordsAddObstacle: SquareCoordinates? = nil

    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !inEditMode{ return }
        
        ///////////////////////////
        // EDIT MODE MOVE EVENTS //
        ///////////////////////////

        let touch = touches.first!
        let positionInScene = touch.locationInNode(self)
        let squareCoords = squareOfPoint(Double(positionInScene.x), y: Double(positionInScene.y))

        switch currentEditAction{
        case CurrentEditAction.None:
            print("error with editing")//QQQQ handle this
        case CurrentEditAction.DrawingObstacle:
            if squareCoords == startSquareCoordsAddObstacle{
                //still no movment out of box
                return
            }else{
                if squareCoords.values.sx != startSquareCoordsAddObstacle!.values.sx{
                    currentEditAction = CurrentEditAction.DrawingObstacleHorz
                }else{
                    currentEditAction = CurrentEditAction.DrawingObstacleVert
                }
            }
            startSquareCoordsAddObstacle = squareCoords
        case CurrentEditAction.DrawingObstacleVert:
            let fixedSx = startSquareCoordsAddObstacle!.values.sx
            let fixedSy = startSquareCoordsAddObstacle!.values.sy
            let currentSy = squareCoords.values.sy
            if fixedSy <= currentSy{
                for sy in fixedSy ... currentSy{
                    addObstacleIfNotThere(SquareCoordinates(sx: fixedSx, sy: sy))
                }
            }else{
                for sy in currentSy ... fixedSy{
                    addObstacleIfNotThere(SquareCoordinates(sx: fixedSx, sy: sy))
                }
            }
        case CurrentEditAction.DrawingObstacleHorz:
            let fixedSx = startSquareCoordsAddObstacle!.values.sx
            let fixedSy = startSquareCoordsAddObstacle!.values.sy
            let currentSx = squareCoords.values.sx
            if fixedSx <= currentSx{
                for sx in fixedSx ... currentSx{
                    addObstacleIfNotThere(SquareCoordinates(sx: sx, sy: fixedSy))
                }
            }else{
                for sx in currentSx ... fixedSx{
                    addObstacleIfNotThere(SquareCoordinates(sx: sx, sy: fixedSy))
                }
            }
        case CurrentEditAction.DraggingOperator:
            operatorNodes[currentDraggedOperator].position = squareCoords.point()
            gameLevelModel!.designInfo.operatorLocations[currentDraggedOperator] = squareCoords

        case CurrentEditAction.DraggingStart:
            if squareCoords != gameLevelModel!.designInfo.startLocation{
                playerNode.position = squareCoords.point()
                gameLevelModel!.designInfo.startLocation = squareCoords
            }

        case CurrentEditAction.DraggingSink:
            if squareCoords != gameLevelModel!.designInfo.sinkLocation{
                sinkNode.position = squareCoords.point()
                gameLevelModel!.designInfo.sinkLocation = squareCoords
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        currentEditAction = CurrentEditAction.None
        currentDraggedOperator = nil
        drawObstacleStartPos = nil
        startSquareCoordsAddObstacle = nil
        
        //QQQQ probably not handling multi-touch - but OK
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if playing{
            pauseGame()
        }
        
        if !inEditMode{ return }

        
        let touch = touches.first!
        let positionInScene = touch.locationInNode(self)
        let squareCoords = squareOfPoint(Double(positionInScene.x), y: Double(positionInScene.y))

        for i in 0..<gameLevelModel!.designInfo.numOperators{
            if operatorNodes[i].containsPoint(positionInScene){
                currentEditAction = CurrentEditAction.DraggingOperator
                currentDraggedOperator = i
                return
            }
        }
        
        if sinkNode.containsPoint(positionInScene){
            currentEditAction = CurrentEditAction.DraggingSink
            return
        }
        
        if playerNode.containsPoint(positionInScene){
            currentEditAction = CurrentEditAction.DraggingStart
            return
        }
        
        //else..
        currentEditAction = CurrentEditAction.DrawingObstacle
        drawObstacleStartPos = squareOfPoint(positionInScene)
        startSquareCoordsAddObstacle = squareCoords
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */

    }
    
    
    //////////////////////////////////////
    // Internal Classes of Menu Buttons //
    //////////////////////////////////////
    
    class HelpButtonNode : SKSpriteNode{
        override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
            (scene as! GameLevelScene).gameAppDelegate!.setReturnAppState(AppState.gameActionPaused)
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
                (scene as! GameLevelScene).messageLabelNode.DisplayFadingMessage("Audio Off", duration: 2.0)
                (scene as! GameLevelScene).stopBackgroundMusic()
            }else{
                self.texture = SKTexture(imageNamed: "audioOff")
                (scene as! GameLevelScene).messageLabelNode.DisplayFadingMessage("Audio On", duration: 2.0)
                (scene as! GameLevelScene).playBackgroundMusic()
            }
        }
    }
    class EditButtonNode : SKSpriteNode{
        override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
            if (scene as! GameLevelScene).inEditMode == false{
                (scene as! GameLevelScene).inEditMode = true
                self.texture = SKTexture(imageNamed: "editOff")
                (scene as! GameLevelScene).popUpNode!.position = CGPoint(x: (scene as! GameLevelScene).popUpDesiredPosition.x, y: CGFloat(0.955*screenHeight))
                (scene as! GameLevelScene).messageLabelNode.DisplayFadingMessage("", duration: 1.0)
            }
            else{
                (scene as! GameLevelScene).inEditMode = false
                self.texture = SKTexture(imageNamed: "edit-button")
                (scene as! GameLevelScene).popUpNode!.position = (scene as! GameLevelScene).popUpDesiredPosition
                (scene as! GameLevelScene).messageLabelNode.DisplayFadingMessage("Edits saved", duration: 5.0)
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
                    tempOperatorStringDict["\(i)"] = "(\(location.values.sx),\(location.values.sy))"
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
                tempStartAndSinkStringDict["0"] = "(\(startLocation.values.sx),\(startLocation.values.sy))"     //currently "0" is start "1" is sink
                tempStartAndSinkStringDict["1"] = "(\(sinkLocation.values.sx),\(sinkLocation.values.sy))"
                
                let outputStartAndSinkDict = tempStartAndSinkStringDict as NSDictionary
                let startAndSinkFilePath = NSHomeDirectory() + "/Library/startAndSink\((scene as! GameLevelScene).gameLevelModel!.levelNumber).plist"
                outputStartAndSinkDict.writeToFile(startAndSinkFilePath, atomically: true)
                print("Wrote to \(startAndSinkFilePath)")

            }
        }
    }
}//end of class
