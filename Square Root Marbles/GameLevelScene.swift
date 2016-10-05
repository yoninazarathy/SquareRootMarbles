//
//  GameLevelScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit

struct PhysicsCategory{
    static let  None                :   UInt32 = 0
    static let  All                 :   UInt32 = UInt32.max
    static let  Player              :   UInt32 = 0b1
    static let  PassingOperator     :   UInt32 = 0b10
    static let  BlockingOperator    :   UInt32 = 0b100
    static let  Obstacle            :   UInt32 = 0b1000
    static let  Sink                :   UInt32 = 0b10000
    static let  Background          :   UInt32 = 0b100000
}


struct GameLevelZPositions{
    static let backZ = CGFloat(-100.0)
    static let obstacleZ = CGFloat(-20.0)
    static let sinkZ = CGFloat(-5.0)
    static let playerZ = CGFloat(0.0)
    static let operatorZ = CGFloat(5.0)
    static let dimPanelZ = CGFloat(250.0)
    static let messageNodeZ = CGFloat(275.0)
    static let popUpMenuZ = CGFloat(300.0)
    static let popUpMenuButtonsZ = CGFloat(400.0)
}

class GameLevelScene: GeneralScene, SKPhysicsContactDelegate {
    var gameLevelModel: GameLevelModel? = nil
    var obstacleMap = Dictionary<SquareCoordinates,SKShapeNode>()
    var playerNode: PlayerNode! = nil
    var operatorNodes: [OperatorNode?] = Array(repeating: nil, count: upperBoundNumOperators)
    var sinkNode: SinkNode! = nil
    var lifesNode: LifesNode! = nil
    var messageLabelNode: MessageNode! = nil

    //QQQQ implement this
    var sinkSpring: SKPhysicsJointSpring! = nil
    var centiSecondsPlayed: Int = 0
    var lastTimeLost:   Int = 0
    var timeString: String! = nil
    var playing: Bool = true
    var popUpNode: SKSpriteNode? = nil
    var inEditMode: Bool  = false
        //note: More edit mode member variables are below
    
    var finishingSteps: Int = 0
    
    var lifeRemaining: Double = Double(secondsBetweenLosses)
    
    var dimPanel: SKSpriteNode!
    
    var lastTimeWallHit: Double = -100.0
    var currentTime: Double = 0.0
    
    var totalTilt: Double = 0.0
    var prevTilt1: Double = 0.0
    var prevTilt2: Double = 0.0
    var tiltMessageDisplayed: Bool = false
    
    //////////////////
    // Game Control //
    //////////////////
    
    func haultAction(){
        //pause phsyics
        physicsWorld.speed = 0.0
        
        self.removeAction(forKey: "timerAction")
        
        //pause core motion
        motionManager.stopDeviceMotionUpdates()
    }
    
