//
//  IntroScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit

class IntroScene: GeneralScene {
    
    var timer: Timer? = nil
    
    override func didMove(to view: SKView) {
        //QQQQ problem if clicked before - need to kill timer
        timer = Timer.scheduledTimer(timeInterval: timeInIntroScreen, target: self, selector: #selector(timerExpired), userInfo: nil, repeats: false)
        playBackgroundMusic()
        setHighBackgroundMusicVolume()
    }
    
    func timerExpired(){
        setLowBackgroundMusicVolume()
        gameAppDelegate!.changeView(AppState.menuScene)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        timer!.invalidate()
        setLowBackgroundMusicVolume()
        gameAppDelegate!.changeView(AppState.menuScene)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
