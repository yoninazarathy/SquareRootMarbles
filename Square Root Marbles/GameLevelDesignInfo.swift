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


let defaultOperatorLocations = [(-7,27),(-7,18),(-7,9),(-7,0),(-7,-9),(-7,-18),
                                (0,-18),(0,-9),(0,0),(0,9),(0,18),(0,27),
                                (7,27),(7,18),(7,9),(7,0),(7,-9),(7,-18)]

//QQQQ? Class or Struct
//QQQQ? How to init the dictionary and set
class GameLevelDesignInfo{
    let levelNumber:        Int
    var startLocation:      SquareCoordinates! = nil
    var sinkLocation:       SquareCoordinates! = nil
    
    var operatorLocations:  [SquareCoordinates!]
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
        
        if let plist = Plist(name: "startAndSink\(levelNumber)"){
            let readStartAndSinkDict = plist.getValuesInPlistFile()
            if let dict = readStartAndSinkDict{
                let separators = NSCharacterSet(charactersInString: "(,)")
                for (key, val) in dict{
                    var words =  val.componentsSeparatedByCharactersInSet(separators)
                    let wrd1 = Int(words[1])!
                    let wrd2 = Int(words[2])!
                    if (key as! NSString) == "0"{
                        startLocation = SquareCoordinates(sx: wrd1, sy: wrd2 )
                    }else{
                        sinkLocation =  SquareCoordinates(sx: wrd1, sy: wrd2 )
                    }
                }
                print("Read startAndSink file for level \(levelNumber) from BUNDLE")
            }else{
                print("No BUNDLE startAndSink file for level \(levelNumber)")
                startLocation = defaultStartLocation
                sinkLocation = defaultSinkLocation
            }
        }else{
            let startAndSinkFilePath = NSHomeDirectory() + "/Library/startAndSink\(levelNumber).plist"
            let readStartAndSinkDict = NSDictionary(contentsOfFile: startAndSinkFilePath)
            if let dict = readStartAndSinkDict{
                let separators = NSCharacterSet(charactersInString: "(,)")
                for (key, val) in dict{
                    var words =  val.componentsSeparatedByCharactersInSet(separators)
                    let wrd1 = Int(words[1])!
                    let wrd2 = Int(words[2])!
                    if (key as! NSString) == "0"{
                        startLocation = SquareCoordinates(sx: wrd1, sy: wrd2 )
                    }else{
                        sinkLocation =  SquareCoordinates(sx: wrd1, sy: wrd2 )
                    }
                }
                print("Read startAndSink file for level \(levelNumber) from PHONE")
            }else{
                print("No PHONE startAndSink file for level \(levelNumber)")
                startLocation = defaultStartLocation
                sinkLocation = defaultSinkLocation
            }
        }
        
        
        ////////////////////
        // Read Operators //
        ////////////////////
        
        //QQQQ maybe more elegant way to do this
        numOperators = GameLevelDesignInfo.globalNumberOfOperators(level)
        operatorLocations = Array(count: numOperators,repeatedValue: nil)
        
        //operator types are hard coded (not read from file)
        operatorTypes = operatorLevelArray[level]

        if let plist = Plist(name: "operators\(levelNumber)"){
            let readOperatorsDict = plist.getValuesInPlistFile()
            if let dict = readOperatorsDict{
                let separators = NSCharacterSet(charactersInString: "(,)")
                var i = 0
                for (key, val) in dict{
                    var words =  val.componentsSeparatedByCharactersInSet(separators)
                    let wrd1 = Int(words[1])!
                    let wrd2 = Int(words[2])!
                    //QQQQ this is some scary casting and indexing without any check
                    operatorLocations[Int(String(key as! NSString))!] = SquareCoordinates(sx: wrd1, sy: wrd2 )
                    i = i + 1
                }
                print("Read operators file for level \(levelNumber) from BUNDLE")
            }else{
                print("No BUNDLE operators file for level \(levelNumber)")
                for i in 0..<operatorLocations.count{
                    let tup = defaultOperatorLocations[i]
                    operatorLocations[i] = SquareCoordinates(sx: tup.0, sy: tup.1 )
                }
            }
        }else{
            let operatorFilePath = NSHomeDirectory() + "/Library/operators\(levelNumber).plist"
            let readOperatorsDict = NSDictionary(contentsOfFile: operatorFilePath)
            if let dict = readOperatorsDict{
                let separators = NSCharacterSet(charactersInString: "(,)")
                var i = 0
                for (key, val) in dict{
                    var words =  val.componentsSeparatedByCharactersInSet(separators)
                    let wrd1 = Int(words[1])!
                    let wrd2 = Int(words[2])!
                    //QQQQ this is some scary casting and indexing without any check
                    operatorLocations[Int(String(key as! NSString))!] = SquareCoordinates(sx: wrd1, sy: wrd2 )
                    i = i + 1
                }
                print("Read operators file for level \(levelNumber) from PHONE")
            }else{
                print("No PHONE operators file for level \(levelNumber)")
                for i in 0..<operatorLocations.count{
                    let tup = defaultOperatorLocations[i]
                    operatorLocations[i] = SquareCoordinates(sx: tup.0, sy: tup.1 )
                }
            }
        }

        
        ///////////////////////////////
        // Read and Create Obstacles //
        ///////////////////////////////
        
