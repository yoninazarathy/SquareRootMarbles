//
//  LevelsPlan.swift
//  Square Root Marbles
//
//  Created by Yoni Nazarathy on 12/09/2016.
//  Copyright © 2016 oneonepsilon. All rights reserved.
//

import Foundation


//Operators: -1, +1, *2, *3, *4, *5, sqrt

/*
sqrt(1) = 1
1 - start: 1, goal: 1, operators: none                          //objective: no square root, learn controls             //sequential maze
2 - start: 2, goal: 1, operators: -1, +1, -1                    //objective: no square root, learn +/- operator action  //sequential maze
3 - start: 3, goal: 1, operators: +1, sqrt, -1                  //objective: square root of 4                           //sequential maze

sqrt(4) = 2
4 - start: 4, goal: 2, operators: -1, -1, -1, sqrt, +1              //objetive: square root of 1                        //sequential maze
5 - start: 5, goal: 2, operators: +1, +1, -1, +1, +1,+1, sqrt, -1   //objective: square root of 9                       //sequential maze
6 - start: 6, goal: 2, operators: -1, -1, -1, +1, sqrt              //objective: square root of 4                       //open plan

sqrt(9) = 3
7 - start: 7, goal: 3, operators: +1, +1, sqrt, -1, -1, sqrt, +1, +1    //objective: square root of 9, square root of 1 //sequential maze
8 - start: 8, goal: 3, operators: +1, sqrt, +1, -1, +1, -1              //objective: square root of 9                   //open plan
9 - start: 9, goal: 3, operators: sqrt && +1, +1, +1, +1, +1, +1, +1    //objective square root of 9 (maybe 16)         //open plan and maze of +1's

sqrt(16) = 4
10 - start: 10, goal: 4, operators: *2, -1, -1, -1, -1, sqrt              //objective square root of 16                   //sequential
11 - start: 11, goal: 4, operators: sqrt && +1, +1, +1, +1, sqrt          //objective square root of 16                   //sequential
12 - start: 12, goal: 4, operators: *2, +1, sqrt, -1                      //objective square root of 25 (maybe 16         //open plan
 
sqrt(25) = 5
13 - start: 13, goal: 5, operators: *2, sqrt                              //objective square root of 25                   //open plan
14 - start: 14, goal: 5, operators: +1, +1, sqrt +1, -1, +1               //objective square root of 16                   //sequential
15 - start: 15, goal: 5, operators: +1, sqrt && -1, -1, -1, -1, -1, -1     //objective square root of 9 (maybe 9)         //open plan and maze of -1's

//continue here after....
 
sqrt(36) = 6
16 - start: 16, goal: 6, operators: *2, +1, +1, +1, +1, sqrt               //objective square root of 36                  //sequential
17 - start: 17, goal: 6, operators: *2, +1, -1, +1, +1, sqrt               //objective square root of 36                    //sequential
18 - start: 18, goal: 6, operators: *2, sqrt, *2, sqrt, *2, sqrt            //objective square root of 36                   //open plan
 
sqrt(49) = 7
19 - start: 19, goal 7, operators: -1, -1, -1, -1, *3, +1, +1 ,+1 ,+1, sqrt //objective square root of 49                   //sequential
20 - start: 20, goal 7, operators: +1, +1, +1, +1, *2 +1, sqrt              //objective square root of 49                   //open plan
21 - start: 21, goal 7, operators: +1, +1, +1, +1, sqrt, *2, *2, *2, +1, +1, +1, +1, +1 //objective sqrt of 25 and 49       //open plan and 2 maze's of +1's
 
sqrt(64) = 8
22 - start: 22, goal: 8, operators: *3, -1, -1, sqrt                    //objective square root of 64                   //sequential
23 - start: 23, goal: 8, operators: -1, -1, *3, +1, sqrt                 //objective square root of 64                  //sequential
24 - start: 24, goal: 8, operators: +1, sqrt, *3, *4, +1, +1, +1, +1     //objective square root of 25                  //open plan and maze of +1's
 
sqrt(81) = 9
25 - start: 25, goal: 9, operators: *3, +1, +1, +1, +1, +1, +1, sqrt    //objective square root of 81                   //sequential
26 - start: 26, goal: 9, operators: +1, *3, sqrt                        //objective square root of 81                   //open plan
27 - start: 27, goal: 9, operators: -1, -1, sqrt, *2, *2, *2, *2, +1, sqrt //objective square root of 25 and 81         //sequential
 
sqrt(100) = 10
28 - start: 28, goal: 10, operators: +1, +1, +1, +1, *3, +1, +1, +1, +1, sqrt   //objective square root of 100          open plan and maze of +1's
29 - start: 29, goal: 10, operators: +1, +1, +1, +1, +1, +1, +1, sqrt, *4 +1, *5, sqrt //objective square root of 36 and 100 //sequential
30 - start: 30, goal: 10, operators: -1,-1,-1,-1 *4, sqrt                //objective square root of 100         //open plan
*/

//QQQQ consider moving to plist file

func goalOfLevel(level: Int) -> Int{
    return level/3 + (level%3 == 0 ? 0 :1)
}

let operatorLevelArray = [
[], //level 0 meaningless
[], //level 1 has no operators
["-1", "+1", "-1"],
["+1", "sqrt", "-1"],
["-1", "-1", "-1", "sqrt", "+1"],
["+1", "+1", "-1", "+1", "+1","+1", "sqrt", "-1"],
["-1", "-1", "-1", "+1", "sqrt"],
["+1", "+1", "sqrt", "-1", "-1", "sqrt", "+1", "+1"],
["+1", "sqrt", "+1", "-1", "+1", "-1"],
["sqrt","+1", "+1", "+1", "+1", "+1", "+1", "+1"],
["*2", "-1", "-1", "-1", "-1", "sqrt"],
["sqrt","+1", "+1", "+1", "+1", "sqrt"],
["*2", "+1", "sqrt", "-1"],
["*2", "sqrt"],
["+1", "+1", "sqrt", "+1", "-1", "+1"],
["+1", "sqrt","-1", "-1", "-1", "-1", "-1", "-1"],
["*2", "+1", "+1", "+1", "+1", "sqrt"],
["*2", "+1", "-1", "+1", "+1", "sqrt"],
["*2", "sqrt", "*2", "sqrt", "*2", "sqrt"],
["-1", "-1", "-1", "-1", "*3", "+1", "+1" ,"+1" ,"+1", "sqrt"],
["+1", "+1", "+1", "+1", "*2", "+1", "sqrt"],
["+1", "+1", "+1", "+1", "sqrt", "*2", "*2", "*2", "+1", "+1", "+1", "+1", "+1"],
["*3", "-1", "-1", "sqrt"],
["-1", "-1", "*3", "+1", "sqrt"],
["+1", "sqrt", "*3", "*4", "+1", "+1", "+1", "+1"],
["*3", "+1", "+1", "+1", "+1", "+1", "+1", "sqrt"],
["+1", "*3", "sqrt"],
["-1", "-1", "sqrt", "*2", "*2", "*2", "*2", "+1", "sqrt"],
["+1", "+1", "+1", "+1", "*3", "+1", "+1", "+1", "+1", "sqrt"],
["+1", "+1", "+1", "+1", "+1", "+1", "+1", "sqrt", "*4","+1", "*5", "sqrt"],
["-1","-1","-1","-1","*4", "sqrt"]]

