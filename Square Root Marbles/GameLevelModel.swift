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
    
    static func centiSeconds(fromString: String) -> Int{
        let numArray = fromString.componentsSeparatedByString(".")
        let time = 100*Int(numArray[0])! + Int(numArray[1])! //QQQQ This is brave/stupid shit...
        return time
    }
    
    //QQQQ
    var bestScoreCentiSecond: Int{
        get{
            return bestScoreString == "" ? Int.max : GameLevelModel.centiSeconds(bestScoreString)
        }
    }

    var newScoreCentiSecond: Int{
        get{
            return newScoreString == "" ? Int.max : GameLevelModel.centiSeconds(newScoreString)
        }
    }

    
    init(level: Int){
        levelNumber = level
        designInfo = GameLevelDesignInfo(level: level)
        let defaults = NSUserDefaults.standardUserDefaults()
        if let bestScore = defaults.stringForKey("level\(level)best") {
            bestScoreString = bestScore
        }else{
            bestScoreString = ""
        }
        
        newScoreString = ""
    }
}