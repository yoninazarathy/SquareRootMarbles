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
    func changeView(newState: AppState)
    func setLevel(newLevel: Int)
    func getLevel() -> Int
    func toggleMute()
    func isMuted() -> Bool
    func getGameLevelModel(level: Int) -> GameLevelModel!
}

class GeneralScene: SKScene {
    var gameAppDelegate: GameAppDelegate?
}


class GameViewController: UIViewController, GameAppDelegate {

    var appState:   AppState    = AppState.introScene
    var currentlevel: Int?      = nil
    var muted: Bool             = false
    
    var gameLevelModels: [GameLevelModel!] = Array(count: numLevels+1, repeatedValue: nil)
    
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
    
    func getGameLevelModel(level: Int) -> GameLevelModel!{
        return gameLevelModels[level]
    }

    var currentGameScene: SKScene? = nil
    
    func setLevel(newLevel: Int){
        currentlevel = newLevel
    }

    func changeView(newState: AppState){
        appState = newState

        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        //QQQQ factor out common code here...
        switch appState{
            case AppState.introScene:
                //QQQQ? Don't know what to do if this fails
                if let currentGameScene = IntroScene(fileNamed:"IntroScene") {
                    /* Set the scale mode to scale to fit the window */
                    currentGameScene.scaleMode = .AspectFill
                    currentGameScene.gameAppDelegate = self
                    skView.presentScene(currentGameScene)
                }
            case AppState.menuScene:
                //QQQQ? Don't know what to do if this fails
                if let currentGameScene = MenuScene(fileNamed:"MenuScene") {
                    /* Set the scale mode to scale to fit the window */
                    currentGameScene.scaleMode = .AspectFill
                    currentGameScene.gameAppDelegate = self
                    skView.presentScene(currentGameScene)
                }
            case AppState.gameActionPlaying:                
                //QQQQ? Don't know what to do if this fails
                if let currentGameScene = GameLevelScene(fileNamed:"GameLevelScene") {
                    /* Set the scale mode to scale to fit the window */
                    currentGameScene.scaleMode = .AspectFill
                    currentGameScene.gameAppDelegate = self
                    skView.presentScene(currentGameScene)
                }
            case AppState.gameActionPaused:
                //QQQQ? Don't know what to do if this fails
                
                //QQQQ Need to "resume game"
                if let currentGameScene = GameLevelScene(fileNamed:"GameLevelScene") {
                    /* Set the scale mode to scale to fit the window */
                    currentGameScene.scaleMode = .AspectFill
                    currentGameScene.gameAppDelegate = self
                    skView.presentScene(currentGameScene)
                }
            case AppState.instructionScene:
                //QQQQ? Don't know what to do if this fails
                if let currentGameScene = InstructionsScene(fileNamed:"InstructionsScene") {
                    /* Set the scale mode to scale to fit the window */
                    currentGameScene.scaleMode = .AspectFill
                    currentGameScene.gameAppDelegate = self
                    skView.presentScene(currentGameScene)
                }
            case AppState.afterLevelScene:
                //QQQQ? Don't know what to do if this fails
                if let currentGameScene = InstructionsScene(fileNamed:"AfterLevelScene") {
                    /* Set the scale mode to scale to fit the window */
                    currentGameScene.scaleMode = .AspectFill
                    currentGameScene.gameAppDelegate = self
                    skView.presentScene(currentGameScene)
            }            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 1...numLevels{
            gameLevelModels[i] = GameLevelModel(level: i)
        }
        changeView(AppState.introScene)
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown //QQQQ????
        } else {
            return .All  //QQQQ ????
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit{
        //print("deinit of GameViewController")
    }
}
