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

//QQQQ it is assumed there aren't more than that (static allocations)
let upperBoundNumOperators = 15

let sqrt3 = 1.732050807568877 //QQQQ


let perectSquares: [Int] = [0,1,4,9,16,25,36,49,64,81,100]

//Maximum value player can take
let maxVal = 100

//let numHexWidth: Int = 20

let hexSize: Double = 20

let timeInIntroScreen = 5.0

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




struct SquareCoordinates: Hashable{
    let values : (sx: Int,sy: Int)
    
    var hashValue : Int {
        get {
            let (a,b) = values
            return a.hashValue &* 31 &+ b.hashValue
        }
    }
    
    func rect() -> CGRect{
        let x = centerPointX + Double(values.sx) * obstacleWidth
        let y = centerPointY + Double(values.sy) * obstacleHeight
        return CGRect(origin: CGPoint(x: x,y: y), size: CGSize(width: obstacleWidth,height: obstacleHeight))
    }
}

// comparison function for conforming to Equatable protocol
func ==(lhs: SquareCoordinates, rhs: SquareCoordinates) -> Bool {
    return lhs.values == rhs.values
}



func squareOfPoint(x: Double, y: Double) -> SquareCoordinates{
    let sx = Int(round((x-centerPointX+obstacleWidth/2)/obstacleWidth))-1
    let sy = Int(round((y-centerPointY+obstacleHeight/2)/obstacleHeight))-1
    return SquareCoordinates(values: (sx, sy))
}



