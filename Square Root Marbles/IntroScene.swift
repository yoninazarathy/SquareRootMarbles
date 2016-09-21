//
//  IntroScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit

class IntroScene: GeneralScene {
    
    var timer: NSTimer? = nil
    
    override func didMoveToView(view: SKView) {
        //QQQQ problem if clicked before - need to kill timer
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInIntroScreen, target: self, selector: #selector(timerExpired), userInfo: nil, repeats: false)
        playBackgroundMusic()
    }
    
    func timerExpired(){
        stopBackgroundMusic()
        gameAppDelegate!.changeView(AppState.menuScene)
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        timer!.invalidate()
        stopBackgroundMusic()
        gameAppDelegate!.changeView(AppState.menuScene)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
