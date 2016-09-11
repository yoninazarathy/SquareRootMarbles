//
//  GraphicsConstants.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 4/09/2016.
//  Copyright © 2016 oneonepsilon. All rights reserved.
//

import Foundation


//Make true only for development purpuses
let editModeEnabled = true

let numLevels = 30

//QQQ Deal with this issue - but for now, fixed for Iphone 6/6s
let screenWidth: Double = 414
let screenHeight: Double = 736

let obstacleSize: Double = 20
let obstacleHeight = obstacleSize
let obstacleWidth = obstacleSize

let numObstaclesWidth: Int = Int(screenWidth/obstacleSize)+2
let numObstaclesHeight: Int = Int(screenHeight/obstacleSize)+2

let obstaclesXSpan: Int = numObstaclesWidth/2 + 1
let obstaclesYSpan: Int = numObstaclesHeight/2 + 1


let centerPointX: Double = screenWidth/2
let centerPointY: Double = screenHeight/2


let sqrt3 = 1.732050807568877 //QQQQ


//let numHexWidth: Int = 20

let hexSize: Double = 20

let timeInIntroScreen = 5.0

struct PhysicsCategory{
    static let  None        :   UInt32 = 0
    static let  All         :   UInt32 = UInt32.max
    static let  Balls       :   UInt32 = 0b1
    static let  Sqrt        :   UInt32 = 0b10
    static let  Squared     :   UInt32 = 0b100
    static let  Obstacle    :   UInt32 = 0b1000
    static let  Goal        :   UInt32 = 0b10000
}

enum AppState{
    case introScene
    case menuScene
    case gameActionPlaying
    case gameActionPaused
    case instructionScene
}

enum StageState{
    case preStart
    case squarePlaying
    case linePlaying
    case transitionSquareToLine
    case transitionLineToSquare
    case sqaureBouncingOverLineHoles
    case lineBouncingOverSquareHoles
    case lineInLineHoles
    case lineInSquareHoles
}

func sizeOfPlayNode(level: Int) -> Double{
    return 35 + 2.5*Double(level)
}
 