    func startAction(){
        //QQQQ give thought to memory leak with this closure (or not???)... the "weak story"
        //QQQQ note sure how exact this time is
        run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.1), SKAction.run(){self.oneSecondWakeUp()}])),
                                                   withKey: "timerAction")
        
        //QQQQ This is crazy - idea is to delay 100ms till start
        run(
                SKAction.sequence([SKAction.wait(forDuration: 0.1),SKAction.run(){
                    //put physics world in normal playing mode
                    self.physicsWorld.speed = 1.0
                    
                    //QQQQ not sure if this should be here or elsewhere
                    //QQQQ not sure these four lines of code do anything. Maybe remove (or modify)
                    let sceneBody = SKPhysicsBody(edgeLoopFrom: self.frame)
                    //sceneBody.friction = 1000
                    sceneBody.categoryBitMask = PhysicsCategory.Background
                    sceneBody.contactTestBitMask = PhysicsCategory.Player
                    self.name = "sceneNode"
                    self.physicsBody = sceneBody
                    
                    motionManager.startDeviceMotionUpdates()
                    motionManager.deviceMotionUpdateInterval = 0.02
                    motionManager.startDeviceMotionUpdates(to: OperationQueue.main ) {
                        (data, error) in
                        //QQQQ adjust and organize these constants
                        self.physicsWorld.gravity = CGVector(dx: 20 * CGFloat(sin(data!.attitude.roll)),dy: -20 * CGFloat(sin(data!.attitude.pitch)))
                        self.totalTilt = self.totalTilt + abs(self.prevTilt1 - data!.attitude.roll) + abs(self.prevTilt2 - data!.attitude.pitch)
                        self.prevTilt1 = data!.attitude.roll
                        self.prevTilt2 = data!.attitude.pitch
                        
                        //QQQQ disabled acceleartion
                        //self.playerNode.physicsBody!.applyForce(CGVector(dx: CGFloat(data!.userAcceleration.x*500), dy: CGFloat(data!.userAcceleration.y*500)))
                        if let error = error { // Might as well handle the optional error as well
                            print(error.localizedDescription)
                            return
                        }
                    }
                    
                    self.playBackgroundMusic()
                }])
        )//end of runAction
    }
    
    func pauseGame(){
        playing = false
        displayPopUp()
        
        self.removeAction(forKey: "timerAction")
        
        haultAction()
    }
    
    func resetLevel(){
        centiSecondsPlayed = 0
        finishingSteps = 0
        let numLifes = gameAppDelegate!.getGameLevelModel(gameAppDelegate!.getLevel()).numMarbles
        lifesNode.setLifes(numLifes)
        
        //QQQQ this does not work... on the GA website (I think it generates error events... maybe Swift 3???)
        GameAnalytics.addProgressionEvent(with: GAProgressionStatusStart, progression01: "Level\(gameAppDelegate!.getLevel())", progression02: "Lifes\(numLifes)", progression03: "NothingToSay")
    }
    
    func playGame(){
        playing = true
        
        messageLabelNode.displayFadingMessage("Your goal: \(sinkNode.targetValue)",duration: 3.0)
        
        //wait for 400ms to let user see screen before gravity kicks in
        //QQQQ change this to use SKAction
        Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(startAction), userInfo: nil, repeats: false)
        
        if let popUp = popUpNode{
            popUp.removeFromParent()
        }
        
        let grow = SKAction.scale(by: 2.2, duration: 1.2)
        let shrink = grow.reversed()
        let makeDynamic = SKAction.run(){self.playerNode.physicsBody!.isDynamic = true
        }
        playerNode.physicsBody!.isDynamic = false
        playerNode.run(SKAction.sequence([grow, shrink, makeDynamic]))
    }
    
    func oneSecondWakeUp(){ //QQQQ change name
        centiSecondsPlayed = centiSecondsPlayed + 10
        
        lifeRemaining = lifeRemaining  - 0.1
        lifesNode.currentLife = Double(lifeRemaining)/Double(secondsBetweenLosses)
        lifesNode.refreshDisplay()
        
        
        if lifeRemaining < 0{
            lastTimeLost = centiSecondsPlayed
            lifeRemaining = Double(secondsBetweenLosses)
            
            lifesNode.currentLife = 1.0
            lifesNode.decrementLifes()
            if  lifesNode.numLifes == 0{
                finalizeSceneWithFailure()
            }
        }
        
        
        
        //QQQQ Currently not doing anything with this
        
//        let secondsPlayed = centiSecondsPlayed / 100 % 100
//        //timeString = String(format:"%02i:%02i", secondsPlayed, centiSecondsPlayed % 100)
//        timeString = String(format:"%02i.%02i", secondsPlayed, centiSecondsPlayed % 100)
//    
//        //QQQQ update this code here
//        
//        timeLabelNode.text = "\(gameAppDelegate!.getNumberOfMarblesX())"
//        //timeLabelNode.text = String(timeString)
    }

    //////////////////////////
    // Finalization of Game //
    //////////////////////////
    
    
    func finalizeSceneWithSuccess(){
        playing = false
        finishingSteps = 200//QQQQ
        sinkNode.removeAllActions()
        playWinSound()

        haultAction()
        physicsWorld.speed = 1.0 //QQQQ have done this on other one too - fix...
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        let newNumMarbles = lifesNode.numLifes
        
        GameAnalytics.addProgressionEvent(with: GAProgressionStatusComplete, progression01: "Level\(gameAppDelegate!.getLevel())", progression02: "Lifes\(newNumMarbles)", progression03: "Centiseconds:\(centiSecondsPlayed)")
        
        let currentLevel = gameLevelModel!.levelNumber
        if currentLevel < numLevels{
            let nextLevel = gameAppDelegate!.getGameLevelModel(currentLevel + 1)
            //open next level if it isn't open
            if nextLevel.numMarbles < newNumMarbles {
                nextLevel.numMarbles = newNumMarbles 
                let defaults = UserDefaults.standard
                defaults.set(String(nextLevel.numMarbles), forKey: "level\(currentLevel+1)marbles")
            }
        }
        
        if newNumMarbles > gameLevelModel!.numMarbles{
            gameLevelModel!.numMarbles = newNumMarbles
            let defaults = UserDefaults.standard
            defaults.set(String(newNumMarbles), forKey: "level\(currentLevel)marbles")
        }
        
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(moveToNextLevelScene), userInfo: nil, repeats: false)
    }
    
    func finalizeSceneWithFailure(){
        playing = false
        playDieSound()
        let badExplosionEmitterNode = SKEmitterNode(fileNamed:"BadExplosionParticle")
        playerNode.color = SKColor.red
        playerNode.underline.fillColor = SKColor.red
        playerNode.underline.strokeColor = SKColor.red
        let colorAction = SKAction.colorize(with: SKColor.red, colorBlendFactor: 0.8, duration: 0.7)
        playerNode.run(colorAction)
        playerNode.labelNode.fontColor = SKColor.red
        playerNode.addChild(badExplosionEmitterNode!)
        haultAction()
        physicsWorld.speed = 1.0 //undo what is done in haultAction (to allow some extra spinning)

        GameAnalytics.addProgressionEvent(with: GAProgressionStatusFail, progression01: "Level\(gameAppDelegate!.getLevel())", progression02: "NothingToSay", progression03: "Centiseconds:\(centiSecondsPlayed)")

        
        //QQQQ Get rid of NSTimer
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(moveToAfterLevelScene), userInfo: nil, repeats: false)
    }
    
    func finalizeSceneWithAbort(){
        gameAppDelegate!.changeView(AppState.menuScene)
        haultAction()
        //stopBackgroundMusic()
    }

    func moveToMenuScene(){
        gameAppDelegate!.changeView(AppState.menuScene)
        //stopBackgroundMusic()
    }
 
    func moveToNextLevelScene(){
        
        let level = gameAppDelegate!.getLevel()
        
        if gameAppDelegate!.getOperationLog().count >= minNumOperationsBetweenAfterScreen &&
            level < numLevels{
            gameAppDelegate!.changeView(AppState.afterLevelSceneBreak)
            setLowBackgroundMusicVolume() //QQQQ the volume should be set as part of the scene
            return
        }
        
        if level < numLevels{
            //QQQQ funny transition mechanism but it works...
            gameAppDelegate!.setLevel(level+1)
            gameAppDelegate!.changeView(AppState.gameActionPlaying)
        }else{
            gameAppDelegate!.changeView(AppState.victoryScene)//!!!!! Victory!!!!
        }
    }

    
    func moveToAfterLevelScene(){
        //QQQQ will want this when failing...
        gameAppDelegate!.changeView(AppState.afterLevelSceneFinished)
        setLowBackgroundMusicVolume() //QQQQ the volume should be set as part of the scene
    }

    
    ///////////////////
    // Initilization //
    ///////////////////
    
    func createObstacleNode(_ coords: SquareCoordinates){
        let rect = coords.rect()
        let node = SKShapeNode(rect: rect)
        node.name = "obstacleNode"
        node.fillColor = SKColor.darkGray
        node.lineWidth = 0
        node.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
        node.physicsBody!.isDynamic = false
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
        sinkNode.zPosition = GameLevelZPositions.sinkZ
        sinkNode.physicsBody = SKPhysicsBody(circleOfRadius: sinkNode.size.width/2)
        sinkNode.physicsBody!.isDynamic = false
        sinkNode.physicsBody!.categoryBitMask = PhysicsCategory.Sink | PhysicsCategory.BlockingOperator
        sinkNode.physicsBody!.collisionBitMask = PhysicsCategory.None
        sinkNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        self.addChild(sinkNode)
        
        let shrink = SKAction.scale(to: 0.8,duration: 1.2)
        let grow = SKAction.scale(to: 1.0, duration: 0.5)
        let sequence = SKAction.sequence([shrink, grow])
        sinkNode.run(SKAction.repeatForever(sequence))
    }
    
    func createOperatorNodes(){
        //QQQQ how to better work with this array?
        for i in 0..<gameLevelModel!.designInfo.numOperators{
            operatorNodes[i] = OperatorNode(operatorActionString: gameLevelModel!.designInfo.operatorTypes[i])
            let node = operatorNodes[i]
            node?.name = "operatorNode"
            node?.position = gameLevelModel!.designInfo.operatorLocations[i]!.point()
            node?.zPosition = GameLevelZPositions.operatorZ
            node?.physicsBody = SKPhysicsBody(circleOfRadius: (node?.size.width)!/2)
            node?.physicsBody?.affectedByGravity = false
            node?.physicsBody?.isDynamic = false
            node?.physicsBody?.categoryBitMask = PhysicsCategory.PassingOperator
            node?.physicsBody?.collisionBitMask = PhysicsCategory.None
            node?.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            self.addChild(node!)
        }
    }
    
    func createPlayerNode(){
        playerNode = PlayerNode(initValue: initValueOfLevel(gameAppDelegate!.getLevel()))
        //playerNode.anchorPoint = CGPoint(x: 0.5, y:0.5) //QQQQ
        playerNode.position = gameLevelModel!.designInfo.startLocation.point()
        playerNode.zPosition = GameLevelZPositions.playerZ
        playerNode.name = "playerNode"
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerNode.size.width/2)
        playerNode.physicsBody!.friction =  0.4 //QQQQ config
        playerNode.physicsBody?.affectedByGravity = true
        playerNode.physicsBody?.isDynamic = true
        playerNode.physicsBody?.categoryBitMask = PhysicsCategory.Player
        playerNode.physicsBody?.angularDamping = 0.6
        playerNode.physicsBody?.linearDamping = 0.3
        //QQQQ not sure we need the background collision
        playerNode.physicsBody?.collisionBitMask = PhysicsCategory.Obstacle | PhysicsCategory.Background
            | PhysicsCategory.BlockingOperator
        playerNode.physicsBody?.contactTestBitMask = PhysicsCategory.All
        self.addChild(playerNode)
    }

    func createDashBoard(){
        //QQQQ coordinates need computing
        lifesNode = LifesNode(position:  CGPoint(x:240, y:600))
        self.addChild(lifesNode)
        
        messageLabelNode = MessageNode(position: CGPoint(x:20, y:625))//QQQQ position...
        messageLabelNode.zPosition = GameLevelZPositions.messageNodeZ
        self.addChild(messageLabelNode)
    }
    
    override func didMove(to view: SKView) {
        setHighBackgroundMusicVolume()
        
        dimPanel = SKSpriteNode(color: UIColor.black, size: self.size)
        dimPanel.alpha = 0.82
        dimPanel.zPosition = GameLevelZPositions.dimPanelZ
        dimPanel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)

        
        let background = SKSpriteNode(imageNamed: "orangeBack")
        background.size = CGSize(width: gameHorzSize, height: gameVertSize)
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x:0,y:0)
        background.zPosition = GameLevelZPositions.backZ
        addChild(background)
        
        physicsWorld.contactDelegate = self
        physicsWorld.speed = 0.0 //will be set to 1.0 when starting
        physicsWorld.gravity = CGVector(dx: 0,dy: 0)

        self.backgroundColor = SKColor.black

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
        
        resetLevel()
        if gameAppDelegate!.getAppState() == AppState.gameActionPlaying{
            playGame()
        }else{//assert it is paused QQQQ
            pauseGame()
            dimPanel.removeFromParent() //needed??? QQQQ
            self.addChild(dimPanel)

        }
    }
    
    ///////////////////////
    // Game Play Actions //
    ///////////////////////
    
    
    func updateOperatorsAndSinkStatus(){
        for i in 0..<gameLevelModel!.designInfo.numOperators{
            let node = operatorNodes[i]
            if node!.operatorAction!.isValid(playerNode.value){
                node?.setAsValid()
            }else{
                node?.setAsInvalid()
            }
        }
        if playerNode.value == sinkNode.targetValue{
            sinkNode.setAsValid()
        }else{
            sinkNode.setAsInvalid()
        }
    }
    
    //this is here to make nodes blocking after they become invalid
    func didEnd(_ contact: SKPhysicsContact) {
        if !playing {return} //this is mostly a safety guard QQQQ
        var actionNode: SKNode?
        if contact.bodyA.node!.name! == "playerNode"{
            actionNode = contact.bodyB.node
        } else{
            actionNode = contact.bodyA.node
        }
        
        switch(actionNode!.name!){
        case "sinkNode":
            //QQQQ no reason for this to be here...
            if sinkNode.valid == false{
                sinkNode?.physicsBody!.categoryBitMask = PhysicsCategory.BlockingOperator
            }
        case "operatorNode":
            if (actionNode as! OperatorNode).valid == false{
                actionNode?.physicsBody!.categoryBitMask = PhysicsCategory.BlockingOperator
            }
        default:
            break
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if !playing {return} //this is mostly a safety guard QQQQ
        
        var actionNode: SKNode?
        if contact.bodyA.node!.name! == "playerNode"{
            actionNode = contact.bodyB.node
        } else{
            actionNode = contact.bodyA.node
        }
        
        switch(actionNode!.name!){
        case "obstacleNode":
            if lastTimeWallHit + 0.05 < currentTime{
                playWallHit(Float(contact.collisionImpulse))
                lastTimeWallHit = currentTime
            }
        case "sinkNode":
            if playerNode.value == sinkNode.targetValue{
                finalizeSceneWithSuccess()
            }else{
                hitBadNode(sinkNode)
            }
        case "sceneNode":
            print("hit scene (error???)")
        case "operatorNode":
            let op = actionNode as! OperatorNode
            if op.active{
                handleOperatorPass(op)
            }
        default:
            print("error")//QQQQ report
        }
    }
    
    func handleOperatorPass(_ operatorNode: OperatorNode){
        if operatorNode.valid!{
            //messageLabelNode.DisplayFadingMessage("You hit \(operatorNode.operatorAction.operationString())",duration: 1.0)
            let newValue = operatorNode.operatorAction.operate(playerNode.value)
            messageLabelNode.displayOperationPass(operatorNode.operatorAction.operationString(),
                                                  oldValue: playerNode.value,
                                                  newValue: newValue,
                                                  duration: 4.0) //QQQQ use globalConst
            
            gameAppDelegate!.recordOperation(
                op: operatorNode.operatorAction.operationString(),
                oldValue: playerNode.value,
                newValue: newValue)            
            
            operatorNode.active = false
            
            let rotate = SKAction.rotate(byAngle: CGFloat(2*M_PI), duration: 2)
            operatorNode.run(rotate)

            let fadeout = SKAction.fadeAlpha(to: 0.3, duration: 1.0)
            let fadein = SKAction.fadeAlpha(to: 1.0, duration: 1.0)
            let revive = SKAction.run(){operatorNode.active = true}
            let sequence = SKAction.sequence([fadeout, fadein,revive])
            operatorNode.run(sequence)
            
            //maybe delete this particle story...
//            let squareRootExplosionEmitterNode = SKEmitterNode(fileNamed:"SquareRootParticle")
//            squareRootExplosionEmitterNode?.emissionAngle = operatorNode.angleToFire
//            operatorNode.addChild(squareRootExplosionEmitterNode!)
//            let particleRemove = SKAction.sequence([SKAction.waitForDuration(1.3), SKAction.runBlock(){squareRootExplosionEmitterNode?.removeFromParent()}])
//            operatorNode.runAction(particleRemove)
            
            
            //operators are of two categories: sqrts  - get attention, others - minor
            if operatorNode.operatorAction.operationString() == "sqrt"{
                
                //get extra life for sqrt that doesn't yield 0 or 1
                if true {//playerNode.value != newValue{
                    if lifesNode.numLifes < 10{
//                        let diceRoll = arc4random_uniform(numSRMVoices) + 1
                        //QQQQ not sure about this random...
//                        self.runAction(SKAction.playSoundFileNamed("srm_\(diceRoll).mp3",waitForCompletion:false))
                        playRandomSRM()
                        
                        self.lifeRemaining = Double(secondsBetweenLosses)
                        lifesNode.currentLife = 1.0
                        lifesNode.incrementLifes(playerNode.position)
                    }else{
                        //QQQQ play sound max lifes reached
                        messageLabelNode.displayFadingMessage("Max", duration: 3.0)//QQQQ
                    }
                    
                    lastTimeLost = centiSecondsPlayed //since getting new life, reset counter
                }
                
                operatorNode.removeFromParent()//QQQQ
                
                
            }else{
                playOperatorSound()
            }
            playerNode.changeValue(newValue)
            updateOperatorsAndSinkStatus()
        }
        else{
            operatorNode.active = false
            let shrink = SKAction.scale(by: 0.4, duration: 1.0)
            let grow = shrink.reversed()
            let revive = SKAction.run(){operatorNode.active = true}
            let sequence = SKAction.sequence([shrink, grow,revive])
            operatorNode.run(sequence)

            hitBadNode(operatorNode)
            
        }
    }

    func repelFromSprite(sprite: SKSpriteNode, magnitude: CGFloat){
        let playerPos = playerNode.position
        let operatorPos = sprite.position
        playerNode.physicsBody!.applyImpulse(
            CGVector(dx: magnitude*(playerPos.x - operatorPos.x), dy: magnitude*(playerPos.y - operatorPos.y)),
            at: CGPoint(x:0,y:0))
    }
    
    func hitBadNode(_ badNode: SKSpriteNode){

        playBadNodeTouchSound()

        repelFromSprite(sprite: badNode, magnitude: 0.6)

        
        lastTimeLost = centiSecondsPlayed //since decrementing life, reset counter
        lifesNode.decrementLifes()
        lifeRemaining  = Double(secondsBetweenLosses)
        
        if lifesNode.numLifes == 0{
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
        playButtonNode.isUserInteractionEnabled = true
        playButtonNode.name = "playButton"
        playButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
        playButtonNode.position = CGPoint(x:playXOffest, y:0)
        playButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        popUpNode!.addChild(playButtonNode)

        let stopButtonNode = StopButtonNode(imageNamed: "cross-button")
        stopButtonNode.isUserInteractionEnabled = true
        stopButtonNode.name = "stopButton"
        stopButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
        stopButtonNode.position = CGPoint(x:stopXOffest, y:0)
        stopButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        popUpNode!.addChild(stopButtonNode)

        let audioButtonNode = AudioButtonNode(imageNamed: "audio")
        audioButtonNode.isUserInteractionEnabled = true
        audioButtonNode.name = "audioButton"
        audioButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
        audioButtonNode.position = CGPoint(x:auidoXOffset, y:0)

        //QQQ Not sure need to set this z position
        audioButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        popUpNode!.addChild(audioButtonNode)
        
        
        let helpButtonNode = HelpButtonNode(imageNamed: "help")
        helpButtonNode.isUserInteractionEnabled = true
        helpButtonNode.name = "helpButton"
        helpButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
        helpButtonNode.position = CGPoint(x:helpXOffset, y:0)
        helpButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
        popUpNode!.addChild(helpButtonNode)
        
        if editModeEnabled{
            let editButtonNode = EditButtonNode(imageNamed: "edit-button")
            editButtonNode.isUserInteractionEnabled = true
            editButtonNode.name = "editButton"
            editButtonNode.size = CGSize(width:buttonSize, height: buttonSize)
            editButtonNode.position = CGPoint(x:editXOffset, y:0)
            editButtonNode.zPosition = GameLevelZPositions.popUpMenuButtonsZ
            popUpNode!.addChild(editButtonNode)
        }
        
        self.addChild(popUpNode!)

        messageLabelNode.displayFadingMessage("Paused", duration: 10.0)
    }

    //////////////
    // Gestures //
    //////////////
    
    func handleTap(_ sender:UITapGestureRecognizer){
        
        if sender.state == .ended {
            var touchLocation: CGPoint = sender.location(in: sender.view)
            touchLocation = self.convertPoint(fromView: touchLocation)
            
            if playing{
                pauseGame()
                setLowBackgroundMusicVolume()
                self.addChild(dimPanel)
            }
            
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
    
    
    func removeObstacleIfThere(_ squareCoords: SquareCoordinates){
        if let node = obstacleMap[squareCoords]{
            node.removeFromParent()
            gameLevelModel!.designInfo.obstacleMap.removeValue(forKey: squareCoords)
            obstacleMap[squareCoords] = nil
        }
    }
    
    func addObstacleIfNotThere(_ squareCoords: SquareCoordinates){
        let node = obstacleMap[squareCoords]
        if node == nil{
            createObstacleNode(squareCoords)
            gameLevelModel!.designInfo.obstacleMap[squareCoords] = ObstacleType.genericObstacle
        }
    }
    
    enum CurrentEditAction{
        case none
        case drawingObstacle    //still not known if Vert of Horz
        case drawingObstacleVert
        case drawingObstacleHorz
        case draggingOperator
        case draggingStart
        case draggingSink
    }

    ////////////////////////////////////////////////
    // Member variables associated with edit mode //
    ////////////////////////////////////////////////
    
    var currentEditAction = CurrentEditAction.none
    var currentDraggedOperator: Int! = nil
    var drawObstacleStartPos: SquareCoordinates! = nil
    var startSquareCoordsAddObstacle: SquareCoordinates? = nil

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !inEditMode{ return }
        
        ///////////////////////////
        // EDIT MODE MOVE EVENTS //
        ///////////////////////////

        let touch = touches.first!
        let positionInScene = touch.location(in: self)
        let squareCoords = squareOfPoint(Double(positionInScene.x), y: Double(positionInScene.y))

        switch currentEditAction{
        case CurrentEditAction.none:
            print("error with editing")//QQQQ handle this
        case CurrentEditAction.drawingObstacle:
            if squareCoords == startSquareCoordsAddObstacle{
                //still no movment out of box
                return
            }else{
                if squareCoords.values.sx != startSquareCoordsAddObstacle!.values.sx{
                    currentEditAction = CurrentEditAction.drawingObstacleHorz
                }else{
                    currentEditAction = CurrentEditAction.drawingObstacleVert
                }
            }
            startSquareCoordsAddObstacle = squareCoords
        case CurrentEditAction.drawingObstacleVert:
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
        case CurrentEditAction.drawingObstacleHorz:
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
        case CurrentEditAction.draggingOperator:
            operatorNodes[currentDraggedOperator]!.position = squareCoords.point()
            gameLevelModel!.designInfo.operatorLocations[currentDraggedOperator] = squareCoords

        case CurrentEditAction.draggingStart:
            if squareCoords != gameLevelModel!.designInfo.startLocation{
                playerNode.position = squareCoords.point()
                gameLevelModel!.designInfo.startLocation = squareCoords
            }

        case CurrentEditAction.draggingSink:
            if squareCoords != gameLevelModel!.designInfo.sinkLocation{
                sinkNode.position = squareCoords.point()
                gameLevelModel!.designInfo.sinkLocation = squareCoords
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //only relevant for editMode
        if !inEditMode{ return }
        
        currentEditAction = CurrentEditAction.none
        currentDraggedOperator = nil
        drawObstacleStartPos = nil
        startSquareCoordsAddObstacle = nil
        
        //QQQQ probably not handling multi-touch - but OK
    }
 
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //only relevant for editMode
        if !inEditMode{ return }

        let touch = touches.first!
        let positionInScene = touch.location(in: self)
        let squareCoords = squareOfPoint(Double(positionInScene.x), y: Double(positionInScene.y))

        for i in 0..<gameLevelModel!.designInfo.numOperators{
            if (operatorNodes[i]?.contains(positionInScene))!{
                currentEditAction = CurrentEditAction.draggingOperator
                currentDraggedOperator = i
                return
            }
        }
        
        if sinkNode.contains(positionInScene){
            currentEditAction = CurrentEditAction.draggingSink
            return
        }
        
        if playerNode.contains(positionInScene){
            currentEditAction = CurrentEditAction.draggingStart
            return
        }
        
        //else..
        currentEditAction = CurrentEditAction.drawingObstacle
        drawObstacleStartPos = squareOfPoint(positionInScene)
        startSquareCoordsAddObstacle = squareCoords
    }

    

    override func update(_ currentTime: TimeInterval) {
        self.currentTime = currentTime

        let almostDeadAction1 = SKAction.colorize(withColorBlendFactor: 1.0, duration: 0.25)
        let almostDeadAction2 = almostDeadAction1.reversed()
        let sequence = SKAction.sequence([almostDeadAction1, almostDeadAction2])
        
        if totalTilt <= 0.6 && centiSecondsPlayed > 500 && !tiltMessageDisplayed{
            tiltMessageDisplayed = true
            messageLabelNode.displayFadingMessage("Tilt device", duration: 4.0)
            GameAnalytics.addDesignEvent(withEventId: "tilt message level\(gameAppDelegate!.getLevel())")
        }
       
        if lifesNode.numLifes == 1{
            if playerNode.action(forKey: "playerAlmostDead") == nil{
                playerNode.run(SKAction.repeatForever(sequence), withKey: "playerAlmostDead")
//                playerNode.labelNode.fontColor = SKColor.red
//                playerNode.underline.fillColor = SKColor.red
            }
        }else{
            if playerNode.action(forKey: "playerAlmostDead") != nil{
                playerNode.removeAction(forKey: "playerAlmostDead")
                playerNode.run(almostDeadAction2) //take away color
//                playerNode.labelNode.fontColor = SKColor.white
//                playerNode.underline.fillColor = SKColor.white //return color QQQQ 
            }
        }

        
        /* Called before each frame is rendered */
        if finishingSteps > 0{
            finishingSteps = finishingSteps - 1
            let playerPos = playerNode.position
            let destPos = sinkNode.position
            playerNode.physicsBody!.applyForce(CGVector(dx: -2.5*(playerPos.x - destPos.x), dy: -2.5*(playerPos.y - destPos.y)))
            playerNode.physicsBody!.linearDamping = 0.2
            playerNode.physicsBody!.applyTorque(-0.01*playerNode.zRotation)
        }
    }
    
    
    //////////////////////////////////////
    // Internal Classes of Menu Buttons //
    //////////////////////////////////////
    
    class HelpButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! GameLevelScene).playButtonClick()
            (scene as! GameLevelScene).gameAppDelegate!.setReturnAppState(AppState.gameActionPaused)
            (scene as! GameLevelScene).gameAppDelegate!.changeView(AppState.instructionScene)
        }
    }
    class PlayButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! GameLevelScene).playButtonClick()
            (scene as! GameLevelScene).dimPanel.removeFromParent()
            (scene as! GameLevelScene).setHighBackgroundMusicVolume()
            (scene as! GameLevelScene).playGame()
        }
    }
    class StopButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! GameLevelScene).playTrashSound()
            //(scene as! GameLevelScene).finalizeSceneWithAbort()
            (scene as! GameLevelScene).moveToAfterLevelScene()
        }
    }
    class AudioButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            (scene as! GameLevelScene).playButtonClick()
            (scene as! GameLevelScene).toggleAudio()
            
            if GeneralScene.audioOff{
                (scene as! GameLevelScene).messageLabelNode.displayFadingMessage("Audio Off", duration: 2.0)
            }else{
                (scene as! GameLevelScene).messageLabelNode.displayFadingMessage("Audio On", duration: 2.0)
            }

        }
    }
    class EditButtonNode : SKSpriteNode{
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            if (scene as! GameLevelScene).inEditMode == false{
                (scene as! GameLevelScene).inEditMode = true
                
                (scene as! GameLevelScene).dimPanel.alpha = 0.1
                
                self.texture = SKTexture(imageNamed: "editOff")
                (scene as! GameLevelScene).popUpNode!.position = CGPoint(x: (scene as! GameLevelScene).popUpDesiredPosition.x, y: CGFloat(0.955*screenHeight))
                (scene as! GameLevelScene).messageLabelNode.displayFadingMessage("", duration: 1.0)
            }
            else{
                (scene as! GameLevelScene).inEditMode = false
                self.texture = SKTexture(imageNamed: "edit-button")
                (scene as! GameLevelScene).popUpNode!.position = (scene as! GameLevelScene).popUpDesiredPosition
                (scene as! GameLevelScene).messageLabelNode.displayFadingMessage("Edits saved", duration: 5.0)
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
                outputObstacleDict.write(toFile: obstacleFilePath, atomically: true)
                print("Wrote to \(obstacleFilePath)")
                
                /////////////////////////////
                // Write operators to file //
                /////////////////////////////
                
                var tempOperatorStringDict = Dictionary<String,String>()
                for i in 0..<(scene as! GameLevelScene).gameLevelModel!.designInfo.numOperators{
                    let location = (scene as! GameLevelScene).gameLevelModel!.designInfo.operatorLocations[i]
                    tempOperatorStringDict["\(i)"] = "(\(location!.values.sx),\(location!.values.sy))"
                }
                
                let outputOperatorDict = tempOperatorStringDict as NSDictionary
                let operatorFilePath = NSHomeDirectory() + "/Library/operators\((scene as! GameLevelScene).gameLevelModel!.levelNumber).plist"
                outputOperatorDict.write(toFile: operatorFilePath, atomically: true)
                print("Wrote to \(operatorFilePath)")
                
                ////////////////////////////////
                // Write startAndSink to file //
                ////////////////////////////////
                
                var tempStartAndSinkStringDict = Dictionary<String,String>()
                let sinkLocation = (scene as! GameLevelScene).gameLevelModel!.designInfo.sinkLocation
                let startLocation = (scene as! GameLevelScene).gameLevelModel!.designInfo.startLocation
                tempStartAndSinkStringDict["0"] = "(\(startLocation!.values.sx),\(startLocation!.values.sy))"     //currently "0" is start "1" is sink
                tempStartAndSinkStringDict["1"] = "(\(sinkLocation!.values.sx),\(sinkLocation!.values.sy))"
                
                let outputStartAndSinkDict = tempStartAndSinkStringDict as NSDictionary
                let startAndSinkFilePath = NSHomeDirectory() + "/Library/startAndSink\((scene as! GameLevelScene).gameLevelModel!.levelNumber).plist"
                outputStartAndSinkDict.write(toFile: startAndSinkFilePath, atomically: true)
                print("Wrote to \(startAndSinkFilePath)")

            }
        }
    }
    
    ////////////
    // Sounds //
    ///////////
    
    func playWallHit(_ impulse: Float){
        if GeneralScene.audioOff{
            return
        }
        let imp = impulse - 1
        if imp < 0{
            return
        }
        let temp = 0.02*imp //make these global constants
        let vol = temp < thumpTopVolume ? temp : thumpTopVolume
        if vol > 0.0{
            SKTAudio.sharedInstance().playSoundEffect(fromLabel: "wallHit", volume: vol)
        }
    }
    
}//end of class
