//
//  MessageNode.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 17/09/2016.
//  Copyright © 2016 oneonepsilon. All rights reserved.
//

import Foundation
import SpriteKit

class MessageNode: SKLabelNode{

    func DisplayFadingMessage(text: String, duration: Double){
        self.text = text
        self.alpha = 1.0
        removeAllActions()
        runAction(SKAction.fadeAlphaTo(0, duration: duration))
    }
}
