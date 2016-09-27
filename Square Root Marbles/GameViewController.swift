//
//  GameViewController.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

let motionManager = CMMotionManager()

protocol GameAppDelegate{
    func changeView(_ newState: AppState)
    func getAppState() -> AppState
    func setLevel(_ newLevel: Int)
    func getLevel() -> Int
    func toggleMute()
    func isMuted() -> Bool
    func getGameLevelModel(_ level: Int) -> GameLevelModel
    
    //used when going (for e.g.) to instructions - need to know if to return to game or to menu...
    func getReturnAppState() -> AppState!
    func setReturnAppState(_ returnState: AppState)
    
    //QQQQ The "X" is because of some objective c stuff
    func getNumberOfMarblesX() -> Int
    func setNumberOfMarblesX(_ number: Int)
    func incrementNumberOfMarbles(_ byNumber: Int)
    func incrementNumberOfMarbles()
    func decrementNumberOfMarbles(_ byNumber: Int)
    func decrementNumberOfMarbles()
}

class GeneralScene: SKScene {
    var gameAppDelegate: GameAppDelegate?
    
    static var playingMusic: Bool = false
    
//    var backgroundMusic: SKAudioNode! = nil
    
    func playBackgroundMusic() {
//        if backgroundMusic != nil {
//            backgroundMusic.removeFromParent()
//        }
//        
//        let temp = SKAudioNode(fileNamed: "136_full_efficiency_0159.mp3")
//        temp.autoplayLooped = true
//        backgroundMusic = temp
//        //backgroundMusic = SKAudioNode(fileNamed: "SpaceGame.caf")
//        //backgroundMusic.autoplayLooped = true
//        //addChild(backgroundMusic)
//        addChild(backgroundMusic)
        if !GeneralScene.playingMusic{
            SKTAudio.sharedInstance().playBackgroundMusic("136_full_efficiency_0159.mp3",volume: musicVolume ) // Start the music
            GeneralScene.playingMusic = true
        }
    }
    
    func stopBackgroundMusic(){
//        if let bm = backgroundMusic{
//            bm.removeFromParent()
//        }
        SKTAudio.sharedInstance().pauseBackgroundMusic() // Pause the music
        GeneralScene.playingMusic = false
    }
    
    //    let numSRMVoices: UInt32 = 22
    //    let musicVolume: Float = 0.6
    //    let endGameVolume: Float = 0.5
    //    let thumpTopVolume: Float = 0.6
    //    let srmVoiceVolume: Float = 1.0
    //    let operatorVolume: Float = 0.5
    
    //QQQQ
    
    func playRandomSRM(){
        let diceRoll = arc4random_uniform(numSRMVoices) + 1
        SKTAudio.sharedInstance().playSoundEffect("srm_\(diceRoll).mp3", volume: srmVoiceVolume)
    }
    
    func playWallHit(_ impulse: Float){
        let temp = 0.005*(impulse - 6) //make these global constants
        let vol = temp < thumpTopVolume ? temp : thumpTopVolume
        SKTAudio.sharedInstance().playSoundEffect("knock.wav", volume: vol)
    }

}


class GameViewController: UIViewController, GameAppDelegate {

    var appState:   AppState    = AppState.introScene
    var currentlevel: Int?      = nil
    var muted: Bool             = false
    
    var numberOfMarbles: Int    = 0
    
    func getNumberOfMarblesX() -> Int{
        return numberOfMarbles
    }
    
    func setNumberOfMarblesX(_ number: Int){
        numberOfMarbles = number
    }
    
    func incrementNumberOfMarbles(_ byNumber: Int){
        numberOfMarbles += byNumber
    }
    
    func incrementNumberOfMarbles(){
        numberOfMarbles += 1
    }
    
    func decrementNumberOfMarbles(_ byNumber: Int){
        numberOfMarbles -= byNumber
    }
    
    func decrementNumberOfMarbles(){
        numberOfMarbles -= 1
    }

    var gameLevelModels: [GameLevelModel?] = Array(repeating: nil, count: numLevels+1)
    
    var returnAppState: AppState! = nil
    
    func getReturnAppState() -> AppState!{
            return returnAppState
    }
    
    func setReturnAppState(_ returnState: AppState){
        returnAppState = returnState
    }
    
    func toggleMute(){
        muted = !muted
    }
    
    func unMute(){
        muted = false
    }
    
