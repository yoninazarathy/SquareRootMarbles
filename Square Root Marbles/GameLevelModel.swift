//
//  GameLevelModel.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright © 2016 oneonepsilon. All rights reserved.
//

import Foundation

enum BallsState{
    case line
    case square
}

//This class contains a representation of game level
//This includes: 
//              (1) The design of the level.
//              (2) The current playing information 
//              (3) History of playing (e.g. high scores/played, not played etc...)
class GameLevelModel{
    let levelNumber:    Int
    let designInfo: GameLevelDesignInfo
    
    var ballsState: BallsState
    
    init(level: Int){
        levelNumber = level
        designInfo = GameLevelDesignInfo(level: level)
        ballsState = BallsState.square //QQQQ maybe want to start as line sometimes
    }
}