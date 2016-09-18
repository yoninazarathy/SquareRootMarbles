//
//  OperatorNode.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 14/09/2016.
//  Copyright © 2016 oneonepsilon. All rights reserved.
//

import Foundation
import SpriteKit


protocol OperatorAction {
    //returns the operation or -1 if invalid
    //assumes it operates on value in [0,maxVal]
    func operate(value: Int) -> Int
    
    //returns a string describing the operation
    func operationString() -> String
    
    static func operationString() -> String
    
    //return true if operate(value) will not return -1
    func isValid(value: Int) -> Bool
}

class SqrtNode: OperatorAction{
    func operate(value: Int) -> Int{
        let val = sqrt(Double(value))
        if Double(Int(val)) == val{
            return Int(val)
        }else{
            return -1
        }
    }
    
    static func operationString() -> String{
        return "sqrt"
    }
    
    func operationString() -> String{return SqrtNode.operationString()}
    
    func isValid(value: Int) -> Bool{
        return perectSquares.contains(value)
    }
}

class MinusOneNode: OperatorAction{
    func operate(value: Int) -> Int{
        return value - 1
        //note if value is 0 it will go to -1
    }

    static func operationString() -> String{
        return "-1"
    }
    func operationString() -> String{return MinusOneNode.operationString()}
    func isValid(value: Int) -> Bool{
        return value > 0
    }

}

class AddOneNode: OperatorAction{
    func operate(value: Int) -> Int{
        let val = value + 1
        return val <= maxVal ? val : -1
    }
    static func operationString() -> String{
        return "+1"
    }
    func operationString() -> String{return AddOneNode.operationString()}
    func isValid(value: Int) -> Bool{
        return value < 100
    }
}

class Times2Node: OperatorAction{
    func operate(value: Int) -> Int{
        let val = 2*value
        return val <= maxVal ? val : -1
    }
    static func operationString() -> String{
        return "*2"
    }
    func operationString() -> String{return Times2Node.operationString()}

    func isValid(value: Int) -> Bool{
        return value < 51
    }
}

class Times3Node: OperatorAction{
    func operate(value: Int) -> Int{
        let val = 3*value
        return val <= maxVal ? val : -1
    }
    static func operationString() -> String{
        return "*3"
    }
    func operationString() -> String{return Times3Node.operationString()}
    func isValid(value: Int) -> Bool{
        return value < 34
    }
}

class Times4Node: OperatorAction{
    func operate(value: Int) -> Int{
        let val = 4*value
        return val <= maxVal ? val : -1
    }
    static func operationString() -> String{
        return "*4"
    }
    func operationString() -> String{return Times4Node.operationString()}
    func isValid(value: Int) -> Bool{
        return value < 26
    }
}

class Times5Node: OperatorAction{
    func operate(value: Int) -> Int{
        let val = 5*value
        return val <= maxVal ? val : -1
    }
    static func operationString() -> String{
        return "*5"
    }
    func operationString() -> String{return Times5Node.operationString()}
    func isValid(value: Int) -> Bool{
        return value < 21
    }
}


class OperatorNode: SKSpriteNode{
    
    var operatorAction: OperatorAction!
    
    var valid: Bool! = nil
    
    var active: Bool = true
    
    var angleToFire: CGFloat = CGFloat(M_PI/2)
    
    func setAsValid(){
        valid = true
        color = SKColor(CIColor: CIColor(red: 0.0, green: 1.0, blue: 0.0))
        colorBlendFactor = 1
        alpha = 1.0
    }
    
    func setAsInvalid(){
        valid = false
        color = SKColor.redColor()
        colorBlendFactor = 1
        alpha = 1.0

    }
    
    override init(texture: SKTexture!,
                  color: UIColor,
                  size: CGSize){
        operatorAction = nil
        super.init(texture: texture,color: color, size: size)
        
    }
    
    func persistentSummary() -> String{
        return "(\(self.position.x),\(self.position.y),\(self.operatorAction.operationString()))"
    }
    
    convenience init(operatorActionString: String){
        self.init(texture: nil, color: SKColor.redColor(), size: CGSize(width:50, height:50))
        switch operatorActionString{
        case SqrtNode.operationString():
            operatorAction = SqrtNode()
            self.texture = SKTexture(imageNamed:"sqrt") //QQQQ
        case MinusOneNode.operationString():
            operatorAction = MinusOneNode()
            self.texture = SKTexture(imageNamed:"minus1") //QQQQ
        case AddOneNode.operationString():
            operatorAction = AddOneNode()
            self.texture = SKTexture(imageNamed:"plus1")
        case Times2Node.operationString():
            operatorAction = Times2Node()
            self.texture = SKTexture(imageNamed:"times2") //QQQQ
        case Times3Node.operationString():
            operatorAction = Times3Node()
            self.texture = SKTexture(imageNamed:"times3") //QQQQ
        case Times4Node.operationString():
            operatorAction = Times4Node()
            self.texture = SKTexture(imageNamed:"times4") //QQQQ
        case Times5Node.operationString():
            operatorAction = Times5Node()
            self.texture = SKTexture(imageNamed:"times5") //QQQQ
        default:
            break //QQQQ error
        }
        self.name = operatorActionString
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Decoding length here would be nice...
        operatorAction = nil //QQQQ why is this initilizor even here?
        super.init(coder: aDecoder)
    }
}


