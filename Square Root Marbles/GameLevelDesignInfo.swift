//
//  GameLevelDesignInfo.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright © 2016 oneonepsilon. All rights reserved.
//

import Foundation
import SpriteKit


extension CGPoint: Hashable {
    public var hashValue: Int {
        return self.x.hashValue << sizeof(CGFloat) ^ self.y.hashValue
    }
}


struct ObstacleInfo{
    
}

struct SinkInfo{
    let sinkLocation: CGPoint
    
    init(location: CGPoint){
        sinkLocation = location
    }
}


//QQQQ? Class or Struct
//QQQQ? How to init the dictionary and set
class GameLevelDesignInfo{
    let levelNumber:    Int
    let startLocation:  CGPoint
    let sinkInfo:       SinkInfo
    let locationsOfSquarers:        Set<CGPoint>? = nil
    let locationOfSquareRooters:    Set<CGPoint>? = nil
    let obstacleMap:                Dictionary<SquareCoordinates,ObstacleInfo>
    
    init(level: Int){
        levelNumber = level
        
        //QQQQ Read here from JSON File
        startLocation = CGPoint(x: 0,y: 0)
        sinkInfo = SinkInfo(location: CGPoint(x:0,y:0))
        obstacleMap = Dictionary<SquareCoordinates,ObstacleInfo>()
        
    }
}