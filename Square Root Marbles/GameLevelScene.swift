//
//  GameLevelScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit

struct GameLevelZPositions{
    static let obstacleZ = CGFloat(-20.0)
    static let operatorZ = CGFloat(-10.0)
    static let sinkZ = CGFloat(-5.0)
    static let playerZ = CGFloat(0.0)
    static let popUpMenuZ = CGFloat(10.0)
    static let popUpMenuButtonsZ = CGFloat(20.0)
}

class GameLevelScene: GeneralScene, SKPhysicsContactDelegate {
    
    var gameLevelModel: GameLevelModel? = nil
    
    var obstacleMap = Dictionary<SquareCoordinates,SKShapeNode>()
    var operatorSprites = Set<SKSpriteNode>()
    var ballsNode: SKSpriteNode! = nil
    var sinkNode: SKShapeNode! = nil
    var sinkNodeText: SKLabelNode! = nil
    
    var sinkSpring: SKPhysicsJointSpring! = nil
    
    var nodeSize: Double!
    var sinkSize: Double!
    
    var timePlayed: Int = 0
    
    var playing: Bool = true

    var popUpNode: SKSpriteNode? = nil
    
    var inEditMode: Bool  = false

    var lastPlayerLocation: CGPoint? = nil
    
    func pauseGame(){
        playing = false
        displayPopUp()
        
        lastPlayerLocation = ballsNode!.position
        
        //pause time
        //QQQQ implement
        
        //pause phsyics
        physicsWorld.speed = 0.0
        
        //pause core motion
        motionManager.stopDeviceMotionUpdates()
    }
    
    func resetGame(){
        lastPlayerLocation = self.gameLevelModel!.designInfo.startLocation
    }
    
