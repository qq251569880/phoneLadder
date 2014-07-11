//
//  GameScene.swift
//  phoneLadder
//
//  Created by 张宏台 on 14-6-28.
//  Copyright (c) 2014年 张宏台. All rights reserved.
//

import SpriteKit
import Foundation
import UIKit

class GameScene: SKScene,DiceGameDelegate {
    var boardP:CGPoint = CGPointMake(0,0)
    var boardSize:CGSize = CGSizeMake(0,0)
   
    var spriteShip = SKSpriteNode()

    var spriteBoard = SKSpriteNode()
    var moveForward = SKAction()
    var moveBack = SKAction()
    var moveUp = SKAction()
    var moveRotateRight = SKAction()
    var moveRotateLeft = SKAction()
    let game = SnakesAndLadders()
    

    
    override func didMoveToView(view: SKView) {
        println("present scane")
        /* Setup your scene here */
        //背景颜色
        var skyColor = SKColor()
        skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        //背景图片，游戏图表
        var skyTexture = SKTexture(imageNamed: "snake")
        
        spriteBoard = SKSpriteNode(texture:skyTexture)
        spriteBoard.position = CGPointMake(self.frame.size.width/2,spriteBoard.size.height/2+150)
        boardP = spriteBoard.position
        var screen = UIScreen.mainScreen()
        println("screen width:\(screen.bounds.size.width),height:\(screen.bounds.size.height)")
        println("board width:\(spriteBoard.size.width),height:\(spriteBoard.size.height)")

        spriteBoard.setScale(screen.bounds.size.width/spriteBoard.size.width*1.3)
        boardSize = spriteBoard.size
        //上部文字说明
        self.addChild(spriteBoard)
        myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "player one";
        myLabel.fontSize = 20;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:self.frame.size.height-100);
        
        self.addChild(myLabel)
        
        
        //飞机
        spriteShip = SKSpriteNode(imageNamed:"Spaceship")
        println("spaceShip width:\(spriteShip.size.width),height:\(spriteShip.size.height)")
        spriteShip.setScale(screen.bounds.size.width/boardSize.width*0.2)
        spriteShip.position = CGPointMake(boardP.x-boardSize.width/5*2,spriteBoard.position.y-boardSize.height/5*2)
        self.addChild(spriteShip)
        
        game.delegate = self
        game.start()
        //设置动画
        var distanceX = boardSize.width/5
        
