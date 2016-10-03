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

enum AppState{
    case introScene
    case menuScene
    case gameActionPlaying //QQQQ implement the state (playing/paused)
    case gameActionPaused
    case afterLevelSceneFinished //the after level scene 
    case afterLevelSceneBreak
    case victoryScene
    case instructionScene
    case settingsScene
}



protocol GameAppDelegate{
    func changeView(_ newState: AppState)
    func getAppState() -> AppState
    func setLevel(_ newLevel: Int)
    func getLevel() -> Int
    func getGameLevelModel(_ level: Int) -> GameLevelModel
    
    //used when going (for e.g.) to instructions - need to know if to return to game or to menu...
    func getReturnAppState() -> AppState!
    func setReturnAppState(_ returnState: AppState)
    
    func recordOperation(op: String, oldValue: Int, newValue: Int)
    func clearOperationLog()
    func getOperationLog() -> [(String,Int,Int)]
}

class GeneralScene: SKScene {
    var gameAppDelegate: GameAppDelegate?
    
    static var audioOff: Bool = false
    
    func initAudio(){
        let defaults = UserDefaults.standard
        GeneralScene.audioOff = defaults.bool(forKey: "audioOff")
        defaults.set(GeneralScene.audioOff, forKey: "audioOff")
    }
    
    func toggleAudio(){
        if GeneralScene.audioOff{
            GeneralScene.audioOff = false
            playBackgroundMusic()
        }else{
            GeneralScene.audioOff = true
            stopBackgroundMusic()
        }
        
        let defaults = UserDefaults.standard
        defaults.set(GeneralScene.audioOff, forKey: "audioOff")
        
        //Log to Game Analytics
        if GeneralScene.audioOff{
            GameAnalytics.addDesignEvent(withEventId: "audioOff")
        }else{
            GameAnalytics.addDesignEvent(withEventId: "audioOn")
        }
    }
    
    func playBackgroundMusic() {
        if !SKTAudio.playingMusic && !GeneralScene.audioOff{
            SKTAudio.sharedInstance().playBackgroundMusic("136_full_efficiency_0159.mp3",volume: musicVolume ) // Start the music
            SKTAudio.playingMusic = true
        }
    }
    
    func setLowBackgroundMusicVolume(){
        SKTAudio.sharedInstance().setLowBackgroundMusicVolume()
    }
    
    func setHighBackgroundMusicVolume(){
        SKTAudio.sharedInstance().setHighBackgroundMusicVolume()
    }
    
    func stopBackgroundMusic(){
        SKTAudio.sharedInstance().pauseBackgroundMusic() // Pause the music
        SKTAudio.playingMusic = false
    }
    
    
    func playButtonClick(){
        if !GeneralScene.audioOff{
            SKTAudio.sharedInstance().playSoundEffect(fromLabel: "buttonClick", volume: 0.7)
        }
    }
    
    func playTrashSound(){
        if !GeneralScene.audioOff{
            SKTAudio.sharedInstance().playSoundEffect(fromLabel: "trash", volume: 0.7)
        }
    }
    
    func playOperatorSound(){
        if !GeneralScene.audioOff{
            SKTAudio.sharedInstance().playSoundEffect(fromLabel: "mathOperator", volume: 0.7)
        }        
    }
    
    func playBadNodeTouchSound(){
        if !GeneralScene.audioOff{
            SKTAudio.sharedInstance().playSoundEffect(fromLabel: "touchBadNode", volume: 0.7)
        }
    }
    
    func playWinSound(){
        if !GeneralScene.audioOff{
            SKTAudio.sharedInstance().playSoundEffect(fromLabel: "gotLevel", volume: 0.8)
        }
    }

    func playDieSound(){
        if !GeneralScene.audioOff{
            SKTAudio.sharedInstance().playSoundEffect(fromLabel: "die", volume: 0.8)
        }
    }
    

    let topList = [40, 43, 45, 10, 18, 17, 28, 32, 33]
    let goodList = [1, 2 , 4, 6, 9 , 11, 12 , 13, 16,  23, 26, 27,  32, 34, 36, 37,38, 39, 44, 46 , 48, 51]
    let okList = [3,5 ,7 , 8 , 14 , 15, 19, 20, 21, 22, 24, 25, 29, 30, 31, 35, 41, 42, 47, 49, 50]

    
    func playRandomSRM(){
        if !GeneralScene.audioOff{
            let firstRoll = arc4random_uniform(10) + 1
            var track: Int
            if (5 <= firstRoll ) {
                track = topList[Int(arc4random_uniform(UInt32(topList.count)))]
            }else if 2 <= firstRoll {
                track = goodList[Int(arc4random_uniform(UInt32(goodList.count)))]
            }else{
                track = okList[Int(arc4random_uniform(UInt32(goodList.count)))]
            }
            
            SKTAudio.sharedInstance().playSRM(num: track, volume: srmVoiceVolume)
        }
    }
}


class GameViewController: UIViewController, GameAppDelegate {

    var appState:   AppState    = AppState.introScene
    var currentlevel: Int?      = nil
    
    var gameLevelModels: [GameLevelModel?] = Array(repeating: nil, count: numLevels+1)
    
    var returnAppState: AppState! = nil

    var operationLog: [(String,Int,Int)] = []
    
    func recordOperation(op: String, oldValue: Int, newValue: Int){
        operationLog.append((op,oldValue,newValue))
    }
    
    func clearOperationLog(){
        operationLog.removeAll()
    }
    
    func getOperationLog() -> [(String,Int,Int)]{
        return operationLog
    }

    
    func getReturnAppState() -> AppState!{
            return returnAppState
    }
    
    func setReturnAppState(_ returnState: AppState){
        returnAppState = returnState
    }
    
    func getLevel() -> Int{
        return currentlevel!
    }
    
    func getGameLevelModel(_ level: Int) -> GameLevelModel{
        return gameLevelModels[level]!
    }
    
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
                    currentGameScene.initAudio()
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
                    skView.scene!.removeAllChildren() //QQQQ not clear why this is needed here (to remove menu boxes)
                    //it was after using SKTransition...
                    //I have sussupected SKAudioNode and NSTimer
                    //QQQQ irrespective of this, need to remove NSTimer

                    skView.presentScene(currentGameScene, transition: transitionSlow)
                }
            case AppState.afterLevelSceneFinished:
                //QQQQ? Don't know what to do if this fails
                if let currentGameScene = AfterLevelScene(fileNamed:"AfterLevelScene") {
                    /* Set the scale mode to scale to fit the window */
                    currentGameScene.scaleMode = .aspectFill
                    currentGameScene.gameAppDelegate = self
                    skView.presentScene(currentGameScene, transition: transitionSlow)
            }
            case AppState.afterLevelSceneBreak: //QQQQ this clause just as above (merge)
            //QQQQ? Don't know what to do if this fails
            if let currentGameScene = AfterLevelScene(fileNamed:"AfterLevelScene") {
                /* Set the scale mode to scale to fit the window */
                currentGameScene.scaleMode = .aspectFill
                currentGameScene.gameAppDelegate = self
                skView.presentScene(currentGameScene, transition: transitionSlow)
            }

            
            case AppState.victoryScene:
            //QQQQ? Don't know what to do if this fails
                if let currentGameScene = VictoryScene(fileNamed:"VictoryScene") {
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
                    skView.scene!.removeAllChildren() //QQQQ not clear why this is needed here (to remove menu boxes)
                    //it was after using SKTransition...
                    //I have sussupected SKAudioNode and NSTimer
                    //QQQQ irrespective of this, need to remove NSTimer
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
}
