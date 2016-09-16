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

enum ObstacleType{
    case noObstacle
    case genericObstacle
}


let defaultOperatorLocations = [(75,600),(75,500),(75,400),(75,300),(75,200),(75,100),
                                (200,100),(200,200),(200,300),(200,400),(200,500),(200,600),
                                (225,600),(225,500),(225,400),(225,300),(225,200),(225,100)]

//QQQQ? Class or Struct
//QQQQ? How to init the dictionary and set
class GameLevelDesignInfo{
    let levelNumber:        Int
    var startLocation:      CGPoint! = nil
    var sinkLocation:       CGPoint! = nil
    
    var operatorLocations:  [CGPoint!]
    let operatorTypes:      [String]
    let numOperators:       Int
    
    var obstacleMap:        Dictionary<SquareCoordinates,ObstacleType>
    
    //QQQQ the fact that operators are hard coded global should be improved
    static func globalNumberOfOperators(level: Int)->Int{
        return operatorLevelArray[level].count
    }
    
    init(level: Int){
        levelNumber = level
        
        /////////////////////////
        // Read Start and Sink //
        /////////////////////////

        
        let startAndSinkFilePath = NSHomeDirectory() + "/Library/startAndSink\(levelNumber).plist"
        let readStartAndSinkDict = NSDictionary(contentsOfFile: startAndSinkFilePath)
        if let dict = readStartAndSinkDict{
            let separators = NSCharacterSet(charactersInString: "(,)")
            for (key, val) in dict{
                var words =  val.componentsSeparatedByCharactersInSet(separators)
                if (key as! NSString) == "0"{
                    startLocation = CGPoint(x: Double(words[1])!, y: Double(words[2])! )
                }else{
                    sinkLocation = CGPoint(x: Double(words[1])!, y: Double(words[2])! )
                }
            }
            print("Read startAndSink file for level \(levelNumber)")
        }else{
            print("No startAndSink file for level \(levelNumber)")
            startLocation = CGPoint(x: 50,y: 600)
            sinkLocation = CGPoint(x:300,y:60)
        }
        
        
        ////////////////////
        // Read Operators //
        ////////////////////
        
        //QQQQ maybe more elegant way to do this
        numOperators = GameLevelDesignInfo.globalNumberOfOperators(level)
        operatorLocations = Array(count: numOperators,repeatedValue: nil)
        
        //operator types are hard coded (not read from file)
        operatorTypes = operatorLevelArray[level]

        let operatorFilePath = NSHomeDirectory() + "/Library/operators\(levelNumber).plist"
        let readOperatorsDict = NSDictionary(contentsOfFile: operatorFilePath)
        if let dict = readOperatorsDict{
            let separators = NSCharacterSet(charactersInString: "(,)")
            var i = 0
            for (_, val) in dict{
                var words =  val.componentsSeparatedByCharactersInSet(separators)
                operatorLocations[i] = CGPoint(x: Double(words[1])!, y: Double(words[2])! )
                i = i + 1
            }
            print("Read operators file for level \(levelNumber)")
        }else{
            print("No operators file for level \(levelNumber)")
            for i in 0..<operatorLocations.count{
                let tup = defaultOperatorLocations[i]
                operatorLocations[i] = CGPoint(x: tup.0, y: tup.1 )
            }
        }

        
        
        
        ////////////////////
        // Read Obstacles //
        ////////////////////
        
        obstacleMap = Dictionary<SquareCoordinates,ObstacleType>()
        
        //QQQQ Update this
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
    }
}