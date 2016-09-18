//
//  GraphicsConstants.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 4/09/2016.
//  Copyright © 2016 oneonepsilon. All rights reserved.
//

import Foundation
import SpriteKit


//Make true only for development purpuses
let editModeEnabled = true
let allowAllLevels = true //also for development

///////////////
// Game Play //
///////////////

let perectSquares: [Int] = [0,1,4,9,16,25,36,49,64,81,100]

//Maximum value player can take
let maxVal = 100

let numLevels = 30

//QQQQ it is assumed there aren't more than that (static allocations)
let upperBoundNumOperators = 15

//QQQQ make naming common (scene/screen)
let timeInIntroScreen = 1.0
let timeInAfterLevelScene = 10.0

/////////////////
// Level World //
/////////////////

let numCubesWidth = 41
let numCubesHeight = 65
let minCubeX = -20
let maxCubeX = 20
let minCubeY = -32
let maxCubeY = 32

//width/height ration is .631
//in iPhone 5,5s,6,6s,6plus, it is around 0.562 
// hence there is more height and the width is the binding

let defaultStartLocation = SquareCoordinates(sx: -16,sy: -27)
let defaultSinkLocation =  SquareCoordinates(sx: 14,sy: 26)

/////////////////////////////////////////
// Mappping to Device Coordinate World //
/////////////////////////////////////////

//QQQ Deal with this issue - but for now, fixed for Iphone 6/6s
//Here is where screenSpecsFallIn.... QQQQ update.... QQQQ maybe need all these calcs in a setup module
let screenWidth: Double = 375
let screenHeight: Double = 667
let screenCenterPointX: Double = screenWidth/2
let screenCenterPointY: Double = screenHeight/2


let cubeSize: Double = screenWidth/Double(numCubesWidth)  //9.1464
let halfCubeSize = cubeSize/2

let offGameVerticalSpare = (screenHeight - cubeSize * Double(numCubesHeight))/2
let gameLevelCenterPointX = screenCenterPointX
let gameLevelCenterPointY = screenCenterPointY - offGameVerticalSpare



enum AppState{
    case introScene
    case menuScene
    case gameActionPlaying //QQQQ implement the state (playing/paused)
    case gameActionPaused
    case afterLevelScene
    case instructionScene
    case settingsScene
}



struct SquareCoordinates: Hashable{
    let values : (sx: Int,sy: Int)
    
    init(sx: Int, sy:Int){
        values.sx = sx
        values.sy = sy
    }
    
    var hashValue : Int {
        get {
            let (a,b) = values
            return a.hashValue &* 31 &+ b.hashValue
        }
    }
    
    func point() -> CGPoint{
        let x = gameLevelCenterPointX - halfCubeSize + Double(values.sx) * cubeSize
        let y = gameLevelCenterPointY - halfCubeSize + Double(values.sy) * cubeSize
        return CGPoint(x: x, y: y)
    }

    func rect() -> CGRect{
        return CGRect(origin: point(), size: CGSize(width: cubeSize,height: cubeSize))
    }
    
    //returns a set of 9 points including the current one and neighbours
    func NeighbourSquares() -> Set<SquareCoordinates> {
        var neighbours = Set<SquareCoordinates>()
        neighbours.insert(SquareCoordinates(sx: values.sx-1,sy:values.sy-1))
        neighbours.insert(SquareCoordinates(sx: values.sx-1,sy:values.sy))
        neighbours.insert(SquareCoordinates(sx: values.sx-1,sy:values.sy+1))
        neighbours.insert(SquareCoordinates(sx: values.sx,sy:values.sy-1))
        neighbours.insert(SquareCoordinates(sx: values.sx,sy:values.sy))
        neighbours.insert(SquareCoordinates(sx: values.sx,sy:values.sy+1))
        neighbours.insert(SquareCoordinates(sx: values.sx+1,sy:values.sy-1))
        neighbours.insert(SquareCoordinates(sx: values.sx+1,sy:values.sy))
        neighbours.insert(SquareCoordinates(sx: values.sx+1,sy:values.sy+1))
        return neighbours
    }
}

// comparison function for conforming to Equatable protocol
func ==(lhs: SquareCoordinates, rhs: SquareCoordinates) -> Bool {
    return lhs.values == rhs.values
}

func squareOfPoint(x: Double, y: Double) -> SquareCoordinates{
    let sx = Int(round((x-gameLevelCenterPointX + cubeSize)/cubeSize))-1
    let sy = Int(round((y-gameLevelCenterPointY + cubeSize)/cubeSize))-1
    return SquareCoordinates(sx: sx, sy: sy)
}

func squareOfPoint(point: CGPoint) -> SquareCoordinates{
    return squareOfPoint(Double(point.x), y: Double(point.y))
}



