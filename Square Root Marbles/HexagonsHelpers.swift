//
//  HexagonsHelpers.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 4/09/2016.
//  Copyright © 2016 oneonepsilon. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

struct HexCoordinates: Hashable{
    let values : (q: Int,r: Int)
    
    var hashValue : Int {
        get {
            let (a,b) = values
            return a.hashValue &* 31 &+ b.hashValue
        }
    }
}

// comparison function for conforming to Equatable protocol
func ==(lhs: HexCoordinates, rhs: HexCoordinates) -> Bool {
    return lhs.values == rhs.values
}

func hexagonPointArray(cx:CGFloat,cy:CGFloat,radius:CGFloat)->[CGPoint] {
    let angleDelta = CGFloat(M_PI/3)
    let angleOffset = CGFloat(M_PI/6)
    var points = [CGPoint]()
    for i in 1...6 {
        let xpo = cx + radius * cos(angleDelta * CGFloat(i) - angleOffset)
        let ypo = cy + radius * sin(angleDelta * CGFloat(i) - angleOffset)
        points.append(CGPoint(x: xpo, y: ypo))
    }
    return points
}

func hexagonPath(cx:CGFloat, cy:CGFloat, radius:CGFloat) -> CGPath {
    let path = CGPathCreateMutable()
    let points = hexagonPointArray(cx, cy: cy,radius: radius)
    let cpg = points[0]
    CGPathMoveToPoint(path, nil, cpg.x, cpg.y)
    for p in points {
        CGPathAddLineToPoint(path, nil, p.x, p.y)
    }
    CGPathCloseSubpath(path)
    return path
}

func hexagonBezier(cx:CGFloat, cy:CGFloat, radius:CGFloat) -> UIBezierPath {
    let path = hexagonPath(cx, cy: cy, radius: radius)
    let bez = UIBezierPath(CGPath: path)
    bez.fill()
    return bez
}


//QQQQ This uses stuff from GraphicsConstants.swift, MAYBE ENCAPSULATE
//Using "Axial Coordinates with pointy top"
//See for example: http://www.redblobgames.com/grids/hexagons/  (somewhat modified what is there)
func pointOfHexagonCenter(q: Int, r: Int) -> CGPoint{
    let y  = centerPointY - hexSize * 1.5 * Double(r)
    let x  = centerPointX + hexSize * sqrt3 * (Double(q) + Double(r)/2 )
    return CGPoint(x: x,y: y)
}

func hexagonOfPoint(x: Double, y: Double) -> HexCoordinates{
    let centeredX = x - centerPointX
    let centeredY = -(y - centerPointY)
    let qRaw = (centeredX * sqrt3/3 - centeredY / 3) / hexSize
    let rRaw = centeredY * (2/3) / hexSize
    
    let cubeX = qRaw
    let cubeZ = rRaw
    let cubeY = -cubeX - cubeZ
    
    var rx = Int(round(cubeX))
    var ry = Int(round(cubeZ))
    var rz = Int(round(cubeY))
    
    let cubeXDiff = abs(Double(rx) - cubeX)
    let cubeYDiff = abs(Double(ry) - cubeY)
    let cubeZDiff = abs(Double(rz) - cubeZ)
    
    if (cubeXDiff > cubeYDiff && cubeXDiff > cubeZDiff){
        rx = -ry - rz
    }else if (cubeYDiff > cubeZDiff){
        ry = -rx - rz
    }else{
        rz = -rx - ry
    }
    
    return HexCoordinates(values: (rx,ry))
}