        var distanceY = boardSize.height / 5
        let originPos:CGPoint = spriteShip.position
        for i:Int in 0..25 {
            var cy = i/5
            var mark:Int = 1
            if(cy%2 != 0){
                mark = -1
            }

            var cx = (i%5)*mark + ((i/5)%2)*4;
            //println("\(i):(\(cx),\(cy))")
            var px = originPos.x + CGFloat(cx) * distanceX
            var py = originPos.y + CGFloat(cy) * distanceY
            var pos = CGPointMake(px,py)
            var angle:CGFloat = M_PI;
            if((i+1)%5 == 0){
                angle = M_PI / 2.0
            }
            else{
                if((i/5) % 2 == 0){
                    angle = 0.0
                }else{
                    angle = M_PI
                }
            }
            pointsPosition[i+1] = PointProperty(pointPosition: pos,angle: angle)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            if node === spriteBoard {
                game.play();
            }
            /*            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)*/
/*            if(stepOn == 25){
                continue
            }
            
            //让飞机移动
            if(stepOn%5 == 0){
                if(stepOn/5%2 == 0){
                    spriteShip.runAction(moveUpRight)
                }
                else{
                    spriteShip.runAction(moveUpLeft)
                }
            }
            else
            {
                if(stepOn/5%2 == 0){
                    spriteShip.runAction(moveForward)
                }
                else{
                    spriteShip.runAction(moveBack)
                }
            }
            stepOn++;
            if(stepOn == 25){
                myLabel.text = "You Win,Game Over!"
            }
*/
        }
    }
    
    struct PointProperty
    {
        var pointPosition:CGPoint = CGPointMake(0,0)
        var angle:CGFloat = 0.0
    }
    var pointsPosition:Dictionary<Int,PointProperty> = [:]
    
    var stepOn = 1
    var myLabel = SKLabelNode()
    
    func straightMove(start:Int,end:Int) -> SKAction {
        var actionList:SKAction[] = []
        
        var x = pointsPosition[end]!.pointPosition.x - pointsPosition[start]!.pointPosition.x
        
        var y = pointsPosition[end]!.pointPosition.y - pointsPosition[start]!.pointPosition.y
        var xy2 = x*x + y*y
        var distance:CGFloat = sqrt(xy2)
        var direction:CGFloat = 0.0
        if(y < 0){
            direction = (-acos(x/distance) + 2*M_PI)%(2*M_PI)
        }else{
            direction = (acos(x/distance) + 2*M_PI)%(2*M_PI)
            
        }
        
        
        func rotatePi(direct:CGFloat) -> CGFloat{
            if(direct > M_PI){
                return direct - 2 * M_PI
            }
            else if(direct < -M_PI){
                return direct+2*M_PI
            }
            else{
                return direct
            }
        }
        var rotateAngle1 = direction - pointsPosition[start]!.angle
        rotateAngle1 = rotatePi(rotateAngle1)
        var rotateAngle2 = pointsPosition[end]!.angle - direction
        rotateAngle2 = rotatePi(rotateAngle2)
        
        actionList += SKAction.rotateByAngle(rotateAngle1,duration:NSTimeInterval(0.2*fabs(rotateAngle1)))
        actionList += SKAction.moveByX(x,y:y,duration:NSTimeInterval(0.01*distance))
        actionList += SKAction.rotateByAngle(rotateAngle2,duration:NSTimeInterval(0.2*fabs(rotateAngle2)))
        
        return SKAction.sequence(actionList)
    }
    
    func diceStepForward(start: Int,step: Int) -> SKAction
        
    {
        var end = start+step
        println("step from \(start) to \(end)")
        var actionList:SKAction[] = []
        
        for i in start..end {
            
            actionList += straightMove(i,end: i+1)
            
        }
        
        var moveActionArray = SKAction.sequence(actionList)
        
        return moveActionArray
        
    }
    
    
    
    var numberOfTurns = 0
    func gameDidStart(game:DiceGame) {
        numberOfTurns = 0
        if game is SnakesAndLadders{
            myLabel.text = "Game Is Going"
            let ourGame = game as SnakesAndLadders
            if ourGame.square != 1 {
                var actions:SKAction[] = []
                actions += straightMove(ourGame.square,end:1)
                println("strait go from \(ourGame.square) to 1")
                spriteShip.runAction(SKAction.sequence(actions))
            }
            
        }
    }
    func gameDidEnd(game:DiceGame){
        myLabel.text = "You Win Game for \(numberOfTurns) turns"
        
    }
    func gamePlay(diceGame:DiceGame,didStartNewTurnWithDiceRoll diceRoll:Int) -> Int {
        myLabel.text = "You Rolled \(diceRoll)"
        let game = diceGame as SnakesAndLadders
        ++numberOfTurns
        println("you rolled \(numberOfTurns) times,this time rolled \(diceRoll)")
        var steps:Int = 0
        var currentSquare = game.square
        var actions:SKAction[] = []
        if(currentSquare + diceRoll > game.finalSquare){
            steps = game.finalSquare - currentSquare
            actions += diceStepForward(currentSquare,step:steps)
            currentSquare += steps
            var backs = diceRoll - steps
            actions += straightMove(currentSquare,end:currentSquare-backs)
            println("strait go from \(currentSquare) to \(currentSquare-backs)")
            
            steps = steps - backs
            currentSquare -= backs
        }else{
            actions += diceStepForward(currentSquare,step:diceRoll)
            steps = diceRoll
            currentSquare += steps
        }
        if(game.board[currentSquare] != 0){
            actions += straightMove(currentSquare,end:(currentSquare+game.board[currentSquare]))
            println("strait go from \(currentSquare) to \(currentSquare+game.board[currentSquare])")
            steps += game.board[currentSquare]
        }
        spriteShip.runAction(SKAction.sequence(actions))
        return steps
    }
    func gameRestartAsk() -> UIAlertController{
        let title = NSLocalizedString("Quit Ask", comment: "")
        let message = NSLocalizedString("Do you want quit the current game and restart.", comment: "")
        let cancelButtonTitle = NSLocalizedString("Nope", comment: "")
        let otherButtonTitle = NSLocalizedString("Yeah", comment: "")
        
        let alertCotroller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            println("The game is going on.")
        }
        
        let otherAction = UIAlertAction(title: otherButtonTitle, style: .Default) { action in
            self.game.start()
        }
        
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
        return alertCotroller
        //return false
    }
    func gameAlert(){
        let tit = NSLocalizedString("提示", comment: "")
        let msg = NSLocalizedString("游戏已结束，是否重新开始？", comment: "")
        var alert:UIAlertView = UIAlertView()
        alert.title = tit
        alert.message = msg
        alert.delegate = self
        alert.addButtonWithTitle("OK")
        alert.addButtonWithTitle("Cancel")
        alert.show()
    }
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        if(buttonIndex == 0){
            self.game.start()
        }
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