    func playGame(){
        playing = true
        
        //put physics world in normal playing mode
        physicsWorld.speed = 1.0

        
        motionManager.startDeviceMotionUpdates()
        motionManager.deviceMotionUpdateInterval = 0.03
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue() ) {
            (data, error) in
            //QQQQ adjust and organize these constants
            self.physicsWorld.gravity = CGVectorMake(10 * CGFloat(sin(2*data!.attitude.roll)),-10 * CGFloat(sin(2*data!.attitude.pitch)))
            self.ballsNode.physicsBody!.applyForce(CGVectorMake(CGFloat(data!.userAcceleration.x*600), CGFloat(data!.userAcceleration.y*600)))
            if let error = error { // Might as well handle the optional error as well
                print(error.localizedDescription)
                return
            }
        }
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(increaseTime), userInfo: nil, repeats: true)
        
        
        //QQQQ do this on last location
        reConfigureActionNodes()
        
        if let popUp = popUpNode{
            popUp.removeFromParent()
        }
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var actionNode: SKNode?
        if contact.bodyA.node!.name! == "ballsNode"{
            actionNode = contact.bodyB.node
        } else{
            actionNode = contact.bodyA.node
        }
        
        lastPlayerLocation = ballsNode.position
        
        switch (gameLevelModel!.ballsState, actionNode!.name!){
        case (_,"obstacleNode"):
        if contact.collisionImpulse > 2{//QQQQ make this 2 a constant
            //QQQQ handle muting globally
            if gameAppDelegate?.isMuted() == false{
                self.runAction(SKAction.playSoundFileNamed("hitMetal.wav",waitForCompletion:false))
            }
        }
        case (BallsState.line,"sqrtNode"):
            print("line hit sqrt")
            //finalizeSceneWithFailure()
        case (BallsState.square,"sqrtNode"):
            print("square hit sqrt")
            gameLevelModel!.ballsState = BallsState.line
            reConfigureActionNodes()
        case (BallsState.line,"squaredNode"):
            print("line hit squared")
            gameLevelModel!.ballsState = BallsState.square
            reConfigureActionNodes()
        case (BallsState.square,"squaredNode"):
            print("square hit squared")
            //finalizeSceneWithFailure()
        case (BallsState.square,"sinkNode"):
            print("square hit destination")
            finalizeSceneWithSuccess()
        case (BallsState.line,"sinkNode"):
            print("line hit destination")
            finalizeSceneWithFailure()
        default:
            break
        }
    }

    func finalizeSceneWithSuccess(){
        gameAppDelegate!.changeView(AppState.menuScene)

        //QQQQ update score here
        
        //QQQQ        self.runAction(SKAction.playSoundFileNamed("chinese-gong-daniel_simon.wav",waitForCompletion:false))
        //QQQQ maybe need to wait till move
//        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(moveToControlPanelScene), userInfo: nil, repeats: false)
    }
    
    func finalizeSceneWithFailure(){
        gameAppDelegate!.changeView(AppState.menuScene)
        //    self.runAction(SKAction.playSoundFileNamed("smashing.wav",waitForCompletion:false))
        //    NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(moveToControlPanelScene), userInfo: nil, repeats: false)
    }
    
    func finalizeSceneWithAbort(){
        gameAppDelegate!.changeView(AppState.menuScene)
    }

    
    func reConfigureActionNodes(){
        if ballsNode != nil{
            ballsNode.removeFromParent()
        }
        
        switch gameLevelModel!.ballsState{
        case BallsState.square:
            //  lineOnlyNode.runAction(SKAction.hide())
            ballsNode = SKSpriteNode(imageNamed: gameLevelModel!.designInfo.ballsSquareImageName)
            ballsNode.size = CGSize(width:nodeSize, height:nodeSize)
            for sp in operatorSprites{
                if sp.name == "sqrtNode"{
                    sp.texture = SKTexture(imageNamed: "bareOKsqrtNode")
                }else{
                    sp.texture = SKTexture(imageNamed: "bareBADsquareNode")
                }
            }
        case BallsState.line:
            //fullSquareNode.runAction(SKAction.hide())
            ballsNode = SKSpriteNode(imageNamed: gameLevelModel!.designInfo.ballsLineImageName)
            ballsNode.size = CGSize(width:nodeSize, height:nodeSize/Double(gameAppDelegate!.getLevel()))
            for sp in operatorSprites{
                if sp.name == "sqrtNode"{
                    sp.texture = SKTexture(imageNamed: "bareBADsqrtNode")
                }else{
                    sp.texture = SKTexture(imageNamed: "bareOKsquareNode")
                }
            }
        }
        
        ballsNode.anchorPoint = CGPoint(x: 0.5, y:0.5)
        ballsNode.position = lastPlayerLocation!
        ballsNode.zPosition = 0
        ballsNode.name = "ballsNode"
        ballsNode.physicsBody = SKPhysicsBody(rectangleOfSize: ballsNode.size)
        ballsNode.physicsBody!.friction =  0.4 //QQQQ config
        ballsNode.physicsBody?.affectedByGravity = true
        ballsNode.physicsBody?.dynamic = true
        ballsNode.physicsBody?.categoryBitMask = PhysicsCategory.Balls
        ballsNode.physicsBody?.collisionBitMask = PhysicsCategory.Obstacle
        ballsNode.physicsBody?.contactTestBitMask = PhysicsCategory.All
        self.addChild(ballsNode)
        
        //QQQQ
   //     sinkSpring = SKPhysicsJointSpring.jointWithBodyA(ballsNode.physicsBody!, bodyB: sinkNode.physicsBody! ,anchorA: ballsNode.anchorPoint, anchorB: sinkNode.position)
        
    }

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
        node.physicsBody!.collisionBitMask = PhysicsCategory.Balls
        node.physicsBody!.contactTestBitMask = PhysicsCategory.Balls
        obstacleMap[coords] = node
        self.addChild(node)
    }
    
    func createOperatorNode(location: CGPoint, type: OperatorType ,mode: OperatorMode){
        let node: SKSpriteNode
        switch type{
        case OperatorType.squareRoot:
            node = SKSpriteNode(imageNamed: "bareOKsqrtNode")
            node.name = "sqrtNode"
        case OperatorType.squared:
             node = SKSpriteNode(imageNamed: "bareOKsquareNode")
            node.name = "squaredNode"
        }
        node.size = CGSize(width: 90, height: 70)
        node.anchorPoint = CGPoint(x: 0.5, y:0.5)
        node.position = location
        node.zPosition = 100
        node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.dynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.Sqrt
        node.physicsBody?.collisionBitMask = PhysicsCategory.None
        node.physicsBody?.contactTestBitMask = PhysicsCategory.Balls
        operatorSprites.insert(node)
        self.addChild(node)
    }

    
    override func didMoveToView(view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        self.backgroundColor = SKColor.blackColor()

        //QQQQ read the level from the controller or so....
        gameLevelModel = GameLevelModel(level: gameAppDelegate!.getLevel())
        
        for (coords,_) in gameLevelModel!.designInfo.obstacleMap{
            createObstacleNode(coords)
        }
        
        for op in gameLevelModel!.designInfo.operators{
            //QQQQ set initial operator modes
            createOperatorNode(op.location, type: op.type, mode: OperatorMode.accepting)
        }
        
        
        nodeSize = sizeOfPlayNode(gameLevelModel!.levelNumber)
        sinkSize = 1.3*nodeSize
        
        sinkNode = SKShapeNode(rectOfSize: CGSize(width: sinkSize, height: sinkSize))
        sinkNode.fillColor = SKColor.greenColor()
        sinkNode.position = CGPoint(x: self.frame.size.width*0.9, y: self.frame.size.height*0.51)
        sinkNode.name = "sinkNode"
        sinkNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 40, height: 40))
        sinkNode.physicsBody!.dynamic = false
        sinkNode.physicsBody!.categoryBitMask = PhysicsCategory.Goal
        sinkNode.physicsBody!.collisionBitMask = PhysicsCategory.None
        sinkNode.physicsBody!.contactTestBitMask = PhysicsCategory.Balls
        self.addChild(sinkNode)
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.numberOfTapsRequired = 2
        self.view?.addGestureRecognizer(tap)
        
        resetGame()
        playGame()
        
    }
    
    func handleTap(sender:UITapGestureRecognizer){
        
        if sender.state == .Ended {
            var touchLocation: CGPoint = sender.locationInView(sender.view)
            touchLocation = self.convertPointFromView(touchLocation)
            if editModeEnabled{
                removeObstacleIfThere(squareOfPoint(Double(touchLocation.x), y: Double(touchLocation.y)))
            }
        }
    }

    
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
    
    func increaseTime(){
//        timePlayed = timePlayed + 1
//        sinkNodeText.text = String(timePlayed)
    }
    
    
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

    
//    QQQQ delete
//    func handleObstacleUpdate(squareCoords: SquareCoordinates){
//        let node = obstacleMap[squareCoords]
//        if node == nil{
//            createObstacleNode(squareCoords)
//            gameLevelModel!.designInfo.obstacleMap[squareCoords] = ObstacleType.genericObstacle
//        }else{
//            //node!.fillColor = SKColor.blackColor()
//            node?.removeFromParent()
//            gameLevelModel!.designInfo.obstacleMap.removeValueForKey(squareCoords)
//            obstacleMap[squareCoords] = nil
//        }
//    }
//    
    var lastSquareCoordsMove: SquareCoordinates? = nil
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !inEditMode{ return }
        
        ///////////////////////////
        // EDIT MODE MOVE EVENTS //
        ///////////////////////////

        let touch = touches.first!

        let positionInScene = touch.locationInNode(self)
