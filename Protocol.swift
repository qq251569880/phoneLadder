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

protocol RandomNumberGenerator{
    func random()-> Double
}

protocol DiceGame{
    var dice : Dice {get}
    func play()
}

protocol DiceGameDelegate {
    func gameDidStart(game:DiceGame)
    func gamePlay(game:DiceGame,didStartNewTurnWithDiceRoll diceRoll:Int) -> Int
    func gameDidEnd(game:DiceGame)
    func gameAlert()
}

class GenerateRandom:RandomNumberGenerator{
    func random()-> Double{
        return Double(arc4random())/ARC4RANDOM_MAX
    }
}

class Dice {
    let sides:Int
    
    let generator:RandomNumberGenerator
    
    
    init(sides:Int,generator:RandomNumberGenerator){
        self.sides = sides
        self.generator = generator
    }
    
    func roll() -> Int{
        return Int(generator.random()*Double(sides)) + 1
        
    }
}

class SnakesAndLadders:DiceGame {
    
    var delegate : DiceGameDelegate?
    
    let finalSquare = 25
    
    let dice = Dice(sides:6,generator:GenerateRandom())
    
    var square = 1
    
    var board:Int[]
    
    var gameOver = false
    init() {

        board = Int[](count :finalSquare+1,repeatedValue:0)
        board[03] = +08;board[06] = +11;board[09] = +09;board[10] = +02;
        board[14] = -10;board[19] = -11;board[22] = -02;board[24] = -08;
    }
    convenience init(finalSquare:Int) {
        self.init()
        self.finalSquare = finalSquare
    }
    func start(){
        delegate?.gameDidStart(self)
        square = 1
    }
    func play(){
        if (square == finalSquare){
            println("ask restart?")
            delegate?.gameAlert()


        }
        else {
            var diceRoll = dice.roll()
            var steps = delegate?.gamePlay(self,didStartNewTurnWithDiceRoll:diceRoll)
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




