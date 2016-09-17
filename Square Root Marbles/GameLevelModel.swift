//
//  GameLevelModel.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright © 2016 oneonepsilon. All rights reserved.
//

import Foundation

//This class contains a representation of game level
//This includes: 
//              (1) The design of the level.
//              (2) The current playing information //QQQQ ended up not having that here (no MVC really)
//              (3) History of playing (e.g. high scores/played, not played etc...)
//QQQQ revisit above doc
class GameLevelModel{
    let levelNumber:    Int
    let designInfo: GameLevelDesignInfo
    
    var bestScoreString: String
    var newScoreString: String
    
    init(level: Int){
        levelNumber = level
        designInfo = GameLevelDesignInfo(level: level)
        bestScoreString = "" //QQQQ read from persistant memoery (property list whatever...)
        newScoreString = ""
    }
}