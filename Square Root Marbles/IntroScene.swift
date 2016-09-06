//
//  IntroScene.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 2/09/2016.
//  Copyright (c) 2016 oneonepsilon. All rights reserved.
//

import SpriteKit

class IntroScene: SKScene {
    
    var obstacleMap = Dictionary<HexCoordinates,SKShapeNode>()
    
    func createObstacleNode(q: Int, r: Int) -> SKShapeNode{
        let path = hexagonPath(0, cy: 0, radius: CGFloat(hexSize))
        let node = SKShapeNode(path: path)
        node.position = pointOfHexagonCenter(q, r: r)
        node.fillColor = SKColor.blueColor()
        node.strokeColor = SKColor.redColor()
        node.lineWidth = 0
        return node
    }
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor.blackColor()
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let hexCoords = hexagonOfPoint(Double(location.x), y: Double(location.y))
            
            var node = obstacleMap[hexCoords]
            if node == nil{
                node = createObstacleNode(hexCoords.values.q, r: hexCoords.values.r)
                node!.fillColor = SKColor.whiteColor()
                obstacleMap[hexCoords] = node
                self.addChild(node!)
            }else{
                //node!.fillColor = SKColor.blackColor()
                node?.removeFromParent()
                obstacleMap[hexCoords] = nil
            }
            
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