    func isMuted() -> Bool{
        return muted
    }
    
    func getLevel() -> Int{
        return currentlevel!
    }
    
    func getGameLevelModel(_ level: Int) -> GameLevelModel{
        return gameLevelModels[level]!
    }

 //   var currentGameScene: SKScene? = nil
    
    func setLevel(_ newLevel: Int){
        currentlevel = newLevel
    }
    
    func getAppState() -> AppState{
        return appState
    }

    func changeView(_ newState: AppState){
        appState = newState

        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = showFPSFlag
        skView.showsNodeCount = showNodCountFlag
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        let transitionSlow = SKTransition.crossFade(withDuration: 0.8)
        let transitionFast = SKTransition.crossFade(withDuration: 0.3)
       // transition.pausesOutgoingScene = true
        
        //QQQQ factor out common code here...
        switch appState{
            case AppState.introScene:
                //QQQQ? Don't know what to do if this fails
                if let currentGameScene = IntroScene(fileNamed:"IntroScene") {
                    /* Set the scale mode to scale to fit the window */
                    currentGameScene.scaleMode = .aspectFill
                    currentGameScene.gameAppDelegate = self
                    skView.presentScene(currentGameScene, transition: transitionSlow)
                }
            case AppState.menuScene:
                //QQQQ? Don't know what to do if this fails
                if let currentGameScene = MenuScene(fileNamed:"MenuScene") {
                    /* Set the scale mode to scale to fit the window */
                    currentGameScene.scaleMode = .aspectFill
                    currentGameScene.gameAppDelegate = self
                    skView.presentScene(currentGameScene, transition: transitionFast)
                }
            case AppState.gameActionPlaying:                
                //QQQQ? Don't know what to do if this fails
                if let currentGameScene = GameLevelScene(fileNamed:"GameLevelScene") {
                    /* Set the scale mode to scale to fit the window */
                    currentGameScene.scaleMode = .aspectFill
                    currentGameScene.gameAppDelegate = self
                    skView.scene!.removeAllChildren() //QQQQ not clear why this is needed here (to remove menu boxes)
                                                        //it was after using SKTransition...
                                                        //I have sussupected SKAudioNode and NSTimer 
                                                        //QQQQ irrespective of this, need to remove NSTimer
                    skView.presentScene(currentGameScene, transition: transitionFast)
                }
            case AppState.gameActionPaused:
                //QQQQ? Don't know what to do if this fails
                
                //QQQQ Need to "resume game" (currently restarting game in paused mode)
                if let currentGameScene = GameLevelScene(fileNamed:"GameLevelScene") {
                    /* Set the scale mode to scale to fit the window */
                    currentGameScene.scaleMode = .aspectFill
                    currentGameScene.gameAppDelegate = self
                    skView.presentScene(currentGameScene, transition: transitionSlow)
                }
            case AppState.instructionScene:
                //QQQQ? Don't know what to do if this fails
                if let currentGameScene = InstructionsScene(fileNamed:"InstructionsScene") {
                    /* Set the scale mode to scale to fit the window */
                    currentGameScene.scaleMode = .aspectFill
                    currentGameScene.gameAppDelegate = self
                    skView.presentScene(currentGameScene, transition: transitionSlow)
                }
            case AppState.afterLevelScene:
                //QQQQ? Don't know what to do if this fails
                if let currentGameScene = AfterLevelScene(fileNamed:"AfterLevelScene") {
                    /* Set the scale mode to scale to fit the window */
                    currentGameScene.scaleMode = .aspectFill
                    currentGameScene.gameAppDelegate = self
                    skView.presentScene(currentGameScene, transition: transitionSlow)
            }
            case AppState.settingsScene:
                //QQQQ? Don't know what to do if this fails
                if let currentGameScene = SettingsScene(fileNamed:"SettingsScene") {
                /* Set the scale mode to scale to fit the window */
                currentGameScene.scaleMode = .aspectFill
                currentGameScene.gameAppDelegate = self
                skView.presentScene(currentGameScene, transition: transitionFast)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true

        
        for i in 1...numLevels{
            gameLevelModels[i] = GameLevelModel(level: i)
        }
        changeView(AppState.introScene)
    }

    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown //QQQQ????
        } else {
            return .all  //QQQQ ????
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    deinit{
        //print("deinit of GameViewController")
    }
}