        obstacleMap = Dictionary<SquareCoordinates,ObstacleType>()

        //make boundary
        var yc,xc: Int!
        for xc in minCubeX...maxCubeX{
            yc = minCubeY
            obstacleMap[SquareCoordinates(sx: xc, sy: yc)] = ObstacleType.genericObstacle
            yc = maxCubeY
            obstacleMap[SquareCoordinates(sx: xc, sy: yc)] = ObstacleType.genericObstacle
        }
        for yc in minCubeY...maxCubeY{
            xc = minCubeX
            obstacleMap[SquareCoordinates(sx: xc, sy: yc)] = ObstacleType.genericObstacle
            xc = maxCubeX
            obstacleMap[SquareCoordinates(sx: xc, sy: yc)] = ObstacleType.genericObstacle
        }
        
        //////////
        // Helpers for design only .... (horizontal and vertical grid)
        
        let makeHorzGrid = false
        let makeVertGrid = false
        
        if makeHorzGrid{
            for yc in minCubeY.stride(to: maxCubeY, by: 8){
                for xc in minCubeX...maxCubeX{
                    obstacleMap[SquareCoordinates(sx: xc, sy: yc)] = ObstacleType.genericObstacle
                }
            }
        }
        if makeVertGrid{
            for xc in minCubeX.stride(to: maxCubeX, by: 8){
                for yc in minCubeY...maxCubeY{
                    obstacleMap[SquareCoordinates(sx: xc, sy: yc)] = ObstacleType.genericObstacle
                }
            }
        }

        if let plist = Plist(name: "obstacles\(levelNumber)"){
            let readObstacleDict = plist.getValuesInPlistFile()
            if let dict = readObstacleDict{
                let separators = NSCharacterSet(charactersInString: "(,)")
                for (key, _) in dict{
                    var words =  key.componentsSeparatedByCharactersInSet(separators)
                    obstacleMap[SquareCoordinates(sx: Int(words[1])!, sy: Int(words[2])!)] = ObstacleType.genericObstacle
                }
                print("Read obstacle file for level \(levelNumber) from BUNDLE")
            }else{
                obstacleMap[SquareCoordinates(sx: 0,sy: 0)] = ObstacleType.genericObstacle
                print("No BUNDLE obstacle file for level \(levelNumber)")
            }
        }else{
            let obstacleFilePath = NSHomeDirectory() + "/Library/obstacles\(levelNumber).plist"
            let readObstacleDict = NSDictionary(contentsOfFile: obstacleFilePath)
            if let dict = readObstacleDict{
                let separators = NSCharacterSet(charactersInString: "(,)")
                for (key, _) in dict{
                    var words =  key.componentsSeparatedByCharactersInSet(separators)
                    obstacleMap[SquareCoordinates(sx: Int(words[1])!, sy: Int(words[2])!)] = ObstacleType.genericObstacle
                }
                print("Read obstacle file for level \(levelNumber) from PHONE")
            }else{
                obstacleMap[SquareCoordinates(sx: 0,sy: 0)] = ObstacleType.genericObstacle
                print("No PHONE obstacle file for level \(levelNumber)")
            }
        }
    }
}