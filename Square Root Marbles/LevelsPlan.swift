//
//  LevelsPlan.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 12/09/2016.
//  Copyright © 2016 oneonepsilon. All rights reserved.
//

import Foundation


func goalOfLevel(_ level: Int) -> Int{
    return level //+ 1
}

func initValueOfLevel(_ level: Int)->Int{
    return level - 1
}

//I think it is assumed the last operator is Sqrt
let operatorLevelArray = [[],
["+1","sqrt"],
["+1","-1","sqrt"],
["+1", "-1", "-1", "+1","sqrt"],
["+1", "*2", "+1", "+1","sqrt"],
["+1", "+1", "*3", "-1", "-1", "+1","sqrt"],
["+1","-1", "+1", "*3", "-1", "+1","sqrt"],
["-1", "*2", "-1", "+1", "*2", "+1","sqrt"],
["*2", "+1", "+1", "+1", "+1","+1", "+1","sqrt"],
["*3", "+1", "+1", "-1", "-1", "*2", "+1","sqrt"],
["*4", "+1", "-1", "*2", "-1","-1","sqrt"],
["+1", "+1", "*4", "+1", "-1", "*2", "-1","sqrt"],
["-1", "-1", "-1", "*2", "+1", "+1","*2","sqrt"],
["*2", "+1", "+1", "-1", "*3", "-1", "-1","sqrt"],
["*3", "-1", "-1", "-1", "+1", "*2","sqrt"],
["-1","*4", "-1", "-1", "-1", "*2", "+1","sqrt"],
["+1", "*4", "*2", "+1", "+1", "-1", "-1","sqrt"],
["-1", "-1", "-1","*2", "-1", "*3", "+1", "+1","sqrt"],
["+1", "*2", "+1", "+1", "+1", "*2","sqrt"],
["-1", "*3", "-1", "-1", "*3","-1", "-1","sqrt"],
["-1", "-1", "-1", "*4", "+1", "*2", "+1", "+1","sqrt"],
["*4", "+1", "+1", "-1", "+1", "*2","+1","sqrt"],
["-1", "-1", "-1", "*2", "+1", "*3", "+1","sqrt"],
["+1", "+1", "+1", "*2", "-1", "*3", "+1","+1","sqrt"],
["-1", "-1", "*3", "+1", "*3", "+1", "-1","sqrt"],
["+1", "+1", "+1", "*3", "*3", "-1","-1","sqrt"],
["*4", "-1", "+1", "+1", "+1", "+1", "*2","sqrt"],
["-1", "-1", "*2", "+1", "+1", "+1","*3","sqrt"],
["-1", "-1", "*4", "+1", "-1", "*3", "-1", "-1","sqrt","sqrt"],
["-1", "*3", "+1", "-1", "*3", "+1", "+1","+1", "-1","sqrt"],
["-1", "-1", "+1", "*2", "+1", "+1", "*3", "+1", "+1","sqrt"] //30
];

