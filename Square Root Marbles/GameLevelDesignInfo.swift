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


class ActionOperator: Hashable, Equatable{
    let location: CGPoint
    
    var hashValue: Int {
        return location.x.hashValue << sizeof(CGFloat) ^ location.y.hashValue
    }
    
    init(location: CGPoint){
        self.location = location
    }

}

// comparison function for conforming to Equatable protocol
func ==(lhs: ActionOperator, rhs: ActionOperator) -> Bool {
    return lhs.location == rhs.location
}




enum ObstacleType{
    case noObstacle
    case genericObstacle
}

enum OperatorType{
    case squareRoot
    case squared
}

enum OperatorMode{
    case accepting
    case destroying
}

struct SinkInfo{
    let location: CGPoint
    
    init(location: CGPoint){
        self.location = location
    }
}

//QQQQ Not sure the Hashable, Equatable are implemented OK
struct OperatorInfo: Hashable, Equatable{
    let location: CGPoint
    let type: OperatorType
    
    var hashValue: Int {
        return location.x.hashValue << sizeof(CGFloat) ^ location.y.hashValue
    }
}

// comparison function for conforming to Equatable protocol
func ==(lhs: OperatorInfo, rhs: OperatorInfo) -> Bool {
    return lhs.location == rhs.location
}



//QQQQ? Class or Struct
//QQQQ? How to init the dictionary and set
class GameLevelDesignInfo{
    let levelNumber:    Int
    let startLocation:  CGPoint
    let sinkInfo:       SinkInfo
    var operators:      Set<OperatorInfo>
    var obstacleMap:    Dictionary<SquareCoordinates,ObstacleType>
    
    let ballsSquareImageName: String
    let ballsLineImageName: String
    
    init(level: Int){
        levelNumber = level
        
        startLocation = CGPoint(x: 150,y: 300)
        sinkInfo = SinkInfo(location: CGPoint(x:40,y:100))
        obstacleMap = Dictionary<SquareCoordinates,ObstacleType>()

        ballsSquareImageName = "ballsSquare\(level)"
        ballsLineImageName = "ballsLine\(level)"
        
        
        
        
        //QQQQ Update this
        //read from .plist file
        if let plist = Plist(name: "iphone6sBoundaryObstacle"){
            let dict = plist.getValuesInPlistFile()
            let separators = NSCharacterSet(charactersInString: "(,)")
            for (key, _) in dict!{
                var words =  key.componentsSeparatedByCharactersInSet(separators)
                obstacleMap[SquareCoordinates(values:(Int(words[1])!,Int(words[2])!))] = ObstacleType.genericObstacle
            }
        }else{
            //QQQQ Fatal error
        }
        
        let obstacleFilePath = NSHomeDirectory() + "/Library/obstacles\(levelNumber).plist"
        let readObstacleDict = NSDictionary(contentsOfFile: obstacleFilePath)
        if let dict = readObstacleDict{
            let separators = NSCharacterSet(charactersInString: "(,)")
            for (key, _) in dict{
                var words =  key.componentsSeparatedByCharactersInSet(separators)
                obstacleMap[SquareCoordinates(values:(Int(words[1])!,Int(words[2])!))] = ObstacleType.genericObstacle
            }
            print("Read obstacle file for level \(levelNumber)")
        }else{
            print("No obstacle file for level \(levelNumber)")
        }
        
        
        //Update initilization of operators
        //QQQQ Read these from somewhere
        operators = Set<OperatorInfo>()
        
        let operatorFilePath = NSHomeDirectory() + "/Library/operators\(levelNumber).plist"
        let readOperatorDict = NSDictionary(contentsOfFile: operatorFilePath)
        if let dict = readOperatorDict{
            let separators = NSCharacterSet(charactersInString: "(,)")
            for (key, val) in dict{
                var xyString =  key.componentsSeparatedByCharactersInSet(separators)
                let type = ((val as! String) == "squared") ? OperatorType.squared : OperatorType.squareRoot
                operators.insert(OperatorInfo(location: CGPoint(x:Double(xyString[1])!,y:Double(xyString[2])!),
                    type: type))
            }
            print("Read operator file for level \(levelNumber)")
        }else{
            print("No operator file for level \(levelNumber)")
            operators.insert(OperatorInfo(
                location: CGPoint(x: 100, y:500),
                type: OperatorType.squareRoot
                ))
            operators.insert(OperatorInfo(
                location: CGPoint(x: 200, y:150),
                type: OperatorType.squared
                ))
        }

        
    }
}