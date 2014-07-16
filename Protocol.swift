//
//  Protocol.swift
//  phoneLadder
//
//  Created by 张宏台 on 14-7-3.
//  Copyright (c) 2014年 张宏台. All rights reserved.
//

import Foundation
import SpriteKit

let ARC4RANDOM_MAX:Double = 0x100000000
//产生随机数的协议
protocol RandomNumberGenerator{
    func random()-> Double
}
//色子游戏的协议
protocol DiceGame{
    var dice : Dice {get}
    func play()
}
//色子游戏代理的协议
protocol DiceGameDelegate {
    func gameDidStart(game:DiceGame)
    func gamePlay(game:DiceGame,didStartNewTurnWithDiceRoll diceRoll:Int) -> Int
    func gameDidEnd(game:DiceGame)
    func gameAlert()
}
//产生随机数的类
class GenerateRandom:RandomNumberGenerator{
    func random()-> Double{
        return Double(arc4random())/ARC4RANDOM_MAX
    }
}
//色子类
class Dice {
    //色子面数，由此决定roll的点数的范围
    let sides:Int
    //产生随机数生成器，类型是RandomNumberGenerator，用实现了该协议的类实例初始化
    let generator:RandomNumberGenerator
    
    
    init(sides:Int,generator:RandomNumberGenerator){
        self.sides = sides
        self.generator = generator
    }
    
    func roll() -> Int{
        return Int(generator.random()*Double(sides)) + 1
        
    }
}
//真正的游戏类
class SnakesAndLadders:DiceGame {
    //这个代理可以理解为：这个代理将具体实现这个游戏的操作，比如游戏状态的显示，飞机的移动等。我认为这个代理应该是GameScene类
    var delegate : DiceGameDelegate?
    
    let finalSquare = 25
    //色子初始化为6面的，随机数产生器使用的是GenerateRandom的对象
    let dice = Dice(sides:6,generator:GenerateRandom())
    
    var square = 1
     //记录蛇和梯子的起点和跳跃的步数
    var board:Int[]
    
    var gameOver = false
    init() {

        board = Int[](count :finalSquare+1,repeatedValue:0)
        board[03] = +08;board[06] = +11;board[09] = +09;board[10] = +02;
        board[14] = -10;board[19] = -11;board[22] = -02;board[24] = -08;
    }
    //我添加了一个convenience构造函数，助于理解convenience构造函数理解可以设置格子数量（本Demo是用不到了）
    convenience init(finalSquare:Int) {
        self.init()
        self.finalSquare = finalSquare
    }
    //我将开始的过程单独实现一次的原因是不至于让这个游戏只能玩一次，可以重新开始
    func start(){
        delegate?.gameDidStart(self)
        square = 1
    }
    //本函数调用一次，就会掷色子一次，飞机就会前进一次
    func play(){
        //如果已经到了终点，提示是否重新开始
        if (square == finalSquare){
            println("ask restart?")
            delegate?.gameAlert()


        }
        else {
            var diceRoll = dice.roll()
            var steps = delegate?.gamePlay(self,didStartNewTurnWithDiceRoll:diceRoll)
            //判断是否已经到了终点，如果到了终点，则调用结束游戏方法，以显示游戏状态
            if (square+steps! == finalSquare){
                end()
            }
            square  += steps!

        }
    }

    func end(){
        delegate?.gameDidEnd(self)
    }

}