//        let previousPosition = touch.previousLocationInNode(self)
//        let translation = CGPoint(  x: positionInScene.x - previousPosition.x,
//                                    y: positionInScene.y - previousPosition.y)
        

        var gotOperator = false
        gameLevelModel!.designInfo.operators.removeAll()
        for node in operatorSprites{
            let type = (node.name == "sqrtNode") ? OperatorType.squareRoot : OperatorType.squared
            if node.containsPoint(positionInScene){
                node.position = positionInScene
                //QQQQ this is bad implementation here!!!
                gameLevelModel!.designInfo.operators.insert(
                    OperatorInfo(location: positionInScene, type: type))
                gotOperator = true
            }else{
                gameLevelModel!.designInfo.operators.insert(
                    OperatorInfo(location: node.position, type: type))
            }
        }
        if gotOperator{
            return
        }
        
        if sinkNode.containsPoint(positionInScene){
            sinkNode.position = positionInScene
            return
        }
        
        if ballsNode.containsPoint(positionInScene){
            ballsNode.position = positionInScene
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
                
                // Write obstacles to file
                var tempObstacleStringDict = Dictionary<String,String>()
                for (coords,obs) in (scene as! GameLevelScene).gameLevelModel!.designInfo.obstacleMap{
                    tempObstacleStringDict["(\(coords.values.sx),\(coords.values.sy))"] = "\(obs)"
                }
                let outputObstacleDict = tempObstacleStringDict as NSDictionary
                let obstacleFilePath = NSHomeDirectory() + "/Library/obstacles\((scene as! GameLevelScene).gameLevelModel!.levelNumber).plist"
                outputObstacleDict.writeToFile(obstacleFilePath, atomically: true)
                print("Wrote to \(obstacleFilePath)")
                
                // Write operators to file
                var tempOperatorStringDict = Dictionary<String,String>()
                for op in (scene as! GameLevelScene).gameLevelModel!.designInfo.operators{
                    tempOperatorStringDict["(\(op.location.x),\(op.location.y))"] = "\(op.type)"
                }
                let outputOperatorDict = tempOperatorStringDict as NSDictionary
                let operatorFilePath = NSHomeDirectory() + "/Library/operators\((scene as! GameLevelScene).gameLevelModel!.levelNumber).plist"
                outputOperatorDict.writeToFile(operatorFilePath, atomically: true)
                print("Wrote to \(operatorFilePath)")
            }
        }
    }
    
}
